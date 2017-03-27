/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   program ID.........:  amst100f.prg                                         ³
³   description........:  Printing of Schedule of Payment                      ³
³   date...............:  02:33pm 29-Nov-1994                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                         U P D A T E S                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        Who        ³     When      ³               Why                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ abb               ³    06.11.2002 ³ copied udi/alir generation from          ³
³                   ³               ³ amsc100c.prg ( interest method )         ³
³                   ³               ³                                          ³
³ jbs               ³  04.22.2003   ³ truerate is inclusive of 10% vat         ³
³                   ³               ³ effective 04.01.03, so we divide         ³
³                   ³               ³ truerate by 1.1 to get netrate           ³
³ ABB               ³  10.21.2004   ³ FOR ONLINE                               ³
³ aga               ³  14.02.2007   ³ neo paysked support for modules          ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include "Colf.ch"
#include "Inkey.ch"

****************************************
*
function print_sked ( macctno )
****************************************
 if !chkpass( procname(),AX_LEVEL,g_USER_ID )
   RETURN NIL
 ENDIF

 reportprint('printschedule()',,,8,33)
 *repcon_ol('printschedule()',,,8,33,,,.F.)
 *repcon_ol('printschedule()',,,8,33,,,.F.)
return nil
****************************************
*
function printschedule()
****************************************
   local  mdbf     := savedbf ( mdbf )
   local  mdivisor := ( Acctdaly->TERM*(Acctdaly->TERM+1) ) / 2
   local  mosbal   := Acctdaly->CREDAMT
   //LOCAL  mudi     := Acctdaly->Credamt - ( Acctdaly->Principal + Acctdaly->Incentive )
   //LOCAL  MRV      := ( Acctdaly->RV/100 ) * Acctdaly->Principal
   private mpage   := 1, mterm:=Acctdaly->Term
   setprc ( 0, 0 )
   heading(mpage )

//aga.29.05.2006.marked for modification
   Paytsked-> ( dbseek(Acctdaly->brcode+Acctdaly->ACCTNO+'D') )
   devpos( prow()+1, 47 )
   devoutpict( mosbal , "99,999,999,999.99" )
   Paytsked-> ( dbeval ( {||  print_rec( @mOsbal ) },,;
                         {|| !Paytsked->(eof()) .and. ;
                            Paytsked->ACCTNO == Acctdaly->ACCTNO .and.;
                            Paytsked->brcode == Acctdaly->brcode ;
                         };
                       );
              )
//.....................................

   __eject()

   setfont('NORMAL')
   restdbf   ( mdbf )
return nil
*********************************************
*
static function print_rec( mOsbal )
*********************************************
   //static mosbal := 0
   local  mcol     := { 11,17,30,47 }
   memvar mpage

//aga.29.05.2006.marked for modification
   mOsbal -= Paytsked->Amtdue
   @ prow()+1, mcol[1] say Paytsked ->PAYNUMBER  pict '999'
   @ prow()  , mcol[2] say Paytsked ->PAYDATE    pict '@D'
   @ prow()  , mcol[3] say Paytsked ->Amtdue     pict '999,999,999.99'
   @ prow()  , mcol[4] say mosbal                pict '99,999,999,999.99'
//....................................

   if( prow()>56, eval({|| __eject(),mpage++, heading(mpage) }), nil )
   mterm--
   
return nil
****************************************
*
static function heading( mpage,sw )
****************************************
   memvar gcompany, gsys_name, gheadmess
   local  mtitle  :=  'PAYMENT SCHEDULE'
   sw := if(sw == nil,.t.,sw )
   mtitle  := if(sw, 'PAYMENT SCHEDULE','ALIR/UDI SCHEDULE' )
   setprc ( 0, 0 )
   prnreptitle(80,00,mpage,mtitle,'Amst100f',gsys_name,gcompany)
   print_head()
   print_subhead( sw )
