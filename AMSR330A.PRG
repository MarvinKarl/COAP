/*
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё   program idЗЗЗ amsr330a                                                     Ё
Ё   descriptionЗЗ Printing of Expiring Insurance Policies (SIBI)               Ё
Ё   authorЗЗЗЗЗЗЗ Engr. Michael B. Espina                                      Ё
Ё   dateЗЗЗЗЗЗЗЗЗ 9:45:24З89am ЗЗ 01-18-2000                                   Ё
цдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё                             u p d a t e s                                    Ё
цдддддддддддддддддддбдддддддддддддбдддддддддддддддддддддддддддддддддддддддддддд╢
Ё        who        Ё     when    Ё                  why                       Ё
цдддддддддддддддддддедддддддддддддедддддддддддддддддддддддддддддддддддддддддддд╢
Ё                   Ё             Ё                                            Ё
юдддддддддддддддддддадддддддддддддадддддддддддддддддддддддддддддддддддддддддддды
*/

////
#include 'inkey.ch'
#include 'colf.ch'
#include 'dbstruct.ch'
////
#defi K_SPACEBAR   32
#defi microfeed    chr( 27 ) + 'J' + chr( 18 )

memvar  AX_LEVEL, gUSER_ID
setcursor(0)

if chkpass( procname(), AX_LEVEL, gUSER_ID )
   begin sequence
         aOpen330a()
         aMain330a()
   end sequence
   dbcloseall()
endif
__mrelease( '*', .t. )
return nil

/*-------------------------*/
 Static Function aMain330a()
/*-------------------------*/
 local mu:=savescreen(,,,),gf:=savedbf(),bf:=setcursor()
 private mmonth := month(gtrandate), myear := year(gtrandate)

 fshadow( 8, 30, 11, 47, 2, 'n/g' )
 while eval ({|| setcursor (3), get_month() })
      *repcontrol ('amsprn330a()')
      xSTR := CHK_PAR(mMONTH) + CHK_PAR(mYEAR)
      REPCON_OL ('amsprn330a()',,,,,,xSTR,.T.)
 enddo
 * restdbf(gf);restscreen(,,,,mu);setcursor(bf)             && RED 051605
 return nil

/* This module is loving dedicated to Ms. linda */

/*--------------------*/
 Function amsprn330a()
/*--------------------*/
 local pgn:=1,xdate := cmonth( ctod(str(mmonth,2)+'/01/'+str(myear,4) )) +' '+str(myear,4)
 local linda5,insured_by:=' '
 Headinc(pgn,xdate)
 dbselectarea('Acctmast')
 dbsetorder(2)
 dbgotop()

 while Acctmast->(!eof())
   linda5:=ACCTMAST->BRCODE+Acctmast->acctno
   dbselectarea('ctrlinfo')
   dbsetorder(1)
   Ctrlinfo->(dbseek(linda5))

   Do while linda5 = CTRLINFO->BRCODE+ctrlinfo->acctno

       if prow() > 52
          __eject()
          pgn++
          SETFONT('UNCONDENSD')
          Headinc(pgn,xdate)
       endif

       if !empty( Ctrlinfo->Insexpry) .and. month(Ctrlinfo->Insexpry) = mmonth ;
          .and. year(Ctrlinfo->Insexpry) = myear .and. Acctmast->OSBAL > 0 .and. ;
          alltrim(ctrlinfo->insby) == '1'
             Insuranc->( dbseek(CTRLINFO->BRCODE+Ctrlinfo->Insco, .f.) )
             @ prow()+1,01 say if(Acctmast->STATUS<>'1','*',' ')
             @ prow()  ,03 say ACCTMAST->BRCODE+'-'+substr( Acctmast->Acctno,-5,5 )
             @ prow()  ,10+4 say substr(Acctmast->Acctname,1,29)
             Client->(dbseek(ACCTMAST->BRCODE+acctmast->clntcode))
             @ prow()  ,42+4  say alltrim(client->address1)+alltrim(client->address2)
             @ prow()  ,102+4 say alltrim(client->telno1)
             @ prow()  ,124+4 say substr(ctrlinfo->colmodel,1,4)
             @ prow()  ,132+4 say substr( Ctrlinfo->Coltype,1,29 )
             @ prow(), 163+4 say alltrim(ctrlinfo->plateno) +' / '+ alltrim(Ctrlinfo->motorno) +' / '+ alltrim(ctrlinfo->serialno)
             @ prow(), 210+4 say Dtoc(Ctrlinfo->Insexpry)
             @ prow(), 221+4 say trans(Ctrlinfo->Amtins, '999,999,999.99')
             @ prow(), 235+4 say transform(Ctrlinfo->insprem, '999,999,999.99')
       endif
       Ctrlinfo->(dbskip())
   Enddo
    Acctmast->(dbskip())
 Enddo
 __eject()
 return nil

/*-------------------------*/
 static function aOpen330a()
/*-------------------------*/
memvar gSYS_NAME, gUSER_ID, gTRANDATE, mFMS0700

if !netuse( '&g_AMS_PATH\Acctmast', .f., 10 )              && Account master file
   break
