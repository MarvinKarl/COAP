/*----------------------------------------------------------------
Syntax := flook( <lExist>,<cDbf>,<cSeek>,<cTitle>,<nFldn1>,<nFldn>,;
          <nFldn>,<nFld>,<lWindow>,<aTbcolumn>,<fFilter1>,;
          <fFilter2>,<>)
Definition :=  <lExist>    := <.t.> declared dbf else <.f.>
               <cDbf>      := optional dbf name to use
               <cSeek>     := optional key to seek
               <cTitle>    := optional title to display
               <nFld1..n>  := optional field to display
               <nFldn>     := optional field to get
               <lWindow>   := optional window size
               <aTbcolumn> := optional tbcolumnnew for browse
               <fFilter1>  := optional field for dbseek (fFilter1)
               <fFilter2)  := optional field for expression such as;
                              while fFilter1 == fFilter2
                           :=
               <cBRANCH>   := OPTIONAL FIELD FOR FILTERING BRANCH RECORDS
 e.g.     := @ <r>, <c> say 'Search Client : ' get <cVAr>
			<[when]> <[!empty(cVar := flook(.t.,'Client',;
			'00009','Client',1,2,3,2 ) ) ]>
 e. g.    := <cVar> := flook(.t.)
	     @ <r>, <c> say 'Search Client : ' get <cVar>
----------------------------------------------------------------*/

*                     1  2    3     4      5     6     7     8     9      10    11      12      13      14       15
FUNCTION flook_online(SW,nDBF,lSEEK,lTITLE,nFLD1,nFLD2,nFLD3,nFLD4,gETFLD,lWIND,lTBCLMN,lFLTER1,lFLTER2,reinpath,lBR)
/*----------------------------------------------------------------*/

//
//    x := fLOOK_ONLINE( .t., 'Prospex',nil, 'Prospect',2,20,1,3,1,,,,,,.T.),;
//                            Prospex->( ordsetfocus( 1 ) ), ;
//


#include "inkey.ch"
#include "setcurs.ch"
#include "memoedit.ch"
#include "dbstruct.ch"
#include "colf.ch"

local dbfaray:={},newcolor,oldcolor,rt_value,b,oldscr:=savescreen(),_crpos:=0,chrsk:=''
local curcolo:=iscolor(),col,ret_value,curdbf,curntx,r1,r2,c1,c2,nbot,ntop,nleft,nright
local pArray:={},ch,tPara:=0,ncount:=0,zz,y,x,cd,mval,local_str,bstru_,norder
LOCAL lFND  := .F.

priv gigi := 1, when := 1
//local st_,old_row,tot_count,lLength,nstart,xamp,xamp2,recnum
aadd(dbfaray, { select(), indexord(), recno(), setcolor(), setcursor(),;
	      savescreen()} )

if !empty(nDbf)
    Dbselectarea(nDBF)
    norder:= ( nDBF )->(indexord())
endif
SetCursor(0)

*** if !file(reinpath+'\Reindex.dbf')   // abb 08.13.04
if !file('&G_CIS_PATH\Reindex.dbf')   // abb 08.13.04
   rt_value := lSeek
else
   if netuse('&G_CIS_PATH\reindex',.f.,10)
