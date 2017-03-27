*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
*³ Orix Metro Leasing and Finance                                            ³Û
*³ Account Management System                                                 ³Û
*ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Û
*³ Program ID...: AMSR2700.PRG                                               ³Û
*³ Description..: Classification of Receivables (Equipment & Term)           ³Û
*³ Author...... : Ariel B. Bulan                                             ³Û
*³ Date.........: 15-Dec-1994   12:38:49pm                                   ³Û
*ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Û
*³                        U P D A T E S                                      ³Û
*ÃÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Û
*³  Who  ³ When        ³ Why                                                 ³Û
*ÃÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Û
*³  ABB  ³ 04-Sep-2000 ³ Get OSBAL from payhist,paysked                      ³Û
*³  ABB  ³ 20-Jan-2005 ³ ONLINE                                              ³Û
*³  MTS  ³ 29-Dec-2006 ³ added AMSHIST2                                      ³Û
*³  AGA  ³ 14-Feb-2007 ³ removed paysked reference                           ³Û
*ÀÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙÛ
*  ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

#include "colf.ch"
#include "inkey.ch"

local zTemp, zUnit
private mDate

begin sequence
	if ! chkpass( procname(), m->AX_LEVEL, m->g_USER_ID )
		break
	endif

   if ( m->TRUE_BRCH == "001" )
      if ! netUse( "&g_AMS_PATH\ACCTMAST",.F.,5)
         break
      endif
      ordlistadd( "&g_AMS_PATH\ACCTMAST" )

      if ! netUse( "&g_AMS_PATH\ORIXUNIT",.F.,5)
         break
      endif
      ordlistadd( "&g_AMS_PATH\ORIXUNIT" )

      if ! netUse ( "&g_PLS_PATH\PLOANS.dbf",.F.,5 )
         break
      endif
      ordlistadd( "&g_PLS_PATH\PLOANS" )

      if ! netUse( "&g_AMS_PATH\STATHIST", .f., 10 )
         break
      endif
      set index to &g_AMS_PATH\STATHIST

      if ! netUse( "&g_AMS_PATH\CANCLACT", .f., 10 )
         break
      endif
      set index to &g_AMS_PATH\CANCLACT

      if ! netUse( "&g_AMS_PATH\AMSHIST", .f., 10 )
         break
      endif
      set index to &g_AMS_PATH\AMSHIST

      if ! netUse( "&g_AMS_PATH\AMSBACK\AMSHIST2", .f., 10 ) && Account Payment history file
         break
      endif
      set index to &g_AMS_PATH\AMSBACK\AMSHIST2     && set index on acctno
   endif

   zTemp := tempName()
   dbcreate( (zTemp), { ;
      { "mcode",    "c",02,00 },;
      { "orixunit", "c",02,00 },;
      { "unitname", "c",30,00 },;
      { "fycode",   "c",03,00 },;
      { "status",   "c",01,00 },;
      { "clntcode" ,"c",07,00 },;
      { "acctno"   ,"c",14,00 },;
      { "term",     "n",03,00 },;
      { "balance"  ,"n",14,02 } } )
   dbUseArea( .T.,, (zTemp), "zTemp", .F. )
   index on field->clntcode+field->acctno to (zTemp)
   Set Index to (zTemp)

   zUnit := tempName()
   dbcreate( (zUnit), { ;
      { "code1",    "c",01,00 },;
      { "orixunit", "c",02,00 },;
      { "unitname", "c",30,00 },;
      { "client1" , "n",06,00 },;
      { "account1", "n",06,00 },;
      { "balance1", "n",16,02 },;
      { "percent",  "n",06,02 },;
      { "client2" , "n",06,00 },;
      { "account2" ,"n",06,00 },;
      { "active2" , "n",16,02 },;
      { "pdr2" ,    "n",16,02 },;
      { "itl2" ,    "n",16,02 },;
      { "balance2", "n",16,02 },;
      { "client3" , "n",06,00 },;
      { "account3", "n",06,00 },;
      { "active3",  "n",16,02 },;
      { "pdr3" ,    "n",16,02 },;
      { "itl3" ,    "n",16,02 },;
      { "balance3"  ,"n",16,02 } } )
   dbUseArea( .T.,, (zUnit), "zUnit", .F. )
   index on field->code1+field->orixunit to (zUnit)
   Set Index to (zUnit)

   zClie := tempName()
   dbcreate( zClie, { ;
      { "orixunit","c",02,00 },;
      { "clntcode","c",07,00 },;
      { "fycode",  "c",03,00 },;
      { "client",  "n",05,00 },;
      { "account", "n",05,00 } } )
   dbusearea( .T.,, (zClie), "clie", .F. )
   index on field->orixunit+field->clntcode+field->fycode to (zClie)
   Set Index to (zClie)

   mDate := m->gTRANDATE
   while get_mdate(7)
      if GetData( mDate )
         reportprint( "_rpt2700()" )
      endif
   enddo
