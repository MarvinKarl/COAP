/*
旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
�   program id.........:  amsr2001.prg                                         �
�   Description........:  Registry of Credit Applications                      �
�   Author.............:  Ariel B. Bulan                                       �
�   Date...............:  01:42pm 26-Jun-1995                                  �
쳐컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
�                         U P D A T E S                                        �
쳐컴컴컴컴컴컴컴컴컴쩡컴컴컴컴컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
�        Who        �     When      �               Why                        �
쳐컴컴컴컴컴컴컴컴컴탠컴컴컴컴컴컴컴탠컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
읕컴컴컴컴컴컴컴컴컴좔컴컴컴컴컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
*/

#include "Colf.ch"
#include "Inkey.ch"

#define MAXROW 55
memvar ax_level,g_user_id
if chkpass( procname(),ax_level,g_user_id )
   if amsr2001open()
      nosnow(.t.)
      amsr2001main()
      nosnow(.f.)
   endif
   eval ({|| __mrelease( "*", .t.), dbcloseall() })
endif
return
******************************
static function amsr2001main()
******************************
   *repcontrol ('amsr2001print()',,,8,33)
   repcon_ol ('amsr2001print()',,,8,33,,,.F.)
return nil
********************************
function amsr2001print()
********************************
   local mscr := savescreen(,,,),mrecno := 0, mlastrec := 0
   private mtitle := 'REGISTRY OF CREDIT APPLICATIONS',mpage := 1

   Caheader->( dbgotop() )
   if !Caheader->(eof())
      setprc (0,0) ; setfont( "ELITE" )
      printhead()  ; printsubhead() ; dispmessage()
      mlastrec := Caheader->(lastrec())
      Caheader->( dbeval ( {|| mrecno++, dispbar( mrecno,mlastrec ),;
                               if(!Caheader->(deleted()),printrec(),nil)},,;
                           {|| !Caheader->(eof()) }))
      __eject()
      setfont( "NORMAL" )
   endif
   restscreen(,,,,mscr)
return nil
******************************************
static function dispbar( mrecno,mlastrec )
******************************************
   local mcol,mcolor,mper := (mrecno/mlastrec)*100
   set device to screen
   dispbegin()
   mcol := 22 + ((mrecno/mlastrec)/100) * 33 * 100
   setpos ( 13,33 ) ; dispout ( padr ( Caheader->CANUMBER    ,22 ), 'w+/gr' )
   setpos ( 14,33 ) ; dispout ( padr ( dtoc(Caheader->CADATE),22 ), 'w+/gr' )
   setpos ( 15,33 ) ; dispout ( left ( dispclntname(Caheader->BRCODE+Caheader->CLNTCODE, 35),22), 'w+/gr' )
   setpos ( 16,33 ) ; dispout ( padr ( dispactaken (Caheader->ACTAKEN ),22), 'w+/gr' )
//   setpos ( 17,33 ) ; dispout ( padr ( trans( Caheader->CALINE,'999,999,999.99' ),22 ), 'w+/gr' )
   setpos ( 17,33 ) ; dispout ( padr ( trans( Caheader->PRNLINE,'999,999,999.99' ),22 ), 'w+/gr' )
   setpos ( 19,22 ) ; dispout ( repl ( ' ',mcol-22) ,'n/w' )
   if col() >= 38
      do case
         case col() == 38
            setpos ( 19,37 ) ; dispout ( left ( ltrim(trans(mper,'999')),1)       ,'n/w'   )
            setpos ( 19,38 ) ; dispout ( right( rtrim(trans(mper,'999')),1)+ '%'  ,'w+/gr' )
         otherwise
            setpos ( 19,37 ) ; dispout ( ltrim( trans( mper, '999' ) ) + '%','n/w')
      endcase
   else
      setpos ( 19,37 ) ; dispout ( ltrim( trans( mper, '999' ) ) + '%','w+/gr')
   endif
   dispend()
   set device to printer
