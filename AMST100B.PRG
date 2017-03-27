/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   Program ID.........:  AMST100B.prg                                         ³
³   Description........:  account execution data entry ( sub module )          ³
³   Author.............:  Ariel B. Bulan                                       ³
³   Date...............:  07:09am 09-Nov-1994                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                         U P D A T E S                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        Who        ³     When      ³               Why                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Janet L. Bautista ³  26-Apr-1996  ³ follow standard coding structure         ³
³ ABB               ³  10.15.2004   ³ ONLINE                                   ³
³ aga               ³  14.02.2007   ³ neo paysked support for modules          ³
³ RLV               ³  9/20/2011    ³  Modified Structure for DOSRI Tagging    ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include "COLF.CH"
#include "INKEY.CH"

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   function assign_details ( mfcltycode, munit     , mdlrcode , mponum   , mpurcamt ,;
                             munitloca , mprincipal, mgd, mrv , mterm    , mtermunit,;
                             mtruerate , mratetype , mfactor  , mamort   , mcredamt ,;
                             malir     , mpayfreq  , maddon   , mudi     , msalesrep,;
                             mdownpay  , mincentive, mnotfctn , mcolexion, mrecourse,;
                             mobligor  , mcolatrl  , mtrantype, mnerate  , mdbf ,;
                             munit2    , mwtax     , mudiamt  , mdtlcode , mdtlcode2 )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   mFCLTYCODE := ( mDBF )->FCLTYCODE; mUNIT     := ( mDBF )->UNIT
   mDLRCODE   := ( mDBF )->DLRCODE  ; mPONUM    := ( mDBF )->PONUM
   mPURCAMT   := ( mDBF )->PURCAMT  ; mUNITLOCA := ( mDBF )->UNITLOCA
   mPRINCIPAL := ( mDBF )->PRINCIPAL; mGD       := ( mDBF )->GD
   mRV        := ( mDBF )->RV       ; mTERM     := ( mDBF )->TERM
   mTERMUNIT  := ( mDBF )->TERMUNIT ; mTRUERATE := ( mDBF )->TRUERATE
   mRATETYPE  := ( mDBF )->RATETYPE ; mFACTOR   := ( mDBF )->FACTOR
   mAMORT     := ( mDBF )->AMORT    ; mCREDAMT  := ( mDBF )->CREDAMT
   mALIR      := ( mDBF )->ALIR     ; mPAYFREQ  := ( mDBF )->PAYFREQ
   mADDON     := ( mDBF )->ADDON    ; mUDI      := ( mDBF )->UDI
   mSALESREP  := ( mDBF )->SALESREP ; mDOWNPAY  := ( mDBF )->DOWNPAY
   mINCENTIVE := ( mDBF )->INCENTIVE; mNOTFCTN  := ( mDBF )->NOTFCTN
   mCOLEXION  := ( mDBF )->COLEXION ; mRECOURSE := ( mDBF )->RECOURSE
   mOBLIGOR   := ( mDBF )->OBLIGOR  ; mCOLATRL  := ( mDBF )->COLATRL
   mTRANTYPE  := ( mDBF )->TRANTYPE ; mnerate   := ( mDBF )->Nerate
   munit2     := ( mDBF )->unit2    ; mwtax     := ( mDBF )->WTAX
   mudiamt    := ( mDBF )->UDIAMT
   
   mdtlcode   := ( mDBF )->dtlcode  ; mdtlcode2 := ( mDBF )->dtlcode2
   
   return( nil )

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   function save_details( mfcltycode, munit    , mdlrcode , mponum   , mpurcamt, munitloca , mprincipal, mgd, mrv ,;
                          mterm     , mtermunit, mtruerate, mratetype, mfactor , mamort    , mcredamt  , malir    ,;
                          mpayfreq  , maddon   , mudi     , msalesrep, mdownpay, mincentive, mnotfctn  , mcolexion,;
                          mrecourse , mobligor , mcolatrl , mtrantype, mnerate , munit2    , mwtax     , mudiamt  ,;
						  mdtlcode  , mdtlcode2  )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   ACCTDALY->FCLTYCODE := mFCLTYCODE; ACCTDALY->UNIT     := mUNIT
   ACCTDALY->DLRCODE   := mDLRCODE  ; ACCTDALY->PONUM    := mPONUM
   ACCTDALY->PURCAMT   := mPURCAMT  ; ACCTDALY->UNITLOCA := mUNITLOCA
   ACCTDALY->PRINCIPAL := mPRINCIPAL; ACCTDALY->GD       := mGD
   ACCTDALY->RV        := mRV       ; ACCTDALY->TERM     := mTERM
   ACCTDALY->TERMUNIT  := mTERMUNIT ; ACCTDALY->TRUERATE := mTRUERATE
   ACCTDALY->RATETYPE  := mRATETYPE ; ACCTDALY->FACTOR   := mFACTOR
   ACCTDALY->AMORT     := mAMORT    ; ACCTDALY->CREDAMT  := mCREDAMT
   ACCTDALY->ALIR      := mALIR     ; ACCTDALY->PAYFREQ  := mPAYFREQ
   ACCTDALY->ADDON     := mADDON    ; ACCTDALY->UDI      := mUDI
   ACCTDALY->SALESREP  := mSALESREP ; ACCTDALY->DOWNPAY  := mDOWNPAY
   ACCTDALY->INCENTIVE := mINCENTIVE; ACCTDALY->NOTFCTN  := mNOTFCTN
   ACCTDALY->COLEXION  := mCOLEXION ; ACCTDALY->RECOURSE := mRECOURSE
   ACCTDALY->OBLIGOR   := mOBLIGOR  ; ACCTDALY->COLATRL  := mCOLATRL
   ACCTDALY->TRANTYPE  := mTRANTYPE ; ACCTDALY->OSBAL    := mCREDAMT
   Acctdaly->Nerate    := mnerate   ; ACCTDALY->WTAX     := mwtax
   Acctdaly->unit2     := munit2    ; ACCTDALY->UDIAMT   := mUDIAMT
   
   Acctdaly->DTLCODE   := mdtlcode  ; Acctdaly->DTLCODE2 := mdtlcode2  
   
   return( nil )

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   function ASSIGN_HEADER(mACCTNO  , mDOCREF  , mREFNO   , mVALDATE, mCONDATE  ,;
                          mCLNTCODE, mSURETY1 , mSURETY2 , mAOCODE , mCLTRLTYPE,;
                          mPAYMODE , mUNITCODE, mREVDATE , mREVFREQ, mCREDTYPE ,;
                          mCURRCODE, nusdrate , mORIXUNIT, mMRR_RATE, mTB_RATE, mFIRSTDUE ,;
                          mPAYTYPE , mMATDATE , mSTATUS  , mASETCODE,mdocref2  ,;
                          mrefno2  , mappval  , mDBF     , lvatincl ,mbrcode, mDOSRI  )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
