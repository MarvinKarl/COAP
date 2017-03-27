/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   PROGRAM ID.........:  amsq0150.prg                                         ³
³   Description........:  accounts masterlist by Client Code                   ³
³   Author.............:  Chi O. Mendoza                                       ³
³   Date...............:  02:13pm 18-Oct-2007                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                         U P D A T E S                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        Who        ³     When      ³               Why                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                                                                              ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include 'INKEY.CH'
#include 'COLF.CH'

#define NIRVANE tone( 480, 0.25 ); tone( 240, 0.25 )

local WATER

if chkpass ( procname(), AX_LEVEL, gUSER_ID )
   nosnow  ( .t. )
   begin sequence
      fopen0150 ()
      fmain0150 ()
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
   static function fMAIN0150()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local sv, WATER
   local menulist 
   priva _x := -1
   

   priva total_princ := total_amort := total_creda := total_osbal := 0
   priva grand_princ := grand_amort := grand_creda := grand_osbal := 0
   priva con, gnam, mpage := 1 ,xClntcode, ac_code := 'piañ'
   private linclude_sold, mbrcode  := g_PAR_BRCH


   savescreen( ,,, sv )
	fDone0150()
   restscreen( ,,,, sv )
   close all  
   return( nil )


// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function fDone0150()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local msv
   priva sw:=1, cnt := inc := 0, ind := 1, on, off := 0
   msv := savescreen( ,,, )
   if get_acctno()
       if lastkey() == K_ESC
		return
	endif
	reportprint('fprnt0150()')    //aga
      *repcon_ol( 'fPrnt0150()', '132 COLUMN',,,,,,.F. )
      inkey( .5 )   
   endif
   restscreen( ,,,, msv )
   return( nil )

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   function fPrnt0150()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local ax,mu:=Acctmast->(indexord()),old_code:= ' '
   memva grand_princ, grand_amort, grand_creda, grand_osbal
   memva con, sw, _x, cnt, off
   private clcnt:= 1,nwpage := .f.,ac_name
   dbsetorder(2)
   ac_name:=acctmast->acctname
   old_code := Acctmast->Clntcode
   ac_code  := if(empty(old_code),spac(7),alltrim(old_code))
   set device to screen
   ax := savescreen( 7, 1, 20, 36 )
   set device to printer   
   fHead0150()
	do while !acctmast->(eof()) .and. acctmast->clntcode == ac_code
		fDisp0150(@old_code)
		acctmast->(dbskip())	
	enddo
      fEjec0150()
      @ prow() + 1,  72 say repl( 'Ä', 16 )
      @ prow()    , 120 say repl( 'Ä', 15 )
      @ prow()    , 136 say repl( 'Ä', 17 )
      @ prow()    , 154 say repl( 'Ä', 17 )
      fEjec0150()
      @ prow() + 1,  53 say 'Grand-Total ¯'
      @ prow()    ,  71 say grand_princ picture '99,999,999,999.99'
      @ prow()    , 118 say grand_amort picture '99,999,999,999.99'
      @ prow()    , 136 say grand_creda picture '99,999,999,999.99'
      @ prow()    , 154 say grand_osbal picture '99,999,999,999.99'
      @ prow() + 1,  72 say repl( 'Í', 16 )
      @ prow()    , 120 say repl( 'Í', 15 )
      @ prow()    , 136 say repl( 'Í', 17 )
      @ prow()    , 154 say repl( 'Í', 17 )
   __eject()
   set device to screen
   inkey( .5 )
   restscreen( 7, 1, 20, 36, ax )
   acctmast->(dbsetorder(mu))
   return( .t. )

**************************************
*
static function fDisp0150 ( old_code )
**************************************
   local row := 1,prntname:= .f., gdamt, rvamt
   memva total_princ, total_amort, total_creda, total_osbal
   memva grand_princ, grand_amort, grand_creda, grand_osbal
   memva sw, cnt, ind, inc, on, ac_code, _x
   
   if Acctmast->status == '0'           // CANCELLED RLV 08/18/2010
        return nil
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
         fSubt0150()
         fEjec0150()
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

   fEjec0150()
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

      @ prow() + row,  5  say       ACCTMAST->BRCODE+substr(Acctmast->acctno,-5,5) PICT '@R 999-99999'
      @ prow()      ,  15 say       left(alltrim(Acctmast->oldno),16)
      @ prow()      ,  33 say       Acctmast->unit           picture '@!'
      @ prow()      ,  74 say       Acctmast->principal      picture '999,999,999.99'
      @ prow()      ,  89 say       gdamt             picture '99.99'
      @ prow()      ,  96 say       rvamt             picture '99.99'
      @ prow()      , 102 say       Acctmast->term           picture '999'
      @ prow()      , 106 say       if(ALLTRIM(Acctmast->Termunit) == '2','m','d' )
      @ prow()      , 108 say       if(ALLTRIM(Acctmast->Termunit) == '2',Acctmast->remterm,0 )   picture '@Z 999'
      @ prow()      , 112 say       if(ALLTRIM(Acctmast->Termunit) == '2','m',' ')
      @ prow()      , 115 say       Acctmast->truerate       picture '99.99'
      @ prow()      , 121 say       Acctmast->amort          picture '999,999,999.99'
      @ prow()      , 139 say       Acctmast->credamt        picture '999,999,999.99'
      @ prow()      , 157 say       Acctmast->osbal          picture '999,999,999.99'
      @ prow()      , 172 say       Acctmast->Valdate        picture '@D'

   return( nil )

