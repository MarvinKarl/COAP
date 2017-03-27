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
³   NATHAN PINEDA   ³ MAY. 3, 2004      ³  MODIFY LTO CERTIFICATION          ³ºº
ÀÄÒÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙºº
  ÈËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼º
   ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
*/
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
#include "inkey.ch"
#include "colf.ch"
#include "dbstruct.ch"
#include "ACHOICE.CH"
#define K_SPACEBAR    32
#define LMARGIN    15
#define REP_WIDTH  75
#define REP_LIMIT  LMARGIN + REP_WIDTH
memvar  AX_LEVEL, gUSER_ID
setcursor(0)
setblink(.t.)
if CHKPASS( procname(), AX_LEVEL, gUSER_ID )
	begin sequence
	OpenDBFiles()
	qMainmode()
	end sequence
	dbcloseall()
endif
__mrelease( '*', .t. )
return nil
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
Static Function qMainmode()
	local kuha
	local col_ := { ;
		tbcolumnnew( 'Code     ', { || AO->aocode } ),;
		tbcolumnnew( 'Name     ', { || AO->aoname } ),;
		tbcolumnnew( 'Position ', { || AO->aopost } ) }
	private cPlateNo, dIssue := Date(), nNotedby:=spac(40)
	Ins_Signee  := spac(40)
	cIns_Signee := spac(40)
	cSign_Post  := spac(30)
	signator := {}
	labas := .t.
	private ind := mrow := mcol := 1
	cPlateNo := if( month(gTrandate) > 9, '0', alltrim(str(month(gTrandate))) )
	setcursor(1)
	fshadow(08,7,11,38,2, 'n/w')
	@ 09,8 say 'Plate No. Ending  ' get cPlateNo picture '9' valid !empty(cPlateNo)
	@ 10,8 say 'Date of Issuance  ' get dIssue picture '99/99/9999' 
	read
	ao->(dbsetorder(1))
	fshadow(12,18,15,65,2,'w+/w')
	setcolor('n/w,w+/n,,,w+/w')
	setcursor(1)
	@ 14, 19 say ' Sign By         ' get Ins_Signee pict '@!XS25' ;
      when lastkey() <> K_ESC .and. !empty(Ins_Signee := eval( { || flook_online(.t.,'AO',,' Account Officers ',,,, ) } ) ) ;
		valid !empty(Ins_Signee)
	//setkey(K_ESC, { || Fescape('Abort? ') } )
	read
	ao->(dbgotop())
	ao->(dbseek(Ins_Signee))
	cIns_Signee :=   AO->aoname
	cSign_Post  :=   AO->aopost
	while !empty(Ins_Signee)
      *repcontrol('repPrn3700()')
      repcon_ol('repPrn3700()',,,,,,,.F.)
		exit
	enddo
return nil
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
function actionkey( a_, b_, c_ )
	local k := lastkey(), ret_val := AC_CONT, h
	memvar ind, mrow, mcol
	do case
		case a_ == AC_HITTOP
			ret_val := AC_ABORT
		case a_ == AC_HITBOTTOM
			ret_val := AC_ABORT
		case a_ == AC_IDLE .or. k == 255
		case k == K_SPACEBAR
			for h := 1 to len( signator )
				signator[ h ] := stuff( signator[ h ], 1, 1," " )
			next
			signator[b_] := stuff ( signator[b_],1,1,;
			if(substr(signator[b_],1,1) == ' ', 'û', ' ' ) )
			mrow     := b_
			mcol     := c_
			ret_val  := AC_ABORT
		case k == K_ENTER .or. k == K_ESC
			mrow     := b_
			mcol     := c_
			ret_val := AC_ABORT
	endcase
