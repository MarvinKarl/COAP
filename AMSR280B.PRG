*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
*³ Orix Metro Leasing and Finance                                            ³Û
*³ Account Management System                                                 ³Û
*ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Û
*³ Program ID...: AMSR280B.PRG                                               ³Û
*³ Description..: Client"s w/OSBAl"s > 1M                                    ³Û
*³ Author...... : Ariel B. Bulan                                             ³Û
*³ Date.........: 21-Apr-1995   12:38:44pm                                   ³Û
*ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Û
*³                        U P D A T E S                                      ³Û
*ÃÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Û
*³  Who  ³ When        ³ Why                                                 ³Û
*ÃÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Û
*³  JBS  ³ 24-Jul-2002 ³ Include all accounts regardless of status           ³Û
*³  JBS  ³ 26-Jul-2002 ³ as of date                                          ³Û
*³  ABB  ³ 20-Jan-2005 ³ FOR ONLINE                                          ³Û
*³  MTS  ³ 29-Dec-2006 ³ Added AMSHIST2                                      ³Û
*³  AGA  ³ 14-Feb-2007 ³ removed paysked reference                           ³Û
*³  RMS  ³             ³ Revise the program add option for old/BSP format    ³Û
*ÀÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙÛ
*  ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

#include "colf.ch"
#include "inkey.ch"

#define RPT_TITLE  "Clients with Outstanding Balance of One(1) Million and Above"
#define AMT_PICT   "999,999,999,999,999.99"
#define _pL 02

local getlist := {}
local zTemp, zClnt, z280a, z280b
private pdDate, cFormat

