/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   colf-iis -- general ledger system                                          ³
³   program idúúamst400b.prg  ( copied from glsr1900.prg )                     ³
³   descriptionúú schedule of depreciation of leased equipment                 ³
³   authorúúúúúúú gener c. singson                                             ³
³   dateúúúúúúúúú 10:54:46ú62am úú 9-6-95                                      ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                             u p d a t e s                                    ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        who        ³       when        ³               why                    ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³       abb         ³     10/19/1999    ³  added more headings                 ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

////
#include 'inkey.ch'
#include 'colf.ch'

////
#xtran mascan_con( <date> )         => { | a | subs( dtos( <date> ), 5, 2 ) == padl( a, 2, '0' ) }

#xtran fiscal_con( <char> )         => { | c | right(c,5) != right( <char>, 5 ) }

#xtran annual_con( <char>, <date> ) => { | c, d | ( val( padr( dtos( <date> ), 6 ) )              >= ;
                                                    val( padr( str( d - 1, 4 ) + '10', 6 ) )   .and. ;
                                                    val( padr( dtos( <date> ), 6 ) )              <= ;
                                                    val( padr( str( d    , 4 ) + '09', 6 ) ) ) .and. ;
                                                    c == right( <char>, 5 ) }
#xtran months_con( <date> )         => { | y, m | padr( dtos( <date> ), 6 ) ==;
                                                  padr( str( y, 4 ) + trim( m ), 6 ) }
////
parameter lacctno
memvar AX_LEVEL, gUSER_ID

*****if !chkpass( procname(), AX_LEVEL, gUSER_ID )
   // until then my luv
*****else
begin sequence
   ******* fOpen1900()
   lacctno := if ( lacctno == nil ,.t.,lacctno )
   if lacctno
      Lcrdepn->(dbsetorder(1))        //
   else
      Lcrdepn->(dbsetorder(2))        // old account number
   endif

   Lcrhead->   ( dbsetorder(3) )
   fMain1900()
   Lcrhead->   ( dbsetorder(1) )
end sequence
//    dbcloseall()
// endif
//__mrelease( '*', .t. )
return

////
static function fMain1900()
local ax := savescreen( ,,, )
priva endmonth := '    ', myear := year( date() ), mfiscal, mprompt := 1, x := .f.// trigger to display acctno acctname matdate and valdate

//ÄÄÄmain loop
fshadow( 15, 50, 18, 62, 2,, ' Option ' )
while  !eval( { | n | fMenu1900() } )
enddo      
return( eval( { | n | restscreen( ,,,, ax ), n } ) )

////
static function fMenu1900()
local menulist, mreturn, mkey := { | k | lastkey() != k }
local mdoit := { | x | reportprint( 'fPrnt1900()', if( mfiscal, nil, '136 Columns' ) ), x }  &&repcontrol( 'fPrnt1900()', if( mfiscal, nil, '136 Columns' ) ), x }
local mtrue := { || if( fFake1900(), eval( mdoit, .f. ), .t. ) }
memvar mfiscal, mprompt

setcolor( 'n/w, w+/n,,, n/w' )
@ 16, 51 prompt '~Month/Year ' message '';
         messagecolor 'w+/n' triggercolor 'w+/w'
@ 17, 51 prompt '~Fiscal Year' message '';
         messagecolor 'w+/n' triggercolor 'w+/w'
menu to mprompt initial mprompt &&timeout 20
mfiscal := if( mprompt == 1, .t., .f. )

if mreturn := eval( mkey, K_ESC )
   //ÄÄÄsubmain loop
   mscreen := savescreen( ,,, )
   while !eval( mtrue ); enddo
   restscreen( ,,,, mscreen )
endif
return( !mreturn )

////
static function fFake1900()
static month_ := { 'Jan-01', 'Feb-02', 'Mar-03', 'Apr-04', 'May-05', 'Jun-06',;
                   'Jul-07', 'Aug-08', 'Sep-09', 'Oct-10', 'Nov-11', 'Dec-12' }
