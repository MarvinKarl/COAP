*------------------------------------------------------------------------------
*- File Name....: AMS.PRG
*- Author.......: Janet L. Bautista
*- Date Start...: 04-Jul-1994      11:28:56am
*------------------------------------------------------------------------------
*- Notice.......: Copyright (c) 2010. ORIX METRO Leasing & Finance Corporation
*------------------------------------------------------------------------------
*- App ID.......: AMS
*- App Name.....: Account Management System
*------------------------------------------------------------------------------
*- Description..: Main calling program
*------------------------------------------------------------------------------
*- Last Update..:
*-    ABB   10.22.2004  ONLINE
*-    AGA   04.04.2005  password expiry (90), locking plus dropper
*-    EVR   06.06.2006  password lenght is 8 or up
*------------------------------------------------------------------------------

#include "inkey.ch"

#define gc_version ".00061"

param cuser

// set system environment
local z,x,st_
LOCAL cHELLO, nHELLO, cSTR, nLEN
LOCAL mDATE := DATE()
PRIVATE mNAME

if empty(cuser)
   cuser := '0'
endif

cls
FT_PRTSCR(.t.)               // function that disable Print Screen Key
// setcancel(.f.)            // for testing only, set to false when running

close all
clear typeahead
close databases

set device to screen
//setkey( K_ALT_C,{ || ALTKC() } )
set bell       off
set echo       off
set exact      off
set print      off
set safety     off
set scoreboard off
set status     off
set talk       off
set unique     off

set century    on
set epoch      to 1977
set confirm    on
set console    on
set cursor     on
set deleted    on
set escape     on
set wrap       on
setblink(.T.)

PRIVATE xNAME := ' '
public gUSER_ID, g_USER_ID := '---', AX_LEVEL, USER_OK, gCOMPANY, gSYS_NAME, gTRANDATE
public g_SYS_NAME, gMENUFILE, g_GRF_PATH, g_CIS_PATH, g_AMS_PATH, g_GL_PATH, g_OLS_PATH ,g_OALP_PATH
public mTRANDATE,_g_pword
PUBLIC g_CPS_PATH, g_PAR_BRCH, g_lastclosed, TRUE_BRCH, g_CRM_PATH
PUBLIC g_CREDCOM, g_COLFYR, g_COSIGN, g_RISK_COMM, g_EXEC_COMM, g_BOARD_COMM, g_COLACODE     // EVR 20122006
PUBLIC g_PENRATE, g_LASTSA, g_INS_SIGNEE, g_SIGN_POST, g_RENCONTACT, g_RENPHONE, g_NTC_SIGNEE, g_NTC_POST
PUBLIC pTemp := ".\"
PUBLIC _gTmpFile := {}
PUBLIC g_FRU_PATH, STN_BRCH
public gBRANCH

setkey(K_SH_F12,{ ||CHANGE_BR()})

ST  = time()
gTRANDATE  := date()     //aga.04.04.2005.date for loguser() gtrandate
/*                                   && RED 042605
ljustcreated := .f.

if !file("c:\Wsconfig.dbf")  // check existence of wsconfig.dbf
                             // 06.18.2004

   dbcreate( 'c:\Wsconfig',{ {'Flag','L',1,0} } )

   if netuse( 'c:\Wsconfig',.f.,5 )
      Wsconfig->(netlock('R',0))
      Wsconfig->flag := .t.
	  Wsconfig->(dbunlock())
      Wsconfig->(dbcommit())
      close data
      ljustcreated := .t.
   else
      return
   endif

endif

if netuse( 'c:\Wsconfig',.f.,5 )

   if !ljustcreated

      if Wsconfig->flag
         _ccolor := setcolor()
         setcolor('B/N')
         alert ( "CANNOT PROCEED! You cannot run more than one application system in your computer... "+;
                  "You either did not exit from the previous application or the previous application  "+;
                  "generated an error which you should have reported immediately to the ICT Division." ,,'W+/B';
               )

         setcolor(_ccolor)
         close all
         return

      else

         if Wsconfig->(netlock('R',5))
            Wsconfig->flag := .t.
            Wsconfig->(dbunlock())
         endif
         Wsconfig->(dbcommit())
      endif

   endif

else
   return
endif
*/

if !file("PARAMETR.DBF")                       // check if PARAMETER file
   ERROR('Parameter file missing!')            // exists
   return
endif

if !NETUSE('PARAMETR',.F.,5)
   return
endif

if eof()
   ERROR('No parameter records found.')
   return
endif

//gCOMPANY   := PARAMETR->COMPANY
//gSYS_NAME  := ALLTRIM(PARAMETR->SYS_NAME)

gMENUFILE  := alltrim(PARAMETR->MENUFILE)

g_GRF_PATH := alltrim(PARAMETR->GRF_PATH)
g_CIS_PATH := alltrim(PARAMETR->CIS_PATH)
g_AMS_PATH := alltrim(PARAMETR->AMS_PATH)
g_GL_PATH  := alltrim(PARAMETR->GL_PATH)
g_PLS_PATH := alltrim(PARAMETR->PLS_PATH)
g_FMS_PATH := alltrim(PARAMETR->FMS_PATH)
g_CPS_PATH := alltrim(PARAMETR->CPS_PATH)

g_OLS_PATH  := alltrim(PARAMETR->OLS_PATH)
g_OALP_PATH := alltrim(PARAMETR->OALP_PATH)

g_FRU_PATH  := alltrim(PARAMETR->FRU_PATH)

//g_CRM_PATH := alltrim(PARAMETR->CRM_PATH)

//TRUE_BRCH  := g_PAR_BRCH := alltrim(PARAMETR->BRCODE)
TRUE_BRCH := g_PAR_BRCH := '000'                            //default for complog checking *pepe 10:47 AM 12/5/2012

if !NETUSE('&g_AMS_PATH\FLAG',.F.,5)
   //FT_PRTSCR(.T.)
   return
endif

gCOMPANY   = FLAG->COMPANY
gSYS_NAME  = alltrim(FLAG->SYS_NAME)

if !NETUSE('&g_GRF_PATH\WSTATION',.F.,5)
   return
end
set index to &g_GRF_PATH\WSTATION

IF WSTATION->(DBSEEK(ALLTRIM(NETNAME())))
   //TRUE_BRCH := g_PAR_BRCH := WSTATION->BRCODE
   g_PAR_BRCH := WSTATION->BRCODE
   STN_BRCH   := WSTATION->BRCODE
   USE_CPS    := WSTATION->USE_CPS
   if !USE_CPS
      TRUE_BRCH := '001'
   endif
ELSE
   alert("Workstation not found! Please call Technology Operations "+;
          "and Applications Support Department!")
   return
ENDIF
WSTATION->(dbclosearea())

if !netuse ( '&g_GRF_PATH\Ntconfig',.f.,5 )           // Sept. 14, 2004
   error ( 'NT Configuration File Not Found.' )
   close all
   return