else
   set index to &g_AMS_PATH\Acctmast,;
                &g_AMS_PATH\Acctacno
/*   if !.f.; ordlistclear(); endif
   ordlistadd( 'Acctmast' )                     && set index on acctno
   ordlistadd( 'Acctsub2')                      && set index on substr(acctno,-5,5)
   ordlistadd( 'Acctclnt')
   ordlistadd( 'Acctacno')  */
endif

if !netuse( '&g_AMS_PATH\Ctrlinfo', .f., 10 )              && Insurance information file
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_AMS_PATH\Ctrlinfo' )                    && set index on acctno
endif

if !netuse( '&g_AMS_PATH\Coverage', .f., 10 )              && Insurance Coverage file
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_AMS_PATH\Coverage' )                    && set index on covercode
endif

if !netuse( '&g_AMS_PATH\Inslog', .f., 10 )              && Insurance Login file
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_AMS_PATH\Inslog' )                    && set index on Acctno
endif

if !NETUSE('&g_CIS_PATH'+'\INSURANC',.f.,5)   && Insurance file
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_CIS_PATH\INSCODE' )                  && set index on ornumber
endif

if !NETUSE('&g_CIS_PATH'+'\CLIENT',.f.,5)   && CLIENT MASTER file
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_CIS_PATH\CLIECD' )                     && set index on clntcode
   ordlistadd( '&g_CIS_PATH\CLIENM' )                     && set index on Fullname
endif
/*
/*------------------------*/
 Static function get_month()
/*------------------------*/
   local mretval := .t., getlist := {}, mcolor := setcolor()
   memvar mmonth, myear
   setcolor( 'n/g,w+/n,,, w+/g' )
   @  8, 31 say 'Transaction Date'                color 'w+/g'
   @  9, 32 say 'Month '
   @ 10, 32 say ' Year '
   @  9, 42 get mmonth pict '99'   when  select_month( @mmonth, 9, 46, 18, 56 )
   @ 10, 41 get myear  pict '9999' valid myear > 1970
   read
   setcolor( mcolor )
return lastkey() != K_ESC
*/
/*-----------------------------------*/
 STatic Function Headinc(pgn,xdate)
/*-----------------------------------*/

setprc(0,0)
setfont('DRAFT')
setfont('ELITE')
@ prow()+1,03 say 'ACCOUNT MANAGEMENT SYSTEM'
@ prow(),  03+len('ACCOUNT MANAGEMENT SYSTEM');
              say PADL('Page No. ' + tran(pgn,'999'),157-len('ACCOUNT MANAGEMENT SYSTEM'))
@ prow()+1,03 say 'AMSR330a'
@ prow()  ,03+len('AMSR330a');
              say PADL( dtoc(DATE())+' '+TIME(), 157-len('AMSR330a'))
@ prow()+1,03 say PADC('ORIX METRO LEASING AND FINANCE CORPORATION',157)
SETFONT('BOLD')
@ prow()+1,03 say padc('LIST OF EXPIRING INSURANCE POLICIES (SIBI)',157)
SETFONT('UNBOLD')
@ prow()+1,03 say padc('For the Month of '+ xdate,157)
@ prow()+1,03 say ''
setfont('ELITE')
SETFONT('CONDENSED')
@ prow()+1,3 say 'ддддддддд дддддддддддддддддддддддддддддд   ддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд дддддддддддддддддддд дддддд   ддддддддддддддддддддддддддддд  дддддддддддддддддддддддддддддддддддддддддддд дддддддддддд дддддддддддддд ддддддддддддд'
@ prow()+1,3 say ' Acct N╖         Account Name                                  Address                                       Tel. No.        Model           Unit                               Plate / Serial                      Expiry         Amount       INSURANCE '
@ prow()+1,3 say '                                                                                                                                                                                   Motor No.                         Date          Insured       PREMIUM'
@ prow()+1,3 say 'ддддддддд дддддддддддддддддддддддддддддд   ддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд дддддддддддддддддддд дддддд   ддддддддддддддддддддддддддддд  дддддддддддддддддддддддддддддддддддддддддддд дддддддддддд дддддддддддддд ддддддддддддд'
/*
/*------------------------------------*/
 static function select_month ( mmonth )
/*------------------------------------*/
return eval( { | x, y, z | x := setcolor(), y := savescreen( ,,, ),;
                          fshadow( 9, 46, 18, 56, 2, 'w/gr' ),;
                          devpos( 10, 49 ), devout( 'Month', 'bg+/gr' ),;
                          devpos( 11, 46 ) , devout( 'цддддддддд╢', 'w/gr' ),;
                          setcolor( 'w/gr, w+/n,,, n/gr' ),;
                          z := achoice( 12, 47, 17, 55,;
                               { 'January', 'February', 'March', 'April',;
                                 'May', 'June', 'July', 'August', 'September',;
                                 'October', 'November', 'December' },,, mmonth ),;
                          setcolor( x ), restscreen( ,,,, y ), mmonth := if( z == 0, mmonth, z ), .f. } )
*/
