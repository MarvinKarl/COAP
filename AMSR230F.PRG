#include "Colf.ch"
#include "Inkey.ch"
*
*   B E F O R E   R U N N I N G  T H I S  R O U T I N E
*
*  ÖÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ·
*  ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹
*  º                                           º
*  º Name    Schedule of Receivables          º
*  º         sorted by fcltycode+status+acctnoº
*  º         customized to cbt                º
*  º                                           º
*  º Author  Ariel B. Bulan                   º
*  º Date    May 15, 2000                     º
*  º Last Update  Mar.13,2001                 º
*  ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹
*  ÓÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ½
//aga.14.02.2007.removed paysked reference

   private _ddate,npage,nchoice
   private mtemp

*********   _ddate := ctod ( '03/15/2000' )
   _ddate := date()
   npage  := 1
********   set century on
********   set deleted on
   if _sked_open()
      if create_temp()
         if get_date( @_ddate,10 )

            if lastkey() != K_ESC
               _comp_menu()
               _copy_temp()
               *repcontrol ( '_sked2_print()',,,8,33 )
               repcon_ol ( '_sked2_print()',,,8,33,,,.F. )
            endif

         endif
      endif
   endif

   close all

   ferase ( mtemp )
   ferase ( mtemp + '.dbf' )
   ferase ( mtemp + '.ntx' )

   release all

return

********************************
*
static function _comp_menu()
********************************
   local mscr := savescreen (,,,)
   local menulist, mcolor := setcolor()

   nchoice := 0

   set color to 'w/n'
   @ 10,30 clear to 18,50
   @ 10,30 to 18,50 double
   @ 12,33 prompt 'FMLC Accounts '
   @ 14,33 prompt 'PBC  Accounts '
   @ 16,33 prompt 'ORIX Accounts '
   menu to nchoice

   setcolor(mcolor)
   restscreen ( ,,,, mscr )
return nil

************************
*
function _sked2_print()
************************
   local dlastpaid   := ctod (''),clastperiod := space(5)
   local ntprincipal := 0 ,ntosbal := 0 ,ntudiamt := 0 ,ntrv := 0
   local astatus     := { '1 = Active ','2 = Past Due ','3 = In Litigation','4 = Repossessed  ','5 = Written-off  ',"6 = Sold Rec'bles" }
   local cstatus,nosbal := 0
   local nsprincipal, nsosbal, nsudiamt, nsrv
   local nfprincipal, nfosbal, nfudiamt, nfrv
   memvar _ddate

   private xprate := Parametr->Penrate * 100

********   dbselectarea ( "Acctmast" )
********   Acctmast->   ( dbsetorder(4))         // FACILITY + STATUS + ACCTNO
********   Acctmast->   ( dbgotop() )

   setfont      ( upper('condensed') )
   _head        ()

   Facility->( dbgotop() )
   do while !Facility->(eof())

      if !Facility->(deleted())      .and. ;
         !empty(Facility->fcltycode) .and. ;
         (mtemp)->(dbseek(Facility->fcltycode))

         @ prow()+1, 01 say repl('-',50)
         @ prow()+1, 01 say 'Facility : ' + Facility->fcltycode+'-'+Facility->fcltyname
         @ prow()+1, 01 say repl('-',50)

         nfprincipal := nfosbal := nfudiamt := nfrv := 0

         do while !(mtemp)->(eof()) .and. ;
                   (mtemp)->fcltycode == alltrim(Facility->fcltycode)

            cstatus     := (mtemp)->status
            nsprincipal := nsosbal := nsudiamt := nsrv := 0

            @ prow()+1, 01 say 'Status : ' + astatus [ val(cstatus) ]
            @ prow()+1, 01 say repl('-',20)

            do while !(mtemp)->(eof()) .and. ;
                      (mtemp)->fcltycode == alltrim(Facility->fcltycode) .and.;
                      (mtemp)->status    == cstatus

