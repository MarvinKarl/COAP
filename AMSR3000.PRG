/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   program id.........:  amsr2006.prg                                         ³
³   description........:  Transaction Volume Per Branch                        ³
³   author.............:  Ariel B. Bulan                                       ³
³   date...............:  04:54pm 21-Aug-1995                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                         U P D A T E S                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        Who        ³     When      ³               Why                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include "Colf.ch"
#include "Inkey.ch"

#define MAXROW 53
   memvar ax_level,g_user_id
   private mtemp
   if chkpass( procname(),ax_level,g_user_id )
      if amsr2006open()
         nosnow(.t.)
         amsr2006main()
         nosnow(.f.)
      endif
      dbcloseall()
      ferase ( mtemp ) ; ferase ( mtemp + '.dbf' ) ; ferase ( mtemp + '.ntx' )
      __mrelease( "*", .t.)
   endif
return
******************************
static function amsr2006main()
******************************
   memvar mtrandate
   LOCAL   cTMP := '', xSTR := ''                  && RED 042505
   private mmonth1 := month ( mtrandate ) , myear1 := year ( mtrandate ) ,;
           mmonth2 := month ( mtrandate ) , myear2 := year ( mtrandate ) ,;
           mpage   := 1, mar := {}

   if create_temp()
      if getperiods()
         IF TRUE_BRCH == '001'                                 && RED 042205
            mscr1 := savescreen( ,,, )
            trans_to_temp()
            trans_to_array()
            restscreen ( ,,,, mscr1 )
         *--->                                  && RED 042505
         ELSE
            xSTR := CHK_PAR(mMONTH1) + CHK_PAR(mMONTH2) + ;
                    CHK_PAR(mYEAR1) + CHK_PAR(mYEAR2)
            cTMP := CPS_REQST(xSTR,'TRANS3000')

            mTEMP := cTMP

            xSTR := CHK_PAR(cTMP) + CHK_PAR(mMONTH1) + CHK_PAR(mMONTH2)   + ;
                    CHK_PAR(mYEAR1) + CHK_PAR(mYEAR2) + CHK_PAR(gSYS_NAME) +;
                    CHK_PAR(gCOMPANY) + CHK_PAR(mPAGE)
         ENDIF
         *--->                                  && RED 042205
         *repcontrol( 'amsr2006print()',,,8,33 )
         REPCON_OL( 'AMSR2006PRINT()',,,8,33,,xSTR,.T. )
      endif
   else
      error ( "Can't Create Temporary File!" )
   endif
return nil
************************************
static function trans_to_array()
************************************
   memvar mtemp
   local mctr := 0

   dispbar2()
   ( mtemp ) -> ( dbgotop () )
   ( mtemp ) -> ( dbeval ( {|| per_yymm( left( dtos ( ( mtemp ) -> VALDATE ),6 ),@mctr ) ;
                           },,;
                           {|| ! ( mtemp ) -> ( eof() ) };
                         );
                )
   tone  ( 1600, 3 ) ; inkey ( .3 )
return nil
****************************************
static function per_yymm ( yymm,mctr )
****************************************
   memvar mtemp

   ( mtemp ) -> ( dbeval ( {|| per_branch( substr( ( mtemp ) -> ACCTNO, 3, 2 ),yymm,@mctr ) ;
                           },,;
                           {|| ! ( mtemp ) -> ( eof() ) .and. ;
                               left( dtos ( ( mtemp ) -> VALDATE ),6 ) == yymm ;
                           };
                         );
                )
   ( mtemp ) -> ( dbskip ( -1 ) )
return nil
********************************************
static function per_branch( mb, yymm, mctr )
********************************************
memvar mtemp,mar
local mleasectr := 0, mloansctr := 0, mtlease := 0, mtloans := 0

@ 15, 28 say left( dispbranch ( mb ), 38 ) color 'w+/gr'
scroll( 16, 28, 18, 65, 1 )
( mtemp )->( dbeval( { || devpos( 14,    28 ), devout( ltrim( trans( ++mctr, '99,999' ) )                  , 'w+/gr' ),;
                          devpos( 14, col() ), devout( '/'                                                 , 'w+/gr' ),;
                          devpos( 14, col() ), devout( ltrim( trans( ( mtemp )->( lastrec() ), '99,999' ) ), 'w+/gr' ),;
                          devpos( 18,    28 ), devout( left( ( mtemp )->ACCTNAME, 38 )                     , 'w+/gr' ),;
                          if ( ( mtemp )->SETCODE == '1',;
                                 eval( { || mtlease += ( (mtemp)->PRINCIPAL - ( (mtemp)->PRINCIPAL* ((mtemp)->gd/100) ) ) ,;
                                            mleasectr++ ;
                                       } ;
                                     ),;
                                 eval( { || mtloans += ( (mtemp)->PRINCIPAL ),;
                                            mloansctr++ ;
                                       };
                                     );
                             );
                     },,;
                     { || !( mtemp )->( eof() ) .and. left( dtos( ( mtemp )->VALDATE ), 6 ) == yymm .and. subs( ( mtemp )->ACCTNO, 3, 2 ) == mb } ) )
