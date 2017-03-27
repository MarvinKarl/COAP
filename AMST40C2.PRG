/*
 здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
 Ё   colf-iis -- general ledger system                                      Ё
 Ё   program idЗЗamst400c.prg  ( copied from amst400b.prg )                 Ё
 Ё   descriptionЗЗ schedule of depreciation of leased equipment (AS OF ...) Ё
 Ё   authorЗЗЗЗЗЗЗ gener c. singson                                         Ё
 Ё   dateЗЗЗЗЗЗЗЗЗ 10:54:46З62am ЗЗ 9-6-95                                  Ё
 цдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
 Ё                             u p d a t e s                                Ё
 цдддддддддддддддддддбдддддддддддддддддддбдддддддддддддддддддддддддддддддддд╢
 Ё        who        Ё       when        Ё               why                Ё
 цдддддддддддддддддддедддддддддддддддддддедддддддддддддддддддддддддддддддддд╢
 Ё                   Ё                   Ё                                  Ё
 юдддддддддддддддддддадддддддддддддддддддадддддддддддддддддддддддддддддддддды
*/

////
#include 'inkey.ch'
#include 'colf.ch'

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
return

////
static function fMain1900()
local ax := savescreen( ,,, )
priva endmonth := '    ', myear := year( date() ), mfiscal, mprompt := 1
private _ddate  := ctod('')
   //дддmain loop
   while  !eval( { | n | fMenu1900() } )
   enddo
return( eval( { | n | restscreen( ,,,, ax ), n } ) )

////
static function fMenu1900()
local menulist, mreturn, mkey := { | k | lastkey() != k }
local mdoit := { | x | reportprint( 'fPrnt40c2()', if( mfiscal, nil, '136 Columns' ) ), x }   &&repcontrol( 'fPrnt40c2()', if( mfiscal, nil, '136 Columns' ) ), x }
local mtrue := { || if( fFake1900(), eval( mdoit, .f. ), .t. ) }

memvar mfiscal, mprompt

/*************
setcolor( 'n/w, w+/n,,, n/w' )
@ 16, 51 prompt '~Month/Year ' message '';
         messagecolor 'w+/n' triggercolor 'w+/w'
@ 17, 51 prompt '~Fiscal Year' message '';
         messagecolor 'w+/n' triggercolor 'w+/w'
menu to mprompt initial mprompt timeout 20
**************/

mprompt := 1
mfiscal := if( mprompt == 1, .t., .f. )  
mreturn := eval( mkey, K_ESC )
if mreturn
   //дддsubmain loop
   mscreen := savescreen( ,,, )
   while !eval( mtrue ); enddo
   restscreen( ,,,, mscreen )
endif
return( !mreturn )

////
static function fFake1900()
static  month_  := { 'Jan-01', 'Feb-02', 'Mar-03', 'Apr-04', 'May-05', 'Jun-06',;
                     'Jul-07', 'Aug-08', 'Sep-09', 'Oct-10', 'Nov-11', 'Dec-12' ;
                   }
local   getlist := {}, bx := setcolor()
memvar mfiscal,_ddate


mfiscal := .t.
fshadow( 10, 20, 12, 52 )
setcolor( 'n/w, w+/n,,, n/w' )

@ 11, 21 say 'As of Report Date  ╞' gget _ddate  picture '@D' valid myear >= 1900
   
setcursor ( 3 )
setkey    ( K_ESC, { || fEscape( 'Abort?' ) } )
read timeout 20 exitevent blankscr3( -1 )
setkey    ( K_ESC, nil )
setcursor ( 0 )
setcolor  ( bx )
return ( lastkey() != K_ESC )

////
static function fAcho1900( _1, _2, _3, _4, ma_, mb_ )
local max, mzz, mex := setkey( K_ESC, nil ) 
local mxx := 1, mc_, md_ := 1

mzz := savescreen( _1, _2, _3 + 1, _4 + 2 )
fshadow( _1, _2, _3, _4, 2, 'n/w' )
mc_ := if( ( mxx := ascan( ma_, { | v | subs( v, 5, 2 ) == mb_ } ) ) > 0, mxx, mxx )
max := achoice( _1 + 1, _2 + 1, _3 - 1, _4 - 1, ma_,,, mc_, md_ ) 
restscreen( _1, _2, _3 + 1, _4 + 2, mzz ) 
setkey( K_ESC, mex )
return( max )

