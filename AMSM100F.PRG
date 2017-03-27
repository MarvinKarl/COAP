/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³   Program ID.........:  amsm100f.prg                                 ³
 ³   Description........:  Existing Liabilities of Group Members        ³
 ³   Author.............:  Ariel B. Bulan                               ³
 ³   Date...............:  12:52pm 29-Mar-1994                          ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³                         U P D A T E S                                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³        Who        ³     When      ³               Why                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³ Janet L. Bautista ³  10-Sep-1997  ³ gd, rv to 5 decimal places       ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

#include "Colf.ch"
#include "Inkey.ch"
#include "Memoedit.ch"

#define ROWLIMIT  47
***************************************************************************
*  Desc    Unavailed CA Line for GROUPS
*  Param   Caheader->CANUMBER, TOTAL CREDIT AMOUNT
*
function eval_ex_acctmast( mcanumber,mclntcode,moutstanding,mhprinted )
***************************************************************************
   local mdbf := savedbf (mdbf), i ,;
         mar1 := {}, mar2 := {}, mp_ar := {} ,;
         mgrupcode , mn := Caheader->(indexord()), mr := Caheader->(recno())
   if Grpmembr->(dbseek(mclntcode))
      mgrupcode := Grpmembr->GRUPCODE
      Grpmembr->(dbgotop())
      Grpmembr->(dbeval( {|| if( Grpmembr->GRUPCODE == mgrupcode,;
                                 aadd(mar1,{Grpmembr->CLNTCODE,Grpmembr->GRUPCODE}),;
                                 nil )},,;
                         {|| !Grpmembr->(eof()) }))

      eval({|x| x := ascan(mar1,{|x| x[1] == mclntcode} ) ,;
                adel(mar1,x)            ,;
                asize(mar1,len(mar1)-1)  ;
          })

      Acctmast->( dbsetorder(2) )            // CLIENT CODE + ACCT. NUMBER

      for i := 1 to len(mar1)
          if Acctmast->(dbseek(mar1[i][1])) // .and. Caheader->ACTAKEN == '3'
             mar2 := {}
             trans_to_array( mar2,moutstanding,mar1[i][1] )
             if len(mar2) > 0
                if !mhprinted
                    mhprinted:= .t.
                    prnhd()
                endif
                print_it ( mar2,mp_ar,@moutstanding,mar1[i][1] )
             endif
          endif
      next i

   endif

   restdbf ( mdbf )
   Caheader->( dbsetorder(mn) )
   Caheader->( dbgoto(mr) )
return nil
************************************************************
*  Desc ¯ prints printing head
*
static function prnhd()
************************************************************
eval ({|| devpos ( prow() + 1, 00 ) , devout ( '³                                                                                          ³                  ³                     ³' ),;
          devpos ( prow() + 1, 000) , devout ( '³' ) ,;
          setfont( 'UNDERLINE' )   ,;
          devpos ( prow(), pcol()) ,;
          devout ( upper( 'Existing Liabilities ')+': ' ) ,;
          setfont( 'OFFUNDERLINE') ,;
          devpos ( prow(), 091+6 ), devout ( "³" ),;
          devpos ( prow(), 110+6 ), devout ( "³" ),;
          devpos ( prow(), 132+6 ), devout ( "³" ) ;
     })
return nil
************************************************************
*   Desc ¯ Dump the current Acctmast record to array mar
*
static function trans_to_array( mar,moutstanding,mclntcode )
************************************************************
    Acctmast->( dbseek ( mclntcode ) )
    Acctmast->( dbeval ( { || aadd ( mar, { Acctmast->FCLTYCODE  ,;
                                            eval({|| Facility->(dbseek(Acctmast->FCLTYCODE)),Facility->SETCODE }),;
                                            Acctmast->GD         ,;
                                            Acctmast->RV         ,;
                                            Acctmast->TERM       ,;
                                            Acctmast->ORIXUNIT   ,;
                                            Acctmast->AMORT      ,;
                                            Acctmast->TRUERATE   ,;
                                            Acctmast->PRINCIPAL  ,;
                                            Acctmast->MATDATE    ,;
                                            mclntcode             ;
                                          };
                                   ) ,;
                              moutstanding += Acctmast->OSBAL }    ,,;
                { || Acctmast->CLNTCODE == mclntcode .and. !Acctmast->(eof())});
              )
    asort ( mar,,,{|x,y| x[1]<y[1] } )  // sort by Facility Code
