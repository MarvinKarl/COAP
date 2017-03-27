/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³   PROGRAM ID.........:  amsm400c.prg                                 ³
 ³   Description........:  Acctmast file maint. (sub-module)            ³
 ³   Author.............:  Ariel B. Bulan                               ³
 ³   Date...............:  10:35am 02-Mar-1995                          ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³                         U P D A T E S                                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³        Who        ³     When      ³               Why                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³ Janet L. Bautista ³  10-Sep-1997  ³ gd, rv to 5 decimal places       ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

#include "COLF.CH"
#include "INKEY.CH"

**************************************************************************
*   Description   input module for OTICKET.dbf ( Faculty->SETCODE == 1 )
*   Parameters    type >> 'A' = Add else Edit
*   Return Value 
function s_code_1( mWHAT    , mPROCEEDS, mTERM  , mTRUERATE, mFCLTYCODE,;
                   mPAYTYPE , mGD, mRV , mFACTOR, mAMORT   , mCREDAMT  ,;
                   mRATETYPE, mUNIT    , mISF3 )
**************************************************************************
local mRECNO := recno(), mISRETURNED  := .f., mPAYCHOICES  := { '1 = IN ADVANCE','2 = IN ARREARS' }
local mSCR := savescreen ( ,,, ), getlist := {} , mcolor := setcolor()

   fshadow( 4, 29, 15, 75, 2, 'w+/gr')
   setcolor( 'bg+/gr, w+/n,,, gr+/gr' )    
   @  4, 30 say propercase( rtrim( Facility->fcltyname ) ) color 'bg+/gr'
   @  8, 56 say upper( if( mPAYTYPE $ '12', if( mPAYTYPE == '1', 'In Advance', 'In Arrears' ), '' ) ) color 'gr+/gr'
   @ 11, 58 say 'MONTH(s)' color 'gr+/gr'
   @ 12, 62 say upper( if( mRATETYPE $ '12', if( mRATETYPE == '1', 'Fixed', 'Floating' ), '' ) ) color 'gr+/gr'
   do while .t.
       @  5, 30 say '             Facility ' get mFCLTYCODE pict '@R 999-99' when .f.
       @  6, 30 say '        NetBook Value ' get mPROCEEDS  pict '999,999,999.99' when eval({|| mISRETURNED := .t., .t.}) valid mPROCEEDS > 0
       @  7, 30 say '      Items for Lease ' get mUNIT      pict '@XS21'
       @  8, 30 say '         Payment Type ' get mPAYTYPE   pict 'X' when chkwhat( mPAYCHOICES, @mPAYTYPE, 8, 56, 'Payment Type' )
       @  9, 30 say '     Guaranty Deposit ' get mGD        pict '99.999999%'
       @ 10, 30 say '       Residual Value ' get mRV        pict '99.999999%'
       @ 11, 30 say '                 Term ' get mTERM      pict '999'     valid mTERM > 0
       @ 12, 30 say '       Effective Rate ' get mTRUERATE  pict '99.9999' valid compute_1( mPROCEEDS, mPAYTYPE, mGD, mRV, mTRUERATE, mTERM, @mFACTOR, @mAMORT, @mCREDAMT, @mRATETYPE )
       @ 13, 30 say 'Monthly Rental Factor ' get mFACTOR    pict '99.9999'        when .f.
       @ 14, 30 say '       Monthly Rental ' get mAMORT     pict '999,999,999.99' when .f.
       if mISF3
          inkey(  0  )
       else
          setcursor( 3 )
          read
          setcursor( 0 )
          if lastkey() == K_ESC
             if esckey()
                exit
             else
                loop
             endif
          endif
       endif
       exit
   enddo
   go mRECNO; setcolor( mcolor )
   restscreen ( ,,,, mSCR )
return nil
**************************************************************************
*   Description   input module for Acctmast.dbf ( Faculty->SETCODE == 2 )
*   Parameters    type >> 'A' = Add else Edit
*   Return Value 
function s_code_2( mWHAT      , mPROCEEDS, mTERM  , mTRUERATE, mFCLTYCODE,;
                   mPAYTYPE   , mGD, mRV , mFACTOR, mAMORT   , mCREDAMT  ,;
                   mRATETYPE  , mUNIT    , mADDON , mISF3    , mWTAX     ,;
				   mINCENTIVE , mNERATE  , mudiamt)
