*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
*³ Orix Metro Leasing and Finance                                            ³Û
*³ Account Management System                                                 ³Û
*ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Û
*³ Program ID...: AMSR230B.PRG                                               ³Û
*³ Description..: Schedule of receivable BSP - Format                        ³Û
*³ Author...... : Ariel B. Bulan                                             ³Û
*³ Date.........: 15-May-2000   10:16:36am                                   ³Û
*ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Û
*³                        U P D A T E S                                      ³Û
*ÃÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Û
*³  Who  ³ When        ³ Why                                                 ³Û
*ÃÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Û
*³       ³ 27-Aug-2001 ³ exclude sold rec'bles, add menu for sol & not sold  ³Û
*³  MTS  ³ 29-Dec-2006 ³ add AMSHIST2                                        ³Û
*³  AGA  ³ 14-Feb-2007 ³ removed paysked reference                           ³Û
*³  RMS  ³ 05-Jul-2010 ³ create temporary file at C:\LOTUS directory         ³Û
*³       ³             ³                                                     ³Û
*ÀÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙÛ
*  ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

#include "colf.ch"
#include "inkey.ch"

*
*   B E F O R E   R U N N I N G  T H I S  R O U T I N E
*
*
*  (1) osbal <= 0 in acctmast MUST be deleted
*  (2) acctmast->(indexkey()) = fcltycode+status+acctno   ( acctfa2.ntx )

#define PICT1 "999,999,999,999.99"

local getlist := {}
local z230b, aAccount[3], aPrint[2]
private sDate, nSold, nchoice

begin sequence
   if ! chkpass( "AMSR2200", m->AX_LEVEL, m->g_USER_ID )
      break
   endif

   if ( m->TRUE_BRCH == "001" )
      if ! netUse( "&g_AMS_PATH\Acctmast",.f., 5 )
         break
      endif
      set index to &g_AMS_PATH\Acctmast

      if ! netUse( "&g_AMS_PATH\Stathist",.f.,5 )
         break
      endif
      set index to &g_AMS_PATH\Stathist

      if ! netUse( "&g_AMS_PATH\canclact",.f.,5 )
         break
      endif
      set index to &g_AMS_PATH\canclact

      if ! netUse( "&g_AMS_PATH\Amshist", .f., 10 ) && Account Payment history file
         break
      endif
      ordlistadd( "&g_AMS_PATH\Amshist" )        && set index on acctno

      if ! netUse( "&g_AMS_PATH\AMSBACK\Amshist2", .f., 10 ) && Account Payment history file
         break
      endif
      ordlistadd( "&g_AMS_PATH\AMSBACK\Amshist2" ) && set index on acctno

      if ! netUse( "&g_AMS_PATH\UdiAlir",.f.,5 )
         break
      endif
      set index to &g_AMS_PATH\UdiAlir
      ** udialir.ntx - brcode+acctno
	  
      if ! netUse( "&g_AMS_PATH\Amsback\UdiAlir2",.f.,5 )
         break
      endif
      set index to &g_AMS_PATH\Amsback\UdiAlir3
      ** udialir3.ntx - brcode+acctno

      if ! netUse( "&g_AMS_PATH\Udi",.f.,5 )
         break
      endif
      set index to &g_AMS_PATH\Udi
      ** udi.ntx - brcode+acctno

      if ! netUse( "&g_AMS_PATH\Alir",.f.,5 )
         break
      endif
      set index to &g_AMS_PATH\Alir
      ** alir.ntx - brcode+acctno

      if ! netUse( "&g_GL_PATH\FLAG",.f.,5 )
         break
      endif

      if ! netUse( "&g_AMS_PATH\Facility", .f., 10 ) && Facility File
         break
      endif
      ordlistadd( "&g_AMS_PATH\Fcltycd" )
   endif

   z230b := tempName()
   dbCreate( (z230b), { ;
      { "fcltycode","c",05,00 },;
      { "status"   ,"c",01,00 },;
      { "brcode"   ,"c",03,00 },;
      { "acctno"   ,"c",14,00 },;
      { "acctname" ,"c",50,00 },;
      { "unit"     ,"c",40,00 },;
      { "term"     ,"n",03,00 },;
      { "termunit", "c",03,00 },;
      { "valdate"  ,"d",08,00 },;
      { "matdate"  ,"d",08,00 },;
      { "principal","n",12,02 },;
      { "balance"  ,"n",14,02 },;
      { "udiamt"  , "n",14,02 },;
      { "rv_amt"   ,"n",14,02 },;
      { "lastpaid", "d",08,00 },;
      { "period",   "c",30,00 },;
      { "fcltyname","c",40,00 } } )
   dbUseArea( .T.,, (z230b), "z230b", .F. )
   index on fcltycode+status+brcode+acctno to (z230b)
   Set Index to (z230b)

   sDate := m->gTRANDATE
   nChoice := 3
   aAccount[1] := RadioButto( 08,28 ," FMLC Accounts")
   aAccount[2] := RadioButto( 09,28 ," PBC  Accounts")
   aAccount[3] := RadioButto( 10,28 ," ORIX Accounts")

   nSold    := 1
   aPrint[1] := RadioButto( 13,28, "All (Excluding Sold) " )
   aPrint[2] := RadioButto( 14,28, "Sold Receivables only" )

   rmsBox( 05,20,11,40,2,,"w+/rb" )
   while .T.
      setcolor( "w+/rb,w+/b,,,w+/bg")
      @ 06,25 say "Date :" get sDate pict "@D"
      @ 07,25,11,55 get nChoice RADIOGROUP aAccount ;
         CAPTION " Select Accounts " COLOR "w/rb,w+/rb,r/rb"
      @ 12,25,15,55 get nSold RADIOGROUP aPrint COLOR "w/rb,w+/rb,r/rb"
      setcursor(1)
      READ
      setcursor(0)
      if lastkey() == 27
         exit
      endif

      if GetData( sDate, nChoice, nSold )
         reportprint( "_sked_print()","132 Column" )
      endif
   enddo
