// program idúúú lb_lkup()// descriptionúú look-up maker
// authorúúúúúúú gener c. singson

////
#include 'inkey.ch'
#include 'colf.ch'

////
#xcomm change <v> into <m> => <v> := if( <v> == nil, <m>, <v> )

////
#define clr_colo    'n/bg, w+/n'
#define clr_mono    'gr+/n, n/w'
#define sound_good  tone( 60, .5 )
#define sound_bad   tone( 480, 0.25 ); tone( 240, 0.25 )
#define frozen      0
#define gr_cell     { 1, 2 }
#define gn_cell     { 1, 2 }
#define gd_cell     { 1, 2 }

////                1       2         3         4         5        6        7        8     9      10       11      12      13      14      15      16      17       18      19         20      21      22
function __lb_lkup( mfname, mntxseek, mntxdisp, mvarname, mfield1, mfield2, mfield3, mtop, mleft, mbottom, mright, mcolor, mpict1, mpict2, mPICT3, get_me, cbrcode, cfirst, cfullname, FLDNM1, FLDNM2, FLDNM3)
local msystem_ := systack(), mrecordno, mholder, mretval := .f.
local cb, n, rel, mkey, mlastpressed, iscolor := iscolor(), medit, lFND, nORGPOS
local tbcol_ := {}
/* tbcol_ := { tbcolumnnew( 'Description', { || tran( eval( fieldblock( field( mfield1 ) ) ), mpict1 ) } ),;
               tbcolumnnew( 'Branch'     , { || tran( eval( fieldblock( field( mfield2 ) ) ), mpict2 ) } ),;
               tbcolumnnew( 'Code'       , { || tran( eval( fieldblock( field( mfield3 ) ) ), mpict3 ) } ) ;
             } */
IF mFIELD1 <> NIL
   IF mPICT1 <> NIL
      IF FLDNM1 <> NIL
         AADD(tbcol_, tbcolumnnew( FLDNM1, { || tran( eval( fieldblock( field( mfield1 ) ) ), mpict1 ) } ) )
      ELSE
         AADD(tbcol_, tbcolumnnew( (MFNAME)->(FIELDNAME(mFIELD1)), { || tran( eval( fieldblock( field( mfield1 ) ) ), mpict1 ) } ) )
      ENDIF
   ELSE
      IF FLDNM1 <> NIL
         AADD(tbcol_, tbcolumnnew( FLDNM1, { || eval( fieldblock( field( mfield1 ) ) ) } ) )
      ELSE
         AADD(tbcol_, tbcolumnnew( (MFNAME)->(FIELDNAME(mFIELD1)), { || eval( fieldblock( field( mfield1 ) ) ) } ) )
      ENDIF
   ENDIF
ENDIF

IF mFIELD2 <> NIL
   IF mPICT2 <> NIL
      IF FLDNM2 <> NIL
         AADD(tbcol_, tbcolumnnew( FLDNM2, { || tran( eval( fieldblock( field( mfield2 ) ) ), mpict2 ) } ) )
      ELSE
         AADD(tbcol_, tbcolumnnew( (MFNAME)->(FIELDNAME(mFIELD2)), { || tran( eval( fieldblock( field( mfield2 ) ) ), mpict2 ) } ) )
      ENDIF
   ELSE
      IF FLDNM2 <> NIL
         AADD(tbcol_, tbcolumnnew( FLDNM2, { || eval( fieldblock( field( mfield2 ) ) ) } ) )
      ELSE
         AADD(tbcol_, tbcolumnnew( (MFNAME)->(FIELDNAME(mFIELD2)), { || eval( fieldblock( field( mfield2 ) ) ) } ) )
      ENDIF
   ENDIF
ENDIF

IF mFIELD3 <> NIL
   IF mPICT3 <> NIL
      IF FLDNM3 <> NIL
         AADD(tbcol_, tbcolumnnew( FLDNM3, { || tran( eval( fieldblock( field( mfield3 ) ) ), mpict3 ) } ) )
      ELSE
         AADD(tbcol_, tbcolumnnew( (MFNAME)->(FIELDNAME(mFIELD3)), { || tran( eval( fieldblock( field( mfield3 ) ) ), mpict3 ) } ) )
      ENDIF
   ELSE
      IF FLDNM3 <> NIL
         AADD(tbcol_, tbcolumnnew( FLDNM3, { || eval( fieldblock( field( mfield3 ) ) ) } ) )
      ELSE
         AADD(tbcol_, tbcolumnnew( (MFNAME)->(FIELDNAME(mFIELD3)), { || eval( fieldblock( field( mfield3 ) ) ) } ) )
      ENDIF
   ENDIF
ENDIF

