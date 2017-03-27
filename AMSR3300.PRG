/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   program idúúú amsm5000                                                     ³
³   descriptionúú Printing of Expiring Insurance Policies                      ³
³   authorúúúúúúú renan s. evangelista                                         ³
³   dateúúúúúúúúú 8:41:24ú89am úú 10-11-96                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                             u p d a t e s                                    ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        who        ³     when    ³                  why                       ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ janet l. bautista ³ 09-Sep-1998 ³ why are there blank account nos?           ³
³Engr.Michael Espina³ 08-Mar-1999 ³ Additional fields in the inquiry &         ³
³                   ³             ³ must be alpabetically arrange by name      ³
³ janet b. salvador ³ 11-Oct-2000 ³ cut LA no. to 16                           ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
////
#include 'inkey.ch'
#include 'colf.ch'
#include 'dbstruct.ch'
////
#defi K_SPACEBAR   32
#defi microfeed    chr( 27 ) + 'J' + chr( 18 )

memvar  AX_LEVEL, gUSER_ID
private g_save_path := 'c:', lchbr := .t., cACCTNAME, cINSNAME
setcursor(0)

if chkpass( procname(), AX_LEVEL, gUSER_ID )
   begin sequence
	 aOpen9999()
     aMain9999()
   end sequence
   dbcloseall()
endif
__mrelease( '*', .t. )
return nil

/*-------------------------*/
 Static Function aMain9999()
/*-------------------------*/
 local mu:=savescreen(,,,),gf:=savedbf(),bf:=setcursor()
 private mmonth := month(gtrandate), myear := year(gtrandate), dateend:= flag->lastclosed

 fshadow( 8, 30, 11, 47, 2, 'n/g' )
 while eval ({|| setcursor (3), get_month() })
      *repcontrol ('qqqamsincprn()')                            && RED 051605
      xSTR := CHK_PAR(mMONTH) + CHK_PAR(mYEAR)+CHK_PAR(DATEEND)
	  
	  if TRUE_BRCH == '001'
		REPCON_OL ('qqqamsincprn(mmonth,myear,dateend)',,,,,,xSTR,.F.)
		if confirm('Create CSV File?')
			createcsv('qqqAmsincCSV(mmonth,myear,dateend)')
		endif
		exit
	  else
		REPCON_OL ('qqqamsincprn()',,,,,,xSTR,.T.)
		if confirm('Create CSV File?')
			createcsv('qqqAmsincCSV(mmonth,myear,dateend)')
		endif
		exit
	  endif	
	  

 enddo
 * restdbf(gf);restscreen(,,,,mu);setcursor(bf)             && RED 051605
 return nil

/*
/*--------------------*/
 Function Amsincprn()
/*--------------------*/
 local pgn:=1,xdate := cmonth( ctod(str(mmonth,2)+'/01/'+str(myear,4) )) +' '+str(myear,4)

 Headinc(pgn,xdate)
 dbselectarea('Ctrlinfo')
 dbgotop()
 while Ctrlinfo->(!eof())
       if prow() > 52
          __eject()
          pgn++
          SETFONT('UNCONDENSD')
          Headinc(pgn,xdate)
       endif
      plate:=space(20)
       if empty(ctrlinfo->plateno)
          plate:= ctrlinfo->motorno
       elseif empty(ctrlinfo->motorno)
          plate:=ctrlinfo->serialno
       elseif empty(ctrlinfo->serialno)
          plate:=space(20)
       else
          plate:=ctrlinfo->plateno
       endif
    

       if !empty( Ctrlinfo->Insexpry) .and. month(Ctrlinfo->Insexpry) = mmonth .and. year(Ctrlinfo->Insexpry) = myear
          Insuranc->( dbseek(CTRLINFO->BRCODE+Ctrlinfo->Insco, .f.) )
          if Acctmast->( dbseek(CTRLINFO->BRCODE+Ctrlinfo->Acctno,.f.) ) .and. Acctmast->OSBAL > 0   // missing condition, that's why there are blank acct # before!
             @ prow()+1,01 say if(Acctmast->STATUS<>'1','*',' ')+' '+ substr(Acctmast->oldno,1,16)+ ' '+ACCTMAST->BRCODE+'-'+Substr( Acctmast->Acctno,-5,5 )+' '+substr(Acctmast->Acctname,1,29)+'  '+ ;
                         dtoc(Acctmast->Matdate)+'  '+ substr(ctrlinfo->colmodel,1,4)+' '+substr( Ctrlinfo->Coltype,1,29 ) 
             @ prow(), 105+4 say plate
             @ prow(), 126+4 say substr( Insuranc->Insname,1,28)
             @ prow(), 156+4 say Ctrlinfo->Inspolcy
             @ prow(), 179+4 say ctrlinfo->insor
             @ prow(), 189+4 say Dtoc(Ctrlinfo->Insexpry )
             @ prow(), 201+4 say trans(Ctrlinfo->Amtins,'999,999,999.99')
             @ prow(), 216+4 say acctmast->aocode
          endif
       endif
       Ctrlinfo->(dbskip())
 enddo
 __eject()
 return nil
 */

 //ESV 02.01.2016
 /*--------------------*/
 Function qqqAmsincCSV(mmonth,myear,dateend)
