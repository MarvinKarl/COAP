#include "inkey.ch"
#include "rms.ch"

********************************************************************************
Init function Init_Vars()
   public _clrTitle, _clrBox, _clrDesktop, _clrMenuBar
   public _clrStatus, _clrBrowse, _clrButton
   public _clrAlert, _clrBar, _clrShadow, _clrError
   public _clrQBox

   m->_clrTitle   := "w+/r"
   m->_clrBox     := "n/w"
   m->_clrAlert   := "n+/w,n/w,r/gr*,n/gr*,r/w+*,w+/r"
   m->_clrDesktop := "w/b,w+/r,bg+/r,w+/r"
   m->_clrMenuBar := "n/w,n/g,r/w,r/g,n+/w,n/w"
   m->_clrButton  := "n/w,n/g,r/w,r/g,n+/w,n/w"
   m->_clrStatus  := "r/w,n/w"
   m->_clrBrowse  := "n/bg,w+/n,n/gr,w+/gr"
   m->_clrShadow  := "n"
   m->_clrBar     := "n/w,w+/r"
   m->_clrError   := "w/b,w+/b,n/b*,w+/b*,n/w,r/w"
   m->_clrQBox     := "n/w,r/w,w+/w"
return nil

*******************************************************************************
function inkeytrap( nWait )
	local bKeyBlock, nKey

   if nWait == nil
      nKey := inkey()
   else
		nKey := inkey(nWait)
	endif
	if !( ( bKeyBlock := setkey( nKey ) ) == NIL )
		eval( bKeyBlock, procname(1), procline(1), "" )
	endif
return nKey

*******************************************************************************
function setif( xVar, xValue)
	if xVar == Nil
		xVar := xValue
	endif
return nil

*******************************************************************************
function rms_Set( cColor, nCursor )
   setcolor(cColor) ; setcursor(nCursor)
return nil

*******************************************************************************
function dispText(nRow, nCol, cText, cColor, cPict)
   DEFAULT cColor := setcolor()

   if cPict != nil
		cText := transform(cText, cPict)
	endif
	dispoutat(nRow, nCol, cText, cColor)
return nil

*******************************************************************************
function WkArea( lSave )
	local aWrk
   static A_WArea := {}

	if lSave
		if used()
         AAdd( A_WArea, { select(), recno(), indexord() } )
		endif
	else
		aWrk := ATail( A_WArea )
		if aWrk != nil
			dbSelectarea( aWrk[1] )
			dbGoto( aWrk[2] )
			ordsetfocus( aWrk[3] )
			ASize( A_WArea, len(A_WArea) - 1 )
		endif
	endif
return nil

*******************************************************************************
function VPopup( aItems, nDefa, cTitle, nT, nL, cColor, lCanEsc )
   local xCurs := setcursor(0)
   local nReturn := 0, nB, nR, nKey
	local oItem, nTemp, nNewItem, oMenu := PopUp()

   DEFAULT cColor := m->_clrButton
   DEFAULT nDefa  := 1
   DEFAULT lCanEsc := .T.

	oMenu:colorspec := cColor
   for nB := 1 to len(aItems)
      oItem := MenuItem( aItems[nB] )
		oMenu:AddItem( oItem )
	next
	if nT != nil
		oMenu:top := nT
	endif
	if nL != nil
		oMenu:left := nL
	endif

	if (nDefa == 0) .or. (nDefa > len(aItems))
		nDefa := 1
	endif

	oMenu:Current := nDefa
	oMenu:Select(nDefa)
	oMenu:Open()
	nT := oMenu:top
	nL := oMenu:left
	nB := oMenu:bottom
	nR := oMenu:right
   oMenu:cargo := savescreen(nT, nL, nB+1, nR+2)
	dbgshadow(nT, nL, nB, nR)
	while .T.
      if cTitle <> nil
         dispoutat( nT, nL+1, cTitle, takeOut(cColor, 6) )
      endif
      nKey := inkey(0)

		if ( nKey == K_DOWN )
			nTemp := oMenu:GetNext()
			if (nTemp == 0)
				nTemp := oMenu:GetFirst()
			endif
			oMenu:Select( nTemp )
			oMenu:Display()
		elseif ( nKey == K_UP )
			nTemp := oMenu:GetPrev()
			if (nTemp == 0)
				nTemp := oMenu:GetLast()
			endif
			oMenu:Select( nTemp )
			oMenu:Display()
		elseif ( nKey == K_ENTER )
			nReturn := oMenu:current
			Exit
      elseif ( nKey == K_ESC ) .and. lCanEsc
			Exit
		elseif ( ( nNewItem := oMenu:GetAccel( nKey ) ) != 0 ) //=== check for menu item accelerator key.
			oMenu:Select( nNewItem )
			oMenu:Display()
			nReturn := oMenu:current
			Exit
		endif
	enddo
   setcursor(xCurs)
   restscreen(nT, nL, nB+1, nR+2, oMenu:cargo)
   oMenu:Close()
