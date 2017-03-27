/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   colf-iis -- account management system                                      ³
³                                                                              ³
³   program idúúú amsq0130.prg                                                 ³
³   descriptionúú accounts masterlist by branch                                ³
³   authorúúúúúúú gener c. singson                                             ³
³   dateúúúúúúúúú 11:29:34ú11am úú 4-18-95                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                         u p d a t e s                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³       who         ³       when        ³               why                    ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

////
#include 'inkey.ch'
#include 'colf.ch'

////
#define   nirvana tone( 480, 0.25 ); tone( 240, 0.25 )
  
////
local water

if !chkpass( procname(), AX_LEVEL, gUSER_ID )
   // until then my luv    
else
   nosnow( .t. )
   begin sequence
         fOpen0130()
         fMain0130()
   recover using water
         if water
            dbcloseall()
            __mrelease( '*', water )
         endif   
   end sequence
   nosnow( .f. )
endif   
return

////
static function fMain0130()
local sv, water
priva _x := -1

savescreen( ,,, sv )
if !fDraw0130()
   while water := !eval( { || fMall0130(), if( _x # -3, !.t., !.f. ) } )
   enddo
endif
   
restscreen( ,,,, sv )
if water := !water
   break water
endif   
return( nil )

////
static function fMall0130()
local menulist 
memva _x
priva total_princ := total_amort := total_creda := total_osbal := 0
priva grand_princ := grand_amort := grand_creda := grand_osbal := 0
priva con, gnam, mpage := 1
private linclude_sold

linclude_sold := .f.

_x := abs( _x )

@ 10, 35 prompt ' ~One ' message '';
         messagecolor 'w+/n' triggercolor '+w/gr'
*****@ 12, 35 prompt ' ~All ' message '';
*****         messagecolor 'w+/n' triggercolor '+w/gr'
menu to _x initial _x &&timeout 20
      
do case
   case _x == 0 
        _x  := -3
   case _x == 1
        _x  := -1
        con := { || eval( gnam ) == ACCTMAST->BRCODE } && +subs( Acctmast->acctno, 3, 2 ) }

        if confirm( 'Include Sold Receivables?',.t. )
           linclude_sold := .t.
        endif

        if lastkey() != K_ESC
           fDone0130()
        endif
   case _x == 2   
        _x  := -2
        if lastrec() > 0
           dbgotop()
           con := { || !eof() }
           fDone0130()
        else
           error( 'No Available Record!' )        
        endif     
endcase        
return( _x )

////
******************************
*
static function fDone0130()
******************************
local msv
priva sw, cnt := inc := 0, ind := 1

msv := savescreen( ,,, )
if !fDate0130()
   reportprint( 'fPrnt0130()', '132 COLUMN' )
   *repcon_ol( 'fPrnt0130()', '132 COLUMN',,,,,,.F. )
   inkey( .5 )   
endif
restscreen( ,,,, msv )
return( nil )

////
****************************
*
function fPrnt0130()
****************************
local ac_name := 'piañ', ax
memva grand_princ, grand_amort, grand_creda, grand_osbal
memva con, sw, _x, cnt 

if _x == -1
   dbeval( { || cnt += 1 },,{ || eval( con ) } )
   dbseek( eval( gnam ) )        
else
   cnt := Acctmast->( lastrec() )  
endi
   
set device to screen
ax := savescreen( 7, 1, 20, 36 )
fOutp0130()                             
set device to printer   
fHead0130()
 
dbeval( { | n | n := if( ac_name != ACCTMAST->BRCODE,;  &&+subs( Acctmast->acctno, 3, 2 ),;
               eval( { || sw := -1, ACCTMAST->BRCODE;   &&+subs( Acctmast->acctno, 3, 2 ) ;
                         } ), ac_name ), fDisp0130( ac_name := n ) ;
        },,                                                        ;
        { || eval( con ) } )
if _x == -2       
   fSubt0130()
endif
   
fEjec0130()        
@ prow() + 1, 108 say repl( 'Ä', 18 )
@ prow()    , 167 say repl( 'Ä', 18 )
@ prow()    , 186 say repl( 'Ä', 18 )
@ prow()    , 205 say repl( 'Ä', 18 )
fEjec0130()
@ prow() + 1,  91 say 'Grand-Total ¯'
@ prow()    , 108 say grand_princ picture '999,999,999,999.99'
@ prow()    , 167 say grand_amort picture '999,999,999,999.99'
@ prow()    , 186 say grand_creda picture '999,999,999,999.99'
@ prow()    , 205 say grand_osbal picture '999,999,999,999.99'
fEjec0130()
@ prow() + 1, 108 say repl( 'Í', 18 )
@ prow()    , 167 say repl( 'Í', 18 )
@ prow()    , 186 say repl( 'Í', 18 )
@ prow()    , 205 say repl( 'Í', 18 )
__eject()           
set device to screen   
inkey( .5 )
restscreen( 7, 1, 20, 36, ax )
return( .t. )

////
****************************************
*
static function fDisp0130( ac_name )
****************************************
local row := 1, gdamt, rvamt
memva total_princ, total_amort, total_creda, total_osbal
memva grand_princ, grand_amort, grand_creda, grand_osbal
memva sw, cnt, ind, inc

   if Acctmast->status == '0'           // CANCELLED RLV 08/18/2010
        return nil
   endif

if Acctmast->status== '6'           // SOLD REC'BLES
   if !linclude_sold
      return nil
   endif
endif

if ( total_princ + total_amort + total_creda + total_osbal ) > 0 .and. sw == -1
     fSubt0130()
     fEjec0130()
     @ prow() + 1, 184 say ''
endif   

total_princ += Acctmast->principal
total_amort += Acctmast->amort
total_creda += Acctmast->credamt
total_osbal += Acctmast->osbal
grand_princ += Acctmast->principal
grand_amort += Acctmast->amort
grand_creda += Acctmast->credamt
grand_osbal += Acctmast->osbal

if sw == -1
   fEjec0130()
   Branches->( dbseek( ac_name ) )
   @ prow() + 1,  9 say ac_name + ' - '  picture '@!'
   @ prow()    , 15 say Branches->brname picture '@!'
   set device to screen
   scroll( 8, 18, 9, 31, 1 )
   @ 9, 18 say padr( Branches->brname, 14 ) color 'w+/rb'
   set device to printer
   sw  := 1   
   row := 2
endif   
fEjec0130()
   if Acctmast->Status != '1'
     do case
        case Acctmast->status == '2'   // PDR
           @ prow() + row , 00 say 'p'
        case Acctmast->status == '3'  // ITEMS
           @ prow() + row , 00 say 'i'
        case Acctmast->status == '4'  // ROPOA
           @ prow() + row , 00 say 'r'
        case Acctmast->status == '5'  // WRITTEN-OFF
           @ prow() + row , 00 say 'w'
        case Acctmast->status == '6'  // SOLD
           @ prow() + row , 00 say 's'
        otherwise
           @ prow() + row , 00 say 'e'
     endcase
     row:=row-1
   endif
if substr(Acctmast->fcltycode,1,3) == '103'
	gdamt := Acctmast->gd 
	rvamt := Acctmast->rv
else
	gdamt := 0
	rvamt := 0
endif

@ prow() + row,   9 say  ACCTMAST->BRCODE+Acctmast->acctno  picture '@R 999-9999-99999-99999'
@ prow()      ,  30 say padr( Acctmast->acctname, 40 ) picture '@!'
@ prow()      ,  71 say       Acctmast->unit           picture '@!'
@ prow()      , 112 say       Acctmast->principal      picture '999,999,999,999.99'
@ prow()      , 131 say       gdamt             picture '99.99'
@ prow()      , 137 say       rvamt             picture '99.99'
@ prow()      , 143 say       Acctmast->term           picture '999'
@ prow()      , 146 say ' months'
@ prow()      , 154 say       Acctmast->remterm        picture '999'
//aga.03.09.2007.insert getremterm function here
//_get_remterm(cacctno, dpaydate, dtermctr, cbrcode)

@ prow()      , 157 say ' months'
@ prow()      , 165 say       Acctmast->truerate       picture '99.99'
@ prow()      , 171 say       Acctmast->amort          picture '999,999,999,999.99'
@ prow()      , 190 say       Acctmast->credamt        picture '999,999,999,999.99'
@ prow()      , 209 say       Acctmast->osbal          picture '999,999,999,999.99'
//aga.03.09.2007.insert getosbal function here
//tgetosbal(xacctno, xcredamt, xdate, xbrcode)

set device to screen
@ 17,  3 say tran( grand_amort,         '999,999,999.99' ) color 'w+/rb'
scroll( 11, 18, 12, 31, 1 )
@ 12, 18 say padr( Acctmast->unit, 14 )                    color 'w+/rb' 
scroll( 14, 18, 15, 31, 1 )
@ 15, 18 say tran( Acctmast->principal, '999,999,999.99' ) color 'w+/rb' 
scroll( 17, 18, 18, 31, 1 )
@ 18, 18 say tran( Acctmast->amort,     '999,999,999.99' ) color 'w+/rb'
@ 18, 18 say tran( Acctmast->amort,     '999,999,999.99' ) color 'w+/rb'
@  9 + ind, 33 say '°'                                     color 'w+/n'
       ind := int( max( ( ( inc += 1 ) / cnt ) * 7, 1 ) )
@  9 + ind, 33 say 'Û'                                     color 'w+/w'
set device to printer
return( nil )

////
static function fSubt0130()
memva total_princ, total_amort, total_creda, total_osbal

fEjec0130()        
@ prow() + 1, 112 say repl( 'Ä', 18 )
@ prow()    , 171 say repl( 'Ä', 18 )
@ prow()    , 190 say repl( 'Ä', 18 )
@ prow()    , 209 say repl( 'Ä', 18 )
fEjec0130()
@ prow() + 1,  95 say '  Sub-Total ¯'
@ prow()    , 112 say total_princ picture '999,999,999,999.99'
@ prow()    , 171 say total_amort picture '999,999,999,999.99'
@ prow()    , 190 say total_creda picture '999,999,999,999.99'
@ prow()    , 209 say total_osbal picture '999,999,999,999.99'
fEjec0130()
@ prow() + 1, 112 say repl( 'Ä', 18 )
@ prow()    , 171 say repl( 'Ä', 18 )
@ prow()    , 190 say repl( 'Ä', 18 )
@ prow()    , 209 say repl( 'Ä', 18 )
total_princ := total_amort := total_creda := total_osbal := 0
return( nil )

////
static function fHead0130()
memvar mpage, gSYS_NAME, gCOMPANY

setfont( upper( 'init' ) )
prnreptitle( 136, 5, mpage++, 'ACCOUNTS MASTERLIST', 'AMSQ0130', gSYS_NAME, gCOMPANY ) 
setfont( upper( 'normal' ) )
@ prow() + 1, ( 136 - 16 ) / 2 say 'As of ' + dtoc( Flag->lastclosed)
setfont( upper( 'condensed' ) )
@ prow() + 1, 8 say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
@ prow() + 1, 8 say '³                    ³                                        ³                                        ³                  ³     ³     ³ Original ³Remaining ³True ³     Monthly      ³      Credit      ³   Outstanding    ³'
@ prow() + 1, 8 say '³     Account N§     ³              Account Name              ³               Collateral               ³     Proceeds     ³ G D ³ R V ³   Term   ³   Term   ³ Rate³   Amortization   ³      Amount      ³     Balance      ³'
@ prow() + 1, 8 say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
return( nil )

////
static function fEjec0130()

if prow() >= 55
   __eject()
   fHead0130()
endif
return( .t. )   

////
static function fDate0130()
local getlist := {}, mcd := space( 3 )
local mcl := setcolor(), log := !.f.
memva gnam, _x

setcolor( 'n/bg, w+/n,,, gr+/bg' )
fShadow( 13, 15, 15, 33, 2, 'n/w' )
@ 14, 16 say 'Branch Code ' + chr( 16 ) + ' '

if _x != -1
   @ 14, 30 say padr( 'All', 3 ) color 'gr+/bg'      
else
   @ 14, 30 gget mcd picture '@!';     &&when pseek( @mcd ) valid fPad0130( @mcd )
                 VALID IF( !EMPTY(MCD) .AND. LASTKEY() == K_ENTER,;
                           IF( VALBRCODE(MCD,g_USER_ID), EVAL({|| fPADXXXX(@MCD, 3),.T.}), EVAL({|| MCD := SPACE(3),.F.}) ) ,;
                           EVAL({|| PSEEK( @MCD ), IF( LASTKEY() == K_ENTER, IF( VALBRCODE(MCD,g_USER_ID), EVAL({|| fPADXXXX(@MCD,3),.T.}), EVAL({|| MCD := SPACE(3), .F.})), EVAL({|| MCD := SPACE(3), .F.}) ) }) ;
                         )
endif
   
setcursor( 3 )
setkey( K_ESC, { || fEscape( 'Abort?' ) } )
read &&timeout 20 exitevent blankscr3( -1 )
setkey( K_ESC, nil )
setcursor( 0 )

if lastkey() != K_ESC
   log  := !.t.
   gnam := { || mcd }  
endif

inkey( .5 )
setcolor( mcl )
return( log )

////
static function pseek( mcd )
return( eval( { || __lb_lkup( 'Branches', 1, 2, @mcd, 2, 1,  ,10,36,20,75,'W/GR+,W/N,,,W/GR+' ), .t. } ) )

////
/*
static function fPad0130( mcd )
local log := !.f.

if !dbseek( mcd := padr( mcd, 3 ) )    && RED REPLACED 2 WITH 3
   log := !.t.
   error( 'No such Record!' )
endif
return( log )
*/
////
static function fDraw0130()

setcolor( 'n/gr, +w/gr' )
*****fShadow( 9, 33, 14, 42, 2, 'n/w' )

fShadow ( 9, 33, 12, 42, 2, 'n/w' )

@ 10, 40 say 'ß'                     color 'w/n'
@ 11, 36 say 'ÜÜÜÜÜ'                 color 'w/n'

*****@ 12, 40 say 'ß'                     color 'w/n'
*****@ 13, 36 say 'ÜÜÜÜÜ'                 color 'w/n'

/*
@  9, 32 say 'Â'                     color 'n/w'
 
@ 10, 32 say '³'                     color 'n/w'
@ 10, 34 say 'Select and write the'  color 'n+/w'
 
@ 11, 32 say '³'                     color 'n/w' 
@ 11, 34 say '            you want'  color 'n+/w'
@ 11, 34 say 'Branch Code'           color 'w+/w'
 
@ 12, 32 say '³'                     color 'n/w' 
@ 12, 34 say 'to be printed in the'  color 'n+/w'
@ 13, 32 say '³'                     color 'n/w'
@ 13, 34 say 'Accounts Masterlist'   color 'w+/w'
@ 13, 53 say '.'                     color 'n+/w'  
@ 14, 32 say 'Á'                     color 'n/w'
*/
return( .f. )

////
static function fOutp0130()                             

inkey( .5 )
dispbegin()
fShadow(  7,  1, 19, 34, 2,   'n/w'  )
dispbox(  8, 17, 18, 17, '³', 'n/w'  )
dispbox(  8, 32, 18, 32, '³', 'n/w'  )
dispbox( 10, 33, 16, 33, '°', 'w+/n' ) 
dispbox( 10,  2, 10, 31, 'Ä', 'n/w'  )
dispbox( 13,  2, 13, 31, 'Ä', 'n/w'  )
dispbox( 16,  2, 16, 31, 'Ä', 'n/w'  )
@  7, 17 say 'Â'             color 'n/w'
@  7, 32 say 'Â'             color 'n/w'
@  8, 33 say chr( 24 )       color 'w+/w'
@  9, 32 say 'ÃÄ´'           color 'n/w' 
@ 10,  1 say 'Ã'             color 'n/w'
@ 10, 17 say 'Å'             color 'n/w'
@ 10, 32 say '´'             color 'n/w' 
@ 13,  1 say 'Ã'             color 'n/w'
@ 13, 17 say 'Å'             color 'n/w'
@ 13, 32 say '´'             color 'n/w' 
@ 16,  1 say 'Ã'             color 'n/w'
@ 16, 17 say 'Å'             color 'n/w'
@ 16, 32 say '´'             color 'n/w' 
@ 17, 32 say 'ÃÄ´'           color 'n/w' 
@ 18, 33 say chr( 25 )       color 'w+/w'  
@ 19, 17 say 'Á'             color 'n/w'
@ 19, 32 say 'Á'             color 'n/w'
@  9,  4 say '  Branch Name' color 'gr+/w'
@ 12,  4 say '   Collateral' color 'gr+/w'
@ 15,  4 say '    Principal' color 'gr+/w'
@ 18,  4 say ' Amortization' color 'gr+/w'
dispend()
return( nil )

////
static function fOpen0130()
local water := !.f.

if !netuse( '&g_AMS_PATH\Flag', .f., 10 )                 && flag
   break water
endif

if !netuse( '&g_GRF_PATH\Branches', .f., 10 ) && branches
   break water
else
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_GRF_PATH\Brcode' )         && set index brcode
endif
   
if !netuse( '&g_AMS_PATH\Acctmast', .f., 10 ) && account master
   break water
else 
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_AMS_PATH\Acctsub' )        && set index subs( acctno, 3, 2 )
                                              &&           + acctname
endif                                       
return( nil )
