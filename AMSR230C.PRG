/*
…ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕª
∫   program ID.........:  amsr2300.prg                                         ∫
∫   description........:  aging of pdr / delinquency report(accounting)        ∫
∫   author.............:  Ariel B. Bulan                                       ∫
∫   date...............:  01:49pm 12-Nov-1994                                  ∫
ÃÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ
∫                   ∫ U P D A T E S ∫                                          ∫
ÃÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕŒÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕŒÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ
∫        Who        ∫     When      ∫               Why                        ∫
ÃÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕŒÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕŒÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ
∫ Renan Evangelista ∫  1997 - 1998  ∫ columns of days past due must            ∫
∫                   ∫               ∫ reflect o/b, not the past due amt        ∫
∫                   ∫               ∫ (industry practice)                      ∫
∫ Janet B. Salvador ∫  19-Jan-1999  ∫ add new acctno                           ∫
∫                   ∫               ∫                                          ∫
∫ abb               ∫  may 16, 2000 ∫ Acctmast->osbal should not be            ∫
∫                   ∫               ∫    the basis for outstanding bal.        ∫
∫                   ∫               ∫   (it should be from amshist.dbf         ∫
∫                   ∫               ∫   (not from acctmast)                    ∫
∫                   ∫               ∫                                          ∫
∫ abb               ∫  may 24, 2000 ∫ as requested by cynthia(acctg)           ∫
∫ abb               ∫  sept 12, 2000∫ removed 10% validation (cynthia)         ∫
∫                   ∫               ∫                                          ∫
∫  mts              ∫   12.29.2006  ∫   added AMSHIST2                         ∫
∫ aga               ∫   14.02.2007  ∫ neo paysked support for modules          ∫
»ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº
*/

#include "COLF.CH"
#include "INKEY.CH"

#define MAXROW 55

memvar ax_level,g_user_id
private mtemp,mtemp2,nchoice
private _sold_choice
private lsummary          //aga.04.03.2008.audit mod

if chkpass( procname(),ax_level,g_user_id )
   if amsr0400open()
      if _get_sold_choice()
         _summ_menu()     //aga.04.03.2008.audit mod
         _comp_menu()
         amsr0400main()
      endif
   endif
   __mrelease ( "*", .t.)
   dbcloseall ()
endif
return

******************************
*
static function amsr0400main()
******************************
   local  mdbf   := savedbf (mdbf), mcolor := setcolor(), mcursor := setcursor()
   memvar gtrandate,mtemp,mtemp2
   private mpage := 0,mmonth,mdays,myear,mtitle,mlm,mdate, lSORT := .F.    && RED 012305 ADDED
   mtitle := 'Aging of Past-Due Receivables'; mlm := 0 ; mdate  := gtrandate
   

   if create_temp()
      do while get_mdate( 7 )

         lSORT := CONFIRM ( 'Sort by Outstanding Balance (descending) ? ' )

         mpage := 0

         select (mtemp) ; __dbZap()
		 
         eval ({|| mmonth := month (mdate) ,;
                   mdays  := day   (mdate) ,;
                   myear  := year  (mdate) ,;
                   xSTR   := CHK_PAR(_SOLD_CHOICE)+;
                             CHK_PAR(mPAGE)       +;
                             CHK_PAR(mMONTH)      +;
                             CHK_PAR(mDAYS)       +;
                             CHK_PAR(mYEAR)       +;
                             CHK_PAR(mTITLE)      +;
                             CHK_PAR(mLM)         +;
                             CHK_PAR(mDATE)       +;
                             CHK_PAR(gTRANDATE)   +;
                             CHK_PAR(gSYS_NAME)   +;
                             CHK_PAR(gCOMPANY)    +;
                             CHK_PAR(nCHOICE)     +;
                             CHK_PAR(lSORT)       ,;
                   REPCON_OL ( 'AMSR230CPRN()','132 COLUMN<CONT.>',,8,33,,xSTR,.T.) ; && RED 012205  repcontrol ( 'amsr230cprn()','132 Column<Cont.>',,8,33) ;
              })
//aga.3.10.2005.redirected for testing
/*
         eval ({|| mmonth := month (mdate) ,;
                   mdays  := day   (mdate) ,;
                   myear  := year  (mdate) ,;
                   repcontrol ( 'amsr230cprn()','132 Column<Cont.>',,8,33) ;
              })
*/
      enddo
   else
      error ( 'Cannot create temporary file!' )
   endif
 //PEPE  setcolor  (mcolor); setcursor (mcursor) ; restdbf   (mdbf)
return nil