*********               if _stathist ( Acctmast->acctno,_ddate ) == cstatus

                  ******** if Acctmast->osbal != 0

                  nosbal := _get_outs()

                  if nosbal != 0                  .and. ;
                     (mtemp)->valdate <= _ddate  .and. ;
                     nchoice == _company_accounts(mTEMP)

                     ////////// .and. ; !_employee_loans(Acctmast->fcltycode)


                     @ prow()+1, 01       say (mtemp)->acctno    pict '@R 9999-99999-99999'
                     @ prow()  , pcol()+1 say padr( (mtemp)->acctname,30 )
                     @ prow()  , pcol()+1 say (mtemp)->valdate   pict '@D'
                     @ prow()  , pcol()+1 say (mtemp)->matdate   pict '@D'
                     @ prow()  , pcol()+1 say (mtemp)->term      pict '999'
                     @ prow()  , pcol()+1 say if ( (mtemp)->termunit != '2','Days  ','Months' ) pict '@!'
                     @ prow()  , pcol()+1 say padr( (mtemp)->unit,30+10 )
                     @ prow()  , pcol()+1 say (mtemp)->principal pict '999,999,999.99'
                     *********
                     ********* @ prow()  , pcol()+1 say (mtemp)->osbal     pict '999,999,999.99'
                     *********
                     @ prow()  , pcol()+1 say nosbal     pict '999,999,999.99'
                     @ prow()  , pcol()+1 say (mtemp)->udiamt    pict '999,999,999.99'
                     @ prow()  , pcol()+1 say (mtemp)->rv/100*(mtemp)->Principal pict '999,999,999.99'

                     clastperiod := space(10)
                     dlastpaid   := _get_last(@clastperiod)

                     @ prow()  , pcol()+1 say dlastpaid         pict '@D'
                     @ prow()  , pcol()+1 say clastperiod       pict '@!'

                     ntprincipal  += (mtemp)->principal

********
********                     ntosbal      += (mtemp)->osbal
********
                     ntosbal      += nosbal
                     ntudiamt     += (mtemp)->udiamt
                     ntrv         += ((mtemp)->rv/100*(mtemp)->principal)

                     nsprincipal  += (mtemp)->principal
**********
**********                     nsosbal      += (mtemp)->osbal
**********
                     nsosbal      += nosbal
                     nsudiamt     += (mtemp)->udiamt
                     nsrv         += ((mtemp)->rv/100*(mtemp)->principal)

                     nfprincipal  += (mtemp)->principal
**********
**********                     nfosbal      += (mtemp)->osbal
**********
                     nfosbal      += nosbal
                     nfudiamt     += (mtemp)->udiamt
                     nfrv         += ((mtemp)->rv/100*(mtemp)->principal)

                     if prow() > 50
                        npage++
                        __eject ( )
                        setprc  ( 0,0 )
                        _head   ( )
                     endif

                  endif

               *********endif

               (mtemp)->(dbskip(+1))

            enddo

            @ prow()+1  , 109+10    say repl ( '-',18 )
            @ prow()  , pcol()+1 say repl ( '-',14 )
            @ prow()  , pcol()+1 say repl ( '-',14 )
            @ prow()  , pcol()+1 say repl ( '-',14+4 )

            @ prow()+1,50 say 'Status Sub Total : '
            @ prow()  , 109+10   say nsprincipal pict '999,999,999,999.99'
            @ prow()  , pcol()+1 say nsosbal     pict '999,999,999.99'
            @ prow()  , pcol()+1 say nsudiamt    pict '999,999,999.99'
            @ prow()  , pcol()+1 say nsrv        pict '999,999,999,999.99'

            @ prow()+1  , 109+10    say repl ( '-',18 )
            @ prow()  , pcol()+1 say repl ( '-',14 )
            @ prow()  , pcol()+1 say repl ( '-',14 )
            @ prow()  , pcol()+1 say repl ( '-',14+4 )

         enddo

         @ prow()+1  , 109+10        say repl ( '-',18 )
         @ prow()  , pcol()+1 say repl ( '-',14 )
         @ prow()  , pcol()+1 say repl ( '-',14 )
         @ prow()  , pcol()+1 say repl ( '-',14+4 )

         @ prow()+1,50 say 'Facility Sub Total : '
         @ prow()  , 109+10      say nfprincipal pict '999,999,999,999.99'
         @ prow()  , pcol()+1 say nfosbal     pict '999,999,999.99'
         @ prow()  , pcol()+1 say nfudiamt    pict '999,999,999.99'
         @ prow()  , pcol()+1 say nfrv        pict '999,999,999,999.99'

         @ prow()+1  , 109+10    say repl ( '-',18 )
         @ prow()  , pcol()+1 say repl ( '-',14 )
         @ prow()  , pcol()+1 say repl ( '-',14 )
         @ prow()  , pcol()+1 say repl ( '-',14+4 )
      else
         // alert ( "not found in facility "+ str ( Acctmast->(recno()) )  )
      endif
      Facility->(dbskip(+1))
   enddo

   @ prow()+1  , 109+10    say repl ( '-',18 )
   @ prow()  , pcol()+1 say repl ( '-',14 )
   @ prow()  , pcol()+1 say repl ( '-',14 )
   @ prow()  , pcol()+1 say repl ( '-',14+4 )

   @ prow()+1,50 say 'Grand Total : '

