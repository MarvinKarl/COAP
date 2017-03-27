*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
*³ Orix Metro Leasing & Finance															 ³Û
*³ Account Management System																 ³Û
*ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Û
*³ Program ID...: AMSM0500.PRG															 ³Û
*³ Description..: PDC file maintenance 												 ³Û
*³ Author...... : Ariel B. Bulan 														 ³Û
*³ Date.........: 31-Aug-1994   01:59:00pm											 ³Û
*ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Û
*³ 							 U P D A T E S 												 ³Û
*ÃÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Û
*³  Who	³ When		  ³ Why																 ³Û
*ÃÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Û
*³ JLB	³ 11-Jun-1997 ³ Allow input of pdc's not yet in acctmast           ³Û
*³ 		³				  ³ (i.e.; in acctdaly) 										 ³Û
*³ ABB	³ 21-Dec-2001 ³ selective pdc printing 									 ³Û
*³ ABB	³ 05-Aug-2004 ³ search using whole account no.							 ³Û
*³ RKG	³ 05-Oct-2004 ³ change account format from "99999" to              ³Û
*³ 		³				  ³ "999-99999-99999"                                  ³Û
*³ ABB	³ 29-Oct-2004 ³ ONLINE															 ³Û
*³ RMS   ³ 10-Oct-2010 ³ CPS for branches                                   ³Û
*ÀÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙÛ
*	 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

#include "colf.ch"
#include "inkey.ch"
#include "rms.ch"

private xPDC1, xPDC2, xCust, xAcct, xPers, xStr
private oTB, aPDC[03]

private mBrAccnt, mAcctNo, mCCode, mClient, mCName
private mRecDate, mReciver, mPName, mValdate, mRem1, mRem2, mRem3

if chkpass( procname(), m->AX_LEVEL, m->g_USER_ID )
   if openData()
      gkey0500()
	endif
	dbCloseAll()
   r_erase( (xAcct) )
   r_erase( (xPDC1) )
   r_erase( (xPDC2) )
   r_erase( (xCust) )
   r_erase( (xPers) )
endif
return nil

*******************************************************************************
static function openData()
   local isOK :=.F.

	begin sequence
      xPDC1 := r_tempfile()
		dbcreate( xPDC1, { ;
			{ "brcode",  "c", 03, 0 },;
			{ "clntcode","c", 07, 0 },;
			{ "acctno",  "c", 14, 0 },;
			{ "recdate", "d", 08, 0 },;
			{ "receiver","c", 05, 0 },;
			{ "valdate", "d", 08, 0 },;
			{ "rem1",    "c", 60, 0 },;
			{ "rem2",    "c", 60, 0 },;
			{ "rem3",    "c", 60, 0 },;
			{ "valdate1","c", 10, 0 },;
			{ "term",    "c", 03, 0 },;
			{ "termunit","c", 03, 0 },;
			{ "matdate", "c", 10, 0 },;
			{ "credamt", "c", 12, 0 } } )
		OpenTMP( (xPDC1), "pdc1", .F. )

      xPDC2 := r_tempfile()
		dbcreate( xPDC2, { ;
			{ "tag",    "l", 01, 0 },;
			{ "recnum", "n", 09, 0 },;
			{ "bank",   "c", 25, 0 },;
			{ "chktype","c", 01, 0 },;
			{ "chkno",  "c", 15, 0 },;
			{ "chkdate","d", 08, 0 },;
			{ "depdate","d", 08, 0 },;
			{ "chkamt", "c", 12, 0 },;
			{ "status", "c", 01, 0 } } )
		OpenTMP( (xPDC2), "pdc2", .F. )
		dbselectarea( "pdc2" )
		dbCreateIndex( (xPDC2), "dtos(chkdate)", {|| dtos(chkdate)}, if( .F., .T., NIL ) )
		set index to (xPDC2)

      xAcct := r_tempfile()
		dbcreate( xAcct, { ;
			{"brcode",   "c", 03, 0 },;
			{"clntcode", "c", 07, 0 },;
			{"acctno",   "c", 14, 0 },;
			{"status",   "c", 01, 0 },;
			{"oldno",    "c", 20, 0 },;
			{"docref",   "c", 03, 0 },;
			{"refno",    "c", 09, 0 },;
			{"valdate",  "c", 10, 0 },;
			{"term",     "c", 03, 0 },;
			{"termunit", "c", 03, 0 },;
			{"matdate",  "c", 10, 0 },;
			{"credamt",  "c", 12, 0 },;
			{"source",   "c", 01, 0 } })
		OpenTMP( (xAcct), "acct", .F. )
		dbSelectArea( "acct" )
      dbCreateIndex( (xAcct), "r_decrypt(brcode+acctno)", {|| r_decrypt(brcode+acctno)}, .F. )
		Set Index to (xAcct)

      if (m->TRUE_BRCH == "001")
         if ! openList( { "pdc_head", "pdc_dtls", "acctmast", ;
                          "acctdaly", "client",   "personel", ;
                          "pdchdbck", "pdcdtbck"               })
				break
			endif
      else
         if ! cust_temp( m->pTemp, 1 )
				break
			endif

         if ! emp_temp( m->pTemp )
				break
			endif
		endif
		client->( dbgotop() )
      personel->( dbgotop() )

      isOK := .T.
	end sequence
return isOK

*******************************************************************************
static function ShowData( isNew )
   dispbegin()
	GetData( isNew )
   SetColor("w+/b")
	dispText( 04, 21, mCCode,, "@R 999-99-99999")
	dispText( 04, 36, left(mCName,40) )
	dispText( 05, 21, mBrAccnt,, "@R 999-9999-99999-99999")
	dispText( 06, 21, dtoc(mRecDate) )
	dispText( 07, 21, mReciver + "  " )
   dispText( 07, 29, mPName )
	dispText( 08, 21, padl(mRem1, 50) )
	dispText( 09, 21, padl(mRem2, 50) )
	dispText( 10, 21, padl(mRem3, 50) )

	select "pdc2"
	pdc2->( dbgotop() )
	oTB:autolite := .f.
	oTB:refreshall():forcestable()
	dispend()
return nil

