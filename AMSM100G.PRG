/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³   Program ID.........:  amsm100g.prg                                 ³
 ³   Description........:  Unavailed OT / Groups                        ³
 ³   Author.............:  Ariel B. Bulan                               ³
 ³   Date...............:  03:04pm 20-Jul-1995                          ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³                         U P D A T E S                                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³        Who        ³     When      ³               Why                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³ Janet L. Bautista ³  10-Sep-1997  ³ gd, rv to 5 decimal places       ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

#include "Colf.ch"
#include "Inkey.ch"

#define ROWLIMIT  47
*****************************************************************
*  Desc ¯  Compute the records with UNAVAILED OFFERING TICKET
*
*
function eval_unot ( mclntcode,mtotal,motavprinted )
*****************************************************************
   local mdbf := savedbf ( mdbf )

   if Oticket->( dbseek(mclntcode) )
      Oticket->( dbeval( {|| if( (Oticket->PROCEEDS-Oticket->PRNAVAIL)>0 .and.;
                                  Oticket->ACTAKEN == '3',;
                                  dispdetcontents( Oticket->FCLTYCODE,mtotal,@motavprinted,.f. ) ,;
                                  nil ;
                               );
                         },,;
                         {|| !Oticket->(eof()) .and. Oticket->CLNTCODE==mclntcode};
                       ) ;
               )
   endif

   restdbf ( mdbf )
return nil
***********************************************************************
*  Desc ¯ Compute the records with UNAVAILED OFFERING TICKET for GROUPS
*
function eval_ungrps ( mclntcode,mtotal,motavprinted )
***********************************************************************
   local mdbf := savedbf ( mdbf )
   local mgrupcode, mar := {}, i 

   if Grpmembr->(dbseek(mclntcode))

      mgrupcode := Grpmembr->GRUPCODE
      Grpmembr->( dbgotop() )
      Grpmembr->( dbeval( {|| if( Grpmembr->GRUPCODE == mgrupcode .and. Grpmembr->CLNTCODE != mclntcode,;
                                  aadd(mar,{Grpmembr->CLNTCODE,Grpmembr->GRUPCODE}),;
                                  nil;
                                );
                           },,;
                           {|| !Grpmembr->(eof()) };
                        );
                )

      for i := 1 to len(mar)
          if Oticket->( dbseek( mar[i][1] )) .and. Oticket->ACTAKEN == '3' .and. ;
             (Oticket->PROCEEDS-Oticket->PRNAVAIL) > 0
             Oticket ->( dbeval( {|| dispdetcontents( Oticket->FCLTYCODE,mtotal,@motavprinted,.t. ) },,;
                                 {|| !Oticket->(eof()) .and. Oticket->CLNTCODE == mar[i] [1] }) )
          endif
      next i

   endif

   restdbf ( mdbf )

return nil

**************************************************************************
*  Desc ¯ Prints CLIENTNAME of record(s) with UNAVAILED OFFERING TICKET
*
static function dispdetcontents ( mfcltycode,mtotal,motavprinted,mgroups )
**************************************************************************
   local mSETCODE := eval ({ || Facility->( dbseek ( mfcltycode ) ) ,;
                                Facility-> SETCODE                   ;
                          })

   if !motavprinted
      devpos ( prow()+1, 00 )  ; devout ( '³' )             ;  disp_3_lines()
      devpos ( prow()+1, 00 )  ; devout ( '³UNAVAILED OT' ) ;  disp_3_lines()
      motavprinted:= .t.
   endif

   if mgroups
      devpos ( prow()+1, 00 )  ; devout ( '³' )
      devpos ( prow()  , 01 )  ; devout ( dispclntname(Oticket->BRCODE+Oticket->CLNTCODE,40) )
      disp_3_lines()
   endif

   ask_setcode( Facility->SETCODE,mtotal )