end sequence
dbcloseAll()
tempErase()
__MRelease( "*", .t.)
return

*******************************************************************************
static function GetData( pDATE )
   local cBrAccnt, lSkip, xStr
   local nOSB, cStatus
   local nH, cFile, cText
   local isOK := .F.
   local zClient, zAccount
   local nAMT_TOTAL := 0, nI, nTerms
   local aTerm := { { "00", " 1 -  6 MONTHS " },;
                    { "01", " 7 - 12 MONTHS " },;
                    { "02", "13 - 18 MONTHS " },;
                    { "03", "19 - 24 MONTHS " },;
                    { "04", "25 - 36 MONTHS " },;
                    { "05", "37 - 48 MONTHS " },;
                    { "06", "49 - 60 MONTHS " },;
                    { "07", "60 MONTHS ABOVE" } }

	Desktop(.T.)
   select "zTemp" ; __dbZap()
   select "zUnit" ; __dbZap()
   for nI := 1 to len(aTerm)
      zUnit->( dbAppend() )
      zUnit->code1    := "B"
      zUnit->orixunit := aTerm[nI, 1]
      zUnit->unitname := aTerm[nI, 2]
   next nI
   zUnit->( dbCommit() )

   begin sequence
      if m->TRUE_BRCH == "001"
         rmsBox(05,10,15,60,1,"Gathering data. please wait...","n/w,w+/r")
         setColor("g/n")
         ACCTMAST->( dbseek(m->g_PAR_BRCH) )
         while ACCTMAST->brcode == m->g_PAR_BRCH .and. ! ACCTMAST->( eof() )
            if pAbort()
               break
            endif

            scroll( 07,11,19,69,1 )
            @ 19,11 say ACCTMAST->brcode+"-"+ACCTMAST->acctno + " "+left(ACCTMAST->acctname,29)+" "+dtoc(ACCTMAST->valdate)

            if ACCTMAST->valdate > pDATE
               ACCTMAST->( dbSkip() )
               loop
            endif

            cFCode := LEFT(ACCTMAST->fcltycode, 3)
            if .not. (cFCode == "103" .or. cFCode == "104")
               ACCTMAST->( dbSkip() )
               loop
            endif

            // check cancelled status
            cBrAccnt := ACCTMAST->brcode+ACCTMAST->acctno
            if ACCTMAST->status == "0"
               lSkip := .T.
               if canclact->( dbseek(cBrAccnt) ) .and. canclact->date > pDATE
                  lSkip := .F.
               endif
               if lSkip
                  ACCTMAST->( dbskip(1) )
                  loop
               endif
            endif

            // include active, pdr & ITL only
            cStatus := _GetStatus( cBrAccnt, pDATE )
            if val(cStatus) > 3
               ACCTMAST->( dbSkip() )
               loop
            endif

            if ( nOSB := Round( _GetOSBal( cBrAccnt, pDATE ), 2 ) ) == 0
               ACCTMAST->( dbSkip() )
               loop
            endif

            zTemp->( dbappend() )
            ORIXUNIT->( dbseek(ACCTMAST->orixunit) )
            zTemp->orixunit  := ACCTMAST->orixunit
            zTemp->unitname  := ORIXUNIT->unitname
            zTemp->fycode    := cFCode
            zTemp->status    := cStatus
            zTemp->clntcode  := ACCTMAST->clntcode
            zTemp->acctno    := ACCTMAST->acctno
            zTemp->term      := ACCTMAST->term
            zTemp->balance   := nOSB

            if val(ACCTMAST->termunit) == 1
               nTerms := ( ACCTMAST->term / 30 )
            elseif val(ACCTMAST->termunit) == 2
               nTerms := ACCTMAST->term
            elseif val(ACCTMAST->termunit) == 3
               nTerms := ACCTMAST->term * 12
            endif

            if nTerms > 60
               zTemp->mcode := "07"
            elseif nTerms > 48
               zTemp->mcode := "06"
            elseif nTerms > 36
               zTemp->mcode := "05"
            elseif nTerms > 24
               zTemp->mcode := "04"
            elseif nTerms > 18
               zTemp->mcode := "03"
            elseif nTerms > 12
               zTemp->mcode := "02"
            elseif nTerms > 6
               zTemp->mcode := "01"
            else
               zTemp->mcode := "00"
            endif
            ACCTMAST->( dbskip(+1) )
         enddo
      else
         xStr := chk_par( m->g_PAR_BRCH )  +; // branch
                 chk_par( pDATE )

         cFile := cps_reqst( xStr, "AMSR1300PRINT" )
         if empty(cFile)
            break
         endif
         cFile := CopyFile( cFile )
         rmsBox(05,10,15,60,1,"Gathering data. please wait...","n/w,w+/r")
         setColor("g/n")

         nH := fOpen( cFile, 0 )
         fSeek( nH, 0 )
         while .T.
            cText := fReadStr( nH, 87 )
            if cText == ""
               exit
            endif
            cText := rms_Parse( cText, "~" )
            scroll( 07,11,19,69,1 )
            @ 19,11 say cText[01]+" "+cText[02] + cText[03]+" "+cText[05]+" "+cText[06]

            zTemp->( dbappend() )
            zTemp->orixunit := cText[01]
            zTemp->unitname := cText[02]
            zTemp->fycode   := cText[03]
            zTemp->status   := cText[04]
            zTemp->clntcode := cText[05]
            zTemp->acctno   := cText[06]
            zTemp->term     := val( cText[07] )
            zTemp->balance  := val( cText[08] )
            zTemp->mcode    := cText[09]
         enddo
         CloseFile( nH, cFile )
      endif
      if zTemp->( dbCommit(), reccount() ) < 1
         Error( "No record to print!" )
         break
      endif

      // Processing by Equipment
      select "clie" ; __dbZap()
      zTemp->( dbgotop() )
      while ! zTemp->( eof() )
         if ! clie->( dbseek(zTemp->orixunit+zTemp->clntcode+zTemp->fycode) )
            clie->( dbappend() )
            clie->orixunit := zTemp->orixunit
            clie->clntcode := zTemp->clntcode
            clie->fycode   := zTemp->fycode
            clie->client   := 1
         endif
         clie->account++

         if ! zUnit->( dbseek("A"+zTemp->orixunit) )
            zUnit->( dbappend() )
            zUnit->code1    := "A"
            zUnit->orixunit := zTemp->orixunit
            zUnit->unitname := zTemp->unitname
         endif
         zUnit->balance1 += zTemp->balance

         if zTemp->fycode == "104"
            zUnit->balance2 += zTemp->balance

            if zTemp->status == "1"
               zUnit->active2 += zTemp->balance
            elseif zTemp->status == "2"
               zUnit->pdr2 += zTemp->balance
            else
               zUnit->itl2 += zTemp->balance
            endif
         else
            zUnit->balance3 += zTemp->balance

            if zTemp->status == "1"
               zUnit->active3 += zTemp->balance
            elseif zTemp->status == "2"
               zUnit->pdr3 += zTemp->balance
            else
               zUnit->itl3 += zTemp->balance
            endif
         endif

         zTemp->( dbskip() )
      enddo
      clie->( dbcommit(), dbgotop() )
      while ! clie->( eof() )
         zUnit->( dbSeek("A"+clie->orixunit) )
         zUnit->client1  += clie->client
         zUnit->account1 += clie->account

         if clie->fycode == "104"
            zUnit->client2  += clie->client
            zUnit->account2 += clie->account
         else
            zUnit->client3  += clie->client
            zUnit->account3 += clie->account
         endif
         clie->( dbskip() )
      enddo
      zUnit->( dbCommit() )

      // Processing by Term
      select "clie" ; __dbZap()
      zTemp->( dbgotop() )
      while ! zTemp->( eof() )
         if ! clie->( dbseek(zTemp->mcode+zTemp->clntcode+zTemp->fycode) )
            clie->( dbappend() )
            clie->orixunit := zTemp->mcode
            clie->clntcode := zTemp->clntcode
            clie->fycode   := zTemp->fycode
            clie->client   := 1
         endif
         clie->account++

         zUnit->( dbseek("B"+zTemp->mcode) )
         zUnit->balance1 += zTemp->balance

         if zTemp->fycode == "104"
            zUnit->balance2 += zTemp->balance

            if zTemp->status == "1"
               zUnit->active2 += zTemp->balance
            elseif zTemp->status == "2"
               zUnit->pdr2 += zTemp->balance
            else
               zUnit->itl2 += zTemp->balance
            endif
         else
            zUnit->balance3 += zTemp->balance

            if zTemp->status == "1"
               zUnit->active3 += zTemp->balance
            elseif zTemp->status == "2"
               zUnit->pdr3 += zTemp->balance
            else
               zUnit->itl3 += zTemp->balance
            endif
         endif

         nAMT_TOTAL += zTemp->balance
         zTemp->( dbskip() )
      enddo
      clie->( dbcommit(), dbgotop() )
      while ! clie->( eof() )
         zUnit->( dbSeek("B"+clie->orixunit) )
         zUnit->client1  += clie->client
         zUnit->account1 += clie->account

         if clie->fycode == "104"
            zUnit->client2  += clie->client
            zUnit->account2 += clie->account
         else
            zUnit->client3  += clie->client
            zUnit->account3 += clie->account
         endif
         clie->( dbskip() )
      enddo
      zUnit->( dbCommit(), dbGotop() )
      while ! zUnit->( eof() )
         zUnit->percent := round( zUnit->balance1 / nAMT_TOTAL * 100, 2 )
         zUnit->( dbskip() )
      enddo
      zUnit->( dbCommit() )

      isOK := .T.
   end sequence
	Desktop(.F.)
