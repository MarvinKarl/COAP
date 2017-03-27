/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   PROGRAM ID.........:  amsq0600.prg                                         ³
³   Description........:  unavailed line                                       ³
³   Author.............:  abb                                                  ³
³   Date...............:  02:45pm 23-Feb-2000                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                         U P D A T E S                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        Who        ³     When      ³               Why                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                   ³               ³                                          ³
³  noel b. santos   ³ Nov. 08, 2001 ³ Modify this report module as per         ³
³                   ³               ³ Sales request.                           ³
³                   ³               ³                                          ³
³  noel b. santos   ³ Dec. 14, 2001 ³ Modify the format of this report         ³
³                   ³               ³                                          ³
³  marvin t. sabile ³ Sep. 21, 2012 ³ Modify distribution of Principal and     ³
³                   ³               ³   credit amount if 2 CA's are used       ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include 'INKEY.CH'
#include 'COLF.CH'

#define NIRVANE tone( 480, 0.25 ); tone( 240, 0.25 )

local WATER
PRIVATE xCLNTCODE := SPACE(10)

if CHKPASS( procname(), AX_LEVEL, gUSER_ID )
  // nosnow( .t. )
  
  if fopen0110()
    fmain0600()
    dbcloseall()
    __mrelease( '*', WATER )
  endif
  
  // nosnow(.f.)
endif

return

/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

static function fMAIN0600()

  local msv
  MEMVAR xCLNTCODE
  priva sw:=1, cnt := inc := 0, ind := 1, on, off := 0

  ********alert ( '1' )

  msv := savescreen( ,,, )
  if !fDate0110()
    reportprint( 'fPrnt0600()', '80 Columns' )
    *repcon_ol( 'fPrnt0600()', '80 Columns',,,,,,.F. )
  endif

*******   alert ( '2' )
  restscreen( ,,,, msv )
return nil

/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