else

    if val(cuser) != 1

       if Ntconfig->eod_flag       // if Flag == True then the user cannot proceed
         close all
         alert ( 'Access Denied ... End of Day closing ongoing.' )
         return
      endif

    endif

   if Ntconfig->eod_flag       // if Flag == True then the user cannot proceed

      if Ntconfig->seq_check != 6
         error ( 'Sequence Error! You should be processing STEP # '+alltrim(trans(Ntconfig->seq_check,"999")) )
         close all
         return
      endif

   endif

endif
 
*--->                         && RED 042605

if !USE_CPS  //if TRUE_BRCH == '001' 
	IF NETUSE('&g_GRF_PATH\COMPLOG',.F.,5)
		SET INDEX TO &g_GRF_PATH\COMPLOG1, &g_GRF_PATH\COMPLOG2,;
					&g_GRF_PATH\COMPLOG3, &g_GRF_PATH\COMPLOG4
		IF COMPLOG->(DBSEEK(NETNAME()))
			IF COMPLOG->STATUS == 'O'
				IF COMPLOG->(NETLOCK('R',0))
					REPLACE COMPLOG->STATUS   WITH 'I'
					REPLACE COMPLOG->SYSTEM   WITH 'AMS'
					REPLACE COMPLOG->BRCODE   WITH TRUE_BRCH
					REPLACE COMPLOG->INDATE   WITH DATE()
					REPLACE COMPLOG->INTIME   WITH TIME()
					REPLACE COMPLOG->OUTDATE  WITH CTOD(' ')
					REPLACE COMPLOG->OUTTIME  WITH ' '
					REPLACE COMPLOG->OUTTIME  WITH ' '
					COMPLOG->(DBUNLOCK())
					COMPLOG->(DBCOMMIT())
				ENDIF
			ELSEIF COMPLOG->STATUS == 'I'
				_ccolor := setcolor()
				setcolor('B/N')

				alert ( "CANNOT PROCEED! You cannot run more than one application system in your computer... "+;
						"You either did not exit from the previous application or the previous application  "+;
						"generated an error which you should have reported immediately to the IT Department." ,,'W+/B';
						)

				setcolor(_ccolor)

				CLOSE ALL
				RETURN
			ENDIF
		else
			COMPLOG->(NETLOCK('A',3))
			REPLACE COMPLOG->WSTATION WITH NETNAME()
			REPLACE COMPLOG->STATUS   WITH 'I'
			REPLACE COMPLOG->SYSTEM   WITH 'AMS'
			REPLACE COMPLOG->BRCODE   WITH TRUE_BRCH
			REPLACE COMPLOG->INDATE   WITH DATE()
			REPLACE COMPLOG->INTIME   WITH TIME()
			REPLACE COMPLOG->OUTDATE  WITH CTOD(' ')
			REPLACE COMPLOG->OUTTIME  WITH ' '
			REPLACE COMPLOG->RESET    WITH ' '
			COMPLOG->(DBUNLOCK())
			COMPLOG->(DBCOMMIT())
		ENDIF
		COMPLOG->(DBCLOSEAREA())
	else
		RETURN
	ENDIF
else
	
	xSTR := CHK_PAR(NETNAME())+CHK_PAR('AMS')+CHK_PAR(STN_BRCH)+CHK_PAR(gSYS_NAME)
	
	//ltemp := IF(alltrim(CPS_REQST(xSTR,'LOGIN')) == 'F',.f.,.t.) 
	
	if !IF(alltrim(CPS_REQST(xSTR,'LOGIN')) == 'F',.f.,.t.)
		_ccolor := setcolor()
		setcolor('B/N')
		alert ( "CANNOT PROCEED! You cannot run more than one application system in your computer... "+;
				"You either did not exit from the previous application or the previous application  "+;
				"generated an error which you should have reported immediately to the IT Department." ,,'W+/B';
				)

         setcolor(_ccolor)

        CLOSE ALL
         RETURN
	endiF
		
endif


*--->


select PARAMETR
use

setcolor( gNORMAL )
LOGUSER()

g_USER_ID := gUSER_ID

if empty(gUSER_ID)
   LICENSE()
endif

if !USER_OK
   *--->                         && RED 042605
	if TRUE_BRCH == '001'
		IF NETUSE('&g_GRF_PATH\COMPLOG',.F.,5)
			SET INDEX TO &g_GRF_PATH\COMPLOG1, &g_GRF_PATH\COMPLOG2,;
						 &g_GRF_PATH\COMPLOG3, &g_GRF_PATH\COMPLOG4

			IF COMPLOG->(DBSEEK(NETNAME()+'AMS   '))
				IF COMPLOG->(NETLOCK('R',0))
					REPLACE COMPLOG->STATUS  WITH 'O'
					REPLACE COMPLOG->SYSTEM  WITH ' '
					REPLACE COMPLOG->OUTDATE WITH DATE()
					REPLACE COMPLOG->OUTTIME WITH TIME()
					COMPLOG->(DBUNLOCK())
					COMPLOG->(DBCOMMIT())
				ENDIF
			ENDIF
			COMPLOG->(DBCLOSEAREA())
		ELSE
			RETURN
		ENDIF
	ELSE
      xSTR := CHK_PAR('AMS')+CHK_PAR(NETNAME())
      CPS_REQST(xSTR,'REJECTUSER')
	ENDIF
   *--->

   ////FT_PRTSCR(.t.)
   return
endif

logged()

*--->                         && RED 042605
if TRUE_BRCH == '001' //chi 10-25-08

	IF NETUSE('&g_GRF_PATH\COMPLOG',.F.,5)
		SET INDEX TO &g_GRF_PATH\COMPLOG1, &g_GRF_PATH\COMPLOG2,;
					 &g_GRF_PATH\COMPLOG3, &g_GRF_PATH\COMPLOG4

		IF COMPLOG->(DBSEEK(NETNAME()+'AMS   '))
			IF COMPLOG->(NETLOCK('R',0))
				REPLACE COMPLOG->USER   WITH g_USER_ID
				COMPLOG->(DBUNLOCK())
				COMPLOG->(DBCOMMIT())
			ENDIF
		ENDIF
		COMPLOG->(DBCLOSEAREA())
	ELSE
		RETURN
	ENDIF
else
    xSTR := CHK_PAR(g_USER_ID)+CHK_PAR('AMS')+CHK_PAR(NETNAME())
	CPS_REQST(xSTR,'LOGUSER')
endif

*--->

//aga.01.04.2005.dropper path
if !NETUSE('&g_ams_path\Drop',.F.,5)
   return
endif
set index to &g_ams_path\drop,&g_ams_path\drop2
*.........................


if !NETUSE("&g_GRF_PATH\HOLIDAYS",.F.,5)
   ////FT_PRTSCR(.t.)
   return
endif
set index to &g_GRF_PATH\HOLIDATE



if !NETUSE('Parametr',.F.,5)
   //// FT_PRTSCR(.t.)
   return
endif


*---> RED 033005
IF NETUSE('&g_AMS_PATH\OL_PARAM',.F.,5)
   SET INDEX TO &g_AMS_PATH\OL_PARAM
// EVR   UPDT_OL()
ELSE
   RETURN
ENDIF
*--->