/*--------------------*/
 local pgn:=1,xdate := cmonth( ctod(str(mmonth,2)+'/01/'+str(myear,4) )) +' '+str(myear,4)
 local linda5,insured_by:=' '
 local cStatus := "" 

 dbselectarea('Acctmast')
 dbsetorder(2)
 dbgotop()
 setprc(0,0)
 @ 00,00 say '"Account Number","Status","Account Name","Maturity Date","Model","Unit","Plate/Motor/Serial No.","Insurance Company","Insurance Policy No.","Insurance OR","Expiry Date","Insured thru/by","AO","Amount Insured","Insurance Premium","Outstanding Balance"'
 while Acctmast->(!eof())
   IF ACCTMAST->BRCODE == g_PAR_BRCH
      linda5:=ACCTMAST->BRCODE+Acctmast->acctno

      dbselectarea('ctrlinfo')
      dbsetorder(1)
      Ctrlinfo->(dbseek(linda5))

      Do while linda5 = CTRLINFO->BRCODE+ctrlinfo->acctno

          plate:=space(20)
          if empty(ctrlinfo->plateno)
             plate:= ctrlinfo->motorno
          elseif empty(ctrlinfo->motorno)
             plate:=ctrlinfo->serialno
          elseif empty(ctrlinfo->serialno)
             plate:=space(20)
          else
             plate:=ctrlinfo->plateno
          endif

          Do case
             case alltrim(ctrlinfo->insby) == '1'
                  insured_by:= 'Client'
             case alltrim(ctrlinfo->insby) == '2'
                  insured_by:= 'Colf'
             case alltrim(ctrlinfo->insby) == '3'
                  insured_by:= 'Dealer'
          Endcase

          if !empty( Ctrlinfo->Insexpry) .and. month(Ctrlinfo->Insexpry) = mmonth .and. year(Ctrlinfo->Insexpry) = myear  .and. Acctmast->OSBAL > 0
               Insuranc->( dbseek(CTRLINFO->BRCODE+Ctrlinfo->Insco, .f.) )
                Do Case
                   Case Acctmast->Status == "1"
                        cStatus := "A"
                   Case Acctmast->Status == "2"
                        cStatus := "P"
                   Case Acctmast->Status == "3"
                        cStatus := "I"
                   Case Acctmast->Status == "4"
                        cStatus := "R"
                   Case Acctmast->Status == "5"
                        cStatus := "W"
                EndCase
				cACCTNAME := Acctmast->acctname
				cACCTNAME := strtran(cAcctName,",","")
				cACCTNAME := strtran(cAcctName,"'","")
				cACCTNAME := strtran(cAcctName,'"','')
				
				cINSNAME  := Insuranc->insname
				cINSNAME := strtran(cINSNAME,",","")
				cINSNAME := strtran(cINSNAME,"'","")
				cINSNAME := strtran(cINSNAME,'"','')
				
				cCOLTYPE  := Ctrlinfo->coltype
				cCOLTYPE := strtran(cCOLTYPE,",","")
				cCOLTYPE := strtran(cCOLTYPE,"'","")
				cCOLTYPE := strtran(cCOLTYPE,'"','')

			//	@ prow()+1,01 say if(Acctmast->STATUS<>'1','*',' ')+' '+substr(Acctmast->oldno,11,5)
				@ prow()+1, 00      say '"' + alltrim(Acctmast->brcode+substr(Acctmast->acctno,-5,5)) + '",' 
				@ prow()+0,pcol()+1 say '"' + alltrim(cStatus) + '",'
				@ prow()+0,pcol()+1 say '"' + alltrim(cACCTNAME) + '",'
				@ prow()+0,pcol()+1 say '"' + dtoc(Acctmast->matdate) + '",'
				@ prow()+0,pcol()+1 say '"' + substr(Ctrlinfo->colmodel,1,4) + '",'
				@ prow()+0,pcol()+1 say '"' + alltrim(cCOLTYPE) + '",'
				@ prow()+0,pcol()+1 say '"' + alltrim(plate) + '",'
				@ prow()+0,pcol()+1 say '"' + alltrim(cINSNAME) + '",'
				@ prow()+0,pcol()+1 say '"' + alltrim(Ctrlinfo->inspolcy) + '",'
				@ prow()+0,pcol()+1 say '"' + alltrim(Ctrlinfo->insor) + '",'
				@ prow()+0,pcol()+1 say '"' + dtoc(Ctrlinfo->insexpry) + '",'
				@ prow()+0,pcol()+1 say '"' + alltrim(insured_by) + '",'
				@ prow()+0,pcol()+1 say '"' + alltrim(Acctmast->aocode) + '",'
				@ prow()+0,pcol()+1 say alltrim(str(Ctrlinfo->amtins)) + ','
				@ prow()+0,pcol()+1 say alltrim(str(Ctrlinfo->insprem)) + ','
				nOSB := _get_outs(mmonth,myear,dateend)
				@ prow()+0,pcol()+1 say alltrim(str(nOSB)) //+ chr(13)
			
          endif

          Ctrlinfo->(dbskip())
      Enddo
   ENDIF
   Acctmast->(dbskip())
 Enddo
 __eject()
 return nil
 
