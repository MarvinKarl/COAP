/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   Program ID.........:  AMSR0300.prg                                         ³
³   Description........:  top clients                                          ³
³   Author.............:  Ariel B. Bulan                                       ³
³   Date...............:  01:53pm 21-Apr-1995                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                         U P D A T E S                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        Who        ³     When      ³               Why                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Janet L. Bautista ³  18-Jun-1998  ³ include past due & items                 ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include "Colf.ch"
#include "Inkey.ch"

#define MAXROW 53
#xtrans getlastrec(<(mlastrec)>) => Acctmast->( dbeval({|| if( (Acctmast->STATUS=='1'.or. Acctmast->STATUS=='2' .or. Acctmast->STATUS=='3'),<mlastrec>++, nil )},,{||!Acctmast->(eof())}) )
// #xtrans getlastrec(<(mlastrec)>) => Acctmast->( dbeval({|| if( (Acctmast->STATUS=='1'),<mlastrec>++, nil )},,{||!Acctmast->(eof())}) )
memvar ax_level,g_user_id
if chkpass( procname(),ax_level,g_user_id )
   if amsr2000open()
      nosnow(.t.)
      amsr2000main()
      nosnow(.f.)
   endif
   eval ({|| __mrelease( "*", .t.), dbcloseall() })
endif
return
******************************
static function amsr2000main()
******************************
   memvar  gtrandate
   local   mdbf   := savedbf (mdbf), mcolor := setcolor(), mcursor := setcursor()
   private mlimit := 0

   dbselectarea ( "Acctmast" )
   if getlimit()
      reportprint('amsr2000print()',,,8,33)
      *repcon_ol ('amsr2000print()',,,8,33,,,.F.)
      restdbf    (mdbf)
      setcolor   (mcolor)
      setcursor  (mcursor)
   endif
return nil
*******************************
static function getlimit()
*******************************
   memvar mlimit
   local getlist := {}, mcolor := setcolor()

   fshadow( 10, 30, 12, 45, 2, 'gr+/g' )
   setcolor( 'w/g, w+/n,,, w+/g' )
   @ 11, 31 say 'Limit ' get mlimit pict '99,999' valid mlimit > 0
   setcursor( 3 )   
   read
   setcursor( 0 )
   setcolor( mcolor )
return lastkey() != K_ESC
*******************************
function amsr2000print()
*******************************
   local mscr := savescreen(,,,)
   memvar gtrandate
   private mpage := 1,mmonth,mdays,myear,mtitle
   mmonth := month ( FLAG->PREVDATE )
   mdays  := day   ( FLAG->PREVDATE )
   myear  := year  ( FLAG->PREVDATE )
   setprc     (0,0)
   setfont    ( upper('condensed') )
   printrec   ()
   restscreen (,,,,mscr)
return nil
******************************
static function printrec()
******************************
   memvar mlimit
   local  mar := {}, mclntcode, mindcode
   local  mosbal   , mnoaccts , mrecno := 0 , mgtotal := 0, mlastrec := 0

   Acctmast-> ( dbgotop() )
   getlastrec ( mlastrec  )
   Acctmast-> ( dbgotop() )

   disp_message ()

   Acctmast->( dbeval( {|| if ( Acctmast->STATUS=='1' .or. Acctmast->STATUS=='2' .or. Acctmast->STATUS=='3',;
                                eval ({|| mclntcode := Acctmast->CLNTCODE ,;
                                          mindcode  := getindustry()      ,;
                                          mosbal    := mnoaccts  := 0     ,;
                                          Acctmast->( dbeval( {||  if (  ( Acctmast->STATUS == '1' .or. ;
                                                                           Acctmast->STATUS == '2' .or. ;
                                                                           Acctmast->STATUS == '3'      ;
                                                                         ) .and. ;
                                                                         Acctmast->OSBAL <> 0,;
                                                                         eval ({|| mnoaccts ++ ,;
                                                                                   mrecno   ++ ,;
                                                                                   mosbal   += Acctmast->OSBAL,;
                                                                                   mgtotal  += Acctmast->OSBAL,;
                                                                                   disp_bar ( mrecno,mlastrec,mclntcode,mindcode,mnoaccts,mosbal );
                                                                              }),;
                                                                    nil ) ;
                                                               },,;
                                                               {|| !Acctmast->(eof()) .and. ;
                                                                    Acctmast->CLNTCODE == mclntcode ;
                                                               };
                                                             );
                                                     ),;
                                          Acctmast->( dbskip(-1) ),;
                                          aadd( mar,{ dispclntname(mclntcode,40) ,;
                                                       mindcode                ,;
                                                       dispindustry(mindcode ) ,;
                                                       mnoaccts                ,;
                                                       mosbal  ;
                                                     };
                                               );
                                           }),;
                              nil );
                       },,;
                       {|| !Acctmast->(eof()) };
                     );
             )
   traverse_array( mar,mgtotal )
