/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³   colf-iis .... Account Management System                                ³
 ³   Program id... Amsr1300.prg                                             ³
 ³   Description . Weekly Deliquency Report                                 ³
 ³   Author....... Engr. Michael B. Espina                                  ³
 ³   Date ........ April 12, 2000 2:15 P.M.                                 ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³                             u p d a t e s                                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³        who        ³       when        ³               why                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³   abb             ³  12/12/2000 9:23am³  provision for printing for      ³
 ³                   ³                   ³  previous dates                  ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include "COLF.CH"
#include "INKEY.CH"

#define MAXROW 54

memvar ax_level,g_user_id
if chkpass( procname(),ax_level,g_user_id )
   if amsr1300open()
      amsr1300main()
   endif
   eval ({|| __mrelease( "*", .t.), dbcloseall() })
endif
return

******************************
static function amsr1300main()
******************************
   local  mdbf   := savedbf (mdbf), mcolor := setcolor(), mcursor := setcursor()
   memvar gtrandate
   private mpage := 1,mmonth,mdays,myear,mtitle,mlm,mdate,clntflag:=''
   mtitle := 'Weekly Deliquency Report'; mlm := 0 ; mdate  := gtrandate
   while get_mdate( 7 )
      mpage := 1
      *eval({|| mmonth := month(mdate), mdays:=day(mdate), myear:=year(mdate),repcontrol('weekly_delinquent_print()','132 Column<Cont.>',,8,33) })
      eval({|| mmonth := month(mdate), mdays:=day(mdate), myear:=year(mdate),repcon_ol('weekly_delinquent_print()','132 Column<Cont.>',,8,33,,,.F.) })
   enddo
   setcolor  (mcolor); setcursor (mcursor) ; restdbf   (mdbf)
return nil

******************************
function weekly_delinquent_print()
******************************
    memvar mdate
    local   mclntcode,t_rec:=0, nrec := 1
    private mamort,mtpastdue,mosbal,totpastdue := 0
    private mpamort,mptpastdue,mposbal,ncurosbal := 0
    private mgamort,mgtpastdue,mgosbal,mdiffdate
    private t_amort:=0, t_osbal:=0, t_pastdue := 0
    private lul:=0, mpdue:=0, ktr:=0
    private new := .t.
    mpamort := mptpastdue := mposbal :=0
    mgamort := mgtpastdue := mgosbal :=0
    setprc(0,0)  ; @ prow(),pcol() say chr(15)
    print_head() ; setfont('CONDENSED') ;print_subhead()
    Acctmast->(dbgotop())
    Acctmast->(dbeval({|| if ( val( Acctmast->STATUS) < 3 .and. ;
                               Acctmast->Valdate <= mdate ,;
                          eval ({ || mclntcode := Acctmast->Acctname ,;
                                     mdiffdate := 0 ,;
                                     if ( !Acctmast->(deleted()),;
                                          nil,;
                                          nil ;
                                        ) ,;
                                     Acctmast->( dbeval({|| if( val( Acctmast->STATUS ) < 3 .and. ;
                                                                !_employee_loans(Acctmast->fcltycode) .and. ;
                                                                Acctmast->osbal > 0 ,;
                                                                eval({||  ; //Paysked->(dbseek(Acctmast->ACCTNO+dtos(mdate),.t.)),
                                                                        traverse_sked(),;
                                                                        mgosbal += Acctmast->Osbal ;
                                                                    }),;
                                                                nil ;
                                                              )},,;
                                     {|| !Acctmast->(eof()) .and. Acctmast->Acctname == mclntcode } )),;
                                     Acctmast->( dbskip(-1) )         ;
                                }),;
                          nil ) ;
                      } ,,;
                ; //   {|| Acctmast->clntcode != '9500422'} ;  
                       {|| !Acctmast->(eof())} ;
                     )                        ;
              )
         @ prow()+1, 01 say '³                ³      ³                                      ³ TOTAL         ³ '
         @ prow(),   92 say '³'+transform(t_amort,'999,999,999,999.99')
         @ prow(),  112 say '³'+ transform(t_osbal,'999,999,999,999.99') + ' ³'
         @ prow(),  145 say '³'+ transform(t_pastdue,'999,999,999,999.99')+' ³              ³                                        ³'
         @ prow()+1, 1 say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
         __eject()
