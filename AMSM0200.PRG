/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³   colf-iis -- account management system                                  ³
 ³   program idúúú amsm0200                                                 ³
 ³   descriptionúú Payment Schedule maintenance                             ³
 ³   authorúúúúúúú renan s. evangelista                                     ³
 ³   dateúúúúúúúúú 9:20:am úú 07-24-96                                      ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³                             u p d a t e s                                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³        who        ³       when        ³               why                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 */
///////Program not yet installed
//error('Program not yet installed.....')
#include 'inkey.ch'
#include 'colf.ch'

#defi clr_mono "w/n,n/w,n/w,n/w,n/w,n/w,n/w,n/w,n/w,n/w,w/n"
#defi clr_colo "w/gr,w/n,w/n,w/n,w/n,w/n,w/n,w/n,w/n,w/n,w/gr"


local mu:=savescreen( ,,, )
memvar  AX_LEVEL, gUSER_ID

setcursor(0)
setblink(.t.)
if !chkpass( procname(), AX_LEVEL, gUSER_ID )
   //NOTHING WILL HAPPEN
else
   if amsm0200open()
      amsm0200main()
   endif
endif
setcursor(0)
restscreen( ,,,,mu )
__mrelease( '*', .t. )
dbcloseall()
return nil
/*-----------------------------*/
 Static Function amsm0200main()
/*-----------------------------*/
local xx,zz,mu,xacct:=spac(14)

 while eval({|| fstart0200(@xacct) } )
    fbrow0200(xacct)
 enddo
return nil
/*--------------------------------*/
 Static Function fstart0200(xacct)
/*--------------------------------*/
local mu := savescreen(,,,), ncur:=setcursor()
@ 24,00
@ 24,01 say '                           < ESC >     < 11 > - Up/Down ' color 'w/n'
@ 24,30 say 'ESC'    color 'w+/n'
@ 24,42 say chr(24)+chr(25) color 'w+/n'
fshadow(13,10,15,50,2,'n/w')
*@ 14,11 say 'Account Name  'get xacct when eval( { || xacct:= flook(.t.,'Acctmast',,'Account Master',3,2,1,1),.f.} )
@ 14,11 say 'Account Name  'get xacct when eval( { || xacct:= flook_online(.t.,'Acctmast',,'Account Master',3,2,1,,1),.f.} )

setcursor(3)
read
setcursor(1)

restscreen ( ,,,,mu )
return (lastkey() <> K_ESC)

/*-------------------------------*/
 Static Function fbrow0200(nacctn)
/*-------------------------------*/
local b,o_col:=setcolor(),o_scr:=savescreen(,,,),o_curs:=setcursor()
local ch,col1_:={},_dcolor:=iscolor(),x

dbselectarea('Paysked')
dbsetorder(1)
dbseek(nAcctn)
col1_:= { tbcolumnnew( 'Account No.',{|| Trans(Paysked->Acctno,'@R 9999-99999-99999')} ), ;
          tbcolumnnew( 'Pay No.'    ,{|| trans(Paysked->Paynum,'999') } )               , ;
          tbcolumnnew( 'Pay Date'   ,{|| trans(Paysked->Paydate,'@D') } )               , ;
          tbcolumnnew( 'Amortization',{|| trans(Paysked->Intamt+Paysked->Prnamt,'999,999,999.99')} ),;
          tbcolumnnew( 'Penalty     ',{|| trans(Paysked->Penalty,'999,999,999.99') } )              ,;
        }
fshadow( 3,1,22,78,2,'n/bg' )
@ 24,00
/*
123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
         1         2         3         4         5         6         7         8
                < ESC >   < F2 > - Edit   < 1111 > - Navigation '
                           < ESC >     < 11 > - Up/Down '
*/
@ 24,01 say '                < ESC >   < F2 > - Edit   < 1111 > - Navigation ' color 'w/n'
@ 24,19 say 'ESC'     color 'w+/n'
@ 24,29 say 'F2'      color 'w+/n'
@ 24,45 say chr(26)+chr(24)+chr(25)+chr(27) color 'w+/n'
b := TBrowseDB(04,2,21,77)
FOR x := 1 TO len(col1_)
    b:AddColumn(col1_[x])
NEXT
b:gotopblock    := { |   | fRecp0700( 'top'   , nacctn ) }
b:gobottomblock := { |   | fRecp0700( 'bottom', nacctn ) }
b:skipblock     := { | n | fRecp0700( 'skip'  , nacctn,  ;
                   { | x | Paysked->Acctno == nacctn }, n ) }