( mtemp )->( dbskip( -1 ) )
aadd( mar, { left( yymm, 4 ), right( yymm, 2 ), mb, mtlease, mleasectr, mtloans, mloansctr, mtlease + mtloans, mleasectr + mloansctr } )
return( nil )
************************************
static function trans_to_temp()
************************************
   memvar mmonth1 , myear1 , mmonth2 , myear2
   local mperiod1 :=  trans( myear1,'9999' ) + right ( '0' + ltrim(trans(mmonth1,'99')),2 )
   local mperiod2 :=  trans( myear2,'9999' ) + right ( '0' + ltrim(trans(mmonth2,'99')),2 )
   local mctr := 0

   Acctmast -> ( dbseek ( mperiod1,.t. ) )
   if val ( left ( dtos ( Acctmast -> VALDATE ) , 6 ) ) >= val ( mperiod1 )
      dispbar1()
      Acctmast -> ( dbeval ( {|| addtotemp( @mctr ) },,;
                             {|| !Acctmast -> ( eof() ) .and.           ;
                                  val ( left ( dtos ( Acctmast -> VALDATE ) , 6 ) ) >= val ( mperiod1 ) .and. ;
                                  val ( left ( dtos ( Acctmast -> VALDATE ) , 6 ) ) <= val ( mperiod2 )      ;
                             };
                           );
                  )
      ( mtemp ) -> ( dbcommit() )
      tone  ( 1600, 3 ) ; inkey ( .3 )
   endif
return nil
********************************
static function addtotemp(mctr)
********************************
   memvar mtemp
if ACCTMAST->status != 0 // CANCELLED RLV 08.18.2010
   @ 14,    28 say alltrim( ltrim( trans( ++mctr,'99,999' ) ) ) + '/' color 'w+/gr'
   @ 14, col() say padr ( ltrim( trans( Acctmast -> (lastrec()),'99,999' ) ), 6 ) color 'w+/gr'
   @ 15,    28 say Acctmast -> VALDATE color 'w+/gr' 
   scroll( 16, 28, 18, 65, 1 )
   @ 18,    28 say left( Acctmast -> ACCTNAME, 38 ) color 'w+/gr' 
   if ( mtemp ) -> ( netlock ( 'A',0 ) )
      ( mtemp ) -> ACCTNO    := Acctmast -> ACCTNO
      ( mtemp ) -> VALDATE   := Acctmast -> VALDATE
      ( mtemp ) -> FCLTYCODE := Acctmast -> FCLTYCODE
      ( mtemp ) -> SETCODE   := getsetcode()
      ( mtemp ) -> PRINCIPAL := Acctmast -> PRINCIPAL - ( Acctmast->principal*(Acctmast->gd/100) )
      ( mtemp ) -> ACCTNAME  := Acctmast -> ACCTNAME
   endif
endif   
return nil
********************************
static function getsetcode()
********************************
   Facility -> ( dbseek ( Acctmast ->FCLTYCODE ) )
return Facility -> SETCODE
********************************
static function create_temp()
********************************
   memvar mtemp
   local mretval := .f.
   local mstruct := { { 'ACCTNO'   ,'C',14,0 }, { 'VALDATE'  ,'D',08,0 },;
                      { 'FCLTYCODE','C',05,0 }, { 'SETCODE'  ,'C',01,0 },;
                      { 'PRINCIPAL','N',16,2 }, { 'ACCTNAME' ,'C',50,2 },;
                      { 'GD','N',9,6 } ;
                    }

   IF TRUE_BRCH == '001'                                     && RED 042205
      mtemp  := uniqfile()
      dbcreate ( ( mtemp ) , mstruct )
      if valtype ( mtemp ) != 'U'
         if netuse ( (mtemp) ,.t.,0 )
            index on dtos  ( VALDATE )   + ;     // Execution date
                     substr( ACCTNO,3,2) + ;     // Branch
                     SETCODE               ;     // Setcode
                     to &mtemp
            set index to &mtemp
            mretval := .t.
         endif
      endif
   ELSE
      mTEMP := ' '
      mRETVAL := .T.
   ENDIF