return nil

****************************
*
static function _get_outs( )
****************************
   local nretval := Acctmast->credamt, ddate := ctod ('')
   local dretval := ctod('')
   local pgn:=1
   local tot_amrt := 0, tot_pen := 0, npent_s := 0,ncredamt:= Acctmast->Credamt
   local Pay_:={ 'Paymt',;              //   1
                 'Ret. Check',;         //   2
                 'ROPOA',;              //   3
                 'Db_Memo ',;           //   4
                 'Misposting',;         //   5
                 'Terminatx',;          //   6
                 'Cr_Memo  ',;          //   7
                 'REVIEW ',;            //   8
                 ' ',;                  //   9
                 'O_T Check',;          //  10
                 'PDR ',;               //  11
                 'LEGAL ',;             //  12
                 'LEGAL ',;             //  13
                 'Current',;            //  14
                 'Current',;            //  15
                 'Balance Forwarded' }  //  16
   local tot_or:=0, tot_am := 0, tot_penal := 0
   local xoramount := xamort := xpenal:=0,pprd:={},pperiod,unpd_pen := 0
   local xacctno,xornum,xrefdate,xcode,nrow:= { 05,19,32,43,60,86,93,117 }
   local _ddate := mdate

   xblk := { || Paysked->Lastpay <= pdate }

   Amshist-> ( dbseek(Acctmast->Acctno) )
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
         xoramount := xamort := xpenal := 0

   enddo

