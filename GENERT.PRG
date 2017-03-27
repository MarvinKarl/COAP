#include "COLF.CH"
#include "SETCURS.CH"
#include "INKEY.CH"

/*-------------------------*/
 Function gen_lcr()
/*-------------------------*/
 local mu:=savedbf(),mallow:=eval( { || chckalow(Acctmast->Asetcode) } )
 local mDeptot:=0,i

 center( 24, 'w+*/n', 'þþþþþþþþþþþþ Generating LCR Depreciation þþþþþþþþþþþþ' )
 dbselectarea('FACILITY')
 dbsetorder(1)
 dbseek(Acctmast->FCLTYCODE)
 if Facility->SETCODE = '1'      // generate depreciation here
    mDepdate := Acctmast->Valdate
    mDay     := Substr(dtoc(mDepdate),4,2)
    mMonth   := month(mDepdate)
    mYear    := year(mDepdate)
    for i:= 1 to mallow
	Lcrdepn->(dbappend())
	Lcrdepn->Acctno    := Acctmast->Acctno
	Lcrdepn->Monthno   := i
	Lcrdepn->Depamount := getamount( i, mallow )
	Lcrdepn->Depdate   := mdepdate
	mDeptot += Lcrdepn->Depamount
	mDepdate := getnextdate( mDepdate )
	Lcrdepn->(dbcommit())
    next i
    mFuldep := Acctmast->Principal - (Acctmast->Principal * (Acctmast->RV/100) )
    if mDeptot <> mFuldep
       mLess := mFuldep - mDeptot
       Lcrdepn->Depamount := mFuldep + ( mLess )
    endif
 endif
 restdbf(mu)
return nil
/*---------------------------------*/
static function getnextdate(mdate)
/*---------------------------------*/
   if month(mdate) + 1 > 12
      mMONTH = (month(mdate) + 1) - 12
      mYEAR  = mYEAR + 1
   else
      mMONTH = month(mdate) + 1
   endif
   do case
      case ltrim(str(mMONTH)) $ '~4~6~9~11' .and. val(mDAY) = 31
	  mdate = ctod(right('00'+ltrim(str(mMONTH)),2) + '/30/' + right(str(mYEAR),4))
      case mMONTH = 2 .and. val(mDAY) > 28
	  if mYEAR/4 == int(mYEAR/4)
	     mdate = ctod(right('00'+ltrim(str(mMONTH)),2) + '/29/' + right(str(mYEAR),4))
	  else
	     mdate = ctod(right('00'+ltrim(str(mMONTH)),2) + '/28/' + right(str(mYEAR),4))
	  endif
      otherwise
	  mdate = ctod(right('00'+ltrim(str(mMONTH)),2) + '/' + mDAY + '/' + right(str(mYEAR),4))
   endcase
   return mdate

/*---------------------------*/
 static function getamount( i,mallowed )
/*---------------------------*/
return( round( ( ( Acctmast->principal -;
		 ( Acctmast->principal * Acctmast->rv / 100 ) ) *;
		 ( mallowed - ( i - 1 ) ) ) /;
	       ( ( mallowed * ( mallowed + 1 ) ) / 2 ), 0 ) )

/*---------------------------------*/
STatic Function chckalow(mAsetcode)
/*---------------------------------*/
local mu:=savedbf(),st,tl
dbselectarea('Asetcode')
dbsetorder(1)
dbseek(mAsetcode)
st := int(Asetcode->Asetlife * 12 * 0.60)
tl := max(Acctmast->Term,st )
//alert( 'life - '+str(st,2) + 'term - '+ str(Acctmast->term,2) + 'tl -'+str(tl,2) )
restdbf(mu)
return tl

////eof()///////