/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   program id.........:  amsr6000.prg                                       Æ»
³   description........:  Renewal Notice                                    ³Ì»
³   author.............: RLV                                                ³ºº
³   date...............: 03.11.2010                                         ³ºº
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´ºº
³                         u p d a t e s                                      ³ºº
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´ºº
³        who        ³     when          ³               why                  ³ºº
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´ºº

³ Ronie L. Vivit    ³August 8,  2008    ³Changed searching of accounts from  ³ºº
³                   ³                   ³ Flook to Fchoice                   ³ºº
³                   ³                   ³                                    ³ ºº
ÀÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ ºº
  ÈËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼º
   ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
*/




////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
#include 'inkey.ch'
#include 'colf.ch'
#include 'dbstruct.ch'
#include 'Achoice.ch'
#defi K_SPACEBAR   32
#defi microfeed    chr( 27 ) + 'J' + chr( 18 )
#defi xprydate  right( space(5) + a_month[ if( month(Ctrlinfo->Insexpry) > 0, month( Ctrlinfo->Insexpry ), 13 ) ],5 )  +' '+ str(day(Ctrlinfo->Insexpry),2)+', '+str(year(Ctrlinfo->Insexpry),4)
memvar  AX_LEVEL, gUSER_ID
setcursor(0)
if !chkpass( procname(), AX_LEVEL, gUSER_ID )
	//NOTHING WILL HAPPEN
else
	begin sequence
	aOpen6000()
	aMain6000()
	end sequence
	dbcloseall()
endif
__mrelease( '*', .t. )
return nil
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
Static Function aMain6000()
	local mu:=savescreen(,,,),gf:=savedbf(),bf:=setcursor()
	private mmonth := month(gtrandate), myear := year(gtrandate)
	private g_INS_SIGNEE, g_SIGN_POST, g_RENCONTACT, g_RENPHONE, dDATE := gtrandate//CTOD('')
    private nacctno:=SPACE(16+4), aRECNO := {},xREASON:= {} , xPAYDATE:={}, xAMORT:={}, xT_ARREAR:= {} ,d_PDC := {}, cNOTICE:=0   && RED 100604 spac(5)   RED 031705 '+4 
    private xPASSED := .f.
    private nTOTARREARS := 0
    
    if Ol_param->(dbseek(g_PAR_BRCH))     // EVR 20122006
		g_INS_SIGNEE := Ol_param->INS_SIGNEE
		g_SIGN_POST  := Ol_param->SIGN_POST
		g_RENCONTACT := Ol_param->RENCONTACT
		g_RENPHONE   := Ol_param->RENPHONE
	endif
   
   
   
 /*  fshadow( 11,29,13,66+4,2,'n/bg' )   && RED 100604 fshadow( 11,30,13,60,2,'n/bg' )  RED 031705 '+4
	setcolor( 'w/bg,n/w,,,w+/bg' )

   @ 12, 31 say 'Account Number  ' get nacctno picture '@R 999-9999-99999-99999';     && RED 031705 ADDED '999-
                                     when eval( { || get_date(), .f. } )       && RED 100604  picture '@R 99999'
	read
*/
	get_date()
	
	
	
  // ACCTMAST->(DBSETORDER(1))    && RED 100604  Acctmast->(dbsetorder(2))
	if lastkey() <> K_ESC //.and. Acctmast->(dbseek(nacctno)) 
	
	endif
   ACCTMAST->(DBSETORDER(3))        && RED 100604
	restdbf(gf);restscreen(,,,,mu);setcursor(bf)
return nil
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
Static function get_date()
	local ndbf:=select(),nclntno:=spac(7),nval,mu
	local o_scr:=savescreen(,,,),msel,xx_,mclntcode
	local cTEXT
	
	FSHADOW(08,13,10,39,02)
	@ 09,15 SAY 'Enter Date ' GET dDATE PICT '@D' VALID !EMPTY(dDATE)

	SET CURSOR ON
	//SETKEY(K_ESC,{||FESCAPE('Abort?')})
	READ
	SETKEY(K_ESC,NIL)
	SET CURSOR OFF	
 
   if lastkey() <> K_ESC //.AND. CURRBRCH(CLIENT->BRCODE)     && RED 031705 ADDED 'CURRBRCH(..
  
	//	fshadow(10,09,21,69,2,'n/bg')
		while .t.
//			mcx := achoice( 11, 10, 20, 68, mu, msel )
			if lastkey() <> K_LEFT .and. lastkey() <> K_RIGHT 
				if lastkey() == K_RETURN
					select_rCheques(nACCTNO)
					
						if lastkey() == K_ENTER 
							if !empty(d_PDC)
								PRINT_DISHONORCHK('LTR_DSHONOR()',,,,,,,.F.)
							else
								exit
							endif	
						endif	
					//exit
				elseif lastkey() == K_ESC
					if cNOTICE != 0
						if alert ('There are '+alltrim(str(cNOTICE))+ ' Dishonored Check/s that are not yet printed. Are you sure you want to Exit?',{'No','Yes'}) = 2      
							DSHNRCHK->(dbsetorder(2))
							if DSHNRCHK->(dbseek(g_par_brch+dtoc(gtrandate)))
								do while g_par_brch+dtoc(gtrandate) == DSHNRCHK->BRCODE+dtoc(DSHNRCHK->TRANDATE)
									 if DSHNRCHK->(netlock('R',0))
										DSHNRCHK->IS_PRN    := .F.
									 endif   
									DSHNRCHK->(dbskip(1))
								enddo
								DSHNRCHK->(dbunlock())
								DSHNRCHK->(dbcommit())	
							endif	
							exit
						endif
					else
						exit
					endif
				else
					exit
				endif
			endif
		enddo
	endif
	restscreen(,,,,o_scr)
	dbselectarea(ndbf)
return nval

