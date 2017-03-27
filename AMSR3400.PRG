/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   program id.........:  amsr3700.prg                                       Æ»
³   description........:  certification of LTO custody                       ³Ì»
³   author.............:  noel b. santos                                     ³ºº
³   date...............:  20.09.2001                                         ³ºº
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´ºº
³                         u p d a t e s                                      ³ºº
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´ºº
³        who        ³     when          ³               why                  ³ºº
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´ºº
³                   ³                   ³                                    ³ºº
³Engr. Mike Espina  ³January 7, 1999    ³Validation on printing of renewal   ³ºº
³                   ³                   ³                                    ³ºº
³Abb                ³March 23, 2001     ³Contact person's name transferred   ³ºº
³                   ³                   ³to Parametr->rencontact, phone to   ³ºº
³                   ³                   ³to Parametr->renphone               ³ºº
³                   ³                   ³                                    ³ºº
³Noel B. Santos     ³October 18, 2001   ³Corrected font size error in        ³ºº
³                   ³                   ³printing pages that skips the       ³ºº
³                   ³                   ³first page.                         ³ºº
³                   ³                   ³                                    ³ºº
³Janet B. Salvador  ³June 27, 2002      ³Add "of premium payment" on         ³ºº
³                   ³                   ³2nd line of 2nd paragraph.          ³ºº
³                   ³                   ³                                    ³ºº
³                   ³                   ³                                    ³ºº
³Nathan B. Pineda   ³March 8, 2004      ³Add option renewal notice           ³ºº
³                   ³                   ³creating 1st & 2nd notice           ³ºº
³                   ³                   ³                                    ³ºº
³ Red K. Guyala     ³September 22, 2004 ³Additional renewal notices printing ³ºº
³                   ³                   ³                                    ³ºº
³                   ³October 6, 2004    ³Change format of acct no. from 5    ³ºº
³                   ³                   ³ digits to 16 including 2 dash.     ³ºº
³                   ³                   ³change of index keys.               ³ºº
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
#defi K_SPACEBAR   32
#defi microfeed    chr( 27 ) + 'J' + chr( 18 )
#defi xprydate  right( space(5) + a_month[ if( month(Ctrlinfo->Insexpry) > 0, month( Ctrlinfo->Insexpry ), 13 ) ],5 )  +' '+ str(day(Ctrlinfo->Insexpry),2)+', '+str(year(Ctrlinfo->Insexpry),4)
memvar  AX_LEVEL, gUSER_ID
setcursor(0)
if !chkpass( procname(), AX_LEVEL, gUSER_ID )
	//NOTHING WILL HAPPEN
else
	begin sequence
	aOpen9999()
	aMain9999()
	end sequence
	dbcloseall()
endif
__mrelease( '*', .t. )
return nil
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
Static Function aMain9999()
	local mu:=savescreen(,,,),gf:=savedbf(),bf:=setcursor(),rnchoice
	private mmonth := month(gtrandate), myear := year(gtrandate)
   PRIVATE nacctno:=SPACE(16+4)        && RED 100604 spac(5)   RED 031705 '+4
   fshadow( 11,29,13,66+4,2,'n/bg' )   && RED 100604 fshadow( 11,30,13,60,2,'n/bg' )  RED 031705 '+4
	setcolor( 'w/bg,n/w,,,w+/bg' )

   @ 12, 31 say 'Account Number  ' get nacctno picture '@R 999-9999-99999-99999';     && RED 031705 ADDED '999-
                                     when eval( { || getacctno(), .f. } )       && RED 100604  picture '@R 99999'
	read

   ACCTMAST->(DBSETORDER(1))    && RED 100604  Acctmast->(dbsetorder(2))
	if lastkey() <> K_ESC .and. Acctmast->(dbseek(nacctno)) 
		if Acctmast->osbal <= 0
			Error('The outstanding balance is already 0!')
		else
         if Ctrlinfo->(dbseek( nACCTNO ) )  && RED 031705 REPLACED 'Acctmast->Acctno

				fprnren_option()
			else
				Error('No existing Collateral...')
			endif
		endif
	endif
   ACCTMAST->(DBSETORDER(3))        && RED 100604
	restdbf(gf);restscreen(,,,,mu);setcursor(bf)
return nil
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
Static function getacctno()
	local ndbf:=select(),nclntno:=spac(7),nval,mu
	local o_scr:=savescreen(,,,),msel,xx_,mclntcode
	local col_ := { ;
		tbcolumnnew( 'Client Name ' , { || Substr(Client->Fullname, 1, 30 ) } ),;
		tbcolumnnew( 'Short Name '  , { || Client->Shrtname } ),;
		tbcolumnnew( 'Code '        , { || Client->Clntcode } ) }
	nval:=.t.
   Client->(dbsetorder(3))
   *nclntno :=flook_ONLINE( .t.,'Client','spac(30)','Client File',3,4,,1,1,.f.,col_ )
   nclntno :=ach_look2() //RLV 2:41 PM 8/8/2008
   //flook_ONLINE( .t.,'Client','spac(30)','Client File',3,4,45,1,1,.f.,col_,,,,.T. )     && RED 031705 ADDED '.T.

   if lastkey() <> K_ESC .AND. CURRBRCH(CLIENT->BRCODE)     && RED 031705 ADDED 'CURRBRCH(..
		Acctmast->(dbsetorder(2))
      *if Acctmast->(dbseek(nacctno))        && RED 031705
      IF ACCTMAST->(DBSEEK(nCLNTNO))
         mclntcode:=ACCTMAST->BRCODE+Acctmast->Clntcode     && RED 031705 ADDED 'ACCTMAST->BRCODE
         mu := { '  Client N§  ' + tran( mclntcode, '@R 999-99-99999' ),;    && RED 031705 '999-
            '  Client Name  ' + left( dispclntname( mclntcode,40 ),40 ),;
				repl( 'Ä', 59 ),;
            '     Acct. N§       Status           Unit ',;
				repl( 'Ä',59 ) }
         /*  RED 100604
			Acctmast->( dbeval({|| aadd( mu,' '+Substr(Acctmast->Acctno,-5,5)+space(7)+substr(upper(disp_status(Acctmast->Status)),1,12)+substr(Acctmast->Unit,1,30)) },,;
				{|| Acctmast->CLNTCODE==mclntcode .and. !Acctmast->(eof()) }) )
         */
         ACCTMAST->( DBEVAL({|| AADD( MU,' '+ACCTMAST->BRCODE+'-'+LEFT(ACCTMAST->ACCTNO,4)+'-'+SUBSTR(ACCTMAST->ACCTNO,5,5)+'-'+RIGHT(ACCTMAST->ACCTNO,5)+SPACE(2)+SUBSTR(UPPER(DISP_STATUS(ACCTMAST->STATUS)),1,12)+SUBSTR(ACCTMAST->UNIT,1,30)) },,;
            {|| ACCTMAST->BRCODE+ACCTMAST->CLNTCODE==mCLNTCODE .AND. !ACCTMAST->(EOF()) }) )          && RED 031705 'ACCTMAST->BRCODE

			msel:={ .f., .f., .f., .f., .f. }
			for xx_ := 1 to len(mu) - 5
				aadd( msel , .t. )
			next xx_
			fshadow(10,09,21,69,2,'n/bg')
			while .t.
				mcx := achoice( 11, 10, 20, 68, mu, msel )
				if lastkey() <> K_LEFT .and. lastkey() <> K_RIGHT
               if lastkey() == K_RETURN
                  nACCTNO :=  SUBSTR( MU[ MCX ],   2,3) +; && RED 031705
                              SUBSTR( MU[ MCX ], 2+4,4) +;
                              SUBSTR( MU[ MCX ], 7+4,5) +;
                              SUBSTR( MU[ MCX ],13+4,5)    && RED 100604  nacctno := substr( mu[ mcx ],2, 5 )
						exit
					elseif lastkey() == K_ESC
                  nacctno :=space(16+4)      && RED 031705 '+4
						nval:=.f.
						exit
					endif
				endif
			enddo
		else
			nval:=.f.
			error('No existing Account....')
		endif
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
Function fprnren01()
	local pgn:=1,xdate := cmonth(gtrandate)+ ' '+ right(str(day(gtrandate) + 100,3,0),2 )+', '+str(year(gtrandate),4 )
	local has_xpre:=' ',b_low:=' '
	local a_month := { 'Jan.','Feb.','Mar.','Apr.','May','June','July','Aug.','Sept.','Oct.','Nov.','Dec.','Xxxxx' }
	setprc(0,0)
	dbselectarea('Ctrlinfo')
	while Ctrlinfo->Acctno == Acctmast->Acctno
		if( Ctrlinfo->Insexpry <= gTrandate, eval( {|| has_xpre := 'has  expired  for the', b_low:= 'unit specified below.' }) ,;
			eval( {|| has_xpre := 'will be  expiring for', b_low:= 'the unit specified below.' }) )
		/* SETFONT('INIT')
		SETFONT('NORMAL')
		
		@ prow()+1,10 say 'FIRST NOTICE'	 */
		@ prow()+1,0 say ''         //noels
		SETFONT('INIT')
		setfont('NORMAL')
		setfont('ELITE')
		SETFONT('NLQ')
		@ prow() + 10, 14 say xdate
		setfont ('BOLD')
		@ prow()+2, 14 say Client->Fullname
		SETFONT ('UNBOLD')
		@ prow()+1, 14 say Client->Address1
		if !empty(Client->Address2)
			@ prow()+1, 14 say Client->Address2
		endif
		if !empty(Client->Address3)
			@ prow()+1, 14 say Client->Address3
		endif
		@ prow()+2, 14 say 'Gentlemen,'                                                                 //
		if alltrim(Ctrlinfo->Insby) == '2'
			@ prow()+2, 14 say 'Please be reminded that the leased/loaned unit you insured thru our Paseo In-'
			@ prow()+1, 14 say 'surance Agency Inc. will expire on '+ xprydate +'. The description is as fol-'
			@ prow()+1, 14 say 'lows:'
			@ prow()+2,15 say  '    Unit                    : ' + SUBSTR(Ctrlinfo->Coltype,1,49 )
			if !empty(Ctrlinfo->Plateno)
				@ prow()+1,15 say  '    Plate                   : ' + alltrim(Ctrlinfo->Plateno)
			endif
			@ prow()+1,15 say  '    Motor / Serial Number   : ' + Alltrim(Ctrlinfo->Motorno) + if( !empty(Ctrlinfo->Motorno) .and. !empty(Ctrlinfo->Serialno) ,' / ','' ) + Ctrlinfo->Serialno
			@ prow()+1,15 say  '    Insurance Policy Number : ' + Ctrlinfo->Inspolcy
         @ prow()+1,15 say  '    Insurance Company       : ' + eval( { || Insuranc->(dbseek(CTRLINFO->BRCODE+Ctrlinfo->Insco,.f.)),Insuranc->Insname } ) && RED 031705 ADDED 'CTRLINFO->BRCODE
			@ prow()+1,15 say  '    Insurance Expiry Date   : ' + Dtoc(Insexpry)
         @ prow()+1,15 say  '    ORIX METRO Account No.  : ' + Trans( Ctrlinfo->Acctno,'@R 999-9999-99999-99999')     && RED 031705 ADDED '999-
			@ prow()+2, 14 say 'Please confirm if we will renew the insurance coverage. We will appreciate it'
			@ prow()+1, 14 say 'if you will renew  the insurance  coverage from us. Do  not hesitate  to call'
			//@ prow()+1, 14 say Parametr->rencontact at 892-0481 to 96 loc. 35 for further details. Attached is the'
			//@ prow()+1, 14 say Parametr->rencontact at 892-0481 to 96 loc. 35 for further details. Attached is the'
			@ prow()+1, 14 say padr(alltrim(Parametr->rencontact),15)+' at '+padr(alltrim(Parametr->renphone),21)+' for further details. Attached is the'
			@ prow()+1, 14 say 'premium computation for your information.'
			@ prow()+2, 14 say 'Thank you and hope to hear from you soon.'
		else
			@ prow()+2, 14 say 'We would like to inform you that your insurance  policy '+has_xpre
			@ prow()+1, 14 say b_low
			@ prow()+2,15 say  '    Unit                    : ' + SUBSTR(Ctrlinfo->Coltype,1,49 )
			if !empty(Ctrlinfo->Plateno)
				@ prow()+1,15 say  '    Plate                   : ' + alltrim(Ctrlinfo->Plateno)
			endif
			@ prow()+1,15 say  '    Motor / Serial Number   : ' + Alltrim(Ctrlinfo->Motorno) + if( !empty(Ctrlinfo->Motorno) .and. !empty(Ctrlinfo->Serialno) ,' / ','' ) + Ctrlinfo->Serialno
			@ prow()+1,15 say  '    Insurance Policy Number : ' + Ctrlinfo->Inspolcy
         @ prow()+1,15 say  '    Insurance Company       : ' + eval( { || Insuranc->(dbseek(CTRLINFO->BRCODE+Ctrlinfo->Insco,.f.)),Insuranc->Insname } )    && RED 031705 ADDED 'CTRLINFO->BRCODE
			@ prow()+1,15 say  '    Insurance Expiry Date   : ' + Dtoc(Insexpry)
         @ prow()+1,15 say  '    ORIX METRO Account No.  : ' + Trans( Ctrlinfo->Acctno,'@R 999-9999-99999-99999')     && RED 031705 '999-
			@ prow()+2,14 say  'Please submit the  original copy of the renewed  policy and the  official re-'
			@ prow()+1,14 say  'ceipt of premium payment as soon as possible. If you have not yet insured the'
			//@ prow()+1,14 say  'be glad to assist you. Please call Christine Chio at 892-0481 to 96 local 35.'
			@ prow()+1,14 say  'unit, we shall be glad to assist you.  Please call '+alltrim(Parametr->rencontact)+' at ' 
			@ prow()+1,14 say  alltrim(Parametr->renphone)+'.'
			//@ prow()+1,14 say  'Please disregard this notice if payment has been made.'
			@ prow()+2,14 say  'Thank you.'
		endif
		@ prow()+3,14 say  'Very truly yours,'
		@ prow()+3,14 say chr(27) + chr(69) + alltrim(Parametr->Ins_signee) + chr(27)+chr(70)
		@ prow()+1,14 say Alltrim( Parametr->sign_post )
		if alltrim(Ctrlinfo->Insby) == '2'
			@ prow()+3, 14 say 'Conforme:'
		endif
		@ prow()+4, 14 say 'Encl: List of Accredited Insurance Companies'
		@ prow()+1, 0 say ''
		__eject()
		Ctrlinfo->(dbskip())
	enddo