function fPrnt0600()

  local nTotAvail, nCredAmount, cGroupCode
  local nTotBook, nTotCred1, nTotPend, nTotCred2, _seek := .t., cbrcode , mmem:= '000'
  local nbook_prncpl := 0, nbook_crdamt := 0, lexceed := .f., nrefno2 := space(5)

  setprc(0,0)
  SETFONT('NORMAL')
  SETFONT('ELITE')

  _heading()

  // show CA accounts

  CAHEADER->(dbseek( xCLNTCODE )) &&RED CLIENT->BRCODE+CLIENT->ClntCode ))

  do while (CAHEADER->BRCODE+CAHEADER->ClntCode == xCLNTCODE) .and. ! CAHEADER->(eof()) && CLIENT->BRCODE+CLIENT->ClntCode
     if CAHEADER->AcTaken != '3'     // approved accounts only
        CAHEADER->(dbskip())
        loop
     endif

     SETFONT('BOLD')
     @ prow()+2, 05 say 'CA#' + CAHEADER->CAnumber
     SETFONT('UNBOLD')

     nTotBook  := 0
     nTotCred1 := 0
     nTotPend  := 0
     nTotCred2 := 0

    // get group number

     /*GRPMEMBR->(dbsetorder(1))             // client
     GRPMEMBR->(dbseek(xCLNTCODE))    && RED CLIENT->BRCODE+CLIENT->ClntCode))

     cGroupCode := iif( GRPMEMBR->BRCODE+GRPMEMBR->ClntCode == xCLNTCODE, GRPMEMBR->BRCODE+GRPMEMBR->GrupCode, "" )   && RED CLIENT->BRCODE+CLIENT->ClntCode

     GRPMEMBR->(dbsetorder(2))             // group
     GRPMEMBR->(dbseek(cGroupCode))*/
	 
	 GRPMEMBR->(dbsetorder(1))             // client 6:15 PM 2/26/2009 RLV
	 if Grpmembr->( dbseek( Caheader->brcode+Caheader->clntcode ) )
	   do while Caheader->brcode+Caheader->clntcode == GRPMEMBR->BRCODE+GRPMEMBR->CLNTCODE
			if Caheader->brcode == GRPMEMBR->BRCODE2
			   mmem := Grpmembr->grupcode
				exit
			else
				GRPMEMBR->(dbskip(1))
			endif
		enddo  
	else
		Grpmembr->( ordsetfocus( 3 ) )
		if Grpmembr->( dbseek( Caheader->brcode+Caheader->clntcode ) )
			mmem := Grpmembr->grupcode
			_seek := .f.
			cbrcode := GRPMEMBR->BRCODE
		endif
	endif		

	Grpmembr->( ordsetfocus( 2 ) ) //group
	if _seek
		Grpmembr->( dbseek( Caheader->brcode+mmem ) )
		cGroupCode :=GRPMEMBR->BRCODE+GRPMEMBR->GrupCode
	else
      //alert( 'yyy' )
      //alert(  cbrcode+'--'+mmem)
      Grpmembr->( dbseek( cbrcode+mmem ) )
      if Grpmembr->BRCODE == Caheader->BRCODE
        cGroupCode :=GRPMEMBR->BRCODE+GRPMEMBR->GrupCode
      endif
	endif
	 
	// alert(cGroupCode)

     if !empty(cGroupCode)

        do while (GRPMEMBR->BRCODE+GRPMEMBR->GrupCode == cGroupCode) .and. ! GRPMEMBR->(eof())
           // get all booked accounts

           ACCTMAST->(dbseek(if(Grpmembr->brcode != Grpmembr->brcode2,Grpmembr->brcode2+Grpmembr->clntcode,Grpmembr->brcode+Grpmembr->clntcode))) //aga.20.06.2005.palitan ko mula grpmember to grpmembr

           do while (ACCTMAST->BRCODE+ACCTMAST->ClntCode == grpmembr->BRCODE+GRPMEMBR->ClntCode) .and. ! ACCTMAST->(eof())
              if ACCTMAST->status == '0'  // CANCELLED RLV 08/18/2010
                 ACCTMAST->(dbskip())
                 loop
              endif
			  
              if ACCTMAST->RefNo != CAHEADER->CAnumber
                 ACCTMAST->(dbskip())
                 loop
              endif
  
              if ACCTMAST->DocRef != '1'    // check if account is CA
                 ACCTMAST->(dbskip())
                 loop
              endif
  
              nTotBook  += ACCTMAST->Principal
              nTotCred1 += ACCTMAST->CredAmt
  
              *****pepe 4:29 PM 9/21/2012
		      if !empty(ACCTMAST->refno2)
		         nrefno2  := ACCTMAST->refno2
		      endif
		      *****
			  
              ACCTMAST->(dbskip())
           enddo

		   *****pepe 4:29 PM 9/21/2012
			if lexceed
			   if nrefno2 == caheader->canumber
				  nTotBook  += nbook_prncpl
				  nTotCred1 += nbook_crdamt
				  
				  lexceed := .f.
			   endif
			endif
			
			if round(nTotBook,2) > caheader->prnline .and. round(nTotCred1,2) > caheader->caline 
			   nbook_prncpl := round(nTotBook - caheader->prnline,2)
			   nbook_crdamt := round(nTotCred1 - caheader->caline,2)
			   
			   nTotBook  := caheader->prnline
			   nTotCred1 := caheader->caline
			   
			   lexceed := .t.
			endif
		   *****
		   
           // pending accounts

           ACCTWAIT->(dbseek(if(Grpmembr->brcode != Grpmembr->brcode2,Grpmembr->brcode2+Grpmembr->clntcode,Grpmembr->brcode+Grpmembr->clntcode)))

           do while (ACCTWAIT->BRCODE+ACCTWAIT->ClntCode == grpmembr->BRCODE+GRPMEMBR->ClntCode) .and. ! ACCTWAIT->(eof())
              if ACCTMAST->status == '0'  // CANCELLED RLV 08/18/2010
                 ACCTMAST->(dbskip())
                 loop
              endif
		   
              if ACCTWAIT->RefNo != CAHEADER->CAnumber
                 ACCTWAIT->(dbskip())
                 loop
              endif
  
              if ACCTWAIT->DocRef != '1'    // check if account is CA
                 ACCTWAIT->(dbskip())
                 loop
              endif
  
              nTotPend  += ACCTWAIT->Principal
              nTotCred2 += ACCTWAIT->CredAmt
  
              ACCTWAIT->(dbskip())
           enddo

           GRPMEMBR->(dbskip())
        enddo

     else

        // get all booked accounts

        ACCTMAST->(dbseek(CAHEADER->BRCODE+CAHEADER->ClntCode))


        do while (ACCTMAST->BRCODE+ACCTMAST->ClntCode == CAHEADER->BRCODE+CAHEADER->ClntCode) .and. ! ACCTMAST->(eof())


			if ACCTMAST->status == '0'  // CANCELLED RLV 08/18/2010
				ACCTMAST->(dbskip())
				loop
			endif		
		
           if ACCTMAST->RefNo != CAHEADER->CAnumber
              ACCTMAST->(dbskip())
              loop
           endif
  
           if ACCTMAST->DocRef != '1'    // check if account is CA
              ACCTMAST->(dbskip())
              loop
           endif
  
           nTotBook  += ACCTMAST->Principal
           nTotCred1 += ACCTMAST->CredAmt
  
		   *****pepe 4:29 PM 9/21/2012
		   if !empty(ACCTMAST->refno2)
		      nrefno2  := ACCTMAST->refno2
		   endif
		   *****
		   
           ACCTMAST->(dbskip())
        enddo

		*****pepe 4:29 PM 9/21/2012
		if lexceed
		   if nrefno2 == caheader->canumber
              nTotBook  += nbook_prncpl
              nTotCred1 += nbook_crdamt
			  
			  lexceed := .f.
		   endif
		endif
		
        if round(nTotBook,2) > caheader->prnline .and. round(nTotCred1,2) > caheader->caline 
 	       nbook_prncpl := round(nTotBook - caheader->prnline,2)
		   nbook_crdamt := round(nTotCred1 - caheader->caline,2)
		   
           nTotBook  := caheader->prnline
           nTotCred1 := caheader->caline
		   
		   lexceed := .t.
		endif
		*****
		
        // pending accounts

        ACCTWAIT->(dbseek(CAHEADER->BRCODE+CAHEADER->ClntCode))

        do while (ACCTWAIT->BRCODE+ACCTWAIT->ClntCode == CAHEADER->BRCODE+CAHEADER->ClntCode) .and. ! ACCTWAIT->(eof())
            if ACCTMAST->status == '0'  // CANCELLED RLV 08/18/2010
                ACCTMAST->(dbskip())
                loop
            endif
		
           if ACCTWAIT->RefNo != CAHEADER->CAnumber
              ACCTWAIT->(dbskip())
             loop
           endif
  
           if ACCTWAIT->DocRef != '1'    // check if account is CA
              ACCTWAIT->(dbskip())
              loop
           endif
  
           nTotPend  += ACCTWAIT->Principal
           nTotCred2 += ACCTWAIT->CredAmt
  
           ACCTWAIT->(dbskip())
        enddo

     endif
        
     @ prow()+1, 10 say "Booked:"
     @ prow()  , 32 say nTotBook  picture '99,999,999,999.99'
     @ prow()  , 60 say nTotCred1 picture '99,999,999,999.99'

     @ prow()+1, 10 say "Pending:"
     @ prow()  , 32 say nTotPend  picture '99,999,999,999.99'
     @ prow()  , 60 say nTotCred2 picture '99,999,999,999.99'

     // show account's credit line
  
     @ prow()+1, 32 say replicate('Ä',17)
     @ prow()  , 60 say replicate('Ä',17)

     @ prow()+1, 10 say 'Credit Line:'
     @ prow()  , 32 say  CAHEADER->PrnLine picture '99,999,999,999.99'
     @ prow()  , 60 say  CAHEADER->CALine  picture '99,999,999,999.99'

     // show account's availed line

     nTotAvail   := nTotBook + nTotPend
     nCredAmount := nTotCred1 + nTotCred2

     @ prow()+1, 10 say 'Total Availed:'
     @ prow()  , 32 say nTotAvail   picture '99,999,999,999.99'
     @ prow()  , 60 say nCredAmount picture '99,999,999,999.99'

     @ prow()+1, 32 say replicate('Ä',17)
     @ prow()  , 60 say replicate('Ä',17)

     // show account's unavailed line
     // Unavailed = CA Line - Availed (Net Proceeds)
  
     @ prow()+1, 10 say 'Unavailed Line:'
     @ prow()  , 32 say CAHEADER->PrnLine - nTotAvail  picture '99,999,999,999.99'
     @ prow()  , 60 say CAHEADER->CALine - nCredAmount picture '99,999,999,999.99'

     @ prow()+1, 32 say replicate('Í',17)
     @ prow()  , 60 say replicate('Í',17)

     CAHEADER->(dbskip())
  enddo

