/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   program id.........:  amsr2005.prg                                         ³
³   description........:  Accounts Executed per account officer                ³
³   author.............:  Ariel B. Bulan                                       ³
³   date...............:  03:05pm 18-Aug-1995                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                         U P D A T E S                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        Who        ³     When      ³               Why                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include "Colf.ch"
#include "Inkey.ch"

#define MAXROW 55
memvar ax_level,g_user_id
if chkpass( procname(),ax_level,g_user_id )
   if amsr2005open()
      nosnow(.t.)
      amsr2005main()
      nosnow(.f.)
   endif
   eval ({|| __mrelease( "*", .t.), dbcloseall() })
endif
return
******************************
static function amsr2005main()
******************************
   LOCAL xSTR
   private  mstart   := ctod ( '//' ) , mend := ctod ( '//' )

   if getdates()
      *repcontrol ('amsr400print()',,,8,33)
      xSTR := CHK_PAR(mSTART)+CHK_PAR(mEND)+CHK_PAR(gCOMPANY)+CHK_PAR(gSYS_NAME)
      REPCON_OL ('AMSR400PRINT()',,,8,33,,xSTR,.T.)
   endif
return nil
***************************
function amsr400print()
***************************
   local msummary := {}
   private mpage := 1,grtotal := 0
   setprc( 0,0 )
   printdetails( msummary )
   chkeject()
   @ prow()+1, 56 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   @ prow()+1, 09 say 'Total : '
   @ prow()  , 56 say grtotal pict '999,999,999,999.99'
   @ prow()+1, 56 say '=================='
   __eject()
   //printsummary( msummary )
return nil

********************************************
*
static function printdetails ( msummary )
********************************************
   memvar mstart,mend
   local mscr := savescreen ( ,,, )

   //dispbar()
   printhead()
   printsubhead()
   Acctmast -> ( dbgotop () )
   Acctmast -> ( dbeval  ( {|| if ( Acctmast -> VALDATE >= mstart  .and.  ;
                                    Acctmast -> VALDATE <= mend    .AND.  ;
                                    ACCTMAST->BRCODE == g_PAR_BRCH .and. Acctmast->STATUS  != '0' ,;
                                    printrec() ,;
                                    nil ;
                                  );
                           },,;
                           {|| !Acctmast -> ( eof() ) ;
                           } ;
                         ) ;
               )

   Acctdaly-> ( dbsetorder (2) )
   Acctdaly-> ( dbseek ( dtos(mstart),.t. ) )
   Acctdaly ->( dbeval  ( {|| if ( Acctdaly -> VALDATE >= mstart  .and. ;
                                   Acctdaly -> VALDATE <= mend    .and. ;
                                   ACCTDALY->BRCODE == g_PAR_BRCH .AND. ;
                                   !Acctmast->(dbseek(ACCTDALY->BRCODE+Acctdaly->Acctno)),;
                                    printrec(.f.) ,;
                                    nil ;
                                  );
                           },,;
                           {|| !Acctdaly -> ( eof() ) } ;
                         ) ;
              )

   restscreen ( ,,,, mscr )
return nil

****************************************
*
static function printao( msummary  )
****************************************
   memvar mstart,mend
   local maocode := Acctmast ->AOCODE, msubtotal := 0

   @ prow()+1, 00       say maocode
   @ prow()  , pcol()+1 say '-'
   @ prow()  , pcol()+1 say prnao( maocode )
   setpos  ( 16,26 ) ; dispout ( maocode + left( prnao ( maocode ),35 ), 'w+/gr' )
   Acctmast -> ( dbeval ( {|| if ( Acctmast -> VALDATE >= mstart .and. Acctmast -> VALDATE <= mend,;
                                   printrec( @msubtotal ),;
                                   nil ;
                                 );
                          },,;
                          {|| !Acctmast -> ( eof() ) .and.   ;
                               Acctmast -> AOCODE == maocode ;
                          };
                        );
               )
   Acctmast -> ( dbskip ( -1 ) )
   @ prow()+1, 60 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   @ prow()+1, 15 say 'Sub-total :   '
   @ prow()  , 60 say msubtotal pict '999,999,999.99'
   @ prow()+1, 60 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   aadd ( msummary, { maocode, ' - ' + prnao( maocode ),;
                      msubtotal ;
                    };
        )
