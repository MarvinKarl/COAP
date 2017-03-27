*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
*³ Orix Metro Leasing and Finance                                            ³Û
*³ Account Management System                                                 ³Û
*ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Û
*³ Program ID...: AMSR230E.PRG                                               ³Û
*³ Description..: Schedule of receivables (sorted by credrisk)               ³Û
*³ Author...... : Ariel B. Bulan                                             ³Û
*³ Date.........: 21-Jun-2000   11:25:55am                                   ³Û
*ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Û
*³                        U P D A T E S                                      ³Û
*ÃÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Û
*³  Who  ³ When        ³ Why                                                 ³Û
*ÃÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Û
*³  MTS  ³ 29-Dec-2006 ³ added AMSHIST2                                      ³Û
*³  AGA  ³ 14-Feb-2007 ³ removed paysked reference                           ³Û
*ÀÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙÛ
*  ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

#include "colf.ch"
#include "inkey.ch"

#define PICT1 "999,999,999,999.99"

local getlist := {}
local z230e, nChoice, aAccount[3]
private sDate

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


		if ! netUse( "&g_AMS_PATH\Amshist", .f., 10 )
			break
		endif
		ordlistadd( "&g_AMS_PATH\Amshist" )

		if ! netUse( "&g_AMS_PATH\AMSBACK\Amshist2", .f., 10 )
			break
		endif
		ordlistadd( "&g_AMS_PATH\AMSBACK\Amshist2" )

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

      if ! netUse( "&g_GL_PATH\flag", .f., 10 )
			break
		endif

		if ! netUse( "&g_CIS_PATH\Corpinfo.dbf", .f., 10 )
			break
		endif
		ordlistadd ( "&g_CIS_PATH\Corpinfo" )
		*** corpinfo.ntx - brcode+clntcode

		if ! netUse( "&g_CIS_PATH\Indvinfo", .f., 10 )
			break
		endif
		ordlistadd( "&g_CIS_PATH\Indvinfo" )
		*** indvinfo.ntx - brcode+clntcode
	endif

   z230e := tempName()
   dbCreate( (z230e), { ;
		{ "credrisk" ,"c",05,00 },;
		{ "fcltycode","c",05,00 },;
		{ "brcode"   ,"c",03,00 },;
		{ "clntcode" ,"c",07,00 },;
		{ "acctno"   ,"c",14,00 },;
		{ "status"   ,"c",01,00 },;
		{ "acctname" ,"c",50,00 },;
		{ "valdate" , "d",08,00 },;
		{ "matdate"  ,"d",08,00 },;
		{ "term"     ,"n",03,00 },;
      { "termunit", "c",01,00 },;
		{ "unit"     ,"c",40,00 },;
		{ "principal","n",15,02 },;
      { "balance"  ,"n",14,02 },;
		{ "udiamt"  , "n",15,02 },;
		{ "rv_amt"   ,"n",14,02 },;
		{ "lastpaid", "d",08,00 },;
      { "period",   "c",30,00 } } )
   dbUseArea( .T.,, (z230e), "z230e", .F. )
   index on credrisk+fcltycode+brcode+clntcode+acctno to (z230e)
   Set Index to (z230e)

   sDate := m->gTRANDATE
   nChoice := 3
   aAccount[1] := RadioButto( 13,28 ," FMLC ")
   aAccount[2] := RadioButto( 14,28 ," PBC  ")
   aAccount[3] := RadioButto( 15,28 ," ORIX ")
   rmsBox( 10,20,07,30,2,,"w+/rb" )
   while .T.
      setcolor( "w+/rb,w+/b,,,w+/bg")
      @ 11,25 say "Date :" get sDate pict "@D"
      @ 12,25,16,40 get nChoice RADIOGROUP aAccount ;
         CAPTION " Accounts " COLOR "w/rb,w+/rb,r/rb"
      setcursor(1)
      READ
      setcursor(0)
      if lastkey() == 27
         exit
      endif
      if GetData( sDate, nChoice )
         reportprint( "_rpt230e()","132 Column" )
      endif
   enddo
end sequence
dbcloseall()
tempErase()
__MRelease( "*", .T. )

return

