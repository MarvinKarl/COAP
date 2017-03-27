/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   PROGRAM ID.........:  amsm300c.prg                                         ³
³   Description........:  loan offering ticket printing                        ³
³   Author.............:  Ariel B. Bulan                                       ³
³   Date...............:  03:26pm 13-Oct-1994                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                         U P D A T E S                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        Who        ³     When      ³               Why                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Janet L. Bautista ³  27-Oct-1994  ³ do not print heading of any of           ³
³                   ³               ³ the memo fields if empty                 ³
³ Gener C. Singson  ³  21-Feb-1996  ³ printing overhaul                        ³
³ Janet L. Bautista ³  17-Apr-1996  ³ follow standard coding structure         ³
³                   ³               ³ & correct printing of aoname             ³
³ Janet L. Bautista ³  10-Sep-1997  ³ gd, rv to 5 decimal places               ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#xtran gettrantype  ( <cnum> ) => if( <cnum> == '1'  , 'Revolving', 'Special' )
#xtran getpaytype   ( <cnum> ) => if( <cnum> == '1'  , 'In Advance', 'In Arrears' )
#xtran getratetype  ( <cnum> ) => if( <cnum> == '1'  , 'Fixed', 'Floating' )
#xtran gettermunit  ( <cnum> ) => if( <cnum> == '1'  , 'Day(s)', 'Month(s)' )
#xtran getnotifition( <cnum> ) => if( <cnum> == '1'  , 'With', 'Without' )
#xtran getcollection( <cnum> ) => if( <cnum> == '1'  , 'Ours', 'Theirs' )
#xtran getrecourse  ( <cnum> ) => if( <cnum> == '1'  , 'With', 'Without' )
#xtran getcredrisk  ( <cnum> ) => if( <cnum> == 'I'  , 'Current',;
                                  if( <cnum> == 'II' , 'Watchlist',;
                                  if( <cnum> == 'III', 'Substandard',;
                                  if( <cnum> == 'IV' , 'Doubtful',;
                                  if( <cnum> == 'V'  , 'Loss', '' ) ) ) ) )
#xtran getpayfreq   ( <cnum> ) => if( <cnum> == '1'  , 'Monthly',;
                                  if( <cnum> == '2'  , 'Bi-Monthly',;
                                  if( <cnum> == '3'  , 'Quarterly',;
                                  if( <cnum> == '4'  , 'Semi-Annual',;
                                  if( <cnum> == '5'  , 'Annual',;
                                  if( <cnum> == '6'  , 'Lumpsum', 'Irregular' ) ) ) ) ) )