*********
*********   @ prow()  , 109+10      say ntprincipal pict '999,999,999,999.99'
*********

   @ prow()  , 109+10-4 say ntprincipal pict '999,999,999,999.99'
   @ prow()  , pcol()+1 say ntosbal     pict '99,999,999,999.99'
   @ prow()  , pcol()+1 say ntudiamt    pict '999,999,999.99'
   @ prow()  , pcol()+1 say ntrv        pict '999,999,999,999.99'

   @ prow()+1  , 109+10    say repl ( '=',18 )
   @ prow()  , pcol()+1 say repl ( '=',14 )
   @ prow()  , pcol()+1 say repl ( '=',14 )
   @ prow()  , pcol()+1 say repl ( '=',14+4 )

   __eject ()
   setfont ( upper('normal') )

return nil

**************************************************
*
static function _stathist ( cacctno,dend )
**************************************************
   local dretval := ctod ('') ,lfound := .f., cstatus := space(1)

   if Stathist->(dbseek(cacctno))
      lfound := .t.

      do while Stathist->acctno == cacctno .and. !Stathist->(eof())

         if Stathist->trandate <= dend
            cstatus := stathist->oldstatus
         endif
         stathist->(dbskip(+1))

      enddo

   endif

   if !lfound
      cstatus := Acctmast->status
   else

      if empty(cstatus)
         cstatus := Acctmast->status
      endif

   endif

return cstatus

**************************************
*
static function _get_last(clastperiod)
**************************************
 local dretval := ctod('')
 local pgn:=1
 local tot_amrt := 0, tot_pen := 0, npent_s := 0,ncredamt:= (mtemp)->Credamt
 local Pay_:={ 'Paymt',;              //  1
               'Ret. Check',;         //  2
               'ROPOA',;              //  3
               'Db_Memo ',;           //  4
               'Misposting',;         //  5
               'Terminatx',;          //  6
               'Cr_Memo  ',;          //  7
               'REVIEW ',;            //  8
               ' ',;                  //  9
               'O_T Check',;          // 10
               'PDR ',;               // 11
               'LEGAL ',;             // 12
               'LEGAL ',;             // 13
               'Current',;            // 14
               'Current',;            // 15
               'Balance Forwarded' }  // 16
 local tot_or:=0, tot_am := 0, tot_penal := 0
 local xoramount := xamort := xpenal:=0,pprd:={},pperiod,unpd_pen := 0
 local xacctno,xornum,xrefdate,xcode,nrow:= { 05,19,32,43,60,86,93,117 }
 local prate:=xprate,pdate:= _ddate, xblk

