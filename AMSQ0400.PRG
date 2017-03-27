/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³  colf-iis --   Account Management System                                     Ã¿
³  descriptionúú Insurance Info Per Account                                    ³Ã¿
³  authorúúúúúúú Engr. Michael B. Espina                                       ³³³
³  dateúúúúúúúúú 4:45:pm úú 02-02-99                                           ³³³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´³³
³        who         ³     when        ³             why                       ³³³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´³³
³                    ³                 ³                                       ³³³
ÀÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ³³
 ÀÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include 'inkey.ch'
#include 'colf.ch'
#include 'dbstruct.ch'
////
#defi K_SPACEBAR   32

memvar  AX_LEVEL, gUSER_ID
public account2xe:= {} ,xgy:=1
setcursor(0)
setblink(.t.)
if chkpass( procname(), AX_LEVEL, gUSER_ID )
   begin sequence
	 qOpen1000()
         mainmode()
   end sequence
   dbcloseall()
endif
__mrelease( '*', .t. )
return nil

/*------------------------*/
 Static Function Mainmode()
/*------------------------*/
local menulist,xchoice
private st
dbselectarea('Acctmast')
Acctmast->(dbsetorder(1))

 st := client1111 ( xchoice )
 if !empty(st)
    acctmast->(dbseek (st) )
    getacct()
    CLIENT->(DBSETORDER(2))
    CLIENT->(DBSEEK(ST))
    reportprint('insprnt()')
    *repcon_ol('insprnt()',,,,,,,.F.)
    CLIENT->(DBSETORDER(1))
 endif
return


********************************
*
static function getacct()
********************************
 local account := {},x,nswitch := 0
 dbselectarea ( 'acctmast' )
 acctmast->   ( dbsetorder(1) )

 x:=1
 Do while ACCTMAST->BRCODE+acctmast->clntcode == st .AND. !acctmast->(eof())

   if (Acctmast->status == '1' .or. Acctmast->status == '6' ) .and. Acctmast->osbal > 0

      aadd ( account,ACCTMAST->BRCODE+acctmast->acctno )

      x++
   endif

   Acctmast->(dbskip(+1))
 Enddo

 dbselectarea ( 'ctrlinfo' )

 for i:=1 to x-1

   waiton ( 'Generating data' )

   if Ctrlinfo->(dbseek(alltrim(account[i])))

       nswitch := 0
                                     //
                                     // added condition by abb 5.15.2001
                                     //

       Do while !Ctrlinfo->(eof()) .and. CTRLINFO->BRCODE+Ctrlinfo->acctno == alltrim(account[i]) // .OR. val(account[i]) < val(ctrlinfo->acctno)
          if ctrlinfo->insured
  
             if nswitch == 0

                aadd ( account2xe, account [i] )

                nswitch := 1
             endif
             ***** account2xe [xgy] := ctrlinfo->acctno

             xgy++
          endif
          Ctrlinfo->(dbskip(+1))

       Enddo

   else
      *******alert ( 'not found := '+ account[i] )
   endif

 Next

/***************************************
 for i := 1 to x
    alert ( str(i,2)+ ' := ' + account2xe[i] )
 next i
 ***************************************/

 waitoff()

return

************************************
*
*
function insprnt()
************************************
local mu  := savedbf(), re := setcursor(), bf:=savescreen (,,,), gf:=setcolor()
local pgn := 1,nacct  , sw := .t.,mikkel,mikkel2,plate,flags:=0

dbselectarea ( 'acctmast' )
acctmast->   ( dbsetorder(2) )
inshead      (pgn)


 i:=1
