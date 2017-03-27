/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   program idúúú amsq1000                                                     ³
³   descriptionúú Maturities                                                   ³
³   authorúúúúúúú renan s. evangelista                                         ³
³   dateúúúúúúúúú 9:20:am úú 07-12-96                                          ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                             u p d a t e s                                    ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        who        ³    when     ³                  why                       ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Engr. Mike Espina ³ 01-Feb-1999 ³Printing of one account                     ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
begin sequence
	if ! chkpass( procname(), AX_LEVEL, gUSER_ID )
		break
	endif

   /*if ! qOpen1000()
      break
   endif*/

	*-- account master file
	if ! netuse('&g_AMS_PATH\ACCTMAST',.f.,5)
		break
	endif
	set index to &g_AMS_PATH\Acctclmt, &g_AMS_PATH\Acctmatd

	if !netuse( '&g_AMS_PATH\Flag', .f., 5 )
		break
	endif

	*-- client master file
	if !netuse( '&g_CIS_PATH\Client', .f., 10 )
		break
	endif
	ordlistadd( '&g_CIS_PATH\Clienm' )            && set index on Fullname

	*-- branches
	if !netuse( '&g_GRF_PATH\branches', .f., 10 )
		break
	endif
	set index to &g_GRF_PATH\branches

	*-- axbranch
	if !netuse( '&g_GRF_PATH\AXBRANCH', .f., 10 )
		break
	endif
	set index to &g_GRF_PATH\AXBRANCH

	mainmode()

end sequence
dbcloseall()
__mrelease( '*', .t. )
return nil

/*------------------------*/
Static Function Mainmode()
/*------------------------*/
	local menulist
	private xchoice
	private st
	//PRIVATE cBRCODES := ACC_BRCH(g_USER_ID)

	DBSELECTAREA('ACCTMAST')
	DBSETORDER(1)
	fshadow( 08,15,13,26,2,'w+/bg')
	setcolor('n/gr,w+/gr','w+/gr,n/gr')
	while .t.
		@ 09,24 say 'Ü'            color 'n/bg'
		@ 10,18 say repl('ß',7)   color 'n/bg'
		@ 11,24 say 'Ü'            color 'n/bg'
		@ 12,18 say repl('ß',7)   color 'n/bg'
		@ 09,17 prompt '  ~All  ' triggercolor 'w+/gr'
		@ 11,17 prompt '  ~One  ' triggercolor 'w+/gr'
		menu to xchoice
		do case
			case xchoice == 1
				@ 09,23 say 'û' COLOR 'n/gr'
				dbgobottom()
				st := ACCTMAST->BRCODE+ACCTMAST->Clntcode
			case xchoice == 2
				@ 11,23 say 'û' COLOR 'n/gr'
				st := client1111(xchoice)
				//client9999(xchoice)
			case xchoice == 0
				exit
		endcase

		if !empty(st)
			//qprnt1000( st,xchoice )
			xSTR := CHK_PAR(gsys_name )+;
				CHK_PAR(gcompany  )+;
				CHK_PAR(xchoice  )+;
				CHK_PAR(st  )

			if xchoice == 2
				IF !ACCTMAST->(dbseek (st) )
				endif

				*repcontrol('qprnt1111()')

				repcon_ol('qprnt2222()',,,,,,xSTR,.t.)

			elseif xchoice == 1
				ACCTMAST->(dbsetorder(2))
				ACCTMAST->(dbgotop())
				*repcontrol('qprnt2222()')
				REPCON_OL('qprnt2222()',,,,,, xSTR, .t.)
			endif
		endif
		return
	enddo
return

