/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   program ID.........:  amsr0900.prg                                         ³
³   description........:  List of Accounts with Floating Interest              ³
³   author.............:  Ariel B. Bulan                                       ³
³   date...............:  02:09pm Apr-10-1995                                  ³
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
memvar ax_level,g_user_id
if chkpass( procname(),ax_level,g_user_id )
   if amsr0900open()
      nosnow(.t.)
      amsr0900main()
      nosnow(.f.)
   endif
   eval ({|| __mrelease( "*", .t.), dbcloseall() })
endif
return
******************************
static function amsr0900main()
******************************
   local  mdbf    := savedbf   (mdbf) ,;
          mcolor  := setcolor  ()     ,;
          mcursor := setcursor ()
   memvar gtrandate
   private mpage  := 1,mmonth,mdays,myear,mtitle,mlm,mdate,moption
   PRIVATE xTEMP  := ''                            && RED 071105
   PRIVATE ntotal := 0
   IF !MAKETEMP(@xTEMP)                             && RED 071105
      RETURN
   ENDIF

   mlm    := 0                  
   mdate  := gtrandate
   myear  := year( gtrandate )   
   mmonth := month( gtrandate )         
   mtitle := 'List of Account with Floating Interest'

   setprc( 0, 0 )

   if get_choice( 1 )
      Acctmast->( dbgotop() )
      *repcontrol( 'amsr0900print()',,, 8, 33 )
      xSTR := CHK_PAR(mPAGE)+CHK_PAR(mMONTH)+CHK_PAR(mDAYS)+CHK_PAR(mYEAR)+;
              CHK_PAR(mTITLE)+CHK_PAR(mLM)+CHK_PAR(mDATE)+CHK_PAR(mOPTION)+;
              CHK_PAR(gTRANDATE)+CHK_PAR(gSYS_NAME)+CHK_PAR(gCOMPANY)
      REPCON_OL( 'AMSR0900PRINT()',,, 8, 33,,xSTR,.T. )
   endif

   IF TRUE_BRCH == '001'
      (xTEMP)->(DBCLOSEAREA())
      FERASE(('C:\'+xTEMP+'.DBF'))
   ENDIF

   setcolor  (mcolor)
   setcursor (mcursor)
   restdbf   (mdbf)
return nil
*************************************
static function get_choice( mwhat )
*************************************
local mrow := if( mwhat == 1, 0, 2 ), mcol := if( mwhat == 1, 0, 5 )
local mcolor := setcolor(), mscreen := savescreen( ,,, ), getlist := {}
memvar moption, mmonth, myear, mpage, mlm

fshadow( 11 + mrow, 30 + mcol, 14 + mrow, if( mwhat == 1, 51, 48 ), 2, if( mwhat == 1, 'w/gr', 'gr+/g' ) )
if mwhat == 1
   while .t.
         setcolor( 'w/gr, w+/n,,, n/gr' )   
         moption := achoice( 12 + mrow, 31 + mcol, 13 + mrow, 50 + mcol, { 'Specify Year/Month ', 'All Records' },,, moption )
         if lastkey() != K_ESC
            if moption == 1
               if get_choice( -1 )
                  exit 
               endif   
            else
               exit
            endif
         else
            exit  
         endif
   enddo      
else
   setcolor( 'w/g, w+/n,,, n/g' )   
   @ 11 + mrow + 1, 30 + mcol + 1 say 'Month ' get mmonth pict '99'   when select_month ( @mmonth, 10, 48, 19, 58 )
   @ 12 + mrow + 1, 30 + mcol + 1 say ' Year ' get myear  pict '9999' valid myear > 1970
   setcursor( 3 )
   read
   setcursor( 0 )
endif   
setcolor( mcolor )
restscreen( ,,,, mscreen )
return( lastkey() != K_ESC )
/*
********************************************
static function select_month ( mmonth )
********************************************
return eval( { | x, y, z | x := setcolor(), y := savescreen( ,,, ),;
                          fshadow( 10, 48, 19, 58, 2, 'w/gr' ),;
                          devpos( 11, 51 ), devout( 'Month', 'bg+/gr' ),;
                          devpos( 12, 48 ) , devout( 'ÃÄÄÄÄÄÄÄÄÄ´', 'w/gr' ),;
                          setcolor( 'w/gr, w+/n,,, n/gr' ),;
                          z := achoice( 13, 49, 18, 57,;
                               { 'January', 'February', 'March', 'April',;
                                 'May', 'June', 'July', 'August', 'September',;
                                 'October', 'November', 'December' },,, mmonth ),;
                          setcolor( x ), restscreen( ,,,, y ), mmonth := if( z == 0, mmonth, z ), .f. } )
*/
*******************************
function amsr0900print()
*******************************
   memvar mpage,mmonth,mdays,myear,mtitle,mlm,mdate,moption
   local  mperiod    := str(myear,4)+right( '0'+ltrim(str(mmonth,2)),2 ) ,;
          mcondition := {|| if(moption == 1, left(dtos(Acctmast->REVDATE),6) == mperiod,.t. ) } ,;
          mrec := {}, mscr := savescreen(,,,)

   setfont ( "elite" )
   print_head ()
   print_subhead ()
     Acctmast->( dbseek( g_PAR_BRCH ) )
   if moption == 1
	do while left(dtos(Acctmast->REVDATE),6) != mperiod .AND. ACCTMAST->BRCODE == g_PAR_BRCH .AND. !ACCTMAST->(eof())
		acctmast->(dbskip())
	enddo
   else

	do while ACCTMAST->BRCODE == g_PAR_BRCH .and. !ACCTMAST->(eof()) .and. empty(Acctmast->REVDATE) 
		acctmast->(dbskip())
	enddo  
   endif
   dispmess()
   Acctmast->( dbeval( {|| if( Acctmast->RATETYPE == '2' .and. Acctmast->STATUS == '1' ;
                               .AND. ACCTMAST->BRCODE == g_PAR_BRCH                   ,;           && RED 070805
                               APNDREC()                                              ,;           && RED 071105 addrec(mrec) ,;
                               nil;
                             );
                       } ,,;
                       {|| eval(mcondition) .and. !Acctmast->(eof()) ;
                       } ;
                     );
             )

   *----    && RED 071105
   (xTEMP)->(DBUNLOCKALL())
   (xTEMP)->(DBCOMMITALL())
   (xTEMP)->(DBGOTOP())
   DO WHILE !(xTEMP)->(EOF())
      DISPBAR((xTEMP)->(RECNO()),(xTEMP)->(RECCOUNT()))
      ntotal := PRINT_REC( { (xTEMP)->FLD1,(xTEMP)->FLD2,(xTEMP)->FLD3,(xTEMP)->FLD4,(xTEMP)->FLD5,(xTEMP)->FLD6 } )
      (xTEMP)->(DBSKIP())
   ENDDO
@prow()+2,00 say 'Total ['+alltrim(str(ntotal))+']'
   /*aeval ( mrec,{|x,y| dispbar  (y,len(mrec)) ,;
                       print_rec(x)            ;
                };
         )*/
   *----
   __eject()
   restscreen(,,,,mscr)
return nil
************************************
STATIC FUNCTION APNDREC()
************************************
LOCAL mREC := {}
   IF (xTEMP)->(NETLOCK('A',3))
      REPLACE (xTEMP)->FLD1 WITH TRANS(ACCTMAST->ACCTNO,"@R 9999-99999-99999")
      REPLACE (xTEMP)->FLD2 WITH TRANS(LEFT(ACCTMAST->ACCTNAME,40), "@X" )
      REPLACE (xTEMP)->FLD3 WITH TRANS(ACCTMAST->TERM, "999" )
      REPLACE (xTEMP)->FLD4 WITH TRANS(IF( ACCTMAST->PAYTYPE == "1","ADVANCE","ARREARS" ),'@X' )
      REPLACE (xTEMP)->FLD5 WITH TRANS(ACCTMAST->VALDATE, "@D" )
      REPLACE (xTEMP)->FLD6 WITH TRANS(ACCTMAST->REVDATE, "@D" )
   ENDIF
   (xTEMP)->(DBUNLOCKALL())
   (xTEMP)->(DBCOMMITALL())

   AADD( mREC, { TRANS(ACCTMAST->ACCTNO,"@R 9999-99999-99999")                  ,;
                 TRANS(LEFT(ACCTMAST->ACCTNAME,40), "@X" )                      ,;
                 TRANS(ACCTMAST->TERM, "999" )                                  ,;
                 TRANS(IF( ACCTMAST->PAYTYPE == "1","ADVANCE","ARREARS" ),'@X' ),;
                 TRANS(ACCTMAST->VALDATE, "@D" )                                ,;
                 TRANS(ACCTMAST->REVDATE, "@D" )                                 ;
               }                                                                 ;
       )

   DISPINDREC( ATAIL(mREC) )
   mREC := {}

RETURN NIL
************************************
static function addrec( mrec )
************************************
   aadd( mrec, { trans(Acctmast->ACCTNO,"@R 9999-99999-99999"),;
                 trans(left(Acctmast->ACCTNAME,40), "@X" )    ,;
                 trans(Acctmast->TERM, "999" )                ,;
                 trans(if( Acctmast->PAYTYPE == "1","Advance","Arrears" ),'@X' ),;
                 trans(Acctmast->VALDATE, "@D" )              ,;
                 trans(Acctmast->REVDATE, "@D" )               ;
               };
       )
   dispindrec( atail(mrec) )
return nil
******************************
static function dispbar(mr,ml)
******************************
   local mcol, mper := (mr/ml)*100
   mcol := 23 + ((mr/ml)/100) * 30 * 100
   setpos ( 18,23 ) ; dispout ( repl ( ' ',mcol-23) ,'n/w' )
   if col() >= 38
      do case
         case col() == 38
            setpos ( 18,37 ) ; dispout ( left ( ltrim(trans(mper,'999')),1)       ,'n/w'   )
            setpos ( 18,38 ) ; dispout ( right( rtrim(trans(mper,'999')),1)+ '%'  ,'w+/gr' )
         otherwise
            setpos ( 18,37 ) ; dispout ( ltrim( trans( mper, '999' ) ) + '%','n/w')
      endcase
   else
      setpos ( 18,37 ) ; dispout(ltrim(trans(mper,'999')) + '%','w+/gr')
   endif
return nil
********************************
static function dispindrec(mrec)
********************************
   dispbegin()
   setpos( 12 , 39 ); dispout( left(mrec[2],16), 'w+/gr' )
   setpos( 13 , 39 ); dispout( padr(mrec[3] + ' ' + dispterm(),16), 'w+/gr' )
   setpos( 14 , 39 ); dispout( padr(mrec[4],16), 'w+/gr' )
   setpos( 15 , 39 ); dispout( padr(mrec[5],16), 'w+/gr' )
   setpos( 16 , 39 ); dispout( padr(mrec[6],16), 'w+/gr' )
   dispend()
return nil
**************************
static function dispterm()
**************************
return alltrim(substr('      Days  MonthsYears ',val(Acctmast->TERMUNIT)*6+1,6))
******************************
static function print_head()
******************************
    memvar mtitle,mpage,gsys_name,gcompany,mlm,mmonth,mdays,myear
    eval ({|| prnreptitle  ( 96,mlm,mpage,mtitle,'Program ID:AMSR0900',gsys_name,gcompany),;
              pagecenter   ( prow()+1,96,'As of '+ cmonth(gtrandate) +' '+trans(day(gtrandate),'99')+', '+trans(year(gtrandate),'9999') ),;
              mpage++;
         })
return nil
*******************************
static function print_subhead()
*******************************
   eval ({|| devpos( prow()+1, 00 ) , devout( "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄ ÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ" ),;
             devpos( prow()+1, 00 ) , devout( " Account Number                Account Name               Term Payment    Date      Review  " ),;
             devpos( prow()+1, 00 ) , devout( "                                                                        Executed     Date   " ),;
             devpos( prow()+1, 00 ) , devout( "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄ ÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ" ) ;
        })
return nil
********************************
static function dispmess()
********************************
   set device to screen
   dispbegin()
   fshadow( 11, 21, 19, 55, 2, 'w/gr')
   setpos ( 12, 22 ); dispout ( '  Account Name                 '  ,'bg+/gr' )
   setpos ( 13, 22 ); dispout ( '          Term                 '  ,'bg+/gr' )
   setpos ( 14, 22 ); dispout ( '       Payment                 '  ,'bg+/gr' )
   setpos ( 15, 22 ); dispout ( ' Date Executed                 '  ,'bg+/gr' )
   setpos ( 16, 22 ); dispout ( '   Review Date                 '  ,'bg+/gr' )
   setpos ( 17, 21 ); dispout ( 'ÆÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍµ','w/gr'   )
   setpos ( 18, 37 ); dispout(ltrim(trans( 0,'999')) + '%'           ,'w+/gr'  )
   dispend()
   set device to printer
return nil
******************************
static function print_rec(mrec)
******************************
   local mcol := { 0,17,58,63,71,82 }

   if prow() >= MAXROW
      __eject()
      print_head()
      print_subhead()
   endif
   eval ({|| devpos( prow()+1, mcol[1] ), devout( mrec[1] ) ,;
             devpos( prow()  , mcol[2] ), devout( mrec[2] ) ,;
             devpos( prow()  , mcol[3] ), devout( mrec[3] ) ,;
             devpos( prow()  , mcol[4] ), devout( mrec[4] ) ,;
             devpos( prow()  , mcol[5] ), devout( mrec[5] ) ,;
             devpos( prow()  , mcol[6] ), devout( mrec[6] ) ,;
	     ntotal := ntotal + 1 ;
        })
return ntotal
******************************
static function amsr0900open()
******************************
    local mretval := .f.
    memvar g_cis_path
    if netuse( '&g_AMS_PATH\Acctmast',.f.,5)
       set index to &g_AMS_PATH\Acctmast,;
                    &g_AMS_PATH\Acctrev
       set order to 2
       mretval := .t.
    endif
return mretval
*                   End of the program ( Amsr0900.prg )
*-------------------------------------------------------------------------------
FUNCTION MAKETEMP(xTEMP)

IF TRUE_BRCH == '001'
   DO WHILE .T.
      xTEMP := SUBSTR(ALLTRIM(g_USER_ID),1,2)+SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)

      IF FILE('C:\'+xTEMP+'.DBF')
         LOOP
      ELSE
         EXIT
      ENDIF
   ENDDO

   DBCREATE( ('C:\'+xTEMP), {{'FLD1','C',16,00},;
                             {'FLD2','C',40,00},;
                             {'FLD3','C',03,00},;
                             {'FLD4','C',07,00},;
                             {'FLD5','C',10,00},;
                             {'FLD6','C',10,00} ;
                            }                   ;
           )

   IF !NETUSE(('C:\'+xTEMP),.T.,10)
      RETURN .F.
   ENDIF
ENDIF

RETURN .T.