local xstat := mstatus
   memvar mTRANDATE
****

**   mACCTNO    := ( mDBF )->BRCODE+( mDBF )->ACCTNO

   mACCTNO    := ( mDBF )->ACCTNO

   mDOCREF   := ( mDBF )->DOCREF
   mREFNO     := ( mDBF )->REFNO    ; mVALDATE  := ( mDBF )->VALDATE
   mCONDATE   := mTRANDATE          ; mCLNTCODE := ( mDBF )->CLNTCODE
   mSTATUS    := ( mDBF )->STATUS   ; mSURETY1  := ( mDBF )->SURETY1
   mSURETY2   := ( mDBF )->SURETY2  ; mAOCODE   := ( mDBF )->AOCODE
   mCLTRLTYPE := ( mDBF )->CLTRLTYPE; mPAYMODE  := ( mDBF )->PAYMODE
   mUNITCODE  := ( mDBF )->UNITCODE ; mREVFREQ  := ( mDBF )->REVFREQ
   mCREDTYPE  := ( mDBF )->CREDTYPE ; mCURRCODE := ( mDBF )->CURRCODE
   mORIXUNIT  := ( mDBF )->ORIXUNIT ; mPAYTYPE  := ( mDBF )->PAYTYPE
   mASETCODE  := ( mDBF )->ASETCODE ; mDOCREF2  := ( mDBF )->DOCREF2
   mREFNO2    := ( mDBF )->REFNO2
   mAppval    := ( mDBf )->Appval
   lvatincl   := ( mdbf )->vatincl
   mbrcode    := ( mdbf )->brcode
   mDOSRI     := ( mdbf )->dosri
   nusdrate   := ( mdbf )->usdrate

   if upper(mDBF) == upper( 'ACCTDALY' )  // Edit !!!
      mFIRSTDUE := ( mDBF ) -> FIRSTDUE
      else
      if mPAYTYPE == '1'         // IN ADVANCE
         mFIRSTDUE := ( mDBF ) -> VALDATE
      else                       // IN ARREARS
         mFIRSTDUE := ADD_DATE( (mDBF)->VALDATE,1, '2' )
      endif
   endif

   if upper(mdbf) == 'ACCTWAIT'
      mstatus   := xstat
   endif

   if upper(mDBF) == upper('ACCTDALY')
      mMATDATE  := ( mDBF ) -> MATDATE
      mREVDATE  := ( mDBF ) -> REVDATE
      mCONDATE  := ( mDBF ) -> CONDATE
      mMRR_RATE := ( mDBF ) -> MRR_RATE
      mTB_RATE  := ( mDBF ) -> TB_RATE
      norixbrrate := ( mDBf )->orixbrrate
   else
      mMATDATE  := ADD_DATE( (mDBF)->VALDATE,(mDBF)->TERM,(mDBF)->TERMUNIT )
   endif
   return nil

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function ADD_DATE(mDATE, mCOUNT, mUNIT)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mRETVAL := 0, md, mm, my, mc := {}
   mc := asize ( mc, mCOUNT )
   mm := month ( mDATE )
   md := day   ( mDATE )
   my := year  ( mDATE )

   do case
      case mUNIT == '1'  // 'Days'
         mRETVAL := mDATE + mCOUNT
         mRETVAL := dtoc( mRETVAL )
      case mUNIT == '2'  // 'Months'
         aeval( mc, {|| mm++,if(mm>12,eval({|| my++,mm:=1 }),nil) } )
         mRETVAL := ltrim(trans(mm,'99'))+'/'+ltrim(trans(md,'99'))+'/'+ltrim(trans(my,'9999'))
      case mUNIT == '3'  // 'Years'
         my += mCOUNT
         mRETVAL := ltrim(trans(mm,'99'))+'/'+ltrim(trans(md,'99'))+'/'+ltrim(trans(my,'9999'))
   endcase
   return ctod(mRETVAL)

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   function SAVE_HEADER(mACCTNO  , mDOCREF  , mREFNO   , mVALDATE, mCONDATE  ,;
                        mCLNTCODE, mSURETY1 , mSURETY2 , mAOCODE , mCLTRLTYPE,;
                        mPAYMODE , mUNITCODE, mREVDATE , mREVFREQ, mCREDTYPE ,;
                        mCURRCODE, nusdrate , mORIXUNIT, mMRR_RATE, mTB_RATE, mFIRSTDUE ,;
                        mPAYTYPE , mMATDATE , mSTATUS  ,mASETCODE, mdocref2  ,;
                        mrefno2  , mappval  , lvatincl , mbrcode , mDOSRI)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   LOCAL mAcctname := saveclntname( mCLNTCODE )  && RED 112504 REMOVED ',mbrcode


   ACCTDALY->ACCTNO   := RIGHT(mACCTNO,14)
   ACCTDALY->ACCTNAME := mAcctname


