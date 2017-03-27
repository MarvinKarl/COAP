/*
 ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³   program ID.........:  amst100i.prg                                 ³
 ³   description........:  accounts execution printing                  ³
 ³   author.............:  Ariel B. Bulan                               ³
 ³   date...............:  10:17am February 28, 2000                    ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³                         U P D A T E S                                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³        Who        ³     When      ³               Why                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³  ABB              ³ 10.22.2004    ³   FOR ONLINE USE                 ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include "Colf.ch"
#include "Inkey.ch"
#define MAXROW 52
*********************************************************
function print_booking( m_acctno , xDBF )
*********************************************************
    local   mscr := savescreen (,,,), mcolor := setcolor()
    memvar mpreparedby, mcheckedby , mnotedby
    memvar mpcode     , mccode     , mncode
    memvar macctno    , mPRN
	private cDBF := xDBF
	
    mPRN := ' '
    ********** mpreparedby := mcheckedby := mnotedby := space( 40 )
    ********** mpcode      := mccode     := mncode   := space( 05 )
    macctno     := m_acctno
    
    ************ get_names  ()
    ************repcontrol ( '_startprn()',,,8,33 )

    _startprn()

    setcolor   ( mcolor )
    restscreen ( ,,,, mscr )

return nil

*******************************************
*
function _startprn()
*******************************************
memvar mPRN
private mpage     := 1
if cDBF == 'ACCTDALY'
    print_head        ()
    print_subhead     (.t.)
    print_facility    ()
    print_others      ()
    print_cash_outlay ()
    print_names       ()
	__eject           ()
endif

if cDBF == 'ACCTMAST'	
    print_head        ()
    print_subhead     (.t.)
    print_facility    ()
    print_names       ()    
	__eject           ()
    print_collateral  ()    
    print_cash_outlay ()    
    doc_list          () 
	__eject           ()
endif	
return nil
                    
*******************************************
*
static function print_others()
*******************************************
   local mleft := 53-8

   @ prow()+2,000 say 'Mode of Payment  : '
   @ prow()  ,pcol() say tran( (cDBF)->paymode, '@X' ) + ' ' + left( upper( disp_mode_pay( (cDBF)->paymode ) ), 30 )

   @ prow()+1,000 say 'Review Frequency : '
   @ prow()  ,pcol() say tran( (cDBF)->revfreq, '@X' ) + ' ' + upper( left( disp_rev_freq( (cDBF)->revfreq ), 35 ) )

   @ prow()+1,000 say 'CB Coll. Type    : '
   @ prow()  ,pcol() say tran( (cDBF)->cltrltype, '@!' ) + ' ' + upper( left( disp_cltrl( (cDBF)->cltrltype ), 33 ) )

   @ prow()+1,000 say 'ORIX Unit Code   : '
   @ prow()  ,pcol() say tran( (cDBF)->orixunit, '@!' ) + ' ' + upper( left( disp_orix_unit( (cDBF)->orixunit ), 30 ) )

   @ prow()+1,000 say 'CB Unit Code     : '
   @ prow()  ,pcol() say tran( (cDBF)->unitcode, '@!' ) + ' ' + upper( left( disp_unit( (cDBF)->unitcode ), 31 ) )

   @ prow()+1,000 say 'CB Credit Type   : '
   @ prow()  ,pcol() say tran( (cDBF)->credtype, '@!' ) + ' ' + upper( left( disp_cred_type( (cDBF)->credtype), 30 ) )

//   @ prow()+1,000 say 'MRR Increment    : '
   @ prow()+1,000 say 'Phibor Rate      : '
   @ prow()  ,pcol() say tran( (cDBF)->mrr_rate, '99.9999' )

//   @ prow()+1,000 say 'TB Increment     : '
   @ prow()+1,000 say 'Mart 1 Rate      : '
   @ prow()  ,pcol() say tran( (cDBF)->tb_rate, '99.9999' )

   @ prow()+1,000 say 'ORIX METRO Borrowing Rate : '
   @ prow()  ,pcol() say tran( (cDBF)->orixbrrate, '99.9999' )

   @ prow()+1,000 say 'Asset Code       : '
   @ prow()  ,pcol()+1 say (cDBF)->asetcode pict '@X'
   @ prow()  ,pcol()+1 say left( eval( {  || asetcode->(dbseek((cDBF)->asetcode) ),Asetcode->Asetname } ), 30 )

return nil

*******************************************
*
static function print_names    ()
*******************************************
    memvar mpreparedby, mcheckedby, mnotedby
    local  ml := 00, mc := 27, mr := 54
    while prow() < 47
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

/********************************************
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
    @ prow()  , pcol()       say (cDBF)->BRCODE+(cDBF)->ACCTNO pict '@R 999-9999-99999-99999'
    @ prow()  , mleft        say 'Execution Date : '
    @ prow()  , pcol()       say dtoc( (cDBF)->VALDATE )
    @ prow()+1, 000          say 'Client Number  : '
    @ prow()  , pcol()       say (cDBF)->BRCODE+(cDBF)->CLNTCODE pict '@R 999-99-99999'

    if mwhat
        @ prow()  , mleft    say 'Document Reference : '
        @ prow()  , pcol()   say (cDBF)->DOCREF
        @ prow()+1, 000      say 'Client Name    : '
    else
        @ prow()  , pcol()+1 say ' '
    endif

    @ prow()  , pcol()+2       say upper ( DISPCLNTNAME( (cDBF)->BRCODE+(cDBF)->CLNTCODE, 50 ) )     &&RED 121305 _dispclntname( (cDBF)->brcode,(cDBF)->CLNTCODE )

    if mwhat
        @ prow()+1, 000      say 'Address        : '
        @ prow()  , 017      say Client->ADDRESS1
        @ prow()+1, 017      say Client->ADDRESS2
        @ prow()+1, 017      say Client->ADDRESS3
        @ prow()+1, 000      say 'AO In-Charge   : '
        @ prow()  , pcol()   say (cDBF)->AOCODE
        @ prow()  , pcol()+2 say dispaoname( (cDBF)->AOCODE )
    endif
    @ prow()+1, 000          say replicate( chr(196),80 )
    mpage++
return nil

*/



