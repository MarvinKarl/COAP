*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
*³ Orix Metro Leasing and Finance                                            ³Û
*³ Account Management System                                                 ³Û
*ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Û
*³ Program ID...: AMS_FUNC.PRG                                               ³Û
*³ Description..:                                                            ³Û
*³ Author...... : Ronnie M. Salvatierra                                      ³Û
*³ Date.........: 01/06/11      07:48:02am                                   ³Û
*ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Û
*³                        U P D A T E S                                      ³Û
*ÃÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Û
*³  Who  ³ When        ³ Why                                                 ³Û
*ÃÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Û
*³       ³ DD-MMM-YYYY ³                                                     ³Û
*ÀÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙÛ
*  ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

#include "inkey.ch"
#include "common.ch"
#include "rms.ch"

*******************************************************************************
FUNCTION __PHeader2( nPage, cReptID, nW, nLeft, cFont, cSysID, cUsrID, cCompID )

   DEFAULT nLeft   := 0
   DEFAULT cSysID  := m->gSYS_NAME
   DEFAULT cUsrID  := m->gUSER_ID
   DEFAULT cCompID := m->gCOMPANY

	setPRC(0,0)
	@ prow()+1,nLeft say cFont + PADR(cSysID, nW - 20) + ;
								PADL( "Page : " + transf( nPage, "9999" ), 20 )
   @ prow()+1,nLeft say cReptID //+ "-" + cUsrID
	@ prow()+0,nW-20 say PADL( rs_Now(), 20 )
	@ prow()+1,nLeft say padc(cCompID, nW)
RETURN NIL

*******************************************************************************
init function deltemp1()
	public pTemp

	m->pTemp := ".\"
return nil

*******************************************************************************
exit function deltemp2()
   if !(m->TRUE_BRCH == "001")
      *Erase_Temp()
      tempErase()
   endif
	__MClear()
return nil

*******************************************************************************
function openList( aList )
   local i

   for i := 1 to len(aList)
      if ! open_if( aList[i] )
         return .f.
      endif
   next i
return .t.