******************************
*
function amsr230cprn()
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
    private mcg1_30,mcg31_60,mcg61_90,mcg91_180,mcg180_360,mcg360_above,mcgtpastdue,mcgosbal,mccur := 0,mcgosbal
    private ma1_30,ma31_60,ma61_90,ma91_180,ma180_360,ma360_above
    private mag1_30,mag31_60,mag61_90,mag91_180,mag180_360,mag360_above,mcagosbal,mcagcur := 0

    private new := .t.,nosbal := 0

    mpamort:= mp1_30 := mp31_60:= mp61_90 := mp91_180 := mp180_360   := mp360_above := mptpastdue := mposbal :=0
    mgamort:= mg1_30 := mg31_60:= mg61_90 := mg91_180 := mg180_360   := mg360_above := mgtpastdue := mgosbal :=0
    msamort:= ms1_30 := ms31_60:= ms61_90 := ms91_180 := ms180_360   := ms360_above := mstpastdue := msosbal :=0

    ma1_30  := ma31_60  := ma61_90  := ma91_180  := ma180_360  := ma360_above := 0
    mag1_30 := mag31_60 := mag61_90 := mag91_180 := mag180_360 := mag360_above := mcagosbal := 0

    setprc (0,0 )
    @ prow (),pcol() say chr(15)
    print_head    ()
    setfont       ( 'CONDENSED' )
    print_subhead ()
    @ prow()+1,00 say ''

    Acctmast->(dbgotop())

    if _sold_choice == 1               // EXCLUDE SODL REC'BLES ( 8.27.2001)

        mcgosbal  := 0
        mcagosbal := 0
        Acctmast->(dbeval({|| if ( val( Acctmast->STATUS) < 3     .and. ;
                                   Acctmast->Valdate <= mdate     .and. ;
                                   nchoice == _company_accounts('ACCTMAST') .AND. ;
                                   ACCTMAST->BRCODE == g_PAR_BRCH ,;
                              eval ({ || mclntcode := Acctmast->Acctname ,;
                                         Acctmast->( dbeval({|| if( val( Acctmast->STATUS ) < 3           .and. ;
                                                                    !_employee_loans(Acctmast->fcltycode) .and. ;
                                                                    nchoice == _company_accounts('ACCTMAST')   ,;
                                                                    eval({||  ; //Paysked->(dbseek(Acctmast->ACCTNO+dtos(mdate),.t.)),
                                                                            nosbal  := _get_outs() ,;
                                                                            if ( nosbal != 0  ,;
                                                                                 eval ({|| ;
                                                                                          mcgosbal++;
                                                                                      }),;
                                                                                 nil ;
                                                                               ),;
                                                                            traverse_sked() ,;
                                                                            mgosbal   += nosbal  ;   // mgosbal += Acctmast->Osbal ;
                                                                         }),;
                                                                    nil ;
                                                                  )},,;
                                         {|| !Acctmast->(eof()) .and. Acctmast->Acctname == mclntcode .and. Acctmast->brcode == g_PAR_BRCH .and. Acctmast->Valdate <= mdate} )),;
                                         Acctmast->( dbskip(-1) )         ;
                                    }),;
                              nil ) ;
                          } ,,;
                          {|| !Acctmast->(eof())} ;
                         ) ;
                  )

        if lSORT        && RED 012305 confirm ( 'Sort by Outstanding Balance (descending) ? ' )
           _prn_tmp()
        else
           _prn_temp()
        endif
//if (g_PAR_BRCH != ACCTMAST->BRCODE ,alert(indexkey() + ' before calling tranverse ' + g_PAR_BRCH +'<>'+ ACCTMAST->BRCODE),nil)
//aga.20.05.2005.dbeval trap prior tranverse, added new brcode validation on 2nd dbeval 
//aga.07.07.2005.mdate reconfirm on 2nd dbeval (v-^), update on cps
    else                      // SOLD  RECEIVABLES

        mcgosbal  := 0
        mcagosbal := 0
        Acctmast->(dbeval({|| if ( val(Acctmast->STATUS) == 6     .and. ;
                                   Acctmast->Valdate <= mdate     .and. ;
                                   nchoice == _company_accounts('ACCTMAST') .AND. ;
                                   ACCTMAST->BRCODE == g_PAR_BRCH ,;
                              eval ({ || mclntcode := Acctmast->Acctname ,;
                                         Acctmast->( dbeval({|| if( val( Acctmast->STATUS ) == 6           .and. ;
                                                                    !_employee_loans(Acctmast->fcltycode) .and. ;
                                                                    nchoice == _company_accounts('ACCTMAST')   ,;
                                                                    eval({||  ;
                                                                            nosbal  := _get_outs() ,;
                                                                            if ( nosbal != 0  ,;
                                                                                 eval ({|| ;
                                                                                          mcgosbal++;
                                                                                      }),;
                                                                                 nil ;
                                                                               ),;
                                                                            traverse_sked()     ,;
                                                                            mgosbal   += nosbal  ;   // mgosbal += Acctmast->Osbal ;
                                                                         }),;
                                                                    nil ;
                                                                  )},,;
                                         {|| !Acctmast->(eof()) .and. Acctmast->Acctname == mclntcode .and. Acctmast->brcode == g_PAR_BRCH .and. Acctmast->Valdate <= mdate} )),;
                                         Acctmast->( dbskip(-1) )         ;
                                    }),;
                              nil ) ;
                          } ,,;
                          {|| !Acctmast->(eof())} ;
                         ) ;
                  )

        if lSORT        && RED 012305 confirm ( 'Sort by Outstanding Balance (descending) ? ' )
           _prn_tmp()
        else
           _prn_temp()
        endif


    endif
		
    __eject()

    
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

//aga.04.05.2006.removed
/*
********************************
static function print_clntcode()
********************************

 if Paysked->(dbseek( ACCTMAST->BRCODE+Acctmast->Acctno)) .and. Paysked->Paydate + 5 < mdate
   new := .t.
   eval ({|| devpos(prow()+1,000)                              ,;
             devoutpict (ACCTMAST->BRCODE+Acctmast->CLNTCODE,'@R 999-99-99999')     ,;
             devpos(prow()  ,9+4)                                ,;
             devout(left(dispclntname(ACCTMAST->BRCODE+Acctmast->CLNTCODE,40),20))  ;
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
      while PAYSKED->BRCODE+Paysked->ACCTNO == ACCTMAST->BRCODE+Acctmast->ACCTNO .and. Paysked->Paydate <= mdate
         if Paysked->Paydate + mval < mdate
            retval += paysked->amtdue
         endif
         Paysked->(dbskip(1))
      enddo
return retval
*/