//aga.26.04.2006.removed for delinquency reengineering
// xblk := { || Paysked->Lastpay <= pdate }

 Amshist->  ( dbseek((mtemp)->Acctno) )
 ncredamt := (mtemp)->Credamt

 do while Amshist->Acctno == (mtemp)->Acctno .and. !Amshist->(eof())

       xrefdate  := Amshist->Refdate
       xornum    := Amshist->Ornumber
       xacctno   := Amshist->Acctno
       xcode     := Amshist->Paycode
       unpd_pen  += Amshist->Unpd_pnlty

       do while Amshist->Acctno   == xAcctno  .and. ;
                Amshist->Ornumber == xornum   .and. ;
                Amshist->Refdate  == xrefdate .and. ;
                Amshist->Paycode  == xcode    .and. ;
               !Amshist->(eof())

           xOramount += If( val( Amshist->Paycode ) < 8, Amshist->Oramount, 0 )
           xamort    += Amshist->Amort
           xpenal    += Amshist->Penalty
           if ( !empty( Amshist->Paydate ) ,;
                 aadd ( pprd,Amshist->Paydate ),;
                 nil ;
              )
           Amshist->(dbskip(+1))
       enddo

       pperiod := if ( len (pprd) > 0,;
                       dtoc( pprd[ 1 ] ) + ;
                       if ( len(pprd ) > 1,;
                            '-' +dtoc(atail(pprd)),;
                            ' ' ;
                          ),;
                       ' ' ;
                     )

       if alltrim(xcode) == '1' // PAYMENT ? ( Sept. 07, 1999 )
          dretval     := xrefdate
          clastperiod := pperiod + '->'+ pay_ [ val( xcode ) ]
       else
          dretval     := xrefdate
          clastperiod := pperiod + '->'+ pay_ [ val( xcode ) ]
       endif

       pprd      := {}
       tot_or    += xOramount
       tot_am    += xamort
       tot_penal += xPenal
       xoramount := xamort := xpenal:=0

 enddo

return dretval

******************************
static function _get_period()
******************************
   local cretval := ' '

return cretval

****************************
static function _head()
****************************
   memvar npage,_ddate
   setprc ( 0,0 )
   @ prow ()+1,01 say 'Page : '+ str(npage)
   @ prow ()+1,01 say 'Schedule of Receivables as of ' + dtoc( _ddate )
   @ prow ()+1,01 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   @ prow ()+1,01 say 'Account          Account                        Execution  Maturity     Term     Items for Leases /                             Net        Outstanding          UDI     Residual  Date of Last   Period Paid'
   @ prow ()+1,01 say 'Number           Name                           Date       Date                  Collaterals for Loans                          Proceeds   Balance              ALIR    Value     Payment        '
   @ prow ()+1,01 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   @ prow ()+1,01 say ' '
return nil

**************************************
*
static function get_date( mdate,mrow )
**************************************
    local mcolor := setcolor(), mcursor:= setcursor(), mretval, getlist := {}
    
    fshadow   ( mrow, 21, mrow + 2, 51, 2, 'gr+/g' )
    setcolor  ( 'w/g, w+/n,,, w+/g' )

    @ mrow + 1, 22 say 'As of Date ' get mdate when !empty( mdate := getdate( mdate, mrow + 1, 41, 'w/gr, gr+/gr,,, n/gr' ) )
    setcursor( 3 )
    read

    if lastkey() == K_ESC
       mretval := .f.
    else
       mretval := .t.
    endif

    setcolor  ( mcolor )
    setcursor ( mcursor )
return mretval