return nil

********************************************************************************
*
static function disp_bar( mrecno,mlastrec,mclntcode,mindcode,mnoaccts,mbalance )
********************************************************************************
   local mcol,mcolor,mper := (mrecno/mlastrec)*100
   set device to screen
   dispbegin()
   mcol := 22 + ((mrecno/mlastrec)/100) * 33 * 100
   setpos ( 14,35 ); dispout ( left ( dispclntname(mclntcode,40),20),'w+/gr' )
   setpos ( 15,35 ); dispout ( left ( dispindustry(mindcode ),20),'w+/gr' )
   setpos ( 16,35 ); dispout ( padr ( ltrim(trans(mnoaccts,'9,999')),20),'w+/gr' )
   setpos ( 17,35 ); dispout ( padr ( ltrim(trans(mbalance,'999,999,999.99')),20),'w+/gr' )
   setpos ( 19,22 ); dispout ( repl ( ' ',mcol-22) ,'n/w' )
   if col() >= 38
      do case
         case col() == 38
            setpos ( 19,37 ); dispout ( left ( ltrim(trans(mper,'999')),1)       ,'n/w'   )
            setpos ( 19,38 ); dispout ( right( rtrim(trans(mper,'999')),1)+ '%'  ,'w+/gr' )
         otherwise
            setpos ( 19,37 ); dispout ( ltrim( trans( mper, '999' ) ) + '%','n/w')
      endcase
   else
      setpos ( 19,37 ); dispout ( ltrim( trans( mper, '999' ) ) + '%','w+/gr')
   endif
   dispend()
   set device to printer
return nil

*************************************
*
static function disp_message( mmess )
*************************************
  set device to screen
  dispbegin()
  fshadow( 13, 21, 20, 55, 2, 'w/gr' )
  setpos ( 14, 22 ); dispout ( '    Client  ', 'bg+/gr' )
  setpos ( 15, 22 ); dispout ( '  Industry  ', 'bg+/gr' )
  setpos ( 16, 22 ); dispout ( '# of Accts  ', 'bg+/gr' )
  setpos ( 17, 22 ); dispout ( '   Balance  ', 'bg+/gr' )
  setpos ( 18, 21 ); dispout ('ÆÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍµ','w/gr')
  dispend()
  set device to printer
return nil
**********************************************
static function traverse_array ( mar,mgtotal )
**********************************************
   local  mtnoaccts := 0, mtosbal := 0
   memvar mlimit

   eval ({|| asort( mar,,,{|x,y| x[5]>y[5] } ) ,;
             if( len(mar)>mlimit,asize(mar,mlimit),nil ) ,;
             printhead()                       ,;
             printsubhead()                    ,;
             aeval ( mar, {|x| if ( x[1] != nil ,;
                                    disp_rec( x[1],x[2],x[3],x[4],x[5],@mtnoaccts,@mtosbal);
                                    ,nil ) } ), printfooter(mtnoaccts,mtosbal,mgtotal), __eject()})
