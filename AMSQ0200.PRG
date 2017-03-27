/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   program idúúú amsq0200.prg                                                 ³
³   descriptionúú vehicles for registration renewal                            ³
³   authorúúúúúúú renan s. evangelista                                         ³
³   dateúúúúúúúúú 9:20:am úú 07-12-96                                          ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                             u p d a t e s                                    ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        who        ³       when        ³               why                    ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ janet l. bautista ³    03-Jun-1998    ³ display old acct no                  ³
³Engr.Michael Espina³    24-Mar-1999    ³ display should be alphabetical       ³
³ janet b. salvador ³    17-Feb-2004    ³ lengthen account name display        ³
³                   ³                   ³ to show accenture accounts           ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

////
#include 'inkey.ch'
#include 'colf.ch'
#include 'dbstruct.ch'
////
#defi K_SPACEBAR   32

memvar  AX_LEVEL, gUSER_ID
setcursor(0)
setblink(.t.)
if chkpass( procname(), AX_LEVEL, gUSER_ID )
   begin sequence
	 qOpen1000()
         qMainmode()
   end sequence
   dbcloseall()
endif
__mrelease( '*', .t. )
return nil
/*--------------------------*/
 Static Function qMainmode()
/*--------------------------*/
//PRIVATE cBRCODES := ACC_BRCH(g_USER_ID)
private eplate:=' '

eplate:= if( month(gTrandate) > 9, '0',alltrim(str(month(gTrandate))) )
setcursor(1)
fshadow(09,7,11,30,2, 'n/w')
@ 10,8 say 'Plate No. Ending  ' get eplate picture '9' valid !empty(eplate)
read
setcursor(0)
if lastkey() <> K_ESC
   *reportprint('qqqPrn0200()')
   REPCON_OL('QQQPRN0200()',,,,,,EPLATE+'~'+DTOC(gTRANDATE),.T.)
endif
return nil

/*-------------------*/
 Function qqqPrn0200()
/*-------------------*/
local pgn:=1,sw:=.t.,nwpg:= .f.
local xacctn := 'XXXXXXXXXXXXXX' ,linda3

dbselectarea('Acctmast')
dbsetorder(2)
dbgotop()
Head_qprn(pgn)

while Acctmast->(!eof())
   sw:=if(CTRLINFO->BRCODE+Ctrlinfo->Acctno <> xacctn,.t., sw )
   linda3:=ACCTMAST->BRCODE+Acctmast->acctno
   dbselectarea('ctrlinfo')
   dbsetorder(1)
   Ctrlinfo->(dbseek(linda3))

   Do while linda3 = CTRLINFO->BRCODE+ctrlinfo->acctno   //.and. substr( alltrim(Ctrlinfo->Plateno),-1,1) == eplate  .and. !eof()
      //IF CTRLINFO->BRCODE $ (cBRCODES)
	  IF AXBRANCH->(DBSEEK(g_USER_ID+CTRLINFO->BRCODE))
         if prow() > 54
            __eject()
            pgn++
            head_qprn(pgn)
            nwpg:= .t.
         endif

         if substr( alltrim(Ctrlinfo->Plateno),-1,1) == eplate .AND. acctmast->osbal > 0
            @ prow()+1,1 say CTRLINFO->BRCODE+substr(Ctrlinfo->Acctno,-5,5) PICT '@R 999-99999'
            @ PROW() , 11 SAY Acctmast->Acctname  // substr(Acctmast->Acctname,1,20)
            @ prow() , 28+30+5 say substr( Ctrlinfo->Coltype,1,27)
            @ prow() , 56+30+5 say substr( Ctrlinfo->Colmodel,1,10)
            @ prow() , 68+30+5 say substr( Ctrlinfo->Motorno,1,20)
            @ prow() , 89+30+5 say substr( Ctrlinfo->Serialno,1,20)
            @ prow() , 110+30+5 say substr(Ctrlinfo->Plateno,1,15)
            @ prow() , 126+30+5 say repl('_',18)
            @ prow() , 145+30+5 say ACCTMAST->OLDNO
         endif
      ENDIF
      xacctn := CTRLINFO->BRCODE+Ctrlinfo->Acctno
      Ctrlinfo->(dbskip())
   Enddo
   Acctmast->(dbskip())
