/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   program ID.........:  amsm400f.prg                                         ³
³   description........:  Printing of Schedule of Payment                      ³
³   author.............:  Ariel B. Bulan                                       ³
³   date...............:  02:15pm 03-Mar-1995                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                         U P D A T E S                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        Who        ³     When      ³               Why                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        aga        ³  14.02.2007   ³  neo paysked support for modules         ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
#include "Colf.ch"
#include "Inkey.ch"

****************************************
*
function printsked ( macctno )
****************************************
   memvar ax_level,g_user_id
   if chkpass( procname(),ax_level,g_user_id )
      *repcontrol('print_schedule()',,,8,33)
      repcon_ol('print_schedule()',,,8,33,,,.F.)
   endif
return nil
****************************************
*
function print_schedule()
****************************************
   local  mdbf     := savedbf ( mdbf )
   local  mdivisor := ( Acctmast->TERM*(Acctmast->TERM+1) ) / 2
   local  mosbal   := Acctmast->Osbal
   local  ncredamt := Acctmast->credamt
   LOCAL  mudi     := Acctmast->Credamt - ( Acctmast->Principal + Acctmast->Incentive )
   local  nntx := Paysked->(indexord())
   private mpage    := 1, nremterm := 0

   setprc ( 0, 0 )
   heading(mpage )

//aga.28.06.2006.first gen only
   if Payimage-> ( dbseek( ACCTMAST->BRCODE+Acctmast->ACCTNO  ) )
      devpos( prow()+1, 47 ) 
      devoutpict( ncredamt , "99,999,999,999.99" )
      Payimage-> ( dbeval( {|| print_rec( @ncredamt ) },,;
                           {|| !Payimage->(eof()) .and. ;
                               PAYIMAGE->BRCODE+Payimage->ACCTNO==ACCTMAST->BRCODE+Acctmast->ACCTNO ;
                           };
                         );
                 )
   else
      Paysked->(dbsetorder(3))   // brcode+acctno+paydate+status
      // alert ( Paysked->(indexkey()) )
      if Paysked-> ( dbseek( ACCTMAST->BRCODE+Acctmast->ACCTNO  ) )
         devpos( prow()+1, 47 )
         // devoutpict( ncredamt , "99,999,999,999.99" )
         devoutpict( Acctmast->OSBAL , "99,999,999,999.99" )
         ncredamt := Acctmast->OSBAL

//         Paysked-> ( dbeval( {||
  //                               print_rc2( @ncredamt )
    //                             },,;
      //                       {|| !Paysked->(eof()) .and. ;
        //                       Paysked->BRCODE+Paysked->ACCTNO==ACCTMAST->BRCODE+Acctmast->ACCTNO ;
          //                   };
            //               );
              //     )

         do while Paysked->BRCODE+Paysked->ACCTNO==ACCTMAST->BRCODE+Acctmast->ACCTNO .and. ;
                  !Paysked->(eof())

            dpaydate := Paysked->PAYDATE
            //if empty(dpaydate)
            //   Paysked->(dbskip(+1))
            //   loop
            //endif
            if Paysked->STATUS == 'D'
               print_rc2( @ncredamt )
            endif

            //do while Paysked->BRCODE+Paysked->ACCTNO==ACCTMAST->BRCODE+Acctmast->ACCTNO .and. ;
            //        !Paysked->(eof()) .and. ;
            //         Paysked->PAYDATE == dpaydate
               Paysked->(dbskip(+1))
           // enddo

         enddo

      end if

   end if 
//.......................
   __eject()

   Paysked->(dbsetorder(nntx))
   restdbf   ( mdbf )
return nil

*********************************************
*
static function print_rc2( mOsbal )
*********************************************
   //static mosbal := 0
   local  mcol   := { 11,17,30,47 }
   memvar mpage

   mOsbal -= Paysked->Amtdue
   @ prow()+1, mcol[1] say Paysked->Paynum      pict '999'     //Paysked ->PAYNUM

   @ prow()  , mcol[2] say Paysked->PAYDATE     pict '@D'
   @ prow()  , mcol[3] say Paysked->amtdue       pict '999,999,999.99'
   @ prow()  , mcol[4] say mosbal                pict '99,999,999,999.99'

   if( prow()>56, eval({|| __eject(),mpage++, heading(mpage) }), nil )