return mretval
********************************
function amsr2006print()
********************************
   local mscr := savescreen ( ,,, )
   setprc( 0,0 )
   printhead()
   printsubhead()
   print_it()
   restscreen ( ,,,, mscr )
return nil
*******************************
static function print_it()
*******************************
   memvar mar
   local mctr := 1,mmax := len ( mar )

   dispbar3()
   setpos ( 13, 22 ) ; dispout ( 'Sorting ...','gr+/gr' )
   asort  ( mar,,, { |x,y| x[1]+x[2]+x[3] < y[1]+y[2]+y[3] } )
   setpos ( 13, 22 ) ; dispout ( 'Printing...','gr+/gr' )
   while mctr <= len ( mar )
      setpos ( 14, 37 ); dispout ( padr( upper(fullmonth(val(mar[mctr][2]))),9 ) + ' '+ mar [mctr][1], 'w+/gr' )
      ppermonth ( mar [ mctr ] [1],mar [ mctr ] [2], @mctr )
   enddo
   __eject()
return nil
**************************************************
static function ppermonth ( myear,mm,mctr )
**************************************************
   memvar mar
   local mperiod := myear+mm
   local mc := { 3,29,44,51,66,72,87 }
   private mttlease   , mttleasectr, mttloans, mttloansctr, mmonthtotal, mtotalccts

   mttlease := mttleasectr := mttloans := mttloansctr := mmonthtotal := mtotalccts := 0
   @ prow() + 2, 00 say fullmonth( val(mm) ) + ' ' + trans( myear,'9999' )
   while mar [ mctr ] [1] + mar [ mctr ] [2] == mperiod
       setpos ( 15, 37 ); dispout ( padr( left( dispbranch ( mar [mctr ] [ 3 ] ), 25 ),22), 'w+/gr' )
       pperbranch( mperiod,@mctr,mar [ mctr ] [ 3 ] )
       if mctr > len ( mar )
          exit
       endif
   enddo
   @ prow() + 1 , mc [2] say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   @ prow()     , mc [3] say 'ÄÄÄÄÄ'
   @ prow()     , mc [4] say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   @ prow()     , mc [5] say 'ÄÄÄÄÄ'
   @ prow()     , mc [6] say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   @ prow()     , mc [7] say 'ÄÄÄÄÄ'
   @ prow() + 1 , mc [1] say 'Month Total : '
   @ prow()     , mc [2] say mttlease    pict '999,999,999.99'
   @ prow()     , mc [3] say mttleasectr pict '9,999'
   @ prow()     , mc [4] say mttloans    pict '999,999,999.99'
   @ prow()     , mc [5] say mttloansctr pict '9,999'
   @ prow()     , mc [6] say mmonthtotal pict '999,999,999.99'
   @ prow()     , mc [7] say mtotalccts  pict '9,999'
   @ prow() + 1 , mc [2] say  'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   @ prow()     , mc [3] say  'ÄÄÄÄÄ'
   @ prow()     , mc [4] say  'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   @ prow()     , mc [5] say  'ÄÄÄÄÄ'
   @ prow()     , mc [6] say  'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   @ prow()     , mc [7] say  'ÄÄÄÄÄ'
return nil
****************************************************
static function pperbranch( mperiod,mctr,mbranch )
****************************************************
   memvar mar
   memvar mttlease   , mttleasectr, mttloans, mttloansctr, mmonthtotal, mtotalccts
   local mtlease := 0 , mleasectr := 0 ,;
         mtloans := 0 , mloansctr := 0
   
   while mar [ mctr ] [1] + mar [ mctr ] [2] == mperiod .and. ;
         mar [ mctr ] [3] == mbranch
         dispstat ( mctr, len( mar ) )
         mtlease   += mar [ mctr ] [ 4 ] ; mleasectr += mar [ mctr ] [ 5 ]
         mtloans   += mar [ mctr ] [ 6 ] ; mloansctr += mar [ mctr ] [ 7 ]
         mctr++
         if mctr > len ( mar )
            exit
         endif
   enddo
   printrec( { mbranch,mtlease,mleasectr,mtloans,mloansctr,mtlease+mtloans,mleasectr+mloansctr } )
   mttlease       += mtlease
   mttleasectr    += mleasectr
   mttloans       += mtloans
   mttloansctr    += mloansctr
   mmonthtotal    += (mtlease+mtloans)
   mtotalccts     += (mleasectr+mloansctr)
