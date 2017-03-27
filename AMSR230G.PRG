*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
*³ Orix Metro Leasing and Finance                                            ³Û
*³ Account Management System                                                 ³Û
*ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Û
*³ Program ID...: AMSR230G.PRG                                               ³Û
*³ Description..: Schedule of Receivables (non-BSP report)                   ³Û
*³ Author...... : Ariel B. Bulan                                             ³Û
*³ Date.........: 15-Nov-2002   02:46:53pm                                   ³Û
*ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Û
*³                        U P D A T E S                                      ³Û
*ÃÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Û
*³  Who  ³ When        ³ Why                                                 ³Û
*ÃÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Û
*³       ³ 15-Nov-2002 ³  exclude sold receivables                          ³Û
*³       ³             ³  and menu for sold & not sold receivables          ³Û
*³       ³ 30-Jan-2003 ³  insert collateral, replace udi/alir with balance  ³Û
*³       ³ 29-Dec-2006 ³  added AMSHIST2, added effective rate              ³Û
*³ RMS   ³ 14-Jun-2011 ³  Get true value of status based on date            ³Û
*³       ³             ³  Update CPS module                                 ³Û
*ÀÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙÛ
*  ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

#include "colf.ch"
#include "inkey.ch"

*
*	 B E F O R E	R U N N I N G	T H I S	R O U T I N E
*
*
*	(1) osbal <= 0 in acctmast MUST be deleted
*  (2) acctmast->(indexkey()) = fcltycode+status+acctno   ( acctfa2.ntx )
*
//aga.14.02.2007.removed paysked reference

#define PICT2 "999,999,999,999.99"
#define PICT3 "999,999,999,999,999.99"
#define PICT4 "999,999"

private psDate, pnSold, nChoice, zTemp
private plRate := .f., pnRate1 := 0, pnRate2 := 0
private aLCR := { 0,0,0,0,0 }
private aFR  := { 0,0,0,0,0 }

begin sequence
   if ! chkpass( "AMSR2200", m->AX_LEVEL, m->g_USER_ID )
      break
   endif

   if ( m->TRUE_BRCH == "001" )
      if ! netUse( "&g_GL_PATH\flag", .f., 5 )
         break
      endif

      if ! netUse( "&g_AMS_PATH\Acctmast",.f., 5 )
         break
      endif
      set index to &g_AMS_PATH\Acctmast
      ** acctmast.ntx - brcode+clntcode

      if ! netUse( "&g_AMS_PATH\Stathist",.f.,5 )
         break
      endif
      set index to &g_AMS_PATH\Stathist
      ** stathist.ntx - brcode+acctno

      if ! netUse("&g_AMS_PATH\canclact",.f.,5)
         break
      endif
      set index to &g_AMS_PATH\canclact
      ** canclact.ntx - brcode+acctno

      if ! netUse( "&g_AMS_PATH\review",.f.,5 )
         break
      endif
      set index to &g_AMS_PATH\review
      ** review.ntx  - brcode+acctno

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

      if ! netUse( "&g_AMS_PATH\Amshist", .f., 10 ) && Account Payment history file
         break
      endif
      ordlistadd( "&g_AMS_PATH\Amshist" )
      ** amshist.ntx - brcode+acctno

      if ! netUse( "&g_AMS_PATH\AMSBACK\Amshist2", .f., 10 ) && Account Payment history file
         break
      endif
      ordlistadd( "&g_AMS_PATH\AMSBACK\Amshist2" ) && set index on acctno
   endif

   if ! netUse( "&g_AMS_PATH\Facility", .f., 10 )
      break
   endif
   ordlistadd ( "&g_AMS_PATH\Fcltycd" )
   
   if ! netUse( "&g_AMS_PATH\Paysked", .f., 10 )
      break
   endif
   ordlistadd ( "&g_AMS_PATH\Paystat" )
   
   ** fcltycd.ntx - fcltycode

   m->zTemp := tempName()
   dbcreate( (m->zTemp), { ;
      { "fcltycode","c",05,00 },;
      { "status"   ,"c",01,00 },;
      { "brcode"   ,"c",03,00 },;
      { "acctno"   ,"c",14,00 },;
      { "acctname" ,"c",50,00 },;
      { "unit"     ,"c",40,00 },;
      { "unit2"    ,"c",40,00 },;
      { "valdate"  ,"d",08,00 },;
      { "matdate"  ,"d",08,00 },;
      { "term"     ,"n",03,00 },;
      { "termunit" ,"c",03,00 },;
      { "amort"    ,"n",15,02 },;
      { "principal","n",12,02 },;
      { "credamt"  ,"n",12,02 },;
      { "balance"  ,"n",14,02 },;
      { "udiamt"  , "n",14,02 },;
      { "rv_amt"   ,"n",14,02 },;
      { "gd_amt"   ,"n",14,02 },;
      { "truerate" ,"n",07,04 },;
      { "remterm"  ,"n",06,00 } 	  } )
   dbUseArea( .T.,, (m->zTemp), "z230g", .F. )
   index on fcltycode+status+brcode+acctno to (m->zTemp)
   Set Index to (m->zTemp)

   psDate  := date()
   plRate  := .f.
   pnRate1 := 0
   pnRate2 := 0
	if _get_sold_choice()
      if get_date( @psDate,10 )
         _comp_menu()
			if confirm("Include Effective Rate?")
            plRate := get_effrate()
            if !plRate
               break
				endif
			endif

			if lastkey() == K_ESC
            break
			endif

         if Get230g( psDate )
            REPCON_OL( "__SKED_PRINT()",,,8,33 )
         endif
		endif
	endif