local getlist := {}, bx := setcolor()
memvar mfiscal

fshadow( 10, 20, if( mfiscal, 13, 12 ), 33 )
setcolor( 'n/w, w+/n,,, n/w' )
if mfiscal
   @ 11, 21 say 'Month ¯' gget endmonth                                            ;
            when !empty( eval( { || endmonth := subs( month_[ max(                 ;
                 fAcho1900( 11, 31, 17, 35, month_, endmonth ), 1 ) ], 5, 2 ) } ) );      // no. of months
            valid if( val( endmonth ) >= 1 .and. val( endmonth ) <= 12, !.f., !.t. )      // 1-12 months
   @ 12, 21 say 'Year  ¯' gget myear picture '9999' valid myear >= 1900
else
   @ 11, 21 say 'Year  ¯' gget myear picture '9999' valid myear >= 1900
endif   
setcursor( 3 )
setkey( K_ESC, { || fEscape( 'Abort?' ) } )
read &&timeout 20 exitevent blankscr3( -1 )
setkey( K_ESC, nil ) 
setcursor( 0 )
setcolor( bx )
return( lastkey() != K_ESC )

******************************************************
*
static function fAcho1900( _1, _2, _3, _4, ma_, mb_ )
******************************************************
local max, mzz, mex := setkey( K_ESC, nil ) 
local mxx := 1, mc_, md_ := 1

   mzz := savescreen( _1, _2, _3 + 1, _4 + 2 )
   fshadow( _1, _2, _3, _4, 2, 'n/w' )
   mc_ := if( ( mxx := ascan( ma_, { | v | subs( v, 5, 2 ) == mb_ } ) ) > 0, mxx, mxx )
   max := achoice( _1 + 1, _2 + 1, _3 - 1, _4 - 1, ma_,,, mc_, md_ )
   restscreen( _1, _2, _3 + 1, _4 + 2, mzz )
   setkey( K_ESC, mex )

return( max )

************************
*
function fPrnt1900()
************************
memvar mfiscal
private grd_monthly_total := 0, mpage := 1, mcode := '81371',_gnnetbkvalue := 0
private grd_jan_total := 0, grd_feb_total := 0, grd_mar_total := 0, grd_apr_total := 0,;
        grd_may_total := 0, grd_jun_total := 0, grd_jul_total := 0, grd_aug_total := 0,; 
        grd_sep_total := 0, grd_oct_total := 0, grd_nov_total := 0, grd_dec_total := 0

if mfiscal

   if Lcrdepn->(indexord()) == 2           // OLDNO
      setfont( upper( 'condensed' ) )
   endif

endif

fHead1900 ()
// Lcrdepn-> ( dbgotop() )
// Lcrdepn-> ( dbeval( { || print1900() },, { || !Lcrdepn->(eof()) } ) )
//

_nctr := 1
Lcrdepn-> ( dbseek( g_par_brch ) )
Lcrdepn-> ( dbeval( { || print1900() },,;
                    { || !Lcrdepn->(eof()) .and. ;
                         Lcrdepn->brcode == g_par_brch ;
                    };
                  );
          )
//
//aga.11.07.2005.accounting chief request, by individual branch
//


Print_total()
__eject   ()
return    ( nil )

***************************
*
static function print1900()
***************************
//
// local  mname :={ | n | Lcrhead->( dbseek( LCRDEPN->BRCODE+right( Lcrdepn->acctno, 5 ) ) ), n }
//
local  mname := Lcrhead->( dbseek( LCRDEPN->BRCODE+right( Lcrdepn->acctno, 5 ) ) )
local  nmonth_ := { 10, 11, 12, 1, 2, 3, 4, 5, 6, 7, 8, 9 }, mcol, n_month
local _nnetbkvalue := 0 , _ndepamount   := 0, ndeplife := 0