if !NETUSE('&g_GL_PATH\FLAG',.F.,5)
   ////FT_PRTSCR(.t.)
   return
endif

// check system date

g_lastclosed := Flag->lastclosed

**********
**********// display system menu
**********
cls
setcolor(gREVERSE)

*--------------------------    && RED 011305
SET CURSOR OFF
@ 10,09 CLEAR TO 14,71
@ 10,10 TO 14,70        COLOR 'W/W+'
@ 11,70 SAY              '≥'         COLOR 'N/W'
@ 12,70 SAY              '≥'         COLOR 'N/W'
@ 13,70 SAY              '≥'         COLOR 'N/W'
@ 14,11 SAY REPL('ƒ',59)+'Ÿ'         COLOR 'N/W'

cHELLO := 'Hello '+ALLTRIM(xNAME)+'!'
nHELLO :=LEN(cHELLO)
cSTR   := 'Today is '+CDOW(DATE())+' - '+CMONTH(DATE())+' '+TRANS(DAY(DATE()),'99')+', '+TRANS(YEAR(DATE()),'9999')
nLEN   := LEN(cSTR)

@ 11,10+(60-nHELLO)/2 SAY cHELLO
@ 12,10+(60-nLEN)/2   SAY cSTR
@ 13,20 SAY          'Please wait while system is building up.'
SET CURSOR ON
*--------------------------

if !file(gMENUFILE+".DBF")
   ERROR('Cannot locate the menu file.')
   close data
   return
endif

  if .not. file('&g_AMS_PATH\USER_ID.NTX')
      if !NETUSE('&g_AMS_PATH\AXMAST',.t.,5)
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
         Axmast->status := 'L'
         Axmast->logindate := date()           // abb 10.01.2004
         Axmast->logintime := time()           // abb 10.01.2004
         Axmast->module := "MAINMENU"          //aga.14.03.2006.register module on log on
         Axmast->WSTATION := netname()
         Axmast->(dbunlock())                //aga.04.04.2005.unlock for netlock
         Axmast->(dbcommit())
         Axmast->(dbclosearea())
      endif
   endif

/********
	//check if brcode is not ORC and OALP
	//modified by FOM
	IF NETUSE('&g_GRF_PATH\BRCODE',.F.,5)
		DBSETINDEX('&g_GRF_PATH\USER')
		IF BRCODE->(DBSEEK(RTRIM(g_USER_ID)))
			if TRUE_BRCH == '001'
				g_PAR_BRCH := BRCODE->AMS
			else
				TRUE_BRCH := g_PAR_BRCH := BRCODE->AMS
			endif
		ENDIF
		if left(g_PAR_BRCH,1) $ '87'
			alert('INVALID BRCODE! ORC and OALP are not Included..')
			lcontinue := .f.
		else
			lcontinue := .t.
		endif
		BRCODE->(DBCLOSEAREA())
	else
		alert('BRCODE file missing!')
		lcontinue := .f.
	ENDIF 

   IF NETUSE('&g_GRF_PATH/BRANCHES',.F.,5)
      
      DBSETINDEX('&g_GRF_PATH/BRANCHES')

      IF BRANCHES->(DBSEEK(g_PAR_BRCH))
         gSYS_NAME  = gSYS_NAME+' ('+g_PAR_BRCH+'-'+RTRIM(BRANCHES->BRNAME)+')'
 	     gBRANCH  = '('+g_PAR_BRCH+'-'+RTRIM(BRANCHES->BRNAME)+')' //pepe
      ENDIF

      BRANCHES->(DBCLOSEAREA())
   ELSE
      RETURN
   ENDIF
********/
   if Ol_param->(dbseek(g_PAR_BRCH))     // EVR 20122006
      g_CREDCOM    := Ol_param->CREDCOM
      g_COLFYR     := Ol_param->COLFYR
      g_COSIGN     := Ol_param->COSIGN
      g_RISK_COMM  := Ol_param->RISK_COMM
      g_EXEC_COMM  := Ol_param->EXEC_COMM
      g_BOARD_COMM := Ol_param->BOARD_COMM
      g_COLACODE   := Ol_param->COLACODE
      g_PENRATE    := Ol_param->PENRATE
      g_LASTSA     := Ol_param->LASTSA
      g_INS_SIGNEE := Ol_param->INS_SIGNEE
      g_SIGN_POST  := Ol_param->SIGN_POST
      g_RENCONTACT := Ol_param->RENCONTACT
      g_RENPHONE   := Ol_param->RENPHONE
	  g_NTC_SIGNEE := Ol_param->NTC_SIGNEE
	  g_NTC_POST   := Ol_param->NTC_POST


//      gTRANDATE    := Ol_param->TRANDATE      // pepe 04.09.2008
   endif

//************* pepe 04.09.2008
mDATE := Flag->LASTCLOSED+1

gTRANDATE := Comp_gTRANDATE(@mDATE) 		// PEPE 04.09.2008

**** REMOVE TRANDATE FIELD FROM LOCAL Parametr.dbf August 12, 2009
****if Parametr->(netlock('R',0))       // PEPE 04.09.2008
****   Parametr->TRANDATE := gTRANDATE
****   Parametr->(dbunlock())
****   Parametr->(dbcommit())
****endif
//************* pepe 04.09.2008




mTRANDATE := gTRANDATE     // EVR 20122006 - moved here

//if lcontinue
   
	FPULLME(gMENUFILE,gCOMPANY,gSYS_NAME,gUSER_ID,gTRANDATE )  // generate menu
	setcolor(gNORMAL)
//endif

   *--------------------------    && RED 011305
   SET CURSOR OFF
   @ 10,09 CLEAR TO 14,71
   SET COLOR TO 'N/W'
   @ 11,26 CLEAR TO 13,55
   @ 11,27 TO 13,54                     COLOR 'W/W+'
   @ 12,54 SAY              '≥'         COLOR 'N/W'
   @ 13,28 SAY REPL('ƒ',26)+'Ÿ'         COLOR 'N/W'

   @ 12,29 SAY  'System is terminating...'
   SET CURSOR ON
   SET COLOR TO
   
   // LOG OUT
   if NETUSE('&g_AMS_PATH\USERLOG',.F.,5)
		SET INDEX TO &g_AMS_PATH\USERLOG
		select USERLOG
		NETLOCK('A',0)
		replace USER_ID  with gUSER_ID	,;
				NAME     with mNAME	,;
				TRANCODE with '4'		,;
				TRANDATE with date()	,;
				TRANTIME with time()	,;
				WSTATION with netname()
		commit
		unlock
   endif

   *--->                         && RED 042605
   if true_brch == '001'
		IF NETUSE('&g_GRF_PATH\COMPLOG',.F.,5)
			SET INDEX TO &g_GRF_PATH\COMPLOG1, &g_GRF_PATH\COMPLOG2,;
						 &g_GRF_PATH\COMPLOG3, &g_GRF_PATH\COMPLOG4

			IF COMPLOG->(DBSEEK(NETNAME()+'AMS   '+PADR(g_USER_ID,6,' ')))
				IF COMPLOG->(NETLOCK('R',0))
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
		ELSE
			RETURN
		ENDIF
	else

		g_par_brch := STN_BRCH
		xSTR := CHK_PAR(g_USER_ID)+CHK_PAR('AMS')+CHK_PAR(NETNAME())
		if !IF(alltrim(CPS_REQST(xSTR,'LOGOUT')) == 'F',.f.,.t.)
			ALERT('FAILED TO ACCESS COMPLOG')
		ENDIF
	endif
   *--->
