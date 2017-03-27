#include "inkey.ch"
#include "rms.ch"

#define  SET_IVAR( v, p ) iif( p == nil, nil, v := p )

#define  RBX_SPACE        repl(chr(255), 9)
********************************************************************************
function TBrowNew( nTop, nLeft, nBottom, nRight, cColors, cHeadSep, cColSep, ;
                   cFootSep, nFreeze )
   local oTbr

   DEFAULT cColors  := m->_clrBrowse
   DEFAULT cHeadSep := "ÑÍ"
   DEFAULT cColSep  := "³"

   oTbr := TBrowseDB( nTop, nLeft, nBottom, nRight )
   *oTbr := TBrowseNew( nTop, nLeft, nBottom, nRight )

   oTbr:colorSpec := cColors
   oTbr:headSep   := cHeadSep
   oTbr:colSep    := cColSep

   SET_IVAR( oTbr:Freeze, nFreeze )
   SET_IVAR( oTbr:footSep, cFootSep )
   oTbr:autolite(.F.)
   oTbr:cargo({{}, nil, nil, nil, .F., 0, 0})
return oTbr

********************************************************************************
function TBrColNew( oTBr, bData, cTitle, nWidth, cFooter, anColors, bColor, ;
                   FSep, cPict )
   local oCol := TBColumnNew(cTitle, bData)

   DEFAULT bColor := {|| {1,2} }

   SET_IVAR( oCol:width,      nWidth)
   SET_IVAR( oCol:footing,    cFooter)
   SET_IVAR( oCol:defColor,   anColors)
   SET_IVAR( oCol:colorBlock, bColor)
   SET_IVAR( oCol:footSep,    FSep)
   SET_IVAR( oCol:picture,    cPict)
   oTBr:addcolumn( oCol )
return oCol

********************************************************************************
function Seek2( uValue, pnArea, pxOrder, plRestRec, lRestOrd, plSoft, plDelOff )
	local nArea := select(), nOrder, lFound, nRecno
	local lDel := set( 11 ) // set deleted

   if pnArea == Nil
      pnArea := nArea
   endif
   dbSelectArea( pnArea )

   nOrder := indexord()
   if pxOrder == Nil
      pxOrder := nOrder
   endif
   ordSetFocus( pxOrder )

   nRecno := Recno()
	if plDelOff
		set( 11, "off" )
	else
		set( 11, "on" )
	endif
   dbSeek( uValue, plSoft )
	lFound := found()
	set( 11, lDel )
	if plRestRec
		dbGoto( nRecno )
	endif
   if lRestOrd
		ordSetFocus( nOrder )
		dbSelectArea( nArea )
	endif
return lFound

*******************************************************************************
function TFormatCol( aArray )
   local oCol := TBColumnNew()
   local xValue := aArray[2]

   oCol:heading := aArray[1]
   if valtype(xValue) == "C"
      oCol:block := FieldBlock(xValue)
   else
      oCol:block := xValue
   endif
   oCol:picture := aArray[3]
   oCol:width   := aArray[4]
return oCol

