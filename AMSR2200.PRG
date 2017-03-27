/*
  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³³   program ID.........:  amsr0300.prg                                 ³
³³   description........:  aging of receivables                         ³
³³   author.............:  Ariel B. Bulan                               ³
³³   date...............:  10:49am 17-Jul-1995                          ³
³ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³³                         U P D A T E S                                ³
³ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³³        Who        ³     When      ³               Why                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³Engr.Michael Espina³2:36 PM 2/25/99³ Updating of Page breaks & Amounts³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include "Colf.ch"
#include "Inkey.ch"

#define MAXROW 120
memvar ax_level,g_user_id
public pgnpahinax:=2
if chkpass( procname(),ax_level,g_user_id )
   if amsr0300open()
      amsr0300main()
   endif
   eval ({|| __mrelease( "*", .t.), dbcloseall() })
endif
return
******************************
static function amsr0300main()
******************************
   local  mdbf   := savedbf (mdbf), mcolor := setcolor(), mcursor := setcursor()
   memvar gtrandate
   private mpage := 1,mmonth,mdays,myear,mtitle,mlm,mdate,nchoice
   mtitle := 'Aging of Receivables'; mlm := 0 ; mdate  := gtrandate
   while get_mdate( 6 )
      mpage  := 1
      mmonth := month(mdate)
      mdays  := day(mdate)
      myear  := year(mdate)
      _comp_menu()

      *repcontrol('amsr0300print()',,,8,33)
      repcon_ol('amsr0300print()',,,8,33,,,.F.)
   enddo
   setcolor  (mcolor); setcursor (mcursor) ; restdbf   (mdbf)
return nil
********************************
*
static function _comp_menu()
********************************
   local mscr := savescreen (,,,)
   local menulist, mcolor := setcolor()

   nchoice := 0

   set color to 'w/n'
   @ 10,30 clear to 18,50
   @ 10,30 to 18,50 double
   @ 12,33 prompt 'FMLC Accounts '
   @ 14,33 prompt 'PBC  Accounts '
   @ 16,33 prompt 'ORIX Accounts '
   menu to nchoice

   setcolor(mcolor)
   restscreen ( ,,,, mscr )
return nil

************************
*
function amsr0300print()
************************
   local mar := {}, mscr := savescreen(,,,)
   access_dbf ( mar )
   print_it   ( mar )
   restscreen ( ,,,, mscr )
return nil
*********************************
static function print_it( mar )
*********************************
   setfont       ( 'CONDENSED' )
   setprc        ( 0,0 )
   SETFONT('CONDENSED')
   print_head    ()
   print_subhead ()
   print_array   ( mar )
   SETFONT('CONDENSED')
return nil
***********************************
static function print_array ( mar )
***********************************
   local ctr := 1, mfcltycode, mftotal := 0
   local mftosbal,mftsix,mftle1year,mftg1year,mftoverdue
   local mgtosbal,mgtsix,mgtle1year,mgtg1year,mgtoverdue

   mgtosbal := mgtsix := mgtle1year := mgtg1year := mgtoverdue := 0
   do while ctr <= len ( mar )
      mftotal    := 0
      mfcltycode := mar [ctr] [1]
      @ prow()+1, 00     say mfcltycode pict '@R 999-999'
      @ prow()  , pcol() say '/'+ dispfclty( mfcltycode )
      @ prow()+1, 00     say ''
      mftosbal := mftsix := mftle1year := mftg1year := mftoverdue := 0
      while mar [ctr] [1]  == mfcltycode
         printrecord( mar [ctr] )
                                           && Facility total for :
         mftosbal   += mar [ctr] [ 06 ]    &&    OSBAL
         mftsix     += mar [ctr] [ 07 ]    &&    up to 6 months
         mftle1year += mar [ctr] [ 08 ]    &&    up to 1 year
         mftg1year  += mar [ctr] [ 09 ]    &&    greater than 1 year
         mftoverdue += mar [ctr] [ 10 ]    &&    amount over due
                                           && Grand total for :
         mgtosbal   += mar [ctr] [ 06 ]    &&    OSBAL
         mgtsix     += mar [ctr] [ 07 ]    &&    up to 6 months
         mgtle1year += mar [ctr] [ 08 ]    &&    up to 1 year
         mgtg1year  += mar [ctr] [ 09 ]    &&    greater than 1 year
         mgtoverdue += mar [ctr] [ 10 ]    &&    amount over due
         ctr++
         if ctr > len ( mar )
            exit
         endif
      enddo
      @ prow() + 1, 00  say '                                                        ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
      @ prow() + 1, 00  say 'Total for this Facility '
      print_fclty_total( mftosbal, mftsix, mftle1year, mftg1year, mftoverdue )
      @ prow() + 1, 00  say '                                                        ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   enddo
   @ prow() + 1, 00 say 'Grand Total '
   print_grand_total ( mgtosbal, mgtsix, mgtle1year, mgtg1year, mgtoverdue )
   @ prow() + 1, 00  say '                                                        ================ ================ ================ ================ ================'
return nil
******************************************************************************************
static function print_grand_total ( mgtosbal, mgtsix, mgtle1year, mgtg1year, mgtoverdue )
******************************************************************************************
 //local mcol := { 0,36,43,54,65,82,99,116,133 }
   local mcol := { 0,27,34,45,56,73,90,107,124 }
   @ prow()  , mcol [5] say mgtosbal                pict '9,999,999,999.99'
   @ prow()  , mcol [6] say mgtsix                  pict '9,999,999,999.99'
   @ prow()  , mcol [7] say mgtle1year              pict '9,999,999,999.99'
   @ prow()  , mcol [8] say mgtg1year               pict '9,999,999,999.99'
   @ prow()  , mcol [9] say mgtoverdue              pict '9,999,999,999.99'
return nil
****************************************************************************************
static function print_fclty_total( mftosbal, mftsix, mftle1year, mftg1year, mftoverdue )
****************************************************************************************
   local mcol := { 0,27,34,45,56,73,90,107,124 }
   @ prow()  , mcol [5] say mftosbal                pict '9,999,999,999.99'
   @ prow()  , mcol [6] say mftsix                  pict '9,999,999,999.99'
   @ prow()  , mcol [7] say mftle1year              pict '9,999,999,999.99'
   @ prow()  , mcol [8] say mftg1year               pict '9,999,999,999.99'
   @ prow()  , mcol [9] say mftoverdue              pict '9,999,999,999.99'
return nil
***************************************
static function printrecord( mrec )
***************************************
   local mcol := { 0,27,34,45,56,73,90,107,124 }
   SETFONT('CONDENSED')
   if prow() >= 55
      __eject()
      @ prow()+1,0 say ''
      SETFONT('CONDENSED')
      @ prow()+1,0 say 'Page No: ' + alltrim(str(pgnpahinax))
      pgnpahinax++
      print_subhead()
   endif
 /* @ prow()+1, mcol [1] say mrec[2]                 pict '@R 99-99999' 
    @ prow()  , pcol()+1 say dispclntname( mrec[2] ) pict '@XS26'
 */

   @ prow()+1, mcol [1] say dispclntname( mrec[2], 40 ) pict '@XS26'
   @ prow()  , mcol [2] say mrec[3]                 pict '99999'
   @ prow()  , mcol [3] say mrec[4]                 pict '@D'
   @ prow()  , mcol [4] say mrec[5]                 pict '@D'
   @ prow()  , mcol [5] say mrec[6]                 pict '9,999,999,999.99'
   @ prow()  , mcol [6] say mrec[7]                 pict '9,999,999,999.99'
   @ prow()  , mcol [7] say mrec[8]                 pict '9,999,999,999.99'
   @ prow()  , mcol [8] say mrec[9]                 pict '9,999,999,999.99'
   @ prow()  , mcol [9] say mrec[10]                pict '9,999,999,999.99'