end sequence
dbcloseall()
tempErase()
__MRelease( "*", .T. )

return

*******************************************************************************
static function GetData( pdDATE, pnChoice, pnSold )
   local cBrAccnt, lSkip, xStr
   local nH, cFile, cText
   local aTemp_[3], dLast, cPeriod
   local isOK := .F.

	Desktop(.T.)
   select "z230b" ; __dbZap()

   begin sequence
      if ( m->TRUE_BRCH == "001" )
         rmsBox( 05,10,15,60,1,"Gathering data. please wait...","n/w,w+/r" )
         setColor("g/n")
         acctmast->( dbseek(m->g_PAR_BRCH) )
         while ! acctmast->( eof() ) .and. acctmast->brcode == m->g_PAR_BRCH
            if pAbort()
               break
            endif
            scroll( 07,11,19,69,1 )
            @ 19,11 say acctmast->brcode+"-"+acctmast->acctno + " "+left(acctmast->acctname,29)+" "+dtoc(acctmast->valdate)

            // skip if booked date is greater than request date
            if acctmast->valdate > pdDATE
               acctmast->( dbSkip() )
               loop
            endif

            // check cancelled status
            cBrAccnt := acctmast->brcode+acctmast->acctno
            if acctmast->status == "0"
               lSkip := .T.
               if canclact->( dbseek(cBrAccnt) ) .and. canclact->date > pdDATE
                  lSkip := .F.
               endif
               if lSkip
                  acctmast->( dbskip(1) )
                  loop
               endif
            endif

            // Account choices
            if pnChoice == 1
               if left(acctmast->acctno, 4) != "9907"
                  acctmast->( dbskip() )
                  loop
               endif
            elseif pnChoice == 2
               if left(acctmast->acctno, 4) != "9908"
                  acctmast->( dbskip() )
                  loop
               endif
            endif

            // check status
            aTemp_[1] := _GetStatus( cBrAccnt, pdDATE )
            if nSold == 1
               if aTemp_[1] == "6"
                  acctmast->( dbskip() )
                  loop
               endif
            else // sold recievables only
               if aTemp_[1] != "6"
                  acctmast->( dbskip() )
                  loop
               endif
            endif

            // outstanding balance
            aTemp_[2] := Round( _GetOSBal( cBrAccnt, pdDATE ), 2 )
            if aTemp_[2] == 0
               acctmast->( dbskip() )
               loop
            endif
            aTemp_[3] := _GetUDI( cBrAccnt, pdDATE )
            dLast   := ctod("")
            cPeriod := ""
            _Payment( cBrAccnt, sDate, @dLast, @cPeriod )

            z230b->( dbappend() )
            z230b->fcltycode := acctmast->fcltycode
            z230b->status    := aTemp_[1]
            z230b->brcode    := acctmast->brcode
            z230b->acctno    := acctmast->acctno
            z230b->acctname  := acctmast->acctname
            z230b->termunit  := acctmast->termunit
            z230b->unit      := acctmast->unit
            z230b->term      := acctmast->term
            z230b->valdate   := acctmast->valdate
            z230b->matdate   := acctmast->matdate
            z230b->principal := acctmast->principal
            z230b->balance   := aTemp_[2]
            z230b->udiamt    := aTemp_[3]
            z230b->rv_amt    := (acctmast->principal * acctmast->rv / 100)
            z230b->lastpaid  := dLast
            z230b->period    := cPeriod
            z230b->fcltyname := __Facility( acctmast->fcltycode )
            acctmast->( dbskip() )
         enddo
      else
         xStr := chk_par( m->g_PAR_BRCH )  +; // branch
                 chk_par( pdDATE )         +;
                 chk_par( nChoice )        +;
                 chk_par( nSold )

         cFile := do_cps( xStr, "_SKED_PRINT" )
         if empty(cFile)
            break
         endif
         cFile := CopyFile( cFile )

         rmsBox( 05,10,15,60,1,"Gathering data. please wait...","n/w,w+/r" )
         setColor("g/n")
         nH := fOpen( cFile, 0 )
         fSeek( nH, 0 )
         while .T.
            cText := fReadStr( nH, 294 )
            if cText == ""
               exit
            endif
            cText := rms_Parse( cText, "~" )
            scroll( 07,11,19,69,1 )

            @ 19,11 say cText[03]+"-"+cText[04]+ " "+left(cText[05],29)+" "+cText[09]

            z230b->( dbappend() )
            z230b->fcltycode := cText[01]
            z230b->status    := cText[02]
            z230b->brcode    := cText[03]
            z230b->acctno    := cText[04]
            z230b->acctname  := cText[05]
            z230b->termunit  := cText[06]
            z230b->unit      := cText[07]
            z230b->term      := val( cText[08] )
            z230b->valdate   := ctod( cText[09] )
            z230b->matdate   := ctod( cText[10] )
            z230b->principal := val( cText[11] )
            z230b->balance   := val( cText[12] )
            z230b->udiamt    := val( cText[13] )
            z230b->rv_amt    := val( cText[14] )
            z230b->lastpaid  := ctod( cText[15] )
            z230b->period    := cText[16]
            z230b->fcltyname := cText[17]
         enddo
         CloseFile( nH, cFile )
      endif
      if z230b->( dbcommit(), reccount() ) == 0
         Error( "No record to print." )
         break
      endif

      isOK := .T.
   end sequence
	Desktop(.F.)