*******************************************************************************
static function GetData( isNew )
	if isNew
		pdc1->( dbgoto(0) )
	endif

	mCCode	:= r_decrypt(pdc1->brcode+pdc1->clntcode) // branch+client
	mClient	:= r_decrypt(pdc1->clntcode)					// client only
	MySeek( mCCode ALIAS "client" )
	mCName	:= r_decrypt(client->fullname)
	mBrAccnt := r_decrypt(pdc1->brcode+pdc1->acctno)	// branch+account
	mAcctNo	:= r_decrypt(pdc1->acctno) 					// account only
	mRecDate := pdc1->recdate
	mReciver := r_decrypt(pdc1->receiver)
	mValDate := pdc1->valdate
	mRem1 	:= r_decrypt(pdc1->rem1)
	mRem2 	:= r_decrypt(pdc1->rem2)
	mRem3 	:= r_decrypt(pdc1->rem3)

	MySeek( mReciver ALIAS "PERSONEL" RESTORD )
	mPName := r_decrypt(PERSONEL->fullname)

	if isNew .or. empty(mBrAccnt)
		select "pdc2" ; __dbzap()
	endif

	pdc2->( dbgotop() )
return nil

*******************************************************************************
static function SaveDetails( lSave )
	local i
   static aDetails := {}

	if lSave
		aDetails := {}
		dbSelectArea("pdc2") ; pdc2->( dbgotop() )
		while ! pdc2->( eof() )
         aAdd(aDetails, pdc2->( SaveFields() ) )
			pdc2->( dbskip() )
		enddo
	else
      dbSelectArea("pdc2") ; __dbZap()
		for i := 1 to len(aDetails)
			pdc2->( dbappend() )
         pdc2->( RestFields(aDetails[i]) )
		next
		pdc2->( dbcommit() )
	endif
return nil

*******************************************************************************
static function gkey0500()
   local nKey, lMeron, nRec
   local n, tbcol_ := { ;
		tbcolumnnew( padr("Drawee Bank" ,11), { || tran( if(pdc2->tag,"û ","")+r_decrypt(pdc2->bank), "@!" ) } ),;
		tbcolumnnew( padr("Check Type"  ,10), { || tran( disp_check(r_decrypt(pdc2->chktype)), "@!" ) } ),;
		tbcolumnnew( padr("Check N§"    ,15), { || tran( r_decrypt(pdc2->chkno), "@!" ) } ),;
		tbcolumnnew( padr("Check Date"  ,10), { || tran( pdc2->chkdate, "@D" ) } ),;
		tbcolumnnew( padr("Dep Date"    ,10), { || tran( pdc2->depdate, "@D" ) } ),;
		tbcolumnnew( padr("Check Amount",14), { || tran( val(r_decrypt(pdc2->chkamt)), "999,999,999.99" ) } ),;
      tbcolumnnew( padr("Status",      09), { || tran( chk_status(r_decrypt(pdc2->status)), "@!" ) } ) }

   begin sequence
      scrntitle( "Post Dated Checks Maintenance", m->gSYS_NAME, m->gUSER_ID, m->gTRANDATE )
		spBox( 03,00,11,79,"w+/b")
		  ********** 0123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789
		setcolor("bg+/b")
      dispoutat( 04, 05, "    Client N§ :              - " )
      dispoutat( 05, 05, "   Account N§ :                " )
      dispoutat( 06, 05, "Date Received :                " )
      dispoutat( 07, 05, "  Received by :       -        " )
      dispoutat( 08, 05, "      Remarks :                " )
      dispoutat( 09, 05, "                               " )
      dispoutat( 10, 05, "                               " )

		select "pdc2"
		oTB := TBrowNew( 12,01,22,78,"w/n,w+/bg","ÍÑÍ"," ³ ","ÄÁÄ" )
		for n := 1 to len( tbcol_ )
			oTB:addcolumn( tbcol_[n] )
		next

      StatLine( " ~INS~-Add ~F2~-Edit ~F4~-Search ~F9~-Print ~Tab~-Details ~Del~-Delete ~ESC~-Exit " )
      spChar( 04,00,11,21, "w+/w,w/n", "Û°" )
      while .T.
			ShowData(.F.)
			nKey := inkeytrap(0)
			do case
				case nKey == K_ESC ; exit

				case nKey == K_INS
               if chkpass( "A", m->AX_LEVEL, m->g_USER_ID )
                  New_PDC(.T.)
					endif

				case nKey == K_F2
               if chkpass( "E", m->AX_LEVEL, m->g_USER_ID )
                  Edit_PDC( mBrAccnt )
					endif

				case nKey == K_F4
               if chkpass( "S", m->AX_LEVEL, m->g_USER_ID )
                  Find_PDC()
					endif

				case nKey == K_DEL
               if chkpass( "D", m->AX_LEVEL, m->g_USER_ID )
                  PDC1_Delete( mBrAccnt )
					endif

				case nKey == K_F9
					if pdc2->( lastrec() ) == 0
						Error( "No PDC's Entered" )
					else
						nRec := pdc2->( recno() )
						lmeron := .F.
						pdc2->( dbgotop() )
                  while ! pdc2->( eof() )
							if pdc2->tag
								lmeron := .T.
								exit
							endif
							pdc2->( dbskip(+1) )
						enddo
						pdc2->( dbgoto(nRec) )
						if lmeron
                     reportprint( "Print_PDC()","Letter size" )
						else
                     Error( "No PDC check selected" )
						endif
					endif

				case nKey == K_TAB ; case0500()
			endcase
		enddo
	end sequence
return nil

*******************************************************************************
static function Check_PDC( cCode )
	local lRet := .F.
	if ! empty(cCode)
		lRet := pdc_head->( dbSeek(cCode) )
		If !lRet
	       lRet := pdchdbck->( dbSeek(cCode) )
		EndIf
	endif
return lRet

*******************************************************************************
static function Find_PDC()
	local nRec := pdc1->( recno() )
	local lRet := .f., Result, lFound := .F.

	begin sequence
      if Get_Account( @mBrAccnt )
         if (m->TRUE_BRCH == "001")
			lFound := Check_PDC( mBrAccnt )
         else
            Result := do_cps( mBrAccnt, "check_pdc" )
			if empty(Result)
			   break
			endif
		    lFound := (Result == "T")
		 endif

		 if lFound
            nRec := Get_PDC( mBrAccnt )
			lRet := .T.
		 else
            if Yes_No2( " Account not found... ",,"  Add  ", " Cancel " )
			   lRet := .T.
			   aPDC[1] := mClient
			   aPDC[2] := mCName
			   aPDC[3] := mBrAccnt
               New_PDC(.F.)
			endif
		 endif
	  endif

	end sequence
	pdc1->( dbgoto(nRec) )

return lRet

