/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   Program ID.........:  amsm100b.prg                                         ³
³   Description........:  credit application maintenance (sub-module)          ³
³   Author.............:  Ariel B. Bulan                                       ³
³   Date...............:  08:56am 25-Aug-1994                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                         U P D A T E S                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        Who        ³     When      ³               Why                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Janet L. Bautista ³  10-Sep-1997  ³ gd, rv to 5 decimal places               ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include "Colf.ch"
#include "Inkey.ch"
#include "Memoedit.ch"

#define ROWLIMIT  47
***************************************************************
*   Description   memo edit for SECURITY HELD/TO BE OBTAINED
*   Parameters    either SECURITY HELD/TO BE OBTAINED variable
*   Return Value  nil
*
function memo( mwhatfield , mwhatinitial, misca, misavail, xrow )
***********************************************************
   local   mediting    := .t., mbuffer
   local   mcursor     := setcursor ( setcursor() )
   local   mlscr       := savescreen( ,,, ), mcolor := setcolor()
   local   mcollength, vrow
   private mtop_row, mtop_col, mfull     , mscr      ,;
           mold_row, mold_col, m_win_row , m_win_col ,;
           marray  , mlevel  , mchoice   , mretval   ,;
           me_command        , mselected , mctr      ,;
           msavescr          , mhead                 ,;
           mk_f1disable      , i, cnt_color := 1, str_color := 'n'

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
/*      eval({|| devpos( mtop_row - 2, 13) , devout( 'Ä', NRM) ,;
                 devpos( mtop_row - 2, 28) , devout( 'Ä', NRM) ,;
                 devpos( mtop_row - 2, 41) , devout( 'Ä', NRM) ,;
                 devpos( mtop_row - 2, 49) , devout( 'Ä', NRM) ,;
                 devpos( mtop_row - 2, 64) , devout( 'Ä', NRM) ,;
                 devpos( 22, 13) , devout( 'Ä', NRM) ,;
                 devpos( 22, 28) , devout( 'Ä', NRM) ,;
                 devpos( 22, 41) , devout( 'Ä', NRM) ,;
                 devpos( 22, 49) , devout( 'Ä', NRM) ,;
                 devpos( 22, 64) , devout( 'Ä', NRM)  ;
             }) */
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
      dispend()
      mWHATFIELD := memoedit ( mWHATFIELD, mTOP_ROW, mTOP_COL, 20, 77, .t. ,"ME_UDF", mcollength,, mOLD_ROW, mOLD_COL, m_WIN_ROW, m_WIN_COL )
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
////
function what_inside( mbottom, key_ )
local mcol := []

