/*
 ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
 º   program id.........:  amsc100c.prg                                 º
 º   description........:  UDI/ALIR generation ( Interest Method )      º
 º   author.............:  ariel b. bulan                               º
 º   date...............:  September 12, 2000                           º
 º   last update........:  June 5, 2002                                 º
 ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶
 º                         U P D A T E S                                º
 ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶
 º        Who        ³     When      ³               Why                º
 ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶
 º abb               ³  jun 05 2002  ³ spread is different from account º
 º                   ³               ³ execution printout               º
 º                   ³               ³                                  º
 º abb               ³  jun 11 2002  ³ modified computation of udialir  º
 º                   ³               ³ based on interest method         º
 º                   ³               ³                                  º
 º jbs               ³  sep 06 2002  ³ consider paytype: if advance,    º
 º                   ³               ³ deduct amort on beg principal    º
 º                   ³               ³                                  º
 º                   ³               ³ add incentive on beg principal   º
 º                   ³               ³                                  º
 º jbs               ³  feb 06 2003  ³ use net effective rate on cml    º
 º                   ³               ³ with incentive                   º
 º                   ³               ³                                  º
 º abb               ³  10.18.2004   ³ FOR ONLINE USE                   º
 ÇÒ·Ö·Ö·Ö·Ö·Ö·Ö·Ö·Ö·ÖÅ·Ö·Ö·Ö·Ö·Ö·Ö·ÖÒÅ·Ö·Ö·Ö·Ö·Ö·Ö·Ö·Ö·Ö·Ö·Ö·Ö·Ö·Ö·Ö·Ö·Ö¶
 ÓĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞÁĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞÁĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞĞ½
*/

#include "Colf.ch"
#include "Inkey.ch"

private __nudiamt
/*-----------------------*/
 Function _gen_udi_alir()
/*-----------------------*/
local mdbf := select()
local mcolor := setcolor()
local mterm := Acctdaly->TERM, mamort := Acctdaly->AMORT
local mprincipal := Acctdaly->PRINCIPAL, mcredamt := Acctdaly->CREDAMT
local mstep := 0,mincent := Acctdaly->Incentive
private mpage := 1

__nudiamt := 0
// heading     ( mpage,.f. )

if substr(Acctdaly->acctno,5,3) == '104'
   mcredamt := mcredamt + ( 0 /100 ) * Acctdaly->Principal // ZERO RV
else
   mcredamt := mcredamt + ( Acctdaly->Rv/100 ) * Acctdaly->Principal
endif


__nudiamt := round( mcredamt-( mprincipal + mincent ) , 0 )
// __nudiamt := round( (mcredamt-( mprincipal + mincent )) / 1.1, 0 ) // abb  06.30.2003


if Acctmast->(dbseek(Acctdaly->brcode+Acctdaly->acctno))

   if Acctdaly->vatincl                 // abb  07.24.2003
//       __nudiamt := round ( __nudiamt / 1.1, 0 )
//
      __nudiamt := round ( __nudiamt, 0 )      // abb 04.23.2004
   endif

   Acctmast->udiamt := round ( __nudiamt , 0 )
   Acctmast->udibal := round ( __nudiamt , 0 )

endif

if substr(Acctdaly->acctno,5,3) == '104'        // udi  (09/16/2000)

     if !udi->(dbseek(Acctdaly->brcode+Acctdaly->acctno))
        udi->(dbappend())
     endif

     udi->brcode := Acctdaly->brcode         // abb 10.18.2004

     udi->acctno := Acctdaly->acctno

     udi->acctno := Acctdaly->acctno
     udi->oldno  := Acctdaly->acctno
     udi->d1     := Acctdaly->acctno
     udi->d2     := Acctmast->acctname
     udi->d3     := 0     // beginning

     if Acctdaly->vatincl                 // abb  06.06.2003
        udi->d4     :=  round (  __nudiamt , 0 ) // abb 09.05.2003
     else
        udi->d4     :=  round ( __nudiamt, 0 )
     endif

     udi->d5     := 0          // no income yet      (09/16/2000)
                                     // it should be filled in
                                     // GLS closing, asking user if
                                     // he wants to generate income, if yes
                                     // then fill this field using the
                                     // flag->udidate+ 1 month as basis for the
                                     // month of income

     udi->d6      := 0          // ending balance, also from GLS closing
     udi->valdate := Acctmast->valdate
     udi->term    := Acctmast->term