return nil
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
Function fprnren011()
	local pgn:=1,xdate := cmonth(gtrandate)+ ' '+ right(str(day(gtrandate) + 100,3,0),2 )+', '+str(year(gtrandate),4 )
	local has_xpre:=' ',b_low:=' '
	local a_month := { 'Jan.','Feb.','Mar.','Apr.','May','June','July','Aug.','Sept.','Oct.','Nov.','Dec.','Xxxxx' }
	setprc(0,0)
	//ALERT('2')
	dbselectarea('Ctrlinfo')
   while CTRLINFO->BRCODE+Ctrlinfo->Acctno == ACCTMAST->BRCODE+Acctmast->Acctno
		if( Ctrlinfo->Insexpry <= gTrandate, eval( {|| has_xpre := 'has  expired  for the', b_low:= 'unit specified below.' }) ,;
			eval( {|| has_xpre := 'will be  expiring for', b_low:= 'the unit specified below.' }) )
		@ prow()+1,0 say ''         //noels
		setfont('NORMAL')
		setfont('ELITE')
		SETFONT('NLQ')
		@ prow() + 10, 14 say xdate
		setfont ('BOLD')
		@ prow()+2, 14 say Client->Fullname
		SETFONT ('UNBOLD')
		@ prow()+1, 14 say Client->Address1
		if !empty(Client->Address2)
			@ prow()+1, 14 say Client->Address2
		endif
		if !empty(Client->Address3)
			@ prow()+1, 14 say Client->Address3
		endif
		@ prow()+2, 14 say 'Gentlemen,'                                                                 //
      @ prow()+2, 14 say 'We would like to inform you that your insurance policy will be expiring for'
      @ prow()+1, 14 say 'the unit specified below.'
      @ prow()+2,15 say  '    Unit                    : ' + SUBSTR(Ctrlinfo->Coltype,1,49 )
		if !empty(Ctrlinfo->Plateno)
			@ prow()+1,15 say  '    Plate                   : ' + alltrim(Ctrlinfo->Plateno)
		endif
		@ prow()+1,15 say  '    Motor / Serial Number   : ' + Alltrim(Ctrlinfo->Motorno) + if( !empty(Ctrlinfo->Motorno) .and. !empty(Ctrlinfo->Serialno) ,' / ','' ) + Ctrlinfo->Serialno
		@ prow()+1,15 say  '    Insurance Policy Number : ' + Ctrlinfo->Inspolcy
      @ prow()+1,15 say  '    Insurance Company       : ' + eval( { || Insuranc->(dbseek(CTRLINFO->BRCODE+Ctrlinfo->Insco,.f.)),Insuranc->Insname } )      && RED 031705 'CTRLINFO->BRCODE
		@ prow()+1,15 say  '    Insurance Expiry Date   : ' + Dtoc(Insexpry)
      @ prow()+1,15 say  '    ORIX METRO Account No.  : ' + Trans( Ctrlinfo->Acctno,'@R 999-9999-99999-99999')     && RED 031705 '999-
		@ prow()+2, 14 say 'Please submit the original copy of the renewed policy and the official'
		@ prow()+1, 14 say 'receipt of premium payment as soon as possible. If you have not yet insured'
		@ prow()+1, 14 say 'the unit, we shall be glad to assist you. Please call ' + alltrim(Parametr->rencontact)
		@ prow()+1, 14 say 'at '+alltrim(Parametr->renphone)
		@ prow()+2, 14 say 'Thank you.'
		@ prow()+3,14 say  'Very truly yours,'
		@ prow()+3,14 say chr(27) + chr(69) + alltrim(Parametr->Ins_signee) + chr(27)+chr(70)
		@ prow()+1,14 say Alltrim( Parametr->sign_post )
		if alltrim(Ctrlinfo->Insby) == '2'
			@ prow()+3, 14 say 'Conforme:'
		endif
		@ prow()+4, 14 say 'Encl: List of Accredited Insurance Companies'
		@ prow()+4, 14 say 'Note: Please disregard this notice if you have already submitted the policy renewal'
		__eject()
		Ctrlinfo->(dbskip())
	enddo
return nil
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
Function fprnren012()
	local pgn:=1,xdate := cmonth(gtrandate)+ ' '+ right(str(day(gtrandate) + 100,3,0),2 )+', '+str(year(gtrandate),4 )
	local has_xpre:=' ',b_low:=' '
	local a_month := { 'Jan.','Feb.','Mar.','Apr.','May','June','July','Aug.','Sept.','Oct.','Nov.','Dec.','Xxxxx' }
	setprc(0,0)
	//ALERT('3')
	dbselectarea('Ctrlinfo')
   while CTRLINFO->BRCODE+Ctrlinfo->Acctno == ACCTMAST->BRCODE+Acctmast->Acctno
		if( Ctrlinfo->Insexpry <= gTrandate, eval( {|| has_xpre := 'has  expired  for the', b_low:= 'unit specified below.' }) ,;
			eval( {|| has_xpre := 'will be  expiring for', b_low:= 'the unit specified below.' }) )
		@ prow()+1,0 say ''         //noels
		setfont('NORMAL')
		setfont('ELITE')
		SETFONT('NLQ')
		@ prow() + 10, 14 say xdate
		setfont ('BOLD')
		@ prow()+2, 14 say Client->Fullname
		SETFONT ('UNBOLD')
		@ prow()+1, 14 say Client->Address1
		if !empty(Client->Address2)
			@ prow()+1, 14 say Client->Address2
		endif
		if !empty(Client->Address3)
			@ prow()+1, 14 say Client->Address3
		endif
		@ prow()+2, 14 say 'Gentlemen,'                                                                 //
		@ prow()+2, 14 say 'We would like to inform you that your insurance policy has expired for'
		@ prow()+1, 14 say 'the unit specified below.'
		@ prow()+2,15 say  '    Unit                    : ' + SUBSTR(Ctrlinfo->Coltype,1,49 )
		if !empty(Ctrlinfo->Plateno)
			@ prow()+1,15 say  '    Plate                   : ' + alltrim(Ctrlinfo->Plateno)
		endif
		@ prow()+1,15 say  '    Motor / Serial Number   : ' + Alltrim(Ctrlinfo->Motorno) + if( !empty(Ctrlinfo->Motorno) .and. !empty(Ctrlinfo->Serialno) ,' / ','' ) + Ctrlinfo->Serialno
		@ prow()+1,15 say  '    Insurance Policy Number : ' + Ctrlinfo->Inspolcy
      @ prow()+1,15 say  '    Insurance Company       : ' + eval( { || Insuranc->(dbseek(CTRLINFO->BRCODE+Ctrlinfo->Insco,.f.)),Insuranc->Insname } )   && RED 031705 'CTRLINFO->BRCODE
		@ prow()+1,15 say  '    Insurance Expiry Date   : ' + Dtoc(Insexpry)
      @ prow()+1,15 say  '    ORIX METRO Account No.  : ' + Trans( Ctrlinfo->Acctno,'@R 999-9999-99999-99999')     && RED 031705 '999-
		@ prow()+2, 14 say 'Please submit the original copy of the renewed policy and the official'
		@ prow()+1, 14 say 'receipt of premium payment as soon as possible. If you have not yet insured'
		@ prow()+1, 14 say 'the unit, we shall be glad to assist you. Please call ' + alltrim(Parametr->rencontact)
		@ prow()+1, 14 say 'at '+alltrim(Parametr->renphone)
		@ prow()+2, 14 say 'Thank you.'
		@ prow()+3,14 say  'Very truly yours,'
		@ prow()+3,14 say chr(27) + chr(69) + alltrim(Parametr->Ins_signee) + chr(27)+chr(70)
		@ prow()+1,14 say Alltrim( Parametr->sign_post )
		if alltrim(Ctrlinfo->Insby) == '2'
			@ prow()+3, 14 say 'Conforme:'
		endif
		@ prow()+4, 14 say 'Encl: List of Accredited Insurance Companies'
		@ prow()+4, 14 say 'Note: Please disregard this notice if you have already submitted the policy renewal'
		__eject()
		Ctrlinfo->(dbskip())
	enddo