//  Do while i < xgy
 Do while i <= len(account2xe)

   if i > len(account2xe)       // abb 5.15.2001
      i++
      loop
   endif

   if prow() >= 55
      pgn++
      __eject ( )
      @ prow  ( )+1,0 say ''
      setfont ( 'CONDENSED' )
      inshead ( pgn )
      sw := .t.
   endif

   acctmast->(dbseek(alltrim(account2xe[i])))
   ctrlinfo->(dbseek(alltrim(account2xe[i])))

   do while CTRLINFO->BRCODE+ctrlinfo->acctno == alltrim(account2xe[i]) .and. !ctrlinfo->(eof())

      mikkel := alltrim(acctmast->termunit)

      Do case
        case mikkel == '1'
             mikkel2 := 'days'
        case mikkel == '2'
             mikkel2 := 'months'
        case mikkel == '3'
             mikkel2 := 'years'
      Endcase

       plate := space(10)
       if ctrlinfo->plateno == ' '
          plate := ctrlinfo->motorno
       elseif ctrlinfo->motorno == ' '
          plate := ctrlinfo->serialno
       elseif ctrlinfo->serialno == 'N.A.'
          plate := space(20)
       else
          plate := ctrlinfo->plateno
       endif

       dbselectarea('insuranc')
       insuranc->  (dbsetorder(1))
       nameins := CTRLINFO->BRCODE+ctrlinfo->insco       && RED 062405 ADDED 'CTRLINFO->BRCODE
       insuranc->  (dbseek(nameins))

       @ prow()+1,01 say substr(Acctmast->oldno,1,16)+' '+;
                         transform(ACCTMAST->BRCODE+Acctmast->acctno,'@R 999-9999-99999-99999') + ' '+;
                         dtoc(Acctmast->valdate)+ ' '+ str(Acctmast->term) + ' '+;
                         mikkel2 + ' '+ substr(ctrlinfo->colmodel,1,4)     + ' '+;
                         substr(ctrlinfo->coltype,1,30)+ '  '+;
                         plate

       @ prow(),116+4 say substr(insuranc->insname,1,30)
       @ prow(),148+4 say ctrlinfo->inspolcy
       @ prow(),168+4 say ctrlinfo->insor
       @ prow(),178+4 say dtoc(ctrlinfo->insexpry)
       @ prow(),191+4 say tran(ctrlinfo->amtins,'999,999,999.99')
       @ prow(),209+4 say acctmast->aocode

       ctrlinfo->(dbskip(+1))

    enddo
    i++

Enddo

restdbf(mu);restscreen(,,,,bf);setcursor(re);setcolor(gf)

return nil

Static Function inshead(pgn)
local aname,aname2

setprc(0,0)
setfont('DRAFT')
setfont('ELITE')
@ prow()+1,02 say 'ACCOUNT MANAGEMENT SYSTEM'
@ prow(),  02+len('ACCOUNT MANAGEMENT SYSTEM');
              say PADL('Page No. ' + tran(pgn,'99'),94-len('ACCOUNT MANAGEMENT SYSTEM'))
@ prow()+1,02 say 'AMSQ0400'
@ prow()  ,02+len('AMSQ0400');
              say PADL( dtoc(DATE())+' '+TIME(), 98-len('AMSQ0300'))
@ prow()+1,02 say PADC('ORIX METRO Leasing and Finance Corporation',98)
@ prow()+1,40 say 'INSURANCE INFO PER ACCOUNT'
setfont('ELITE')
SETFONT('CONDENSED')
@ prow()+1,01 say client->fullname
//@ prow()+1,01 say acctmast->aocode
@ prow()+1,00 say ''
@ prow()+1,00 SAY 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄ '
@ prow()+1,00 SAY '  LA. NUMBER          ACCOUNT NO          DATE        TERM   YR              UNIT                     PLATE/MOTOR/              INSURANCE COMPANY           POLICY NUMBER     INSOR     EXPIRY        AMOUNT       ACCOUNT'
@ prow()+1,00 SAY '                                         GRANTED             MOD.                                      SERIAL NO.                                                                        DATE         INSURED      OFFICER'
@ prow()+1,00 SAY 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄ '

return(nil)

/*--------------------------------*/
Static Function client1111(xchoice)
/*--------------------------------*/
local mu:=savedbf(),re:=setcursor(),bf:=savescreen(,,,),gf:=setcolor()
local naccnt:=spac(10),accntnm:=spac(50)
dbselectarea('Acctmast')
dbsetorder(2)
Client->( dbsetorder(1) )
fshadow(15,07,17,36,2,'n/w') && RED 11172004 CHANGED 53 TO 34
set color to 'n/w','w/n',,,'w+/w'
setcursor(3)
setkey( K_ESC, NIL)