memvar mfiscal, grd_monthly_total, myear, endmonth,_gnnetbkvalue
memvar grd_jan_total, grd_feb_total, grd_mar_total, grd_apr_total,;
       grd_may_total, grd_jun_total, grd_jul_total, grd_aug_total,; 
       grd_sep_total, grd_oct_total, grd_nov_total, grd_dec_total 
private month_in_word


if mfiscal

//alert( padr( dtos( Lcrhead->matdate), 6 ) )

   if _months_con( Lcrdepn->depdate , myear, endmonth ) .and. ;
      Lcrhead->( dbseek( LCRDEPN->BRCODE+right( Lcrdepn->acctno, 5 ) ) ) //.and. ;      && ONE MONTH ONLY

//aga.12.09.2005.remove, duplicate of previous argument
//      val( padr( dtos( Lcrhead->matdate), 6 ) )  >= val( padr( str( myear, 4 )+ endmonth , 6 ) )
// #xtran months_con( <date> )         => { | y, m | padr( dtos( <date> ), 6 ) == padr( str( y, 4 ) + trim( m ), 6 ) }
	if lcrhead->matdate < ctod(alltrim(endmonth)+'/01/'+alltrim(str(myear)))
		Lcrdepn->(dbskip(+1))
		return
	endif
	
	//alert(dtos(__lastday(dtos(ctod(alltrim(endmonth)+'/'+alltrim(endmonth)+'/'+alltrim(str(myear)))))))
	if lcrhead->valdate > __lastday(dtos(ctod(alltrim(endmonth)+'/'+alltrim(endmonth)+'/'+alltrim(str(myear)))))
		Lcrdepn->(dbskip(+1))
		return
	endif

      fEjec1900 ()
      @ prow() + 1,   4 say LCRHEAD->BRCODE+substr( Lcrhead->acctno,-5, 5 )    picture '@R 999-99999'

      if Acctmast->( dbseek( LCRHEAD->BRCODE+Lcrhead->acctno ) )
         @ prow() ,  pcol()+2 say padr( ACCTMAST->BRCODE+Acctmast->oldno,16 )
      else
         @ prow() ,  pcol()+2 say padr( 'notfound',16 )
      endif

      @ prow()    ,  pcol()+2 say padr ( dispclntname( LCRHEAD->BRCODE+Lcrhead->clntcode, 35 ),30-9) picture '@!'
      @ prow()    ,  pcol()+2 say Lcrhead->valdate                   picture '@D'
      @ prow()    ,  pcol()+2 say Lcrhead->matdate                   picture '@D'
      @ prow()    ,  pcol()+2 say Lcrdepn->depamount                 picture '@Z 99,999,999.99'

      grd_monthly_total += Lcrdepn->depamount

      @ prow(),pcol() + 2 say trans ( _get_maturity ( Lcrhead->matdate,;
                                                Lcrhead->valdate,;
                                                Lcrhead->term,;
                                                Lcrhead->termunit ;
                                              ),;
                                '@D' ;
                              )

      _nnetbkvalue  := 0
      _ndepamount   := round ( Lcrhead->principal - round ( ( Lcrhead->rv / 100 * Lcrhead->Principal ),2 ), 0)

      _nnetbkvalue  := _get_netbook_val(LCRHEAD->BRCODE+Lcrhead->acctno,endmonth,myear)  //// Lcrhead->netbookval

      @ prow()  ,pcol()+2+6 say trans ( _nnetbkvalue,'999,999,999.99' )

      if Asetcode->(dbseek(Lcrhead->asetcode))
         ndeplife := round( Asetcode->asetlife * 12 * 0.60,0 )
         ndeplife := max ( Lcrhead->term,ndeplife )
      endif

      @ prow(),pcol()+2 say padr( Asetcode->asetname,25 )
      @ prow(),pcol()+2 say trans( Lcrhead->principal,'999,999,999.99' )
      @ prow(),pcol()+2 say trans( Lcrhead->rv/100*Lcrhead->principal ,'999,999,999.99' )
      @ prow(),pcol()+4 say trans( Lcrhead->term     ,'999' )
      @ prow(),pcol()+4 say trans( Asetcode->asetlife*12,'999' )+' months'
      @ prow(),pcol()+2 say trans( ndeplife,'999' )

      _gnnetbkvalue     += _nnetbkvalue

   endif

