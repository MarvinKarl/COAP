/*
 ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
 º   program ID.........:  amsr2300.prg                                 º
 º   description........:  update acctmast->osbal2                      º
 º   author.............:  Ariel B. Bulan                               º
 º   date...............:  09:40am 09/14/2000                           º
 ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹
 º                   º U P D A T E S º                                  º
 ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹
 º        Who        º     When      º               Why                º
 ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹
 º                   º               º                                  º
 ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
*/

#include "COLF.CH"
#include "INKEY.CH"

#define MAXROW 55

memvar ax_level,g_user_id
private mtemp,mtemp2

if chkpass( procname(),ax_level,g_user_id )
   if amsr0400open()
      amsr0400main()
   endif
   eval ({|| __mrelease( "*", .t.), dbcloseall() })
endif
return

********************************
*
static function amsr0400main()
********************************
   local  mdbf   := savedbf (mdbf), mcolor := setcolor(), mcursor := setcursor()
   memvar gtrandate,mtemp,mtemp2
   private mpage := 1,mmonth,mdays,myear,mtitle,mlm,mdate
   mtitle := 'Aging of Past-Due Receivables'; mlm := 0 ; mdate  := gtrandate
   if create_temp()
      do while get_mdate( 7 )
         mpage := 1
         eval ({|| mmonth := month(mdate) ,;
                   mdays  := day(mdate)   ,;
                   myear  := year(mdate)  ,;
                   repcon_ol ( 'osbal_rev()','132 Column<Cont.>',,8,33,,,.F.) ;   &&repcontrol ( 'osbal_rev()','132 Column<Cont.>',,8,33) ;
              })
      enddo
   else
      error ( 'Cannot create temporary file!' )
   endif
   setcolor  (mcolor); setcursor (mcursor) ; restdbf   (mdbf)
return nil

******************************
*
function osbal_rev()
******************************
    memvar mdate
    local   mclntcode,t_rec:=0, nrec := 1
//    private mamort,m1_30,m31_60,m61_90,m91_180,m180_above,mtpastdue,mosbal,totpastdue := 0
//    private mpamort,mp1_30,mp31_60,mp61_90,mp91_180,mp180_above,mptpastdue,mposbal,ncurosbal := 0
//    private mgamort,mg1_30,mg31_60,mg61_90,mg91_180,mg180_above,mgtpastdue,mgosbal

    private mamort ,m1_30 ,m31_60 ,m61_90 ,m91_180 ,m180_360 ,m360_above ,mtpastdue,mosbal,totpastdue := 0
    private mpamort,mp1_30,mp31_60,mp61_90,mp91_180,mp180_360,mp360_above,mptpastdue,mposbal,ncurosbal := 0
    private mgamort,mg1_30,mg31_60,mg61_90,mg91_180,mp180_360,mp360_above,mgtpastdue,mgosbal
    private msamort,ms1_30,ms31_60,ms61_90,ms91_180,ms180_360,ms360_above,mstpastdue,msosbal

    private mc1_30,mc31_60,mc61_90,mc91_180,mc180_360,mc360_above,mctpastdue,mcosbal
    private mcg1_30,mcg31_60,mcg61_90,mcg91_180,mcg180_360,mcg360_above,mcgtpastdue,mcgosbal,mccur,mcgosbal
    private ma1_30,ma31_60,ma61_90,ma91_180,ma180_360,ma360_above
    private mag1_30,mag31_60,mag61_90,mag91_180,mag180_360,mag360_above,mcagosbal,mcagcur := 0

    private new := .t.,nosbal := 0

    mpamort:= mp1_30 := mp31_60:= mp61_90 := mp91_180 := mp180_360   := mp360_above := mptpastdue := mposbal :=0
    mgamort:= mg1_30 := mg31_60:= mg61_90 := mg91_180 := mg180_360   := mg360_above := mgtpastdue := mgosbal :=0
    msamort:= ms1_30 := ms31_60:= ms61_90 := ms91_180 := ms180_360   := ms360_above := mstpastdue := msosbal :=0

    ma1_30:=ma31_60:=ma61_90:=ma91_180:=ma180_360:=ma360_above:= 0
    mag1_30:=mag31_60:=mag61_90:=mag91_180:=mag180_360:=mag360_above := mcagosbal :=0

    setprc(0,0)  ; @ prow(),pcol() say chr(15)
    print_head() ; setfont('CONDENSED');print_subhead()
    @ prow()+1,00 say ''

    //altd()