begin sequence
   if ! chkpass( procname(), m->AX_LEVEL, m->g_USER_ID )
      break
   endif

   if ( m->TRUE_BRCH == "001" )
      if ! netUse( "&g_AMS_PATH\acctmast",.f.,5)
         break
      endif
      Set_Index( m->g_AMS_PATH, { "acctmast", "Acctclnt" } )
      ordsetfocus(2)
      *** acctmast
      *** acctclnt

      if ! netUse( "&g_AMS_PATH\Ctrlinfo", .f., 5 )
         break
      endif
      Set_Index( m->g_AMS_PATH, { "Ctrlinfo" } )
      * ctrlinfo - brcode+acctno

      if ! netUse( "&g_AMS_PATH\stathist",.f.,5 )
         break
      endif
      Set_Index( m->g_AMS_PATH, { "stathist" } )

      if ! netUse( "&g_AMS_PATH\canclact",.f.,5 )
         break
      endif
      Set_Index( m->g_AMS_PATH, { "canclact" } )

      if ! netUse( "&g_AMS_PATH\amshist", .f., 10 )
         break
      endif
      Set_Index( m->g_AMS_PATH, { "amshist" } )
      // amshist.ntx brcode+acctno

      if ! netUse( "&g_AMS_PATH\AMSBACK\Amshist2", .f., 10 )
         break
      endif
      dbsetindex( "&g_AMS_PATH\AMSBACK\Amshist2" )
      // amshist2.ntx brcode+acctno
   endif

   if ! netUse( "&g_AMS_PATH\unitcode",.f.,5 )
      break
   endif
   Set_Index( m->g_AMS_PATH, { "unitcode" } )
   * unitcode

   if ! netUse( "&g_CIS_PATH\Client.dbf",.f.,5)
      break
   endif
   Set_Index( m->g_CIS_PATH, { "Cliecd" } )
   * cliecd.ntx - brcode+clntcode

   if ! netUse( "&g_CIS_PATH\borrower.dbf",.f.,5)
      break
   endif
   Set_Index( m->g_CIS_PATH, { "borrower" } )
   * borrower - brwrcode

   zTemp := tempName()
   dbcreate( zTemp, { ;
      { "brcode"  ,"c",03,00 },;
      { "clntcode","c",07,00 },;
      { "acctno"  ,"c",14,00 },;
      { "fycode",  "c",02,00 },;
      { "fycode2", "c",05,00 },;
      { "status",  "c",01,00 },;
      { "unitcode","c",02,06 },;
      { "gd_amt",  "n",14,02 },;
      { "matdate", "d",08,00 },;
      { "appdate", "d",08,00 },;
      { "appvalue","n",14,02 },;
      { "appcntr", "n",09,00 },;
      { "balance", "n",14,02 } } )
   dbusearea( .T.,, (zTemp), "temp", .F. )
   dbCreateIndex( (zTemp)+".nt1", "brcode+clntcode+acctno", ;
      {|| field->brcode+field->clntcode+field->acctno }, .F. )
   dbCreateIndex( (zTemp)+".nt2", "brcode+clntcode+fycode+status+unitcode", ;
      {|| field->brcode+field->clntcode+field->fycode+field->status+field->unitcode }, .F. )
   ordlistclear()
   ordlistadd( (zTemp)+".nt1" )
   ordlistadd( (zTemp)+".nt2" )
   ordsetfocus(1)

   zClnt := tempName()
   dbcreate( zClnt, { ;
      { "brcode"  ,"c",03,00 },;
      { "clntcode","c",07,00 },;
      { "balance", "n",16,02 } } )
   dbusearea( .T.,, (zClnt), "zClnt", .F. )
   index on field->brcode+field->clntcode to (zClnt)
   Set Index to (zClnt)

   z280a := tempName()
   dbcreate( z280a, { ;
      { "clntcode","c",07,00 },;
      { "clntname","c",50,00 },;
      { "balance", "n",16,02 } } )
   dbusearea( .T.,, (z280a), "z280a", .F. )
   dbCreateIndex( (z280a)+".nt1", "clntcode", {|| field->clntcode }, .F. )
   dbCreateIndex( (z280a)+".nt2", "clntname", {|| field->clntname }, .F. )
   ordlistclear()
   ordlistadd( (z280a)+".nt1" )
   ordlistadd( (z280a)+".nt2" )
   ordsetfocus(1)

   z280b := tempName()
   dbcreate( z280b, { ;
      { "id",      "c",15,00 },;
      { "accts",   "n",03,00 },;
      { "brcode"  ,"c",03,00 },;
      { "clntcode","c",07,00 },;
      { "clntname","c",50,00 },;
      { "fycode",  "c",02,00 },;
      { "status",  "c",01,00 },;
      { "unitcode","c",02,00 },;
      { "tin_num", "c",12,00 },;
      { "brwrcode","c",04,00 },;
      { "gd_amt",  "n",16,02 },;
      { "matdate", "d",08,00 },;
      { "appvalue","n",16,02 },;
      { "appdate", "d",08,00 },;
      { "balance", "n",16,02 } } )
   dbusearea( .T.,, (z280b), "z280b", .F. )
   dbCreateIndex( (z280b)+".nt1", "id", {|| field->id }, .F. )
   dbCreateIndex( (z280b)+".nt2", "clntname", {|| field->clntname }, .F. )
   ordlistclear()
   ordlistadd( (z280b)+".nt1" )
   ordlistadd( (z280b)+".nt2" )
   ordsetfocus(1)

   pdDate := DATE()
   cFormat := "O"
   Box3( 07,21,05,35 )
   while .T.
      rms_Set( "n/w,w/n,,,w+/w", 1 )
      @ 08,24 say "As of Date :" get pdDate  pict "@KD" valid ! empty(pdDate)
      @ 09,24 say "    Format :" get cFormat pict "!"   valid cFormat $ "OB"
      @ 10,24 say "             O - Old Format"
      @ 11,24 say "             B - BSP Format"
      read
      if lastkey() == 27
         exit
      endif

      if Get280b()
         if cFormat == "B"
            repcon_ol( "rpt280b()","132 Column" )
         else
            repcon_ol( "rpt280a()","80 Column" )
         endif
      endif
   enddo