*******************************************************************************
function open_if( cAlias )
   local isOK := .F.

   cAlias := alltrim(upper(cAlias))
   begin sequence
      do case
         /* AMS Data */
         case cAlias == "AXMAST"
            if ! NetUse("&g_AMS_PATH\AXMAST",.f.,5 )
               break
            endif
            Set_Index( m->g_AMS_PATH, { "USER_ID" } )

         case cAlias == "PDC_HEAD"
            if !NetUse( "&g_AMS_PATH\pdc_head",.F.,5 )
               break
            endif
            Set_Index( m->g_AMS_PATH, { "pdc_head", "pdc_clnt", "pdc_hdrt", "pdcrevac", "pdc_val" })
            ** pdc_head.ntx     // brcode+acctno
            ** pdc_clnt.ntx     // brcode+clntcode
            ** pdc_hdrt.ntx     // brcode+substr(acctno,-5,5)
            ** pdcrevac.ntx     // dtos(recdate)+brcode+acctno
            ** pdc_val .ntx     // dtos(recdate)+str(day(valdate),2)

         case cAlias == "PDC_DTLS"
            if !NetUse( "&g_AMS_PATH\pdc_dtls",.F.,5)
               break
            endif
            Set_Index( m->g_AMS_PATH, { "pdc_dtls", "pdc_date", "pdcdchk", "pdcdeptl", "pdc_ornm", "pdc_stat" })
            ** pdc_dtls.ntx      // brcode+acctno+dtos(chkdate)
            ** pdc_date.ntx      // brcode+dtos(depdate)
            ** pdcdchk .ntx      // brcode+acctno+chkno
            ** pdcdeptl.ntx      // depdate
            ** pdc_ornm.ntx      // brcode+ornumber
            ** pdc_stat.ntx      // brcode+status+acctno+dtos(depdate)

         case cAlias == "ACCTMAST"
            if !NetUse( "&g_AMS_PATH\Acctmast",.F.,5 )
               break
            endif
            Set_Index( m->g_AMS_PATH, { "acctclnt", "acctmast" } )
            *acctclnt // brcode+clntcode+acctno
            *acctmast // brcode+acctno

         case cAlias == "ACCTDALY"
            if !NetUse( "&g_AMS_PATH\acctdaly",.F.,5 )
               break
            endif
            Set_Index( m->g_AMS_PATH, {"accdclnt"} ) // brcode+acctno

         case cAlias == "DELQHEAD"
            if !Netuse( "&g_AMS_PATH\delqhead",.F.,5 )
               break
            endif
            Set_Index( m->g_AMS_PATH, { "delqhead" } ) // brcode+acctno

         case cAlias == "DELQDTLS"
            if !Netuse( "&g_AMS_PATH\delqdtls",.F.,5)
               break
            endif
            Set_Index( m->g_AMS_PATH, { "delqdtls" } )


         /* GRF Data */
         case cAlias == "COMPLOG"
            if ! netUse("&g_GRF_PATH\COMPLOG",.F.,5)
               break
            endif
            Set_Index(m->g_GRF_PATH, {"COMPLOG1", "COMPLOG2", "COMPLOG3", "COMPLOG4"})
            *** complog1.ntx - wstation+system+user
            *** complog2.ntx - status+brcode+dtos(indate)+intime
            *** complog3.ntx - system+user+status
            *** complog4.ntx - user+system+status

         case cAlias == "BRANCHES"
            if ! NetUse("&g_GRF_PATH/BRANCHES", .F., 5)
               break
            endif
            Set_Index( m->g_GRF_PATH, { "BRANCHES" } )

         case cAlias == "PERSONEL"
            if !NetUse( "&g_GRF_PATH\personel",.F.,5)
               break
            endif
            Set_Index( m->g_GRF_PATH, {"initials"} )


         /* CIS Data */
         case cAlias == "CLIENT"
            if !NetUse( "&g_CIS_PATH\client",.F.,5 )
               break
            endif
            Set_Index( m->g_CIS_PATH, {"cliecd","clienm","cliebf"} )
            *cliecd  // brcode+clntcode
            *clienm  // fullname+brcode
            *cliebf  // brcode+fullname

         case cAlias == "PDCHDBCK"
            if !NetUse( "&g_AMS_PATH\AMSBACK\pdchdbck",.F.,5 )
               break
            endif
            Set_Index( m->g_AMS_PATH+"\AMSBACK", { "pbk_head", "pbk_clnt", "pbk_hdrt", "pbkrevac", "pbk_val" })
            ** pdc_head.ntx     // brcode+acctno
            ** pdc_clnt.ntx     // brcode+clntcode
            ** pdc_hdrt.ntx     // brcode+substr(acctno,-5,5)
            ** pdcrevac.ntx     // dtos(recdate)+brcode+acctno
            ** pdc_val .ntx     // dtos(recdate)+str(day(valdate),2)

         case cAlias == "PDCDTBCK"
            if !NetUse( "&g_AMS_PATH\AMSBACK\pdcdtbck",.F.,5 )
               break
            endif
            Set_Index( m->g_AMS_PATH+"\AMSBACK", { "pbk_dtls", "pbk_date", "pbkdchk", "pbkdeptl", "pbk_ornm", "pbk_stat" })
            ** pdc_dtls.ntx      // brcode+acctno+dtos(chkdate)
            ** pdc_date.ntx      // brcode+dtos(depdate)
            ** pdcdchk .ntx      // brcode+acctno+chkno
            ** pdcdeptl.ntx      // depdate
            ** pdc_ornm.ntx      // brcode+ornumber
            ** pdc_stat.ntx      // brcode+status+acctno+dtos(depdate)

      endcase
      isOK := .T.
   end sequence
return isOK

*******************************************************************************
function cust_temp( cPath, nDaily )
	local nH, cFile, cText, lRet := .F., i := 0
   local xParam
   memvar xCust

	begin sequence
		xCust := r_tempfile( cPath )
		dbCreate( xCust , { ;
			{"brcode",   "c", 03, 0 },;
			{"clntcode", "c", 07, 0 },;
			{"fullname", "c", 50, 0 },;
			{"accounts", "c", 04, 0 } } )
		OpenTMP((xCust), "client", .F. )
		dbCreateIndex( (xCust)+".nt1", "r_decrypt(brcode+clntcode)", {|| r_decrypt(brcode+clntcode)}, if( .F., .T., NIL ) )
		dbCreateIndex( (xCust)+".nt2", "r_decrypt(fullname)", {|| r_decrypt(fullname)}, if( .F., .T., NIL ) )
		ordlistclear()
		ordlistadd( (xCust)+".nt1" )
		ordlistadd( (xCust)+".nt2" )
		ordsetfocus(1)

      if (cFile := do_cps(m->g_PAR_BRCH, "GET_CLIENT")) == ""
			break
		endif
		cFile := CopyFile(cFile)
		if (nH := FOpen( cFile, 0 )) == -1
			Error( cFile+" not found...")
			break
		endif
		FSeek( nH, 0 ) // top of file
		while .T.
			dispText( 24, i++, ".", "r/n")
			if i > 79
				i := 0
				dispText(24, i, space(80), "r/n")
			endif
			cText := FReadStr(nH, 70 )
			if cText == ""
				exit
			endif
			cText := rms_Parse( cText, "~" )
         CLIENT->( dbappend() )
         CLIENT->brcode   := r_encrypt(cText[1])
         CLIENT->clntcode := r_encrypt(cText[2])
         CLIENT->fullname := r_encrypt(cText[3])
         CLIENT->accounts := r_encrypt(cText[4])
		enddo
      CLIENT->( dbcommit() )
      CloseFile(nH, cFile )
		lRet := .T.
	end sequence
