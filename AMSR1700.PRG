/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   colf-iis .... Account Management System                                                                  Ã¿
³   Program id... Amsr1700                                                                                   ³³
³   Description . Gross Margin Report per AO                                                                 ³³
³   Author....... Engr. Michael B. Espina                                                                    ³³
³   Date ........ September 22, 1999 9:30 A.M.                                                               ³³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´³
³                             u p d a t e s                                                                  ³³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´³
³        who        ³       when        ³               why                                                  ³³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´³
³    mts            ³    08.01.2008     ³ added validation on brcode of AO                                   ³³
³    RLV            ³3:32 PM 10/3/2013  ³ Removal of GD in the formula if facility is 104                    ³³
ÀÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/                                                                           

#include 'inkey.ch'
#include 'colf.ch'
#include 'dbstruct.ch'
////
#defi K_SPACEBAR   32
#defi microfeed    chr( 27 ) + 'J' + chr( 18 )

memvar  AX_LEVEL, gUSER_ID
private loves := 0 , tsoyce

//setcursor(0)

if chkpass( procname(), AX_LEVEL, gUSER_ID )
   begin sequence
         aOpen1700()
         aMain1700()
   end sequence
   dbcloseall()
endif
__mrelease( '*', .t. )
return //nil

static function print_option()
local mu:=SAVEDBF(),menulist,pchoice,st:=savescreen(,,,)

   fshadow  ( 13,46,19,64,2,'w+/bg' )
   setcolor ( 'n/gr,w+/gr','w+/gr,n/gr' )

   @ 13,49 say 'Report Option' color 'n/bg'
   @ 15,60 say 'Ü'  color 'n/bg'
   @ 16,48 say repl('ß',13) color 'n/bg'
   @ 17,60 say 'Ü'  color 'n/bg'
   @ 18,48 say repl('ß',13) color 'n/bg'

   while .t.

      @ 15,47 prompt ' ~Individual  '  triggercolor 'w+/gr'
      @ 17,47 prompt ' ~Summary     '  triggercolor 'w+/gr'
      menu to pchoice

      if lastkey() <> K_ESC .and. !empty(pchoice)
          exit
      elseif Lastkey() == K_ESC
          exit
      endif
   enddo

   do case
      case pchoice == 1
         xxx := savescreen( ,,, )
         @ 15,47 say repl(' ',13) color 'n/bg'
         @ 16,47 say repl(' ',13) color 'n/bg'
         @ 15,48 say ' Individual   ' color 'w+/gr'
         inkey(.5)
         restscreen( ,,,,xxx )
         @ 15,61 say 'û'  color 'w/gr'
         pval := 1
         *repcontrol ('Indvprnt()')
         repcon_ol ('Indvprnt()',,,,,,,.F.)
      case pchoice == 2
         xxx := savescreen( ,,, )
         @ 17,47 say repl(' ',13) color 'n/bg'
         @ 18,47 say repl(' ',13) color 'n/bg'
         @ 17,48 say ' Summary      ' color 'w+/gr'
         inkey(.5)
         restscreen( ,,,,xxx )
         @ 17,61 say 'û'  color 'w/gr'
         pval := 2
         *repcontrol ('Sumprnt()')
         repcon_ol ('Sumprnt()',,,,,,,.F.)
      case pchoice == 0
         pval := 0
   endcase

   restdbf    ( mu )
   restscreen ( ,,,,st )

return

/*-------------------------*/
 Static Function aMain1700()
/*-------------------------*/
 local mu:=savescreen(,,,),gf:=savedbf(),bf:=setcursor()
 private mmonth := month(gtrandate), myear := year(gtrandate)

 fshadow( 8, 30, 11, 47, 2, 'n/g' )
 while eval ({|| setcursor (3), get_month() })
      ams1700 := crea_xtemp()
      if !file(ams1700+'.DBF')
               dbcreate( ams1700,{ {'ACCTNO'  ,'C',14,00}, ;
                                   {'CLNTCODE','C',07,00}, ;
                                   {'FACILITY','C',01,00}, ;
                                   {'BRCODE'  ,'C',03,00}, ;
                                   {'AOCODE'  ,'C',05,00} })
      endif
      if !netuse('&ams1700',.F.,0)
         break
      endif
      get_amsr1700()
      close &ams1700
      ferase( ams1700 + '.DBF')
      ferase( ams1700 + '.NTX')
 Enddo
 restdbf(gf);restscreen(,,,,mu);setcursor(bf)
 return nil

