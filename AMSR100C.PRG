/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   program idúúú amsr0100                                                   Ã¿
³   descriptionúú Account Payment History                                    ³Ã¿
³   authorúúúúúúú renan s. evangelista                                       ³³³
³   dateúúúúúúúúú 9:20:am úú 08-12-96                                        ³³³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´³³
³                             u p d a t e s                                  ³³³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´³³
³        who        ³     when      ³                why                     ³³³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´³³
³                   ³               ³                                        ³³³
³ Janet B. Salvador ³  01-Mar-1999  ³ incorrect review interpretation        ³³³
³ abb               ³  07-Nov-2001  ³ ropoa-active                           ³³³
³ abb               ³  07.28.2004   ³ hide truerate,net2close,eff.rate       ³³³
³                   ³               ³ for client's use                       ³³³
³ Red K. Guyala     ³  04-Oct-2004  ³ change acct no. format from            ³³³
³                   ³               ³  * 5 digits seeking to 14              ³³³
³                   ³               ³  * 9999-9999-9999 to 99-9999999999     ³³³
³                   ³               ³  * Acctsub2 index file to Acctmast     ³³³
³ mts               ³  29-Dec-2006  ³  Added AMSHIST2			     ³³³
³ aga               ³  14.02.2007   ³  neo paysked support for modules       ³³³
ÀÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ³³
 ÀÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

////

#include 'inkey.ch'
#include 'colf.ch'
#include 'dbstruct.ch'

////
#defi K_SPACEBAR   32
#defi microfeed    chr( 27 ) + 'J' + chr( 18 )
////
#xtran gettermunit   ( <cnum> ) => if( <cnum> == '1  ', 'Day(s)', 'Month(s)' )
#xtran getpayfreq    ( <cnum> ) => if( <cnum> == '1'  , 'Monthly',;
                                   if( <cnum> == '2'  , 'Bi-Monthly',;
                                   if( <cnum> == '3'  , 'Quarterly',;
                                   if( <cnum> == '4'  , 'Semi-Annual',;
                                   if( <cnum> == '5'  , 'Annual',;
                                   if( <cnum> == '6'  , 'Lumpsum', 'Irregular' ) ) ) ) ) )


memvar  AX_LEVEL, gUSER_ID
setcursor(0)
setblink(.t.)
if !chkpass( procname(), AX_LEVEL, gUSER_ID )
   //NOTHING WILL HAPPEN
else
   begin sequence
	 aOpenhist()
         aMainhist()
   end sequence
   dbcloseall()
endif
__mrelease( '*', .t. )
return nil

*****
*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  Static Function  aMainhist()
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 local mu       := savescreen(,,,), gf := savedbf(), bf := setcolor()
 local nacct    := SPACE(08)     && RED 100404 spac(5)
 LOCAL GETLIST  := {}
 private xprate := g_PENRATE * 100,nprefby:=spac(40),nNotedby :=spac(40)     // EVR 01082007 - changed from Parametr->PENRATE
 private cCLIENTCD := space(10)

 FSHADOW(09,13,13,64,2,'n/w')               && RED 100404 fshadow(09,13,12,45,2,'n/w')
 setcolor('n/w,w/n,,,w+/w' )
 setcursor(1)
 while lastkey() <> K_ESC  .and. .t.
     @ 10,15 say 'Account N§ to Print  ' ;
                  get nacct PICT '@R 999-99999';       && RED 041805 PICT '@R 999-9999-99999-99999' ;      && RED 100404 pict '99999' ;
                  VALID IF( !EMPTY(nACCT),;
                           IF( VALBRCODE(LEFT(nACCT,3),g_USER_ID),;
                               nCHKACCT(@nACCT),;
                               EVAL({|| nACCT := SPACE(08), .F.}) ),;                && RED 041805 SPACE(17)
                           EVAL( { || nACCT := GET_HACCT(),;
                                      IF(EMPTY(nACCT),.F.,;
                                         IF(VALBRCODE(LEFT(nACCT,3),g_USER_ID) ,;
                                            EVAL({|| ACCTNAME(nACCT,11,38,25), nCHKACCT(@nACCT) }),;
                                            EVAL({|| nACCT := SPACE(08), .F.});      && RED 041805 SPACE(17)
                                        ));
                               } ) )

                  /*when eval( { || nacct:= get_Hacct(), ACCTNAME(nACCT,11,38,25), .t. } ) ;
                  valid lastkey() == K_UP .or. nchkAcct(@nAcct)*/

     @ 11,15 SAY 'Account Name         '    && RED 100704
     @ 12,15 say 'Penalty  Rate        ' get xprate Pict '99'    && RED 100704 - @ 11,15 say
                                          
     setkey( K_ESC,{ || Fescape('Abort?') } )
     read
     setkey( K_ESC,nil )
     if lastkey() == K_ENTER .or. lastkey() == K_ESC
        xprate := if ( xprate > 0,;
                       xprate/100,;
                       xprate ;
                     )
        exit
     endif
 enddo
 setcolor(bf)
 setcursor(0)
 if lastkey() <> K_ESC
    if chksignee()
       reportprint('__Prnhist01()','Legal size of Paper' )
       *repcon_ol('__Prnhist01()','Legal size of Paper',,,,,,.F. )
    endif
 endif
 restscreen(,,,,mu)
 restdbf(gf)
 return nil