/*--------------------------------*/
Function qprnt2222()
/*--------------------------------*/
	local mu:=savedbf(),re:=setcursor(),bf:=savescreen(,,,),gf:=setcolor()
	local pgn:=1,nrow,tot_cred:=0,tot_prin:=0,tot_bal:=0, sw:=.t.
	&&local ddate := cmonth(Flag->Prevdate)+' '+str(day(Flag->Prevdate),2)+', '+ str( year( Flag->Prevdate ),4 )
	LOCAL dDATE := cMONTH(FLAG->LASTCLOSED)+' '+STR(DAY(FLAG->LASTCLOSED),2)+', '+ STR( YEAR( FLAG->LASTCLOSED ),4 )

	IF xchoice == 2
		dbselectarea('ACCTMAST')
		dbsetorder(1)
		ST := ACCTMAST->BRCODE+ACCTMAST->CLNTCODE
		head1111(pgn,ddate)

		do while ACCTMAST->BRCODE+ACCTMAST->Clntcode == st .and. !Eof()
			//IF ACCTMAST->BRCODE $ (cBRCODES)
			IF AXBRANCH->(DBSEEK(g_USER_ID+ACCTMAST->BRCODE))
				if prow() >= 55
					pgn++
					//@ prow()+1,0 say ''
					__eject()
					@ prow()+1,0 say ''
					head1111(pgn,ddate)
				endif
				tot_cred += ACCTMAST->Credamt
				tot_prin += ACCTMAST->Principal
				tot_bal  += ACCTMAST->Osbal
				//aga.29.01.2007.acctdept request emi for acctno instead oldno
				@ prow()+1,02 say alltrim(ACCTMAST->brcode)+'-'+substr(ACCTMAST->acctno,1,4) +'-'+substr(ACCTMAST->acctno,5,5)+'-'+substr(ACCTMAST->acctno,10,5)+'   ' + tran(ACCTMAST->Credamt,'999,999,999.99')+'   ' ;
					+tran(ACCTMAST->Principal,'999,999,999.99')+'   '+if(!empty(ACCTMAST->Valdate),dtoc(ACCTMAST->Valdate),spac(10))+ ;
					'   '+ if(!empty(ACCTMAST->Matdate),dtoc(ACCTMAST->Matdate),spac(10) ) +'   '+tran(ACCTMAST->Osbal,'999,999,999.99')

				//      @ prow()+1,02 say ACCTMAST->Oldno+'   ' + tran(ACCTMAST->Credamt,'999,999,999.99')+'   ' ;
					//                       +tran(ACCTMAST->Principal,'999,999,999.99')+'   '+if(!empty(ACCTMAST->Valdate),dtoc(ACCTMAST->Valdate),spac(10))+ ;
					//                       '   '+ if(!empty(ACCTMAST->Matdate),dtoc(ACCTMAST->Matdate),spac(10) ) +'   '+tran(ACCTMAST->Osbal,'999,999,999.99')


			ENDIF
			dbskip()
		enddo
		@ PROW()+1,02 SAY '                       ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ                             ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
		@ PROW()+1,02 SAY 'GRAND TOTAL    :       '+tran(tot_cred,'999,999,999.99')+'   '+tran(tot_prin,'999,999,999.99')+'                             '+tran(tot_bal,'999,999,999.99')
		@ PROW()+1,02 SAY '                       ÍÍÍÍÍÍÍÍÍÍÍÍÍÍ   ÍÍÍÍÍÍÍÍÍÍÍÍÍÍ                             ÍÍÍÍÍÍÍÍÍÍÍÍÍÍ'
		__eject()
		restdbf(mu);restscreen(,,,,bf);setcursor(re);setcolor(gf)
	ELSE
		dbselectarea('ACCTMAST')
		dbsetorder(2)
		//SETFONT('INIT')
		head2222(pgn,ddate)
		nclnt:= ACCTMAST->BRCODE+ACCTMAST->Clntcode

		do while !eof()
			//IF ACCTMAST->BRCODE $ (cBRCODES)
			IF AXBRANCH->(DBSEEK(g_USER_ID+ACCTMAST->BRCODE))
				if prow() >= 55
					pgn++
					__eject()
					@ prow()+1,0 say ''
					SETFONT('UNCONDENSD')
					head2222(pgn,ddate)
					sw:=.t.
				endif
				if ACCTMAST->BRCODE+ACCTMAST->Clntcode <> nclnt .or. sw
					sw := .f.
					nclnt:=ACCTMAST->BRCODE+ACCTMAST->Clntcode
					//aga.29.01.2007.acctdept request emi for acctno instead oldno
					@ prow()+1,02 say SUBSTR(ACCTMAST->Acctname,1,40)+'  '+alltrim(ACCTMAST->brcode)+'-'+substr(ACCTMAST->acctno,1,4) +'-'+substr(ACCTMAST->acctno,5,5)+'-'+substr(ACCTMAST->acctno,10,5) +'  '+tran(ACCTMAST->Credamt,'999,999,999.99')+'  ';
						+tran(ACCTMAST->Principal,'999,999,999.99')+'   '+if(!empty(ACCTMAST->Valdate),dtoc(ACCTMAST->Valdate),spac(10))+;
						'   '+if(!empty(ACCTMAST->Matdate),dtoc(ACCTMAST->Matdate),spac(10) ) +'  '+tran(ACCTMAST->Osbal,'999,999,999.99')

					//         @ prow()+1,02 say SUBSTR(ACCTMAST->Acctname,1,40)+'  '+ ACCTMAST->Oldno +'  '+tran(ACCTMAST->Credamt,'999,999,999.99')+'  ';
						//                           +tran(ACCTMAST->Principal,'999,999,999.99')+'   '+if(!empty(ACCTMAST->Valdate),dtoc(ACCTMAST->Valdate),spac(10))+;
						//                           '   '+if(!empty(ACCTMAST->Matdate),dtoc(ACCTMAST->Matdate),spac(10) ) +'  '+tran(ACCTMAST->Osbal,'999,999,999.99')
				else
					//aga.29.01.2007.acctdept request emi for acctno instead oldno
					@ prow()+1,02 say spac(42)+alltrim(ACCTMAST->brcode)+'-'+ substr(ACCTMAST->acctno,1,4) +'-'+substr(ACCTMAST->acctno,5,5)+'-'+substr(ACCTMAST->acctno,10,5) +'  '+tran(ACCTMAST->Credamt,'999,999,999.99')+'  ';
						+tran(ACCTMAST->Principal,'999,999,999.99')+'   '+if(!empty(ACCTMAST->Valdate),dtoc(ACCTMAST->Valdate),spac(10))+;
						'   '+ if(!empty(ACCTMAST->Matdate),dtoc(ACCTMAST->Matdate),spac(10) ) +'  '+tran(ACCTMAST->Osbal,'999,999,999.99')

					//         @ prow()+1,02 say spac(42)+ ACCTMAST->Oldno +'  '+tran(ACCTMAST->Credamt,'999,999,999.99')+'  ';
						//                           +tran(ACCTMAST->Principal,'999,999,999.99')+'   '+if(!empty(ACCTMAST->Valdate),dtoc(ACCTMAST->Valdate),spac(10))+;
						//                           '   '+ if(!empty(ACCTMAST->Matdate),dtoc(ACCTMAST->Matdate),spac(10) ) +'  '+tran(ACCTMAST->Osbal,'999,999,999.99')
				endif
			ENDIF
			dbskip()
		enddo
		restdbf(mu);restscreen(,,,,bf);setcursor(re);setcolor(gf)
	ENDIF
