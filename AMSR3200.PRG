/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   program id.........:  amsr2003.prg                                         ³
³   Description........:  Accounts without Post-Dated Checks                   ³
³   Author.............:  Ariel B. Bulan                                       ³
³   Date...............:  01:59pm 07-Jul-1995                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                         U P D A T E S                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        Who        ³     When      ³               Why                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³renan evangelista  ³08-08-96/4:00PM³ Add Oldno & Collateral                   ³
³                   ³               ³ /alter index to day(Firstdue)            ³
³ aga               ³ 14.02.2007    ³ neo paysked support for modules          ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include "Colf.ch"
#include "Inkey.ch"

#define MAXROW 55
memvar ax_level,g_user_id
if chkpass( procname(),ax_level,g_user_id )
   if amsr2003open()
      nosnow(.t.)
      amsr2003main()
      nosnow(.f.)
   endif
   eval ({|| __mrelease( "*", .t.), dbcloseall() })
endif
return
******************************
static function amsr2003main()
******************************
   *repcontrol ('amsr2003print()',,,8,33)
   xSTR := CHK_PAR(gCOMPANY)+CHK_PAR(mTRANDATE)+CHK_PAR(0)
   REPCON_OL ('AMSR2003PRINT()',,,8,33,,xSTR,.T.)
return nil
********************************
function amsr2003print()
********************************
   //setfont( 'PICA')
   //setfont( 'CONDENSED' )
   
   printhead (1)
   printsubhead ()
   accessdbf ()
   __eject()
   setfont( 'PICA' )
return nil
******************************
static function accessdbf()
******************************
   local mrecno := 0 , mlastrec := Acctmast->(lastrec()), mdue := 0 ,;
         mscr   := savescreen(,,,),npage:=1

   dispmessage()
   Acctmast->(dbsetorder(4))
   Acctmast -> ( dbgotop() )
   Acctmast -> ( dbeval ( {|| mrecno++          ,;
                              printrec( @mdue,@npage ) ,; && IF( ACCTMAST->BRCODE == g_PAR_BRCH , printrec( @mdue,@npage ), NIL ) ,;
                              dispbar ( mrecno,mlastrec,mdue ) ;
                          },,;
                          {|| !Acctmast->(eof()) } ;
                        );
               )
   restscreen( ,,,, mscr )
return nil
*************************************
static function dispmessage()
*************************************
  set device to screen
  dispbegin()
  fshadow( 10, 21, 20, 55, 2, 'w/gr')
  setpos ( 11, 22 ); dispout ( ' Account Name  ','bg+/gr' )
  setpos ( 14, 22 ); dispout ( 'Maturity Date  ','bg+/gr' )
  setpos ( 15, 22 ); dispout ( '    Principal  ','bg+/gr' )
  setpos ( 16, 22 ); dispout ( '          Due  ','bg+/gr' )
  setpos ( 17, 22 ); dispout ( '       Rental  ','bg+/gr' )
  setpos ( 18, 21 ); dispout ('ÆÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍµ','w/gr')    
  dispend()
  set device to printer
return nil
**************************************************
static function dispbar( mrecno,mlastrec,mdue )
**************************************************
   local mcol,mcolor,mper := (mrecno/mlastrec)*100
   set device to screen
   dispbegin()
   mcol := 22 + ((mrecno/mlastrec)/100) * 33 * 100
   setpos ( 11,38 ) ; dispout ( padr ( Acctmast->ACCTNAME , 17 ),'w+/gr' )
   Acctmast->(dbskip(+1))
   setpos ( 12,38 ) ; dispout ( padr ( Acctmast->ACCTNAME , 17 ),'w+/gr' )
   if !Acctmast->(eof())
      Acctmast->(dbskip(+1))
      setpos ( 13,38 ) ; dispout ( padr ( Acctmast->ACCTNAME, 17 ),'w+/gr' )
      Acctmast->(dbskip(-1))
   endif
   Acctmast->(dbskip(-1))
   setpos ( 14,38 ) ; dispout ( padr ( dtoc (Acctmast->MATDATE), 17 ),'w+/gr' )
   setpos ( 15,38 ) ; dispout ( padr ( ltrim(trans(Acctmast->PRINCIPAL,'999,999,999.99')),17),'w+/gr' )
   setpos ( 16,38 ) ; dispout ( padr ( ltrim(trans(mdue,'999')), 17),'w+/gr' )
   setpos ( 17,38 ) ; dispout ( padr ( ltrim(trans( Acctmast->AMORT,'999,999,999.99' )),17 ),'w+/gr' )
   setpos ( 19,22 ) ; dispout ( repl ( ' ',mcol-22) ,'n/w' )
   if col() >= 38
      do case
         case col() == 38
            setpos ( 19,37 ) ; dispout ( left ( ltrim(trans(mper,'999')),1)       ,'n/w'   )
            setpos ( 19,38 ) ; dispout ( right( rtrim(trans(mper,'999')),1)+ '%'  ,'w+/gr' )
         otherwise
            setpos ( 19,37 ) ; dispout ( ltrim( trans( mper, '999' ) ) + '%','n/w')
      endcase
   else
      setpos ( 19,37 ) ; dispout ( ltrim( trans( mper, '999' ) ) + '%','w+/gr')
   endif
   dispend()
   set device to printer
