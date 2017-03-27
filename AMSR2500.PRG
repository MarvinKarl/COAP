/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   Program ID.........:  amsr0600.prg                                         ³
³   Description........:  account executed for the month                       ³
³   Author.............:  Ariel B. Bulan                                       ³
³   Date...............:  02:51pm 19-Jan-1995                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                         U P D A T E S                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        Who        ³     When      ³               Why                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include "Colf.ch"
#include "Inkey.ch"

#define MAXROW 56
#define ZERO   0
memvar ax_level,g_user_id
private cRESTR
if chkpass( procname(),ax_level,g_user_id )
   if amsr0600open()
      amsr0600main()
   endif
   eval ({|| __mrelease( "*", .t.), dbcloseall() })
endif
return
******************************
static function amsr0600main()
******************************
   local   mdbf  := savedbf (mdbf), mcolor := setcolor(), mcursor := setcursor()
   LOCAL   xSTR  := ''
   memvar  gtrandate
   private mpage := 1, mmonth := month(gtrandate), myear := year(gtrandate)
   private mtitle,mlm
   private mpreparedby,mcheckedby,mnotedby,mpcode,mccode, mncode

   mtitle      := 'Accounts Executed for the Month'; mlm := 0
   mpreparedby := mcheckedby := mnotedby := space( 40 )
   mpcode      := mccode     := mncode   := space( 05 )
   fshadow( 8, 30, 11, 47, 2, 'n/g' )
   eval ({|| setcursor (3), get_monames() })
      mpage := 1
      *--->                        RED 012205
      *repcontrol ('amsr0600print()',,,09,37)
      xSTR := CHK_PAR(mYEAR) + CHK_PAR(mMONTH) + CHK_PAR(mPAGE)         + ;
              CHK_PAR(mTITLE) + CHK_PAR(mLM) + CHK_PAR(mPREPAREDBY)     + ;
              CHK_PAR(mCHECKEDBY) + CHK_PAR(mNOTEDBY) + CHK_PAR(mPCODE) + ;
              CHK_PAR(mCCODE) + CHK_PAR(mNCODE) + CHK_PAR(gSYS_NAME)    + ;
              CHK_PAR(gCOMPANY) + CHK_PAR(cRESTR)
      REPCON_OL('AMSR0600PRINT()',,,09,37,,xSTR,.T.)
      *--->
   //enddo
   setcolor   (mcolor) ; setcursor (mcursor) //; restdbf (mdbf)
return nil

******************************
*
function amsr0600print()
******************************
   local mrecords := {}, i
   setprc       ( 0,0 )
   f0600compute ( mrecords )
   setfont      ( upper( 'condensed' ) )
   f0600head    ( )
   setfont      ( upper( 'condensed' ) )
   f0600sbhead  ( )
   setfont      ( upper( 'condensed' ) )
   f0600print   ( mrecords )
   for i:= prow ( ) to 49 ; @ i,00 say ''; next i
   print_names  ( )
   __eject      ( )
return nil

********************************************
*
static function f0600print ( mrecords )
********************************************
   local mt1      := 1 , mt2 := 1, mfcltycd
   local mptotal, mgdtotal, mrtotal, matotal, maftotal, mnaftotal, mtrtotal, mpertotal, mwtotal
   local mfctotal := {}   , mgtotal := {}

   while mt1 <= len ( mrecords )
         mfcltycd   := mrecords [ mt1 ] [ 1 ]
         @ prow()+2 , 5       say mfcltycd pict '@R 999-99'
         @ prow()   , pcol()  say ' '+ upper ( dispfcltyname( mfcltycd ) )
         mptotal   := mgdtotal  := mrtotal   := matotal   := 0
         maftotal  := mnaftotal := mtrtotal  := mpertotal := mwtotal:= 0
         while eval ( {|| if( mt1<= len ( mrecords ),mrecords [ mt1 ] [ 1 ] == mfcltycd, .f.) })
               disp_em ( mrecords [ mt1 ] )
               mptotal   += mrecords [ mt1 ] [ 4 ]
               mgdtotal  += mrecords [ mt1 ] [ 5 ]
               mrtotal   += mrecords [ mt1 ] [ 6 ]
               matotal   += mrecords [ mt1 ] [ 7 ]
               maftotal  += mrecords [ mt1 ] [ 11 ]
               mnaftotal += mrecords [ mt1 ] [ 12 ]
               mtrtotal  += mrecords [ mt1 ] [ 13 ]
               mpertotal += mrecords [ mt1 ] [ 14 ]
               mwtotal   += mrecords [ mt1 ] [ 15 ]
               if prow() >= 55
                     setfont      ( upper( 'condensed' ) )
                  __eject()
               endif
               mt1++
         enddo
         f0600ftotal( { mptotal,mgdtotal,mrtotal,matotal,maftotal,mnaftotal,mtrtotal,mpertotal,mwtotal })
   enddo