***********************************
*
static function traverse_sked()
***********************************
    local  mclntno  ,macctno, mu := 0,mval:=0, mBRCODE
    local  mnextpaydate,mmatdate,mpayfreq,mremterm:=0,date_ok := .f.
    local  mdiffdate   := 0,mdiff := 0,sw:=.f., p_due:= .f.
    local  _mdiffdate2 := 0
    memvar mdate

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


//aga.04.05.2006.marked for modification

    dbselectarea('Paysked')
    Paysked->(dbsetorder(2))

    Paysked->(dbseek(ACCTMAST->BRCODE+Acctmast->ACCTNO+'D'))
    mu := Paysked->(recno())

    Paysked-> ( dbeval({ || mremterm++ },,{ || PAYSKED->BRCODE+Paysked->Acctno == ACCTMAST->BRCODE+Acctmast->Acctno .and. paysked->status == 'D'}) )
    Paysked-> ( dbgoto(mu) )

    mclntno  := Acctmast->CLNTCODE
    macctno  := right(Acctmast->ACCTNO,5)
    mamort   := Acctmast->AMORT
    mBRCODE  := ACCTMAST->BRCODE
    mmatdate := if ( empty(dtos(Acctmast->MATDATE)),;
                     ctod(''),;
                     Acctmast->MATDATE ;
                   )

    mpayfreq := Acctmast->PAYFREQ

//    if Paysked->(dbseek(ACCTMAST->BRCODE+Acctmast->ACCTNO,.t.)) .and. Paysked->Paydate <= mdate

    if Paysked->(dbseek(ACCTMAST->BRCODE+Acctmast->ACCTNO+'D')) .and. Paysked->Paydate <= mdate

       mosbal       := nosbal
       sw           := .t.
       mnextpaydate := Paysked->paydate

       mval         := if ( Paysked->Paydate + 5 > mdate,;
                            5,;
                            0 ;
                          )

       do while PAYSKED->BRCODE+Paysked->ACCTNO == ACCTMAST->BRCODE+Acctmast->ACCTNO .and. Paysked->Paydate <= mdate .and. Paysked->status == 'D'

         mcagosbal += paysked->amtdue

         if Paysked->Paydate <= mdate  // + if( p_due, 0, 5) <= mdate RLV 03/02/2011 Removed to sync with PDR tagging at EOD     //ADD 5 DAYS
            _mdiffdate2  := mdate - Paysked->Paydate                            //backdate(Paysked->Paydate)
			
            mnextpaydate := if ( !sw ,;
                                 eval({|| sw:=.t. ,;
                                          Paysked->Paydate ;
                                     }),;
                                 mnextpaydate ;
                               )
            mtpastdue    += paysked->amtdue

            if _mdiffdate2 <= 90
               p_due     := .t.
               mdiffdate := if ( !date_ok,;
                                  eval ( { || date_ok := .t.,;
                                              mdate - Paysked->Paydate ;         //backdate(Paysked->Paydate) ;
                                         };
                                       ),;
                                  mdiffdate ;
                               )
            else
               if _mdiffdate2 > 90
                  p_due     := .t.
                  mdiffdate := if ( !date_ok,;
                                     eval ( { || date_ok := .t.,;
                                                 mdate - Paysked->Paydate ;       //backdate(Paysked->Paydate) ;
                                            };
                                          ),;
                                     mdiffdate ;
                                  )
               else
                  sw:=.f.
               endif

            endif
         endif

         /*
         if Paysked->Paydate + if( p_due, 0, 5) <= mdate      //ADD 5 DAYS

            _mdiffdate2  := mdate - Paysked->Paydate 

            if !sw 
               sw:=.t. 
               mnextpaydate := Paysked->Paydate 
            end if

            mtpastdue += paysked->amtdue

            if _mdiffdate2 <= 90
               p_due     := .t.

               if !date_ok
                  date_ok := .t.
                  mdiffdate := mdate - Paysked->Paydate                
               end if
            else

               if _mdiffdate2 > 90
                  p_due     := .t.

                 if !date_ok
                    date_ok := .t.
                    mdiffdate := mdate - Paysked->Paydate 
                 end if
               else
                  sw:=.f.
               endif

            endif
         endif
         */
         //............................................

         Paysked->(dbskip(+1))

       enddo       
//..........................................                   
	    //if acctmast->acctno == '05181040700568'
		//   alert(dtos(mdate)+ ' '+str(mdiffdate))
		//endif
		
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
             mtpastdue   := mtpastdue
          otherwise
             ncurosbal   += mosbal
             mcagcur     += mtpastdue
       endcase

       if mtpastdue > 0 .and. mdiffdate > 0
          mosbal   := nosbal
          save_to_temp ( mBRCODE+macctno,mamort,m1_30,m31_60,m61_90,m91_180,m180_360,m360_above,mtpastdue,mosbal,mnextpaydate,mmatdate,mpayfreq,mremterm)
          new := .f.
       else
          mosbal := 0
       endif


    endif

return nil

