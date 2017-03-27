/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   PROGRAM ID.........:  amsm1007.prg                                         ³
³   Description........:  availment sheet maintenance                          ³
³   Author.............:  Ariel B. Bulan                                       ³
³   Date...............:  02:18pm 10-Jan-1995                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                         U P D A T E S                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        Who        ³     When      ³               Why                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ janet l. bautista ³  12-Apr-1996  ³ remove value date validation             ³
³ renan evangelista ³  25-Jun-1996  ³ limit the access of Ao                   ³
³                   ³  11-Jul-1996  ³ revise screen display < docref2 &        ³
³                   ³               ³ refno2 > & validate their entry          ³
³ janet l. bautista ³  18-Aug-1998  ³ round computation of rv/gd to 1          ³
³                   ³               ³ decimal place, tot. rec'bles comp        ³
³ janet b. salvador ³  15-Feb-1999  ³ tracking of ca/ot balance must           ³
³                   ³               ³ include availment + bookings             ³
³ ariel b. bulan    ³  10.29.2001   ³ modified computation of unavailed        ³
³                   ³               ³          principal                       ³
³ RED K. GUYALA     ³  10/05/2004   ³ Changed the acct no. format and          ³
³                   ³               ³  its database seeking.                   ³
³ abb               ³  10.13.2004   ³  ONLINE                                  ³
³ aga               ³  14.02.2007   ³  marked for paytsked use in 100e, b, f   ³
³ mts               ³  7/21/2008    ³  comment out (Scanning for valid branch/ ³
³                   ³               ³  user records) & modified for exclusive  ³
³                   ³               ³  use according to user's branch code     ³
³ MTS               ³  08.24.2011   ³ Added di/si,wtax,& neteff rate in        ³
³                   ³               ³  ML facility and UDI computation in CML  ³
³ RLV               ³  9/20/2011    ³  Modified Structure for DOSRI Tagging    ³
³ MTS               ³  10/21/2013   ³  Validation for Sub-limit & Main Facility³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include "Colf.ch"
#include "Inkey.ch"

private _ltruerate,_lterm,_lgd,_lrv,_lratetype,_lpaytype
private _lcredamt , _lamort
private __ncredamt := 0,__namort := 0
private __crefno2 := space(5)

if CHKPASS( procname(),ax_level,g_user_id )
   if amsm1007open()
      fm1007 ()
   endif
   eval ({|| __mrelease( "*", .t.), dbcloseall() })
endif
return