return nil
**************************************
static function printrec( m2 )
**************************************
   local mc := { 3,29,44,51,66,72,87 }

   @ prow()+1, mc [1] say left( dispbranch ( m2 [ 1 ] ), 25 )
   @ prow()  , mc [2] say m2 [ 2 ] pict '999,999,999.99'
   @ prow()  , mc [3] say m2 [ 3 ] pict '9,999'
   @ prow()  , mc [4] say m2 [ 4 ] pict '999,999,999.99'
   @ prow()  , mc [5] say m2 [ 5 ] pict '9,999'
   @ prow()  , mc [6] say m2 [ 6 ] pict '999,999,999.99'
   @ prow()  , mc [7] say m2 [ 7 ] pict '9,999'
   chkeject()
return nil
*****************************
static function chkeject()
*****************************
   if prow() >= MAXROW
      fejectpause()
      printhead()
      printsubhead()
   endif
return nil
*******************************
static function printsubhead()
*******************************
  @ prow() + 2 , 00 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄ'
  @ prow() + 1 , 00 say 'Month / Branch               Lease          # of   Loan           # of  Branch Total   Total'
  @ prow() + 1 , 00 say '                             (Net Amt Fin.) Accts                 Accts                Accts'
  @ prow() + 1 , 00 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄ'
return nil
*****************************
static function printhead()
*****************************
   memvar mmonth1 , myear1 ,;
          mmonth2 , myear2
   memvar gcompany,gsys_name,mpage

   setfont ( 'PICA' )
   devpos( prow()+1,00 ) ; devout ( gsys_name )
   devpos( prow()  ,69 ) ; devout ( 'Page : '+ltrim(trans(mpage,'9,999')) )
   devpos( prow()+1,00 ) ; devout ( 'Program ID:AMSR2006' )
   devpos( prow()  ,69 ) ; devout (  dtoc(date())+' '+time() )
   mpage++
   pagecenter  ( prow()+2,80, gcompany )
   pagecenter  ( prow()+1,80, 'Transaction Volume Per Branch' )
   pagecenter  ( prow()+1,80, 'for '+ dispmy( mmonth1,myear1 ) + ' to ' + dispmy( mmonth2,myear2 ) )
   setfont ( 'ELITE' )
return nil
******************************************
static function dispmy( mmonth,myear )
******************************************
return fullmonth ( mmonth ) + ' ' + trans ( myear,'9999' )
************************************
static function fullmonth( mmonth )
************************************
   local mlist    := space( 9 ) + 'January  '+'February '+'March    '+;
                                  'April    '+'May      '+'June     '+;
                                  'July     '+'August   '+'September'+;
                                  'October  '+'November '+'December '
return alltrim ( substr( mlist, 9 * mmonth + 1, 9 ) )
*****************************
static function getperiods()
*****************************
   local getlist := {}, mcolor := setcolor()
   memvar mmonth1, myear1, mmonth2, myear2

   fshadow( 12, 43, 15, 58, 2, 'gr+/g' )
   setcolor( 'w/g, w+/n,,, w+/g' )
   @ 12, 44 say 'Report Date' color 'bg+/g'
   @ 13, 44 say 'From    /'
   @ 14, 44 say '  To    /'
   @ 13, 51 get mmonth1 pict '99'   when  sel_month( @mmonth1 ) valid chkmonth ( mmonth1 )
   @ 13, 54 get myear1  pict '9999' valid chkyear( myear1, myear2, 1 )                       
   @ 14, 51 get mmonth2 pict '99'   when  sel_month( @mmonth2 ) valid chkmonth ( mmonth2 )
   @ 14, 54 get myear2  pict '9999' valid chkyear( myear1, myear2, 2 )                      
   setcursor( 3 )
   read
   setcursor( 0 )
   setcolor( mcolor )
return lastkey() != K_ESC
********************************************
static function sel_month ( mmonth )
********************************************
return eval( { | x, y, z | x := setcolor(), y := savescreen( ,,, ),;
                          fshadow( 10, 54, 19, 64, 2, 'w/gr' ),;
                          devpos( 11, 57 ), devout( 'Month', 'bg+/gr' ),;
                          devpos( 12, 54 ) , devout( 'ÃÄÄÄÄÄÄÄÄÄ´', 'w/gr' ),;
                          setcolor( 'w/gr, w+/n,,, n/gr' ),;
                          z := achoice( 13, 55, 18, 63,;
                               { 'January', 'February', 'March', 'April',;
                                 'May', 'June', 'July', 'August', 'September',;
                                 'October', 'November', 'December' },,, mmonth ),;
                          setcolor( x ), restscreen( ,,,, y ), mmonth := if( z == 0, mmonth, z ), .t. } )