*****************************************
*
static function backdate( present_date )
*****************************************
local nyear := year(gTRANDATE)

nPrev_month := present_date
nMONTH      := subs(dtos(present_date),5,2)

   do case
   
	  case nMONTH $ '_05_07_10_12'
           nPrev_month := present_date - 30

      case nMONTH $ '_01_02_04_06_08_09_11'
           nPrev_month := present_date - 31

      case nMONTH == '03'
	       if nyear/4 <> int(nyear/4)
              nPrev_month := present_date - 28
		   else
              nPrev_month := present_date - 29
		   endif
		   
   endcase

return nPrev_month

***************************************************************************************************************
*
static function percentage (mg1_30,mg31_60,mg61_90,mg91_180,mg180_360,mg360_above,mgtpastdue,mgosbal,ncurosbal)
***************************************************************************************************************
    local mcol  := { 37,43,62,81,100,119,138,157,176,195,206,217,223 }
    local u,v,w,x,y,z
    LOCAL nTOT := 0              

    memvar mcg1_30,mcg31_60,mcg61_90,mcg91_180,mcg180_360,mcg360_above,mcgtpastdue,mcgosbal,mccur

//aga.04.03.2008.audit mod
if lsummary
    print_head()
end if

    setfont ('NLQ')
    setfont ('BOLD')
    @ PROW  ()+2, 10

    @ prow  ()+1,61 say 'Percentage to          Number                  Total'
    @ prow  ()+1,61 say 'Total Receivables      of Accounts             Past Due '

    setfont ('UNBOLD')

    v :=  ( mg1_30+mg31_60+mg61_90+mg91_180+mg180_360+mg360_above )
    u :=  ( mGOSBAL - nCUROSBAL )             
    nTOT := V + U                            


    // alert ( str(mcgosbal) + 'dasf'+ str(mccur) )
//aga.3.10.2005.added v value to reflect osbal on current
//    @ prow()+2, 10 say 'C U R R E N T             :'+ spac(4) + tran( u:= ( mgosbal - ncurosbal ),'99,999,999,999.99' ) + spac(10) + trans( getpercent( u, v+u ),'999.99')  + ' %'+ space(10)+ trans( mcgosbal-mccur,'99,999') + space(10)+ trans( mcagosbal-mcagcur,'99,999,999,999.99' )
//aga.06.03.2008.audit it head request, remove past due column
//    @ prow()+2, 10 say 'C U R R E N T             :'+ spac(4) + tran( u:= ( mgosbal - ncurosbal + v),'99,999,999,999.99' ) + spac(10) + trans( getpercent( u, v+u ),'999.99')  + ' %'+ space(10)+ trans( mcgosbal-mccur,'99,999') + space(10)+ trans( mcagosbal-mcagcur,'99,999,999,999.99' )
    @ prow()+2, 10 say 'C U R R E N T             :'+ spac(4) + tran( u:= ( mgosbal - ncurosbal + v),'99,999,999,999.99' ) + spac(10) + trans( getpercent( u, v+u ),'999.99')  + ' %'+ space(10)+ trans( mcgosbal-mccur,'99,999') 

//........................................................
    @ prow()+1, 10 say '01 - 30  Days Past Due    :'+ spac(4) + tran( mg1_30     ,'99,999,999,999.99' ) + spac(10) + trans( getpercent( mg1_30     ,v+u ),'999.99' ) + ' %' +       space(10)+ trans( mcg1_30     ,'99,999')   + space(10)+ trans( mag1_30          ,'99,999,999,999.99' ) //mgosbal
    @ prow()+1, 10 say '31 - 60  Days Past Due    :'+ spac(4) + tran( mg31_60    ,'99,999,999,999.99' ) + spac(10) + trans( getpercent( mg31_60    ,v+u ),'999.99' ) + ' %' +       space(10)+ trans( mcg31_60    ,'99,999')   + space(10)+ trans( mag31_60         ,'99,999,999,999.99' ) //mgosbal
    @ prow()+1, 10 say '61 - 90  Days Past Due    :'+ spac(4) + tran( mg61_90    ,'99,999,999,999.99' ) + spac(10) + trans( getpercent( mg61_90    ,v+u ),'999.99' ) + ' %' +       space(10)+ trans( mcg61_90    ,'99,999')   + space(10)+ trans( mag61_90         ,'99,999,999,999.99' ) //mgosbal
    @ prow()+1, 10 say '91 - 180 Days Past Due    :'+ spac(4) + tran( mg91_180   ,'99,999,999,999.99' ) + spac(10) + trans( getpercent( mg91_180   ,v+u ),'999.99' ) + ' %' +       space(10)+ trans( mcg91_180   ,'99,999')   + space(10)+ trans( mag91_180        ,'99,999,999,999.99' ) //mgosbal
    @ prow()+1, 10 say '181- 360 Days Past Due    :'+ spac(4) + tran( mg180_360  ,'99,999,999,999.99' ) + spac(10) + trans( getpercent( mg180_360  ,v+u ),'999.99' ) + ' %' +       space(10)+ trans( mcg180_360  ,'99,999')   + space(10)+ trans( mag180_360       ,'99,999,999,999.99' ) //mgosbal
    @ prow()+1, 10 say '361 Days and Above        :'+ spac(4) + tran( mg360_above,'99,999,999,999.99' ) + spac(10) + trans( getpercent( mg360_above,v+u ),'999.99' ) + ' %' +       space(10)+ trans( mcg360_ABOVE,'99,999')   + space(10)+ trans( mag360_ABOVE     ,'99,999,999,999.99' ) //mgosbal
    @ prow()+1, 10 say '                           '+space(4) + repl('-',17 )+space(10) + repl('-',6 )  + spac(10) + repl('-',11 )+space(7) + repl('-',17 )

