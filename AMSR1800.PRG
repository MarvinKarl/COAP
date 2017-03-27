*------------------------------------------------------------------------------
*- File Name....: AMSR1800.PRG
*- Author.......: Ariel B. Bulan
*- Date Start...: 31-Jul-2000   02:45:52pm
*------------------------------------------------------------------------------
*- Notice.......: Copyright (c) 2000. ORIX METRO Leasing and Finance Corporation
*------------------------------------------------------------------------------
*- App ID.......: AMS
*- App Name.....: Account Management System
*------------------------------------------------------------------------------
*- Description..: Classification of Receivables by Facility
*------------------------------------------------------------------------------
*- Last Update..:
*-   ABB    01.20.2005  for branch online
*-   MTS    12.29.2006  added AMSHIST2
*-   AGA    02.14.2007  added removed paysked reference
*-   RMS    01.14.2016  fixed display of TOTALS
*------------------------------------------------------------------------------

#include "colf.ch"
#include "inkey.ch"
#include "orix.ch"

#define MAXROW 54

memvar ax_level,g_user_id
private mtemp,mpage := 1

begin sequence
   *-- check for access
   if ! chkpass( procname(), m->AX_LEVEL, m->g_USER_ID )
      break
   endif
   
   if ! amsr1800open()
      break
   endif

   amsr1800main()
end sequence
dbcloseall ()
__mrelease ( "*", .t.)
return

*------------------------------------------------------------------------------
static function amsr1800open()
   local mretval := .f.

   begin sequence
      *-- account master file
      if !netuse( '&g_AMS_PATH\ACCTMAST',.f.,5)
         break
      endif
      set index to &g_AMS_PATH\ACCTMAST,&g_AMS_PATH\ACCTCLNT,&g_AMS_PATH\SURECLNT, &g_AMS_PATH\ACCTACNO
      set order to 4

      *-- client list
      if ! netuse('&g_CIS_PATH'+'\Client.dbf',.f.,5)
         break
      endif
      set index  to &g_CIS_PATH\Cliecd, &g_CIS_PATH\Clienm

      *-- account payment history (current)
      if !netuse( '&g_AMS_PATH\AMSHIST', .f., 10 )   
         break
      endif
      set index to &g_AMS_PATH\AMSHIST           

      *-- account payment history (archieve)
      if !netuse( '&g_AMS_PATH\AMSBACK\AMSHIST2', .f., 10 )      
         break
      endif
      set index to &g_AMS_PATH\AMSBACK\AMSHIST2    
      
      mretval := .t.
   end sequence
return mretval

********************************
static function create_temp()
   memvar mtemp
   local mretval := .f.
   local mstruct := { { 'ACCTNO'     ,'C',14,00 } ,;
                      { 'ACCTNAME'   ,'C',30,00 } ,;
                      { 'AMORT'      ,'N',15,02 } ,;
                      { 'MONTH1'     ,'N',15,02 } ,;
                      { 'MONTH2'     ,'N',15,02 } ,;
                      { 'MONTH3'     ,'N',15,02 } ,;
                      { 'MONTH4'     ,'N',15,02 } ,;
                      { 'MONTH5'     ,'N',15,02 } ,;
                      { 'MONTH6'     ,'N',15,02 } ,;
                      { 'MONTH7'     ,'N',15,02 } ,;
                      { 'MONTH8'     ,'N',15,02 } ,;
                      { 'MONTH9'     ,'N',15,02 } ,;
                      { 'MONTH10'    ,'N',15,02 } ,;
                      { 'MONTH11'    ,'N',15,02 } ,;
                      { 'MONTH12'    ,'N',15,02 } ,;
                      { 'MONTH13'    ,'N',15,02 } ,;
                      { 'MONTH14'    ,'N',15,02 } ,;
                      { 'MONTH15'    ,'N',15,02 } ,;
                      { 'MONTH16'    ,'N',15,02 } ,;
                      { 'MONTH17'    ,'N',15,02 } ,;
                      { 'MONTH18'    ,'N',15,02 } ,;
                      { 'MONTH19'    ,'N',15,02 } ,;
                      { 'MONTH20'    ,'N',15,02 } ,;
                      { 'MONTH21'    ,'N',15,02 } ,;
                      { 'MONTH22'    ,'N',15,02 } ,;
                      { 'MONTH23'    ,'N',15,02 } ,;
                      { 'MONTH24'    ,'N',15,02 } ,;
                      { 'MONTH25'    ,'N',15,02 } ,;
                      { 'MONTH26'    ,'N',15,02 } ,;
                      { 'MONTH27'    ,'N',15,02 } ,;
                      { 'MONTH28'    ,'N',15,02 } ,;
                      { 'MONTH29'    ,'N',15,02 } ,;
                      { 'MONTH30'    ,'N',15,02 } ,;
                      { 'MONTH31'    ,'N',15,02 } ,;
                      { 'MONTH32'    ,'N',15,02 } ,;
                      { 'MONTH33'    ,'N',15,02 } ,;
                      { 'MONTH34'    ,'N',15,02 } ,;
                      { 'MONTH35'    ,'N',15,02 } ,;
                      { 'MONTH36'    ,'N',15,02 } ,;
                      { 'MONTH37'    ,'N',15,02 } ,;
                      { 'OSBAL'      ,'N',15,02 } ,;
                      { 'REMTERM'    ,'N',15,00 } ,;
                      { 'PRINCIPAL'  ,'N',15,02 } ,;
                      { 'OS5M'       ,'N',15,02 } ,;
                      { 'OS5TO50M'   ,'N',15,02 } ,;
                      { 'OS50ABOVE'  ,'N',15,02 } ,;
                      { 'TYPE'       ,'C',5,00 } ;
                    }

   IF TRUE_BRCH == '001'
      mtemp  := uniqfile()
      dbcreate ( ( mtemp ) , mstruct )
      if valtype ( mtemp ) != 'U'
         if netuse ( (mtemp) ,.t.,0 )
            index on type+substr(acctno,5,5)+acctname to (mtemp)  // facility+acctname
            set index to (mtemp)
            mretval := .t.
         endif
      endif
   ELSE
      mRETVAL := .T.
   ENDIF