end sequence
dbCloseall()
tempErase()
__MRelease( "*", .T. )
return

**********************************
static function _get_sold_choice()
   local _cscr := savescreen (,,,),menulist := {}
   pnSold := 1
	@ 15-9,40 clear to 18-9,62
	@ 15-9,40 to 18-9,62
	@ 16-9,41 prompt "All (excluding sold) "
	@ 17-9,41 prompt "Sold Receivables Only"
   menu to pnSold
   restscreen(,,,,_cscr)
return lastkey() != K_ESC

**************************************
static function get_date( mdate, mrow )
	local isOK := .T.
	local mcolor := setcolor(), mcursor:= setcursor(), getlist := {}

	fshadow( mrow, 21, mrow + 2, 51, 2, "gr+/g" )
	setcolor( "w/g, w+/n,,, w+/g" )
	@ mrow + 1, 22 say "As of Date " get mdate when !empty( mdate := getdate( mdate, mrow + 1, 41, "w/gr, gr+/gr,,, n/gr" ) )
	setcursor( 3 )
	read
	if lastkey() == K_ESC
		isOK := .F.
	endif
   setcolor( mcolor )
   setcursor( mcursor )
return isOK

********************************
static function _comp_menu()
	local mscr := savescreen (,,,)
   local menulist, mcolor := setcolor("w/n")

   nChoice := 0
	@ 10,30 clear to 20,50
	@ 10,30 to 20,50 double
	@ 12,33 prompt "FMLC Accounts "
	@ 14,33 prompt "PBC  Accounts "
	@ 16,33 prompt "ORIX Accounts "
	@ 18,33 prompt "ALL  Accounts "
   menu to nChoice
	setcolor(mcolor)
   restscreen( ,,,, mscr )
return nil

*****************************
static function get_effrate()
	local xx := savescreen(,,,)
	local isOK := .T.

	fshadow(11,30,14,51,,,"Effective Rate Range")
	@ 12, 31 say "From : "
	@ 12, 41 say "%"
   @ 12, 37 get pnRate1 pict "999" valid pnRate1 >=0 .and. pnRate1 <= 100
	@ 13, 31 say "To   : "
	@ 13, 41 say "%"
   @ 13, 37 get pnRate2 pict "999" valid pnRate2 >= 0 .and. pnRate2 <= 100 .and. pnRate2 >= pnRate1
	setcursor(3)
	read
	setcursor(0)
	if lastkey() == K_ESC
		isOK := .f.
	endif
	restscreen(,,,,xx)
return isOK

