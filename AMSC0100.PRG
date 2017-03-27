/*
 ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³   Program id.........:  AMSC0100.prg                                 ³
 ³   Description........:  close the day's transactions                 ³
 ³   Author.............:  Renan S. Evangelista                         ³
 ³   Date...............:  3:30pm 19-Jul-1996                           ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³                         U P D A T E S                                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³        Who        ³     When      ³               Why                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³  ARIEL B. BULAN   ³  06/08/99     ³ reactivate Function Acctreview() ³
 ³                   ³  06/10/99     ³ deactivate Function Acctreview() ³
 ³                   ³  01/12/2000   ³ Automatic Closing of CA/OT       ³
 ³                   ³               ³ function _auto_close()           ³
 ³                   ³               ³                                  ³
 ³ ABB               ³  10.18.2004   ³ ABB                              ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include "Colf.ch"
#include "Setcurs.ch"
#include "Inkey.ch"
local gf,rctr:=1,ncol:=0,nbar:=0,repflg:=.f.,lrec,mu,o_clr,o_curs
private xtrandate := gTrandate
//
// check flags first...
//
setblink(.t.)


if !netuse ( '&g_GRF_PATH\Ntconfig',.f.,5 )   //    09.14.2004
   close all
   return
endif

if !Ntconfig->eod_flag
   close all
   return
endif

close all

if !chkpass ( procname(), AX_LEVEL, g_USER_ID )
   return
endif

if !netuse('&g_AMS_PATH\flag',.f.,5)
   return
endif

/**************         SUPPRESS VALIDATION FOR PROOFLIST PRINTING abb 04.07.2005
if !prnproof
   error('Prooflist not yet Printed!')
   dbcloseall()
   return nil
endif
***************/

/*
if !BACKUP                         // check if files have been backed-up
   ERROR('Backup not yet Done!')
   dbcloseall()
   return nil
endif
*/

&& get date range to close

 o_clr  := setcolor()
 o_curs := setcursor()
 mu     := savescreen( ,,, )
 fshadow   ( 7,50,9,78,2,'n/w' )
 setcolor  ( 'w/n,w+/n,,,w+/n' )
 setcursor ( 1 )

 do while .t.

    @ 8, 51 say 'Date to Close ' get xtrandate pict '@D' valid !empty(xtrandate)

    setcursor ( 3 )
    read
    setcursor ( 1 )

    if lastkey() == K_RETURN .and. confirm('Are you sure?')
       cont:=.t.
       exit
    elseif lastkey() == K_ESC
       dbcloseall ()
       setcolor   ( o_clr)
       setcursor  ( o_curs)
       restscreen ( ,,,,mu )
       return nil
    endif
 enddo
 setcolor   ( o_clr  )
 setcursor  ( o_curs )
 restscreen ( ,,,,mu )


// confirm closing
if !CONFIRM('Close '+ dtoc(xTRANDATE) + ' transactions?')
   close data
   return nil
endif

// ask again
if !confirm ('Is backup already done? Prooflist?')
   close data
   return nil
endif

// open databases and indeces, open exclusive (we're posting to master files!)

mERR = .F.

if !aMsOpenclos()
   clos data
   return
endif

if Chkpaysked()
    dbcloseall()
    return nil
endif

/* ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   start posting to master files: 
       1. update OTICKET->CRDAVAIL, PRNAVAIL
		 CAHEADER->AVAILED, PRNAVAIL
		 CADETAIL->AVAILED, PRNAVAIL
       2. update CA line, OT status if fully availed (close ACTAKEN)
	  do not close if revolving
			  ÄÄÄÄÄÄÄÄÄ
       3. move ACCTDALY to ACCTMAST
       4. move PAYTSKED to PAYSKED
       5. generate schedule of depreciation of leased equipments
       6. clean transaction files:
	     - remove accounts executed from ACCTWAIT
	     - delete posted records of ACCTDALY
	     - delete posted records of PAYTSKED
   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ */
///////temporary

if !confirm('Continue anyway?')
   close all
   return nil
endif
//Commented for temporary use only

gf:=savescreen(,,,)
fshadow(10,20,12,61,2,'w+/n+')
@ 11, 21 say repl('±',40 )  color 'w+/n'
@ 13, 34 say 'Percentage Processed       %' color 'w/n'
inkey(0.2)
dbselectarea ( 'Acctdaly' )
Acctdaly->   ( dbsetorder(1) )
Acctdaly->   ( dbgotop   ()  )  // abb 11.30.2004

***Acctdaly->   ( dbseek(Parametr->brcode)  )      // 10.18.2004 abb

lrec := 0

Acctdaly->( dbeval( {|| lrec++ },,;
                    {|| !Acctdaly->(eof()) ;
                    } ;
                  ) ;
          )

Acctdaly->   ( dbgotop   ()  )  // abb 12.01.2004

