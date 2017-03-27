*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
*³ Orix Metro Leasing and Finance                                            ³Û
*³ Account Management System                                                 ³Û
*ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Û
*³ Program ID...: AMSM5000.PRG                                               ³Û
*³ Description..: Insurance Policy Maintenance                               ³Û
*³ Author...... : Renan S. Evangelista                                       ³Û
*³ Date.........: 21-Jun-1996   08:41:24am                                   ³Û
*ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Û
*³                        U P D A T E S                                      ³Û
*ÃÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Û
*³  Who  ³ When        ³ Why                                                 ³Û
*ÃÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Û
*³  RED  ³ 01-Oct-2004 ³ Change format of acct # in picklist                 ³Û
*³       ³             ³ from 5 digit format to 14 digits                    ³Û
*³       ³             ³ and index from acctsub2 to acctmast                 ³Û
*³  RMS  ³ 07-Jan-2011 ³ CPS                                                 ³Û
*ÀÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙÛ
*  ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

#include "inkey.ch"
#include "colf.ch"
#include "rms.ch"


private xAcct, zTemp1, zTemp2
private xCust, ztemp
private mClient, mCName, mAcctno, mOldNo, mUnit, mUnit2
private mValDate, mPrincip, mMatDate, mBalance, mAOcode, mStatus

if chkpass( procname(), m->AX_LEVEL, m->gUSER_ID )
   if openData()
      fikey5000()
   endif
	dbCloseAll()
   r_erase( (zTemp1) )
   r_erase( (zTemp2) )
   r_erase( (xAcct) )
   r_erase( (xCust) )
   r_erase( (ztemp) )
endif
tempErase()
__MRelease("*", .T.)
return nil

*******************************************************************************
static function openData()
   local lRet := .F.

	begin sequence
      zHist := tempName()
      dbcreate( zHist, { ;
			{ "recnum",  "n", 09, 0 },;
			{ "brcode",  "c", 03, 0 },;
         { "acctno",  "c", 14, 0 },;
         { "insured", "l", 01, 0 },;
         { "insby",   "c", 02, 0 },;
         { "insprem", "n", 12, 2 },;
         { "amtins",  "n", 12, 2 },;
         { "insdate", "d", 08, 0 },;
         { "insexpry","d", 08, 0 },;
			{ "inscover","c", 02, 0 },;
			{ "inspolcy","c", 20, 0 },;
         { "insor",   "c", 08, 0 },;
         { "userid",  "c", 06, 0 },;
         { "update",  "d", 08, 0 } } )
      OpenTMP( (zHist), "zHist", .F. )
      dbSelectArea( "zHist" )
      index on dtos(field->update) to (zHist) desc
      *ordCondSet(,,,,,, RECNO(),,,,.T. ) ; ordCreate( (m->zHist),, "dtos(update)", {|| dtos(field->update)}, )
      Set Index to (zHist)

      m->zTemp1 := r_tempfile( m->pTemp )
      dbcreate( m->zTemp1, { ;
			{"brcode",   "c", 03, 0 },;
         {"clntcode", "c", 07, 0 },;
			{"acctno",   "c", 14, 0 },;
         {"oldno",    "c", 20, 0 },;
         {"unit",     "c", 40, 0 },;
         {"unit2",    "c", 40, 0 },;
         {"valdate",  "c", 10, 0 },;
         {"principal","c", 14, 0 },;
         {"matdate",  "c", 10, 0 },;
         {"osbal",    "c", 14, 0 },;
         {"aocode",   "c", 05, 0 },;
         {"status",   "c", 01, 0 } })
      OpenTMP( (zTemp1), "temp1", .F. )

      zTemp2 := r_tempfile( m->pTemp )
      dbcreate( zTemp2, { ;
			{ "recnum",  "n", 09, 0 },;
			{ "brcode",  "c", 03, 0 },;
         { "insured", "l", 01, 0 },;
         { "plateno", "c", 15, 0 },;
			{ "motorno", "c", 25, 0 },;
			{ "serialno","c", 20, 0 },;
			{ "insby",   "c", 02, 0 },;
			{ "insco",   "c", 04, 0 },;
			{ "insprem", "c", 12, 0 },;
			{ "amtins",  "c", 12, 0 },;
			{ "insdate", "c", 10, 0 },;
			{ "insexpry","c", 10, 0 },;
			{ "inscover","c", 02, 0 },;
			{ "inspolcy","c", 20, 0 },;
			{ "insor",   "c", 08, 0 } } )
      OpenTMP( (zTemp2), "temp2", .F. )

		m->xAcct := r_tempfile( m->pTemp )
		dbcreate( m->xAcct, { ;
			{"brcode",   "c", 03, 0 },;
         {"clntcode", "c", 07, 0 },;
			{"acctno",   "c", 14, 0 },;
			{"status",   "c", 01, 0 },;
			{"oldno",    "c", 20, 0 },;
			{"docref",   "c", 03, 0 },;
			{"refno",    "c", 09, 0 } })
		OpenTMP( (xAcct), "acct", .F. )
		dbSelectArea( "acct" )
      dbCreateIndex( (xAcct), "r_decrypt(brcode+acctno)", {|| r_decrypt(brcode+acctno)}, .F. )
		Set Index to (xAcct)

      ztemp := r_tempfile()
      dbcreate( ztemp, {;
         { "brcode",  "c",03,0 },;
         { "clntcode","c",07,0 },;
         { "acctno",  "c",14,0 },;
         { "motorno", "c",25,0 },;
         { "serialno","c",20,0 },;
         { "plateno", "c",15,0 }})
      OpenTMP( (ztemp), "ztemp", .F.)
      dbSelectArea( "ztemp" )
      dbCreateIndex( (ztemp), "brcode+acctno", {|| brcode+acctno }, .F. )
      Set Index to (ztemp)

      if (m->TRUE_BRCH == "001")
         if ! open_if( "acctmast" )
            break
         endif
         **ordsetfocus( "acctclnt" )

         if !NetUse( "&g_AMS_PATH\Ctrlinfo", .f., 10 ) && Insurance information file
            break
         endif
         Set_Index( m->g_AMS_PATH, { "Ctrlinfo" } ) // brcode+acctno

         if !NetUse( "&g_AMS_PATH\Coverage", .f., 10 ) && Insurance Coverage file
            break
         endif
         Set_Index( m->g_AMS_PATH, { "Coverage" } ) && set index on covercode

         if !NetUse( "&g_AMS_PATH\Inslog", .f., 10 )&& Insurance Login file
            break
         endif
         Set_Index( m->g_AMS_PATH, { "Inslog" } )
         ** inslog.ntx  - brcode+acctno

         if !NetUse("&g_CIS_PATH\INSURANC",.f.,5)   && Insurance file
            break
         endif
         Set_Index( m->g_CIS_PATH, { "INSCODE", "INSNAME" } ) && set index on ornumber

         if ! open_if( "client" )
            break
         endif
         ordsetfocus("cliecd")
      else // CPS Here
         if ! cust_temp( m->pTemp )
            break
         endif

         if ! temp_insu()
            break
         endif

         if ! temp_cover()
            break
         endif
      endif

      lRet := .T.
	end sequence