*******************************************************************************
function Search( nT, nL, nH, paFlds, cAlias, pxOrder, cTitle, lRestOrd, cColors )
   local oTB, oCol, nKey, cKey, nR, nW
   local nRec, nPrevRec, i
   local aColor, nOrder, nArea := Select()
   local nSubs := 1, aOrdList := {}
   local lRetVal := .F.
   local xColor, cSeek
   local getlist := {}

   DEFAULT nT      := 3
   DEFAULT nH      := MaxRow(.T.) - 4
   DEFAULT cColors := m->_clrBrowse
   DEFAULT cAlias  := nArea
   DEFAULT cTitle  := " Select Records "

   dbSelectArea( cAlias )
   nOrder := indexord()
   setif( @pxOrder, nOrder )
   ordSetFocus( pxOrder )
	nPrevRec := Recno()
   aColor := rms_Parse(cColors)

   nSubs := indexord()
	for i := 1 to 15
		if (!(Len(Trim(ordkey(i))) == 0))
			aAdd(aOrdList, { i, ordkey(i) } )
		endif
	next

	if eof()
		dbGoTop()
	endif

   nW := 0
	for i := 1 to len(paFlds)
      nW += paFlds[i, 4] + 1
	next
   nW += 2
   if nL == nil
      nL := int( (maxcol(.T.)+1-nW) / 2 )
	endif
   nR := nL + nW
   Desktop(.T.) ; SetBlink(.F.)
   rms_set( aColor[2], 0)
   oTB := TBrowNew(nT+1, nL+1, nH-2, nR-1, cColors, "ÑÍ","³","ÏÍ" )
   for i := 1 to len( paFlds )
      oCol := TFormatCol( paFlds[i] )
		oTB:AddColumn( oCol )
   next

   dispbegin()
   rmsBox( nT, nL, nH-nT, nW,2,cTitle,aColor[3]+","+aColor[4],RBX_SPACE )
	dbRefresh( oTB )
	dispend()
   while .T.
      dispbegin()
      *dispText( nH, nL+1, padr("Key: " + ordkey(), nW-1), aColor[3] )
      dispoutAt( nH-1,nL+1, space(nW-1), aColor[2] )
		oTB:forceStable()
      dispend()
		nRec := Recno()
      nKey := THighlight( oTB, oTB:rowpos, 1, oTB:colcount )
		do case
         case TNavigate( oTB, nKey, .F. )

         case nKey == K_ESC
				dbGoto(nPrevRec) ; Exit

         case nKey == K_ENTER
            lRetVal := .T.; Exit

         case nKey == K_ALT_O .AND. Len(aOrdList) > 1
				if nSubs++ >= len(aOrdList)
					nSubs := 1
				endif
				dispbegin()
				ordSetFocus( aOrdList[nSubs, 1] )
				oTB:refreshAll():forceStable()
            dispend()

         case (nKey >= 32 .AND. nKey <= 255)
            cSeek := upper(chr(nKey)) + space(nW-2)
            begin sequence
               __Keyboard(chr(K_END))
               xColor := setColor(aColor[2]+","+aColor[2])
               @nH-1, nL+1 get cSeek pict "@!"
               setCursor(1)
               read
               setCursor(0)
               if lastkey() == K_ESC
                  break
               endif
               dbSeek(cSeek, .T.)
               dbRefresh( oTB )
            end sequence
		endcase
	enddo
   Desktop(.F.)
   if lRestOrd
		ordSetFocus( nOrder )
		dbSelectArea( nArea )
	endif
return (lRetVal)

