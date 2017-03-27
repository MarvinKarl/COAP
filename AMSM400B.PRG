/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   program ID.........:  amsm400b.prg                                         ³
³   description........:  Acct Master Data Entry ( sub-module )                ³
³   author.............:  Ariel B. Bulan                                       ³
³   date...............:  02:45pm 01-Mar-1995                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                         U P D A T E S                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        Who        ³     When      ³               Why                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                   ³               ³                                          ³
³  ABB              ³  10.18.2004   ³    ONLINE                                ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include "Colf.ch"
#include "Inkey.ch"
******************************
*
function sec_menu( mtrue , xDBF)
******************************
   local option2    , mscr   := savescreen(,,,)
   local menulist   , mcolor := setcolor ()
   local mtitle := padr( if( mtrue, 'Availment Sheet', 'Acct Execution' ), 17 )
   local macct := if( mtrue, ACCTMAST->BRCODE+Acctmast->acctno, ACCTDALY->BRCODE+Acctdaly->acctno )
   local mdbf := alias(), mntx := indexord()                    //pepe 03.11.2008 
   local arr_ := if( mtrue, { { | a | coll_info      ( a, .f., .f. ) }  ,;
                              { | a | cash_outlay    ( a, .f., .f. ) }  ,;
                              { | a | doc_list       ( a, .f., .f. ) }  ,;
                              { | a | print_availment ( a , xDBF          ) },; //{ | a | print_acct     ( a           ) }  ,;//
                              { | a | browse_schedule( a, .t.      ) }  ,;
                              { | a | printsked      ( a           ) }  ,;
                              { | a | print_udi      ( a,'Acctmast') } },;
                            { { | a | collatral_information( a, .f., .f. ) },;
                              { | a | init_cash_outlay     ( a, .f., .f. ) },;
                              { | a | doc_checklist        ( a, .f., .f. ) },;
                              { | a | print_availment      ( a, xDBF           ) },;
                              { | a | browse_sked          ( a, .t.      ) },;
                              { | a | print_sked           ( a           ) },;
                              { | a | prn_udisprd          ( a,'Acctdaly') } ;
                            } ;
                   )
   dispbegin()
   fshadow( 6, 48, 21, 76, 2, 'w+/w')
   fshade()
   dispend()

   setcolor ( 'n/bg,w+/gr')
   do while .t.
      @  7, 50 prompt ' ~Collateral Information ' message ''  messagecolor 'w+/n' triggercolor 'w+/bg'
      @ 09, 50 prompt ' ~Initial Cash Outlay    ' message ''  messagecolor 'w+/n' triggercolor 'w+/bg'
      @ 11, 50 prompt ' ~Documents Checklist    ' message ''  messagecolor 'w+/n' triggercolor 'w+/bg'
      ********* @ 13, 50 prompt ' ~Print ' + mtitle         message ''  messagecolor 'w+/n' triggercolor 'w+/bg'
      @ 13, 50 prompt ' ~Print                  ' message ''  messagecolor 'w+/n' triggercolor 'w+/bg'
      @ 15, 50 prompt ' Payment ~Schedule       ' message ''  messagecolor 'w+/n' triggercolor 'w+/bg'
      @ 17, 50 prompt ' p~Rint Payment Schedule ' message ''  messagecolor 'w+/n' triggercolor 'w+/bg'
      @ 19, 50 prompt ' Print ~UDI Spread       ' message ''  messagecolor 'w+/n' triggercolor 'w+/bg'
      menu to option2 initial option2 &&timeout 200

      if option2 > 0
         eval( arr_[ option2 ], macct )   
      else
         exit   
      endif
   enddo

   dbselectarea(mdbf)  //pepe 03.11.2008
   dbsetorder(mntx)    //pepe 03.11.2008

   setcolor   ( mcolor )
   restscreen (,,,, mscr )
return nil
////
static function fshade()

@  7, 74 say 'ß'                        color 'w/n'
@  9, 74 say 'ß'                        color 'w/n'
@ 11, 74 say 'ß'                        color 'w/n'
@ 13, 74 say 'ß'                        color 'w/n'
@ 15, 74 say 'ß'                        color 'w/n'
@ 17, 74 say 'ß'                        color 'w/n'
@ 19, 74 say 'ß'                        color 'w/n'