return isOK

*******************************************************************************
function _sked_print()
   local asTotals, afTotals, agTotals := { 0,0,0,0 }
   local cStatus, cFCode
   local nPage := 1

   InitLPT()
   z230b->( dbgotop() )
   _head230b( nPage++, .F. )
   while ! z230b->( eof() )
      if cFCode != z230b->fcltycode
         if prow() > 58
            _head230b( nPage++, .T. )
         endif
         cFCode := z230b->fcltycode
         afTotals := { 0,0,0,0 }
         @ prow()+1,01 say "Facility : " + z230b->fcltycode + "-" + z230b->fcltyname
         @ prow()+1,01 say repl("-",50)
      endif

      if cStatus != cFCode + z230b->status
         if prow() > 58
            _head230b( nPage++, .T. )
         endif
         cStatus  := cFCode + z230b->status
         asTotals := { 0,0,0,0 }

         @ prow()+1,01 say "Status : " + _dstatus( z230b->status )
         @ prow()+1,01 say repl("-",20)
      endif

      if prow() > 58
         _head230b( nPage++, .T. )
      endif

      @ prow()+1,01       say z230b->brcode+z230b->acctno  pict "@R 999-9999-99999-99999"
      @ prow()+0,pcol()+1 say padr( z230b->acctname, 30 )
      @ prow()+0,pcol()+1 say z230b->valdate   pict "@D"
      @ prow()+0,pcol()+1 say z230b->matdate   pict "@D"
      @ prow()+0,pcol()+1 say z230b->term      pict "999"
      @ prow()+0,pcol()+1 say if( z230b->termunit != "2","Days  ","Months" ) pict "@!"
      @ prow()+0,pcol()+1 say z230b->unit
      @ prow()+0,pcol()+1 say z230b->principal pict PICT1
      @ prow()+0,pcol()+1 say z230b->balance   pict PICT1
      @ prow()+0,pcol()+1 say z230b->udiamt    pict PICT1
     if substr(z230b->fcltycode,1,3) == '103'   // bong
      @ prow()+0,pcol()+1 say z230b->rv_amt    pict PICT1
	  else
	  rv := 0
	  @ prow()+0,pcol()+1 say rv    pict PICT1
	  endif
      @ prow()+0,pcol()+1 say z230b->lastpaid  pict "@D"
      @ prow()+0,pcol()+1 say z230b->period    pict "@!"

      // status totals
      asTotals[1] += z230b->principal
      asTotals[2] += z230b->balance
      asTotals[3] += z230b->udiamt
     if substr(z230b->fcltycode,1,3) == '103'   // bong
      asTotals[4] += z230b->rv_amt
	  endif

      // facility totals
      afTotals[1] += z230b->principal
      afTotals[2] += z230b->balance
      afTotals[3] += z230b->udiamt
     if substr(z230b->fcltycode,1,3) == '103'   // bong
      afTotals[4] += z230b->rv_amt
	  endif

      // grand totals
      agTotals[1] += z230b->principal
      agTotals[2] += z230b->balance
      agTotals[3] += z230b->udiamt
     if substr(z230b->fcltycode,1,3) == '103'   // bong
      agTotals[4] += z230b->rv_amt
	  endif

      z230b->( dbskip() )

      if cStatus != z230b->fcltycode+z230b->status
         if prow() > 58
            _head230b( nPage++, .T. )
         endif
         _prnLine( 127, "-", len(PICT1) )
         _prnTotals( 127, "Status Sub Total :", asTotals )
      endif

      if cFCode != z230b->fcltycode
         if prow() > 58
            _head230b( nPage++, .T. )
         endif
         @ prow()+1,00 say ""
         _prnTotals( 127, "Facility Sub Total :", afTotals )
         _prnLine( 127, "-", len(PICT1) )
      endif

      if z230b->( eof() )
         if prow() > 58
            _head230b( nPage++, .T. )
         endif
         @ prow()+1,00 say ""
         _prnTotals( 127, "Grand Total :", agTotals )
         _prnLine( 127, "=", len(PICT1) )
      endif
   enddo
   __Eject()