*******************************
*
static function fm1007()
*******************************
local keys_ := { '<Ins>\-Add ', '<F2>\Edit ', '<F3>\CredAmt ', '<F4>\Search ', '<F5>\Details ', '<F9>\Print ', '<Del>\ ', '<Esc>\' }
local nrow := 5, mrow := 1, mbanner := 'Availment Sheet Maintenance'
memvar g_sys_name, g_user_id, mtrandate
private sbrcode := space(3)

   _lgd       := .f.
   _ltruerate := .f.
   _lterm     := .f.
   _lrv       := .f.
   _lratetype := .f.
   _lpaytype  := .f.

   dbselectar ( 'Acctwait' )
   Acctwait->(dbseek(g_PAR_BRCH))

   nrecno := Acctwait->(recno())

   IF !amstsearch( space( len( Acctwait->clntcode ) ),sbrcode )  && RED 112404 ADDED 'IF !.. RETURN ENDIF
      if lastkey() == K_ESC      
         return
      endif
      __keyboard( chr( K_INS ) )
   ENDIF

   if lastkey() == K_ESC        
      return
   endif

   if ACCTWAIT->BRCODE <> g_PAR_BRCH .AND. !_BR_rights ( g_USER_ID, 'CLIENT' )   
      error ( 'Cannot access A.S. of ' + _get_branch(ACCTWAIT->brcode) )
      Acctwait->(dbgoto(nrecno))
      return
   else

      if Acctwait->(eof())
         __keyboard( chr( K_INS ) )
      else

         if !_rights ( Acctwait->aocode )

         else
            sbrcode := Acctwait->brcode
         endif
      endif

   endif

   sbrcode := g_PAR_BRCH
   
   nscanctr := 0

   if !_rights(Acctwait->aocode)
       error ( 'A.S. belongs to '+Acctwait->aocode )
	   Acctwait->(dbgobottom())
	   Acctwait->(dbskip(+1))
   endif


   scr_make   ( keys_, 3, 1, 22, 78, mbanner )

   if Acctwait->( eof() )
      error( "No Record Found!" )
      __keyboard( chr( K_INS ) )
   endif

   while eval ( { || disprec(),;
                     gkey1007( @mrow, @nrow ) ;
                };
              )
   enddo

   return nil

********************************************
*
*
static function gkey1007(mrow, nrow)
********************************************
   local mretval := .t., mkey, nretval := 0,nrecno := 0
   local noldcredamt := 0, noldamort := 0
   local csource := if(Acctwait->docref=='1','CA#','OT#' )


   memvar ax_level, g_user_id

   mkey := inkey(0)

   do case

      case mkey == K_F3   // CHANGE AMORT/CREDIT AMOUNT abb 09.12.2005

         if Acctwait->brcode == g_PAR_BRCH

            __scr0912 := savescreen (10,10,16,64)
            __ccursor := setcursor  ()
            if chkpass ( 'S', ax_level, g_user_id )

               __ncredamt := Acctwait->credamt
               __namort   := Acctwait->amort

               if Acctwait->changed <= 0  // nabago na ba yung CREDAMT/AMORT ?
                  noldcredamt := Acctwait->credamt
                  noldamort   := Acctwait->amort

                  __ncredamt := 0
                  __namort   := 0
               else
                  noldcredamt := Acctwait->oldcredamt
                  noldamort   := Acctwait->oldamort
               endif


               @ 10,10 clear to 15,64
               @ 10,10 to 15,64

               center ( 24, 'w+/n', '<<< CHANGE AMORT/CREDIT AMOUNT >>> ' )
               @ 11,11 say '                        ORIGINAL         DEVIATION'
               @ 12,11 say 'Credit Amount       : ' + trans ( noldcredamt ,'999,999,999.99' ) + ' -'
               @ 13,11 say 'Amortization/Rental : ' + trans ( noldamort   ,'999,999,999.99' ) + ' -'

/*               @ 14,11 say '(enter ZERO for IRREGULAR Amortization/Rental) ' color 'b/w'*/

               @ 12, 50 get __ncredamt               ;
                        pict '999,999,999.99'        ;
                        valid !empty(__ncredamt)

               @ 13, 50 get __namort                 ;
                        when _get_amort(@__namort)   ;
                        pict '999,999,999.99'        ;
                        valid __namort >= 0

               setcursor(3)
               read

               if lastkey() == K_ENTER

                  if noldcredamt != __ncredamt .or. noldamort != __namort

                     alert ( 'WARNING: Changes to the Monthly Amortization/Credit Amount cannot be reverted to '+csource+' '+Acctwait->brcode+'-'+Acctwait->refno+ ' once you update it.')

                     if confirm ( 'Continue to replace Credit Amt. '+alltrim(transform( noldcredamt,'999,999,999.99'))+;
                                  ' with '+ alltrim ( transform ( __ncredamt,'999,999,999.99')) ;
                                )

                        if confirm( 'Are you sure?' )

                           if Acctwait->(netlock('R',0))

                              center ( 24, 'w+/n', 'Replacing Credit Amount            ' )

                              Acctwait->oldcredamt := noldcredamt
                              Acctwait->oldamort   := noldamort

                              center ( 24, 'w+/n', 'Replacing Amortization             ' )

                              Acctwait->credamt := __ncredamt
                              Acctwait->amort   := __namort
                              Acctwait->changed := Acctwait->changed + 1

                           endif

                           Acctwait->(dbunlock())
                           Acctwait->(dbcommit())

                           center ( 24, 'w+/n', 'Updating Audit Trail               ' )

                           if AcctDrop->(netlock('A',0))
                              AcctDrop->user_id    := g_user_id
                              AcctDrop->date       := mtrandate
                              AcctDrop->time       := time()
                              AcctDrop->oldcredamt := noldcredamt
                              AcctDrop->oldamort   := noldamort
                              AcctDrop->credamt    := __ncredamt
                              AcctDrop->amort      := __namort
                              AcctDrop->acctno     := Acctwait->acctno
                              AcctDrop->aocode     := Acctwait->aocode
                              AcctDrop->brcode     := Acctwait->brcode
                           endif

                           AcctDrop->(dbunlock())
                           AcctDrop->(dbcommit())

                           center ( 24, 'w+/n', '                                   ' )
                           error  ( 'UPDATE COMPLETED  ')


                       endif

                     endif

                  endif

               endif

               center ( 24, 'w+/n', '                                   ' )

            endif

            setcursor  ( __ccursor )
            restscreen ( 10,10,16,64,__scr0912)

         endif


      case mkey == K_UP //.or. mkey == K_PGUP

         if g_PAR_BRCH == '001'
         if chkpass ( 'S', ax_level, g_user_id )

            *if !Acctwait->(eof()) .and. _rights( ACCTWAIT->BRCODE, Acctwait->aocode )
            if !Acctwait->(eof()) .and. _rights( Acctwait->aocode )

               nrecno := Acctwait->(recno())

               Acctwait->( dbskip( -1 ) )

               if alltrim(Acctwait->brcode) != alltrim(sbrcode)
                  error ( 'Top of Branch File' )
                  Acctwait->(dbgoto(nrecno))

               else

                  nscanctr := 0
                  cscr := savescreen (,,,)

				  if !_rights(Acctwait->aocode)
					 //error ( 'A.S. belongs to '+Acctwait->aocode )
					 //Acctwait->(dbgobottom())
		 		     Acctwait->(dbskip(-1))
		             if !aoaccess->(dbseek(alltrim(Acctwait->brcode)+left(alltrim(G_USER_ID)+'   ',6)+alltrim(Acctwait->aocode)))

					    do while !Acctwait->(bof())
					      if aoaccess->(dbseek(alltrim(Acctwait->brcode)+left(alltrim(G_USER_ID)+'   ',6)+alltrim(Acctwait->aocode)))
					 	     exit
					      endif
					    Acctwait->(dbskip(-1))
					   enddo
					 endif
				  endif

                  restscreen (,,,,cscr )

                  if Acctwait->(bof())
                     error ( 'This is the first record'  )
                     Acctwait->(dbgoto(nrecno))
                  endif
               endif

            endif

         endif

         endif
      case mkey == K_DOWN //.or. mkey == K_PGDN

         if g_PAR_BRCH == '001'

         if chkpass ( 'S', ax_level, g_user_id )

           *if !Acctwait->(eof()) .and. _rights( ACCTWAIT->BRCODE, Acctwait->aocode )
           if !Acctwait->(eof()) .and. _rights( Acctwait->aocode )

            nrecno := Acctwait->(recno())

            Acctwait->( dbskip( +1 ) )

			IF ACCTWAIT->BRCODE ==  g_PAR_BRCH

	            cscr := savescreen (,,,)
	            nscanctr := 0

				if !_rights(Acctwait->aocode)
				   //error ( 'A.S. belongs to '+Acctwait->aocode )
				   //Acctwait->(dbgobottom())
	 		       Acctwait->(dbskip(+1))
		               if !aoaccess->(dbseek(alltrim(Acctwait->brcode)+left(alltrim(G_USER_ID)+'   ',6)+alltrim(Acctwait->aocode)))

					      do while !Acctwait->(eof())
						     if Acctwait->brcode == g_PAR_BRCH
						          if aoaccess->(dbseek(alltrim(Acctwait->brcode)+left(alltrim(G_USER_ID)+'   ',6)+alltrim(Acctwait->aocode)))
							         exit
						          endif
							 endif
					      Acctwait->(dbskip(+1))
						  enddo
					   endif
			    endif

	            restscreen (,,,,cscr )

			ELSE
		        Acctwait->(dbgobottom())
	            Acctwait->(dbskip(+1))
			ENDIF

            if Acctwait->(eof())
               error ( 'This is the last record' )
               Acctwait->( dbgoto(nrecno) )
            endif

            endif

         endif
         endif

      case mkey == K_DEL


         if CURRBRCH(ACCTWAIT->BRCODE) .AND. chkpass ( 'E', ax_level, g_user_id )

            if Acctwait->( eof() )
               error ( 'Nothing to delete!' )
            else


               if !Acctdaly->(dbseek(Acctwait->brcode+Acctwait->acctno))
                  *if _rights ( ACCTWAIT->BRCODE, Acctwait->aocode )
                  if _rights ( Acctwait->aocode )

                     amstdelete ( 'Delete Acct N§ '+ tran( ACCTWAIT->BRCODE+Acctwait->acctno, '@R 999-9999-99999-99999' ) )

                      nrecno := Acctwait->(recno())

                     nscanctr := 0
                     cscr := savescreen(,,,)

					 if !_rights(Acctwait->aocode)

			 		    Acctwait->(dbskip(-1))
			            if !aoaccess->(dbseek(alltrim(Acctwait->brcode)+left(alltrim(G_USER_ID)+'   ',6)+alltrim(Acctwait->aocode)))

						   do while !Acctwait->(bof())
						     if aoaccess->(dbseek(alltrim(Acctwait->brcode)+left(alltrim(G_USER_ID)+'   ',6)+alltrim(Acctwait->aocode)))
						 	    exit
						     endif
						   Acctwait->(dbskip(-1))
						  enddo
						endif
					 endif

                     restscreen (,,,,cscr )

                     if Acctwait->(eof())
                        error ( 'This is the last record' )
                        Acctwait->(dbgoto(nrecno))
                     endif

                  else
                     error ( 'Cannot delete A.S. of '+Acctwait->aocode )
                  endif
              else
                 error ( 'Availment Sheet already exists in Acct. Execution' )
              endif

            endif

         endif

      case mkey == K_INS

           if chkpass( 'A', ax_level, g_user_id )
              amstupdate( 'A' )
           endif

      case mkey == K_F2

         if Acctdaly->(dbseek(Acctwait->brcode+Acctwait->acctno))
            error ( 'Availment Sheet already exists in Acct. Execution' )
         else

            if CURRBRCH(ACCTWAIT->BRCODE) .AND. CHKPASS( 'E', ax_level, g_user_id ) .and. _chkright(Acctwait->Aocode,sbrcode)
               if Acctwait->( eof() )
                 error( 'Nothing to Edit!' )
               else
                  amstupdate( 'E' )
               endif
            endif
         endif
      case mkey == K_F4

         if chkpass ( 'S', ax_level, g_user_id )

            if Acctwait->( eof() )
               error( 'Nothing to search!' )
            else

              nrecno := Acctwait->(recno())

              amstsearch( space( len( Acctwait->clntcode ) ),sbrcode )

              if ACCTWAIT->BRCODE <> g_PAR_BRCH
                 error ( 'Cannot access A.S. of ' + _get_branch(ACCTWAIT->BRCODE) ) && RED 031805 REPLACED 'Oticket->brcode
                 Acctwait->(dbgoto(nrecno))
              else

                 *if !_rights ( ACCTWAIT->BRCODE, Acctwait->aocode ) .or. Acctwait->(eof())
                 if !_rights ( Acctwait->aocode ) .or. Acctwait->(eof())
                    error ( 'A.S. belongs to '+Acctwait->aocode )
                    Acctwait->(dbgoto(nrecno))
                 else
                    sbrcode := Acctwait->brcode
                 endif

              endif

            endif

         endif

      case mkey == K_F5
         if CHKPASS( 'S', ax_level, g_user_id )
            if Acctwait->( eof() )
               error( 'No Details Available!' )
            else

                tones()
                tones()
                *if _rights ( ACCTWAIT->BRCODE, Acctwait->aocode )
                if _rights ( Acctwait->aocode )
                   f1007details()
                else
                   error ( 'Cannot update Availment of '+Acctwait->aocode )
                endif
            endif
         endif
      case mkey == K_F9

           if CHKPASS( 'S', ax_level, g_user_id )

              if Acctwait->( eof() )
                 error( 'Nothing to Print!' )
              else
                 *if _rights ( ACCTWAIT->BRCODE, Acctwait->aocode )
                 if _rights ( Acctwait->aocode )

                     do case
                        case Acctwait->docref == '1'

                             if Caheader->( dbseek( Acctwait->brcode+Acctwait->refno ) )

                                if Caheader->actaken != '3'
                                   error( 'CA not yet APPROVED!' )
                                else

                                   if !empty( Acctwait->Docref2 )

                                      if Acctwait->Docref2 == '1'

                                         if Caheader->( dbseek( Acctwait->brcode+Acctwait->refno2 ) )

                                            if Caheader->actaken != '3'
                                               error( 'CA not yet APPROVED!' )
                                            else
                                               ams1007print ()
                                               drop  ( alltrim(g_user_id)+' '+'prints acctno (avail.) ' + Acctwait->brcode+substr(Acctwait->acctno,-5,5) )
                                            endif
                                         endif
                                      elseif Acctwait->docref2 == '2'

                                         if Oticket->( dbseek( Acctwait->brcode+Acctwait->refno2 ) )

                                           if Oticket->actaken != '3'

                                              error( 'OT not yet APPROVED!' )
                                           else
                                              ams1007print()
                                              drop  ( alltrim(g_user_id)+' '+'prints acctno (avail.) ' + substr(Acctwait->acctno,-5,5) )
                                           endif
                                         endif
                                      endif

                                   else

                                      ams1007print()
                                      drop  ( alltrim(g_user_id)+' '+'prints acctno (avail.) ' + substr(Acctwait->acctno,-5,5) )
                                   endif
                                endif
                             endif
                        otherwise

                           if Oticket->( dbseek( Acctwait->brcode+Acctwait->refno ) )

                              if Oticket->actaken != '3'

                                 error( 'OT not yet APPROVED!' )
                              else
                                 if !empty( Acctwait->Docref2 )

                                    if Acctwait->Docref2 == '1'

                                       if Caheader->( dbseek( Acctwait->brcode+Acctwait->refno2 ) )

                                          if Caheader->actaken != '3'

                                             error( 'CA not yet APPROVED!' )
                                          else

                                             ams1007print()
                                             drop  ( alltrim(g_user_id)+' '+'prints acctno (avail.) ' + substr(Acctwait->acctno,-5,5) )

                                          endif
                                       endif

                                    elseif Acctwait->docref2 == '2'

                                       if Oticket->( dbseek( ACCTWAIT->BRCODE+Acctwait->refno2 ) ) && RED 022205 ADDED BRCODE

                                           if Oticket->actaken != '3'

                                              error( 'OT not yet APPROVED!' )
                                           else

                                              ams1007print()
                                              drop  ( alltrim(g_user_id)+' '+'prints acctno (avail.) ' + substr(Acctwait->acctno,-5,5) )
                                           endif

                                       endif

                                    endif

                                 else

                                    ams1007print()
                                    drop  ( alltrim(g_user_id)+' '+'prints acctno (avail.) ' + substr(Acctwait->acctno,-5,5) )
                                 endif
                              endif
                           endif
                     endcase
                 else
                    error ( 'Cannot print Availment of '+Acctwait->aocode )
                 endif
              endif
           endif
      case mkey == K_ESC
         if exitmod()
            mretval := !mretval
         endif
   endcase
   tb_indicator( mkey, @mrow, @nrow, 78, 5, 20 )
return( mretval )

*****************************************
*
static function _get_amort ( __namort )
*****************************************
   local lretval := .t.

   if confirm ( 'Irregular Payment?',.t. )
      lretval  := .f.
      __namort := 0
   endif

   if lastkey() == K_ESC
      lretval := .f.
   endif

return lretval

***************************************
*
static function _rights ( caocode )
***************************************
    local lretval := .f.,nrec := aoaccess->(recno())

dbselectarea('aoaccess')      
dbsetorder(1)

    if aoaccess->(dbseek(alltrim(Acctwait->brcode)+left(alltrim(G_USER_ID)+'   ',6)+alltrim(Acctwait->aocode)))

       lretval := .t.

    endif
	aoaccess->(dbgoto(nrec))
dbselectarea('acctwait')

return lretval

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function f1007details()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mfcltycode, mmatdate  , munit     , mdlrcode , mponum   , mpurcamt ,;
         munitloca , mprincipal, mpaytype  , mgd, mrv , mterm    , mtermunit,;
         mtruerate , mratetype , mfirstdue , mfactor  , mamort   , mcredamt ,;
         malir     , mpayfreq  , maddon    , mudi     , msalesrep, mdownpay ,;
         mincentive, mnotfctn  , mcolexion , mrecourse, mobligor , mcolatrl ,;
         mtrantype , munit2    , mslv := {}, macctno  , mvaldate , mdocref  ,;
         mdocref2  , mrefno2   , mnerate   , mappval  , mwtax    , mudiamt  ,;
		 mdtlcode  , mdtlcode2 

   assign_details ( @mfcltycode, @mmatdate , @munit     , @mdlrcode , @mponum   ,;
                    @mpurcamt  , @munitloca, @mprincipal, @mpaytype , @mgd      ,;
                    @mrv       , @mterm    , @mtermunit , @mtruerate, @mratetype,;
                    @mfirstdue , @mfactor  , @mamort    , @mcredamt , @malir    ,;
                    @mpayfreq  , @maddon   , @mudi      , @msalesrep, @mdownpay ,;
                    @mincentive, @mnotfctn , @mcolexion , @mrecourse, @mobligor ,;
                    @mcolatrl  , @mtrantype, @munit2    , @mnerate  , @mappval  ,;
					@mwtax     , @mudiamt  , @mdtlcode  , @mdtlcode2 ;
                  )

   mrefno   := ACCTWAIT->BRCODE+Acctwait->refno
   mdlrcode := Acctwait->dlrcode
   mdocref  := Acctwait->docref
   mrefno2  := ACCTWAIT->BRCODE+Acctwait->refno2
   mdocref2 := Acctwait->docref2

   return( eval( { | n | chek_fcltycode(  'E'      , @mfcltycode, @munit    , @mdlrcode , @mponum  , @mpurcamt  ,;
                                         @munitloca, @mprincipal, @mpaytype , @mgd, @mrv, @mterm   , @mtermunit ,;
                                         @mtruerate, @mratetype , @mfirstdue, @mpayfreq , @mfactor , @mamort    ,;
                                         @mcredamt , @malir     , @mmatdate , @msalesrep, @mdownpay, @mincentive,;
                                         mvaldate  , .t.        , mdocref   , mdocref2  , mrefno   , mrefno2    ,;
										 @maddon  , @mudi      ,;
                                         @mnotfctn , @mcolexion , @mrecourse, @mobligor , @mcolatrl, @mtrantype ,;
                                         mslv      , macctno    , @munit2   ,  ,@mnerate ,@mappval ,,           ,;
										 @mwtax    , @mudiamt   , @mdtlcode , @mdtlcode2), n } ) )

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function amstupdate(mwhat)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   memvar  g_sys_name, g_user_id, mtrandate, ax_level
   local mpayfreqchoices := { '1 = MONTHLY    ', '2 = BI-MONTHLY ', '3 = QUARTERLY  ',;
			      '4 = SEMI-ANNUAL', '5 = ANNUAL     ', '6 = LUMPSUM    ', '7 = IRREGULAR  ' }
   local misupdated := .f., macctno, mrecno := Acctwait->( recno() ), msavethem, mfcltycode
   local mdocref, mrefno, mvaldate, mcondate, mclntcode, msurety1, msurety2, maocode
   local mcltrltype, mpaymode, munitcode, mrevfreq, mcredtype, mcurrcode, morixunit, mstat
   local mdocref2, mrefno2,mproceed1:=0,mproceed2:=0
   local mcontinue := .t., mcursor := setcursor(), getlist := {}, mleft := 22, mrayt := 61
   local mdocrefchoices  := assign_elements ( mdocrefchoices , 1 )
   local mfreqchoices    := assign_elements ( mfreqchoices   , 2 )
   local mpaymodechoices := assign_elements ( mpaymodechoices, 3 )
   local mrevchoices     := assign_elements ( mrevchoices    , 4 )
   local mstatchoices    := assign_elements ( mstatchoices   , 5 )
   local munit , mdlrcode,mponum   ,mpurcamt,munitloca,mprincipal,mpaytype ,mgd
   local mrv   , mterm   ,mtermunit, mtruerate , mratetype, mfirstdue, mfactor
   local mamort, mcredamt,malir    , mpayfreq  , mmatdate , munit2, maddon, mudi
   local msalesrep, mdownpay , mincentive, mnotfctn , mcolexion, mrecourse,mnerate, mWTAX, mudiamt
   local mobligor, mcolatrl, mtrantype, misentered  := .f., mremarks, mslv := {}
   local ln_avlble := 0,xclntcd:='',xclntcd2:='',ln_avlble2:=0,mappval
   local cacctno , cdocref  , crefno   , cvaldate  , ccondate, cclntcode,;
         csurety1, csurety2 , caocode  , ccltrltype, cpaymode, cunitcode,;
         crevfreq, ccredtype, ccurrcode, corixunit , cremarks, cstat,;
         cdocref2, crefno2
   local  cfcltycode,  cmatdate ,  cunit     ,  cdlrcode ,  cponum   ,;
          cpurcamt  ,  cunitloca,  cprincipal,  cpaytype ,  cgd      ,;
          crv       ,  cterm    ,  ctermunit ,  ctruerate,  cratetype,;
          cfirstdue ,  cfactor  ,  camort    ,  ccredamt ,  calir    ,;
          cpayfreq  ,  caddon   ,  cudi      ,  csalesrep,  cdownpay ,;
          cincentive,  cnotfctn ,  ccolexion ,  crecourse,  cobligor ,;
          ccolatrl  ,  ctrantype,  cunit2    ,  cnerate  ,  cappval  ,;
		  cwtax
   local lvatincl
   local cbrcode := space(3),mbrcode := space(3), qlogic := .f.,  mDOSRI := ' '
   local mdtlcode, cdtlcode, mdtlcode2, cdtlcode2
   local mprnamt1 :=  mprnamt2 :=  mcrdamt1 := mcrdamt2 := 0
   local lref2 := .f.
   local mCRBAL := 0, mPRNBAL := 0
   local nUSDRATE := 0

   if ( upper( mwhat ) == chr(65),;
        Acctwait->( dbgoto( lastrec() + 1 ) ),;
        mwhat := chr(82) ;
      )

   center ( 24, 'w+/n', if( lower( mwhat ) == 'r', '® Edit Record ¯', '® Add Record ¯' ) )

   assign_header  (  @macctno , @mdocref  , @mrefno   , @mvaldate  , @mcondate  , @mclntcode,;
                     @msurety1, @msurety2 , @maocode  , @mcltrltype, @mpaymode  , @munitcode,;
                     @mrevfreq, @mcredtype, @mcurrcode, @nusdrate  , @morixunit , @mremarks, @mstat    ,;
                     @mdocref2, @mrefno2  , @lvatincl , @mbrcode   , @mDOSRI               ;
                  )

   mREMARKS := COLLMEM( 'AW_REM', RIGHT(mACCTNO,14), LEFT(mACCTNO,3) )        && RED 111505

   __crefno2 := mREFNO2

   lvatincl := .f.                 // VAT exclusive *pepe 2:41 PM 7/28/2008

   if lower(mwhat) == 'a'              // abb 05.01/2003

   *-- RED 112504 ---
      mBRCODE   := g_PAR_BRCH
      mACCTNO   := g_PAR_BRCH+RIGHT(mACCTNO,14)
      mCLNTCODE := g_PAR_BRCH+RIGHT(mCLNTCODE,7)
      mREFNO    := g_PAR_BRCH+RIGHT(mREFNO,5)
      mREFNO2   := g_PAR_BRCH+RIGHT(mREFNO2,5)
   *-----------------

   endif

   cacctno     := macctno
   cdocref     := mdocref
   crefno      := mrefno
   cvaldate    := mvaldate
   ccondate    := mcondate
   cclntcode   := mclntcode
   csurety1    := msurety1
   csurety2    := msurety2
   caocode     := maocode
   ccltrltype  := mcltrltype
   cpaymode    := mpaymode
   cunitcode   := munitcode
   crevfreq    := mrevfreq
   ccredtype   := mcredtype
   ccurrcode   := mcurrcode
   cusdrate    := nusdrate
   corixunit   := morixunit
   cremarks    := mremarks
   //cstat       := mstat                 //used for restriction of editing after AVAILMENT SHEET is printed
   cstat       := space(1)                //disable restriction of editing after AVAILMENT SHEET is printed
   cdocref2    := mdocref2
   crefno2     := mrefno2
   cbrcode     := mbrcode           // abb 10.14.2004


   assign_details ( @mfcltycode, @mmatdate , @munit     , @mdlrcode , @mponum   ,;
                    @mpurcamt  , @munitloca, @mprincipal, @mpaytype , @mgd      ,;
                    @mrv       , @mterm    , @mtermunit , @mtruerate, @mratetype,;
                    @mfirstdue , @mfactor  , @mamort    , @mcredamt , @malir    ,;
                    @mpayfreq  , @maddon   , @mudi      , @msalesrep, @mdownpay ,;
                    @mincentive, @mnotfctn , @mcolexion , @mrecourse, @mobligor ,;
                    @mcolatrl  , @mtrantype, @munit2    , @mnerate  , @mappval  ,;
					@mWTAX     , @mudiamt  , @mdtlcode  , @mdtlcode2    ;
                  )

   cfcltycode  := mfcltycode
   cmatdate    := mmatdate
   cunit       := munit
   cdlrcode    := mdlrcode
   cponum      := mponum
   cpurcamt    := mpurcamt
   cunitloca   := munitloca
   cprincipal  := mprincipal
   cpaytype    := mpaytype
   cgd         := mgd
   crv         := mrv
   cterm       := mterm
   ctermunit   := mtermunit
   ctruerate   := mtruerate
   cratetype   := mratetype
   cfirstdue   := mfirstdue
   cfactor     := mfactor
   camort      := mamort
   ccredamt    := mcredamt
   calir       := malir
   cpayfreq    := mpayfreq
   caddon      := maddon
   cudi        := mudi
   csalesrep   := msalesrep
   cdownpay    := mdownpay
   cincentive  := mincentive
   cnotfctn    := mnotfctn
   ccolexion   := mcolexion
   crecourse   := mrecourse
   cobligor    := mobligor
   ccolatrl    := mcolatrl
   ctrantype   := mtrantype
   cunit2      := munit2
   cnerate     := mnerate
   cappval     := mappval
   cwtax       := mWTAX
   cdtlcode    := mdtlcode
   cdtlcode2   := mdtlcode2

   *assign_slv     ( mslv,macctno )     // Stipulated Loss Value ! (May 16,1995)
   ASSIGN_SLV     ( mSLV,IF(LEN(mACCTNO) = 17, mACCTNO, g_PAR_BRCH+mACCTNO) )
   disprec        ()
   setcolor       ( 'gr+/b, w+/g,,, gr+/b' )

   do while mcontinue

      @ 04, mleft say if(mwhat == 'A',g_PAR_BRCH+'99999999999999',macctno ) ;
              pict '@R 999-9999-99999-99999'

      @ 04, mrayt+1 get mvaldate  ;
                    pict '@D'     ;
                    when ( eval ( {|| mvaldate := if (mwhat=='A',mtrandate,mvaldate),;
                                      .t. ;
                                  };
                                ) ;
                         ) ;
                    valid agetproceeds( @mprincipal,mwhat,cstat )

      @ 06, mleft get mdocref     ;
                  pict '@X'       ;
                  when  if ( (mwhat == 'A' .OR. mwhat == 'R' .and. empty(cstat) ) ,;
                             chkdocref ( mdocrefchoices, @mdocref, 6, mleft,.f.),;
                             .f. ;
                           );
                  valid Lastkey() == K_UP .or.  ;
                       ( !empty(mdocref)    .and. ;
                         ( mdocref $ '12' ) .and. ;
                         disp1111(mdocref, 6, mleft ) ;
                       )

      @ 07, mleft get mrefno      ;
                  pict '@R 999-99999';
                  when (mwhat == 'A' .OR. mwhat == 'R' .and. empty(cstat)) ;
                  valid Lastkey() == K_UP .or. ;
                        ( !empty(mrefno) .and. ;
                          IF( CURRBRCH( LEFT( mREFNO, 3)), .T., EVAL({|| mREFNO:=g_PAR_BRCH+SPACE(5), .F.}) ) .AND.;
                          check_refno(mdocref,@mrefno,mwhat,@mproceed1, @ln_avlble, @xclntcd,mprincipal,@mbrcode,1 , @mDOSRI,.F.,0,mdtlcode,mdtlcode2) ;
                        )


	  @ 10, mrayt+6 get mDOSRI    pict '@X' when .f.

      @ 09, mleft get  mclntcode ;
                  pict '@R 999-99-99999' ;
                  when if ( lastkey() != K_ESC ,;
                             eval( { ||  mclntcode := if(mwhat == 'A', xclntcd, mclntcode), chkclntcode ( @mclntcode, mdocref, mrefno, mwhat, 09, mleft, mbrcode ) }) , .f. );
                  VALID IF( CURRBRCH( LEFT( mCLNTCODE, 3) ), .T., EVAL({|| mCLNTCODE:=g_PAR_BRCH+SPACE(7), .F.}) )

      @ 11, mleft get msurety1  pict '@!'
      @ 12, mleft get msurety2  pict '@!'
      @ 13, mleft get maocode   pict '99999' when  if ( lastkey() != K_ESC ,;
                  chkaocode ( @maocode, mdocref, mrefno, 13, mleft, mbrcode ),;
                  .f. )

      //14, mleft get mcurrcode  pict '@X'   when EVAL({|| mcurrcode := 'P',.F.})
	  
	  @ 14, mleft get mcurrcode  pict '@X' when  if ( lastkey() != K_ESC ,;
                chkcurrency ( @mcurrcode, 14, mleft ), .f. )
				
      @ 14, mrayt+1 get nUSDRATE  ;
                    pict '99.99'     ;
                    when ( eval ( {||  if (alltrim(mcurrcode) =='$',.t.,.f.),;
                                      .t. ;
                                  };
                                ) ;
                         ) ;
                    valid round(nUSDRATE,2) > 0

      @ 16, mleft get mfcltycode   ;
                  pict '@R 999-99' ;
                  when if ( lastkey() != K_ESC,;
                  eval( {|| if( mwhat <> 'A' ,;
            checkref2( mdocref   , mrefno     , mdocref2  , mrefno2   ,;
                       mwhat     , @mproceed1 , @mproceed2, mbrcode   ,;
					   mfcltycode, mprincipal , mdtlcode  , mdtlcode2) ,;
                       nil) ,;
      chek_fcltycode( mwhat     , @mfcltycode, @munit    , @mdlrcode  ,;
                       @mponum   , @mpurcamt  , @munitloca, @mprincipal,;
                       @mpaytype , @mgd       , @mrv      , @mterm     ,;
                       @mtermunit, @mtruerate , @mratetype, @mfirstdue ,;
                       @mpayfreq , @mfactor   , @mamort   , @mcredamt  ,;
                       @malir    , @mmatdate  , @msalesrep, @mdownpay  ,;
                       @mincentive, mvaldate  , .f.       , mdocref    , mdocref2,;
                       mrefno    , mrefno2    , @maddon   , @mudi     , @mnotfctn  ,;
                       @mcolexion, @mrecourse , @mobligor , @mcolatrl  ,;
                       @mtrantype, @mslv      , macctno   , @munit2    ,;
                       mproceed1+mproceed2    , @mnerate  , @mappval   ,;
                       @mremarks , @mbrcode   , @mWTAX    , @mudiamt   ,;
					   @mdtlcode , @mdtlcode2 , cstat      ,;
					   @mCRBAL   , @mPRNBAL   , @lref2 ) ;
				   				   } ;
				 ) , .f. )


		  @ 06, mrayt+1 get mdocref2  ;
						pict '@X'     ;
						when lref2 .AND. Lastkey() <> K_ESC .and. EVAL({|| (chkdocref ( mdocrefchoices, @mdocref2, 6, mrayt+1,.t. ),qlogic:= .t.) ;
								}) ;
						valid Lastkey() == K_UP .or. ;
							  ( ( mdocref2 $ ' 12' ) .and. ;
								if (  !empty(mdocref2),;
									 disp1111(mdocref2,6,mrayt+1) ,;
									 .f. ;
								   ) ;
							  )

		  @ 07, mrayt+1 get mrefno2   ;
				  pict '@R 999-99999' ;
				  when lref2 .AND. Lastkey() <> K_ESC ;
				  valid  (Lastkey() == K_UP .or. ;
						( if ( !empty(mrefno2),;
							   ( IF( CURRBRCH( LEFT( mREFNO2, 3)), .T., EVAL({|| mREFNO2:=g_PAR_BRCH+SPACE(5), .F.}) ) .AND.;
							   getfclty( mWHAT,@mfcltycode,16,2,mrefno,mprincipal,mcredamt,mdocref,mdocref2,mrefno2,mdtlcode,@mdtlcode2,mCRBAL,mPRNBAL,;
                                         @mcrdamt1,@mcrdamt2,@mprnamt1,@mprnamt2,@xclntcd2,@ln_avlble2 ) ),;
							   .f. ;
							 ) .and. ;
						  if ( !empty(mrefno2),;
							   if( mdocref == mdocref2,;
								   if ( mrefno == mrefno2,;
										.f.,;
										.t. ;
									  ),;
								   .t. ;
								 ),;
							   .f. ;
							 ) .and. ;
						chkgrp( xclntcd, xclntcd2,mdocref2,cstat,mwhat ) ) .and. ;
						   if ((mwhat == 'R' .and. empty(cstat)) .OR. mwhat <> 'R',    if ( ln_avlble + ln_avlble2 < mprincipal,;
							 eval( { || Error('Net Proceeds exceed Remaining Line..!!! ') ,.f.}), .t. ) ,.t.) )

      @ 17, mleft get mprincipal pict '999,999,999.99' when .f.
      @ 18, mleft get mterm      pict '@X'             when .f.
      @ 17, mrayt get mtruerate  pict '99.9999'        when .f.
      @ 18, mrayt get mcredtype  pict '@X'             when .f.

      @ 19, mleft get lvatincl   when  lastkey() != K_ESC .and. ;
                                       eval ({ || setcursor(3),.t. }) ;
                                 pict 'N'

      @ 20, mleft get mpaymode   pict '@X'       ;
                  when lastkey() != K_ESC .and. ;
                       if(  !empty(mfcltycode) ,;
                            chkpaymode ( mpaymodechoices , @mpaymode , 20, mleft ),;
                            .f. ;
                         )

      @ 21, mleft get mrevfreq   ;
                  pict '@X'      ;
                  when  lastkey() != K_ESC .and. ;
                        if( mratetype == '2',;
                           .t.,;
                           eval({|| mrevfreq:='4',;
                                    displrevpreq( mrevfreq,21,24,'w/b'),;
                                    .f. ;
                               })) ;
                         .and. if( mratetype <> '1'   .and. ;
                                   lastkey() != K_ESC .and. ;
                                   !empty(mfcltycode),;
                                   chkreviewfreq ( mrevchoices, @mrevfreq, 21, mleft ),;
                                   .f. ;
                                 )

      @ 20, mrayt+2 get mpayfreq ;
                    pict '@X'    ;
                    when if( lastkey() != K_ESC, chkpayfreq( mpayfreqchoices, @mpayfreq, 20, mrayt + 2 ), .f. )

      setcursor ( 3 )
      read
      setcursor ( 0 )

      if lastkey() == K_ENTER

         if mremarks != Nil .and. !empty(mfcltycode)

            devpos( 21, mrayt + 2 )
            devout( "< Memo >", 'gr+/b' )

            if Facility->Setcode == '3'
               memo0300m ( @mremarks , "R", .f.,.t. )
            else
               memo ( @mremarks , "R", .f.,.t. )
            endif

         endif

      endif

      if lastkey() == K_ESC
         if esckey()
            Acctwait-> ( dbgoto ( mrecno ) )
            exit
         else
            loop
         endif
      endif

      if confirm( 'Are all entries correct?')
	  
         acctno_generate ( @macctno, mwhat ) //ÄÄÄ PLUS one to parameter table
		 
         if ( mwhat == 'A',;
              macctno := stuff ( macctno, 8, 5, mfcltycode ),;
              nil ;
            )

         SAVEMEM( mREMARKS, 'AW_REM', RIGHT(mACCTNO,14), cBRCODE )

         if netlock ( mwhat, 0 )

			if !qlogic .and. mWHAT == 'A' //  for a more filtered saving of refno2 and docref2 RLV 5:16 PM 12/22/2008
				mdocref2 := ' '
				mrefno2  := ' '
			endif
			
            save_header( macctno  , mdocref  , mrefno  , mvaldate  , mcondate, mclntcode,;
               msurety1, msurety2 , maocode  , mcltrltype, mpaymode, munitcode,;
               mrevfreq, mcredtype, mcurrcode, nUSDRATE, morixunit , mremarks, mstat, mdocref2, ;
			   mrefno2 , lvatincl , mbrcode  , mDOSRI  , lref2)

            save_details ( mfcltycode, mmatdate , munit, mdlrcode, mponum          ,;
                           mpurcamt  , munitloca, mprincipal, mpaytype, mgd, mrv   ,;
                           mterm     , mtermunit, mtruerate , mratetype, mfirstdue ,;
                           mfactor   , mamort   , mcredamt  , malir    , mpayfreq  ,;
                           maddon    , mudi     , msalesrep , mdownpay , mincentive,;
                           mnotfctn  , mcolexion, mrecourse , mobligor , mcolatrl  ,;
                           mtrantype , munit2   , mnerate   , mappval  , mWTAX     ,;
						   mudiamt   , mdtlcode , mdtlcode2 , mrefno   , mrefno2   ,;
						   mdocref   , mdocref2 , macctno   , mcrdamt1 , mcrdamt2  ,;
                           mprnamt1	 , mprnamt2 , lref2 ;
                         )

            *save_slv( mslv,macctno )
            SAVE_SLV( mSLV,IF(LEN(mACCTNO) = 17, mACCTNO, g_PAR_BRCH+mACCTNO) )

            misupdated := .t.

            if Acctdrop->(dbseek(Acctwait->brcode+Acctwait->acctno+dtos(Acctwait->valdate))) 
               do while Acctdrop->acctno == Acctwait->acctno .and. ;
                        Acctdrop->brcode == Acctwait->brcode .and. ;
                        Acctdrop->date   == Acctwait->valdate
                  if Acctdrop->(netlock('R',0))
                     Acctdrop->(dbdelete())
                     Acctdrop->(dbunlock())
                  endif
                  Acctdrop->(dbseek(Acctwait->brcode+Acctwait->acctno+dtos(Acctwait->valdate))) 
               enddo
               Acctdrop->(dbcommit())
            endif

            __ncredamt := 0
            __namort   := 0

            if mwhat == 'A'
               drop  ( alltrim(g_user_id)+' '+'Adds acctno(avail.) ' + substr(macctno,-5,5) )
            else
                  ******
                  ******           HEADER
                  ******
                  if cacctno    != macctno
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5) )
                  endif

                  if cdocref    != mdocref
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'mdocref' )
                  endif

                  if crefno     != mrefno
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'mrefno' )
                  endif

                  if cvaldate   != mvaldate
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'mvaldate' )
                  endif

                  if ccondate   != mcondate
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'mcondate' )
                  endif

                  if cclntcode  != mclntcode
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'mclntcode' )
                  endif

                  if csurety1   != msurety1
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'msurety1' )
                  endif

                  if csurety2   != msurety2
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'msurety2' )
                  endif

                  if caocode    != maocode
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'maocode' )
                  endif

                  if ccltrltype != mcltrltype
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'mcltrltype' )
                  endif

                  if cpaymode   != mpaymode
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'mpaymode' )
                  endif

                  if cunitcode  != munitcode
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'munitcode' )
                  endif

                  if crevfreq   != mrevfreq
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'crevfreq'+crevfreq+'#'+mrevfreq )
                  endif

                  if ccredtype  != mcredtype
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'ccredtype'+ccredtype+'#'+mcredtype )
                  endif

                  if ccurrcode  != mcurrcode
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'ccurrcode'+ccurrcode+'#'+mcurrcode )
                  endif
				  
                  if round(cusdrate,2)   != round(nusdrate,2)
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'cusdrate'+str(cusdrate)+'#'+str(nusdrate) )
                  endif

                  if corixunit  != morixunit
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'morixunit' )
                  endif

                  if cremarks   != mremarks
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'mremarks' )
                  endif

                  if cstat      != mstat
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'mstat' )
                  endif

                  if cdocref2   != mdocref2
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'mdocref2' )
                  endif

                  if crefno2    != mrefno2
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'mrefno2' )
                  endif
                  ******
                  ******           DETAILS
                  ******
                  if cfcltycode  != mfcltycode
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'mfcltycode'+cfcltycode+'#'+mfcltycode )
                  endif

                  if cmatdate    != mmatdate
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'mmatdate'+dtoc(cmatdate)+'#'+dtoc(mmatdate) )
                  endif

                  if cunit       != munit
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'cunit'+alltrim(cunit)+'#'+alltrim(munit) )
                  endif

                  if cdlrcode    != mdlrcode
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'cdlrcode'+cdlrcode+'#'+mdlrcode )
                  endif

                  if cponum      != mponum
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'cponum'+cponum+'#'+mponum )
                  endif

                  if round(cpurcamt,2)    != round( mpurcamt,2 )
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'cpurcamt'+str(round(cpurcamt,2))+'#'+str(round(cpurcamt,2)) )
                  endif

                  if cunitloca   != munitloca
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'cunitloca'+alltrim(cunitloca)+'#'+alltrim(munitloca) )
                  endif

                  if round ( cprincipal,2)  != round(mprincipal,2)
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'cprincipal'+str(cprincipal)+'#'+str(mprincipal) )
                  endif

                  if cpaytype    != mpaytype
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'cpaytype'+cpaytype+'#'+mpaytype )
                  endif

                  if round(cgd,2) != round(mgd,2)
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'cgd'+str(cgd)+'#'+str(mgd) )
                  endif

                  if round ( crv,2) != round(mrv,2)
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'crv'+str(crv)+'#'+str(mrv) )
                  endif

                  if round (cterm,2) != round( mterm,2)
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'cterm'+str(cterm)+'#'+str(mterm) )
                  endif

                  if ctermunit   != mtermunit
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'ctermunit'+ctermunit+'#'+mtermunit )
                  endif

                  if round ( ctruerate,2)   != round( mtruerate,2)
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'ctruerate'+str(ctruerate)+'#'+str(mtruerate) )
                  endif

                  if cratetype   != mratetype
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'mratetype'+cratetype+'#'+mratetype )
                  endif

                  if cfirstdue   != mfirstdue
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'cfirstdue'+dtoc(cfirstdue)+'#'+dtoc(mfirstdue) )
                  endif

                  if round(cfactor,2) != round(mfactor,2)
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'mfactor'+str(cfactor)+'#'+str(mfactor) )
                  endif

                  if round ( camort,2)   != round(mamort,2)
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'camort'+str(camort)+'#'+str(mamort) )
                  endif

                  if round(ccredamt,2) != round(mcredamt,2)
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'mcredamt'+str(ccredamt)+'#'+str(mcredamt) )
                  endif

                  if round(calir,2)  != round(malir,2)
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'calir'+str(calir)+'#'+str(malir) )
                  endif

                  if cpayfreq    != mpayfreq
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'cpayfreq'+cpayfreq+'#'+mpayfreq )
                  endif

                  if round(caddon,2) != round(maddon,2)
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'caddon'+str(caddon)+'#'+str(maddon) )
                  endif

                  if round(cudi,2) != round(mudi,2)
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'cudi'+str(cudi)+'#'+str(mudi) )
                  endif

                  if csalesrep != msalesrep
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'csalesrep'+csalesrep+'#'+msalesrep )
                  endif

                  if round(cdownpay,2) != round(mdownpay,2)
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'cdownpay'+str(cdownpay)+'#'+str(mdownpay) )
                  endif

                  if round(cincentive,2) != round(mincentive,2)
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'cincentive'+str(cincentive)+'#'+str(mincentive) )
                  endif

                  if cnotfctn    != mnotfctn
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'cnotfctn'+cnotfctn+'#'+mnotfctn )
                  endif

                  if ccolexion   != mcolexion
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'ccolexion'+ccolexion+'#'+mcolexion )
                  endif

                  if crecourse   != mrecourse
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'crecourse'+crecourse+'#'+mrecourse )
                  endif

                  if cobligor    != mobligor
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'cobligor'+cobligor+'#'+mobligor )
                  endif

                  if ccolatrl    != mcolatrl
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'ccolatrl'+ccolatrl+'#'+mcolatrl )
                  endif

                  if ctrantype != mtrantype
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'ctrantype'+ctrantype+'#'+mtrantype )
                  endif

                  if cunit2 != munit2
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'cunit2'+alltrim(cunit2)+'#'+alltrim(munit2) )
                  endif

                  if round(cnerate,2) != round(mnerate,2)
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'cnerate'+str(cnerate)+'#'+str(mnerate) )
                  endif

                  if cappval     != mappval
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'cappval'+str(cappval)+'#'+str(mappval) )
                  endif

                  if round(cwtax,2) != round(mWTAX,2)
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'cwtax'+str(cwtax)+'#'+str(mWTAX) )
                  endif

                  if cdtlcode != mdtlcode
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'cdtlcode'+cdtlcode+'#'+mdtlcode )
                  endif

                  if cdtlcode2 != mdtlcode2
                     drop  ( alltrim(g_user_id)+' '+'Edits acctno(avail.) '+ substr(macctno,-5,5)+'cdtlcode2'+cdtlcode2+'#'+mdtlcode2 )
                  endif
            endif

         endif

         Acctwait->( dbunlock() )
         Acctwait->( dbcommit() )
         mcontinue := .f.
      endif
   enddo
   center ( 24, 'w+/n', '                          '  )
   return ( misupdated )