**if Acctdaly->( dbseek(Parametr->brcode) )            // abb 10.18.2004

   @ 11, 21 say 'Û' color 'w+/n'

   do while !Acctdaly->(eof()) // .and. Acctdaly->brcode == Parametr->brcode


      @ 11,21 say repl('Û', ( rctr/lrec ) * 40 ) color 'w+/n'
      @ 13,54 say ( rctr/lrec ) * 100 color 'w+/n'
      rctr++
      // '1' = for posting, '2' = hold

      if Acctdaly->STATUS <> '1' .or. Acctdaly->Valdate > xtrandate
         Acctdaly->(dbskip(+1))
         loop
      endif

      //update CA/OT balance

      if alltrim(Acctdaly->DOCREF) == '1'     // availment thru CA

         dbselectarea('CAHEADER')
         Caheader->(dbsetorder(1)) //setorder to Refno

         if Caheader->( dbseek(Acctdaly->brcode+ACCTDALY->REFNO)) // abb 10.18.2004

            if Caheader->PRNAVAIL + ACCTDALY->PRINCIPAL <= Caheader->PRNLINE

               replace Caheader->AVAILED  with Caheader->AVAILED + ACCTDALY->CREDAMT ,;
                       Caheader->PRNAVAIL with Caheader->PRNAVAIL+ ACCTDALY->PRINCIPAL
               Caheader->(dbcommit())
            else
               crline := (Caheader->CALINE - Caheader->Availed)
               prline := (Caheader->PRNLINE - CAheader->PRNAVAIL)

               replace Caheader->AVAILED  with Caheader->AVAILED  + crline,;
                       Caheader->PRNAVAIL with Caheader->PRNAVAIL + prline

               Caheader->(dbcommit())
               if alltrim(Acctdaly->Docref2) == '1'
                  dbselectarea( 'Caheader' )
   //
   //                if Caheader->(dbseek(Acctdaly->Refno2))
   //
                  if Caheader->(dbseek(Acctdaly->brcode+Acctdaly->Refno2))     // abb 10.18.2004
                     replace Caheader->AVAILED with Caheader->AVAILED + (ACCTDALY->CREDAMT-crline ),;
                             Caheader->PRNAVAIL with Caheader->PRNAVAIL + (ACCTDALY->PRINCIPAL-prline  )
                             Caheader->(dbcommit())
                  endif

               elseif alltrim(Acctdaly->Docref2) == '2'

                  dbselectarea( 'oticket')
                  Oticket->   ( dbsetorder(1) )  //refno
                  if Oticket->(dbseek(Acctdaly->brcode+Acctdaly->Refno2))
                     replace  Oticket->CRDAVAIL with Oticket->CRDAVAIL + (ACCTDALY->CREDAMT-crline ),;
                              Oticket->PRNAVAIL with Oticket->PRNAVAIL + (ACCTDALY->PRINCIPAL-prline  )
                              Oticket->(dbcommit())
                  endif

               endif
            endif
         endif

      elseif alltrim(Acctdaly->DOCREF) == '2'     // availment thru OT

         dbselectarea('Oticket')
         Oticket->   (dbsetorder(1))     // set order to refno

         if Oticket->(dbseek( Acctdaly->brcode + ACCTDALY->REFNO ) )
            if Oticket->PRNAVAIL + ACCTDALY->PRINCIPAL <= Oticket->PROCEEDS
               replace Oticket->CRDAVAIL with Oticket->CRDAVAIL+ACCTDALY->CREDAMT,;
               Oticket->PRNAVAIL with Oticket->PRNAVAIL+ACCTDALY->PRINCIPAL
               Oticket->(dbcommit())
            else
               crline := (Oticket->CREDAMT - Oticket->CRDAVAIL)
               prline := (Oticket->PROCEEDS - Oticket->PRNAVAIL)
               replace Oticket->CRDAVAIL with Oticket->CRDAVAIL + crline, ;
                       Oticket->PRNAVAIL with Oticket->PRNAVAIL + prline
               Oticket->(dbcommit())
               Oticket->(dbcommit())
               if alltrim(Acctdaly->Docref2) == '1'
                  dbselectarea( 'Caheader' )
                  Caheader->  ( dbsetorder(1) )

                  if Caheader->( dbseek(Acctdaly->brcode+Acctdaly->Refno2) )
                     replace Caheader->AVAILED  with Caheader->AVAILED + (ACCTDALY->CREDAMT-crline ),;
                             Caheader->PRNAVAIL with Caheader->PRNAVAIL + (ACCTDALY->PRINCIPAL-prline  )
                             CAheader->(dbcommit())
                  endif
               elseif alltrim(Acctdaly->Docref2) == '2'
                  dbselectarea( 'oticket')
                  Oticket->   ( dbsetorder(1) )  //refno
                  if Oticket->( dbseek(Acctdaly->Refno2) )
                     replace  Oticket->CRDAVAIL with Oticket->CRDAVAIL + (ACCTDALY->CREDAMT-crline ),;
                              Oticket->PRNAVAIL with Oticket->PRNAVAIL + (ACCTDALY->PRINCIPAL-prline  )
                              Oticket->(dbcommit())
                  endif
               endif
            endif
         endif

      endif // end of docref checking

      add_acct   ()  // add record  to Acctmast //-checked

      repflg := .t.

      transfer   ()   // Transfer records from Paytsked to Paysked //-checked
      gen_lcr    ()   // Generate Lcr Depreciation //-checked

      ////  gen_udispred()

      _gen_udi_alir  ()      // generate udi/alir ( abb, 09/13/2000 )
      __update_udi   ()      // updated udispred exclusive of tax

      chkdelwait     ( Acctdaly->Acctno )     // Delete Availment w/c is already booked
      // gen_rvspred ()  //- temporarily omitted under floor delivery

      ACCTDALY->(dbdelete())
      ACCTDALY->(dbskip())
   enddo    //terminate the traversing of Acctdaly

   &&
   && Commented for temporary use only
   &&

   Trantempjv    ()          // Tranfer Ams JV to GLS
                             // this module must conform with the entry in
                             // the Acctdaly to avoid mis-leading entry

   waiton        ( 'Automatic Closing of CA/OT ACCOUNTS ... ',,'n*/w' )

   _auto_close   ( xtrandate ) // AutoMatic Closing of CA/OT ( January 12, 2000 )

   waitoff       ()

   error         ( 'Transferring of JV from AMS to GLS has been done..!!' )

**endif

// Acctreview()         // check accout for review
                        // is not finally completed seek feedback from MANCOM
                        // this is a very delicate module, it will affect much
                        // in the schedule if done erroneously
                        &&
                        &&  REACTIVATE the calling of Acctreview Module
                        &&  ( ABB June 8, 1999 )
                        &&

inkey(0.2)

//if repflg


   dbselectarea('Flag')
   Flag->(netlock( 'R',5 ))

   Flag->Prnproof := .f.
   Flag->Backup   := .f.
   Flag->dclosed  := .t.
   Flag->lastclosed := xtrandate
   Flag->(dbunlock())
   Flag->(dbcommit())

   Parametr->(netlock( 'R',5 ))
   Parametr->Prevdate := Flag->lastclosed
   Parametr->(Flag->(dbunlock()))
   Parametr->(dbcommit())

// EVR   UPDT_OL()         && RED 033005

   setcolor('w/n')

   //clear
      x:=1
      whil x < 13
	 //tone (st_[x],0)
	 inkey(.05)
	 x += 1
	 scroll(00,00,11,79,-1)
	 @ 11,00 say ' '
	 scroll(12,00,24,79,1)
	 @ 12,00 say ' '
	 for z = 1  to 40
	   @ 00,00 say ''
	 next
      endd

   license()

      if .not. file('&g_AMS_PATH\USER_ID.NTX')
         if !NETUSE('&g_AMS_PATH\AXMAST',.T.,5)
            USER_OK = .F.
            return ( nil )
         else
            index on decrypt(AXMAST->USER_ID) to &g_AMS_PATH\USER_ID
            use
         endif
      endif

      if !NETUSE('&g_AMS_PATH\AXMAST',.F.,5)
         USER_OK = .F.
         return ( nil )
      endif
      set index to &g_AMS_PATH\USER_ID

      if Axmast->(dbseek(g_USER_ID))
         if Axmast->(netlock('R',5))
            Axmast->status    := 'E'
            Axmast->logoutdate := date()
            Axmast->logouttime := time()
            Axmast->(dbunlock())
         endif
            Axmast->(dbcommit())
      endif

if netuse( 'c:\Wsconfig',.f.,5 )
   if Wsconfig->(netlock('R',5))
      Wsconfig->flag := .f.
      Wsconfig->(dbunlock())
   endif
      Wsconfig->(dbcommit())
