/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   program ID.........:  amsm100g.prg                                         ³
³   description........:  Account Master Printing                              ³
³   author.............:  Ariel B. Bulan                                       ³
³   date...............:  10:00am 03-Mar-1995                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                         U P D A T E S                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        Who        ³     When      ³               Why                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Janet L. Bautista ³  10-Sep-1997  ³ gd, rv to 5 decimal places               ³
³ Edreb S. Virtusio ³  19-Jul-2011  ³ add others                               ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include "Colf.ch"
#include "Inkey.ch"

#define MAXROW 54
*********************************************************
function print_acct( m_acctno )
*********************************************************
    local   mscr := savescreen (,,,), mcolor := setcolor()
    memvar  ax_level, g_user_id
    private mpreparedby, mcheckedby, mnotedby, mpcode, mccode, mncode, macctno

    if !chkpass( procname(),ax_level,g_user_id )
      return nil
    endif
    mpreparedby := mcheckedby := mnotedby := space( 40 )
    mpcode      := mccode     := mncode   := space( 05 )
    macctno     := m_acctno
   
    *if( get_names(), repcontrol('beginprinting()',,,8,33),nil )
    if( get_names(), repcon_ol('beginprinting()',,,8,33),nil )
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


//**********************************************
//static function get_names()
//**********************************************
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
//***************************************************
//static function look_at_them( mcode, mname, mmess )
//***************************************************
//    if lastkey() != K_ESC
//       center  ( 24, 'w+/n', mmess )
//       lb_lkup ( 'Personel' ,1,1, @mcode, 2, 1, 10, 4, 20, 64, 'w/gr+,w/n,,,w/gr+' )
//       mname := Personel->FULLNAME
//       center  ( 24, 'w+/n', padr( '', len( mmess ) ) )
//    endif
//return .f.

*******************************************
function beginprinting()
*******************************************
    private mpage     := 1
    print_head        ()
    print_subhead     ()
    print_facility    ()
    print_names       ()     //               D I A Y  B A N G E R  !!!
    print_collateral  ()     //                     ||||||||
    print_cash_outlay ()     //                     ||||||||
    doc_list          ()     //                     
return nil
********************************************
static function print_names ()
********************************************
    memvar mpreparedby, mcheckedby, mnotedby
return eval ({ | ml , mc , mr | ml := 00, mc := 27, mr := 54                 ,;
                 devpos( prow()+2, 00 ) , devout( repl( chr(196), 80 ) )     ,;
                 devpos( prow()+1, ml ) , devout( "Prepared by :" )          ,;
                 devpos( prow(), mc )   , devout( "Checked by  :" )          ,;
                 devpos( prow(), mr )   , devout( "Noted by    :" )          ,;
                 devpos( prow()+3, ml ) , devout( repl( "Ä", 25 ) )          ,;
                 devpos( prow(), mc )   , devout( repl( "Ä", 25 ) )          ,;
                 devpos( prow(), mr )   , devout( repl( "Ä", 25 ) )          ,;
                 devpos( prow()+1, ml ) , devout( left( mpreparedby, 25 ) )  ,;
                 devpos( prow(), mc )   , devout( left( mcheckedby , 25 ) )  ,;
                 devpos( prow(), mr )   , devout( left( mnotedby   , 25 ) )  ,;
                 nil                                                          ;
            })