////////// noels

  OTICKET->(dbseek( xCLNTCODE ))  && RED CLIENT->BRCODE+CLIENT->ClntCode ))
_seek   := .t.
cbrcode :='000' 
mmem    :='000'
  
  
  
  do while (OTICKET->BRCODE+OTICKET->ClntCode == xCLNTCODE) .and. ! OTICKET->(eof()) && RED CLIENT->BRCODE+CLIENT->ClntCode
     if OTICKET->AcTaken != '3'     // approved accounts only
        OTICKET->(dbskip())
        loop
     endif

     SETFONT('BOLD')
     @ prow()+2, 05 say 'OT#' + OTICKET->OTnumber
     SETFONT('UNBOLD')

     nTotBook  := 0
     nTotCred1 := 0
     nTotPend  := 0
     nTotCred2 := 0

     // get group number

     /*GRPMEMBR->(dbsetorder(1))             // client
     GRPMEMBR->(dbseek(xCLNTCODE))    && RED CLIENT->BRCODE+CLIENT->ClntCode))

     cGroupCode := iif( GRPMEMBR->BRCODE+GRPMEMBR->ClntCode == xCLNTCODE, GRPMEMBR->BRCODE+GRPMEMBR->GrupCode, "" )  && RED CLIENT->BRCODE+CLIENT->ClntCode

     GRPMEMBR->(dbsetorder(2))             // group
     GRPMEMBR->(dbseek(cGroupCode))*/
	 
	 GRPMEMBR->(dbsetorder(1))             // client 6:14 PM 2/26/2009 RLV
	 if Grpmembr->( dbseek( OTICKET->brcode+OTICKET->clntcode ) )
	   do while OTICKET->brcode+OTICKET->clntcode == GRPMEMBR->BRCODE+GRPMEMBR->CLNTCODE
			if OTICKET->brcode == GRPMEMBR->BRCODE2
			   mmem := Grpmembr->grupcode
				exit
			else
				GRPMEMBR->(dbskip(1))
			endif
		enddo  
	else
		Grpmembr->( ordsetfocus( 3 ) )
		if Grpmembr->( dbseek( OTICKET->brcode+OTICKET->clntcode ) )
			mmem := Grpmembr->grupcode
			_seek := .f.
			cbrcode := GRPMEMBR->BRCODE
		endif
	endif		

	Grpmembr->( ordsetfocus( 2 ) ) //group
	if _seek
		Grpmembr->( dbseek( OTICKET->brcode+mmem ) )
		cGroupCode :=GRPMEMBR->BRCODE+GRPMEMBR->GrupCode
	else
		Grpmembr->( dbseek( cbrcode+mmem ) )
		cGroupCode :=GRPMEMBR->BRCODE+GRPMEMBR->GrupCode
	endif	 
	 

     if !empty(cGroupCode)

        do while (GRPMEMBR->GrupCode == cGroupCode) .and. ! GRPMEMBR->(eof())
           // get all booked accounts

           ACCTMAST->(dbseek(GRPMEMBR->BRCODE+GRPMEMBR->ClntCode))

           do while (ACCTMAST->BRCODE+ACCTMAST->ClntCode == GRPMEMBR->BRCODE+GRPMEMBR->ClntCode) .and. ! ACCTMAST->(eof())
              if ACCTMAST->status == '0'  // CANCELLED RLV 08/18/2010
                 ACCTMAST->(dbskip())
                 loop
              endif
		   
              if ACCTMAST->RefNo != OTICKET->OTnumber       // OTICKET->CAnumber
                 ACCTMAST->(dbskip())                        // jbs 03.13.2002
                 loop
              endif

              if ACCTMAST->DocRef != '2'    // check if account is OT
                 ACCTMAST->(dbskip())
                 loop
              endif

              nTotBook  += ACCTMAST->Principal
              nTotCred1 += ACCTMAST->CredAmt

		      *****pepe 4:29 PM 9/21/2012
		      if !empty(ACCTMAST->refno2)
		         nrefno2  := ACCTMAST->refno2
		      endif
		      *****
		   
              ACCTMAST->(dbskip())
           enddo

		   *****pepe 4:29 PM 9/21/2012
		   if lexceed
		      if nrefno2 == oticket->otnumber
                 nTotBook  += nbook_prncpl
                 nTotCred1 += nbook_crdamt
			  
			     lexceed := .f.
		      endif
		   endif
		
           if round(nTotBook,2) > oticket->proceeds .and. round(nTotCred1,2) > oticket->credamt 
 	          nbook_prncpl := round(nTotBook - oticket->proceeds,2)
		      nbook_crdamt := round(nTotCred1 - oticket->credamt,2)
		   
              nTotBook  := oticket->proceeds
              nTotCred1 := oticket->credamt
		   
		      lexceed := .t.
		   endif
		   *****
		
           // pending accounts

           ACCTWAIT->(dbseek(GRPMEMBR->BRCODE+GRPMEMBR->ClntCode))

           do while (ACCTWAIT->BRCODE+ACCTWAIT->ClntCode == GRPMEMBR->BRCODE+GRPMEMBR->ClntCode) .and. ! ACCTWAIT->(eof())
              if ACCTWAIT->RefNo != OTICKET->OTnumber
                 ACCTWAIT->(dbskip())
                 loop
              endif

              if ACCTWAIT->DocRef != '2'    // check if account is OT
                 ACCTWAIT->(dbskip())
                 loop
              endif

              nTotPend  += ACCTWAIT->Principal
              nTotCred2 += ACCTWAIT->CredAmt

              ACCTWAIT->(dbskip())
           enddo

           GRPMEMBR->(dbskip())
        enddo

     else  // abb 08.09.2007

        ACCTMAST->(dbseek(Oticket->BRCODE+Oticket->ClntCode))

        do while (ACCTMAST->BRCODE+ACCTMAST->ClntCode == Oticket->BRCODE+Oticket->ClntCode) .and. ! ACCTMAST->(eof())
              if ACCTMAST->status == '0'  // CANCELLED RLV 08/18/2010
                 ACCTMAST->(dbskip())
                 loop
              endif
		
           if ACCTMAST->RefNo != OTICKET->OTnumber       // OTICKET->CAnumber
              ACCTMAST->(dbskip())                        // jbs 03.13.2002
              loop
           endif

           if ACCTMAST->DocRef != '2'    // check if account is OT
              ACCTMAST->(dbskip())
              loop
           endif

           nTotBook  += ACCTMAST->Principal
           nTotCred1 += ACCTMAST->CredAmt

		   *****pepe 4:29 PM 9/21/2012
		   if !empty(ACCTMAST->refno2)
		      nrefno2  := ACCTMAST->refno2
		   endif
		   *****
		   
           Acctmast->(dbskip(+1))

        enddo

		*****pepe 4:29 PM 9/21/2012
		if lexceed
		   if nrefno2 == oticket->otnumber
              nTotBook  += nbook_prncpl
              nTotCred1 += nbook_crdamt
		  
		     lexceed := .f.
		   endif
		endif
		
        if round(nTotBook,2) > oticket->proceeds .and. round(nTotCred1,2) > oticket->credamt 
 	       nbook_prncpl := round(nTotBook - oticket->proceeds,2)
		   nbook_crdamt := round(nTotCred1 - oticket->credamt,2)
		
           nTotBook  := oticket->proceeds
           nTotCred1 := oticket->credamt
		
		   lexceed := .t.
		endif
		*****
		   
        // pending accounts