endif

_updateNtConfig()

*--->                         && RED 051005
IF TRUE_BRCH == '001'
	IF NETUSE('&g_GRF_PATH\COMPLOG',.F.,5)
		SET INDEX TO &g_GRF_PATH\COMPLOG1, &g_GRF_PATH\COMPLOG2,;
					 &g_GRF_PATH\COMPLOG3, &g_GRF_PATH\COMPLOG4

		IF COMPLOG->(DBSEEK(NETNAME()+'AMS   '+PADR(g_USER_ID,6,' ')))
			IF COMPLOG->(NETLOCK('R',3))
				REPLACE COMPLOG->STATUS  WITH 'O'
				REPLACE COMPLOG->SYSTEM  WITH ' '
				REPLACE COMPLOG->USER    WITH ' '
				REPLACE COMPLOG->OUTDATE WITH DATE()
				REPLACE COMPLOG->OUTTIME WITH TIME()
				COMPLOG->(DBUNLOCK())
				COMPLOG->(DBCOMMIT())
			ENDIF
		ENDIF

		COMPLOG->(DBCLOSEAREA())
	ENDIF
ELSE
	g_par_brch := true_brch
	xSTR := CHK_PAR(g_USER_ID)+CHK_PAR('GLS')+CHK_PAR(NETNAME())
	if !IF(alltrim(CPS_REQST(xSTR,'LOGOUT')) == 'F',.f.,.t.)
		ALERT('FAILED TO ACCESS COMPLOG')
	ENDIF
ENDIF
*--->

   quit

//endif
restscreen(,,,,gf)
dbcloseall()
return nil

*********************************************
*
static function _auto_close ( dtrandate )
*********************************************
   local nrecno  := Caheader->(recno()),ndate
   local nrecno2 := Oticket-> (recno())

   Caheader->(dbgotop())                // abb 10.18.2004
***   Caheader->(dbseek(Parametr->brcode))  abb 11.30.2004
   do while !Caheader->(eof()) // .and. Caheader->brcode == Parametr->brcode // abb 10.18.2004

      ndate := Caheader->actdate+365           // LESS THAN OR EQUAL TO 1 YEAR

      if ndate <= dtrandate .and. Caheader->actaken == '3'

         if Caheader->actaken != '5' .and. _chk_avail ( Caheader->brcode,Caheader->canumber,'1' )

            if Caheader->(netlock( 'R',0 ) )
               Caheader->actaken := '5'             // CLOSED
               Caheader->actdate := dtrandate       // TRANS. DATE
               Caheader->user_id := 'XXX'           // USER_ID
               Caheader->(dbunlock())
            endif

         endif

      endif

      Caheader->(dbskip(+1))
   enddo

   Oticket->(dbgotop())

****   Oticket->(dbseek(Parametr->brcode))
   do while !Oticket->(eof()) // .and. Oticket->brcode == Parametr->brcode

      ndate := Oticket->actdate+90       // LESS THAN OR EQUAL TO 3 MONTHS

      if ndate <= dtrandate .and. Oticket->actaken == '3'

         if Oticket->actaken != '5' .and. _chk_avail ( Oticket->brcode,Oticket->otnumber,'2' )

            if Oticket->(netlock( 'R',0 ) )
               Oticket->actaken := '5'              // CLOSED OT
               Oticket->actdate := dtrandate        // TRANS. DATE
               Oticket->user_id := 'XXX'            // USER_ID
               Oticket->(dbunlock())
            endif

         endif

      endif

      Oticket->(dbskip(+1))
   enddo

   Oticket ->( dbcommit( ) )
   Caheader->( dbcommit( ) )
   Caheader->( dbgotop ( nrecno  ) )
   Oticket ->( dbgotop ( nrecno2 ) )
return nil

***************************************************
*
static function _chk_avail ( cbrcode,ccanumber,cdocref )
***************************************************
   local lretval := .t.,nntx := Acctwait->(indexord()),nrecno := Acctwait->(recno())

   Acctwait->(dbsetorder(5)) ///   refno+docref1
   if Acctwait->(dbseek( cbrcode+ccanumber+cdocref ))
      lretval := .f.
   endif

   Acctwait->(dbsetorder(6)) ///   refno2+docref1
   if Acctwait->(dbseek( cbrcode+ccanumber+cdocref ))
      lretval := .f.
   endif

   Acctwait->(dbsetorder(nntx))
   Acctwait->(dbgoto(nrecno))

return lretval

/*---------------------------*/
 Static Function Chkpaysked()
/*---------------------------*/
local nval := .f.,totcred := 0
private glend_:={}
//
//
*****Acctdaly->(dbseek(Parametr->brcode))       // abb 10.18.2004
Acctdaly->(dbgotop())
do while Acctdaly->(!eof())     // .and. Acctdaly->Brcode == Parametr->brcode
     totcred := 0
//      Paytsked->( dbseek( Acctdaly->Acctno ))
     Paytsked->( dbseek( Acctdaly->brcode+Acctdaly->Acctno ))     // abb 10.18.2004
     Paytsked->( dbeval( {|| totcred += Paytsked->Amort },,;
                         {|| Paytsked->Acctno == Acctdaly->Acctno .and. ;
                             Paytsked->brcode == Acctdaly->brcode .and. ;
                            !Paytsked->(eof()) ;
                         };
                       );
               )
     if round( totcred,2 ) <> round( Acctdaly->Credamt, 2)
        aadd( glend_,{ Acctdaly->Acctno,Substr(Acctdaly->Acctname,1,40),Acctdaly->Credamt, totcred } )
     endif
     Acctdaly->(dbskip(+1))
 enddo

 if !empty( glend_ )
    nval := .t.
    *repcontrol( 'Paytsked_()' )
    repcon_ol( 'Paytsked_()',,,,,,,.F. )
 endif

return nval

/*--------------------*/
 Function Paytsked_()
/*--------------------*/
/*
         1         2         3         4         5         6         7         8         9
123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
  ----------------  ----------------------------------------  --------------  --------------
  Account No                     Account Name                 Credit Amount   Schedule Amt.
  ----------------  ----------------------------------------  --------------  --------------
  9999-99999-99999  1234567890123456789012345678901234567890  999,999,999.99  999,999,999.99
                         List of Discrepancies in Payment Schedule
                                Xxxxxxxxxxx 99, 1999

*/
setfont('DRAFT')
setfont('ELITE')
@ prow()+1, 1 say Padc( 'List of Discrepancies in Payment Schedule',96 )
@ prow()+1, 1 say Padc( Cmonth(xTrandate)+' '+ str(day(xTrandate),2) +', ' + str(year(xTrandate),4 ), 96 )
@ prow()+1, 1 say ''
@ prow()+1, 3 say '----------------  ----------------------------------------  --------------  --------------'
@ prow()+1, 3 say '  Account No                     Account Name               Credit Amount   Schedule Amt. '
@ prow()+1, 3 say '----------------  ----------------------------------------  --------------  --------------'
for x := 1 to len( glend_ )
    @ prow()+1, 3 say trans( glend_[ x,1 ],'@R 9999-99999-99999' )
    @ prow()  ,21 say glend_[ x,2 ]
    @ prow()  ,63 say trans( glend_[ x,3 ],'999,999,999.99')
    @ prow()  ,79 say trans( glend_[ x,4 ],'999,999,999.99')