#include 'INKEY.CH'
#include 'ACHOICE.CH'
#include 'COLF.CH'

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   function OTPRINT()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   private DEF_BAL, MAX_1_COMNAME_LENGTH := '', mSUB_1_TITLE, mSUB_2_TITLE
   private mPAGE := 0, COMM_ := {}, MAX_2_COMNAME_LENGTH := ''
   private THE_AMOUNT_HAS_BEEN_PRINTED_RECENTLY := .t., JUST_ONCE := .t.
   setprc( 0,0 )
   BEG_OTPRINT( SEEKCLNT(), SEEKFCLTY(), SEEKAMNT(), SEEKSIGN() )
   __mrelease( "*", .t. )

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function BEG_OTPRINT( clnt_, fclty_, amnt_, sign_ )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   memvar mPAGE, just_once
   heading( .t. )
   heading( .f. )
   devprint( clnt_, .t., .t., sign_ )
   devpos( prow() + 1, 0 )
   devout( repl( 'Ä', maxcol() ) )
   devprint( fclty_, .f., .t., sign_ )

   devmemos( OTICKET->secheld, 'security held', sign_  )
   devmemos( OTICKET->obtain , 'to be obtained', sign_ )

   devpos( prow() + 1, 0 )
   eval( { | p | p := prow(), if( p + 9 >= 45, eval( { || devpos( max( 45,prow() ), 0 ), CHKEJECT( sign_, .t. ) } ), nil ) } )
   devprint( amnt_, .f., .f., sign_ )

   devmemos( OTICKET->remarks, 'remarks', sign_ )

   devpos( if( mPAGE < 2, max( 45, prow() ), if( !just_once, max( 45, prow() ), max( 52,prow() ) ) ), 0 )
   CHKEJECT( sign_, .f. )
   __eject()

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function SEEKCLNT()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mclntcode := { | n | Client->( dbseek( OTICKET->clntcode ) ), n }
   local mclnt := rtrim( eval( mclntcode, Client->fullname ) )
   local mcrdcd := eval( { || Corpinfo->( dbseek( OTICKET->clntcode ) ), rtrim( Corpinfo->credrisk ) } )
   local mindcd := eval( { || Client->( dbseek( OTICKET->clntcode ) ),;
         Industry->( dbseek( Client->indcode ) ), rtrim( Client->indcode ) + ' ' + Industry->indname } )
   local clnt_, maxlen := 1, mdata_ 

   clnt_  := { 'Client Name', 'Credit Risk', 'Industry', 'Address', '~', '~' }
   mdata_ := { tran( eval( mclntcode, Client->clntcode ), '@R 99-99999' ) + ' ' + mclnt,;
               mcrdcd + ' ' + tran( getcredrisk( mcrdcd ), '@X' ), mindcd,;
               tran( if( empty( eval( mclntcode, Client->address1 ) ), '~',;
               eval( mclntcode, Client->address1 ) ), '@X' ),;
               tran( if( empty( eval( mclntcode, Client->address2 ) ), '~',;
               eval( mclntcode, Client->address2 ) ), '@X' ),;
               tran( if( empty( eval( mclntcode, Client->address3 ) ), '~',;
               eval( mclntcode, Client->address3 ) ), '@X' ) }
   return( refine( clnt_, mdata_, maxlen, .t. ) )

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function SEEKFCLTY()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mSETCODE := { | s | FACILITY->( dbseek( OTICKET->FCLTYCODE ) ), s }
   local mfclty := { | n | "(" + rtrim( FACILITY->fcltyalias ) + ") " +;
                                               rtrim( propercase( n ) ) }
   local fclty_, maxlen := 1, mdata_

   do case
      case eval( mSETCODE, FACILITY->SETCODE ) == '1'
         fclty_ := { eval( mfclty, FACILITY->fcltyname ),;
                     'Purchase Amount', 'Guaranty Deposit', 'Residual Value', 'Term', 'Effective Rate',;
                     'Monthly Rental', 'Monthly Rental Factor', 'Item for Lease', '~', 'Surety', '~' }
         mdata_ := { tran( OTICKET->credamt, '999,999,999.99' ),;
                     tran( OTICKET->proceeds, '999,999,999.99' ),;
                     tran( OTICKET->gd, '99.99999' ) + '%',;
                     tran( OTICKET->rv, '99.99999' ) + '%',;
                     tran( OTICKET->term, '999' ) + ' ' +;
                     tran( gettermunit( OTICKET->termunit ), '@X' ),;
                     tran( OTICKET->truerate, '99.99' ) + '% ' +;
                     tran( getratetype( OTICKET->ratetype ), '@X' ),; 
                     tran( OTICKET->amort, '999,999,999.99' ) + ' ' +;
                     tran( getpaytype( OTICKET->paytype ), '@X' ),;
                     tran( OTICKET->factor, '99.9999' ),;
                     tran( if( empty( OTICKET->unit ), '~', OTICKET->unit ), '@X' ),;
                     tran( if( empty( OTICKET->unit2 ), '~', OTICKET->unit2 ), '@X' ),;
                     tran( if( empty( OTICKET->surety1 ), '~', OTICKET->surety1 ), '@X' ),;
                     tran( if( empty( OTICKET->surety2 ), '~', OTICKET->surety2 ), '@X' ) }
      case eval( mSETCODE, FACILITY->SETCODE ) == '2'
         fclty_ := { eval( mfclty, FACILITY->fcltyname ),;
                     'Net Proceeds', 'Term', 'Effective Rate', 'Monthly Amortization', 'Collaterals',;
                     '~', 'Surety', '~' }
         mdata_ := { tran( OTICKET->credamt, '999,999,999.99' ),;
                     tran( OTICKET->proceeds, '999,999,999.99' ),;
                     tran( OTICKET->term, '999' ) + ' ' +;
                     tran( gettermunit( OTICKET->termunit ), '@X' ),;
                     tran( OTICKET->truerate, '99.99' ) + '% ' +;
                     tran( getratetype( OTICKET->ratetype ), '@X' ),;
                     tran( OTICKET->amort, '999,999,999.99' ) + ' ' +;
                     tran( getpaytype( OTICKET->paytype ), '@X' ),;
                     tran( if( empty( OTICKET->unit ), '~', OTICKET->unit ), '@X' ),;
                     tran( if( empty( OTICKET->unit2 ), '~', OTICKET->unit2 ), '@X' ),;
                     tran( if( empty( OTICKET->surety1 ), '~', OTICKET->surety1 ), '@X' ),;
                     tran( if( empty( OTICKET->surety2 ), '~', OTICKET->surety2 ), '@X' ) }
      case eval( mSETCODE, FACILITY->SETCODE ) == '3'
         fclty_ := { eval( mfclty, FACILITY->fcltyname ),;
                     'Unit', '~', 'Dealer', 'Sales Representative', 'Cash Price', 'Down Payment',"D.I. / S.I.",;
                     'Net Proceeds', 'Term', 'Gross Rate', 'Net Effective Rate', 'Monthly Amortization',;
                     'Surety' , '~' }
         mdata_ := { tran( OTICKET->credamt, '999,999,999.99' ),;
                     tran( if( empty( OTICKET->unit ), '~', OTICKET->unit ), '@X' ),;
                     tran( if( empty( OTICKET->unit2 ), '~', OTICKET->unit2 ), '@X' ),;
                     tran( eval( { || Dealer->( dbseek( OTICKET->BRCODE+OTICKET->dlrcode ) ), Dealer->dlrname } ), '@X' ),;   && RED 013105 'OTICKET->BRCODE
                     tran( if( empty( OTICKET->salesrep ), '~', OTICKET->salesrep ), '@X' ),;
                     tran( OTICKET->purcamt, '999,999,999.99' ),;
                     tran( OTICKET->downpay, '999,999,999.99' ),;
                     tran( Oticket->Incentive,'999,999,999.99' ),;
                     tran( OTICKET->proceeds, '999,999,999.99' ),;
                     tran( OTICKET->term, '999' ) + ' ' +;
                     tran( gettermunit( OTICKET->termunit ), '@X' ),;
                     tran( OTICKET->truerate, '99.9999' ) + '% ' +;
                     tran( getratetype( OTICKET->ratetype ), '@X' ),;
                     tran( OTICKET->nerate, '99.9999' ),;                    
                     tran( OTICKET->amort, '999,999,999.99' ) + ' ' +;
                     tran( getpaytype( OTICKET->paytype ), '@X' ),;
                     tran( if( empty( OTICKET->surety1 ), '~', OTICKET->surety1 ), '@X' ),;
                     tran( if( empty( OTICKET->surety2 ), '~', OTICKET->surety2 ), '@X' ) }
      otherwise
         if OTICKET->ratetype == '1'
            fclty_ := { eval( mfclty, FACILITY->fcltyname ),;
                        'Type', 'Term', 'Effective Rate', '~', 'Payment Frequency', 'Notification', 'Collection',;
                        'Recourse', 'Obligor', 'Collateral', '~', 'Surety', '~' }
            mdata_ := { tran( OTICKET->credamt, '999,999,999.99' ),;
                        tran( gettrantype( OTICKET->trantype ), '@X' ),;
                        tran( OTICKET->term, '999' ) + ' ' +;
                        tran( gettermunit( OTICKET->termunit ), '@X' ),;
                        'Min. spread of ' + tran( OTICKET->truerate, '99.99' )+' %',;
                        'over the average cost of funds',;
                        tran( getpayfreq( OTICKET->payfreq ), '@X' ),;
                        tran( getnotifition( OTICKET->notfctn ), '@X' ),;
                        tran( getcollection( OTICKET->colexion ), '@X' ),;  
                        tran( getrecourse( OTICKET->recourse ), '@X' ),;
                        tran( OTICKET->obligor, '@X' ),;
                        tran( if( empty( OTICKET->unit ), '~', OTICKET->unit ), '@X' ),;
                        tran( if( empty( OTICKET->unit2 ), '~', OTICKET->unit2 ), '@X' ),;
                        tran( if( empty( OTICKET->surety1 ), '~', OTICKET->surety1 ), '@X' ),;
                        tran( if( empty( OTICKET->surety2 ), '~', OTICKET->surety2 ), '@X' ) }
         else
            fclty_ := { eval( mfclty, FACILITY->fcltyname ),;
                        'Net Proceeds', 'Type', 'Term', 'Effective Rate', 'Payment Frequency', 'Amortization',;
                        'Notification', 'Collection', 'Recourse', 'Obligor', 'Collateral', '~', 'Surety', '~' }
            mdata_ := { tran( OTICKET->credamt, '999,999,999.99' ),;
                        tran( OTICKET->proceeds, '999,999,999.99' ),;
                        tran( gettrantype( OTICKET->trantype ), '@X' ),;
                        tran( OTICKET->term, '999' ) + ' ' +;
                        tran( gettermunit( OTICKET->termunit ), '@X' ),;
                        tran( OTICKET->truerate, '99.99' ) + '%',;
                        tran( getpayfreq( OTICKET->payfreq ), '@X' ),;
                        tran( OTICKET->amort, '999,999,999.99' ),;
                        tran( getnotifition( OTICKET->notfctn ), '@X' ),;
                        tran( getcollection( OTICKET->colexion ), '@X' ),;  
                        tran( getrecourse( OTICKET->recourse ), '@X' ),;
                        tran( OTICKET->obligor, '@X' ),;
                        tran( if( empty( OTICKET->unit ), '~', OTICKET->unit ), '@X' ),;
                        tran( if( empty( OTICKET->unit2 ), '~', OTICKET->unit2 ), '@X' ),;
                        tran( if( empty( OTICKET->surety1 ), '~', OTICKET->surety1 ), '@X' ),;
                        tran( if( empty( OTICKET->surety2 ), '~', OTICKET->surety2 ), '@X' ) }
         endif
   endcase   
   return( refine( fclty_, mdata_, maxlen, .f. ) )

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function SEEKAMNT()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   &&local mosbal := seekosbal( OTICKET->clntcode,.t. ), amnt_, maxlen := 1
   local mosbal := seekosbal( OTICKET->BRCODE+OTICKET->clntcode,.t. ), amnt_, maxlen := 1
   local mgrnts := 0, munavail := seekunavail(), mthistran := OTICKET->credamt
   local othrunvl_:={}, mdata_:={},mu,mvp:=0,othrosbal_:={},i,mi
   memvar def_bal                           

   aeval( seekgrup(), { | a_ | mu:= seekosbal( a_, .f. ), if( mu <> nil, aadd(othrosbal_,mu ), nil) } )
   aeval( seekgrup(), { | r_ | mu:= skothrunvl( r_ ), if( mu <> nil, aadd(othrunvl_,mu ), nil) } )
   amnt_ := { 'Balance Outstanding', 'Plus: Other Guarantees', '~', 'Sub-Total',;
              'Unavailed Credit Line', 'This Transaction', '~', 'Total', '~' }
   altd()
   if !empty(othrosbal_)
      mgrnts += othrosbal_[1,1]
   endif
   if len(othrosbal_) > 1
      asize( amnt_, len(amnt_) + len(othrosbal_)-1 )
      for i:= 2 to len(othrosbal_)
              mgrnts += othrosbal_[i,1]
              ains( amnt_, 3 )
              afill( amnt_,'~',3,1 )
      next i
   endif
   def_bal := 0
   def_bal += mosbal + mgrnts + munavail + mthistran
   mi := if( ( len( othrosbal_ ) -1 ) < 0, 0, ( len( othrosbal_ ) - 1 ) )
   if !empty(othrunvl_)
      asize( amnt_, len(amnt_) + len(othrunvl_) )
      for i:= 1 to len( othrunvl_ )
              mvp += othrunvl_[i,1]
              ains( amnt_, mi + 6 )
              afill( amnt_,'~', mi+6,1 )
      next i
   endif
   def_bal += mvp
   aadd(mdata_,tran( mosbal, '999,999,999.99' ) )
   aadd(mdata_,tran( if( !empty( othrosbal_ ),othrosbal_[1,1], 0 ), '999,999,999.99' );
                +' ' + if(!empty( othrosbal_),othrosbal_[1,2 ],' ') )

   if len( othrosbal_ ) > 1
    for i:= 2 to len(othrosbal_)
       mi := 2
       aadd( mdata_, tran( othrosbal_[ i, mi-1 ],'999,999,999.99' )+' ' + othrosbal_[ i,mi ]  )
    next i
   endif

   aadd(mdata_,repl( 'Ä', 14 ) )
   aadd(mdata_,tran( mosbal + mgrnts, '999,999,999.99' ) )
   aadd(mdata_,tran( munavail, '999,999,999.99' ) )

   if !empty( othrunvl_ )
    for i:= 1 to len(othrunvl_)
       mi := 2
       aadd( mdata_, tran( othrunvl_[ i, mi-1 ],'999,999,999.99' )+' ' + othrunvl_[ i,mi ]  )
    next i
   endif

   aadd(mdata_,tran( mthistran, '999,999,999.99' ) )
   aadd(mdata_,repl( 'Ä', 14 ) )
   aadd(mdata_,tran( mvp + mosbal + mgrnts + munavail + mthistran, '999,999,999.99' ) )
   aadd(mdata_,repl( 'Í', 14 ) )

   return( refine( amnt_, mdata_, maxlen, .f. ) )

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function SEEKSIGN( mwhat )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mcolor := setcolor(), mlen, mname_ := {}
   local arr_ := if( mwhat == nil, getcomcode(), mwhat )
   local mpick, mscreen := savescreen( ,,, ), mcol, m_row, m_col
   memvar max_1_comname_length, max_2_comname_length
   memvar msub_1_title, msub_2_title, comm_
   private m_a := 0, m_b := 0, mrow := 1, ach_

   if( mwhat == nil, eval( { || m_row := 5, m_col := 10, 1 } ),;
                        eval( { || m_row := 7, m_col := 18, 2 } ) )
   ach_ := getcomember( arr_[ 1, 1 ] )
   mcol := max( len( arr_[ 1, 2 ] ), len( ach_[ 1 ] ) )
   if( mwhat == nil, msub_1_title := arr_[ 1, 2 ], nil )
   msub_2_title := arr_[ 1, 2 ]

   set device to screen 
   fshadow( m_row, m_col, m_row + 4 + len( ach_ ), m_col + 2 + mcol, 2, 'n/bg' )
   devpos( m_row + 1, m_col + 1 ); devout( propercase( msub_2_title ), 'w+/bg' )
   setcolor( 'gr+/n, n/w,,, gr+/n' )
   while .t.
      board_picture( m_row, m_col, ach_, arr_, mcol )
      mpick := achoice( m_row + 2, m_col + 1, m_row + 2 +;
                  len( ach_ ), m_col + 1 + mcol, ach_, .t., "crd_comm", mrow ) 
      do case
         case lastkey() == K_ENTER
            if arr_[ 1, 3 ] <= m_a .and. arr_[ 1, 4 ] <= m_b
               if len( arr_ ) > 1
                  aeval( ach_, { | a_ | if( subs( a_, 2, 1 ) == chr( 1 ),;
                               aadd( mname_, rtrim( subs( a_, 6 ) ) ), nil ) } )
                  adel( arr_, 1 )
                  aadd( comm_, mname_ )
                  if valtype( arr_[ 1 ] ) != 'U'
                     SEEKSIGN( arr_ )                 
                  else
                     aeval( comm_, { | s_, n | comm_[ n, 1 ] := rtrim( s_[ 1 ] ), n } )
                     aeval( comm_[ 1 ], { | s_ | max_1_comname_length += s_ } )
                     aeval( comm_[ 2 ], { | s_ | max_2_comname_length += s_ } )   
                     max_1_comname_length := len( max_1_comname_length )
                     max_2_comname_length := len( max_2_comname_length )
                  endif   
               else
                  aeval( ach_, { | a_ | if( subs( a_, 2, 1 ) == chr( 1 ),;
                         aadd( comm_, rtrim( subs( a_, 6 ) ) ), nil ) } )
                  aeval( comm_, { | s_, n | comm_[ n ] := rtrim( s_ ), n } )
                  aeval( comm_, { | s_ | max_1_comname_length += s_ } )
                  max_1_comname_length := len( max_1_comname_length )
               endif
            exit
            endif   
         case lastkey() == K_SPACE     
            __keyboard( chr( K_DOWN ) )
            m_a := m_b := 0
            aeval( ach_, { | a_ | if( subs( a_, 2, 1 ) == chr( 1 );
                                  .and. subs( a_, 4, 1 ) == 'A', m_a += 1,;
                                  if( subs( a_, 2, 1 ) == chr( 1 );
                                  .and. subs( a_, 4, 1 ) == 'B', m_b += 1, nil ) ) } )
      endcase
   enddo
   setcolor( mcolor )
   inkey( .3 )
   restscreen( ,,,, mscreen )
   set device to print
   return( comm_ )

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   function crd_comm( a, b, c )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mkey := lastkey(), mTRUE := AC_CONT
   memvar ach_, mrow

   mrow := b
   do case
      case a == AC_HITTOP
         mrow  := len( ach_ )
         mTRUE := AC_ABORT
      case a == AC_HITBOTTOM
         mrow  := 1
         mTRUE := AC_ABORT
      case mkey == K_SPACE
         ach_[ b ] := stuff( ach_[ b ], 2, 1,;
         if( substr( ach_[ b ], 2, 1 ) == chr( 250 ), chr( 1 ), chr( 250 ) ) )
         mTRUE := AC_ABORT           
      case mkey == K_ENTER
         mTRUE := AC_ABORT
   endcase
   return( mTRUE )        

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function board_picture( m_row, m_col, ach_, arr_, mcol )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   memvar m_a, m_b

   dispbegin()
   devpos( m_row + 2 + len( ach_ ), m_col + 2 )
   devout( 'A-' + ltrim( str( arr_[ 1, 3 ] ) ), 'gr+/bg' )
   devpos( m_row + 2 + len( ach_ ), col() + 1 )
   devout( padr( repl( chr( 01 ), m_a ),;
            ( ( m_col + 6 + mcol ) - m_col + 1 ) - 11 ), 'n/bg' )
   devpos( m_row + 3 + len( ach_ ), m_col + 2 )
   devout( 'B-' + ltrim( str( arr_[ 1, 4 ] ) ), 'gr+/bg' )
   devpos( m_row + 3 + len( ach_ ), col() + 1 )
   devout( padr( repl( chr( 01 ), m_b ),;
            ( ( m_col + 6 + mcol ) - m_col + 1 ) - 11 ), 'n/bg' )
   dispend()
   return( nil )

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function getcomcode()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local arr_ := {}
   memvar def_bal

   Comcodes->( dbgotop() )
   Comcodes->( dbeval( { || if( def_bal >= Comcodes->minimum .and.;
                             def_bal <= Comcodes->maximum,;
                             aadd( arr_, { Comcodes->comcode,;
                             rtrim( Comcodes->comname ), Comcodes->reqa,;
                             Comcodes->reqb } ), nil ) },,;
                    { || !Comcodes->( eof() ) } ) )
   if arr_[ 1, 1 ] $ '_03_04'
      Comcodes->( dbseek( '02' ) )  
      asize( arr_, len( arr_ ) + 1 )
      ains( arr_, 1 )
      arr_[ 1 ] := { Comcodes->comcode,;
           rtrim( Comcodes->comname ), Comcodes->reqa, Comcodes->reqb }
   endif   
   return( arr_ )                    
   
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function getcomember( mcode )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local arr_ := {}, maxlen := 1

   Comember->( dbseek( mcode ) )
   Comember->( dbeval( { || aadd( arr_, ' ' + chr( 250 ) + ' ' + rtrim( Comember->grupcode ) +;
                                        ' ' + rtrim( Comember->shortname ) ) },,;
                       { || mcode == Comember->comcode } ) )
   aeval( arr_, { | a_ | maxlen := max( len( rtrim( a_ ) ), maxlen ) } )
   aeval( arr_, { | a_, n | arr_[ n ] := padr( a_, maxlen ) } )
   return( arr_ )

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function refine( arr1_, arr2_, maxlen, mTRUE )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   aeval( arr1_, { | a_ | maxlen := max( len( a_ ), maxlen ) } )
   aeval( arr1_, { | a_, n | arr1_[ n ] := padr( if( rat( '~', a_ ) > 0,;
       '', a_ ), maxlen + 1, if( mTRUE, chr( 32 ), chr( 250 ) ) ) +     ;
                                     ': ' + rtrim( upper( arr2_[ n ] ) ), n } )
   return( arr1_ )       

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function seekosbal( mclntcode, sw )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mosbal := 0, mdbf_ := stackin()
   sw := if( sw == nil, .f., sw )
   dbselectar( 'Acctmast' )
   ordsetfocus( 2 )
   Acctmast->( dbseek( mclntcode ) )
   Acctmast->( dbeval( { || mosbal += Acctmast->osbal },,;
                    { || ACCTMAST->BRCODE+Acctmast->clntcode == mclntcode } ) )
   stackout( mdbf_ )
   if !sw
     if mosbal > 0
       return( { mosbal, getclnme( mclntcode ) } )
     else
       return nil
     endif
   else
     return mosbal
   endif