**************************
*
static function Ach_look2()
**************************
local mod_t:='noacct',ckey:=space(10)
local headr:='   Client Name                            Branch  Clntcode  # of Accts'
   
   main_achoice('CLIENT',3,1,,8,4,21,76,headr,mod_t)
   
  if mpos > 0 .and. lastkey() == K_ENTER
				cKEY := substr( ltrim(mchoices[mpos]),44,3)+substr( ltrim(mchoices[mpos]),50,2)+;
				substr( ltrim(mchoices[mpos]),53,5)				
				client->(dbsetorder(3))
				CLIENT->(DBSEEK(substr( ltrim(mchoices[mpos]),44,3)+substr( ltrim(mchoices[mpos]),1,40)))
				//ALERT(substr( ltrim(mchoices[mpos]),44,3)+substr( ltrim(mchoices[mpos]),1,40))
  endif 
 
return ckey

////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
static function aOpen6000()
	memvar gSYS_NAME, gUSER_ID, gTRANDATE, mFMS0700
// EVR	if !netuse( 'Parametr',.f.,10 )
// EVR	   break
// EVR	endif
   if !netuse( '&g_AMS_PATH\Acctmast', .f., 10 )              && Account master file
		break
	else
		if !.f.; ordlistclear(); endif
      ordlistadd( '&g_AMS_PATH\Acctmast' )                     && set index on acctno
	  ordlistadd( '&g_AMS_PATH\Acctclnt')
      ordlistadd( '&g_AMS_PATH\Acctsub2')                      && set index on substr(acctno,-5,5)
	endif
	
   if !netuse( '&g_AMS_PATH\PDC_HEAD', .f., 10 )              && Insurance information file
		break
	else
		if !.f.; ordlistclear(); endif
      ordlistadd( '&g_AMS_PATH\Pdc_head' )                    && set index on acctno
	  ordlistadd( '&g_AMS_PATH\Pdc_hdrt' )
	  ordlistadd( '&g_AMS_PATH\Pdcrevac' )
	  ordlistadd( '&g_AMS_PATH\Pdc_clnt' )
	endif         
	
   if !netuse( '&g_AMS_PATH\PDC_DTLS', .f., 10 )              && Insurance information file
		break
	else
		if !.f.; ordlistclear(); endif
      ordlistadd( '&g_AMS_PATH\Pdc_dtls' )                    && set index on acctno
	  ordlistadd( '&g_AMS_PATH\Pdc_date' )
	  ordlistadd( '&g_AMS_PATH\Pdc_ornm' )   // rlv brcodE+ORNUMBER
	endif   

   if !netuse( '&g_AMS_PATH\AMSBACK\PDCHDBCK', .f., 10 )              && Insurance information file
		break
	else
		if !.f.; ordlistclear(); endif
      ordlistadd( '&g_AMS_PATH\AMSBACK\PBK_HEAD' )                    && set index on acctno
	  ordlistadd( '&g_AMS_PATH\AMSBACK\PBK_HDRT' )
	  ordlistadd( '&g_AMS_PATH\AMSBACK\PBKREVAC' )
	  ordlistadd( '&g_AMS_PATH\AMSBACK\PBK_CLNT' )
	endif         
 
    if !netuse( '&g_AMS_PATH\AMSBACK\PDCDTBCK', .f., 10 )              && Insurance information file
		break
	else
		if !.f.; ordlistclear(); endif
      ordlistadd( '&g_AMS_PATH\AMSBACK\PBK_DTLS' )                    && set index on acctno
	  ordlistadd( '&g_AMS_PATH\AMSBACK\PBK_DATE' )
	  ordlistadd( '&g_AMS_PATH\AMSBACK\PBK_ORNM' )   // rlv brcodE+ORNUMBER
	endif	

    if !netuse( '&g_AMS_PATH\DSHNRCHK', .f., 10 )              && Insurance information file RLV 03/22/2010
		break
	else
		if !.f.; ordlistclear(); endif
      ordlistadd( '&g_AMS_PATH\DSHNRCHK' )
	  ordlistadd( '&g_AMS_PATH\DSHNRDTE' )
	endif      	

	  
   if !netuse( '&g_AMS_PATH\AMSHIST', .f., 10 )              && Insurance information file RLV 03/22/2010
		break
	else
		if !.f.; ordlistclear(); endif
      ordlistadd( '&g_AMS_PATH\AMSHACOR' )                    && set index on ornumber
	endif      	
	
   if !netuse( '&g_Ams_Path\Paysked',.f.,5)   //Account Schedule File from AMS
      return .f.
   endif
   set index to '&g_Ams_Path\Paysked', '&g_Ams_Path\Paydsked', '&g_Ams_Path\Paystat' 	
	
 /*  *---> red 092204 added the following
   If ! Netuse("&g_CIS_path\AO",.F.,10)
      Break
   Else
      If !.f. ;ordlistclear(); Endif
      Ordlistadd("&g_CIS_path\AO")
   Endif
   *---> end
*/
	if !NETUSE('&g_CIS_PATH'+'\CLIENT',.f.,5)   && CLIENT MASTER file
		break
	else
		if !.f.; ordlistclear(); endif
		ordlistadd( '&g_CIS_PATH\CLIECD' )                     && set index on clntcode
		ordlistadd( '&g_CIS_PATH\CLIENM' )                     && set index on Fullname
		ORDLISTADD( '&g_CIS_PATH\CLIEBF' )     //rlv   11:08 AM 8/8/2008 FOR fchoice searching
	endif
	
    if !netuse( '&g_AMS_PATH\Ol_PARAM', .f., 10 )              && Account master file
		break
	else
		if !.f.; ordlistclear(); endif
	  ordlistadd( '&g_AMS_PATH\OL_PARAM')
	endif

	if !netuse( '&g_GL_PATH\Gltranhd', .f., 10 )    && general ledger
	   break
	else
	   if !.f.; ordlistclear(); endif
	   ordlistadd( '&g_GL_PATH\Gltrndte' )     
	   ORDLISTADD( '&G_GL_PATH\Gltranhd' )     
	endif

	if !netuse( '&g_CIS_PATH\Signers', .f., 10 )        && corporate signees
	   break
	else
	   if !.f.; ordlistclear(); endif : !.f.
	   ordlistadd( '&g_CIS_PATH\Signers' )              && set index on client code
	endif
	
	IF !NETUSE('&g_GL_PATH\RCHK_JV',.F.,10)     
	   RETURN .f.
	ENDIF
	SET INDEX TO &g_GL_PATH\RCHK_JV1, &g_GL_PATH\RCHK_JV2
	
