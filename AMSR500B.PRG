/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   colf-iis -- account management system                                      ³
³   program idúúú amsr3000                                                     ³
³   descriptionúú Accts. with running out PDC's                                ³
³   authorúúúúúúú ariel b. bulan                                               ³
³   dateúúúúúúúúú 9:45:am úú 12-26-2001                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                             u p d a t e s                                    ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        who        ³       when        ³               why                    ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                   ³                   ³                                      ³
³   abb             ³  01.09.2002       ³   added lastpayment date             ³
³   abb             ³  03.22.2002       ³   sort by deposit date+account       ³
³                   ³                   ³        name ( added to temp file)    ³
³   aga             ³  14.02.2007       ³   removed paysked reference function ³
³   fom             ³  04.21.2010       ³   Delete LA Number Column            ³
³   mts             ³  07.14.2011       ³   Added PDCDTBCK database            ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include 'inkey.ch'
#include 'colf.ch'
#include 'dbstruct.ch'

#define K_SPACEBAR   32
#define microfeed    chr( 27 ) + 'J' + chr( 18 )

memvar  AX_LEVEL, gUSER_ID

private cTempPDCfile, cTempIndex

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

**********************************
*
Static Function aOpen9999()
**********************************
  local aTempStruc := { { 'AcctNo'  ,'C',14,00 } ,;
                        { 'AcctName','C',50,00 } ,;
                        { 'Bank'    ,'C',25,00 } ,;
                        { 'ChkNo'   ,'C',12,00 } ,;
                        { 'ChkAmt'  ,'N',12,02 } ,;
                        { 'Amort'   ,'N',12,02 } ,;
                        { 'Osbal'   ,'N',12,02 } ,;
                        { 'Valdate' ,'D',08,02 } ,;
                        { 'Depdate' ,'D',08,02 } ,;
                        { 'Matdate' ,'D',08,02 } ,;
						{ 'status'  ,'C',01,00 } ,;
                        { 'BRCODE'  ,'C',03,00 }  ;
                      }
					  
	//chi 042110 removed { 'Oldno'   ,'C',20,00 } ,; 
  
  if !netuse( '&g_AMS_PATH\Acctmast', .f., 10 )              && Account master file
     break
  else
     if !.f.; ordlistclear(); endif
     ordlistadd( '&g_AMS_PATH\Acctacno' )                    && set index on acctname
  endif

  if !netuse( '&g_AMS_PATH\Paysked',.f.,5)
     break
  else
     if !.f.; ordlistclear(); endif
     ordlistadd( '&g_AMS_PATH\Paysked' )
  endif

  if !netuse( '&g_AMS_PATH\Payimage',.f.,5)
     break
  else
     if !.f.; ordlistclear(); endif
     ordlistadd ( '&g_AMS_PATH\Payimage' )
     ordlistadd ( '&g_AMS_PATH\Paysub1' )
  endif

  if !netuse( '&g_AMS_PATH\Pdc_dtls', .f., 10 )              && Payment Schedule file
     break
  else
     if !.f.; ordlistclear(); endif
     ordlistadd( '&g_AMS_PATH\Pdc_dtls' )                     && set index account number
  endif

  if !netuse( '&g_AMS_PATH\AMSBACK\PDCDTBCK', .f., 10 )              && Payment Schedule file
     break
  else
     if !.f.; ordlistclear(); endif
     ordlistadd( '&g_AMS_PATH\AMSBACK\PBK_DTLS' )                     && set index account number
  endif
  
  //create a unique temporary file

  cTempPDCfile := UniqFile('DBF')
  cTempIndex := UniqFile('NTX')

  IF TRUE_BRCH == '001'
  *-----------------------------
     dbcreate( (cTempPDCfile), aTempStruc )

     if valtype(cTempPDCfile) != 'U'
       if ( netuse((cTempPDCfile), .t., 0) )    // open temp file exclusively

         // create new index file

         *cTempIndex := UniqFile('NTX')   &&RED 121304 MOVED UP
         dbcreateindex( cTempIndex, 'dtos(depdate)+AcctName+BRCODE+acctno', { || dtos(depdate)+AcctName+BRCODE+acctno }, .f. )

         set index to (ctempPdcfile)->(ctempindex)
         (ctempPdcfile)->(dbsetorder(1))        // account name

       else
         alert('Unable to open file.')
       endif
     else
       alert('Unable to create file.')
     endif
  *----------------------------------
  ENDIF
return nil

/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