@ 08, 51 say 'ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ' color 'w/n'
@ 10, 51 say 'ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ' color 'w/n'
@ 12, 51 say 'ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ' color 'w/n'
@ 14, 51 say 'ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ' color 'w/n'
@ 16, 51 say 'ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ' color 'w/n'
@ 18, 51 say 'ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ' color 'w/n'
@ 20, 51 say 'ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ' color 'w/n'
return( nil )
******************************
function f0400details()
******************************
   center ( 24, 'w+/n', '® Display Details ¯' )
   mFCLTYCODE := Acctmast->FCLTYCODE; mPROCEEDS  := Acctmast->PRINCIPAL
   mTERM      := Acctmast->TERM     ; mTRUERATE  := Acctmast->TRUERATE
   mPAYTYPE   := Acctmast->PAYTYPE  ; mGD        := Acctmast->GD
   mRV        := Acctmast->RV       ; mFACTOR    := Acctmast->FACTOR
   mAMORT     := Acctmast->AMORT    ; mCREDAMT   := Acctmast->CREDAMT
   mRATETYPE  := Acctmast->RATETYPE ; mUNIT      := Acctmast->UNIT
   mADDON     := Acctmast->ADDON    ; mDLRCODE   := Acctmast->DLRCODE
   mSALESREP  := Acctmast->SALESREP ; mPURCAMT   := Acctmast->PURCAMT
   mDOWNPAY   := Acctmast->DOWNPAY  ; mINCENTIVE := Acctmast->INCENTIVE
   mNERATE    := Acctmast->NERATE   ; mTRANTYPE  := Acctmast->TRANTYPE
   mNOTFCTN   := Acctmast->NOTFCTN  ; mCOLEXION  := Acctmast->COLEXION
   mRECOURSE  := Acctmast->RECOURSE ; mOBLIGOR   := Acctmast->OBLIGOR
   mCOLATRL   := Acctmast->COLATRL  ; mTERMUNIT  := Acctmast->TERMUNIT
   mWTAX      := Acctmast->WTAX     ; mudiamt    := Acctmast->UDIAMT
   chkfcltycode( @mFCLTYCODE, @mPROCEEDS, @mTERM     , @mTRUERATE ,;
                 @mPAYTYPE  , @mGD, @mRV, @mFACTOR   , @mAMORT    ,;
                 @mCREDAMT  , @mRATETYPE, @mUNIT     , @mADDON    ,;
                 @mDLRCODE  , @mSALESREP, @mPURCAMT  , @mDOWNPAY  ,;
                 @mINCENTIVE, @mNERATE  , @mTRANTYPE , @mNOTFCTN  ,;
                 @mCOLEXION , @mRECOURSE, @mOBLIGOR  , @mCOLATRL  ,;
                 @mTERMUNIT , 'E', .t.  , @mWTAX     , @mudiamt)
   center ( 24, 'w+/n', '                          ' )
return nil
****************************************
static function chkfcltycode( mFCLTYCODE, mPROCEEDS, mTERM     , mTRUERATE  ,;
                              mPAYTYPE  , mGD, mRV , mFACTOR   , mAMORT     ,;
                              mCREDAMT  ,                        mRATETYPE  ,;
                              mUNIT     , mADDON   , mDLRCODE  , mSALESREP  ,;
                              mPURCAMT  , mDOWNPAY , mINCENTIVE, mNERATE    ,;
                              mTRANTYPE , mNOTFCTN , mCOLEXION , mRECOURSE  ,;
                              mOBLIGOR  , mCOLATRL , mTERMUNIT , mWHAT      ,;
							  mISF3     , mWTAX    , mudiamt)
****************************************
   local mRETVAL := .f.

   if empty ( mFCLTYCODE ) .and. mWHAT == 'E'
      return .f.
   endif
   if !mISF3
      lb_lkup('Facility', 1, 1,@mFCLTYCODE, 3 , 1, 11, 02+16, 19, 50+16, 'W/GR+,W/N,,,W/GR+')
   endif
   if lastkey() != K_ESC
      do case
         case Facility->SETCODE == '1'
            mTERMUNIT := '2'
            s_code_1   ( mWHAT      , @mPROCEEDS, @mTERM    , @mTRUERATE, mFCLTYCODE ,;
                         @mPAYTYPE  , @mGD, @mRV, @mFACTOR  , @mAMORT   , @mCREDAMT  ,;
                         @mRATETYPE , @mUNIT    , mISF3 )
         case Facility->SETCODE == '2'
            mTERMUNIT := '2'
            s_code_2       ( mWHAT       , @mPROCEEDS, @mTERM    , @mTRUERATE, mFCLTYCODE ,;
                             @mPAYTYPE   , @mGD, @mRV, @mFACTOR  , @mAMORT   , @mCREDAMT  ,;
                             @mRATETYPE  , @mUNIT    , @mADDON   , mISF3     , @mWTAX      ,;
							 @mINCENTIVE , @mNERATE  , @mudiamt)
         case Facility->SETCODE == '3'
            mTERMUNIT := '2'
            s_code_3       ( mWHAT      , @mPROCEEDS , @mTERM     , @mTRUERATE , mFCLTYCODE,;
                             @mPAYTYPE  , @mGD       , @mRV       , @mFACTOR   , @mAMORT   ,;
							 @mCREDAMT  , @mRATETYPE , @mUNIT     , @mDLRCODE  , @mSALESREP,;
							 @mPURCAMT  , @mDOWNPAY  , @mINCENTIVE, @mNERATE   , mISF3     ,;
							 @mWTAX     , @mudiamt   )
         case Facility->SETCODE == '4'
            s_code_4       (mWHAT      , @mPROCEEDS, @mTERM     , @mTRUERATE , mFCLTYCODE,;
                             @mPAYTYPE  , @mGD, @mRV, @mFACTOR  , @mAMORT    , @mCREDAMT ,;
                             @mRATETYPE, @mUNIT     , @mDLRCODE , @mSALESREP , @mPURCAMT ,;
                             @mDOWNPAY , @mINCENTIVE, @mNERATE  , @mTRANTYPE , @mNOTFCTN ,;
                             @mCOLEXION, @mRECOURSE , @mOBLIGOR , @mCOLATRL  , @mTERMUNIT,;
                             mISF3)
          case Facility->SETCODE == '5'
            s_code_5       (mWHAT       , @mPROCEEDS, @mTERM    , @mTRUERATE , mFCLTYCODE ,;
                             @mPAYTYPE  , @mGD, @mRV, @mFACTOR  , @mAMORT    , @mCREDAMT ,;
                             @mRATETYPE , @mUNIT     , @mDLRCODE, @mSALESREP , @mPURCAMT ,;
                             @mDOWNPAY , @mINCENTIVE, @mNERATE  , @mTRANTYPE , @mNOTFCTN ,;
                             @mCOLEXION, @mRECOURSE , @mOBLIGOR , @mCOLATRL  , @mTERMUNIT,;
                             mISF3)
      endcase
   endif
return mRETVAL
*
*                          End of the program ( amsm400b.prg )
*
