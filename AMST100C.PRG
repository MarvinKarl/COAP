/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³   program id.........:  amst100c.prg                                 ³
 ³   description........:  availments data entry ( facilities )         ³
 ³   author.............:  Ariel B. Bulan                               ³
 ³   date...............:  11:41pm 10-Nov-1994                          ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³                         U P D A T E S                                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³        Who        ³     When      ³               Why                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³ Janet L. Bautista ³  10-Sep-1997  ³ gd & rv to 5 decimal places      ³
 ³ Janet B. Salvador ³  15-Feb-1999  ³ error on matdate computation     À¿
 ³ abb               ³  12-Apr-2000  ³ chkfirstdue( mfirstdue, mvaldate )³
 ³                   ³               ³   firstduedate < valdate          ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 */

#include "Colf.ch"
#include "Inkey.ch"

********************************************************************************************
function check_facility ( mwhat    , mfcltycode, munit     , mdlrcode  , mponum   ,;
                          mpurcamt , munitloca , mprincipal, mpaytype  , mgd, mrv ,;
                          mterm    , mtermunit , mtruerate , mratetype , mfirstdue,;
                          mpayfreq , mfactor   , mamort    , mcredamt  , malir    ,;
                          mmatdate , msalesrep , mdownpay  , mincentive, mvaldate ,;
                          misf5    , mdocref   , mrefno    , maddon    , mudi     ,;
                          mnotfctn , mcolexion , mrecourse , mobligor  , mcolatrl ,;
                          mtrantype, mnerate   , munit2    , mwtax     , mudiamt  )
********************************************************************************************

local mretval := .f., mcont := .t., mfclty2 := mfcltycode, mdbf2use := 'Acctwait'
local mreturn := .t.

   if upper( alias() ) != upper( 'Acctdaly' )
      mdbf2use := if ( mdocref=='1' , 'Cadetail' , 'Oticket' )
   endif
   mvaldate:=if(mvaldate == nil,Acctdaly->Valdate,mvaldate)
   altd()

   if !misf5 .and. mwhat == 'A'
      assign_all_facilities( mdbf2use  , @mfcltycode, @munit     , @mdlrcode  , @mponum   ,;
                             @mpurcamt , @munitloca , @mprincipal, @mpaytype  , @mgd, @mrv,;
                             @mterm    , @mtermunit , @mtruerate , @mratetype , @mfirstdue,;
                             @mpayfreq , @mfactor   , @mamort    , @mcredamt  , @malir    ,;
                             @mmatdate , @msalesrep , @mdownpay  , @mincentive, @mvaldate ,;
                             @mdocref  , @mrefno    , @maddon    , @mudi      , @mnotfctn ,;
                             @mcolexion, @mrecourse , @mobligor  , @mcolatrl  , @mtrantype,;
                             @mnerate  , @munit2    , @mwtax     , @mudiamt)
   endif
   @ 10, 21 say tran( mfcltycode, '@R 999-99' ) + ' ' + dispfcltyname( mfcltycode ) color 'gr+/b'
   if lastkey() != K_ESC
      do case
         case Facility -> SETCODE == '1'
            if empty(mtermunit)
               mtermunit := '2'
            endif

            set_code_1( @mwhat    , @mfcltycode, @munit    , @mdlrcode , @mponum, @mpurcamt ,;
                        @munitloca, @mprincipal, @mpaytype , @mgd, @mrv, @mterm , @mtermunit,;
                        @mtruerate, @mratetype , @mfirstdue, @mfactor  , @mamort, @mcredamt ,;
                        @malir    , @mpayfreq  , @mmatdate , mvaldate  , mrefno , mdbf2use  ,;
                        misf5     , @mreturn   , @munit2 )


         case Facility -> SETCODE == '2'
            ******mtermunit := '2'          // removed by ariel(05/11/2000) for account no. 7601 solidcard
                                            
            set_code_2( @mwhat    , @mfcltycode, @munit    , @mprincipal, @mpaytype, @mterm     ,;
                        @mtermunit, @mtruerate , @mratetype, @mfirstdue , @mpayfreq, @maddon    ,;
                        @mamort   , @mcredamt  , @mudi     , @mmatdate  , mvaldate , mrefno     ,;
                        mdbf2use  , misf5      , @mreturn  , @munit2    , @mwtax   , @mincentive,;
						@mnerate  , @mudiamt )


         case Facility -> SETCODE == '3'
            *****mtermunit := '2'

            set_code_3( @mwhat     , @mfcltycode, @munit  , @mdlrcode , @msalesrep, @mpurcamt , @mdownpay , @mincentive,;
                        @mprincipal, @mpaytype  , @mterm  , @mtermunit, @mtruerate, @mratetype, @mfirstdue, @mpayfreq  ,;
                        @mamort    , @mcredamt  , @mudi   , @mmatdate , mvaldate  , mrefno    , mdbf2use  , misf5      ,;
						@mnerate   , @mreturn   , @munit2 , @mwtax    , @mudiamt)


         case Facility -> SETCODE == '4' .or. Facility -> SETCODE == '5'

            set_code_4( @mwhat     , @mfcltycode, @munit  , @mdlrcode , @msalesrep, @mpurcamt , @mdownpay , @mincentive,;
                        @mprincipal, @mpaytype  , @mterm  , @mtermunit, @mtruerate, @mratetype, @mfirstdue, @mpayfreq  ,;
                        @mamort    , @mcredamt  , @mudi   , @mnotfctn , @mcolexion, @mrecourse, @mobligor , @mcolatrl  ,;
                        mtrantype  , @mmatdate  , mvaldate, mrefno    , mdbf2use  , misf5, @mreturn,@munit2 )


      endcase

   endif
   setcursor(3)