return nReturn

*******************************************************************************
function CurClr(lSave, nCursor, cColor)
   local aTemp
   STATIC saCurClr_ := {}

   if lSave
      AADD( saCurClr_, { ROW(), COL(), iif(nCursor != nil, setcursor(nCursor), ;
         setcursor()), iif(cColor != nil, setColor(cColor), setColor()) } )
   else
      aTemp := ATAIL( saCurClr_ )
      setPos(aTemp[1], aTemp[2])
      setCursor(aTemp[3])
      setColor(aTemp[4])
      ASIZE( saCurClr_, LEN(saCurClr_) - 1 )
   endif
return nil

*******************************************************************************
function Desktop( lSave )
	local aDesk
   static _saDesk := {}

	if lSave
      aAdd(_saDesk, { Chr(Row()),Chr(Col()),Chr(Setcursor()), setcolor(), setblink(), savescreen()})
   else
      aDesk := ATail( _saDesk )
		dispbegin()
      restscreen( 0, 0, maxrow(), maxcol(), aDesk[6] )
      setblink( aDesk[5] )
      setcolor( aDesk[4] )
      setpos( Asc(aDesk[1]), Asc(aDesk[2]) )
      setcursor( Asc(aDesk[3]) )
		dispend()
      aSize( _saDesk, len(_saDesk) - 1 )
	endif
return nil

********************************************************************************
function rms_Parse(cStr, cDelim)
	local nAt, aList := {}

   DEFAULT cDelim :=  ","

	while ( nAt := at(cDelim, cStr)) != 0
		aAdd(aList, substr(cStr, 1, nAt-1))
		cStr := substr( cStr, nAt+1 )
	enddo
	aAdd(aList, cStr)
return aList

*******************************************************************************
function _vPath( cPath )
   local cResult := alltrim(cPath)

   if right(cResult, 1) != "\"
      cResult += "\"
   endif
   cPath := cResult
return cResult

*******************************************************************************
function close_if( cAlias )
	if select( cAlias ) > 0
		select( cAlias )
		dbclosearea( cAlias )
	endif
return nil

