//This is a temporary index file routine
//To test the difference b-tween Blinker and Exospace
//Author: Renan S. Evangelista

#include "Colf.ch"
#include "Addedit.ch"

if opentemp()
   do_reindex()
endif
dbcloseall()
return nil
/*------------------------*/
 Static Function opentemp()
/*------------------------*/
local nretval

if !Netuse('Reindex',.t.,0)
   return .f.
endif
dbsetindex('Reindex')
dbgotop()
return .t.
/*-------------------------*/
 Static Function do_reindex
/*-------------------------*/
local mu, _xdbf, _xkey, _xfile,_st1
local xx := Reindex->(Lastrec())
local zz := 1

clear
@ 09, 04 to 11, 25 double
@ 10, 5 say repl('±',19 ) color 'w/n'

_xdbf := Reindex->Filename
_st1  := .t.
while !Reindex->(eof())
    if _st1 .or. _xdbf <> Reindex->Filename <> _xdbf
       Netuse( (_xdbf),.t.,0)
    endif
    while _xdbf == Reindex->Filename
          _xfile := Reindex->Index_name
          _xkey:= Reindex->Key
          index on &_xkey to ( _xfile )
          reindex->(dbskip())
          @ 10,5 say repl( 'Û', ( zz++ / xx ) * 19 ) color 'w+/n'
    enddo
    dbclosearea()
    _xdbf := Reindex->filename
enddo
return nil