/*-------------------------------*/
 Static Function get_Hacct()
/*-------------------------------*/
local nretval:=spac(16),mu:=savedbf()    && RED 100404   spac(5)
local ax_:=SPACE(10), az_, axx_, xSet:=setkey( K_ESC )
local scr_ := savescreen( ,,,, ),colr_:=setcolor(), cbrcode := g_PAR_BRCH
LOCAL nRECNO := 0

MEMVAR GETLIST
SETKEY( K_ESC, NIL )

nRECNO := _GETCLWIN(AX_,2,CLIENT->(INDEXORD()))

IF nRECNO = 0 .AND. LASTKEY() == K_ENTER
   setkey(K_ESC, nil )
   dbselectarea('Client')
   ax_ := flook_ONLINE( .t.,'Client',nil,'Client Master File',3,45,1,4,1,,,,,,.T. )

   IF LASTKEY() == K_ENTER
      nRECNO := CLIENT->(RECNO())
   ENDIF
ENDIF

IF LASTKEY() != K_ESC
   CLIENT->(DBGOTO(nRECNO))

   AX_ := CLIENT->BRCODE+CLIENT->CLNTCODE
   cCLIENTCD := Client->brcode+Client->clntcode          && PEPE 10.17.2007

   if lastkey() == K_ESC
      restdbf(mu)
      setkey( K_ESC, xSet )
      restscreen(,,,, scr_ )
      setcolor( colr_ )
      return SPACE(16)     && RED 100404 spac(5)
   elseif nRECNO > 0 .AND. ;
          IF( EMPTY(AX_) ,.F., VALBRCODE( LEFT( AX_,3), g_USER_ID) ) .AND. ;
          !empty( axx_ := checkacctmas( ax_ ) )

          setcolor('w/gr,n/w,,,w/gr')
          fShadow( 10,30,20,50+20, 2 ,'w/gr' )
          @ 11,31 say padc('Account Number | Old Acct. No.',19+20 ) color 'w+/bg'
          @ 12,31 say repl('Ä',19+20 ) color 'w/gr'

      do while .t.
   *********      az_ := achoice( 13,33,19,48,axx_,,'fstatudf', 1 ,1 )
         az_ := achoice ( 13,35-4,19,48+20,axx_,,'fstatudf', 1 ,1 )

         if lastkey() == K_ESC
            nretval:=SPACE(16)      && RED 100404 spac(5)
            exit
         elseif lastkey() <> K_LEFT .and. lastkey() <> K_RIGHT
   ******         nretval := substr(axx_[ az_ ],-5,5 )
            *---> RED 100404
            *nretval := substr(axx_[ az_ ],12,6 )   // 9999-99999-99999
                                                   // 1234567890123456
            nRETVAL := LEFT(AXX_[AZ_],3)+SUBSTR(AXX_[ AZ_ ],5,4 )+SUBSTR(AXX_[ AZ_ ],10,5 )+SUBSTR(AXX_[ AZ_ ],16,5 )

            exit
         endif
      enddo
   endif
ENDIF

setkey( K_ESC, xSet )
restscreen(,,,, scr_ )
setcolor( colr_ )
restdbf(mu)
return nretval
/*--------------------------------*/
 Static Function Checkacctmast(ax_)
/*--------------------------------*/
local nretval,axz_:={},mu:=savedbf()
local mi:=Acctmast->(Indexord())
dbselectarea('Acctmast')

dbsetorder(2)