return mreturn
******************************************************************************************
static function set_code_1( mwhat    , mfcltycode, munit    , mdlrcode, mponum, mpurcamt ,;
                            munitloca, mprincipal, mpaytype , mgd, mrv, mterm , mtermunit,;
                            mtruerate, mratetype , mfirstdue, mfactor , mamort, mcredamt ,;
                            malir    , mpayfreq  , mmatdate , mvaldate, mrefno, mdbf2use , misf5, mreturn,munit2 )
******************************************************************************************
local motnumber := Oticket->OTNUMBER, mrecno := recno(), misreturned := .f.
local mscr := savescreen( ,,, ), getlist := {}, mcolor := setcolor()
local mpayfreqchoices := { '1 = MONTHLY    ','2 = BI-MONTHLY ','3 = QUARTERLY  ',;
                           '4 = SEMI-ANNUAL','5 = ANNUAL     ','6 = LUMPSUM    ','7 = IRREGULAR  ' }
local noldterm,noldgd,noldrv
fshadow( 4, 30, 21+1, 75, 2, 'w+/gr')
setcolor( 'bg+/gr, w+/n,,, gr+/gr' )

//aga.13.11.2007.remove !misf5 .or. 
mfirstdue := if( mwhat == 'A', firstdte( mvaldate,mtermunit,mpaytype), mfirstdue ) 
mmatdate  := if( mwhat == 'A', matrdte( mvaldate,mpaytype,mtermunit,mterm ), mmatdate)                   

@  4  , 31 say propercase( rtrim( Facility->fcltyname ) ) color 'bg+/gr'
@  6+1, 60 say upper( left( disp_dealer( mdlrcode ), 15 ) ) color 'gr+/gr'

if mtermunit == '1'
   @ 12+1, 59 say 'Days    ' color 'gr+/gr'
else
   @ 12+1, 59 say 'MONTH(s)' color 'gr+/gr'
endif

@ 13+1, 63 say if( mratetype $ '12', if( mratetype == '1', 'FIXED', 'FLOATING' ), '' )         color 'gr+/gr'
@ 15+1, 57 say if( !empty( mpayfreq ), subs( mpayfreqchoices[ val( mpayfreq ) ], 5, 11 ), '' ) color 'gr+/gr'

do while .t.   
   @  5, 31 say '      Items for Lease ' get munit      pict '@XS20'          when .f.
   @  6, 31 say '                      ' get munit2     pict '@XS20'          when .f.

   @  6+1, 31 say '               Dealer ' get mdlrcode   pict '@X'             when .f.
   @  7+1, 31 say '                PO N§ ' get mponum     pict '99999999'       when .f.
   @  8+1, 31 say '        Unit Location ' get munitloca  pict '@XS20'          when .f.
   @  9+1, 31 say '      Purchase Amount ' get mprincipal pict '999,999,999.99' when .f.
   @ 10+1, 31 say '     Guaranty Deposit ' ;
              get mgd           ;
              pict '99.999999%' ;
              when .f.
   @ 11+1, 31 say '       Residual Value ' ;
              get mrv                       ;
              pict '99.999999%'      ;
              when .f.

   @ 12+1, 31 say '                 Term ' get mterm      pict '999'  ;
                valid mterm > 0  .and. eval({||mmatdate :=matrdte( mvaldate,mpaytype,mtermunit,mterm ),.t. })
                //aga.13.11.2007.removed firstdue recompute on term edit
                //.and. eval( { || mfirstdue:=firstdte(mvaldate,mtermunit,mpaytype),.t.} ) ;

   @ 13+1, 31 say '       Effective Rate ' get mtruerate  pict '99.9999'        when .f.
   @ 14+1, 31 say '       First Due Date ' get mfirstdue  pict '@D'   ;
              when .t. ;  //eval( { || mfirstdue:=firstdte(mvaldate,mtermunit,mpaytype),.t.} ) ; //aga.13.11.2007.removed firstdue recompute
              valid chkfirstdue ( mfirstdue, mvaldate )

   @ 15+1, 31 say '    Payment Frequency ' get mpayfreq   pict 'X'              when .f.

//aga.16.10.2007.matdate editing disabled if monthly
if mpayfreq == '1'
   @ 16+1, 31 say '        Maturity Date ' get mmatdate pict '@D' when eval ({|| mmatdate := matrdte( mfirstdue,mpaytype,mtermunit,mterm ),.t. }) .and. .f.