next x
__eject()
return nil

/*----------------------------------*/
 Static function chkdelwait( xAcctno)
/*----------------------------------*/
local mu:=savedbf(),bf:=Acctwait->(indexord())
dbselectarea( 'Acctwait')
Acctwait->  ( dbsetorder(1) )         // abb 10.18.2004

**alert ( Acctwait->(indexkey()) )          // abb 12.8.2004
**
**alert ( 'Acctdaly->brcode+xAcctno := ' + Acctdaly->brcode+xAcctno + '*' )
**
Acctwait->  ( dbseek( Acctdaly->brcode+xAcctno) )
Acctwait->  ( dbeval( { ||  Acctwait->(dbdelete())  ;
                      },,;
                      { || Acctwait->Acctno == xAcctno .and. ;
                           Acctwait->brcode == Acctdaly->brcode ;
                      } ;
                    ) ;
            )
//pack
restdbf(mu)
Acctwait->(dbsetorder(bf))
return nil

/*---------------------------*/
 Static Function Trantempjv()
/*---------------------------*/
local zz:=savedbf(),xx:=savescreen( ,,, )
local trec:=0,nrec:=1
dbselectarea('Amsjvh')
*****Amsjvh->( dbseek(Parametr->brcode) )
Amsjvh->( dbgotop() )     // abb 01.24.2005
Amsjvh->( dbeval({||trec++ },,{|| !Amsjvh->(eof()) }) )     && RED 031105 REMOVED '.and. Amsjvh->brcode == g_PAR_BRCH
// Amsjvh->(dbgotop()   abb 10.18.2004
//
***** Amsjvh-> ( dbseek ( Parametr->brcode) )
Amsjvh-> ( dbgotop () )  // abb 01.24.2005
Amsjvh-> ( dbeval ( { || if( Amsjvh->Trandate <= xTrandate,;
                             eval( {|| Updtehead(),;
                                       Amsjvh->(dbdelete()) ;
                                   } ;
                                 ),;
                          nil),;
                      devpos(24,1),devout( repl('þ',(nrec/trec) * 79),'w/n'), nrec++ },,;
                 { || !Amsjvh->(eof())  } ) )

dbselectarea('Amsjvh')
//pack
restscreen(,,,,xx)
restdbf(zz)
return nil

/*----------------------------*/
 Static Function Updtehead()
/*----------------------------*/
///coding for tranferring to GLS\RUN\Tranhead
///from AMS\RUN\Amsjvh
local zz:=savedbf()

dbselectarea('Tranhead')
if Tranhead->(netlock('A',0))
   Tranhead->brcode     := Amsjvh->brcode       // abb 10.18.2004

   Tranhead->Trandate   := Amsjvh->Trandate
   Tranhead->Trnumber   := Amsjvh->Trnumber
   Tranhead->Trancode   := '1'    //Amsjvh->Trancode
   Tranhead->Trantype   := Amsjvh->Trantype  //== '1', '1', '3' )
   Tranhead->Tramount   := Amsjvh->Tramount
   Tranhead->Partix1    := Amsjvh->Partix1
   Tranhead->Partix2    := Amsjvh->Partix2
   Tranhead->Partix3    := Amsjvh->Partix3
   Tranhead->Partix4    := Amsjvh->Partix4
   Tranhead->Partix5    := Amsjvh->Partix5
   Tranhead->Partix6    := Amsjvh->Partix6
   Tranhead->Partix7    := Amsjvh->Partix7
   Tranhead->Usercode   := Amsjvh->Usercode

   Tranhead->Adjmntcode := '7'          // '7' means from 'booking'   abb 10.18.2004
   Tranhead->Origin     := .t.

   Tranhead->post_date  := Amsjvh->post_date // abb 10.18.2005
   
   Tranhead->(dbunlock())
   Tranhead->(dbcommit())
endif

Amsjvd->(dbseek(Amsjvh->brcode+Amsjvh->Trnumber))
Amsjvd->(dbeval({ || Updtedtls(),;
                     Amsjvd->(dbdelete()) },,;
                { || Amsjvd->Trnumber == Amsjvh->Trnumber .and. ;
                     Amsjvd->brcode   == Amsjvh->brcode ;
                } ;
               ) ;
        )
dbselectarea('Amsjvd')
//pack
restdbf(zz)
return nil

/*--------------------------*/
 Static Function Updtedtls()
/*--------------------------*/
local zz:=savedbf()
//code for the append in the Trandtls File
Dbselectarea('Trandtls')
if Trandtls->(netlock('A',0 ))
  Trandtls->brcode    := Amsjvd->brcode
  Trandtls->Trnumber  := Amsjvd->Trnumber
  Trandtls->Glcode    := Amsjvd->Glcode
  Trandtls->Drcr      := Amsjvd->Drcr
  Trandtls->Amount    := Amsjvd->Amount
  Trandtls->Trancode  := '1'  //Amsjvd->Trancode
  Trandtls->(Dbunlock())
  Trandtls->(dbcommit())
endif
////////////
restdbf(zz)
return nil

 && OB will then be controlled by the GLS
 && as well as payment Schedule and Payment history posting
 && only Payment Schedule image file will be updated in this module

/*----------------------------*/
 Static Function Acctreview()           //check account for review
/*----------------------------*/
local mu:=savedbf(),ncol,lrec:=0,nbar,rctr:=1,old_amrt,nremterm
local n_inc := 0,oldrate,nrefdate,ex_mo := 0,old_date,nmast:= Acctmast->(indexord()),nrev := Review->(indexord())
local lstart := .f.

Acctmast->  ( dbsetorder(1) )    //index on acctno
Review->    ( dbsetorder(1) )
dbselectarea( 'Treview' )
Treview->   ( dbsetorder(1) )
Treview->   ( dbgotop() )

waiton ( 'Evaluating Review file...!!..pls. wait..!!,',,'n*/w' )
Treview->   ( dbeval ( {|| lrec++ },,;
                       {|| Treview->(!eof()) }) )

waitoff()
Treview->   ( dbgotop() )
process_scr ( '.....Posting account for review..!!!..' )