return nil
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
static function _prn_first_metro_notice()
	local pgn := 1,xdate := cmonth(date())+ ' '+ right(str(day(date()) + 100,3,0),2 )+', '+str(year(date()),4 )
	local has_xpre := ' '
	local a_month  := { 'Jan.','Feb.','Mar.','Apr.','May','June','July','Aug.','Sept.','Oct.','Nov.','Dec.','Xxxxx' }
	local amount
	dbselectarea('Ctrlinfo')
	//ALERT('4')
   while CTRLINFO->BRCODE+Ctrlinfo->Acctno == ACCTMAST->BRCODE+Acctmast->Acctno
		amount := 0
		fshadow( 08,30,12,65,2,'n/bg' )
		setpos(09, 32)
		dispout('Amount     ')
		setpos(10, 32)
		dispout('Motor No   ' + ctrlinfo->motorno)
		setpos(11, 32)
		dispout('Serial No  ' + ctrlinfo->serialno)
		@ 09, 41 get amount picture '999,999,999.99'
		setcursor(3)
		read  
		setcursor(0)
		ganda_ni_loves:=.t.
		if substr(ctrlinfo->acctno,5,3) = '103'               // LEASING
			ganda_ni_loves:=.t.
		elseif substr(ctrlinfo->acctno,5,3) = '104'           // LOAN
			ganda_ni_loves:=.f.
		endif
		xpirydate := substr(cmonth(ctrlinfo->insexpry),1,3)+'.'+ ' '+ right(str(day(ctrlinfo->insexpry) + 100,3,0),2 )+', '+str(year(ctrlinfo->insexpry),4 )
		xpr2      := (ctrlinfo->insexpry)-15
		if dow(xpr2) = 7
			xpr2:=xpr2+2
		elseif dow(xpr2) = 1
			xpr2:=xpr2+1
		endif
		xpr3:=(ctrlinfo->insexpry)-7
		if dow(xpr3) = 7
			xpr3:=xpr3+2
		elseif dow(xpr3) = 1
			xpr3:=xpr3+1
		endif
		xpirydate2:=substr(cmonth(xpr2),1,3)+'.'+ ' '+ right(str(day(xpr2) + 100,3,0),2 )+', '+str(year(xpr2),4 )
		xpirydate3:=substr(cmonth(xpr3),1,3)+'.'+ ' '+ right(str(day(xpr3) + 100,3,0),2 )+', '+str(year(xpr3),4 )
		setprc( 0, 0 )
		@ prow()+1, 0 say ''
		setfont('NORMAL')
		SETFONT('NLQ')
		setfont('ELITE')
		@ prow(), 14 say xdate
		setfont ('BOLD')
		@ prow  ()+2, 14 say Client->Fullname
		SETFONT ('UNBOLD')
		@ prow  ()+1, 14 say Client->Address1
		if !empty(Client->Address2)
			@ prow()+1, 14 say Client->Address2
		endif
		if !empty(Client->Address3)
			@ prow()+1, 14 say Client->Address3
		endif
		@ prow()+2, 14 say 'Acct No. : '+ substr(ctrlinfo->acctno,-5,5)
		@ prow()+1, 14 say ctrlinfo->coltype
		@ prow()+1, 14 say 'Serial no: '+ ctrlinfo->serialno
		@ prow()+1, 14 say 'Motor no : '+ ctrlinfo->motorno
		@ prow()+1, 14 say 'Plate no : '+ ctrlinfo->plateno
		@ prow()+2, 14 say 'Gentlemen,'                                                                 
		@ prow()+2, 14 say '      Please be informed that the subject insurance policy '
		//    1234567890123456789
		if gtrandate > ctrlinfo->insexpry
			@ prow()  , pcol()+1 say 'will expire on '
			@ prow()+1, 14 say xpirydate+ '.'
		else
			@ prow()  , pcol()+1 say 'expires on '
			@ prow()+1, 14 say xpirydate+ '.'
		endif
		@ prow()  , pcol()+2 say 'We are giving you the option to secure  for  yourself  the '
		@ prow()+1, 14       say 'renewal of the cover, provided that:'
		@ prow()+2, 14       say '         i.)  you furnish us, and we receive at least ten (10) days before'
		@ prow()+1, 14       say '              '+dtoc(ctrlinfo->insexpry)+',the original copy of  the  insurance  policy  and'
		//@ prow()+1, 14       say '              '+dtoc(xpr2)+',the original copy of  the  insurance  policy  and'
		@ prow()+1, 14       say '              official  receipt evidencing payment of premium.'
		@ prow()+1, 14       say '        ii.)  you secure  insurance  cover  from  any  of  our  accredited'
		@ prow()+1, 14       say '              insurance companies only (Please refer to attached list),and'
		@ prow()+1, 14       say '       iii.)  the coverage amount shall be at least P '+alltrim(tran(amount,'999,999,999.99')) +'.'
		@ prow()+2, 14 say '       If  any  of  these  conditions  are  not  fulfilled,  we  would  be'
		@ prow()+1, 14 say 'constrained to renew the policy ourselves and  accordingly  bill  you  for'
		@ prow()+1, 14 say 'the premium, with interest and charges where  applicable.'
		/********************
		if gtrandate > ctrlinfo->insexpry
			@ prow()+1, 14 say 'instruction immediately.'
		else
			@ prow()+1, 14 say 'instruction before '+xpirydate2 +'.'
		endif
		*********************/
		@ prow()+2, 14 say '       It  would   be  mutually   beneficial  if  you  reply  immediately.'
		@ prow()+1, 14 say 'Please disregard  this  notice if proper renewal, or payment of  insurance'
		@ prow()+1, 14 say 'premium, has already been made.'
		@ prow()+3,65 say 'Very truly yours,'
		@ prow()+3,65 say chr(27) + chr(69) + alltrim(g_INS_SIGNEE) + chr(27)+chr(70)     // EVR 01112007 - changed from Parametr->INS_SIGNEE
		@ prow()+1,65 say Alltrim( g_SIGN_POST )     // EVR 01112007 - changed from Parametr->SIGN_POST
		@ prow()+2, 14 say 'Amount of coverage on third party liability should:'
		@ prow()+2, 14 say '      Property Damage  -   P100,000.00'
		@ prow()+1, 14 say '      Bodily Injury    -   P100,000.00'
		/**********************
		if gtrandate > ctrlinfo->insexpry
			@ prow()+1, 14 say "address at  21/F  GT Tower Int'l   Building as soon as possible the following"
		else
			@ prow()+1, 14 say "office address at 21/F GT Tower Int'l Building on or before "+xpirydate3 +" the"
		endif
		@ prow()+1, 14 say 'following documents:'
		if ganda_ni_loves = .f.
			@ prow()+2, 18 say '1. Original  insurance policy duly  endorsed to ORIX METRO (complete with'
			@ prow()+1, 18 say '   Mortgagee Clause).'
		else
			@ prow()+2, 18 say '1. Original insurance policy with  ORIX METRO Leasing &  Finance Corpora-'
			@ prow()+1, 18 say '   tion as assured.'
		endif
		@ prow()+1, 18 say '2. Original Official Receipt of premium payment. '                           
		@ prow()+2, 14 say 'Kindly give this  matter your preferential attention and your compliance will'
		@ prow()+1, 14 say 'be highly appreciated.'
		@ prow()+2, 14 say 'Thank you.'
		@ prow()+3, 14 say 'Very truly yours,'
		@ prow()+3,14 say chr(27) + chr(69) + alltrim(Parametr->Ins_signee) + chr(27)+chr(70)
		@ prow()+1,14 say Alltrim( Parametr->sign_post )
		*************/
		__eject()
		Ctrlinfo->(dbskip(+1))
	enddo
	__eject()
return nil
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
static function aOpen9999()
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

   *---> red 092204 added the following
   If ! Netuse("&g_CIS_path\AO",.F.,10)
      Break
   Else
      If !.f. ;ordlistclear(); Endif
      Ordlistadd("&g_CIS_path\AO")
   Endif
   *---> end

	if !NETUSE('&g_CIS_PATH'+'\CLIENT',.f.,5)   && CLIENT MASTER file
		break
	else
		if !.f.; ordlistclear(); endif
		ordlistadd( '&g_CIS_PATH\CLIECD' )                     && set index on clntcode
		ordlistadd( '&g_CIS_PATH\CLIENM' )                     && set index on Fullname
		ORDLISTADD( '&g_CIS_PATH\CLIEBF' )     //rlv   11:08 AM 8/8/2008 FOR fchoice searching
	endif
return .t.
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
/*
Static function get_month()
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
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
STatic Function Headinc(pgn,xdate)
	setprc(0,0)
	@ prow()+1, 0 say ''
	setfont('DRAFT')
	setfont('ELITE')
	@ prow(),03 say 'ACCOUNT MANAGEMENT SYSTEM'
	@ prow(),  03+len('ACCOUNT MANAGEMENT SYSTEM');
		say PADL('Page No. ' + tran(pgn,'999'),93-len('ACCOUNT MANAGEMENT SYSTEM'))
	@ prow()+1,03 say 'AMS3400'
	@ prow()  ,03+len('AMSQ9999');
		say PADL( dtoc(DATE())+' '+TIME(), 93-len('AMSQ1000'))
	@ prow()+1,03 say PADC('ORIX METRO LEASING AND FINANCE CORPORATION',93)
	SETFONT('BOLD')
	@ prow()+1,03 say padc('LIST OF EXPIRING INSURANCE POLICIES',93)
	SETFONT('UNBOLD')
	@ prow()+1,03 say padc('For the Month of '+ xdate,93)
	@ prow()+1,03 say ''
	setfont('ELITE')
	SETFONT('CONDENSED')
	@ prow()+1,3 say 'ÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
	@ prow()+1,3 say 'Acct        Account Name              Maturity              Unit                     Insurance Company            Policy Number       Expiry    Amount Insured'
	@ prow()+1,3 say 'N§                                       date                                                                                          Date                   '
	@ prow()+1,3 say 'ÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
/*
static function select_month ( mmonth )
	return eval( { | x, y, z | x := setcolor(), y := savescreen( ,,, ),;
		fshadow( 9, 46, 18, 56, 2, 'w/gr' ),;
	devpos( 10, 49 ), devout( 'Month', 'bg+/gr' ),;
	devpos( 11, 46 ) , devout( 'ÃÄÄÄÄÄÄÄÄÄ´', 'w/gr' ),;
	setcolor( 'w/gr, w+/n,,, n/gr' ),;
	z := achoice( 12, 47, 17, 55,{;
		'January', 'February', 'March', 'April',;
		'May', 'June', 'July', 'August', 'September',;
		'October', 'November', 'December' },,, mmonth ),;
	setcolor( x ), restscreen( ,,,, y ), mmonth := if( z == 0, mmonth, z ), .f. } )
*/
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
static function fprnren_option()
	local mu:=SAVEDBF(),menulist,pchoice,st:=savescreen(,,,)
	private amount:={}
	fshadow(13,46,19,71,2,'w+/bg')
	setcolor('n/gr,w+/gr','w+/gr,n/gr')
	@ 13,52 say 'Report Option' color 'n/bg'
	@ 15,67 say 'Ü'  color 'n/bg'
	@ 16,48 say repl('ß',21) color 'n/bg'
	@ 17,67 say 'Ü'  color 'n/bg'
	@ 18,48 say repl('ß',21) color 'n/bg'
	while .t.
		@ 15,47 prompt ' ~Renewal Notice        '  triggercolor 'w+/gr'
		@ 17,47 prompt ' ~Renewal Notice (SIBI) ' triggercolor 'w+/gr'
		menu to pchoice
		if lastkey() <> K_ESC .and. !empty(pchoice)
			exit
		elseif Lastkey() == K_ESC
			exit
		endif
	Enddo
	Do case
		case pchoice == 1
			xxx := savescreen( ,,, )
			@ 15,47 say repl(' ',21) color 'n/bg'
			@ 16,47 say repl(' ',21) color 'n/bg'
			@ 15,48 say ' Renewal Notice        ' color 'w+/gr'
			inkey(.5)
			restscreen( ,,,,xxx )
			@ 15,69 say 'û'  color 'w/gr'
			pval := 1
			//rnmenu
			fshadow(07,25,13,50,2,'w+/bg')
			setcolor('n/gr,w+/gr','w+/gr,n/gr')
			@ 07,31 say 'Notice Option' color 'n/bg'
			@ 09,46 say 'Ü'  color 'n/bg'
			@ 10,27 say repl('ß',21) color 'n/bg'
			@ 11,46 say 'Ü'  color 'n/bg'
			@ 12,27 say repl('ß',21) color 'n/bg'
			while .t.
				@ 09,26 prompt ' ~Letter No. 1          '  triggercolor 'w+/gr'
				@ 11,26 prompt ' ~Letter No. 2          ' triggercolor 'w+/gr'
				menu to rnchoice
				if lastkey() <> K_ESC .and. !empty(pchoice)
					exit
				elseif Lastkey() == K_ESC
					exit
				endif
			Enddo
			Do case
				case rnchoice == 1
					xxx := savescreen( ,,, )
					@ 09,26 say repl(' ',21) color 'n/bg'
					@ 10,26 say repl(' ',21) color 'n/bg'
					@ 09,27 say ' Letter No. 1         ' color 'w+/gr'
					inkey(.5)
					restscreen( ,,,,xxx )
					@ 15,69 say 'û'  color 'w/gr'
               *repcontrol ('fprnren011()') && *---> red 092004
               SEL_INSBY("1") &&                  *---> red 092104

					pval := 1
				case rnchoice == 2
					xxx := savescreen( ,,, )
					@ 11,26 say repl(' ',21) color 'n/bg'
					@ 12,26 say repl(' ',21) color 'n/bg'
					@ 11,27 say ' Letter No. 2          ' color 'w+/gr'
					inkey(.5)
					restscreen( ,,,,xxx )
					@ 11,27 say 'û'  color 'w/gr'
					pval := 2
					if !empty(ctrlinfo->insexpry)
                  *repcontrol ('fprnren012()')  && *--->red 092204
                  SEL_INSBY("2")
					else
						Error('There is no existing expiry date! Please check...')
					endif
				case pchoice == 0
					pval := 0
			endcase
		case pchoice == 2
			xxx := savescreen( ,,, )
			@ 17,47 say repl(' ',21) color 'n/bg'
			@ 18,47 say repl(' ',21) color 'n/bg'
			@ 17,48 say ' Renewal Notice (SIBI) ' color 'w+/gr'
			inkey(.5)
			restscreen( ,,,,xxx )
			@ 17,69 say 'û'  color 'w/gr'
			pval := 2
			if !empty(ctrlinfo->insexpry)
            *repcontrol ('fprnren02()')
            repcon_ol ('fprnren02()',,,,,,,.F.)
			else
				Error('There is no existing expiry date! Please check...')
			endif
		case pchoice == 0
				pval := 0
	endcase
	RESTDBF(mu)
	restscreen(,,,,st)
