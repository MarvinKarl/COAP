/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   PROGRAM ID.........:  amsm0300.prg                                         ³
³   Description........:  loan offering ticket maintenance                     ³
³   Author.............:  Ariel B. Bulan                                       ³
³   Date...............:  09:42pm 19-Sep-1994                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                         U P D A T E S                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        Who        ³     When      ³               Why                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ janet l. bautista ³  16-Apr-1996  ³ follow standard coding structure         ³
³ renan evangelista ³  25-Jun-1996  ³ modify printing and limit the            ³
³                   ³               ³ access of ao                             ³
³ abb               ³               ³ ONLINE                                   ³
³ mts               ³  7/21/2008    ³  comment out (Scanning for valid branch/ ³
³                   ³               ³  user records) & modified for exlusive   ³
³                   ³               ³  use according to user's branch code     ³
³ mts               ³  8/31/2011    ³  added wtax on CADETAIL for CML & ML     ³
³ RLV               ³  9/20/2011    ³  Modified Structure for DOSRI Tagging    ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include "COLF.CH"
#include "INKEY.CH"
#include "MEMOEDIT.CH"

private xTEMP     // EVR 27112006

if CHKPASS(procname(),AX_LEVEL,g_USER_ID)
   if AMSM0300OPEN()
      //nosnow( .t. )
      //drop  ( '[û]'+alltrim(g_user_id)+' '+'Enters Offering Ticket' )   //aga.15.10.2007.essential trace onlu
      FM0300()

      (xTEMP)->(dbclosearea())     // EVR 27112006
      ferase(xTEMP+'.DBF')
      ferase(xTEMP+'.NTX')

      //drop  ( '[X]'+alltrim(g_user_id)+' '+'Quits Offering Ticket' )   //aga.15.10.2007.essential trace only
//      nosnow( .f. )
   endif