/****************************
                          eval ({ || mclntcode := Acctmast->Acctname ,;
                                     Acctmast->( dbeval({|| if( .t. ,;                            // val( Acctmast->STATUS ) < 3 ,;// .and. ; !_employee_loans(Acctmast->fcltycode),;
                                                                eval({||  ;                 // Paysked->(dbseek(Acctmast->ACCTNO+dtos(mdate),.t.)),
                                                                        nosbal  := _get_outs() ,;
                                                                        if ( nosbal != 0  ,;
                                                                             eval ({|| ;
                                                                                      mcgosbal++;
                                                                                  }),;
                                                                             nil ;
                                                                           ),;
                                                                        Acctmast->(netlock('R',0)),; //traverse_sked()     ,;
                                                                        Acctmast->osbal2   := nosbal ,;
                                                                        Acctmast->asofdate := mdate  ,;
                                                                        mgosbal   += nosbal  ;   // mgosbal += Acctmast->Osbal ;
                                                                     }),;
                                                                nil ;
                                                              )},,;
                                     {|| !Acctmast->(eof()) .and. Acctmast->Acctname == mclntcode } )),;
                                     Acctmast->( dbskip(-1) )         ;
                                }),;
                          nil ) ;
******************/

    Acctmast->(dbgotop())
    set deleted on
    set century on

    mcgosbal  := 0
    mcagosbal := 0
    Acctmast->(dbeval({|| if ( Acctmast->valdate <= mdate ,;
                               eval ({|| ;
                                        nosbal  := _get_outs()       ,;
                                        Acctmast->(netlock('R',0))   ,;
                                        Acctmast->osbal2   := nosbal ,;
                                        Acctmast->asofdate := mdate  ;
                                    }),;
                               nil ;
                             );
                      },,;
                      {|| !Acctmast->(eof())} ;
                     ) ;
              )

/*************************
    if confirm ( 'Sort by Outstanding Balance (descending) ? ' )
       _prn_tmp()
    else
       _prn_temp()
    endif
    __eject()
*******************************/

    
********    page_grand_total( mpamort,mp1_30,mp31_60,mp61_90,mp91_180,mp180_360,mp360_above,mptpastdue,mposbal,'Page Total')
*********    page_grand_total( mgamort,mg1_30,mg31_60,mg61_90,mg91_180,mg180_360,mg360_above,mgtpastdue,ncurosbal,'Grand Total')
*********    __eject()
********    percentage ( mg1_30,mg31_60,mg61_90,mg91_180,mp180_360,mg360_above,mgtpastdue,mgosbal,ncurosbal )
return nil
/*
****************************************************
*
static function _employee_loans(cfcltycode)
****************************************************
   local lretval := .f.

   if cfcltycode == '10451' .or. ;
      cfcltycode == '10452' .or. ;
      cfcltycode == '10453' .or. ;
      cfcltycode == '10454'
      lretval := .t.
   endif

return lretval
*/
********************************
static function print_clntcode()
********************************
/*************
 if Paysked->(dbseek( Acctmast->Acctno)) .and. Paysked->Paydate + 5 < mdate ;
    .and. chkacct() > Acctmast->Amort * 0.10
******/

 if Paysked->(dbseek( Acctmast->Acctno)) .and. Paysked->Paydate + 5 < mdate
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
*
static function traverse_sked()
*******************************
    local  mclntno  ,macctno, mu := 0,mval:=0
    local  mnextpaydate,mmatdate,mpayfreq,mremterm:=0,date_ok := .f.
    local  mdiffdate   := 0,mdiff := 0,sw:=.f., p_due:= .f.
    local  _mdiffdate2 := 0
    memvar mdate

//    memvar mamort,m1_30,m31_60,m61_90,m91_180,m180_above,mtpastdue,mosbal
//    memvar mpamort,mp1_30,mp31_60,mp61_90,mp91_180,mp180_above,mptpastdue,mposbal
//    memvar mgamort,mg1_30,mg31_60,mg61_90,mg91_180,mg180_above,mgtpastdue,mgosbal

    memvar mamort ,m1_30 ,m31_60 ,m61_90 ,m91_180 ,m180_360 ,m360_above ,mtpastdue,mosbal,totpastdue
    memvar mpamort,mp1_30,mp31_60,mp61_90,mp91_180,mp180_360,mp360_above,mptpastdue,mposbal,ncurosbal
    memvar mgamort,mg1_30,mg31_60,mg61_90,mg91_180,mg180_360,mg360_above,mgtpastdue,mgosbal
    memvar mc1_30,mc31_60,mc61_90,mc91_180,mc180_360,mc360_above,mctpastdue,mcosbal
    memvar mcg1_30,mcg31_60,mcg61_90,mcg91_180,mcg180_360,mcg360_above,mcgtpastdue,mcgosbal,mccur

    memvar ma1_30,ma31_60,ma61_90,ma91_180,ma180_360,ma360_above
    memvar mag1_30,mag31_60,mag61_90,mag91_180,mag180_360,mag360_above,mcagcur,mcagosbal

    memvar nosbal

    mamort  := m1_30    := m31_60   := m61_90    := m91_180   := m180_360     := m360_above  := mtpastdue := mosbal  :=0
    mc1_30  := mc31_60  := mc61_90  := mc91_180  := mc180_360 := mc360_above  := mctpastdue  := mcosbal   := 0
    mcg1_30 := mcg31_60 := mcg61_90 := mcg91_180 := mcg180_360:= mcg360_above := mcgtpastdue := mccur     := 0

    ma1_30  := ma31_60  := ma61_90  := ma91_180  := ma180_360  := ma360_above  := 0
    mag1_30 := mag31_60 := mag61_90 := mag91_180 := mag180_360 := mag360_above := 0

    // mnextpaydate := if( Paysked->ACCTNO==Acctmast->ACCTNO , Paysked->PAYDATE,space(10) )
    // mremterm     := Acctmast->TERM-Paysked->PAYNUM
    //
    Paysked->(dbseek(Acctmast->ACCTNO))
    mu := Paysked->(recno())

    Paysked->(dbeval({ || mremterm++ },,{ || Paysked->Acctno == Acctmast->Acctno}))
    Paysked->(dbgoto(mu))

    mclntno  := Acctmast->CLNTCODE
    macctno  := right(Acctmast->ACCTNO,5)
    mamort   := Acctmast->AMORT
    mmatdate := if( empty(dtos(Acctmast->MATDATE)),space(10),Acctmast->MATDATE )
    mpayfreq := Acctmast->PAYFREQ
    //
    // disp_payment_freq( Acctmast->PAYFREQ )
    //
    if Paysked->(dbseek(Acctmast->ACCTNO,.t.))  .and. Paysked->Paydate <= mdate

       mosbal       := nosbal
       sw           := .t.
       mnextpaydate := Paysked->paydate
       mval         := if ( Paysked->Paydate + 5 > mdate,;
                            5,;
                            0 ;
                          )

       do while Paysked->ACCTNO  == Acctmast->ACCTNO .and. ;
                Paysked->Paydate <= mdate

         mcagosbal += Paysked->amort

         if Paysked->Paydate + if( p_due, 0, 5) <= mdate      //ADD 5 DAYS

            _mdiffdate2  := mdate - Paysked->Paydate 

            mnextpaydate := if ( !sw ,;
                                 eval({|| sw:=.t. ,;
                                          Paysked->Paydate ;
                                     }),;
                                 mnextpaydate ;
                               )
            
            mtpastdue    += Paysked->Amort