***************************************************************************************************************************************************************
static function getfclty( mWHAT, mfcltycode, mrow, mcol, mrefno, mprincipal, mcredamt, mdocref, mdocref2, mrefno2, mdtlcode, mdtlcode2, mCRBAL, mPRNBAL,;
                          mcrdamt1, mcrdamt2, mprnamt1, mprnamt2, xclntcd2,ln_avlble2 )
***************************************************************************************************************************************************************
   local mc := setcolor(), mscr := savescreen ( ,,, ), mfclty := .T., mntx := Acctwait->(indexord())
   local mrecno := Acctwait->(recno()), mrecno2 := 0, lPASS := .T., mok := .f.

   center  ( 24, 'w+/n', '® Search Facility ¯' )

   while .t.

	  //Get_Facility(mrefno,@mfcltycode,@mfclty,@mrecno,@mdtlcode,"DOCUMENT REFERENCE I")

	  //Cadetail->( dbgoto( mrecno ) )

	  if !empty(mdocref2)
	  
	      IF mdocref2 == '1'
		      if !empty(right(mrefno2,5))
 	             Get_Facility(mrefno2,mfcltycode,@mfclty,@mrecno2,@mdtlcode2,"DOCUMENT REFERENCE II",mdocref2)
		         Cadetail->( dbgoto( mrecno2 ) )
			  else
			     error('Invalid reference number!')
		         lPASS := .f.
			     return mok
			  endif
		  
		      if Cadetail->fcltycode <> mfcltycode
		         error('Invalid facility code!')
		         lPASS := .f.
			     return mok
		      endif
		  
          ELSE
		  
		       if OTICKET->(dbseek(mrefno2))
	              mfclty2      := OTICKET->fcltycode	   
			   endif
 
                if upper(mWHAT) == 'A'
				
					//******pepe 4:32 PM 12/8/2011
					msg := acctwait->(indexord())
					acctwait->(dbsetorder(5))
					if Acctwait->(dbseek(mREFNO2+mdocref2))  // Acctwait->(indexkey())) should be BRCODE+REFNO
					   alert ( 'CANNOT ACCEPT MORE THAN ONE AVAILMENT FOR OFFERING TICKETS' )
					   lPASS := .f.
					   return mok
					endif

					acctwait->(dbsetorder(6))
					if Acctwait->(dbseek(mREFNO2+mdocref2))
					   alert ( 'CANNOT ACCEPT MORE THAN ONE AVAILMENT FOR OFFERING TICKETS' )
					   lPASS := .f.
					   return mok
					endif
					acctwait->(dbsetorder(msg))
					//******

					__cACTNTX := Acctmast->(indexord())
					Acctmast->(dbsetorder(6))
					if Acctmast->(dbseek(mREFNO2+mdocref2)) .and. Acctmast->status != '0'
					   alert ( 'OTNUMBER '+Oticket->OTNUMBER+' ALREADY ASSIGNED TO ACCT. #'+trans( Acctmast->brcode+Acctmast->ACCTNO,'@R 999-9999-99999-99999' ) )
					   lPASS := .f.
					   return mok
					endif

					Acctmast->(dbsetorder(7))
					if Acctmast->(dbseek(mREFNO2+mdocref2)) .and. Acctmast->status != '0'
					   alert ( 'OTNUMBER '+Oticket->OTNUMBER+' ALREADY ASSIGNED TO ACCT. #'+trans( Acctmast->brcode+Acctmast->ACCTNO,'@R 999-9999-99999-99999' ) )
					   lPASS := .f.
					   return mok
					endif
				   
					Acctmast->(dbsetorder(__cACTNTX))     
					
			   endif

		       if OTICKET->fcltycode <> mfcltycode
		          error('Invalid facility code!')
		          lPASS := .f.
			      return mok
		       endif

		  ENDIF
		  

	  else
	     //if Cadetail->PRINCIPAL < mprincipal .and. !Cadetail->INCLUDE
			lPASS := .f.
			ERROR('Document reference not found!')
		 //endif
	  endif

      if lastkey() != K_ESC

		 If lPASS
			 if !mfclty
				error ( 'Facility Code not Found in CA!' )
			 else

			    if mdocref2 == '1'
						Cadetail->( dbgoto( mrecno2 ) )
						Caheader->(dbseek(Cadetail->brcode + Cadetail->canumber))

						IF chk_osbal2(mWHAT,mrefno,mprincipal,mcredamt,mdocref,mfcltycode,mdocref2,mrefno2,mdtlcode2,mCRBAL,mPRNBAL,;
												   @mcrdamt1,@mcrdamt2,@mprnamt1,@mprnamt2,@ln_avlble2)
						//IF chck_refno2(mdocref,mdocref2,mrefno,@mrefno2,mwhat,@mproceed2,@ln_avlble2,@xclntcd2,mprincipal,@mbrcode,2,,.T.,@mproceed1,;
						//			               mdtlcode,mdtlcode2,mfcltycode,mcredamt,@mcrdamt1,@mcrdamt2,@mprnamt1,@mprnamt2)
						   //error ( 'CA line fully availed!' )
						ELSE
						   if mrecno2 > 0
							  Cadetail->( dbgoto( mrecno2 ) )
							  xclntcd2 := Caheader->brcode + Caheader->clntcode
							  mok := .t.
							  exit
						   else
							  error ( 'CA not found!' )
						   endif

						ENDIF
				else

						mActivPbal := OTICKET->PROCEEDS
						mActivCbal := OTICKET->CREDAMT

						//if round(mprincipal,2) > round(mActivPbal + mPRNBAL,2)
						  // lreturnval := .t.
						   //error ( 'Principal line exceeds available line!' )
						if round(mCREDAMT,2) > round(mActivCbal + mCRBAL,2)
						   lreturnval := .t.
						   error ( 'Credit line exceeds available line!' )
						else
							IF mCREDAMT >= mCRBAL
							   mCRDAMT1  := mCRBAL
							   mCRDAMT2  := round(mCREDAMT - mCRBAL,2)
							ELSE
							   mCRDAMT1  := mCRBAL
							   mCRDAMT2  := 0
							ENDIF
                        
							IF mprincipal >= mPRNBAL
							   mPRNAMT1  := mPRNBAL
							   mPRNAMT2  := round(mprincipal - mPRNBAL,2)
							ELSE
							   mPRNAMT1  := mPRNBAL
							   mPRNAMT2  := 0
							ENDIF
							
							ln_avlble2 := mActivPbal
							xclntcd2 := OTICKET->brcode + OTICKET->clntcode
						    mok := .t.
							exit
						endif
				
				endif

			 endif
		 //Else
		     //ERROR('Facility fully availed!')
		 EndIf
      else
         exit
      endif
   enddo

   Acctwait-> ( dbsetorder(mntx) )
   Acctwait-> (dbgoto(mrecno))

   setcolor ( mc )
   restscreen ( ,,,, mscr )
return mok

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   Static Function chk_osbal2(mWHAT,mrefno,mprincipal,mcredamt,mdocref,mfcltycode,mdocref2,mrefno2,mdtlcode,mCRBAL,mPRNBAL,;
                                                      mcrdamt1,mcrdamt2,mprnamt1,mprnamt2,ln_avlble2)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