*******************************************************************************
static function New_PDC( isNew )
	local lRet := .F., lOK := .F.
	local nRec := pdc1->( recno() )
	local getlist := {}

	SaveDetails(.T.); ShowData(.T.)
	if ! isNew
		mCCode	:= aPDC[1]
		mCName	:= aPDC[2]
		mBrAccnt := aPDC[3]
	endif
	mRecDate := date()
	center( 24, "w+/n","® Add Record ¯")
	while .T.
      rms_Set( "gr+/b, w+/g,,, gr+/b", 1 )
      @04,21 get mCCode   pict "@R 999-99-99999" when isNew valid v_client( @mCCode, @mCName )
		@04,36 get mCName   pict "@S40" when .f.
      @05,21 get mBrAccnt pict "@R 999-9999-99999-99999" when isNew valid chkacctno( isNew, @mBrAccnt, mCCode )
		@06,21 get mRecDate pict "@D"  valid !empty(mRecDate)
		@07,21 get mReciver pict "@K!" valid v_reciver(@mReciver, @mPName)
		@07,29 get mPName   pict "@!"  when .f.
		@08,21 get mRem1	  pict "@KS50"
		@09,21 get mRem2	  pict "@KS50"
		@10,21 get mRem3	  pict "@KS50"
		read
		SetCursor(0)
		if LastKey() == K_ESC
			if EscKey()
				exit
			endif
			loop
		endif

		if Confirm( "All entries correct?" )
			if !(m->TRUE_BRCH == "001")
            m->xStr := cToken("A")  + cToken(mBrAccnt) + cToken(mCCode) + ;
                   cToken(mRecDate) + cToken(mReciver) + cToken(mRem1) + ;
                   cToken(mRem2)    + cToken(mRem3)

            lOK := (do_cps(m->xStr, "PDC_UPD_head") == "T") // PDC_UPD_HEAD
			else
            lOK := PDC1_Update( .T. )
			endif
			if lOK
            nRec := Upd_PDC1()
				dep_araw := mRecDate  // this is for the over-all date recieved
				lRet := .T.
			endif
			exit
		endif
	enddo
	if ! lRet
		SaveDetails(.F.)
	endif
	pdc1->( dbgoto(nRec) )
	center( 24, "w+/n","               " )
return lRet

*******************************************************************************
static function Edit_PDC( pAccnt )
	local lRet := .F., lOK := .F.
	local getlist := {}

   if empty( pAccnt )
      Error( "Nothing to Edit!" )
		return nil
	endif

	center( 24, "w+/n","® Edit Record ¯")
	ShowData(.F.)
	while .T.
		setcolor( "gr+/b, w+/g,,, gr+/b" )
		@04,21 get mCCode   pict "@R 999-99-99999" when .F.
		@04,36 get mCName   pict "@S40" when .f.
		@05,21 get mBrAccnt pict "@R 999-9999-99999-99999" when .F.
		@06,21 get mRecDate pict "@D"  valid !empty(mRecDate)
		@07,21 get mReciver pict "@K!" valid v_reciver(@mReciver, @mPName)
		@07,29 get mPName   pict "@!"  when .f.
		@08,21 get mRem1	  pict "@KS50"
		@09,21 get mRem2	  pict "@KS50"
		@10,21 get mRem3	  pict "@KS50"
		setcursor(3)
		read
		SetCursor(0)
		if LastKey() == K_ESC
			if EscKey()
				exit
			endif
			loop
		endif

		if Confirm( "All entries correct?" )
			if !(m->TRUE_BRCH == "001")
            m->xStr := cToken("R") + cToken(mBrAccnt) + cToken(mCCode) + ;
                  cToken(mRecDate) + cToken(mReciver) + cToken(mRem1)  + ;
                  cToken(mRem2)    + cToken(mRem3)

            lOK := (do_cps(m->xStr, "PDC_UPD_HEAD") == "T")
			else
				lOK := PDC1_Update( .F. )
			endif
			if lOK
            Upd_PDC1()
				dep_araw := mRecDate  // this is for the over-all date recieved
				lRet := .T.
			endif
			exit
		endif
	enddo
	center( 24, "w+/n","               " )
return lRet

*******************************************************************************
static function PDC1_Update( isNew )
local curr := .t.
	if isNew
      pdc_head->( netlock("A", 0) )
	else
      if pdc_head->( dbseek(mBrAccnt), netlock("R", 0) )
	  elseif pdchdbck->( dbseek(mBrAccnt), netlock("R", 0) )
         curr := .f.
	  endif
	endif
	if curr
	   pdc_head->brcode	    := LEFT(mBrAccnt,  03)
	   pdc_head->acctno	    := RIGHT(mBrAccnt, 14)
	   pdc_head->clntcode   := RIGHT(mCCode,   07)
	   pdc_head->recdate    := mRecDate
	   pdc_head->receiver   := mReciver
	   pdc_head->rem1 	    := mRem1
	   pdc_head->rem2 	    := mRem2
	   pdc_head->rem3 	    := mRem3
       pdc_head->( dbCommit(), dbUnlock() )
	else
	   pdchdbck->brcode	    := LEFT(mBrAccnt,  03)
	   pdchdbck->acctno	    := RIGHT(mBrAccnt, 14)
	   pdchdbck->clntcode   := RIGHT(mCCode,   07)
	   pdchdbck->recdate    := mRecDate
	   pdchdbck->receiver   := mReciver
	   pdchdbck->rem1 	    := mRem1
	   pdchdbck->rem2 	    := mRem2
	   pdchdbck->rem3 	    := mRem3
       pdchdbck->( dbCommit(), dbUnlock() )
    endif
return .T.

*******************************************************************************
static function Upd_PDC1()
	select "pdc1" ; __dbzap()
	pdc1->( dbappend() )
	pdc1->brcode	:= r_encrypt(left(mBrAccnt, 3))
	pdc1->clntcode := r_encrypt(right(mCCode, 7))	 // mClient
	pdc1->acctno	:= r_encrypt(right(mBrAccnt, 14)) // mAcctno
	pdc1->recdate	:= mRecDate
	pdc1->receiver := r_encrypt(mReciver)
	pdc1->valdate	:= mValDate
	pdc1->rem1		:= r_encrypt(mRem1)
	pdc1->rem2		:= r_encrypt(mRem2)
	pdc1->rem3		:= r_encrypt(mRem3)

   acct->( dbSeek(mBrAccnt) )
	pdc1->valdate1 := acct->valdate
	pdc1->term		:= acct->term
	pdc1->termunit := acct->termunit
	pdc1->matdate	:= acct->matdate
	pdc1->credamt	:= acct->credamt
return pdc1->( dbcommit(), recno() )