return
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
function fprnren02()
	local pgn := 1,xdate := cmonth(date())+ ' '+ right(str(day(date()) + 100,3,0),2 )+', '+str(year(date()),4 )
	local has_xpre := ' '
	local a_month  := { 'Jan.','Feb.','Mar.','Apr.','May','June','July','Aug.','Sept.','Oct.','Nov.','Dec.','Xxxxx' }
	local amount
	//ALERT('5')
	if substr(acctmast->acctno,3,2) == '07'
		_prn_first_metro_notice()     // PRINT FIRST METRO ACCOUNTS ONLY (07.05.2001)
		return nil
	endif
	dbselectarea('Ctrlinfo')
   while CTRLINFO->BRCODE+Ctrlinfo->Acctno == ACCTMAST->BRCODE+Acctmast->Acctno
		amount:=0
		fshadow( 08,30,12,65,2,'n/bg' )
		setpos(09, 32)
		dispout('Amount     ')
		setpos(10, 32)
		dispout('Motor No   ' + ctrlinfo->motorno)
		setpos(11, 32)
		dispout('Serial No  ' + ctrlinfo->serialno)
		@ 09, 41 get amount picture '999,999,999.99'
		read  
		ganda_ni_loves:=.t.
		if substr(ctrlinfo->acctno,5,3) = '103'
			ganda_ni_loves:=.t.
		elseif substr(ctrlinfo->acctno,5,3) = '104'
			ganda_ni_loves:=.f.
		endif
		xpirydate := substr(cmonth(ctrlinfo->insexpry),1,3)+'.'+ ' '+ right(str(day(ctrlinfo->insexpry) + 100,3,0),2 )+', '+str(year(ctrlinfo->insexpry),4 )
		xpr2      := (ctrlinfo->insexpry)-15
		if dow(xpr2) = 7
			xpr2:=xpr2+2
		elseif dow(xpr2) = 1
			xpr2:=xpr2+1
		endif
		xpr3:=(ctrlinfo->insexpry)-7
		if dow(xpr3) = 7
			xpr3:=xpr3+2
		elseif dow(xpr3) = 1
			xpr3:=xpr3+1
		endif
		xpirydate2:=substr(cmonth(xpr2),1,3)+'.'+ ' '+ right(str(day(xpr2) + 100,3,0),2 )+', '+str(year(xpr2),4 )
		xpirydate3:=substr(cmonth(xpr3),1,3)+'.'+ ' '+ right(str(day(xpr3) + 100,3,0),2 )+', '+str(year(xpr3),4 )
		setprc  ( 0, 0 )
		@ prow()+1, 0 say ''
		setfont ( 'NORMAL' )
		SETFONT ( 'NLQ'    )
		setfont ( 'ELITE'  )
		@ prow(), 14 say xdate
		setfont ('BOLD')
		@ prow  ()+2, 14 say Client->Fullname
		SETFONT ('UNBOLD')
		@ prow  ()+1, 14 say Client->Address1
		if !empty(Client->Address2)
			@ prow()+1, 14 say Client->Address2
		endif
		if !empty(Client->Address3)
			@ prow()+1, 14 say Client->Address3
		endif
		@ prow()+2, 14 say 'Acct No. : '+ substr(ctrlinfo->acctno,-5,5)
		@ prow()+1, 14 say ctrlinfo->coltype
		@ prow()+1, 14 say 'Serial no: '+ ctrlinfo->serialno
		@ prow()+1, 14 say 'Motor no : '+ ctrlinfo->motorno
		@ prow()+1, 14 say 'Plate no : '+ ctrlinfo->plateno
		@ prow()+2, 14 say 'Gentlemen,'                                                                 
		@ prow()+2, 14 say 'We would like to advise you that the above insurance policy covering your ve-'
		if gtrandate > ctrlinfo->insexpry
			if ganda_ni_loves = .t.
				@ prow()+1, 14 say 'hicle lease from ORIX METRO expired on '+  xpirydate + '.  In accordance with the'
			else
				@ prow()+1, 14 say 'hicle mortgage to ORIX METRO expired on '+  xpirydate + '. In accordance with the'
			endif
		else
			if ganda_ni_loves = .t.
				@ prow()+1, 14 say 'hicle lease from ORIX METRO expires on '+  xpirydate + '.  In accordance with the'
			else
				@ prow()+1, 14 say 'hicle mortgage to ORIX METRO expires on '+  xpirydate + '. In accordance with the'
			endif
		endif
		if ganda_ni_loves = .t.
			@ prow()+1, 14 say 'Lease  Agreement   you   executed   with  us,  your  insurance  policy  needs'
		else
			@ prow()+1, 14 say 'Chattel Mortgage Agreement you executed with  us, your insurance policy needs'
		endif
		@ prow()+1, 14 say 'to be renewed in order to protect our mutual interest.'
		@ prow()+2, 14 say 'For your convenience, and as  an added service we provide our valued clients,'
		@ prow()+1, 14 say 'our  authorized  broker, GAINSWORTH INSURANCE AGENCY, INC.   is  willing   to'
		@ prow()+1, 14 say 'arrange the renewal of your  expiring policy based on the attached Offer Slip'
		@ prow()+1, 14 say 'describing the extent of the coverage as  well as the corresponding annual of'
		@ prow()+1, 14 say 'charges of P '+ alltrim(tran(amount,'999,999,999.99')) +'.'
		@ prow()+2, 14 say 'Please call GIAI  at telephone numbers   241-0055 or 244-5069 and  look   for'
		@ prow()+1, 14 say 'Ms.  Gemma  Blanza  for  clarifications  and  advise  her   of  your  renewal '
		if gtrandate > ctrlinfo->insexpry
			@ prow()+1, 14 say 'instruction immediately.'
		else
			@ prow()+1, 14 say 'instruction before '+xpirydate2 +'.'
		endif
		@ prow()+2, 14 say 'If you wish to secure  your own renewal policy issued by an insurance company'
		@ prow()+1, 14 say 'duly accredited by ORIX METRO, please  submit to   Ms. Christine Medina  with'
		if gtrandate > ctrlinfo->insexpry
			@ prow()+1, 14 say "address at  21/F  GT Tower Int'l   Building as soon as possible the following"
		else
			@ prow()+1, 14 say "office address at 21/F GT Tower Int'l Building on or before "+xpirydate3 +" the"
		endif
		@ prow()+1, 14 say 'following documents:'
		if ganda_ni_loves = .f.
			@ prow()+2, 18 say '1. Original  insurance policy duly  endorsed to ORIX METRO (complete with'
			@ prow()+1, 18 say '   Mortgagee Clause).'
		else
			@ prow()+2, 18 say '1. Original insurance policy with  ORIX METRO Leasing &  Finance Corpora-'
			@ prow()+1, 18 say '   tion as assured.'
		endif
		@ prow()+1, 18 say '2. Original Official Receipt of premium payment. '                           
		@ prow()+2, 14 say 'Kindly give this  matter your preferential attention and your compliance will'
		@ prow()+1, 14 say 'be highly appreciated.'
		@ prow()+2, 14 say 'Thank you.'
		@ prow()+3, 14 say 'Very truly yours,'
		**************    @ prow()+3, 14 say 'Edna L. Layosa'
		************8    @ prow()+3, 14 say Parametr->ren_signee        // 'Edna L. Layosa'
		@ prow()+3,14 say chr(27) + chr(69) + alltrim(g_INS_SIGNEE) + chr(27)+chr(70)     // EVR 01112007 - changed from Parametr->INS_SIGNEE
		@ prow()+1,14 say Alltrim( g_SIGN_POST )     // EVR 01112007 - changed from Parametr->SIGN_POST
		*************    @ prow()+1, 14 say Parametr->ren_sigpos        // 'Vice President'
		*************    @ prow()+1, 14 say 'Vice President'
		Ctrlinfo->(dbskip())
		__eject()
	enddo
	__eject()
 return nil
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
/*       1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6
1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123
              XXXXXXXXXX 99, 9999

              XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
              Yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
              Yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy

              Gentlemen,

              We would like to inform you that your insurance policy for the unit specified
              below has expired.
                                          1234567890123456789012345678901234567890123456789
                Unit                    : XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
                Plate / Motor Number    : XXX-999 / XX9999999999999
                Insurance Policy Number : XX999999999999999
                Insurance Company       : XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
                Insurance Expiry Date   : 99/99/9999
                Orix Account Number     : 9999-99999-99999

              Please submit the  original copy of the renewed  policy and the  official re-
              ceipt as soon as possible. If you  have not yet  insured  the  unit, we shall
              be glad to assist you. Please call Lei Bernabe or Christine Chio at  892-0481
              to 96 local 35.

              Thank you.

              Very truly yours,

              Edna L. Layosa
              Assistant Vice President

              Encl: List of Accredited Insurance Companies

              Please be reminded that the leased/loaned unit you insured thru our Paseo In-
              surance Agency Inc. will expire on Xxxxx 99, 9999. The description is as fol-
              lows:

                Unit                    : XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
                Plate / Motor Number    : XXX-999 / XX9999999999999
                Insurance Policy Number : XX999999999999999
                Insurance Company       : XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
                Insurance Expiry Date   : 99/99/9999
                Orix Account Number     : 9999-99999-99999

              Please confirm if we will renew the insurance coverage. We will appreciate it
              if you will renew the insurance coverage from us. Do not hesitate to call Lei
              Bernabe  or  Christine  Chio  892-0481 to 96 loc. 35 for further details. At-
              tached is the premium computation for your information.

              Thank you and hope to hear from you soon.

*/
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
*---> RED 092004
*------------------------>
FUNCTION SEL_INSBY(cLETTER)
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
                                                   Valid !Empty(cSignee) .and. lastkey() == K_ENTER
   @ 16,20 SAY "Position  " Get cPos    Pict "@!" when !Empty(cSignee) Valid !Empty(cPos)
   READ

   RESTDBF(rdb)
   RESTSCREEN(,,,,rscr)
   SETCURSOR(rcur)

   IF LASTKEY() = K_ENTER
      DBSELECTAREA('Ctrlinfo')

      IF MULT_UM()
         IF CONFIRM('Separate page for various units?')
            lMULT_UM := .T.
         ELSE
            lMULT_UM := .F.
         ENDIF
      ENDIF

      IF ALLTRIM(CTRLINFO->INSBY) == "2"
         IF lMULT_UM
            *REPCONTROL ('LTR_FOR04()')
            REPCON_OL ('LTR_FOR04()',,,,,,,.F.)
         ELSE
            *REPCONTROL ('LTR_FOR01()')
            REPCON_OL ('LTR_FOR01()',,,,,,,.F.)
         ENDIF
      ELSEIF ALLTRIM(CTRLINFO->INSBY) $ "1^3"
         IF cLETTER == "1"
            IF lMULT_UM
               IF SELFLEET()                 && RED 062205
                  *REPCONTROL ('LTR_FOR05()')
                  REPCON_OL ('LTR_FOR05()',,,,,,,.F.)
               ENDIF
            ELSE
               *REPCONTROL ('LTR_FOR02()')
               REPCON_OL ('LTR_FOR02()',,,,,,,.F.)
            ENDIF
         ELSEIF cLETTER == "2"
            IF lMULT_UM
               IF SELFLEET()                 && RED 062205
                  *REPCONTROL ('LTR_FOR06()')
                  REPCON_OL ('LTR_FOR06()',,,,,,,.F.)
               ENDIF
            ELSE
               *REPCONTROL ('LTR_FOR03()')
               REPCON_OL ('LTR_FOR03()',,,,,,,.F.)
            ENDIF
         ENDIF
      ENDIF
   ENDIF
RETURN NIL
*------------------------>
FUNCTION SELFLEET()
LOCAL aFLEET    := {}
LOCAL aREC      := {}
LOCAL nREC      := CTRLINFO->(RECNO())
LOCAL SCRA, IDX := 0
LOCAL lRETVAL   := .F.
LOCAL dEXPIRY   := CTRLINFO->INSEXPRY
LOCAL cCOLOR    := SETCOLOR()

lNONEED := .T.

DO WHILE CTRLINFO->BRCODE+CTRLINFO->ACCTNO == ACCTMAST->BRCODE+ACCTMAST->ACCTNO
   IF dEXPIRY <> CTRLINFO->INSEXPRY
      lNONEED := .F.
   ENDIF

   AADD(aFLEET,LEFT(CTRLINFO->COLMODEL,4)+" "+;
               LEFT(CTRLINFO->COLTYPE,35)+" "+;
               DTOC(CTRLINFO->INSEXPRY))

   AADD(aREC,CTRLINFO->(RECNO()))

   CTRLINFO->(DBSKIP())
ENDDO

CTRLINFO->(DBGOTO(nREC))

IF lNONEED
   RETURN .T.
ENDIF

SETCOLOR('N/BG,N/W,N/N,N/N,N/W')

IF LEN(aFLEET) > 0
   SCRA := SAVESCREEN(09,13,17,65)
   @ 09,13 CLEAR TO 17,65

   @ 09,13 TO 17,65
   @ 09,22 SAY '[Unit/Model]'
   @ 09,56 SAY '[Expiry]'

   @ 09,23 SAY 'Unit'         COLOR 'W+/BG'
   @ 09,28 SAY 'Model'        COLOR 'W+/BG'
   @ 09,57 SAY 'Expiry'       COLOR 'W+/BG'

   SETCOLOR('W+/BG,N/W,N/N,N/N,N/W')

   IDX := ACHOICE(10,14,16,64,aFLEET)

   IF LASTKEY() == K_ENTER
      CTRLINFO->(DBGOTO(aREC[IDX]))  
      lRETVAL := .T.
   ENDIF

   RESTSCREEN(09,13,17,65,SCRA)
ENDIF

SETCOLOR(cCOLOR)