local lreturnval := .f., mn := ACCTMAST->(indexord()), mo := Acctwait->(indexord()), mp := Caheader->(indexord())
local mCLNTCD := SPACE(7), lTRUE := .F.
local arr_refno := {}
local lfclty := .f., mrecno
//local mprnamt1 := mprnamt2 := 0
local mBAL := 0, mBAL2 := 0, CR_AMT := 0, PRN_AMT := 0
local mActivPmain := 0       //PRINCIPAL of selected facility 
local mActivCmain := 0       //CREDAMT of selected facility
local mActivPbal := 0         //total PRINCIPAL availed within selected facility
local mActivCbal := 0         //total CREDAMT availed within selected facility
local linclude := .f.

   If PURCHASE->(DBSEEK(mfcltycode)) .or. CADETAIL->TRANTYPE == '1' //revolving
   
	   IF CAHEADER->(DBSEEK(mrefno2))
		  mCLNTCD := CAHEADER->BRCODE+CAHEADER->CLNTCODE
	   ENDIF

	   ACCTWAIT->( dbsetorder(4) )
	   ACCTMAST->( dbsetorder(2) )
	   GRPMEMBR->(DBSETORDER(2))
	   CAHEADER->(DBSETORDER(3))

	   IF GRPMEMBR->(DBSEEK(mCLNTCD))
		  cGRPCD := GRPMEMBR->BRCODE+GRPMEMBR->GRUPCODE
		  lTRUE := .T.
	   ENDIF

	   GRPMEMBR->(DBSETORDER(1))
	   IF lTRUE

		   GRPMEMBR->(DBSEEK(cGRPCD))
		   DO WHILE GRPMEMBR->BRCODE+GRPMEMBR->GRUPCODE == cGRPCD.AND. ;
				   !GRPMEMBR->(EOF())

                grp_acctno := GRPMEMBR->BRCODE2+GRPMEMBR->CLNTCODE

		   GRPMEMBR->(DBSKIP())
		   ENDDO
		   
				if CAHEADER->(DBSEEK(grp_acctno))
				   DO WHILE CAHEADER->BRCODE + CAHEADER->CLNTCODE == grp_acctno .and. ;
				           !CAHEADER->(eof())
					   IF CAHEADER->ACTAKEN == '3'
						   CADETAIL->(DBSEEK(CAHEADER->BRCODE+CAHEADER->CANUMBER+left(mdtlcode,2)))
							   DO WHILE CADETAIL->BRCODE+CADETAIL->CANUMBER == CAHEADER->BRCODE+CAHEADER->CANUMBER .AND. ;
							                   LEFT(CADETAIL->DTLCODE,2) ==  LEFT(mdtlcode,2)                                                             .AND. ;
									          !CADETAIL->(EOF())
											  
									   IF CADETAIL->CANUMBER == right(mrefno2,5)
									       if CADETAIL->INCLUDE .and. left(CADETAIL->dtlcode,2) == left(mDTLCODE,2)
									            PRN_AMT := CADETAIL->PRINCIPAL
												CR_AMT   := CADETAIL->CREDAMT
												linclude := .t.
										   endif
										   
										  IF CADETAIL->DTLCODE == mdtlcode
											 mActivPmain    += CADETAIL->PRINCIPAL
											 mActivCmain    += CADETAIL->CREDAMT
											 //mCRBAL  += CADETAIL->CREDAMT
											 //mPRNBAL += CADETAIL->PRINCIPAL
										  //ELSE
											 //mBAL2   += CADETAIL->PRINCIPAL
										  ENDIF
										  
										  /**
										   IF PURCHASE->(DBSEEK(CADETAIL->FCLTYCODE)) .AND. CADETAIL->DTLCODE == mdtlcode
										        mActivPmain    += CADETAIL->PRINCIPAL
												mActivCmain    += CADETAIL->CREDAMT
											    //CR_AMT  += CADETAIL->CREDAMT
										   ELSE
											    mBAL2   += CADETAIL->PRINCIPAL
										   ENDIF
										   **/
									   ENDIF
							   CADETAIL->(DBSKIP())
							   ENDDO
					   ENDIF

				   CAHEADER->(DBSKIP())
				   ENDDO
				EndIf



		   GRPMEMBR->(DBSEEK(cGRPCD))
		   DO WHILE GRPMEMBR->BRCODE+GRPMEMBR->GRUPCODE == cGRPCD.AND. ;
				   !GRPMEMBR->(EOF())

			   ACCTMAST->( dbseek(GRPMEMBR->BRCODE2+GRPMEMBR->CLNTCODE) )
			   Do While ACCTMAST->BRCODE+ACCTMAST->CLNTCODE == GRPMEMBR->BRCODE2+GRPMEMBR->CLNTCODE .and. ;
					   !ACCTMAST->(eof())
				  If ACCTMAST->status <> '0'
					 //IF PURCHASE->(DBSEEK(SUBS(ACCTMAST->ACCTNO,5,5))) 
					     //If  ACCTMAST->DTLCODE == mdtlcode .OR. ACCTMAST->DTLCODE2 == mdtlcode
					If left(ACCTMAST->dtlcode,2) == left(mDTLCODE,2) .or. left(ACCTMAST->dtlcode2,2) == left(mDTLCODE,2)	 
					    if empty(ACCTMAST->docref2)
			                if ACCTMAST->dtlcode == mDTLCODE
			                     mActivPbal += ACCTMAST->Principal
								 mActivCbal += ACCTMAST->OSBAL
			                endif
					        PRN_AMT    -= ACCTMAST->PRINCIPAL
					        CR_AMT  -= ACCTMAST->OSBAL
						else
							if Refernce->(dbseek(ACCTMAST->brcode+ACCTMAST->Refno+ACCTMAST->dtlcode+ACCTMAST->acctno))
			                   if ACCTMAST->dtlcode == mDTLCODE
			                        mActivPbal += Refernce->PRNAMNT1
									mActivCbal += Refernce->CREDAMT1
			                   endif
							   PRN_AMT    -= Refernce->PRNAMNT1
							   CR_AMT  -= Refernce->CREDAMT1
							else
							   Refernce->(dbsetorder(2))
								if Refernce->(dbseek(ACCTMAST->brcode+ACCTMAST->Refno2+ACCTMAST->dtlcode2+ACCTMAST->ACCTNO))
			                       if ACCTMAST->dtlcode2 == mDTLCODE
			                            mActivPbal += Refernce->PRNAMNT2
										mActivCbal += Refernce->CREDAMT2
			                       endif								
								   PRN_AMT    -= Refernce->PRNAMNT2
								   CR_AMT  -= Refernce->CREDAMT2
								endif
							endif
						endif 
						//EndIf
					 //ELSE
						//IF RIGHT(mrefno,5) == ACCTMAST->REFNO .and. ACCTMAST->DOCREF == '1' .or. RIGHT(mrefno,5) == ACCTMAST->REFNO2 .and. ACCTMAST->DOCREF2 == '1'
						   //PRN_AMT   -= ACCTMAST->PRINCIPAL
						//ENDIF
					ENDIF
				  EndIF
			   ACCTMAST->(dbskip())
			   EndDo

		   GRPMEMBR->(DBSKIP())
		   ENDDO

	   ELSE

		   IF CAHEADER->(DBSEEK(mCLNTCD))
			  DO WHILE CAHEADER->BRCODE + CAHEADER->CLNTCODE == mCLNTCD .and. ;
				      !CAHEADER->(eof())
				  IF CAHEADER->ACTAKEN == '3'
					 CADETAIL->(DBSEEK(CAHEADER->BRCODE+CAHEADER->CANUMBER+left(mdtlcode,2)))
					 DO WHILE CADETAIL->BRCODE+CADETAIL->CANUMBER == CAHEADER->BRCODE+CAHEADER->CANUMBER .AND. ;
					                 LEFT(CADETAIL->DTLCODE,2) == LEFT(mdtlcode,2)                                                              .AND. ;
							        !CADETAIL->(EOF())

						IF CADETAIL->CANUMBER == right(mrefno2,5)
						
                            if CADETAIL->include .and. left(CADETAIL->dtlcode,2) == left(mDTLCODE,2)
			                     PRN_AMT := CADETAIL->PRINCIPAL
								 CR_AMT  := CADETAIL->CREDAMT
								 linclude := .t.
			                endif
							
							
						   IF CADETAIL->DTLCODE == mdtlcode
							  mActivPmain    += CADETAIL->PRINCIPAL
							  mActivCmain    += CADETAIL->CREDAMT
							  //mCRBAL  += CADETAIL->CREDAMT
							  //mPRNBAL += CADETAIL->PRINCIPAL
						   //ELSE
							  //mBAL2   += CADETAIL->PRINCIPAL
						   ENDIF
						   /***
						   IF PURCHASE->(DBSEEK(CADETAIL->FCLTYCODE)) .AND. CADETAIL->DTLCODE == mdtlcode
                                mActivPmain    += CADETAIL->PRINCIPAL
								mActivCmain    += CADETAIL->CREDAMT
							    //CR_AMT  += CADETAIL->CREDAMT
						   ELSE

							  mBAL2   += CADETAIL->PRINCIPAL

						   ENDIF
						   ***/
						ENDIF
					 CADETAIL->(DBSKIP())
					 ENDDO
				  ENDIF
			  CAHEADER->(DBSKIP())
			  ENDDO
		   ENDIF

		   ACCTMAST->( dbseek(mCLNTCD) )

		   Do While ACCTMAST->BRCODE+ACCTMAST->CLNTCODE == mCLNTCD .and. ;
				   !ACCTMAST->(eof())
			  If ACCTMAST->status <> '0'
					 //IF PURCHASE->(DBSEEK(SUBS(ACCTMAST->ACCTNO,5,5))) 
					 If left(ACCTMAST->dtlcode,2) == left(mDTLCODE,2) .or. left(ACCTMAST->dtlcode2,2) == left(mDTLCODE,2)
					     //If  ACCTMAST->DTLCODE == mdtlcode .OR. ACCTMAST->DTLCODE2 == mdtlcode
					    if empty(ACCTMAST->docref2)
			                if ACCTMAST->dtlcode == mDTLCODE
			                     mActivPbal += ACCTMAST->Principal
								 mActivCbal += ACCTMAST->OSBAL
			                endif
					        PRN_AMT    -= ACCTMAST->PRINCIPAL
					        CR_AMT  -= ACCTMAST->OSBAL
						else
							if Refernce->(dbseek(ACCTMAST->brcode+ACCTMAST->Refno+ACCTMAST->dtlcode+ACCTMAST->ACCTNO))
			                   if ACCTMAST->dtlcode == mDTLCODE
			                        mActivPbal += Refernce->PRNAMNT1
									mActivCbal += Refernce->CREDAMT1
			                   endif
							   PRN_AMT    -= Refernce->PRNAMNT1
							   CR_AMT  -= Refernce->CREDAMT1
							else
							   Refernce->(dbsetorder(2))
								if Refernce->(dbseek(ACCTMAST->brcode+ACCTMAST->Refno2+ACCTMAST->dtlcode2+ACCTMAST->ACCTNO))
			                       if ACCTMAST->dtlcode2 == mDTLCODE
			                            mActivPbal += Refernce->PRNAMNT2
										mActivCbal += Refernce->CREDAMT2
			                       endif								
								   PRN_AMT    -= Refernce->PRNAMNT2
								   CR_AMT  -= Refernce->CREDAMT2
								endif
							endif
						endif 
						//EndIf
					 //ELSE
						//IF RIGHT(mrefno,5) == ACCTMAST->REFNO .and. ACCTMAST->DOCREF == '1' .or. RIGHT(mrefno,5) == ACCTMAST->REFNO2 .and. ACCTMAST->DOCREF2 == '1'
						   //PRN_AMT   -= ACCTMAST->PRINCIPAL
						//ENDIF
					 ENDIF
			  EndIF
		   ACCTMAST->(dbskip())
		   EndDo
	   ENDIF

	   Acctwait->  ( dbsetorder(5) )
	   if Acctwait -> (dbseek(mrefno2+mdocref2))

		  Do While Acctwait->brcode + Acctwait->Refno  == mrefno2  .and. ;
				   Acctwait->Docref == mdocref2                    .and. ;
				  !Acctwait->(eof())
			/***
			 IF PURCHASE->(DBSEEK(SUBS(Acctwait->ACCTNO,5,5))) .AND. Acctwait->DTLCODE == mdtlcode
			 
			    if empty(Acctwait->Docref2)
			         if Acctwait->dtlcode == mDTLCODE
			              mActivPbal += Acctwait->Principal
						  mActivCbal += Acctwait->CREDAMT
			         endif	
					 PRN_AMT    -= Acctwait->Principal
					 CR_AMT  -= Acctwait->CREDAMT
				else
					if Refernce->(dbseek(Acctwait->brcode+Acctwait->Refno+Acctwait->dtlcode))
			             if Acctwait->dtlcode == mDTLCODE
			                  mActivPbal += Refernce->PRNAMNT1
							  mActivCbal += Refernce->CREDAMT1
			             endif	
					     PRN_AMT    -= Refernce->PRNAMNT1
					     CR_AMT  -= Refernce->CREDAMT1
					endif
				endif
				
			 ELSE
			 ***/
			 if Acctwait->brcode + Acctwait->ACCTNO <> macctno .AND. left(Acctwait->dtlcode,2) == left(mDTLCODE,2) 
			    if empty(Acctwait->Docref2)
			         if Acctwait->dtlcode == mDTLCODE
			              mActivPbal += Acctwait->Principal
						  mActivCbal += Acctwait->CREDAMT
			         endif	
					 PRN_AMT    -= Acctwait->Principal
					 CR_AMT  -= Acctwait->CREDAMT
				else
					if Refernce->(dbseek(Acctwait->brcode+Acctwait->Refno+Acctwait->dtlcode+ACCTWAIT->ACCTNO))
				         if Acctwait->dtlcode == mDTLCODE
			                  mActivPbal += Refernce->PRNAMNT1
							  mActivCbal += Refernce->CREDAMT1
			             endif	
					     PRN_AMT    -= Refernce->PRNAMNT1
					     CR_AMT  -= Refernce->CREDAMT1
					endif
				endif
			 endif
			 //ENDIF
		  Acctwait ->(DBSKIP())
		  ENDDO

	   endif

	   Acctwait->  ( dbsetorder(6) )
	   if Acctwait -> (dbseek(mrefno2+mdocref2))

		  Do While Acctwait->brcode + Acctwait->Refno2  == mrefno2  .and. ;
				   Acctwait->Docref2 == mdocref2                    .and. ;
				  !Acctwait->(eof())
			 //IF PURCHASE->(DBSEEK(SUBS(Acctwait->ACCTNO,5,5))) .AND. Acctwait->DTLCODE2 == mdtlcode
			 if Acctwait->brcode + Acctwait->ACCTNO <> macctno .AND.  left(Acctwait->dtlcode2,2) == left(mDTLCODE,2) 
			 Refernce->(dbsetorder(2))
			    if Refernce->(dbseek(Acctwait->brcode+Acctwait->Refno2+Acctwait->dtlcode2+ACCTWAIT->ACCTNO))
			         if Acctwait->dtlcode2 == mDTLCODE
			              mActivPbal += Refernce->PRNAMNT2
						  mActivCbal += Refernce->CREDAMT2
			         endif	
				     PRN_AMT    -= Refernce->PRNAMNT2
				     CR_AMT  -= Refernce->CREDAMT2
				endif
			 endif
			 //ELSE
			 /***
			    if Refernce->(dbseek(Acctwait->brcode+Acctwait->Refno2+Acctwait->dtlcode2))
			         if Acctwait->dtlcode2 == mDTLCODE
			              mActivPbal += Refernce->PRNAMNT2
						  mActivCbal += Refernce->CREDAMT2
			         endif	
				     PRN_AMT    -= Refernce->PRNAMNT2
				     CR_AMT  -= Refernce->CREDAMT2
				endif
			  ***/
			 //ENDIF
		  Acctwait ->(DBSKIP())
		  ENDDO

	   endif

	   
		mActivPbal := round(mActivPmain - mActivPbal,2)
		mActivCbal := round(mActivCmain - mActivCbal,2)
		ln_avlble2 := mActivPbal
		
		if  mActivPbal > round(PRN_AMT,2)
			   if round(mprincipal,2) > round(PRN_AMT + mPRNBAL,2)
				  lreturnval := .t.
				  error ( 'Principal line exceeds available line!' )
			   elseif round(mCREDAMT,2) > round(CR_AMT + mCRBAL,2)
				  lreturnval := .t.
				  error ( 'Credit line exceeds available line!' )
			   else
					IF mCREDAMT >= mCRBAL
					   mCRDAMT1  := mCRBAL
					   mCRDAMT2  := round(mCREDAMT - mCRBAL,2)
					ELSE
					   mCRDAMT1  := mCRBAL
					   mCRDAMT2  := 0
					ENDIF

					IF mprincipal >= mPRNBAL
					   mPRNAMT1  := mPRNBAL
					   mPRNAMT2  := round(mprincipal - mPRNBAL,2)
					ELSE
					   mPRNAMT1  := mPRNBAL
					   mPRNAMT2  := 0
					ENDIF
			   endif
		else
			   if round(mprincipal,2) > round(mActivPbal + mPRNBAL,2)
				  lreturnval := .t.
				  error ( 'Principal line exceeds available line!' )
			   elseif round(mCREDAMT,2) > round(mActivCbal + mCRBAL,2)
				  lreturnval := .t.
				  error ( 'Credit line exceeds available line!' )
			   else
					IF mCREDAMT >= mCRBAL
					   mCRDAMT1  := mCRBAL
					   mCRDAMT2  := round(mCREDAMT - mCRBAL,2)
					ELSE
					   mCRDAMT1  := mCRBAL
					   mCRDAMT2  := 0
					ENDIF

					IF mprincipal >= mPRNBAL
					   mPRNAMT1  := mPRNBAL
					   mPRNAMT2  := round(mprincipal - mPRNBAL,2)
					ELSE
					   mPRNAMT1  := mPRNBAL
					   mPRNAMT2  := 0
					ENDIF
			   endif
		endif
		 
	   /***
       if round(mprincipal,2) > round(PRN_AMT + mPRNBAL,2)
		  lreturnval := .t.
	      error ( 'Principal line exceeds available line!' )
	   elseif round(mCREDAMT,2) > round(CR_AMT + mCRBAL,2)
		  lreturnval := .t.
	      error ( 'Credit line exceeds available line!' )
	   else
		    IF mCREDAMT >= mCRBAL
		       mCRDAMT1  := mCRBAL
		       mCRDAMT2  := round(mCREDAMT - mCRBAL,2)
			ELSE
		       mCRDAMT1  := mCRBAL
		       mCRDAMT2  := 0
			ENDIF

			IF mprincipal >= mPRNBAL
			   mPRNAMT1  := mPRNBAL
			   mPRNAMT2  := round(mprincipal - mPRNBAL,2)
			ELSE
			   mPRNAMT1  := mPRNBAL
			   mPRNAMT2  := 0
			ENDIF
	   endif
       ***/
	   
	   ACCTMAST->(dbsetorder(mn))
	   ACCTWAIT->(dbsetorder(mo))
	   CAHEADER->(dbsetorder(mp))
	   GRPMEMBR->(dbsetorder(2))

	   CAHEADER->(dbseek(mrefno2))
   ELSE

	  curr_dtlcd := CADETAIL->dtlcode

      if CADETAIL->(DBSEEK(mrefno2+left(mdtlcode,2)))

			 do while CADETAIL->brcode + CADETAIL->canumber == mrefno2 .and.;
							 LEFT(CADETAIL->DTLCODE,2)  == LEFT(mDTLCODE,2)          .and.;
							!CADETAIL->(eof())
					 
							 if CADETAIL->INCLUDE
								  PRN_AMT := CADETAIL->PRINCIPAL
								  CR_AMT   := CADETAIL->CREDAMT
								  linclude := .t.
							  endif
							  
							 if CADETAIL->DTLCODE == mDTLCODE
								  mActivPmain := CADETAIL->PRINCIPAL
								  mActivCmain := CADETAIL->CREDAMT
							 endif
			 CADETAIL->(dbskip())
			 enddo

			   Acctwait->  ( dbsetorder(5) )
			   if Acctwait -> (dbseek(mrefno2+mdocref2))

				  Do While Acctwait->brcode + Acctwait->Refno  == mrefno2  .and. ;
						   Acctwait->Docref == mdocref2                    .and. ;
						  !Acctwait->(eof())
                       if left(Acctwait->dtlcode,2) == left(mDTLCODE,2) 
						if empty(Acctwait->Docref2)
							 if Acctwait->dtlcode == mDTLCODE
								  mActivPbal += Acctwait->Principal
								  mActivCbal += Acctwait->CREDAMT
							 endif	
							 PRN_AMT    -= Acctwait->Principal
							 CR_AMT  -= Acctwait->CREDAMT
						else
							if Refernce->(dbseek(Acctwait->brcode+Acctwait->Refno+Acctwait->dtlcode+ACCTWAIT->ACCTNO))
								 if Acctwait->dtlcode == mDTLCODE
									  mActivPbal += Refernce->PRNAMNT1
									  mActivCbal += Refernce->CREDAMT1
								 endif	
								 PRN_AMT    -= Refernce->PRNAMNT1
								 CR_AMT  -= Refernce->CREDAMT1
							endif
						endif
					   endif

				  Acctwait ->(DBSKIP())
				  ENDDO

			   endif

			   Acctwait->  ( dbsetorder(6) )
			   if Acctwait -> (dbseek(mrefno2+mdocref2))

				  Do While Acctwait->brcode + Acctwait->Refno2  == mrefno2  .and. ;
						   Acctwait->Docref2 == mdocref2                    .and. ;
						  !Acctwait->(eof())
                       if left(Acctwait->dtlcode2,2) == left(mDTLCODE,2) 
						if Refernce->(dbseek(Acctwait->brcode+Acctwait->Refno2+Acctwait->dtlcode2+ACCTWAIT->ACCTNO))
							 if Acctwait->dtlcode2 == mDTLCODE
								  mActivPbal += Refernce->PRNAMNT2
								  mActivCbal += Refernce->CREDAMT2
							 endif	
							 PRN_AMT    -= Refernce->PRNAMNT2
							 CR_AMT  -= Refernce->CREDAMT2
						endif
					   endif

				  Acctwait ->(DBSKIP())
				  ENDDO

			   endif

			 Acctmast->  ( dbsetorder(6) )
			 if Acctmast -> (dbseek(mrefno2+mdocref2))

				Do While Acctmast->brcode + Acctmast->Refno  == mrefno2  .and. ;
						 Acctmast->Docref == mdocref2                    .and. ;
						!Acctmast->(eof())
					 If left(Acctmast->dtlcode,2) == left(mDTLCODE,2)
						if empty(Acctmast->Docref2)
							 if Acctmast->dtlcode == mDTLCODE
								  mActivPbal += Acctmast->Principal
								  mActivCbal += Acctmast->CREDAMT
							 endif	
							 PRN_AMT    -= Acctmast->Principal
							 CR_AMT  -= Acctmast->CREDAMT
						else

							if Refernce->(dbseek(Acctmast->brcode+Acctmast->Refno+Acctmast->dtlcode+Acctmast->acctno))
								 if Acctmast->dtlcode == mDTLCODE
									  mActivPbal += Refernce->PRNAMNT1
									  mActivCbal += Refernce->CREDAMT1
								 endif	
								 PRN_AMT    -= Refernce->PRNAMNT1
								 CR_AMT  -= Refernce->CREDAMT1

							endif
						endif
					 endif
				Acctmast ->(DBSKIP())
				ENDDO

			 endif

			 Acctmast->  ( dbsetorder(7) )
			 if Acctmast -> (dbseek(mrefno2+mdocref2))

				Do While Acctmast->brcode + Acctmast->Refno2  == mrefno2  .and. ;
						 Acctmast->Docref2 == mdocref2                    .and. ;
						!Acctmast->(eof())
				    If left(Acctmast->dtlcode2,2) == left(mDTLCODE,2)
						if empty(Acctmast->Docref2)
							 if Acctmast->dtlcode == mDTLCODE
								  mActivPbal += Acctmast->Principal
								  mActivCbal += Acctmast->CREDAMT
							 endif	
							 PRN_AMT    -= Acctmast->Principal
							 CR_AMT  -= Acctmast->CREDAMT
						else
							if Refernce->(dbseek(Acctmast->brcode+Acctmast->Refno+Acctmast->dtlcode+Acctmast->acctno))
								 if Acctmast->dtlcode == mDTLCODE
									  mActivPbal += Refernce->PRNAMNT1
									  mActivCbal += Refernce->CREDAMT1
								 endif	
								 PRN_AMT    -= Refernce->PRNAMNT1
								 CR_AMT  -= Refernce->CREDAMT1
							endif
						endif
					 endif
				Acctmast ->(DBSKIP())
				ENDDO

			 endif

			 //alert(str(mActivPmain)+ ' '+str(mActivPbal))
			 
			mActivPbal := round(mActivPmain - mActivPbal,2)
			mActivCbal := round(mActivCmain - mActivCbal,2)
			
			//alert('activpbal '+str(mActivPbal)+' activcbal '+str(mActivCbal)+' prnamt '+str(PRN_AMT)+' mprnbal '+str(mPRNBAL))
			
			ln_avlble2 := mActivPbal
			
			//alert(str(mActivPbal)+' '+str(Round(PRN_AMT - mprincipal,2))+' '+str(mActivCbal)+' '+str(round(CR_AMT-mCREDAMT,2)))
			
			//if round(mActivPbal,2) == round(PRN_AMT,2) .and. round(mActivCbal,2) == round(CR_AMT,2) .and. linclude
			//if round(CAHEADER->PRNLINE - CAHEADER->PRNAVAIL,2) == round(PRN_AMT,2) .and. round(mActivCbal,2) == round(CR_AMT,2) .and. linclude
			   //lreturnval := .t.
			   //error ( 'Line already expended!!!!' )	
			   
			do case 
			    case round(mprincipal,2) > round(PRN_AMT + mPRNBAL,2)
					  lreturnval := .t.
					  error ( 'Principal line exceeds available line!' )
					  
				case round(mCREDAMT,2) > round(CR_AMT + mCRBAL,2)
					  lreturnval := .t.
					  error ( 'Credit line exceeds available line!' )	
					  
				case round(mprincipal,2) > round(mActivPbal + mPRNBAL,2)
					  lreturnval := .t.
					  error ( 'Principal line exceeds available line!' )
					  
				case round(mCREDAMT,2) > round(mActivCbal + mCRBAL,2)
					  lreturnval := .t.
					  error ( 'Credit line exceeds available line!' )
					  
                otherwise
						IF mCREDAMT >= mCRBAL
						   mCRDAMT1  := mCRBAL
						   mCRDAMT2  := round(mCREDAMT - mCRBAL,2)
						ELSE
						   mCRDAMT1  := mCREDAMT
						   mCRDAMT2  := 0
						ENDIF

						IF mprincipal >= mPRNBAL
						   mPRNAMT1  := mPRNBAL
						   mPRNAMT2  := round(mprincipal - mPRNBAL,2)
						ELSE
						   mPRNAMT1  := mprincipal
						   mPRNAMT2  := 0
						ENDIF
			endcase
			
			/***
			if  mActivPbal > PRN_AMT 
				   if round(mprincipal,2) > round(PRN_AMT + mPRNBAL,2)
					  lreturnval := .t.
					  error ( 'Principal line exceeds available line!' )
				   elseif round(mCREDAMT,2) > round(CR_AMT + mCRBAL,2)
					  lreturnval := .t.
					  error ( 'Credit line exceeds available line!' )			   
				   else
						IF mCREDAMT >= mCRBAL
						   mCRDAMT1  := mCRBAL
						   mCRDAMT2  := round(mCREDAMT - mCRBAL,2)
						ELSE
						   mCRDAMT1  := mCREDAMT
						   mCRDAMT2  := 0
						ENDIF

						IF mprincipal >= mPRNBAL
						   mPRNAMT1  := mPRNBAL
						   mPRNAMT2  := round(mprincipal - mPRNBAL,2)
						ELSE
						   mPRNAMT1  := mprincipal
						   mPRNAMT2  := 0
						ENDIF
				   endif
			else
				   if round(mprincipal,2) > round(mActivPbal + mPRNBAL,2)
					  lreturnval := .t.
					  error ( 'Principal line exceeds available line!' )
				   elseif round(mCREDAMT,2) > round(mActivCbal + mCRBAL,2)
					  lreturnval := .t.
					  error ( 'Credit line exceeds available line!' )

				   else
						IF mCREDAMT >= mCRBAL
						   mCRDAMT1  := mCRBAL
						   mCRDAMT2  := round(mCREDAMT - mCRBAL,2)
						ELSE
						   mCRDAMT1  := mCREDAMT
						   mCRDAMT2  := 0
						ENDIF

						IF mprincipal >= mPRNBAL
						   mPRNAMT1  := mPRNBAL
						   mPRNAMT2  := round(mprincipal - mPRNBAL,2)
						ELSE
						   mPRNAMT1  := mprincipal
						   mPRNAMT2  := 0
						ENDIF
				   endif
			endif
		    ***/
			
			
			
			
		 /***
         if round(mprincipal,2) > round(PRN_AMT + mPRNBAL,2)
		    lreturnval := .t.
	        error ( 'Principal line exceeds available line!' )
		 elseif round(mCREDAMT,2) > round(CR_AMT + mCRBAL,2)
		    lreturnval := .t.
	        error ( 'Credit line exceeds available line!' )
		 else

		    IF mCREDAMT >= mCRBAL
		       mCRDAMT1  := mCRBAL
		       mCRDAMT2  := round(mCREDAMT - mCRBAL,2)
			ELSE
		       mCRDAMT1  := mCRBAL
		       mCRDAMT2  := 0
			ENDIF

			IF mprincipal >= mPRNBAL
			   mPRNAMT1  := mPRNBAL
			   mPRNAMT2  := round(mprincipal - mPRNBAL,2)
			ELSE
			   mPRNAMT1  := mPRNBAL
			   mPRNAMT2  := 0
			ENDIF

		 endif
	     ***/
	  endif


   EndIF

