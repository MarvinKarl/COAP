*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
*³ Orix Metro Leasing and Finance                                            ³Û
*³ Account Management System                                                 ³Û
*ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Û
*³ Program ID...: AMSM1010.PRG                                               ³Û
*³ Description..: Delinquent Accounts Status Maintenance                     ³Û
*³ Author...... : Ariel B. Bulan                                             ³Û
*³ Date.........: 24-Apr-1995   04:25:00pm                                   ³Û
*ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Û
*³                       U P D A T E S                                       ³Û
*ÃÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Û
*³  Who  ³ When        ³ Why                                                 ³Û
*ÃÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Û
*³  RMS  ³ 03-Jan-2011 ³ CPS for branches                                    ³Û
*ÀÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙÛ
*  ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

#include "colf.ch"
#include "inkey.ch"
#include "rms.ch"

private xCust, xAcct, xDQ1, xDQ2, oTB, aHead[03]
private mClient, mCName, mAcctno, mRecover, mUnsecured, mClascoll
private xStr, xScr

if chkpass( procname(), m->AX_LEVEL, m->g_USER_ID )
   xScr := Savescreen()
   if open1010M()
      gkey1010()
	endif
	dbCloseAll()
   r_erase( (xAcct) )
   r_erase( (xDQ1) )
   r_erase( (xDQ2) )
   r_erase( (xCust) )
endif
return nil

*******************************************************************************
static function open1010M()
	local lRet := .F.

	begin sequence
		xDQ1 := r_tempfile( m->pTemp )
		dbcreate( xDQ1, { ;
			{ "brcode",   "c", 03, 0 },;
         { "clntcode", "c", 07, 0 },;
         { "acctno",   "c", 14, 0 },;
			{ "recover",  "c", 16, 0 },;
			{ "unsecured","c", 16, 0 },;
			{ "clascoll", "c", 01, 0 } } )
		OpenTMP( (xDQ1), "dq1", .F. )

		xDQ2 := r_tempfile( m->pTemp )
		dbcreate( xDQ2, { ;
			{ "recnum", "n", 09, 0 },;
			{ "date",   "d", 08, 0 },;
			{ "status", "c", 40, 0 } } )
		OpenTMP( (xDQ2), "dq2", .F. )
		dbselectarea( "dq2" )
      dbCreateIndex( (xDQ2), "dtos(date)", {|| dtos(date)}, .F. )
		set index to (xDQ2)

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
		dbCreateIndex( (xAcct), "r_decrypt(brcode+acctno)", {|| r_decrypt(brcode+acctno)}, if( .F., .T., NIL ) )
		Set Index to (xAcct)

      if (m->TRUE_BRCH == "001")
         if ! openList( { "delqhead", "delqdtls", "acctmast", "client" })
				break
			endif
      else
			if !cust_temp( m->pTemp )
				break
			endif
		endif
      client->( dbgotop() )

		lRet := .T.
	end sequence
return lRet

*******************************************************************************
static function GetData( isNew )
	if isNew
		dq1->( dbgoto(0) )
	endif
	mAcctNo    := r_decrypt(dq1->brcode+dq1->acctno)
	mRecover   := val(r_decrypt(dq1->recover))
	mUnsecured := val(r_decrypt(dq1->unsecured))
	mClascoll  := r_decrypt(dq1->clascoll)

   mClient := r_decrypt(dq1->brcode+dq1->clntcode)
   MySeek( mClient ALIAS "client" )
	mCName  := r_decrypt(client->fullname)

	if isNew .or. empty(mAcctno)
		select "dq2" ; __dbzap()
	endif

	dq2->( dbgotop() )
return nil

*******************************************************************************
static function ShowData( isNew )

	dispbegin()
	GetData( isNew )
   setcolor("w+/b")
   dispoutat( 04,21, transf( mClient, "@R 999-99-99999" ) )
   dispoutat( 04,36, left(mCName,40) )
   dispoutat( 05,21, transf( mAcctno,    "@R 999-9999-99999-99999" ) )
   dispoutat( 06,45, transf( mRecover,   "@R 999,999,999.99") )
   dispoutat( 07,45, transf( mUnsecured, "@R 999,999,999.99") )
   dispoutat( 08,45, mClascoll )

	select "dq2"
	dq2->( dbgotop() )
	oTB:autolite := .F.
	oTB:refreshall():forcestable()
	dispend()