return nil
*******************************************************
*  Desc ¯ Prints records with UNAVAILED OFFERING TICKET
*
static function ask_setcode( msetcode, mtotal )
*******************************************************
   memvar meject
   local mlimit := 0, i

   devpos( prow()+1, 000 )   ; devout( '³'+ left(Oticket->FCLTYCODE,3) + '-' + right( Oticket->FCLTYCODE,2)+" ("+alltrim(Facility->FCLTYALIAS)+") "+left( alltrim( upper( Facility->FCLTYNAME ) ) , 40 ) )
   devpos( prow()  , 091 )   ; devout( "³" )

   devpos ( prow()  , 110 )  ; devout( "³" )
   devpos ( prow()  , 116 )  ; devout( transform(  Oticket->CREDAMT,"999,999,999.99" ) )
   devpos ( prow()  , 132 )  ; devout( '³' )

   do case
      case msetcode == '1'
           devpos( prow()+1, 000 ) ; devout( "³       Purchase Amount       : "+ ltrim(trans( Oticket->PROCEEDS,"999,999,999.99")))  ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 000 ) ; devout( "³       Guaranty Deposit      : "+ trans( Oticket->GD,"99.999999%") )                   ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 000 ) ; devout( "³       Residual Value        : "+ trans( Oticket->RV,"99.999999%") )                   ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 000 ) ; devout( "³       Term                  : "+ ltrim(trans( Oticket->TERM,"999" )+ if(Oticket->TERMUNIT == '1', ' Days',' Months') ))
           devpos( prow()  , pcol()+2 ) ; devout( ltrim(disp_paytype( Oticket->PAYTYPE ))  );disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 000 ) ; devout( "³       Effective Rate        : "+ ltrim(trans( Oticket->TRUERATE,"99.99%") )) ; devPos( prow()  , pcol()+2+5 ) ; Devout( if( Oticket->RATETYPE $ '12', if( Oticket->RATETYPE == '1', 'Fixed   ', 'Floating' ), ' ')) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Monthly Rental        : "+ ltrim(trans( Oticket->AMORT,"999,999,999.99") ))    ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Monthly Rental Factor : "+ ltrim(trans( Oticket->FACTOR,"99.9999") ) )         ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Items for lease       : "+ ltrim( Oticket->UNIT ))                             ; disp_3_lines()
           if !empty( Oticket->UNIT2 )
               _can_be_ejected(mtotal)
               devpos( prow()+1, 00 )  ; devout( "³                               "+ ltrim( Oticket ->UNIT2) )              ; disp_3_lines()
           endif
      case msetcode == '2'
           devpos( prow()+1, 00 )  ; devout( "³       Net Proceeds          : "+ ltrim(trans( Oticket->PROCEEDS,"999,999,999.99") ) ); disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Term                  : "+ ltrim(trans( Oticket->TERM,"999" )) + if(Oticket->TERMUNIT == '1', ' Days',' Months') )
           devpos( prow()  , pcol()+2 ) ; devout( ltrim(disp_paytype( Oticket->PAYTYPE) )  )  ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Effective Rate        : "+ ltrim(trans( Oticket->TRUERATE,"99.99%") )) ; DevPos( prow()  , pcol()+2+5 ) ;Devout( if( Oticket->RATETYPE $ '12', if( Oticket->RATETYPE == '1', 'Fixed   ', 'Floating' ), ' ') ) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Monthly Amortization  : "+ ltrim(trans( Oticket->AMORT,"999,999,999.99") ))     ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Collaterals           : "+ ltrim( Oticket ->UNIT ))                              ; disp_3_lines()
           if !empty( Oticket->UNIT2 )
               _can_be_ejected(mtotal)
               devpos( prow()+1, 00 )  ; devout( "³                               "+ ltrim( Oticket->UNIT2 ) )                        ; disp_3_lines()
           endif
      case msetcode == '3'
           devpos( prow()+1, 00 )  ; devout( "³       Unit                  : "+ltrim( Oticket->UNIT  ))                              ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³                               "+ltrim( Oticket->UNIT2 ))                              ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Dealer                : "+ltrim(dispDLRNAME( Oticket->DLRCODE ) ))             ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Sales Representative  : "+ ltrim( Oticket ->SALESREP ))                          ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Purchase Amount       : "+ ltrim(trans( Oticket->PURCAMT,"999,999,999.99") ) )  ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Down Payment          : "+ ltrim(trans( Oticket->DOWNPAY,"999,999,999.99") ))   ; disp_3_lines() ; _can_be_ejected(mtotal)
