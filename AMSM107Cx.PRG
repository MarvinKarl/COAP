/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   program id.........:  amsm107c.prg                                         ³
³   description........:  availments maintenance ( facilities )                ³
³   author.............:  Ariel B. Bulan                                       ³
³   date...............:  11:41pm 10-Nov-1994                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                         U P D A T E S                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        Who        ³     When      ³               Why                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Janet L. Bautista ³  10-Sep-1997  ³ gd, rv to 5 decimal places               ³
³ abb               ³  20-Mar-2001  ³ add editing of ratetypes                 ³
³ Janet B. Salvador ³  09-Sep-2002  ³ get net effective rate for CML           ³
³ Janet B. Salvador ³  13-Feb-2003  ³ nerate <= truerate & > 0                 ³
³ ABB               ³  10.14.2004   ³ ONLINE                                   ³
³ RLV               ³  02.02.2010   ³ Dealer achoice removed and changed       ³
³ MTS               ³  08.24.2011   ³ Added di/si,wtax,& neteff rate in        ³
³                   ³               ³  ML facility and UDI computation in CML  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include "Colf.ch"
#include "Inkey.ch"
#include 'achoice.ch'

#define maxrow 54
////
#defi clr_mono     'gr+/bg, w+/rb, w+/b, b/w, w+/g, b+/g, r+/n, w+/r, n/w, w+/rb'
#defi clr_colo    'w+/n, n/w, n/w, w*/n, w/n, w+/n, w+/n, n/w, w+/n, n/w'
#defi guns_n_roses tone( 60, .5 )
#defi nirvana      tone( 480, 0.25 ); tone( 240, 0.25 )
#defi frozen       0
#defi gR_CELL      { 1,  2 }
#defi gN_CELL      { 3,  9 }
#defi gD_CELL      { 9, 10 }
#defi K_SPACEBAR   32
#defi microfeed    chr( 27 ) + 'J' + chr( 18 )
********************************************************************************************
function chek_fcltycode( mwhat    , mfcltycode, munit     , mdlrcode , mponum    ,;
                         mpurcamt , munitloca , mprincipal, mpaytype , mgd       ,;
                         mrv      , mterm     , mtermunit , mtruerate, mratetype ,;
                         mfirstdue, mpayfreq  , mfactor   , mamort   , mcredamt  ,;
                         malir    , mmatdate  , msalesrep , mdownpay , mincentive,;
                         mvaldate , misf5     , mdocref   , mrefno   , maddon    ,;
                         mudi     , mnotfctn  , mcolexion , mrecourse, mobligor  ,;
                         mcolatrl , mtrantype , mslv      , macctno  , munit2    ,;
                         mproceeds, mnerate   , mappval   , mremarks , mbrcode   ,;
						 mWTAX    , mudiamt)
********************************************************************************************
   local mretval  := .f., mdbf2use := 'Acctwait', mar := {}, mcolor := setcolor(), mscr := savescreen(,,,)
   private net_procd := mproceeds

   if mwhat == 'A'
      mdbf2use := if ( mdocref=='1' , 'Cadetail' , 'Oticket' )
      mvaldate := if ( mvaldate == Nil, (alias())->VALDATE, mvaldate )
   endif

   if mdocref == '1' .and. mwhat == 'A' .and. ;  // CA .and. not ADD .and.
      !misf5                                     // not "VIEW ONLY"
      getfclty( @mfcltycode,16,2,mrefno,mprincipal,mdocref )        // get the appropriate
                                                 // facility
      if lastkey() == K_ESC
         return .f.
      endif
   endif

   //omit @ in principal
   if !misf5 .and. mwhat == 'A'           
      assign_all_facilities ( mdbf2use  , @mfcltycode, @munit    , @mdlrcode , @mponum   , @mpurcamt  ,;
                              @munitloca, mprincipal , @mpaytype , @mgd, @mrv, @mterm    , @mtermunit ,;
                              @mtruerate, @mratetype , @mfirstdue, @mpayfreq , @mfactor  , @mamort    ,;
                              @mcredamt , @malir     , @mmatdate , @msalesrep, @mdownpay , @mincentive,;
                              @mvaldate , @mdocref   , @mrefno   , @maddon   , @mudi     , @mnotfctn  ,;
                              @mcolexion, @mrecourse , @mobligor , @mcolatrl , @mtrantype, mar        ,;
                              @munit2   , @mnerate   , @mappval  , @mremarks , @mWTAX    , @mudiamt)
   endif

   @ 16, 22    say mfcltycode pict '@R 999-99'               color 'gr+/b' 
   @ 16, col() say ' '+ upper( dispfcltyname( mfcltycode ) ) color 'gr+/b'
   if lastkey() != K_ESC
      do case
         case Facility -> SETCODE == '1'
            ******mtermunit := '2'
            set_code_1 ( @mwhat    , @mfcltycode, @munit     , @mdlrcode , @mponum    ,;
                         @mpurcamt , @munitloca , @mprincipal, @mpaytype , @mgd, @mrv ,;
                         @mterm    , @mtermunit , @mtruerate , @mratetype, @mfirstdue ,;
                         @mfactor  , @mamort    , @mcredamt  , @malir    , @mpayfreq  ,;
                         @mmatdate , mvaldate   , mrefno     , mdbf2use  , misf5      ,;
                         @mslv     , macctno    , @munit2    , mdocref   , mbrcode)
         case Facility -> SETCODE == '2'
            **********mtermunit := '2'
            set_code_2 ( @mwhat    , @mfcltycode, @munit    , @mprincipal, @mpaytype, @mterm     ,;
                         @mtermunit, @mtruerate , @mratetype, @mfirstdue , @mpayfreq, @maddon    ,;
                         @mamort   , @mcredamt  , @mudi     , @mmatdate  , mvaldate , mrefno     ,;
                         mdbf2use  , misf5      , @munit2   , mdocref    , mbrcode,   @mINCENTIVE,;
						 @mWTAX    , @mNERATE   , @mudiamt )
         case Facility -> SETCODE == '3'
            ********mtermunit := '2'
            set_code_3 ( @mwhat     , @mfcltycode, @munit    , @mdlrcode  , @msalesrep,;
                         @mpurcamt, @mdownpay, @mincentive ,;
                         @mprincipal, @mpaytype  , @mterm                            ,;
                         @mtermunit , @mtruerate , @mratetype, @mfirstdue , @mpayfreq,;
                         @mamort    , @mcredamt  , @mudi                             ,;
                         @mmatdate  , mvaldate   , mrefno     , mdbf2use  ,misf5     ,;
                         @munit2    , mdocref    , @mnerate, @maddon, @mappval,;
                         mbrcode    , @mWTAX     , @mudiamt;
                       )
         case Facility -> SETCODE == '4' .or. Facility -> SETCODE == '5'
            set_code_4 ( @mwhat     , @mfcltycode, @munit     , @mdlrcode  , @msalesrep,;
                         @mpurcamt  , @mdownpay  , @mincentive, @mprincipal, @mpaytype ,;
                         @mterm     , @mtermunit , @mtruerate , @mratetype , @mfirstdue,;
                         @mpayfreq  , @mamort    , @mcredamt  , @mudi      ,;
                         @mnotfctn  , @mcolexion , @mrecourse , @mobligor  , @mcolatrl ,;
                         mtrantype , @mmatdate  , mvaldate   , mrefno     , mdbf2use  ,;
                         misf5      , mdocref   , mbrcode ;
                       )
      endcase
   endif
   setcolor (mcolor) ; restscreen( ,,,,mscr )
   release net_procd