return lRet

*******************************************************************************
static function temp_insu()
   local zInsu := tempName()

   DBCreate( zInsu, { ;
      {"brcode",  "c", 03, 0 },;
      {"inscode", "c", 04, 0 },;
      {"insname", "c", 40, 0 },;
      {"catcode", "c", 02, 0 } })
   OpenTMP( (zInsu), "insuranc", .F. )
   DBSelectArea( "insuranc" )
   index on field->brcode+field->inscode to (zInsu)+".nt1"
   index on field->insname               to (zInsu)+".nt2"
   ordlistclear()
   ordlistadd( (zInsu)+".nt1" )
   ordlistadd( (zInsu)+".nt2" )
   ordsetfocus(1)

return CPS_Exec( m->g_PAR_BRCH, "GET_INSCOMP", "insuranc", 55 )

*******************************************************************************
static function temp_cover()
   local zCover := tempName()

   DBCreate( zCover, { ;
      {"covercode", "c", 02, 0 },;
      {"coverdesc", "c", 30, 0 } })
   OpenTMP( (zCover), "coverage", .F. )
   index on field->covercode to (zCover)
   Set Index to (zCover)

return CPS_Exec( chk_par(m->g_PAR_BRCH), "GET_COVER", "coverage", 36 )

*******************************************************************************
static function fikey5000()
   local n, tbcol_ := { ;
      tbcolumnnew( padr("Plate No.", 15), { || tran( r_decrypt(temp2->plateno),  "@!" ) } ),;
      tbcolumnnew( padr("Motor No.", 25), { || tran( r_decrypt(temp2->motorno),  "@!" ) } ),;
      tbcolumnnew( padr("Serial No.",20), { || tran( r_decrypt(temp2->serialno), "@!" ) } ),;
      tbcolumnnew( padr("Ins Thru",  10), { || tran( disp_insu(r_decrypt(temp2->insby)), "@!"  ) } ),;
      tbcolumnnew( padr("Company",   30), { || tran( disp_comp(r_decrypt(temp2->brcode), r_decrypt(temp2->insco)), "@!" ) } ),;
      tbcolumnnew( padr("Premium",   15), { || tran( val(r_decrypt(temp2->insprem)), "999,999,999.99" ) } ),;
      tbcolumnnew( padr("Amount Insured", 15), { || tran(val(r_decrypt(temp2->amtins)), "999,999,999.99" ) } ),;
      tbcolumnnew( padr("Date Insured", 12), { || tran(r_decrypt(temp2->insdate), "@D") } ),;
      tbcolumnnew( padr("Expiry Date", 12),  { || tran(r_decrypt(temp2->insexpry),"@D") } ),;
      tbcolumnnew( padr("Type of Coverage",20), { || tran(disp_cover(r_decrypt(temp2->inscover)), "@!" ) } ),;
      tbcolumnnew( padr("Policy Number", 20), { || tran(r_decrypt(temp2->inspolcy), "@!") } ),;
      tbcolumnnew( padr("OR N§",10), { || tran(r_decrypt(temp2->insor), "@!" ) } ) }

   begin sequence
      scrntitle( "Insurance Policies Maintenance", m->gSYS_NAME, m->gUSER_ID, m->gTRANDATE )
		spBox( 03,00,12,79,"w/n")
		********** 0123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789
		setcolor("w/n")
      dispoutat( 04, 05, "         Client ¯"     )
      dispoutat( 05, 05, " Account Number ¯"     )
      dispoutat( 05, 40, "       LA No. ¯"       )
      dispoutat( 06, 05, "           Unit ¯"     )
      dispoutat( 07, 05, "                ¯"     )
      dispoutat( 09, 05, " Execution Date ¯"     )
      dispoutat( 09, 40, "       Net Proceeds ¯" )
      dispoutat( 10, 05, "  Maturity Date ¯"     )
      dispoutat( 10, 40, "Outstanding Balance ¯" )
      dispoutat( 11, 05, "Account Officer ¯"     )
      dispoutat( 11, 40, "     Account Status ¯" )

      select "temp2"
		oTB := TBrowNew( 13,01,22,78,"w/n,w+/bg","ÍÑÍ"," ³ ","ÄÁÄ" )
		for n := 1 to len( tbcol_ )
			oTB:addcolumn( tbcol_[n] )
		next
      StatLine( " ~Tab~-Details  ~F4~-Search  ~F5~-View History Log  ~Esc~-Exit " )
      spChar( 04,00,12,21, "w+/w,w/n", "Û°" )
		while .T.
         ShowData(.F.)
			nKey := inkeytrap(0)
			do case
				case nKey == K_ESC ; exit
				case nKey == K_F4
               if chkpass( "S", m->AX_LEVEL, m->gUSER_ID )
                  Find_Policy()
               endif
         case nKey == K_F5
            if chkpass( "S", m->AX_LEVEL, m->gUSER_ID )
               InsLog_Hist()
            endif
            case nKey == K_TAB ; fVouc5000()
			endcase
		enddo
   end sequence