/* This module is loving dedicated to LUL */

/*--------------------*/
 Function qqqAmsincprn(mmonth,myear,dateend)
/*--------------------*/
 local pgn:=1,xdate := cmonth( ctod(str(mmonth,2)+'/01/'+str(myear,4) )) +' '+str(myear,4)
 local linda5,insured_by:=' '
 local cStatus := ""       && *---> red 092004

 Headinc(pgn,xdate,dateend)
 dbselectarea('Acctmast')
 dbsetorder(2)
 dbgotop()
 while Acctmast->(!eof())
   IF ACCTMAST->BRCODE == g_PAR_BRCH      && RED 031705
      linda5:=ACCTMAST->BRCODE+Acctmast->acctno

      dbselectarea('ctrlinfo')
      dbsetorder(1)
      Ctrlinfo->(dbseek(linda5))

      Do while linda5 = CTRLINFO->BRCODE+ctrlinfo->acctno

          if prow() > 52
             __eject()
             pgn++
             SETFONT('UNCONDENSD')
             Headinc(pgn,xdate,dateend)
          endif
          plate:=space(20)
          if empty(ctrlinfo->plateno)
             plate:= ctrlinfo->motorno
          elseif empty(ctrlinfo->motorno)
             plate:=ctrlinfo->serialno
          elseif empty(ctrlinfo->serialno)
             plate:=space(20)
          else
             plate:=ctrlinfo->plateno
          endif

          Do case
             case alltrim(ctrlinfo->insby) == '1'
                  insured_by:= 'Client'
             case alltrim(ctrlinfo->insby) == '2'
                  insured_by:= 'Colf'
             case alltrim(ctrlinfo->insby) == '3'
                  insured_by:= 'Dealer'
          Endcase

          if !empty( Ctrlinfo->Insexpry) .and. month(Ctrlinfo->Insexpry) = mmonth .and. year(Ctrlinfo->Insexpry) = myear  .and. Acctmast->OSBAL > 0
               Insuranc->( dbseek(CTRLINFO->BRCODE+Ctrlinfo->Insco, .f.) )
            // if Acctmast->( dbseek(Ctrlinfo->Acctno,.f.) ) .and. Acctmast->OSBAL > 0   // missing condition, that's why there are blank acct # before!
   //             @ prow()+1,01 say if(Acctmast->STATUS<>'1','*',' ')+' '+ substr(Acctmast->oldno,1,16)+ ' '+Substr( Acctmast->Acctno,-5,5 )+' '+substr(Acctmast->Acctname,1,29)+'  '+ ;
   //                         dtoc(Acctmast->Matdate)+'  '+ substr(ctrlinfo->colmodel,1,4)+' '+substr( Ctrlinfo->Coltype,1,29 )

                *---> RED ADDED 0902004
                Do Case
                   Case Acctmast->Status == "1"
                        cStatus := "A"
                   Case Acctmast->Status == "2"
                        cStatus := "P"
                   Case Acctmast->Status == "3"
                        cStatus := "I"
                   Case Acctmast->Status == "4"
                        cStatus := "R"
                   Case Acctmast->Status == "5"
                        cStatus := "W"
                EndCase

                @ prow()+1,01 say if(Acctmast->STATUS<>'1','*',' ')+' '+substr(Acctmast->oldno,11,5)
                @ prow(),  08 say ACCTMAST->BRCODE+'-'+Substr( Acctmast->Acctno,-5,5 )
                @ prow(),  17+4 say cStatus
                @ prow(),  21+4 say substr(Acctmast->Acctname,1,40)
                @ prow(),  62+4 say dtoc(Acctmast->Matdate)
                @ prow(),  74+4 say substr(ctrlinfo->colmodel,1,4)
                @ prow(),  79+4 say substr(Ctrlinfo->Coltype,1,35)
                @ prow(), 115+4 say LEFT(plate,15)
                @ prow(), 131+4 say substr( Insuranc->Insname,1,35)
                @ prow(), 167+4 say LEFT(Ctrlinfo->Inspolcy,20)
                @ prow(), 188+4 say ctrlinfo->insor
                @ prow(), 199+4 say Dtoc(Ctrlinfo->Insexpry)
                @ prow(), 211+4 say insured_by
                @ prow(), 218+4 say acctmast->aocode
                @ prow(), 224+4 say trans(Ctrlinfo->Amtins, '999,999,999.99')
                @ prow(), 239+4 say transform(Ctrlinfo->insprem, '999,999,999.99')
				@ prow(), 254+4 say transform(_get_outs(mmonth,myear,dateend), '999,999,999.99')

                /* ---> RED REMOVED 092004
                @ prow()+1,01 say if(Acctmast->STATUS<>'1','*',' ')+' '+ substr(Acctmast->oldno,11,5)+ ' '+Substr( Acctmast->Acctno,-5,5 )+' '+substr(Acctmast->Acctname,1,29)+'  '+ ;
                            dtoc(Acctmast->Matdate)+'  '+ substr(ctrlinfo->colmodel,1,4)+' '+substr( Ctrlinfo->Coltype,1,20 )
                @ prow(),  84 say plate
                @ prow(), 105 say substr( Insuranc->Insname,1,28)
                @ prow(), 135 say Ctrlinfo->Inspolcy
                @ prow(), 157 say ctrlinfo->insor
                @ prow(), 168 say Dtoc(Ctrlinfo->Insexpry )
                @ prow(), 180 say trans(Ctrlinfo->Amtins, '999,999,999.99')
                @ prow(), 196 say acctmast->aocode
                @ prow(), 192 say insured_by
                @ prow(), 200 say transform(Ctrlinfo->insprem, '999,999,999.99')
                if Client->(dbseek(acctmast->clntcode))
                  @ prow(), 200 say client->address1
                  @ prow(), 210 say client->contact
                endif
                */
            // endif
          endif

          Ctrlinfo->(dbskip())
      Enddo
   ENDIF
   Acctmast->(dbskip())
 Enddo
 __eject()
 return nil



