#include "colf.ch"
#include "inkey.ch"
#include "setcurs.ch"
#include "memoedit.ch"
#include "dbstruct.ch"


//chi-----------
#defi color_colo  'gr+/bg, w+/n'
#defi color_mono  'gr+/n, n/w'
#defi sound_one    tone( 60, .5 )
#defi sound_two    tone( 480, 0.25 ); tone( 240, 0.25 )
#defi frozen       0

//--------------
*#defi color_colo  'gr+/bg, w+/n'
*#defi color_mono  'gr+/n, n/w'
*#defi sound_one    tone( 60, .5 )
*#defi sound_two    tone( 480, 0.25 ); tone( 240, 0.25 )
*#defi frozen       0
*
*/*----------------------------------------------------------------*/
*
**                     1  2    3     4      5     6     7     8     9      10    11      12      13      14       15
*FUNCTION flook_online(SW,nDBF,lSEEK,lTITLE,nFLD1,nFLD2,nFLD3,nFLD4,gETFLD,lWIND,lTBCLMN,lFLTER1,lFLTER2,reinpath,lBR)
*/*----------------------------------------------------------------*/
*local dbfaray:={},newcolor,oldcolor,rt_value,b,oldscr:=savescreen(),_crpos:=0,chrsk:=''
*local curcolo:=iscolor(),col,ret_value,curdbf,curntx,r1,r2,c1,c2,nbot,ntop,nleft,nright
*local pArray:={},ch,tPara:=0,ncount:=0,zz,y,x,cd,mval,local_str,bstru_,norder
*LOCAL lFND  := .F.
*
*priv gigi := 1, when := 1
*aadd(dbfaray, { select(), indexord(), recno(), setcolor(), setcursor(),;
*         savescreen()} )
*
*if !empty(nDbf)
*    Dbselectarea(nDBF)
*    norder:= ( nDBF )->(indexord())
*endif
*SetCursor(0)
*
*if !file('&g_CIS_PATH\Reindex.dbf')
*   rt_value := lSeek
*else
*   if netuse('&g_CIS_PATH\reindex',.f.,10)
*     dbsetindex('&g_CIS_PATH\reindex')
*   endif
*
*   if(!empty(nDbf),eval({|| dbseek(alltrim(upper(nDbf))) } ),.t.)
*      if sw
*         if nDbf == nil
*            dbselectarea(dbfaray[1,1])
*            dbsetorder(dbfaray[1,2])
*         else
*            dbselectarea(nDbf)
*            dbsetorder( norder )
*         endif
*         if !empty(lSeek)
*            if !dbseek(lSeek)
*               dbgotop()
*            endif
*         else
*            dbgotop()
*         endif
*      else
*         curdbf:=alltrim(reindex->filename)
*         curntx:=alltrim(reindex->index_name)
*
*         if netuse(curdbf,.f.,5)
*            if !empty(curntx)
*               dbsetindex(curntx)
*            endif
*         endif
*
*         if !empty(lSeek)
*            if !dbseek(lSeek)
*               dbgotop()
*            endif
*         else
*            dbgotop()
*         endif
*      endif
*
*      nfld1:=if(empty(nfld1),1,nFld1)
*      nfld2:=if(empty(nfld2),2,nFld2)
*      nfld3:=if(empty(nfld3),if(fcount() < 3,nil,3),nFld3)
*      nfld4:=if(empty(nfld4),NIL,nFld4)
*
*      bstru_:=dbstruct()
*      lTitle := if( lTitle == nil, alias(), lTitle)
*      lWind  := if( lWind == nil, .t., lWind)
*
*      if !lWind
*         r1 :=  5
*         c1 :=  4
*         r2 := 20
*         c2 := 74
*      else
*         r1 := 5
*         c1 := if( getactive():col < 40, 24, 2 )
*         r2 := r1 + 15
*         c2 := c1 + 53
*      endif
*
*      ntop   := r1
*      nleft  := c1
*      nBot   := r2
*      nright := c2
*      zz:=savescreen( , , , )
*      cd:=setcolor()
*
*      setcolor('w/gr')
*      @ nTOp, nleft clear TO nbot, nright
*
*      setcolor(cd)
*      baks(nTOp, nleft ,nbot, nright,lTitle,'w+/gr')
*      ncount:=IF(!empty( lSeek ),len(if(valtype(lSeek)=='N',alltrim(str(lseek)),alltrim(lseek)))+2,(c2-c1)-6)
*
*      if ncount >=(nright-6)-(nleft+3)
*         ncount:=(nright-9)-(nleft+3)
*      endif
*
*      cd:=setcolor()
*      setcolor('w/n')
*      @nbot,nleft+5 say replicate(chr(176),(nright-6)-(nleft+3)) colo 'w+/n'
*      @nbot,nleft+4+int(((nright-6)-(nleft+3))/2) say '_'  color 'w+/n'
*
*      setcolor(cd)
*      b := TBrowsedb()
*      b:ntop          := r1 + 1
*      b:nleft         := c1 + 2
*      b:nbottom       := r2 - 1
*      b:nright        := c2 - 2
*
*      if lflter1 == nil
*         b:gotopblock    := { |   | fRec1Pos( 'top'     ) }
*         b:gobottomblock := { |   | fRec1Pos( 'bottom'  ) }
*         b:skipblock     := { | n | fRec1Pos( 'skip', n ) }
*      else
*         b:gotopblock    := { |   | fRec2Pos( 'top'   , EVAL(lflter1) ) }
*         b:gobottomblock := { |   | fRec2Pos( 'bottom', EVAL(lflter1) ) }
*         b:skipblock     := { | n | fRec2Pos( 'skip'  , lflter1, { | x | EVAL(lflter2) == x }, n ) }
*      endif
*
*      b:colpos        := 1
*      b:headSep       := "ÒÄ"
*      b:colSep        := "º"
*      b:colorspec     :=  "w/bg+,w/n,w/n,w/n,w/n,w/n,w/n,w/n,w/n,w/n,w/bg+"
*                         //"n+/w,w/n,w+/n,w+/n,w+/n+,w+/n+,w+/n+,w+/n,w+/n+,w+/n,n+/w+"
*                         //"w+/n,n/w,n/w,n/w,n/w+,n/w+,n/w+,n/w,n/w+,n/w,w+/n"
*      if(!empty(nFld1),aadd(pArray,nFld1),.t.)
*      if(!empty(nFld2),aadd(pArray,nFld2),.t.)
*      if(!empty(nFld3),aadd(pArray,nFld3),.t.)
*      IF(!EMPTY(nFLD4),AADD(pARRAY,nFLD4),.T.)
*
*      if lTbclmn == nil  .or. len(lTbclmn) < 1
*         if !empty(nFld1) .and. !empty(nFld2) .and. !empty(nFld3) &&.AND. !EMPTY(nFLD4)   RED 101404
*            for y:=1 to len(pArray)  //tPara
*                if pArray[y] <> nil
*                   col := tbcolumnNew()
*                   col:heading := substr(fieldname(pArray[y]),1,1)+lower(substr(fieldname(pArray[y]),2,12))
*
*                   if valtype(fieldget(pArray[y])) # 'M'
*                      col:block   := fieldblock(field(pArray[y]))
*                      col:width   := if( bstru_[fieldpos( field(pArray[y]) )][DBS_LEN] > 25, 25,;
*                                     if( valtype(fieldget(pArray[y])) == 'D', 10, ;
*                                     IF( bstru_[fieldpos( field( pArray[y] ) )][DBS_LEN] < len(field(pArray[y])),;
*                                        len( field(pArray[y]) ),bstru_[ fieldpos( field(pArray[y] ) ) ][ DBS_LEN ] ) ) )
*                   else
*                      col:block  := {|| '<MEMO>' }
*                      col:WIDTH   := 6
*                   endif
*
*                   b:addcolumn(col)
*                endif
*            next
*         else
*            for y := 1 to fcount()
*               col:= tbcolumnNew()
*               col:heading:= substr(fieldname(y),1,1)+lower(substr(fieldname(y),2,12))
*
*               if valtype(fieldget(y)) # 'M'
*                  col:block  := fieldblock(field(y))
*                       col:width   := if( bstru_[fieldpos( field(y) )][DBS_LEN] > 25, 25,;
*                                      if( valtype(fieldget(y)) == 'D', 10, ;
*                                      IF( bstru_[fieldpos( field( y ) )][DBS_LEN] < len(field(y)),;
*                                      len( field(y) ),bstru_[ fieldpos( field( y ) ) ][ DBS_LEN ] ) ) )
*
*               else
*                  col:block  := {|| '<MEMO>' }
*                  col:width  := 6
*               endif
*
*               b:addcolumn(col)
*            next
*         endif
*      ELSE
*         FOR y:=1 to len(ltbclmn)
*             b:addcolumn(lTbclmn[y])
*         next
*      endif
*
*      DO WHILE .t.
*         DO WHILE .not. b:stabilize()
*            ch := Inkey()
*
*            IF ch <> 0
*               exit
*            ENDIF
*         ENDDO
*
*         b:colorRect({b:rowpos,1,b:rowpos,b:colcount},{3,4})
*
*         IF b:stable
*            IF b:hittop .OR. b:hitbottom
*               TONE(1000,5)
*            endif
*
*            ch := Inkey(0)
*         endif
*
*         setcursor(0)
*
*         IF ch == K_UP
*            chrsk:= ''
*            _crpos:=0
*            b:up()
*            b:refreshall()
*         ELSEIF ch == K_DOWN
*               chrsk:= ''
*               _crpos:=0
*               b:down()
*               b:refreshall()
*         ELSEIF ch == K_LEFT
*                if b:colpos = 1
*                   TONE(1000,5)
*                endif
*                b:colpos := 2
*                b:left()
*         ELSEIF ch == K_RIGHT
*                if b:colpos == b:colcount
*                   TONE(1000,5)
*                endif
*                b:colpos := 4 && 2
*                b:right()
*         ELSEIF ch == K_PGUP
*                chrsk:= ''
*                _crpos:=0
*                b:pageUp()
*                b:refreshall()
*         ELSEIF ch == K_PGDN
*                chrsk:= ''
*                _crpos:=0
*                b:pageDown()
*                b:refreshall()
*         ELSEIF ch == K_HOME
*                b:home()
*         ELSEIF ch == K_END
*                b:End()
*         ELSEIF ch == K_CTRL_HOME
*                b:panHome()
*         ELSEIF ch == K_CTRL_END
*                b:panend()
*         ELSEIF ch == K_TAB
*                b:panRight()
*         ELSEIF ch == K_SH_TAB
*                b:panLeft()
*         ELSEIF ch == K_CTRL_PGUP
*                chrsk:= ''
*                _crpos:=0
*                b:GOTOP()
*         ELSEIF ch == K_CTRL_PGDN
*                chrsk:= ''
*                _crpos:=0
*                b:gobottom()
*         ELSEIF ch == K_F1
*         ELSEIF ch == K_F3
*                curcolo :=!curcolo
*                b:colorspec := if(curcolo,"w/bg+,w/n,w/n,w/n,w/n,w/n,w/n,w/n,w/n,w/n,w/bg+" , ;  //"n/w,w/n,w/n,w/n,w/n,w/n,w/n,w/n,w/n,w/n,n/w"
*                                     "w/n,n/w,n/w,n/w,n/w,n/w,n/w,n/w,n/w,n/w,w/n")
*                b:configure()
*         ELSEIF ch == K_ESC
*                exit
*         ELSEIF ch == K_ENTER
*                if deleted()
*                   boxshad(10,10,14,60,'On')
*                   @12,25 say 'Deleted Records..!!!!'
*                   Tone(1000,5)
*                   INKEY(.5)
*                   boxshad(10,10,14,60,'OFF')
*                Else
*                   exit
*                eNDIF
*         ELSEIF ( ch > 31 .AND. ch < 127 ) .OR. CH == K_BS
*                DO WHILE .T.
*                   if _crpos <= ncount
*                      IF CH == K_BS
*                         _crpos--
*                         CHRSK := LEFT(CHRSK,LEN(CHRSK)-1)
*                      ELSEIF CH <> K_ENTER .AND. CH <> K_ESC
*                         _crpos++
*                         chrsk:=chrsk+upper(if(chr(ch) $ '0123456789',alltrim(str(val(chr(ch)))),chr(ch)))
*                      ENDIF
*
*                      cd:=setcolor()
*                      setcolor('w+/n')
*                      @nbot,nleft+5 say replicate(chr(176),(nright-6)-(nleft+3)) color 'w+/n'
*                      setcolor(cd)
*                      @nbot,nleft+5+( (int(((nright-6)-(nleft+3))/2))-(int(len(chrsk)/2)) ) say chrsk+'_'  color 'w+/n'
*                      b:gotop()
*
*                      IF lFLTER1 == NIL
*                         lFND:= dbseek(chrsk,.F.)
*                      ELSE
*                         lFND:= dbseek(chrsk,.F.)
*                      ENDIF
*
*                      IF !lFND
*                         CHRSK := LEFT(CHRSK,LEN(CHRSK)-1)
*                         DBSEEK(CHRSK,.F.)
*                         EXIT
*                      ELSEIF LASTKEY() == K_ENTER .OR. ;
*                             LASTKEY() == K_ESC
*                         EXIT
*                      ENDIF
*
*                   ELSE
*                      EXIT
*                   endif
*
*                   CH := INKEY(0)
*                ENDDO
*                b:refreshall()
*         ELSE
*            Tone(800,5)
*         ENDIF
*
*         @nbot,nleft+5 say replicate(chr(176),(nright-6)-(nleft+3)) color 'w+/n'
*         @nbot,nleft+5+( (int(((nright-6)-(nleft+3))/2))-(int(len(chrsk)/2)) ) say chrsk+'_'  color 'w+/n'
*      ENDDO
*
*      if ch == 13
*         IF lBR == NIL .OR. !lBR      && RETURN VALUE IS CLIENT CODE ONLY
*            RET_VALUE := IF(GETFLD # NIL,FIELDGET(GETFLD),IF(EMPTY(NFLD1),LSEEKFLD(LSEEK),FIELDGET(NFLD1)))
*         ELSEIF lBR        && RETURN VALUE IS BRANCH CODE + CLIENT CODE
*            RET_VALUE := IF(GETFLD # NIL,BRCODE+FIELDGET(GETFLD),IF(EMPTY(nFLD1),LSEEKFLD(LSEEK),BRCODE+FIELDGET(nFLD1)))
*         ENDIF
*      elseif ch == 27
*         ret_value := lSeek
*      endif
*
*      reindex->(dbclosearea())
*      if !sw
*         curdbf->(dbclosearea())
*      endif
*endif  //!file('Reindex.dbf')
*
*if dbfaray[ 1,1 ] <> select(nDbf)
*   dbselectarea( ( dbfaray[ 1, 1 ] ) )
*   dbsetorder  ( ( dbfaray[ 1, 2 ] ) )
*   dbgoto      ( ( dbfaray[ 1, 3 ] ) )
*endif
*setcolor    (   dbfaray[ 1, 4 ] )
*setcursor   (   dbfaray[ 1, 5 ] )
*restscreen( , , , , zz)
*rt_value:=ret_value
*RETURN (getactive():varput(mval:=eval({ || if(ch<> 27,rt_value,getactive():varget()) } ) ) )
*
*static Function lseekfld(lseek)
*local loc_fld
*if !empty(lseek) .or. empty(lseek)
*   loc_fld:=indexkey()
*   if '+' $ loc_fld
*      loc_fld:=substr(loc_fld,1,at('+',loc_fld))
*      if '(' $ loc_fld .and. ')' $ loc_fld
*    loc_fld:=substr(loc_fld,at('(',loc_fld),at(')',loc_fld))
*      endif
*   endif
*   if '(' $ loc_fld .and. ')' $ loc_fld
*      loc_fld:=substr(loc_fld,at('(',loc_fld),at(')',loc_fld))
*   endif
*else
*    return nil
*endif
*return (loc_fld:=fieldget(fieldpos(upper(alltrim(loc_fld)))))
*
*/*----------------------------*/
*FUNCTION boxshad(nT,nL,nB,nR,cSet,cColor)
*/*----------------------------*/
*
*STATIC cWinscr := {}
*STATIC nEl := 0
*if !empty(cColor)
*   setcolor(cColor)
*endif
*IF upper(cSet) = 'ON'
*   Aadd(cWinscr, Savescreen(nT,nL,nB+1,nR+2))
*   nEl++
*   Restscreen(nT+1,nL+1,nB+1,nR+2,;
*   Transform(Savescreen(nT+1,nL+1,nB+1,nR+2),;
*   Replicate('X' + chr(8), Len(Savescreen(nT+1,nl+1,nB+1,nR+2)))))
*   @nT,nl clear TO nB,nR
*   @nT,nL TO nB,nR double
*ELSE
*   Restscreen(nT,nl,nB+1,nR+2,cWinscr[nEl])
*   Adel(cWinscr,nEl)
*   Asize(cWinscr,nEl)
*ENDIF
*RETURN nil
*/*--------------*/
*Function baks(ntop,nleft,nbot,nrght,ntitle,color)
*local x:=1,mu:=setcolor(),gf
*if empty(color)
*    color:='w'
*endif
*
*setcolor(color)
*@ntop,nleft say chr(218)
*@ntop,nleft+1 say replicate(chr(196),(nrght)-(nleft+1))
*
*@ntop+1,nleft to nbot-1,nleft
*@nbot,nleft+5 say replicate(chr(176),(nrght-2)-(nleft+3)) color 'w+/n'
*x:=2
*for x:= 1 to (nbot-ntop)-2
*   @ntop+x,nrght say chr(176)  color 'w+/n'
*next
*@ ntop,nrght say chr(191)
*@ nbot,nleft say chr(192)
*@ nbot,nleft+1 say chr(196)
*@ nbot,nleft+2 say chr(196)
*@ nbot,nrght-2 say chr(196)
*@ nbot,nrght-1 say chr(196)
*@ nbot,nrght say chr(217)
*
*if nTitle <> nil
*  @ ntop,nrght-(len(ntitle)+2) say ntitle color 'w/gr'
*endif
*if iscolor()
*   set colo to n/w+
*endif
*@ nbot,nleft+3 say chr(17)+chr(254)  color 'n/w+'
*@ nbot,nrght-4 say chr(254)          color 'n/w+'
*@ nbot,nrght-3 say chr(16)           color 'n/w+'
*@ nbot-1,nrght say chr(31)           color 'n/w+'
*@ ntop+1,nrght say chr(30)           color 'n/w+'
*setcolor( mu )
*return nil
*
*stat func fEval( f8 )
*loca rec
*memv gigi
*
*rec  := eval( { | x | x := recno(), dbseek( f8 ), x } )
*gigi := 0
*dbeval( { || gigi++ },, { | x | x == f8 } )
*dbgoto( rec )
*gigi := max( gigi, 1 )
*return( nil )
*
*static func fRec1Pos( how, howMany )
*loca actual := 0, i
*stat where := 1
*
*do case
*   case how = 'top'
*        where := 1
*        dbgotop()
*   case how = 'bottom'
*        where := lastrec()
*        dbgobottom()
*   case how = 'skip'
*        do case
*           case howMany < 0
*                whil ( actual > howMany ) .and. ( !bof() )
*                     dbskip( -1 )
*                     if !bof()
*                    actual--
*                     endi : !bof()
*                endd : ( actual > howMany ) .and. ( !bof() )
*           case howMany > 0
*                whil ( actual < howMany ) .and. ( !eof() )
*                     dbskip( +1 )
*                     if !eof()
*                   actual++
*                     endi : !eof()
*                endd : ( actual < howMany ) .and. ( !eof() )
*                if eof()
*                   dbskip( -1 )
*                endi : eof()
*           othe
*                dbskip( 0 )
*        endc
*   othe
*        retu( where )
*endc
*
*where += actual
*where := min( max( where, 1 ), lastrec() )
*retu( actual )
*
*////
*static func fRec2Pos( how, what, which, howmany )
*loca actual := 0, soft
*memv gigi, when
*
*do case
*   case how = 'top'
*        when := 1
*        DBGOTOP()
*        DO WHILE !EOF() .AND. !EVAL(WHICH,WHAT)
*           DBSKIP(+1)
*        ENDDO
*   case how = 'bottom'
*        when := gigi
*        DBGOBOTTOM()
*        DO WHILE !BOF() .AND. !EVAL(WHICH,WHAT)
*           DBSKIP(-1)
*        ENDDO
*   case how = 'skip'
*        do case
*           case howmany < 0
*                while ( actual > howmany ) .and. ( !bof() ) .and. eval( which, what )
*                   dbskip( -1 )
*                   if !bof() .and. eval( which, what )
*                      actual--
*                   endif
*                enddo
*                if bof() .or. !eval( which, what ) .and. !empty(what)
*                   dbskip( +1 )
*                endif
*           case howmany > 0
*                while ( actual < howmany ) .and. ( !eof() ) .and. eval( which, what )
*                    dbskip( +1 )
*                    if !eof() .and. eval( which, what )
*                       actual++
*                    endif
*                enddo
*                if eof() .or. !eval( which, what ) .AND. !EMPTY(WHAT)
*                   dbskip( -1 )
*                endif
*           otherwise
*                dbskip( 0 )
*        endcase
*   otherwise
*        return( when )
*endcase
*
*when += actual
*when := min( max( when, 1 ), gigi )
*
*return( actual )
*--------------------------------------------
*FUNCTION FBRCH( cBRCOD, nLEN )
*LOCAL DBFARAY := {}
*LOCAL cRETVAL := ''
*LOCAL nROW    := ROW()
*LOCAL nCOL    := COL()
*LOCAL lOPEN   := IF(SELECT("BRANCHES") > 0,.T.,.F.)
*
*IF EMPTY(nLEN) .OR. nLEN = NIL
*   nLEN := 30
*ENDIF
*
*IF !lOPEN
*   AADD(DBFARAY,{SELECT(),INDEXORD(),RECNO(),SETCOLOR(),SETCURSOR(),SAVESCREEN()})
*
*   IF NETUSE('&g_GRF_PATH\BRANCHES',.F.,10)
*      DBSETINDEX('&g_GRF_PATH\BRANCHES')
*   ELSE
*      RETURN NIL
*   ENDIF
*ENDIF
*
*IF BRANCHES->(DBSEEK(ALLTRIM(cBRCOD),.F.))
*   cRETVAL := LEFT(BRANCHES->BRNAME,nLEN)
*ELSE
*   cRETVAL := NIL
*ENDIF
*
*IF !lOPEN
*   BRANCHES->(DBCLOSEAREA())
*
*   IF( EMPTY( DBFARAY[1,1] ), NIL, DBSELECTAREA( (DBFARAY[1,1]) ) )
*   IF( EMPTY( DBFARAY[1,2] ), NIL, DBSETORDER( (DBFARAY[1,2]) ) )
*   IF( EMPTY( DBFARAY[1,3] ), NIL, DBGOTO( (DBFARAY[1,3]) ) )
*   IF( EMPTY( DBFARAY[1,4] ), NIL, SETCOLOR(DBFARAY[1,4]) )
*   IF( EMPTY( DBFARAY[1,5] ), NIL, SETCURSOR(DBFARAY[1,5]) )
*ENDIF
*
*SETPOS(nROW,nCOL)
*
*RETURN cRETVAL
*--------------------------------------------
/***
FUNCTION ACC_BRCH(cUSER)
LOCAL DBFARAY := {}
LOCAL cRETVAL := ""
LOCAL lSW     := .F.
LOCAL lOPEN   := IF(SELECT("AXBRANCH") > 0,.T.,.F.)

IF !lOPEN
   AADD(DBFARAY,{SELECT(),INDEXORD(),RECNO(),SETCOLOR(),SETCURSOR(),SAVESCREEN()})

   IF NETUSE('&g_GRF_PATH\AXBRANCH',.F.,10)
      DBSETINDEX('&g_GRF_PATH\AXBRANCH')
   ELSE
      RETURN
   ENDIF
ENDIF

IF AXBRANCH->( DBSEEK( ALLTRIM(cUSER) ) )
   cRETVAL := '"'+g_PAR_BRCH

   DO WHILE ALLTRIM(AXBRANCH->USER_ID) == ALLTRIM(cUSER) .AND. ! AXBRANCH->( EOF() )
      IF lSW
         cRETVAL := cRETVAL + '^'
      ENDIF

      lSW := .T.

      cRETVAL := cRETVAL + AXBRANCH->BRCODE

      AXBRANCH->( DBSKIP() )
   ENDDO

   cRETVAL := cRETVAL + '"'
ELSE
   cRETVAL := '"'+g_PAR_BRCH+'"'
ENDIF

IF !lOPEN
   AXBRANCH->(DBCLOSEAREA())

   IF( EMPTY( DBFARAY[1,1] ), NIL, DBSELECTAREA( (DBFARAY[1,1]) ) )
   IF( EMPTY( DBFARAY[1,2] ), NIL, DBSETORDER( (DBFARAY[1,2]) ) )
   IF( EMPTY( DBFARAY[1,3] ), NIL, DBGOTO( (DBFARAY[1,3]) ) )
   IF( EMPTY( DBFARAY[1,4] ), NIL, SETCOLOR(DBFARAY[1,4]) )
   IF( EMPTY( DBFARAY[1,5] ), NIL, SETCURSOR(DBFARAY[1,5]) )
ENDIF

RETURN cRETVAL

***/
/***
FUNCTION ACC_BRCH(cUSER)
LOCAL DBFARAY := {}
LOCAL cRETVAL := ""
LOCAL lSW     := .F.
LOCAL lOPEN   := IF(SELECT("AXBRANCH") > 0,.T.,.F.)

IF !lOPEN
   AADD(DBFARAY,{SELECT(),INDEXORD(),RECNO(),SETCOLOR(),SETCURSOR(),SAVESCREEN()})

   IF NETUSE('&g_GRF_PATH\AXBRANCH',.F.,10)
      DBSETINDEX('&g_GRF_PATH\AXBRANCH')
   ELSE
      RETURN
   ENDIF
ENDIF

IF AXBRANCH->( DBSEEK( ALLTRIM(cUSER) ) )
   cRETVAL := '"'+g_PAR_BRCH


   DO WHILE ALLTRIM(AXBRANCH->USER_ID) == ALLTRIM(cUSER) .AND. ! AXBRANCH->( EOF() )
   
      IF lSW
         cRETVAL := cRETVAL + '^'
      ENDIF

      lSW := .T.

      cRETVAL := cRETVAL + AXBRANCH->BRCODE

   AXBRANCH->( DBSKIP() )
   ENDDO

   cRETVAL := cRETVAL+ '"'
   
   
ELSE
   cRETVAL := '"'+g_PAR_BRCH+'"'
ENDIF

IF !lOPEN
   AXBRANCH->(DBCLOSEAREA())

   IF( EMPTY( DBFARAY[1,1] ), NIL, DBSELECTAREA( (DBFARAY[1,1]) ) )
   IF( EMPTY( DBFARAY[1,2] ), NIL, DBSETORDER( (DBFARAY[1,2]) ) )
   IF( EMPTY( DBFARAY[1,3] ), NIL, DBGOTO( (DBFARAY[1,3]) ) )
   IF( EMPTY( DBFARAY[1,4] ), NIL, SETCOLOR(DBFARAY[1,4]) )
   IF( EMPTY( DBFARAY[1,5] ), NIL, SETCURSOR(DBFARAY[1,5]) )
ENDIF

RETURN cRETVAL
***/

*-----------------------------------------
*FUNCTION MKE_TMPPRO(cBRCODES)
*LOCAL lRETVAL := .F.
*LOCAL DBFARAY := {}
*LOCAL bFLTER  := &('{ || '+'PROSPEX->BRCODE $ '+ cBRCODES +' }')
*LOCAL aSTRUC
*LOCAL lOPEN   := IF(SELECT("PROSPEX") > 0,.T.,.F.)
*
*IF !lOPEN
*   AADD(DBFARAY,{SELECT(),INDEXORD(),RECNO(),SETCOLOR(),SETCURSOR(),SAVESCREEN()})
*
*   IF NETUSE('&g_CIS_PATH\PROSPEX',.F.,5)
*      aSTRUC := DBSTRUCT()
*   ELSE
*      RETURN .F.
*   ENDIF
*ENDIF
*
*   IF FILE('C:\TMPPROS.DBF')
*      FERASE('C:\TMPPROS.DBF')
*
*      IF FILE('C:\TMPPROS.NTX')
*         FERASE('C:\TMPPROS.NTX')
*      ENDIF
*   ENDIF
*
*   DBCREATE('C:\TMPPROS',aSTRUC)
*
*IF NETUSE('C:\TMPPROS',.F.,5)
*   @ 13,10 SAY 'Creating search file..'
*   @ 14,10 SAY REPL('±',60)
*
*   DO WHILE !PROSPEX->(EOF())
*      IF PROSPEX->BRCODE $ &cBRCODES
*         COPREC()
*      ENDIF
*
*      PROSPEX->(DBSKIP())
*      @ 14,10 SAY REPL('²',(PROSPEX->(RECNO())/PROSPEX->(RECCOUNT()))*60)
*      @ 15,10 SAY TRANS((PROSPEX->(RECNO())/PROSPEX->(RECCOUNT()))*100,'999')+' %'
*   ENDDO
*   @ 13,10 CLEAR TO 15,70
*
*   DBCREATEINDEX('C:\TMPPROS','FULLNAME+BRCODE+PRPXCODE',{|| FULLNAME+BRCODE+PRPXCODE })
*
*   TMPPROS->(DBCLOSEAREA())
*
*   lRETVAL := .T.
*ENDIF
*
*IF !lOPEN
*   PROSPEX->(DBCLOSEAREA())
*
*   IF( EMPTY( DBFARAY[1,1] ), NIL, DBSELECTAREA( ( DBFARAY[1,1] ) ) )
*   IF( EMPTY( DBFARAY[1,2] ), NIL, DBSETORDER( ( DBFARAY[1,2] ) ) )
*   IF( EMPTY( DBFARAY[1,3] ), NIL, DBGOTO( ( DBFARAY[1,3] ) ) )
*   IF( EMPTY( DBFARAY[1,4] ), NIL, SETCOLOR( DBFARAY[1,4] ) )
*   IF( EMPTY( DBFARAY[1,5] ), NIL, SETCURSOR( DBFARAY[1,5] ) )
*ENDIF
*
*RETURN lRETVAL
*----------------------------------------*
*FUNCTION COPREC()
*
*TMPPROS->(DBAPPEND())
*
*REPLACE TMPPROS->FULLNAME WITH PROSPEX->FULLNAME
*REPLACE TMPPROS->BRCODE   WITH PROSPEX->BRCODE
*REPLACE TMPPROS->PRPXCODE WITH PROSPEX->PRPXCODE
*REPLACE TMPPROS->SHRTNAME WITH PROSPEX->SHRTNAME
*
*TMPPROS->(DBCOMMIT())
*
*RETURN NIL
*-------------------------------------------------------------------------------*

/*****
FUNCTION VALBRCODE(cBRCODE,cUSER)
LOCAL lRETVAL := .F.
LOCAL cVALCODE := ACC_BRCH(cUSER)

IF cBRCODE $ &cVALCODE
   lRETVAL := .T.
ELSE
   ERROR('You have no rights for this branch.')
ENDIF

RETURN lRETVAL

***/

FUNCTION VALBRCODE(cBRCODE,cUSER)
LOCAL lRETVAL := .F.
//LOCAL cVALCODE := ACC_BRCH(cUSER)
LOCAL lOPEN   := IF(SELECT("AXBRANCH") > 0,.T.,.F.)

activeDBF:= alias()

IF !lOPEN
   IF NETUSE('&G_GRF_PATH\AXBRANCH',.F.,10)
      DBSETINDEX('&G_GRF_PATH\AXBRANCH')
   ELSE
      RETURN lRETVAL
   ENDIF
ENDIF

//IF cBRCODE $ &cVALCODE

IF AXBRANCH->(dbseek(cUSER+cBRCODE))
   lRETVAL := .T.
ELSE
   ERROR('You have no rights for this branch.')
ENDIF

IF !lOPEN
   AXBRANCH->(DBCLOSEAREA())
ENDIF

dbselectarea(activeDBF)

*ALERT('VALBRCODE-'+cBRCODE+'-'+cUSER+'-'+IF(lRETVAL,'TRUE','FALSE')+'-'+cVALCODE)
RETURN lRETVAL

*-------------------------------------------------------------------------------
FUNCTION CURRBRCH(cBRCODE)
LOCAL lRETVAL := .F.
//alert(cbrcode+' '+g_par_brch)
IF ALLTRIM(cBRCODE) == g_PAR_BRCH
   lRETVAL := .T.
ELSE
   IF LASTKEY() == K_F2
      ERROR('You are not allowed to edit data from this branch.')
   ELSEIF LASTKEY() == K_DEL
      ERROR('You are not allowed to delete data from this branch.')
   ELSE
      ERROR('You are not allowed to transact with this branch code.')
   ENDIF
ENDIF

RETURN lRETVAL
*-----------------------------------------
FUNCTION CPS_REQST(cKEY,cFUNCNM)
LOCAL cRETVAL
LOCAL nREQNO
LOCAL cMESS
LOCAL cSCR
LOCAL DBFARAY := {}
LOCAL lPAUSE  := .F.
LOCAL nX      := 0

IF !EMPTY(cKEY) //PEPE
   IF LEN(cKEY) > 1000
      ALERT('cKEY LENGTH EXCEEDS CPSQ->PARAMS LIMIT! ;; PLEASE CONTACT ICT DEPARTMENT.')
      RETURN
   ENDIF
ENDIF

cFUNCNM := IF(LEN(cFUNCNM) > 15, LEFT(cFUNCNM,15), cFUNCNM)

IF !FILE('&g_CPS_PATH\STARTUP.DBF')
   ERROR('Connection to Central Processing is missing.')
   RETURN NIL
ELSEIF NETUSE('&g_CPS_PATH\STARTUP',.F.,5)
       IF (EMPTY(STARTUP->DATE) .OR. EMPTY(STARTUP->TIME)) .AND. ;
          STARTUP->MULTIPLE = 0
          ERROR('Central Processing is offline. Call IT dept.')
          STARTUP->(DBCLOSEAREA())
          RETURN NIL
       ELSE
          STARTUP->(DBCLOSEAREA())
       ENDIF
ENDIF

AADD(DBFARAY,{SELECT(),INDEXORD(),RECNO(),SETCOLOR(),SETCURSOR(),SAVESCREEN()})

IF !NETUSE('&g_CPS_PATH\CPSQ',.F.,0)
   RETURN
ELSE
 
   CPSQ->(DBAPPEND())
   REPLACE CPSQ->USER      WITH g_USER_ID
   REPLACE CPSQ->BRCODE    WITH g_PAR_BRCH
   REPLACE CPSQ->REQ_TYPE  WITH UPPER(cFUNCNM)
   REPLACE CPSQ->PARAMS    WITH IIF( cKEY <> NIL, cKEY, ' ' )
   REPLACE CPSQ->STATUS    WITH 'W'
   REPLACE CPSQ->DATESTART WITH DATE()
   REPLACE CPSQ->TIMESTART WITH TIME()
   CPSQ->(DBRUNLOCK())
   nREQNO := CPSQ->(RECNO())

ENDIF

cSCR := SAVESCREEN(11,10,14,70)
SETCURSOR(0)

DO WHILE .T.

   CPSQ->(DBGOTO(nREQNO))

   DO CASE
      CASE CPSQ->STATUS == 'C'
           cMESS   := '  REQUEST COMPLETED  '
           cRETVAL := CPSQ->TEMPFILE
           EXIT
      CASE CPSQ->STATUS == 'P'
           cMESS := ' REQUEST IS PROCESSING '
      CASE CPSQ->STATUS == 'W'
           cMESS := ' REQUEST IS ON QUEUE '
      CASE CPSQ->STATUS == 'I'
           cMESS   := ' REQUEST IS INVALID. PRESS ANY KEY. '
           lPAUSE  := .T.
      CASE CPSQ->STATUS == 'H'
           cMESS   := ' REQUEST WAS HALTED. PRESS ANY KEY. '
           lPAUSE  := .T.
   ENDCASE

   nX := INT((80-LEN(cMESS))/2)
   FSHADOW(11,nX,13,nX+LEN(cMESS)+1 ,2,'N/BG')
   @ 12,nX+1 SAY cMESS      COLOR 'GR+*/BG'

   IF lPAUSE
      lPAUSE  := .F.
      cRETVAL := NIL
      INKEY(0)
      EXIT
   ELSE
      INKEY(2)
   ENDIF

ENDDO

CPSQ->(DBCLOSEAREA())

RESTSCREEN(11,10,14,70,cSCR)

IF( EMPTY( DBFARAY[1,1] ), NIL, DBSELECTAREA( (DBFARAY[1,1]) ) )
IF( EMPTY( DBFARAY[1,2] ), NIL, DBSETORDER( (DBFARAY[1,2]) ) )
IF( EMPTY( DBFARAY[1,3] ), NIL, DBGOTO( (DBFARAY[1,3]) ) )
IF( EMPTY( DBFARAY[1,4] ), NIL, SETCOLOR(DBFARAY[1,4]) )
IF( EMPTY( DBFARAY[1,5] ), NIL, SETCURSOR(DBFARAY[1,5]) )

RETURN cRETVAL
*-----------------------------------------
FUNCTION NXTVALBR( cBRCH, cBRCODES, cMOVE)
LOCAL nSTRT := AT(cBRCH,cBRCODES)
LOCAL cRETVAL

ALERT()

IF cBRCH == NIL .OR. cBRCODES == NIL .OR. cMOVE == NIL
   ALERT('One of the parameters passed to "NXTVALBR" is empty.')
   RETURN NIL
ENDIF

IF ALLTRIM(UPPER(cMOVE)) == 'FORWARD'
   IF LEN(cBRCODES) > nSTRT + 4
      nSTRT := nSTRT + 4
   ELSE
      RETURN NIL
   ENDIF
ELSEIF ALLTRIM(UPPER(cMOVE)) == 'BACKWARD'
       IF (nSTRT - 4) > 0
          nSTRT := nSTRT - 4
       ELSE
          RETURN NIL
       ENDIF
ELSE
   ALERT('You passed an invalid parameter value in "NXTVALBR" function.')
   RETURN NIL
ENDIF

cRETVAL := SUBSTR(cBRCODES,nSTRT,3)

RETURN cRETVAL
*--------------------------------------
FUNCTION MSGWIN(X,Y,cMSG,cCOL1,cCOL2,cACT)
LOCAL X2
LOCAL Y2
LOCAL SCRTMP
STATIC aSCR := {}

IF X == NIL .OR. Y == NIL .OR. cACT == NIL
   ALERT('INVALID PARAMETER')
   RETURN
ELSEIF cMSG == NIL
    ALERT('3RD PARAMETER IS NIL')
    RETURN
ELSEIF ALLTRIM(UPPER(cACT)) == 'ON'
    IF cCOL1 == NIL
       cCOL1 := 'W+/N'
    ELSEIF cCOL2 == NIL
       cCOL2 := 'R*/N'
    ENDIF
ELSEIF !(ALLTRIM(UPPER(cACT)) $ 'ON^OFF')
    ALERT('INVALID 6TH PARAMETER VALUE')
    RETURN
ENDIF

X2 := X+2
Y2 := Y+2+LEN(RTRIM(cMSG))+1

IF ALLTRIM(UPPER(cACT)) == 'ON'
   AADD( aSCR, SAVESCREEN( X, Y, X2+1, Y2+1) )

   BOXSHADOW( X, Y, X2, Y2 )
   @ X,Y TO X2,Y2                              COLOR cCOL1
   @ X+1,Y+1 SAY SPACE(1)+RTRIM(cMSG)+SPACE(1) COLOR cCOL2
   *INKEY(0)    && for testing only
ELSEIF ALLTRIM(UPPER(cACT)) == 'OFF'
   RESTSCREEN( X, Y, X2+1, Y2+1, aSCR[LEN(aSCR)] )

   aDEL(aSCR,LEN(aSCR)-1)
   aSIZE(aSCR,LEN(aSCR)-1)
ENDIF

RETURN
/*-----------------------------------
* NOTE: This function is for converting arrays to string so that it can be saved
*       in a database field. As you know arrays in its natural state cannot be
*       saved in a dbf field. WARNING: This function works only for single
*       dimension arrays.... Anyway thats only what we need. - RED

FUNCTION ARR2STR(aARRAY)
LOCAL sSTRING := '{'
LOCAL cSEP    := ',', cVAR

FOR I := 1 TO LEN(aARRAY)
    DO CASE
       CASE VALTYPE(aARRAY[I]) == 'C'
            sSTRING := sSTRING+'"'
*            sSTRING := sSTRING+'C'+CHR(26)+aARRAY[I]+'"'
            sSTRING := sSTRING+aARRAY[I]+'"'
       CASE VALTYPE(aARRAY[I]) == 'N'
            IF aARRAY[I] = 0
               cVAR := '0'
            ELSE
               cVAR := ALLTRIM(STR( aARRAY[I] ))
            ENDIF

*            sSTRING := sSTRING+'N'+CHR(26)+cVAR+'"'
            sSTRING := sSTRING+cVAR
       CASE VALTYPE(aARRAY[I]) == 'D'
            sSTRING := sSTRING+'"'
            sSTRING := sSTRING+'D'+CHR(26)+DTOC(aARRAY[I])+'"'
    ENDCASE

    IF I < LEN(aARRAY)
       sSTRING := sSTRING+','
    ENDIF
NEXT

sSTRING := sSTRING+'}'

ALERT('ARR2STR-'+sSTRING)

RETURN sSTRING
*----------------------------------*/
FUNCTION CHK_PAR(VAR)
LOCAL RETVAL

IF VAR == NIL
   RETVAL := ' '+'~'
ELSE
   DO CASE
      CASE VALTYPE(VAR) == 'N'
           IF VAR = 0
              VAR := '0'
           ELSE
              VAR := ALLTRIM(STR(VAR))
           ENDIF

           RETVAL := VAR+'~'
      CASE VALTYPE(VAR) == 'D'
           RETVAL := DTOC(VAR)+'~'
      CASE VALTYPE(VAR) == 'C'
           RETVAL := VAR+'~'
      CASE VALTYPE(VAR) == 'L'
           IF VAR
              RETVAL := 'T~'
           ELSE
              RETVAL := 'F~'
           ENDIF
      *CASE VALTYPE(VAR) == 'A'
      *     RETVAL := ARR2STR(VAR)+'~'
      OTHERWISE
           RETVAL := '~'
   ENDCASE
ENDIF

RETURN RETVAL
*-------------------------------------------------------------------------------
FUNCTION SYSINFO
LOCAL nUX   := 9
LOCAL nUY   := 23
LOCAL nLX   := 15
LOCAL nLY   := nUY+11+18
LOCAL cSRCH := IF(TRUE_BRCH == '001','AMS.EXE','BRAMS.EXE')
LOCAL aINFO := DIRECTORY((cSRCH))

@ nUX,nUY CLEAR TO nLX,nLY
@ nUX,nUY TO nLX,nLY
FSHADOW(nUX,nUY,nLX,nLY,2)

@ nUX,nUY+1  SAY '[System Info]'                             COLOR 'W+/BG'
@ nLX,nLY-15 SAY '[Press any key]'                           COLOR 'W+/BG'
@ nUX,nUY+2  SAY 'System Info'                               COLOR 'GR+/BG'
@ nLX,nLY-14 SAY 'Press any key'                             COLOR 'GR+/BG'

@ nUX+1,nUY+1 SAY '    System'
@ nUX+2,nUY+1 SAY '      Size'
@ nUX+3,nUY+1 SAY '      Date'
@ nUX+4,nUY+1 SAY '      Time'
@ nUX+5,nUY+1 SAY ' Attribute'

@ nUX+1,nUY+12 SAY ''                                       COLOR 'GR+/BG'
@ nUX+2,nUY+12 SAY ''                                       COLOR 'GR+/BG'
@ nUX+3,nUY+12 SAY ''                                       COLOR 'GR+/BG'
@ nUX+4,nUY+12 SAY ''                                       COLOR 'GR+/BG'
@ nUX+5,nUY+12 SAY ''                                       COLOR 'GR+/BG'

*IF !EMPTY(aINFO)
   @ nUX+1,nUY+14 SAY aINFO[1,1]                             COLOR 'W+/BG'
   @ nUX+2,nUY+14 SAY TRAN(aINFO[1,2],'@R 999,999,999')+' B' COLOR 'W+/BG'
   @ nUX+3,nUY+14 SAY DTOC(aINFO[1,3])                       COLOR 'W+/BG'
   @ nUX+4,nUY+14 SAY aINFO[1,4]                             COLOR 'W+/BG'
   @ nUX+5,nUY+14 SAY aINFO[1,5]                             COLOR 'W+/BG'
*ENDIF

INKEY(0)

RETURN
*-------------------------------------------------------------------------------*
FUNCTION _BR_RIGHTS ( cUSERCODE, mWRKAREA )
LOCAL LRETVAL := .F., nREC := AXBRANCH->(RECNO())

IF AXBRANCH->(DBSEEK(ALLTRIM(cUSERCODE)))

   DO WHILE !AXBRANCH->(EOF()) .AND. ;
            ALLTRIM(AXBRANCH->USER_ID) == ALLTRIM(cUSERCODE)

      IF ALLTRIM(AXBRANCH->BRCODE) == ALLTRIM((mWRKAREA)->BRCODE)
         lRETVAL := .T.
      ENDIF

      AXBRANCH->(DBSKIP())
   ENDDO

ENDIF

AXBRANCH->(DBGOTO(nREC))

RETURN lRETVAL
*-------------------------------------------------------------------------------*