return .t.
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////




*------------------------>
FUNCTION xSEL_INSBY(cLETTER)
   LOCAL RDB       := SAVEDBF()
   LOCAL RSCR      := SAVESCREEN()
   LOCAL RCUR      := SETCURSOR()
   LOCAL lMULT_UM  := .F.
   PRIVATE cSIGNEE := SPACE(40)
   PRIVATE cPOS    := SPACE(30)
   
   cSIGNEE := RTRIM(g_INS_SIGNEE)     // EVR 01112007 - changed from PARAMETR->INS_SIGNEE

   FSHADOW(14,18,17,72,2,'n/bg')
   SETCOLOR('w/bg,n/w',,,'w+/bg')
   SET CURSOR ON

   @ 15,20 SAY "Signee    " Get cSignee Pict "@!" When eval({ || Getsign(),.f.}) ;
                                                   Valid !Empty(cSignee)
   @ 16,20 SAY "Position  " Get cPos    Pict "@!" Valid !Empty(cPos)
   READ

   RESTDBF(rdb)
   RESTSCREEN(,,,,rscr)
   SETCURSOR(rcur)

   IF LASTKEY() = K_ENTER
      DBSELECTAREA('Ctrlinfo')
  REPCON_OL ('LTR_DSHONOR()',,,,,,,.F.)
   ENDIF
RETURN NIL