end sequence
dbCloseAll()
tempErase()
__MRelease( "*", .T.)
return

*******************************************************************************
static function Get280b()
   local cBrClnt, cBrAccnt
   local nOSB, cFyCode, cStatus, lSkip
   local nH, cFile, cText
   local isOK := .F.

   select "temp" ; __dbZap()
   temp->( ordsetfocus(1) )

   Desktop(.T.) ; SetCursor(0)
   begin sequence
      if (m->TRUE_BRCH == "001")
         Box3( 05,05,15,70 )
         dispoutat( 06,06, " Gathering Data..." )
         setColor( "g/n" )
         acctmast->( dbseek(m->g_PAR_BRCH) )
         while ! acctmast->( eof() ) .and. acctmast->brcode == m->g_PAR_BRCH
            if pAbort()
               break
            endif
            scroll( 07,06,19,74,1 )
            @ 19,07 say acctmast->brcode+"-"+acctmast->acctno+ " "+padr(acctmast->acctname, 40)

            // if booked date > requested date
            if acctmast->valdate > pdDate
               acctmast->( dbskip() )
               loop
            endif

            cBrAccnt := acctmast->brcode+acctmast->acctno
            if acctmast->status == "0"
               lSkip := .T.
               if canclact->( dbSeek(cBrAccnt) ) .and. canclact->date > pdDate
                  lSkip := .F.
               endif

               if lSkip
                  acctmast->( dbskip() )
                  loop
               endif
            endif

            // facility is 103 & 104 only
            cFCode := left(acctmast->fcltycode, 3)
            if .not. ( cFCode == "103" .or. cFCode == "104" )
               acctmast->( dbskip() )
               loop
            endif

            nOSB     := round( _GetOSBal(cBrAccnt, pdDate), 2 )

            // get outstanding balance greater than 1.00
            if nOSB > 0
               temp->( dbappend() )
               temp->brcode   := acctmast->brcode
               temp->clntcode := acctmast->clntcode
               temp->acctno   := acctmast->acctno
               temp->fycode2  := acctmast->fcltycode
               if cFCode == "103"
                  temp->fycode := "32"
               elseif cFCode == "104"
                  if acctmast->fcltycode == "10402" .or. acctmast->fcltycode == "10403"
                     temp->fycode := "33"
                  else
                     temp->fycode := "14"
                  endif
               endif
               temp->matdate  := acctmast->matdate
			   if substr(Acctmast->fcltycode,1,3) == '104' 
			   temp->gd_amt   := 0
			   else
               temp->gd_amt   := acctmast->principal * ( acctmast->gd / 100 )
			   endif
               temp->unitcode := acctmast->unitcode
               temp->status   := _GetStatus( cBrAccnt, pdDate )
               temp->balance  := nOSB

               __Colateral( cBrAccnt )
            endif
            acctmast->( dbskip() )
         enddo
      else
         xStr := chk_par( m->g_PAR_BRCH ) +; // branch
                 chk_par( pdDate )

         cFile := do_cps( xStr, "AMSR280BPRN" )
         if empty(cFile)
            break
         endif

         cFile := CopyFile( cFile )
         nH := fOpen( cFile, 0 )
         fSeek( nH, 0 )
         while .T.
            cText := fReadStr( nH, 120 )
            if cText == ""
               exit
            endif
            cText := rms_Parse( cText, "~" )

            temp->( dbappend() )
            temp->brcode    := cText[01]
            temp->clntcode  := cText[02]
            temp->acctno    := cText[03]
            temp->fycode2   := cText[04]
            temp->fycode    := cText[05]
            temp->matdate   := ctod( cText[06] )
            temp->gd_amt    := val( cText[07] )
            temp->unitcode  := cText[08]
            temp->status    := cText[09]
            temp->balance   := val( cText[10] )
            temp->appdate   := ctod( cText[11] )
            temp->appvalue  := val( cText[12] )
            temp->appcntr   := val( cText[13] )
         enddo
         CloseFile( nH, cFile )
      endif
      if temp->( dbcommit(), reccount() ) == 0
         Error( "No Record to print." )
         break
      endif

      select "zClnt" ; __dbZap()
      temp->( ordsetfocus(2), dbgotop() )
      while ! temp->( eof() )
         if ! zClnt->( dbseek(temp->brcode+temp->clntcode) )
            zClnt->( dbappend() )
            zClnt->brcode   := temp->brcode
            zClnt->clntcode := temp->clntcode
         endif
         zClnt->balance += temp->balance
         temp->( dbskip() )
      enddo
      zClnt->( dbcommit() )

      select "z280a" ; __dbZap()
      z280a->( ordsetfocus(1) )

      select "z280b" ; __dbZap()
      z280b->( ordsetfocus(1) )

      temp->( ordsetfocus(2), dbgotop() )
      while ! temp->( eof() )
         if zClnt->( dbSeek(temp->brcode+temp->clntcode) ) .and. zClnt->balance >= 1000000
            if cFormat == "B" // new format
               if ! z280b->( dbseek(temp->brcode+temp->clntcode+temp->fycode+;
                  temp->status+temp->unitcode) )
                  z280b->( dbappend() )
                  z280b->ID := temp->brcode+temp->clntcode+temp->fycode+;
                               temp->status+temp->unitcode
                  z280b->brcode   := temp->brcode
                  z280b->clntcode := temp->clntcode
                  z280b->clntname := __Client( temp->brcode+temp->clntcode )
                  z280b->tin_num  := client->tin
                  z280b->brwrcode := client->brwrcode
                  z280b->fycode   := temp->fycode
                  z280b->status   := temp->status
                  z280b->unitcode := temp->unitcode
                  z280b->matdate  := temp->matdate
                  z280b->appdate  := temp->appdate
               endif
               z280b->accts++
               z280b->gd_amt   += temp->gd_amt
               z280b->balance  += temp->balance
               z280b->appvalue += temp->appvalue
            else // old format
               if ! z280a->( dbSeek(temp->clntcode) )
                  z280a->( dbappend() )
                  z280a->clntcode := temp->clntcode
                  z280a->clntname := __Client( temp->brcode+temp->clntcode )
               endif
               z280a->balance += temp->balance
            endif
         endif
         temp->( dbskip() )
      enddo
      z280a->( dbcommit() )
      z280b->( dbcommit() )

      if cFormat == "O"
         if z280a->( reccount() ) == 0
            Error( "No Record to print." )
            break
         endif
      else
         if z280b->( reccount() ) == 0
            Error( "No Record to print." )
            break
         endif
      endif

      isOK := .T.
   end sequence

   Desktop(.F.)
