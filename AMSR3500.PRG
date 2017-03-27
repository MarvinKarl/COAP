/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ·
³   colf-iis -- account management system                                      º
³   program idúúú amsm5000                                                     º
³   descriptionúú Registry of approved applications                            º
³   authorúúúúúúú Engr. Michael B. Espina                                      º
³   dateúúúúúúúúú July 20, 1999 4:00 p.m.                                      º
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶
³                             u p d a t e s                                    º
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶
³        who        ³       when        ³               why                    º
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶
³      abb          ³  03/14/2001       ³  update committee groupings          º
³                   ³                   ³  get outstanding balance from        º
³                   ³                   ³      amshist.dbf not acctmast        º
³      mts          ³  12/29/2006       ³  added AMSHIST2                      º
³      aga          ³  14.02.2007       ³  removed paysked reference           º
ÔÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
*/

#include 'inkey.ch'
#include 'colf.ch'
#include 'dbstruct.ch'
////
#defi K_SPACEBAR   32
#defi microfeed    chr( 27 ) + 'J' + chr( 18 )

memvar  AX_LEVEL, gUSER_ID
setcursor (0)

if chkpass ( procname(), AX_LEVEL, gUSER_ID )
   begin sequence
      aOpen3500 ()
      aMain3500 ()
   end sequence
   dbcloseall()
endif
__mrelease( '*', .t. )
close all
return nil

********************************
*
static Function aMain3500()
********************************
 local mu := savescreen(,,,), gf := savedbf(), bf := setcursor(),dday
 private mmonth := month(gtrandate), myear := year(gtrandate),mdate

 fshadow ( 8, 30, 11, 47, 2, 'n/g' )
 while eval ({|| setcursor (3),;
                 get_month() ;
            })

     mdate   := ctod ( right( '0'+alltrim(str(mmonth,2)),2) +;
                       '/01/'                        +;
                       right( alltrim(str(myear,4)),4)       ;
                     )          // added by abb 3.16.2001

     mdate   := lastday(mdate)
     IF TRUE_BRCH == '001'
        amstemp := crea_xtemp()

        if !file(amstemp+'.DBF')
               dbcreate ( amstemp,;
                          { {'NUMBER','C',7,0 }, ;
                            {'ACTAKEN' ,'C',1,0 }, ;
                            {'ACTDATE' ,'D',8,0 }, ;
                            {'FLAG'    ,'C',1,0 };
                          };
                        )
        endif

        if !netuse('&amstemp',.F.,0)
           break
        endif
     ENDIF

     xSTR := CHK_PAR(mMONTH)+CHK_PAR(mYEAR)+CHK_PAR(mDATE)
     *repcontrol ( 'get_amsr3500()' )
     REPCON_OL ( 'GET_AMSR3500()',,,,,,xSTR,.T. )

     IF TRUE_BRCH == '001'
        close &amstemp
        ferase ( amstemp + '.DBF')
        ferase ( amstemp + '.NTX')
     ENDIF

 Enddo
 restdbf(gf);restscreen(,,,,mu);setcursor(bf)
 return nil

***********************************************
*
function get_amsr3500()
***********************************************
 local ca_ot_num := 0 , max      := {}, xrecno   := 0, x      := 0, linda   := ' '
 local texpose1  := 0 , texpose2 := 0 , texpose3 := 0, txpose := 0
 local ttx1      := 0 , ttx2     := 0 , ttx3     := 0, ttx4   := 0,ttxpose  := 0
 local gttx1     := 0 , gttx2    := 0 , gttx3    := 0, gttx4  := 0,gttxpose := 0,flaging:=0

 ************dbselectarea ( 'comcodes' )

 Comcodes->(dbgotop())
 do while comcodes->(!eof())
    aadd ( max,comcodes->maximum )
    Comcodes-> ( dbskip(+1) )
 enddo

     select cadetail
     go top
     Do while !cadetail->(eof())

        c_no:=cadetail->canumber
        Caheader->(dbseek(c_no))

        if Caheader->actaken            == '3'    .and. ; // APPROVED 3.14.2001
           month ( Caheader->Actdate )  == mmonth .and. ;
           year  ( Caheader->Actdate )  == myear

           t_canumbr := Cadetail->canumber
           t_actaken := Caheader->actaken
           t_actdate := Caheader->actdate

           texpose1  := Caheader->caline
           xrecno3   := Cadetail->(recno())
           indxno3   := Cadetail->(indexord())

           xrecno5   := Caheader->(recno())
           indxno5   := Caheader->(indexord())

           kind      := 1
           totalxpose := _get_total_xpose(t_canumbr,kind)

           Caheader-> ( dbsetorder(indxno5) )
           Caheader-> ( dbgoto(xrecno5) )
           Cadetail-> ( dbsetorder(indxno3) )
           Cadetail-> ( dbgoto(xrecno3) )

           dbselectarea ( '&amstemp' )

           ********append blank

           (amstemp)->(dbappend())

           (amstemp)->number  := 'CA' + t_canumbr
           (amstemp)->actaken := t_actaken
           (amstemp)->actdate := t_actdate

