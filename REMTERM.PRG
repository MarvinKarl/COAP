***************************************
*
static function _get_remterm(cacctno,dpaydate)
***************************************
local nntx    := Acctmast->(indexord()),nrecno := Acctmast->(recno())
local cretval := space (5),nremterm := 0,cret2 := ' '
Acctmast->(dbsetorder(1))              // account number
Acctmast->(dbseek(cacctno))

Paysked->(dbseek(cacctno+dtos(dpaydate),.t.))

if Paysked->paynum != 0 .and. Paysked->acctno == cacctno
   nremterm := Paysked->paynum
else
   Payimage->(dbseek(cacctno+dtos(dpaydate),.t.))

   if Payimage->acctno == cacctno
      nremterm := Payimage->paynum
   endif

endif

cretval := padl(alltrim(str(nremterm)),3)+'/'

if Acctmast->term <= 72
   cret2   := padr(alltrim(str(Acctmast->term)),3)
else
   cret2   := padr(alltrim(str(_get_term(Acctmast->acctno))),3)
endif
cretval := cretval + cret2

Acctmast->(dbsetorder(nntx))
Acctmast->(dbgoto(nrecno))
return cretval

***************************************
*
static function _get_term(cacctno)
***************************************
local nntx    := Acctmast->(indexord()),nrecno := Acctmast->(recno())
local nretval := 0
Acctmast->(dbsetorder(1))              // account number
Acctmast->(dbseek(cacctno))

if Payimage->(dbseek(cacctno))

   do while Payimage->acctno == cacctno .and. !Payimage->(eof())
      nretval++
      Payimage->(dbskip(+1))
   enddo

endif

Acctmast->(dbsetorder(nntx))
Acctmast->(dbgoto(nrecno))
return nretval
