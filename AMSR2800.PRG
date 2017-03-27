/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³   program id.........:  Amsr1900.prg                                ³
 ³   Description........:  Clients w/ OSBAL's of >=1 MILLION PESO      ³
 ³   Author.............:  Ariel B. Bulan                              ³
 ³   Date...............:  10:00am 21-Apr-19945                        ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³                         U P D A T E S                               ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³        Who        ³     When      ³               Why               ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

#include "Colf.ch"
#include "Inkey.ch"

#define MAXROW 53
#define ONE_MILLION 1000000
#xtrans accu_osbal ( <(mosbal)>,<mclntcode>,<(mrecno)>,<mlastrec> ) => ;
                     eval({|| Acctmast->( dbeval ({|| if( Acctmast->STATUS == '1',;
                                                          eval ({|| <mrecno>++ ,;
                                                                    disp_bar( <mrecno>,mlastrec ) ,;
                                                                    <mosbal> += Acctmast->OSBAL    ;
                                                               }),;
                                                          nil );
                                                  },,;
                                                  {|| !Acctmast->(eof()) .and. Acctmast->CLNTCODE == <mclntcode> }) );
                         })

#xtrans add_array( <mar>,<mclntcode>,<(mtotal)>,<mosbal> ) => ;
                           eval ({|| aadd( <mar>, { <mclntcode> ,;
                                                    trans(<mosbal>,'999,999,999.99') ;
                                                  };
                                         ),;
                                     mtotal += mosbal ;
                                })

#xtrans getlastrec(<(mlastrec)>) => Acctmast->( dbeval({|| if( Acctmast->STATUS == '1' ,<mlastrec>++, nil )},,{||!Acctmast->(eof())}) )
memvar ax_level,g_user_id
if chkpass( procname(),ax_level,g_user_id )
   if amsr1900open()
      amsr1900main()
   endif
   eval ({|| __mrelease( "*", .t.), dbcloseall() })
endif
return
******************************
static function amsr1900main()
******************************
   memvar gtrandate
   eval ({|x,y,z| x := savedbf  (x) ,;
                  y := setcolor ()  ,;
                  z := setcursor()  ,;
                  dbselectarea  ( "Acctmast" ) ,;
                  repcon_ol    ('amsr1900print()',,,8,33,,,.F.) ,;     &&repcontrol    ('amsr1900print()',,,8,33) ,;
                  restdbf       (x)   ,;
                  setcolor      (y)   ,;
                  setcursor     (z)    ;
        })
return nil
*******************************
function amsr1900print()
*******************************
   local mscr := savescreen(,,,)
   memvar gtrandate
   private mpage := 1,mmonth,mdays,myear,mtitle
   mmonth := month ( gtrandate )
   mdays  := day   ( gtrandate )
   myear  := year  ( gtrandate )
   setprc(0,0)
   setfont( 'NORMAL' )
   printrec()
   restscreen(,,,,mscr)
return nil
******************************
static function printrec()
******************************
   local mclntcode,mosbal,mtotal := 0, mar := {}, mrecno := 0, mlastrec := 0

   Acctmast->( dbgotop() )
   getlastrec( mlastrec  )
   disp_message( 'Validating Accounts...' )
   Acctmast->( dbgotop() )
   Acctmast->( dbeval({|| if ( Acctmast->STATUS == '1',;
                               eval ({|| mclntcode := Acctmast->CLNTCODE ,;
                                         mosbal    := 0                  ,;
                                         accu_osbal( mosbal,mclntcode,mrecno,mlastrec ) ,;
                                         if( mosbal >= ONE_MILLION ,;
                                              add_array( mar,mclntcode,mtotal,mosbal ),;
                                             nil ) ,;
                                         Acctmast->(dbskip(-1));
                                    }),;
                               nil;
                             );
                      },,;
                      {|| !Acctmast->(eof()) });
             )
   if len(mar) > 0
      printhead()
      printsubhead()
      asort( mar,,,{|x,y| x[1]<y[1]} )
      aeval( mar,{|x| devpos( prow()+1, 04 ), devout( dispclntname(x[1],40) ) ,; && CLIENT
                      devpos( prow()  , 54 ), devout( x[2] ) ,; && OUTSTANDING BALANCE
                      check_eject()                           ;
                  })
      @ prow()+1, 50 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
      @ prow()+1, 20 say 'Total : '
      @ prow()  , 50 say trans( mtotal,'999,999,999,999.99' )
      @ prow()+1, 50 say 'ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ'
   endif
   __eject()
return nil
******************************
static function check_eject()
******************************
   if prow() > MAXROW
      __eject() ; printhead() ; printsubhead()
   endif
return nil
******************************
static function printhead()
******************************
    memvar mtitle,mpage,gsys_name,gcompany,mmonth,mdays,myear
    eval ({|| mtitle := 'Clients with Outstanding Balance of One (1) Million and Above',prnreptitle  ( 80,0,mpage,mtitle,'Program ID:AMSR1900',gsys_name,gcompany),pagecenter   ( prow()+1,80,'As of '+fr0100month( trans(mmonth,'99') )+' '+trans(mdays,'99')+', '+trans(myear,'9999'),mpage++ )})
return nil
******************************
static function printsubhead()
******************************
   @ prow() + 2 , 04 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   @ prow() + 1 , 04 say 'Client Name                                    Outstanding Balance'
   @ prow() + 1 , 04 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
return nil
******************************
static function amsr1900open()
******************************
   local mretval := .f.
   memvar g_cis_path
   if netuse('Acctmast',.f.,5)
      set index to Acctmast,Acctclnt,Sureclnt
      set order to 2
      if netuse( '&g_cis_path'+'\Client.dbf',.f.,5)
         set index to &g_cis_path\Cliecd, &g_cis_path\Clienm
         mretval := .t.
      endif
   endif
return mretval
*                       End of the program ( Amsr1900.prg )