else
   @ 16+1, 31 say '        Maturity Date ' get mmatdate pict '@D' when eval ({|| mmatdate := matrdte( mfirstdue,mpaytype,mtermunit,mterm ),.t. })
end if
//...........................

   @ 17+1, 31 say 'Monthly Rental Factor ' get mfactor    pict '99.999999'      when .f.
   @ 18+1, 31 say '               Rental ' get mamort     pict '999,999,999.99' when .f.
   @ 19+1, 31 say '    Total Receivables ' get mcredamt   pict '999,999,999.99' when .f.
//   @ 20+1, 31 say '          ALIR Amount ' get malir      pict '999,999,999.99' when eval( { || malir := mcredamt - mprincipal, if( malir < 0, malir := 0, nil ), .f. } )

   if misf5
      inkey( 0 )
      exit
   else
      setcursor( 3 )  //0
      read
      setcursor( 0 )
      if lastkey() == K_ESC
         if esckey()
            mreturn := .f.
            exit
         else
            loop
         endif
      endif
   endif

   if lastkey() <> K_ENTER
      loop
   endif
   exit

enddo
go mrecno
setcolor( mcolor )
restscreen( ,,,, mscr )

return nil
***********************************************************************************************
static function set_code_2( mwhat    , mfcltycode, munit    , mprincipal, mpaytype, mterm     ,;
                            mtermunit, mtruerate , mratetype, mfirstdue , mpayfreq, maddon    ,; 
                            mamort   , mcredamt  , mudi     , mmatdate  , mvaldate, mrefno    ,;
                            mdbf2use , misf5     , mreturn  , munit2    , mwtax   , mincentive,;
					     	mnerate  , mudiamt)
***********************************************************************************************
local motnumber := oticket->otnumber, mrecno := recno(), misreturned  := .f.
local mscr := savescreen( ,,, ), getlist := {}, mcolor := setcolor()
local mratechoices    := { '1 = FIXED   '  , '2 = FLOATING' }
local mpayfreqchoices := { '1 = MONTHLY    ','2 = BI-MONTHLY ','3 = QUARTERLY  ',;
                           '4 = SEMI-ANNUAL','5 = ANNUAL     ','6 = LUMPSUM    ','7 = IRREGULAR  ' }

fshadow( 4, 31, 20, 75, 2, 'w+/gr')
setcolor( 'bg+/gr, w+/n,,, gr+/gr' )

//aga.13.11.2007.remove !misf5 .or. 
mfirstdue := if( mwhat == 'A', firstdte(mvaldate,mtermunit,mpaytype), mfirstdue ) 
mmatdate  := if( mwhat == 'A', matrdte( mvaldate,mpaytype,mtermunit,mterm ), mmatdate)  

@  4, 33 say propercase( rtrim( Facility->fcltyname ) ) color 'bg+/gr'

if mtermunit == '1'
   @ 10, 59 say 'Days    ' color 'gr+/gr'
else
   @ 10, 59 say 'MONTH(s)' color 'gr+/gr'
endif


@ 11, 63 say if( mratetype $ '12', if( mratetype == '1', 'FIXED', 'FLOATING' ), '' ) color 'gr+/gr'
@ 14, 57 say if ( !empty( mpayfreq ), substr ( mpayfreqchoices [ val(mpayfreq) ], 5, 14 ), '' ) color 'gr+/gr'

do while .t.
   @  5, 32 say '         Collaterals ' get munit      pict '@XS20'  when .f.
   @  6, 32 say '                     ' get munit2     pict '@XS20'  when .f.
   @  7, 32 say '         Net Proceed ' get mprincipal pict '999,999,999.99' when .f.
   
   @  8, 32 say '            D.I/S.I. ' get mINCENTIVE pict '999,999,999.99' when .f.
   @  9, 32 say '     Withholding Tax ' get mwtax pict '999,999,999.99' when .f.   
   
   @ 10, 32 say '                Term ' get mterm      pict '999'            valid mterm > 0 .and. ;
                eval ( {||mmatdate :=matrdte( mvaldate,mpaytype,mtermunit,mterm ),.t. })
                //aga.13.11.2007.removed firstdue recompute on term edit
                //eval( { || mfirstdue:=firstdte(mvaldate,mtermunit,mpaytype),.t. } ) .and. 

   @ 11, 32 say 'Gross Effective Rate ' get mtruerate  pict '99.9999'        when .f.
   
   @ 12, 32 say '  Net Effective Rate ' get mnerate pict '99.9999%' when .f.
   
   @ 13, 32 say '      First Due Date ' get mfirstdue  pict '@D'             when .t. ;   //eval( { || mfirstdue:=firstdte(mvaldate,mtermunit,mpaytype),.t. } );
                                                                           valid chkfirstdue( mfirstdue, mvaldate )
   @ 14, 32 say '   Payment Frequency ' get mpayfreq   pict 'X'              when .f.
   @ 15, 32 say '         Add-On Rate ' get maddon     pict '99.9999'        when .f.
   @ 16, 32 say '        Amortization ' get mamort     pict '999,999,999.99' when .f.
   @ 17, 32 say '       Credit Amount ' get mcredamt   pict '999,999,999.99' when .f.
   @ 18, 32 say '          UDI Amount ' get mudiamt    pict '999,999,999.99' when EVAL({|| mudiamt := round( mCREDAMT - ROUND(mprincipal+mincentive+mWTAX,2),2),.F.})  //PEPE 9:08 AM 8/24/2011