RETURN lRETVAL
*------------------------>
FUNCTION GETSIGN
   LOCAL COL_ := { ;
      TBCOLUMNNEW( 'CODE '    , { || AO->AOCODE } ),;
      TBCOLUMNNEW( 'NAME '    , { || AO->AONAME } ),;
      TBCOLUMNNEW( 'POSITION ', { || AO->AOPOST } ) }

   cSIGNEE :=flook_ONLINE( .t.,'AO',,'Personnel File',3,4,,1,1,.F.,COL_ )
   IF LASTKEY() == K_ENTER
   IF cSIGNEE == RTRIM(g_INS_SIGNEE)     // EVR 01112007 - changed from PARAMETR->INS_SIGNEE
      cPOS := RTRIM(g_SIGN_POST)     // EVR 01112007 - changed from PARAMETR->SIGN_POST
   ELSE
      cSIGNEE := AO->AONAME
      cPOS    := AO->AOPOST
   ENDIF
   ELSE
	RETURN .f.
   ENDIF
RETURN .T.
*------------------------>
FUNCTION LTR_FOR01  //first notice omlf acct single
   LOCAL nPGN  := 1
   LOCAL xDATE := cMONTH(GTRANDATE) +' '+ RIGHT(STR(DAY(GTRANDATE) + 100,3,0),2 )+', '+STR(YEAR(GTRANDATE),4 )
   LOCAL cEXPI := ""
   LOCAL cPMS  := ""
   SETPRC(0,0)
   l1acct := .t.
   DO WHILE CTRLINFO->BRCODE+CTRLINFO->ACCTNO == ACCTMAST->BRCODE+ACCTMAST->ACCTNO
      cEXPI := cMONTH(CTRLINFO->INSEXPRY) +' '+ RIGHT(STR(DAY(CTRLINFO->INSEXPRY) + 100,3,0),2 )+', '+STR(YEAR(CTRLINFO->INSEXPRY),4 )

      
      cPMS := PMS()
		
		//@ PROW()+4,68 SAY chr(27)+chr(69)+'FIRST NOTICE'+chr(27)+chr(70)
	  //setfont('INIT')
	  SETFONT("NORMAL")
      SETFONT("ELITE")
      SETFONT("NLQ")
	  setfont('BOLD')
	  if rnchoice == 1
		@prow()+4,79  say chr(27)+chr(69)
		@prow()+1,79  say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
		@ PROW()+1,79 SAY '³ FIRST NOTICE ³'
		@prow()+1,79  say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'+chr(27)+chr(70)
	  endif
	  if rnchoice == 2
		@prow()+4,79  say chr(27)+chr(69)
		@prow()+1,79  say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
		@ PROW()+1,79 SAY '³ SECOND NOTICE ³'
		@prow()+1,79  say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'+chr(27)+chr(70)
	  endif
	  
	  
	  SETFONT('UNBOLD')
      @ PROW()+4,14 SAY XDATE
      SETFONT('BOLD')
      @ PROW()+3,14 SAY RTRIM(CLIENT->COLLECT)
      SETFONT ('UNBOLD')
      @ PROW()+1,14 SAY RTRIM(CLIENT->POSITION)
      SETFONT('BOLD')
      @ PROW()+1,14 SAY RTRIM(CLIENT->FULLNAME)
      SETFONT ('UNBOLD')
      @ PROW()+1,14 SAY RTRIM(CLIENT->ADDRESS1)

      IF !EMPTY(CLIENT->ADDRESS2)
         @ PROW()+1, 14 SAY RTRIM(CLIENT->ADDRESS2)
         IF !EMPTY(CLIENT->ADDRESS3)
            @ PROW()+1,14 SAY RTRIM(CLIENT->ADDRESS3)
         ENDIF
      ENDIF

      @ PROW()+2,23 SAY "RE: "+chr(27)+chr(69)+"RENEWAL NOTICE"+chr(27)+chr(70)
      @ PROW()+2,14 SAY "Dear Sir/Madam,"
//aga.05.10.2005.theresa request
      @ PROW()+2,14 SAY "Please  be informed that the insurance policy of the leased/financed unit insured"
      @ PROW()+1,14 SAY "through  "+chr(27)+chr(69) + "OMLF Insurance Agency Inc." +chr(27)+chr(70) +", formerly " +chr(27)+chr(69) + "COLF Insurance Agency Inc." +chr(27)+chr(70)+ ", will be"
      @ PROW()+1,14 SAY "expiring on " +chr(27)+chr(69)+cExpi+chr(27)+chr(70)+", details of which are as follows:"

      @ PROW()+2,23 SAY "ORIX METRO Acct. No.  : "+Right(Ctrlinfo->Acctno,5)
      @ PROW()+1,23 SAY "Unit/Model            : "+Rtrim(Ctrlinfo->Colmodel)+" "+Rtrim(Ctrlinfo->Coltype)
      @ PROW()+1,23 SAY "Plate/Motor/Serial No.: "+Rtrim(cPms)
      @ PROW()+1,23 SAY "Existing Insurance Co.: "+Rtrim(eval( { || Insuranc->(dbseek(CTRLINFO->BRCODE+Ctrlinfo->Insco,.f.)),Insuranc->Insname } ))
      @ PROW()+1,23 SAY "Insurance Policy No.  : "+Rtrim(Ctrlinfo->Inspolcy)

      @ PROW()+2,14 SAY "In accordance with the Agreement you have executed with  us, the  said unit needs"
      @ PROW()+1,14 SAY "to be insured in  order  to protect  our mutual  interest.  We shall therefore be"
      @ PROW()+1,14 SAY "renewing the insurance coverage and bill you accordingly for the premium payment."

      @ PROW()+2,14 SAY "Should you  have any  questions, please  call "+chr(27)+chr(69)+Rtrim(g_RENCONTACT)+chr(27)+chr(70)+" of  our "+chr(27)+chr(69)+"Insurance"     // EVR 01112007 - changed from Parametr->RENCONTACT
      @ PROW()+1,14 SAY "Department"+chr(27)+chr(70)+" at "+chr(27)+chr(69)+"Telephone Number "+Rtrim(g_RENPHONE)+chr(27)+chr(70)+"."     // EVR 01112007 - changed from Parametr->RENPHONE
      @ PROW()+3,14 SAY "Very truly yours,"
      @ PROW()+4,14 SAY chr(27)+chr(69)+Rtrim(cSignee)+chr(27)+chr(70)
      @ PROW()+1,14 SAY Rtrim(cPos)
      //@55 ,22       SAY chr(27)+chr(15)+"Note: Please disregard this notice if proper renewal and payment of insurance premium has been received by our office."+chr(18)
	  //@ 55,22        SAY chr(27)+chr(15)+"Note: Late submission will only be accepted upon payment of Documentary Stamp Tax and Pro-Rata Premium."+chr(18)
   @ 57,22       say chr(27) + chr(15)+'THIS IS A SYSTEM-GENERATED LETTER AND IF ISSUED WITHOUT ALTERATION, THIS DOES NOT REQUIRE A SIGNATURE.'+chr(18)
	__EJECT()
	    CTRLINFO->(DBSKIP())
   ENDDO
RETURN NIL
*------------------------>
FUNCTION LTR_FOR02
   LOCAL nPGN  := 1
   LOCAL xDATE := cMONTH(GTRANDATE) +' '+ RIGHT(STR(DAY(GTRANDATE) + 100,3,0),2 )+', '+STR(YEAR(GTRANDATE),4 )
   LOCAL cEXPI := ""
   LOCAL cPMS  := ""

   DO WHILE CTRLINFO->BRCODE+CTRLINFO->ACCTNO == ACCTMAST->BRCODE+ACCTMAST->ACCTNO
      cExpi := cMONTH(CTRLINFO->INSEXPRY) +' '+ RIGHT(STR(DAY(CTRLINFO->INSEXPRY) + 100,3,0),2 )+', '+STR(YEAR(CTRLINFO->INSEXPRY),4 )

      SETPRC(0,0)
      cPMS := PMS()

      SETFONT("NORMAL")
      SETFONT("ELITE")
	  SETFONT("NLQ")
	  setfont('BOLD')
		//ALERT('2')
		@prow()+3,79  say chr(27)+chr(69)
		@prow()+1,79  say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
		@ PROW()+1,79 SAY '³ FIRST NOTICE ³'
		@prow()+1,79  say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'+chr(27)+chr(70)
	  SETFONT('UNBOLD')
      @ PROW()+1,14-4 SAY XDATE
      SETFONT('BOLD')
      @ PROW()+2,14-4 SAY RTRIM(CLIENT->COLLECT)
      SETFONT ('UNBOLD')
      @ PROW()+1,14-4 SAY RTRIM(CLIENT->POSITION)
      SETFONT('BOLD')
      @ PROW()+1,14-4 SAY RTRIM(CLIENT->FULLNAME)
      SETFONT ('UNBOLD')
      @ PROW()+1,14-4 SAY RTRIM(CLIENT->ADDRESS1)

      IF !EMPTY(CLIENT->ADDRESS2)
         @ PROW()+1, 14-4 SAY RTRIM(CLIENT->ADDRESS2)
         IF !EMPTY(CLIENT->ADDRESS3)
            @ PROW()+1,14-4 SAY RTRIM(CLIENT->ADDRESS3)
         ENDIF
      ENDIF

      @ PROW()+2,19-4 SAY "RE: "+chr(27)+chr(69)+"RENEWAL NOTICE"+chr(27)+chr(70)
      @ PROW()+1,23-4 SAY "ORIX METRO Acct. No.  : "+Right(Ctrlinfo->Acctno,5)
      @ PROW()+1,23-4 SAY "Unit/Model            : "+Rtrim(Ctrlinfo->Colmodel)+" "+Rtrim(Ctrlinfo->Coltype)
      @ PROW()+1,23-4 SAY "Plate/Motor/Serial No.: "+Rtrim(cPms)
      @ PROW()+1,23-4 SAY "Existing Insurance Co.: "+Rtrim(eval( { || Insuranc->(dbseek(CTRLINFO->BRCODE+Ctrlinfo->Insco,.f.)),Insuranc->Insname } ))
      @ PROW()+1,23-4 SAY "Insurance Policy No.  : "+Rtrim(Ctrlinfo->Inspolcy)
      @ PROW()+1,23-4 SAY "Insurance Expiry Date : "+Dtoc(Ctrlinfo->Insexpry)

                     ****                                                                                        90       100       110
                     ****123456789112345678921234567893123456789412345678951234567896123456789712345678981234567890123456789012345678901234567892
      @ PROW()+2,14-4 SAY "Dear Sir/Madam,"
      @ PROW()+2,14-4 SAY "We wish to remind you that the above insurance  policy covering  the unit financed"
      @ PROW()+1,14-4 SAY "by / leased with "+chr(27)+chr(69)+"ORIX METRO"+chr(27)+chr(70)+" is about to  expire. We are giving  you the  option to"
      @ PROW()+1,14-4 SAY "secure for yourself the renewal of the insurance cover, provided that:"
/*
   @ PROW()+2,14 SAY "Dear Sir/Madam,"
   @ PROW()+2,14 SAY "We wish to remind you that the insurance policy of the attached list of leased/"
//aga.07.09.2005.added insurance policy of the
   @ PROW()+1,14 SAY "financed units under "+chr(27)+chr(69)+"ORIX METRO Acct. Number "+Right(Ctrlinfo->Acctno,5)+chr(27)+chr(70)+" is about to expire. We are"
   @ PROW()+1,14 SAY "giving you the option to secure for yourself the renewal of the insurance cover,"
   @ PROW()+1,14 SAY "provided that:"
*/

      @ PROW()+2,17-4 SAY    "a. You furnish us, and we receive, at least "+chr(27)+chr(69)+"ten (10) days before "+Left(cExpi,Len(cExpi)-5)
      @ PROW()+1,20-4 SAY       Right(cExpi,4)+chr(27)+chr(70)+", the original  copy of  the  Insurance  Policy  and  Official Receipt"
      @ PROW()+1,20-4 SAY       "evidencing premium payment or Insurance Certification in full force;"

      @ PROW()+2,17-4 SAY    "b. The secured  policy  is  with a  Mortgagee Clause  with  non-cancellation"
      @ PROW()+1,20-4 SAY       "provision in favor of "+chr(27)+chr(69)+"ORIX METRO"+chr(27)+chr(70)+" (for loan transactions only);"

      @ PROW()+2,17-4 SAY    "c. You secure insurance cover from any of our accredited insurance companies"
      @ PROW()+1,20-4 SAY       "only. Please refer to attached list."