else     && ALL MONTHS IN THE FISCAL YEAR

   if eval( fiscal_con( Lcrdepn->acctno ), mcode ) .and. ;
      Lcrhead->( dbseek( LCRDEPN->BRCODE+right( Lcrdepn->acctno, 5 ) ) ) //.and. ;

//aga.12.09.2005.remove, duplicate of previous argument
//      val( padr( dtos( Lcrhead->matdate), 6 ) )  >= val( padr( str( myear - 1, 4 ) + '10', 6 ) )
//#xtran fiscal_con( <char> )         => { | c | right(c,5) != right( <char>, 5 ) }

      mcode := Lcrdepn->brcode+right( Lcrdepn->acctno, 5 )
		if lcrhead->matdate < ctod('10/01/'+alltrim(str(myear-1)))
			Lcrdepn->(dbskip(+1))
			return
		endif
	
		if lcrhead->valdate > ctod('09/30/'+alltrim(str(myear)))
			Lcrdepn->(dbskip(+1))
			return
		endif
      fEjec1900()   
//       @ prow() + 1,   6 say LCRDEPN->BRCODE+right( Lcrdepn->acctno, 5 )        picture '@R 999-99999'
		x := .t.
      //@ prow() + 1,   6 say right( Lcrdepn->acctno, 5 )        picture '@R 99999'

     // if Acctmast->(dbseek(LCRHEAD->BRCODE+Lcrhead->acctno))
     //    @ prow() ,  12 say right(alltrim(Acctmast->oldno),6)
     // else
     //    @ prow() ,  pcol()+2 say '!Found'
     // endif

     // @ prow()    ,  21 say padr ( dispclntname( LCRHEAD->BRCODE+Lcrhead->clntcode, 35 ),30-9) picture '@!'
     // @ prow()    ,  43 say Lcrhead->valdate    picture '@D'
     // @ prow()    ,  54 say Lcrhead->matdate    picture '@D'

/*
      @ prow()    ,  pcol()+2 say padr ( dispclntname( LCRHEAD->BRCODE+Lcrhead->clntcode ),30-9) picture '@!'
      @ prow()    ,  pcol()+2 say Lcrhead->valdate    picture '@D'
      @ prow()    ,  pcol()+2 say Lcrhead->matdate    picture '@D'
*/

   endif