/*------------------------>
FUNCTION GETSIGN
   LOCAL COL_ := { ;
      TBCOLUMNNEW( 'CODE '    , { || AO->AOCODE } ),;
      TBCOLUMNNEW( 'NAME '    , { || AO->AONAME } ),;
      TBCOLUMNNEW( 'POSITION ', { || AO->AOPOST } ) }

   cSIGNEE :=flook_ONLINE( .t.,'AO',,'Personnel File',3,4,,1,1,.F.,COL_ )
   IF cSIGNEE == RTRIM(g_INS_SIGNEE)     // EVR 01112007 - changed from PARAMETR->INS_SIGNEE
      cPOS := RTRIM(g_SIGN_POST)     // EVR 01112007 - changed from PARAMETR->SIGN_POST
   ELSE
      cSIGNEE := AO->AONAME
      cPOS    := AO->AOPOST
   ENDIF
RETURN .T.
*/
*------------------------>
FUNCTION LTR_DSHONOR  //2nd notice omlf accts various
   LOCAL nPGN  := 1
   LOCAL xDATE := cMONTH(GTRANDATE) +' '+ RIGHT(STR(DAY(GTRANDATE) + 100,3,0),2 )+', '+STR(YEAR(GTRANDATE),4 )
   local zDATE := ' '
   LOCAL cEXPI := ""
   LOCAL cPMS  := "", NCTR := 1
   local mACCTNO, CCC
   local _chkdate
   local _dREASON := { '<DAIF> Drawn Against Insufficient Fund        ',;
                  '<DAUD> Drawn Against Uncollected Deposit      ',;
                  'Payment Stopped                               ',;
                  'Signature Differs/IrRegular/Missing/InComplete',;
                  'Account Closed                                ',;
                  'Garnished Account                             ' ;
                }
   local PDCDTTMP, PDCHDTMP
   
     for ccc := 1 to len(arecno)
   
   
		   SETPRC(0,0)

		   SETFONT("NORMAL")
		   SETFONT("ELITE")
		   SETFONT("NLQ")
				
		   //ALERT(STR(aRECNO[i][1])+' '+aRECNO[i][2])
		   
		   If aRECNO[ccc][2] == "PDC_DTLS"
			  PDCDTTMP := 'PDC_DTLS'
			  PDCHDTMP := 'PDC_HEAD'
		      (PDCDTTMP)->(dbgoto(aRECNO[ccc][1]))
		      (PDCHDTMP)->(dbsetorder(1))
		      (PDCHDTMP)->(dbseek((PDCDTTMP)->brcode+(PDCDTTMP)->acctno))
		   Else
			  PDCDTTMP := 'PDCDTBCK'
			  PDCHDTMP := 'PDCHDBCK'
		      (PDCDTTMP)->(dbgoto(aRECNO[ccc][1]))
		      (PDCHDTMP)->(dbsetorder(1))
		      (PDCHDTMP)->(dbseek((PDCDTTMP)->brcode+(PDCDTTMP)->acctno))
		   EndIf

		   CLIENT->(dbsetorder(1))
		   CLIENT->(dbseek((PDCHDTMP)->brcode+(PDCHDTMP)->clntCode))
		   _chkdate := cMONTH((PDCDTTMP)->depDATE) +' '+ RIGHT(STR(DAY((PDCDTTMP)->depDATE) + 100,3,0),2 )+', '+STR(YEAR((PDCDTTMP)->depDATE),4 )
		   
		   @ PROW()+8,14-5 SAY XDATE
			
		   SIGNERS->(dbseek(CLIENT->brcode+CLIENT->clntcode))

		   SETFONT('BOLD')
		   @ PROW()+3,14-5 SAY RTRIM(CLIENT->FULLNAME)
		   SETFONT ('UNBOLD')
		   @ PROW()+1,14-5 SAY RTRIM(CLIENT->ADDRESS1)

		   IF !EMPTY(CLIENT->ADDRESS2)
			  @ PROW()+1, 14-5 SAY RTRIM(CLIENT->ADDRESS2)
			  IF !EMPTY(CLIENT->ADDRESS3)
				 @ PROW()+1,14-5 SAY RTRIM(CLIENT->ADDRESS3)
			  ENDIF
		   ENDIF
		   
		   @ PROW()+2,14-5 SAY 'Attention:    ' 
				SETFONT('BOLD')
		   @ PROW(),14-5+16 SAY if(!empty(SIGNERS->signer),SIGNERS->signer,CLIENT->COLLECT)
			    SETFONT ('UNBOLD')
			if empty(SIGNERS->signer)
				@ PROW()+1,14-5+14 SAY RTRIM(CLIENT->POSITION)
			endif	
		   @ PROW()+2,14-5 SAY 'Re:           ' + Def_Acct((PDCDTTMP)->brcode+(PDCDTTMP)->acctno)
		   @ PROW()+1,14-5+14 SAY (PDCDTTMP)->bank
		   @ PROW()+1,14-5+14 SAY 'Check No. '+ (PDCDTTMP)->chkno
		   
						  ****                                                                                        90       100       110
						  ****123456789112345678921234567893123456789412345678951234567896123456789712345678981234567890123456789012345678901234567892
		   //@ PROW()+2,24-4 SAY "RE: "+chr(27)+chr(69)+"RENEWAL NOTICE"+chr(27)+chr(70)
		   @ PROW()+2,14-5 SAY 'Gentlemen:'
		   @ PROW()+2,14-5 SAY 'Our records show that above numbered check dated ' + if(len(_cHKDATE) <= 14 ,'  '+_cHKDATE,_cHKDATE) 
		   @ PROW(),76 SAY ' for the amount of'
		   //@ PROW()+1,14-5 SAY upper(fChar0700((PDCDTTMP)->chkamt))
		   PAGECENTER(prow()+1,100, upper(fChar0700((PDCDTTMP)->chkamt)) + ' PESOS ONLY'  )
		   @ PROW()+1,14-5 SAY '(P ' +  alltrim(trans((PDCDTTMP)->chkamt,'9,999,999.99')) + ')' + ' was dishonored by the drawee bank for the following reason(s):'
		   
		   //@ PROW()+2,20 SAY CHR(27)+CHR(69)+RTRIM((PDCDTTMP)->rem1)+CHR(27)+CHR(70)
		   SETFONT('BOLD')
			  PAGECENTER(prow()+2,100,  alltrim(upper(_dREASON[val(xREASON[CCC])]) )  )
		   SETFONT('UNBOLD')
		   
		   AMSHIST->(dbseek((PDCDTTMP)->brcode+(PDCDTTMP)->acctno+(PDCDTTMP)->ornumber))
		    zdate :=cMONTH(xPAYDATE[ccc]) +' '+ RIGHT(STR(DAY(xPAYDATE[ccc]) + 100,3,0),2 )+', '+STR(YEAR(xPAYDATE[ccc]),4 )
		   
		   @ PROW()+2,14-5 SAY 'The  amount of  the  foregoing check represents your  monthly amortization/rental for'
		   @ PROW()+1,14-5 SAY  zdate + '. Consequently, you are now in arrears for the amount of P'+ ;
				if(true_brch == '001',trans(tot_arrears(GTRANDATE,ccc,PDCDTTMP),'99,999,999.99'),trans(xT_ARREAR[ccc],'99,999,999.99') )
		   @ PROW()+1,14-5 SAY 'including penalties.'
		   //@ PROW()+1,14-5 SAY 'unfortunately  a  victim of a calamity yourself.'

		   @ PROW()+2,14-5 SAY 'Accordingly, demand is hereby made upon you to make good on your dishonored check and'      // EVR 01112007 - changed from Parametr->RENCONTACT
		   @ PROW()+1,14-5 SAY 'pay your arrearages within five (5) days from your receipt hereof. Should you fail or'
		   @ PROW()+1,14-5 SAY 'refuse to comply herewith, we shall  be  compelled  to  initiate legal action against'
		   @ PROW()+1,14-5 SAY 'you, including a criminal complaint for violation of Batas Pambansa Blg. 22.'

		   @ PROW()+3,14-5 SAY "Very truly yours,"
		   @ PROW()+4,14-5 SAY CHR(27)+CHR(69)+ALLTRIM(upper(g_NTC_SIGNEE))+CHR(27)+CHR(70)
		   @ PROW()+1,14-5 SAY ALLTRIM(g_NTC_POST)
		   //@ 55,22        SAY chr(27)+chr(15)+"Note: Late submission will only be accepted upon payment of Documentary Stamp Tax and Pro-Rata Premium."+chr(18)
		//   @ 57,22        say chr(27) + chr(15)+'THIS IS A SYSTEM-GENERATED LETTER AND IF ISSUED WITHOUT ALTERATION, THIS DOES NOT REQUIRE A SIGNATURE.'+chr(18)

		   
		   __EJECT()
		SETPRC(0,0) 
	next CCC
	
RETURN NIL

**************************************************
static function tot_arrears(_trndate,pos,PDCDTTMP)
**************************************************
local nretval := 0, arr_ := {} , ctr := 1, _days:=0 , _pdue :=0 ,narr_ := {}, _penalty := 0

PAYSKED->(dbsetorder(3))