/******************************
        ACCTWAIT->(dbseek(Oticket->BRCODE+Oticket->ClntCode))

        do while (ACCTWAIT->BRCODE+ACCTWAIT->ClntCode == Oticket->BRCODE+Oticket->ClntCode) .and. ! ACCTWAIT->(eof())

           if ACCTWAIT->RefNo != Oticket->OTNUMBER
              ACCTWAIT->(dbskip())
             loop
           endif
  
           if ACCTWAIT->DocRef != '2'    // check if account is CA
              ACCTWAIT->(dbskip())
              loop
           endif
  
           nTotPend  += ACCTWAIT->Principal
           nTotCred2 += ACCTWAIT->CredAmt
  
           ACCTWAIT->(dbskip())

        enddo
***************************/

     endif

     @ prow()+1, 10 say "Booked:"
     @ prow()  , 32 say nTotBook  picture '99,999,999,999.99'
     @ prow()  , 60 say nTotCred1 picture '99,999,999,999.99'

     @ prow()+1, 10 say "Pending:"
     @ prow()  , 32 say nTotPend  picture '99,999,999,999.99'
     @ prow()  , 60 say nTotCred2 picture '99,999,999,999.99'

     // show account's credit line
  
     @ prow()+1, 32 say replicate('Ä',17)
     @ prow()  , 60 say replicate('Ä',17)

     @ prow()+1, 10 say 'Credit Line:'
     @ prow()  , 32 say OTICKET->Proceeds picture '99,999,999,999.99'
     @ prow()  , 60 say OTICKET->CredAmt  picture '99,999,999,999.99'

     // show account's availed line

     nTotAvail   := nTotBook + nTotPend
     nCredAmount := nTotCred1 + nTotCred2

     @ prow()+1, 10 say 'Total Availed:'
     @ prow()  , 32 say nTotAvail   picture '99,999,999,999.99'
     @ prow()  , 60 say nCredAmount picture '99,999,999,999.99'

     @ prow()+1, 32 say replicate('Ä',17)
     @ prow()  , 60 say replicate('Ä',17)

     // show account's unavailed line
     // Unavailed = CA Line - Availed (Net Proceeds)
  
     @ prow()+1, 10 say 'Unavailed Line:'
     @ prow()  , 32 say OTICKET->Proceeds - nTotAvail  picture '99,999,999,999.99'
     @ prow()  , 60 say OTICKET->CredAmt - nCredAmount picture '99,999,999,999.99'

     @ prow()+1, 32 say replicate('Í',17)
     @ prow()  , 60 say replicate('Í',17)

     OTICKET->(dbskip())
  enddo

  @ prow()+1, 00 say ""

  __eject()

