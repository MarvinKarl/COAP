/*                                                             ÚÄ¿
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿     ³ ÀÄÄÄÄÄÄÄÄÄÄ¿
³   program idúúú amst0400                               ³ÚÄÄ¿ ÀÄÄÄÄÄÄÄÄÄÄÄÄÙ
³   descriptionúú Depreciation of Leased Equipment       ³³  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   authorúúúúúúú ariel b. bulan                         ³ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
³   dateúúúúúúúúú 2:00:pm úú 07-15-99                    ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                             u p d a t e s                                    ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        who        ³       when        ³              why                     ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                   ³                   ³                                      ³
³                   ³                   ³                                      ³
³                   ³                   ³                                      ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include 'inkey.ch'
#include 'colf.ch'

#defi clr_colo     'gr+/bg, w+/rb, w+/b, b/w, w+/g, b+/g, r+/n, w+/r, n/w, w+/rb'
#defi clr_mono     'w/n, n/w, n/w, w*/n, w/n, w+/n, w+/n, n/w, w+/gr, n/w'
// #defi clr_mono     'gr+/n, n/w, n/w, w*/n, w/n, w+/n, w+/n, n/w, w+/gr, n/w'
#defi guns_n_roses tone( 60, .5 )
#defi nirvana      tone( 480, 0.25 ); tone( 240, 0.25 )
#defi frozen       0
#defi gR_CELL      { 1,  2 }
#defi gN_CELL      { 3,  9 }
#defi gD_CELL      { 9, 10 }

#defi K_SPACEBAR   32
#defi microfeed    chr( 27 ) + 'J' + chr( 18 )

#xtra xConfigure( <x> ) =>;
    cb:getcolumn( <x> ):footing := tran( fFoot0100( <x> ), '9,999,999,999.99' );;
    cb:configure()

local mu:=savescreen( ,,, )
memvar  ax_level, guser_id

set confirm on
setcursor ( 0 )
setblink  (.t.)

if !chkpass( procname(), ax_level, guser_id )
   // nothing will happen
else
   begin sequence
      amstopen0400 ()
      amstmain0400 ()
   end sequence
   dbcloseall()
endif
setcursor  ( 0 )
restscreen ( ,,,,mu )
__mrelease ( '*', .t. )
return nil

/*******************************/
static function amstmain0400()
/*******************************/
   local mu:=savescreen(,,,),npreval,lcont := .t.
   //LOCAL cBRCODES := ACC_BRCH(g_USER_ID)
   private appflg := .f.
   private color  := iscolor(), cb
   private col_, rel, cel, arg
   private gigi   := 1, jing := 1, where := 1
   private zax, zrow := 1, xrow := 5
   private nnetbkvalue,ndepamount,dpretermdate,naccuamt,_ndepmatdate
   private _dfrom,_dto
   private npctr

   nnetbkvalue  := ndepamount := 0
   dpretermdate := ctod ( '' )

   if Lcrhead->(bof()) .and. Lcrhead->(Eof())
      error ( 'Error: Lcrhead File is empty.' )
   else

      scrntitle ( 'Depreciation of Leased Equipment', gsys_name, guser_id, gtrandate )
      dispbox   ( 3, 0, maxrow(), maxcol(), space( 9 ), 'n/n' )
      //
      // optionmen ( '<Ins>-Add <F2>-Edit <F4>-Search <F5>-Status <Del>-Delete <Esc>-Exit<',23 )
      //
******      optionmen ( '<F2>-Edit <F4>-Search <F9>-Print <Tab>-Switch <Esc>-Exit<',23 )
      optionmen ( '<F2>-Pret <F4>-Search <F9>-Print <Tab>-Switch <Esc>-Exit<',23 )

      setcolor  ( 'w/n' )
      baks      ( 3,2,22,77,,'w/n' )
      @ 14,2 say 'Æ'  color 'w/n'
      @ 14,col  () say repl('Í',74 )  color 'w/n'
      Lcrhead-> (dbgotop())

      if Lcrhead-> ( eof()) .and. Lcrhead->(bof() )
         Lcrhead-> ( dbgobottom() )
         Lcrhead-> ( dbskip(+1) )
      endif

      // scrn_rfrsh   ( @npreval  )

      dbselectarea ( "Lcrhead" )
      //Lcrhead-> ( dbgotop() )
      Lcrhead->( dbseek( g_par_brch )) //aga.11.07.2005.per branch

      cb := eval ( { | n | n := fBrow0100() } )
      fLite0100  ( .t. )
      do while lcont 
         //IF LCRHEAD->BRCODE $ &cBRCODES 
            scrn_rfrsh   ( )
            fStab0100    ( cb )
         //ENDIF
         lcont := amst0400key ( )
      enddo

   endif

   restscreen (,,,,mu)

return nil

////
static function fBrow0100()
local zz := fZipp0100()
memvar color, cb, zax
memvar col_, rel, cel, arg

// fShadow ( 3, 1, 22, 78, 2, 'w+/gr' )
fShadow ( 3, 2, 22, 77, 2, 'w+/gr' )

/******
   eval( { || fShadow( 3, 1, 22, 78, 2, 'w+/gr' ),;
           fJour0100(),;
           fEval0100(),;
           fChek0100() } )
*******/

dbselectarea( 'Lcrdepn' )
zax:= if ( dbseek( substr(LCRHEAD->BRCODE+Lcrhead->acctno,-5,5)),;
                   substr(LCRHEAD->BRCODE+Lcrhead->acctno,-5,5),;
                   spac(0) ;
         )
cb               := TBrowsedb() 
cb:ntop          :=  12 + 2
cb:nleft         :=  1 + 2
cb:nbottom       := 22 - 1
cb:nright        := 77 - 1
cb:headsep       := 'ÄÂÄ'
cb:colsep        := ' ³ '
cb:footsep       := 'ÄÁÄ'
cb:gotopblock    := { |   | fRecp0100( 'top'   , zax ) }
cb:gobottomblock := { |   | fRecp0100( 'bottom', zax ) }
cb:skipblock     := { | n | fRecp0100( 'skip'  , zax,  ;
                    { | x | x == LCRDEPN->BRCODE+substr( Lcrdepn->acctno,-5,5 )  }, n ) }
cb:colorspec     := if( color, clr_mono, clr_colo )
col_ := { tbcolumnnew( '    Month No. '    ,{ || transform( Lcrdepn->monthno, '99' ) } ),;
          tbcolumnnew( '     Depr. Amount ',{ || transform( round(Lcrdepn->depamount,0), '@Z 9,999,999,999.99' ) } ),;
          tbcolumnnew( '     Depr. Date   ',{ || transform( Lcrdepn->depdate,"@D" ) } );
        }

for n := 1 to len( col_ )
    cb:addcolumn( col_[ n ] )
    if n == 1
       //
       // col_[ n ]:colorblock := { || gR_CELL }
       //
       col_[ n ]:footing    :=  '        Total '
    else
       //
       // col_[ n ]:colorblock := { || gN_CELL }
       //
       if n == 2
          col_[ n ]:footing    := trans( fFoot0100( n ), '9,999,999,999.99' )
       endif
    endif
next n

cb:freeze   := frozen
cb:colpos   := cb:freeze + 1
cb:autolite := .f.
arg         := ( ( cb:colpos + 1 ) / cb:colcount ) * ( cb:nright - cb:nleft )
cel         := cb:nleft + 2
rel         := 1

/*
@ cb:ntop    + 2, cb:nright + 1 say chr( 24 )      color 'n/+w'
@ cb:nbottom    , cb:nright + 1 say chr( 25 )      color 'n/+w' 
@ cb:nbottom + 1, cb:nleft  + 1 say chr( 27 )      color 'n/+w'
@ cb:nbottom + 1, cb:nright - 1 say chr( 26 )      color 'n/+w' 
@ cb:ntop    + 3, cb:nright + 1,;
  cb:nbottom - 1, cb:nright + 1 box repl( '°', 9 ) color '+w/n'
@ cb:nbottom + 1, cb:nleft  + 2,;
  cb:nbottom + 1, cb:nright - 2 box repl( '°', 9 ) color '+w/n'
@ cb:ntop    - 1, cb:nleft      say repl( 'Ä',;
		    ( cb:nright - cb:nleft ) + 1 ) color 'w+/g'  
@ cb:ntop    - 1, cb:nleft  - 1 say 'Ã'            color 'w+/g'
@ cb:ntop    - 1, cb:nright + 1 say '´'            color 'w+/g'
*/