***********************************************
/* This module is lovingly dedicated to Linda U. Lipardo my love */
static function get_amsr1700()
***********************************************
 local ca_ot_num:=0, ST_NAF:={}, xrecno:=0, x:=0, linda:= ' '
 local lul:=0
 memvar tsoyce,loves

     Do case
        case g_user_id = 'MBE'
             name := ' ' // 'Mike Gwapo'
        case g_user_id = 'LUL'
             name := ' ' //
         otherwise
             name := ' '
     Endcase


     if confirm ( 'Print with Gross Margin '+ name +'?' )
        tsoyce:=1
        set color to 'gr+/gr+','gr+/b'
        fshadow(10,30,14,50,1,'gr+/b' ,'AVERAGE COST')
        loves:=0
        set cursor on
        @ 12,32 say "Average: "        color  'gr+/b'
        @ 12,42 get loves pict '99.9999'

        setcursor (2)
        read
        setcursor (0)

     else
        tsoyce := 2
     endif

     set cursor off
     waiton ( 'Generating data' )

     select acctmast
     //go top
	 ACCTMAST->(DBSEEK(g_PAR_BRCH)) // RLV branch seeking 3:30 PM 10/3/2013
     Do while acctmast->(!eof()) .AND. ACCTMAST->BRCODE == g_PAR_BRCH
	 
        f_code:=acctmast->fcltycode

        if month(acctmast->valdate) == mmonth .and. year(acctmast->valdate) == myear .and. Acctmast->STATUS  != '0' // CANCELLED RLV 08.18.2010

           acctnum  := acctmast->acctno
           acctclnt := acctmast->clntcode
           acctao   := acctmast->aocode
           ACCTBRCD := ACCTMAST->BRCODE

	   IF facility->(dbseek(f_code))		//PEPE
	      acctfclty  := facility->fcltygrp
       ELSE
	      acctfclty  := '4' //error('FACILITY CODE not found')
	   ENDIF

           dbselectarea ( '&ams1700' )
           append blank
           replace acctno   with acctnum
           replace clntcode with acctclnt
           REPLACE BRCODE   WITH ACCTBRCD
           REPLACE facility WITH acctfclty		//pepe



/****************************
           if f_code == '10301' .or. f_code == '10302'
              replace facility with '1'       // FOR LEASE FACILITY
           elseif f_code == '10401' .or. f_code == '10407' .or. f_code == '10412';
                  .or. f_code == '10408' .or. f_code == '10410'
              replace facility with '2'       // FOR LOAN FACILITY
           elseif f_code == '10402' .or. f_code == '10403' .or. f_code == '10404';
                  .or. f_code == '10405' .or. f_code == '10406' .or. f_code == '10409'
              replace facility with '3'       // FOR RECEIVABLES PURCHASED
           else
              replace facility with '4'
           endif
****************************/

           replace aocode with acctao
        endif
        select acctmast
        skip
     Enddo
     waitoff()
     print_option()
  // repcontrol('get_gross_margin()')

Return