**********  if ( ( Paysked->Amort ) > ( Acctmast->Amort * .10 ) ) .and. ;

            if _mdiffdate2 <= 90

               p_due     := .t.
               mdiffdate := if ( !date_ok,;
                                  eval ( { || date_ok := .t.,;
                                              mdate - Paysked->Paydate ;
                                         };
                                       ),;
                                  mdiffdate ;
                               )

            else

               if _mdiffdate2 > 90
                  p_due     := .t.
                  mdiffdate := if ( !date_ok,;
                                     eval ( { || date_ok := .t.,;
                                                 mdate - Paysked->Paydate ;
                                            };
                                          ),;
                                     mdiffdate ;
                                  )
               else
                  sw:=.f.
               endif

            endif
         endif

         Paysked->(dbskip(+1))

       enddo       // END OF Paysked->ACCTNO == Acctmast->ACCTNO .and. ;
                   //        Paysked->Paydate <= mdate

       do case
          case mdiffdate >= 360
             mc360_above ++
             m360_above  := mosbal
          case mdiffdate >= 181
             mc180_360   ++
             m180_360    := mosbal
          case mdiffdate >= 091
             mc91_180    ++
             m91_180     := mosbal
          case mdiffdate >= 061
             mc61_90     ++
             m61_90      := mosbal
          case mdiffdate >= 031
             mc31_60     ++
             m31_60      := mosbal
          case mdiffdate >= 001
             mc1_30      ++
             m1_30       := mosbal
             ********* mtpastdue   := if( mtpastdue > Acctmast->Amort * .10, mtpastdue, 0 )
             mtpastdue   := mtpastdue
          otherwise
             ncurosbal   += mosbal
             mcagcur     += mtpastdue
       endcase

       if mtpastdue > 0 .and. mdiffdate > 0
          mosbal   := nosbal
          // print_it ( macctno,mamort,m1_30,m31_60,m61_90,m91_180,m180_360,m360_above,mtpastdue,mosbal,mnextpaydate,mmatdate,mpayfreq,mremterm)
          save_to_temp ( macctno,mamort,m1_30,m31_60,m61_90,m91_180,m180_360,m360_above,mtpastdue,mosbal,mnextpaydate,mmatdate,mpayfreq,mremterm)
          new := .f.
       else
          mosbal := 0
       endif

*****       mgosbal += nosbal      ,;   // mgosbal += Acctmast->Osbal ;

/*       if ( nosbal!=0  ,;
            mcgosbal++ ,;
            nil ;
          )
*/
    endif

/*****************
    mpamort     += mamort    ; mp1_30      += m1_30
    mp31_60     += m31_60    ; mp61_90     += m61_90
    mp91_180    += m91_180   ; mp180_360   += m180_360

    mp360_above += m360_above

    msamort     += mamort    ; ms1_30      += m1_30
    ms31_60     += m31_60    ; ms61_90     += m61_90
    ms91_180    += m91_180   ; ms180_360   += m180_360
    ms360_above += m360_above


    mgamort     += mamort    ; mg1_30      += m1_30
    mg31_60     += m31_60    ; mg61_90     += m61_90
    mg91_180    += m91_180   ; mg180_360   += m180_360
    mg360_above += m360_above

    mgtpastdue  += mtpastdue //; mgosbal     += mosbal
    ncurosbal   += mosbal
******************/

    

