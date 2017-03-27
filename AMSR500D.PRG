/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   colf-iis -- account management system                                      ³
³   program idúúú amsr500D                                                     ³
³   descriptionúú Accts. with PDC's ( Audit )                                  ³
³   authorúúúúúúú Adrian Abu                                                   ³
³   dateúúúúúúúúú 1500 30 Sept 2004                                            ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                             u p d a t e s                                    ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        who        ³       when        ³               why                    ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        aga        ³  14.02.2007       ³  removed paysked reference           ³
³        mts        ³  07.14.2011       ³  Added PDCDTBCK database             ³
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
                        { 'RevFreq' ,'C',16,00 } ,;                        
                        { 'Osbal'   ,'N',12,02 } ,;
                        { 'Revdate' ,'D',08,02 } ,;
                        { 'Valdate' ,'D',08,02 } ,;
                        { 'Depdate' ,'D',08,02 } ,;
                        { 'Matdate' ,'D',08,02 } ,;
                        { 'BRCODE'  ,'C',03,00 }  ;
                      }
  
  if !netuse( '&g_AMS_PATH\Acctmast', .f., 10 )              && Account master file
     break
  else
     if !.f.; ordlistclear(); endif
//   ordlistadd( 'Acctmast' )                    && set index on acctno
     ordlistadd( '&g_AMS_PATH\Acctacno' )                    && set index on acctname
  endif

//aga.26.04.2006.removed for delinquency reengineering
/*
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
*/

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
  *-----------------------
     dbcreate( (cTempPDCfile), aTempStruc )

     if valtype(cTempPDCfile) != 'U'
       if ( netuse((cTempPDCfile), .t., 0) )    // open temp file exclusively

         // create new index file

*         cTempIndex := UniqFile('NTX')
         dbcreateindex( cTempIndex, 'AcctName+dtos(valdate)', { || AcctName+dtos(valdate) }, .f. )

         set index to (ctempPdcfile)->(ctempindex)
         (ctempPdcfile)->(dbsetorder(1))        // account name

       else
         alert('Unable to open file.')
       endif
     else
       alert('Unable to create file.')
     endif
  *-----------------------
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
  @ 18,20 say 'PDC Date to Print    ' get ddate pict '@D' valid !empty(ddate)
  setkey(K_ESC ,{ || fescape( 'Abort?' ) } )
  read
  setkey(K_ESC, nil)

  if lastkey() != K_ESC        // confirm ( 'Proceed?')
     ddate := MonthPlusOne ( ddate )        // noels
     *repcontrol   ( '_pdc09999Audit()' )
     xSTR := CHK_PAR(dDATE)+CHK_PAR(cTempPDCfile)+CHK_PAR(cTempIndex)
     REPCON_OL   ( '_PDC09999AUDIT()',,,,,,xSTR,.T. )
  endif

  restdbf(mu);restscreen(,,,,bf);setcursor(re);setcolor(gf)
return nil

**********************
*
function _pdc09999Audit()
**********************
  local mu:=savedbf(),re:=setcursor(),bf:=savescreen(,,,),gf:=setcolor()
  local pgn:=1,chkcnt:=0,tot_amount:=0
//  local xdate:=cmonth(ddate) + ' ' + str(day(ddate),2) +', '+str(year(ddate),4)
  local xdate:=cmonth(ddate) + ' '+str(year(ddate),4)

  Head_9999( pgn,xdate)

 Acctmast->(dbgotop())
 do while !Acctmast->(eof())
     IF ACCTMAST->BRCODE == g_PAR_BRCH
        if Acctmast->paymode == '1' .and. Acctmast->osbal > 0 .and. Acctmast->valdate <= ddate  // only with PDC with osbal

			if PDCDTBCK->(dbseek(ACCTMAST->BRCODE+Acctmast->acctno))                   //check on PDCDTBCK

			   do while PDCDTBCK->BRCODE+PDCDTBCK->acctno == ACCTMAST->BRCODE+Acctmast->acctno .and. !PDCDTBCK->(eof())

					(ctempPdcfile)->(dbappend())

					if substr(Acctmast->acctno,5,3) == '103'
					   (ctempPdcfile)->acctno := Acctmast->acctno
					   (ctempPdcfile)->BRCODE := Acctmast->BRCODE
					else
					   (ctempPdcfile)->acctno := Acctmast->acctno
					   (ctempPdcfile)->BRCODE := Acctmast->BRCODE
					endif

					(ctempPdcfile)->acctname := Acctmast->acctname

					if Acctmast->revfreq == '1'
					   (ctempPdcfile)->revfreq := '1-Quarterly'
					elseif Acctmast->revfreq == '2'
					   (ctempPdcfile)->revfreq := '2-Semi-Annual'
					elseif Acctmast->revfreq == '3'
					   (ctempPdcfile)->revfreq := '3-Annual'
					elseif Acctmast->revfreq == '4'
					   (ctempPdcfile)->revfreq := '4-Not Applicable'
					elseif Acctmast->revfreq == '5'
					   (ctempPdcfile)->revfreq := '5-Monthly'
					endif

					(ctempPdcfile)->valdate  := Acctmast->valdate
					(ctempPdcfile)->matdate  := Acctmast->matdate
					(ctempPdcfile)->revdate  := Acctmast->revdate
					(ctempPdcfile)->osbal    := Acctmast->osbal
					(ctempPdcfile)->depdate  := _prn_check()

					(ctempPdcfile)->(dbcommit())

				 PDCDTBCK->(dbskip(+1))

			   enddo

			endif

			if Pdc_dtls->(dbseek(ACCTMAST->BRCODE+Acctmast->acctno))                   //check on pdc_dtls

			   do while PDC_DTLS->BRCODE+Pdc_dtls->acctno == ACCTMAST->BRCODE+Acctmast->acctno .and. !Pdc_dtls->(eof())

				 //if Pdc_dtls->depdate <= ddate                        // only before the date

					(ctempPdcfile)->(dbappend())

					if substr(Acctmast->acctno,5,3) == '103'
					   (ctempPdcfile)->acctno := Acctmast->acctno
					   (ctempPdcfile)->BRCODE := Acctmast->BRCODE
					else
					   (ctempPdcfile)->acctno := Acctmast->acctno
					   (ctempPdcfile)->BRCODE := Acctmast->BRCODE
					endif

					(ctempPdcfile)->acctname := Acctmast->acctname

					if Acctmast->revfreq == '1'
					   (ctempPdcfile)->revfreq := '1-Quarterly'
					elseif Acctmast->revfreq == '2'
					   (ctempPdcfile)->revfreq := '2-Semi-Annual'
					elseif Acctmast->revfreq == '3'
					   (ctempPdcfile)->revfreq := '3-Annual'
					elseif Acctmast->revfreq == '4'
					   (ctempPdcfile)->revfreq := '4-Not Applicable'
					elseif Acctmast->revfreq == '5'
					   (ctempPdcfile)->revfreq := '5-Monthly'
					endif

					(ctempPdcfile)->valdate  := Acctmast->valdate
					(ctempPdcfile)->matdate  := Acctmast->matdate
					(ctempPdcfile)->revdate  := Acctmast->revdate
					(ctempPdcfile)->osbal    := Acctmast->osbal
					(ctempPdcfile)->depdate  := _prn_check()

					(ctempPdcfile)->(dbcommit())

				 //endif

				 Pdc_dtls->(dbskip(+1))

			   enddo

			endif
        endif
     ENDIF
     Acctmast->(dbskip(+1))

  enddo