return isOK

*******************************************************************************
static function __Colateral( pcBrAccnt )
   ctrlinfo->( dbSeek(pcBrAccnt) )
   while ! ctrlinfo->( eof() ) .and. ctrlinfo->brcode+ctrlinfo->acctno == pcBrAccnt
      temp->appdate  := ctrlinfo->appdate
      temp->appvalue += ctrlinfo->appvalue
      temp->appcntr++
      ctrlinfo->( dbSkip() )
   enddo
return NIL

*******************************************************************************
static function _Borrower( cFCode, nLen )
   local Result := ""

   if borrower->( dbSeek(cFCode) )
      Result := borrower->brwrname
   endif

   if nLen != NIL
      Result := left(Result, nLen)
   endif
return Result

****************************************************************************
function rpt280a( pdDate )
   local nTotals := 0, nPage := 1

   InitLPT()
   z280a->( ordsetfocus(2), dbGotop() )
   while ! z280a->( eof() )
      SetPRC(0,0) // draft + 10cpi
      @ prow()+1,_pL+00 say "x"+chr(0) + "!"+chr(0) + m->gSYS_NAME
      @ prow()+0,_pL+67 say "Page No.: " + tran(nPage++, "9999")
      @ prow()+1,_pL+00 say "Program ID: AMSR280B - " + m->gUSER_ID
      @ prow()+0,_pL+62 say rs_Now()
      @ prow()+2,_pL+00 say PADC(m->gCOMPANY, 80)
      @ prow()+1,_pL+00 say PADC("E"+RPT_TITLE+"F", 80)
      @ prow()+1,_pL+00 say PADC( "As of " + rms_mdy( pdDate ), 80)
      @ prow()+1,_pL+00 say "----------------------------------------------------------------------------"
      @ prow()+1,_pL+00 say "Client Name                                              Outstanding Balance"
      @ prow()+1,_pL+00 say "--------------------------------------------------    ----------------------"
                            *0123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789
                            *XXXXXXXXX-XXXXXXXXX-XXXXXXXXX-XXXXXXXXX-XXXXXXXXX-    999,999,999,999,999.99
      while .T.
         if z280a->balance >= 1000000
            @ prow()+1,_pL+00 say z280a->clntname
            @ prow()+0,_pL+54 say z280a->balance     pict AMT_PICT
            nTotals += z280a->balance
         endif

         if z280a->( dbskip(), eof() ) .or. prow() > 55
            exit
         endif
      enddo

      if z280a->( eof() )
         @ prow()+1,_pL+54 say "----------------------"
         @ prow()+1,_pL+40 say "Total : "
         @ prow()+0,_pL+54 say nTotals PICT AMT_PICT
         @ prow()+1,_pL+54 say "======================"
      endif
      __Eject()
   enddo
