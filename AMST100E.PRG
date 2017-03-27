/*
 ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³   program id.........:  amst100e.prg                                 ³
 ³   description........:  Schedule of payments generation (availments) ³
 ³   author.............:  Ariel B. Bulan                               ³
 ³   date...............:  2:52pm 18-Nov-1994                           ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³                         U P D A T E S                                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³        Who        ³     When      ³               Why                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³                   ³               ³                                  ³
 ³   ABB             ³  10.18.2004   ³     ONLINE                       ³
 ³   ABB             ³  02.09.2005   ³  display unbalanced paysked vs.  ³
 ³                   ³               ³  acctdaly->credamt               ³
 ³   aga             ³  14.02.2007   ³  neo paysked support for modules ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include "Colf.ch"
#include "Inkey.ch"

*****************************************
*
function generate_sked ( mwhat )
*****************************************
local mdbf := savedbf(mdbf), mcolor := setcolor(), mscr := savescreen( ,,, )
local mterm := Acctdaly->TERM, mamort := Acctdaly->AMORT
local mprincipal := Acctdaly->PRINCIPAL, mcredamt := Acctdaly->CREDAMT
local mstep := 0


center( 24, 'w+*/n', '® Generating Schedule of Payment... ¯' )
if Facility->SETCODE $ '1234'

   if Acctdaly->PAYFREQ $ '123456'
      del_old_sked()
   endif

   do case
      case Acctdaly->PAYFREQ == '1'            // Monthly
           mstep  := 1
      case Acctdaly->PAYFREQ == '2'            // Bi-monthly
           mstep  := 2 ; mterm  /= 2 ; mamort *= 2
      case Acctdaly->PAYFREQ == '3'            // Quarterly
           mstep  := 4 ; mterm /= 4    ; mamort *= 4
      case Acctdaly->PAYFREQ == '4'            // Semi-Annual
           mstep  := 6 ; mterm /= 6    ; mamort *= 6
      case Acctdaly->PAYFREQ == '5'            // Annual
           mstep  := 12; mterm /= 12   ; mamort *= 12
      case Acctdaly->PAYFREQ == '6'            // Lumpsum
           update_skedfile ( Acctdaly->ACCTNO,1,Acctdaly->MATDATE,Acctdaly->CREDAMT )
      case Acctdaly->PAYFREQ == '7'            // Irregular
           if mwhat != 'A'
              if confirm ( 'Erase all Previous Schedule of Payment?' )
                 del_old_sked()
              endif
           endif
           browse_sked( Acctdaly->ACCTNO )
   endcase

   if !(Acctdaly->PAYFREQ $ '67')
      if Acctdaly -> TERMUNIT == '1'
         mterm := mterm / 30
      endif
      create_sked( mterm,mamort,mprincipal,mcredamt,mstep )
      error ( 'Schedule Generated...' )
   endif

else
      do case
         //aga.19.05.2008.ipp monthly patch for acctdaly
         case Acctdaly->PAYFREQ == '1'            // Monthly
              if mwhat != 'A'
                 del_old_sked()
              end if

              mstep  := 1
              create_sked( mterm,mamort,mprincipal,mcredamt,mstep )
              error ( 'Schedule Generated...' )
         //..............................

         case Acctdaly->PAYFREQ == '6'            // Lumpsum
              del_old_sked()
              update_skedfile ( Acctdaly->ACCTNO,1,Acctdaly->MATDATE,Acctdaly->CREDAMT )
         case Acctdaly->PAYFREQ == '7'            // Irregular
              if mwhat != 'A'
                 if confirm ( 'Erase all Previous Schedule of Payment?' )
                    del_old_sked()
                 endif
              endif
              browse_sked( Acctdaly->ACCTNO )
      endcase
end if


   restdbf(mdbf);setcolor(mcolor);restscreen(,,,,mscr)
