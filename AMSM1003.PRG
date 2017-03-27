/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   PROGRAM ID.........:  amsm1003.prg                                         ³
³   Description........:  credit type file maintenance                         ³
³   Author.............:  Ariel B. Bulan                                       ³
³   Date...............:  09:21pm 03-Nov-1994                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                         U P D A T E S                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        Who        ³     When      ³               Why                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                   ³               ³                                          ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include "Colf.CH"
#include "Inkey.CH"

memvar ax_level,g_user_id
if chkpass( procname(),ax_level,g_user_id )
   if ( amsm1003open(), eval ({ || nosnow( .t. ), mainfunction( 'CB Credit Type', 'CB Credit Name'  ),nosnow( .f. ) } ), nil )
   eval ({|| __mrelease("*", .t.), dbcloseall() })
endif
return
******************************
static function amsm1003open()
******************************
   local mretval  := if ( netuse ( '&g_AMS_PATH\Credtype', .f. ,5 ), eval ({ || dbsetindex ( '&g_AMS_PATH\Credtype' ), mretval := .t. }), mretval := .f. )
return mretval
*                         End of the program ( amsm1003.prg )