****************************
*
static function _get_outs( )
****************************
   local nretval := (mtemp)->credamt, ddate := ctod ('')
   local dretval := ctod('')
   local pgn:=1
   local tot_amrt := 0, tot_pen := 0, npent_s := 0,ncredamt:= (mtemp)->Credamt
   local Pay_:={ 'Paymt',;              // 1
                 'Ret. Check',;         // 2
                 'ROPOA',;              // 3
                 'Db_Memo ',;           // 4
                 'Misposting',;         // 5
                 'Terminatx',;          // 6
                 'Cr_Memo  ',;          // 7
                 'REVIEW ',;            // 8
                 ' ',;                  // 9
                 'O_T Check',;          //10
                 'PDR ',;               //11
                 'LEGAL ',;             //12
                 'LEGAL ',;             //13
                 'Current',;            //14
                 'Current',;            //15
                 'Balance Forwarded' }  //16
   local tot_or:=0, tot_am := 0, tot_penal := 0
   local xoramount := xamort := xpenal:=0,pprd:={},pperiod,unpd_pen := 0
   local xacctno,xornum,xrefdate,xcode,nrow:= { 05,19,32,43,60,86,93,117 }
**********   local prate:=xprate,pdate:= _ddate, xblk
   memvar _ddate

//aga.26.04.2006.removed for delinquency reengineering
//   xblk := { || Paysked->Lastpay <= pdate }

   Amshist->  ( dbseek((mtemp)->Acctno) )
   ncredamt := (mtemp)->Credamt

   do while Amshist->Acctno == (mtemp)->Acctno .and. !Amshist->(eof())

         xrefdate  := Amshist->Refdate
         xornum    := Amshist->Ornumber
         xacctno   := Amshist->Acctno
         xcode     := Amshist->Paycode
         unpd_pen  += Amshist->Unpd_pnlty

         do while Amshist->Acctno   == xAcctno  .and. ;
                  Amshist->Ornumber == xornum   .and. ;
                  Amshist->Refdate  == xrefdate .and. ;
                  Amshist->Paycode  == xcode    .and. ;
                 !Amshist->(eof())

             if xrefdate <= _ddate

                xOramount += if ( val( Amshist->Paycode ) < 8,;
                                  Amshist->Oramount,;
                                  0;
                                )
                xamort    += Amshist->Amort
                xpenal    += Amshist->Penalty
                if ( !empty( Amshist->Paydate ) ,;
                      aadd ( pprd,Amshist->Paydate ),;
                      nil ;
                   )

             endif

             Amshist->(dbskip(+1))
         enddo

         pperiod := if ( len (pprd) > 0,;
                         dtoc( pprd[ 1 ] ) + ;
                         if ( len(pprd ) > 1,;
                              '-' +dtoc(atail(pprd)),;
                              ' ' ;
                            ),;
                         ' ' ;
                       )

/*********************************
         if alltrim(xcode) == '1' // PAYMENT ? ( Sept. 07, 1999 )
            dretval     := xrefdate
            clastperiod := pperiod + '->'+ pay_ [ val( xcode ) ]
         else
            dretval     := xrefdate
            clastperiod := pperiod + '->'+ pay_ [ val( xcode ) ]
         endif
************************/

         nretval -= (xamort)

         pprd      := {}
         tot_or    += xOramount
         tot_am    += xamort
         tot_penal += xPenal
         xoramount := xamort := xpenal:=0

   enddo

return nretval

****************************
static function _sked_open()
****************************
   local lretval := .t.

   if netuse( 'Acctmast',.f., 5 )
      set index to Acctmast,Acctclnt,Sureclnt,Acctfa2,Acctsub2,Acctaonm,Acctacno,Acctval
      Acctmast->( dbsetorder (1) )
   else
      lretval := .f.
   endif

   if netuse ( 'Stathist',.f.,5 )
      set index to Stathist
   else
      lretval := .f.
   endif


   if netuse( 'Amshist', .f., 10 )              && Account Payment history file
      ordlistadd( 'Amshist' )                   && set index on acctno
   else
      lretval := .f.
   endif

//aga.26.04.2006.removed for delinquency reengineering
//   if netuse( 'Paysked', .f., 10 )              && Account Payment schedule file
//      ordlistadd( 'Paysked' )                   && set index on acctno
//   else
//      lretval := .f.
//   endif

   if !netuse( 'Parametr', .f., 10 )            && Parametr File
      lretval := .f.
   endif

   if !netuse( 'Facility', .f., 10 )            && Facility File
      lretval := .f.
   else
      ordlistadd ( 'Fcltycd' )
   endif