//aga.06.03.2008.audit it head request, remove past due column
//    @ prow()+1, 10 say 'T O T A L                 :'+ spac(4) + tran( v+u,'99,999,999,999.99' ) + spac(10) + trans( 100,'999.99') + ' %'+ space(10)+trans( mcgosbal-mccur+mcg1_30+mcg31_60+mcg61_90+mcg91_180+mcg180_360+mcg360_ABOVE,'999,999')+ space(9)+trans( mcagosbal-mcagcur+mag1_30+mag31_60+mag61_90+mag91_180+mag180_360+mag360_ABOVE,'99,999,999,999.99' )
    @ prow()+1, 10 say 'T O T A L                 :'+ spac(4) + tran( v+u,'99,999,999,999.99' ) + spac(10) + trans( 100,'999.99') + ' %'+ space(10)+trans( mcgosbal-mccur+mcg1_30+mcg31_60+mcg61_90+mcg91_180+mcg180_360+mcg360_ABOVE,'999,999') + space(9)+trans( mag1_30+mag31_60+mag61_90+mag91_180+mag180_360+mag360_ABOVE,'99,999,999,999.99' )   

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

/*
    @ prow()+1, 000 say "                                      ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ "
    @ prow()+1, 000       say mmessage

    @ prow()  , 28        say mamort     pict '999,999,999,999.99' //from 31
    @ prow()  , pcol()+2  say m1_30      pict '999,999,999,999.99'
    @ prow()  , pcol()+2  say m31_60     pict '999,999,999,999.99'
    @ prow()  , pcol()+2  say m61_90     pict '999,999,999,999.99'
    @ prow()  , pcol()+2  say m91_180    pict '999,999,999,999.99'
    @ prow()  , pcol()+2  say m180_360   pict '999,999,999,999.99'
    @ prow()  , pcol()+2  say m360_above pict '999,999,999,999.99'
    @ prow()  , pcol()+2  say mtpastdue  pict '999,999,999,999.99'
    @ prow()  , pcol()+2  say mosbal     pict '999,999,999,999.99'
*/
    @ prow()+1, 000 say "                                       ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ  ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ "
    @ prow()+1, 000 say mmessage

//aga.05.10.2005.absolute values to adjust other columns displaced by the inclusion of the "brcode+'-'"
    @ prow()  , 38        say mamort     pict '999,999,999,999.99' //from 31
    @ prow()  , 57        say m1_30      pict '999,999,999,999.99'
    @ prow()  , 76        say m31_60     pict '999,999,999,999.99'
    @ prow()  , 95        say m61_90     pict '999,999,999,999.99'
    @ prow()  , 114       say m91_180    pict '999,999,999,999.99'
    @ prow()  , 133       say m180_360   pict '999,999,999,999.99'
    @ prow()  , 152       say m360_above pict '999,999,999,999.99'
    @ prow()  , 171       say mtpastdue  pict '999,999,999,999.99'
    @ prow()  , 190       say mosbal     pict '999,999,999,999.99'

return nil

**********************************************************************************************************
static function _prn_subtotal ( mamort,m1_30,m31_60,m61_90,m91_180,m180_360,m360_above,mtpastdue,mosbal,mmessage)
**********************************************************************************************************
    local mcol  := { 37,43,62,81,100,119,138,157,176,195,206,217,224 }

//aga.04.03.2008.audit mod
if lsummary
    @ prow()+1, 000 say "                                       ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ  ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ "
    @ prow()+1, 000 say mmessage

//aga.05.10.2005.absolute values to adjust other columns displaced by the inclusion of the "brcode+'-'"
    @ prow()  , 38        say mamort     pict '999,999,999,999.99' //from 31
    @ prow()  , 57        say m1_30      pict '999,999,999,999.99'
    @ prow()  , 76        say m31_60     pict '999,999,999,999.99'
    @ prow()  , 95        say m61_90     pict '999,999,999,999.99'
    @ prow()  , 114       say m91_180    pict '999,999,999,999.99'
    @ prow()  , 133       say m180_360   pict '999,999,999,999.99'
    @ prow()  , 152       say m360_above pict '999,999,999,999.99'
    @ prow()  , 171       say mtpastdue  pict '999,999,999,999.99'
    @ prow()  , 190       say mosbal     pict '999,999,999,999.99'
                        
    @ prow()+1, 000 say 'No. of Accounts : '

    //@ prow()  , 34        say space(18)
    @ prow()  , 60    say mc1_30      pict '999,999,999,999'
    @ prow()  , 79    say mc31_60     pict '999,999,999,999'
    @ prow()  , 98    say mc61_90     pict '999,999,999,999'
    @ prow()  , 117   say mc91_180    pict '999,999,999,999'
    @ prow()  , 136   say mc180_360   pict '999,999,999,999'
    @ prow()  , 155   say mc360_above pict '999,999,999,999'



    @ prow()+1, 000 say 'Past Due :        '

    @ prow()  , 57   say ma1_30      pict '999,999,999,999.99'
    @ prow()  , 76   say ma31_60     pict '999,999,999,999.99'
    @ prow()  , 95   say ma61_90     pict '999,999,999,999.99'
    @ prow()  , 114  say ma91_180    pict '999,999,999,999.99'
    @ prow()  , 133  say ma180_360   pict '999,999,999,999.99'
    @ prow()  , 152  say ma360_above pict '999,999,999,999.99'