return nil

*******************************************************************************
static function SaveDetails( lSave )
	local i
   static aDetails := {}

	if lSave
		aDetails := {}
      dbSelectArea("dq2") ; dq2->( dbGoTop() )
		while ! dq2->( eof() )
         aAdd(aDetails, dq2->( SaveFields() ) )
			dq2->( dbSkip() )
		enddo
	else
      dbSelectArea("dq2") ; __dbZap()
		for i := 1 to len(aDetails)
         dq2->( dbAppend() )
         dq2->( RestFields(aDetails[i]) )
		next
		dq2->( dbCommit() )
	endif
return nil

******************************************************************************
static function gkey1010()
   local nKey, nRec, n
	local tbcol_ := { ;
		tbcolumnnew( padr("Date"  , 10), { || tran( dq2->date, "@D" ) } ),;
		tbcolumnnew( padr("Status", 40), { || r_decrypt(dq2->status) } ) }

	begin sequence
      scrntitle( "Delinquent Accounts Maintenance", m->gSYS_NAME, m->gUSER_ID, m->gTRANDATE )
		spBox( 03,00,09,79,"w+/b")
		setcolor("bg+/b")
		********** 0123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789
      dispoutat( 04, 05, "       Client :              - " )
      dispoutat( 05, 05, "   Account N§ :           " )
      dispoutat( 06, 05, "            Estimated Recovery Amount : " )
      dispoutat( 07, 05, "             Unsecured Balance Amount : " )
      dispoutat( 08, 05, "Classification of Estimated Collection : " )

		select "dq2"
		oTB := TBrowNew( 10,01,22,78,"w/n,w+/bg","ÍÑÍ"," ³ ","ÄÁÄ" )
		for n := 1 to len( tbcol_ )
			oTB:addcolumn( tbcol_[n] )
		next

      StatLine( " ~Ins~-Add ~F2~-Edit ~F4~-Search ~Tab~-Details ~Del~-Delete ~Esc~-Exit " )
      spChar( 04,00,09,21, "w+/w,w/n", "Û°" )
		while .T.
         ShowData(.F.)
			nKey := inkeytrap(0)
			do case
				case nKey == K_ESC ; exit
				case nKey == K_INS
					if chkpass( "A", m->AX_LEVEL, m->g_USER_ID )
                  New_DAS(.T.)
					endif
				case nKey == K_F2
               if chkpass( "E", m->AX_LEVEL, m->g_USER_ID )
                  if empty(mAcctno)
                     Error("Nothing to Edit!")
                  else
                     Edit_DAS()
                  endif
					endif
				case nKey == K_F4
					if chkpass( "S", m->AX_LEVEL, m->g_USER_ID )
						Find_DAS()
					endif
				case nKey == K_DEL
               if chkpass( "D", m->AX_LEVEL, m->g_USER_ID )
                  DAS1_Delete( mAcctno )
					endif
            case nKey == K_TAB ; case1010()
			endcase
		enddo
	end sequence
return nil

*******************************************************************************
static function Check_DAS( cCode )
	local lRet := .F.
	if ! empty(cCode)
		lRet := delqhead->( dbSeek(cCode) )
	endif
return lRet

*******************************************************************************
static function Find_DAS()
	local nRec := dq1->( recno() )
	local Result, lRet := .F., lFound := .F.

	begin sequence
      if Get_Account( @mAcctno )
         if (m->TRUE_BRCH == "001")
				lFound := Check_DAS( mAcctno )
         else
            Result := do_cps(mAcctno, "DAS_CHECK")
				if empty(Result)
					break
				endif
				lFound := (Result == "T")
			endif
			if lFound
            nRec := Get_DAS( mAcctno )
				lRet := .T.
			else
            if Yes_No2( " Account not found... ",, "  Add  ", " Cancel " )
					lRet := .T.
					aHead[1] := mClient
					aHead[2] := mCName
					aHead[3] := mAcctno
               New_DAS(.F.)
				endif
			endif
		endif
	end sequence
	dq1->( dbgoto(nRec) )