return nil
***********************************************************************************************
static function disp_rec( mclntname,mindcode,mindname,mnoaccts,mosbal,mtnoaccts,mtosbal)
***********************************************************************************************
   local mcol := { 4,49,96,104}
   eval ({|| devpos ( prow()+1, mcol[1]  ), devout ( mclntname ) ,;
             devpos ( prow()  , mcol[2]  ), devout ( mindcode  ) ,;
             devpos ( prow()  , pcol()+1 ), devout ( mindname  ) ,;
             devpos ( prow()  , mcol[3]  ), devout ( trans(mnoaccts,'9,999') ) ,;
             devpos ( prow()  , mcol[4]  ), devout ( trans(mosbal,'999,999,999,999.99') ) ,;
             mtnoaccts += mnoaccts ,;
             mtosbal   += mosbal   ,;
             check_eject( MAXROW )})
return nil
**********************************************************
static function printfooter(mtnoaccts,mtosbal,mgtotal)
**********************************************************
   memvar mlimit
   check_eject( 45 )

   @ prow() + 1, 096 say 'ÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   @ prow() + 1, 040 say 'TOTAL : '
   @ prow()    , 095 say trans( mtnoaccts,'99,999' )
   @ prow()    , 104 say trans( mtosbal,'999,999,999,999.99' )
   @ prow() + 1, 096 say 'ÍÍÍÍÍÍ  ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ'
   @ prow() + 2, 040 say 'CURRENT LEASE CONTRACTS RECEIVABLES'
   @ prow() + 1, 040 say 'AND FINANCE RECEIVABLES'
   @ prow()    , 104 say trans( mgtotal,'999,999,999,999.99' )
   @ prow() + 1, 096 say '        ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ'
   @ prow() + 2, 040 say '% OF TOTAL RECEIVABLES FROM TOP '+ltrim(trans(mlimit,'99,999'))+' CLIENTS'
   @ prow() + 1, 040 say 'AND FINANCE RECEIVABLES'
   @ prow() + 1, 096 say (mtosbal/mgtotal)*100 pict '999.99 %'
   @ prow() + 1, 096 say 'ÍÍÍÍÍÍÍÍ'
return nil
******************************
static function getindustry()
******************************
return  eval ({|x,y| x := savedbf(x), Client->(dbseek(Acctmast->CLNTCODE)),;
                y := Client->INDCODE, restdbf(x), y })
********************************************
static function check_eject(mmaxrow)
********************************************
   if prow() > mmaxrow
      __eject() ; printhead() ; printsubhead()
   endif
return nil
**********************************
static function printhead()
**********************************
    memvar mtitle,mpage,gsys_name,gcompany,mmonth,mdays,myear,mlimit
    setfont( upper("normal") )
    eval ({|| mtitle := 'TOP '+ltrim(trans(mlimit,'99,999'))+' CLIENTS',prnreptitle  ( 80,0,mpage,mtitle,'Program ID:AMSR2000',gsys_name,gcompany),pagecenter   ( prow()+1,80,'As of '+fr0100month( trans(mmonth,'99') )+' '+trans(mdays,'99')+', '+trans(myear,'9999'),mpage++ )})
    setfont( upper("condensed") )
return nil
******************************
static function printsubhead()
******************************
   @ prow() + 2 , 04 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   @ prow() + 1 , 04 say 'Client Name                                  Industry                                       No. of     Outstanding'
   @ prow() + 1 , 04 say '                                                                                            Accts.       Balance  '
   @ prow() + 1 , 04 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
return nil
/*
*****************************************
static function dispindustry(mindcode)
*****************************************
return eval ({|x,y| x := savedbf( x ), Industry->(dbseek( mindcode )),;
                    y:=Industry->INDNAME, restdbf( x ), y })
*/
******************************
static function amsr2000open()
******************************
   local mretval := .f.
   memvar g_cis_path
   if netuse('Acctmast',.f.,5)
      set index to Acctmast,Acctclnt,Sureclnt
      set order to 2
      if netuse( '&g_cis_path'+'\Client.dbf',.f.,5)
         set index to &g_cis_path\Cliecd, &g_cis_path\Clienm
         if netuse( '&g_cis_path'+'\Industry.dbf',.f.,5)
            set index to &g_CIS_PATH\Industry
            if netuse('FLAG',.f.,5)
               mretval := .t.
            endif
         endif
      endif
   endif
   return mretval
*                         End of the program ( Amsr2000.prg )