@ cb:ntop    - 1, cb:nleft      say repl( 'Ä',( cb:nright - cb:nleft ) + 1 ) ;
                                         color 'w+/gr'
@ cb:ntop    - 1, cb:nleft  - 1 say 'Ã'  color 'w+/gr'
@ cb:ntop    - 1, cb:nright + 1 say '´'  color 'w+/gr'


fUnzp0100( zz )
__keyboard( chr( K_END ) )
return( cb )

*******************************************
*
static function fFoot0100( cx )
*******************************************
local xx := fZipp0100(), dx := 0
Lcrdepn->( dbseek( LCRHEAD->BRCODE+substr(Lcrhead->acctno,-5,5) ) )
//ÄÄÄsum dr and cr with regards to tbrowse footing
Lcrdepn->( dbeval ( { || dx += Lcrdepn->depamount },,;
                    { || LCRDEPN->BRCODE+substr(Lcrdepn->acctno,-5,5) == LCRHEAD->BRCODE+substr(Lcrhead->acctno,-5,5) .and. ;
                        !Lcrdepn->(eof()) ;
                    };
                  );
        )

fUnzp0100( xx )
return  round( dx,0)

*******************************************
*
static function fLite0100( ax )
*******************************************
local bx := if( ax, 'w+/n', 'w/n' )
local cx := if( ax, 'w/n' , 'w+/n')

dispbegin()
if ax
  @ 23, 12 say 'F2'  color 'w+/n'
  @ 23, 22 say 'F4'  color 'w+/n'
  @ 23, 34 say 'F9'  color 'w+/n'
  @ 23, 45 say 'Tab' color 'w+/n'
  @ 23, 58 say 'Esc' color 'w+/n'
else
  @ 23, 12 say 'F2'  color 'n/n'
  @ 23, 22 say 'F4'  color 'n/n'
  @ 23, 34 say 'F9'  color 'n/n'
  @ 23, 45 say 'Tab' color 'w+/n'
  @ 23, 58 say 'Esc' color 'n/n'
endif
dispend()
return( nil )

*******************************************
*
static function fStab0100( cb )
*******************************************
   local zz,mu:=Lcrdepn->(indexord()), osel:=select()
   memva zax

   dbselectar( 'Lcrdepn' )
   zax:= if ( dbseek( LCRHEAD->BRCODE+substr(Lcrhead->acctno,-5,5),.F.),;
              LCRHEAD->BRCODE+substr(Lcrhead->acctno,-5,5),;
              spac(0) ;
            )
   xConfigure( 2 )
   while !cb:stabilize(); enddo
   cb:refreshall()
   ****** dispbegin()
   ****** @ cb:ntop + 3, cb:nright + 1,;
   ******   cb:nbottom - 1, cb:nright + 1 box repl( '°', 9 ) color '+w/n'
   ****** dispend()
   Lcrdepn->( dbsetorder(mu) )
   dbselectarea( osel )
return( cb )

********************************************
*
static function scrn_rfrsh(npreval)         //Refresh screen display
********************************************
   local ax :=  0,ndeplife := 0
   memvar nnetbkvalue,ndepamount,dpretermdate,naccuamt,_ndepmatdate

   nnetbkvalue  := ndepamount   := 0
   dpretermdate := ctod ( '' )

   @ 04,04    say '     Account Number   '   color 'bg+/gr'
   @ 04,col() say LCRHEAD->BRCODE+Lcrhead->acctno  pict '@R 999-9999-99999-99999' color 'w+/gr'

   @ 05,04    say '       Account Name   '   color 'bg+/gr'
   @ 05,col() say LCRHEAD->BRCODE+Lcrhead->clntcode pict '@R 999-99-99999' color 'w+/gr'   && RED 11122004 REPLACED '@!'
   @ 05,col()+1 say padr ( dispclntname( LCRHEAD->BRCODE+Lcrhead->clntcode, 31 ),35) color 'w+/gr'

   @ 06,04    say '               Term   '   color 'bg+/gr'
   @ 06,col() say Lcrhead->term               color 'w+/gr'

   @ 06,col()+5 say '        Maturity Date   '        color 'bg+/gr'
   @ 06,col()   say Lcrhead->matdate pict '99/99/9999' color 'w+/gr'

   @ 07,04    say '        Net Proceeds  '   color 'bg+/gr'
   @ 07,col() say Lcrhead->principal pict '999,999,999.99' color 'w+/gr'

   @ 07,col()+2 say 'Execution Date  '  color 'bg+/gr'
   @ 07,col() say Lcrhead->valdate pict '99/99/9999'     color 'w+/gr'
//
//
//   @ 08,04    say '    Purchase Amount   '  color 'bg+/gr'
//   @ 08,col() say Lcrhead->purcamt pict '999,999,999.99' color 'w+/gr'
//
   @ 08,40    say 'Outstanding Balance  ' color 'bg+/gr'

   Acctmast->(dbseek(LCRHEAD->BRCODE+Lcrhead->acctno))
   @ 08,col() say Acctmast->osbal pict '999,999,999.99'  color 'w+/gr'

   @ 09,40    say 'Unit  '                    color 'bg+/gr'
   @ 09,col() say Acctmast->unit  pict '@XS30' color 'w+/gr'
   @ 10,40    say '      ' color 'bg+/gr'
   @ 10,col() say Acctmast->unit2 pict '@XS30' color 'w+/gr'

   @ 09,04    say '     Residual Value   '  color 'bg+/gr'
   @ 09,col() say Lcrhead->rv                color 'w+/gr'

   @ 10,04    say '   Depreciation Life  '  color 'bg+/gr'

   if Asetcode->(dbseek(Lcrhead->asetcode))
      ndeplife := round( Asetcode->asetlife * 12 * 0.60,0 )
      ndeplife := max ( Lcrhead->term,ndeplife )
   endif

   @ 10,col() say trans( ndeplife,'999' )    color 'w+/gr'

   @ 11,04    say ' Pretermination Date  '    color 'bg+/gr'
   @ 11,col() say Lcrhead->ptermdate pict '@D' color 'w+/gr'

   @ 11,col() + 5 say 'Depr. Mat. Date  '    color 'bg+/gr'

   _ndepmatdate := _get_maturity ( Lcrhead->matdate,;
                                  Lcrhead->valdate,;
                                  ndeplife,;
                                  Lcrhead->termunit ;
                                )

   @ 11,col() say _ndepmatdate color 'w+/gr'

   ndepamount   := round( Lcrhead->principal - round( Lcrhead->rv / 100 * Lcrhead->Principal ,2 ), 0 )
   nnetbkvalue  := Lcrhead->netbookval

   
   @ 12,04    say ' Depreciable Amount   '        color 'bg+/gr'
   @ 12,col() say ndepamount pict '999,999,999.99' color 'w+/gr'

*****   @ 12,col()+2 say 'Net Book Value  ' color 'bg+/gr'
*****   @ 12,col()   say nnetbkvalue pict '999,999,999.99' color 'w+/gr'
   // @ 12,col()   say nnetbkvalue pict '999,999,999.99' color 'w+/gr'

return nil