**   ACCTDALY->ACCTNO    := mACCTNO   ; ACCTDALY->ACCTNAME := mAcctname
   ACCTDALY->DOCREF    := mDOCREF   ; ACCTDALY->REFNO    := mREFNO
   ACCTDALY->VALDATE   := mVALDATE  ; ACCTDALY->CONDATE  := mCONDATE
   ACCTDALY->CLNTCODE  := mCLNTCODE ; ACCTDALY->SURETY1  := mSURETY1
   ACCTDALY->SURETY2   := mSURETY2  ; ACCTDALY->AOCODE   := mAOCODE
   ACCTDALY->CLTRLTYPE := mCLTRLTYPE; ACCTDALY->PAYMODE  := mPAYMODE
   ACCTDALY->UNITCODE  := mUNITCODE ; ACCTDALY->REVDATE  := mREVDATE
   ACCTDALY->REVFREQ   := mREVFREQ  ; ACCTDALY->CREDTYPE := mCREDTYPE
   ACCTDALY->CURRCODE  := mCURRCODE ; ACCTDALY->ORIXUNIT := mORIXUNIT
   ACCTDALY->MRR_RATE  := mMRR_RATE ; ACCTDALY->TB_RATE  := mTB_RATE
   ACCTDALY->FIRSTDUE  := mFIRSTDUE ; ACCTDALY->PAYTYPE  := mPAYTYPE
   ACCTDALY->MATDATE   := mMATDATE  ; ACCTDALY->STATUS   := mSTATUS
   ACCTDALY->DOCREF2   := mDOCREF2  ; ACCTDALY->REFNO2   := mREFNO2
   ACCTDALY->USDRATE   := nusdrate

   if valtype ( masetcode ) != 'C'
      masetcode := space(2)
   endif

   ACCTDALY->ASETCODE   := mASETCODE

   Acctdaly->Appval     := mAppval
   Acctdaly->orixbrrate := norixbrrate
   Acctdaly->user_id    := g_USER_ID              // abb feb. 23, 2001
   Acctdaly->vatincl    := lvatincl
   Acctdaly->Brcode     := mbrcode                 // abb 10.18.2004
	Acctdaly->dosri 	:= mDOSRI
	
   return( nil )

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   function SAVECLNTNAME(mCLNTCODE)  && RED 112504 REMOVED ',mbrcode
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   //local mu:=select(),nord:=indexord(),nrec:=(alias())->(recno())
   local mDBF:=savedbf( mDBF )
   dbselectarea( "CLIENT" )
   CLIENT->(dbsetorder(1))