do while Treview->(!eof())

   ex_mo := 0
   process_bar( lrec, rctr )
   rctr++

   if Treview->Status <> '1'
      Treview->(dbskip(+1))
      loop
   endif

   if Acctmast-> ( dbseek ( Treview->Acctno ) )

       Updt_pyschd ( Treview->Acctno  ,;
                     Treview->Effdate1,;
                     Treview->Monthno ,;
                     n_inc    ,;
                     Acctmast->Matdate,;
                     Treview->App_amrt,;
                     @nrefdate,;
                     @ex_mo ;
                   )

       n_inc := Treview->App_amrt - Acctmast->Amort
       dbselectarea ( 'Acctmast' )

       while !Acctmast->(netlock( 'R',5 ))
       enddo

       old_amrt := Acctmast->Amort
       oldrate  := Acctmast->Truerate
       old_date := if ( Review->(dbseek(Acctmast->Acctno)),;
                        Acctmast->Effdate ,;
                        Acctmast->Firstdue ;
                      )

       nremterm := Acctmast->Remterm

       if !lstart                                       &&  added . . .
          if !Review->(dbseek(Acctmast->Acctno))
             Add_review ( old_amrt,oldrate, old_date )  &&  by . . .
          endif
          lstart := .t.                                 &&  abb
                                                        &&     ( june 9, 1999 )
       endif

       Acctmast->Truerate   := Treview->App_tr
       Acctmast->Amort      := Treview->App_amrt
       Acctmast->Revdate    := Treview->Effdate2
       Acctmast->Rv_Refdate := nrefdate
       Acctmast->Effdate    := Treview->Effdate1
       Acctmast->Rv_months  := ex_mo // Treview->Monthno  && this will have to do when amort decreases
       // Acctmast->Osbal    := Acctmast->Osbal + ( n_inc *  Treview->Monthno )

       Acctmast-> ( dbunlock() )
       Acctmast-> ( dbcommit() )

*****
*****       Add_review ( old_amrt,oldrate, old_date )      && removed by ariel
*****                                                      && ( june 9, 1999 )
                                                           && for this   É»
                                                           &&  ÉËËÍÍÍÍÍÍÍÊ¼
                                                           &&  
       Add_review ( Acctmast->amort,Acctmast->truerate, Acctmast->effdate )
       Treview->  ( dbdelete() )
   endif

   Treview->(dbskip(+1))

enddo

Treview->( dbcommit() )
inkey    ( .2 )
restdbf  ( mu )
Acctmast-> ( dbsetorder(nmast) )
Review-> ( dbsetorder(nrev) )
return nil

/*----------------------------------------------------*/
 Static Function Updt_pyschd( nAcctno,neffdate,nmo,n_inc,nmatdate,namort,nrefdate,ex_mo )
/*---------------------------------------------------*/
 //check remterm, it is not a wise decision to use remterm as a basis of remaining term
 //sometime it varies
 //try to figure out the effect in the payment image file
 local als := select(), zz := 0, inc_int, nint_amt,old_nmo := nmo
 local tot_inc := n_inc * nmo,nval,org_amort,p_num,prevdate

 dbselectarea ( 'Payimage' )
 Payimage->   ( dbsetorder(1) )
 Payimage->   ( dbseek( nAcctno + dtos(neffdate),.t. ) )
 do while Payimage->Acctno == nAcctno .and. !Payimage->(eof())
    Payimage->Amort := namort
    nmo--
    ex_mo++                  && check the exact no of changes occurence in the image file
    Payimage->( dbskip(+1) ) && this will be recorded in the master file to be use in GL
 enddo                       && closing esp. when the rental/amortization decreases
 Payimage->  ( dbcommit() )

 /*
 Payimage->(dbskip(-1))
 while Payimage->Acctno == nAcctno .and. Payimage->Amort <> nAmort
    Payimage->(dbskip(-1))
 enddo
 */

 nrefdate := if ( Payimage->Acctno == nAcctno .and. Payimage->Amort == nAmort,;
                  Payimage->Paydate,;
                  ctod('') ;
                )

 && this process will control the updating<Review> that will be done
 && during GLS Closing
 && Review will be posted like posting normal adjustment
 && the only difference is that the reference file w/c is the Image file
 && have been updated first in the AMS

/*
 && this process will be handled in the GLS Closing
*/

 dbselectarea(als)
 return nil

/*--------------------------------------*/
 Static Function evaldate( nacct, pdate, org_amort, p_num )
/*--------------------------------------*/
local xvaldate := pdate
if Payimage->(dbseek( nacct + dtos(pdate) ))
   Payimage->(dbskip(-1))
   if Payimage->Acctno == nacct
      xvaldate  := Payimage->Paydate
      org_amort := Payimage->Amort
      p_num     := Payimage->Paynum
   endif
endif
return xvaldate

