//temporary utility file that re-generate schedule of payment

#include "COLF.CH"
#include "SETCURS.CH"
#include "INKEY.CH"
setcursor(0)
begin sequence
   openutil()
   mainfunc()
end sequence
dbcloseall()
clear
setcursor(1)
return nil
///

STatic Function Openutil()

if !netuse('Facility',.f.,5 )
   break
else
   set index to Fcltycd
endif
if !netuse('Asetcode',.f.,5 )
   break
else
   set index to Asetcode
endif

if !netuse('Lcrdepn',.t.,5 )
   break
else
   set index to Lcrdepn
endif

if !netuse('Acctmast',.f.,5)
   break
else
   set index to Acctmast
endif

if !netuse('Paysked',.t.,5)
   break
else
   set index to paysked,paydsked
endif

if !netuse('Rvspread',.t.,5)
   break
else
   set index to Rvspread
endif

if !netuse('Udispred',.t.,5)
   break
else
   set index to Udispred
endif

retur nil
//////
Static function mainfunc()
@ 00,00 say 'Temporary System for Generation of Schedule, LCR Depreciation, UDI & RV' color 'w+/w'
@ 01,00 say 'Please Do Not Interrupt< halting of program might cause mal-function of the system > ' color 'w+/w'
@ 03,00,23,79 box repl('²',9 )
if alert('Re-generate payment schedule and LCR Depreciation;< Zap PAYSKED & LCRDEPN > ',{'Continue','Cancel'},'n/w') == 1
   dbselectarea('Paysked')
   zap
   DBSELECTAREA('LCRDEPN')
   ZAP
   dbselectarea('Acctmast')
   dbgotop()
   fshadow(13,10,15,71,2,'w+/n')
   @ 14, 11 say repl('±',60 )  color 'w+/n'
   @ 16, 47 say 'Percentage Processed    %' color 'w/n'
   ncol:=11
   lrec:=count_dbf('Acctmast',1 )
   nbar:=round( 60/lrec,4 )
   rctr:=1
   Acctmast->(dbeval( {|| generate_sked('A'),gen_lcr(),gen_udispred(),gen_rvspred(), ;
                          ncol += nbar,statusbar(lrec,rctr,ncol,nbar,60,11,68,14,10 ), rctr++ },, ;
                          { || Acctmast->(!eof()) } ) )
   @ 24,00 say repl(' ',80) color 'w/n'
   error('Payment Schedule has been update........')
   tone(850,2)
   inkey(5)
   error('LCR Depreciation File has been update.....')
   tone(850,2)
   error('UDI Spread File has been update.....')
   tone(850,2)
   error('RV Spread File has been update.....')
   tone(850,2)
else
   break
endif
return nil