#include "inkey.ch"
#include "rms.ch"

#define BUTTONSEP 4

*******************************************************************************
function lOpenArea()
	local nArea

	for nArea := 1 to 254
		select( nArea )
		if used()
			return .T.
		endif
	next
return .F.

*******************************************************************************
function netDBUse( cDBF, lOpenMode, nTry, cAlias, lNew, lReadOnly )
	local lRet := .F.                             // return
	local lForever                                // infinite retry
	local cOldScreen := savescreen( maxrow(), 0, maxrow(), maxcol()+1 )
	local nKey       := 0
	local cErrMsg, nWait

	DEFAULT cAlias    := r_ALIAS(cDBF)
	DEFAULT lOpenMode := .T.
	DEFAULT nTry      := 5
	DEFAULT lNew      := .T.
	DEFAULT lReadOnly := .F.

	nWait    := nTry
	lForever := ( nWait == 0 )
	cErrMsg  := cDBF + " is in use, Do you want to wait? "

	__Keyboard( chr(255) )
	inkey()

	while ( lForever .OR. (nWait >= 0) )
		DISPOUTAT( MAXROW(), 0, PADC( "Opening "  + upper(alltrim(cDBF)) + " ... ³ " + ;
			ITOS(nWait, 4, 1), MAXCOL()+1 ), "GR+/R" )

		DBUSEAREA( lNew,, (cDBF), (cAlias), lOpenMode, lReadOnly )

		if ! netErr()
			lRet := .T.
			exit
		endif
		inkey( .5 )
		nWait--

		if ( !lForever .and. (nWait < 0) )
			if rms_Yesno( cErrMsg )
				nWait := nTry
			endif
		endif
	enddo

	RESTSCREEN( MAXROW(), 0, MAXROW(), MAXCOL()+1, cOldScreen )
return (lRet)

*******************************************************************************
static function nLabelLen( cText, cDelim )
	local nRet := Len(cText)

	DEFAULT cDelim := "~"
	if AT(cDelim, cText) > 0
		nRet--
	endif
return nRet

*******************************************************************************
function VMenu( aMenu, cDefa, nRow, nCol, cColor, lEsc, lBox )
	local aColor, cHotKeys := ""
	local i, cRet, nKey, cKey
	local nLong := 1, nLen := len(aMenu)
	local nT, nL, nB, nW
	local aRows[nLen], aCols[nLen], aText[nLen]

	DEFAULT cColor := m->_clrButton ,;
		lEsc   := .T. ,;
		lBox   := .F.

	aeval( aMenu, { |x| nLong := max( nLong, len(x) ) } )
	aColor := rms_Parse(cColor)
	Desktop(.T.) ; setcursor(0)
	dispbegin()
	if lBox
		nT := nRow - 1
		nL := nCol - 2
		nB := nLen + 1 + nT
		nW := nLong + 4

		nB := nLen * 3
		nW += 1
		box3( nT, nL, nB, nL+nW, aColor[6] )
	endif

	for i := 1 to nLen
		aRows[i] := nRow
		aCols[i] := nCol
		aText[i] := " " + padr(aMenu[i], nLong) + " "
		saymenu( .F., aRows[i], aCols[i], aText[i], cColor )
		cHotkeys += substr(aText[i], at("~", aText[i])+1, 1)

		nRow += 2
	next
	i := at( upper(cDefa), cHotKeys )
	i := if( empty(i), 1, i )
	dispend()
	while .T.
		saymenu2( .T., aRows[i], aCols[i], aText[i], cColor )
		cKey := upper( chr(nKey := Inkey(0)) )
		saymenu2( .F., aRows[i], aCols[i], aText[i], cColor )
		if ( nKey == K_ESC ) .AND. lEsc
			cRet := chr(K_ESC)
			exit
		elseif ( nKey == K_UP )
			if --i <  1
				i := nLen
			endif
		elseif ( nKey  == K_DOWN )
			if ++i > nLen
				i := 1
			endif
		elseif ( nKey == K_ENTER )
			saymenu( .T., aRows[i], aCols[i], aText[i], cColor )
			cRet := substr(cHotKeys, i, 1)
			exit
		elseif ( cKey $ cHotKeys )
			i := at(cKey, cHotkeys)
			saymenu( .T., aRows[i], aCols[i], aText[i], cColor )
			cRet := substr(cHotkeys, i, 1)
			exit
		endif
	enddo
	Desktop(.F.)
