*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
*³ ORIX METRO Leasing and Finance Corporation                                ³Û
*³ Account Management System                                                 ³Û
*ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Û
*³ Program ID...: AMSR500C.PRG                                               ³Û
*³ Description..: PDC Inventory List                                         ³Û
*³ Author...... : Ariel B. Bulan                                             ³Û
*³ Date.........: Jun-03-2002   16:33:36                                     ³Û
*ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Û
*³                        U P D A T E S                                      ³Û
*ÃÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Û
*³  Who  ³ When        ³ Why                                                 ³Û
*ÃÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Û
*³  JBS  ³ Feb-13-2003 ³ print all pdc regardless of paymode                 ³Û
*³  AGA  ³ Feb-14-2007 ³ removed paysked referece function                   ³Û
*³  RMS  ³ Jan-03-2012 ³ removed all tag pdc                                 ³Û
*ÀÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙÛ
*  ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

#include "inkey.ch"
#include "colf.ch"

#define AMNT_14   "999,999,999.99"

local zTemp
private vd_Date := m->gTRANDATE

Desktop(.T.)
begin sequence
   if ! chkpass( procname(), m->AX_LEVEL, m->gUSER_ID )
      break
   endif

   if (m->TRUE_BRCH == "001")
      if ! netUse( "&g_AMS_PATH\ACCTMAST", .f., 10 )
         break
      endif
      ordlistadd( "&g_AMS_PATH\ACCTMAST" ) // brcode+acctno

      *** Current PDC Database
      if ! netUse( "&g_AMS_PATH\PDC_DTLS", .f., 10 )
         break
      endif
      *ordlistadd( "&g_AMS_PATH\PDC_DTLS" ) // brcode+acctno+dtos(chkdate)
      ordlistadd( "&g_AMS_PATH\PDC_DATE" )  // brcode+dtos(depdate)

      *** History PDC
      if ! netUse( "&g_AMS_PATH\AMSBACK\PDCDTBCK", .f., 10 )
         break
      endif
      ordlistadd( "&g_AMS_PATH\AMSBACK\PBK_DATE" ) // brcode+dtos(depdate)
   endif

   zTemp := tempName()
   dbcreate( zTemp, { ;
      { "brcode"   ,"c",03,00 },;
      { "acctno"   ,"c",14,00 },;
      { "acctname" ,"c",50,00 },;
      { "bank"     ,"c",25,00 },;
      { "chkno"    ,"c",12,00 },;
      { "chkdate"  ,"d",08,00 },;
      { "depdate"  ,"d",08,00 },;
      { "chkamt"   ,"n",11,02 } } )
   dbUseArea( .T.,, (zTemp), "z500c", .F. )
   index on substr(dtos(field->depdate),7,2)+field->acctname+field->acctno to (zTemp)
   Set Index to (zTemp)

   rmsBox(10,18,4,37,6,"PDC Inventory List","n/w,w+/r")
   while .T.
      setcolor("n/w,gr+/n,,,w+/w") ; setcursor(1)
      @ 13,20 say "Cut-off Date  " get vd_date pict "@D" valid !empty(vd_date)
      read
      if lastkey() == 27
         exit
      endif

      if GetData( m->g_PAR_BRCH, vd_date ) > 0
         reportprint( "AMSR_500C()" )
      endif
   enddo
end sequence
Desktop(.F.)
DBCloseAll()
tempErase()
__mrelease( "*", .t. )

return