return NIL

*******************************************************************************
static function __Client( pcCode, plTrim )
   local Result := ""

   if plTrim == nil
      plTrim := .F.
   endif

   if client->( dbSeek(pcCode) )
      Result := client->fullname
   endif

   if plTrim
      Result := alltrim(Result)
   endif
return Result

*******************************************************************************
static function rptHead( nPage )
   SetPRC(0,0)  // draft + 10cpi
   @ prow()+1,_pL+00 say "x"+chr(0) + "!"+chr(0) + m->gSYS_NAME
   @ prow()+0,_pL+125 say "Page No.: " + tran(nPage++, "9999")
   @ prow()+1,_pL+000 say "Program ID: AMSR280B - " + m->gUSER_ID
   @ prow()+0,_pL+115 say rs_Now()
   @ prow()+1,_pL+000 say PADC("ORIX METRO Leasing and Finance Corporation ",136)
   @ prow()+1,_pL+000 say PADC(RPT_TITLE + " (BSP)", 136)
   @ prow()+1,_pL+000 say PADC( "As of " + rms_mdy( pdDate ), 136) + "!"
   @ prow()+2,_pL+000 say "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
   @ prow()+1,_pL+000 say "NO. OF                                                                                         FACILITY  STATUS                          CB UNIT                           MATURITY                          APPRAISAL"
   @ prow()+1,_pL+000 say "ACCTS   CLIENT NAME                                         T I N        BORROWER                  CODE    CODE        GUARANTY DEPOSIT     CODE      OUTSTANDING BALANCE      DATE         APPRAISAL VALUE       DATE"
   @ prow()+1,_pL+000 say "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
                         * 0123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456
                         *  9999   XXXXXXXXX-XXXXXXXXX-XXXXXXXXX-XXXXXXXXX-XXXXXXXXX-  999-999-999  XXXXXXXXX-XXXXXXXXX-        XX       X  999,999,999,999,999.99       XX   999,999,999,999,999.99  99999999  999,999,999,999,999.99   99999999
return nil