/* EVR 28122006 - removed
   *--------------------------------------  && RED 033005
   IF NETUSE('PARAMETR',.F.,5)
      IF NETUSE('&g_AMS_PATH\OL_PARAM',.F.,5)
         SET INDEX TO &g_AMS_PATH\OL_PARAM
         UPDT_OL()
      ENDIF
   ENDIF
   *--------------------------------------
*/
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
         Axmast->status := 'E'
         Axmast->logoutdate := date()           // abb 10.01.2004
         Axmast->logouttime := time()           // abb 10.01.2004
         Axmast->module := ""                   //aga.14.03.2006.register module on log off
         Axmast->(dbunlock())
      endif
      Axmast->(dbcommit())
   endif

   if USER_OK
    //  LICENSE()
   endif
   /*                         && RED 050605
   if netuse( 'c:\Wsconfig',.f.,5 )
      if Wsconfig->(netlock('R',5))
         Wsconfig->flag := .f.
         Wsconfig->(dbcommit())
      endif
      Wsconfig->(dbunlock())
   endif
   */
close all
//Ferase( (ctrlxxxx)+'.ntx')
set cursor on
setcolor(gNORMAL)
////FT_PRTSCR(.t.)
return

// functions //

/*ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
 ≥ Function    : Get user code                                          ≥
 ≥ Syntax      : LOGUSER()                                              ≥
 ≥                                                                      ≥
 ≥ Module Calls: CENTER, ERROR, GETPASS                                 ≥
 ¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*/
function LOGUSER
   local SCRTITLE,mPASSWORD,CTR,ncol,lCHANGE:=.f.,userCTR := 1,iduser     // EVR 02052007
   private mlastpass
   SCRTITLE = [USER IDENTIFICATION]
   setcolor(gNORMAL)
   cls

   if !NETUSE('&g_AMS_PATH\USERLOG',.F.,5)
      USER_OK = .F.
      return ( nil )
   endif
   SET INDEX TO &g_AMS_PATH\USERLOG

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
      return nil
   endif
   set index to &g_AMS_PATH\USER_ID

   setcolor(gDATAENTRY)
   cls
   ncol:=21
   @ 01,00 say repl('Õ',80)

   @ 09,00 say repl('Õ',80)

   @ 02,ncol say ' ±€€€€€   ±€€€€€€‹  ±€€€€€€  ±€€›  ±€€›'
   @ 03,ncol say '±€€  ±€€  ±€€  ±€€    ±€€     ±€€›±€€› '
   @ 04,ncol say '±€€  ±€€  ±€€  ±€€    ±€€      ±€€€€   '
   @ 05,ncol say '±€€  ±€€  ±€€€€€ﬂ     ±€€     ±€€›±€€› '
   @ 06,ncol say ' ±€€€€€   ±€€  ±€‹  ±€€€€€€  ±€€›  ±€€›'

   center   (08,gNORMAL,'ORIX METRO Leasing & Finance Corporation')
   
   
  setcolor(gBRIGHT)
  center    (11,gBRIGHT,'OMLF INTEGRATED APPLICATIONS SUITE version 8.01' )
  center   (12,gBRIGHT,upper(gSYS_NAME))

   setcolor(gBRIGHT)
   CENTER(12,gBRIGHT,upper(gSYS_NAME) + gc_version )
   CENTER(14,gREVERSE,space(21)+SCRTITLE+space(20))
   setcolor(gNORMAL)
   @ 13,09 to 22,70
   @ 15,10 say replicate('ƒ',60)
   @ 17,14 say [  User ID :]
   @ 18,14 say [User Name :]
   @ 19,14 say [ Password :]
   @ 20,14 say [   Branch :]

   USER_OK  = .F.
   CTR      = 1
   gUSER_ID = 'SUPER '
   mNAME    = space(30)

   do while CTR <= 3
      @ 17,26 clear to 19,69
      clear typeahead

      if !(eof() .and. bof())
	 gUSER_ID = space(6)
      endif

      setcolor(gDATAENTRY)
      @ 17,26 get gUSER_ID pict [@!] //;
	          //VALID CHK_BRCODE(@gUSER_ID)

      if eof() .and. bof()
	 @ 18,26 get mNAME pict '@!' valid !empty(mNAME)
      endif

      read
      setcolor(gNORMAL)

      if empty(gUSER_ID)
         AXMAST->(dbclosearea())
	     USER_OK = .F.
	     return ( nil )
      endif

//aga.01.04.2005.determine if the user is locked
      if _is_locked()     
         AXMAST->(dbclosearea())	  
         USER_OK = .F.
         return ( nil )
      endif
*....................

      if !( bof() .and. eof() )

/* 	 seek gUSER_ID
	 if !found()
	    ERROR([User ID not found!])
	    CTR = CTR + 1
	    loop
       *---&&RED-11/15/04--
    ELSE
       xNAME := AXMAST->NAME
       *-------------------
	 endif */

    mNAME = AXMAST->NAME
	 setcolor(gNORMAL)
//	 @ 18,26 say mNAME pict [@!]
	 @ 19,26 say []

	 mPASSWORD = GETPASS()
	 mUSERID := GETUSERID()
    _g_pword  = mpassword
 mlastpass = mpassword

	 if trim(AXMAST->PASSWORD) == mPASSWORD .and. mUSERID == 'YES'
//aga.01.04.2005.check if password already expired or give GRACE
            if Axmast->expired <= gtrandate

               if Axmast->grace > 0
                  alert ( 'You have '+alltrim(trans ( Axmast->grace,'999' ))+' grace logins to think of your new password ' )
                  Axmast->( netlock('R',0))
                  Axmast->grace := Axmast->grace - 1
                  Axmast->( dbunlock())
                  Axmast->( dbcommit())
               else 
                  alert ( 'Password for user '+alltrim(guser_id)+' already expired' )
                  lCHANGE := userpass ()        // change user password
                  user_ok := .f.
                  if !lCHANGE     // EVR 02052007
                     return nil
				  else
					// CHANGE PASSWORD
					select USERLOG
					NETLOCK('A',0)
					replace USER_ID  with gUSER_ID	,;
							NAME     with mNAME	,;
							TRANCODE with '2'		,;
							TRANDATE with date()	,;
							TRANTIME with time()	,;
							WSTATION with netname()
					commit
					unlock
                  endif
               endif

            endif