*******************************************************************************
static function Get230g( pDATE )
   local cBrAccnt, lSkip, xStr
   local nOSB, cStatus, tmprate
   local nH, cFile, cText
   local isOK := .F., nremterm := 0

	Desktop(.T.)
   select "z230g" ; __dbZap()

   begin sequence
      if m->TRUE_BRCH == "001"
         @ 8,18 clear to 20,74
         @ 8,18 to 20,74
         acctmast->( dbseek(m->g_PAR_BRCH) )
         while acctmast->brcode == m->g_PAR_BRCH .and. ! acctmast->( eof() )
            if pAbort()
               break
            endif

            scroll( 9,19,19,73,1 )
            @ 19,19 say acctmast->brcode+"-"+acctmast->acctno + " "+left(acctmast->acctname,25)+" "+dtoc(acctmast->valdate) color "w/n"

            if acctmast->valdate > pDATE
               acctmast->( dbSkip() )
               loop
            endif

            // check cancelled status
            cBrAccnt := acctmast->brcode+acctmast->acctno
            if acctmast->status == "0"
               lSkip := .T.
               if canclact->( dbseek(cBrAccnt) ) .and. canclact->date > pDATE
                  lSkip := .F.
               endif
               if lSkip
                  acctmast->( dbskip(1) )
                  loop
               endif
            endif

            // account choice
            if nChoice == 1
               if left(acctmast->acctno, 4) != "9907"
                  acctmast->( dbskip() )
                  loop
               endif
            elseif nChoice == 2
               if left(acctmast->acctno, 4) != "9908"
                  acctmast->( dbskip() )
                  loop
               endif
            endif

            // include sold or sold only
            cStatus := _GetStatus( cBrAccnt, pDATE )
            if pnSold == 1
               if cStatus == "6"
                  acctmast->( dbskip() )
                  loop
               endif
            else // sold recievables only
               if cStatus != "6"
                  acctmast->( dbskip() )
                  loop
               endif
            endif

            tmprate := 0
            if plRate
               tmprate := acctmast->truerate
               if review->( dbseek(cBrAccnt) )
                  tmprate := review->app_tr
                  while ! review->( eof() ) .and. review->brcode+review->acctno == cBrAccnt
                     if review->effdate > psDate
                        exit
                     endif

                     if review->app_tr >= pnRate1 .and. review->app_tr <= pnRate2
                        tmprate := review->app_tr
                     endif
                     review->( dbskip() )
                  enddo
               else
                  if acctmast->truerate < pnRate1 .or. acctmast->truerate > pnRate2
                     acctmast->( dbskip() )
                     loop
                  endif
               endif
            endif

            // skip if balance = 0
            nOSB := Round( _GetOSBal( cBrAccnt, pDATE ), 2 )
            if empty(nOSB)
               acctmast->( dbSkip() )
               loop
            endif
			
			nremterm := 0
			if acctmast->fcltycode == '10405' //Floor Stock Financing
			   if paysked->(dbseek(acctmast->brcode+acctmast->acctno+'D'))
		while paysked->brcode+paysked->acctno == acctmast->brcode+acctmast->acctno .and. ;
				          !paysked->(eof())
				     if paysked->status == 'D'
				        nremterm += 1
				     endif
				  paysked->(dbskip())
				  enddo
	    endif
            else			   
               if acctmast->amort == 0 .or. nOSB <= 0 
                  nremterm := acctmast->term
               else
                  nremterm := round( nOSB / acctmast->amort, 2 )
               endif
			endif

            z230g->( dbappend() )
            z230g->fcltycode := acctmast->fcltycode
            z230g->status    := cStatus
            z230g->brcode    := acctmast->brcode
            z230g->acctno    := acctmast->acctno
            z230g->acctname  := acctmast->acctname
            z230g->valdate   := acctmast->valdate
            z230g->matdate   := acctmast->matdate
            z230g->amort     := acctmast->amort
            z230g->term      := acctmast->term
            z230g->termunit  := acctmast->termunit
            z230g->unit      := acctmast->unit
            z230g->unit2     := acctmast->unit2
            z230g->principal := acctmast->principal
            z230g->credamt   := acctmast->credamt
            z230g->balance   := nOSB
            z230g->udiamt    := _GetUDI( cBrAccnt, pDATE )
            z230g->rv_amt    := (acctmast->principal * acctmast->rv / 100)
            z230g->gd_amt    := (acctmast->principal * acctmast->gd / 100)
			z230g->remterm   := nremterm
            if plRate
               z230g->truerate := tmprate
            endif
            acctmast->( dbskip(+1) )
         enddo
      else
         xStr := chk_par( m->g_PAR_BRCH )  +; // branch
                 chk_par( pnSold )         +;
                 chk_par( pDATE )          +;
                 chk_par( nChoice )        +;
                 iif(plRate, "T~", "F~")   +;
                 chk_par( str(pnRate1,3) ) +;
                 chk_par( str(pnRate2,3) )

         cFile := cps_reqst( xStr, "__SKED_PRINT" )
         if empty(cFile)
            break
         endif

         @ 8,18 clear to 20,74
         @ 8,18 to 20,74
         cFile := CopyFile( cFile )
         nH := fOpen( cFile, 0 )
         fSeek( nH, 0 )
         while .T.
            //cText := fReadStr( nH, 288 )
			cText := ReadLine( nH )
            if cText == ""
               exit
            endif
            cText := rms_Parse( cText, "~" )
            scroll( 9,19,19,73,1 )
            @ 19,19 say cText[03]+"-"+cText[04]+ " "+left(cText[05],40) color "w/n"

            z230g->( dbappend() )
            z230g->fcltycode := cText[01]
            z230g->status    := cText[02]
            z230g->brcode    := cText[03]
            z230g->acctno    := cText[04]
            z230g->acctname  := cText[05]
            z230g->valdate   := ctod( cText[06] )
            z230g->matdate   := ctod( cText[07] )
            z230g->term      := val( cText[08] )
            z230g->termunit  := cText[09]
            z230g->unit      := cText[10]
            z230g->unit2     := cText[11]
            z230g->amort     := val( cText[12] )
            z230g->principal := val( cText[13] )
            z230g->balance   := val( cText[14] )
            z230g->udiamt    := val( cText[15] )
            z230g->gd_amt    := val( cText[16] )
            z230g->rv_amt    := val( cText[17] )
            z230g->truerate  := val( cText[18] )
			z230g->remterm   := val( cText[19] )
         enddo
         CloseFile( nH, cFile )
      endif
      z230g->( dbCommit() )

      if z230g->( reccount() ) < 1
         Error( "No record to print!" )
      else  
         isOK := .T.
      endif
   end sequence
	Desktop(.F.)