return nil

*******************************************************************************
static function Find_Policy()
   local nRec := temp1->( recno() )
   local nChoice, lRet := .F.
   local aMenu := { "By &Account Number", "By &Motor/Serial No" }

	begin sequence
      if (nChoice := VPopup( aMenu,1,,05,15 ) ) > 0
         if Get_Account( @mAcctno, nChoice )
            nRec := FillTemp( mAcctno )
            lRet := .T.
         endif
      endif
	end sequence
   temp1->( dbgoto(nRec) )
return lRet

*******************************************************************************
static function FillTemp( mAccount )
   local nRec, nH, cFile, cText, cCode

   if (m->TRUE_BRCH == "001")
      dbSelectArea("temp1") ; __dbZap()

      MySeek( mAccount ALIAS "acctmast" order 2 )
      temp1->( DBAppend() )
      temp1->brcode    := r_encrypt(acctmast->brcode)
      temp1->clntcode  := r_encrypt(acctmast->clntcode)
      temp1->acctno    := r_encrypt(acctmast->acctno)
      temp1->oldno     := r_encrypt(acctmast->oldno)
      temp1->unit      := r_encrypt(acctmast->unit)
      temp1->unit2     := r_encrypt(acctmast->unit2)
      temp1->valdate   := r_encrypt(dtoc(acctmast->valdate))
      temp1->principal := r_encrypt(str(acctmast->principal, 12, 2))
      temp1->matdate   := r_encrypt(dtoc(acctmast->matdate))
      temp1->osbal     := r_encrypt(str(acctmast->osbal, 12, 2))
      temp1->aocode    := r_encrypt(acctmast->aocode)
      temp1->status    := r_encrypt(acctmast->status)
      nRec := temp1->( DBCommit(), recno() )

      dbSelectArea("temp2") ; __dbZap()
      MySeek( mAcctno alias "ctrlinfo" )
      while ! ctrlinfo->( eof() ) .and. ctrlinfo->brcode+ctrlinfo->acctno == mAcctno
         temp2->( DBAppend() )
         temp2->recnum   := ctrlinfo->( recno() )
         temp2->brcode   := r_encrypt(ctrlinfo->brcode)
         temp2->insured  := ctrlinfo->insured
         temp2->plateno  := r_encrypt(ctrlinfo->plateno)
         temp2->motorno  := r_encrypt(ctrlinfo->motorno)
         temp2->serialno := r_encrypt(ctrlinfo->serialno)
         temp2->insby    := r_encrypt(ctrlinfo->insby)
         temp2->insco    := r_encrypt(ctrlinfo->insco)
         temp2->insprem  := r_encrypt(str(ctrlinfo->insprem,12,2))
         temp2->amtins   := r_encrypt(str(ctrlinfo->amtins,12,2))
         temp2->insdate  := r_encrypt(dtoc(ctrlinfo->insdate))
         temp2->insexpry := r_encrypt(dtoc(ctrlinfo->insexpry))
         temp2->inscover := r_encrypt(ctrlinfo->inscover)
         temp2->inspolcy := r_encrypt(ctrlinfo->inspolcy)
         temp2->insor    := r_encrypt(ctrlinfo->insor)
         ctrlinfo->( DBSkip() )
      enddo
      temp2->( DBCommit() )
   else
      cFile := do_cps( mAccount, "INSU_DATA" )
      cFile := CopyFile( cFile )
      nH := FOpen( cFile, 0 )
      FSeek(nH, 0)
      cText := FReadStr(nH, 188)
      cText := rms_Parse( cText, "~" )
      dbSelectArea("temp1") ; __dbZap()

      temp1->( DBAppend() )
      temp1->brcode    := r_encrypt(cText[1])
      temp1->clntcode  := r_encrypt(cText[2])
      temp1->acctno    := r_encrypt(cText[3])
      temp1->oldno     := r_encrypt(cText[4])
      temp1->unit      := r_encrypt(cText[5])
      temp1->unit2     := r_encrypt(cText[6])
      temp1->valdate   := r_encrypt(cText[7])
      temp1->principal := r_encrypt(cText[8])
      temp1->matdate   := r_encrypt(cText[9])
      temp1->osbal     := r_encrypt(cText[10])
      temp1->aocode    := r_encrypt(cText[11])
      temp1->status    := r_encrypt(cText[12])
      nRec := temp1->( DBCommit(), recno() )

      dbSelectArea("temp2") ; __dbZap()
      while .T.
         cText := FReadStr(nH, 170)
         if cText == ""
            exit
         endif
         cText := rms_Parse( cText, "~" )
         temp2->( DBAppend() )
         temp2->recnum   := val(alltrim(cText[1]))
         temp2->brcode   := r_encrypt(cText[2])
         temp2->insured  := iif(cText[3]=="T", .T., .F.)
         temp2->plateno  := r_encrypt(cText[4])
         temp2->motorno  := r_encrypt(cText[5])
         temp2->serialno := r_encrypt(cText[6])
         temp2->insby    := r_encrypt(cText[7])
         temp2->insco    := r_encrypt(cText[8])
         temp2->insprem  := r_encrypt(cText[9])
         temp2->amtins   := r_encrypt(cText[10])
         temp2->insdate  := r_encrypt(cText[11])
         temp2->insexpry := r_encrypt(cText[12])
         temp2->inscover := r_encrypt(cText[13])
         temp2->inspolcy := r_encrypt(cText[14])
         temp2->insor    := r_encrypt(cText[15])
      enddo
      temp2->( DBCommit() )
      CloseFile(nH, cFile)
   endif