return nil
****************************************
*
static function print_subhead( SW )
****************************************
   local mleft := 17
   *          1         2         3         4         5         6         7         8         9         0         1         2         3
   *01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
   *           999   99/99/9999   999,999,999.99   99,999,999,999.99
   *                 ÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   *                  MATURITY        ALIR/            ALIR/UDI
   *                    DATE           UDI             BALANCE                                                        '
   *                 ÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   *           999   99/99/9999   999,999,999.99   99,999,999,999.99
   *           11    17           30               47
   *  { 11,17,30,47 }
   sw := if( sw == nil, .t., sw )
   setfont( 'PICA' )
   if sw
      @ prow()+2, mleft say  'ÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
      @ prow()+1, mleft say  ' PAYMENT      AMORTIZATION/      O/S BALANCE   '
      @ prow()+1, mleft say  '  DATE           RENTAL                        '
      @ prow()+1, mleft say  'ÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   else
      @ prow()+2, mleft say  'ÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
      @ prow()+1, mleft say  ' MATURITY         ALIR/           ALIR/UDI     '
      @ prow()+1, mleft say  '   DATE            UDI            BALANCE      '
      @ prow()+1, mleft say  'ÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   endif
return nil

****************************************
*
static function print_head()
****************************************

   @ prow()+2, 00     say 'Account Number     : '
   @ prow()  , pcol() say ACCTDALY->BRCODE+Acctdaly->ACCTNO    pict '@R 999-9999-99999-99999'
   @ prow()  , 53     say 'Availment Date : '
   @ prow()  , pcol() say dtoc(Acctdaly->VALDATE)

   @ prow()+1, 00     say 'Client Code/Name   : '
   @ prow()  , pcol() say ACCTDALY->BRCODE+Acctdaly->CLNTCODE  pict '@R 999-99-99999'
   @ prow()  , pcol() say ' '+upper(dispclntname(ACCTDALY->BRCODE+Acctdaly->CLNTCODE,40))

   @ prow()+1, 00     say 'Facility Code/Name : '
   @ prow()  , pcol() say Acctdaly->FCLTYCODE pict '@R 999-99'
   @ prow()  , pcol() say '   '+ dispfcltyname(Acctdaly->FCLTYCODE)

   @ prow()+1, 00     say 'Net Proceeds       : '
   @ prow()  , pcol() say ltrim(transform (Acctdaly->PRINCIPAL,'999,999,999.99'))

   @ prow()+1, 00     say 'Term               : '
   @ prow()  , pcol() say ltrim(transform (Acctdaly->TERM,'999'))
   @ prow()  , pcol() say space(7) + if(Acctdaly->TERMUNIT $ '12', if( Acctdaly->TERMUNIT=='1','DAYS    ','MONTH(S)'),space(8))

   @ prow()+1, 00     say 'True Rate          : '
   @ prow()  , pcol() say Acctdaly->TRUERATE   pict '99.99999'
   @ prow()  , pcol() say ' '+upper (dispratetype(Acctdaly->RATETYPE))

return nil
/*-------------------------------*/
function prn_udisprd( xAcctno )
/*-------------------------------*/
if chkpass( procname(),ax_level,g_user_id )
   reportprint( 'fPrintudi1()' )

   *repcon_ol( 'fPrintudi1()',,,,,,,.F. )
endif
return nil

/*-----------------------*/
 Function fPrintudi1()
/*-----------------------*/
local mdbf := select()
local mcolor := setcolor()
local mterm := Acctdaly->TERM, mamort := Acctdaly->AMORT
local mprincipal := Acctdaly->PRINCIPAL, mcredamt := Acctdaly->CREDAMT
local mstep := 0,mincent := Acctdaly->Incentive
private mpage := 1
heading     ( mpage,.f. )

if substr(Acctdaly->acctno,5,3) == '104'                                      //pepe 4:57 PM 11/29/2011
   mcredamt := mcredamt + ( 0 /100 ) * Acctdaly->Principal // ZERO RV
