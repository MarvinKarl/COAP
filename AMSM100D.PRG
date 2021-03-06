/* 旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
   �   Program ID.........:  amsm100d.prg                                 �
   �   Description........:  Unavailed CA Line                            �
   �   Author.............:  Ariel B. Bulan                               �
   �   Date...............:  04:05pm 23-Mar-1994                          �
   쳐컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
   �                         U P D A T E S                                �
   쳐컴컴컴컴컴컴컴컴컴쩡컴컴컴컴컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
   �        Who        �     When      �               Why                �
   쳐컴컴컴컴컴컴컴컴컴탠컴컴컴컴컴컴컴탠컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
   �                   �               �                                  �
   �                   �               �                                  �
   읕컴컴컴컴컴컴컴컴컴좔컴컴컴컴컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
*/

#include "Colf.ch"
#include "Inkey.ch"
#include "Memoedit.ch"

#define ROWLIMIT  47

*****************************************************************************
*  Desc  Prints SINGLE FACILITIES
*  Para  CANUMBER,FACILITY CODE, TOTAL, CREDIT AMT., LINETYPE
*  Ret   nil
*
function disp_one ( mcanumber, mfcltycode,mtotal,mrecno,mcredamt,misregular )
*****************************************************************************
   Cadetail-> ( dbseek ( mcanumber+mfcltycode ) )
   Cadetail-> ( dbeval ( {|| if( Cadetail->(recno()) == mrecno                   ,;
                                 eval ( {|| if ( misregular != '1', mcredamt := Cadetail -> CREDAMT - Cadetail -> AVAILED, nil ),;
                                            dispdetcontents( mfcltycode,mtotal,mcredamt,misregular );
                                        };
                                      ),;
                                 nil ) ;
                         },,;
                         {|| Cadetail->CANUMBER == mcanumber .and. Cadetail->FCLTYCODE == mfcltycode .and. !Cadetail->(eof()) } ))
return nil
*********************************************************************************
*  Desc � Displays Cadetail/Acctmast contents
*
static function dispdetcontents( mfcltycode,mtotal,mcredamt,misregular )
*********************************************************************************
   local mSETCODE := eval ({ || Facility->( dbseek ( mFCLTYCODE ) ) ,;
                                Facility-> SETCODE                   ;
                          })
  ask_setcode( Facility->SETCODE,mtotal,mcredamt,misregular )