*******************************************************************************
static function GetData( pdDATE, pnChoice )
	local cBrAccnt, lSkip, xStr
	local nH, cFile, cText
	local aTemp_[3], dLast, cPeriod
	local isOK := .F.

	Desktop(.T.)
	select "z230e" ; __dbZap()

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

				// status
				aTemp_[1] := _GetStatus( cBrAccnt, pdDATE )
				if aTemp_[1] == "6"
					acctmast->( dbskip() )
					loop
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
            _Payment( cBrAccnt, pdDate, @dLast, @cPeriod )

				z230e->( dbappend() )
            z230e->credrisk  := __CredRisk( acctmast->brcode+acctmast->clntcode )
				z230e->fcltycode := acctmast->fcltycode
				z230e->brcode    := acctmast->brcode
            z230e->clntcode  := acctmast->clntcode
				z230e->acctno    := acctmast->acctno
				z230e->acctname  := acctmast->acctname
				z230e->valdate   := acctmast->valdate
				z230e->matdate   := acctmast->matdate
				z230e->term      := acctmast->term
            z230e->termunit  := iif( acctmast->termunit != "2", "D", "M" )
				z230e->unit      := acctmast->unit
            z230e->status    := aTemp_[1]
				z230e->principal := acctmast->principal
				z230e->balance   := aTemp_[2]
				z230e->udiamt    := aTemp_[3]
				z230e->rv_amt    := (acctmast->principal * acctmast->rv / 100)
				z230e->lastpaid  := dLast
				z230e->period    := cPeriod
				acctmast->( dbskip() )
			enddo
		else
			xStr := chk_par( m->g_PAR_BRCH )  +;    // branch
				chk_par( pdDATE )              +;
            chk_par( pnChoice )

         cFile := do_cps( xStr, "_SKED_PRNCREDIT" )
			if empty(cFile)
				break
			endif
         cFile := CopyFile( cFile )

         rmsBox( 05,10,15,60,1,"Gathering data. please wait...","n/w,w+/r" )
         setColor("g/n")
			nH := fOpen( cFile, 0 )
			fSeek( nH, 0 )
			while .T.
            cText := fReadStr( nH, 267 )
				if cText == ""
					exit
				endif
				cText := rms_Parse( cText, "~" )
            scroll( 07,11,19,69,1 )
            @ 19,11 say cText[03]+"-"+cText[05]+ " "+left(cText[06],29)+" "+cText[07]

				z230e->( dbappend() )
            z230e->credrisk  := cText[01]
            z230e->fcltycode := cText[02]
				z230e->brcode    := cText[03]
            z230e->clntcode  := cText[04]
            z230e->acctno    := cText[05]
            z230e->acctname  := cText[06]
            z230e->valdate   := ctod( cText[07] )
            z230e->matdate   := ctod( cText[08] )
            z230e->term      := val( cText[09] )
            z230e->termunit  := cText[10]
            z230e->unit      := cText[11]
            z230e->status    := cText[12]
            z230e->principal := val( cText[13] )
            z230e->balance   := val( cText[14] )
            z230e->udiamt    := val( cText[15] )
            z230e->rv_amt    := val( cText[16] )
            z230e->lastpaid  := ctod( cText[17] )
            z230e->period    := cText[18]
			enddo
			CloseFile( nH, cFile )
		endif
		if z230e->( dbcommit(), reccount() ) == 0
			Error( "No record to print." )
			break
		endif

		isOK := .T.
	end sequence
	Desktop(.F.)
return isOK