****************************
*
static function amain9999()
****************************
  local mu:=savedbf(),re:=setcursor(),bf:=savescreen(,,,),gf:=setcolor()
  LOCAL xSTR
  private ddate:=mtrandate
  setkey(K_ESC, nil)
  setcolor('n/w,w/n,,,w+/w')
  setcursor(1)

  fshadow(17,18,19,55,2,'n/w')
  @ 18,20 say 'PDC Date to Print    ' get ddate pict '@D' valid !empty(ddate) // .and. chkpdcdate(ddate)

  setkey(K_ESC ,{ || fescape( 'Abort?' ) } )
  read
  setkey(K_ESC, nil)

  if lastkey() != K_ESC        // confirm ( 'Proceed?')
     ddate := MonthPlusOne ( ddate )        // noels
     xSTR := CHK_PAR(dDATE)+CHK_PAR(cTempPDCfile)+CHK_PAR(cTempIndex)
     REPCON_OL   ( '_PDC09999()',,,,,,xSTR,.T. )
  endif

  restdbf(mu);restscreen(,,,,bf);setcursor(re);setcolor(gf)
return nil

**********************
*
function _pdc09999()
**********************
  local mu:=savedbf(),re:=setcursor(),bf:=savescreen(,,,),gf:=setcolor()
  local pgn:=1,chkcnt:=0,tot_amount:=0, astatus := {'Active','Past Due','In Litigation','Repossesed','Written-Off'}
  local xdate:=cmonth(ddate) + ' ' + str(day(ddate),2) +', '+str(year(ddate),4)

  Head_9999( pgn,xdate)

  Acctmast->(dbgotop())
  do while !Acctmast->(eof())
     IF ACCTMAST->BRCODE == g_PAR_BRCH

        if Acctmast->paymode <> '1'            // not equal to PDC
           Acctmast->(dbskip(+1))
           loop
        endif

        if Acctmast->osbal <= 0                // may balanse pa ba?
           Acctmast->(dbskip(+1))
           loop
        endif


        if PDCDTBCK->(dbseek(ACCTMAST->BRCODE+Acctmast->acctno))

           ncount := 0
           do while PDCDTBCK->BRCODE+PDCDTBCK->acctno == ACCTMAST->BRCODE+Acctmast->acctno .and. !PDCDTBCK->(eof())


             if PDCDTBCK->depdate <= ddate    // PDCDTBCK->Status <> '1'
                PDCDTBCK->(dbskip(+1))        // abb 05.09.2001 ( infinite loop )
                loop
             endif

             ncount++
             PDCDTBCK->(dbskip(+1))

           enddo
		   
           if ncount <= 0

              (ctempPdcfile)->(dbappend())

                 if substr(Acctmast->acctno,5,3) == '103'
                    (ctempPdcfile)->acctno := Acctmast->acctno
                    (ctempPdcfile)->BRCODE := Acctmast->BRCODE
                 else
                    (ctempPdcfile)->acctno := Acctmast->acctno
                    (ctempPdcfile)->BRCODE := Acctmast->BRCODE
                 endif


              (ctempPdcfile)->acctname := Acctmast->acctname
              (ctempPdcfile)->valdate  := Acctmast->valdate
              (ctempPdcfile)->matdate  := Acctmast->matdate
              (ctempPdcfile)->amort    := Acctmast->amort
              (ctempPdcfile)->osbal    := Acctmast->osbal
			  (ctempPdcfile)->status   := Acctmast->status
              (ctempPdcfile)->depdate  := _prn_check()

              (ctempPdcfile)->(dbcommit())


           endif
		endif

        if Pdc_dtls->(dbseek(ACCTMAST->BRCODE+Acctmast->acctno))

           ncount := 0
           do while PDC_DTLS->BRCODE+Pdc_dtls->acctno == ACCTMAST->BRCODE+Acctmast->acctno .and. !Pdc_dtls->(eof())


             if Pdc_dtls->depdate <= ddate    // Pdc_dtls->Status <> '1'
                Pdc_dtls->(dbskip(+1))       // abb 05.09.2001 ( infinite loop )
                loop
             endif

             ncount++
             Pdc_dtls->(dbskip(+1))

           enddo

           if ncount <= 0

              (ctempPdcfile)->(dbappend())