return lRet

*******************************************************************************
function Get_Client( mCode, mName )
	local cCode := m->g_PAR_BRCH+space(07)
	local nRec := 0, getlist := {}

	Desktop(.T.)
   Box3(08, 15, 2, 29, "n/w")
   begin sequence
      rms_set("w+/w, w+/n,,, gr+/w", 3)
		__KeyBoard(CHR(K_END))
      @09,17 say "Client Code " get cCode pict "@R 999-99-99999" VALID v_client(@cCode, @mName)
		read
		setcursor(0)
      if lastkey() == 27
			break
		endif
      if CLIENT->( DBSeek(cCode) )
         nRec  := CLIENT->( recno() )
         mCode := r_decrypt(CLIENT->brcode+CLIENT->clntcode)
         mName := r_decrypt(CLIENT->fullname)
		else
			Error( "Client not found!" )
		endif
	end sequence
	Desktop(.F.)
return nRec

*******************************************************************************
function v_client( cCode, cName )
   local cFile, cText, nH, lRet := .F., bScope
	local xBrch := ! (m->TRUE_BRCH == "001" )
	local aFlds := { ;
		{ "Client Name", "fullname", "@!",    45,  xBrch },;
		{ "Branch",      "brcode"  , "@!",    07,  xBrch },;
      { "Code",        "clntcode", "@R 99-99999", 08,  xBrch } }

	begin sequence
		if !(m->TRUE_BRCH == "001")
         *aAdd( aFlds, { "Accts", "accounts", "99999", 05,  xBrch } )
			bScope := {|| .T. }
		else
         bScope := {|| brcode == m->g_PAR_BRCH }
		endif

      if empty(cCode) .or. left(cCode, 3) != m->g_PAR_BRCH
			cCode := m->g_PAR_BRCH+space(07)
		endif

      if (CLIENT->( DBSeek(cCode) ) .and. !empty(cCode)) .OR. ;
         ABrowse( 3,,21,"client",2,aFlds,"Select Client", bScope )

         if (m->TRUE_BRCH == "001")
            cCode := CLIENT->brcode+CLIENT->clntcode
            cName := CLIENT->fullname
         else
            cCode := r_decrypt(CLIENT->brcode+CLIENT->clntcode)
            cName := r_decrypt(CLIENT->fullname)
			endif

			if left(cCode, 3) != m->g_PAR_BRCH
				Error( "Invalid Branch code!" )
				break
			endif
			lRet := .T.
		endif
		if !lRet
			cCode := m->g_PAR_BRCH+space(07)
			__KeyBoard(CHR(K_END))
		endif
	end sequence
return lRet

*******************************************************************************
function emp_temp( cPath )
	local cFile, nH, cText, lRet := .F.
   memvar xPers

	begin sequence
		m->xPers := r_tempfile( cPath )
		dbcreate( m->xPers, { ;
			{ "brcode",  "c", 03, 0 },;
			{ "initials","c", 06, 0 },;
			{ "fullname","c", 40, 0 } } )
		OpenTMP( (xPers), "PERSONEL", .F. )
		dbCreateIndex( (xPers), "r_decrypt(initials)", {|| r_decrypt(initials)}, if( .F., .T., NIL ) )
		Set Index to (xPers)

		m->xStr := chk_par(m->g_PAR_BRCH)
      if (cFile := do_cps(m->xStr, "GET_EMPLOYEE")) == ""
			break
		endif
		cFile := CopyFile(cFile)
		if (nH := FOpen( cFile, 0 )) == -1
			Error( cFile+" not found..." )
			break
		endif
		FSeek( nH, 0 ) // top of file
		while .T.
         cText := FReadStr( nH, 54 )
			if cText == ""
				exit
			endif
			cText := rms_Parse( cText, "~" )
			PERSONEL->( dbappend() )
			PERSONEL->brcode	 := r_encrypt(cText[1])
			PERSONEL->initials := r_encrypt(cText[2])
			PERSONEL->fullname := r_encrypt(cText[3])
		enddo
      CloseFile(nH, cFile)
		lRet := .T.
	end sequence