//            amount := totalxpose+texpose1

           amount := totalxpose        // abb 3.15.2001

           do case                      // added by abb 03/14/2001
              case amount <= max[1]
                 replace flag with '1'
              case amount > max[1] .and. amount <= max[2]
                 replace flag with '2'
              case amount > max[2] .and. amount <= max[3]
                 replace flag with '3'
              case amount > max[3] .and. amount <= max[4]
                 replace flag with '4'
              otherwise
                 replace flag with '5'
           endcase

        endif

        cadetail->(dbskip(+1))

     Enddo

     select Oticket
     go top

     Do while !Oticket->(eof())

        if Oticket->actaken          == '3'    .and. ;
           month(Oticket->Actdate)   == mmonth .and. ;
           year(Oticket->Actdate)    == myear

           t_canumbr := Oticket->otnumber
           t_actaken := Oticket->actaken
           t_actdate := Oticket->actdate
           texpose1  := Oticket->credamt

           xrecno4:=Oticket->(recno())
           indxno4:=Oticket->(indexord())

           kind:=2
           totalxpose:=_get_total_xpose(t_canumbr,kind)

           Oticket->(dbsetorder(indxno4))
           Oticket->(dbgoto(xrecno4))

           dbselectarea('&amstemp')
           append blank
           replace number  with 'TA'+ t_canumbr
           replace actaken with t_actaken
           replace actdate with t_actdate

           // amount:=totalxpose+texpose1
           amount:=totalxpose         // ABB 3.15.2001

           do case                       // added by abb 03/14/2001
              case amount <= max[1]
                 replace flag with '1'
              case amount > max[1] .and. amount <= max[2]
                 replace flag with '2'
              case amount > max[2] .and. amount <= max[3]
                 replace flag with '3'
              case amount > max[3] .and. amount <= max[4]
                 replace flag with '4'
              otherwise
                 replace flag with '5'
           endcase

        endif

        Oticket->(dbskip(+1))

     Enddo

     dbselectarea ( '&amstemp' )
     index on flag+number to &amstemp
     &amstemp->(dbgotop())

     ca_num2 := ' '
     ca_num3 := ' '
     ctr     := 1

     amsr35head ()
     Do while &amstemp->(!eof())

        if prow() > 33 
           __eject()
           amsr35head()
        endif

        x++
        xflag := alltrim(str(x))

        do case
           case x == 1
                linda:='SUB-CREDIT COMMITTEE I'
           case x == 2
                linda:='SUB-CREDIT COMMITTEE II'
           case x == 3
                linda:='CREDIT COMMITTEE'
           case x == 4
                linda:='EXECUTIVE COMMITTEE'
           case x == 5
                linda:='BOARD OF DIRECTORS'
        endcase

        @ prow()+1, 1 say ' '
        @ prow()+1, 1 say linda
        @ prow()+1, 1 say ' '

        Do while alltrim(&amstemp->flag) == xflag .and. ;
                 &amstemp->(!eof())

           ca_num := substr ( &amstemp->number,3,5 )

           if substr(&amstemp->number,1,2) == 'CA'

              Cadetail->(dbseek(ca_num))

              if ca_num <> ca_num3

                @ prow()+1,1 say 'CA ' + Cadetail->canumber

                Caheader->(dbsetorder(1))
                Caheader->(dbseek(ca_num))

                clcode := Caheader->clntcode

                Client->(dbseek(clcode))

                @ prow(),10  say substr(Client->fullname,1,30)
                @ prow(),44  say substr(Cadetail->unit,1,30) + '  '+ substr(Cadetail->unit2,1,30)
                @ prow(),109 say substr(Client->collect,1,25)

                if client->address2 == ' '
                   @ prow(),136 say substr(client->address3,1,25)
                else
                   @ prow(),136 say substr(client->address2,1,25)
                endif

                xrecno  := Caheader->(recno())
                indxno  := Caheader->(indexord())
                xrecno2 := Cadetail->(recno())
                indxno2 := Cadetail->(indexord())

                @ prow(),163 say trans(texpose1:=Caheader->caline,'999,999,999.99')

                code := Caheader->clntcode

                Acctmast->(dbsetorder(1))
                *****
                ************* Acctmast->(dbseek(code))
                ************* cclnt := acctmast->clntcode
                *****
                if Acctmast->(dbseek(code))
                   cclnt := Acctmast->clntcode
                else
                   cclnt := Caheader->clntcode
                endif


                @ prow(),180  say trans ( texpose4 := get_unavailed(cclnt,ca_num), '999,999,999.99')

                Caheader->(dbsetorder(indxno))
                Caheader->(dbgoto(xrecno))
                Cadetail->(dbsetorder(indxno2))
                Cadetail->(dbgoto(xrecno2))

                code := Caheader->clntcode

                Acctmast->(dbsetorder(1))
                Acctmast->(dbseek(code))

                cclnt := acctmast->clntcode

                @ prow(),197  say trans ( texpose2 := get_ob(cclnt), '999,999,999.99' )
                @ prow(),214  say trans ( texpose3 := get_guarantee(cclnt), '999,999,999.99' )