private where_is := 1     
change mpict1 into '@X'
change mpict2 into '@X'
change mpict3 into '@X'
change get_me into 1

   setcursor   ( 0 )

   dbselectar  ( mfname )
   ordsetfocus ( mntxseek )

   if lastrec() > 0
       medit := .t.

       IF cFIRST == NIL
          if !dbseek( upper(mvarname) )
             mrecordno := -1
          else
             mrecordno := recno()
          endif

       ELSEif cFIRST <> NIL .AND. upper (cfirst) == 'CODE'
          if !dbseek( cbrcode+upper(mvarname) )
             mrecordno := -1
          else
             mrecordno := recno()
          endif

       elseIF mRECORDNO <> NIL

          ordsetfocus ( mntxdisp )

          if !dbseek( alltrim(upper(cfullname)) )
             mrecordno := -1
          else
             mrecordno := recno()
          endif

       endif

       nORGPOS := RECNO()        && RED 110504

       ordsetfocus( mntxdisp )
       dbgotop()
       IF mRECORDNO <> NIL
          if ( mrecordno == -1, dbgotop(), dbgoto( mrecordno ) )
       ENDIF
       dispbegin()
       fshadow( mtop, mleft, mbottom, mright, 2, 'w+/gr' )   
       cb               := tbrowsedb() 
       cb:ntop          := mtop    + 1
       cb:nleft         := mleft   + 1
       cb:nbottom       := mbottom - 1
       cb:nright        := mright  - 1
       cb:headsep       := 'ÄÂÄ'
       cb:colsep        := ' ³ '
       cb:gotopblock    := { |   | lookrec( 'top'     ) }
       cb:gobottomblock := { |   | lookrec( 'bottom'  ) }
       cb:skipblock     := { | n | lookrec( 'skip', n ) }
       cb:colorspec := if( iscolor, clr_colo, clr_mono )
       for n := 1 to len( tbcol_ )
           cb:addcolumn( tbcol_[ n ] )
           tbcol_[ n ]:colorblock := { | v | colormode( v ) }       
       next    
       cb:freeze   := frozen
       cb:colpos   := cb:freeze + 1
       cb:autolite := .f.
       rel_what  := 1
       @ cb:ntop    + 2, cb:nright + 1 say chr( 24 )                          color 'n/w'
       @ cb:nbottom    , cb:nright + 1 say chr( 25 )                          color 'n/w' 
       @ cb:ntop    + 3, cb:nright + 1, cb:nbottom - 1, cb:nright + 1 box '°' color 'w/n'
       dispend()  
   else
       error ( 'No Record to View!' )
       medit := .f.
   endif

   mlastpressed := ''

   do while medit
      if cb:colpos > cb:colcount
         sound_good
      endif

      if cb:colpos <= cb:freeze
         sound_good
         cb:colpos := cb:freeze + 1
      endif

      while !cb:stabilize()
            if nextkey() <> 0
               exit
            endif
      enddo

      if cb:hittop .or. cb:hitbottom
         sound_good
         waiton( if( cb:hittop, 'First Record', 'Last Record' ), .f., 'n/w', row() - 2 )
         inkey( .1 )
         waitoff()
      endif

      dispbegin()

      if lastrec() > cb:rowcount
          @ cb:ntop + 3 + rel_what, cb:nright + 1 say '°' color 'w/n'
            rel_what := min( ( lookrec() / lastrec() ) * cb:rowcount, cb:rowcount - 3 )
          @ cb:ntop + 3 + rel_what, cb:nright + 1 say 'Û' color 'w+/w'
      endif

      dispend()

      mkey := eval( { || cb:hilite(), inkey( 0 ) } )

      do case
         case navigate( cb, mkey )     
              @ cb:nbottom + 1, cb:nleft + 1 say repl( 'Ä', len( mlastpressed ) + 1 ) color 'w+/gr' 
              mlastpressed := ''         
         case mkey == K_F3
              iscolor := !iscolor
              cb:colorspec := if( iscolor, clr_colo, clr_mono )
              cb:configure()
         case mkey == K_ENTER
              IF GET_ME <> NIL
                 mholder  := ( mfname )->( field( get_me ) )
                 mvarname := &mholder
              ENDIF
              exit
         case mkey == K_ESC
              exit
         case mkey == K_BS

              if !empty( mlastpressed )
                 mlastpressed := subs( mlastpressed, 1, len( mlastpressed ) - 1 )
                 if empty( mlastpressed )
                    @ cb:nbottom + 1, cb:nleft + 1 say 'ÄÄ' color 'w+/gr'
                 else
                    @ cb:nbottom + 1, cb:nleft + 2 say upper( mlastpressed ) + 'Ä' color 'w+/gr'


                    if !dbseek( upper(mlastpressed), .t. )
                       if len( mlastpressed ) == 1
                           mrecordno := recno()
                       endif
                       do case
                          case dbseek( upper( mlastpressed ) )
                               mrecordno := recno()
                          case dbseek( lower( mlastpressed ) )
                               mrecordno := recno()
                       endcase
                       dbgoto ( mrecordno )
                    endif
                    if( eof(), dbgobottom(), nil )
                    cb:refreshall()
                 endif
              endif
         case mkey >= 32 .and. mkey <= 254  // ALPHANUMERIC !!!

              DO WHILE .T.
                 if empty( mlastpressed )
                    mlastpressed := chr( mkey )
                 else
                    IF mKEY == K_BS
                       mlastpressed := LEFT(mlastpressed,LEN(mLASTPRESSED)-1)
                    ELSEIF mKEY <> K_ENTER .AND. mKEY <> K_ESC
                       mlastpressed := mlastpressed + chr( mkey )
                    ENDIF
                 endif

                 if len( mlastpressed ) > 30
                    mlastpressed := left( mlastpressed,30 )
                 endif

                 @ cb:nbottom + 1, cb:nleft + 1 say '' + REPL('Ä',30)    color 'w+/gr'
                 @ cb:nbottom + 1, cb:nleft + 2 say upper( mlastpressed ) color 'w+/gr'

                 IF EMPTY(mLASTPRESSED)
                    DBGOTO(nORGPOS)
                    EXIT
                 ENDIF

                 mrecordno := recno()
                 lFND := DBSEEK( upper(mLASTPRESSED) )

                 *if !dbseek( mlastpressed, .t. )  && RED
                 IF !lFND
                    if len( mlastpressed ) == 1
                       mrecordno := recno()
                    endif
                    do case
                       case dbseek( upper( mlastpressed ) )
                            mrecordno := recno()
                       case dbseek( lower( mlastpressed ) )
                            mrecordno := recno()
                    endcase
                    dbgoto( mrecordno )

                    mLASTPRESSED := LEFT(mLASTPRESSED,LEN(mLASTPRESSED)-1)

                    @ cb:nbottom + 1, cb:nleft + 1 say '' + REPL('Ä',30)    color 'w+/gr'
                    @ cb:nbottom + 1, cb:nleft + 2 say upper( mlastpressed ) color 'w+/gr'

                    EXIT
                 ELSEIF LASTKEY() == K_ENTER
                    EXIT
                 ELSEIF LASTKEY() == K_ESC
                    DBGOTO(nORGPOS)
                    EXIT
                 endif

                 mKEY := INKEY(0)

                 *if( eof(), dbgobottom(), nil )
              ENDDO

              cb:refreshall()
         otherwise
              sound_bad     
         endcase
   enddo
   sysflow( msystem_ )
   return( mretval )