return( ret_val )
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
function bintana()
	fShadow( 7, 3, 20, 76  , 2, 'w+/n', '  Account Officers  ' )
	@  8, 04 say ' Tag  Code  Name                   Position                             '  color 'w+/bg'
	@  9, 04 say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'  color 'w/n'
	@ 10, 04 say '³                                                                      ³'  color 'w/n'
	@ 11, 04 say '³                                                                      ³'  color 'w/n'
	@ 12, 04 say '³                                                                      ³'  color 'w/n'
	@ 13, 04 say '³                                                                      ³'  color 'w/n'
	@ 14, 04 say '³                                                                      ³'  color 'w/n'
	@ 15, 04 say '³                                                                      ³'  color 'w/n'
	@ 16, 04 say '³                                                                      ³'  color 'w/n'
	@ 17, 04 say '³                                                                      ³'  color 'w/n'
	@ 18, 04 say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'  color 'w/n'
	@ 19, 04 say '                                                                        '  color 'n/w'
	@ 11, 73 , 16, 73   box repl( '°', 9 )                     color '+w/n'
	@ 10, 73 say chr( 24 )                                    color 'n/w+'
	@ 17, 73 say chr( 25 )                                    color 'n/w+'
return nil
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
Function repPrn3700()
	dbselectarea('CTRLINFO')
	dbsetorder(1)
	dbselectarea('ACCTMAST')
	dbsetorder(2)                   // acctacno = acctname + acctno
	dbgotop()
	do while !(ACCTMAST->(eof()))   // sorted by account name
      IF ACCTMAST->BRCODE == g_PAR_BRCH
         CTRLINFO->(dbseek(ACCTMAST->BRCODE+ACCTMAST->AcctNo))

         do while ACCTMAST->BRCODE+ACCTMAST->AcctNo == CTRLINFO->BRCODE+CTRLINFO->AcctNo .and. !(CTRLINFO->(eof()))
            //print certification of active accounts with plate number
            //ending with the specified number
            if right(alltrim(CTRLINFO->PlateNo),1) == cPlateNo .and. ACCTMAST->OsBal > 0
            //verify if account is leased (103) or loaned (104)
               if left( ACCTMAST->FcltyCode, 3 ) == '103'
                  LeaseCertPrn()
               else
                  LoanCertPrn()
               endif
            endif
            CTRLINFO->(dbskip())
         enddo
      ENDIF
		ACCTMAST->(dbskip())
	enddo
