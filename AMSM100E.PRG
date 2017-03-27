/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³   Program ID.........:  amsm100e.prg                                 ³
 ³   Description........:  Unavailed CA Line of Group Members           ³
 ³   Author.............:  Ariel B. Bulan                               ³
 ³   Date...............:  09:31pm 29-Mar-1994                          ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³                         U P D A T E S                                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³        Who        ³     When      ³               Why                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³                   ³               ³                                  ³
 ³                   ³               ³                                  ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

#include "Colf.ch"
#include "Inkey.ch"
#include "Memoedit.ch"

#define ROWLIMIT  47
******************************************************
*  Desc    Unavailed CA Line for GROUPS
*  Param   Caheader->CANUMBER, TOTAL CREDIT AMOUNT
*  Retval  nil
*
function eval_groups ( mcanumber,mclntcode,mtotal,munavprinted  )
*****************************************************
   local mdbf := savedbf (mdbf), i,;
         mar1 := {}, mar2 := {}, mp_ar := {} ,;
         mgrupcode ,;
         mrecno := Caheader->( recno() )    ,;
         mntx   := Caheader->( indexord() ) ,;
         marpos

   if Grpmembr->(dbseek(mclntcode))
      mgrupcode := Grpmembr->GRUPCODE

      Grpmembr->( dbgotop() )
      Grpmembr->( dbeval( {|| if( Grpmembr->GRUPCODE == mgrupcode ,;
                                  aadd( mar1,{ Grpmembr->CLNTCODE ,;
                                               Grpmembr->GRUPCODE  ;
                                             };
                                      ),;
                                  nil );
                          },,;
                          {|| !Grpmembr->(eof()) ;
                          };
                        );
                )

      marpos := ascan( mar1,{ |x| x[1] == mclntcode })

      adel  ( mar1,marpos ) ; asize ( mar1,len(mar1)-1 )

      Caheader->( dbsetorder(3) )            // Client Code
      for i := 1 to len(mar1)
          if Caheader->(dbseek(mar1[i][1])) .and. Caheader->ACTAKEN == '3'
             trans_to_array(mar2)            // transfer to array
              if !empty( mar2 )               // if array is empty
                print_it ( mar2,mp_ar,mtotal,mar1[i][1],@munavprinted )
              endif
              mar2 := {} ; mp_ar := {}
          endif
      next i

      Caheader->( dbsetorder(mntx) )
      Caheader->( dbgoto(mrecno) )

   endif

   restdbf ( mdbf )
return nil

****************************************************************
*  Desc ¯ Determine if the current record is valid to be printed
*
static function valid_rec()
****************************************************************
   local mretval := .t.

   if Cadetail -> TRANTYPE == '1'       // Transaction is "Revolving" ?
      Facility -> ( dbseek ( Cadetail -> FCLTYCODE ) )
      if Facility -> SETCODE $ '_4_5'   // IPP .or. RP
         Acctmast-> ( dbsetorder(6) )
            if Acctmast->( dbseek( Caheader->CLNTCODE ) ) .and. Acctmast->fcltycode == Cadetail->fcltycode
                mretval = .f.
            else
                mretval = .t.
            endif
      endif
   endif
   
return mretval

********************************************************
*   Desc  Dump the current Cadetail record to array mar
*
static function trans_to_array( mar )
********************************************************
 if Cadetail->( dbseek ( Caheader->CANUMBER ) )
     Cadetail->( dbeval ( {|| if ( valid_rec(), ;
                              aadd( mar, { Cadetail->FCLTYCODE ,;
                                         eval({|| Facility->(dbseek(Cadetail->FCLTYCODE)),Facility->SETCODE }),;
                                         Cadetail->GD        ,;
                                         Cadetail->RV        ,;
                                         Cadetail->TERM      ,;
                                         Cadetail->UNIT      ,;
                                         Cadetail->UNIT2     ,;
                                         Cadetail->AMORT     ,;
                                         Cadetail->TRUERATE  ,;
                                         Cadetail->PRINCIPAL ,;
                                         Cadetail->INCLUDE   ,;
                                         Cadetail->(recno()) ,;
                                         Cadetail->PRINCIPAL ,;
                                         Cadetail->FACTOR    ,;
                                         Cadetail->NOTFCTN   ,;
                                         Cadetail->COLEXION  ,;
                                         Cadetail->RECOURSE  ,;
                                         Cadetail->OBLIGOR   ,;
                                         Cadetail->PRNAVAIL  ,;
                                         Caheader->LINETYPE  ,;
                                         Caheader->CANUMBER  ,;
                                         if( Caheader->LINETYPE == '1',; && OMNIBUS
                                             Caheader->CALINE - Caheader->AVAILED,;
                                             Cadetail->CREDAMT- Cadetail->AVAILED ;
                                           ) ;
                                       };
                               ),;
                            nil ) ;
                        },,;
                        {|| Cadetail->CANUMBER == Caheader->CANUMBER .and.;
                           !Cadetail->(eof()) ;
                        };
                      );
             )