return nretval
/*
****************************************************
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
 if Paysked->(dbseek( Acctmast->Acctno)) ; //.and. Paysked->Paydate + 5 < mdate ;
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
Static function Chkacct()
local mval,retval:=0

      // mval:= if( Paysked->Paydate + 5 > mdate, 5, 0 )
      mval:= 0
      while Paysked->ACCTNO == Acctmast->ACCTNO .and. Paysked->Paydate <= mdate
         if Paysked->Paydate + mval < mdate
            retval += Paysked->Amort
         endif
         Paysked->(dbskip())
      enddo
return retval

*******************************
static function traverse_sked()
*******************************
    local  mclntno  ,macctno, mu := 0,mval:=0
    local  mnextpaydate,mmatdate,mpayfreq,mremterm:=0,date_ok := .f.
    local  mdiff := 0,sw:=.f., p_due:= .f.
    memvar mdate,lul, mpdue, mdiffdate
    memvar mamort,m1_30,m31_60,m61_90,m91_180,m180_above,mtpastdue,mosbal
    memvar mpamort,mp1_30,mp31_60,mp61_90,mp91_180,mp180_above,mptpastdue,mposbal
    memvar mgamort,mg1_30,mg31_60,mg61_90,mg91_180,mg180_above,mgtpastdue,mgosbal

    mamort := m1_30  := m31_60 := m61_90  := m91_180  := m180_above  := mtpastdue  := mosbal  :=0
    mpdue:=0
    if (prow() >= MAXROW)
       mpage++
       @ prow()+1, 1 say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
       __eject()
       @ prow()+1, 00 say 'Page : ' + trans(mpage, '999' )
       SETPRC( 0,0 )
       print_subhead()
       @ prow()+1, 1 say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
    endif

    Paysked->(dbseek(Acctmast->ACCTNO))
    mu := Paysked->(recno())
    Paysked->( dbeval({ || mremterm++ },,{ || Paysked->Acctno == Acctmast->Acctno}))
    Paysked->(dbgoto(mu))
    mclntno  := Acctmast->CLNTCODE
    macctno  := right(Acctmast->ACCTNO,5)
    mamort   := Acctmast->AMORT
    mmatdate := if( empty(dtos(Acctmast->MATDATE)),space(10),Acctmast->MATDATE )
    mpayfreq := Acctmast->PAYFREQ

    If Paysked->(dbseek(Acctmast->ACCTNO,.t.))  .and. Paysked->Paydate <= mdate
       mosbal   := Acctmast->OSBAL
       mnextpaydate := if( Paysked->Amort > Acctmast->Amort * 0.10 ,eval( {|| sw:=.t.,Paysked->Paydate }),nil )
     //  mval := if( Paysked->Paydate + 5 > mdate, 5, 0 )
       mval := 0
       while Paysked->ACCTNO == Acctmast->ACCTNO .and. Paysked->Paydate <= mdate
        // if Paysked->Paydate + if( p_due, 0, 5) <= mdate      //ADD 5 DAYS
         if Paysked->Paydate <= mdate      
            mnextpaydate:= if( !sw, eval({|| sw:=.t.,Paysked->Paydate }),mnextpaydate )
            mtpastdue += Paysked->Amort
            mpdue++
            if ( ( Paysked->Amort ) > ( Acctmast->Amort * .10 ) )
               p_due := .t.
               mdiffdate := if( !date_ok, eval({ || date_ok := .t., mdate - Paysked->Paydate } ), mdiffdate )
            else
               sw:=.f.
            endif
         endif
         Paysked->(dbskip())
       Enddo
       if mtpastdue > 0 .and. mdiffdate > 0
          mosbal   := Acctmast->OSBAL
          print_it( macctno,mamort,m1_30,m31_60,m61_90,m91_180,m180_above,mtpastdue,mosbal,mnextpaydate,mmatdate,mpayfreq,mremterm)
          new := .f.
       else
          mosbal := 0
       endif
    endif
    mpamort     += mamort     
    mptpastdue  += mtpastdue ; mposbal     += mosbal
    mgamort     += mamort    
    mgtpastdue  += mtpastdue 
    ncurosbal   += mosbal
return nil

*****************************************************************************************************************************************
*
static function print_it( macctno,mamort,m1_30,m31_60,m61_90,m91_180,m180_above,mtpastdue,mosbal,mnextpaydate,mmatdate,mpayfreq,mremterm)
*****************************************************************************************************************************************
 local linda:=0, new_date, ispacio:=0, pasok:=.f., ispacio2:=0
 local rev:=0, revdate, m_date:=ctod('')
 memvar lul, mdiffdate
 memvar t_amort, t_osbal, t_pastdue, ktr

  if mamort * .10 < mtpastdue
    if clntflag != Acctmast->clntcode
       if lul = 0
          @ prow()+1, 1 say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
          lul:=1
          ktr:=0
       else
        if ktr > 1
          @ prow()+1, 01 say '³                ³      ³                                      ³ TOTAL         ³ '
          @ prow(),   92 say '³'+ transform(t_amort,'999,999,999,999.99')
          @ prow(),  112 say '³'+ transform(t_osbal,'999,999,999,999.99') + ' ³'
          @ prow(),  145 say '³'+ transform(t_pastdue,'999,999,999,999.99')+' ³              ³                                        ³'
        endif
         t_amort:= 0
         t_pastdue:= 0
         t_osbal :=0
         ktr:=0
         @ prow()+1, 01 say 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
       endif
         @ prow()+1, 01 say '³                ³      ³' +left(dispclntname(Acctmast->BRCODE+Acctmast->CLNTCODE,40),35)+ '   ³               ³           ³                   ³                   ³            ³                   ³              ³                                        ³'
         if Signers->(dbseek(Acctmast->clntcode))
            @ prow()+1, 01 say '³                ³      ³'+ Signers->signer + '        ³               ³           ³                   ³                   ³            ³                   ³              ³                                        ³'
         else
            @ prow()+1, 01 say '³                ³      ³                                      ³               ³           ³                   ³                   ³            ³                   ³              ³                                        ³'
         endif
         linda:=1
    endif
    mdiffdate:=0
    dbselectarea('Paysked')
    Paysked->(dbsetorder(1))
    Paysked->(dbseek(Acctmast->acctno))
    // mdiffdate2 := mdate-Paysked->Paydate
    // alert('1 '+dtos(paysked->paydate) + str(mdiffdate2))
    m_date:=Paysked->paydate
    Payimage->(dbsetorder(1))
    Payimage->(dbseek(Acctmast->acctno+dtos(m_date),.t.))
    mdiffdate := mdate-Payimage->Paydate
    if Payimage->(eof())
       Payimage->(dbgobottom())
    else
       Payimage->(dbskip(-1))
    endif

//  alert('2 '+dtos(payimage->paydate)+' '+str(mdiffdate))
//  new_date := round(mdiffdate / 30,0)

    new_date := if(mdiffdate/30 > int(mdiffdate/30), int(mdiffdate/30)+1, int(mdiffdate/30))
    if new_date = 0
       new_date:=1
    endif

    @ prow()+1,01 say '³  ' + substr( Acctmast->Oldno,1,13 )
    @ prow(), 18  say '³'   + substr(Acctmast->acctno,10,5)
    @ prow(), 25  say '³'   + substr(acctmast->unit,1,35)
    @ prow(), 64  say '³'   + transform(acctmast->valdate,'99/99/9999')
    @ prow(), 80  say '³'   + transform(Payimage->paydate,'99/99/9999')
    @ prow(), 92  say '³'   + transform(mamort,'999,999,999,999.99')
    @ prow(), 112 say '³'   + transform(mosbal,'999,999,999,999.99')
    @ prow(), 132 say '³'   + transform(new_date, '99') + ' month/s'
    @ prow(), 145 say '³'   + transform(mtpastdue,'999,999,999,999.99')
    @ prow(), 165 say '³'   + transform(Acctmast->matdate,'99/99/9999')
    pasok := .f.
    Delqdtls->(dbgotop())
    Delqdtls->(dbsetorder(1))
    Delqdtls->(dbseek(Acctmast->acctno))
    if found()
       actnum:=Delqdtls->acctno
       Do while actnum = Delqdtls->acctno .and. Delqdtls->(!eof())
          if Delqdtls->date = mdate .and. ispacio = 0
             pasok := .t.
             @ prow(), 180 say  '³' + delqdtls->status + '³'
          elseif Delqdtls->date = mdate .and. ispacio <> 0
             pasok := .t.
             @ prow()+1, 01 say '³                ³      ³                                      ³               ³           ³                   ³                   ³            ³                   ³' + delqdtls->status + '³'
          else
             ispacio2:=1
          endif

          Delqdtls->(dbskip())
          ispacio:=1
          if ispacio2 = 1
             ispacio:=0
             ispacio2:=0
          endif
       Enddo
       ispacio := 0
       if pasok = .f.
          rev:=0
          delqdtls->(dbskip(-1))
          revdate:=Delqdtls->date
          Delqdtls->(dbgotop())
          Delqdtls->(dbsetorder(1))
          if Delqdtls->(dbseek(actnum))
             Do while actnum = Delqdtls->acctno .and. Delqdtls->(!bof())
                if revdate = Delqdtls->date .and. rev = 0
                   @ prow(), 180 say  '³' + delqdtls->status + '³'
                   rev++
                elseif revdate = Delqdtls->date .and. rev != 0
                   @ prow()+1, 01 say '³                ³      ³                                      ³               ³           ³                   ³                   ³            ³                   ³                ³' + delqdtls->status + '³'
                   rev++
                else
                   // until then my linda
                endif
                Delqdtls->(dbskip())
             Enddo
          else
             @ prow(), 180 say '³                                        ³'
          endif
       endif
       Paysked->(dbseek(Acctmast->acctno))
       clntflag:=Acctmast->clntcode
       t_amort+= mamort
       t_osbal+= mosbal
       t_pastdue+= mtpastdue
       ktr++
    endif
  endif
return nil

********************************
*
static function amsr13head()
********************************
local  mdate := 'For the Month of ' + { 'January', 'February', 'March',;
                'April', 'May', 'June', 'July', 'August', 'September', ;
                'October', 'November', 'December' }[ mmonth ] +  ;
                ' ' + padr( myear, 4 )

setprc  ( 0,0 )
setfont ( 'DRAFT' )
setfont ( 'ELITE' )
@ prow  ()+1,03 say 'ACCOUNT MANAGEMENT SYSTEM'
@ prow  ()+1,03 say 'AMSR1300'
@ prow  ()  ,03+len('AMSR1300');
                say PADL( dtoc(DATE())+' '+TIME(), 90-len('AMSR1300'))

********** @ prow()+1,03 say PADC('CONSOLIDATED ORIX LEASING AND FINANCE CORPORATION',90)

@ prow  ()+1,03 say padc ( 'ORIX METRO Leasing and Finance Corporation',90 )
SETFONT ( 'BOLD'   )
@ prow  ()+1,03 say padc('WEEKLY DELIQUENCY REPORT',90)
SETFONT ( 'UNBOLD' )
@ prow  ()+1,03 say padc(mdate, 90)

return


******************************
static function print_head()
******************************
    memvar mtitle,mpage,gsys_name,gcompany,mlm,mmonth,mdays,myear
    eval ({|| ;
       mtitle := 'Weekly Deliquency Report',;
       prnreptitle  ( 132,mlm,mpage,mtitle,'Program ID:AMSR1300',gsys_name,gcompany),;
       pagecenter   ( prow()+1,132,'As of '+fr0100month( trans(mmonth,'99') )+' '+trans(mdays,'99')+', '+trans(myear,'9999') );
       })
       @ prow()+1,0 say ''
return nil

*******************************
*
static function print_subhead()
*******************************
setfont('CONDENSED')
    eval({|| ;
devpos( prow()+1, 01 ) , devout( "ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿" ),;
devpos( prow()+1, 01 ) , devout( "³ Client LA No   ³ ACCT ³            CLIENT / PRINCIPAL        ³     DATE OF   ³   LAST    ³   MONTHLY RATE    ³    OUTSTANDING    ³  MONTHS    ³     TOTAL AMOUNT  ³   MATURITY   ³             R E M A R K S              ³" ),;
devpos( prow()+1, 01 ) , devout( "³                ³  NO  ³                COLLATERAL            ³    EXECUTION  ³  PAYMENT  ³  AMORTIZATION     ³      BALANCE      ³ PAST DUE   ³       PASTDUE     ³     DATE     ³                                        ³" ),;
devpos( prow()+1, 01 ) , devout( "ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ" );
        })

********************************
static function amsr1300open()
********************************
    local mretval := .f.
    memvar g_cis_path
    if netuse( 'Acctmast',.f.,5)
       set index to Acctmast,Acctclnt,Sureclnt, Acctacno
       set order to 4
       if netuse( 'Paysked',.f.,5)
          set index to Paysked
          if netuse( 'Payimage',.f.,5)
             set index to Payimage
             if netuse(  '&g_cis_path'+'\Client.dbf',.f.,5)
                set index  to &g_cis_path\Cliecd, &g_cis_path\Clienm
                if netuse('Delqdtls',.f.,5)
                   set index to Delqdtls
                   if netuse(  '&g_cis_path'+'\Signers.dbf',.f.,5)
                      set index to &g_cis_path\Signers
                      mretval := .t.
                   endif
                endif
             endif
          endif
      endif
   endif
return mretval
*                     End of the program ( amsr1300.prg )