*******************************************************************************
function _rpt230e()
   local nPage := 1
   local cRisk, cFCode
   local arTotals, afTotals, agTotals := { 0,0,0,0 }

   InitLPT()
   _head230e( nPage++, .F.)
	z230e->( dbgotop() )
   while ! z230e->( eof() )
      if cRisk != z230e->credrisk
         if prow() > 58
			eject
            _head230e( nPage++, .T. )
         endif
         cRisk := z230e->credrisk
         arTotals := { 0,0,0,0 }
         @ prow()+1,01 say "Credit Risk : " + _disp_credrisk( cRisk )
         @ prow()+1,01 say repl("-",50)
      endif

      if cFCode != cRisk + z230e->fcltycode
         if prow() > 58
			eject
            _head230e( nPage++, .T. )
         endif
         cFCode := cRisk + z230e->fcltycode
         afTotals := { 0,0,0,0 }
         @ prow()+1, 01 say if( left(z230e->fcltycode, 3) == "103","Lease","Loans" )
         @ prow()+1, 01 say repl("-",50)
      endif

      if prow() > 58
			eject
         _head230e( nPage++, .T. )
      endif

      @ prow()+1,01       say z230e->brcode+z230e->acctno     pict "@R 999-9999-99999-99999"
      @ prow()+0,pcol()+1 say padr( z230e->acctname,30 )
      @ prow()+0,pcol()+1 say z230e->valdate    pict "@D"
      @ prow()+0,pcol()+1 say z230e->matdate    pict "@D"
      @ prow()+0,pcol()+1 say z230e->term       pict "999"
      @ prow()+0,pcol()+1 say z230e->termunit
      @ prow()+0,pcol()+1 say z230e->unit
      @ prow()+0,pcol()+1 say z230e->principal  pict PICT1
      @ prow()+0,pcol()+1 say z230e->balance    pict PICT1
      @ prow()+0,pcol()+1 say z230e->udiamt     pict PICT1
	  if substr(z230e->fcltycode,1,3) == '103'	// bong
      @ prow()+0,pcol()+1 say z230e->rv_amt     pict PICT1
	  else
	  rv := 0
	  @ prow()+0,pcol()+1 say rv     pict PICT1
	  endif
      @ prow()+0,pcol()+1 say z230e->lastpaid   pict "@D"
      @ prow()+0,pcol()+1 say z230e->period     pict "@!"

      afTotals[1] += z230e->principal
      afTotals[2] += z230e->balance
      afTotals[3] += z230e->udiamt
	  if substr(z230e->fcltycode,1,3) == '103'	// bong
      afTotals[4] += z230e->rv_amt
	  endif

      arTotals[1] += z230e->principal
      arTotals[2] += z230e->balance
      arTotals[3] += z230e->udiamt
	  if substr(z230e->fcltycode,1,3) == '103'	// bong
      arTotals[4] += z230e->rv_amt
	  endif

      agTotals[1] += z230e->principal
      agTotals[2] += z230e->balance
      agTotals[3] += z230e->udiamt
	  if substr(z230e->fcltycode,1,3) == '103'	// bong
      agTotals[4] += z230e->rv_amt
	  endif

      z230e->( dbskip() )

      if cFCode != z230e->credrisk + z230e->fcltycode
         if prow() > 58
			eject
            _head230e( nPage++, .T. )
         endif
         _prnLine( 122, "-", len(PICT1) )
         _prnTotals( 122, "Lease/Loan Sub Total :", afTotals )
      endif

      if cRisk != z230e->credrisk
         if prow() > 58
			eject
            _head230e( nPage++, .T. )
         endif
         @ prow()+1,00 say ""
         _prnTotals( 122, "Credit Risk Sub Total :", arTotals )
         _prnLine( 122, "-", len(PICT1) )
      endif

      if z230e->( eof() )
         if prow() > 58
			eject
            _head230e( nPage++, .T. )
         endif
         @ prow()+1,00 say ""
         _prnTotals( 122, "Grand Total :", agTotals )
         _prnLine( 122, "=", len(PICT1) )
      endif
   enddo
return nil

*******************************************************************************
static function _head230e( nPage, lEject )
   setprc( 0,0 )
   @ prow()+1,01 say "x"+chr(0) + "!" + "Page : "+ str(nPage)
   @ prow()+1,01 say "Schedule of Receivables as of " + dtoc( sDate )
   @ prow()+1,01 say "-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
   @ prow()+1,01 say "  Account            Account                        Execution  Maturity   Term  Items for Leases /                       Net                Outstanding        UDI                Residual           Date of Last Period Paid                    "
   @ prow()+1,01 say "  Number             Name                           Date       Date             Collaterals for Loans                    Proceeds           Balance            ALIR               Value              Payment                                     "
   @ prow()+1,01 say "-------------------- ------------------------------ ---------- ---------- ----- ---------------------------------------- ------------------ ------------------ ------------------ ------------------ ------------ -------------------------------"
                   * 0123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789
                   *  999-9999-99999-99999 XXXXXXXXX-XXXXXXXXX-XXXXXXXXX- 99/99/9999 99/99/9999 999 X XXXXXXXXX-XXXXXXXXX-XXXXXXXXX-XXXXXXXXX- 999,999,999,999.99 999,999,999,999.99 999,999,999,999.99 999,999,999,999.99 99/99/9999    XXXXXXXXX-XXXXXXXXX-XXXXXXXXX-
return nil

*******************************************************************************
static function __CredRisk( pcCODE )
   local Result := space(5)

	if corpinfo->( dbseek(pcCODE) )
		Result := corpinfo->credrisk
	else
		if indvinfo->( dbseek(pcCODE) )
			Result := indvinfo->credrisk
		endif
	endif
return Result

********************************************
static function _disp_credrisk( ccredrisk )
	local Result,mrisk
	local mcred := {"CURRENT","WATCHLIST / AEM","SUBSTANDARD","DOUBTFUL","LOSS"}

	mrisk := alltrim ( ccredrisk )

	do case
		case mrisk == "I"
			Result := mrisk + " " +  mcred [1]
		case mrisk == "II"
			Result := mrisk + " " +  mcred [2]
		case mrisk == "III"
			Result := mrisk + " " +  mcred [3]
		case mrisk == "IV"
			Result := mrisk + " " +  mcred [4]
		case mrisk == "V"
			Result := mrisk + " " +  mcred [5]
		otherwise
			Result := mrisk + " " +  "INVALID CREDIT RISK"
	endcase

return  Result

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