return nil
***************************************************************************
*  Desc � determine the Facility->SETCODE of ( Cadetail->FCLTYCODE .or.
*                                              Acctmast->FCLTYCODE )
*
static function ask_setcode( msetcode,mtotal,mcredamt,misregular )
***************************************************************************
   memvar meject
   local mlimit := 0, i

   devpos ( prow()+1, 000 ) ; devout( '�'+left(( alias() )->FCLTYCODE,3)+'-'+right(( alias() )->FCLTYCODE,2)+" ("+alltrim(Facility->FCLTYALIAS)+") "+left( alltrim( upper( Facility->FCLTYNAME ) ) , 40 ) )

   if misregular == '1'                          && OMNIBUS
      devpos ( prow()  , 091 ) ; devout( "�" )
      devpos ( prow()  , 110 ) ; devout( "�" )
      devpos ( prow()  , 132 ) ; devout( '�' )
   else                                          && REGULAR
      devpos ( prow()  , 091 ) ; devout( "�" )
      devpos ( prow()  , 110 ) ; devout( "�" )
      devpos ( prow()  , 116 ) ; devout( transform( mcredamt,"999,999,999.99" ) )
      devpos ( prow()  , 132 ) ; devout( '�' )
   endif

   do case
      case msetcode == '1'
           if misregular == '1'
               devpos( prow()+1, 000 ) ; devout( "�       Purchase Amount       : "+ ltrim(trans(( alias() )->PRINCIPAL,"999,999,999.99"))) ; sub_limit()    ;  disp_3_lines() ; _can_be_ejected(mtotal)
           else
               devpos( prow()+1, 000 ) ; devout( "�       Purchase Amount       : "+ ltrim(trans(( alias() )->PRINCIPAL-(alias())->PRNAVAIL,"999,999,999.99"))) ; sub_limit()    ;  disp_3_lines() ; _can_be_ejected(mtotal)
           endif
           devpos( prow()+1, 000 ) ; devout( "�       Guaranty Deposit      : "+ ltrim(trans(( alias() )->GD, "99.99%") ))              ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 000 ) ; devout( "�       Residual Value        : "+ ltrim(trans(( alias() )->RV,"99.99%")) )               ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 000 ) ; devout( "�       Term                  : "+ ltrim(trans(( alias() )->TERM,"999" )+' Months' ))
           devpos( prow()  , pcol()+2 ) ; devout( ltrim(disp_paytype( (alias())->PAYTYPE ))  );disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 000 ) ; devout( "�       Effective Rate        : "+ ltrim(trans(( alias() )->TRUERATE,"99.99%") )) ; devPos( prow()  , pcol()+2+5 ) ; Devout( if( ( alias() )->RATETYPE $ '12', if( ( alias() )->RATETYPE == '1', 'Fixed   ', 'Floating' ), ' ')) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 000 ) ; devout( "�       Monthly Rental        : "+ ltrim(trans(( alias() )->AMORT,"999,999,999.99") ))    ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 000 ) ; devout( "�       Monthly Rental Factor : "+ ltrim(trans(( alias() )->FACTOR,"99.9999") ) )          ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 000 ) ; devout( "�       Items for lease       : "+ ltrim(( alias() )->UNIT ))                             ; disp_3_lines()
           if !empty( (alias())->UNIT2 )
               _can_be_ejected(mtotal)
               devpos( prow()+1, 00 )  ; devout( "�                               "+ ltrim(( alias() )->UNIT2) )              ; disp_3_lines()
           endif
      case msetcode == '2'
           if misregular == '1'
              devpos( prow()+1, 00 )  ; devout( "�       Net Proceeds          : "+ ltrim(trans(( alias() )->PRINCIPAL,"999,999,999.99") ) ); sub_limit() ;  disp_3_lines() ; _can_be_ejected(mtotal)
           else
              devpos( prow()+1, 00 )  ; devout( "�       Net Proceeds          : "+ ltrim(trans(( alias() )->PRINCIPAL-(alias())->PRNAVAIL,"999,999,999.99") ) ); sub_limit() ;  disp_3_lines() ; _can_be_ejected(mtotal)
           endif
           devpos( prow()+1, 00 )  ; devout( "�       Term                  : "+ ltrim(trans(( alias() )->TERM,"999" )+' Months' ))
           devpos( prow()  , pcol()+2 ) ; devout( ltrim(disp_paytype( (alias())->PAYTYPE) )  );disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 000 ) ; devout( "�       Effective Rate        : "+ ltrim(trans(( alias() )->TRUERATE,"99.99%") )) ; DevPos( prow()  , pcol()+2+5 ) ;Devout( if( ( alias() )->RATETYPE $ '12', if( ( alias() )->RATETYPE == '1', 'Fixed   ', 'Floating' ), ' ') ) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 000 ) ; devout( "�       Monthly Amortization  : "+ ltrim(trans(( alias() )->AMORT,"999,999,999.99") ))     ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 000 ) ; devout( "�       Collaterals           : "+ ltrim(( alias() )->UNIT ))                              ; disp_3_lines()
           if !empty( (alias())->UNIT2 )
               _can_be_ejected(mtotal)
               devpos( prow()+1, 00 )  ; devout( "�                               "+ ltrim(( alias() )->UNIT2 ) )                           ; disp_3_lines()
           endif
      case msetcode == '3'
           devpos( prow()+1, 000 ) ; devout( "�       Unit                  : "+ltrim(( alias() )->UNIT  ))     ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 000 ) ; devout( "�                               "+ltrim(( alias() )->UNIT2 ))     ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 000 ) ; devout( "�       Dealer                : "+ltrim(dispDLRNAME( ( alias() )->DLRCODE ) )) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 000 ) ; devout( "�       Sales Representative  : "+ ltrim(( alias() )->SALESREP )) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 000 ) ; devout( "�       Purchase Amount       : "+ ltrim(trans(( alias() )->PURCAMT,"999,999,999.99") ) )  ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 000 ) ; devout( "�       Down Payment          : "+ ltrim(trans(( alias() )->DOWNPAY,"999,999,999.99") ))   ; disp_3_lines() ; _can_be_ejected(mtotal)