//           devpos( prow()+1, 00 )  ; devout( "³       Dealer's Incentive    : "+ ltrim(trans( Oticket->INCENTIVE,"999,999,999.99")) ) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       D.I. / S.I.           : "+ ltrim(trans( Oticket->INCENTIVE,"999,999,999.99")) ) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Net Proceeds          : "+ ltrim(trans( Oticket->PROCEEDS,"999,999,999.99")) ) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Term                  : "+ ltrim(trans( Oticket->TERM,"999")+if( Oticket->TERMUNIT == '1',' Days',' Months') ))
           devpos( prow()  , pcol()+2 ) ; devout( ltrim(disp_paytype( Oticket->PAYTYPE ))  );disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Gross Rate            : "+ ltrim(trans( Oticket->TRUERATE,"99.99%") ) )         ; devPos( prow()  , pcol()+2+5 ) ;Devout( if( Oticket->RATETYPE $ '12', if( Oticket->RATETYPE == '1', 'Fixed   ', 'Floating' ), ' ') ) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Monthly Amortization  : "+ ltrim(trans( Oticket->AMORT,'999,999,999.99') ) )    ; disp_3_lines()
      case msetcode == '4'
           devpos( prow()+1, 00 )  ; devout( "³       Net Proceeds          : "+ ltrim(trans( Oticket->PROCEEDS,"999,999,999.99") )) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Term                  : "+ ltrim(trans( Oticket->TERM,"999" )+if( Oticket->TERMUNIT == '1', ' Days', ' Months' )     ))
           devpos( prow()  , pcol()+2 ) ; devout( ltrim(disp_paytype( Oticket->PAYTYPE ))  );disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Effective Rate        : "+ ltrim(trans( Oticket->TRUERATE,"99.99%") ))          ; devpos( prow() , pcol()+2+5 ) ; devout( if( Oticket->RATETYPE $ '12', if( Oticket->RATETYPE == '1', 'Fixed   ', 'Floating' ), ' ') ) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Monthly Amortization  : "+ ltrim(trans( Oticket->AMORT,"999,999,999.99") ) )    ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Notification          : "+ if( Oticket->NOTFCTN   $ '12' , if( Oticket ->NOTFCTN  == '1', 'With   ' , 'Without'     ),' ') ) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Collection            : "+ if( Oticket->COLEXION  $ '12' , if( Oticket ->COLEXION == '1', 'Ours  ' , 'Theirs'      ),' ') ) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Recourse              : "+ if( Oticket->RECOURSE $ '12'  , if( Oticket ->RECOURSE == '1', 'With   ' , 'Without'    ),' ') ) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Obligor               : "+ ltrim( Oticket->OBLIGOR ))                           ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Collateral            : "+ ltrim( Oticket->UNIT    ))                           ; disp_3_lines()
           if !empty( Oticket->UNIT2 )
               _can_be_ejected(mtotal)
               devpos( prow()+1, 00 )  ; devout( "³                               "+ ltrim( Oticket->UNIT2 ))  ; disp_3_lines()
           endif
      case msetcode == '5'
           devpos( prow()+1, 00 ) ; devout( "³       Term                  : "+ ltrim(trans( Oticket->TERM,"999" )+ if ( Oticket->TERMUNIT == '1',' Days',' Months' ) ))      ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 ) ; devout( "³       Effective Rate        : "+ 'Minimum spread of ' +ltrim(trans( Oticket->TRUERATE,"99.99%") )+ ' over the average cost of funds') ; disp_3_lines() ; _can_be_ejected(mtotal)  //DevPos( prow()  , pcol()+2+5 ) ;Devout( if( Oticket->RATETYPE $ '12', if( Oticket->RATETYPE == '1', 'Fixed   ', 'Floating' ), ' ') ) ;
           devpos( prow()+1, 00 ) ; devout( "³       Notification          : "+ if( Oticket->NOTFCTN   $ '12' , if( Oticket->NOTFCTN == '1', 'With   ' , 'Without'     ),' ') ) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 ) ; devout( "³       Collection            : "+ if( Oticket->COLEXION  $ '12' , if( Oticket->COLEXION == '1', 'Ours  ' , 'Theirs'      ),' ') ) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 ) ; devout( "³       Recourse              : "+ if( Oticket->RECOURSE $ '12'  , if( Oticket->RECOURSE == '1', 'With   ' , 'Without'    ),' ') ) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 ) ; devout( "³       Obligor               : "+ ltrim(Oticket->OBLIGOR )) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 ) ; devout( "³       Collateral            : "+ ltrim(Oticket->UNIT    )) ; disp_3_lines()
           if !empty( Oticket->UNIT2 )
               _can_be_ejected(mtotal)
               devpos( prow()+1, 00 )  ; devout( "³                               "+ ltrim( Oticket ->UNIT2  ) ) ; disp_3_lines()
           endif
   endcase
return nil
/*
***************************************
*  Desc ¯ prints PAYMENT TYPE
*
static function disp_paytype( mpaytype )
***************************************
return if ( mpaytype $ '12', if( mpaytype == '1',' In Advance',' In Arrears'),'' )
*/
****************************************************
*  Desc ¯ eject if the printer row reaches the limit
*
static function _can_be_ejected(mtotal)
****************************************************
   memvar meject, mpage,i
   if prow() >= ROWLIMIT
      @ prow() + 1, 00 say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
      @ prow() + 1, 00 say 'Next Page Please.'
      for i := prow() to ROWLIMIT ; @ i, 000 say '' ; next i
      @ prow() + 3, 002 say upper ( dispaoname( Caheader->AOCODE ) )
      devpos( prow()    , 098 ) ; devout( upper ( dispaoname(Parametr->COSIGN) ) )
      devpos( prow() + 1, 002 ) ; devout( upper( dispaopost(Caheader->AOCODE)) )
      devpos( prow()    , 098 ) ; devout( upper ("Assistant Vice President") )

      if !meject
         disp_committee(mtotal,.t.,55,Caheader->CATYPE) ; meject := .t.
      endif
      mpage++
      fejectpause()
      @ prow() + 1, 001 say 'CA Number     : '  +       Caheader->CANUMBER
      @ prow()    , 123 say 'Page : '+ trans( mpage, '999')
      @ prow() + 1, 001 say 'Client Name   : '+ dispclntname( Caheader->BRCODE+Caheader->CLNTCODE,40 )
      @ prow() + 1, 000 say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
   endif
return nil
************************************
*  Desc ¯ prints three vertical lines
*
static function disp_3_lines()
************************************
   devpos( prow(), 091 ) ; devout( "³" )
   devpos( prow(), 110 ) ; devout( "³" )
   devpos( prow(), 132 ) ; devout( '³' )
return nil
/*
*************************************************************
*  Desc ¯ returns the position of the current account officer
*
static function dispaopost(maocode)
*************************************************************
   Ao->(dbseek(maocode))
return alltrim(Ao->AOPOST)
*/
*
*                     End of the program ( amsm100g.prg )
*