return nil
************************************************************
*  Desc  displays unavailed CA LINE of Group Members
*  Para  Array to print, facility code, total credit amount
*  Ret   Nil
*
static function print_it ( mar,mp_ar,moutstanding,mclntcode )
*************************************************************
  local i, mctr := 1, mfcltycode,;
        mpos := 0
  private momnibus := .f.

  asort  ( mar,,,{|x,y| x[1] < y[1] } )
  devpos ( prow() + 1, 00 ) ; devout( '³                                                                                          ³                  ³                     ³' )
  devpos ( prow() + 1, 00 ) ; devout( '³'+ dispclntname(mclntcode, 40 ) )
  disp_3_lines() ; _can_be_ejected ( moutstanding )

  while mctr<= len(mar)

        i := 0  ; mfcltycode := mar[mctr] [1] ; mpos := mctr
        while eval ( {|x| x:= if ( mctr <= len(mar) ,;
                                   mar [mctr] [1] == mfcltycode,;
                                   .f. ) ,;
                              if( x,i++   ,nil ) ,;
                              if( x,mctr++,nil ) ,;
                              x ;
                     } ;
                   )
        enddo

        if i == 1
           disp_1 ( mar[mctr-1] [11]    ,;  && CLIENT NO.
                      mar[mctr-1] [1]   ,;  && FACILITY CODE
                      @moutstanding      ;  && TOTAL CREDIT AMOUNT
                   )
             adel(mar,mpos) ; asize(mar,len(mar)-1) ; mctr--
        endif

  enddo

  if len( mar ) > 0
     move_ar ( mp_ar, mar, moutstanding )
  endif

return nil
*************************************************************
*  Desc  Groups records w/ the same FACILITY CODE
*  Para  Group Code, Each Elements Code, Outstanding Balance
*  Ret   Nil
*
static function move_ar ( mp_ar, mar, moutstanding )
****************************************************
    local mgd := {} , mrv  := {}, mterm:= {},munit  := {}   , mamort:= {}    ,;
          mtruerate := {}, mprincipal := {} ,mmaturity := {}, mar_recno :={} ,;
          mt1 := 1 , mfcltycode, msetcode   ,mclntcode

    while mt1 <= len ( mar )
       mfcltycode := mar [ mt1 ] [1]       // Facility Code
       msetcode   := mar [ mt1 ] [2]       // SetCode
       mclntcode  := mar [ mt1 ] [11]      // Client Code
       while mar [ mt1 ] [1] == mfcltycode
          aadd( mgd       , mar[ mt1 ] [3] )
          aadd( mrv       , mar[ mt1 ] [4] )
          aadd( mterm     , mar[ mt1 ] [5] )
          aadd( munit     , { mfcltycode, mar [ mt1 ] [6] } )
          aadd( mamort    , { mfcltycode, mar [ mt1 ] [7] } )
          aadd( mtruerate , { mfcltycode, mar [ mt1 ] [8] } )
          aadd( mprincipal, { mfcltycode, mar [ mt1 ] [9] } )
          aadd( mmaturity , mar [ mt1 ] [10] )  // Replacement for OSBAL 2895 ( MATURITY DATE )
          mt1 ++
          if mt1 > len ( mar )
             exit
          endif
       enddo
       asort ( mgd   ,,,{|x,y|x<y } )
       asort ( mrv   ,,,{|x,y|x<y } )
       asort ( mterm ,,,{|x,y|x<y } )
       asort ( mmaturity,,,{|x,y| dtos(x)<dtos(y)} )
       each_setcode ( mp_ar, mfcltycode, msetcode,mgd,mrv,mterm,mmaturity,mclntcode )
    enddo
    fprint ( mp_ar, munit, mamort, mtruerate, mprincipal,moutstanding,mmaturity,mar_recno,mar )