return isOK

#define _pnW    136
*******************************************************************************
static function _rptHead( nPage, lNew )
   /*
   10cpi   80 136   - PICA
   12cpi   96 163   - ELITE
   17cpi  137 233   - PICA  + CONDENSED ON
   20cpi  160 272   - ELITE + CONDENSED ON
   */

   if lNew
      __Eject()
   endif
   SetPrc( 0,0 )
   @ prow()+1,001 say "x"+chr(0) + "!"+chr(0) + m->gSYS_NAME
   @ prow()+0,117 say "Page : " + transf( nPage, "9999" )
   @ prow()+1,001 say "AMSR230G-" + m->g_USER_ID
   @ prow()+0,117 say rs_Now()
   @ prow()+1,000 say padc(m->gCOMPANY, _pnW)
   if plRate
      if pnSold == 1
         @ prow()+1,000 say padc( "Schedule of Outstanding Receivables with Effective Rates of "+ ITOS(pnRate1)+"%"+ " To " + ITOS(pnRate2)+"%" , _pnW )
		else
         @ prow()+1,000 say padc( "Schedule of Outstanding SOLD Receivables with Effective Rates of "+ ITOS(pnRate1)+"%"+ " To " + ITOS(pnRate2)+"%", _pnW )
		endif
	else
      if pnSold == 1
         @ prow()+1,000 say padc( "Schedule of Receivables", _pnW )
		else
         @ prow()+1,000 say padc( "Schedule of SOLD Receivables", _pnW )
		endif
	endif
   @ prow()+1,000 say padc( "As of "+ dtoc(psDate), _pnW ) + "!" + if (plRate, "", "")

   @ prow()+1,01 say "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ" + iif(plRate,"ÄÄÄÄÄÄÄÄÄÄÄ","")
   @ prow()+1,01 say "Account Number       Account Name                   Collateral                      Execution Maturity   Term  Remaining        Monthly       Net Proceeds        Outstanding         UDI / ALIR   Guaranty Deposit     Residual Value" + iif(plRate,"  Effective","")
   @ prow()+1,01 say "                                                                                         Date     Date              Term   Rental/Amort                               Balance                                                         " + iif(plRate,"       Rate","")
   @ prow()+1,01 say "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ" + iif(plRate,"ÄÄÄÄÄÄÄÄÄÄÄ","")
                     *123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789- 123456789-
                     *999-9999-99999-99999 XXXXXXXXX-XXXXXXXXX-XXXXXXXXX- XXXXXXXXX-XXXXXXXXX-XXXXXXXXX- 99/99/9999 99/99/9999  999 999 XXXXXX 999,999,999.99 999,999,999,999.99 999,999,999,999.99 999,999,999,999.99 999,999,999,999.99 999,999,999,999.99 999.9999 %
                     *                                                                                                                                        ------------------ ------------------ ------------------ ------------------ ------------------
                     *                                                                                                                     Status Sub Total : 999,999,999,999.99 999,999,999,999.99 999,999,999,999.99 999,999,999,999.99 999,999,999,999.99
                     *                                                                                                                   Facility Sub Total : 999,999,999,999.99 999,999,999,999.99 999,999,999,999.99 999,999,999,999.99 999,999,999,999.99
                     *                                                                                                                          Grand Total : 999,999,999,999.99 999,999,999,999.99 999,999,999,999.99 999,999,999,999.99 999,999,999,999.99