else
   mcredamt := mcredamt + ( Acctdaly->Rv/100 ) * Acctdaly->Principal
endif

//pepe 4:57 PM 11/29/2011 mcredamt += ( Acctdaly->Rv/100 ) * Acctdaly->Principal

devpos      ( prow()+1, 47 )
// devoutpict  ( mcredamt-( mprincipal + mincent ), "99,999,999,999.99" )

//pepe 5:17 PM 9/2/2011  devoutpict  ( round((mcredamt-( mprincipal + mincent )),0), "99,999,999,999.99" )

devoutpict  ( round((mcredamt-( mprincipal + mincent + Acctdaly->WTAX )),0), "99,999,999,999.99" )

// remove / 1.1 abb 03.23.2004
// devoutpict  ( round((mcredamt-( mprincipal + mincent ))/1.1,0), "99,999,999,999.99" )
// divide by 1.1 jbs 04.22.2003

/*
   alert ( trans ( mcredamt-( mprincipal + mincent ), "99,999,999,999.99" ) )

alert ( '1' + trans ( mcredamt   , "99,999,999,999.99" ) )
alert ( '2' + trans ( mprincipal , "99,999,999,999.99" ) )
alert ( '3' + trans ( mincent    , "99,999,999,999.99" ) )
alert ( '4' + trans ( Acctdaly->rv, "99,999,999,999.99" ) )
*/

eval( {|| Facility->(dbseek(Acctdaly->Fcltycode)) } )
   do case
      case Acctdaly->Payfreq $ '12345'
           mstep := 1
           if Acctdaly -> TERMUNIT == '1'
              mterm := int(mterm / 30) + if( mterm % 30 <> 0,1,0)
           endif

           fPrnudi002( mterm,mamort,mprincipal,mcredamt,mstep,mincent )

      case Acctdaly->PAYFREQ $ '67'            // Lumpsum
           // mpaydate:= Acctdaly->firstdue
           mpaydate:= Acctdaly->valdate
           if Facility->SETCODE $ '45'
              if Acctdaly -> TERMUNIT == '1'
                 mterm := int(mterm / 30) + if( mterm % 30 <> 0,1,0)
              endif
              fPrn_udinow( mterm,mamort,mprincipal,mcredamt,Acctdaly->Matdate,mincent )
           else
              if Acctdaly -> TERMUNIT == '1'
                 mterm := int(mterm / 30) + if( mterm % 30 <> 0,1,0)
              endif
              fPrnudi002( mterm,mamort,mprincipal,mcredamt,mstep,mincent )
           endif
      endcase
     __eject()
   dbselectarea(mdbf);setcolor(mcolor)
return nil

*********************************************************************
static function fPrn_udinow( mterm,mamort,mprincipal,mcredamt,mMatdate,mincent )
*********************************************************************
local mdivisor  := ( mterm * ( mterm+1 ) ) / 2, xix ,org_term:=mterm,udiamt //udibal
// local macctno   := Acctdaly->ACCTNO, mpaydate := Acctdaly->firstdue,ndeff

local macctno   := Acctdaly->ACCTNO, mpaydate := Acctdaly->valdate,ndeff
local mtermunit := '2', mpaynumber := 0, mintamt, mprnamt, mosbal, moldmdays

// local org_int   := mCredamt - ( mPrincipal + mincent ) ,var_intr,mrefdate,tot_int:=0

local org_int   := round((mCredamt - ( mPrincipal + mincent )),0),var_intr,mrefdate,tot_int:=0

// local org_int   := round((mCredamt - ( mPrincipal + mincent ))/1.1,0),var_intr,mrefdate,tot_int:=0
//udibal  := org_int

local __nbalance   := udiamt  //aga.21.11.2007.__nbalance parameter

//udiamt  := org_int
if Acctdaly->UDIAMT > 0
   udiamt      := Acctdaly->UDIAMT
   __nbalance  := Acctdaly->UDIAMT