return (.t.)

/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////

static function _heading()

   SETFONT('NORMAL')
   SETFONT('ELITE')

   *@ prow()+1,05       say "(" + left(Client->clntcode,2) + "-" + substr(Client->clntcode,3) + ")"
   @ prow()+1,05       say "(" + TRAN(CLIENT->BRCODE+Client->clntcode,'@R 999-99-99999') + ")"

   SETFONT('BOLD')
   @ prow()  ,pcol()+1 say Client->fullname
   SETFONT('UNBOLD')

   @ prow()+1,05       say "Unavailed Line as of "

   SETFONT('BOLD')
   @ prow(),  pcol()+1 say alltrim(cmonth(date())) + ' ' + alltrim(str(day(date()))) + ', ' + alltrim(str(year(date())))
   SETFONT('UNBOLD')

   @ prow()+1, 04 say replicate('Ä',87)
   @ prow()+1, 05 say "CA/OT No."
   @ prow()  , 25 say "Purchase Amount / Net Proceeds"
   @ prow()  , 65 say "Credit Amount"
   @ prow()+1, 04 say replicate('Ä',87)

   // noels
   // @ prow()+1,04 say '       CA/OT    Account         Net               Credit           Value       Avail.'
   // @ prow()+1,04 say '        No.       No.         Proceeds            Amount           Date        Date  '
   // @ prow()+1,04 say replicate('Ä',87)

   ///////     ' Booked CA Accounts'
   ///////     '  CA#xxxxx  xxxxx  99,999,999,999.99  99,999,999,999.99  03/20/2001  08/19/2001