*******************************************
*
static function print_subhead( mwhat )
*******************************************
    memvar gcompany, gsys_name, gheadmess, mpage, mtrandate
    local mleft := 53-8
    setprc( 0,0 )
    mwhat := if ( mwhat == nil, .t., mwhat )
	
	if !mWHAT
		//@ prow()+1 , 000         say 'Page : '
		//@ prow()   , pcol()      say mpage pict '9,999'
		@ prow()+1, 000          say replicate( chr(196),80 )
		@ prow()+1, 000          say 'Account Number : '
		@ prow()  , pcol()       say (cDBF)->BRCODE+(cDBF)->ACCTNO pict '@R 999-9999-99999-99999'
		@ prow()  , mleft        say 'Execution Date : '
		@ prow()  , pcol()       say dtoc( (cDBF)->VALDATE )
		@ prow()+1, 000          say 'Client Number  : '
		@ prow()  , pcol()       say (cDBF)->BRCODE+(cDBF)->CLNTCODE pict '@R 999-99-99999'

		if mwhat
			@ prow()  , mleft    say 'Document Reference : '
			@ prow()  , pcol()   say (cDBF)->DOCREF
			@ prow()+1, 000      say 'Client Name    : '
		else
			@ prow()  , pcol()+1 say ' '
		endif

		@ prow()  , pcol()+2       say upper ( DISPCLNTNAME( (cDBF)->BRCODE+(cDBF)->CLNTCODE, 50 ) )     &&RED 121305 _dispclntname( (cDBF)->brcode,(cDBF)->CLNTCODE )

		if mwhat
			@ prow()+1, 000      say 'Address        : '
			@ prow()  , 017      say Client->ADDRESS1
			@ prow()+1, 017      say Client->ADDRESS2
			@ prow()+1, 017      say Client->ADDRESS3
			@ prow()+1, 000      say 'AO In-Charge   : '
			@ prow()  , pcol()   say (cDBF)->AOCODE
			@ prow()  , pcol()+2 say dispaoname( (cDBF)->AOCODE )
		endif
		@ prow()+1, 000          say replicate( chr(196),80 )
		//mpage++

	else
	

		@ prow()+1, 000      say replicate( chr(196),80 )

		@ prow()+1, 000      say 'Account Number : '
		@ prow()  , pcol()   say (cDBF)->BRCODE+(cDBF)->ACCTNO pict '@R 999-9999-99999-99999'

		@ prow()  , mleft    say 'Document Reference : '
		@ prow()  , pcol()   say dispreftype( (cDBF)->docref ) +  ' '+(cDBF)->refno

		@ prow()+1, 000      say 'Client Number  : '
		@ prow()  , pcol()   say (cDBF)->BRCODE+(cDBF)->CLNTCODE pict '@R 999-99-99999'

		@ prow()  , mleft    say 'Currency Code      : '
		@ prow()  , pcol()   say (cDBF)->currcode  + ' '+ dispcurrency((cDBF)->currcode)

		@ prow()+1, 000      say 'Client Name    : '
		@ prow()  , pcol()       say upper ( DISPCLNTNAME( (cDBF)->BRCODE+(cDBF)->CLNTCODE,50 ) )    &&RED 121305 _dispclntname( (cDBF)->brcode,(cDBF)->CLNTCODE )

		@ prow()+1, 000      say 'Address        : '
		@ prow()  , 017      say Client->ADDRESS1
		@ prow()+1, 017      say Client->ADDRESS2

		if !empty(Client->address3)
		   @ prow()+1, 017      say Client->ADDRESS3
		endif

		@ prow()+1, 000      say 'Surety         : '
		if cDBF == 'ACCTDALY'
			@ prow()  , pcol()+1 say (cDBF)->surety1
		else
			@ prow()  , pcol()+1 say (cDBF)->surety
		endif
		
		@ prow()+1, 000      say '               : '
		@ prow()  , pcol()+1 say (cDBF)->surety2

		@ prow()+1, 000      say 'AO In-Charge   : '
		@ prow()  , pcol()   say (cDBF)->AOCODE
		@ prow()  , pcol()+2 say dispaoname( (cDBF)->AOCODE )

		@ prow()+2, 000      say 'Execution Date : '
		@ prow()  , pcol()   say dtoc( (cDBF)->VALDATE )

		@ prow()  , mleft    say 'Net Proceeds   : '
		@ prow()  , pcol()   say trans( (cDBF)->PRINCIPAL ,'999,999,999.99' )

		@ prow()+1, 000      say 'Contract Date  : '
		@ prow()  , pcol()   say dtoc( (cDBF)->CONDATE )

		@ prow()  , mleft    say 'Effective Rate : '
		@ prow()  , pcol()   say trans( (cDBF)->TRUERATE,'99.99999') + ' ' +if( (cDBF)->RATETYPE $ '12', if( (cDBF)->RATETYPE == '1', 'Fixed   ', 'Floating' ), ' ')
		
		@ prow()+1, 000      say 'Review Date    : '
		@ prow()  , pcol()   say dtoc( (cDBF)->REVDATE )

		@ prow()  , mleft    say 'Term           : '
		@ prow()  , pcol()   say trans( (cDBF)->TERM, '999' ) + if( (cDBF)->TERMUNIT == '1', ' Days',' Month(s)' )

		@ prow()+1, 000      say 'First Due Date : '
		@ prow()  , pcol()   say dtoc( (cDBF)->FIRSTDUE )

		@ prow()  , mleft    say 'Rental         : '
		@ prow()   ,pcol()   say trans( (cDBF)->AMORT   , '999,999,999.99' )

		@ prow()+1, 000      say 'Maturity Date  : '
		@ prow()  , pcol()   say dtoc( (cDBF)->MATDATE  )

		@ prow()  , mleft    say 'Total Receivables : '
		@ prow()  , pcol()   say trans( (cDBF)->CREDAMT , '999,999,999.99' )

		@ prow()+1, 000          say replicate( chr(196),80 )
		
	endif
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
   local  mtitle  :=  'Account Execution'
   if mwhat == nil
      prnreptitle( 80,00,mpage,mtitle,'Program ID : Amst100o'+ if(cDBF == 'ACCTMAST','(Account Master)',' ') ,gsys_name,gcompany)
   else
      @ prow()+1 , 000    say 'Page : '
      @ prow()   , pcol() say mpage pict '9,999'
      setfont('BOLD')
      @ prow()+1 , 31     say 'ACCOUNT EXECUTION'
      setfont('UNBOLD')
   endif
   @ prow()+1    , 31   say cmonth(mtrandate)+' '+str(day(mtrandate),2)+', '+str(year(mtrandate),4)
   mpage++