else
   udiamt     := round((Acctdaly->CREDAMT - ( Acctdaly->PRINCIPAL + Acctdaly->INCENTIVE + Acctdaly->WTAX)),2)
   __nbalance := round((Acctdaly->CREDAMT - ( Acctdaly->PRINCIPAL + Acctdaly->INCENTIVE + Acctdaly->WTAX)),2)
endif

var_int := org_int / ( mMatdate-mPaydate )
moldmdays  := day ( mpaydate )
mrefdate := mpaydate


for xix := 1 to mterm
    mpaynumber++
    comp_spred( @mpaydate, @mintamt, mMatdate, var_int, org_term, xix, mrefdate, mincent )
    tot_int += round( mIntamt,0 )

    if xix == mterm .and. tot_int <> org_int
       ndeff := org_int - tot_int
       mintamt += ( ndeff )
    endif

    //udibal -= mintamt

    __nbalance := udiamt  //aga.21.11.2007.__nbalance assign

    udiamt -= mintamt

    //fprnudi01( macctno,mpaynumber,mpaydate,mintamt,udibal )

    //fprnudi01( macctno,mpaynumber,mpaydate,mintamt,udiamt)
    fprnudi01( macctno,mpaynumber,mpaydate,mintamt,udiamt,__nbalance )  //aga.21.11.2007.__nbalance missing

    mrefdate := getrefdt( mpaydate )
next xix

//adjust_int( tot_int,org_int)

return nil

/*--------------------------------------------------------------------------------*/
 STATIC Function comp_spred(mpaydate, mintamt, mMatdate, var_int, org_term, mTerm,mrefdate )
/*--------------------------------------------------------------------------------*/
 local ldate := lastday(mrefdate)

 ldate    := if(mterm < org_term , ldate, mmatdate)
 mIntamt  := round( ( ldate-mPaydate ) * var_int ,0 )
 mpaydate := ldate
 return nil

*********************************************************************
STATIC function fPrnudi002( mterm,mamort,mprincipal,mcredamt,mstep, mincent )
*********************************************************************
local mdivisor := ( mterm * ( mterm+1 ) ) / 2, xix,udiamt  //udibal
// local macctno := Acctdaly->ACCTNO, mpaydate := Acctdaly->firstdue, tot_int:=0
local macctno := Acctdaly->ACCTNO, mpaydate := Acctdaly->valdate, tot_int:=0
local mtermunit := '2', mpaynumber := 0, mintamt, mprnamt, mosbal, moldmdays
local org_int := round((mCredamt - ( mprincipal + mincent )),0),ndeff
// local org_int := round((mCredamt - ( mprincipal + mincent ))/1.1,0),ndeff
local __nprincipal := 0, __npbalance := 0, __noldbal := 0, nsum := 0
local __nbalance   := udiamt

if Acctdaly->UDIAMT > 0
   udiamt := Acctdaly->UDIAMT
else
   //udiamt := round((mCredamt - ( mprincipal + mincent )),0)

//alert("udiamt: "+str(mCredamt)+' '+str(Acctdaly->principal)+' '+str(Acctdaly->incentive)+' '+str(Acctdaly->wtax))

   udiamt := round((mCredamt - ( Acctdaly->principal + Acctdaly->incentive + Acctdaly->wtax )),0) 
   
endif
//alert("udiamt: "+str(udiamt))
moldmdays  := day ( mpaydate )

if substr(Acctdaly->acctno,5,3) == '104'
   //__nprincipal := Acctdaly->principal + Acctdaly->incentive    // jbs 09.06.2002
   __nprincipal := Acctdaly->principal + Acctdaly->incentive +  Acctdaly->wtax   // pepe 5:10 PM 9/2/2011
else
   __nprincipal :=   Acctdaly->principal- ( (Acctdaly->gd/100) * Acctdaly->principal )
endif

//alert("__nprincipal: "+str(__nprincipal))