return .f.


/*--------------------------------*/
Static Function head1111(pgn,ddate)
/*--------------------------------*/

	setprc(0,0)
	setfont('NLQ')
	setfont('ELITE')
	@ prow()+1,02 say alltrim(gsys_name)
	@ prow(),  02+len('ACCOUNT MANAGEMENT SYSTEM');
		say PADL('Page No. ' + tran(pgn,'99'),94-len('ACCOUNT MANAGEMENT SYSTEM'))
	@ prow()+1,02 say 'AMSQ1000'
	@ prow()  ,02+len('AMSQ1000');
		say PADL( dtoc(DATE())+' '+TIME(), 94-len('AMSQ1000'))
	@ prow()+1,02 say PADC(gcompany,94)
	@ prow()+1,02 say padc('LIST OF ACCOUNTS ACCORDING TO MATURITY DATE',94)
	@ prow()+1,02 say padc('As of '+ ddate, 94)
	@ prow()+1,00 say ''
	@ prow()+1,02 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
	@ prow()+1,02 say ' ACCOUNT NUMBER        CREDIT AMOUNT     NET PROCEEDS    VALUE DATE   MAT. DATE     O/S BALANCE  '
	@ prow()+1,02 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
	setfont('DRAFT')
	setfont('ELITE')
	@ prow()+1,02 say ACCTMAST->Acctname
return nil

/*--------------------------------*/
Static Function head2222(pgn,ddate)
/*--------------------------------*/

	setprc(0,0)
	setfont('NLQ')
	setfont('ELITE')
	@ prow()+1,02 say alltrim(gsys_name)
	@ prow(),  02+len('ACCOUNT MANAGEMENT SYSTEM');
		say PADL('Page No. ' + tran(pgn,'99'),94-len('ACCOUNT MANAGEMENT SYSTEM'))
	@ prow()+1,02 say 'AMSQ1000'
	@ prow()  ,02+len('AMSQ1000');
		say PADL( dtoc(DATE())+' '+TIME(), 94-len('AMSQ1000'))
	@ prow()+1,02 say PADC(gcompany,94)
	@ prow()+1,02 say padc('LIST OF ACCOUNTS ACCORDING TO MATURITY DATE',94)
	@ prow()+1,02 say padc('As of '+ ddate, 94)
	@ prow()+1,00 say ''
	@ prow()+1,01 SAY ' ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
	@ prow()+1,01 SAY '           ACCOUNT NAME                     ACCOUNT NUMBER       CREDIT AMOUNT    NET PROCEEDS    VALUE DATE   MAT. DATE    O/S BALANCE  '
	@ prow()+1,01 SAY ' ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
	SETFONT('DRAFT')
	SETFONT('PICA')
	setfont('CONDENSED')
	@ prow()+1,01 SAY ''
return nil