//1
      @ PROW()+2,14-4     SAY "If any of these conditions are not fulfilled,"
	  setfont('BOLD')
	  @ PROW()  ,PCOL() SAY 'ORIX METRO ' 
      setfont('UNBOLD')	  
	  @ PROW()  ,PCOL() SAY "has  the option under  the"
      @ PROW()+1,14-4     SAY "existing loan/lease agreement, but without any obligation, to renew the policy and" 
      @ PROW()+1,14-4     SAY "accordingly bill you for the  premium, with interest and charges where applicable."

      @ PROW()+2,14-4     SAY "For  clarification,  please  call  "+chr(27)+chr(69)+Rtrim(g_RENCONTACT)+chr(27)+chr(70)+"  of  our  "+chr(27)+chr(69)+"Insurance  Department"+chr(27)+chr(70)+"  at"     // EVR 01112007 - changed from Parametr->RENCONTACT
      @ PROW()+1,14-4     SAY chr(27)+chr(69)+"Telephone  Number "+Rtrim(g_RENPHONE)+chr(27)+chr(70)+" or you may drop  by our office and we  shall be"     // EVR 01112007 - changed from Parametr->RENPHONE
      @ PROW()+1,14-4     SAY "glad to be of service."

      @ PROW()+2,14-4     SAY "It would be  mutually beneficial if  you reply immediately. Please disregard  this"
      @ PROW()+1,14-4     SAY "notice if the above insurance requirements have already been complied with."
      //@ PROW()+1,14-6     SAY "complied with."

      @ PROW()+2,14-4    SAY "Very truly yours,"
      @ PROW()+3,14-4    SAY chr(27)+chr(69)+alltrim(cSignee)+chr(27)+chr(70)
	  @ PROW()+1,14-4    SAY alltrim(cPos)
	  @ 57,22        say chr(27) + chr(15)+'THIS IS A SYSTEM-GENERATED LETTER AND IF ISSUED WITHOUT ALTERATION, THIS DOES NOT REQUIRE A SIGNATURE.'+chr(18)
      __EJECT()
      CTRLINFO->(DBSKIP())
   ENDDO
RETURN NIL
*------------------------>
FUNCTION LTR_FOR03
   LOCAL nPGN    := 1
   LOCAL xDATE   := cMONTH(GTRANDATE) +' '+ RIGHT(STR(DAY(GTRANDATE) + 100,3,0),2 )+', '+STR(YEAR(GTRANDATE),4 )
   LOCAL cEXPI   := ""
   LOCAL cB4EXPI := ""
   LOCAL cPMS    := ""

   DO WHILE CTRLINFO->BRCODE+CTRLINFO->ACCTNO == ACCTMAST->BRCODE+ACCTMAST->ACCTNO
      cEXPI   := cMONTH(CTRLINFO->INSEXPRY) +' '+ RIGHT(STR(DAY(CTRLINFO->INSEXPRY) + 100,3,0),2 )+', '+STR(YEAR(CTRLINFO->INSEXPRY),4 )
	  //RLV 10:12 AM 12/9/2008
	  if cMONTH(CTRLINFO->INSEXPRY) == 'January' .and. DAY(CTRLINFO->INSEXPRY) <= 10
		cB4EXPI := cMONTH(CTRLINFO->INSEXPRY-10) +' '+ RIGHT(STR(DAY(CTRLINFO->INSEXPRY-10) + 100,3,0),2 )+', '+STR(YEAR(CTRLINFO->INSEXPRY)-1,4)
	  else
		cB4EXPI := cMONTH(CTRLINFO->INSEXPRY-10) +' '+ RIGHT(STR(DAY(CTRLINFO->INSEXPRY-10) + 100,3,0),2 )+', '+STR(YEAR(CTRLINFO->INSEXPRY),4)
	  endif
	  //
      SETPRC(0,0)
	  //ALERT('8')
      cPMS := PMS()
      //SETFONT("ELITE")
      SETFONT("PICA")
	  SETFONT('CONDENSED')
      SETFONT("NLQ")
	  setfont('BOLD')
		@prow()+3,117  say chr(27)+chr(69)
		@prow()+1,117  say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
		@ PROW()+1,117 SAY '³ SECOND NOTICE ³'
		@prow()+1,117  say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'+chr(27)+chr(70)
	  SETFONT('UNBOLD')
      @ PROW()+3,21-4 SAY xDATE
      SETFONT('BOLD')
      @ PROW()+2,21-4 SAY RTRIM(CLIENT->COLLECT)
      SETFONT ('UNBOLD')
      @ PROW()+1,21-4 SAY RTRIM(CLIENT->POSITION)
      SETFONT('BOLD')
      @ PROW()+1,21-4 SAY RTRIM(CLIENT->FULLNAME)
      SETFONT ('UNBOLD')
      @ PROW()+1,21-4 SAY RTRIM(CLIENT->ADDRESS1)

      IF !EMPTY(CLIENT->ADDRESS2)
         @ PROW()+1, 21-4 SAY RTRIM(CLIENT->ADDRESS2)
         IF !EMPTY(CLIENT->ADDRESS3)
            @ PROW()+1,21-4 SAY RTRIM(CLIENT->ADDRESS3)
         ENDIF
      ENDIF

      @ PROW()+2,27-4 SAY "RE: "+chr(27)+chr(69)+"RENEWAL NOTICE"+chr(27)+chr(70)
      @ PROW()+1,27-4 SAY "ORIX METRO Acct. No.  : "+Right(Ctrlinfo->Acctno,5)
      @ PROW()+1,27-4 SAY "Unit/Model            : "+Rtrim(Ctrlinfo->Colmodel)+" "+Rtrim(Ctrlinfo->Coltype)
      @ PROW()+1,27-4 SAY "Plate/Motor/Serial No.: "+Rtrim(cPms)
      @ PROW()+1,27-4 SAY "Existing Insurance Co.: "+Rtrim(eval( { || Insuranc->(dbseek(CTRLINFO->BRCODE+Ctrlinfo->Insco,.f.)),Insuranc->Insname } ))
      @ PROW()+1,27-4 SAY "Insurance Policy No.  : "+Rtrim(Ctrlinfo->Inspolcy)
      @ PROW()+1,27-4  SAY "Insurance Expiry Date : "+Dtoc(Ctrlinfo->Insexpry)

                     ****                                                                                        90       100       110
                     ****123456789112345678921234567893123456789412345678951234567896123456789712345678981234567890123456789012345678901234567892
      @ PROW()+2,21-4 SAY "Dear Sir/Madam,"
      @ PROW()+2,21-4 SAY "We are still awaiting the insurance renewal policy of the unit described above. In accordance with the Agreement"
      @ PROW()+1,21-4 SAY "you  have  executed  with us, the  said unit  needs to be  insured in order to  protect our mutual  interest. To    "
      @ PROW()+1,21-4 SAY "ensure that the renewal coverage of the  leased/financed unit has been secured, kindly  submit to our office the"
      @ PROW()+1,21-4 SAY chr(27)+chr(69)+"original copy"+chr(27)+chr(70)+" of the following insurance requirements on or before "+chr(27)+chr(69)+cB4expi+chr(27)+chr(70)+";"

      @ PROW()+2,24-4 SAY    "a. Insurance Policy from an accredited insurance company (See attached list.)"
	  
      @ PROW()+2,24-4 SAY    "b. Official Receipt of  Premium  Payment or  Insurance Certification in full force"
	  
      @ PROW()+2,24-4 SAY    "c. Mortgagee Clause  with non-cancellation  provision in favor of "+chr(27)+chr(69)+"ORIX METRO"+chr(27)+chr(70)+' (for loan transactions only)'

      @ PROW()+2,21-4 SAY "If any of these conditions are not fulfilled,"+chr(27)+chr(69)+' ORIX METRO'+chr(27)+chr(70)+" has the option under the existing loan/lease agreement,"
      @ PROW()+1,21-4 SAY "but  without any  obligation, to  renew the  policy and  accordingly bill you for the premium, with interest and" 
	  @ PROW()+1,21-4 SAY "charges where applicable."
	  
      @ PROW()+2,21-4 SAY "Please address your queries, if any, to our  "+chr(27)+chr(69)+"Insurance Department"+chr(27)+chr(70)+" at "+chr(27)+chr(69)+"Tel. No. "+Rtrim(g_RENPHONE)+chr(27)+chr(70)+'. You may look for' 
      @ PROW()+1,21-4 SAY +chr(27)+chr(69)+Rtrim(g_RENCONTACT)+chr(27)+chr(70)+" for any  clarification  or you  may  drop by  our  office and we  shall  be  glad to be of  service."     // EVR 01112007 - changed from Parametr->RENPHONE & Parametr->RENCONTACT
      //@ PROW()+1,14-6 SAY ""

      @ PROW()+2,21-4 SAY "It would be mutually  beneficial if you reply immediately  as we would not want to expose you to any unnecessary"
      @ PROW()+1,21-4 SAY "risk. Please  disregard  this notice  if the  above insurance  requirements  have  already  been  complied with."
      //@ PROW()+1,14-6 SAY ""

      @ PROW()+2,21-4 SAY "Very truly yours,"
      @ PROW()+3,21-4 SAY chr(27)+chr(69)+Rtrim(cSignee)+chr(27)+chr(70)
      @ PROW()+1,21-4 SAY Rtrim(cPos)
      @ 55,27        SAY chr(27)+chr(15)+"Note: Late submission will only be accepted upon payment of Documentary Stamp Tax and Pro-Rata Premium."+chr(18)
	  @ 57,16        say chr(27) + chr(15)+'THIS IS A SYSTEM-GENERATED LETTER AND IF ISSUED WITHOUT ALTERATION, THIS DOES NOT REQUIRE A SIGNATURE.'
      __EJECT()
      CTRLINFO->(DBSKIP())
   ENDDO
RETURN NIL
*------------------------>
FUNCTION LTR_FOR04  //2nd notice omlf accts various
   LOCAL nPGN  := 1
   LOCAL xDATE := cMONTH(GTRANDATE) +' '+ RIGHT(STR(DAY(GTRANDATE) + 100,3,0),2 )+', '+STR(YEAR(GTRANDATE),4 )
   LOCAL cEXPI := ""
   LOCAL cPMS  := ""

   SETPRC(0,0)
   
  SETFONT("NORMAL")
   SETFONT("ELITE")
   SETFONT("NLQ")
   
   IF rnchoice == 1
   setfont('BOLD')
   @prow()+4,79  say chr(27)+chr(69)
	@prow()+1,79  say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
	@ PROW()+1,79 SAY '³ FIRST NOTICE ³'
	@prow()+1,79  say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'+chr(27)+chr(70)
	SETFONT('UNBOLD')
    endif
              
   IF rnchoice == 2
   setfont('BOLD')
   @prow()+4,79  say chr(27)+chr(69)
	@prow()+1,79  say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
	@ PROW()+1,79 SAY '³ SECOND NOTICE ³'
	@prow()+1,79  say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'+chr(27)+chr(70)
	SETFONT('UNBOLD')
    endif
                                  
   @ PROW()+6,14-4 SAY XDATE
   SETFONT('BOLD')
   @ PROW()+3,14-4 SAY RTRIM(CLIENT->COLLECT)
   SETFONT ('UNBOLD')
   @ PROW()+1,14-4 SAY RTRIM(CLIENT->POSITION)
   SETFONT('BOLD')
   @ PROW()+1,14-4 SAY RTRIM(CLIENT->FULLNAME)
   SETFONT ('UNBOLD')
   @ PROW()+1,14-4 SAY RTRIM(CLIENT->ADDRESS1)

   IF !EMPTY(CLIENT->ADDRESS2)
      @ PROW()+1, 14-4 SAY RTRIM(CLIENT->ADDRESS2)
      IF !EMPTY(CLIENT->ADDRESS3)
         @ PROW()+1,14-4 SAY RTRIM(CLIENT->ADDRESS3)
      ENDIF
   ENDIF
                  ****                                                                                        90       100       110
                  ****123456789112345678921234567893123456789412345678951234567896123456789712345678981234567890123456789012345678901234567892
   @ PROW()+2,24-4 SAY "RE: "+chr(27)+chr(69)+"RENEWAL NOTICE"+chr(27)+chr(70)
   @ PROW()+2,14-4 SAY "Dear Sir/Madam,"
   @ PROW()+2,14-4 SAY "Please be informed that the insurance policy of the attached list of leased/financed"
