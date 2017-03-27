/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   colf-iis -- account management system                                      ³
³   program idúúú amsr3600                                                     ³
³   description ..... Monthly Execution report                                 ³
³   authorúúúúúúú Engr. Michael B. Espina                                      ³
³   dateúúúúúúúúú August 8, 1999 4:00 p.m.                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                             u p d a t e s                                    ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        who        ³       when        ³               why                    ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                   ³                   ³                                      ³
³ abb               ³  07.28.04         ³  replace docstamps rate from         ³
³                   ³                   ³   .15% to .50 %       line 300       ³
³ abb               ³  11.09.2005       ³ removed rv in total receivables      ³
³                   ³                   ³ formula                              ³
³ mts               ³  09.05.2007       ³ removed hard coded fclty codes &     ³
³		    ³			³ added client counter		       ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include 'inkey.ch'
#include 'colf.ch'
#include 'dbstruct.ch'
////
#defi K_SPACEBAR   32
#defi microfeed    chr( 27 ) + 'J' + chr( 18 )

memvar  AX_LEVEL, gUSER_ID
private TLS_NAF,TLN_NAF,TP_NAF,choice,cRESTR

setcursor(0)

if chkpass( procname(), AX_LEVEL, gUSER_ID )
   begin sequence
         aOpen3600()
         aMain3600()
   end sequence
   dbcloseall()
endif
__mrelease( '*', .t. )
return nil

/*-------------------------*/
 Static Function aMain3600()
/*-------------------------*/
 local mu:=savescreen(,,,),gf:=savedbf(),bf:=setcursor()
 private mmonth := month(gtrandate), myear := year(gtrandate)

 fshadow( 8, 30, 11, 47, 2, 'n/g' )
 Do case
    case g_user_id = 'MBE'
         name:= 'Mike Gwapo'
    case g_user_id = 'LUL'
         name:='Linda'
    otherwise
         name:=' '
 Endcase

 while eval ({|| setcursor (3), get_month() })
       if confirm('Print Report with WATR ' + name)
          choice:=1
       else
          choice:=2
       endif
       get_branches()
	   if confirm('Include restructured accounts?')
			cRESTR := 1
	   else
			cRESTR := 2
	   endif
       IF TRUE_BRCH == '001'                                   && RED 042206
          ams3600 := crea_xtemp()
          if !file(ams3600+'.DBF')
             dbcreate( ams3600,{ {'ACCTNO'  ,'C',14,00}, ;
                                 {'CLNTCODE','C',07,00}, ;
                                 {'FACILITY','C',01,00}, ;
                                 {'BRCODE'  ,'C',03,00}  })
          endif
          if !netuse('&ams3600',.F.,0)
             break
          endif
       ENDIF

       *--->                                                      RED 042205
       *repcontrol('get_amsr3600()')
       xSTR := CHK_PAR(mMONTH) + CHK_PAR(mYEAR) + CHK_PAR(CHOICE)    +;
               CHK_PAR(TLS_NAF) + CHK_PAR(TLN_NAF) + CHK_PAR(TP_NAF) +;
               CHK_PAR(gSYS_NAME) + CHK_PAR(gCOMPANY) + CHK_PAR(cRESTR)

       REPCON_OL('get_amsr3600()',,,,,,xSTR,.T.)
       *--->

       IF TRUE_BRCH == '001'                                   && RED 042206
          close &ams3600
          ferase( ams3600 + '.DBF')
          ferase( ams3600 + '.NTX')
       ENDIF
 Enddo
 restdbf(gf);restscreen(,,,,mu);setcursor(bf)
 return nil

***********************************************
/* This module is lovingly dedicated to Linda my loves */
function get_amsr3600()
***********************************************
 local ca_ot_num:=0, ST_NAF:=array(3), xrecno:=0, x:=0, linda:= ' '
 local T_PRPL:=0, T_NAF:=0, T_TRCV:=0, net:=0
 local WATR:=0, PRCNT:=0, T_WATR:=0, T_PRCNT:=0
 local lul:=0, docstamps:=0, T_DOC:=0
 memvar TLS_NAF, TLN_NAF, TP_NAF, choice
 PRIVATE NCTR := 0,NCTR2 := 0,NCTR3 := 0

     afill (ST_NAF,0 )

     select acctmast