return nil
*********************************************************************
static function create_sked( mterm,mamort,mprincipal,mcredamt,mstep )
*********************************************************************
local i, mdivisor, macctno := Acctdaly->ACCTNO, mpaydate := Acctdaly->FIRSTDUE
local mtermunit := '2', mpaynumber := 0, mintamt, mprnamt, mosbal, moldmdays
local mtot_int  := 0

local ask := 0, mset := 0

moldmdays  := day ( mpaydate )

//aga.31.10.2007.confirm end of month due date
if ascan({ 2,4,6,9,11 },month(mpaydate)) != 0 
   if month(mpaydate) == 2 
      if day(mpaydate) == 28 .or. day(mpaydate) == 29
         ask++
      end if
   else   
      if day(mpaydate) == 30 
         ask++
      end if
   end if
end if

if ask > 0
   if confirm( 'Every end of month due date (' + dtoc(mpaydate) + ')?')
      mset++
   else
      mset := 0
   end if
end if
//.......................


for i:= mterm to 1 step-1
    mpaynumber++

    update_skedfile  ( macctno  ,mpaynumber,mpaydate, mamort )
    reckon_paydate   ( @mpaydate,mtermunit ,mstep,moldmdays,mset )
next i
return nil

*******************************************************************
*
static function reckon_paydate ( mpaydate,mtermunit,mstep,olddays,mset )
*******************************************************************
local mmonth := month( mpaydate ), myear := year( mpaydate )
local mdays  := olddays, i

do case
   case mtermunit == '1'   // days
        mpaydate++
   case mtermunit == '2'   // months
        mmonth += mstep
        if mmonth > 12
           myear++
           mmonth-=12 
        endif
        if mmonth == 2                         // February ???
           if is_leap(myear)                   // 29 ???
              mdays := if( mdays > 28,29,mdays )
           else
              mdays := if( mdays>=28,28,mdays )
           endif
        else
           if mdays > 30
              mdays := if( Ascan( { 4,6,9,11 },mmonth) <> 0, 30, 31)
           endif
        endif

//aga.31.10.2007.insert patch
        if mset > 0
           mdays := day(addmonth( ctod(ltrim(str(mmonth,2,0)) + '/01/' + ltrim(str(myear,4,0)) ),1)-1)
        end if        
//.............

        mpaydate := ctod( ltrim( str( mmonth, 2, 0 ) ) + '/' +;
                          ltrim( str( mdays , 2, 0 ) ) + '/' +;
                          ltrim( str ( myear, 4, 0 ) ) )
    endcase


return .t.

***************************************************************************************************
function reckon_succOSBAL( mintamt,mprnamt,mterm,mamort,mprincipal,mcredamt,mosbal,mdivisor,mtot_int )
***************************************************************************************************
    mintamt  := ( (mcredamt-mprincipal) * mterm ) / mdivisor
    mprnamt  := mamort - mintamt
    mosbal   := mosbal - mamort
    mtot_Int += mintamt
    if mterm == 1 .and. (mcredamt-mprincipal) <> mtot_int
       mintamt := mintamt + ((mcredamt-mprincipal) - mtot_int)
       mprnamt  := mamort - mintamt
    endif
return nil
***************************************************************************************************
function reckon_1stosbal ( mintamt,mprnamt,mterm,mamort,mprincipal,mcredamt,mosbal,mdivisor)
***************************************************************************************************
    mdivisor := ( mterm * ( mterm+1 ) ) / 2
    mintamt  := ( (mcredamt-mprincipal)*(mterm-1) ) / mdivisor
    mprnamt  := mamort   - mintamt
    mosbal   := mcredamt - mamort
return nil

******************************************************************************
static function update_skedfile( macctno, mpaynumber, mpaydate,mamort )
******************************************************************************
//do while isholiday ( mpaydate )  ; mpaydate-- ; enddo  //Sat.|Sun.|Holidays?
//   if mpaydate != Acctdaly->MATDATE
//   endif