********************************************
*
static function scrn_ref2(npreval)         //Refresh screen display
********************************************
   local ax :=  0,ndeplife := 0

   @ 04,04    say '     Account Number   '  color 'w/gr'
   @ 04,col() say LCRHEAD->BRCODE+Lcrhead->acctno  pict '@R 999-9999-99999-99999' color 'w/gr'

   @ 05,04    say '       Account Name   '   color 'w/gr'
   @ 05,col() say LCRHEAD->BRCODE+Lcrhead->clntcode pict '@R 999-99-99999' color 'w/gr' && RED 11122004 REPLACED '@!'
   @ 05,col()+1 say padr ( dispclntname( LCRHEAD->BRCODE+Lcrhead->clntcode, 31 ),35) color 'w/gr'

   @ 06,04    say '               Term   '  color 'w/gr'
   @ 06,col() say Lcrhead->term              color 'w/gr'

   @ 06,col()+5 say '        Maturity Date   ' color 'w/gr'
   @ 06,col()   say Lcrhead->matdate pict '99/99/9999'     color 'w/gr'

   @ 07,04    say '        Net Proceeds  '   color 'w/gr'
   @ 07,col() say Lcrhead->principal pict '999,999,999.99' color 'w/gr'


   @ 07,col()+2 say 'Execution Date  '  color 'w/gr'
   @ 07,col() say Lcrhead->valdate pict '99/99/9999'     color 'w/gr'
//
//   @ 08,04    say '    Purchase Amount   '  color 'w/gr'
//   @ 08,col() say Lcrhead->purcamt pict '999,999,999.99' color 'w/gr'
//

   @ 08,40    say 'Outstanding Balance  ' color 'w/gr'
   Acctmast->(dbseek(LCRHEAD->BRCODE+Lcrhead->acctno))
   @ 08,col() say Acctmast->osbal pict '999,999,999.99'  color 'w/gr'

   @ 09,40    say 'Unit  '                    color 'w/gr'
   @ 09,col() say Acctmast->unit  pict '@XS30' color 'w/gr'
   @ 10,40    say '      ' color 'w/gr'
   @ 10,col() say Acctmast->unit2 pict '@XS30' color 'w/gr'

   @ 09,04    say '     Residual Value   '  color 'w/gr'
   @ 09,col() say Lcrhead->rv                color 'w/gr'

   if Asetcode->(dbseek(Lcrhead->asetcode))
      ndeplife := round( Asetcode->asetlife * 12 * 0.60,0 )
      ndeplife := max ( Lcrhead->term,ndeplife )
   endif

   @ 10,04    say '   Depreciation Life  '    color 'w/gr'
   @ 10,col() say trans( ndeplife,'999' )      color 'w/gr'

   @ 11,04    say ' Pretermination Date  '    color 'w/gr'
   @ 11,col() say Lcrhead->ptermdate pict '@D' color 'w/gr'

   @ 11,col() + 5 say 'Depr. Mat. Date  '    color 'w/gr'

   _ndepmatdate := _get_maturity ( Lcrhead->matdate,;
                                      Lcrhead->valdate,;
                                      ndeplife,;
                                      Lcrhead->termunit ;
                                    );

   @ 11,col()     say _ndepmatdate color 'w/gr'

   ndepamount  := round ( Lcrhead->principal - round ( Lcrhead->rv / 100 * Lcrhead->Principal,2 ), 0 )
   nnetbkvalue := Lcrhead->netbookval

   @ 12,04    say ' Depreciable Amount   '        color 'w/gr'
   @ 12,col() say ndepamount pict '999,999,999.99' color 'w/gr'

*****   @ 12,col()+2 say 'Net Book Value  ' color 'w/gr'
*****   @ 12,col()   say nnetbkvalue pict '999,999,999.99' color 'w/gr'

return nil

************************************************************************
*****
***** static function compute_matdate ( mmatdate, mvaldate, mterm, mtermunit )
*****
function _get_maturity ( mmatdate,mvaldate,mterm,mtermunit )
**************************************************************************
    local  mmonth := month ( mvaldate ) , myear  := year ( mvaldate )
    local  mdays  := day   ( mvaldate ) , i
    
    do case
       case mtermunit == '1'       // Days
            mmatdate += mterm
            do while isholiday ( mmatdate )  ; mmatdate-- ; enddo
       case mtermunit == '2'       // Months
            for i := 1 to mterm
                mmonth++
                if mmonth > 12
                   myear++
                   mmonth := 1
                endif
            next i
            do case
               case ltrim(trans(mmonth,'999')) ==  '2'         // February ?
                  if ( is_leap(myear),;
                       mdays := if ( mdays >  28,29,mdays ),;
                       mdays := if ( mdays >= 28,28,mdays ) ;
                     )
               case ltrim(trans(mmonth,'999')) $ '_4_6_9_11'
                  if mdays > 30
                     mdays := 30
                  endif
            endcase
            mmatdate :=  ctod( ltrim( str( mmonth, 2, 0 ) ) + '/' +;
                               ltrim( str( mdays , 2, 0 ) ) + '/' +;
                               ltrim( str ( myear, 4, 0 ) ) )
            ////////
            // move the date backwards if it is a holiday
            //
            do while isholiday ( mmatdate ) ; mmatdate-- ; enddo
    endcase
return mmatdate


**************************************
static function isholiday ( mmatdate )
**************************************
   local mretval := .f.
   do case
      case dow ( mmatdate ) == 1 .or. dow ( mmatdate ) == 7
         mretval := .t.
      case Holidays->(dbseek(getholidate(mmatdate)))
         mretval := .t.
   endcase
return mretval
/*
****************************************
static function getholidate ( mmatdate )
****************************************
   local mmonth := right( '0'+alltrim (str(month(mmatdate),2,0)), 2)
   local mdays  := right( '0'+alltrim (str(day  (mmatdate),2,0)), 2)
return mmonth+'/'+mdays
***************************************************
*
static function _get_maturity ( ndeplife,dvaldate )
***************************************************
local dretval, nctr
local nmonth := month(dvaldate),nyear := year(dvaldate),nday := day(dvaldate)

for nctr := 1 to ndeplife
    nmonth ++
    if nmonth > 12
       nyear++
       nmonth := 1
    endif
next nctr

dretval := ctod (  right( '0'+alltrim(str(nmonth,2)),2 ) + '/'+;
                   right( '0'+alltrim(str(nday  ,2)),2 ) + '/'+;
                   right( '0'+alltrim(str(nyear ,4)),2 ) ;
                )

return dretval
*/
**********************************************
*
*
function optionmen( n1,nrow )               && RED 052505 REMOVED 'static
**********************************************
   local x,st_:={},n2:=n1,tl,ppy:={},ncol
   ncol := 40-len(n1)/2
   @ nrow,00 say repl(' ',79) color 'w/n'
   while len(n2) > 1
      x:=n2
      if (tl := at('>',n2 )) <> 0
         aadd(st_, substr(n2,1,tl) )
         n2:=substr( n2,tl+1, len(n2) )
         aadd(ppy,substr( n2,1,at('<',n2)-1 ) )
         n2:=substr( n2,at('<',n2),len(n2) )
      endif
      if n2 == x .or. empty(n2)
         exit
      endif
   enddo
   if !empty(st_)
      //x:=len(st_)
      for x:= 1 to len(st_)
          @ nrow,ncol  say st_[x]   color 'w+/n'
          @ nrow,col() say if(x <= len(ppy), ppy[x],'') color 'w/n'
          ncol := col()
      next x
   endif
