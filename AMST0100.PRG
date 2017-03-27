/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   Program ID.........:  AMST0100.prg                                         ³
³   Description........:  account execution ( main module )                    ³
³   Author.............:  Ariel B. Bulan                                       ³
³   Date...............:  02:32pm 04-Nov-1994                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                         U P D A T E S                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        Who        ³     When      ³               Why                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Janet L. Bautista ³  26-Apr-1996  ³ follow standard coding structure         ³
³ Renan Evangelista ³  25-May-1996  ³ revised the printing module              ³
³ Janet B. Salvador ³  22-Jan-1999  ³ correct computation of revdate           ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ ABB               ³  10.15.2004   ³ ONLINE                                   ³
³ MTS               ³  08.01.2008   ³ fixed a bug that alters mVALDATE         ³
³                   ³               ³   when adding                            ³
³ MTS               ³  08.12.2008   ³ changed lb_lkup() to gen_achoice()       ³
³ MTS               ³  08.14.2008   ³ modified generate_sked() for branches    ³
³ RLV               ³  9/20/2011    ³  Modified Structure for DOSRI Tagging    ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include "COLF.CH"
#include "INKEY.CH"

private norixbrrate := 0
SETKEY(K_ALT_C, { || FUNCALTC() } )
dbsetdriver('DBFNTX')
if CHKPASS(procname(), AX_LEVEL, g_USER_ID)
   if AMST0100OPEN()

      // pepe (for real-time transaction date) 04.09.2008
      //if gTRANDATE <= Flag->lastclosed     
      //   error ( 'Please Change TRANSACTION DATE in the Utilities Option' )
      //   __mrelease ( "*", .t.)
      //   dbcloseall ()
      //   return
      //endif

      nosnow( .t. )
      FT0100()
      nosnow( .f. )
   endif
   eval ({|| __mrelease( "*", .t.), dbcloseall() })
endif