return nil

*********************************************
*
static function print_rec( mOsbal )
*********************************************
   //static mosbal := 0
   local  mcol   := { 11,17,30,47 }
   memvar mpage

//aga.28.06.2006.not used
   mOsbal -= Payimage->Amort
   @ prow()+1, mcol[1] say Payimage->Paynum      pict '999'     //Paysked ->PAYNUM

   @ prow()  , mcol[2] say Payimage->PAYDATE     pict '@D'
   @ prow()  , mcol[3] say Payimage->AMORT        pict '999,999,999.99'
   @ prow()  , mcol[4] say mosbal                pict '99,999,999,999.99'
//.......................

   if( prow()>56, eval({|| __eject(),mpage++, heading(mpage) }), nil )

return nil



****************************************
*
static function heading( mpage,sw )
****************************************
   memvar gcompany, gsys_name, gheadmess
   local  mtitle  :=  'PAYMENT SCHEDULE'
   sw := if( sw == nil,.t.,.f. )
   mtitle  := if ( sw,;
                   'PAYMENT SCHEDULE',;
                   'UDI/ALIR SCHEDULE' ;
                 )

   prnreptitle   ( 79,01,mpage,mtitle,'Amst100f',gsys_name,gcompany )
   print_head    ( )
   print_subhead ( sw )
return nil
****************************************
*
static function print_subhead( sw )
****************************************
   local mleft := 17
   //sw := if( sw == nil,.t.,.f. )

   setfont ( 'PICA' )

   if sw
      @ prow()+2, mleft say  'ÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
      @ prow()+1, mleft say  ' PAYMENT      AMORTIZATION/      O/S BALANCE   '
      @ prow()+1, mleft say  '  DATE           RENTAL                        '
      @ prow()+1, mleft say  'ÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   else
      @ prow()+2, mleft say  'ÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
      @ prow()+1, mleft say  ' MATURITY         ALIR/           ALIR/UDI     '
      @ prow()+1, mleft say  '   DATE            UDI            BALANCE      '
      @ prow()+1, mleft say  'ÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   endif

return nil
****************************************
*
static function print_head()
****************************************

   @ prow()+2, 00     say 'Account Number     : '
   @ prow()  , pcol() say ACCTMAST->BRCODE+Acctmast->ACCTNO    pict '@R 999-9999-99999-99999'
   @ prow()  , 53     say 'Availment Date : '
   @ prow()  , pcol() say dtoc(Acctmast->VALDATE)

   @ prow()+1, 00     say 'Client Code/Name   : '
   @ prow()  , pcol() say ACCTMAST->BRCODE+Acctmast->CLNTCODE  pict '@R 999-99-99999'
   @ prow()  , pcol() say ' '+upper(dispclntname(ACCTMAST->BRCODE+Acctmast->CLNTCODE,40))    && RED 032105 ADDED 'ACCTMAST->BRCODE+

   @ prow()+1, 00     say 'Facility Code/Name : '
   @ prow()  , pcol() say Acctmast->FCLTYCODE pict '@R 999-99'
   @ prow()  , pcol() say '   '+ dispfcltyname(Acctmast->FCLTYCODE)

   @ prow()+1, 00     say 'Net Proceeds       : '
   @ prow()  , pcol() say ltrim(transform (Acctmast->PRINCIPAL,'999,999,999.99'))

   @ prow()+1, 00     say 'Term               : '
   @ prow()  , pcol() say ltrim(transform (Acctmast->TERM,'999'))
   @ prow()  , pcol() say space(7) + if(Acctmast->TERMUNIT $ '12', if( Acctmast->TERMUNIT=='1','DAYS    ','MONTH(S)'),space(8))

   @ prow()+1, 00     say 'True Rate          : '
   @ prow()  , pcol() say Acctmast->TRUERATE   pict '99.99999'
   @ prow()  , pcol() say ' '+upper (dispratetype(Acctmast->RATETYPE))

   @ prow()+1, 00     say 'VAT Inclusive      : '

   if Acctmast->vatincl
      @ prow()  , pcol() say 'Yes'
   else
      @ prow()  , pcol() say 'No'
   endif


return nil
/*-------------------------------*/
  Function print_udi( xAcctno )