*******************************************************************************
static function PDC1_Delete( mCode )
	if empty(mCode)
		Error( "Nothing to Delete!" )
		return nil
	endif

	if Confirm( "Delete Acct N§ "+tran( mBrAccnt, "@R 999-9999-99999-99999" )+" ?" )
		if ! (m->TRUE_BRCH == "001")
         if do_cps(mBrAccnt, "PDC_DEL_HEAD") == "T"
				select "pdc1" ; __dbZap()
			endif
		else
			if pdc_dtls->( dbseek(mCode) )
				while !pdc_dtls->( eof() ) .AND. (pdc_dtls->brcode+pdc_dtls->acctno == mCode)
               pdc_dtls->( netlock("R", 0), dbDelete(), dbUnlock(), dbSkip() )
				enddo
				pdc_dtls->( dbCommit() )
			elseif pdcdtbck->( dbseek(mCode) )
				while !pdcdtbck->( eof() ) .AND. (pdcdtbck->brcode+pdcdtbck->acctno == mCode)
                       pdcdtbck->( netlock("R", 0), dbDelete(), dbUnlock(), dbSkip() )
				enddo
				pdcdtbck->( dbCommit() )
			endif
			
            pdc_head->( dbSeek(mCode), netlock("R", 0), dbDelete(), dbcommit(), dbunlock() )
			if pdchdbck->( dbSeek(mCode))
			   if pdchdbck->( netlock("R", 0))
			      pdchdbck->(dbDelete())
                  pdchdbck->(dbUnlock())
                  pdchdbck->(dbCommit())
			   endif
			endif

			select "pdc1" ; __dbZap()
		endif
	endif
return nil

*******************************************************************************
function Print_PDC()
   local nLast := pdc2->( recno() )
   local mu := 1, aInfo[05]
	local mVALDATE, mTERM, mTERMUNIT, mMATDATE, mCREDAMT
	local nrow_:={ 1,5,31,47,62,73 }

   mVALDATE  := r_decrypt(pdc1->valdate1)
	mTERM 	 := val(r_decrypt(pdc1->term))
	mTERMUNIT := r_decrypt(pdc1->termunit)
	mMATDATE  := r_decrypt(pdc1->matdate)
	mCREDAMT  := val(r_decrypt(pdc1->credamt))

   prnreptitle( 80,2,1,"Acknowledgment Receipt", "User : " + m->g_USER_ID, m->gSYS_NAME, m->gCOMPANY )
	*prnreptitle( 80,0,1,"Acknowledgment Receipt", "Program ID:AMSM0500", m->gSYS_NAME, m->gCOMPANY )
	@ prow()+2, 2 say "Account Number : " + Trans(mBrAccnt,"@R 999-9999-99999-99999" )
   @ prow()+1, 2 say "Execution Date : " + mVALDATE + space(16) + "Term          : " +;
		trans(mTERM,"999") + " " + if(mTERMUNIT="1","Days",if(mTERMUNIT="2","Months","Years"))
	@ prow()+1, 2 say "Maturity Date  : " + mMATDATE + space(16) + "Credit Amount : " + trans(mCREDAMT,"99,999,999,999.99")

	@ prow()+2, 2 say "Received from "+ alltrim(mCName) +" the following checks"
	@ prow()+1, 2 say "For deposit to the account of ORIX upon due date."
	@ prow()+2, 5 say "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ"
	setfont("BOLD")
	@ prow()+1, 5 say "Drawee Bank               Check No.        Amount        Check Date Due Date "
	Setfont("UNBOLD")
	@ prow()+1, 5 say "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ"
                    * 56789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 12345

	pdc2->( dbgotop() )
   while !pdc2->( eof() )
		if pdc2->tag
         @ prow()+1,nrow_[1] say tran( mu++, "999" )
			@ prow()  ,nrow_[2] say r_decrypt(pdc2->Bank)
			@ prow()  ,nrow_[3] say r_decrypt(pdc2->Chkno)
			@ prow()  ,nrow_[4] say trans( val(r_decrypt(pdc2->Chkamt)),"999,999,999.99" )
			@ prow()  ,nrow_[5] say dtoc( pdc2->Chkdate )
			@ prow()  ,nrow_[6] say dtoc( pdc2->Depdate )
		endif
		pdc2->( dbskip() )
	enddo

   @ prow()+1,05 say padc("******** Nothing Follows ******** ", 65 )
   @ prow()+2,30 say "Received By : "
   @ prow()+1,44 say mPName
   @ prow()+2,05 say "Remarks : " + mRem1
   @ prow()+1,15 say mRem2
   @ prow()+1,15 say mRem3
	__eject()
   pdc2->( dbGoto(nLast) )
return nil

*******************************************************************************
static function v_reciver( cCode, cName )
   local aFlds, xBrch := ! (m->TRUE_BRCH == "001")
   local isOK := .F.

	begin sequence
					  *  header 	fields	  pict  size  decrypt
		aFlds := { { "Code",   "Initials", "@!", 06, xBrch },;
					  { "Name",   "fullname", "@!", 35, xBrch },;
					  { "Branch", "brcode",   "@!", 06, xBrch } }

		if PERSONEL->( dbseek(cCode, .T.) ) .OR. ;
			ABrowse( 07,26,21,"PERSONEL",1, aFlds," Select Receiver " )

			if ! (m->TRUE_BRCH == "001")
				cCode := r_decrypt(PERSONEL->initials)
				cName := r_decrypt(PERSONEL->fullname)
			else
				cCode := PERSONEL->initials
				cName := PERSONEL->fullname
			endif

         isOK := .T.
		endif
	end sequence
return isOK

*******************************************************************************
static function case0500()
   local nKey, nLast

	if empty(mBrAccnt)
		return nil
	endif

   StatLine( " ~INS~-Add ~F2~-Edit ~F4~-Search ~Tab~-Header ~Del~-Delete " )
   spChar( 04,00,11,21, "w/n,w+/w", "°Û" )
   while .T.
		dispbegin()
		select "pdc2"
		oTB:forcestable()
		dispend()
      nKey := Thighlight( oTB, oTB:rowpos, oTB:colpos, oTB:colpos )
		do case
         case TNavigate( oTB, nKey )

			case nKey == K_TAB ; exit

			case nKey == K_ALT_A
            nLast := pdc2->( recno() )
				pdc2->( dbgotop() )
				while ! pdc2->( eof() )
					pdc2->tag := ! pdc2->tag
					pdc2->( dbskip() )
				enddo
            pdc2->( dbGoto(nLast) )
				oTB:forcestable():refreshall()

			case nKey == K_SPACE
				pdc2->tag := ! pdc2->tag
				oTB:refreshcurrent()

			case nKey == K_INS
            if chkpass("A", m->AX_LEVEL, m->g_USER_ID)
					upd_detail( .T., pdc2->bank, pdc2->chkamt )
				endif

			case nKey == K_F2
            if chkpass("E", m->AX_LEVEL, m->g_USER_ID)
               upd_detail( .F., pdc2->bank, pdc2->chkamt )
				endif

			case nKey == K_F4
            if chkpass("S", m->AX_LEVEL, m->g_USER_ID)
               Find_Detail( oTB )
				endif

			case nKey == K_DEL
            if chkpass("D", m->AX_LEVEL, m->g_USER_ID)
               Del_detail( oTB )
				endif
		endcase
	enddo
   StatLine( " ~INS~-Add ~F2~-Edit ~F4~-Search ~F9~-Print ~Tab~-Details ~Del~-Delete ~ESC~-Exit " )
   spChar( 04,00,11,21, "w+/w,w/n", "Û°" )