return lRet

******************************************************************************
static function DAS1_Update( isNew )
   local lRet := .T.
	if isNew
      delqhead->( netlock("A", 0) )
      delqhead->brcode := left(mAcctno, 3)
      delqhead->acctno := right(mAcctno, 14)
	else
      delqhead->( dbseek(mAcctno), netlock("R", 0) )
	endif
   delqhead->recover   := mRecover
   delqhead->unsecured := mUnsecured
   delqhead->clascoll  := mClascoll
   delqhead->( dbcommit(), dbunlock() )
return lRet

*******************************************************************************
static function Update_DAS()
	dbselectArea("dq1") ; __dbZap()
	dq1->( dbappend() )
   dq1->brcode    := r_encrypt(left(mAcctno,03))
   dq1->clntcode  := r_encrypt(right(mClient,07))
	dq1->acctno    := r_encrypt(right(mAcctno,14))
	dq1->recover   := r_encrypt(str(mRecover,16,2))
	dq1->unsecured := r_encrypt(str(mUnsecured,16,2))
	dq1->clascoll  := r_encrypt(mClascoll)
return dq1->( dbCommit(), recno() )

******************************************************************************
static function New_DAS( isNew )
	local lRet := .F., lOK := .F.
	local nRec := dq1->( recno() )
	local getlist := {}

	SaveDetails(.T.) ; ShowData(.T.)
	if ! isNew
		mClient := aHead[1]
		mCName  := aHead[2]
		mAcctno := aHead[3]
	endif
	center( 24, "w+/n","® Add Record ¯ " )
	while .T.
		rms_Set( "gr+/b, w+/g,,, gr+/b", 1 )
		@04,21 get mClient     picture "@R 999-99-99999" when isNew valid v_client( @mClient, @mCName )
		@04,36 get mCName      picture "@!S40" when .f.
		@05,21 get mAcctno     picture "@R 999-9999-99999-99999" when isNew valid chkacctno( isNew, @mAcctno, mClient )
		@06,45 gget mRecover   calculator picture "999,999,999.99"
		@07,45 gget mUnsecured calculator picture "999,999,999.99"
		@08,45 get mClascoll   picture "@X"
		read
		setcursor(0)
		if lastkey() == K_ESC
			if EscKey()
				exit
			endif
			loop
		endif

		if Confirm( "Are all entries correct?" )
         if (m->TRUE_BRCH == "001")
				lOK := DAS1_Update(.T.)
         else
            m->xStr := "A~" + mAcctno+"~" + chk_par(mRecover) + ;
					chk_par(mUnsecured) + chk_par(mClascoll)
            lOK := ( do_cps(m->xStr, "DAS1_UPDATE") == "T" )
			endif
			if lOK
				nRec := Update_DAS()
				lRet := .T.
			endif
			exit
		endif
	enddo
	if ! lRet
		SaveDetails(.F.)
	endif
	dq1->( dbgoto(nRec) )
   center( 24, "w+/n","                     " )
return lRet

******************************************************************************
static function Edit_DAS()
	local nRec, lRet := .F., lOK := .F.
	local getlist := {}

	center( 24, "w+/n","® Edit Record ¯" )
	ShowData(.F.)
	while .T.
		rms_set( "gr+/b, w+/g,,, gr+/b", 1 )
		@04,21 get mClient     picture "@R 999-99-99999" when .F.
		@04,36 get mCName      picture "@!S40" when .F.
		@05,21 get mAcctno     picture "@R 999-9999-99999-99999" when .F.
		@06,45 gget mRecover   calculator picture "999,999,999.99"
		@07,45 gget mUnsecured calculator picture "999,999,999.99"
		@08,45 get mClascoll   picture "@X"
		read
		setcursor(0)
		if lastkey() == K_ESC
			if EscKey()
				exit
			endif
			loop
		endif

		if Confirm( "Are all entries correct?" )
         if (m->TRUE_BRCH == "001")
            lOK := DAS1_Update(.F.)
         else
            m->xStr := "R~" + mAcctno+"~" + chk_par(mRecover) + ;
               chk_par(mUnsecured)  + chk_par(mClascoll)
            lOK := ( do_cps(m->xStr, "DAS1_UPDATE") == "T" )
			endif
			if lOK
            nRec := Update_DAS()
				lRet := .T.
			endif
			exit
		endif
	enddo
	center ( 24, "w+/n","                     " )