/*****************************

       mpage++
       page_grand_total( mpamort,mp1_30,mp31_60,mp61_90,mp91_180,mp180_360,mp360_above,mptpastdue,mposbal,'Page Total',.t.)

       mpamort:= mp1_30 := mp31_60:= mp61_90 := mp91_180:= mp180_360 := mp360_above:= mptpastdue:= mposbal :=0
       __eject()
       SETPRC( 0,0 )
       @ prow()+1, 00 say 'Page : ' + trans(mpage, '999' )
       print_subhead()
    endif
*****************************/

return nil
*******************************************************************************************************
 static function percentage (mg1_30,mg31_60,mg61_90,mg91_180,mg180_360,mg360_above,mgtpastdue,mgosbal,ncurosbal)
*******************************************************************************************************
    local mcol  := { 37,43,62,81,100,119,138,157,176,195,206,217,223 }
    local u,v,w,x,y,z
    memvar mcg1_30,mcg31_60,mcg61_90,mcg91_180,mcg180_360,mcg360_above,mcgtpastdue,mcgosbal,mccur

    print_head()
    setfont ('NLQ')
    setfont ('BOLD')
    @ PROW  ()+2, 10
*********    setfont ('UNDERLINE')

    @ prow  ()+1,61 say 'Percentage to          Number                  Total'
    @ prow  ()+1,61 say 'Total Receivables      of Accounts             Past Due '


*********    setfont ('OFFUNDERLINE')

    setfont ('UNBOLD')

    v :=  ( mg1_30+mg31_60+mg61_90+mg91_180+mg180_360+mg360_above )

    // alert ( str(mcgosbal) + 'dasf'+ str(mccur) )

    @ prow()+2, 10 say 'C U R R E N T             :'+ spac(4) + tran( u:= ( mgosbal - ncurosbal ),'99,999,999,999.99' ) + spac(10) + trans( getpercent( u, v+u ),'999.99')  + ' %'+ space(10)+ trans( mcgosbal-mccur,'99,999') + space(10)+ trans( mcagosbal-mcagcur,'99,999,999,999.99' )
    @ prow()+1, 10 say '01 - 30  Days Past Due    :'+ spac(4) + tran( mg1_30     ,'99,999,999,999.99' ) + spac(10) + trans( getpercent( mg1_30     ,v+u ),'999.99' ) + ' %' +       space(10)+ trans( mcg1_30     ,'99,999')   + space(10)+ trans( mag1_30          ,'99,999,999,999.99' ) //mgosbal
    @ prow()+1, 10 say '31 - 60  Days Past Due    :'+ spac(4) + tran( mg31_60    ,'99,999,999,999.99' ) + spac(10) + trans( getpercent( mg31_60    ,v+u ),'999.99' ) + ' %' +       space(10)+ trans( mcg31_60    ,'99,999')   + space(10)+ trans( mag31_60         ,'99,999,999,999.99' ) //mgosbal
    @ prow()+1, 10 say '61 - 90  Days Past Due    :'+ spac(4) + tran( mg61_90    ,'99,999,999,999.99' ) + spac(10) + trans( getpercent( mg61_90    ,v+u ),'999.99' ) + ' %' +       space(10)+ trans( mcg61_90    ,'99,999')   + space(10)+ trans( mag61_90         ,'99,999,999,999.99' ) //mgosbal
    @ prow()+1, 10 say '91 - 180 Days Past Due    :'+ spac(4) + tran( mg91_180   ,'99,999,999,999.99' ) + spac(10) + trans( getpercent( mg91_180   ,v+u ),'999.99' ) + ' %' +       space(10)+ trans( mcg91_180   ,'99,999')   + space(10)+ trans( mag91_180        ,'99,999,999,999.99' ) //mgosbal
    @ prow()+1, 10 say '181- 360 Days Past Due    :'+ spac(4) + tran( mg180_360  ,'99,999,999,999.99' ) + spac(10) + trans( getpercent( mg180_360  ,v+u ),'999.99' ) + ' %' +       space(10)+ trans( mcg180_360  ,'99,999')   + space(10)+ trans( mag180_360       ,'99,999,999,999.99' ) //mgosbal
    @ prow()+1, 10 say '361 Days and Above        :'+ spac(4) + tran( mg360_above,'99,999,999,999.99' ) + spac(10) + trans( getpercent( mg360_above,mgosbal ),'999.99' ) + ' %' + space(10)+ trans( mcg360_ABOVE,'99,999')     + space(10)+ trans( mag360_ABOVE     ,'99,999,999,999.99' )
    @ prow()+1, 10 say '                           '+space(4) + repl('-',17 )+space(10) + repl('-',6 )  + spac(10) + repl('-',11 )+space(7) + repl('-',17 )
    @ prow()+1, 10 say 'T O T A L                 :'+ spac(4) + tran( v+u,'99,999,999,999.99' ) + spac(10) + trans( 100,'999.99') + ' %'+ space(10)+trans( mcgosbal-mccur+mcg1_30+mcg31_60+mcg61_90+mcg91_180+mcg180_360+mcg360_ABOVE,'999,999')+ space(9)+trans( mcagosbal-mcagcur+mag1_30+mag31_60+mag61_90+mag91_180+mag180_360+mag360_ABOVE,'99,999,999,999.99' )
    @ prow()+1, 10 say '                           '+space(4) + repl('=',17 )+space(10) + repl('=',6 )  + spac(10) + repl('=',11 )+space(7) + repl('=',17 )
    setfont ('NORMAL')

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
*
static function page_grand_total( mamort,m1_30,m31_60,m61_90,m91_180,m180_360,m360_above,mtpastdue,mosbal,mmessage)
**********************************************************************************************************
    local mcol  := { 37,43,62,81,100,119,138,157,176,195,206,217,224 }

    @ prow()+1, 000 say "                                     ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ "
    @ prow()+1, 000       say mmessage

    @ prow()  , 31        say mamort     pict '999,999,999,999.99'
    @ prow()  , pcol()+2  say m1_30      pict '999,999,999,999.99'
    @ prow()  , pcol()+2  say m31_60     pict '999,999,999,999.99'
    @ prow()  , pcol()+2  say m61_90     pict '999,999,999,999.99'
    @ prow()  , pcol()+2  say m91_180    pict '999,999,999,999.99'
    @ prow()  , pcol()+2  say m180_360   pict '999,999,999,999.99'
    @ prow()  , pcol()+2  say m360_above pict '999,999,999,999.99'
    @ prow()  , pcol()+2  say mtpastdue  pict '999,999,999,999.99'
    @ prow()  , pcol()+2  say mosbal     pict '999,999,999,999.99'