/*-------------------------*/
 static function aOpen9999()
/*-------------------------*/
memvar gSYS_NAME, gUSER_ID, gTRANDATE, mFMS0700

if !netuse( '&g_AMS_PATH\Acctmast', .f., 10 )              && Account master file
   break
else
   set index to &g_AMS_PATH\Acctmast,;
                &g_AMS_PATH\Acctacno
/*   if !.f.; ordlistclear(); endif
   ordlistadd( 'Acctmast' )                     && set index on acctno
   ordlistadd( 'Acctsub2')                      && set index on substr(acctno,-5,5)
   ordlistadd( 'Acctclnt')
   ordlistadd( 'Acctacno')  */
endif

if !netuse( '&g_AMS_PATH\Ctrlinfo', .f., 10 )              && Insurance information file
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_AMS_PATH\Ctrlinfo' )                    && set index on acctno
endif

if !netuse( '&g_AMS_PATH\AMSHIST', .f., 10 )              && Insurance information file
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_AMS_PATH\AMSHIST' )                    && set index on acctno
endif

if !netuse( '&g_AMS_PATH\AMSBACK\AMSHIST2', .f., 10 )              && Insurance information file
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_AMS_PATH\AMSBACK\AMSHIST2' )                    && set index on acctno
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


if !NETUSE('&g_CIS_PATH'+'\CLIENT',.f.,5)   && CLIENT MASTER file
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_CIS_PATH\CLIECD' )                     && set index on clntcode
   ordlistadd( '&g_CIS_PATH\CLIENM' )                     && set index on Fullname