/*
****
****   if eval( annual_con( Lcrdepn->acctno, Lcrdepn->depdate ), mcode, myear ) .and. ;
****

//   if eval( annual_con( Lcrdepn->acctno, Lcrdepn->depdate ), mcode, myear ) .and. ;

   if _annual_con( Lcrdepn->acctno,Lcrdepn->depdate, mcode,myear ) .and. ;
      Lcrhead->( dbseek( Lcrdepn->BRCODE+substr( Lcrdepn->acctno, -5,5 ) ) )

//      Lcrhead->( dbseek( Lcrdepn->BRCODE+right( Lcrdepn->acctno, 5 ) ) )

      if ( n_month := ascan( nmonth_, { | m | eval( mascan_con( Lcrdepn->depdate ), m ) } ) ) > 0  .and. ;
         Lcrhead->( dbseek( LCRDEPN->BRCODE+substr( Lcrdepn->acctno, -5,5 ) ) )  

//         Lcrhead->( dbseek( LCRDEPN->BRCODE+right( Lcrdepn->acctno, 5 ) ) )

         mcol          := 51 + 14 * n_month

         month_in_word := subs( lower( cmonth( ctod( padl( nmonth_[ n_month ], 2, '0' ) + '/01/01' ) ) ), 1, 3 )
         grd_&month_in_word._total += Lcrdepn->depamount

//         @ prow(), mcol say Lcrdepn->depamount picture '@Z 99,999,999.99'
*****         @ prow()+1, 10 say Lcrdepn->depamount picture '@Z 99,999,999.99'

         @ prow(), mcol say Lcrdepn->depamount picture '@Z 99,999,999.99'

*/


   if _annual_con( Lcrdepn->acctno,Lcrdepn->depdate, mcode,myear ) .and. ;
      Lcrhead->( dbseek( Lcrdepn->BRCODE+substr( Lcrdepn->acctno, -5,5 ) ) )

      if ( n_month := ascan( nmonth_, { | m | eval( mascan_con( Lcrdepn->depdate ), m ) } ) ) > 0  .and. ;
         Lcrhead->( dbseek( LCRDEPN->BRCODE+substr( Lcrdepn->acctno, -5,5 ) ) )  

         mcol          := 51 + 14 * n_month
         month_in_word := subs( lower( cmonth( ctod( padl( nmonth_[ n_month ], 2, '0' ) + '/01/01' ) ) ), 1, 3 )
		 
		 
		 
		 //**************************************chi
		 
		 if lcrhead->matdate < ctod('10/01/'+alltrim(str(myear-1)))
			Lcrdepn->(dbskip(+1))
			return
		endif
	
		if lcrhead->valdate > ctod('09/30/'+alltrim(str(myear)))
			Lcrdepn->(dbskip(+1))
			return
		endif
		
		if x
			@ prow() + 1,   6 say right( Lcrdepn->acctno, 5 )        picture '@R 99999'
			if Acctmast->(dbseek(LCRHEAD->BRCODE+Lcrhead->acctno))
				@ prow() ,  12 say right(alltrim(Acctmast->oldno),6)
			else
				@ prow() ,  pcol()+2 say '!Found'
			endif
			@ prow()    ,  21 say padr ( dispclntname( LCRHEAD->BRCODE+Lcrhead->clntcode, 35 ),30-9) picture '@!'
			@ prow()    ,  43 say Lcrhead->valdate    picture '@D'
			@ prow()    ,  54 say Lcrhead->matdate    picture '@D'
			x := .f.
		endif
		 //*************************************
		 grd_&month_in_word._total += Lcrdepn->depamount
         @ prow(), mcol say Lcrdepn->depamount picture '@Z 99,999,999.99'


      endif

   endif

endif

return( nil )

*********************************************************
*
static function _months_con( __ddate, __y,__m )
*********************************************************
local lretval := .f.

** alert ( 'dtos(__ddate) := ' + dtos(__ddate) )
** alert ( 'padr( dtos( __ddate ), 6 ):= ' + padr( dtos( __ddate ), 6 ) )
** alert ( 'padr( str( __y, 4 ) + trim( __m ), 6 ) := '+ padr( str( __y, 4 ) + trim( __m ), 6 ) )

   if padr( dtos( __ddate ), 6 ) == padr( str( __y, 4 ) + trim( __m ), 6 )
      lretval := .t.
   endif

return lretval

*********************************************************
*
static function _annual_con( __cchar, __ddate, __cc,__dd )
*********************************************************
   local lretval := .f.


   if val( padr( dtos( __ddate), 6 ) )  >= val( padr( str( __dd - 1, 4 ) + '10', 6 ) ) .and. ;
      val( padr( dtos( __ddate ), 6 ) )  <= val( padr( str( __dd    , 4 ) + '09', 6 ) ) .and. ;
      right(__cc,5) == right( __cchar, 5 )
      lretval := .t.
   endif

return lretval


***************************************************************
static function _get_netbook_val( cacctno,cendmonth,nyear )
***************************************************************
   local nretval  := 0,nrecno := Lcrdepn->(recno())
   local clastday, _enddate
   local ndepamt

   do case
      case alltrim(cendmonth) $  '_01_03_05_07_08_10_12'
           clastday := '31'
      case alltrim(cendmonth) $  '_04_06_09_11'
           clastday := '30'
      case alltrim(cendmonth) == '02'
