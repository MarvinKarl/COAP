/*
 ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³   PROGRAM ID.........:  AMSM300B.prg                                 Ã¿
 ³   Description........:  loan offering ticket file maint. (sub-module)³³
 ³   Author.............:  Ariel B. Bulan                               ³³
 ³   Date...............:  11:54pm 15-Aug-1994                          ³³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´³
 ³                         U P D A T E S                                ³³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´³
 ³        Who        ³     When      ³               Why                ³³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´³
 ³ Janet L. Bautista ³  16-Apr-1996  ³ correct rate type display        ³³
 ³ Janet L. Bautista ³  10-Sep-1997  ³ gd, rv to 5 decimal places       ³³
 ³ Janet B. Salvador ³  11-Feb-2003  ³ nerate <= truerate on get        ³³
 ³ ABB               ³  10.21.2004   ³ FOR ONLINE                       ³³
 ÀÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include "COLF.CH"
#include "INKEY.CH"

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
// Description   input module for SETCODE = '1'
// Parameters    type >> 'A' = Add else Edit

   function SET_CODE_ONE(mWHAT,     mPROCEEDS, mTERM,    mTRUERATE, mFCLTYCODE,;
                         mPAYTYPE,  mGD, mRV,  mFACTOR,  mAMORT,    mCREDAMT,  ;
                         mAMENDED,  mAMENDREF, mRATETYPE, mUNIT,    mISF3,     ;
                         mTERMUNIT, mUNIT2)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mOTNUMBER := OTICKET->OTNUMBER, mRECNO := recno()
   local mISRETURNED := .f., mPAYCHOICES  := { '1 = IN ADVANCE','2 = IN ARREARS' }
   local mSCR := savescreen( ,,, ), getlist := {} , mCOLOR := setcolor()

   fshadow( 4, 29, 19, 75, 2, 'w+/gr' )
   setcolor( 'bg+/gr, w+/n,,, gr+/gr' )    
   @ 04,30 say propercase( rtrim( Facility->fcltyname ) ) color 'bg+/gr'   
   @ 09,57 say if( mPAYTYPE $ '12', if( mPAYTYPE == '1', 'IN ADVANCE', 'IN ARREARS' ), '') color 'gr+/gr'
   @ 12,58 say 'MONTH(s)' color 'gr+/gr'
   @ 13,62 say if( mRATETYPE $ '12', if( mRATETYPE == '1', 'FIXED', 'FLOATING' ), '') color 'gr+/gr'
   do while .t.
      @ 05,30 say '             Facility ' get mFCLTYCODE picture '@R 999-99' when .f.
      @ 06,30 say '        NetBook Value ' get mPROCEEDS    picture '999,999,999.99' when eval({|| mISRETURNED := .t., .t.}) valid mPROCEEDS > 0
      @ 07,30 say '      Items for Lease ' get mUNIT      picture '@!S21'
      @ 08,30 say '                      ' get mUNIT2     picture '@!S21'
      @ 09,30 say '         Payment Type ' get mPAYTYPE   picture 'X' when CHKWHAT( mPAYCHOICES, @mPAYTYPE, 9, 57, 'Payment Type' )
      @ 10,30 say '     Guaranty Deposit ' get mGD        picture '99.999999%'
      @ 11,30 say '       Residual Value ' get mRV        picture '99.999999%'
      @ 12,30 say '                 Term ' get mTERM      picture '999'     valid mTERM > 0
      @ 13,30 say '       Effective Rate ' get mTRUERATE  picture '99.9999' valid COMPUTE_1( mPROCEEDS, mPAYTYPE, mGD, mRV, mTRUERATE, mTERM, @mFACTOR, @mAMORT, @mCREDAMT, @mRATETYPE, 13, 62 )
      @ 14,30 say 'Monthly Rental Factor ' get mFACTOR    picture '99.9999' when .f.
      @ 15,30 say '       Monthly Rental ' get mAMORT     picture '999,999,999.99' when .f.
      @ 16,30 say '    Total Receivables ' get mCREDAMT   picture '999,999,999.99' when .f.
      @ 17,30 say '       Terms Amended? ' get mAMENDED   picture '!' valid mAMENDED $ 'YN'
      @ 18,30 say '  Amendment Reference ' get mAMENDREF  picture '@X'
      if mISF3
         inkey( 0 )
      else
         setcursor( 3 )
         read
         setcursor( 0 )
         if lastkey() == K_ESC
            if ESCKEY()
               exit
            else
               loop
            endif
         endif
      endif
      exit
   enddo
   go mRECNO; setcolor( mCOLOR )
   restscreen( ,,,, mSCR )
   return nil
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
// Description   input module for SETCODE = '2'
// Parameters    type >> 'A' = Add else Edit

   function SET_CODE_TWO(mWHAT,    mPROCEEDS, mTERM,     mTRUERATE, mFCLTYCODE,;
                         mPAYTYPE, mGD, mRV,  mFACTOR,   mAMORT,    mCREDAMT,  ;
                         mAMENDED, mAMENDREF, mRATETYPE, mUNIT,     mADDON,    ;
                         mISF3,    mTERMUNIT, mUNIT2,    mINCENTIVE,mWTAX,     ;
						 mNERATE)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mOTNUMBER   := OTICKET->OTNUMBER, mRECNO := recno(), mISRETURNED := .f.
   local mPAYCHOICES := { '1 = IN ADVANCE','2 = IN ARREARS' }
   local mSCR        := savescreen( ,,, ), getlist := {}, mCOLOR := setcolor()

   fshadow( 4, 28, 20, 75, 2, 'w+/gr' )
   setcolor( 'bg+/gr, w+/n,,, gr+/gr' )    
   @ 04,29 say propercase( rtrim( Facility->fcltyname ) ) color 'bg+/gr'   
   @ 11,54 say if( mPAYTYPE $ '12', if( mPAYTYPE == '1', 'IN ADVANCE', 'IN ARREARS' ),'') color 'gr+/gr'
   @ 12,56 say 'MONTH(s)' color 'gr+/gr'
   @ 13,60 say if( mRATETYPE $ '12', if( mRATETYPE == '1', 'FIXED', 'FLOATING' ),'') color 'gr+/gr'
   do while .t.
       @ 05,29 say '            Facility ' get mFCLTYCODE picture '@R 999-99' when .f.
       @ 06,29 say '        Net Proceeds ' get mPROCEEDS    picture '999,999,999.99' when eval({|| mISRETURNED := .t., .t.})
       @ 07,29 say '         Collaterals ' get mUNIT      picture '@!S23'
       @ 08,29 say '                     ' get mUNIT2     picture '@!S23'
	   
	   @ 09,29 say '           D.I./S.I. ' get mINCENTIVE picture '999,999,999.99'
	   @ 10,29 say '     Withholding Tax ' get mWTAX picture '999,999,999.99'
	   	   
       @ 11,29 say '        Payment Type ' get mPAYTYPE   picture 'X' when CHKWHAT( mPAYCHOICES, @mPAYTYPE,11, 54, 'Payment Type' )
       @ 12,29 say '                Term ' get mTERM      picture '999' valid mTERM > 0
       @ 13,29 say 'Gross Effective Rate ' get mTRUERATE  picture '99.9999' valid compute_2(mPROCEEDS,mPAYTYPE,mTRUERATE,mTERM,@mADDON,@mAMORT,@mCREDAMT,@mRATETYPE, 13, 60 )
	   
       @ 14,29 say '  Net Effective Rate ' get mNERATE    picture '99.9999%' when eval({ || mNERATE := NETRATE( mPROCEEDS+mINCENTIVE+mWTAX, mAMORT, mTERM, mPAYTYPE ),.f.})
				   
       @ 15,29 say '         Add-On Rate ' get mADDON     picture '99.9999'        when .f.
       @ 16,29 say 'Monthly Amortization ' get mAMORT     picture '999,999,999.99' when .f.
       @ 17,29 say '       Credit Amount ' get mCREDAMT   picture '999,999,999.99' when .f.
       @ 18,29 say '      Terms Amended? ' get mAMENDED   picture '!' valid mAMENDED $ 'YN'
       @ 19,29 say ' Amendment Reference ' get mAMENDREF  picture '@X'
       if mISF3
          inkey(  0  )
       else
          setcursor( 3 )
          read
          setcursor( 0 )
          if lastkey() == K_ESC
             if ESCKEY()
                exit
             else
                loop
             endif
          endif
       endif
       exit
   enddo
   go mRECNO; setcolor( mCOLOR )
   restscreen ( ,,,, mSCR )
   return nil
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
// Description   input module for OTICKET.dbf ( Faculty->SETCODE == 3 )
// Parameters    type >> 'A' = Add else Edit

   function SET_CODE_3 ( mWHAT,     mPROCEEDS, mTERM,     mTRUERATE,  mFCLTYCODE,;
                         mPAYTYPE,  mGD, mRV,  mFACTOR,   mAMORT,     mCREDAMT,  ;
                         mAMENDED,  mAMENDREF, mRATETYPE, mUNIT,      mDLRCODE,  ;
                         mSALESREP, mPURCAMT,  mDOWNPAY,  mINCENTIVE, mNERATE,   ;
                         mISF3,     mTERMUNIT, mUNIT2,    mAPPVAL,    MAPPDATE,  ;
						 mWTAX )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mOTNUMBER    := OTICKET->OTNUMBER, mRECNO := recno()
   local mISRETURNED  := .f., mPAYCHOICES  := { '1 = IN ADVANCE','2 = IN ARREARS' }
   local mRATECHOICES := { '1 = FIXED     ','2 = FLOATING  ' }
   local getlist := {}, mSCR := savescreen ( ,,, ), mCOLOR := setcolor()

   fshadow  ( 3, 28, 23, 77, 2, 'w+/gr' )
   setcolor ( 'bg+/gr, w+/n,,, gr+/gr' )
   @ 03,29 say propercase( rtrim( Facility->fcltyname ) ) color 'bg+/gr'
   @ 07,57 say DISPDLRNAME( OTICKET->BRCODE+mDLRCODE )    color 'gr+/gr'
   @ 08,57 SAY DISPDLRNAME( OTICKET->BRCODE+mDLRCODE )    COLOR 'GR+/GR'   && RED 013105
   @ 16,46 say if( mPAYTYPE $ '12', if( mPAYTYPE == '1', 'IN ADVANCE', 'IN ARREARS' ),'') color 'gr+/gr'
   @ 16,69 say 'MONTH(s)' color 'gr+/gr'
   @ 17,60 say if( mRATETYPE $ '12', if( mRATETYPE == '1', 'FIXED', 'FLOATING' ),'') color 'gr+/gr'
   do while .t.
      @ 04,29 say ' Date of Application ' get mAPPDATE   PICTURE '@D'
      @ 05,29 say '            Facility ' get mFCLTYCODE picture '@R 999-99' when .f.
      @ 06,29 say '                Unit ' get mUNIT      picture '@!S23'
      @ 07,29 say '                     ' get mUNIT2     picture '@!S23'
      @ 08,29 say '              Dealer ' get mDLRCODE   picture '@X' VALID IF( EMPTY( mDLRCODE )                            ,;
                                                                                 .F.                                          ,;
                                                                                 EVAL({|| mDLRCODE := OTICKET->BRCODE+mDLRCODE,;
                                                                                          CHKDLRCODE(@mDLRCODE,8)             ,;    && RED 091005 mDLRCODE := RIGHT(mDLRCODE,4)       ,;
                                                                                          .T.                                  ;
                                                                                     })                                        ;
                                                                               )
                                                                       /*
                                                                       when  EVAL({|| mDLRCODE := OTICKET->BRCODE+mDLRCODE,;
                                                                                      CHKDLRCODE(@mDLRCODE,8)             ,;
                                                                                      mDLRCODE := RIGHT(mDLRCODE,4)       ,;
                                                                                      .T.                                  ;
                                                                                  })                                       ;
                                                                       valid !empty ( mDLRCODE )            && RED 013105 '@
                                                                       */

      @ 09,29 say 'Sales Representative ' get mSALESREP  picture '@XS20'
      @ 10,29 say '     Appraised Value ' get mAPPVAL    picture '999,999,999.99'
      @ 11,29 say '     Purchase Amount ' get mPURCAMT   picture '999,999,999.99'
      @ 12,29 say '        Down Payment ' get mDOWNPAY   picture '999,999,999.99'
