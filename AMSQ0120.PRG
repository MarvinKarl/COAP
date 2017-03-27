/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   colf-iis -- account management system                                      ³
³                                                                              ³
³   program idúúú amsq0120.prg                                                 ³
³   descriptionúú accounts masterlist by facility                              ³
³   authorúúúúúúú gener c. singson                                             ³
³   dateúúúúúúúúú 9:37:34ú19am úú 3-9-95                                       ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                         u p d a t e s                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³       who         ³       when        ³               why                    ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ janet b. salvador ³  18-july-2002     ³ remove accts w/ 0 bal (line 190)     ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

////
#include 'inkey.ch'
#include 'colf.ch'

////
#define   nirvana tone( 480, 0.25 ); tone( 240, 0.25 )

if !chkpass( procname(), AX_LEVEL, gUSER_ID )
   // until then my luv    
else
   begin sequence
         nosnow( .t. )
         fOpen0120()
         fMain0120()
         nosnow( .f. )
   end sequence
   dbcloseall()
endif   
__mrelease( '*', !.f. )
return

////
static function fMain0120()
local sv
priva _x := -1

savescreen( ,,, sv )
if !fDraw0120()
   while !eval( { || fMall0120(), if( _x # -3, !.t., !.f. ) } )
   enddo
endif   
restscreen( ,,,, sv )
return( nil )

////
static function fMall0120()
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
        con := { || eval( gnam ) == ACCTMAST->BRCODE+Acctmast->fcltycode } && RED 11162004 ADDED ACCTMAST->BRCODE

        if confirm( 'Include Sold Receivables?',.t. )
           linclude_sold := .t.
        endif

        if lastkey() != K_ESC
           fDone0120()
        endif

   case _x == 2   
        _x  := -2
        if lastrec() > 0
           dbgotop()
           con := { || !eof() }
           fDone0120()
        else
           error( 'No Available Record!' )        
        endif     
endcase        
return( _x )

////
static function fDone0120()
local msv
priva sw, cnt := inc := 0, ind := 1

msv := savescreen( ,,, )
if !fDate0120()
   reportprint( 'fPrnt0120()', '132 COLUMN' )
   *repcon_ol( 'fPrnt0120()', '132 COLUMN',,,,,,.F. )
   inkey( .5 )   
endif

restscreen( ,,,, msv )
return( nil )

////
function fPrnt0120()
local fc_code := 'piañ', ax
memva grand_princ, grand_amort, grand_creda, grand_osbal
memva con, sw, _x, gnam, cnt 

if _x == -1
   dbeval( { || cnt += 1 },,;
           { || eval( con ) } )
   dbseek( eval( gnam ) )        
else
   cnt := Acctmast->( lastrec() )  
endi
   
set device to screen
ax := savescreen( 7, 1, 20, 36 )
fOutp0120()                             
set device to printer   
fHead0120()

dbeval( { | n | n := if( fc_code != ACCTMAST->BRCODE+padr( Acctmast->fcltycode, 5 ),;
                    eval( { || sw := -1, ACCTMAST->BRCODE+padr( Acctmast->fcltycode,;
                    5 ) } ), fc_code ), fDisp0120( fc_code := n )  ;
        },,                                                        ;
        { || eval( con ) } )
if _x == -2       
   fSubt0120()
endif
   
/**********************************************
fEjec0120()        
@ prow() + 1, 110 say repl( 'Ä', 18 )
@ prow()    , 169 say repl( 'Ä', 18 )
@ prow()    , 188 say repl( 'Ä', 18 )
@ prow()    , 207 say repl( 'Ä', 18 )
fEjec0120()
@ prow() + 1,  93 say 'Grand-Total ¯'
@ prow()    , 110 say grand_princ picture '999,999,999,999.99'
@ prow()    , 169 say grand_amort picture '999,999,999,999.99'
@ prow()    , 188 say grand_creda picture '999,999,999,999.99'
@ prow()    , 207 say grand_osbal picture '999,999,999,999.99'
fEjec0120()
@ prow() + 1, 110 say repl( 'Í', 18 )
@ prow()    , 169 say repl( 'Í', 18 )
@ prow()    , 188 say repl( 'Í', 18 )
@ prow()    , 207 say repl( 'Í', 18 )
*********************************************/

fEjec0120()
@ prow() + 1,  70 say repl( 'Ä', 18 )
@ prow()    , 169 say repl( 'Ä', 18 )
@ prow()    , 188 say repl( 'Ä', 18 )
@ prow()    , 207 say repl( 'Ä', 18 )

fEjec0120()
@ prow() + 1,  74 say 'Grand-Total ¯'
@ prow()    ,  pcol()+6say grand_princ picture '999,999,999,999.99'
@ prow()    , 173 say grand_amort picture '999,999,999,999.99'
@ prow()    , 192 say grand_creda picture '999,999,999,999.99'
@ prow()    , 211 say grand_osbal picture '999,999,999,999.99'
fEjec0120()
@ prow() + 1,  74 say repl( 'Í', 18 )
@ prow()    , 173 say repl( 'Í', 18 )
@ prow()    , 192 say repl( 'Í', 18 )
@ prow()    , 211 say repl( 'Í', 18 )

__eject()           
set device to screen   
inkey( .5 )
restscreen( 7, 1, 20, 36, ax )
return( .t. )

////
static function fDisp0120( fc_code )
local row := 1, fc_name
memva total_princ, total_amort, total_creda, total_osbal
memva grand_princ, grand_amort, grand_creda, grand_osbal
memva sw, cnt, ind, inc

fc_name := eval( { || Facility->( dbseek( RIGHT(fc_code,5) ) ), Facility->fcltyname } )

   if Acctmast->status == '0'           // CANCELLED RLV 08/18/2010
        return nil
   endif

   if Acctmast->Osbal==0               // remove 0 balance (jbs 07.18.2002)
      return nil
   endif

   if Acctmast->status== '6'           // SOLD REC'BLES
      if !linclude_sold
          return nil
      endif
   endif

if ( total_princ + total_amort + total_creda + total_osbal ) > 0 .and. sw == -1
     fSubt0120()
     fEjec0120()
     @ prow() + 1, 0 say ''
endif   
if substr(Acctmast->fcltycode,1,3) == '103'
	gdamt := Acctmast->gd 
	rvamt := Acctmast->rv
else
	gdamt := 0
	rvamt := 0
endif
total_princ += Acctmast->principal
total_amort += Acctmast->amort
total_creda += Acctmast->credamt
total_osbal += Acctmast->osbal
grand_princ += Acctmast->principal
grand_amort += Acctmast->amort
grand_creda += Acctmast->credamt
grand_osbal += Acctmast->osbal

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

if sw == -1
   fEjec0120()
   @ prow() + 1, 1 say fc_code picture '@R 999-XXXXX' &&'@!'
   @ prow()    , 10 say '-'
   @ prow()    , 11 say fc_name picture '@!'

   set device to screen
   scroll( 8, 18, 9, 31, 1 )
   @ 9      ,   18 say padr( fc_name, 14 ) color 'w+/rb'
   set device to printer
   sw  := 1   
   row := 2
endif   
fEjec0120()
//
// @ prow() + row,   1 say Acctmast->acctno    picture '@R 9999-99999-99999'
//
**************88 @ prow() + row,   1 say substr(alltrim(Acctmast->oldno),-5,5)     picture '@!'

if empty(Acctmast->oldno)
   @ prow() + row,   1 say ACCTMAST->BRCODE+padr(Acctmast->acctno,16) picture '@R 999-9999-99999-99999' &&'@!'
else
   @ prow() + row,   1 say ACCTMAST->BRCODE+left(alltrim(Acctmast->oldno),16) picture '@R 999-9999-99999-99999' &&'@!'
endif

/****************************
@ prow()      ,  22 say padr(Acctmast->acctname,20) picture '@!'
@ prow()      ,  73 say Acctmast->unit      picture '@!'
@ prow()      , 114 say Acctmast->principal picture '999,999,999,999.99'
@ prow()      , 133 say Acctmast->gd        picture '99.99'
@ prow()      , 139 say Acctmast->rv        picture '99.99'
@ prow()      , 145 say Acctmast->term      picture '999'
@ prow()      , 148 say if( Acctmast->termunit == '1', ' days', ' months' )
@ prow()      , 156 say Acctmast->remterm   picture '999'
@ prow()      , 159 say if( Acctmast->termunit == '1', ' days', 'months' )
@ prow()      , 167 say Acctmast->truerate  picture '99.99'
@ prow()      , 173 say Acctmast->amort     picture '999,999,999,999.99'
@ prow()      , 192 say Acctmast->credamt   picture '999,999,999,999.99'
@ prow()      , 211 say Acctmast->osbal     picture '999,999,999,999.99'
@ prow()      , 230 say Acctmast->aocode    picture '@!'
@ prow()      , 236 say Acctmast->valdate   picture '@D'
*************************/

@ prow()      ,  22 say padr(Acctmast->acctname,20) picture '@!'
@ prow()      , pcol()+2 say Acctmast->unit      picture '@!'
@ prow()      , pcol()+2  say Acctmast->principal picture '999,999,999,999.99'
@ prow()      , pcol()+2  say gdamt        picture '99.99'
@ prow()      , pcol()+2  say rvamt        picture '99.99'
@ prow()      , pcol()+2  say Acctmast->term      picture '999'
@ prow()      , pcol()+2  say if( Acctmast->termunit == '1', 'days', 'mos.' )
@ prow()      , pcol()+2  say Acctmast->remterm   picture '999'
@ prow()      , pcol()+2  say if( Acctmast->termunit == '1', 'days', 'mos.' )
//aga.03.09.2007.insert getremterm function here
//_get_remterm(cacctno, dpaydate, dtermctr, cbrcode)

@ prow()      , pcol()+2  say Acctmast->truerate  picture '99.99'
@ prow()      , pcol()+2  say Acctmast->amort     picture '999,999,999,999.99'
@ prow()      , pcol()+2  say Acctmast->credamt   picture '999,999,999,999.99'
@ prow()      , pcol()+2  say Acctmast->osbal     picture '999,999,999,999.99'
//aga.03.09.2007.insert getosbal function here
//tgetosbal(xacctno, xcredamt, xdate, xbrcode)

@ prow()      , pcol()+2  say Acctmast->aocode    picture '@!'
@ prow()      , pcol()+2  say Acctmast->valdate   picture '@D'

set device to screen
@ 17,  3 say tran( grand_amort,         '999,999,999.99' ) color 'w+/rb'
scroll( 11, 18, 12, 31, 1 )
@ 12, 18 say padr( Acctmast->acctname, 14 )                color 'w+/rb' 
scroll( 14, 18, 15, 31, 1 )
@ 15, 18 say tran( Acctmast->principal, '999,999,999.99' ) color 'w+/rb' 
scroll( 17, 18, 18, 31, 1 )
@ 18, 18 say tran( Acctmast->amort,     '999,999,999.99' ) color 'w+/rb'
@  9 + ind, 33 say '°'                                     color 'w+/n'
       ind := int( max( ( ( inc += 1 ) / cnt ) * 7, 1 ) )
@  9 + ind, 33 say 'Û'                                     color 'w+/w'
set device to printer
return( nil )

////
static function fSubt0120()
memva total_princ, total_amort, total_creda, total_osbal

fEjec0120()        
@ prow() + 1, 114 say repl( 'Ä', 18 )
@ prow()    , 173 say repl( 'Ä', 18 )
@ prow()    , 192 say repl( 'Ä', 18 )
@ prow()    , 211 say repl( 'Ä', 18 )
fEjec0120()
@ prow() + 1,  97 say '  Sub-Total ¯'
@ prow()    , 114 say total_princ picture '999,999,999,999.99'
@ prow()    , 173 say total_amort picture '999,999,999,999.99'
@ prow()    , 192 say total_creda picture '999,999,999,999.99'
@ prow()    , 211 say total_osbal picture '999,999,999,999.99'
fEjec0120()
@ prow() + 1, 114 say repl( 'Ä', 18 )
@ prow()    , 173 say repl( 'Ä', 18 )
@ prow()    , 192 say repl( 'Ä', 18 )
@ prow()    , 211 say repl( 'Ä', 18 )
total_princ := total_amort := total_creda := total_osbal := 0
return( nil )

////
static function fHead0120()
memvar mpage, gSYS_NAME, gCOMPANY

setfont( upper( 'init' ) )
prnreptitle( 136, 5, mpage++, 'ACCOUNTS MASTERLIST', 'AMSQ0120', gSYS_NAME, gCOMPANY ) 
setfont( upper( 'normal' ) )
@ prow() + 1, ( 136 - 16 ) / 2 say 'As of ' + dtoc( Flag->lastclosed )
setfont( upper( 'condensed' ) )
@ prow() + 1, 0 say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿'
@ prow() + 1, 0 say '³                    ³                        ³                                        ³                  ³     ³     ³ Original ³Remaining ³ True ³     Monthly       ³      Credit      ³     Outstanding    ³ A O ³Execution³'
@ prow() + 1, 0 say '³     Account N§     ³      Account Name      ³               Collateral               ³     Proceeds     ³ G D ³ R V ³   Term   ³   Term   ³ Rate ³   Amortization    ³      Amount      ³       Balance      ³Code ³  Date   ³'
@ prow() + 1, 0 say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÙ'
return( nil )

////
static function fEjec0120()

if prow() >= 55
   __eject()
   fHead0120()
endif
return( .t. )   

////
static function fDate0120()
local getlist := {}, mcd := space( 5 ), cBRCODE := SPACE(3)
local mcl := setcolor(), log := !.f.
memva gnam, _x

setcolor( 'n/bg, w+/n,,, gr+/bg' )
fShadow( 12, 14, 15, 34, 2, 'n/w' )
@ 13, 15 say 'Branch Code ' + chr( 16 ) + ' '
@ 14, 15 say 'Facility N§ ' + chr( 16 ) + ' '

if _x != -1
   @ 14, 29 say padr( 'All', 5 ) color 'gr+/bg'      
else
   @ 13, 29 GGET cBRCODE PICTURE '999' VALID IF(!EMPTY(cBRCODE) .AND. VALBRCODE(cBRCODE,g_USER_ID), .T., EVAL({|| cBRCODE:= SPACE(3) ,.F. }))
   @ 14, 29 gget mcd picture '@!';               && when pseek( @mcd ) valid fPad0120( @mcd )
               VALID IF( !EMPTY(MCD) .AND. LASTKEY() == K_ENTER,;
                         IF( fPADXXXX( @mcd, 5 ), .T., EVAL({ || MCD := SPACE(5), .F. }) ),;
                         EVAL({ || PSEEK( @MCD ), IF( LASTKEY() == K_ENTER, .T., .F.) });
                       )
endif
   
setcursor( 3 )
setkey( K_ESC, { || fEscape( 'Abort?' ) } )
read &&timeout 20 exitevent blankscr3( -1 )
setkey( K_ESC, nil )
setcursor( 0 )

if lastkey() != K_ESC
   log  := !.t.
   gnam := { || cBRCODE + mcd }  && RED 11162004 ADDED cBRCODE
endif
inkey( .5 )
setcolor( mcl )
return( log )

////
static function pseek( mcd )
*return( eval( { || lb_lkup( 'Facility', 1, 2, @mcd, 3, 1, 10, 36, 20, 75, 'W/GR+,W/N,,,W/GR+' ), .t. } ) )
RETURN( EVAL( { || __LB_LKUP( 'FACILITY', 1, 2, @MCD, 3, 1,  ,10,36,20,75,'W/GR+,W/N,,,W/GR+' ), .T. } ) )

////
/*
static function fPad0120( mcd )
local log := !.f.

if !dbseek( mcd := padr( mcd, 5 ) )
   log := !.t.
   error( 'No such Record!' )
endif
return( log )
*/
////
static function fDraw0120()

setcolor( 'n/gr, +w/gr' )
*****fShadow( 9, 33, 14, 42, 2, 'n/w' )
fShadow( 9, 33, 12, 42, 2, 'n/w' )
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
@ 11, 34 say 'Facility N§'           color 'w+/w'
 
@ 12, 32 say '³'                     color 'n/w' 
@ 12, 34 say 'to be printed in the'  color 'n+/w'
 
@ 13, 32 say '³'                     color 'n/w' 
@ 13, 34 say 'Accounts Masterlist'   color 'w+/w'
@ 13, 53 say '.'                     color 'n+/w'  
@ 14, 32 say 'Á'                     color 'n/w'
*/
return( .f. )

////
static function fOutp0120()                             

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
@  9,  4 say 'Facility Name' color 'gr+/w'
@ 12,  4 say ' Account Name' color 'gr+/w'
@ 15,  4 say '    Principal' color 'gr+/w'
@ 18,  4 say ' Amortization' color 'gr+/w'
dispend()
return( nil )

////
static function fOpen0120()

if !netuse( '&g_AMS_PATH\Flag', .f., 10 )               && flag
   break 
endif

if !netuse( '&g_AMS_PATH\Facility', .f., 10 )           && facility
   break 
else 
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_AMS_PATH\Fcltycd' )                  && set index on facility code
endif  

if !netuse( '&g_AMS_PATH\Acctmast', .f., 10 )           && account master
   break 
else 
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_AMS_PATH\Acctfa' )                   && set index on facility code + acctno
endif                                       
return( nil )