return nRec

*******************************************************************************
static function disp_insu( cInsu, lDisp )
   local aList := space(6)+"Client"+"COLF  "+"Dealer"
   local cResult := ""

	setif(@lDisp, .T.)
	if lDisp
		cResult := cInsu + " "
   endif
	cResult += substr(aList, val(cInsu) * 6 + 1, 6)
return cResult

*******************************************************************************
static function disp_comp( cCode, cComp )
   local Result := space(30)

   if MySeek( cCode+cComp ALIAS "insuranc" ORDER 1 RESTORD )
      Result := insuranc->insname
   endif
return cComp + "-" + left(Result, 30)

*******************************************************************************
static function disp_cover( pCODE )
   MySeek( pCODE ALIAS "coverage" RESTORD )
   *Result := coverage->coverdesc
return LEFT(coverage->coverdesc, 30)

*******************************************************************************
static function ShowData( isNew )
   dispbegin()
   GetData( isNew )
	SetColor( "w+/n" )
   dispText( 04, 23, mClient,, "@R 999-99-99999" )
   dispText( 04, 38, left(mCName,40) )
   dispText( 05, 23, mAcctno,, "@R 999-9999-99999-99999" )
   dispText( 05, 56, mOldNo,, "@!" )
   dispText( 06, 23, mUnit,, "@!" )
   dispText( 07, 23, mUnit2,, "@!" )
	dispText( 09, 23, mValDate,, "@D" )
	dispText( 09, 62, mPrincip,, "999,999,999.99" )
	dispText( 10, 23, mMatDate,, "@D" )
	dispText( 10, 62, mBalance,, "999,999,999.99" )
	dispText( 11, 23, mAOcode,, "@!" )
   dispText( 11, 62, mStatus+" "+accnt_stat(mStatus),, "@!" )

   select "temp2"
   temp2->( dbgotop() )
	oTB:autolite := .f.
	oTB:refreshall():forcestable()
	dispend()
return nil

*******************************************************************************
static function GetData( isNew )
	if isNew
      temp1->( dbgoto(0) )
   endif

   mClient  := r_decrypt(temp1->brcode+temp1->clntcode) // branch+client
   MySeek( mClient ALIAS "client" )
   mCName   := r_decrypt(client->fullname)

   mAcctNo  := r_decrypt(temp1->brcode+temp1->acctno) // branch+account
   mOldNo   := r_decrypt(temp1->oldno)
   mUnit    := r_decrypt(temp1->unit)
   mUnit2   := r_decrypt(temp1->unit2)
   mValdate := ctod(r_decrypt(temp1->valdate))
   mPrincip := val(r_decrypt(temp1->principal))
   mMatdate := ctod(r_decrypt(temp1->matdate))
   mBalance := val(r_decrypt(temp1->osbal))
   mAOcode  := r_decrypt(temp1->aocode)
   mStatus  := r_decrypt(temp1->status)

   if isNew .or. empty(mAcctno)
      select "temp2" ; __dbzap()
   endif

   temp2->( dbgotop() )
return nil

*******************************************************************************
static function Get_Account( mAccnt, nChoice )
	local lRet := .F.

	if Get_Client( @mClient, @mCName ) > 0
      if (nChoice == 1)
         lRet := v_account( @mAccnt, mClient )
      else
         lRet := v_motor( @mAccnt, mClient )
      endif
	endif
return lRet