*******************
*
*
function Indvprnt()
*******************
 local AOC,actnum,ACTBRCD,NAF:=0, TNAF:=0, CLBRCD
 local facil,STNAF:=0,rate:=0, GMT:=0, STGMT:=0, monthskip := .f.
 memvar tsoyce,loves

   dbselectarea('&ams1700')
   index on AOCODE+FACILITY to &ams1700
   &ams1700->(dbgotop())
   AOC2:=' '
   amsr17head()
   heading()

   Do while &ams1700->(!eof())
      if &ams1700->facility <> '4' .AND. &AMS1700->BRCODE == g_PAR_BRCH    && RED 012305 ADDED BRANCH CODE FILTER
         faci:=&ams1700->facility
         AOC:=alltrim(&ams1700->aocode)
         AO->(dbseek(AOC))
         @ prow()+1, 7 say AO->aoname

         Do while alltrim(AOC) = alltrim(&ams1700->aocode) .and. &ams1700->(!eof())
		 
		    if &ams1700->facility <> '4' .AND. &AMS1700->BRCODE == g_PAR_BRCH   //pepe 6:57 PM 08.01.2008
			
	            if prow() > 55
	               __eject()
	               amsr17head()
	               heading()
	            endif
	            if faci != &ams1700->facility
	               @ prow()+1, 1 say ' '
	               if tsoyce = 1
	                  @ prow()+1, 72 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ                    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
	               else
	                  @ prow()+1, 72 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
	               endif
	               @ prow()+1, 21 say 'SUB-TOTAL'
	               @ prow(), 72 say trans(TNAF,'999,999,999.99')
	               if tsoyce = 1
	                  @ prow(), 106 say trans(GMT,'999,999,999.99')
	               endif
	               if tsoyce = 1
	                  @ prow()+1, 72 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ                    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
	               else
	                  @ prow()+1, 72 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
	               endif
	               @ prow()+1, 1 say ' '

	               faci:=&ams1700->facility
	               STNAF+=TNAF
	               STGMT+=GMT
	               TNAF:=0
	               GMT:=0
	            endif

	            actnum  := &ams1700->acctno
	            ACTBRCD := &AMS1700->BRCODE
	            acctmast->(dbsetorder(2))
	            acctmast->(dbseek(ACTBRCD+actnum))

	            if &ams1700->facility = '1'
	               @ prow()+1,7 say 'L-'+ACCTMAST->BRCODE+'-'+substr(acctmast->acctno,-5,5)
	            elseif &ams1700->facility = '2'
	               @ prow()+1,7 say 'DL-'+ACCTMAST->BRCODE+'-'+substr(acctmast->acctno,-5,5)
	            elseif &ams1700->facility = '3'
	               @ prow()+1,7 say 'DL-'+ACCTMAST->BRCODE+'-'+substr(acctmast->acctno,-5,5)
	            endif

	            clcode := acctmast->clntcode
	            CLBRCD := ACCTMAST->BRCODE
	            Client->(dbseek(CLBRCD+clcode))
	            @ prow(),21 say substr(Client->fullname,1,40)
				
				if subs(ACCTMAST->ACCTNO,5,3) == '104'  // RLV 3:30 PM 10/3/2013 GD Removal
					NAF := acctmast->principal
				else
					NAF:=((acctmast->principal)-((acctmast->principal)*((acctmast->gd)/100)))
				endif
				
				acctrate := acctmast->truerate
	            @ prow(),72 say trans(NAF,'999,999,999.99')
	            //@ prow(),94 say trans(acctrate,'99.99') + ' %'

	            if tsoyce == 1

	               if &ams1700->facility == '1' .or. &ams1700->facility == '2'
				   
				   	  if review->(dbseek(&AMS1700->BRCODE+&ams1700->acctno))
					     do while REVIEW->BRCODE+REVIEW->ACCTNO == &AMS1700->BRCODE+&ams1700->acctno .and. !REVIEW->(eof())
						    IF SUBS(dtos(REVIEW->EFFDATE),1,6) <= ALLTRIM(STR(MYEAR)+RIGHT('00'+ltrim(STR(MMONTH)),2))
	                              //ALERT('11 '+&ams1700->acctno+' '+ALLTRIM(STR(MYEAR)+RIGHT('00'+ltrim(STR(MMONTH)),2)))
							      //ALERT('12 '+&ams1700->acctno+' '+SUBS(DTOS(REVIEW->EFFDATE),1,6))
							   acctrate := REVIEW->APP_TR
							   monthskip := .t.
							ENDIF

						    IF SUBS(dtos(REVIEW->EFFDATE),1,6) > ALLTRIM(STR(MYEAR)+RIGHT('00'+ltrim(STR(MMONTH)),2))
							   if !monthskip
							       acctrate := REVIEW->APP_TR
							       EXIT
							   endif
							ENDIF
					     REVIEW->(DBSKIP(+1))
	                     enddo
						 monthskip := .f.
					  endif
				   
	                  rate  :=  (acctrate - loves) / 100
	                  Gross := (NAF*rate)
					  @ prow(),94 say trans(acctrate,'99.99') + ' %'
	                  @ prow(),106 say trans(Gross,'999,999,999.99')
	                  GMT += Gross
	               else

				   	  if review->(dbseek(&AMS1700->BRCODE+&ams1700->acctno))
					     do while REVIEW->BRCODE+REVIEW->ACCTNO == &AMS1700->BRCODE+&ams1700->acctno .and. !REVIEW->(eof())
						    IF SUBS(dtos(REVIEW->EFFDATE),1,6) <= ALLTRIM(STR(MYEAR)+RIGHT('00'+ltrim(STR(MMONTH)),2))
	                              //ALERT('11 '+&ams1700->acctno+' '+ALLTRIM(STR(MYEAR)+RIGHT('00'+ltrim(STR(MMONTH)),2)))
							      //ALERT('12 '+&ams1700->acctno+' '+SUBS(DTOS(REVIEW->EFFDATE),1,6))
							   acctrate := REVIEW->APP_TR
							   monthskip := .t.
							ENDIF

						    IF SUBS(dtos(REVIEW->EFFDATE),1,6) > ALLTRIM(STR(MYEAR)+RIGHT('00'+ltrim(STR(MMONTH)),2))
							   if !monthskip
							       acctrate := REVIEW->APP_TR
							       EXIT
							   endif
							ENDIF
					     REVIEW->(DBSKIP(+1))
	                     enddo
						 monthskip := .f.
					  endif

	                  rate  := acctrate - loves
	                  Gross := ((NAF*rate)/36000) * acctmast->term  // divided by 36000 because of divideb by 100 first then 360
					  @ prow(),94 say trans(acctrate,'99.99') + ' %'
	                  @ prow(),106 say trans(Gross,'999,999,999.99')
	                  GMT += Gross
	               endif
				else
					@ prow(),94 say trans(acctrate,'99.99') + ' %'
	            endif

	            TNAF += NAF
				
			endif
			
         &ams1700->(dbskip(+1))

         Enddo

         @ prow()+1, 1 say ' '
         if tsoyce == 1
            @ prow()+1, 72 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ                    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
         else
            @ prow()+1, 72 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
         endif

         @ prow()+1, 21 say 'SUB-TOTAL'
         @ prow(), 72 say trans(TNAF,'999,999,999.99')

         if tsoyce == 1
            @ prow(), 106 say trans(GMT,'999,999,999.99')
         endif

         if tsoyce == 1
            @ prow()+1, 72 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ                    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
         else
            @ prow()+1, 72 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
         endif

         @ prow()+1, 1 say ' '
         STNAF+=TNAF
         STGMT+=GMT
         @ prow()+1, 21 say 'TOTAL'
         @ prow(), 72 say trans(STNAF,'999,999,999.99')

         if tsoyce == 1
            @ prow(), 106 say trans(STGMT,'999,999,999.99')
         endif

         if tsoyce == 1
            @ prow()+1, 72 say 'ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ                   ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ'
         else
            @ prow()+1, 72 say 'ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ'
         endif

         TNAF  := 0
         GMT   := 0
         STNAF := 0
         STGMT := 0

      else
         &ams1700->(dbskip(+1))
      endif
   Enddo
   __eject()