return nil

*******************************************************************************
function __sked_print()
   local asTotals := { 0,0,0,0,0 } // status
   local afTotals := { 0,0,0,0,0 } // facility
   local agTotals := { 0,0,0,0,0 } // grand totals
   local cFCode, cStatus//, nremterm := 0
   local nPage := 1

   InitLPT() // init printer
   z230g->( dbgotop() )
   _rptHead( nPage++, .F. )
   while ! z230g->( eof() )
      if cFCode != z230g->fcltycode
         if prow() > 58
            _rptHead( nPage++, .T. )
         endif
         cFCode := z230g->fcltycode
         afTotals := { 0,0,0,0,0 } // facility totals
         facility->( dbseek(cFCode) )
         @ prow()+1,01 say "Facility : " + facility->fcltycode+"-"+facility->fcltyname
         @ prow()+1,01 say repl("-",50)
      endif

      if cStatus != cFCode + z230g->status
         if prow() > 58
            _rptHead( nPage++, .T. )
         endif
         cstatus  := cFCode + z230g->status
         asTotals := { 0,0,0,0,0 }
         @ prow()+1,01 say "Status : " + _dstatus( z230g->status )
         @ prow()+1,01 say repl("-",20)
      endif

      @ prow()+1,01       say z230g->brcode+z230g->acctno    pict "@r 999-9999-99999-99999"
      @ prow()+0,pcol()+1 say padr( z230g->acctname, 30 )
      @ prow()+0,pcol()+1 say padr( z230g->unit,     30 )
      @ prow()+0,pcol()+1 say z230g->valdate   pict "@d"
      @ prow()+0,pcol()+1 say z230g->matdate   pict "@d"
      @ prow()+0,pcol()+2 say z230g->term      pict "999"
	  
	  @ prow()+0,pcol()+1 say z230g->remterm pict "999"
	  
      //if z230g->amort == 0 .or. z230g->balance <= 0  // abb 11.18.2002
        // @ prow()+0,pcol()+1 say z230g->term    pict "999"
      //else
        // nremterm := round( z230g->balance / z230g->amort, 2 )
         //@ prow()+0,pcol()+1 say nremterm pict "999"
      //endif

      @ prow()+0,pcol()+1 say iif( z230g->termunit != "2","days  ","months" ) pict "@!"
      @ prow()+0,pcol()+1 say z230g->amort     pict "999,999,999.99"
      @ prow()+0,pcol()+1 say z230g->principal pict PICT2
      @ prow()+0,pcol()+1 say z230g->balance   pict PICT2
      @ prow()+0,pcol()+1 say z230g->udiamt    pict PICT2
	  if substr(z230g->fcltycode,1,3) == '103'	// bong
      @ prow()+0,pcol()+1 say z230g->gd_amt    pict PICT2
      @ prow()+0,pcol()+1 say z230g->rv_amt    pict PICT2
	  else
	  gd := 0
	  rv := 0
      @ prow()+0,pcol()+1 say gd    pict PICT2
      @ prow()+0,pcol()+1 say rv    pict PICT2
	  endif
      if plRate
         @ prow()+0,pcol()+1 say z230g->truerate pict "999.9999 %"
      endif

      // status total
      astotals[1] += z230g->principal
      astotals[2] += z230g->balance
      astotals[3] += z230g->udiamt
	  if substr(z230g->fcltycode,1,3) == '103'	// bong
      astotals[4] += z230g->gd_amt
      astotals[5] += z230g->rv_amt
	  endif

      // facility total
      aftotals[1] += z230g->principal
      aftotals[2] += z230g->balance
      aftotals[3] += z230g->udiamt
	  if substr(z230g->fcltycode,1,3) == '103'	// bong
      aftotals[4] += z230g->gd_amt
      aftotals[5] += z230g->rv_amt
	  endif

      // grand total
      agtotals[1] += z230g->principal
      agtotals[2] += z230g->balance
      agtotals[3] += z230g->udiamt
	  if substr(z230g->fcltycode,1,3) == '103'	// bong
      agtotals[4] += z230g->gd_amt
      agtotals[5] += z230g->rv_amt
	  endif

      if left(z230g->fcltycode, 3) == "103" // LCR
         if z230g->status == "1"
            aLCR[1]++
            aLCR[2] += z230g->balance
         elseif z230g->status == "2"
            aLCR[3]++
            aLCR[4] += z230g->balance
         endif
         aLCR[5] += z230g->udiamt
      else
         if z230g->status == "1"
            aFR[1]++
            aFR[2] += z230g->balance
         elseif z230g->status == "2"
            aFR[3]++
            aFR[4] += z230g->balance
         endif
         aFR[5]  += z230g->udiamt
      endif

      z230g->( dbskip() )
      if prow() > 58
        _rptHead( nPage++, .T. )
      endif

      if cStatus != z230g->fcltycode + z230g->status
         if prow() > 58
           _rptHead( nPage++, .T. )
         endif
         _prnLine( 137, "-", len(PICT2) )
         _prnTotals( 137, "Status Sub Total :", asTotals )
         *_prnLine( 137,"-", len(PICT2) )
      endif

      if cFCode != z230g->fcltycode
         if prow() > 58
           _rptHead( nPage++, .T. )
         endif
         @ prow()+1,00 say ""
         _prnTotals( 137, "Facility Sub Total :", afTotals )
         _prnLine( 137, "-", len(PICT2) )
      endif

      if z230g->( eof() )
         if prow() > 58
           _rptHead( nPage++, .T. )
         endif
         @ prow()+1,00 say ""
         _prnTotals( 137, "Grand Total :", agTotals )
         _prnLine( 137, "=", len(PICT2) )
      endif
   enddo
   __Eject()

   *** month end report
   SetPRC(0,0)
   @ prow()+1,00 say "x"+chr(0) + "!"+chr(0)
   @ prow()+1,00 say "Page No. : " + trans( nPage,"99,999")
	@ prow()+1,00 say "Monthly Report"
	@ prow()+1,00 say "Outstanding Balance of Receivables/Loan Portfolio"
   @ prow()+1,00 say "As of " + dtoc( psDate )

	@ prow()+1,00 say "                  No. of Accounts          Outstanding Balance"
	@ prow()+1,00 say "Current  : "
   @ prow()+2,00 say "            LCR  " + space(9) + trans( aLCR[1], PICT4 ) + space(15)+ trans( aLCR[2], PICT2 )
   @ prow()+2,00 say "            FR   " + space(9) + trans( aFR[1] , PICT4 ) + space(15)+ trans( aFR[2] , PICT2 )
	@ prow()+1,00 say "Past Due : "
   @ prow()+2,00 say "            LCR  " + space(9) + trans( aLCR[3], PICT4 ) + space(15)+ trans( aLCR[4], PICT2 )
   @ prow()+2,00 say "            FR   " + space(9) + trans( aFR[3] , PICT4 ) + space(15)+ trans( aFR[4] , PICT2 )
	@ prow()+1,00 say "             --------------------         ------------------------"
   @ prow()+1,00 say "Grand Total :    " + space(9) + trans( aLCR[1]+aLCR[3]+aFR[1]+aFR[3], PICT4 ) + space(11) + trans( aLCR[2]+aLCR[4]+aFR[2]+aFR[4], PICT3 )
	@ prow()+1,00 say "             ====================         ========================"
   @ prow()+1,00 say "UDI  := "+ trans( aFR[5] , PICT2 )
   @ prow()+1,00 say "ALIR := "+ trans( aLCR[5], PICT2 )
   __eject ()
   setfont( "NORMAL" )
return nil

*******************************************************************************
static function _prnTotals( nCol, cSay, aTotals )
   @ prow()+1,nCol-len(cSay)-1 say cSay
   @ prow()+0,pcol()+1 say aTotals[1] pict PICT2
   @ prow()+0,pcol()+1 say aTotals[2] pict PICT2
   @ prow()+0,pcol()+1 say aTotals[3] pict PICT2
   @ prow()+0,pcol()+1 say aTotals[4] pict PICT2
   @ prow()+0,pcol()+1 say aTotals[5] pict PICT2
return nil

*******************************************************************************
static function _prnLine( nCol, cChar, nLen )
   @ prow()+1,nCol     say repl( cChar, nLen )
   @ prow()+0,pcol()+1 say repl( cChar, nLen )
   @ prow()+0,pcol()+1 say repl( cChar, nLen )
   @ prow()+0,pcol()+1 say repl( cChar, nLen )
   @ prow()+0,pcol()+1 say repl( cChar, nLen )
return nil