return lRet

********************************************************************************
static function DAS1_Delete( mCode )
	if empty(mCode)
		Error( "Nothing to Delete!" )
		return nil
	endif

	if Confirm( "Delete Acct N§ "+tran( mCode, "@R 999-9999-99999-99999" )+" ?" )
      if (m->TRUE_BRCH == "001")
			if delqdtls->( dbseek(mCode) )
            while ! delqdtls->( eof() ) .and. (delqdtls->brcode+delqdtls->acctno == mCode)
               delqdtls->( netlock("R", 0), dbDelete(), dbUnlock(), dbSkip() )
				enddo
				delqdtls->( dbCommit() )
			endif
         delqhead->( dbSeek(mCode), netlock("R", 0), dbDelete(), dbcommit(), dbunlock() )

			dbSelectArea("dq1") ; __dbZap()
      else
         if do_cps(mAcctno, "DAS1_DELETE") == "T"
            dbSelectArea("dq1") ; __dbZap()
         endif
		endif
	endif
return nil

********************************************************************************
static function Get_DAS( mAccount )
   local nRec, nH, cFile, cText, cCode

	begin sequence
		if !(m->TRUE_BRCH == "001")
         cFile := do_cps(mAccount, "DAS_GET")
			cFile := CopyFile( cFile )
			nH := FOpen( cFile, 0 )
			FSeek(nH, 0)
			cText := FReadStr(nH, 57)
			cText := rms_Parse( cText, "~" )

			dbSelectArea("dq1") ; __dbZap()
			dq1->( dbappend() )
			dq1->brcode    := r_encrypt(cText[1])
			dq1->acctno    := r_encrypt(cText[2])
			dq1->recover   := r_encrypt(cText[3])
			dq1->unsecured := r_encrypt(cText[4])
			dq1->clascoll  := r_encrypt(cText[5])
         dq1->clntcode  := client->clntcode
         nRec := dq1->( dbcommit(), recno() )

			dbSelectArea("dq2") ; __dbZap()
			while .T.
				cText := FReadStr(nH, 83)
				if cText == ""
					exit
				endif
				cText := rms_Parse( cText, "~" )
				dq2->( dbappend() )
				dq2->recnum := val(alltrim(cText[1]))
				dq2->date   := ctod(cText[4])
				dq2->status := r_encrypt(cText[5])
			enddo
			dq2->( dbcommit() )
			FClose(nH) ; FErase(cFile)
		else
			select "dq1" ; __dbZap()
			delqhead->( dbSeek(mAccount) )
			dq1->( dbappend() )
			dq1->brcode    := r_encrypt(delqhead->brcode)
			dq1->acctno    := r_encrypt(delqhead->acctno)
			dq1->recover   := r_encrypt(str(delqhead->recover,16,2))
			dq1->unsecured := r_encrypt(str(delqhead->unsecured,16,2))
			dq1->clascoll  := r_encrypt(delqhead->clascoll)
         dq1->clntcode  := r_encrypt(client->clntcode)
			nRec := dq1->( dbcommit(), recno() )

			dbSelectArea("dq2") ; __dbZap()
			delqdtls->( dbSeek(mAccount) )
			while !delqdtls->( eof() ) .AND. delqdtls->brcode+delqdtls->acctno == mAccount
				dq2->( dbappend() )
				dq2->recnum := delqdtls->( recno() )
				dq2->date   := delqdtls->date
				dq2->status := r_encrypt(delqdtls->status)
				delqdtls->( dbskip() )
			enddo
			dq2->( dbcommit() )
		endif
	end sequence
return nRec

*******************************************************************************
static function Get_Account( mAccnt )
	local lRet := .F.

	if Get_Client( @mClient, @mCName ) > 0
      lRet := v_account( @mAccnt, mClient )
	endif
return lRet