else                                   // alir (09/16/2000)

     if !alir->(dbseek(Acctdaly->brcode+Acctdaly->acctno))
        alir->(dbappend())
     endif

      alir->brcode := Acctdaly->brcode          // abb 10.18.2004

      alir->acctno := Acctdaly->acctno
      alir->oldno  := Acctdaly->acctno
      alir->d1     := Acctdaly->acctno
      alir->d2     := Acctmast->acctname
      alir->d3     := 0         // beginning

      if Acctdaly->vatincl           // abb 06.06.2003
         alir->d4     := round ( __nudiamt , 0 )   // abb 09.05.2003
      else
         alir->d4     := round ( __nudiamt, 0 )
      endif

      alir->d5     := 0         // no income yet         (09/16/2000)
                                // it should be filled in
                                // GLS closing, asking user if
                                // he wants to generate income, if yes
                                // then fill this field using the
                                // flag->udidate+1 month as basis for the
                                // month of income

     alir->d6      := 0          // ending balance, also from GLS closing
     alir->valdate := Acctmast->valdate
     alir->term    := Acctmast->term

endif      // substr(Acctdaly->acctno,1,3) == '104'        // udi  (09/16/2000)


eval( {|| Facility->(dbseek(Acctdaly->Fcltycode)) } )
   do case
      case Acctdaly->Payfreq $ '12345'
           mstep := 1
           if Acctdaly -> TERMUNIT == '1'
              mterm := int(mterm / 30) + if( mterm % 30 <> 0,1,0)
           endif

           fPrnudi002( mterm,mamort,mprincipal,mcredamt,mstep,mincent )

      case Acctdaly->PAYFREQ $ '67'            // Lumpsum

           //mpaydate:= Acctdaly->firstdue
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
              fPrnudi002 ( mterm,mamort,mprincipal,mcredamt,mstep,mincent )
           endif

      endcase
     // __eject ()

   dbselectarea (mdbf)
   setcolor     (mcolor)

return nil

*********************************************************************-
static function fPrn_udinow( mterm,mamort,mprincipal,mcredamt,mMatdate,mincent )
*********************************************************************

local mdivisor  := ( mterm * ( mterm+1 ) ) / 2, xix ,org_term:=mterm,udiamt //udibal
//local macctno   := Acctdaly->ACCTNO, mpaydate := Acctdaly->firstdue,ndeff
local macctno   := Acctdaly->ACCTNO, mpaydate := Acctdaly->valdate,ndeff
local mtermunit := '2', mpaynumber := 0, mintamt, mprnamt, mosbal, moldmdays
local org_int   := mCredamt - ( mPrincipal + mincent ) ,var_intr,mrefdate,tot_int:=0
//udibal  := org_int
udiamt  := org_int
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
    udiamt -= mintamt
    //fprnudi01( macctno,mpaynumber,mpaydate,mintamt,udibal )
    fprnudi01( macctno,mpaynumber,mpaydate,mintamt,udiamt )
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

******************************************************************************
*
STATIC function fPrnudi002( mterm,mamort,mprincipal,mcredamt,mstep, mincent )
******************************************************************************
local mdivisor := ( mterm * ( mterm+1 ) ) / 2, xix,udiamt  //udibal
// local macctno := Acctdaly->ACCTNO, mpaydate := Acctdaly->firstdue, tot_int:=0
local macctno := Acctdaly->ACCTNO, mpaydate := Acctdaly->valdate, tot_int:=0
local mtermunit := '2', mpaynumber := 0, mintamt, mprnamt, mosbal, moldmdays
local org_int := round( mCredamt - ( mprincipal + mincent ),0 ),ndeff,nsum := 0
local __nprincipal := 0, __npbalance := 0, __noldbal := 0

