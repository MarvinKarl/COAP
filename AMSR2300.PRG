/*
 ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³   program ID.........:  amsr2300.prg                                 ³
 ³   description........:  aging of past-due receivables                ³
 ³   author.............:  Ariel B. Bulan                               ³
 ³   date...............:  01:49pm 12-Nov-1994                          ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³                         U P D A T E S                                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³        Who        ³     When      ³               Why                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³ Renan Evangelista ³  1997 - 1998  ³ columns of days past due must    ³
 ³                   ³               ³ reflect o/b, not the past due amt³
 ³                   ³               ³ (industry practice)              ³
 ³ Janet B. Salvador ³  19-Jan-1999  ³ add new acctno                   ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include "COLF.CH"
#include "INKEY.CH"

#define MAXROW 54

memvar ax_level,g_user_id
if chkpass( procname(),ax_level,g_user_id )
   if amsr0400open()
      amsr0400main()
   endif
   eval ({|| __mrelease( "*", .t.), dbcloseall() })
endif
return
******************************
static function amsr0400main()
******************************
   local  mdbf   := savedbf (mdbf), mcolor := setcolor(), mcursor := setcursor()

   memvar gtrandate
   private mpage := 1,mmonth,mdays,myear,mtitle,mlm,mdate
   mtitle := 'Aging of Past-Due Receivables'; mlm := 0 ; mdate  := gtrandate
   do while get_mdate( 7 )
      mpage := 1
      eval ({|| mmonth := month(mdate) ,;
                mdays  := day(mdate)   ,;
                myear  := year(mdate)  ,;
                repcon_ol ( 'amsr0400print()','132 Column<Cont.>',,8,33,,,.F.) ;     &&repcontrol ( 'amsr0400print()','132 Column<Cont.>',,8,33) ;
           })
   enddo
   setcolor  (mcolor); setcursor (mcursor) ; restdbf   (mdbf)
return nil
******************************
function amsr0400print()
******************************
    memvar mdate
    local   mclntcode,t_rec:=0, nrec := 1
    private mamort,m1_30,m31_60,m61_90,m91_180,m180_above,mtpastdue,mosbal,totpastdue := 0
    private mpamort,mp1_30,mp31_60,mp61_90,mp91_180,mp180_above,mptpastdue,mposbal,ncurosbal := 0
    private mgamort,mg1_30,mg31_60,mg61_90,mg91_180,mg180_above,mgtpastdue,mgosbal
    private new := .t.,nosbal := 0
    mpamort:= mp1_30 := mp31_60:= mp61_90 := mp91_180 := mp180_above := mptpastdue := mposbal :=0
    mgamort:= mg1_30 := mg31_60:= mg61_90 := mg91_180 := mg180_above := mgtpastdue := mgosbal :=0
    setprc(0,0)  ; @ prow(),pcol() say chr(15)
    print_head() ; setfont('CONDENSED');print_subhead()
    @ prow()+1,00 say ''

    Acctmast->(dbgotop())
    //altd()

    Acctmast->(dbeval({|| if ( val( Acctmast->STATUS) < 3 .and. Acctmast->STATUS  != '0' .and. Acctmast->Valdate <= mdate,;
                          eval ({ || mclntcode := Acctmast->Acctname ,;
                                     if ( !Acctmast->(deleted()),;
                                          nil,;
                                          nil ;
                                        ) ,;
                                     Acctmast->( dbeval({|| if( val( Acctmast->STATUS ) < 3 .and. Acctmast->STATUS  != '0' .and. ;
                                                                !_employee_loans(Acctmast->fcltycode),;
                                                                eval({||  ; //Paysked->(dbseek(Acctmast->ACCTNO+dtos(mdate),.t.)),
                                                                        nosbal  := _get_outs() ,;
                                                                        traverse_sked()        ,; // mgosbal += Acctmast->Osbal ;
                                                                        mgosbal += nosbal       ;
                                                                    }),;
                                                                nil ;
                                                              )},,;
                                     {|| !Acctmast->(eof()) .and. Acctmast->Acctname == mclntcode } )),;
                                     Acctmast->( dbskip(-1) )         ;
                                }),;
                          nil ) ;
                      } ,,;
                      {|| !Acctmast->(eof())} ;
                     )                        ;
              )
    page_grand_total( mpamort,mp1_30,mp31_60,mp61_90,mp91_180,mp180_above,mptpastdue,mposbal,'Page Total')
    page_grand_total( mgamort,mg1_30,mg31_60,mg61_90,mg91_180,mg180_above,mgtpastdue,ncurosbal,'Grand Total')
    __eject()
    percentage ( mg1_30,mg31_60,mg61_90,mg91_180,mg180_above,mgtpastdue,mgosbal,ncurosbal )
    __eject()
return nil
/*
****************************************************
*
static function _employee_loans(cfcltycode)
****************************************************
   local lretval := .f.

   if cfcltycode == '10451' .or. cfcltycode == '10452' .or. ;
      cfcltycode == '10453' .or. cfcltycode == '10454'
      lretval := .t.
   endif

return lretval
*/
********************************
static function print_clntcode()
********************************
 if Paysked->(dbseek( Acctmast->Acctno)) .and. Paysked->Paydate + 5 < mdate ;
    .and. chkacct() > Acctmast->Amort * 0.10
   new := .t.
   eval ({|| devpos(prow()+1,000)                              ,;
             devoutpict (Acctmast->CLNTCODE,'@R 99-99999')     ,;
             devpos(prow()  ,9)                                ,;
             devout(left(dispclntname(Acctmast->BRCODE+Acctmast->CLNTCODE,40),20))  ;
        })
 endif