if valtype( key_ ) == 'A'
   aeval( key_, { | k_ | mcol += stuff( k_, at( '\', k_ ), 1, '' ) } )   
   dispbox( mbottom + 1, 0, mbottom + 1, maxcol(), '', 'n/n' )
   setpos( mbottom + 1, ( 80 - len( mcol ) ) / 2 )       
   aeval( key_, { | k_ | setcolor( 'w+/n' ), qqout( subs( k_, 1, at( '\', k_ ) - 1 ) ),;
                         setcolor( 'w/n'  ), qqout( subs( k_, at( '\', k_ ) + 1 ) ) } )
endif                         
return( nil )
*********************************************************
*   Description   essential function for memoedit module
*   Parameters    mode, row and column
*   Return Value  default
*
function me_udf( me_mode, me_row, me_col )
******************************************
   local  mE_KEY   := lastkey()  , mE_SAVE, mwhat_row := 1, nwhat_row := 1
   local  mCOLOR   := setcolor() , mCURSOR := setcursor ( setcursor () )
   memvar mARRAY   , mLEVEL
   memvar mE_MACROS, mE_FILE     , mE_COMMAND
   memvar mOLD_ROW , mOLD_COL    , m_WIN_ROW, m_WIN_COL
   memvar mRETVAL  , mSELECTED   , mCTR
   memvar mSAVESCR , mHEAD       , mTOP_ROW
   memvar mK_F1DISABLE, mCHOICE, cnt_color, str_color

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
              mRETVAL := mSELECTED := '' ; mARRAY := transfer_value( mLEVEL )
              mHEAD := 'Options'
              do while .t.
                 do while lastkey() != K_ESC
                    mCHOICE    := gen_achoice( mARRAY, nwhat_row, mHEAD, 04, 43, len( mARRAY ) + 4, 77, 'W/GR+,W/N,,,W/GR+')
                    if lastkey() != K_ESC .and. mLEVEL == 1
                       mHEAD  := trim  ( mARRAY[val(mCHOICE)] )
                       mHEAD  := substr( mHEAD, at( '=', mHEAD ) + 2 )
                       mLEVEL += val( mCHOICE )
                       mARRAY := transfer_value( mLEVEL )
                    else
                       mwhat_row++
                       nwhat_row := ascan( marray, { | a_ | padr( a_, 2 ) ==;
                                     padr( ltrim( str( mwhat_row ) ), 2 ) } )
                       exit
                    endif
                 enddo
                 if lastkey() != K_ESC
                    mSELECTED := ''
                    do case
                       case mLEVEL == 2
                            if val ( mCHOICE ) == 7
                               mSELECTED := get_value('N','Amount Executed ', 40) +' - '+;
                                            get_value('D','Date of Execution ', 35) +;
                                            ' executed by' + ' '                      +;
                                            get_value('C','Executors ',30)          +;
                                            ' held by'     + ' '                      +;
                                            get_value('C','Branch ', 30)+'.'
                            endif
                       case mLEVEL == 3
                            if val ( mCHOICE ) == 8
                               mSELECTED := get_value( 'N','Amount ',30)
                            elseif val ( mCHOICE ) == 13
                               mSELECTED := get_value( 'N','Value ',30) + ' - '+;
                                            get_value( 'D','Evaluation Date ',35)
                            endif
                       case mLEVEL == 4
                            if val ( mCHOICE ) == 7
                               mSELECTED := 'for '+get_value('N','Amount ',30 )
                            elseif val ( mCHOICE ) == 12
                               mSELECTED := get_value( 'N','Value ' ,30) + ' - '+;
                                            get_value( 'D','Evaluation Date ',35)
                            endif
                       case mLEVEL == 5
                           if val ( mCHOICE ) == 4
                              mSELECTED := 'over and up to '+;
                                           get_value('N','N§ of Days ',40 )+ ' days '
                           elseif val ( mCHOICE ) == 9
                               mSELECTED := 'others '+get_value('C','Specs ',30)
                           elseif val ( mCHOICE ) == 10
                              mSELECTED := 'for ' + get_value('N','Amount ',35)+;
                                           ' a with book value of '+ ;
                                           get_value( 'N','Book Value ',40) + ' - '+;
                                           get_value( 'D','Date ',30)
                           endif
                       case mLEVEL == 6
                           if val ( mCHOICE ) == 10
                              mSELECTED := get_value( 'N','Cost Value ',35) + ' - '+;
                                           get_value( 'D','Evaluation Date ',35)
                           endif
                       case mLEVEL == 7
                           if val ( mCHOICE ) == 3
                              mSELECTED := 'executed by' + ' '                      +;
                                           get_value('C','Executors ',30)         +;
                                           ' held by'     + ' '                     +;
                                           get_value('C','Branch ', 30)+'.'
                           endif

                       case mLEVEL == 8
                           if val ( mCHOICE ) == 2
                              mSELECTED := get_value('N','Amount ', 30 ) +;
                                           ' issued by ' + get_value('C','Name of Issuing Company ',50 ) +;
                                           ' on '        + get_value('D','Date ',30) +  ;
                                           ' expiry date '+get_value('D','Expiry Date ',35)+'.'
                           endif
                       case mLEVEL == 9
                           if val ( mCHOICE ) == 2
                              mSELECTED := get_value('C',"Co-Signer's Name ",40) + '.'
                           endif
                       case mLEVEL == 10
                           if val ( mCHOICE ) == 2
                              mSELECTED := get_value('N','Amount ',30 ) +;
                                           ' issued by '+ get_value('C','Issuer ',30 )+'.'
                           endif
                       case mLEVEL == 11
                           if val ( mCHOICE ) == 5
                              mSELECTED := get_value ('C','Details ',30 )+' in'
                           endif
                    endcase
                    if empty( mSELECTED )
                       mSELECTED := trim( mARRAY [ val ( mCHOICE ) ] )
                       mSELECTED := substr( mSELECTED , 5, len ( mSELECTED ) - 4 )
                    endif
                 endif
                 mRETVAL  = mRETVAL+' '+ltrim(mSELECTED)
                 mCTR++
                 if right( mRETVAL,1 ) == '.' .or. lastkey() == K_ESC
                    exit
                 endif
                 keyboard str( mCTR , 2, 0 )
              enddo
              keyboard if( lastkey() == K_ESC, '', mRETVAL )
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
*******************************************************************************
*   Description   Computes for the ff : Monthly Rental Factor
*                                        Monthly Rental
*                                        Total Receivables
*   Parameters    PRINCIPAL, GUARANTY DEPOSIT, RESIDUAL VALUE, TERM, EFF. RATE
*                  MONTHLY RENTAL FACTOR, MONTHLY RENTAL, CREDIT AMOUNT
*   Return Value  .t.
*
function compute_1(mprincipal,mpaytype, mgd,mrv,mtruerate,mterm,mfactor,mamort,mcredamt, mratetype, xrow, xcol )
***************************************************************************************************
   local mRATEMTH, mPVALUE, mPVLESS, mGDAMOUNT, mRVAMOUNT, mUP, mDOWN
   local mRATECHOICES := { '1 = Fixed     ','2 = Floating  ' }

   mRATEMTH := ( mTRUERATE / 100 ) / 12                  // effective rate/month
   mPVALUE  := mPRINCIPAL - ( ( mGD/100 ) * mPRINCIPAL ) // present value
   mPVLESS  := 0

   if mGD <> mRV
      mGDAMOUNT := mPRINCIPAL * ( mGD / 100 )
      mRVAMOUNT := mPRINCIPAL * ( mRV / 100 )
      mPVLESS   := ( abs( mGDAMOUNT - mRVAMOUNT ) ) * ( (1+mRATEMTH) ** ( -mTERM ))
   endif

   mPVALUE  := iif ( mGD > mRV, mPVALUE + mPVLESS, mPVALUE-mPVLESS )
   if mPAYTYPE == '1'
      mUP   := mRATEMTH * (( 1 + mRATEMTH ) ** ( mTERM - 1 ))  // in advance
   else
      mUP   := mRATEMTH * (( 1 + mRATEMTH ) ** ( mTERM     ))  // in arrears
   endif
   mDOWN    :=  (( 1 + mRATEMTH) ** mTERM ) - 1
   mAMORT   := round ( mPVALUE * ( mUP / if(mdown==0,1,mdown)  ), 2)

   mAMORT   := intround(mAMORT)

   mFACTOR  := ( mAMORT / mPRINCIPAL ) * 100

   mCREDAMT := mAMORT * mTERM

   *chkratetype( mRATECHOICES, @mRATETYPE, xrow, xcol, .T. )
   chkratetype( mRATECHOICES, @mRATETYPE, xrow, xcol )
return .t.
*********************************************************************************************
*   Description   Computes for the ff :  Add-on Rate
*                                         Monthly Amortization
*                                         Credit Amount
*   Parameters    PRINCIPAL, TERM, EFF. RATE, ADD-ON RATE
*                  MONTHLY RENTAL, CREDIT AMOUNT
*   Return Value  .t.
*
function compute_2(mprincipal,mpaytype,mtruerate,mterm,maddon,mamort,mcredamt,mratetype, xrow, xcol)
*********************************************************************************************
   local mRATECHOICES := { '1 = Fixed     ','2 = Floating  ' }
   local mRATEMTH := ( mTRUERATE / 100 ) /12      // effective rate per month
   local mUP,mDOWN

   if mPAYTYPE == '1'
      mUP   := mRATEMTH * (( 1 + mRATEMTH ) ** ( mTERM - 1 ))  // in advance
   else
      mUP   := mRATEMTH * (( 1 + mRATEMTH ) ** ( mTERM     ))  // in arrears
   endif

   mDOWN    := (( 1 + mRATEMTH) ** mTERM ) - 1
   mAMORT   := round ( mPRINCIPAL * ( mUP/ if(mDOWN==0, 1,mdown) ), 2 )
   mAMORT   := intround ( mAMORT )
   mCREDAMT := mAMORT * mTERM
   mADDON   := ( mCREDAMT - mPRINCIPAL ) / if(mPRINCIPAL==0,1,mprincipal)

   *chkratetype( mRATECHOICES, @mRATETYPE, xrow, xcol, .T. )
   chkratetype( mRATECHOICES, @mRATETYPE, xrow, xcol )

return .t.
*****************************************************************************************
*
function compute_3(mprincipal,mpaytype,mtruerate,mterm,mnerate,mamort,mcredamt,mratetype, xrow, xcol)
*****************************************************************************************
   local mRATEMTH, mDOWN, mUP
   local mRATECHOICES := { '1 = Fixed     ','2 = Floating  ' }
   mRATEMTH := ( mTRUERATE / 100 ) /12      // effective rate per month

   if mPAYTYPE == '1'
      mUP   := mRATEMTH * (( 1 + mRATEMTH ) ** ( mTERM - 1 ))  // in advance
   else
      mUP   := mRATEMTH * (( 1 + mRATEMTH ) ** ( mTERM     ))  // in arrears
   endif
   mDOWN    := (( 1 + mRATEMTH) ** mTERM ) - 1
   mAMORT   := round ( mPRINCIPAL * ( mUP/mDOWN ), 2 )
   mAMORT   := intround ( mAMORT )

   if mtruerate == 0 .and. mnerate == 0          // ABB 10.20.2005
      mCREDAMT := mPRINCIPAL
   else
      mCREDAMT := mAMORT * mTERM
   endif

   mNERATE  := mNERATE   //FOR THE MEANTIME UNTIL FORMULA HAS NOT BEEN DERIVED
   *chkratetype( mRATECHOICES, @mRATETYPE, xrow, xcol, .T. )
   chkratetype( mRATECHOICES, @mRATETYPE, xrow, xcol )

return .t.

*********************************************************************************
*
function compute_4(mprincipal,mpaytype,mtruerate,mterm,mamort,mcredamt,mtermunit)
*********************************************************************************
   local mRATEMTH,mDOWN,mUP

   if mTERMUNIT == '2'    // MONTHS
      mRATEMTH := ( mTRUERATE / 100 ) / 12      // effective rate per month
   else                  // DAYS
      mRATEMTH := ( mTRUERATE / 100 ) / 360
   endif

   if mPAYTYPE == '1'
      mUP   := mRATEMTH * (( 1 + mRATEMTH ) ** ( mTERM - 1 ))  // in advance
   else
      mUP   := mRATEMTH * (( 1 + mRATEMTH ) ** ( mTERM     ))  // in arrears
   endif

   mDOWN    := (( 1 + mRATEMTH) ** mTERM ) - 1
   if mup == 0 .and. mdown == 0
      mamort := 0
   else
      mAMORT   := round(mPRINCIPAL*(mUP/mDOWN),2)
   endif
   mAMORT   := intround ( mAMORT )
   mCREDAMT := mAMORT * mTERM
return .f.

****************************
function intround( mamount )
****************************
return if( mamount >= int ( mamount ) + 0.20, int ( mamount ) + 1, int ( mamount ) )

************************************************************
static function chkratetype( mratechoices, mratetype, xrow, xcol )
************************************************************
  mRATETYPE := gen_achoice( mRATECHOICES, val( mRATETYPE ), 'Rate Type', 15, 56, 18, 77, 'W/GR+,W/N,,,W/GR+' )
  @ xrow, xcol say upper( if( mRATETYPE == '1', 'Fixed   ', 'Floating' ) ) color 'gr+/gr'
return .f.
/*
***********************************
*
static function dispaopost(maocode)
***********************************
   Ao->(dbseek(maocode))
return alltrim(Ao->AOPOST)
*/
*******************************************************
*  Desc  Checks if Cadetail->INCLUDE == .T.
*  Para  None
*  Ret  
*
function includes_are_ok()
**************************
   local mretval := .t. , mdbf := savedbf ( mdbf ), mctr := 0, merror := .f.
   if Cadetail->( dbseek ( Caheader->brcode+Caheader->CANUMBER ) )
      if !Cadetail->INCLUDE              // if First Record is NOT INCLUDED
          Cadetail->( dbeval(  {|| mctr++,;
                                   if( mctr == 2 .and. Cadetail->INCLUDE,merror := .t.,nil ) },,;
                               {|| Cadetail->CANUMBER==Caheader->CANUMBER .and. ;
                                   Cadetail->brcode  ==Caheader->brcode   .and. ;
                                   !Cadetail->(eof()) } ) )
          if merror
             error( 'Please Check your INCLUDE Sequence!' ); mretval := .f.
          endif
      endif
   endif
   restdbf ( mdbf )
return mretval
***************************************************************************************************************************************************
*  Description  Displays Array elements per SETCODE
*
function disp_per_set ( mp_ar,mctr,munit,mamort,mtruerate,mprincipal,mdbf,mtotal,mnetproceeds,mrentfactor,mnotfics,mcollects,mrecourses,mobligors )
***************************************************************************************************************************************************
   local i, msep := space(7)
   local meffective,mamort2 ,mproceeds,mfactor
   local mnotfic   ,mcollect,mrecourse,mobligor

   do case
      case mp_ar [ mctr ] [2] == '1'
          if upper ( alias() ) == upper ( 'Acctmast' )

             meffective := mp_ar [mctr] [5]
             mamort2    := mp_ar [mctr] [6]

             @ prow()+1, 0 say '³'+ msep + mp_ar[ mctr ] [3] ; disp_3_lines() ; _can_be_ejected( mtotal )
             disp_all_amounts( 1,mtruerate,msep,1,mamort,@meffective,@mamort2 )
             @ prow()+1, 0 say '³'+ msep + mp_ar[ mctr ] [4] ; disp_3_lines() ; _can_be_ejected( mtotal )
             @ prow()+1, 0 say '³'+ msep + meffective        ; disp_3_lines() ; _can_be_ejected( mtotal )
             @ prow()+1, 0 say '³'+ msep + mamort2           ; disp_3_lines() ; _can_be_ejected( mtotal )
             @ prow()+1, 0 say '³'+ msep + mp_ar[ mctr ] [7] ; disp_3_lines() ; _can_be_ejected( mtotal )
             @ prow()+1, 0 say '³'+ msep + mp_ar[ mctr ] [8] ; prn_unit ( munit,mp_ar[ mctr ] [1], mdbf,mtotal ) ; _can_be_ejected( mtotal )

          else

             mproceeds  := mp_ar [mctr] [3]
             meffective := mp_ar [mctr] [7]
             mamort2    := mp_ar [mctr] [8]
             mfactor    := mp_ar [mctr] [9]

             disp_all_amounts( 1,mtruerate,msep,1,mamort, @meffective,@mamort2,@mproceeds,mnetproceeds,@mfactor,mrentfactor   )

             @ prow()+1, 0 say '³'+ msep + mproceeds          ; disp_3_lines() ; _can_be_ejected( mtotal )
             @ prow()+1, 0 say '³'+ msep + mp_ar[ mctr ] [4]  ; disp_3_lines() ; _can_be_ejected( mtotal )
             @ prow()+1, 0 say '³'+ msep + mp_ar[ mctr ] [5]  ; disp_3_lines() ; _can_be_ejected( mtotal )
             @ prow()+1, 0 say '³'+ msep + mp_ar[ mctr ] [6]  ; disp_3_lines() ; _can_be_ejected( mtotal )
             @ prow()+1, 0 say '³'+ msep + meffective         ; disp_3_lines() ; _can_be_ejected( mtotal )
             @ prow()+1, 0 say '³'+ msep + mamort2            ; disp_3_lines() ; _can_be_ejected( mtotal )
             @ prow()+1, 0 say '³'+ msep + mfactor            ; disp_3_lines() ; _can_be_ejected( mtotal )
             @ prow()+1, 0 say '³'+ msep + mp_ar[ mctr ] [10] ; prn_unit ( munit,mp_ar[ mctr ] [1], mdbf,mtotal ) ; _can_be_ejected( mtotal )

          endif
      case  mp_ar [ mctr ] [2] == '2' .or.   mp_ar [ mctr ] [2] == '3'

          if upper ( alias() ) == upper ( 'Acctmast' )

             meffective := mp_ar [mctr][4]
             mamort2    := mp_ar [mctr][5]

             @ prow()+1, 0 say '³'+ msep+ mp_ar[ mctr ] [3] ; disp_3_lines()  ; _can_be_ejected(mtotal)
             disp_all_amounts( 1,mtruerate,msep,1,mamort, @meffective, @mamort2 )
             @ prow()+1, 0 say '³' + msep + meffective        ; disp_3_lines()  ; _can_be_ejected(mtotal)
             @ prow()+1, 0 say '³' + msep + mamort2           ; disp_3_lines()  ; _can_be_ejected(mtotal)
             @ prow()+1, 0 say '³' + msep + mp_ar[ mctr ] [6] ; disp_3_lines()  ; _can_be_ejected(mtotal)
             @ prow()+1, 0 say '³' + msep + mp_ar[ mctr ] [7] ; prn_unit ( munit, mp_ar[ mctr ] [1],mdbf,mtotal ) ; _can_be_ejected(mtotal)

          else

             mproceeds  := mp_ar [mctr] [3]
             meffective := mp_ar [mctr] [5]
             mamort2    := mp_ar [mctr] [6]

             disp_all_amounts( 1,mtruerate,msep,1,mamort, @meffective,@mamort2,@mproceeds,mnetproceeds)
             @ prow()+1, 0 say '³' + msep + mproceeds         ; disp_3_lines(); _can_be_ejected(mtotal)
             @ prow()+1, 0 say '³' + msep + mp_ar[ mctr ] [4] ; disp_3_lines(); _can_be_ejected(mtotal)
             @ prow()+1, 0 say '³' + msep + meffective        ; disp_3_lines(); _can_be_ejected(mtotal)
             @ prow()+1, 0 say '³' + msep + mamort2           ; disp_3_lines(); _can_be_ejected(mtotal)
             @ prow()+1, 0 say '³' + msep + mp_ar[ mctr ] [7] ; prn_unit ( munit, mp_ar[ mctr ] [1],mdbf,mtotal ) ; _can_be_ejected(mtotal)

          endif

      otherwise

          if upper ( alias() ) == upper ( 'Acctmast' )
             meffective := mp_ar [ mctr ] [04]
             mamort2    := ''
             @ prow()+1, 0 say '³'+ msep+ mp_ar[ mctr ] [3] ; disp_3_lines()  ; _can_be_ejected( mtotal )
             disp_all_amounts( 2,mtruerate,msep,1,mamort, @meffective, @mamort2 )
             @ prow()+1, 0 say '³'+ msep+ meffective        ; disp_3_lines()  ; _can_be_ejected(mtotal)
             @ prow()+1, 0 say '³'+ msep+ mp_ar[ mctr ] [5] ; prn_unit( munit, mp_ar[ mctr ] [1], mdbf,mtotal ) ; _can_be_ejected( mtotal )
          else

             mproceeds  := mp_ar [ mctr ] [03]
             meffective := mp_ar [ mctr ] [05]
             mnotfic    := mp_ar [ mctr ] [06]
             mcollect   := mp_ar [ mctr ] [07]
             mrecourse  := mp_ar [ mctr ] [08]
             mobligor   := mp_ar [ mctr ] [09]
             mamort2    := ''
             mfactor    := mp_ar [ mctr ] [9]

             disp_all_amounts( 1,mtruerate,msep,1,mamort, @meffective,@mamort2,@mproceeds,mnetproceeds,@mfactor,mrentfactor,;
                               @mnotfic   ,mnotfics   ,;
                               @mcollect  ,mcollects  ,;
                               @mrecourse ,mrecourses ,;
                               @mobligor  ,mobligors   ;
                             )

             @ prow()+1, 0 say '³'+ msep + mproceeds          ; disp_3_lines() ; _can_be_ejected ( mtotal )
             @ prow()+1, 0 say '³'+ msep + mp_ar [ mctr ] [4] ; disp_3_lines() ; _can_be_ejected ( mtotal )
             @ prow()+1, 0 say '³'+ msep + meffective         ; disp_3_lines() ; _can_be_ejected ( mtotal )
             @ prow()+1, 0 say '³'+ msep + mnotfic            ; disp_3_lines() ; _can_be_ejected ( mtotal )
             @ prow()+1, 0 say '³'+ msep + mcollect           ; disp_3_lines() ; _can_be_ejected ( mtotal )
             @ prow()+1, 0 say '³'+ msep + mrecourse          ; disp_3_lines() ; _can_be_ejected ( mtotal )
             @ prow()+1, 0 say '³'+ msep + 'Obligor               : ' ; disp_obligors ( mobligors, mtotal )
             @ prow()+1, 0 say '³'+ msep + mp_ar [ mctr ] [ 10 ] ; prn_unit( munit, mp_ar[ mctr ] [1], mdbf,mtotal ) ; _can_be_ejected( mtotal )

             //disp_all_amounts( 2,mtruerate,msep,1,mprincipal )

          endif

   endcase
return nil
***************************************************************
*  Description  Displays TOTAL MONTHLY RENTAL/NET PROCEEDS and
*                         effective rate ( TRUERATE )
*
static function disp_all_amounts(x,mtruerate,msep,mint,mamount,meffective,mamort,mproceeds,mnetproceeds,mfactor,mrentfactor,;
                                   mnotfic   ,mnotfics    ,;
                                   mcollect  ,mcollects   ,;
                                   mrecourse ,mrecourses  ,;
                                   mobligor  ,mobligors    ;
                                )
******************************************************************************************************************************
   local mtrue2 := {}

   aeval ( mtruerate, {|x| aadd(mtrue2,x[2])} )
   if upper(alias()) == upper( 'Acctmast' )
      asort ( mtrue2 ,,, {|x,y| x<y } )
      del_dup_units ( mamount )
   endif

   meffective := meffective + get_effective( mtrue2 )
   mamort     := mamort     + ltrim(get_total(mamount))

   if mproceeds != nil
      mproceeds := mproceeds + get_proceeds   ( mnetproceeds  )
      mfactor   := if ( mfactor   != nil , mfactor   + get_rentfactor ( mrentfactor   ), nil )
      mnotfic   := if ( mnotfic   != nil , mnotfic   + get_text   ( mnotfics   , { 'With','Without' } ), nil )
      mcollect  := if ( mcollect  != nil , mcollect  + get_text   ( mcollects  , { 'Ours','Theirs'  } ), nil )
      mrecourse := if ( mrecourse != nil , mrecourse + get_text ( mrecourses , { 'With','Without' } ), nil )
   endif

return nil
***************************************************
*
static function disp_obligors  ( mobligors,mtotal )
***************************************************
   local mrow := prow() ,mcol := pcol(), moldrow := prow()
   aeval ( mobligors, {|x| if ( moldrow != mrow, eval ({|| devpos(prow()+1,0),;
                                                           devout('³'+space( 29 ) );
                                                       }),nil ),;
                           devpos ( mrow , mcol )   ,;
                           devout ( alltrim(x) )    ,;
                           disp_3_lines()           ,;
                           _can_be_ejected (mtotal) ,;
                           mrow++                   ,;
                           nil                       ;
                      })
return nil
********************************************
*
static function get_proceeds( mnetproceeds )
********************************************
   local mretval := ''
   mnetproceeds := del_dup_proceeds( mnetproceeds )
   aeval ( mnetproceeds,{|x| mretval += ' ; '+ltrim(trans(x,'999,999,999.99')) })
   mretval := substr(mretval,4,len(mretval)-3)
return mretval
**********************************************
*
static function get_rentfactor ( mrentfactor )
**********************************************
   local mretval := ''
   aeval ( mrentfactor,{|x| mretval += ' ; '+ltrim(trans(x,'999.9999')) })
   mretval := substr(mretval,4,len(mretval)-3)
return mretval
******************************************
*
static function get_text ( mtext,martext )
******************************************
   local mretval := ''
   aeval ( mtext, {|x| mretval += ' ; ' + martext [ val (trans(x,'@X'))] })
   mretval := substr(mretval,4,len(mretval)-3)
return mretval
*****************************************
*
static function del_dup_proceeds( mproc )
*****************************************
   local x2,i:=1,mctr:=0,mproc2 := aclone( mproc )
   asort( mproc2,,,{|x,y| x < y })
   while i<=len(mproc2)
        x2 := mproc2 [i]
        mctr:=1
        while mproc2 [i] == x2
              if (mctr > 1, eval({|| adel(mproc2,i),asize(mproc2,len(mproc2)-1),i-- }),nil )
              mctr++ ; i++
              if i>len(mproc2)
                 exit
              endif
        enddo
   enddo
   mproc := aclone( mproc2 )
return mproc
***************************************
*
static function get_effective( mtrue2 )
***************************************
   local mretval := ''
   if upper( alias() ) == upper ( 'Acctmast' )
       mretval := if( mtrue2[1] != mtrue2[len(mtrue2)], ltrim(trans( mtrue2[1],"99.99%" )) + " - " + trans( mtrue2[len(mtrue2)],"99.99%" ), trans( mtrue2[len(mtrue2)],"99.99%" ) )
   else
       aeval ( mtrue2, {|x| mretval += ' ; '+ltrim(trans(x,"99.99%")) } )
       mretval := substr( mretval, 4, len( mretval ) - 3 )
   endif
return mretval
*************************************
*
static function get_total ( mamount )
*************************************
   local mamt2 := 0 , mamt3 := ''
return eval ({|x| if ( upper(alias()) == upper('Acctmast') ,;
                       x := eval ({|| aeval ( mamount, {|y| mamt2 += y[2]})  ,;
                                      trans ( mamt2  ,'999,999,999.99') })   ,;
                       x := eval ({|| aeval( mamount, {|x| mamt3 += ' ; '+ ltrim(trans(x[2],'999,999,999.99')) }) ,;
                                      mamt3 := substr( mamt3,4,len(mamt3)-3) })),;
                       x })
******************************************************************
*  Desc  Displays Collaterals/Unit Code/Item Code ( UNIT )
*  Para  UNITCODE,FACILITY CODE, ACTIVE DBF, TOTAL
*  Ret  
*
static function prn_unit ( munit,mfcltycode,mdbf,mtotal )
******************************************************************
   local i := 1, mstart := 1, mrow := prow(), mpos, morixunit, mcol := 32
   local mprinted := .f.    , mctr, mswitch := .f.
   asort( munit,,,{ |x,y| x[2]<y[2] })     // SORT BY ORIXUNIT
   while i<=len(munit)                     // delete all
      morixunit := munit [i] [2]           // duplicate ORIXUNIT
      i++
      if i<=len(munit)
          while munit[i][2]==morixunit
             adel  ( munit,i )
             asize ( munit,len(munit)-1 )
             i--
             i++
             if i > len(munit)
                exit
             endif
          enddo
      endif
   enddo

   if ( mpos := ascan ( munit, {|x| x[1] == mfcltycode }, mstart ) ) > 0
      while ( mpos := ascan ( munit, {|x| x[1] == mfcltycode }, mstart ) ) > 0
            if eval({|| if( upper(mdbf)== upper('Acctmast'), !empty (munit[mpos][2]), !empty(munit[mpos])) })
               if upper( mdbf ) == upper( 'Acctmast' )
                  if mprinted
                     devpos ( mrow, mcol )
                     devout ( eval({|| Orixunit->(dbseek(munit [mpos] [2])),;
                              subs( Orixunit->UNITNAME, 1, 1 ) + lower( subs( Orixunit->UNITNAME, 2 ) );
                                   }) )
                     mrow += 1        
                     disp_3_lines()             
                     _can_be_ejected( mtotal )                                
                     eval({|| devpos( mrow, 0 ), devout("³") })
                     mswitch := .t.
                  endif   
                  mprinted := .t.
               else
                  mctr := 0
                  aeval ( munit[mpos],{|x| mctr++  ,;
                                       if ( mctr>1 .and. !empty(x) ,;
                                            prn_unix(x,@mrow,mcol,@mprinted,mtotal),;
                                            nil  ;
                                          );
                                      };
                        )
               endif
            else
               if ( !mprinted, disp_3_lines(), nil )
            endif
            morixunit := munit [mpos] [2]
            mpos++
            if mpos > len ( munit )
               mswitch := !mswitch
               exit
            endif
            if mrow >= 48
               mrow := mrow-47
            else
               mrow := prow()
            endif
            while munit [mpos] [2] == morixunit
                  mpos++
                  if mpos > len ( munit )
                     exit
                  endif
            enddo
            mstart := mpos
            if mpos > len ( munit ) .or. mstart > len ( munit )
               exit
            endif
      enddo
      if mswitch 
         disp_3_lines()
      endif
   else
      disp_3_lines()
   endif
return nil
************************************************************
*  Description  displays UNIT2 if it NOT empty
*
static function prn_unix( x,mrow,mcol,mprinted,mtotal )
************************************************************
   eval({|| if ( mprinted, eval({|| devpos( mrow, 0 ), devout("³") }), mprinted := .t. ),;
            devpos ( mrow, mcol ),;
            devout ( x )         ,;
            mrow++               ,;
            disp_3_lines()       ,;
            eval({|| _can_be_ejected(mtotal), if(prow()<=3,mrow:=prow()+1,nil) });
       })
return nil
************************************************
*  Desc  Display FACILITY CODE/NAME
*
function disp_fac( mfcltycode,msetcode, mtotal )
************************************************
     memvar meject
     local mfname := dispfcltyname(mfcltycode)
     local malias := alltrim( Facility->FCLTYALIAS )
     eval ({|| ;
            devpos( prow()+1, 000 ), devout( '³'+left( mfcltycode,3 )+'-'+right( mfcltycode,2)+" ("+malias+") "+left( upper(mfname),40 )),;
            devpos( prow()  , 091 ), devout( "³" ) ;
          })
return nil
*******************************************************
*  Desc  Filters an ARRAY for DUPLICATE RECORDS
*
static function del_dup_units( munit )
**************************************
   local x2,i:=1,mctr:=0,munit2 := aclone( munit )
   asort( munit2,,,{|x,y| x[2] < y[2] })
   while i<=len(munit2)
        x2 := munit2 [i] [2]
        mctr:=1
        while munit2 [i] [2] == x2
              if ( mctr > 1, eval({|| adel(munit2,i),;
                                      asize(munit2,len(munit2)-1),i-- ;
                                 }),;
                   nil )
              mctr++ ; i++
              if i>len(munit2)
                 exit
              endif
        enddo
   enddo
   munit := aclone( munit2 )
return nil
***************************************************************************
*  Description  Displays RECORDS which have no DUPLICATES from
*                         Cadetail.dbf or Acctmast.dbf
*
static function remove_singles ( mar, mtotal, mdbf, mamount)
***************************************************************************
   local i:=1 , mdup := 0 , mpos := 0, mfcltycode, mrecno

   while i <= len ( mar )

      mfcltycode := mar [ i ] [1]; mdup := 0; mpos := i; mrecno := 0
      while mar [ i ] [1] == mfcltycode
         mdup++ ; i++
         if i > len ( mar )
            exit
         endif
      enddo

      if mdup == 1
         do case
         
            case upper(mdbf) == upper ( 'Acctmast' )
                 Acctmast->( dbseek ( Caheader->CLNTCODE ) )
                 Acctmast->( dbeval ( {|| if( Acctmast->FCLTYCODE == mfcltycode, dispdetcontents(Acctmast->FCLTYCODE,mtotal) ,nil) },,;
                                      {|| Acctmast->CLNTCODE == Caheader->CLNTCODE .and. !Acctmast->(eof()) }) )
            otherwise
                 details( mfcltycode, mtotal, mar[i-1] [12], mamount)
         endcase
         
         adel  ( mar, mpos ) ; asize ( mar, len( mar )-1 )  ; i--

      endif

   enddo
   if ( !empty(mar) .and. upper(mdbf) == upper('Cadetail'), filter_include( mar,mtotal ),nil )
return nil
********************************************
*
static function filter_include( mar,mtotal )
********************************************
   local mretval := .t., mctr := 1
   while mctr <= len( mar )
        vali_inc( mar, @mctr, mar[mctr][1], mtotal )
        mctr++
   enddo
return nil
******************************************************
*
static function vali_inc( mar,mindex,mfc,mtotal )
******************************************************
   local mretval := .t.

   if mindex < len(mar)
      if mar [mindex] [11] .and. mar [mindex+1] [11]
         details( mfc,mtotal, mar [mindex] [12] )
         adel  ( mar, mindex ) ; asize ( mar, len( mar )-1 ) ; mindex--
      endif
   else
      do case
         case mindex-1 == 0          // NO RECORD LEFT !!!
              details( mfc,mtotal,mar[mindex][12])
              adel ( mar, mindex ) ; asize ( mar, len( mar )-1 )
              mretval := .f.
         case mindex-2 >= 1          // greater than or equal to ONE RECORD LEFT
              if mar [mindex  ] [11] .and. ; //  INCLUDE = Y
                !mar [mindex-1] [11] .and. ; //  INCLUDE = N
                 mar [mindex-2] [11]         //  INCLUDE = Y
                 details( mfc,mtotal,mar[mindex] [12] )
                 adel ( mar, mindex ) ; asize ( mar, len( mar )-1 ) ; mindex--
              endif
      endcase
   endif
return mretval
********************************************
*
static function details( mfc,mtotal,mrecno )
********************************************
   Cadetail-> ( dbseek ( Caheader->CANUMBER ) )
   Cadetail-> ( dbeval ( {|| if( Cadetail->(recno()) == mrecno .and.  ;
                                 Cadetail->FCLTYCODE == mfc          ,;
                                 eval ({|| dispdetcontents(Cadetail->FCLTYCODE,mtotal) });
                                 ,nil;
                                ) ;
                         },,;
                         {|| Cadetail->CANUMBER == Caheader->CANUMBER .and. ;
                             !Cadetail->(eof()) ;
                         };
                       ))
return nil
**********************************************************************
*  Description  Transfers selected records from ACCTMAST.DBF to array
*                          and Accumulate OUTSTANDING BALANCE
*
static function trans_first( mar, moutstanding )
************************************************
    Acctmast->( dbseek ( Caheader->CLNTCODE ) )
    Acctmast->( dbeval ( { || aadd ( mar   , { Acctmast->FCLTYCODE ,;
                                               eval({|| Facility->(dbseek(Acctmast->FCLTYCODE)),Facility->SETCODE }),;
                                               Acctmast->GD        ,;
                                               Acctmast->RV        ,;
                                               Acctmast->TERM      ,;
                                               Acctmast->ORIXUNIT  ,;
                                               Acctmast->AMORT     ,;
                                               Acctmast->TRUERATE  ,;
                                               Acctmast->PRINCIPAL ,;
                                               Acctmast->MATDATE   ,;
                                               Acctmast->CLNTCODE   ;
                                              } ;
                                   ),;
                              moutstanding += Acctmast->OSBAL ;
                         },,;
                         { || Acctmast->CLNTCODE == Caheader->CLNTCODE .and. ;
                             !Acctmast->(eof()) ;
                         };
                       );
              )
    asort ( mar,,,{|x,y| x[1]<y[1] } )  // sort by Facility Code
return nil
**************************************************************************
*  Description  Transfers selected records from CADETAIL.DBF to array
*                          and Accumulate CREDIT AMOUNT
*
static function tfirst( mar, mtotcred )
**************************************************************************
    Cadetail->( dbseek ( Caheader->CANUMBER ) )
    Cadetail->( dbeval ( { || aadd ( mar ,{ Cadetail->FCLTYCODE ,;
                                            eval({|| Facility->(dbseek(Cadetail->FCLTYCODE)),Facility->SETCODE }),;
                                            Cadetail->GD           ,;
                                            Cadetail->RV           ,;
                                            Cadetail->TERM         ,;
                                            Cadetail->UNIT         ,;
                                            Cadetail->UNIT2        ,;
                                            Cadetail->AMORT        ,;
                                            Cadetail->TRUERATE     ,;
                                            Cadetail->PRINCIPAL    ,;
                                            Cadetail->INCLUDE      ,;
                                            Cadetail->(recno())    ,;
                                            Cadetail->PRINCIPAL    ,;
                                            Cadetail->FACTOR       ,;
                                            Cadetail->NOTFCTN      ,;
                                            Cadetail->COLEXION     ,;
                                            Cadetail->RECOURSE     ,;
                                            Cadetail->OBLIGOR       ;
                                           };
                                   ) ;
                              } ,,;
                { || Cadetail->CANUMBER == Caheader->CANUMBER .and. !Cadetail->(eof())});
              )
return nil
**********************************************************************************************************************
*  Description  Add values to ARRAY mp_ar for each setcode
*
function each_setcode ( mp_ar, mfcltycode, msetcode,mgd,mrv,mterm,mdbf,mmaturity,mnetproceeds,mrentfactor )
**********************************************************************************************************************
    local mgd2,mrv2,mterm2

    do case
       case msetcode == '1'
           if upper(mdbf) == upper ( 'Acctmast' )
            aadd ( mp_ar,{ mfcltycode ,;
                           msetcode   ,;
                           eval  ({|| 'Guaranty Deposit      : '+ ltrim(transform( mgd[1],'99.999999%' )) + if( len(mgd)>1 .and. atail(mgd) != mgd[1], ' - ' + transform ( atail(mgd),'99.999999%'),' ')  }) ,;
                           eval  ({|| 'Residual Value        : '+ ltrim(transform( mrv[1],'99.999999%' )) + if( len(mrv)>1 .and. atail(mrv) != mrv[1], ' - ' + transform ( atail(mrv),'99.999999%'),' ')  }) ,;
                           eval  ({|| 'Effective Rate        : ' }),;
                           eval  ({|| 'Total Monthly Rental  : ' }),;
                           eval  ({|| 'Maturity Date         : '+ ltrim(dtoc( mmaturity[1] ) )+ ' - ' + ltrim( dtoc( atail(mmaturity) ) ) }),;
                           eval  ({|| 'Items for Lease       : ' }) ;
                         };
                 )
           else
            aadd ( mp_ar,{ mfcltycode   ,;
                           msetcode     ,;
                           eval ({|| 'Purchase Amount       : '}) ,;
                           eval ({|| 'Guaranty Deposit      : '+ get_rv   ( mgd   ) }),;
                           eval ({|| 'Residual Value        : '+ get_rv   ( mrv   ) }),;
                           eval ({|| 'Term                  : '+ get_term ( mterm ) }),;
                           eval ({|| 'Effective Rate        : ' }) ,;
                           eval ({|| 'Monthly Rental        : ' }) ,;
                           eval ({|| 'Monthly Rental Factor : ' }) ,;
                           eval ({|| 'Items for Lease       : ' })  ;
                         };
                 )
            endif
       case msetcode == '2' .or. msetcode == '3'
            if upper(mdbf) == upper ( 'Acctmast' )
               aadd ( mp_ar,{ mfcltycode ,;
                              msetcode   ,;
                              eval  ({|| 'Term                  : '+ ltrim(transform( mterm[1],'999' ))  + ' Months ' +if( len(mterm)>1 .and. atail(mterm) != mterm[1], ' - ' + transform ( atail(mterm),'999')+' Months',' ')  }),;
                              eval  ({|| 'Effective Rate        : ' })     ,;
                              eval  ({|| 'Total Amortization    : '}) ,;
                              eval  ({|| 'Maturity Date         : '+ ltrim(dtoc( mmaturity[1] ) ) + ' - ' + ltrim( dtoc(atail(mmaturity)) ) }) ,;
                              eval  ({|| 'Collateral            : ' })      ;
                            };
                    )
            else
               aadd ( mp_ar,{ mfcltycode ,;
                              msetcode   ,;
                              eval ({|| 'Net Proceeds          : ' }),;
                              eval ({|| 'Term                  : ' + get_term(mterm) }),;
                              eval ({|| 'Effective Rate        : ' }),;
                              eval ({|| 'Monthly Amortization  : ' }),;
                              eval ({|| 'Collateral            : ' }) ;
                            };
                    )
            endif
       otherwise
            if upper(mdbf) == upper ( 'Acctmast' )
               aadd ( mp_ar,{ mfcltycode,;
                              msetcode  ,;
                              eval ({|| 'Term                  : '+ ltrim(transform( mterm[1],'999' ))  + ' Months ' +if( len(mterm)>1 .and. atail(mterm) != mterm[1], ' - ' + transform ( atail(mterm),'999')+' Months',' ')  }),;
                              eval ({|| 'Effective Rate        : '}),;
                              eval ({|| 'Collateral            : ' }) };
                    )
            else
               aadd ( mp_ar,{ mfcltycode ,;
                              msetcode   ,;
                              eval ({|| 'Net Proceeds          : ' }) ,;
                              eval ({|| 'Term                  : '+ get_term( mterm ) }) ,;
                              eval ({|| 'Effective Rate        : ' }) ,;
                              eval ({|| 'Notification          : ' }) ,;
                              eval ({|| 'Collection            : ' }) ,;
                              eval ({|| 'Recourse              : ' }) ,;
                              eval ({|| 'Obligor               : ' }) ,;
                              eval ({|| 'Collateral            : ' }) };
                    )
            endif
    endcase
return nil
**********************************
*
static function get_term ( mterm )
**********************************
   local mretval := ''
return eval ({|| aeval ( mterm,{|x| mretval += ' ; ' + ltrim(trans(x,'999')) }),;
                 mretval := substr( mretval,4,len(mretval)-3) + ' Months' ;
            })
******************************
*
static function get_rv ( mrv )
******************************
   local mretval := ''
return eval ({|| aeval ( mrv,{|x| mretval += ' ; ' + ltrim(trans(x,'99.999999 %')) }),;
                 mretval := substr( mretval,4,len(mretval)-3) })
//
//             ****    END OF ACCTMAST/CADETAIL VALIDATION  ****
//
**************************************************************************************
*  Desc  Dump contents of the MEMO file (.dbt) to the PRINTING DEVICE
*
function print_memo ( mvar, misremarks,miscamemos, mrowlimit, mtotal,meject,moff_row,mprinted )
**************************************************************************************
   local mctr, mnumlines, i
   misremarks := if ( misremarks == nil , .f., misremarks )
   miscamemos := if ( miscamemos == nil , .f., miscamemos )
   mnumlines  := mlcount ( mvar ,if(miscamemos,133,75) )
   moff_row   := if ( moff_row == nil, 0, moff_row )
   mprinted   := if ( mprinted == nil,.f.,mprinted )  // July 5, 1995

   for mctr   := 1 to mnumlines + 1
       @ prow() + 1, moff_row say memoline(mvar,if(miscamemos,133,75),mctr,,.f.)

       if prow() >= mrowlimit

          do case
             case !miscamemos
                
                for i:= prow() to 47; devpos ( i, 0 ) ; devout ( ' ' ); next i
                devpos( prow() + 4, 002 ) ; devout( upper ( dispaoname(Oticket->AOCODE)) )
//                devpos( prow()    , 055 ) ; devout( upper ( dispaoname(Parametr->COSIGN) ) )
                devpos( prow() + 1, 002 ) ; devout( upper ( dispaopost(Oticket->AOCODE)) )
//                devpos( prow()    , 055 ) ; devout( upper ("Assistant Vice President") )

                if !mprinted
                   mprinted := .t.
                   disp_committee ( mtotal, , 55 )
                endif

                fejectpause()
                next_page()

             otherwise       // do printing of CA TO BE OBTAINED .and.

                if meject != nil
                   if mctr+1 <= mnumlines

                      @ prow() + 1, 00 say 'Next Page Please.'
                      for i := prow() to 47 ; @ i, 00 say ' ' ; next i
                      @ prow() + 3, 02  say upper( dispAONAME(Caheader->AOCODE) )
//                      devpos( prow()    , 098 )   ; devout( upper ( dispaoname(Parametr->COSIGN) ) )
                      devpos( prow() + 1, 002 )   ; devout( upper ( dispaopost(Caheader->AOCODE) ) )
//                      devpos( prow()    , 098 )   ; devout( upper ("Assistant Vice President") )

                      if (!meject,eval({|| meject := .t.,disp_committee ( mtotal,.t., 56, Caheader->CATYPE )}),nil)
                      check_if_page_finished( ,miscamemos, )

                   endif
               endif

          endcase
       endif

   next i

   @ prow() , pcol() say ''
return nil
**********************************************************
*
static function dispdetcontents( mfcltycode,mtotal )
**********************************************************
   local mSETCODE := eval ({ || Facility->( dbseek ( mFCLTYCODE ) ) ,;
                                Facility-> SETCODE                   ;
                          })
  ask_setcode( Facility->SETCODE,mtotal )
return nil
***********************************************************
*
static function ask_setcode( msetcode, mtotal, mis_review )
***********************************************************
   memvar meject
   local mlimit := 0, i,mcaline := 0

   devpos( prow()+1, 000 ) ; devout( '³' )
   devpos( prow()  , 091 ) ; devout( "³" )
   devpos( prow()  , 110 ) ; devout( "³" )
   devpos( prow()  , 132 ) ; devout( '³' )
   devpos( prow()+1, 000 ) ; devout( '³'+left(( alias() )->FCLTYCODE,3)+'-'+right(( alias() )->FCLTYCODE,2)+" ("+alltrim(Facility->FCLTYALIAS)+") "+left( alltrim( upper( Facility->FCLTYNAME ) ) , 40 ) )
   devpos( prow()  , 091 ) ; devout( "³" )

   if upper  ( alias() ) == upper( 'Cadetail' )
      devpos ( prow()  , 110 )  ; devout( "³" )
      if Cadetail->INCLUDE
         devpos ( prow()  , 116 )  ; devout( transform( ( alias() )->CREDAMT,"999,999,999.99" ) )
      endif
   else

      devpos ( prow()  , 094 )  ; devout( transform( ( alias() )->OSBAL  ,"999,999,999.99" ) )
      devpos ( prow()  , 110 )  ; devout( "³" )

      if ( alias() ) -> FCLTYCODE $ '_4_5'

         if present_in_caheader( @mcaline, ( alias() ) -> CLNTCODE )
            devpos ( prow() , 116 ) ; devout ( transform( mcaline,"999,999,999.99" ) )
         endif                                

      endif

   endif

   devpos ( prow()  , 132 )     ; devout( '³' )

   do case
      case msetcode == '1'
           devpos( prow()+1, 000 ) ; devout( "³       Purchase Amount       : "+ ltrim(trans(( alias() )->PRINCIPAL,"999,999,999.99"))); sub_limit()     ;  disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 000 ) ; devout( "³       Guaranty Deposit      : "+ ltrim(trans(( alias() )->GD, "99.999999%") ))          ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 000 ) ; devout( "³       Residual Value        : "+ ltrim(trans(( alias() )->RV, "99.999999%")) )           ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 000 ) ; devout( "³       Term                  : "+ ltrim(trans(( alias() )->TERM,"999" )+ if((alias())->TERMUNIT == '1', ' Days',' Months') ))
           devpos( prow()  , pcol()+2 ) ; devout( ltrim(disp_paytype( (alias())->PAYTYPE ))  );disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 000 ) ; devout( "³       Effective Rate        : "+ ltrim(trans(( alias() )->TRUERATE,"99.99%") )) ; devPos( prow()  , pcol()+2+5 ) ; Devout( if( ( alias() )->RATETYPE $ '12', if( ( alias() )->RATETYPE == '1', 'Fixed   ', 'Floating' ), ' ')) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Monthly Rental        : "+ ltrim(trans(( alias() )->AMORT,"999,999,999.99") ))    ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Monthly Rental Factor : "+ ltrim(trans(( alias() )->FACTOR,"99.9999") ) )        ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Items for lease       : "+ ltrim(( alias() )->UNIT ))                             ; disp_3_lines()
           if !empty( (alias())->UNIT2 )
               _can_be_ejected(mtotal)
               devpos( prow()+1, 00 )  ; devout( "³                               "+ ltrim(( alias() )->UNIT2) )              ; disp_3_lines()
           endif
      case msetcode == '2'
           devpos( prow()+1, 00 )  ; devout( "³       Net Proceeds          : "+ ltrim(trans(( alias() )->PRINCIPAL,"999,999,999.99") ) ); sub_limit() ;  disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Term                  : "+ ltrim(trans(( alias() )->TERM,"999" )+ if((alias())->TERMUNIT == '1', ' Days',' Months') ))
           devpos( prow()  , pcol()+2 ) ; devout( ltrim(disp_paytype( (alias())->PAYTYPE) )  );disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Effective Rate        : "+ ltrim(trans(( alias() )->TRUERATE,"99.99%") )) ; DevPos( prow()  , pcol()+2+5 ) ;Devout( if( ( alias() )->RATETYPE $ '12', if( ( alias() )->RATETYPE == '1', 'Fixed   ', 'Floating' ), ' ') ) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Monthly Amortization  : "+ ltrim(trans(( alias() )->AMORT,"999,999,999.99") ))     ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Collaterals           : "+ ltrim(( alias() )->UNIT ))                              ; disp_3_lines()
           if !empty( (alias())->UNIT2 )
               _can_be_ejected(mtotal)
               devpos( prow()+1, 00 )  ; devout( "³                               "+ ltrim(( alias() )->UNIT2 ) )                        ; disp_3_lines()
           endif
      case msetcode == '3'
           devpos( prow()+1, 00 )  ; devout( "³       Unit                  : "+ltrim(( alias() )->UNIT  ))                              ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³                               "+ltrim(( alias() )->UNIT2 ))                              ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Dealer                : "+ltrim(dispDLRNAME( ( alias() )->DLRCODE ) ))             ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Sales Representative  : "+ ltrim(( alias() )->SALESREP ))                          ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Purchase Amount       : "+ ltrim(trans(( alias() )->PURCAMT,"999,999,999.99") ) )  ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Down Payment          : "+ ltrim(trans(( alias() )->DOWNPAY,"999,999,999.99") ))   ; disp_3_lines() ; _can_be_ejected(mtotal)
//           devpos( prow()+1, 00 )  ; devout( "³       Dealer's Incentive    : "+ ltrim(trans(( alias() )->INCENTIVE,"999,999,999.99")) ) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       D.I. / S.I.           : "+ ltrim(trans(( alias() )->INCENTIVE,"999,999,999.99")) ) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Net Proceeds          : "+ ltrim(trans(( alias() )->PRINCIPAL,"999,999,999.99")) ) ; sub_limit() ;  disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Term                  : "+ ltrim(trans(( alias() )->TERM,"999")+if( (alias())->TERMUNIT == '1',' Days',' Months') ))
           devpos( prow()  , pcol()+2 ) ; devout( ltrim(disp_paytype( (alias())->PAYTYPE ))  );disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Gross Rate            : "+ ltrim(trans(( alias() )->TRUERATE,"99.99%") ) )         ; devPos( prow()  , pcol()+2+5 ) ;Devout( if( ( alias() )->RATETYPE $ '12', if( ( alias() )->RATETYPE == '1', 'Fixed   ', 'Floating' ), ' ') ) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Monthly Amortization  : "+ ltrim(trans(( alias() )->AMORT,'999,999,999.99') ) )    ; disp_3_lines()
      case msetcode == '4'
           devpos( prow()+1, 00 )  ; devout( "³       Net Proceeds          : "+ ltrim(trans(( alias() )->PRINCIPAL,"999,999,999.99") )) ; sub_limit() ;  disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Type                  : "+ ltrim(trans(( alias() )->TRANTYPE,"@X" )+ if ( (alias())->TRANTYPE == '1',' Revolving', ' Special' ) ))      ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Term                  : "+ ltrim(trans(( alias() )->TERM,"999" )+if( (alias())->TERMUNIT == '1', ' Days', ' Months' )     ))
           devpos( prow()  , pcol()+2 ) ; devout( ltrim(disp_paytype( (alias())->PAYTYPE ))  );disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Effective Rate        : "+ ltrim(trans(( alias() )->TRUERATE,"99.99%") ))          ; DevPos( prow()  , pcol()+2+5 ) ;Devout( if( ( alias() )->RATETYPE $ '12', if( ( alias() )->RATETYPE == '1', 'Fixed   ', 'Floating' ), ' ') ) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Monthly Amortization  : "+ ltrim(trans(( alias() )->AMORT,"999,999,999.99") ) )    ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Notification          : "+ if( ( alias() )->NOTFCTN   $ '12' , if( ( alias() )->NOTFCTN == '1', 'With   ' , 'Without'     ),' ') ) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Collection            : "+ if( ( alias() )->COLEXION  $ '12' , if( ( alias() )->COLEXION == '1', 'Ours  ' , 'Theirs'      ),' ') ) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Recourse              : "+ if( ( alias() )->RECOURSE $ '12'  , if( ( alias() )->RECOURSE == '1', 'With   ' , 'Without'    ),' ') ) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Obligor               : "+ ltrim(( alias() )->OBLIGOR ))                           ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Collateral            : "+ ltrim(( alias() )->UNIT    ))                           ; disp_3_lines()
           if !empty( (alias())->UNIT2 )
               _can_be_ejected(mtotal)
               devpos( prow()+1, 00 )  ; devout( "³                               "+ ltrim(( alias() )->UNIT2 ))  ; disp_3_lines()
           endif
      case msetcode == '5'
           devpos( prow()+1, 00 ) ; devout( "³       Type                  : "+ ltrim(trans(( alias() )->TRANTYPE,"@X" )+ if ( (alias())->TRANTYPE == '1',' Revolving', ' Special' ) ))      ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 ) ; devout( "³       Term                  : "+ ltrim(trans(( alias() )->TERM,"999" )+ if ( (alias())->TERMUNIT == '1',' Days',' Months' ) ))      ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 ) ; devout( "³       Effective Rate        : "+ 'Minimum spread of ' +ltrim(trans(( alias() )->TRUERATE,"99.99%") )+ ' over the average cost of funds') ; disp_3_lines() ; _can_be_ejected(mtotal)  //DevPos( prow()  , pcol()+2+5 ) ;Devout( if( ( alias() )->RATETYPE $ '12', if( ( alias() )->RATETYPE == '1', 'Fixed   ', 'Floating' ), ' ') ) ;
           devpos( prow()+1, 00 ) ; devout( "³       Notification          : "+ if( ( alias() )->NOTFCTN   $ '12' , if( ( alias() )->NOTFCTN == '1', 'With   ' , 'Without'     ),' ') ) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 ) ; devout( "³       Collection            : "+ if( ( alias() )->COLEXION  $ '12' , if( ( alias() )->COLEXION == '1', 'Ours  ' , 'Theirs'      ),' ') ) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 ) ; devout( "³       Recourse              : "+ if( ( alias() )->RECOURSE $ '12'  , if( ( alias() )->RECOURSE == '1', 'With   ' , 'Without'    ),' ') ) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 ) ; devout( "³       Obligor               : "+ ltrim(( alias() )->OBLIGOR )) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 ) ; devout( "³       Collateral            : "+ ltrim(( alias() )->UNIT    )) ; disp_3_lines()
           if !empty( (alias())->UNIT2 )
               _can_be_ejected(mtotal)
               devpos( prow()+1, 00 )  ; devout( "³                               "+ ltrim(( alias() )->UNIT2  ) ) ; disp_3_lines()
           endif
   endcase