return lRet

*******************************************************************************
function disp_status( xStat )
   local aList
   aList := "             " + "Active       " + ;
            "Past Due     " + "In Litigation" + ;
            "Repossessed  " + "Written-off  " + ;
            "Sold Rec'bles"
return substr(aList, val(xStat) * 13+1, 13)

*******************************************************************************
function accnt_stat( xStat )
   local aList
   aList := "             " + "Active       " + ;
            "Past Due     " + "In Litigation" + ;
            "Repossessed  " + "Written-off  " + ;
            "Sold Rec'bles"
return substr(aList, val(xStat) * 13+1, 13)

*******************************************************************************
function _dstatus( pcStat )
   local Result := space(17)

   if pcStat == "0"
      Result := "0 = Cancelled"
   elseif pcStat == "1"
      Result := "1 = Active"
   elseif pcStat == "2"
      Result := "2 = Past Due"
   elseif pcStat == "3"
      Result := "3 = In Litigation"
   elseif pcStat == "4"
      Result := "4 = Repossessed"
   elseif pcStat == "5"
      Result := "5 = Written-Off"
   elseif pcStat == "6"
      Result := "6 = Sold Rec'bles"
   endif
return padr(Result, 17)

*******************************************************************************
function ach_cust2()
	local mod_t:='noacct',ckey:=space(10)
	local headr:='   Client Name                            Branch  Clntcode  # of Accts'

	main_achoice('CLIENT',3,1,,8,4,21,76,headr,mod_t)

	if mpos > 0 .and. lastkey() == K_ENTER
		cKEY := substr( ltrim(mchoices[mpos]),44,3)+substr( ltrim(mchoices[mpos]),50,2)+;
			substr( ltrim(mchoices[mpos]),53,5)
      client->( dbsetorder(1) )

      if client->( DBSeek (alltrim(cKEY)) )
         aNRECNO  := client->( recno() )
		endif
	ENDIF
   nRecno := aNRECNO
return ckey

*******************************************************************************
function tempName( cExt )
   local cFile, cPath := "C:\LOTUS\"

	while .T.
      cFile := ITOS(_Random(100))+ITOS(_Random(200))+ITOS(_Random(300))
		if Len(cFile) > 7
         cFile := "Z"+LEFT(cFile, 7)
		else
         cFile := "Z"+STRZERO(val(cFile), 7)
		endif

		if cExt != nil
			cFile := cFile + "." + cExt
		endif

      if ! File( cPath + cFile )
			exit
		endif
	enddo
   AADD( m->_gTmpFile, { cPath, cFile } )
return cPath + cFile