endif
return nil
********************************************************************
*  Desc  displays unavailed CA LINE of Group Members
*  Para  Array to print, facility code, total credit amount
*
static function print_it ( mar,mp_ar,mtotal,mclntcode,munavprinted )
********************************************************************
  local i, mctr := 1, mlinetype, mfcltycode
  local   mpos := 0
  private momnibus := .f.

  asort( mar,,,{|x,y| x[20]+x[1] < y[20]+y[1] } )

  if !munavprinted
      munavprinted := .t.
      eval ({|| devpos( prow()+1, 000 ) , devout( '³' ) ,;
                disp_3_lines()                          ,;
                devpos( prow()+1, 000 ) , devout( '³' ) ,;
                devpos( prow()  , 001 ) , devout( 'UNAVAILED CREDIT LINE' ) ,;
                devpos( prow()  , 091 ) , devout( "³" ) ,;
                devpos( prow()  , 110 ) , devout( "³" ) ,;
                devpos( prow()  , 132 ) , devout( '³' )  ;
           })
  endif

  eval ({|| devpos( prow()+1, 000 ) , devout( '³' ) ,;
            devpos( prow()  , 001 ) , devout( dispclntname(mclntcode, 40) ), ;
            devpos( prow()  , 091 ) , devout( "³" ) ,;
            devpos( prow()  , 110 ) , devout( "³" ) ,;
            devpos( prow()  , 132 ) , devout( '³' )  ;
       })

  if mar [1] [20] == '1'  && OMNIBUS LINE
      momnibus := .t.
      eval ({|| devpos( prow()+1, 000 ) , devout( '³' ) ,;
                devpos( prow()  , 005 ) , devout( 'OMNIBUS LINE' ) ,;
                devpos( prow()  , 091 ) , devout( "³" ) ,;
                devpos( prow()  , 110 ) , devout( "³" ) ,;
                devpos( prow()  , 116 ) , devout( transform(mar[1][22],"999,999,999.99")) ,;
                devpos( prow()  , 132 ) , devout( '³' )  ;
           })
  endif

  while mctr<= len(mar)

        i := 0  ; mfcltycode := mar[mctr] [1] ; mpos := mctr
        while eval ( {|x| x:= if ( mctr <= len(mar),;
                                   if( mar [mctr] [20] == '1',;
                                       mar [mctr] [1] == mfcltycode,;
                                      .f.;
                                     ),;
                                   .f.;
                                  ),;
                              i++,;
                              mctr++,;
                              x ;
                     } ;
                   )
        enddo

        if i == 1

           disp_one ( mar[mctr-1][21]  ,;  && CANUMBER
                      mar[mctr-1][1]   ,;  && FACILITY CODE
                      mtotal           ,;  && TOTAL OUTSTANDING BALANCE
                      mar[mctr-1][12]  ,;  && Cadetail->(recno())
                      mar[mctr-1][22]  ,;  && Caheader->CALINE -Caheader->AVAILED ( OMNIBUS ) or Cadetail->CREDAMT - Cadetail->AVAILED ( REGULAR )
                      mar[mctr-1][20]   ;  && LINETYPE
                    )

             adel(mar,mpos) ; asize(mar,len(mar)-1) ; mctr--
        endif
  enddo

  move_ar ( mp_ar, mar, mtotal )

return nil