//           if month( ctod('02/28'+alltrim(str(nyear))) ) + 1 == 3
           if nyear/4 <> int(nyear/4)
              clastday := '28'
           else
              clastday := '29'
           endif
   endcase

   _enddate := ctod( right( '0'+alltrim(cendmonth),2 ) +'/'+clastday+'/'+str(nyear) )

//   alert ( Lcrdepn->(indexkey()) )
//                      001    0301 10301 00041
//    if Lcrdepn->(dbseek( LEFT(cacctno,3)+substr(cacctno,-8,5) ))   && RED 11122004 REPLACED -5 WITH -8
//
 
   if Lcrdepn->(dbseek( LEFT(cacctno,3)+substr(cacctno,-5,5) ))   && RED 11122004 REPLACED -5 WITH -8  //aga.11.07.2005.reverted to -5, -8 returns extra long string

      if empty(Lcrhead->ptermdate)

         do while LCRDEPN->BRCODE+substr(Lcrdepn->acctno,-5,5) == LEFT(cacctno,3)+substr(cacctno,-5,5)  .and. ;    && RED 11122004 REPLACED -5 WITH -8 //aga.11.07.2005.reverted to -5, -8 returns extra long string
                 !Lcrdepn->(eof())

            if Lcrdepn->depdate <= _enddate
               nretval += round(Lcrdepn->depamount,2)
            endif

            Lcrdepn->(dbskip(+1))
         enddo


         ndepamt := round( Lcrhead->principal - round( Lcrhead->rv / 100 * Lcrhead->Principal ,2 ), 2 )
         nretval := ndepamt - nretval

//////        if substr(Lcrhead->acctno,-5,5) == '00721'
/////            alert ( str(ndepamt)+'*'+ str(nretval) )
/////         endif

      else

         nretval := 0
         if Lcrhead->ptermdate > _enddate

            do while LCRDEPN->BRCODE+substr(Lcrdepn->acctno,-5,5) == LEFT(cacctno,3)+substr(cacctno,-5,5)  .and. ;   && RED 11122004 REPLACED -5 WITH -8 //aga.11.07.2005.reverted to -5, -8 returns extra long string
                    !Lcrdepn->(eof())

               if Lcrdepn->depdate <= _enddate
                  nretval += round(Lcrdepn->depamount,2)
               endif
               Lcrdepn->(dbskip(+1))
            enddo

            ndepamt := round( Lcrhead->principal - round( Lcrhead->rv / 100 * Lcrhead->Principal ,2 ), 2 )
            nretval := ndepamt - nretval
         endif

      endif

   endif

   Lcrdepn->(dbgoto(nrecno))

return nretval

////
static function Print_total()
local  nmonth_ := { 10, 11, 12, 1, 2, 3, 4, 5, 6, 7, 8, 9 }, mcol, n_month
local  _ntotal := 0
memvar mfiscal, grd_monthly_total,_gnnetbkvalue
memvar grd_jan_total, grd_feb_total, grd_mar_total, grd_apr_total,;
       grd_may_total, grd_jun_total, grd_jul_total, grd_aug_total,; 
       grd_sep_total, grd_oct_total, grd_nov_total, grd_dec_total 
private month_in_word      

if mfiscal

/*   month_in_word := subs( lower( cmonth( ctod( padl( nmonth_[ 11 ], 2, '0' ) + '/01/01' ) ) ), 1, 3 )
   _ntotal := grd_&month_in_word._total

   alert ( 'grand total := ' + str(_ntotal) )
*/

   fEjec1900()                      
   @ prow() + 1, 76 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄ'+space(15)+'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   fEjec1900()   
   @ prow() + 1, 75     say grd_monthly_total picture '@Z 999,999,999.99'
   @ prow()  ,pcol()+20 say _gnnetbkvalue     picture '999,999,999,999.99'
   fEjec1900()   
   @ prow() + 1, 76 say 'ÍÍÍÍÍÍÍÍÍÍÍÍÍ'+space(15)+'ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ'

