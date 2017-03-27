/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ program id.........:  amsr2005.prg                                           ³
³ description........:  List of overdue ( Tokyo Format )                       ³
³ author.............:  Ariel B. Bulan                                         ³
³ date...............:  04:13pm 7-Aug-1995                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                       U P D A T E S                                          ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³      Who        ³     When      ³               Why                          ³
³      aga        ³  14.02.2007   ³  neo paysked support for modules           ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include "Colf.ch"
#include "Inkey.ch"

#define MAXROW 55
   memvar ax_level,g_user_id
   private mtemp
   if chkpass( procname(),ax_level,g_user_id )
      if amsr0500open()
         nosnow       (.t.)
         amsr0500main ()
         nosnow       (.f.)
      endif
      dbcloseall()
      ferase ( mtemp ) ; ferase ( mtemp + '.dbf' ) ; ferase ( mtemp + '.ntx' )
      __mrelease( "*", .t.)
   endif
return
******************************
static function amsr0500main()
******************************
   local   mdbf  := savedbf(mdbf), mcolor := setcolor(), mcursor := setcursor()
   memvar  gtrandate
   private mpage := 1, mmonth := month(gtrandate), myear := year(gtrandate),;
           mperiod

   if create_temp()
      fshadow( 8, 30, 11, 47, 2, 'gr+/g' )
      if eval ( {|x| setcursor( 3 ) , x := get_month() , setcursor( 0 ) , x })
         access_delinq ()                           // Traverse Delqhead.dbf
         *repcontrol    ('amsr0500print()',,,09,37)  // print it!
         repcon_ol    ('amsr0500print()',,,09,37,,,.F.)
      endif
   else
      error ( 'Cannot create temporary file!' )
   endif
   setcolor (mcolor) ; setcursor (mcursor) ; restdbf (mdbf)
return nil
*********************************
static function access_delinq ()
*********************************
   memvar mmonth,myear

   Delqhead -> ( dbgotop() )
   Delqhead -> ( dbeval ( {|| Delqdtls -> ( dbseek ( Delqhead -> ACCTNO ) ) ,;
                              if ( getlastdate () != 0,;
                                   addrec() ,;
                                   nil ;
                                 ) ;
                          } ,,;
                          {|| !Delqhead->( eof() ) ;
                          } ;
                        ) ;
               )
return nil
*********************************
static function getlastdate ()
*********************************
   memvar mmonth,myear
   local mrecno := 0

   Delqdtls -> ( dbeval ( {|| if ( month( Delqdtls -> DATE ) == mmonth .and. ;
                                   year ( Delqdtls -> DATE ) == myear ,;
                                   mrecno := Delqdtls -> ( recno() ) ,;
                                   nil ;
                                 ) ;
                          },,;
                          {|| Delqdtls -> ACCTNO == Delqhead -> ACCTNO .and.;
                             !Delqdtls -> ( eof() ) ;
                          };
                        ) ;
               )
   if mrecno == 0
      Delqdtls -> ( dbgoto ( lastrec()+1 ) )
   else
      Delqdtls -> ( dbgoto ( mrecno ) )
   endif
return mrecno
*****************************
static function addrec()
*****************************
   memvar mtemp
   local  mamtover := 0 ,mprdover := 0

   if ( mtemp ) -> ( netlock ( 'A',0 ) )
      getamtprd  ( @mamtover,@mprdover )
      ( mtemp ) -> ACCTNO   := Delqdtls -> ACCTNO
      ( mtemp ) -> STATUS   := getstatus  ( )     // Acctmast -> STATUS
      ( mtemp ) -> DATEOVER := getdateover( )     // Paysked -> PAYDATE
      ( mtemp ) -> AMTOVER  := mamtover           // summation of INTAMT+PRNAMT
      ( mtemp ) -> PRDOVER  := mprdover           // no. of records summed
   endif
   ( mtemp ) -> ( dbunlock() )
return nil
************************************************
static function getstatus  ( )
************************************************
   Acctmast -> ( dbseek ( Delqdtls -> ACCTNO ) )
return Acctmast -> STATUS
************************************************
static function getamtprd( mamtover,mprdover )
************************************************
   local mrepdate := rep_date()