//aga.16.10.2007.matdate editing disabled if monthly, changed from first to val
if mpayfreq == '1' 
   @ 19, 32 say '     Maturity Date ' get mmatdate pict '@D' when eval ( { || mmatdate := matrdte( mfirstdue, mpaytype,mtermunit,mterm ),.t. }) .and. .f.
else
   @ 19, 32 say '     Maturity Date ' get mmatdate pict '@D' when eval ( { || mmatdate := matrdte( mfirstdue, mpaytype,mtermunit,mterm ),.t. })   
end if
//...........................

   if misf5
      inkey(  0  )
      exit
   else
      setcursor( 3 )
      read
      setcursor( 0 )
      if lastkey() == K_ESC
         if esckey()
            mreturn := .f.
            exit
         else
            loop
         endif
      endif
   endif
   //exit
   if lastkey() <> K_ENTER
      loop
   endif
   exit
enddo
go mrecno
setcolor( mcolor )
restscreen( ,,,, mscr )
return nil
**************************************************
static function set_code_3( mwhat     , mfcltycode, munit  , mdlrcode , msalesrep, mpurcamt , mdownpay , mincentive,;
                            mprincipal, mpaytype  , mterm  , mtermunit, mtruerate, mratetype, mfirstdue, mpayfreq  ,;
                            mamort    , mcredamt  , mudi   , mmatdate , mvaldate , mrefno   , mdbf2use , misf5     ,;
							mnerate   , mreturn   , munit2 , mwtax    , mudiamt)
**************************************************
local motnumber := oticket->otnumber, mrecno := recno(), misreturned := .f.
local mscr := savescreen( ,,, ), getlist := {}, mcolor := setcolor()
local mpayfreqchoices := { '1 = MONTHLY    ','2 = BI-MONTHLY ','3 = QUARTERLY  ',;
                           '4 = SEMI-ANNUAL','5 = ANNUAL     ','6 = LUMPSUM    ','7 = IRREGULAR  ' }

fshadow( 4, 31, 23, 75, 2, 'w+/gr')
setcolor( 'bg+/gr, w+/n,,, gr+/gr' )

//aga.13.11.2007.remove !misf5 .or. 
mfirstdue := if( mwhat == 'A', firstdte(mvaldate,mtermunit,mpaytype), mfirstdue ) 
mmatdate  := if( mwhat == 'A', matrdte( mvaldate,mpaytype,mtermunit,mterm ), mmatdate)

mudi := mcredamt - ( mprincipal + mincentive )

@  4, 32 say propercase( rtrim( Facility->fcltyname ) ) color 'bg+/gr'

if mtermunit == '1'
   @ 14, 59 say 'Days    ' color 'gr+/gr'
else
   @ 14, 59 say 'MONTH(s)' color 'gr+/gr'
endif

@ 15, 63 say if( mratetype $ '12', if( mratetype == '1', 'FIXED', 'FLOATING' ), '' ) color 'gr+/gr'
@ 18, 57 say if ( !empty( mpayfreq ), substr ( mpayfreqchoices [ val(mpayfreq) ], 5, 11 ), '' ) color 'gr+/gr'

do while .t.
   @  5  , 32 say '                Unit ' get munit      pict '@XS20'          when .f.
   @  6  , 32 say '                     ' get munit2     pict '@XS20'          when .f.
   @  7, 32 say '              Dealer ' get mdlrcode   pict '@X'             when .f.
   @  8, 32 say 'Sales Representative ' get msalesrep  pict '@XS20'          when .f.
   @  9, 32 say '     Purchase Amount ' get mpurcamt   pict '999,999,999.99' when .f.
   @  10, 32 say '        Down Payment ' get mdownpay   pict '999,999,999.99' when .f.