//                 txpose := texpose1+texpose2+texpose3+texpose4

                txpose := texpose2+texpose3+texpose4   // abb 3.15.2001

                @ prow(),231  say trans(txpose, '999,999,999.99')
                @ prow(),248  say alltrim(trans(Cadetail->truerate,'999.99'))+ ' %'
                @ prow(),258  say alltrim(str(Cadetail->term)) + ' months'
              else
                Cadetail->(dbskip(+1))
                @ prow()+1,44  say substr(Cadetail->unit,1,30)
                @ prow(),76  say substr(Cadetail->unit2,1,30)
                flaging:=1
              endif

           else       // this else is for the offering ticket

              Oticket->(dbsetorder(2))
              Oticket->(dbgotop())
              Oticket->(dbseek(ca_num))

              @ prow()+1,1 say 'OT '+ Oticket->otnumber

              Client->(dbseek(Oticket->clntcode))

              @ prow(),10 say substr(Client->fullname,1,30)
              @ prow(),44 say iif ( OTICKET->UNIT<>space(40),;
                                     substr(Oticket->unit,1,30)   + '  ' + substr(Oticket->unit2,1,30),;
                                     substr(Oticket->secure1,1,30)+ '  ' + substr(Oticket->secure2,1,30) ;
                                   )

              @ prow(),109 say substr(Client->collect,1,25)

              if client->address2 == ' '
                 @ prow(),136 say substr(client->address3,1,25)
              else
                 @ prow(),136 say substr(client->address2,1,25)
              endif

              xrecno := Oticket->(recno())
              indxno := Oticket->(indexord())

              @ prow(),163 say trans(texpose1:=Oticket->credamt,'999,999,999.99')

              code  := oticket->clntcode

              Acctmast->( dbsetorder(1) )
              if Acctmast->(dbseek(code))
                 cclnt := acctmast->clntcode
              else
                 cclnt := Oticket->clntcode
              endif

              @ prow(),180  say trans( texpose4 := get_unavailed(cclnt,ca_num), '999,999,999.99')

              Oticket->(dbgotop())
              Oticket->(dbsetorder(indxno))
              Oticket->(dbgoto(xrecno))

              @ prow(),197  say trans ( texpose2 := get_ob(cclnt), '999,999,999.99')
              @ prow(),214  say trans ( texpose3 := get_guarantee(cclnt), '999,999,999.99')

***              txpose:=texpose1+texpose2+texpose3+texpose4

              txpose := texpose2+texpose3+texpose4    // abb 3.15.2001

              @ prow(),231  say trans(txpose, '999,999,999.99')
              @ prow(),248  say alltrim(trans(Oticket->truerate,'999.99'))+ ' %'
              @ prow(),258  say alltrim(str(Oticket->term)) + ' months'
           endif

           if flaging == 0
              ttx1    += texpose1
              ttx2    += texpose2
              ttx3    += texpose3
              ttx4    += texpose4
              ttxpose += txpose
           else
              flaging := 0
           endif

           ca_num3 := ca_num
           &amstemp->(dbskip(+1))
      enddo

      @ prow()+1, 163  say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
      @ prow(),   180  say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
      @ prow(),   197  say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
      @ prow(),   214  say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
      @ prow(),   231  say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'

      @ prow()+1 , 1  say 'Sub Total'
      @ prow(), 163  say trans(ttx1, '999,999,999.99')
      @ prow(), 180  say trans(ttx4, '999,999,999.99')
      @ prow(), 197  say trans(ttx2, '999,999,999.99')
      @ prow(), 214  say trans(ttx3, '999,999,999.99')
      @ prow(), 231  say trans(ttxpose, '999,999,999.99')

      gttx1    += ttx1
      gttx2    += ttx2
      gttx3    += ttx3
      gttx4    += ttx4
      gttxpose += ttxpose

      ttx1    := 0
      ttx2    := 0
      ttx3    := 0
      ttx4    := 0
      ttxpose := 0

      &amstemp->(dbskip(-1))
      &amstemp->(dbskip())

   Enddo

   @ prow()+2, 163  say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   @ prow(),   180  say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   @ prow(),   197  say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   @ prow(),   214  say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   @ prow(),   231  say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'

   @ prow()+1 , 1  say 'Total'
   @ prow(), 163  say trans(gttx1, '999,999,999.99')
   @ prow(), 180  say trans(gttx4, '999,999,999.99')
   @ prow(), 197  say trans(gttx2, '999,999,999.99')
   @ prow(), 214  say trans(gttx3, '999,999,999.99')
   @ prow(), 231  say trans(gttxpose, '999,999,999.99')

   __eject()

return

****************************************
*
static function get_prinamt(ca_num)
****************************************
 local printamt:=0,ca_num2:=' '