return nil
**************************************************
static function printrec( mtal )
**************************************************
   local mc := { 2,10+4,51+4,60+4,75+4,86+4,94+4}
   local ndf
   mtal := if ( mtal == nil,.t.,mtal )
   ndf := if( mtal,'Acctmast','Acctdaly' )
   //disprec()
   grtotal += (ndf)->Principal

   if ndf == 'Acctmast'
      @ prow()+1, mc [1]   say (NDF)->BRCODE+right ( (ndf) -> ACCTNO, 5 )+'*'  PICT '@R 999-99999A'
   else
      @ prow()+1, mc [1]   say (NDF)->BRCODE+right ( (ndf) -> ACCTNO, 5 )      PICT '@R 999-99999'
   endif

   @ prow()  , mc [2]   say left  ( (ndf) -> ACCTNAME,40 )
   @ prow()  , mc [3]   say eval( {||  if(Facility->(dbseek((ndf)->FCLTYCODE)),substr(Facility->Fcltyalias,1,8),'      ') } )
   @ prow()  , mc [4]   say (ndf) -> PRINCIPAL pict '999,999,999.99'
   @ prow()  , mc [5]   say (ndf) -> TERM      pict '999'
   @ prow()  , pcol()+1 say prntermunit ( (ndf) -> TERMUNIT ) pict '@X'
   @ prow()  , mc [6]   say (ndf) -> TRUERATE  pict '99.9999'
   @ prow()  , mc [7]  say (ndf) ->Aocode
  // msubtotal += Acctmast -> PRINCIPAL
   chkeject()
return nil
/*
******************************************
static function prntermunit ( mtermunit )
******************************************
   local mretval

   do case
      case alltrim( mtermunit ) == '1'
         mretval := 'DAYS'
      case alltrim( mtermunit ) == '2'
         mretval := 'MONTHS'
      otherwise
         mretval := 'YEARS'
   endcase
return mretval
********************************
static function prnao( maocode )
********************************
   Ao -> ( dbseek ( maocode ) )
return Ao -> AONAME
*/
******************************
static function printsubhead()
******************************
   @ prow()+2,00 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄ ÄÄÄÄÄ'
   @ prow()+1,00 say '  Acct. No.   Account Name                             Facility     Purchase     Term      True     AO '
   @ prow()+1,00 say '                                                                     Amount                Rate        '
   @ prow()+1,00 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄ ÄÄÄÄÄ'
return nil
******************************
static function printhead()
******************************
   memvar gcompany,gsys_name,mpage,mstart,mend

   setfont ( 'PICA' )
   devpos( prow()+1,00 ) ; devout ( gsys_name )
   devpos( prow()  ,65 ) ; devout ( 'Page : '+ltrim(trans(mpage,'9,999')) )
   devpos( prow()+1,00 ) ; devout ( 'Program ID:AMSR2005' )
   devpos( prow()  ,65 ) ; devout (  dtoc(date())+' '+time() )
   mpage++
   pagecenter  ( prow()+2,80, gcompany )
   pagecenter  ( prow()+1,80, 'Accounts Executed' )
   pagecenter  ( prow()+1,80, 'From '+ ddmmmyyyy( mstart ) + ' to ' + ddmmmyyyy( mend )  )
   setfont ( 'ELITE' )