//     go top
     dbseek(g_PAR_BRCH)    // abb 12.20.2004

     ACCTBRCODE := space(len(g_PAR_BRCH)) // abb 12.20.2004

     Do while acctmast->(!eof()) .and. Acctmast->brcode == g_PAR_BRCH
        f_code:=acctmast->fcltycode

        if month(acctmast->valdate) = mmonth .and. ;
           year(acctmast->valdate) = myear  .and. Acctmast->STATUS  != '0' // CANCELLED RLV 08.18.2010 //  .and. acctmast->osbal > 0

           acctnum    := acctmast->acctno
           acctclnt   := acctmast->clntcode
           ACCTBRCODE := ACCTMAST->BRCODE

	   if cRESTR == 2
			if f_code == '10310' .or. f_code == '10410'
				Acctmast->(dbskip())
				loop
			endif
	   endif
	   IF facility->(dbseek(f_code))		//PEPE
	      acctfclty  := facility->fcltygrp		
	   ELSE
	      error('FACILITY CODE not found')
	   ENDIF

           dbselectarea ( '&ams3600' )
           append blank
           replace acctno   with acctnum
           replace clntcode with acctclnt
           REPLACE BRCODE   WITH ACCTBRCODE
           REPLACE facility WITH acctfclty		//pepe

/**********************************************
           if     f_code = '10301' .or. ;
                  f_code = '10302' .or. ;
		  f_code = '10303'
              replace facility with '1'       // FOR LEASE FACILITY
           elseif f_code = '10401'    .or. ;
                  f_code = '10407'    .or. ;
                  f_code = '10408'    .or. ;
                  f_code = '10410'    .or. ;
                  f_code = '10412'

              replace facility with '2'       // FOR LOAN FACILITY
           elseif f_code = '10402'    .or. ;
                  f_code = '10403'    .or. ;
                  f_code = '10404'    .or. ;
                  f_code = '10405'    .or. ;
                  f_code = '10406'    .or. ;
                  f_code = '10409'    .or. ;
                  f_code = '10411'   
              replace facility with '3'       // FOR RECEIVABLES PURCHASED
           else
              replace facility with '4'
           endif
        endif
**********************************************/

	  IF FACILITY    == '1'
		NCTR++	
	  ELSEIF FACILITY == '2'
		NCTR2++
	  ELSEIF FACILITY == '3'
		NCTR3++
	  ENDIF



        endif

        select acctmast
        acctmast->(dbskip(+1))
     enddo
     
     dbselectarea ( '&ams3600' )
     index on FACILITY to &ams3600

     &ams3600->(dbgotop())
     xflag := 0
     do while &ams3600->(!eof())

        xflag++
        xflag2 := str(xflag)
        Do while alltrim(&ams3600->facility) == alltrim(xflag2) .and. ;
                         &ams3600->(!eof())

           actnum    := &ams3600->acctno
           ACTBRCODE := &AMS3600->BRCODE
           acctmast->(dbsetorder(2))
           acctmast->(dbseek(ACTBRCODE+actnum))

           do case
              case xflag == 1  // LEASE
                   NAF := ((acctmast->principal)-((acctmast->principal)*((acctmast->gd)/100)))
              case xflag == 2  // LOAN
                   NAF := acctmast->principal
              case xflag == 3  // PERSONAL LOANS
                   NAF := acctmast->principal
           endcase

           net += NAF
           &ams3600->(dbskip(+1))
        enddo