**********************************
*
*
static Function add_acct()        // add record to account master file
**********************************
 local mu := Savedbf()

   center ( 24, 'w+*/n', 'þþþþþþþþ Transferring data to Account master File þþþþþþþþ' )
   dbselectarea ( 'acctmast'  )
   Acctmast   ->( dbappend () )

   acctmast->brcode    := acctdaly->brcode         // abb 10.18.2004
   acctmast->acctno    := acctdaly->acctno
   acctmast->clntcode  := acctdaly->clntcode
   acctmast->acctname  := acctdaly->acctname
   acctmast->refno     := acctdaly->refno
   acctmast->aocode    := acctdaly->aocode
   acctmast->fcltycode := acctdaly->fcltycode
   acctmast->principal := acctdaly->principal
   acctmast->paytype   := acctdaly->paytype
   acctmast->term      := acctdaly->term
   acctmast->termunit  := acctdaly->termunit
   acctmast->remterm   := acctdaly->term
   acctmast->truerate  := acctdaly->truerate
   acctmast->ratetype  := acctdaly->ratetype
   acctmast->surety    := substr( acctdaly->surety1,1,40 )
   acctmast->surety2   := substr( acctdaly->surety2,1,40 )
   acctmast->unit      := substr( acctdaly->unit,1,40 )
   acctmast->unit2     := acctdaly->unit2
   acctmast->addon     := acctdaly->addon
   acctmast->gd        := acctdaly->gd
   acctmast->rv        := acctdaly->rv
   acctmast->factor    := acctdaly->factor
   acctmast->dlrcode   := acctdaly->dlrcode
   acctmast->salesrep  := acctdaly->salesrep
   acctmast->purcamt   := acctdaly->purcamt
   acctmast->downpay   := acctdaly->downpay
   acctmast->incentive := acctdaly->incentive
   acctmast->nerate    := acctdaly->nerate
   acctmast->trantype  := acctdaly->trantype
   acctmast->notfctn   := acctdaly->notfctn
   acctmast->colexion  := acctdaly->colexion
   acctmast->recourse  := acctdaly->recourse
   acctmast->obligor   := acctdaly->obligor
   acctmast->colatrl   := acctdaly->colatrl
   acctmast->ornumber  := acctdaly->ornumber
   acctmast->udiamt    := acctdaly->udiamt
   acctmast->ediamt    := acctdaly->ediamt
   acctmast->ervamt    := acctdaly->ervamt
   acctmast->osbal     := acctdaly->osbal
   acctmast->tdsassign := acctdaly->tdsassign
   acctmast->tdsfield  := acctdaly->tdsfield
   acctmast->user_id   := acctdaly->user_id
   acctmast->amort     := acctdaly->amort
   acctmast->credamt   := acctdaly->credamt
   acctmast->docref    := acctdaly->docref
   acctmast->valdate   := acctdaly->valdate
   acctmast->condate   := acctdaly->condate
   acctmast->paymode   := acctdaly->paymode
   acctmast->payfreq   := acctdaly->payfreq
   acctmast->revfreq   := acctdaly->revfreq
   acctmast->cltrltype := acctdaly->cltrltype
   acctmast->unitcode  := acctdaly->unitcode
   acctmast->credtype  := acctdaly->credtype
   acctmast->unitloca  := acctdaly->unitloca
   acctmast->firstdue  := acctdaly->firstdue
   acctmast->matdate   := acctdaly->matdate
   acctmast->currcode  := acctdaly->currcode
   acctmast->orixunit  := acctdaly->orixunit
   acctmast->status    := acctdaly->status
   acctmast->revdate   := acctdaly->revdate
   acctmast->mrr_rate  := acctdaly->mrr_rate
   acctmast->tb_rate   := acctdaly->tb_rate
   acctmast->asetcode  := acctdaly->asetcode
   acctmast->refno2    := acctdaly->refno2
   acctmast->docref2   := acctdaly->docref2
   acctmast->ponum     := acctdaly->ponum
   acctmast->orixbrrate:= acctdaly->orixbrrate         // 10.03.2002 abb SSR#29

   acctmast->vatincl   := Acctdaly->vatincl   // 05.05.2003    abb

   acctmast->(dbcommit())

   restdbf(mu)
   @ 24,00 say repl(' ',79)
return nil

/*---------------------------*/
 Static function Add_review( namort, nrate, odate )
/*---------------------------*/
local mu:=savedbf()
dbselectarea('Review')
if Review->( netlock('A',5) )
   Review->Acctno    := Treview->Acctno
   Review->Pvalue    := Treview->Pvalue
   Review->New_mrr   := Treview->New_mrr
   Review->New_tb    := Treview->New_tb
   Review->Comp_tr   := Treview->Comp_tr
   Review->Comp_amrt := Treview->Comp_amrt
   Review->Status    := Treview->STatus
   Review->Effdate   := odate //Treview->Effdate1
   Review->App_tr    := nrate
   Review->App_amrt  := namort
   Review->Revdate   := Treview->Effdate2
   Review->(dbunlock())
   Review->(dbcommit())
endif
restdbf(mu)
return nil

******************************
*
static function transfer()      // update schedule of payment
******************************
local mu:=Savedbf()

 center( 24, 'w+*/n', 'þþþþ Transferring data to Paysked.dbf and Payimage.þþþþ' )

 dbselectarea ( 'Paytsked')
//  Paytsked->   ( dbsetorder(1) )      //acctno abb

 Paytsked->   ( dbsetorder(1) )      // brcode + acctno 10.18.2004 abb
//
//  if Paytsked->( dbseek(Acctdaly->Acctno) )
//

 *if Paytsked->( dbseek(g_PAR_BRCH+Acctdaly->Acctno) )   // abb 10.18.2004
 IF PAYTSKED->( DBSEEK(ACCTDALY->BRCODE+ACCTDALY->ACCTNO) )   && RED 031105 REPLACED ABOVE LINE

    do while Paytsked->Acctno == Acctdaly->Acctno .and. ;
             Paytsked->brcode == ACCTDALY->BRCODE .and. ;     && RED 031105 REPLACED 'g_PAR_BRCH
            !Paytsked->(eof())

       // dbselectarea('Paysked')
       // netlock('A',5)
       Paysked->(dbappend())

       Paysked->brcode  := Paytsked->brcode
       Paysked->Acctno  := Paytsked->Acctno
       Paysked->Paynum  := Paytsked->Paynumber
       Paysked->Paydate := Paytsked->Paydate
       Paysked->Amort   := Paytsked->Amort
       Paysked->(dbunlock())
       //
       // Paytsked->(dbdelete())
       //
       Paytsked->(dbskip(+1))
    enddo
       Paysked->(dbcommit())
 endif
*
* ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
* ³      May 5, 2003 abb      Ã¿
* ÀÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ³
*  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*
*
//  if Paytsked->( dbseek(Acctdaly->Acctno) )
 if Paytsked->( dbseek(Acctdaly->brcode+Acctdaly->Acctno) )  // abb 10.18.2004

    do while Paytsked->Acctno == Acctdaly->Acctno .and. ;
             Paytsked->brcode == ACCTDALY->BRCODE .and. ;         && RED 031105 REPLACED 'g_PAR_BRCH
            !Paytsked->(eof())

       Payimage->(dbappend())
       Payimage->brcode  := Paytsked->brcode
       Payimage->Paynum  := Paytsked->Paynumber
       Payimage->Acctno  := Paytsked->Acctno
       Payimage->Paydate := Paytsked->Paydate
       Payimage->amort   := Paytsked->Amort

       Paytsked->(dbdelete())
       Paytsked->(dbskip(+1))

    enddo

    Payimage->(dbunlock())
    Payimage->(dbcommit())

 endif

restdbf(mu)
@ 24,00 say repl( ' ',79 )
return nil

   // generate schedule of depreciation (for leasing facility only)