****     dbsetindex(reinpath+'\reindex')
     dbsetindex('&G_CIS_PATH\reindex')
     //open the file and its index
   endif

   if(!empty(nDbf),eval({|| dbseek(alltrim(upper(nDbf))) } ),.t.)
    // check if the file exist
      if sw
         if nDbf == nil
            dbselectarea(dbfaray[1,1])
            dbsetorder(dbfaray[1,2])
         else
            dbselectarea(nDbf)
            dbsetorder( norder )
         endif //
	//if dbfaray[1,2] # nil
        //
	//endif
         if !empty(lSeek)
            if !dbseek(lSeek)
               dbgotop()
               //dbskip()
            endif
         else
            dbgotop()
         endif
      else
         curdbf:=alltrim(reindex->filename)
         curntx:=alltrim(reindex->index_name)

         if netuse(curdbf,.f.,5)
            if !empty(curntx)
               dbsetindex(curntx)
            endif
         endif

         if !empty(lSeek)
            if !dbseek(lSeek)
               dbgotop()
               //dbskip()
            endif
         else
            dbgotop()
         endif
      endif

      //endif of !file(reindex.dbf) is not yet encoded(found at the end of this function)
      nfld1:=if(empty(nfld1),1,nFld1)
      nfld2:=if(empty(nfld2),2,nFld2)
      nfld3:=if(empty(nfld3),if(fcount() < 3,nil,3),nFld3)
      nfld4:=if(empty(nfld4),NIL,nFld4)

      bstru_:=dbstruct()
      lTitle := if( lTitle == nil, alias(), lTitle)
      lWind  := if( lWind == nil, .t., lWind)

      if !lWind
         r1 :=  5
         c1 :=  4
         r2 := 20
         c2 := 74
      else
         r1 := 5
         c1 := if( getactive():col < 40, 24, 2 )
         r2 := r1 + 15
         c2 := c1 + 53
      endif

      ntop   := r1
      nleft  := c1
      nBot   := r2
      nright := c2
      zz:=savescreen( , , , )
      cd:=setcolor()

      setcolor('w/gr')
      @ nTOp, nleft clear TO nbot, nright

      setcolor(cd)
      baks(nTOp, nleft ,nbot, nright,lTitle,'w+/gr')
      ncount:=IF(!empty( lSeek ),len(if(valtype(lSeek)=='N',alltrim(str(lseek)),alltrim(lseek)))+2,(c2-c1)-6)

      if ncount >=(nright-6)-(nleft+3)
         ncount:=(nright-9)-(nleft+3)
      endif

      cd:=setcolor()
      setcolor('w/n')
      @nbot,nleft+5 say replicate(chr(176),(nright-6)-(nleft+3)) colo 'w+/n'
      @nbot,nleft+4+int(((nright-6)-(nleft+3))/2) say '_'  color 'w+/n'

      setcolor(cd)
      b := TBrowsedb()
      b:ntop          := r1 + 1
      b:nleft         := c1 + 2
      b:nbottom       := r2 - 1
      b:nright        := c2 - 2

      if lflter1 == nil
         b:gotopblock    := { |   | fRec1Pos( 'top'     ) }
         b:gobottomblock := { |   | fRec1Pos( 'bottom'  ) }
         b:skipblock     := { | n | fRec1Pos( 'skip', n ) }
      else

         *fEval( lflter1 )
         b:gotopblock    := { |   | fRec2Pos( 'top'   , EVAL(lflter1) ) }
         b:gobottomblock := { |   | fRec2Pos( 'bottom', EVAL(lflter1) ) }
         b:skipblock     := { | n | fRec2Pos( 'skip'  , lflter1, { | x | EVAL(lflter2) == x }, n ) }
         /*
         b:gotopblock    := { |   | fRec2Pos( 'top'   , EVAL(lflter1) ) }
         b:gobottomblock := { |   | fRec2Pos( 'bottom', EVAL(lflter1) ) }
         b:skipblock     := { | n | fRec2Pos( 'skip'  , lflter1, lflter2, n ) }
         */
      endif

      b:colpos        := 1
      b:headSep       := "ÒÄ"
      b:colSep        := "º"
      b:colorspec     :=  "w/bg+,w/n,w/n,w/n,w/n,w/n,w/n,w/n,w/n,w/n,w/bg+"
                         //"n+/w,w/n,w+/n,w+/n,w+/n+,w+/n+,w+/n+,w+/n,w+/n+,w+/n,n+/w+"
                         //"w+/n,n/w,n/w,n/w,n/w+,n/w+,n/w+,n/w,n/w+,n/w,w+/n"
      if(!empty(nFld1),aadd(pArray,nFld1),.t.)
      if(!empty(nFld2),aadd(pArray,nFld2),.t.)
      if(!empty(nFld3),aadd(pArray,nFld3),.t.)
      IF(!EMPTY(nFLD4),AADD(pARRAY,nFLD4),.T.)

      if lTbclmn == nil  .or. len(lTbclmn) < 1
         if !empty(nFld1) .and. !empty(nFld2) .and. !empty(nFld3) &&.AND. !EMPTY(nFLD4)   RED 101404
            for y:=1 to len(pArray)  //tPara
                if pArray[y] <> nil
                   col := tbcolumnNew()
                   col:heading := substr(fieldname(pArray[y]),1,1)+lower(substr(fieldname(pArray[y]),2,12))

                   if valtype(fieldget(pArray[y])) # 'M'
                      col:block   := fieldblock(field(pArray[y]))