alert(dtos(mrepdate))

//aga.26.04.2006.marked for modification
   if Paysked -> ( dbseek ( Delqdtls -> ACCTNO ) )
      Paysked -> ( dbeval ( {|| eval ( {|| mamtover += ( Paysked->INTAMT + Paysked->PRNAMT ),;
                                           mprdover ++ ;
                                       };
                                     );
                            },,;
                            {|| !Paysked -> ( eof() ) .and. ;
                                 Paysked -> ACCTNO == Delqdtls -> ACCTNO .and. ;
                                 Paysked -> PAYDATE < mrepdate ;
                            };
                          );
                 )
   endif
//......................................

return nil
********************************
static function rep_date()
********************************
   memvar mmonth,myear
   local mretval := ctod ( right( '0'+ ltrim(trans(mmonth,'99')),2) + ;
                           '/01/'                                   + ;
                           ltrim(trans(myear,'9999'))                 ;
                         )
return mretval
********************************
static function getdateover()
********************************
   Paysked -> ( dbseek ( Delqdtls -> ACCTNO ) )
//aga.26.04.2006.marked for modification

return Paysked -> PAYDATE
********************************
function amsr0500print()
********************************
   private mpage := 1
   setprc     ( 0,0 )
   printhead  ()
   printsubhead()
   print_all  ()
   prnfooting ()
   __eject    ()
   setfont    ( 'PICA' )
return nil
******************************
static function print_all()
******************************
   local mgrandamt := 0 ,mgrandosbal := 0
   memvar  mtemp
   ( mtemp ) -> ( dbgotop () )
   ( mtemp ) -> ( dbeval ( {|| byfacility( substr( ( mtemp ) -> ACCTNO,5,5 ),@mgrandamt,@mgrandosbal ) ;
                           },,;
                           {|| !( mtemp ) -> ( eof() )  };
                         );
                )
   @ prow() + 1, 116 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   @ prow() + 1, 001 say 'Grand Total : '
   @ prow()    , 116 say trans( mgrandamt  ,'999,999,999.99' )
   @ prow()    , 131 say trans( mgrandosbal,'999,999,999.99' )
   @ prow() + 1, 116 say '============== =============='
return nil
********************************************************
static function byfacility( mfc,mgrandamt,mgrandosbal )
********************************************************
   local mfcamt := 0 , mfcosbal := 0
   local mcounter := 0
   printfacility( mfc )

   ( mtemp ) -> ( dbeval ( {|| bystatus ( (mtemp) -> STATUS,mfc,@mfcamt, @mfcosbal,@mcounter );
                           } ,,;
                           {|| !( mtemp ) -> ( eof() ) .and. ;
                               substr ( ( mtemp ) -> ACCTNO,5,5 ) == mfc ;
                           };
                         );
                )
   @ prow() + 1, 116 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   @ prow() + 1, 001 say 'Facility Total : '
   @ prow()    , 116 say trans( mfcamt  ,'999,999,999.99' )
   @ prow()    , 131 say trans( mfcosbal,'999,999,999.99' )
   if !( mtemp ) -> ( eof() )
      fejectpause  ()
      printhead    ()
      printsubhead ()
   endif
   mgrandamt    += mfcamt
   mgrandosbal  += mfcosbal
   ( mtemp ) -> ( dbskip ( -1 ) )
return nil
*******************************************************************
static function bystatus ( mstat,mfc,mfcamt,mfcosbal,mcounter )
*******************************************************************
   local mstamt := 0, mstosbal := 0
   local mstats  := { '1 - 2 MONTHS        ' , ;
                      '3 - 6 MONTHS        ' , ;
                      'PAST DUE ACCOUNTS   ' , ;
                      'ITEMS IN LITIGATION ' , ;
                      'REPOSSESSED ACCOUNTS'   ;
                    }

   if mstat == '1'
      printstats ( mstats,'1' )
   else
      printstats ( mstats, ltrim( str ( val ( mstat ) + 1 ) ) )
   endif                                       
   ( mtemp ) -> ( dbeval ( {|| bybranches( mstat,@mcounter,mstats,mfc,substr ( ( mtemp) -> ACCTNO,3,2 ),@mstamt, @mstosbal );
                           },,;
                           {|| ! ( mtemp ) -> ( eof() )       .and. ;
                                 ( mtemp ) -> STATUS == mstat .and. ;
                                 substr ( ( mtemp ) -> ACCTNO,5,5 ) == mfc ;
                           };
                         );
                 )
   ( mtemp ) -> ( dbskip ( -1 ) )
   @ prow() + 1, 116 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   @ prow() + 1, 001 say 'Status Total : '
   @ prow()    , 116 say trans( mstamt  ,'999,999,999.99' )
   @ prow()    , 131 say trans( mstosbal,'999,999,999.99' )
   mfcamt    += mstamt
   mfcosbal  += mstosbal