return nil
*************************************************************
*
static function present_in_caheader( mcaline,mclntcode )
*************************************************************
   local mcarec := Caheader -> ( recno() ), mcantx := Caheader -> (indexord())
   local mcanumber := Caheader -> CANUMBER
   local mretval := .f.

   Caheader -> ( dbsetorder ( 3 ) )    // CLIENT CODE
   if Caheader -> ( dbseek ( mclntcode ) )
      if Caheader -> ACTAKEN == '3'   // Approved ?
         if Caheader -> CANUMBER != mcanumber
            if Cadetail -> ( dbseek ( Caheader -> CANUMBER ) )
               Cadetail -> ( dbeval ( { ||  if ( Cadetail -> INCLUDE .and. ;
                                                 getsetcd ( Cadetail -> FCLTYCODE ) $ '_4_5' ,;
                                                 eval ( {|| mretval := .t. ,;
                                                            mcaline += Cadetail ->PRINCIPAL ;
                                                        };
                                                      ),;
                                                 nil ;
                                               );
                                      },,;
                                      { || !Cadetail -> ( eof() ) .and. ;
                                            Cadetail -> CANUMBER == Caheader -> CANUMBER ;
                                      };
                                    );
                            )
            endif
         endif
      endif
   endif

   Caheader -> ( dbsetorder ( mcantx ) )
   Caheader -> ( dbgoto( mcarec ) )