endif

if !netuse( '&g_AMS_PATH\Flag',.f.,5)
   return
end if

/*
/*------------------------*/
 Static function get_month()
/*------------------------*/
   local mretval := .t., getlist := {}, mcolor := setcolor()
   memvar mmonth, myear, dateend 
 setcolor( 'n/g,w+/n,,, w+/g' )
   @  8, 31 say 'Transaction Date'                color 'w+/g'
   @  9, 32 say 'Month '
   @ 10, 32 say ' Year '
   @  9, 42 get mmonth pict '99'   when  select_month( @mmonth, 9, 46, 18, 56 )
   @ 10, 41 get myear  pict '9999' valid myear > 1970
   setkey(K_ESC ,{ || fescape( 'Abort?' ) } )   
   read
   setkey(K_ESC, nil)
   setcolor( mcolor )

   
dateend := flag->lastclosed        

@ 011,20 clear to 14,60
@ 011,20 to 14,60
@ 12,21 say 'Outstanding Balance As Of: ' get dateend pict '@D' valid !empty(dateend) 
@ 13,21 say '*Given date is as of last closing date.' color 'w+/bg'
//@ 14,21 say ' closing date.' color 'w+/bg'
setkey(K_ESC ,{ || fescape( 'Abort?' ) } )   
read
setkey(K_ESC, nil)

return lastkey() != K_ESC

****************************
*
static function _get_outs(mmonth,myear,dateend) // RLV 3:56 PM 3/5/2009
****************************
   local nretval := Acctmast->credamt, ddate := ctod ('')
   local dretval := ctod('')
   local pgn:=1
   local tot_amrt := 0, tot_pen := 0, npent_s := 0,ncredamt:= Acctmast->Credamt
   local Pay_:={ 'Paymt',;              // 1
                 'Ret. Check',;         // 2
                 'ROPOA',;              // 3
                 'Db_Memo ',;           // 4
                 'Misposting',;         // 5
                 'Terminatx',;          // 6
                 'Cr_Memo  ',;          // 7
                 'REVIEW ',;            // 8
                 ' ',;                  // 9
                 'O_T Check',;          //10
                 'PDR ',;               //11
                 'LEGAL ',;             //12
                 'LEGAL ',;             //13
                 'Current',;            //14
                 'Current',;            //15
                 'Balance Forwarded' }  //16
   local tot_or:=0, tot_am := 0, tot_penal := 0
   local xoramount := xamort := xpenal:=0,pprd:={},pperiod,unpd_pen := 0
   local xacctno,xornum,xrefdate,xcode,nrow:= { 05,19,32,43,60,86,93,117 }, xBRCODE


//aga.26.04.2006.removed for delinquency reengineering
//   xblk := { || Paysked->Lastpay <= pdate }