return mretval
******************************************************************************
static function getfclty( mfcltycode, mrow, mcol, mrefno, mprincipal, mdocref )
******************************************************************************
   local mc := setcolor(), mscr := savescreen ( ,,, ),;
         mfclty := .f.   , mrecno := 0

   center  ( 24, 'w+/n', '® Search Facility ¯' )

   while .t.
      lb_lkup ( 'Facility',1,1,@mfcltycode, 2 , 1, 10, 47, 21, 75,'w/gr','@XS15','@X' )

      if lastkey() != K_ESC
         Cadetail->( dbseek ( mrefno ) )
         Cadetail->( dbeval ( {|| if(Cadetail->FCLTYCODE == mfcltycode,;
                                     eval({|| mfclty := .t. , mrecno := Cadetail->( recno() )}), nil ) },,;
                              {|| !Cadetail->(eof()) .and. CADETAIL->BRCODE+Cadetail->CANUMBER == mREFNO }))
         if !mfclty
            error ( 'Facility Code not Found in CA!' )
         else
		 
            IF chk_osbal(mrefno,mprincipal,mdocref,mfcltycode)
               error ( 'CA line fully availed!' )
            ELSE
               Cadetail->( dbgoto( mrecno ) )
               exit      
            ENDIF

         endif
      else
         exit
      endif
   enddo

   setcolor ( mc )
   restscreen ( ,,,, mscr )
return nil

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   Static Function chk_osbal(mrefno,mprincipal,mdocref,mfcltycode)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
local mBAL := 0, mBAL2 := 0, lreturnval := .f., mn := ACCTMAST->(indexkey()), mo := Acctwait->(indexkey())
local mCLNTCD := SPACE(7), lTRUE := .F.

   If PURCHASE->(DBSEEK(mfcltycode))
	   IF CAHEADER->(DBSEEK(mrefno))
		  mCLNTCD := CAHEADER->BRCODE+CAHEADER->CLNTCODE
	   ENDIF

	   CADETAIL->(DBSEEK(mrefno))
	   DO WHILE CADETAIL->BRCODE+CADETAIL->CANUMBER == mrefno .AND. ;
			   !CADETAIL->(EOF())
			   IF CADETAIL->FCLTYCODE == mfcltycode
				  IF PURCHASE->(DBSEEK(CADETAIL->FCLTYCODE))
					 //IF CADETAIL->INCLUDE
						mBAL += CADETAIL->PRINCIPAL
					 //ENDIF
				  ELSE
					 //IF CADETAIL->INCLUDE
						mBAL2 += CADETAIL->PRINCIPAL
					 //ENDIF
				  ENDIF
			   ENDIF
	   CADETAIL->(DBSKIP())
	   ENDDO

	   ACCTMAST->( dbsetorder(2) )
	   GRPMEMBR->(DBSETORDER(2))
	   IF GRPMEMBR->(DBSEEK(mCLNTCD))
		  cGRPCD := GRPMEMBR->BRCODE+GRPMEMBR->GRUPCODE
		  lTRUE := .T.
	   ENDIF

	   GRPMEMBR->(DBSETORDER(1))
	   IF lTRUE

		   GRPMEMBR->(DBSEEK(cGRPCD))
		   DO WHILE GRPMEMBR->BRCODE+GRPMEMBR->GRUPCODE == cGRPCD.AND. ;
				   !GRPMEMBR->(EOF())
	   
			   ACCTMAST->( dbseek(GRPMEMBR->BRCODE2+GRPMEMBR->CLNTCODE) )
			   Do While ACCTMAST->BRCODE+ACCTMAST->CLNTCODE == GRPMEMBR->BRCODE2+GRPMEMBR->CLNTCODE .and. ;
					   !ACCTMAST->(eof())
				  If ACCTMAST->status <> '0'
					 IF PURCHASE->(DBSEEK(SUBS(ACCTMAST->ACCTNO,5,5)))
						mBAL -= ACCTMAST->OSBAL
					 ELSE
						IF RIGHT(mrefno,5) == ACCTMAST->REFNO
						   mBAL2 -= ACCTMAST->PRINCIPAL
						ENDIF
					 ENDIF
				  EndIF
			   ACCTMAST->(dbskip())
			   EndDo
		   
		   GRPMEMBR->(DBSKIP())
		   ENDDO
	   ELSE
		   ACCTMAST->( dbseek(mCLNTCD) )
		   
		   Do While ACCTMAST->BRCODE+ACCTMAST->CLNTCODE == mCLNTCD .and. ;
				   !ACCTMAST->(eof())
			  If ACCTMAST->status <> '0'
				 IF PURCHASE->(DBSEEK(SUBS(ACCTMAST->ACCTNO,5,5)))
					mBAL -= ACCTMAST->OSBAL
				 ELSE
					IF RIGHT(mrefno,5) == ACCTMAST->REFNO
					   mBAL2 -= ACCTMAST->PRINCIPAL
					ENDIF
				 ENDIF
			  EndIF
		   ACCTMAST->(dbskip())
		   EndDo
	   ENDIF

	   Acctwait->  ( dbsetorder(5) )
	   if Acctwait -> (dbseek(mrefno+mdocref))
	 
		  Do While Acctwait->brcode + Acctwait->Refno  == mrefno  .and. ;
				   Acctwait->Docref == mdocref                    .and. ;
				  !Acctwait->(eof())
			 IF PURCHASE->(DBSEEK(SUBS(Acctwait->ACCTNO,5,5)))
				mBAL -= Acctwait->Principal
			 ELSE
				mBAL2 -= Acctwait->Principal
			 ENDIF
		  Acctwait ->(DBSKIP())
		  ENDDO

	   endif
	//ALERT(STR(mBAL)+' '+STR(mprincipal)+' '+STR(mBAL2))
	   IF PURCHASE->(DBSEEK(mfcltycode))
		  If round(mBAL - mprincipal,2) < 0
			 lreturnval := .t.
		  EndIf
	   ELSE
		  If round(mBAL2 - mprincipal,2) < 0
			 lreturnval := .t.
		  EndIf
	   ENDIF
	   
	   ACCTMAST->(dbsetorder(mn))   
	   ACCTWAIT->(dbsetorder(mo))
	   GRPMEMBR->(dbsetorder(2))
   EndIF
return lreturnval

********************************************************************************************
static function set_code_1 ( mwhat    , mfcltycode, munit    , mdlrcode , mponum,mpurcamt,;
                             munitloca, mprincipal, mpaytype , mgd, mrv , mterm          ,;
                             mtermunit, mtruerate , mratetype, mfirstdue, mfactor        ,;
                             mamort   , mcredamt  , malir    , mpayfreq , mmatdate       ,;
                             mvaldate , mrefno    , mdbf2use , misf5    , mslv, macctno  ,;
                             munit2   , mdocref   , mbrcode )
********************************************************************************************
   local motnumber := Oticket->OTNUMBER, mrecno := recno(), misreturned := .f.
   local mpaychoices     := { '1 = IN ADVANCE', '2 = IN ARREARS' }
   local mscr := savescreen( ,,, ), getlist := {}, moldprin := mprincipal
   local moldterm := mterm, moldtruerate := mtruerate, mcolor := setcolor()
   local noldtruerate := 0,noldrv,noldgd,noldterm

   fshadow  ( 4, 30, 19, 75, 2, 'w+/gr' )
   setcolor ( 'bg+/gr, w+/n,,, gr+/gr' )
   @  4, 31 say propercase( rtrim( Facility->fcltyname ) ) color 'bg+/gr'


   @  7, 60 say upper( left( disp_dealer ( mdlrcode ), 15 ) ) color 'gr+/gr'

   @ 11, 57 say if( mpaytype $ '12', if( mpaytype == '1', 'IN ADVANCE', 'IN ARREARS' ), '') color 'gr+/gr'

   if mtermunit == '1'
      @ 14, 59 say 'DAYS    ' color 'gr+/gr'
   else
      @ 14, 59 say 'MONTH(s)' color 'gr+/gr'
   endif

   @ 15, 63 say if ( mratetype $ '12', if( mratetype == '1', 'FIXED', 'FLOATING' ), '') color 'gr+/gr'

   noldtruerate := mtruerate
   noldrv       := mrv
   noldgd       := mgd
   noldterm     := mterm

   do while .t.


       @ 05, 31 say '      Items for Lease ' get munit      pict '@XS20'
       @ 06, 31 say '                      ' get munit2     pict '@XS20'
       @ 07, 31 say '               Dealer ' get mdlrcode   ;
                                              pict '@X'      ;
                                              when getdealer ( @mdlrcode, 7, 60 ) ;
                                              valid chkdealer( @mdlrcode, 7, 60, mbrcode )
       @ 08, 31 say '                PO N§ ' get mponum     pict '99999999'
       @ 09, 31 say '        Unit Location ' get munitloca  pict '@XS20'
       @ 10, 31 say '      Purchase Amount ' get mprincipal pict '999,999,999.99' valid check_amount( mprincipal )
       @ 11, 31 say '         Payment Type ' get mpaytype   pict 'X' when .f.  // chkwhat( mpaychoices, @mpaytype, 11, 57, 'Payment Type' )

       @ 12, 31 say '     Guaranty Deposit ' ;
                get mgd  ;
                pict '99.999999%' ;
                valid mgd >= 0

       @ 13, 31 say '       Residual Value ' ;
                get mrv        ;
                pict '99.999999%' ;
                valid mrv >= ( noldrv * 0.05 )
          //      valid mrv >= 0

       @ 14, 31 say '                 Term ' ;
                get mterm      ;
                pict '999'     ;
                valid mterm > 0