//        if xflag == 1

        do case
           case xflag == 1
                net       := round(net,2)
                ST_NAF[1] := net + TLS_NAF
                net       := 0
           case xflag == 2
                net       := round(net,2)
                ST_NAF[2] := net + TLN_NAF
                net       := 0
           case xflag == 3
                net       := round(net,2)
                ST_NAF[3] := net
                net       := 0
        endcase

     enddo

     ST_NAF[2] := ST_NAF[2]+ST_NAF[3]
     ST_NAF[3] := ST_NAF[2]

     xflag:=0
     dbselectarea('&ams3600')
     &ams3600->(dbgotop())
     amsr35head()

     Do while &ams3600->(!eof()) //.and. &ams3600->facility <> '4'
        if prow() > 30
           __eject()
           amsr35head()
        endif

        xflag++
        xflag2:=str(xflag)

        if xflag == 1
           heading()
           *---> RED 092704
           *@ prow()+2, 12 say 'LEASE'
           @ prow()+2, 04 say 'LEASE'
           @ prow()+1, 1 say ' '
        elseif xflag == 2
           heading()
           *---> RED 092704
           *@ prow()+2, 12 say 'LOAN'
           @ prow()+2, 04 say 'LOAN'
           @ prow()+1, 1 say ' '
        elseif xflag == 3
           heading()
           *---> RED 092704
           *@ prow()+2, 12 say 'RECEIVABLES PURCHASED'
           @ prow()+2, 04 say 'RECEIVABLES PURCHASED'
           @ prow()+1, 1 say ' '
        endif
       
        Do while alltrim(&ams3600->facility) == alltrim(xflag2) .and. &ams3600->(!eof())
           if alltrim(&ams3600->facility) == '4'    // Not LOAN, LEASE or PERSONAL LOANS
              exit
           endif
           actnum    := &ams3600->acctno
           ACTBRCODE := &AMS3600->BRCODE
           acctmast->(dbsetorder(2))
           acctmast->(dbseek(ACTBRCODE+actnum))
           *---> RED 092704
           *@ prow()+1,12 say substr(acctmast->acctno,-5,5)
           *@ prow(), 19 say acctmast->valdate
           @ prow()+1,04 say ACCTMAST->BRCODE+substr(acctmast->acctno,-5,5) PICT '@R 999-99999'
           @ prow(), 10+4  say acctmast->valdate

           clcode   :=acctmast->clntcode
           CLBRCODE := ACCTMAST->BRCODE
           Client->(dbseek(CLBRCODE+clcode))

           if xflag = 1   // for lease only
              *---> RED 092704
              *@ prow(),31  say substr(Client->fullname,1,30)
              *@ prow(),63  say substr(acctmast->unit,1,30)
              *@ prow(),97  say trans(acctmast->principal, '999,999,999.99')
              @ prow(),21+4  say substr(Client->fullname,1,30)
              @ prow(),52+4  say substr(acctmast->unit,1,30)
              @ prow(),83+4  say trans(acctmast->principal, '999,999,999.99')
              NAF := ((acctmast->principal)-((acctmast->principal)*((acctmast->gd)/100)))
           else       // for loans and receivables
              *---> RED 092704
              *@ prow(),31  say substr(Client->fullname,1,38)
              *@ prow(),71  say substr(acctmast->unit,1,38)
              @ prow(),21+4  say substr(Client->fullname,1,38)
              @ prow(),60+4  say substr(acctmast->unit,1,38)
              NAF := acctmast->principal
           endif

           *---> RED 092704
           *@ prow(),115 say trans(NAF, '999,999,999.99')
           @ prow(),99+4 say trans(NAF, '999,999,999.99')

           if xflag = 1     // this is for the lease and loan transactions in total receivables
              do case
                  case alltrim(acctmast->termunit)=='3' .and. '104' $ acctmast->fcltycode
                     TRCV:= acctmast->amort*acctmast->term // abb 07/13/2000
                  otherwise
                     if acctmast->amort <> 0
                        ///// abb 11.09.2005   TRCV:=(((acctmast->amort)*(acctmast->term))+((acctmast->principal)*((acctmast->rv)/100)))
                        TRCV:= acctmast->credamt  // (((acctmast->amort)*(acctmast->term))+((acctmast->principal)*((acctmast->rv)/100)))
                     else
                        ///// abb 11.09.2005   TRCV:=((acctmast->credamt)+((acctmast->principal)*((acctmast->rv)/100)))    // jbs 04.09.2003
                        TRCV:= acctmast->credamt  // ((acctmast->credamt)+((acctmast->principal)*((acctmast->rv)/100)))    // jbs 04.09.2003
                     endif
              endcase

           else             // this is for the receivable purchased in Total receivables
              TRCV:=acctmast->credamt
           endif
           *---> RED 092704
           *@ prow(),132 say trans(TRCV, '999,999,999.99')
           @ prow(),114+4 say trans(TRCV, '999,999,999.99')   //pepe

           if xflag != 3

              do case
                 case alltrim(acctmast->termunit)=='3'
                      *---> RED 092704
                      *@ prow(),147 say str(acctmast->term) + ' years'
                      @ prow(),129+4 say str(acctmast->term) + ' years'
                 otherwise
                      *---> RED 092704
                      *@ prow(),147 say str(acctmast->term) + ' months'
                      @ prow(),129+4 say str(acctmast->term) + ' months'
              endcase

           else
              *---> RED 092704
              *@ prow(),147 say str(acctmast->term)
              @ prow(),129+4 say str(acctmast->term)

              do case
                 case alltrim(acctmast->termunit) == '1'
                    @ prow(), pcol() say ' days'
                 case alltrim(acctmast->termunit) == '2'
                    @ prow(), pcol() say ' months'
                 case alltrim(acctmast->termunit) == '3'
                    @ prow(), pcol() say ' years'
              endcase

           endif
           *---> RED 092704
           *@ prow(),159 say str(acctmast->truerate) + ' %'
           @ prow(),140+4 say str(acctmast->truerate) + ' %'

           PRCNT := NAF / ST_NAF [xflag]

           if choice = 1
              *--->RED 092704
              *@ prow(),172 say trans(PRCNT, '9.9999')
              @ prow(),151+4 say trans(PRCNT, '9.9999')

              if xflag = 1      // LEASE
                 WATR := (((acctmast->truerate)*NAF)/ST_NAF[xflag]) // *100
              elseif xflag = 2  // LOAN
                 WATR := (((acctmast->truerate)*NAF)/ST_NAF[xflag])// *100
              elseif xflag =3   // PERSONAL LOANS
                 WATR := (((acctmast->truerate)*NAF)/ST_NAF[xflag])// *100
              endif
              *---> RED 092704
              *@ prow(),178 say trans(WATR,'99,999.9999') + ' %'
              @ prow(),159+4 say trans(WATR,'99,999.9999') + ' %'

              if xflag = 1
                 docstamps := ((acctmast->term)/12)*6
                 docstamps := round(docstamps,0)

                 if substr( acctmast->acctno,5,3 ) != '103'    // IF lease don't display
                    *---> RED 092704
                    *@ prow(),194 say trans(docstamps,'999,999')    // docstamps
                    @ prow(),173+4 say trans(docstamps,'999,999')
                 endif

              else
                 // docstamps := (acctmast->credamt)*.0015
                 docstamps := (acctmast->credamt)*.0050     // abb 07.28.04
                 docstamps := int(docstamps)+1

                 if substr( acctmast->acctno,5,3 ) != '103'     // IF lease don't display
                    *---> RED 092704
                    *@ prow(),195 say trans(docstamps,'999,999') // docstamps
                    @ prow(),173+4 say trans(docstamps,'999,999')
                 endif

              endif

           endif

           T_PRPL  += acctmast->principal
           T_NAF   += NAF
           T_TRCV  += TRCV
           T_PRCNT += PRCNT
           T_WATR  += WATR

           if substr( acctmast->acctno,5,3 ) != '103'     // IF lease don't display
              T_DOC   += docstamps
           endif

           *---> RED 092804 ADDITIONAL FIELDS
           CTRLINFO->(DBSEEK(ACCTMAST->BRCODE+ACCTMAST->ACCTNO))

           DO CASE
              CASE ALLTRIM(CTRLINFO->INSBY) == "1"
                   cINSBY := "CLIENT"
              CASE ALLTRIM(CTRLINFO->INSBY) == "2"
                   cINSBY := "COLF"
              CASE ALLTRIM(CTRLINFO->INSBY) == "3"
                   cINSBY := "DEALER"
              OTHERWISE
                   cINSBY := SPACE(0)
           ENDCASE

           cINSCOM := LEFT(EVAL( { || INSURANC->(DBSEEK(CTRLINFO->BRCODE+CTRLINFO->INSCO,.F.)),INSURANC->INSNAME } ),25)
           cAO     := ACCTMAST->AOCODE
           cEXPDTE := CTRLINFO->INSEXPRY
           cSUMINS := TRANS(CTRLINFO->AMTINS, '999,999,999.99')
           cPREM   := TRANSFORM(CTRLINFO->INSPREM, '999,999,999.99')

           IF CHOICE = 1
              @ PROW(),181+4 SAY cINSCOM
              @ PROW(),207+4 SAY cINSBY
              @ PROW(),215+4 SAY cAO
              @ PROW(),221+4 SAY cEXPDTE
              @ PROW(),232+4 SAY cSUMINS
              @ PROW(),247+4 SAY cPREM
           ELSE
              @ PROW(),151+4 SAY cINSCOM
              @ PROW(),177+4 SAY cINSBY
              @ PROW(),185+4 SAY cAO
              @ PROW(),191+4 SAY cEXPDTE
              @ PROW(),202+4 SAY cSUMINS
              @ PROW(),217+4 SAY cPREM
           ENDIF
           *--->

           &ams3600->(dbskip(+1))

        Enddo

           if xflag < 4

              if xflag = 1
                 if choice = 1
                    if t_doc > 0           // abb 07.29.04
                       *---> RED 092804
                       *@ prow()+1,97 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ                         ÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄ'
                       @ prow()+1,83+4 say  'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ                       ÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄ'
                    else
                       *---> RED 092804
                       *@ prow()+1,97 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ                         ÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄ'
                       @ prow()+1,83+4 say  'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ                       ÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄ'
                    endif
                 else
                    *---> RED 092804
                    *@ prow()+1,97 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
                    @ prow()+1,83 say  'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
                 endif
              else
                 if choice = 1
                    if t_doc > 0
                       *---> RED 092804
                       *@ prow()+1,97 say '                 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ                         ÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄ'
                       @ prow()+1,83+4 say  '                ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ                       ÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄ'
                    else
                       *---> RED 092804
                       *@ prow()+1,97 say '                 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ                         ÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄ'
                       @ prow()+1,83 say  '                ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ                       ÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄ'
                    endif

                 else
                    *---> RED 092804
                    *@ prow()+1,97 say '                 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
                    @ prow()+1,83 say  '                ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
                 endif
              endif

              *---> RED 092804

              if xflag == 1
	      	@ PROW()+1, 03 say 'TOTAL ACCOUNTS = ' + LTRIM(STR(NCTR))
              elseif xflag == 2
	      	@ PROW()+1, 03 say 'TOTAL ACCOUNTS = ' + LTRIM(STR(NCTR2))
              elseif xflag == 3
	      	@ PROW()+1, 03 say 'TOTAL ACCOUNTS = ' + LTRIM(STR(NCTR3))
              endif

              @ prow()	, 66 say 'SUB-TOTAL'


              if xflag = 1  // for lease only
                 *---> RED 092804
                 *@ prow(),97 say trans(T_PRPL, '999,999,999.99')
                 @ prow(), 83+4 say trans(T_PRPL, '999,999,999.99')
              endif
              *---> RED 092804
              *@ prow(),115 say trans(T_NAF, '999,999,999.99')
              *@ prow(),132 say trans(T_TRCV, '999,999,999.99')
              @ prow(),99+4  say trans(T_NAF, '999,999,999.99')
              @ prow(),113+4 say trans(T_TRCV, '999,999,999.99')

              if choice = 1
                 *---> RED 092804
                 *@ prow(),172 say trans(T_PRCNT, '9.9999')
                 *@ prow(),178 say trans(T_WATR,'99,999.9999') + ' %'
                 @ prow(),152+4 say trans(T_PRCNT, '9.9999')
                 @ prow(),159+4 say trans(T_WATR,'99,999.9999') + ' %'

                 if xflag = 1

                    if t_doc > 0           // abb 07.29.04
                       *---> RED 092804
                       *@ prow(),192 say trans(T_DOC, '9,999')
                       @ prow(),172+4 say trans(T_DOC, '9,999')
                    endif

                 else

                    if t_doc >  0           // abb 07.29.04
                       *---> RED 092804
                       *@ prow(),193 say trans(T_DOC, '9,999,999')
                       @ prow(),172+4 say trans(T_DOC, '9,999,999')
                    endif

                 endif
              endif
              T_PRPL:=0; T_NAF:=0; T_TRCV:=0; T_WATR:=0; T_PRCNT:=0; T_DOC:=0

           endif

           if alltrim(&ams3600->facility) == '4'    // Not LOAN, LEASE or PERSONAL LOANS
              exit
           endif

     Enddo
     __eject()

