/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   PROGRAM ID...: AMSR0700.prg                                                ³
³   Description..: daily transaction prooflist                                 ³
³   Date.........:  9:20pm 08-Aug-1996                                         ³
³   Author.......: Renan S. Evangelista                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                         U P D A T E S                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        Who        ³     When      ³               Why                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Janet L. Bautista ³  10-Feb-1997  ³ missing RP/IPP bookings                  ³
³ Janet ulit        ³  12-Feb-1997  ³ change of report format                  ³
³ ABB               ³  10.21.2004   ³ ONLINE                                   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include 'inkey.ch'
#include 'colf.ch'
#include 'dbstruct.ch'

#defi K_SPACEBAR   32
#defi microfeed    chr( 27 ) + 'J' + chr( 18 )

#xtran getpaytype    ( <cnum> ) => if( <cnum> == '1'  , 'In Advance', 'In Arrears' )
#xtran getratetype   ( <cnum> ) => if( <cnum> == '1'  , 'Fixed   ', 'Floating' )
#xtran gettermunit   ( <cnum> ) => if( <cnum> == '1'  , 'Days  ', 'Months' )

memvar AX_LEVEL, gUSER_ID
setcursor(0)
setblink(.t.)
if chkpass( procname(), AX_LEVEL, gUSER_ID )
   begin sequence
      aOpen9999()
      aMain9999()
   end sequence
   dbcloseall()
endif
__mrelease( '*', .t. )
return nil

/*---------------------------*/
 Static Function aOpen9999()
/*---------------------------*/

if !netuse( '&g_AMS_PATH\Flag',.f., 10 )
   break
endif

if !netuse( 'Parametr',.f., 10 )
   break
endif

if !netuse( '&g_AMS_PATH\Acctdaly', .f., 10 )              && Account daily file
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_AMS_PATH\Accfclty' )                    && set index on Facility
endif

if !netuse( '&g_AMS_PATH\Facility', .f., 10 )
   break
else
   ordlistadd( '&g_AMS_PATH\Fcltycd' )
endif

return nil

/*-------------------------*/
 Static Function aMain9999()
/*-------------------------*/
 local mu:=savedbf(),st:=Savescreen( ,,, )

 dbselectarea('Acctdaly')
 dbsetorder( 1 )
 dbgotop()

 reportprint('aPrtprflst()','136-column continuous')
 *repcon_ol('aPrtprflst()','136-column continuous',,,,,,.F.)

 if confirm('Is transaction prooflist final?')
    dbselectarea('Flag')
    netlock('F',0)
    Flag->Prnproof := .t.
    dbunlock()
    dbcommit()
 endif

 restscreen( ,,,st )
 restdbf(mu)
 return nil

/*---------------------*/
  Function aPrtprflst()
/*---------------------*/
local npg:=1,tot_princ:=0,tot_amort:=0,tot_cred:=0,grd_princ:=0,grd_amort:=0,grd_cred:=0
local xdate := cmonth(gTrandate) +' '+ str(day(gTrandate),2) +', '+ str(year(gTrandate),4)

setfont('DRAFT')
setfont('PICA')
setfont('CONDENSED')
Head_proof(npg,xdate)