return nil
************************************
static function amst0400key()
************************************
 local nkey,nflg:=.t. ,recnum:=0,x,_zz,_zz2,menulist,pchoice := 0,pchoice2
 memvar _dfrom,_dto
 memvar npctr

 if !appflg
    nkey:=  inkey(0)
 else
    nkey:=  22
 endif

   do case
      case nkey == K_PGUP .or. nkey == K_UP
         Lcrhead->(dbskip( -1 ))
         if Lcrhead->brcode != g_par_brch
            Lcrhead->( dbskip( +1 ) ) //aga.11.07.2005.per branch
         end if

         //if Lcrhead->(bof())
         //   waiton( 'Beginning of file!' )
         //   waitoff()
         //   Lcrhead->(dbgotop())
         //endif
      case nkey == K_PGDN .or. nkey == K_DOWN
         Lcrhead->(dbskip())
         if Lcrhead->brcode != g_par_brch
            Lcrhead->( dbskip( -1 ) ) //aga.11.07.2005.same as above, and the two below
         end if

         //if Lcrhead->(eof())
         //   waiton  ( 'End of file!' )
         //   waitoff ()
         //   Lcrhead->(dbskip( -1 ))
         //endif
      case nkey == K_END              //recnum:= Treview->(lastrec())
         //Lcrhead->(dbgobottom())
         Lcrhead->(dbseek(padl(val(g_par_brch) + 1, 3, "0")))
         Lcrhead->( dbskip( -1 ) )
      case nkey == K_HOME
         //Lcrhead->(dbgotop())
         Lcrhead->( dbseek( g_par_brch ) )
      case nkey == K_INS            //review another account
                /*****************
         if agetamsm0300()
             sw := .t.
             if(sw, eval( {|| scrn_rfrsh(@npreval),;
                              getreview1('1',npreval,,) ;
                        } ),nil )
             nflg := .t.
         else
             if (Treview->(eof()) .and. Treview->(bof()))
                nflg := .f.
             endif
         endif
         *************/

      case nkey == K_F2            // review the current account

         /***********
            getreview1 ( '2',npreval,, )
            nflg:=.t.
         ************/
         IF CURRBRCH(LCRHEAD->BRCODE)
            _get_preterm()
         ENDIF

      case nkey == K_F9            // search account to be review

         _zz := savescreen ( ,,, )
         fshadow  ( 10,35,21,57,2,'w+/bg' )
         setcolor ( 'n/gr,w+/gr','w+/gr,n/gr' )
         @ 10,37 say 'Print Options' color 'n/bg'
         @ 12,56 say 'Ü'  color 'n/bg'
         @ 13,37 say repl('ß',20) color 'n/bg'
         @ 14,56 say 'Ü'  color 'n/bg'
         @ 15,37 say repl('ß',20) color 'n/bg'
         @ 16,56 say 'Ü'  color 'n/bg'
         @ 17,37 say repl('ß',20) color 'n/bg'
         @ 18,56 say 'Ü'  color 'n/bg'
         @ 19,37 say repl('ß',20) color 'n/bg'
         @ 20,56 say 'Ü'  color 'n/bg'
         @ 21,37 say repl('ß',20) color 'n/bg'

         do while .t.

            _dfrom := date()
            _dto   := date()

            @ 12,36 prompt ' ~This Account       '  triggercolor 'w+/gr'
            @ 14,36 prompt ' Per ~Period         '  triggercolor 'w+/gr'
            @ 16,36 prompt ' ~Schedule of Depr.  '  triggercolor 'w+/gr'
            @ 18,36 prompt ' ~Sked of Depr.(Asof)'  triggercolor 'w+/gr'
            @ 20,36 prompt '~Sked of Depr.(Asof)2'  triggercolor 'w+/gr'
            menu to pchoice

            if lastkey() <> K_ESC .and. !empty(pchoice)
               do case
                  case pchoice == 1
                     npctr := 1
                     reportprint ( '_amst400pr()' ,,,8,33 )
                     *repcon_ol ( '_amst400pr()' ,,,8,33,,,.F. )
                  case pchoice == 2

                     _zz2 := savescreen( ,,, )
                     fshadow  ( 17,35,20,57,2,'w+/bg')
                     setcolor ('n/gr,w+/gr','w+/gr,n/gr')
                     @ 18,36 say 'Start  ' get _dfrom pict '@D' valid !empty(_dfrom )
                     @ 19,36 say '  End  ' get _dto   pict '@D' valid _dfrom <= _dto

                     setcursor (3)
                     read
                     setcursor (0)

                     if lastkey() != K_ESC
                        *repcontrol ( '_amst4pr2()' ,,,8,33 )
                        repcon_ol ( '_amst4pr2()' ,,,8,33,,,.F. )
                     endif

                     restscreen ( ,,,,_zz2 )

                  case pchoice == 3

                     _zz2 := savescreen( ,,, )

                     fshadow  ( 20,35,23,57,2,'w+/bg' )
                     setcolor ( 'n/gr,w+/gr','w+/gr,n/gr' )

                     @ 21,36 prompt ' ~Sorted by Acctno   '  triggercolor 'w+/gr'
                     @ 22,36 prompt ' Sorted by ~Oldno    '  triggercolor 'w+/gr'
                     menu to pchoice2

                     do case
                        case pchoice2 == 1
                           eval ( {|x,y| x := savedbf ( x ) ,;
                                         y := setcolor()    ,;
                                         amst400b(.t.)         ,;
                                         setcolor(y)        ,;
                                         restdbf ( x )       ;
                                  } ;
                                )
                        case pchoice2 == 2
                           eval ( {|x,y| x := savedbf ( x ) ,;
                                         y := setcolor()    ,;
                                         amst400b(.f.)         ,;
                                         setcolor(y)        ,;
                                         restdbf ( x )       ;
                                  } ;
                                )
                      endcase
                  case pchoice == 4

                     _zz2 := savescreen( ,,, )

                     eval ( {|x,y| x := savedbf  ( x ) ,;
                                   y := setcolor ()    ,;
                                   amst400c      (.t.) ,;
                                   setcolor      (y)   ,;
                                   restdbf       (x)    ;
                            } ;
                          )

                     restscreen ( ,,,,_zz2 )

                  case pchoice == 5

                     _zz2 := savescreen( ,,, )

                     eval ( {|x,y| x := savedbf  ( x ) ,;
                                   y := setcolor ()    ,;
                                   amst40c2      (.t.) ,;
                                   setcolor      (y)   ,;
                                   restdbf       (x)    ;
                            } ;
                          )

                     restscreen ( ,,,,_zz2 )
                 endcase
            else
               exit
            endif

         enddo
         restscreen ( ,,,,_zz )

      case nkey == K_F8            //
         over_ride( '1' )
      case nkey == K_F4            // search account to be review

         if !Lcrhead->(eof()) .and. !Lcrhead->(bof())
             _search_it ()
         endif

         nflg := .t.

      case nkey == K_DEL    //  delete current account in the Treview file

         /**********
         if !Treview->(eof()) .and. Confirm('Delete this record<'+Trans(TREVIEW->BRCODE+Treview->Acctno,'@R 999-99999-9999-99999')+'>?')
            MSGWIN(10,35,'Saving','w+/bg','r/bg','on')
            Treview->(rlock())
            Treview->(dbdelete())
            Treview->(dbunlock())
            Treview->(dbskip())
            if Treview->(eof())
               Treview->(dbskip(-1))
            endif
            MSGWIN(10,35,'Saving','w+/bg','r/bg','off')
         endif
         nflg:=.t.
         ***********/

      case nkey == K_F5            //edit status of current account
         /**********
              getreview1('2',npreval,.t.)
              nflg:=.t.
         *****************/
      case nkey == K_ESC          // exit module

         if confirm ( 'Are you sure you want to Exit?' )
            nflg := .f.
         endif

      case nkey == K_TAB
         tone(500,0)
         // tone(800,0)
         // tone(600,0)
         fLite0100  ( .f. )
         scrn_ref2  ()         //Refresh screen display
         fVouc0100  ()
         fLite0100  ( .t. )
         scrn_rfrsh ()
      otherwise
         tone(800,1)
         nflg := .t.
   endcase
return nflg

**********************************
*
static function _search_it ()
**********************************
   local ax := Lcrhead->(recno()), bx := space( 8 ), dx := savescreen( ,,, )
   local getlist := {}, cx := setcolor(),nntx := Lcrhead->(indexord())

   fShadow   ( row(), 18, row() + 2, 42, 2, 'w+/rb', ' Search ' )
   setcolor  ( 'w+/rb, w+/n,,, gr+/rb' )

   @ row() + 1, 19 say 'Account No. ' gget bx picture '@R 999-99999' VALID IF( !EMPTY(BX),;   && RED 11122004 REPLACED '@!'
                                                                                IF( VALBRCODE( LEFT(BX,3), g_USER_ID),;
                                                                                    .T.,;
                                                                                    EVAL({|| BX := SPACE(8),;
                                                                                             .F.;
                                                                                        });
                                                                                  ),;
                                                                                .F.;
                                                                              )
   setcursor ( 3 )
   read &&timeout 20 exitevent blankscr3( -1 )
   setcursor ( 0 )
   *bx := right ( '00000'+alltrim(bx),5 )    && RED 11122004

   if lastkey() != K_ESC

      Lcrhead->(dbsetorder(3))      // substr(acctno,-5,5)
      if !Lcrhead->( dbseek ( bx ) )
         waiton  ( 'Account Number not found',, 'w+/r' )
         inkey   ( .2 )
         waitoff ()
      else
         ax := Lcrhead->( recno() )
      endif

   endif

   Lcrhead->  ( dbsetorder ( nntx ) )
   Lcrhead->  ( dbgoto     ( ax   ) )
   setcolor   ( cx )
   restscreen ( ,,,, dx )