*******************************************
static function print_subhead( mwhat )
*******************************************
    local mleft := 53

    mwhat := if ( mwhat == nil, .t., mwhat )
    @ prow()+2, 000          say replicate( chr(196),80 )
    @ prow()+1, 000          say 'Account Number : '
    @ prow()  , pcol()       say ACCTMAST->BRCODE+Acctmast->ACCTNO pict '@R 999-9999-99999-99999'
    @ prow()  , mleft        say 'Execution Date : '
    @ prow()  , pcol()       say dtoc( Acctmast->VALDATE )
    @ prow()+1, 000          say 'Client Number  : '
    @ prow()  , pcol()       say ACCTMAST->BRCODE+Acctmast->CLNTCODE pict '@R 999-99-99999'
    if mwhat
        @ prow()  , mleft    say 'Document Reference : '
        @ prow()  , pcol()   say Acctmast->DOCREF
        @ prow()+1, 000      say 'Client Name    : '
    else
        @ prow()  , pcol()+1 say ' '
    endif

    @ prow()  , pcol()       say upper ( dispclntname( ACCTMAST->BRCODE+Acctmast->CLNTCODE, 40 ) )

    if mwhat
        @ prow()+1, 000      say 'Address        : '
        @ prow()  , 017      say Client->ADDRESS1
        @ prow()+1, 017      say Client->ADDRESS2
        @ prow()+1, 017      say Client->ADDRESS3
        @ prow()+1, 000      say 'AO In-Charge   : '
        @ prow()  , pcol()   say Acctmast->AOCODE
        @ prow()  , pcol()+2 say dispaoname( Acctmast->AOCODE )
    endif
    @ prow()+1, 000          say replicate( chr(196),80 )
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
      @ prow()+1 , 32     say 'AVAILMENT SHEET'
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
   @ prow()+2, 00 say Acctmast->FCLTYCODE + ' ' + dispfcltyname( Acctmast->FCLTYCODE )
   msetcode := Facility->SETCODE
   do case
      case msetcode == '1'
           @ prow()+1, mleft say 'Items for Lease       : ' + Acctmast->UNIT
           @ prow()+1, mleft say 'Dealer                : ' + Acctmast->DLRCODE
           @ prow()+1, mleft say 'Purchase Amount       : ' + trans( Acctmast->PURCAMT,'999,999,999.99' )
           @ prow()+1, mleft say 'Unit Location         : ' + Acctmast->UNITLOCA
           @ prow()+1, mleft say 'Net Book Value        : ' + trans( Acctmast->PRINCIPAL, '999,999,999.99' )
           @ prow()+1, mleft say 'Payment Type          : ' + Acctmast->PAYTYPE + ' '+ if( Acctmast->PAYTYPE $ '12', if( Acctmast->PAYTYPE == '1', 'In advance', 'In arrears' ), ' ')
           @ prow()+1, mleft say 'Guaranty Deposit      : ' + trans( Acctmast->GD, '99.999999%' )+'   '+ '[' + ( trans( round(Acctmast->PRINCIPAL*(Acctmast->GD/100),2),'999,999,999.99'))+']'
           @ prow()+1, mleft say 'Residual Value        : ' + trans( Acctmast->RV, '99.999999%' )+'   '+ '[' + ( trans( round(Acctmast->PURCAMT*(Acctmast->RV/100),2),'999,999,999.99'))+']'
           @ prow()+1, mleft say 'Term                  : ' + trans( Acctmast->TERM, '999' ) + ' Month(s)'
           @ prow()+1, mleft say 'Effective Rate        : ' + trans( Acctmast->TRUERATE,'99.9999') + ' ' +if( Acctmast->RATETYPE $ '12', if( Acctmast->RATETYPE == '1', 'Fixed   ', 'Floating' ), ' ')
           @ prow()+1, mleft say 'First Due Date        : ' + dtoc ( Acctmast->FIRSTDUE )
           @ prow()+1, mleft say 'Payment Frequency     : ' + Acctmast->PAYFREQ + ' ' +  if ( !empty( Acctmast->PAYFREQ ), substr ( mpayfreqchoices [ val(Acctmast->PAYFREQ) ], 5, 11 ), '  ' )
           @ prow()+1, mleft say 'Maturity Date         : ' + dtoc ( Acctmast->MATDATE )
           @ prow()+1, mleft say 'Monthly Rental Factor : ' + trans( Acctmast->FACTOR  , '99.999999'      )
           @ prow()+1, mleft say 'Rental                : ' + trans( Acctmast->AMORT   , '999,999,999.99' )
           @ prow()+1, mleft say 'Total Receivables     : ' + trans( Acctmast->CREDAMT , '999,999,999.99' )
           @ prow()+1, mleft say '                                                                        '
           @ prow()+1, mleft say 'Review Date           : ' + dtoc ( Acctmast->REVDATE )
           @ prow()+1, mleft say 'Mode of Payment       : ' + tran( Acctmast->paymode, '@X' ) + ' ' + tran( LEFT(disp_mode_pay( Acctmast->paymode ),15), '@!' )
           @ prow()+1, mleft say 'Review Frequency      : ' + tran( Acctmast->revfreq, '@X' ) + ' ' + tran( left( disp_rev_freq( Acctmast->revfreq ), 15 ), '@!' ) 
           @ prow()+1, mleft say 'CB Collateral Type    : ' + tran( Acctmast->cltrltype, '@X' ) + ' ' + tran( left( disp_cltrl( Acctmast->cltrltype ), 15 ), '@!' )
           @ prow()+1, mleft say 'Orix Unit Code        : ' + tran( Acctmast->orixunit ,'@X' ) + ' '+ tran( left( disp_ORIX_unit( Acctmast->orixunit ), 17 ), '@!' )
           @ prow()+1, mleft say 'CB Unit Code          : ' + tran( Acctmast->unitcode, '@X' ) + ' ' + tran( left( disp_unit( Acctmast->unitcode ), 15 ), '@!' )
           @ prow()+1, mleft say 'CB Credit Type        : ' + tran( Acctmast->credtype, '@X' ) + ' ' + tran( left( disp_cred_type( Acctmast->credtype ), 15 ), '@!' )
           @ prow()+1, mleft say 'MRR Increment         : ' + trans( Acctmast->MRR_RATE , '99.9999' )
           @ prow()+1, mleft say 'TB Increment          : ' + trans( Acctmast->TB_RATE , '99.9999')
           @ prow()+1, mleft say 'Orix Borr. Rate       : ' + trans( Acctmast->ORIXBRRATE , '99.9999' )
           @ prow()+1, mleft say 'Asset Code            : ' + trans( Acctmast->ASETCODE , '@X' ) + ' ' + TRAN( LEFT(disp_asetname( Acctmast->asetcode),13), '@!' )
      case msetcode == '2'
	  
           @ prow()+1, mleft say 'Collateral/s          : ' + Acctmast->UNIT
           @ prow()+1, mleft say 'Net Proceeds          : ' + trans( Acctmast->PRINCIPAL ,'999,999,999.99' )
		   
		   @ prow()+1, mleft say 'D.I. / S.I.           : ' + (trans( Acctmast->INCENTIVE, '999,999,999.99' )) +' '+ '(' + ltrim( trans( round((Acctmast->INCENTIVE/Acctmast->PURCAMT)*100,2),'99.999999%'))+')'
		   @ prow()+1, mleft say 'Withholding Tax       : ' + (trans( Acctmast->WTAX, '999,999,999.99' ))      +' '+ '('+ ltrim( trans( round((Acctmast->WTAX/Acctmast->PRINCIPAL)*100,2),'99.999999%')) +')'   
		                                                                                            
           @ prow()+1, mleft say 'Payment Type          : ' + Acctmast->PAYTYPE + ' '+ if( Acctmast->PAYTYPE $ '12', if( Acctmast->PAYTYPE == '1', 'In advance', 'In arrears' ), ' ')
           @ prow()+1, mleft say 'Term                  : ' + trans( Acctmast->TERM, '999' ) + ' Month(s)'
           @ prow()+1, mleft say 'Gross Effective Rate  : ' + trans( Acctmast->TRUERATE,'99.9999') + ' ' +if( Acctmast->RATETYPE $ '12', if( Acctmast->RATETYPE == '1', 'Fixed   ', 'Floating' ), ' ')
		   @ prow()+1, mleft say 'Net Effective Rate    : ' + trans( Acctmast->NERATE,'99.9999%')
           @ prow()+1, mleft say 'First Due Date        : ' + dtoc ( Acctmast->FIRSTDUE )
           @ prow()+1, mleft say 'Payment Frequency     : ' + Acctmast->PAYFREQ + ' ' +  if ( !empty( Acctmast->PAYFREQ ), substr ( mpayfreqchoices [ val(Acctmast->PAYFREQ) ], 5, 11 ), '  ' )
           @ prow()+1, mleft say 'Add-On Rate           : ' + trans( Acctmast->ADDON  , '99.9999'        )
           @ prow()+1, mleft say 'Amortization          : ' + trans( Acctmast->AMORT  , '999,999,999.99' )
           @ prow()+1, mleft say 'Credit Amount         : ' + trans( Acctmast->CREDAMT, '999,999,999.99' )
		   if Acctmast->UDIAMT > 0
		      @ prow()+1, mleft say 'UDI Amount            : ' + trans( Acctmast->UDIAMT , '999,999,999.99' )
		   else
              @ prow()+1, mleft say 'UDI Amount            : ' + trans( Acctmast->CREDAMT - ACCTMAST->PRINCIPAL - ACCTMAST->INCENTIVE - ACCTMAST->WTAX, '999,999,999.99' )
		   endif
           //@ prow()+1, mleft say 'UDI Amount            : ' + trans( Acctmast->UDI    , '999,999,999.99' )
           @ prow()+1, mleft say 'Maturity Date         : ' + dtoc ( Acctmast->MATDATE )
	  
	  
      case msetcode == '3'
           @ prow()+1, mleft say 'Unit                  : ' + Acctmast->UNIT
           @ prow()+1, mleft say 'Dealer                : ' + Acctmast->DLRCODE + ' ' + disp_dealer ( Acctmast->DLRCODE )
           @ prow()+1, mleft say 'Sales Representative  : ' + Acctmast->SALESREP
           @ prow()+1, mleft say 'Purchase Amount       : ' + trans( Acctmast->PURCAMT   , '999,999,999.99' )
           @ prow()+1, mleft say 'Down Payment          : ' + trans( Acctmast->DOWNPAY   , '999,999,999.99' )