return nil
***************************************
static function dispmess()
***************************************
   set device to screen
   dispbegin()
   fshadow( 06, 20, 20, 55, 2, 'w/gr' )
   setpos ( 07, 22 ) ; dispout ( 'Fclty Nm  ','bg+/gr' )
   setpos ( 08, 22 ) ; dispout ( 'Clnt. Nm  ','bg+/gr' )
   setpos ( 09, 22 ) ; dispout ( 'Acct. N§  ','bg+/gr' )
   setpos ( 10, 22 ) ; dispout ( 'Date Executed  ','bg+/gr' )
   setpos ( 11, 22 ) ; dispout ( 'Maturity Date  ','bg+/gr' )
   setpos ( 12, 20 ) ; dispout ( 'ÆÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍµ','w/gr')
   setpos ( 18, 20 ) ; dispout ( 'ÆÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍµ','w/gr')
   setpos ( 13, 22 ) ; dispout ( '  Outstanding  ','bg+/gr' )
   setpos ( 14, 22 ) ; dispout ( '  Amt Overdue  ','bg+/gr' )
   setpos ( 15, 22 ) ; dispout ( '  <= 6 Months  ','bg+/gr' )
   setpos ( 16, 22 ) ; dispout ( '  <= 1 Year    ','bg+/gr' )
   setpos ( 17, 22 ) ; dispout ( '   > 1 Year    ','bg+/gr' )
   dispend()
   set device to printer