****************************************************************************
function rpt280b( pdDate )
   local aTotals[04], nPage := 1

   AFill(aTotals, 0.0)

   InitLPT()
   z280b->( ordsetfocus(2), dbGotop() )
   while ! z280b->( eof() )
      rptHead( nPage++ )
      * 0123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456
      *  9999   XXXXXXXXX-XXXXXXXXX-XXXXXXXXX-XXXXXXXXX-XXXXXXXXX-  999-999-999  XXXXXXXXX-XXXXXXXXX-        XX       X  999,999,999,999,999.99       XX   999,999,999,999,999.99  99999999  999,999,999,999,999.99   99999999
      while .T.
         @ prow()+1,_pL+001 say z280b->accts       pict "9999"
         @ prow()+0,_pL+008 say z280b->clntname
         @ prow()+0,_pL+060 say z280b->tin_num
         @ prow()+0,_pL+073 say _Borrower(z280b->brwrcode, 20)
         @ prow()+0,_pL+101 say z280b->fycode
         @ prow()+0,_pL+110 say z280b->status
         @ prow()+0,_pL+113 say z280b->gd_amt pict AMT_PICT
         @ prow()+0,_pL+142 say z280b->unitcode
         @ prow()+0,_pL+147 say z280b->balance  pict AMT_PICT
         if z280b->accts > 1
            @ prow()+0,_pL+171 say "99999999"
         else
            @ prow()+0,_pL+171 say dtos(z280b->matdate)
         endif
         @ prow()+0,_pL+181 say z280b->appvalue  PICT AMT_PICT
         if z280b->accts > 1
            @ prow()+0,_pL+206 say "99999999"
         else
            @ prow()+0,_pL+206 say dtos(z280b->appdate)
         endif
         aTotals[1] += z280b->gd_amt
         aTotals[2] += z280b->balance
         aTotals[3] += z280b->appvalue

         if z280b->( dbskip(), eof() ) .or. prow() > 55
            exit
         endif
      enddo

      if z280b->( eof() )
         @ prow()+1,_pL+113 say "----------------------"
         @ prow()+0,_pL+147 say "----------------------"
         @ prow()+0,_pL+181 say "----------------------"
         @ prow()+1,_pL+113 say aTotals[1] PICT AMT_PICT
         @ prow()+0,_pL+147 say aTotals[2] PICT AMT_PICT
         @ prow()+0,_pL+181 say aTotals[3] PICT AMT_PICT
         @ prow()+1,_pL+113 say "======================"
         @ prow()+0,_pL+147 say "======================"
         @ prow()+0,_pL+181 say "======================"
      endif

      if z280b->( eof() )
         if prow() >= 40
            rptHead( nPage++ )
            __Eject()
         endif
         @ prow()+1,_pL+000 say "ELEGEND:F"
         @ prow()+2,_pL+000 say "-1FACILITY CODE-0"
         @ prow()+1,_pL+015 say "14 MORTGAGE CONTRACT RECEIVABLES (LOANS)"
         @ prow()+1,_pL+015 say "32 LEASE CONTRACT RECEIVABLES"
         @ prow()+1,_pL+015 say "33 RECEIVABLES FINANCED (IPP / RECEIVABLE PURCHASED)"

         @ prow()+2,_pL+000 say "-1STATUS CODE-0"
         @ prow()+1,_pL+015 say "1 CURRENT"
         @ prow()+1,_pL+015 say "2 PAST DUE"
         @ prow()+1,_pL+015 say "3 ITEMS IN LITIGATION"

         @ prow()+2,_pL+000 say "-1CB UNIT CODE-0"
         @ prow()+1,_pL+015 say "31 HEAVY EQUIPMENT"
         @ prow()+1,_pL+015 say "32 MACHINERY"
         @ prow()+1,_pL+015 say "33 CARS"
         @ prow()+1,_pL+015 say "34 TRUCKS"
         @ prow()+1,_pL+015 say "35 OFFICE EQUIPMENT"
         @ prow()+1,_pL+015 say "36 OTHER MOVABLES"
      endif
      __Eject()
   enddo
return NIL