sele ACCTDALY
do while !eof()

   if STATUS <> '1'
      skip 
      loop
   endif

   if Acctdaly->brcode != g_PAR_BRCH             // abb 10.21.2004
      Acctdaly->(dbskip(+1))
      loop
   endif

   nFcltycode := Fcltycode
   sele FACILITY
   seek nFCLTYCODE
   @ prow()+1,02 say FCLTYNAME
   @ prow()+1,02 say ' '

   sele ACCTDALY
   do while FCLTYCODE == nFCLTYCODE .and. !eof()
      if prow() > 53
	 npg++
	 __eject()

	 Head_proof(npg,xdate)
      endif
      if STATUS <> '1'
	 skip
	 loop
      endif

      @ prow()+1,02   say BRCODE+'-'+substr(ACCTNO,-5,5)+'-'

      @ prow(), 009+4 say substr(ACCTNAME,1,34)
      @ prow(), 043+4 say substr(UNIT,1,40)
      @ prow(), 084+4 say PRINCIPAL                  pict '999,999,999.99'
      @ prow(), 099+4 say GD/100 * PRINCIPAL         pict '9,999,999.99'
      @ prow(), 112+4 say RV/100 * PRINCIPAL         pict '9,999,999.99'
      @ prow(), 125+4 say TERM                       pict '999' + ' ' + gettermunit(TERMUNIT)
      @ prow(), 136+4 say getpaytype(PAYTYPE)
      @ prow(), 149+4 say TRUERATE                   pict '99.9999'
      @ prow(), 157+4 say getratetype(RATETYPE)
      @ prow(), 166+4 say AMORT                      pict '999,999,999.99'
      @ prow(), 181+4 say CREDAMT+(RV/100*PRINCIPAL) pict '999,999,999.99'
      @ prow(), 196+4 say substr(AOCODE,1,5)
      @ prow(), 203+4 say VALDATE

      tot_princ += Acctdaly->Principal
      tot_amort += Acctdaly->Amort
      tot_Cred  += Acctdaly->Credamt
      grd_princ += Acctdaly->Principal
      grd_amort += Acctdaly->Amort
      grd_Cred  += Acctdaly->Credamt
      skip
   enddo
   if prow() > 53
      npg++
      __eject()
      Head_proof(npg,xdate)
   endif
   @ prow()+1,084+4 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   @ prow(),166+4   say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   @ prow(),181+4   say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   @ prow()+1,09+4  say 'Sub-Total :'
   @ prow(),084+4   say tran(tot_princ,'999,999,999.99')
   @ prow(),166+4   say tran(tot_amort,'999,999,999.99')
   @ prow(),181+4   say tran(tot_cred,'999,999,999.99')
   @ prow()+1,084+4 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   @ prow(),166+4   say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   @ prow(),181+4   say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   @ prow()+1,01+4  say ' '
   tot_princ := 0
   tot_amort := 0
   tot_cred  := 0
enddo

@ prow(),002+4   say 'Grand Total :'
@ prow(),084+4   say tran(grd_princ,'999,999,999.99')
@ prow(),166+4   say tran(grd_amort,'999,999,999.99')
@ prow(),181+4   say tran(grd_cred,'999,999,999.99')
@ prow()+1,084+4 say 'ÍÍÍÍÍÍÍÍÍÍÍÍÍÍ'
@ prow(),166+4   say 'ÍÍÍÍÍÍÍÍÍÍÍÍÍÍ'
@ prow(),181+4   say 'ÍÍÍÍÍÍÍÍÍÍÍÍÍÍ'
__eject()

setfont('NORMAL')
return nil

/*------------------------------*/
 static function head_proof(pgn,xdate)
/*------------------------------*/
setprc(0,0)
setfont('PICA')
PRNREPTITLE(127,1,PGN,'Daily Transaction Prooflist for Branch '+g_PAR_BRCH,'AMSR0700',gSYS_NAME)
PAGECENTER(prow()+1,127,xdate)
SETFONT('CONDENSED')

@ prow()+1,02 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄ'
@ prow()+1,02 say "  Account Number/Name                        Unit                                       Net Proceeds Guaranty Dep Residual Val Term       Pay. Type  True Rate RateType     Rent/Amort  Total Rec'ble  AO   Date Executed"
@ prow()+1,02 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄ'
return nil

/*       1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2         3         
12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123
	09    15                                 50                                       91             106          119          132 136    143        154       164      173            188            203   210
 ---------------------------------------- ---------------------------------------- -------------- ------------ ------------ ---------- ---------- --------- -------- -------------- -------------- ----- -------------
 Account Number/Name                      Unit                                       Net Proceeds Guaranty Dep Residual Val Term       Pay. Type  True Rate RateType     Rent/Amort  Total Rec'ble  AO   Date Executed
 ---------------------------------------- ---------------------------------------- -------------- ------------ ------------ ---------- ---------- --------- -------- -------------- -------------- ----- -------------
 99999-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 999,999,999.99 9,999,999.99 9,999,999.99 333 XXXXXX xxxxxxxxxx   99.9999 xxxxxxxx 999,999,999.99 999,999,999.99 xxxxx  mm/dd/yyyy
{2,9,43,															       months in advance           floating
*/
