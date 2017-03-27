/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   program id.........:  amsm107f.prg                                         ³
³   description........:  Availment Sheet                                        ³
³   author.............:  Marvin T. Sabile                                     ³
³   date...............:  9:36 AM 3/21/2014                                    ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                         U P D A T E S                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        Who        ³     When      ³               Why                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                   ³               ³                                          ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include "Colf.ch"
#include "Inkey.ch"

*-------------------------------------------------------------------------------
FUNCTION xDLNAME(cDLNME,X,Y,cPROG)
LOCAL lRETVAL := .F.
LOCAL cCOL    := SETCOLOR()
LOCAL nIDX    := DEALER->(INDEXORD())
LOCAL aDEALER := {}, bDEALER := {}
LOCAL nAGL    := 0
LOCAL SCR
local GETLIST := {}   
LOCAL wDEALER

IF LASTKEY() == K_ENTER
   IF EMPTY(ALLTRIM(cDLNME))
      cDLNME  := SPACE(50)
      lRETVAL := .T.
   ELSE
      DEALER->(DBSETORDER(3))

      IF DEALER->(DBSEEK(g_par_brch+RTRIM(cDLNME)) )

         DO WHILE SUBSTR(DEALER->DLRNAME,1,LEN(RTRIM(cDLNME))) == RTRIM(cDLNME) .AND. ;
	 	 !DEALER->(EOF())

            IF DEALER->BRCODE == g_PAR_BRCH
               AADD(aDEALER,DEALER->DLRNAME+' '+DEALER->BRCODE+'-'+DEALER->DLRCODE)
               AADD(bDEALER,DEALER->DLRCODE)
            ENDIF

            DEALER->(DBSKIP())
         ENDDO

         IF LEN(aDEALER) > 0
            *SCR := SAVESCREEN(16,21,19,70)
            *nAGL := ACHOICE(16,21,19,70,aDEALER,,'xUDF')
            SCR  := SAVESCREEN(X,Y,X+3,Y+49)
            nAGL := ACHOICE(X,Y,X+3,Y+49,aDEALER,,'xUDF')

    IF LASTKEY() = K_ENTER
 //              cDLNME := aDEALER[nAGL]
 //              lRETVAL := .T.
		DEALER->(DBSETORDER(1))
		IF DEALER->(DBSEEK(g_PAR_BRCH+bDEALER[nAGL])) //.and. cPROG != 'INQUIRY'    //pepe 01.16.2008
			   cDLNME := DEALER->dlrname//aDEALER[nAGL]
			   lRETVAL := .T.
			endif
	  	
            ELSEIF LASTKEY() == K_ESC
                   cDLNME := SPACE(50)
                   lRETVAL := .F.
            ENDIF
         ELSE
            cDLNME := SPACE(50)
            lRETVAL := .F.
         ENDIF

         *RESTSCREEN(16,21,19,70,SCR)
         RESTSCREEN(X,Y,X+3,Y+49,SCR)

      ELSE
         cDLNME := SPACE(50)
      ENDIF

      DEALER->(DBSETORDER(nIDX))

      SETCOLOR(cCOL)
   ENDIF
ENDIF

RETURN lRETVAL

FUNCTION xUDF(nMODE,nHI,nPOS)
LOCAL nRETVAL := 2

DO CASE
   CASE nMODE == 1 .OR. nMODE == 2
        nRETVAL := 2
   CASE LASTKEY() == K_ENTER
        nRETVAL := 1
   CASE LASTKEY() == K_ESC
        nRETVAL := 0
ENDCASE

RETURN nRETVAL

*
*                     End of the program ( amsm107f.prg )
*