//aga.07.09.2005.added insurance policy of the
   @ PROW()+1,14-4 SAY "units under ORIX METRO Acct. No: "+chr(27)+chr(69)+Right(Ctrlinfo->Acctno,5)+chr(27)+chr(70)+" insured  through  "+chr(27)+chr(69) + "OMLF Insurance Agency Inc." +chr(27)+chr(70) +","
   @ PROW()+1,14-4 SAY "formerly " +chr(27)+chr(69) + "COLF Insurance Agency Inc." +chr(27)+chr(70) + ", is  about  to expire."

   @ PROW()+2,14-4 SAY "In  accordance  with the Agreement  you have  executed with us, the said  units need"
   @ PROW()+1,14-4 SAY "to be  insured   in order to protect  our  mutual  interest. We shall  therefore  be"
   @ PROW()+1,14-4 SAY "renewing  the insurance coverage and  bill you accordingly  for the premium payment."

   @ PROW()+2,14-4 SAY "Should you have any questions, please call  "+chr(27)+chr(69)+Rtrim(g_RENCONTACT)+chr(27)+chr(70)+" of  our "+chr(27)+chr(69)+"Insurance Department"     // EVR 01112007 - changed from Parametr->RENCONTACT
   @ PROW()+1,14-4 SAY "at "+chr(27)+chr(69)+"Telephone Number "+Rtrim(g_RENPHONE)+chr(27)+chr(70)+"."     // EVR 01112007 - changed from Parametr->RENPHONE
   @ PROW()+3,14-4 SAY "Very truly yours,"
   @ PROW()+4,14-4 SAY CHR(27)+CHR(69)+RTRIM(cSignee)+CHR(27)+CHR(70)
   @ PROW()+1,14-4 SAY RTRIM(cPos)
   //@ 55,22        SAY chr(27)+chr(15)+"Note: Late submission will only be accepted upon payment of Documentary Stamp Tax and Pro-Rata Premium."+chr(18)
   @ 57,22        say chr(27) + chr(15)+'THIS IS A SYSTEM-GENERATED LETTER AND IF ISSUED WITHOUT ALTERATION, THIS DOES NOT REQUIRE A SIGNATURE.'+chr(18)

   
   __EJECT()
   IF rnchoice == 1
	setfont('BOLD')
   @prow()+4,79  say chr(27)+chr(69)
	@prow()+1,79  say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
	@ PROW()+1,79 SAY '³ FIRST NOTICE ³'
	@prow()+1,79  say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'+chr(27)+chr(70)
	SETFONT('UNBOLD')
	endif
	
	IF rnchoice == 2
	setfont('BOLD')
   @prow()+4,79  say chr(27)+chr(69)
	@prow()+1,79  say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
	@ PROW()+1,79 SAY '³ SECOND NOTICE ³'
	@prow()+1,79  say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'+chr(27)+chr(70)
	SETFONT('UNBOLD')
    endif
   MULT_HEAD()
   //SETPRC(20,01)

   DO WHILE CTRLINFO->BRCODE+CTRLINFO->ACCTNO == ACCTMAST->BRCODE+ACCTMAST->ACCTNO
      cEXPI := CMONTH(CTRLINFO->INSEXPRY) +' '+ RIGHT(STR(DAY(CTRLINFO->INSEXPRY) + 100,3,0),2 )+', '+STR(YEAR(CTRLINFO->INSEXPRY),4 )
      cPMS  := PMS()

      @ PROW()+1, 21 SAY LEFT(CTRLINFO->COLMODEL,4)+" "+LEFT(CTRLINFO->COLTYPE,35)
      @ PROW(),   62 SAY RTRIM(cPMS)
      @ PROW(),   83 SAY LEFT(EVAL( { || INSURANC->(DBSEEK(CTRLINFO->BRCODE+CTRLINFO->INSCO,.F.)),INSURANC->INSNAME } ),35)
      @ PROW(),  119 SAY LEFT(CTRLINFO->INSPOLCY,20)
      @ PROW(),  140 SAY DTOC(CTRLINFO->INSEXPRY)

      CTRLINFO->(DBSKIP())

      IF PROW() > 57
         //@ 55,22        SAY chr(27)+chr(15)+"Note: Late submission will only be accepted upon payment of Documentary Stamp Tax and Pro-Rata Premium."+chr(18)
   @ 57,37       say chr(27) + chr(15)+'THIS IS A SYSTEM-GENERATED LETTER AND IF ISSUED WITHOUT ALTERATION, THIS DOES NOT REQUIRE A SIGNATURE.'+chr(18)

         __EJECT()
         //SETFONT("UNCONDENSED")
		 setfont('BOLD')
   @prow()+4,79  say chr(27)+chr(69)
	@prow()+1,79  say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
	@ PROW()+1,79 SAY '³ FIRST NOTICE ³'
	@prow()+1,79  say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'+chr(27)+chr(70)
	SETFONT('UNBOLD')
         MULT_HEAD()
         //SETPRC(20,01)
      ENDIF
   ENDDO

   //@ 55,37        SAY chr(27)+chr(15)+"Note: Late submission will only be accepted upon payment of Documentary Stamp Tax and Pro-Rata Premium."+chr(18)
   @ 57,37        say chr(27) + chr(15)+'THIS IS A SYSTEM-GENERATED LETTER AND IF ISSUED WITHOUT ALTERATION, THIS DOES NOT REQUIRE A SIGNATURE.'+chr(18)

   __EJECT()
   SETFONT("UNCONDENSED")

   __EJECT()
RETURN NIL
*------------------------>
FUNCTION LTR_FOR05
   LOCAL nPGN  :=1
   LOCAL xDATE := cMONTH(GTRANDATE) +' '+ RIGHT(STR(DAY(GTRANDATE) + 100,3,0),2 )+', '+STR(YEAR(GTRANDATE),4 )
   LOCAL cEXPI := cMONTH(CTRLINFO->INSEXPRY) +' '+ RIGHT(STR(DAY(CTRLINFO->INSEXPRY) + 100,3,0),2 )+', '+STR(YEAR(CTRLINFO->INSEXPRY),4 )
   LOCAL cPMS  := ""

   SETPRC(0,0)
   SETFONT("NORMAL")
   SETFONT("ELITE")
   SETFONT("NLQ")
   setfont('BOLD')
	  @prow()+4,79  say chr(27)+chr(69)
	  @prow()+1,79  say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
	  @ PROW()+1,79 SAY '³ FIRST NOTICE ³'
	  @prow()+1,79  say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'+chr(27)+chr(70)
   SETFONT('UNBOLD')
   @ PROW()+02,14-4 SAY XDATE
   SETFONT('BOLD')
   @ PROW()+2,14-4 SAY RTRIM(CLIENT->COLLECT)
   SETFONT ('UNBOLD')
   @ PROW()+1,14-4 SAY RTRIM(CLIENT->POSITION)
   SETFONT('BOLD')
   @ PROW()+1,14-4 SAY RTRIM(CLIENT->FULLNAME)
   SETFONT ('UNBOLD')
   @ PROW()+1,14-4 SAY RTRIM(CLIENT->ADDRESS1)

   IF !EMPTY(CLIENT->ADDRESS2)
      @ PROW()+1, 14-4 SAY RTRIM(CLIENT->ADDRESS2)
      IF !EMPTY(CLIENT->ADDRESS3)
         @ PROW()+1,14-4 SAY RTRIM(CLIENT->ADDRESS3)
      ENDIF
   ENDIF
                  ****                                                                                        90       100       110
                  ****123456789112345678921234567893123456789412345678951234567896123456789712345678981234567890123456789012345678901234567892
   @ PROW()+2,14-4 SAY "Dear Sir/Madam,"
   @ PROW()+2,14-4 SAY "We wish  to remind  you that the insurance  policy  of the attached list of leased/"
//aga.07.09.2005.added insurance policy of the
   @ PROW()+1,14-4 SAY "financed  units  under "+chr(27)+chr(69)+"ORIX  METRO Acct. Number  "+Right(Ctrlinfo->Acctno,5)+chr(27)+chr(70)+" is about to  expire. We  are"
   @ PROW()+1,14-4 SAY "giving you the option to secure for  yourself the renewal  of the insurance  cover,"
   @ PROW()+1,14-4 SAY "provided that:"

   @ PROW()+2,15-5 SAY    "a. You furnish us, and we receive, at least "+chr(27)+chr(69)+"ten (10) days  before "+cExpi+chr(27)+chr(70)+","
   @ PROW()+1,18-5 SAY       "the  original copy  of the  Insurance Policy  and  Official Receipt  evidencing"
   @ PROW()+1,18-5 SAY       "premium payment or Insurance Certification in full force;"

   @ PROW()+2,15-5 SAY    "b. The secured policy is  with a Mortgagee  Clause with non-cancellation provision"
   @ PROW()+1,18-5 SAY       "in favor of "+chr(27)+chr(69)+"ORIX METRO"+chr(27)+chr(70)+" (for loan transactions only);"

   @ PROW()+2,15-5 SAY    "c. You secure insurance cover from any of our accredited insurance companies only."
   @ PROW()+1,18-5 SAY       "Please refer to attached list."

   /* @ PROW()+2,14 SAY "If any of these conditions are not fulfilled, we may be forced to renew the"
   @ PROW()+1,14 SAY "policy ourselves as stated in your contract with us and accordingly bill you" 
   @ PROW()+1,14 SAY "for the premium, with interest and charges where applicable."
 */
   @ PROW()+2,14-4     SAY "If any of these conditions are not fulfilled,"
	  setfont('BOLD')
	  @ PROW()  ,PCOL() SAY 'ORIX METRO ' 
      setfont('UNBOLD')	  
	  @ PROW()  ,PCOL() SAY "has  the option under  the"
      @ PROW()+1,14-4     SAY "existing loan/lease agreement, but without any obligation, to renew the policy and" 
      @ PROW()+1,14-4     SAY "accordingly bill you for the  premium, with interest and charges where applicable."

      @ PROW()+2,14-4     SAY "For  clarification,  please  call  "+chr(27)+chr(69)+Rtrim(g_RENCONTACT)+chr(27)+chr(70)+"  of  our  "+chr(27)+chr(69)+"Insurance  Department"+chr(27)+chr(70)+"  at"     // EVR 01112007 - changed from Parametr->RENCONTACT
      @ PROW()+1,14-4     SAY chr(27)+chr(69)+"Telephone  Number "+Rtrim(g_RENPHONE)+chr(27)+chr(70)+" or you may drop  by our office and we  shall be"     // EVR 01112007 - changed from Parametr->RENPHONE
      @ PROW()+1,14-4     SAY "glad to be of service."

      @ PROW()+2,14-4     SAY "It would be  mutually  beneficial if  you reply immediately. Please disregard this"
      @ PROW()+1,14-4     SAY "notice  if  the above  insurance  requirements  have  already  been complied  with."

   @ PROW()+3,14-4 SAY "Very truly yours,"
   @ PROW()+3,14-4 SAY chr(27)+chr(69)+Rtrim(cSignee)+chr(27)+chr(70)
   @ PROW()+1,14-4 SAY Rtrim(cPos)
   @ 57,22        say chr(27) + chr(15)+'THIS IS A SYSTEM-GENERATED LETTER AND IF ISSUED WITHOUT ALTERATION, THIS DOES NOT REQUIRE A SIGNATURE.'+chr(18)
   __EJECT()
   setfont('BOLD')
	  @prow()+4,79  say chr(27)+chr(69)
	  @prow()+1,79  say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
	  @ PROW()+1,79 SAY '³ FIRST NOTICE ³'
	  @prow()+1,79  say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'+chr(27)+chr(70)
   SETFONT('UNBOLD')	
   MULT_HEAD()

   CTRLINFO->(DBSEEK(ACCTMAST->BRCODE+ACCTMAST->ACCTNO))           && RED 062205

   DO WHILE CTRLINFO->BRCODE+CTRLINFO->ACCTNO == ACCTMAST->BRCODE+ACCTMAST->ACCTNO
      cPMS  := PMS()

      @ PROW()+1, 21 SAY LEFT(CTRLINFO->COLMODEL,4)+" "+LEFT(CTRLINFO->COLTYPE,35)
      @ PROW(),   62 SAY RTRIM(cPMS)
      @ PROW(),   83 SAY LEFT(EVAL( { || INSURANC->(DBSEEK(CTRLINFO->BRCODE+CTRLINFO->INSCO,.F.)),INSURANC->INSNAME } ),35)
      @ PROW(),  119 SAY LEFT(CTRLINFO->INSPOLCY,20)
      @ PROW(),  140 SAY DTOC(CTRLINFO->INSEXPRY)

      CTRLINFO->(DBSKIP())

      IF PROW() > 57
		@ 57,37        say chr(27) + chr(15)+'THIS IS A SYSTEM-GENERATED LETTER AND IF ISSUED WITHOUT ALTERATION, THIS DOES NOT REQUIRE A SIGNATURE.'+chr(18)
         __EJECT()
		 setfont('BOLD')
	  @prow()+4,79  say chr(27)+chr(69)
	  @prow()+1,79  say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
	  @ PROW()+1,79 SAY '³ FIRST NOTICE ³'
	  @prow()+1,79  say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'+chr(27)+chr(70)
   SETFONT('UNBOLD')
         MULT_HEAD()
      ENDIF
   ENDDO
	@ 57,37        say chr(27) + chr(15)+'THIS IS A SYSTEM-GENERATED LETTER AND IF ISSUED WITHOUT ALTERATION, THIS DOES NOT REQUIRE A SIGNATURE.'+chr(18)
   __EJECT()