return mretval
/*
***************************************
*
static function disp_paytype( mpaytype )
***************************************
return if ( mpaytype $ '12', if( mpaytype == '1',' In Advance',' In Arrears'),'' )
*/
***************************************
*
static function _can_be_ejected(mtotal)
***************************************
   memvar meject, mpage,i
   if prow() >= ROWLIMIT
      @ prow() + 1, 00 say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
      @ prow() + 1, 00 say 'Next Page Please.'
      for i := prow() to ROWLIMIT ; @ i, 000 say '' ; next i
      @ prow() + 3, 002 say upper ( dispaoname( Caheader->AOCODE ) )
//      devpos( prow()    , 098 ) ; devout( upper ( dispaoname(Parametr->COSIGN) ) )
      devpos( prow() + 1, 002 ) ; devout( upper( dispaopost(Caheader->AOCODE)) )
//      devpos( prow()    , 098 ) ; devout( upper ("Assistant Vice President") )

      if !meject
         disp_committee(mtotal,.t.,55,Caheader->CATYPE) ; meject := .t.
      endif
      mpage++
      fejectpause()
      @ prow() + 1, 001 say 'CA Number     : '  +       Caheader->CANUMBER
      @ prow()    , 123 say 'Page : '+ trans( mpage, '999')
      @ prow() + 1, 001 say 'Client Name   : '+ dispclntname( Caheader->BRCODE+Caheader->CLNTCODE, 40  )
      @ prow() + 1, 000 say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
   endif