return lreturnval

/*---------------------------------------------------*/
 Static Function agetproceeds( mprincipal,mwhat,cstat )
/*---------------------------------------------------*/
local mu:=savedbf(),st:=savescreen( ,,, ),nretval := .f.,gf:=setcolor()

if (mwhat == 'R' .and. empty(cstat)) .OR. mwhat <> 'R'
   while .t.
 	 setcolor('w/bg+,n/w,,,w+/bg+')
	 fshadow( 5,24,7,56,2,'w/bg+' )
	 @ 06, 26 say 'Net Proceeds  ' color 'w/bg+'
	 @ 06, 41 get mprincipal  ;
			  pict '999,999,999.99' ;
			  when lastkey() <> K_ESC valid !empty(mprincipal)                                 // transfer for the purpose of checking the available line

	 setkey( K_ESC, {|| fescape('Abort?') } )
	 read
	 setkey(K_ESC,nil)

	 if lastkey() == K_RETURN
		nretval := .t.
		exit
	 elseif lastkey() == K_ESC
	   nretval := .f.
	   exit
	 endif
   enddo

   setcolor(gf)
   restscreen( ,,,,st )
   @ 17, 22 say trans(mprincipal,'999,999,999.99')
else
   nretval := .t.
endif

return nretval

/*---------------------------------*/
static Function chkgrp(clnt1,clnt2,ndocref,cstat,mwhat)
/*---------------------------------*/
 local mu:=savedbf(),gf:=if(ndocref == '2',Oticket->(Indexord()), Caheader->(indexord()) )
 local nretval := .f.,code1:='',code2:='',st:=Grpmembr->(indexord())
 local mess1 :=if( ndocref == '2','OT File', 'CA File')
 //Grpmembr->(dbsetorder(2))

if (mwhat == 'R' .and. empty(cstat)) .OR. mwhat <> 'R'
     Grpmembr->(dbsetorder(3))  //BRCODE2+CLNTCODE
	 if clnt1 == clnt2
		nretval := .t.
	 elseif Grpmembr->(dbseek(clnt1))
		code1:= Grpmembr->Grupcode
		code2:= eval( {|| Grpmembr->(dbseek(clnt2,.f.)),Grpmembr->Grupcode} )
		if code1 == code2
		   nretval := .t.
		endif
	 endif
	 if nretval == .f.
		error('Error:Invalid reference in '+mess1+'.')
	 endif
	 restdbf(mu)
	 Grpmembr->(dbsetorder(st))
	 eval( {|| if(ndocref == '2',Oticket->(dbsetorder(gf)), Caheader->(dbsetorder(gf)) ) } )
 else
     nretval := .t.
 endif
 return nretval

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function chkpayfreq(mpayfreqchoices, mpayfreq, mrow, mrayt)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   mpayfreq := gen_achoice ( mpayfreqchoices, val ( mpayfreq ),'Payment Freq.', 10, 55, 18 , 78, 'W/GR+,W/N,,,W/GR+')
   @ mrow, mrayt + len( mpayfreq ) + 1 say upper( disp_payment_freq( mpayfreq) ) color 'gr+/b'
   return .f.
/*
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function disp_payment_freq(mpayfreq)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mlist := space ( 11 ) + 'Monthly    Bi-monthly Quarterly  Semi-annualAnnual     Lumpsum    Irregular  '
   return substr ( mlist, val ( mpayfreq ) * 11 + 1, 11 )
*/
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   **ÄÄÄÄ*¯ gener's stack ®*ÄÄÄÄ**
   static function chkclntcode(mclntcode, mdocref, mrefno, mwhat, mfloor, mleft, mbrcode )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mscreen, arr_ := {}, mgrpcode:='000', mindexord := Grpmembr->( indexord() ), mrow, mcol := 1, mdbf := savedbf()
   local mesc := setkey( K_ESC, nil ), mcursor := setcursor( setcursor() ), mcolor := setcolor(), mcodeclnt := mclntcode
   local mseek := { | s | if( mdocref == '1', Caheader->( s ), Oticket->( s ) ) }, mdisplay, mcodemiss
   local mcode := { || if( mdocref == '1', CAHEADER->BRCODE+Caheader->clntcode, OTICKET->BRCODE+Oticket->clntcode ) }
   local mfullname := { | c | Client->( dbseek( c ) ), tran( padr( c, 10 ), '@R 999-99-99999' ) +' '+ Client->fullname }
   LOCAL cTRUNC := SPACE(0), _seek := .t., cbrcode
   local tmp := ''

   setcursor( 0 )
   if( lower( mwhat ) == 'r', nil, eval( mseek, dbseek( mbrcode+mrefno ) ) )
   mclntcode := mcodemiss := if( lower( mwhat ) == 'r', mclntcode, eval( mcode ) )

   //aga.27.11.2007.edit group deny patch
   if lower(mwhat) == 'r' //edit
      return .f.
   end if
   //.............................

   Grpmembr->( dbsetorder( 2 ) )

//aga.21.11.2005.temp insert of mbrcode to facilitate editing
   if Grpmembr->( dbseek( mclntcode ) )    && RED 112504 REMOVED 'mbrcode+
	   	do while mclntcode == GRPMEMBR->BRCODE+GRPMEMBR->CLNTCODE
			if left(mCLNTCODE,3) == GRPMEMBR->BRCODE2
			   mgrpcode := Grpmembr->grupcode
				exit
			else
				GRPMEMBR->(dbskip(1))
			endif
		enddo
	else
		Grpmembr->( ordsetfocus( 3 ) )
		if Grpmembr->( dbseek( mclntcode ) )
			mgrpcode := Grpmembr->grupcode
			_seek := .f.
			cbrcode := GRPMEMBR->BRCODE
		endif

	endif
	      Grpmembr->( dbsetorder( 1 ) )
	if _seek
		Grpmembr->( dbseek( left(mCLNTCODE,3)+mgrpcode ) )
	else
		Grpmembr->( dbseek( cbrcode+mgrpcode ) )
	endif

		      //if Grpmembr->( dbseek( Grpmembr->brcode+mgrpcode ) )              // abb 06.21.2005
		         Grpmembr->( dbeval( { ||aadd( arr_, eval( mfullname, if(Grpmembr->brcode != Grpmembr->brcode2,Grpmembr->brcode2+Grpmembr->clntcode,Grpmembr->brcode+Grpmembr->clntcode) ) ) },,;    && RED 112504 ADDED 'Grpmembr->brcode+
		                             { || Grpmembr->brcode+Grpmembr->grupcode == Grpmembr->brcode+mgrpcode ;
		                             };
		                           );
		                   )
		      //endif


   Grpmembr->( dbsetorder( mindexord ) )

   if len( arr_ ) > 0

      if ( mrow := ascan( arr_, { | a_ | subs( a_, 1, 12 ) == ;
           tran( if( empty( mcodeclnt ), mclntcode, mcodeclnt ), '@R 999-99-99999' ) } ) ) > 0

         mclntcode := val( gen_achoice( arr_, mrow, subs( arr_[ mrow ], 10, 43 ), {} ) )

//aga.21.11.2005.array bound check...caused by incomplete array built by grp (see previous comment)

         if lastkey() != K_ESC

            mdisplay  := subs( arr_[ mclntcode ], 13, 40 )

            mclntcode := stuff( subs( arr_[ mclntcode ], 1, 12 ), 4, 1, '' )

            mCLNTCODE := STUFF(mCLNTCODE, 6, 1, '')


         else
            mdisplay  := subs( eval( mfullname, if( empty( mclntcode ), mcodemiss, mcodeclnt ) ), 09, 40 )
            mclntcode := stuff( subs( eval( mfullname, if( empty( mclntcode ), mcodemiss, mcodeclnt ) ), 1, 8 ), 3, 1, '' )
         endif

      endif

   else
      cTRUNC := eval( mfullname, if( empty( mcodeclnt ), mclntcode, mcodeclnt ) )
      mdisplay := subs( cTRUNC, 13, 40 )
      mclntcode := stuff( subs( cTRUNC, 1, 12;
                              ), 4, 1, '')
      mCLNTCODE := STUFF(mCLNTCODE, 6, 1, '')
   endif

   devpos( mfloor, mleft + len( mclntcode ) + 3 )
   devout( mdisplay, 'gr+/b' )
   setkey( K_ESC, mesc )
   setcursor( mcursor )
   restdbf( mdbf )