return nil

*******************************************************************************
static function Find_Detail( oBr )
   local uDate := ctod("//")
	local getlist := {}

	begin sequence
		Desktop(.T.)
      Box3( 11, 12, 2, 26, "n/w" )
      rms_set( "n/w, w+/n,,, gr+/w", 1 )
      @ 12,14 say "Check Date " get uDate pict "@D"
		read
      if lastkey() == 27
			break
		endif
      pdc2->( dbSeek(dtos(uDate), .T.) )
	end sequence
	Desktop(.F.)
   oBr:refreshAll():forcestable()
return nil

*******************************************************************************
static function Del_detail( oBr )
	local lOK := .F.

   if pdc2->recnum == 0
      return nil
   endif

	if Confirm("Delete Check N§: " + trim(r_decrypt(pdc2->chkno)) + "?")
       if ( m->TRUE_BRCH == "001" )
          lOK := pdc_dtls->( dbGoto(pdc2->recnum), netlock("R", 0), ;
                            dbDelete(), dbcommit(), dbunlock(), .T. )
          lOK := pdcdtbck->( dbGoto(pdc2->recnum), netlock("R", 0), ;
                             dbDelete(), dbcommit(), dbunlock(), .T. )
       else
		  lOK := (do_cps( alltrim(str(pdc2->recnum)), "pdc_del_dtls" ) == "T")
	   endif
	   if lOK .AND. pdc2->( dbdelete(), dbcommit(), dbskip(), eof() )
		  pdc2->( dbgobottom() )
	   endif
       oBr:refreshAll()
	endif
return nil

*******************************************************************************
static function upd_detail( isNew, mdraw1, chk_amt )
   local sw:=.F., getlist := {}
   local nLast := pdc2->(recno()), nday:=0, xday:=0
	local aChkList  := { "1 = Local      ","2 = Regional   ","3 = Out-Of-Town" }
   local aStatList := { "1 = Active   ","2 = Hold     ","3 = Deposited"}
   local nH, cFile, aDtls[11], lchkno

   if ! isNew .and. pdc2->recnum == 0
      return nil
   endif

	Desktop(.T.)
	if isNew
		pdc2->( dbgoto(0) )
		center( 24, "w+/n", " ® Add Details ¯" )
	else
		center( 24, "w+/n", "® Edit Details ¯" )
	endif

   aDtls[01] := pdc2->recnum
   aDtls[02] := r_decrypt(if(!empty(mdraw1), mdraw1, pdc2->bank))
   aDtls[03] := r_decrypt(pdc2->chktype)
   aDtls[04] := r_decrypt(pdc2->chkno)
   aDtls[05] := iif(isNew, date(), pdc2->chkdate)
   aDtls[06] := iif(isNew, date(), pdc2->depdate)
   aDtls[07] := val(r_decrypt(if(!empty(chk_amt), chk_amt, pdc2->chkamt)))
   aDtls[08] := r_decrypt(pdc2->status)

   Box3( 11, 29, 9, 43, "n/gr" )

   dispText( 13,58, disp_check(aDtls[03]), "bg/gr" )
   dispText( 18,58, chk_status(aDtls[08]), "bg/gr" )
   aDtls[09] := 1
   aDtls[10] := if(isNew, Confirm( "Multiple entry of checks?" ), .F. )
   aDtls[11] := if(aDtls[10], Confirm("Ascending <Yes>?"), .F. )

   while .T.
      rms_Set( "w/gr, n/w,,, w+/gr", 1 )
      @12,30 say " Drawee Bank  " get aDtls[02]  picture "@!X" valid !empty(aDtls[02])
      @13,30 say "  Check Type  " get aDtls[03]  picture "@X" when selchktype(aChkList, aDtls, 13) valid aDtls[03] $ "123"
      @14,30 say "    Check N§  " get aDtls[04]  picture "@X" valid !empty(aDtls[04])
      @15,30 say "  Check Date  " get aDtls[05]  picture "@D" valid !empty(aDtls[05])
      @16,30 say "Deposit Date  " get aDtls[06]  picture "@D" valid v_date(aDtls)
      @17,30 say "Check Amount  " gget aDtls[07] calculator   picture "99,999,999.99" valid (aDtls[07] > 0)
      @18,30 say "      Status  " get aDtls[08]  picture "9"   when selchkSTAT(aStatList, aDtls, 18) valid aDtls[08] $ "123"
      @19,30 say "No. of Checks " get aDtls[09]  picture "999" when aDtls[10]
		read
		SetCursor(0)
		if LastKey() == K_ESC
			if EscKey()
				exit
			endif
			loop
		endif

		if Confirm( "Are all entries correct?" )
         lchkno := len(alltrim(aDtls[04]))
         xday := day(aDtls[05]) // chkdate
         nday := day(aDtls[06]) // depdate

         if !(m->TRUE_BRCH == "001")
            cFile := r_tempfile( m->g_AMS_PATH, "TXT" )
            nH := FCreate( cFile, 0 )
         endif
         while aDtls[09] > 0
				if isNew
               pdc2->( dbAppend() )
				endif
            aDtls[05] := getdep( aDtls[05], sw, xday )
            aDtls[06] := getdep( aDtls[06], sw, nday )

            pdc2->bank    := r_encrypt(aDtls[02])
            pdc2->chktype := r_encrypt(aDtls[03])
            pdc2->chkno   := r_encrypt(aDtls[04])
            pdc2->chkdate := aDtls[05]
            pdc2->depdate := aDtls[06]
            pdc2->chkamt  := r_encrypt(str(aDtls[07],12,2))
            pdc2->status  := r_encrypt(aDtls[08])
				pdc2->( dbcommit() )

            if ! (m->TRUE_BRCH == "001")
               FWrite(nH, str(pdc2->recnum, 9) + "~" + ;
						left(mBrAccnt,3)			 + "~" + ;
						right(mBrAccnt,14)		 + "~" + ;
						r_decrypt(pdc2->bank)	 + "~" + ;
						r_decrypt(pdc2->chktype) + "~" + ;
						r_decrypt(pdc2->chkno)	 + "~" + ;
						dtoc(pdc2->chkdate)		 + "~" + ;
						dtoc(pdc2->depdate)		 + "~" + ;
						r_decrypt(pdc2->chkamt)  + "~" + ;
						r_decrypt(pdc2->status)  + "~" + ;
						str(pdc2->(recno()), 9)  + "~" + chr(13) + chr(10) )
				else
               PDC2_Update()
				endif
            aDtls[09]--
				sw := .T.
            aDtls[04] := val(aDtls[04]) + if(aDtls[11], 1, -1)
            if len(alltrim(str(aDtls[04]))) > lchkno
               lchkno++
            endif
            aDtls[04] := strzero(aDtls[04], lchkno)
			enddo
         nLast := pdc2->( recno() )
			if !(m->TRUE_BRCH == "001")
				FClose(nH)
            Scatter( cFile )
			else
				pdc_dtls->( dbcommit() )
			endif
			exit
		endif
	enddo
	Desktop(.F.)

	select "pdc2"
   pdc2->( dbgoto(nLast) )
   oTB:forcestable():refreshall()
