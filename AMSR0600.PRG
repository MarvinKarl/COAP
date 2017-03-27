/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³   colf-iis -- account management system                                  ³
 ³   program idúúú amsr3100                                                 ³
 ³   descriptionúú PDC Recieved for the day                                 ³
 ³   authorúúúúúúú renan s. evangelista                                     ³
 ³   dateúúúúúúúúú 9:20:am úú 07-25-96                                      ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³                             u p d a t e s                                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³        who        ³       when        ³               why                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³ Marvin T. Sabile  ³   July 14, 2011   ³ Added PDCHDBCK & PDCDTBCK        ³
 ³                   ³                   ³   databases                      ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
setblink(.t.)
if !chkpass( procname(), AX_LEVEL, gUSER_ID )
   //NOTHING WILL HAPPEN
else
   begin sequence
	 aOpen1111()
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
   ordlistadd( '&g_AMS_PATH\Acctmast' )                    && set index on acctno
   //ordlistadd( 'Acctclnt' )                    && index on Clntcode + acctno
endif

if !netuse( '&g_AMS_PATH\Pdc_dtls', .f., 10 )               && Payment Schedule file
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_AMS_PATH\Pdc_dtls' )                     && set index  on acctno
   //ordlistadd( 'Paydsked' )                    && set index on paydate
endif

if !netuse( '&g_AMS_PATH\Pdc_Head', .f., 10 )               && Payment Schedule file
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_AMS_PATH\Pdcrevac' )                     && set index recdate  + acctno
   //ordlistadd( 'Paydsked' )                    && set index on paydate
endif

if !netuse( '&g_AMS_PATH\AMSBACK\PDCDTBCK', .f., 10 )               && Payment Schedule file
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_AMS_PATH\AMSBACK\PBK_DTLS' )                     && set index  on acctno
endif

if !netuse( '&g_AMS_PATH\AMSBACK\PDCHDBCK', .f., 10 )               && Payment Schedule file
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_AMS_PATH\AMSBACK\PBKREVAC' )                     && set index recdate  + acctno
endif

if !netuse('&g_grf_path'+'\Personel',.f.,5)
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_grf_path\Initials')
endif


return nil
/*
/*-------------------------------*/
 STatic Function chkpdcdate(ddate)
/*-------------------------------*/
 local mu:=savedbf(),re:=setcursor(),bf:=savescreen(,,,),gf:=setcolor()
 
 dbselectarea('Pdc_head')
 dbsetorder(1)

 IF Pdc_head->(DBSEEK(DTOS(ddate)))
    return .t. 
 ELSEIF PDCHDBCK->(DBSEEK(DTOS(ddate)))
    return .t.
 ELSE
    error('PDC received date not found.')
    return .f. 
 ENDIF

 /**
 ALERT(ALIAS())
 if !dbseek(dtos(ddate))
    error('PDC received date not found.FFF')
    return .f.
 else
    return .t.
 endif
 **/
 
restdbf(mu);restscreen(,,,,bf);setcursor(re);setcolor(gf)
return .t.

  
/*-------------------------*/
 Static Function Amain9999()
/*-------------------------*/
local mu:=savedbf(),re:=setcursor(),bf:=savescreen(,,,),gf:=setcolor()
private ddate:=mtrandate

setkey(K_ESC, nil)
setcolor('n/w,w/n,,,w+/w')
setcursor(1)

fshadow(17,18,19,55,2,'n/w')
@ 18,20 say 'PDC Date Received    ' get ddate pict '@D' valid !empty(ddate) .and. chkpdcdate(ddate)
setkey(K_ESC ,{ || fescape( 'Abort?' ) } )
read
setkey(K_ESC, nil)

if lastkey() <> K_ESC
   reportprint('pdc01111()')
   *repcon_ol('pdc01111()',,,,,,,.F.)
endif

restdbf(mu);restscreen(,,,,bf);setcursor(re);setcolor(gf)
return nil
/*-------------------------*/
 Function pdc01111()
/*-------------------------*/
local mu:=savedbf(),re:=setcursor(),bf:=savescreen(,,,),gf:=setcolor()
local pgn:=1,chkcnt:=0,tot_amount:=0,xdate,sw,flg:=.f.,chk1:=0,t_amount:=0
local ThenTrig := .T., NowTrig := .T.