return nil

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function fDisp0110( old_code )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local row := 1,prntname:= .f.
   memva total_princ, total_amort, total_creda, total_osbal
   memva grand_princ, grand_amort, grand_creda, grand_osbal
   memva sw, cnt, ind, inc, on, ac_code, _x

   if alltrim( ac_code ) == Alltrim( old_code )
      prntname:= .f.
      clcnt++
   else
      if ( total_princ + total_amort + total_creda + total_osbal ) > 0 .and. clcnt > 1
         fSubt0110()
         fEjec0110()
      ENDIF
      clcnt:= 1
      old_code := ac_code
      prntname := .t.
   endif

   total_princ += Acctmast->principal
   total_amort += Acctmast->amort
   total_creda += Acctmast->credamt
   total_osbal += Acctmast->osbal
   grand_princ += Acctmast->principal
   grand_amort += Acctmast->amort
   grand_creda += Acctmast->credamt
   grand_osbal += Acctmast->osbal

   /*
   if sw == -1
      set device to screen
      scroll( 8, 18, 9, 31, 1 )
      @ 9, 18 say padr( ac_code, 14 ) color 'w+/rb'
      set device to printer
      sw := on := 1   
   endif   
   */
   fEjec0110()
   if Acctmast->Status != '1'
     if _x == -1
        @ prow() + row , 10 say '*'
     else
        @ prow() + row ,  7 say '*'
     endif
     row:=row-1
   endif
   if _x == -1
      @ prow() + row,  5  say       ACCTMAST->BRCODE+substr(Acctmast->acctno,-5,5) PICT '@R 999-99999'
      @ prow()      ,  12 say       Acctmast->oldno
      @ prow()      ,  29 say       Acctmast->unit           picture '@!'
      @ prow()      ,  70 say       Acctmast->principal      picture '999,999,999.99'
      @ prow()      ,  85 say       Acctmast->gd             picture '99.99'
      @ prow()      ,  92 say       Acctmast->rv             picture '99.99'
      @ prow()      ,  98 say       Acctmast->term           picture '999'
      @ prow()      , 102 say       if(ALLTRIM(Acctmast->Termunit) == '2','m','d' )
      @ prow()      , 104 say       if(ALLTRIM(Acctmast->Termunit) == '2',Acctmast->remterm,0 )   picture '@Z 999'
      @ prow()      , 108 say       if(ALLTRIM(Acctmast->Termunit) == '2','m',' ')
      @ prow()      , 111 say       Acctmast->truerate       picture '99.99'
      @ prow()      , 117 say       Acctmast->amort          picture '999,999,999.99'
      @ prow()      , 135 say       Acctmast->credamt        picture '999,999,999.99'
      @ prow()      , 153 say       Acctmast->osbal          picture '999,999,999.99'
      @ prow()      , 168 say       Acctmast->Valdate        picture '@D'
   else
      @ prow() + row,   9 say       Acctmast->oldno
      if prntname  .or. nwpage
         @ prow()      ,  26 say  padr( Acctmast->acctname,40 )
         nwpage := .f.
      else
         @ prow()      ,  26 say  padr( ' ',40 )
      endif
      @ prow()      ,  67 say       Acctmast->unit           picture '@!'
      @ prow()      , 108 say       Acctmast->principal      picture '99,999,999,999.99'
      @ prow()      , 127 say       Acctmast->gd             picture '99.99'
      @ prow()      , 133 say       Acctmast->rv             picture '99.99'
      @ prow()      , 139 say       Acctmast->term           picture '999'
      @ prow()      , 142 say ' months'
      @ prow()      , 150 say       Acctmast->remterm        picture '999'
      @ prow()      , 153 say ' months'
      @ prow()      , 161 say       Acctmast->truerate       picture '99.99'
      @ prow()      , 167 say       Acctmast->amort          picture '999,999,999.99'
      @ prow()      , 186 say       Acctmast->credamt        picture '99,999,999,999.99'
      @ prow()      , 205 say       Acctmast->osbal          picture '99,999,999,999.99'
   endif
   /*
   set device to screen
   @ 17,  3 say tran( grand_amort,         '999,999,999.99' ) color 'w+/rb'
   scroll( 11, 18, 12, 31, 1 )
   @ 12, 18 say padr( Acctmast->unit, 14 )                    color 'w+/rb' 
   scroll( 14, 18, 15, 31, 1 )
   @ 15, 18 say tran( Acctmast->principal, '999,999,999.99' ) color 'w+/rb' 
   scroll( 17, 18, 18, 31, 1 )
   @ 18, 18 say tran( Acctmast->amort,     '999,999,999.99' ) color 'w+/rb'
   @ 18, 18 say tran( Acctmast->amort,     '999,999,999.99' ) color 'w+/rb'
   @  9 + ind, 33 say '°'                                     color 'w+/n'
          ind := int( max( ( ( inc += 1 ) / cnt ) * 7, 1 ) )
   @  9 + ind, 33 say 'Û'                                     color 'w+/w'

   set device to printer
   */
   return( nil )

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function fSubt0110()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

   memva total_princ, total_amort, total_creda, total_osbal

   fEjec0110()
   @ prow() + 1, 108 say replicate( 'Ä', 18 )
   @ prow()    , 167 say replicate( 'Ä', 18 )
   @ prow()    , 186 say replicate( 'Ä', 18 )
   @ prow()    , 205 say replicate( 'Ä', 18 )
   fEjec0110()
   @ prow() + 1,  91 say '  Sub-Total ¯'
   @ prow()    , 108 say total_princ picture '99,999,999,999.99'
   @ prow()    , 167 say total_amort picture '99,999,999,999.99'
   @ prow()    , 186 say total_creda picture '99,999,999,999.99'
   @ prow()    , 205 say total_osbal picture '99,999,999,999.99'

   @ prow() + 1, 108 say replicate( 'Ä', 18 )
   @ prow()    , 167 say replicate( 'Ä', 18 )
   @ prow()    , 186 say replicate( 'Ä', 18 )
   @ prow()    , 205 say replicate( 'Ä', 18 )   
   total_princ := total_amort := total_creda := total_osbal := 0

   return( nil )

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function fHead0110()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   memvar mpage, gSYS_NAME, gCOMPANY, nwpage

   if _x == -1
     setfont( upper( 'init' ) )
     prnreptitle( 102, 5, mpage++, 'ACCOUNTS MASTERLIST', 'AMSQ0110', gSYS_NAME, gCOMPANY )
     setfont( upper( 'uncondensd' ) )
     @ prow() + 1, ( 102 - 16 ) / 2 say 'As of ' + dtoc( Flag->prevdate )
     setfont( upper( 'condensed' ) )
     @ prow()+1,1 say '   ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿'
     @ prow()+1,1 say '   ³ New  ³      Old       ³                                        ³              ³     ³     ³ Orig ³ Rem  ³ True³   Monthly    ³      Credit     ³    Outstanding  ³Execution³'
     @ prow()+1,1 say '   ³Acctno³   Account N§   ³               Collateral               ³   Proceeds   ³ G D ³ R V ³ Term ³ Term ³ Rate³ Amortization ³      Amount     ³      Balance    ³   Date  ³'
     @ prow()+1,1 say '   ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÙ'
     @ prow()+1,1 say ' '                                                                                                                                                                     
     @ prow()+1,5 say ac_name
     @ prow()+1,1 say ' '
   else
     setfont( upper( 'init' ) )
     prnreptitle( 136, 5, mpage++, 'ACCOUNTS MASTERLIST', 'AMSQ0110', gSYS_NAME, gCOMPANY )
     setfont( upper( 'uncondensd' ) )
     @ prow() + 1, ( 136 - 16 ) / 2 say 'As of ' + dtoc( Flag->prevdate )
     setfont( upper( 'condensed' ) )
     @ prow() + 1, 8 say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿'
     @ prow() + 1, 8 say '³                ³                                        ³                                        ³                  ³     ³     ³ Original ³Remaining ³True ³     Monthly      ³      Credit      ³   Outstanding    ³Execution³'
     @ prow() + 1, 8 say '³   Account N§   ³              Account Name              ³               Collateral               ³     Proceeds     ³ G D ³ R V ³   Term   ³   Term   ³ Rate³   Amortization   ³      Amount      ³     Balance      ³  Date   ³'
     @ prow() + 1, 8 say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÙ'
     nwpage := .t.
   endif
   return( nil )

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function fEjec0110()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   memvar _x
   if _x == -1
     if prow() >= 42
        __eject()
        fHead0110()
     endif
   else
     if prow() >= 50
        __eject()
        fHead0110()
     endif
   endif
   return( .t. )

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function fDate0110()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local getlist := {}, mcd := space( 7 )
   local mcl := setcolor(), log := !.f.
   memva gnam, _x    &&, xClntcode

   xClntcode := space(10)

   Acctmast->(dbsetorder(1))
   CLIENT->(DBSETORDER(2))
   setcolor( 'n/bg, w+/n,,, gr+/bg' )
   fShadow( 13, 15, 15, 51, 2, 'n/w' )
   @ 14, 16 say 'Client Code  ' get xCLNTCODE PICT '@R 999-99-99999';
                                 VALID IF( !EMPTY(RIGHT(xCLNTCODE,7)) .AND. LASTKEY() == K_ENTER,;
                                           IF( VALBRCODE(LEFT(xCLNTCODE,3),g_USER_ID),;
                                               IF( fPAD0110(@xCLNTCODE), .T., EVAL({|| xCLNTCODE := SPACE(10), .F.}) ),;
                                               EVAL({|| xCLNTCODE := SPACE(10), .F. });
                                             ),;
                                           EVAL({|| xCLNTCODE:= EVAL({ || ach_look() }),;
                                                    IF( LASTKEY() == K_ENTER,;
                                                        IF( VALBRCODE(LEFT(xCLNTCODE,3),g_USER_ID), .T., EVAL({|| xCLNTCODE:=SPACE(10), .F.}) ),;
                                                        EVAL({|| xCLNTCODE:=SPACE(10), .F.});
                                                      );
                                               });
                                         )
   /*
            picture '@!S07' ;
            when pseek( @mcd ) ;
            valid fPad0110( @mcd )
   */
   setcursor( 3 )
   setkey( K_ESC, { || fEscape( 'Abort?' ) } )
   read &&timeout 20 exitevent blankscr3( -1 )
   setkey( K_ESC, nil )
   setcursor( 0 )

   CLIENT->(DBSETORDER(1))

   if lastkey() != K_ESC
      ********** xClntcode:=Acctmast->Clntcode
      *xClntcode := Client->Clntcode
      log  := !.t.
      gnam := { || xClntcode }
   endif

   inkey( .5 )
   setcolor( mcl )
   return( log )
   
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
   

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function pseek( mcd )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   acctmast->(dbsetorder(1))
*****   return( eval( { || lb_lkup( 'Acctmast', 1, 1, @mcd, 3, 2, 10, 36, 20, 75, 'W/GR+,W/N,,,W/GR+',,, 3 ), .t. } ) )
return eval ({|| lb_lkup( 'Client'  , 1, 2, @mcd, 3, 1, 8,  8,  21, 75, 'W/GR+,W/N,,,W/GR+'),.t. })

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function fPad0110( mcd )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local result := .t., nntx := Client->(indexord()),nrecno := Client->(recno())

   Client->(dbsetorder(1))            //   clntcode

   *mcd := padl(alltrim(mcd),7,"0")     && RED

   if ! Client->(dbseek( mcd ))
      result := .f.
      error ( 'Record not found in Client Master!' )
      Client->(dbgoto(nrecno))
   endif

   Client->(dbsetorder(nntx))

