/*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
 �   program ID.........:  amst100l.prg                                 �
 �   description........:  documents checklist printing                 �
 �   author.............:  Ariel B. Bulan                               �
 �   date...............:  10:35am 03-Jan-1995                          �
 쳐컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
 �                         U P D A T E S                                �
 쳐컴컴컴컴컴컴컴컴컴쩡컴컴컴컴컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
 �        Who        �     When      �               Why                �
 쳐컴컴컴컴컴컴컴컴컴탠컴컴컴컴컴컴컴탠컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
 퀁enan evangelista  �13-Jun-1996    � Arrange printing of dates        �
 �                   �               � Add prepared/checked/noted by    �
 읕컴컴컴컴컴컴컴컴컴좔컴컴컴컴컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�*/

****************************************
*
function transfer_rec( mrecords )
****************************************
local blnk_dt := ctod('  /  /  ')

    aadd ( mrecords, { Docday->DOCCODE, ' ', ;
                       if( empty(Docday->DOCDATE), space(10), Docday->DOCDATE) ,;
                       if( empty(Docday->RECDATE), space(10), Docday->RECDATE) ,;
                       Docday->RECEIVER, Docday->CHECKER, Docday->STATUS, Docday->REMARKS ;
                      };
         )
return nil
****************************************
*
function print_list( mrecord )
****************************************
    local mcol := { 1,5,39,52,67,78,85 }
    @ prow()+1, mcol[1] say mrecord[1]           pict '@X'
    @ prow()  , mcol[2] say mrecord[2]           pict '@X'
    @ prow()  , mcol[3] say if(valtype(mrecord[3]) == 'C', tran(mrecord[3],'@X' ), tran(mrecord[3],'@D') )
    @ prow()  , mcol[4] say if(valtype(mrecord[4]) == 'C', tran(mrecord[4],'@X' ), tran(mrecord[4],'@D') )
    @ prow()  , mcol[5] say mrecord[5]           pict '@X'
    @ prow()  , mcol[6] say mrecord[6]           pict '@X'
    @ prow()  , mcol[7] say padr(mrecord[8],52)  pict '@X'

   *                    XXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  99/99/9999   99/99/9999     XXX        XXX    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   *                    1   5                             36  39      48   52      61      59         80    85                                                   140



    //@ prow()  , mcol[7] say mrecord[7]           pict '@X'
return nil
****************************************
*
function print_shead()
****************************************                                                                                   1
   *                             1         2         3         4         5         6         7         8         9         0         1         2         3         4         5
   *                   0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
   @ prow()+2, 00 say '旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴컴컴컫컴컴컴컴컴쩡컴컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커'
   @ prow()+1, 00 say '�               Document             �  Document  �    Date    � Received � Checked �                      R e m a r k s                     �'
   @ prow()+1, 00 say '�                 Name               �    Date    �  Received  �    By    �   By    �                                                        �'
   @ prow()+1, 00 say '읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컨컴컴컴컴컴컴좔컴컴컴컴컴컨컴컴컴컴컴좔컴컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸'
   *                    XXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  99/99/9999   99/99/9999     XXX        XXX    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   *                    1   5                             36  39      48   52      61      59         80    85                                                   140
return nil
*
*                       End of the program ( Amst100L.prg )
*