********************************************************************************
static function chkacctno( isNew, mAcct, mClient )
	local lRet := .F., lFound := .F.
	local nRec := dq1->( recno() )

	begin sequence
		if lastkey() == K_UP
			lRet := .T. ; break
		endif
      if ! acct->( dbSeek(mAcct, .F.) )
         if ! v_account( @mAcct, mClient )
				break
			endif
		endif

      if (m->TRUE_BRCH == "001")
         lFound := ( isNew .AND. Check_DAS( mAcct ) )
      else
         lFound := (isNew .AND. do_cps( mAcct, "DAS_CHECK" ) == "T")
		endif
		if lFound
         Error( "Account N§ already exist!" )
			break
		endif

      mAcct := r_decrypt(acct->brcode+acct->acctno)
		lRet := .T.
	end sequence
	if ! lRet
      mAcct := space(17)
	endif
	dq1->( dbGoto(nRec) )
return lRet

*******************************************************************************
static function v_account( mAccnt, mClient )
	local cFile, nH, cKey, cText, xAcc
   local mar, nPos := 0, mlog := {}, lRet := .F.

	__Keyboard()
	if !(m->TRUE_BRCH = "001")
      if (cFile := do_cps(cToken(mClient), "GET_ACCOUNT" )) == ""
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
			acct->( dbappend() )
			acct->brcode   := r_encrypt(cText[1])
			acct->clntcode := r_encrypt(cText[2])
			acct->acctno   := r_encrypt(cText[3])
			acct->status   := r_encrypt(cText[4])
			acct->oldno    := r_encrypt(cText[5])
			acct->docref   := r_encrypt(iif( cText[6] == "1", "CA ", "OT " ))
			acct->refno    := r_encrypt(cText[1])+"-"+r_encrypt(cText[7])
		enddo
		FClose(nH) ; FErase( cFile )
	else
		dbSelectArea( "acct" ) ; __dbZap()
		xAcc := "acctmast"
		(xAcc)->( dbseek(mClient) )
		while ! (xAcc)->( eof() ) .and. (xAcc)->brcode+(xAcc)->clntcode == mClient
			acct->( dbappend() )
			acct->brcode   := r_encrypt( (xAcc)->brcode )
			acct->clntcode := r_encrypt( (xAcc)->clntcode )
			acct->acctno   := r_encrypt( (xAcc)->acctno )
			acct->status   := r_encrypt( (xAcc)->status )
			acct->oldno    := r_encrypt( (xAcc)->oldno )
			acct->docref   := r_encrypt( iif( (xAcc)->docref == "1", "CA ", "OT " ) )
			acct->refno    := r_encrypt( (xAcc)->brcode )+"-"+r_encrypt((xAcc)->refno )
			(xAcc)->( dbSkip() )
		enddo
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
         cKEY := substr(ltrim(mar[nPos]),01,3) + ;
            substr(ltrim(mar[nPos]),05,4) + ;
            substr(ltrim(mar[nPos]),10,5) + ;
            substr(ltrim(mar[nPos]),16,5)
			if Acct->( dbseek(cKEY) )
            //mAccnt := r_decrypt(acct->brcode+acct->acctno)
            mAccnt := cKey
				lRet := .T.
			endif
		endif
	end sequence
return lRet

*******************************************************************************
static function case1010()
	local nKey, nRec

	if empty(mAcctno)
		return nil
	endif

   StatLine( " ~Ins~-Add ~F2~-Edit ~F4~-Search ~Tab~-Header ~Del~-Delete " )
   spChar( 04,00,09,21, "w/n,w+/w", "°Û" )
	while .T.
		dispbegin()
		select "dq2"
		oTB:forcestable()
		dispend()
      nKey := THighlight( oTB, oTB:rowpos, 1, oTB:colcount )
		do case
         case TNavigate(oTB, nKey, .F.)
			case nKey == K_TAB  ; exit
			case nKey == K_INS
				if chkpass("A", m->AX_LEVEL, m->g_USER_ID)
               Upd_Detail(.T.)
				endif
			case nKey == K_F2
				if chkpass("E", m->AX_LEVEL, m->g_USER_ID)
               Upd_Detail(.F.)
				endif
			case nKey == K_F4
				if chkpass("S", m->AX_LEVEL, m->g_USER_ID)
					Find_Detail( mAcctno )
				endif
			case nKey == K_DEL
				if chkpass("D", m->AX_LEVEL, m->G_USER_ID)
               Del_Detail()
				endif
		endcase
	enddo
   StatLine( " ~Ins~-Add ~F2~-Edit ~F4~-Search ~Tab~-Details ~Del~-Delete ~Esc~-Exit " )
   spChar( 04,00,09,21, "w+/w,w/n", "Û°" )