return cRet

*******************************************************************************
static function saymenu( lPush, nRow, nCol, cText, cColor )
	local aColor := rms_Parse(cColor)
	local cShad  := m->_clrShadow + substr(aColor[6], at("/", aColor[6]))
	local cKey, nPos := at("~", cText)

	cText := strtran(cText, "~")
	cKey := substr(cText, nPos--, 1)
	if lPush
		dispoutat( nRow, nCol, " ", aColor[6] )
		dispoutat( nRow, nCol+1, cText, aColor[3] )
		dispoutat( nRow, nCol+nPos+1, cKey, aColor[4] )
		dispoutat( nRow+1, nCol+1, space(len(cText)), aColor[6] )
		inkey(.30)
	endif
	dispoutat( nRow, nCol, cText, aColor[1] )
	dispoutat( nRow, col(), "Ü", cShad )
	dispoutat( nRow, nCol+nPos, cKey, aColor[2] )
	dispoutat( nRow+1, nCol+1, repli("ß", len(cText)), cShad )
return nil

*******************************************************************************
static function saymenu2( lPush, nRow, nCol, cText, cColor )
	local aColor := rms_Parse(cColor)
	local cKey, nPos := at("~", cText)

	cText := strtran(cText, "~")
	cKey := substr(cText, nPos--, 1)
	if lPush
		dispoutat( nRow, nCol, cText, aColor[3] )
		dispoutat( nRow, nCol+nPos, cKey, aColor[4] )
	else
		dispoutat( nRow, nCol, cText, aColor[1] )
		dispoutat( nRow, nCol+nPos, cKey, aColor[2] )
	endif
return nil

********************************************************************************
function HMenu(aMenu, nPos, nRow, nCol, cColors, nSpace)
	local cHotKeys := ""
	local i, cRet, nKey, cKey
	local nLen := len(aMenu)
	local aRows[nLen], aCols[nLen], aText[nLen]

	DEFAULT cColors := m->_clrButton,;
		nSpace  := BUTTONSEP

	dispbegin()
	for i := 1 to nLen
		aRows[i] := nRow
		aCols[i] := nCol
		aText[i] := " " + aMenu[i] + " "
		cHotkeys += substr(aText[i], at("~", aText[i])+1, 1)
		saymenu( .F., aRows[i], aCols[i], aText[i], cColors )

		nCol += len(aText[i]) + nSpace
	next i
	dispend()

	if ValType(nPos) == "C"
		nPos := substr(cHotKeys,nPos,1)
	elseif nPos == nil .OR. nPos > len(cHotKeys)
		nPos := 1
	endif
	while .T.
		saymenu2( .T., aRows[nPos], aCols[nPos], aText[nPos], cColors )
		cKey := upper( chr(nKey := inkey(0)) )
		saymenu2( .F., aRows[nPos], aCols[nPos], aText[nPos], cColors )
		if ( nKey == K_ESC )
			cRet := chr(K_ESC)
			exit
		elseif ( nKey == K_LEFT )
			if --nPos < 1
				nPos := nLen
			endif
		elseif ( nKey == K_RIGHT )
			if ++nPos > nLen
				nPos := 1
			endif
		elseif ( nKey == K_ENTER )
			saymenu( .T., aRows[nPos], aCols[nPos], aText[nPos], cColors )
			cRet := substr(cHotKeys, nPos, 1)
			exit
		elseif ( cKey $ cHotKeys )
			i := at(cKey, cHotkeys)
			saymenu( .T., aRows[i], aCols[i], aText[i], cColors )
			cRet := substr(cHotKeys, i, 1)
			exit
		endif
	enddo
