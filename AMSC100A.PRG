/*
 ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³   program id.........:  amsc100a.prg                                 ³
 ³   description........:  Unearned Discounted Interest spread          ³
 ³   author.............:  renan s. evangelista                         ³
 ³   date...............:  15-August '96                                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³                         U P D A T E S                                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³        Who        ³     When      ³               Why                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³                   ³               ³                                  ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include "Colf.ch"
#include "Inkey.ch"


*****************************************
function gen_udispred( mwhat )
*****************************************
local mdbf := savedbf(mdbf), mcolor := setcolor(), mscr := savescreen( ,,, )
local mterm := Acctdaly->TERM, mamort := Acctdaly->AMORT
local mprincipal := Acctdaly->PRINCIPAL, mcredamt := Acctdaly->CREDAMT
local mincent := Acctdaly->Incentive
local mstep := 0

eval( {|| Facility->(dbseek(Acctdaly->Fcltycode)) } )
mcredamt += ( Acctdaly->Rv/100 ) * Acctdaly->Principal
center( 24, 'w+*/n', '® Generating Unearned Discount Interest < Spread >... ¯' )
   do case
      case Acctdaly->Payfreq $ '12345'
           mstep := 1
           if Acctdaly -> TERMUNIT == '1'
              mterm := int(mterm / 30) + if( mterm % 30 <> 0,1,0)
           endif
           create_sked( mterm,mamort,mprincipal,mcredamt,mstep,mincent )

      case Acctdaly->PAYFREQ $ '67'            // Lumpsum
           mpaydate:= Acctdaly->Valdate
           if Facility->SETCODE $ '45'
              if Acctdaly -> TERMUNIT == '1'
                 mterm := int(mterm / 30) + if( mterm % 30 <> 0,1,0)
              endif
              crea_spred( mterm,mamort,mprincipal,mcredamt,Acctdaly->Matdate, mincent )
           else
              if Acctdaly -> TERMUNIT == '1'
                 mterm := int(mterm / 30) + if( mterm % 30 <> 0,1,0)
              endif
              create_sked( mterm,mamort,mprincipal,mcredamt,mstep,mincent )
           endif
      endcase
   restdbf(mdbf);setcolor(mcolor);restscreen(,,,,mscr)
return nil

********************************************************************************
*
static function crea_spred( mterm,mamort,mprincipal,mcredamt,mMatdate, mincent )
********************************************************************************
local mdivisor  := ( mterm * ( mterm+1 ) ) / 2, i ,org_term:=mterm
local macctno   := Acctdaly->ACCTNO, mpaydate := Acctdaly->Valdate
local mtermunit := '2', mpaynumber := 0, mintamt, mprnamt, mosbal, moldmdays
local org_int   := mCredamt - ( mPrincipal + mincent ) ,var_intr,mrefdate,tot_int:=0

var_int   := org_int / ( mMatdate-mPaydate )
moldmdays := day ( mpaydate )
mrefdate  := mpaydate
for i:= 1 to mterm
    mpaynumber++
    comp_spred(@mpaydate, @mintamt, mMatdate, var_int, org_term, i, mrefdate )
    update_skedfile  ( macctno,mpaynumber,mpaydate,mintamt,mprnamt )
    mrefdate := getrefdt(mpaydate)
    tot_int += round( mIntamt,0 )
next i
adjust_int(tot_int,org_int)
return nil

/*-----------------------------------------*/
 Static Function adjust_int(tot_int,org_int)
/*-----------------------------------------*/
 local mu:=savedbf(),ndeff := org_int-tot_int

 dbselectarea('udispred')
 if tot_int <> org_int
    Udispred->Intamt := Udispred->Intamt + (ndeff)
    dbcommit()
 endif
 restdbf(mu)
 return nil

/*---------------------------------*/
 Function getrefdt(mpaydate)
/*---------------------------------*/
 local mmonth:=month(mpaydate) + 1,myear:=year(mPaydate)

 if mmonth > 12
    mmonth := 1
    myear++
 endif
 return ctod( str(mmonth,2,0 )+'/01/'+str(myear,4,0) )



/*--------------------------------------------------------------------------------*/
 STatic Function comp_spred(mpaydate, mintamt, mMatdate, var_int, org_term, mTerm,mrefdate )
/*--------------------------------------------------------------------------------*/
 local ldate := lastday(mrefdate)

 ldate    := if(mterm < org_term , ldate, mmatdate)
 mIntamt  := round( ( ldate-mPaydate ) * var_int ,0 )
 mpaydate := ldate
 return nil

*********************************************************************
static function create_sked( mterm,mamort,mprincipal,mcredamt,mstep,mincent )
*********************************************************************
local mdivisor := ( mterm * ( mterm+1 ) ) / 2, i
local macctno := Acctdaly->ACCTNO, mpaydate := Acctdaly->Valdate, tot_int:=0
local mtermunit := '2', mpaynumber := 0, mintamt, mprnamt, mosbal, moldmdays

moldmdays  := day ( mpaydate )
for i:= mterm to 1 step - 1
    mpaynumber++
    mintamt := round( ( (mcredamt-( mprincipal+ mincent ) ) * i ) / mdivisor,0 )
    tot_int += round( mIntamt, 0 )
    update_skedfile  ( macctno  ,mpaynumber,mpaydate,mintamt,mprnamt )
    reckon_paydate   ( @mpaydate,mtermunit ,mstep, moldmdays )
next i
adjust_int(tot_int, ( mCredamt-( mprincipal + mincent) ) )
return nil

*****************************************************************
static function reckon_paydate ( mpaydate,mtermunit,mstep,olddays )
*****************************************************************
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

/*-----------------------*/
 Function Lastday( ndate )
/*-----------------------*/
 local array1_ := { 4,6,9,11 },nretval,array2_ := { 1,3,5,7,8,10,12 }
 local nmo := ltrim( str( month(ndate),2, 0 ) )
 local nda := ltrim( str( day(ndate),2, 0 ) )
 local nyr := ltrim( str( year(ndate),4, 0 ) )

 if Ascan( Array1_,month(ndate) ) <> 0
    nretval := 30
 elseif Ascan( Array2_,month(ndate ) ) <> 0
    nretval := 31
 else
    if is_leap(year(ndate))
       nretval := 29
    else
       nretval := 28
    endif
 endif
 return ctod( nmo+'/'+ltrim(str(nretval, 2, 0 ) )+'/'+nyr )

******************************************************************************
static function update_skedfile( macctno,mpaynumber,mpaydate,mintamt,mprnamt )
******************************************************************************
   //do while isholiday ( mpaydate )  ; mpaydate-- ; enddo  //Sat.|Sun.|Holidays?
   Udispred->(dbsetorder(1))
   if mpaydate != Acctdaly->MATDATE
   endif
   if Udispred->(netlock('A',0))
      Udispred->ACCTNO    := macctno
      Udispred->PAYNUM    := mpaynumber
      Udispred->PAYDATE   := mpaydate
      Udispred->INTAMT    := mintamt
      Udispred->( dbunlock() )
   endif
      Udispred->(dbcommit())
return nil

*                    End of the Program ( amsc100a.prg )