************************************************
static function chkyear( myear1,myear2,mwhat )
************************************************
   local mretval := .f.
   local my := if ( mwhat == 1, myear1, myear2 )

   if !empty( my ) .or. lastkey() != K_ESC
      if my == myear2
         if my < myear1
            error ( 'Second Year is "<" First Year.' )
         else
            mretval := .t.
         endif
      else
         mretval := .t.
      endif
   endif
return mretval
**************************************
static function chkmonth ( mmonth )
**************************************
   local mretval := .f.

   if !empty ( mmonth ) .or. lastkey() != K_ESC
      if mmonth < 1 .or. mmonth > 12
         error ( 'Invalid Range of Month!' )
      else
         mretval := .t.
      endif
   endif
return mretval
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
************************************************
static function dispbranch ( mbranch )
************************************************
   Branches -> ( dbseek ( mbranch ) )
return Branches -> BRNAME
************************************
static function dispbar3()
************************************
   set device to screen
   dispbegin ()
   fshadow ( 12, 21, 18, 59, 2, 'w/gr' )
   @ 13, 22 say 'Printing...' color 'gr+/gr'
   @ 14, 28 say ' Month  '  color 'bg+/gr'                     
   @ 15, 28 say 'Branch  '  color 'bg+/gr'                     
   @ 16, 21 say 'ÆÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍµ' color 'w/gr'  
   dispend   ()
   set device to printer
return nil
************************************
static function dispbar1()
************************************
   dispbegin ()
   fshadow ( 12, 10, 19, 66, 2, 'w/gr' )
   @ 13, 11 say 'Filtering Records by Date of Execution...' color 'gr+/gr'
   @ 14, 13 say '      Record  ' color 'bg+/gr'
   @ 15, 13 say '        Date  ' color 'bg+/gr'
   @ 16, 13 say 'Account Name  ' color 'bg+/gr'
   dispend   ()
return nil
************************************
static function dispbar2()
************************************
   dispbegin ()
   fshadow ( 12, 10, 19, 66, 2, 'w/gr' )
   @ 13, 11 say 'Dividing Records by Branches...' color 'gr+/gr'
   @ 14, 13 say '      Record  ' color 'bg+/gr'
   @ 15, 13 say '      Branch  ' color 'bg+/gr'
   @ 16, 13 say 'Account Name  ' color 'bg+/gr'
   dispend   ()
return nil
*****************************************
static function dispstat ( mctr, mmax )
*****************************************
   local mper := ( mctr / mmax ) * 100
   local mcol := 22 + (( mctr / mmax )/100) * 37 * 100

   set device to screen
   dispbegin()
   setpos ( 17,22 ) ; dispout ( repl ( ' ',mcol-22) ,'n/w' )
   if col() >= 40
      do case
         case col() == 40
            setpos ( 17,39 ) ; dispout ( left ( ltrim(trans(mper,'999')),1)       ,'n/w'   )
            setpos ( 17,40 ) ; dispout ( right( rtrim(trans(mper,'999')),1)+ '%'  ,'w+/gr' )
         otherwise
            setpos ( 17,39 ) ; dispout ( ltrim( trans( mper, '999' ) ) + '%','n/w')
      endcase
   else
      setpos ( 17,39 ) ; dispout ( ltrim( trans( mper, '999' ) ) + '%','w+/gr')
   endif
   dispend()
   set device to printer
return nil
******************************
static function amsr2006open()
******************************
   local mretval := .f.
   memvar g_cis_path,g_grf_path

   if netuse( '&g_AMS_PATH\Acctmast',.f., 5 )
      set index to &g_AMS_PATH\Acctval,;
                   &g_AMS_PATH\Acctmast,;
                   &g_AMS_PATH\Acctacno,;
                   &g_AMS_PATH\Acctclnt,;
                   &g_AMS_PATH\Sureclnt,;
                   &g_AMS_PATH\Acctfa,;
                   &g_AMS_PATH\Acctsub2,;
                   &g_AMS_PATH\Acctaonm
      if netuse( '&g_AMS_PATH\Facility',.f.,5 )
         set index to &g_AMS_PATH\Fcltycd
         if netuse( '&g_grf_path\Branches.dbf',.f., 5)
            set index to &g_grf_path\Branches
            mretval := .t.
         endif
      endif
   endif
return mretval
*                     End of the program ( Amsr2006.prg )
