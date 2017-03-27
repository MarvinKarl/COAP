/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   program ID.........:  amsm0400.prg                                         ³
³   description........:  Account Master File Maintenance                      ³
³   author.............:  Ariel B. Bulan                                       ³
³   date...............:  03:09pm 02/14/95                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                         U P D A T E S                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        Who        ³     When      ³               Why                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ RED K. GUYALA     ³  10/05/2004   ³ Change account no. format from           ³
³                   ³               ³ '99999' to '9999-99999-99999'            ³
³ ABB               ³  10.21.2004   ³ FOR ONLINE                               ³
³                   ³               ³                                          ³
³ aga               ³  14.01.2007   ³ new index for paysked for submodule need ³
³                   ³               ³                                          ³
³ RLV               ³  9/20/2011    ³  Modified Structure for DOSRI Tagging    ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include "Colf.ch"
#include "Inkey.ch"
#include "Achoice.ch"
#define   cursorless    K_TAB * K_CTRL_C - K_ESC



memvar ax_level,g_user_id
if chkpass( procname(),ax_level,g_user_id )   // if the user can access this function
   if amsm0400open()                          // if all .dbf files are opened
      nosnow(.t.)                             // turn on screen snow checking
      fm0400main()                            // call the main program
      nosnow(.f.)                             // turn off screen snow checking
   endif