return nil
*********************************
*
static function disp_3_lines()
*********************************
   devPos( prow(), 091 ) ; devOut( "³" ) ; devPos( prow()  , 110 ) ; DevOut( "³" ) ; devPos( prow()  , 132 ) ; DevOut( '³')
return nil
*******************************************************
*
static function eject_in_facilities( mlimit, mtotal )
*******************************************************
      memvar meject
      local i
      if  alias() == upper('Cadetail')
          eval( {|x,y| x := savedbf(x),(alias())->(dbskip(+1)),;
                                      y := Caheader->CANUMBER == (alias())->CANUMBER,;
                                      restdbf(x),;
                                      y;
                                })
      endif

      @ prow() + 1, 00 say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
      @ prow() + 1, 00 say 'Next Page Please.'

      for i := prow() to 47 ; @ i, 00 say ' '; next i

      @ prow() + 2, 002 say upper ( dispaoname( Caheader->AOCODE ) )
//      devpos( prow()    , 098 )   ; devout( upper ( dispaoname(Parametr->COSIGN) ) )
      devpos( prow() + 1, 002 )   ; devout( upper ( dispaopost(Caheader->AOCODE)) )
//      devpos( prow()    , 098 )   ; devout( upper ("Assistant Vice President") )
       
      if meject != nil
         if !meject
            disp_committee ( mtotal,.t., 55,Caheader->CATYPE ); meject := .t.
         endif
      endif

      check_if_page_finished( , .t., .t. )