//aga.18.04.2005.seek() fails if called by amsm1007 since g_par_brch gets appended twice (e.i, 023+0230004).FIXED
//alert("1007:search string: " + g_PAR_BRCH + "+" + mclntcode)

   CLIENT->( dbseek ( g_PAR_BRCH+mCLNTCODE ) )     && RED 112504 REMOVED 'mbrcode+
   restdbf ( mDBF )
   //dbselectarea(mu)
   //dbsetorder(nord)
   //if nrec <> recno()
   //   dbgoto(nrec)
   //endif

   return CLIENT->FULLNAME

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   function UPDATE_POSITION(mPOS)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mACCTNO, mDBF := alias()
   mPOS     := 0
   mACCTNO  := (mDBF)->ACCTNO
   (mDBF) -> (dbgotop())
   (mDBF) -> (dbeval({|| if ( !(mDBF)->(deleted()) , mPOS++, nil )},,{|| (mDBF)->ACCTNO != mACCTNO .and. !(mDBF)->(eof()) }))
   mPOS++
   return nil

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   function ASSIGN_ELEMENTS(mARRAY_NAME, mSEQUENCE)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   do case
      case mSEQUENCE == 1
           mARRAY_NAME := { '1 = Credit Application '     ,'2 = Offering Ticket'}
      case mSEQUENCE == 2
           mARRAY_NAME := { '1 = Monthly','2 = Bi-monthly','3 = Quarterly','4 = Semi-annual','5 = Annual','6 = Lumpsum','7 = Irregular'}
      case mSEQUENCE == 3
           mARRAY_NAME := { '1 = Post-dated checks'       ,'2 = Cash' ,'3 = Automatic Debit' }
      case mSEQUENCE == 4
           mARRAY_NAME := { '1 = Quarterly', '2 = Semi-Annual', '3 = Annual', '4 = Not Applicable','5 = Monthly' }
      case mSEQUENCE == 5
           mARRAY_NAME := { '1 = For Posting'       ,'2 = Hold' }
   endcase
   return mARRAY_NAME

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   function CHECKTRANSACTION(mTRANCHOICES, mTRANTYPE, mROW)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   mTRANTYPE := gen_achoice( mTRANCHOICES, val( mTRANTYPE ), 'Transaction', mROW+1, 56, mROW+1+len( mTRANCHOICES ), 77, 'w/gr+,w/n,,,w/gr+' )
   @ mROW, 58 say if( mTRANTYPE == '1', 'Revolving', 'Special  ' ) color ( 'b/gr,b/gr' )
   return .f.

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   function CHECKNOTFCTN(mNOTCHOICES, mNOTFCTN, mROW)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   mNOTFCTN := gen_achoice( mNOTCHOICES, val( mNOTFCTN ), 'Notification', mROW+1, 56, mROW+1+len( mNOTCHOICES ), 77, 'w/gr+,w/n,,,w/gr+' )
   @ mROW, 58 say if( mNOTFCTN == '1', 'With   ', 'Without' ) color ( 'b/gr,b/gr' )
   return .f.

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   function CHECKCOLEXION(mCOLCHOICES, mCOLEXION, mROW)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   mCOLEXION := gen_achoice( mCOLCHOICES, val( mCOLEXION ), 'Collection', mROW+1, 56, mROW+1+len ( mCOLCHOICES ), 77, 'w/gr+,w/n,,,w/gr+' )
   @ mROW, 58 say if( mCOLEXION == '1', 'Ours  ', 'Theirs' )  color ( 'b/gr,b/gr' )
   return .f.

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   function CHECKRECOURSE(mRECHOICES, mRECOURSE, mROW)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   mRECOURSE := gen_achoice( mRECHOICES, val( mRECOURSE ), 'Recourse', mROW+1, 56, mROW+1+len ( mRECHOICES ), 77, 'w/gr+,w/n,,,w/gr+' )
   @ mROW, 58 say if( mRECOURSE == '1', 'With   ', 'Without') color ( 'b/gr,b/gr' )
   return .f.

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   function CHECK_TERM(mTERMCHOICES, mTERM, mTERMUNIT, mROW)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   if !empty ( mTERM )
      mTERMUNIT := gen_achoice( mTERMCHOICES, val( mTERMUNIT ), 'terms', mROW+1, 56, mROW+1+len( mTERMCHOICES ), 77, 'w/gr+,w/n,,,w/gr+' )
      @ mROW, 62 say if( mTERMUNIT == '1', 'Day(s)  ', 'Month(s)' ) color ( 'b/gr,b/gr' )
   endif
   return .t.

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//   function T100UPDATEPARAM()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
/* EVR 01112007 - no use
   if PARAMETR->( netlock ( 'R', 0 ) )
      PARAMETR-> LASTAN++
      PARAMETR-> ( dbcommit() )
   endif
   PARAMETR->( dbunlock() )

   UPDT_OL()            && RED 033005

   return nil
*/

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   function CHKPAYFREQ(mPAYFREQCHOICES, mPAYFREQ, mROW, mCOL)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   mPAYFREQ := gen_achoice ( mPAYFREQCHOICES, val ( mPAYFREQ ),'Payment Freq.', if ( mROW >= 17 , mROW-6 , mROW ), 21, mROW + 1 + len ( mPAYFREQCHOICES ), 41, 'W/GR+,W/N,,,W/GR+')
   @ mROW, mCOL say disp_payment_freq( mPAYFREQ) color ( 'b/gr,b/gr' )
   return .f.

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   function CHKDOCREF(mDOCREFCHOICES, mDOCREF, mROW, mCOL)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   mDOCREF := gen_achoice ( mDOCREFCHOICES, val ( mDOCREF ),'Doc. Reference', mROW+1, 21, mROW + 1 + len ( mDOCREFCHOICES ), 41, 'W/GR+,W/N,,,W/GR+')
   @ mROW, mCOL+2 say dispreftype ( mDOCREF )
   return .f.

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   function CHKREVIEWFREQ(mREVCHOICES, mREVFREQ, mROW, mCOL)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   mREVFREQ := gen_achoice ( mREVCHOICES, val ( mREVFREQ ),'Review Frequency', mROW-4, 21, mROW + 1 + len ( mREVCHOICES ), 41, 'W/GR+,W/N,,,W/GR+')
   @ mROW, mCOL+2 say upper( left ( disp_rev_freq ( mREVFREQ ), 15 ) )
   return .f.

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   function CHKCLTRLTYPE(mCLTRLTYPE, mROW, mCOL)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CENTER ( 24, 'w+/n', '® Select Collateral Name ¯' )
   lb_lkup('Colatral',1,1,@mCLTRLTYPE, 2 , 1, 10, 12, 22, 75, 'W/GR+,W/N,,,W/GR+')
   @ mROW, mCOL+3 say upper ( left ( disp_cltrl ( mCLTRLTYPE ), 15 ) )
   CENTER ( 24, 'w+/n', '                          ' )
   return .f.

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   function CHKCORIXUNITCODE(mORIXUNIT, mROW, mCOL)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CENTER ( 24, 'w+/n', '® Select ORIX Unit Name ¯' )
   lb_lkup( 'Orixunit' ,1,1,@mORIXUNIT, 2 , 1, 10, 12, 22, 75, 'W/GR+,W/N,,,W/GR+')
   @ mROW, mCOL+3 say left ( DISP_ORIX_UNIT ( mORIXUNIT ), 15 )
   CENTER ( 24, 'w+/n', '                         ' )
   return .f.

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   function CHKCBUNITCODE(mUNITCODE, mROW, mCOL)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CENTER ( 24, 'w+/n', '® Select CB Unit Name ¯' )
   lb_lkup( 'Unitcode' ,1,1,@mUNITCODE, 2 , 1, 10, 12, 22, 75, 'W/GR+,W/N,,,W/GR+')
   @ mROW, mCOL+3 say left ( disp_unit ( mUNITCODE ), 15 )
   CENTER ( 24, 'w+/n', '                       ' )
   return .f.

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   function CHKDEALERCODE(mDLRCODE, mROW, mCOL)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CENTER ( 24, 'w+/n', '® Select Dealer Name ¯' )
   tones  ()
   lb_lkup( 'Dealer' ,1, 1, @mDLRCODE, 2 , 1, 10, 12, 22, 75, 'W/GR+,W/N,,,W/GR+')
   @ mROW, mCOL say left ( DISP_DEALER ( mDLRCODE ), 15 ) color ( 'b/gr,b/gr' )
   CENTER ( 24, 'w+/n', '                      ' )
   return .f.