/***************************/
static Function gen_lcr()
/***************************/
 local mu:=savedbf(),mallow:=eval( { || chckalow(Acctdaly->Asetcode) } )
 local mDeptot:=0,i
 center( 24, 'w+*/n', 'þþþþþþþþþþþþ Generating LCR Depreciation þþþþþþþþþþþþ' )
 dbselectarea ( 'Facility' )
 Facility->   ( dbsetorder(1) )
 Facility->   ( dbseek(Acctdaly->fcltycode) )

 if Facility->SETCODE = '1'      // generate depreciation here

    mDepdate := Acctdaly->Valdate
    mDay     := substr( dtoc ( mDepdate),4,2)
    mMonth   := month ( mDepdate )
    mYear    := year  ( mDepdate )

    _update_Lcr_Head()
    for i:= 1 to mallow
        Lcrdepn->(dbappend())
        Lcrdepn->brcode    := Acctdaly->brcode
        Lcrdepn->Acctno    := Acctdaly->Acctno
        Lcrdepn->Monthno   := i
        Lcrdepn->Depamount := getamount( i, mallow )
        Lcrdepn->Depdate   := mdepdate
        mDeptot += Lcrdepn->Depamount
        mDepdate := getnextdate ( mDepdate )
        Lcrdepn-> ( dbcommit() )
    next i

    mFuldep := Acctdaly->Principal - ( Acctdaly->Principal * (Acctdaly->RV/100) )
    if mDeptot <> mFuldep
       mLess := mFuldep - mDeptot
       Lcrdepn->Depamount := Lcrdepn->Depamount + ( mLess )
       Lcrdepn->(dbcommit())
    endif

 endif
 restdbf(mu)
 @ 24,00 say repl(' ',79 )
return nil

**********************************
*
static function _update_Lcr_Head()        // ABB ( July 21, 1999 )
**********************************
   if Lcrhead->(netlock('A',0))
      Lcrhead->brcode    := Acctdaly->brcode // abb 10.18.2004
      Lcrhead->acctno    := Acctdaly->acctno
      Lcrhead->clntcode  := Acctdaly->clntcode
      Lcrhead->principal := Acctdaly->principal
      Lcrhead->term      := Acctdaly->term
      Lcrhead->purcamt   := Acctdaly->purcamt
      Lcrhead->user_id   := Acctdaly->user_id
      Lcrhead->valdate   := Acctdaly->valdate
      Lcrhead->matdate   := Acctdaly->matdate
      Lcrhead->rv        := Acctdaly->rv
      Lcrhead->asetcode  := Acctdaly->asetcode
      Lcrhead->termunit  := Acctdaly->termunit
      Lcrhead->(dbunlock())
   endif
   Lcrhead->(dbcommit())

return nil

*********************************************
*
static function chckalow(mAsetcode)
*********************************************
   local mu:=savedbf(),st,tl,mterm
   if Acctdaly -> TERMUNIT == '1'
      mterm := int(Acctdaly->Term / 30) + if( Acctdaly->Term % 30 <> 0,1,0)
   else
      mterm := Acctdaly->term
   endif
   dbselectarea('Asetcode')
   dbsetorder(1)
   dbseek(mAsetcode)
   st := int(Asetcode->Asetlife * 12 * 0.60)
   tl := max(mTerm,st )
   restdbf(mu)
return tl

/*---------------------------------*/
static function getnextdate(mdate)
/*---------------------------------*/
   if month(mdate) + 1 > 12
      mMONTH = (month(mdate) + 1) - 12
      mYEAR  = mYEAR + 1
   else
      mMONTH = month(mdate) + 1
   endif
   do case
      case ltrim(str(mMONTH)) $ '~4~6~9~11' .and. val(mDAY) = 31
	  mdate = ctod(right('00'+ltrim(str(mMONTH)),2) + '/30/' + right(str(mYEAR),4))
      case mMONTH = 2 .and. val(mDAY) > 28
	  if mYEAR/4 == int(mYEAR/4)
	     mdate = ctod(right('00'+ltrim(str(mMONTH)),2) + '/29/' + right(str(mYEAR),4))
	  else
	     mdate = ctod(right('00'+ltrim(str(mMONTH)),2) + '/28/' + right(str(mYEAR),4))
	  endif
      otherwise
	  mdate = ctod(right('00'+ltrim(str(mMONTH)),2) + '/' + mDAY + '/' + right(str(mYEAR),4))
   endcase
   return mdate

/*---------------------------*/
 static function getamount( i,mallowed )
/*---------------------------*/
return( round( ( ( Acctdaly->principal -;
		 ( Acctdaly->principal * Acctdaly->rv / 100 ) ) *;
		 ( mallowed - ( i - 1 ) ) ) /;
	       ( ( mallowed * ( mallowed + 1 ) ) / 2 ), 0 ) )

/*------------------------------------*/
  Function Process_bar( t_rec,c_rec )
/*------------------------------------*/
 //altd()
 @ 14,11 say repl('Û',( c_rec/t_rec) * 60 ) color 'bg+/gr'
 @ 16,66 say trans( c_rec/t_rec * 100, '999.99') color 'w+/n'
return nil

/*---------------------*/
 Function Process_scr( xmess )
/*---------------------*/
 xmess := if( xmess == nil,'Processing, pls. wait..!!!..',xmess )
 fshadow(13,10,15,71,2,'w+/gr')
 @ 14, 11 say repl('±',60 )  color 'w/gr'
 @ 16, 43 say 'Percentage Processed     %' color 'w/n'
 @ 14, 11 say 'Û' color 'bg+/gr'
 @ 24, 00 say repl(' ',80 ) color 'n/w'
 @ 24, 40 - ( len( xmess )/2 ) say xmess color 'n*/w'
Return nil