return nil

**********************************
*
function _amst4pr2()
**********************************
   local nrec := Lcrhead->(recno())
   memvar _dfrom,_dto
   memvar npctr
   npctr := 1

   Lcrhead->(dbgotop())

   do while !Lcrhead->(eof())

      if !empty(Lcrhead->ptermdate)      && was the account preterminated ?

         if Lcrhead->ptermdate >= _dfrom .and. Lcrhead->ptermdate <= _dto
            _amst400pr ()
         endif

      endif

      Lcrhead->(dbskip(+1))
   enddo
   Lcrhead->(dbgoto(nrec))

return nil

**********************************
*
function _amst400pr()
**********************************
   memvar npctr

   _head()

   if Lcrdepn->(dbseek(LCRHEAD->BRCODE+substr(Lcrhead->acctno,-5,5)))

      do while LCRDEPN->BRCODE+substr(Lcrdepn->acctno,-5,5) == LCRHEAD->BRCODE+substr(Lcrhead->acctno,-5,5) .and. ;
              !Lcrdepn->(eof())

         @ prow()+1,01        say trans ( Lcrdepn->monthno  ,'999' )
         @ prow()  ,pcol()+12 say trans ( Lcrdepn->depamount,'999,999,999.99' )
         @ prow()  ,pcol()+11 say trans ( Lcrdepn->depdate  ,'999,999,999.99' )

         if prow() >= 54
           __eject()
           npctr++
           _head()
         endif
         Lcrdepn->(dbskip(+1))
      enddo
      __eject()

   endif

return nil

**********************************
static function _head()
**********************************

   setprc(0,0)
   @ prow()+1,01      say 'Page No. ' + trans ( npctr,'9,999' )
   @ prow()+1,01      say 'Account Number      : '  + trans ( LCRHEAD->BRCODE+Lcrhead->acctno,'@R 999-9999-99999-99999' )
   @ prow()+1,01      say 'Client Code         : '  + trans ( LCRHEAD->BRCODE+Lcrhead->clntcode,'@R 999-99-99999' ) + ' '+;   && RED 11122004 REPLACED '@!'
                      padr ( dispclntname( LCRHEAD->BRCODE+Lcrhead->clntcode, 31 ),38)
   @ prow()+1,01      say 'Term                : '  + trans ( Lcrhead->term,'999' )
   @ prow()  ,pcol()+5 say '        Maturity Date    : '  + trans ( Lcrhead->matdate,'99/99/9999' )

//    @ prow()+1,00      say ' '
   @ prow()+1,01      say 'Net Proceeds        : '+ trans (  Lcrhead->principal,'999,999,999.99' )
   @ prow()  ,pcol()+2 say 'Execution Date   : '+ trans ( Lcrhead->valdate,'99/99/9999' )
   @ prow()+01,01     say 'Residual Value      : '+ trans(Lcrhead->rv,'999,999,999.99' )

//   @ prow()+1,00      say ' '

   if Asetcode->(dbseek(Lcrhead->asetcode))
      ndeplife := round( Asetcode->asetlife * 12 * 0.60,0 )
      ndeplife := max ( Lcrhead->term,ndeplife )
   endif

   @ prow()+01,01       say 'Depreciation Life   : '+ trans( ndeplife,'999' )
   @ prow(),pcol() + 13 say 'Depr. Mat. Date  : ' + ;
                        trans ( _get_maturity ( Lcrhead->matdate,;
                                                Lcrhead->valdate,;
                                                Lcrhead->term,;
                                                Lcrhead->termunit ;
                                              ),;
                                '@D' ;
                              )

   nnetbkvalue  := 0
   ndepamount   := round ( Lcrhead->principal - round ( ( Lcrhead->rv / 100 * Lcrhead->Principal ),2 ), 0)

   @ prow()+1,01 say 'Pretermination Date : ' + trans( Lcrhead->ptermdate,'@D' )
   @ prow()+1,01 say 'Depreciable Amount  : ' + trans( ndepamount,'999,999,999.99' )
   @ prow()+1,01 say 'Net Book Value      : ' + trans ( nnetbkvalue,'999,999,999.99' )

   @ prow()+2,01 say 'Month            Depreciation           Depreciation'
   @ prow()+1,01 say 'Number           Amount                 Date'

   @ prow()+1,01 say ''

return nil

**********************************
*
static function _get_preterm()
**********************************
   local dretval, cscr := savescreen (,,,)
   memvar nnetbkvalue,ndepamount,dpretermdate,naccuamt

   dpretermdate := ctod ( '' )
   fShadow ( 10, 20, 12, 60, 2, 'gb+/gr' )
   @ 11,21 say 'Pretermination Date  ' ;
           get dpretermdate ;
           pict '@D' VALID IF(!EMPTY(dPRETERMDATE) .AND. LASTKEY() == K_ENTER,;
                              IF(VALPRETERM(dPRETERMDATE),;
                                 .T.,;
                                 EVAL({|| dPRETERMDATE := CTOD(' ') ,;
                                          .F.;
                                     });
                                ),;
                              EVAL({|| _BROWSE_PRE(@dPRETERMDATE),;
                                       IF(LASTKEY() == K_ENTER,;
                                          .T.,;
                                          EVAL({|| dPRETERMDATE := CTOD(' '),;
                                                   .F.;
                                              });
                                         );
                                  }) ;
                             )

           /*
           when _browse_pre( @dpretermdate ) ;
           valid !empty(dpretermdate) .and.  ;
                 if ( Lcrhead->valdate > dpretermdate,;
                      eval({|| error( 'Execution Date is greater than entered date' ),.f. }),;
                      .t. ;
                    ) .and. ;
                 if ( Lcrhead->matdate <= dpretermdate,;
                      eval({|| error( 'Maturity Date is not greater than entered date' ),.f. }),;
                      .t. ;
                    ) .and. ;
                 _ffind ( dpretermdate )
           */
   setcursor(2)
   read
   setcursor(0)

   if lastkey() != K_ESC

      if confirm ( 'Permanently Update Depreciation Schedule ? ' )
         MSGWIN(12,36,'Saving','W+/BG','R*/BG','ON')
         if Lcrhead-> ( netlock('R',0) )

            Lcrhead->ptermdate  := dpretermdate
            Lcrhead->( dbunlock() )
            _update_lcrdepn()            && july 19, 1999 ( abb )

            ****if Lcrhead->(netlock('R',0))
            ****   Lcrhead->netbookval := ndepamount - naccuamt
            ***endif

            if Lcrhead->(netlock('R',0))
               Lcrhead->netbookval := 0

               Lcrhead->(dbunlock())
               Lcrhead->(dbcommit())
            endif

         endif
         MSGWIN(12,36,'Saving','W+/BG','R*/BG','OFF')
      endif

   endif

   restscreen ( ,,,, cscr )
return dretval

*-----------------------------------------
FUNCTION VALPRETERM(dPRETERMDATE)
LOCAL lRETVAL := !empty(dpretermdate) .and.  ;
                 if ( Lcrhead->valdate > dpretermdate,;
                      eval({|| error( 'Execution Date is greater than entered date' ),.f. }),;
                      .t. ;
                    ) .and. ;
                 if ( Lcrhead->matdate <= dpretermdate,;
                      eval({|| error( 'Maturity Date is not greater than entered date' ),.f. }),;
                      .t. ;
                    ) .and. _ffind ( dpretermdate )