return nil
//////////
********************************
*
Static function Chkacct()
********************************
local mval,retval:=0

      mval:= if( Paysked->Paydate + 5 > mdate, 5, 0 )
      while Paysked->ACCTNO == Acctmast->ACCTNO .and. Paysked->Paydate <= mdate
         if Paysked->Paydate + mval < mdate
            retval += Paysked->Amort
         endif
         Paysked->(dbskip(1))
      enddo
return retval

*******************************
static function traverse_sked()
*******************************
    local  mclntno  ,macctno, mu := 0,mval:=0
    local  mnextpaydate,mmatdate,mpayfreq,mremterm:=0,date_ok := .f.
    local  mdiffdate:=0,mdiff := 0,sw:=.f., p_due:= .f.
    memvar mdate
    memvar mamort,m1_30,m31_60,m61_90,m91_180,m180_above,mtpastdue,mosbal
    memvar mpamort,mp1_30,mp31_60,mp61_90,mp91_180,mp180_above,mptpastdue,mposbal
    memvar mgamort,mg1_30,mg31_60,mg61_90,mg91_180,mg180_above,mgtpastdue,mgosbal

    //altd()
    mamort := m1_30  := m31_60 := m61_90  := m91_180  := m180_above  := mtpastdue  := mosbal  :=0
    //mnextpaydate := if( Paysked->ACCTNO==Acctmast->ACCTNO , Paysked->PAYDATE,space(10) )
    //mremterm     := Acctmast->TERM-Paysked->PAYNUM
    Paysked->(dbseek(Acctmast->ACCTNO))
    mu := Paysked->(recno())

    Paysked->(dbeval({ || mremterm++ },,{ || Paysked->Acctno == Acctmast->Acctno}))
    Paysked->(dbgoto(mu))

    mclntno  := Acctmast->CLNTCODE
    macctno  := right(Acctmast->ACCTNO,5)
    mamort   := Acctmast->AMORT
    mmatdate := if( empty(dtos(Acctmast->MATDATE)),space(10),Acctmast->MATDATE )
    mpayfreq := Acctmast->PAYFREQ
    // disp_payment_freq( Acctmast->PAYFREQ )

    If Paysked->(dbseek(Acctmast->ACCTNO,.t.))  .and. Paysked->Paydate <= mdate
       mosbal   := Acctmast->OSBAL
       mnextpaydate := if( Paysked->Amort > Acctmast->Amort * 0.10 ,eval( {|| sw:=.t.,Paysked->Paydate }),nil )
       mval     := if( Paysked->Paydate + 5 > mdate, 5, 0 )
       while Paysked->ACCTNO == Acctmast->ACCTNO .and. Paysked->Paydate <= mdate
         if Paysked->Paydate + if( p_due, 0, 5) <= mdate      //ADD 5 DAYS
            mnextpaydate := if( !sw, eval({|| sw:=.t.,Paysked->Paydate }),mnextpaydate )
            mtpastdue    += Paysked->Amort
            if ( ( Paysked->Amort ) > ( Acctmast->Amort * .10 ) )
               p_due     := .t.
               //mdiffdate++ //+= mdate - Paysked->Paydate
               mdiffdate := if( !date_ok, eval({ || date_ok := .t., mdate - Paysked->Paydate } ), mdiffdate )
            else
               sw:=.f.
            endif
         endif
         Paysked->(dbskip(1))
       enddo
       do case
          case mdiffdate >= 181
            m180_above := mosbal
          case mdiffdate >= 091
            m91_180    := mosbal
          case mdiffdate >= 061
            m61_90     := mosbal
          case mdiffdate >= 031
            m31_60     := mosbal
          case mdiffdate >= 001
            m1_30      := mosbal
            mtpastdue := if( mtpastdue > Acctmast->Amort * .10, mtpastdue, 0 )
       endcase
       if mtpastdue > 0 .and. mdiffdate > 0
          //totpastdue += mtpastdue
          mosbal   := Acctmast->OSBAL
          print_it( macctno,mamort,m1_30,m31_60,m61_90,m91_180,m180_above,mtpastdue,mosbal,mnextpaydate,mmatdate,mpayfreq,mremterm)
          new := .f.
       else
          mosbal := 0
       endif
       //@ prow()+1, 00 say ''
    endif
    mpamort     += mamort    ; mp1_30      += m1_30
    mp31_60     += m31_60    ; mp61_90     += m61_90
    mp91_180    += m91_180   ; mp180_above += m180_above
    mptpastdue  += mtpastdue ; mposbal     += mosbal
    mgamort     += mamort    ; mg1_30      += m1_30
    mg31_60     += m31_60    ; mg61_90     += m61_90
    mg91_180    += m91_180   ; mg180_above += m180_above
    mgtpastdue  += mtpastdue //; mgosbal     += mosbal
    ncurosbal   += mosbal
    if (prow() >= MAXROW)
       mpage++
       page_grand_total( mpamort,mp1_30,mp31_60,mp61_90,mp91_180,mp180_above,mptpastdue,mposbal,'Page Total',.t.)
       //ncurosbal += mposbal
       mpamort:= mp1_30 := mp31_60:= mp61_90 := mp91_180:= mp180_above:= mptpastdue:= mposbal :=0
       __eject()
       SETPRC( 0,0 )
       @ prow()+1, 00 say 'Page : ' + trans(mpage, '999' )
       print_subhead()
    endif