Enddo
__eject()
return nil

/*---------------------------*/
 Static function Head_qprn( pgn )
/*---------------------------*/
local nmo_  := { 'January','February','March','April','May','June', 'July','August','September','October' }
local xdate 
local ndex  := if( val(eplate) > 0, val(eplate), 10 )
xdate := nmo_[ ndex ] + ' ' + str( year( gTrandate ),4 )
setprc(0,0)
setfont('DRAFT')
setfont('ELITE')
@ prow()+1,01 say 'ACCOUNT MANAGEMENT SYSTEM'
@ prow(),  01+len('ACCOUNT MANAGEMENT SYSTEM');
              say PADL('Page No. ' + tran(pgn,'999'),96-len('ACCOUNT MANAGEMENT SYSTEM'))
@ prow()+1,01 say 'AMSQ0200'
@ prow()  ,01+len('AMSQ9999');
              say PADL( dtoc(DATE())+' '+TIME(), 96-len('AMSQ1000'))
@ prow()+1,01 say PADC('ORIX METRO LEASING AND FINANCE CORPORATION',96)
SETFONT('BOLD')
@ prow()+1,01 say padc('LIST OF MOTOR VEHICLES FOR RENEWAL',96)
SETFONT('UNBOLD')
@ prow()+1,01 say padc('For the Month of '+ xdate,96)
@ prow()+1,01 say ''
setfont('ELITE')
SETFONT('CONDENSED')
@prow()+1,1 say '------------------------------------------------------------- --------------------------- ----------- -------------------- -------------------- --------------- ------------------ ----------------'
@prow()+1,1 say 'Account Number/Name                                           Type of Vehicle             Model       Motor Number         Serial Number        Plate Number    Remarks            LA Number       '
@prow()+1,1 say '------------------------------------------------------------- --------------------------- ----------- -------------------- -------------------- --------------- ------------------ ----------------'

RETURN NIL

/*--------------------------*/
  Static Function Qopen1000()
/*--------------------------*/

if !netuse( '&g_grf_path'+'\Axbranch.dbf',.f.,5)
   return .f.
endif
set index to &g_grf_path\Axbranch
   
if !netuse('&g_AMS_PATH\Acctmast',.f.,5)
   break
else
   set index to &g_AMS_PATH\Acctmast,&g_AMS_PATH\Acctacno
endif

if !netuse('&g_AMS_PATH\Ctrlinfo',.f.,5)
   break
else
   set index to &g_AMS_PATH\Ctrlinfo
endif

if !netuse( '&g_AMS_PATH\Flag', .f., 5 )
   break
endif

if !netuse( '&g_Cis_path\Client', .f., 10 )               && Client file
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_Cis_path\Clienm' )                    && set index on Fullname
endif

return nil
/*

         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7
12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
-------------------------------------  ------------------------------  -----------  --------------------  --------------------  ---------------  ------------------
Account Number/Name                    Type of Vehicle                 Model        Motor Number          Serial Number         Plate Number                Remarks
-------------------------------------  ------------------------------  -----------  --------------------  --------------------  ---------------  ------------------
99999-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXX

-------------------------- --------------------------- ----------- -------------------- -------------------- --------------- ------------------ ----------------
Account Number/Name        Type of Vehicle             Model       Motor Number         Serial Number        Plate Number    Remarks            LA Number       
-------------------------- --------------------------- ----------- -------------------- -------------------- --------------- ------------------ ----------------
99999 XXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXX XXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXX

-------------------------------------------------------- --------------------------- ----------- -------------------- -------------------- --------------- ------------------ ----------------
Account Number/Name                                      Type of Vehicle             Model       Motor Number         Serial Number        Plate Number    Remarks            LA Number       
-------------------------------------------------------- --------------------------- ----------- -------------------- -------------------- --------------- ------------------ ----------------
99999 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXX XXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXX

         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7
12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890

*/
