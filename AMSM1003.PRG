/*
旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
�   PROGRAM ID.........:  amsm1003.prg                                         �
�   Description........:  credit type file maintenance                         �
�   Author.............:  Ariel B. Bulan                                       �
�   Date...............:  09:21pm 03-Nov-1994                                  �
쳐컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
�                         U P D A T E S                                        �
쳐컴컴컴컴컴컴컴컴컴쩡컴컴컴컴컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
�        Who        �     When      �               Why                        �
쳐컴컴컴컴컴컴컴컴컴탠컴컴컴컴컴컴컴탠컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
�                   �               �                                          �
읕컴컴컴컴컴컴컴컴컴좔컴컴컴컴컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
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