return nil
****************************************************************************
static function bybranches ( mstat,mcounter,mstats,mfc,mbr,mstamt,mstosbal )
****************************************************************************
   local mbramt := 0, mbrosbal := 0
   printbranch ( mbr )

   ( mtemp ) -> ( dbeval ( {|| mcounter ++  ,;
                               if ( mstat == '1'  ,;
                                    for_months ( @mcounter,mstats,'1',mfc,mbr,@mbramt,@mbrosbal ),;
                                    assignprint ( mcounter,@mbramt,@mbrosbal ) ;
                                  );
                           },,;
                           {|| ! ( mtemp ) -> ( eof() )  .and. ;
                                 substr ( ( mtemp ) -> ACCTNO,3,2) == mbr .and.;
                                 ( mtemp ) -> STATUS == mstat             .and.;
                                 substr ( ( mtemp ) -> ACCTNO,5,5 ) == mfc ;
                           };
                         );
                 )
   ( mtemp ) -> ( dbskip ( -1 ) )
   @ prow() + 2, 116 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   @ prow() + 1, 001 say 'Branch Total : '
   @ prow()    , 116 say trans( mbramt  ,'999,999,999.99' )
   @ prow()    , 131 say trans( mbrosbal,'999,999,999.99' )
   mstamt   += mbramt
   mstosbal += mbrosbal
return nil
******************************************************************************
static function for_months ( mcounter,mstats,mstat,mfc,mbr,mbramt,mbrosbal )
******************************************************************************
   memvar mtemp
   local mstatprinted := .f.

   mcounter --
   ( mtemp ) -> ( dbeval ( {|| mcounter ++  ,;
                               if ( ( mtemp ) -> PRDOVER <= 2,;
                                    assignprint ( mcounter,@mbramt,@mbrosbal ),;
                                    eval ({|| if ( !mstatprinted,;
                                                    eval ({|| printstats(mstats,'2'),;
                                                              mstatprinted:= .t.  ;
                                                         }),;
                                                    nil ;
                                                 ) ,;
                                              assignprint ( mcounter,@mbramt,@mbrosbal ) ;
                                         });
                                  );
                           },,;
                           {|| ! ( mtemp ) -> ( eof() ) .and.      ;
                                 ( mtemp ) -> STATUS == '1'  .and. ;
                                 substr ( ( mtemp ) -> ACCTNO,3,2) == mbr .and.;
                                 substr ( ( mtemp ) -> ACCTNO,5,5 ) == mfc ;
                           };
                         );
                 )
   ( mtemp ) -> ( dbskip ( -1 ) )