endif
__mrelease( "*", .t.)
dbcloseall()
return
************************************************************
* Desc ¯ Account Master File Maintenance's main program
static function fm0400main()
************************************************************
local keys_ := { '<F2>\Edit ', '<F4>\Search ','<F5>\Details ', '<F6>\Status ','<F10>\More ', '<Esc>\' }
local nrow := 5, mrow := 1, mbanner := 'Account Master File Maintenance'
LOCAL cBRCODES := g_PAR_BRCH
memvar g_sys_name,g_user_id,mtrandate                       
private sbrcode := g_PAR_BRCH     // EVR 28122006 - changed from Parametr->brcode

//cBRCODES := ACC_BRCH(g_USER_ID)

dbselectar( 'Acctmast' )
//
// Acctmast->( dbgotop() )
//
Acctmast->( dbseek(sbrcode) )

if fsearch (@sbrcode)
   scr_make ( keys_, 3, 1, 22, 78, mbanner )
   while eval( { || disp_record( cBRCODES ),;
                    gkey0400( @mrow, @nrow, cBRCODES ) ;
               };
             );enddo
endif
return nil
**********************************************
static function gkey0400( mrow, nrow, cBRCODES )
**********************************************
   local mretval := .t., mkey
   LOCAL nTOPREC, nBOTREC, lEDGE := .F.
   LOCAL cNXTVALBR, cCURBRCH, cNXTBR, lNXTVALREC := .F.
   LOCAL SCRSKIP, aBLINK := {}, nLOOP := 1
   memvar ax_level, g_user_id

   AADD(aBLINK,'ú')
   AADD(aBLINK,'ù')
   AADD(aBLINK,'')
   AADD(aBLINK,'+')
   AADD(aBLINK,'*')
   AADD(aBLINK,'')

   mkey := inkey(0)

   do case

      case mkey == K_UP .or. mkey == K_PGUP
/***
           SCRSKIP := SAVESCREEN(22,28,22,54)
           @ 22,28 SAY '[ Searching next record   ]' COLOR 'W+/N'
           nTOPREC := RECNO()
           cCURBRCH := ACCTMAST->BRCODE

           IF EVAL( { || DBSKIP( -1 ), BOF() } )
              mSAY := 'BEGINNING OF FILE'
           ELSE
              //IF !(ACCTMAST->BRCODE $ &cBRCODES)
			  IF !AXBRANCH->(DBSEEK(g_USER_ID+ACCTMAST->BRCODE))
			  
                 @ 22,28 SAY '[ Searching next branch   ]' COLOR 'W+/N'
                 cNXTVALBR := NXTVALBR( cCURBRCH, cBRCODES ,'BACKWARD')

                 DO WHILE .T.
                    @ 22,52 SAY aBLINK[nLOOP] COLOR 'W+/N'
                    IIF(nLOOP = 6, nLOOP := 1, nLOOP++)

                    IF cNXTVALBR == NIL
                       mSAY := 'BEGINNING OF FILE'
                       DBGOTO(nTOPREC)
                       lEDGE := .T.
                       EXIT
                    ELSE
                       cNXTBR := PADL( ALLTRIM( STR( VAL( cNXTVALBR ) + 1 ) ),3,'0' )
                       IF cNXTBR == cCURBRCH
                          mSAY := 'BEGINNING OF FILE'
                          DBGOTO(nTOPREC)
                          lEDGE := .T.
                          EXIT
                       ELSE
                          IF ACCTMAST->(DBSEEK(cNXTVALBR))
                             DO WHILE .T.
                                @ 22,52 SAY aBLINK[nLOOP] COLOR 'W+/N'
                                IIF(nLOOP = 6, nLOOP := 1, nLOOP++)

                                IF ACCTMAST->(DBSEEK(cNXTBR))
                                   ACCTMAST->(DBSKIP(-1))
                                   //IF ACCTMAST->BRCODE $ &cBRCODES
								   IF AXBRANCH->(DBSEEK(g_USER_ID+ACCTMAST->BRCODE))
                                      lNXTVALREC := .T.
                                      EXIT
                                   ENDIF
                                ELSE
                                   cNXTBR := PADL( ALLTRIM( STR( VAL( cNXTBR ) + 1 ) ),3,'0' )
                                   IF cNXTBR == cCURBRCH
                                      mSAY := 'BEGINNING OF FILE'
                                      DBGOTO(nTOPREC)
                                      lEDGE := .T.
                                      EXIT
                                   ENDIF
                                ENDIF
                             ENDDO
                          ELSE
                             cNXTVALBR := NXTVALBR( cNXTVALBR, cBRCODES ,'BACKWARD')
                          ENDIF
                          IF lEDGE .OR. lNXTVALREC
                             EXIT
                          ENDIF
                       ENDIF
                    ENDIF
                 ENDDO

              ENDIF
           ENDIF
           RESTSCREEN(22,28,22,54,SCRSKIP)
***/

      case mkey == K_DOWN .or. mkey == K_PGDN
/***
           SCRSKIP := SAVESCREEN(22,28,22,54)
           @ 22, 28 SAY '[ Searching next record   ]' COLOR 'W+/N'
           nBOTREC := RECNO()
           cCURBRCH := ACCTMAST->BRCODE

           IF EVAL( { || DBSKIP( +1 ), EOF() } )
              MSAY := 'END OF FILE'
              MPOS := LASTREC()
           ELSE
              //IF !(ACCTMAST->BRCODE $ &cBRCODES)    && user has no rights for this branch
			  IF !AXBRANCH->(DBSEEK(g_USER_ID+ACCTMAST->BRCODE))
                 @ 22, 28 SAY '[ Searching next branch   ]' COLOR 'W+/N'
                 cNXTVALBR := NXTVALBR( cCURBRCH, cBRCODES ,'FORWARD')

                 DO WHILE .T.
                    @ 22,52 SAY aBLINK[nLOOP] COLOR 'W+/N'
                    IF(nLOOP = 6, nLOOP := 1, nLOOP++)

                    IF cNXTVALBR == NIL
                       MSAY := 'END OF FILE'
                       DBGOTO(nBOTREC)
                       lEDGE := .T.
                       EXIT
                    ELSE
                       IF ACCTMAST->(DBSEEK(cNXTVALBR))
                          //IF ACCTMAST->BRCODE $ &cBRCODES
						  IF AXBRANCH->(DBSEEK(g_USER_ID+ACCTMAST->BRCODE))
                             EXIT
                          ENDIF
                       ELSE
                          cNXTVALBR := NXTVALBR( cNXTVALBR, cBRCODES ,'FORWARD')
                       ENDIF
                    ENDIF
                 ENDDO

              ENDIF
           ENDIF
           RESTSCREEN(22,28,22,54,SCRSKIP)
***/
      case mkey == K_F2
           if CURRBRCH(ACCTMAST->BRCODE) .AND. chkpass('E',ax_level,g_user_id)

              if Acctmast->STATUS == '1' .or. Acctmast->STATUS == '2'         // ACTIVE //aga.13.07.2005.added past due editing by ma'am cynthia
                 tones       ()
                 edit_record ()
              else
                 error ( "Record can't be Edited!" )
              endif

           endif
      case mkey == K_F4
           if chkpass('S',ax_level,g_user_id)
              if( Acctmast->(eof()), error('Nothing to Search!'), amsmsearch() )
           endif
      case mkey == K_F5
           if chkpass('S',ax_level,g_user_id)
              tones() ; f0400details()
           endif
	  case mkey == K_F6
           if chkpass('E',ax_level,g_user_id)
				if AMSJVLOG->(dbseek(ACCTMAST->BRCODE+ACCTMAST->ACCTNO))
					
					if !AMSHIST->(dbseek(ACCTMAST->BRCODE+ACCTMAST->ACCTNO))
						edit_status()
					else
						WARN('Account already has existing payment/s. Cancellation denied..  ',1)
					endif
					
				ELSE
					WARN('Account does not exist in AMSJVLOG',1)
				endif	
           endif
      case mkey == K_F9

           if chkpass ( 'S',ax_level,g_user_id)

              if Acctmast->Status == '6'       // SOLD nga ba? 8.27.2001 abb

                 __adbfs := savescreen ( ,,, )

                 tone(500,0)
                 tone(800,0)
                 tone(600,0)

                 fWind0100 ( 7, 10, 9, 74, 'w+/gr', '', 'bg+/gr' )

                 @ 8,11 say 'Sold To  '+ ffind0100 ( Acctmast->soldto, 38 )
                 inkey(0)
                 restscreen ( ,,,, __adbfs )

              endif
           endif

      case mkey == K_F10
           if chkpass('S',ax_level,g_user_id)
              if Acctmast->( eof() )
                 error( 'Nothing to Inform!' )
              else

                 tones()
                 sec_menu( .t. , 'ACCTMAST' )

              endif   
           endif
      case mkey == K_ESC
           if exitmod()
              mretval := !mretval
           endif
   endcase
   tb_indicator( mkey, @mrow, @nrow, 78, 5, 20 )
   IF( lEDGE, EVAL({ || TONE( 60, .5 ), waiton( mSAY, .F., 'N/W', 9 ) }) , NIL )

return( mretval )
*****************************
static function edit_record()
*****************************
local getlist := {}, mstatus     := Acctmast->STATUS   , mrevdate  := Acctmast->REVDATE ,;
                     mmodepay    := Acctmast->PAYMODE  , mrevfreq  := Acctmast->REVFREQ ,;
                     mcltrltype  := Acctmast->CLTRLTYPE, morixunit := Acctmast->ORIXUNIT,;
                     mcbunitcode := Acctmast->UNITCODE , mcredtype := Acctmast->CREDTYPE,;
                     mmrr_rate   := Acctmast->MRR_RATE , mtb_rate  := Acctmast->TB_RATE
local morixbrrate := Acctmast->orixbrrate           // abb 10.03.2002 SSR#29
local mcursor := setcursor(), mcont := .t.
local mstat_choices := { '1 = Active       ','2 = Past Due     ','3 = In Litigation','4 = Repossessed  ','5 = Written-off  ',"6 = Sold Rec'bles" }
local mdocrefchoices  := assign_elements( mdocrefchoices , 1 ), mfreqchoices := assign_elements( mfreqchoices, 2 ),;
      mpaymodechoices := assign_elements( mpaymodechoices, 3 ), mrevchoices  := assign_elements( mrevchoices , 4 )

   center( 24, 'w+/n','® Edit Record ¯')
   setcolor( 'gr+/b, w+/g,,, gr+/b' ) 
   while mcont
        //setpos( 04, 59 ) ; aadd( getlist, _get_( mstatus    , "mstatus"    , "@X"     ,, {|| fgetstatus( @mstatus, mstat_choices ) } ):display() )
        //setpos( 17, 23 ) ; aadd( getlist, _get_( mrevdate   , "mrevdate"   , "@D"     ,, {|| if( lastkey()!=K_ESC,.t.,.f. )} ):display() )
        setpos( 18, 23 ) ; aadd( getlist, _get_( mmodepay   , "mmodepay"   , "@X"     ,, {|| if( lastkey()!=K_ESC, chkpaymode   ( mpaymodechoices , @mmodepay ,18 , 23 ), .f. ) } ):display() )
        setpos( 19, 23 ) ; aadd( getlist, _get_( mrevfreq   , "mrevfreq"   , "@X"     ,, {|| if( lastkey()!=K_ESC, chkreviewfreq( mrevchoices     , @mrevfreq ,19 , 23 ), .f. )} ) :display() )
        setpos( 20, 23 ) ; aadd( getlist, _get_( mcltrltype , "mcltrltype" , "@X"     ,, {|| if( lastkey()!=K_ESC, chkcltrltype ( @mcltrltype     , 20,23 ),.f. ) } ):display() )
        setpos( 21, 23 ) ; aadd( getlist, _get_( morixunit  , "morixunit"  , "@X"     ,, {|| if( lastkey()!=K_ESC, chkcorixunitcode ( @morixunit  , 21,23 ),.f. ) } ):display() )
        setpos( 17, 59 ) ; aadd( getlist, _get_( mcbunitcode, "mcbunitcode", "@X"     ,, {|| if( lastkey()!=K_ESC, chkcbunitcode ( @mcbunitcode   , 17,59 ),.f. ) } ):display() )
        setpos( 18, 59 ) ; aadd( getlist, _get_( mcredtype  , "mcredtype"  , "@X"     ,, {|| if( lastkey()!=K_ESC, chkcredittype ( @mcredtype     , 18,59,32,21 ),.f. ) } ):display() )
        setpos( 19, 59 ) ; aadd( getlist, _get_( mmrr_rate  , "mmrr_rate"  , "99.9999",, {|| if( lastkey()!=K_ESC,.t.,.f.)} ):display() )
        setpos( 20, 59 ) ; aadd( getlist, _get_( mtb_rate   , "mtb_rate"   , "99.9999",, {|| if( lastkey()!=K_ESC,.t.,.f.)} ):display() )
        setpos( 21, 59 ) ; aadd( getlist, _get_( morixbrrate, "morixbrrate" , "99.9999",, {|| if( lastkey()!=K_ESC,.t.,.f.)} ):display() )

        setcursor( 3 )
        readmodal(getlist) ; getlist := {}
        setcursor( 0 )

        if ( lastkey()==K_ESC,if( esckey(), mcont:=.f., mcont:=.t. )      ,;
                              if( confirm( 'Are all entries correct?' ),;
                                      eval({|| MSGWIN(9,35,'Saving','W+/BG','R*/BG','ON'),;  //aga.13.07.2005.drop trace for editing
                                               if (Acctmast->STATUS != mstatus        ,drop ( alltrim(g_user_id)+' '+'Edits acctno(acctmast) '+ substr(Acctmast->acctno,-5,5) + " status from "     + Acctmast->STATUS          + " to " + mstatus),), ;  
                                               if (Acctmast->REVDATE != mrevdate      ,drop ( alltrim(g_user_id)+' '+'Edits acctno(acctmast) '+ substr(Acctmast->acctno,-5,5) + " revdate from "    + dtos(Acctmast->REVDATE)   + " to " + dtos(mrevdate)) ,), ;  
                                               if (Acctmast->PAYMODE != mmodepay      ,drop ( alltrim(g_user_id)+' '+'Edits acctno(acctmast) '+ substr(Acctmast->acctno,-5,5) + " paymode from "    + Acctmast->PAYMODE         + " to " + mmodepay),), ;  
                                               if (Acctmast->REVFREQ != mrevfreq      ,drop ( alltrim(g_user_id)+' '+'Edits acctno(acctmast) '+ substr(Acctmast->acctno,-5,5) + " revfreq from "    + Acctmast->REVFREQ         + " to " + mrevfreq),), ;  
                                               if (Acctmast->CLTRLTYPE != mcltrltype  ,drop ( alltrim(g_user_id)+' '+'Edits acctno(acctmast) '+ substr(Acctmast->acctno,-5,5) + " cltrltype from "  + Acctmast->CLTRLTYPE       + " to " + mcltrltype),), ;  
                                               if (Acctmast->ORIXUNIT  != morixunit   ,drop ( alltrim(g_user_id)+' '+'Edits acctno(acctmast) '+ substr(Acctmast->acctno,-5,5) + " orixunit from "   + Acctmast->ORIXUNIT        + " to " + morixunit),), ;  
                                               if (Acctmast->UNITCODE  != mcbunitcode ,drop ( alltrim(g_user_id)+' '+'Edits acctno(acctmast) '+ substr(Acctmast->acctno,-5,5) + " cbunitcode from " + Acctmast->UNITCODE        + " to " + mcbunitcode),), ;  
                                               if (Acctmast->CREDTYPE  != mcredtype   ,drop ( alltrim(g_user_id)+' '+'Edits acctno(acctmast) '+ substr(Acctmast->acctno,-5,5) + " credtype from "   + Acctmast->CREDTYPE        + " to " + mcredtype),), ;  
                                               if (Acctmast->MRR_RATE  != mmrr_rate   ,drop ( alltrim(g_user_id)+' '+'Edits acctno(acctmast) '+ substr(Acctmast->acctno,-5,5) + " mrr_rate from "   + str(Acctmast->MRR_RATE)   + " to " + str(mmrr_rate)),), ;  
                                               if (Acctmast->TB_RATE   != mtb_rate    ,drop ( alltrim(g_user_id)+' '+'Edits acctno(acctmast) '+ substr(Acctmast->acctno,-5,5) + " tb_rate from "    + str(Acctmast->TB_RATE)    + " to " + str(mtb_rate)),), ;  
                                               if (Acctmast->ORIXBRRATE != morixbrrate,drop ( alltrim(g_user_id)+' '+'Edits acctno(acctmast) '+ substr(Acctmast->acctno,-5,5) + " orixbrrate from " + str(Acctmast->ORIXBRRATE) + " to " + str(morixbrrate)),), ;  
                                               mcont := .f.               ,;
                                               Acctmast->(netlock('R',0)) ,;
                                               Acctmast->STATUS    := mstatus   ,;
                                               Acctmast->REVDATE   := mrevdate  ,;
                                               Acctmast->PAYMODE   := mmodepay  ,;
                                               Acctmast->REVFREQ   := mrevfreq  ,;
                                               Acctmast->CLTRLTYPE := mcltrltype,;
                                               Acctmast->ORIXUNIT  := morixunit ,;
                                               Acctmast->UNITCODE  := mcbunitcode,;
                                               Acctmast->CREDTYPE  := mcredtype ,;
                                               Acctmast->MRR_RATE  := mmrr_rate ,;
                                               Acctmast->TB_RATE   := mtb_rate  ,;
                                               Acctmast->ORIXBRRATE:= morixbrrate,;
                                               Acctmast->brcode    := sbrcode    ,;
                                               Acctmast->(dbunlock()) ,;
                                               Acctmast->(dbcommit()) ,;
                                               MSGWIN(9,35,'Saving',,,'OFF') ;
                                      }),;
                                nil);
           )
   enddo
   center( 24, 'w+/n','               ')
return nil
***********************************
static function edit_status()
***********************************
local getlist := {}, mstatus     := Acctmast->STATUS   , mcont := .t.
local xstat_choices := { '0 = Cancelled    '} //,'1 = Active       ','2 = Past Due     ','3 = In Litigation','4 = Repossessed  ','5 = Written-off  ',"6 = Sold Rec'bles" }
private xstatus, mapprover:= ' ', mduetot := 0
   center( 24, 'w+/n','® Change Status ¯')
   setcolor( 'gr+/b, w+/g,,, gr+/b' ) 
   while mcont
        setpos( 04, 59 ) ; aadd( getlist, _get_( mstatus    , "mstatus"    , "@X"     ,, {|| xgetstatus( @mstatus, xstat_choices ) } ):display() )

        setcursor( 3 )
        readmodal(getlist) ; getlist := {}
        setcursor( 0 )

        if ( lastkey()==K_ESC,if( esckey(), mcont:=.f., mcont:=.t. )      ,;
                              if( xcancelval(,@mapprover),;
                                      eval({|| MSGWIN(9,35,'Saving','W+/BG','R*/BG','ON'),;  //aga.13.07.2005.drop trace for editing
                                               if (Acctmast->STATUS != xstatus        ,drop ( alltrim(g_user_id)+' '+'Edits acctno(acctmast) '+ substr(Acctmast->acctno,-5,5) + " status from "     + Acctmast->STATUS          + " to " + mstatus),), ;  
                                               mcont := .f.               ,;
                                               Acctmast->(netlock('R',0)) ,;
                                               Acctmast->STATUS    := xstatus   ,;
                                               Acctmast->(dbunlock()) ,;
                                               Acctmast->(dbcommit()) ,;
											   avail_reverse(),;
											   CANCLACT->(netlock('A',0)) ,;    //RLV Audit trail
											   CANCLACT->acctno  := Acctmast->acctno,;
											   CANCLACT->brcode  := Acctmast->brcode,;
											   CANCLACT->user_id := g_user_id 	    ,;
											   CANCLACT->date    := date() 		    ,;
											   CANCLACT->time    := time() 		    ,;
											   CANCLACT->approver:= mapprover 	    ,;
                                               CANCLACT->(dbunlock()) 			    ,;
                                               CANCLACT->(dbcommit()) 			    ,;
											   cancelsked(@mduetot) 			    ,;
											   jv_reversal() 					    ,;
                                               MSGWIN(9,35,'Saving',,,'OFF') ,;
											   alert('Account successfully CANCELLED!!');
                                      }),;
                                nil);
			)
   enddo
   center( 24, 'w+/n','                 ')
return nil
											//   AMSHIST->(netlock('A',0)) 		    ,;
											//   AMSHIST->BRCODE := Acctmast->brcode  ,;
											//   AMSHIST->ACCTNO := Acctmast->acctno  ,;
											//   AMSHIST->PAYCODE := '7 '             ,;
											//   AMSHIST->REFDATE := date()   	    ,;
											//   AMSHIST->ORAMOUNT := mduetot 	    ,;
											//   AMSHIST->PENALTY  := mduetot 	    ,;
                                            //   AMSHIST->(dbunlock())        	    ,;
                                            //   AMSHIST->(dbcommit())          	    ,;

											
											

											
											
*****************************************
static function avail_reverse()
*****************************************
local nPRNAVAIL

if ACCTMAST->docref == '1'
	
	if CAHEADER->(dbseek(ACCTMAST->brcode+ACCTMAST->refno))
		
		if CAHEADER->(netlock('R',0))
		   CAHEADER->prnavail := CAHEADER->prnavail - ACCTMAST->principal
		   CAHEADER->availed  := CAHEADER->availed - ACCTMAST->credamt
		endif
		   CAHEADER->(dbunlock())
		   CAHEADER->(dbcommit())
		
	endif
	
elseif ACCTMAST->docref == '2'

	if OTICKET->(dbseek(ACCTMAST->brcode+ACCTMAST->refno))
		
		if OTICKET->(netlock('R',0))
		   OTICKET->prnavail := OTICKET->prnavail - ACCTMAST->principal
		   OTICKET->CRDAVAIL := OTICKET->CRDAVAIL - ACCTMAST->credamt
		endif
		   OTICKET->(dbunlock())
		   OTICKET->(dbcommit())
		
	endif
	
endif


RETURN NIL

*******************************
static function jv_reversal()
*******************************

LOCAL NPRT1,XPRT1,NPRT2,XPRT2, ntrn
local ltrue:=.t.
local ntrandate,nbrcode,ntrancode,ntrantype,ntramount
local npartix1,npartix2,npartix3,npartix4,npartix5
local nusercode,nadjmntcode,nAdjsource,nLcradj,npost_date
LOCAL nglcode,ndrcr,nnamount, ntrancode2, nbrcode2,njv,newtr 
local mREVERSE := .f. ,nApproved, nAprvuser, nAprvdate, origtrnumber

if AMSJVLOG->(dbseek(ACCTMAST->brcode+ACCTMAST->acctno))
	do while ACCTMAST->brcode+ACCTMAST->acctno == AMSJVLOG->brcode+AMSJVLOG->acctno
		if !AMSJVLOG->cancelled
			if TRANHEAD->(dbseek(AMSJVLOG->brcode+AMSJVLOG->trnumber))
					Ol_param->(dbseek(g_PAR_BRCH))
						do while ltrue 		//******determine last JV No.
							if ol_param->brcode == AMSJVLOG->brcode
							  njv := ol_param->lastjvno
							  ol_param->(dbskip(1))
							else
							  ltrue := .f.
							endif
						enddo	

						newtr:=alltrim(str(val(njv)+1))
					origtrnumber:= Tranhead->trnumber
					ntrandate   := Tranhead->trandate   
					nbrcode     := Tranhead->brcode     
					ntrancode   := Tranhead->trancode   
					ntrantype   := Tranhead->trantype   
					ntramount   := Tranhead->tramount   
					npartix1    := Tranhead->partix1   
					npartix2    := Tranhead->partix2   
					npartix3    := Tranhead->partix3
					npartix4    := Tranhead->partix4
					npartix5    := Tranhead->partix5
					nusercode   := Tranhead->usercode
					nAdjmntcode := Tranhead->Adjmntcode
					nAdjsource  := Tranhead->Adjsource 
					nLcradj     := Tranhead->Lcradj    
					npost_date  := Tranhead->post_date 
					nApproved   := Tranhead->Approved
					
					 if Tranhead->(netlock('A',0))
						Tranhead->trandate   := ntrandate 
						Tranhead->trnumber   := newtr
						Tranhead->brcode     := nbrcode
						Tranhead->trancode   := ntrancode
						Tranhead->trantype   := ntrantype
						Tranhead->tramount   := ntramount
						Tranhead->partix1    := npartix1
						Tranhead->partix2    := npartix2
						Tranhead->partix3    := npartix3
						Tranhead->partix4    := npartix4
						Tranhead->partix5    := npartix5
						Tranhead->usercode   := nusercode
						Tranhead->Adjmntcode := nAdjmntcode         // nAdjmntcode
						Tranhead->Adjsource  := nAdjsource
						Tranhead->Lcradj     := nLcradj
						Tranhead->post_date  := npost_date
						Tranhead->Approved   := nApproved  
						Tranhead->aprvuser   := nAprvuser
						Tranhead->Aprvdate   := nAprvdate
							Tranhead->(dbunlock())
						Tranhead->(dbcommit())	
					 endif
					  
						
					 if TRANHEAD->(dbseek(AMSJVLOG->brcode+AMSJVLOG->trnumber))

							NPRT1:= SUBSTR(TRANHEAD->PARTIX1,11,70)  //correct
							XPRT1:= 'TO REVERSE '+ NPRT1
					
							if TRANHEAD->(netlock('R',0))
								TRANHEAD->PARTIX1 := XPRT1	
								TRANHEAD->(dbunlock())
								TRANHEAD->(dbcommit())
							endif
							
					 endif
						
							do while TRANDTLS->(dbseek(AMSJVLOG->brcode+AMSJVLOG->trnumber))//TRANDTLS->brcode+TRANDTLS->trnumber ==;
								 //AMSJVLOG->brcode+AMSJVLOG->trnumber

								if TRANDTLS->drcr == '1'
								  if Trandtls->(netlock('R',0))
									 Trandtls->TRNUMBER   :=  newtr
									 Trandtls->DRCR       := '2'          // DEBIT
									 Trandtls->(dbunlock())
									 Trandtls->(dbcommit())
								  endif
								else
								  if Trandtls->(netlock('R',0))
									 Trandtls->TRNUMBER   := newtr
									 Trandtls->DRCR       := '1'          // DEBIT
									 Trandtls->(dbunlock())
									 Trandtls->(dbcommit())			
								  endif
								endif	
							 TRANDTLS->(DBSKIP(1))
							
							enddo	

							do while ADJACCTS->(dbseek(AMSJVLOG->brcode+AMSJVLOG->trnumber))	
							  if ADJACCTS->(netlock('R',0))
								  ADJACCTS->(dbdelete())
							  endif
								 ADJACCTS->(DBCOMMIT())
								 ADJACCTS->(DBUNLOCK())	
							enddo	

						if Ol_param->(dbseek(g_PAR_BRCH))
							if Ol_param->(netlock('R', 0))
							  cJVNO              := alltrim(str(val(Ol_param->LASTJVNO)+1))
							  Ol_param->LASTJVNO := cJVNO
							endif
							Ol_param->(dbunlock())
							Ol_param->(dbcommit())
						endif



							mREVERSE := .t.
							
						if CNREVLOG->( netlock( 'A', 0 ) )
								  CNREVLOG->brcode     := TRANHEAD->brcode
								  CNREVLOG->trnumber   := TRANHEAD->trnumber 
								  CNREVLOG->acctno     := ACCTMAST->acctno
								  CNREVLOG->amount     := TRANHEAD->tramount 
								  CNREVLOG->JVDATE     := TRANHEAD->trandate 
								  CNREVLOG->postdate   := TRANHEAD->post_date
								  CNREVLOG->ORIGJVNO   := origtrnumber
						endif
							
						CNREVLOG->(dbunlock())
						CNREVLOG->(dbcommit())
							

			elseif GLTRANHD->(dbseek(AMSJVLOG->brcode+AMSJVLOG->trnumber))///CLOSED ENTRY

				if Ol_param->(dbseek(g_PAR_BRCH))
					if Ol_param->(netlock('R', 0))
					  cJVNO              := alltrim(str(val(Ol_param->LASTJVNO)+1))
					  Ol_param->LASTJVNO := cJVNO
					endif
					Ol_param->(dbunlock())
					Ol_param->(dbcommit())
				endif

				if Tranhead->(netlock('A',0))

					Tranhead->trandate   := gTRANDATE
					Tranhead->trnumber   := cJVNO
					Tranhead->brcode     := Gltranhd->brcode
					Tranhead->trancode   := if( Gltranhd->Trancode == '1', '3', Gltranhd->Trancode )
					Tranhead->trantype   := Gltranhd->trantype
					Tranhead->tramount   := Gltranhd->tramount

					NPRT1:= SUBSTR(Gltranhd->PARTIX1,11,70)  //correct
					XPRT1:= 'TO REVERSE '+ NPRT1  
					
					Tranhead->partix1    := XPRT1             // Gltranhd->partix1
					Tranhead->partix2    := Gltranhd->partix2
					Tranhead->partix3    := Gltranhd->partix3
					Tranhead->partix4    := Gltranhd->partix4
					Tranhead->partix5    := Gltranhd->partix5
					
					Tranhead->usercode   := Gltranhd->usercode
					Tranhead->Adjmntcode := '1'//Gltranhd->Adjmntcode
					Tranhead->Adjsource  := Gltranhd->Adjsource
					Tranhead->Lcradj     := '5' //Gltranhd->Lcradj
					Tranhead->post_date  := date()
					Tranhead->Approved   := .t.
					Tranhead->aprvuser   := 'SYSTEM'
					Tranhead->Aprvdate   := date()

					Tranhead->(dbunlock())
					Tranhead->(dbcommit())


					if Gltrandt->(dbseek(Gltranhd->BRCODE+Gltranhd->TRNUMBER))

			 
					  do while Gltrandt->BRCODE   == Gltranhd->BRCODE     .and. ;
								Gltrandt->TRNUMBER == Gltranhd->TRNUMBER   .and. ;
							  !Gltrandt->(eof())


						 if Trandtls->(netlock('A',0))
							Trandtls->TRNUMBER   := cJVNO
							Trandtls->GLCODE     := Gltrandt->GLCODE
							Trandtls->DRCR       := if (Gltrandt->DRCR == '1','2','1')

							Trandtls->AMOUNT     := Gltrandt->Amount
							Trandtls->TRANCODE   := if( Gltrandt->Trancode == '1', '3', Gltrandt->Trancode )
							Trandtls->BRCODE     := Gltrandt->Brcode
							Trandtls->(dbunlock())
							Trandtls->(dbcommit())
						 endif

						 Gltrandt->(dbskip(+1))

					  enddo

					  if Adjmast->(dbseek(Gltranhd->Brcode+Gltranhd->Trnumber))

						do while Adjmast->BRCODE   == Gltranhd->BRCODE     .and. ;
								Adjmast->TRNUMBER == Gltranhd->TRNUMBER   .and. ;
								!Adjmast->(eof())

						 if Adjaccts->(netlock('A',0))
							Adjaccts->TRNUMBER  := cJVNO
							Adjaccts->ACCNTNO_1 := Adjmast->ACCNTNO_1
							Adjaccts->AMOUNT    := Adjmast->AMOUNT
							Adjaccts->ACCTNAME1 := Adjmast->ACCTNAME1
							Adjaccts->ORIGIN    := Adjmast->ORIGIN
							Adjaccts->STATUS    := Adjmast->STATUS
							Adjaccts->DRCR      := if (Adjmast->DRCR == '1','2','1')
							Adjaccts->BRCODE    := Adjmast->BRCODE
							Adjaccts->(dbunlock())
							Adjaccts->(dbcommit())
						 endif

						 Adjmast->(dbskip(+1))

						enddo

					  endif

					endif

				endif

				mREVERSE := .t.
				
				if CNREVLOG->( netlock( 'A', 0 ) )
						  CNREVLOG->brcode     := TRANHEAD->brcode
						  CNREVLOG->trnumber   := TRANHEAD->trnumber 
						  CNREVLOG->acctno     := ACCTMAST->acctno
						  CNREVLOG->amount     := TRANHEAD->tramount 
						  CNREVLOG->JVDATE     := TRANHEAD->trandate 
						  CNREVLOG->postdate   := TRANHEAD->post_date
						  CNREVLOG->ORIGJVNO   := GLTRANHD->trnumber
				endif
					
				CNREVLOG->(dbunlock())
				CNREVLOG->(dbcommit())		
			endif
			AMSJVLOG->(dbskip(1))
		endif	
	enddo
endif  // AMSJVLOG
//return mREVERSE


return

*********************************************************
static function cancelsked ( mduetot )
*********************************************************



if Paysked->(dbseek(ACCTMAST->brcode+ACCTMAST->acctno+'D'))
	do while Paysked->(dbseek(ACCTMAST->brcode+ACCTMAST->acctno+'D'))
		PAYSKED->(netlock('R',0))
		PAYSKED->status := 'X'
		mduetot += Paysked->amort
		//PAYSKED->(DBSKIP(1))
	enddo
        PAYSKED->(dbunlock())
        PAYSKED->(dbcommit())
endif
return 

*************************************************************
static function chkpaymode ( mpaymodechoices, mpaymode, mrow, mcol )
*************************************************************
   local mscr := savescreen( 24,0,24,79)

   center( 24,'w+/n','® Select Payment Mode ¯' )
   mpaymode := gen_achoice ( mpaymodechoices, val(mpaymode),'Payment Mode', mrow-3, 58, 18, 78, 'W/GR+,W/N,,,W/GR+')
   @ mrow, mcol+2 say LEFT(upper(disp_mode_pay(mpaymode)),15)
   restscreen( 24,0,24,79,mscr )
return .f.

/*
********************************************************
static function chkcltrltype  ( mcltrltype, mrow, mcol )
********************************************************
   center ( 24, 'w+/n', '® Select Collateral Name ¯' )
   lb_lkup('Colatral',1,1,@mcltrltype, 2 , 1, 10, 32, 21, 75, 'W/GR+,W/N,,,W/GR+')
   @ mrow, mcol+3 say upper ( left ( disp_cltrl ( mcltrltype ), 15 ) )
   center ( 24, 'w+/n', '                          ' )
return .f.
*/

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function chkcltrltype(mcltrltype, mrow, mcol)  //pepe 08.19.2008
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
     LOCAL nctr := 0, mARRAY_NAME := {}, aTranrecs := {}
	 
     Colatral->(dbgotop())
     do while !Colatral->(eof()) 
	    nctr++
        	    aadd ( mARRAY_NAME, padr(' ',' ') +   '  ' +;
                           UPPER(padr  ( Colatral->CLTRLNAME,30))  + ' ³ ' +  ;
                           UPPER(padr  ( Colatral->CLTRLTYPE,2) )  + ' '      ;
              	         )
						 
				aadd(aTranrecs,Colatral->CLTRLTYPE)

        if Colatral->CLTRLTYPE == mcltrltype
	       mcltrltype :=  str(nctr)
	    endif

      Colatral->(dbskip(+1))
      enddo
	  
   mcltrltype := gen_achoice ( mARRAY_NAME, val ( mcltrltype ),'Select Collateral Name', 10, 37, 21, 75, 'W/GR+,W/N,,,W/GR+')
   mcltrltype := if (lastkey() != K_ESC,aTranrecs[val(mcltrltype)],mcltrltype )
   
   @ mrow, mcol+3 say upper ( left ( disp_cltrl ( mcltrltype ), 15 ) )  color 'gr+/b'
   return .f.

/*
**********************************************************
static function chkcorixunitcode ( morixunit, mrow, mcol )
**********************************************************
   center ( 24, 'w+/n', '® Select ORIX Unit Name ¯' )
   lb_lkup( 'Orixunit' ,1,1,@morixunit, 2 , 1, 10, 32, 21, 75, 'W/GR+,W/N,,,W/GR+')
   @ mrow, mcol+3 say left ( disp_ORIX_unit ( morixunit ), 15 )
   center ( 24, 'w+/n', '                         ' )
return .f.
*/

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function chkcorixunitcode(morixunit, mrow, mcol )  //pepe 08.19.2008
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
     LOCAL nctr := 0, mARRAY_NAME := {}, aTranrecs := {}
	 
     Orixunit->(dbgotop())
     do while !Orixunit->(eof()) 
	    nctr++
        	    aadd ( mARRAY_NAME, padr(' ',' ') +   '  ' +;
                           UPPER(padr  ( Orixunit->UNITNAME,30))  + ' ³ ' +  ;
                           UPPER(padr  ( Orixunit->UNITCODE,2) )  + ' '      ;
              	         )
						 
				aadd(aTranrecs,Orixunit->UNITCODE)

        if Orixunit->UNITCODE == morixunit
	       morixunit :=  str(nctr)
	    endif

      Orixunit->(dbskip(+1))
      enddo
	  
   morixunit := gen_achoice ( mARRAY_NAME, val ( morixunit ),'® Select ORIX Unit Name ¯', 10, 37, 21, 75, 'W/GR+,W/N,,,W/GR+')
   morixunit := if (lastkey() != K_ESC,aTranrecs[val(morixunit)],morixunit )
   
   @ mrow, mcol+3 say left ( disp_ORIX_unit ( morixunit ), 15 )  color 'gr+/b'
   return .f.
   
/*
*******************************************************
static function chkcbunitcode ( munitcode, mrow, mcol )
*******************************************************
   center ( 24, 'w+/n', '® Select CB Unit Name ¯' )
   lb_lkup( 'Unitcode' ,1,1,@munitcode, 2 , 1, 10, 32, 21, 75, 'W/GR+,W/N,,,W/GR+')
   @ mrow, mcol+3 say left ( disp_unit ( munitcode ), 15 )
   center ( 24, 'w+/n', '                       ' )
return .f.
*/

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function chkcbunitcode(munitcode, mrow, mcol)  //pepe 08.19.2008
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
     LOCAL nctr := 0, mARRAY_NAME := {}, aTranrecs := {}
	 
     Unitcode->(dbgotop())
     do while !Unitcode->(eof()) 
	    nctr++
        	    aadd ( mARRAY_NAME, padr(' ',' ') +   '  ' +;
                           UPPER(padr  ( Unitcode->UNITNAME,30))  + ' ³ ' +  ;
                           UPPER(padr  ( Unitcode->UNITCODE,2) )  + ' '      ;
              	         )
						 
				aadd(aTranrecs,Unitcode->UNITCODE)

        if Unitcode->UNITCODE == munitcode
	       munitcode :=  str(nctr)
	    endif

      Unitcode->(dbskip(+1))
      enddo
	  
   munitcode := gen_achoice ( mARRAY_NAME, val ( munitcode ),'® Select CB Unit Name ¯', 10, 37, 21, 75, 'W/GR+,W/N,,,W/GR+')
   munitcode := if (lastkey() != K_ESC,aTranrecs[val(munitcode)],munitcode )
   
   @ mrow, mcol+3 say left ( disp_unit ( munitcode ), 15 )  color 'gr+/b'
   return .f.
   
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function chkcredittype(mCREDTYPE, mROW, mCOL, X2, Y2)  //pepe 08.19.2008
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
     LOCAL nctr := 0, mARRAY_NAME := {}, aTranrecs := {}
	 
     Credtype->(dbgotop())
     do while !Credtype->(eof()) 
	    nctr++
        	    aadd ( mARRAY_NAME, padr(' ',' ') +   '  ' +;
                           UPPER(padr  ( Credtype->CREDNAME,50))  + ' ³ ' +  ;
                           UPPER(padr  ( Credtype->CREDTYPE,2) )  + ' '      ;
              	         )
						 
				aadd(aTranrecs,Credtype->CREDTYPE)

        if Credtype->CREDTYPE == mcredtype
	       mcredtype :=  str(nctr)
	    endif

      Credtype->(dbskip(+1))
      enddo
	  
   mcredtype := gen_achoice ( mARRAY_NAME, val ( mcredtype ),'® Select Credit Type ¯', 10, X2, Y2, 75, 'W/GR+,W/N,,,W/GR+')
   mcredtype := if (lastkey() != K_ESC,aTranrecs[val(mcredtype)],mcredtype )
   
   @ mROW, mCOL+3 say upper( left( disp_cred_type(mcredtype), 16 ) ) color 'gr+/b'
   return .f.
   
   
*******************************************************************
static function chkreviewfreq ( mrevchoices, mrevfreq, mrow, mcol )
*******************************************************************
   mrevfreq := gen_achoice ( mrevchoices, val ( mrevfreq ),'Review Frequency', mrow-5, 58, 18, 78, 'W/GR+,W/N,,,W/GR+')
   @ mrow, mcol+2 say upper( left ( disp_rev_freq ( mrevfreq ), 15 ) )
return .f.
/*
*******************************************
static function disp_mode_pay ( mpaymode )
*******************************************
// return if( mpaymode $ '12' ,if( mpaymode == '1', 'Post-dated checks', 'Cash             '), space ( 17 ) )
   local cretval

   if mpaymode $ '12'
      if mpaymode == '1'
         cretval := 'Post-dated checks'
      else
         cretval := 'Cash             '
      endif
   else
      if mpaymode $ '3'
         cretval := 'Automatic Debit'
      endif
   endif

return cretval
*/
*************************************************
static function fgetstatus(mstatus,mstat_choices)
*************************************************
   eval ({|| mstatus := gen_achoice( mstat_choices, val( mstatus ), 'Status Codes', 05, 60, 09, 78, 'w/gr+,w/n,,,w/gr+' ),;
             devpos( 04,60) ,devout( tran( xdisp_status( mstatus ), '@!' ) ) } )
return .f.

*************************************************
static function xgetstatus(mstatus,xstat_choices)
*************************************************

   eval ({|| mstatus := gen_achoice( xstat_choices, val( mstatus ), 'Status Code', 05, 60, 06, 78, 'w/gr+,w/n,,,w/gr+' ),xstatus := substr(xstat_choices[val(mstatus)],1,1),mstatus := xstatus,;
             devpos( 04,60) ,devout( tran( ' '+xdisp_status( xstatus ), '@!' ) ) } )		 
	
	
return .f.

*****************************
*
static function disp_record( cBRCODES )
*****************************
//IF ACCTMAST->BRCODE $ &cBRCODES
IF AXBRANCH->(DBSEEK(g_USER_ID+ACCTMAST->BRCODE))
   dispbegin ()
   @  4,  2 say '        Account N§  ' color 'w/b'
   &&@  4, 23 say tran( Acctmast->acctno, '@R 9999-99999-99999' ) color 'w+/b'
   @  4, 23 say tran(Acctmast->BRCODE+Acctmast->acctno, '@R 999-9999-99999-99999' ) color 'w+/b'
   @  4, 43 say '       Status  ' color 'w/b'
   @  4, 59 say tran( Acctmast->status, '@X' ) +' '+;
                tran( xdisp_status( Acctmast->status ), '@!' ) color 'w+/b'
   @  5,  2 say '      Account Name  ' color 'w/b'
   @  5, 23 say tran( Acctmast->acctname, '@!' ) color 'w+/b'
   @  6,  2 say '    Doc. Reference  ' color 'w/b'
   @  6, 23 say tran( Acctmast->docref,'@X' ) color 'w+/b'
   @  6, 42 say 'Availment Date  ' color 'w/b'
   @  6, 59 say tran( Acctmast->valdate, '@D' ) color 'w+/b'

   @  7,  2 say '    Old Number      ' color 'w/b'
   @  7, 23 say Acctmast->oldno color 'w+/b'

   @  7, 42 say '   Branch Name  ' color 'w/b'
   @  7, 59 say tran( Acctmast->brcode, '@!' ) + ' ' + padr ( _get_branch(Acctmast->brcode),15) color 'w+/b'

   @  8,  2 say '          CA/OT N§  ' color 'w/b'
   @  8, 23 say tran( IF(EMPTY(ACCTMAST->REFNO),SPACE(8),ACCTMAST->BRCODE+Acctmast->refno), '@R 999-99999' ) color 'w+/b'     && RED 112604 ADDED 'ACCTMAST->BRCODE '999-
   @  8, 42 say ' Contract Date  ' color 'w/b'
   @  8, 59 say tran( Acctmast->condate, '@D' ) color 'w+/b'
   @  9,  2 say '         Client N§  ' color 'w/b'
   &&@  9, 23 say tran( Acctmast->clntcode, '@R 99-99999' ) +;
   @  9, 23 say tran( ACCTMAST->BRCODE+Acctmast->clntcode, '@R 999-99-99999' ) +;
                ' ' + tran( DISPCLNTNAME ( ACCTMAST->BRCODE+ACCTMAST->CLNTCODE,40 ), '@!' ) color 'w+/b'   &&RED 121305 _dispclntname ( Acctmast->brcode,Acctmast->clntcode )
   @ 10,  2 say '            Surety  ' color 'w/b'
   @ 10, 23 say tran( Acctmast->surety, '@X' ) color 'w+/b'
   @ 11,  2 say '      AO In-Charge  ' color 'w/b'
   @ 11, 23 say tran( Acctmast->aocode,'99999' ) +;
                ' ' + tran( dispaoname( Acctmast->AOCODE ), '@!' ) color 'w+/b'
   @ 12,  2 say '          Currency  ' color 'w/b'
   @ 12, 23 say tran( Acctmast->currcode, '99' ) color 'w+/b'
   @ 12, 42 say '         DOSRI  ' color 'w/b'
   @ 12, 59 say tran(if(Acctmast->DOSRI != 'NO ','YES '+'['+Acctmast->DOSRI+']' ,'NO           '),'@X') color 'w+/b'
   @ 13,  2 say '     Facility Code  ' color 'w/b'
   @ 13, 23 say tran( Acctmast->fcltycode, '@R 999-99' ) +;
                ' ' + tran( dispalias( Acctmast->fcltycode,40,'N' ), '@!' ) color 'w+/b'
//   @ 14,  2 say '       Net Proceds  ' color 'w/b'
   @ 14,  2 say '      Net Proceeds  ' color 'w/b'  //aga.09.03.2006.wrong spelling
   @ 14, 23 say tran( Acctmast->principal, '999,999,999.99' ) color 'w+/b'
   @ 14, 42 say '     True Rate  ' color 'w/b'
   @ 14, 59 say tran( Acctmast->truerate, '99.99999' ) +;
                ' ' + tran( dispratetype( Acctmast->ratetype ), '@!' ) color 'w+/b'
   @ 15,  2 say '              Term  ' color 'w/b'
   @ 15, 23 say tran( Acctmast->term, '999' ) +;
                dispterm( Acctmast->termunit ) color 'w+/b'
   @ 15, 42 say ' Maturity Date  ' color 'w/b'
   @ 15, 59 say tran( Acctmast->matdate, '@D' ) color 'w+/b'
   @ 17,  2 say '       Review Date  ' color 'w/b'
   @ 17, 23 say tran( Acctmast->revdate, '@D' ) color 'w+/b'
   @ 18,  2 say '   Mode of Payment  ' color 'w/b'
   @ 18, 23 say tran( Acctmast->paymode, '@X' ) +;
                ' ' + tran( LEFT(disp_mode_pay( Acctmast->paymode ),15), '@!' ) color 'w+/b'

   //
   // abb 10.03.2002   SSR # 29
   //

   @ 18-1, 42 say '  CB Unit Code  ' color 'w/b'
   @ 18-1, 59 say tran( Acctmast->unitcode, '@X' ) +;
                ' ' + tran( left( disp_unit( Acctmast->unitcode ), 15 ), '@!' ) color 'w+/b'
   @ 19,  2 say '  Review Frequency  ' color 'w/b'
   @ 19, 23 say tran( Acctmast->revfreq, '@X' ) +;
                ' ' + tran( left( disp_rev_freq( Acctmast->revfreq ), 15 ), '@!' ) color 'w+/b'
   @ 19-1, 42 say 'CB Credit Type  ' color 'w/b'
   @ 19-1, 59 say tran( Acctmast->credtype, '@X' ) +;
                ' ' + tran( left( disp_cred_type( Acctmast->credtype ), 15 ), '@!' ) color 'w+/b'
   @ 20,  2 say 'CB Collateral Type  ' color 'w/b'
   @ 20, 23 say tran( Acctmast->cltrltype, '@X' ) +;
                ' ' + tran( left( disp_cltrl( Acctmast->cltrltype ), 15 ), '@!' ) color 'w+/b'
   @ 20-1, 42 say ' MRR Increment  ' color 'w/b'
   @ 20-1, 59 say tran( Acctmast->mrr_rate, '99.9999' ) color 'w+/b'

   @ 21,  2 say '    ORIX Unit Code  ' color 'w/b'
   @ 21, 23 say tran( Acctmast->orixunit ,'@X' ) +;
                ' '+ tran( left( disp_ORIX_unit( Acctmast->orixunit ), 17 ), '@!' ) color 'w+/b'
   @ 21-1, 42 say '  TB Increment  ' color 'w/b'
   @ 21-1, 59 say tran( Acctmast->tb_rate, '99.9999' ) color 'w+/b'

   @ 22-1, 42 say ' ORIX Borr.Rate ' color 'w/b'
   @ 22-1, 59 say tran( Acctmast->orixbrrate, '99.9999' ) color 'w+/b'
   dispend()
ENDIF
return( nil )
********************************************
static function dispterm(mtermunit)
********************************************
return eval({|| if(trim(mtermunit) $ '12',' '+if( trim(mtermunit)=='1','DAY(s)  ','MONTH(s)'),space(10) )})
**************************************
static function disp_status( mstatus )
**************************************
return eval({|x| x := space(13)+'Cancelled    '+'Active       '+'Past Due     '+'In Litigation'+'Repossessed  '+'Written-off  '+"Sold Rec'bles",' '+substr(x,val(mstatus)*13+1,13)})
**********************************************
**************************************
function Xdisp_status( mstatus )
**************************************
//return eval({|x| x := space(13)+'Cancelled    '+'Active       '+'Past Due     '+'In Litigation'+'Repossessed  '+'Written-off  '+"Sold Rec'bles",' '+substr(x,val(mstatus)*13+1,13)})
local mretval

do case
	case mstatus == '0'
		mretval := 'Cancelled    '
	case mstatus == '1'
		mretval := 'Active       '
	case mstatus == '2'
		mretval := 'Past Due     '
	case mstatus == '3'
		mretval := 'In Litigation'
	case mstatus == '4'
		mretval := 'Repossessed  '
	case mstatus == '5'
		mretval := 'Written-off  '
	case mstatus == '6'
		mretval := "Sold Rec'bles"
		
endcase

return (mretval)
**********************************************

*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  static function xcancelval(mactaken,mapprover)
*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mRETVAL   := .f. , GETLIST := {}          ,;
         muser_id  := '      '                    ,;
         mpassword := '',mscr := savescreen( ,,, ) ,;
         mc        := setcolor ()


   fshadow( 7, 45, 10, 70, 2, 'n/w' )
   setcolor( 'bg+/w, w+/n,, gr+/w' )
   @ 8, 46 say 'Approver ID '          // get approver id
   @ 9, 46 say '   Password '          // ger his user id
   @ 8, 60 get muser_id  pict '@!X'
   @ 9, 60 say space(10)
   setcursor( 3 )
   read
   setcursor( 0 )

   if !empty(muser_id)      // escape was pressed or lastkey() != K_ESC .and.

      if  CANAPPRV-> ( ACCT_approver ( muser_id ) )  // search if approver id
                                                     // is valid
         if getpassword( @mpassword )                // if so, then check his
                                                     // password
            if Axmast -> ( dbseek ( muser_id ) ) .and. trim(Axmast->PASSWORD) == encrypt (trim(mpassword))
               mapprover := muser_id
               mRETVAL := .t.
            else
               ERROR ( "Incorrect password." )
            endif
         endif
      else
         error ( 'Access denied.' )
         mRETVAL := .f.
      endif
   endif

   setcolor   ( mc )
   restscreen ( ,,,, mscr )
   return mRETVAL
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
// Description  validates approver
   function ACCT_approver( muserid )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mf := .f.
   CANAPPRV -> ( dbgotop() )
   CANAPPRV -> ( dbeval ( {|| if ( CANAPPRV->APPROVER == muserid,;
                                   mf := .t.,;
                                   nil ;
                                 );
                          },,;
                          {|| !CANAPPRV->(eof()) .and. !mf }))

return mf
   
   
**********************************************
static function ach_look()
**********************************************
local mod_t:='DEFAULT', ckey:=space(10)
local headr:='    Client Name                           Branch  Clntcode '
   
   main_achoice('CLIENT',3,1,,8,10,21,71,headr,mod_t)
   
	if mpos > 0 .and. lastkey() == K_ENTER
				cKEY := substr( ltrim(mchoices[mpos]),44,3)+substr( ltrim(mchoices[mpos]),50,2)+;
				substr( ltrim(mchoices[mpos]),53,5)
				client->(dbsetorder(1))
				
             if Client->( dbseek (alltrim(cKEY)) )   
                aNRECNO  := Client->(RECNO())
				
            endif		 
	ENDIF 
nrecno:= aNRECNO  
return ckey

**************************
*
static function Ach_look2()
**************************
local mod_t:='noacct',ckey:=space(10)
local headr:='   Client Name                            Branch  Clntcode  # of Accts'
   
   main_achoice('CLIENT',3,1,,8,4,21,76,headr,mod_t)
   
  if mpos > 0 .and. lastkey() == K_ENTER
				cKEY := substr( ltrim(mchoices[mpos]),44,3)+substr( ltrim(mchoices[mpos]),50,2)+;
				substr( ltrim(mchoices[mpos]),53,5)
				client->(dbsetorder(1))
				
             if Client->( dbseek (alltrim(cKEY)) )   
                aNRECNO  := Client->(RECNO())
				
            endif		 
	ENDIF 
nrecno:= aNRECNO  
return ckey

**********************************************
static function amsmsearch()
**********************************************
   local mcolor := setcolor(), mrecno := Acctmast->(recno()), mclntcode := space(7)
   local mscr := savescreen(,,,), mdbf := savedbf(), getlist := {},mu:={},mlog:={}
   local mposition:=0,ppy := Acctmast->(indexord()),xx_:=Client->(indexord())
   LOCAL cBRCODE := SPACE(3), cKEY := SPACE(18), cBRCLCODE := SPACE(10)

   Client->(dbsetorder(2))
   center      ( 24, 'w+/n', '® Search Record ¯' )
   fshadow  ( 10, 12, 12, 39, 2, 'n/w' )
   setcolor ( 'bg+/w, w+/n,,, gr+/w'   )

   *@ 11, 13 say 'Account N§ '             ;
   *         get mclntcode                  ;
   *         pict '99999'                   ;
   *         when eval( { || macctno := eval( {|| flook_ONLINE(.t.,'Client',Acctmast->Acctname,'Client Master File',3,45,1,,1,.f.,,,,g_ams_path,.T.) } ),.T. } );

&&            when eval( { || cBRCLCODE := eval( {|| flook_ONLINE(.t.,'Client',  ;
&&                            Acctmast->Acctname,'Client Master File',3,45,1,,1, ;
&&                            .f.,,,,g_ams_path,.T.) } ),.T. } )                 ;
&&            VALID IF( EMPTY(cBRCLCODE), VALBRCODE( LEFT(cBRCLCODE,3), g_USER_ID ), .T. )

   @ 11, 13 say 'Client N§ '                                                  ;
            get cBRCLCODE                                                      ;
            pict '@R 999-99-99999'                                             ;
            VALID IF( !EMPTY(cBRCLCODE),                         ;
                      VALBRCODE( LEFT(cBRCLCODE,3), g_USER_ID ), ;
                      eval( { || cBRCLCODE := eval( {|| ach_look() } ), ;
                      IF(LASTKEY() == K_ENTER,VALBRCODE(LEFT(cBRCLCODE,3), g_USER_ID),.F.) } ) )


   setcursor( 3 )
   read
   setcursor( 0 )
   //
   // macctno := if ( !empty( macctno ), right( '0000' + alltrim(macctno), 5 ),macctno )
   //
   IF LASTKEY() == K_ENTER
   
      cBRCODE   := LEFT(cBRCLCODE,3)
      mCLNTCODE := RIGHT(cBRCLCODE,7)
   ENDIF

   Acctmast->  ( dbsetorder (2) )

   if !empty(mclntcode) .and. lastkey() != K_ESC

      if Acctmast->(dbseek(cBRCLCODE))

         *sbrcode := Client->brcode   // 10.28.2004 abb

         mu := { '  Client N§  '   + tran( cBRCLCODE, '@R 999-99-99999' ) ,;
                 '  Client Name  ' + DISPCLNTNAME( cBRCODE+mCLNTCODE,30 ),;      &&left( _dispclntname ( cBRCODE, mclntcode ),30 )
                    repl( 'Ä', 68 ),;     && RED 112604 REPLACED 64 WITH 68
                    '       Acct. N§         Status     Old Acct. No.       Ref. No.',;
                    repl( 'Ä', 68 );      && RED 112604 REPLACED 64 WITH 68
               }
		 
         ACCTMAST->( DBEVAL({|| AADD( MU,' '+;
                     TRANS(ACCTMAST->BRCODE+ACCTMAST->ACCTNO,'@R 999-9999-99999-99999')+;
                     SPACE(2)+substr(upper(xdisp_status(Acctmast->Status)),1,12) +;
                     Acctmast->oldno + if ( Acctmast->docref == '1','CA ','OT ' )+;
                                       ACCTMAST->BRCODE+'-'+Acctmast->refno)+' '},,;
                    {|| Acctmast->CLNTCODE == mclntcode .and. ;
                        !Acctmast->(eof())              .and. ;
                        Acctmast->brcode   == cBRCODE         ;
                    }) )

//alert(str(len(mu)))
 
         if len(mu) > 1
            mlog := aclone( mu )
            aeval( mlog, { | l, c | mlog[ c ] := if( c <= 5, .f., .t. ), c } )
            mposition := val( gen_achoice( mu, 6, 'Search', mlog ) )
//alert('ZZZZxxxZZZZZ')
//alert(str(mposition))
         endif


         if !empty(mposition) .and. lastkey() <> K_ESC

            *sbrcode := Client->brcode   // 10.28.2004 abb
            cKEY     := SUBSTR(MU[mPOSITION],2,3)+SUBSTR(MU[mPOSITION],6,4)+;
                        SUBSTR(MU[mPOSITION],11,5)+SUBSTR(MU[mPOSITION],17,5)

//alert(acctmast->acctno+' '+cKEY)

            ACCTMAST->(DBSETORDER(1))
            ACCTMAST->(DBSEEK( cKEY ))

            mrecno:=Acctmast->(recno())
         endif
      else
         error('Record not found in Account Master')
      endif

   endif
   setcolor( mcolor )
   restscreen(,,,,mscr)
   restdbf( mdbf )
   Acctmast->( dbsetorder(ppy) )
   Acctmast->( dbgoto( mrecno ) )
   Client->(dbsetorder(xx_))
return nil
/*
***************************************
static function dispalias( mFCLTYCODE )
***************************************
   Facility->( dbseek ( mFCLTYCODE ) )
return Facility->FCLTYNAME
*/
******************************
static function amsm0400open()
******************************
   local  mretval := .f.
   local cscr := savescreen ( ,,, ),mcol
   memvar g_cis_path

   @ 22,1 say 'Opening files .....'
   mcol := col()

   if !netuse( '&g_grf_path\Branches', .f., 5 ) && branches
      return .f.
   else
      ordlistadd( '&g_grf_path\Brcode' )   && set index on branch code
   endif
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_AMS_PATH\Drop',.f.,5 )
      return .f.
   endif
   set index to &g_AMS_PATH\Drop
   @ 22,mcol say '.'
   mcol := col()
   
   if !NETUSE('&g_AMS_PATH\AMSHIST',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\amshist
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_GL_PATH\Tranhead',.f.,5)
      return .f.
   endif
   set index to &g_GL_PATH\Tranhead, &g_GL_PATH\Trancode, &g_GL_PATH\Tranbank, &g_GL_PATH\Tranlcrj, &g_GL_PATH\Trandate
   @ 22,mcol say '.'
   mcol := col()   
 
	if !netuse( '&g_GL_PATH\Adjmast', .f., 5 )       &&  
		return .f.      
	endif
	set index to &g_GL_PATH\ADJMAST
 
	if !netuse( '&g_GL_PATH\Adjaccts', .f., 10 )             && Adjustment of Accounts details
	   	return .f.      
	endif
	set index to &g_GL_PATH\ADJACCTS
	@ 22,mcol say '.'
	mcol := col() 
 
    if !NETUSE('&g_GL_PATH\Trandtls',.f.,5)
      return .f.
    endif
    set index to &g_GL_PATH\Trandtls, &g_GL_PATH\Trglcode
    @ 22,mcol say '.'
    mcol := col()
   
    if !netuse( '&g_GL_PATH\Gltranhd', .f., 5 )       &&  
        return .f.
    endif
    set index to &g_GL_PATH\Gltranhd 
    @ 22,mcol say '.'
    mcol := col()
	
    if !netuse( '&g_GL_PATH\Gltrandt', .f., 5 )       &&  
        return .f.
    endif
    set index to &g_GL_PATH\Gltrandt 
    @ 22,mcol say '.'
    mcol := col()	
	
    if !netuse( '&g_GL_PATH\OL_PARAM', .f., 5 )       &&  
        return .f.
    endif
    set index to &g_GL_PATH\OL_PARAM
    @ 22,mcol say '.'
    mcol := col()	
   
    if !NETUSE('&g_AMS_PATH\CANAPPRV',.f.,5)
      return .f.
    endif
    @ 22,mcol say '.'
    mcol := col()
   
   if !NETUSE('&g_AMS_PATH\CURRENCY',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\CURRENCY
   @ 22,mcol say '.'
   mcol := col()
   
    if !NETUSE('&g_AMS_PATH\CANCLACT',.f.,5)
      return .f.
    endif
	 set index to &g_AMS_PATH\CANCLACT
    @ 22,mcol say '.'
    mcol := col()
   
   if !NETUSE('&g_AMS_PATH\AMSJVLOG',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\AMSJVLOG, &g_AMS_PATH\AMSJVLGT
   @ 22,mcol say '.'
   mcol := col()   
	
   if !NETUSE('&g_AMS_PATH\CNREVLOG',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\CNREVLOG, &g_AMS_PATH\CNREVLGT
   @ 22,mcol say '.'
   mcol := col()   	
   
   if !NETUSE('&g_AMS_PATH\AXMAST',.f.,5 )
      return .f.
   endif
   set index to &g_AMS_PATH\USER_ID
   @ 22,mcol say '.'
   mcol := col()  

	if !NETUSE(  '&g_AMS_PATH\Caheader',.f.,5)
		return
	endif	
	set index  to &g_AMS_PATH\Caheader, &g_AMS_PATH\Carev, &g_AMS_PATH\Caclnt
	Caheader->( dbsetorder (1) )
	@ 22,mcol say '.'
	mcol := col()  
	
	if !NETUSE('&g_AMS_PATH\Oticket',.F.,5)
		return .f.
	endif
	set index to &g_AMS_PATH\OTICKET, &g_AMS_PATH\OTCLNT
	@ 22,mcol say '.'
	mcol := col()
	
	if !NETUSE('&g_GRF_PATH\AXBRANCH',.F.,5)
		return .f.
	endif
	set index to &g_GRF_PATH\AXBRANCH
	
   if netuse( '&g_AMS_PATH\Acctmast',.f., 5 )
      set index to &g_AMS_PATH\Acctmast,;
                   &g_AMS_PATH\Acctclnt,;
                   &g_AMS_PATH\Sureclnt,;
                   &g_AMS_PATH\Acctfa  ,;
                   &g_AMS_PATH\Acctsub2,;
                   &g_AMS_PATH\Acctaonm,;
                   &g_AMS_PATH\Acctacno,;
                   &g_AMS_PATH\Acctval ,;
                   &g_AMS_PATH\Acctrev ,;
                   &g_AMS_PATH\Acctsub ,;
                   &g_AMS_PATH\Acctfclt,;
                   &g_AMS_PATH\Acctcdft,;
                   &g_AMS_PATH\Acctclmt,;
                   &g_AMS_PATH\Acctday ,;
                   &g_AMS_PATH\Acctmatd
      @ 22,mcol say '.'
      mcol := col()

      Acctmast->( dbsetorder (2) )


      if netuse ( '&g_cis_path'+'\Client.dbf',.f.,5)
         set index to &g_cis_path\Cliecd, &g_cis_path\Clienm, &g_CIS_PATH\CLIEBF
         @ 22,mcol say '.'
         mcol := col()


         if netuse( '&g_cis_path'+'\Dealer.dbf',.f.,5)
            set index to &g_cis_path\Dlrcode,&g_CIS_PATH\Dlrname
            @ 22,mcol say '.'
            mcol := col()


            if netuse( '&g_AMS_PATH\Doccodes', .f., 5 )
               set index to &g_AMS_PATH\Doccodes,&g_AMS_PATH\Doccname
               @ 22,mcol say '.'
               mcol := col()

               if netuse( '&g_AMS_PATH\Reqdocs', .f., 5 )
                  set index to &g_AMS_PATH\Reqdocs
                  @ 22,mcol say '.'
                  mcol := col()

                  if netuse( '&g_AMS_PATH\Paysked', .f., 5 )
                     set index to &g_AMS_PATH\Paystat,&g_AMS_PATH\Paydsked,&g_AMS_PATH\Paysked //aga.14.01.2007.synch
                     @ 22,mcol say '.'
                     mcol := col()

                     if netuse( '&g_AMS_PATH\Colatral', .f. , 5 )
                        set index to &g_AMS_PATH\Colatral
                        @ 22,mcol say '.'
                        mcol := col()

                        if netuse ( '&g_AMS_PATH\Orixunit', .f. , 5 )
                           set index to &g_AMS_PATH\Orixunit
                           @ 22,mcol say '.'
                           mcol := col()

                           if netuse ( '&g_AMS_PATH\Unitcode', .f. , 5 )
                              set index to &g_AMS_PATH\Unitcode
                              @ 22,mcol say '.'
                              mcol := col()

                              if netuse ( '&g_AMS_PATH\Credtype', .f. , 5 )
                                 set index to &g_AMS_PATH\Credtype
                                 @ 22,mcol say '.'
                                 mcol := col()

                                 if netuse ( '&g_CIS_PATH'+'\Ao.dbf',.f.,5)
                                    set index to &g_CIS_PATH\Ao.ntx
                                    @ 22,mcol say '.'
                                    mcol := col()

                                    if netuse( '&g_AMS_PATH\Facility',.f.,5)
                                       set index to &g_AMS_PATH\Fcltycd
                                       @ 22,mcol say '.'
                                       mcol := col()

                                       if netuse( '&g_AMS_PATH\Ctrlinfo', .f., 5 )
                                          set index to &g_AMS_PATH\Ctrlinfo
                                          @ 22,mcol say '.'
                                          mcol := col()

                                          if netuse( '&g_AMS_PATH\Asetcode',.f.,5)
                                             set index to &g_AMS_PATH\Asetcode
                                             @ 22,mcol say '.'
                                             mcol := col()

                                             if netuse( '&g_cis_path'+'\Insuranc',.f.,5)
                                                set index to &g_cis_path\Inscode,;
                                                             &g_CIS_PATH\INSNAME
                                                @ 22,mcol say '.'
                                                mcol := col()

                                                if netuse( '&g_AMS_PATH\Cashout',.f.,5)
                                                   set index to &g_AMS_PATH\Cashout
                                                   @ 22,mcol say '.'
                                                   mcol := col()

                                                   if netuse( '&g_AMS_PATH\Paycodes',.f.,5)
                                                      set index to &g_AMS_PATH\Paycodes
                                                      @ 22,mcol say '.'
                                                      mcol := col()

                                                      if netuse( '&g_AMS_PATH\Docday',.f.,5)
                                                         set index to &g_AMS_PATH\Docday
                                                         @ 22,mcol say '.'
                                                         mcol := col()

                                                         if netuse( '&g_grf_path'+'\Personel.dbf',.f.,5)
                                                            set index to &g_grf_path\Initials.ntx,&g_grf_path\Personel.ntx
                                                            @ 22,mcol say '.'
                                                            mcol := col()

                                                            if netuse( '&g_AMS_PATH\Coverage',.f.,5)
                                                               set index to &g_AMS_PATH\Coverage
                                                               @ 22,mcol say '.'
                                                               mcol := col()

                                                               if netuse( '&g_AMS_PATH\Ctrlothr', .f., 5 )
                                                                  set index to &g_AMS_PATH\ctrlothr
                                                                  @ 22,mcol say '.'
                                                                  mcol := col()

                                                                  if netuse( '&g_AMS_PATH\Payimage',.f.,5)
                                                                     dbsetindex( '&g_AMS_PATH\Payimage' )
                                                                     @ 22,mcol say '.'
                                                                     mcol := col()

                                                                     if netuse('&g_AMS_PATH\udispred',.f.,5)
                                                                        set index to &g_AMS_PATH\udispred
                                                                        @ 22,mcol say '.'
                                                                        mcol := col()

                                                                        if netuse( '&g_GL_PATH\Glcode', .f., 5 )               && general ledger
                                                                           set index to &g_GL_PATH\Glcode,&g_GL_PATH\Glname
                                                                           @ 22,mcol say '.'
                                                                           mcol := col()

// EVR                                                                  if netuse( 'Parametr', .f., 5 )               && general ledger
// EVR                                                                     @ 22,mcol say '.'
// EVR                                                                     mcol := col()

                                                                           mretval := .t.
// EVR                                                                  endif
                                                                        endif
                                                                     endif
                                                                  endif
                                                               endif
                                                            endif
                                                         endif
                                                      endif
                                                   endif
                                                endif
                                             endif
                                          endif
                                       endif
                                    endif
                                 endif
                              endif
                           endif
                        endif
                     endif
                  endif
               endif
            endif
         endif
      endif
   endif
   restscreen ( ,,,,cscr )

return mretval

////
static function fFind0100( ax, bx, sw )
local retval:=''
sw:= if(sw==nil, .f.,sw )
if sw
 retval:=  eval( { | x | Glcode->( dbseek( ax ) ),;
	   x := transform( ax, '@R 999-99-99-9999' ),;
	   chr(15)+ x + ' ' + padr( Glcode->glname, bx ) + chr(18) } )
else
 retval:=  eval( { | x | Glcode->( dbseek( ax ) ),;
	   x := transform( ax, '@R 999-99-99-9999' ),;
	   x + ' ' + padr( Glcode->glname, bx ) } )
endif
return retval 

********************************************************
*
static function fWind0100( a_, b_, c_, d_, e_, f_, g_ )
********************************************************
   fShadow( a_, b_, c_, d_, 2, e_, f_ )
   setcolor( g_ + ', n+/w,,, w+/' + substr( g_, 5, 2 ) )
return( g_ )

************************************
*
static function fsearch ( cbrcode )
************************************
   local mRECNO := Acctmast->( recno() )
   local mntx   := Acctmast->( indexord() )
   local mSCR   := savescreen ( ,,, ), mcolor := setcolor()
   local mCLNTCODE := space( len(Acctmast->CLNTCODE) )
   local mar, mposition := 1, mlog := {}, mRETVAL := .f.
   local nrecno := 0
   local cfullname := space ( len( Client->fullname ) )
   LOCAL cKEY
   memvar GETLIST

   &&nrecno := _getClwin ( mclntcode,2,Client->(indexord()) )            // abb 10.18.2004 )   // client code + indexord
   nrecno := _getClwin ( mclntcode,1,Client->(indexord()) )

   IF nRECNO = 0 .AND. LASTKEY() == K_ENTER
   
   ach_look2()
   
      center     ( 24,'w+/n', '® Search Record ¯' )
    //  __lb_lkup  ( 'CLIENT',1,2,@mCLNTCODE,03,45,1,08,12-7,21,75,'W/GR+,W/N,,,W/GR+','@XS40','999','@R 99-99999',,cbrcode,'NAME',cfullname,' Client name','Branch','Code' )
      center     ( 24, 'w+/n', '                 ' )

      IF LASTKEY() == K_ENTER
         nRECNO := CLIENT->(RECNO())
      ENDIF
   ENDIF

   if lastkey() != K_ESC   &&.and. nrecno > 0

      Client->  ( dbgoto(nrecno) )

      mclntcode := Client->clntcode
      cfullname := alltrim(Client->fullname)

      *center     ( 24,'w+/n', '® Search Record ¯' )
      *__lb_lkup  ( 'CLIENT',1,2,@mCLNTCODE,3,45,1,8,12-7,21,75,'W/GR+,W/N,,,W/GR+',,,,cbrcode,'NAME',cfullname )
      *center     ( 24, 'w+/n', '                 ' )

      if lastkey() == K_ENTER .and. nrecno > 0 .AND. VALBRCODE( CLIENT->BRCODE, g_USER_ID )

         Acctmast->(dbsetorder(2))

         if Acctmast->( dbseek ( alltrim(Client->brcode)+mclntcode) )
/*
            mar := { '  Client N§  ' + tran( Client->brcode+mCLNTCODE, '@R 999-99-99999' )   ,;
                     'Client Name  ' + DISPCLNTNAME( ACCTMAST->BRCODE+mCLNTCODE,15 ),;      &&RED 121305 left( _dispclntname( Acctmast->brcode,mCLNTCODE ),15 )
                      repl( 'Ä', 43 ), ' Branch   CA/OT No.        Acct. Number', repl( 'Ä',43 ) ;   &&repl( 'Ä', 43 ), ' Branch Name   CA/OT No.   Acct. Number', repl( 'Ä',43 ) ;
                   }

            &&Acctmast->( dbeval( {|| aadd( mar,Acctmast->brcode+' '+;
            Acctmast->( dbeval( {|| aadd( mar,padr(_get_branch(Acctmast->brcode),10)+;
                                           ' '               + ;
                                           ACCTMAST->BRCODE+'-'+Acctmast->refno   + ;
                                           space(3)          + ;  && RED 112604 REPLACED 7 WITH 3
                                           trans( Acctmast->brcode+Acctmast->Acctno,'@R 999-9999-99999-99999' ) ;
                                     ) ;
                            },,;
                            {|| Acctmast->clntcode == mclntcode      .and. ;
                                Acctmast->brcode   == Client->brcode .and. ;
                                !Acctmast->(eof()) ;
                            };
                           );
                   )
*/   
      mar := { '  Client N§  '   + tran( mCLNTCODE, '@R 999-99-99999' ) ,;
                 '  Client Name  ' + DISPCLNTNAME( cBRCODE+mCLNTCODE,30 ),;      &&left( _dispclntname ( cBRCODE, mclntcode ),30 )
                    repl( 'Ä', 68 ),;     && RED 112604 REPLACED 64 WITH 68
                    '       Acct. N§         Status     Old Acct. No.       Ref. No.',;
                    repl( 'Ä', 68 );      && RED 112604 REPLACED 64 WITH 68
               }
		 
         ACCTMAST->( DBEVAL({|| AADD( MAR,' '+;
                     TRANS(ACCTMAST->BRCODE+ACCTMAST->ACCTNO,'@R 999-9999-99999-99999')+;
                     SPACE(2)+substr(upper(xdisp_status(Acctmast->Status)),1,12) +;
                     Acctmast->oldno + if ( Acctmast->docref == '1','CA ','OT ' )+;
                                       ACCTMAST->BRCODE+'-'+Acctmast->refno)+' '},,;
                    {|| Acctmast->CLNTCODE == mclntcode .and. ;
                        !Acctmast->(eof())              .and. ;
                        Acctmast->brcode   == cBRCODE         ;
                    }) )			  

            if len(mar) > 1
               mlog := aclone( mar )
               aeval ( mlog, { | l, c | mlog[ c ] := if( c <= 5, .f., .t. ), c } )
               mposition := val( gen_achoice( mar, 6, 'Search', mlog ) )
            endif

            if mposition > 0 .and. lastkey() != K_ESC

               *Acctmast->(dbsetorder(5))  //      && RED 120205
               *cKEY := substr( ltrim(mar[mposition]),24,3) + substr( ltrim(mar[mposition]),39,5)
               ACCTMAST->(DBSETORDER(1))
               cKEY := SUBSTR( LTRIM(MAR[mPOSITION]),1,3) + ;
                       SUBSTR( LTRIM(MAR[mPOSITION]),5,4) + ;
                       SUBSTR( LTRIM(MAR[mPOSITION]),10,5) + ;
                       SUBSTR( LTRIM(MAR[mPOSITION]),16,5)
					  // alert(ckey)
               if Acctmast-> ( dbseek ( cKEY ) )
                  sbrcode := Acctmast->brcode
                  mrecno  := Acctmast->(recno())
                  mretval := .t.
               endif

            endif

         else
            ERROR ( 'Account NOT Found!' )
            mretval := .f.
         endif

      endif

   endif

   setcolor   ( mcolor )
   restscreen ( ,,,, mSCR )
   Acctmast->  ( dbsetorder ( mntx ) )
   Acctmast->  ( dbgoto ( mRECNO ) )
return mRETVAL

****************************************************
*
static function _getClwin ( mclntcode,nneword,noldntx)           // abb 10.18.2004
****************************************************
   local nntx := Client->(indexord()),ccursor := setcursor()
   local cclntname := space(len(Client->fullname))
   local nretval   := 0
   LOCAL cCLNTCODE := SPACE(10)

   IF( nNEWORD = CLIENT->(INDEXORD()), NIL, Client->(dbsetorder(nneword)) )
   cscr := savescreen ( ,,, )

   *@ 10,10 clear to 12,52
   *@ 10,10 to 12,52
   *@ 11,12 say 'Client Name  ' get cclntname pict '@!S20'
   @ 10,10 clear to 12,39
   @ 10,10 to 12,39
   @ 11,12 say 'Client Code ' get cCLNTCODE pict '@R 999-99-99999' VALID ( EMPTY(cCLNTCODE) .OR. IF(VALBRCODE(LEFT(cCLNTCODE,3),g_USER_ID),.T.,EVAL({|| cCLNTCODE:=SPACE(10),.F.})))

   setcursor(3)
   read
   setcursor(0)

   restscreen ( ,,,,cscr )

   if lastkey() != K_ESC
      *if Client->(dbseek(alltrim(cclntname)))
      IF EMPTY(cCLNTCODE)
         nRETVAL := 0
      ELSE
         IF CLIENT->(DBSEEK(ALLTRIM(cCLNTCODE)))
            nretval := Client->(recno())
         else
            error ( 'Client not found' )
         endif
      ENDIF
   endif

   Client->  ( dbsetorder(noldntx) )
   setcursor ( ccursor)

return nretval


//********************************************************** PEPE
//********************************************************** 02.26.2008 FROM (SYSDEV\COLFDEV\AMS\LIB\ACHMAKE.PRG)

function gen_achoice( mchoices, mdefault, mhead, mgetrue )

   
local mkey := { | k | k == K_ENTER .or. k == K_ESC }
local mdbf_ := stackin(), mposition, mcolor := setcolor(), mtrue := !.f.
local mreturn := { | s, k, c, n | restscreen( ,,,, s ), __mrelease( k, .t. ), setcursor( c ), ltrim( str( n, 4, 0 ) ) }
local mscr := savescreen( ,,, ), maxcol := 0, mrow_1 := if( valtype( mgetrue ) == 'A', 10, 12 ), mrow_2 := 20
local mcol_1 := 40 - eval( { || aeval( mchoices, { | a_ | maxcol := max( maxcol, len( a_ ) ) } ), max( maxcol, len( trim( mhead ) ) ) / 2 } )
local mcol_2 := mcol_1 + max( maxcol, len( trim( mhead ) ) ) + 1, mcursor := setcursor( setcursor() )

private kill_arr_ := aclone( mchoices ), kill_1_col := kill_ind := 1, mwatch := '”'
private kill_1_row, kill_2_col := mcol_2, kill_2_row := mrow_1, kill_getrue


kill_1_row := mdefault := if( mdefault == 0, 1, mdefault )

mgetrue := if( valtype( mgetrue ) == 'A', mgetrue, .t. )
   
dispbegin()
  setcursor( screen_2_disp( mrow_1, mcol_1, mrow_2, mcol_2, mhead, maxcol ) )
  if valtype( mgetrue ) != 'A' 
    aeval( kill_arr_, { | a_, c | kill_arr_[ c ] := propercase( stuff( a_, rat( '=', a_ ), 1, chr( 26 ) ) ), c } )
    kill_getrue := 0    
  else
    if ascan( mgetrue, { | f_ | f_ == .f. } ) > 0
       kill_getrue := 5
    else
       kill_getrue := 0
       mwatch := nil
    endif
  endif  
  __keyboard( chr( 255 ) )
dispend()
              
while mtrue
      mposition := achoice( mrow_1 + 3, mcol_1 + 1, mrow_2 - 1, mcol_2 - 1, kill_arr_, mgetrue, 'procudf', kill_1_row, kill_1_col )
      mtrue := if( eval( mkey, lastkey() ), !mtrue, mtrue )  
enddo       
stackout( mdbf_ )
setcolor( mcolor )//ÿ
return( eval( mreturn, mscr, 'kill_*', mcursor, if( mposition == 0, mdefault, mposition ) ) )   
              
////
static function screen_2_disp( mrow_1, mcol_1, mrow_2, mcol_2, mhead, maxcol )

fshadow( mrow_1, mcol_1, mrow_2, mcol_2, 2, 'w+/gr+' )   
devpos(  mrow_1 + 1, mcol_1 + 1 ); devout( trim( mhead ), 'w+/gr+' )   
devpos(  mrow_1 + 2, mcol_1 - 0 ); devout( 'Ã' + repl( 'Ä', max( maxcol, len( trim( mhead ) ) ) ) + '´', 'w/gr+' )   
dispbox( mrow_1 + 3, mcol_1 + 1, mrow_2 - 1, mcol_2 - 1, '', 'n/bg' )   
dispbox( mrow_1 + 3, mcol_2, mrow_2 - 1, mcol_2, '°', 'w/n' )
devpos(  mrow_1 + 3, mcol_2 ); devout( chr( 24 ), 'n/w' )
devpos(  mrow_2 - 1, mcol_2 ); devout( chr( 25 ), 'n/w' )
setcolor( 'n/bg, w+/n,,, n/bg' )   
return( cursorless )

/////
function procudf( a_, b_, c_ )
local k := lastkey(), ret_val := AC_CONT
local msize := if( kill_getrue == 5 .or. valtype( mwatch ) == 'U', 5, 3 )
memvar kill_arr_, kill_ind, kill_getrue
memvar kill_1_row, kill_1_col, mwatch
memvar kill_2_row, kill_2_col

do case
   case a_ == AC_HITTOP
        __keyboard( chr( 255 ) )
        kill_1_row := len( kill_arr_ )
        ret_val    := AC_ABORT
   case a_ == AC_HITBOTTOM
        __keyboard( chr( 255 ) )
        kill_1_row := 1        
        ret_val    := AC_ABORT
   case a_ == AC_IDLE .or. k == 255
        dispbegin()
        devpos( kill_2_row + kill_ind + 3, kill_2_col ); devout( '°', 'w/n'  )
        kill_ind := min( max( ( ( b_ - kill_getrue ) / ;
                    ( len( kill_arr_ ) - kill_getrue ) ) * msize, 1 ), msize )
        devpos( kill_2_row + kill_ind + 3, kill_2_col ); devout( 'Û', 'w+/w' )
        dispend()
   case k == K_ENTER .or. k == K_ESC
        kill_1_row := b_
        kill_1_col := c_
        ret_val    := if( k == K_ENTER, AC_SELECT, AC_ABORT )
endcase
return( ret_val )

////
function propercase( a_ )
local i, mchar := upper( left( a_, 1 ) ) + lower( subs( a_, 2 ) )

for i := 1 to len( mchar )
    mchar := if( subs( mchar, i, 1 ) $ '_-_/_ ',                              ;
                 subs( mchar, 1, i ) + subs( upper( mchar ), i + 1, 1 ) +     ;
                 subs( mchar, i + 2 ), if( subs( mchar, i, 4 ) == 'And '  .or.;
                                           subs( mchar, i, 3 ) == 'Of '   .or.;
                                           subs( mchar, i, 5 ) == 'With ' .or.;
                                           subs( mchar, i, 3 ) == 'On '   .or.;
                                           subs( mchar, i, 3 ) == 'In '   .or.;
                                           subs( mchar, i, 4 ) == 'For '  .or.;
                                           subs( mchar, i, 3 ) == 'By '   .or.;
                                           subs( mchar, i, 4 ) == 'Per ',     ;
                                           subs( mchar, 1, i - 1 ) + subs( lower( mchar ), i ), mchar ) )
next
return( mchar )


*
*                    End of the program ( amsm0400.prg )
*