***************************************************
local mRECNO := recno(), mISRETURNED := .f., mPAYCHOICES := { '1 = IN ADVANCE','2 = IN ARREARS' }
local mSCR := savescreen ( ,,, ), getlist := {}, mcolor := setcolor()

   fshadow( 4, 30, 18, 75, 2, 'w+/gr')
   setcolor( 'bg+/gr, w+/n,,, gr+/gr' )    
   @  4, 31 say propercase( rtrim( Facility->fcltyname ) ) color 'bg+/gr'
   @ 10, 56 say upper( if( mPAYTYPE $ '12', if( mPAYTYPE == '1', 'In Advance', 'In Arrears' ),'' ) ) color 'gr+/gr'
   @ 11, 58 say 'MONTH(s)' color 'gr+/gr'
   @ 12, 62 say upper( if( mRATETYPE $ '12', if( mRATETYPE == '1', 'Fixed', 'Floating' ), '' ) ) color 'gr+/gr'

   do while .t.
       @  5, 31 say '            Facility ' get mFCLTYCODE pict '@R 999-99' when .f.
       @  6, 31 say '        Net Proceeds ' get mPROCEEDS  pict '999,999,999.99' when eval({|| mISRETURNED := .t., .t.})
	   
       @  7, 31 say '            D.I/S.I. ' get mINCENTIVE pict '999,999,999.99' when .f.
       @  8, 31 say '     Withholding Tax ' get mwtax pict '999,999,999.99' when .f.   
	   
       @  9, 31 say '         Collaterals ' get mUNIT      pict '@XS21'
       @ 10, 31 say '        Payment Type ' get mPAYTYPE   pict 'X' when chkwhat( mPAYCHOICES, @mPAYTYPE,10, 56, 'Payment Type' )
       @ 11, 31 say '                Term ' get mTERM      pict '999' valid mTERM > 0
       @ 12, 31 say 'Gross Effective Rate ' get mTRUERATE  pict '99.9999' valid compute_2(mPROCEEDS,mPAYTYPE,mTRUERATE,mTERM,@mADDON,@mAMORT,@mCREDAMT,@mRATETYPE)
	   
       @ 13, 31 say '  Net Effective Rate ' get mnerate pict '99.9999%' when .f.
   
       @ 14, 31 say '         Add-On Rate ' get mADDON     pict '99.9999'        when .f.
       @ 15, 31 say 'Monthly Amortization ' get mAMORT     pict '999,999,999.99' when .f.
       @ 16, 31 say '       Credit Amount ' get mCREDAMT   pict '999,999,999.99' when .f.
       @ 17, 31 say '          UDI Amount ' get mudiamt    pict '999,999,999.99' when .f.
   
       if mISF3
          inkey (  0  )
       else  
          setcursor( 3 )
          read
          setcursor( 0 )
          if lastkey() == K_ESC
             if esckey()
                exit
             else
                loop
             endif
          endif
       endif
       exit
   enddo
   go mRECNO; setcolor( mcolor )
   restscreen ( ,,,, mSCR )
return nil
**************************************************************************
*   Description   input module for Acctmast.dbf ( Faculty->SETCODE == 3 )
*   Parameters    type >> 'A' = Add else Edit
*   Return Value 
function s_code_3( mWHAT    , mPROCEEDS, mTERM     , mTRUERATE, mFCLTYCODE,;
                   mPAYTYPE , mGD      , mRV       , mFACTOR  , mAMORT    ,; 
				   mCREDAMT , mRATETYPE, mUNIT     , mDLRCODE , mSALESREP ,;
				   mPURCAMT , mDOWNPAY , mINCENTIVE, mNERATE  , mISF3     ,;
				   mWTAX    , mudiamt )