*......................

            CENTER(23,gBRIGHT,[˛˛˛ ACCESS PERMITTED ˛˛˛])
			@ 18,26 say mNAME pict [@!]	// bong 08.06.2012
			inkey(.5)
			// LOG IN
			select USERLOG
			NETLOCK('A',0)
			replace USER_ID  with gUSER_ID	,;
					NAME     with mNAME	,;
					TRANCODE with '1'		,;
					TRANDATE with date()	,;
					TRANTIME with time()	,;
					WSTATION with netname()
			commit
			unlock
	    exit
	 else
	    // ERROR([INCORRECT PASSWORD!!!])
		ERROR([INCORRECT USER ID/PASSWORD!!!])
	 endif
      else
	 mPASSWORD = SETPASS()

	 NETLOCK('A',0)
	 replace USER_ID  with encrypt(gUSER_ID),;
		 NAME     with mNAME,  PASSWORD with mPASSWORD,;
		 CRT_DAT  with date(), CRT_BY   with gUSER_ID,;
		 LEVEL    with encrypt('9')
	 commit
	 unlock

	 exit
      endif
      CTR = CTR + 1
	  if iduser == alltrim(gUSER_ID)
		userCTR = userCTR + 1
	  else
		if CTR < 3
			userCTR = userCTR + 1
		endif
		iduser := alltrim(gUSER_ID)
	  endif
   enddo

   select AXMAST
	if CTR > 3 .and. userCTR > 3
	  qqout(chr(7))
	  setcolor(gREVERSE)
	  DRAWBOX(22,20,24,59,2)
	  setcolor(gNORMAL)
	  CENTER(23,gBLINKING,[UNAUTHORIZED USER!  ACCESS DENIED.])
	  _lockuser ()                    //aga.15.02.2006.lock user after 3 wrong passwords
	  // LOCKED OUT
		select USERLOG
		NETLOCK('A',0)
		replace USER_ID  with gUSER_ID	,;
				NAME     with mNAME	,;
				TRANCODE with '3'		,;
				TRANDATE with date()	,;
				TRANTIME with time()	,;
				WSTATION with netname()
		commit
		unlock
	  inkey(3)
	  USER_OK = .F.
	  return ( nil )
	elseif CTR > 3 .and. userCTR < 4
	  qqout(chr(7))
	  setcolor(gREVERSE)
	  DRAWBOX(22,20,24,59,2)
	  setcolor(gNORMAL)
	  CENTER(23,gBLINKING,[UNAUTHORIZED USER!  ACCESS DENIED.])
	//     _lockuser ()                    //aga.15.02.2006.lock user after 3 wrong passwords
	  inkey(3)
	  USER_OK = .F.
	  return ( nil )
	endif
   AX_LEVEL = decrypt(AXMAST->LEVEL)
   if len(mPASSWORD) == 0
      mPASSWORD = SETPASS()
      NETLOCK('R',0)
      replace PASSWORD with mPASSWORD, MOD_DAT  with date(),;
	      MOD_BY   with gUSER_ID
      commit
      unlock
   endif
   
   cCode := g_PAR_BRCH //:= axmast->brcode
   
   IF NETUSE('&g_GRF_PATH\BRCODE',.F.,5)
      DBSETINDEX('&g_GRF_PATH\USER')
      IF BRCODE->(DBSEEK( gUSER_ID ))
	     cCode := g_PAR_BRCH := BRCODE->AMS
      ENDIF
      BRCODE->(DBCLOSEAREA())
   ENDIF
   
   if !NETUSE('&g_GRF_PATH\BRANCHES',.F.,5)
      USER_OK = .F.
      return nil
   endif
   set index to &g_GRF_PATH\BRCODE,&g_GRF_PATH\BRANCHES
   
   aBranch := aBranches( gUSER_ID )
   @ 20,26,23,55 get cCode LISTBOX aBranch DROP;
                 valid CHK_BRCODE(gUSER_ID,cCode)
   read
   if lastkey() != 27
      if !empty(aBranch)
         g_PAR_BRCH := cCode
	  else
	     error("No record in AXBRANCH. Please call Application Support Dept.!")
         USER_OK = .F.
	     return ( nil )
	  endif
   elseif lastkey() == 27
      USER_OK = .F.
	  return ( nil )
   endif
   
   BRANCHES->(dbseek(g_PAR_BRCH))
   
   gSYS_NAME  := gSYS_NAME+' ('+g_PAR_BRCH+'-'+RTRIM(BRANCHES->BRNAME)+')'
   gBRANCH    := '('+g_PAR_BRCH+'-'+RTRIM(BRANCHES->BRNAME)+')'
   
   close databases

   USER_OK = .T.
   return ( nil )
// eof: LOGUSER

static function aBranches( cUser )
   local aList := {}
   local ax_found := .f.

   if !NETUSE('&g_GRF_PATH\AXBRANCH',.F.,5)
      USER_OK = .F.
      return nil
   endif
   set index to &g_GRF_PATH\AXBRANCH
   
   IF BRANCHES->( dbseek(g_PAR_BRCH) )
      aAdd( aList, { padr( trim(branches->brname) +"-"+branches->brcode, 40), ;
                branches->brcode } )
	  default_br := g_PAR_BRCH	
   ENDIF
   
   AXBRANCH->( dbseek(cUser) )
   
   while ! AXBRANCH->( eof() ) .AND. AXBRANCH->user_id == cUser
      BRANCHES->( dbseek(AXBRANCH->brcode) )
	  //if BRANCHES->brcode <> '701' .and. BRANCHES->brcode <> '801'                        //ORC & OALP
	  if BRANCHES->brcode <> default_br
         aAdd( aList, { padr( trim(branches->brname) +"-"+branches->brcode, 40), ;
                     branches->brcode } )
      endif
	  ax_found := .t.	 
	  //endif
      AXBRANCH->( dbskip() )
   enddo
   
   AXBRANCH->(dbclosearea())
   
   if !ax_found
      aList := {}
   endif
   
return aList

****************************************
*
STATIC FUNCTION CHK_BRCODE(gUSER_ID,cCode)
****************************************
LOCAL lRETVAL := .T.
local ax := axmast->(recno())

if cCode == "701" .or. cCode == "801"
   lRETVAL  := .F.
   error([Your Branch Code is not allowed in this system!])
   gUSER_ID := SPACE(6)
else

   IF NETUSE('&g_GRF_PATH\BRCODE',.F.,5)
      DBSETINDEX('&g_GRF_PATH\USER')
      IF BRCODE->(DBSEEK( gUSER_ID ))
	     if BRCODE->(netlock('R',0))
	        BRCODE->AMS := cCode
			BRCODE->(dbunlock())
			BRCODE->(dbcommit())
		 endif
      ENDIF
      BRCODE->(DBCLOSEAREA())
   ENDIF

   dbselectarea('AXMAST')
   AXMAST->(dbgoto(ax))
endif

RETURN lRETVAL

/*ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
 ≥ Set password for new user                                            ≥
 ¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*/
