/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³   PROGRAM ID.........:  amsq0100.prg                                 ³
 ³   Description........:  accounts masterlist by account officer       ³
 ³   Author.............:  Gener C. Singson                             ³
 ³   Date...............:  02:56pm 06-Mar-1995                          ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³                         U P D A T E S                                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³        Who        ³     When      ³               Why                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³ janet l. bautista ³  15-Apr-1996  ³ to follow standard coding        ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

#include 'INKEY.CH'
#include 'COLF.CH'

#define NIRVANA tone( 480, 0.25 ); tone( 240, 0.25 )

private gSYS_NAME := 'Accounts Management System'
private gCOMPANY  := 'Consolidated ORIX Leasing and Finance Corporation'

************8if CHKPASS( procname(), AX_LEVEL, gUSER_ID )
   begin sequence
         nosnow( .t. )
         fOPEN0100()
         fMAIN0100()
         nosnow( .f. )
   end sequence
   dbcloseall()
*****************endif
__mrelease( '*', !.f. )
return

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function fMAIN0100()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local sv
   priva _x := -1

   savescreen( ,,, sv )
   if !fDraw0100()
      while !eval( { || fMall0100(), if( _x # -3, !.t., !.f. ) } )
      enddo
   endif   
   restscreen( ,,,, sv )
   return( nil )

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function fMall0100()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local menulist 
   memva _x
   priva total_princ := total_amort := total_creda := total_osbal := 0
   priva grand_princ := grand_amort := grand_creda := grand_osbal := 0
   priva con, gnam, mpage := 1

   _x := abs( _x )

   @ 10, 35 prompt ' ~One ' message '';
            messagecolor 'w+/n' triggercolor 'w+/gr'

   @ 12, 35 prompt ' ~All ' message '';
            messagecolor 'w+/n' triggercolor 'w+/gr'

   menu to _x initial _x timeout 20               

   do case
      case _x == 0 
         _x  := -3
      case _x == 1
         _x  := -1
         con := { || eval( gnam ) == Acctmast->aocode }
         fDone0100()        
      case _x == 2   
         _x  := -2
         if lastrec() > 0
            dbgotop()
            con := { || !eof() }
            fDone0100()
         else
            error( 'No Available Record!' )        
         endif     
   endcase        
   return( _x )

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function fDone0100()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local msv
   priva sw, cnt := inc := 0, ind := 1

   msv := savescreen( ,,, )
   if !fDate0100()
      *repcontrol( 'fPrnt0100()', '132 COLUMN' )
      repcon_ol( 'fPrnt0100()', '132 COLUMN',,,,,,.F. )
      inkey( .5 )   
   endif
   restscreen( ,,,, msv )
   return( nil )

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   function fPrnt0100()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local ao_code := 'piañ', ax
   memva grand_princ, grand_amort, grand_creda, grand_osbal
   memva con, sw, _x, cnt 

   if _x == -1
      dbeval( { || cnt += 1 },,;
              { || eval( con ) } )
      dbseek( eval( gnam ) )        
   else
      cnt := Acctmast->( lastrec() )  
   endif
   set device to screen
   ax := savescreen( 7, 1, 20, 36 )

   fOutp0100 ()
   set device to printer   
   fHead0100 ()

   dbeval( { | n |   ;
                            n := if( ao_code != padr( Acctmast->aocode, 5 ),;
                            eval( { || sw := -1,;
                                       padr( Acctmast->aocode,5 ) ;
                                  };
                                ),;
                            ao_code ;
                          ),;
                          fDisp0100( ao_code := n , Acctmast->fcltycode ) ;
           },,;
           { || eval( con ) } )

   if _x == -2       
      fSubt0100 ()
   endif

   fEjec0100()        
   @ prow() + 1, 125 say repl( 'Ä', 18 )
   @ prow()    , 173 say repl( 'Ä', 18 )
   @ prow()    , 192 say repl( 'Ä', 18 )
   @ prow()    , 211 say repl( 'Ä', 18 )
   fEjec0100()
   @ prow() + 1, 108 say 'Grand-Total ¯'
   @ prow()    , 125 say grand_princ picture '999,999,999,999.99'
   @ prow()    , 173 say grand_amort picture '999,999,999,999.99'
   @ prow()    , 192 say grand_creda picture '999,999,999,999.99'
   @ prow()    , 211 say grand_osbal picture '999,999,999,999.99'
   fEjec0100()
   @ prow() + 1, 125 say repl( 'Í', 18 )
   @ prow()    , 173 say repl( 'Í', 18 )
   @ prow()    , 192 say repl( 'Í', 18 )
   @ prow()    , 211 say repl( 'Í', 18 )
   __eject()           
   set device to screen   
   inkey( .5 )
   restscreen( 7, 1, 20, 36, ax )
   return( .t. )

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function fDisp0100( ao_code, fc_code )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local row := 1, ao_name, fc_name
   memva total_princ, total_amort, total_creda, total_osbal
   memva grand_princ, grand_amort, grand_creda, grand_osbal
   memva sw, cnt, ind, inc

if Acctmast->osbal != 0

if ( total_princ + total_amort + total_creda + total_osbal ) > 0 .and. sw == -1
     fSubt0100()
     fEjec0100()
     @ prow() + 1, 207 say ''
endif   

total_princ += Acctmast->principal
total_amort += Acctmast->amort
total_creda += Acctmast->credamt
total_osbal += Acctmast->osbal
grand_princ += Acctmast->principal
grand_amort += Acctmast->amort
grand_creda += Acctmast->credamt
grand_osbal += Acctmast->osbal

ao_name := eval( { || Ao->( dbseek( ao_code ) ),;
                 padr( Ao->aoname, 40 ) } )
fc_name := eval( { || Facility->( dbseek( fc_code ) ),;
                 padr( Facility->fcltyalias, 5 ) } )

if sw == -1
   fEjec0100()
   @ prow() + 1,  3 say ao_code picture '99999'
   @ prow()    ,  9 say '-'
   @ prow()    , 11 say ao_name picture '@!'
   set device to screen
   scroll( 8, 18, 9, 31, 1 )
   @ 9, 18 say padr( ao_name, 14 ) color 'w+/rb'
   set device to printer
   sw  := 1   
   row := 2
endif   
fEjec0100()
@ prow() + row,   3 say Acctmast->acctno    picture '@R 9999-99999-99999'
@ prow()      ,  20 say padr( getclient(), 50 ) picture '@!'
@ prow()      ,  71 say fc_code             picture '@R 999-99'
@ prow()      ,  78 say fc_name             picture '@!'
@ prow()      ,  84 say Acctmast->unit      picture '@!'
@ prow()      , 125 say Acctmast->principal picture '999,999,999,999.99'
@ prow()      , 144 say Acctmast->gd        picture '99.99'
@ prow()      , 150 say Acctmast->rv        picture '99.99'
@ prow()      , 156 say Acctmast->term      picture '999'
@ prow()      , 159 say ' months'
@ prow()      , 167 say Acctmast->truerate  picture '99.99'
@ prow()      , 173 say Acctmast->amort     picture '999,999,999,999.99'
@ prow()      , 192 say Acctmast->credamt   picture '999,999,999,999.99'
@ prow()      , 211 say Acctmast->osbal     picture '999,999,999,999.99'
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
endif
return( nil )

////
static function fSubt0100()
memva total_princ, total_amort, total_creda, total_osbal

fEjec0100()        
@ prow() + 1, 125 say repl( 'Ä', 18 )
@ prow()    , 173 say repl( 'Ä', 18 )
@ prow()    , 192 say repl( 'Ä', 18 )
@ prow()    , 211 say repl( 'Ä', 18 )
fEjec0100()
@ prow() + 1, 108 say '  Sub-Total ¯'
@ prow()    , 125 say total_princ picture '999,999,999,999.99'
@ prow()    , 173 say total_amort picture '999,999,999,999.99'
@ prow()    , 192 say total_creda picture '999,999,999,999.99'
@ prow()    , 211 say total_osbal picture '999,999,999,999.99'
fEjec0100()
@ prow() + 1, 125 say repl( 'Ä', 18 )
@ prow()    , 173 say repl( 'Ä', 18 )
@ prow()    , 192 say repl( 'Ä', 18 )
@ prow()    , 211 say repl( 'Ä', 18 )   
total_princ := total_amort := total_creda := total_osbal := 0
return( nil )

////
static function fHead0100()
memvar mpage, gSYS_NAME, gCOMPANY

setfont( upper( 'init' ) )
prnreptitle( 136, 5, mpage++, 'ACCOUNTS MASTERLIST', 'AMSQ0100', gSYS_NAME, gCOMPANY ) 
setfont( upper( 'normal' ) )
@ prow() + 1, ( 136 - 16 ) / 2 say 'As of ' + dtoc( Flag->prevdate ) 
setfont( upper( 'condensed' ) )
@ prow() + 1, 2 say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
@ prow() + 1, 2 say '³                ³                                                  ³            ³                                        ³                  ³     ³     ³ Original ³True ³     Monthly      ³      Credit      ³   Outstanding    ³'
@ prow() + 1, 2 say '³   Account N§   ³                   Account Name                   ³  Facility  ³               Collateral               ³     Proceeds     ³ G D ³ R V ³   Term   ³ Rate³   Amortization   ³      Amount      ³     Balance      ³'
@ prow() + 1, 2 say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
return( nil )

////
static function fEjec0100()

if prow() >= 55
   __eject()
   fHead0100()
endif
return( .t. )   

////
static function fDate0100()
local  getlist := {}, mcd := space( 5 )
local  mcl := setcolor(), log := !.f.
memvar gnam, _x

setcolor( 'n/bg, w+/n,,, gr+/bg' )
fShadow( 13, 20, 15, 36, 2, 'n/w' )
@ 14, 21 say 'AO Code ' + chr( 16 ) + ' '
if _x != -1
   @ 14, 31 say 'All  ' color 'gr+/bg'      
else
************   @ 14, 31 gget mcd picture '@!' when pseek( @mcd ) valid fPad0100( @mcd )
endif   
setcursor( 3 )
setkey( K_ESC, { || fEscape( 'Abort?' ) } )
read timeout 20 exitevent blankscr3( -1 )
setkey( K_ESC, nil )
setcursor( 0 )
if lastkey() != K_ESC
   log  := !.t.
   gnam := { || mcd }  
endif
inkey( .5 )
setcolor( mcl )
return( log )

/***********************************
////
static function pseek( mcd )
return( eval( { || lb_lkup( 'Ao', 1, 2, @mcd, 2, 1, 10, 36, 20, 75, 'W/GR+,W/N,,,W/GR+' ), .t. } ) )
*************************/
/*
////
static function fPad0100( mcd )
local log := !.f.

if !dbseek( mcd := padr( mcd, 5 ) )
   log := !.t.
   error( 'No such Record!' )
endif
return( log )
*/
////
static function fDraw0100()

setcolor('n/gr,w+/gr','w+/gr,n/gr')

/*****************
  DEHIGHLIGHT THIS WHEN ALL IS INCLUDED
fShadow( 9, 33, 14, 42, 2, 'n/w' )
@ 10, 40 say 'ß'                    color 'w/n'
@ 11, 36 say 'ÜÜÜÜÜ'                color 'w/n'
@ 12, 40 say 'ß'                    color 'w/n'
@ 13, 36 say 'ÜÜÜÜÜ'                color 'w/n'
******************/

fShadow( 9, 33, 12, 42, 2, 'n/w' )
@ 10, 40 say 'ß'                    color 'w/n'
@ 11, 36 say 'ÜÜÜÜÜ'                color 'w/n'

*****@ 12, 40 say 'ß'                    color 'w/n'
******@ 13, 36 say 'ÜÜÜÜÜ'                color 'w/n'

/*
@  9, 32 say 'Â'                    color 'n/w'
@ 10, 32 say '³'                    color 'n/w'
@ 10, 34 say 'Select and write the' color 'n+/w'
 
@ 11, 32 say '³'                    color 'n/w' 
@ 11, 34 say '        you want to'  color 'n+/w'
@ 11, 34 say 'Ao-Code'              color 'w+/w'
 
@ 12, 32 say '³'                    color 'n/w' 
@ 12, 34 say 'be printed in the'    color 'n+/w'
 
@ 13, 32 say '³'                    color 'n/w' 
@ 13, 34 say 'Accounts Masterlist'  color 'w+/w'
@ 13, 53 say '.'                    color 'n+/w'  
@ 14, 32 say 'Á'                    color 'n/w'
*/
return( .f. )

////
static function fOutp0100()                             

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
@  9,  2 say 'Account Officer' color 'gr+/w'
@ 12,  2 say '   Account Name' color 'gr+/w'
@ 15,  2 say '      Principal' color 'gr+/w'
@ 18,  2 say '   Amortization' color 'gr+/w'
dispend()
return( nil )
/*
****************************************************
static function getclient ()
****************************************************
   Client -> ( dbseek ( Acctmast -> CLNTCODE ) )
return Client -> SHRTNAME
*/
////
static function fOPEN0100()

if !netuse( 'Flag', .f., 10 )               && flag
   break 
endif

g_cis_path := '\colfsys\cis\run\'

if !netuse( '&g_CIS_PATH\Ao', .f., 10 )     && account officer
   break 
else 
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_CIS_PATH\Ao' )           && set index on ao code
endif

if !netuse( 'Facility', .f., 10 )           && facility
   break 
else 
   if !.f.; ordlistclear(); endif
   ordlistadd( 'Fcltycd' )                  && set index on facility code
endif  

if !NETUSE( '&g_CIS_PATH'+'\Client.dbf',.f.,5)
   break
else
   set index to &g_CIS_PATH\Cliecd, &g_CIS_PATH\Clienm
endif

if !netuse( 'Acctmast', .f., 10 )           && account master
   break 
else 
   if !.f.; ordlistclear(); endif
   ordlistadd( 'Acctaonm' )                 && set index aocode + acctname
endif                                       
return( nil )
//
//
//    per_ao.prg
//
//