//aga.25.01.2008.f29 marked entry point for matdate synch
if mpaynumber == acctdaly->term
   if mpaydate != acctdaly->matdate
      if Facility->SETCODE != '5'   //aga.07.08.2008.do not update matdate if IPP patch
         if acctdaly->(netlock('R',0))
            acctdaly->matdate := mpaydate   //aga.04.03.2008.replace paytsked->paydate 
            acctdaly->(dbunlock())
            acctdaly->(dbcommit())
         end if 
      end if
   else  
      //alert(' daly matdate '+ dtos(acctdaly->matdate) + ' daly term ' + trim(str(acctdaly->term)) + ' tsked paynum ' + trim(str(mpaynumber)) + ' tsked paydate ' + dtos(mpaydate))
   end if
end if
//..............................

//aga.04.09.2006.new fields for new sked
   if Paytsked->(netlock('A',0))
      Paytsked->ACCTNO    := macctno
      Paytsked->PAYNUMBER := mpaynumber  
      Paytsked->PAYDATE   := mpaydate
      Paytsked->Amtdue    := mAmort
      Paytsked->brcode    := sbrcode          // abb 10.18.2004
      Paytsked->status    := 'D'          // due
      Paytsked->( dbunlock() )
   endif

   Paytsked->(dbcommit())
//..........................

return nil
********************************
function is_leap( myear )
********************************
   local mretval := ctod( '02/28/'+str( myear,4 ) )
return ( month(mretval+1) == 2)