*******************************************************************************
function r_alias( cStr )
	local nPos

	// Strip out the drive and path information, if any
	if (( nPos := max( max( 0, rat( "\", cStr )), rat( ":", cStr ))) != 0 )
		cStr := substr( cStr, ++nPos )
	endif

	// Strip out the extension information, if any
	if (( nPos := rat( ".", cStr )) != 0 )
		cStr := substr( cStr, 1, --nPos )
	endif
return (cStr)

*******************************************************************************
function openTMP(cDBF, cAlias, lShared, lRead )
	local lRet := .T.

   DEFAULT cAlias  := r_alias(cDBF) ,;
           lShared := .T. ,;
           lRead   := .F.

	dbUseArea(.T.,, cDBF, cAlias, lShared, lRead )
	if NetErr()
		lRet := .F.
	else
		select (cAlias)
	endif
return lRet

*******************************************************************************
function Set_Index(cPath, aIndex, nOrd)
	local i

   DEFAULT cPath := ".\"
   DEFAULT nOrd  := 1

   _vPath( @cPath )
	for i := 1 to len(aIndex)
		ordlistadd(cPath + aIndex[i])
	next i
	ordsetfocus(nOrd)
return nil

*******************************************************************************
function Frame2( nT, nL, nB, nR, cTitle, cColor, cBox, lShad )
   local aColor[2], cBox2, i

   DEFAULT cColor := m->_clrBox
   DEFAULT cBox   := "ÚÄ¿³ÙÄÀ³ÃÄ´"
   DEFAULT lShad  := .T.

   cBox2 := substr(cBox, 1, 8) + CHR(255)
	dispbegin()
   dispbox( nT, nL, nB, nR, cBox2, cColor )
   dispoutat( nT, nL+3, cTitle, cColor )
   cBox2 := substr(cBox,9,1)
   for i := nL+1 to nR-1
      cBox2 += substr(cBox, 10, 1)
   next
   cBox2 += substr(cBox,11,1)
   dispoutat(nT+3, nL, cBox2, cColor )
	if lShad
		dbgshadow( nT, nL, nB, nR )
	endif
	dispend()
return nil

*******************************************************************************
function Box3(nT, nL, nH, nW, cColor, lShad, cBox, nFrame)
   local aColor, nB := nT + nH, nR := nL + nW

   DEFAULT cColor := m->_clrBox + "," + m->_clrTitle
   DEFAULT lShad  := .T.
   DEFAULT cBox   := BX_SINGLE1
   DEFAULT nFrame := 0

   aColor := rms_Parse(cColor)
   _TFrame(nT, nL, nB, nR, aColor[1], nFrame, cBox)
   if lShad
      dbgshadow(nT, nL, nB, nR)
   endif
return nil

*******************************************************************************
function spChar(nT, nL, nS, nB, cAtt, cChar )
	local i

	DEFAULT cAtt  := "w+/w,w/n" ,;
			  cChar := "Û°"

	dispbegin()
	for i := nT to nS
		dispText( i, nL, substr(cChar,1,1), GetClrPair(cAtt, 1) )
	next
	for i := nS to nB
		dispText( i, nL, substr(cChar,2,1), GetClrPair(cAtt, 2) )
	next
	dispend()
return nil

*******************************************************************************
function TLine( nT, nL, nR, cAtt, cFill )
	local i, nW := nR - nL + 1

	DEFAULT cAtt  := setcolor() ,;
			  cFill := "ÃÄ´"

	dispbegin()
	for i := nL + 1 to nR - 1
		dispText( nT, i, substr(cFill,2,1), cAtt )
	next
	dispText( nT, nL, substr(cFill,1,1), cAtt )
	dispText( nT, nR, substr(cFill,3,1), cAtt )
	dispend()
return nil

*******************************************************************************
function spBox( nT, nL, nB, nR, cAtt, cTitle )
   local nW := nR - nL + 1
   local cBox := BX_SINGLE1

   DEFAULT cAtt := m->_clrBox+","+m->_clrTitle

	cAtt := rms_Parse(cAtt)
	dispbegin()
	dispbox( nT, nL, nB, nR, cBox, cAtt[1] )
   dispoutat( nB, nL, "Ã", cAtt[1])
   dispoutat( nB, nR, "´", cAtt[1])
	if cTitle <> nil
		dispoutat(nT, nL + (nW - len(cTitle)) / 2, cTitle, cAtt[2] )
	endif
	dispend()
return Nil

*******************************************************************************
function _Random( nNum )
	local nTime:= seconds(), nRet
	static nSeed := 1

	while ( nNum > nTime )
		nTime:= nTime * 100 + seconds()
	enddo
	nSeed:= (nSeed + nTime) / (nRet:= nSeed * nTime % nNum + 1)
return int(nRet)

*******************************************************************************
function Statline(cText, cColor, nL, nB, nW)
	local i, lOn:= .F.

   DEFAULT cColor := m->_clrStatus
   DEFAULT nL     := 0
   DEFAULT nB     := maxrow()-1

   if nW == Nil
		nW := (maxcol()+1) - nL
	endif

	cColor := rms_Parse(cColor)
	dispbegin()
	dispoutat( nB, nL, space(nW), cColor[2] )
	for i:= 1 to Len(cText)
		if (SubStr(cText, i, 1) != "~")
			if (lOn)
				dispoutat( nB, nL, SubStr(cText, i, 1), cColor[1] )
			else
				dispoutat( nB, nL, SubStr(cText, i, 1), cColor[2] )
			endif
			nL++
		else
			lOn:= !lOn
		endif
	next
	dispend()
return Nil

*******************************************************************************
function r_encrypt(cStr)
	local i, l2, l6, l7
	local nLen := len(cStr)
   local L4:= "®‘¡ûÝòð¸œôàŠ«¯»áÜ›…’“øõçÑïùŸž±¿å§Ûè¦£äÊþýî‹ãŒê­¨ „€é–÷¬Öæ¢°?!*|¾È"
   local L5:= "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz.0123456789 =,:/-^+_!¤¥"

	cStr := alltrim(cStr)
	L2:= ""
	for i:= 1 to Len(cStr)
		L6:= SubStr(cStr, i, 1)
		L7:= At(L6, L5)
		L2:= L2 + iif(L7 = 0, L6, SubStr(L4, L7, 1))
	next
	cStr:= alltrim(L2) + Space(nLen)
	cStr:= Left(cStr, nLen)
return cStr

*******************************************************************************
function r_decrypt(cStr)
	local nLen:= Len(cStr), L2, L3, L6, L7
   local L4:= "®‘¡ûÝòð¸œôàŠ«¯»áÜ›…’“øõçÑïùŸž±¿å§Ûè¦£äÊþýî‹ãŒê­¨ „€é–÷¬Öæ¢°?!*|¾È"
   local L5:= "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz.0123456789 =,:/-^+_!¤¥"

	cStr:= alltrim(cStr)
	L2:= ""
	for L3:= 1 to len(cStr)
		L6:= SubStr(cStr, L3, 1)
		L7:= At(L6, L4)
		L2:= L2 + iif(L7 != 0, SubStr(L5, L7, 1), L6)
	next
	cStr:= alltrim(L2) + Space(nLen)
	cStr:= Left(cStr, nLen)
return cStr

*******************************************************************************
function CopyFile( cFile )
	local cFile2 := r_tempfile( , "txt" )

	cFile := alltrim(cFile)
	__CopyFile( (cFile), (cFile2) )
	FErase(cFile)
return cFile2

*******************************************************************************
function CloseFile(nH, cFile)
   FClose(nH)
   FErase(cFile)
return nil

*******************************************************************************
function ITOS(nVar, nLen, nDeci)
   if pcount() == 3
      return Str(nVar, nLen, nDeci)
   elseif pcount() == 2
      return Str(nVar, nLen)
   endif
return LTrim(Str(nVar))

*******************************************************************************
function cSTRZERO(nVar, nLen, nDeci)
   local cNumber

   if pcount() == 3
      cNumber := Str(nVar, nLen, nDeci)
   elseif pcount() == 2
      cNumber := Str(nVar, nLen)
   else
      cNumber := Str(nVar)
   endif
return STRTRAN(cNumber, " ", "0")


*******************************************************************************
function r_tempfile( cPath, cExt )
   local cFile

   DEFAULT cPath := ".\"

   _vPath( @cPath )
	while .T.
      cFile := ITOS(_Random(100))+ITOS(_Random(200))+ITOS(_Random(300))
      if Len(cFile) > 7
         cFile := "Z"+Left(cFile, 7)
      else
         cFile := "Z"+cSTRZERO(val(cFile), 7)
      endif
      cFile := cPath+cFile
		if cExt != nil
			cFile := cFile + "." + cExt
		endif
		if ! File( cFile )
			exit
		endif
	enddo
return cFile

*******************************************************************************
function r_erase( cFile )
   local aList := {}
   if cFile != nil
      aList := directory( cFile+".*" )
   endif
   if len(aList) > 0
      aEval(aList, {|cFile| Safe_Erase(cFile[1])})
   endif
return nil

*******************************************************************************
function Erase_Temp( cPath )
   local aList := directory("Z*.*")
   aEval(aList, {|cFile| Safe_Erase(cFile[1])})
return nil

*******************************************************************************
function Safe_Erase( cFile )
	local nH := FOpen( cFile, 2+16 )

	if nH != -1
		FClose(nH)
		FErase(cFile)
	endif
return nil

*******************************************************************************
function strMatch(s1, s2)
   local lRet := .F.
   if alltrim(s1) == alltrim(s2)
      lRet := .T.
   endif
return lRet

*******************************************************************************
function cToken( uValue, nLen, nDeci )
   local cResult, xType := ValType(uValue)

   if ( xType == "U" )
      cResult := "~"
   elseif ( xType == "N" )
      cResult := str(uValue, nLen, nDeci) + "~"
   elseif ( xType == "D" )
      cResult := dtoc(uValue)+"~"
   elseif ( xType == "C" )
      cResult := uValue+"~"
   elseif ( xType == "L" )
      cResult := if(uValue, "T~", "~F")
   endif
return cResult

*******************************************************************************
function DirName( cDrive )
   if cDrive == nil
      cDrive := DiskName()
   endif
return cDrive+":\"+CurDir()

*******************************************************************************
function SaveFields()
	local nI, aFields := {}

	for nI := 1 to FCount()
		aAdd(aFields, FieldGet(nI))
	next
return aFields

*******************************************************************************
function RestFields( aFields )
	local nI

	for nI := 1 to FCount()
		FieldPut(nI, aFields[nI])
	next
return nil

*******************************************************************************
function nValToNum( uValue )
	local nRet := 0, cType := ValType(uValue)

	if ( cType == "N" )
		nRet := uValue
	elseif ( cType == "C" )
		nRet := Val( uValue )
	elseif ( cType == "L" )
		nRet := if(uValue, 1, 0)
	endif
return nRet

*******************************************************************************
function cValToChr( uValue )
	local cRet := "Nil", cType := Valtype( uValue )

	if ( cType == "C" )
		cRet := uValue
	elseif ( cType == "N" )
		cRet := alltrim(str(uValue))
	elseif ( cType == "D" )
		cRet := dtoc(uValue)
	elseif ( cType == "L" )
		cRet := if(uValue, ".T.", ".F.")
	elseif ( cType == "M" )
		cRet := uValue
	endif
return cRet

*******************************************************************************
function BP_WINMAKE(nT, nL, nB, nR, cColors, cTitle, cBox, lShad)
	local aBox, xClr:= SETCOLOR(), xCur:= chr(setcursor()), ;
		xRow:= chr(ROW()), xCol:= chr(COL()), xBli := setblink()
	local xScr:= SAVESCREEN(nT, nL, nB + 1, nR + 2)
	local nW := nR - nL

   DEFAULT cColors := m->_clrBox + "," + m->_clrTitle
   DEFAULT cBox    := BX_SINGLE1
   DEFAULT lShad   := .T.

	aBox:= {nT, nL, nB, nR, xRow, xCol, xCur, xClr, xBli, xScr}
	dispbegin()
   _TShadow(nT, nL, nB, nR, cBox, GetClrPair(cColors, 1), lShad)
	if cTitle <> nil
      dispText(nT, nL + (nW - len(cTitle)) / 2, cTitle, GetClrPair(cColors, 2) )
	endif
	dispend()
return aBox

*******************************************************************************
function winRest(aBox)
	dispBegin()
	restScreen(aBox[01], aBox[02], aBox[03] + 1, aBox[04] + 2, aBox[10])
	setBlink(aBox[09])
	setColor(aBox[08])
	setPos(asc(aBox[05]), asc(aBox[06]))
	setCursor(asc(aBox[07]))
	dispEnd()
return nil

*******************************************************************************
function rs_Now()
return dtoc( date() ) + " " + time()

******************************************************************************
function rms_ntod( nM, nD, nY )
	local xDate, xFormat := set( 4, "mm/dd/yyyy" )
	xDate := transf(nM, "99/") + transf(nD, "99/") + transf(nY,"9999")
	set( 4, xFormat )
return ctod(xDate)

*******************************************************************************
function takeOut(cColors, nPos)
   local cValue:= "", Local2:= 1, Local3:= 1, Local4:= 1

   DEFAULT nPos := 1

   while (Local2 != nPos .AND. Local3 < LEN(cColors))
      if (SUBSTR(cColors, Local3++, 1) == ",")
         Local2++
      endif
   enddo

   if (Local2 == nPos)
      cValue:= SUBSTR(cColors, Local3)
      while (!(SUBSTR(cValue, Local4, 1) == ",") .AND. Local4 <= LEN(cValue))
         Local4++
      enddo
      if (Local4 <= LEN(cValue))
         cValue:= LEFT(cValue, Local4 - 1)
      endif
   endif
return cValue

*******************************************************************************
function _TShadow(nT, nL, nB, nR, cBox, cColors, lShad)
   dispbox(nT, nL, nB, nR, cBox, cColors)
   if lShad
		dbgshadow(nT, nL, nB, nR)
   endif
return nil

*******************************************************************************
function _TFrame( nT, nL, nB, nR, cColor, nFrame, cBox )
   local i, aColor[2]

   DEFAULT nFrame := 0
   DEFAULT cBox := "ÚÄ¿³ÙÄÀ³"

   if nFrame == 0
      aColor[1] := aColor[2]:= cColor
   else
      if (i := at("/", cColor)) > 0
         cColor := SUBSTR(cColor, i+1)
      endif
      if nFrame == 1
         aColor[1] := "w+/" + cColor
         aColor[2] := "n/"  + cColor
      elseif nFrame == 2
         aColor[1] := "n/"  + cColor
         aColor[2] := "w+/" + cColor
      else
         aColor[1]:= cColor + "+/" + cColor
         aColor[2]:= "n/" + cColor
      endif
   endif
	dispBegin()
   dispbox( nT, nL, nB, nR, cBox, aColor[1] )
   if nFrame != 0
      for i := nT + 1 to nB - 1
         dispoutAt( i, nR, SUBSTR(cBox, 8, 1), aColor[2] )
      next i
      for i := nL + 1 to nR - 1
         dispoutAt( nB, i, SUBSTR(cBox, 6, 1), aColor[2] )
      next i
      dispoutAt( nT, nL, SUBSTR(cBox, 1, 1), aColor[1] )
      dispoutAt( nT, nR, SUBSTR(cBox, 3, 1), aColor[2] )
      dispoutAt( nB, nR, SUBSTR(cBox, 5, 1), aColor[2] )
      dispoutAt( nB, nL, SUBSTR(cBox, 7, 1), aColor[1] )
   endif
	dispEnd()
return nil

*******************************************************************************
function _TLine( nT, nL, nR, cColor, cFill )
   local nI, nW := nR - nL + 1

   DEFAULT cColor := setColor()
   DEFAULT cFill := "ÃÄ´"

	dispBegin()
   for nI := nL + 1 to nR - 1
      dispoutAt( nT, nI, SUBSTR(cFill,2,1), cColor )
   next
   dispoutAt( nT, nL, SUBSTR(cFill,1,1), cColor )
   dispoutAt( nT, nR, SUBSTR(cFill,3,1), cColor )
	dispEnd()
return nil

*******************************************************************************
function rmsBox(nT, nL, nH, nW, nType, cTitle, cColor, cBox, lShad, nFrame )
   local aColor, aBox
   local nB := nT + nH, nR := nL + nW
   local xScr:= saveScreen(nT, nL, nB + 1, nR + 2)

   DEFAULT lShad := .T.

   if nType == 1 // winbox
      cBox := "ÚÄ¿³ÙÄÀ³"+chr(255)
   elseif nType == 2 // normal
      DEFAULT nFrame :=  0
   elseif nType == 3 // qbox
      DEFAULT cColor := m->_clrQBox
      cBox := repl(chr(255), 9)
   elseif nType == 4
      cBox := "ÚÄ¿³ÙÄÀ³"+chr(255)+"ÃÄ´"
   elseif nType == 5
      DEFAULT cColor := m->_clrQBox
      cBox := repl(chr(255), 9)
   endif

   if cColor == nil
      cColor := m->_clrBox + "," + m->_clrTitle
   endif

   if cBox == nil
      cBox := "ÚÄ¿³ÙÄÀ³"+chr(255)
   endif

   aBox := { nT, nL, nB, nR, chr(row()), chr(col()), chr(setCursor()), ;
             setColor(), setBlink(), xScr }

   setCursor(0)
	aColor := rms_Parse(cColor)
   dispBegin()
   if nType == 1
      _TFrame( nT+1, nL, nB, nR, aColor[01], 1, cBox)
      dispoutAt(nT, nL, padr("[þ] " + cTitle, nW+1), aColor[02] )
      dbgshadow(nT, nL, nB, nR)
   elseif nType == 2
      _TFrame( nT, nL, nB, nR, aColor[01], nFrame, cBox )
      if cTitle != nil
         dispoutAt(nT, nL + ( (nW - LEN(cTitle)) / 2 ) + 1, cTitle, aColor[02])
      endif
      if lShad
         dbgshadow(nT, nL, nB, nR)
      endif
   elseif nType == 3
      _TShadow( nT, nL, nB, nR, cBox, aColor[01], lShad )
      dispoutAt( nT, nL, repl("ß", nW+1), aColor[03])
      dispoutAt( nT+1, nL, padc(cTitle, nW+1), aColor[02] )
      dispoutAt( nT+2, nL, repl("Ä", nW+1), aColor[01] )
   elseif nType == 4
      _TShadow( nT, nL, nB, nR, left(cBox,9), aColor[01], lShad )
      if cTitle != nil
         _TLine(nT+2,nL,nR,aColor[01],SUBSTR(cBox,10,3))
         dispoutAt(nT+1,nL+1, padc(cTitle,nW-1), aColor[02])
      endif
   elseif nType == 5
      _TShadow( nT, nL, nB, nR, cBox, aColor[01], lShad )
      dispoutAt( nT, nL, repl("ß", nW+1), aColor[03])
   endif
   dispEnd()
   setCursor(asc(aBox[07]))
return aBox

*******************************************************************************
function do_cps(cKEY, cFuncNM)
	local cRetVal := "", nReqno, cMess
   local lPAUSE  := .F., nX := 0, lRet := .F.

   DEFAULT cKey := " "
   begin sequence
      if len(cKEY) > 1000
         ALERT("cKEY LENGTH EXCEEDS cpsq->PARAMS LIMIT! ;; PLEASE CONTACT ICT DEPARTMENT.")
         break
      endif
      cFuncNM := upper(if(len(cFuncNM) > 15, left(cFuncNM, 15), cFuncNM))

      if ! File("&g_CPS_PATH\STARTUP.DBF")
         Error("Connection to Central Processing is missing.")
         break
      endif
      if !Netuse( "&g_CPS_PATH\STARTUP",.F.,5 )
         break
      endif
      if (Empty(STARTUP->DATE) .OR. Empty(STARTUP->TIME)) .AND. STARTUP->MULTIPLE == 0
         Error("Central Processing is offline. Call IT dept.")
         break
      endif
      lRet := .T.
   end sequence
   close_if("startup")

   if !lRet
      return cRetVal
   endif

   WkArea(.T.); Desktop(.T.) ; setblink(.T.)
	begin sequence
      if !NetUse( "&g_CPS_PATH\cpsq", .F., 5 )
			break
		endif
		cpsq->( dbappend() )
		cpsq->user		 := m->g_USER_ID
      cpsq->brcode    := m->g_PAR_BRCH
		cpsq->req_type  := cFuncNM
		cpsq->params	 := cKey
		cpsq->status	 := "W"
		cpsq->datestart := date()
		cpsq->timestart := time()
		nReqno := cpsq->( dbrunlock(), recno() )

		setcursor(0)
		while .T.
			cpsq->( dbgoto(nReqno) )
			do case
				case cpsq->status == "C"
					cMess   := "   REQUEST COMPLETED   "
					cRetVal := alltrim(cpsq->tempfile)
					exit
				case cpsq->status == "P"
               cMess   := " REQUEST IS PROCESSING "
               *cMess := "PROCESSING " + cFuncNM
				case cpsq->status == "W"
					cMess   := "  REQUEST IS ON QUEUE  "
				case cpsq->status == "I"
					cMess   := "REQUEST IS INVALID. PRESS ANY KEY."
					lPAUSE  := .T.
				case cpsq->status == "H"
					cMess   := "REQUEST WAS HALTED. PRESS ANY KEY"
					lPAUSE  := .T.
			endcase

			*cMess := padc(cMess, 25)
			nX := int((80-len(cMess))/2)
         rmsBox(11,nX,02,LEN(cMess)+1,2,,"N/BG" )
			dispoutat( 12, nX+1, cMess, "gr+*/bg" )

			if lPAUSE
				lPAUSE := .F.
				inkeytrap(0)
				exit
			else
				Inkeytrap(2)
			endif
			if lastkey() == K_ALT_Q
            cpsq->( rlock() )
            cpsq->status  := "H"
            cpsq->dateend := date()
            cpsq->timeend := time()
				cpsq->( dbunlock(), dbcommit() )
			endif
		enddo
		close_if( "cpsq" )
	end sequence
	WkArea(.F.); Desktop(.F.)
	*Remind( cRetVal )
return cRetVal