dbselectarea('Cadetail')
Cadetail->(dbgotop())
Cadetail->(dbsetorder(1))
Cadetail->(dbseek(ca_num))
ca_num2:=cadetail->canumber
Do while Ca_num = ca_num2
   if Cadetail->include == .T.
      printamt+=cadetail->principal
   endif
Cadetail->(dbskip())
ca_num2:=cadetail->canumber
Enddo
return(printamt)

************************************
*
static function get_ob(cclnt)
************************************
   local tbalance:=0,balance2:=' '
   dbselectarea('acctmast')
   Acctmast->(dbgotop())
   Acctmast->(dbsetorder(1))
   Acctmast->(dbseek(cclnt))

   cclnt2 := Acctmast->clntcode
   Do while cclnt == cclnt2 .and. !Acctmast->(eof())

      if empty(cclnt)                //  == ' '
         exit
      endif

**********      tbalance += Acctmast->osbal

      tbalance += _get_outs()

      Acctmast->(dbskip(+1))
      cclnt2  := Acctmast->clntcode

   Enddo

return(tbalance)

****************************************
*
static function get_guarantee(cclnt)
****************************************
  local tgrnte:=0, cl_codes:={}

  dbselectarea ( 'grpmembr' )

  grpmembr-> ( dbgotop() )
  grpmembr-> ( dbsetorder(1) )    // seek the client code
  grpmembr-> ( dbseek(cclnt) )

  g_code := grpmembr->grupcode

  // grpmembr-> ( browse() )

  grpmembr->( dbgotop() )
  grpmembr->( dbsetorder(2)  )   // seek the grupcode
  grpmembr->( dbseek(g_code) )

  Do while g_code == grpmembr->grupcode .and. ;
           grpmembr->(!eof())
     aadd ( cl_codes,grpmembr->clntcode )
     grpmembr->(dbskip(+1))
  enddo

  dbselectarea('acctmast')

  Acctmast->(dbsetorder(1))
  For i:=1 to len(cl_codes)
      coding := cl_codes[i]
      Acctmast->(dbseek(coding))
      Do while coding == Acctmast->clntcode .and. ;
               Acctmast->(!eof())           .and. ;
               coding <> cclnt
**************
**************         tgrnte += Acctmast->osbal
**************
         tgrnte += _get_outs()              // abb 3.16.2001

         Acctmast->(dbskip(+1))
      Enddo
  Next
return(tgrnte)      

********************************************
*
static function get_unavailed(cclnt,ca_num)
********************************************
  local tgrnte    := 0 , unavld_codes := {}
  local c_line    := 0 , c_availed    := 0,;
        o_crdamnt := 0 , o_availed    := 0,;
        t_unavld2 := 0 , t_unavld1    := 0

  dbselectarea ( 'grpmembr' )

  grpmembr-> ( dbgotop() )
  grpmembr-> ( dbsetorder(1) )    // seek the client code
  grpmembr-> ( dbseek(cclnt) )

  g_code := grpmembr->grupcode

  grpmembr-> ( dbgotop () )
  grpmembr-> ( dbsetorder (2) )   // seek the grupcode
  grpmembr-> ( dbseek  (g_code) )

  Do while g_code == grpmembr->grupcode .and. grpmembr->(!eof())
     aadd      ( unavld_codes,grpmembr->clntcode )
     grpmembr->( dbskip(+1) )
  Enddo

  dbselectarea('Caheader')
  Caheader->(dbsetorder(2))

  if len(unavld_codes) <> 0

     for i:=1 to len(unavld_codes)

       coding := unavld_codes[i]
       Caheader->(dbseek(coding))

         do while coding == Caheader->clntcode .and. Caheader->(!eof())
**
**            if Caheader->actaken == '3' .and. cclnt <> coding
**
            if Caheader->actaken == '3'   // abb 3.15.2001
               c_line    += Caheader->caline
               c_availed += Caheader->availed
            endif
            Caheader->(dbskip(+1))
         enddo

     next

     t_unavld1 := c_line-c_availed

  else                                // means no group inclusion abb 3.14.2001

     caheader->(dbseek(cclnt))
     ot_clnt := caheader->clntcode
     ca_no   := caheader->canumber
     Do while ot_clnt == caheader->clntcode .and. caheader->(!eof())

**********        if caheader->actaken == '3' .and. ca_no <> ca_num

        if caheader->actaken == '3'       // abb 3.15.2001
           c_line    += Caheader->caline
           c_availed += Caheader->availed
        endif
        caheader->(dbskip(+1))
        ca_no := caheader->canumber


     Enddo
     t_unavld1 := c_line-c_availed

  endif
     
  dbselectarea('Oticket')
  oticket->(dbsetorder(1))

  if len(unavld_codes) <> 0

      For i:=1 to len(unavld_codes)
          coding  := unavld_codes[i]
          oticket->(dbseek(coding))
          ot_clnt := oticket->clntcode

          Do while coding == oticket->clntcode .and. oticket->(!eof())