end if
//...............................................................................................


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

//aga.04.03.2008.audit mod
   if lsummary
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
   end if 

      do while substr ( (mtemp)->acctno,5,3 ) == ctype .and. !(mtemp)->(eof())

          print_it  ('1')

          if prow() >= MAXROW
             //mpage++
             page_grand_total ( mpamort,mp1_30,mp31_60,mp61_90,mp91_180,mp180_360,mp360_above,mptpastdue,mposbal,'Page Total',.t.)
             mpamort:= mp1_30 := mp31_60:= mp61_90 := mp91_180:= mp180_360 := mp360_above:= mptpastdue:= mposbal :=0

//aga.04.03.2008.audit mod
          if lsummary
             __eject ()
          end if

             setprc  ( 0,0 )
             @ prow  ()+1, 00 say 'Page : ' + trans(mpage, '999' )
             print_subhead ()
          endif
          (mtemp)-> (dbskip(+1))

      enddo

      _prn_subtotal ( msamort,ms1_30,ms31_60,ms61_90,ms91_180,ms180_360,ms360_above,mstpastdue,msosbal,'Sub Total',.t.)


   enddo

//aga.04.03.2008.audit mod
if lsummary
   __eject()
end if

   percentage ( mg1_30,mg31_60,mg61_90,mg91_180,mg180_360,mg360_above,mgtpastdue,mgosbal,ncurosbal )
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
         //mpage++
         page_grand_total ( mpamort,mp1_30,mp31_60,mp61_90,mp91_180,mp180_360,mp360_above,mptpastdue,mposbal,'Page Total',.t.)
         mpamort:= mp1_30 := mp31_60:= mp61_90 := mp91_180:= mp180_360 := mp360_above:= mptpastdue:= mposbal :=0

//aga.04.03.2008.audit mod
       if lsummary
         __eject ()
       end if
 
         setprc  ( 0,0 )
         @ prow  ()+1, 00 say 'Page : ' + trans(mpage, '999' )
         print_subhead ()
      endif

      (mtemp)-> (dbskip(-1))

   enddo

//aga.04.03.2008.audit mod
if lsummary
   @ prow()+1, 000+4 say "                                      ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ  ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ  ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ "
   @ prow()+1, 000+4     say 'Grand Total '

   @ prow()  , 31+4      say _mgamort     pict '999,999,999,999.99'
   @ prow()  , pcol()+2  say _mg1_30      pict '999,999,999,999.99'
   @ prow()  , pcol()+2  say _mg31_60     pict '999,999,999,999.99'
   @ prow()  , pcol()+2  say _mg61_90     pict '999,999,999,999.99'
   @ prow()  , pcol()+2  say _mg91_180    pict '999,999,999,999.99'
   @ prow()  , pcol()+2  say _mg180_360   pict '999,999,999,999.99'
   @ prow()  , pcol()+2  say _mg360_above pict '999,999,999,999.99'
   @ prow()  , pcol()+2  say _mgtpastdue  pict '999,999,999,999.99'
   @ prow()  , pcol()+2  say _mgosbal     pict '999,999,999,999.99'
   @ prow()+1, 000+4 say "                                      ================== ================== ================== ================== ================== ================== ================== ================== ================== "
end if

//aga.04.03.2008.audit mod
if lsummary
   __eject()
end if

   percentage ( mg1_30,mg31_60,mg61_90,mg91_180,mg180_360,mg360_above,mgtpastdue,mgosbal,ncurosbal )
   __eject()

return nil

*******************************************
*
static function print_it( _one_is_lcr_fr )
*******************************************
    local mcol := { 37,43,62,81,100,119,138,157,177,197,209,224 }

//aga.05.10.2005.absolute values to adjust other columns displaced by the inclusion of the "brcode+'-'"
//aga.04.03.2008.audit mod
if lsummary
    @ prow()+1,00       say (MTEMP)->BRCODE+'-'+substr((mtemp)->ACCTNO,-5,5)
    @ prow(),pcol()+2   say (mtemp)->ACCTNAME
    @ prow(),38         say (mtemp)->AMORT      pict '999,999,999,999.99'
    @ prow(),57         say (mtemp)->N1_30      pict '999,999,999,999.99'
    @ prow(),76         say (mtemp)->N31_60     pict '999,999,999,999.99'
    @ prow(),95         say (mtemp)->N61_90     pict '999,999,999,999.99'
    @ prow(),114        say (mtemp)->N91_180    pict '999,999,999,999.99'
    @ prow(),133        say (mtemp)->N181_360   pict '999,999,999,999.99'
    @ prow(),152        say (mtemp)->N361_ABOVE pict '999,999,999,999.99'
    @ prow(),171        say (mtemp)->NPASSDUE   pict '999,999,999,999.99'
    @ prow(),190        say (mtemp)->NOSBAL     pict '999,999,999,999.99'
    @ prow(),212        say (mtemp)->DNEXTPAYD
    @ prow(),223        say (mtemp)->DMATDATE