return nil

*******************************************************************************
static function Scatter( cFile )
	local nRec := pdc2->( recno() )
	local cText, cFile2, nH

	cFile2 := do_cps( cFile, "pdc_upd_dtls" )
	cFile2 := CopyFile(cFile2)
	if (nH := FOpen(cFile2, 0)) == -1
      Error( cFile+" not found...")
      return nil
	endif
	FSeek(nH, 0)
	While .T.
		cText := FReadStr(nH, 22)
		if cText == ""
			Exit
		endif
		cText := rms_Parse( cText, "~" )
		nRec := val(alltrim(cText[1]))
		pdc2->( dbgoto( val(cText[2]) ) )
      pdc2->recnum := nRec
   enddo
   pdc2->( dbcommit() )
   CloseFile(nH, cFile2)
return nRec

*******************************************************************************
static function PDC2_Update()
local curr := .t.
	if pdc2->recnum == 0
	  if pdc_head->(dbseek(mBrAccnt))
         pdc_dtls->( netlock("A", 0) )
	  else
	     pdcdtbck->( netlock("A", 0) )
		 curr := .f.
	  endif
	else
	  if pdc_dtls->(dbseek(mBrAccnt))
	     pdc_dtls->( dbGoto(pdc2->recnum), netlock("R", 0) )
	  elseif pdcdtbck->(dbseek(mBrAccnt))
	     pdcdtbck->( dbGoto(pdc2->recnum), netlock("R", 0) )
		 curr := .f.
	  endif
	endif
	
	if curr
		pdc_dtls->brcode	:= left(mBrAccnt, 03)
		pdc_dtls->acctno	:= right(mBrAccnt, 14)
		pdc_dtls->bank 	:= r_decrypt(pdc2->bank)
		pdc_dtls->chktype  := r_decrypt(pdc2->chktype)
		pdc_dtls->chkno	:= r_decrypt(pdc2->chkno)
		pdc_dtls->chkdate  := pdc2->chkdate
		pdc_dtls->depdate  := pdc2->depdate
		pdc_dtls->chkamt	:= val( alltrim(r_decrypt(pdc2->chkamt)) )
		pdc_dtls->status	:= r_decrypt(pdc2->status)
		pdc_dtls->( dbUnlock() )
		pdc_dtls->( dbCommit() )
	else
		pdcdtbck->brcode	:= left(mBrAccnt, 03)
		pdcdtbck->acctno	:= right(mBrAccnt, 14)
		pdcdtbck->bank 	:= r_decrypt(pdc2->bank)
		pdcdtbck->chktype  := r_decrypt(pdc2->chktype)
		pdcdtbck->chkno	:= r_decrypt(pdc2->chkno)
		pdcdtbck->chkdate  := pdc2->chkdate
		pdcdtbck->depdate  := pdc2->depdate
		pdcdtbck->chkamt	:= val( alltrim(r_decrypt(pdc2->chkamt)) )
		pdcdtbck->status	:= r_decrypt(pdc2->status)
		pdcdtbck->( dbUnlock() )
		pdcdtbck->( dbCommit() )
	endif

	if pdc2->recnum == 0
	   if curr
	      pdc2->recnum := pdc_dtls->( recno() )
	   else
	      pdc2->recnum := pdcdtbck->( recno() )
	   endif
	endif
return nil

*******************************************************************************
static function getdep( date1, sw, nday )
	local nyear := year( date1 )
	local nmonth:= month( date1 )
	local xday	:= 0
	local rday_ := { 31,28,31,30,31,30,31,31,30,31,30,31 }

   if ! sw
		return date1
	endif

	nmonth:= month(date1) + 1
	nyear := year(date1)

	if nmonth > 12
		nmonth := 1
		nyear := nyear + 1
	endif

	if nday > 30
		nday := rday_[ nmonth ]
	endif

	if nday >= 28 .AND. nmonth == 2
		if ( nyear % 4 ) == 0
			nday := 29
		else
			nday := 28
		endif
	endif

	xday	:= nday
	date1 := ctod( "'"+str(nmonth,2) + "/"+ str(xday,2)+ "/" + str(nyear,4) + "'")
return date1

*********************************************************
static function selchktype(aChkList, aData, mROW)
	local mLIST := { "Local       ", "Regional    ", "Out-of-Town" }

   aData[03] := gen_achoice( aChkList, val( aData[03] ), "Check Type", 14, 56, 17, 77, "W/GR+,W/N,,,W/GR+" )
   @ mROW, 58 say padr( mLIST[ val(aData[03] ) ], 12 ) color "bg/gr"
return .F.

*******************************************************************************
static function selchkSTAT(aStatList, aData, mROW)
	local mLIST := { "Active", "Hold", "Deposited" }

   aData[08] := gen_achoice( aStatList, val(aData[08]), "status", 16, 56, 19, 77, "W/GR+,W/N,,,W/GR+" )
   @ mROW, 58 say padr( mLIST[ val(aData[08]) ], 12 ) color "bg/gr"
return .F.

*******************************************************************************
static function v_date( aData )
	local lRet := .T.

   if aData[05] > aData[06]
		Error("Check Date must be < to Deposit Date!")
		lRet := .F.
	endif
return lRet

*******************************************************************************
static function disp_check(cCheck)
	local aList := space(12) +"Local       "+"Regional    "+"Out-Of-Town "