Return

function Sumprnt()
local clcode, GMT:=0, TNAF:=0, t_total:=0, g_total:=0
local tf_lease:=0, tf_loans:=0,tg_lease:=0, tg_loans:=0, monthskip := .f.
memvar loves

   dbselectarea('&ams1700')
   index on AOCODE+FACILITY to &ams1700
   &ams1700->(dbgotop())
   AOC2:=' '
   amsr17head()
   heading2()

   Do while &ams1700->(!eof())

      if &ams1700->facility <> '4' .AND. &AMS1700->BRCODE == g_PAR_BRCH    && RED 012305 ADDED BRANCH CODE FILTER
         AOC:=alltrim(&ams1700->aocode)
         AO->(dbseek(AOC))
         @ prow()+1, 7 say AO->aoname

         Do while alltrim(AOC) = alltrim(&ams1700->aocode) .and. &ams1700->(!eof())
		 
		    if &ams1700->facility <> '4' .AND. &AMS1700->BRCODE == g_PAR_BRCH                             //pepe 6:57 PM 08.01.2008
			
	            actnum   := &ams1700->acctno
	            ACTBRCD  := &AMS1700->BRCODE
	            acctmast->(dbsetorder(2))
	            acctmast->(dbseek(ACTBRCD+actnum))
				
				if subs(ACCTMAST->ACCTNO,5,3) == '104' // RLV 3:30 PM 10/3/2013 GD Removal
					NAF := acctmast->principal
				else
					NAF:=((acctmast->principal)-((acctmast->principal)*((acctmast->gd)/100)))
				endif
				
				     acctrate := acctmast->truerate
	           if &ams1700->facility = '1' .or. &ams1700->facility = '2'

				  if review->(dbseek(&AMS1700->BRCODE+&ams1700->acctno))
				     do while REVIEW->BRCODE+REVIEW->ACCTNO == &AMS1700->BRCODE+&ams1700->acctno .and. !REVIEW->(eof())
				        IF SUBS(dtos(REVIEW->EFFDATE),1,6) <= ALLTRIM(STR(MYEAR)+RIGHT('00'+ltrim(STR(MMONTH)),2))
	                        //ALERT('11 '+&ams1700->acctno+' '+ALLTRIM(STR(MYEAR)+RIGHT('00'+ltrim(STR(MMONTH)),2)))
					        //ALERT('12 '+&ams1700->acctno+' '+SUBS(DTOS(REVIEW->EFFDATE),1,6))
					       acctrate := REVIEW->APP_TR
					       monthskip := .t.
					    ENDIF

				        IF SUBS(dtos(REVIEW->EFFDATE),1,6) > ALLTRIM(STR(MYEAR)+RIGHT('00'+ltrim(STR(MMONTH)),2))
					       if !monthskip
					           acctrate := REVIEW->APP_TR
					           EXIT
					       endif
					    ENDIF
				     REVIEW->(DBSKIP(+1))
	                 enddo
					 monthskip := .f.
				  endif
  
	              rate:=(acctrate - loves) / 100
	              Gross:=(NAF*rate)
				  
	           else

				  if review->(dbseek(&AMS1700->BRCODE+&ams1700->acctno))
				     do while REVIEW->BRCODE+REVIEW->ACCTNO == &AMS1700->BRCODE+&ams1700->acctno .and. !REVIEW->(eof())
				        IF SUBS(dtos(REVIEW->EFFDATE),1,6) <= ALLTRIM(STR(MYEAR)+RIGHT('00'+ltrim(STR(MMONTH)),2))
	                        //ALERT('11 '+&ams1700->acctno+' '+ALLTRIM(STR(MYEAR)+RIGHT('00'+ltrim(STR(MMONTH)),2)))
					        //ALERT('12 '+&ams1700->acctno+' '+SUBS(DTOS(REVIEW->EFFDATE),1,6))
					       acctrate := REVIEW->APP_TR
					       monthskip := .t.
					    ENDIF

				        IF SUBS(dtos(REVIEW->EFFDATE),1,6) > ALLTRIM(STR(MYEAR)+RIGHT('00'+ltrim(STR(MMONTH)),2))
					       if !monthskip
					           acctrate := REVIEW->APP_TR
					           EXIT
					       endif
					    ENDIF
				     REVIEW->(DBSKIP(+1))
	                 enddo
					 monthskip := .f.
				  endif
				  
	              rate:=acctrate - loves
	              Gross:=((NAF*rate)/36000) * acctmast->term  // divided by 36000 because of divided by 100 first then 360

	           endif

	           if &ams1700->facility == '1'
	              tf_lease+=NAF
	              tg_lease+=gross
	           else
	              tf_loans+=NAF
	              tg_loans+=gross
	           endif

	           GMT+=Gross
	           TNAF+=NAF
			   
		    endif
			
         &ams1700->(dbskip())
         Enddo

         @ prow(),50 say trans(TNAF,'999,999,999.99')
         @ prow(),70 say trans(GMT,'999,999,999.99')

         t_total+=TNAF
         g_total+=GMT
         TNAF:=0
         GMT:=0
      else
        &ams1700->(dbskip())
      endif
   Enddo

      @ prow()+1, 47 say ' ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ     ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ'
      @ prow()+1, 7 say 'TOTAL '
      @ prow(), 50 say trans(t_total,'999,999,999.99')
      @ prow(), 70 say trans(g_total,'999,999,999.99')
      @ prow()+2, 7 say 'TOTAL LEASES '
      @ prow(), 50 say trans(tf_lease,'999,999,999.99')
      @ prow(), 70 say trans(tg_lease,'999,999,999.99')
      @ prow()+2, 7 say 'TOTAL LOANS '
      @ prow(), 50 say trans(tf_loans,'999,999,999.99')
      @ prow(), 70 say trans(tg_loans,'999,999,999.99')
      @ prow()+1, 47 say ' ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ     ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ'
      @ prow()+1, 7 say 'TOTAL LOANS & LEASE'
      @ prow(), 50 say trans(tf_loans+tf_lease,'999,999,999.99')
      @ prow(), 70 say trans(tg_loans+tg_lease,'999,999,999.99')
      setfont('BOLD')
      @ prow()+2, 7 say 'GRAND TOTAL'
      @ prow(), 50 say trans(tf_loans+tf_lease,'999,999,999.99')
      @ prow(), 70 say trans(tg_loans+tg_lease,'999,999,999.99')
      @ prow()+1, 47 say ' ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ     ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ'
      setfont('Unbold')
      __eject()