/*    RED 100605
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   function DISP_DEALER(mDLRCODE, mROW)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   DEALER-> ( dbseek ( g_PAR_BRCH+mDLRCODE  ) )
   return DEALER->DLRNAME

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   function CHKCREDITTYPE(mCREDTYPE, mROW, mCOL)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CENTER ( 24, 'w+/n', '® Select Credit Type ¯' )
   lb_lkup( 'Credtype' ,1,1,@mCREDTYPE, 2 , 1, 10, 12, 22, 75, 'W/GR+,W/N,,,W/GR+')
   @ mROW, mCOL+3 say left ( disp_cred_type ( mCREDTYPE ), 15 )
   CENTER ( 24, 'w+/n', '                      ' )
   return .f.
*/
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   function DISPSTAT(mSTAT)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   return if ( mstat $ '12', if( mstat == '1', 'For posting', 'Hold       ' ), space(11))
/*
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   function DISP_MODE_PAY(mPAYMODE)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   return if( mPAYMODE $ '123' ,if( mPAYMODE == '1', 'Post-dated checks',if( mPAYMODE == '2','Cash             ','Automatic Debit  ' ) ), space ( 17 ) )
*/
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   function DISPCURRENCY(mCURRCODE)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CURRENCY-> ( dbseek ( mCURRCODE ) )
   return CURRENCY->CURRNAME

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   function DISP_CRED_TYPE(mCREDTYPE)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   CREDTYPE -> ( dbseek ( mCREDTYPE ) )
   return CREDTYPE -> CREDNAME

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   function DISP_REV_FREQ(mREVFREQ)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    local mlist := space (14) + 'Quarterly     '+;
                                'Semi-Annual   '+;
                                'Annual        '+;
                                'Not Applicable'+;
                                'Monthly       '
   return substr ( mlist, val ( mREVFREQ ) * 14 + 1, 14 )

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   function DISP_UNIT(mUNITCODE)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   UNITCODE -> ( dbseek( mUNITCODE ) )
   return UNITCODE -> UNITNAME
