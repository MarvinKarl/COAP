/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   PROGRAM ID.........:  amsm1006.prg                                         ³
³   Description........:  Payment Codes                                        ³
³   Author.............:  Ariel B. Bulan                                       ³
³   Date...............:  06:53pm 29-Nov-1994                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                         U P D A T E S                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        Who        ³     When      ³               Why                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                   ³               ³                                          ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include "Colf.ch"
#include "Inkey.ch"

memvar ax_level,g_user_id
if chkpass( procname(),ax_level,g_user_id )
   if ( amsm1006open(), eval ({ || nosnow( .t. ), mainfunction( 'Payment Code', 'Payment Name'  ),nosnow( .f. ) } ), nil )
   eval ({|| __mrelease("*", .t.), dbcloseall() })
endif
return
******************************
*
static function amsm1006open()
******************************
   local mretval :=  if ( netuse ( '&g_AMS_PATH\Paycodes', .f. ,5 ), eval ({|| dbsetindex ( '&g_AMS_PATH\Paycodes' ), .t. } ), .f. )
return mretval
*                         End of the program ( amsm1006.prg )