RETURN lRETVAL
********************************
*
static function _ffind ( ddate )
********************************
   local cseek := LCRHEAD->BRCODE+substr ( Lcrhead->acctno,-5,5) ,lretval := .f.
   local nrec := Lcrdepn->( recno()), nntx := Lcrdepn->(indexord())
alert(indexkey())
   if Lcrdepn->( dbseek ( cseek  ) )
      do while LCRDEPN->BRCODE+substr(Lcrdepn->acctno,-5,5) = cseek .and. !Lcrdepn->(eof())

         if Lcrdepn->depdate == ddate
            lretval := .t.
         endif

         Lcrdepn->(dbskip(+1))
      enddo

   endif

   if !lretval
       error ( 'Depreciation Date Not Found' )
   endif

   Lcrdepn->(dbsetorder(nntx))
   Lcrdepn->(dbgoto(nrec))

return lretval

*********************************************
*
static function _browse_pre( dpretermdate )
********************************************
   local lretval  := .t.,nrec := Lcrdepn->(recno()), nntx := Lcrdepn->(indexord())
   local cseek    := LCRHEAD->BRCODE+substr( Lcrhead->acctno,-5,5 )
   local achoices := {}, cdate := '1',nctr

   if Lcrdepn->( dbseek ( cseek  ) )
      MSGWIN(12,36,'Preparing data..','w+/bg','r*/bg','on')
      do while LCRDEPN->BRCODE+substr(Lcrdepn->acctno,-5,5) = cseek .and. !Lcrdepn->(eof())
         aadd ( achoices,Lcrdepn->depdate )
         Lcrdepn->(dbskip(+1))
      enddo
      MSGWIN(12,36,'Preparing data..','w+/bg','r*/bg','off')

      for nctr := 1 to len(achoices)
         achoices [nctr] := alltrim( str( nctr ) ) + " = " + dtoc( achoices [nctr] )
      next nctr

      cdate := gen_achoice  ( achoices, val( cdate ), 'Depr. Date', 2, 60, 20+1+len (achoices), 77, 'w/gr+,w/n,,,w/gr+' )

      if lastkey() != K_ESC
         dpretermdate := ctod( right ( achoices [ val ( cdate ) ], 10 ) )
      endif

   endif

   Lcrdepn->(dbsetorder(nntx))
   Lcrdepn->(dbgoto(nrec))
return lretval

**********************************
*
static function _update_lcrdepn()
**********************************
   local nrec     := Lcrdepn->(recno()),nrec2 := 0,lfound := .f.
   local narr_del := {},nctr
   memvar nnetbkvalue,ndepamount,dpretermdate,naccuamt

   naccuamt := 0
   if Lcrdepn->(dbseek(LCRHEAD->BRCODE+substr(Lcrhead->acctno,-5,5)+dtos(Lcrhead->ptermdate),.t. ))
      lfound := .t.
   else

      if LCRDEPN->BRCODE+substr(Lcrdepn->acctno,-5,5) == LCRHEAD->BRCODE+substr(Lcrhead->acctno,-5,5)

         lfound := .t.

         Lcrdepn->(dbskip(+1))
         if Lcrdepn->(eof())
            Lcrdepn->(dbgobottom())
         endif

      endif

   endif

   if lfound

      nrec2    := Lcrdepn->(recno())
      narr_del := {}

      do while LCRDEPN->BRCODE+substr(Lcrdepn->acctno,-5,5) == LCRHEAD->BRCODE+substr(Lcrhead->acctno,-5,5) .and. ;
              !Lcrdepn->(eof())

         if Lcrdepn->depdate > Lcrhead->ptermdate
            aadd ( narr_del,Lcrdepn->(recno()) )
            naccuamt += Lcrdepn->depamount
         endif

         Lcrdepn->(dbskip(+1))

      enddo

      if naccuamt > 0

         Lcrdepn->(dbgoto(nrec2))                 &&& ACCUMULATE
         if Lcrdepn->(netlock('R',0))
            Lcrdepn->depamount  := Lcrdepn->depamount + naccuamt
            Lcrdepn->(dbunlock())
            Lcrdepn->(dbcommit())
         endif

         for nctr := 1 to len( narr_del )         &&& DELETE SUCCEEDING RECORDS
            Lcrdepn->(dbgoto(narr_del[nctr]))
            if Lcrdepn->(netlock('R',0))
               Lcrdepn->(dbdelete())
               Lcrdepn->(dbunlock())
               Lcrdepn->(dbcommit())
            endif
         next nctr

      endif

   endif
   Lcrdepn->(dbgoto(nrec))

return nil

**********************************
*
static function fVouc0100()
**********************************
local  log := !.f., zz := fZipp0100()
local  dx := 0, ax := 0, xx,mzy:=Savescreen(23,0,23,80)
local dtr:=0, mmm,__ntotal := 0,__ndepamount := 0, __nrecno := 0
memvar color, cb, zax, gigi
memvar col_, rel, cel, arg
memvar AX_LEVEL, gUSER_ID

dbselectarea( 'Lcrdepn' )
zax:= if ( dbseek ( LCRHEAD->BRCODE+substr( Lcrhead->acctno,-5,5 ) ),;
           LCRHEAD->BRCODE+substr( Lcrhead->acctno,-5,5 ),;
           spac   ( 0 );
         )
//
// fEval0100()
//

        color        := !color
	     cb:colorspec := if( color, clr_mono, clr_colo )

do while log

     if cb:colpos > cb:colcount
        guns_n_roses
     endi
     if cb:colpos <= cb:freeze
        guns_n_roses
     endi

     do while !cb:stabilize()
        if nextkey() <> 0
           exit
        endif
     enddo        
     
     if cb:hittop .or. cb:hitbottom
        guns_n_roses
        if cb:hittop
          waiton( 'Begin', .f., 'bg+/rb', row() - 2 )
        endif
        if cb:hitbottom
           waiton( 'End', .f., 'bg+/rb', row() - 2 )
        endif
        inkey( .1 )
        waitoff()
     endi

     dispbegin()

     if gigi > cb:rowcount
        ******* @ cb:ntop + 3 + rel, cb:nright + 1 say '°' color '+w/n'
        ******* rel := min( ( fRecp0100() / gigi ) * cb:rowcount, cb:rowcount - 1 )
        ******* @ cb:ntop + 3 + rel, cb:nright + 1 say 'Û' color '+gr/w'
     endif

     ******* @ cb:nbottom + 1, cel say '°' color '+w/n'
     cel := ( cb:colpos / cb:colcount ) * ( cb:nright - cb:nleft )
     cel := if( cel < arg + 1, cb:nLeft + 2, cel + 1 )

     ******* @ cb:nbottom + 1, cel say 'Û' color '+gr/w'
     ******* @  5, 1, 12,1 box repl( '°', 9 ) color 'w+/n'
     ******* @ 13, 1, 20,1 box repl( 'Û', 9 ) color 'gr+/w'

     dispend()

     key := eval (  { || cb:hilite() ,;
                         inkey( 0 )   ;
                    };
                 )
     
     do case
        case fNavi0100( cb, key )
        case key == K_TAB
            xx := fZipp0100()
            dx := ax := 0.00

            tone(500,0)
            //
            // tone(800,0)
            // tone(600,0)
            //

            __nrecno := Lcrdepn->(recno())
            if Lcrdepn->( dbseek( LCRHEAD->BRCODE+substr( Lcrhead->acctno,-5,5 ) ) )

               __ntotal := 0
               do while LCRDEPN->BRCODE+substr(Lcrdepn->acctno,-5,5) == LCRHEAD->BRCODE+substr( Lcrhead->acctno,-5,5) .and. ;
                        !Lcrdepn->(eof())
                  __ntotal += ( Lcrdepn->depamount )
                  Lcrdepn->(dbskip(+1))
               enddo

               __ndepamount:= round ( Lcrhead->principal - round( Lcrhead->rv / 100 * Lcrhead->Principal ,2 ), 0 )

               if round ( __ndepamount,2 ) != round ( __ntotal,2 )
                  tone(500,0)
                  tone(800,0)
                  tone(600,0)
                  error     (  "Detail is "+ alltrim( trans( round ( __ntotal,2 ),"999,999,999.99") )+ " Header is "+ alltrim( trans( round ( __ndepamount,2 ),"999,999,999.99")) )
                  Lcrdepn-> ( dbgoto ( __nrecno ) )
                  loop
               endif

            endif

            Lcrdepn->(dbseek( LCRHEAD->BRCODE+substr( Lcrhead->acctno,-5,5 ) ) )
            log  := !log
            cb:gotop()

        color        := !color
	     cb:colorspec := if( color, clr_mono, clr_colo )
        cb:configure()

        case key == K_INS
            if chkpass( 'A', AX_LEVEL, gUSER_ID )

              /*
              if fGete0100 ( 'a' )
                         eval ( { || mmmm:=recno(),;
                                     cb:gobottom(),;
                                     cb:gotop() ;
                              } ) //,dbgoto(mmmm)
              endif
              */

               xConfigure( 2 )

           endif

	case key == K_DEL

        if CURRBRCH(LCRDEPN->BRCODE) .AND. chkpass( 'D', AX_LEVEL, gUSER_ID )
           /*
           if Tranhead->trnumber == Trandtls->trnumber
              if Trandtls->( netlock( 'R', 0 ) )
		      fEras0100( !.t. )
		      //cb:gotop()
                      dtr:=recno()
		      cb:refreshall()
                      eval({|| cb:gotop(), dbgoto(dtr) })
            xConfigure( 2 )
		   endif
         Trandtls->( dbunlock() )
          endif
          */
	     endif   
	case key == K_F1
	     // waiting_function()
	case key == K_F2