return nil

*******************************************************************************
function _Payment( pcBRACCNT, pdDATE, pdLAST, pcPERIOD )
   local aPeriod_ := {}, pperiod
   local xornum, xrefdate, xcode
   local Pay_ := { ;
      "Paymt",;                       // 1
      "Ret. Check",;                  // 2
      "ROPOA",;                       // 3
      "Db_Memo ",;                    // 4
      "Misposting",;                  // 5
      "Terminatx",;                   // 6
      "Cr_Memo  ",;                   // 7
      "REVIEW ",;                     // 8
      " ",;                           // 9
      "O_T Check",;                   //10
      "PDR ",;                        //11
      "LEGAL ",;                      //12
      "LEGAL ",;                      //13
      "Current",;                     //14
      "Current",;                     //15
      "Balance Forwarded" ,;          //16
      "Sold"   }                      // 17   abb 9.10.2001

   pdLAST   := ctod("")
   pcPERIOD := ""
   if amshist->( dbseek(pcBRACCNT) )
      aPeriod_ := {}
      while amshist->brcode+amshist->acctno == pcBRACCNT .and. ! amshist->( eof() )
         if amshist->refdate > pdDATE
            exit
         endif

         xornum    := amshist->ornumber
         xrefdate  := amshist->refdate
         xcode     := amshist->paycode
         while amshist->brcode+amshist->acctno == pcBRACCNT .and. ;
            amshist->ornumber == xornum   .and. ;
            amshist->refdate  == xrefdate .and. ;
            amshist->paycode  == xcode    .and. ;
            ! amshist->( eof() )

            if ! empty(amshist->paydate)
               aAdd( aPeriod_, amshist->paydate )
            endif

            amshist->( dbskip() )
			enddo

         pperiod := ""
         if len(aPeriod_) > 0
            pperiod := dtoc( aPeriod_[1] )
         endif
         if len(aPeriod_) > 1
            pperiod += "-" +dtoc(atail(aPeriod_))
         endif
         pdLAST   := xrefdate
         pcPERIOD := pperiod + "->" + pay_[ val(xCode) ]

         aPeriod_ := {}
      enddo
	endif

   if amshist2->( dbseek(pcBRACCNT) )
      aPeriod_ := {}
      while amshist2->brcode+amshist2->acctno == pcBRACCNT .and. ! amshist2->( eof() )
         if amshist2->refdate > pdDATE
            exit
         endif

         xrefdate  := amshist2->refdate
         xornum    := amshist2->ornumber
         xcode     := amshist2->paycode
         while amshist2->brcode+amshist2->acctno == pcBRACCNT  .and. ;
            amshist2->ornumber == xornum   .and. ;
            amshist2->refdate  == xrefdate .and. ;
            amshist2->paycode  == xcode    .and. ;
            ! amshist2->( eof() )

            if ! empty( amshist2->paydate )
               aAdd( aPeriod_, amshist2->paydate )
            endif

            amshist2->( dbskip() )
			enddo

         pperiod := ""
         if len(aPeriod_) > 0
            pperiod := dtoc( aPeriod_[1] )
         endif
         if len(aPeriod_) > 1
            pperiod += "-" +dtoc(atail(aPeriod_))
         endif
         pdLAST   := xrefdate
         pcPERIOD := pperiod + "->" + pay_[ val(xCode) ]

         aPeriod_ := {}
      enddo
   endif
