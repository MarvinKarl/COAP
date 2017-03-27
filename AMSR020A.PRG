/*
  program id...: repcntrl.prg                                         
  description..: report control routine                               
  author.......: gener c. singson                                     
  date.........: 9:14am 26-4-1995                                   
  compile with.: /n /w /rnanfor
  syntax.......: repcontrol( < cname >, < [ cmess ] >, < [ ctext ] >,;
                                          < [ nrow ] >, < [ ncol ] > )
  <   cname   > := report procedure name                            
  < [ cmess ] > := an optional message for paper to be used in prn  
  < [ ctext ] > := an optional temporary textfile to be used in prn 
  < [ nrow  ] > := an optional row to display menu                  
  < [ ncol  ] > := an optional col to display menu                  
                                                                        
  example......: repcntrl( 'print_me()', '80 column', 'pr.txt', 11, 44 )    
*/

////
#incl 'colf.ch'
#incl 'inkey.ch'

////
#defi color_colo  'gr+/bg, w+/n'
#defi color_mono  'gr+/n, n/w'
#defi sound_one    tone( 60, .5 )
#defi sound_two    tone( 480, 0.25 ); tone( 240, 0.25 )
#defi frozen       0

#xcom xToneLevel       => tunes( { { 177, .57 }, { 57, 7 }, { 117, .97 } } )
#xtra tunes( <a> )     => aeval( < a >, { | a | tone( a\[ 1 ], a\[ 2 ] ) } )
#xtra xPutField( <a> ) => eval( { || _field->( <a> )->line1  := subs( mtext,   1, 15 ),;
                                     _field->( <a> )->line2  := subs( mtext,  16, 15 ),;
                                     _field->( <a> )->line3  := subs( mtext,  31, 15 ),;
                                     _field->( <a> )->line4  := subs( mtext,  46, 15 ),;
                                     _field->( <a> )->line5  := subs( mtext,  61, 15 ),;
                                     _field->( <a> )->line6  := subs( mtext,  76, 15 ),;
                                     _field->( <a> )->line7  := subs( mtext,  91, 15 ),;
                                     _field->( <a> )->line8  := subs( mtext, 106, 15 ),;
                                     _field->( <a> )->line9  := subs( mtext, 121, 15 ),;
                                     _field->( <a> )->line10 := subs( mtext, 136, 15 ),;
                                     _field->( <a> )->line11 := subs( mtext, 151, 15 ),;
                                     _field->( <a> )->line12 := subs( mtext, 166, 15 ),;
                                     _field->( <a> )->line13 := subs( mtext, 181, 15 ),;
                                     _field->( <a> )->line14 := subs( mtext, 196, 15 ),;
                                     _field->( <a> )->line15 := subs( mtext, 211, 15 ),;
                                     _field->( <a> )->line16 := subs( mtext, 226, 15 ),;
                                     _field->( <a> )->line17 := subs( mtext, 241, 15 ),;
                                     _field->( <a> )->line18 := subs( mtext, 256, 15 ),;
                                     _field->( <a> )->line19 := subs( mtext, 271, 15 ) ;
                                } )
                                  
////
function prncontrol( procname, papersize, textname, y_axis, x_axis, sw )
local ft_flogic
local savedbf_ := if( empty( alias() ), {}, ft_fzip() )
prnflag := .f.

set defa to c:\
sw:=if(sw==nil,.t.,sw)
begin sequence
   ft_finit( procname, papersize, textname, y_axis, x_axis )
recover using ft_flogic
   if ft_flogic
      if len( savedbf_ ) > 0
         ft_funzip( savedbf_ )         
      endif  
   endif
end sequence

set defa to
if prnflag
   return sw
else
   return !sw
endif
return ( eval( { || prnflag } ) )
//__mrelease( '*', ft_flogic )
////
static function ft_finit( procname, papersize, textname, y_axis, x_axis )
local menulist, ft_flogic := !.f., mscreen := savescreen( ,,, ), mvar
local mcursor := setcursor( setcursor() ), mcolor := setcolor(), mchoice
local namedata := 'tmx' + subs( stuff( time(), 3, 1, '_' ), 1, 3 ) + subs( time(), -2, 2 ) + '.dbf'
local nametext := 'c:\prx' + subs( stuff( time(), 3, 1, '_' ), 1, 3 ) + subs( time(), -2, 2 ) + '.txt'
priva pg_eject_switch := 0, mstring := space( 100 )

