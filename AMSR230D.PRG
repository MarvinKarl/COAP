*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
*³ Orix Metro Leasing and Finance                                            ³Û
*³ Account Management System                                                 ³Û
*ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Û
*³ Program ID...: AMSR230D.PRG                                               ³Û
*³ Description..: Aging of past-due receivables (accounting)                 ³Û
*³ Author...... : Ariel B. Bulan                                             ³Û
*³ Date.........: 12-Nov-1994   01:49:06pm                                   ³Û
*ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Û
*³                        U P D A T E S                                      ³Û
*ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Û
*³        Who        ³     When      ³               Why                     ³Û
*ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Û
*³ Renan Evangelista ³  1997 - 1998  ³ columns of days past due must         ³Û
*³                   ³               ³ reflect o/b, not the past due amt     ³Û
*³                   ³               ³ (industry practice)                   ³Û
*³ Janet B. Salvador ³  19-Jan-1999  ³ add new acctno                        ³Û
*³ ABB               ³  may 16, 2000 ³ ACCTMAST->osbal should not be         ³Û
*³                   ³               ³    the basis for outstanding bal.     ³Û
*³                   ³               ³   (it should be from AMSHIST.dbf      ³Û
*³                   ³               ³   (not from ACCTMAST)                 ³Û
*³ ABB               ³  11.19.2002   ³ consider pastdue for > 10% of osbal   ³Û
*³ MTS               ³  29-Dec-2006  ³ added AMSHIST2                        ³Û
*³ AGA               ³  14-Feb-2007  ³ neo PAYSKED support for modules       ³Û
*³ RMS               ³  08-Jul-2011  ³ Include employee accounts             ³Û
*³                   ³               ³                                       ³Û
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙÛ
*  ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

#include "colf.ch"
#include "inkey.ch"

#define AMT_PICT "999,999,999,999.99"
#define RPT_TITLE "Aging of Past-Due Receivables"
#define _PRATE  0.10

local getlist := {}
local z230d, nChoice, aAccount[3]
private sDate

begin sequence
	if ! chkpass( procname(), m->AX_LEVEL, m->g_USER_ID )
		break
	endif

   if ( m->TRUE_BRCH == "001" )
      if ! netuse( "&g_AMS_PATH\ACCTMAST",.f.,5)
         break
      endif
      ordlistadd( "&g_AMS_PATH\ACCTMAST")

      if ! netuse( "&g_AMS_PATH\PAYSKED",.f.,5)
         break
      endif
      ordlistadd( "&g_AMS_PATH\PAYSTAT")
      *** paystat.ntx  - brcode+acctno+status+dtos(paydate)+str(paynum)

      if ! netuse( "&g_AMS_PATH\AMSHIST", .f., 10 )
         break
      endif
      ordlistadd( "&g_AMS_PATH\AMSHIST")

      if ! netuse( "&g_AMS_PATH\AMSBACK\AMSHIST2", .f., 10 )
         break
      endif
      ordlistadd( "&g_AMS_PATH\AMSBACK\AMSHIST2")
   endif

   z230d := tempName()
   dbcreate( (z230d), { ;
      { "status",  "c",01,00 },;
      { "brcode"  ,"c",03,00 },;
      { "acctno"  ,"c",14,00 },;
      { "acctname","c",30,00 },;
      { "amort"   ,"n",15,02 },;
      { "balance" ,"n",14,02 },;
      { "due",     "n",14,02 },;
      { "matdate" ,"d",08,00 },;
      { "paydate" ,"d",08,00 },;
      { "nterm",   "n",03,00 },;
      { "aging",   "n",09,00 },;
      { "current", "n",14,02 },;
      { "matured", "n",14,02 },;
      { "n1_30",   "n",14,02 },;
      { "n31_60",  "n",14,02 },;
      { "n61_90",  "n",14,02 },;
      { "n91_180", "n",14,02 },;
      { "n180_up", "n",14,02 } } )
   dbUseArea( .T.,, (z230d), "z230d", .F. )
   index on str(field->aging,9)+field->brcode+field->acctname to (z230d)
   Set Index to (z230d)

   sDate := m->gTRANDATE
   nChoice := 3
   aAccount[1] := RadioButto( 12,28 ," FMLC ")
   aAccount[2] := RadioButto( 13,28 ," PBC  ")
   aAccount[3] := RadioButto( 14,28 ," ORIX ")
   rmsBox( 09,20,07,27,2,,"w+/rb" )
   while .T.
      setcolor( "w+/rb,w+/b,,,w+/bg")
      @ 10,25 say "Date :" get sDate pict "@D"
      @ 11,25,15,41 get nChoice RADIOGROUP aAccount ;
         CAPTION " Accounts " COLOR "w/rb,w+/rb,r/rb"
      setcursor(1)
      READ
      setcursor(0)
      if lastkey() == 27
         exit
      endif
      if GetData( sDate, nChoice )
         reportprint( "_rpt230d()","132 Column" )
      endif
   enddo
end seqeunce
dbcloseall()
tempErase()
__MRelease( "*", .T.)
return

*******************************************************************************
static function GetData( pdDate, pnChoice )
   local cBrAccnt, nAmort, nOSB, aTemp[3]
   local xSTR, isOK := .F.

   select "z230d" ; __dbZap()

   Desktop(.T.) ; setcursor(0)
   begin sequence
      if ( m->TRUE_BRCH == "001" )
         rmsBox( 05,10,15,60,1,"Gathering data. please wait...","n/w,w+/r" )
         setColor("g/n")
         ACCTMAST->( dbSeek(m->g_PAR_BRCH) )
         while ! ACCTMAST->( eof() ) .and. ACCTMAST->brcode == m->g_PAR_BRCH
            if pAbort()
               break
            endif
            scroll( 07,11,19,69,1 )
            @ 19,11 say ACCTMAST->brcode+"-"+ACCTMAST->acctno + " "+left(ACCTMAST->acctname,29)+" "+dtoc(ACCTMAST->valdate)

            if ACCTMAST->valdate > sDate .or. ACCTMAST->status == "0" .or. ;
               val(ACCTMAST->status) > 2
               ACCTMAST->( dbskip() )
               loop
            endif

            if pnChoice == 1
               if left(ACCTMAST->acctno, 4) != "9907"
                  ACCTMAST->( dbskip() )
                  loop
               endif
            elseif pnChoice == 2
               if left(ACCTMAST->acctno, 4) != "9908"
                  ACCTMAST->( dbskip() )
                  loop
               endif
            endif

            /*  buds - 2011-Jul-08
            ** skip employee loan
            if ACCTMAST->fcltycode == "10451" .or. ACCTMAST->fcltycode == "10452" .or. ;
               ACCTMAST->fcltycode == "10453" .or. ACCTMAST->fcltycode == "10454"
               ACCTMAST->( dbskip() )
               loop
            endif
            */

            cBrAccnt := ACCTMAST->brcode+ACCTMAST->acctno
            nOSB  := round( _GetOSBal( cBrAccnt, pdDate ), 2 )
            /*if empty(nOSB)
               ACCTMAST->( dbskip() )
               loop
            endif*/

            aTemp := { ctod(""), 0, 0 }
            _DoPaySked( cBrAccnt, pdDate, aTemp )
            if empty(nOSB) .and. empty(aTemp[2])
               ACCTMAST->( dbskip() )
               loop
            endif

            z230d->( dbappend() )
            z230d->status   := ACCTMAST->status
            z230d->brcode   := ACCTMAST->brcode
            z230d->acctno   := ACCTMAST->acctno
            z230d->acctname := ACCTMAST->acctname
            z230d->matdate  := ACCTMAST->matdate
            z230d->amort    := ACCTMAST->amort
            z230d->balance  := nOSB
            z230d->paydate  := aTemp[1]
            z230d->due      := aTemp[2]
            z230d->nterm    := aTemp[3]

            nAging := 0
            if aTemp[2] > 0
               nAging := pdDate - aTemp[1]
            endif
            z230d->aging := nAging

            if nAging > 180
               z230d->n180_up := nOSB
            elseif nAging > 90
               z230d->n91_180 := nOSB
            elseif nAging > 60
               z230d->n61_90  := nOSB
            elseif nAging > 30
               z230d->n31_60  := nOSB
            elseif nAging > 0
               z230d->n1_30   := nOSB
            else
               z230d->current := nOSB
            endif

            ACCTMAST->( dbskip() )
         enddo
      else
         xSTR := chk_par( m->g_PAR_BRCH )  +; // branch
                 chk_par( pdDATE )         +;
                 chk_par( pnChoice )

         cFile := cps_reqst( xSTR, "AMSR230DPRN" )
         if empty(cFile)
            break
         endif

         cFile := CopyFile( cFile )
         rmsBox( 05,10,15,60,1,"Gathering. please wait...","n/w,w+/r" )
         setColor("g/n")

         nH := fOpen( cFile, 0 )
         fSeek( nH, 0 )
         while .T.
            cText := fReadStr( nH, 151 )
            if cText == ""
               exit
            endif
            cText := rms_Parse( cText, "~" )
            scroll( 07,11,19,69,1 )
            @ 19,11 say cText[01]+"-"+cText[02]+ " "+left(cText[03],29)+" "+cText[05]

            z230d->( dbappend() )
            z230d->brcode   := cText[01]
            z230d->acctno   := cText[02]
            z230d->acctname := cText[03]
            z230d->status   := cText[04]
            z230d->matdate  := ctod( cText[05] )
            z230d->amort    := val( cText[06] )
            z230d->balance  := val( cText[07] )
            z230d->paydate  := ctod( cText[08] )
            z230d->due      := val( cText[09] )
            z230d->nterm    := val( cText[10] )

            nAmort   := val( cText[06] )  // amortization
            nOSB     := val( cText[07] )  // balance
            aTemp[1] := ctod( cText[08] ) // paydate
            aTemp[2] := val( cText[09] )  // total due
            aTemp[3] := val( cText[10] )  // remaining term
            nAging   := 0

            if aTemp[2] > 0
               nAging := pdDate - aTemp[1]
            endif
            z230d->aging := nAging

            if nAging > 180
               z230d->n180_up := nOSB
            elseif nAging > 90
               z230d->n91_180 := nOSB
            elseif nAging > 60
               z230d->n61_90  := nOSB
            elseif nAging > 30
               z230d->n31_60  := nOSB
            elseif nAging > 0
               z230d->n1_30   := nOSB
            else
               z230d->current := nOSB
            endif
         enddo
         CloseFile( nH, cFile )
      endif
      if z230d->( dbcommit(), reccount() ) == 0
         Error( "No record to print." )
         break
      endif

      isOK := .T.
   end sequence
   Desktop(.F.)
return isOK

*******************************************************************************
static function _DoPaySked( pcBrAccnt, pdDate, aData )
   *** aData 1 - Next Pay date
   ***       2 - Total Due
   ***       3 - Terms

   if PAYSKED->( dbSeek(pcBrAccnt+"D" ) )
      aData[1] := PAYSKED->paydate  // next paydate
      while ! PAYSKED->( eof() ) .and. PAYSKED->brcode+PAYSKED->acctno == pcBrAccnt .and. ;
         PAYSKED->status == "D"

         if pdDATE > PAYSKED->paydate
            aData[2] += PAYSKED->amtdue // total due
         endif
         aData[3]++
         PAYSKED->( dbskip() )
      enddo
   endif
return nil

*******************************************************************************
static function _head230d( nPage, lEject, n )

   /*
   10cpi   80 136   - PICA
   12cpi   96 163   - ELITE
   17cpi  137 233   - PICA  + CONDENSED ON
   20cpi  160 272   - ELITE + CONDENSED ON
   */

   if lEject
      __Eject()
   endif
   setPRC(0, 0)
   @ prow()+1,000 say "x"+chr(0) + "!"+chr(0) + m->gSYS_NAME
   @ prow()+0,127 say "Page : " + transf(nPage, "9999")
   @ prow()+1,000 say "Program ID:AMSR230d"
   @ prow()+0,117 say rs_Now()
   @ prow()+1,000 say PADC( m->gCOMPANY, 136)
   @ prow()+1,000 say PADC( "E"+RPT_TITLE+"F", 136)
   @ prow()+1,000 say PADC( "As of "+ rms_mdy(sDate), 136 ) + "!"
   if n == nil
      @ prow()+1,000 say "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
      @ prow()+1,000 say "Account No. / Account Name               Amortization       1-30 Days          31-60 Days         61-90 Days         91-180 Days        180 Days Above     Total Past Due     Outstanding        Next       Maturity   Remaining"
      @ prow()+1,000 say "                                                                                                                                                                              Balance            Pay Date   Date       Term     "
      @ prow()+1,000 say "---------------------------------------- ------------------ ------------------ ------------------ ------------------ ------------------ ------------------ ------------------ ------------------ ---------- ---------- ---------"
                        * 0123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-
                        * 999-99999 XXXXXXXXX-XXXXXXXXX-XXXXXXXXX- 999,999,999,999.99 999,999,999,999.99 999,999,999,999.99 999,999,999,999.99 999,999,999,999.99 999,999,999,999.99 999,999,999,999.99 999,999,999,999.99 99/99/9999 99/99/9999      9999
  endif
return nil

*******************************************************************************
function _rpt230d()
   local nPage := 1
   local agTotals[10], apTotals[10]

   AFill(agTotals, 0)
   AFill(apTotals, 0)
   InitLPT()
   z230d->( dbgotop() )
   _head230d( nPage++, .F. )
   while ! z230d->( eof() )
      if prow() > 58
         _head230d( nPage++, .T. )
      endif

      if z230d->aging > 0
         @ prow()+1,000      say z230d->brcode+right(z230d->acctno,5) pict "@R 999-99999"
         @ prow()+0,pcol()+1 say z230d->acctname
         @ prow()+0,pcol()+1 say z230d->amort     pict AMT_PICT
         @ prow()+0,pcol()+1 say z230d->n1_30     pict AMT_PICT
         @ prow()+0,pcol()+1 say z230d->n31_60    pict AMT_PICT
         @ prow()+0,pcol()+1 say z230d->n61_90    pict AMT_PICT
         @ prow()+0,pcol()+1 say z230d->n91_180   pict AMT_PICT
         @ prow()+0,pcol()+1 say z230d->n180_up   pict AMT_PICT
         @ prow()+0,pcol()+1 say z230d->due       pict AMT_PICT
         @ prow()+0,pcol()+1 say z230d->balance   pict AMT_PICT
         @ prow()+0,pcol()+1 say z230d->paydate   pict "@D"
         @ prow()+0,pcol()+1 say z230d->matdate   pict "@D"
         @ prow()+0,pcol()+6 say z230d->nterm     pict "9999"

         apTotals[1] += z230d->amort
         apTotals[2] += z230d->n1_30
         apTotals[3] += z230d->n31_60
         apTotals[4] += z230d->n61_90
         apTotals[5] += z230d->n91_180
         apTotals[6] += z230d->n180_up
         apTotals[7] += z230d->due
         apTotals[8] += z230d->balance

         agTotals[1] += z230d->amort
         agTotals[2] += z230d->n1_30
         agTotals[3] += z230d->n31_60
         agTotals[4] += z230d->n61_90
         agTotals[5] += z230d->n91_180
         agTotals[6] += z230d->n180_up
         agTotals[7] += z230d->due
         agTotals[8] += z230d->balance
      endif
      agTotals[09] += z230d->current
      agTotals[10] += z230d->balance

      if z230d->( dbskip(), eof() ) .or. prow() > 58
         _prnLines( 41, "-" )
         _prnTotal( "Page Total: ", 41, apTotals)
         AFill(apTotals, 0)
      endif

      if z230d->( eof() )
         @ prow()+1,00 say ""
         _prnTotal( "Grand Total: ", 41, agTotals)
         _prnLines( 41, "=" )
      endif
   enddo
   _head230d( nPage++, .T., 1 )
   @ prow()+2,02 say "-1Percentage to Total Receivables-0"
   @ prow()+2,10 say "C U R R E N T          : " + transf( agTotals[09], AMT_PICT ) + ;
      space(06) + transf( agTotals[09] / agTotals[10] * 100, "999.99 %")
   @ prow()+1,10 say "01 - 30  Days Past Due : " + transf( agTotals[02], AMT_PICT ) + ;
      space(06) + transf( agTotals[02] / agTotals[10] * 100, "999.99 %")
   @ prow()+1,10 say "31 - 60  Days Past Due : " + transf( agTotals[03], AMT_PICT ) + ;
      space(06) + transf( agTotals[03] / agTotals[10] * 100, "999.99 %")
   @ prow()+1,10 say "61 - 90  Days Past Due : " + transf( agTotals[04], AMT_PICT ) + ;
      space(06) + transf( agTotals[04] / agTotals[10] * 100, "999.99 %")
   @ prow()+1,10 say "91 - 180 Days Past Due : " + transf( agTotals[05], AMT_PICT ) + ;
      space(06) + transf( agTotals[05] / agTotals[10] * 100, "999.99 %")
   @ prow()+1,10 say "181 Days and Above     : " + transf( agTotals[06], AMT_PICT ) + ;
      space(06) + transf( agTotals[06] / agTotals[10] * 100, "999.99 %")
                      *123456789-123456789-123456789-123456789-123456789-123456789
                      *                         999,999,999,999.99      999.99 %
   @ prow()+1,35 say "------------------      ------"
   @ prow()+1,11 say "T O T A L             : " + transf( agTotals[10], AMT_PICT )
   @ prow()+0,59 say "100.00 %"
   @ prow()+1,35 say "==================      ======"
   __Eject()
return nil

*******************************************************************************
static function _prnLines( nCol, cChar )
   @ prow()+1,nCol     say repl(cChar, len(AMT_PICT) )
   @ prow()+0,pcol()+1 say repl(cChar, len(AMT_PICT) )
   @ prow()+0,pcol()+1 say repl(cChar, len(AMT_PICT) )
   @ prow()+0,pcol()+1 say repl(cChar, len(AMT_PICT) )
   @ prow()+0,pcol()+1 say repl(cChar, len(AMT_PICT) )
   @ prow()+0,pcol()+1 say repl(cChar, len(AMT_PICT) )
   @ prow()+0,pcol()+1 say repl(cChar, len(AMT_PICT) )
   @ prow()+0,pcol()+1 say repl(cChar, len(AMT_PICT) )
return nil

*******************************************************************************
static function _prnTotal( cSay, nCol, aTotals )
   @ prow()+1, nCol - len(cSay) - 1 say cSay
   @ prow()+0,pcol()+1 say aTotals[1] PICT AMT_PICT
   @ prow()+0,pcol()+1 say aTotals[2] PICT AMT_PICT
   @ prow()+0,pcol()+1 say aTotals[3] PICT AMT_PICT
   @ prow()+0,pcol()+1 say aTotals[4] PICT AMT_PICT
   @ prow()+0,pcol()+1 say aTotals[5] PICT AMT_PICT
   @ prow()+0,pcol()+1 say aTotals[6] PICT AMT_PICT
   @ prow()+0,pcol()+1 say aTotals[7] PICT AMT_PICT
   @ prow()+0,pcol()+1 say aTotals[8] PICT AMT_PICT
return nil