return nil

**********************************************************************************************************
static function _prn_subtotal ( mamort,m1_30,m31_60,m61_90,m91_180,m180_360,m360_above,mtpastdue,mosbal,mmessage)
**********************************************************************************************************
    local mcol  := { 37,43,62,81,100,119,138,157,176,195,206,217,224 }
    @ prow()+1, 000 say "                                     ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ "
    @ prow()+1, 000 say mmessage

    @ prow()  , 31        say mamort     pict '999,999,999,999.99'
    @ prow()  , pcol()+2  say m1_30      pict '999,999,999,999.99'
    @ prow()  , pcol()+2  say m31_60     pict '999,999,999,999.99'
    @ prow()  , pcol()+2  say m61_90     pict '999,999,999,999.99'
    @ prow()  , pcol()+2  say m91_180    pict '999,999,999,999.99'
    @ prow()  , pcol()+2  say m180_360   pict '999,999,999,999.99'
    @ prow()  , pcol()+2  say m360_above pict '999,999,999,999.99'
    @ prow()  , pcol()+2  say mtpastdue  pict '999,999,999,999.99'
    @ prow()  , pcol()+2  say mosbal     pict '999,999,999,999.99'

    @ prow()+1, 000 say 'No. of Accounts : '

    @ prow()  , 31        say space(18)
    @ prow()  , pcol()+4  say mc1_30      pict '999,999,999,999'
    @ prow()  , pcol()+4  say mc31_60     pict '999,999,999,999'
    @ prow()  , pcol()+4  say mc61_90     pict '999,999,999,999'
    @ prow()  , pcol()+4  say mc91_180    pict '999,999,999,999'
    @ prow()  , pcol()+4  say mc180_360   pict '999,999,999,999'
    @ prow()  , pcol()+4  say mc360_above pict '999,999,999,999'


*********8888      ma1_30 := ma31_60 := ma61_90 := ma91_180 := ma180_360 := ma360_above:= 0

    @ prow()+1, 000 say 'Past Due : '

    @ prow()  , 31        say space(18)
    @ prow()  , pcol()+2  say ma1_30      pict '999,999,999,999'
    @ prow()  , pcol()+2  say ma31_60     pict '999,999,999,999'
    @ prow()  , pcol()+2  say ma61_90     pict '999,999,999,999'
    @ prow()  , pcol()+2  say ma91_180    pict '999,999,999,999'
    @ prow()  , pcol()+2  say ma180_360   pict '999,999,999,999'
    @ prow()  , pcol()+2  say ma360_above pict '999,999,999,999'



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