*******************************************************************************
function ABrowse( nT, nL, nH, cAlias, nIndex, aColumns, cTitle, bScope, cColors )
   local nKey, nLen, lRet := .F.
   local i, aColor, nW, aList := {}, aHeads := {}
   local oTB, oCol, nRec := 0 , nRecs
   local nArea, nOrder
   local cSeek := "", getlist := {}
   private nRow

   DEFAULT nT := 3
   DEFAULT nH := maxrow()-4
   DEFAULT cTitle := "Select Records"
   DEFAULT bScope := {|| .T.}
   DEFAULT cColors := m->_clrBrowse+","+m->_clrBox

   nRecs := nH - nT - 3
   nArea := select() ; dbSelectArea( cAlias )
   nOrder := indexord(); ordSetFocus( nIndex )

   if eof()
      (cAlias)->( dbGoTop() )
   endif
   aList := FillData( cAlias, aColumns, nRecs, bScope )
   if len(aList) < 1
      Error( "Database is Empty." )
      return .f.
   endif

   nLen := 0
   for i := 1 to len(aColumns)
      aAdd( aHeads, aColumns[i, 1] )
      nLen += aColumns[i, 4] + 1
   next
   if nL == nil
      nL := int( (maxcol(.T.)+1 - nLen) / 2 )
   endif
   nW := nL + nLen + 2

   oTB := TBrowNew( nT+1, nL+1, nH-1, nW-1,cColors,"ÑÍ","³","ÏÍ" )
   oTB:SkipBlock     := { |x| x := _ASkip(aList, m->nRow, x), m->nRow += x, x }
   oTB:GoTopBlock    := { | | m->nRow := 1 }
   oTB:GoBottomBlock := { | | m->nRow := len(aList) }

   m->nRow := 1
   for i := 1 to len( aList[m->nRow] ) - 1
      *oCol := TBColumnNew( aHeads[i], _ABlock(aList, i) )
      oCol := _TColumn(aHeads, aList, m->nRow, i)
      oTB:AddColumn(oCol)
   next

   Desktop(.T.) ; SetBlink(.F.)
   aColor := rms_Parse(cColors)
   rms_set( aColor[1], 0)

	dispbegin()
   rmsBox( nT, nL, nH-nT, nLen+2,2,cTitle,aColor[3]+","+aColor[4],RBX_SPACE )
   oTB:configure():invalidate():forcestable()
	dispend()

   __keyboard()
   while .T.
      oTB:forcestable()
      oTB:colorRect({oTB:rowpos, 1, oTB:rowpos, oTB:colCount }, {2,1})
      nKey := inkeytrap(0)
      oTB:colorRect({oTB:rowpos, 1, oTB:rowpos, oTB:colCount }, {1,1})
      do case
         case nKey == K_ESC ; exit
         case nKey == K_ENTER
            lRet := .T.; nRec := aList[m->nRow, oTB:colCount+1] ; exit
         case nKey == K_CTRL_PGUP ; oTB:gotop()
         case nKey == K_CTRL_PGDN ; oTB:gobottom()
         case nKey == K_UP        ; oTB:up()
         case nKey == K_DOWN      ; oTB:down()
         case nKey == K_PGUP
            oTB:gotop()
            do_GetPrev( oTB, cAlias, aColumns, nRecs, aList[m->nRow, oTB:colcount+1], @aList, bScope )
         case nKey == K_PGDN
            oTB:gobottom()
            do_GetNext( oTB, cAlias, aColumns, nRecs, recno(), .T., @aList, bScope )

         case (nKey >= 32 .AND. nKey <= 255)
            cSeek := upper(chr(nKey)) + space(nLen-2)
            begin sequence
               __Keyboard(chr(K_END))
               setcolor(aColor[2]+","+aColor[2])
               @nH, nL+2 get cSeek pict "@!"
               setcursor(3)
               read
               setcursor(0)
               if lastkey() == K_ESC
                  break
               endif
               dbSeek(cSeek, .T.)
               do_GetNext( oTB, cAlias, aColumns, nRecs, recno(), .F., @aList, bScope )
            end sequence
            dispText(nH, nL+2, space(nLen-1), aColor[3])
      endcase
   enddo
   Desktop(.F.)
   if nRec != 0
      dbGoto( nRec )
   endif
   ordSetFocus( nOrder )
   dbSelectArea( nArea )
return (lRet)