return cRet

********************************************************************************
function rms_Alert(aMsg, acOptions, nDefa, cTitle, cColors, nSpace)
	local nT, nL, nH, nW, nS, nB, nR, aColor
	local i, cRet, nMsg, nBtn, aBox
	local nLenMsg := 0, ;
		nLenOpt := BUTTONSEP

	DEFAULT acOptions := { " ~OK " },;
		cColors   := m->_clrAlert,;
		nSpace    := BUTTONSEP

	nBtn := len(acOptions)
	if ValType(aMsg) != "A"
		aMsg := rms_Parse(aMsg, ";")
	endif
	nMsg := len(aMsg)
	aeval(aMsg, {|_1| nLenMsg := max( nLenMsg, len(_1) ) } )

	for i := 1 to len( acOptions )
		nLenOpt += nLabelLen( acOptions[ i ] ) + nSpace
	next

	nH := nMsg + 5
	nW := Max(nLenMsg, nLenOpt) + BUTTONSEP
	nT := int( (maxrow() + 1 - nH) / 2)
	nL := int( (maxcol() + 1 - nW) / 2)
	nS := nL + int((nW - nLenOpt) / 2) + nSpace
	nB := nT + nH
	nR := nL + nW

	aColor := rms_Parse(cColors)
   //aBox := BP_WINMAKE( nT, nL, nB, nR+3, aColor[6]+","+aColor[5],cTitle,BX_DOUBLE+chr(255) )
   aBox := rmsBox( nT, nL, nH, nW+3,2,cTitle,aColor[6]+","+aColor[5],BX_DOUBLE+chr(255) )
	setcursor(0)
	for i := 1 to nMsg
		dispoutat( nT+i+1, nL+2, padc(aMsg[i], nW), aColor[6] )
	next
	cRet := HMenu( acOptions, nDefa, nT+nH-2, nS, cColors, nSpace)
	winRest(aBox)
return cRet

********************************************************************************
function rms_YesNo( cMsg, nDefa, cColors)
	DEFAULT nDefa := 2
return rms_Alert( cMsg,{" ~Yes "," ~No "},nDefa,,cColors ) == "Y"

********************************************************************************
function rms_Abort( cMsg, nDefa, cColors)
return rms_Alert( cMsg,{" ~Abort "," ~Retry "}, nDefa,,cColors ) == "A"

********************************************************************************
function Remind( cMsg, nWait, lPress, lTone, nT, cColor )
	local nL

	DEFAULT nWait  := 0 ,;
		lPress := .F. ,;
		lTone  := .T. ,;
		cColor := "gr+/r" ,;
		nT     := INT(maxrow()/2)

	cMsg := cValToChr( cMsg )
	if lPress
		cMsg += " Press any key..."
	endif
	nL := (maxcol(.T.) - len(cMsg)) / 2
	Desktop(.T.)
	rms_set(cColor, 0)
	Box3( nT, nL-2, 2, len(cMsg)+3, cColor )
	dispoutat( nT+1, nL, cMsg )
	if lTone
		tone(500, 1) ; tone(750, 1) ; tone(500, 1)
	endif
	inkey(nWait)
	Desktop(.F.)
return nil

*******************************************************************************
function CheckDate( pcDate )
return ! EMPTY(CTOD(pcDate))

*******************************************************************************
function EncodeDate( nY, nM, nD )
	local dDate, dFormat := SET( 4, "dd-mm-yyyy" )

	dDate := CTOD( STRZERO(nD,2) + "-" + STRZERO(nM,2) + "-" + STRZERO(nY,4) )
	WHILE EMPTY(dDate)
		dDate := CTOD( STRZERO(--nD,2) + "-" + STRZERO(nM,2) + "-" + STRZERO(nY,4) )
	ENDDO
	SET( 4, dFormat )