static function SETPASS
   local mPASSWORD:=[],CTR:=0
   do while len(mPASSWORD)=0
      CENTER(23,gBLNK_REV,'Please enter new PASSWORD...')
      qqout(chr(7))
      @ 19,26 say space(20)
      @ 19,26 say []
      mPASSWORD = GETPASS()
      CTR = CTR + 1
      do case
	 case len(mPASSWORD) = 0 .and. CTR = 3
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
            Axmast->status := 'E'
            Axmast->(dbunlock())
         endif
         Axmast->(dbcommit())
      endif

      quit

	 case len(mPASSWORD) = 0
	    ERROR('No PASSWORD entered!')
	    loop
      endcase
      for CTR = 1 to 3
	 CENTER(23,gBLNK_REV,'Please retype new PASSWORD...')
	 qqout(chr(7))
	 @ 19,26 say space(20)
	 @ 19,26 say []
	 if mPASSWORD == GETPASS()
	    exit
	 endif
	 tone(392,2)
	 tone(392,2)
	 tone(392,2)
	 tone(311,8)
	 ERROR('Different password entered!')
      next
   enddo
   if CTR > 3
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
            Axmast->status := 'E'
            Axmast->(dbunlock())
         endif
         Axmast->(dbcommit())
      endif

      quit
   endif

   return mPASSWORD
// eop: SETPASS

/*ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
 ≥ Function    : display goodbye screen                                 ≥
 ≥ Syntax      : LICENSE()                                              ≥
 ¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*/
function LICENSE
   cls
   ET     = time()
   BGDATE = ctod('08/15/1994')
   ENDATE = ctod('09/26/1995')
   UPDATE = ctod('09/11/2014')
   setcolor(gNORMAL)
   @ 00,00 say [Goodbye from ]
   setcolor(gBRIGHT)
   @ row(),col() say [The ] + gSYS_NAME
   setcolor(gNORMAL)
   @ row(),col() say [, active for ] + ELAPTIME(ST,ET)
   @ 07,19-3 to 15,60+3
//   @ 07,60 say '+'
//   for x:= 8 to 14;@x,60 say '≥';next x
//   @ 15,19 say '+'
//   @ 15,20 say repl('ƒ',40 ); @ 15,60 say '+'
   CENTER(8,gBRIGHT,upper(gSYS_NAME))
   @ 10,27 say [      Version : 1.00024]
   @ 11,27 say [ Date Started : ] + DTODMY(BGDATE)
   @ 12,27 say [Date Finished : ] + DTODMY(ENDATE)
   @ 13,27 say [  Last Update : ] + iif(empty(UPDATE),'',DTODMY(UPDATE))
   setcolor(gBRIGHT)
   @ 14,56 say [ORIX]
   setcolor(gNORMAL)
   @ 23,00
   return ( nil )

  Static Function ALTKC()
  if Confirm('Do you want to exit abruptly?')
     setcolor('w/n')
    // license()
     setcolor('w/n')
     set cursor on
     dbcloseall()

      if .not. file('&g_AMS_PATH\USER_ID.NTX')
         if !NETUSE('&g_AMS_PATH\AXMAST',.T.,5)
            USER_OK = .F.
            return ( nil )
         else
            index on decrypt(AXMAST->USER_ID) to &g_AMS_PATH\USER_ID
            use
         endif
      endif

      if !NETUSE ( '&g_AMS_PATH\AXMAST',.F.,5 )
         USER_OK = .F.
         return ( nil )
      endif
      set index to &g_AMS_PATH\USER_ID

      if Axmast->(dbseek(g_USER_ID))
         if Axmast->(netlock('R',5))
            Axmast->status := 'E'
            Axmast->(dbunlock())
         endif
         Axmast->(dbcommit())
      endif


     quit

  endif
  return .t.
// eop: LICENSE


//aga.01.04.2005.dropper
**************************
*
function drop( cmessage )
**************************
   if Drop->(netlock('A',0))
      Drop->user_id := g_user_id
      Drop->date    := date()
      Drop->time    := time()
      Drop->action  := padr( cmessage,70 )
      Drop->(dbunlock())
      Drop->(dbcommit())
   endif
return nil
//.......................

*/*-------------------------*/
*Static function clrscr(nflg)
*/*-------------------------*/
*local x
*      x:=1
*      whil x < 14
*    if nflg
*       tone (200,0)
*    endif
*    x += 1
*    scroll(00,00,11,40,1,+1)
*    @ 11,00 say ' '
*    scroll(00,41,11,80,1,-1)
*    @ 11,00 say ' '
*    scroll(12,00,24,40,-1,+1)
*    @ 12,00 say ' '
*    scroll(12,41,24,80,-1,-1)
*    @ 12,00 say ' '
*    for z = 1  to 40
*      @ 00,00 say ''
*    next
*    //inkey(.2)
*      endd
/*----------*/

//aga.01.04.2005.locking functions
*******************************
*  added by abb ( 02.14.2001 )
*
static function _lockuser()
*******************************

   if Axmast->(dbseek(gUSER_ID))
      Axmast->(netlock('R',0))
      Axmast->locked := .t.
      Axmast->(dbunlock())
   endif

//ALL LOCKED ACCOUNTS ARE STORED IN LOCKUSER.DBF
IF NETUSE('&g_AMS_PATH\LOCKUSER',.F.,5) //PEPE 06.20.2007

    LOCKUSER->(netlock('A',0))

    LOCKUSER->BRCODE   := Axmast->brcode
    LOCKUSER->USER_ID  := gUSER_ID
    LOCKUSER->PASSWORD := AXMAST->PASSWORD
    LOCKUSER->LASTPASS := mLASTPASS
    LOCKUSER->LOCKDATE := DATE()
    LOCKUSER->LOCKTIME := TIME()
    LOCKUSER->WSTATION := NETNAME()

    LOCKUSER->(dbunlock())
    LOCKUSER->(dbcommit())

ELSE
   return
endif

return nil

*******************************
*
* added by abb ( 02.14.2001 )
*
static function _is_locked()
*******************************
local lretval := .f.

   if Axmast-> ( dbseek ( gUSER_ID ) )
      if Axmast->locked
         error ( 'User '+alltrim(guser_id)+' already locked' )
         lretval := .t.
      endif
   endif

return lretval

*********************************
*     copied from glsu0100.prg  used here in gls.prg for expired password
*
static function USERPASS()        // change user password
*********************************
   local mSCREEN,mROW

/**********
   if AXMAST->AX_LEVEL <> '9' .and. gUSER_ID <> decrypt(AXMAST->USER_ID)
      ERROR([Access denied.])
      return
   endif
   mROW    = mOBJ:rowpos+8
********/

   mrow := 18
   mSCREEN = savescreen(mROW-1,28+3,mROW+1,74+3)
   setcolor(gREVERSE)
   @ mROW-1,28+3 to mROW+1,74+3 double