return nil

******************************************************************************
static function Upd_Detail( isNew )
   local mstatus, mdate, isOK := .F.
	local cRec, nRec := dq2->( recno() )
	local getlist := {}
   local nT := 15, nL := 15

	if !isNew .AND. dq2->recnum == 0
		isNew := .T.
	endif

   if isNew
		dq2->( dbgoto(0) )
	endif

	mDate   := dq2->date
	mStatus := r_decrypt(dq2->status)

   if isNew
		mDate := date()
	endif

	Desktop(.T.)
   Box3( nT, nL, 3, 55, "n/w" )
	while .T.
      rms_set( "n/w,w/n,,, w+/n", 1 )
      @nT+1,nL+3 say "  Date :" get mdate   pict "@D" valid !Empty( mdate )
      @nT+2,nL+3 say "Status :" get mstatus pict "@X" valid !Empty( mstatus )
		read
      if lastkey() == 27
			if EscKey()
				exit
			endif
			loop
		endif

		if Confirm( "Are all entries correct?" )
         if (m->TRUE_BRCH == "001")
				if isNew
               delqdtls->( netlock("A", 0) )
				else
               delqdtls->( dbgoto(dq2->recnum), netlock("R", 0) )
				endif
            delqdtls->brcode := left(mAcctno, 03)
            delqdtls->acctno := right(mAcctno, 14)
				delqdtls->date   := mDate
				delqdtls->status := r_decrypt(mStatus)
            isOK := delqdtls->( dbcommit(), dbunlock(), .T. )
            cRec := delqdtls->( recno() )
         else
            m->xStr := str(dq2->recnum, 9)+"~" + cToken(mAcctno) + ;
               cToken(mDate) + cToken(mStatus)

            if ! empty(cRec := do_cps(m->xStr, "DAS2_UPDATE"))
               isOK := .T.
               cRec := val(cRec)
				endif
			endif
         if isOK
				if isNew
					dq2->( dbappend() )
               dq2->recnum := cRec
				endif
				dq2->date   := mdate
				dq2->status := r_encrypt(mStatus)
				nRec := dq2->( dbcommit(), recno() )
         endif
			exit
		endif
	enddo
   Desktop(.F.)
	dbSelectArea( "dq2" )
	dq2->( dbgoto(nRec) )
	oTB:ForceStable():refreshall()
return nil

*******************************************************************************
static function Del_Detail()
	local lOK := .F.

	if dq2->recnum == 0
		Error("Nothing to Delete!")
		return nil
	endif

	if Confirm( "Delete Date "+dtoc( dq2->date )+"?" )
      if !(m->TRUE_BRCH == "001")
         lOK := (do_cps(alltrim(str(dq2->recnum)), "DAS2_DELETE") == "T")
		else
         delqdtls->( dbgoto(dq2->recnum), netlock("R", 0), dbdelete(), dbcommit(), dbunlock() )
         lOK := .T.
		endif
		if lOK .AND. dq2->( dbdelete(), dbcommit(), dbskip(), eof() )
			dq2->( dbgobottom() )
		endif
      oTB:refreshAll()
	endif
return nil

*******************************************************************************
static function Find_Detail()
	local nRec := dq2->( recno() )
   local mDate := ctod("//")
   local getlist := {}

	begin sequence
		Desktop(.T.)
      Box3( 11, 12, 2, 20, "n/w" )
		rms_set( "n/w, w+/n,,, gr+/w", 1 )
		@ 12,14 say "Date :" get mDate pict "@D"
		read
      if lastkey() == 27
			break
		endif
		nRec := dq2->( dbseek(dtos(mDate), .T.), recno() )
	end sequence
	Desktop(.F.)
	dq2->( dbgoto(nRec) )
	oTB:refreshall():forcestable()
return nil