////
function fPrnt40c2()
memvar mfiscal,_ddate
private grd_monthly_total := 0, mpage := 1, mcode := '81371',_gnnetbkvalue := 0
private grd_jan_total := 0, grd_feb_total := 0, grd_mar_total := 0, grd_apr_total := 0,;
        grd_may_total := 0, grd_jun_total := 0, grd_jul_total := 0, grd_aug_total := 0,; 
        grd_sep_total := 0, grd_oct_total := 0, grd_nov_total := 0, grd_dec_total := 0

******* if mfiscal
*******
*******   if Lcrdepn->(indexord()) == 2
*******      setfont( upper( 'condensed' ) )
*******   endif
*******endif

/************
   Lcrdepn-> ( dbgotop() )
   Lcrdepn-> ( dbeval( { || print1900() },,;
                       { || !Lcrdepn->(eof()) } ) )
************/

fHead1900   ()
Lcrhead->   ( dbgotop () )
Lcrhead->   ( dbeval  ( { || print1900() },,;
                        { || !Lcrhead->(eof()) } ;
                      );
            )
Print_total ()
__eject     ()
return      ( nil )

////
static function print1900()
  local  nmonth_ := { 10, 11, 12, 1, 2, 3, 4, 5, 6, 7, 8, 9 }, mcol, n_month
  local _nnetbkvalue := 0 , _ndepamount   := 0,ndeplife := 0
  memvar _ddate
  memvar mfiscal, grd_monthly_total, myear, endmonth,_gnnetbkvalue
  memvar grd_jan_total, grd_feb_total, grd_mar_total, grd_apr_total,;
         grd_may_total, grd_jun_total, grd_jul_total, grd_aug_total,;
         grd_sep_total, grd_oct_total, grd_nov_total, grd_dec_total
  private month_in_word

  myear    := year(_ddate)
  endmonth := right( '0'+alltrim(str(month(_ddate))),2 )

  _nnetbkvalue  := 0
  _ndepamount   := round ( Lcrhead->principal - round ( ( Lcrhead->rv / 100 * Lcrhead->Principal ),2 ), 0)
  _nnetbkvalue  := _get_netbook_val ( Lcrhead->acctno )  //// Lcrhead->netbookval

  if _nnetbkvalue > 10

     fEjec1900 ()
     @ prow() + 1, 4 say  substr( Lcrhead->acctno,-5, 5 )  pict '@R 99999'

     if Acctmast->( dbseek( Lcrhead->acctno ) )
        @ prow() ,  pcol()+2 say padr( Acctmast->oldno,16 )
     else
        @ prow() ,  pcol()+2 say padr( 'notfound',16 )
     endif

     @ prow()    ,  pcol()+2 say padr ( dispclntname( Lcrhead->BRCODE+Lcrhead->clntcode, 35 ),30-9) picture '@!'
     @ prow()    ,  pcol()+2 say Lcrhead->valdate     picture '@D'
     @ prow()    ,  pcol()+2 say Lcrhead->matdate     picture '@D'

     @ prow(),pcol() + 2 say trans ( _get_maturity ( Lcrhead->matdate,;
                                               Lcrhead->valdate,;
                                               Lcrhead->term,;
                                               Lcrhead->termunit ;
                                             ),;
                               '@D' ;
                             )


     @ prow()  ,pcol()+2 say trans ( _nnetbkvalue,'999,999,999.99' )

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

     grd_monthly_total += Lcrdepn->depamount
     _gnnetbkvalue     += _nnetbkvalue

  endif

return( nil )

********************************************
*
static function _get_netbook_val( cacctno )
********************************************
   local nretval  := 0,nrecno := Lcrdepn->(recno())
   local clastday, _enddate
   local ndepamt
   memvar _ddate

   _enddate := _ddate

   if Lcrdepn->(dbseek(substr(cacctno,-5,5)))

      if empty(Lcrhead->ptermdate)

         do while substr(Lcrdepn->acctno,-5,5) == substr(cacctno,-5,5)  .and. ;
                 !Lcrdepn->(eof())

            if Lcrdepn->depdate <= _enddate
               nretval += round(Lcrdepn->depamount,2)
            endif

            Lcrdepn->(dbskip(+1))
         enddo

         ndepamt := round( Lcrhead->principal - round( Lcrhead->rv / 100 * Lcrhead->Principal ,2 ), 2 )
         nretval := ndepamt - nretval

      else

         nretval := 0
         if Lcrhead->ptermdate > _enddate

            do while substr(Lcrdepn->acctno,-5,5) == substr(cacctno,-5,5) .and.;
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
   else
      alert ( "NOT FOUND IN LCRDEPN " + Lcrhead->acctno )
   endif

   Lcrdepn->(dbgoto(nrecno))