return nil
/*
********************************************
static function ddmmmyyyy( mdate )
********************************************
   local md,mm,my

   md := right( '0'+ ltrim(trans(day(mdate),'99')),2 )
   mm := left( cmonth(mdate),3   )
   my := trans( year(mdate),'9999')
return ( md + '-' + mm + '-' + my )
*/
********************************************
static function printsummary ( msummary )
********************************************
   local mgrandtotal := 0

   asort ( msummary,,, {|x,y| x[3] > y[3] } )
   @ prow()+1 , 00 say 'SUMMARY : '
   aeval ( msummary, {|x| devpos ( prow()+1,03 ) , devoutpict ( x [1],'@X' ) ,;
                          devpos ( prow()  ,09 ) , devoutpict ( x [2],'@X' ) ,;
                          devpos ( prow()  ,60 ) , devoutpict ( x [3],'999,999,999.99' ) ,;
                          mgrandtotal += x[3] ,;
                          chkeject( .t. ) ;
                    };
         )
   @ prow()+1, 56 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   @ prow()+1, 09 say 'Total : '
   @ prow()  , 56 say mgrandtotal pict '999,999,999,999.99'
   @ prow()+1, 56 say '=================='
   __eject()
return nil
/*
*****************************
static function getdates()
*****************************
   memvar mstart,mend

   fshadow( 11, 30, 14, 48, 2 , 'gr+/g' )
   setcolor( 'w/g, w+/n,,, w+/g' )
   @ 11, 31 say 'Report Date' color 'bg+/g'
   @ 12, 31 say 'From ' get mstart pict '@D' valid !empty ( mstart )
   @ 13, 31 say '  To ' get mend   pict '@D' valid chkmend( mstart, mend )
   setcursor ( 3 )
   read
   setcursor ( 0 )
return lastkey() != K_ESC
*/
********************************
static function chkeject(msumm)
********************************
   if prow() >= MAXROW
      fejectpause()
      if msumm == nil
         printhead()
         printsubhead()
      endif
   endif
return nil
/*
********************************************
static function chkmend( mstart, mend )
********************************************
   local mretval := .f.
   if !empty ( mend )
      if mend < mstart
         error ( 'End Date is "<" Beginning Date.' )
      else
         mretval := .t.
      endif
   endif
return mretval
****************************************
static function dispbar( )
****************************************
   memvar mstart,mend

   set device to screen
   dispbegin()
   fshadow ( 14, 10, 20, 66, 2, 'w/gr' )
   @ 15, 11 say ' Report Date  ' color 'bg+/gr'
   @ 16, 11 say 'Acct Officer  ' color 'bg+/gr'
   @ 17, 11 say '   Acct Name  ' color 'bg+/gr'
   @ 18, 11 say '              ' color 'bg+/gr'
   @ 19, 11 say '              ' color 'bg+/gr'
   @ 15, 26 say dtoc ( mstart ) + '-' + dtoc ( mend ) color 'w+/gr'
   dispend()
   set device to printer
return nil
******************************
static function disprec()
******************************
   set device to screen
   dispbegin ()
   scroll    ( 17,26,19,65,1 )
   @ 19,26 say left( Acctmast -> ACCTNAME, 40 ) color 'w+/gr'
   dispend   ()
   set device to printer
return nil
*/
******************************
static function amsr2005open()
******************************
   local mretval := .f.
   memvar g_cis_path

   if netuse( '&g_AMS_PATH\Acctmast',.f., 5 )
      set index to &g_AMS_PATH\Acctmast //,Acctacno,Acctclnt,Sureclnt,Acctfa,Acctsub2,Acctaonm
      set order to 7
      if netuse( '&g_AMS_PATH\Facility',.f.,5 )
         set index to &g_AMS_PATH\Fcltycd
         if netuse( '&g_cis_path'+'\Ao.dbf',.f.,5)
            set index to &g_cis_path\Ao.ntx
            if netuse('&g_AMS_PATH\Acctdaly',.f.,5 )
               set index to &g_AMS_PATH\Acctdaly, &g_AMS_PATH\Acctdate
               mretval := .t.
            endif
         endif
      endif
   endif
return mretval
*                     End of the program ( Amsr2005.prg )