*********                valid mterm <= noldterm .and. mterm > 0

       @ 15, 31 say '       Effective Rate ' ;
                get   mtruerate  ;
                pict '99.9999'   ;
                valid mtruerate >= 0 .and. ;
                      compute_1( mprincipal, mpaytype, mgd, mrv, mtruerate, if(mtermunit=='1',mterm/30,mterm), @mfactor, @mamort, @mcredamt, @mratetype, 15 )

*********                valid mtruerate >= noldtruerate .and. ;
         **************             compute_1( mprincipal, mpaytype, mgd, mrv, mtruerate, if(mtermunit=='1',mterm/30,mterm), @mfactor, @mamort, @mcredamt, @mratetype, 15 )

       @ 16, 31 say 'Monthly Rental Factor ' get mfactor    pict '99.999999'      when .f.
       @ 17, 31 say '               Rental ' get mamort     pict '999,999,999.99' when .f.
       @ 18, 31 say '    Total Receivables ' get mcredamt   pict '999,999,999.99' when .f.
       if misf5
          inkey( 0 )
       else

          setcursor( 3 )
          read
          setcursor( 0 )

          if lastkey() != K_ESC
             if lastkey() == K_ENTER
                *browse_slv ( @mslv, macctno )           && RED 061705
                BROWSE_SLV ( @mSLV, IF(LEN(mACCTNO) = 17, mACCTNO, g_PAR_BRCH+mACCTNO ) )  
                if upper(chr(lastkey())) == 'Y'
                   keyboard( chr ( K_ESC ) )
                endif
             endif
          endif
       endif
       if lastkey() == K_ESC .or. lastkey() == K_ENTER
          exit
       endif
   enddo

   go mrecno
   setcolor( mcolor )
   restscreen( ,,,, mscr )
return nil

*************************************************************
static function check_amount( mprincipal )         //,mdocref,mrefno )
*************************************************************
   local mretval := .t.

   if mprincipal > 0

      if net_procd < mprincipal
         error('Exceeds Unavailed Line<'+alltrim(tran(net_procd,'99,999,999,999.99'))+'>.' )
         mretval:=.f.
      endif

   else
     mretval:=.f.
   endif
return mretval

  /*
   if mprincipal > 0
      do case
         case mdocref == '1'
            if Caheader-> ( dbseek ( mrefno ) )
               if Caheader->PRNLINE-Caheader->PRNAVAIL < mprincipal
                  error ( 'Amount Exceeds Unavailed Line!' ) ; mretval := .f.
               endif
            endif
         otherwise
            if Oticket->( dbseek ( mrefno ) )
               if Oticket->PROCEEDS-Oticket->PRNAVAIL < mprincipal
                  error ( 'Amount Exceeds Unavailed Line!' ) ; mretval := .f.
               endif
            endif
      endcase
   else
      mretval := .f.
   endif
   */

**********************************************************
static function chkdealer( mdlrcode, mrow, mcol, mbrcode )   // abb 10.14.2004 added mbrcode
**********************************************************
   local mretval := .t.
   if empty( mdlrcode )
      @ mrow, mcol say repl( ' ',15 ) color 'gr+/gr'
   else
      if !Dealer->( dbseek (mbrcode+mdlrcode ) )
         error ( 'Dealer does not Exists!' )
         mretval := .f.
      endif
   endif
return mretval

***********************************************
static function getdealer( mdlrcode,mrow,mcol )
***********************************************
   local mc := setcolor(), mscr := savescreen ( ,,, )
   LOCAL cORGDLR := SPACE(4)                         && RED 081205
   LOCAL nORGNTX := DEALER->(INDEXORD())             && RED 081205
   local GETLIST := {}   
   private aTranrecs := {}, aTranpos  := {}, _APalmSec := {}, aRECNO := {} // PEPE
   private nClient := space(10),nIndcode := space(4),nSecind := space(4),nBorrow  := space(4),nNation := space(2)  // PEPE
   private nCLASS  := space(2),nRefer := space(2),nRefbrn := space(3), nAOCHARGE := space(5), nAOASSIST := space(5), _keys // PEPE
   private gCODE := spac(11),sDate:=ctod(''),eDate:=ctod(''),gname:='',opt:= ' '
   private cglname := space(len(DEALER->dlrname))

   center  ( 24, 'w+/n', '® Search Dealer ¯' )

   cORGDLR  := mDLRCODE := DEALER->BRCODE+mDLRCODE
   *lb_lkup ( 'Dealer',1,1,@mdlrcode, 2 , 1, 07, 01, 21, 52,NRM )
//PEPE 12.06.2007   __lb_lkup( 'DEALER',1,2,@mDLRCODE, 2 , 1, 14, 05, 21, 20, 70, 'w/gr+,w/n,,,w/gr+')
 
  // getTranrecs()		//PEPE 12.06.2007
  


     *fshadow   ( 09,10,11,40,2,'w/bg' )            // RED 041905

    fshadow   ( 09,10,12,64,2,'w/bg' )
    //fshadow   ( 13,10,16,40,2,'n/bg' )
    setcolor  ( 'w/bg,bg+/w,,,w+/bg' )

    @ 10,11 say 'Dealer Code  '                ;
            get cORGDLR                       ;
            picture '@R 999-9999' ;               // 
            WHEN  xSHOWNAME(cORGDLR,11,13)     ;               // 
            VALID DLRCODES(@cORGDLR,11,13,'AVAILMENT')     // RLV 020210
 
	setcursor(3)
	read
	setcursor(0)
 
   mDLRCODE := RIGHT(cORGDLR,4)	//PEPE 12.06.2007

   IF LASTKEY() == K_ESC
      mDLRCODE := RIGHT(cORGDLR,4)
   ENDIF

   DEALER->(DBSETORDER(nORGNTX))
   DEALER->(DBSEEK(cORGDLR))

   setcolor ( mc )
   restscreen ( ,,,, mscr )
 
   //@ mrow, mcol say upper( left(Dealer->DLRNAME,15) ) color 'gr+/gr'

   @ mrow, mcol say upper( left(IF(Dealer->(DBSEEK(g_par_brch+mDLRCODE)),DEALER->DLRNAME,SPACE(14)),15) ) color 'gr+/gr'


return .t.
*********************************************************************************************
static function set_code_2 ( mwhat    , mfcltycode, munit    , mprincipal, mpaytype, mterm ,;
                             mtermunit, mtruerate , mratetype, mfirstdue , mpayfreq, maddon,;
                             mamort   , mcredamt  , mudi     , mmatdate  , mvaldate, mrefno,;
                             mdbf2use , misf5     , munit2   , mdocref   , mbrcode , mINCENTIVE,;
							 mWTAX    , mNERATE   , mudiamt)
*********************************************************************************************
   local motnumber := oticket->otnumber, mrecno := recno(), misreturned  := .f.
   local mpaychoices  := { '1 = IN ADVANCE', '2 = IN ARREARS' }
   local mscr := savescreen( ,,, ), getlist := {}, moldprin := mprincipal
   local moldterm := mterm, moldtruerate := mtruerate, mcolor := setcolor()
   local noldtruerate := 0,noldrv,noldgd,noldterm

   fshadow( 4, 32, 18, 75, 2, 'w+/gr' )
   setcolor( 'bg+/gr, w+/n,,, gr+/gr' )    
   @  4, 33 say propercase( rtrim( Facility->fcltyname ) ) color 'bg+/gr'   
   @ 10, 58 say if( mpaytype $ '12', if( mpaytype == '1', 'IN ADVANCE', 'IN ARREARS' ), '') color 'gr+/gr'
