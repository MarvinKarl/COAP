/*
������������������������������������������������������������������������������Ŀ
�   PROGRAM ID.........:  amsm1002.prg                                         �
�   Description........:  CB unit code file maintenance                        �
�   Author.............:  Ariel B. Bulan                                       �
�   Date...............:  05:08pm 03-Nov-1994                                  �
������������������������������������������������������������������������������Ĵ
�                         U P D A T E S                                        �
������������������������������������������������������������������������������Ĵ
�        Who        �     When      �               Why                        �
������������������������������������������������������������������������������Ĵ
�                   �               �                                          �
��������������������������������������������������������������������������������
*/

#include "Colf.ch"
#include "Inkey.ch"

memvar ax_level,g_user_id
if chkpass( procname(),ax_level,g_user_id )
   if ( amsm1002open(), eval ({ || nosnow( .t. ), mainfunction( 'CB Unit Code', 'CB Unit Name'  ),nosnow( .f. ) } ), nil )
   eval ({|| __mrelease("*", .t.), dbcloseall() })
endif
return
******************************
static function amsm1002open()
******************************
   local mretval :=  if ( netuse ( '&g_AMS_PATH\Unitcode', .f. ,5 ), eval ({|| dbsetindex ( '&g_AMS_PATH\Unitcode' ), .t. } ), .f. )
return mretval
*                         End of the program ( amsm1002.prg )