// program idúúú tb_maker()
// descriptionúú browse maker
// authorúúúúúúú gener c. singson

//  ABB ONLINE
////
#include 'inkey.ch'
#include 'colf.ch'

////
#xcomm change <v> into <m> => <v> := if( <v> == nil, <m>, <v> )

////
#define clr_colo    'gr+/n, n/w, n/w, w*/n, w/n, w+/n, w+/n,n/w, w+/gr, n/w'
#define clr_mono    'gr+/bg, w+/rb, w+/b, b/w, w+/g, b+/g, r+/n, w+/r, n/w, w+/rb'
#define sound_good  tone( 60, .5 )
#define sound_bad   tone( 480, 0.25 ); tone( 240, 0.25 )
#define frozen      0
#define gr_cell     { 1,  2 }
#define gn_cell     { 7,  8 }
#define gd_cell     { 9, 10 }

////
function __tb_maker( tbcol_  , key_, mtop, mleft, mbottom, mright, mbanner,;
                     mlastrec, mdisplay, mcode, mblock, atop, aleft, abottom,;
                     aright  , sbrcode)
local cb
public tbkill_cel, tbkill_arg, tbkill_color := iscolor(), tbkill_where := 1, tbkill_code := mcode 
public tbkill_lastrec := if( mlastrec == nil, 1, max( mlastrec, 1 ) ), tbkill_rel
public tbkill_mtop, tbkill_mleft, tbkill_mbottom, tbkill_mright, tbkill_mdisplay, tbkill_element

change mtop     into  3
change mleft    into  2
change mbottom  into 22
change mright   into 77
change mbanner  into ''
change mdisplay into .t.
change atop     into  0
change aleft    into  0
change abottom  into  0
change aright   into  0
tbkill_mtop     := mtop
tbkill_mleft    := mleft
tbkill_mbottom  := mbottom
tbkill_mright   := mright
tbkill_mdisplay := mdisplay
tbkill_element  := 1

dispbegin()
_tb_painter( key_, mtop, mleft, mbottom, mright, mbanner, mdisplay, ;
            valtype( mcode ) != 'U' .and. valtype( mblock ) != 'U',;
                                      atop, aleft, abottom, aright )
cb               := tbrowsedb() 
cb:ntop          := mtop    + 1 + atop
cb:nleft         := mleft   + 1 + aleft
cb:nbottom       := mbottom - 1 - abottom
cb:nright        := mright  - 1 - aright
cb:headsep       := 'ÄÂÄ'
cb:colsep        := ' ³ '
if valtype( mcode ) != 'U' .and. valtype( mblock ) != 'U'
   cb:gotopblock    := { |   | getrec( 'top'   , tbkill_code            ) }
   cb:gobottomblock := { |   | getrec( 'bottom', tbkill_code            ) }
   cb:skipblock     := { | n | getrec( 'skip'  , tbkill_code, mblock, n ) }
elseif valtype( mcode ) == 'A'  
   cb:gotopblock    := { |   | tbkill_element := 1                          }
   cb:gobottomblock := { |   | tbkill_element := len( mcode )               }
   cb:skipblock     := { | n | arrrec( tbkill_lastrec, @tbkill_element, n ) }
else
   cb:gotopblock    := { |   | posrec( 'top'     ) }
   cb:gobottomblock := { |   | posrec( 'bottom'  ) }
   cb:skipblock     := { | n | posrec( 'skip', n ) }
endif   

cb:colorspec := if( tbkill_color, clr_mono, clr_colo )
for n := 1 to len( tbcol_ )
    cb:addcolumn( tbcol_[ n ] )
    tbcol_[ n ]:colorblock := { | v | colormode( v ) }       
next    
cb:freeze   := frozen
cb:colpos   := cb:freeze + 1
cb:autolite := .f.
tbkill_arg  := ( ( cb:colpos + 1 ) / cb:colcount ) * ( cb:nright - cb:nleft )
tbkill_cel  := cb:nleft + 2
tbkill_rel  := 1

@ cb:ntop    + 2, cb:nright + 1 say chr( 24 )                          color 'n/w'
@ cb:nbottom    , cb:nright + 1 say chr( 25 )                          color 'n/w' 
@ cb:nbottom + 1, cb:nleft  + 1 say chr( 27 )                          color 'n/w'
@ cb:nbottom + 1, cb:nright - 1 say chr( 26 )                          color 'n/w' 
@ cb:ntop    + 3, cb:nright + 1, cb:nbottom - 1, cb:nright + 1 box '°' color 'w/n'
@ cb:nbottom + 1, cb:nleft  + 2, cb:nbottom + 1, cb:nright - 2 box '°' color 'w/n' 
dispend()  
return( cb )

////
function __tb_stabilize( cb, tb_udf )
local key
memvar tbkill_rel, tbkill_cel, tbkill_arg, tbkill_lastrec, tbkill_color, tbkill_mdisplay
memvar tbkill_code, tbkill_mtop, tbkill_mleft, tbkill_mbottom, tbkill_mright