////
static function colormode( value )
local type := valtype( value ), clr

do case
   case type == 'N' .and. value < 0
        clr := gn_cell
   case type == 'L' .and. !value
        clr := gn_cell
   case type == 'D'
        clr := gd_cell      
   other
        clr := gr_cell
endcase
return( clr )

////
static function lookrec( how, howmany )
local actual := 0
memvar where_is

do case
   case how = 'top'
        where_is := 1
        dbgotop()
   case how = 'bottom'
        where_is := lastrec()
        dbgobottom()
   case how = 'skip'
        do case
           case howmany < 0
                while ( actual > howmany ) .and. ( !bof() )
                      dbskip( -1 )
                      if !bof()
                         actual--
                      endif
                enddo
           case howmany > 0
                while ( actual < howmany ) .and. ( !eof() )
                      dbskip( +1 )
                      if !eof()
                         actual++
                      endif
                enddo
                if eof()
                   dbskip( -1 )
                endif
           otherwise
                dbskip( 0 )
        endcase
   otherwise
        return( where_is )           
endcase
where_is += actual
where_is := min( max( where_is, 1 ), lastrec() )
return( actual )

////
static function navigate( brow, knob )
loca did := .t.

do case
   case knob == K_UP    
        brow:up()
   case knob == K_DOWN  
        brow:down()
   case knob == K_LEFT  
        brow:left()
   case knob == K_RIGHT 
        brow:right()
   case knob == K_PGUP
        brow:pageup()
   case knob == K_PGDN
        brow:pagedown()
   case knob == K_CTRL_PGUP
        brow:gotop()
   case knob == K_CTRL_PGDN
        brow:gobottom()
   case knob == K_HOME
        brow:home()
   case knob == K_END
        brow:end()
   case knob == K_CTRL_HOME
        brow:panhome()
   case knob == K_CTRL_END
        brow:panend()                
   otherwise
        did := .f.     
endcase        
return( did )

////
static function systack()
return( { select(), indexord(), recno(), setcursor( setcursor() ), setcolor(), savescreen( ,,, ) } )

////
static function sysflow( ar_ )
LOCAL cSEL := SELECT()
return( eval( { || dbselectar( ar_[ 1 ] ), dbsetorder( ar_[ 2 ] ),;
                   IF(ar_[ 1 ]<>cSEL, dbgoto(     ar_[ 3 ] ), NIL),;
                   setcursor(  ar_[ 4 ] ), setcolor(   ar_[ 5 ] ),;
                   restscreen( ,,,, ar_[ 6 ] );
            } );
      )
*
*              End of the program( myluk.prg )
*