xdate:=cmonth(ddate) + ' ' + str(day(ddate),2) +', '+str(year(ddate),4)

//dbselectarea('Pdc_dtls')
//dbsetorder(1)

If PDCHDBCK->(dbseek(DTOS(ddate)))
	//Head_9999( pgn,xdate)

	while PDCHDBCK->Recdate == ddate .and. PDCHDBCK->(!eof())
		sw := .f.
		if PDCDTBCK->( dbseek(PDCHDBCK->BRCODE+PDCHDBCK->Acctno) )
		   while PDCDTBCK->BRCODE+PDCDTBCK->Acctno == PDCHDBCK->BRCODE+PDCHDBCK->Acctno .and. PDCDTBCK->(!eof())

			   if PDCDTBCK->Status <> '1'
				  PDCDTBCK->(dbskip(+1))
				  loop
			   endif
			   
			   If ThenTrig
			      Head_9999(pgn,xdate)
			      ThenTrig := .F.
			   EndIf

			   if !sw
				  sw:= .t.
				  accname:=eval( {|| Acctmast->(dbseek(PDCHDBCK->BRCODE+PDCHDBCK->Acctno)), substr(Acctmast->Acctname,1,34) } )
				  @ prow()+1, 2 say 'Account Number/Name : '+ PDCHDBCK->BRCODE+'-'+substr(PDCHDBCK->Acctno,-5,5)+'-'+ accname
				  @ prow()+1, 2 say 'Received by         : '+ dispreceiver( PDCHDBCK->Receiver )
				  @ prow()+1, 2 say ' '
			   endif
			   if prow() > 54
				  __eject()
				  pgn++
				  Head_9999(pgn)
			   endif
			   chk1++
			   chkcnt++
			   flg:=.t.
			   t_amount += PDCDTBCK->Chkamt
			   tot_amount += PDCDTBCK->Chkamt
			   @ prow()+1, 02 say substr(PDCDTBCK->Bank,1,15) + '   '+PDCDTBCK->chktype+'-'+            ;
							  dispchktype(PDCDTBCK->chktype)+'   '+ PDCDTBCK->Chkno +      ;
							  '   '+dtoc(PDCDTBCK->chkdate)+'    '+dtoc(PDCDTBCK->Depdate)+;
							  '    '+tran(PDCDTBCK->Chkamt,'99,999,999.99')
			   PDCDTBCK->(dbskip())
		   enddo
		   if sw .and. !empty(t_amount)
			  //flg := .t.
			  //@ prow()+1, 2 say ' '
			  @ prow()+1,37 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
			  @ PROW()+1,37 SAY 'NO. OF CHECKS :   '+trans(chk1,'@B 99,999')
			  @ prow()  ,68 say 'TOTAL      :   '+trans(t_amount,'99,999,999.99')
			  @ prow()+1, 2 say ' '
			  t_amount := 0
			  chk1     := 0
		   endif
		endif
		PDCHDBCK->(dbskip())
	enddo
EndIf

If Pdc_head->(dbseek(DTOS(ddate)))

	//Head_9999( pgn,xdate)

	while Pdc_head->Recdate == ddate .and. Pdc_head->(!eof())
		sw := .f.
		if Pdc_dtls->( dbseek(PDC_HEAD->BRCODE+Pdc_head->Acctno) )
		   while PDC_DTLS->BRCODE+Pdc_dtls->Acctno == PDC_HEAD->BRCODE+Pdc_head->Acctno .and. Pdc_dtls->(!eof())

			   if Pdc_dtls->Status <> '1'
				  Pdc_dtls->(dbskip(+1))
				  loop
			   endif
			   
			   If NowTrig
			      Head_9999(pgn,xdate)
			      NowTrig := .F.
			   EndIf
			   
			   if !sw
				  sw:= .t.
				  accname:=eval( {|| Acctmast->(dbseek(PDC_HEAD->BRCODE+Pdc_head->Acctno)), substr(Acctmast->Acctname,1,34) } )
				  @ prow()+1, 2 say 'Account Number/Name : '+ PDC_HEAD->BRCODE+'-'+substr(Pdc_head->Acctno,-5,5)+'-'+ accname
				  @ prow()+1, 2 say 'Received by         : '+ dispreceiver( Pdc_head->Receiver )
				  @ prow()+1, 2 say ' '
			   endif
			   if prow() > 54
				  __eject()
				  pgn++
				  Head_9999(pgn)
			   endif
			   chk1++
			   chkcnt++
			   flg:=.t.
			   t_amount += Pdc_dtls->Chkamt
			   tot_amount += Pdc_dtls->Chkamt
			   @ prow()+1, 02 say substr(Pdc_dtls->Bank,1,15) + '   '+Pdc_dtls->chktype+'-'+            ;
							  dispchktype(Pdc_dtls->chktype)+'   '+ Pdc_dtls->Chkno +      ;
							  '   '+dtoc(Pdc_dtls->chkdate)+'    '+dtoc(Pdc_dtls->Depdate)+;
							  '    '+tran(Pdc_dtls->Chkamt,'99,999,999.99')
			   Pdc_dtls->(dbskip())
		   enddo
		   if sw .and. !empty(t_amount)
			  //flg := .t.
			  //@ prow()+1, 2 say ' '
			  @ prow()+1,37 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
			  @ PROW()+1,37 SAY 'NO. OF CHECKS :   '+trans(chk1,'@B 99,999')
			  @ prow()  ,68 say 'TOTAL      :   '+trans(t_amount,'99,999,999.99')
			  @ prow()+1, 2 say ' '
			  t_amount := 0
			  chk1     := 0
		   endif
		endif
		Pdc_head->(dbskip())
	enddo