return result

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function fDraw0110()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   setcolor( 'n/gr, +w/gr' )
*****   fShadow( 9, 33, 14, 42, 2, 'n/w' )
   fShadow( 9, 33, 12, 42, 2, 'n/w' )
   @ 10, 40 say 'ß'                     color 'w/n'
   @ 11, 36 say 'ÜÜÜÜÜ'                 color 'w/n'

*****   @ 12, 40 say 'ß'                     color 'w/n'
*****   @ 13, 36 say 'ÜÜÜÜÜ'                 color 'w/n'

   /*
   @  9, 32 say 'Â'                     color 'n/w'
    
   @ 10, 32 say '³'                     color 'n/w'
   @ 10, 34 say 'Select and write the'  color 'n+/w'
    
   @ 11, 32 say '³'                     color 'n/w' 
   @ 11, 34 say '             you want' color 'n+/w'
   @ 11, 34 say 'Account Name'          color 'w+/w'
    
   @ 12, 32 say '³'                     color 'n/w' 
   @ 12, 34 say 'to be printed in the'  color 'n+/w'
    
   @ 13, 32 say '³'                     color 'n/w' 
   @ 13, 34 say 'Accounts Masterlist'   color 'w+/w'
   @ 13, 53 say '.'                     color 'n+/w'  
   @ 14, 32 say 'Á'                     color 'n/w'
   */
   return( .f. )

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function fOutp0110()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   inkey( .5 )
   dispbegin()
   fShadow(  7,  1, 19, 34, 2,   'n/w'  )
   dispbox(  8, 17, 18, 17, '³', 'n/w'  )
   dispbox(  8, 32, 18, 32, '³', 'n/w'  )
   dispbox( 10, 33, 16, 33, '°', 'w+/n' ) 
   dispbox( 10,  2, 10, 31, 'Ä', 'n/w'  )
   dispbox( 13,  2, 13, 31, 'Ä', 'n/w'  )
   dispbox( 16,  2, 16, 31, 'Ä', 'n/w'  )
   @  7, 17 say 'Â'             color 'n/w'
   @  7, 32 say 'Â'             color 'n/w'
   @  8, 33 say chr( 24 )       color 'w+/w'
   @  9, 32 say 'ÃÄ´'           color 'n/w' 
   @ 10,  1 say 'Ã'             color 'n/w'
   @ 10, 17 say 'Å'             color 'n/w'
   @ 10, 32 say '´'             color 'n/w' 
   @ 13,  1 say 'Ã'             color 'n/w'
   @ 13, 17 say 'Å'             color 'n/w'
   @ 13, 32 say '´'             color 'n/w' 
   @ 16,  1 say 'Ã'             color 'n/w'
   @ 16, 17 say 'Å'             color 'n/w'
   @ 16, 32 say '´'             color 'n/w' 
   @ 17, 32 say 'ÃÄ´'           color 'n/w' 
   @ 18, 33 say chr( 25 )       color 'w+/w'  
   @ 19, 17 say 'Á'             color 'n/w'
   @ 19, 32 say 'Á'             color 'n/w'
   @  9,  4 say ' Account Name' color 'gr+/w'
   @ 12,  4 say '   Collateral' color 'gr+/w'
   @ 15,  4 say '    Principal' color 'gr+/w'
   @ 18,  4 say ' Amortization' color 'gr+/w'
   dispend()
   return( nil )