*******************************************************************************
static function GetData( pID, pDATE )
   local lc_acct, nCount := -1
   local la_temp[04]

	Desktop(.T.)
   select "z500c" ; __dbZap()

   begin sequence
      if m->TRUE_BRCH == "001"
         rmsBox( 05,05,15,70,4,"Gathering Data","n/w,w+/r" )
         rms_set("g/n", 0)

         *** Current
         PDC_DTLS->( DBSeek(pID+dtos(pDATE), .T.) )
         while PDC_DTLS->brcode == pID .and. ! PDC_DTLS->( eof() )
            if pAbort()
               break
            endif

            lc_acct := PDC_DTLS->brcode+PDC_DTLS->acctno
            ACCTMAST->( DBSeek(lc_acct) )
            scroll( 08,06,19,74,1 )
            @ 19,06 say ACCTMAST->brcode+"-"+ACCTMAST->acctno + " "+left(ACCTMAST->acctname,39)+" "+dtoc(ACCTMAST->valdate)

            if PDC_DTLS->status != "1" .or. PDC_DTLS->ltransmit .or. ;
               ACCTMAST->osbal <= 0 .or. ACCTMAST->status == "0"

               PDC_DTLS->( dbSkip() )
               loop
            endif

            z500c->( DBAppend() )
            z500c->brcode    := PDC_DTLS->brcode
            z500c->acctno    := PDC_DTLS->acctno
            z500c->acctname  := ACCTMAST->acctname
            z500c->bank      := PDC_DTLS->bank
            z500c->chkno     := PDC_DTLS->chkno
            z500c->chkdate   := PDC_DTLS->chkdate
            z500c->depdate   := PDC_DTLS->depdate
            z500c->chkamt    := PDC_DTLS->chkamt

            PDC_DTLS->( dbSkip() )
         enddo

         *** History
         PDCDTBCK->( DBSeek(pID+dtos(pDATE), .T.) )
         while PDCDTBCK->brcode == pID .and. ! PDCDTBCK->( eof() )
            if pAbort()
               break
            endif

            lc_acct := PDCDTBCK->brcode+PDCDTBCK->acctno
            ACCTMAST->( DBSeek(lc_acct) )
            scroll( 08,06,19,74,1 )
            @ 19,06 say ACCTMAST->brcode+"-"+ACCTMAST->acctno + " "+left(ACCTMAST->acctname,39)+" "+dtoc(ACCTMAST->valdate)

            if PDCDTBCK->status != "1" .or. PDCDTBCK->ltransmit .or. ;
               ACCTMAST->osbal <= 0 .or. ACCTMAST->status == "0"

               PDCDTBCK->( dbSkip() )
               loop
            endif

            z500c->( DBAppend() )
            z500c->brcode    := PDCDTBCK->brcode
            z500c->acctno    := PDCDTBCK->acctno
            z500c->acctname  := ACCTMAST->acctname
            z500c->bank      := PDCDTBCK->bank
            z500c->chkno     := PDCDTBCK->chkno
            z500c->chkdate   := PDCDTBCK->chkdate
            z500c->depdate   := PDCDTBCK->depdate
            z500c->chkamt    := PDCDTBCK->chkamt

            PDCDTBCK->( dbSkip() )
         enddo
      else
         la_Temp[01] := chk_par( pID   ) +; // branch
                        chk_par( pDATE )    // DATE

         la_Temp[02] := cps_reqst( la_Temp[01], "PDC_INVLIST" ) // AMS006
         if empty(la_Temp[02])
            break
         endif

         la_Temp[03] := CopyFile( la_Temp[02] )

         rmsBox( 05,05,15,70,4,"Gathering Data","n/w,w+/r" )
         rms_set("g/n", 0)

         la_Temp[04] := fOpen( la_Temp[03], 0 )
         fSeek( la_Temp[04], 0 )
         while .T.
            lc_text := fReadStr( la_Temp[04], 151 )
            if lc_text == ""
               exit
            endif
            lc_text := rms_Parse( lc_text, "~" )
            scroll( 08,06,19,74,1 )
            @ 19,06 say lc_text[01]+"-"+lc_text[02]+ " "+left(lc_text[03],39)+" "+lc_text[07]

            z500c->( dbappend() )
            z500c->brcode    := lc_text[01]
            z500c->acctno    := lc_text[02]
            z500c->acctname  := lc_text[03]
            z500c->bank      := lc_text[04]
            z500c->chkno     := lc_text[05]
            z500c->chkdate   := ctod( lc_text[06] )
            z500c->depdate   := ctod( lc_text[07] )
            z500c->chkamt   := val( lc_text[08] )
         enddo
         CloseFile( la_Temp[04], la_Temp[03] )
      endif
      nCount := z500c->( DBCommit(), reccount() )
   end sequence
   if nCount == 0
      Error( "No record to print!" )
   endif
	Desktop(.F.)
return nCount

*******************************************************************************
static Function _rptHead( nPage, lEject )
   local nW := 100

   if lEject
      __Eject()
   endif
   __PHeader2( nPage++,"AMSR500C",nW,0,"x"+chr(0)+"!"+chr(1) )
   @ prow()+1,000 say padc("INVENTORY LIST OF PDC'S", nW)
   @ prow()+1,000 say padc("FOR "+ rms_mdy(vd_date), nW) + "!"
   @ prow()+1,00 say "------------------------------------------------------------------------------------------------------------------------------------"
   @ prow()+1,00 say "      Account                 Account                           Drawee Bank        Check          Check        Check      Deposit   "
   @ prow()+1,00 say "      Number                   Name                                                Number         Amount       Date       Date      "
   @ prow()+1,00 say "-------------------- ----------------------------------- ------------------------- ------------ -------------- ---------- ----------"
                     *.........10........20........30........40........50........60........70........80........90.......100.......110.......120.......130.......140.......150.......160.......170.......180.......190.......200.......210.......220.......230........240
                     *999-9999-99999-99999 XXXXXXXXX-XXXXXXXXX-XXXXXXXXX-XXXXX XXXXXXXXX-XXXXXXXXX-XXXX- XXXXXXXXX-XX 999,999,999.99 99/99/9999 99/99/9999

return nil

*******************************************************************************
function AMSR_500C()
  local nPage := 1
  local ncntr := 0
  InitLPT()
  _rptHead( nPage++, .F. )

   z500c->( dbGotop() )
   while ! z500c->( eof() )
      if prow() > 58
         _rptHead( nPage++, .T. )
      endif
	  ncntr++
     @ prow()+1,00       say z500c->brcode+z500c->acctno pict "@R 999-9999-99999-99999"
     @ prow()+0,pcol()+1 say left(z500c->acctname,35) pict "@!"
     @ prow()+0,pcol()+1 say z500c->bank     pict "@!"
     @ prow()+0,pcol()+1 say z500c->chkno
     @ prow()+0,pcol()+1 say transf(z500c->chkamt, AMNT_14)
     @ prow()+0,pcol()+1 say z500c->chkdate
     @ prow()+0,pcol()+1 say z500c->depdate

     z500c->( dbSkip(1) )
  enddo
	@prow()+2,00 say 'Total Number of PDCs : '+STR(ncntr)
  __eject()
return nil