return mretval

******************************
static function amsr1800main()
   local  mdbf   := savedbf (mdbf), mcolor := setcolor(), mcursor := setcursor(), xSTR
   memvar gtrandate,mtemp
   private mpage := 1,mmonth,mdays,myear,mtitle,mlm,mdate
   private cbrcode := g_PAR_BRCH
   mtitle := 'Classification of Receivables'; mlm := 0 ; mdate  := gtrandate

   if create_temp()
      do while get_mdate( 7 )
         mpage  := 1
         mmonth := month(mdate)
         mdays  := day(mdate)
         myear  := year(mdate)
         *repcontrol ( 'amsr1800prn()','132 Column<Cont.>',,8,33)

         xSTR := CHK_PAR(mPAGE)+CHK_PAR(mMONTH)+CHK_PAR(mDAYS)      +;
                 CHK_PAR(mYEAR)+CHK_PAR(mTITLE)+CHK_PAR(mLM)        +;
                 CHK_PAR(mDATE)+CHK_PAR(gSYS_NAME)+CHK_PAR(gCOMPANY)+;
                 CHK_PAR(gTRANDATE)
         REPCON_OL ( 'AMSR1800PRN()','132 COLUMN<CONT.>',,8,33,,xSTR,.T.)
      enddo
   else
      error ( 'Cannot create temporary file!' )
   endif
   setcolor  (mcolor); setcursor (mcursor) ; restdbf   (mdbf)
return nil

******************************
function amsr1800prn()
    memvar mdate
    local   mclntcode,t_rec:=0, nrec := 1

    private mamort ,m1_30 ,m31_60 ,m61_90 ,m91_180 ,m180_360 ,m360_above ,mtpastdue,mosbal,totpastdue := 0
    private mpamort,mp1_30,mp31_60,mp61_90,mp91_180,mp180_360,mp360_above,mptpastdue,mposbal,ncurosbal := 0
    private mgamort,mg1_30,mg31_60,mg61_90,mg91_180,mp180_360,mp360_above,mgtpastdue,mgosbal
    private msamort,ms1_30,ms31_60,ms61_90,ms91_180,ms180_360,ms360_above,ms361,mstpastdue,msosbal

    private mc1_30,mc31_60,mc61_90,mc91_180,mc180_360,mc360_above,mctpastdue,mcosbal
    private mcg1_30,mcg31_60,mcg61_90,mcg91_180,mcg180_360,mcg360_above,mcgtpastdue,mcgosbal,mccur,mcgosbal
    private ma1_30,ma31_60,ma61_90,ma91_180,ma180_360,ma360_above
    private mag1_30,mag31_60,mag61_90,mag91_180,mag180_360,mag360_above,mcagosbal,mcagcur := 0

    private new := .t.,_nosbal := 0

    mpamort:= mp1_30 := mp31_60:= mp61_90 := mp91_180 := mp180_360   := mp360_above := mptpastdue := mposbal :=0
    mgamort:= mg1_30 := mg31_60:= mg61_90 := mg91_180 := mg180_360   := mg360_above := mgtpastdue := mgosbal :=0
    msamort:= ms1_30 := ms31_60:= ms61_90 := ms91_180 := ms180_360   := ms360_above := mstpastdue := msosbal :=0

    ma1_30:=ma31_60:=ma61_90:=ma91_180:=ma180_360:=ma360_above:= 0
    mag1_30:=mag31_60:=mag61_90:=mag91_180:=mag180_360:=mag360_above := mcagosbal :=0

    setprc(0,0)  ; @ prow(),pcol() say chr(15)
    print_head() ; setfont('CONDENSED');print_subhead()
    @ prow()+1,00 say ''

    Acctmast->(dbgotop())
    //altd()

    mcgosbal  := 0
    mcagosbal := 0