//      @ 13,29 say "  Dealer's Incentive " get mINCENTIVE picture '999,999,999.99' ;
      @ 13,29 say "         D.I. / S.I. " get mINCENTIVE picture '999,999,999.99' ;
                                           valid eval (  { ||  ;
                                                             if (  mpurcamt < mappval ,;
                                                                   mProceeds:= mPurcamt - mDownpay,;
                                                                   mProceeds:= mappval  - mDownpay;
                                                                ),;
                                                             .t. ;
                                                        };
                                                      )
      @ 14,29 say '     Withholding Tax ' get mWTAX picture '999,999,999.99'
	  
      @ 15,29 say '        Net Proceeds ' get mPROCEEDS  picture '999,999,999.99' when eval({|| mISRETURNED := .t., .f.})
      @ 16,29 say 'Payment Type ' get mPAYTYPE   picture 'X' when CHKWHAT( mPAYCHOICES, @mPAYTYPE, 16, 46, 'Payment Type' )
      @ 16,58 say 'Term ' get mTERM      picture '999' valid mTERM > 0
      @ 17,29 say 'Gross Effective Rate ' get mTRUERATE  picture '99.9999' valid compute_3( mPROCEEDS,mPAYTYPE,mTRUERATE,mTERM,@mNERATE,@mAMORT,@mCREDAMT,@mRATETYPE, 17, 60 )
      //@ 18,29 say '  Net Effective Rate ' get mNERATE    picture '99.9999' valid mNERATE <= mTRUERATE .and. mNERATE >= 0    // jbs 02.11.2003
	  @ 18,29 say '  Net Effective Rate ' get mNERATE    picture '99.9999%' when eval({ || mNERATE := NETRATE( mPROCEEDS+mINCENTIVE+mWTAX, mAMORT, mTERM, mPAYTYPE ),.f.})
      @ 19,29 say 'Monthly Amortization ' get mAMORT     picture '999,999,999.99' when .f.
      @ 20,29 say '       Credit Amount ' get mCREDAMT   picture '999,999,999.99' when .f.
      @ 21,29 say '      Terms Amended? ' get mAMENDED   picture '!' valid mAMENDED $ 'YN'
      @ 22,29 say ' Amendment Reference ' get mAMENDREF  picture '@X'
      if mISF3
         inkey (  0  )
      else
         setcursor( 3 )
         read
         setcursor( 0 ) 
         if lastkey() == K_ESC
            if ESCKEY()
               exit
            else
               loop
            endif
         endif
      endif
      exit
   enddo
   go mRECNO; setcolor( mCOLOR )
   restscreen ( ,,,, mSCR )
   return nil
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
// Description   input module for Faculty->SETCODE == 5
// Parameters    type >> 'A' = Add else Edit

   function SET_CODE_5( mWHAT,     mPROCEEDS, mTERM,     mTRUERATE,  mFCLTYCODE, ;
                        mPAYTYPE,  mGD, mRV,  mFACTOR,   mAMORT,     mCREDAMT,   ;
                        mAMENDED,  mAMENDREF, mRATETYPE, mUNIT,      mDLRCODE,   ;
                        mSALESREP, mPURCAMT,  mDOWNPAY,  mINCENTIVE, mNERATE,    ;
                        mTRANTYPE, mNOTFCTN,  mCOLEXION, mRECOURSE,  mOBLIGOR,   ;
                        mCOLATRL,  mTERMUNIT, mISF3,     mUNIT2,     mFORMULA, mPAYFREQ;
                      )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mOTNUMBER    := OTICKET->OTNUMBER, mRECNO := recno()
   local mISRETURNED  := .f.
   local mFORMCHOICES := { '1 = SIMPLE INTEREST ', '2 = TRUE DISCOUNTING' }
   local mFREQCHOICES := { '1 = MONTHLY    ', '2 = BI-MONTHLY ', '3 = QUARTERLY  ',;
                           '4 = SEMI-ANNUAL', '5 = ANNUAL     ', '6 = LUMPSUM    ',;
                           '7 = IRREGULAR  ' }
   local mNOTCHOICES  := { '1 = WITH      ','2 = WITHOUT   ' }
   local mRATECHOICES := { '1 = FIXED     ','2 = NEGOTIABLE' }
   local mTRANCHOICES := { '1 = REVOLVING ','2 = SPECIAL   ' }
   local mCOLCHOICES  := { '1 = OURS      ','2 = THEIRS    ' }
   local mRECHOICES   := { '1 = WITH      ','2 = WITHOUT   ' }
   local mTERMCHOICES := { '1 = DAY(s)    ','2 = MONTH(s)  ' }
   local getlist      := {}, mCOLOR := setcolor(), mSCR := savescreen ( ,,, )

   fshadow( 4, 29, 22, 75, 2, 'w+/gr' )
   setcolor( 'bg+/gr, w+/n,,, gr+/gr' )    
   @ 04,30 say propercase( rtrim( Facility->fcltyname ) ) color 'bg+/gr'
   @ 06,54 say if( empty( mTRANTYPE ), '', subs( mTRANCHOICES[ val( mTRANTYPE ) ], 5 ) ) color 'gr+/gr'
   @ 08,56 say if( empty( mTERMUNIT ), '', subs( mTERMCHOICES[ val( mTERMUNIT ) ], 5 ) ) color 'gr+/gr'
   @ 09,54 say if( empty( mRATETYPE ), '', subs( mRATECHOICES[ val( mRATETYPE ) ], 5 ) ) color 'gr+/gr'
   @ 11,54 say if( empty( mFORMULA  ), '', subs( mFORMCHOICES[ val( mFORMULA  ) ], 5 ) ) color 'gr+/gr'
   @ 12,54 say if( empty( mPAYFREQ  ), '', subs( mFREQCHOICES[ val( mPAYFREQ  ) ], 5 ) ) color 'gr+/gr'
   @ 15,54 say if( empty( mNOTFCTN  ), '', subs( mNOTCHOICES [ val( mNOTFCTN  ) ], 5 ) ) color 'gr+/gr'
   @ 16,54 say if( empty( mCOLEXION ), '', subs( mCOLCHOICES [ val( mCOLEXION ) ], 5 ) ) color 'gr+/gr'
   @ 17,54 say if( empty( mRECOURSE ), '', subs( mRECHOICES  [ val( mRECOURSE ) ], 5 ) ) color 'gr+/gr'
   mPAYTYPE := '2'

   do while .t.
      @ 05,30 say '           Facility ' get mFCLTYCODE picture '@R 999-99' when .f.
      @ 06,30 say '   Transaction Type ' get mTRANTYPE  picture '@X' when CHKWHAT( mTRANCHOICES, @mTRANTYPE, 6, 54, 'Transaction Type' ) valid mTRANTYPE $ '12'
      @ 07,30 say '       Net Proceeds ' get mPROCEEDS    picture '999,999,999.99'
      @ 08,30 say '       Maximum Term ' get mTERM      picture '999' valid mTERM > 0 .and. eval( { || CHKWHAT( mTERMCHOICES, @mTERMUNIT, 8, 56, 'Term Unit' ), .t. } )
      @ 09,30 say '          Rate Type ' get mRATETYPE  picture '@X' when CHKWHAT( mRATECHOICES, @mRATETYPE, 9, 54, 'Rate Type' )
      @ 10,30 say '      Interest Rate ' get mTRUERATE  picture '99.9999' valid !empty( mtruerate )
