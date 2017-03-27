/*
⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
≥   PROGRAM ID.........:  amsq0100.prg                                         ≥
≥   Description........:  accounts masterlist by account officer               ≥
≥   Author.............:  Gener C. Singson                                     ≥
≥   Date...............:  02:56pm 06-Mar-1995                                  ≥
√ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥
≥                         U P D A T E S                                        ≥
√ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥
≥        Who        ≥     When      ≥               Why                        ≥
√ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥
≥ janet l. bautista ≥  15-Apr-1996  ≥ to follow standard coding                ≥
¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
*/

#include 'INKEY.CH'
#include 'COLF.CH'

#define NIRVANA tone( 480, 0.25 ); tone( 240, 0.25 )

if CHKPASS( procname(), AX_LEVEL, gUSER_ID )
   begin sequence
         nosnow( .t. )
         fOPEN0100()
         fMAIN0100()
         nosnow( .f. )
   end sequence
   dbcloseall()
endif   
__mrelease( '*', !.f. )
return

// ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
   static function fMAIN0100()
// ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
   local sv
   priva _x := -1

   savescreen    ( ,,, sv )
   if !fDraw0100 ()
      while !eval( { || fMall0100(), if( _x # -3, !.t., !.f. ) } )
      enddo
   endif   
   restscreen( ,,,, sv )
   return( nil )

// ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
   static function fMall0100()
// ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
   local menulist 
   memva _x
   priva total_princ := total_amort := total_creda := total_osbal := 0
   priva grand_princ := grand_amort := grand_creda := grand_osbal := 0
   priva con, gnam, mpage := 1
   private linclude_sold

   linclude_sold := .f.
   _x := abs( _x )

   @ 10, 35 prompt ' ~One ' message '';
            messagecolor 'w+/n' triggercolor 'w+/gr'

/*****************
   @ 12, 35 prompt ' ~All ' message '';
            messagecolor 'w+/n' triggercolor 'w+/gr'
********************/

   menu to _x initial _x &&timeout 20

   do case
      case _x == 0 
         _x  := -3
      case _x == 1
         _x  := -1
         con := { || eval( gnam ) == Acctmast->aocode }
         linclude_sold := .f.
         if confirm( 'Include Sold Receivables?',.t. )
            linclude_sold := .t.
         endif

         if lastkey() != K_ESC
            fDone0100()
         endif

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

// ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
   static function fDone0100()
// ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
   local msv, cBRCODES := g_PAR_BRCH  //ACC_BRCH(g_USER_ID)
   priva sw, cnt := inc := 0, ind := 1

   msv := savescreen( ,,, )
   if !fDate0100()
      reportprint( 'fPrnt0100('+cBRCODES+')', '132 COLUMN' )
      *repcon_ol( 'fPrnt0100('+cBRCODES+')', '132 COLUMN',,,,,,.F. )
      inkey( .5 )   
   endif
   restscreen( ,,,, msv )
   return( nil )

// ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
   function fPrnt0100(cBRCODES)
// ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
   local ao_code := 'piaÒ', ax
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
   fOutp0100()                             
   set device to printer
   fHead0100() 
//aga.27.10.2006.temp mod for ssr for csp
//   dbeval( { | n | n := if( ao_code != padr( Acctmast->aocode, 5 ),;
//                       eval( { || sw := -1, padr( Acctmast->aocode,;
//                       5 ) } ), ao_code ), IF(ACCTMAST->BRCODE $ (cBRCODES) .and. 'ACCENTURE' $ Acctmast->acctname .and. Acctmast->Osbal > 0, fDisp0100( ao_code := n,;
//                       Acctmast->fcltycode ), NIL) ;
//                       },,;
//                       { || eval( con ) } )

/*
   dbeval( { | n | n := if( ao_code != padr( Acctmast->aocode, 5 ),;
                       eval( { || sw := -1, padr( Acctmast->aocode,;
                       5 ) } ), ao_code ), IF(ACCTMAST->BRCODE $ (cBRCODES), fDisp0100( ao_code := n,;
                       Acctmast->fcltycode ), NIL) ;
                       },,;
                       { || eval( con ) } )
*/

   dbeval( { | n | n := if( ao_code != padr( Acctmast->aocode, 5 ),;
                       eval( { || sw := -1, padr( Acctmast->aocode,;
                       5 ) } ), ao_code ), IF(AXBRANCH->(DBSEEK(g_USER_ID+ACCTMAST->BRCODE)), fDisp0100( ao_code := n,;
                       Acctmast->fcltycode ), NIL) ;
                       },,;
                       { || eval( con ) } )

   if _x == -2       
      fSubt0100()
   endif   
   fEjec0100()
   @ prow() + 1, 129 say repl( 'ƒ', 18 )
   @ prow()    , 177 say repl( 'ƒ', 18 )
   @ prow()    , 196 say repl( 'ƒ', 18 )
   @ prow()    , 215 say repl( 'ƒ', 18 )
   fEjec0100()
   @ prow() + 1, 112 say 'Grand-Total Ø'
   @ prow()    , 129 say grand_princ picture '999,999,999,999.99'
   @ prow()    , 177 say grand_amort picture '999,999,999,999.99'
   @ prow()    , 196 say grand_creda picture '999,999,999,999.99'
   @ prow()    , 215 say grand_osbal picture '999,999,999,999.99'
   fEjec0100()
   @ prow() + 1, 129 say repl( 'Õ', 18 )
   @ prow()    , 177 say repl( 'Õ', 18 )
   @ prow()    , 196 say repl( 'Õ', 18 )
   @ prow()    , 215 say repl( 'Õ', 18 )
   __eject()           
   set device to screen   
   inkey( .5 )
   restscreen( 7, 1, 20, 36, ax )
   return( .t. )

// ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
   static function fDisp0100( ao_code, fc_code )
// ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
   local row := 1, ao_name, fc_name, gdamt, rvamt
   memva total_princ, total_amort, total_creda, total_osbal
   memva grand_princ, grand_amort, grand_creda, grand_osbal
   memva sw, cnt, ind, inc

   if Acctmast->status== '0'           // CANCELLED RLV 08/18/2010
        return nil
   endif
   
   if Acctmast->status== '6'            // SOLD REC'BLES
      if !linclude_sold
          return nil
      endif
   endif

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

if substr(Acctmast->fcltycode,1,3) == '103'
	gdamt := Acctmast->gd 
	rvamt := Acctmast->rv
else
	gdamt := 0
	rvamt := 0
endif

@ prow() + row,   3 say ACCTMAST->BRCODE+Acctmast->acctno    picture '@R 999-9999-99999-99999'
@ prow()      ,  24 say Acctmast->acctname  picture '@!'
@ prow()      ,  75 say fc_code             picture '@R 999-99'
@ prow()      ,  82 say fc_name             picture '@!'
@ prow()      ,  88 say Acctmast->unit      picture '@!'
@ prow()      , 129 say Acctmast->principal picture '999,999,999,999.99'
@ prow()      , 148 say gdamt        picture '99.99'
@ prow()      , 154 say rvamt        picture '99.99'
@ prow()      , 160 say Acctmast->term      picture '999'
@ prow()      , 163 say ' months'
@ prow()      , 171 say Acctmast->truerate  picture '99.99'
@ prow()      , 177 say Acctmast->amort     picture '999,999,999,999.99'
@ prow()      , 196 say Acctmast->credamt   picture '999,999,999,999.99'
@ prow()      , 215 say Acctmast->osbal     picture '999,999,999,999.99'
//aga.03.09.2007.insert getosbal function here
//tgetosbal(xacctno, xcredamt, xdate, xbrcode)

//aga.27.10.2006.temp add for ssr for csp
//@ prow()      , 235 say Acctmast->matdate   picture '@D'

set device to screen
@ 17,  3 say tran( grand_amort,         '999,999,999.99' ) color 'w+/rb'
scroll( 11, 18, 12, 31, 1 )
@ 12, 18 say padr( Acctmast->acctname, 14 )                color 'w+/rb'
scroll( 14, 18, 15, 31, 1 )
@ 15, 18 say tran( Acctmast->principal, '999,999,999.99' ) color 'w+/rb'
scroll( 17, 18, 18, 31, 1 )
@ 18, 18 say tran( Acctmast->amort,     '999,999,999.99' ) color 'w+/rb'
@  9 + ind, 33 say '∞'                                     color 'w+/n'
       ind := int( max( ( ( inc += 1 ) / cnt ) * 7, 1 ) )
@  9 + ind, 33 say '€'                                     color 'w+/w'
set device to printer
return( nil )

////
static function fSubt0100()
memva total_princ, total_amort, total_creda, total_osbal

fEjec0100()        
@ prow() + 1, 129 say repl( 'ƒ', 18 )
@ prow()    , 177 say repl( 'ƒ', 18 )
@ prow()    , 196 say repl( 'ƒ', 18 )
@ prow()    , 215 say repl( 'ƒ', 18 )
fEjec0100()
@ prow() + 1, 112 say '  Sub-Total Ø'
@ prow()    , 129 say total_princ picture '999,999,999,999.99'
@ prow()    , 177 say total_amort picture '999,999,999,999.99'
@ prow()    , 196 say total_creda picture '999,999,999,999.99'
@ prow()    , 215 say total_osbal picture '999,999,999,999.99'
fEjec0100()
@ prow() + 1, 129 say repl( 'ƒ', 18 )
@ prow()    , 177 say repl( 'ƒ', 18 )
@ prow()    , 196 say repl( 'ƒ', 18 )
@ prow()    , 215 say repl( 'ƒ', 18 )
total_princ := total_amort := total_creda := total_osbal := 0
return( nil )

////
static function fHead0100()
memvar mpage, gSYS_NAME, gCOMPANY

setfont( upper( 'init' ) )
prnreptitle( 136, 5, mpage++, 'ACCOUNTS MASTERLIST', 'AMSQ0100', gSYS_NAME, gCOMPANY ) 
setfont( upper( 'normal' ) )
@ prow() + 1, ( 136 - 16 ) / 2 say 'As of ' + dtoc( Flag->lastclosed )
setfont( upper( 'condensed' ) )

//aga.27.10.2006.temp mod for ssr for csp
//@ prow() + 1, 2 say '⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒ¬ƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒø'
//@ prow() + 1, 2 say '≥                    ≥                                                  ≥            ≥                                        ≥                  ≥     ≥     ≥ Original ≥True ≥     Monthly      ≥      Credit      ≥   Outstanding    ≥  Maturity ≥'
//@ prow() + 1, 2 say '≥     Account Nß     ≥                   Account Name                   ≥  Facility  ≥               Collateral               ≥     Proceeds     ≥ G D ≥ R V ≥   Term   ≥ Rate≥   Amortization   ≥      Amount      ≥     Balance      ≥    Date   ≥'
//@ prow() + 1, 2 say '¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒ¡ƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒŸ'


@ prow() + 1, 2 say '⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒ¬ƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø'
@ prow() + 1, 2 say '≥                    ≥                                                  ≥            ≥                                        ≥                  ≥     ≥     ≥ Original ≥True ≥     Monthly      ≥      Credit      ≥   Outstanding    ≥'
@ prow() + 1, 2 say '≥     Account Nß     ≥                   Account Name                   ≥  Facility  ≥               Collateral               ≥     Proceeds     ≥ G D ≥ R V ≥   Term   ≥ Rate≥   Amortization   ≥      Amount      ≥     Balance      ≥'
@ prow() + 1, 2 say '¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒ¡ƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ'


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
   @ 14, 31 gget mcd picture '@!';            && RED 11122004 REMOVED- when pseek( @mcd ) valid fPad0100( @mcd )'
            VALID IF( !EMPTY(MCD) .AND. LASTKEY() == K_ENTER,;
                      IF( fPADXXXX( MCD, 5 ) ,;
                          .T.,;
                          EVAL({|| MCD := SPACE(5),;
                                   .F.;
                              });
                        ),;
                      EVAL({|| PSEEK(@MCD),;
                               IF( LASTKEY() == K_ENTER,;
                                   .T.,;
                                   EVAL({|| MCD := SPACE(5),;
                                            .F.;
                                       });
                                 );
                          });
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
*return( eval( { || lb_lkup( 'Ao', 1, 2, @mcd, 2, 1, 10, 36, 20, 75, 'W/GR+,W/N,,,W/GR+' ), .t. } ) )
 return( eval( { || __lb_lkup( 'Ao'      , 1, 2,@mcd    , 1, 2, 3,10,24,20,75,'W/GR+,W/N,,,W/GR+',,,,,,,,'Name','Position' ), .t. } ) )
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
@ 10, 40 say 'ﬂ'                    color 'w/n'
@ 11, 36 say '‹‹‹‹‹'                color 'w/n'
@ 12, 40 say 'ﬂ'                    color 'w/n'
@ 13, 36 say '‹‹‹‹‹'                color 'w/n'
******************/

fShadow( 9, 33, 12, 42, 2, 'n/w' )
@ 10, 40 say 'ﬂ'                    color 'w/n'
@ 11, 36 say '‹‹‹‹‹'                color 'w/n'

*****@ 12, 40 say 'ﬂ'                    color 'w/n'
******@ 13, 36 say '‹‹‹‹‹'                color 'w/n'

/*
@  9, 32 say '¬'                    color 'n/w'
@ 10, 32 say '≥'                    color 'n/w'
@ 10, 34 say 'Select and write the' color 'n+/w'
 
@ 11, 32 say '≥'                    color 'n/w' 
@ 11, 34 say '        you want to'  color 'n+/w'
@ 11, 34 say 'Ao-Code'              color 'w+/w'
 
@ 12, 32 say '≥'                    color 'n/w' 
@ 12, 34 say 'be printed in the'    color 'n+/w'
 
@ 13, 32 say '≥'                    color 'n/w' 
@ 13, 34 say 'Accounts Masterlist'  color 'w+/w'
@ 13, 53 say '.'                    color 'n+/w'  
@ 14, 32 say '¡'                    color 'n/w'
*/
return( .f. )

////
static function fOutp0100()                             

inkey( .5 )
dispbegin()
fShadow(  7,  1, 19, 34, 2,   'n/w'  )
dispbox(  8, 17, 18, 17, '≥', 'n/w'  )
dispbox(  8, 32, 18, 32, '≥', 'n/w'  )
dispbox( 10, 33, 16, 33, '∞', 'w+/n' ) 
dispbox( 10,  2, 10, 31, 'ƒ', 'n/w'  )
dispbox( 13,  2, 13, 31, 'ƒ', 'n/w'  )
dispbox( 16,  2, 16, 31, 'ƒ', 'n/w'  )
@  7, 17 say '¬'             color 'n/w'
@  7, 32 say '¬'             color 'n/w'
@  8, 33 say chr( 24 )       color 'w+/w'
@  9, 32 say '√ƒ¥'           color 'n/w' 
@ 10,  1 say '√'             color 'n/w'
@ 10, 17 say '≈'             color 'n/w'
@ 10, 32 say '¥'             color 'n/w' 
@ 13,  1 say '√'             color 'n/w'
@ 13, 17 say '≈'             color 'n/w'
@ 13, 32 say '¥'             color 'n/w' 
@ 16,  1 say '√'             color 'n/w'
@ 16, 17 say '≈'             color 'n/w'
@ 16, 32 say '¥'             color 'n/w' 
@ 17, 32 say '√ƒ¥'           color 'n/w' 
@ 18, 33 say chr( 25 )       color 'w+/w'  
@ 19, 17 say '¡'             color 'n/w'
@ 19, 32 say '¡'             color 'n/w'
@  9,  2 say 'Account Officer' color 'gr+/w'
@ 12,  2 say '   Account Name' color 'gr+/w'
@ 15,  2 say '      Principal' color 'gr+/w'
@ 18,  2 say '   Amortization' color 'gr+/w'
dispend()
return( nil )

////
static function fOPEN0100()

if !netuse( '&g_AMS_PATH\Flag', .f., 10 )               && flag
   break 
endif

if !netuse( '&g_CIS_PATH\Ao', .f., 10 )     && account officer
   break 
else 
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_CIS_PATH\Ao' )           && set index on ao code
endif

if !netuse( '&g_grf_path'+'\Axbranch.dbf',.f.,5)
   return .f.
endif
set index to &g_grf_path\Axbranch

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
   ordlistadd( '&g_AMS_PATH\Acctaonm' )                 && set index aocode + acctname
endif                                       
return( nil )

// Eop: AMSQ0100.prg //