/*chi042110
              if !empty(Acctmast->oldno)
   ***              @ prow()+1,00 say padr( trans(Acctmast->oldno,'@!'),20 )
                 (ctempPdcfile)->oldno  := Acctmast->oldno
                 (ctempPdcfile)->BRCODE := Acctmast->BRCODE
              else
*/
                 if substr(Acctmast->acctno,5,3) == '103'
   ***                 @ prow()+1,00 say padr( 'L-'+right( Acctmast->acctno,5),20)
                    (ctempPdcfile)->acctno := Acctmast->acctno
                    (ctempPdcfile)->BRCODE := Acctmast->BRCODE
                 else
   ***                 @ prow()+1,00 say padr('M-'+right( Acctmast->acctno,5),20)
                    (ctempPdcfile)->acctno := Acctmast->acctno
                    (ctempPdcfile)->BRCODE := Acctmast->BRCODE
                 endif

 //chi042110   endif

  /*chi042110            if substr(Acctmast->acctno,5,3) == '103'
   ***              @ prow()  ,pcol()+2 say 'L-'+right( Acctmast->acctno,5)
                 (ctempPdcfile)->acctno := Acctmast->acctno
                 (ctempPdcfile)->BRCODE := Acctmast->BRCODE
              else
   ***              @ prow()  ,pcol()+2 say 'M-'+right( Acctmast->acctno,5)
                 (ctempPdcfile)->acctno := Acctmast->acctno
                 (ctempPdcfile)->BRCODE := Acctmast->BRCODE
              endif
*/


              (ctempPdcfile)->acctname := Acctmast->acctname
              (ctempPdcfile)->valdate  := Acctmast->valdate
              (ctempPdcfile)->matdate  := Acctmast->matdate
              (ctempPdcfile)->amort    := Acctmast->amort
              (ctempPdcfile)->osbal    := Acctmast->osbal
			  (ctempPdcfile)->status   := Acctmast->status
              (ctempPdcfile)->depdate  := _prn_check()

              (ctempPdcfile)->(dbcommit())


           endif

        else     // NOT FOUND IN PDC_DTLS

           (ctempPdcfile)->(dbappend())
/*chi042110
           if !empty(Acctmast->oldno)
   ***           @ prow()+1,00 say padr( trans(Acctmast->oldno,'@!'),20 )
                 (ctempPdcfile)->oldno  := Acctmast->oldno
                 (ctempPdcfile)->BRCODE := Acctmast->BRCODE
           else
*/
              if substr(Acctmast->acctno,5,3) == '103'
   ***              @ prow()+1,00 say padr( 'L-'+right( Acctmast->acctno,5),20)
                 (ctempPdcfile)->acctno := Acctmast->acctno
                 (ctempPdcfile)->BRCODE := Acctmast->BRCODE
              else
   ***              @ prow()+1,00 say padr('M-'+right( Acctmast->acctno ,5),20)
                 (ctempPdcfile)->acctno := Acctmast->acctno
                 (ctempPdcfile)->BRCODE := Acctmast->BRCODE
              endif

//chi042110           endif
/*chi042110
           if substr(Acctmast->acctno,5,3) == '103'
   ***           @ prow()  ,pcol()+2 say 'L-'+right( Acctmast->acctno,5)
              (ctempPdcfile)->acctno := Acctmast->acctno
              (ctempPdcfile)->BRCODE := Acctmast->BRCODE
           else
   ***           @ prow()  ,pcol()+2 say 'M-'+right( Acctmast->acctno,5)
              (ctempPdcfile)->acctno := Acctmast->acctno
              (ctempPdcfile)->BRCODE := Acctmast->BRCODE
           endif
*/

           (ctempPdcfile)->acctname := Acctmast->acctname
           (ctempPdcfile)->valdate  := Acctmast->valdate
           (ctempPdcfile)->matdate  := Acctmast->matdate
           (ctempPdcfile)->amort    := Acctmast->amort
           (ctempPdcfile)->osbal    := Acctmast->osbal
		   (ctempPdcfile)->status   := Acctmast->status
           (ctempPdcfile)->depdate  := _prn_check()

           (ctempPdcfile)->(dbcommit())

        endif

     ENDIF

     Acctmast->(dbskip(+1))

  enddo


   (ctempPdcfile)->(dbgotop())
   do while !(ctempPdcfile)->(eof())

      if substr(Acctmast->acctno,5,3) == '103'
         @ prow()+1,00 say padr( 'L-'+(ctempPdcfile)->BRCODE+'-'+right( (ctempPdcfile)->acctno,5),11)
      else
         @ prow()+1,00 say padr('M-'+(ctempPdcfile)->BRCODE+'-'+right( (ctempPdcfile)->acctno,5),11)
      endif

