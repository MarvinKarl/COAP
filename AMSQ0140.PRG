/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   colf-iis -- account management system                                      ³
³                                                                              ³
³   program idúúú amsq0140.prg                                                 ³
³   descriptionúú accounts masterlist by client group                          ³
³   authorúúúúúúú gener c. singson                                             ³
³   dateúúúúúúúúú 2:28:9ú73pm úú 6-19-95                                       ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                         u p d a t e s                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³       who         ³       when        ³               why                    ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ esv               ³ 06/27/2012        ³CPS/ GRUPCODE                         ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

////
#include 'inkey.ch'
#include 'colf.ch'

////
#define   nirvana tone( 480, 0.25 ); tone( 240, 0.25 )
local water
private mcd := space( 6 ) && RED11172004 REPLACED 3 WITH 6
////


if !chkpass( procname(), AX_LEVEL, gUSER_ID )
   // until then my luv    
else
   nosnow( .t. )
   begin sequence
         fOpen0140()
         fMain0140()
   recover using water      
         if water
            dbcloseall()
            __mrelease( '*', water )            
         endif   
   end
   nosnow( .f. )
endif   
return

////
static function fMain0140()
local sv, water
priva _x := -1

savescreen( ,,, sv )
if !fDraw0140()
   while water := !eval( { || fMall0140(), if( _x # -3, !.t., !.f. ) } )
   enddo
endif   
restscreen( ,,,, sv )
if water := !water
   break water
endif   
return( nil )

////
static function fMall0140()
local menulist 
memva _x
priva total_princ := total_amort := total_creda := total_osbal := 0
priva grand_princ := grand_amort := grand_creda := grand_osbal := 0
priva con, gnam, mpage := 1
private linclude_sold

_x := abs( _x )

@ 10, 35 prompt ' ~One ' message '';
         messagecolor 'w+/n' triggercolor '+w/gr'
***** @ 12, 35 prompt ' ~All ' message '';
*****          messagecolor 'w+/n' triggercolor '+w/gr'
menu to _x initial _x &&timeout 20
      
do case
   case _x == 0 
        _x  := -3
   case _x == 1
        _x  := -1
        con := { || eval( gnam ) == Grpcodes->grupcode }
        linclude_sold := .f.
        if confirm( 'Include Sold Receivables?',.t. )
           linclude_sold := .t.
        endif

        if lastkey() != K_ESC
           fDone0140()
        endif
   case _x == 2   
        _x  := -2
        if lastrec() > 0
           dbgotop()
           con := { || !Grpcodes->( eof() ) }
           fDone0140()
        else
           error( 'No Available Record!' )        
        endif     
endcase        
return( _x )

******************************
*
static function fDone0140()
******************************
local msv
priva sw, cnt := inc := 0, ind := 1, on, off := 0,recnt:=0

msv := savescreen( ,,, )
if !fDate0140()
   *reportprint( 'fPrnt0140()', '132 COLUMN' )
   xSTR := CHK_PAR(mcd)+CHK_PAR(gSYS_NAME)+CHK_PAR(gCOMPANY)+CHK_PAR(g_user_id)
   repcon_ol( 'fPrnt0140()',,,,,,xSTR,.t. ) // esv
   inkey( .5 )   
endif
restscreen( ,,,, msv )
return( nil )

**************************
*
function fPrnt0140()
**************************
local ac_name := 'piañ', ax
memva grand_princ, grand_amort, grand_creda, grand_osbal
memva con, sw, _x, cnt, off

if _x == -1
*****   dbeval( { || cnt += 1 },, { || eval( con ) } )
*****   dbseek( eval( gnam ) )
else
   cnt := Grpcodes->( lastrec() )  
endi   
set device to screen
ax := savescreen( 7, 1, 20, 36 )
fOutp0140()                             
set device to printer   
fHead0140()

/**************
Grpcodes->( dbeval( { | n | fJust0140(),;
                            if( !Grpmembr->( dbseek( Grpcodes->grupcode ) ),;
                                 n,          ;
                                 Grpmembr->( dbeval( { || sw := -1, ;
                                                          fDoit0140 ( Grpmembr->clntcode ),;
                                                          eval( {|| chksubt() } ) ;
                                                     },,;
                                                     { || Grpmembr->grupcode == Grpcodes->grupcode };
                                                   );
                                           );
                              ),;
                            if( ( total_princ <> 0 .or. ;
                                  total_amort <> 0 .or. ;
                                  total_creda <> 0 .or. ;
                                  total_osbal <> 0      ;
                                ),;
                                fSubt0140( total_princ, total_amort, total_creda, total_osbal, '+' ),;
                                nil ;
                              ) ;
                    },,                                                                               ;
                    { || eval( con ) } ) )
*****************/

if Grpmembr->( dbseek( alltrim(mcd)) )
   do while !Grpmembr->(eof()) .and. GRPMEMBR->BRCODE+alltrim(Grpmembr->grupcode) == alltrim(mcd)
      fDoit0140 ( GRPMEMBR->BRCODE2+Grpmembr->clntcode )
      Grpmembr->(dbskip(+1))
   enddo
endif

fSubt0140( grand_princ, grand_amort, grand_creda, grand_osbal, '-' )
__eject()           
set device to screen   
inkey( .5 )
restscreen( 7, 1, 20, 36, ax )
return( .t. )

////
*************************************
*
static function fDoit0140( ac_name )
*************************************
recnt := 0
return( if( Acctmast->( dbseek( ac_name ) ),;
            Acctmast->( dbeval( { || if ( Acctmast->status== '6',; // SOLD REC'BLES
                                          if ( linclude_sold ,;
                                               eval({|| recnt++,;
                                                      fDisp0140( ac_name ) ;
                                                   }),;
                                               nil;
                                             ),;
                                          eval({|| recnt++,;
                                                   fDisp0140( ac_name ) ;
                                               }) ;
                                        );
                                },,;
                                { || ac_name == ACCTMAST->BRCODE+Acctmast->clntcode } ) ),{|| off:= -1} ) )

////
****************************************
*
static function fDisp0140( ac_name )
****************************************
local row := 1, gdamt, rvamt
memva total_princ, total_amort, total_creda, total_osbal
memva grand_princ, grand_amort, grand_creda, grand_osbal
memva sw, on, off

   if Acctmast->status == '0'           // CANCELLED RLV 08/18/2010
        return nil
   endif



if ( total_princ + total_amort + total_creda + total_osbal ) > 0 .and. sw == -1
     if off == 1
        fSubt0140( total_princ, total_amort, total_creda, total_osbal, '+' )
     endif   
endif   

total_princ += Acctmast->principal
total_amort += Acctmast->amort
total_creda += Acctmast->credamt
total_osbal += Acctmast->osbal

grand_princ += Acctmast->principal
grand_amort += Acctmast->amort
grand_creda += Acctmast->credamt
grand_osbal += Acctmast->osbal

*****if sw == -1
*****   sw := on := 1
*****else
*****   on := -1
*****endif
sw := 1
on := 1

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

fEjec0140()
@ prow() + row,   9 say  ACCTMAST->BRCODE+Acctmast->acctno         picture '@R 999-9999-99999-99999'
@ prow()      ,  30 say                              ;
         padr( if( on == 1,                         ;
         eval( { || on := -1, off := -1, Acctmast->acctname } ),;
         eval( { || off := 1, ' ' } ) ), 40 )          picture '@!'
@ prow()      ,  71 say       Acctmast->unit           picture '@!'
@ prow()      , 112 say       Acctmast->principal      picture '999,999,999,999.99'
@ prow()      , 131 say       gdamt             picture '99.99'
@ prow()      , 137 say       rvamt             picture '99.99'
@ prow()      , 143 say       Acctmast->term           picture '999'
@ prow()      , 146 say ' months'
// @ prow()      , 154 say       Acctmast->remterm        picture '999'     erlachica - 11/05/09
//aga.03.09.2007.insert getremterm function here
//_get_remterm(cacctno, dpaydate, dtermctr, cbrcode)

// @ prow()      , 157 say ' months'     erlachica - 11/05/09
@ prow()      , 154 say       Acctmast->truerate       picture '99.99'
@ prow()      , 160 say       Acctmast->amort          picture '999,999,999,999.99'
@ prow()      , 179 say       Acctmast->credamt        picture '999,999,999,999.99'
@ prow()      , 198 say       Acctmast->osbal          picture '999,999,999,999.99'
@ prow()      , 217 say       Acctmast->matdate
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
set device to printer
return( nil )
////
Static function Chksubt()
if recnt <  2
   total_princ := 0
   total_amort := 0
   total_creda := 0
   total_osbal := 0
endif
return .t.
////
static function fJust0140()
memva ind, inc, cnt

set device to screen
scroll( 8, 18, 9, 31, 1 )
@ 9      , 18 say padr( Grpcodes->grupname, 14 )           color 'w+/rb'
@ 9 + ind, 33 say '°'                                      color 'w+/n'
      ind := int( max( ( ( inc += 1 ) / max( cnt, 1 ) ) * 7, 1 ) )
@ 9 + ind, 33 say 'Û'                                      color 'w+/w'
set device to printer
fEjec0140()
@ prow() + 1,  9 say Grpcodes->grupcode + ' - ' picture '@!'
@ prow()    , 15 say Grpcodes->grupname         picture '@!'
fEjec0140()
@ prow() + 1,  9 say ''
return( nil )   

////
static function fSubt0140( xprinc, xamort, xcreda, xosbal, mwhat )
memva total_princ, total_amort, total_creda, total_osbal
memva grand_princ, grand_amort, grand_creda, grand_osbal

fEjec0140()        
@ prow() + 1, 112 say repl( 'Ä', 18 )
@ prow()    , 160 say repl( 'Ä', 18 )
@ prow()    , 179 say repl( 'Ä', 18 )
@ prow()    , 198 say repl( 'Ä', 18 )
fEjec0140()
do case
   case mwhat == '+' 
        @ prow() + 1, 95 say '  Sub-Total ¯'
   case mwhat == '-'      
        @ prow() + 1, 95 say 'Grand-Total ¯'
endcase        
@ prow()    , 112 say xprinc picture '999,999,999,999.99'
@ prow()    , 160 say xamort picture '999,999,999,999.99'
@ prow()    , 179 say xcreda picture '999,999,999,999.99'
@ prow()    , 198 say xosbal picture '999,999,999,999.99'
//fEjec0140()
@ prow() + 1, 112 say repl( if( mwhat == '+', 'Ä', 'Í' ), 18 )
@ prow()    , 160 say repl( if( mwhat == '+', 'Ä', 'Í' ), 18 )
@ prow()    , 179 say repl( if( mwhat == '+', 'Ä', 'Í' ), 18 )
@ prow()    , 198 say repl( if( mwhat == '+', 'Ä', 'Í' ), 18 )
do case
   case mwhat == '+' 
        total_princ := total_amort := total_creda := total_osbal := 0
   case mwhat == '-'     
        total_princ := total_amort := total_creda := total_osbal := ;
        grand_princ := grand_amort := grand_creda := grand_osbal := 0
endcase   
fEjec0140()
@ prow() + 1,  9 say ''
return( nil )

////
static function fHead0140()
local ax := 'As of ' + cmonth( Flag->lastclosed ) + ' ' +;
            subs( dtos( Flag->lastclosed ), -2, 2 ) + ', ' +;
            subs( dtos( Flag->lastclosed ),  1, 4 )
local zz := grpcodes->(indexord())
memvar mpage, gSYS_NAME, gCOMPANY          

grpcodes->(dbsetorder(1))
grpcodes->(dbseek(mcd))

setfont( upper( 'init' ) )
prnreptitle( 136, 5, mpage++, 'ACCOUNTS MASTERLIST', 'AMSQ0140', gSYS_NAME, gCOMPANY ) 
setfont( upper( 'normal' ) )
Client->(dbseek(Grpcodes->brcode+Grpcodes->clntcode))
@ prow() + 1, ( 136 - len( 'FOR '+upper(alltrim(Client->fullname))+ ' ( ' + transf(mcd,'@R 999-999') + ' ) ' ) ) / 2 say 'FOR '+upper(alltrim(Client->fullname)) + ' ( ' + transf(mcd,'@R 999-999') + ' ) '
@ prow() + 1, ( 136 - len( ax ) ) / 2 say ax

//pagecenter( prow ()+2,136, 'FOR ' + upper(alltrim(Client->fullname)) + transf(mcd,'@R 999-999'))
//@ prow() + 1, ( 136 - len( ax ) ) / 2 say ax
setfont( upper( 'condensed' ) )
@ prow() + 1, 8 say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿'
@ prow() + 1, 8 say '³                    ³                                        ³                                        ³                  ³     ³     ³ Original ³True ³     Monthly      ³      Credit      ³   Outstanding    ³ Maturity ³'
@ prow() + 1, 8 say '³     Account N§     ³              Account Name              ³               Collateral               ³     Proceeds     ³ G D ³ R V ³   Term   ³ Rate³   Amortization   ³      Amount      ³     Balance      ³   Date   ³'
@ prow() + 1, 8 say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ'

grpcodes->(dbsetorder(zz))
return( nil )

////
static function fEjec0140()

if prow() >= 55
   __eject()
   fHead0140()
endif
return( .t. )   

////
static function fDate0140()
local getlist := {}
local mcl := setcolor(), log := !.f., cbrcode:=g_PAR_BRCH
memva gnam, _x 

setcolor( 'n/bg, w+/n,,, gr+/bg' )
fShadow( 13, 15, 15, 36, 2, 'n/w' )


@ 14, 16 say 'Group Code ' + chr( 16 ) + ' '
if _x != -1
   @ 14, 29 say padr( 'All', 3 ) color 'gr+/bg'      
else
   @ 14, 29 gget mcd picture '@R 999-999';          &&'@!S20' when pseek( @mcd ) valid fPadxxxx( @mcd, 6 )        &&fPad0140( @mcd )
                 VALID IF( !EMPTY(MCD) .AND. LASTKEY() == K_ENTER,;
                           IF( VALBRCODE(LEFT(MCD,3),g_USER_ID), IF( fPADXXXX( @MCD, 6 ), .T., EVAL({|| MCD:=SPACE(6) ,.F. }) ), EVAL({|| MCD:=SPACE(6) ,.F. }) ) ,;    &&AD040(@MCD)
                           EVAL({|| ach_look(@MCD) ,IF( LASTKEY() == K_ENTER, EVAL({|| VALBRCODE(LEFT(MCD,3),g_USER_ID) }), EVAL({|| MCD:=SPACE(6) ,.F. }) ) }) ;
                         )
endif
   
setcursor( 3 )
setkey( K_ESC, { || fEscape( 'Abort?' ) } )
read &&timeout 20 exitevent blankscr3( -1 )
setkey( K_ESC, nil )
setcursor( 0 )

//alert ( 'asdf' + mcd )

if lastkey() != K_ESC
   log  := !.t.
   gnam := { || mcd }  
endif
inkey( .5 )
setcolor( mcl )
return( log )

////
**********************************************
static function ach_look(MCD)
**********************************************
local mod_t:='group', ckey:=space(6)
local headr:='           Group Name         Brcode  Group Code          '
GRPCODES->(dbgotop())
GRPCODES->(dbsetorder(3))
   main_achoice('GRPCODES',3,1,,8,7,21,67,headr,mod_t)
  
  if mpos > 0 .and. lastkey() == K_ENTER .and. !empty(mchoices)
  
		cKEY := substr( ltrim(mchoices[mpos]),24,3)+substr( ltrim(mchoices[mpos]),34,3)
			mcd:=CKEY 
	ENDIF 

return MCD

static function pseek( mcd )
LOCAL nINDX := GRPCODES->(INDEXORD())

*return( eval( { || __lb_lkup( 'Grpcodes', 1, 2, @mcd, 2, 1,  ,10,36,20,75,'W/GR+,W/N,,,W/GR+' ), .t. } ) )

GRPCODES->(DBSETORDER(3))
MCD := EVAL({ || fLook_ONLINE(.t.,'Grpcodes',mcd,'Group codes',2, 3, 1, , 1, .f.,,,,g_AMS_PATH, .t.) })
GRPCODES->(DBSETORDER(nINDX))

RETURN MCD
/*
////
static function fPad0140( mcd )
local log := !.f.

if !dbseek( mcd := padr( mcd, 6 ) )              && RED 071105 REPLACE 3 WITH 6
   log := !.t.
   error( 'No such Record!' )
endif
return( log )
*/
////
static function fDraw0140()

setcolor( 'n/gr, +w/gr' )
***** fShadow( 9, 33, 14, 42, 2, 'n/w' )
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
@ 11, 34 say '           you want '  color 'n+/w'
@ 11, 34 say 'Group Code'            color 'w+/w'
 
@ 12, 32 say '³'                     color 'n/w' 
@ 12, 34 say 'to be printed in the'  color 'n+/w'
 
@ 13, 32 say '³'                     color 'n/w' 
@ 13, 34 say 'Accounts Masterlist'   color 'w+/w'
@ 13, 53 say '.'                     color 'n+/w'  
@ 14, 32 say 'Á'                     color 'n/w'
*/

return( .f. )

////
static function fOutp0140()                             

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
@  9,  4 say '   Group Name' color 'gr+/w'
@ 12,  4 say '   Collateral' color 'gr+/w'
@ 15,  4 say '    Principal' color 'gr+/w'
@ 18,  4 say ' Amortization' color 'gr+/w'
dispend()
return( nil )

////
static function fOpen0140()
local water := !.f.

if !netuse( '&g_AMS_PATH\Flag', .f., 10 )               && flag
   break water
endif

if !netuse( '&g_AMS_PATH\Acctmast', .f., 10 )           && account master
   break water
else 
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_AMS_PATH\Acctclnt' )                 && set index clntcode + acctno
endif                                       

if !netuse( '&g_AMS_PATH\Grpmembr', .f., 10 )           && group member
   break water
else 
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_AMS_PATH\Grpmembr' )                 && set index grupcode
endif                                       

if !netuse( '&g_AMS_PATH\Grpcodes', .f., 10 )           && group code
   break water
else 
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_AMS_PATH\Grpcodes' )                 && set index brcode + grupcode
   ordlistadd( '&g_AMS_PATH\Grpnames' )                 && set index grupname + brcode
   ordlistadd( '&g_AMS_PATH\GrpBRNM' )                  && set index BRCODE + grupname
endif                    

if !netuse( '&g_CIS_PATH\Client', .f., 10 )           && Client master
   break water
else 
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_CIS_PATH\Cliecd' )                 && set index brcode + clntcode
endif
                   
return( nil )

/*
******************************************************
function tgetosbal(xacctno, xcredamt, xdate, xbrcode)   //aga.05.07.2007.as of date osbal
******************************************************
mDBF       := {}
ahistbal   := 0
mcredamt   := xcredamt
mbalance   := 0
mDBF       := savedbf(mDBF)

dbselectarea('Amshist')
dbsetorder(1)

ahistbal := 0  

Amshist->(dbseek(xbrcode+xacctno))

if !found() //seek fails
   restdbf (mDBF)
   return mbalance
end if

do while !Amshist->(eof()) .and. Amshist->brcode == xbrcode .and. Amshist->acctno == xacctno

   if Amshist->refdate <= xdate
      ahistbal := ahistbal + Amshist->amort 
   end if

   Amshist->(dbskip(+1)) 
enddo

mbalance := mcredamt - ahistbal  

restdbf (mDBF)

return mbalance


********************************************************
function _get_remterm(cacctno,dpaydate,dtermctr,cbrcode)
********************************************************
local cretval  := space (5)
local nremterm := 0

Paysked->(dbseek(cacctno+'D'))

if Paysked->paynum != 0 .and. PAYSKED->BRCODE+Paysked->acctno == cacctno .and. paysked->status == 'D' 
   nremterm := Paysked->paynum + dtermctr 
else
   Payimage->(dbseek(cacctno+dtos(dpaydate),.t.))

   if Payimage->brcode+Payimage->acctno == cacctno
      nremterm := Payimage->paynum
   endif

endif

cretval := padl(alltrim(str(nremterm)),3)

//Acctmast->term <= 72  //get on acctmast if less then 72, else count image

return cretval

*/