/********* pepe 11:36 AM 8/1/2008 new {function browse_sked}

*************************************************
*
*
function browse_sked(_macctno,misfromsubmenu )
*************************************************
local mblock := { | x | PAYTSKED->BRCODE+Paytsked->acctno+'D' == x   .and. paytsked->status == 'D' }, cb, mdbf_, mswitch := .t., mcolor := setcolor()
local keys_  := { '<Ins>\-Add ', '<F2>\Edit ', '<F3>\Color ', '<Del>\ ', '<Esc>\' }, mscreen := savescreen( ,,, )
local tbcol_ := { tbcolumnnew( padr( "Pay't N§"      , 10 ), { || tran( Paytsked->paynumber, '@R 999'            ) } ),;
                  tbcolumnnew( padr( "Pay't Date"    , 10 ), { || tran( Paytsked->paydate  , '@D'                ) } ),;
                  tbcolumnnew( padr( "Amort/Rental", 15 )  , { || tran( Paytsked->Amtdue   , '99,999,999,999.99' ) } ) }
memvar tbkill_lastrec, ax_level, g_user_id

//aga.29.05.2006.marked for modification 

private mis_add_one := Paytsked->( dbseek( _macctno ) ), macctno := _macctno+'D'
  
mdbf_ := savedbf()   
tbkill_lastrec := 1                              

waiton( 'wait a second, please!',, 'n/w' )   

dbselectar( "Paytsked" )
if Paytsked->( dbseek( tbkill_code := macctno ) )
   Paytsked->( dbeval( { || tbkill_lastrec++, mswitch := .f. },,;
                       { || PAYTSKED->BRCODE+Paytsked->acctno+'D' == macctno } ;
                     );
             )
endif

waitoff()    
if mswitch
   if !mis_add_one
      error( "No Record Found!" )
      __keyboard( chr( K_INS ) )
   endif   
endif

Paytsked->( dbseek( macctno ) )

cb := __tb_maker( tbcol_, keys_, 6, 2, 18, 59,,, .f., macctno, mblock,,,,,,sbrcode )
Paytsked->( __tb_stabilizer( cb, { | o, k | casee100( o, k ) } ) )
//.....................................

restdbf( mdbf_ )                             
setcolor( mcolor )
restscreen( ,,,, mscreen )
return( nil )

********************************************************************
static function casee100( mbrowse, mkey )
********************************************************************
local misfromsubmenu := mreturn := .t., mcolor := setcolor(), mscreen := savescreen( ,,, )
local _nskedtotal := 0
memvar mis_add_one, ax_level, g_user_id, macctno

misfromsubmenu := if( mis_add_one, .f., misfromsubmenu )

do case
   case mkey == K_ESC

        if !prnamt_equal_to_principal(@_nskedtotal)

//aga.06.07.2005.no more slipping thru
           alert ( 'Sked total is '     + alltrim(trans ( _nskedtotal,"999,999,999.99")) + ' Credit Amount is ' + alltrim(trans ( Acctdaly->credamt,"999,999,999.99")))
//....................................
        else
           mreturn := !mreturn
        endif
   case mkey == K_INS

        if chkpass( 'A', ax_level, g_user_id )
           if payment_sked( 'A', misfromsubmenu )
              tb_refresh( mbrowse, 'a' )
           endif
        endif      
   case mkey == K_F2

        if chkpass( 'E', ax_level, g_user_id )
           *if Paytsked->acctno != macctno                  && RED 060105

//aga.29.30.2006.marked for modification
           IF PAYTSKED->BRCODE+PAYTSKED->ACCTNO+'D' != mACCTNO
              error( 'Nothing to Edit!' )
              Paytsked->( dbseek( macctno ) )       && RED 060105 REMOVED 'sbrcode+
           else  
              if payment_sked( 'E', misfromsubmenu )
                 tb_refresh( mbrowse, 'c' )
              endif
           endif
//......................................

        endif    
   case mkey == K_DEL

        if chkpass( 'D', ax_level, g_user_id )
           *if Paytsked->acctno != macctno                    && RED 060105

//aga.29.30.2006.marked for modification
           IF PAYTSKED->BRCODE+PAYTSKED->ACCTNO+'D' != mACCTNO
              error( 'Nothing to Delete!' )
              Paytsked->( dbseek( macctno ) )       && RED 060105 REMOVED 'sbrcode+
           else 
              if confirm( 'Delete Payment N§ ' + trim( tran( Paytsked->Paynumber, '@R 999' ) ) + '?' )
                 Paytsked->( netlock( 'R', 0 ) )
                 Paytsked->( dbdelete() )
                 Paytsked->( dbskip( +1 ) )
                 *if Paytsked->acctno != macctno               && RED 060105
                 IF PAYTSKED->BRCODE+PAYTSKED->ACCTNO+'D' != mACCTNO
                    Paytsked->( dbseek( macctno ) )       && RED 060105 REMOVED 'sbrcode+
                 endif
                 tb_refresh( mbrowse, 'a' )
              endif
           endif
//......................................

        endif   
   otherwise        
        mreturn := !mreturn
endcase         
setcolor( mcolor )
restscreen( ,,,, mscreen )
return( mreturn )

*********/


******************************************************
*
function prnamt_equal_to_principal ( _ntotal )  //aga.29.07.2005.removed static mod, now called by amst0100
******************************************************
//aga.29.05.2006.marked for modification
   local mrecno := Paytsked->(recno()),mamrtotal:=0
   local mretval := .t.
   Paytsked->( dbseek(Acctdaly->brcode+Acctdaly->ACCTNO+'D') )
   Paytsked->( dbeval( {|| mamrtotal += Paytsked->Amtdue },,;
                       { || Paytsked->ACCTNO == Acctdaly->ACCTNO .and. ;
                            Paytsked->brcode == Acctdaly->brcode;
                       };
                     );
             )

   if round(mamrtotal,2) != round(Acctdaly->Credamt,2)
      mretval := .f.
   endif

   _ntotal := mamrtotal
   Paytsked->(dbgoto(mrecno))
//.................................

return mretval
***************************************************
static function payment_sked( mwhat,misfromsubmenu)
***************************************************