return nil
************************************************************
*  Desc  Printing routine for multiple Acctmast Records for
*         the same CLIENT CODE
*
static function fprint ( mp_ar, munit, mamort, mtruerate, mprincipal,moutstanding,mmaturity,mar_recno,mar )
***********************************************************************************************************
    memvar meject
    local  mcaline := 0
    local  mctr := 1, mlimit := 0, mfcltycode, msetcode, mosbal, mrecno

    while mctr <= len ( mp_ar )

          mfcltycode := mp_ar [ mctr ] [1]
          msetcode   := mp_ar [ mctr ] [2]
          mclntcode  := mp_ar [ mctr ] [ len(mp_ar[mctr]) ]

          while mp_ar [ mctr ] [1] == mfcltycode

             disp_fac ( mfcltycode , msetcode, moutstanding )

             mosbal := 0
             @ prow(), 94 say disp_ostot( mfcltycode,@mosbal,mclntcode )

             devpos( prow(), 110 ) ; devout( "³" )

             if getsetcd ( mfcltycode ) $ '_4_5'
                  if present_in_caheader( @mcaline,mclntcode )
                     @ prow(), 116 say mcaline pict '999,999,999.99'
                  endif
             endif

             devpos( prow(), 132 ) ; devout( '³' )

             disp_per_set ( mp_ar,mctr,munit,mamort,mtruerate,mprincipal,'Acctmast',moutstanding )

             mctr++
             if mctr > len ( mp_ar )
                exit
             endif

          enddo

    enddo