return

static function get_branches()
 local zz
 local ls:=0, ln:=0, pn:=0
 memvar TLS_NAF,TLN_NAF,TP_NAF

 zz:=savescreen(0,0,24,80,)
 fshadow( 6, 20, 10, 50, 2, 'n/g' )
 setcolor('n/g','n/rb','n/rb','n/g')
 @ 6, 21 say 'BRANCHES'
 @ 7, 21 say 'LEASE '
 @ 7, 36 get ls       pict '999,999,999.99'  color 'n/g'
 @ 8, 21 say 'LOAN '
 @ 8, 36 get ln       pict '999,999,999.99'  color 'n/g'
 @ 9, 21 say 'PERSONAL LOANS'
 @ 9, 36 get pn       pict '999,999,999.99'  color 'n/g'

 setcursor (3)
 read
 setcursor (0)

 TLS_NAF:=ls
 TLN_NAF:=ln
 TP_NAF :=pn
 restscreen(0,0,24,80,zz)
 return


  
static function get_prinamt(ca_num)
 local printamt:=0,ca_num2:=' '

dbselectarea('acctmast')
acctmast->(dbgotop())
acctmast->(dbsetorder(1))
acctmast->(dbseek(ca_num))
ca_num2:=acctmast->canumber
Do while Ca_num = ca_num2
   if acctmast->include == .T.
      printamt+=acctmast->principal
   endif