//           devpos( prow()+1, 000 ) ; devout( "�       Dealer's Incentive    : "+ ltrim(trans(( alias() )->INCENTIVE,"999,999,999.99")) ) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 000 ) ; devout( "�       D.I. / S.I.           : "+ ltrim(trans(( alias() )->INCENTIVE,"999,999,999.99")) ) ; disp_3_lines() ; _can_be_ejected(mtotal)
           if misregular == '1'
               devpos( prow()+1, 00 )  ; devout( "�       Net Proceeds          : "+ ltrim(trans(( alias() )->PRINCIPAL,"999,999,999.99")) ) ; sub_limit() ;  disp_3_lines() ; _can_be_ejected(mtotal)
           else
               devpos( prow()+1, 00 )  ; devout( "�       Net Proceeds          : "+ ltrim(trans(( alias() )->PRINCIPAL-(alias())->PRNAVAIL,"999,999,999.99")) ) ; sub_limit() ;  disp_3_lines() ; _can_be_ejected(mtotal)
           endif
           devpos( prow()+1, 00 )  ; devout( "�       Term                  : "+ ltrim(trans(( alias() )->TERM,"999"+' Months') ))
           devpos( prow()  , pcol()+2 ) ; devout( ltrim(disp_paytype( (alias())->PAYTYPE ))  );disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "�       Gross Rate            : "+ ltrim(trans(( alias() )->TRUERATE,"99.99%") ) )         ; devPos( prow()  , pcol()+2+5 ) ;Devout( if( ( alias() )->RATETYPE $ '12', if( ( alias() )->RATETYPE == '1', 'Fixed   ', 'Floating' ), ' ') ) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "�       Monthly Amortization  : "+ ltrim(trans(( alias() )->AMORT,'999,999,999.99') ) )    ; disp_3_lines()
      case msetcode == '4'
           devpos( prow()+1, 000 ) ; devout( "�       Net Proceeds          : "+ ltrim(trans(( alias() )->PRINCIPAL,"999,999,999.99") )) ; sub_limit() ;  disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 000 ) ; devout( "�       Term                  : "+ ltrim(trans(( alias() )->TERM,"999" )+' Months' ))
           devpos( prow()  , pcol()+2 ) ; devout( ltrim(disp_paytype( (alias())->PAYTYPE ))  );disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 000 ) ; devout( "�       Effective Rate        : "+ ltrim(trans(( alias() )->TRUERATE,"99.99%") ))          ; DevPos( prow()  , pcol()+2+5 ) ;Devout( if( ( alias() )->RATETYPE $ '12', if( ( alias() )->RATETYPE == '1', 'Fixed   ', 'Floating' ), ' ') ) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 000 ) ; devout( "�       Monthly Amortization  : "+ ltrim(trans(( alias() )->AMORT,"999,999,999.99") ) )    ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 000 ) ; devout( "�       Notification          : "+ if( ( alias() )->NOTFCTN   $ '12' , if( ( alias() )->NOTFCTN == '1', 'With   ' , 'Without'     ),' ') ) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 000 ) ; devout( "�       Collection            : "+ if( ( alias() )->COLEXION  $ '12' , if( ( alias() )->COLEXION == '1', 'Ours  ' , 'Theirs'      ),' ') ) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 000 ) ; devout( "�       Recourse              : "+ if( ( alias() )->RECOURSE $ '12'  , if( ( alias() )->RECOURSE == '1', 'With   ' , 'Without'    ),' ') ) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 000 ) ; devout( "�       Obligor               : "+ ltrim(( alias() )->OBLIGOR ))  ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 000 ) ; devout( "�       Collateral            : "+ ltrim(( alias() )->UNIT    ))  ; disp_3_lines()
           if !empty( (alias())->UNIT2 )
               _can_be_ejected(mtotal)
               devpos( prow()+1, 00 )  ; devout( "�                               "+ ltrim(( alias() )->UNIT2 ))  ; disp_3_lines()
           endif
      case msetcode == '5'
           if misregular == '1'
               devpos( prow()+1, 00 )  ; devout( "�       Net Proceeds          : "+ ltrim(trans(( alias() )->PRINCIPAL,"999,999,999.99")) ) ; sub_limit() ;  disp_3_lines() ; _can_be_ejected(mtotal)
           else
               devpos( prow()+1, 00 )  ; devout( "�       Net Proceeds          : "+ ltrim(trans((alias() )->PRINCIPAL-( alias() )->PRNAVAIL,"999,999,999.99")) ) ; sub_limit() ;  disp_3_lines() ; _can_be_ejected(mtotal)
           endif
           devpos( prow()+1, 00 )  ; devout( "�       Maximum Term          : "+ ltrim(trans(( alias() )->TERM,"999" )+' Months' ))      ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "�       Interest Rate         : "+ ltrim(trans( ( alias() )->TRUERATE,"99.9999%" ) ))      ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "�       Monthly Amortization  : "+ ltrim(trans(( alias() )->AMORT,"999,999,999.99") ))     ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "�       Notification          : "+ if( ( alias() )->NOTFCTN   $ '12' , if( ( alias() )->NOTFCTN == '1', 'With   ' , 'Without'     ),' ') ) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "�       Collection            : "+ if( ( alias() )->COLEXION  $ '12' , if( ( alias() )->COLEXION == '1', 'Ours  ' , 'Theirs'      ),' ') ) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "�       Recourse              : "+ if( ( alias() )->RECOURSE $ '12'  , if( ( alias() )->RECOURSE == '1', 'With   ' , 'Without'    ),' ') ) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "�       Obligor               : "+ ltrim(( alias() )->OBLIGOR )) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "�       Collateral            : "+ ltrim(( alias() )->UNIT    )) ; disp_3_lines()
           if !empty( (alias())->UNIT2 )
               _can_be_ejected(mtotal)
               devpos( prow()+1, 00 )  ; devout( "�                               "+ ltrim(( alias() )->UNIT2  ) ) ; disp_3_lines()
           endif
   endcase