//                           col:width   := if( bstru_[fieldpos( field( pArray[y] ) )][DBS_LEN] > 25, 25,;
//                                          IF( bstru_[fieldpos( field( pArray[y] ) )][DBS_LEN] < len(field(pArray[y])),;
//                                          if( valtype(fieldget(pArray[y])) <> 'D', len( field( pArray[ y ] ) ), ;
//                                          len( field( pArray[ y ] ) ) + 2 ), ;
//                                          bstru_[ fieldpos( field( pArray[ y ] ) ) ][ DBS_LEN ] ) )
                      col:width   := if( bstru_[fieldpos( field(pArray[y]) )][DBS_LEN] > 25, 25,;
                                     if( valtype(fieldget(pArray[y])) == 'D', 10, ;
                                     IF( bstru_[fieldpos( field( pArray[y] ) )][DBS_LEN] < len(field(pArray[y])),;
                                        len( field(pArray[y]) ),bstru_[ fieldpos( field(pArray[y] ) ) ][ DBS_LEN ] ) ) )
                   else
                      col:block  := {|| '<MEMO>' }
                      col:WIDTH   := 6
                   endif

                   b:addcolumn(col)
                endif
            next
         else
            for y := 1 to fcount()
               col:= tbcolumnNew()
               col:heading:= substr(fieldname(y),1,1)+lower(substr(fieldname(y),2,12))

               if valtype(fieldget(y)) # 'M'
                  col:block  := fieldblock(field(y))
                    //col:width   := if(bstru_[fieldpos(field(y))][DBS_LEN] > 25, 25,IF( bstru_[fieldpos(field(y))][DBS_LEN] ;
                    //                 < len(field(y)), len(field(y)),bstru_[fieldpos(field(y))][DBS_LEN] ) )
                       col:width   := if( bstru_[fieldpos( field(y) )][DBS_LEN] > 25, 25,;
                                      if( valtype(fieldget(y)) == 'D', 10, ;
                                      IF( bstru_[fieldpos( field( y ) )][DBS_LEN] < len(field(y)),;
                                      len( field(y) ),bstru_[ fieldpos( field( y ) ) ][ DBS_LEN ] ) ) )

               else
                  col:block  := {|| '<MEMO>' }
                  col:width  := 6
               endif

               b:addcolumn(col)
            next
         endif
      ELSE //not empty(ltbclmn)
         FOR y:=1 to len(ltbclmn)
             b:addcolumn(lTbclmn[y])
         next
      endif

      DO WHILE .t.
         DO WHILE .not. b:stabilize()
            ch := Inkey()

            IF ch <> 0
               exit
            ENDIF
         ENDDO

         b:colorRect({b:rowpos,1,b:rowpos,b:colcount},{3,4})

         IF b:stable
            IF b:hittop .OR. b:hitbottom
               TONE(1000,5)
            endif

            ch := Inkey(0)
         endif

         setcursor(0)

         IF ch == K_UP
            chrsk:= ''
            _crpos:=0
            b:up()
            b:refreshall()
         ELSEIF ch == K_DOWN
               chrsk:= ''
               _crpos:=0
               b:down()
               b:refreshall()
         ELSEIF ch == K_LEFT
                if b:colpos = 1
                   TONE(1000,5)
                endif
                b:colpos := 2
                b:left()
         ELSEIF ch == K_RIGHT
                if b:colpos == b:colcount
                   TONE(1000,5)
                endif
                b:colpos := 4 && 2
                b:right()
         ELSEIF ch == K_PGUP
                chrsk:= ''
                _crpos:=0
                b:pageUp()
                b:refreshall()
         ELSEIF ch == K_PGDN
                chrsk:= ''
                _crpos:=0
                b:pageDown()
                b:refreshall()
         ELSEIF ch == K_HOME
                b:home()
         ELSEIF ch == K_END
                b:End()
         ELSEIF ch == K_CTRL_HOME
                b:panHome()
         ELSEIF ch == K_CTRL_END
                b:panend()
         ELSEIF ch == K_TAB
                b:panRight()
         ELSEIF ch == K_SH_TAB
                b:panLeft()
         ELSEIF ch == K_CTRL_PGUP
                chrsk:= ''
                _crpos:=0
                b:GOTOP()
         ELSEIF ch == K_CTRL_PGDN
                chrsk:= ''
                _crpos:=0
                b:gobottom()
         ELSEIF ch == K_F1
                //d_scrn:=savescreen( , , , )
                //helps()
                //restscreen( , , , ,d_scrn )
         ELSEIF ch == K_F3
		//color setting
                curcolo :=!curcolo
                b:colorspec := if(curcolo,"w/bg+,w/n,w/n,w/n,w/n,w/n,w/n,w/n,w/n,w/n,w/bg+" , ;  //"n/w,w/n,w/n,w/n,w/n,w/n,w/n,w/n,w/n,w/n,n/w"
	                                  "w/n,n/w,n/w,n/w,n/w,n/w,n/w,n/w,n/w,n/w,w/n")
                b:configure()
         ELSEIF ch == K_ESC
                exit
                //b:refreshall()
         ELSEIF ch == K_ENTER
                if deleted()
                   boxshad(10,10,14,60,'On')
                   @12,25 say 'Deleted Records..!!!!'
                   Tone(1000,5)
                   INKEY(.5)
                   boxshad(10,10,14,60,'OFF')
                Else
                   exit
                eNDIF
         /*
         ELSEIF ch == K_BS
                DO WHILE .T.
                   if !empty(chrsk) .or. _crpos > 0
                      IF CH == K_BS
                         _crpos--
                         chrsk:=left(chrsk,len(chrsk)-1)
                      ELSEIF CH <> K_ENTER .AND. CH <> K_ESC
                         _crpos++
                         chrsk:=chrsk+upper(if(chr(ch) $ '0123456789',alltrim(str(val(chr(ch)))),chr(ch)))
                      ENDIF

                      cd:=setcolor()
                      setcolor('w+/n')
                      @nbot,nleft+5 say replicate(chr(176),(nright-6)-(nleft+3))
                      setcolor(cd)
                      @nbot,nleft+5+( (int(((nright-6)-(nleft+3))/2))-(int(len(chrsk)/2)) ) say chrsk+'_'  color 'w+/n'
                      *set softseek on    && RED

                      if !empty(chrsk)
                         b:gotop()
                         IF lFLTER1 == NIL
                            lFND := dbseek(chrsk,.F.)
                         ELSE
                            lFND := dbseek(chrsk,.F.)
                         ENDIF

                         IF !lFND .OR. ;
                            LASTKEY() == K_ENTER .OR. ;
                            LASTKEY() == K_ESC
                            EXIT
                         ENDIF
                      endif

                      *if eof()
                      *   b:gobottom()
                      *endif
                   ELSE
                      EXIT
                   endif

                   CH := INKEY(0)
                ENDDO
                *dbgoto(recno())
                b:refreshall()
         */
         ELSEIF ( ch > 31 .AND. ch < 127 ) .OR. CH == K_BS
                DO WHILE .T.
                   if _crpos <= ncount
                      IF CH == K_BS
                         _crpos--
                         CHRSK := LEFT(CHRSK,LEN(CHRSK)-1)
                      ELSEIF CH <> K_ENTER .AND. CH <> K_ESC
                         _crpos++
                         chrsk:=chrsk+upper(if(chr(ch) $ '0123456789',alltrim(str(val(chr(ch)))),chr(ch)))
                      ENDIF

                      cd:=setcolor()
                      setcolor('w+/n')
                      @nbot,nleft+5 say replicate(chr(176),(nright-6)-(nleft+3)) color 'w+/n'
                      setcolor(cd)
                      @nbot,nleft+5+( (int(((nright-6)-(nleft+3))/2))-(int(len(chrsk)/2)) ) say chrsk+'_'  color 'w+/n'
                      b:gotop()
                      *set softseek on    && RED

                      IF lFLTER1 == NIL
                         lFND:= dbseek(chrsk,.F.)
                      ELSE
                         lFND:= dbseek(chrsk,.F.)
                      ENDIF

                      IF !lFND
                         CHRSK := LEFT(CHRSK,LEN(CHRSK)-1)
                         DBSEEK(CHRSK,.F.)
                         EXIT
                      ELSEIF LASTKEY() == K_ENTER .OR. ;
                             LASTKEY() == K_ESC
                         EXIT
                      ENDIF

                      *If eof()
                      *   b:gobottom()
                      *endif
                   ELSE
                      EXIT
                   endif

                   CH := INKEY(0)
                ENDDO
                b:refreshall()
         ELSE
            Tone(800,5)
         ENDIF

         @nbot,nleft+5 say replicate(chr(176),(nright-6)-(nleft+3)) color 'w+/n'
         @nbot,nleft+5+( (int(((nright-6)-(nleft+3))/2))-(int(len(chrsk)/2)) ) say chrsk+'_'  color 'w+/n'
      ENDDO

      if ch == 13
         *ret_value := if(gEtfld # nil,fieldget(gEtfld),if(empty(nFld1),lseekfld(lseek),fieldget(nFld1)))
         IF lBR == NIL .OR. !lBR      && RETURN VALUE IS CLIENT CODE ONLY
            RET_VALUE := IF(GETFLD # NIL,FIELDGET(GETFLD),IF(EMPTY(NFLD1),LSEEKFLD(LSEEK),FIELDGET(NFLD1)))
         ELSEIF lBR        && RETURN VALUE IS BRANCH CODE + CLIENT CODE
            RET_VALUE := IF(GETFLD # NIL,BRCODE+FIELDGET(GETFLD),IF(EMPTY(nFLD1),LSEEKFLD(LSEEK),BRCODE+FIELDGET(nFLD1)))
         ENDIF
      elseif ch == 27
         ret_value := lSeek
      endif

      reindex->(dbclosearea())
      if !sw
         curdbf->(dbclosearea())
      endif
endif  //!file('Reindex.dbf')

if dbfaray[ 1,1 ] <> select(nDbf)
   dbselectarea( ( dbfaray[ 1, 1 ] ) )
   dbsetorder  ( ( dbfaray[ 1, 2 ] ) )
   dbgoto      ( ( dbfaray[ 1, 3 ] ) )
endif
setcolor    (   dbfaray[ 1, 4 ] )
setcursor   (   dbfaray[ 1, 5 ] )
restscreen( , , , , zz)
rt_value:=ret_value
RETURN (getactive():varput(mval:=eval({ || if(ch<> 27,rt_value,getactive():varget()) } ) ) )

static Function lseekfld(lseek)
local loc_fld
if !empty(lseek) .or. empty(lseek)
   loc_fld:=indexkey()
   if '+' $ loc_fld
      loc_fld:=substr(loc_fld,1,at('+',loc_fld))
      if '(' $ loc_fld .and. ')' $ loc_fld
	 loc_fld:=substr(loc_fld,at('(',loc_fld),at(')',loc_fld))
      endif
   endif
   if '(' $ loc_fld .and. ')' $ loc_fld
      loc_fld:=substr(loc_fld,at('(',loc_fld),at(')',loc_fld))
   endif
else
    return nil
endif
return (loc_fld:=fieldget(fieldpos(upper(alltrim(loc_fld)))))

/*----------------------------*/
FUNCTION boxshad(nT,nL,nB,nR,cSet,cColor)
/*----------------------------*/

STATIC cWinscr := {}
STATIC nEl := 0
if !empty(cColor)
   setcolor(cColor)
endif
IF upper(cSet) = 'ON'
   Aadd(cWinscr, Savescreen(nT,nL,nB+1,nR+2))
   nEl++
   Restscreen(nT+1,nL+1,nB+1,nR+2,;
   Transform(Savescreen(nT+1,nL+1,nB+1,nR+2),;
   Replicate('X' + chr(8), Len(Savescreen(nT+1,nl+1,nB+1,nR+2)))))
   @nT,nl clear TO nB,nR
   @nT,nL TO nB,nR double
ELSE
   Restscreen(nT,nl,nB+1,nR+2,cWinscr[nEl])
   Adel(cWinscr,nEl)
   Asize(cWinscr,nEl)
ENDIF
RETURN nil
/*--------------*/
Function baks(ntop,nleft,nbot,nrght,ntitle,color)
local x:=1,mu:=setcolor(),gf
//private ncolo:=color
if empty(color)
	 color:='w'
endif

setcolor(color)
@ntop,nleft say chr(218)
@ntop,nleft+1 say replicate(chr(196),(nrght)-(nleft+1))

@ntop+1,nleft to nbot-1,nleft   //double
@nbot,nleft+5 say replicate(chr(176),(nrght-2)-(nleft+3)) color 'w+/n'
x:=2
for x:= 1 to (nbot-ntop)-2
	@ntop+x,nrght say chr(176)  color 'w+/n'
next
@ ntop,nrght say chr(191)
@ nbot,nleft say chr(192)
@ nbot,nleft+1 say chr(196)
@ nbot,nleft+2 say chr(196)
@ nbot,nrght-2 say chr(196)
@ nbot,nrght-1 say chr(196)
@ nbot,nrght say chr(217)

if nTitle <> nil
  @ ntop,nrght-(len(ntitle)+2) say ntitle color 'w/gr'
endif
if iscolor()
   set colo to n/w+
endif
@ nbot,nleft+3 say chr(17)+chr(254)  color 'n/w+'
@ nbot,nrght-4 say chr(254)          color 'n/w+'
@ nbot,nrght-3 say chr(16)           color 'n/w+'
@ nbot-1,nrght say chr(31)           color 'n/w+'
@ ntop+1,nrght say chr(30)           color 'n/w+'
setcolor( mu )
return nil

//borrowed function

stat func fEval( f8 )
loca rec
memv gigi

rec  := eval( { | x | x := recno(), dbseek( f8 ), x } )
gigi := 0
dbeval( { || gigi++ },, { | x | x == f8 } )
dbgoto( rec )
gigi := max( gigi, 1 )
return( nil )

static func fRec1Pos( how, howMany )
loca actual := 0, i
stat where := 1

do case
   case how = 'top'
        where := 1
        dbgotop()
   case how = 'bottom'
        where := lastrec()
        dbgobottom()
   case how = 'skip'
        do case
           case howMany < 0
                whil ( actual > howMany ) .and. ( !bof() )
                     dbskip( -1 )
                     if !bof()
                    actual--
                     endi : !bof()
                endd : ( actual > howMany ) .and. ( !bof() )
           case howMany > 0
                whil ( actual < howMany ) .and. ( !eof() )
                     dbskip( +1 )
                     if !eof()
                   actual++
                     endi : !eof()
                endd : ( actual < howMany ) .and. ( !eof() )
                if eof()
                   dbskip( -1 )
                endi : eof()
           othe
                dbskip( 0 )
        endc
   othe
        retu( where )
endc

where += actual
where := min( max( where, 1 ), lastrec() )
retu( actual )

////
*              fRec2Pos('skip',lflter1,lflter2,n)
static func fRec2Pos( how, what, which, howmany )
loca actual := 0, soft
memv gigi, when

do case
   case how = 'top'
        when := 1
        *dbseek( what )
        DBGOTOP()
        DO WHILE !EOF() .AND. !EVAL(WHICH,WHAT)
           DBSKIP(+1)
        ENDDO
   case how = 'bottom'
        when := gigi
        /*
        soft  := set( _SET_SOFTSEEK, .t. )
        dbseek( left( what, len( what ) - 1 ) + chr( 255 ) )
        dbskip( -1 )
        set( _SET_SOFTSEEK, soft )
        */
        DBGOBOTTOM()
        DO WHILE !BOF() .AND. !EVAL(WHICH,WHAT)
           DBSKIP(-1)
        ENDDO
   case how = 'skip'
        do case
           case howmany < 0
                while ( actual > howmany ) .and. ( !bof() ) .and. eval( which, what )
                   dbskip( -1 )
                   if !bof() .and. eval( which, what )
                      actual--
                   endif
                enddo
                *if !eval( which, what )
                if bof() .or. !eval( which, what ) .and. !empty(what)
                   dbskip( +1 )
                endif
           case howmany > 0
                while ( actual < howmany ) .and. ( !eof() ) .and. eval( which, what )
                    dbskip( +1 )
                    if !eof() .and. eval( which, what )
                       actual++
                    endif
                enddo
                if eof() .or. !eval( which, what ) .AND. !EMPTY(WHAT)
                   dbskip( -1 )
                endif
           otherwise
                dbskip( 0 )
        endcase
   otherwise
        return( when )
endcase

when += actual
when := min( max( when, 1 ), gigi )

return( actual )
*--------------------------------------------
FUNCTION FBRCH( cBRCOD )
LOCAL DBFARAY := {}
LOCAL cRETVAL := ''
LOCAL nROW    := ROW()
LOCAL nCOL    := COL()
LOCAL lOPEN   := IF(SELECT("BRANCHES") > 0,.T.,.F.)

IF !lOPEN
   AADD(DBFARAY,{SELECT(),INDEXORD(),RECNO(),SETCOLOR(),SETCURSOR(),SAVESCREEN()})

   IF NETUSE('&G_GRF_PATH\BRANCHES',.F.,10)
      DBSETINDEX('&G_GRF_PATH\BRCODE')
   ELSE
      RETURN NIL
   ENDIF
ENDIF

IF BRANCHES->(DBSEEK(ALLTRIM(cBRCOD),.F.))
   cRETVAL := LEFT(BRANCHES->BRNAME,16)
ELSE
   cRETVAL := NIL
ENDIF

IF !lOPEN
   BRANCHES->(DBCLOSEAREA())

   IF( EMPTY( DBFARAY[1,1] ), NIL, DBSELECTAREA( (DBFARAY[1,1]) ) )
   IF( EMPTY( DBFARAY[1,2] ), NIL, DBSETORDER( (DBFARAY[1,2]) ) )
   IF( EMPTY( DBFARAY[1,3] ), NIL, DBGOTO( (DBFARAY[1,3]) ) )
   IF( EMPTY( DBFARAY[1,4] ), NIL, SETCOLOR(DBFARAY[1,4]) )
   IF( EMPTY( DBFARAY[1,5] ), NIL, SETCURSOR(DBFARAY[1,5]) )
ENDIF

SETPOS(nROW,nCOL)

RETURN cRETVAL
*--------------------------------------------
FUNCTION ACC_BRCH(cUSER)
LOCAL DBFARAY := {}
LOCAL cRETVAL := ""
LOCAL lSW := .F.
LOCAL lOPEN   := IF(SELECT("AXBRANCH") > 0,.T.,.F.)

IF !lOPEN
   AADD(DBFARAY,{SELECT(),INDEXORD(),RECNO(),SETCOLOR(),SETCURSOR(),SAVESCREEN()})

   IF NETUSE('&G_GRF_PATH\AXBRANCH',.F.,10)
      DBSETINDEX('&G_GRF_PATH\AXBRANCH')
   ELSE
      RETURN
   ENDIF
ENDIF

IF AXBRANCH->( DBSEEK( ALLTRIM(cUSER) ) )
   cRETVAL := '"'

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
   cRETVAL := NIL
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
*-----------------------------------------
FUNCTION MKE_TMPPRO(cBRCODES)
LOCAL lRETVAL := .F.
LOCAL DBFARAY := {}
LOCAL bFLTER  := &('{ || '+'PROSPEX->BRCODE $ '+ cBRCODES +' }')
LOCAL aSTRUC
LOCAL lOPEN   := IF(SELECT("PROSPEX") > 0,.T.,.F.)

IF !lOPEN
   AADD(DBFARAY,{SELECT(),INDEXORD(),RECNO(),SETCOLOR(),SETCURSOR(),SAVESCREEN()})

   IF NETUSE('&g_CIS_PATH\PROSPEX',.F.,5)
      aSTRUC := DBSTRUCT()
   ELSE
      RETURN .F.
   ENDIF
ENDIF

   IF FILE('C:\TMPPROS.DBF')
      FERASE('C:\TMPPROS.DBF')

      IF FILE('C:\TMPPROS.NTX')
         FERASE('C:\TMPPROS.NTX')
      ENDIF
   ENDIF

   DBCREATE('C:\TMPPROS',aSTRUC)

IF NETUSE('C:\TMPPROS',.F.,5)
   @ 13,10 SAY 'Creating search file..'
   @ 14,10 SAY REPL('±',60)

   DO WHILE !PROSPEX->(EOF())
      IF PROSPEX->BRCODE $ &cBRCODES
         COPREC()
      ENDIF

      PROSPEX->(DBSKIP())
      @ 14,10 SAY REPL('²',(PROSPEX->(RECNO())/PROSPEX->(RECCOUNT()))*60)
      @ 15,10 SAY TRANS((PROSPEX->(RECNO())/PROSPEX->(RECCOUNT()))*100,'999')+' %'
   ENDDO
   @ 13,10 CLEAR TO 15,70

   DBCREATEINDEX('C:\TMPPROS','FULLNAME+BRCODE+PRPXCODE',{|| FULLNAME+BRCODE+PRPXCODE })

   TMPPROS->(DBCLOSEAREA())

   lRETVAL := .T.
ENDIF

IF !lOPEN
   PROSPEX->(DBCLOSEAREA())

   IF( EMPTY( DBFARAY[1,1] ), NIL, DBSELECTAREA( ( DBFARAY[1,1] ) ) )
   IF( EMPTY( DBFARAY[1,2] ), NIL, DBSETORDER( ( DBFARAY[1,2] ) ) )
   IF( EMPTY( DBFARAY[1,3] ), NIL, DBGOTO( ( DBFARAY[1,3] ) ) )
   IF( EMPTY( DBFARAY[1,4] ), NIL, SETCOLOR( DBFARAY[1,4] ) )
   IF( EMPTY( DBFARAY[1,5] ), NIL, SETCURSOR( DBFARAY[1,5] ) )
ENDIF

RETURN lRETVAL
*----------------------------------------
FUNCTION COPREC()

TMPPROS->(DBAPPEND())

REPLACE TMPPROS->FULLNAME WITH PROSPEX->FULLNAME
REPLACE TMPPROS->BRCODE   WITH PROSPEX->BRCODE
REPLACE TMPPROS->PRPXCODE WITH PROSPEX->PRPXCODE
REPLACE TMPPROS->SHRTNAME WITH PROSPEX->SHRTNAME

TMPPROS->(DBCOMMIT())


RETURN NIL
*-----------------------------------------
FUNCTION VALBRCODE(cBRCODE,cUSER)
LOCAL lRETVAL := .F.
LOCAL cVALCODE := ACC_BRCH(cUSER)

IF cBRCODE $ &cVALCODE
   lRETVAL := .T.
ELSE
   ERROR('You have no rights for this branch.')
ENDIF

RETURN lRETVAL

