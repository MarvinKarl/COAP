/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   program id.........:  amsr2004.prg                                         ³
³   Description........:  Unavailed credit approvals                           ³
³   Author.............:  Ariel B. Bulan                                       ³
³   Date...............:  01:59pm 07-Jul-1995                                  ³
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
   if amsr2004open()
      nosnow(.t.)
      amsr2004main()
      nosnow(.f.)
   endif
   eval ({|| __mrelease( "*", .t.), dbcloseall() })
endif
return
******************************
static function amsr2004main()
******************************
   *repcontrol ('amsr2004print()',,,8,33)
   repcon_ol ('amsr2004print()',,,8,33,,,.F.)
return nil
********************************
function amsr2004print()
********************************
   private mpage := 1
   setprc ( 0,0 )
   printhead ()
   printsubhead ()
   accessdbf ()
   __eject()
   setfont( 'PICA' )
return nil
******************************
static function accessdbf()
******************************
   local mrecno := 0 , mlastrec := Caheader->(lastrec()) ,;
         mscr   := savescreen(,,,)

   Caheader -> ( dbgotop() )
   Caheader -> ( dbeval ( {|| if ( Caheader->ACTAKEN == '3' .and. ;
                                   (Caheader->CALINE-Caheader->AVAILED) > 0 ,;
                                   eval ({|| mrecno++    ,;
                                             printrec ()  ;
                                        }),;
                                   nil ;
                                 );
                          },,;
                          {|| !Caheader->(eof()) } ;
                        );
               )
   restscreen( ,,,, mscr )
return nil
******************************
static function printrec()
******************************
   local mc := { 0,8,59,71,83,99 }

   @ prow()+1, mc[01]   say Caheader->CANUMBER  pict '99999'
   @ prow()  , mc[02]   say Caheader->CLNTCODE  pict '@R 99-99999'
   @ prow()  , pcol()+1 say printclnt()         pict '@XS40'
   @ prow()  , mc[03]   say Caheader->ACTDATE   pict '@D'
   @ prow()  , mc[04]   say Caheader->REVDATE   pict '@D'
   @ prow()  , mc[05]   say Caheader->CALINE    pict '999,999,999.99'
   @ prow()  , mc[06]   say Caheader->CALINE-Caheader->AVAILED pict '999,999,999.99'
   if prow() >= MAXROW
      fejectpause()
      printhead()
      printsubhead()
   endif
return nil
/*
********************************
static function printclnt()
********************************
return Client->(dbseek(Caheader->CLNTCODE)), Client->FULLNAME
*/
******************************
static function printhead()
******************************
   setfont     ( 'PICA')
   prnheader   ()
   pagecenter  ( prow()+2,80, gcompany )
   pagecenter  ( prow()+1,80, 'Unavailed Credit Approvals' )
   pagecenter  ( prow()+1,80, 'As of '+printdate() )
   setfont     ( 'CONDENSED' )
return nil
************************************************
static function prnheader( )
************************************************
   memvar gcompany,gsys_name,mpage
   devpos( prow()+1,00 ) ; devout ( gsys_name )
   devpos( prow()  ,69 ) ; devout ( 'Page : '+ltrim(trans(mpage,'9,999')) )
   devpos( prow()+1,00 ) ; devout ( 'Program ID:AMSR2004' )
   devpos( prow()  ,69 ) ; devout ( dtoc(date())+' '+time() )
   mpage++
return nil
/*
******************************
static function printdate()
******************************
   memvar mtrandate
return alltrim(cmonth(mtrandate))+' '+ltrim(trans(day(mtrandate),'99'))+', '+ltrim(trans(year(mtrandate),'9999'))
*/
******************************
static function printsubhead()
******************************
   @ prow()+2, 00 say 'ÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   @ prow()+1, 00 say '  CA    Client Code/Name                                     Date       Expiry     Total Approved    Unavailed   '
   @ prow()+1, 00 say 'Number                                                      Approved     Date         Facility        Amount     '
   @ prow()+1, 00 say 'ÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
return nil
******************************
static function amsr2004open()
******************************
   local mretval := .f.
   memvar g_cis_path
   if netuse('&g_AMS_PATH\Caheader',.f.,5)
      set index  to &g_AMS_PATH\Caheader,;
                    &g_AMS_PATH\Carev,;
                    &g_AMS_PATH\Caclnt
      Caheader->( dbsetorder (1) )
      if netuse( '&g_cis_path'+'\Client.dbf',.f.,5)
         set index to &g_cis_path\Cliecd,;
                      &g_cis_path\Clienm
         mretval := .t.
      endif
   endif
return mretval
*                     End of the program ( Amsr2004.prg )