return( .f. )

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function chkcurrency(mcurrcode, mrow, mleft)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mscreen := savescreen( ,,, )
   center ( 24, 'w+/n', '® Search Currency ¯' )
   lb_lkup('Currency',1,2,@mcurrcode, 2 , 1, 15, 27, 21, 75, 'W/GR+,W/N,,,W/GR+')
   @ mrow, mleft + len( mcurrcode ) + 1 say upper( dispcurrency(mcurrcode) ) color 'gr+/b'
   restscreen( ,,,, mscreen )
   return .f.
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function chkaocode(maocode,mdocref,mrefno, mrow, mleft,mbrcode)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   if( mdocref == '1', Caheader->(dbseek(mrefno)), Oticket->(dbseek(mrefno)) )  && RED 112504 REMOVED 'mbrcode+ 2X
   maocode := if ( mdocref == '1', Caheader->AOCODE,Oticket->AOCODE )
   @ mrow, mleft + len( maocode ) + 1 say upper( dispaoname( maocode ) ) color 'gr+/b'
   return .f.
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function disprec()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mpayfreqchoices := { '1 = MONTHLY    ','2 = BI-MONTHLY ','3 = QUARTERLY  ',;
			      '4 = SEMI-ANNUAL','5 = ANNUAL     ','6 = LUMPSUM    ',;
			      '7 = IRREGULAR  ' }, mleft := 2 , mrayt := 43

   dispbegin()
   @ 04, mleft say '       Account N§  '                                 color 'w/b'

   @ 04, col() say ACCTWAIT->BRCODE+Acctwait->acctno pict '@R 999-9999-99999-99999'          color 'w+/b'

   @ 05, mleft say '      Branch Name  '                                 color 'w/b'
   @ 05, col() say Acctwait->brcode + ' ' + padr( _get_branch(Acctwait->brcode),40) pict '@!'  color 'w+/b'

   @ 04, mrayt say ' Availment Date   '                                         color 'w/b'
   @ 04, col() say dtoc( Acctwait->valdate )                                     color 'w+/b'
   @ 06, mleft say ' Doc. Reference 1  '                                        color 'w/b'
   @ 06, col() say Acctwait->docref                                              color 'w+/b'
   @ 06, col() say ' ' + upper( dispreftype( Acctwait->docref ) )                color 'w+/b'
   @ 06, mrayt say 'Doc. Reference 2  '                                         color 'w/b'
   @ 06, col() say Acctwait->docref2                                             color 'w+/b'
   @ 06, col() say ' ' + upper( dispreftype( Acctwait->docref2 ) )               color 'w+/b'
   @ 07, mleft say '         CA/OT N§  '                                        color 'w/b'
   @ 07, col() say IF(EMPTY(ACCTWAIT->REFNO),SPACE(8),ACCTWAIT->BRCODE+Acctwait->refno)    PICT '@R 999-99999'       color 'w+/b'
   @ 07, mrayt say '        CA/OT N§  '                                         color 'w/b'
   @ 07, col() say IF(EMPTY(ACCTWAIT->REFNO2),SPACE(8),ACCTWAIT->BRCODE+Acctwait->refno2)   PICT '@R 999-99999'  color 'w+/b'
   @ 09, mleft say '           Client  '                                        color 'w/b'
   @ 09, col() say ACCTWAIT->BRCODE+Acctwait->clntcode pict '@R 999-99-99999'    color 'w+/b'
   @ 09, col() say ' ' + upper( DISPCLNTNAME( ACCTWAIT->BRCODE+Acctwait->clntcode, 40 ) )       color 'w+/b'  && RED 112504 REMOVED 'Acctwait->brcode, CHANGED _DISPCLNTNAME TO DISPCLNTNAME
   @ 10, mrayt say '           DOSRI  '                                        color 'w/b'
   @ 10, col() say if(ACCTWAIT->DOSRI != 'NO ' .AND. !EMPTY(ACCTWAIT->DOSRI),'YES '+'['+ACCTWAIT->DOSRI+']' ,'NO           ') pict '@X'                       color 'w+/b'
   @ 11, mleft say '           Surety  '                                        color 'w/b'
   @ 11, col() say Acctwait->surety1 pict '@X'                                   color 'w+/b'
   @ 12, mleft say '                   '                                        color 'w/b'
   @ 12, col() say Acctwait->surety2 pict '@X'                                   color 'w+/b'
   @ 13, mleft say '     AO In-Charge  '                                        color 'w/b'
   @ 13, col() say Acctwait->aocode                                              color 'w+/b'
   @ 13, col() say ' ' + upper( dispaoname( Acctwait->aocode ) )                 color 'w+/b'
   @ 14, mleft say '         Currency  '                                        color 'w/b'
   @ 14, col() say Acctwait->currcode pict '@X'                                  color 'w+/b'
   @ 14, col() say ' ' + upper( dispcurrency( Acctwait->currcode ) )             color 'w+/b'
   @ 16, mleft say '    Facility Code  '                                        color 'w/b'
   @ 16, col() say Acctwait->fcltycode pict '@R 999-99'                          color 'w+/b'
   @ 16, col() say ' '  + upper( dispfcltyname( Acctwait->FCLTYCODE ) )          color 'w+/b'
   @ 17, mleft say '     Net Proceeds  '                                        color 'w/b'
   @ 17, col() say trans( Acctwait->principal, '999,999,999.99' )                color 'w+/b'
   @ 17, mrayt say '      True Rate  '                                          color 'w/b'
   @ 17, col() say trans( Acctwait->truerate , '99.9999' )                       color 'w+/b'
   @ 17, col() say ' ' + upper( dispratetype( Acctwait->ratetype ) )             color 'w+/b'
   @ 18, mleft say '             Term  '                                        color 'w/b'
   @ 18, col() say trans( Acctwait->term     , '999'     )                       color 'w+/b'
   @ 18, col() say ' '+ if( Acctwait->termunit $ '12', if( alltrim( Acctwait->termunit ) == '1', 'DAY(s)  ', 'MONTH(s)'), space( 8 ) ) color 'w+/b'
   @ 18, mrayt say '  Credit Amount  '                                          color 'w/b'
   @ 18, col() say tran( Acctwait->credamt, '999,999,999.99' )                   color 'w+/b'

   @ 19, mleft say '  VAT Inclusive    '       color 'w/b'    // abb 05/01/2003
   @ 19, col() say Acctwait->vatincl            color 'w+/b'   // abb 05/01/2003

   @ 20, mleft say '  Mode of Payment  '                                        color 'w/b'
   @ 20, col() say Acctwait->paymode                                             color 'w+/b'
   @ 20, col() say ' ' + upper( disp_mode_pay( Acctwait->PAYMODE ) )             color 'w+/b'
   @ 21, mleft say ' Review Frequency  '                                        color 'w/b'
   @ 21, col() say Acctwait->revfreq                                             color 'w+/b'
   @ 21, col() say ' ' + upper( left( disp_rev_freq( Acctwait->revfreq ), 15 ) ) color 'w+/b'
   @ 20, mrayt say 'Payment Frequency  '                                        color 'w/b'
   @ 20, col() say Acctwait->payfreq                                             color 'w+/b'
   if !empty( Acctwait->payfreq )
      @ 20, col() say ' ' + upper( subs( mpayfreqchoices[ val( Acctwait->payfreq) ], 5, 11 ) ) color 'w+/b'
   else
      @ 20, col() say space( 12 ) color 'w+/b'
   endif
   @ 21, mrayt say '          Remarks  '                                        color 'w/b'
   @ 21, col() say '< Memo >'                                                    color 'w+/b'
   dispend()
   return nil
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function assign_header ( macctno , mdocref  , mrefno   , mvaldate  , mcondate  , mclntcode,;
                                   msurety1, msurety2 , maocode  , mcltrltype, mpaymode  , munitcode,;
                                   mrevfreq, mcredtype, mcurrcode, nusdrate  , morixunit , mremarks, mstat    ,;
                                   mdocref2, mrefno2  , lvatincl , mbrcode , mDOSRI;
                                 )

   return( eval( { | n | ;
          macctno   := ACCTWAIT->BRCODE+Acctwait->ACCTNO  , mdocref  := Acctwait->DOCREF ,;
          mrefno    := ACCTWAIT->BRCODE+Acctwait->REFNO   , mvaldate := Acctwait->VALDATE,;
          mclntcode := ACCTWAIT->BRCODE+Acctwait->CLNTCODE, msurety1 := Acctwait->SURETY1,;
			 msurety2  := Acctwait->SURETY2 , maocode  := Acctwait->AOCODE ,;
			 mpaymode  := Acctwait->PAYMODE , mrevfreq := Acctwait->REVFREQ,;
			 mdocref2  := ACCTWAIT->DOCREF2 , mrefno2  := ACCTWAIT->BRCODE+ACCTWAIT->REFNO2 ,;
          mcurrcode := Acctwait->CURRCODE,;
		  nusdrate  := Acctwait->USDRATE,;
          mstat     := Acctwait->STATUS,;
          lvatincl  := Acctwait->VATINCL,;
          mbrcode   := Acctwait->brcode ,;
			 mDOSRI := ACCTWAIT->dosri , ;
          n } ) )

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function save_header( macctno , mdocref  , mrefno     , mvaldate  , mcondate, mclntcode,;
          msurety1, msurety2 , maocode  , mcltrltype, mpaymode  , munitcode,;
          mrevfreq, mcredtype, mcurrcode, nusdrate  , morixunit , mremarks ,;
 		  mstat   , mdocref2 , mrefno2  , lvatincl  , mbrcode   , mDOSRI   , lref2 )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ                                      //aga.18.04.2005.added right() to remove brcode prefix

  if !lref2
       Acctwait->Docref2 := space(1)
	   mrefno2                    := space(5)
  else
       Acctwait->Docref2 := IF (!EMPTY(RIGHT(mrefno2,5)),mdocref2,SPACE(1))
   endif

   return( eval( { | n | Acctwait->ACCTNO  := RIGHT(macctno,14) , Acctwait->ACCTNAME := saveclntname( right( mCLNTCODE, 7) ),;   && RED 112504 REMOVED ',mbrcode
          Acctwait->DOCREF  := mdocref , Acctwait->REFNO    := RIGHT(mrefno,5)    ,;
          Acctwait->VALDATE := mvaldate, Acctwait->CLNTCODE := RIGHT(mclntcode,7) ,;
			 Acctwait->SURETY1 := msurety1, Acctwait->SURETY2  := msurety2  ,;
			 Acctwait->AOCODE  := maocode , Acctwait->PAYMODE  := mpaymode  ,;
			 Acctwait->REVFREQ := mrevfreq, Acctwait->CURRCODE := mcurrcode ,;
			 Acctwait->USDRATE := nusdrate, ;
             Acctwait->Refno2   := RIGHT(mrefno2,5)  , ;
                                         Acctwait->STATUS   := mstat,;
          Acctwait->vatincl := lvatincl, Acctwait->brcode   := mbrcode,Acctwait->dosri := mDOSRI  , n } ) )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function assign_details( mfcltycode,  mmatdate ,  munit     ,  mdlrcode ,;
                   mponum   , mpurcamt  ,  munitloca,  mprincipal,  mpaytype ,;
                   mgd      , mrv       ,  mterm    ,  mtermunit ,  mtruerate,;
                   mratetype, mfirstdue ,  mfactor  ,  mamort    ,  mcredamt ,;
                   malir    , mpayfreq  ,  maddon   ,  mudi      ,  msalesrep,;
                   mdownpay , mincentive,  mnotfctn ,  mcolexion ,  mrecourse,;
                   mobligor , mcolatrl  ,  mtrantype,  munit2    ,  mnerate  ,;
                   mappval  , mWTAX     ,  mudiamt  ,  mdtlcode  ,  mdtlcode2 ;
				  )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   return( eval( { | n | mfcltycode := Acctwait->FCLTYCODE, munit := Acctwait->UNIT    ,;
			 mdlrcode   := Acctwait->DLRCODE  , mponum    := Acctwait->PONUM   ,;
			 mpurcamt   := Acctwait->PURCAMT  , munitloca := Acctwait->UNITLOCA,;
			 mprincipal := Acctwait->PRINCIPAL, mpaytype  := Acctwait->PAYTYPE ,;
			 mgd        := Acctwait->GD       , mrv       := Acctwait->RV      ,;
			 mterm      := Acctwait->TERM     , mtermunit := Acctwait->TERMUNIT,;
			 mtruerate  := Acctwait->TRUERATE , mratetype := Acctwait->RATETYPE,;
			 mfirstdue  := Acctwait->FIRSTDUE , mfactor   := Acctwait->FACTOR  ,;
			 mamort     := Acctwait->AMORT    , mcredamt  := Acctwait->CREDAMT ,;
			 malir      := Acctwait->ALIR     , mpayfreq  := Acctwait->PAYFREQ ,;
			 maddon     := Acctwait->ADDON    , mudi      := Acctwait->UDI     ,;
			 msalesrep  := Acctwait->SALESREP , mdownpay  := Acctwait->DOWNPAY ,;
			 mincentive := Acctwait->INCENTIVE, mnotfctn  := Acctwait->NOTFCTN ,;
			 mcolexion  := Acctwait->COLEXION , mrecourse := Acctwait->RECOURSE,;
			 mobligor   := Acctwait->OBLIGOR  , mcolatrl  := Acctwait->COLATRL ,;
			 mtrantype  := Acctwait->TRANTYPE , mmatdate  := Acctwait->MATDATE ,;
          munit2     := Acctwait->UNIT2       , mnerate   := Acctwait->Nerate  ,;
		  mWTAX      := Acctwait->WTAX        , mudiamt   := Acctwait->UDIAMT  ,;
          mappval    := Acctwait->Appval      , mdtlcode  := Acctwait->DTLCODE ,;
		  mdtlcode2  := Acctwait->DTLCODE2    , n } ) )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function save_details( mfcltycode, mmatdate , munit     , mdlrcode , mponum    ,;
				 mpurcamt  , munitloca, mprincipal, mpaytype , mgd, mrv  ,;
				 mterm     , mtermunit, mtruerate , mratetype, mfirstdue ,;
				 mfactor   , mamort   , mcredamt  , malir    , mpayfreq  ,;
				 maddon    , mudi     , msalesrep , mdownpay , mincentive,;
				 mnotfctn  , mcolexion, mrecourse , mobligor , mcolatrl  ,;
				 mtrantype , munit2   , mnerate   , mappval  , mWTAX     ,;
				 mudiamt   , mdtlcode , mdtlcode2 , mrefno   , mrefno2   ,;
				 mdocref   , mdocref2 , macctno   , mcrdamt1 , mcrdamt2  ,;
				 mprnamt1  , mprnamt2 , lref2 )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ


	  
	  if !empty(mdocref2)

		  if (REFERNCE->(dbseek(mrefno+mdtlcode+RIGHT(macctno,14))),msave := "R",msave := "A")
               if lref2
					  if REFERNCE->(netlock(msave,0))
						 REFERNCE->brcode   := g_par_brch
						 REFERNCE->acctno   := RIGHT(macctno,14)
						 REFERNCE->carefno1 := RIGHT(mrefno,5)
						 REFERNCE->docref1  := mdocref
						 REFERNCE->dtlcode1 := mdtlcode
						 REFERNCE->prnamnt1 := mprnamt1
						 REFERNCE->credamt1 := mcrdamt1

						 REFERNCE->carefno2 := RIGHT(mrefno2,5) //if (lref2,RIGHT(mrefno2,5),space(5))
						 REFERNCE->docref2   := mdocref2 //if (lref2,mdocref2,space(1))
						 REFERNCE->dtlcode2 := mdtlcode2 //if (lref2,mdtlcode2,space(4))
						 REFERNCE->prnamnt2 := mprnamt2 //if (lref2,mprnamt2,0)
						 REFERNCE->credamt2 := mcrdamt2 //if (lref2,mcrdamt2,0)
						 REFERNCE->(dbunlock())
					 endif
					 REFERNCE->(dbcommit())

			   else

 				    if REFERNCE->(netlock('R',0))
					     REFERNCE->(dbdelete())
						 REFERNCE->(dbunlock())
						 REFERNCE->(dbcommit())
				    endif

			   endif
      else
	     if REFERNCE->(dbseek(mrefno+mdtlcode+RIGHT(macctno,14))) .and. !lref2
		      if REFERNCE->(netlock('R',0))
			       REFERNCE->(dbdelete())
			       REFERNCE->(dbunlock())
			       REFERNCE->(dbcommit())
			  endif
		 endif
	  endif
	  
      if !lref2
	       mdtlcode2 := space(4)
	  endif

   return( eval( { | n | Acctwait->FCLTYCODE  := mfcltycode, Acctwait->UNIT     := munit    ,;
			 Acctwait->DLRCODE    := mdlrcode  , Acctwait->PONUM    := mponum   ,;
			 Acctwait->PURCAMT    := mpurcamt  , Acctwait->UNITLOCA := munitloca,;
			 Acctwait->PRINCIPAL  := mprincipal, Acctwait->PAYTYPE  := mpaytype ,;
			 Acctwait->GD         := mgd       , Acctwait->RV       := mrv      ,;
			 Acctwait->TERM       := mterm     , Acctwait->TERMUNIT := mtermunit,;
			 Acctwait->TRUERATE   := mtruerate , Acctwait->RATETYPE := mratetype,;
			 Acctwait->FIRSTDUE   := mfirstdue , Acctwait->FACTOR   := mfactor  ,;
			 Acctwait->AMORT      := mamort    , Acctwait->CREDAMT  := mcredamt ,;
			 Acctwait->ALIR       := malir     , Acctwait->PAYFREQ  := mpayfreq ,;
			 Acctwait->ADDON      := maddon    , Acctwait->UDI      := mudi     ,;
			 Acctwait->SALESREP   := msalesrep , Acctwait->DOWNPAY  := mdownpay ,;
			 Acctwait->INCENTIVE  := mincentive, Acctwait->NOTFCTN  := mnotfctn ,;
			 Acctwait->COLEXION   := mcolexion , Acctwait->RECOURSE := mrecourse,;
			 Acctwait->OBLIGOR    := mobligor  , Acctwait->COLATRL  := mcolatrl ,;
			 Acctwait->TRANTYPE   := mtrantype , Acctwait->MATDATE  := mmatdate ,;
			 Acctwait->UNIT2      := munit2    , Acctwait->Nerate   := mnerate  ,;
          Acctwait->Appval     := mappval      , Acctwait->WTAX     := mWTAX    ,;
          Acctwait->changed    := 0            , Acctwait->UDIAMT   := mudiamt  ,;
          Acctwait->DTLCODE    := mdtlcode	   , Acctwait->DTLCODE2 := mdtlcode2,;
 		  n } ) )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function amstdelete(message)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mrecno , mretval := .f.

   if confirm( message + '?' )

      REFERNCE->(DBSETORDER(2))
	  IF REFERNCE->(DBSEEK(ACCTWAIT->BRCODE+ACCTWAIT->REFNO2+ACCTWAIT->DTLCODE2+ACCTWAIT->ACCTNO))
	     IF REFERNCE->(NETLOCK('R',0))
		    REFERNCE->(DBDELETE())
		    REFERNCE->(DBUNLOCK())
			REFERNCE->(DBCOMMIT())
		 ENDIF
	  ENDIF

      if Slv->( netlock( 'F', 0 ) )
         if Slv-> ( dbseek ( ACCTWAIT->BRCODE+Acctwait->acctno ) )
            Slv-> ( dbeval ( { ||  Slv->( dbdelete() ) },,;
                             { || !Slv->( eof() ) .and. ;
                                   SLV->BRCODE+Slv->acctno == ACCTWAIT->BRCODE+Acctwait->acctno ;
                             } ;
                           ) ;
                  )
         endif
      endif
      Slv->( dbunlock() )
      if Acctwait->( netlock( 'R', 0 ) )
         eval ( {|| drop  ( alltrim(g_user_id)+' '+'deletes account (avail.) ' + substr(Acctwait->acctno,-5,5) ),;
                    Acctwait->( dbdelete() )   ,;
                    Acctwait->( dbskip( +1 ) ) ,;
                    mrecno := Acctwait->( recno() ),;
                    Acctwait->( dbunlock() )   ,;
                    if ( Acctwait->( eof() ) ,;
                         Acctwait->( dbskip( -1 ) ),;
                         nil ;
                       );
                } ;
              )
      endif
      Acctwait->( dbunlock() )

      mretval := .t.
   endif
return mretval

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
static function acctno_generate(macctno, mwhat)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mlastan
   LOCAL cBRCODE := LEFT(mACCTNO,3)

   if mwhat == 'A'
// EVR       if Parametr->( netlock( 'R', 0 ) )
// EVR          _field->Parametr->lastan := val( ( mlastan := right ( '00000'+ alltrim( str( Parametr->lastan + 1, 5, 0 ) ), 5 ) ) )
// EVR          Parametr->( dbcommit() )
// EVR          macctno := cBRCODE + Parametr->colfyr + right(g_PAR_BRCH,2) + Acctwait->fcltycode + mlastan
// EVR       endif
// EVR       Parametr->( dbunlock() )

      if Ol_param->(dbseek(g_PAR_BRCH))
         if Ol_param->(netlock('R',0))
            Ol_param->LASTAN := val(mlastan := right('00000'+alltrim(str(Ol_param->LASTAN+1,5,0)),5))
            Ol_param->(dbunlock())
            macctno := cBRCODE + Ol_param->COLFYR + right(g_PAR_BRCH,2) + Acctwait->FCLTYCODE + mlastan
         endif
         Ol_param->(dbcommit())
      endif

// EVR      UPDT_OL()               && RED 033005

   endif
return .f.

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function amstsearch(mclntcode,sbrcode)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mRECNO  := Acctwait->( recno() )
   local mCURSOR := setcursor(setcursor())
   local mntx    := Acctwait->( indexord() )
   local mSCR    := savescreen ( ,,, ), mcolor := setcolor()
   local mar, mposition := 1, mlog := {}, mretval := .f., cbrcode
   local cFULLNAME := SPACE( LEN(CLIENT->FULLNAME) ), cKEY
   memvar getlist

   center     ( 24, 'w+/n', '® Search Record ¯' )