return nil
********************************************************
static function assignprint ( mcounter,mbramt,mbrosbal )
********************************************************
   memvar mtemp
   local  mstats := {} ,;
          mcltshort,munit ,mvaldate,mdateover,mcredamt,mamtover,mosbal,mrecover,munsecured,mclascoll,;
          macctno  ,munit2,mterm   ,          mamort  ,mprdover,;
          msigner  ,mprincipal     ,          mrv ,;
          mtitle

   Acctmast -> ( dbseek ( ( mtemp ) -> ACCTNO ) )
   mbramt   += ( mtemp ) -> AMTOVER          //  Amount Overdue    ( BRANCH )
   mbrosbal +=  Acctmast -> OSBAL            //  Outstanding Total ( TOTAL  )
   getstats( mstats )
   mcltshort  := getclient ()
   munit      := Acctmast  -> UNIT
   mvaldate   := Acctmast  -> VALDATE
   mdateover  := ( mtemp ) -> DATEOVER
   mcredamt   := Acctmast  -> CREDAMT
   mamtover   := ( mtemp ) -> AMTOVER
   mosbal     := Acctmast  -> OSBAL
   mrecover   := getrecover ()
   munsecured := Delqhead  -> UNSECURED
   mclascoll  := Delqhead  -> CLASCOLL
   macctno    := Acctmast  -> ACCTNO
   munit2     := Acctmast  -> UNIT2
   mterm      := Acctmast  -> TERM
   mamort     := Acctmast  -> AMORT
   mprdover   := ( mtemp ) -> PRDOVER
   msigner    := getsigner()
   mprincipal := Acctmast -> PRINCIPAL
   mrv        := round( mprincipal  * ( Acctmast -> RV / 100 ), 2 )
   mtitle     := Signers  -> TITLE
   printrec ( mstats   ,;
              mcltshort,munit ,mvaldate,mdateover,mcredamt,mamtover,mosbal,mrecover,munsecured,mclascoll,;
              macctno  ,munit2,mterm   ,          mamort  ,mprdover,;
              msigner  ,mprincipal     ,          mrv ,;
              mtitle   ,mcounter;
            )
return nil
***********************************************************************************************************************
static function printrec ( mstats   ,;
                           mcltshort,munit ,mvaldate,mdateover,mcredamt,mamtover,mosbal,mrecover,munsecured,mclascoll,;
                           macctno  ,munit2,mterm   ,          mamort  ,mprdover,;
                           msigner  ,mprincipal     ,          mrv ,;
                           mtitle   ,mcounter )
***********************************************************************************************************************
   local mc := { 0,6,37,79,90,101,116,131,146,161,176,201 }
   local mstatctr := 1, mctr

   @ prow()+1, mc [01] say trans( mcounter, '9,999' )
   @ prow()  , mc [02] say mcltshort
   @ prow()  , mc [03] say munit
   @ prow()  , mc [04] say mvaldate
   @ prow()  , mc [05] say mdateover
   @ prow()  , mc [06] say trans ( mcredamt,'999,999,999.99' )
   @ prow()  , mc [07] say trans ( mamtover,'999,999,999.99' )
   @ prow()  , mc [08] say trans ( mosbal  ,'999,999,999.99' )
   @ prow()  , mc [09] say trans ( mrecover,'999,999,999.99' )
   @ prow()  , mc [10] say trans ( munsecured,'999,999,999.99' )
   @ prow()  , mc [11] say space ( 11 ) + mclascoll
   if mstatctr <= len ( mstats )
      prndelqstatus( mstats,mc[12],mstatctr )
      mstatctr++
   endif
   if prow() >= MAXROW
      fejectpause  ()
      printhead    ()
      printsubhead ()
   endif
   @ prow()+1, mc [02] say trans ( macctno,'@R 9999-99999-99999' )
   @ prow()  , mc [03] say munit2
   @ prow()  , mc [04] say trans ( mterm  ,'999') + ' Months'
   @ prow()  , mc [06] say trans ( mamort ,'999,999,999.99' )
   @ prow()  , mc [07] say trans ( mprdover,'999') + '  Month/(s)'
   if mstatctr <= len ( mstats )
      prndelqstatus( mstats,mc[12],mstatctr )
      mstatctr++
   endif
   if prow() >= MAXROW
      fejectpause  ()
      printhead    ()
      printsubhead ()
   endif
   @ prow()+1, mc [02] say msigner
   @ prow()  , mc [03] say trans ( mprincipal,'999,999,999.99' )
   @ prow()  , mc [06] say trans ( mrv       ,'999,999,999.99' )
   if mstatctr <= len ( mstats )
      prndelqstatus( mstats,mc[12],mstatctr )
      mstatctr++
   endif
   if prow() >= MAXROW
      fejectpause  ()
      printhead    ()
      printsubhead ()
   endif
   @ prow()+1, mc [02] say mtitle
   for mctr := mstatctr to len ( mstats )
       prndelqstatus( mstats,mc[12],mctr )
       if mctr+1 <= len ( mstats )
          if prow() >= MAXROW
             fejectpause  ()
             printhead    ()
             printsubhead ()
          endif
          @ prow()+1, 00 say ''
       endif
   next mctr