**************    Acctmast->(dbeval({|| if ( val( Acctmast->STATUS) < 3 .and. Acctmast->Valdate <= mdate,;
    Acctmast->(dbeval({|| if ( val( Acctmast->STATUS) < 3  .AND. ACCTMAST->BRCODE == g_PAR_BRCH         ,;
                          eval ({ || mclntcode := Acctmast->Acctname                                    ,;
                                     Acctmast->( dbeval({|| if( val( Acctmast->STATUS ) < 3 .and.        ;
                                                                !_employee_loans(Acctmast->fcltycode)    ;
                                                                .AND. ACCTMAST->BRCODE == g_PAR_BRCH    ,;
                                                                eval({||                                 ;
                                                                        _nosbal := _get_outs()          ,;
                                                                        if ( round(_nosbal,0) != 0      ,;
                                                                             save_to_temp()             ,;
                                                                             nil                         ;
                                                                           )                             ;
                                                                     })                                 ,;
                                                                nil                                      ;
                                                              )}                                       ,,;
                                     {|| !Acctmast->(eof()) .and. Acctmast->Acctname == mclntcode .and.  ;
                                          Acctmast->brcode == cbrcode} ))                               ,;
                                     Acctmast->( dbskip(-1) )                                            ;
                               })                                                                       ,;
                         nil )                                                                           ;
                      }                                                                                ,,;
                      {|| !Acctmast->(eof())  }                                                          ;  && RED 021705 .and. Acctmast->brcode == cbrcode
                     )                                                                                   ;
              )



    print_it()

    ************ _prn_temp()
    __eject()
return nil

/*
****************************************************
static function _employee_loans(cfcltycode)
****************************************************
   local lretval := .f.

   if cfcltycode == '10451' .or. ;
      cfcltycode == '10452' .or. ;
      cfcltycode == '10453' .or. ;
      cfcltycode == '10454'
      lretval := .t.
   endif

return lretval
*/

********************************
static function print_clntcode()
 if Paysked->(dbseek( Acctmast->Acctno)) .and. Paysked->Paydate + 5 < mdate ;
    .and. chkacct() > Acctmast->Amort * 0.10
   new := .t.
   eval ({|| devpos(prow()+1,000)                              ,;
             devoutpict (Acctmast->CLNTCODE,'@R 99-99999')     ,;
             devpos(prow()  ,9)                                ,;
             devout(left(dispclntname(Acctmast->BRCODE+Acctmast->CLNTCODE,40),20))  ;
        })
 endif
return nil

********************************
Static function Chkacct()
local mval,retval:=0

      mval:= if( Paysked->Paydate + 5 > mdate, 5, 0 )
      while Paysked->ACCTNO == Acctmast->ACCTNO .and. Paysked->Paydate <= mdate
         if Paysked->Paydate + mval < mdate
            retval += Paysked->Amort
         endif
         Paysked->(dbskip(1))
      enddo
return retval


**************************
static function print_it()
    memvar msamort,ms1_30,ms31_60,ms61_90,ms91_180,ms180_360,ms360_above,ms361,msosbal
    memvar mpamort,mp1_30,mp31_60,mp61_90,mp91_180,mp180_360,mp360_above,mp361,mposbal

    local mcol := { 37,43,62,81,100,119,138,157,177,197,209,224 }
    local ctype
    (mtemp)->(dbgotop())
    mpamort:=mp1_30:=mp31_60:=mp61_90:=mp91_180:=mp180_360:=mp360_above:=mp361:=0
    mgamort:=mg1_30:=mg31_60:=mg61_90:=mg91_180:=mg180_360:=mg360_above:=mg361:=0

    do while !(mtemp)->(eof())

      @ prow()+1,00 say '--------------------------------'
      if (mtemp)->TYPE == 'LEASE'                            // LEASE
         @ prow()+1,00 say 'LCR - LEASE CONTRACT RECEIVABLES'
      else                                         // LOANS
         @ prow()+1,00 say 'FR  - FINANCE RECEIVABLES       '
      endif
      @ prow()+1,00 say '--------------------------------'

      ctype   := (mtemp)->type
      msamort := ms1_30:=ms31_60:=ms61_90:=ms91_180:=ms180_360:=ms360_above:= ms361 :=msosbal:=0

      do while (mtemp)->type == ctype .and. !(mtemp)->(eof())

         @ prow()+1,00       say substr((mtemp)->ACCTNO,-5,5)
         @ prow(),pcol()+2   say (mtemp)->ACCTNAME
         @ prow(),pcol()+2   say (mtemp)->AMORT      pict '999,999,999,999.99'
         @ prow(),pcol()+2   say (mtemp)->MONTH1     pict '999,999,999,999.99'
         @ prow(),pcol()+2   say (mtemp)->MONTH2     pict '999,999,999,999.99'
         @ prow(),pcol()+2   say (mtemp)->MONTH3     pict '999,999,999,999.99'
         @ prow(),pcol()+2   say (mtemp)->MONTH4     pict '999,999,999,999.99'
         @ prow(),pcol()+2   say (mtemp)->MONTH5  +;
                                 (mtemp)->MONTH6  +;
                                 (mtemp)->MONTH7  +;
                                 (mtemp)->MONTH8  +;
                                 (mtemp)->MONTH9  +;
                                 (mtemp)->MONTH10 +;
                                 (mtemp)->MONTH11 +;
                                 (mtemp)->MONTH12  pict '999,999,999,999.99'

         @ prow(),pcol()+2   say (mtemp)->MONTH13 +;
                                 (mtemp)->MONTH14 +;
                                 (mtemp)->MONTH15 +;
                                 (mtemp)->MONTH16 +;
                                 (mtemp)->MONTH17 +;
                                 (mtemp)->MONTH18 +;
                                 (mtemp)->MONTH19 +;
                                 (mtemp)->MONTH20 +;
                                 (mtemp)->MONTH21 +;
                                 (mtemp)->MONTH22 +;
                                 (mtemp)->MONTH23 +;
                                 (mtemp)->MONTH24 +;
                                 (mtemp)->MONTH25 +;
                                 (mtemp)->MONTH26 +;
                                 (mtemp)->MONTH27 +;
                                 (mtemp)->MONTH28 +;
                                 (mtemp)->MONTH29 +;
                                 (mtemp)->MONTH30 +;
                                 (mtemp)->MONTH31 +;
                                 (mtemp)->MONTH32 +;
                                 (mtemp)->MONTH33 +;
                                 (mtemp)->MONTH34 +;
                                 (mtemp)->MONTH35 +;
                                 (mtemp)->MONTH36   pict '999,999,999,999.99'

         @ prow(),pcol()+2   say (mtemp)->MONTH37   pict '999,999,999,999.99'
         @ prow(),pcol()+2   say (mtemp)->OSBAL     pict '999,999,999,999.99'
         @ prow(),pcol()+2   say (mtemp)->REMTERM   pict '99,999,999,999,999'

         msamort       += (mtemp)->amort
         ms1_30        += (mtemp)->month1
         ms31_60       += (mtemp)->month2
         ms61_90       += (mtemp)->month3
         ms91_180      += (mtemp)->month4
         ms180_360     += (mtemp)->month5+(mtemp)->month9 +;
                          (mtemp)->month6+(mtemp)->month10+;
                          (mtemp)->month7+(mtemp)->month11+;
                          (mtemp)->month8+(mtemp)->month12

         ms360_above   += (mtemp)->month13+(mtemp)->month25+;
                          (mtemp)->month14+(mtemp)->month26+;
                          (mtemp)->month15+(mtemp)->month27+;
                          (mtemp)->month16+(mtemp)->month28+;
                          (mtemp)->month17+(mtemp)->month29+;
                          (mtemp)->month18+(mtemp)->month30+;
                          (mtemp)->month19+(mtemp)->month31+;
                          (mtemp)->month20+(mtemp)->month32+;
                          (mtemp)->month21+(mtemp)->month33+;
                          (mtemp)->month22+(mtemp)->month34+;
                          (mtemp)->month23+(mtemp)->month35+;
                          (mtemp)->month24+(mtemp)->month36

         ms361         += (mtemp)->month37
         msosbal       += (mtemp)->osbal

         mpamort       += (mtemp)->amort
         mp1_30        += (mtemp)->month1
         mp31_60       += (mtemp)->month2
         mp61_90       += (mtemp)->month3
         mp91_180      += (mtemp)->month4
         mp180_360     += (mtemp)->month5+(mtemp)->month9 +;
                          (mtemp)->month6+(mtemp)->month10+;
                          (mtemp)->month7+(mtemp)->month11+;
                          (mtemp)->month8+(mtemp)->month12

         mp360_above   += (mtemp)->month13+(mtemp)->month25+;
                          (mtemp)->month14+(mtemp)->month26+;
                          (mtemp)->month15+(mtemp)->month27+;
                          (mtemp)->month16+(mtemp)->month28+;
                          (mtemp)->month17+(mtemp)->month29+;
                          (mtemp)->month18+(mtemp)->month30+;
                          (mtemp)->month19+(mtemp)->month31+;
                          (mtemp)->month20+(mtemp)->month32+;
                          (mtemp)->month21+(mtemp)->month33+;
                          (mtemp)->month22+(mtemp)->month34+;
                          (mtemp)->month23+(mtemp)->month35+;
                          (mtemp)->month24+(mtemp)->month36

         mp361         += (mtemp)->month37
         mposbal       += (mtemp)->osbal

         mgamort       += (mtemp)->amort
         mg1_30        += (mtemp)->month1
         mg31_60       += (mtemp)->month2
         mg61_90       += (mtemp)->month3
         mg91_180      += (mtemp)->month4
         mg180_360     += (mtemp)->month5+(mtemp)->month9 +;
                          (mtemp)->month6+(mtemp)->month10+;
                          (mtemp)->month7+(mtemp)->month11+;
                          (mtemp)->month8+(mtemp)->month12

         mg360_above   += (mtemp)->month13+(mtemp)->month25+;
                          (mtemp)->month14+(mtemp)->month26+;
                          (mtemp)->month15+(mtemp)->month27+;
                          (mtemp)->month16+(mtemp)->month28+;
                          (mtemp)->month17+(mtemp)->month29+;
                          (mtemp)->month18+(mtemp)->month30+;
                          (mtemp)->month19+(mtemp)->month31+;
                          (mtemp)->month20+(mtemp)->month32+;
                          (mtemp)->month21+(mtemp)->month33+;
                          (mtemp)->month22+(mtemp)->month34+;
                          (mtemp)->month23+(mtemp)->month35+;
                          (mtemp)->month24+(mtemp)->month36

         mg361         += (mtemp)->month37
         mgosbal       += (mtemp)->osbal

         if prow() >= MAXROW
            _page_subtotal()
            mpage++
            __eject ()
            setprc  ( 0,0 )
            @ prow  ()+1, 00 say 'Page : ' + trans(mpage, '999' )
            print_subhead ()
            mpamort:=mp1_30:=mp31_60:=mp61_90:=mp91_180:=mp180_360:=mp360_above:=mp361:=0
         endif

         (mtemp)->(dbskip(+1))

      enddo

      _prn_subtotal ( )

  enddo

  _grand_total ()
  __eject      ()
  _compute_summ()
  __eject      ()

return nil

********************************
*
static function _compute_summ()
********************************
   local mgarray:={},nctr := 1

   aadd( mgarray,{ '1 MO & BELOW            ' ,0,0 } )
   aadd( mgarray,{ 'OVER 1 MO.  TO 2  MOS.  ' ,0,0 } )
   aadd( mgarray,{ 'OVER 2 MOS. TO 3  MOS.  ' ,0,0 } )
   aadd( mgarray,{ 'OVER 3 MOS. TO 4  MOS.  ' ,0,0 } )
   aadd( mgarray,{ 'OVER 4 MOS. TO 12 MOS.  ' ,0,0 } )
   aadd( mgarray,{ 'OVER 12 MOS. TO 36 MOS. ' ,0,0 } )
   aadd( mgarray,{ '36 MOS. AND ABOVE       ' ,0,0 } )

   (mtemp)->(dbgotop())

   do while !(mtemp)->(eof())

      if (mtemp)->TYPE == 'LEASE'                  // LEASE

         mgarray [1] [2] += ( (mtemp)->month1 )
         mgarray [2] [2] += ( (mtemp)->month2 )
         mgarray [3] [2] += ( (mtemp)->month3 )
         mgarray [4] [2] += ( (mtemp)->month4 )
         mgarray [5] [2] += ( (mtemp)->month5 +(mtemp)->month9 +;
                              (mtemp)->month6 +(mtemp)->month10+;
                              (mtemp)->month7 +(mtemp)->month11+;
                              (mtemp)->month8 +(mtemp)->month12 ;
                            )
         mgarray [6] [2] += ( (mtemp)->month13 +(mtemp)->month25 +;
                              (mtemp)->month14 +(mtemp)->month26 +;
                              (mtemp)->month15 +(mtemp)->month27 +;
                              (mtemp)->month16 +(mtemp)->month28 +;
                              (mtemp)->month17 +(mtemp)->month29 +;
                              (mtemp)->month18 +(mtemp)->month30 +;
                              (mtemp)->month19 +(mtemp)->month31 +;
                              (mtemp)->month20 +(mtemp)->month32 +;
                              (mtemp)->month21 +(mtemp)->month33 +;
                              (mtemp)->month22 +(mtemp)->month34 +;
                              (mtemp)->month23 +(mtemp)->month35 +;
                              (mtemp)->month24 +(mtemp)->month36  ;
                            )
         mgarray [7] [2] += ( (mtemp)->month37 )

      else                                         // LOANS
         mgarray [1] [3] += ( (mtemp)->month1 )
         mgarray [2] [3] += ( (mtemp)->month2 )
         mgarray [3] [3] += ( (mtemp)->month3 )
         mgarray [4] [3] += ( (mtemp)->month4 )
         mgarray [5] [3] += ( (mtemp)->month5 +(mtemp)->month9 +;
                              (mtemp)->month6 +(mtemp)->month10+;
                              (mtemp)->month7 +(mtemp)->month11+;
                              (mtemp)->month8 +(mtemp)->month12 ;
                            )
         mgarray [6] [3] += ( (mtemp)->month13 +(mtemp)->month25 +;
                              (mtemp)->month14 +(mtemp)->month26 +;
                              (mtemp)->month15 +(mtemp)->month27 +;
                              (mtemp)->month16 +(mtemp)->month28 +;
                              (mtemp)->month17 +(mtemp)->month29 +;
                              (mtemp)->month18 +(mtemp)->month30 +;
                              (mtemp)->month19 +(mtemp)->month31 +;
                              (mtemp)->month20 +(mtemp)->month32 +;
                              (mtemp)->month21 +(mtemp)->month33 +;
                              (mtemp)->month22 +(mtemp)->month34 +;
                              (mtemp)->month23 +(mtemp)->month35 +;
                              (mtemp)->month24 +(mtemp)->month36  ;
                            )
         mgarray [7] [3] += ( (mtemp)->month37 )

      endif

      (mtemp)->(dbskip(+1))
   enddo

    mtitle := 'Classification of Receivables'

   @ prow()+1,00 say gcompany
   @ prow()+1,00 say mtitle
   @ prow()+1,00 say 'As of '+fr0100month( trans(mmonth,'99') )+' '+trans(mdays,'99')+', '+trans(myear,'9999')

   @ prow()+2,28 say 'LEASING               FINANCING             TOTAL'
   @ prow()+1,28 say "------------------    ------------------    ------------------"
   *                  999,999,999,999.99    999,999,999,999.99    999,999,999,999.99

   @ prow()+2,00 say mgarray [1][1] + space(4) + ;
                     trans(mgarray[1][2],Cc_Amnt18) + space(4) +;
                     trans(mgarray[1][3],Cc_Amnt18) + space(4) +;
                     trans(mgarray[1][3]+mgarray[1][2],Cc_Amnt18)

   @ prow()+1,00 say mgarray [2][1] + space(4) +;
                     trans(mgarray[2][2],Cc_Amnt18) + space(4) +;
                     trans(mgarray[2][3],Cc_Amnt18) + space(4) +; 
                     trans(mgarray[2][3]+mgarray[2][2],Cc_Amnt18)

   @ prow()+1,00 say mgarray [3][1] + space(4) +;
                     trans(mgarray[3][2],Cc_Amnt18) + space(4) +;
                     trans(mgarray[3][3],Cc_Amnt18) + space(4) +;
                     trans(mgarray[3][3]+mgarray[3][2],Cc_Amnt18)

   @ prow()+1,00 say mgarray [4][1] + space(4) +; 
                     trans(mgarray[4][2],Cc_Amnt18) + space(4) +;
                     trans(mgarray[4][3],Cc_Amnt18) + space(4) +;
                     trans(mgarray[4][3]+mgarray[4][2],Cc_Amnt18)

   @ prow()+1,00 say mgarray [5][1] + space(4) +;
                     trans(mgarray[5][2],Cc_Amnt18) + space(4) +;
                     trans(mgarray[5][3],Cc_Amnt18) + space(4) +;
                     trans(mgarray[5][3]+mgarray[5][2],Cc_Amnt18)

   @ prow()+1,00 say mgarray [6][1] + space(4) +;
                     trans(mgarray[6][2],Cc_Amnt18) + space(4) +;
                     trans(mgarray[6][3],Cc_Amnt18) + space(4) +;
                     trans(mgarray[6][3]+mgarray[6][2],Cc_Amnt18)

   @ prow()+1,00 say mgarray [7][1] + space(4) +;
                     trans(mgarray[7][2],Cc_Amnt18) + space(4) +;
                     trans(mgarray[7][3],Cc_Amnt18) + space(4) +;
                     trans(mgarray[7][3]+mgarray[7][2],Cc_Amnt18)

   @ prow()+1,28 say repl("-", 18) + space(04) + repl("-", 18) + space(04) + repl("-", 18)
   @ prow()+1,28 say mgarray[1][2]+;
                     mgarray[2][2]+;
                     mgarray[3][2]+;
                     mgarray[4][2]+;
                     mgarray[5][2]+;
                     mgarray[6][2]+;
                     mgarray[7][2] ;
                  pict Cc_Amnt18

   @ prow()+0,pcol()+4 say mgarray[1][3]+;
                          mgarray[2][3]+;
                          mgarray[3][3]+;
                          mgarray[4][3]+;
                          mgarray[5][3]+;
                          mgarray[6][3]+;
                          mgarray[7][3] ;
                    pict Cc_Amnt18

   @ prow()+0,pcol()+4 say mgarray[1][3]+mgarray[1][2]+;
                          mgarray[2][3]+mgarray[2][2]+;
                          mgarray[3][3]+mgarray[3][2]+;
                          mgarray[4][3]+mgarray[4][2]+;
                          mgarray[5][3]+mgarray[5][2]+;
                          mgarray[6][3]+mgarray[6][2]+;
                          mgarray[7][3]+mgarray[7][2] ;
                      pict Cc_Amnt18

    @ prow()+1,28 say repl("=", 18) + space(04) + repl("=", 18) + space(04) + repl("=", 18)

return nil

********************************
static function save_to_temp ( )
    memvar mtemp,_nosbal
    local mcol := { 37,43,62,81,100,119,138,157,177,197,209,224 }
    local nosbal,namort,nremterm
    local namortctr := 0 ,nfieldctr := 4
    local nosbalctr := 0

    namort    := Acctmast->amort
    nremterm  := round(_nosbal/Acctmast->amort,2)
    if int(nremterm) != nremterm            // ibig sabihin may fraction part
       nremterm := int(nremterm) + 1
    endif

    if nremterm == 0 .and. _nosbal < namort         // osbal < amortization
       nremterm := 1
    endif
    nosbalctr := _nosbal

    (mtemp)->(dbappend())
    (mtemp)->acctno    := Acctmast->acctno
    (mtemp)->acctname  := Acctmast->acctname
    (mtemp)->osbal     := _nosbal
    (mtemp)->amort     := namort
    (mtemp)->remterm   := nremterm
    (mtemp)->principal := Acctmast->principal

  *****  if (mtemp)->remterm > 0         // special purpose only,can be removed
       do case                      // need osbal for profile of loan portfolio
                                    // august 2, 2000
                                    //
          case Acctmast->principal >  50000000
             (mtemp)->OS50ABOVE := _nosbal
          case Acctmast->principal >= 5000000
             (mtemp)->OS5TO50M  := _nosbal
          otherwise
             (mtemp)->OS5M      := _nosbal
       endcase

******    endif
    
    if substr(Acctmast->fcltycode,1,3) = '103'            // LEASE
       (mtemp)->type := 'LEASE'
    else
       (mtemp)->type := 'LOANS'
    endif

    do while namortctr <= _nosbal .and. namort > 0
       namortctr += namort

       if namortctr <= _nosbal

          if nfieldctr <= 40                       // from month1..month36
             (mtemp)->(fieldput(nfieldctr,namort))
          else
             (mtemp)->month37 += namort            //
          endif

          nosbalctr -= namort
          nfieldctr ++              

       else

          if nfieldctr > 40
             namortctr        -= namort    // less the added amortization
             (mtemp)->month37 += (_nosbal-namortctr)
             namortctr        += namort    // add amort again to exit the loop
          else

             if namort > _nosbal
                (mtemp)->(fieldput(nfieldctr ,_nosbal ))
             else

               if namortctr > _nosbal
                  namortctr  -=namort      // less the added amortization
                  (mtemp)->(fieldput(nfieldctr ,_nosbal-namortctr ))
                  namortctr  +=namort      // add amort again to exit the loop
               endif

             endif

          endif

       endif

    enddo

return nil

******************************
static function print_head()
    memvar mtitle,mpage,gsys_name,gcompany,mlm,mmonth,mdays,myear
    mtitle := 'Classification of Receivables'
    prnreptitle  ( 132,mlm,mpage,mtitle,'Program ID:AMSR1800',gsys_name,gcompany)
    pagecenter   ( prow()+1,132,'As of '+fr0100month( trans(mmonth,'99') )+' '+trans(mdays,'99')+', '+trans(myear,'9999') )
    @ prow()+1,0 say ''
return nil

*********************************
static function print_subhead()
    setfont ( 'CONDENSED' )
    @prow()+1,00 say "컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�  컴컴컴컴컴컴컴컴컴  컴컴컴컴컴컴컴컴컴  컴컴컴컴컴컴컴컴컴  컴컴컴컴컴컴컴컴컴  컴컴컴컴컴컴컴컴컴  컴컴컴컴컴컴컴컴컴  컴컴컴컴컴컴컴컴컴  컴컴컴컴컴컴컴컴컴  컴컴컴컴컴컴컴컴컴  컴컴컴컴컴컴컴컴컴" 
    @prow()+1,00 say "Client No./Name                        Amortization        1-30 Days           31-60 Days          61-90 Days          91-120 Days         121-360 Days        361-1080            1081 Days & Above   Outstanding         Remaining         " 
    @prow()+1,00 say "                                                           (1 Month)           (2 Months)          (3 Months)          (4 Months)          (5-12 Months)       (13-36 Months)      37 mos. and above   Balance             Term              " 
    @prow()+1,00 say "컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�  컴컴컴컴컴컴컴컴컴  컴컴컴컴컴컴컴컴컴  컴컴컴컴컴컴컴컴컴  컴컴컴컴컴컴컴컴컴  컴컴컴컴컴컴컴컴컴  컴컴컴컴컴컴컴컴컴  컴컴컴컴컴컴컴컴컴  컴컴컴컴컴컴컴컴컴  컴컴컴컴컴컴컴컴컴  컴컴컴컴컴컴컴컴컴" 
                     *99999  xxxxxxxxx-xxxxxxxxx-xxxxxxxxx-  999,999,999,999.99  999,999,999,999.99  999,999,999,999.99  999,999,999,999.99  999,999,999,999.99  999,999,999,999.99  999,999,999,999.99  999,999,999,999.99  999,999,999,999.99  9999
                     *123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-
return nil

*------------------------------------------------------------------------------
static function l_prnline( pc_char, pn_len )
   @ prow()+1,00 say space(39) +;
                     repl("�",pn_len) +"  "+;
                     repl("�",pn_len) +"  "+;
                     repl("�",pn_len) +"  "+;
                     repl("�",pn_len) +"  "+;
                     repl("�",pn_len) +"  "+;
                     repl("�",pn_len) +"  "+;
                     repl("�",pn_len) +"  "+;
                     repl("�",pn_len) +"  "+;
                     repl("�",pn_len)
return nil

*------------------------------------------------------------------------------
static function _prn_subtotal()
   l_prnline( "�",18)  
   @ prow()+1,000       say padr('CLASSIFICATION TOTAL : ', 38)
   @ prow()+0,pcol()+1  say msamort     pict Cc_Amnt18
   @ prow()+0,pcol()+2  say ms1_30      pict Cc_Amnt18
   @ prow()+0,pcol()+2  say ms31_60     pict Cc_Amnt18
   @ prow()+0,pcol()+2  say ms61_90     pict Cc_Amnt18
   @ prow()+0,pcol()+2  say ms91_180    pict Cc_Amnt18
   @ prow()+0,pcol()+2  say ms180_360   pict Cc_Amnt18
   @ prow()+0,pcol()+2  say ms360_above pict Cc_Amnt18
   @ prow()+0,pcol()+2  say ms361       pict Cc_Amnt18
   @ prow()+0,pcol()+2  say msosbal     pict Cc_Amnt18
return nil

*------------------------------------------------------------------------------
static function _page_subtotal()
   l_prnline( "�",18)  
   @ prow()+1,000       say padr('PAGE TOTAL : ', 38)
   @ prow()+0,pcol()+1  say mpamort     pict Cc_Amnt18
   @ prow()+0,pcol()+2  say mp1_30      pict Cc_Amnt18
   @ prow()+0,pcol()+2  say mp31_60     pict Cc_Amnt18
   @ prow()+0,pcol()+2  say mp61_90     pict Cc_Amnt18
   @ prow()+0,pcol()+2  say mp91_180    pict Cc_Amnt18
   @ prow()+0,pcol()+2  say mp180_360   pict Cc_Amnt18
   @ prow()+0,pcol()+2  say mp360_above pict Cc_Amnt18
   @ prow()+0,pcol()+2  say mp361       pict Cc_Amnt18
   @ prow()+0,pcol()+2  say mposbal     pict Cc_Amnt18
return nil

*------------------------------------------------------------------------------
static function _grand_total()
   l_prnline( "�",18)
   @ prow()+1,000       say PADR('GRAND TOTAL : ', 38)
   @ prow()+0,pcol()+1  say mgamort     pict Cc_Amnt18
   @ prow()+0,pcol()+2  say mg1_30      pict Cc_Amnt18
   @ prow()+0,pcol()+2  say mg31_60     pict Cc_Amnt18
   @ prow()+0,pcol()+2  say mg61_90     pict Cc_Amnt18
   @ prow()+0,pcol()+2  say mg91_180    pict Cc_Amnt18
   @ prow()+0,pcol()+2  say mg180_360   pict Cc_Amnt18
   @ prow()+0,pcol()+2  say mg360_above pict Cc_Amnt18
   @ prow()+0,pcol()+2  say mg361       pict Cc_Amnt18
   @ prow()+0,pcol()+2  say mgosbal     pict Cc_Amnt18
  l_prnline( "=",18)
return nil

****************************
static function _get_outs( )
   local nretval := Acctmast->credamt, ddate := ctod ('') //
   local dretval := ctod('')
   local pgn:=1
   local tot_amrt := 0, tot_pen := 0, npent_s := 0,ncredamt:= Acctmast->Credamt
   local Pay_:= { 'Paymt',;              // 1
                  'Ret. Check',;         // 2
                  'ROPOA',;              // 3
                  'Db_Memo ',;           // 4
                  'Misposting',;         // 5
                  'Terminatx',;          // 6
                  'Cr_Memo  ',;          // 7
                  'REVIEW ',;            // 8
                  ' ',;                  // 9
                  'O_T Check',;          //10
                  'PDR ',;               //11
                  'LEGAL ',;             //12
                  'LEGAL ',;             //13
                  'Current',;            //14
                  'Current',;            //15
                  'Balance Forwarded'  ;
                } //16
   local tot_or:=0, tot_am := 0, tot_penal := 0
   local xoramount := xamort := xpenal:=0,pprd:={},pperiod,unpd_pen := 0
   local xacctno,xornum,xrefdate,xcode,nrow:= { 05,19,32,43,60,86,93,117 }
**********   local prate:=xprate,pdate:= _ddate, xblk
   local _ddate := mdate

//aga.06.06.2006.removed
//   xblk := { || Paysked->Lastpay <= pdate }

Amshist->( dbseek(cbrcode+Acctmast->Acctno) )

if Amshist->  ( dbseek(cbrcode+Acctmast->Acctno) )
   
   ncredamt := Acctmast->Credamt

   do while Amshist->Acctno == Acctmast->Acctno .and. !Amshist->(eof()) .and. ;
            Amshist->brcode == cbrcode

         xrefdate  := Amshist->Refdate
         xornum    := Amshist->Ornumber
         xacctno   := Amshist->Acctno
         xcode     := Amshist->Paycode
         unpd_pen  += Amshist->Unpd_pnlty

         do while Amshist->Acctno   == xAcctno  .and. ;
                  Amshist->Ornumber == xornum   .and. ;
                  Amshist->Refdate  == xrefdate .and. ;
                  Amshist->Paycode  == xcode    .and. ;
                  Amshist->brcode   == cbrcode  .and. ;
                 !Amshist->(eof())

             if xrefdate <= _ddate

                xOramount += if ( val( Amshist->Paycode ) < 8,;
                                  Amshist->Oramount,;
                                  0;
                                )
                xamort    += Amshist->Amort
                xpenal    += Amshist->Penalty

                if ( !empty( Amshist->Paydate ) ,;
                      aadd ( pprd,Amshist->Paydate ),;
                      nil ;
                   )

             endif

             Amshist->(dbskip(+1))
         enddo

         pperiod := if ( len (pprd) > 0,;
                         dtoc( pprd[ 1 ] ) + ;
                         if ( len(pprd ) > 1,;
                              '-' +dtoc(atail(pprd)),;
                              ' ' ;
                            ),;
                         ' ' ;
                       )

/*********************************
         if alltrim(xcode) == '1' // PAYMENT ? ( Sept. 07, 1999 )
            dretval     := xrefdate
            clastperiod := pperiod + '->'+ pay_ [ val( xcode ) ]
         else
            dretval     := xrefdate
            clastperiod := pperiod + '->'+ pay_ [ val( xcode ) ]
         endif
************************/

         nretval -= (xamort)

         pprd      := {}
         tot_or    += xOramount
         tot_am    += xamort
         tot_penal += xPenal
         xoramount := xamort := xpenal:=0

   enddo

endif

Amshist2->  ( dbseek(cbrcode+Acctmast->Acctno) )

if Amshist2->( dbseek(cbrcode+Acctmast->Acctno) )
   ncredamt := Acctmast->Credamt

   do while AMSHIST2->Acctno == Acctmast->Acctno .and. !AMSHIST2->(eof()) .and. ;
            AMSHIST2->Brcode == cbrcode

         xrefdate  := AMSHIST2->Refdate
         xornum    := AMSHIST2->Ornumber
         xacctno   := AMSHIST2->Acctno
         xcode     := AMSHIST2->Paycode
         unpd_pen  += AMSHIST2->Unpd_pnlty

         do while AMSHIST2->Acctno   == xAcctno  .and. ;
                  AMSHIST2->Ornumber == xornum   .and. ;
                  AMSHIST2->Refdate  == xrefdate .and. ;
                  AMSHIST2->Paycode  == xcode    .and. ;
                  AMSHIST2->brcode   == cbrcode  .and. ;
                 !AMSHIST2->(eof())

             if xrefdate <= _ddate

                xOramount += if ( val( AMSHIST2->Paycode ) < 8,;
                                  AMSHIST2->Oramount,;
                                  0;
                                )
                xamort    += AMSHIST2->Amort
                xpenal    += AMSHIST2->Penalty

                if ( !empty( AMSHIST2->Paydate ) ,;
                      aadd ( pprd,AMSHIST2->Paydate ),;
                      nil ;
                   )

             endif

             AMSHIST2->(dbskip(+1))
         enddo

         pperiod := if ( len (pprd) > 0,;
                         dtoc( pprd[ 1 ] ) + ;
                         if ( len(pprd ) > 1,;
                              '-' +dtoc(atail(pprd)),;
                              ' ' ;
                            ),;
                         ' ' ;
                       )

/*********************************
         if alltrim(xcode) == '1' // PAYMENT ? ( Sept. 07, 1999 )
            dretval     := xrefdate
            clastperiod := pperiod + '->'+ pay_ [ val( xcode ) ]
         else
            dretval     := xrefdate
            clastperiod := pperiod + '->'+ pay_ [ val( xcode ) ]
         endif
************************/

         nretval -= (xamort)

         pprd      := {}
         tot_or    += xOramount
         tot_am    += xamort
         tot_penal += xPenal
         xoramount := xamort := xpenal:=0

   enddo
endif

return nretval