******************************
   static function fSubt0150()
******************************

   memva total_princ, total_amort, total_creda, total_osbal

   fEjec0150()
   @ prow() + 1, 112 say repl( 'Ä', 18 )
   @ prow()    , 171 say repl( 'Ä', 18 )
   @ prow()    , 190 say repl( 'Ä', 18 )
   @ prow()    , 209 say repl( 'Ä', 18 )
   fEjec0150()
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

******************************
   static function fHead0150()
******************************
   memvar mpage, gSYS_NAME, gCOMPANY, nwpage


     setfont( upper( 'init' ) )
     prnreptitle( 102, 5, mpage++, 'ACCOUNTS MASTERLIST', 'AMSQ0150', gSYS_NAME, gCOMPANY )
     setfont( upper( 'uncondensd' ) )
     @ prow() + 1, ( 102 - 16 ) / 2 say 'As of ' + dtoc( Flag->lastclosed )
     setfont( upper( 'condensed' ) )
     @ prow()+1,1 say '   ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿'
     @ prow()+1,1 say '   ³  New    ³      Old       ³                                        ³              ³     ³     ³ Orig ³ Rem  ³ True³   Monthly    ³      Credit     ³    Outstanding  ³Execution³'
     @ prow()+1,1 say '   ³ Acctno  ³   Account N§   ³               Collateral               ³   Proceeds   ³ G D ³ R V ³ Term ³ Term ³ Rate³ Amortization ³      Amount     ³      Balance    ³   Date  ³'
     @ prow()+1,1 say '   ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÙ'
     @ prow()+1,1 say ' '                                                                                                                                                                     
     @ prow()+1,5 say ac_name
     @ prow()+1,1 say ' '
   return( nil )

******************************
   static function fEjec0150()
******************************
   memvar _x
     if prow() >= 42
        __eject()
        fHead0150()
     endif
   return( .t. )

*******************************
   static function get_acctno()
*******************************


   local mretval := .f., mCOLOR := setcolor(), mscr := savescreen ( ,,, )
   local getlist := {}, mCURSOR := setcursor( setcursor() )
   LOCAL tBR := mbrcode+'-', mclientcod := space( 7 ) 
memva _x   
   setcursor( 0 )
   tones()
   fshadow( 10, 21, 12, 48, 2, 'n/w' )
   setcolor( 'bg+/w, w+/n,,, gr+/w' )

   @ 11,23 say 'Client Code  '
   @ 11,35 GET tBR WHEN .F.
   @ 11,39 get mclientcod pict '@K 99999999' valid  chk_acctno( @mclientcod, @mretval, mbrcode )
	mretval := .t.
   setcursor( 3 )
	setkey( K_ESC, { || fEscape( 'Abort?' ) } )
   read &&timeout 20 exitevent blankscr3( -1 )
   setkey( K_ESC, nil )
  setcursor( 0 )
   setcursor( mCURSOR )
   setcolor( mCOLOR )
   restscreen( ,,,, mscr )

return mretval


*******************************************************
static function chk_acctno(mclientcod, mretval,mbrcode)
*******************************************************
local mod_t:='acct_fnc', ckey:=space(10),cbrcode:= g_PAR_BRCH
local headr:='    Client Code                          Branch     Account N§    '
Acctmast->(dbsetorder(2))
if mclientcod == space(7)
	ERROR('Please Enter the Client Code')
	return .f.
else
	if acctmast->(dbseek(mbrcode+mclientcod))
		return .t.
	else
		error('Client Code not found ')
		 mclientcod := space( 7 )
		return .f.
	endif
endif 
	
  
******************************
   static function fOutp0150()
******************************
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

******************************
   static function fOPEN0150()
******************************
   local WATER := !.f.

   if !netuse( '&g_AMS_PATH\Flag', .f., 10 )               && flag
      break WATER
   endif

   if !netuse( '&g_AMS_PATH\Acctmast', .f., 10 )           && account master
      break WATER
   else 
      if !.f.; ordlistclear(); endif
      //ordlistadd( 'Acctacno' )                 && set index acctname + acctno
      set index to &g_AMS_PATH\Acctacno, &g_AMS_PATH\Acctclnt, &g_AMS_PATH\Acctmatd
      dbsetorder(2)
   endif
   return( nil )

// Eop: AMSQ0150.prg //