***************************************************
local mRECNO := recno(), mISRETURNED  := .f., mPAYCHOICES  := { '1 = IN ADVANCE','2 = IN ARREARS' }
local mRATECHOICES := { '1 = FIXED     ','2 = FLOATING  ' }, GETLIST := {}
local mSCR := savescreen ( ,,, ), mcolor := setcolor()

   fshadow( 4, 30, 21, 75, 2, 'w+/gr' )
   setcolor( 'bg+/gr, w+/n,,, gr+/gr' )    
   @  4, 31 say propercase( rtrim( Facility->fcltyname ) ) color 'bg+/gr'
   @  7, 59 say dispDLRNAME( mDLRCODE ) color 'gr+/gr'
   @ 14, 56 say upper( if( mPAYTYPE $ '12', if( mPAYTYPE == '1', 'In Advance', 'In Arrears' ),'' ) ) color 'gr+/gr'
   @ 15, 58 say 'MONTH(s)' color 'gr+/gr'
   @ 16, 62 say upper( if( mRATETYPE $ '12', if( mRATETYPE == '1', 'Fixed', 'Floating' ), '' ) ) color 'gr+/gr'
   do while .t.
       @  5, 31 say '            Facility ' get mFCLTYCODE pict '@R 999-99' when .f.
       @  6, 31 say '                Unit ' get mUNIT      pict '@XS21'
       @  7, 31 say '              Dealer ' get mDLRCODE   pict '@X' when chkdlrcode ( @mDLRCODE, 7 ) valid !empty ( mDLRCODE )
       @  8, 31 say 'Sales Representative ' get mSALESREP  pict '@XS21'
       @  9, 31 say '     Purchase Amount ' get mPURCAMT   pict '999,999,999.99'
       @ 10, 31 say '        Down Payment ' get mDOWNPAY   pict  '99,999,999.99'
       @ 11, 31 say "         D.I. / S.I. " get mINCENTIVE pict  '99,999,999.99'
	   @ 12, 31 say "    Withholding Tax " get mWTAX pict  '99,999,999.99'
       @ 13, 31 say '        Net Proceeds ' get mPROCEEDS  pict '999,999,999.99' when eval({|| mISRETURNED := .t., .t.})
       @ 14, 31 say '        Payment Type ' get mPAYTYPE   pict 'X' when chkwhat( mPAYCHOICES, @mPAYTYPE, 14, 56, 'Payment Type' )
       @ 15, 31 say '                Term ' get mTERM      pict '999' valid mTERM > 0
       @ 16, 31 say 'Gross Effective Rate ' get mTRUERATE  pict '99.9999' valid compute_3(mPROCEEDS,mPAYTYPE,mTRUERATE,mTERM,@mNERATE,@mAMORT,@mCREDAMT,@mRATETYPE)
       @ 17, 31 say '  Net Effective Rate ' get mNERATE    pict '99.9999'        when .f.
       @ 18, 31 say 'Monthly Amortization ' get mAMORT     pict '999,999,999.99' when .f.
       @ 19, 31 say '       Credit Amount ' get mCREDAMT   pict '999,999,999.99' when .f.
       @ 20, 31 say '          UDI Amount ' get mudiamt    pict '999,999,999.99' when .f.
 
       if mISF3
          inkey(  0  )
       else
          setcursor( 3 )
          read
          setcursor( 0 )
          if lastkey() == K_ESC
             if esckey()
                exit
             else
                loop
             endif
          endif
       endif
       exit
   enddo
   go mRECNO; setcolor( mcolor )
   restscreen ( ,,,, mSCR )
return nil
**************************************************************************
*   Description   input module for Acctmast.dbf ( Faculty->SETCODE == 4 )
*   Parameters    type >> 'A' = Add else Edit
*   Return Value 
function s_code_4( mWHAT    , mPROCEEDS , mTERM   , mTRUERATE, mFCLTYCODE,;
                   mPAYTYPE , mGD, mRV  , mFACTOR , mAMORT   , mCREDAMT  ,;
                   mRATETYPE, mUNIT     , mDLRCODE, mSALESREP, mPURCAMT  ,;
                   mDOWNPAY , mINCENTIVE, mNERATE , mTRANTYPE, mNOTFCTN  ,;
                   mCOLEXION, mRECOURSE , mOBLIGOR, mCOLATRL , mTERMUNIT , mISF3 )