*********             if oticket->actaken == '3'.and. coding <> cclnt

             if oticket->actaken == '3'         // abb 3.15.2001
                o_crdamnt += oticket->credamt
                o_availed += oticket->crdavail
             endif

             oticket->(dbskip(+1))

          Enddo
      Next

      t_unavld2 := o_crdamnt-o_availed

   else                            // means no group inclusion abb 3.14.2001

      Oticket->(dbseek(cclnt))
      ot_clnt := oticket->clntcode
      ot_no   := oticket->otnumber

      Do while ot_clnt == oticket->clntcode .and. oticket->(!eof())

***         if oticket->actaken == '3' .and. ot_no <> ca_num

         if oticket->actaken == '3'         // abb 3.15.2001
            o_crdamnt += oticket->credamt
            o_availed += oticket->crdavail
         endif

         oticket->(dbskip(+1))
         ca_no := oticket->otnumber

      Enddo

      t_unavld2 := o_crdamnt-o_availed

   endif

   t_unavld := t_unavld1+t_unavld2



return (t_unavld)

************************************************
*
static function _get_total_xpose(c_no,kind)
************************************************
local code

   if kind == 1
      code := Caheader->clntcode
   else
      code := Oticket->clntcode
   endif

   Acctmast-> ( dbsetorder(1) )
   if Acctmast-> ( dbseek(code) )
      cclnt    := acctmast->clntcode
   else

      if kind == 1
         cclnt := Caheader->clntcode
      else
         cclnt := Oticket->clntcode
      endif

   endif   
 
   texpose4 := get_unavailed ( cclnt,c_no )
   texpose2 := get_ob ( cclnt )
   texpose3 := get_guarantee ( cclnt )

   txpose   := texpose2+texpose3+texpose4

return (txpose)

*************************************
*
static function amsr35head()
*************************************
local  mdate := 'For the Month of ' + ;
                { 'January'  ,;
                  'February' ,;
                  'March'    ,;
                  'April'    ,;
                  'May'      ,;
                  'June'     ,;
                  'July'     ,;
                  'August'   ,;
                  'September',;
                  'October'  ,;
                  'November' ,;
                  'December'  ;
                };
                [ mmonth ] +  ;
                ' ' + padr( myear, 4 )
setprc  ( 0,0 )
setfont ( 'DRAFT' )
setfont ( 'ELITE' )
@ prow  ( )+1,03 say 'ACCOUNT MANAGEMENT SYSTEM'
//
// @ prow(),  03+len('ACCOUNT MANAGEMENT SYSTEM');
//               say PADL('Page No. ' + 155-len('ACCOUNT MANAGEMENT SYSTEM'))
//
@ prow  ()+1,03 say 'AMSR3500'
@ prow  ()  ,03+len('AMSR3500');
              say PADL( dtoc(DATE())+' '+TIME(), 155-len('AMSR3500'))

@ prow  ()+1,03 say PADC('ORIX METRO LEASING AND FINANCE CORPORATION',155)

setfont ( 'BOLD' )
@ prow  ()+1,03 say padc('REGISTRY OF APPROVED APPLICATIONS',155)
setfont ( 'UNBOLD' )

@ prow ()+1,03 say padc(mdate, 155)
@ prow ()+1,03 say ''

setfont ('ELITE')
setfont ('CONDENSED')

@ prow ()+1,1 say 'ÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ'
@ prow ()+1,1 say '  CA/OT           ACCOUNT NAME                                         U N I T                                      PRINCIPAL                 LOCATION                CREDIT         UNAVAILED       EXISTING OB        OTHER            TOTAL          TRUE       TERM '
@ prow ()+1,1 say '  NUMBER                                                                                                                                                              AMOUNT           LINE                           GUARANTEES        EXPOSURE        RATE     (MONTHS) '
@ prow ()+1,1 say 'ÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ'

return




/*-------------------------*/
 static function aOpen3500()
/*-------------------------*/
memvar gSYS_NAME, gUSER_ID, gTRANDATE, mFMS0700

if !netuse( '&g_AMS_PATH\Acctmast', .f., 10 )              && Account master file
   break
else
   set index to &g_AMS_PATH\Acctclnt,;
                &g_AMS_PATH\Acctacno
endif

if !netuse( '&g_AMS_PATH\Oticket', .f., 10 )              && Account master file
   break
else
   set index to &g_AMS_PATH\otclnt,;
                &g_AMS_PATH\oticket
endif

if !netuse( '&g_AMS_PATH\Caheader', .f., 10 )              && Account master file
   break
else
   set index to &g_AMS_PATH\caheader,;
                &g_AMS_PATH\caclnt
endif

if !netuse( '&g_AMS_PATH\Cadetail', .f., 10 )              && Account master file
   break
else
   set index to &g_AMS_PATH\cadetail
endif

if !netuse( '&g_AMS_PATH\Amshist', .f., 5 )        && Account Payment history file
   break
else
   set index to &g_AMS_PATH\Amshist                && set index on acctno