//           @ prow()+1, mleft say "Dealer's Incentive    : " + trans( Acctmast->INCENTIVE , '999,999,999.99' )
		   @ prow()+1, mleft say 'D.I. / S.I.           : ' + (trans( Acctmast->INCENTIVE, '999,999,999.99' )) +' '+ '(' + ltrim( trans( round((Acctmast->INCENTIVE/Acctmast->PURCAMT)*100,2),'99.999999%'))+')'
		   @ prow()+1, mleft say 'Withholding Tax       : ' + (trans( Acctmast->WTAX, '999,999,999.99' ))      +' '+ '('+ ltrim( trans( round((Acctmast->WTAX/Acctmast->PRINCIPAL)*100,2),'99.999999%')) +')'   
           @ prow()+1, mleft say 'Net Proceeds          : ' + trans( Acctmast->PRINCIPAL , '999,999,999.99' )  
           @ prow()+1, mleft say 'Payment Type          : ' + Acctmast->PAYTYPE + ' '+ if( Acctmast->PAYTYPE $ '12', if( Acctmast->PAYTYPE == '1', 'In advance', 'In arrears' ), ' ')
           @ prow()+1, mleft say 'Term                  : ' + trans( Acctmast->TERM , '999' ) + ' Month(s)'
           @ prow()+1, mleft say 'Gross Effective Rate  : ' + trans( Acctmast->TRUERATE  , '99.9999') + ' ' +if( Acctmast->RATETYPE $ '12', if( Acctmast->RATETYPE == '1', 'Fixed   ', 'Floating' ), ' ')
		   @ prow()+1, mleft say 'Net Effective Rate    : ' + trans( Acctmast->NERATE,'99.9999%')
           @ prow()+1, mleft say 'First Due Date        : ' + dtoc ( Acctmast->FIRSTDUE )
           @ prow()+1, mleft say 'Payment Frequency     : ' + Acctmast->PAYFREQ + ' ' +  if ( !empty( Acctmast->PAYFREQ ), substr ( mpayfreqchoices [ val(Acctmast->PAYFREQ) ], 5, 11 ), '  ' )
           @ prow()+1, mleft say 'Amortization          : ' + trans( Acctmast->AMORT     , '999,999,999.99' )
           @ prow()+1, mleft say 'Credit Amount         : ' + trans( Acctmast->CREDAMT   , '999,999,999.99' )
		   if Acctmast->UDIAMT > 0
		      @ prow()+1, mleft say 'UDI Amount            : ' + trans( Acctmast->UDIAMT , '999,999,999.99' )
		   else
              @ prow()+1, mleft say 'UDI Amount            : ' + trans( Acctmast->CREDAMT - ACCTMAST->PRINCIPAL - ACCTMAST->INCENTIVE - ACCTMAST->WTAX, '999,999,999.99' )
		   endif
           //@ prow()+1, mleft say 'UDI Amount            : ' + trans( Acctmast->UDI       , '999,999,999.99' )
           @ prow()+1, mleft say 'Maturity Date         : ' + dtoc ( Acctmast->MATDATE )
      case msetcode == '4' .or. msetcode == '5'
           @ prow()+1, mleft say 'Transaction Type      : ' + Acctmast->TRANTYPE  + ' ' + if( Acctmast->TRANTYPE == '1', 'Revolving', 'Special  ' )
           @ prow()+1, mleft say 'Net Proceeds          : ' + trans( Acctmast->PRINCIPAL, '999,999,999.99' )
           @ prow()+1, mleft say 'Payment Type          : ' + Acctmast->PAYTYPE + ' '+ if( Acctmast->PAYTYPE $ '12', if( Acctmast->PAYTYPE == '1', 'In advance', 'In arrears' ), ' ')
           @ prow()+1, mleft say 'Term                  : ' + trans( Acctmast->TERM, '999' ) + if( Acctmast->TERMUNIT == '1', ' Days',' Month(s)' )
           @ prow()+1, mleft say 'Effective Rate        : ' + trans( Acctmast->TRUERATE,'99.9999') + ' ' +if( Acctmast->RATETYPE $ '12', if( Acctmast->RATETYPE == '1', 'Fixed   ', 'Floating' ), ' ')
           @ prow()+1, mleft say 'Notification          : ' + Acctmast->NOTFCTN   + ' ' + ( Acctmast->NOTFCTN  $ '12', if( Acctmast->NOTFCTN  == '1', 'With   '   , 'Without'    ), ' ' )
           @ prow()+1, mleft say 'Collection            : ' + Acctmast->COLEXION  + ' ' + ( Acctmast->COLEXION $ '12', if( Acctmast->COLEXION == '1', 'Ours  '    , 'Theirs'     ), ' ' )
           @ prow()+1, mleft say 'Recourse              : ' + Acctmast->RECOURSE  + ' ' + ( Acctmast->RECOURSE $ '12', if( Acctmast->RECOURSE == '1', 'With   '   , 'Without'    ), ' ' )
           @ prow()+1, mleft say 'Obligor               : ' + Acctmast->OBLIGOR
           @ prow()+1, mleft say 'Collateral            : ' + Acctmast->COLATRL
           @ prow()+1, mleft say 'First Due Date        : ' + dtoc( Acctmast->FIRSTDUE )
           @ prow()+1, mleft say 'Payment Frequency     : ' + Acctmast->PAYFREQ + ' ' +  if ( !empty( Acctmast->PAYFREQ ), substr ( mpayfreqchoices [ val(Acctmast->PAYFREQ) ], 5, 11 ), '  ' )
           @ prow()+1, mleft say 'Amortization          : ' + trans( Acctmast->AMORT   , '999,999,999.99' )
           @ prow()+1, mleft say 'Credit Amount         : ' + trans( Acctmast->CREDAMT , '999,999,999.99' )
           //@ prow()+1, mleft say 'UDI Amount            : ' + trans( Acctmast->UDI     , '999,999,999.99' )
           @ prow()+1, mleft say 'Maturity Date         : ' + dtoc ( Acctmast->MATDATE )
   endcase