***************************************************
local mRECNO       := recno(), mISRETURNED  := .f.
local mPAYCHOICES  := { '1 = IN ADVANCE','2 = IN ARREARS' }
local mNOTCHOICES  := { '1 = WITH      ','2 = WITHOUT   ' }
local mRATECHOICES := { '1 = FIXED     ','2 = FLOATING  ' }
local mTRANCHOICES := { '1 = REVOLVING ','2 = SPECIAL   ' }
local mCOLCHOICES  := { '1 = OURS      ','2 = THEIRS    ' }
local mRECHOICES   := { '1 = WITH      ','2 = WITHOUT   ' }
local mTERMCHOICES := { '1 = DAY(s)    ','2 = MONTH(s)  ' }
local getlist := {}, mcolor := setcolor(), mSCR := savescreen ( ,,, )

   fshadow( 4, 30, 18, 75, 2, 'w+/gr' )
   setcolor( 'bg+/gr, w+/n,,, gr+/gr' )    
   @  4, 31 say propercase( rtrim( Facility->fcltyname ) ) color 'bg+/gr'
   @  8, 56 say upper( if( mPAYTYPE  $ '12' , if( mPAYTYPE  == '1', 'In Advance', 'In Arrears' ),'') ) color 'gr+/gr'
   @  9, 58 say if( mTERMUNIT $ '12' , if( mTERMUNIT == '1', 'DAY(s)', 'MONTH(s)' ),'') color 'gr+/gr'
   @ 11, 56 say upper( if( mNOTFCTN  $ '12' , if( mNOTFCTN  == '1', 'With', 'Without' ),'') ) color 'gr+/gr'
   @ 12, 56 say upper( if( mCOLEXION $ '12' , if( mCOLEXION == '1', 'Ours', 'Theirs' ),'') ) color 'gr+/gr'
   @ 13, 56 say upper( if( mRECOURSE $ '12' , if( mRECOURSE == '1', 'With', 'Without' ),'') ) color 'gr+/gr'
   do while .t.
       @  5, 31 say '            Facility ' get mFCLTYCODE pict '@R 999-99' when .f.
       @  6, 31 say '    Transaction Type ' get mTRANTYPE  pict '@X' when chkwhat( mTRANCHOICES, @mTRANTYPE, 6, 56, 'Transaction Type' ) valid mTRANTYPE $ '12'
       @  7, 31 say '        Net Proceeds ' get mPROCEEDS  pict '999,999,999.99'
       @  8, 31 say '        Payment Type ' get mPAYTYPE   pict 'X' when chkwhat( mPAYCHOICES, @mPAYTYPE, 8, 56, 'Payment Type' )
       @  9, 31 say '                Term ' get mTERM      pict '999' valid mTERM > 0 .and. eval( { || chkwhat( mTERMCHOICES, @mTERMUNIT, 9, 58, 'Term Unit' ), .t. } )
       @ 10, 31 say '      Effective Rate ' get mTRUERATE  pict '99.9999'
       @ 11, 31 say '        Notification ' get mNOTFCTN   pict '@X' when chkwhat( mNOTCHOICES, @mNOTFCTN , 11, 56, 'Notification' )
       @ 12, 31 say '          Collection ' get mCOLEXION  pict '@X' when chkwhat( mCOLCHOICES, @mCOLEXION, 12, 56, 'Collection' )
       @ 13, 31 say '            Recourse ' get mRECOURSE  pict '@X' when chkwhat( mRECHOICES , @mRECOURSE, 13, 56, 'Recourse' )
       @ 14, 31 say '             Obligor ' get mOBLIGOR   pict '@XS21' valid !empty ( mOBLIGOR )
       @ 15, 31 say '          Collateral ' get mCOLATRL   pict '@XS21' valid !empty ( mCOLATRL )
       @ 16, 31 say 'Monthly Amortization ' get mAMORT     pict '999,999,999.99' when compute_4(mPROCEEDS,mPAYTYPE,mTRUERATE,mTERM,@mAMORT,@mCREDAMT,mTERMUNIT)
       @ 17, 31 say '       Credit Amount ' get mCREDAMT   pict '999,999,999.99' when .f.
       if mISF3
          inkey(  0  )
       else
          setcursor( 3 )
          read
          setcursor( 0 )
          if lastkey() == K_ESC
             if esckey()
                exit
             else
                loop
             endif
          endif
       endif
       exit
   enddo
   go mRECNO; setcolor( mcolor )
   restscreen (,,,,mSCR)
return nil
**************************************************************************
*   Description   input module for Acctmast.dbf ( Faculty->SETCODE == 5 )
*   Parameters    type >> 'A' = Add else Edit
*   Return Value 
function s_code_5( mWHAT    , mPROCEEDS , mTERM   , mTRUERATE, mFCLTYCODE,;
                   mPAYTYPE , mGD, mRV  , mFACTOR , mAMORT   , mCREDAMT  ,;
                   mRATETYPE, mUNIT     , mDLRCODE, mSALESREP, mPURCAMT  ,;
                   mDOWNPAY , mINCENTIVE, mNERATE , mTRANTYPE, mNOTFCTN  ,;
                   mCOLEXION, mRECOURSE , mOBLIGOR, mCOLATRL , mTERMUNIT , mISF3 )