//   @ 11, 32 say "  Dealer's Incentive " get mincentive pict '999,999,999.99' when .f.
   @ 11, 32 say "         D.I. / S.I. " get mincentive pict '999,999,999.99' when .f.
   @ 12, 32 say "     Withholding Tax " get mwtax pict '999,999,999.99' when .f.
   @ 13, 32 say   '         Net Proceed ' get mprincipal pict '999,999,999.99' when .f.
   @ 14, 32 say '                Term ' get mterm      pict '999'            valid mterm > 0 .and. ;
                eval ( {||mmatdate :=matrdte( mvaldate,mpaytype,mtermunit,mterm ),; //,dispmat(mmatdate)
                mudi := mcredamt - ( mprincipal + mincentive ), .t. })
                //aga.13.11.2007.removed firstdue recompute on term edit
                //eval( { || mfirstdue:=firstdte(mvaldate,mtermunit,mpaytype),.t. } ) .and. ;

   @ 15, 32 say '          Gross Rate ' get mtruerate  pict '99.9999'        when .f.
   @ 16, 32 say '  Net Effective Rate ' get mnerate    pict '99.9999'
   @ 17, 32 say '      First Due Date ' get mfirstdue  pict '@D'             when .t. ;  //eval( { || mfirstdue:=firstdte(mvaldate,mtermunit,mpaytype),.t. } ); //aga.13.11.2007.removed firstdue recompute 
                                                                              valid chkfirstdue( mfirstdue, mvaldate )
   @ 18, 32 say '   Payment Frequency ' get mpayfreq   pict 'X'              when .f.
   @ 19, 32 say '        Amortization ' get mamort     pict '999,999,999.99' when .f.
   @ 20, 32 say '       Credit Amount ' get mcredamt   pict '999,999,999.99' when .f.
   @ 21, 32 say '          UDI Amount ' get mudiamt       pict '999,999,999.99' when EVAL({|| mudiamt := round( mCREDAMT - ROUND(mprincipal+mincentive+mWTAX,2),2),.F.})  //PEPE 9:08 AM 8/24/2011


//aga.16.10.2007.matdate editing disabled if monthly
if mpayfreq == '1' 
   @ 22, 32 say '       Maturity Date ' get mmatdate   pict '@D'             when eval( { || mmatdate := matrdte( mfirstdue, mpaytype,mtermunit,mterm ),.t. } ) .and. .f.
else
   @ 22, 32 say '       Maturity Date ' get mmatdate   pict '@D'             when .t.  valid mmatdate > mfirstdue .or. Lastkey() == K_UP
end if
//...........................


   if misf5
      inkey     (  0  )
      exit
   else
      setcursor( 3 )
      read
      setcursor( 0 )
      if lastkey() == K_ESC
         if esckey()
            mreturn := .f.
            exit
         else
            loop
         endif
      endif
   endif
   //exit
   if lastkey() <> K_ENTER
      loop
   endif
   exit
enddo
go mrecno
setcolor( mcolor )
restscreen( ,,,, mscr )
return nil
**************************************************
static function set_code_4( mwhat     , mfcltycode, munit   , mdlrcode , msalesrep, mpurcamt , mdownpay , mincentive,;
                            mprincipal, mpaytype  , mterm   , mtermunit, mtruerate, mratetype, mfirstdue, mpayfreq  ,;
                            mamort    , mcredamt  , mudi    , mnotfctn , mcolexion, mrecourse, mobligor , mcolatrl  ,;
                            mtrantype , mmatdate  , mvaldate, mrefno   , mdbf2use , misf5, mreturn,munit2 )
**************************************************
local motnumber := oticket->otnumber, mrecno := recno(), misreturned := .f.
local mscr := savescreen( ,,, ), getlist := {}, mcolor := setcolor()
local mtermchoices := { '1 = DAY(s)  ', '2 = MONTH(s)' }
local mpayfreqchoices := { '1 = MONTHLY    ','2 = BI-MONTHLY ','3 = QUARTERLY  ',;
                           '4 = SEMI-ANNUAL','5 = ANNUAL     ','6 = LUMPSUM    ','7 = IRREGULAR  ' }

fshadow( 4, 34, 20+1, 75, 2, 'w+/gr')
setcolor( 'bg+/gr, w+/n,,, gr+/gr' )

//aga.13.11.2007.remove !misf5 .or. 
mfirstdue := if( mwhat == 'A', firstdte(mvaldate,mtermunit,mpaytype), mfirstdue ) 
mmatdate  := if( mwhat == 'A', matrdte( mvaldate,mpaytype,mtermunit,mterm ), mmatdate)

