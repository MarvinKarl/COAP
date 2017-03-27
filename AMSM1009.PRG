/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   PROGRAM ID.........:  AMSM1009.prg                                         ³
³   Description........:  Group Codes                                          ³
³   Date...............:  03:00pm 03-Mar-1995                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                         U P D A T E S                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        Who        ³     When      ³               Why                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Janet L. Bautista ³  27-Apr-1996  ³ correct grammar of prompts/msgs          ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include "COLF.CH"
#include "INKEY.CH"

if CHKPASS(procname(), AX_LEVEL, g_USER_ID)
   if AMSM1009OPEN()
      nosnow( .t. )
      FM1009()
      nosnow( .f. )
   endif
   eval ({|| __mrelease("*", .t.), dbcloseall() })
endif
return

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function FM1009()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mbanner := 'Client Groups File Maintenance', cb, mdbf, mcolor := 'w+/b'    
   local mblock := { | x | GRPMEMBR->BRCODE+GRPMEMBR->grupcode == x }
   local keys_  := { '<Ins>\-Add ', '<F2>\Edit ', '<F3>\Color ', '<F4>\Search ', '<F9>\Print ','<Tab>\-Window ', '<Del>\ ', '<Esc>\' }
   //LOCAL cBRCODES := ACC_BRCH(g_USER_ID)
   LOCAL nTOPREC, nBOTREC, lEDGE := .F.
   LOCAL cNXTVALBR, cCURBRCH, cNXTBR, lNXTVALREC := .F.
   LOCAL SCRSKIP, aBLINK := {}, nLOOP := 1
   local tbcol_ := { tbcolumnnew( padr( 'Brcode',       7 ), { || tran( GRPMEMBR->BRCODE,  '@R 999' ) } ),;
					 tbcolumnnew( padr( 'Origin',      7 ), { || tran( GRPMEMBR->BRCODE2, '@R 999' ) } ),;
					 tbcolumnnew( padr( 'Code'       ,  8 ), { || tran( GRPMEMBR->CLNTCODE,'@R 99-99999' ) } ),;
                     tbcolumnnew( padr( 'Client Name', 30 ), { || dispclntname( if(GRPMEMBR->BRCODE2 == GRPMEMBR->BRCODE,GRPMEMBR->BRCODE,GRPMEMBR->BRCODE2)+GRPMEMBR->CLNTCODE, 30 ) } ) }
   memvar tbkill_code, tbkill_lastrec

   AADD(aBLINK,'ú')
   AADD(aBLINK,'ù')
   AADD(aBLINK,'')
   AADD(aBLINK,'+')
   AADD(aBLINK,'*')
   AADD(aBLINK,'')
   
   dbselectarea( "GRPCODES" )
   if( GRPCODES->( eof() ), eval({|| ERROR("No record found!"), __Keyboard(chr(K_INS)) }), nil)
   GRPCODES->(DBSEEK(g_PAR_BRCH))

   mdbf_ := savedbf()                                 
   dbselectar( "GRPMEMBR" )
   GRPMEMBR->( dbseek( GRPCODES->BRCODE+GRPCODES->grupcode ) )
   cb := tb_maker( tbcol_, keys_,,,,, mbanner,,, GRPCODES->BRCODE+GRPCODES->grupcode, mblock, 3,,, )
   restdbf( mdbf_ )                                   

   do while .t.
      //IF GRPCODES->BRCODE $ &cBRCODES
	  IF AXBRANCH->(DBSEEK(g_USER_ID+GRPCODES->BRCODE))
         dispheadrec( mcolor )
         mdbf_ := savedbf()
         dbselectar( "GRPMEMBR" )
         GRPMEMBR->( dbseek( tbkill_code := GRPCODES->BRCODE+GRPCODES->grupcode ) )
         tb_refresh( cb )
         restdbf( mdbf_ )
      ENDIF

      mkey := inkey(0)

      do case
         /*case mKEY == K_UP .or. mKEY == K_PGUP
              if CHKPASS('S',AX_LEVEL,G_USER_ID)
                 *GRPCODES->(dbskip(-1))

                 SCRSKIP := SAVESCREEN(22,28,22,54)
                 @ 22,28 SAY '[ Searching next record   ]' COLOR 'W+/N'
                 nTOPREC := RECNO()
                 cCURBRCH := GRPCODES->BRCODE

                 IF EVAL( { || GRPCODES->(DBSKIP( -1 )), BOF() } )
                    mSAY := 'BEGINNING OF FILE'
                 ELSE
                    IF !(GRPCODES->BRCODE $ &cBRCODES)
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
                                IF GRPCODES->(DBSEEK(cNXTVALBR))
                                   DO WHILE .T.
                                      @ 22,52 SAY aBLINK[nLOOP] COLOR 'W+/N'
                                      IIF(nLOOP = 6, nLOOP := 1, nLOOP++)

                                      IF GRPCODES->(DBSEEK(cNXTBR))
                                         GRPCODES->(DBSKIP(-1))
                                         IF GRPCODES->BRCODE $ &cBRCODES
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
              endif
         case mKEY == K_DOWN .or. mKEY == K_PGDN
              if CHKPASS('S',AX_LEVEL,G_USER_ID)
                 *GRPCODES->( dbskip( +1 ) )

                 SCRSKIP := SAVESCREEN(22,28,22,54)
                 @ 22, 28 SAY '[ Searching next record   ]' COLOR 'W+/N'
                 nBOTREC := RECNO()
                 cCURBRCH := GRPCODES->BRCODE

                 IF EVAL( { || GRPCODES->(DBSKIP( +1 )), EOF() } )
                    mSAY := 'END OF FILE'
                    mPOS := LASTREC()
                 ELSE
                    IF !(GRPCODES->BRCODE $ &cBRCODES)    && user has no rights for this branch
                       @ 22, 28 SAY '[ Searching next branch   ]' COLOR 'W+/N'
                       cNXTVALBR := NXTVALBR( cCURBRCH, cBRCODES ,'FORWARD')

                       DO WHILE .T.
                          @ 22,52 SAY aBLINK[nLOOP] COLOR 'W+/N'
                          IF(nLOOP = 6, nLOOP := 1, nLOOP++)

                          IF cNXTVALBR == NIL
                             mSAY := 'END OF FILE'
                             DBGOTO(nBOTREC)
                             lEDGE := .T.
                             EXIT
                          ELSE
                             IF GRPCODES->(DBSEEK(cNXTVALBR))
                                IF GRPCODES->BRCODE $ &cBRCODES
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
              endif*/
       /* case mKEY == K_HOME
              if CHKPASS('S',AX_LEVEL,G_USER_ID)
                 GRPCODES->( dbgotop() )
              endif
         case mKEY == K_END
              if CHKPASS('S',AX_LEVEL,G_USER_ID)
                 GRPCODES->( dbgobottom() )
              endif */
         case mKEY == K_INS
              if CHKPASS('A',AX_LEVEL,G_USER_ID)
                 updatehead('A')
              endif
         case mKEY == K_F2
              IF CURRBRCH(GRPCODES->BRCODE) .AND. CHKPASS('E',AX_LEVEL,G_USER_ID)
                 if( GRPCODES->( eof() ), ERROR('Nothing to edit!'),updatehead('E'))
              ENDIF
         case mKEY == K_F4
              if CHKPASS('S',AX_LEVEL,G_USER_ID)
                 if GRPCODES->( eof() )
                    ERROR('Nothing to search!')
                 else
                    search_head(space(len(GRPCODES->BRCODE+GRPCODES->GRUPCODE)))
                 endif
              endif
			  
         case mKEY == K_F9
			private _USER_choice := 1 //,cbrcode := '   '
				//_SELCT_BY()
			do while .t.
				if lastkey() != K_ESC
					REPCON_OL( '_fprint1009()','80 columns',,,,,,.f.)
					exit
				endif
				
				if lastkey() == K_ESC
					exit
				endif	
			enddo			  
			
         case mKEY == K_TAB
              //IF GRPCODES->BRCODE $ &cBRCODES
			  IF AXBRANCH->(DBSEEK(g_USER_ID+GRPCODES->BRCODE))
                 if CHKPASS('S',AX_LEVEL,G_USER_ID)
                    if !GRPCODES->( eof() )
                       mdbf_ := savedbf()
                       dbselectar( "GRPMEMBR" )
                       tbkill_lastrec := 0
                       GRPMEMBR->( dbseek( tbkill_code := GRPCODES->BRCODE+GRPCODES->grupcode ) )
                       GRPMEMBR->( dbeval( { || tbkill_lastrec++ },, { || GRPMEMBR->BRCODE+GRPMEMBR->grupcode == GRPCODES->BRCODE+GRPCODES->grupcode } ) )
                       tbkill_lastrec := max( tbkill_lastrec, 1 )
                       GRPMEMBR->( dbseek( tbkill_code := GRPCODES->BRCODE+GRPCODES->grupcode ) )
                       GRPMEMBR->( tb_stabilizer( cb, { | o, k | case1009( o, k ) } ) )
                       restdbf( mdbf_ )
                    endif
                 endif
              ENDIF
         case mKEY == K_ESC
              if exitmod()
                 exit
              endif
         case mKEY == K_DEL
              IF CURRBRCH(GRPCODES->BRCODE) .AND. CHKPASS('D',AX_LEVEL,G_USER_ID)
                 if GRPCODES->(eof())
                    error('Nothing to delete!')
                 else
                    if CONFIRM ( 'Delete group code ' + GRPCODES->BRCODE+GRPCODES->grupcode + '?')
                       delete_head()
                    endif
                 endif
              ENDIF
      endcase
      tb_indicator( ,,,,,, .f. )
      IF( lEDGE,;
          EVAL({ || TONE( 60, .5 ),;
                    waiton( mSAY, .T., 'N/W', 9 );
              }),;
          NIL;
        )

   enddo
   __mxrelease( tbkill_cel, tbkill_arg, tbkill_lastrec,;
                tbkill_code, tbkill_where, tbkill_color, tbkill_rel,;
                tbkill_mtop, tbkill_mleft, tbkill_mbottom, tbkill_mright )  
   return nil
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
// Description   displays current GRPCODES.dbf record
// Parameters    none

   static function dispheadrec(mcolor)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   dispbegin()
   @ 04,03 say '  Group Code  ' color 'bg+/b'
   @ row(),col() say GRPCODES->BRCODE+GRPCODES->GRUPCODE PICT '@R 999-999'color (mCOLOR)
   @ 05,03 say '  Group Name  ' color 'bg+/b'
   @ row(),col() say substr(GRPCODES->GRUPNAME,1,30) color (mCOLOR)
   @ 05,49 say 'Client Code  ' color 'bg+/b'
   @ row(),col() say GRPCODES->CLNTCODE PICT '@R 99-99999'color (mCOLOR)
   
   dispend()
   return nil
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function case1009(cb, mkey)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mreturn := .t., mscreen := savescreen( ,,, ), mcolor := setcolor()
   
   do case
      case mkey == K_INS
         if CHKPASS('A',AX_LEVEL,G_USER_ID)
            update_detail( 'A' )
            tb_refresh( cb, 'a' )
         endif    
      /*case mkey == K_F2
           if CURRBRCH( (ALIAS())->BRCODE ) .AND. CHKPASS('E',AX_LEVEL,G_USER_ID)
              if( GRPMEMBR->BRCODE+GRPMEMBR->GRUPCODE != GRPCODES->BRCODE+GRPCODES->grupcode, eval({|| ERROR('Nothing to edit!'), dbseek( GRPCODES->BRCODE+GRPCODES->grupcode )}),update_detail('E'))
              tb_refresh( cb, 'c' )
           endif*/
      case mkey == K_DEL
           if CURRBRCH(GRPMEMBR->BRCODE) .AND. CHKPASS('D',AX_LEVEL,G_USER_ID)
              if( GRPMEMBR->BRCODE+GRPMEMBR->GRUPCODE != GRPCODES->BRCODE+GRPCODES->grupcode, eval({|| ERROR('Nothing to delete!'), dbseek( GRPCODES->BRCODE+GRPCODES->grupcode )}), delete_detail( GRPCODES->BRCODE+GRPCODES->grupcode, GRPMEMBR->BRCODE+GRPMEMBR->CLNTCODE ))
              tb_refresh( cb, 'a' )
           endif
      case mkey == K_F4
         if CHKPASS('S',AX_LEVEL,G_USER_ID)
            if GRPMEMBR->BRCODE+GRPMEMBR->GRUPCODE != GRPCODES->BRCODE+GRPCODES->grupcode
               eval({|| ERROR('Nothing to search!'),dbseek( GRPCODES->BRCODE+GRPCODES->grupcode )})
            else
               search_detail( space ( len(GRPMEMBR->BRCODE+GRPMEMBR->CLNTCODE) ),cb:rowpos + 15 )
            endif
            tb_refresh( cb, 'a' )
         endif
      otherwise
         mreturn := !mreturn        
   endcase
   setcolor( mcolor )   
   restscreen( ,,,, mscreen )
   return( mreturn )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
// Description   add/edits GRPCODES.DBF
// Parameters    type >> 'A' = add else edit
   static function updatehead(mWHAT)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mGRUPCODE, mGRUPNAME , mMINIMUM , mMAXIMUM , mSIGNEES , mREQA , mREQB , mGRUPNAME2, mCLNTCODE
   local mPERFORMING  := .t. , mRECNO := recno()
   local getlist      := {}
   
   if ( upper(mWHAT) == 'A', eval({|| CENTER( 24, 'w+/n','® Add Record ¯')}),;
                             eval({|| mWHAT := 'R', CENTER ( 24, 'w+/n', '® Edit Record ¯')}))
   if mwhat == 'A'  //add
      //GRPCODES->(dbseek(padl(val(g_par_brch) + 1, 3, "0"))) //aga.13.07.2005.can't be used since grpcodes contains non-continous brcodes
// EVR removed 06282007     grpcodes->(dbgotop())                                   //aga.13.07.2005.so kailangan manual seek 
      do while !grpcodes->(eof())
         if grpcodes->brcode != g_par_brch
            exit
         end if
         grpcodes->(dbskip(+1))
      end do
      grpcodes->( dbskip( -1 ) )                              //aga.13.07.2005.tapos irewind yung record pointer
//      alert(g_PAR_BRCH +"-" +alltrim(str(val(GRPCODES->GRUPCODE)+1)))
	OL_PARAM->(dbseek(g_PAR_BRCH))
      mgrupcode := g_PAR_BRCH + padl(val(OL_PARAM->GRUPCODE)+1,3,'0')
	  mCLNTCODE := if(mWHAT == 'A',space(7),GRPCODES->CLNTCODE)
      mgrupname := space(30)                                  //aga.18.10.2006.minimize confusion

//    eval ({|x,y| x := GRPCODES->(recno()),;
//           GRPCODES->(dbgobottom())      ,;
//           y := val(GRPCODES->GRUPCODE)+1,;
//           GRPCODES->(dbgoto(x))         ,;
//           right('000'+ltrim(str(y,5)),3)})
   else    //edit
      mgrupcode := GRPCODES->BRCODE+GRPCODES->GRUPCODE
      mgrupname := GRPCODES->GRUPNAME 
   endif


   mgrupname  := space(30)   //aga.18.10.2006.minimize confusion
   setcolor( 'gr+/b, w+/g,,, gr+/b' )
  do while mperforming
      @ 04, 18 get mGRUPCODE  PICT '@R 999-999' when .f.  
	  @ 05, 63 get mCLNTCODE  PICT '@R 999-9999' when .f.
      @ 05, 18 get mGRUPNAME  pict '@X' ; //valid !empty(mgrupname)   //aga.18.10.2006.prevent blank groupname
                    VALID IF( LASTKEY() == K_ENTER .and. mGRUPNAME != space(30) ,;
                             IF( VALBRCODE(g_par_brch,g_USER_ID) .and. search_rootclient(mGRUPNAME) .and. _search_clienm(mGRUPNAME,g_par_brch),;
                                .t.,;
                                 EVAL({|| mGRUPNAME := SPACE(30), .F.});
                               ),;
                             EVAL({|| __lb_lkup('Client', 1, 2,@mGRUPNAME, 3,45, 1, 13,05,21,75, 'W/GR+,W/N,,,W/GR+',,,,,,,,' NAME','BRANCH','CODE'),;
                                      IF( LASTKEY() == K_ENTER,;
                                          EVAL({ || mGRUPNAME := substr(CLIENT->FULLNAME,1,30),mGRUPNAME2 := CLIENT->FULLNAME,;
                                                    IF(VALBRCODE(g_par_brch,g_USER_ID) .and. _matchbrch() .and. _search_clienm(mGRUPNAME,g_par_brch), ;
                                                       .T.,;
                                                       EVAL({|| mGRUPNAME := SPACE(30), .F.});
                                                      );
                                              }),;
                                          .F.;
                                        );
                                 });
                            )	  
	   
	  
      /*              VALID IF(!EMPTY(RIGHT(mGRUPNAME,20)) .AND. LASTKEY() == K_ENTER,;
                             IF( VALBRCODE(LEFT(mGRUPNAME,3),g_USER_ID) ,;
                                 CLNTEXIST(mGRUPNAME),;
                                 EVAL({|| mGRUPNAME := GRPCODES->BRCODE+SPACE(7), .F.});
                               ),;
                             EVAL({|| __lb_lkup('Client', 1, 2,@mGRUPNAME, 3,45, 1, 13,05,21,75, 'W/GR+,W/N,,,W/GR+',,,,,,,,' NAME','BRANCH','CODE'),;
                                      IF( LASTKEY() == K_ENTER,;
                                          EVAL({ || mGRUPNAME := CLIENT->BRCODE+mGRUPNAME,;
                                                    IF(VALBRCODE(LEFT(mGRUPNAME,3),g_USER_ID), ;
                                                       .T.,;
                                                       EVAL({|| mGRUPNAME := GRPCODES->BRCODE+SPACE(20), .F.});
                                                      );
                                              }),;
                                          .F.;
                                        );
                                 });
                            )
	  */
      setcursor(3)
      read
      setcursor(0)

      if lastkey() == K_ESC
         if esckey()
            go mRECNO            
            exit
         else
            loop
         endif
      endif

	  if mwhat != 'A'
		Grpcodes->(dbsetorder(1))
		Grpcodes->(dbseek(mgrupcode))
	  endif
	  
      if CONFIRM('All entries correct?')
         MSGWIN(3,36,'Saving','W+/BG','R*/BG','ON')
         if GRPCODES-> ( NETLOCK( mWHAT, 0 ) )
                     GRPCODES->GRUPCODE :=  RIGHT(mGRUPCODE,3) 
                     GRPCODES->GRUPNAME :=  mGRUPNAME          
                     GRPCODES->BRCODE   :=  LEFT(mGRUPCODE,3)  
					 GRPCODES->CLNTCODE :=  CLIENT->CLNTCODE   		 
               /*eval({||;
                     GRPCODES->GRUPCODE :=  RIGHT(mGRUPCODE,3) ,;
                     GRPCODES->GRUPNAME :=  mGRUPNAME          ,;
                     GRPCODES->BRCODE   :=  LEFT(mGRUPCODE,3)  ,;
					 GRPCODES->CLNTCODE :=  CLIENT->CLNTCODE    ;
                   })*/
		 endif
                GRPCODES->( dbunlock() )
                GRPCODES->( dbcommit() )
                *exit      & RED 11112004 TO EARLY TO EXIT
         
	if mwhat == 'A'	 
		 if OL_PARAM-> ( NETLOCK( 'R', 0 ) )
			OL_PARAM->GRUPCODE := RIGHT(mGRUPCODE,3)
		 endif	
			OL_PARAM->( dbunlock() )
			OL_PARAM->( dbcommit() )
	endif	    
         MSGWIN(3,36,'Saving','W+/BG','R*/BG','OFF')
         EXIT
      else
         go mRECNO               
      endif
   enddo
   CENTER( 24, 'w+/n', '                      ' )
   return nil
 // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function search_rootclient(mGRUPNAME)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ   
  local lretrn:= .f.
  CLIENT->(dbsetorder(2))
 
   if CLIENT->(dbseek(mGRUPNAME))
		lretrn := .t.
   endif
   
   CLIENT->(dbsetorder(1))
  return lretrn   
  // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function _search_clienm(mGRUPNAME,g_par_brch)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ   
  local lretrn:= .f.
  GRPCODES->(dbsetorder(3))
 
   if GRPCODES->(dbseek(g_par_brch+mGRUPNAME))
		error('The Client Name is already in use.')
   else
		lretrn := .t.
   endif
   //GRPBR->(dbsetorder(1))
  return lretrn 
  // ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function _matchbrch()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ   
  local lretrn:= .f.
  
 
   if CLIENT->BRCODE == g_par_brch
		lretrn := .t.
   else
		error('The branch code is different from your current branch.')
		
   endif
   
   
  return lretrn    
   
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function chkgrupname(mCLNTCODE)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CENTER ( 24, 'w+/n', '® Search Client Code ¯' )
   *lb_lkup('Client',1,2,@mCLNTCODE, 3 , 1, 13, 12, 21, 75, 'W/GR+,W/N,,,W/GR+')
   __lb_lkup('Client'  , 1, 2,@mCLNTCODE, 3,45, 1, 13,12,21,75, 'W/GR+,W/N,,,W/GR+')
   @ 24, 00 say repl( ' ',80 ) color 'w+/n'
   return .f.
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function chkmGRUPCODE(mGRUPCODE)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mRETVAL := .t. , mdbf := savedbf ( mdbf )
   if dbseek ( mGRUPCODE )
      ERROR ('Duplicate group code!')
      mRETVAL := .f.
   endif
   restdbf ( mdbf )
   return mRETVAL
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function update_detail(mWHAT)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mSCR := savescreen(,,,), mGRUPCODE := GRPCODES->BRCODE+GRPCODES->GRUPCODE
   local mCLNTCODE, mRECNO := recno(), mCURSOR := setcursor(), getlist := {}

   if ( upper( mWHAT ) == 'A', GRPMEMBR->(dbgoto(lastrec()+1)) , mWHAT := 'R')
   if upper(mWHAT) == 'A'
      CENTER( 24, 'w+/n', '® Add Record ¯' )
   else   
      CENTER( 24, 'w+/n', '® Edit Record ¯' )
   endif   
   fshadow( 09, 15, 12, 43, 2, 'n/w' )
   setcolor( 'bg+/w, w+/n,,, gr+/w' )
   mCLNTCODE := GRPCODES->BRCODE+GRPMEMBR->CLNTCODE

   do while .t.
      @ 10, 16 say ' Group Code ' get mGRUPCODE  pict '@R 999-999' when  .f.      && RED 11112004 REPLACED '@X' when  .f.
      @ 11, 16 say 'Client Code ' get mCLNTCODE  pict '@R 999-99-99999' ;  &&when chkgrupname( @mCLNTCODE ) valid !empty( mCLNTCODE )
                    VALID IF(!EMPTY(RIGHT(mCLNTCODE,7)) .AND. LASTKEY() == K_ENTER,;
                             IF( search_client(mCLNTCODE) ,;//IF( VALBRCODE(LEFT(mCLNTCODE,3),g_USER_ID) .AND. MATCHBRCH(GRPCODES->BRCODE,LEFT(mCLNTCODE,3)).AND. search_client(mCLNTCODE) ,;
                                 CLNTEXIST(mCLNTCODE),;
                                 EVAL({|| mCLNTCODE := GRPCODES->BRCODE+SPACE(7), .F.});
                               ),;
                             EVAL({|| __lb_lkup('Client', 1, 2,@mCLNTCODE, 3,45, 1, 13,05,21,75, 'W/GR+,W/N,,,W/GR+',,,,,,,,' NAME','BRANCH','CODE'),;
                                      IF( LASTKEY() == K_ENTER,;
                                          EVAL({ || mCLNTCODE := CLIENT->BRCODE+mCLNTCODE,;
                                                    IF(search_client(mCLNTCODE) , ;//IF(VALBRCODE(LEFT(mCLNTCODE,3),g_USER_ID) .AND. MATCHBRCH(GRPCODES->BRCODE,LEFT(mCLNTCODE,3)) .AND. search_client(mCLNTCODE) , ;
                                                       .T.,;
                                                       EVAL({|| mCLNTCODE := GRPCODES->BRCODE+SPACE(7), .F.});
                                                      );
                                              }),;
                                          .F.;
                                        );
                                 });
                            )

      setcursor( 3 )                                                   
      read
      setcursor( 0 )

      if lastkey() == K_ESC
         if esckey()
            go mRECNO
            exit
         else
            loop
         endif
      endif
      if ( CONFIRM ( 'All entries correct?' ) )
         MSGWIN(9,26,'Saving','W+/BG','R*/BG','ON')
         if GRPMEMBR->( NETLOCK( mWHAT, 0 ) )
            eval({|| GRPMEMBR->GRUPCODE   := RIGHT(mGRUPCODE,3) ,;
                     GRPMEMBR->CLNTCODE   := RIGHT(mCLNTCODE,7) ,;
                     GRPMEMBR->BRCODE     := LEFT(mGRUPCODE,3)  ,;
					 GRPMEMBR->BRCODE2    := if(LEFT(mGRUPCODE,3) != LEFT(mCLNTCODE,3),LEFT(mCLNTCODE,3),LEFT(mGRUPCODE,3)) ,;
					 GRPMEMBR->USER_ID    := g_USER_ID })
           GRPMEMBR->( dbunlock() )
           GRPMEMBR->( dbcommit() )
           *exit  && RED 11112004 RO EARLY TO EXIT
         endif
         MSGWIN(9,26,'Saving','W+/BG','R*/BG','OFF')
         EXIT
      else
         go mRECNO   
      endif
   enddo
   setcursor( mCURSOR ) ; setcolor ( NRM )
   restscreen(,,,,mSCR)
   return nil

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function search_client(nclntcode)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ   
  local lretrn:= .f.
  GRPMEMBR->(dbsetorder(2))
 
   if GRPMEMBR->(dbseek(nclntcode)) 
		if GRPMEMBR->BRCODE2 == GRPMEMBR->BRCODE  
			error('The Client is already in a group. ')
		else
			lretrn := .t.
		endif	
   else
	GRPMEMBR->(dbsetorder(3))
		if GRPMEMBR->(dbseek(nclntcode)) 
			error('The Client is already in a group. ')
		else	
			lretrn := .t.
		endif	
   endif
   GRPMEMBR->(dbsetorder(1))
  return lretrn 
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function search_head(mGRUPCODE)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mRECNO := GRPCODES->( recno() ) , mCURSOR := setcursor ( setcursor() ), cCOLOR := SETCOLOR()
   local mSCR   := savescreen ( ,,, ), mgroup := GRPCODES->BRCODE+GRPCODES->grupcode ,mgrp
   memvar getlist

   CENTER( 24, 'w+/n' , '® Search Record ¯' )
   SETCOLOR('BG+/W,W+/N,,,GR+/W')
   FSHADOW(03,20,05,44,2,'N/W')
   mGROUP := SPACE(6)
   *@ 04, 36 get mgroup when lb_lkup( 'GRPCODES', 1, 2, @mgroup, 2, 1, 4, 39, 15, 75, 'W/GR+,W/N,,,W/GR+') pict '@X' color 'w+/n'
   @ 04, 22 SAY ' Group Code  '
   @row(),col() say g_par_brch+'-' color 'n/w'
   @ 04, 40 get mgroup PICT '@R 999' VALID IF( !EMPTY(mGROUP) .AND. LASTKEY()==K_ENTER,;
											   EVAL({|| mGROUP := g_par_brch+mgroup, .T.})			,;
											   EVAL({ || mgrp:=ach_look(@mGROUP)  ,;
														 IF( LASTKEY() == K_ENTER,;
															 EVAL({ || mGROUP := mgrp, .T.}),;
															 .F.);
												   });
											 )
    
/*   @ 04, 36 get mgroup PICT '@R 999-999' VALID IF( !EMPTY(mGROUP) .AND. LASTKEY()==K_ENTER,;
                                                   IF( VALBRCODE(LEFT(mGROUP,3),g_USER_ID),;
                                                       .T.,;
                                                       EVAL({|| mGROUP := SPACE(6), .F.}) ),;
                                                   EVAL({ || __lb_lkup( 'GRPCODES', 1, 2, @mgroup, 2, 3, 1, 4, 34, 15, 75, 'W/GR+,W/N,,,W/GR+'),;
                                                             IF( LASTKEY() == K_ENTER,;
                                                                 EVAL({ || mGROUP := GRPCODES->BRCODE+mGROUP, .T.}),;
                                                                 .F.);
                                                       });
                                                 )
*/
   setcursor( 3 )
   read
   setcursor( 0 )

   GRPCODES->( dbsetorder(1))
   if lastkey() != K_ESC
	   if GRPCODES->( dbseek ( alltrim(mgroup) ) )
	      mRECNO := recno()
	   else
	      if lastkey() != K_ESC .and. !empty( mgroup )
	         ERROR ( 'No such group code!' )
	      endif
	   endif
	endif
   restscreen( ,,,, mSCR )
   //GRPCODES->( dbgoto( mRECNO ) )
   setcursor( mCURSOR )
   SETCOLOR(cCOLOR)
   return nil
   
**********************************************
static function ach_look(MCD)
**********************************************
local mod_t:='group', ckey:=space(6)
local headr:='           Group Name         Brcode  Group Code          '
GRPCODES->(dbgotop())
GRPCODES->(dbsetorder(3))
   main_achoice('GRPCODES',3,1,,8,7,21,67,headr,mod_t)
  
  if mpos > 0 .and. lastkey() == K_ENTER .and. !empty(mchoices)
  
		cKEY := substr( ltrim(mchoices[mpos]),24,3)+substr( ltrim(mchoices[mpos]),34,3)
			mcd:=CKEY 
	ENDIF 

return MCD   
   
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function delete_head()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   LOCAL nORGORD := GRPMEMBR->(INDEXORD())

   MSGWIN(12,35,'Deleting','w+/bg','r*/bg','on')

   GRPMEMBR->(DBSETORDER(1))

   if GRPCODES->( netlock ('R',0) )
      GRPCODES->( dbdelete() )

      if GRPMEMBR->( dbseek ( GRPCODES->BRCODE+GRPCODES->GRUPCODE ) )
         *IF GRPMEMBR->(netlock( 'F', 0 ) )
            GRPMEMBR->(dbeval( {|| GRPMEMBR->(netlock( 'R', 0 )),;
                                   GRPMEMBR->(dbdelete()),;
                                   GRPMEMBR->(DBUNLOCK()) ;
                               } ,,;
                               {|| GRPMEMBR->BRCODE+GRPMEMBR->GRUPCODE == GRPCODES->BRCODE+GRPCODES->GRUPCODE .and. ;
                                   !GRPMEMBR->(eof());
                               };
                             );
                      )
         *   GRPMEMBR->( dbunlock() )
         *ENDIF
      endif


      GRPCODES->( dbskip ( +1 ) )

      if ( GRPCODES->( eof() ) ,;
           GRPCODES->(dbskip(-1)),;
           nil )

      GRPCODES->( dbunlock() )
   endif

   GRPMEMBR->(DBSETORDER(nORGORD))

   MSGWIN(12,35,'Deleting','w+/bg','r*/bg','off')
   return nil
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function search_detail(mCLNTCODE, mROW)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mRECNO := recno(), mSCR := savescreen ( ,,, ), mLCOLOR := setcolor(), nORGORD := GRPMEMBR->(INDEXORD())
   memvar getlist

   CENTER( 24, 'w+/n', '® Search Record ¯' )
   fshadow( 12, 11, 14, 41, 2, 'n/w' )
   setcolor( 'bg+/w, w+/n,,, gr+/w' )
   GRPMEMBR->(DBSETORDER(2))

   @ 13, 12 say 'Client Code N§ ' get mCLNTCODE pict '@R 999-99-99999';
                                    VALID IF( !EMPTY(RIGHT(mCLNTCODE,7)) .AND. LASTKEY() == K_ENTER,;
                                           IF( VALBRCODE(LEFT(mCLNTCODE,3),g_USER_ID),;
                                               IF( fPAD0110(@mCLNTCODE), .T., EVAL({|| mCLNTCODE := SPACE(10), .F.}) ),;
                                               EVAL({|| mCLNTCODE := SPACE(10), .F. });
                                             ),;
                                           EVAL({|| __lb_lkup('Client', 1, 2,@mCLNTCODE, 3,45, 1, 13,05,21,75, 'W/GR+,W/N,,,W/GR+',,,,,,,,' NAME','BRANCH','CODE'),;
                                                    IF( LASTKEY() == K_ENTER,;
                                                         .T.,;
                                                        EVAL({|| mCLNTCODE:=SPACE(10), .F.});
                                                      );
                                               });
                                         )

   setcursor( 3 )
   read
   setcursor( 0 )
   
/*                                           EVAL({|| mCLNTCODE:= EVAL({ || ach_loo2() }),;
                                                    IF( LASTKEY() == K_ENTER,;
                                                        IF( VALBRCODE(LEFT(mCLNTCODE,3),g_USER_ID), .T., EVAL({|| mCLNTCODE:=SPACE(10), .F.}) ),;*/
   
   
   if !empty(mCLNTCODE)
		mCLNTCODE:=CLIENT->BRCODE+mCLNTCODE
   endif

   if GRPMEMBR->(dbseek(mCLNTCODE))
	do while mclntcode == GRPMEMBR->BRCODE+GRPMEMBR->CLNTCODE
		if left(mCLNTCODE,3) == GRPMEMBR->BRCODE2
			mRECNO := GRPMEMBR->(recno())
			exit
		else
			GRPMEMBR->(dbskip(1))
		endif
	enddo  
   else
		GRPMEMBR->(DBSETORDER(3))
		if GRPMEMBR->(dbseek(mCLNTCODE))
			mRECNO := GRPMEMBR->(recno())
		else
   
		      if( lastkey()!=K_ESC .and. !empty( mCLNTCODE ),;
		          EVAL({ || ERROR( 'No such client code!' ),;
		                    DBGOTO( mRECNO ) ;
		              }),;
		          nil;
		        )
	     endif
	endif
	
   GRPMEMBR->(DBSETORDER(nORGORD))
   GRPMEMBR->(dbgoto( mRECNO ))
   restscreen( ,,,, mSCR )
   setcolor( mLCOLOR )
   return nil
**********************************************
static function ach_loo2()
**********************************************
local mod_t:='WCLTYPE', ckey:=space(10)
local headr:='    Client Name                           Branch  Clntcode  Cltype'
   
   main_achoice('CLIENT',3,1,,8,7,21,75,headr,mod_t)
   
  if mpos > 0 .and. lastkey() == K_ENTER .and. !empty(mchoices)
				cKEY := substr( ltrim(mchoices[mpos]),44,3)+substr( ltrim(mchoices[mpos]),50,2)+;
				substr( ltrim(mchoices[mpos]),53,5)
				client->(dbsetorder(1))
				
             if Client->( dbseek (alltrim(cKEY)) )   
                aNRECNO  := Client->(RECNO())
				
            endif		 
	ENDIF 
nrecno:= aNRECNO  
return ckey
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function fPad0110( mcd )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local result := .t., nntx := Client->(indexord()),nrecno := Client->(recno())

   Client->(dbsetorder(1))            //   clntcode

   *mcd := padl(alltrim(mcd),7,"0")     && RED

   if ! Client->(dbseek( mcd ))
      result := .f.
      error ( 'Record not found in Client Master!' )
      Client->(dbgoto(nrecno))
   endif

   Client->(dbsetorder(nntx))

return result   
   
   
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function delete_detail(mGRUPCODE,mCLNTCODE)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

   if CONFIRM('Delete client code ' +trans(mCLNTCODE,'@R 999-99-99999')+ '?')
      MSGWIN(12,35,'Deleting','W+/BG','R*/BG','ON')
      if netlock( 'R', 0 )
         GRPMEMBR->( dbdelete() )      
         GRPMEMBR->( dbskip( +1 ) )
         if GRPMEMBR->BRCODE+GRPMEMBR->GRUPCODE != GRPCODES->BRCODE+GRPCODES->GRUPCODE
            GRPMEMBR->( dbgoto( GRPMEMBR->( lastrec() ) + 1 ) )         
            GRPMEMBR->( dbseek( mGRUPCODE ) )                
         endif
         GRPMEMBR->( dbunlock() )
      endif
      MSGWIN(12,35,'Deleting','W+/BG','R*/BG','OFF')
   endif

   return nil
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function AMSM1009OPEN()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mRETVAL := .f.
   if NETUSE('&g_AMS_PATH\GRPCODES',.f.,5)
      set index to &g_AMS_PATH\GRPCODES,;
                   &g_AMS_PATH\GRPNAMES,;
				   &g_AMS_PATH\GRPBRNM ,;
				   &g_AMS_PATH\GRPCDCLT
					  
      if NETUSE('&g_AMS_PATH\GRPMEMBR',.f.,5)
         set index to &g_AMS_PATH\GRPMEMBR,;
                      &g_AMS_PATH\GRPCLNT ,;
					  &g_AMS_PATH\GRPCLNT2,;
					  &g_AMS_PATH\GRPMEMB2
					  
	      if NETUSE('&g_AMS_PATH\OL_PARAM',.f.,5)
	         set index to &g_AMS_PATH\OL_PARAM

	         if NETUSE('&g_CIS_PATH'+'\CLIENT.dbf',.f.,5)
	            set index to &g_CIS_PATH\CLIECD,;
	                         &g_CIS_PATH\CLIENM,;
							 &g_cis_path\cliebf
							 
				if NETUSE('&g_GRF_PATH'+'\BRANCHES.dbf',.f.,5)
					set index to &g_GRF_PATH\BRANCHES	 
						mRETVAL := .t.
				endif		
			endif			
         endif
      endif
   endif
   
   if !netuse( '&g_grf_path'+'\Axbranch.dbf',.f.,5)
      return .f.
   endif
   set index to &g_grf_path\Axbranch
   
   return mRETVAL

// Eop: AMSM1009.prg //
*----------------------------------------
FUNCTION CLNTEXIST(mCLNTCODE)
LOCAL lRETVAL := .F.
LOCAL nORGNTX := CLIENT->(INDEXORD())

CLIENT->(DBSETORDER(1))
IF CLIENT->(DBSEEK(mCLNTCODE))
   lRETVAL := .T.
ELSE
   ERROR('Client number not found!')
ENDIF

CLIENT->(DBSETORDER(nORGNTX))
RETURN lRETVAL
*----------------------------------------
FUNCTION MATCHBRCH(cGRPCOD,mCLNTCODE)
lRETVAL := .F.

IF cGRPCOD == mCLNTCODE
   lRETVAL := .T.
ELSE
   ERROR('The branch code is different from the group.')
ENDIF

RETURN lRETVAL

**********************************
*
static function _SELCT_BY()     
**********************************
   local _cscr := savescreen (,,,),menulist := {},bx := setcolor()
   
   setcolor  ( 'bg/gr+,n/w,,, w/gr+' )
   @ 08,25 clear to 11,35
   @ 08,25 to 11,35
   @ 08, 26 say 'Print' color 'W+/bg'
   @ 09,26 prompt 'By Branch'
   @ 10,26 prompt 'All  '
   menu to _USER_choice
   do case
      case _user_choice == 1
			 fbrch4300()
      case _user_choice == 2
			
   endcase
setcolor  ( bx )
   restscreen  (,,,,_cscr)
return lastkey () != K_ESC


***************************
*
static function fbrch4300()
***************************
local  ax := !.t., getlist := {}, bx := setcolor()
//memvar dit, mpage

fshadow ( 10, 30, 12, 49, 2, 'bg/gr+' )

setcolor  ( 'bg/gr+,n/w,,, w/gr+' )
setcursor (1)
//@  10, 31 say 'Execution Date' color 'n/bg'
@ 11, 32 say 'Branch Code  '
@ 11, 45 get cbrcode pict '@R 999'  valid !empty(cbrcode)  


setcursor ( 3 )
read           // timeout 20 exitevent blankscr3( -1 )
setkey    ( K_ESC, nil )

setcursor ( 0  )
setcolor  ( bx )


return 

************************
*
function _fprint1009()
************************
memvar _USER_choice
local noclntcd := 0, wiclntcd := 0, _grtot
private mpage := 1, _ghead:= .t., nbrcode, cbrcode := g_par_brch


fHead1009()
if _USER_choice == 1
	GRPCODES->(dbseek(cBRCODE))
endif	

nbrcode:=GRPCODES->BRCODE
Branches->(dbseek(nbrcode))

@ prow()+ 1   , 02 say 'Branch: '
SETFONT('BOLD')
@ prow()   , 12 say BRANCHES->BRCODE+'-'+BRANCHES->BRNAME
SETFONT('UNBOLD')

GRPCODES->(dbsetorder(1))

do while if(_USER_choice == 2, !GRPCODES->(eof()), cBRCODE == GRPCODES->BRCODE  )
					
			if prow() >= 57
			  // setfont( upper( 'uncondensd' ) )
				__eject()
				fHead1009()
			endif				
	
		if GRPCODES->BRCODE != nbrcode
				__eject()
				fHead1009()
				_ghead := .t.
				nbrcode:=GRPCODES->BRCODE
				Branches->(dbseek(nbrcode))
				@ prow()+ 1   , 02 say 'Branch: '
				SETFONT('BOLD')
				@ prow()   , 12 say BRANCHES->BRCODE+'-'+BRANCHES->BRNAME
				SETFONT('UNBOLD')
		endif
		
		@ prow()+ 1   , 02 say 'Group Code:'+'  '+GRPCODES->BRCODE + "-" + GRPCODES->GRUPCODE
		@ prow()+ 1   , 02 say 'Group Name:'+' '+if(!empty(GRPCODES->CLNTCODE),'['+GRPCODES->BRCODE+'-'+ trans(GRPCODES->CLNTCODE,'@R 999-9999') +'] ','[--------] ')  + substr(GRPCODES->GRUPNAME,1,40)

		if(!empty(GRPCODES->CLNTCODE),wiclntcd++,noclntcd++)

			if prow() >= 57
				__eject()
				fHead1009()
			endif					

		if GRPMEMBR->(dbseek(GRPCODES->BRCODE+GRPCODES->GRUPCODE))
			
			do while GRPCODES->BRCODE+GRPCODES->GRUPCODE == GRPMEMBR->BRCODE+GRPMEMBR->GRUPCODE
				if prow() >= 57
				 //  setfont( upper( 'uncondensd' ) )
					__eject()
					fHead1009()
				endif		
				
				@ prow()+ 1 , 5 say '('+GRPMEMBR->BRCODE+')'+'  '+transform( GRPMEMBR->BRCODE2+GRPMEMBR->CLNTCODE, '@R 999-99-99999' )+ ' '+;
				dispclntname( GRPMEMBR->BRCODE2+GRPMEMBR->CLNTCODE, 40 )+'  '+ _get_branch(GRPMEMBR->BRCODE2)
				GRPMEMBR->(dbskip(1))
			enddo
		endif
		@ prow()+ 1   , 1 say '  '
	GRPCODES->(dbskip(1))
enddo

_grtot:= wiclntcd + noclntcd

				if prow() >= 57
				 //  setfont( upper( 'uncondensd' ) )
					__eject()
					fHead1009()
				endif		
@ prow()+ 1 , 5 say 'Total No. of Groups w/  Client Codes: '//+ trans(wiclntcd,'@R 999') 
@ prow()    , 45 say wiclntcd PICT '@R 9,999'
@ prow()+ 1 , 5 say 'Total No. of Groups w/o Client Codes: '//+ trans(noclntcd,'@R 999') 
@ prow()    , 45 say noclntcd PICT '@R 9,999'
 @ prow() + 1,  42 say repl( 'Í', 13 )
@ prow()+ 1 , 5 say '                         GRAND TOTAL: '//+ '['+ trans(_grtot,'@R 999') + ']'
@ prow()    , 45 say  _grtot PICT '@R 9,999'
__eject()
return  

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function fHead1009()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   memvar mpage, gSYS_NAME, gCOMPANY, nwpage
   
   setfont( upper( 'INIT' ) )
   setprc  ( 0,0 ) 
   setfont( upper( 'uncondensd' ) )
   SETFONT('PICA')
   @ prow()+1,0 say gSYS_NAME
   @ prow(),80-11-0 say 'Page : ' + str(mpage++,4)
   @ prow()+1,0        say 'AMSM1009'
   @ prow() ,80-19-0 say dtoc(date()) + ' ' + time()
   @ prow()+1,0        say 'User: ' + g_user_id

      PAGECENTER(prow()+2,80,'ORIX METRO LEASING and FINANCE CORPORATION')
      SETFONT('BOLD')
      PAGECENTER(prow()+1,80,'CLIENT GROUPS ')
      SETFONT('UNBOLD')
  @ prow() + 1, 1 say '  ' 
 // setfont( upper( 'uncondensd' ) )
	// prnreptitle( 80, 5, mpage++, 'ACCOUNTS WITH LACKING DOCUMENTS', 'MISU4300', gSYS_NAME, gCOMPANY )
	//PAGECENTER(prow()+1,80,'Execution Date for the Period '+alltrim(dtoc(sdate)) + ' to ' +alltrim(dtoc(edate)))
   //  @ prow() + 1, ( 80 - 16 ) / 2 say 'As of ' + dtoc( Flag->lastclosed )
 			 setfont( upper( 'normal' ) )	
		     @ prow() + 1, 1 say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
		     @ prow() + 1, 1 say '³       Code       ³                Client Name                ³      Branch      ³'
		     @ prow() + 1, 1 say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'		
 /*    setfont( upper( 'condensed' ) )                                                     
     @ prow() + 1, 1 say 'ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
     @ prow() + 1, 1 say '³         ³          ³          ³                                                                                                          ³'
     @ prow() + 1, 1 say '³ User ID ³   Date   ³   Time   ³                                                  Action                                                  ³'
     @ prow() + 1, 1 say 'ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
*/	 
   return
************************************
*                                         // abb 10.12.2004
static function _get_branch(cbrcode)
************************************
   local cretval := space(20)

   IF !EMPTY(cBRCODE)
      if Branches->(dbseek(alltrim(cbrcode)))
         cretval := Branches->brname
      endif
   ENDIF

return alltrim(cretval)