return nil
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
Static function LeaseCertPrn()
	local cPrnLn, cBrCode
	setprc(0,0)
	SETFONT('INIT')
	SETFONT('ELITE')
	SETFONT('NLQ')
	SETFONT('BOLD')
	@ prow()+12,LMARGIN say chr(14) + padc('C E R T I F I C A T I O N',int(REP_WIDTH / 2)) + chr(14)
	@ prow()+5,LMARGIN  say 'TO WHOM THIS MAY CONCERN:'
	SETFONT('UNBOLD')
	@ prow()+3,LMARGIN say ''
	cPrnLn := '      This is to certify that the original LTO Certificate of Registration of '
	cPrnLn := cPrnLn + '^B' + alltrim(CTRLINFO->ColType) + '^U is in our custody.'
	PrintBlock(cPrnLn)
	@ prow()+2,LMARGIN say ''
	cPrnLn := '      The unit is being leased to ^B' + alltrim(ACCTMAST->AcctName) + '^U'
	cPrnLn := cPrnLn + ' under Lease Contract No. ^B' + alltrim(right(ACCTMAST->AcctNo,5)) + '^U'
	cPrnLn := cPrnLn + ' and particulary described as follows:'
	PrintBlock(cPrnLn)
	SETFONT('BOLD')
	@ prow()+2,LMARGIN+15 say 'Motor No.      :     ' + alltrim(CTRLINFO->Motorno)
	@ prow()+1,LMARGIN+15 say 'Serial No.     :     ' + alltrim(CTRLINFO->SerialNo)
	@ prow()+1,LMARGIN+15 say 'Yr. Model      :     ' + alltrim(CTRLINFO->ColModel)
	@ prow()+1,LMARGIN+15 say 'Plate No.      :     ' + alltrim(CTRLINFO->PlateNo)
	@ prow()+1,LMARGIN+15 say 'MV File No.    :     ' + alltrim(CTRLINFO->mrvno)
	SETFONT('UNBOLD')
	@ prow()+2,LMARGIN say ''
	cPrnLn := '      This certification is issued upon the request of the LESSEE '
	cPrnLn := cPrnLn + 'for whatever legal purpose it may serve.'
	PrintBlock(cPrnLn)
	@ prow()+2,LMARGIN say ''
	cPrnLn := '      Issued on this ^B' + alltrim(str(day(dIssue))) + 'th day of '
	cPrnLn := cPrnLn + alltrim(upper(cmonth(dIssue))) + ', ' + alltrim(str(year(dIssue)))
	cPrnLn := cPrnLn + '^U, in the City of Makati.'
	PrintBlock(cPrnLn)
	@ prow()+4,LMARGIN say ''
	cBrCode := alltrim(substr(ACCTMAST->AcctNo,3,2))
	SETFONT('BOLD')
	do case
		case cBrCode == '07'
			@ prow()+1,REP_LIMIT-31 say '     ORIX METRO LEASING AND    '
			@ PROW()+1,REP_LIMIT-31 say '      FINANCE  CORPORATION     '
			//@ prow()+1,REP_LIMIT-31 say ' (Formerly known as First Metro'
			//@ prow()+1,REP_LIMIT-31 say '     Leasing & Finance Corp.)  '
		case cBrCode == '08'
			@ prow()+1,REP_LIMIT-31 say '     ORIX METRO LEASING AND    '
			@ PROW()+1,REP_LIMIT-31 say '      FINANCE  CORPORATION     '
			//@ prow()+1,REP_LIMIT-31 say '     (Formerly known as PBC    '
			//@ prow()+1,REP_LIMIT-31 say '    Leasing & Finance Corp.)   '
		otherwise
			@ prow()+1,REP_LIMIT-31 say '    ORIX METRO LEASING AND     '
			@ PROW()+1,REP_LIMIT-31 say '     FINANCE  CORPORATION      '
			//@ prow()+1,REP_LIMIT-31 say '(Formerly known as Consolidated' 
			//@ prow()+1,REP_LIMIT-31 say ' Orix Leasing & Finance Corp.) '
	endcase
	@ prow()+3,REP_LIMIT-31 say padc(alltrim(cIns_Signee),31)
	@ prow()+1,REP_LIMIT-31 say padc(alltrim(cSign_Post),31)
	SETFONT('UNBOLD')
	__eject()