return nil
********************************************
*
static function get_setcode( msetcode )
********************************************
    local mretval
    do case
       case msetcode == '1'
            mretval := 9
       case msetcode == '2'
            mretval := 6
       case msetcode == '3'
            mretval := 11
       case msetcode == '4' .or. msetcode == '5'
            mretval := 10
    endcase
return mretval
**********************************************************************************
*
static function check_if_page_finished( mis_review, mis_camemos,misfromfacility )
**********************************************************************************
   memvar mpage

   mis_review      := if ( mis_review      == nil, .f., mis_review      )
   mis_camemos     := if ( mis_camemos     == nil, .f., mis_camemos     )
   misfromfacility := if ( misfromfacility == nil, .f., misfromfacility )

   if prow() >= ROWLIMIT

      if !mis_camemos
          @ prow() + 1, 00 say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
      endif

      mpage++
      fejectpause()
      @ prow() + 1, 001 say 'CA Number     : ' + Caheader->CANUMBER
      @ prow()    , 123 say 'Page : '+ trans( mPAGE, '999')
      @ prow() + 1, 001 say 'Client Name   : '+ dispCLNTNAME( Caheader->BRCODE+Caheader->CLNTCODE, 40 )

      if !mis_camemos
         @ prow() + 1, 000 say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
         @ prow() + 1, 000 say '³                                                                                          ³  OUTSTANDING IN  ³AMOUNT OF LINE AND/OR³'
         @ prow() + 1, 000 say '³                         DESCRIPTION OF CREDIT FACILITIES                                 ³ CURRENCY OF DEBT ³ SPECIAL TRANSACTION ³'
         @ prow() + 1, 000 say 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
      else
         do case
            case misfromfacility
                 @ prow() + 1, 000 say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
            otherwise
                 @ prow() + 1, 000 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
         endcase
      endif

      if mis_review
         @ prow() + 1, 000 say '³'
         setfont('UNDERLINE')
         @ prow(),pcol()   say upper( 'Existing Liabilities ')+' : '
         setfont('OFFUNDERLINE')
      else
         if !mIS_CAMEMOS
            @ prow() + 1, 000 say '³'
            setfont('UNDERLINE')
            @ prow(),pcol()   say upper( dispcatype( Caheader->CATYPE ) )+' : '
            setfont('OFFUNDERLINE')
         endif
      endif
      if !mIS_CAMEMOS
          devpos( prow()  , 091 ) ; devout( "³" )
          devpos( prow()  , 110 ) ; devout( "³" )
          devpos( prow()  , 132 ) ; devout( "³" )
      endif
   endif

