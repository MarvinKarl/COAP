/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   PROGRAM ID.........:  amsm1005.prg                                         ³
³   Description........:  ORIX unit code file maintenance                      ³
³   Author.............:  Ariel B. Bulan                                       ³
³   Date...............:  03:56pm 07-Nov-1994                                  ³
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
   if ( amsm1005open(), eval ({ || nosnow( .t. ), mainfunction( 'Orix Unit Code', 'Orix Unit Name'  ),nosnow( .f. ) } ), nil )
   eval ({|| __mrelease("*", .t.), dbcloseall() })
endif
return
******************************
*
static function amsm1005open()
******************************
   local mretval :=  if ( netuse ( '&g_AMS_PATH\Orixunit', .f. ,5 ), eval ({|| dbsetindex ( '&g_AMS_PATH\Orixunit' ), .t. } ), .f. )
return mretval
*                         End of the program ( amsm1005.prg )