/*chi042110
      if substr(Acctmast->acctno,5,3) == '103'
         @ prow()  ,pcol()+2 say 'L-'+(ctempPdcfile)->BRCODE+'-'+right( (ctempPdcfile)->acctno,5)
      else
         @ prow()  ,pcol()+2 say 'M-'+(ctempPdcfile)->BRCODE+'-'+right( (ctempPdcfile)->acctno,5)
      endif
*/

	  if val((ctempPdcfile)->status) == 0
		@ prow()  ,pcol()+2 say 'CANCELLED'
	  else
		@ prow()  ,pcol()+2 say padr(astatus[val((ctempPdcfile)->status)],13)
	  endif
      @ prow()  ,pcol()+2 say trans((ctempPdcfile)->acctname,'@!')
      @ prow()  ,pcol()+2 say trans((ctempPdcfile)->valdate,'@D')
      @ prow()  ,pcol()+2 say trans((ctempPdcfile)->matdate,'@D')
      @ prow()  ,pcol()+2 say trans((ctempPdcfile)->amort,'999,999,999,999.99')
      @ prow()  ,pcol()+2 say trans((ctempPdcfile)->osbal,'999,999,999,999.99')
      @ prow()  ,pcol()+2 say trans((ctempPdcfile)->depdate,'@D')

      if prow() >= 54
         __eject()
         pgn++
         Head_9999( pgn,xdate)
      endif

      (ctempPdcfile)->(dbskip(+1))
   enddo

   __eject()

return nil

***************************************
*
static function _prn_check()
***************************************
   local dretval := ctod ( '' ),adays := {},nctr := 0

     if PDCDTBCK->(dbseek(ACCTMAST->BRCODE+Acctmast->acctno))

        do while PDCDTBCK->BRCODE+PDCDTBCK->acctno == ACCTMAST->BRCODE+Acctmast->acctno .and. !PDCDTBCK->(eof())
           if PDCDTBCK->depdate <= ddate
              aadd ( adays,PDCDTBCK->depdate  )
           endif
           PDCDTBCK->(dbskip(+1))
        enddo

        adays := asort ( adays,,,{|x,y| x>y })

        dretval := adays [1]
	 EndIf

	 if Pdc_dtls->(dbseek(ACCTMAST->BRCODE+Acctmast->acctno))

        do while PDC_DTLS->BRCODE+Pdc_dtls->acctno == ACCTMAST->BRCODE+Acctmast->acctno .and. !Pdc_dtls->(eof())
           if Pdc_dtls->depdate <= ddate
              aadd ( adays,Pdc_dtls->depdate  )
           endif
           Pdc_dtls->(dbskip(+1))
        enddo

        adays := asort ( adays,,,{|x,y| x>y })

        dretval := adays [1]
     endif

return dretval

***************************************
*
Static Function Head_9999( pgn,xdate )
***************************************
  setprc  (0,0)
  setfont ('DRAFT')
  setfont ('ELITE')

  @ prow ()+1,00 say 'ACCOUNT MANAGEMENT SYSTEM'
  @ prow (),  00+len('ACCOUNT MANAGEMENT SYSTEM');
                 say PADL('Page No. ' + tran(pgn,'999'),80-len('ACCOUNT MANAGEMENT SYSTEM'))
  @ prow ()+1,00 say 'AMSR500B'
  @ prow ()  ,00+len('AMSR500B');
                 say PADL( dtoc(DATE())+' '+TIME(), 80-len('AMSR500B'))
  @ prow ()+1,00 say PADC('ORIX METRO Leasing and Finance Corporation',80)
  @ prow ()+1,00 say padc("LIST OF ACCOUNTS WITH RUNNING OUT PDC's",80)

  @ prow ()+1,00 say padc('FOR '+ xdate,80)

  setfont      ( upper('condensed') )

  @ prow ()+1,00 say ' '
  @ prow ()+1,00 say '-------------------------------------------------------------------------------------------------------------------------------------------------------------------'
  @ prow ()+1,00 say 'Account                            Client                                         Booking        Maturity         Monthly            Outstanding  Last        '
  @ prow ()+1,00 say 'Number           Status            Name                                           Date           Date             Amort/Rent         Balance      Check       '
  @ prow ()+1,00 say '-------------------------------------------------------------------------------------------------------------------------------------------------------------------'
  @ prow ()+1,00 say ' '

return nil


/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

************************************
*
static function MonthPlusOne( dSrcDate )        // noels
*
************************************
  local dNewDate

  if month(dSrcDate) == 12
    dNewDate := ctod("01/31/" + str(year(dSrcDate)+1))
  else

    //  skip 2 months in order to get ending day of the next month

    dNewDate := dSrcDate + 32

    // set to first day of the month

    dNewDate := ctod(str(month(dNewDate)) + "/01/" + str(year(dNewDate)))

    dNewDate := dNewDate - 1     // move a day back

  endif

return dNewDate

*
*           end of the program ( amsr500b.prg )
*