return dDate

*******************************************************************************
function DecodeDate( dDate, nY, nM, nD )
	DEFAULT dDate := DATE()

	nY := Year(dDate)
	nM := Month(dDate)
	nD := Day(dDate)
return nil

*******************************************************************************
function num2day( nD, lFull )
	local Result := ""
	local aAraw := { "Sunday", "Monday", "Tuesday", "Wednesday", ;
		"Thursday", "Friday", "Saturday" }

	DEFAULT lFull := .F.

	if (nD >= 1 .OR. nD <= 7)
		Result := aAraw[nD]

		if ! lFull
			Result := left(Result, 3)
		endif
	endif
return Result

*******************************************************************************
function num2mon( nM, lFull )
	local Result := ""
	local aBuwan := { "January",   "February", "March",    "April", ;
		"May",       "June",     "July",     "August",;
		"September", "October",  "November", "December" }

	DEFAULT lFull := .T.

	if (nM >= 1 .or. nM <= 12)
		Result := aBuwan[nM]

		if ! lFull
			Result := left(Result, 3)
		endif
	endif
return Result

*******************************************************************************
function AnsiDate( cDate )                       // YYYYMMDD
	local nY, nM, nD

	nY := val(substr(cDate, 1, 4))
	nM := val(substr(cDate, 5, 2))
	nD := val(substr(cDate, 7, 2))
return EncodeDate(nM, nD, nY)

*******************************************************************************
function RS_IsLeap( uValue )
	local nY, nM, nD

	DEFAULT uValue := date()
	if ValType(uValue) == "D"
		decodedate( uValue, @nY, @nM, @nD )
	else
		nY := uValue
	endif
return (nY % 4) == 0

*******************************************************************************
function rs_nDays( uValue, isLeap )
	local nDays := 31, iMonth

	if valtype(uValue) == "D"
		iMonth := Month(uValue)
		isLeap := rs_isleap(uValue)
	else
		iMonth := uValue
	endif

	if (iMonth == 2)
		nDays := iif(isLeap, 29, 28)
	elseif (iMonth == 4) .OR. (iMonth == 6) .or. (iMonth == 9) .or. (iMonth == 11)
		nDays := 30
	endif
return nDays

*******************************************************************************
function rs_AMONTH( dDate, nMonths )
	local iYear, iMonth, iDay, nDays

	iDay   := DAY(dDate)
	iMonth := MONTH(dDate)
	iYear  := YEAR(dDate)

	iMonth += nMonths

	while (iMonth <= 0)
		iMonth += 12
		iYear--
	enddo

	while (iMonth > 12)
		iMonth -= 12
		iYear++
	enddo

	nDays := rs_nDays( iMonth, rs_isleap(iYear) )
	if (iDay > nDays)
		iDay := nDays
	endif
return encodedate(iYear, iMonth, iDay)

*******************************************************************************
function rmsDate( uDate, nType )
	local iYear, iMonth, iDays, n1
	local Result

	DEFAULT uDate := DATE()
	iYear  := YEAR(uDate)
	iMonth := MONTH(uDate)

	if nType == 1                                 // BOY
		Result := EncodeDate(iYear, 1, 1)
	elseif nType == 2                             // EOY
		Result := EncodeDate(iYear, 12, 31)
	elseif nType == 3                             // BOM
		Result := EncodeDate(iYear, iMonth, 1)
	elseif nType == 4                             // EOM
		if (++iMonth > 12)
			iMonth := 1
			iYear++
		endif
		Result := EncodeDate(iYear, iMonth, 1) - 1
	elseif nType == 5                             // BOQ
		iMonth -= ( iMonth - 1) % 3
		EncodeDate(iYear, iMonth, 1)
	elseif nType == 6                             // EOQ
		iMonth += 3 - ( ( iMonth - 1 ) % 3 )
		if iMonth > 12
			iMonth := 1
			iYear++
		endif
		Result := EncodeDate(iYear, iMonth, 1) - 1
	elseif nType == 7                             // quarter
		iMonth := month(uDate) + 2
		Result := INT( iMonth / 3 )
	elseif nType == 8                             // Week
		iDays := DIFFDATE( rmsDate(uDate, 1), uDate )
		Result := INT( iDays / 7 ) + 1
		n1 := iDays % 7
		if n1 > 0
			Result++
		endif
	endif