**  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    static function fopen0110()
**  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

   if !netuse('&g_AMS_PATH\caheader',.f.,5)
      return .f.
   else
      if !.f.; ordlistclear(); endif
      // set index  to caheader,carev,caclnt

      set index to &g_AMS_PATH\caclnt    // ClntCode
   endif

  //   if !netuse('  cadetail',.f.,5)
  //      return .f.
  //   else
  //      if !.f.; ordlistclear(); endif
  //      set index  to cadetail,cadetcfl
  //   endif

   if !netuse('&g_AMS_PATH\oticket',.f.,5)
     return .f.
   else
     if !.f.; ordlistclear(); endif
     set index to &g_AMS_PATH\otclnt     // ClntCode
   endif

   if !netuse('&g_AMS_PATH\Flag', .f., 10 )               && flag
      return .f.
   endif

   if !netuse('&g_AMS_PATH\Acctwait',.f.,5)
     return .f.
   else
     // set index to acctwait, acctwsub, acctrecl, acctwclt, acctref1, acctref2
     // Acctwait->(dbsetorder(3))      // refno+clntcode

     set index to &g_AMS_PATH\acctwclt   // clntcode
   endif

   if !netuse('&g_cis_path'+'\client.dbf',.f.,5)
      return .f.
   else
      set index to &g_cis_path\cliecd, &g_cis_path\clienm,  &g_cis_path\cliebf
   endif

   if !netuse('&g_AMS_PATH\Acctdaly',.f.,5)
      return .f.
   else
      set index to &g_AMS_PATH\acctdaly, &g_AMS_PATH\accdclnt, &g_AMS_PATH\accdsub1, &g_AMS_PATH\accfclty, &g_AMS_PATH\accdname
      set order to 2           ///  clntcode
   endif

   if !netuse('&g_AMS_PATH\GrpMembr',.f.,5)
      return .f.
   else
      set index to &g_AMS_PATH\GrpClnt, &g_AMS_PATH\GrpMembr, &g_AMS_PATH\GRPCLNT2, &g_AMS_PATH\GRPMEMB2
   endif

   if !netuse( '&g_AMS_PATH\Acctmast', .f., 10 )
      return .f.
   else
      if !.f.; ordlistclear(); endif
      // set index to Acctacno, Acctclnt,Acctmast
      // Acctmast->(dbsetorder(3))

      // noels
      set index to &g_AMS_PATH\AcctClnt     // clntcode + acctno
   endif

return .t.

/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/*
static function UniqFile( cFileExt )
  local mfiname, mrandnum

  do while .t.

    mrandnum := substr(time(),1,2) + substr(time(),4,2) + substr(time(),7,2)

    mfiname  := 'TF' + mrandnum

    if file(mfiname + '.' + cFileExt)          // test if file exist
      loop
    else
      exit
    endif

  enddo
return mfiname
*/

/**************************************************************************

   Caheader->(dbseek(Client->clntcode))
   do while Caheader->clntcode == Client->clntcode .and. !Caheader->(eof())
      crefno   := 'CA'+Caheader->canumber
      _process_details ( '1',crefno,nnetproc,ncredamt )
      Caheader->( dbskip(+1) )
   enddo

   if Oticket->(dbseek(Client->clntcode))
      do while Oticket->clntcode == Client->clntcode .and. !Oticket->(eof())
         crefno   := 'OT'+Oticket->otnumber
         _process_details('2',crefno,nnetproc,ncredamt )
         Oticket->(dbskip(+1))
      enddo
   endif

***************************************************************************/


/***************************************************************************

static function _process_details ( cdbf,crefno,nnetproc,ncredamt )
   local cacctno,dvaldate,cremarks

   if cdbf == '1'          // CAHEADER.DBF

      if Caheader->actaken == '3'      // not equal to closed .and. APPROVED

         if Acctwait->(dbseek(Caheader->canumber+Caheader->clntcode))

            cacctno  := substr(Acctwait->acctno,-5,5)
            nnetproc := Acctwait->principal
            ncredamt := Acctwait->credamt

//            if Acctdaly->(dbseek(Acctwait->clntcode+Acctwait->acctno))
            if Acctmast->(dbseek(Acctwait->clntcode+Acctwait->acctno))
               dvaldate := Acctmast->valdate
               cremarks := 'BOOKED'
            else
               cremarks := 'PENDING'
               dvaldate := Acctwait->valdate
            endif

            @ prow()+1, 01       say crefno
            @ prow()  , pcol()+3 say cacctno
            @ prow()  , pcol()+3 say trans(nnetproc,"99,999,999,999.99")
            @ prow()  , pcol()+3 say trans(ncredamt,"99,999,999,999.99")

            if cremarks == 'BOOKED'
               @ prow()  , pcol()+6  say trans(dvaldate,"@D")
               @ prow()  , pcol()+17 say cremarks
            else
               @ prow()  , pcol()+20 say trans(dvaldate,"@D")
               @ prow()  , pcol()+3 say cremarks
            endif

         endif
      endif

   else            // OTICKET.DBF

      if Oticket->actaken == '3'      // not equal to closed .and. APPROVED

         if Acctwait->(dbseek(Oticket->OTnumber+Oticket->clntcode))

            cacctno  := substr(Acctwait->acctno,-5,5)
            nnetproc := Acctwait->principal
            ncredamt := Acctwait->credamt

            if Acctmast->(dbseek(Acctwait->clntcode+Acctwait->acctno))
               dvaldate := Acctmast->valdate
               cremarks := 'BOOKED'
            else
               cremarks := 'PENDING'
               dvaldate := Acctwait->valdate
            endif

            @ prow()+1, 01       say crefno
            @ prow()  , pcol()+3 say cacctno
            @ prow()  , pcol()+3 say trans(nnetproc,"99,999,999,999.99")
            @ prow()  , pcol()+3 say trans(ncredamt,"99,999,999,999.99")

            if cremarks == 'BOOKED'
               @ prow()  , pcol()+6  say trans(dvaldate,"@D")
               @ prow()  , pcol()+17 say cremarks
            else
               @ prow()  , pcol()+20 say trans(dvaldate,"@D")
               @ prow()  , pcol()+3 say cremarks
            endif

         endif
      endif

   endif
return nil

***************************************************************************/

// eop: amsq0600.prg