b:freeze        := 1
b:colpos        := 2
b:headSep       :=  "ÄÂÄ"
b:colSep        :=  " ³ "
b:gotop()
b:colorspec     := clr_colo
b:refreshall()
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
         if(b:hittop,b:gotop(),b:gobottom())
      endif
      ch := eval({|| Inkey( 0 ) } )
   endif
      setcursor(0)
      IF ch == K_UP
	 b:up()
         b:refreshall()
      ELSEIF ch == K_DOWN
         b:down()
         b:refreshall()
      ELSEIF ch == K_LEFT
      ELSEIF ch == K_RIGHT
      ELSEIF ch == K_F3
        _dcolor:=!_dcolor
        b:colorspec := if(!_dcolor,clr_mono,clr_colo)
        b:gotop()
        b:configure()
      ELSEIF ch == K_PGUP
	  b:pageUp()
          b:refreshall()
      ELSEIF ch == K_PGDN
          b:pageDown()
          b:refreshall()
      ELSEIF ch == K_CTRL_PGUP
	  b:gotop()
          b:refreshall()
      ELSEIF ch == K_CTRL_PGDN
	     b:goBotTOm()
             b:refreshall()
      ELSEIF ch == K_ESC
          tone(500,1);tone(300,1);tone(400,1)
          if Exitmod()
             exit
          endif
      //ELSEIF ch == K_INS
      //        //edit_cell(.t.,nacctn)
      //        b:refreshall()
      ELSEIF ch == K_F2
        if chkpass( 'E', AX_LEVEL, gUSER_ID )
           EDIT_CELL(nacctn)
           b:refreshcurrent()
        endif
      ENDIF
    //b:refreshall()
ENDDO
restscreen(, , , ,o_scr)
return nil
//////////
Static Function feval0200()
local arr_:={},x
for x:= 1 to fcount()
 aadd( arr_, fieldget(x) )
next x
return arr_

/*--------------------------------*/
 Static Function EDIT_CELL(nacctn)
/*--------------------------------*/
local arr_:=feval0200(),arrx 
local o_scr := savescreen(,,,),o_crs:=setcursor(),o_col:=setcolor()
arrx:= arr_[4] + arr_[5]
fshadow(10,09,16,46,2,'n/bg+','Edit Penalty')
setcolor('w/bg+,n+/w,,,w+/bg+')

while .t.
  @ 11, 11 say 'Account No .  ' get arr_[1] picture '@R 9999-99999-9999' when .f.
  @ 12, 11 say 'Pay Number    ' get arr_[2] picture '@B 999'             when .f.
  @ 13, 11 say 'Payment Date  ' get arr_[3] picture '@D'                 when .f.
  @ 14, 11 say 'Amortization  ' get arrx    picture '@B 999,999,999.99'  when .f.
  @ 15, 11 say 'Penalty       ' gget arr_[ 9 ] picture '@B 999,999,999.99'  calculator
  read
  if lastkey() == K_RETURN
     tone(500,1);tone(300,1);tone(400,1)
     if Confirm('Are all entries correct?')
        tone(800,1);tone(600,1);tone(700,1)

//aga.01.25.2005.marker...remove later

        exit
     endif
  elseif lastkey() == K_ESC
    exit
  endif
enddo
if lastkey() <> K_ESC
   if netlock('R',5)
      Paysked->Penalty := arr_[ 9 ]
      dbunlock()
      dbcommit()
   endif
endif
restscreen(,,,,o_scr)
setcursor(o_crs)
setcolor(o_col)
return nil




/*-----------------------------*/
 Static Function amsm0200open()
/*-----------------------------*/

if !netuse('Acctmast',.f.,5)
   return .f.
endif
set index to Acctacno

if !netuse('Paysked',.f.,5)
   return .f.
endif
set index to Paysked,Paydsked
Paysked->( dbsetorder(1) )

scrntitle ( 'Payment Schedule Maintenance', gSYS_NAME, gUSER_ID, gTRANDATE )
@ 3,0 clear to 24,80
dispbox   ( 3, 1, 22,78, repl('²',9), 'w/n' )
//@ 24,00 say repl(' ',79) color 'w/n'
@ 23,1 say repl('Û',78) color 'bg+/n'
return .t.

////////////////////////////////////////////////////////////////////////////
static function fRecp0700( how, what, which, howmany, vax )    //skip block function that filters the display
local  actual := 0, soft                                       //of records per account number

do case
   case how = 'top'
        dbseek( what,.f. )
   case how = 'bottom'
        soft  := set( _SET_SOFTSEEK, .t. )
        dbseek( left( what, len( what ) - 1 ) + chr( 255 ) )
        dbskip( -1 )
        set( _SET_SOFTSEEK, soft )
   case how = 'skip'
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
                if (eof() .or. !eval( which, what )) .and. !empty( what )
                   dbskip( -1 )
                endif
                dbskip(0)
           otherwise
                dbskip( 0 )
        endcase
   otherwise
endcase
return( actual )