end if
//................................................

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
*
static function save_to_temp ( macctno,mamort,m1_30,m31_60,m61_90,m91_180,m180_360,m360_above,mtpastdue,mosbal,mnextpaydate,mmatdate,mpayfreq,mremterm)
*******************************************************************************************************************************************************
    memvar mtemp,mtemp2
    local mcol := { 37,43,62,81,100,119,138,157,177,197,209,224 }

    (mtemp)->(dbappend())
    (mtemp)->ACCTNO      := Acctmast->acctno
    (mtemp)->ACCTNAME    := left(dispclntname(ACCTMAST->BRCODE+Acctmast->CLNTCODE,40),23)
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
    (MTEMP)->BRCODE      := ACCTMAST->BRCODE

return nil

******************************
*
static function print_head()
******************************
    memvar mtitle,mpage,gsys_name,gcompany,mlm,mmonth,mdays,myear

    mtitle := if ( _sold_choice==1,'Delinquency Report','Delinquency of Sold Receivables')
    mpage++
    prnreptitle  ( 132,mlm,mpage,mtitle,'Program ID:Amsr230c',gsys_name,gcompany)
    pagecenter   ( prow()+1,132,'As of '+fr0100month( trans(mmonth,'99') )+' '+trans(mdays,'99')+', '+trans(myear,'9999') )

    do case
       case nchoice == 1
          pagecenter   ( prow()+1,132,'First Metro' )
       case nchoice == 2
          pagecenter   ( prow()+1,132,'PBC Finance' )
       case nchoice == 3
          pagecenter   ( prow()+1,132,'ORIX Metro' )
    endcase
    @ prow()+1,0 say ''

return nil

*******************************
*
static function print_subhead()
*******************************

//aga.05.10.2005.removed 4 spaces to adjust the displacement caused by the inclusion of the "brcode+'-'"
//aga.04.03.2008.audit mod
if lsummary
    setfont ( 'CONDENSED' ) //minus 2
    eval({|| devpos( prow()+1, 00 ) , devout( "ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ  ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ  ƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒ" ),;
             devpos( prow()+1, 00 ) , devout( "  Client No./Name                         Amortization         1-30 Days         31-60 Days         61-90 Days         91-180 Days       181-360 Days      361 Days Above     Total Past Due       Outstanding         Next     Maturity " ),;
             devpos( prow()+1, 00 ) , devout( "                                                                                                                                                                                                   Balance           Pay Date     Date   " ),;
             devpos( prow()+1, 00 ) , devout( "ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ  ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ  ƒƒƒƒƒƒƒƒƒƒ ƒƒƒƒƒƒƒƒƒƒ" );
        })
end if
//.......................................................

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
   local xacctno,xornum,xrefdate,xcode,nrow:= { 05,19,32,43,60,86,93,117 }, xBRCODE
   local _ddate := mdate

if Amshist->  ( dbseek(ACCTMAST->BRCODE+Acctmast->Acctno) )
   ncredamt := Acctmast->Credamt

   do while AMSHIST->BRCODE+Amshist->Acctno == ACCTMAST->BRCODE+Acctmast->Acctno .and. !Amshist->(eof())

         xrefdate  := Amshist->Refdate
         xornum    := Amshist->Ornumber
         xacctno   := Amshist->Acctno
         xcode     := Amshist->Paycode
         xBRCODE   := AMSHIST->BRCODE
         unpd_pen  += Amshist->Unpd_pnlty

         do while AMSHIST->BRCODE+Amshist->Acctno   == xBRCODE+xAcctno  .and. ;
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

/*
         if alltrim(xcode) == '1' // PAYMENT ? ( Sept. 07, 1999 )
            dretval     := xrefdate
            clastperiod := pperiod + '->'+ pay_ [ val( xcode ) ]
         else
            dretval     := xrefdate
            clastperiod := pperiod + '->'+ pay_ [ val( xcode ) ]
         endif
*/

         nretval -= (xamort)

         pprd      := {}
         tot_or    += xOramount
         tot_am    += xamort
         tot_penal += xPenal
         xoramount := xamort := xpenal := 0

   enddo
endif


if Amshist2->  ( dbseek(ACCTMAST->BRCODE+Acctmast->Acctno) )
   ncredamt := Acctmast->Credamt

   do while AMSHIST2->BRCODE+AMSHIST2->Acctno == ACCTMAST->BRCODE+Acctmast->Acctno .and. !AMSHIST2->(eof())

         xrefdate  := AMSHIST2->Refdate
         xornum    := AMSHIST2->Ornumber
         xacctno   := AMSHIST2->Acctno
         xcode     := AMSHIST2->Paycode
         xBRCODE   := AMSHIST2->BRCODE
         unpd_pen  += AMSHIST2->Unpd_pnlty

         do while AMSHIST2->BRCODE+AMSHIST2->Acctno   == xBRCODE+xAcctno  .and. ;
                  AMSHIST2->Ornumber == xornum   .and. ;
                  AMSHIST2->Refdate  == xrefdate .and. ;
                  AMSHIST2->Paycode  == xcode    .and. ;
                 !AMSHIST2->(eof())

             if xrefdate <= _ddate

                xOramount += if ( val( AMSHIST2->Paycode ) < 8,;
                                  AMSHIST2->Oramount,;
                                  0;
                                )
                xamort    += AMSHIST2->Amort
                xpenal    += AMSHIST2->Penalty

                if ( !empty( AMSHIST2->Paydate ) ,;
                      aadd ( pprd,AMSHIST2->Paydate ),;
                      nil ;
                   )

             endif

             AMSHIST2->(dbskip(+1))
         enddo

         pperiod := if ( len (pprd) > 0,;
                         dtoc( pprd[ 1 ] ) + ;
                         if ( len(pprd ) > 1,;
                              '-' +dtoc(atail(pprd)),;
                              ' ' ;
                            ),;
                         ' ' ;
                       )