return
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function FT0100()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local keys_ := { '<Ins>\-Add ', '<F2>\Edit ', '<F3>\JV ', '<F4>\Search ', '<F5>\Details ', '<F10>\More ', '<Esc>\' }
   local nROW := 5, mROW := 1, mBANNER := 'Account Execution'
   local _lretval := .f.
   private sbrcode := g_PAR_BRCH

   dbselectar ( 'Acctdaly' )
   Acctdaly-> ( dbgotop() )

   _lretval := _amstsearch( SBRCODE+space( len( substr(ACCTDALY->acctno,-5,5) ) ) )

   if lastkey() == K_ESC
      return
   endif

   if !_lretval
      return
   endif

   ACCTDALY->(DBSETORDER(3))
   if !Acctdaly->( dbseek(sbrcode+substr(Acctdaly->Acctno,-5,5)))
       __keyboard ( chr( K_INS ) )
   endif
   ACCTDALY->(DBSETORDER(1))

   scr_make ( keys_, 3, 1, 22, 78, mBANNER )
   do while eval ( { || disp_record (),;
                        gtrn0100    ( @mROW, @nROW ) ;
                      } ;
                   )
   enddo

return nil

************************************
*
static function GTRN0100(mROW, nROW)
************************************
   local mretval := .t., mKEY, lJVFOUND := .f.
   local _nskedtotal := 0 //aga.29.07.2005.check balance upon exit
   mKEY := inkey( 0 )
   
   do case

         /*************
               case mKEY == K_HOME
                  if CHKPASS(' S', AX_LEVEL, g_USER_ID )
                     ACCTDALY->( dbgotop() )
                  endif
               case mKEY == K_END
                  if CHKPASS( 'S', AX_LEVEL, g_USER_ID )
                     ACCTDALY->( dbgobottom() )
                  endif
         ************/


      case mKEY == K_UP .or. mKEY == K_PGUP
         if g_PAR_BRCH == '001'
         if CHKPASS( 'S', AX_LEVEL, g_USER_ID )
            ACCTDALY->( dbskip( -1 ) )

            if Acctdaly->(bof())
               error ( 'End of file' )
               Acctdaly->(dbseek(g_PAR_BRCH))
            else

               if Acctdaly->brcode != g_PAR_BRCH
                  error ( 'Beginning of Branch file' )
                  ACCTDALY->( dbskip( +1 ) )
               endif
            endif

         endif
         endif
      case mKEY == K_DOWN .or. mKEY == K_PGDN
         if g_PAR_BRCH == '001'
         if CHKPASS( 'S', AX_LEVEL, g_USER_ID )
            ACCTDALY->( dbskip( +1 ) )

            if Acctdaly->(eof())
               error ( 'End of file' )
               Acctdaly->(dbgobottom())
            else

               if Acctdaly->brcode != g_PAR_BRCH
                  error ( 'End of Branch file' )
                  ACCTDALY->( dbskip( -1 ) )
               endif
            endif

         endif
         endif

      case mKEY == K_DEL
         if CHKPASS( 'E', AX_LEVEL, g_USER_ID )
		    If !FTLIST->(dbseek(ACCTDALY->brcode+ACCTDALY->acctno))
               if ACCTDALY->( eof() ) .or. Acctdaly->brcode != g_PAR_BRCH
                  ERROR( 'Nothing to delete!' )
               else      
                  amstdelete( 'Delete Acct N§ ' + trans( ACCTDALY->acctno, '@R 9999-99999-99999' ) + ' and ALL ITS JOURNAL VOUCHERS' )
               endif
		    Else
				if  FTLIST->funded > 0.00  
					ALERT('Cannot delete Acct N§ ;;' + trans( ACCTDALY->acctno, '@R 9999-99999-99999' )+';; Fund Request already processed!')
				else
					amstdelete( 'Delete Acct N§ ' + trans( ACCTDALY->acctno, '@R 9999-99999-99999' ) + ' and ALL ITS JOURNAL VOUCHERS' )
				endif				
			EndIF
         endif     
      case mKEY == K_INS
         if CHKPASS( 'A', AX_LEVEL, g_USER_ID )
            AMSTUPDATE( 'A' )
         endif        
      case mKEY == K_F2
         if CHKPASS( 'E', AX_LEVEL, g_USER_ID )
		    If !FTLIST->(dbseek(ACCTDALY->brcode+ACCTDALY->acctno))
               if ACCTDALY->( eof() ) .or. Acctdaly->brcode != g_PAR_BRCH
                  ERROR( 'Nothing to edit!' )
               else
                  AMSTUPDATE( 'E' )
               endif
			Else
				if  FTLIST->funded > 0.00  
					ALERT('Cannot edit Acct N§ ;;' + trans( ACCTDALY->acctno, '@R 9999-99999-99999' )+';; Fund Request already processed!')
				else
					  AMSTUPDATE( 'E' )
				endif
            EndIf			
         endif

      case mKEY == K_F3

         if CHKPASS( 'E', AX_LEVEL, g_USER_ID )

            if ACCTDALY->( eof() )
               ERROR( 'No transaction yet!' )
            else
               if Acctdaly->brcode != g_PAR_BRCH
                  error ( 'Nothing to edit' )
               else
                  //if ACCTDALY->( netlock( 'R', 0 ) )  //pepe 8:45 AM 2/27/2009
                     amstvoucher()
                  //endif
                  //ACCTDALY->( dbunlock() )
               endif
            endif

         endif              
      case mKEY == K_F4
         if CHKPASS( 'S', AX_LEVEL, g_USER_ID )
            if ACCTDALY->( eof() )
               ERROR( 'Nothing to search!' )
            else
               amstsearch( space( len( substr(ACCTDALY->acctno,-5,5) ) ) )
            endif
         endif
      case mKEY == K_F5
         if ACCTDALY->( eof() ) .or. Acctdaly->brcode != g_PAR_BRCH
            error( 'No records to edit' )
         else
            if CHKPASS('S', AX_LEVEL, g_USER_ID)
               tones()
               f0100details()
            endif
         endif
      case mKEY == K_F10
         if CHKPASS('S', AX_LEVEL, g_USER_ID)
            if ACCTDALY->( eof() ) .or. Acctdaly->brcode != g_PAR_BRCH
               ERROR( 'No records to edit' )
            else   
               tones()
               sec_menu( .f. , 'ACCTDALY' )              
            endif

         endif

      case mKEY == K_ESC
         if Acctdaly->brcode == g_PAR_BRCH  // dapat same branch  abb 08.17.2005
			
					Tranhead->(dbseek(g_PAR_BRCH))
					do while Tranhead->BRCODE == g_PAR_BRCH .and. !Tranhead->(eof())
						if Tranhead->TRLOANNO == subs(Acctdaly->ACCTNO, -5, 5)
							lJVFOUND := .t.
							exit
						endif
						Tranhead->(dbskip())
					enddo
					
				if !lJVFOUND
					alert('Denied!! Pls. fill-up the JV Entries before exiting the booking process.')
					return .t.
				endif
			
            if !prnamt_equal_to_principal (@_nskedtotal) .and. Acctdaly->status == '1' //if for posting
             //aga.29.07.2005.check if paysked generated and balanced, for irregular accounts
               alert ( 'Sked total is '     + alltrim(trans ( _nskedtotal,"999,999,999.99")) + ' Credit Amount is ' + alltrim(trans ( Acctdaly->credamt,"999,999,999.99")))
            else
                if exitmod()
                   mretval := !mretval
                endif
            endif
				
				/*if Acctdaly->status == '1'
					Tranhead->(dbseek(g_PAR_BRCH))
					do while Tranhead->BRCODE == g_PAR_BRCH .and. !Tranhead->(eof())
						if Tranhead->TRLOANNO == subs(Acctdaly->ACCTNO, -5, 5)
							lJVFOUND := .t.
							exit
						endif
						Tranhead->(dbskip())
					enddo
					
					if lJVFOUND
						if exitmod()
						 mretval := !mretval
						endif
					else
						alert('Denied!! Pls. fill-up the JV Entries before exiting the booking process.')
						mretval := .t.
					endif
				else
                if exitmod()
                   mretval := !mretval
                endif
				endif*/

         else
             if exitmod()
                mretval := !mretval
             endif
         endif

   endcase

   tb_indicator( mKEY, @mROW, @nROW, 78, 5, 20 )
   return( mretval )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function f0100details()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mfcltycode, munit, mdlrcode, mponum, mpurcamt, munitloca, mprincipal
   local mgd, mrv, mterm, mtermunit, mtruerate, mratetype, mfactor, mamort
   local mcredamt, malir, mpayfreq, maddon, mudi, msalesrep, mdownpay, mincentive
   local mnotfctn, mcolexion, mrecourse, mobligor, mcolatrl, mtrantype
   local mpaytype, mfirstdue, mmatdate, mvaldate, mdocref, mrefno,mnerate
   local munit2  , mwtax, mudiamt

   assign_details ( @mfcltycode, @munit     , @mdlrcode  , @mponum   , @mpurcamt ,;
                    @munitloca , @mprincipal, @mgd       , @mrv      , @mterm    ,;
					@mtermunit , @mtruerate , @mratetype , @mfactor  , @mamort   ,;
					@mcredamt  , @malir     , @mpayfreq  , @maddon   , @mudi     ,;
					@msalesrep , @mdownpay  , @mincentive, @mnotfctn , @mcolexion,;
                    @mrecourse , @mobligor  , @mcolatrl  , @mtrantype, @mnerate  ,;
					'ACCTDALY' , @munit2    , @mwtax     , @mudiamt ;
                  )

   mdocref   := ACCTDALY->docref  ; mrefno   := ACCTDALY->refno
   mdlrcode  := ACCTDALY->dlrcode ; mpaytype := ACCTDALY->paytype
   mfirstdue := ACCTDALY->firstdue; mmatdate := ACCTDALY->matdate
   return( eval( { | n | check_facility( 'E', @mfcltycode, @munit     , @mdlrcode  , @mponum   , @mpurcamt ,;
                                              @munitloca , @mprincipal, @mpaytype  , @mgd, @mrv, @mterm    ,;
                                              @mtermunit , @mtruerate , @mratetype , @mfirstdue, @mpayfreq ,;
                                              @mfactor   , @mamort    , @mcredamt  , @malir    , @mmatdate ,;
                                              @msalesrep , @mdownpay  , @mincentive, mvaldate  , .t.       ,;
                                              mdocref    , mrefno     , @maddon    , @mudi     , @mnotfctn ,;
                                              @mcolexion , @mrecourse , @mobligor  , @mcolatrl , @mtrantype,;
											  @mnerate   , @munit2    , @mwtax     , @mudiamt), n } ) )

*****************************************
*
*
static function AMSTUPDATE(mwhat)
*****************************************
   local misupdated := .f., macctno, mrecno := ACCTDALY->( recno() ),mdocref2, mrefno2
   local mdocref, mrefno, mvaldate, mcondate, mclntcode, msurety1, msurety2, maocode
   local mcltrltype, mstatus, mpaymode, munitcode, mrevfreq, mcredtype, mcurrcode
   local morixunit, mcontinue := .t., mCURSOR := setcursor(), getlist := {}, mreturn := .t.
   local mleft := 21, mrayt := 55, msavethem,mdocw2:=spac(2),mdocw:=spac(2),msep:=','
   local mpaymodechoices := assign_elements( mpaymodechoices, 3 )
   local mstatchoices := assign_elements( mstatchoices, 5 )
   local mrevchoices := assign_elements( mrevchoices, 4 )
   local mfcltycode, munit, mdlrcode, mponum, mpurcamt, munitloca, mprincipal
   local mpaytype, mgd, mrv, mterm, mtermunit, mtruerate, mratetype, mfirstdue
   local mfactor, mamort, mcredamt, malir, mpayfreq, mmatdate, mrevdate,mnerate
   local maddon, mudi, msalesrep, mdownpay, mincentive, mnotfctn, mcolexion,masetcode,mappval
   local mrecourse, mobligor, mcolatrl, mtrantype, mmrr_rate, mtb_rate, misentered := .f.
   local munit2, mwtax, mudiamt
   local lvatincl
   local cbrcode := space(3),mbrcode := space(3)
   LOCAL tBR     := g_PAR_BRCH+'-',  mDOSRI := ' '
   local mdtlcode,mdtlcode2
   local nusdrate
   private mset := 0
   
   if( upper( mwhat ) == chr( 65 ), ACCTDALY->( dbgoto( lastrec() + 1 ) ), mwhat := chr( 82 ) )

   assign_header  ( @macctno  , @mdocref  , @mrefno   , @mvaldate, @mcondate  ,;
                    @mclntcode, @msurety1 , @msurety2 , @maocode , @mcltrltype,;
                    @mpaymode , @munitcode, @mrevdate , @mrevfreq, @mcredtype ,;
                    @mcurrcode, @nusdrate , @morixunit, @mmrr_rate, @mtb_rate, @mfirstdue ,;
                    @mpaytype , @mmatdate , @mstatus  , @masetcode,@mdocref2  ,;
                    @mrefno2  , @mappval  , 'ACCTDALY', @lvatincl ,;
                    @mbrcode , @mDOSRI ;
                  )

   assign_details ( @mfcltycode, @munit     , @mdlrcode , @mponum   , @mpurcamt ,;
                    @munitloca , @mprincipal, @mgd, @mrv, @mterm    , @mtermunit,;
                    @mtruerate , @mratetype , @mfactor  , @mamort   , @mcredamt ,;
                    @malir     , @mpayfreq  , @maddon   , @mudi     , @msalesrep,;
                    @mdownpay  , @mincentive, @mnotfctn , @mcolexion, @mrecourse,;
                    @mobligor  , @mcolatrl  , @mtrantype, @mnerate  , 'ACCTDALY',;
                    @munit2    , @mwtax     , @mudiamt  , @mdtlcode , @mdtlcode2 ;
                  )

   cbrcode := mbrcode         // abb 10.18.2004

   if upper(mwhat) == chr(65)  // add 05.10.2003
//
//      lvatincl := .t.              // abb 10.18.2004
//
      lvatincl := .f.
      mbrcode  := g_PAR_BRCH // abb 10.18.2004
   endif


   disp_record ()

   setcolor    ( 'gr+/b, w+/g,,, gr+/b' )
   center      ( 24, 'w+/n', if( mwhat == 'A', '® Add Record ¯', '® Edit Record ¯' ) )
   //
   // @ 04, mrayt say upper( dispreftype( ACCTDALY->docref ) )
   // mrevdate:= revwdte(mvaldate,mpaytype)
   //

   do while mcontinue
      @ 05,mrayt get mstatus pict '9' when if( lastkey() != K_ESC .and. mreturn, chkstat( mstatchoices, @mstatus, 5, mrayt ), .f. )

      @ 04,mleft get macctno ;   && RED 112204 ADDED '+4
                 pict '@R 9999-99999-99999' ;
                 when if(  lastkey() == K_ENTER .and. mwhat == 'A', eval( { | x | x := get_acctno( @macctno,@mbrcode ),  ;               //  pepe 9:23 AM 08.01.2008 added {lastkey() == K_ENTER}
                     if( lastkey() != K_ESC, eval( { || assign_header( @macctno  , @mdocref  , @mrefno   , @mvaldate , @mcondate  ,;
                                                                       @mclntcode, @msurety1 , @msurety2 , @maocode  , @mcltrltype,;
                                                                       @mpaymode , @munitcode, @mrevdate , @mrevfreq , @mcredtype ,;
                                                                       @mcurrcode, @nusdrate , @morixunit, @mmrr_rate, @mtb_rate , @mfirstdue ,;
                                                                       @mpaytype , @mmatdate , @mstatus  , @masetcode, @mdocref2  ,;
                                                                       @mrefno2  , @mappval  ,'Acctwait' , @lvatincl , @mbrcode, @mDOSRI  ) ,;
                                                       assign_details ( @mfcltycode, @munit     , @mdlrcode , @mponum   , @mpurcamt ,;
                                                                        @munitloca , @mprincipal, @mgd, @mrv, @mterm    , @mtermunit,;
                                                                        @mtruerate , @mratetype , @mfactor  , @mamort   , @mcredamt ,;
                                                                        @malir     , @mpayfreq  , @maddon   , @mudi     , @msalesrep,;
                                                                        @mdownpay  , @mincentive, @mnotfctn , @mcolexion, @mrecourse,;
                                                                        @mobligor  , @mcolatrl  , @mtrantype, @mnerate  , 'Acctwait',;
                                                                        @munit2    , @mwtax     , @mudiamt  , @mdtlcode , @mdtlcode2 ;
                                                                      );
                                                                       } ), nil ), .f. } ), .f. )
      @ 04,mrayt   get mdocw      pict '@X'         when eval({ || mdocw := if(mdocref == '1','CA','OT'),.f.})
      @ 04,mrayt+3 get mrefno     pict '@R #99999'  when .f.
      @ 04,mrayt+9 get msep       pict '@X'         when .f.
      @ 04,mrayt+11 get mdocw2    pict '@X'         when eval( { || mdocw2:= if(!empty(mdocref2),if( mdocref2 == '1','CA','OT'),'  '),.f. })
      @ 04,mrayt+14 get mrefno2   pict '@R #99999'  when .f.
      @ 06,mleft+4 get mclntcode  pict '@R 99-99999' when .f.     &&RED 112204 ADDED '+4
      @ 07,mleft   get mvaldate   pict '@D'         when eval({|| mvaldate := if( mwhat == 'A', mTrandate, mvaldate),.f. })                    //pepe 07.10.2008 when eval({|| mvaldate := mTrandate,.f. }) 

                                  //aga.06.06.2006.removed to prevent assign_header function, called when editing, to change the valdate or execution date
                                  //when eval({|| mvaldate := if( mwhat == 'A', mTrandate, mvaldate),.f. }) ;   
                                  //valid ( mvaldate >= mtrandate .and. mvaldate <= (mtrandate+5) )

      @ 07,mrayt   get maocode    pict '99999'      when .f.
      @ 08,mleft   get mcondate   pict '@D'         when lastkey()!=K_ESC  .and. mreturn
      @ 08,mrayt   get mcurrcode  pict '@X'         when .f. // when if( lastkey() != K_ESC .and. mreturn , chkcurrency( @mcurrcode ), .f. )
	  
      @ 09,mrayt+5   get mDOSRI    pict '@X' when chkDOSRI(mDOSRI,09,mrayt)
      @ 10,mleft   get mfcltycode pict '@R 999-99'  when if( lastkey() != K_ESC, eval( { || mreturn := mcontinue:= ;
                                                       check_facility( mwhat     , @mfcltycode, @munit    , @mdlrcode , @mponum  , @mpurcamt  ,;
                                                                       @munitloca, @mprincipal, @mpaytype , @mgd, @mrv, @mterm   , @mtermunit ,;
                                                                       @mtruerate, @mratetype , @mfirstdue, @mpayfreq , @mfactor , @mamort    ,;
                                                                       @mcredamt , @malir     , @mmatdate , @msalesrep, @mdownpay, @mincentive,;
                                                                       mvaldate  , .f.        , mdocref   , mrefno    , @maddon  , @mudi      ,;
                                                                       @mnotfctn , @mcolexion , @mrecourse, @mobligor , @mcolatrl, @mtrantype ,;
                                                                       @mnerate   , @munit2   , @mwtax    , @mudiamt) , .f. }) , .f. )
      @ 11,mleft   get mprincipal pict '999,999,999.99' when .f.
      @ 11,mrayt   get mtruerate  pict '99.9999'        when .f.
      @ 12,mleft   get mterm      pict '@X'             when .f.
      @ 12,mrayt   get mcredamt   pict '999,999,999.99' when .f.
      @ 13,mleft   get msurety1   pict '@!'             when lastkey() != K_ESC .and. mreturn
      @ 14,mleft   get msurety2   pict '@!'             when lastkey() != K_ESC .and. mreturn

      @ 15,mleft   get lvatincl   pict '@Y'             when lvatincl := .f.    //when if ( lastkey() != K_ESC .and. mreturn ,.t. ,.f. )   //aga.13.11.2007.false


      @ 16,mleft   get mpaymode   pict '@X'             when if( lastkey() != K_ESC .and. mreturn , chkpaymode( mpaymodechoices, @mpaymode ), .f. )
      @ 17,mleft   get mrevfreq   pict '@X'  ;
                   when if( mratetype == '2',;
                            .t.,;
                            eval({ || mrevfreq:='4',;
                                      displrevpreq( mrevfreq,17,mleft + 2,'w/b'),.f.}) ) ;
                                                             .and. mreturn .and. lastkey() <> K_ESC .and. chkreviewfreq( mrevchoices, @mrevfreq, lastkey() != K_ESC .and. mratetype == '2',17,mleft+2 ) ;
                                                             .and. eval( { || mrevdate:=revwdte( mvaldate,mpaytype,mtermunit,mrevfreq ), disprevd(mrevdate,17,21) } ) ;
                                                              valid lastkey() <> K_ESC .and. mrevfreq <> '0' .and. disprviewfreq(mrevchoices, mrevfreq, lastkey() != K_ESC .and. mratetype == '2' )  .and. ;
                                                              eval( { || mrevdate:=revwdte( mvaldate,mpaytype,mtermunit,mrevfreq ), disprevd(mrevdate,17,21) } )

      @ 18,mleft   get mrevdate   pict '@D'             when ( lastkey() != K_ESC .and. mrevfreq <> '4' .and. mreturn) valid !empty(mrevdate)
      @ 19,mleft   get mcltrltype pict '@X'             when if( lastkey() != K_ESC .and. mreturn, chkcltrltype( @mcltrltype ), .f. )
      @ 20,mleft   get morixunit  pict '@X'             when if( lastkey() != K_ESC .and. mreturn, chkcorixunitcode( @morixunit ), .f. )
      @ 21,mleft   get munitcode  pict '@X'             when if( lastkey() != K_ESC .and. mreturn, chkcbunitcode( @munitcode  ), .f. )
      @ 16,mrayt   get mcredtype  pict '@X'             when if( lastkey() != K_ESC .and. mreturn, chkcredittype( @mcredtype, 16, 58, 17, 21  ), .f. )
      @ 17,mrayt   get masetcode  pict '@X'             when if( lastkey() != K_ESC .and. mreturn, chkcbasetcode( @masetcode  ), .f. )//;     //when lastkey() <> K_ESC .and. mreturn .AND. !empty(masetcode:= eval( { || flook_online( .t.,'Asetcode',masetcode,'Asset Code',,,,,1,,,,,g_ams_path) } )) ;     &&flook( .t.,'Asetcode',masetcode,'Asset Code',,,,1,,,,,g_ams_path) } )) ;
                                                        //valid lastkey() <> K_ESC .and. mreturn .and. !empty(masetcode) .and. eval({|| dispsetnme(masetcode)} )
      @ 18,mrayt   get mmrr_rate  pict '99.9999'        when lastkey() != K_ESC .and. mreturn .and. mratetype == '2' valid mmrr_rate >= 0
      @ 19,mrayt   get mtb_rate   pict '99.9999'        when lastkey() != K_ESC .and. mreturn .and. mratetype == '2' valid mtb_rate  >= 0
      @ 20,mrayt+10  get norixbrrate pict '99.9999'     when lastkey() != K_ESC .and. mreturn .and. mratetype == '2' valid mtb_rate  >= 0

      setcursor( 3 )
      read
      setcursor( 0 )
      if lastkey() == K_ESC .or. !mreturn
         if esckey()
            mcontinue := .f.
         endif
         loop
      endif
      if lastkey() == K_ENTER  //.or. lastkey() == K_PGDN
         if mwhat == 'A'
            macctno := stuff( macctno, 5, 5, mfcltycode )
         endif
         if confirm( 'Are all entries correct?' )
            //if netlock ( mwhat, 0 )
            if(mwhat=='A',eval({|| dbappend() } ),eval( {|| netlock('R',0 ) } ) )

            if !neterr()
               save_header ( macctno  , mdocref  , mrefno   , mvaldate , mcondate  ,;
                             mclntcode, msurety1 , msurety2 , maocode  , mcltrltype,;
                             mpaymode , munitcode, mrevdate , mrevfreq , mcredtype ,;
                             mcurrcode, nusdrate , morixunit, mmrr_rate, mtb_rate , mfirstdue ,;
                             mpaytype , mmatdate , mstatus  , masetcode, mdocref2  ,;
                             mrefno2  , mappval  , lvatincl , mbrcode  , mDOSRI     ;
                           )
               save_details ( mfcltycode, munit     , mdlrcode , mponum    , mpurcamt ,;
                              munitloca , mprincipal, mgd      , mrv       , mterm    ,;
                              mtermunit , mtruerate , mratetype, mfactor   , mamort   ,;
                              mcredamt  , malir     , mpayfreq , maddon    , mudi     ,;
                              msalesrep , mdownpay  , mincentive, mnotfctn , mcolexion,;
                              mrecourse , mobligor  , mcolatrl , mtrantype , mnerate  ,;
                              munit2    , mwtax     , mudiamt  , mdtlcode  , mdtlcode2 ;
                            )
							
							

																		
																		
               misupdated := .t.
               ACCTDALY->(dbunlock())
			   Acctdaly->(dbcommit())      // abb ( 07/13/2000 )
            endif
// EVR      if( mwhat == 'A', t100updateparam(), nil )

//PEPE 08.14.2008 
            if g_PAR_BRCH != '001'
 
			   if acctdaly->PAYFREQ == '7'
                  generate_sked( mwhat )
			   else

					if Facility->SETCODE $ '1234'

					   if !(Acctdaly->PAYFREQ $ '67')
					      if Acctdaly -> TERMUNIT == '1'
					         mterm := mterm / 30
					      endif
						  create_sked(mterm,mamort,mprincipal,mcredamt)
					   endif
					   
					else

					   if Acctdaly->PAYFREQ == '1'
					      mstep  := 1
						  create_sked(mterm,mamort,mprincipal,mcredamt)
					   endif
					 
					endif
					
                  xSTR := CHK_PAR(sBRCODE) + CHK_PAR(Acctdaly->acctno) + CHK_PAR(mWHAT) + CHK_PAR(mset)
		          CPS_REQST(xSTR, 'generate_sked')
			      error ( 'Schedule Generated...' )
		          dbselectarea('Acctdaly')
			   endif

            else 
			    generate_sked( mwhat )
			endif
//------------------------------------------

            mcontinue := .f.
            mrecno := ACCTDALY->( recno() )
         endif
      endif
   enddo
   center( 24, 'w+/n', '                      ' )
   ACCTDALY->( dbgoto( mrecno ) )
   return( misupdated )

   
***************************
static function chkDOSRI(mDOSRI,nX,nY)
***************************

	if mDOSRI == 'NO '
		@ nX, nY SAY '              '
	else
		@ nX, nY SAY 'YES '+'['+mDOSRI+']'
	endif

return .f.   
   
*********************************************************************
static function create_sked( mterm,mamort,mprincipal,mcredamt )
*********************************************************************
local i, mdivisor, macctno := Acctdaly->ACCTNO, mpaydate := Acctdaly->FIRSTDUE
local mtermunit := '2', mpaynumber := 0, mintamt, mprnamt, mosbal, moldmdays
local mtot_int  := 0
local ask := 0

moldmdays  := day ( mpaydate )

//aga.31.10.2007.confirm end of month due date
if ascan({ 2,4,6,9,11 },month(mpaydate)) != 0 
   if month(mpaydate) == 2 
      if day(mpaydate) == 28 .or. day(mpaydate) == 29
         ask++
      end if
   else   
      if day(mpaydate) == 30 
         ask++
      end if
   end if
end if

if ask > 0
   if confirm( 'Every end of month due date (' + dtoc(mpaydate) + ')?')
      mset++
   else
      mset := 0
   end if
end if
//.......................

return nil

   ////////
   Function displrevpreq( mrevfreq,nrow,ncol,colr )
   @ nrow,ncol say upper( left ( disp_rev_freq ( mrevfreq ), 15 ) )  color colr
   return nil

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function DISP_RECORD()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mleft := 2, mrayt := 38,mu:=Acctwait->(indexord())
   Acctdaly->(dbsetorder(1))
   dispbegin()

   @ 04,mleft   say '      Account N§  '                          color 'w/b'
***   @ 04,col()   say tran( ACCTDALY->BRCODE+ACCTDALY->acctno, '@R 999-9999-99999-99999' ) color 'w+/b'     && RED 112204 ADDED '999-
   @ 04,col()   say tran( ACCTDALY->acctno, '@R 9999-99999-99999' ) color 'w+/b'     && RED 112204 ADDED '999-
   @ 04,mrayt+3 say '  Doc. Ref.  '                            color 'w/b'
   @ 04,col()   say dispreftype( ACCTDALY->docref  ) + ' ' + tran( ACCTDALY->refno, '@R #99999' ) color 'w+/b'
   @ 04,col()   say eval( { || if(!empty(ACCTdaly->docref2 ),eval({|| ', '+dispreftype( ACCTdaly->docref2 ) ;
                                                    + ' ' + tran( ACCTdaly->refno2, '@R #99999' ) } ),'           ') }) ;
                     color 'w+/b'

   //@ 05,mleft say 'Doc. Reference 1  '                            color 'w/b'
   //@ 05,col() say 'XX - 99999'               color 'w+/b' //tran( ACCTDALY->status, '9' )                   color 'w+/b'
   //@ 05,mrayt say 'Doc. Reference 2  '                            color 'w/b'
   //@ 05,col() say 'XX - 99999'             color 'w+/b'

   @  5,mleft say '          Branch  '                            color 'w/b'
   @  5,col() say Acctdaly->brcode + '-' + padr( _get_branch(Acctdaly->brcode),20) color 'w+/b'
   @ 05,mrayt say '        Status  '                            color 'w/b'
   @ 05,col() say tran( ACCTDALY->status, '9' )                   color 'w+/b'
   @ 05,col() say ' ' + upper( dispstat( ACCTDALY->status ) )     color 'w+/b'
   @ 06,mleft say '          Client  '                          color 'w/b'
   @ 06,col() say tran( ACCTDALY->BRCODE+ACCTDALY->clntcode, '@R 999-99-99999' ) + ' ' + upper( DISPCLNTNAME( ACCTDALY->BRCODE+ACCTDALY->CLNTCODE,44 ) ) color 'w+/b' && RED 112204 ADDED '999-   &&RED 121305 _dispclntname( Acctdaly->Brcode,ACCTDALY->clntcode )
   @ 07,mleft say '  Execution Date  '                          color 'w/b'
   @ 07,col() say tran( ACCTDALY->valdate, '@D' )                 color 'w+/b'
   @ 07,mrayt say '  AO In-Charge  '                            color 'w/b'
   @ 07,col() say ACCTDALY->aocode + left( upper( dispaoname( ACCTDALY->aocode ) ), 18 ) color 'w+/b'
   @ 08,mleft say '   Contract Date  '                          color 'w/b'
   @ 08,col() say tran( ACCTDALY->condate, '@D' )                 color 'w+/b'
   @ 08,mrayt say '      Currency  '                            color 'w/b'
   @ 08,col() say tran( ACCTDALY->currcode, '@X' ) + ' ' + left( upper( dispcurrency( ACCTDALY->currcode ) ), 18 ) color 'w+/b'
   @ 09,mrayt say '         DOSRI  '                            color 'w/b'
   @ 09,col() say tran(if(ACCTDALY->DOSRI != 'NO '.AND. !EMPTY(ACCTDALY->DOSRI),'YES '+'['+ACCTDALY->DOSRI+']' ,'NO           '),'@X') color 'w+/b'
   @ 10,mleft say '        Facility  '                          color 'w/b'
   @ 10,col() say tran( ACCTDALY->fcltycode, '@R 999-99' ) + ' ' + upper( dispfcltyname( ACCTDALY->fcltycode ) ) color 'w+/b'
   @ 11,mleft say '     Net Proceed  '                          color 'w/b'
   @ 11,col() say tran( ACCTDALY->principal, '999,999,999.99' )   color 'w+/b'
   @ 11,mrayt say '     True Rate  '                            color 'w/b'
   @ 11,col() say tran( ACCTDALY->truerate, '99.9999' ) + ' ' + upper( dispratetype( ACCTDALY->ratetype ) ) color 'w+/b'
   @ 12,mleft say '            Term  '                          color 'w/b'
   @ 12,col() say tran( ACCTDALY->term, '999' ) + ' ' + if( ACCTDALY->termunit $ '12', if( ACCTDALY->termunit == '1', 'DAY(s)  ', 'MONTH(s)' ), '        ' ) color 'w+/b'
   @ 12,mrayt say ' Credit Amount  '                            color 'w/b'
   @ 12,col() say tran( ACCTDALY->credamt, '999,999,999.99' )     color 'w+/b'
   @ 13,mleft say '          Surety  '                          color 'w/b'
   @ 13,col() say tran( ACCTDALY->surety1, '@X' )                 color 'w+/b'
   @ 14,mleft say '                  '                          color 'w/b'
   @ 14,col() say tran( ACCTDALY->surety2, '@X' )                 color 'w+/b'
   @ 15,mleft say '   VAT Inclusive  '                          color 'w/b'
   @ 15,col() say tran( ACCTDALY->vatincl, '@Y' ) + ' ' + left( upper( ' ' ), 10 ) color 'w+/b'
   @ 16,mleft say ' Mode of Payment  '                          color 'w/b'
   @ 16,col() say tran( ACCTDALY->paymode, '@X' ) + ' ' + left( upper( disp_mode_pay( ACCTDALY->paymode ) ), 10 ) color 'w+/b'
   @ 17,mleft say 'Review Frequency  '                          color 'w/b'
   @ 17,col() say tran( ACCTDALY->revfreq, '@X' ) + ' ' + upper( left( disp_rev_freq( ACCTDALY->revfreq ), 15 ) ) color 'w+/b'
   @ 18,mleft say '     Review Date  '                          color 'w/b'
   @ 18,col() say tran( ACCTDALY->revdate, '@D' )                 color 'w+/b'
   @ 19,mleft say '   CB Coll. Type  '                          color 'w/b'
   @ 19,col() say tran( ACCTDALY->cltrltype, '@!' ) + ' ' + upper( left( disp_cltrl( ACCTDALY->cltrltype ), 13 ) ) color 'w+/b'
   @ 20,mleft say '  ORIX Unit Code  '                          color 'w/b'
   @ 20,col() say tran( ACCTDALY->orixunit, '@!' ) + ' ' + upper( left( disp_orix_unit( ACCTDALY->orixunit ), 20 ) ) color 'w+/b'
   @ 21,mleft say '    CB Unit Code  '                          color 'w/b'
   @ 21,col() say tran( ACCTDALY->unitcode, '@!' ) + ' ' + upper( left( disp_unit( ACCTDALY->unitcode ), 21 ) ) color 'w+/b'
   @ 16,mrayt say 'CB Credit Type  '                            color 'w/b'
   @ 16,col() say tran( ACCTDALY->credtype, '@!' ) + ' ' + upper( left( disp_cred_type( ACCTDALY->credtype), 20 ) ) color 'w+/b'

//   @ 18,mrayt say ' MRR Increment  '                            color 'w/b'
   @ 18,mrayt say '   Phibor Rate  '                            color 'w/b'
   @ 18,col() say tran( ACCTDALY->mrr_rate, '99.9999' )          color 'w+/b'
   @ 19,mrayt say '   Mart 1 Rate  '                            color 'w/b'
   @ 19,col() say tran( ACCTDALY->tb_rate, '99.9999' )           color 'w+/b'
   @ 17,mrayt say '    Asset Code  '                            color 'w/b'
   @ 17,col() say Acctdaly->asetcode pict '@X'                   color 'w+/b'
   @ 17,COL()+1 say left( eval( {  || asetcode->(dbseek(Acctdaly->asetcode) ),Asetcode->Asetname } ), 20 ) color 'w+/b'
   @ 20,mrayt+2 say ' ORIX METRO Borr. Rate  '                            color 'w/b'
   @ 20,col() say tran( ACCTDALY->orixbrrate,'99.9999' )           color 'w+/b'
   dispend()

   Acctdaly->(dbsetorder(mu))
   return( nil )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function chkstat(mstatchoices, mstat, mROW, mCOL)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   mstat := gen_achoice ( mstatchoices, val ( mstat ), 'Status',  14, 62, 17, 78, 'W/GR+,W/N,,,W/GR+')
   @ mROW, mCOL + len( mstat ) + 1 say upper( dispstat(mstat) ) color 'gr+/b'
   return .f.

/*
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function chkcbunitcode(munitcode)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mscreen := savescreen( ,,, )
   center ( 24, 'w+/n', '® Select CB Unit Name ¯' )
   lb_lkup( 'Unitcode' ,1,1,@munitcode, 2 , 1, 10, 37, 21, 75, 'W/GR+,W/N,,,W/GR+')
   restscreen( ,,,, mscreen )
   @ 21, 24 say upper( left(disp_unit(munitcode), 21 ) ) color 'gr+/b'
   return .f.
*/
   
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function chkcbunitcode(munitcode)  //pepe 08.12.2008
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
   
   @ 21, 24 say upper( left(disp_unit(munitcode), 21 ) ) color 'gr+/b'
   return .f.
   
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function chkcbasetcode(masetcode)  //pepe 08.12.2008
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
     LOCAL nctr := 0, mARRAY_NAME := {}, aTranrecs := {}
	 
     Asetcode->(dbgotop())
     do while !Asetcode->(eof()) 
	    nctr++
        	    aadd ( mARRAY_NAME, padr(' ',' ') +   '  ' +;
                           UPPER(padr  ( Asetcode->ASETCODE,2) )  + ' ³ ' +  ;
                           UPPER(padr  ( Asetcode->ASETNAME,40))  + ' ³ ' +  ;
                           UPPER(padr  ( Asetcode->ASETLIFE,2))   + ' '      ;
              	         )
						 
				aadd(aTranrecs,Asetcode->ASETCODE)

        if Asetcode->ASETCODE == masetcode
	       masetcode :=  str(nctr)
	    endif

      Asetcode->(dbskip(+1))
      enddo
	  
   masetcode := gen_achoice ( mARRAY_NAME, val ( masetcode ),'® Select Asset Code ¯', 5, 5, 5, 5, 'W/GR+,W/N,,,W/GR+')
   masetcode := if (lastkey() != K_ESC,aTranrecs[val(masetcode)],masetcode )
   
   dispsetnme(masetcode)

   return .f.
   
   /*    RED 100605
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function chkcredittype(mcredtype)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mscreen := savescreen( ,,, )
   center ( 24, 'w+/n', '® Select Credit Type ¯' )
   lb_lkup( 'Credtype' ,1,1,@mcredtype, 2 , 1, 10, 17, 21, 75, 'W/GR+,W/N,,,W/GR+')
   restscreen( ,,,, mscreen )
   @ 16, 58 say upper( left( disp_cred_type(mcredtype), 20 ) ) color 'gr+/b'
   return .f.
   */

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function chkcredittype(mCREDTYPE, mROW, mCOL, X2, Y2)  //pepe 08.12.2008
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
   
   @ mROW, mCOL say upper( left( disp_cred_type(mcredtype), 20 ) ) color 'gr+/b'
   return .f.
   
   
/*
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function chkcorixunitcode(morixunit)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mscreen := savescreen( ,,, )
   center ( 24, 'w+/n', '® Select ORIX Unit Name ¯' )
   lb_lkup( 'Orixunit' ,1,1,@morixunit, 2 , 1, 10, 37, 21, 75, 'W/GR+,W/N,,,W/GR+')
   restscreen( ,,,, mscreen )
//    @ 20, 24 say upper( left(disp_ORIX_unit(morixunit), 20 ) ) color 'gr+/b'
   @ 20, 24 say upper( left(disp_ORIX_unit(morixunit), 16 ) ) color 'gr+/b'
   return .f.
*/


// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function chkcorixunitcode(morixunit)  //pepe 08.12.2008
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
   
   @ 20, 24 say upper( left(disp_ORIX_unit(morixunit), 16 ) ) color 'gr+/b'
   return .f.


// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function chkpayfreq(mpayfreqchoices, mpayfreq)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   mpayfreq := gen_achoice ( mpayfreqchoices, val(mpayfreq),'Payment Freq.', 10, 50, 18, 77, 'w/gr+,w/n,,,w/gr+')
   @ 17, 23 say left(upper(disp_payment_freq(mpayfreq)),15) color 'gr+/b'
   return .f.
   
/*
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function chkcltrltype(mcltrltype)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mscreen := savescreen( ,,, )
   center ( 24, 'w+/n', '® Select Collateral Name ¯' )
   lb_lkup('Colatral',1,1,@mcltrltype, 2 , 1, 10, 37, 21, 75, 'W/GR+,W/N,,,W/GR+')
   restscreen( ,,,, mscreen )
   @ 19,24 say substr(  upper(disp_cltrl(mcltrltype)),1,13) color 'gr+/b'
   return .f.
*/
   
   
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function chkcltrltype(mcltrltype)  //pepe 08.12.2008
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
   
   @ 19,24 say substr(  upper(disp_cltrl(mcltrltype)),1,13) color 'gr+/b'
   return .f.

   
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function chkpaymode(mpaymodechoices, mpaymode)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   mpaymode := gen_achoice ( mpaymodechoices, val ( mpaymode ),'Payment Mode', 15, 60, 18, 77, 'W/GR+,W/N,,,W/GR+')
   @ 16,23 say left(upper(disp_mode_pay(mpaymode)),10) color 'gr+/b'
   return .f.
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function chkcurrency(mcurrcode)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mscreen := savescreen( ,,, )
   center ( 24, 'w+/n', '® Select Currency ¯' )
   lb_lkup('Currency',1,2,@mcurrcode, 2 , 1, 14, 47, 21, 75, 'W/GR+,W/N,,,W/GR+')
   restscreen( ,,,, mscreen )
   @ 08,58 say left(upper(dispcurrency(mcurrcode)),18) color 'gr+/b'
  
   return .f.
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function chkreviewfreq(mrevchoices, mrevfreq, mflag)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   if mflag
      mrevfreq := gen_achoice ( mrevchoices, val ( mrevfreq ),'Review Frequency', 14, 57, 18, 77, 'W/GR+,W/N,,,W/GR+')
   endif
   if lastkey() != K_ESC
      @ 17, 23 say padr( upper( subs( mrevchoices[ val( mrevfreq ) ], 5 ) ), 15 ) color 'gr+/b'
   endif   
   return .t.
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function disprviewfreq(mrevchoices, mrevfreq)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   if lastkey() != K_ESC
      @ 17, 23 say padr( upper( subs( mrevchoices[ val( mrevfreq ) ], 5 ) ), 15 ) color 'gr+/b'
   endif   
   return .t.
/*
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function disp_payment_freq(mpayfreq)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mlist := space( 11 ) + 'MONTHLY    BI-MONTHLY QUARTERLY  SEMI-ANNUALANNUAL     LUMPSUM    IRREGULAR  '
   return( subs( mlist, val( mpayfreq ) * 11 + 1, 11 ) )
*/
/*-----------------------------------*/
 Static Function del_jvntry( mAcctno )
/*-----------------------------------*/
local bf:=select()     // EVR ,mu:= Tranhead->(indexord())
mAcctno := substr( mAcctno,-5, 5 )
dbselectarea('Tranhead')
// EVR dbsetorder(1)
if dbseek(g_PAR_BRCH)     // EVR 25092006 - before mAcctno
// EVR    dbeval( { || Amsjvh->Trantype := '3', del_Trn_JV(Amsjvh->Trnumber) },,;
// EVR            { || Amsjvh->Trloanno == mAcctno } )
   do while Tranhead->BRCODE == g_PAR_BRCH .and. !Tranhead->(eof())
      if Tranhead->TRLOANNO == mAcctno
         netlock( 'R', 0 )
         Tranhead->Trantype := '3'
         del_Trn_JV(g_PAR_BRCH+Tranhead->Trnumber)
// EVR          exit
      endif
      Tranhead->(dbskip())
   enddo
   dbunlock()
   dbcommit()
endif
// EVR Tranhead->(dbsetorder(mu))
Dbselectarea(bf)
return nil

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function amstdelete(message)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mrecno , mretval := .f.
   if confirm(message + '?')

      ctrldelete( ACCTDALY->acctno )
      del_schedule( ACCTDALY->acctno )
      del_cashout( ACCTDALY->acctno )
      del_docday( ACCTDALY->acctno )
      del_jvntry( Acctdaly->Acctno )
	  
	  if Acctdaly->( netlock( 'R', 0 ))
	     Acctdaly->( dbdelete() ) 
		 Acctdaly->( dbunlock() ) 
		 Acctdaly->( dbcommit() ) 
		 Acctdaly->( dbskip( +1 ) )
		 mretval := .t.
	  endif
	  
	  if Acctdaly->( eof() )
	     Acctdaly->( dbskip( -1 ) )
	  endif
	  
	  /****
      if( netlock( 'R', 0 ),;
         eval( { || ( alias() )->( dbdelete() )       ,;
                    ( alias() )->( dbskip( +1 ) )     ,;
                    mrecno := ( alias() )->( recno() ),;
                    ( alias() )->( dbunlock() )       ,;
                    if( ( alias() )->( eof() )        ,;
                    eval( { || ( alias() )->( dbskip( -1 ) ) } ), nil ) } ), nil )
         mretval := .t.
      endif
	  ****/
   endif
   
   return mretval
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function get_acctno(macctno,mbrcode)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mretval := .f., mCOLOR := setcolor(), mscr := savescreen ( ,,, )
   local getlist := {}, mCURSOR := setcursor( setcursor() )
   LOCAL tBR := mBRCODE+'-'

   macctno := if( empty( macctno ), space( 5 ), right( macctno, 5 ) )
   setcursor( 0 )
   tones()
   fshadow( 10, 21, 12, 43, 2, 'n/w' )
   setcolor( 'bg+/w, w+/n,,, gr+/w' )

   @ 11,23 say 'Acct N§ '
   @ 11,33 GET tBR WHEN .F.
   @ 11,37 get macctno pict '@K 99999' valid chk_acctno( @macctno, @mretval, mbrcode )
   setcursor( 3 )
   read
   setcursor( 0 )


   setcursor( mCURSOR )
   setcolor( mCOLOR )
   restscreen( ,,,, mscr )

return( mretval )

****************************************************
*
*
static function chk_acctno(macctno, mretval,mbrcode)
****************************************************
   local mdbf := savedbf ( mdbf ),nntx := Acctwait->(indexord())

   if lastkey() == K_ESC .or. empty( macctno )
      return .f.
   endif

   macctno := right( '00000' + alltrim( macctno ), 5 )
   if eval( { | x, y | x := ACCTDALY->( recno() ),;
                       ACCTDALY->( dbgotop() ),;
                     ACCTDALY->( dbeval( { || nil },, { || !ACCTDALY->( eof() ) .and. ACCTDALY->BRCODE+right( ACCTDALY->acctno, 5 ) != mBRCODE+macctno } ) ),;                       && RED 053005 REMOVED 'ACCTDALY->( dbeval( { || nil },, { || !ACCTDALY->( eof() ) .and. right( ACCTDALY->acctno, 5 ) != macctno } ) ),;
                     y := right( ACCTDALY->acctno, 5 ) != macctno, ACCTDALY->( dbgoto( x ) ), y } )

      Acctwait->(dbsetorder(2))

      if !Acctwait->( dbseek(mbrcode+macctno ))
         ERROR( 'No such account number!' )
      else
	     If chk_osbal(Acctwait->BRCODE,Acctwait->CLNTCODE,Acctwait->refno,Acctwait->refno2,Acctwait->DOCREF,Acctwait->DOCREF2)
		    ERROR( 'CA line fully availed!' )
            Acctwait->(dbsetorder(2))
            Acctwait->( dbseek(mbrcode+macctno ))
		 Else
            Acctwait->(dbsetorder(2))
            Acctwait->( dbseek(mbrcode+macctno ))
            macctno := Acctwait->acctno
            mretval := .t.
		 EndIf

         //macctno := Acctwait->acctno
         //mretval := .t.
      endif
   else
      ERROR( 'Account already executed!' )
   endif

   Acctwait-> ( dbsetorder(nntx) )
   restdbf( mdbf )
   return( mretval )

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   Static Function chk_osbal(cbrcd,clnt,m_refno,m_refno2,mDOCREF,mDOCREF2)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
local mBAL := 0, lreturnval := .f., ln_avail := 0
local arr_avail2 := {}

/***
   ACCTMAST->( dbseek(cbrcd+clnt) )

   Do While ACCTMAST->BRCODE+ACCTMAST->CLNTCODE == cbrcd+clnt .and. ;
           !ACCTMAST->(eof())
      If ACCTMAST->status <> '0'
		 If PURCHASE->(DBSEEK(SUBS(ACCTMAST->ACCTNO,5,5)))
            mBAL -= ACCTMAST->OSBAL
		 EndIf
 	  EndIf
   ACCTMAST->(dbskip())
   EndDo
***/   

   Acctwait->  ( dbsetorder(5) )
   /**
   if Acctwait -> (dbseek(cbrcd+m_refno+'1'))
      Acctwait -> (dbeval( { || mBAL += Acctwait->Principal  },,;
                           { || Acctwait->Refno  == m_refno           .and. ;
                                Acctwait->Docref == '1'               .and. ;
                                Acctwait->brcode == cbrcd             .and. ;
                               !Acctwait->(eof())                           ;
                           } ))
   endif
   
   **/
   
   IF mDOCREF == '1'
	  if Acctwait -> (dbseek(cbrcd+m_refno+mDOCREF))
	     do while Acctwait->Refno  == m_refno           .and. ;
	  		      Acctwait->Docref == mDOCREF           .and. ;
	  		      Acctwait->brcode == cbrcd             .and. ;
	  		     !Acctwait->(eof())  
      
	  		mBAL += Acctwait->Principal	
	  		if !empty(acctwait->refno2)
	  		   if ascan(arr_avail2,acctwait->refno2) == 0
	  			  if CAHEADER->(dbseek(cbrcd+acctwait->refno2))
	  				 if caheader->actaken == '3'
	  					ln_avail += Caheader->Prnline - Caheader->Prnavail
	  				 endif
	  			  elseif OTICKET->(dbseek(cbrcd+acctwait->refno2))
	  				 if OTICKET->actaken == '3'
	  					ln_avail += Oticket->Proceeds - Oticket->Prnavail
	  				 endif
	  			  endif
	  			  aadd(arr_avail2,acctwait->refno2)
	  		   endif
	  		endif
	     acctwait->(dbskip())
	     enddo
	  endif 
   
      If CAHEADER->(dbseek(cbrcd+m_refno+mDOCREF))
         ln_avail += Caheader->Prnline - Caheader->Prnavail
      ENDIF
   ELSE
	  If OTICKET->(dbseek(cbrcd+m_refno+mDOCREF))
         ln_avail += Oticket->Proceeds - Oticket->Prnavail
	  ENDIF
   ENDIF
   
 //alert(str(ln_avail)+' 1 '+str(Caheader->Prnline - Caheader->Prnavail)+' '+m_refno)
 
   IF !EMPTY(mDOCREF2)
      if CAHEADER->(dbseek(cbrcd+m_refno2+mDOCREF2))
         ln_avail += Caheader->Prnline - Caheader->Prnavail
      endif

      if OTICKET->(dbseek(cbrcd+m_refno2+mDOCREF2))
         ln_avail += Oticket->Proceeds - Oticket->Prnavail
      endif
   ENDIF
 
   If round(ln_avail - mBAL,2) < 0
      lreturnval := .t.
   EndIf
   
Return lreturnval

FUNCTION FUNCALTC()
IF Confirm('Do you want to Exit Abruptly ?')
   release all
   dbcloseall()
   return nil
endif
return nil

Static Function dispsetnme(xasetcode)

if Asetcode->(dbseek(xasetcode))
   @ 17, 58 say substr(Asetcode->Asetname,1,20) color 'gr+/b' //color 'w+/b'
   return .t.
else
   error('Asset code not found.')
   return .f.
endif
return .t.

Static function disprevd(mrevdate)

@ 18,21 say mrevdate pict '@D' Color 'gr+/b'
return  .t.
// Eop: AMST0100.prg //