***************************
*
static function _prn_temp()
***************************
   local ctype := '103'
   memvar mtemp,mtemp2

   mpamort := mp1_30   := mp31_60  := mp61_90    := mp91_180  := mp180_360    := mp360_above  := mptpastdue:= mposbal :=0
   mcg1_30 := mcg31_60 := mcg61_90 := mcg91_180 := mcg180_360 := mcg360_above := mcgtpastdue  := 0

   (mtemp)->(dbgotop())
   do while !(mtemp)->(eof())

      msamort := ms1_30  := ms31_60 := ms61_90  := ms91_180  := ms180_360   := ms360_above := mstpastdue := msosbal :=0
      mc1_30  := mc31_60 := mc61_90 := mc91_180 := mc180_360 := mc360_above := mctpastdue  := mcosbal    := 0

      ma1_30 := ma31_60 := ma61_90 := ma91_180 := ma180_360 := ma360_above:= 0

      ctype := substr( (mtemp)->acctno,5,3 )

      ************ alert ( ctype )

      if ctype == '103'                            // LEASE
         @ prow()+1,00 say ' '
         @ prow()+1,00 say '--------------------------------'
         @ prow()+1,00 say 'LCR - LEASE CONTRACT RECEIVABLES'
         @ prow()+1,00 say '--------------------------------'
      else                                         // LOANS
         @ prow()+1,00 say ' '
         @ prow()+1,00 say '--------------------------------'
         @ prow()+1,00 say 'FR  - FINANCE RECEIVABLES       '
         @ prow()+1,00 say '--------------------------------'
      endif

      do while substr ( (mtemp)->acctno,5,3 ) == ctype .and. !(mtemp)->(eof())

          print_it  ('1')

          if prow() >= MAXROW
             mpage++
             page_grand_total ( mpamort,mp1_30,mp31_60,mp61_90,mp91_180,mp180_360,mp360_above,mptpastdue,mposbal,'Page Total',.t.)
             mpamort:= mp1_30 := mp31_60:= mp61_90 := mp91_180:= mp180_360 := mp360_above:= mptpastdue:= mposbal :=0
             __eject ()
             setprc  ( 0,0 )
             @ prow  ()+1, 00 say 'Page : ' + trans(mpage, '999' )
             print_subhead ()
          endif
          (mtemp)-> (dbskip(+1))

      enddo

      _prn_subtotal ( msamort,ms1_30,ms31_60,ms61_90,ms91_180,ms180_360,ms360_above,mstpastdue,msosbal,'Sub Total',.t.)

*********8888      @ prow()+1,00 say 'No. of Accounts : '

   enddo

   __eject()
   ************88 percentage ( mg1_30,mg31_60,mg61_90,mg91_180,mg180_360,mg360_above,mgtpastdue,mgosbal,ncurosbal )
   __eject()

return nil

***************************
*
*                             ( sorted by OSBAL (descending),abb 08/29/2000  )
*
static function _prn_tmp()
***************************
   local ctype := '103'
   memvar mtemp,mtemp2
   private _mgamort,_mg1_30  ,_mg31_60  ,_mg61_90, _mg91_180 ,_mg180_360,_mg360_above,_mgtpastdue,_mgosbal

   mpamort := mp1_30   := mp31_60  := mp61_90    := mp91_180  := mp180_360    := mp360_above  := mptpastdue:= mposbal :=0
   mcg1_30 := mcg31_60 := mcg61_90 := mcg91_180 := mcg180_360 := mcg360_above := mcgtpastdue  := 0

   (mtemp)->(dbgotop())
   (mtemp)->(dbsetorder(2))            // osbal
   (mtemp)->(dbgobottom())

   _mgamort := _mg1_30  :=_mg31_60  :=_mg61_90:= _mg91_180 :=_mg180_360:=_mg360_above:=_mgtpastdue:=_mgosbal := 0

   do while !(mtemp)->(bof())

      msamort := ms1_30  := ms31_60 := ms61_90  := ms91_180  := ms180_360   := ms360_above := mstpastdue := msosbal :=0
      mc1_30  := mc31_60 := mc61_90 := mc91_180 := mc180_360 := mc360_above := mctpastdue  := mcosbal    := 0

      ma1_30 := ma31_60 := ma61_90 := ma91_180 := ma180_360 := ma360_above:= 0

      ctype := substr( (mtemp)->acctno,5,3 )

      print_it  ('2')

      if prow() >= MAXROW
         mpage++
         page_grand_total ( mpamort,mp1_30,mp31_60,mp61_90,mp91_180,mp180_360,mp360_above,mptpastdue,mposbal,'Page Total',.t.)
         mpamort:= mp1_30 := mp31_60:= mp61_90 := mp91_180:= mp180_360 := mp360_above:= mptpastdue:= mposbal :=0
         __eject ()
         setprc  ( 0,0 )
         @ prow  ()+1, 00 say 'Page : ' + trans(mpage, '999' )
         print_subhead ()
      endif

      (mtemp)-> (dbskip(-1))

   enddo

   @ prow()+1, 000 say "                                     ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ "
   @ prow()+1, 000       say 'Grand Total '

   @ prow()  , 31        say _mgamort     pict '999,999,999,999.99'
   @ prow()  , pcol()+2  say _mg1_30      pict '999,999,999,999.99'
   @ prow()  , pcol()+2  say _mg31_60     pict '999,999,999,999.99'
   @ prow()  , pcol()+2  say _mg61_90     pict '999,999,999,999.99'
   @ prow()  , pcol()+2  say _mg91_180    pict '999,999,999,999.99'
   @ prow()  , pcol()+2  say _mg180_360   pict '999,999,999,999.99'
   @ prow()  , pcol()+2  say _mg360_above pict '999,999,999,999.99'
   @ prow()  , pcol()+2  say _mgtpastdue  pict '999,999,999,999.99'
   @ prow()  , pcol()+2  say _mgosbal     pict '999,999,999,999.99'
   @ prow()+1, 000 say "                                     ================== ================== ================== ================== ================== ================== ================== ================== ================== "

   __eject()
   percentage ( mg1_30,mg31_60,mg61_90,mg91_180,mg180_360,mg360_above,mgtpastdue,mgosbal,ncurosbal )
   __eject()