*********   if gUSER_ID == decrypt(AXMAST->USER_ID) .or. (AX_LEVEL <> '9')

   if gUSER_ID == decrypt(AXMAST->USER_ID) .and. .f.
      @ mROW,29+3 clear to mROW,73+3
      @ mROW,29+3 say 'Enter Current Password : '
      if AXMAST->PASSWORD <> GETPASS()
         setcolor(gBRIGHT)
         ERROR('Incorrect PASSWORD!')
         restscreen(mROW-1,28+3,mROW+1,74+3,mSCREEN)
         return
      endif
   endif

   @ mROW,29+3 clear to mROW,73+3
   @ mROW,29+3 say 'Enter New Password : '
   mPASSWORD := GETPASS()
   if len(mPASSWORD) == 0
      setcolor(gBRIGHT)
      ERROR('Invalid NEW PASSWORD!')
      restscreen(mROW-1,28+3,mROW+1,74+3,mSCREEN)
      return .f.     // EVR 02052007
   endif

  if len(mpassword) < 8     // EVR 06062006 - before <5
      setcolor(gBRIGHT)
      ERROR('Password is less than 8!')
      restscreen(mROW-1,28,mROW+1,74,mSCREEN)
      return .f.     // EVR 02052007
   endif

   if alltrim(Axmast->password) == alltrim(mPASSWORD)
      error ( 'You must type a different password' )
      restscreen(mROW-1,28,mROW+1,74,mSCREEN)
      return .f.     // EVR 02052007
   endif

   @ mROW,29+3 clear to mROW,73+3
   @ mROW,29+3 say 'Retype New Password : '
   nPASSWORD := GETPASS()
   if len(nPASSWORD) == 0 .or. mPASSWORD<>nPASSWORD
// EVR if mPASSWORD<>GETPASS()
      setcolor(gBRIGHT)
      ERROR('Password not changed!')
      lOK := .f.     // EVR 02052007
   else
      setcolor(gBRIGHT)
*****8      select AXMAST

      Axmast->(NETLOCK('R',0))
      Axmast->PASSWORD := mPASSWORD
      Axmast->MOD_DAT  := date()
      Axmast->MOD_BY   := gUSER_ID
      Axmast->expired  := date()+90
      Axmast->grace    := 5
      Axmast->(dbunlock())
      Axmast->(dbcommit())

      error ( 'New PASSWORD accepted!' )
      lOK := .t.     // EVR 02052007
   endif
   restscreen(mROW-1,28+3,mROW+1,74+3,mSCREEN)
   setcolor(gBRIGHT)
   return lOK
*..............................

*******************************
*
*
static function logged()             // abb 10.01.2004        // abb
*******************************
   /*                   && RED 042605
   if !NETUSE('&g_AMS_PATH\AXMAST',.F.,5)
      USER_OK = .F.
      return ( nil )
   endif
   set index to &g_AMS_PATH\USER_ID

   if Axmast->(dbseek(g_USER_ID))

      if Axmast->status == 'L'        //

         if netuse( 'c:\Wsconfig',.f.,5 )
            if Wsconfig->(netlock('R',5))
               Wsconfig->flag := .f.
               Wsconfig->(dbunlock())
            endif
            Wsconfig->(dbcommit())
         endif

         close all
         alert ( "ACCESS DENIED ! You are already logged on OR you did not properly exit from the previous session" )

//         quit   temporary lang po, setbwi kasi pagtesting

         quit    // Reinstated by ABB

      endif

   endif
   */
   if true_brch == '001'  //chi 10.28.08
   *--->                                  && RED 042605
		IF NETUSE('&g_GRF_PATH\COMPLOG',.F.,5)
			SET INDEX TO &g_GRF_PATH\COMPLOG3, &g_GRF_PATH\COMPLOG1,;
						 &g_GRF_PATH\COMPLOG2, &g_GRF_PATH\COMPLOG4

			IF COMPLOG->(DBSEEK('AMS   '+PADR(g_USER_ID,6,' ')+'I'))
				COMPLOG->(DBSETORDER(2))
				IF COMPLOG->(DBSEEK(NETNAME()+'AMS   '))
					IF COMPLOG->(NETLOCK('R',0))
						REPLACE COMPLOG->STATUS  WITH 'O'
						REPLACE COMPLOG->SYSTEM  WITH ' '
						REPLACE COMPLOG->USER    WITH ' '
						REPLACE COMPLOG->OUTDATE WITH DATE()
						REPLACE COMPLOG->OUTTIME WITH TIME()
						COMPLOG->(DBCOMMIT())
						COMPLOG->(DBRUNLOCK())
					ENDIF
				ENDIF
				DBCLOSEALL()
				ALERT ( "ACCESS DENIED ! You are already logged on OR you did not properly exit from the previous session" )
				QUIT
			ENDIF
			COMPLOG->(DBCLOSEAREA())
		ENDIF
	ELSE
		xSTR := CHK_PAR(g_USER_ID)+CHK_PAR('AMS')+CHK_PAR(NETNAME())
		if IF(alltrim(CPS_REQST(xSTR,'LOGGED')) == 'F',.f.,.t.)
			ALERT ( "ACCESS DENIED ! You are already logged on OR you did not properly exit from the previous session" )
			DBCLOSEALL()
			QUIT
		ENDIF
			
			
	ENDIF
	
   *--->

   close all

return nil

************************************
*                                         // abb 10.12.2004
function _get_branch(cbrcode)
************************************
   local cretval := space(20)

   IF !EMPTY(cBRCODE)
      if Branches->(dbseek(alltrim(cbrcode)))
         cretval := Branches->brname
      endif
   ENDIF

return alltrim(cretval)
********************************************
*   Description   displays client name
*   Parameters    client code
*   Return value  client name
*function _dispclntname( cbrcode,mclntcode )
********************************************
*   local mretval, mdbf := savedbf( mdbf )
*   Client->( dbsetorder(1) )
*   Client->( dbseek(alltrim(cbrcode)+mclntcode,.f.) )
*   mretval := left( Client->FULLNAME, 40 )
*   restdbf( mdbf )
*return mretval
*
*                  end of the program (ams.prg)
*
*-------------------------------------------------------------------------------
/* EVR 28122006 - removed
FUNCTION UPDT_OL()

IF OL_PARAM->(DBSEEK(TRUE_BRCH))
   IF OL_PARAM->(NETLOCK('R',0))
      REPLACE OL_PARAM->LASTCANO   WITH PARAMETR->LASTCANO
      REPLACE OL_PARAM->LASTAN     WITH PARAMETR->LASTAN
      REPLACE OL_PARAM->LASTOTNO   WITH PARAMETR->LASTOTNO
      REPLACE OL_PARAM->CREDCOM    WITH PARAMETR->CREDCOM
      REPLACE OL_PARAM->COLFYR     WITH PARAMETR->COLFYR
      REPLACE OL_PARAM->COSIGN     WITH PARAMETR->COSIGN
      REPLACE OL_PARAM->RISK_COMM  WITH PARAMETR->RISK_COMM
      REPLACE OL_PARAM->EXEC_COMM  WITH PARAMETR->EXEC_COMM
      REPLACE OL_PARAM->BOARD_COMM WITH PARAMETR->BOARD_COMM
      REPLACE OL_PARAM->LASTJV     WITH PARAMETR->LASTJV
      REPLACE OL_PARAM->COLACODE   WITH PARAMETR->COLACODE
      REPLACE OL_PARAM->PENRATE    WITH PARAMETR->PENRATE
      REPLACE OL_PARAM->LASTSA     WITH PARAMETR->LASTSA
      REPLACE OL_PARAM->TRANDATE   WITH PARAMETR->TRANDATE
      REPLACE OL_PARAM->PREVDATE   WITH PARAMETR->PREVDATE
      OL_PARAM->(DBUNLOCK())	  
      OL_PARAM->(DBCOMMIT())
   ENDIF
ELSE
   IF OL_PARAM->(NETLOCK('A',0))
      REPLACE OL_PARAM->BRCODE     WITH PARAMETR->BRCODE
      REPLACE OL_PARAM->LASTCANO   WITH PARAMETR->LASTCANO
      REPLACE OL_PARAM->LASTAN     WITH PARAMETR->LASTAN
      REPLACE OL_PARAM->LASTOTNO   WITH PARAMETR->LASTOTNO
      REPLACE OL_PARAM->CREDCOM    WITH PARAMETR->CREDCOM
      REPLACE OL_PARAM->COLFYR     WITH PARAMETR->COLFYR
      REPLACE OL_PARAM->COSIGN     WITH PARAMETR->COSIGN
      REPLACE OL_PARAM->RISK_COMM  WITH PARAMETR->RISK_COMM
      REPLACE OL_PARAM->EXEC_COMM  WITH PARAMETR->EXEC_COMM
      REPLACE OL_PARAM->BOARD_COMM WITH PARAMETR->BOARD_COMM
      REPLACE OL_PARAM->LASTJV     WITH PARAMETR->LASTJV
      REPLACE OL_PARAM->COLACODE   WITH PARAMETR->COLACODE
      REPLACE OL_PARAM->PENRATE    WITH PARAMETR->PENRATE
      REPLACE OL_PARAM->LASTSA     WITH PARAMETR->LASTSA
      REPLACE OL_PARAM->TRANDATE   WITH PARAMETR->TRANDATE
      REPLACE OL_PARAM->PREVDATE   WITH PARAMETR->PREVDATE
      OL_PARAM->(DBUNLOCK())
      OL_PARAM->(DBCOMMIT())
   ENDIF
ENDIF
RETURN
*/