return Result

*******************************************************************************
function rms_mdy( dDate, lFull )
	local nY, nM, nD

	DEFAULT dDate := date()
	DEFAULT lFull := .T.

	nY := Year(dDate)
	nM := Month(dDate)
	nD := Day(dDate)
return num2mon(nM, lFull) + " " + STRZERO(nD, 2) + ", " + TRANSF(nY, "9999" )

*******************************************************************************
function rms_dmy( dDate, lFull )
	local nY, nM, nD

	DEFAULT dDate := DATE()
	DEFAULT lFull := .F.

	nY := Year(dDate)
	nM := Month(dDate)
	nD := Day(dDate)
return STRZERO(nD, 2) + "-" + num2mon(nM, lFull) + "-" + TRANSF(nY, "9999" )

*******************************************************************************
function DIFFDATE( xDate1, xDate2 )
	DEFAULT xDate1 := date()
	DEFAULT xDate2 := date()
return xDate2 - xDate1

/*   Financial Functions */
*******************************************************************************
FUNCTION PAYMENT( nCapital, nRate, nTime, nType )
	local n1, n2

	DEFAULT nType := 0

	nRate := ( nRate / 100 / 12 )                 // monthly rate
	if nType == 0
		n1 := (1.0 + nRate) ** nTime
	else
		n1 := (1.0 + nRate) ** ( nTime -1 )
	endif
	n2 := ( (1.0 + nRate) ** nTime ) - 1.0
RETURN nCapital * (nRate * n1) / n2

*******************************************************************************
FUNCTION RATE(nCapital, nAmort, nTime)
	local nRate := 1.0                            // return value
	local nTemp                                   // temporary rate
	local dAux, n1
	local dEpsilon := 0.00001
	local dScale   := 1.0

   while (nRate < 1020.0 ) /* maximum anual rate */
	nTemp := nRate *  0.000833333                 // ( 0.01 / 12 )
	n1 := (1.0 + nTemp) ** nTime
	dAux := nCapital * ( (n1 * nTemp) / (n1 - 1.0) )
	if (dAux > nAmort)
		nRate := nRate - dScale
		dScale := dScale * 0.10
		if ( dAux - nAmort) < dEpsilon
			exit
		endif
	else
		nRate := nRate + dScale
	endif
enddo
RETURN nRate

*******************************************************************************
FUNCTION FV(nCapital, nRate, nTime)
	local n1

	if nRate == 0.0
		RETURN nCapital * nTime
	endif
	nRate := nRate / 100 / 12
	n1 := (1.0 + nRate) ** nTime
RETURN nCapital * n1 / nRate

*******************************************************************************
FUNCTION PV(nCapital, nRate, nTime)
	local n1

	if nRate == 0.0
		RETURN nCapital * nTime
	endif
	nRate := nRate / 100 / 12
	n1 := (1.0 + nRate) ** -nTime
RETURN nCapital * ( (1.0 - n1) / nRate )

*******************************************************************************
FUNCTION PERIODS(nCapital, nAmort, nRate)
	local n1

	nRate := nRate / 100 / 12
	if nAmort <= nCapital * nRate
		RETURN -1
	endif

	if nRate == 0.0
		RETURN nCapital / nAmort
	endif
	n1 := -LOG(1.0 - (nCapital * nRate/ nAmort))
RETURN n1 / LOG(1+nRate)