return nil
*************************************************************
*
static function present_in_caheader( mcaline,mclntcode )
*************************************************************
   local mcarec := Caheader -> ( recno() ), mcantx := Caheader -> (indexord())
   local mretval := .f.

   Caheader -> ( dbsetorder ( 3 ) )    // CLIENT CODE
   if Caheader -> ( dbseek ( mclntcode ) )
      if Caheader -> ACTAKEN == '3'   // Approved ?
      if Cadetail -> ( dbseek ( Caheader -> CANUMBER ) )
         Cadetail -> ( dbeval ( { ||  if ( Cadetail -> INCLUDE .and. ;
                                           getsetcd ( Cadetail -> FCLTYCODE ) $ '_4_5' ,;
                                           eval ( {|| mretval := .t. ,;
                                                      mcaline += Cadetail -> PRINCIPAL ;
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

   Caheader -> ( dbsetorder ( mcantx ) )
   Caheader -> ( dbgoto( mcarec ) )
return mretval
/*
***********************************************
*
static function getsetcd ( mfcltycode )
***********************************************
   Facility->(dbseek(mfcltycode))
return Facility->SETCODE
*/
*********************************************************
*  Description  returns accumulated OUTSTANDING TOTAL
*
static function disp_ostot( mfcltycode,mosbal,mclntcode )
*********************************************************
    eval({|x| x:= Acctmast->(recno())       ,;
              Acctmast->(dbseek(mclntcode)) ,;
              Acctmast->(dbeval({|| if( Acctmast->FCLTYCODE==mfcltycode ,mosbal += Acctmast->OSBAL,nil) } ,,;
                                {|| Acctmast->CLNTCODE==mclntcode .and. !Acctmast->(eof()) } )) ,;
              Acctmast->( dbgoto(x) )        ;
     })
return transform(mosbal,'999,999,999.99')
**********************************************************************************************
*  Description  Add values to ARRAY mp_ar for each setcode
*
static function each_setcode ( mp_ar, mfcltycode, msetcode,mgd,mrv,mterm,mmaturity,mclntcode )
**********************************************************************************************
    local mgd2,mrv2,mterm2

    do case
       case msetcode == '1'
            aadd ( mp_ar,{ mfcltycode ,;
                           msetcode   ,;
                           eval  ({|| 'Guaranty Deposit      : '+ ltrim(transform( mgd[1],'99.999999%' )) + if( len(mgd)>1 .and. atail(mgd) != mgd[1], ' - ' + transform ( atail(mgd),'99.999999%'),' ')  }) ,;
                           eval  ({|| 'Residual Value        : '+ ltrim(transform( mrv[1],'99.999999%' )) + if( len(mrv)>1 .and. atail(mrv) != mrv[1], ' - ' + transform ( atail(mrv),'99.999999%'),' ')  }) ,;
                           eval  ({|| 'Effective Rate        : ' })  ,;
                           eval  ({|| 'Total Monthly Rental  : ' })  ,;
                           eval  ({|| 'Maturity Date         : '+ ltrim(dtoc( mmaturity[1] ) )+ ' - ' + ltrim( dtoc( atail(mmaturity) ) ) }),;
                           'Items for Lease       : '                ,;
                           mclntcode                                  ;
                         };
                 )
       case msetcode == '2' .or. msetcode == '3'
               aadd ( mp_ar,{ mfcltycode ,;
                              msetcode   ,;
                              eval  ({|| 'Term                  : '+ ltrim(transform( mterm[1],'999' ))  + ' Months ' +if( len(mterm)>1 .and. atail(mterm) != mterm[1], ' - ' + transform ( atail(mterm),'999')+' Months',' ')  }),;
                              eval  ({|| 'Effective Rate        : ' })     ,;
                              eval  ({|| 'Total Amortization    : '}) ,;
                              eval  ({|| 'Maturity Date         : '+ ltrim(dtoc( mmaturity[1] ) ) + ' - ' + ltrim( dtoc(atail(mmaturity)) ) }) ,;
                              eval  ({|| 'Collateral            : ' })     ,;
                              mclntcode                                     ;
                            };
                    )
       otherwise
               aadd ( mp_ar,{ mfcltycode,;
                              msetcode  ,;
                              eval ({|| 'Term                  : '+ ltrim(transform( mterm[1],'999' ))  + ' Months ' +if( len(mterm)>1 .and. atail(mterm) != mterm[1], ' - ' + transform ( atail(mterm),'999')+' Months',' ')  }),;
                              eval ({|| 'Effective Rate        : '})   ,;
                              eval ({|| 'Collateral            : ' })  ,;
                              mclntcode                                };
                    )
    endcase
return nil

**********************************
*
static function get_term ( mterm )
**********************************
   local mretval := ''
return eval ( {|| aeval ( mterm,{|x| mretval += ' ; ' + ltrim(trans(x,'999')) }),;
                  mretval := substr( mretval,4,len(mretval)-3 ) + ' Months' ;
              };
            )

******************************
*
static function get_rv ( mrv )
******************************
   local mretval := ''
return eval ( {|| aeval ( mrv,{|x| mretval += ' ; ' + ltrim(trans(x,'99.999999 %')) }),;
                  mretval := substr( mretval,4,len(mretval)-3) ;
              };
            )

***************************************************************
*  Desc  Prints SINGLE FACILITIES
*  Para  CANUMBER,FACILITY CODE, TOTAL, CREDIT AMT., LINETYPE
*  Ret   nil
*
static function disp_1 ( mclntcode,mfcltycode,moutstanding )
***************************************************************
   if Acctmast->(dbseek(mclntcode))
      dispdetcontents( mfcltycode,@moutstanding)
   endif
return nil

****************************************************************
*  Desc ¯ displays the contents of Cadetail .or. Acctmast
*
static function dispdetcontents( mfcltycode,moutstanding)
****************************************************************
   local mSETCODE := eval ({ || Facility->( dbseek ( mFCLTYCODE ) ) ,;
                                Facility-> SETCODE                   ;
                          })
  ask_setcode( Facility->SETCODE,@moutstanding)
return nil

****************************************************
*  Desc ¯
*
static function ask_setcode( msetcode,mtotal )
****************************************************
   memvar meject
   local mlimit := 0, i, mcaline := 0

   devpos( prow()+1, 000 ) ; devout( '³'+left(( alias() )->FCLTYCODE,3)+'-'+right(( alias() )->FCLTYCODE,2)+" ("+alltrim(Facility->FCLTYALIAS)+") "+left( alltrim( upper( Facility->FCLTYNAME ) ) , 40 ) )
   devpos( prow()  , 091 ) ; devout( "³" )
   devpos ( prow()  , 094 ) ; devout( transform( ( alias() )->OSBAL  ,"999,999,999.99" ) )
   devpos ( prow()  , 110 ) ; devout( "³" )

   if Acctmast -> FCLTYCODE $ '_4_5'
      if present_in_caheader( @mcaline )
         @ prow(), 116 say mcaline pict '999,999,999.99'
      endif
   endif

   devpos ( prow()  , 132 )     ; devout( '³' )

   do case
      case msetcode == '1'
           devpos( prow()+1, 000 ) ; devout( "³       Guaranty Deposit      : "+ ltrim(trans(( alias() )->GD, "99.999999%") ))           ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 000 ) ; devout( "³       Residual Value        : "+ ltrim(trans(( alias() )->RV,"99.999999%")) )            ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 000 ) ; devout( "³       Term                  : "+ ltrim(trans(( alias() )->TERM,"999" )+' Months' ))
           devpos( prow()  , pcol()+2 ) ; devout( ltrim(disp_paytype( (alias())->PAYTYPE ))  );disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 000 ) ; devout( "³       Effective Rate        : "+ ltrim(trans(( alias() )->TRUERATE,"99.99%") )) ; devPos( prow()  , pcol()+2+5 ) ; Devout( if( ( alias() )->RATETYPE $ '12', if( ( alias() )->RATETYPE == '1', 'Fixed   ', 'Floating' ), ' ')) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Monthly Rental        : "+ ltrim(trans(( alias() )->AMORT,"999,999,999.99") ))    ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Monthly Rental Factor : "+ ltrim(trans(( alias() )->FACTOR,"99.9999") ) )         ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Items for lease       : "+ ltrim(( alias() )->UNIT ))                             ; disp_3_lines()
           if !empty( (alias())->UNIT2 )
               _can_be_ejected(mtotal)
               devpos( prow()+1, 00 )  ; devout( "³                               "+ ltrim(( alias() )->UNIT2) )                        ; disp_3_lines()
           endif
      case msetcode == '2'
           //devpos( prow()+1, 00 )  ; devout( "³       Net Proceeds          : "+ ltrim(trans(( alias() )->PRINCIPAL,"999,999,999.99") ) ); sub_limit() ;  disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Term                  : "+ ltrim(trans(( alias() )->TERM,"999" )+' Months' ))
           devpos( prow()  , pcol()+2 ) ; devout( ltrim(disp_paytype( (alias())->PAYTYPE) )  );disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Effective Rate        : "+ ltrim(trans(( alias() )->TRUERATE,"99.99%") )) ; DevPos( prow()  , pcol()+2+5 ) ;Devout( if( ( alias() )->RATETYPE $ '12', if( ( alias() )->RATETYPE == '1', 'Fixed   ', 'Floating' ), ' ') ) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Monthly Amortization  : "+ ltrim(trans(( alias() )->AMORT,"999,999,999.99") ))     ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Collaterals           : "+ ltrim(( alias() )->UNIT ))                              ; disp_3_lines()
           if !empty( (alias())->UNIT2 )
               _can_be_ejected(mtotal)
               devpos( prow()+1, 00 )  ; devout( "³                               "+ ltrim(( alias() )->UNIT2 ) )  ; disp_3_lines()
           endif
      case msetcode == '3'
           devpos( prow()+1, 00 )  ; devout( "³       Unit                  : "+ltrim(( alias() )->UNIT  ))     ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³                               "+ltrim(( alias() )->UNIT2 ))     ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Dealer                : "+ltrim(dispDLRNAME( ( alias() )->DLRCODE ) )) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Sales Representative  : "+ ltrim(( alias() )->SALESREP )) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Purchase Amount       : "+ ltrim(trans(( alias() )->PURCAMT,"999,999,999.99") ) )  ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Down Payment          : "+ ltrim(trans(( alias() )->DOWNPAY,"999,999,999.99") ))   ; disp_3_lines() ; _can_be_ejected(mtotal)
