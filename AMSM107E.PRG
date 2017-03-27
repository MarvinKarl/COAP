/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   program id.........:  amsm107e.prg                                         ³
³   description........:  Get Facility                                         ³
³   author.............:  Marvin T. Sabile                                     ³
³   date...............:  8:54 AM 10/9/2013                                    ³
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


******************************************************************************
*
Function Get_Facility(mrefno,mfcltycode,mfclty,mrecno,mdtlcode,ntitle,mdocref2)
******************************************************************************
local mcolor  := setcolor(), mscreen := savescreen( ,,, ), mlogic := .t.
LOCAL NTX := INDEXORD(), mm := ALIAS()
private PRO := 0,PROS := .F., nTOP := .F.,mPRESS := .F.
private mrecno2 := mrecno, mfclty2 := mfcltycode, cdtlcode2 := mdtlcode, cdocref2 := if (mdocref2 == nil,' ',mdocref2)

 aFclty := {}
 _AFcltySearch := {}
 aFCLTY_RECNO  := {}


 fShadow( 14, 1, 22, 78, 2, 'n/w' ) //w+/GR

 dbselectarea('Cadetail')
 Cadetail->(dbseek(mrefno))

 ___GetFacility(mrefno)

     setcolor ( 'n+/n, GR+/n' )

	 @ 15,29 say nTITLE color 'b+/w'
     @ 16,2 say ' Facility        Type           Amount      Term  Effective Rate    Availed'  color 'n/w'
     @ 17,2 to 17,77								  color 'n/w'
	 
	 @ 22,64 say '[UP/DOWN]' 					  		  color 'rb/w'
     //@ 22,39 say '[PGDN]-NEXT' 					  		  color 'n/w'
     //@ 22,52 say '[PGUP]-PREVIOUS'     					  	  color 'n/w'

     do while .t.
      mBX := achoice(18,2, 21, 77, aFclty, .t.,'FCLTY_FUNC')

      do case
         case lastkey() == K_ESC
               exit
  
         case lastkey() == K_ENTER
	      if mPRESS
		     mrecno     := mrecno2
			 mfcltycode := mfclty2
			 mdtlcode   := cdtlcode2
			 if !empty(mfcltycode)
			    mfclty := .t.
			 endif
             exit
	      endif
	    
      endcase
     enddo

   setcolor       ( mcolor )
   restscreen     ( ,,,, mscreen )


DBSELECTAREA(mm)
DBSETORDER(NTX)

return mBX


**************************************
*
STATIC FUNCTION ___GetFacility(mrefno)
**************************************
local NCTR := 0

  dbselectarea('Cadetail')
	  if Cadetail->(dbseek(mrefno))
	  
			  do while Cadetail->brcode+Cadetail->canumber == mrefno  .and. ;
			               !Cadetail->(eof()) 

			//IF Cadetail->BRCODE == left(mrefno,3) .and. Cadetail->CANUMBER == right(mrefno,5)

				   nctr++

						aadd ( aFclty,  padr(' ',' ')   		  +   ;
					   if (Facility->(dbseek(Cadetail->fcltycode)),padr ( Cadetail->fcltycode,5) +'-'+padr ( Facility->FCLTYALIAS,5),space(11) )    + ' ' +   ;
								   IF(Cadetail->include,padr('Main Facility',13),padr('Sub-limit',13))    + ' ' +   ;
								   tran ( Cadetail->PRINCIPAL,"999,999,999.99")  + '    ' +   ;
								   tran ( Cadetail->TERM,"999")       + '      ' +   ;
								   tran ( Cadetail->TRUERATE,"99.9999")   + ' ' +   ;
								   tran ( Cadetail->AVAILED,"999,999,999.99")   + ' '    ;
								 ) 

					aadd ( _AFcltySearch,Cadetail->(RECNO()))	

				  if !nTOP

					IF alltrim(str(NCTR)) == '1'
					   pro++

					  if pro > len(aFCLTY_RECNO) 
						 AADD ( aFCLTY_RECNO,{Cadetail->(RECNO()),0} )
					  ENDIF

					endif

				  endif

			//ENDIF

				IF nctr > 13
						exit
				endif

					Cadetail->(dbskip(+1))


			  enddo
			  
	  endif

RETURN 


**********************************************
*
FUNCTION FCLTY_FUNC (status, curr_elem, curr_row)
**********************************************
local key    := lastkey(),mSAY,cSRCH := space(20),lchar := ' '
local __nctr := 0, getlist := {}, menulist := {},nORGPOS := 0
local _lfound := .f., mscreen1 := savescreen1( ,,, )
LOCAL NTX := Cadetail->(INDEXORD())

   do case
      case key == K_ESC
         return 0

      case key == K_ENTER

	mPRESS := .T.

	DBSETORDER(1)

	__mseekvar := _AFcltySearch[curr_elem]
	
	Cadetail->(dbgoto(__mseekvar))
	
	IF !Cadetail->(EOF()) .OR. !Cadetail->(BOF())

	    If empty(cdocref2)
	       mrecno2   := Cadetail->(recno())
	       mfclty2   := Cadetail->fcltycode	   
		   cdtlcode2 := Cadetail->DTLCODE
		Else
		   If Cadetail->fcltycode == mfclty2
	          mrecno2   := Cadetail->(recno())
	          mfclty2   := Cadetail->fcltycode	   
		      cdtlcode2 := Cadetail->DTLCODE		
		   EndIf
		EndIf
	ENDIF
	
	/***
	if Cadetail->(dbseek(__mseekvar))
	   mrecno2  := Cadetail->(recno()) //Cadetail->brcode+
	   mfclty2  := Cadetail->fcltycode
	endif
	***/

	return 0

      case key == K_PGUP

	       nTOP 	   := .T.
           IF(alltrim(str(pro)) == '1',pros := .T.,pro--)

	       if pros   // Cadetail->(bof()) .OR. Cadetail->BRCODE != g_PAR_BRCH
              mSAY := 'BEGINNING OF FILE'    
              WAITON( mSAY,, 'W+/R' )
              WAITOFF()
	          pros := .F.
		   ELSE

			   dbgoto(aFCLTY_RECNO[pro][1]) //Cadetail->(dbgoto(aFCLTY_RECNO[pro][1]) )

			   if Cadetail->brcode == g_PAR_BRCH

				   aFclty   := {}
				   _AFcltySearch   := {}
				   ___GetFacility()

				   @ 8,14 clear to 21, 68

			   endif
		      
	       endif
		   
		   /**

	       dbgoto(aFCLTY_RECNO[pro][1]) //Cadetail->(dbgoto(aFCLTY_RECNO[pro][1]) )

	       if Cadetail->brcode == g_PAR_BRCH .and. !pros

               aFclty   := {}
               _AFcltySearch   := {}
               ___GetFacility()

               @ 8,14 clear to 21, 68

	       endif
		   
		   **/

	return 

      case key == K_PGDN

	nTOP := .F.
	Cadetail->(dbskip(+1))

	if Cadetail->(eof()) .OR. Cadetail->BRCODE != g_PAR_BRCH
          mSAY := 'END OF FILE' 
          WAITON( mSAY,, 'W+/R' )
          WAITOFF()
	endif

	 if Cadetail->brcode == g_PAR_BRCH 

               aFclty   := {}
               _AFcltySearch   := {}
               ___GetFacility()

               @ 8,14 clear to 21, 68

	endif

        return

    endcase

DBSETORDER(NTX)

return 2



*
*                     End of the program ( amsm107e.prg )
*