endif

if !netuse( '&g_AMS_PATH\AMSBACK\Amshist2', .f., 5 )        && Account Payment history file
   break
else
   set index to &g_AMS_PATH\AMSBACK\Amshist2                && set index on acctno
endif
if !netuse( '&g_AMS_PATH\Comcodes', .f., 10 )              && Account master file
   break
endif

if !netuse( '&g_AMS_PATH\Grpmembr', .f., 10 )              && Account master file
   break
else
   set index to &g_AMS_PATH\grpclnt,;
                &g_AMS_PATH\grpmembr
endif

if !NETUSE('&g_CIS_PATH'+'\CLIENT',.f.,5)   && CLIENT MASTER file
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_CIS_PATH\CLIECD' )                     && set index on clntcode
   ordlistadd( '&g_CIS_PATH\CLIENM' )                     && set index on Fullname
endif
/*
/*------------------------*/
 Static function get_month()
/*------------------------*/
   local mretval := .t., getlist := {}, mcolor := setcolor()
   memvar mmonth, myear
   setcolor( 'n/g,w+/n,,, w+/g' )
   @  8, 31 say 'Transaction Date'                color 'w+/g'
   @  9, 32 say 'Month '
   @ 10, 32 say ' Year '
   @  9, 42 get mmonth pict '99'   when  select_month( @mmonth, 9, 46, 18, 56 )
   @ 10, 41 get myear  pict '9999' valid myear > 1970

   setcursor (2)
   read
   setcursor (0)

   setcolor  (mcolor)

return lastkey() != K_ESC
*/
/*-----------------------------------*/
 STatic Function Headinc(pgn,xdate)
/*-----------------------------------*/




/*
/*------------------------------------*/
 static function select_month ( mmonth )
/*------------------------------------*/
return eval( { | x, y, z | x := setcolor(), y := savescreen( ,,, ),;
                          fshadow( 9, 46, 18, 56, 2, 'w/gr' ),;
                          devpos( 10, 49 ), devout( 'Month', 'bg+/gr' ),;
                          devpos( 11, 46 ) , devout( 'ÃÄÄÄÄÄÄÄÄÄ´', 'w/gr' ),;
                          setcolor( 'w/gr, w+/n,,, n/gr' ),;
                          z := achoice( 12, 47, 17, 55,;
                               { 'January', 'February', 'March', 'April',;
                                 'May', 'June', 'July', 'August', 'September',;
                                 'October', 'November', 'December' },,, mmonth ),;
                          setcolor( x ), restscreen( ,,,, y ), mmonth := if( z == 0, mmonth, z ), .f. } )
*/
/*-------------------------*/
 Static Function crea_Xtemp()
/*-------------------------*/
local mfile
memvar gUSER_ID
while .t.
    mfile:=substr(alltrim(gUSER_ID),1,2)+substr(time(),1,2)+substr(time(),4,2)+substr(time(),7,2)
    if file( mfile + '.DBF' )
       loop
    else
        exit
    endif
enddo
return mfile

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
**********   local prate:=xprate,pdate:= _ddate, xblk
**********   local _ddate := mdate
   local _ddate := mdate

   //aga.20.10.2007.removed not used
   //xblk := { || Paysked->Lastpay <= pdate }

   Amshist->  ( dbseek(Acctmast->Acctno) )
if Amshist->  ( dbseek(Acctmast->Acctno) )

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
endif

   Amshist2->  ( dbseek(Acctmast->Acctno) )

if Amshist2->  ( dbseek(Acctmast->Acctno) )
   ncredamt := Acctmast->Credamt

   do while AMSHIST2->Acctno == Acctmast->Acctno .and. !AMSHIST2->(eof())

         xrefdate  := AMSHIST2->Refdate
         xornum    := AMSHIST2->Ornumber
         xacctno   := AMSHIST2->Acctno
         xcode     := AMSHIST2->Paycode
         unpd_pen  += AMSHIST2->Unpd_pnlty

         do while AMSHIST2->Acctno   == xAcctno  .and. ;
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
endif

return nretval