******   @  9, 59 say 'MONTH(s)' color 'gr+/gr'
   if mtermunit == '1'
      @ 11, 60 say 'DAYS    ' color 'gr+/gr'
   else
      @ 11, 60 say 'MONTH(s)' color 'gr+/gr'
   endif

   @ 12, 64 say if( mratetype $ '12', if( mratetype == '1', 'FIXED', 'FLOATING' ), '') color 'gr+/gr'
   noldtruerate := mtruerate
   noldterm     := mterm

   do while .t.

       @  5, 33 say '       Collateral(s) ' get munit      pict '@XS19'
       @  6, 33 say '                     ' get munit2     pict '@XS19'
       @  7, 33 say '         Net Proceed ' get mprincipal pict '999,999,999.99' valid check_amount( mprincipal )
	   
	   @  8, 33 say '           D.I./S.I. ' get mINCENTIVE picture '999,999,999.99'
	   @  9, 33 say '     Withholding Tax ' get mWTAX picture '999,999,999.99'
	   
       @ 10,33 say '        Payment Type ' get mpaytype   pict 'X'   when .f. .and. chkwhat( mpaychoices, @mpaytype,10, 58, 'Payment Type' )
       @ 11,33 say '                Term ' get mterm      ;
                                       pict '999'     ;
                                       valid mterm > 0
          //                             valid mterm > 0 .and. mterm <= noldterm

       @ 12, 33 say 'Gross Effective Rate ' get mtruerate  ;
                                       pict '99.9999' ;
                                       valid mtruerate >= 0 .and. ;
                                             compute_2 ( mprincipal,mPAYTYPE,mTRUERATE,if(mtermunit=='1',mterm/30,mterm),@mADDON,@mAMORT,@mCREDAMT,@mRATETYPE,10 )
											 
       @ 13, 33 say '  Net Effective Rate ' get mNERATE    picture '99.9999%' when eval({ || mNERATE := NETRATE( mprincipal+mINCENTIVE+mWTAX, mAMORT, mTERM, mPAYTYPE ),.f.})
***************
**************                                       valid mtruerate >= noldtruerate .and. ;
***********
       @ 14, 33 say '         Add-On Rate ' get maddon     pict '99.9999'        when .f.
       @ 15, 33 say '        Amortization ' get mamort     pict '999,999,999.99' when .f.
       @ 16, 33 say '       Credit Amount ' get mcredamt   pict '999,999,999.99' when .f.
	   @ 17, 33 say '          UDI Amount ' get mudiamt    pict '999,999,999.99' when EVAL({|| mudiamt := round( mCREDAMT - ROUND(mprincipal+mincentive+mWTAX,2),2),.F.})  //PEPE 9:08 AM 8/24/2011
       if misf5
          inkey( 0 )
       else
          setcursor( 3 )
          read
          setcursor( 0 )
       endif

       if lastkey() == K_ESC .or. lastkey() == K_ENTER
          exit
       endif

   enddo
   go mrecno; setcolor( mcolor )
   restscreen( ,,,, mscr )
return nil
********************************************************************************************************************
static function set_code_3 ( mwhat     , mfcltycode, munit, mdlrcode , msalesrep, mpurcamt , mdownpay , mincentive,;
                             mprincipal, mpaytype  , mterm, mtermunit, mtruerate, mratetype, mfirstdue, mpayfreq  ,;
                             mamort    , mcredamt  , mudi , mmatdate , mvaldate , mrefno   , mdbf2use , misf5     ,;
                             munit2    , mdocref   , mnerate,  maddon, mappval  , mbrcode  , mWTAX    , mudiamt  )
********************************************************************************************************************
   local motnumber := oticket->otnumber, mrecno := recno(), misreturned  := .f.
   local mpayfreqchoices := { '1 = MONTHLY    ','2 = BI-MONTHLY ','3 = QUARTERLY  ',;
                              '4 = SEMI-ANNUAL','5 = ANNUAL     ','6 = LUMPSUM    ',;
                              '7 = IRREGULAR  ' }
   local mscr := savescreen(,,,), getlist := {}, moldprin := mprincipal, oldrep := msalesrep
   local moldterm := mterm , moldtruerate := mtruerate, mcolor := setcolor()
   local o_purc := mpurcamt, o_down := mdownpay, o_inc :=mincentive, olddlr:=mdlrcode
   local noldtruerate := 0, noldterm, noldrv, noldgd
   local npercent := 0

   if mappval > mpurcamt                         // whichever is lower
      npercent := ( mdownpay / mpurcamt ) * 100
   else
      npercent := ( mdownpay / mappval ) * 100
   endif

   fshadow  ( 3, 31, 23, 75, 2, 'w+/gr' )
   setcolor ( 'bg+/gr, w+/n,,, gr+/gr'  )

   @  3, 32 say propercase( rtrim( Facility->fcltyname ) ) color 'bg+/gr'
   @  6, 60 say eval( { || Dealer->(dbseek(g_PAR_BRCH+mdlrcode,.f.)) , substr( Dealer->Dlrname,1,15 ) } ) color 'bg+/gr'
   @ 14, 57 say if( mpaytype $ '12', if( mpaytype == '1', 'IN ADVANCE', 'IN ARREARS' ), '') color 'gr+/gr'

*********
*********   @ 15, 59 say 'MONTH(s)' color 'gr+/gr'
*********

   if mtermunit == '1'
      @ 15, 59 say 'DAYS    ' color 'gr+/gr'
   else
      @ 15, 59 say 'MONTH(s)' color 'gr+/gr'
   endif

   @ 16, 63 say if( mratetype $ '12', if( mratetype == '1', 'FIXED', 'FLOATING' ), '') color 'gr+/gr'
   @ 18, 57 say if( !empty( mpayfreq ), subs( mpayfreqchoices[ val( mpayfreq ) ], 5, 11 ), '' ) color 'gr+/gr'

   noldtruerate := mtruerate
   noldterm     := mterm

   do while .t.
       @  4, 32 say '                Unit ' get munit      pict '@XS20'
       @  5, 32 say '                     ' get munit2     pict '@XS20'
       @  6, 32 say '              Dealer ' get mdlrcode   pict '@X'           ;
                                             when getdealer( @mdlrcode, 6, 60 ) ;
                                             valid chkdealer( @mdlrcode, 6, 60, mbrcode ) .and. eval( { ||if( mdlrcode <> olddlr,error('Dealer has been changed.!!'),nil) ,.t.})
       @  7, 32 say 'Sales Representative ' get msalesrep  pict '@XS20'  valid eval({ || if( msalesrep <> oldrep,error('Sales Rep. has been changed.!!'),nil),.t. } )
       @  8, 32 say '     Appraised Value ' get mappval    pict '999,999,999.99'  
       @  9, 32 say '     Purchase Amount ' get mpurcamt   pict '999,999,999.99'  valid lastkey() == K_UP .or. mpurcamt <= o_purc //when .f.
       @ 10, 32 say '        Down Payment ' ;
                get mdownpay   ;
                pict '999,999,999.99'  ;
                valid lastkey() == K_UP .or. ;
                      eval ({|| _is_downpay_valid(mdownpay,npercent,mpurcamt,mappval,mprincipal,mrefno) }) .or. ;
                      ( mdownpay >= o_down .and. ;
                        eval( {|| mprincipal := mPurcamt - mdownpay,.t. });
                      )

//       @ 11, 32 say "  Dealer's Incentive " get mincentive pict '999,999,999.99'  //valid lastkey() == K_UP // .or. trans( mincentive,'999,999,999.99' ) <= trans( 10000,'999,999,999.99' )  //when .f.
       @ 11, 32 say "         D.I. / S.I. " get mincentive pict '999,999,999.99'  //valid lastkey() == K_UP // .or. trans( mincentive,'999,999,999.99' ) <= trans( 10000,'999,999,999.99' )  //when .f.
	   @ 12, 32 say '     Withholding Tax ' get mWTAX picture '999,999,999.99'
       @ 13, 32 say '         Net Proceed ' get mprincipal pict '999,999,999.99'  valid lastkey() == K_UP .or. check_amount( mprincipal )
       @ 14, 32 say '        Payment Type ' get mpaytype   when .f. pict 'X'
       @ 15, 32 say '                Term ' ;
                get   mterm     ;
                pict  '999'     ;
                valid lastkey() == K_UP .or. ;
                       mterm > 0