return isOK

#define _pnW 136
#define AMT_PICT "999,999,999,999.99"
#define NUM_PICT "999,999"
*******************************************************************************
function _rpt2700()
   local nPage := 1
   local aTotals[16]

   InitLPT()
   SetPRC( 0,0 )
   @ prow()+1,001 say "x"+chr(0) + "!"+chr(0) + m->gSYS_NAME
   @ prow()+0,131 say "Page : " + transf( nPage, "9999" )
   @ prow()+1,001 say "AMSR2700-" + m->g_USER_ID
   @ prow()+0,117 say rs_Now()
   @ prow()+1,000 say padc(m->gCOMPANY, _pnW)
   @ prow()+1,000 say padc( "EClassification of Receivables by Equipment and by TermF" , _pnW )
   @ prow()+1,000 say padc( "As of "+ rms_mdy(mDate), _pnW ) + "!"
   @ prow()+3,01 say "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
   @ prow()+1,01 say "                                  Total    Total                                 ³ No. of  No. of           F I N A N C E   R E C E I V A B L E S                              ³ No. of  No. of     L E A S E    C O N T R A C T    R E C E I V A B L E S                    "
   @ prow()+1,01 say "A. BY TYPE OF EQUIPMENT           Clients  Accounts Outstanding Balance        % ³ Clients Accounts   Current Amount        PDR Amount       ITL Amount         Total Amount   ³ Clients Accounts   Current Amount       PDR Amount         ITL Amount       Total Amount    "
   @ prow()+1,01 say "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
                     *123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-
                     *99 XXXXXXXXX-XXXXXXXXX-XXXXXXXXX- 999,999  999,999  999,999,999,999.99  999.99 %   999,999  999,999 999,999,999,999.99 999,999,999,999.99 999,999,999,999.99 999,999,999,999.99  999,999  999,999 999,999,999,999.99 999,999,999,999.99 999,999,999,999.99 999,999,999,999.99

   AFill(aTotals, 0)
   zUnit->( dbSeek("A") )
   while ! zUnit->( eof() ) .and. zUnit->code1 == "A"
      @ prow()+1,001       say zUnit->orixunit+" "+zUnit->unitname
      @ prow()+0,pcol()+1  say zUnit->client1   PICT NUM_PICT
      @ prow()+0,pcol()+2  say zUnit->account1  PICT NUM_PICT
      @ prow()+0,pcol()+2  say zUnit->balance1  PICT AMT_PICT
      @ prow()+0,pcol()+2  say zUnit->percent   PICT "999.99 %"
      @ prow()+0,pcol()+2  say zUnit->client2   PICT NUM_PICT
      @ prow()+0,pcol()+2  say zUnit->account2  PICT NUM_PICT
      @ prow()+0,pcol()+1  say zUnit->active2   PICT AMT_PICT
      @ prow()+0,pcol()+1  say zUnit->pdr2      PICT AMT_PICT
      @ prow()+0,pcol()+1  say zUnit->itl2      PICT AMT_PICT
      @ prow()+0,pcol()+1  say zUnit->balance2  PICT AMT_PICT
      @ prow()+0,pcol()+2  say zUnit->client3   PICT NUM_PICT
      @ prow()+0,pcol()+2  say zUnit->account3  PICT NUM_PICT
      @ prow()+0,pcol()+1  say zUnit->active3   PICT AMT_PICT
      @ prow()+0,pcol()+1  say zUnit->pdr3      PICT AMT_PICT
      @ prow()+0,pcol()+1  say zUnit->itl3      PICT AMT_PICT
      @ prow()+0,pcol()+1  say zUnit->balance3  PICT AMT_PICT

      aTotals[01] += zUnit->client1
      aTotals[02] += zUnit->account1
      aTotals[03] += zUnit->balance1
      aTotals[04] += zUnit->percent
      aTotals[05] += zUnit->client2
      aTotals[06] += zUnit->account2
      aTotals[07] += zUnit->active2
      aTotals[08] += zUnit->pdr2
      aTotals[09] += zUnit->itl2
      aTotals[10] += zUnit->balance2
      aTotals[11] += zUnit->client3
      aTotals[12] += zUnit->account3
      aTotals[13] += zUnit->active3
      aTotals[14] += zUnit->pdr3
      aTotals[15] += zUnit->itl3
      aTotals[16] += zUnit->balance3


      zUnit->( dbskip() )
      if zUnit->code1 != "A"
         @ prow()+1,35 say "-------  -------  ------------------  ------    -------  ------- ------------------ ------------------ ------------------ ------------------  -------  ------- ------------------ ------------------ ------------------ ------------------"
         @ prow()+1,35       say aTotals[01]   PICT NUM_PICT
         @ prow()+0,pcol()+2 say aTotals[02]   PICT NUM_PICT
         @ prow()+0,pcol()+2 say aTotals[03]   PICT AMT_PICT
         @ prow()+0,pcol()+2 say "100.00 %"
         @ prow()+0,pcol()+2 say aTotals[05]   PICT NUM_PICT
         @ prow()+0,pcol()+2 say aTotals[06]   PICT NUM_PICT
         @ prow()+0,pcol()+1 say aTotals[07]   PICT AMT_PICT
         @ prow()+0,pcol()+1 say aTotals[08]   PICT AMT_PICT
         @ prow()+0,pcol()+1 say aTotals[09]   PICT AMT_PICT
         @ prow()+0,pcol()+1 say aTotals[10]   PICT AMT_PICT
         @ prow()+0,pcol()+2 say aTotals[11]   PICT NUM_PICT
         @ prow()+0,pcol()+2 say aTotals[12]   PICT NUM_PICT
         @ prow()+0,pcol()+1 say aTotals[13]   PICT AMT_PICT
         @ prow()+0,pcol()+1 say aTotals[14]   PICT AMT_PICT
         @ prow()+0,pcol()+1 say aTotals[15]   PICT AMT_PICT
         @ prow()+0,pcol()+1 say aTotals[16]   PICT AMT_PICT
         @ prow()+1,35 say "=======  =======  ==================  ======    =======  ======= ================== ================== ================== ==================  =======  ======= ================== ================== ================== =================="
      endif
   enddo

   @ prow()+3,01 say "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
   @ prow()+1,01 say "                                  Total    Total                                 ³ No. of  No. of           F I N A N C E   R E C E I V A B L E S                              ³ No. of  No. of     L E A S E    C O N T R A C T    R E C E I V A B L E S                    "
   @ prow()+1,01 say "B. BY TERM                        Clients  Accounts Outstanding Balance        % ³ Clients Accounts   Current Amount        PDR Amount       ITL Amount         Total Amount   ³ Clients Accounts   Current Amount       PDR Amount         ITL Amount       Total Amount    "
   @ prow()+1,01 say "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
                     *123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-
                     *XXXXXXXXX-XXXXXXXXX-XXXXXXXXX-    999,999  999,999  999,999,999,999.99  999.99 %   999,999  999,999 999,999,999,999.99 999,999,999,999.99 999,999,999,999.99 999,999,999,999.99  999,999  999,999 999,999,999,999.99 999,999,999,999.99 999,999,999,999.99 999,999,999,999.99
   AFill(aTotals, 0)
   zUnit->( dbseek("B") )
   while ! zUnit->( eof() ) .and. zUnit->code1 == "B"
      @ prow()+1,001       say zUnit->unitname
      @ prow()+0,pcol()+4  say zUnit->client1   PICT NUM_PICT
      @ prow()+0,pcol()+2  say zUnit->account1  PICT NUM_PICT
      @ prow()+0,pcol()+2  say zUnit->balance1  PICT AMT_PICT
      @ prow()+0,pcol()+2  say zUnit->percent   PICT "999.99 %"
      @ prow()+0,pcol()+2  say zUnit->client2   PICT NUM_PICT
      @ prow()+0,pcol()+2  say zUnit->account2  PICT NUM_PICT
      @ prow()+0,pcol()+1  say zUnit->active2   PICT AMT_PICT
      @ prow()+0,pcol()+1  say zUnit->pdr2      PICT AMT_PICT
      @ prow()+0,pcol()+1  say zUnit->itl2      PICT AMT_PICT
      @ prow()+0,pcol()+1  say zUnit->balance2  PICT AMT_PICT
      @ prow()+0,pcol()+2  say zUnit->client3   PICT NUM_PICT
      @ prow()+0,pcol()+2  say zUnit->account3  PICT NUM_PICT
      @ prow()+0,pcol()+1  say zUnit->active3   PICT AMT_PICT
      @ prow()+0,pcol()+1  say zUnit->pdr3      PICT AMT_PICT
      @ prow()+0,pcol()+1  say zUnit->itl3      PICT AMT_PICT
      @ prow()+0,pcol()+1  say zUnit->balance3  PICT AMT_PICT

      aTotals[01] += zUnit->client1
      aTotals[02] += zUnit->account1
      aTotals[03] += zUnit->balance1
      aTotals[04] += zUnit->percent
      aTotals[05] += zUnit->client2
      aTotals[06] += zUnit->account2
      aTotals[07] += zUnit->active2
      aTotals[08] += zUnit->pdr2
      aTotals[09] += zUnit->itl2
      aTotals[10] += zUnit->balance2
      aTotals[11] += zUnit->client3
      aTotals[12] += zUnit->account3
      aTotals[13] += zUnit->active3
      aTotals[14] += zUnit->pdr3
      aTotals[15] += zUnit->itl3
      aTotals[16] += zUnit->balance3

      if zUnit->( dbskip(), eof() )
         @ prow()+1,35 say "-------  -------  ------------------  ------    -------  ------- ------------------ ------------------ ------------------ ------------------  -------  ------- ------------------ ------------------ ------------------ ------------------"
         @ prow()+1,35       say aTotals[01]   PICT NUM_PICT
         @ prow()+0,pcol()+2 say aTotals[02]   PICT NUM_PICT
         @ prow()+0,pcol()+2 say aTotals[03]   PICT AMT_PICT
         @ prow()+0,pcol()+2 say "100.00 %"
         @ prow()+0,pcol()+2 say aTotals[05]   PICT NUM_PICT
         @ prow()+0,pcol()+2 say aTotals[06]   PICT NUM_PICT
         @ prow()+0,pcol()+1 say aTotals[07]   PICT AMT_PICT
         @ prow()+0,pcol()+1 say aTotals[08]   PICT AMT_PICT
         @ prow()+0,pcol()+1 say aTotals[09]   PICT AMT_PICT
         @ prow()+0,pcol()+1 say aTotals[10]   PICT AMT_PICT
         @ prow()+0,pcol()+2 say aTotals[11]   PICT NUM_PICT
         @ prow()+0,pcol()+2 say aTotals[12]   PICT NUM_PICT
         @ prow()+0,pcol()+1 say aTotals[13]   PICT AMT_PICT
         @ prow()+0,pcol()+1 say aTotals[14]   PICT AMT_PICT
         @ prow()+0,pcol()+1 say aTotals[15]   PICT AMT_PICT
         @ prow()+0,pcol()+1 say aTotals[16]   PICT AMT_PICT
         @ prow()+1,35 say "=======  =======  ==================  ======    =======  ======= ================== ================== ================== ==================  =======  ======= ================== ================== ================== =================="
      endif
   enddo
   __Eject()
return nil