return lretval
/*
************************************
*
static function _company_accounts()
************************************
   local cretval := 3        // 1-metro,2-pbc,3-orix

   if nchoice == 0
      cretval := 0
   else
      do case
         case substr(alltrim( (mtemp)->acctno ),1,4) == '9907'    // METRO
            cretval := 1

         case substr(alltrim( (mtemp)->acctno ),1,4) == '9908'    // PBC
            cretval := 2

      endcase
   endif

return cretval

****************************************************
*
static function _employee_loans(cfcltycode)
****************************************************
   local lretval := .f.

   if cfcltycode == '10451' .or. ;
      cfcltycode == '10452' .or. ;
      cfcltycode == '10453' .or. ;
      cfcltycode == '10454'
      lretval := .t.
   endif

return lretval
*/
********************************
*
static function _copy_temp()
********************************
   memvar _ddate

   waiton( 'Transferring to temporary file',, 'n*/+w' )

   Acctmast->   ( dbgotop() )
   do while !Acctmast->(eof())

      if Acctmast->valdate <= _ddate

         (mtemp)->(dbappend())

         (mtemp)->acctno    := Acctmast->acctno
         (mtemp)->acctname  := Acctmast->acctname
         (mtemp)->valdate   := Acctmast->valdate
         (mtemp)->matdate   := Acctmast->matdate
         (mtemp)->term      := Acctmast->term
         (mtemp)->termunit  := Acctmast->termunit
         (mtemp)->unit      := Acctmast->unit
         (mtemp)->fcltycode := Acctmast->fcltycode
         (mtemp)->udiamt    := Acctmast->udiamt
         (mtemp)->rv        := Acctmast->rv
         (mtemp)->credamt   := Acctmast->credamt
         (mtemp)->principal := Acctmast->principal

         ********(mtemp)->status    := Acctmast->status

         (mtemp)->status    := _stathist ( Acctmast->acctno,_ddate )

      endif

      Acctmast->(dbskip(+1))
   enddo

   waitoff()

return nil

********************************
*
static function create_temp()
********************************
   memvar mtemp
   local mretval := .f.
   local mstruct := { { 'ACCTNO'   ,'C',14,0 },;
                      { 'ACCTNAME' ,'C',50,0 },;
                      { 'VALDATE'  ,'D',08,0 },;
                      { 'MATDATE'  ,'D',08,0 },;
                      { 'TERM'     ,'N',03,0 },;
                      { 'TERMUNIT' ,'C',03,0 },;
                      { 'UNIT'     ,'C',40,0 },;
                      { 'FCLTYCODE','C',05,0 },;
                      { 'STATUS'   ,'C',01,0 },;
                      { 'UDIAMT'   ,'N',12,2 },;
                      { 'RV'       ,'N',09,6 },;
                      { 'CREDAMT'  ,'N',12,2 },;
                      { 'PRINCIPAL','N',12,2 };
                    }

   mtemp  := uniqfile()
   dbcreate ( ( mtemp ) , mstruct )
   if valtype ( mtemp ) != 'U'
      if netuse ( (mtemp) ,.t.,0 )
         index on FCLTYCODE + ;     // Facility Code
                  STATUS    + ;    // Account Status
                  ACCTNO      ;     // Account Number
                  to &mtemp
         set index to &mtemp
         mretval := .t.
      endif
   endif
return mretval
/*
********************************
static function uniqfile()
********************************
   local mfiname, mrandnum
   do while .t.
      mrandnum := substr(time(),1,2) + substr(time(),4,2) + substr(time(),7,2)
      mfiname  := 'TF' + mrandnum
      if file(mfiname+'.dbf')                 // test if text file exist
         loop
      else
         exit
      endif
   enddo
return mfiname
*/
*
*                   end of the program ( amsr230f.prg )
*