*********************
*********************                ( mterm > 0 .and. mterm <= noldterm )
*********************
       @ 16, 32 say 'Gross Effective Rate ' get   mtruerate  ;
                                             pict  '99.9999' ;
                                             valid mtruerate >= 0 .and. ;
                                                   lastkey   () == K_UP .or. ;
                                                   compute_2 ( mprincipal,mPAYTYPE,mTRUERATE,if(mtermunit=='1',mterm/30,mterm),@mADDON,@mAMORT,@mCREDAMT,@mRATETYPE,16)
**************                                   valid mtruerate >= noldtruerate .and. ;
          
//       @ 16, 32 say '  Net Effective Rate ' get mnerate    pict '99.9999'        // when .f. pict '99.9999' jbs 09.09.02
       @ 17, 32 say '  Net Effective Rate ' get mnerate    pict '99.9999' when eval({ || mNERATE := NETRATE( mprincipal+mINCENTIVE+mWTAX, mAMORT, mTERM, mPAYTYPE ),.f.})
	   
       @ 18, 32 say '   Payment Frequency ' get mpayfreq   pict 'X'              when .f.
       @ 19, 32 say '        Amortization ' get mamort     pict '999,999,999.99' when .f.
       @ 20, 32 say '       Credit Amount ' get mcredamt   pict '999,999,999.99' when .f.
       //@ 21, 32 say '          UDI Amount ' get mudi       pict '999,999,999.99' when .f.
	   @ 21, 32 say '          UDI Amount ' get mudiamt       pict '999,999,999.99' when EVAL({|| mudiamt := round( mCREDAMT - ROUND(mprincipal+mincentive+mWTAX,2),2),.F.})  //PEPE 9:08 AM 8/24/2011
       @ 22, 32 say '         Add-on Rate ' get maddon     pict '99.9999'        when .f.
       //@ 17, 32 say '  Net Effective Rate ' get mnerate    pict '99.9999'        valid mnerate <= mtruerate .and. mnerate >= 0  // jbs 02.13.2003  . abb 10.20.2005 '>='
                                                   // when .f. pict '99.9999' jbs 09.09.02

       if misf5
          inkey( 0 )
       else
          setcursor( 3 )
          read
          setcursor( 0 )
       endif

       if lastkey() == K_ESC .or. lastkey() == K_ENTER
          exit
       endif

   enddo
   go mrecno; setcolor( mcolor )
   restscreen(,,,, mscr )
return nil

*****************************************************************************************
*
static function _is_downpay_valid(mdownpay,npercent,mpurcamt,mappval,mprincipal,mrefno)
*****************************************************************************************
   local lretval := .f., nactualpercent := 0

   if mappval > mpurcamt                         // whichever is lower
      nactualpercent :=  ( mdownpay / mpurcamt ) * 100
   else
      nactualpercent :=  ( mdownpay / mappval  ) * 100
   endif


   if nactualpercent >= npercent
      lretval := .t.
   else

     if mappval < mpurcamt          // abb 09.28.2005
        _mbase := mappval
     else
        _mbase := mpurcamt
     endif



     if empty(alltrim(__crefno2))

        __npercent := 0
        __nbase2   := 0

        if Oticket->(dbseek(mrefno))
           if Oticket->appval > Oticket->purcamt
              __nbase2   := Oticket->purcamt
           else
              __nbase2   := Oticket->appval
           endif

           __npercent := (Oticket->downpay/__nbase2) * 100

**           if  <= __npercent

  **         else

    **       endif

        endif

     endif


   endif


return lretval

**************************************************
static function set_code_4 ( mwhat     , mfcltycode, munit   , mdlrcode , msalesrep, mpurcamt , mdownpay , mincentive,;
                             mprincipal, mpaytype  , mterm   , mtermunit, mtruerate, mratetype, mfirstdue, mpayfreq  ,;
                             mamort    , mcredamt  , mudi    , mnotfctn , mcolexion, mrecourse, mobligor , mcolatrl  ,;
                             mtrantype , mmatdate  , mvaldate, mrefno   , mdbf2use , misf5    , mdocref  , mbrcode)
**************************************************
   local motnumber := oticket->otnumber, mrecno := recno(), misreturned := .f.
   local mtermchoices := { '1 = DAY(s)  ', '2 = MONTH(s)' }
   local mpayfreqchoices :=  { '1 = MONTHLY    ','2 = BI-MONTHLY ','3 = QUARTERLY  ',;
                               '4 = SEMI-ANNUAL','5 = ANNUAL     ','6 = LUMPSUM    ',;
                               '7 = IRREGULAR  ' }
   local mscr := savescreen ( ,,, ), getlist := {}, moldprin := mprincipal
   local moldterm := mterm , moldtruerate := mtruerate, mcolor := setcolor()
   local noldtruerate := 0,noldterm,noldrv,noldgd
   local _mRATECHOICES := { '1 = FIXED   ','2 = FLOATING' }

   fshadow  ( 4, 34, 19, 75, 2, 'w+/gr' )
   setcolor ( 'bg+/gr, w+/n,,, gr+/gr'  )

   @  4, 35 say propercase( rtrim( Facility->fcltyname ) ) color 'bg+/gr'   
   @  7, 57 say if ( mpaytype  $ '12', if( mpaytype  == '1', 'IN ADVANCE', 'IN ARREARS' ), '' ) color 'gr+/gr'
   @  8, 59 say if ( mtermunit $ '12', if( mtermunit == '1', 'DAY(s)', 'MONTH(s)' ), '' ) color 'gr+/gr'
   @  9, 63 say if ( mratetype $ '12', if( mratetype == '1', 'FIXED', 'FLOATING' ), '' ) color 'gr+/gr'
   @ 10, 57 say if ( mnotfctn  $ '12', if( mnotfctn  == '1', 'WITH', 'WITHOUT' ), '' ) color 'gr+/gr'
   @ 11, 57 say if ( mcolexion $ '12', if( mcolexion == '1', 'OURS', 'THEIRS' ), '' ) color 'gr+/gr'
   @ 12, 57 say if ( mrecourse $ '12', if( mrecourse == '1', 'WITH', 'WITHOUT' ), '' ) color 'gr+/gr'
   @ 15, 57 say if ( !empty( mpayfreq ), subs( mpayfreqchoices[ val( mpayfreq ) ], 5, 11 ), '' ) color 'gr+/gr'

   mtrantype := if ( empty( mtrantype  ), '1', mtrantype )
   mnotfctn  := if ( empty( mnotfctn   ), '1', mnotfctn  )
   mcolexion := if ( empty( mcolexion  ), '1', mcolexion  )
   mrecourse := if ( empty( mrecourse  ), '1', mrecourse  )

   noldtruerate := mtruerate
   noldterm     := mterm

   do while .t.

       @  5, 35 say ' Transaction Type ' get mtrantype  pict '@X' when .f.   
       @  6, 35 say '      Net Proceed ' get mprincipal pict '999,999,999.99' valid check_amount( mprincipal )
       @  7, 35 say '     Payment Type ' get mpaytype   when .f. pict 'X'
       @  8, 35 say '             Term ' get mterm      ;
                pict '999' ;
                valid mterm > 0         .and. ;
                      eval( { || chkwhat( mtermchoices, @mtermunit, 8, 59, 'Term Unit' ), .t. } )
/*************************
                valid mterm > 0         .and. ;
                      mterm <= noldterm .and. ;
                      eval( { || chkwhat( mtermchoices, @mtermunit, 8, 59, 'Term Unit' ), .t. } )
*******************/

       @  9, 35 say '   Effective Rate ' get mtruerate  ;
                                          pict '99.9999' ;
                                          valid mtruerate > 0 .and. ;
                                                eval ( {|| chkratetype( _mratechoices, @mratetype, 9, 63 ),.t. })     // abb 3.20.2001