*******************************************************************************
static function v_account( mAccnt, mClient )
	local cFile, nH, cKey, cText, xAcc
   local mar, nPos := 0, mlog := {}, lRet := .F.

	__Keyboard()
   if (m->TRUE_BRCH == "001")
		dbSelectArea( "acct" ) ; __dbZap()
		xAcc := "acctmast"
      MySeek( mClient alias "acctmast" order 1 )
		while ! (xAcc)->( eof() ) .and. (xAcc)->brcode+(xAcc)->clntcode == mClient
         acct->( DBAppend() )
			acct->brcode   := r_encrypt( (xAcc)->brcode )
			acct->clntcode := r_encrypt( (xAcc)->clntcode )
			acct->acctno   := r_encrypt( (xAcc)->acctno )
			acct->status   := r_encrypt( (xAcc)->status )
			acct->oldno    := r_encrypt( (xAcc)->oldno )
			acct->docref   := r_encrypt( iif( (xAcc)->docref == "1", "CA ", "OT " ) )
			acct->refno    := r_encrypt( (xAcc)->brcode )+"-"+r_encrypt((xAcc)->refno )
         (xAcc)->( DBSkip() )
		enddo
   else
      if (cFile := do_cps(cToken(mClient), "Get_Account" )) == ""
			return lRet
		endif
		cFile := CopyFile(cFile)
		dbselectarea( "acct" ) ; __dbZap()

		// Put Text to DBF
		nH := FOpen( cFile, 0 )
		FSeek( nH, 0 )                             // top of file
		while .T.
			cText := FReadStr(nH, 104 )
			if cText == ""
				exit
			endif
			cText := rms_Parse( cText, "~" )
         acct->( DBAppend() )
			acct->brcode   := r_encrypt(cText[1])
			acct->clntcode := r_encrypt(cText[2])
			acct->acctno   := r_encrypt(cText[3])
			acct->status   := r_encrypt(cText[4])
			acct->oldno    := r_encrypt(cText[5])
			acct->docref   := r_encrypt(iif( cText[6] == "1", "CA ", "OT " ))
			acct->refno    := r_encrypt(cText[1])+"-"+r_encrypt(cText[7])
		enddo
		FClose(nH) ; FErase( cFile )
	endif
	dbselectarea( "acct" ) ; acct->( dbgotop() )

	begin sequence
		if acct->( lastrec() ) == 0
         Error( "Account NOT Found..." )
			break
		endif

		mar := { "    Client N§  " + tran(mClient, "@R 999-99-99999" ) ,;
			"  Client Name  " + left(mCName, 40),;
			repl( "Ä", 68 ),;
			"       Acct. N§         Name ",;
			repl( "Ä", 68 ) }

		acct->( dbeval( {|| aadd( mar, " " + ;
			trans(r_decrypt(acct->brcode+acct->acctno), "@R 999-9999-99999-99999")+;
         space(2)+substr(upper(xdisp_status(r_decrypt(acct->status))), 1, 12) +;
			r_decrypt(acct->oldno) + r_decrypt(acct->docref) + r_decrypt(acct->refno) )+" "},, ;
			{|| r_decrypt(acct->brcode+acct->clntcode) == mClient .AND. ! acct->( eof() ) }) )

		if len(mar) > 1
			mlog := aclone( mar )
			aeval ( mlog, { | l, c | mlog[ c ] := if( c <= 5, .F., .T. ), c } )
         nPos := val( gen_achoice( mar, 6, "Search", mlog ) )
		endif

      if nPos > 0 .AND. lastkey() != K_ESC
         mAccnt := substr(ltrim(mar[nPos]),01,3) + ;
            substr(ltrim(mar[nPos]),05,4) + ;
            substr(ltrim(mar[nPos]),10,5) + ;
            substr(ltrim(mar[nPos]),16,5)
         lRet := .T.
		endif
	end sequence
return lRet