//      /************
**        if chkpass( 'E', AX_LEVEL, gUSER_ID ) .and. val( Tranhead->Trnumber ) > Parametr->Jv_limit
**      if Tranhead->trnumber == Trandtls->trnumber
  **       if Trandtls->( netlock( 'R', 5 ) )
        IF CURRBRCH(LCRDEPN->BRCODE)
           fGete0400(  )
           cb:refreshcurrent()
           cb:configure()
        ENDIF
		      //cb:refreshall()
      //      xConfigure( 2, 3 )
            xConfigure( 2 )
    **     endif
      **   Trandtls->( dbunlock() )
  **    endif
  **      endif
//      ********/
	case key == K_F3
*****        color        := !color
*****         cb:colorspec := if( color, clr_mono, clr_colo )
*****         cb:configure()
     endc
endd
fUnzp0100( zz )
restscreen(23,0,23,80,mzy)
return( nil )

*****************************************
*
static function fGete0400(  )
*****************************************
   local cscr := savescreen (,,,)
   local cacctno,nmonthno,ndepamt,ddepdate,coldno

   cacctno    := LCRDEPN->BRCODE+Lcrdepn->acctno
   nmonthno   := Lcrdepn->monthno
   ndepamount := Lcrdepn->depamount
   ddepdate   := Lcrdepn->depdate
   coldno     := Lcrdepn->oldno

   @ 12,40 clear to 18,77
   @ 12,40 to 18,77

   @ 13,41 say 'Account No.  : ' get cacctno   pict '@R 999-9999-99999-99999' when .f.
   @ 14,41 say '  Month No.  : ' get nmonthno  when .f.
   @ 15,41 say 'Depr. Amount : ' get ndepamount ;
                                 pict '999,999,999.99' ;
                                 valid (ndepamount >= 0)
   @ 16,41 say '  Depr. Date : ' get ddepdate  pict '@D' when .f.
   @ 17,41 say '    Old No.  : ' get coldno   when .f.

   setcursor(3)
   read
   setcursor(0)

   if lastkey() == K_ENTER
      MSGWIN(14,55,'Saving','W+/BG','R*/BG','ON')
      if Lcrdepn->(netlock('R',0))
         Lcrdepn->acctno     := RIGHT(cacctno,14)
         Lcrdepn->monthno    := nmonthno
         Lcrdepn->depamount  := ndepamount
         Lcrdepn->depdate    := ddepdate
         Lcrdepn->oldno      := coldno
         LCRDEPN->BRCODE     := LEFT(cacctno,3)
         Lcrdepn->(dbunlock())
         Lcrdepn->(dbcommit())
      endif
      MSGWIN(14,55,'Saving','W+/BG','R*/BG','OFF')
   endif


   restscreen(,,,,cscr)
return nil

*****************************************
*
static function fNavi0100( brow, knob )
*****************************************
loca did := .t.

do case
   case knob == K_UP    
	brow:up()
   case knob == K_DOWN  
	brow:down()
   case knob == K_LEFT  
	brow:left()
   case knob == K_RIGHT 
	brow:right()
   case knob == K_PGUP
	brow:pageup()
   case knob == K_PGDN
	brow:pagedown()

   /********
      case knob == K_CTRL_PGUP
         brow:gotop()
      case knob == K_CTRL_PGDN
         brow:gobottom()
   ********/

   case knob == K_HOME
	brow:home()
   case knob == K_END
	brow:end()
   case knob == K_CTRL_HOME
	brow:panhome()
   case knob == K_CTRL_END
	brow:panend()                
   othe
	did := .f.     
endc        
return( did )
/*
*****************************************
static function dispclntname( mclntcode )
*****************************************
return eval ({ |x,y| x:= savedbf ( x ), Client->( dbsetorder(1) ),;
                     Client->( dbseek(mclntcode) ), y:= left( Client->FULLNAME, 31 ),;
                     restdbf( x ), y })
*/
////
static function fRecp0100( how, what, which, howmany )
local  actual := 0, soft
memvar gigi, where

do case
   case how = 'top'
	where := 1 
	dbseek( what,.f. )
   case how = 'bottom'
	where := gigi 
	soft  := set( _SET_SOFTSEEK, .t. )
	dbseek( left( what, len( what ) - 1 ) + chr( 255 ) ,.f.)
	dbskip( -1 )
	set( _SET_SOFTSEEK, soft )
   case how = 'skip'
	do case
	   case howmany < 0
		while ( actual > howmany ) .and. ( !bof() ) .and.;
		      eval( which, what )
		      dbskip( -1 )
		      if !bof() .and. eval( which, what )
			 actual--
		      endif
		enddo
		if !eval( which, what )
		   dbskip( +1 )
		endif    
	   case howmany > 0
		while ( actual < howmany ) .and. ( !eof() ) .and.;
		      eval( which, what )
		      dbskip( +1 )
		      if !eof() .and. eval( which, what )
			 actual++
		      endif
		enddo
		if ( eof() .or. !eval( which, what ) ) .and. !empty(what)
		   dbskip( -1 )
		endif
	   otherwise
		dbskip( 0 )
	endcase
   otherwise
	return( where )           
endcase
where += actual
where := min( max( where, 1 ), gigi )
return( actual )

////
static function fZipp0100()
local arr := { select(), indexord(), recno() }
return( arr )

////
static function fUnzp0100( ar_ )
return( eval( { || dbselectar( ar_[ 1 ] ),;
		   dbsetorder( ar_[ 2 ] ),;
         dbgoto(     ar_[ 3 ] ), nil } ) )

****************************************
*
*
static function over_ride( nsw, xtrcode)
****************************************
local o_scr:=savescreen(,,,) ,nsel := select(),old_num
local nuser := space(5),npass,user_:= { 'ABC','HBL','XXX','JLB','LLY','ABB','CBT' }
local o_clr:=setcolor(),o_curs:=setcursor(),xtrnum,xdate,nrec,nx
local ndtls := (alias())->(indexord()),dtls_rec:= (alias())->(recno())

fshadow      ( 5,40,8,65,2,'w/gr')
setcursor    ( 1 )
setcolor     ( 'w/gr,n/w,,,w+/gr' )

@ 6, 41 say 'User_Id   ' // get nuser
@ 7, 41 say 'Password  ' // get npass
@ 6, 52 get nuser picture '@!'