else
   fEjec1900()                      
   @ prow() + 1, 65 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   fEjec1900()   
   @ prow() + 1, 12 say 'Grand Total'
   for n_month := 1 to 12
       month_in_word := subs( lower( cmonth( ctod( padl( nmonth_[ n_month ], 2, '0' ) + '/01/01' ) ) ), 1, 3 )   
***       @ prow(), 51 + 14 * n_month say grd_&month_in_word._total picture '@Z 99,999,999.99'
       @ prow(), 51 + 14 * n_month say grd_&month_in_word._total picture '999,999,999.99'
   next
   fEjec1900()   
   @ prow() + 1, 65 say 'ÍÍÍÍÍÍÍÍÍÍÍÍÍ ÍÍÍÍÍÍÍÍÍÍÍÍÍ ÍÍÍÍÍÍÍÍÍÍÍÍÍ ÍÍÍÍÍÍÍÍÍÍÍÍÍ ÍÍÍÍÍÍÍÍÍÍÍÍÍ ÍÍÍÍÍÍÍÍÍÍÍÍÍ ÍÍÍÍÍÍÍÍÍÍÍÍÍ ÍÍÍÍÍÍÍÍÍÍÍÍÍ ÍÍÍÍÍÍÍÍÍÍÍÍÍ ÍÍÍÍÍÍÍÍÍÍÍÍÍ ÍÍÍÍÍÍÍÍÍÍÍÍÍ ÍÍÍÍÍÍÍÍÍÍÍÍÍ' 
endif                     
return( nil )

////
static function fHead1900()
local mfiscalyear := if( val( endmonth ) >= 12, 1, 0 )
local nummonth := ctod( endmonth + '/01/' + str( myear, 4 ) )
local mnoequal := { | x | month( nummonth ) != x }, lenmonth
local chrmonth := ctod( padl( month( nummonth ) + if( eval( mnoequal, 12 ), 1, 0 ), 2, 0 ) +;
      if( eval( mnoequal, 12 ), '/01/', '/30/' ) + str( myear - mfiscalyear, 4 ) ) - if( eval( mnoequal, 12 ), 1, 0 )       
local mcmonth := { | l | padc( cmonth( nummonth ), l ) }
local _cmonth
memvar gSYS_NAME, gCOMPANY, mpage, dit, endmonth, myear, mfiscal              

if mfiscal
//    lenmonth := upper( cmonth( chrmonth ) + ' ' + subs( dtoc( chrmonth ), 4, 2 ) + ', ' + str( year( chrmonth ), 4 ) )
   lenmonth := upper( cmonth( chrmonth ) + ' ' + subs( dtoc( chrmonth ), 4, 2 ) + ', ' + ltrim( str ( myear, 4 ) )) // abb 01.25.2002
else
   lenmonth := 'FISCAL YEAR OCTOBER ' + ltrim( str( myear - 1, 4 ) ) + ' TO SEPTEMBER ' + ltrim( str( myear, 4 ) )
endif      
setfont( upper( 'init' ) )

if mfiscal
   prnreptitle( 80, 0, mpage++, 'SCHEDULE OF DEPRECIATION OF LEASED EQUIPMENT', 'amst400b', gSYS_NAME, gCOMPANY )
   @ prow() + 1, ( 80 - len( lenmonth ) ) / 2 say lenmonth
   @ prow() + 1, 2 say ''
   // setfont( upper( 'normal' ) )
   setfont( upper( 'condensed' ) )
   _cmonth := eval( mcmonth, 13 )