if PAYSKED->(dbseek((PDCDTTMP)->brcode+(PDCDTTMP)->acctno+'D'))

	do while _trndate >= PAYSKED->paydate .and. PAYSKED->status == 'D'
		aadd(arr_,PAYSKED->paydate)
		aadd(narr_,PAYSKED->amtdue)
		_pdue += PAYSKED->amtdue
		PAYSKED->(dbskip(1))
	enddo
	
	if 	substr((PDCDTTMP)->acctno,5,5) == '10402' .or. substr((PDCDTTMP)->acctno,5,5) == '10403'
		do while ctr <= len(arr_)
			if gtrandate >  arr_[ctr] //.and. if(substr((PDCDTTMP)->acctno,5,5) != '10402' .and. substr((PDCDTTMP)->acctno,5,5) != '10403' ,5,0)
 			   _days := _trndate -  arr_[ctr]
			   _penalty += round((((narr_[ctr] * _days) * 0.05) / 30),2)
			endif	
			ctr++
		enddo
	else	
		do while ctr <= len(arr_)
			if gtrandate >  arr_[ctr]+5 //.and. if(substr((PDCDTTMP)->acctno,5,5) != '10402' .and. substr((PDCDTTMP)->acctno,5,5) != '10403' ,5,0)
				_days := _trndate -  arr_[ctr]
				_penalty += round((((narr_[ctr] * _days) * 0.05) / 30),2)
			endif	
		    ctr++
		enddo
	endif	
endif

/****
if PAYSKED->(dbseek(PDC_DTLS->brcode+PDC_DTLS->acctno+'D'))

	do while _trndate >= PAYSKED->paydate .and. PAYSKED->status == 'D'
		aadd(arr_,PAYSKED->paydate)
		aadd(narr_,PAYSKED->amtdue)
		_pdue += PAYSKED->amtdue
		PAYSKED->(dbskip(1))
	enddo
	
	if 	substr(PDC_DTLS->acctno,5,5) == '10402' .or. substr(PDC_DTLS->acctno,5,5) == '10403'
		do while ctr <= len(arr_)
			if gtrandate >  arr_[ctr] //.and. if(substr(PDC_DTLS->acctno,5,5) != '10402' .and. substr(PDC_DTLS->acctno,5,5) != '10403' ,5,0)
 			   _days := _trndate -  arr_[ctr]
			   _penalty += round((((narr_[ctr] * _days) * 0.05) / 30),2)
			endif	
			ctr++
		enddo
	else	
		do while ctr <= len(arr_)
			if gtrandate >  arr_[ctr]+5 //.and. if(substr(PDC_DTLS->acctno,5,5) != '10402' .and. substr(PDC_DTLS->acctno,5,5) != '10403' ,5,0)
				_days := _trndate -  arr_[ctr]
				_penalty += round((((narr_[ctr] * _days) * 0.05) / 30),2)
			endif	
		    ctr++
		enddo
	endif	
endif
****/

nretval :=  _penalty + _pdue


return nretval

*********************************************
static function select_rCheques(nACCTNO)
*********************************************

local mSELECTED, mOK_TO_SELECT,nRECNO := {},nREASON:= {}, nPAYDATE:={}, cCTR:=0
local nAMORT := {} , nT_ARREAR := {}

//memvar 
  // set device to screen
   mSCR := savescreen ( ,,, )
   setcolor ( NRM )
   
    aRECNO    := {} 
	xREASON   := {} 
	xPAYDATE  := {}
	xAMORT    := {}
	xT_ARREAR := {}
	cNOTICE   := 0
	d_PDC     := {}