return nil
*******************************************************************************************************
 static function percentage (mg1_30,mg31_60,mg61_90,mg91_180,mg180_above,mgtpastdue,mgosbal,ncurosbal)
*******************************************************************************************************
    local mcol  := { 37,43,62,81,100,119,138,157,176,195,206,217,223 }
    local u,v,w,x,y,z
    print_head()
    setfont ('NLQ')
    setfont ('BOLD')
    @ PROW  ()+2, 10
    setfont ('UNDERLINE')
    @ prow  ()  ,PCOL() say 'Percentage to Total Receivables'
    setfont ('OFFUNDERLINE')
    setfont ('UNBOLD')
    v := ( mg1_30+mg31_60+mg61_90+mg91_180+mg180_above )
    **************** alert(str(mgosbal))
    @ prow()+2, 10 say 'C U R R E N T             :'+ spac(4) + tran( u:= ( mgosbal - ncurosbal ),'99,999,999,999.99' ) + spac(10) + trans( getpercent( u, mgosbal ),'999.99') + ' %'
    @ PROW()+1, 10 say '01 - 30  Days Past Due    :'+ spac(4) + tran( mg1_30     ,'99,999,999,999.99' ) + spac(10) + trans( getpercent( mg1_30     ,mgosbal ),'999.99' ) + ' %'
    @ PROW()+1, 10 say '31 - 60  Days Past Due    :'+ spac(4) + tran( mg31_60    ,'99,999,999,999.99' ) + spac(10) + trans( getpercent( mg31_60    ,mgosbal ),'999.99' ) + ' %'
    @ PROW()+1, 10 say '61 - 90  Days Past Due    :'+ spac(4) + tran( mg61_90    ,'99,999,999,999.99' ) + spac(10) + trans( getpercent( mg61_90    ,mgosbal ),'999.99' ) + ' %'
    @ PROW()+1, 10 say '91 - 180 Days Past Due    :'+ spac(4) + tran( mg91_180   ,'99,999,999,999.99' ) + spac(10) + trans( getpercent( mg91_180   ,mgosbal ),'999.99' ) + ' %'
    @ PROW()+1, 10 say '181 Days and Above        :'+ spac(4) + tran( mg180_above,'99,999,999,999.99' ) + spac(10) + trans( getpercent( mg180_above,mgosbal ),'999.99' ) + ' %'
    @ prow()+1, 10 say '                           '+space(4) + repl('-',17 )+space(10) + repl('-',6 )
    @ prow()+1, 10 say 'T O T A L                 :'+ spac(4) + tran( v+u,'99,999,999,999.99' ) + spac(10) + trans( 100,'999.99') + ' %'
    @ prow()+1, 10 say '                           '+space(4) + repl('=',17 )+space(10) + repl('=',6 )
    setfont('NORMAL')