return Nil

*******************************************************************************
static function _head230b( nPage, lEject )
   if lEject
      __Eject()
   endif
   setPrc( 0,0 )  // draft + 20cpi
   @ prow()+1,01 say "x"+chr(0) + "!" + "Page : "+ str(nPage)
   if nSold == 1
      @ prow ()+1,01 say "Schedule of Receivables - BSP as of " + dtoc( sDate )
	else
      @ prow ()+1,01 say "Schedule of SOLD Receivables - BSP as of " + dtoc( sDate )
	endif
   @ prow()+1,01 say "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
   @ prow()+1,01 say "  Account            Account                        Execution  Maturity   Term       Items for Leases /                                      Net        Outstanding                UDI           Residual Date of Last Period Paid"
   @ prow()+1,01 say "  Number             Name                           Date       Date                  Collaterals for Loans                              Proceeds            Balance               ALIR              Value      Payment            "
   @ prow()+1,01 say "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
                   * 0123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-
                   *  999-9999-99999-99999 XXXXXXXXX-XXXXXXXXX-XXXXXXXXX- 99/99/9999 99/99/9999 999 XXXXXX XXXXXXXXX-XXXXXXXXX-XXXXXXXXX-XXXXXXXXX- 999,999,999,999.99 999,999,999,999.99 999,999,999,999.99 999,999,999,999.99   99/99/9999  XXXXXXXXX-
return nil

*******************************************************************************
static function _prnTotals( nCol, cSay, aTotals )
   @ prow()+1,nCol-len(cSay)-1 say cSay
   @ prow()+0,pcol()+1 say aTotals[1] pict PICT1
   @ prow()+0,pcol()+1 say aTotals[2] pict PICT1
   @ prow()+0,pcol()+1 say aTotals[3] pict PICT1
   @ prow()+0,pcol()+1 say aTotals[4] pict PICT1
return nil

*******************************************************************************
static function _prnLine( nCol, cChar, nLen )
   @ prow()+1,nCol     say repl( cChar, nLen )
   @ prow()+0,pcol()+1 say repl( cChar, nLen )
   @ prow()+0,pcol()+1 say repl( cChar, nLen )
   @ prow()+0,pcol()+1 say repl( cChar, nLen )
return nil