//   Amshist->  ( dbseek(ACCTMAST->BRCODE+Acctmast->Acctno) )
if Amshist->  ( dbseek(ACCTMAST->BRCODE+Acctmast->Acctno) )
   ncredamt := Acctmast->Credamt

   do while AMSHIST->BRCODE+Amshist->Acctno == ;                           && RED 031105 ADDED '->BRCODE
            ACCTMAST->BRCODE+Acctmast->Acctno .and. !Amshist->(eof()) .and. AMSHIST->REFDATE <= dateend //ctod(str(mmonth)+'/'+str(__days(mmonth,myear))+'/'+str(myear))	     && RED 031105 ADDED '->BRCODE

		 xrefdate  := Amshist->Refdate
         xornum    := Amshist->Ornumber
         xacctno   := Amshist->Acctno
         xcode     := Amshist->Paycode
         xBRCODE   := AMSHIST->BRCODE     && RED 031105
         unpd_pen  += Amshist->Unpd_pnlty

		 
         do while Amshist->Acctno   == xAcctno  .and. ;
                  Amshist->Ornumber == xornum   .and. ;
                  Amshist->Refdate  == xrefdate .and. ;				  
                  Amshist->Paycode  == xcode    .and. ;
                  AMSHIST->BRCODE   == xBRCODE  .AND. ;
                 !Amshist->(eof())

        
               xamort    += Amshist->Amort
            
		
             Amshist->(dbskip(+1))
         enddo
		nretval -= (xamort)	 
		xamort := xpenal:=0
   enddo
endif

//   Amshist2->  ( dbseek(ACCTMAST->BRCODE+Acctmast->Acctno) )    && RED 031105 ADDED 'ACCTMAST->BRCODE+
if Amshist2->  ( dbseek(ACCTMAST->BRCODE+Acctmast->Acctno) )    && RED 031105 ADDED 'ACCTMAST->BRCODE+

   ncredamt := Acctmast->Credamt

   do while AMSHIST2->BRCODE+AMSHIST2->Acctno == ;                           && RED 031105 ADDED '->BRCODE
            ACCTMAST->BRCODE+Acctmast->Acctno .and. !AMSHIST2->(eof())  .and. AMSHIST->REFDATE <= dateend //ctod(str(mmonth)+'/'+str(__days(mmonth,myear))+'/'+str(myear))    && RED 031105 ADDED '->BRCODE
         xrefdate  := AMSHIST2->Refdate
         xornum    := AMSHIST2->Ornumber
         xacctno   := AMSHIST2->Acctno
         xcode     := AMSHIST2->Paycode
         xBRCODE   := AMSHIST2->BRCODE     && RED 031105
         unpd_pen  += AMSHIST2->Unpd_pnlty

         do while AMSHIST2->Acctno   == xAcctno  .and. ;
                  AMSHIST2->Ornumber == xornum   .and. ;
                  AMSHIST2->Paycode  == xcode    .and. ;
                  AMSHIST2->BRCODE   == xBRCODE  .AND. ;
                 !AMSHIST2->(eof())

             //if month(xrefdate) = mmonth .and. year(xrefdate) = myear
                xamort    += AMSHIST2->Amort
            // endif

             AMSHIST2->(dbskip(+1))
         enddo
	nretval -= (xamort)
	xamort := xpenal:=0
   enddo
endif 

return NRETVAL

*******************************
*
static function __days(mmonth,myear) // RLV 3:56 PM 3/5/2009
*******************************

local nretval := 0

if  mmonth == 1 .or. mmonth == 3 .or. mmonth == 5 .or. mmonth == 7 .or. mmonth == 8 .or. mmonth == 10 .or. mmonth == 12
	nretval := 31
else
	if  mmonth == 4 .or. mmonth == 6 .or. mmonth == 9 .or. mmonth == 11
		nretval := 30
	else
		nretval := 29
	endif
endif


return nretval



*/
/*-----------------------------------*/
 STatic Function Headinc(pgn,xdate,dateend)
/*-----------------------------------*/

SETFONT('NORMAL')   && *---> RED 092004
setprc(0,0)
setfont('DRAFT')
setfont('ELITE')
@ prow()+1,03 say 'ACCOUNT MANAGEMENT SYSTEM'
@ prow(),  03+len('ACCOUNT MANAGEMENT SYSTEM');
              say PADL('Page No. ' + tran(pgn,'999'),150-len('ACCOUNT MANAGEMENT SYSTEM'))  &&157-len('ACCOUNT MANAGEMENT SYSTEM')) *---> red 092004