*******************************************************************************
function _ASearch( uSeek, cAlias, uOrder, aColumns, nT, nL, nH, cTitle, bScope, cColor )
   local nKey, nLen, lRet := .F.
   local i, aColor, nW, aList := {}, aHeads := {}
   local oTB, oCol, nRec := 0, nRecs
   local nArea, nOrder
   local cSeek := "", getlist := {}
   private nRow

   DEFAULT nT := 3
   DEFAULT nH := maxrow()-4
   DEFAULT cTitle := "Select Records"
   DEFAULT bScope := {|| .T.}
   DEFAULT cColor := m->_clrBrowse+","+m->_clrBox

   nRecs := nH - nT - 3
   nArea := select() ; dbSelectArea( cAlias )
   nOrder := indexord(); ordSetFocus( uOrder )

   (cAlias)->( dbSeek(uSeek, .T.) ) // starting record
   aList := FillData( cAlias, aColumns, nRecs, bScope )
   if LEN(aList) < 1
      Error( "Empty records." )
      return .f.
   endif

   nLen := 0
   for i := 1 to len(aColumns)
      aAdd( aHeads, aColumns[i, 1] )
      nLen += aColumns[i, 4] + 1
   next
   if nL == nil
      nL := int( (maxcol(.T.)+1 - nLen) / 2 )
   endif
   nW := nL + nLen + 2

   oTB := TBrowNew( nT+1, nL+1, nH-1, nW-1,cColor,"ÑÍ","³","ÏÍ" )
   oTB:SkipBlock     := { |x| x := _ASkip(aList, m->nRow, x), m->nRow += x, x }
   oTB:GoTopBlock    := { | | m->nRow := 1 }
   oTB:GoBottomBlock := { | | m->nRow := len(aList) }

   m->nRow := 1
   for i := 1 to len( aList[m->nRow] ) - 1
      *oCol := TBColumnNew( aHeads[i], _ABlock(aList, i) )
      oCol := _TColumn(aHeads, aList, m->nRow, i)
      oTB:AddColumn(oCol)
   next

   Desktop(.T.) ; SetBlink(.F.)
   aColor := rms_Parse(cColor)
   rms_set( aColor[1], 0)

	dispbegin()
   rmsBox( nT, nL, nH-nT, nLen+2,2,cTitle,aColor[3]+","+aColor[4],RBX_SPACE )
   oTB:configure():invalidate():forcestable()
	dispend()

   __keyboard()
   while .T.
      oTB:forcestable()
      oTB:colorRect({oTB:rowpos, 1, oTB:rowpos, oTB:colCount }, {2,1})
      nKey := inkeytrap(0)
      oTB:colorRect({oTB:rowpos, 1, oTB:rowpos, oTB:colCount }, {1,1})
      do case
         case nKey == K_ESC ; exit
         case nKey == K_ENTER
            lRet := .T.; nRec := aList[m->nRow, oTB:colCount+1] ; exit
         case nKey == K_CTRL_PGUP ; oTB:gotop()
         case nKey == K_CTRL_PGDN ; oTB:gobottom()
         case nKey == K_UP        ; oTB:up()
         case nKey == K_DOWN      ; oTB:down()
         case nKey == K_PGUP
            oTB:gotop()
            do_GetPrev( oTB, cAlias, aColumns, nRecs, aList[m->nRow, oTB:colcount+1], @aList, bScope )
         case nKey == K_PGDN
            oTB:gobottom()
            do_GetNext( oTB, cAlias, aColumns, nRecs, recno(), .T., @aList, bScope )

         /*
         case nKey == K_ALT_F1
            remind( aList[m->nRow, oTB:colcount+1],,,.F. ) */

         case (nKey >= 32 .AND. nKey <= 255)
            cSeek := upper(chr(nKey)) + space(nLen-2)
            begin sequence
               __Keyboard(chr(K_END))
               setcolor(aColor[2]+","+aColor[2])
               @nH, nL+2 get cSeek pict "@!"
               setcursor(3)
               read
               setcursor(0)
               if lastkey() == K_ESC
                  break
               endif
               dbSeek(cSeek, .T.)
               do_GetNext( oTB, cAlias, aColumns, nRecs, recno(), .F., @aList, bScope )
            end sequence
            dispText(nH, nL+2, space(nLen-1), aColor[3])
      endcase
   enddo
   Desktop(.F.)
   if nRec != 0
      dbGoto( nRec )
   endif
   ordSetFocus( nOrder )
   dbSelectArea( nArea )
return (lRet)

*******************************************************************************
static function _TColumn(aHeads, aArray, nRow, nSub)
   local oCol := TBColumnNew(aHeads[nSub], _ABlock(aArray, nSub))
return oCol

*******************************************************************************
static function _ASkip( aArray, nCurrent, nSkip )
   if (nCurrent + nSkip < 1)
      return (-nCurrent + 1)
   elseif (nCurrent + nSkip > len(aArray) )
      return ( len(aArray) - nCurrent )
   endif
return (nSkip)

******************************************************************************
static function _ABlock( aArray, nIndex )
Return ( {|p| IF( p == nil, aArray[m->nRow, nIndex], aArray[m->nRow, nIndex] := p ) } )

*******************************************************************************
static function do_GetNext(oTB, nArea, aColumns, nRecs, nRecNo, lSkip, aList, bScope)
   local i, oCol, aHeads := {}

   DEFAULT lSkip := .T.
   select(nArea) ; dbGoto(nRecno)
   if lSkip
      dbSkip()
   endif
   if eof()
      oTB:gobottom()
   else
      for i := 1 to len(aColumns)
         aAdd( aHeads, aColumns[i, 1] )
      next
      aList := FillData(nArea, aColumns, nRecs, bScope )
      if len(aList) == 0
         do_GetPrev( oTB, nArea, aColumns, nRecs, nRecno, @aList, bScope )
         oTB:gobottom()
      endif
      oTB:goTop()
      for i := 1 to oTB:colcount()
         oCol := _TColumn(aHeads, aList, m->nRow, i)
         oTB:SetColumn(i, oCol)
      next
   endif