return nil
***************************************
static function dispfclty( mfcltycode )
***************************************
   Facility->( dbseek( mfcltycode ) )
return Facility-> FCLTYNAME
*********************************
static function access_dbf( mar )
*********************************
   local ml := Acctmast->( lastrec() ), mr := 1
   dispmess()
   Acctmast->( dbgotop() )
   Acctmast->( dbeval({|| eval ({|| transfer_to_array ( mar,Acctmast->FCLTYCODE,ml,@mr ),;
                                    Acctmast->( dbskip(-1) ) ;
                               });
                      },,;
                      {|| !Acctmast->(eof())  };
                     );
             )
return nil
*********************************
static function dispbar( mwhat )
*********************************
   do case
      case empty( mwhat )
         setpos ( 07, 33 ) ; dispout ( padr( dispfclty( Acctmast->FCLTYCODE ), 21 ),'w+/gr'  )
         setpos ( 08, 33 ) ; dispout ( padr( dispclntname(Acctmast->BRCODE+Acctmast->CLNTCODE, 40), 21 ),'w+/gr'  )
         setpos ( 09, 33 ) ; dispout ( padr( trans(Acctmast->ACCTNO,'@R 9999-99999-99999'),21 ),'w+/gr'  )
         setpos ( 10, 38 ) ; dispout ( padr( Acctmast->VALDATE ,16 ), 'w+/gr'  )
         setpos ( 11, 38 ) ; dispout ( padr( Acctmast->MATDATE ,16 ), 'w+/gr'  )
      otherwise
         setpos ( 13, 38 ) ; dispout ( padr( trans( mwhat [1],'999,999,999.99'),16 ), 'w+/gr' )
         setpos ( 14, 38 ) ; dispout ( padr( trans( mwhat [5],'999,999,999.99'),16 ), 'w+/gr' )
         setpos ( 15, 38 ) ; dispout ( padr( trans( mwhat [2],'999,999,999.99'),16 ), 'w+/gr' )
         setpos ( 16, 38 ) ; dispout ( padr( trans( mwhat [3],'999,999,999.99'),16 ), 'w+/gr' )
         setpos ( 17, 38 ) ; dispout ( padr( trans( mwhat [4],'999,999,999.99'),16 ), 'w+/gr' )
   endcase
return nil
***************************************************
static function dispindicator( mlastrec,mrecno )
***************************************************
   local mcol,mcolor,mper := (mrecno/mlastrec)*100
   set device to screen
   dispbegin()

   mcol := 22 + ((mrecno/mlastrec)/100) * 32 * 100
   setpos ( 19,22 ) ; dispout ( repl ( ' ',mcol-22) ,'n/w' )
   if col() >= 37
      do case
         case col() == 37
            setpos ( 19,36 ) ; dispout ( left ( ltrim(trans(mper,'999')),1)       ,'n/w'   )
            setpos ( 19,37 ) ; dispout ( right( rtrim(trans(mper,'999')),1)+ '%'  ,'w+/gr' )
         otherwise
            setpos ( 19,36 ) ; dispout ( ltrim( trans( mper, '999' ) ) + '%','n/w')
      endcase
   else
      setpos ( 19,36 ) ; dispout ( ltrim( trans( mper, '999' ) ) + '%','w+/gr')
   endif
   dispend()
   set device to printer