*******************************************************************************
function tempErase()
   local nI, aList

   while ( nI := len(m->_gTmpFile) ) > 0
      aList := directory( m->_gTmpFile[nI,1] + m->_gTmpFile[nI,2]+".*" )
      if len(aList) > 0
         aEval(aList, {|cFile| Safe_Erase( "C:\LOTUS\" + cFile[1])})
      endif
      ASize( m->_gTmpFile, nI-1 )
   enddo
return nil

*******************************************************************************
function pAbort()
   local nKey := inkey()
   local bAbort := .F.

   if nKey == 27 .and. Confirm( "Do you want to Abort" )
      bAbort := .T.
   endif
return bAbort

*******************************************************************************
function InitLPT()
   setprc(0,0)
   @ prow(),pcol() say "@"
return nil

*******************************************************************************
function _GetOSBal( pBRACCNT, pDATE )
   local nAmort, nBalance := acctmast->credamt

   if acctmast->valdate > pDATE
      nBalance := 0
	endif

   // Get History Record
   if amshist2->( DBSeek(pBRACCNT) )
      nAmort := 0
      while ! amshist2->( eof() )  .and. amshist2->brcode+amshist2->acctno == pBRACCNT ;
         .and. amshist2->refdate <= pDATE

         nAmort += amshist2->amort
         amshist2->( DBSkip() )
      enddo
      nBalance -= nAmort
   endif

   // Get Current record
   if amshist->( DBSeek(pBRACCNT) )
      nAmort := 0
      while ! amshist->( eof() ) .and. amshist->brcode+amshist->acctno == pBRACCNT ;
         .and. amshist->refdate <= pDATE

         nAmort += amshist->amort
         amshist->( DBSkip() )
      enddo
      nBalance -= nAmort
   endif

return nBalance

*******************************************************************************
function _GetStatus( pBRACCNT, pDATE )
   local Result := " "

   stathist->( DBSeek(pBRACCNT) )
   while stathist->brcode+stathist->acctno == pBRACCNT .and. ! stathist->( eof() )
      if stathist->trandate > pDATE
         Result := stathist->oldstatus
			exit
		endif
      Result := stathist->newstatus
      stathist->( DBSkip() )
	enddo

   if empty(Result)
      Result := "1"
      *if val(acctmast->status) > 3
      *   Result := acctmast->status
      *endif
	endif
return Result

*******************************************************************************
function _GetUDI( pBRACCNT, pDATE )
   local nAmount := 0
   local ld_date

   if flag->udi_date == pDATE
      if udi->( DBSeek(pBRACCNT) )
         if udi->d3 != 0 .or. udi->d4 != 0 .or. ;
            udi->d5 != 0 .or. udi->d6 != 0
            nAmount := Udi->d6
			endif
		else
         if alir->( DBSeek(pBRACCNT) )
            if alir->d3 != 0 .or. alir->d4 != 0 .or. ;
               alir->d5 != 0 .or. alir->d6 != 0
               nAmount := alir->d6
				endif
			endif
      endif
   else
      *-- add 1 month
      ld_date := rs_Amonth(pDATE, 1)
      ld_date := rmsDate(ld_date, 4)

      *- get info from history
      if UDIALIR2->( DBSeek(pBRACCNT) )
         while ! UDIALIR2->( eof() ) .and. UDIALIR2->brcode+UDIALIR2->acctno == pBRACCNT
            if UDIALIR2->postdate > ld_date
               exit
            endif
            nAmount := UDIALIR2->d6
            UDIALIR2->( DBSkip() )
         enddo
      endif

      *- get info from current
      if UDIALIR->( DBSeek(pBRACCNT) )
         while ! UDIALIR->( eof() ) .and. UDIALIR->brcode+UDIALIR->acctno == pBRACCNT
            if UDIALIR->postdate > ld_date
               exit
            endif
            nAmount := UDIALIR->d6
            UDIALIR->( DBSkip() )
         enddo
		endif
	endif
return nAmount

*******************************************************************************
function __Facility( pcCode, plTrim )
   local Result := space(40)

   if plTrim == nil
      plTrim := .F.
   endif

   if facility->( DBSeek(pcCode) )
      Result := facility->fcltyname
   endif

   if plTrim
      Result := alltrim(Result)
   endif
return Result

*******************************************************************************
FUNCTION __TermUnit( uValue )
   LOCAL Result := SPACE(10)
   LOCAL aList := { "Day(s)", "Month(s)" }
   LOCAL nVal  := nValToNum( uValue )

   IF nVal == 0 .OR. nVal > LEN(aList)
   ELSE
      Result := PADR( aList[nVal], 10 )
   ENDIF
RETURN Result

*******************************************************************************
FUNCTION __RateType( uValue )
   LOCAL Result := SPACE(08)
   LOCAL aList := { "Fixed", "Floating" }
   LOCAL nVal  := nValToNum( uValue )

   IF nVal == 0 .OR. nVal > LEN(aList)
   ELSE
      Result := PADR( aList[nVal], 8 )
   ENDIF
RETURN Result

*******************************************************************************
function CPS_Exec( pcParam, pcFUNC, cAlias, nLen )
   local nH, cFile, cText

   pcFUNC := upper(ALLTRIM(pcFUNC))

   cFile := do_cps( pcParam, pcFUNC )
   if empty(cFile)
      return .F.
   endif

   cFile := CopyFile( cFile )
   nH := FOpen( cFile, 0 )
   FSeek( nH, 0 )  // top of file
   select (cAlias) ; __dbZap()

   while .T.
      cText := FREADSTR( nH, nLen )
      if cText == ""
         exit
      endif
      cText := rms_Parse( cText, "~" )
      (cAlias)->( DBAppend() )

      do case
         case pcFUNC == "GET_INSCOMP"
            (cAlias)->brcode  := cText[1]
            (cAlias)->inscode := cText[2]
            (cAlias)->insname := cText[3]
            (cAlias)->catcode := cText[4]

         case pcFUNC == "GET_COVER"
            (cAlias)->covercode := cText[1]
            (cAlias)->coverdesc := cText[2]

         case pcFUNC == "INSU_LOG"
            (cAlias)->recnum   := val(alltrim(cText[1]))
            (cAlias)->brcode   := cText[2]
            (cAlias)->acctno   := cText[3]
            (cAlias)->insured  := iif(cText[4]=="T", .T., .F.)
            (cAlias)->insby    := cText[05]
            (cAlias)->insprem  := val(cText[06])
            (cAlias)->amtins   := val(cText[07])
            (cAlias)->insdate  := ctod(cText[08])
            (cAlias)->insexpry := ctod(cText[09])
            (cAlias)->inscover := cText[10]
            (cAlias)->inspolcy := cText[11]
            (cAlias)->insor    := cText[12]
            (cAlias)->update   := ctod(cText[13])
            (cAlias)->userid   := cText[14]

      endcase
   enddo
   CloseFile(nH, cFile)
   (cAlias)->( DBCommit(), DBGoTop() )
return .T.

*******************************************************************************
function cFacility( pcCode, pnType )
   local lcResult := ""

   FACILITY->( DBSeek(pcCode) )
   if pnType == 1
      lcResult := FACILITY->fcltyname
   elseif pnType == 2
      lcResult := FACILITY->fcltyalias
	elseif nType == 3
      lcResult := FACILITY->setcode
	endif
return lcResult

*******************************************************************************
FUNCTION _TempAO( pcAlias, pAll )
   LOCAL isOK := .F.
   LOCAL zAO, nH, cFile, cText

   DEFAULT pAll TO .F.
   begin sequence
      zAO := tempName()
      DBCreate( zAO, { ;
         { "aocode","c",05,00 },;
         { "aoname","c",40,00 },;
         { "value", "n",01,00 } })
      openTMP( (zAO), pcAlias )
      index on field->aocode to (zAO)
      Set Index to (zAO)

      if (m->TRUE_BRCH == "001")
         if ! netUse( "&g_CIS_PATH\AO",.f.,5 )
            break
         endif
         ordListAdd( "&g_CIS_PATH\AO" )

         AO->( DBGoTop() )
         WHILE ! AO->( eof() )
            (pcAlias)->( DBAppend() )
            (pcAlias)->aocode := AO->aocode
            (pcAlias)->aoname := AO->aoname
            (pcAlias)->value  := 1
            AO->( DBSkip() )
         ENDDO
         close_if( "AO" )
      else
         cFile := cps_reqst(m->g_PAR_BRCH, "CIS_AOList")
         if valtype(cFile) != "C" .or. empty(cFile)
            break
         endif
         cFile := copyFile(cFile)
         nH := FOpen( cFile, 0 )
         FSeek( nH, 0 ) // top of file
         while .T.
            cText := FReadStr(nH, 49 )
            if cText == ""
               exit
            endif
            cText := rms_Parse( cText, "~" )
            (pcAlias)->( DBAppend() )
            (pcAlias)->aocode := cText[01]
            (pcAlias)->aoname := cText[02]
            (pcAlias)->value  := 1
         enddo
         CloseFile(nH, cFile )
      endif

      if pAll
         (pcAlias)->( DBAppend() )
         (pcAlias)->aocode := "*ALL*"
         (pcAlias)->aoname := "ALL Account Officer"
         (pcAlias)->value  := 2
      endif
      (pcAlias)->( DBCommit() )

      isOK := .T.
   end sequence
RETURN isOK

*******************************************************************************
function readline(nHandle, nBuffSize)
   local cRet :="", cBuff:="", nPos:=0, nEol:=0, nRead:=0
   local CRLF := CHR(13)+CHR(10)

   DEFAULT nBuffSize TO 1024
   cBuff := SPACE(nBuffSize)

   nPos := FSEEK(nHandle, 0, 1) // FS_RELATIVE)  SAVE CURRENT POSITION
   if ( nRead := FREAD(nHandle, @cBuff, nBuffSize) ) > 0
      if ( nEol := AT(CRLF, SUBSTR(cBuff, 1, nRead)) ) == 0
         cRet := cBuff       // LINE OVERFLOW OR EOF() - RETURN ENTIRE BUFFER
      else
         cRet := SUBSTR(cBuff, 1, nEol-1)
         FSEEK(nHandle, nPos+nEol+1, 0) //FS_SET)
      endif
   endif
return (cRet)