@ 16, 08 SAY ' Client Code  ' GET nACCNT PICT '@R 999-99-99999';
                                VALID IF( !EMPTY(RIGHT(nACCNT,7)) .AND. LASTKEY() == K_ENTER,;
                                          IF( VALBRCODE(LEFT(nACCNT,3),g_USER_ID),;
                                              IF( CHECKCLNT(nACCNT), .T., EVAL({|| nACCNT := SPACE(10), .F.}) ),;
                                              EVAL({|| nACCNT := SPACE(10), .F.});
                                            ),;
                                          EVAL({|| nACCNT:=EVAL({ || ach_look() }),;
                                                   IF( LASTKEY() == K_ENTER,;
                                                       IF( VALBRCODE(LEFT(nACCNT,3),g_USER_ID), .T., EVAL({|| nACCNT := SPACE(10),.F.}) ),;
                                                       EVAL({|| nACCNT := SPACE(10),.F.});
                                                     );
                                              });
                                        )
*@ 16,08 say '  Client Name   ';
*        get accntnm pict '@!S25' when !empty(nacct:=eval( { || flook(.t.,'Client',nil,'Account Master File',1,3,2,3) } ) );
*                                 valid lastkey() <> K_ESC .and. !empty(accntnm)  .and. checkclnt(client->clntcode)

setkey( K_ESC, {|| Fescape( 'Abort?') } )
read
setkey( K_ESC, NIL)

*if lastkey() <> K_ESC .and. checkclnt(client->clntcode) /* !empty(nAccnt)*/
*   naccnt := client->clntcode
*endif
restdbf(mu);restscreen(,,,,bf);setcursor(re);setcolor(gf)

return (naccnt)

**********************************************
static function ach_look()
**********************************************
local mod_t:='WCLTYPE', ckey:=space(10)
local headr:='    Client Name                           Branch  Clntcode  Cltype'
   
   main_achoice('CLIENT',3,1,,8,7,21,75,headr,mod_t)
   
  if mpos > 0 .and. lastkey() == K_ENTER .and. !empty(mchoices)
				cKEY := substr( ltrim(mchoices[mpos]),44,3)+substr( ltrim(mchoices[mpos]),50,2)+;
				substr( ltrim(mchoices[mpos]),53,5)
				client->(dbsetorder(1))
				
             if Client->( dbseek (alltrim(cKEY)) )   
                aNRECNO  := Client->(RECNO())
				
            endif		 
	ENDIF 
nrecno:= aNRECNO  
return ckey


/*
/*--------------------------------*/
 Static function checkclnt(xclntcode)
/*--------------------------------*/
local mu:=savedbf(),re:=setcursor(),bf:=savescreen(,,,),gf:=setcolor()
local nval
dbselectarea('Acctmast')
dbsetorder(1)
if dbseek( xclntcode )
   nval := .t.
else
   error('No account found for this client.')
   nval := .f.
endif
restdbf(mu);restscreen(,,,,bf);setcursor(re);setcolor(gf)
return nval
*/
/*------------------------*/
 Static Function Qopen1000()
/*------------------------*/

if !netuse('&g_AMS_PATH\Ctrlinfo',.f.,5)
   break
else
   set index to &g_AMS_PATH\ctrlinfo
endif

if !netuse('&g_AMS_PATH\Acctmast',.f.,5)
   break
else
   set index to &g_AMS_PATH\acctclnt,&g_AMS_PATH\acctmast
endif

if !netuse( '&g_AMS_PATH\Flag', .f., 5 )
   break
endif

if !netuse( '&g_cis_path\Insuranc', .f., 5 )
   break
else
   ordlistadd('&g_cis_path\inscode')
endif

if !netuse( '&g_Cis_path\Client', .f., 10 )               && Client file
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_Cis_path\Clienm' )                    && set index on Fullname
   ORDLISTADD('&g_CIS_PATH\Cliecd')
   ordlistadd( '&g_CIS_PATH\CLIEBF' )
 //  ordlistadd( '&g_Cis_path\ao' )                        && set index on AccountOfficer

endif

return nil