if lastkey() == K_TAB
   if valtype( tbkill_code ) != 'U'
      dispbegin()
      dispbox( tbkill_mtop + 2, tbkill_mleft, ( ( tbkill_mbottom - 2 ) / 2 ) + tbkill_mtop, tbkill_mleft, '°', 'w/n' )
      dispbox( ( ( tbkill_mbottom - 2 ) / 2 ) + tbkill_mtop, tbkill_mleft, tbkill_mbottom - 2, tbkill_mleft, 'Û', 'w+/w' )
      dispend()
   endif   
endif

while .t.
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
      if tbkill_lastrec > cb:rowcount
          @ cb:ntop + 3 + tbkill_rel, cb:nright + 1 say '°' color 'w/n'
            tbkill_rel := min( ( if( valtype( tbkill_code ) != 'U',;
                       getrec(), if( valtype( tbkill_code ) == 'A',;
                       arrrec(), posrec() ) ) / tbkill_lastrec ) * cb:rowcount, cb:rowcount - 3 )
          @ cb:ntop + 3 + tbkill_rel, cb:nright + 1 say 'Û' color 'w+/w'
      endif   
      @ cb:nbottom + 1, tbkill_cel say '°' color 'w/n'
        tbkill_cel := ( cb:colpos / cb:colcount ) * ( cb:nright - cb:nleft )
        tbkill_cel := if( tbkill_cel < tbkill_arg + 1, cb:nleft + 2,;
                          tbkill_cel + if( cb:colpos == 6, 0, 1 ) )
      @ cb:nbottom + 1, tbkill_cel say 'Û' color 'w+/w'
      dispend()
      key := eval( { || cb:hilite(),inkey( 0 ) } )
      do case
         case tb_navigate( cb, key )     
         case eval( tb_udf, cb, key )
         case key == K_F3
              tbkill_color := !tbkill_color
              cb:colorspec := if( tbkill_color, clr_mono,) //, clr_colo )
              cb:configure()
         case key == K_ESC .or. key == K_TAB   
              if valtype( tbkill_code ) != 'U' .and. tbkill_mdisplay
                 if key == K_TAB
                    dispbegin()
                    dispbox( tbkill_mtop + 2, tbkill_mleft, ( ( tbkill_mbottom - 2 ) / 2 ) + tbkill_mtop, tbkill_mleft, 'Û', 'w+/w' )
                    dispbox( ( ( tbkill_mbottom - 2 ) / 2 ) + tbkill_mtop, tbkill_mleft, tbkill_mbottom - 2, tbkill_mleft, '°', 'w/n' )
                    dispend()
                    sound_good   
                    cb:gotop()
                    exit
                 endif   
              else         
                 if key == K_ESC
                    if exitmod()
                       __mxrelease( tbkill_cel, tbkill_arg, tbkill_lastrec,;
                       tbkill_code, tbkill_where, tbkill_color, tbkill_rel,;
                       tbkill_mtop, tbkill_mleft, tbkill_mbottom, tbkill_mright,;
                       tbkill_mdisplay, tbkill_element )
                       exit        
                    endif
                 endif   
              endif

         otherwise
              sound_bad

      endcase

enddo

return (nil)

************************************
*
function _tb_refresh ( cb,mrefresh )
************************************
change mrefresh into ''


do case
   case lower( mrefresh ) == 'a'
        cb:refreshall() 
   case lower( mrefresh ) == 'c'    
        cb:refreshcurrent()
   otherwise    
        cb:configure()
        while !cb:stabilize()
              if nextkey() <> 0
                 exit
              endif
        enddo
endcase
return( nil )

////
function posrec( how, howmany )
local actual := 0
memvar tbkill_lastrec, tbkill_where

do case
   case how = 'top'
        tbkill_where := 1
        dbgotop()
   case how = 'bottom'
        tbkill_where := tbkill_lastrec
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
        return( tbkill_where )           
endcase
tbkill_where += actual
tbkill_where := min( max( tbkill_where, 1 ), tbkill_lastrec )
return( actual )

////
function getrec( how, what, which, howmany )
local  actual := 0, soft
memvar tbkill_lastrec, tbkill_where

do case
   case how == 'top'
        tbkill_where := 1 
        dbseek( what )
   case how == 'bottom'
        tbkill_where := tbkill_lastrec 
        soft  := set( _SET_SOFTSEEK, .t. )
        dbseek( left( what, len( what ) - 1 ) + chr( 255 ) )
        dbskip( -1 ) 
        set( _SET_SOFTSEEK, soft )
   case how == 'skip'
        do case
           case howmany < 0
                while ( actual > howmany ) .and. ( !bof() ) .and.;
                      eval( which, what )
                      dbskip( -1 )
                      if !bof() .and. eval( which, what )
                         actual--
                      endif
                enddo
                if !eval( which, what )
                   dbskip( +1 )
                endif    
           case howmany > 0
                while ( actual < howmany ) .and. ( !eof() ) .and.;
                      eval( which, what )
                      dbskip( +1 )
                      if !eof() .and. eval( which, what )
                         actual++
                      endif
                enddo
                if eof() .or. !eval( which, what )
                   dbskip( -1 )
                endif
           otherwise
                dbskip( 0 )
        endcase
   otherwise
        return( tbkill_where )           