return nil
/*
*****************************************
static function dispclntname(mclntcode)
*****************************************
   Client->(dbseek(mclntcode))
return Client->FULLNAME
*/
********************************************************
static function transfer_to_array ( mar,mfc,ml,mr )
********************************************************
   local m1_to_6_months, m6_to_1_year, mover_1_year, mamount_overdue

   Acctmast->( dbeval ({|| m1_to_6_months := m6_to_1_year := mover_1_year := mamount_overdue := 0 ,;
                           dispbar() ,;
                           dispindicator(ml,mr) ,;
                           mr++      ,;
                           if ( Acctmast->STATUS == '1' .and. ;
                                nchoice == _company_accounts('ACCTMAST'),;
                                eval ({|| seek_to_paysked(@m1_to_6_months,@m6_to_1_year,@mover_1_year,@mamount_overdue),;
                                          aadd( mar, { Acctmast->FCLTYCODE ,;
                                                       Acctmast->CLNTCODE  ,;
                                                       right(Acctmast->ACCTNO,5),;
                                                       Acctmast->VALDATE   ,;
                                                       Acctmast->MATDATE   ,;
                                                       Acctmast->OSBAL     ,;
                                                       m1_to_6_months      ,;
                                                       m6_to_1_year        ,;
                                                       mover_1_year        ,;
                                                       mamount_overdue      ;
                                                     };
                                               );
                                     }),;
                                nil ) ;
                       },,;
                       {|| !Acctmast->(eof()) .and. Acctmast->FCLTYCODE == mfc };
                      );
             )
return nil
******************************************************************************************
static function seek_to_paysked( m1_to_6_months,m6_to_1_year,mover_1_year,mamount_overdue)
******************************************************************************************

   if Paysked->( dbseek( Acctmast->ACCTNO ) )
      Paysked->( dbeval( {|| compute_term( @m1_to_6_months,@m6_to_1_year,@mover_1_year,@mamount_overdue) ,;
                             dispbar( { Acctmast->OSBAL,m1_to_6_months,m6_to_1_year,mover_1_year,mamount_overdue } ) ;
                         },,;
                         {|| !Paysked->(eof()) .and. Paysked->ACCTNO == Acctmast->ACCTNO };
                       );
               )
   endif
return nil
***************************************************************************************
static function compute_term(m1_to_6_months,m6_to_1_year,mover_1_year,mamount_overdue)
***************************************************************************************
   memvar mdate
   local mamount  :=  Paysked->Amort // Paysked->PRNAMT + Paysked->INTAMT
  // local msix   := 0 , m1year := 0
   local msix:=m1year:=ctod('')
  //get_terms( @msix, @m1year )

  msix:=addmonth(mdate,6)
  m1year:=addmonth(mdate,12)

   do case
/*
      case Paysked->PAYDATE < mdate
         mamount_overdue += mamount
      case Paysked->PAYDATE > mdate .AND. Paysked->PAYDATE <= msix
         m1_to_6_months  := m1_to_6_months + mamount
      case Paysked->PAYDATE > msix .AND. Paysked->PAYDATE <= m1year
         m6_to_1_year    := m6_to_1_year + mamount
      case Paysked->PAYDATE > m1year
         mover_1_year    := mover_1_year + mamount
*/  
      case Paysked->PAYDATE < mdate
         mamount_overdue += mamount
      case Paysked->PAYDATE <= msix
         m1_to_6_months  += mamount
      case Paysked->PAYDATE <= m1year
         m6_to_1_year    += mamount
      case Paysked->PAYDATE > m1year
         mover_1_year    += mamount
   endcase

return nil
*****************************************
static function get_terms( msix, m1year )
*****************************************
   msix   := get_next_term (06) && SIX MONTHS
   m1year := get_next_term (12) && 1 YEAR