*******************************************************************************
static function v_motor( mAccnt, mClient )
   local mar, nPos := 0, lRet := .F.
   local cFile, nH, cText
   local nT := 5, nL := 5, xAccnt

	__Keyboard()

   if (m->TRUE_BRCH == "001")
      dbSelectArea( "ztemp" ) ; __dbZap()
      MySeek( mClient alias "acctmast" order 1 )
      while ! acctmast->( eof() ) .and. strMatch(acctmast->brcode+acctmast->clntcode, mClient)
         xAccnt := acctmast->brcode+acctmast->acctno
         MySeek( xAccnt ALIAS "ctrlinfo" order 1 )
         while ! ctrlinfo->( eof() ) .and. strMatch(ctrlinfo->brcode+ctrlinfo->acctno, xAccnt)
            ztemp->( DBAppend() )
            ztemp->brcode   := acctmast->brcode
            ztemp->clntcode := acctmast->clntcode
            ztemp->acctno   := acctmast->acctno
            ztemp->motorno := ctrlinfo->motorno
            ztemp->serialno:= ctrlinfo->serialno
            ztemp->plateno := ctrlinfo->plateno
            ctrlinfo->( DBSkip() )
         enddo
         acctmast->( DBSkip() )
      enddo
   else
      if (cFile := do_cps(mClient, "Get_Motor" )) == ""
			return lRet
		endif
		cFile := CopyFile(cFile)
      dbselectarea( "ztemp" ) ; __dbZap()

		// Put Text to DBF
		nH := FOpen( cFile, 0 )
		FSeek( nH, 0 )                             // top of file
		while .T.
         cText := FReadStr(nH, 92 )
			if cText == ""
				exit
			endif
			cText := rms_Parse( cText, "~" )
         ztemp->( DBAppend() )
         ztemp->brcode   := cText[1]
         ztemp->clntcode := cText[2]
         ztemp->acctno   := cText[3]
         ztemp->motorno  := cText[4]
         ztemp->serialno := cText[5]
         ztemp->plateno  := cText[6]
		enddo
      CloseFile(nH, cFile )
   endif
   ztemp->( dbgotop() )

	begin sequence
      if ztemp->( lastrec() ) == 0
         Error( "Account NOT Found..." )
			break
		endif

      mar := {}
      ztemp->( dbeval( {|| aadd( mar, ;
         trans( ztemp->acctno, "@R 9999-99999-99999") + "³" + ;
         trans( left(ztemp->motorno,20), "@!") + "³" + trans( ztemp->serialno, "@!") + "³" + ;
         trans( left(ztemp->plateno,10), "@!") )},,{|| ! ztemp->( eof() ) }) )

      Desktop(.T.)
      setcolor( "w+/rb" )
      *Frame2( nT,nL,nT+12,nL+70," Search ", "w+/rb" )
      rmsBox( nT,nL,12,70,4,,"w+/rb",,,3 )
      dispText( nT+1, nL+3, "Client N§: " + trans(mClient, "@R 999-99-99999") )
      dispText( nT+2, nL+3, "     Name: " + mCName )
      dispText( nT+4, nL+2, "Account N§" )
      dispText( nT+4, nL+20, "Motor N§"  )
      dispText( nT+4, nL+40, "Serial N§" )
      dispText( nT+4, nL+61, "Plate N§" )
      nPos := achoice(nT+5,nL+1,nT+11,nL+69,mar,,1,1)
      if nPos > 0
         mAccnt := m->g_PAR_BRCH + ;
            substr(ltrim(mar[nPos]),01,4) + ;
            substr(ltrim(mar[nPos]),06,5) + ;
            substr(ltrim(mar[nPos]),12,5)
         lRet := .T.
      endif
      Desktop(.F.)
	end sequence
return lRet

*******************************************************************************
static function fVouc5000()
   local nKey, nRec

	if empty(mAcctno)
		return nil
   endif

   StatLine( " ~Tab~-Header  ~F2~-Edit " )
   spChar( 04,00,12,21, "w/n,w+/w", "°Û" )
   while .T.
		dispbegin()
      select "temp2"
		oTB:forcestable()
      dispend()
      nKey := THighlight( oTB, oTB:rowpos, oTB:colpos, oTB:colpos )
		do case
         case TNavigate(oTB, nKey)
			case nKey == K_TAB  ; exit
         case nKey == K_F2
            if chkpass( "E", m->AX_LEVEL, m->gUSER_ID )
               Upd_Detail(.F.)
            endif
		endcase
	enddo
   StatLine( " ~Tab~-Details  ~F4~-Search  ~F5~-View History Log  ~Esc~-Exit " )
   spChar( 04,00,12,21, "w+/w,w/n", "Û°" )
return nil

*******************************************************************************
static function sele_insby( xVar, mrow, ncol )
   local aList := { "1 = CLIENT ","2 = COLF   ","3 = DEALER " }
   local oldval := xVar
   xVar := gen_achoice( aList, val(xVar), "Insured By", mrow, 56, mrow+len(aList), 77, "w/gr+,w/n,,,w/gr+" )
   *xVar := str( VPopup( aList, val(xVar), mRow, nCol ), 1 )
	if lastkey() == K_ESC
		xVar := oldval
   endif
   dispoutat( mrow, ncol, disp_insu( xVar, .F. ) )
return .f.