//    __lb_lkup  ( 'Client',1,2,@mclntcode,3,1,67,8,21,75,'W/GR+,W/N,,,W/GR+')

   &&nrecno := _getClwin ( mclntcode,2,Client->(indexord()) )            // abb 10.18.2004 )   // client code + indexord
   nRECNO := _GETCLWIN ( mCLNTCODE,1,Client->(indexord()) )            // abb 10.18.2004 )   // client code + indexord

   IF nRECNO = 0 .AND. LASTKEY() == K_ENTER
      center     ( 24,'w+/n', '® Search Record ¯' )
      __lb_lkup  ( 'CLIENT',1,2,@mCLNTCODE,03,45,1,08,12-7,21,75,'W/GR+,W/N,,,W/GR+','@XS40','999','@R 99-99999',,cbrcode,'NAME',cfullname,' Client name','Branch','Code' )
      center     ( 24, 'w+/n', '                 ' )

      IF LASTKEY() == K_ENTER
         nRECNO := CLIENT->(RECNO())
      ENDIF
   ENDIF

   if lastkey() != K_ESC       &&.and. nrecno > 0
      CLIENT->(DBGOTO(nRECNO))
      mCLNTCODE := CLIENT->BRCODE+CLIENT->CLNTCODE
      cfullname := Client->fullname

      *__lb_lkup  ( 'Client',1,2,@mclntcode,3,1,45,8,12-7,21,75,'W/GR+,W/N,,,W/GR+',,,,,sbrcode,'NAME',cfullname)
      *center     ( 24, 'w+/n', '                 ' )

      if lastkey() == K_ENTER .AND. nRECNO > 0 .AND. VALBRCODE(CLIENT->BRCODE, g_USER_ID)
         cbrcode := alltrim(Client->brcode)
         Acctwait->(dbsetorder(4))
         if Acctwait->( dbseek ( mclntcode ) )    && RED 112504 REMOVED 'cbrcode +
            mar := { '  Client N§  ' + tran( mclntcode, '@R 999-99-99999' )    ,;     && RED 112504 REMOVED 'CLIENT->BRCODE+
                     'Client Name  ' + left( dispclntname( mclntcode, 40 ),25 )      ,;     && RED 112504 REMOVED 'Acctwait->brcode, CHANGED _DISPCLNTNAME TO DISPCLNTNAME
                     repl( 'Ä', 47 ), ' Branch Code   Ref N§         Account N§', repl( 'Ä', 47 ) }

            Acctwait->( dbeval( {|| aadd( mar,Acctwait->brcode+' '+;
                                    padr(_get_branch(Acctwait->brcode),8)+' '+;  && RED 112504 CHANGED 10 TO 8
                                    ACCTWAIT->BRCODE+'-'+Acctwait->REFNO+space(5)+;  && RED 112504 CHANGED 7 TO 5 ADDED 'ACCTWAIT->BRCODE+'-'+
                                    trans(ACCTWAIT->BRCODE+Acctwait->ACCTNO,'@R 999-9999-99999-99999'))},,;
                                {|| Acctwait->brcode+Acctwait->CLNTCODE==mclntcode .and. ;
                                    !Acctwait->(eof())}))

            if len(mar) > 1
               mlog := aclone( mar )
               aeval( mlog, { | l, c | mlog[ c ] := if( c <= 5, .f., .t. ), c } )
               mposition := val( gen_achoice( mar, 6, 'Search', mlog ) )
            endif

            if mposition > 0 .and. lastkey() != K_ESC
               *---> RED 100504
               *Acctwait->(dbsetorder(2))  // right( ACCTNO,5 )
               *if Acctwait->(dbseek( right(ltrim(mar[mposition]),5) ) )

               cKEY := SUBSTR(MAR[mPOSITION],28,3)+SUBSTR(MAR[mPOSITION],32,4)+SUBSTR(MAR[mPOSITION],37,5)+RIGHT(MAR[mPOSITION],5)

               ACCTWAIT->(DBSETORDER(1))
         //       IF ACCTWAIT->(DBSEEK( SUBSTR(MAR[MPOSITION],14,4)+SUBSTR(MAR[MPOSITION],19,5)+RIGHT(MAR[MPOSITION],5) ) )   abb 10.14.2004
               IF ACCTWAIT->(DBSEEK( cKEY ))                      && RED 112304 REPLACED 'alltrim(Client->brcode)+SUBSTR(MAR[MPOSITION],14+14,4)+SUBSTR(MAR[MPOSITION],14+19,5)+RIGHT(MAR[MPOSITION],5) )
                  mRECNO := Acctwait->(recno())
                  mRETVAL := .T.
               ELSE
                  mRETVAL := .F.
               endif
            ELSE
               mRETVAL := .F.
            endif
         else
            error ( 'Client N§ not Found!' )
            mRETVAL := .F.
         endif
      endif
   ELSE
      mRETVAL := .F.
   endif

   setcolor  ( mcolor )
   restscreen( ,,,, mSCR )
   setcursor ( mCURSOR )
   Acctwait->( dbsetorder( mntx ) )
   Acctwait->( dbgoto ( mRECNO ) )
   return (mRETVAL)
/*******************************************************************************************/
static Function frefother( mrefno,mdocref,mprincipal,mbrcode,mwhat,mdtlcode,mdtlcode2 )   // abb 10.14.2004
/*******************************************************************************************/
 local mu    := savedbf(),nrec:=Acctwait->( Recno() )
 local n_ord := Acctwait->(Dbsetorder()),mretval:=0

 if upper(mwhat) <> 'A'
    curr_acct := Acctwait->brcode + Acctwait->acctno
 endif

 dbselectarea( 'Acctwait' )
 Acctwait->  ( dbsetorder(5) )

 if Acctwait->(dbseek(mrefno+mdocref))

    do while Acctwait->brcode + Acctwait->refno == mrefno  .and. ;
             Acctwait->Docref                   == mdocref .and. ;
            !Acctwait->(eof())

		 if empty(Acctwait->Docref2)
			   if upper(mwhat) == 'A'
				  //IF !Acctmast->(DBSEEK(Acctwait->brcode+Acctwait->ACCTNO))
					  mretval += Acctwait->Principal
				  //ENDIF
			   else
				  if curr_acct <> Acctwait->brcode + Acctwait->acctno
					 //IF !Acctmast->(DBSEEK(Acctwait->brcode+Acctwait->ACCTNO))
						   mretval += Acctwait->Principal
					 //ENDIF
				  endif
			   endif
		  else
			   if upper(mwhat) == 'A'
				    if REFERNCE->(dbseek(Acctwait->brcode+Acctwait->refno+Acctwait->dtlcode+ACCTWAIT->ACCTNO))
					     if REFERNCE->DOCREF1 == mdocref
					        mretval += REFERNCE->PRNAMNT1//Acctwait->Principal
						 endif
					endif
			   else
				  if curr_acct <> Acctwait->brcode + Acctwait->acctno
					   if REFERNCE->(dbseek(Acctwait->brcode+Acctwait->refno+Acctwait->dtlcode+ACCTWAIT->ACCTNO))
					      if REFERNCE->DOCREF1 == mdocref
					         mretval += REFERNCE->PRNAMNT1//Acctwait->Principal
						  endif
					   endif
				  endif
			   endif
		  endif

	Acctwait->(dbskip())
	enddo

 endif
/////////////////////////////////////////////
  Acctwait -> ( dbsetorder(6) )

 if Acctwait -> (dbseek(mbrcode+right(mrefno,5)+mdocref))

    nprn_refno  := 0
    nprn_refno2 := 0
    do while Acctwait->Refno2  == right(mrefno,5)  .and. ;
             Acctwait->Docref2 == mdocref          .and. ;
             Acctwait->brcode  == mbrcode          .and. ;
            !Acctwait->(eof())

       //if Caheader->(dbseek(Acctwait->brcode+Acctwait->refno2))

          //nprn_refno := Caheader->prnline - Caheader->prnavail

		  REFERNCE->(dbsetorder(2))
		  if REFERNCE->(dbseek(Acctwait->brcode+Acctwait->refno2))
		     Do While REFERNCE->brcode + REFERNCE->carefno2 == Acctwait->brcode+Acctwait->refno2 .and. ;
			         !REFERNCE->(eof())
                   if REFERNCE->DOCREF2 == mdocref
		        //nprn_refno -= REFERNCE->prnamnt2
				nprn_refno += REFERNCE->prnamnt2
				endif

		     REFERNCE->(dbskip())
		     Enddo
		  endif
		  REFERNCE->(dbsetorder(1))
		  

/***
          if Acctwait->principal > nprn_refno         // > mprincipal

             ndiff      := Acctwait->principal- nprn_refno

             if ndiff > 0

			    if upper(mwhat) == 'A'
				   mretval := mretval + ndiff
			    else
				   if curr_acct <> Acctwait->brcode + Acctwait->acctno
					  mretval := mretval + ndiff
				   endif
			    endif
				
             endif

          endif
***/

       //else

		  //if upper(mwhat) == 'A'
		     //mretval += Acctwait->Principal
		  //else
		     //if curr_acct <> Acctwait->brcode + Acctwait->acctno
			    //mretval += Acctwait->Principal
		     //endif
		  //endif

       //endif

       Acctwait->(dbskip(+1))

    enddo
    mretval +=  nprn_refno
	
 endif
 

 
/////////////////////////////////////////////
 
/***
 Acctwait -> ( dbsetorder(6) )

 if Acctwait -> (dbseek(mbrcode+right(mrefno,5)+mdocref))

    nprn_refno  := 0
    nprn_refno2 := 0
    do while Acctwait->Refno2  == right(mrefno,5)  .and. ;
             Acctwait->Docref2 == mdocref          .and. ;
             Acctwait->brcode  == mbrcode          .and. ;
            !Acctwait->(eof())

       if Caheader->(dbseek(Acctwait->brcode+Acctwait->refno2))

          nprn_refno := Caheader->prnline - Caheader->prnavail

		  REFERNCE->(dbsetorder(2))
		  if REFERNCE->(dbseek(Acctwait->brcode+Acctwait->refno2))
		     Do While REFERNCE->brcode + REFERNCE->carefno2 == Acctwait->brcode+Acctwait->refno2 .and. ;
			         !REFERNCE->(eof())

		        nprn_refno -= REFERNCE->prnamnt2

		     REFERNCE->(dbskip())
		     Enddo
		  endif
		  REFERNCE->(dbsetorder(1))

          if Acctwait->principal > nprn_refno         // > mprincipal

             ndiff      := Acctwait->principal- nprn_refno

             if ndiff > 0

			    if upper(mwhat) == 'A'
				   mretval := mretval + ndiff
			    else
				   if curr_acct <> Acctwait->brcode + Acctwait->acctno
					  mretval := mretval + ndiff
				   endif
			    endif
                //mretval := mretval + ndiff

             endif

          endif

       else

		  if upper(mwhat) == 'A'
		     mretval += Acctwait->Principal
		  else
		     if curr_acct <> Acctwait->brcode + Acctwait->acctno
			    mretval += Acctwait->Principal
		     endif
		  endif

       endif

       Acctwait->(dbskip(+1))

    enddo

 endif
 
/***/
 restdbf(mu)

 Acctwait->(dbsetorder(n_ord));Acctwait->(dbgoto(nrec))

return mretval

//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
static function check_refno(mdocref, mrefno, mwhat,t_proceed, ln_avail, xclnt, mprincipal, mbrcode, nORD , mDOSRI,lPURC,t_proceed1,mdtlcode,mdtlcode2)
//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mdbf := savedbf( mdbf ), mok := .t., mntx := Acctwait->(indexord())
   local mdbfuse := if ( mdocref == '1','Caheader','Oticket' )
   local mmess   := if ( mdocref == '1','CA','OT' ), mRECNO := 0
   LOCAL fline := .F.

   mrefno   := LEFT(mREFNO,3) + right( '00000'+alltrim( SUBSTR(mrefno,4,5) ),5)
   otherRef := frefother ( mrefno,mdocref,mprincipal,mbrcode,mwhat,mdtlcode,mdtlcode2 )

   if empty(mbrcode)
      mbrcode := alltrim(g_PAR_BRCH)
   endif

   do case

      case !(mdbfuse)->(dbseek(mrefno))

         error ( 'No such '+mmess+' N§!' )
         mok := .f.

      otherwise

         if (mdbfuse)->ACTAKEN != '3'   // Not Approved ?
		    if mdocref == '1'
				if (mdbfuse)->ACTAKEN == '1'
				   error( mmess + ' N§ '+(mdbfuse)->CANUMBER+' is not yet approved!' )
				   mok := .f.
				else
				   error( mmess + ' N§ '+(mdbfuse)->CANUMBER+' is already closed!' )
				   mok := .f.
				endif
			else
				if (mdbfuse)->ACTAKEN == '1'
				   error( mmess + ' N§ '+(mdbfuse)->OTNUMBER+' is not yet approved!' )
				   mok := .f.
				else
				   error( mmess + ' N§ '+(mdbfuse)->OTNUMBER+' is already closed!' )
				   mok := .f.
				endif
			endif

         else
            if mdocref == '1'     // Caheader

		 	   ndate := Caheader->actdate + 365
		       if ndate < gTRANDATE
			      alert('CA# '+left(mrefno,3)+'-'+right(mrefno,5)+' is already expired!')
			      return .f.
			   endif

               if (Caheader->PRNLINE-Caheader->PRNAVAIL) <= 0
                  error ( 'CA line fully availed!' )
                  mok := .f.
               endif

            else                  // Offering Ticket

		 	   ndate := Oticket->actdate + 365
		       if ndate < gTRANDATE
			      alert('OT# '+left(mrefno,3)+'-'+right(mrefno,5)+' is already expired!')
			      return .f.
			   endif

               if (Oticket->PROCEEDS-Oticket->PRNAVAIL) <= 0
                  error ( 'OT fully availed!' )
                  mok := .f.
               endif
            endif
         endif

   endcase

   if mdocref == '1'       // 'Caheader'
      t_proceed := Caheader->Prnline - Caheader->Prnavail
	  t_proceed := t_proceed + t_proceed1   //REFNO1 + REFNO2
	  
      t_proceed := t_proceed - otherRef

      //ln_avail  := t_proceed - mprincipal  //pepe 12:23 PM 12/7/2011
	  ln_avail  := t_proceed
      net_procd := t_proceed   // abb 09.23.2005

	  IF lPURC
         ln_avail  := t_proceed - mprincipal
	  ELSE
	     ln_avail  := t_proceed
	  ENDIF

	  //alert(str(t_proceed))
      if ln_avail < 0
         error ( 'CA line fully availed!!' )
         t_proceed := 0
         ln_avail  := 0
         mok       := .f.
      endif

	  /*** pepe waiting for SSR 9:23 AM 6/21/2012
	  if Caheader->revdate < gtrandate
	     error('CA already expired!')
         t_proceed := 0
         ln_avail  := 0
         mok       := .f.
	  endif
	  ***/
		mDOSRI     := Caheader->dosri

		if mDOSRI == 'NO '
			@ 10, 62 SAY '              '
		else
			@ 10, 62 SAY 'YES '+'['+mDOSRI+']'
		endif

      xclnt    := CAHEADER->BRCODE+Caheader->Clntcode

      if Cadetail->(Dbseek(Caheader->brcode+Caheader->canumber))
         __nrecno := 0

         do while Cadetail->brcode   == Caheader->brcode   .and. ;
                  Cadetail->canumber == Caheader->canumber .and. ;
                 !Cadetail->(eof())
			__nrecno := Cadetail->(recno())
            if Cadetail->include
               if Cadetail->trantype == '1'
                  exit
               endif
            endif
            Cadetail->(dbskip(+1))
         enddo

         if __nrecno != 0
            Cadetail->(dbgoto(__nrecno))
            //ln_avail   := Caheader->prnline      //aga.30.01.2006.removed to retain remaining ln_avail
            //t_proceed  := Caheader->prnline      //PEPE 3:13 PM 10/2/2012 DID NOT KNOW FOR WHAT PURPOSE.
         endif

      endif

   elseif mdocref == '2'   // if alias() == 'Oticket'
      //
      // seek in Acctwait if there is still pending availments,
      //         if yes prompt the user :
      //   'ERROR : CANNOT ACCEPT MORE THAN ONE AVAILMENT FOR OFFERING TICKETS'
      //   RETURN
      // seek in Acctmast if OT NUMBER already booked
      //         if yes prompt the user :
      //   'ERROR : OTNUMBER '+Oticket->OTNUMBER+' already assigned to Acct. #'+Acctmast->ACCTNO
      //

      ACCTWAIT->(ordsetfocus(if(nORD == 1,5,6)))

	  if mwhat == 'A'  //pepe 5:56 PM 8/23/2012
         if Acctwait->(dbseek(mREFNO+mdocref))  // Acctwait->(indexkey())) should be BRCODE+REFNO
            alert ( 'CANNOT ACCEPT MORE THAN ONE AVAILMENT FOR OFFERING TICKETS' )
            return .f.
          endif


		  //******pepe 4:32 PM 12/8/2011
		  msg := acctwait->(indexord())
		  acctwait->(dbsetorder(6))
		  if Acctwait->(dbseek(mREFNO+mdocref))
			 alert ( 'CANNOT ACCEPT MORE THAN ONE AVAILMENT FOR OFFERING TICKETS' )
			 return .f.
		  endif
		  acctwait->(dbsetorder(msg))
		  //******
	  endif

      __cACTNTX := Acctmast->(indexord())
		ACCTMAST->(ordsetfocus(if(nORD == 1,6,7)))

      if Acctmast->(dbseek(mREFNO+mdocref)) .and. Acctmast->status != '0' // RLV STATUS VERIFICATION 03.16.2011 // Acctmast->(indexkey())) should be BRCODE+REFNO
         alert ( 'OTNUMBER '+Oticket->OTNUMBER+' ALREADY ASSIGNED TO ACCT. #'+trans( Acctmast->brcode+Acctmast->ACCTNO,'@R 999-9999-99999-99999' ) )
         return .f.
      endif

	  //******pepe 4:32 PM 12/8/2011
	  Acctmast->(dbsetorder(7))
      if Acctmast->(dbseek(mREFNO+mdocref)) .and. Acctmast->status != '0'
         alert ( 'OTNUMBER '+Oticket->OTNUMBER+' ALREADY ASSIGNED TO ACCT. #'+trans( Acctmast->brcode+Acctmast->ACCTNO,'@R 999-9999-99999-99999' ) )
         return .f.
      endif
      //******

      Acctmast->(dbsetorder(__cACTNTX))      // abb

      t_proceed := Oticket->Proceeds - Oticket->Prnavail
	  t_proceed := t_proceed + t_proceed1   //REFNO1 + REFNO2
      t_proceed := t_proceed - otherRef
      ln_avail  := t_proceed

	  IF lPURC
         ln_avail  := t_proceed - mprincipal
	  ELSE
	     ln_avail  := t_proceed
	  ENDIF

		mDOSRI := Oticket->dosri

		if mDOSRI == 'NO '
			@ 10, 62 SAY '              '
		else
			@ 10, 62 SAY 'YES '+'['+mDOSRI+']'
		endif

      if ln_avail < 0   //if ln_avail <= 0
         error ( 'OT fully availed!' )
         t_proceed := 0
         ln_avail  := 0
         mok       := .f.
      endif

	  dOTDATE := oticket->otdate + 90  //3 months validity

      /*** pepe waiting for SSR 9:23 AM 6/21/2012
	  if dOTDATE < gtrandate
	     error('OT already expired!')
         t_proceed := 0
         ln_avail  := 0
         mok       := .f.
	  endif
	  ***/

      xclnt    := OTICKET->BRCODE+Oticket->Clntcode

   endif

   Acctwait-> ( dbsetorder(mntx)  )
   restdbf    ( mdbf )

return mok


**************************************
*
static function chk_fclty(mfcltycode)
**************************************
local lretval := .t.

if FACILITY->(dbseek(mfcltycode))
   if FACILITY->setcode == "3"
      lretval := .f.    // for CML & auto loan
   endif
endif