return substr(aList, val(cCheck) * 12 + 1, 12)

*******************************************************************************
static function chk_status(cStat)
	local aList := space(9)+"Active   "+"Hold     "+"Deposited"
return substr(aList, val(cStat) * 9 + 1, 9)

*******************************************************************************
static function Get_PDC( mAccount )
   local nRec := pdc1->( recno() )
   local nH, cFile, cText

	begin sequence
		if ! (m->TRUE_BRCH == "001")
         if (cFile := do_cps(mAccount, "GET_PDC")) == ""
            break
         endif

			cFile := CopyFile( cFile )
			nH := FOpen( cFile, 0 )
			FSeek(nH, 0)
			cText := FReadStr(nH, 240)
			cText := rms_Parse( cText, "~" )

			select "pdc1" ; __dbzap()
			pdc1->( dbappend() )
			pdc1->brcode	:= r_encrypt(cText[1])
			pdc1->clntcode := r_encrypt(cText[2])
			pdc1->acctno	:= r_encrypt(cText[3])
			pdc1->recdate	:= ctod(cText[4])
			pdc1->receiver := r_encrypt(cText[5])
			pdc1->valdate	:= ctod(cText[6])
			pdc1->rem1		:= r_encrypt(cText[7])
			pdc1->rem2		:= r_encrypt(cText[8])
			pdc1->rem3		:= r_encrypt(cText[9])

         acct->( dbSeek(mAccount) )
			pdc1->valdate1 := acct->valdate
			pdc1->term		:= acct->term
			pdc1->termunit := acct->termunit
			pdc1->matdate	:= acct->matdate
			pdc1->credamt	:= acct->credamt
			nRec := pdc1->( dbcommit(), recno() )

			select "pdc2" ; __dbzap()
         while .T.
            cText := FReadStr(nH, 112)
				if cText == ""
					exit
				endif
				cText := rms_Parse( cText, "~" )
				pdc2->( dbappend() )
				pdc2->recnum  := val(alltrim(cText[1]))
				*pdc2->brcode	:= r_encrypt(cText[2])
				*pdc2->acctno	:= r_encrypt(cText[3])
				pdc2->bank	  := r_encrypt(cText[4])
				pdc2->chktype := r_encrypt(cText[5])
				pdc2->chkno   := r_encrypt(cText[6])
				pdc2->chkdate := ctod(cText[7])
				pdc2->depdate := ctod(cText[8])
				pdc2->chkamt  := r_encrypt(cText[9])
				pdc2->status  := r_encrypt(cText[10])
			enddo
			pdc2->( dbcommit() )
         CloseFile(nH, cFile)
		else
			select "pdc1" ; __dbzap()
			pdc_head->( dbSeek(mAccount) )
			pdc1->( dbappend() )
			pdc1->brcode	:= r_encrypt(pdc_head->brcode)
			pdc1->clntcode := r_encrypt(pdc_head->clntcode)
			pdc1->acctno	:= r_encrypt(pdc_head->acctno)
			pdc1->recdate	:= pdc_head->recdate
			pdc1->receiver := r_encrypt(pdc_head->receiver)
			pdc1->valdate	:= pdc_head->valdate
			pdc1->rem1		:= r_encrypt(pdc_head->rem1)
			pdc1->rem2		:= r_encrypt(pdc_head->rem2)
			pdc1->rem3		:= r_encrypt(pdc_head->rem3)
			
			if pdchdbck->( dbSeek(mAccount) )  //From PDC_HEAD BACK
			   pdc1->( dbappend() )
			   pdc1->brcode	    := r_encrypt(pdchdbck->brcode)
			   pdc1->clntcode   := r_encrypt(pdchdbck->clntcode)
			   pdc1->acctno	    := r_encrypt(pdchdbck->acctno)
			   pdc1->recdate	:= pdchdbck->recdate
			   pdc1->receiver   := r_encrypt(pdchdbck->receiver)
			   pdc1->valdate	:= pdchdbck->valdate
			   pdc1->rem1		:= r_encrypt(pdchdbck->rem1)
			   pdc1->rem2		:= r_encrypt(pdchdbck->rem2)
			   pdc1->rem3		:= r_encrypt(pdchdbck->rem3)
			endif
			

         acct->( dbSeek(mAccount) )
         pdc1->valdate1 := acct->valdate
			pdc1->term		:= acct->term
			pdc1->termunit := acct->termunit
			pdc1->matdate	:= acct->matdate
			pdc1->credamt	:= acct->credamt
			nRec := pdc1->( dbcommit(), recno() )

			select "pdc2" ; __dbzap()
			pdc_dtls->( dbSeek(mAccount) )
			while !pdc_dtls->( eof() ) .and. pdc_dtls->brcode+pdc_dtls->acctno == mAccount
				pdc2->( dbappend() )
				pdc2->recnum  := pdc_dtls->( recno() )
				pdc2->bank	  := r_encrypt(pdc_dtls->bank)
				pdc2->chktype := r_encrypt(pdc_dtls->chktype)
				pdc2->chkno   := r_encrypt(pdc_dtls->chkno)
				pdc2->chkdate := pdc_dtls->chkdate
				pdc2->depdate := pdc_dtls->depdate
				pdc2->chkamt  := r_encrypt(str(pdc_dtls->chkamt, 12, 2))
				pdc2->status  := r_encrypt(pdc_dtls->status)
				pdc_dtls->( dbskip() )
			enddo

			if pdcdtbck->( dbSeek(mAccount) )     //From PDC_DTLS BACK
			   while !pdcdtbck->( eof() ) .and. pdcdtbck->brcode+pdcdtbck->acctno == mAccount
				   pdc2->( dbappend() )
				   pdc2->recnum  := pdcdtbck->( recno() )
				   pdc2->bank	 := r_encrypt(pdcdtbck->bank)
				   pdc2->chktype := r_encrypt(pdcdtbck->chktype)
				   pdc2->chkno   := r_encrypt(pdcdtbck->chkno)
				   pdc2->chkdate := pdcdtbck->chkdate
				   pdc2->depdate := pdcdtbck->depdate
				   pdc2->chkamt  := r_encrypt(str(pdcdtbck->chkamt, 12, 2))
				   pdc2->status  := r_encrypt(pdcdtbck->status)
			   pdcdtbck->( dbskip() )
			   enddo
			endif
			pdc2->( dbcommit() )
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