*******************************************************************************
static function Upd_Detail( isNew )
   local getlist := {}
   local nRec := temp2->( recno() )
   local xVar01, xVar02, xVar03, xVar04, xVar05, xVar06, xVar07
   local xVar08, xVar09, xVar10, xVar11, xVar12, xVar13, xParams
   local nT := 8, nL := 13

   if ! isNew .and. temp2->recnum == 0
      Error("Nothing to Edit")
      return nil
   endif

   if isNew
      temp2->( dbGoto(0) )
   endif

   *xVar01 := m->mAcctno
   xVar01 := temp2->recnum
   xVar02 := r_decrypt(temp2->Plateno)
   xVar03 := r_decrypt(temp2->Motorno)
   xVar04 := r_decrypt(temp2->Serialno)
   xVar05 := r_decrypt(temp2->Insby)
   xVar06 := r_decrypt(temp2->Insco)
   xVar07 := val(r_decrypt(temp2->Insprem))
   xVar08 := val(r_decrypt(temp2->Amtins))
   xVar09 := ctod(r_decrypt(temp2->Insdate))
   xVar10 := ctod(r_decrypt(temp2->Insexpry))
   xVar11 := r_decrypt(temp2->Inscover)
   xVar12 := r_decrypt(temp2->Inspolcy)
   xVar13 := r_decrypt(temp2->Insor)

	Desktop(.T.)
   Box3( nT,nL,13,62,"w+/rb" )
	while  .T.
      setcolor( "w+/rb" )
		dispoutat( 08,15, " Update " )
		dispoutat( 09,15, "        Plate No.  " )
		dispoutat( 10,15, "        Motor No.  " )
		dispoutat( 11,15, "       Serial No.  " )
		dispoutat( 12,15, "       Insured by  " )
		dispoutat( 13,15, "Insurance Company  " )
		dispoutat( 14,15, "Insurance Premium  " )
		dispoutat( 15,15, "   Amount Insured  " )
		dispoutat( 16,15, "     Date Insured  " )
		dispoutat( 17,15, "      Expiry Date  " )
		dispoutat( 18,15, " Type of Coverage  " )
		dispoutat( 19,15, "    Policy Number  " )
		dispoutat( 20,15, "Insurance O.R. N§  " )

		rms_set( "w/rb,n/w,,,w+/rb", 1 )
      @ 09, 35 get xVar02 picture "@!"
      @ 10, 35 get xVar03 picture "@!"
      @ 11, 35 get xVar04 picture "@!"
      @ 12, 35 get xVar05 picture "@X" when eval( { || sele_insby( @xVar05, 12, 37 ),.f.} )
      @ 13, 35 get xVar06 picture "@!" when _vComp( @xVar06 ) valid !empty( @xVar06 )
      @ 14, 35 get xVar07 picture "999,999,999.99" valid xVar07 > 0
      @ 15, 35 get xVar08 picture "999,999,999.99" valid xVar08  > 0
      @ 16, 35 get xVar09 picture "@D" valid _vDate( xVar09, @xVar10 )
      @ 17, 35 get xVar10 picture "@D" valid _vDate2( xVar09, xVar10 )
      @ 18, 35 get xVar11 picture "@!" when _vCover( @xVar11 ) valid !empty( @xVar11 )
      @ 19, 35 get xVar12 picture "@X"
      @ 20, 35 get xVar13 picture "@X"
		read
		setcursor(0)
      if lastkey() == 27
         if EscKey()
            Exit
         endif
         loop
      endif
      if Confirm( "Are all entries correct?" )
         *MSGWIN(12,35,"Saving","W+/BG","R*/BG","ON")

         if isNew
            temp2->( DBAppend() )
         endif
         temp2->Plateno := r_encrypt(xVar02)
         temp2->Motorno := r_encrypt(xVar03)
         temp2->Serialno:= r_encrypt(xVar04)
         temp2->Insby   := r_encrypt(xVar05)
         temp2->Insco   := r_encrypt(xVar06)
         temp2->Insprem := r_encrypt(str(xVar07),12,2)
         temp2->Amtins  := r_encrypt(str(xVar08),12,2)
         temp2->Insdate := r_encrypt(dtoc(xVar09))
         temp2->Insexpry:= r_encrypt(dtoc(xVar10))
         temp2->Inscover:= r_encrypt(xVar11)
         temp2->Inspolcy:= r_encrypt(xVar12)
         temp2->Insor   := r_encrypt(xVar13)
         nRec := temp2->( DBCommit(), recno() )

         xParams := cToken(xVar01,9,0) + cToken(xVar02) + cToken(xVar03) + ;
                    cToken(xVar04) + cToken(xVar05) + cToken(xVar06) + ;
                    cToken(xVar07,12,2) + cToken(xVar08,12,2) + ;
                    cToken(xVar09) + cToken(xVar10) + cToken(xVar11) + ;
                    cToken(xVar12) + cToken(xVar13) + cToken(m->gUSER_ID)
         upd_inslog( xParams )
         *MSGWIN(12,35,"Saving",,,"OFF")
         exit
      endif
   enddo
   Desktop(.F.)
   dbSelectArea("temp2")
   temp2->( dbGoto(nRec) )
   oTB:forcestable():refreshall()
return nil

*******************************************************************************
static function upd_inslog( xParams )
   if (m->TRUE_BRCH == "001")
      ctrlinfo->( dbgoto(temp2->recnum) )
      while .T.
         if ctrlinfo->( netlock("R", 5) )
            ctrlinfo->plateno  := r_decrypt(temp2->plateno)
            ctrlinfo->motorno  := r_decrypt(temp2->motorno)
            ctrlinfo->serialno := r_decrypt(temp2->serialno)
            ctrlinfo->insby    := r_decrypt(temp2->insby)
            ctrlinfo->insco    := r_decrypt(temp2->insco)
            ctrlinfo->insprem  := val(r_decrypt(temp2->insprem))
            ctrlinfo->amtins   := val(r_decrypt(temp2->amtins))
            ctrlinfo->insdate  := ctod(r_decrypt(temp2->insdate))
            ctrlinfo->insexpry := ctod(r_decrypt(temp2->insexpry))
            ctrlinfo->inscover := r_decrypt(temp2->inscover)
            ctrlinfo->inspolcy := r_decrypt(temp2->inspolcy)
            ctrlinfo->insor    := r_decrypt(temp2->insor)
            ctrlinfo->( DBCommit(), dbunlock() )
            exit
         endif
      enddo

      while .T.
         if inslog->( netlock("A", 5) )
            inslog->brcode  := ctrlinfo->brcode
            inslog->acctno  := ctrlinfo->acctno
            inslog->insured := ctrlinfo->insured
            inslog->insby   := ctrlinfo->insby
            inslog->insprem := ctrlinfo->insprem
            inslog->amtins  := ctrlinfo->amtins
            inslog->insdate := ctrlinfo->insdate
            inslog->insexpry:= ctrlinfo->insexpry
            inslog->inscover:= ctrlinfo->inscover
            inslog->inspolcy:= ctrlinfo->inspolcy
            inslog->insor   := ctrlinfo->insor
            inslog->update  := date()
            inslog->userid  := m->gUSER_ID
            inslog->( DBCommit(), dbunlock() )
            exit
         endif
      enddo
   else
      do_cps(xParams, "INSU_UPDAT")
   endif