/*
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   function DISP_ORIX_UNIT(mUNITCODE)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   ORIXUNIT -> ( dbseek( mUNITCODE ) )
   return ORIXUNIT -> UNITNAME

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   function DISP_PAYMENT_FREQ(mPAYFREQ)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mLIST := space ( 11 ) + 'Monthly    Bi-monthly Quarterly  Semi-annualAnnual     Lumpsum    Irregular  '
   return substr ( mLIST, val ( mPAYFREQ ) * 11 + 1, 11 )
*/
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   function DISP_CLTRL(mCLTRLTYPE)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   COLATRAL -> ( dbseek ( mCLTRLTYPE ) )
   return COLATRAL -> CLTRLNAME

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   function DISPRATETYPE(mRATETYPE)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mRETVAL
   mRETVAL := if( mRATETYPE $ '12', if( mRATETYPE == '1', 'Fixed   ', 'Floating' ), space(8) )
   return mRETVAL

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   function DISPREFTYPE(mDOCREF)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   return  if ( mDOCREF  $ '12' ,  if ( mDOCREF == '1', 'CA', 'OT' ), '  ' )

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   function CHKCLNTCODE(mCLNTCODE, mDOCREF,nrow, ncol)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   mCLNTCODE := if ( mDOCREF == '1', Caheader->CLNTCODE, OTICKET->CLNTCODE )
   @ 09, 31 say DISPCLNTNAME( mCLNTCODE, 40 )
   return .f.

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   function CHKSURETY(mSURETY, mDOCREF)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   mSURETY := if ( mDOCREF == '1', Caheader->GUARANTOR, OTICKET->SURETY )
   @ 10, 31 say DISPCLNTNAME( mSURETY, 40 )
   return .f.

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   function CHKAOCODE(mAOCODE, mDOCREF)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   mAOCODE :=  if ( mDOCREF == '1', Caheader->AOCODE, OTICKET->AOCODE )
   @ 12, 31 say DISPAONAME( mAOCODE )
   return .f.

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//   function ACCTNO_GENERATE(mACCTNO, mWHAT)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
/* EVR 01112007 - no use
   local mLASTAN
   if mWHAT == 'A'
      mLASTAN    := right ( '00000'+ alltrim (str(PARAMETR->LASTAN+1,5,0)), 5 )
      mACCTNO    := PARAMETR->COLFYR + PARAMETR-> BRCODE+ ACCTDALY->FCLTYCODE + mLASTAN
   endif
   return .f.
*/

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   function AMSTSEARCH(mACCTNO)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mCOLOR := setcolor (), mSCREEN := savescreen( ,,,)
   local mRECNO := Acctdaly->(recno()), getlist := {}, mRETVAL := .f.,mu:=savedbf()
   LOCAL tBR := g_PAR_BRCH+'-'

   Acctdaly->(dbsetorder(3))
   CENTER( 24,'w+/n', '® Search Record ¯' )
   fshadow( 10, 21, 12, 44, 2, 'n/w' )
   setcolor( 'bg+/w, w+/n,,, gr+/w' )

   @ 11, 22 say 'Acct N§ '
   @ 11, 32 GET tBR WHEN .F.
   @ 11, 36 get mACCTNO     ;
            pict '@R 99999' ;
            valid eval({|| macctno := padl( alltrim(macctno),5,'0' ) ,.t.})
   setcursor( 3 )   
   read
   setcursor( 0 )

   if macctno == '00000'

   else

   if !empty(mACCTNO) .and. lastkey() != K_ESC

     if !Acctdaly->(dbseek(sbrcode+mACCTNO ) )
        error( 'Acct Number not Found!' )
     else
        mrecno := Acctdaly->( recno() )
        mretval:= .t.
     endif

   endif

   endif

   setcolor( mCOLOR )
   restscreen( ,,,, mSCREEN )
   restdbf(mu)
   ACCTDALY->( dbgoto( mRECNO ) )
   return( mRETVAL )

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   function _AMSTSEARCH(mACCTNO)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mCOLOR := setcolor (), mSCREEN := savescreen( ,,,)
   local mRECNO := Acctdaly->(recno()), getlist := {}, mRETVAL := .f.,mu:=savedbf()
   LOCAL cBRCH := LEFT(mACCTNO,3) + '-'

   mACCTNO := RIGHT(mACCTNO,5)
   Acctdaly->(dbsetorder(3))
   CENTER( 24,'w+/n', '® Search Record ¯' )
   fshadow( 10, 21, 12, 41, 2, 'n/w' )
   setcolor( 'bg+/w, w+/n,,, gr+/w' ) 
   @ 11, 22 say 'Acct N§ '
   @ 11, 32 GET cBRCH  WHEN .F.
   @ 11, 36 get mACCTNO     ;
            pict '@R 99999' ;
            valid Eval({|| macctno := padl( alltrim(macctno),5,'0' ) ,.t.})
   setcursor( 3 )   
   read
   setcursor( 0 )

   if macctno == '00000'