setcursor(3)
read
setcursor(0)

if lastkey() <> K_ESC .and. eval({|| ascan(user_,alltrim(nuser)) <> 0 })
   @ 7, 52 say ''
   npass := getpass()
   if Axmast-> ( dbseek( alltrim(nuser)) ) .and. alltrim( Axmast->Password ) == alltrim(npass)
      restscreen ( ,,,,o_scr )
      if confirm ( 'Rollback Depreciation Spread?' )
         MSGWIN(7,52,'Saving','W+/BG','R*/BG','ON')
         _roll_it()

         if Lcrhead->(netlock('R',0))
            Lcrhead->ptermdate  := ctod( '')
            Lcrhead->netbookval := 0
            Lcrhead->(dbunlock())
            Lcrhead->(dbcommit())
         endif

         error ( 'Depreciation Spread Computation processed' )
         MSGWIN(7,52,'Saving','W+/BG','R*/BG','OFF')
      endif

   else
     error('Access denied..!!!!')
   endif
endif

dbselectarea(nsel)
restscreen(,,,,o_scr)
setcolor( o_clr )
setcursor( o_curs )
return nil

/*******************************/
static function _roll_it()
/*******************************/
   local nctr,dpaydate := Lcrhead->valdate,ntermlimit := Lcrhead->term
   local ntermunit := Lcrhead->termunit, ndeplife

   if Lcrdepn->(dbseek(LCRHEAD->BRCODE+substr(Lcrhead->acctno,-5,5)))
      MSGWIN(10,30,'Processing','w+/bg','r*/bg','on')

      do while !Lcrdepn->(eof()) .and. ;
                LCRDEPN->BRCODE+substr(Lcrdepn->acctno,-5,5) == LCRHEAD->BRCODE+substr(Lcrhead->acctno,-5,5)
         if Lcrdepn->(netlock('R',0))
            Lcrdepn->(dbdelete())
            Lcrdepn->(dbunlock())
         endif
         Lcrdepn->(dbskip(+1))
      enddo

      ndeplife := ntermlimit
      if Asetcode->(dbseek(Lcrhead->asetcode))
         ndeplife := round( Asetcode->asetlife * 12 * 0.60,0 )
         ndeplife := max ( Lcrhead->term,ndeplife )
      endif
//
//      @ 10,col() say trans( ndeplife,'999' )    color 'w+/gr'
//
      for nctr := 1 to ndeplife
         if Lcrdepn->(netlock('A',0))

            nrec := Lcrdepn->(recno())

            Lcrdepn->acctno    := Lcrhead->acctno
            Lcrdepn->monthno   := nctr
//             Lcrdepn->depamount := getamount      ( nctr,ntermlimit )
            Lcrdepn->depamount := getamount      ( nctr,ndeplife )
            Lcrdepn->depdate   := dpaydate
            LCRDEPN->BRCODE    := LCRHEAD->BRCODE

            dpaydate := reckon_paydate ( dpaydate,alltrim(ntermunit),1 )

            Lcrdepn->(dbunlock())
            Lcrdepn->(dbgoto(nrec))
            // dpaydate := Lcrdepn->depdate

         endif
      next nctr
      Lcrdepn->(dbcommit())

      MSGWIN(10,30,'Processing','w+/bg','r*/bg','off')
   else
      error ( 'No Records found for AcctNo '+LCRHEAD->BRCODE+alltrim(Lcrhead->acctno) )
      if confirm ( 'Recompute anyway? ' )
         MSGWIN(10,30,'Processing','w+/bg','r*/bg','on')

         for nctr := 1 to ntermlimit
            if Lcrdepn->(netlock('A',0))

               nrec := Lcrdepn->(recno())

               Lcrdepn->acctno    := Lcrhead->acctno
               Lcrdepn->monthno   := nctr
               Lcrdepn->depamount := getamount( nctr,ntermlimit )

               Lcrdepn->depdate   := dpaydate
               LCRDEPN->BRCODE    := LCRHEAD->BRCODE

               dpaydate := reckon_paydate( dpaydate,alltrim(ntermunit),1 )

               Lcrdepn->(dbunlock())
               Lcrdepn->(dbgoto(nrec))
               // dpaydate := Lcrdepn->depdate

               Lcrdepn->(dbcommit())

            endif
         next nctr

         MSGWIN(10,30,'Processing','w+/bg','r*/bg','off')
      endif

   endif

return nil

*****************************************************************
*
static function reckon_paydate ( mpaydate,mtermunit,mstep )
*****************************************************************
    local  mmonth := month ( mpaydate ) , myear  := year ( mpaydate )
    local  mdays  := day   ( mpaydate ) , i

    do case
       case mtermunit == '1'   // days
            mpaydate++

       case mtermunit == '2'   // months

            mmonth := mmonth + mstep

            if mmonth > 12
               myear++
               mmonth := 1
            endif

            if mmonth == 2                         // February ???
               if is_leap(myear)                   // 29 ???
                  mdays := if( mdays>28,29,mdays )
               else
                  mdays := if( mdays>=28,28,mdays )
               endif
            endif

            if mmonth != 1
               if alltrim(str(mmonth)) $ '_4_6_9_11'
                  if mdays > 30
                     mdays := 30
                  endif
               endif
            endif

            mpaydate := ctod ( alltrim( str( mmonth, 2, 0 ) ) + '/' +;
                               alltrim( str( mdays , 2, 0 ) ) + '/' +;
                               alltrim( str ( myear, 4, 0 ) ) ;
                             )

           

    endcase
return mpaydate

/***************************************/
static function getamount( i,mallowed )
/***************************************/
return ( round( ( ( Lcrhead->principal -;
                    ( round( round(Lcrhead->principal * Lcrhead->rv,2) / 100,2) ) ;
                  ) *;
                  ( mallowed - ( i - 1 ) ) ) /;
                  ( ( round( mallowed * ( mallowed + 1 ),2) ) / 2 ), 2 ) ;
      )


/*******************************/
static function amstopen0400 ()
/*******************************/
   local lretval:=.t.

   if !netuse ( '&g_AMS_PATH\Acctmast',.f.,5 )
      lretval := .f.
   else
      ordlistclear ()
      ordlistadd   ( '&g_AMS_PATH\Acctmast' )       // acctno
      ordlistadd   ( '&g_AMS_PATH\Acctsub2' )
      ordlistadd   ( '&g_AMS_PATH\Acctacno' )       // open index file for Acctmast
      Acctmast->   ( dbsetorder (1) )
   endif

   if !netuse ( '&g_AMS_PATH\Lcrdepn',.f.,5 )
      return .f.
   else
      dbclearindex()
      set index to &g_AMS_PATH\Lcrdepn,&g_AMS_PATH\Lcrdepn2
      set order to 1
   endif

   if !netuse ( '&g_AMS_PATH\Lcrhead',.f.,5 )
      lretval := .f.
   else
      ordlistclear ()
      ordlistadd   ( '&g_AMS_PATH\Lcrhead1' )       // acctno + clntcode
      ordlistadd   ( '&g_AMS_PATH\Lcrhead2' )       // clntcode + acctno
      ordlistadd   ( '&g_AMS_PATH\Lcrhead3' )       // subst(acctno,-5,5)
      Lcrhead->   ( dbsetorder(1) )
   endif

   if !netuse( '&g_cis_path'+'\Client.dbf',.f.,5)
      lretval := .f.
   else
      set index to &g_cis_path\Cliecd, &g_cis_path\Clienm
   endif

   if !netuse ( '&g_AMS_PATH\axmast',.f.,5 )
      lretval := .f.
   endif
   set index to &g_AMS_PATH\user_id

   if !netuse('&g_grf_path'+'\holidays',.f.,5)
      return .f.
   endif
   set index to &g_grf_path\holidate

   if !netuse ( '&g_AMS_PATH\Asetcode', .f. ,5 )
      lretval := .f.
   else
      dbsetindex ( '&g_AMS_PATH\Asetcode' )
   endif
return lretval