return nil

*******************************************************************************
static function _vComp( xVar )
   local isOK, aFlds, bScope := { || .T. }
   local xBrch := !(m->TRUE_BRCH == "001")
   local xVal := m->g_PAR_BRCH + xVar

   aFlds := { ;
      { "Company", "insname", "@!", 40, xBrch },;
      { "Code",    "inscode", "@!", 04, xBrch },;
      { "Branch",  "brcode",  "@!", 06, xBrch },;
      { "Category","catcode", "@!", 08, xBrch } }

   if (m->TRUE_BRCH == "001")
      bScope := {|| brcode == m->g_PAR_BRCH }
   endif

   MySeek( xVal ALIAS "insuranc" ORDER 1 )
   if ABrowse(03,,21,"insuranc",2,aFlds,"Select Insurance Company", bScope )
      if (m->TRUE_BRCH == "001")
         xVar := insuranc->inscode
         dispoutat( 13,40, left(insuranc->insname,30))
      else
         xVar := r_decrypt(insuranc->inscode)
         dispoutat( 13,40, left(r_decrypt(insuranc->insname),30))
      endif
   endif
return .F.

*******************************************************************************
static function _vCover( xVar, nR )
   local xBrch := !(m->TRUE_BRCH == "001")
   local aFlds := { { "Code",        "covercode", "@!", 04, xBrch },;
                    { "Description", "coverdesc", "@!", 30, xBrch } }

   MySeek( xVar ALIAS "coverage" ORDER 1 )
   if ABrowse(07,26,21,"coverage",1,aFlds,"Select Coverage")
      if xBrch
         xVar := r_decrypt(coverage->covercode)
      else
         xVar := coverage->covercode
      endif
      dispoutat( 18,40, disp_cover(xVar) )
   endif
return .F.

*******************************************************************************
static function _vDate( xDate, xDate2 )
   local nD, nM, nY, lRet := .F.
   if !Empty(xDate)
      nM := month(xDate)
      nD := Day(xDate)
      nY := Year(xDate)+1
      xDate2 := rms_ntod( nM, nD, str(nY,4) )
      lRet := .T.
   endif
return lRet

*******************************************************************************
static function _vDate2( xDate, xDate2 )
   local lRet := .T.
   if xDate > xDate2
      Error("Expiration date should be greater than Insurance date")
      lRet := .F.
   endif
return lRet

*******************************************************************************
static function InsLog_Hist()
   local cBrAccnt := r_decrypt(temp1->brcode+temp1->acctno)
   local oHist, aOption := {}
   local nH, cFile, cText

	if empty(mAcctno)
		return nil
   endif

   select "zHist" ; __dbZap()
   if (m->TRUE_BRCH == "001")
      inslog->( DBSeek(cBrAccnt) )
      while ! inslog->( eof() ) .and. inslog->brcode+inslog->acctno == cBrAccnt
         zHist->( DBAppend() )
         zHist->recnum  := inslog->( recno() )
         zHist->brcode  := inslog->brcode
         zHist->acctno  := inslog->acctno
         zHist->insured := inslog->insured
         zHist->insby   := inslog->insby
         zHist->insprem := inslog->insprem
         zHist->amtins  := inslog->amtins
         zHist->insdate := inslog->insdate
         zHist->insexpry:= inslog->insexpry
         zHist->inscover:= inslog->inscover
         zHist->inspolcy:= inslog->inspolcy
         zHist->insor   := inslog->insor
         zHist->update  := inslog->update
         zHist->userid  := inslog->userid
         inslog->( DBSkip() )
      enddo
      zHist->( DBCommit(), DBGoTop() )
   else
      CPS_Exec( cBrAccnt, "INSU_LOG", "zHist", 135 )
   endif

   oHist := TBrowNew( 07,02,13,75,,"ÂÄ" )
   MyColumn( oHist, TITLE "Last Update"   BLOCK {|| zHist->update    } picture "@D" )
   MyColumn( oHist, TITLE "User"          BLOCK {|| zHist->userid    }  )
   MyColumn( oHist, TITLE "Ins Thru"      BLOCK {|| disp_insu(zHist->insby) } width 10  )
   MyColumn( oHist, TITLE "Premium"       BLOCK {|| zHist->insprem   } picture "999,999,999.99" )
   MyColumn( oHist, TITLE "Amount Insured"  BLOCK {|| zHist->amtins  } picture "999,999,999.99" )
   MyColumn( oHist, TITLE "Date Insured"  BLOCK {|| zHist->insdate   } picture "@D" )
   MyColumn( oHist, TITLE "Expiry Date"   BLOCK {|| zHist->insexpry  } picture "@D" )
   MyColumn( oHist, TITLE "Policy Number" BLOCK {|| zHist->inspolcy  } )
   MyColumn( oHist, TITLE "OR N§"         BLOCK {|| zHist->insor     }  )

   DBBrowse( oHist, "zHist", 1, "Insurance Log History", aOption, {.T., .F., .T.} )
return nil