*************                                          valid mtruerate >= noldtruerate ;
       @ 10, 35 say '     Notification ' get mnotfctn   pict '@X'  when .f.
       @ 11, 35 say '       Collection ' get mcolexion  pict '@X'  when .f.
       @ 12, 35 say '         Recourse ' get mrecourse  pict '@X'  when .f.
       @ 13, 35 say '          Obligor ' get mobligor   pict '@XS20'
       @ 14, 35 say '       Collateral ' get mcolatrl   pict '@XS20'
       @ 15, 35 say 'Payment Frequency ' get mpayfreq   pict 'X'   when .f.
       @ 16, 35 say '     Amortization ' get mamort     pict '999,999,999.99'
       @ 17, 35 say '    Credit Amount ' get mcredamt   pict '999,999,999.99'
       @ 18, 35 say '       UDI Amount ' get mudi       pict '999,999,999.99' when eval ({|| mudi := mcredamt-mprincipal,.f. })

       if misf5
          inkey( 0 )
       else
          setcursor( 3 )
          read
          setcursor( 0 )
       endif

       if lastkey() == K_ESC .or. lastkey() == K_ENTER
          exit
       endif

   enddo
   go mrecno; setcolor( mcolor )
   restscreen(,,,, mscr )
return nil
*******************************************************
static function valid_payfreq(mpayfreqchoices,mpayfreq)
*******************************************************
   local mretval := .f., mcontinue := .t.
   do while mcontinue
      chkpayfreq(mpayfreqchoices,@mpayfreq,17,58)
      if (Facility->SETCODE=='5' .and. !(mpayfreq $ '67'),error('Invalid Payment Frequency, <Lumpsum/Irregular> Only!'),mcontinue:=.f.)
   enddo
return mretval
**************************************************
static function chkfirstdue( mfirstdue, mvaldate )
**************************************************
   local mretval := .t.
   if mfirstdue < mvaldate
      error ( 'Availment Date is ">" First Due Date.' ); mretval := .f.
   endif
return mretval
************************************************************************
static function compute_matdate ( mmatdate, mvaldate, mterm, mtermunit )
**************************************************************************
    local  mmonth := month ( mvaldate ) , myear  := year ( mvaldate )
    local  mdays  := day   ( mvaldate ) , i
    
    do case
       case mtermunit == '1'       // Days
            mmatdate += mterm
            do while isholiday ( mmatdate )  ; mmatdate-- ; enddo
       case mtermunit == '2'       // Months
            for i := 1 to mterm
                mmonth++
                if mmonth > 12
                   myear++ ; mmonth := 1
                endif
            next i
            do case
               case ltrim(trans(mmonth,'999')) ==  '2'         // February ?
                  if ( is_leap(myear), mdays := if( mdays>28,29,mdays ),mdays := if( mdays>=28,28,mdays ) )
               case ltrim(trans(mmonth,'999')) $ '_4_6_9_11'
                  if mdays > 30
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
return .f.
/*
***********************************************************
static function chkpayment(mpaychoices,mpaytype,mrow,mcol )
***********************************************************
  mpaytype := gen_achoice( mpaychoices, val( mpaytype ), 'Payment', mrow+1, 56, mrow+1+len( mpaychoices ), 77, 'w/gr+,w/n,,,w/gr+' )
  @ mrow, mcol say upper( if( mpaytype == '1', 'In advance', 'In arrears' ) ) color 'gr+/gr'
  return .f.
*/
******************************************************************
static function  chkratetype( mratechoices, mratetype, mrow, mcol )
******************************************************************
  mratetype := gen_achoice( mratechoices, val( mratetype ), 'Rate Type', mrow+1, 56, mrow+1+len( mratechoices), 77, 'w/gr+,w/n,,,w/gr+' )
  @ mrow, mcol say upper( if( mratetype == '1', 'Fixed   ', 'Floating' ) ) color 'gr+/gr'
return .t.
**************************************
static function isholiday ( mmatdate )
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
***************************************************************
static function fclty_not_found ( mrefno, mfcltycode, mdocref )
***************************************************************
   local mretval := .f.
   if !empty ( mfcltycode ) .and. lastkey() != K_ESC
      if mdocref == '1'
         if !Cadetail->(dbseek(mrefno+mfcltycode))
             error ( 'No such Facility in CA!' )
             mretval := .t.
         endif
      else
         if !Oticket->(dbseek(mrefno+mfcltycode))
             error ( 'Different Facility Entered, Call Concerned AO!' )
             mretval := .t.
         endif
      endif
   endif
   
return mretval

************************************************************************************************
static function assign_all_facilities ( mdbf2use , mfcltycode, munit    , mdlrcode , mponum   , mpurcamt  ,;
                                        munitloca, mprincipal, mpaytype , mgd, mrv , mterm    , mtermunit ,;
                                        mtruerate, mratetype , mfirstdue, mpayfreq , mfactor  , mamort    ,;
                                        mcredamt , malir     , mmatdate , msalesrep, mdownpay , mincentive,;
                                        mvaldate , mdocref   , mrefno   , maddon   , mudi     , mnotfctn  ,;
                                        mcolexion, mrecourse , mobligor , mcolatrl , mtrantype, mar       ,;
                                        munit2   , mnerate   , mappval  , mremarks , mWTAX    , mudiamt )
************************************************************************************************
   munit      := (mdbf2use)->UNIT     ; mdlrcode  := (mdbf2use)->DLRCODE
   mpurcamt   := (mdbf2use)->PURCAMT  ; mpaytype  := (mdbf2use)->PAYTYPE
   mgd        := (mdbf2use)->GD       ; mrv       := (mdbf2use)->RV
   mterm      := (mdbf2use)->TERM     ; mtermunit := (mdbf2use)->TERMUNIT
   mtruerate  := (mdbf2use)->TRUERATE ; mratetype := (mdbf2use)->RATETYPE
   mfactor    := (mdbf2use)->FACTOR   ; mamort    := (mdbf2use)->AMORT
   mcredamt   := (mdbf2use)->CREDAMT  ; maddon    := (mdbf2use)->ADDON
   msalesrep  := (mdbf2use)->SALESREP ; mdownpay  := (mdbf2use)->DOWNPAY
   mincentive := (mdbf2use)->INCENTIVE; mnotfctn  := (mdbf2use)->NOTFCTN
   mcolexion  := (mdbf2use)->COLEXION ; mrecourse := (mdbf2use)->RECOURSE
   mobligor   := (mdbf2use)->OBLIGOR  ; mcolatrl  := (mdbf2use)->COLATRL
   mtrantype  := (mdbf2use)->TRANTYPE ; munit2    := (mdbf2use)->UNIT2
   mnerate    := (mdbf2use)->Nerate       
   mappval    := (mdbf2use)->Appval
   mWTAX      := (mdbf2use)->WTAX


   do case
      case upper(mdbf2use) == 'OTICKET'
         mprincipal   := Oticket->PROCEEDS
         mfcltycode   := Oticket->FCLTYCODE
         *---> RED 101905
         *mremarks     := Oticket->obtain // abb 05.17.2004
         mREMARKS     := COLLMEM( 'OT_OBT', OTICKET->OTNUMBER, OTICKET->BRCODE )
 
      otherwise

         mprincipal   := (mdbf2use)->PRINCIPAL
         if upper ( mdbf2use) != 'ACCTWAIT'                // abb 05.17.2004
// EVR            mremarks     := Caheader->obtain             // abb 05.17.2004
            mREMARKS     := COLLMEM( 'CA_OBT', Caheader->CANUMBER, Caheader->BRCODE )
         endif                                             // abb 05.17.2004

   endcase
   
   if upper ( mdbf2use) == 'ACCTWAIT'
      mfcltycode   := Acctwait->FCLTYCODE
      mponum       := Acctwait->PONUM
      mfirstdue    := Acctwait->FIRSTDUE
      malir        := Acctwait->ALIR
      mudi         := Acctwait->UDI
      mudiamt      := Acctwait->UDIAMT
   else
      munitloca    := space ( len ( Acctwait->UNITLOCA ) )
      mponum       := space ( len ( Acctwait->PONUM ) )
      mfirstdue    := ctod  ( '//' )
      malir        := 0
      mudi         := 0
	  mudiamt      := 0
   endif
   
return nil