/*
         if alltrim(xcode) == '1' // PAYMENT ? ( Sept. 07, 1999 )
            dretval     := xrefdate
            clastperiod := pperiod + '->'+ pay_ [ val( xcode ) ]
         else
            dretval     := xrefdate
            clastperiod := pperiod + '->'+ pay_ [ val( xcode ) ]
         endif
*/

         nretval -= (xamort)

         pprd      := {}
         tot_or    += xOramount
         tot_am    += xamort
         tot_penal += xPenal
         xoramount := xamort := xpenal := 0

   enddo

endif



return nretval

********************************
*
static function create_temp()
********************************
   memvar mtemp,mtemp2
   local cfullpath
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
                      { 'DMATDATE'   ,'D',08,00 } ,;
                      { 'BRCODE'     ,'C',03,00 } ;
                    }

   mtemp  := uniqfile()
   mtemp2 := _uniqfile()



//    dbcreate ( ( mtemp ) , mstruct )

//   mtemp  := 'c:\' + mtemp
  // mtemp2 := 'c:\' + mtemp2

   cfullpath  :=  ( mtemp )
//    dbcreate ( 'c:\'+cfullpath , mstruct )         // abb june 03, 2004
   dbcreate ( cfullpath , mstruct )         // abb june 03, 2004

   if valtype ( mtemp ) != 'U'
      if netuse ( (mtemp) ,.t.,0 )
         index on BRCODE+substr(acctno,5,5)+acctname to &mtemp  // facility+acctname
         if valtype ( mtemp2 ) != 'U'
            mretval := .t.
            index on nosbal to &mtemp2  // nosbal
            set index to &mtemp,&mtemp2
         endif
      endif
   endif

return mretval


********************************
static function _uniqfile()
********************************
   local mfiname, mrandnum
   do while .t.
      mrandnum := substr(time(),1,2) + substr(time(),4,2) + substr(time(),7,2)
      mfiname  := 'Z0' + mrandnum     // ABB 06.03.2004
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
    if netuse( '&g_AMS_PATH\Acctmast',.f.,5)
       set index to &g_AMS_PATH\Acctmast,;
                    &g_AMS_PATH\Acctclnt,;
                    &g_AMS_PATH\Sureclnt,;
                    &g_AMS_PATH\Acctacno
       set order to 4
       if netuse( '&g_AMS_PATH\Paysked',.f.,5)
          set index to &g_AMS_PATH\Paysked, &g_AMS_PATH\Paystat   //aga
          if netuse(  '&g_cis_path'+'\Client.dbf',.f.,5)
             set index  to &g_cis_path\Cliecd, &g_cis_path\Clienm
             if netuse( '&g_AMS_PATH\Amshist', .f., 5 )        && Account Payment history file
                set index to &g_AMS_PATH\Amshist                && set index on acctno
                if netuse( '&g_AMS_PATH\AMSBACK\Amshist2', .f., 5 )        && Account Payment history file
                   set index to &g_AMS_PATH\AMSBACK\Amshist2 
                   if netuse( '&g_AMS_PATH\payimage',.f.,5)
                      set index to &g_AMS_PATH\payimage
                      mretval := .t.
 		   endif
                endif
             endif
          endif
       endif
    endif

return mretval


//aga.04.03.2008.audit mod
**********************************
*
static function _summ_menu()
**********************************
   local _cscr := savescreen (,,,),menulist := {}
   summ_choice := 1   

   @ 15-9,40 clear to 18-9,62
   @ 15-9,40 to 18-9,62
   @ 16-9,41 prompt 'Print All            '
   @ 17-9,41 prompt 'Print Summary        '
   menu to summ_choice
   do case
      case summ_choice == 1
         lsummary := .t.
      case summ_choice == 2
         lsummary := .f.
   endcase

   restscreen  (,,,,_cscr)
return lastkey () != K_ESC
//.................................


********************************
*
static function _comp_menu()
********************************
   local mscr := savescreen (,,,)
   local menulist, mcolor := setcolor()

   nchoice := 0

   set color to 'w/n'
   @ 10,30 clear to 18,50
   @ 10,30 to 18,50 double
   @ 12,33 prompt 'FMLC Accounts '
   @ 14,33 prompt 'PBC  Accounts '
   @ 16,33 prompt 'ORIX Accounts '
   menu to nchoice

   setcolor(mcolor)
   restscreen ( ,,,, mscr )
return nil


**********************************
*
static function _get_sold_choice()
**********************************
   local _cscr := savescreen (,,,),menulist := {}
   _sold_choice := 1
   @ 15-9,40 clear to 18-9,62
   @ 15-9,40 to 18-9,62
   @ 16-9,41 prompt 'All (excluding sold) '
   @ 17-9,41 prompt 'Sold Receivables Only'
   menu to _sold_choice
   do case
      case _sold_choice == 1
//         alert ( str(_sold_choice) )
      case _sold_choice == 2
//         alert ( str(_sold_choice) )
   endcase

   restscreen  (,,,,_cscr)
return lastkey () != K_ESC

*
*                     End of the program ( amsr0400.prg )
*