return nil
*************************************
*  Desc ¯
*
function dispcrd ( mclntcode )
*************************************
   local mcred := {'UNCLASSIFIED','LOANS ESP. MENTIONED','SUBSTANDARD SECURED','DOUBTFUL','LOSS','SUBSTANDARD UNSECURED'}
   local mretval := space( len ( Corpinfo -> CREDRISK )+ 10 )
   local mrisk

   if Corpinfo -> ( dbseek( mclntcode ) )

      mrisk := alltrim ( Corpinfo -> CREDRISK )

      do case
         case mrisk == 'I'
            mretval := mrisk + ' ' +  mcred [1]
         case mrisk == 'II'
            mretval := mrisk + ' ' +  mcred [2]
         case mrisk == 'III'
            mretval := mrisk + ' ' +  mcred [3]
         case mrisk == 'IV'
            mretval := mrisk + ' ' +  mcred [4]
         case mrisk == 'V'
            mretval := mrisk + ' ' +  mcred [5]
         case mrisk == 'VI'
            mretval := mrisk + ' ' +  mcred [6]
      endcase

   endif

return mretval
*************************************
*
static function dispELR ( mclntcode )
*************************************
return eval ({|x,y| x := savedbf (x)               ,;
                    Corpinfo->(dbseek(mclntcode))  ,;
                    y := Corpinfo->LIABREV         ,;
                    restdbf (x)                    ,;
                    y                               ;
            })