***************************************************************************
static function check_principal( mprincipal, mrefno, mfcltycode,mdbf2use  )
***************************************************************************
    local mretval := .t., mdbf := savedbf( mdbf )

    if mprincipal<=0
       return .f.
    endif
    if upper(mdbf2use) == 'CADETAIL'
       if Cadetail->( dbseek(mrefno+mfcltycode) )
          if mprincipal > (Cadetail->PRINCIPAL-Cadetail->AVAILED)
             error ( 'Net Proceed Exceeds Principal Amount!' ); mretval := .f.
          endif
       endif
    else
       if Oticket->( dbseek(mrefno) )
          if mprincipal>(Oticket->PROCEEDS)
             error ( 'Net Proceed Exceeds Principal Amount!' ); mretval := .f.
          endif
       endif
    endif
    restdbf ( mdbf )
return (mretval)

**********************************************************************************************************
static function compute_1(mprincipal,mpaytype, mgd,mrv,mtruerate,mterm,mfactor,mamort,mcredamt,mratetype,mrow)
**********************************************************************************************************
   local mRATEMTH, mPVALUE, mPVLESS, mGDAMOUNT, mRVAMOUNT, mUP, mDOWN
   local mRATECHOICES := { '1 = FIXED   ','2 = FLOATING' }

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
      mUP   := mRATEMTH * (( 1 + mRATEMTH ) ** ( mTERM     ))  // in advance
   endif
   mDOWN    :=  (( 1 + mRATEMTH) ** mTERM ) - 1
   mAMORT   := round ( mPVALUE * ( mUP / if(mdown==0,1,mdown)  ), 2)
   mAMORT   := intround(mAMORT)
   mFACTOR  := ( mAMORT / mPRINCIPAL ) * 100
   mCREDAMT := mAMORT * mTERM
   ********* no edit of rate type ->> ( 07072000 ding said ) chkratetype( mRATECHOICES, @mRATETYPE, mrow, 63 )
   chkratetype( mRATECHOICES, @mRATETYPE, mrow, 63 )   // 3.20.2001 abb
return .t.

****************************************************************************************************
*
static function compute_2( mPRINCIPAL,mPAYTYPE,mTRUERATE,mTERM,mADDON,mAMORT,mCREDAMT,mRATETYPE,mrow )
****************************************************************************************************
   local mRATECHOICES := { '1 = FIXED   ','2 = FLOATING' }
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

   if mtruerate == 0 // abb 10.20.2005
      mCREDAMT := mPRINCIPAL
   else
      mCREDAMT := mAMORT * mTERM
   endif

   mADDON   := ( mCREDAMT - mPRINCIPAL ) / if(mPRINCIPAL==0,1,mprincipal)
   ********* no edit of rate type ->>    chkratetype( mratechoices, @mratetype, mrow, 63 )
   chkratetype( mratechoices, @mratetype, mrow, 63 )     // abb 3.20.2001
return .t.


*******************************
*
static function GetTranRecs()
******************************
local mcolor  := setcolor(), mscreen := savescreen( ,,, ), mlogic := .t.
LOCAL NTX := INDEXORD(), mm := ALIAS()
private nPREVSELECT := 0, PRO := 0,PROS := .F., nTOP := .F.,mPRESS := .F.

 aTranrecs := {}
 aTranpos  := {}
 _APalmSec := {}

//do case

// case lfound == 1

 fShadow( 5, 13, 22, 69, 2, 'w+/g' ) //w+/GR

 dbselectarea('DEALER')
 DBSETORDER(3)
 DEALER->(dbseek(g_par_brch))

 ___GetTranRecs()

     setcolor ( 'i/gr, w+/bg' )

     @ 6,14 say '              DLRNAME                   BRCODE DLRCODE'  color 'w+/g'
     @ 7,14 to 7,68								  color 'w+/g'
     @ 22,39 say '[PGDN]-NEXT' 					  		  color 'bg+/g'
     @ 22,52 say '[PGUP]-PREVIOUS'     					  	  color 'bg+/g'

     do while .t.
      mBX := achoice(8,14, 22, 68, aTranRecs, .t.,'DEALRFUNC')

      do case
         case lastkey() == K_ESC
               exit
  
         case lastkey() == K_ENTER
	      if mPRESS
                 exit
	      endif
	    
      endcase
     enddo

   setcolor       ( mcolor )
   restscreen     ( ,,,, mscreen )

//endcase
DBSELECTAREA(mm)
DBSETORDER(NTX)

return mBX

**************************************
*
STATIC FUNCTION ___GetTranRecs(lfound)
**************************************
//LOCAL NCTR := 0, NCTR2 := 0
local NCTR := 0

//do case

//  case lfound == 1 

//  _keys := 1

  dbselectarea('DEALER')

      do while !DEALER->(eof()) 

	IF DEALER->BRCODE == g_PAR_BRCH

		//IF DEALER->CLTYPE == '1'

		   nctr++

        	    aadd ( aTranRecs,  padr(' ',' ')   		+ ' ' +   ;
			   padr ( DEALER->DLRNAME,40)           + ' ' +   ;
                           padr ( DEALER->brcode,3)        	+ '   ' +   ;
                           padr ( DEALER->dlrcode,4)		+ ' '     ;
              	         ) 

		    aadd ( _APalmSec,DEALER->brcode+DEALER->DLRCODE)	

		  if !nTOP

		    IF alltrim(str(NCTR)) == '1'
		       pro++

		      if pro > len(aRECNO) 
		         AADD ( aRECNO,{DEALER->(RECNO()),0} )
		      ENDIF

		    endif

		  endif

	ENDIF

		IF nctr > 13
           		exit
		endif

         	DEALER->(dbskip(+1))


      enddo

//endcase

RETURN 

**********************************************
*
FUNCTION DEALRFUNC (status, curr_elem, curr_row)
**********************************************
local key    := lastkey(),mSAY,cSRCH := space(20),lchar := ' '
local __nctr := 0, getlist := {}, menulist := {},nORGPOS := 0
local _lfound := .f., mscreen1 := savescreen1( ,,, )
LOCAL NTX := DEALER->(INDEXORD())

//do case

// case _keys == 1

   do case
      case key == K_ESC
         return 0

      case key == K_ENTER

	mPRESS := .T.

	DBSETORDER(1)

	__mseekvar := _APalmSec[curr_elem]
	if DEALER->(dbseek(__mseekvar))
	   nClient := DEALER->dlrcode
	endif

	return 0

      case key >= 32 .and. key <= 254

	lchar	:= upper(chr(lastkey()))
	nORGPOS := recno()
        __keyboard(lchar)

	@22,15  say '' 			color 'w+/g'	
	@22,18 get cSRCH pict '@!' 		color 'w+/g'

	setcursor( 3 )
	read
	setcursor( 0 )

        restscreen1     ( ,,,, mscreen1 )

	if lastkey() == K_ENTER

	mPRESS := .F.

	   if DEALER->(dbseek(g_par_brch + rtrim(cSRCH)))

               aTranRecs   := {}
               _APalmSec   := {}
               ___GetTranRecs()

               @ 8,14 clear to 21, 68

	   else
		error('DEALER not found!')
		dbgoto(nORGPOS)
	   endif

	endif

	return 0

      case key == K_PGUP

	nTOP 	   := .T.
        IF(alltrim(str(pro)) == '1',pros := .T.,pro--)

	if pros   // DEALER->(bof()) .OR. DEALER->BRCODE != g_PAR_BRCH
          mSAY := 'BEGINNING OF FILE'    
          WAITON( mSAY,, 'W+/R' )
          // INKEY( 1 )
          WAITOFF()
	  pros := .F.
	endif

	dbgoto(aRECNO[pro][1]) //DEALER->(dbgoto(aRECNO[pro][1]) )

	if DEALER->brcode == g_PAR_BRCH 

           //IF DEALER->CLTYPE == '1'

               aTranRecs   := {}
               _APalmSec   := {}
               ___GetTranRecs()

               @ 8,14 clear to 21, 68
	   //ENDIF

	endif

	return 

      case key == K_PGDN

	nTOP := .F.
	DEALER->(dbskip(+1))

	if DEALER->(eof()) .OR. DEALER->BRCODE != g_PAR_BRCH
          mSAY := 'END OF FILE' 
          WAITON( mSAY,, 'W+/R' )
          // INKEY( 1 )
          WAITOFF()
	endif

	 if DEALER->brcode == g_PAR_BRCH 

               aTranRecs   := {}
               _APalmSec   := {}
               ___GetTranRecs()

               @ 8,14 clear to 21, 68

	endif

        return

    endcase