if true_brch == '001'
 GLTRANHD->(dbgotop())
	if GLTRANHD->(dbseek((g_par_brch)+dtos(ddate)))
		do while GLTRANHD->trandate == ddate .and. g_par_brch == GLTRANHD->brcode
			if GLTRANHD->adjmntcode == '8' // exclusive for returned checks
				if RCHK_JV->(dbseek(GLTRANHD->brcode+GLTRANHD->trnumber))
					PDCDTBCK->(DBSETORDER(3))
					if PDCDTBCK->(dbseek(RCHK_JV->brcode+RCHK_JV->ORNUMBER))
						if DSHNRCHK->(dbseek(PDCDTBCK->brcode+PDCDTBCK->ORNUMBER)) 
							if DSHNRCHK->trandate == gTRANDATE
								if !DSHNRCHK->is_prn
									if AMSHIST->(dbseek(PDCDTBCK->brcode+PDCDTBCK->acctno+PDCDTBCK->ORNUMBER))
										ACCTMAST->(dbseek(PDCDTBCK->Brcode+PDCDTBCK->acctno))
										//aadd( d_PDC, '  '+ substr(ACCTMAST->acctname,1,15)+' ³ '+Def_Acct(PDCDTBCK->brcode+PDCDTBCK->Acctno)+' ³ '+trans(PDCDTBCK->chkamt,'999,999,999.99')+'³ ' + PDCDTBCK->chkno +' ³ '+dtoc(PDCDTBCK->depdate))
										aadd( d_PDC, '  '+ substr(ACCTMAST->acctname,1,15)+' ³ '+Def_Acct(PDCDTBCK->brcode+PDCDTBCK->Acctno)+' ³ '+trans(PDCDTBCK->chkamt,'999,999,999.99')+'³ ' + PDCDTBCK->chkno +' ³ '+dtoc(PDCDTBCK->depdate)+' ³ '+'PDCDTBCK')
										aadd( nRECNO,PDCDTBCK->(recno()) )
										aadd( nREASON,GLTRANHD->REASON )
										aadd( nPAYDATE,AMSHIST->refdate )
										aadd(   nAMORT, ACCTMAST->amort  )
										cNOTICE++
									endif
								endif
							endif	
						else
							if AMSHIST->(dbseek(PDCDTBCK->brcode+PDCDTBCK->acctno+PDCDTBCK->ORNUMBER))
								ACCTMAST->(dbseek(PDCDTBCK->Brcode+PDCDTBCK->acctno))
								//aadd( d_PDC, '  '+ substr(ACCTMAST->acctname,1,15)+' ³ '+Def_Acct(PDCDTBCK->brcode+PDCDTBCK->Acctno)+' ³ '+trans(PDCDTBCK->chkamt,'999,999,999.99')+'³ ' + PDCDTBCK->chkno +' ³ '+dtoc(PDCDTBCK->depdate))
								aadd( d_PDC, '  '+ substr(ACCTMAST->acctname,1,15)+' ³ '+Def_Acct(PDCDTBCK->brcode+PDCDTBCK->Acctno)+' ³ '+trans(PDCDTBCK->chkamt,'999,999,999.99')+'³ ' + PDCDTBCK->chkno +' ³ '+dtoc(PDCDTBCK->depdate)+' ³ '+'PDCDTBCK')
								aadd( nRECNO,PDCDTBCK->(recno()) )
								aadd( nREASON,GLTRANHD->REASON )
								aadd( nPAYDATE,AMSHIST->refdate )
								aadd(   nAMORT, ACCTMAST->amort  )
								cNOTICE++
							endif
						endif	
					endif //END OF PDCDTBCK
					
					PDC_DTLS->(DBSETORDER(3))
					if PDC_DTLS->(dbseek(RCHK_JV->brcode+RCHK_JV->ORNUMBER))
						if DSHNRCHK->(dbseek(PDC_DTLS->brcode+PDC_DTLS->ORNUMBER)) 
							if DSHNRCHK->trandate == gTRANDATE
								if !DSHNRCHK->is_prn
									if AMSHIST->(dbseek(PDC_DTLS->brcode+PDC_DTLS->acctno+PDC_DTLS->ORNUMBER))
										ACCTMAST->(dbseek(PDC_DTLS->Brcode+PDC_DTLS->acctno))
										//aadd( d_PDC, '  '+ substr(ACCTMAST->acctname,1,15)+' ³ '+Def_Acct(PDC_DTLS->brcode+PDC_DTLS->Acctno)+' ³ '+trans(PDC_DTLS->chkamt,'999,999,999.99')+'³ ' + PDC_DTLS->chkno +' ³ '+dtoc(PDC_DTLS->depdate))
										aadd( d_PDC, '  '+ substr(ACCTMAST->acctname,1,15)+' ³ '+Def_Acct(PDC_DTLS->brcode+PDC_DTLS->Acctno)+' ³ '+trans(PDC_DTLS->chkamt,'999,999,999.99')+'³ ' + PDC_DTLS->chkno +' ³ '+dtoc(PDC_DTLS->depdate)+' ³ '+'PDC_DTLS')
										aadd( nRECNO,PDC_DTLS->(recno()) )
										aadd( nREASON,GLTRANHD->REASON )
										aadd( nPAYDATE,AMSHIST->refdate )
										aadd(   nAMORT, ACCTMAST->amort  )
										cNOTICE++
									endif
								endif
							endif	
						else
							if AMSHIST->(dbseek(PDC_DTLS->brcode+PDC_DTLS->acctno+PDC_DTLS->ORNUMBER))
								ACCTMAST->(dbseek(PDC_DTLS->Brcode+PDC_DTLS->acctno))
								//aadd( d_PDC, '  '+ substr(ACCTMAST->acctname,1,15)+' ³ '+Def_Acct(PDC_DTLS->brcode+PDC_DTLS->Acctno)+' ³ '+trans(PDC_DTLS->chkamt,'999,999,999.99')+'³ ' + PDC_DTLS->chkno +' ³ '+dtoc(PDC_DTLS->depdate))
								aadd( d_PDC, '  '+ substr(ACCTMAST->acctname,1,15)+' ³ '+Def_Acct(PDC_DTLS->brcode+PDC_DTLS->Acctno)+' ³ '+trans(PDC_DTLS->chkamt,'999,999,999.99')+'³ ' + PDC_DTLS->chkno +' ³ '+dtoc(PDC_DTLS->depdate)+' ³ '+'PDC_DTLS')
								aadd( nRECNO,PDC_DTLS->(recno()) )
								aadd( nREASON,GLTRANHD->REASON )
								aadd( nPAYDATE,AMSHIST->refdate )
								aadd(   nAMORT, ACCTMAST->amort  )
								cNOTICE++
							endif
						endif	
					endif
				endif		
			endif
			GLTRANHD->(dbskip(1))
		enddo	
	endif	