return nil
**************************************************
static function prndelqstatus ( mstats,mc,mindex )
**************************************************
   @ prow(), mc say mstats [ mindex ]
return nil
************************************
static function getstats( mstats )
************************************
   memvar mmonth,myear
   Delqdtls -> ( dbseek ( ( mtemp ) -> ACCTNO ) )
   Delqdtls -> ( dbeval ( { || if ( month( Delqdtls -> DATE ) == mmonth .and. ;
                                          year ( Delqdtls -> DATE ) == myear ,;
                                    aadd( mstats , Delqdtls -> STATUS ),;
                                    nil ;
                                  );
                          },,;
                          { || !Delqdtls -> ( eof() ) .and. ;
                                Delqdtls -> ACCTNO == ( mtemp ) -> ACCTNO ;
                          };
                        );
               )
return nil
********************************
static function getsigner()
********************************
  Signers -> ( dbseek( Acctmast -> CLNTCODE ) )
return Signers -> SIGNER
/*
****************************************************
static function getclient ()
****************************************************
   Client -> ( dbseek ( Acctmast -> CLNTCODE ) )
return Client -> SHRTNAME
*/
****************************************************
static function getrecover ()
****************************************************
   memvar mtemp
   Delqhead -> ( dbseek ( ( mtemp ) -> ACCTNO ) )
return Delqhead -> RECOVER
/*
******************************
static function printclnt()
******************************
   Client->(dbseek(Caheader->CLNTCODE))
return Client->FULLNAME
*/
******************************
static function printhead()
******************************
   setfont    ( 'PICA')
   pagecenter ( prow()+1,236, chr(14)+'List of Overdue'+chr(14) )
   setfont    ( 'CONDENSED' )
   @ prow()+2, 000 say '(Unit : in Pesos )'
   @ prow()  , 207 say 'As of '+ printdate()
return nil
/*
******************************
static function printdate()
******************************
   memvar mtrandate
return alltrim(cmonth(mtrandate))+' '+ltrim(trans(day(mtrandate),'99'))+', '+ltrim(trans(year(mtrandate),'9999'))
*/
******************************
static function prnfooting()
******************************
   local i

   for i := prow() to MAXROW
       @ prow() + 1 , 00 say ' '
   next i
   @ prow()+1, 000 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   @ prow()+1, 000 say '    * Note 1 : "Outstanding Receivables" + "Amount Overdue"+ "RV" + "Deposit Amount Received" : NBV = Net Book Value'
   @ prow()+1, 000 say '    * Note 2 : (1) Estimated Market Value of Leased Property and/or Mortgaged Property  (2) Additional Expense (/\)  (3) Assign of Earning  (4) Insurance  (5) Amount of Guaranty'
   @ prow()+1, 000 say '    * Note 3 : (A) Confident of full recovery    (B) Uncertain whether partial or full recovery    (C) No possibility of recovery'
return nil
******************************
static function printsubhead()
******************************
   @ prow()+1, 000 say 'ÚÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
   @ prow()+1, 000 say '³    ³                              ³                                         ³Execution ³          ³Total Contract³   Amount     ³ (I) Credit   ³(II) Estimated³    (III)     ³         (IV)           ³1) Reason for Overdue                  ³'
   @ prow()+1, 000 say '³    ³                              ³            Type of Equipment            ³  Date    ³ Date of  ³  Receivable  ³   Overdue    ³Balance   * 1 ³     Recovery ³  Unsecured   ³Classification of       ³2) Action Taken / or To be taken       ³'
   @ prow()+1, 000 say '³ No ³       Name of Lessee         ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ´ Overdue  ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´     Amount   ³  Amount      ³Estimated Collection    ³3) Others                              ³'
   @ prow()+1, 000 say '³    ³                              ³           (Purchase Amount)             ³(Lease    ³ Commenced³(Monthly Lease³  (Period     ³  ( N B V )   ³     * 2      ³  Out of (I)  ³of (III) into A, B or C ³                                       ³'
   @ prow()+1, 000 say '³    ³                              ³                                         ³  Term    ³          ³ Rent : RV)   ³   Overdue)   ³              ³              ³              ³          * 3           ³                                       ³'
   @ prow()+1, 000 say 'ÀÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