/*
   @ prow() + 1, 3 say 'ÚÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
   @ prow() + 1, 3 say '³Acct.³                                         ³Execution ³ Maturity ³               ³'+' Depr.      ³   NetBook   ³'
   @ prow() + 1, 3 say '³  N§ ³              Account Name               ³   Date   ³   Date   ³' + _cmonth+'  ³'+' Mat. Date  ³   Value     ³'
   @ prow() + 1, 3 say 'ÀÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
*/
   @ prow() + 1, 3 say 'ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄ¿'
   @ prow() + 1, 3 say '³         ³                                         ³Execution ³ Maturity ³               ³ Depr.          ³   NetBook      ³   Equipment             ³ Cost of       ³ Residual      ³ Lease      ³Asset  ³Depr.³'
   @ prow() + 1, 3 say '³Acct. N§ ³              Account Name               ³   Date   ³   Date   ³'+_cmonth + '  ³ Mat. Date      ³   Value        ³   Type                  ³ Equipment     ³ Value         ³ Term       ³Life   ³Life ³'
   @ prow() + 1, 3 say 'ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÙ'

else
   prnreptitle( 136, 0, mpage++, 'SCHEDULE OF DEPRECIATION OF LEASED EQUIPMENT', 'amst400b', gSYS_NAME, gCOMPANY )
   @ prow() + 1, ( 136 - len( lenmonth ) ) / 2 say lenmonth
   @ prow() + 1, 5 say ''
   setfont( upper( 'pica' ) )
   setfont( upper( 'condensed' ) )
   @ prow() + 1, 5 say 'ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
   @ prow() + 1, 5 say '³         ³                              ³Execution ³ Maturity ³             ³             ³             ³             ³             ³             ³             ³             ³             ³             ³             ³             ³'
   @ prow() + 1, 5 say '³Acct. N§ ³         Account Name         ³   Date   ³   Date   ³   October   ³  November   ³  December   ³   January   ³  February   ³    March    ³    April    ³     May     ³    June     ³    July     ³   August    ³  September  ³'
   @ prow() + 1, 5 say 'ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
endif
   
return( nil )

////
static function fEjec1900()

if prow() >= 55
   __eject()
   fHead1900()   
endif
return( nil )   


/****************
////
static function fOpen1900()

if !netuse( '&g_AMS_PATH\Acctmast', .f., 10 )   // account master
   break 
else 
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_AMS_PATH\Acctsub2' )         // set index on right( acctno, 5 ) + dtos( depdate )
endif 

if !netuse( '&g_AMS_PATH\Lcrdepn', .f., 10 )    // lease contract receivable depreciation
   break 
else 
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_AMS_PATH\Lcrdepn'  )  // set index on right( acctno, 5 ) + dtos( depdate )
   ordlistadd( '&g_AMS_PATH\Lcrdepn2' )  // set index on oldno + dtos( depdate )
endif

****************/
/*
*****************************************
static function dispclntname( mclntcode )
*****************************************
return eval ({ |x,y| x:= savedbf ( x ), Client->( dbsetorder(1) ),;
                     Client->( dbseek(mclntcode) ), y:= left( Client->FULLNAME, 35 ),;
                     restdbf( x ), y })
*/
////

****************************************
*
static function __lastday(nstartmonth)
****************************************
   local cmonth,cyear,cstartmonth

   cstartmonth := alltrim(nstartmonth)

   cmonth := right(cstartmonth,2)
   cyear  := left(cstartmonth,4)

   tdate := ctod( right('0'+cmonth,2)+'/01/'+cyear)

   do case
      case month(tdate) == 1 .or. month(tdate) == 3  .or. ;
           month(tdate) == 5 .or. month(tdate) == 7  .or. ;
           month(tdate) == 8 .or. month(tdate) == 10 .or. ;
           month(tdate) == 12
           tdate := ctod( right('0'+cmonth,2)+'/31/'+cyear)
      case month(tdate) == 4 .or. month(tdate) == 6  .or. ;
           month(tdate) == 9 .or. month(tdate) == 11
           tdate := ctod( right('0'+cmonth,2)+'/30/'+cyear)
      otherwise
           tdate := ctod( right('0'+cmonth,2)+'/28/'+cyear)
           if month(tdate+1) == 2
              tdate := ctod( right('0'+cmonth,2)+'/29/'+cyear)
           endif

   endcase
return tdate

#stdout end of 'schedule of depreciation of leased equipment ( amst400b.prg )'