return nil
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
Static function LoanCertPrn()
	local cPrnLn, cBrCode
	setprc(0,0)
	SETFONT('INIT')
	SETFONT('ELITE')
	SETFONT('NLQ')
	SETFONT('BOLD')
	@ prow()+12,LMARGIN say chr(14) + padc('C E R T I F I C A T I O N',int(REP_WIDTH / 2)) + chr(14)
	@ prow()+5,LMARGIN  say 'TO WHOM THIS MAY CONCERN:'
	SETFONT('UNBOLD')
	@ prow()+3,LMARGIN say ''
	cPrnLn := '      This is to certify that the original LTO Certificate of Registration of '
	cPrnLn := cPrnLn + '^B' + alltrim(CTRLINFO->ColType) + '^U with Plate No. ^B'
	cPrnLn := cPrnLn + alltrim(CTRLINFO->PlateNo) + '^U is in our custody.'
	PrintBlock(cPrnLn)
	@ prow()+2,LMARGIN say ''
	cPrnLn := '      The  unit is owned by ^B' + alltrim(ACCTMAST->AcctName) + '^U'
	cPrnLn := cPrnLn + ' and duly encumbered to ^BORIX METRO^U under Loan Account No. ^B'
	cPrnLn := cPrnLn + alltrim(right(ACCTMAST->AcctNo,5)) + '^U. Vehicle details are as follows:'
	PrintBlock(cPrnLn)
	SETFONT('BOLD')
	@ prow()+2,LMARGIN+15 say 'Motor No.      :     ' + alltrim(CTRLINFO->Motorno)
	@ prow()+1,LMARGIN+15 say 'Serial No.     :     ' + alltrim(CTRLINFO->SerialNo)
	@ prow()+1,LMARGIN+15 say 'MV File No.    :     ' + alltrim(CTRLINFO->mrvno)  
	SETFONT('UNBOLD')
	@ prow()+2,LMARGIN say ''
	cPrnLn := '      This certification is issued upon the request of the MORTGAGOR '
	cPrnLn := cPrnLn + 'for whatever legal purpose it may serve.'
	PrintBlock(cPrnLn)
	@ prow()+2,LMARGIN say ''
	cPrnLn := '      Issued this ^B' + alltrim(str(day(dIssue))) + 'th day of '
	cPrnLn := cPrnLn + alltrim(upper(cmonth(dIssue))) + ', ' + alltrim(str(year(dIssue)))
	cPrnLn := cPrnLn + '^U, in the City of Makati.'
	PrintBlock(cPrnLn)
	@ prow()+4,LMARGIN say ''
	cBrCode := alltrim(substr(ACCTMAST->AcctNo,3,2))
	SETFONT('BOLD')
	do case
		case cBrCode == '07'
			@ prow()+1,REP_LIMIT-31 say '     ORIX METRO LEASING AND    '
			@ PROW()+1,REP_LIMIT-31 say '      FINANCE  CORPORATION     '
			//@ prow()+1,REP_LIMIT-31 say ' (Formerly known as First Metro'
			//@ prow()+1,REP_LIMIT-31 say '    Leasing & Finance Corp.)   '
		case cBrCode == '08'
			@ prow()+1,REP_LIMIT-31 say '     ORIX METRO LEASING AND    '
			@ PROW()+1,REP_LIMIT-31 say '      FINANCE  CORPORATION     '
			//@ prow()+1,REP_LIMIT-31 say '     (Formerly known as PBC    '
			//@ prow()+1,REP_LIMIT-31 say '     Leasing & Finance Corp.)  '
		otherwise
			@ prow()+1,REP_LIMIT-31 say '    ORIX METRO LEASING AND     '
			@ PROW()+1,REP_LIMIT-31 say '     FINANCE  CORPORATION      '
			//@ prow()+1,REP_LIMIT-31 say '(Formerly known as Consolidated' 
			//@ prow()+1,REP_LIMIT-31 say ' Orix Leasing & Finance Corp.) '
	endcase
	@ prow()+3,REP_LIMIT-31 say padc(alltrim(cIns_Signee),31)
	@ prow()+1,REP_LIMIT-31 say padc(alltrim(cSign_Post),31)
	SETFONT('UNBOLD')
	__eject()
return nil
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
Static Function OpenDBFiles()
// EVR	if !netuse('PARAMETR',.f.,5)
// EVR		break
// EVR	endif
	if !netuse('&g_Cis_path\AO',.f.,5)
		break
	else
		if !.f.; ordlistclear(); endif
		ordlistadd( '&g_Cis_path\AO' )                    && set index on AONAME
	endif
   if !netuse('&g_AMS_PATH\ACCTMAST',.f.,5)
		break
	else
      set index to &g_AMS_PATH\ACCTMAST,;
                   &g_AMS_PATH\ACCTACNO
	endif
   if !netuse('&g_AMS_PATH\CTRLINFO',.f.,5)
		break
	else
      set index to &g_AMS_PATH\CTRLINFO
	endif
   if !netuse( '&g_AMS_PATH\FLAG', .f., 5 )
		break
	endif
	if !netuse('&g_Cis_path\CLIENT', .f., 10 )    // Client file
		break
	else
		if !.f.; ordlistclear(); endif
		ordlistadd('&g_Cis_path\CLIENM')           // set index on Fullname
	endif