@  4, 35 say propercase( rtrim( Facility->fcltyname ) ) color 'bg+/gr'
@  7, 59 say if ( mtermunit $ '12', if( mtermunit == '1', 'DAY(s)', 'MONTH(s)' ), '' ) color 'gr+/gr'
@  8, 63 say if ( mratetype $ '12', if( mratetype == '1', 'FIXED', 'FLOATING' ), '' ) color 'gr+/gr'
@  9, 57 say if ( mnotfctn  $ '12', if( mnotfctn  == '1', 'WITH', 'WITHOUT' ), '' ) color 'gr+/gr'
@ 10, 57 say if ( mcolexion $ '12', if( mcolexion == '1', 'OURS', 'THEIRS' ), '' ) color 'gr+/gr'
@ 11, 57 say if ( mrecourse $ '12', if( mrecourse == '1', 'WITH', 'WITHOUT' ), '' ) color 'gr+/gr'
@ 15, 57 say if ( !empty( mpayfreq ), substr ( mpayfreqchoices [ val(mpayfreq) ], 5, 11 ), '' )
do while .t.
   @  5, 35 say ' Transaction Type ' get mtrantype  pict '@X'             when .f.
   @  6, 35 say '      Net Proceed ' get mprincipal pict '999,999,999.99' when .f.
   @  7, 35 say '             Term ' get mterm      pict '999'            valid mterm > 0 .and. eval( { || chkwhat( mtermchoices, @mtermunit, 7, 59, 'Term Unit' ), .t. } ) .and. ;
                 eval ( {||mmatdate :=matrdte( mvaldate,mpaytype,mtermunit,mterm ),.t. }) // ,dispmat(mmatdate)
                 //aga.13.11.2007.removed firstdue recompute on term edit
                 //eval( { || mfirstdue:=firstdte(mvaldate,mtermunit,mpaytype),.t. } ) .and. 

   @  8, 35 say '   Effective Rate ' get mtruerate  pict '99.9999'        when .f.
   @  9, 35 say '     Notification ' get mnotfctn   pict '@X'             when .f.
   @ 10, 35 say '       Collection ' get mcolexion  pict '@X'             when .f.
   @ 11, 35 say '         Recourse ' get mrecourse  pict '@X'             when .f.
   @ 12, 35 say '          Obligor ' get mobligor   pict '@XS20'          when .f.
   @ 13, 35 say '       Collateral ' get mcolatrl   pict '@XS20'          when .f.
   @ 14, 35 say '   First Due Date ' get mfirstdue  pict '@D'             when .t. ;  //eval( { || mfirstdue:=firstdte(mvaldate,mtermunit,mpaytype),.t. } ) ; //aga.13.11.2007.removed firstdue recompute
                                                                           valid chkfirstdue( mfirstdue, mvaldate )
   @ 15, 35 say 'Payment Frequency ' get mpayfreq   pict 'X'              when .f.
   @ 16, 35 say '     Amortization ' get mamort     pict '999,999,999.99' when .f.
   @ 17, 35 say '    Credit Amount ' get mcredamt   pict '999,999,999.99' when .f.
//   @ 18, 35 say '       UDI Amount ' get mudi       pict '999,999,999.99' when .f.
   @ 19, 35 say '    Maturity Date ' get mmatdate   pict '@D'             when .t. valid lastkey() == K_UP .or. mmatdate > mfirstdue

   if misf5
      inkey(0)
      exit
   else
      setcursor( 3 )
      read
      setcursor( 0 )
      if lastkey() == K_ESC
         if esckey()
            mreturn := .f.
            exit
         else
            loop
         endif
      endif
   endif
   //exit
   if lastkey() <> K_ENTER
      loop
   endif
   exit
enddo
go mrecno
setcolor( mcolor )
restscreen( ,,,, mscr )
return nil
**************************************************
*
*  updated by abb ( 04/12/2000 11:00am )
*
static function chkfirstdue( mfirstdue, mvaldate )
**************************************************
   local mretval := .t.
*********
*********   if mfirstdue < mvaldate
*********      error( 'Execution Date is ">" First Due Date.' );
*********
   if empty ( mfirstdue )
      error ( 'Empty First Due Date' )
      mretval := .f.
   endif
return mretval
*********************************************************************************
static function compute_matdate ( mmatdate, mvaldate, mterm, mtermunit,mpaytype )
*********************************************************************************
    local  mmonth := month ( mvaldate ) , myear  := year ( mvaldate )
    local  mdays  := day   ( mvaldate ) , i

    do case
       case mtermunit == '1'       // Days
            mmatdate += mterm
            if mpaytype == '2'   // In Arrears
               mmonth --
            endif
            do case
               case mmonth == 2         // February ?
                  if (is_leap(myear),mdays := if( mdays>28,29,mdays ),mdays := if( mdays>=28,28,mdays ) )
               case ltrim( str( mmonth,2 ) ) $ '_4_6_9_11' // Mths. with Max of
                  if mdays > 30                            // 30 days
                     mdays := 30
                  endif
            endcase
            mmatdate :=  ctod( ltrim( str( mmonth, 2, 0 ) ) + '/' +;
                               ltrim( str( mdays , 2, 0 ) ) + '/' +;
                               ltrim( str ( myear, 4, 0 ) ) )
            do while isholiday ( mmatdate )  ; mmatdate-- ; enddo
       case mtermunit == '2'       // Months
            for i := 1 to mterm
                mmonth++
                if mmonth > 12
                   myear++ ; mmonth := 1
                endif
            next i
            if mpaytype == '2'   // In Arrears
               mmonth --
            endif
            do case
               case mmonth == 2         // February ?
                  if (is_leap(myear),mdays := if( mdays>28,29,mdays ),mdays := if( mdays>=28,28,mdays ) )
               case ltrim( str( mmonth,2 ) ) $ '_4_6_9_11' // Mths. with Max of
                  if mdays > 30                            // 30 days
                     mdays := 30
                  endif
            endcase
            mmatdate :=  ctod( ltrim( str( mmonth, 2, 0 ) ) + '/' +;
                               ltrim( str( mdays , 2, 0 ) ) + '/' +;
                               ltrim( str ( myear, 4, 0 ) ) )
            ////////
            // move the date backwards if it is a holiday
            //
            do while isholiday ( mmatdate ) ; mmatdate-- ; enddo
    endcase