return nretval

////
static function Print_total()
local  nmonth_ := { 10, 11, 12, 1, 2, 3, 4, 5, 6, 7, 8, 9 }, mcol, n_month
memvar mfiscal, grd_monthly_total,_gnnetbkvalue
memvar grd_jan_total, grd_feb_total, grd_mar_total, grd_apr_total,;
       grd_may_total, grd_jun_total, grd_jul_total, grd_aug_total,; 
       grd_sep_total, grd_oct_total, grd_nov_total, grd_dec_total 
private month_in_word      

   fEjec1900 ()
   @ prow    () + 1, 88 say 'ддддддддддддд-'
   fEjec1900 ()
   @ prow()+1  ,88  say _gnnetbkvalue     picture '999,999,999.99'

   fEjec1900 ()
   @ prow() + 1    , 88 say 'мммммммммммммм'
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
memvar gSYS_NAME, gCOMPANY, mpage, dit, endmonth, myear, mfiscal,_ddate

   chrmonth := 'As of '+ upper(cmonth( _ddate ) )+ ' '+ ltrim ( str(day(_ddate)) )+', '+ltrim(str(year(_ddate)))
   setfont( upper( 'init' ) )

   prnreptitle   ( 80, 0, mpage++, 'Schedule of Depreciation of Leased Equipment', 'AMST400C', gSYS_NAME, gCOMPANY )
   @ prow() + 1, ( 80 - len( chrmonth ) ) / 2 say chrmonth
   @ prow() + 1, ( 80 - len( 'SGV Format' ) ) / 2 say 'SGV Format'
   @ prow() + 1, 2 say ''
   // setfont( upper( 'normal' ) )
   setfont( upper( 'condensed' ) )
   _cmonth := eval( mcmonth, 13 )
   @ prow() + 1, 3 say 'здддддбдддддддддддддддддддддддддддддддддддддддддбддддддддддбддддддддддбддддддддддддбддддддддддддддддбдддддддддддддддддддддддддбдддддддддддддддбдддддддддддддддбддддддбдддддддддддддбддддд©'
   @ prow() + 1, 3 say 'ЁAcct.Ё                                         ЁExecution Ё Maturity Ё'+' Depr.      Ё   NetBook      Ё   Equipment             Ё Cost of       Ё Residual      Ё LeaseЁ Asset       ЁDepr.Ё'
   @ prow() + 1, 3 say 'Ё  N╖ Ё              Account Name               Ё   Date   Ё   Date   Ё'+' Mat. Date  Ё   Value        Ё   Type                  Ё Equipment     Ё Value         Ё Term Ё Life        ЁLife Ё'
   @ prow() + 1, 3 say 'юдддддадддддддддддддддддддддддддддддддддддддддддаддддддддддаддддддддддаддддддддддддаддддддддддддддддадддддддддддддддддддддддддадддддддддддддддадддддддддддддддаддддддадддддддддддддаддддды'

return( nil )

////
static function fEjec1900()

if prow() >= 55
   __eject()
   fHead1900()   
endif
return nil

/********************************

static function fOpen1900()

if !netuse( 'Acctmast', .f., 10 )   // account master
   break 
else 
   if !.f.
      ordlistclear()
   endif
   ordlistadd( 'Acctsub2' )         // set index on right( acctno, 5 ) + dtos( depdate )
endif 

if !netuse( '&g_AMS_PATH\Lcrdepn', .f., 10 )    // lease contract receivable depreciation
   break 
else 
   if !.f.
      ordlistclear()
   endif
   ordlistadd( '&g_AMS_PATH\Lcrdepn'  )  // set index on right( acctno, 5 ) + dtos( depdate )
   ordlistadd( '&g_AMS_PATH\Lcrdepn2' )  // set index on oldno + dtos( depdate )
endif

****************/
/*
*****************************************
*
static function dispclntname( mclntcode )
*****************************************
return eval ({ |x,y|                                 ;
               x:= savedbf ( x )                    ,;
               Client-> ( dbsetorder ( 1 ) )        ,;
               Client-> ( dbseek     ( mclntcode) ) ,;
               y:= left ( Client->FULLNAME, 35 )    ,;
               restdbf  ( x )                       ,;
               y                                     ;
             };
            )
*/
////
#stdout end of 'schedule of depreciation of leased equipment ( AS OF DATE amst400c.prg )'