//       __keyboard( chr( K_ESC ) )
      return .f.
   endif

   if !empty(mACCTNO) .and. lastkey() != K_ESC

     if !Acctdaly->(dbseek(sbrcode+mACCTNO ) )

         Acctwait->(dbsetorder(2))
         if !Acctwait->(dbseek( sbrcode+left(macctno,5) ) )
            error ( 'Availment Sheet NOT found' )
            return .f.
         else
            Acctwait->(dbsetorder(1))
            return .t.
         endif

         Acctwait->(dbsetorder(1))

         error( 'Acct Number not Found!' )
      else
        mrecno := Acctdaly->( recno() )
        mretval:= .t.
     endif

   endif

   setcolor( mCOLOR )
   restscreen( ,,,, mSCREEN )
   restdbf(mu)
   ACCTDALY->( dbgoto( mRECNO ) )
return( mRETVAL )

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   function GETLASTREC()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local x := 0
   return( eval( { | y | y := savedbf( y ), dbgotop(),;
        dbeval( { || if( !deleted(), x++, nil ) },, { || !eof() } ), restdbf( y ), x } ) )

*************************************
*
function AMST0100OPEN()
*************************************
   local cscr := savescreen ( ,,, ),mcol

   @ 22,1 say 'Opening files .....'
   mcol := col()

   if !netuse( '&g_grf_path\Branches', .f., 5 ) && branches
      return .f.
   endif
   set index to &g_grf_path\Brcode   && set index on branch code
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_GL_PATH\Flag',.f.,5)
      return .f.
   endif
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_AMS_PATH\ACCTMAST',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\ACCTCLNT
   
   if !NETUSE('&g_AMS_PATH\ACCTDALY',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\ACCTDALY,;
                &g_AMS_PATH\ACCDCLNT,;
                &g_AMS_PATH\ACCDSUB1,;
                &g_AMS_PATH\ACCFCLTY,;
                &g_AMS_PATH\ACCDNAME
   Acctdaly->(dbgotop())
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_GL_PATH\Tranhead',.f.,5)
      return .f.
   endif
   set index to &g_GL_PATH\Tranhead, &g_GL_PATH\Trancode, &g_GL_PATH\Tranbank, &g_GL_PATH\Tranlcrj, &g_GL_PATH\Trandate
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_GL_PATH\Trandtls',.f.,5)
      return .f.
   endif
   set index to &g_GL_PATH\Trandtls, &g_GL_PATH\Trglcode
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_AMS_PATH\ACCTWAIT',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\ACCTWAIT,;
                &g_AMS_PATH\ACCTWSUB,;
                &g_AMS_PATH\acctrecl,;
                &g_AMS_PATH\acctwclt,;
                &g_AMS_PATH\acctref1,;
                &g_AMS_PATH\acctref2
   ACCTWAIT->( dbsetorder(2) )
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_CIS_PATH'+'\CLIENT.DBF',.f.,5)
      return .f.
   endif
   set index to &g_CIS_PATH\CLIECD, &g_CIS_PATH\CLIENM
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_AMS_PATH\DOCCODES',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\DOCCODES, &g_AMS_PATH\DOCCNAME
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

   if !NETUSE('&g_AMS_PATH\CREDTYPE',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\CREDTYPE
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_AMS_PATH\CAHEADER',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\CAHEADER, &g_AMS_PATH\CAREV
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_AMS_PATH\CADETAIL',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\CADETAIL
   @ 22,mcol say '.'
   mcol := col()

/*	if !netuse( '&g_GL_PATH\JVSYSAX',.f.,10 )
	   break
	else
	   ordlistadd ( '&g_GL_PATH\JVSYSUID' )
	endif
	@ 22,mcol say '.'
	mcol := col()
	*/
// EVR if !NETUSE('PARAMETR',.f.,5)
// EVR    return .f.
// EVR endif
// EVR @ 22,mcol say '.'
// EVR mcol := col()

   *----------------------------------------------    && RED 033005
   IF NETUSE('&g_GL_PATH\OL_PARAM',.F.,5)
      SET INDEX TO &g_GL_PATH\OL_PARAM
   ELSE
      RETURN .F.
   ENDIF
   *----------------------------------------------

   if !NETUSE('&g_CIS_PATH'+'\AO.dbf',.f.,5)
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
   set index to &g_AMS_PATH\OTICKET
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_AMS_PATH\COVERAGE',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\COVERAGE
   @ 22,mcol say '.'
   mcol := col()
   
   if !NETUSE('&g_AMS_PATH\PURCHASE',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\PURCHASE
   
   if !netuse( '&g_FRU_PATH\FTLIST', .f., 5 )
      return .f.
   endif
   set index to &g_FRU_PATH\FTLIST01                 //BRCODE + ACCTNO
   
   if !NETUSE('&g_GRF_PATH'+'\HOLIDAYS',.f.,5)
      return .f.
   endif
   set index to &g_GRF_PATH\HOLIDATE
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_CIS_PATH'+'\DEALER.DBF',.f.,5)
      return .f.
   endif
   set index to &g_CIS_PATH\DLRCODE
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_AMS_PATH\CTRLINFO',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\CTRLINFO
   @ 22,mcol say '.'
   mcol := col()

  if !NETUSE('&g_AMS_PATH\AMSJVLOG',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\AMSJVLOG, &g_AMS_PATH\AMSJVLGT
   @ 22,mcol say '.'
   mcol := col()   
   
   if !NETUSE('&g_CIS_PATH'+'\INSURANC',.f.,5)
      return .f.
   endif
   set index to &g_CIS_PATH\INSCODE
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_AMS_PATH\PAYTSKED',.f.,5)  //aga.04.09.2006.netuse paytsked
      return .f.
   endif
   set index to &g_AMS_PATH\PAYTSTAT, &g_AMS_PATH\PAYTSKED 
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_AMS_PATH\PAYCODES',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\PAYCODES
   @ 22,mcol say '.'
   mcol := col()
   
   if !NETUSE('&g_AMS_PATH\CASHOUT',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\CASHOUT
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_AMS_PATH\DOCDAY',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\DOCDAY
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_GRF_PATH'+'\PERSONEL.DBF',.f.,5)
      return .f.
   endif
   set index to &g_GRF_PATH\INITIALS.ntx
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_AMS_PATH\ASETCODE',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\ASETCODE
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_AMS_PATH\AMSGL',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\AMSGL
   @ 22,mcol say '.'
   mcol := col()

   if !NETUSE('&g_GL_path\JV_LOG',.f.,5)
      return .f.
   else
      if !.f.; ordlistclear(); endif
      ordlistadd( '&g_GL_path\JV_LOG' )
   endif

   if !netuse( '&g_GL_PATH\GL_DEPO',.f.,10 )
      break
   else
      ordlistadd ( '&g_GL_PATH\GL_DEPO' )
   endif
   @ 22,mcol say '.'
   mcol := col()

   if !netuse( 'Parametr', .f., 10 ) 
      //FT_PRTSCR(.T.)
      return
   endif


/*
   if !NETUSE('AMSJVH',.f.,5)
      return .f.
   endif
   set index to AMSJVH

   if !NETUSE('AMSJVD',.f.,5)
      return .f.
   endif
   set index to AMSJVD

   if !NETUSE('&g_GL_PATH\GLCODE', .f.,5 )
      return .f.
   endif
   set index to &g_GL_PATH\GLCODE, &g_GL_PATH\GLNAME
*/

   if !netuse( '&g_AMS_PATH\Ctrlothr', .f., 5 )
      return .f.
   endif
   set index to &g_AMS_PATH\ctrlothr
   @ 22,mcol say '.'
   mcol := col()

   if !netuse( '&g_AMS_PATH\Colacode', .f., 5 )
      return .f.
   endif
   set index to &g_AMS_PATH\Colacode
   @ 22,mcol say '.'
   mcol := col()

//aga.15.07.2005.dropper
   if !netuse('&g_AMS_PATH\Drop',.f.,5 )
      return .f.
   endif
   ordlistadd( '&g_AMS_PATH\Drop' )
   @ 22,mcol say '.'
   mcol := col()
//......................

   restscreen ( ,,,,cscr )
return .t.

// Eop: AMST100B.prg //
