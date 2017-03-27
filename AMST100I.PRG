/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   program ID.........:  amst100i.prg                                         ³
³   description........:  accounts execution printing                          ³
³   author.............:  Ariel B. Bulan                                       ³
³   date...............:  10:35am 03-Jan-1995                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                         U P D A T E S                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        Who        ³     When      ³               Why                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Myrna M. Espolon  ³  25-Apr-1996  ³ Include Menu Option on what to           ³
³                   ³               ³ PRINT( e.g. Collateral Info ,            ³
³                   ³               ³             Documents Checklist          ³
³ Janet L. Bautista ³  10-Sep-1997  ³ gd, rv to 5 decimal places               ³
³ ABB               ³  10.22.2004   ³ FOR ONLINE                               ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include "Colf.ch"
#include "Inkey.ch"
#define MAXROW 52
*********************************************************
function print_availment( m_acctno, xDBF )
*********************************************************
    local   mscr := savescreen (,,,), mcolor := setcolor()
    private mpreparedby, mcheckedby , mnotedby
    private mpcode     , mccode     , mncode
    private macctno    , mPRN := ' ', sDBF := xDBF
    mpreparedby := mcheckedby := mnotedby := space( 40 )
    mpcode      := mccode     := mncode   := space( 05 )
    macctno     := m_acctno

	if sDBF == 'ACCTMAST'
		mPRN := '3'
	endif	
	
    if ( if(sDBF == 'ACCTDALY',prav_menu(@mPRN),.t.),;
         eval ( {|| get_names(),;
                    reportprint('startprinting()',,,8,33) ;  &&repcontrol('startprinting()',,,8,33) ;
                };
              ),;
         nil ;
       )
    setcolor( mcolor ) ; restscreen ( ,,,, mscr )
return nil

//aga.04.05.2005.new and improved get_names()...yay!
*******************************
static function get_names()
*******************************
memvar mpreparedby , mcheckedby, mnotedby
local  getlist := {}, ax := setcolor()
private entryname [3]
entryname [1] := entryname [2] := entryname [3] := space(40)

fshadow ( 6, 29, 10, 69, 2, 'n/w')
setcolor( 'bg+/w, w+/n,,, gr+/w' ) 

@ 7, 30 say 'Prepared by ' gget entryname[1] picture '@xs25'            ;
         when lastkey() != K_ESC valid !empty( mpreparedby := get_initial(entryname[1], 1, 6, 44, 25 ) )
@ 8, 30 say ' Checked by ' gget entryname[2] picture '@xS25'            ;
         when lastkey() != K_ESC valid !empty( mcheckedby  := get_initial(entryname[2], 2, 6, 44, 25 ) )
@ 9, 30 say '   Noted by ' gget entryname[3] picture '@xS25'            ;
         when lastkey() != K_ESC valid !empty( mnotedby := get_initial(entryname[3], 3, 6, 44, 25 ) )

setcursor ( 3 )
read   
setcursor ( 0 )
setcolor  ( ax )

return( lastkey()!=K_ESC )
//.........................................


//*********************************************
//static function get_names()
//*********************************************
//    memvar mpreparedby , mcheckedby, mnotedby
//    memvar mpcode      , mccode    , mncode
//    local  getlist := {}
//
//    fshadow ( 6, 29, 10, 69, 2, 'n/w')
//    setcolor( 'bg+/w, w+/n,,, gr+/w' ) 
//    @ 7, 30 say 'Prepared by ' get mpreparedby pict '@XS25' when look_at_them( @mpcode, @mpreparedby, '® Prepared by ¯' )
//    @ 8, 30 say ' Checked by ' get mcheckedby  pict '@XS25' when look_at_them( @mccode, @mcheckedby , '® Checked by ¯'  )
//    @ 9, 30 say '   Noted by ' get mnotedby    pict '@XS25' when look_at_them( @mncode, @mnotedby   , '® Noted by ¯'    )
//    setcursor( 3 )
//    read
//    setcursor( 0 )
//return ( lastkey()!=K_ESC )

***************************
static function prav_menu(mPRN)
***************************
local mSCR := savescreen(,,,),  mCOLOR := setcolor(), mSCR2
local mLOG := .t., mCH := 1, menulist

******** alert ( "amst100i" )

eval( { || fShadow( 17, 41, 21-(if(sDBF == 'ACCTMAST',2,0)), 63, 2, 'n/+w' ) } )
setcolor( 'n/bg, gr+/n,,, w+/bg' )

while mLOG

      @ 17+1, 42 prompt ' ~Account Execution   '  message '' ;
              messagecolor 'w+/n' triggercolor 'w+/bg'
      @ 18+1, 42 prompt ' ~Collateral Info     ' message '' ;
               messagecolor 'w+/n' triggercolor 'w+/bg'
      @ 19+1, 42 prompt ' ~Documents Checklist ' message '' ;
               messagecolor 'w+/n' triggercolor 'w+/bg'
	
      menu to mCH initial mCH timeout 20

      mSCR2 := savescreen( ,,, )
      setcolor(NRM)
      do case
         case mCH == 0
              mLOG := !.t.
              mretval := .f.
         case mCH == 1
              mPRN := '3'
         case mCH == 2
              mPRN := '1'
         case mCH == 3
              mPRN := '2'
      endcase
      setcolor( 'n/bg, gr+/n,,, w+/bg' )
      restscreen( ,,,, mSCR2 )
      exit
enddo      

setcolor( mCOLOR )
restscreen( ,,,, mSCR )
return(mLog)

//***************************************************
//static function look_at_them( mcode, mname, mmess )
//***************************************************
//   if lastkey() != K_ESC
//      center  ( 24, 'w+/n', mmess )
//      lb_lkup ( 'Personel' ,1,1, @mcode, 2, 1, 10, 4, 20, 64, 'w/gr+,w/n,,,w/gr+' )      
//      mname := Personel->FULLNAME
//      @ 24, 00 say repl (' ',78) color 'w+/n'
//   endif
//return .f.

*******************************************
*
function startprinting()
*******************************************
memvar mPRN
private mpage     := 1

    &&& print_head        ()
    &&& print_subhead     ()
    &&& print_facility    ()
    &&& print_names       ()
    &&& print_cash_outlay ()   // amst100k.prg
    do case
       case mPRN == '1'    &&& Print Collateral Info
            print_collateral  ()     // amst100j.prg
       case mPRN == '2'
            doc_list          ()     // amst100l.prg
       case mPRN == '3'
            print_booking(,sDBF)  // amst100o.prg
            ********* repcontrol('print_booking()',,,8,33)

    endcase
    //__eject()

return nil                                  
*******************************************
*
static function print_names    ()
*******************************************
    memvar mpreparedby, mcheckedby, mnotedby
    local  ml := 00, mc := 27, mr := 54
    while prow() < 51
      @ prow()+1,0 say ''
    enddo
    @ prow()+2, 00 say repl( chr(196), 80 )
    @ prow()+1, ml say 'Prepared by :'
    @ prow()  , mc say 'Checked by  :'
    @ prow()  , mr say 'Noted by    :'
    @ prow()+2, ml say repl( 'Ä', 25 )
    @ prow()  , mc say repl( 'Ä', 25 )
    @ prow()  , mr say repl( 'Ä', 25 )
    @ prow()+1, ml say left( mpreparedby, 25 )
    @ prow()  , mc say left( mcheckedby , 25 )
    @ prow()  , mr say left( mnotedby   , 25 )
return nil
*******************************************
*
static function print_subhead( mwhat )
*******************************************
    memvar gcompany, gsys_name, gheadmess, mpage, mtrandate
    local mleft := 53
    setprc( 0,0 )
    mwhat := if ( mwhat == nil, .t., mwhat )

    @ prow()+1 , 000         say 'Page : '
    @ prow()   , pcol()      say mpage pict '9,999'
    @ prow()+1, 000          say replicate( chr(196),80 )
    @ prow()+1, 000          say 'Account Number : '
    @ prow()  , pcol()       say ACCTDALY->BRCODE+Acctdaly->ACCTNO pict '@R 999-9999-99999-99999'
    @ prow()  , mleft        say 'Execution Date : '
    @ prow()  , pcol()       say dtoc( Acctdaly->VALDATE )
    @ prow()+1, 000          say 'Client Number  : '
    @ prow()  , pcol()       say ACCTDALY->BRCODE+Acctdaly->CLNTCODE pict '@R 999-99-99999'

    if mwhat
        @ prow()  , mleft    say 'Document Reference : '
        @ prow()  , pcol()   say Acctdaly->DOCREF
        @ prow()+1, 000      say 'Client Name    : '
    else
        @ prow()  , pcol()+1 say ' '
    endif

    @ prow()  , pcol()+2       say upper ( DISPCLNTNAME( ACCTDALY->BRCODE+ACCTDALY->CLNTCODE, 50 ) )     &&RED 121305 _dispclntname( Acctdaly->brcode,Acctdaly->CLNTCODE )

    if mwhat
        @ prow()+1, 000      say 'Address        : '
        @ prow()  , 017      say Client->ADDRESS1
        @ prow()+1, 017      say Client->ADDRESS2
        @ prow()+1, 017      say Client->ADDRESS3
        @ prow()+1, 000      say 'AO In-Charge   : '
        @ prow()  , pcol()   say Acctdaly->AOCODE
        @ prow()  , pcol()+2 say dispaoname( Acctdaly->AOCODE )
    endif
    @ prow()+1, 000          say replicate( chr(196),80 )
    mpage++
return nil
/****************************************/
Static Function PgeTitle(xrow,xSize,xText)
/****************************************/
setfont('BOLD')
@ xrow, 1 say padc(xText,xSize)
setfont('UNBOLD')
return nil
*******************************************
*
static function print_head( mwhat )
*******************************************
   memvar gcompany, gsys_name, gheadmess, mpage, mtrandate
   local  mtitle  :=  'Availment Sheet'
   if mwhat == nil
      prnreptitle( 80,00,mpage,mtitle,'Program ID : Amst100i',gsys_name,gcompany)
   else
      @ prow()+1 , 000    say 'Page : '
      @ prow()   , pcol() say mpage pict '9,999'
      setfont('BOLD')
      @ prow()+1 , 32     say 'AVAILMENT SHEET'
      setfont('UNBOLD')
   endif
   @ prow()+1    , 30     say 'As of '+ cmonth(mtrandate)+' '+str(day(mtrandate),2)+', '+str(year(mtrandate),4)
   mpage++
return nil
*****************************************
*
static function print_facility()
*****************************************
   local mpayfreqchoices := { '1 = Monthly    ','2 = Bi-monthly ','3 = Quarterly  ','4 = Semi-annual','5 = Annual     ','6 = Lumpsum    ','7 = Irregular  ' }
   local msetcode, mleft := 6
   @ prow()+2, 00 say Acctdaly->FCLTYCODE + ' ' + dispfcltyname( Acctdaly->FCLTYCODE )
   msetcode := Facility->SETCODE
   do case
      case msetcode == '1'
           @ prow()+1, mleft say 'Items for Lease       : ' + Acctdaly->UNIT
           @ prow()+1, mleft say 'Dealer                : ' + Acctdaly->DLRCODE
           @ prow()+1, mleft say 'PO Number             : ' + trans( Acctdaly->PONUM  ,'99999999' )
           @ prow()+1, mleft say 'Purchase Amount       : ' + trans( Acctdaly->PURCAMT,'999,999,999.99' )
           @ prow()+1, mleft say 'Unit Location         : ' + Acctdaly->UNITLOCA
           @ prow()+1, mleft say 'Net Book Value        : ' + trans( Acctdaly->PRINCIPAL, '999,999,999.99' )
           @ prow()+1, mleft say 'Payment Type          : ' + Acctdaly->PAYTYPE + ' '+ if( Acctdaly->PAYTYPE $ '12', if( Acctdaly->PAYTYPE == '1', 'In advance', 'In arrears' ), ' ')
           @ prow()+1, mleft say 'Guaranty Deposit      : ' + trans( Acctdaly->GD, '99.999999%' )
           @ prow()+1, mleft say 'Residual Value        : ' + trans( Acctdaly->RV, '99.999999%' )
           @ prow()+1, mleft say 'Term                  : ' + trans( Acctdaly->TERM, '999' ) + ' Month(s)'
           @ prow()+1, mleft say 'Effective Rate        : ' + trans( Acctdaly->TRUERATE,'99.9999') + ' ' +if( Acctdaly->RATETYPE $ '12', if( Acctdaly->RATETYPE == '1', 'Fixed   ', 'Floating' ), ' ')
           @ prow()+1, mleft say 'First Due Date        : ' + dtoc ( Acctdaly->FIRSTDUE )
           @ prow()+1, mleft say 'Payment Frequency     : ' + Acctdaly->PAYFREQ + ' ' +  if ( !empty( Acctdaly->PAYFREQ ), substr ( mpayfreqchoices [ val(Acctdaly->PAYFREQ) ], 5, 11 ), '  ' )
           @ prow()+1, mleft say 'Maturity Date         : ' + dtoc ( Acctdaly->MATDATE )
           @ prow()+1, mleft say 'Monthly Rental Factor : ' + trans( Acctdaly->FACTOR  , '99.999999'      )
           @ prow()+1, mleft say 'Rental                : ' + trans( Acctdaly->AMORT   , '999,999,999.99' )
           @ prow()+1, mleft say 'Total Receivables     : ' + trans( Acctdaly->CREDAMT , '999,999,999.99' )
           @ prow()+1, mleft say 'ALIR Amount           : ' + trans( Acctdaly->ALIR    , '999,999,999.99' )
      case msetcode == '2'
           @ prow()+1, mleft say 'Collateral/s          : ' + Acctdaly->UNIT
           @ prow()+1, mleft say 'Net Proceeds          : ' + trans( Acctdaly->PRINCIPAL ,'999,999,999.99' )
		   @ prow()+1, mleft say 'D.I. / S.I.           : ' + trans( Acctdaly->INCENTIVE ,'999,999,999.99' )
		   @ prow()+1, mleft say 'Withholding Tax       : ' + trans( Acctdaly->WTAX ,'999,999,999.99' )
           @ prow()+1, mleft say 'Payment Type          : ' + Acctdaly->PAYTYPE + ' '+ if( Acctdaly->PAYTYPE $ '12', if( Acctdaly->PAYTYPE == '1', 'In advance', 'In arrears' ), ' ')
           @ prow()+1, mleft say 'Term                  : ' + trans( Acctdaly->TERM, '999' ) + ' Month(s)'
           @ prow()+1, mleft say 'Gross Effective Rate  : ' + trans( Acctdaly->TRUERATE,'99.9999') + ' ' +if( Acctdaly->RATETYPE $ '12', if( Acctdaly->RATETYPE == '1', 'Fixed   ', 'Floating' ), ' ')
		   @ prow()+1, mleft say 'Net Effective Rate    : ' + trans( Acctdaly->NERATE,'99.9999%')
           @ prow()+1, mleft say 'First Due Date        : ' + dtoc ( Acctdaly->FIRSTDUE )
           @ prow()+1, mleft say 'Payment Frequency     : ' + Acctdaly->PAYFREQ + ' ' +  if ( !empty( Acctdaly->PAYFREQ ), substr ( mpayfreqchoices [ val(Acctdaly->PAYFREQ) ], 5, 11 ), '  ' )
           @ prow()+1, mleft say 'Add-On Rate           : ' + trans( Acctdaly->ADDON  , '99.9999'        )
           @ prow()+1, mleft say 'Amortization          : ' + trans( Acctdaly->AMORT  , '999,999,999.99' )
           @ prow()+1, mleft say 'Credit Amount         : ' + trans( Acctdaly->CREDAMT, '999,999,999.99' )
		   if Acctdaly->UDIAMT > 0
		      @ prow()+1, mleft say 'UDI Amount            : ' + trans( Acctdaly->UDIAMT , '999,999,999.99' )
		   else
              @ prow()+1, mleft say 'UDI Amount            : ' + trans( Acctdaly->UDI    , '999,999,999.99' )
		   endif
           @ prow()+1, mleft say 'Maturity Date         : ' + dtoc ( Acctdaly->MATDATE )
		   
      case msetcode == '3'
           @ prow()+1, mleft say 'Unit                  : ' + Acctdaly->UNIT
           @ prow()+1, mleft say 'Dealer                : ' + Acctdaly->DLRCODE + ' ' + disp_dealer ( Acctdaly->DLRCODE )
           @ prow()+1, mleft say 'Sales Representative  : ' + Acctdaly->SALESREP
           @ prow()+1, mleft say 'Purchase Amount       : ' + trans( Acctdaly->PURCAMT   , '999,999,999.99' )
           @ prow()+1, mleft say 'Down Payment          : ' + trans( Acctdaly->DOWNPAY   , '999,999,999.99' )
//           @ prow()+1, mleft say "Dealer's Incentive    : " + trans( Acctdaly->INCENTIVE , '999,999,999.99' )
           @ prow()+1, mleft say "D.I. / S.I.           : " + trans( Acctdaly->INCENTIVE , '999,999,999.99' )
		   @ prow()+1, mleft say "Withholding Tax       : " + trans( Acctdaly->WTAX , '999,999,999.99' )
           @ prow()+1, mleft say 'Net Proceeds          : ' + trans( Acctdaly->PRINCIPAL , '999,999,999.99' )
           @ prow()+1, mleft say 'Payment Type          : ' + Acctdaly->PAYTYPE + ' '+ if( Acctdaly->PAYTYPE $ '12', if( Acctdaly->PAYTYPE == '1', 'In advance', 'In arrears' ), ' ')
           @ prow()+1, mleft say 'Term                  : ' + trans( Acctdaly->TERM , '999' ) + ' Month(s)'
           @ prow()+1, mleft say 'Gross Effective Rate  : ' + trans( Acctdaly->TRUERATE  , '99.9999') + ' ' +if( Acctdaly->RATETYPE $ '12', if( Acctdaly->RATETYPE == '1', 'Fixed   ', 'Floating' ), ' ')
		   @ prow()+1, mleft say 'Net Effective Rate    : ' + trans( Acctdaly->NERATE,'99.9999%')
           @ prow()+1, mleft say 'First Due Date        : ' + dtoc ( Acctdaly->FIRSTDUE )
           @ prow()+1, mleft say 'Payment Frequency     : ' + Acctdaly->PAYFREQ + ' ' +  if ( !empty( Acctdaly->PAYFREQ ), substr ( mpayfreqchoices [ val(Acctdaly->PAYFREQ) ], 5, 11 ), '  ' )
           @ prow()+1, mleft say 'Amortization          : ' + trans( Acctdaly->AMORT     , '999,999,999.99' )
           @ prow()+1, mleft say 'Credit Amount         : ' + trans( Acctdaly->CREDAMT   , '999,999,999.99' )
		   if Acctdaly->UDIAMT > 0
		      @ prow()+1, mleft say 'UDI Amount            : ' + trans( Acctdaly->UDIAMT , '999,999,999.99' )
		   else
              @ prow()+1, mleft say 'UDI Amount            : ' + trans( Acctdaly->UDI    , '999,999,999.99' )
		   endif
           @ prow()+1, mleft say 'Maturity Date         : ' + dtoc ( Acctdaly->MATDATE )
		   
      case msetcode == '4' .or. msetcode == '5'
           @ prow()+1, mleft say 'Transaction Type      : ' + Acctdaly->TRANTYPE  + ' ' + if( Acctdaly->TRANTYPE == '1', 'Revolving', 'Special  ' )
           @ prow()+1, mleft say 'Net Proceeds          : ' + trans( Acctdaly->PRINCIPAL, '999,999,999.99' )
           @ prow()+1, mleft say 'Payment Type          : ' + Acctdaly->PAYTYPE + ' '+ if( Acctdaly->PAYTYPE $ '12', if( Acctdaly->PAYTYPE == '1', 'In advance', 'In arrears' ), ' ')
           @ prow()+1, mleft say 'Term                  : ' + trans( Acctdaly->TERM, '999' ) + if( Acctdaly->TERMUNIT == '1', ' Days',' Month(s)' )
           @ prow()+1, mleft say 'Effective Rate        : ' + trans( Acctdaly->TRUERATE,'99.9999') + ' ' +if( Acctdaly->RATETYPE $ '12', if( Acctdaly->RATETYPE == '1', 'Fixed   ', 'Floating' ), ' ')
           @ prow()+1, mleft say 'Notification          : ' + Acctdaly->NOTFCTN   + ' ' + ( Acctdaly->NOTFCTN  $ '12', if( Acctdaly->NOTFCTN  == '1', 'With   '   , 'Without'    ), ' ' )
           @ prow()+1, mleft say 'Collection            : ' + Acctdaly->COLEXION  + ' ' + ( Acctdaly->COLEXION $ '12', if( Acctdaly->COLEXION == '1', 'Ours  '    , 'Theirs'     ), ' ' )
           @ prow()+1, mleft say 'Recourse              : ' + Acctdaly->RECOURSE  + ' ' + ( Acctdaly->RECOURSE $ '12', if( Acctdaly->RECOURSE == '1', 'With   '   , 'Without'    ), ' ' )
           @ prow()+1, mleft say 'Obligor               : ' + Acctdaly->OBLIGOR
           @ prow()+1, mleft say 'Collateral            : ' + Acctdaly->COLATRL
           @ prow()+1, mleft say 'First Due Date        : ' + dtoc( Acctdaly->FIRSTDUE )
           @ prow()+1, mleft say 'Payment Frequency     : ' + Acctdaly->PAYFREQ + ' ' +  if ( !empty( Acctdaly->PAYFREQ ), substr ( mpayfreqchoices [ val(Acctdaly->PAYFREQ) ], 5, 11 ), '  ' )
           @ prow()+1, mleft say 'Amortization          : ' + trans( Acctdaly->AMORT   , '999,999,999.99' )
           @ prow()+1, mleft say 'Credit Amount         : ' + trans( Acctdaly->CREDAMT , '999,999,999.99' )
           @ prow()+1, mleft say 'UDI Amount            : ' + trans( Acctdaly->UDI     , '999,999,999.99' )
           @ prow()+1, mleft say 'Maturity Date         : ' + dtoc ( Acctdaly->MATDATE )
   endcase
return nil
*******************************************
*
static function print_collateral ()
*******************************************
//    if Ctrlinfo->( dbseek( Acctdaly->ACCTNO ) )

    if Ctrlinfo->( dbseek( Acctdaly->brcode+Acctdaly->ACCTNO ) )  // 10.22.2004
       //__eject()
       Ctrlinfo->( dbeval( {|| print_subhead(.f.),;
                               pgeTitle( prow()+1, 80,'COLLATERAL INFORMATION' ),print_colrec(),print_names(),__eject() } ,, ;
                           {|| !Ctrlinfo->(eof()) .and. ;
                                Ctrlinfo->ACCTNO==Acctdaly->ACCTNO .and. Ctrlinfo->brcode == Acctdaly->brcode;
                           };
                         );
                 )
    endif
return nil
************************************
*
static function print_cash_outlay()
************************************
//    if Cashout->( dbseek( Acctdaly->ACCTNO ) )
   if Cashout->( dbseek( Acctdaly->brcode+Acctdaly->ACCTNO ) )        // abb 10.22.2004
      print_head    (.f.)
      print_subhead (.f.)
      pagecenter    ( prow()+1, 80, 'INITIAL CASH OUTLAY' )
      print_chead   (   )

      Cashout->( dbeval({|| print_cout()      ,;
                            if ( prow() >= MAXROW,;
                                 eval({|| __eject       (),;
                                          print_head    (.f.),;
                                          print_subhead (.f.),;
                                          pagecenter    ( prow()+1, 80, 'INITIAL CASH OUTLAY' ),;
                                          print_chead   () ;
                                      };
                                     ),;
                                 nil) ;
                        },,;
                        {||  !Cashout->(eof())                  .and. ;
                              Cashout->ACCTNO==Acctdaly->ACCTNO .and. ;
                              Cashout->brcode==Acctdaly->brcode       ;
                        };
                       );
               )
   endif
return nil
************************************
*
static function print_chead()
************************************
    local ml := 01
    @ prow()+2, ml say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
    @ prow()+1, ml say '        Payment               Amount            Reference          Reference   '
    @ prow()+1, ml say '         Code                  Paid             Code/Name            Number    '
    @ prow()+1, ml say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
return nil
****************************************
*
static function doc_list()
****************************************
    local mrecords  := {}, i:=1, mstatus,prtflg
    local mstatuses := {'ON-HAND :','LACKING :'}
//     if Docday->( dbseek(Acctdaly->ACCTNO) )
//
    if Docday->( dbseek(Acctdaly->brcode+Acctdaly->ACCTNO) )          // abb 10.22.2004
       Docday->( dbeval( {|| transfer_rec( mrecords ) },,;
                         {|| !Docday->(eof()) .and. ;
                             Docday->ACCTNO == Acctdaly->ACCTNO .and. ;
                             Docday->brcode == Acctdaly->brcode ;
                         };
                       ) ;
               )
       asort   ( mrecords,,, { |x,y| x[7] < y[7] })
       aeval   ( mrecords,   { |x| x[2] := upper( left(dispdocname(x[1]),30) )})     && RED 062305 REMOVED 'g_PAR_BRCH+

       if len(mrecords) > 0
           //__eject()
           &&& print_head (.f.)
           print_subhead (.f.)
           setfont('BOLD')
           pagecenter ( prow()+1, 80, 'DOCUMENTS CHECKLIST' )
           setfont('UNBOLD')
           setfont(upper('condensed'))
           print_shead ()
           do while i<=len( mrecords )
              mstatus := mrecords [i] [7]
              @ prow()+2, 000 say mstatuses [ val(mstatus) ]
              do while ( mrecords[i][7]==mstatus .and. i<=len(mrecords) )
                  prtflg:=.f.
                  print_list ( mrecords [i] ) ; i++
                  if i>len(mrecords)
                     exit
                  endif
                  if prow() >= 50
                     prtflg:= .t.
                     //setfont('NORMAL')
                     setfont('UNCONDENSD')
                     print_names()
                     __eject()
                     && print_head (.f.)
                     print_subhead  (.f.)
                     setfont('BOLD')
                     pagecenter ( prow()+1, 80, 'DOCUMENTS CHECKLIST' )
                     setfont('UNBOLD')
                     setfont(upper('condensed'))
                     print_shead()
                  endif
              enddo
           enddo
        endif
        setfont('UNCONDENSD')
        //setfont('NORMAL')
        if valtype(prtflg) == 'L' .and. prtflg == .f.
           setfont('UNCONDENSD')
           print_names()
        endif
        __eject()
    endif
    //setfont(upper('normal'))
    setfont('UNCONDENSD')
return nil
*
*                    End of the program ( Amst100i.prg )
*