return .t.
**************************************
function isholiday ( mmatdate )
**************************************
   local mretval := .f.
   do case
      case dow ( mmatdate ) == 1 .or. dow ( mmatdate ) == 7
         mretval := .t.
      case Holidays->(dbseek(getholidate(mmatdate)))
         mretval := .t.
   endcase
return mretval


/*
****************************************
static function getholidate ( mmatdate )
****************************************
   local mmonth := right( '0'+alltrim (str(month(mmatdate),2,0)), 2)
   local mdays  := right( '0'+alltrim (str(day  (mmatdate),2,0)), 2)
return mmonth+'/'+mdays
*/

******************************************************
static function assign_all_facilities ( mdbf2use , mfcltycode, munit    , mdlrcode , mponum  , mpurcamt  ,;
                                        munitloca, mprincipal, mpaytype , mgd, mrv , mterm   , mtermunit ,;
                                        mtruerate, mratetype , mfirstdue, mpayfreq , mfactor , mamort    ,;
                                        mcredamt , malir     , mmatdate , msalesrep, mdownpay, mincentive,;
                                        mvaldate , mdocref   , mrefno   , maddon   , mudi    , mnotfctn  ,;
                                        mcolexion, mrecourse , mobligor , mcolatrl , mtrantype,mnerate   ,;
                                        munit2   , mwtax     , mudiamt )
******************************************************


mfcltycode := (mdbf2use)->FCLTYCODE; munit      := (mdbf2use)->UNIT
mdlrcode   := (mdbf2use)->DLRCODE  ; mpurcamt   := (mdbf2use)->PURCAMT
mprincipal := if( upper(mdbf2use) == 'OTICKET', (mdbf2use)->PROCEEDS, (mdbf2use)->PRINCIPAL )
mpaytype   := (mdbf2use)->PAYTYPE  ; mgd        := (mdbf2use)->GD
mrv        := (mdbf2use)->RV       ; mterm      := (mdbf2use)->TERM
mtermunit  := (mdbf2use)->TERMUNIT ; mtruerate  := (mdbf2use)->TRUERATE
mratetype  := (mdbf2use)->RATETYPE ; mfactor    := (mdbf2use)->FACTOR
mamort     := (mdbf2use)->AMORT    ; mcredamt   := (mdbf2use)->CREDAMT
maddon     := (mdbf2use)->ADDON    ; msalesrep  := (mdbf2use)->SALESREP
mdownpay   := (mdbf2use)->DOWNPAY  ; mincentive := (mdbf2use)->INCENTIVE
mnotfctn   := (mdbf2use)->NOTFCTN  ; mcolexion  := (mdbf2use)->COLEXION
mrecourse  := (mdbf2use)->RECOURSE ; mobligor   := (mdbf2use)->OBLIGOR
mcolatrl   := (mdbf2use)->COLATRL  ; mtrantype  := (mdbf2use)->TRANTYPE
mvaldate   := if(empty(mvaldate),(mdbf2use)->VALDATE,mvaldate)
mnerate    := (mdbf2use)->Nerate
munit2     := (mdbf2use)->unit2
mwtax      := (mdbf2use)->WTAX
mudiamt    := (mdbf2use)->UDIAMT

if( upper ( mdbf2use) == upper ( 'Acctwait' ),;
    eval ({|| mfirstdue := (mdbf2use)->FIRSTDUE ,;
              malir     := (mdbf2use)->ALIR     ,;
              mudi      := (mdbf2use)->UDI }), nil )
************8alert ( mtermunit )
return nil
////

/*
******************************************************
static function chkwhat( marray_, mvariable, mrow, mcol, mtitle )
******************************************************

mvariable := gen_achoice( marray_, val( mvariable ), mtitle )
@ mrow, mcol say subs( marray_[ val( mvariable ) ], at( '=',;
                       marray_[ val( mvariable ) ] ) + 2 ) color 'gr+/gr'
return( .f. )
*/
//

******************************************************
function leafyr(mdate)
******************************************************

if year(mdate) % 4 == 0
   return .t.
else
  return .f.
endif
return nil

//
******************************************************
static function firstdte( mvaldate, mtermunit, mpaytype)
******************************************************
local dday := day(mvaldate),mmonth := month(mvaldate), yyear:=year(mvaldate)
local mo_1:={ 1,3,5,7,8,10,12 },mo_2:={ 4,6,9,11 }


 if alltrim(mpaytype) == '2'
    if alltrim( mtermunit ) == '1'
       mval := mvaldate + 1
    else
       if month( mvaldate ) == 12
          mmonth := 1
          yyear  := yyear + 1
       else
          mmonth := mmonth + 1
       endif
       if ascan( mo_2, mmonth ) <> 0 .and. dday == 31
          dday := 30
       elseif mmonth == 2 .and. dday > 28
          if is_leap( yyear)
             dday := 29
          else
             dday := 28
          endif
       endif
       mval := ctod(str(mmonth,2) + '/' + str(dday,2) +'/' + str(yyear,4) )
    endif
 else
    mval := mvaldate
 endif
 return mval

