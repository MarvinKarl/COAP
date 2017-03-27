/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   PROGRAM ID.........:  amsr1200.prg                                         ³
³   Description........:  credit application for review                        ³
³   Author.............:  Ariel B. Bulan                                       ³
³   Date...............:  09:44am 19-Oct-1994                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                         U P D A T E S                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        Who        ³     When      ³               Why                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include "COLF.CH"
#include "INKEY.CH"
#include "MEMOEDIT.CH"

memvar ax_level,g_user_id
if chkpass( procname(),ax_level,g_user_id )
   if amsr1200open()
      amsrmain()
   endif
   release all
   close data
endif
return
******************************************
static function amsrmain()
**************************
   local  mDBF   := savedbf( mdbf ), mscr := savescreen (,,,), mcolor := setcolor(), mcursor := setcursor()
   memvar gtrandate
   private mpage := 1,mmonth := month( gtrandate ), mdays, myear:= year ( gtrandate );
           ,mtitle,mlm,mdate

   mtitle := 'Credit Application for Review'
   setprc( 0, 0 )
   fshadow( 8, 30, 11, 47, 2, 'gr+/g')

   while eval ({|| setcursor(3), get_month() })
      SETPRC(0,0)
      if Caheader->( dbseek( g_PAR_BRCH+ltrim(trans(myear,'9999')) + right('0'+ltrim(trans(mmonth,'99')),2) ) )
         *repcontrol ( 'amsr1200prn()' ,,,8,33)
         repcon_ol ( 'amsr1200prn()' ,,,8,33,,,.F.)
      else
         error ( 'Period Not Found!' )
      endif
   enddo
   restdbf( mdbf ); setcolor(mcolor) ; restscreen( ,,,, mscr ) ; setcursor(mcursor)
return nil
*********************************************
function amsr1200prn()
*********************************************
   local mLM := 0
   memvar gcompany, gsys_name, mpage, mmonth, myear,mtitle
   setfont('DRAFT')
   setfont('CONDENSED')

   prnreptitle  ( 80,mLM,mPAGE,mTITLE,'AMSR1200',gSYS_NAME,gCOMPANY  )
   pagecenter   ( prow()+1,80,'For the Month of '+fr0100month( str(mMONTH,2) )+' '+str(mYEAR,4))
   dispheader   ()
   validate_records  ( )

return nil
************************************************
static function validate_records( )
*************************************************
   memvar mmonth,myear
   local mperiod := ltrim(trans(myear,'9999')) + right('0'+ltrim(trans(mmonth,'99')),2)  
   Caheader-> ( dbeval ( {|| if ( Caheader->ACTAKEN == '3',;
                                  disp_records(),;
                                  nil;
                                );
                         },,;
                         {|| left(dtos(Caheader->REVDATE),6) == mperiod .and. !Caheader->(eof()) .and. ;
                             Caheader->brcode == g_PAR_BRCH ;
                         };
                       );
              )
return nil
******************************
static function disp_records()
******************************
   local mCOLUMN := { 000+3 , 009+3+4, 061+3, 068+3, 077+3, 089+3, 101+3, 116+3 }
   memvar gcompany, gsys_name, mpage, mmonth, myear, mlm, mtitle
   setfont('CONDENSED')
   @ prow()+1, mCOLUMN [1] say Caheader->BRCODE+Caheader -> CLNTCODE  pict '@R 999-99-99999'
   @ prow()  , mCOLUMN [2] say dispclntnam( CAHEADER->BRCODE+Caheader -> CLNTCODE, 46 )
   @ prow()  , mCOLUMN [3] say Caheader -> AOCODE
   @ prow()  , mCOLUMN [4] say Caheader -> CANUMBER
   @ prow()  , mCOLUMN [5] say Caheader -> CADATE
   @ prow()  , mCOLUMN [6] say Caheader -> REVDATE
   @ prow()  , mCOLUMN [7] say Caheader -> CALINE    pict '999,999,999.99'
   @ prow()  , mCOLUMN [8] say Caheader -> CALINE - Caheader -> AVAILED pict '999,999,999.99'
   if prow() > 53
      __eject()
      mPAGE ++
      prnreptitle  ( 80,mLM,mPAGE,mTITLE,'Amsr1200',gSYS_NAME,gCOMPANY)
      pagecenter   ( prow()+1,80,'For the Month of '+fr0100month( str(mMONTH,2) )+' '+str(mYEAR,4))
      dispheader   ()
   endif
return nil
***************************
Function fr0100month(mMONTH)
***************************
return alltrim( substr('         January  February March    April    May      June     July     August   SeptemberOctober  November December ',val(mMONTH)*9+1,9) )
****************************
static function dispheader()
****************************
   setfont('CONDENSED')
   @  prow()+2, 03 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄ  ÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   @  prow()+1, 03 say 'Client Code / Name                                           AO     CA No.    CA Date    Review Date Credit Line    O/B of Line   '
   @  prow()+1, 03 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄ  ÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
return nil
******************************
static function amsr1200open()
******************************
   local mRETVAL := .f.
   if NETUSE('&g_AMS_PATH\Caheader',.f.,5)
      set index to &g_AMS_PATH\Caheader,;
                   &g_AMS_PATH\Carev
      set order to 2
      if NETUSE('&g_AMS_PATH\Cadetail',.f.,5)
         set index to &g_AMS_PATH\Cadetail
         if NETUSE('&g_CIS_PATH'+'\Client.dbf',.f.,5)
            set index to &g_CIS_PATH\Cliecd,;
                         &g_CIS_PATH\Clienm
            mRETVAL := .t.
         endif
      endif
   endif
return mRETVAL
*                          End of the Program ( amsr1200.prg )
*****************************************
/*
static function dispclntname(mclntcode)
*****************************************
   Client->(dbseek(g_PAR_BRCH+mclntcode))
return Client->FULLNAME
*/
******************************         && RED COPIED IN THIS PRG FROM AMSR2200.PRG
function get_mdate( mrow )
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