********* __nudiamt := round( mcredamt-( mprincipal + mincent ) , 0 )
//udibal := org_int
// udiamt := org_int

udiamt := __nudiamt
moldmdays  := day ( mpaydate )

if substr(Acctdaly->acctno,5,3) == '104'
   __nprincipal := Acctdaly->principal + Acctdaly->incentive    // jbs 09.06.2002
else
   __nprincipal :=   Acctdaly->principal- ( (Acctdaly->gd/100) * Acctdaly->principal )
endif


if ACCTDALY->PAYTYPE = '1'                           /// jbs 09.06.2002
   __nprincipal := __nprincipal - ACCTDALY->AMORT
endif

// alert ( '2' + trans( __nprincipal,"999,999,999.99"))

for xix := mterm to 1 step - 1

    mpaynumber++
    if ACCTDALY->INCENTIVE <> 0                        // jbs 02.06.2003
       mintamt      := round( __nprincipal * (Acctdaly->nerate/100)  / 12, 0 )
    else
      mintamt      := round( __nprincipal * (Acctdaly->truerate/100)  / 12, 0 )
    endif

//     alert( '3' + trans(mintamt,"999,999,999.99") )
 
    if ACCTDALY->INCENTIVE <> 0                        // jbs 02.06.2003
//        mintamt      := round( __nprincipal * (Acctdaly->nerate/100/1.1)  / 12, 0 )

       mintamt      := round( __nprincipal * (Acctdaly->nerate/100)  / 12, 0 ) // abb 03.23.2004
    else
//       mintamt      := round( __nprincipal * (Acctdaly->truerate/100/1.1)  / 12, 0 )

       mintamt      := round( __nprincipal * (Acctdaly->truerate/100)  / 12, 0 )  // abb 03.23.2004
    endif

    __npbalance  := Acctdaly->amort - mintamt
    __nprincipal := __nprincipal    - __npbalance

    __npbalance  := udiamt
    udiamt -= mintamt
    nsum := nsum + mintamt

    fprnudi01       ( macctno  ,mpaynumber,mpaydate,mintamt,udiamt )
    spred_matdate   ( @mpaydate,mtermunit ,mstep   ,moldmdays )

    if udiamt < 0
       xix := 1
    endif

next xix

if __nudiamt > nsum  // mas malaki yung computed accrual vs. acctmast->udiamt
   udispred->intamt := udispred->intamt + (__nudiamt - nsum)
endif

**
**
**  REMOVE ZEROES ( 06.05.2002 )
**
**

if udispred->(dbseek(Acctdaly->brcode+Acctdaly->acctno))

   do while udispred->acctno == Acctdaly->acctno .and. !Udispred->(eof()) .and. ;
            udispred->brcode == Acctdaly->brcode

      __noldbal := __nudiamt
      __nudiamt := __nudiamt - Udispred->intamt

      if __nudiamt < 0
         udispred->intamt  := abs(__noldbal)
         Udispred->(dbskip(+1))
         do while udispred->acctno == Acctdaly->acctno .and. !Udispred->(eof())
            Udispred->intamt  := 0
            Udispred->(dbskip(+1))
         enddo
         loop
      endif
      Udispred->(dbskip(+1))

   enddo


endif

return nil

********************************************************************
*
static function spred_matdate ( mpaydate,mtermunit,mstep,olddays )
********************************************************************
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
/*------------------------------------------------------------------------*/
 Static Function fprnudi01( macctno,mpaynumber,mpaydate,mintamt,_udiamt )
/*------------------------------------------------------------------------*/
 local ncol_:= { 11,17,30,47 }

 udispred->(dbappend())
 udispred->brcode  := Acctdaly->brcode
 udispred->acctno  := Acctdaly->acctno
 udispred->oldno   := Acctdaly->acctno
 udispred->paynum  := mpaynumber
 udispred->paydate := mpaydate
 udispred->intamt  := round(mintamt,0)

 return nil