acctmast->(dbskip())
ca_num2:=acctmast->canumber
Enddo
return(printamt)
 

static function amsr35head()
local  mdate := 'For the Month of ' + { 'January', 'February', 'March',;
                'April', 'May', 'June', 'July', 'August', 'September', ;
                'October', 'November', 'December' }[ mmonth ] +  ;
                ' ' + padr( myear, 4 )
memvar choice

setprc(0,0)
setfont('DRAFT')
setfont('ELITE')
@ prow()+1,03 say 'ACCOUNT MANAGEMENT SYSTEM'
//@ prow(),  03+len('ACCOUNT MANAGEMENT SYSTEM');
//              say PADL('Page No. ' + 140-len('ACCOUNT MANAGEMENT SYSTEM'))
@ prow()+1,03 say 'AMSR3600'
@ prow()  ,03+len('AMSR3600');
              say PADL( dtoc(DATE())+' '+TIME(), 140-len('AMSR3600'))
// @ prow()+1,03 say PADC('ORIX METRO LEASING AND FINANCE CORPORATION',140)
@ prow()+1,03 say PADC( upper(alltrim(gCOMPANY)),140)     // EVR 01112007 - changed from Parametr->COMPANY
SETFONT('BOLD')
// @ prow()+1,03 say padc('MONTHLY EXECUTION REPORT FOR HEAD OFFICE',140)
@ prow()+1,03 say padc('MONTHLY EXECUTION REPORT',140)
SETFONT('UNBOLD')
@ prow()+1,03 say padc(mdate, 140)
return