return nil
*************************************
static function dispmessage()
*************************************
  set device to screen
  dispbegin()
  fshadow( 12, 21, 20, 55, 2, 'w/gr' )
  setpos ( 13, 22 ); dispout ( '   CA N�  ', 'bg+/gr' )
  setpos ( 14, 22 ); dispout ( ' CA Date  ', 'bg+/gr' )
  setpos ( 15, 22 ); dispout ( '  Client  ', 'bg+/gr' )
  setpos ( 16, 22 ); dispout ( '  Status  ', 'bg+/gr' )
  setpos ( 17, 22 ); dispout ( ' CA Line  ', 'bg+/gr' )
  setpos ( 18, 21 ); dispout ('팠袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴�','w/gr')  
  dispend()
  set device to printer
return nil
******************************
static function printhead()
******************************
   memvar mpage,mtitle,gsys_name,gcompany,mtrandate
   devpos( prow()+1, 00 )  ; devout( gsys_name )
   devpos( prow()  , 85 )  ; devout( 'Page : '+ltrim(trans(mpage,'9,999')) )
   devpos( prow()+1, 00 )  ; devout( 'Program ID:AMSR2001' )
   devpos( prow()  , 74 )  ; devout( date() )
   devpos( prow()  , pcol()+1 ) ; devout( time() )
   pagecenter( prow()+2, 96, gcompany )
   pagecenter( prow()+1, 96, mtitle   )
   pagecenter( prow()+1, 96, 'As of '+alltrim(cmonth(mtrandate))+' '+ltrim(trans(day(mtrandate),'99'))+', '+ltrim(trans(year(mtrandate),'9999')) )
   mpage++
return nil
******************************
static function printrec()
******************************
   local mc := { 0,10,22,31,68,81 }
   @ prow()+1, mc[1] say Caheader->CANUMBER pict '99999'
   @ prow()  , mc[2] say Caheader->CADATE   pict '@D'
   @ prow()  , mc[3] say Caheader->CLNTCODE pict '99-99999'
   @ prow()  , mc[4] say dispclntname( Caheader->BRCODE+Caheader->CLNTCODE, 35 ) pict '@X'
   @ prow()  , mc[5] say dispactaken ( Caheader->ACTAKEN  ) pict '@X'
//   @ prow()  , mc[6] say Caheader->CALINE   pict '999,999,999.99'
   @ prow()  , mc[6] say Caheader->PRNLINE   pict '999,999,999.99'
   if prow() >= MAXROW
      fejectpause()
      printhead()
      printsubhead()
   endif
return nil
***************************************
static function dispactaken( mactaken )
***************************************
   local mACTCHOICES := space(12) + 'FOR APPROVALAMENDED     APPROVED    DISAPPROVED CLOSED      '

//aga.17.01.2006.processing code 0 bypass for display
if mactaken == '0'
   return 'PROCESSING  '
end if
//..................................................

return substr( mactchoices, val( mactaken ) * 12 + 1 , 12 )
/*
*****************************************
static function dispclntname( mclntcode )
*****************************************
return eval ({ |x,y| x:= savedbf ( x ), Client->( dbsetorder(1) ),;
                     Client->( dbseek(mclntcode) ), y:= left( Client->FULLNAME, 35 ),;
                     restdbf( x ), y })
*/
******************************
static function printsubhead()
******************************
   @ prow()+2, 00 say '컴컴컴컴  컴컴컴컴컴  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴  컴컴컴컴컴컴 컴컴컴컴컴컴컴'
   @ prow()+1, 00 say '   CA      CA Date    Client Code/Name                              Status       Credit Line'
   @ prow()+1, 00 say ' Number'
   @ prow()+1, 00 say '컴컴컴컴  컴컴컴컴컴  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴  컴컴컴컴컴컴 컴컴컴컴컴컴컴'
return nil
******************************
static function amsr2001open()
******************************
   local mretval := .f.
   if netuse( '&g_AMS_PATH\Caheader',.f.,5)
      set index to &g_AMS_PATH\Caheader,;
                   &g_AMS_PATH\Carev,;
                   &g_AMS_PATH\Caclnt
      Caheader->( dbsetorder(1) )
      if netuse( '&g_cis_path'+'\Client.dbf',.f.,5)
         set index to &g_cis_path\Cliecd,;
                      &g_cis_path\Clienm
         mretval := .t.
      endif
   endif
return mretval
*                     End of the program ( amsr2001.prg )