if dbseek(ax_)
   waiton('Checking Account Master file...',,'n*/w')
   *---> RED 100404
   *dbeval( { || aadd(axz_, Trans( Acctmast->Acctno,'@R 9999-99999-99999' )+' | '+alltrim(acctmast->oldno) ) },, ;
   dbeval( { || aadd(axz_, Trans( ACCTMAST->BRCODE+Acctmast->Acctno,'@R 999-9999-99999-99999' )+' | '+alltrim(acctmast->oldno) ) },, ;
           { || ACCTMAST->BRCODE+Acctmast->Clntcode == ax_  } )
  waitoff()
endif

Acctmast->(dbsetorder(mi))
restdbf(mu)
return axz_
/////
static Function fstatudf( nmode, ne1, nrow )
local kk:=lastkey(),nretval
do case
   case nmode == AC_HITTOP
        Tone(600,5)
        NRETVAL :=  2
   case nmode == AC_IDLE
        NRETVAL :=  2
   CASE nmode == AC_HITBOTTOM
        tone(700,6)
        NRETVAL :=  2
   case kk == K_ENTER
        nretval := 1
   case kk == K_ESC
        nretval := 0
otherwise
   nretval := 2
endcase
return nretval
//aga.13.05.2005.new and improved chksignee()...yay!
*******************************
static function chksignee()
*******************************
memvar nprefby, nnotedby
local  getlist := {}, ax := setcolor()

private entryname [2]
entryname [1] := entryname [2] := space(40)

fshadow ( 12, 18, 15, 65, 2, 'n/w')
setcolor( 'bg+/w, w+/n,,, gr+/w' ) 

@ 13, 19 say ' Prepared By   ' gget entryname[1] picture '@xs28'            ;
         when lastkey() != K_ESC valid !empty( nprefby := get_initial(entryname[1], 1, 12, 36, 28 ) )
@ 14, 19 say ' Noted By      ' gget entryname[2] picture '@xS28'            ;
         when lastkey() != K_ESC valid !empty( nNotedby := get_initial(entryname[2], 2, 12, 36, 28 ) )

setcursor ( 3 )
read   
setcursor ( 0 )
setcolor  ( ax )

return( lastkey()!=K_ESC )
//.........................................

///*----------------------------*/
//Static Function chksignee()
///*----------------------------*/
// local mu:=setcolor(),nretval := .f.
//
// fshadow(12,18,15,65,2,'w+/w')
// setcolor('n/w,w+/n,,,w+/w')
// setcursor(1)
// while   .t.
//   @ 13, 19 say ' Prepared By   ' get nprefby  pict '@!XS25' ;
//                                 when eval( { || !empty(nPrefby := flook_ONLINE(.t.,'Personel',,'Personnel File',,,,2 ) ),.f. } ) ;
//                                 valid !empty(nPrefby)
//   @ 14, 19 say ' Noted By      ' get nNotedby pict '@!XS25' ;
//                                 when lastkey() <> K_ESC .and. !empty(nNotedby := eval( { || flook_ONLINE(.t.,'Personel',,'Personnel File',,,,2 ) } ) ) ;
//                                 valid !empty(nNotedby)
//   setkey(K_ESC, { || Fescape('Abort? ') } )
//   read
//   if lastkey() == K_ESC .or. Lastkey() == K_ENTER
//      exit
//   endif
// enddo
// setkey(K_ESC,Nil )
// if lastkey() <> K_ESC
//    nretval := .t.
// endif
// setcolor(mu)
// setcursor(0)
// return nretval

/*----------------------------*/
 Static Function nchkAcct(nacct)
/*----------------------------*/
 local mu:= savedbf(),nretval:=.f.
 * nACCT := LEFT(nACCT,4)+SUBSTR(nACCT,6,5)+RIGHT(nACCT,5)   && RED 100404   nacct := substr( '00000'+ alltrim(nacct),-5,5 )
 nACCT := LEFT(nACCT,3) + PADL(ALLTRIM(RIGHT(nACCT,5)),5,'0')     && RED 041805

 dbselectarea('Acctmast')
 dbsetorder(1)

 if Acctmast->(dbseek( nacct ))
    DISPNAME(11,38,25)              && RED 100704
    if Amshist2->(dbseek( ACCTMAST->BRCODE+Acctmast->Acctno ) )
       nretval:=.t.

    elseif Amshist->(dbseek( ACCTMAST->BRCODE+Acctmast->Acctno ) )
       nretval:=.t.

    else
       error('No payment yet!')
    endif
 else
    error('No such account!')
    CLRNAME(11,38,25)               && RED 100704
 endif

 *nACCT := LEFT(nACCT,3)+SUBSTR(nACCT,5,4)+SUBSTR(nACCT,11,5)+RIGHT(nACCT,5)  && RED 100404

 return nretval

*****************************
*
Function __Prnhist01()
*****************************
// local pgn:=1,xdate:=Cmonth( Flag->Prevdate )+' '+str(Day( Flag->Prevdate ),2)+', '+str(year(Flag->Prevdate ),4)
 local pgn:=1,xdate:=Cmonth( Flag->lastclosed )+' '+str(Day( Flag->lastclosed),2)+', '+str(year(Flag->lastclosed),4)

 local tot_amrt := 0, tot_pen := 0, npent_s := 0,ncredamt:= Acctmast->Credamt
 local nctr     := 0
 local Pay_:={ 'Payment',;            // 1
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
               'Balance Forwarded',;  // 16
               'Sold' ,;              // 17   abb 8.30.2001
               'ROPOA-Current' ;      // 18   abb 8.30.2001
            }
 local tot_or:=0, tot_am := 0, tot_penal := 0
 local xoramount := xamort := xpenal:=0,pprd:={},pperiod,unpd_pen := 0
 local xacctno,xornum,xrefdate,xcode,nrow:= { 05,19,32,43,60,86,93,117 }
 local prate:=xprate,pdate:= gTrandate, xblk

//aga.08.06.2006.marked for modification
// xblk := { || Paysked->Lastpay <= pdate }

 Headhist01 ( pgn,xdate )
 Headhist02 ()
 Head_det   ()


 Amshist2->  ( dbseek(ACCTMAST->BRCODE+Acctmast->Acctno) )

IF Amshist2->  ( dbseek(ACCTMAST->BRCODE+Acctmast->Acctno) )
 ncredamt := Acctmast->Credamt

 do while AMSHIST2->BRCODE+AMSHIST2->Acctno == ACCTMAST->BRCODE+Acctmast->Acctno .and. !AMSHIST2->(eof())

       if prow() > 60
          __eject    ()
          pgn++
          setfont    ('UNCONDENSD')
          Headhist01 (pgn,xdate)
          Head_det   ()
       endif

       xrefdate := AMSHIST2->Refdate
       xornum   := AMSHIST2->Ornumber
       xacctno  := AMSHIST2->Acctno
       xcode    := AMSHIST2->Paycode
       unpd_pen += AMSHIST2->Unpd_pnlty

       do while AMSHIST2->Acctno   == xAcctno  .and. ;
                AMSHIST2->Ornumber == xornum   .and. ;
                AMSHIST2->Refdate  == xrefdate .and. ;
                AMSHIST2->Paycode  == xcode    .and. ;
               !AMSHIST2->(eof())

           xOramount += if ( val( AMSHIST2->Paycode ) < 8,;
                                  AMSHIST2->Oramount,;
                                0  ;
                              )

           xamort    += ( AMSHIST2->Amort )
           xpenal    += ( AMSHIST2->Penalty )

           if !empty( AMSHIST2->Paydate )
              aadd ( pprd,AMSHIST2->Paydate )
           endif

           if nctr == 0
              nctr := 1
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

       if val(xcode) != 16
          if nctr == 1
             @ prow()+1, 05 say Pay_[ 16 ]
*****             @ prow()  ,117 say Tran( nCredamt ,'@( 999,999,999.99' )
             @ prow()  ,103 say Tran( nCredamt ,'@( 999,999,999.99' )
             nctr := 2
          endif    
       else
          nctr := 2
       endif

       @ prow()+1, 05 say Pay_[ val( xcode ) ]

       @ prow()  , 19 + if(xcode == '16',5, 0 ) ;
                      say if( xcode == '16','',Dtoc( xRefdate ) )
       @ prow()  , 32 say if( xcode == '16','',xOrnum )
       @ prow()  , 43 say tran( xOramount,'@( 999,999,999.99')

*********       @ prow()  , 60 say if( xcode == '16',' ',pperiod)

*********       @ prow()  , 86 say trans ( xamort, '@( 999,999,999.99')
*********       @ prow()  ,103 say tran  ( xPenal, '@( 9,999,999.99')
*********       @ prow()  ,117 say Tran  ( (nCredamt -= ( xamort ) ) ,'@( 999,999,999.99' )


       @ prow()  ,  60 say trans ( xamort, '@( 999,999,999.99')
       @ prow()  ,  86 say tran  ( xPenal, '@( 9,999,999.99')
       @ prow()  , 103 say Tran  ( (nCredamt -= ( xamort ) ) ,'@( 999,999,999.99' )

       pprd      := {}
       tot_or    += xOramount
       tot_am    += xamort
       tot_penal += xPenal
       xoramount := xamort := xpenal:=0

 enddo

ELSE
 Amshist->  ( dbseek(ACCTMAST->BRCODE+Acctmast->Acctno) )
 ncredamt := Acctmast->Credamt

 do while AMSHIST->BRCODE+Amshist->Acctno == ACCTMAST->BRCODE+Acctmast->Acctno .and. !Amshist->(eof())

       if prow() > 60
          __eject    ()
          pgn++
          setfont    ('UNCONDENSD')
          Headhist01 (pgn,xdate)
          Head_det   ()
       endif

       xrefdate := Amshist->Refdate
       xornum   := Amshist->Ornumber
       xacctno  := Amshist->Acctno
       xcode    := Amshist->Paycode
       unpd_pen += Amshist->Unpd_pnlty

       do while Amshist->Acctno   == xAcctno  .and. ;
                Amshist->Ornumber == xornum   .and. ;
                Amshist->Refdate  == xrefdate .and. ;
                Amshist->Paycode  == xcode    .and. ;
               !Amshist->(eof())

           xOramount += if ( val( Amshist->Paycode ) < 8,;
                                  Amshist->Oramount,;
                                0  ;
                              )

           xamort    += ( Amshist->Amort )
           xpenal    += ( Amshist->Penalty )

           if !empty( Amshist->Paydate )
              aadd ( pprd,Amshist->Paydate )
           endif

           if nctr == 0
              nctr := 1
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

       if val(xcode) != 16
          if nctr == 1
             @ prow()+1, 05 say Pay_[ 16 ]
*****             @ prow()  ,117 say Tran( nCredamt ,'@( 999,999,999.99' )
             @ prow()  ,103 say Tran( nCredamt ,'@( 999,999,999.99' )
             nctr := 2
          endif    
       else
          nctr := 2
       endif

       @ prow()+1, 05 say Pay_[ val( xcode ) ]

       @ prow()  , 19 + if(xcode == '16',5, 0 ) ;
                      say if( xcode == '16','',Dtoc( xRefdate ) )
       @ prow()  , 32 say if( xcode == '16','',xOrnum )
       @ prow()  , 43 say tran( xOramount,'@( 999,999,999.99')

*********       @ prow()  , 60 say if( xcode == '16',' ',pperiod)

*********       @ prow()  , 86 say trans ( xamort, '@( 999,999,999.99')
*********       @ prow()  ,103 say tran  ( xPenal, '@( 9,999,999.99')
*********       @ prow()  ,117 say Tran  ( (nCredamt -= ( xamort ) ) ,'@( 999,999,999.99' )


       @ prow()  ,  60 say trans ( xamort, '@( 999,999,999.99')
       @ prow()  ,  86 say tran  ( xPenal, '@( 9,999,999.99')
       @ prow()  , 103 say Tran  ( (nCredamt -= ( xamort ) ) ,'@( 999,999,999.99' )

       pprd      := {}
       tot_or    += xOramount
       tot_am    += xamort
       tot_penal += xPenal
       xoramount := xamort := xpenal:=0

 enddo

ENDIF

********* @ prow()+1, 117 say Trans(Acctmast->Osbal,'999,999,999.99' )

 @ prow()+1, 103 say Trans(Acctmast->Osbal,'999,999,999.99' )

 tot_pen := unpd_pen


//aga.08.05.2006.marked for modification
/*
 if Paysked->(dbseek( ACCTMAST->BRCODE+Acctmast->Acctno ) )

    while PAYSKED->BRCODE+Paysked->Acctno == ACCTMAST->BRCODE+Acctmast->Acctno
       if Paysked->Paydate < Flag->lastclosed
          if prow() > 60
                __eject()
                pgn++
                setfont('UNCONDENSD')
                Headhist01(pgn,xdate)
                Head_det()
          endif

          if Paysked->Amtdue >  Acctmast->Amort * .10 .and. Paysked->Paydate  + 5 < Pdate
                npent_s := round( ( ( Paysked->Amtdue ) * prate /30 ) * ( pdate - Paysked->Paydate ), 0 )
          elseif ( pdate - Paysked->Paydate ) > 35
                npent_s := round( ( ( Paysked->Amtdue ) * prate /30 ) * ( pdate - Paysked->Paydate ), 0 )
          endif

          tot_amrt += ( Paysked->Amtdue )
          tot_pen  += ( npent_s )
       endif
       Paysked->(dbskip())
    enddo
 endif
*/


 if Paysked->(dbseek( ACCTMAST->BRCODE+Acctmast->Acctno+'D' ) )  

    while paysked->brcode+paysked->acctno == ACCTMAST->BRCODE+Acctmast->Acctno .and. paysked->status == 'D'

       if Paysked->Paydate < Flag->lastclosed
          if prow() > 60
                __eject()
                pgn++
                setfont('UNCONDENSD')
                Headhist01(pgn,xdate)
                Head_det()
          endif


          if Paysked->Amtdue >  Acctmast->Amort * .10 .and. Paysked->Paydate  + 5 < Pdate
                npent_s := round( ( ( Paysked->Amtdue ) * prate /30 ) * ( pdate - Paysked->Paydate ), 0 )
          elseif ( pdate - Paysked->Paydate ) > 35
                npent_s := round( ( ( Paysked->Amtdue ) * prate /30 ) * ( pdate - Paysked->Paydate ), 0 )
          endif

          tot_amrt += ( Paysked->Amtdue )
          tot_pen  += ( npent_s )
       endif
       Paysked->(dbskip())
    enddo

 endif

//.............................................


 @ prow()+1 ,02 say ''
 @ prow()+1 ,02 say Repl('Ä',132 )
 if Prow() > 52
      __eject()
      pgn++
      Headhist01(pgn,xdate)
 endif

 setfont('PICA')
 setfont('CONDENSED')
/************
 @ prow()+1, 43 say tran( tot_or,'@( 999,999,999.99')
 @ prow()  , 86 say tran( tot_am,'@( 999,999,999.99')
 @ prow()  ,103 say tran( tot_penal,'@( 9,999,999.99')
 @ prow()+1, 43 say repl( 'Í',14)
 @ prow()  , 86 say repl( 'Í',14)
 @ prow()  , 103 say repl( 'Í',12)
 abb 08.11.2004
**************/

 @ prow()+1, 43     say tran( tot_or,'@( 999,999,999.99')
 @ prow()  , 86-26  say tran( tot_am,'@( 999,999,999.99')
 @ prow()  ,103-17  say tran( tot_penal,'@( 9,999,999.99')
 @ prow()+1, 43     say repl( 'Í',14)
 @ prow()  , 86-26  say repl( 'Í',14)
 @ prow()  , 103-17 say repl( 'Í',12)

 setfont('UNCONDENSD')

 if Prow() > if(tot_amrt <> 0 .or.  tot_pen <> 0, 50,52 )
      __eject()
      pgn++
      Headhist01(pgn,xdate)
 endif

 setfont('UNCONDENSD')
 //setfont('NLQ')
 setfont('ELITE')
 if tot_amrt <> 0 .or.  tot_pen <> 0
    @ prow()+1,02 say 'TOTALS : '
    @ pROW()+1,02 SAY ''
    @ prow()+1,02 say '   Total Amortizations Unpaid : '+ tran(tot_amrt,'999,999,999.99')
    @ prow()+1,02 say '   Penalties Unpaid           : '+ Tran(Tot_pen ,'999,999,999.99')
    @ prow()+1,02 say '                                 '+repl('Ä',14)
    @ prow()+1,02 say '   Total Amount Due           : '+tran(Tot_amrt+Tot_pen,'999,999,999.99')
    @ prow()+1,02 say '                                 '+repl('Í',14)
    prnnoted()
 else
    prnnoted()
 endif
 __eject()
 return nil

/*-------------------------*/
 Static Function prnnoted()
/*-------------------------*/

setfont('ELITE')
@ prow()+2,02 say 'Prepared by : '
setfont('PICA')
setfont('CONDENSED')
@ prow()  ,pcol() say repl( '_',40 )

setfont('UNCONDENSD')
setfont('ELITE')
// @ PROW(), 50 SAY 'Noted by : '
@ PROW(), pcol()+10 SAY 'Noted by : '
setfont('PICA')
setfont('CONDENSED')
@ prow()  ,pcol() say repl( '_',40 )
setfont('UNCONDENSD')

setfont('ELITE')
@ prow()+1,02 say '              '
setfont('PICA')
setfont('CONDENSED')
@ PROW(), pcol() say padc(alltrim(nPrefby),40)
setfont('UNCONDENSD')
setfont('ELITE')
// @ PROW(), 50 SAY '           '
@ PROW(), pcol()+10 SAY '           '
setfont('PICA')
setfont('CONDENSED')
@ prow(), pcol() say padc(Alltrim(nNotedby),40)
setfont('NORMAL')
SETFONT('UNCONDENSD')
RETURN NIL

/*------------------------------------*/
 Static Function Headhist01(pgn,xdate)
/*------------------------------------*/

setprc(0,0)
setfont('DRAFT')
setfont('ELITE')
@ prow()+1,02 say 'ACCOUNT MANAGEMENT SYSTEM'
@ prow(),  02+len('ACCOUNT MANAGEMENT SYSTEM');
              say PADL('Page No. ' + tran(pgn,'999'),94-len('ACCOUNT MANAGEMENT SYSTEM'))
@ prow()+1,02 say 'AMSR0100'
@ prow()  ,02+len('AMSQ9999');
              say PADL( dtoc(DATE())+' '+TIME(), 94-len('AMSQ1000'))
@ prow()+1,02 say PADC('ORIX METRO Leasing and Finance Corporation',94)
setfont('BOLD')
@ prow()+1,02 say padc('ACCOUNT PAYMENT HISTORY',94)
setfont('UNBOLD')
@ prow()+1,02 say padc('As of '+ xdate,94)
@ prow()+1,02 say ''
return nil

/*--------------------------*/
 Static Function Headhist02()
/*---------------------------*/
local lcol := 58
local cacctstr
//setfont('NLQ')
//setfont('PICA')

@ prow()+1,02 say 'Account Number  : ' + tran(ACCTMAST->BRCODE+Acctmast->Acctno,'@R 999-9999-99999-99999')+' / '+alltrim(Acctmast->oldno)

@ prow()+1,02 say 'Account Name    : ' + if (!empty(cCLIENTCD), subs(cCLIENTCD,1,3)+'-'+subs(cCLIENTCD,4,7) +space(2)+ Acctmast->Acctname ,Acctmast->Acctname)   && PEPE added cCLIENTCD 10.17.2007
@ prow()+1,02 say ''

/****** subheading three starts below *******/
Facility->(dbseek(Acctmast->FCLTYCODE))

IF Facility->setcode == '1'
   nGD := Tran( (Acctmast->GD/100) * Acctmast->Principal,'999,999,999.99')
   nRV := Tran( ( Acctmast->Rv/100 ) * Acctmast->Principal, '999,999,999.99' )
else
   nGD := Tran(0,'999,999,999.99')
   nRV := Tran(0,'999,999,999.99')
endif

@ prow()+1,02   say 'Date Booked     : ' + Dtoc(Acctmast->Valdate)
@ prow()  ,lcol say 'Amount Financed  : ' + Tran(Acctmast->Principal,'999,999,999.99')

@ prow()+1,02   say 'First Due Date  : ' + Dtoc( Acctmast->Firstdue )
@ prow()  ,lcol say 'Residual Value   : ' + nRV

@ prow()+1,02   say 'Maturity Date   : ' + dtoc( Acctmast->matdate )
@ prow()  ,lcol say 'Guaranty Deposit : ' + nGD

@ prow()+1,02   say 'Term            : ' + Tran(Acctmast->Term,'999') + ' ' + gettermunit( Acctmast->Termunit )
@ prow()  ,lcol say 'Amortization     : ' + Tran( Acctmast->Amort,'999,999,999.99')

***** @ prow()+1,02   say 'True Rate       : ' + Tran( Acctmast->Truerate,'99.99999' ) +' %'
@ prow()+1,lcol say 'Pay. Frequency   : ' + getpayfreq( Acctmast->Payfreq )

****** @ prow()+1,lcol say 'Net-To-Close     : '+ tran( if( Acctmast->Osbal > 0, nGetnetcls(ACCTMAST->BRCODE+Acctmast->Acctno), 0 ), '999,999,999.99')

@ prow()+1,02 say 'Collateral      : '+ Acctmast->Unit
if !empty(Acctmast->Unit2)
  @ prow()+1,02 say '                  ' + Acctmast->Unit2
endif
@ prow()+1,02 say ''
cacctstr := ACCTMAST->BRCODE+substr( Acctmast->Acctno, -5,5 )

if Review -> ( dbseek ( cacctstr ) )
   @ prow()+1,02 say 'Adjustments     :'
   prntrev( prow() )
   @ prow()+1,02 say ''
endif

// prndthst()
return nil
/*-------------------------*/
 Static Function Head_det()
/*-------------------------*/

//setfont('DRAFT')
setfont('NLQ')
setfont('PICA')
setfont('CONDENSED')

/*
@ prow()+1, 05 say '-----------   -----------  ---------  --------------   -----------------------   -----------------------------  --------------'
@ prow()+1, 05 say 'Type  of      Date  of     Reference   Amount Paid          Period  Paid             PAYMENT APPLICATION          Outstanding '
@ prow()+1, 05 say 'Transaction   Transaction  Number                                                Amortization      Penalties        Balance   '
@ prow()+1, 05 say '-----------   -----------  ---------  --------------   -----------------------   --------------   ------------  --------------'
*/

@ prow()+1, 05 say '-----------   -----------  ---------  --------------   -----------------------------------------  -----------------'
@ prow()+1, 05 say 'Type  of      Date  of     Reference   Amount Paid                PAYMENT APPLICATION                Outstanding'
@ prow()+1, 05 say 'Transaction   Transaction  Number                      Amortization           Penalties              Balance    '
@ prow()+1, 05 say '-----------   -----------  ---------  --------------   --------------   ------------------------  -----------------'



setfont('DRAFT')
return nil
/*
/*-----------------------------------------------------------*/
 Static Function getintamt(nIntamt,nPrnamt,nPaydate,xprate,nPrvdte)
/*-----------------------------------------------------------*/
local nretval:=0,xblk:={ || Paysked->Lastpay <= nPrvdte }

//if( !empty((xtemp)->Lastpay) .and. eval( xblk ),;
//                 (xtemp)->Lastpay, (xtemp)->Paydate )

nretval := ( ( nIntamt + nPrnamt ) * (xprate/30)) * ( nPrvdte - nPaydate )
return nretval
*/
/*---------------------------*/
 Static Function Prntrev(nrow)
/*---------------------------*/

local col1:=22,col2:=44,col3:=66,mu:=savedbf(),nctr:=0
dbselectarea('Review')
if Review->(dbseek(ACCTMAST->BRCODE+Substr( Acctmast->Acctno, -5,5 ) ))

  setfont('NLQ')
  @ prow()   ,25 say 'Effectivity Date'
  @ prow()   ,45 say '  Amortization  '
***** @ prow()   ,64 say '  Effective Rate'
  @ prow()+1,22 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
  @ prow()  ,42 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
***** @ prow()  ,62 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'

  do while REVIEW->BRCODE+Review->Acctno == ACCTMAST->BRCODE+Acctmast->Acctno .and. !Review->(eof())
     @ prow()+1, col1 say tran(++nctr,'99') + '. ' + dtoc( Review->Effdate )
     @ prow()  , col2 say tran( Review->App_amrt,'999,999,999.99')
*****     @ prow()  , col3 say tran( Review->App_tr,'99.9999')
     Review->(dbskip(+1))
  enddo

  setfont('DRAFT')
endif
return nil
/*--------------------------------*/
 Static function nGetnetcls(nacct)
/*-------------------------------*/

 local tot_pen := 0,tot_int:=0,nretval,skedrec:=paysked->(recno()),nrecno:=Acctmast->(recno())
 local gr_deff:= ( ( Acctmast->RV/100 )* Acctmast->Principal) - ((Acctmast->Gd/100) * Acctmast->Principal )
 local nref, mu , ndiff, nyr

 altd()
 ndiff := __make_da_difference( gTrandate, Acctmast->Firstdue, Acctmast->Paytype )
 mu   := ( month( Acctmast->Firstdue) + ndiff ) % 12
 nyr  := int( ( month(Acctmast->Firstdue) + ndiff ) / 12 )
 nref :=  ctod ( str( if( mu < 1 , 12, mu ), 2 ) + '/01/' + str(year(Acctmast->Firstdue)+nyr , 4) )
 //
 Udispred->( dbseek( nAcct + dtos( nref ) ,.t. )  )
 Udispred->( dbeval({|| tot_int += Udispred->Intamt },,;
            {|| UDISPRED->BRCODE+Udispred->Acctno == nAcct } ) )
 //
 /*
 Paysked->(dbseek( nAcct + dtos( nref ) ,.t. ) )
 while Paysked->Acctno == Acctmast->Acctno  
       tot_int += Paysked->Intamt
       Paysked->(dbskip())
 enddo
 */

 nretval := Acctmast->Osbal - tot_int + ( gr_deff )
 Paysked->(dbgoto(skedrec))
 Acctmast->(dbgoto(nrecno))
 return nretval

/*--------------------------*/
 function __make_da_difference( m1, m2 )
/*--------------------------*/
local nval,x1,x2,x3
local y1,y2,y3,a1 := a2 := a3 := 0
m1:= dtos(m1)
m2:= dtos(m2)
x1= val( substr(m1,1,4 ) );x2:=val(substr( m1,5,2 ) ); x3:=val(substr(m1,7,2 ) )
y1= val( substr(m2,1,4 ) );y2:=val(substr( m2,5,2 ) ); y3:=val(substr(m2,7,2 ) )
a1 := if( ( x3 - y3 ) < 0, eval({|| x2--, ( x3 + 30 ) - y3 }), x3 - y3 )
a2 := if( ( x2 - y2 ) < 0, eval({|| x1--, ( x2 + 12 ) - y2 }), x2- y2 )
//if( a2 - 1 < 0, nil, --a2 )
a3 := x1 - y1
nval :=  ( a3 * 12 ) + a2 + if( a1 > 0 , 1, 0 )
return nval

/*-------------------------*/
 Static Function aOpenhist()
/*-------------------------*/

//alert ( '1' )
if !netuse( '&g_AMS_PATH\Acctmast', .f., 10 )              && Account master file
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_AMS_PATH\AcctSub2' )                    && set index on substr( acctno, -5,5 )
   ordlistadd( '&g_AMS_PATH\Acctclnt' )                    && set index on Clientcode
endif

//alert ( '2' )

if !netuse( '&g_Cis_Path\Client', .f., 10 )              && Client Master file
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_Cis_Path\Clienm' )                    && set Client Name
   ORDLISTADD( '&g_CIS_PATH\CLIECD' )                    && set Client Code
endif

//alert ( '3' )
if !netuse( '&g_AMS_PATH\Amshist', .f., 10 )              && Account Payment history file
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_AMS_PATH\Amshist' )                    && set index on acctno
   //ordlistadd( 'Acctclnt' )                 
endif

if !netuse( '&g_AMS_PATH\AMSBACK\Amshist2', .f., 10 )              && Account Payment history file
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_AMS_PATH\AMSBACK\Amshist2' )                    && set index on acctno
   //ordlistadd( 'Acctclnt' )                 
endif

//alert ( '4' )
if !netuse( '&g_AMS_PATH\Paysked', .f., 10 )              && Account Payment schedule file
   break
else
   if !.f.; ordlistclear(); endif
//   ordlistadd( '&g_AMS_PATH\Paysked' )                    && set index on acctno
     set index to &g_AMS_PATH\Paystat      //aga.21.06.2007.new index

   //ordlistadd( 'Acctclnt' )
endif

//alert ( '5' )
if !netuse( '&g_AMS_PATH\Review', .f., 10 )              && Account Review file
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_AMS_PATH\Review1' )                    && set index on acctno
endif

//alert ( '6' )
if !netuse( '&g_AMS_PATH\Udispred', .f., 10 )              && Account Review file
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_AMS_PATH\Udispred' )                    && set index on acctno
   //ordlistadd( 'Acctclnt' )
endif

if !netuse( '&g_AMS_PATH\FACILITY', .f., 10 )              && Account Review file
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_AMS_PATH\FACILITY' )                    && set index on acctno
endif

//alert ( '7' )
if !netuse( '&g_Grf_path\Personel', .f., 10 )   && Account Review file
   break
else
   if !.f.; ordlistclear(); endif
   //ordlistadd( '&g_Grf_path\Personel' )         && set index on acctno
   ordlistadd( '&g_Grf_path\Initials' )         && set index on initials
   //ordlistadd( 'Acctclnt' )
endif

//alert ( '8' )
// EVR if !netuse( 'Parametr', .f., 10 )              && Account Review file
// EVR    break
// EVR endif

//alert ( '9' )
if !netuse( '&g_ams_path\Flag', .f., 10 )              && Account Review file
   break
endif

return nil
/*
123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
         1         2         3         4         5         6         7         8         9         0         1         2
    -----------   ----------   --------   --------------   -----------------------   -----------------------------  --------------
     Type  of     Date Paid    OR N§       Amount Paid          Period  Paid             PAYMENT APPLICATION         Outstanding
    Transaction                                                                      Amortization      Penalties      Balance
    -----------   ----------   --------   --------------   -----------------------   --------------   ------------  --------------
    xxxxxxxxxxx   99/99/9999   99999999   999,999,999.99   99/99/9999 - 99/99/9999   999,999,999.99   9,999,999.99  999,999,999.99
    nrow:= { 55,19,32,43,60,86,93,117 }
*/
*------------------------>
STATIC FUNCTION ACCTNAME(nACCT,nROW,nCOL,nSPC)
LOCAL nNTXORD := ACCTMAST->(INDEXORD())

nACCT   := LEFT(nACCT,4)+SUBSTR(nACCT,6,5)+RIGHT(nACCT,5)

IF LASTKEY() == K_ENTER
   ACCTMAST->(DBSETORDER(1))

   IF ACCTMAST->(DBSEEK(nACCT))
      DISPNAME(nROW,nCOL,nSPC)
   ELSE
      CLRNAME(nROW,nCOL,nSPC)
   ENDIF

   ACCTMAST->(DBSETORDER(nNTXORD))
ELSE
   CLRNAME(nROW,nCOL,nSPC)
ENDIF

RETURN NIL
*------------------------>
STATIC FUNCTION DISPNAME(nROW,nCOL,nSPC)

@ nROW,nCOL SAY LEFT(ACCTMAST->ACCTNAME,nSPC)   COLOR 'W+/W'

RETURN .T.
*------------------------>
STATIC FUNCTION CLRNAME(nROW,nCOL,nSPC)

@ nROW,nCOL SAY SPACE(nSPC)      COLOR 'W+/W'

RETURN .F.
*------------------------>
FUNCTION _GETCLWIN ( mCLNTCODE,nNEWORD,nOLDNTX)
LOCAL nNTX := CLIENT->(INDEXORD()), cCURSOR := SETCURSOR()
LOCAL cCLNTNAME := SPACE(LEN(CLIENT->FULLNAME))
LOCAL nRETVAL   := 0
MEMVAR GETLIST

CLIENT->(DBSETORDER(nNEWORD))
cSCR := SAVESCREEN ( ,,, )

@ 12,15 CLEAR TO 14,55
@ 12,15 TO 14,55
@ 13,16 SAY 'Client Code  ' GET mCLNTCODE PICT '@R 999-99-99999'

SETCURSOR(3)
READ
SETCURSOR(0)

RESTSCREEN ( ,,,,cSCR )

IF LASTKEY() != K_ESC

   IF CLIENT->(DBSEEK(mCLNTCODE))
      nRETVAL := CLIENT->(RECNO())
   ELSEIF !EMPTY(mCLNTCODE)
      ERROR ( 'CLIENT NOT FOUND' )
   ENDIF

ENDIF

CLIENT->  ( DBSETORDER(nOLDNTX) )
SETCURSOR ( cCURSOR)

RETURN nRETVAL
