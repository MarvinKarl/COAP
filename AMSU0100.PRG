/*컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
 �   PROGRAM ID...: amsu0100.prg                                        �
 �   Description..: update contact information                          �
 �   Author.......: Marvin T. Sabile                                    �
 �   Date.........: 9:04 AM 7/12/2011                                   �
 쳐컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
 �                         U P D A T E S                                �
 쳐컴컴컴컴컴컴컴컴컴쩡컴컴컴컴컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
 �        Who        �     When      �               Why                �
 쳐컴컴컴컴컴컴컴컴컴탠컴컴컴컴컴컴컴탠컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
 �                   �               �                                  �
 읕컴컴컴컴컴컴컴컴컴좔컴컴컴컴컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�*/

#include "COLF.CH"
 
If chkpass( procname(), AX_LEVEL, gUSER_ID )
   Begin sequence
         fOpen0100()
         fMain0100()
   End sequence
   dbcloseall()
EndIf   
return

// 컴컴컴컴컴컴컴컴컴컴컴컴컴�
   static function fMain0100()
// 컴컴컴컴컴컴컴컴컴컴컴컴컴�
local mscreen := SAVESCREEN(,,,)
local cContact:=space(21),cPhone:=space(21)


fshadow   ( 8,24,11,58,2,'w+/gr' )
setcursor ( 1 )

OL_PARAM->(dbseek(g_PAR_BRCH))

cContact := OL_PARAM->RENCONTACT
cPhone   := OL_PARAM->RENPHONE

@  9,25  say 'CONTACT �'               COLOR 'w+/gr'
@  9,36  get cContact picture '@!' VALID !EMPTY(cContact)    COLOR 'N/W'
@ 10,25  say 'PHONE   �'               COLOR 'w+/gr'
@ 10,36  get cPhone   picture '@!' VALID !EMPTY(cPhone)      COLOR 'N/W'


setcursor(3)
read
setcursor(1)

If confirm('Save new Entry?')

   //If OL_PARAM->(dbseek(g_PAR_BRCH))
   If Ol_PARAM->(netlock('R',0))
      OL_PARAM->RENCONTACT := cContact
      OL_PARAM->RENPHONE   := cPhone
      Ol_PARAM->(DbUnlock())
      Ol_PARAM->(DbCommit())
   Endif

EndIf

return

// 컴컴컴컴컴컴컴컴컴컴컴컴컴�
   static function fOpen0100()
// 컴컴컴컴컴컴컴컴컴컴컴컴컴�

if !netuse( '&g_ams_path\OL_PARAM', .f., 10 )              && GL OR Referance file
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_ams_path\OL_PARAM' )
endif