EndIf

//@PROW()+1, 02 say ' '
@PROW()+1, 02 say 'TOTAL NO. OF CHECKS : '+trans(chkcnt,'@B 999,999')
@PROW()+1, 02 say 'TOTAL CHECK AMOUNT  : '+trans(tot_amount,'@B 99,999,999.99')
__eject()
return nil
/*----------------------------*/
Static Function Head_9999( pgn,xdate )
/*----------------------------*/
setprc(0,0)
setfont('DRAFT')
setfont('ELITE')
@ prow()+1,02 say 'ACCOUNT MANAGEMENT SYSTEM'
@ prow(),  02+len('ACCOUNT MANAGEMENT SYSTEM');
              say PADL('Page No. ' + tran(pgn,'999'),94-len('ACCOUNT MANAGEMENT SYSTEM'))
@ prow()+1,02 say 'AMSR0600'
@ prow()  ,02+len('AMSR0600');
              say PADL( dtoc(DATE())+' '+TIME(), 94-len('AMSR0600'))
@ prow()+1,02 say PADC('CONSOLIDATED ORIX LEASING AND FINANCE CORPORATION',94)
@ prow()+1,02 say padc('LIST OF PDCs RECEIVED',94)
@ prow()+1,02 say padc(xdate,94)
@ prow()+1,02 say ' '
@ prow()+1,02 say '---------------   --------------   ---------------   ----------   ------------   -------------'
@ prow()+1,02 say '    Bank            Check Type       Check Number    Check Date   Deposit Date    Check Amount'
@ prow()+1,02 say '---------------   --------------   ---------------   ----------   ------------   -------------'
@ prow()+1,02 say ' '
return nil
/*
***************************************
static function dispchktype( mCHKTYPE )
***************************************
   local mLIST := space (12 ) +'Metro Manila'+'Regional    '+'Out-Of-Town '
return substr ( mLIST, val ( mCHKTYPE ) * 12 + 1, 12 )
**********************************************************
static function dispreceiver( mreceiver )
*******************************************
return eval ({|x,y| x := savedbf (x) ,;
                    Personel->( dbseek ( mRECEIVER ) ) ,;
                    y := Personel ->FULLNAME           ,;
                    restdbf (x)      ,;
                    y;
            })
*/


/*       1         2         3         4         5         6         7         8         9         0         1         2         3         4
12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
 ---------------   --------------  'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
                                    NO. OF CHECKS :   99,999       TOTAL      :   99,999,999.99
 COLF
 ---------------   --------------   ---------------   ----------   ------------   -------------
    Bank             Check Type      Check Number     Check Date   Deposit Date   Check Amount
 ---------------   --------------   ---------------   ----------   ------------   -------------
 XXXXXXXXXXXXXXX   9-XXXXXXXXXXXX   999999999999999   99/99/9999    99/99/9999    99,999,999.99


 Account Number/Name : 99999-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
 Received by         : AAAAAAAAAAAAAAAA X. BBBBBBBBBBBBBBBBBBBB
*/