*******************************************************************************
static function chkacctno( isNew, mCode, mClient )
	local lRet := .F., lFound := .F.
	local nRec := pdc1->( recno() )

	begin sequence
		if lastkey() == K_UP
			lRet := .T. ; break
		endif

		if ! acct->( dbSeek(mCode, .F.) )
			if ! v_account( @mCode, mClient )
				break
			endif
		endif

      if (m->TRUE_BRCH == "001")
         lFound := ( isNew .AND. Check_PDC( mCode ) )
      else
         lFound := ( isNew .AND. do_cps( mCode, "CHECK_PDC" ) == "T" )
		endif

		if lFound
			Error("Account N§ already exist!" )
			break
		endif

      *mCode := r_decrypt(acct->brcode+acct->acctno)
		lRet := .T.
	end sequence
	if ! lRet
		mCode := space(17)
	endif
   pdc1->( dbgoto(nRec) )
return lRet

*******************************************************************************
static function v_account( mAccnt, mClient )
   local cFile, nH, cKey, cText, xAcc, xParam
	local mar, mposition := 0, mlog := {}, lRet := .F.

	__Keyboard()
	if ! (m->TRUE_BRCH == "001")
      xParam := cToken(mClient) + cToken("1")
      if (cFile := do_cps(xParam, "GET_ACCOUNT" )) == ""
			return lRet
		endif
		cFile := CopyFile(cFile)
		dbselectarea( "acct" ) ; __dbZap()

		// Put Text to DBF
		nH := FOpen( cFile, 0 )
		FSeek( nH, 0 ) // top of file
		while .T.
			cText := FReadStr(nH, 104 )
			if cText == ""
				exit
			endif
			cText := rms_Parse( cText, "~" )
         if acct->( dbseek(cText[1]+ctext[3]) )
            loop
         endif
			acct->( dbappend() )
			acct->brcode	:= r_encrypt(cText[1])
			acct->clntcode := r_encrypt(cText[2])
			acct->acctno	:= r_encrypt(cText[3])
			acct->status	:= r_encrypt(cText[4])
			acct->oldno 	:= r_encrypt(cText[5])
			acct->docref	:= r_encrypt(iif( cText[6] == "1", "CA ", "OT " ))
			acct->refno 	:= r_encrypt(cText[1])+"-"+r_encrypt(cText[7])
			acct->valdate	:= r_encrypt(cText[8])
			acct->term		:= r_encrypt(cText[9])
			acct->termunit := r_encrypt(cText[10])
			acct->matdate	:= r_encrypt(cText[11])
			acct->credamt	:= r_encrypt(cText[12])
			acct->source	:= cText[13]
		enddo
      CloseFile(nH, cFile )
	else
		dbselectarea( "acct" ) ; __dbZap()
		Fill_Acct( "M", mClient ) // acctmast
		Fill_Acct( "D", mClient ) // acctdaly
      Fill_Acct( "P", mClient ) // pdc_head
	endif
	dbselectarea( "acct" )  ; acct->( dbgotop() )

	begin sequence
		if acct->( lastrec() ) == 0
			Error( "Account NOT Found!" )
			break
		endif

		mar := { "    Client N§  " + tran(mClient, "@R 999-99-99999" ) ,;
			"  Client Name  " + left(mCName, 40),;
			repl( "Ä", 68 ),;
			"       Acct. N§         status     Old Acct. No.       Ref. No.",;
			repl( "Ä", 68 ) }

      acct->( dbeval( {|| aadd( mar, " " + ;
			trans( r_decrypt(acct->brcode+acct->acctno), "@R 999-9999-99999-99999")+;
         space(2)+substr(upper(accnt_stat(r_decrypt(acct->status))), 1, 12) +;
			r_decrypt(acct->oldno) + r_decrypt(acct->docref) + r_decrypt(acct->refno)) +" "},, ;
         {|| r_decrypt(acct->brcode+acct->clntcode) == mClient .AND. ! acct->( eof() ) }) )

      if len(mar) > 1
			mlog := aclone( mar )
			aeval ( mlog, { | l, c | mlog[ c ] := if( c <= 5, .F., .T. ), c } )
			mposition := val( gen_achoice( mar, 6, "Search Account", mlog ) )
		endif

		if lastkey() != K_ESC .and. mposition > 0
         mAccnt := substr(ltrim(mar[mPOSITION]),1,3) + ;
                   substr(ltrim(mar[mPOSITION]),5,4) + ;
                   substr(ltrim(mar[mPOSITION]),10,5) + ;
                   substr(ltrim(mar[mPOSITION]),16,5)
         lRet := .T.
		endif

	end sequence
return lRet

*******************************************************************************
static function Fill_Acct( cSource, mCode )
	local xAcc

   if cSource == "P"
      select "pdc_head" ; ordsetfocus(2)
      xAcc := "pdc_head"
      (xAcc)->( dbseek(mCode) )
      while ! (xAcc)->( eof() ) .AND. (xAcc)->brcode+(xAcc)->clntcode == mCode
         if ! acct->( dbSeek(pdc_head->brcode+pdc_head->acctno) )
            acct->( dbappend() )
            acct->brcode   := r_encrypt( (xAcc)->brcode )
            acct->clntcode := r_encrypt( (xAcc)->clntcode )
            acct->acctno   := r_encrypt( (xAcc)->acctno )
            acct->source   := cSource
         endif
         (xAcc)->( dbSkip() )
      enddo
      select "pdc_head" ; ordsetfocus(1)
   else
      xAcc := if(cSource == "M", "acctmast", "acctdaly")
      (xAcc)->( dbseek(mCode) )
      while ! (xAcc)->( eof() ) .AND. (xAcc)->brcode+(xAcc)->clntcode == mCode

         acct->( dbappend() )
         acct->brcode   := r_encrypt( (xAcc)->brcode )
         acct->clntcode := r_encrypt( (xAcc)->clntcode )
         acct->acctno   := r_encrypt( (xAcc)->acctno )
         acct->status   := r_encrypt( (xAcc)->status )
         acct->oldno    := r_encrypt( if(cSource == "M", (xAcc)->oldno, space(20)) )
         acct->docref   := r_encrypt( iif( (xAcc)->docref == "1", "CA ", "OT " ) )
         acct->refno    := r_encrypt( (xAcc)->brcode )+"-"+r_encrypt( (xAcc)->refno )
         acct->valdate  := r_encrypt( dtoc((xAcc)->valdate) )
         acct->term     := r_encrypt( str((xAcc)->term, 3) )
         acct->termunit := r_encrypt( (xAcc)->termunit )
         acct->matdate  := r_encrypt( dtoc((xAcc)->matdate) )
         acct->credamt  := r_encrypt( str((xAcc)->credamt, 12, 2) )
         acct->source   := cSource
         (xAcc)->( dbSkip() )
      enddo
   endif
return nil
