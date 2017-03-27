/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   colf-iis -- account management system                                      ³
³   program idúúú amsr4000                                                     ³
³   descriptionúú Accounts for Review/repricing                                ³
³   authorúúúúúúú renan s. evangelista                                         ³
³   dateúúúúúúúúú 9:20:am úú 07-26-96                                          ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                             u p d a t e s                                    ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        who        ³       when        ³               why                    ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ janet b. salvador ³    07-feb-2001    ³ include records not yet reviewed     ³
³                   ³                   ³ (revdate <= report date)             ³
³ abb               ³ 09-may-2001 11:30a³ per company(fmlfc,pbc,orix accts.    ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

////
#include 'inkey.ch'
#include 'colf.ch'
#include 'dbstruct.ch'
////
#defi K_SPACEBAR   32
#defi microfeed    chr( 27 ) + 'J' + chr( 18 )

memvar  AX_LEVEL, gUSER_ID
private nchoice

setcursor(0)
setblink(.t.)
if !chkpass( procname(), AX_LEVEL, gUSER_ID )
   //NOTHING WILL HAPPEN
else
   begin sequence
         aOpen1111()
         _comp_menu()
         aMain9999()
   end sequence
   dbcloseall()
endif
__mrelease( '*', .t. )
return nil
/*-------------------------*/
 Static Function aOpen1111()
/*-------------------------*/

if !netuse( '&g_AMS_PATH\Acctmast', .f., 10 )              && Account master file
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_AMS_PATH\Acctacno' )                    && set index on acctname
endif
return nil
/*-------------------------*/
 Static Function aMain9999()
/*-------------------------*/
 local mu:=savescreen(,,,),gf:=savedbf(),bf:=setcursor()
 private mmonth := month(gtrandate), myear := year(gtrandate)

 fshadow( 8, 30, 11, 47, 2, 'n/g' )
 while eval ({|| setcursor (3), get_month() })
      mpage := 1
      *repcontrol ('amsr9999print()')
      xSTR := CHK_PAR(nCHOICE)+CHK_PAR(mMONTH)+CHK_PAR(mYEAR)
      REPCON_OL ('AMSR9999PRINT()',,,,,,xSTR,.T.)
 enddo
 restdbf(gf);restscreen(,,,,mu);setcursor(bf)
 return nil
/*-------------------------*/
 Function amsr9999print()
/*-------------------------*/
 local pgn:=1,mmdate:=ctod(str(mmonth,2)+'/01/'+str(myear,4))
 local chkprev:=ctod(iif(mmonth=12,'01',str(mmonth+1))+'/01/'+iif(mmonth=12,str(myear+1),str(myear)))-1
 local xdate:= cmonth(mmdate)+' '+str(myear,4)
 dbselectarea('Acctmast')
 dbsetorder(1)     //acctname
 setfont('PICA')
 head_amsr9999(pgn,xdate)
 while !eof()
       IF BRCODE == g_PAR_BRCH
          if prow() > 53
             __eject()
             pgn++
             Head_amsr9999(pgn,xdate)

          endif

      //    if (month(Acctmast->Revdate) <= mmonth .and. ;
      //       year(Acctmast->Revdate) <= myear .and. Acctmast->Osbal > 0)

          if Acctmast->Revdate <= chkprev .and. ;
             Acctmast->Osbal   > 0        .and. ;
             Acctmast->Ratetype == '2'    .and. ;
             nchoice == _company_accounts('ACCTMAST')

             @ prow()+1,03 say substr(Acctmast->Acctno,-5,5) +' '+substr(Acctmast->Acctname,1,34)+'  '+                 ;
                               tran(Acctmast->Principal,'999,999,999.99')+'  '+ tran(Acctmast->Truerate,'99.9999')+'  '+;
                               if(!empty(Acctmast->Valdate),dtoc(Acctmast->valdate),spac(10) )+'  '+                    ;
                               if(!empty(Acctmast->matdate),dtoc(Acctmast->matdate),spac(10) )+'  '+                    ;
                               if(!empty(Acctmast->revdate),dtoc(Acctmast->revdate),spac(10) )+'  '+                    ;
                               tran(Acctmast->Amort,'999,999,999.99')+'  '+tran(Acctmast->Osbal,'999,999,999.99')
          endif
       ENDIF
     dbskip()
 enddo

 __eject()
 SETFONT('UNCONDENSD')
 SETFONT('NORMAL')
 return nil
/*--------------------------------------*/
 Static function Head_amsr9999(pgn,xdate)
/*--------------------------------------*/
setfont('NLQ')
setfont('ELITE')
SETFONT('UNCONDENSD')
setprc(0,0)
@ prow()+1,02 say 'ACCOUNT MANAGEMENT SYSTEM'
@ prow(),  02+len('ACCOUNT MANAGEMENT SYSTEM');
              say PADL('Page No. ' + tran(pgn,'999'),95-len('ACCOUNT MANAGEMENT SYSTEM'))
@ prow()+1,02 say 'AMSR9999'
@ prow()  ,02+len('AMSQ9999');
              say PADL( dtoc(DATE())+' '+TIME(), 95-len('AMSQ1000'))

@ prow()+1,02 say PADC('ORIX METRO LEASING AND FINANCE CORPORATION',95)
@ prow()+1,02 say padc('LIST OF ACCOUNTS FOR REVIEW',95)
do case
   case nchoice == 1
      @ prow()+1,02 say padc('FMLFC ACCOUNTS',95)
   case nchoice == 2
      @ prow()+1,02 say padc('PBC ACCOUNTS',95)
   otherwise
      @ prow()+1,02 say padc('ORIX ACCOUNTS',95)
endcase

@ prow()+1,02 say padc('For the Month of '+xdate,95)
@ prow()+1,02 say ' '
setfont('DRAFT')
setfont('PICA')
SETFONT('CONDENSED')
@ prow()+1,03 say 'ÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
@ prow()+1,03 say 'Acct         Account Name                  Net Proceeds    True    Value date   Maturity    Review      Amortization    Outstanding  '
@ prow()+1,03 say 'N§                                                         Rate                   Date       Date                         Balance    '
@ prow()+1,03 say 'ÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
return nil

/*------------------------*/
 Static function get_month()
/*------------------------*/
   local mretval := .t., getlist := {}, mcolor := setcolor(),sw:=0
   memvar mmonth, myear
   setcolor( 'n/g,w+/n,,, w+/g' )
   @  8, 31 say 'Transaction Date'                color 'w+/g'
   @  9, 32 say 'Month '
   @ 10, 32 say ' Year '
   @  9, 42 get mmonth pict '99'   when  select_month( @mmonth, @sw )
   @ 10, 41 get myear  pict '9999' when  lastkey() <> K_ESC valid myear > 1970
   read
   setcolor( mcolor )
return lastkey() != K_ESC
/*------------------------------------*/
 static function select_month ( mmonth,sw )
/*------------------------------------*/
WHILE .T.
  eval( { | x, y, z | x := setcolor(), y := savescreen( ,,, ),;
                          fshadow( 9, 46, 18, 56, 2, 'w/gr' ),;
                          devpos( 10, 49 ), devout( 'Month', 'bg+/gr' ),;
                          devpos( 11, 46 ) , devout( 'ÃÄÄÄÄÄÄÄÄÄ´', 'w/gr' ),;
                          setcolor( 'w/gr, w+/n,,, n/gr' ),;
                          z := achoice( 12, 47, 17, 55,;
                               { 'January', 'February', 'March', 'April',;
                                 'May', 'June', 'July', 'August', 'September',;
                                 'October', 'November', 'December' },,, mmonth ) ,;
                          setcolor( x ), restscreen( ,,,, y ), mmonth := if( z == 0, mmonth, z ), .f. } )
  IF LASTKEY() <> K_RIGHT .AND. LASTKEY() <> K_LEFT
     EXIT
  ENDIF
ENDDO
RETURN .F.
********************************
*
static function _comp_menu()
********************************
   local mscr := savescreen (,,,)
   local menulist, mcolor := setcolor()

   nchoice := 0

   set color to 'w/n'
   @ 10,30 clear to 18,50
   @ 10,30 to 18,50 double
   @ 12,33 prompt 'FMLC Accounts '
   @ 14,33 prompt 'PBC  Accounts '
   @ 16,33 prompt 'ORIX Accounts '
   menu to nchoice

   setcolor(mcolor)
   restscreen ( ,,,, mscr )
return nil

/*
************************************
*
static function _company_accounts()
************************************
   local cretval := 3        // 1-metro,2-pbc,3-orix

   if nchoice == 0
      cretval := 0
   else
      do case
         case substr(alltrim(Acctmast->acctno),1,4) == '9907'    // METRO
            cretval := 1

         case substr(alltrim(Acctmast->acctno),1,4) == '9908'    // PBC
            cretval := 2

      endcase
   endif

return cretval
*/
/*       1         2         3         4         5         6         7         8         9         0         1         2         3         4
12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
 ÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 Acct         Account Name                  Net Proceeds    True    Value date   Maturity    Review      Amortization    Outstanding
 N§                                                         Rate                   Date       Date                         Balance
 ÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 99999 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  999,999,999.99  99.9999  99/99/9999  99/99/9999  99/99/9999  999,999,999.99  999,999,999.99


 Account Number/Name : 
 Received by         : AAAAAAAAAAAAAAAA X. BBBBBBBBBBBBBBBBBBBB
*/