************       @ 11,30 say '            Formula ' get mFORMULA   picture '@X' when if( mRATETYPE != '1', .t., eval( { || mFORMULA := ' ', setpos( 11, 54 ), qqout( padr( '', 16 ) ), .f. } ) ) .and. CHKWHAT( mFORMCHOICES, @mFORMULA, 11, 54, 'Formula' )
      @ 11,30 say '            Formula ' ;
              get mformula                ;
              picture '@X'                ;
              when if ( mRATETYPE != '1',;
                        .t.             ,;
                        eval ( { || mformula := ' '  ,;
                                    setpos( 11, 54 ) ,;
                                    qqout( padr( '', 16 ) ),;
                                    .f. ;
                               } ;
                             ) ;
                        ) .and. ;
                        chkwhat( mFORMCHOICES, @mFORMULA, 11, 54, 'Formula' )

      @ 12,30 say '  Payment Frequency ' ;
              get mPAYFREQ                ;
              picture '@X'                ;
              when eval( { || !CHKWHAT( mFREQCHOICES, @mPAYFREQ, 12, 54, 'Payment Frequency' ),.t.}) ;
              valid chk_pay_freq ( mTERM, mTERMUNIT, mPAYFREQ, mFREQCHOICES ) .and.;
                    _formulation  ( mFORMULA, mTERMUNIT, mProceeds, mTRUERATE, mTERM, mPAYFREQ, @mCREDAMT, @mAMORT, mRATETYPE )

      @ 13,30 say '       Amortization ' get mAMORT     picture '999,999,999.99' when .f.
      @ 14,30 say '      Credit Amount ' get mCREDAMT   picture '999,999,999.99' when .f.
      @ 15,30 say '       Notification ' get mNOTFCTN   picture '@X' when CHKWHAT( mNOTCHOICES, @mNOTFCTN, 15, 54, 'Notification' )
      @ 16,30 say '         Collection ' get mCOLEXION  picture '@X' when CHKWHAT( mCOLCHOICES, @mCOLEXION, 16, 54, 'Collection' )
      @ 17,30 say '           Recourse ' get mRECOURSE  picture '@X' when CHKWHAT( mRECHOICES , @mRECOURSE, 17, 54, 'Recourse' )
      @ 18,30 say '            Obligor ' get mOBLIGOR   picture '@XS23' valid !empty ( mOBLIGOR )
      @ 19,30 say '         Collateral ' get mCOLATRL   picture '@XS23' valid !empty ( mCOLATRL )
      @ 20,30 say '     Terms Amended? ' get mAMENDED   picture '!' valid mAMENDED $ 'YN'
      @ 21,30 say 'Amendment Reference ' get mAMENDREF  picture '@X'
      if mISF3
         inkey (  0  )
      else
        setcursor( 3 )
        read
        setcursor( 0 )
        if lastkey() == K_ESC
           if ESCKEY()
              exit
           else
              loop
           endif
        endif
      endif
      exit
   enddo
   go mRECNO; setcolor( mCOLOR )
   restscreen ( ,,,, mSCR )
   return nil
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   function chk_pay_freq( nTERM, nTERMUNIT, npayfreq, mfreqchoices_ )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mreturn := { | t | t, !.t. }   

   do case
      case nTERMUNIT == '1'
         do case
            case npayfreq == '1'
               mreturn := { | t | t > 30 }
            case npayfreq == '2'
               mreturn := { | t | t > 60 }
            case npayfreq == '3'
               mreturn := { | t | t > 90 }
            case npayfreq == '4'
               mreturn := { | t | t > 180 }
            case npayfreq == '5'
               mreturn := { | t | t > 360 }
         otherwise
               mreturn:={ | t | t > 0 }
         endcase
      case nTERMUNIT == '2'
         do case
            case npayfreq == '1'
               mreturn := { | t | t > 1 }
            case npayfreq == '2'
               mreturn := { | t | t > 2 }
            case npayfreq == '3'
               mreturn := { | t | t > 3 }
            case npayfreq == '4'
               mreturn := { | t | t > 6 }
            case npayfreq == '5'
               mreturn := { | t | t > 12 }
         otherwise
               mreturn:={ | t | t > 0 }
      endcase
   endcase
   devpos( 12, 54 )
   devout( if( empty( npayfreq  ), '',;
             subs( mfreqchoices_[ val( npayfreq  ) ], 5 ) ), 'gr+/gr' )
   return( eval( mreturn, nTERM ) )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   function FORMULATION( nFORMULA, nTERMUNIT, nPROCEEDS, nTRUERATE,;
                         nTERM, npayfreq, mCREDAMT, mAMORT, mratetype )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mINT                     
   if alltrim(mratetype) == '1'
      mCREDAMT := nPROCEEDS
      mAMORT   := 0
      mINT     := 0
      return .t.
   endif

   if nFORMULA == '1'
      if nTERMUNIT == '1'
         mINT := round( ( nPROCEEDS * ( nTRUERATE / 100 ) * nTERM ) / 360, 2 )
         mCREDAMT := nPROCEEDS + mINT
         do case
            case npayfreq == '1'
                 mAMORT := mCREDAMT / ( nTERM / 30 )
            case npayfreq == '2'
                 mAMORT := mCREDAMT / ( nTERM / 60 )
            case npayfreq == '3'
                 mAMORT := mCREDAMT / ( nTERM / 90 )
            case npayfreq == '4'
                 mAMORT := mCREDAMT / ( nTERM / 180 )
            case npayfreq == '5'
                 mAMORT := mCREDAMT / ( nTERM / 360 )
            otherwise
                mAMORT := 0
         endcase
      else
         mINT := round( ( nPROCEEDS * ( nTRUERATE / 100 ) * nTERM ) / 12, 2 )
         mCREDAMT := nPROCEEDS + mINT
         do case
         case npayfreq == '1'
              mAMORT := mCREDAMT / nTERM
         case npayfreq == '2'
              mAMORT := mCREDAMT / ( nTERM /  2 )
         case npayfreq == '3'
              mAMORT := mCREDAMT / ( nTERM /  3 )
         case npayfreq == '4'
              mAMORT := mCREDAMT / ( nTERM /  6 )
         case npayfreq == '5'
              mAMORT := mCREDAMT / ( nTERM / 12 )
         otherwise
              mAMORT := 0
         endcase
      endif
   else                    
      if nTERMUNIT == '1'
         mINT := round( nPROCEEDS - ( ( nPROCEEDS * 360 ) / ( ( ( nTRUERATE / 100 ) * nTERM ) + 360 ) ), 2 )
         mCREDAMT := nPROCEEDS + mINT
         do case
            case npayfreq == '1'
                 mAMORT := mCREDAMT / ( nTERM / 30 )
            case npayfreq == '2'
                 mAMORT := mCREDAMT / ( nTERM / 60 )
            case npayfreq == '3'
                 mAMORT := mCREDAMT / ( nTERM / 90 )
            case npayfreq == '4'
                 mAMORT := mCREDAMT / ( nTERM / 180 )
            case npayfreq == '5'
                 mAMORT := mCREDAMT / ( nTERM / 360 )
            otherwise
                 mAMORT := 0
         endcase
      else
         mINT := round( nPROCEEDS - ( ( nPROCEEDS * 12 ) / ( ( ( nTRUERATE / 100 ) * nTERM ) + 12 ) ), 2 ) 
         mCREDAMT := nPROCEEDS + mINT
         do case
            case npayfreq == '1'
                 mAMORT := mCREDAMT / nTERM
            case npayfreq == '2'
                 mAMORT := mCREDAMT / ( nTERM /  2 )
            case npayfreq == '3'
                 mAMORT := mCREDAMT / ( nTERM /  3 )
            case npayfreq == '4'
                 mAMORT := mCREDAMT / ( nTERM /  6 )
            case npayfreq == '5'
                 mAMORT := mCREDAMT / ( nTERM / 12 )
            otherwise
                 mAMORT := 0
         endcase
      endif
   endif   
   return .t.