return nil

**************************
*
static function print_it( _one_is_lcr_fr )
**************************
    local mcol := { 37,43,62,81,100,119,138,157,177,197,209,224 }

    @ prow()+1,00       say substr((mtemp)->ACCTNO,-5,5)
    @ prow(),pcol()+2   say (mtemp)->ACCTNAME
    @ prow(),pcol()+2   say (mtemp)->AMORT      pict '999,999,999,999.99'
    @ prow(),pcol()+2   say (mtemp)->N1_30      pict '999,999,999,999.99'
    @ prow(),pcol()+2   say (mtemp)->N31_60     pict '999,999,999,999.99'
    @ prow(),pcol()+2   say (mtemp)->N61_90     pict '999,999,999,999.99'
    @ prow(),pcol()+2   say (mtemp)->N91_180    pict '999,999,999,999.99'
    @ prow(),pcol()+2   say (mtemp)->N181_360   pict '999,999,999,999.99'
    @ prow(),pcol()+2   say (mtemp)->N361_ABOVE pict '999,999,999,999.99'
    @ prow(),pcol()+2   say (mtemp)->NPASSDUE   pict '999,999,999,999.99'
    @ prow(),pcol()+2   say (mtemp)->NOSBAL     pict '999,999,999,999.99'
    @ prow(),pcol()+2   say (mtemp)->DNEXTPAYD
    @ prow(),pcol()+2   say (mtemp)->DMATDATE

    msamort     += (mtemp)->AMORT
    ms1_30      += (mtemp)->N1_30
    ms31_60     += (mtemp)->N31_60
    ms61_90     += (mtemp)->N61_90
    ms91_180    += (mtemp)->N91_180
    ms180_360   += (mtemp)->N181_360
    ms360_above += (mtemp)->N361_ABOVE
    mstpastdue  += (mtemp)->NPASSDUE
    msosbal     += (mtemp)->NOSBAL

    mpamort     += (mtemp)->AMORT
    mp1_30      += (mtemp)->N1_30
    mp31_60     += (mtemp)->N31_60
    mp61_90     += (mtemp)->N61_90
    mp91_180    += (mtemp)->N91_180
    mp180_360   += (mtemp)->N181_360
    mp360_above += (mtemp)->N361_ABOVE
    mptpastdue  += (mtemp)->NPASSDUE
    mposbal     += (mtemp)->NOSBAL


    mgamort     += (mtemp)->AMORT
    mg1_30      += (mtemp)->N1_30
    mg31_60     += (mtemp)->N31_60
    mg61_90     += (mtemp)->N61_90
    mg91_180    += (mtemp)->N91_180
    mg180_360   += (mtemp)->N181_360
    mg360_above += (mtemp)->N361_ABOVE
    mgtpastdue  += (mtemp)->NPASSDUE
*************8    mgosbal     += (mtemp)->NOSBAL

    if _one_is_lcr_fr == '2'
      _mgamort     += (mtemp)->AMORT
      _mg1_30      += (mtemp)->N1_30
      _mg31_60     += (mtemp)->N31_60
      _mg61_90     += (mtemp)->N61_90
      _mg91_180    += (mtemp)->N91_180
      _mg180_360   += (mtemp)->N181_360
      _mg360_above += (mtemp)->N361_ABOVE
      _mgtpastdue  += (mtemp)->NPASSDUE
      _mgosbal     += (mtemp)->NOSBAL
    endif

    ncurosbal   += (mtemp)->NOSBAL
    mccur       ++

       do case
          case (mtemp)->N361_ABOVE > 0
             mc360_above  ++
             mcg360_above ++
             ma360_above  += (mtemp)->NPASSDUE
             mag360_above  += (mtemp)->NPASSDUE
             //     mag1_30 := mag31_60 := mag61_90 := mag91_180 := mag180_360 := mag360_above := 0


          case (mtemp)->N181_360   > 0
             mc180_360    ++
             mcg180_360   ++
             ma180_360    += (mtemp)->NPASSDUE
             mag180_360    += (mtemp)->NPASSDUE
          case (mtemp)->N91_180    > 0
             mc91_180     ++
             mcg91_180    ++
             ma91_180     += (mtemp)->NPASSDUE
             mag91_180     += (mtemp)->NPASSDUE
          case (mtemp)->N61_90     > 0
             mc61_90      ++
             mcg61_90     ++
             ma61_90      += (mtemp)->NPASSDUE
             mag61_90      += (mtemp)->NPASSDUE
          case (mtemp)->N31_60     > 0
             mc31_60      ++
             mcg31_60     ++
             ma31_60      += (mtemp)->NPASSDUE
             mag31_60      += (mtemp)->NPASSDUE
          case (mtemp)->N1_30      > 0
             mc1_30       ++
             mcg1_30      ++
             ma1_30       += (mtemp)->NPASSDUE
             mag1_30       += (mtemp)->NPASSDUE
       endcase