return nil
/*
*****************************************
*  Desc � returns payment type description
*
static function disp_paytype( mpaytype )
*****************************************
return if ( mpaytype $ '12', if( mpaytype == '1',' In Advance',' In Arrears'),'' )
*/
******************************************************************************
*  Desc � asks if current printer row exceeds the limit printer row varible
*
static function _can_be_ejected(mtotal)
******************************************************************************
   memvar meject, mpage,i
   if prow() >= ROWLIMIT
      @ prow() + 1, 00 say '읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴좔컴컴컴컴컴컴컴컴컴컴�'
      @ prow() + 1, 00 say 'Next Page Please.'
      for i := prow() to ROWLIMIT ; @ i, 000 say '' ; next i
      @ prow() + 3, 002 say upper ( dispaoname( Caheader->AOCODE ) )
      @ prow()    , 098 say upper ( 'Bernadette P. Astudillo'    )
      @ prow() + 1, 000 say '    Account Officer                                                                               Assistant Vice President'
      if !meject
         disp_committee(mtotal,.t.,55,Caheader->CATYPE) ; meject := .t.
      endif
      //__eject() ;
      mpage++
      fejectpause()
      @ prow() + 1, 001 say 'CA Number     : ' + Caheader->CANUMBER
      @ prow()    , 123 say 'Page : '+ trans( mpage, '999')
      @ prow() + 1, 001 say 'Client Name   : '+ dispclntname( Caheader->BRCODE+Caheader->CLNTCODE, 40  )
      @ prow() + 1, 000 say '旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴쩡컴컴컴컴컴컴컴컴컴컴�'
   endif
return nil
*************************************************
*  Desc � prints vertical lines of the current CA
*
function disp_3_lines()
*************************************************
   devpos( prow(), 091 ) ; devout( "�" ) ; devpos( prow()  , 110 ) ; devout( "�" ) ; devpos( prow()  , 132 ) ; devout( '�')
return nil
/*
******************************************************************
*  Desc � returns (SUB-LIMIT) if current CA is in omnibus LINETYPE
*
static function sub_limit()
******************************************************
memvar momnibus
return eval ({|| devpos ( prow(), pcol() ),;
                 devout ( if ( momnibus , '     (SUB-LIMIT)','') );
            })
*/
*
*                   End of the program ( amsm100d.prg )
*
