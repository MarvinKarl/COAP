/*
旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
�   PROGRAM ID.........:  amsm1013.prg                                         �
�   Description........:  Insurance Coverage Code maintenance                  �
�   Author.............:  renan s. evangelista                                 �
�   Date...............:  09:20am 25-Nov-1996                                  �
쳐컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
�                         U P D A T E S                                        �
쳐컴컴컴컴컴컴컴컴컴쩡컴컴컴컴컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
�        Who        �     When      �               Why                        �
쳐컴컴컴컴컴컴컴컴컴탠컴컴컴컴컴컴컴탠컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
�                   �               �                                          �
읕컴컴컴컴컴컴컴컴컴좔컴컴컴컴컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
*/

#include "Colf.ch"
#include "Inkey.ch"

memvar ax_level,g_user_id
if chkpass( procname(),ax_level,g_user_id )
   if ( amsm1013open(), eval ({ || nosnow( .t. ), mainfunction( 'Coverage Code', 'Insurance Description'  ),nosnow( .f. ) } ), nil )
   eval ({|| __mrelease("*", .t.), dbcloseall() })
endif
return
******************************
*
static function amsm1013open()
******************************
   local mretval :=  if ( netuse ( '&g_AMS_PATH\Coverage', .f. ,5 ), eval ({|| dbsetindex ( '&g_AMS_PATH\Coverage' ), .t. } ), .f. )
return mretval
*                         End of the program ( amsm1013.prg )