***************************************************
   local mRECNO       := recno(), mISRETURNED  := .f.
   local mPAYCHOICES  := { '1 = IN ADVANCE','2 = IN ARREARS' }
   local mNOTCHOICES  := { '1 = WITH      ','2 = WITHOUT   ' }
   local mRATECHOICES := { '1 = FIXED     ','2 = FLOATING  ' }
   local mTRANCHOICES := { '1 = REVOLVING ','2 = SPECIAL   ' }
   local mCOLCHOICES  := { '1 = OURS      ','2 = THEIRS    ' }
   local mRECHOICES   := { '1 = WITH      ','2 = WITHOUT   ' }
   local mTERMCHOICES := { '1 = DAY(s)    ','2 = MONTH(s)  ' }
   local getlist := {}, mcolor := setcolor(), mSCR := savescreen ( ,,, )

   fshadow( 4, 34, 16, 75, 2, 'w+/gr' )
   setcolor( 'bg+/gr, w+/n,,, gr+/gr' )    
   @  4, 35 say propercase( rtrim( Facility->fcltyname ) ) color 'bg+/gr'
   @  8, 56 say if( mPAYTYPE  $ '12' , if( mPAYTYPE  == '1', 'IN ADVANCE', 'IN ARREARS' ),'') color 'gr+/gr'
   @  9, 58 say if( mTERMUNIT $ '12' , if( mTERMUNIT == '1', 'DAY(s)', 'MONTH(s)' ),'') color 'gr+/gr'
   @ 11, 56 say if( mNOTFCTN  $ '12' , if( mNOTFCTN  == '1', 'WITH', 'WITHOUT' ),'') color 'gr+/gr'
   @ 12, 56 say if( mCOLEXION $ '12' , if( mCOLEXION == '1', 'OURS', 'THEIRS' ),'') color 'gr+/gr'
   @ 13, 56 say if( mRECOURSE $ '12' , if( mRECOURSE == '1', 'WITH', 'WITHOUT' ),'') color 'gr+/gr'
   do while .t.
       @  5, 35 say '        Facility ' get mFCLTYCODE pict '@R 999-99' when .f.
       @  6, 35 say 'Transaction Type ' get mTRANTYPE  pict '@X' when chkwhat( mTRANCHOICES, @mTRANTYPE, 6, 56, 'Transaction Type' ) valid mTRANTYPE $ '12'
       @  7, 35 say '    Net Proceeds ' get mPROCEEDS  pict '999,999,999.99'
       @  8, 35 say '    Payment Type ' get mPAYTYPE   pict 'X' when chkwhat( mPAYCHOICES, @mPAYTYPE, 8, 56, 'Payment Type' )
       @  9, 35 say '    Maximum Term ' get mTERM      pict '999' valid mTERM > 0 .and. eval( { || chkwhat( mTERMCHOICES, @mTERMUNIT, 9, 58, 'Term Unit' ), .t. } )
       @ 10, 35 say '   Interest Rate ' + ' NEGOTIABLE'
       @ 11, 35 say '    Notification ' get mNOTFCTN   pict '@X' when chkwhat( mNOTCHOICES, @mNOTFCTN  , 11, 56, 'Notification' )
       @ 12, 35 say '      Collection ' get mCOLEXION  pict '@X' when chkwhat( mCOLCHOICES, @mCOLEXION, 12, 56, 'Collection' )
       @ 13, 35 say '        Recourse ' get mRECOURSE  pict '@X' when chkwhat( mRECHOICES , @mRECOURSE, 13, 56, 'Recourse' )
       @ 14, 35 say '         Obligor ' get mOBLIGOR   pict '@XS21' valid !empty ( mOBLIGOR )
       @ 15, 35 say '      Collateral ' get mCOLATRL   pict '@XS21' valid !empty ( mCOLATRL )
       if mISF3
          inkey(  0  )
       else
          setcursor( 3 )
          read
          setcursor( 0 )
          if lastkey() == K_ESC
             if esckey()
                exit
             else
                loop
             endif
          endif
       endif
       exit
   enddo
   go mRECNO; setcolor( mcolor )
   restscreen ( ,,,, mSCR )
return nil
***********************************************************
*  Desc ¯ check for the dealer code using the look-up table
static function chkdlrcode ( mdlrcode,mrow )
***********************************************************
   lb_lkup('Dealer', 1, 2, @mdlrcode, 2 , 1, 09, 02, 20, 50, 'w/gr+,w/n,,,w/gr+')
   @ mrow, 57 say dispdlrname( mdlrcode ) color 'gr+/gr'
return .f.
/*
**********************************************
*  Desc ¯ search for the dealer name
static function dispdlrname( mdlrcode )
**********************************************
   local mdbf := savedbf( mdbf )
   Dealer->( dbsetorder(1) )
   Dealer->( dbseek(mdlrcode) )
   restdbf ( mdbf )
return left( Dealer->DLRNAME, 15 )
*/
////
/*
static function chkwhat( marray_, mvariable, mrow, mcol, mtitle )

mvariable := gen_achoice( marray_, val( mvariable ), mtitle )
@ mrow, mcol say subs( marray_[ val( mvariable ) ], at( '=',;
                       marray_[ val( mvariable ) ] ) + 2 ) color 'gr+/gr' 
return( .f. )
*/
*
*                      End of the Program ( amsm400c.prg )
*