//aga.29.05.2006.marked for modification
   local mrecno    := Paytsked->(recno()), mscr := savescreen(,,,)
   local mcursor   := setcursor(), mcolor := setcolor(), mmess
   local mcontinue := .t., mpaynumber, mpaydate, mamort
   local mrow      := 13, mcol := 4, mretval := .f., getlist := {}

   misfromsubmenu := if ( misfromsubmenu==nil, .f. , misfromsubmenu )
   mcol := if(!misfromsubmenu,mcol+=12,mcol)

   if(upper(mwhat)==chr(65),Paytsked->(dbgoto(lastrec()+1)),mwhat:=chr(82))

   mmess := if(upper(mwhat)==chr(65),'® Add Record ¯','® Edit Record ¯')

   eval({|| mpaynumber := Paytsked->PAYNUMBER, mpaydate := Paytsked->PAYDATE, mamort := Paytsked->Amtdue })

   center( 24, 'w+/n',mmess )
   fshadow ( mrow,mcol,mrow+4,mcol+37,2,'n/bg' )
   setcolor( 'w/bg, n+/w,,, w+/bg' )
   do while mcontinue
      @ mrow+1,mcol+1 say '      Payment N§ ' get mpaynumber pict '999' when (mwhat=='A') valid chkmpaynumber( mpaynumber )
      @ mrow+2,mcol+1 say '    Payment Date ' get mpaydate   pict '@D'  valid checkmpaydate( mwhat, mpaydate )   //aga.28.01.2008.f29 matdate check mod
      @ mrow+3,mcol+1 say '    Amort/Rental ' get mAmort     pict '999,999,999.99' valid mamort >=0
      setcursor( 3 )
      read
      setcursor( 0 )
      if lastkey() == K_ESC
         if esckey()
            mcontinue := .f.
         endif   
         loop
      endif
      if lastkey() == K_ENTER
         if confirm( 'Are all entries correct?' )
            if Paytsked->( netlock( mwhat, 0 ) )
               eval ( { || Paytsked->ACCTNO    := Acctdaly->ACCTNO ,;
                           Paytsked->PAYNUMBER := mpaynumber       ,;
                           Paytsked->PAYDATE   := mpaydate         ,;
                           Paytsked->brcode    := sbrcode          ,;
                           Paytsked->Amtdue    := mAmort           ,;
                           Paytsked->Status    := 'D'               ;
                      } ;
                    )
               Paytsked->( dbunlock() )
			   Paytsked->( dbcommit() )
            endif   
            mrecno:= Paytsked->(recno()) ; mcontinue := .f. ; mretval := .t.
         endif
      endif
   enddo
   Paytsked->(dbgoto(mrecno))
//........................................

//aga.25.01.2008.f29 marked entry point for matdate synch
if upper(mwhat) == chr(65)  //add
   //no code
else  //edit
   if paytsked->paynumber == acctdaly->term
      if paytsked->paydate != acctdaly->matdate
         if Facility->SETCODE != '5'   //aga.07.08.2008.do not update matdate if IPP patch
            if acctdaly->(netlock('R',0))
               acctdaly->matdate := paytsked->paydate
               acctdaly->(dbunlock())
               acctdaly->(dbcommit())
            end if   
         end if
      else
//         alert(' daly matdate ' + dtos(acctdaly->matdate) + ' daly term ' + trim(str(acctdaly->term)) + ' tsked paynum ' + trim(str(paytsked->paynumber)) + ' tsked paydate ' + dtos(paytsked->paydate))
      end if
   end if
end if
//..............................

   setcursor  (mcursor )
   setcolor   (mcolor  )
   restscreen (,,,,mscr)
return (mretval)

*****************************************
static function checkmpaydate( mwhat, mpaydate ,xterm, mterm )  //aga.28.01.2008.f29 test on edit matdate
*****************************************