endif
release all
close data
return

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
// Description  program's main function
   static function FM0300()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local keys_ := { '<Ins>\-Add ', '<F2>\Edit ', '<F4>\Search ', '<F5>\Details ', '<F6>\Action ', '<F9>\Print ', '<Del>\ ', '<Esc>\' }
   local nROW := 5, mROW := 1, mbanner := 'Offering Ticket File Maintenance'
   local nscanctr := 0
   local getlist := {}
   //LOCAL cVALCODE := ACC_BRCH(cUSER)
   LOCAL lFIRSTOT := .F., cAO := ' '     // EVR 27112006
   private cdivhead := space(5), cdivpost := space(30)
   private creason := space(1) ,_reason_desc := space(40)
   private sbrcode := space(3) ,soticket  := space(len(OTICKET->BRCODE+Oticket->otnumber))

   dbselectar((xTEMP))     // EVR 27112006
   if Aoaccess->(dbseek(g_PAR_BRCH+g_USER_ID))
      do while !Aoaccess->(eof()) .and. Aoaccess->BRCODE+Aoaccess->AOCODE == g_PAR_BRCH+g_USER_ID
         if Aoaccess->AOACCESS <> cAO
            if Ao->(dbseek(padr(alltrim(Aoaccess->AOACCESS),5,' ')))
               append blank
               (xTEMP)->AOCODE := Ao->AOCODE
               (xTEMP)->AONAME := Ao->AONAME
            endif
         endif
         cAO := Aoaccess->AOACCESS
         Aoaccess->(dbskip())
      enddo
   endif

   dbselectar ( 'Oticket' )
   Oticket->  ( dbgotop() )

   sbrcode := g_PAR_BRCH
   @ 8,30 clear to 10,63
   @ 8,30 to 10,63
   @ 9,31 say 'Offering Ticket No. : ' get soticket pict '@R 999-99999'
   setcursor(3)
   read
   setcursor(0)

   if lastkey() == K_ESC
      return
   endif

   nrecno := 0
   if empty(soticket)
      // search for name instead

      fsearch (sbrcode)

      *if !_BR_rights ( g_user_id )   // ABB 10.12.2004     && RED 032805
      IF LASTKEY() == K_ENTER
         //IF !(OTICKET->BRCODE $ cVALCODE)
		 if Oticket->BRCODE <> g_PAR_BRCH  //chk_user() 
            *error ( 'Cannot access OT of ' + _get_branch(Oticket->brcode) )  && RED 032805
            Oticket->(dbgoto(nrecno))
			
            lFIRSTOT := .T.
            *return // abb 10.22.04
         else
            *if !_rights ( OTICKET->BRCODE, Oticket->aocode ) .or. Oticket->(eof())
            if !_rights ( OTICKET->AOCODE ) .or. Oticket->(eof())
               error ( 'OT belongs to '+Oticket->aocode )
               Oticket->(dbgoto(nrecno))
               return // abb 10.22.04
            else
               sbrcode  := Oticket->brcode
               soticket := OTICKET->BRCODE+Oticket->otnumber       // abb 10.22.2004
            endif
         endif
      ENDIF
   else
      *soticket := right ( '00000'+alltrim(soticket),5 )    && RED 112304
      IF LEN(ALLTRIM(SOTICKET)) < 8
         SOTICKET := LEFT(SOTICKET,3) + PADL(ALLTRIM(SUBSTR(SOTICKET,4,5)),5,'0')
      ENDIF
   endif

   if lastkey() == K_ESC
      return
   endif

   IF lFIRSTOT                      &&\
      __KEYBOARD ( CHR( K_INS ) )   && > RED 060605
   ELSE                             &&/
      if !Oticket->(dbseek(soticket))   && RED 112204 REMOVED 'sbrcode+
         error ( 'Offering Ticket No. '+soticket+' for branch '+sbrcode+' not found' )
         return
      endif

      if Oticket->(eof())
         error ( 'End of File' )
         return
      endif

      *if !_rights ( OTICKET->BRCODE, Oticket->aocode )
      if !_rights ( Oticket->aocode )
         error ( 'OT belongs to '+Oticket->aocode )
         Oticket->(dbgoto(nrecno))
         return // abb 10.22.04
      endif
	  
	  if OTICKET->BRCODE <> g_par_brch
         error ( 'Invalid Branch' )
         Oticket->(dbgoto(nrecno))
         return 
	  endif
	  

      nscanctr := 0
	  
   /** pepe 11:38 AM 7/21/2008
      *do while !_rights ( OTICKET->BRCODE, Oticket->aocode ) .and. !Oticket->(eof())
      do while !_rights ( Oticket->aocode ) .and. !Oticket->(eof())
         nscanctr :=  nscanctr + 1
         @ 22,1 say 'Scanning for valid branch/user records : '+padr( alltrim(trans(nscanctr,"99,999,999" )), 12 )
         Oticket->(dbskip(+1))
      enddo


	   if !_rights(Oticket->aocode)
	       error ( 'OT belongs to '+Oticket->aocode )
		   Oticket->(dbgobottom())
		   Oticket->(dbskip(+1))
	   endif
   **/
   
   ENDIF                            && RED 060605

   scr_make   ( keys_, 3, 1, 22, 78, mbanner )

   disphead ()
   if Oticket->( eof() )
      error      ( "No record found!" )
      __keyboard ( chr( K_INS ) )
   endif

   do while eval (  { || disprec  (),;
                         gkey0300 ( @mrow, @nrow ) ;
                   };
                 )
   enddo

return nil



*********************************************
*
*
static function gkey0300 ( mrow, nrow )
*********************************************
   local mretval := .t., mkey, nrecno := 0,cscr, F4SCR, SRCH := SPACE(8)
   private mscreen

   mkey := inkey ( 0 )
  
   do case

     *****     case mKEY == K_HOME
     *****    if CHKPASS( 'S', AX_LEVEL, g_USER_ID )
     *****       nrecno := Oticket->(recno())
     *****       Oticket->( dbgotop() )
     *****       do while !_rights ( Oticket->aocode ) .and. !Oticket->(eof())
     *****          Oticket->(dbskip(+1))
     *****       enddo
     *****       if Oticket->(eof())
     *****          error     ( 'This is the first record'  )
     *****          Oticket-> ( dbgoto(nrecno) )
     *****       endif
     *****    endif
     ***** case mKEY == K_END
     *****    if chkpass ( 'S', AX_LEVEL, g_USER_ID )
     *****      nrecno := Oticket->(recno())
     *****      Oticket->( dbgobottom() )
     *****      do while !_rights ( Oticket->aocode ) .and. !Oticket->(bof())
     *****         Oticket->(dbskip(-1))
     *****      enddo
     *****      if Oticket->(bof())
     *****         error     ( 'This is the last record'  )
     *****         Oticket-> ( dbgoto(nrecno) )
     *****      endif
     *****    endif


      case mKEY == K_UP .or. mKEY == K_PGUP

         if g_PAR_BRCH == '001'

         if chkpass ( 'S', AX_LEVEL, g_USER_ID )

            nrecno := Oticket->(recno())

            Oticket->( dbskip( -1 ) )

            if alltrim(Oticket->brcode) != alltrim(sbrcode)
               error ( 'Top of Branch File' )
               Oticket->(dbgoto(nrecno))

            else

               nscanctr := 0
               cscr := savescreen (,,,)
			   
			   /** pepe 2:12 PM 7/21/2008
               *do while !_rights(OTICKET->BRCODE, Oticket->aocode)  .and. !Oticket->(bof())
               do while !_rights( Oticket->aocode)  .and. !Oticket->(bof())
      
                  nscanctr :=  nscanctr + 1
                  @ 22,1 say 'Scanning for valid branch/user records : '+padr( alltrim(trans(nscanctr,"99,999,999" )), 12 )
                  Oticket->(dbskip(-1))

                  if alltrim(Oticket->brcode) != alltrim(sbrcode)
                     restscreen (,,,,cscr )
                     if alltrim(sbrcode) == '001'
                        error ( 'Top of Head Office File' )
                     else
                        error ( 'Top of Branch File' )
                     endif
                     Oticket->(dbgoto(nrecno))
                     exit
                  endif
     
               enddo
			   **/
			   
			   if !_rights(Oticket->aocode)
		 	      Oticket->(dbskip(-1))
		          if !aoaccess->(dbseek(alltrim(Oticket->brcode)+left(alltrim(G_USER_ID)+'   ',6)+alltrim(Oticket->aocode)))

			       do while !Oticket->(bof())
			         if aoaccess->(dbseek(alltrim(Oticket->brcode)+left(alltrim(G_USER_ID)+'   ',6)+alltrim(Oticket->aocode)))
			 	        exit
			         endif
			       Oticket->(dbskip(-1))
			      enddo
			    endif
			   endif
				  
               restscreen (,,,,cscr )

               if Oticket->(bof())
                  error ( 'This is the first record'  )
                  Oticket->(dbgoto(nrecno))
               endif

            endif

           endif
         endif

      case mKEY == K_DOWN .or. mKEY == K_PGDN
	  

         if g_PAR_BRCH == '001'

         if chkpass ( 'S', AX_LEVEL, g_USER_ID )

            nrecno := Oticket->(recno())

            Oticket->( dbskip( +1 ) )
			
			IF Oticket->BRCODE ==  g_PAR_BRCH

	            cscr := savescreen (,,,)
	            nscanctr := 0


				/** pepe 2:12 PM 7/21/2008
	            *do while !_rights ( OTICKET->BRCODE, Oticket->aocode ) .and. !Oticket->(eof())
	            do while !_rights ( Oticket->aocode ) .and. !Oticket->(eof())
	               nscanctr :=  nscanctr + 1
	               @ 22,1 say 'Scanning for valid branch/user records : '+padr( alltrim(trans(nscanctr,"99,999,999" )), 12 )
	               Oticket->(dbskip(+1))

	               if alltrim(Oticket->brcode) != alltrim(sbrcode)
	                  restscreen (,,,,cscr )

	                  if alltrim(sbrcode) == '001'         // abb 10.13.2004
	                     error ( 'End of Head Office File' )
	                  else
	                     error ( 'End of Branch File' )
	                  endif
	                  Oticket->(dbgoto(nrecno))
	                  exit
	               endif

	            enddo
				**/

				if !_rights(Oticket->aocode)
		 		   Oticket->(dbskip(+1))
			           if !aoaccess->(dbseek(alltrim(Oticket->brcode)+left(alltrim(G_USER_ID)+'   ',6)+alltrim(Oticket->aocode)))

					      do while !Oticket->(eof())
						     if Oticket->brcode == g_PAR_BRCH
						          if aoaccess->(dbseek(alltrim(Oticket->brcode)+left(alltrim(G_USER_ID)+'   ',6)+alltrim(Oticket->aocode)))
							         exit
						          endif
							 endif 
					      Oticket->(dbskip(+1))
						  enddo
					   endif
				endif

            restscreen (,,,,cscr )
			
			ELSE
		        Oticket->(dbgobottom())
	            Oticket->(dbskip(+1))
			ENDIF

            if Oticket->(eof())
               error ( 'This is the last record' )
               Oticket->( dbgoto(nrecno) )
            endif

         endif
         endif

      case mKEY == K_DEL

         if CURRBRCH(OTICKET->BRCODE) .AND. chkpass ( 'E', AX_LEVEL, g_USER_ID ) .and. Oticket->actaken == '1'

            if Oticket->( eof() )
               error ( 'Nothing to delete!' )
            else

              *if _rights ( OTICKET->BRCODE, Oticket->aocode )
              if _rights ( Oticket->aocode )

                   nrecno := Oticket->(recno())

                   if fdelete ()
                      mretval := .f.           // abb 10.13.2004
                      error ( 'Record deleted!' )
                      return mretval
                   else
                      Oticket->(dbgoto(nrecno))
                      return .t.
                   endif


                   //do while !_rights ( Oticket->aocode ) .and. !Oticket->(eof())
                     // Oticket->(dbskip(+1))
                   //enddo

                  nscanctr := 0
				  
			      /** pepe 2:12 PM 7/21/2008
                  *do while !_rights ( OTICKET->BRCODE, Oticket->aocode ) .and. !Oticket->(eof())
                  do while !_rights ( Oticket->aocode ) .and. !Oticket->(eof())
                     nscanctr :=  nscanctr + 1
                     @ 22,1 say 'Scanning for valid branch/user records : '+padr( alltrim(trans(nscanctr,"99,999,999" )), 12 )
                     Oticket->(dbskip(+1))

                     if alltrim(Oticket->brcode) != alltrim(sbrcode)
                        restscreen (,,,,cscr )
                        error ( 'End of Branch File' )
                        Oticket->(dbgoto(nrecno))
                        exit
                     endif

                  enddo
				  **/

				  if !_rights(Oticket->aocode)
			 	     Oticket->(dbskip(-1))
			         if !aoaccess->(dbseek(alltrim(Oticket->brcode)+left(alltrim(G_USER_ID)+'   ',6)+alltrim(Oticket->aocode)))

					     do while !Oticket->(bof())
					       if aoaccess->(dbseek(alltrim(Oticket->brcode)+left(alltrim(G_USER_ID)+'   ',6)+alltrim(Oticket->aocode)))
					 	      exit
					       endif
					     Oticket->(dbskip(-1))
					    enddo
					  endif
				  endif

                  if Oticket->(eof())
                     error ( 'This is the last record' )
                     Oticket->(dbgoto(nrecno))
                  endif

               else
                  error ( 'Cannot delete OT of '+Oticket->aocode ) 
               endif

            endif

         endif

      case mKEY == K_INS
         if CHKPASS( 'A', AX_LEVEL, g_USER_ID )   
            FUPDATE( 'A' )     
         endif   
      case mKEY == K_F2
         if CURRBRCH(OTICKET->BRCODE) .AND. CHKPASS( 'E', AX_LEVEL, g_USER_ID ) .and. ;
            _chkright(Oticket->Aocode,sbrcode)           .and. ;
            Oticket->actaken == '1'

            if OTICKET->( eof() )
               ERROR( 'Nothing to edit!' ) 
            else
               FUPDATE( 'E' )
            endif
         else
            if Oticket->actaken == '3'
               error ( 'Cannot edit Approved OT' )
            elseif Oticket->actaken == '5'
               error ( 'Cannot edit Closed OT' )
            endif

         endif
      case mKEY == K_F4

         if chkpass ( 'S', AX_LEVEL, g_USER_ID )

            if Oticket->( eof() )
               error( 'Nothing to search!' )
            else

              nrecno := Oticket->(recno())

              F4SCR := SAVESCREEN(08,30,10,63)

              @ 8,30 CLEAR TO 10,63
              @ 8,30 TO 10,63
              @ 9,31 SAY 'OFFERING TICKET NO. : ' GET SRCH PICT '@R 999-99999'

              SETCURSOR(3)
              READ
              SETCURSOR(0)

              RESTSCREEN(08,30,10,63,F4SCR)

              IF LASTKEY() <> K_ESC

                 IF EMPTY(SRCH)
                    fsearch (sbrcode)

                    if Oticket->BRCODE <> g_PAR_BRCH //pepe 9:46 AM 7/23/2008 {!_BR_rights ( g_USER_ID, 'OTICKET' )}
                       error ( 'Cannot access OT of ' + _get_branch(Oticket->brcode) )
                       Oticket->(dbgoto(nrecno))
                    else

                       *if !_rights ( OTICKET->BRCODE, Oticket->aocode ) .or. Oticket->(eof())
                       if !_rights ( Oticket->aocode ) .or. Oticket->(eof())
                          error ( 'OT belongs to '+Oticket->aocode )
                          Oticket->(dbgoto(nrecno))
                       else
                          sbrcode := Oticket->brcode
                       endif

                    endif
                 ELSE
                    IF LEN(ALLTRIM(SRCH)) < 8
                       SRCH := LEFT(SRCH,3) + PADL(ALLTRIM(SUBSTR(SRCH,4,5)),5,'0')
                    ENDIF

                    IF LASTKEY() <> K_ESC

					   IF SUBS(SRCH,1,3) == g_PAR_BRCH                          //pepe 9:46 AM 7/23/2008
	                       IF !OTICKET->(DBSEEK(SRCH))
	                          error ( 'Offering Ticket No. '+SRCH+' for branch '+sbrcode+' not found' )
	                          OTICKET->(DBGOTO(nRECNO))
	                       ELSEIF Oticket->(eof())
	                          error ( 'End of File' )
	                          OTICKET->(DBGOTO(nRECNO))
	                       *ELSEIF !_rights ( OTICKET->BRCODE, Oticket->aocode )
	                       ELSEIF !_rights ( Oticket->aocode )
	                          error ( 'OT belongs to '+Oticket->aocode )
	                          OTICKET->(DBGOTO(nRECNO))
	                       ENDIF
					   ELSE
                           error ( 'Cannot access OT of ' + _get_branch(SUBS(SRCH,1,3)) )
                           Oticket->(dbgoto(nrecno))
					   ENDIF

                    ENDIF
                 ENDIF

              ENDIF

            ENDIF

         ENDIF

      case mKEY == K_F5

         if chkpass ( 'S', ax_level, g_user_id )

            if OTICKET->( eof() )              
               ERROR( 'No details available!' )            
            else
               tones()

               *if _rights ( OTICKET->BRCODE, Oticket->aocode )
               if _rights ( Oticket->aocode )
                  F0500DETAILS()
               else
                  error ( 'Cannot update OT of '+Oticket->aocode )
               endif

            endif

         endif   
      case mKEY == K_F6        
         if CHKPASS( 'A', AX_LEVEL, g_USER_ID ) .and. _chkright(Oticket->Aocode,sbrcode)
			Client->(ordsetfocus(1))
			if Client->(dbseek(Oticket->brcode+Oticket->clntcode))
				if Client->status !='3'
					error('Client not yet reviewed!')
				else
					if look_approver ( G_USER_ID )
						if OTICKET->( eof() )
							ERROR( 'Nothing to edit!' )
						else
							if _rights ( Oticket->aocode )

								if alltrim(Oticket->AOCODE) != alltrim(G_USER_ID)
									FUPDATE( 'E', .t. )
								else
									alert ( 'ERROR : User cannot approve own Credit Application / Offering Ticket' )
								endif

							else
								error ( 'Cannot update OT of '+ Oticket->aocode )
							endif
							
						endif
					else
					  error ( 'User '+alltrim(G_USER_ID)+' Cannot Proceed ' )
					endif
				endif
			endif
         endif   
      case mKEY == K_F9

         if CHKPASS( 'S', AX_LEVEL, g_USER_ID )

            if Oticket->actaken != '5'            // closed OT 10.13.2004

               if OTICKET->( eof() )
                  ERROR( 'Nothing to print!' )
               else

                  *if _rights ( OTICKET->BRCODE, Oticket->aocode )
                  if _rights ( Oticket->aocode )
					//if alltrim(Caheader->AOCODE) != alltrim(G_USER_ID)
                       **** if Oticket->( netlock( 'R', 5 ) )
							if _getdivhead( Oticket->AOCODE )  // division head 10/10/2000
								*repcontrol( 'otprint()' )
								repcon_ol( 'otprint()',,,,,,,.F. )
								*repORTPRINT( 'otprint()' )
								Drop  ( alltrim(g_user_id)+' '+'Prints OTicket No. '+Oticket->otnumber )
							endif
						****endif
                     ****Oticket->( dbunlock() )
                    //else
                    //   alert ( 'ERROR : User cannot approve own Credit Application.' )
                    //endif
                     
                  else
                     error ( 'Cannot print OT of '+Oticket->aocode )
                  endif

               endif
            else
               error ( 'Cannot Print Closed OT' )
            endif

         endif      
      case mKEY == K_ESC
         if exitmod()
            mRETVAL := !mRETVAL
         endif   
   endcase
   // tb_indicator( mKEY, @mROW, @nROW, 78, 5, 20 )
   return( mRETVAL )

***************************************
*
static function _rights ( caocode )
***************************************
    local lretval := .f.,nrec := aoaccess->(recno())

//    alert ( alltrim(Oticket->brcode)+left(alltrim(G_USER_ID)+'   ',6)+alltrim(Oticket->aocode))

    if aoaccess->(dbseek(alltrim(Oticket->brcode)+left(alltrim(g_USER_ID)+'   ',6)+alltrim(Oticket->aocode)))

//       do while !aoaccess->(eof()) .and. ;
  //              alltrim(aoaccess->brcode) == alltrim(Parametr->brcode) .and. ;

  //              alltrim(aoaccess->aocode) == alltrim(G_USER_ID)

    //      if alltrim(aoaccess->aoaccess) == alltrim(caocode)
             lretval := .t.
      //    endif

        //  aoaccess->(dbskip(+1))
       //  enddo
    endif

    aoaccess->(dbgoto(nrec))

return lretval

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function F0500DETAILS()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mFCLTYCODE := OTICKET->FCLTYCODE, mPROCEEDS  := OTICKET->PROCEEDS
   local mTERM      := OTICKET->TERM     , mTRUERATE  := OTICKET->TRUERATE
   local mPAYTYPE   := OTICKET->PAYTYPE  , mGD        := OTICKET->GD
   local mRV        := OTICKET->RV       , mFACTOR    := OTICKET->FACTOR
   local mAMORT     := OTICKET->AMORT    , mCREDAMT   := OTICKET->CREDAMT
   local mAMENDED   := if( OTICKET->AMENDED, 'Y', 'N' )
   local mAMENDREF  := OTICKET->AMENDREF , mRATETYPE  := OTICKET->RATETYPE
   local mUNIT      := OTICKET->UNIT     , mUNIT2     := OTICKET->UNIT2
   local mADDON     := OTICKET->ADDON    , mDLRCODE   := OTICKET->DLRCODE
   local mSALESREP  := OTICKET->SALESREP , mPURCAMT   := OTICKET->PURCAMT
   local mDOWNPAY   := OTICKET->DOWNPAY  , mINCENTIVE := OTICKET->INCENTIVE
   local mNERATE    := OTICKET->NERATE   , mTRANTYPE  := OTICKET->TRANTYPE
   local mNOTFCTN   := OTICKET->NOTFCTN  , mCOLEXION  := OTICKET->COLEXION
   local mRECOURSE  := OTICKET->RECOURSE , mOBLIGOR   := OTICKET->OBLIGOR
   local mCOLATRL   := OTICKET->COLATRL  , mTERMUNIT  := OTICKET->TERMUNIT
   local mFORMULA   := OTICKET->FORMULA  , mPAYFREQ   := OTICKET->PAYFREQ
   local mAppval    := Oticket->Appval   , mAppdate   := Oticket->Appdate
   local mWTAX      := Oticket->WTAX
   return( eval( { | n | CHKFCLTYCODE( @mFCLTYCODE, @mPROCEEDS , @mTERM    ,;
                                       @mTRUERATE , @mPAYTYPE  , @mGD, @mRV,;
                                       @mFACTOR   , @mAMORT    , @mCREDAMT ,;
                                       @mAMENDED  , @mAMENDREF , @mRATETYPE,;
                                       @mUNIT     , @mADDON    , @mDLRCODE ,;
                                       @mSALESREP , @mPURCAMT  , @mDOWNPAY ,;
                                       @mINCENTIVE, @mNERATE   , @mTRANTYPE,;
                                       @mNOTFCTN  , @mCOLEXION , @mRECOURSE,;
                                       @mOBLIGOR  , @mCOLATRL  , @mTERMUNIT,;
                                       'E', .t., @mUNIT2, @mFORMULA, @mPAYFREQ,;
                                       @mAPPVAL, @mAPPDATE,@mWTAX), n } ) )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
// Description  updates OTICKET.dbf
   static function FUPDATE(mwhat,misf3)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   //ÄÄÄÄÄÄÄÄÄÄ declare all memory variables to be used . . .
   local motnumber,motdate ,mactaken,mactdate ,mCLNTCODE ,mAOCODE,mFCLTYCODE ,;
         mproceeds,mpaytype,mterm   ,mtermunit,mtruerate, mratetype, mamort  ,;
         mcredamt ,msurety1,msurety2,msecure1,msecure2 ,mcondition, muser_id ,;
         munit2, mapprover
   local msecheld ,mobtain ,mremarks, mformula, mpayfreq
   local mactchoices  := { '1 = FOR APPROVAL', '2 = AMENDED    ', '3 = APPROVED   ', '4 = DISAPPROVED','5 = CLOSED     ' }
   local mpaychoices  := { '1 = IN ADVANCE','2 = IN ARREARS' }
   local mratechoices := { '1 = FIXED     ','2 = FLOATING  ' }, mrecno := recno()
   local mgd, mrv, mamended, mfactor, mamendref, munit, maddon, mdlrcode, msalesrep
   local mpurcamt, mdownpay, mincentive, mnerate, mtrantype , mnotfctn , mcolexion
   local mrecourse, mobligor, mcolatrl, mRETVAL := .f.
   local mAppval  , mAppdate ,mWTAX , mDOSRI
   local cbrcode := space ( len ( g_PAR_BRCH ) )
   LOCAL tBR := g_PAR_BRCH + '-', cPRVCOL := SETCOLOR()
   local mDOSRICHOICES := { '1 = DIRECTORS', '2 = OFFICERS', '3 = STOCKHOLDERS', '4 = RELATED INTERESTS'}
   local mRELINTERESTS := { '1 = DIRECT', '2 = INDIRECT'}
   
   
   memvar GETLIST

   //alert(mAOCODE)
   // if the user wants to add then
   //    position the file pointer to the bottom of the file
   // else
   //    change the parameter "mwhat" to "R" which will be used later in
   //    NETLOCKing functions ...
   // endif

   if upper(mwhat) == 'A'
      CENTER( 24, 'w+/n','® Add Record ¯') 
      OTICKET->(dbgoto(lastrec()+1))
      motnumber := 'XXXXX'
      tBR := g_PAR_BRCH + '-'
   else
      CENTER( 24, 'w+/n','® Edit Record ¯')    
      mwhat := 'R'
      tBR := OTICKET->BRCODE + '-'
   endif

   misf3 := if ( misf3 == nil, .f., .t. )
	
   eval({|| mOTNUMBER    := if( mWHAT == 'R', OTICKET->OTNUMBER, mOTNUMBER )     ,;
            mOTDATE      := OTICKET->OTDATE   , mACTAKEN    := OTICKET->ACTAKEN  ,;
            mACTDATE     := OTICKET->ACTDATE  , mCLNTCODE   := OTICKET->BRCODE+OTICKET->CLNTCODE ,;
            mAOCODE      := if(!empty(OTICKET->AOCODE),OTICKET->AOCODE,g_USER_ID)   , mFCLTYCODE  := OTICKET->FCLTYCODE,;
            mPROCEEDS    := OTICKET->PROCEEDS , mPAYTYPE    := OTICKET->PAYTYPE  ,;
            mTERM        := OTICKET->TERM     , mTERMUNIT   := OTICKET->TERMUNIT ,;
            mTRUERATE    := OTICKET->TRUERATE , mRATETYPE   := OTICKET->RATETYPE ,;
            mAMORT       := OTICKET->AMORT    , mCREDAMT    := OTICKET->CREDAMT  ,;
            mSURETY1     := OTICKET->SURETY1  , mSURETY2    := OTICKET->SURETY2  ,;
            mSECURE1     := OTICKET->SECURE1  , mSECURE2    := OTICKET->SECURE2  ,;      && RED 092305 mCONDITION   := OTICKET->CONDITION,; mSECHELD     := OTICKET->SECHELD  ,; mOBTAIN      := OTICKET->OBTAIN   ,;
            mGD          := OTICKET->GD       ,;
            mRV          := OTICKET->RV       , mFACTOR     := OTICKET->FACTOR   ,;
            mAMENDED     := if(OTICKET->AMENDED==.t.,'Y','N'),;
            mAMENDREF    := OTICKET->AMENDREF , mUNIT       := OTICKET->UNIT     ,;
            munit2       := OTICKET->UNIT2    , mADDON      := OTICKET->ADDON    ,;
            mDLRCODE     := OTICKET->DLRCODE  , mSALESREP   := OTICKET->SALESREP ,;
            mPURCAMT     := OTICKET->PURCAMT  , mDOWNPAY    := OTICKET->DOWNPAY  ,;
            mINCENTIVE   := OTICKET->INCENTIVE, mNERATE     := OTICKET->NERATE   ,;
            mTRANTYPE    := OTICKET->TRANTYPE , mNOTFCTN    := OTICKET->NOTFCTN  ,;
            mCOLEXION    := OTICKET->COLEXION , mRECOURSE   := OTICKET->RECOURSE ,;
            mOBLIGOR     := OTICKET->OBLIGOR  , mCOLATRL    := OTICKET->COLATRL  ,;  && RED 092305 mREMARKS     := OTICKET->REMARKS  ,;
            mapprover    := OTICKET->APPROVER ,;
            mFORMULA     := OTICKET->formula  , mPAYFREQ    := OTICKET->payfreq  ,;
            mAppval      := Oticket->Appval,;
            creason      := Oticket->disapptype  ,;      // abb
            _reason_desc := Oticket->dreason     ,;      // 11.26.2003
            mAppdate     := Oticket->Appdate     ,;
            cbrcode      := Oticket->brcode      ,;     
			mDOSRI       := Oticket->dosri       ,;     // ERL - 011412
			mWTAX		 := Oticket->WTAX         ;
         } ;
       )

   mUSER_ID := g_USER_ID

   disprec ()

   if upper(mwhat) == 'A'                    // abb 10.12.2004
      @ 6,20 say space(50) color 'gr+/b'
   endif
   setcolor( 'gr+/b, w+/g,,, gr+/b' )

   do while .t.
      @ 04,20 GET tBR        WHEN .F.
      @ 04,20+4 get mOTNUMBER  when .f.
      @ 05,20 get mOTDATE    when lastkey() <> K_ESC .and. !misf3 pict '@D' valid !empty(motdate)
      @ 04,58 get mACTAKEN   pict '@X' ;
                             when if (  lastkey() <> K_PGDN .and. ;
                                        lastkey() <> K_ESC,;
                                        chkACTAKEN( mACTCHOICES, @mACTAKEN,@mapprover,mwhat ),;
                                        .f.  ;
                                     )
      @ 05,58 get mACTDATE   when lastkey() <> K_ESC ;
                             pict '@D' ;
                             valid .t. // !empty(mactdate)
      @ 07,20 get mCLNTCODE  pict '@R 999-99-99999' ;    && RED 11232004 ADDED '999-
                             when lastkey() <> K_ESC .and. ;
                                  if( !misf3,;
                                      chkclntcode( @cbrcode,@mclntcode ), .f. ) ;
                                  valid !empty( mclntcode  )
      @ 08,20 get mAOCODE    pict '@X' when lastkey() <> K_ESC .and. if( !misf3, CHKAOCODE( @mAOCODE ), .f. )
	  @ 09,63 get mDOSRI    pict '@X' when lastkey() <> K_ESC .and. if(!misf3 ,if(if(yes_no2( 'DOSRI?',, ' Yes ', ' No ', .f.,'w+/rb','w+/rb' ),;
										chkDOSRI( mDOSRICHOICES,@mDOSRI,mRELINTERESTS,9,58 ), noDOSRI(@mDOSRI,9,58)) == 'YES',.f.,.f.) , .f. )
		
      @ 10,20 get mFCLTYCODE pict '@R 999-99' when lastkey() <> K_ESC .and. if( !misf3, CHKFCLTYCODE( @mFCLTYCODE, @mPROCEEDS, @mTERM , @mTRUERATE,;
                                                                              @mPAYTYPE  , @mGD, @mRV, @mFACTOR   , @mAMORT   ,;
                                                                              @mCREDAMT  , @mAMENDED , @mAMENDREF , @mRATETYPE,;
                                                                              @mUNIT     , @mADDON   , @mDLRCODE  , @mSALESREP,;
                                                                              @mPURCAMT  , @mDOWNPAY , @mINCENTIVE, @mNERATE  ,;
                                                                              @mTRANTYPE , @mNOTFCTN , @mCOLEXION , @mRECOURSE,;
                                                                              @mOBLIGOR  , @mCOLATRL , @mTERMUNIT , mWHAT, .f.,;
                                                                              @munit2    , @mFORMULA , @mPAYFREQ  , @mAPPVAL  ,;
																			  @mAPPDATE  , @mWTAX    ), .f. )
      @ 12,20 get mPROCEEDS  pict '999,999,999.99' when .f. valid !empty ( mPROCEEDS )
      @ 13,20 get mTERM      pict '999'     when .f.
      @ 14,20 get mTRUERATE  pict '99.9999' when lastkey() <> K_ESC .and. if( !misf3, eval({|| chkratetype( mRATECHOICES, @mRATETYPE, 14 ), .f. }),.f. )
      @ 15,20 get mSURETY1   when lastkey() <> K_ESC .and. !misf3 pict '@!'
      @ 16,20 get mSURETY2   when lastkey() <> K_ESC .and. !misf3 pict '@!'
      @ 17,20 get mSECURE1   when lastkey() <> K_ESC .and. !misf3 pict '@!'
      @ 18,20 get mSECURE2   when lastkey() <> K_ESC .and. !misf3 pict '@!'
      @ 19,20 say '< Memo >'
      @ 20,20 say '< Memo >'
      @ 21,20 say '< Memo >'

      setcursor ( 3 )
      read
      setcursor ( 0 )

      *--->                   && RED 092305
      mSECHELD := COLLMEM( 'OT_SEC', mOTNUMBER, cBRCODE )
      mOBTAIN  := COLLMEM( 'OT_OBT', mOTNUMBER, cBRCODE )
      mREMARKS := COLLMEM( 'OT_REM', mOTNUMBER, cBRCODE )
      *--->

      if lastkey() != K_ESC .and. !misf3

         if Facility->Setcode == '3'
            updte_mem3( @msecheld, @mobtain, @mremarks, 19, 20, 20, 20, .f. )
         else
            update_memo( @msecheld, @mobtain, @mremarks, 19, 20, 20, 20, .f. )
         endif
      endif

      if lastkey() == K_ESC
         if esckey()
            exit
         else
            loop
         endif
      endif

      if CONFIRM ( 'All entries correct?' )
 
         if OTICKET->( NETLOCK ( mwhat, 0 ) )

            if upper ( mwhat ) == 'A'

               Oticket->brcode := cbrcode     // abb 10.12.2004

// EVR         if Parametr->( NETLOCK( 'R', 0 ) )
// EVR            _field->Parametr->lastotno := motnumber := right( '0000'+ ltrim( str( val( Parametr->lastotno ) + 1 ) ), 5 )
// EVR            Parametr->( dbcommit() )                  
// EVR         endif   
// EVR         Parametr->( dbunlock() )
               if Ol_param->(dbseek(g_PAR_BRCH))
                  if Ol_param->(netlock('R', 0))
                     Ol_param->LASTOTNO := motnumber := right('0000'+ltrim(str(val(Ol_param->LASTOTNO)+1)),5)
                     Ol_param->(dbunlock())
                  endif
                  Ol_param->(dbcommit())
               endif

// EVR         UPDT_OL()            && RED 033005
            endif

            *--->                   && RED 092305
            SAVEMEM( mSECHELD, 'OT_SEC', mOTNUMBER, cBRCODE )
            SAVEMEM( mOBTAIN, 'OT_OBT', mOTNUMBER, cBRCODE )
            SAVEMEM( mREMARKS, 'OT_REM', mOTNUMBER, cBRCODE )
            *--->
            eval ({|| OTICKET->OTNUMBER    :=  mOTNUMBER , OTICKET->OTDATE      :=  mOTDATE                   ,;
                      OTICKET->ACTAKEN     :=  mACTAKEN  , OTICKET->ACTDATE     :=  mACTDATE                  ,;
                      OTICKET->CLNTCODE    :=  RIGHT(mCLNTCODE,7) , OTICKET->AOCODE      :=  mAOCODE                   ,;
                      OTICKET->FCLTYCODE   :=  mFCLTYCODE, OTICKET->PROCEEDS    :=  mPROCEEDS                 ,;
                      OTICKET->PAYTYPE     :=  mPAYTYPE  , OTICKET->TERM        :=  mTERM                     ,;
                      OTICKET->TERMUNIT    :=  mTERMUNIT , OTICKET->TRUERATE    :=  mTRUERATE                 ,;
                      OTICKET->RATETYPE    :=  mRATETYPE , OTICKET->AMORT       :=  mAMORT                    ,;
                      OTICKET->CREDAMT     :=  mCREDAMT  , OTICKET->SURETY1     :=  mSURETY1                  ,;
                      OTICKET->SURETY2     :=  mSURETY2  , OTICKET->SECURE1     :=  mSECURE1                  ,;
                      OTICKET->SECURE2     :=  mSECURE2  ,;        && RED 092805 OTICKET->CONDITION   :=  mCONDITION                ,;
                      OTICKET->USER_ID     :=  mUSER_ID  ,;        && RED 092305 OTICKET->SECHELD     :=  mSECHELD                  ,; OTICKET->OBTAIN      :=  mOBTAIN   ,
                      OTICKET->GD          :=  mGD                       ,;
                      OTICKET->RV          :=  mRV       , OTICKET->FACTOR      :=  mFACTOR                   ,;
                      OTICKET->AMENDED     :=  if(mAMENDED=='Y',.t.,.f.) ,;
                      OTICKET->AMENDREF    :=  mAMENDREF , OTICKET->UNIT        :=  mUNIT                     ,;
                      OTICKET->UNIT2       :=  munit2    , OTICKET->ADDON       :=  mADDON                    ,;
                      OTICKET->DLRCODE     :=  mDLRCODE  , OTICKET->SALESREP    :=  mSALESREP                 ,;
                      OTICKET->PURCAMT     :=  mPURCAMT  , OTICKET->DOWNPAY     :=  mDOWNPAY                  ,;
                      OTICKET->INCENTIVE   :=  mINCENTIVE, OTICKET->NERATE      :=  mNERATE                   ,;
                      OTICKET->TRANTYPE    :=  mTRANTYPE , OTICKET->NOTFCTN     :=  mNOTFCTN                  ,;
                      OTICKET->COLEXION    :=  mCOLEXION , OTICKET->RECOURSE    :=  mRECOURSE                 ,;
                      OTICKET->OBLIGOR     :=  mOBLIGOR  , OTICKET->COLATRL     :=  mCOLATRL                  ,;     && RED 092305   OTICKET->REMARKS     :=  mREMARKS  ,
                      OTICKET->APPROVER    :=  mapprover                 ,;
                      OTICKET->DATE_APROV  :=  mtrandate , OTICKET->TIME        :=  time()                    ,;
                      OTICKET->FORMULA     :=  mFORMULA  , OTICKET->PAYFREQ     :=  mPAYFREQ                  ,;
                      Oticket->Appval      :=  mAppval      ,;
                      Oticket->disapptype  :=  creason      ,;
                      Oticket->dreason     := _reason_desc  ,;
                      Oticket->Appdate     :=  mAppdate     ,;
					  if(!misf3,Oticket->dosri :=  mDOSRI ,),;//if(mDOSRI == 'YES',.t.,.f.) ,;
					  Oticket->WTAX        :=  mWTAX         ;
                 } )

               OTICKET->( dbunlock() )
               OTICKET->( dbcommit() )

               if mwhat == 'A'
                  drop  ( alltrim(g_user_id)+' '+'Adds OTicket No. '+Oticket->otnumber )
               else
                  drop  ( alltrim(g_user_id)+' '+'Edits OTicket No. '+Oticket->otnumber )
               endif

               mRETVAL := .t.
         endif
         mrecno := OTICKET->( recno() )
         exit
      endif
   enddo

   SETCOLOR(cPRVCOL)

   OTICKET->( dbgoto ( mrecno ) )
   CENTER( 24, 'w+/n', space( 15 ) )
   return mRETVAL

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
// Description  returns the ratetype description
   static function chkratetype( mratechoices, mratetype, mROW )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   @ mROW,28 say if( mratetype == '1', 'FIXED   ', 'FLOATING' )
   return .f.

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
// Description  select payment type
   static function chkpayment(mpaychoices,mpaytype,mROW)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   mpaytype := gen_achoice( mpaychoices, val( mpaytype ), 'Payment', 13, 24, 16, 45, 'W/GR+,W/N,,,W/GR+' )
   @ mROW, 24+6 say if( mPAYTYPE == '1', 'IN ADVANCE', 'IN ARREARS' )
   return .f.

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
// Description  select ACTION TAKEN
   static function chkactaken(mactchoices,mactaken,mapprover,mwhat)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
local old_taken := mactaken
local cscr := savescreen (,,,)
local getlist   := {}
local _disappchoices := space(37) + ;
                      'Financials                           '+;
                      'Credit/Findings in Company/Principals'+;
                      'Industry Outlook                     '+;
                      'Others, specify                      '
local _adisapproved  := { '1 = Financials' ,;
                          '2 = Credit Findings in Company/Principals' ,;
                          '3 = Industry Outlook',;
                          '4 = Others, specify'  ;
                        }

   do while .t.
      mactaken := gen_achoice( mactchoices, val( mactaken ), 'Action Taken', 05, 58, 10, 78, 'W/GR+,W/N,,,W/GR+' )
      @ 04,60 say upper( dispactaken( mactaken ) )  // displays ACTION TAKEN

      if mactaken == '4'                     // Disapproved 3.18.2003
         @ 10,10 clear to 13,65
         @ 10,10 to 13,65
         creason := gen_achoice( _adisapproved, val( creason ), 'Disapproved', 06, 57, 11, 77, 'w/gr+,w/n,,,w/gr+' )

         @ 11,11 say 'Reason ? : ' get creason     ;
                                   pict '@!S40'    ;
                                   valid creason $ '1234' ;
                                   when .f.

         do case
            case creason == '1'
                 _reason_desc := '1 = Financials         '
            case creason == '2'
                 _reason_desc := '2 = Credit Findings in Company/Principals'
            case creason == '3'
                 _reason_desc := '3 = Industry Outlook'
            otherwise
                 if empty(Oticket->dreason)
                    _reason_desc := space(len(_reason_desc))
                 else
                    _reason_desc := _reason_desc
                 endif
         endcase

         @ 12,11 say 'Others   : ' get  _reason_desc    ;
                                   when creason == '4'  ;
                                   pict '@!'            ;
                                   valid !empty(_reason_desc)

         setcursor(3)
         read

         restscreen(,,,,cscr)
         @ 04, 60 say upper( dispactaken( mactaken ) )
         if lastkey() != K_ESC
            alert ( _reason_desc )
         endif

      endif

//       if mwhat <> 'A' .and. old_taken <> mactaken .and. lastkey() != K_ESC   // if ACTION TAKEN is APPROVED
      if mwhat <> 'A' .and. old_taken <> mactaken .and. lastkey() != K_ESC   // if ACTION TAKEN is APPROVED
         if actvalidate( mactaken, @mapprover )      // get APPROVER & PASSWORD
            exit
         endif
      elseif lastkey() == K_ESC
         mactaken := old_taken
         exit
      else
         /*
         if mactaken == '3'
            __keyboard( chr( 27 ) )
         endif
         */
         exit
      endif
   enddo

return .f.

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
// Description  gets APPROVER ID and PASSWORD
   function actvalidate( mactaken,mapprover )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mRETVAL   := .f. , GETLIST := {}          ,;
         muser_id  := mapprover                    ,;
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

      if Approver -> ( look_approver ( muser_id ) )  // search if approver id
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
   function look_approver( muserid )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mf := .f.
   Approver -> ( dbgotop() )
   Approver -> ( dbeval ( {|| if ( Approver->APPROVER == muserid,;
                                   mf := .t.,;
                                   nil ;
                                 );
                          },,;
                          {|| !Approver->(eof()) .and. !mf }))

return mf

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
// Description  gets approver's password
   function getpassword( mpassword )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mctr := 0, mc := 60
   
   CENTER ( 24, 'w+/n', '® Enter Password ¯' )
   setcursor ( 1 )
   @ 9, mc say ''
   while inkey ( 0 ) != K_ESC
      if lastkey() != K_ESC .and. lastkey() != K_ENTER
                                         // do not display the characters
                                         // being keyed-in else
         @ 9,mc say 'ş' color ( 'w+/n' )  // display character "ş"
         setpos( 9, col() - 1 )         
         mc++                            // increment the column counter

         if ++mctr <= 20                 // if total characters pressed was
                                         // less than or equal to 20 then ...

            mpassword += upper ( chr ( lastkey() ) ) // append it to the
                                                    // password string
            if mc > 69                    // if column is greater than 69 ...
               mc := 69
            endif
         else
            tone ( 50,1 )
            mc := 69
         endif
         mpchar := 'ş'
      else
         exit
      endif
   enddo
   setcursor ( 3 )
   CENTER ( 24,NRM,'                      ' )
   return lastkey() != K_ESC

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
// Description  lets the user select the FACILITY if the last key pressed
//               was not equal to F3, but in the event that his last key 
//               typed was F3 then this function will just assign the 
//               values from OTICKET and display the values gathered...

   function CHKFCLTYCODE( mFCLTYCODE, mPROCEEDS, mTERM     , mTRUERATE   ,;
                          mPAYTYPE  , mGD, mRV , mFACTOR   , mAMORT      ,;
                          mCREDAMT  , mAMENDED , mAMENDREF , mRATETYPE   ,;
                          mUNIT     , mADDON   , mDLRCODE  , mSALESREP   ,;
                          mPURCAMT  , mDOWNPAY , mINCENTIVE, mNERATE     ,;
                          mTRANTYPE , mNOTFCTN , mCOLEXION , mRECOURSE   ,;
                          mOBLIGOR  , mCOLATRL , mTERMUNIT , mWHAT, mISF3,;
                          munit2, mFORMULA, mPAYFREQ, mAPPVAL,mAPPDATE   ,;
						  mWTAX     )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mRETVAL := .f., mcolor := setcolor()
   private xmcro := 'gget'
   if empty ( mFCLTYCODE ) .and. mWHAT == 'E'
      return .f.
   endif
   if !mISF3
      lb_lkup('FACILITY', 1, 1,@mFCLTYCODE, 3, 1, 11, 02+16, 19, 50+16, 'W/GR+,W/N,,,W/GR+')
   else
      xmcro:='get'
   endif
   @ 10, 20 say mFCLTYCODE pict '@R 999-99' color 'gr+/b'
   @ 10, 27 say DISPALIAS(mFCLTYCODE,,'N')       color 'gr+/b'
   if lastkey() != K_ESC
      do case
         case FACILITY->SETCODE == '1'
            mTERMUNIT := '2'
            SET_CODE_ONE   ( mWHAT      , @mPROCEEDS, @mTERM    , @mTRUERATE, mFCLTYCODE ,;
                             @mPAYTYPE  , @mGD, @mRV, @mFACTOR  , @mAMORT   , @mCREDAMT  ,;
                             @mAMENDED  , @mAMENDREF, @mRATETYPE, @mUNIT    , mISF3      ,;
                             @mTERMUNIT , @munit2;
                            )
         case FACILITY->SETCODE == '2'
            mTERMUNIT := '2'         
            SET_CODE_TWO   ( mWHAT      , @mPROCEEDS, @mTERM    , @mTRUERATE, mFCLTYCODE ,;
                             @mPAYTYPE  , @mGD, @mRV, @mFACTOR  , @mAMORT   , @mCREDAMT  ,;
                             @mAMENDED  , @mAMENDREF, @mRATETYPE, @mUNIT    , @mADDON    ,;
                             mISF3      , @mTERMUNIT, @munit2   , @mINCENTIVE,@mWTAX     ,;
						     @mNERATE                                                      ;
                            )
         case FACILITY->SETCODE == '3'
            mTERMUNIT := '2'         
            SET_CODE_3     ( mWHAT      , @mPROCEEDS, @mTERM    , @mTRUERATE , mFCLTYCODE,;
                             @mPAYTYPE  , @mGD, @mRV, @mFACTOR  , @mAMORT    , @mCREDAMT ,;
                             @mAMENDED  , @mAMENDREF, @mRATETYPE, @mUNIT     , @mDLRCODE ,;
                             @mSALESREP , @mPURCAMT , @mDOWNPAY , @mINCENTIVE, @mNERATE  ,;
                             mISF3      , @mTERMUNIT, @munit2   , @mappval   , @mappdate ,;
							 @mWTAX      ;
                           )
         case FACILITY->SETCODE == '4' .or. FACILITY->SETCODE == '5'
            SET_CODE_5     ( mWHAT      , @mPROCEEDS, @mTERM    , @mTRUERATE , mFCLTYCODE,;
                             @mPAYTYPE  , @mGD, @mRV, @mFACTOR  , @mAMORT    , @mCREDAMT ,;
                             @mAMENDED  , @mAMENDREF, @mRATETYPE, @mUNIT     , @mDLRCODE ,;
                             @mSALESREP , @mPURCAMT , @mDOWNPAY , @mINCENTIVE, @mNERATE  ,;
                             @mTRANTYPE , @mNOTFCTN , @mCOLEXION, @mRECOURSE , @mOBLIGOR ,;
                             @mCOLATRL  , @mTERMUNIT, mISF3     , @munit2, @mFORMULA, @mPAYFREQ ;
                           )
      endcase
   endif
   if !misf3
      setcursor (3)
   endif
   setcolor( mcolor )
   return mRETVAL

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
// Description  selection of client code using the lb_lkup function
//               which is in myluk.prg file ...
**************************************************
*
static function chkclntcode( cbrcode,mCLNTCODE )
**************************************************
local cINFO :=  space(1)

   __lb_lkup ( 'Client',1,2,@mclntcode,03,45,01,08,12-7,21,75, 'w/gr+,w/n,,,w/gr+',,,,,cbrcode, ) && RED 112304 REMOVED ''CODE'

   mCLNTCODE := cBRCODE+mCLNTCODE
   cbrcode := alltrim(Client->brcode)           // abb 10.13.2004

   *@ 07,29 say _dispclntname( cbrcode,mCLNTCODE )  // display the client name
   @ 07,29 say DISPCLNTNAME( cBRCODE+mCLNTCODE, 40 )

   if cbrcode != g_PAR_BRCH
      error ( 'Cannot add/edit client for branch '+cbrcode )
      __keyboard( chr( 27 ) )
   else
        if CLIENT->(dbseek(cbrcode+subs(mCLNTCODE,4,7)))
		   if CLIENT->CLTYPE == '2'		                                 //CONSUMER  pepe 2:21 PM 08.05.2008 
				if !SIGNERS->(DBSEEK(cbrcode+subs(mCLNTCODE,4,7))) 
				    cINFO := 'SIGNEE'
			    else
				   if EMPTY(SIGNERS->SIGNER)
				      cINFO := 'SIGNEE'
				   endif
				endif
				if !Indvcntc->(DBSEEK(cbrcode+subs(mCLNTCODE,4,7)))
				    cINFO := if (!empty(cINFO),cINFO+';CONTACT PERSON','CONTACT PERSON')
			    else
				   if EMPTY(Indvcntc->CONTACT)
				      cINFO := if (!empty(cINFO),cINFO+';CONTACT PERSON','CONTACT PERSON')
				   endif
				endif
				if !Indvinfo->(DBSEEK(cbrcode+subs(mCLNTCODE,4,7)))
					cINFO := if (!empty(cINFO),cINFO+';PERSONAL INFORMATION','PERSONAL INFORMATION')
			    else
				   if EMPTY(Indvinfo->NATION)
				      cINFO := if (!empty(cINFO),cINFO+';PERSONAL INFORMATION','PERSONAL INFORMATION') 
				   endif
				endif

				IF !EMPTY(cINFO)
				   alert('Cannont add/edit client without completing the following information:;;'+cINFO)
				   __keyboard( chr( 27 ) )
				ENDIF
		   endif
	    endif
   endif

return .f.

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
// Description  selection of surety...
   static function chksurety( msurety )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   lb_lkup('CLIENT',1,2,@msurety, 3 , 1, 10, 18, 21, 75, 'w/gr+,w/n,,,w/gr+')
   *@ 16, 30 say _dispclntname( g_PAR_BRCH, g_PAR_BRCH+msurety )
   @ 16, 30 say DISPCLNTNAME( g_PAR_BRCH+mSURETY,40 )
   return .f.

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
// Description  select the AO using the lb_lkup function...
   static function CHKAOCODE(mAOCODE)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   lb_lkup( (xTEMP),1,1,@mAOCODE,2,1,09,16,21,75, 'w/gr+,w/n,,,w/gr+' )     // EVR 27112006
   @ 08, 26 say DISPAONAME( mAOCODE )   // displays Account Officer's name
   return .f.

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
// Description  updates the parameter file - LASTOTNO field 
//               which is the last OFFERING TICKET number used
//   static function UPDATE_PARAMETR()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
/* EVR 27122006 - no use
   local mdbf := savedbf ( mdbf )
   dbselectarea( "Parametr" )
   if Parametr->( NETLOCK ( 'R', 0 ) )
      Parametr->LASTOTNO  := OTICKET->OTNUMBER
      Parametr->( dbunlock() ) ; Parametr->( dbcommit() )
   endif
   restdbf ( mdbf )

   UPDT_OL()            && RED 033005

return nil
*/

************************************
*
*
static function FSEARCH(cbrcode)
************************************
   local mRECNO := OTICKET->( recno() )
   local mntx   := OTICKET->( indexord() )
   local mSCR   := savescreen ( ,,, ), mcolor := setcolor()
   local mCLNTCODE := space( len(OTICKET->BRCODE+OTICKET->CLNTCODE) )
   local mar, mposition := 1, mlog := {}, mRETVAL := .f.
   local nrecno := 0
   local cfullname := space ( len( Client->fullname ) )
   LOCAL cKEY
   memvar GETLIST

   &&nrecno := _getClwin ( mclntcode,2,Client->(indexord()) )            // abb 10.18.2004 )   // client code + indexord
   nRECNO := _GETCLWIN ( mCLNTCODE,1,CLIENT->(INDEXORD()) )



   IF nRECNO = 0 .AND. LASTKEY() == K_ENTER

      center     ( 24,'w+/n', '® Search Record ¯' )
      __lb_lkup  ( 'CLIENT',1,2,@mCLNTCODE,03,45,01,08,12-7,21,75,'W/GR+,W/N,,,W/GR+','@XS40','999','@R 99-99999',,cbrcode,'NAME',cfullname,' Client name','Branch', )  && RED 112304 REMOVED ''Code'
      center     ( 24, 'w+/n', '                 ' )

      IF LASTKEY() == K_ENTER
         nRECNO := CLIENT->(RECNO())

      ENDIF
   ENDIF


   if lastkey() != K_ESC         &&.and. nrecno > 0

//       Client->  ( dbsetorder( 1 ) )       // clntname + brcode
      Client->  ( dbgoto(nrecno) )

      mclntcode := CLIENT->BRCODE+Client->clntcode
      cfullname := alltrim(Client->fullname)

      *center     ( 24,'w+/n', '® Search Record ¯' )
      *__lb_lkup  ( 'CLIENT',1,2,@mCLNTCODE,03,45,01,08,12-7,21,75,'W/GR+,W/N,,,W/GR+','@XS40','999','@R 99-99999',,cbrcode,'NAME',cfullname,' Client name','Branch','Code' )
      *center     ( 24, 'w+/n', '                 ' )

   if lastkey() == K_ENTER .and. nrecno > 0 .AND. VALBRCODE( CLIENT->BRCODE, g_USER_ID )
      OTICKET->(dbsetorder(2))

//      if OTICKET->( dbseek(mCLNTCODE) )

      if OTICKET->( dbseek ( mclntcode) )    && RED 112304 REMOVED 'alltrim(Client->brcode)+

         mar := { '  Client N§  ' + tran( mCLNTCODE, '@R 999-99-99999' )    ,;
                  'Client Name  ' + left( dispclntname( mCLNTCODE, 40 ),15 ),;     && RED 112504 REMOVED 'Oticket->brcode, CHANGED _DISPCLNTNAME TO DISPCLNTNAME
                   repl( 'Ä', 43 ), ' Branch Name   OT N§       Action Taken', repl( 'Ä',43 ) ;
                }

         OTICKET->( dbeval( {|| aadd( mar,Oticket->brcode+;
                                ' '+;
                                padr(_get_branch(Oticket->brcode),8)+;  && RED 112304 REPLACED 10 WITH 8
                                ' '+;
                                OTICKET->BRCODE+'-'+;
                                OTICKET->OTNUMBER+;
                                space(5)+;      && RED 112304 REPLACED 7 WITH 5
                                alltrim(upper(dispactaken(OTICKET->ACTAKEN))) ) },,;
                            {|| OTICKET->BRCODE+OTICKET->CLNTCODE == mCLNTCODE .AND. ;
                                !OTICKET->(eof()) }) )

         if len(mar) > 1
            mlog := aclone( mar )         
            aeval ( mlog, { | l, c | mlog[ c ] := if( c <= 5, .f., .t. ), c } )
            mposition := val( gen_achoice( mar, 6, 'Search', mlog ) )
         endif

         if mposition > 0 .and. lastkey() != K_ESC
            cKEY := substr( ltrim(mar[mposition]),14,3)+substr( ltrim(mar[mposition]),18,5)

            Oticket->(dbsetorder(1))  // BRCODE + OTNUMBER

            if Oticket-> ( dbseek (cKEY) )   && RED 112304 REMOVED 'alltrim(Client->brcode)+;

//
//                                    left(ltrim(mar[mposition]),5) ) )
//
                mrecno  := Oticket->(recno())
                mretval := .t.

            endif

         endif

      else
         ERROR ( 'No existing OT on file!' )
      endif

   endif

   endif

   setcolor   ( mcolor )
   restscreen ( ,,,, mSCR )
   OTICKET->  ( dbsetorder ( mntx ) )
   OTICKET->  ( dbgoto ( mRECNO ) )

return mRETVAL

****************************************************
*
static function _getClwin ( mclntcode,nneword,noldntx)           // abb 10.18.2004
****************************************************
   local nntx := Client->(indexord()),ccursor := setcursor()
   local cclntname := space(len(Client->fullname))
   local nretval   := 0
   LOCAL nCLNTCODE := SPACE(10)

   Client->(dbsetorder(nneword))
   cscr := savescreen ( ,,, )

   @ 10,10 clear to 12,52
   @ 10,10 to 12,52
   *@ 11,12 say 'Client Name  ' get cclntname pict '@!S20'
   @ 11,16 say 'Client Code  '
   @ 11,30 GET nCLNTCODE pict '@R 999-99-99999' VALID ( EMPTY(nCLNTCODE) .OR. IF(VALBRCODE( LEFT( nCLNTCODE, 3), g_USER_ID),.T.,EVAL({ || nCLNTCODE := SPACE(10),.F.}) ) )

   setcursor(3)
   read
   setcursor(0)

   restscreen ( ,,,,cscr )

   if lastkey() != K_ESC

      IF EMPTY(nCLNTCODE)
         nRETVAL := 0
      ELSE
         *if Client->(dbseek(alltrim(cclntname)))
         IF CLIENT->(DBSEEK(ALLTRIM(nCLNTCODE)))
            nretval := Client->(recno())
         else
            error ( 'Client not found' )
         endif
      ENDIF

   endif

   Client->  ( dbsetorder(noldntx) )
   setcursor ( ccursor)

return nretval

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function FDELETE()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mRECNO := OTICKET-> ( recno() ), mRETVAL := .f.
   if CONFIRM( 'Delete Ticket N§ '+TRAN(OTICKET->BRCODE+OTICKET->OTNUMBER,'@R 999-99999')+'?' )
      if NETLOCK('R',0)
         drop  ( alltrim(g_user_id)+' '+'Deletes OTicket No. '+TRAN(OTICKET->BRCODE+Oticket->otnumber,'@R 999-99999') )
         OTICKET->( dbdelete() )
         mRETVAL := .t.
      endif
      OTICKET-> ( dbunlock()  )
      OTICKET-> ( dbskip ( +1 ) )
      if OTICKET-> ( eof() )
         OTICKET-> ( dbgobottom() )
      endif
      mRECNO := OTICKET-> ( recno() )
   endif
   OTICKET->( dbgoto ( mRECNO ) )
   return mRETVAL
/*
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function DISPALIAS(mFCLTYCODE)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   FACILITY->( dbseek ( mFCLTYCODE ) )
   return FACILITY->FCLTYNAME
*/
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function DISPREC()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   return( eval( { | n | dispbegin()                                                                        ,;
                      DevPos( 04, 20 )          , DevOutPict( OTICKET->BRCODE+OTICKET->OTNUMBER, '@R 999-99999', 'w+/b' )                       ,;   &&RED 112304 DevOut( OTICKET->OTNUMBER, 'w+/b' )                       ,;
                      DevPos( 05, 20 )          , DevOut( OTICKET->OTDATE, 'w+/b' )                         ,;
                      DevPos( 04, 58 )          , Devout( OTICKET->ACTAKEN, 'w+/b' )                        ,;
                      DevPos( 04, col() + 1 )   , DevOut( upper( DISPACTAKEN( OTICKET->ACTAKEN ) ), 'w+/b' ),;
                      DevPos( 05, 58 )          , DevOut( OTICKET->ACTDATE, 'w+/b' )                        ,;
                      DevPos( 06, 20 )          , DevOutPict( OTICKET->brcode + ' ' + padr( _get_branch(Oticket->brcode),40), "@!", 'w+/b' )    ,;
                      DevPos( 07, 20 )          , DevOutPict( OTICKET->BRCODE+OTICKET->CLNTCODE, "@R 999-99-99999", 'w+/b' )    ,;
                      DevPos( 07, col() + 1 )   , DevOut( DISPCLNTNAME( OTICKET->BRCODE+OTICKET->CLNTCODE, 40  ), 'w+/b' )      ,;     && RED 112504 REMOVED 'Oticket->brcode, CHANGED _DISPCLNTNAME WITH DISPCLNTNAME
                      DevPos( 08, 20 )          , DevOut( OTICKET->AOCODE, 'w+/b' )                         ,;
                      DevPos( 08, col() + 1 )   , DevOut( DISPAONAME( OTICKET->AOCODE    ), 'w+/b' )        ,;
					  DevPos( 09, 58 )          , DevOut( if(OTICKET->DOSRI != 'NO ','YES '+'['+OTICKET->DOSRI+']' ,'NO           '), 'w+/b' )  			,;
                      DevPos( 10, 20 )          , DevOutPict( OTICKET->FCLTYCODE, "@R 999-99", 'w+/b' )     ,;
                      DevPos( 10, col() + 1 )   , DevOut( DISPALIAS( OTICKET->FCLTYCODE,, 'N' ), 'w+/b' )      ,;
                      DevPos( 12, 20 )          , DevOutPict( OTICKET->PROCEEDS, "999,999,999.99",'w+/b')  ,;
                      DevPos( 13, 20 )          , DevOutPict( OTICKET->TERM, "999", 'w+/b' )                ,;
                      DevPos( 13, col() + 1 )   , DevOut( if(OTICKET->TERMUNIT=='1',"DAY(s)  ",if( OTICKET->TERMUNIT=='2',"MONTH(s)", space( 8 ) ) ), 'w+/b' ),;
                      DevPos( 14, 20 )          , DevOutPict( OTICKET->TRUERATE, "99.9999", 'w+/b' )        ,;
                      DevPos( 14, col() + 1 )   , DevOut( if( ( OTICKET->FCLTYCODE<='10401' .or. OTICKET->FCLTYCODE='10407' ),if( OTICKET->RATETYPE == "1","FIXED     ","FLOATING  "),if( OTICKET->RATETYPE == "1","NEGOTIABLE","FIXED     ")),'w+/b'),;
                      DevPos( 15, 20 )          , DevOut( OTICKET->SURETY1 , 'w+/b' )                       ,;
                      DevPos( 16, 20 )          , DevOut( OTICKET->SURETY2 , 'w+/b' )                       ,;
                      DevPos( 17, 20 )          , DevOut( OTICKET->SECURE1, 'w+/b' )                        ,;
                      DevPos( 18, 20 )          , DevOut( OTICKET->SECURE2, 'w+/b' )                        ,;
                      DevPos( 19, 20 )          , DevOut( "< Memo >"        , 'w+/b' )                      ,;
                      DevPos( 20, 20 )          , DevOut( "< Memo >"        , 'w+/b' )                      ,;
                      DevPos( 21, 20 )          , DevOut( "< Memo >"        , 'w+/b' )                      ,;
                      dispend(), n } ) )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function DISPHEAD()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   return( eval( { | n | dispbegin()                                                                                                                ,;
                      devpos(      04, 02 ) , devout( "          OT N§                         Action Taken                      ", 'w/b' ),;
                      devpos( row()+1, 02 ) , devout( "        OT Date                          Action Date                      ", 'w/b' ),;
                      devpos( row()+1, 02 ) , devout( "         Branch                                                           ", 'w/b' )  ,;
                      devpos( row()+1, 02 ) , devout( "      Client N§                                                           ", 'w/b' )  ,;
                      devpos( row()+1, 02 ) , devout( "             AO                                                           ", 'w/b' )  ,;
					  devpos( row()+1, 02 ) , devout( "                                               DOSRI                      ", 'w/b' )  ,;
                      devpos( row()+1, 02 ) , devout( "Credit Facility                                                           ", 'w/b' )  ,;
                      devpos( row()+2, 02 ) , devout( "   Net Proceeds                                                           ", 'w/b' )  ,;
                      devpos( row()+1, 02 ) , devout( "           Term                                                           ", 'w/b' )  ,;
                      devpos( row()+1, 02 ) , devout( "      True Rate                                                           ", 'w/b' )  ,;
                      devpos( row()+1, 02 ) , devout( "         Surety                                                           ", 'w/b' )  ,;
                      devpos( row()+1, 02 ) , devout( "                                                                          ", 'w/b' )  ,;
                      devpos( row()+1, 02 ) , devout( "       Security                                                           ", 'w/b' )  ,;
                      devpos( row()+1, 02 ) , devout( "                                                                          ", 'w/b' )  ,;
                      devpos( row()+1, 02 ) , devout( "  Security Held  < Memo >                                                 ", 'w/b' )  ,;
                      devpos( row()+1, 02 ) , devout( " To be Obtained  < Memo >                                                 ", 'w/b' )  ,;
                      devpos( row()+1, 02 ) , devout( "        Remarks  < Memo >                                                 ", 'w/b' )  ,;
                      dispend(), n } ) )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function COMPUTE(mPROCEEDS, mPAYTYPE, mTRUERATE, mTERM, mAMORT, mCREDAMT)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mRATEMTH, mDOWN, mUP ,mADDON
   mRATEMTH := ( mTRUERATE/100 ) /12
   if mPAYTYPE == '1' 
      mUP := mRATEMTH * (( 1 + mRATEMTH ) ** ( mTERM -1 ))
   else
      mUP := mRATEMTH * (( 1 + mRATEMTH ) ** ( mTERM ))
   endif   
   mDOWN    := (( 1 + mRATEMTH ) ** mTERM ) - 1
   mAMORT   := round ( mPROCEEDS * ( mUP/mDOWN ), 2 )
   mAMORT   := INTROUND ( mAMORT )
   mCREDAMT := mAMORT * mTERM
   return .f.

//------------------------------------------------------------------------------------------------
Static function updte_mem3( mSECHELD, mOBTAIN, mREMARKS, mROW1, mROW2, mCOL1, mCOL2, mISCA, xrow )
//------------------------------------------------------------------------------------------------
   if ( misca == nil , misca := .t., misca )
   eval({|| devpos( mROW1, mCOL1 ),devout( "< Memo >", 'gr+/b' ),memo0300m ( @mSECHELD , "S",misca,, xrow ),;
            devpos( mROW1, mCOL1 ),devout( "< Memo >", 'gr+/b' )                                           ,;
            devpos( mROW2, mCOL2 ),devout( "< Memo >", 'gr+/b' ),memo0300m ( @mOBTAIN  , "O",misca,, xrow ),;
            devpos( mROW2, mCOL2 ),devout( "< Memo >", 'gr+/b' ) } )
   if mremarks != Nil
      devpos ( mrow2+1, mcol2 ) ; devout( "< Memo >", 'gr+/b' )
      memo0300m ( @mremarks , "R", misca,, xrow )
      devpos ( mrow2+1, mcol2 ) ; devout( "< Memo >", 'gr+/b' )
   endif

return nil

//--------------------------------------------------------------
Function memo0300m( mwhatfield , mwhatinitial, misca, misavail, xrow )
//--------------------------------------------------------------
   local   mediting    := .t., mbuffer
   local   mcursor     := setcursor ( setcursor() )
   local   mlscr       := savescreen( ,,, ), mcolor := setcolor()
   local   vrow
   private mtop_row, mtop_col, mfull     , mscr      ,;
           mold_row, mold_col, m_win_row , m_win_col ,;
           marray  , mlevel  , mchoice   , mretval   ,;
           me_command        , mselected , mctr      ,;
           msavescr          , mhead                 ,;
           mk_f1disable      , i, cnt_color := 1, str_color := 'n',;
           mcollength
   mk_f1disable := .f.
   me_command   := 0
   mlevel       := 1
   mtop_row     := if( xrow == nil, 13, xrow )
   mtop_col     :=  2
   mfull        := .f.
   vrow := mtop_row

   if ( misca == Nil, misca := .t., Nil )
   if misavail == nil
      mcollength  := if( misca, 133, 75 )
   else
      mcollength  := 77
   endif
   if mwhatinitial != 'R'
      what_inside( 22, { '<F1>\Options ', '<F3>\Color ', '<F5>\Zoom ', '<F9>\Save ', '<F10>\Save & Exit ', '<Esc>\' } )
   else
      what_inside( 22, { '<F3>\Color ', '<F5>\Zoom ', '<F9>\Save ', '<F10>\Save & Exit ', '<Esc>\' } )
      mK_F1DISABLE := .t.
   endif
   if misca
   else
      @ mtop_row - 2, 2 say repl( 'Ä', 76 ) color 'w+/b'
   endif
   setcolor( 'gr+/n, w+/n,,, gr+/n' )
   setcursor( 3 )
   do while mediting
      dispbegin()
      do case
         case upper( mWHATINITIAL ) == 'S'
            @ mTOP_ROW - 1, 2 say padr( ' Security Held', 76 ) color 'w+/' + str_color
         case upper( mWHATINITIAL ) == 'O'
            @ mTOP_ROW - 1, 2 say padr( ' To Be Obtained', 76 ) color 'w+/' + str_color
         otherwise
            @ mTOP_ROW - 1, 2 say padr( ' Remarks', 76 ) color 'w+/' + str_color
      endcase
      @ 21, 2 say padl( 'ã ', 76 ) color 'w+/' + str_color
      dispend()              &&         1         2         3   4   5    6         7          8 9        10        11         12         13
      mWHATFIELD := memoedit ( mWHATFIELD, mTOP_ROW, mTOP_COL, 20, 77, .t. ,"wu_udf", mcollength,, mOLD_ROW, mOLD_COL, m_WIN_ROW, m_WIN_COL )
      if !empty( mE_COMMAND )
         do case
            case mE_COMMAND == 1
               mEDITING := .f.
               loop
            case mE_COMMAND == 2
               mFULL   := ! mFULL
               if mFULL
                  mSCR := savescreen( ,,, )
                  mTOP_ROW := 05 ; mTOP_COL := 02
               else
                  restscreen ( ,,,, mSCR )
                  mTOP_ROW := vrow; mTOP_COL := 02
               endif
            case mE_COMMAND == 3
         endcase
         mE_COMMAND := 0
      endif
   enddo
   setcolor   ( mCOLOR     )   
   setcursor  ( mCURSOR    )
   restscreen ( ,,,, mLSCR )
return nil

 function wu_udf( me_mode, me_row, me_col )

   local  mE_KEY   , mE_SAVE, mwhat_row := 1, nwhat_row := 1
   local  mCOLOR   := setcolor() , mCURSOR := setcursor ( setcursor () )
   local  xxx
   memvar mARRAY   , mLEVEL
   memvar mE_MACROS, mE_FILE     , mE_COMMAND
   memvar mOLD_ROW , mOLD_COL    , m_WIN_ROW, m_WIN_COL
   memvar mRETVAL  , mSELECTED   , mCTR
   memvar mSAVESCR , mHEAD       , mTOP_ROW
   memvar mK_F1DISABLE, mCHOICE, cnt_color, str_color

   mE_KEY := lastkey()
   if mE_MODE == ME_INIT             // initialization mode
      return ME_DEFAULT              // tell memoedit to start
   elseif mE_MODE == ME_IDLE         // idle mode, update row/column
      dispbegin()
      setcursor( 0 )
      @ mtop_row - 1, 69 say padl( ltrim( str( mE_ROW ) ), 4 ) + ':' + ;
                         padr( ltrim( str( mE_COL + 1 ) ), 4 ) color 'bg+/' + str_color
      setcursor( mcursor )
      dispend()             
   else
      do case
         case mE_KEY == K_ESC
              setcursor( 0 )
              mE_COMMAND := 1
              tone( 1600, 1 ) ; tone ( 800, 1 )
              if CONFIRM( 'Abandon Editing?' )
                 setcursor( mcursor )
                 return mE_KEY
              endif
              mE_COMMAND := 3; mE_KEY := K_CTRL_END
              setcursor( mcursor )
              return mE_KEY
         case mE_KEY == K_F1 .and. !mK_F1DISABLE
              setcursor( 0 )         
              mCHOICE := mLEVEL := mCTR := 1
              //mRETVAL := mSELECTED := '' ; mARRAY := transfer_value( mLEVEL )
              xxx := Getmemdata()
              keyboard if( lastkey() == K_ESC, '',xxx  )
              setcursor( mcursor )
         case mE_KEY == K_F3   

              if cnt_color > 0 .and. cnt_color <= 15
                 cnt_color++
              else
                 cnt_color := 1
              endif
              str_color := { 'n', 'b', 'g', 'bg', 'r', 'rb', 'gr', 'w', 'n+',;
                             'b+', 'g+', 'bg+', 'r+', 'rb+', 'gr+', 'w+' }[ cnt_color ]
              setcolor( 'gr+/' + str_color + ', w+/' + str_color + ',,, gr+/' + str_color )
              mE_COMMAND := 3; mE_KEY := K_CTRL_END

              return mE_KEY                
         case mE_KEY == K_F9 
              setcursor( 0 )
              waiton( 'commit!', .f., 'w+/bg' )
              inkey( .5 )
              waitoff() 
              setcursor( mcursor )
              mE_KEY := K_CTRL_END
              return mE_KEY
        case mE_KEY == K_F10
              //keyboard space(77)
              setcursor( 0 )
              waiton( 'commit!', .f., 'w+/bg' )
              inkey( .5 )
              waitoff() 
              setcursor( mcursor )
              mE_KEY := K_CTRL_END
              mE_COMMAND := 1
              return mE_KEY
         case mE_KEY == K_F5
              mE_COMMAND := 2
              return K_CTRL_END
         case mE_KEY == K_INS
              setcursor( if( readinsert(), 3, 1 ) )
              return K_INS
      endcase
   endif
   mOLD_ROW  := mE_ROW ; mOLD_COL  := mE_COL
   m_WIN_ROW := row()  ; m_WIN_COL := col()
return ME_DEFAULT




// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function AMSM0300OPEN()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   // if !NETUSE('OTICKET',.f.,5)
   local cscr := savescreen ( ,,, ),mcol
   @ 22,1 say 'Opening files .....'
   mcol := col()

//   alert ( '1' )
   xTEMP := creattemp()     // EVR 27112006
   dbcreate((xTEMP), {{'AOCODE','C',5,0},{'AONAME','C',40,0}})
   while !NETUSE((xTEMP),.F.,5); enddo
   index on AOCODE to (xTEMP)

//   alert ( '2' )
   *--->     && RED 092305 EXPERIMENTAL STAGE
   IF NETUSE('&g_AMS_PATH\OT_SEC',.F.,5)
      SET INDEX TO &g_AMS_PATH\OT_SEC
   ELSE
      RETURN .F.
   ENDIF

   @ 22,mCOL SAY '.'
   mCOL := COL()

//   alert ( '3' )
   IF NETUSE('&g_AMS_PATH\OT_OBT',.F.,5)
      SET INDEX TO &g_AMS_PATH\OT_OBT
   ELSE
      RETURN .F.
   ENDIF

   @ 22,mCOL SAY '.'
   mCOL := COL()

//   alert ( '4' )
   IF NETUSE('&g_AMS_PATH\OT_REM',.F.,5)
      SET INDEX TO &g_AMS_PATH\OT_REM
   ELSE
      RETURN .F.
   ENDIF

   @ 22,mCOL SAY '.'
   mCOL := COL()
   *--->

//   alert ( '5' )
   if !NETUSE('&g_AMS_PATH\Oticket',.F.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\OTICKET, &g_AMS_PATH\OTCLNT
   @ 22,mcol say '.'
   mcol := col()

//   alert ( '6' )
   if !NETUSE('&g_AMS_PATH\Aoaccess',.F.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\AOACCESS,&g_AMS_PATH\AOACCES2
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_GRF_PATH'+'\PERSONEL',.f.,5)
      return .f.
   endif
   set index to &g_GRF_PATH\INITIALS
   @ 22,mcol say '.'
   mcol := col()

//   alert ( '3' )

   if !NETUSE('&g_CIS_PATH'+'\CLIENT.DBF',.f.,5)
      return .f.
   endif
   set index to &g_CIS_PATH\CLIECD, &g_CIS_PATH\CLIENM
   @ 22,mcol say '.'
   mcol := col()

// EVR   if !NETUSE('PARAMETR',.f.,5)
// EVR      return .f.
// EVR   endif
// EVR   @ 22,mcol say '.'
// EVR   mcol := col()

   *--------------------------------------   RED 033005
   IF NETUSE('&g_AMS_PATH\OL_PARAM',.F.,5)
      SET INDEX TO &g_AMS_PATH\OL_PARAM
   ELSE
      RETURN .F.
   ENDIF
   *--------------------------------------

   if !NETUSE('&g_AMS_PATH\FACILITY',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\FCLTYCD
   @ 22,mcol say '.'
   mcol := col()

   
   if !NETUSE('&g_CIS_PATH'+'\AO.DBF',.f.,5)
      return .f.
   endif
   set index to &g_CIS_PATH\AO.NTX
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_CIS_PATH'+'\DEALER.DBF',.f.,5)
      return .f.
   endif
   set index to &g_CIS_PATH\DLRCODE, &g_CIS_PATH\DLRNAME
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_CIS_PATH'+'\SIGNERS.DBF',.f.,5)
      return .f.
   endif
   set index to &g_CIS_PATH\SIGNERS
   @ 22,mcol say '.'
   mcol := col()
   
   if !NETUSE('&g_CIS_PATH'+'\Indvcntc.DBF',.f.,5)
      return .f.
   endif
   set index to &g_CIS_PATH\Indvcntc
   @ 22,mcol say '.'
   mcol := col()
   
   if !NETUSE('&g_CIS_PATH'+'\Indvinfo.DBF',.f.,5)
      return .f.
   endif
   set index to &g_CIS_PATH\Indvinfo
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_AMS_PATH\ACCTMAST',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\ACCTMAST,;
                &g_AMS_PATH\ACCTCLNT,;
                &g_AMS_PATH\SURECLNT,;
                &g_AMS_PATH\ACCTFA  ,;
                &g_AMS_PATH\ACCTSUB2
   dbsetorder(3)
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_AMS_PATH\COMCODES',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\COMCODES
   @ 22,mcol say '.'
   mcol := col()


   if !NETUSE('&g_AMS_PATH\COMEMBER',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\COMEMBER
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_CIS_PATH'+'\INDUSTRY.DBF',.f.,5)
      return .f.
   endif
   set index to &g_CIS_PATH\INDUSTRY
   @ 22,mcol say '.'
   mcol := col()


   if !NETUSE( '&g_CIS_PATH'+'\CORPINFO.DBF',.f.,5)
      return .f.
   endif
   set index to &g_CIS_PATH\CORPINFO
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_AMS_PATH\CAHEADER',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\CAHEADER, &g_AMS_PATH\CAREV, &g_AMS_PATH\CACLNT
   Caheader->(dbsetorder(3))
   @ 22,mcol say '.'
   mcol := col()

   if !netuse('&g_AMS_PATH\Cadetail',.f.,5)                // abb 12.27.2002
      return .f.
   else
      set index to &g_AMS_PATH\Cadetail,&g_AMS_PATH\Cadetcfl
   endif
   @ 22,mcol say '.'
   mcol := col()


   if !netuse( '&g_AMS_PATH\Subcred',.f.,5 )
      return .f.
   endif
   set index to &g_AMS_PATH\Subcred
   @ 22,mcol say '.'
   mcol := col()


   if !NETUSE('&g_AMS_PATH\GRPCODES',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\GRPCODES
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_AMS_PATH\GRPMEMBR',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\GRPMEMBR, &g_AMS_PATH\GRPCLNT,&g_AMS_PATH\GRPCLNT2, &g_AMS_PATH\GRPMEMB2
   Grpmembr->(dbsetorder(2))
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_AMS_PATH\APPROVER',.f.,5)
      return .f.
   endif
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_AMS_PATH\AXMAST',.f.,5 )
      return .f.
   endif
   set index to &g_AMS_PATH\USER_ID
   @ 22,mcol say '.'
   mcol := col()


   if !NETUSE('&g_AMS_PATH\Drop',.f.,5 )
      return .f.
   endif
   set index to &g_AMS_PATH\Drop
   @ 22,mcol say '.'
   mcol := col()

   if !netuse( '&g_grf_path'+'\Axbranch.dbf',.f.,5)
      return .f.
   endif
   set index to &g_grf_path\Axbranch
   @ 22,mcol say '.'
   mcol := col()

   if !netuse( '&g_grf_path\Branches', .f., 5 ) && branches
      return .f.
   else
      ordlistadd( '&g_grf_path\Brcode' )   && set index on branch code
   endif
   @ 22,col() say '.'

   restscreen ( ,,,,cscr )
return .t.

Static Function Getmemdata()

local mu := savescreen( ,,, ),rx_:=setcolor()
local nretval,xray_:={},sw:=.f.,xtring
local xx_,zz_,yy_,st_
local yray_:={ .t.,.f.,.f.,.t.,.f.,.t.,.f.,.f.,.t.,.t.,.t.,.t.,.f.,.f.,.t.,.t.,.f.,.f. }
xray_ := { 'ş Minimum Comprehensive Insurance Coverage for the ' ,;
           '  entire term shall be the purchase amount to be ',   ;
           '  secured from an Orix-accredited insurance company .',;
           'ş Minimum Third Party Liability Insurance Coverage ' ,;
           '  of at least 100,000.00.'                           ,;
           'ş Minimum Floater Insurance Coverage shall be the '  ,;
           '  purchase amount for the entire term to be secured ',;
           '  from an insurance company accredited to ORIX.'     ,;
           'ş Post-Dated Checks for all monthly amortization.'   ,;
           'ş Ocular & Documention Fee of P _.',;
           'ş Second Hand Units are subject to appraisal.'       ,;
           'ş Net Amount Financed should not be more than _% '  ,;
           '  of the appraised value.'                          ,;
           'ş Appraisal Fee of P _.'                ,;
           'ş All Other Incidental Costs, such as, but not '     ,;
           '  limited to Mortgage Fee, Doc. Stamps Fee, etc., '  ,;
           '  shall be borne by the mortgage.' }
fshadow( 9, 12, 22, 68, 2, 'w/bg', )
@ 9, 14 say 'Terms and Conditions' color 'n/bg'
setcolor('w/n,n/w,,,w/n')
while .t.
  achn := achoice( 10,13,21,67,xray_,yray_)
  if lastkey() == K_ESC
    exit
  elseif lastkey() <> K_RIGHT .and. lastkey() <> K_LEFT
   sw:= .t.
   exit
  endif
enddo
if sw
  if achn == 1
     xtring := xray_[1] + xray_[2] + xray_[ 3 ]
  elseif achn == 4
     xtring  := xray_[4] + xray_[5]
  elseif achn == 6
     xtring  := xray_[6] + xray_[7] + xray_[8]
  elseif achn == 9
     xtring  := xray_[9]
  elseif achn == 10
     xtring  := xray_[10]
     xx_ := getval('N', 'Documentation Fee','999,999,999.99' )
     zz_ := at('_',xtring )
     st_ := alltrim( trans(xx_,'@B 999,999,999.99') )
     xtring := stuff( xtring, zz_ , 1 , st_ )
  elseif achn == 11
     xtring  := xray_[11]
  elseif achn == 12
     xx_ := getval('N', 'Percentile of Appraised Value','99.99' )
     zz_ := at('_',xray_[12] )
     st_ := alltrim( trans(xx_,'@BZ 99.99') )
     xray_[12] := stuff( xray_[12], zz_, 1, st_ )
     // xx_ := getval('N', 'Appraised Value','999,999,999.99' )
     // st_ := alltrim( trans(xx_,'@B 999,999,999.99' ) )
     // zz_ := at('+',xray_[13] )
     // xray_[13]:=stuff( xray_[13] , zz_ , 1 , st_ )
     xtring  := xray_[12] + xray_[13] // + xray_[14]
  elseif achn == 14
     xtring  := xray_[14]
     xx_ := getval('N', 'Appraised Fee','999,999,999.99' )
     st_ := alltrim( trans(xx_,'@B 999,999,999.99') )
     zz_ := at('_',xtring )
     xtring := stuff( xtring , zz_ , 1 , st_ )
  elseif achn == 15
     xtring  := xray_[15] + xray_[16] + xray_[17]
  endif
  xtring := stuff( xtring, at('ş',xtring),2,'' )
endif
restscreen( ,,,, mu )
return xtring
//--------------------------------------------
static Function getval( xtype,xtle,xpic,nstr )
//--------------------------------------------
local mu := len( xtle ) + len(xpic ) + 4,cv_
local rx_ := savescreen( ,,, ),ev_:=setcolor(),oldv
local rr_:=setcursor()
nstr := if( nstr == nil,1,nstr)
oldv:=cv_:=if(xtype == 'N',0,if( xtype == 'D',ctod('  /  /  '),spac(nstr)) )
setcursor(1)
fshadow( 3, 5 , 5, 5 + mu, 2 ,'n/bg' )
setcolor('w/bg,w+/n,,,w+/bg')
do while .t.
  @ 4,6 say xtle + ' ' get cv_  pict xpic
  read
  if lastkey() == K_ENTER .or. lastkey() == K_ESC
     exit
  endif
enddo
if lastkey() == K_ESC
   cv_ := oldv
endif
setcolor(ev_)
setcursor(rr_)
restscreen(,,,, rx_ )
return cv_

*****************************************
*
static function _BR_rights ( cusercode )   // ABB 10.12.2004
*****************************************
    local lretval := .f.,nrec := axbranch->(recno())

    if axbranch->(dbseek(alltrim(cusercode)))

       do while !axbranch->(eof()) .and. ;
                alltrim(axbranch->user_id) == alltrim(cusercode)

          if alltrim(axbranch->brcode) == alltrim(Oticket->brcode)
             lretval := .t.
          endif

          axbranch->(dbskip(+1))
       enddo

    endif

    axbranch->(dbgoto(nrec))

return lretval

************************************
*
static function _chkright(xAocode,sbrcode)
************************************
 local mretval := .f.
 memvar G_USER_ID
 Aoaccess->( dbseek ( alltrim(Oticket->brcode) + G_USER_ID) )
 do while alltrim(Aoaccess->Aocode) == alltrim(G_USER_ID) .and. ;
          alltrim(Oticket->brcode)  == alltrim(sbrcode) .and. ;
          !Aoaccess->(eof())

    if alltrim(Aoaccess->aoaccess) == alltrim(xAocode)
       mretval := .t.
       exit
    endif
    Aoaccess->(dbskip())
 enddo
 if !mretval
    error('Access to this account denied.')
 endif
 return mretval
/*          && RED 100505
**********************************
*   Description   displays AONAME
*   Parameters    ao code
*   Return Value  nil
static function dispAONAME( mAOCODE )
**********************************
   Ao->( dbseek ( mAOCODE ) )
return Ao->AONAME
*/
*
*                        end of the program ( amsm0300.prg )
*
*------------------------------------------------------------------------------>
FUNCTION SAVEMEM( mTEXT, cFLD, cKEY, cBRCODE )
LOCAL cWRKAREA := ''
LOCAL nROWS    := 0
LOCAL cLMODE   := ''
LOCAL cROW     := ''
LOCAL nSTART   := 0
LOCAL nEND     := 0

DO CASE
   CASE UPPER(cFLD) == 'OT_SEC'
        cWRKAREA := 'OT_SEC'
   CASE UPPER(cFLD) == 'OT_OBT'
        cWRKAREA := 'OT_OBT'
   CASE UPPER(cFLD) == 'OT_REM'
        cWRKAREA := 'OT_REM'
   CASE UPPER(cFLD) == 'OT_CON'
        cWRKAREA := 'OT_CON'
   CASE UPPER(cFLD) == 'AW_REM'
        cWRKAREA := 'AW_REM'
   CASE UPPER(cFLD) == 'CA_SEC'
        cWRKAREA := 'CA_SEC'
   CASE UPPER(cFLD) == 'CA_OBT'
        cWRKAREA := 'CA_OBT'
ENDCASE

*nROWS := MLCOUNT( mTEXT, 76,,)
nROWS := LEN(mTEXT)/76
IF( MOD(LEN(mTEXT),76) > 0, nROWS++, NIL )

FOR I := 1 TO nROWS
    IF (cWRKAREA)->(DBSEEK(cBRCODE+cKEY+STR(I,6)))
       cLMODE := 'R'
    ELSE
       cLMODE := 'A'
    ENDIF

    nSTART := (76 * (I-1)) + 1
    nEND   := nSTART + 76

    cROW := SUBSTR(mTEXT, nSTART, nEND)
    *cROW := MEMOLINE(mTEXT, 76, I,,, )
    *mTEXT := MEMOTRAN(mTEXT,'','')

    IF (cWRKAREA)->(NETLOCK(cLMODE,5))
       IF UPPER(LEFT(cWRKAREA,2)) == 'OT'
          REPLACE (cWRKAREA)->OTNUMBER WITH cKEY
       ELSEIF UPPER(LEFT(cWRKAREA,2)) == 'AW'
          REPLACE (cWRKAREA)->ACCTNO   WITH cKEY
       ELSEIF UPPER(LEFT(cWRKAREA,2)) == 'CA'
          REPLACE (cWRKAREA)->CANUMBER WITH cKEY
       ENDIF
       REPLACE (cWRKAREA)->BRCODE   WITH cBRCODE
       REPLACE (cWRKAREA)->LINE     WITH I
       REPLACE (cWRKAREA)->TEXT     WITH cROW
       (cWRKAREA)->(DBRUNLOCK())
    ENDIF
NEXT

DO WHILE .T.
   IF (cWRKAREA)->(DBSEEK(cBRCODE+cKEY+STR(I,6)))
      IF (cWRKAREA)->(NETLOCK('R',5))  
         (cWRKAREA)->(DBDELETE())
      ENDIF
   ELSE
      EXIT
   ENDIF
   I++
ENDDO

RETURN
*------------------------------------------------------------------------------>
FUNCTION COLLMEM( cFLD, cKEY, cBRCODE )
LOCAL cWRKAREA := ''
LOCAL mTEXT    := ''
LOCAL nROW     := 1

DO CASE
   CASE UPPER(cFLD) == 'OT_SEC'
        cWRKAREA := 'OT_SEC'
   CASE UPPER(cFLD) == 'OT_OBT'
        cWRKAREA := 'OT_OBT'
   CASE UPPER(cFLD) == 'OT_REM'
        cWRKAREA := 'OT_REM'
   CASE UPPER(cFLD) == 'OT_CON'
        cWRKAREA := 'OT_CON'
   CASE UPPER(cFLD) == 'AW_REM'
        cWRKAREA := 'AW_REM'
   CASE UPPER(cFLD) == 'CA_SEC'
        cWRKAREA := 'CA_SEC'
   CASE UPPER(cFLD) == 'CA_OBT'
        cWRKAREA := 'CA_OBT'
ENDCASE

IF (cWRKAREA)->(DBSEEK(cBRCODE+cKEY+STR(nROW,6),.F.))
   DO WHILE IF(LEFT(cWRKAREA,2) == 'OT',;
               (cWRKAREA)->BRCODE+(cWRKAREA)->OTNUMBER,;
               IF(LEFT(cWRKAREA,2) == 'AW',;
                  (cWRKAREA)->BRCODE+(cWRKAREA)->ACCTNO,;
                  (cWRKAREA)->BRCODE+(cWRKAREA)->CANUMBER)) == cBRCODE+cKEY .AND. ;
               !(cWRKAREA)->(EOF())
      mTEXT := mTEXT+(cWRKAREA)->TEXT
      (cWRKAREA)->(DBSKIP())
   ENDDO
ENDIF

RETURN mTEXT

/* //chi 072309
***************************************
*
static function _rights ( caocode )
***************************************
    local lretval := .f.,nrec := aoaccess->(recno())
//    if aoaccess->(dbseek(alltrim(Caheader->brcode+G_USER_ID)))
    if aoaccess->( dbseek( alltrim(Caheader->brcode)+;//Oticket->Aocode
                           left(alltrim(G_USER_ID)+'   ',6)+;
                           alltrim(Caheader->aocode);
                         );
                 )

//       do while !aoaccess->(eof()) .and. ;
  //              alltrim(aoaccess->aocode) == alltrim(G_USER_ID) .and. ;
    //            alltrim(aoaccess->brcode) == alltrim(aoaccess->brcode)  ;

      //    if alltrim(aoaccess->aoaccess) == alltrim(caocode)
             lretval := .t.
        //  endif

          //aoaccess->(dbskip(+1))
       //enddo

    endif

    aoaccess->(dbgoto(nrec))

return lretval */