Return


static function heading()
memvar tsoyce
@ prow()+1,03 say ''
setfont('ELITE')
SETFONT('CONDENSED')
if tsoyce = 1
   @ prow()+1, 7 say 'ÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ     ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ      ÄÄÄÄÄÄÄÄÄ     ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   @ prow()+1, 7 say ' L.A.#/LOAN               LESSE                             NET AMOUNT FINANCED       NET T.R.       GROSS MARGIN'
   @ prow()+1, 7 say 'ÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ     ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ      ÄÄÄÄÄÄÄÄÄ     ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   @ prow()+1, 1 say ' '
else
   @ prow()+1, 7 say 'ÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ     ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ      ÄÄÄÄÄÄÄÄÄ'
   @ prow()+1, 7 say ' L.A.#/LOAN               LESSE                             NET AMOUNT FINANCED       NET T.R.'
   @ prow()+1, 7 say 'ÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ     ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ      ÄÄÄÄÄÄÄÄÄ'
   @ prow()+1, 1 say ' '
endif
return


static function heading2()

@ prow()+1,03 say ''
setfont('ELITE')
SETFONT('CONDENSED')
@ prow()+1, 7 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ      ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
@ prow()+1, 7 say '        ACCOUNT OFFICER               NET AMOUNT FINANCED      GROSS MARGIN'
@ prow()+1, 7 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ      ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
@ prow()+1, 1 say ' '

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
 read
 TLS_NAF:=ls
 TLN_NAF:=ln
 TP_NAF:=pn
 restscreen(0,0,24,80,zz)
