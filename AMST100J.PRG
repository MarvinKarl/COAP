/*
 ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³   program ID.........:  amst100j.prg                                 ³
 ³   description........:  Collateral Printing                          ³
 ³   author.............:  Ariel B. Bulan                               ³
 ³   date...............:  10:35am 03-Jan-1995                          ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³                         U P D A T E S                                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³        Who        ³     When      ³               Why                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³renan evangelista  ³ 12-Jun-1996   ³ Arrange Choices/pinting of dates ³
 ³                   ³               ³ Add prepared/checked/noted by    ³
 ³abb                ³ 10.22.2004    ³ FOR ONLINE                       ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

*******************************************
*
function print_colrec(xacctno)
*******************************************
    local mrow := 7 , mleft := 2 , mrayt := 35
    xacctno:= if( xacctno == nil, ACCTDALY->BRCODE+Acctdaly->Acctno, xacctno )
    @ prow()+2 , 07     say 'Vehicle/Chattel Type : '
    @ prow()   ,pcol()  say Ctrlinfo->COLTYPE  color 'w+/gr+' pict '@X'
    @ prow()+2, mleft   say '          Model : '
    @ prow()  , pcol()  say Ctrlinfo->COLMODEL color 'w+/gr+' pict '@X'
    @ prow()  , mrayt   say '     Appraisal Date : '
    @ prow()  , pcol()  say if(!empty(Ctrlinfo->APPDATE),tran(Ctrlinfo->APPDATE,'@D'),spac(10) )  color 'w+/gr+' //pict '@D'
    //@ prow()+1, mleft   say "Deprec'ble Life : "
    //@ prow()  , pcol()  say Ctrlinfo->COLLIFE  color 'w+/gr+' pict '999.99'
    //@ prow()  , pcol()  say ' years'
    @ prow()+1, mleft   say 'Appraisal Value : '
    @ prow()  , pcol()  say Ctrlinfo->APPVALUE color 'w+/gr+' pict '999,999,999.99'
    @ prow()  , mrayt   say '          Appraiser : '
    @ prow()  , pcol()  say Ctrlinfo->APREYSER color 'w+/gr+' pict '@X'
    @ prow()+1, mleft   say '   Plate Number : '
    @ prow()  , pcol()  say Ctrlinfo->PLATENO  color 'w+/gr+' pict '@X'
    @ prow()  , mrayt   say '     Appraisal Freq : '
    @ prow()  , pcol()  say Ctrlinfo->APPFREQ  color 'w+/gr+' pict '@X'
    @ prow()  , pcol()  say ' '+ dispappfreq( Ctrlinfo->APPFREQ )
    @ prow()+1, mleft   say '  Serial Number : '
    @ prow()  , pcol()  say Ctrlinfo->SERIALNO color 'w+/gr+' pict '@X'
    @ prow()+1, mleft   say '   Motor Number : '
    @ prow()  , pcol()  say Ctrlinfo->MOTORNO  color 'w+/gr+' pict '@X'
    @ prow()  , 46      say        'Insured? : '
    @ prow()  , pcol()  say dispinsured(Ctrlinfo->INSURED) color 'w+/gr+'
    @ prow()+1, mleft   say '      CR Number : '
    @ prow()  , pcol()  say Ctrlinfo->CRNUMBER color 'w+/gr+' pict '@X'
    @ prow()  , mrayt   say '         Insured by : '
    @ prow()  , pcol()  say Ctrlinfo->INSBY    color 'w+/gr+' pict '@X'
    @ prow()+1, mleft   say '      OR Number : '
    @ prow()  , pcol()  say Ctrlinfo->CRORNO   color 'w+/gr+' pict '@X'
    @ prow()  , mrayt   say '      Insurance Co. : '
    @ prow()  , pcol()  say Ctrlinfo->INSCO    color 'w+/gr+' pict '@X'
    @ prow()  , pcol()  say '  '+ left( dispinsname( Ctrlinfo->INSCO ), 15 )
    @ prow()+1, mleft   say "   Reg'n Expiry : "
    @ prow()  , pcol()  say if(!empty(Ctrlinfo->CREXPIRY),tran(Ctrlinfo->CREXPIRY,'@D'),spac(10) ) color 'w+/gr+' //pict '@D'
    @ prow()  , mrayt   say '  Insurance Premium : '
    @ prow()  , pcol()  say Ctrlinfo->INSPREM  color 'w+/gr+' pict '999,999,999.99'
    @ prow()+1, mrayt   say '       Date Insured : '
    @ prow()  , pcol()  say if(!empty(Ctrlinfo->INSDATE),tran(Ctrlinfo->INSDATE,'@D'),spac(10) ) color 'w+/gr+' //pict '@D'
    @ prow()+1, mleft   say ' Prop. Location : '
    @ prow()  , pcol()  say left(Ctrlinfo->LOCATION,14) color 'w+/gr+' pict '@X'
    @ prow()  , mrayt+1 say 'Insurance Exp. Dt. : '
    @ prow()  , pcol()  say if(!empty(Ctrlinfo->INSEXPRY),tran(Ctrlinfo->INSEXPRY,'@D'),spac(10) ) color 'w+/gr+' //pict '@D'
    @ prow()+1, mleft   say '     TCT Number : '
    @ prow()  , pcol()  say Ctrlinfo->TCTNO    color 'w+/gr+' pict '@X'
    @ prow()  , mrayt   say '   Type of Coverage : '
    @ prow()  , pcol()  say Ctrlinfo->INSCOVER color 'w+/gr+' pict '@X'
    @ prow()  , pcol()  say ' '+dispcover( Ctrlinfo->INSCOVER )
    @ prow()+1, mleft   say 'Latest RETR No. : '
    @ prow()  , pcol()  say Ctrlinfo->RETRNO   color 'w+/gr+' pict '@X'
    @ prow()  , mrayt   say '      Policy Number : '
    @ prow()  , pcol()  say Ctrlinfo->INSPOLCY color 'w+/gr+' pict '@X'
    @ prow()+1, mleft   say 'Latest RETR Dt. : '
    @ prow()  , pcol()  say if( !empty(Ctrlinfo->RETRDATE),tran(Ctrlinfo->RETRDATE,'@D'), spac(10) ) color 'w+/gr+' //pict '@D'
    @ prow()  , mrayt   say '          OR Number : '
    @ prow()  , pcol()  say Ctrlinfo->INSOR  color 'w+/gr+' pict '@X'
    if(CheckCtrl(xacctno), print_other(xacctno), nil )
return nil
*-----------------------
 Function print_other(xacctno)
*-----------------------
local mu:=savedbf(),gf:=ctrlothr->(recno())
@ prow()+1, 1 say ''
@ prow()+1, 1 say ''
// @ prow()+1, 1 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
// @ prow()+1, 1 say '         Code    ³       Description       ³     Collateral Information        '
// @ prow()+1, 1 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
@ prow()+1, 1 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
@ prow()+1, 1 say 'Collateral Information                                                         '
@ prow()+1, 1 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'

do while CTRLOTHR->BRCODE+Ctrlothr->Acctno == xAcctno .and. !eof()
  if !deleted()
//   @ prow()+1,10 say Ctrlothr->Colacode
   //@ prow()  ,18 say '³'
//   @ prow()  ,21 say getcoladesc(Ctrlothr->Colacode)
   //@ prow()  ,44 say '³'
   @ prow()+1,01 say Ctrlothr->Colainfo pict '@X'
  endif
  Ctrlothr->(dbskip())
enddo
return nil
/*----------------------*/
Function CheckCtrl(x)
/*----------------------*/

if Ctrlothr->(Dbseek(x))
   return .t.
else
   return .f.
endif
return .t.
/*---------------------------*/
Static Function getcoladesc(xcode)
/*---------------------------*/
local ncode:=spac(20),mu:=savedbf(),bf:=colacode->(recno())
dbselectarea('Colacode')
dbsetorder(1)
if dbseek(xcode)
   ncode:=Colacode->coladesc
endif
Colacode->(dbgoto(bf))
restdbf(mu)
return ncode

/*
12345678901234567890123456789012345678901234567890123456789012345678901234567890
         1         2         3         4         5         6         7         8
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
         Code    ³       Description       ³     Collateral Information
         XXX        XXXXXXXXXXXXXXXXXXXX       XXXXXXXXXXXXXXXXXXXXXXXXX
*/
*
*                      End of the program ( Amst100j.prg )
*