if ACCTDALY->PAYTYPE = '1'                           /// jbs 09.06.2002
   __nprincipal := __nprincipal - ACCTDALY->AMORT
endif

//alert("term "+str(mterm))

for xix := mterm to 1 step - 1

    mpaynumber++

//     mintamt      := round( __nprincipal * (Acctdaly->truerate/100/1.1)  / 12, 0 )   // jbs 04.22.2003

    if ACCTDALY->INCENTIVE <> 0  .OR. ACCTDALY->WTAX <> 0                       // jbs 02.06.2003
//        mintamt      := round( __nprincipal * (Acctdaly->nerate/100/1.1)  / 12, 0 )

       mintamt      := round( __nprincipal * (Acctdaly->nerate/100)  / 12, 0 )
	   
    else
//      mintamt      := round( __nprincipal * (Acctdaly->truerate/100/1.1)  / 12, 0 )

      mintamt      := round( __nprincipal * (Acctdaly->truerate/100)  / 12, 0 )
	  
    endif
	
    __npbalance  := Acctdaly->amort - mintamt
    __nprincipal := __nprincipal    - __npbalance

	
//alert("udiamt: "+str(udiamt)+' '+"mintamt: "+str(mintamt))

    __nbalance := udiamt
    udiamt     -= mintamt
    nsum       := nsum + mintamt

    fprnudi01       ( macctno  ,mpaynumber,mpaydate,mintamt,udiamt,__nbalance )
    spred_matdate   ( @mpaydate,mtermunit ,mstep   ,moldmdays )

    if udiamt < 0
       xix := 1
    endif

next xix

return nil

******************************************************************
*
static function spred_matdate ( mpaydate,mtermunit,mstep,olddays )
******************************************************************
local mmonth := month( mpaydate ), myear := year( mpaydate )
local mdays  := olddays, i ,array1_:= { 4,6,9,11 }

do case
   case mtermunit == '1'   // days
        mpaydate++
   case mtermunit == '2'   // months
        mmonth += mstep
        if mmonth > 12
           myear++
           mmonth-=12 
        endif
        if mmonth == 2                         // February ???
           if is_leap(myear)                   // 29 ???
              mdays := if( mdays > 28,29,mdays )
           else
              mdays := if( mdays>=28,28,mdays )
           endif
        ELSE
           if mdays > 30
              mdays := if( ascan( array1_, mmonth ) <> 0, 30, 31 )
           endif
        endif
        mpaydate := ctod( ltrim( str( mmonth, 2, 0 ) ) + '/' +;
                          ltrim( str( mdays , 2, 0 ) ) + '/' +;
                          ltrim( str ( myear, 4, 0 ) ) )
    endcase
return .t.
***********************************************************************************
*
static function fprnudi01( macctno,mpaynumber,mpaydate,mintamt,udiamt,__nbalance )
***********************************************************************************
 local ncol_:= { 11,17,30,47 }

 @ prow()+1, ncol_[1] say trans( mpaynumber,'999' )
 @ prow()  , ncol_[2] say dtoc(mpaydate)

 if udiamt < 0
    @ prow()  , ncol_[3] say trans( round(__nbalance,0),'999,999,999.99' )
    @ prow()  , ncol_[4] say trans( round(0,0), '99,999,999,999.99' )
 else

   if mpaynumber == Acctdaly->term
      @ prow()  , ncol_[3] say trans( round(__nbalance,0),'999,999,999.99' )
      @ prow()  , ncol_[4] say trans( round(0,0), '99,999,999,999.99' )
   else
      @ prow()  , ncol_[3] say trans( round(mintamt,0),'999,999,999.99' )
      @ prow()  , ncol_[4] say trans( udiamt, '99,999,999,999.99' )

   endif
 endif

 if prow() > 56
    __eject()
    mpage++
    heading ( mpage,.f. )
 endif
 return nil
*                     End of the program ( amst100f.prg )
*
