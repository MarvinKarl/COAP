/*
 ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³   program id.........:  amsc100b.prg                                 ³
 ³   description........:  Residual Value Generation <Spread>           ³
 ³   author.............:  renan c. evangelista                         ³
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
function gen_rvspred( mwhat )
*****************************************
local mdbf := savedbf(mdbf), mcolor := setcolor(), mscr := savescreen( ,,, )
local mterm := Acctdaly->TERM, mamort := Acctdaly->AMORT
local mprincipal := Acctdaly->PRINCIPAL, mcredamt := Acctdaly->CREDAMT
local mstep := 0

eval( {|| Facility->(dbseek(Acctdaly->Fcltycode)) } )
center( 24, 'w+*/n', '® Generating Residual Value < Spread >... ¯' )
if Facility->SETCODE $ '1'
   do case
      case Acctdaly->Payfreq $ '12345'
           mstep := 1
           if Acctdaly -> TERMUNIT == '1'
              mterm := int(mterm / 30) + if( mterm % 30 <> 0,1,0)
           endif
           create_sked( mterm,mamort,mprincipal,Acctdaly->RV,mstep )

      case Acctdaly->PAYFREQ $ '67'            // Lumpsum
           mpaydate:= Acctdaly->Valdate
           if Facility->SETCODE $ '45'
              if Acctdaly -> TERMUNIT == '1'
                 mterm := int(mterm / 30) + if( mterm % 30 <> 0,1,0)
              endif
              crea_spred( mterm,mamort,mprincipal,Acctdaly->RV,Acctdaly->Matdate )
           else
              if Acctdaly -> TERMUNIT == '1'
                 mterm := int(mterm / 30) + if( mterm % 30 <> 0,1,0)
              endif
              create_sked( mterm,mamort,mprincipal,Acctdaly->Rv,mstep )
           endif
      endcase
   endif
   restdbf(mdbf);setcolor(mcolor);restscreen(,,,,mscr)
return nil

*********************************************************************
static function crea_spred( mterm,mamort,mprincipal,mRv,mMatdate )
*********************************************************************

local mdivisor  := ( mterm * ( mterm+1 ) ) / 2, i ,org_term:=mterm
local macctno   := Acctdaly->ACCTNO, mpaydate := Acctdaly->Valdate
local mtermunit := '2', mpaynumber := 0, mrvamt, mprnamt, mosbal, moldmdays
local org_int   := ( mRv/100 ) * mPrincipal,var_int,mrefdate,tot_int:=0

var_int := org_int / ( mMatdate-mPaydate )
moldmdays  := day ( mpaydate )
mrefdate := mpaydate
for i:= 1 to mterm
    mpaynumber++
    comp_spred(@mpaydate, @mrvamt, mMatdate, var_int, org_term, i, mrefdate )
    update_skedfile  ( macctno,mpaynumber,mpaydate,mrvamt,mprnamt )
    mrefdate := getrefdt(mpaydate)
    tot_int += round( mrvamt,0 )
next i
adjust_int(tot_int,org_int)
return nil

/*-----------------------------------------*/
 Static Function adjust_int(tot_int,org_int)
/*-----------------------------------------*/
 local mu:=savedbf(),ndeff := org_int-tot_int

 dbselectarea('Rvspread')
 if tot_int <> org_int
    Rvspread->rvamt := Rvspread->rvamt + (ndeff)
    dbcommit()
 endif
 restdbf(mu)
 return nil

/*---------------------------------*/
 Static Function getrefdt(mpaydate)
/*---------------------------------*/
 local mmonth:=month(mpaydate) + 1,myear:=year(mPaydate)

 if mmonth > 12
    mmonth := 1
    myear++
 endif
 return ctod( str(mmonth,2,0 )+'/01/'+str(myear,4,0) )



/*--------------------------------------------------------------------------------*/
 STatic Function comp_spred(mpaydate, mrvamt, mMatdate, var_int, org_term, mTerm,mrefdate )
/*--------------------------------------------------------------------------------*/
 local ldate := lastday(mrefdate)

 ldate    := if(mterm < org_term , ldate, mmatdate)
 mrvamt  := round( ( ldate-mPaydate ) * var_int ,0 )
 mpaydate := ldate
 return nil

*********************************************************************
static function create_sked( mterm,mamort,mprincipal,mRv,mstep )
*********************************************************************
local mdivisor := ( mterm * ( mterm+1 ) ) / 2, i
local macctno := Acctdaly->ACCTNO, mpaydate := Acctdaly->Valdate,tot_int:=0
local mtermunit := '2', mpaynumber := 0, mrvamt, mprnamt, mosbal, moldmdays
local org_int := (mRv/100) * mPrincipal

moldmdays  := day ( mpaydate )
for i:= mterm to 1 step -1
    mpaynumber++
    mrvamt := round( ( (org_int) * i ) / mdivisor,0 )
    tot_int += round( mrvamt, 0 )
    update_skedfile  ( macctno  ,mpaynumber,mpaydate,mrvamt,mprnamt )
    reckon_paydate   ( @mpaydate,mtermunit ,mstep, moldmdays )
next i
adjust_int(tot_int, org_int)
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

******************************************************************************
static function update_skedfile( macctno,mpaynumber,mpaydate,mrvamt,mprnamt )
******************************************************************************
   //do while isholiday ( mpaydate )  ; mpaydate-- ; enddo  //Sat.|Sun.|Holidays?
   if mpaydate != Acctdaly->MATDATE
   endif
   if Rvspread->(netlock('A',0))
      Rvspread->ACCTNO    := macctno
      Rvspread->PAYNUM    := mpaynumber
      Rvspread->PAYDATE   := mpaydate
      Rvspread->rvamt    := mrvamt
      Rvspread->( dbunlock() )
   endif
      Rvspread->(dbcommit())
return nil
*********************
////end of amsc100b.prg