return nil

*******************************************************************************
static function do_GetPrev(oTB, nArea, aColumns, nRecs, nRecno, aList, bScope)
   local i, oCol, nCtr := 0, aHeads := {}

   select (nArea) ; dbGoto(nRecno)
   while (nRecs > nCtr) .AND. ! bof()
      if eval(bScope)
         nCtr++
      endif
      *remind( str(nRecs)+" "+str(nCtr)+" "+str(recno()) ,,, .F. )
      dbSkip(-1)
   enddo

   for i := 1 to len(aColumns)
      aAdd( aHeads, aColumns[i, 1] )
   next
   aList := FillData(nArea, aColumns, nRecs, bScope )
   oTB:goTop()
   for i := 1 to oTB:colcount()
      oCol := _TColumn(aHeads, aList, m->nRow, i)
      oTB:SetColumn(i, oCol)
   next
return nil

******************************************************************************
static function FillData( nArea, aColumns, nRecs, bScope )
   local aArows, aArray := {}
   local nRec, nCtr := 1, nCol := 1
   local i, xValue, nPos

   dbSelectArea(nArea)
   while ! eof()
      if eval( bScope )
         aArows := {}
         for i := 1 to len(aColumns)
            nPos := FieldPos(aColumns[i,2])
            xValue := FieldGet(nPos)
            if aColumns[i, 5]
               xValue := r_decrypt(xValue)
            endif
            xValue := trans( xValue, aColumns[i,3] )
            xValue := padr(xValue, aColumns[i,4] )
            aAdd(aArows, xValue )
         next
         aAdd( aArows, recno() )
         aAdd( aArray, aArows )
         if nCtr++ >= nRecs
            Exit
         endif
      endif
      dbSkip(+1)
   enddo
return aArray

*******************************************************************************
function THighlight( oB, nT, nL, nR )
   local nKey

   oB:colorRect( {nT, nL, nT, nR}, {2,1} )
   nKey := inkeytrap(0)
   oB:colorRect( {nT, nL, nT, nR}, {1,2} )
return nKey

*******************************************************************************
function TNavigate( brow, key, xtra )
   local lRet := .T.

   DEFAULT xtra := .T.

	do case
      case key == K_DOWN  ; brow:down()
      case key == K_UP    ; brow:up()
      case key == K_PGDN  ; brow:pagedown()
      case key == K_PGUP  ; brow:pageup()
      case key == K_CTRL_PGUP ; brow:gotop()
      case key == K_CTRL_PGDN ; brow:gobottom()

      case key == K_RIGHT      .AND. xtra ; brow:right()
      case key == K_LEFT       .AND. xtra ; brow:left()
      case key == K_HOME       .AND. xtra ; brow:home()
      case key == K_END        .AND. xtra ; brow:end()
      case key == K_CTRL_LEFT  .AND. xtra ; brow:panleft()
      case key == K_CTRL_RIGHT .AND. xtra ; brow:panright()
      case key == K_CTRL_HOME  .AND. xtra ; brow:panhome()
      case key == K_CTRL_END   .AND. xtra ; brow:panend()
		otherwise
         lRet := .F.
	endcase
return lRet