return nil

*****************************************
*
static function print_facility()
*****************************************
   local mpayfreqchoices := { '1 = Monthly    ','2 = Bi-monthly ','3 = Quarterly  ','4 = Semi-annual','5 = Annual     ','6 = Lumpsum    ','7 = Irregular  ' }
   local msetcode, mleft := 6

   @ prow()+2, 00 say (cDBF)->FCLTYCODE + ' ' + dispfcltyname( (cDBF)->FCLTYCODE )
   @ prow()+1, 00 say ''

   msetcode := Facility->SETCODE
   do case
      case msetcode == '1'
           @ prow()+1, mleft say 'Items for Lease       : ' + (cDBF)->UNIT
           **@ prow()+1, mleft say 'Dealer                : ' + (cDBF)->DLRCODE
           **@ prow()+1, mleft say 'PO Number             : ' + trans( (cDBF)->PONUM  ,'99999999' )
           ***** @ prow()+1, mleft say 'Purchase Amount       : ' + trans( (cDBF)->PURCAMT,'999,999,999.99' )
           @ prow()+1, mleft say 'Unit Location         : ' + (cDBF)->UNITLOCA
           ***** @ prow()+1, mleft say 'Net Book Value        : ' + trans( (cDBF)->PRINCIPAL, '999,999,999.99' )
           @ prow()+1, mleft say 'Payment Type          : ' + (cDBF)->PAYTYPE + ' '+ if( (cDBF)->PAYTYPE $ '12', if( (cDBF)->PAYTYPE == '1', 'In advance', 'In arrears' ), ' ')
           @ prow()+1, mleft say 'Guaranty Deposit      : ' + trans( (cDBF)->GD, '99.999999%' ) +'   '+ '[' + ( trans( round((cDBF)->PRINCIPAL*((cDBF)->GD/100),2),'999,999,999.99'))+']'
           @ prow()+1, mleft say 'Residual Value        : ' + trans( (cDBF)->RV, '99.999999%' ) +'   '+ '[' + ( trans( round((cDBF)->PRINCIPAL*((cDBF)->RV/100),2),'999,999,999.99'))+']'
           *** @ prow()+1, mleft say 'Term                  : ' + trans( (cDBF)->TERM, '999' ) + ' Month(s)'
           ***@ prow()+1, mleft say 'Effective Rate        : ' + trans( (cDBF)->TRUERATE,'99.99999') + ' ' +if( (cDBF)->RATETYPE $ '12', if( (cDBF)->RATETYPE == '1', 'Fixed   ', 'Floating' ), ' ')
           ***** @ prow()+1, mleft say 'First Due Date        : ' + dtoc ( (cDBF)->FIRSTDUE )
           @ prow()+1, mleft say 'Payment Frequency     : ' + (cDBF)->PAYFREQ + ' ' +  if ( !empty( (cDBF)->PAYFREQ ), substr ( mpayfreqchoices [ val((cDBF)->PAYFREQ) ], 5, 11 ), '  ' )
           ***** @ prow()+1, mleft say 'Maturity Date         : ' + dtoc ( (cDBF)->MATDATE )
           @ prow()+1, mleft say 'Monthly Rental Factor : ' + trans( (cDBF)->FACTOR  , '99.999999'      )
           @ prow()+1, mleft say 'Rental                : ' + trans( (cDBF)->AMORT   , '999,999,999.99' )
           @ prow()+1, mleft say 'Total Receivables     : ' + trans( (cDBF)->CREDAMT , '999,999,999.99' )
		   @ prow()+1, mleft say 'ALIR Amount           : ' + trans( (cDBF)->UDIAMT    , '999,999,999.99' )
			
      case msetcode == '2'
           @ prow()+1, mleft say 'Collateral/s          : ' + (cDBF)->UNIT
           ***** @ prow()+1, mleft say 'Net Proceeds          : ' + trans( (cDBF)->PRINCIPAL ,'999,999,999.99' )
		   
		   @ prow()+1, mleft say 'D.I. / S.I.           : ' + (trans( (cDBF)->INCENTIVE, '999,999,999.99' ))  +' '+ '[' + ltrim( trans( round(((cDBF)->INCENTIVE/(cDBF)->PURCAMT)*100,2),'99.999999%'))+']'
		   @ prow()+1, mleft say 'Withholding Tax       : ' + (trans( (cDBF)->WTAX, '999,999,999.99' ))       +' '+ '['+ ltrim( trans( round(((cDBF)->WTAX/(cDBF)->PRINCIPAL)*100,2),'99.999999%')) +']'   
		                                                                                            
           @ prow()+1, mleft say 'Payment Type          : ' + (cDBF)->PAYTYPE + ' '+ if( (cDBF)->PAYTYPE $ '12', if( (cDBF)->PAYTYPE == '1', 'In advance', 'In arrears' ), ' ')
           ***@ prow()+1, mleft say 'Term                  : ' + trans( (cDBF)->TERM, '999' ) + ' Month(s)'
           ***** @ prow()+1, mleft say 'Effective Rate        : ' + trans( (cDBF)->TRUERATE,'99.9999') + ' ' +if( (cDBF)->RATETYPE $ '12', if( (cDBF)->RATETYPE == '1', 'Fixed   ', 'Floating' ), ' ')
           ***** @ prow()+1, mleft say 'First Due Date        : ' + dtoc ( (cDBF)->FIRSTDUE )
		   
		   @ prow()+1, mleft say 'Net Effective Rate       : ' + trans( (cDBF)->NERATE, '99.9999' )
		   
           @ prow()+1, mleft say 'Payment Frequency     : ' + (cDBF)->PAYFREQ + ' ' +  if ( !empty( (cDBF)->PAYFREQ ), substr ( mpayfreqchoices [ val((cDBF)->PAYFREQ) ], 5, 11 ), '  ' )
           @ prow()+1, mleft say 'Add-On Rate           : ' + trans( (cDBF)->ADDON  , '99.9999'        )
           @ prow()+1, mleft say 'Amortization          : ' + trans( (cDBF)->AMORT  , '999,999,999.99' )
           @ prow()+1, mleft say 'Credit Amount         : ' + trans( (cDBF)->CREDAMT, '999,999,999.99' )
           //@ prow()+1, mleft say 'UDI Amount            : ' + trans( (cDBF)->UDI    , '999,999,999.99' )
		   @ prow()+1, mleft say 'UDI Amount            : ' + trans( (cDBF)->UDIAMT    , '999,999,999.99' )
           @ prow()+1, mleft say 'Maturity Date         : ' + dtoc ( (cDBF)->MATDATE )
      case msetcode == '3'
           @ prow()+1, mleft say 'Unit                  : ' + (cDBF)->UNIT
           @ prow()+1, mleft say '                      : ' + (cDBF)->UNIT2
           @ prow()+1, mleft say 'Dealer                : ' + (cDBF)->DLRCODE + ' ' + disp_dealer ( (cDBF)->DLRCODE )
           @ prow()+1, mleft say 'PO Number             : ' + trans( (cDBF)->PONUM  ,'99999999' )
           @ prow()+1, mleft say 'Sales Representative  : ' + (cDBF)->SALESREP
           ***** @ prow()+1, mleft say 'Purchase Amount       : ' + trans( (cDBF)->PURCAMT   , '999,999,999.99' )
           @ prow()+1, mleft say 'Down Payment          : ' + trans( (cDBF)->DOWNPAY   , '999,999,999.99' )