//aga.21.04.2005.function for gls report notes
function get_initial(iname, pos, sy, sx, slen)
//..................................
memvar entryname
namelist  := {}
menulist  := {}
userentry := 0
nctr      := 0
hit       := 0
iname     := upper(iname)

if trim(iname) == ""                
   Personel->( dbsetorder(2) )
   entryname [pos] := flook_ONLINE( .t., 'Personel', nil, 'Personnel', 2, 1,, 2,,,,,g_grf_path  )
elseif len(trim(iname)) <= 2 
   entryname [pos] := space(30)
else
   Personel->( dbsetorder(1) )
   if Personel->(dbseek(trim(iname)))  
      entryname [pos] := Personel->Fullname       
   else
      Personel->( dbsetorder(2) )
      Personel->(dbgotop())
      while !Personel->(eof())
          if upper(alltrim(iname)) $ upper(Personel->Fullname)
             aadd(namelist,Personel->Fullname)
             hit++
          end if
          if hit == 8
             exit
          end if
          Personel->(dbskip(+1))
      end do
      scr := savescreen( sy+pos+nctr,sx,sy+pos+nctr+len(namelist),sx+slen )
      if len(namelist) != 0
         while lastkey() != K_ESC
         for nctr := 1 to len(namelist)
             @ sy+pos+nctr, sx prompt substr(namelist[nctr],1,slen) 
         next nctr
         menu to userentry   
         if userentry != 0
            entryname [pos] := namelist[userentry]
            restscreen( sy+pos,sx,sy+pos+len(namelist),sx+slen,scr)
            exit
         endif        
         end do
      else
         entryname [pos] := space(30)
         restscreen( sy+pos,sx,sy+pos+len(namelist),sx+slen,scr)
      end if
   end if
end if

return entryname [pos]

//...................................

*******************************************
* 
function chkpass ( mOPT,mAX_LEVEL,mUSER )                    //aga.14.03.2006.chkpass bypass for module tracking
*******************************************
   local LASTAREA := select()
   cSYS   := g_AMS_PATH + '\USERMOD'
   axpath := g_AMS_PATH

   //drop insertion point
if len(mOPT) > 4 .and. procname(2) == '(b)FLOCATE'  //aga.15.03.2006.preceeding pulldown call
   //alert(mOPT+ " " + mAX_LEVEL + " " + mUSER)

   if !netuse(axpath + '\axmast',.F.,5)
      error('Axmast not found')
      return 
   else
      ordlistadd (axpath + '\user_id')

      axmast->(dbseek(muser))
      if found()
         if axmast->(netlock('R',5))
            axmast->module  := mopt
            axmast->(dbunlock())
         end if
         axmast->(dbcommit())
      end if

      axmast->(dbclosearea())
   end if
end if
   //....................

   if mAX_LEVEL = [9]
      return .t.
   endif

   if .not. file ( IF(cSYS == 'USERMOD','USERMOD.NTX',cSYS+'.NTX' ) )
      //select 0
      //NETUSE("&cSYS",.T.,0)
      //index on DECRYPT(fieldname(1))+fieldname(2) to &cSYS
      //use
	  
	  error("Branch "+STN_BRCH+" has been disconnected! Reset your computer and try again.")  
	  return .f.
   endif

   select 0
   netuse ( '&cSYS',.F.,0 )
   set index to &cSYS
   
   if len(mOPT) > 4

       if !Usermod->(dbseek(mUSER+mOPT))
         use
         select ( LASTAREA )
         error  ('Access Denied!')
         return .F.
      else
         use
         select ( LASTAREA )         
         return .T.
      endif
   endif

   if !Usermod->(dbseek(mUSER+procname(1)))
      error  ( 'Access Denied!' )
      use
      select ( LASTAREA )
      return .F.
   endif

   if mOPT $ USERMOD->RIGHTS
      use
      select ( LASTAREA )
      return .T.
   else
      error  ( 'Access Denied!' )
      use
      select ( LASTAREA )
      return .F.
   endif

return .T.

*************************************
*
static Function Comp_GTRANDATE(mDATE)
*************************************
nTENOR := 0

do while .t.


     if dow(mDATE) = 7 .or. dow(mDATE) = 1
       nTENOR := nTENOR + 1
//       mDATE :=  mDATE+nTENOR
       mDATE :=  mDATE+1
       loop
     endif


     if HOLIDAYS->(dbseek(substr(dtos(mDATE),5,2)+'/'+substr(dtos(mDATE),7,2)) )

      do while Holidays->Holidate == substr(dtos(mDATE),5,2)+'/'+substr(dtos(mDATE),7,2) .and. ;
         !Holidays->(eof())

         if Holidays->Holidate == substr(dtos(mDATE),5,2)+'/'+substr(dtos(mDATE),7,2)
            nTENOR := nTENOR + 1
            mDATE :=  mDATE+1
         endif
      Holidays->(dbskip(+1))
      enddo
      loop

     endif


     exit

enddo	

return mDATE

static function GETUSERID()

		 seek gUSER_ID
		 if !found()
//			ERROR([User ID not found!])
			mUSERID := 'NO'
//			loop
		 ELSE
		   xNAME := AXMAST->NAME
		   mUSERID := 'YES'
		 endif
return mUSERID