//aga.29.05.2006.marked for modification
   local mretval := .t., mrecno := Paytsked->( recno() )
   do case
      case lastkey()==K_ESC .or. empty( mpaydate )
           mretval := .f.
      case Acctdaly->FIRSTDUE > mpaydate
           error ( 'Due Date is ">" Payment Date.' )
           mretval := .f.
//aga.28.01.2008.f29 test on edit matdate
//      case Acctdaly->MATDATE  < mpaydate
//           error ( 'Payment Date is ">" Maturity Date.' )
//           mretval := .f.
      case eval( { || Paytsked->( dbseek( Acctdaly->acctno ) ),                 ;
                      Paytsked->( dbeval( { || nil },,;
                                          { || Acctdaly->acctno == Paytsked->acctno .and. ;
                                               Paytsked->paydate != mpaydate .and. ;
                                               Paytsked->brcode == sbrcode ;
                                          } ;
                                        );
                                ),;
                      if( upper( mwhat ) == 'A', Paytsked->paydate == mpaydate,.f.) } )
           error ( 'Duplicate Payment Date!' )
           mretval := .f.
   endcase
   Paytsked->( dbgoto(mrecno) )
//.....................................


return (mretval)
***************************************************
static function chkmpaynumber( mpaynumber,macctno )
***************************************************

//aga.29.05.2006.marked for modification
   local mretval := .t. , mrecno := Paytsked->(recno())
   
   if lastkey() == K_ESC .or. empty( mpaynumber )
      return .f.
   endif
   Paytsked->( dbseek( sbrcode+Acctdaly->acctno+'D' ) )
   Paytsked->( dbeval ( {||nil},, ;
                        {|| Acctdaly->acctno == Paytsked->acctno .and. ;
                            Paytsked->PAYNUMBER != mpaynumber .and.;
                            Paytsked->BRCODE != sbrcode .and. Paytsked->status == 'D';
                        }) )

   if Paytsked->PAYNUMBER == mpaynumber       .and. ;
      Acctdaly->acctno    == Paytsked->acctno .and. ;
      Acctdaly->brcode    == sbrcode 
      error ( 'Payment N§ already Exists!' )
      mretval := .f.
   endif
   Paytsked->(dbgoto(mrecno))
//......................................

return mretval
*********************************
static function del_old_sked()
*********************************

//aga.29.05.2006.marked for modification
   Paytsked->( dbseek( sbrcode+Acctdaly->ACCTNO+'D' ) )
//   Paytsked->(netlock('F',0))
  // Paytsked->( dbeval( {|| Paytsked->(dbdelete()) },,;
    //                   {|| !Paytsked->(eof()) .and. ;
      //                      Paytsked->ACCTNO==Acctdaly->ACCTNO .and.;
        //                    Paytsked->BRCODE =sbrcode .and. Paytsked->status == 'D';
          //             }))
//   Paytsked->(dbunlock())

   
   Paytsked->( dbeval( {||  Paytsked->(netlock('R',0)),;
                            Paytsked->(dbdelete()) ,;
                            Paytsked->(dbunlock()) ;
                       },,;
                       {|| !Paytsked->(eof()) .and. ;
                            Paytsked->ACCTNO==Acctdaly->ACCTNO .and.;
                            Paytsked->BRCODE =sbrcode .and. Paytsked->status == 'D';
                       }))

   Paytsked->(dbcommit())


//.....................................

return nil
*********************************
function del_schedule(macctno)
*********************************
   local mscr := savescreen( ,,, )
   
   center ( 24, 'w+/n', '® Deleting Records in Payment Schedule File ¯' )

//aga.29.05.2006.marked for modification
   Paytsked->( dbseek(macctno) )
   Paytsked->( netlock ('F',0) )
   Paytsked->( dbseek(sbrcode+macctno) )
   Paytsked->( dbeval ( {|| Paytsked->(dbdelete() )},,;
                        {|| Paytsked->brcode == sbrcode .and. ;
                            Paytsked->acctno==macctno   .and. ;
                            !Paytsked->(eof()) ;
                        }) )
   Paytsked->( dbunlock())