return nil
*******************************************
*
static function print_collateral ()
*******************************************
    __eject()
    Ctrlinfo->( dbseek( ACCTMAST->BRCODE+Acctmast->ACCTNO ) )
    Ctrlinfo->( dbeval( {|| print_head(.f.),print_subhead(.f.),pagecenter( prow()+1, 80,'COLLATERAL INFORMATION' ),print_colrec(ACCTMAST->BRCODE+Acctmast->Acctno),__eject() } ,, {|| !Ctrlinfo->(eof()) .and. CTRLINFO->BRCODE+Ctrlinfo->ACCTNO==ACCTMAST->BRCODE+Acctmast->ACCTNO }) )
return nil
************************************
*
static function print_cash_outlay()
************************************
    Cashout->( dbseek( ACCTMAST->BRCODE+Acctmast->ACCTNO ) )
    print_head    (.f.)
    print_subhead (.f.)
    pagecenter    ( prow()+1, 80, 'INITIAL CASH OUTLAY' )
    print_chead   (   )

    Cashout->( dbeval({|| print_cout() ,;
                          if ( prow() >= MAXROW, eval({||__eject(),print_head(.f.),print_subhead(.f.),pagecenter    ( prow()+1, 80, 'INITIAL CASH OUTLAY' ) ,print_chead()}), nil) ;
                      },,;
                      {||!Cashout->(eof()) .and. CASHOUT->BRCODE+Cashout->ACCTNO==ACCTMAST->BRCODE+Acctmast->ACCTNO }) )
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
    local mrecords  := {}, i:=1, mstatus
    local mstatuses := {'ON-HAND :','LACKING :'}
    Docday->( dbseek( ACCTMAST->BRCODE+Acctmast->ACCTNO ) )
    Docday->( dbeval( {|| transfer_rec( mrecords ) },,{||!Docday->(eof()) .and. DOCDAY->BRCODE+Docday->ACCTNO==ACCTMAST->BRCODE+Acctmast->ACCTNO }) )
    asort   ( mrecords,,, { |x,y| x[7] < y[7] })
    aeval   ( mrecords,   {|x| x[2] := upper( left(dispdocname(x[1]),25) )})   && RED 031405 ADDED 'g_PAR_BRCH+    && RED 062405 REMOVED 'g_PAR_BRCH+

    if len(mrecords) > 0
        __eject() ;print_head (.f.)  ; print_subhead (.f.)
        pagecenter ( prow()+1, 80, 'DOCUMENTS CHECKLIST' )
		setfont(upper('condensed'))
        print_shead ()
        do while i<=len( mrecords )
           mstatus := mrecords [i] [7]
           @ prow()+1, 000 say mstatuses [ val(mstatus) ]
           do while ( mrecords[i][7]==mstatus .and. i<=len(mrecords) )
               print_list ( mrecords [i] ) ; i++
               if i>len(mrecords)
                  exit
               endif
               if prow() >= MAXROW
                  __eject() ;print_head (.f.) ; print_subhead  (.f.)
                  pagecenter ( prow()+1, 80, 'DOCUMENTS CHECKLIST' )
				  setfont(upper('condensed'))
                  print_shead()
               endif
           enddo
        enddo
     endif
    __eject()
return nil
*
*                    End of the program ( Amst100i.prg )
*