/*
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function seekgrup()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local arr_ := {}, mdbf_ := stackin(), mgrupcode

   dbselectar( 'Grpmembr' )
   Grpmembr->( dbseek( OTICKET->clntcode ) )
   mgrupcode := Grpmembr->grupcode
   Grpmembr->( ordsetfocus( 1 ) )
   Grpmembr->( dbseek( mgrupcode ) )
   Grpmembr->( dbeval( { || if( Grpmembr->clntcode == OTICKET->clntcode,;
                         nil, aadd( arr_, Grpmembr->clntcode ) ) },,;
                    { || Grpmembr->grupcode == mgrupcode } ) )
   Grpmembr->( ordsetfocus( 2 ) )                    
   stackout( mdbf_ )
   return( arr_ )
*/
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function seekunavail()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mdbf_ := stackin(), mretval := 0,nrec := Oticket->(recno())
   local mtotcaline := 0, mtotavailed := 0, mclntcode := OTICKET->clntcode

   dbselectar( 'Caheader' )
   Caheader->( ordsetfocus( 3 ) )   
   Caheader->( dbseek( mclntcode ) )
   Caheader->( dbeval( { || if( Caheader->actaken == '3', eval( { ||;
                             mtotcaline  += Caheader->caline,;
                             mtotavailed += Caheader->availed } ), nil ) },,;
                    { || Caheader->clntcode == mclntcode } ) )
   mretval := mtotcaline - mtotavailed
   mtotcaline := mtotavailed := 0
   dbselectar( 'OTICKET' )
   OTICKET->( ordsetfocus( 2 ) )
   OTICKET->( dbseek( mclntcode ) )
   OTICKET->( dbeval( { || if( Oticket->(recno()) <> nrec .and. OTICKET->actaken == '3', eval( { ||;
                        mtotcaline  += OTICKET->credamt,;
                        mtotavailed += OTICKET->crdavail } ), nil ) },,;
                   { || OTICKET->clntcode == mclntcode } ) )
   stackout( mdbf_ )            
   return( mretval += ( mtotcaline - mtotavailed ) )           

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function skothrunvl( ncode )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mdbf_ := stackin(), mretval := 0
   local mtotcaline := 0, mtotavailed := 0, mclntcode := ncode

   dbselectar( 'Caheader' )
   Caheader->( ordsetfocus( 3 ) )   
   Caheader->( dbseek( mclntcode ) )
   Caheader->( dbeval( { || if( Caheader->actaken == '3', eval( { ||;
                             mtotcaline  += Caheader->caline,;
                             mtotavailed += Caheader->availed } ), nil ) },,;
                    { || CAHEADER->BRCODE+Caheader->clntcode == mclntcode } ) )
   mretval := mtotcaline - mtotavailed
   mtotcaline := mtotavailed := 0
   dbselectar( 'OTICKET' )
   OTICKET->( ordsetfocus( 2 ) )
   OTICKET->( dbseek( mclntcode ) )
   OTICKET->( dbeval( { || if( OTICKET->actaken == '3', eval( { ||;
                        mtotcaline  += OTICKET->credamt,;
                        mtotavailed += OTICKET->crdavail } ), nil ) },,;
                   { || OTICKET->BRCODE+OTICKET->clntcode == mclntcode } ) )
   stackout( mdbf_ )
   mretval += ( mtotcaline - mtotavailed )
   altd()
   if mretval > 1
      return( { mretval, getclnme( ncode ) } )
   else
      return nil
   endif