//.....................................

   restscreen (,,,,mscr)
return nil
*
*                    End of the Program ( amst100e.prg )
*


***********************************************
*
function browse_sked(_macctno,misfromsubmenu )
***********************************************
local mcolor  := setcolor(), mscreen := savescreen( ,,, ), mm := INDEXORD(),zz := ALIAS()
private macctno := _macctno, NCTR := 0
private mfsubmenu := misfromsubmenu, mreturn := .t.

 aTranrecs := {}
 aTranpos  := {}
 _APalmSec := {}
 //aRECNO    := {}

 if !PAYTSKED->(dbseek(macctno))
     error( "No Record Found!" )
    __keyboard( chr( K_INS ) )
 endif   

 fShadow( 6, 2, 18, 47, 2, 'w+/g' ) //w+/GR

 dbselectarea('PAYTSKED')

    PAYTSKED->(dbseek(macctno+'D'))

 GBrows_sked()
 
     setcolor ( 'i/gr, w+/bg' )

     @ 7,3 say  "  Pay't N§     Pay't Date     Amort/Rental"    color 'w+/g'
	 @ 8,3 say  "ÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"  color 'w+/g'
	 
     do while .t.
	 
      fShadow( 6, 2, 18, 47, 2, 'w+/g' ) //w+/GR
	  @ 7,3 say  "  Pay't N§     Pay't Date     Amort/Rental"    color 'w+/g'
	  @ 8,3 say  "ÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"  color 'w+/g'
	  
      mBX := achoice(9, 3, 17, 46, aTranRecs, .t.,'CASEE100')

      do case
         case lastkey() == K_ESC
		      if !mreturn
				if PAYTSKED->(dbseek(macctno+'D'))
					do while .t. .and. !PAYTSKED->(eof())
						if PAYTSKED->brcode+PAYTSKED->acctno+PAYTSKED->status == macctno+'D'
							PAYTSKED->(dbskip(1))
						else
							PAYTSKED->(dbskip(-1))
							if PAYTSKED->brcode+PAYTSKED->acctno+PAYTSKED->status == macctno+'D'
							Acctdaly->(dbsetorder(1))
								if Acctdaly->(dbseek(macctno))
									 if Acctdaly->( netlock( 'R', 0 ) )
										Acctdaly->matdate := Paytsked->paydate
										//replace Acctdaly->matdate with Paytsked->paydate
										Acctdaly->( dbunlock() )
										Acctdaly->( dbcommit() )
									 endif
									exit
								else
									exit
								endif 
								Acctdaly->(dbsetorder(2))
							else
								exit
							endif
						endif
					enddo

				endif
                 exit
			  endif
  
      endcase

    restscreen     ( 9, 3, 17, 46, mscreen )
	
     enddo

    setcolor       ( mcolor )
    restscreen     ( ,,,, mscreen )
	
DBSELECTAREA(ZZ)
DBSETORDER(mm)

return mBX

**************************************
*
STATIC FUNCTION GBrows_sked()
**************************************

NCTR := 0

  dbselectarea('PAYTSKED')

     PAYTSKED->(dbseek(macctno+'D'))