*************************************************************************
*
static function _formulation( nformula, ntermunit, nproceeds, ntruerate,;
                              nterm, npayfreq, mcredamt, mamort, mratetype )
*************************************************************************
   local mINT

   if alltrim(mratetype) == '2'
      mCREDAMT := nPROCEEDS
      mAMORT   := 0
      mINT     := 0
      return .t.
   endif

   if nFORMULA == '1'
      if nTERMUNIT == '1'
         mINT := round( ( nPROCEEDS * ( nTRUERATE / 100 ) * nTERM ) / 360, 2 )
         mCREDAMT := nPROCEEDS + mINT
         do case
            case npayfreq == '1'
                 mAMORT := mCREDAMT / ( nTERM / 30 )
            case npayfreq == '2'
                 mAMORT := mCREDAMT / ( nTERM / 60 )
            case npayfreq == '3'
                 mAMORT := mCREDAMT / ( nTERM / 90 )
            case npayfreq == '4'
                 mAMORT := mCREDAMT / ( nTERM / 180 )
            case npayfreq == '5'
                 mAMORT := mCREDAMT / ( nTERM / 360 )
            otherwise
                mAMORT := 0
         endcase
      else
         mINT := round( ( nPROCEEDS * ( nTRUERATE / 100 ) * nTERM ) / 12, 2 )
         mCREDAMT := nPROCEEDS + mINT
         do case
         case npayfreq == '1'
              mAMORT := mCREDAMT / nTERM
         case npayfreq == '2'
              mAMORT := mCREDAMT / ( nTERM /  2 )
         case npayfreq == '3'
              mAMORT := mCREDAMT / ( nTERM /  3 )
         case npayfreq == '4'
              mAMORT := mCREDAMT / ( nTERM /  6 )
         case npayfreq == '5'
              mAMORT := mCREDAMT / ( nTERM / 12 )
         otherwise
              mAMORT := 0
         endcase
      endif
   else                    
      if nTERMUNIT == '1'
         mINT := round( nPROCEEDS - ( ( nPROCEEDS * 360 ) / ( ( ( nTRUERATE / 100 ) * nTERM ) + 360 ) ), 2 )
         mCREDAMT := nPROCEEDS + mINT
         do case
            case npayfreq == '1'
                 mAMORT := mCREDAMT / ( nTERM / 30 )
            case npayfreq == '2'
                 mAMORT := mCREDAMT / ( nTERM / 60 )
            case npayfreq == '3'
                 mAMORT := mCREDAMT / ( nTERM / 90 )
            case npayfreq == '4'
                 mAMORT := mCREDAMT / ( nTERM / 180 )
            case npayfreq == '5'
                 mAMORT := mCREDAMT / ( nTERM / 360 )
            otherwise
                 mAMORT := 0
         endcase
      else
         mINT := round( nPROCEEDS - ( ( nPROCEEDS * 12 ) / ( ( ( nTRUERATE / 100 ) * nTERM ) + 12 ) ), 2 ) 
         mCREDAMT := nPROCEEDS + mINT
         do case
            case npayfreq == '1'
                 mAMORT := mCREDAMT / nTERM
            case npayfreq == '2'
                 mAMORT := mCREDAMT / ( nTERM /  2 )
            case npayfreq == '3'
                 mAMORT := mCREDAMT / ( nTERM /  3 )
            case npayfreq == '4'
                 mAMORT := mCREDAMT / ( nTERM /  6 )
            case npayfreq == '5'
                 mAMORT := mCREDAMT / ( nTERM / 12 )
            otherwise
                 mAMORT := 0
         endcase
      endif
   endif   
   return .t.

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
// Description  check for the dealer code using the look-up table
   function CHKDLRCODE( mDLRCODE, mROW )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   LOCAL cORGDLR := mDLRCODE                       && RED 081205
   LOCAL nORGNTX := DEALER->(INDEXORD())           && RED 081205

   *lb_lkup('DEALER', 1, 2, @mDLRCODE, 2 , 1, 09, 02, 20, 50, 'w/gr+,w/n,,,w/gr+')     && RED 020905
   DO WHILE .T.  //PEPE 2:29 PM 1/28/2009
   
	  __lb_lkup('DEALER', 1, 2, @mDLRCODE, 2 , 14, 1, 09, 02, 20, 70, 'w/gr+,w/n,,,w/gr+')

	  //IF LASTKEY() == K_ESC
	     //mDLRCODE := RIGHT(cORGDLR,4)
	  //ENDIF
      IF LASTKEY() == K_ENTER .and. !EMPTY(mDLRCODE)
	     DEALER->(DBSETORDER(1))
	     IF DEALER->(DBSEEK(g_PAR_BRCH+mDLRCODE))
	        EXIT
		 ELSE
		    ERROR('DEALER CODE IS NOT AVAILABLE FOR THIS BRANCH!')
		 ENDIF
		 DEALER->(DBSETORDER(nORGNTX))
	  ENDIF
   ENDDO

   DEALER->(DBSETORDER(nORGNTX))
   DEALER->(DBSEEK(cORGDLR))

   @ mROW,57 say DISPDLRNAME( DEALER->BRCODE+mDLRCODE ) color 'gr+/gr'                 && RED 020905 REMOVED 'OTICKET->BRCODE+
   return .f.
/*
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
// Description  search for the dealer name
   function DISPDLRNAME( mDLRCODE )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mDBF := savedbf( mDBF )
   Dealer->( dbsetorder(1) )
   Dealer->( dbseek(mdlrcode) )
   restdbf ( mDBF )
   return left( Dealer->DLRNAME, 15 )

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   function CHKWHAT( marray_, mvariable, mROW, mCOL, mtitle )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   mvariable := gen_achoice( marray_, val( mvariable ), mtitle )
   @ mROW, mCOL say subs( marray_[ val( mvariable ) ], at( '=',;
                          marray_[ val( mvariable ) ] ) + 2 ) color 'gr+/gr'
   return .f.
*/
// Eop: AMSM300B.prg //