***************************************************************
*  Desc   Moves all elements from array "mar" to array "mp_ar"
*
static function move_ar ( mp_ar, mar, mtotal )
***************************************************************
    local mfcltycode, msetcode  ,;
          mt1 := 1  ,;
          mgd := {} , mrv  := {}, mterm:= {},munit  := {}   , mamort:= {}    ,;
          mtruerate := {}, mprincipal := {} ,mmaturity := {}, mar_recno :={} ,;
          mnetproceeds := {}, mrentfactor := {}                              ,;
          mnotfics     := {}, mcollects   := {}                              ,;
          mrecourses   := {}, mobligors   := {}                               ;

    while mt1 <= len ( mar )
       mfcltycode := mar [ mt1 ] [1]       // Facility Code
       msetcode   := mar [ mt1 ] [2]       // SetCode
       while mar [ mt1 ] [1] == mfcltycode
          aadd( mgd         , mar[ mt1 ] [3] )
          aadd( mrv         , mar[ mt1 ] [4] )
          aadd( mterm       , mar[ mt1 ] [5] )
          aadd( munit       , { mfcltycode, mar [ mt1 ] [6],mar [ mt1 ] [7] })
          aadd( mamort      , { mfcltycode, mar [ mt1 ] [8]  } )
          aadd( mtruerate   , { mfcltycode, mar [ mt1 ] [9]  } )
          aadd( mprincipal  , { mfcltycode, mar [ mt1 ] [10] - mar [ mt1] [19] })
          aadd( mar_recno   , mar [ mt1 ] [ 12 ] )
          aadd( mnetproceeds, mar [ mt1 ] [ 13 ] )
          aadd( mrentfactor , mar [ mt1 ] [ 14 ] )
          aadd( mnotfics    , mar [ mt1 ] [ 15 ] )
          aadd( mcollects   , mar [ mt1 ] [ 16 ] )
          aadd( mrecourses  , mar [ mt1 ] [ 17 ] )
          aadd( mobligors   , mar [ mt1 ] [ 18 ] )
          mt1 ++
          if mt1 > len ( mar )
             exit
          endif
       enddo

       each_setcode ( mp_ar, mfcltycode, msetcode,mgd,mrv,mterm,'Cadetail',mmaturity )

    enddo

    fprint  ( mp_ar, munit, mamort, mtruerate, mprincipal,mtotal,'Cadetail',mmaturity,mar_recno, mnetproceeds, mrentfactor,mnotfics,mcollects, mrecourses, mobligors,mar  )

return nil

*****************************************************************************************************************************************************************************
*  Description  printing routine for multiple Cadetail Records for
*                         the same CLIENT CODE
*
static function fprint ( mp_ar, munit, mamort, mtruerate, mprincipal,mtotal,mdbf,mmaturity,mar_recno,mnetproceeds,mrentfactor,mnotfics,mcollects, mrecourses, mobligors,mar )
*****************************************************************************************************************************************************************************
    memvar meject
    local  mctr := 1, mlimit := 0, mfcltycode, msetcode, mosbal, mrecno, mcredamt

    while mctr <= len ( mp_ar )
          mfcltycode := mp_ar [ mctr ] [1] ; msetcode := mp_ar [ mctr ] [2]
          while mp_ar [ mctr ] [1] == mfcltycode

             disp_fac ( mfcltycode,msetcode,mtotal )
             devpos ( prow(), 110 )  ; devout( "³" )

             if mar [1] [20] == '2'   // if LINETYPE == 'REGULAR'
                mcredamt := 0
                aeval( mprincipal,{ |x| mcredamt+= x[2]} ) // count all CREDIT AMOUNT
                devpos( prow(), 116 ); devoutpict( mcredamt, "999,999,999.99" )
             endif

             devpos ( prow(), 132 )  ; devout( '³' )
             disp_per_set ( mp_ar,mctr,munit,mamort,mtruerate,mprincipal,mdbf,mtotal,mnetproceeds,mrentfactor,mnotfics,mcollects, mrecourses, mobligors )

             mctr++
             if mctr>len(mp_ar)
                exit
             endif

          enddo

    enddo
return nil
*
*                    End of the program ( amsm100e.prg )
*