static function heading()
@ prow()+1,03 say ''
setfont('ELITE')
SETFONT('CONDENSED')
if xflag = 1
   if choice = 1     // With WATR
      /*
      @ prow()+1,11 say 'ÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ'
      @ prow()+1,11 say ' ACCT   EXECUTION                  LESSEE                          LEASED               PURCHASED        NET AMOUNT         TOTAL           TERM      TRUE     PERCENT      WATR        DOC'
      @ prow()+1,11 say 'NUMBER    DATE                                                    EQUIPMENT               AMOUNT          FINANCED       RECEIVABLES                  RATE                             STAMPS'
      @ prow()+1,11 say 'ÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ'
                                1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22        23        24        25        26        27        28
                       1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
      */
      @ prow()+1,03 say 'ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄ ÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
      @ prow()+1,03 say '   ACCT    EXECUTION               LESSEE                         LEASED              PURCHASED       NET AMOUNT       TOTAL         TERM       TRUE    PERCENT    WATR        DOC        INSURANCE COMPANY     INSURED  AO     EXPIRY        SUM          PREMIUM'
      @ prow()+1,03 say '  NUMBER     DATE                                                EQUIPMENT              AMOUNT         FINANCED     RECEIVABLES                 RATE                          STAMPS                             THRU            DATE       INSURED'
      @ prow()+1,03 say 'ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄ ÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   else                // 12346 1234567891 123456789112345678921234567893 123456789112345678921234567893 12345678911234  12345678911234 12345678911234 1234567891 1234567891  123456 1234567891123 1234567 1234567891123456789212345    1    12345 1234567891 12345678911234 12345678911234
      /*
      @ prow()+1,11 say 'ÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ'
      @ prow()+1,11 say ' ACCT   EXECUTION                  LESSEE                          LEASED               PURCHASED        NET AMOUNT         TOTAL           TERM      TRUE'
      @ prow()+1,11 say 'NUMBER    DATE                                                    EQUIPMENT               AMOUNT          FINANCED       RECEIVABLES                  RATE' 
      @ prow()+1,11 say 'ÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ'
                                1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22        23        24        25        26        27        28
                       1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
      */
      @ prow()+1,03 say 'ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄ ÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
      @ prow()+1,03 say '   ACCT    EXECUTION               LESSEE                          LEASED             PURCHASED       NET AMOUNT       TOTAL         TERM      TRUE        INSURANCE COMPANY      INSURED  AO     EXPIRY        SUM          PREMIUM'
      @ prow()+1,03 say '  NUMBER     DATE                                                 EQUIPMENT             AMOUNT         FINANCED     RECEIVABLES                RATE                                THRU            DATE       INSURED'
      @ prow()+1,03 say 'ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄ ÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
                       // 12346 1234567891 123456789112345678921234567893 123456789112345678921234567893 12345678911234  12345678911234 12345678911234 1234567891 1234567891 1234567891123456789212345    1    12345 1234567891 12345678911234 12345678911234
   endif