//           @ prow()+1, mleft say "Dealer's Incentive    : " + trans( (cDBF)->INCENTIVE , '999,999,999.99' )
		   @ prow()+1, mleft say 'D.I. / S.I.           : ' + (trans( (cDBF)->INCENTIVE, '999,999,999.99' ))+' '+ '[' + ltrim( trans( round(((cDBF)->INCENTIVE/(cDBF)->PURCAMT)*100,2),'99.999999%'))+']'
		   @ prow()+1, mleft say 'Withholding Tax       : ' + (trans( (cDBF)->WTAX, '999,999,999.99' ))     +' '+ '['+ ltrim( trans( round(((cDBF)->WTAX/(cDBF)->PRINCIPAL)*100,2),'99.999999%')) +']'   
           @ prow()+1, mleft say 'Net Proceeds          : ' + trans( (cDBF)->PRINCIPAL , '999,999,999.99' ) 
           @ prow()+1, mleft say 'Payment Type          : ' + (cDBF)->PAYTYPE + ' '+ if( (cDBF)->PAYTYPE $ '12', if( (cDBF)->PAYTYPE == '1', 'In advance', 'In arrears' ), ' ')
           *** @ prow()+1, mleft say 'Term                  : ' + trans( (cDBF)->TERM , '999' ) + ' Month(s)'
		   @ prow()+1, mleft say 'Net Effective Rate    : ' + trans( (cDBF)->NERATE,     '99.9999' )
           @ prow()+1, mleft say 'Gross Rate            : ' + trans( (cDBF)->TRUERATE  , '99.9999') + ' ' +if( (cDBF)->RATETYPE $ '12', if( (cDBF)->RATETYPE == '1', 'Fixed   ', 'Floating' ), ' ')
           ***@ prow()+1, mleft say 'First Due Date        : ' + dtoc ( (cDBF)->FIRSTDUE )
           @ prow()+1, mleft say 'Payment Frequency     : ' + (cDBF)->PAYFREQ + ' ' +  if ( !empty( (cDBF)->PAYFREQ ), substr ( mpayfreqchoices [ val((cDBF)->PAYFREQ) ], 5, 11 ), '  ' )
           @ prow()+1, mleft say 'Amortization          : ' + trans( (cDBF)->AMORT     , '999,999,999.99' )
           @ prow()+1, mleft say 'Credit Amount         : ' + trans( (cDBF)->CREDAMT   , '999,999,999.99' )
           @ prow()+1, mleft say 'UDI Amount            : ' + trans( (cDBF)->UDIAMT    , '999,999,999.99' )
           ***** @ prow()+1, mleft say 'Maturity Date         : ' + dtoc ( (cDBF)->MATDATE )
      case msetcode == '4' .or. msetcode == '5'
           @ prow()+1, mleft say 'Transaction Type      : ' + (cDBF)->TRANTYPE  + ' ' + if( (cDBF)->TRANTYPE == '1', 'Revolving', 'Special  ' )
           ***** @ prow()+1, mleft say 'Net Proceeds          : ' + trans( (cDBF)->PRINCIPAL, '999,999,999.99' )
           @ prow()+1, mleft say 'Payment Type          : ' + (cDBF)->PAYTYPE + ' '+ if( (cDBF)->PAYTYPE $ '12', if( (cDBF)->PAYTYPE == '1', 'In advance', 'In arrears' ), ' ')
           *** @ prow()+1, mleft say 'Term                  : ' + trans( (cDBF)->TERM, '999' ) + if( (cDBF)->TERMUNIT == '1', ' Days',' Month(s)' )
           *** @ prow()+1, mleft say 'Effective Rate        : ' + trans( (cDBF)->TRUERATE,'99.9999') + ' ' +if( (cDBF)->RATETYPE $ '12', if( (cDBF)->RATETYPE == '1', 'Fixed   ', 'Floating' ), ' ')
           @ prow()+1, mleft say 'Notification          : ' + (cDBF)->NOTFCTN   + ' ' + ( (cDBF)->NOTFCTN  $ '12', if( (cDBF)->NOTFCTN  == '1', 'With   '   , 'Without'    ), ' ' )
           @ prow()+1, mleft say 'Collection            : ' + (cDBF)->COLEXION  + ' ' + ( (cDBF)->COLEXION $ '12', if( (cDBF)->COLEXION == '1', 'Ours  '    , 'Theirs'     ), ' ' )
           @ prow()+1, mleft say 'Recourse              : ' + (cDBF)->RECOURSE  + ' ' + ( (cDBF)->RECOURSE $ '12', if( (cDBF)->RECOURSE == '1', 'With   '   , 'Without'    ), ' ' )
           @ prow()+1, mleft say 'Obligor               : ' + (cDBF)->OBLIGOR
           @ prow()+1, mleft say 'Collateral            : ' + (cDBF)->COLATRL
           ***** @ prow()+1, mleft say 'First Due Date        : ' + dtoc( (cDBF)->FIRSTDUE )
           @ prow()+1, mleft say 'Payment Frequency     : ' + (cDBF)->PAYFREQ + ' ' +  if ( !empty( (cDBF)->PAYFREQ ), substr ( mpayfreqchoices [ val((cDBF)->PAYFREQ) ], 5, 11 ), '  ' )
           @ prow()+1, mleft say 'Amortization          : ' + trans( (cDBF)->AMORT   , '999,999,999.99' )
           @ prow()+1, mleft say 'Credit Amount         : ' + trans( (cDBF)->CREDAMT , '999,999,999.99' )
		   //@ prow()+1, mleft say 'UDI Amount            : ' + trans( (cDBF)->UDI     , '999,999,999.99' ) RLV 9:17 AM 5/21/2013
           @ prow()+1, mleft say 'UDI Amount            : ' + trans( (cDBF)->UDIAMT     , '999,999,999.99' )
           ***** prow()+1, mleft say 'Maturity Date         : ' + dtoc ( (cDBF)->MATDATE )
   endcase
