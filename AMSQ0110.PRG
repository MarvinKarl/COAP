/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   PROGRAM ID.........:  amsq0110.prg                                         ³
³   Description........:  accounts masterlist by account name                  ³
³   Author.............:  Gener C. Singson                                     ³
³   Date...............:  02:13pm 08-Mar-1995                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                         U P D A T E S                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        Who        ³     When      ³               Why                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ janet l. bautista ³  15-Apr-1996  ³ to follow standard coding                ³
³Engr.Michael Espina³ 02-March-1999 ³ Addition of New Account Number           ³
³ abb               ³ 04-Sept-2001  ³ excl/incl sold rec'bles option           ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include 'INKEY.CH'
#include 'COLF.CH'

#define NIRVANE tone( 480, 0.25 ); tone( 240, 0.25 )

local WATER

if chkpass ( procname(), AX_LEVEL, gUSER_ID )
   nosnow  ( .t. )
   begin sequence
      fopen0110 ()
      fmain0110 ()
      recover using WATER
      if water
         dbcloseall()
         __mrelease( '*', WATER )
      endif   
   end
   nosnow( .f. )
endif
   
return

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function fMAIN0110()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local sv, WATER
   priva _x := -1

   savescreen( ,,, sv )
   if !fDraw0110()
      while WATER := !eval( { || fMall0110(), if( _x # -3, !.t., !.f. ) } )
      enddo
   endif   
   restscreen( ,,,, sv )
   if WATER := !WATER
      break WATER
   endif   
   return( nil )

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function fMall0110()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local menulist 
   memva _x
   priva total_princ := total_amort := total_creda := total_osbal := 0
   priva grand_princ := grand_amort := grand_creda := grand_osbal := 0
   priva con, gnam, mpage := 1 ,xAcctname
   private linclude_sold

   linclude_sold := .f.
   _x := abs( _x )

   @ 10, 35 prompt ' ~One ' message '';
            messagecolor 'w+/n' triggercolor '+w/gr'
            /*************
   @ 12, 35 prompt ' ~All ' message '';
            messagecolor 'w+/n' triggercolor '+w/gr'
            ************/
   menu to _x initial _x &&timeout 20

   do case
      case _x == 0 
         _x  := -3
      case _x == 1
         linclude_sold := .f.
         _x  := -1
         con := { || eval( gnam ) == ACCTMAST->BRCODE+Acctmast->Acctname }    //Acctmast->acctname }
         if confirm( 'Include Sold Receivables?',.t. )
            linclude_sold := .t.
         endif

         if lastkey() != K_ESC
            fDone0110()
         endif

      case _x == 2
         _x  := -2
         if lastrec() > 0
            dbgotop()
            con := { || !eof() }
            fDone0110()
         else
            error( 'No Available Record!' )        
         endif     
   endcase        
   return( _x )

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function fDone0110()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local msv
   priva sw:=1, cnt := inc := 0, ind := 1, on, off := 0

   msv := savescreen( ,,, )
   if !fDate0110()
      REPCON_OL( 'fPrnt0110()', '132 COLUMN',,,,,,,'AMSQ0110-Accounts Masterlist by Acct. Name ',.T.)
      //repcon_ol( 'fPrnt0110()', '132 COLUMN',,,,,,.T.,'sgsdfgsdfgdgg' )
     // inkey( .5 )   
   endif
   restscreen( ,,,, msv )
   return( nil )

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   function fPrnt0110()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local ax,mu:=Acctmast->(indexord()),old_code:= ' '
   memva grand_princ, grand_amort, grand_creda, grand_osbal
   memva con, sw, _x, cnt, off
   private ac_code := 'piañ',clcnt:= 1,nwpage := .f.,ac_name

   dbsetorder(3)
   if _x == -1
      dbeval( { || cnt += 1 },,;
              { || eval( con ) } )
      dbseek( eval( gnam ) )
      ac_name:= acctmast->acctname
   else
      cnt := Acctmast->( lastrec() )
      acctmast->( dbgotop() )
   endi
   old_code := Acctmast->Acctname
   ac_code  := if(empty(old_code),spac(7),alltrim(old_code))
   set device to screen
   ax := savescreen( 7, 1, 20, 36 )
   //alert(con)
   //
   // fOutp0110()
   //
   //ACCTMAST->(dbsetorder(3))
   set device to printer   
   fHead0110()
   dbeval( { | n | n := if ( ac_code == alltrim( ACCTMAST->BRCODE+Acctmast->Acctname ),;
                             eval( { || sw := -1, ac_code }),  ;
                             eval( { || sw := 1, alltrim( ACCTMAST->BRCODE+Acctmast->Acctname ) } );
                           ),;
                           ac_code := alltrim( n ), fDisp0110(@old_code)  ;
           },,{ || eval( con ) } )

   if _x == -2 .and. clcnt > 1
      fSubt0110()
   endif

   if _x == -1
      fEjec0110()
      @ prow() + 1,  83 say repl( 'Ä', 16 )
      @ prow()    , 123 say repl( 'Ä', 15 )
      @ prow()    , 139 say repl( 'Ä', 17 )
      @ prow()    , 157 say repl( 'Ä', 17 )
      fEjec0110()
      @ prow() + 1,  68 say 'Grand-Total ¯'
      @ prow()    ,  82 say grand_princ picture '99,999,999,999.99'
      @ prow()    , 121 say grand_amort picture '99,999,999,999.99'
      @ prow()    , 139 say grand_creda picture '99,999,999,999.99'
      @ prow()    , 157 say grand_osbal picture '99,999,999,999.99'
      @ prow() + 1,  83 say repl( 'Í', 16 )
      @ prow()    , 123 say repl( 'Í', 15 )
      @ prow()    , 139 say repl( 'Í', 17 )
      @ prow()    , 157 say repl( 'Í', 17 )
   else
      fEjec0110()
      @ prow() + 1, 112 say repl( 'Ä', 18 )
      @ prow()    , 171 say repl( 'Ä', 18 )
      @ prow()    , 190 say repl( 'Ä', 18 )
      @ prow()    , 209 say repl( 'Ä', 18 )
      fEjec0110()
      @ prow() + 1,  95 say 'Grand-Total ¯'
      @ prow()    , 112 say grand_princ picture '999,999,999,999.99'
      @ prow()    , 171 say grand_amort picture '999,999,999,999.99'
      @ prow()    , 190 say grand_creda picture '999,999,999,999.99'
      @ prow()    , 209 say grand_osbal picture '999,999,999,999.99'

      @ prow() + 1, 112 say repl( 'Í', 18 )
      @ prow()    , 171 say repl( 'Í', 18 )
      @ prow()    , 190 say repl( 'Í', 18 )
      @ prow()    , 209 say repl( 'Í', 18 )
   endif
   __eject()
   set device to screen
   inkey( .5 )
   restscreen( 7, 1, 20, 36, ax )
   acctmast->(dbsetorder(mu))
   return( .t. )

**************************************
*
static function fDisp0110 ( old_code )
**************************************
   local row := 1,prntname:= .f., gdamt, rvamt
   memva total_princ, total_amort, total_creda, total_osbal
   memva grand_princ, grand_amort, grand_creda, grand_osbal
   memva sw, cnt, ind, inc, on, ac_code, _x

   if Acctmast->status == '0'           // CANCELLED RLV 08/18/2010
        return nil
   endif   
   
   if Acctmast->status== '6'           // SOLD REC'BLES
      if !linclude_sold
          return nil
      endif
   endif
   
	if substr(Acctmast->fcltycode,1,3) == '103'
		gdamt := Acctmast->gd 
		rvamt := Acctmast->rv
	else
		gdamt := 0
		rvamt := 0
	endif

   if alltrim( ac_code ) == Alltrim( old_code )
      prntname:= .f.
      clcnt++
   else
      if ( total_princ + total_amort + total_creda + total_osbal ) > 0 .and. clcnt > 1
         fSubt0110()
         fEjec0110()
      ENDIF
      clcnt:= 1
      old_code := ac_code
      prntname := .t.
   endif

   total_princ += Acctmast->principal
   total_amort += Acctmast->amort
   total_creda += Acctmast->credamt
   total_osbal += Acctmast->osbal
   grand_princ += Acctmast->principal
   grand_amort += Acctmast->amort
   grand_creda += Acctmast->credamt
   grand_osbal += Acctmast->osbal

   fEjec0110()
   if Acctmast->Status != '1'
     do case
        case Acctmast->status == '2'   // PDR
           @ prow() + row , 04 say 'p'
        case Acctmast->status == '3'  // ITEMS
           @ prow() + row , 04 say 'i'
        case Acctmast->status == '4'  // ROPOA
           @ prow() + row , 04 say 'r'
        case Acctmast->status == '5'  // WRITTEN-OFF
           @ prow() + row , 04 say 'w'
        case Acctmast->status == '6'  // SOLD
           @ prow() + row , 04 say 's'
        otherwise
           @ prow() + row , 04 say 'e'
     endcase
     row:=row-1
   endif

   if _x == -1

      @ prow() + row,  05 say alltrim(Acctmast->brcode)+'-'+alltrim(Acctmast->Clntcode	 )
	  @ prow()      ,  17 say ACCTMAST->BRCODE+substr(Acctmast->acctno,-5,5) PICT '@R 999-99999'
      @ prow()      ,  27 say left(alltrim(Acctmast->oldno),16)
      @ prow()      ,  44 say Acctmast->unit           picture '@!'
      @ prow()      ,  85 say Acctmast->principal      picture '999,999,999.99'
      @ prow()      , 100 say gdamt             picture '99.99'
      @ prow()      , 106 say rvamt             picture '99.99'
      @ prow()      , 112 say Acctmast->term           picture '999'
      @ prow()      , 116 say if(ALLTRIM(Acctmast->Termunit) == '2','m','d' )
      //@ prow()      , 123 say if(ALLTRIM(Acctmast->Termunit) == '2',Acctmast->remterm,0 )   picture '@Z 999'
      //@ prow()      , 127 say if(ALLTRIM(Acctmast->Termunit) == '2','m',' ')
      @ prow()      , 118 say Acctmast->truerate       picture '99.99'
      @ prow()      , 124 say Acctmast->amort          picture '999,999,999.99'
      @ prow()      , 142 say Acctmast->credamt        picture '999,999,999.99'
      @ prow()      , 160 say Acctmast->osbal          picture '999,999,999.99'
      @ prow()      , 175 say Acctmast->Valdate        picture '@D'
   else

      @ prow() + row,   9 say       ACCTMAST->BRCODE+left( alltrim(Acctmast->oldno),16 ) PICT '@R 999-9999-99999-99999'
      if prntname  .or. nwpage
         @ prow()      ,  30 say  padr( Acctmast->acctname,40 ) 
         nwpage := .f.
      else
         @ prow()      ,  30 say  padr( ' ',40 )
      endif

      @ prow()      ,  71 say       Acctmast->unit           picture '@!'
      @ prow()      , 112 say       Acctmast->principal      picture '999,999,999,999.99'
      @ prow()      , 131 say       gdamt             picture '99.99'
      @ prow()      , 137 say       rvamt             picture '99.99'
      @ prow()      , 143 say       Acctmast->term           picture '999'
      @ prow()      , 146 say ' months'
      @ prow()      , 154 say       Acctmast->remterm        picture '999'
      @ prow()      , 157 say ' months'
//aga.03.09.2007.insert getremterm function here
//_get_remterm(cacctno, dpaydate, dtermctr, cbrcode)

      @ prow()      , 165 say       Acctmast->truerate       picture '99.99'
      @ prow()      , 171 say       Acctmast->amort          picture '999,999,999.99'
      @ prow()      , 190 say       Acctmast->credamt        picture '999,999,999,999.99'
      @ prow()      , 209 say       Acctmast->osbal          picture '999,999,999,999.99'
//aga.03.09.2007.insert getosbal function here
//tgetosbal(xacctno, xcredamt, xdate, xbrcode)

   endif
   return( nil )

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function fSubt0110()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

   memva total_princ, total_amort, total_creda, total_osbal

   fEjec0110()
   @ prow() + 1, 112 say repl( 'Ä', 18 )
   @ prow()    , 171 say repl( 'Ä', 18 )
   @ prow()    , 190 say repl( 'Ä', 18 )
   @ prow()    , 209 say repl( 'Ä', 18 )
   fEjec0110()
   @ prow() + 1,  95 say '  Sub-Total ¯'
   @ prow()    , 112 say total_princ picture '999,999,999,999.99'
   @ prow()    , 171 say total_amort picture '999,999,999,999.99'
   @ prow()    , 190 say total_creda picture '999,999,999,999.99'
   @ prow()    , 209 say total_osbal picture '999,999,999,999.99'

   @ prow() + 1, 112 say repl( 'Ä', 18 )
   @ prow()    , 171 say repl( 'Ä', 18 )
   @ prow()    , 190 say repl( 'Ä', 18 )
   @ prow()    , 209 say repl( 'Ä', 18 )
   total_princ := total_amort := total_creda := total_osbal := 0

   return( nil )

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function fHead0110()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   memvar mpage, gSYS_NAME, gCOMPANY, nwpage

   if _x == -1
     setfont( upper( 'init' ) )
     prnreptitle( 102, 5, mpage++, 'ACCOUNTS MASTERLIST', 'AMSQ0110', gSYS_NAME, gCOMPANY )
     setfont( upper( 'uncondensd' ) )
     @ prow() + 1, ( 102 - 16 ) / 2 say 'As of ' + dtoc( Flag->lastclosed )
     setfont( upper( 'condensed' ) )
     //@ prow()+1,1 say '   ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿'
     //@ prow()+1,1 say '   ³   Client  ³    New     ³      Old       ³                                        ³              ³     ³     ³ Orig ³ True³   Monthly    ³      Credit     ³    Outstanding  ³Execution³'
     //@ prow()+1,1 say '   ³    Code   ³   Acctno   ³   Account N§   ³               Collateral               ³   Proceeds   ³ G D ³ R V ³ Term ³ Rate³ Amortization ³      Amount     ³      Balance    ³   Date  ³'
     //@ prow()+1,1 say '   ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÙ'
     @ prow()+1,1 say '   ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿'
     @ prow()+1,1 say '   ³  Client   ³  New    ³      Old       ³                                        ³              ³     ³     ³Orig³ True ³   Monthly    ³      Credit     ³   Outstanding   ³Execution³'
     @ prow()+1,1 say '   ³   Code    ³ Acctno  ³   Account N§   ³               Collateral               ³   Proceeds   ³ G D ³ R V ³Term³ Rate ³ Amortization ³      Amount     ³     Balance     ³   Date  ³'
     @ prow()+1,1 say '   ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÙ'

     @ prow()+1,1 say ' '                                                                                                                                                                     
     @ prow()+1,5 say '[ '+alltrim(ac_name)+' ]'
     @ prow()+1,1 say ' '
   else
     setfont( upper( 'init' ) )
     prnreptitle( 136, 5, mpage++, 'ACCOUNTS MASTERLIST', 'AMSQ0110', gSYS_NAME, gCOMPANY )
     setfont( upper( 'uncondensd' ) )
     @ prow() + 1, ( 136 - 16 ) / 2 say 'As of ' + dtoc( Flag->lastclosed )
     setfont( upper( 'condensed' ) )
     @ prow() + 1, 8 say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿'
     @ prow() + 1, 8 say '³                ³                                        ³                                        ³                  ³     ³     ³ Original ³Remaining ³True ³     Monthly      ³      Credit      ³   Outstanding    ³Execution³'
     @ prow() + 1, 8 say '³   Account N§   ³              Account Name              ³               Collateral               ³     Proceeds     ³ G D ³ R V ³   Term   ³   Term   ³ Rate³   Amortization   ³      Amount      ³     Balance      ³  Date   ³'
     @ prow() + 1, 8 say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÙ'
     nwpage := .t.
   endif
   return( nil )

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function fEjec0110()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   memvar _x
   if _x == -1
     if prow() >= 42
        __eject()
        fHead0110()
     endif
   else
     if prow() >= 50
        __eject()
        fHead0110()
     endif
   endif
   return( .t. )

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function fDate0110()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local getlist := {}, mcd := space( 50 )
   local mcl := setcolor(), log := !.f., cbrcode:= g_PAR_BRCH
   memva gnam, _x, xAcctname

   Acctmast->(dbsetorder(3))
   setcolor( 'n/bg, w+/n,,, gr+/bg' )
   fShadow( 13, 15-5, 15, 51-5, 2, 'n/w' )

   @ 14, 16-5 say 'Account Name ' + chr( 16 ) + ' '
   if _x != -1
      @ 14, 31-5 say padr( 'All', 20 ) color 'gr+/bg'
   else
      @ 14, 31-5 gget mcd picture '@!S20'                                  ;  && RED 11162004 REMOVED 'when pseek( @mcd ) valid fPad0110( @mcd )'
               VALID IF( !EMPTY(MCD) .AND. LASTKEY() == K_ENTER           ,;
                         EVAL( { || SCREEN(@MCD)                          ,;  && RED 033005 'FILTER()
                             IF( !EMPTY(MCD)                              ,;
                                 IF( VALBRCODE(cbrcode,g_USER_ID),;  && RED 033005   fPAD0110( @mcd )                  ,;
                                     .T.                                  ,;  && RED 033005    EVAL({ || MCD := SPACE(50), .F.}) ;
                                     EVAL({ || MCD := SPACE(50), .F.})     ;  && RED 033005    )                                ,;
                                   )                                      ,;
                                 .F.                                       ;
                               )                                           ;
                             } )                                          ,;
                         EVAL({ || in:=ach_look(),;
                                   MCD :=  in                                                                                                        ,;        && RED 033005
                                   IF( LASTKEY() == K_ENTER                                                                                        ,;
                                       IF( VALBRCODE(cbrcode,g_USER_ID)                                                                   ,;
                                           .T.                                                                                                     ,;
                                           EVAL({ || MCD := SPACE(50), .F.})                                                                        ;
                                         )                                                                                                         ,;
                                       EVAL({ || MCD := SPACE(50)                                                                                  ,;
                                              .F.                                                                                                   ;
                                           })                                                                                                       ;
                                     )                                                                                                              ;
                             })                                                                                                                     ;
                       )
   endif

   setcursor( 3 )
   setkey( K_ESC, { || fEscape( 'Abort?' ) } )
   read &&timeout 20 exitevent blankscr3( -1 )
   setkey( K_ESC, nil )
   setcursor( 0 )

   if lastkey() != K_ESC
   ACCTMAST->(DBSetorder(3))

//alert(mcd + ' ' + alias() + ' ' + indexkey())

      ACCTMAST->(DBSEEK(cbrcode+MCD))          && RED 033005
      xAcctname := ACCTMAST->BRCODE+Acctmast->Acctname

//alert(xAcctname)

      mcd:= Acctmast->acctname
      log  := !.t.
      gnam := { || xAcctname }
   endif

   inkey( .5 )
   setcolor( mcl )
   return( log )
   
**********************************************
static function ach_look()
**********************************************
local mod_t:='acct_fnc', ckey:=space(10),cbrcode:= g_PAR_BRCH
local headr:='    Account Name                          Branch     Account N§    '
   
main_achoice('ACCTMAST',3,1,,8,6,21,75,headr,mod_t)
   
if mpos > 0 .and. lastkey() == K_ENTER .and. !empty(mchoices)

   cKEY := substr( ltrim(mchoices[mpos]),1,20)

/*	
   client->(dbsetorder(1))
			
   if Client->( dbseek (alltrim(cKEY)) )   
      aNRECNO := Client->(RECNO())
   endif		
*/ 

end if

//alert(ckey)
akey := ckey

return ckey
   
   
   *------------------------------
   FUNCTION fBRCODE(cNAME)
   LOCAL cRETVAL := SPACE(3)

   IF ACCTMAST->(DBSEEK(RTRIM(cNAME)))
      cRETVAL := ACCTMAST->BRCODE
   ENDIF

   RETURN cRETVAL
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function pseek( mcd )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   acctmast->(dbsetorder(3))
   *return( eval( { || lb_lkup( 'Acctmast', 1, 1, @mcd, 3, 2, 10, 36, 20, 75, 'W/GR+,W/N,,,W/GR+',,, 3 ), .t. } ) )
   __LB_LKUP( 'ACCTMAST', 1, 1, @MCD, 3,88, 2,10,26,20,75,'W/GR+,W/N,,,W/GR+',,,,3,,,,'Name','Branch',' Acct No.' )
   **ALERT(ACCTMAST->BRCODE+ACCTMAST->ACCTNAME)
   RETURN
/*
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function fPad0110( mcd )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local log := !.f.
  
   if !dbseek( mcd := padr( mcd, 50 ) )
      log := !.t.
      error( 'No such Record!' )
   endif
   return( log )
*/
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function fDraw0110()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   setcolor( 'n/gr, +w/gr' )
*****   fShadow( 9, 33, 14, 42, 2, 'n/w' )
   fShadow( 9, 33, 12, 42, 2, 'n/w' )
   @ 10, 40 say 'ß'                     color 'w/n'
   @ 11, 36 say 'ÜÜÜÜÜ'                 color 'w/n'

*****   @ 12, 40 say 'ß'                     color 'w/n'
*****   @ 13, 36 say 'ÜÜÜÜÜ'                 color 'w/n'

   /*
   @  9, 32 say 'Â'                     color 'n/w'
    
   @ 10, 32 say '³'                     color 'n/w'
   @ 10, 34 say 'Select and write the'  color 'n+/w'
    
   @ 11, 32 say '³'                     color 'n/w' 
   @ 11, 34 say '             you want' color 'n+/w'
   @ 11, 34 say 'Account Name'          color 'w+/w'
    
   @ 12, 32 say '³'                     color 'n/w' 
   @ 12, 34 say 'to be printed in the'  color 'n+/w'
    
   @ 13, 32 say '³'                     color 'n/w' 
   @ 13, 34 say 'Accounts Masterlist'   color 'w+/w'
   @ 13, 53 say '.'                     color 'n+/w'  
   @ 14, 32 say 'Á'                     color 'n/w'
   */
   return( .f. )

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function fOutp0110()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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
   @  9,  4 say ' Account Name' color 'gr+/w'
   @ 12,  4 say '   Collateral' color 'gr+/w'
   @ 15,  4 say '    Principal' color 'gr+/w'
   @ 18,  4 say ' Amortization' color 'gr+/w'
   dispend()
   return( nil )

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function fOPEN0110()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local WATER := !.f.

   if !netuse( '&g_AMS_PATH\Flag', .f., 10 )               && flag
      break WATER
   endif
   
   if !netuse( '&g_CIS_PATH\CLIENT', .f., 10 )              
      break WATER
   else
		if !.f.; ordlistclear(); endif
      set index to &g_CIS_PATH\Cliebf
   endif
   
   if !netuse ( '&g_AMS_path\PRINTCTR',.f.,10 )
      break water
	endif

   if !netuse( '&g_AMS_PATH\Acctmast', .f., 10 )           && account master
      break WATER
   else 
      if !.f.; ordlistclear(); endif
      //ordlistadd( 'Acctacno' )                 && set index acctname + acctno
      set index to &g_AMS_PATH\Acctacno, &g_AMS_PATH\Acctclnt, &g_AMS_PATH\Acctmatd
      dbsetorder(3)
   endif
   return( nil )

// Eop: AMSQ0110.prg //
/*
1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
         1         2         3         4         5         6         7         8         9         0         1          2        3         4         5         6         7
   Account Management System                                                                Page :    1
   AMSQ0110                                                                         06/11/1996 17:27:11E
                             CONSOLIDATED ORIX LEASING and FINANCE CORPORATION                    
                                          ACCOUNTS MASTERLISTF
                                            As of 04/30/1996
          ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
          ³                ³                                        ³              ³     ³     ³ Orig ³ Rem  ³ True³   Monthly    ³      Credit     ³    Outstanding  ³
          ³   Account N§   ³               Collateral               ³   Proceeds   ³ G D ³ R V ³ Term ³ Term ³ Rate³ Amortization ³      Amount     ³      Balance    ³
          ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

          ACA FOODS, INC.
       ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿'
       ³                ³                                        ³                                        ³                  ³     ³     ³ Orig. ³ Rem.  ³ True³   Monthly      ³      Credit      ³   Outstanding    ³Execution³'
       ³   Account N§   ³              Account Name              ³               Collateral               ³     Proceeds     ³ G D ³ R V ³ Term  ³ Term  ³ Rate³ Amortization   ³      Amount      ³     Balance      ³  Date   ³'
       ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÙ'
                                                                                                                                          999 mo. 999 mo. 99.99  999,999,999.99  999,999,999,999.99 999,999,999,999.99 99/99/9999
                                                                                                            ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
                                                             Grand-Total ¯          2,287,000.00                                     105,405.00      2,529,720.00        674,963.00
123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345
         1         2         3         4         5         6         7         8         9         0         1          2        3         4         5         6         7         8         9         0         1         2
                                                                     999,999,999.99              xxx m xxx m        999,999,999.99    999,999,999.99    999,999,999.99
           18-181-08        TWO UNITS FRYMASTER GAS FRYER                380,000.00 15.00  5.00   24 m  13 m  20.50      17,514.00        420,336.00         87,575.00
           18-181-09        1 UNIT MANITOWOC ICE CUBE MACHINE            167,000.00 15.00  5.00   24 m  14 m  20.50       7,697.00        184,728.00         38,490.00
           18-181-06        1 UNIT NIECO CHARBROILER                     550,000.00 15.00  5.00   24 m  14 m  20.50      25,349.00        608,376.00        151,740.00
           18-181-07        1 UNIT LOT WALK-IN FREEZER/CHILLER           890,000.00 15.00  5.00   24 m  15 m  20.50      41,018.00        984,432.00        286,942.00
           18-181-010       4 UNITS OMRON CASH REGISTER, RS4540          300,000.00 15.00  5.00   24 m  16 m  20.50      13,827.00        331,848.00        110,216.00
                                                                   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ                                ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
                                                Grand-Total ¯          2,287,000.00                                     105,405.00      2,529,720.00        674,963.00
                                                                   ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ                                ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
                                                                  99,999,999,999.99                              99,999,999,999.99 99,999,999,999.99
*/
*-------------------------------------------------------------------------------


STATIC FUNCTION SCREEN(cMCD)           && RED 033005
LOCAL aACCTS := {}
LOCAL aACCTS2:= {}
LOCAL nIDX   := 0
LOCAL SCR    := SAVESCREEN(15,26,19,75), cbrcode:= g_par_brch
acctmast->(dbsetorder(3))
IF ACCTMAST->(DBSEEK(RTRIM(cbrcode+cMCD)))
   DO WHILE cbrcode+ACCTMAST->ACCTNAME = RTRIM(cbrcode+cMCD) .AND. CBRCODE == ACCTMAST->BRCODE

     /* IF ACCTMAST->BRCODE == g_PAR_BRCH .AND.;
         ASCAN(aACCTS,RTRIM(ACCTMAST->ACCTNAME)) = 0
         AADD(aACCTS,ACCTMAST->ACCTNAME)
      ENDIF*/
	  
      IF ACCTMAST->BRCODE == g_PAR_BRCH .AND.;
         ASCAN(aACCTS,RTRIM(rtrim(ACCTMAST->ACCTNAME)+' '+tran(ACCTMAST->CLNTCODE,'@R 99-99999'))) = 0 //ASCAN(aACCTS,RTRIM(ACCTMAST->ACCTNAME)) = 0
         AADD(aACCTS,rtrim(ACCTMAST->ACCTNAME)+' '+tran(ACCTMAST->CLNTCODE,'@R 99-99999')) //AADD(aACCTS,ACCTMAST->ACCTNAME)
		 AADD(aACCTS2,ACCTMAST->ACCTNAME)
      ENDIF	  
	  
	  

      ACCTMAST->(DBSKIP())
   ENDDO

   IF LEN(aACCTS) > 1
      nIDX := ACHOICE(15,26,19,75,aACCTS)
      RESTSCREEN(15,26,19,75,SCR)

      IF LASTKEY() == K_ENTER
         cMCD := aACCTS2[nIDX]
      ELSE
         cMCD := SPACE(50)
      ENDIF
   ELSEIF LEN(aACCTS) = 1
          cMCD := aACCTS2[1]
   ELSE
      ERROR('Client name not found.')
      cMCD := SPACE(50)
   ENDIF
ENDIF

RETURN




/*STATIC FUNCTION SCREEN(cMCD)           && RED 033005
LOCAL aACCTS := {}
LOCAL  aACCTS2:= {}
LOCAL nIDX   := 0
LOCAL SCR    := SAVESCREEN(15,26,19,78), cbrcode:= g_par_brch
acctmast->(dbsetorder(3))
IF CLIENT->(DBSEEK(RTRIM(cbrcode+cMCD))) //ACCTMAST->(DBSEEK(RTRIM(cbrcode+cMCD)))
   DO WHILE cbrcode+CLIENT->FULLNAME = RTRIM(cbrcode+cMCD) .AND. CBRCODE == CLIENT->BRCODE //cbrcode+ACCTMAST->ACCTNAME = RTRIM(cbrcode+cMCD) .AND. !ACCTMAST->(EOF())

      IF CLIENT->BRCODE == g_PAR_BRCH .AND.;
         ASCAN(aACCTS,RTRIM(rtrim(CLIENT->FULLNAME)+' '+tran(CLIENT->CLNTCODE,'@R 99-99999'))) = 0 //ASCAN(aACCTS,RTRIM(ACCTMAST->ACCTNAME)) = 0
         AADD(aACCTS,rtrim(CLIENT->FULLNAME)+' '+tran(CLIENT->CLNTCODE,'@R 99-99999')) //AADD(aACCTS,ACCTMAST->ACCTNAME)
		 AADD(aACCTS2,CLIENT->FULLNAME)
      ENDIF

      CLIENT->(DBSKIP())
   ENDDO

   IF LEN(aACCTS) > 1
      nIDX := ACHOICE(15,26,19,78,aACCTS)
      RESTSCREEN(15,26,19,78,SCR)

      IF LASTKEY() == K_ENTER
         cMCD := aACCTS2[nIDX]
      ELSE
         cMCD := SPACE(50)
      ENDIF
   ELSEIF LEN(aACCTS) = 1
          cMCD := aACCTS2[1]
   ELSE
      ERROR('Client name not found.')
      cMCD := SPACE(50)
   ENDIF
ENDIF

RETURN
*/