return nil
/*
************************************************
static function getpercent( mdividend,mdivisor )
************************************************
   local mretval := 0
   mretval := ( mdividend/ if(mdivisor==0,1,mdivisor) ) * 100
return mretval
*/
**********************************************************************************************************
static function page_grand_total( mamort,m1_30,m31_60,m61_90,m91_180,m180_above,mtpastdue,mosbal,mmessage)
**********************************************************************************************************
    local mcol  := { 37,43,62,81,100,119,138,157,176,195,206,217,224 }
    @ prow()+1, 000 say "                                           ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
    @ prow()+1, 000      say mmessage       
    @ prow()  , mcol[2]  say mamort     pict '999,999,999,999.99'
    @ prow()  , mcol[3]  say m1_30      pict '999,999,999,999.99'
    @ prow()  , mcol[4]  say m31_60     pict '999,999,999,999.99'
    @ prow()  , mcol[5]  say m61_90     pict '999,999,999,999.99'
    @ prow()  , mcol[6]  say m91_180    pict '999,999,999,999.99'
    @ prow()  , mcol[7]  say m180_above pict '999,999,999,999.99'
    @ prow()  , mcol[8]  say mtpastdue  pict '999,999,999,999.99'
    @ prow()  , mcol[9]  say mosbal     pict '999,999,999,999.99'
return nil

*******************************************************************************
*
static function compute_first(m1_30,m31_60,m61_90,m91_180,m180_above,mtpastdue)
*******************************************************************************
    memvar mdate
    local mdiffdate

    mdiffdate    := mdate-Paysked->PAYDATE
    do case
       case mdiffdate >= 181
            m180_above += Paysked->Amort
            mtpastdue  += m180_above
       case mdiffdate >= 091
            m91_180    += Paysked->Amort
            mtpastdue  += m91_180
       case mdiffdate >= 061
            m61_90     += Paysked->Amort
            mtpastdue  += m61_90
       case mdiffdate >= 031
            m31_60     += Paysked->Amort
            mtpastdue  += m31_60
       case mdiffdate >= 001
            m1_30      += Paysked->Amort
            mtpastdue  += m1_30
    endcase