else
	
	if !xPASSED
		create_temp()
		cCPSPARAM 	:= chk_par(dtoc(GTRANDATE))+;
					   chk_par(dtoc(dDATE))+;
					   chk_par(g_par_brch)
					   
		cTEXT2DBF := cps_reqst(cCPSPARAM,'PREP_NTICEDSHNR')
		waiton( 'Generating checks for printing',, 'n*/+w' )

		FT_FUSE('&g_CPS_PATH\'+cTEXT2DBF)
		DO WHILE !FT_FEOF()
			cText := FT_FREADLN()
			if empty(cTEXT)
				exit
			endif
			cText := s_Parse( cText, "~" )
			
			if PDCHKDBF->( netlock( 'A', 0 ) )
				PDCHKDBF->ACCTNAME :=      cText[1]
				PDCHKDBF->ACCTNO   :=      cText[2]
				PDCHKDBF->CHKAMT   :=  val(cText[3])
				PDCHKDBF->CHKNO    :=      cText[4]	
				PDCHKDBF->DEPDATE  := ctod(cText[5])
				PDCHKDBF->FROMDBF  :=      cText[6]
				PDCHKDBF->NRECNO   :=  val(cText[7])
				PDCHKDBF->CREASON  :=      cText[8]			
				PDCHKDBF->DREFDATE := ctod(cText[9])
				PDCHKDBF->NAMORT   :=  val(cText[10])
				PDCHKDBF->T_ARREAR :=  val(cText[11])
			endif	
			
			FT_FSKIP(1)
		ENDDO
			PDCHKDBF->(DBCOMMIT())
			PDCHKDBF->(DBUNLOCK())

		FT_FUSE()                // close file
		xPASSED := .t.
	endif
	
		PDCHKDBF->(dbgotop())
		do while !PDCHKDBF->(eof())
			aadd( d_PDC, '  ' + PDCHKDBF->acctname+' ³ '+PDCHKDBF->Acctno+' ³ '+trans(PDCHKDBF->chkamt,'999,999,999.99')+'³ ' +PDCHKDBF->chkno +' ³ '+dtoc(PDCHKDBF->depdate)+' ³ '+PDCHKDBF->FROMDBF)
			aadd( nRECNO   ,PDCHKDBF->Nrecno )
			aadd( nREASON  ,PDCHKDBF->CREASON )
			aadd( nPAYDATE ,PDCHKDBF->Drefdate )
			aadd(   nAMORT ,PDCHKDBF->Namort  )
			aadd( nT_ARREAR,PDCHKDBF->T_ARREAR  )
			cNOTICE++
			PDCHKDBF->(dbskip(1))
		enddo

	waitoff()
	
	
endif	


      fshadow( 08, 1, 21, 78, 2 , 'w/rb+,w/n,,,w/gr+')
	  dispbox(08, 1, 21, 78, 1,'n/w+')
	  //devpos ( 08,03) ; devout ( 'UNIT / MODEL', 'W/W+' )
	  devpos ( 10,03) ; devout ( 'Account Name       Account No.      Amount        Check No.   Deposit Date', 'W/RB+' )
      devpos ( 20, 4) ; devout ( '<Spacebar>-Select/Unselect <Alt+A>-Select All <ESC>-EXIT <ENTER>-Print', 'W/GR+' )
      mPDC  := 1
      //devpos ( 20, 3 ) ; devout ( 'Selected   0 / ' + trans( mUNITS, '99'), 'W/GR+')
      mSELECTED      :=  0 ; mOK_TO_SELECT  := .t.
	  
	  @ 12,3 clear TO 19,77

	  dispbox(11, 2, 19, 77, 1,'w/rb')
	  	//devpos ( 19,03) ; devout ( '                Á                             Á               Á         Á', 'W/RB+' )
		@ 11, 21 say 'Â' color 'W/RB'
		@ 11, 31 say 'Â' color 'W/RB'
		@ 11, 47 say 'Â' color 'W/RB'
		@ 11, 65 say 'Â' color 'W/RB'		
		@ 19, 21 say 'Á' color 'W/RB'
		@ 19, 31 say 'Á' color 'W/RB'
		@ 19, 47 say 'Á' color 'W/RB'
		@ 19, 65 say 'Á' color 'W/RB'
	
		USERDRAW()     
		
	//alert(str(nRECNO[1])+' '+nREASON[1]+' '+dtos(nPAYDATE[1])+' '+str(nAMORT[1]))	
		
    do while mPDC != 0
         mPDC := achoice ( 12, 3, 18, 76, d_PDC, mOK_TO_SELECT ,'_xKEY_PRESS', mPDC )

        do case
            case lastkey () == K_ENTER //.or. lastkey() == K_ESC
               mGCTR := 0
			   
               mCTR  := 0
               for i := 1 to len ( d_PDC )
                   if left ( d_PDC [i], 1 ) == 'û'
                      mCTR++
						//aadd( aRECNO, nRECNO[i] )
						//ALERT(RIGHT ( d_PDC [i], 8 ))
						aadd( aRECNO, {nRECNO[i] , RIGHT ( d_PDC [i], 8 )} )
						aadd( xREASON,nREASON[i])
						aadd( xPAYDATE,nPAYDATE[i])
						aadd( xAMORT, nAMORT[i])
						if true_brch != '001'
							aadd( xT_ARREAR, nT_ARREAR[i])
						endif
						//ALERT(STR(i))
						//ALERT(STR(aRECNO[i][1])+' '+aRECNO[i][2])
                   endif
               next i

			   if empty(d_PDC)
					error ( 'There were 0 Checks Found.' )
					DSHNRCHK->(dbsetorder(2))
					if DSHNRCHK->(dbseek(g_par_brch+dtoc(gtrandate)))
						do while g_par_brch+dtoc(gtrandate) == DSHNRCHK->BRCODE+dtoc(DSHNRCHK->TRANDATE)
							 if DSHNRCHK->(netlock('R',0))
								DSHNRCHK->IS_PRN    := .F.
							 endif   
							DSHNRCHK->(dbskip(1))
						enddo
						DSHNRCHK->(dbunlock())
						DSHNRCHK->(dbcommit())	
					endif
				exit
			   endif
			   
			   
               if  mCTR <= 0
                   error ( 'There were 0 Checks Selected/Found.' )
                  mPDC := 1
               endif

            case lastkey () == 32
               if left( d_PDC [ mPDC ], 1 ) = 'û'
                  d_PDC [ mPDC ] := ' ' + right ( d_PDC [ mPDC ], len ( d_PDC [ mPDC ]  ) - 1 )
                  mSELECTED--
                  if ( mSELECTED < 0, mSELECTED := 0, Nil )
               else
				
                // if ( mSELECTED < mPDC )
                     d_PDC [ mPDC ] := 'û' + right ( d_PDC [ mPDC ], len ( d_PDC [ mPDC ] ) - 1 )
                     mSELECTED++ ; mPDC++
                     if mPDC > len ( d_PDC )
                        mPDC := len ( d_PDC )
                     endif
                // else
                //    tone( 300, 5 )
                // endif
               endif
             //  devpos ( 20, 3 ) ; devout ( 'Selected  '+ trans( mSELECTED,'99')+' / ' + trans( mUNITS, '99'), 'W/GR+')
			case lastkey() == K_ALT_A
				for aaa := 1 to len(d_PDC)
					if left( d_PDC [ aaa ], 1 ) = 'û'
						d_PDC [ aaa ] := ' ' + right ( d_PDC [ aaa ], len ( d_PDC [ aaa ]  ) - 1 )
						mSELECTED--
						if ( mSELECTED < 0, mSELECTED := 0, Nil )
					else
					
						d_PDC [ aaa ] := 'û' + right ( d_PDC [ aaa ], len ( d_PDC [ aaa ] ) - 1 )
						mSELECTED++ ; mPDC++
						if mPDC > len ( d_PDC )
						mPDC := len ( d_PDC )
						endif
					endif
				next aaa
				
			 case lastkey () == K_ENTER //.or. lastkey() == K_ESC
				return
			case lastkey () == K_ESC
			

        endcase
     enddo



   restscreen ( ,,,, mSCR )
 //  set device to printer
return .t.

static function USERDRAW()        // draw lines/field separators
   local i
   setcolor(gNORMAL)
   for i = 12 to 18
      //if mOBJ:rowpos != i-8
         @ i,21 say chr(179)
         @ i,31 say chr(179)
         @ i,47 say chr(179)	  
	  	 @ i,65 say chr(179)	  
      //endif
   next
   //setcolor(gBRIGHT)
   return


*****************************
static function Def_Acct(nACCTNO)
*****************************
local macctno := ' '

	if substr(nACCTNO,8,3) == '103' 
		mACCTNO := 'L-'+ RIGHT(nACCTNO,5)
	elseif substr(nACCTNO,8,3) == '104' .and.  substr(nACCTNO,8,5) != '10402' .and. substr(nACCTNO,8,5) != '10403'
		mACCTNO := 'M-'+ RIGHT(nACCTNO,5)
	elseif substr(nACCTNO,8,5) == '10402'
		mACCTNO := 'I-'+ RIGHT(nACCTNO,5)
	elseif substr(nACCTNO,8,5) == '10403'
		mACCTNO := 'R-'+ RIGHT(nACCTNO,5)		
    endif

return macctno

/*------------------------------------*/
static function disp_status( mstatus )
/*------------------------------------*/
return eval({|x| x := space(13)+'Active       '+;
                                'Past Due     '+;
                                'In Litigation'+;
                                'Repossessed  '+;
                                'Written-off  ',;
                                ' '+substr(x,val(mstatus)*13+1,13) })
*-------------------------------------------------------------------------------
static FUNCTION DISPCLNTNAME( mCLNTCODE, nLEN )

IF nLEN == NIL .OR. EMPTY(nLEN)
   nLEN := 50
ENDIF

return eval ({ |x,y| x:= savedbf ( x ),;
                     Client->( dbsetorder(1) ),;
                     Client->( dbseek(mclntcode) ),;
                     y:= left( Client->FULLNAME, nLEN ),;
                     restdbf( x ),;
                     y })

*---------------------------------------------------------------------------------
FUNCTION _xKEY_PRESS ( STATUS, CURR_ELEM, CURR_ROW )
   local key := lastkey()
   do case
      case key == K_ESC
         return 0
      case key == K_ENTER
         return 0
      case key == K_SPACE
          tone( 1600, 1) ; tone( 800, 1)
         tone( 800, 1)
         return 1
	  case key == K_ALT_A
          tone( 1600, 1) ; tone( 800, 1)
         tone( 800, 1)
         return 1	  
    endcase
return 2
*---------------------------------------------------------------------------------
********************************
*
static function create_temp()
********************************
   memvar cTEMP, cTEMP2
   local cfullpath
   local mretval := .f.
   local mstruct := { { 'ACCTNAME'  ,'C',15,00 } ,;  
                      { 'ACCTNO'    ,'C',7,00  } ,;
				      { 'CHKAMT'    ,'N',14,02 } ,;
					  { 'CHKNO'     ,'C',15,00 } ,;
					  { 'DEPDATE'   ,'D',8,00  } ,;
					  { 'FROMDBF'   ,'C',8,00  } ,;
					  { 'NRECNO'    ,'N',12,00 } ,;
					  { 'CREASON'   ,'C',1,00  } ,;
					  { 'DREFDATE'  ,'D',8,00  } ,;
					  { 'NAMORT'    ,'N',14,2  } ,;
					  { 'T_ARREAR' ,'N',14,02 }  ;
                    }

   cTEMP  := _uniqfile()
	//cTEMP2 :=  uniqfile('NTX')

//    dbcreate ( ( cTEMP ) , mstruct )

//   cTEMP  := 'c:\' + cTEMP
  // cTEMP2 := 'c:\' + cTEMP2

   cfullpath  :=  ( cTEMP )
//    dbcreate ( 'c:\'+cfullpath , mstruct )         // abb june 03, 2004
   dbcreate (  'c:\lotus\'+cfullpath , mstruct )         // abb june 03, 2004

   if valtype ( cTEMP ) != 'U'
      if netuse ( 'c:\lotus\'+(cTEMP) ,.t.,0 )
      //   index on str(JRSNO) to 'c:\lotus\'+(cTEMP)  // facility+acctname
	  //	index on brcode+CLNTNAME to 'c:\lotus\'+(cTEMP2)
             mretval := .t.
      //       set index to 'c:\lotus\'+(cTEMP) ,'c:\lotus\'+(cTEMP2)
      endif
   endif

return

********************************
*
static function _uniqfile()
********************************
   local mfiname, mrandnum := 'PDCHKDBF'
   do while .t.
      //mrandnum := substr(time(),1,2) + substr(time(),4,2) + substr(time(),7,2)
//      mfiname  := 'TM' + mrandnum
      mfiname  :=  mrandnum     // ABB 06.03.2004
      if file('c:\lotus\'+mfiname+'.dbf')                 // test if text file exist
			ferase('c:\lotus\'+mfiname+'.dbf')
         loop
      else
         exit
      endif
   enddo
return mfiname 
*-------------------------------------------------------------------------------
static function s_Parse( cText, cDelim )
	local nPos, aList := {}

   if (cDelim==Nil) .or. empty(cDelim)
      cDelim := ","
   endif

	while ( nPos := At(cDelim, cText)) != 0
		AAdd( aList, substr(cText, 1, nPos-1) )
		cText := substr( cText, nPos+1 )
	enddo
	AAdd( aList, cText )
return aList