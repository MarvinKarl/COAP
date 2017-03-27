/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   colf-iis -- account management system                                      ³
³   program idúúú amsr3000                                                     ³
³   descriptionúú PDC for Deposit                                              ³
³   authorúúúúúúú renan s. evangelista                                         ³
³   dateúúúúúúúúú 9:20:am úú 07-24-96                                          ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                             u p d a t e s                                    ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        who        ³       when        ³               why                    ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                   ³                   ³                                      ³
³ Noel B. Santos    ³   Oct. 21, 2001   ³ Sorted report output by Account      ³
³                   ³                   ³ Name. (Per Request of Ma'm Weng)     ³
³                   ³                   ³                                      ³
³ Marvin T. Sabile  ³   July 14, 2011   ³ Added PDCDTBCK database              ³
³ Edreb S. Virtusio ³   Jan. 30, 2013   ³ Options to print PWT/SDB/ALL         ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include 'inkey.ch'
#include 'colf.ch'
#include 'dbstruct.ch'

#define K_SPACEBAR   32
#define microfeed    chr( 27 ) + 'J' + chr( 18 )

memvar  AX_LEVEL, gUSER_ID

private cTempPDCfile, cTempIndex, pdcTYPE := {"PDC's WAREHOUSING","PDC's SAFETY DEPOSIT BOX"}

setcursor(0)
setblink(.t.)
if !chkpass( procname(), AX_LEVEL, gUSER_ID )
   //NOTHING WILL HAPPEN
else
   begin sequence
	 aOpen9999()
         aMain9999()
   end sequence
   dbcloseall()
endif

// delete temporary files

ferase( cTempPDCfile )
ferase( cTempIndex )

__mrelease( '*', .t. )

return nil

/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

Static Function aOpen9999()

  local aTempStruc := { { 'AcctNo'  ,'C',14,00 } ,;
                        { 'AcctName','C',34,00 } ,;
                        { 'Bank'    ,'C',25,00 } ,;
                        { 'ChkNo'   ,'C',12,00 } ,;
                        { 'ChkAmt'  ,'N',11,02 } ,;
                        { 'CLNTNO'  ,'C',07,00 } ,;
                        { 'PDC'     ,'C',01,00 } ,;
                        { 'Brcode'  ,'C',03,00 }  ;
                      }
  
  if !netuse( '&g_AMS_PATH\Acctmast', .f., 10 )              && Account master file
     break
  else
     if !.f.; ordlistclear(); endif //1noels
     ordlistadd( '&g_AMS_PATH\Acctmast' )                    && set index on acctname
  endif
  
  if !netuse( '&g_AMS_PATH\Pdc_dtls', .f., 10 )               && Payment Schedule file
     break
  else
     if !.f.; ordlistclear(); endif
     ordlistadd( '&g_AMS_PATH\Pdcdeptl' )                     && set index depdate
  endif
  
  if !netuse( '&g_AMS_PATH\AMSBACK\PDCDTBCK', .f., 10 )               && Payment Schedule file
     break
  else
     if !.f.; ordlistclear(); endif
     ordlistadd( '&g_AMS_PATH\AMSBACK\PBKDEPTL' )                     && set index depdate
  endif

  //create a unique temporary file

  cTempPDCfile := UniqFile('DBF')

  dbcreate( (cTempPDCfile), aTempStruc )

  if valtype(cTempPDCfile) != 'U'
    if ( netuse((cTempPDCfile), .t., 0) )    // open temp file exclusively

      // create new index file

      cTempIndex := UniqFile('NTX')
      dbcreateindex( cTempIndex, 'PDC+AcctName', { || PDC+AcctName }, .f. )
    else
      alert('Unable to open file.')
    endif
  else
    alert('Unable to create file.')
  endif

return nil

/////////////////////////////////////////////////////////////////////////////

Static Function Amain9999()
  local mu:=savedbf(),re:=setcursor(),bf:=savescreen(,,,),gf:=setcolor()
  private ddate:=mtrandate, sprint := 0
  setkey(K_ESC, nil)
  setcolor('n/w,w/n,,,w+/w')
  setcursor(1)
  fshadow(11,30,15,65,2,'n/w')
  @ 12,32 say '[1]-PWT   [2]-SDB   [3]-ALL'
  @ 13,32 say 'Option to Print    ' get sprint picture '9' valid sprint > 0 .and. sprint <= 3
  @ 14,32 say 'PDC Date to Print  ' get ddate pict '@D' valid !empty(ddate) .and. chkpdcdate(ddate)
  setkey(K_ESC ,{ || fescape( 'Abort?' ) } )
  read
  setkey(K_ESC, nil)
  if lastkey() <> K_ESC
     reportprint('pdc09999()')
     *repcon_ol('pdc09999()',,,,,,,.F.)
  endif
  restdbf(mu);restscreen(,,,,bf);setcursor(re);setcolor(gf)
return nil

/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

Function pdc09999()

  local mu:=savedbf(),re:=setcursor(),bf:=savescreen(,,,),gf:=setcolor()
  local pgn:=1,chkcnt:=0,tot_amount:=0
  local xdate:=cmonth(ddate) + ' ' + str(day(ddate),2) +', '+str(year(ddate),4)
  local ThenTrig := .T., NowTrig := .T.

  
  dbselectarea('PDCDTBCK')
  dbsetorder(1)
  IF PDCDTBCK->(dbseek(ddate))
      
	  //Head_9999(pgn,xdate)
	  
	  do while PDCDTBCK->Depdate == dDate .and. PDCDTBCK->(!eof())
		 IF PDCDTBCK->BRCODE == g_PAR_BRCH
			if PDCDTBCK->Status <> '1'
			  PDCDTBCK->(dbskip())       // abb 05.09.2001 ( infinite loop )
			  loop
			endif
			
			if sprint < 3
				if sprint == 1
					if !PDCDTBCK->ltransmit
						PDCDTBCK->(dbskip())
						loop
					endif
				else
					if PDCDTBCK->ltransmit
						PDCDTBCK->(dbskip())
						loop
					endif
				endif
			endif

			If ThenTrig
			   Head_9999(pgn,xdate)
			   ThenTrig := .F.
			EndIf

			if PDCDTBCK->ltransmit
				pdcsort := '1'
			else
				pdcsort := '2'
			endif
			chkcnt++
			tot_amount += PDCDTBCK->ChkAmt
			accname:=eval( {|| ACCTMAST->(dbseek(PDCDTBCK->BRCODE+PDCDTBCK->Acctno)), substr(ACCTMAST->Acctname,1,34) } )

			// save data to our temporary file

			(cTempPDCfile)->(dbappend())
			(cTempPDCfile)->AcctNo   := PDCDTBCK->AcctNo
			(cTempPDCfile)->AcctName := accname
			(cTempPDCfile)->Bank     := PDCDTBCK->Bank
			(cTempPDCfile)->ChkNo    := PDCDTBCK->ChkNo
			(cTempPDCfile)->ChkAmt   := PDCDTBCK->ChkAmt
			(cTempPDCfile)->CLNTNO   := IF(ACCTMAST->(DBSEEK(PDCDTBCK->BRCODE+PDCDTBCK->ACCTNO)), ACCTMAST->CLNTCODE, SPACE(7))
			(cTempPDCfile)->BRCODE   := PDCDTBCK->BRCODE
			(cTempPDCfile)->(dbcommit())
		 ENDIF

		 PDCDTBCK->(dbskip())
	  enddo
  EndIf
  
  dbselectarea('PDC_DTLS')
  dbsetorder(1)
  If PDC_DTLS->(dbseek(ddate))

	  //Head_9999(pgn,xdate)
	  
	  do while PDC_DTLS->Depdate == dDate .and. Pdc_dtls->(!eof())
		 IF PDC_DTLS->BRCODE == g_PAR_BRCH
			if PDC_DTLS->Status <> '1'
			  PDC_DTLS->(dbskip())       // abb 05.09.2001 ( infinite loop )
			  loop
			endif
			
			if sprint < 3
				if sprint == 1
					if !PDC_DTLS->ltransmit
						PDC_DTLS->(dbskip())
						loop
					endif
				else
					if PDC_DTLS->ltransmit
						PDC_DTLS->(dbskip())
						loop
					endif
				endif
			endif

			If NowTrig
			   Head_9999(pgn,xdate)
			   NowTrig := .F.
			EndIf
			
			if PDC_DTLS->ltransmit
				pdcsort := '1'
			else
				pdcsort := '2'
			endif
			
			chkcnt++
			tot_amount += PDC_DTLS->ChkAmt
			accname:=eval( {|| ACCTMAST->(dbseek(PDC_DTLS->BRCODE+PDC_DTLS->Acctno)), substr(ACCTMAST->Acctname,1,34) } )

			// save data to our temporary file

			(cTempPDCfile)->(dbappend())
			(cTempPDCfile)->AcctNo   := PDC_DTLS->AcctNo
			(cTempPDCfile)->AcctName := accname
			(cTempPDCfile)->Bank     := PDC_DTLS->Bank
			(cTempPDCfile)->ChkNo    := PDC_DTLS->ChkNo
			(cTempPDCfile)->ChkAmt   := PDC_DTLS->ChkAmt
			(cTempPDCfile)->CLNTNO   := IF(ACCTMAST->(DBSEEK(PDC_DTLS->BRCODE+PDC_DTLS->ACCTNO)), ACCTMAST->CLNTCODE, SPACE(7))
			(cTempPDCfile)->BRCODE   := PDC_DTLS->BRCODE
			(cTempPDCfile)->PDC      := pdcsort
			(cTempPDCfile)->(dbcommit())
		 ENDIF

		 PDC_DTLS->(dbskip())
	  enddo
  EndIf
  
  // print table

  (cTempPDCfile)->(dbgotop())
  mnewPDC := '0'
  mcount := 0
  subchk := 0
  subamount := 0
  do while ! (cTempPDCfile)->(eof())
  
    if prow() > 54
      __eject()
      pgn++
      Head_9999(pgn,xdate)
    endif
	if sprint == 3
		if (cTempPDCfile)->PDC == '2' .and. mcount == 0
			mcount++
			if subchk > 0
				setfont('BOLD')
				@ PROW()+2, 08 say '                SUB-TOTAL :                '+trans(subchk,'999,999')+spac(10)+'               '+trans(subamount,'99,999,999.99')
				@ PROW()+1, 08 say '                                           '+'ÍÍÍÍÍÍÍ'+spac(25)+'ÍÍÍÍÍÍÍÍÍÍÍÍÍ'
				setfont('UNBOLD')
			endif
			subchk := 0
			subamount := 0
		endif
		if mnewPDC != (cTempPDCfile)->PDC
				@ prow()+1, 02 say ' '
				setfont('BOLD')
				@ prow()+1, 02 say pdcTYPE[val((cTempPDCfile)->PDC)]
				@ prow()+1, 02 say ' '
				setfont('UNBOLD')
				mnewPDC := (cTempPDCfile)->PDC
		endif
	endif
    @ prow()+1, 02 say (cTempPDCfile)->BRCODE+'-'+(cTempPDCfile)->CLNTNO+' '+(cTempPDCfile)->BRCODE+'-'+substr((cTempPDCfile)->Acctno,-5,5)+'-'+;
                       LEFT((cTempPDCfile)->AcctName,29)+' '+substr((cTempPDCfile)->Bank,1,15)+' '+(cTempPDCfile)->Chkno+' '+tran((cTempPDCfile)->ChkAmt,'@R 99,999,999.99')
					   
					   subchk++
					   subamount += (cTempPDCfile)->ChkAmt
	
	(cTempPDCfile)->(dbskip())
  enddo

  if sprint == 3
  setfont('BOLD')
  @ PROW()+2, 08 say '                SUB-TOTAL :                '+trans(subchk,'999,999')+spac(10)+'               '+trans(subamount,'99,999,999.99')
  @ PROW()+1, 08 say '                                           '+'ÍÍÍÍÍÍÍ'+spac(25)+'ÍÍÍÍÍÍÍÍÍÍÍÍÍ'
  @ PROW()+2, 08 say 'GRAND TOTAL NO. OF CHECKS :                '+trans(chkcnt,'999,999')+spac(10)+'GRAND TOTAL :  '+trans(tot_amount,'99,999,999.99')
  @ PROW()+1, 08 say '                                           '+'ÍÍÍÍÍÍÍ'+spac(25)+'ÍÍÍÍÍÍÍÍÍÍÍÍÍ'
  setfont('UNBOLD')
  __eject()
  else
  setfont('BOLD')
  @ PROW()+2, 08 say 'TOTAL NO. OF CHECKS :                '+trans(chkcnt,'999,999')+spac(16)+'TOTAL :        '+trans(tot_amount,'99,999,999.99')
  @ PROW()+1, 08 say '                                     '+'ÍÍÍÍÍÍÍ'+spac(31)+'ÍÍÍÍÍÍÍÍÍÍÍÍÍ'
  setfont('UNBOLD')
  __eject()
  endif

return nil

/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

Static Function Head_9999( pgn,xdate )
  setprc(0,0)
  setfont('DRAFT')
  setfont('ELITE')
  @ prow()+1,02 say 'ACCOUNT MANAGEMENT SYSTEM'
  @ prow(),  02+len('ACCOUNT MANAGEMENT SYSTEM');
                say PADL('Page No. ' + tran(pgn,'999'),94-len('ACCOUNT MANAGEMENT SYSTEM'))
  @ prow()+1,02 say 'AMSR0500'
  @ prow()  ,02+len('AMSR0500');
                say PADL( dtoc(DATE())+' '+TIME(), 94-len('AMSR0500'))
  @ prow()+1,02 say PADC('ORIX METRO LEASING AND FINANCE CORPORATION',94)
  @ prow()+1,02 say padc('LIST OF PDC FOR DEPOSIT',94)
  @ prow()+1,02 say padc('For '+ xdate,94)
  setfont('BOLD')
  if sprint < 3
	@ prow()+1,02 say padc(pdcTYPE[sprint],94)
  endif
  setfont('UNBOLD')
  @ prow()+1,02 say ' '
  @ prow()+1,02 say '----------- --------------------------------------- --------------- ------------ -------------'
  @ prow()+1,02 say 'Client Code          Account Number/Name                  Bank      Check Number     Amount   '
  @ prow()+1,02 say '----------- --------------------------------------- --------------- ------------ -------------'
//  @ prow()+1,02 say ' '
return nil


/////////////////////////////////////////////////////////////////////////////

/*       1         2         3         4         5         6         7         8         9         0         1         2         3         4
12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
       TOTAL NO. OF CHECKS :                999,999           TOTAL :           99,999,999.99
COLF
 ----------------------------------------   ---------------   ---------------   -------------
         Account Number/Name                    Bank           Check Number        Amount
 ----------------------------------------   ---------------   ---------------   -------------
 99999-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   XXXXXXXXXXXXXXX   999999999999999   99,999,999.99

*/