return nil
*****************************************************************************************************************************************
static function print_it( macctno,mamort,m1_30,m31_60,m61_90,m91_180,m180_above,mtpastdue,mosbal,mnextpaydate,mmatdate,mpayfreq,mremterm)
*****************************************************************************************************************************************
    local mcol := { 37,43,62,81,100,119,138,157,177,197,209,224 }
    eval ({|| devpos(prow()+1,000)                              ,;
             devoutpict (substr( Acctmast->Oldno,1,13 ),'@!')     ,;
             devpos(prow()  ,14)                                ,;
             devout(substr(ACCTMAST->ACCTNO,10,5))              ,;
             devpos(prow(),20)                                  ,;
             devout(left(dispclntname(Acctmast->BRCODE+Acctmast->CLNTCODE,40),22))  ;
        })
    //@ prow(), mcol[1]  say macctno      pict '99999'
    @ prow(), mcol[2]  say mamort       pict '999,999,999,999.99'
    @ prow(), mcol[3]  say m1_30        pict '999,999,999,999.99'
    @ prow(), mcol[4]  say m31_60       pict '999,999,999,999.99'
    @ prow(), mcol[5]  say m61_90       pict '999,999,999,999.99'
    @ prow(), mcol[6]  say m91_180      pict '999,999,999,999.99'
    @ prow(), mcol[7]  say m180_above   pict '999,999,999,999.99'
    @ prow(), mcol[8]  say mtpastdue    pict '999,999,999,999.99'
    @ prow(), mcol[9]  say mosbal       pict '999,999,999,999.99'
    @ prow(), mcol[10] say mnextpaydate
    @ prow(), mcol[11] say mmatdate
    //@ prow(), mcol[12] say mpayfreq     pict '@X'
    @ prow(), mcol[12] say mremterm     pict '999'
return nil
******************************
static function print_head()
******************************
    memvar mtitle,mpage,gsys_name,gcompany,mlm,mmonth,mdays,myear
    eval ({|| ;
       mtitle := 'Aging of Past-Due Receivables',;
       prnreptitle  ( 132,mlm,mpage,mtitle,'Program ID:AMSR0400',gsys_name,gcompany),;
       pagecenter   ( prow()+1,132,'As of '+fr0100month( trans(mmonth,'99') )+' '+trans(mdays,'99')+', '+trans(myear,'9999') );
       })
       @ prow()+1,0 say ''
       //,mpage++;
return nil
*******************************
static function print_subhead()
*******************************
setfont('CONDENSED')
    eval({|| ;
devpos( prow()+1, 00 ) , devout( "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ " ),;
devpos( prow()+1, 00 ) , devout( "Client LA No./Name                         Amortization       1-30 Days          31-60 Days         61-90 Days         91-180 Days        180 Days Above     Total Past Due       Outstanding           Next      Maturity    Remaining " ),;
devpos( prow()+1, 00 ) , devout( "                                                                                                                                                                                    Balance           Pay Date      Date         Term   " ),;
devpos( prow()+1, 00 ) , devout( "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ " );
        })
/*
           1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7
 012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ " ),;
 Client Code/name                           Amortization       1-30 Days          31-60 Days         61-90 Days         91-180 Days        180 Days Above     Total Past Due       Outstanding           Next      Maturity    Remaining " ),;
                                                                                                                                                                                    Balance           Pay Date      Date         Term   " ),;
 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ " );
 1234567890123 1234567890123456789012345678 999,999,999,999.99
          Percentage to Total Receivable

          C U R R E N T             :    99,999,999,999.99         99.99 %
          01 - 30  Days Past Due    :    99,999,999,999.99         99.99 %
          31 - 60  Days Past Due    :    99,999,999,999.99         99.99 %
          61 - 90  Days Past Due    :    99,999,999,999.99         99.99 %
          91 - 180 Days Past Due    :    99,999,999,999.99         99.99 %
          180 Days and Above        :    99,999,999,999.99         99.99 %
                                         -----------------        ------
          T O T A L                 :    99,999,999,999.99        100.00 %
                                         =================        ======

        devpos( prow()+2, 00 ) , devout( "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ " ),;
        devpos( prow()+1, 00 ) , devout( "Client Code/Name                    Acctno Amortization       1-30 Days          31-60 Days         61-90 Days         91-180 Days        180 Days Above     Total Past Due      Outstanding          Next     Maturity   Freq. Remaining " ),;
        devpos( prow()+1, 00 ) , devout( "                                                                                                                                                                                   Balance          Pay Date     Date             Term    " ),;
        devpos( prow()+1, 00 ) , devout( "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ " );

        })
*/
return nil