**************************************************************
*
static function matrdte( mvaldate,mpaytype,mtermunit,mterm )
**************************************************************
local dday := day(mvaldate),mmonth := month(mvaldate), yyear:=year(mvaldate)
local mo_1:={ 1,3,5,7,8,10,12 },mo_2:={ 4,6,9,11 }, nctr := 0,nmonth2 := 0
local m_end:={ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
LOCAL lFRSTDUE := .F., lINCYR := .F.

 if alltrim(mpaytype) == '2'                 // IN ARREARS
    if alltrim(mtermunit) == '1'                // daily
       mvaldate := mvaldate + mterm
    else                                        // monthly
       nmonth2 := mmonth

       for nctr := 1 to mterm
           nmonth2++        
           if nmonth2 > 12
              yyear++
              nmonth2 := 1                
           endif
       next nctr

       mmonth := nmonth2
    endif
 else                                        // IN ADVANCE
    if alltrim(mtermunit) == '1'                // daily
       mvaldate := (mvaldate + mterm) - 1
    else                                        // monthly
       IF mMONTH = 1
          lFRSTDUE := .T.
       ENDIF

       nmonth2 := mmonth
       mmonth  += ( mterm - 1 )
       for nctr := 1 to mterm
           nmonth2++
           if nmonth2 > 12
              yyear++
              nmonth2 := 1
              lINCYR  := .T.
           endif
       next nctr

       IF lFRSTDUE .AND. lINCYR
          yYEAR := yYEAR - 1
       ENDIF

       if ( mmonth % 12 == 0 )
          mmonth := 12
       else
          mmonth := mmonth % 12
       endif

    endif

  endif

   if ascan( mo_2, mmonth ) <> 0 .and. dday == 31
      dday := 30
   elseif mmonth == 2 .and. dday > 28
      if is_leap( yyear)
         dday := 29
      else
         dday := 28
      endif
   endif

   mvaldate :=ctod( tran(mmonth,'99') +'/'+ tran(dday,'99') +'/'+str(yyear,4) )

return mvaldate

//////////
/*------------------------------------------------------*/
Function revwdte( mvaldate,mpaytype,mtermunit,mrevfreq )

/*------------------------------------------------------*/
local dday := day(mvaldate),mmonth := month(mvaldate), yyear:=year(mvaldate)
local dretval := ctod ('')

/* if alltrim(mrevfreq) == '4'
   return ctod('  /  /  ')
elseif alltrim(mtermunit) <> '2'
   return mvaldate
elseif  alltrim(mpaytype) == '2'
    yyear := yyear + 1
else
   yyear    := yyear + 1
   mvaldate :=ctod( tran( mmonth,'99') +'/'+ tran(dday,'99') +'/'+ str(yyear,4) )
   yyear:=year(mvaldate)
   mmonth   := mmonth - 1
   if mmonth < 1
      yyear:=yyear - 1
      mmonth := 12
   endif
   dday := day(lastday(ctod( tran( mmonth,'99') +'/01/'+ str(yyear,4) )))
   //mvaldate :=ctod( tran( mmonth,'99') +'/'+ tran(dday,'99') +'/'+ str(yyear,4) )
endif */

do case
   case alltrim(mREVFREQ) == '5'        // months
      mmonth++
      if mmonth > 12
         mmonth := 1
         yyear++
      endif

      dretval := ctod( tran( mmonth,'99') +'/'+ tran(dday,'99') +'/'+ str(yyear,4) )

      do while empty(dretval)
         dday--
         dretval := ctod( tran( mmonth,'99') +'/'+ ;
                          tran(dday   ,'99') +'/'+ ;
                          str(yyear,4) ;
                        )
      enddo

   case alltrim(mREVFREQ) == '4'        // not applicable
      return ctod('  /  /  ')
   case alltrim(mTERMUNIT) <> '2'       // termunit not months
      return mVALDATE
   case alltrim(mREVFREQ) == '1'        // review freq = quarterly
      mMONTH := if(alltrim(mPAYTYPE)=='2', mMONTH + 3, mMONTH + 2)
      if mMONTH > 12
         mMONTH := mMONTH - 12
         yYEAR  := yYEAR  + 1
      endif
   case alltrim(mREVFREQ) == '2'        // review freq = semi-annual
      mMONTH = if(alltrim(mPAYTYPE)=='2', mMONTH + 6, mMONTH + 5)
      if mMONTH > 12
         mMONTH := mMONTH - 12
         yYEAR  := yYEAR  + 1
      endif
   case alltrim(mREVFREQ) == '3'        // review freq = annual
      mMONTH = if(alltrim(mPAYTYPE)=='2', mMONTH + 12, mMONTH + 11)
      if mMONTH > 12
         mMONTH := mMONTH - 12
         yYEAR  := yYEAR  + 1
      endif
endcase
dretval := ctod( tran( mmonth,'99') +'/'+ tran(dday,'99') +'/'+ str(yyear,4) )
********** alert ( dtoc ( dretval ) )
return dretval

////////
Static function dispmat(mmatdate)
@ 19,55 say mmatdate pict '@D' color 'bg+/gr'
return .t.
*
*                   End of the program ( amst100c.prg )
*