return nil
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
static function PrintBlock( cPrgraph )
	local nPos := 0, cWord := '', cLine := ''

	// accept starting spaces
	do while left(cPrgraph,1) == ' '
		cLine := cLine + ' '
		cPrgraph := substr(cPrgraph,2)
	enddo

	cPrgraph := rtrim(cPrgraph)

	do while len(cPrgraph) > 0
		nPos := at(' ', cPrgraph)
		if nPos == 0
			cWord := cPrgraph
			cPrgraph := ''
		else
			cWord := left(cPrgraph, nPos-1)
			cPrgraph := substr(cPrgraph, nPos+1 )
		endif

		if ( pcol() + len(cLine+cWord) - CtrlChrCnt(cWord) ) > REP_LIMIT
			PrintLine(BJustify(cLine, REP_WIDTH + 1))
			@ prow()+1,LMARGIN say ''
			cLine := cWord

			if nPos == 0
				PrintLine(cLine)
			endif
		else
			cLine := iif( cLine == '', cWord, cLine + ' ' + cWord )

			if nPos == 0
				PrintLine(cLine)
			endif
		endif
	enddo
return nil
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
static function PrintLine( cStrLine )
	local nPtr := 1, cChar := ''
	do while nPtr <= len(cStrLine)
		cChar := substr(cStrLine,nPtr,1)
		if cChar == '^'
			cChar := substr(cStrLine,++nPtr,1)
			do case
				case cChar == 'B'
					SETFONT('BOLD')
				case cChar == 'U'
					SETFONT('UNBOLD')
				case cChar == 'N'
					SETFONT('NORMAL')
				case cChar == 'E'
					SETFONT('ELITE')
				case cChar == 'D'
					SETFONT('DRAFT')
				case cChar == 'C'
					SETFONT('CONDENSED')
				case cChar == 'S'
					SETFONT('UNCONDENSD')
				case cChar == 'I'
					SETFONT('INIT')
				case cChar == 'P'
					SETFONT('PICA')
			endcase
		else
			@ prow(),pcol() say cChar
		endif
		nPtr++
	enddo
return nil
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
static function BJustify( cLine, nWidth )
	local nCtrlChr := 0, cSpaces := '', cResult := ''
	local nPrev := 1, nNew := 0

	do while left(cLine,1) == ' '
		cSpaces := cSpaces + ' '
		cLine := substr(cLine,2)
	enddo

	cResult := alltrim(cLine)
	nCtrlChr := CtrlChrCnt(cResult)

	do while ( len(cSpaces + cResult) - nCtrlChr ) < nWidth
		do while nNew == 0
			nNew := at(' ', substr(cResult, nPrev) )
			if nNew == 0
				nPrev := 1
			endif
		enddo

		do while substr(cResult, nPrev + nNew, 1 ) == ' '
			nNew++
		enddo

		nNew += nPrev
		cResult := left(cResult,nNew-1) + ' ' + substr(cResult,nNew)
		nPrev := nNew + 1
		nNew := 0

	enddo
	cResult := cSpaces + cResult
return cResult
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
static function CtrlChrCnt( cString )
	local nCount := 0
	do while at('^', cString) > 0
		nCount += 2
		cString := substr(cString, at('^', cString) + 1)
	enddo
return nCount
////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
	//flook( .t.,'AO','spac(30)','Client File',,,,,.f.,col_ )
	//flook( .t.,'AO','spac(30)',' Account Officer ',3,4,1,1,.f.,col_ )
	//DO WHILE !AO->(EOF())
	//	aadd(signator,' ' + ' ³ ' + padr( AO->aocode,5 ) + ' ³ ' + padr( AO->aoname,40) + ' ³ ' + padr( AO->aopost ,30) )
	//	AO -> (dbskip(+1))
	//ENDDO
	//bintana()
	//DO WHILE .T.
		//Pick := ACHOICE(10,06,17,60,signator,.t.,"actionkey",mrow,mcol)
		//setcursor(0)
		//if lastkey() == K_ENTER
			//for g := 1 to len( signator )
				//if(substr(signator[g],1,1) == 'û' )
					//cIns_Signee := substr(signator[g],13,40)
					//cSign_Post  := substr(signator[g],56,30)
				//endif	
			//next
		//repcontrol('repPrn3700()')
		//endif
		//if lastkey() == K_ESC
			//return
		//endif
	//ENDDO