****************************
*
static function _get_outs( )
****************************
   local nretval := Acctmast->credamt, ddate := ctod ('')
   local dretval := ctod('')
   local pgn:=1
   local tot_amrt := 0, tot_pen := 0, npent_s := 0,ncredamt:= Acctmast->Credamt
   local Pay_:={ 'Paymt',;              // 1
                 'Ret. Check',;         // 2
                 'ROPOA',;              // 3
                 'Db_Memo ',;           // 4
                 'Misposting',;         // 5
                 'Terminatx',;          // 6
                 'Cr_Memo  ',;          // 7
                 'REVIEW ',;            // 8
                 ' ',;                  // 9
                 'O_T Check',;          //10
                 'PDR ',;               //11
                 'LEGAL ',;             //12
                 'LEGAL ',;             //13
                 'Current',;            //14
                 'Current',;            //15
                 'Balance Forwarded' }  //16
   local tot_or:=0, tot_am := 0, tot_penal := 0
   local xoramount := xamort := xpenal:=0,pprd:={},pperiod,unpd_pen := 0
   local xacctno,xornum,xrefdate,xcode,nrow:= { 05,19,32,43,60,86,93,117 }
**********   local prate:=xprate,pdate:= _ddate, xblk
   local _ddate := mdate

   xblk := { || Paysked->Lastpay <= pdate }

   Amshist->  ( dbseek(Acctmast->Acctno) )
   ncredamt := Acctmast->Credamt

   do while Amshist->Acctno == Acctmast->Acctno .and. !Amshist->(eof())

         xrefdate  := Amshist->Refdate
         xornum    := Amshist->Ornumber
         xacctno   := Amshist->Acctno
         xcode     := Amshist->Paycode
         unpd_pen  += Amshist->Unpd_pnlty

         do while Amshist->Acctno   == xAcctno  .and. ;
                  Amshist->Ornumber == xornum   .and. ;
                  Amshist->Refdate  == xrefdate .and. ;
                  Amshist->Paycode  == xcode    .and. ;
                 !Amshist->(eof())

             if xrefdate <= _ddate

                xOramount += if ( val( Amshist->Paycode ) < 8,;
                                  Amshist->Oramount,;
                                  0;
                                )
                xamort    += Amshist->Amort
                xpenal    += Amshist->Penalty
                if ( !empty( Amshist->Paydate ) ,;
                      aadd ( pprd,Amshist->Paydate ),;
                      nil ;
                   )

             endif

             Amshist->(dbskip(+1))
         enddo

         pperiod := if ( len (pprd) > 0,;
                         dtoc( pprd[ 1 ] ) + ;
                         if ( len(pprd ) > 1,;
                              '-' +dtoc(atail(pprd)),;
                              ' ' ;
                            ),;
                         ' ' ;
                       )

/*********************************
         if alltrim(xcode) == '1' // PAYMENT ? ( Sept. 07, 1999 )
            dretval     := xrefdate
            clastperiod := pperiod + '->'+ pay_ [ val( xcode ) ]
         else
            dretval     := xrefdate
            clastperiod := pperiod + '->'+ pay_ [ val( xcode ) ]
         endif
************************/

         nretval -= (xamort)

         pprd      := {}
         tot_or    += xOramount
         tot_am    += xamort
         tot_penal += xPenal
         xoramount := xamort := xpenal:=0

   enddo

return nretval

********************************
static function amsr0400open()
********************************
    local mretval := .f.
    memvar g_cis_path
    if netuse( 'Acctmast',.f.,5)
       set index to Acctmast,Acctclnt,Sureclnt, Acctacno
       set order to 4
       if netuse( 'Paysked',.f.,5)
          set index to Paysked
          if netuse(  '&g_cis_path'+'\Client.dbf',.f.,5)
             set index  to &g_cis_path\Cliecd, &g_cis_path\Clienm
             if netuse( 'Amshist', .f., 5 )    && Account Payment history file
                set index to Amshist            && set index on acctno
                mretval := .t.
             endif
          endif
       endif
    endif
return mretval
*                     End of the program ( amsr0400.prg )