//Ready for printing

   (ctempPdcfile)->(dbgotop())
 
   do while !(ctempPdcfile)->(eof())

      if substr(Acctmast->acctno,5,3) == '103'
         @ prow()+1,00 say 'L-'+(ctempPdcfile)->BRCODE+'-'+right( (ctempPdcfile)->acctno,5)
      else
         @ prow()+1,00 say 'M-'+(ctempPdcfile)->BRCODE+'-'+right( (ctempPdcfile)->acctno,5)
      endif

      @ prow()  ,pcol()+2 say trans((ctempPdcfile)->acctname,'@!')
      @ prow()  ,pcol()+2 say trans((ctempPdcfile)->valdate,'@D')
      @ prow()  ,pcol()+2 say trans((ctempPdcfile)->matdate,'@D')
      @ prow()  ,pcol()+2 say trans((ctempPdcfile)->osbal,'999,999,999,999.99')
      @ prow()  ,pcol()+5 say trans((ctempPdcfile)->revfreq,'@B')
      @ prow()  ,pcol()+2 say trans((ctempPdcfile)->revdate,'@D')
      @ prow()  ,pcol()+3 say trans((ctempPdcfile)->depdate,'@D')

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
           aadd ( adays,PDCDTBCK->depdate  )
           PDCDTBCK->(dbskip(+1))
        enddo

        adays := asort ( adays,,,{|x,y| x>y })

        dretval := adays [1]
     endif
	 
     if Pdc_dtls->(dbseek(ACCTMAST->BRCODE+Acctmast->acctno))

        do while PDC_DTLS->BRCODE+Pdc_dtls->acctno == ACCTMAST->BRCODE+Acctmast->acctno .and. !Pdc_dtls->(eof())
         //if Pdc_dtls->depdate <= ddate
              aadd ( adays,Pdc_dtls->depdate  )
       //    endif
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
                 say PADL('Page No. ' + tran(pgn,'999'),90-len('ACCOUNT MANAGEMENT SYSTEM'))
  @ prow ()+1,00 say 'AMSR500D'
  @ prow ()  ,00+len('AMSR500D');
                 say PADL( dtoc(DATE())+' '+TIME(), 90-len('AMSR500D'))
  @ prow ()+1,00 say PADR('ORIX METRO Leasing and Finance Corporation',80)
  @ prow ()+1,00 say PADR("LIST OF ACCOUNTS WITH PDC's ( AUDIT )",80)

  @ prow ()+1,00 say PADR(xdate,80)
  
  setfont ( upper('condensed') )

  @ prow ()+1,00 say ' '
  @ prow ()+1,00 say '-------------------------------------------------------------------------------------------------------------------------------------------------------------------'
  @ prow ()+1,00 say '  Account    Account                                             Date        Maturity           Outstanding     Review            Last Review  Date of             '
  @ prow ()+1,00 say '  Number     Name                                                Booked      Date               Balance         Frequency         Date         Last Check          '
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
/*
*************************************
*
static function UniqFile( cFileExt )
*************************************
  local mfiname, mrandnum

  do while .t.

    mrandnum := substr(time(),1,2) + substr(time(),4,2) + substr(time(),7,2)

    mfiname  := 'TF' + mrandnum

    if file(mfiname + '.' + cFileExt)          // test if text file exist
      loop
    else
      exit
    endif

  enddo
return mfiname
*/
*
*           end of the program ( amsr500d.prg )
*