return lretval

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   Static Function chk_osbal(mrefno,mprincipal,mdocref,mfcltycode, mdtlcode, mdtlcode2)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
local mBAL := 0, mBAL2 := 0, lreturnval := .f., mn := ACCTMAST->(indexkey()), mo := Acctwait->(indexkey())
local mCLNTCD := SPACE(7), lTRUE := .F.

   IF CAHEADER->(DBSEEK(mrefno))
	   mCLNTCD := CAHEADER->BRCODE+CAHEADER->CLNTCODE

	   CADETAIL->(DBSEEK(mrefno))
	   DO WHILE CADETAIL->BRCODE+CADETAIL->CANUMBER == mrefno .AND. ;
			   !CADETAIL->(EOF())
			   IF CADETAIL->FCLTYCODE == mfcltycode
				  IF PURCHASE->(DBSEEK(CADETAIL->FCLTYCODE)) .or. CADETAIL->TRANTYPE == '1'
					 //IF CADETAIL->INCLUDE
						mBAL += CADETAIL->PRINCIPAL
					 //ENDIF
				  ELSE
					 //IF CADETAIL->INCLUDE
						mBAL2 += CADETAIL->PRINCIPAL
					 //ENDIF
				  ENDIF
			   ENDIF
	   CADETAIL->(DBSKIP())
	   ENDDO

	   ACCTMAST->( dbsetorder(2) )
	   GRPMEMBR->(DBSETORDER(2))
	   IF GRPMEMBR->(DBSEEK(mCLNTCD))
		  cGRPCD := GRPMEMBR->BRCODE+GRPMEMBR->GRUPCODE
		  lTRUE := .T.
	   ENDIF

	   GRPMEMBR->(DBSETORDER(1))

	   IF lTRUE
		   GRPMEMBR->(DBSEEK(cGRPCD))
		   DO WHILE GRPMEMBR->BRCODE+GRPMEMBR->GRUPCODE == cGRPCD.AND. ;
				   !GRPMEMBR->(EOF())

			   ACCTMAST->( dbseek(GRPMEMBR->BRCODE2+GRPMEMBR->CLNTCODE) )
			   Do While ACCTMAST->BRCODE+ACCTMAST->CLNTCODE == GRPMEMBR->BRCODE2+GRPMEMBR->CLNTCODE .and. ;
					   !ACCTMAST->(eof())
				  If ACCTMAST->status <> '0'
					 IF PURCHASE->(DBSEEK(SUBS(ACCTMAST->ACCTNO,5,5)))
						mBAL -= ACCTMAST->OSBAL
					 ELSE
						if CADETAIL->(dbseek(ACCTMAST->BRCODE+ACCTMAST->REFNO)) .and. CADETAIL->TRANTYPE == '1'
					       mBAL -= ACCTMAST->OSBAL
  					    else
						   IF RIGHT(mrefno,5) == ACCTMAST->REFNO
   						      mBAL2 -= ACCTMAST->PRINCIPAL
						   ENDIF
						endif
					 ENDIF
				  EndIF
			   ACCTMAST->(dbskip())
			   EndDo

		   GRPMEMBR->(DBSKIP())
		   ENDDO
	   ELSE
		   ACCTMAST->( dbseek(mCLNTCD) )

		   Do While ACCTMAST->BRCODE+ACCTMAST->CLNTCODE == mCLNTCD .and. ;
				   !ACCTMAST->(eof())
			  If ACCTMAST->status <> '0'
				 IF PURCHASE->(DBSEEK(SUBS(ACCTMAST->ACCTNO,5,5)))
					mBAL -= ACCTMAST->OSBAL
				 ELSE
					if CADETAIL->(dbseek(ACCTMAST->BRCODE+ACCTMAST->REFNO)) .and. CADETAIL->TRANTYPE == '1'
					   mBAL -= ACCTMAST->OSBAL
  					else
					   IF RIGHT(mrefno,5) == ACCTMAST->REFNO
   					      mBAL2 -= ACCTMAST->PRINCIPAL
					   ENDIF
					endif
				 ENDIF
			  EndIF
		   ACCTMAST->(dbskip())
		   EndDo
	   ENDIF

	   nBRACCT:= Acctwait->BRCODE + Acctwait->ACCTNO

	   Acctwait->  ( dbsetorder(5) )

	   if Acctwait -> (dbseek(mrefno+mdocref))

		  Do While Acctwait->brcode + Acctwait->Refno  == mrefno  .and. ;
				   Acctwait->Docref == mdocref                    .and. ;
				  !Acctwait->(eof())
			 IF Acctwait->BRCODE+Acctwait->ACCTNO <> nBRACCT
				IF PURCHASE->(DBSEEK(SUBS(Acctwait->ACCTNO,5,5))) .AND. Acctwait->DTLCODE == mdtlcode
				   mBAL -= Acctwait->Principal
				ELSE
				   if CADETAIL->(dbseek(Acctwait->BRCODE+Acctwait->REFNO)) .and. CADETAIL->TRANTYPE == '1'
					  mBAL -= Acctwait->Principal
  				   else
				      mBAL2 -= Acctwait->Principal
			       endif
				ENDIF
			 ENDIF
		  Acctwait ->(DBSKIP())
		  ENDDO

	   endif

	   IF PURCHASE->(DBSEEK(mfcltycode)) .or. (CADETAIL->(dbseek(mrefno)) .and. CADETAIL->TRANTYPE == '1')
		  If round(mBAL - mprincipal,2) < 0
			 lreturnval := .t.
		  EndIf
	   ELSE
		  If round(mBAL2 - mprincipal,2) < 0
			 lreturnval := .t.
		  EndIf
	   ENDIF

	   ACCTWAIT->(dbsetorder(1))
	   ACCTWAIT->(DBSEEK(nBRACCT))
	   ACCTMAST->(dbsetorder(mn))
	   GRPMEMBR->(DBSETORDER(2))
   ENDIF

return lreturnval


// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
static function checkref2(mdocref, mrefno, mdocref2, mrefno2, mwhat, t_proceed, t_proceed2, mbrcode, mfcltycode, mprincipal, mdtlcode, mdtlcode2)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mdbf := savedbf( mdbf ), mok := .f., mntx := Acctwait->(indexord())
   local gf:= oticket->(indexord()),bf:=Caheader->(indexord())
   oticket->( dbsetorder(1) )
   CAheader->( dbsetorder(1) )
   mrefno := mBRCODE+right('00000'+alltrim(mrefno),5)
   mrefno2:= mBRCODE+right('00000'+alltrim(mrefno2),5)

   if mdocref <> nil .and. mdocref == '1'
     if Caheader->(dbseek(mrefno))
        t_proceed  := Caheader->Prnline - Caheader->Prnavail
        mok:=.t.
     endif

  elseif mdocref <> nil .and. mdocref == '2'
     if Oticket->(dbseek(mrefno))
        t_proceed := Oticket->Proceeds - Oticket->Prnavail
        mok:=.t.
     endif

  endif

  if mdocref2 <> nil .and. mdocref2 == '1'
     if Caheader->(dbseek(mrefno2))
        t_proceed2  := Caheader->Prnline - Caheader->Prnavail
        mok:=.t.
     endif

  elseif mdocref2 <> nil .and. mdocref2 == '2'
        if Oticket->(dbseek(mrefno2))
           t_proceed2 := Oticket->Proceeds - Oticket->Prnavail
           mok:=.t.
        endif

  endif

  If PURCHASE->(dbseek(mfcltycode)) .or. (CADETAIL->(dbseek(mrefno)) .and. CADETAIL->TRANTYPE == '1')
	  IF chk_osbal(mrefno,mprincipal,mdocref,mfcltycode, mdtlcode, mdtlcode2)
		 //getfclty( @mfcltycode,16,2,mrefno,mprincipal,mdocref )
		  DO WHILE .T.
			 ERROR( 'CA line exceeds line amount!' )
			 if lastkey() == K_ESC
				return .f.
			 endif
		  ENDDO

	  ELSE
		 mok:=.t.
	  ENDIF
  EndIf
  
  otherRef  := frefother ( mrefno,mdocref,mprincipal,mbrcode,mwhat,mdtlcode,mdtlcode2 )
  
  t_proceed := t_proceed - otherRef
  
  // (str(t_proceed)+' '+str(t_proceed2))

  Acctwait->( dbsetorder(mntx) )
  Oticket->( dbsetorder(gf) )
  CAheader->( dbsetorder(bf) )
  restdbf ( mdbf )
  return mok

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function chkpaymode(mpaymodechoices, mpaymode, mrow, mleft)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   mpaymode := gen_achoice ( mpaymodechoices, val ( mpaymode ),'Payment Mode', 14, 60, 18, 78, 'W/GR+,W/N,,,W/GR+')
   @ mrow, mleft + len( mpaymode ) + 1 say upper( disp_mode_pay( mpaymode ) ) color 'gr+/b'
   return .f.
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function chkstat(mstatchoices, mstat, mrow, mcol)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   mstat := gen_achoice ( mstatchoices, val ( mstat ), 'Status',  14, 62, 17, 78, 'W/GR+,W/N,,,W/GR+')
   @ mrow, mcol + len( mstat ) + 1 say upper( dispstat(mstat) ) color 'gr+/b'
   return .f.
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function chkreviewfreq(mrevchoices, mrevfreq, mrow, mleft)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   mrevfreq := gen_achoice ( mrevchoices, val ( mrevfreq ),'Review Frequency', 13, 60, 18, 78, 'W/GR+,W/N,,,W/GR+')
   @ mrow, mleft + len( mrevfreq ) + 1 say upper( left ( disp_rev_freq ( mrevfreq ), 15 ) ) color 'gr+/b'
   return .f.
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function chkdocref(mdocrefchoices, mdocref, mrow, mcol,sw)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mdef := spac(len(mdocref)),defdoc:=mdocref
   sw:=if( !empty(sw), sw, .f. )

   if sw
      aadd(mdocrefchoices, '3 = Not Applicable ' )
   elseif len(mdocrefchoices) > 2
      asize(mdocrefchoice,len(mdocrefchoices)-1)
   endif

   mdocref := gen_achoice ( mdocrefchoices, val ( mdocref ),'Doc. Reference', mrow+1, 21, mrow + 1 + len ( mdocrefchoices ), 41, 'W/GR+,W/N,,,W/GR+')
   mdocref := if(mdocref == '3',' ',if(lastkey() == K_ESC, defdoc, mdocref) )

   if sw
     asize(mdocrefchoice,len(mdocrefchoices)-1)
   endif

   @ mrow, mcol + len( mdocref ) + 1 say upper( dispreftype( mdocref ) ) color 'gr+/b'
return .t.

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   Static Function disp1111( mdef,mrow,mcol )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   @ mrow, mcol + len( mdef ) + 1 say upper( dispreftype( mdef ) ) color 'gr+/b'
   return .t.
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function AMSM1007OPEN()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local cscr := savescreen ( ,,, ),mcol

   @ 22,1 say 'Opening files .....'
   mcol := col()

   *--->     && RED 111705
   IF NETUSE('&g_AMS_PATH\AW_REM',.F.,5)
      SET INDEX TO &g_AMS_PATH\AW_REM
   ELSE
      RETURN .F.
   ENDIF

   @ 22,mCOL SAY '.'
   mCOL := COL()

   *--->       && RED 102505
   If NETUSE('&g_AMS_PATH'+'\OT_OBT.DBF',.f.,5)
      SET INDEX TO &g_AMS_PATH\OT_OBT
   ELSE
      RETURN .F.
   ENDIF
   @ 22,mcol say '.'
   mcol := col()
   *--->

   If NETUSE('&g_AMS_PATH'+'\CA_OBT.DBF',.f.,5)
      SET INDEX TO &g_AMS_PATH\CA_OBT
   ELSE
      RETURN .F.
   ENDIF
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_CIS_PATH'+'\CLIENT.DBF',.f.,5)
      return .f.
   endif
   set index to &g_CIS_PATH\CLIECD, &g_CIS_PATH\CLIENM
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_AMS_PATH'+'\Acctdrop.dbf',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\Acctdrp1
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_AMS_PATH\DOCCODES',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\DOCCODES
   @ 22,mcol say '.'
   mcol := col()

   if !netuse( '&g_grf_path'+'\Axbranch.dbf',.f.,5)
      return .f.
   endif
   set index to &g_grf_path\Axbranch
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_AMS_PATH\AOACCESS',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\AOACCESS
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_AMS_PATH\REQDOCS',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\REQDOCS
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_AMS_PATH\COLATRAL',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\COLATRAL
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_AMS_PATH\UNITCODE',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\UNITCODE
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_AMS_PATH\Acctdaly',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\Acctdaly
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_AMS_PATH\CREDTYPE',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\CREDTYPE
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_AMS_PATH\CAHEADER',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\CAHEADER, &g_AMS_PATH\CAREV, &g_AMS_PATH\CACLNT
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_AMS_PATH\CADETAIL',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\CADETAIL
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_AMS_PATH\REFERNCE',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\REFRNCE1,;    //BRCODE + CAREFNO1 + DTLCODE1 + ACCTNO
                &g_AMS_PATH\REFRNCE2      //BRCODE + CAREFNO2 + DTLCODE2 + ACCTNO

   if !NETUSE('&g_AMS_PATH\PURCHASE',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\PURCHASE

   *---------------------------------------  RED 033005
   IF NETUSE('&g_AMS_PATH\OL_PARAM',.F.,5)
      SET INDEX TO &g_AMS_PATH\OL_PARAM
   ELSE
      RETURN .F.
   ENDIF
   *---------------------------------------

   if !NETUSE('&g_CIS_PATH\AO.DBF',.f.,5)
      return .f.
   endif
   set index to &g_CIS_PATH\AO.NTX
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_AMS_PATH\FACILITY',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\FCLTYCD
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_AMS_PATH\CURRENCY',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\CURRENCY
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_AMS_PATH\ORIXUNIT',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\ORIXUNIT
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_AMS_PATH\OTICKET',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\OTICKET, &g_AMS_PATH\OTCLNT
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_GRF_PATH'+'\HOLIDAYS',.f.,5)
      return .f.
   endif
   set index to &g_GRF_PATH\HOLIDATE
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE( '&g_CIS_PATH'+'\DEALER.DBF',.f.,5)
      return .f.
   endif
   set index to &g_CIS_PATH\DLRCODE, &g_CIS_PATH\DLRNAME, &g_CIS_PATH\DLRBRNM
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_AMS_PATH\CTRLINFO',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\CTRLINFO
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_CIS_PATH'+'\INSURANC',.f.,5)
      return .f.
   endif
   set index to &g_CIS_PATH\INSCODE
   @ 22,mcol say '.'
   mcol := col()

//   if !NETUSE('&g_AMS_PATH\PAYTSKED',.f.,5)  //aga.14.01.2007.synch
//      return .f.
//   endif
//   set index to &g_AMS_PATH\PAYTSKED, &g_AMS_PATH\PAYTSTAT
//   @ 22,mcol say '.'
//   mcol := col()


   if !NETUSE('&g_AMS_PATH\PAYCODES',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\PAYCODES
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_GRF_PATH'+'\PERSONEL.DBF',.f.,5)
      return .f.
   endif
   set index to &g_GRF_PATH\INITIALS.NTX
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_AMS_PATH\ACCTWAIT',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\ACCTWAIT,;         && BRCODE+ACCTWAIT
                &g_AMS_PATH\ACCTWSUB,;         && BRCODE+SUBSTR(ACCTNO,-5,5)
                &g_AMS_PATH\ACCTRECL,;         && BRCODE+REFNO+CLNTCODE
                &g_AMS_PATH\ACCTWCLT,;         && BRCODE+CLNTCODE
                &g_AMS_PATH\ACCTREF1,;         && BRCODE+REFNO+DOCREF
                &g_AMS_PATH\ACCTREF2           && BRCODE+REFNO2+DOCREF2
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_AMS_PATH\ACCTMAST',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\ACCTMAST,;
					 &g_AMS_PATH\ACCTCLNT,;
					 &g_AMS_PATH\SURECLNT,;
					 &g_AMS_PATH\ACCTFA,  ;
					 &g_AMS_PATH\ACCTSUB2,;
					 &g_AMS_PATH\ACTMREF1,;
					 &g_AMS_PATH\ACTMREF2

   Acctmast->(dbsetorder(5))
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_AMS_PATH\SLV',.f.,5 )
      return .f.
   endif
   set index to &g_AMS_PATH\SLV
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_CIS_PATH'+'\INDUSTRY.DBF',.f.,5)
      return .f.
   endif
   set index to &g_CIS_PATH\INDUSTRY
   @ 22,mcol say '.'
   mcol := col()

   if !netuse('&g_AMS_PATH\GRPCODES',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\GRPCODES
   @ 22,mcol say '.'
   mcol := col()

   if !netuse('&g_AMS_PATH\Grpmembr',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\GRPMEMBR, &g_AMS_PATH\GRPCLNT,&g_AMS_PATH\GRPCLNT2, &g_AMS_PATH\GRPMEMB2
   Grpmembr->( dbsetorder(2) )
   @ 22,mcol say '.'
   mcol := col()

   if !netuse('&g_GL_PATH\OTHRCOMP.DBF',.f.,5 )
      return .f.
   endif
   @ 22,mcol say '.'
   mcol := col()

   if !netuse('&g_CIS_PATH\SIGNERS.DBF',.f.,5 )
      return .f.
   endif
   set index to &g_CIS_PATH\SIGNERS
   @ 22,mcol say '.'
   mcol := col()

   if !netuse( '&g_AMS_PATH\Comcodes' ,.f., 5)
      return .f.
   endif
   set index to &g_AMS_PATH\Comcodes
   @ 22,mcol say '.'
   mcol := col()

   if !netuse( '&g_AMS_PATH\Comember' ,.f.,5)
      return .f.
   endif
   set index  to &g_AMS_PATH\Comember
   @ 22,mcol say '.'
   mcol := col()

   if !netuse( '&g_grf_path\Branches', .f., 5 ) && branches
      return .f.
   else
      ordlistadd( '&g_grf_path\Brcode' )   && set index on branch code
   endif
   @ 22,mcol say '.'
   mcol := col()

   if !netuse('&g_AMS_PATH\Drop',.f.,5 )
      return .f.
   endif
   set index to &g_AMS_PATH\Drop
   @ 22,mcol say '.'
   mcol := col()

//aga.20.09.2007.open apraisal database
/*
   if !netuse('&g_CIS_PATH\apraisal',.f.,5 )
      return .f.
   endif
   set index to &g_CIS_PATH\apraisal
   @ 22,mcol say '.'
   mcol := col()
*/
//.........................

   restscreen ( ,,,,cscr )

return .t.

*****************************************
*
static function _BR_rights ( cusercode )   // ABB 10.12.2004
*****************************************
    local lretval := .f., nrec := axbranch->(recno())

    if axbranch->(dbseek(alltrim(cusercode)))

       do while !axbranch->(eof()) .and. ;
                alltrim(axbranch->user_id) == alltrim(cusercode)

//          if alltrim(axbranch->brcode) == alltrim(Acctwait->brcode) abb 03.07.2005
          if alltrim(axbranch->brcode) == alltrim(CLIENT->BRCODE)   && RED 030805 REPLACED 'g_PAR_BRCH WITH CLIENT->BRCODE
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
 Aoaccess->( dbseek ( alltrim(Acctwait->brcode) + G_USER_ID) )
 do while alltrim(Aoaccess->Aocode) == alltrim(G_USER_ID) .and. ;
          alltrim(Acctwait->brcode)  == alltrim(sbrcode)  .and. ;
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
   @ 11,12 say 'Client Code ' get cCLNTCODE pict '@R 999-99-99999' VALID ( EMPTY(cCLNTCODE) .OR. IF(VALBRCODE(LEFT(cCLNTCODE,3), g_USER_ID),.T.,EVAL({|| cCLNTCODE:=SPACE(10) ,.F.})) )

   setcursor(3)
   read
   setcursor(0)

   restscreen ( ,,,,cscr )

   if lastkey() != K_ESC
      *if Client->(dbseek(alltrim(cclntname)))
      IF EMPTY(cCLNTCODE)
         nRETVAL := 0
      ELSE
         IF CLIENT->(DBSEEK(cCLNTCODE))
            nretval := Client->(recno())
         else
            error ( 'Client N§ not found' )
         endif
      ENDIF

   endif

   Client->  ( dbsetorder(noldntx) )
   setcursor ( ccursor)

return nretval

/*
static function getaprsl()
local nretval := space(5)




return nretval
*/


*
*                           end of the program ( amsm1007.prg )
*