return nil

*******************************************************************************************************************************************************
static function save_to_temp ( macctno,mamort,m1_30,m31_60,m61_90,m91_180,m180_360,m360_above,mtpastdue,mosbal,mnextpaydate,mmatdate,mpayfreq,mremterm)
*******************************************************************************************************************************************************
    memvar mtemp,mtemp2
    local mcol := { 37,43,62,81,100,119,138,157,177,197,209,224 }

    (mtemp)->(dbappend())
    (mtemp)->ACCTNO      := Acctmast->acctno
    (mtemp)->ACCTNAME    := left(dispclntname(Acctmast->BRCODE+Acctmast->CLNTCODE,40),22)
    (mtemp)->AMORT       := mamort
    (mtemp)->N1_30       := m1_30
    (mtemp)->N31_60      := m31_60
    (mtemp)->N61_90      := m61_90
    (mtemp)->N91_180     := m91_180
    (mtemp)->N181_360    := m180_360
    (mtemp)->N361_ABOVE  := m360_above
    (mtemp)->NPASSDUE    := mtpastdue
    (mtemp)->NOSBAL      := mosbal
    (mtemp)->DNEXTPAYD   := mnextpaydate
    (mtemp)->DMATDATE    := mmatdate

return nil

******************************
static function print_head()
******************************
    memvar mtitle,mpage,gsys_name,gcompany,mlm,mmonth,mdays,myear
    eval ( {|| mtitle := 'Delinquency Report',;
              prnreptitle  ( 132,mlm,mpage,mtitle,'Program ID:AMSR230c',gsys_name,gcompany),;
              pagecenter   ( prow()+1,132,'As of '+fr0100month( trans(mmonth,'99') )+' '+trans(mdays,'99')+', '+trans(myear,'9999') );
           };
         )
    @ prow()+1,0 say ''

return nil
*******************************
static function print_subhead()
*******************************
    setfont ( 'CONDENSED' )
    eval({|| devpos( prow()+1, 00 ) , devout( "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ" ),;
             devpos( prow()+1, 00 ) , devout( "Client No./Name                       Amortization       1-30 Days          31-60 Days         61-90 Days         91-180 Days        181-360 Days       361 Days Above     Total Past Due       Outstanding           Next      Maturity " ),;
             devpos( prow()+1, 00 ) , devout( "                                                                                                                                                                                                  Balance           Pay Date      Date   " ),;
             devpos( prow()+1, 00 ) , devout( "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ" );
        })

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
static function create_temp()
********************************
   memvar mtemp,mtemp2
   local mretval := .f.
   local mstruct := { { 'ACCTNO'     ,'C',14,00 } ,;
                      { 'ACCTNAME'   ,'C',22,00 } ,;
                      { 'AMORT'      ,'N',15,02 } ,;
                      { 'N1_30'      ,'N',15,02 } ,;
                      { 'N31_60'     ,'N',15,02 } ,;
                      { 'N61_90'     ,'N',15,02 } ,;
                      { 'N91_180'    ,'N',15,02 } ,;
                      { 'N181_360'   ,'N',15,02 } ,;
                      { 'N361_ABOVE' ,'N',15,02 } ,;
                      { 'NPASSDUE'   ,'N',15,02 } ,;
                      { 'NOSBAL'     ,'N',15,02 } ,;
                      { 'DNEXTPAYD'  ,'D',08,00 } ,;
                      { 'DMATDATE'   ,'D',08,00 } ;
                    }

   mtemp  := uniqfile()
   mtemp2 := _uniqfile()

   dbcreate ( ( mtemp ) , mstruct )
   if valtype ( mtemp ) != 'U'
      if netuse ( (mtemp) ,.t.,0 )
         index on substr(acctno,5,5)+acctname to &mtemp  // facility+acctname
         if valtype ( mtemp2 ) != 'U'
            mretval := .t.
            index on nosbal to &mtemp2  // nosbal
            set index to &mtemp,&mtemp2
         endif
      endif
   endif

return mretval

********************************
*
static function uniqfile()
********************************
   local mfiname, mrandnum
   do while .t.
      mrandnum := substr(time(),1,2) + substr(time(),4,2) + substr(time(),7,2)
      mfiname  := 'TF' + mrandnum
      if file(mfiname+'.dbf')                 // test if text file exist
         loop
      else
         exit
      endif
   enddo
return mfiname

********************************
*
static function _uniqfile()
********************************
   local mfiname, mrandnum
   do while .t.
      mrandnum := substr(time(),1,2) + substr(time(),4,2) + substr(time(),7,2)
      mfiname  := 'TM' + mrandnum
      if file(mfiname+'.dbf')                 // test if text file exist
         loop
      else
         exit
      endif
   enddo
return mfiname

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
             if netuse( 'Amshist', .f., 5 )        && Account Payment history file
                set index to Amshist                && set index on acctno
                if netuse( 'payimage',.f.,5)
                   set index to payimage
                   mretval := .t.
                endif
             endif
          endif
       endif
    endif
return mretval
*                     End of the program ( amsr0400.prg )