endcase
tbkill_where += actual
tbkill_where := min( max( tbkill_where, 1 ), tbkill_lastrec )
return( actual )

////
function arrrec( alen, curpos, howmany )
local actual

if howmany >= 0
   if ( curpos + howmany ) > alen
      actual := alen - curpos
      curpos := alen
   else
      actual := howmany
      curpos += howmany
   endif
else
   if ( curpos + howmany ) < 1
      actual := 1 - curpos
      curpos := 1
   else
      actual := howmany
      curpos += howmany
   endif
endif                   
return( actual )

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
function tb_navigate( brow, knob )
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
function _tb_painter( key_, mtop, mleft, mbottom, mright, mbanner,;
                   mdisplay, mline, atop, aleft, abottom, aright )
local mcol := [], mcolor := setcolor()
memvar gSYS_NAME, gUSER_ID, gTRANDATE, tbkill_color

if mdisplay
   scrntitle( mbanner, gSYS_NAME, gUSER_ID, gTRANDATE )
   dispbox( mtop, 0, maxrow() - 1, maxcol(), '', 'n/n' ) 
endif   
fshadow( mtop, mleft, mbottom, mright, 2, 'w+/b' )
if mline
   if atop >= 5
      devpos( mtop + 1, mright ); devout( chr( 24 ), 'n/w' )
      dispbox( mtop + 2, mright, mtop + atop - 2, mright, '°', 'w/n' )
      devpos( mtop + 2, mright ); devout( 'Û', 'w+/w' )
      devpos( mtop + atop - 1, mright ); devout( chr( 25 ), 'n/w' )         
   endif
   if mdisplay
      devpos( mtop + 1, mleft ); devout( chr( 24 ), 'n/w' )
      dispbox( mtop + 2, mleft, mbottom - 2, mleft, '°', 'w/n' )
      dispbox( mtop + 2, mleft, ( ( mbottom - 2 ) / 2 ) + mtop, mleft, 'Û', 'w+/w' )
      devpos( mbottom - 1, mleft ); devout( chr( 25 ), 'n/w' )   
      devpos( mtop + atop, mleft + aleft + 1 )
      devout( repl( 'Ä', mright - aright - mleft + aleft - 1 ) + '´', 'w+/b' )
   endif   
endif
if valtype( key_ ) == 'A'
   aeval( key_, { | k_ | mcol += stuff( k_, at( '\', k_ ), 1, '' ) } )   
   dispbox( 23, 0, 23, maxcol(), '', 'n/n' )
   setpos( 23, ( 80 - len( mcol ) ) / 2 )       
   aeval( key_, { | k_ | setcolor( 'w+/n' ), qqout( subs( k_, 1, at( '\', k_ ) - 1 ) ),;
                         setcolor( 'w/n'  ), qqout( subs( k_, at( '\', k_ ) + 1 ) ) } )
endif                         
setcolor( mcolor )                       
return( nil )

////
function tb_indicator( mkey, mrow, nrow, mcol, top_row, bottom_row, mwhat )
local malias := { | a | ( alias() )->( a ) }

mwhat := if( mwhat == nil, .t., mwhat )

if mwhat
   dispbegin()
   do case
      case mkey == K_UP .or. mkey == K_PGUP
           mrow := if( eval( malias, bof() ), 1, mrow -= 1 )
      case mkey == K_DOWN .or. mkey == K_PGDN        
           mrow := if( eval( malias, eof() ), eval( malias, lastrec() ), mrow += 1 )
      case mkey == K_END .or. mkey == K_CTRL_END
           mrow := eval( malias, lastrec() )
      case mkey == K_HOME .or. mkey == K_CTRL_HOME               
           mrow := 1
   endcase        
   devpos( nrow, mcol ); devout( '°', 'w/n' )
   nrow := top_row + max( 0, mrow /;
           max( eval( malias, lastrec() ), 1 ) * bottom_row - top_row ) 
   devpos( nrow, mcol ); devout( 'Û', 'w+/w' )      
   dispend()
endif   
if eval( malias, bof() ) .or. eval( malias, eof() )
   sound_good
   waiton( if( eval( malias, bof() ), 'First Record', 'Last Record' ), .f., 'n/w', 5 )
   inkey( .1 )
   waitoff()
   if eval( malias, eof() )
      eval( malias, dbgobottom() )
   endif
endif 
return( nil )