return
 
*********************************
*
static function amsr17head()
*********************************
local  mdate := 'For the Month of ' + { 'January', 'February', 'March',;
                'April', 'May', 'June', 'July', 'August', 'September', ;
                'October', 'November', 'December' }[ mmonth ] +  ;
                ' ' + padr( myear, 4 )
memvar tsoyce,loves

setprc(0,0)
setfont('DRAFT')
setfont('ELITE')
@ prow()+1,03 say 'ACCOUNT MANAGEMENT SYSTEM'
@ prow()+1,03 say 'AMSR1700'
@ prow()  ,03+len('AMSR1700');
              say PADL( dtoc(DATE())+' '+TIME(), 90-len('AMSR1700'))
@ prow()+1,03 say PADC('CONSOLIDATED ORIX LEASING AND FINANCE CORPORATION',90)
SETFONT('BOLD')
@ prow()+1,03 say padc('GROSS MARGIN PER ACCOUNT OFFICER',90)
SETFONT('UNBOLD')
@ prow()+1,03 say padc(mdate, 90)
if tsoyce = 1
   @ prow()+1,1 say ' '
   @ prow()+1,7 say 'AVERAGE COST FOR THE MONTH : ' + str(loves)
endif
 
return

/*-------------------------*/
 static function aOpen1700()
/*-------------------------*/
memvar gSYS_NAME, gUSER_ID, gTRANDATE, mFMS0700

if !netuse( '&g_AMS_PATH\Acctmast', .f., 10 )              && Account master file
   break
else
   set index to &g_AMS_PATH\Acctclnt,;
                &g_AMS_PATH\Acctmast,;
                &g_AMS_PATH\Acctaonm
endif

if !netuse( '&g_cis_path'+'\AO',.f.,5)
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_CIS_PATH\AO' )                     
endif

if !NETUSE('&g_CIS_PATH'+'\CLIENT',.f.,5)   && CLIENT MASTER file
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_CIS_PATH\CLIECD' )                     && set index on clntcode
   ordlistadd( '&g_CIS_PATH\CLIENM' )                     && set index on Fullname
endif

if !netuse( '&g_AMS_PATH\REVIEW', .f., 10 )
   break
else
   set index to &g_AMS_PATH\REVIEW
endif

if !netuse( '&g_AMS_PATH\Facility', .f., 10 )
   break
else
   set index to &g_AMS_PATH\fcltycd
endif

return
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
   @  9, 42 get mmonth pict '99'   when  select_month( @mmonth, 9, 40, 18, 56 )
   @ 10, 41 get myear  pict '9999' valid myear > 1970
   read
   setcolor( mcolor )
return lastkey() != K_ESC
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