/*-------------------------------*/
if chkpass( procname(),ax_level,g_user_id )
   *repcontrol( 'fPrint_udi2()' )
   repcon_ol( 'fPrint_udi2()',,,,,,,.F. )
endif
return nil

************************************
*
function fPrint_udi2()
************************************
local mdbf   := select ()
local mcolor := setcolor ()
local mterm  := Acctmast->TERM, mamort := Acctmast->AMORT
local mprincipal := Acctmast->PRINCIPAL, mcredamt := Acctmast->CREDAMT
local mstep := 0,mincent := Acctmast->Incentive
PRIVATE mpage    := 1

 heading  ( mpage,.f. )
 mcredamt += ( Acctmast->Rv/100 ) * Acctmast->Principal
 devpos   ( prow()+1, 47 )
******* devoutpict ( mcredamt-( mprincipal + mincent ), "99,999,999,999.99" )
 devoutpict ( Acctmast->udiamt, "99,999,999,999.99" )

 eval( {|| Facility->(dbseek(Acctmast->Fcltycode)) } )

   do case
      case Acctmast->Payfreq $ '12345'
           mstep := 1

           if Acctmast -> TERMUNIT == '1'
              mterm := int(mterm / 30) + if( mterm % 30 <> 0,1,0)
           endif


           fPrnudi002 ( mterm,mamort,mprincipal,mcredamt,mstep,mincent )

      case Acctmast->PAYFREQ $ '67'            // Lumpsum

           mpaydate:= Acctmast->Valdate

           if Facility->SETCODE $ '45'
              if Acctmast -> TERMUNIT == '1'
                 mterm := int(mterm / 30) + if( mterm % 30 <> 0,1,0)
              endif
              fPrn_udinow( mterm,mamort,mprincipal,mcredamt,Acctmast->Matdate,mincent )
           else
              if Acctmast -> TERMUNIT == '1'
                 mterm := int(mterm / 30) + if( mterm % 30 <> 0,1,0)
              endif
              fPrnudi002( mterm,mamort,mprincipal,mcredamt,mstep,mincent )
           endif
      endcase
      __eject()
   dbselectarea(mdbf);setcolor(mcolor)
return nil

*********************************************************************
static function fPrn_udinow( mterm,mamort,mprincipal,mcredamt,mMatdate,mincent )
*********************************************************************
local mdivisor  := ( mterm * ( mterm+1 ) ) / 2, xix ,org_term:=mterm,udibal
local macctno   := ACCTMAST->BRCODE+Acctmast->ACCTNO, mpaydate := Acctmast->Valdate,ndeff
local mtermunit := '2', mpaynumber := 0, mintamt, mprnamt, mosbal, moldmdays
local org_int   := mCredamt - ( mPrincipal + mincent ) ,var_intr,mrefdate,tot_int:=0


/*******************
udibal  := org_int
var_int := org_int / ( mMatdate-mPaydate )
moldmdays  := day ( mpaydate )
mrefdate := mpaydate
for xix := 1 to mterm
    mpaynumber++
    comp_spred( @mpaydate, @mintamt, mMatdate, var_int, org_term, xix, mrefdate, mincent )
    tot_int += round( mIntamt,0 )
    if xix == mterm .and. tot_int <> org_int
       ndeff := org_int - tot_int
       mintamt += ( ndeff )
    endif
    udibal -= mintamt
    fprnudi01( udibal )
    mrefdate := getrefdt(mpaydate)

next xix
*********************/

if Udispred->(dbseek(ACCTMAST->BRCODE+acctmast->acctno))

   // nudibal := Acctmast->udibal
   nudibal := Acctmast->udiamt
   mdeff   := 0


   do while Udispred->BRCODE+Udispred->acctno == Acctmast->BRCODE+Acctmast->acctno .and. !Udispred->(eof())
      nudibal -= Udispred->intamt
      fprnudi01 ( nudibal )
      Udispred->( dbskip(+1) )
   enddo

endif

//adjust_int( tot_int,org_int)
return nil

/*--------------------------------------------------------------------------------*/
 STATIC Function comp_spred(mpaydate, mintamt, mMatdate, var_int, org_term, mTerm,mrefdate )