@ prow()+1,03 say 'AMSR3300'
@ prow()  ,03+len('AMSQ9999');
              say PADL( dtoc(DATE())+' '+TIME(),150-len('AMSQ1000'))   &&157-len('AMSQ1000')) *---> red 092004
@ prow()+1,03 say PADC('ORIX METRO LEASING AND FINANCE CORPORATION',150)  &&157) *---> red 092004
SETFONT('BOLD')
@ prow()+1,03 say padc('LIST OF EXPIRING INSURANCE POLICIES',150)  &&157) *---> red 092004
SETFONT('UNBOLD')
@ prow()+1,03 say padc('For the Month of '+ xdate,150)  &&157) *---> red 092004
@ prow()+1,03 say padc('Outstanding Balance is As Of '+ dtoc(dateend),150)
@ prow()+1,03 say ''
setfont('ELITE')
SETFONT('CONDENSED')

*---> red 092004
*@ prow()+1,3 say 'ÄÄÄÄÄ ÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄ ÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
*@ prow()+1,3 say 'LA N§  Acct    Status            Account Name             Maturity  Model        Unit            Plate / Motor N§         Insurance Company        Insurance Policy N§  Insurance    Expiry    INSURED  AO      Amount         INSURANCE'
*@ prow()+1,3 say '       No.                                                  date                                    Serial N§                                                               OR        Date     THRU/BY         Insured          PREMIUM'
*@ prow()+1,3 say 'ÄÄÄÄÄ ÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄ ÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
@ prow()+1,2 say 'ÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄ ÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
@ prow()+1,2 say 'LA N§  Acct N§  Status            Account Name                  Maturity   Model              Unit                   Plate/Motor N§           Insurance Company          Insurance Policy N§  Insurance    Expiry   INSURED  AO      Amount        INSURANCE      OUTSTANDING'
@ prow()+1,2 say '                                                                  date                                                  Serial N§                                                                 OR        Date    THRU/BY         Insured         PREMIUM         BALANCE'	
@ prow()+1,2 say 'ÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄ ÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
/* ---> red 092004            S      1234567891123456789212345678931234567894 1234567890  1234567891123456789212345678931234567894 123456789112345 12345678911234567892123456789312345 12345678911234567892                                                                                                           
@ prow()+1,3 say 'ÄÄÄÄÄ ÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄ ÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ' 
@ prow()+1,3 say 'LA N§  Acct        Account Name             Maturity  Model            Unit      Plate / Serial           Insurance Company            Policy Number       Insurance   Expiry       Amount       AO   INSURED    INSURANCE             ADDRESS                  CONTACT'
@ prow()+1,3 say '       No.                                     date                                 Motor No.                                                                  OR       Date        Insured             BY        PREMIUM'                                                       
@ prow()+1,3 say 'ÄÄÄÄÄ ÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄ ÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
*/

//@ prow()+1,3 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄ ÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ' 
//@ prow()+1,3 say '  LA Number       Acct        Account Name             Maturity  Model            Unit                Plate / Serial           Insurance Company            Policy Number       Insurance   Expiry       Amount       AO   INSURED    INSURANCE       ADDRESS       CONTACT'
//@ prow()+1,3 say '                  No.                                     date                                           Motor No.                                                                  OR       Date        Insured             BY        PREMIUM'                                                       
//@ prow()+1,3 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄ ÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
/*
/*------------------------------------*/
 static function select_month ( mmonth )
/*------------------------------------*/
return eval( { | x, y, z | x := setcolor(), y := savescreen( ,,, ),;
                          fshadow( 9, 46, 18, 56, 2, 'w/gr' ),;
                          devpos( 10, 49 ), devout( 'Month', 'bg+/gr' ),;
                          devpos( 11, 46 ) , devout( 'ÃÄÄÄÄÄÄÄÄÄ´', 'w/gr' ),;
                          setcolor( 'w/gr, w+/n,,, n/gr' ),;
                          z := achoice( 12, 47, 17, 55,;
                               { 'January', 'February', 'March', 'April',;
                                 'May', 'June', 'July', 'August', 'September',;
                                 'October', 'November', 'December' },,, mmonth ),;
                          setcolor( x ), restscreen( ,,,, y ), mmonth := if( z == 0, mmonth, z ), .f. } )
