/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³   program ID.........:  amst100j.prg                                 ³
 ³   description........:  Initial Cash Outlay Printing                 ³
 ³   author.............:  Ariel B. Bulan                               ³
 ³   date...............:  10:35am 03-Jan-1995                          ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³                         U P D A T E S                                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³        Who        ³     When      ³               Why                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³                   ³               ³                                  ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

************************************
*
function print_cout()
************************************
   local mcol := { 01,5,27,44,47,70 }
   @ prow()+1, mcol[1] say Cashout->PAYCODE   pict '@X'
   @ prow()  , mcol[2] say left(disppayname(Cashout->PAYCODE),20) pict '@X'
   @ prow()  , mcol[3] say Cashout->AMOUNT    pict '999,999,999.99'
   @ prow()  , mcol[4] say Cashout->REFCODE   pict '@X'
   @ prow()  , mcol[5] say upper( if( Cashout->REFCODE $ '12',if(Cashout->REFCODE=='1','Official Receipt','Journal Voucher'),' ' ) )
   @ prow()  , mcol[6] say Cashout->REFNO     pict '99999999'
return nil
*
*                     End of the program ( amst100k.prg )
*