*******************************************************************************
function dbBrowse( oBrowse, cAlias, nOrder, cTitle, aOptions, aOthers, cColors )
   local nArea := Select(), xOrder
   local i, nB, nR, aColor
   local nKey, cKeys := "", aStat := " "
   local aAction := {}, nSubs, aOrdList := {}
   local nT := oBrowse:ntop,;
         nL := oBrowse:nleft,;
         nH := oBrowse:nBottom,;
         nW := oBrowse:nright

   if cColors == Nil
      cColors := oBrowse:colorSpec + ",r/bg,w+/bg"
   endif

   xOrder := iOrder( cAlias, nOrder )
   aColor := rms_Parse(cColors)

   nSubs := nOrder
	for i := 1 to 15
      if (!(Len(Trim(ordkey(i))) == 0))
			aAdd(aOrdList, { i, ordkey(i) } )
      endif
	next

   for i := 1 to len(aOptions)
      if aOptions[i, 1]
         cKeys += chr(aOptions[i, 2])
         aStat += aOptions[i,3]
         aAdd(aAction, aOptions[i, 4])
      endif
   next i

   if len(aOthers) < 3
      ASize(aOthers, 3)
      aOthers[3] := .F.
   endif

   if aOthers[2]
      aStat += " ~Enter~-Select "
   endif

   if aOthers[1]
      aStat += " ~Esc~-Exit "
   endif

   if eof() .OR. ! aOthers[2]
      dbGoTop()
   endif

   nB := nT + nH ; nR := nL + nW
   Desktop(.T.) ; SetBlink(.F.) ; SetCursor(0)
   rmsBox( nT, nL, nH, nW, 3, cTitle, aColor[1]+","+aColor[5]+","+aColor[6] )
   StatLine( aStat, aColor[5]+","+aColor[1], nL, nB, nW+1 )

   oBrowse:nTop    := nT + 3
   oBrowse:nLeft   := nL //+ 1
   oBrowse:nBottom := nB - 1
   oBrowse:nRight  := nR //- 1
   oBrowse:colorSpec := cColors
   SET_IVAR( oBrowse:footsep, "ÁÄ")

   while .T.
      *dispoutat( nB, nL+1, padr("INDEX: " + ordkey(), nW-1), aColor[5] )
      dispbegin()
      oBrowse:forceStable()
      dispend()
      if aOthers[3]
         nKey := THighlight( oBrowse, oBrowse:rowpos, oBrowse:colpos, oBrowse:colpos )
      else
         nKey := THighlight( oBrowse, oBrowse:rowpos, oBrowse:leftvisible, oBrowse:rightvisible )
      endif
      do case
         case TNavigate( oBrowse, nKey, aOthers[3] )
         case chr(nKey) $ cKeys
            i := At(chr(nKey),cKeys)
            eval(aAction[i])
            __Keyboard()
         case nKey == K_ESC .AND. aOthers[1]
            exit
         case nKey == K_ENTER .AND. aOthers[2] .AND. ! deleted()
            exit
         case nKey == K_ALT_O .AND. len(aOrdList) > 1
            if ++nSubs > len(aOrdList)
               nSubs := 1
            endif
            ordsetfocus( aOrdList[nSubs, 1] )
            dbRefresh( oBrowse )
         case nKey == K_ALT_S
            do_search()
            dbRefresh( oBrowse )
      endcase
   enddo
   Desktop(.F.)
   ordsetfocus(xOrder)
   dbSelectAr( nArea )
return nil

******************************************************************************
static function do_search()
   local lFound := .F.
   local cText := space(40)
   local nT := 09, nL := 15
   local aBox, getlist := {}

   begin sequence
      aBox := rmsBox( nT,nL,05,47,2," Search ", "n/gr,w+/r", "ÉÍ»º¼ÍÈºÿ" )
      setBlink(.F.) ; rms_Set( "n/gr,n/g,,,w+/gr", 1)
      dispoutAt(nT+2,nL+12, "Enter data to search for: ")
      dispoutAt(nT+3,nL+03, "["+padr(".",40)+"]" )
      @nT+3,nL+4 get cText pict "@!" valid !empty(cText)
      read
      if lastkey() == K_ESC
         break
      endif
      lFound := dbSeek( cText, .T. )
      if eof()
         dbSkip(-1)
      endif
   end sequence
   winRest(aBox)
return lFound

*******************************************************************************
function dbRefresh( oTB )
   local nRec

	if eof()
		dbSkip(-1)
	endif
	nRec := Recno()
	dispbegin()
	oTB:refreshall()
	while ! oTB:Stabilize() ; enddo
	while ( Recno() != nRec )
		oTB:up()
		while ! oTB:Stabilize() ; enddo
	enddo
	dispend()
return nil

*******************************************************************************
static function iOrder( nArea, xOrder )
   local nOrder
   dbSelectArea( nArea )
   nOrder := indexord()
   ordsetfocus( xOrder )
return nOrder

*******************************************************************************
function dbStable( oTB, nArea )
   dispBegin()
   dbSelectArea(nArea)
   oTB:autolite := .F.
   oTB:refreshAll(): forcestable()
   dispEnd()
return nil