else
   if choice = 1     // With WATR
      /*
      @ prow()+1,11 say 'ÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ'
      @ prow()+1,11 say ' ACCT   EXECUTION                  CLIENT                                COLLATERAL                       NET AMOUNT          TOTAL        TERM       TRUE     PERCENT      WATR       DOC'
      @ prow()+1,11 say 'NUMBER    DATE                                                                                             FINANCED        RECEIVABLES                RATE                            STAMPS'
      @ prow()+1,11 say 'ÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ'
                                1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22        23        24        25        26        27        28
                       1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
      */
      @ prow()+1,03 say 'ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄ ÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
      @ prow()+1,03 say '   ACCT    EXECUTION                 CLIENT                               COLLATERAL                  NET AMOUNT       TOTAL         TERM       TRUE    PERCENT    WATR         DOC       INSURANCE COMPANY     INSURED  AO     EXPIRY        SUM          PREMIUM'
      @ prow()+1,03 say '  NUMBER     DATE                                                                                      FINANCED     RECEIVABLES                 RATE                           STAMPS                            THRU            DATE       INSURED'
      @ prow()+1,03 say 'ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄ ÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   else                // 12346 1234567891 12345678911234567892123456789312345678 12345678911234567892123456789312345678 12345678911234 12345678911234 1234567891 1234567891  123456 1234567891123 1234567 1234567891123456789212345    1    12345 1234567891 12345678911234 12345678911234
      /*
      @ prow()+1,11 say 'ÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄ'
      @ prow()+1,11 say ' ACCT   EXECUTION                  CLIENT                                COLLATERAL                      NET AMOUNT            TOTAL       TERM       TRUE'
      @ prow()+1,11 say 'NUMBER    DATE                                                                                            FINANCED          RECEIVABLES               RATE'
      @ prow()+1,11 say 'ÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄ'
      */
      @ prow()+1,03 say 'ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄ ÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
      @ prow()+1,03 say '   ACCT    EXECUTION                CLIENT                               COLLATERAL                   NET AMOUNT       TOTAL         TERM       TRUE        INSURANCE COMPANY     INSURED  AO     EXPIRY        SUM          PREMIUM'
      @ prow()+1,03 say '  NUMBER     DATE                                                                                      FINANCED     RECEIVABLES                 RATE                               THRU            DATE       INSURED'
      @ prow()+1,03 say 'ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄ ÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
                       // 12346 1234567891 12345678911234567892123456789312345678 12345678911234567892123456789312345678 12345678911234 12345678911234 1234567891 1234567891 1234567891123456789212345    1    12345 1234567891 12345678911234 12345678911234
   endif
endif


RETURN


static function head2()
local  mdate := 'For the Month of ' + { 'January', 'February', 'March',;
                'April', 'May', 'June', 'July', 'August', 'September', ;
                'October', 'November', 'December' }[ mmonth ] +  ;
                ' ' + padr( myear, 4 )