return nil
********************************
static function create_temp()
********************************
   memvar mtemp
   local mretval := .f.
   local mstruct := { { 'ACCTNO'  ,'C',14,00 } ,;
                      { 'STATUS'  ,'C',01,00 } ,;
                      { 'DATEOVER','D',08,00 } ,;
                      { 'AMTOVER' ,'N',16,02 } ,;
                      { 'PRDOVER' ,'N',03,00 }  ;
                    }

   mtemp  := uniqfile()
   dbcreate ( ( mtemp ) , mstruct )
   if valtype ( mtemp ) != 'U'
      if netuse ( (mtemp) ,.t.,0 )
         index on substr( ACCTNO,5,5) +;      // Facility
                  STATUS              +;      // STATUS
                  str( PRDOVER,3)     +;      // PERIOD OVERDUE
                  substr( ACCTNO,3,2)  ;      // Branch
                  to &mtemp
         set index to &mtemp
         mretval := .t.
      endif
   endif
return mretval
******************************************************
static function printfacility( mfcltycode )
******************************************************
   Facility -> ( dbseek ( mfcltycode ) )
   @ prow() + 2 , 00 say trans( mfcltycode,'@R 999-99' )+' '+Facility -> FCLTYNAME
return nil
****************************************************
static function printstats ( mstats,mindex )
****************************************************
   devpos ( prow() + 1, 1 )
   if (mindex == nil ) .or. !( mindex $ '12345' )
      devout ( 'Invalid status code' )
   else
      devout ( mstats [ val ( mindex ) ] )
   endif
return nil
************************************************
static function printbranch ( mbranch )
************************************************
   Branches -> ( dbseek ( mbranch ) )
   @ prow() + 1, 01 say Branches -> BRNAME
return nil
/*
********************************
static function uniqfile()
********************************
   local mfiname, mrandnum
   do while .t.
      mrandnum := substr(time(),1,2) + substr(time(),4,2) + substr(time(),7,2)
      mfiname  := 'TF' + mrandnum
      if file(mfiname+'.dbf')                 // test if text file exist
         loop
      else
         exit
      endif
   enddo
return mfiname
*/
******************************
static function amsr0500open()
******************************
   local mretval := .f.
   memvar g_cis_path,g_grf_path
   if netuse( '&g_cis_path'+'\Client.dbf',.f.,5)
      set index to &g_cis_path\Cliecd,;
                   &g_cis_path\Clienm
      if netuse( '&g_AMS_PATH\Acctmast',.f., 5 )
         set index to &g_AMS_PATH\Acctmast,;
                      &g_AMS_PATH\Acctacno,;
                      &g_AMS_PATH\Acctclnt,;
                      &g_AMS_PATH\Sureclnt,;
                      &g_AMS_PATH\Acctfa,;
                      &g_AMS_PATH\Acctsub2
         if netuse( '&g_AMS_PATH\Paysked',.f.,5)
            set index to &g_AMS_PATH\Paysked
            if netuse( '&g_AMS_PATH\Delqhead',.f.,5 )
               set index to &g_AMS_PATH\Delqhead
               if netuse( '&g_AMS_PATH\Delqdtls',.f.,5 )
                  set index to &g_AMS_PATH\Delqdtls
                  if netuse( '&g_cis_path\Signers.dbf',.f.,5 )
                     set index to &g_cis_path\Signers
                     if netuse( '&g_AMS_PATH\Facility',.f.,5 )
                        set index to &g_AMS_PATH\Fcltycd
                        if netuse( '&g_grf_path\Branches.dbf',.f., 5)
                           set index to &g_grf_path\Branches
                           mretval := .t.
                        endif
                     endif
                  endif
               endif
            endif
         endif
      endif
   endif
return mretval
*                    end of the program ( amsr2005.prg )