/*--------------------------------*/
Static Function client1111(xchoice)
/*--------------------------------*/
	local mu:=savedbf(),re:=setcursor(),bf:=savescreen(,,,),gf:=setcolor()
	local naccnt:=spac(10),accntnm:=spac(50)
	dbselectarea('ACCTMAST')
	dbsetorder(2)
	Client->( dbsetorder(1) )
	fshadow(15,07,17,34,2,'n/w')                  && RED 11172004 CHANGED 53 TO 34
	set color to 'n/w','w/n',,,'w+/w'
	setcursor(3)
	setkey( K_ESC, NIL)

	@ 16,08 SAY ' Client N§  ' GET nACCNT PICT '@R 999-99-99999';
		VALID IF( !EMPTY(RIGHT(nACCNT,7)) .AND. LASTKEY() == K_ENTER,;
		IF( VALBRCODE(LEFT(nACCNT,3),g_USER_ID),;
		IF( CHECKCLNT(nACCNT),;
		.T.,;
		EVAL({|| nACCNT := SPACE(10), .F.});
		),;
		EVAL({|| nACCNT := SPACE(10), .F.});
		),;
		EVAL({|| nACCNT:=EVAL( { || FLOOK_ONLINE(.t.,'Client',nil,'Account Master File',3,45,1,2,1,,,,,,.T.) } ),;
		IF( LASTKEY() == K_ENTER,;
		IF( VALBRCODE(LEFT(nACCNT,3),g_USER_ID),;
		.T.,;
		EVAL({|| nACCNT := SPACE(10),.F.});
		),;
		EVAL({|| nACCNT := SPACE(10),.F.});
		);
		});
		)
	*@ 16,08 say ' Client Name   ' get accntnm pict '@!S25' when !empty(nacct:=eval( { || flook(.t.,'Client',nil,'Account Master File',1,3,2,3) } ) );
		*                                 valid lastkey() <> K_ESC .and. !empty(accntnm) .and. checkclnt(CLIENT->BRCODE+Client->Clntcode)
	setkey( K_ESC, {|| Fescape( 'Abort?') } )
	read
	setkey( K_ESC, NIL)
*if lastkey() <> K_ESC .and. checkclnt(CLIENT->BRCODE+Client->Clntcode)  /*!empty(nAccnt)*/
	*   naccnt := CLIENT->BRCODE+Client->Clntcode
	*endif
	restdbf(mu);restscreen(,,,,bf);setcursor(re);setcolor(gf)
return (naccnt)

*-----------------------------------
FUNCTION CHKBYNAME(cCLNTNAME)
	LOCAL lRETVAL := .F.

	IF CLIENT->(DBSEEK(cCLNTNAME))
		lRETVAL := .T.
	ELSE
		ERROR('Client name not found.')
	ENDIF

RETURN lRETVAL
/*
/*--------------------------------*/
Static function checkclnt(xclntcode)
/*--------------------------------*/
	local mu:=savedbf(),re:=setcursor(),bf:=savescreen(,,,),gf:=setcolor()
	local nval
	dbselectarea('ACCTMAST')
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

*********************************
static function _getbrch()
	*********************************
	local reval
	if branches->(dbseek(g_par_brch))
		reval := branches->brname
	endif

return reval

/*       1         2         3         4         5         6         7         8         9         0         1         2         3         4
12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
Page No. 999
99/99/9999
                                    ACCORDING TO MATURITY DATE
                                     As of XXXXXXXXX 99, 1999
----------------------------------------  ----------------  --------------  --------------  ----------  ----------  --------------
          ACCOUNT NAME                     ACCOUNT NUMBER   CREDIT AMOUNT     PRINCIPAL     VALUE DATE  MAT. DATE    O/S BALANCE
----------------------------------------  ----------------  --------------  --------------  ----------  ----------  --------------
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XX-XX-XXX-XXXXXX  999,999,999.99  999,999,999.99  99/99/9999  99/99/9999  999,999,999.99

         1         2         3         4         5         6         7         8         9         0         1         2         3         4
1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
 Page No. 999                                                                        pAGE nO. 99
 99/99/9999                                                                    /11/1111 11;11;11
                                    ACCORDING TO MATURITY DATE
                                     As of XXXXXXXXX 99, 1999
 ----------------   --------------   --------------   ----------   ----------   --------------
  ACCOUNT NUMBER    CREDIT AMOUNT      PRINCIPAL      VALUE DATE   MAT. DATE     O/S BALANCE
 ----------------   --------------   --------------   ----------   ----------   --------------
 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
 XX-XX-XXX-XXXXXX   999,999,999.99   999,999,999.99   99/99/9999   99/99/9999   999,999,999.99
 ----------------   --------------   --------------   ----------   ----------   --------------
 GRAND TOTAL    :   999,999,999.99   999,999,999.99                             999,999,999.99

*/