return nil
******************************
static function printrec(mdue,npage)
******************************
   local mc := { 0,18,45,57,73,78,84,100,132,154,165,177,187,219 }

   @ prow()+1, mc[01] say sUBSTR(Acctmast->OLDNO,1,14)     PICT '@!'  //pict '@R 9999-99999-99999'
   @ prow()  , mc[02] say Acctmast->ACCTNAME               pict '@XS25'
   @ prow()  , mc[03] say Acctmast->MATDATE                pict '@D'
   @ prow()  , mc[04] say Acctmast->PRINCIPAL              pict '999,999,999.99'
   @ prow()  , mc[05] say mdue := printdue()               pict '999'
   @ prow()  , mc[06] say Acctmast->TERM                   pict '999'
   @ prow()  , mc[07] say Acctmast->AMORT                  pict '999,999,999.99'
   @ prow()  , mc[08] say printaddress()                   pict '@XS30'
   @ prow()  , mc[09] say printcontact()                   pict '@XS20'
   @ prow()  , mc[10] say printphone()                     pict '@XS9'
   @ prow()  , mc[11] say Acctmast->REVDATE                pict '@D'
   @ prow()  , mc[12] say printrate()                      pict '@X'
   @ prow()  , mc[13] say substr(Acctmast->Colatrl,1,30)
   @ prow()  , mc[14] say Acctmast->Aocode

   if prow() >= MAXROW
      npage ++
      fejectpause()
      printhead(npage)
      printsubhead()
   endif
return nil
******************************
static function printdue()
******************************
   memvar mtrandate
   local mdue := 1

//aga.02.05.2006.marked for modification

dbselectarea('Paysked')
paysked->(dbsetorder(1))

   Paysked->(dbseek(ACCTMAST->BRCODE+Acctmast->ACCTNO+'D'))
   Paysked->(dbeval({|| if (Paysked->PAYDATE < mtrandate, mdue++, nil) },,;
                    {|| PAYSKED->BRCODE+Paysked->ACCTNO == ACCTMAST->BRCODE+Acctmast->ACCTNO .and. Paysked->status == 'D' .and. !Paysked->(eof()) };
                   );
            )
dbselectarea('Acctmast')
Acctmast->(dbsetorder(4))

//......................................

return mdue
********************************
static function printcontact()
********************************
return Client->(dbseek(Acctmast->BRCODE+Acctmast->CLNTCODE)), Client->COLLECT
******************************
static function printaddress()
******************************
return Client->(dbseek(Acctmast->BRCODE+Acctmast->CLNTCODE)), Client->ADDRESS1
******************************
static function printphone()
******************************
return Client->(dbseek(Acctmast->BRCODE+Acctmast->CLNTCODE)), Client->TELNO1
******************************
static function printrate()
******************************
return if( alltrim(Acctmast->RATETYPE) == '1','Fixed','Floating' )
******************************
static function printhead(pgn)
******************************
   memvar gcompany
   setprc ( 0,0 )
   @ PROW()+1,00 SAY ''
   setfont('DRAFT')
   setfont( 'PICA')
   setfont( 'CONDENSED' )
   @ prow()+1,01 say 'ACCOUNT MANAGEMENT SYSTEM'
   @ prow(),  01+len('ACCOUNT MANAGEMENT SYSTEM');
              say PADL('Page No. ' + tran(pgn,'999'),225-len('ACCOUNT MANAGEMENT SYSTEM'))
   @ prow()+1,01 say 'AMSR2003'
   @ prow()  ,01+len('AMSQ9999');
              say PADL( dtoc(DATE())+' '+TIME(), 225-len('AMSQ1000'))

   pagecenter( prow()+1,225, gcompany )
   pagecenter( prow()+1,225, 'Accounts without Post-Dated Checks' )
   pagecenter( prow()+1,225, 'As of '+printdate() ) 
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
   @ prow()+2, 00 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄ  ÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄ'
   @ prow()+1, 00 say '     Account              Account             Maturity     Principal     Due  Term     Rental                  Address                Contact Person      Telephone    Review      Rate             Collateral             Account'
   @ prow()+1, 00 say '     Number                Name                 Date        Amount                                                                                           No.        Date       Type                                    Officer'
   @ prow()+1, 00 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄ  ÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄ'
return nil
******************************
static function amsr2003open()
******************************
   local mretval := .f.
   memvar g_cis_path
   if netuse('&g_AMS_PATH\Acctmast',.f.,5)
      set index to &g_AMS_PATH\Acctmast,;
                   &g_AMS_PATH\Acctclnt,;
                   &g_AMS_PATH\Sureclnt,;
                   &g_AMS_PATH\Acctday
      Acctmast->( dbsetorder(1) )
      if netuse( '&g_cis_path'+'\Client.dbf',.f.,5)
         set index to &g_cis_path\Cliecd, &g_cis_path\Clienm
         if netuse( '&g_cis_path'+'\Industry.dbf',.f.,5)
            set index to &g_CIS_PATH\Industry
            if netuse( '&g_AMS_PATH\Paysked',.f.,5 )
               set index to &g_AMS_PATH\Paystat               //aga.27.06.2006.new index
               mretval := .t.
            endif
         endif
      endif
   endif
return mretval
*                     End of the program ( Amsr2003.prg )