//endcase

DBSETORDER(NTX)

return 2

STATIC FUNCTION xSHOWNAME(cDEALER,nROW,nCOL)
LOCAL cDLRNAME := SPACE(50)

IF DEALER->(DBSEEK(cDEALER))
   cDLRNAME := DEALER->DLRNAME
ENDIF

@ nROW,nCOL SAY cDLRNAME COLOR 'W+/GR'

RETURN .T.


*-------------------------------------------------------------------------------
STATIC FUNCTION DLRCODES(gCODE,X,Y,cPROG)  // RLV 020210
LOCAL lRETVAL := .F.
LOCAL cDLRNAME := SPACE(50)
LOCAL nIDX    := DEALER->(INDEXORD())
LOCAL SCR
local GETLIST := {}   
private cPROG2 := cPROG

SETKEY( K_ESC, NIL )

IF EMPTY(gCODE)

   SCR := SAVESCREEN( 11,10,13,72 )
   FWIND0100( 11,10,13,72, 'W+/GR', , 'BG+/GR')

   @ 12,12 SAY 'DLNAME ' GET cDLRNAME PICT '@!' VALID xDLNAME(@cDLRNAME,13,21,cPROG) .and. !empty(cDLRNAME)
  
 //setcursor(3)
 READ
 //setcursor(0)
   RESTSCREEN( 11,10,13,72,SCR )

   IF EMPTY(cDLRNAME)

      IF LASTKEY() == K_ENTER
         DEALER->(DBSETORDER(2))
         gCODE := DLRBROWSE(gCODE)

         IF LASTKEY() == K_ENTER

            @ X,Y SAY DEALER->DLRNAME
            lRETVAL := .T.
         ELSEIF LASTKEY() == K_ESC
                gCODE := SPACE(11+3)
                lRETVAL := .F.
         ENDIF
      ELSE
         gCODE := SPACE(11+3)
         lRETVAL := .F.
      ENDIF
   ELSE
      DEALER->(DBSETORDER(3))

      IF DEALER->(DBSEEK(g_PAR_BRCH+PADR(cDLRNAME,50,' ')))
         gCODE := DEALER->BRCODE+DEALER->DLRCODE
         @ X,Y SAY cDLRNAME                      &&COLOR ''
         lRETVAL := .T.
      ENDIF
   ENDIF
ELSE

   IF LASTKEY() == K_ENTER

      IF CURRBRCH(LEFT(gCODE,3))
         DEALER->(DBSETORDER(1))

         IF DEALER->(DBSEEK(gCODE))
            gCODE := DEALER->BRCODE+DEALER->DLRCODE
            @ X,Y SAY DEALER->DLRNAME            &&COLOR ''
            lRETVAL := .T.
         ELSE
            gCODE := SPACE(11+3)
            lRETVAL := .F.
         ENDIF
      ELSE
         gCODE := SPACE(11+3)
         lRETVAL := .F.
      ENDIF
	ELSE
      gCODE := SPACE(11+3)
      lRETVAL := .F.
   ENDIF
ENDIF

DEALER->(DBSETORDER(nIDX))
SETKEY(K_ESC, { || FESCAPE('ABORT?') })

RETURN lRETVAL

*-------------------------------------------------------------------------------
FUNCTION xDLNAME(cDLNME,X,Y,cPROG)
LOCAL lRETVAL := .F.
LOCAL cCOL    := SETCOLOR()
LOCAL nIDX    := DEALER->(INDEXORD())
LOCAL aDEALER := {}, bDEALER := {}
LOCAL nAGL    := 0
LOCAL SCR
local GETLIST := {}   
LOCAL wDEALER

IF LASTKEY() == K_ENTER
   IF EMPTY(ALLTRIM(cDLNME))
      cDLNME  := SPACE(50)
      lRETVAL := .T.
   ELSE
      DEALER->(DBSETORDER(3))

      IF DEALER->(DBSEEK(g_par_brch+RTRIM(cDLNME)) )

         DO WHILE SUBSTR(DEALER->DLRNAME,1,LEN(RTRIM(cDLNME))) == RTRIM(cDLNME) .AND. ;
	 	 !DEALER->(EOF())

            IF DEALER->BRCODE == g_PAR_BRCH
               AADD(aDEALER,DEALER->DLRNAME+' '+DEALER->BRCODE+'-'+DEALER->DLRCODE)
               AADD(bDEALER,DEALER->DLRCODE)
            ENDIF

            DEALER->(DBSKIP())
         ENDDO

         IF LEN(aDEALER) > 0
            *SCR := SAVESCREEN(16,21,19,70)
            *nAGL := ACHOICE(16,21,19,70,aDEALER,,'xUDF')
            SCR  := SAVESCREEN(X,Y,X+3,Y+49)
            nAGL := ACHOICE(X,Y,X+3,Y+49,aDEALER,,'xUDF')

    IF LASTKEY() = K_ENTER
 //              cDLNME := aDEALER[nAGL]
 //              lRETVAL := .T.
		DEALER->(DBSETORDER(1))
		IF DEALER->(DBSEEK(g_PAR_BRCH+bDEALER[nAGL])) //.and. cPROG != 'INQUIRY'    //pepe 01.16.2008
			   cDLNME := DEALER->dlrname//aDEALER[nAGL]
			   lRETVAL := .T.
			endif
	  	
            ELSEIF LASTKEY() == K_ESC
                   cDLNME := SPACE(50)
                   lRETVAL := .F.
            ENDIF
         ELSE
            cDLNME := SPACE(50)
            lRETVAL := .F.
         ENDIF

         *RESTSCREEN(16,21,19,70,SCR)
         RESTSCREEN(X,Y,X+3,Y+49,SCR)

      ELSE
         cDLNME := SPACE(50)
      ENDIF

      DEALER->(DBSETORDER(nIDX))

      SETCOLOR(cCOL)
   ENDIF
ENDIF

RETURN lRETVAL

FUNCTION xUDF(nMODE,nHI,nPOS)
LOCAL nRETVAL := 2

DO CASE
   CASE nMODE == 1 .OR. nMODE == 2
        nRETVAL := 2
   CASE LASTKEY() == K_ENTER
        nRETVAL := 1
   CASE LASTKEY() == K_ESC
        nRETVAL := 0
ENDCASE

RETURN nRETVAL

static function fWind0100( a_, b_, c_, d_, e_, f_, g_ )

fShadow( a_, b_, c_, d_, 2, e_, f_ )
setcolor( g_ + ', n+/w,,, w+/' + substr( g_, 5, 2 ) )
return( g_ )

static FUNCTION DLRBROWSE(gCODE)
LOCAL cDEALER := SPACE(4)
LOCAL cGLNAME := SPACE(50)
LOCAL nIDX := DEALER->(INDEXORD())
private nCLIENT := space(11)

DEALER->(ORDSETFOCUS(1))

DEALER->(DBSEEK(g_PAR_BRCH))
cGLNAME := DEALER->DLRNAME
DEALER->(ORDSETFOCUS(2))

DEALER->(ORDSETFOCUS(2))
//cDEALER := __FLOOK(.T.,'DEALER',CGLNAME+g_PAR_BRCH,'Chart of Accounts!!',2,6,1,1,,,,,g_GLS_PATH)  //PEPE 09.28.2007

cDEALER := getTranrecs(1)	//PEPE 09.28.2007
cDEALER := nCLIENT		//PEPE 09.28.2007

IF DEALER->BRCODE != g_PAR_BRCH
   ERROR('GL Code NOT found in branch '+g_PAR_BRCH)
   cDEALER := SPACE(14)
ELSE
   cDEALER := g_PAR_BRCH+ALLTRIM(cDEALER)
ENDIF

RETURN cDEALER

/*    RED 100605
************************************************
*
static function DISP_DEALER(mDLRCODE, mROW)
************************************************
   DEALER-> ( dbseek ( g_PAR_BRCH+mDLRCODE  ) )
return DEALER->DLRNAME
*/
*
*                   End of the program ( amsm107c.prg )
*