//	 PAYTSKED->(dbGOTO(mRECNO))
      do while PAYTSKED->BRCODE+Paytsked->acctno+Paytsked->status == macctno+'D' .and. ;
		      !PAYTSKED->(eof()) 

		       nctr++
			   
        	    aadd ( aTranRecs,  padr(' ',' ')   		+ '   ' +   ;
                           trans ( PAYTSKED->Paynumber,"999")        	+ '     ³   ' +  ;
                           padr  ( PAYTSKED->Paydate,10)		        + '  ³ ' +  ;
                           trans ( PAYTSKED->Amtdue,"999,999,999.99")       ;
              	         )

		        aadd ( _APalmSec,PAYTSKED->brcode+Paytsked->acctno+Paytsked->status+dtos(Paytsked->Paydate)+str(Paytsked->Paynumber))

      PAYTSKED->(dbskip(+1))
      enddo
	  
	  if nctr == 0
        	    aadd ( aTranRecs,  padr(' ',' ')   		+ '   ' +   ;
                           trans ( PAYTSKED->Paynumber,"999")        	+ '     ³   ' +  ;
                           padr  ( PAYTSKED->Paydate,10)		        + '  ³ ' +  ;
                           trans ( PAYTSKED->Amtdue,"999,999,999.99")       ;
              	         )

		        aadd ( _APalmSec,PAYTSKED->brcode+Paytsked->acctno+Paytsked->status+dtos(Paytsked->Paydate)+str(Paytsked->Paynumber))
	  endif
	  
RETURN 0

****************************************************
*
FUNCTION CASEE100 (status, curr_elem, curr_row)
****************************************************
local key    := lastkey(),mSAY,cSRCH := space(10)
local __nctr := 0, getlist := {}, menulist := {},nORGPOS := 0
local _lfound := .f., mscreen1 := savescreen1( ,,, ), INDKEY := INDEXORD()
local _nskedtotal := 0

   do case
      case key == K_ESC
        if !prnamt_equal_to_principal(@_nskedtotal)

            //aga.06.07.2005.no more slipping thru
            alert ( 'Sked total is '     + alltrim(trans ( _nskedtotal,"999,999,999.99")) + ' Credit Amount is ' + alltrim(trans(Acctdaly->credamt,"999,999,999.99")))

        else
           mreturn := !mreturn
        endif
         return 0

      case key == K_INS

        if chkpass( 'A', ax_level, g_user_id )
           if payment_sked( 'A', mfsubmenu )
		      aTranrecs := {}
              _APalmSec := {}
              GBrows_sked()

           endif
        endif   
	
	return 1

   case key  == K_F2
   
        if chkpass( 'E', ax_level, g_user_id )
		
	       __mseekvar := _APalmSec[curr_elem]

           IF !PAYTSKED->(dbseek(__mseekvar))                        // PAYTSKED->BRCODE+PAYTSKED->ACCTNO+'D' != mACCTNO
              error( 'Nothing to Edit!' )
              Paytsked->( dbseek( macctno ) )
           else
 		     if Paytsked->paynumber != 0 
                if payment_sked( 'E', mfsubmenu )
		           aTranrecs := {}
                   _APalmSec := {}
                   GBrows_sked()
                endif
			 else 
                error( 'Nothing to Edit!' )
                Paytsked->( dbseek( macctno ) )
			 endif
           endif

        endif
		
		return 1
		
   case key  == K_DEL

        if chkpass( 'D', ax_level, g_user_id )

	       __mseekvar := _APalmSec[curr_elem]

           IF !PAYTSKED->(dbseek(__mseekvar))                      // PAYTSKED->BRCODE+PAYTSKED->ACCTNO+'D' != mACCTNO
              error( 'Nothing to Delete!' )
              Paytsked->( dbseek( macctno ) )
           else
		      if Paytsked->paynumber != 0 
                 if confirm( 'Delete Payment N§ ' + trim( tran( Paytsked->Paynumber, '@R 999' ) ) + '?' )
                    Paytsked->( netlock( 'R', 0 ) )
                    Paytsked->( dbdelete() )
                    Paytsked->( dbskip( +1 ) )

                    IF PAYTSKED->BRCODE+PAYTSKED->ACCTNO+'D' != mACCTNO
                       Paytsked->( dbseek( macctno ) )
                    endif
				 
		            aTranrecs := {}
                    _APalmSec := {}
                    GBrows_sked()
				 endif
		      else
                 error( 'Nothing to Delete!' )
                 Paytsked->( dbseek( macctno ) )
              endif
           endif

        endif

		return 1

    endcase

RETURN  2
