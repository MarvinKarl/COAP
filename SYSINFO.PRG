LOCAL aINFO := DIRECTORY('AMS.EXE')
LOCAL nUX   := 9
LOCAL nUY   := 23
LOCAL nLX   := 15
LOCAL nLY   := nUY+11+18

@ nUX,nUY CLEAR TO nLX,nLY
@ nUX,nUY TO nLX,nLY
*FSHADOW(nUX,nUY,nLX,nLY,2)

@ nUX,nUY+1  SAY '[System Info]'   COLOR 'W+/BG'
@ nLX,nLY-15 SAY '[Press any key]' COLOR 'W+/BG'
@ nUX,nUY+2  SAY 'System Info'     COLOR 'GR+/BG'
@ nLX,nLY-14 SAY 'Press any key'   COLOR 'GR+/BG'

@ nUX+1,nUY+1 SAY '    System'
@ nUX+2,nUY+1 SAY '      Size'
@ nUX+3,nUY+1 SAY '      Date'
@ nUX+4,nUY+1 SAY '      Time'
@ nUX+5,nUY+1 SAY ' Attribute'

@ nUX+1,nUY+12 SAY ''        COLOR 'GR+/BG'
@ nUX+2,nUY+12 SAY ''        COLOR 'GR+/BG'
@ nUX+3,nUY+12 SAY ''        COLOR 'GR+/BG'
@ nUX+4,nUY+12 SAY ''        COLOR 'GR+/BG'
@ nUX+5,nUY+12 SAY ''        COLOR 'GR+/BG'

@ nUX+1,nUY+14 SAY aINFO[1,1]                             COLOR 'W+/BG'
@ nUX+2,nUY+14 SAY TRAN(aINFO[1,2],'@R 999,999,999')+' B' COLOR 'W+/BG'
@ nUX+3,nUY+14 SAY DTOC(aINFO[1,3])                       COLOR 'W+/BG'
@ nUX+4,nUY+14 SAY aINFO[1,4]                             COLOR 'W+/BG'
@ nUX+5,nUY+14 SAY aINFO[1,5]                             COLOR 'W+/BG'

INKEY(0)

RETURN