/************************************

function get_amsr3500()
 local ca_ot_num:=0, max:={}, xrecno:=0, x:=0, linda:= ' '
 local texpose1:=0,texpose2:=0,texpose3:=0,txpose:=0
 local ttx1:=0,ttx2:=0,ttx3:=0,ttx4:=0,ttxpose:=0
 local gttx1:=0,gttx2:=0,gttx3:=0,gttx4:=0,gttxpose:=0,flaging:=0

     dbselectarea ( 'comcodes' )
     Comcodes->(dbgotop())
     do while comcodes->(!eof())
        aadd(max,comcodes->maximum)
        Comcodes->(dbskip(+1))
     enddo


     select cadetail
     go top
     Do while !cadetail->(eof())

        c_no:=cadetail->canumber
        Caheader->(dbseek(c_no))

        if Caheader->actaken        == '3'    .and. ;
           month(Caheader->Actdate) == mmonth .and.;
           year(Caheader->Actdate)  == myear

           t_canumbr:= Cadetail->canumber
           t_actaken:= Caheader->actaken
           t_actdate:= Caheader->actdate

           texpose1:=Caheader->caline
           xrecno3:=Cadetail->(recno())
           indxno3:=cadetail->(indexord())

           xrecno5:=Caheader->(recno())
           indxno5:=caheader->(indexord())

           kind:=1
           totalxpose := _get_total_xpose(t_canumbr,kind)

           Caheader->(dbsetorder(indxno5))
           Caheader->(dbgoto(xrecno5))
           Cadetail->(dbsetorder(indxno3))
           Cadetail->(dbgoto(xrecno3))

           dbselectarea('&amstemp')
           append blank
           replace number  with 'CA' + t_canumbr
           replace actaken with t_actaken
           replace actdate with t_actdate

           amount:=totalxpose+texpose1

           do case
              case amount <= max[1]
                 replace flag with '1'
              case amount > max[1] .and. amount <= max[2]
                 replace flag with '2'
              case amount > max[2] .and. amount <= max[3]
                 replace flag with '3'
              case amount > max[3] .and. amount <= max[4]
                 replace flag with '4'
              otherwise
                 replace flag with '5'
           endcase

        endif

        cadetail->(dbskip(+1))

     Enddo

     select Oticket
     go top

     Do while !Oticket->(eof())

        if Oticket->actaken          == '3'    .and. ;
           month(Oticket->Actdate)   == mmonth .and. ;
           year(Oticket->Actdate)    == myear

           t_canumbr := Oticket->otnumber
           t_actaken := Oticket->actaken
           t_actdate := Oticket->actdate
           texpose1  := Oticket->credamt

           xrecno4:=Oticket->(recno())
           indxno4:=Oticket->(indexord())

           kind:=2
           totalxpose:=_get_total_xpose(t_canumbr,kind)

           Oticket->(dbsetorder(indxno4))
           Oticket->(dbgoto(xrecno4))

           dbselectarea('&amstemp')
           append blank
           replace number  with 'TA'+ t_canumbr
           replace actaken with t_actaken
           replace actdate with t_actdate
           amount:=totalxpose+texpose1

           do case
              case amount <= max[1]
                 replace flag with '1'
              case amount > max[1] .and. amount <= max[2]
                 replace flag with '2'
              case amount > max[2] .and. amount <= max[3]
                 replace flag with '3'
              case amount > max[3] .and. amount <= max[4]
                 replace flag with '4'
              otherwise
                 replace flag with '5'
           endcase

        endif

        Oticket->(dbskip(+1))

     Enddo

     dbselectarea ( '&amstemp' )
     index on flag+number to &amstemp
     &amstemp->(dbgotop())

     ca_num2 := ' '
     ca_num3 := ' '
     ctr     := 1

     amsr35head()
     Do while &amstemp->(!eof())

        if prow() > 33 
           __eject()
           amsr35head()
        endif
        x++
        xflag:=alltrim(str(x))

        do case
           case x == 1
                linda:='SUB-CREDIT COMMITTEE I'
           case x == 2
                linda:='SUB-CREDIT COMMITTEE II'
           case x == 3
                linda:='CREDIT COMMITTEE'
           case x == 4
                linda:='EXECUTIVE COMMITTEE'
           case x == 5
                linda:='BOARD OF DIRECTORS'
        endcase

        @ prow()+1, 1 say ' '
        @ prow()+1, 1 say linda
        @ prow()+1, 1 say ' '

        Do while alltrim(&amstemp->flag) == xflag .and. &amstemp->(!eof())
           ca_num:=substr(&amstemp->number,3,5)
           if substr(&amstemp->number,1,2) = 'CA'
              Cadetail->(dbseek(ca_num))
              if ca_num <> ca_num3
                 @ prow()+1,1 say 'CA ' + Cadetail->canumber
                 caheader->(dbsetorder(1))
                 Caheader->(dbseek(ca_num))
                 clcode:=Caheader->clntcode
                 Client->(dbseek(clcode))
                 @ prow(),10  say substr(Client->fullname,1,30)
                 @ prow(),44  say substr(Cadetail->unit,1,30) + '  '+ substr(Cadetail->unit2,1,30)
                 @ prow(),109 say substr(Client->collect,1,25)
                if client->address2 == ' '
                   @ prow(),136 say substr(client->address3,1,25)
                else
                   @ prow(),136 say substr(client->address2,1,25)
                endif

                xrecno  := Caheader->(recno())
                indxno  := Caheader->(indexord())
                xrecno2 := Cadetail->(recno())
                indxno2 := Cadetail->(indexord())

                @ prow(),163 say trans(texpose1:=Caheader->caline,'999,999,999.99')
                code:=Caheader->clntcode
                Acctmast->(dbsetorder(1))
                Acctmast->(dbseek(code))
                cclnt := acctmast->clntcode

                @ prow(),180  say trans(texpose4:=get_unavailed(cclnt,ca_num), '999,999,999.99')

                Caheader->(dbsetorder(indxno))
                Caheader->(dbgoto(xrecno))
                Cadetail->(dbsetorder(indxno2))
                Cadetail->(dbgoto(xrecno2))
                code:=Caheader->clntcode
                Acctmast->(dbsetorder(1))
                Acctmast->(dbseek(code))

                cclnt := acctmast->clntcode

                @ prow(),197  say trans ( texpose2 := get_ob(cclnt), '999,999,999.99' )
                @ prow(),214  say trans ( texpose3 := get_guarantee(cclnt), '999,999,999.99' )

                txpose := texpose1+texpose2+texpose3+texpose4

                @ prow(),231  say trans(txpose, '999,999,999.99')
                @ prow(),248  say alltrim(trans(Cadetail->truerate,'999.99'))+ ' %'
                @ prow(),258  say alltrim(str(Cadetail->term)) + ' months'
              else
                Cadetail->(dbskip())
                @ prow()+1,44  say substr(Cadetail->unit,1,30)
                @ prow(),76  say substr(Cadetail->unit2,1,30)
                flaging:=1
              endif
           else       // this else is for the offering ticket

              Oticket->(dbsetorder(2))
              Oticket->(dbgotop())
              Oticket->(dbseek(ca_num))
              @ prow()+1,1 say 'OT '+ Oticket->otnumber
              Client->(dbseek(Oticket->clntcode))
              @ prow(),10 say   substr(Client->fullname,1,30)
              @ prow(),44 say  iif(OTICKET->UNIT<>space(40),substr(Oticket->unit,1,30)+ '  '+ substr(Oticket->unit2,1,30),substr(Oticket->secure1,1,30)+ '  '+ substr(Oticket->secure2,1,30))
              @ prow(),109 say substr(Client->collect,1,25)

              if client->address2 == ' '
                 @ prow(),136 say substr(client->address3,1,25)
              else
                 @ prow(),136 say substr(client->address2,1,25)
              endif

              xrecno:=Oticket->(recno())
              indxno:=Oticket->(indexord())
              @ prow(),163 say trans(texpose1:=Oticket->credamt,'999,999,999.99')

              code:=oticket->clntcode
              Acctmast->(dbsetorder(1))
              Acctmast->(dbseek(code))
              cclnt:=acctmast->clntcode

              @ prow(),180  say trans(texpose4:=get_unavailed(cclnt,ca_num), '999,999,999.99')
              Oticket->(dbgotop())
              Oticket->(dbsetorder(indxno))
              Oticket->(dbgoto(xrecno))
              @ prow(),197  say trans ( texpose2 := get_ob(cclnt), '999,999,999.99')
              @ prow(),214  say trans ( texpose3 := get_guarantee(cclnt), '999,999,999.99')
              txpose:=texpose1+texpose2+texpose3+texpose4
              @ prow(),231  say trans(txpose, '999,999,999.99')
              @ prow(),248  say alltrim(trans(Oticket->truerate,'999.99'))+ ' %'
              @ prow(),258  say alltrim(str(Oticket->term)) + ' months'
           endif
           if flaging = 0
              ttx1+=texpose1;ttx2+=texpose2;ttx3+=texpose3
              ttx4+=texpose4;ttxpose+=txpose
           else
              flaging:=0
           endif
           ca_num3:=ca_num
           &amstemp->(dbskip())
      enddo

      @ prow()+1, 163  say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
      @ prow(),   180  say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
      @ prow(),   197  say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
      @ prow(),   214  say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
      @ prow(),   231  say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'

      @ prow()+1 , 1  say 'Sub Total'
      @ prow(), 163  say trans(ttx1, '999,999,999.99')
      @ prow(), 180  say trans(ttx4, '999,999,999.99')
      @ prow(), 197  say trans(ttx2, '999,999,999.99')
      @ prow(), 214  say trans(ttx3, '999,999,999.99')
      @ prow(), 231  say trans(ttxpose, '999,999,999.99')

      gttx1    += ttx1
      gttx2    += ttx2
      gttx3    += ttx3
      gttx4    += ttx4
      gttxpose += ttxpose

      ttx1    := 0
      ttx2    := 0
      ttx3    := 0
      ttx4    := 0
      ttxpose := 0

      &amstemp->(dbskip(-1))
      &amstemp->(dbskip())

   Enddo

   @ prow()+2, 163  say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   @ prow(),   180  say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   @ prow(),   197  say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   @ prow(),   214  say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   @ prow(),   231  say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'

   @ prow()+1 , 1  say 'Total'
   @ prow(), 163  say trans(gttx1, '999,999,999.99')
   @ prow(), 180  say trans(gttx4, '999,999,999.99')
   @ prow(), 197  say trans(gttx2, '999,999,999.99')
   @ prow(), 214  say trans(gttx3, '999,999,999.99')
   @ prow(), 231  say trans(gttxpose, '999,999,999.99')

   __eject()
return
************************************/