return nil
********************************************
static function disp_em( m_mrec )
********************************************
   local mcol := { 5,22,84,99,114,129,144,148,155,164,179,194,209,219,76 }
   @ prow()+1 , mcol [01] say m_mrec[02]  pict '@R 9999-99999-99999'
   @ prow()   , mcol [02] say m_mrec[03]  pict '@X'
   
   @ prow()   , mcol [15] say m_mrec[18]  pict '@X'
   
   @ prow()   , mcol [03] say m_mrec[04]  pict '999,999,999.99'
   @ prow()   , mcol [04] say m_mrec[05]  pict '999,999,999.99'
   @ prow()   , mcol [05] say m_mrec[06]  pict '999,999,999.99'
   @ prow()   , mcol [06] say m_mrec[07]  pict '999,999,999.99'
   @ prow()   , mcol [07] say m_mrec[08]  pict '999'
   @ prow()   , mcol [08] say m_mrec[09]  pict '@X'
   @ prow()   , mcol [09] say m_mrec[10]  pict '99.99999'
   @ prow()   , mcol [10] say m_mrec[11]  pict '999,999,999.99'
   @ prow()   , mcol [11] say m_mrec[12]  pict '999,999,999.99'
   @ prow()   , mcol [12] say m_mrec[13]  pict '999,999,999.99'
   @ prow()   , mcol [13] say m_mrec[14]  pict '999.9999%'
   @ prow()   , mcol [14] say m_mrec[15]  pict '999.9999%'
return nil
*******************************************
static function print_names    ()
*******************************************
    memvar mpreparedby, mcheckedby, mnotedby
    local  ml := 00, mc := 27, mr := 54
    @ prow()+2, 00 say repl( chr(196), 80 )
    @ prow()+1, ml say 'Prepared by :'
    @ prow()  , mc say 'Checked by  :'
    @ prow()  , mr say 'Noted by    :'
    @ prow()+3, ml say repl( 'Ä', 25 )
    @ prow()  , mc say repl( 'Ä', 25 )
    @ prow()  , mr say repl( 'Ä', 25 )
    @ prow()+1, ml say left( mpreparedby, 25 )
    @ prow()  , mc say left( mcheckedby , 25 )
    @ prow()  , mr say left( mnotedby   , 25 )
return nil
*****************************************
static function f0600compute ( mrecords )
*****************************************
   memvar mmonth,myear
   local mts := {}, mperiod := str(myear,4)+ right( '0'+ltrim( str(mmonth,2) ), 2 )
   Acctmast -> ( dbgotop() )
   Acctmast -> ( dbeval ({|| if( left(dtos(Acctmast->VALDATE),6) == mperiod .and. Acctmast->STATUS == '1' .AND. ACCTMAST->BRCODE == g_PAR_BRCH ,;
                                 if (cRESTR == 2,if(Acctmast->fcltycode == '10310' .or. Acctmast->fcltycode == '10410',dbskip(),trans_to_array(mrecords)),trans_to_array(mrecords)) , nil );
                          },,{|| !Acctmast->(eof()) } ) )
   get_left_totals ( mrecords, mts )
   get_perc_watr   ( mrecords, mts )
return nil
****************************************************
static function trans_to_array ( mrecords )
****************************************************

if substr(Acctmast->fcltycode,1,3) == '104'
nGD := 0
nRV := 0
else
nGD := Acctmast -> GD/100*Acctmast->PRINCIPAL
nRV := Acctmast -> RV/100*Acctmast->PRINCIPAL
endif

   aadd ( mrecords                                 ,;
          { Acctmast -> FCLTYCODE                  ,;
            Acctmast -> ACCTNO                     ,;
            Acctmast -> ACCTNAME                   ,;
            Acctmast -> PRINCIPAL                  ,;
            nGD ,;
            nRV ,;
            Acctmast -> AMORT                      ,;
            Acctmast -> TERM                       ,;
            f0600term ( Acctmast->TERMUNIT )       ,;
            Acctmast -> TRUERATE                   ,;
            f0600financed ()                       ,;
            f0600netfinanced ()                    ,;
            Acctmast -> CREDAMT                    ,;
            ZERO                                   ,;
            ZERO                                   ,;
            Facility -> SETCODE                    ,;
            ACCTMAST -> BRCODE                     ,;
			f2500curr(ACCTMAST -> CURRCODE)         ;
          })
return nil
******************************
static function amsr0600open()
******************************
    local mretval := .f.
    if netuse( '&g_AMS_PATH\Acctmast',.f.,5)
       set index to &g_AMS_PATH\Acctmast,;
                    &g_AMS_PATH\Acctclnt,;
                    &g_AMS_PATH\Sureclnt,;
                    &g_AMS_PATH\Acctfa,;
                    &g_AMS_PATH\Acctsub2
       Acctmast->(dbsetorder (4))
       if netuse( '&g_GRF_PATH'+'\Personel.dbf',.f.,5)
          set index  to &g_GRF_PATH\Initials.ntx
          if netuse( '&g_AMS_PATH\Facility',.f.,5)
             set index to &g_AMS_PATH\Fcltycd
             mretval := .t.
          endif
       endif
    endif
return mretval
*                      End of the program ( amsr0600.prg )