/*
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 Static Function getclnme( ncode )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
local mu:=stackin()

dbselectarea('Client')
dbsetorder( 1 )
Client ->( dbseek( ncode ) )
altd()
stackout( mu )
return substr( Client->shrtname, 1, 17 )
*/
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function heading( mTRUE )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mheadmsge := upper( 'offering ticket' )
   memvar gcompany, gsys_name, mPAGE

   if mTRUE
      setfont( upper( "elite" ) )
      devpos( prow() + 1,  0 ); devout( gcompany )
      devpos( prow()    , 70 ); devout( gsys_name )
      devpos( prow() + 1,  0 ); devout( mheadmsge )
      devpos( prow()    , 76 ); devout( date() )
      devpos( prow()    , pcol() + 1 ); devout( time() )
      setfont( upper( "pica" ) )
   else
      if( ( mPAGE++ ) >= 1, eval( { || devpos( prow() + 1, 71 ),;
         devout( 'Page : ' + ltrim( tran( mPAGE, '99' ) ) ) } ), nil )
         devpos( prow() + 1, 0 ); devout( repl( 'Ä', maxcol() ) )    
         setfont( upper( "bold" ) ) 
         devpos( prow() + 1, 11 ); devout( 'OT N§ : ' + OTICKET->otnumber )
         devpos( prow()    , 50 ); devout( 'OT Date : ' + dtoc( OTICKET->otdate ) )
         setfont( upper( "unbold" ) )
         setfont( upper( "pica" ) )   
         devpos( prow() + 1, 0 ); devout( repl( 'Ä', maxcol() ) )       
   endif
   return( nil )

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function devprint( arr_, mTRUE, mfalse, sign_ )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local maxlen := 1, w
   memvar just_once

   mTRUE := if( mTRUE, { || 5 }, { || ( 80 - maxlen ) / 2 } )
   aeval( arr_, { | a_ | maxlen := max( len( a_ ), maxlen ) } ) 
   setfont( upper( if( mfalse, "bold", "pica" ) ) )
   aeval( arr_, { | a_, n | w := a_, if( n == 2, eval( { || setfont( upper( "unbold" ) ),;
                         setfont( upper( "pica" ) ) } ), nil ), if( at( '~', a_ ) > 0,;
                         nil, eval( { || devpos( prow() + 1, eval( mTRUE ) ),;
                         devout( w ), CHKEJECT( sign_, .t. ) } ) ), n } )
   if !mfalse
      just_once := !just_once
   endif                         
   return( nil )	

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function devmemos( mfield, msge, sign_ )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   if !empty( mfield )
      @ prow() + 2, 0 say upper( msge )
      @ prow() + 1, 0 say repl( 'Ä', len( msge ) )
      memo_print( mfield, sign_, msge )
   endif
   return( nil )

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function memo_print( mfield, sign_, msge )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mnum := mlcount( mfield, 76 ), i
   for i := 1 to mnum
      CHKEJECT( sign_, .t. ) 
      @ prow() + 1, 2 say memoline( mfield, 76, i,, .f. )
   next
   // to correct printing of aoname on the last page   (jlb)
   if msge = 'remarks' .and. !the_amount_has_been_printed_recently
      footer()
   endif
   return( nil )

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function footer()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mseek := { | n | Ao->( dbseek( OTICKET->aocode ) ), n } 
   return( eval( { | n | devpos( prow() + 5, 0 ),;
                      devout( repl( 'Ä', len( rtrim( eval( mseek, Ao->aoname ) ) ) ) ),;
                      devpos( prow() + 1, 0 ),;
                      devout( eval( mseek, Ao->aoname ), '@!' ),;
                      devpos( prow() + 1, 0 ),;
                      devout( eval( mseek, Ao->aopost ), '@!' ), n } ) )

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function CHKEJECT( sign_, mTRUE )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local m_1_signees := '', m_2_signees := '', m_1_pad, m_2_pad 
   memvar the_amount_has_been_printed_recently, just_once, msub_2_title
   memvar max_1_comname_length, max_2_comname_length, msub_1_title, mPAGE

   if prow() >= if( the_amount_has_been_printed_recently, 45, 52 )
      footer()
      if the_amount_has_been_printed_recently
         if msub_1_title != msub_2_title
            setfont( upper( "condensed" ) )            
            m_1_pad := ( 70 - max_1_comname_length ) / len( sign_[ 1, 1 ] )
            m_2_pad := ( 70 - max_2_comname_length ) / len( sign_[ 2, 1 ] )
            aeval( sign_[ 1 ], { | s_ | m_1_signees += padr( s_, len( s_ ) + m_1_pad ) } )
            aeval( sign_[ 2 ], { | s_ | m_2_signees += padr( s_, len( s_ ) + m_2_pad ) } )
            devpos( prow() + 1, 0 ); devout( 'Ú' + repl( 'Ä', 69 ) + 'Â' + repl( 'Ä', 69 ) + '¿' )
            devpos( prow() + 1, 0 ); devout( '³' + padc( msub_1_title, 69 ) + '³' + padc( msub_2_title, 69 ) + '³' )
            devpos( prow() + 1, 0 ); devout( 'Ã' + repl( 'Ä', 69 ) + 'Å' + repl( 'Ä', 69 ) + '´' )
            devpos( prow() + 1, 0 ); devout( '³' + repl( ' ', 69 ) + '³' + repl( ' ', 69 ) + '³' )
            devpos( prow() + 1, 0 ); devout( '³' + repl( ' ', 69 ) + '³' + repl( ' ', 69 ) + '³' )
            devpos( prow() + 1, 0 ); devout( '³' + repl( ' ', 69 ) + '³' + repl( ' ', 69 ) + '³' )
            devpos( prow() + 1, 0 ); devout( '³' + padc( rtrim( m_1_signees ), 69 ) + '³' + padc( rtrim( m_2_signees ), 69 ) + '³' )
            devpos( prow() + 1, 0 ); devout( 'À' + repl( 'Ä', 69 ) + 'Á' + repl( 'Ä', 69 ) + 'Ù' )      
            setfont( upper( "pica" ) )
         else
            setfont( upper( "condensed" ) )            
            m_1_pad := ( 140 - max_1_comname_length ) / len( sign_ )
            aeval( sign_, { | s_ | m_1_signees += padr( s_, len( s_ ) + m_1_pad ) } )
            devpos( prow() + 1, 0 ); devout( 'Ú' + repl( 'Ä', 138 ) + '¿' )
            devpos( prow() + 1, 0 ); devout( '³' + padc( msub_1_title, 138 ) + '³' )
            devpos( prow() + 1, 0 ); devout( 'Ã' + repl( 'Ä', 138 ) + '´' )
            devpos( prow() + 1, 0 ); devout( '³' + repl( ' ', 138 ) + '³' )
            devpos( prow() + 1, 0 ); devout( '³' + repl( ' ', 138 ) + '³' )
            devpos( prow() + 1, 0 ); devout( '³' + repl( ' ', 138 ) + '³' )
            devpos( prow() + 1, 0 ); devout( '³' + padc( rtrim( m_1_signees ), 138 )  + '³' )   
            devpos( prow() + 1, 0 ); devout( 'À' + repl( 'Ä', 138 ) + 'Ù' )      
            setfont( upper( "pica" ) )
         endif  
         if !just_once
            the_amount_has_been_printed_recently := !;
            the_amount_has_been_printed_recently
         endif
      endif
      if mTRUE
         fejectpause()      
         heading( .f. )   
      endif   
   endif
   return( nil )

// Eop: AMSM300C.prg //