//           devpos( prow()+1, 00 )  ; devout( "³       Dealer's Incentive    : "+ ltrim(trans(( alias() )->INCENTIVE,"999,999,999.99")) ) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       D.I. / S.I.           : "+ ltrim(trans(( alias() )->INCENTIVE,"999,999,999.99")) ) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Net Proceeds          : "+ ltrim(trans(( alias() )->PRINCIPAL,"999,999,999.99")) ) ; sub_limit() ;  disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Term                  : "+ ltrim(trans(( alias() )->TERM,"999"+' Months') ))
           devpos( prow()  , pcol()+2 ) ; devout( ltrim(disp_paytype( (alias())->PAYTYPE ))  );disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Gross Rate            : "+ ltrim(trans(( alias() )->TRUERATE,"99.99%") ) )         ; devPos( prow()  , pcol()+2+5 ) ;Devout( if( ( alias() )->RATETYPE $ '12', if( ( alias() )->RATETYPE == '1', 'Fixed   ', 'Floating' ), ' ') ) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Monthly Amortization  : "+ ltrim(trans(( alias() )->AMORT,'999,999,999.99') ) )    ; disp_3_lines()
      case msetcode == '4'
           devpos( prow()+1, 00 )  ; devout( "³       Net Proceeds          : "+ ltrim(trans(( alias() )->PRINCIPAL,"999,999,999.99") )) ; sub_limit() ;  disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Term                  : "+ ltrim(trans(( alias() )->TERM,"999" )+' Months' ))
           devpos( prow()  , pcol()+2 ) ; devout( ltrim(disp_paytype( (alias())->PAYTYPE ))  );disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Effective Rate        : "+ ltrim(trans(( alias() )->TRUERATE,"99.99%") ))          ; DevPos( prow()  , pcol()+2+5 ) ;Devout( if( ( alias() )->RATETYPE $ '12', if( ( alias() )->RATETYPE == '1', 'Fixed   ', 'Floating' ), ' ') ) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Monthly Amortization  : "+ ltrim(trans(( alias() )->AMORT,"999,999,999.99") ) )    ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Notification          : "+ if( ( alias() )->NOTFCTN   $ '12' , if( ( alias() )->NOTFCTN == '1', 'With   ' , 'Without'     ),' ') ) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Collection            : "+ if( ( alias() )->COLEXION  $ '12' , if( ( alias() )->COLEXION == '1', 'Ours  ' , 'Theirs'      ),' ') ) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Recourse              : "+ if( ( alias() )->RECOURSE $ '12'  , if( ( alias() )->RECOURSE == '1', 'With   ' , 'Without'    ),' ') ) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Obligor               : "+ ltrim(( alias() )->OBLIGOR ))  ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Collateral            : "+ ltrim(( alias() )->UNIT    ))  ; disp_3_lines()
           if !empty( (alias())->UNIT2 )
               _can_be_ejected(mtotal)
               devpos( prow()+1, 00 )  ; devout( "³                               "+ ltrim(( alias() )->UNIT2 ))  ; disp_3_lines()
           endif
      case msetcode == '5'
           //devpos( prow()+1, 00 )  ; devout( "³       Net Proceeds          : "+ ltrim(trans(( alias() )->PRINCIPAL,"999,999,999.99")) ) ; sub_limit() ;  disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Maximum Term          : "+ ltrim(trans(( alias() )->TERM,"999" )+' Months' ))      ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Interest Rate         : "+ ltrim(trans( ( alias() )->TRUERATE,"99.9999%" ) ))      ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Monthly Amortization  : "+ ltrim(trans(( alias() )->AMORT,"999,999,999.99") ))     ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Notification          : "+ if( ( alias() )->NOTFCTN   $ '12' , if( ( alias() )->NOTFCTN == '1', 'With   ' , 'Without'     ),' ') ) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Collection            : "+ if( ( alias() )->COLEXION  $ '12' , if( ( alias() )->COLEXION == '1', 'Ours  ' , 'Theirs'      ),' ') ) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Recourse              : "+ if( ( alias() )->RECOURSE $ '12'  , if( ( alias() )->RECOURSE == '1', 'With   ' , 'Without'    ),' ') ) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Obligor               : "+ ltrim(( alias() )->OBLIGOR )) ; disp_3_lines() ; _can_be_ejected(mtotal)
           devpos( prow()+1, 00 )  ; devout( "³       Collateral            : "+ ltrim(( alias() )->UNIT    )) ; disp_3_lines()
           if !empty( (alias())->UNIT2 )
               _can_be_ejected(mtotal)
               devpos( prow()+1, 00 )  ; devout( "³                               "+ ltrim(( alias() )->UNIT2  ) ) ; disp_3_lines()
           endif
   endcase
