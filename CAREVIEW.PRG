/*
 ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³   PROGRAM ID.........:  amsm0100.prg                                 ³
 ³   Description........:  credit application for review ( per period ) ³
 ³   Author.............:  Ariel B. Bulan                               ³
 ³   Date...............:  10:30pm 15-Aug-1994                          ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                         ³  U P D A T E S  ³
 ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³        Who        ³     When      ³               Why                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

private _dstart, dend

set deleted on
set century on

//if CHKPASS ( procname(),ax_level,g_user_id )  // if the user can access this function
   if _amsropen()                          // if all .dbf files are opened
       _dstart := ctod ( '07/01/2003' )
       _dend   := ctod ( '06/30/2004' )
       *repcontrol ( '_print_ca()' )
       repcon_ol ( '_print_ca()',,,,,,,.F. )
   endif
//endif

close all
return

***********************
*
function _print_ca()
***********************

   npage := 1
   setprc (0,0)
   @ prow ()+1, 00 say "Schedule of CA's for review"
   @ prow ()+1, 00 say "For the period "+dtoc(_dstart)+" - " + dtoc(_dend)
   @ prow ()+1, 00 say "Page  " +trans(npage,"999,999")
   @ prow ()+1, 00 say " "
   @ prow ()+2, 00 say "             Client                                          Ca Date     Review Date "
   @ prow ()+1, 00 say " "

   Caheader->(dbgotop())
   do while !Caheader->(eof())

      if Caheader->revdate >= _dstart .and. Caheader->revdate <= _dend

         nmdate  := Caheader->revdate
         ntotal  := 0

         @ prow()+1, 00 say ' '
         @ prow()+1, 00 say upper(cmonth(nmdate) ) + ' '+ trans( year(nmdate),"9999" )
         @ prow()+1, 00 say ' '


         do while month(nmdate) == month(Caheader->revdate) .and. ;
                 !Caheader->(eof())

         @ prow()+1, 00       say Caheader->clntcode             pict '@!'
         @ prow()  , pcol()+2 say _dispname(Caheader->clntcode)  pict '@!'
         @ prow()  , pcol()+2 say Caheader->cadate               pict '@D'
         @ prow()  , pcol()+2 say Caheader->revdate              pict '@D'

         if prow() > 55
            setprc(0,0)
            __eject()
            npage++
            @ prow ()+1, 00 say "Schedule of CA's for review"
            @ prow ()+1, 00 say "For the period "+dtoc(_dstart)+" - " + dtoc(_dend)
            @ prow ()+1, 00 say "Page  " +trans(npage,"999,999")
            @ prow ()+1, 00 say " "
            @ prow ()+2, 00 say "             Client                                          Ca Date     Review Date "
            @ prow ()+1, 00 say " "
         endif

         ntotal++
         Caheader->(dbskip(+1))

         enddo
         @prow()+1,00 say 'Total for this month '+ trans(ntotal,"999,999")

      else
         Caheader->(dbskip(+1))


      endif
   enddo

   __eject()

return nil

static function _dispname()
   local cretval
   Client->(dbseek(Caheader->clntcode))
   cretval := Client->fullname
return cretval

static function _amsropen()

   if !NETUSE(  'Caheader',.f.,5)
      return .f.
   else
      set index  to Caheader,Carev,Caclnt
      Caheader->( dbsetorder (2) )
   endif

   if !netuse(  '\colfsys\cis\run\Client', .f., 5 )
      return .f.
   else
      set index  to 'z:\colfsys\cis\run\Cliecd'
      Client->( dbsetorder (1) )
   endif

return .t.
*
*
*
