/*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
 �   program ID.........:  amst100j.prg                                 �
 �   description........:  Initial Cash Outlay Printing                 �
 �   author.............:  Ariel B. Bulan                               �
 �   date...............:  10:35am 03-Jan-1995                          �
 쳐컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
 �                         U P D A T E S                                �
 쳐컴컴컴컴컴컴컴컴컴쩡컴컴컴컴컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
 �        Who        �     When      �               Why                �
 쳐컴컴컴컴컴컴컴컴컴탠컴컴컴컴컴컴컴탠컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
 �                   �               �                                  �
 읕컴컴컴컴컴컴컴컴컴좔컴컴컴컴컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�*/

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