return nil
******************************
* Desc ¯ prints vertical lines
*
static function disp_3_lines()
******************************
   devpos( prow() , 091 ) ; devout( "³" )
   devpos( prow() , 110 ) ; devout( "³" )
   devpos( prow() , 132 ) ; devout( '³' )
return nil
***************************************
*
static function _can_be_ejected(mtotal)
***************************************
   memvar meject, mpage,i

   if prow() >= ROWLIMIT

      meject := .f.

      @ prow() + 1, 00 say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
      @ prow() + 1, 00 say 'Next Page Please.'
      for i := prow() to ROWLIMIT ; @ i, 000 say '' ; next i
      @ prow() + 3, 002 say upper ( dispaoname( Caheader->AOCODE ) )
      @ prow()    , 098 say upper ( 'Bernadette P. Astudillo'    )
      @ prow() + 1, 000 say '    Account Officer                                                                               Assistant Vice President'

      if !meject
         disp_committee( mtotal,.t.,55,Caheader->CATYPE ) ; meject := .t.
      endif

      mpage++
      fejectpause()
      @ prow() + 1, 001 say 'CA Number     : ' + Caheader->CANUMBER
      @ prow()    , 123 say 'Page : '+ trans( mpage, '999')
      @ prow() + 1, 001 say 'Client Name   : '+ dispclntname( Caheader->BRCODE+Caheader->CLNTCODE, 40 )
      @ prow() + 1, 000 say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
   endif
return nil
/*
***************************************
*
static function disp_paytype( mpaytype )
***************************************
return if ( mpaytype $ '12', if( mpaytype == '1',' In Advance',' In Arrears'),'' )
***************************
*
static function sub_limit()
***************************
memvar momnibus
return eval ({|| devpos ( prow(), pcol() ),;
                 devout ( if ( momnibus , '     (SUB-LIMIT)','') );
            })
*/
*
*                   End of the program ( amsm100f.prg )
*