return nil
***************************************
static function get_next_term( mrange )
***************************************
   memvar mmonth,mdays,myear
   local i, mm2 := mmonth, md2 := mdays, my2 := myear
   local mretval

   for i := 1 to mrange
      mm2++
      if mm2 >= 13
         my2++
         mm2 := 1
      endif
   next i
   do case
      case ltrim(trans(mm2,'99')) $ '_1_3_5_7_8_10_12'
         md2 := 31
      case ltrim(trans(mm2,'99')) $ '_4_6_9_11'
         md2 := 30
      otherwise
         md2 := if ( month( ctod('02/28/'+trans(my2,'9999'))+1 == 3 ), 28, 29 )
   endcase
   mretval := trans(mm2,'99') + '/' + trans(md2,'99') + '/' + trans(my2,'9999')
return ctod(mretval)
******************************
static function get_mdate( mrow )
******************************
    local mcolor := setcolor(), mcursor:= setcursor(), mretval, getlist := {}
    memvar mdate
    
    fshadow( mrow, 21, mrow + 2, 51, 2, 'gr+/g' )
    setcolor( 'w/g, w+/n,,, w+/g' )
    @ mrow + 1, 22 say 'Transaction Date ' get mdate when !empty( mdate := getdate( mdate, mrow + 1, 41, 'w/gr, gr+/gr,,, n/gr' ) )
    setcursor( 3 )
    read
    if ( lastkey()==K_ESC, mretval:=.f.,mretval:=.t. )
    setcolor( mcolor ); setcursor( mcursor )
return mretval
******************************
static function print_head()
******************************
   memvar mtitle,mpage,gsys_name,gcompany,mlm,mmonth,mdays,myear
   setfont('CONDENSED')
   eval ({|| mtitle := 'Aging of Receivables' ,;
             prnreptitle ( 80,mlm,mpage,mtitle,'Program ID:AMSR2200', gsys_name, gcompany ),;
             pagecenter  ( prow()+1,80,'As of '+fr0100month( trans(mmonth,'99') )+' '+trans(mdays,'99')+', '+trans(myear,'9999') ) ,;
             mpage++ ;
        })
return nil
/*
************************************
*
static function _company_accounts()
************************************
   local cretval := 3        // 1-metro,2-pbc,3-orix

   if nchoice == 0
      cretval := 0
   else
      do case
         case substr(alltrim(Acctmast->acctno),1,4) == '9907'
            cretval := 1

         case substr(alltrim(Acctmast->acctno),1,4) == '9908'
            cretval := 2

      endcase
   endif

return cretval
*/
*******************************
static function print_subhead()
*******************************
    setfont('CONDENSED')
    eval({|| ;
        devpos( prow()+2, 00 ) , devout( "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"),;
        devpos( prow()+1, 00 ) , devout( "Client Code/Name           Acctno  Date       Maturity   Outstanding       Up to 6 Months   Over 6 Months    Over 1 Year          Amount   " ) ,;
        devpos( prow()+1, 00 ) , devout( "                                   Executed   Date       Balance                             to 1 Year                            Overdue  " ) ,;
        devpos( prow()+1, 00 ) , devout( "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ" )  ;
        })
return nil
********************************
static function amsr0300open()
********************************
    local mretval := .f.
    memvar g_cis_path
    if netuse( 'Acctmast',.f.,5)
       set index to Acctmast,Acctclnt,Sureclnt,Acctfa
       Acctmast->( dbsetorder(4) )  && ACCTNO + FCLTYCODE
       if netuse( 'Paysked',.f.,5)
          set index to Paysked         && ACCTNO + dtos (PAYDATE)
          if netuse(  '&g_cis_path'+'\Client.dbf',.f.,5)
             set index  to &g_cis_path\Cliecd, &g_cis_path\Clienm
             if netuse( 'Facility',.f.,5)  && FACILITY CODE
                set index to Fcltycd
                mretval := .t.
             endif
          endif
       endif
    endif
return mretval
*                     End of the program ( amsr0300.prg )