papersize := if( papersize == nil, 'normal', papersize )
textname  := if( textname  == nil, nametext, textname  )
y_axis    := if( y_axis    == nil,        9, y_axis    )
x_axis    := if( x_axis    == nil,       25, x_axis    )

if procname != nil
   if !file( textname )
      if !ft_ffixed( textname )
         break ft_flogic
      endif
   endif 
   
   eval( { || setcursor( 0 ), set( 32, .f. ),;
              set( 36,  0  ), set( 35, .t. ), set( 37, .f. ) } )
              
   mchoice := ft_ftext( y_axis, x_axis )
   setcolor( 'n/bg, w+/rb,,, n/bg' )

   @ y_axis + 1, x_axis + 1 prompt ' ~Screen/Printer   ' + chr( 16 ) + ' ' message '' messagecolor 'w+/n' triggercolor 'w+/bg'
   @ y_axis + 2, x_axis + 1 prompt ' ~File             ' + chr( 16 ) + ' ' message '' messagecolor 'w+/n' triggercolor 'w+/bg'
   menu to mchoice initial mchoice timeout 120
   //@ y_axis + 2, x_axis + 1 prompt ' ~Printer    '                 message '' messagecolor 'w+/n' triggercolor 'w+/bg'
   do case
      case mchoice == 1
           ft_fscreen( procname, namedata, textname, y_axis, x_axis )
      //case mchoice == 2
           //ft_fprinter( procname, papersize, y_axis, x_axis )
      case mchoice == 2
           ft_ffile( procname, y_axis, x_axis )
   endcase   
   
   eval ( { || setcursor( mcursor ), setcolor( mcolor ),               ;
                ( namedata )->( dbclosearea() ),;
                 ferase( 'c:\' + ( namedata ) ),;
                 ferase( 'c:\' + ( textname ) ), set( 36, 22 ) ;
          };
        )
endif
inkey( .25 )
restscreen( ,,,, mscreen )
break ft_flogic
return( nil )

////
static function ft_fscreen( procname, namedata, textname, y_axis, x_axis )
local menulist, mpick := 1, mcolor := setcolor()
local mscreen := savescreen( y_axis + 1, x_axis + 13, y_axis + 5, x_axis + 24 )

fshadow( y_axis + 1, x_axis + 21, y_axis + 4, x_axis + 30, 2, 'n/w' )
@ y_axis + 1, x_axis + 22 say 'Mode' color 'w+/w'
@ y_axis + 2, x_axis + 22 prompt ' ~Normal ' message '' messagecolor 'w+/n' triggercolor 'w+/bg'
@ y_axis + 3, x_axis + 22 prompt ' ~Shrink ' message '' messagecolor 'w+/n' triggercolor 'w+/bg'
menu to mpick initial mpick &&timeout 30

if mpick != 0
   waiton( 'Generating Screen Report',, 'n*/+w' )
   set printer to &textname.
   set device to printer
   eval( &('{ ||' + procname + '}' ) )
   set printer to
   set device to screen
   waitoff()
   if ft_fselect( namedata, textname, y_axis, x_axis )
      ft_fbrowse( mpick )
   endif   
   ( namedata )->( dbclosearea() )
   ferase( ( namedata ) )
   ferase( ( textname ) )
endif   
setcolor( mcolor )
inkey( .25 )
restscreen( y_axis + 1, x_axis + 13, y_axis + 5, x_axis + 24, mscreen )
return( nil )

////
static function ft_fprinter( procname, papersize, y_axis, x_axis )
memvar pg_eject_switch

if yes_no2( 'Ready printer with ' + papersize + ' paper.  Continue?',, ' Yes ', ' No ', .t. )
   if !ft_fprintready()
   else
      pg_eject_switch := 2
      waiton( 'Printing, please wait.',, 'n*/+w' )
      set device to printer
      eval( &('{ ||' + procname + '}' ) )
      set device to screen
      waitoff()
      waiton( 'Printing completed, press any key.',, 'n*/+w' )
      inkey( .50 )
      waitoff() 
      pg_eject_switch := 0
  endif
endif  
return( nil )

////
static function ft_ffile( procname, y_axis, x_axis ) 
local mscreen := savescreen( y_axis + 3, x_axis + 13, y_axis + 6, x_axis + 26 )
local mdrive := eval( { | x | x := '\' + curdir() + '\',;
      strtran( x, '\\', '\' ), padr( lower( x ), 50 ) } ), getlist := {}
local mcolor := setcolor()     

fshadow( y_axis + 3, x_axis + 13, y_axis + 5, x_axis + 24, 2, 'n/w' )
@ y_axis + 3, x_axis + 14 say 'Filename' color 'w+/w'
@ y_axis + 4, x_axis + 14 get mdrive picture '@XS10' valid !empty( mdrive ) color 'w+/gr'
setcursor( 3 )
readmodal( getlist ); getlist := {}
setcursor( 0 ) 
if lastkey() != K_ESC
   if ft_ffixed( mdrive )
      ferase( ( mdrive ) )
      waiton( 'Generating File Report',, 'n*/+w' )
      set printer to &mdrive. 
      set device to printer
      eval( &( '{ ||' + procname + '}' ) )
      set printer to
      set device to screen
      waitoff()
   endif
endif
setcolor( mcolor ) 
restscreen( y_axis + 3, x_axis + 13, y_axis + 6, x_axis + 26, mscreen )
return( nil ) 

////
static function ft_fselect( namedata, textname, y_axis, x_axis )
local mtemp, mtext, i, mread_ := {}, mscreen, mkey := .t.
priva mwork := 1, mline := 0

namedata := subs( namedata, 1, 8 )

if !file( 'read.dbf' )
   waiton( 'Press any key to continue, <Esc> to abort.',, 'n/+w' )
   inkey( 0 )
   waitoff()
   if mkey := lastkey() != K_ESC
      for i := 1 to 19
          aadd( mread_, { 'line' + ltrim( str( i, 2 ) ), 'c', 15, 0 } )
      next
	  aadd( mread_,{ 'line20','n',10,0 } )
      dbcreate( 'read', mread_ )
   endif
endif
if mkey
   if netuse( 'read', .f., 10 )
      mtemp := read->( dbstruct() )
      read->( dbclosearea() )
      dbcreate( namedata, mtemp )
      if netuse( namedata, .f., 10 )
         ft_fuse( textname )
         mline   := max( ft_flastrec(), 1 )
         mscreen := ft_fprep( y_axis, x_axis )
         while !ft_feof()                         
               mtext := ft_freadln()              
               if ( namedata )->( netlock( 'A', 0 ) )
                  xPutField( namedata )               
                  //( namedata )->( dbcommit() )
               endif
               ( namedata )->( dbunlock() )
               ft_fwork( y_axis, x_axis )
               ft_fskip()
         enddo
         ( namedata )->( dbcommit() )
         ft_fuse()
         inkey( .5 )
         restscreen( y_axis + 2, x_axis + 1, y_axis + 5, x_axis + 14, mscreen )
      endif
   endif      
endif   
return( mkey )

////
static function ft_fprep( y_axis, x_axis )
local mret := savescreen( y_axis + 2, x_axis + 1, y_axis + 5, x_axis + 14 ) 

dispbegin()
fshadow( y_axis + 2, x_axis + 1, y_axis + 4, x_axis + 12, 2, 'n/w' )
@ y_axis + 2, x_axis + 2 say 'Preparing'     color 'w+/w' 
@ y_axis + 3, x_axis + 2 say repl( '°', 10 ) color 'w+/n'
dispend()
return( mret )

////
static function ft_fwork( y_axis, x_axis )
memvar mwork, mline  

dispbegin()
@ y_axis + 3, x_axis + 1 + mwork say '°' color 'w+/n'
mwork := max( ( ( ft_frecno() / mline ) * 10 ), 1 ) 
@ y_axis + 3, x_axis + 1 + mwork say 'Û' color 'w+/w'
dispend()
return( nil ) 

////
static function ft_fbrowse( mchoice )
local column, browse, key, n, celpos, mmode, msnap := .f., nstart
local relpos, color := iscolor(), mread := .t., argue, mcolor := setcolor()
local mclear_, mmessy_ := ft_fclear( .t. )
private sr_rec,col_rec

dispbox( 0, 0, maxrow(), maxcol(), space( 9 ), 'n/n' )
mmode := if( mchoice == 2, setmode( 43, 80 ), .f. ) 

dbgotop()
dispbegin()
@  1,  2 say 'Screen Report Scroller'             color 'w+/n'
@  1, 74 say 'COLF'                               color 'w+/n'
@  2,  1, if( mmode, 41, 23 ), 78 box 'ÚÄ¿³ÙÄÀ³ ' color 'w+/bg'
@ if( mmode, 42, 24 ),  2  say '<ESC>Exit/Printer <F3>color <F4>search'   color 'w+/n'
@ if( mmode, 42, 24 ),  7  say 'Exit/Printer'     color 'w/n'
@ if( mmode, 42, 24 ), 24  say 'Color'            color 'w/n'
@ if( mmode, 42, 24 ), 34  say 'Search'           color 'w/n'
@ if( mmode, 42, 24 ), 58  say 'Percentage ¯'     color 'w/n'
browse               := tbrowsedb()
browse:ntop          :=  3
browse:nleft         :=  2
browse:nbottom       := if( mmode, 40, 22 )
browse:nright        := 77
browse:colsep        := ''
browse:colorspec     := if( color, color_colo, color_mono )
browse:gotopblock    := { |   | ft_fpointer( 'top'     ) }
browse:gobottomblock := { |   | ft_fpointer( 'bottom'  ) }  
browse:skipblock     := { | n | ft_fpointer( 'skip', n ) }
column               := tbcolumnnew()
browse:addcolumn( column )
for n := 1 to fcount()-1
    column            := tbcolumnnew()
    column:defcolor   := { 1, 2 }
    column:block      := fieldblock( field( n ) )
    browse:addcolumn( column ) 
next
browse:freeze        := frozen
browse:colpos        := browse:freeze + 1
browse:autolite      := .f.
argue                := ( ( browse:colpos + 1 ) / ( browse:colcount ) ) * 75
celpos               := 4
relpos               := 1
@ browse:ntop       , browse:nright + 1 say chr( 24 ) color 'n/w'
@ browse:nbottom    , browse:nright + 1 say chr( 25 ) color 'n/w' 
@ browse:nbottom + 1, browse:nleft  + 1 say chr( 27 ) color 'n/w'
@ browse:nbottom + 1, browse:nright - 1 say chr( 26 ) color 'n/w' 
@ browse:ntop    + 1, browse:nright + 1,;
  browse:nbottom - 1, browse:nright + 1 box repl( '°', 9 ) color 'w+/n'
@ browse:nbottom + 1, browse:nleft  + 2,;
browse:nbottom + 1, browse:nright - 2 box repl( '°', 9 ) color 'w+/n' 
while !browse:stabilize(); enddo
mclear_ := ft_fclear( .t. )
dispbox( 0, 0, maxrow(), maxcol(), space( 9 ), 'n/n' )
dispend()
ft_fclear( .f., mclear_ )
     
while .t.
   
  if browse:colpos > browse:colcount
     sound_one
  endif
      
  if browse:colpos <= browse:freeze
     sound_one
  endif
 
  if msnap
     if !browse:stable
        while !browse:stabilize()
          if nextkey() <> 0
             exit
          endif
        enddo
     endif
  else
    msnap := !msnap   
  endif   
      
  if browse:hittop .or. browse:hitbottom
     sound_two
  endif
  
  dispbegin()      
  if lastrec() > browse:rowcount
     @ browse:ntop + 1 + relpos, browse:nright + 1 say '°' color 'w+/n'
       relpos := min( ( ft_fpointer() / lastrec() ) * browse:rowcount,;
                                                  browse:rowcount - 3 )
     @ browse:ntop + 1 + relpos, browse:nright + 1 say 'Û' colo '+gr/w'
  endif
  @ browse:nbottom + 1, celpos say '°' colo '+w/n'
    celpos := ( browse:colpos / browse:colcount ) * 75
    celpos := if( celpos < argue + 1, 4, celpos )
  @ browse:nbottom + 1, celpos say 'Û' colo '+gr/w'
  @ if( mmode, 42, 24 ), 71    say padr( str( round( ( recno() /;
                    lastrec() ) * 100, 0 ), 3 ) + ' %', 5 ) colo 'w+/n' //ft_fpointer()
  browse:hilite()
  dispend()

  key := ft_finkey( if( mmode, +1, -1 ), )  
  
  do case
     case ft_fnavigate( browse, key )                         
     case key == K_F3
          color            := !color
          browse:colorspec := if( color, color_colo, color_mono )
          browse:configure()
     case key == K_F4     
          browse:colpos := browse:freeze + 1 + ft_ffour( row() - 1,.f. )
          browse:refreshall()
     case key == K_CTRL_L
          browse:colpos := browse:freeze + 1 + ft_ffour( row() - 1,.t. )
          browse:refreshall()
     case key == K_ESC
          if confirm(' Re-direct output to printer? ') .and. lastkey() <> K_ESC
             ft_printing()
             if !confirm('..Continue viewing? ') .and. Lastkey() <> K_ESC
                setprc( 0, 0 )
                exit
             else
                browse:refreshall()
             endif
          elseif lastkey() <> K_ESC
             exit
          endif
  endcase
enddo
setmode( 25, 80 )
setcolor( mcolor )
ft_fclear( .f., mmessy_ )
__mrelease('*',.t. )
return( nil )

////
static function ft_fclear( mpar, mwhat_ )
local n, m, mdelay := 750, mclear_ := ''

if mpar
   mclear_ := {}
   for n := 0 to maxrow()
       aadd( mclear_, savescreen( n, 0, n, maxcol() ) )
   next
else
   for n := 0 to maxrow()
       restscreen( n, 0, n, maxcol(), mwhat_[ n + 1 ] )
       for m := 1 to mdelay
       next
   next
endif
return( mclear_ )   

////
static function ft_ffour( row, swc )
local  msearch, mrecno, getlist := {}
local  col := 1, mscreen, sx, x
memvar mstring

sx      := eval( { || if( col() > 40, 36, 4 ) } )
mstring := padr( mstring, 100 )

mscreen := savescreen( row, sx, row + 3, sx + 40 )
if !swc
  fshadow( row, sx, row + 2, sx + 38, 2, 'n/w' )
  @ row    , sx + 1 say 'Search' color 'w+/w'
  @ row + 1, sx + 1 get mstring picture '@XS37' valid !empty( mstring ) color 'w+/gr'
  setcursor( 3 )
  readmodal( getlist )
  getlist := {}
  setcursor( 0 )
endif
if lastkey() != K_ESC
   mstring := upper( rtrim( mstring ) )
   mrecno  := recno()
   if swc .and. recno() == sr_rec
      dbskip()
   endif
   while recno() != lastrec() + 1
         msearch := upper( ( field->line1  ) + ( field->line2  ) +;
                           ( field->line3  ) + ( field->line4  ) +;
                           ( field->line5  ) + ( field->line6  ) +;
                           ( field->line7  ) + ( field->line8  ) +;
                           ( field->line9  ) + ( field->line10 ) +;
                           ( field->line11 ) + ( field->line12 ) +; 
                           ( field->line13 ) + ( field->line14 ) +; 
                           ( field->line15 ) + ( field->line16 ) +; 
                           ( field->line17 ) + ( field->line18 ) +; 
                           ( field->line19 ) )                    
         if ( col := ( ( at( mstring, msearch ) / 285 ) * 19 ) ) != 0
            if swc .and. col_rec == col .and. sr_rec == recno()
               if ( col := ( ( at( mstring, substr(msearch,col,500) ) / 285 ) * 19 ) ) != 0
                  sr_rec:=recno()
                  col_rec := col
                  exit
               endif
            else
              sr_rec:=recno()
              col_rec := col
              exit
           endif
         endi
         dbskip( +1 )   
   enddo
   if eof()
      dbgoto( mrecno )
   endif   
endif
restscreen( row, sx, row + 3, sx + 40, mscreen )
return( max( col, 1 ) + 1 )

////
static function ft_fpointer( how, howmany )
local  actual := 0, i
static where  := 1

do case
   case how == 'top'
        where := 1
        dbgotop()
   case how == 'bottom'
        where := lastrec()
        dbgobottom()
   case how == 'skip'
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
            othe
                 dbskip( 0 )
        endcase
   othe
        return( where )
endcase
where += actual
where := min( max( where, 1 ), lastrec() )
return( actual )

////
static function ft_fnavigate( brow, knob )
local did := .t.

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
   case knob == K_TAB
        brow:panright()      
   case knob == K_SH_TAB
        brow:panleft()
   othe
        did := .f.     
endcase
return( did )

////
static function ft_fprintready()
local mready := .f.

while .t.
      if !isprinter()
         waiton( 'Printer not ready.  Any key to retry, <Esc> to exit.',, 'n/w+' )
         inkey( 5 )
         waitoff()
         if lastkey() == K_ESC
            exit
         endif
      else
         mready := .t.
         exit
      endif
enddo
return( mready )

////
static function ft_ffixed( mdrive )
local ret := .t.

fcreate( mdrive, 0 )
if ferror() <> 0
   waiton( 'Please check your drive, press any key.',, 'n/+w' )
   inkey( 0 )
   waitoff()
   ret := .f.
endif
return( ret )

////
static function ft_fzip()
return( { select(), indexord(), recno() } )

////
static function ft_funzip( ar_ )
return( eval( { | n | dbselectar( ar_[ 1 ] ),;
                      dbsetorder( ar_[ 2 ] ),;
                      dbgoto(     ar_[ 3 ] ), n } ) )

////
static function ft_ftext( y_axis, x_axis )

dispbegin()
fshadow( y_axis, x_axis, y_axis + 3, x_axis + 21, 2, 'n/w' )
dispbox( y_axis + 1, x_axis + 1, y_axis + 2, x_axis + 20, space( 9 ), 'w+/bg' )
@ y_axis, x_axis +  1 say 'Destination' color 'w+/w'
dispend()
return( 1 )

////
Static Function ft_printing()
local cChoice,mstring,mu:=setcolor(),gf:=setcursor(),lnd:=recno()
local strpage:=1,endpage,sw:=.f.,menulist,bf:=savescreen( ,,, ),xFlg:=.f.
dbgoto( 2 )
if Empty(line20) .or. line20 == 0
  waiton('Preparing hardcopy..,please wait')
  endpage:=rep_fld()
  waitoff()
else
  endpage:=eval( { || dbgoto(lastrec()), line20 } )
endif

fshadow( 9, 19, 12, 45, 2,'n/w')
while .t.
@ 10,28 say '[ All   Pages ]'                       color 'w+/w'
@ 10,30 say 'All   Pages'                           color 'n/w'
@ 11,28 say '[   1 - '+tran(endpage,'99999')+' ]'   color 'w+/w'
@ 11,32 say '1'                                     color 'n/w'
@ 11,36 say tran(endpage,'@B 99999')                color 'n/w'
@ 10,20 prompt '  ~All  ' message '' messagecolor 'w+/n' triggercolor 'w+/bg'
@ 11,20 prompt ' ~Range ' message '' messagecolor 'w+/n' triggercolor 'w+/bg'
menu to cChoice initial cChoice timeout 120
do case
   case cChoice == 1
    dbgotop()
    exit
     //print all
   case cChoice == 2
     //print by range
     while .t.
     setcursor(3)
     setcolor('w/bg','w/n',,,'w+/bg')
     @ 11, 30 get strpage pict '999'   valid eval( { || ft_found(strpage) } )
     @ 11, 36 get endpage pict '@B 99999' valid (endpage >= strpage)
     read
     if lastkey() == K_ESC .and. exitmod()
        xFlg := .t.
        exit
     else
        exit
     endif
     endd
     if xFlg
        loop
     else
        exit
     endif
     setcursor(gf)
     setcolor(mu)
     dbgotop()
     locate all for line20 == strpage
     exit
   case cChoice == 0
     setcursor(gf)
     setcolor(mu)
     dbgoto( lnd )
     restscreen( ,,,,bf )
     return nil
endcase
endd
if confirm(' Pause between pages? ' )
   sw:=.t.
endif
do while !Isprinter()
      if alert( 'Printer is either off or out of paper..',{'Retry','Exit'},'n/w') == 2
         setcursor(gf)
         setcolor(mu)
         dbgoto( lnd )
         restscreen( ,,,,bf )
         return nil
      else
         loop
      endif
enddo

set console off
set printer on
prnflag := .t.
do while line20 <= endpage .and. !eof()
   mstring :=  ( field->line1  ) + ( field->line2  ) +;
                     ( field->line3  ) + ( field->line4  ) +;
                     ( field->line5  ) + ( field->line6  ) +;
                     ( field->line7  ) + ( field->line8  ) +;
                     ( field->line9  ) + ( field->line10 ) +;
                     ( field->line11 ) + ( field->line12 ) +;
                     ( field->line13 ) + ( field->line14 ) +;
                     ( field->line15 ) + ( field->line16 ) +;
                     ( field->line17 ) + ( field->line18 ) +;
                     ( field->line19 )
   if ( rat( Chr(12) ,mstring ) <> 0 )
     if recno() <> lastrec()
       if sw
          do while !Isprinter()
             set console on
             set printer off
             if cd:=alert( 'Printer is either off or out of paper..',{'Retry','Exit'},'n/w') == 2
                set console on
                set printer off
                setcursor(gf)
                setcolor(mu)
                dbgoto( lnd )
                restscreen( ,,,,bf )
                exit
                //return nil
             else
                 set console off
                 set printer on
                 loop
             endif
             set console off
             set printer on
          enddo
          ? rtrim(mstring)
          dbskip()
          mstring :=  ( field->line1  ) + ( field->line2  ) +;
                     ( field->line3  ) + ( field->line4  ) +;
                     ( field->line5  ) + ( field->line6  ) +;
                     ( field->line7  ) + ( field->line8  ) +;
                     ( field->line9  ) + ( field->line10 ) +;
                     ( field->line11 ) + ( field->line12 ) +;
                     ( field->line13 ) + ( field->line14 ) +;
                     ( field->line15 ) + ( field->line16 ) +;
                     ( field->line17 ) + ( field->line18 ) +;
                     ( field->line19 )
         set printer off
         set console on
         error('Print wait..')
         set printer on
         set console off
      endif
     endif
   endif
   ? rtrim(mstring)
   dbskip()
enddo
set console on
set printer off
dbgoto( lnd )
restscreen( ,,,,bf )
return nil

Static Function rep_fld()
local mstring:='',pagenum:=0

dbgotop()
netlock( 'F', 0 )
do while !eof()
   pagenum++
   mstring := upper( ( field->line1  ) + ( field->line2  ) +;
                     ( field->line3  ) + ( field->line4  ) +;
                     ( field->line5  ) + ( field->line6  ) +;
                     ( field->line7  ) + ( field->line8  ) +;
                     ( field->line9  ) + ( field->line10 ) +;
                     ( field->line11 ) + ( field->line12 ) +;
                     ( field->line13 ) + ( field->line14 ) +;
                     ( field->line15 ) + ( field->line16 ) +;
                     ( field->line17 ) + ( field->line18 ) +;
                     ( field->line19 ) )
   do while ( rat( Chr(12) ,mstring ) == 0 ) .and. !eof()
      replace field->line20  with pagenum
      dbskip()
      mstring := upper( ( field->line1  ) + ( field->line2  ) +;
                     ( field->line3  ) + ( field->line4  ) +;
                     ( field->line5  ) + ( field->line6  ) +;
                     ( field->line7  ) + ( field->line8  ) +;
                     ( field->line9  ) + ( field->line10 ) +;
                     ( field->line11 ) + ( field->line12 ) +;
                     ( field->line13 ) + ( field->line14 ) +;
                     ( field->line15 ) + ( field->line16 ) +;
                     ( field->line17 ) + ( field->line18 ) +;
                     ( field->line19 ) )
   enddo
   if ( rat( Chr(12) ,mstring ) <> 0 )
      replace field->line20 with pagenum
   endif
   dbskip()
enddo
dbcommit()
dbunlock()
return pagenum

Static Function ft_found(npage)
dbgotop()
locate all for line20 == npage
if found()
   return .t.
else
   return .f.
endif            
return nil

#stdout end of 'report control routine'
/*
         1         2         3         4         5         6
12345678901234567890123456789012345678901234567890123456789012345678901234567890
 <ESC>Exit/Printer <F3>color <F4>search <CTRL_L>con't search  percentage 999 %

*/