*/
/*       1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6
1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123
  ÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  Acct        Account Name              Maturity               Unit                    Insurance Company            Policy Number       Expiry    Amount Insured
  N§                                       date                                                                                            Date
  ÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  99999 XXXXXXXXXXXXXXXXXXXXXXXXXXXXX  99/99/9999  XXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXX  99999999999999999999  99/99/9999  999,999,999.99


 Account Number/Name : 
 Received by         : AAAAAAAAAAAAAAAA X. BBBBBBBBBBBBBBBBBBBB
*/

****************************
function createcsv(procfunc)
****************************
private loverwrite := .t.//, 
savepath := g_save_path+'\'+space(20)
begin sequence
	if __savepath()
		if(loverwrite,eval( { | n |  n := savescreen( ,,, ),;
			if(logrep('IN',savepath),get_copy(procfunc),__keyboard(chr(K_ESC))),;
			logrep('OUT',savepath),;
			restscreen( ,,,, n ) ;
			} ),__keyboard(chr(K_ESC)))	
	endif
end sequence
return .t.

*********************
function __savepath()
*********************
n := savescreen( ,,, )
	fshadow(11,30,13,30+len(savepath)+1,,,' Save Path ')
	//fShadow    ( 10, 40, 14, 71, 2,,' Signatories ' )
	@ 12, 31 get savepath valid eval({||! empty(savepath) .and. if(file(savepath),if(confirm(alltrim(savepath)+' is already exist..Do you want to overwrite?'),ferase(savepath),loverwrite := .f.),.t.),if(lastkey() == K_ESC,__keyboard(chr(K_ESC)),) ,.t.}) 
	setcursor(3)
		read
	setcursor(0)
	if lastkey() == K_ESC
		return .f.
	endif
	if len(alltrim(savepath)) == len(alltrim(g_save_path))+1
		Alert('Enter File Name')
		return .f.
	endif
	restscreen( ,,,, n )
	return .t.
	
**************************
function get_copy(procfunc)
**************************
	// if lchbr 
		// waiton( 'Generating CSV ['+alltrim(tmpbrdisp[nget])+']',, 'n*/+w' )
	// else
		waiton( 'Generating CSV',, 'n*/+w' )
//	endif
         set printer to &savepath.
         set device to printer
		 eval( &('{ ||' + procfunc + '}' ) )
         set printer to
         set device to screen
         waitoff()
		 error('file is already generated at '+alltrim(savepath))
	return __keyboard(chr(K_ESC))
	
	
**********************
function logrep(nstat,savepath)
**********************
memvar repcnt
/* do case
	case upper(nstat) == 'IN'
		if !netuse( '&g_CSV_PATH\replog', .f., 10 )
   			break
		else
			set index to &g_csv_path\replog
		endif
		if replog->(netlock('A',3))
			replace replog->wstation   with NETNAME()
         replace replog->brcode  with TRUE_BRCH
         REPLACE replog->user   WITH g_USER_ID
			REPLACE replog->datestart   WITH date()
			REPLACE replog->dateend   WITH CTOD(' ')
			REPLACE replog->timestart   WITH time()
			REPLACE replog->timeend   WITH ' '
			REPLACE replog->report   WITH _get_proc()
		replog->(DBCOMMIT())
		replog->(DBUNLOCK())
		endif
		repcnt := replog->(recno())
		replog->(dbclosearea())
		return .t.
	case  upper(nstat) == 'OUT'
		if !netuse( '&g_CSV_PATH\replog', .f., 10 )
   		break
		else
			set index to &g_csv_path\replog
		endif
		replog->(dbgoto(repcnt))
		if replog->(netlock('R',3))
			REPLACE replog->dateend   WITH date()
			REPLACE replog->timeend   WITH time()
			REPLACE replog->rep_save WITH savepath
		replog->(DBCOMMIT())
		replog->(DBUNLOCK())
		endif
		replog->(dbclosearea())
		return .t.
	otherwise
		return .f.
endcase */

return .t.


/* ***************************
static function _get_proc()
***************************
local retval
memvar g_procname

if netuse('&g_csv_path\csvmenu',.f.,5)
	do while !csvmenu->(eof()) .and. upper(csvmenu->block) != upper(g_procname)+'()'
		csvmenu->(dbskip())
	enddo
retval := strtran(csvmenu->prompt,'~','')
endif
csvmenu->(dbclosearea())
return retval */