/*
*************************************
*
function dispindustry ( mindcode )
*************************************
return eval ({|x,y| x := savedbf( x )              ,;
                    Industry->(dbseek( mindcode )) ,;
                    y:=Industry->INDNAME           ,;
                    restdbf( x )                   ,;
                    y                               ;
            })
*/
*************************************
*
static function dispcatype( mCATYPE )
*************************************
   local mCACHOICES := space(52) + 'Proposed Facility                                   '+;
                                   'Existing Liabilities                                '+;
                                   'Proposed Facility And Review of Existing Liabilities'+;
                                   'Reclassification of credit risk                     '
return alltrim( substr( mCACHOICES, val( mCATYPE ) * 52 + 1 , 52 ) )
**************************************************************************************
*  Desc ¯ lets the user to choose the members of the committee selected
*
*
function check_committee(  mTOTAL, mCOMNAME, members, fullname, msignees, mdispcomm, mcatype )
**************************************************************************************
   local  mSCR        := savescreen ( ,,, )    ,;
          mCOLOR      := setcolor ()           ,;
          mdbf        := savedbf ( mdbf )      ,;
          mMERON      := .f.                   ,;
          mCOMCODE , i      , getlist := {}    ,;
          mSELECTED, mSIGNEE, mREQB            ,;
          mOK_TO_SELECT                        , ncolor,;
          mGCTR := 0 , mCTR  := 0, mcomrec := Comcodes->(recno())

   memvar mSCREEN
   private groups    := {}

   set device to screen
   mSCR := savescreen ( ,,, )
   restscreen ( ,,,, mSCREEN )

   setcolor ( NRM )

   if mtotal <= 0
      fshadow ( 4, 5, 6, 34, 2, 'n/w')
      mtotal := 0
      ncolor := setcolor()   
      setcolor( 'bg+/w, w+/n,,, gr+/w' )
      @ 5,  6 say 'Line Amount ' get mtotal pict '999,999,999.99'
      setcursor ( 3 )
      read
      setcursor ( 0 )
      setcolor( mcolor )
   endif

   center ( 24, 'w+/n', '® Select Signees ¯' )

   dbselectarea ( "Comcodes" )
   Comcodes->( dbgotop() )
   Comcodes->( dbeval ( { || ;
                  if ( mTOTAL >= Comcodes->MINIMUM .and. mTOTAL <= Comcodes->MAXIMUM,;
                       eval({ || mcomrec  := Comcodes->(recno()) ,;
                                 mMERON   := .t., mCOMCODE := Comcodes->COMCODE     ,;
                                 mCOMNAME := Comcodes->COMNAME                      ,;
                                 mSIGNEES := Comcodes->SIGNEES                      ,;
                                 mREQB    := Comcodes->REQB                          ;
                            })                                                      ,;
                       Nil                                                           ;
                     )                                                               ;
               }                                                                   ,,;
               { || !Comcodes->( eof() )  }                                          ;
              );
             )

   if mcatype != nil

      if alltrim ( mcatype ) == '4' .and. mCOMCODE != g_BOARD_COMM     // EVR 28122006 - changed from Parametr->BOARD_COMM

         if Comcodes -> ( dbseek ( g_RISK_COMM ) )     // EVR 28122006 - changed from Parametr->RISK_COMM

            mcomrec  := Comcodes->(recno())
            mmeron   := .t.
            mCOMCODE := Comcodes->COMCODE
            mcomname := Comcodes->COMNAME
            msignees := Comcodes->SIGNEES
            mreqb    := Comcodes->REQB

         endif

      endif
   endif

   if !mmeron
       error ( 'Total Amount has No Range in Committee File.' )
       restscreen ( ,,,, mSCR )
       restdbf ( mdbf )
       return .f.
   else
      dbselectarea ( "Comember" )
      if Comember->( dbseek ( mCOMCODE ) )
         dbeval    ( {||  aadd( members, '  '+Comember->SHORTNAME+' ³ '+ Comember->GRUPCODE ) ,;
                          aadd( fullname, Comember->SHORTNAME)             ,;
                          aadd( groups  , Comember->GRUPCODE )              ;
                     }                                                    ,,;
                     {|| !Comember->( eof() ) .and. Comember->COMCODE == mCOMCODE } ;
                   )
         Comcodes->( dbgoto(mcomrec) )
      endif

      fshadow( 08, 1, 21, 33, 2 , 'w/gr+,w/n,,,w/gr+')
      devpos ( 08, 1 ) ; devout ( 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿', 'w/gr+' )
      devpos ( 09, 1 ) ; devout ( '³      Signees      ³   Group   ³', 'w/gr+' )
      devpos ( 10, 1 ) ; devout ( 'ÆÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍµ', 'w/gr+' )
      devpos ( 11, 1 ) ; devout ( '³' + left( mCOMNAME, 28 ) + '   ³', 'w/gr+' )
      devpos ( 19, 3 ) ; devout ( '<Spacebar>Select/Unselect', 'W/GR+' )
      msignee  := 1
      devpos ( 20, 3 ) ; devout ( 'Selected   0 / ' + trans( mSIGNEES, '99'), 'W/GR+')
      mSELECTED      :=  0 ; mOK_TO_SELECT  := .t.
      do while mSIGNEE != 0
         mSIGNEE := achoice ( 12, 3, 18, 31, members, mOK_TO_SELECT ,'myfunc', mSIGNEE )

         do case
            case lastkey () == K_ENTER .or. lastkey() == K_ESC

               mGCTR := 0
               mCTR  := 0
               for i := 1 to len ( members )
                   if left ( members [i], 1 ) == 'û'
                      mCTR++
                      if groups [ i ] == 'B'
                         mGCTR++
                       endif
                   endif
               next i

               if mGCTR < mREQB .or. mCTR < mSIGNEES

                  do case
                     case mGCTR < mREQB
                          error ( 'Insufficient N§ of Group B Signees,' )
                     case mCTR  < mSIGNEES
                          error ( 'Insufficient N§ of Signees Selected,' )
                  endcase

                  mSIGNEE := 1

               endif

            case lastkey () == 32

               if left( members [ mSIGNEE ], 1 ) = 'û'
                  members [ mSIGNEE ] := ' ' + right ( members [ mSIGNEE ], len ( members [ mSIGNEE ]  ) - 1 )
                  mSELECTED--
                  if ( mSELECTED < 0, mSELECTED := 0, Nil )
               else
                  if ( mSELECTED < mSIGNEES )
                     members [ mSIGNEE ] := 'û' + right ( members [ mSIGNEE ], len ( members [ mSIGNEE ] ) - 1 )
                     mSELECTED++ ; mSIGNEE++
                     if mSIGNEE > len ( members )
                        mSIGNEE := len ( members )
                     endif
                  else
                     tone( 300, 5 )
                  endif
               endif

               devpos ( 20, 3 ) ; devout ( 'Selected  '+ trans( mSELECTED,'99')+' / ' + trans( mSIGNEES, '99'), 'W/GR+')

         endcase
       enddo

   endif

   restscreen ( ,,,, mSCR )
   set device to printer

   restdbf ( mdbf )

return .t.
***************************
*
static function sub_limit()
***************************
return eval ({|| devpos ( prow(), pcol() ),;
                 devout ( if ( upper(alias()) == 'CADETAIL' .and. !(alias())->INCLUDE, ' (SUB-LIMIT)','') );
            })
/*
***********************************************
*  Desc 
*  Para 
*  Ret  
*
function myfunc ( status, curr_elem, curr_row )
***********************************************
   local key := lastkey()
   do case
      case key == K_ESC
         return 0
      case key == K_ENTER
         return 0
      case key == 32
         // tone( 1600, 1) ; tone( 800, 1)
         tone( 800, 1)
         return 1
    endcase
return 2

***********************************************
*   Desc ¯ returns the setcode of the current record
*          from Facility.dbf
*
static function getsetcd ( mfcltycode )
***********************************************
   Facility->(dbseek(mfcltycode))
return Facility->SETCODE
*/
*
*                     End of the Program ( amsm100b.prg )
*