/*--------------------------------------------------------------------------------*/
 local ldate := lastday(mrefdate)

 ldate    := if(mterm < org_term , ldate, mmatdate)
 mIntamt  := round( ( ldate-mPaydate ) * var_int ,0 )
 mpaydate := ldate
 return nil

*********************************************************************
*
static function fPrnudi002( mterm,mamort,mprincipal,mcredamt,mstep, mincent )
*********************************************************************
local mdivisor := ( mterm * ( mterm+1 ) ) / 2, xix,udibal
local macctno := Acctmast->BRCODE+Acctmast->ACCTNO, mpaydate := Acctmast->Valdate, tot_int:=0
local mtermunit := '2', mpaynumber := 0, mintamt, mprnamt, mosbal, moldmdays
local org_int := mCredamt - ( mprincipal + mincent ),ndeff

/*******************
udibal := org_int
moldmdays  := day ( mpaydate )
for xix := mterm to 1 step - 1
    mpaynumber++
    mintamt := round( ( ( mcredamt-( mprincipal + mincent ) ) * xix ) / mdivisor,0 )
    tot_int += round( mIntamt, 0 )
    if xix == 1 .and. tot_int <> org_int
       ndeff := org_int - tot_int
       mintamt += ( ndeff )
    endif
    udibal -= mintamt
    fprnudi01 ( macctno  ,mpaynumber,mpaydate,mintamt,udibal )
    spred_matdate   ( @mpaydate,mtermunit ,mstep, moldmdays )
next xix
******************/

if Udispred->(dbseek(ACCTMAST->BRCODE+acctmast->acctno))

   // nudibal := Acctmast->udibal
   nudibal := Acctmast->udiamt
   mdeff   := 0

   do while UDISPRED->BRCODE+Udispred->acctno == Acctmast->BRCODE+Acctmast->acctno .and. !Udispred->(eof())

      if Acctmast->vatincl
//          nudibal -= Udispred->interest           // abb 08.29.2003
         nudibal -= Udispred->intamt // MALI PALA DAPAT NET PALA 10.01.2003
      else
         nudibal -= Udispred->intamt
      endif


      fprnudi01 ( nudibal )
      Udispred->( dbskip(+1) )
   enddo

endif

// adjust_int(tot_int, mCredamt-( mprincipal + mincent ))

return nil

*****************************************************************
static function spred_matdate ( mpaydate,mtermunit,mstep,olddays )
*****************************************************************
local mmonth := month( mpaydate ), myear := year( mpaydate )
local mdays  := olddays, i ,array1_:= { 4,6,9,11 }

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
        ELSE
           if mdays > 30
              mdays := if( ascan( array1_, mmonth ) <> 0, 30, 31 )
           endif
        endif
        mpaydate := ctod( ltrim( str( mmonth, 2, 0 ) ) + '/' +;
                          ltrim( str( mdays , 2, 0 ) ) + '/' +;
                          ltrim( str ( myear, 4, 0 ) ) )
    endcase
return .t.

/*------------------------------------------------------------------------*/
********
******** static Function fprnudi01( macctno,mpaynumber,mpaydate,mintamt,udibal)
********
static function fprnudi01 ( nudibal )
/*------------------------------------------------------------------------*/
 local ncol_:= { 11,17,30,47 }

/*********
 @ prow()+1, ncol_[1] say trans( mpaynumber,'999' )
 @ prow()  , ncol_[2] say dtoc(mpaydate)
 @ prow()  , ncol_[3] say trans( mintamt,'999,999,999.99' )
 @ prow()  , ncol_[4] say trans( udibal, '99,999,999,999.99' )
********/

 @ prow()+1, ncol_[1] say trans( Udispred->paynum,'999' )
 @ prow()  , ncol_[2] say dtoc ( Udispred->paydate )

** if Acctmast->vatincl
  **  @ prow()  , ncol_[3] say trans( Udispred->interest,'999,999,999.99' )
** else

    @ prow()  , ncol_[3] say trans( Udispred->intamt,'999,999,999.99' )

** endif

 @ prow()  , ncol_[4] say trans( nudibal, '99,999,999,999.99' )


 if ( prow()>56,;
      eval({|| __eject(),mpage++, heading(mpage,.f.) }),;
      nil ;
    )

return nil

*
*                     End of the program ( amsm400i.prg )
*