return nil
*******************************************
*
static function print_collateral ()
*******************************************
    if Ctrlinfo->( dbseek((cDBF)->brcode+(cDBF)->ACCTNO ) )
       //__eject()
       Ctrlinfo->( dbeval( {|| print_head(.f.),print_subhead(.f.),pgeTitle( prow()+1, 80,'COLLATERAL INFORMATION' ),print_colrec((cDBF)->brcode+(cDBF)->ACCTNO),print_names(),__eject() } ,, {|| !Ctrlinfo->(eof()) .and. Ctrlinfo->ACCTNO==(cDBF)->ACCTNO }) )
    endif
return nil
************************************
*
static function print_cash_outlay()
************************************
   if Cashout->( dbseek((cDBF)->brcode+(cDBF)->ACCTNO ) )
      print_head    (.f.)
      print_subhead (.f.)
      pagecenter    ( prow()+1, 80, 'INITIAL CASH OUTLAY' )
      print_chead   (   )

      Cashout->( dbeval({|| print_cout((cDBF)->brcode+(cDBF)->ACCTNO )      ,;
                            if ( prow() >= MAXROW, eval({||__eject(),print_head(.f.),print_subhead(.f.),pagecenter    ( prow()+1, 80, 'INITIAL CASH OUTLAY' ) ,print_chead()}), nil) ;
                        },,;
                        {||!Cashout->(eof()) .and. CASHOUT->BRCODE+Cashout->ACCTNO==(cDBF)->brcode+(cDBF)->ACCTNO }) )
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
    if Docday->( dbseek((cDBF)->brcode+(cDBF)->ACCTNO ) )
       Docday->( dbeval( {|| transfer_rec( mrecords ) },,{||!Docday->(eof()) .and. DOCDAY->BRCODE+Docday->ACCTNO==(cDBF)->brcode+(cDBF)->ACCTNO  }) )
       asort   ( mrecords,,, { |x,y| x[7] < y[7] })
       aeval   ( mrecords,   {|x| x[2] := upper( left(dispdocname(x[1]),30) )})

       if len(mrecords) > 0
           //__eject()
            print_head (.f.)
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
                      print_head (.f.)
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
*                    End of the program ( Amst100o.prg )
*