memvar choice

setprc(0,0)
setfont('DRAFT')
setfont('ELITE')
@ prow()+1,03 say 'ACCOUNT MANAGEMENT SYSTEM'
//@ prow(),  03+len('ACCOUNT MANAGEMENT SYSTEM');
//              say PADL('Page No. ' + 140-len('ACCOUNT MANAGEMENT SYSTEM'))
@ prow()+1,03 say 'AMSR3600'
@ prow()  ,03+len('AMSR3600');
              say PADL( dtoc(DATE())+' '+TIME(), 140-len('AMSR3600'))
// @ prow()+1,03 say PADC('CONSOLIDATED ORIX LEASING AND FINANCE CORPORATION',140)

@ prow()+1,03 say PADC( upper(alltrim(Parametr->company)),140)

SETFONT('BOLD')
@ prow()+1,03 say padc('MONTHLY EXECUTION REPORT',140)
SETFONT('UNBOLD')
@ prow()+1,03 say padc(mdate, 140)
@ prow()+1,03 say ''
setfont('ELITE')
SETFONT('CONDENSED')
if choice = 1     // With WATR
   @ prow()+1,11 say 'ÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ'
   @ prow()+1,11 say '   ACCT     EXECUTION                  CLIENT                                COLLATERAL                       NET AMOUNT          TOTAL        TERM       TRUE     PERCENT      WATR        DOC'
   @ prow()+1,11 say '  NUMBER      DATE                                                                                             FINANCED        RECEIVABLES                RATE                             STAMPS'
   @ prow()+1,11 say 'ÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ'
else
   @ prow()+1,11 say 'ÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄ'
   @ prow()+1,11 say '   ACCT     EXECUTION                  CLIENT                                COLLATERAL                      NET AMOUNT            TOTAL        TERM      TRUE'
   @ prow()+1,11 say '  NUMBER      DATE                                                                                            FINANCED          RECEIVABLES               RATE'
   @ prow()+1,11 say 'ÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄ'
endif

RETURN


/*-------------------------*/
 static function aOpen3600()
/*-------------------------*/
memvar gSYS_NAME, gUSER_ID, gTRANDATE, mFMS0700

*---> RED 092804
IF !NETUSE( '&g_AMS_PATH\CTRLINFO', .F., 10 )              && INSURANCE INFORMATION FILE
   BREAK
ELSE
   IF !.F.; ORDLISTCLEAR(); ENDIF
   ORDLISTADD( '&g_AMS_PATH\CTRLINFO' )                    && SET INDEX ON ACCTNO
ENDIF

IF !NETUSE('&G_CIS_PATH'+'\INSURANC',.F.,5)   && INSURANCE FILE
   BREAK
ELSE
   IF !.F.; ORDLISTCLEAR(); ENDIF
   ORDLISTADD( '&G_CIS_PATH\INSCODE' )                  && SET INDEX ON ORNUMBER
ENDIF
*--->

if !netuse( '&g_AMS_PATH\Acctmast', .f., 10 )              && Account master file
   break
else
   set index to &g_AMS_PATH\AcctMATD,;
                &g_AMS_PATH\Acctmast
endif

if !netuse( '&g_AMS_PATH\Facility', .f., 10 )              && Account master file
   break
else
   set index to &g_AMS_PATH\fcltycd
endif

// EVR if !netuse( 'Parametr', .f., 10 )              && Account master file
// EVR    break
// EVR endif


if !NETUSE('&g_CIS_PATH'+'\CLIENT',.f.,5)   && CLIENT MASTER file
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_CIS_PATH\CLIECD' )                     && set index on clntcode
   ordlistadd( '&g_CIS_PATH\CLIENM' )                     && set index on Fullname
endif

return .t.
/*
/*------------------------*/
 Static function get_month()
/*------------------------*/
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
/*-----------------------------------*/
 STatic Function Headinc(pgn,xdate)
/*-----------------------------------*/




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
/*-------------------------*/
 Static Function crea_Xtemp()
/*-------------------------*/
local mfile
memvar gUSER_ID
while .t.
    mfile:=substr(alltrim(gUSER_ID),1,2)+substr(time(),1,2)+substr(time(),4,2)+substr(time(),7,2)
    if file( mfile + '.DBF' )
       loop
    else
        exit
    endif
enddo
return mfile