/*---------------------------*/
 Static Function aMsopenclos()
 local nretval := .f.

 if !NETUSE('&g_AMS_PATH\ACCTMAST',.T.,5)
    return .f.
 endif
 dbclearindex()
 set index to &g_AMS_PATH\acctmast, &g_AMS_PATH\acctclnt, &g_AMS_PATH\acctfa,  &g_AMS_PATH\sureclnt, &g_AMS_PATH\acctsub2, &g_AMS_PATH\acctaonm,;
              &g_AMS_PATH\acctacno, &g_AMS_PATH\acctrev,  &g_AMS_PATH\acctsub, &g_AMS_PATH\acctval,  &g_AMS_PATH\acctfclt,;
              &g_AMS_PATH\acctcdft, &g_AMS_PATH\acctclmt, &g_AMS_PATH\acctday, &g_AMS_PATH\acctmatd

 if !netuse('&g_AMS_PATH\paysked',.t.,5)
    return .f.
 endif
 dbclearindex()
 set index to &g_AMS_PATH\paysked, &g_AMS_PATH\paydsked

 if !netuse('&g_AMS_PATH\payimage',.t.,5)
    return .f.
 endif
 dbclearindex()
 set index to &g_AMS_PATH\payimage

 if !netuse('&g_AMS_PATH\caheader',.t.,5)
    return .f.
 endif
 dbclearindex()
 set index to &g_AMS_PATH\caheader, &g_AMS_PATH\carev, &g_AMS_PATH\caclnt

 if !netuse('&g_AMS_PATH\cadetail',.t.,5)
    return .f.
 endif
 dbclearindex()
 set index to &g_AMS_PATH\cadetail, &g_AMS_PATH\cadetcfl

 if !netuse('&g_AMS_PATH\oticket',.t.,5)
    return .f.
 endif
 dbclearindex()
 set index to &g_AMS_PATH\oticket, &g_AMS_PATH\otclnt

 if !netuse('&g_AMS_PATH\lcrdepn',.t.,5)
    return .f.
 endif
 dbclearindex()
 dbsetindex('&g_AMS_PATH\lcrdepn')

 if !netuse('Parametr',.t.,5)
    return .f.
 *--->      && RED 033005
 ELSE
    IF NETUSE('&g_AMS_PATH\OL_PARAM',.F.,5)
       SET INDEX TO &g_AMS_PATH\OL_PARAM
    ELSE
       RETURN .F.
    ENDIF
 *--->
 endif

 if !netuse('&g_ams_path\amshist',.t.,5)
    return .f.
 endif
 dbclearindex()
 set index to &g_AMS_PATH\Amshist,&g_AMS_PATH\Amshacor,&g_AMS_PATH\Amshrefd

 if !netuse('&g_AMS_PATH\acctdaly',.t.,5)
    return .f.
 endif
 dbclearindex()
 set index to &g_AMS_PATH\acctdaly,;
              &g_AMS_PATH\accdclnt,;
              &g_AMS_PATH\accdsub1,;
              &g_AMS_PATH\accfclty,;
              &g_AMS_PATH\accdname

 if !netuse('&g_AMS_PATH\acctwait',.t.,5)
    return .f.
 endif
 dbclearindex()
 set index to &g_AMS_PATH\acctwait,;
             &g_AMS_PATH\acctwsub,;
             &g_AMS_PATH\acctrecl,;
             &g_AMS_PATH\acctwclt,;
             &g_AMS_PATH\acctref1,;
             &g_AMS_PATH\acctref2

 if !netuse('&g_AMS_PATH\paytsked',.t.,5)
    return .f.
 else
    dbclearindex()
    set index to &g_AMS_PATH\paytsked
 endif

 if !netuse('&g_AMS_PATH\facility',.f.,5)
    return .f.
 endif
 dbclearindex()
 set index to &g_AMS_PATH\fcltycd

 if !netuse('&g_AMS_PATH\asetcode',.f.,5)
    return .f.
 endif
 dbclearindex()
 dbsetindex('&g_AMS_PATH\asetcode')

 if !netuse('&g_AMS_PATH\treview',.t.,5)
    return .f.
 endif
 dbclearindex()
*************8 dbsetindex('treview')
 set index to &g_AMS_PATH\treview,&g_AMS_PATH\Trevref
 set order to 1

 if !netuse('&g_AMS_PATH\review',.t.,5)
    return .f.
 endif
 dbclearindex()

 dbsetindex('&g_AMS_PATH\review')
 dbsetindex('&g_AMS_PATH\review1')

 if !netuse('&g_AMS_PATH\rvspread',.t.,5)
    return .f.
 endif
 dbclearindex()
 dbsetindex('&g_AMS_PATH\rvspread')

 if !netuse('&g_AMS_PATH\udispred',.t.,5)
    return .f.
 endif
 dbclearindex()
 dbsetindex('&g_AMS_PATH\udispred')

 if !netuse('&g_AMS_PATH\udi',.t.,5)
    return .f.
 endif
 dbclearindex()
 dbsetindex('&g_AMS_PATH\udi')

 if !netuse('&g_AMS_PATH\alir',.t.,5)
    return .f.
 endif
 dbclearindex()
 dbsetindex('&g_AMS_PATH\alir')

 if !netuse('&g_AMS_PATH\amsjvh',.t.,5)
    return .f.
 endif
 dbclearindex()
 set index to &g_AMS_PATH\amsjvh,&g_AMS_PATH\amsjvt

 if !netuse('&g_AMS_PATH\amsjvd',.t.,5)
    return .f.
 endif
 dbclearindex()
 set index to &g_AMS_PATH\amsjvd

 if !netuse ( '&g_AMS_PATH\lcrhead',.f.,5 )
    lretval := .f.
 else
    ordlistclear ()
    ordlistadd   ( '&g_AMS_PATH\lcrhead1' )       // acctno + clntcode
    ordlistadd   ( '&g_AMS_PATH\lcrhead2' )       // clntcode + acctno
    ordlistadd   ( '&g_AMS_PATH\lcrhead3' )       // subst(acctno,-5,5)
    lcrhead->   ( dbsetorder(1) )
 endif

 if !netuse('&g_gl_path\tranhead',.t.,5)
    return .f.
 endif
 dbclearindex()
 set index to '&g_gl_path\tranhead', '&g_gl_path\trancode',;
              '&g_gl_path\tranbank','&g_gl_path\trandate' ,;
              '&g_gl_path\Tranlcrj'


   if !netuse ( '&g_GRF_PATH\Ntconfig',.f.,5 )   //    09.14.2004
      return .f.
   endif

 if !netuse('&g_gl_path\trandtls',.t.,5)
    return .f.
 endif
 dbclearindex()
 set index to '&g_gl_path\trandtls', '&g_gl_path\trglcode'

return .t.

***********************************************************************
*
static function __update_udi()    // update udispred exclusive of tax
***********************************************************************
   if Udispred->(dbseek(Acctdaly->brcode+Acctdaly->acctno))

      do while !Udispred->(eof()) .and. ;
                Udispred->acctno == Acctdaly->acctno .and. ;
                Udispred->brcode == Acctdaly->brcode

         Udispred->interest := round ( Udispred->intamt / 1.1, 0 )
         Udispred->vat      := round ( Udispred->intamt / 11 , 0 )

         if Paysked->(dbseek(Acctdaly->brcode+Udispred->acctno+dtos(Udispred->paydate) ))
            Paysked->interest  := round ( Udispred->intamt / 1.1, 0 )
            Paysked->vat       := round ( Udispred->intamt / 11, 0 )
            Paysked->principal := round ( Paysked->amort-Paysked->interest-Paysked->vat, 0 )
         endif

         if Payimage->(dbseek(Acctdaly->brcode+Udispred->acctno+dtos(Udispred->paydate) ))
            Payimage->interest  := round ( Udispred->intamt / 1.1, 0 )
            Payimage->vat       := round ( Udispred->intamt / 11, 0 )
            Payimage->principal := round ( Payimage->amort-Payimage->interest-Payimage->vat, 0 )
         endif

         Udispred->(dbskip(+1))
      enddo
      Udispred ->(dbcommit())
      Paysked  ->(dbcommit())
      Payimage ->(dbcommit())

   endif

return nil


**************************************
*
*
static function _updateNtConfig()
**************************************
   if Ntconfig->(netlock('R',5))
      Ntconfig->seq_check := 7
      Ntconfig->(dbunlock())
      Ntconfig->(dbcommit())
   endif
return nil

//
//
// Eof: AMSC0100.prg //
//
//