RETURN NIL
*------------------------>
FUNCTION LTR_FOR06
   LOCAL nPGN    := 1
   LOCAL xDATE   := CMONTH(GTRANDATE) +' '+ RIGHT(STR(DAY(GTRANDATE) + 100,3,0),2 )+', '+STR(YEAR(GTRANDATE),4 )
   LOCAL cEXPI   := CMONTH(CTRLINFO->INSEXPRY) +' '+ RIGHT(STR(DAY(CTRLINFO->INSEXPRY) + 100,3,0),2 )+', '+STR(YEAR(CTRLINFO->INSEXPRY),4 )
   LOCAL cB4EXPI := CMONTH(CTRLINFO->INSEXPRY-10) +' '+ RIGHT(STR(DAY(CTRLINFO->INSEXPRY-10) + 100,3,0),2 )+', '+STR(YEAR(CTRLINFO->INSEXPRY),4)
   LOCAL cPMS    := ""

   	  //RLV 10:12 AM 12/9/2008
	  if cMONTH(CTRLINFO->INSEXPRY) == 'January' .and. DAY(CTRLINFO->INSEXPRY) <= 10
		cB4EXPI := cMONTH(CTRLINFO->INSEXPRY-10) +' '+ RIGHT(STR(DAY(CTRLINFO->INSEXPRY-10) + 100,3,0),2 )+', '+STR(YEAR(CTRLINFO->INSEXPRY)-1,4)
	  else
		cB4EXPI := cMONTH(CTRLINFO->INSEXPRY-10) +' '+ RIGHT(STR(DAY(CTRLINFO->INSEXPRY-10) + 100,3,0),2 )+', '+STR(YEAR(CTRLINFO->INSEXPRY),4)
	  endif
	  //
 
   
   SETPRC(0,0)
   //ALERT('11')
   SETFONT("NORMAL")
   SETFONT("ELITE")
   SETFONT("NLQ")
   setfont('BOLD')
	  @prow()+4,79  say chr(27)+chr(69)
	  @prow()+1,79  say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
	  @ PROW()+1,79 SAY '³ SECOND NOTICE ³'
	  @prow()+1,79  say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'+chr(27)+chr(70)
   SETFONT('UNBOLD')
   @ PROW()+3,14-3 SAY xDATE
   SETFONT('BOLD')
   @ PROW()+2,14-3 SAY RTRIM(CLIENT->COLLECT)
   SETFONT ('UNBOLD')
   @ PROW()+1,14-3 SAY RTRIM(CLIENT->POSITION)
   SETFONT('BOLD')
   @ PROW()+1,14-3 SAY RTRIM(CLIENT->FULLNAME)
   SETFONT ('UNBOLD')
   @ PROW()+1,14-3 SAY RTRIM(CLIENT->ADDRESS1)

   IF !EMPTY(CLIENT->ADDRESS2)
      @ PROW()+1, 14-3 SAY RTRIM(CLIENT->ADDRESS2)
      IF !EMPTY(CLIENT->ADDRESS3)
         @ PROW()+1,14-3 SAY RTRIM(CLIENT->ADDRESS3)
      ENDIF
   ENDIF
                  ****                                                                                        90       100       110
                  ****123456789112345678921234567893123456789412345678951234567896123456789712345678981234567890123456789012345678901234567892
   @ PROW()+2,14-3 SAY "Dear Sir/Madam,"
   @ PROW()+2,14-3 SAY "We are still awaiting the insurance renewal policy of the attached list of leased/"
   @ PROW()+1,14-3 SAY "financed units under "+chr(27)+chr(69)+"ORIX METRO Acct. No: "+Right(Ctrlinfo->Acctno,5)+chr(27)+chr(70)+". In accordance  with the Agreement"
   @ PROW()+1,14-3 SAY "you have  executed with us, the said units  need to be insured in order to protect"
   @ PROW()+1,14-3 SAY "our mutual interest. To ensure that the renewal coverage has been  secured, kindly"
   @ PROW()+1,14-3 SAY "submit to our office the "+chr(27)+chr(69)+"original copy"+chr(27)+chr(70)+" of the following insurance  requirements on"
   @ PROW()+1,14-3 SAY "or before "+chr(27)+chr(69)+cB4expi+chr(27)+chr(70)+";"

   @ PROW()+2,17-3 SAY    "a. Insurance Policy from an accredited insurance  company (See attached list.)"
   @ PROW()+1,17-3 SAY    "b. Official  Receipt of  Premium Payment  or Insurance  Certification in  full"
   @ PROW()+1,20-3 SAY       "force"
   @ PROW()+1,17-3 SAY    "c. Mortgagee  Clause with  non-cancellation  provision in favor  of "+chr(27)+chr(69)+"ORIX METRO"+chr(27)+chr(70)
   @ PROW()+1,20-3 SAY       "(for loan transactions only)"
   
   //@ PROW()+2,21 SAY "If any of these conditions are not fulfilled,"+chr(27)+chr(69)+' ORIX METRO'+chr(27)+chr(70)+" has the option under the existing loan/lease agreement,"
   //   @ PROW()+1,21 SAY "under the existing loan/lease agreement, but without any obligation, to renew the policy and  accordingly bill you for the premium, with interest and" 
//	  @ PROW()+1,21 SAY "charges where applicable."
   
   
   

   @ PROW()+2,14-3 SAY "If any of these  conditions are not fulfilled,"+chr(27)+chr(69)+' ORIX METRO'+chr(27)+chr(70)+" has the option under the"
   @ PROW()+1,14-3 SAY "existing loan/lease agreement, but without any obligation, to renew the policy and"
   @ PROW()+1,14-3 SAY "accordingly bill you for the premium, with interest and charges  where applicable." 
   //@ PROW()+1,14-3 SAY ""

   @ PROW()+2,14-3 SAY "Please  address your  queries, if  any, to  our "+chr(27)+chr(69)+"Insurance  Department"+chr(27)+chr(70)+" at  "+chr(27)+chr(69)+"Tel. No. "
   @ PROW()+1,14-3 SAY Rtrim(g_RENPHONE)+chr(27)+chr(70)+". You may look for "+chr(27)+chr(69)+Rtrim(g_RENCONTACT)+chr(27)+chr(70)+" for any  clarification  or  you may"     // EVR 01112007 - changed from Parametr->RENPHONE & Parametr->RENCONTACT
   @ PROW()+1,14-3 SAY "drop by our office and we shall be glad to be of service."

   @ PROW()+2,14-3 SAY "It would be mutually beneficial if you reply immediately as we would not  want to"
   @ PROW()+1,14-3 SAY "expose you  to any unnecessary  risk. Please disregard  this notice if  the above"
   @ PROW()+1,14-3 SAY "insurance requirements have already been complied with."

   @ PROW()+3,14-3 SAY "Very truly yours,"
   @ PROW()+4,14-3 SAY chr(27)+chr(69)+Rtrim(cSignee)+chr(27)+chr(70)
   @ PROW()+1,14-3 SAY Rtrim(cPos)
   @ 55,22        SAY chr(27)+chr(15)+"Note: Late submission will only be accepted upon payment of Documentary Stamp Tax and Pro-Rata Premium."+chr(18)
   @ 57,22        say chr(27) + chr(15)+'THIS IS A SYSTEM-GENERATED LETTER AND IF ISSUED WITHOUT ALTERATION, THIS DOES NOT REQUIRE A SIGNATURE.'+chr(18)
   //@ 56,22       SAY chr(27)+chr(15)+"Note: Late submission will only be accepted upon payment of Documentary Stamp Tax and Pro-Rata Premium."+chr(18)
   
   __EJECT()
	setfont('BOLD')
	  @prow()+4,79  say chr(27)+chr(69)
	  @prow()+1,79  say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
	  @ PROW()+1,79 SAY '³ SECOND NOTICE ³'
	  @prow()+1,79  say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'+chr(27)+chr(70)
   SETFONT('UNBOLD')
   MULT_HEAD()
   SETPRC(20,01)

   DO WHILE CTRLINFO->BRCODE+CTRLINFO->ACCTNO == ACCTMAST->BRCODE+ACCTMAST->ACCTNO
      cPMS  := PMS()

      @ PROW()+1, 21 SAY LEFT(CTRLINFO->COLMODEL,4)+" "+LEFT(CTRLINFO->COLTYPE,35)
      @ PROW(),   62 SAY RTRIM(cPMS)
      @ PROW(),   83 SAY LEFT(EVAL( { || INSURANC->(DBSEEK(CTRLINFO->BRCODE+CTRLINFO->INSCO,.F.)),INSURANC->INSNAME } ),35)
      @ PROW(),  119 SAY LEFT(CTRLINFO->INSPOLCY,20)
      @ PROW(),  140 SAY DTOC(CTRLINFO->INSEXPRY)

      CTRLINFO->(DBSKIP())

      IF PROW() > 55
         @ 55,22        SAY chr(27)+chr(15)+"Note: Late submission will only be accepted upon payment of Documentary Stamp Tax and Pro-Rata Premium."+chr(18)
	     @ 58,22        say chr(27) + chr(15)+'THIS IS A SYSTEM-GENERATED LETTER AND IF ISSUED WITHOUT ALTERATION, THIS DOES NOT REQUIRE A SIGNATURE.'+chr(18)    
		 __EJECT()
		 setfont('BOLD')
	  @prow()+4,79  say chr(27)+chr(69)
	  @prow()+1,79  say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
	  @ PROW()+1,79 SAY '³ SECOND NOTICE ³'
	  @prow()+1,79  say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'+chr(27)+chr(70)
   SETFONT('UNBOLD')
         MULT_HEAD()
         SETPRC(20,01)
      ENDIF

   ENDDO
@ 55,37 SAY CHR(27)+CHR(15)+"Note: Late submission will only be accepted upon payment of Documentary Stamp Tax and Pro-Rata Premium."+chr(18)
@ 58,22 say chr(27) + chr(15)+'THIS IS A SYSTEM-GENERATED LETTER AND IF ISSUED WITHOUT ALTERATION, THIS DOES NOT REQUIRE A SIGNATURE.'+chr(18)
   

   __EJECT()
RETURN NIL
*--------------------->
FUNCTION NOT_NA(cVAL)
LOCAL lRETVAL := .F.

IF ALLTRIM(cVAL) == "N.A." .OR. ALLTRIM(cVAL) == "NA." .OR. ;
   ALLTRIM(cVAL) == "N.A" .OR. ALLTRIM(cVAL) == "NA"
   lRETVAL := .T.
ENDIF

RETURN lRETVAL
*--------------------->
FUNCTION PMS()
LOCAL cRETVAL := ""

IF EMPTY(CTRLINFO->PLATENO) .OR. NOT_NA(CTRLINFO->PLATENO)
   IF EMPTY(CTRLINFO->MOTORNO) .OR. NOT_NA(CTRLINFO->MOTORNO)
      IF EMPTY(CTRLINFO->SERIALNO) .OR. NOT_NA(CTRLINFO->SERIALNO)
         cRETVAL := "N.A."
      ELSE
         cRETVAL := CTRLINFO->SERIALNO
      ENDIF
   ELSE
      cRETVAL := CTRLINFO->MOTORNO
   ENDIF
ELSE
   cRETVAL := CTRLINFO->PLATENO
ENDIF

RETURN cRETVAL
*--------------------->
FUNCTION MULT_UM()
LOCAL lRETVAL   := .F.
LOCAL nBOOKMARK := CTRLINFO->(RECNO())
LOCAL cKEY      := CTRLINFO->BRCODE+CTRLINFO->ACCTNO

CTRLINFO->(DBSKIP())

IF ALLTRIM(CTRLINFO->BRCODE+CTRLINFO->ACCTNO) == cKEY
   lRETVAL := .T.
ENDIF

CTRLINFO->(DBGOTO(nBOOKMARK))

RETURN lRETVAL
*--------------------->
FUNCTION MULT_HEAD()
**                                                                                        90       100       110       120       130
**12345678911234567892123456789312345678941234567895123456789612345678971234567898123456789012345678901234567890123456789012345678901234567890
//SETFONT('INIT')
   //SETFONT('ELITE')
   //setfont('BOLD')
   //@prow()+4,79  say chr(27)+chr(69)
   //@prow()+1,79  say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
   //@ PROW()+1,79 SAY '³ FIRST NOTICE ³'
   //@prow()+1,79  say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'+chr(27)+chr(70)
   //SETFONT('UNBOLD')
SETFONT("BOLD")
@ 11,38 SAY "LIST OF EXPIRING INSURANCE"
@ 13,12 SAY RTRIM(CLIENT->FULLNAME)
@ 14,12 SAY "ORIX METRO Acct. Number "+RIGHT(CTRLINFO->ACCTNO,5)
SETFONT("UNBOLD")
SETFONT("CONDENSED")
@ 16,21 SAY "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄ"
@ 17,21 SAY "              Unit/Model                  Plate N§/Motor N§        Existing Insurance Company     Insurance Policy N§   Insurance"
@ 18,21 SAY "                                              Serial N§                                                                Expiry Date"
@ 19,21 SAY "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄ"
*            1234567891123456789212345678931234567894 12345678911234567892 12345678911234567892123456789312345 12345678911234567892 123456789
RETURN NIL
