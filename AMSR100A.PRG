/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³   colf-iis -- account management system                                  ³
 ³   program idúúú amsr100A                                                 ³
 ³   descriptionúú Unearned Discount and Interest                           ³
 ³   authorúúúúúúú renan s. evangelista                                     ³
 ³   dateúúúúúúúúú 9:20:am úú 08-12-96                                      ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³                             u p d a t e s                                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³        who        ³       when        ³               why                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

////
#include 'inkey.ch'
#include 'colf.ch'
#include 'dbstruct.ch'
////
#defi K_SPACEBAR   32
#defi microfeed    chr( 27 ) + 'J' + chr( 18 )
////
#xtran gettermunit   ( <cnum> ) => if( <cnum> == '1'  , 'Day(s)', 'Month(s)' )
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

/*---------------------------*/
 Static Function  aMainhist()
/*---------------------------*/
 local mu:= savescreen(,,,),gf:=savedbf(),bf:=setcolor()
 local nacct:=spac(5)
 private xprate := Parametr->Penrate * 100,nprefby:=spac(40),nNotedby :=spac(40)

 fshadow(09,13,11,45,2,'n/w')
 setcolor('n/w,w/n,,,w+/w' )
 setcursor(1)
 while lastkey() <> K_ESC  .and. .t.
     @ 10,15 say 'Account N§ to Print  ' get nacct pict '99999' when eval( { || nacct:= get_Hacct(), .t. } ) valid lastkey() == K_UP .or. nchkAcct(@nAcct)
     //@ 11,15 say 'Penalty  Rate        ' get xprate Pict '99'
     if lastkey() == K_ESC .or. Lastkey() == K_ENTER
        exit
     endif
     setkey( K_ESC,{ || Fescape('Abort?') } )
     read
     setkey( K_ESC,nil )
 enddo
 setcolor(bf)
 setcursor(0)
 if lastkey() <> K_ESC
    if chksignee()
       *repcontrol('Prnhist02()','Legal size of Paper' )
       repcon_ol('Prnhist02()','Legal size of Paper',,,,,,.F. )
    endif
 endif
 restscreen(,,,,mu)
 restdbf(gf)
 return nil
/*--------------------------*/
 Static Function get_Hacct()
/*--------------------------*/
local nretval:=spac(5),mu:=savedbf()
local ax_,az_,axx_,xSet:=setkey( K_ESC )
local scr_ := savescreen( ,,,, ),colr_:=setcolor()
setkey(K_ESC, nil )
dbselectarea('Client')
&&ax_ := flook( .t.,'Client',nil,'Client Master File',3,1,4,1 )
ax_ := flook_online( .t.,'Client',nil,'Client Master File',3,1,4,,1 )
if lastkey() == K_ESC
   restdbf(mu)
   setkey( K_ESC, xSet )
   restscreen(,,,, scr_ )
   setcolor( colr_ )
   return spac(5)
elseif !empty( axx_ := checkacctmas( ax_ ) )
   setcolor('w/gr,n/w,,,w/gr')
   fShadow( 10,30,20,50, 2 ,'w/gr' )
   @ 11,31 say padc('Account Number',19 ) color 'w+/bg'
   @ 12,31 say repl('Ä',19 ) color 'w/gr'
   while .t.
      az_ := achoice( 13,33,19,48,axx_,,'fstatudf', 1 ,1 )
      if lastkey() == K_ESC
         nretval:=spac(5)
         exit
      elseif lastkey() <> K_LEFT .and. lastkey() <> K_RIGHT
         nretval := substr(axx_[ az_ ],-5,5 )
         exit
      endif
   enddo
endif
setkey( K_ESC, xSet )
restscreen(,,,, scr_ )
setcolor( colr_ )
restdbf(mu)
return nretval
/*---------------------------------*/
 Static Function Checkacctmast(ax_)
/*---------------------------------*/
local nretval,axz_:={},mu:=savedbf()
local mi:=Acctmast->(Indexord())
dbselectarea('Acctmast')
dbsetorder(2)
if dbseek(ax_)
   waiton('Checking Account Master file...',,'n*/w')
   dbeval( { || aadd(axz_, Trans( Acctmast->Acctno,'@R 9999-99999-99999' ) ) },, ;
           { || Acctmast->Clntcode == ax_  } )
  waitoff()
endif
Acctmast->(dbsetorder(mi))
restdbf(mu)
return axz_
//////
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
/*----------------------------*/
 Static Function chksignee()
/*----------------------------*/
 
 local mu:=setcolor(),nretval := .f.

 fshadow(12,18,15,65,2,'w+/w')
 setcolor('n/w,w+/n,,,w+/w')
 setcursor(1)
 while   .t.
   @ 13, 19 say ' Prepared By   ' get nprefby  pict '@!XS25' ;
                                 when eval( { || !empty(nPrefby := flook_online(.t.,'Personel',,'Personnel File',,,,,2 ) ),.f. } ) ;   &&flook(.t.,'Personel',,'Personnel File',,,,2 ) ),.f. } ) ;
                                 valid !empty(nPrefby)
   @ 14, 19 say ' Noted By      ' get nNotedby pict '@!XS25' ;
                                 when lastkey() <> K_ESC .and. !empty(nNotedby := eval( { || flook_online(.t.,'Personel',,'Personnel File',,,,,2 ) } ) ) ;  &&flook(.t.,'Personel',,'Personnel File',,,,2 ) } ) ) ;
                                 valid !empty(nNotedby)
   setkey(K_ESC, { || Fescape('Abort? ') } )
   read
   if lastkey() == K_ESC .or. Lastkey() == K_ENTER
      exit
   endif
 enddo
 setkey(K_ESC,Nil )
 if lastkey() <> K_ESC
    nretval := .t.
 endif
 setcolor(mu)
 setcursor(0)
 return nretval

/*----------------------------*/
 Static Function nchkAcct(nacct)
/*----------------------------*/
 local mu:= savedbf(),nretval:=.f.
 nacct := substr( '00000'+ alltrim(nacct),-5,5 )
 dbselectarea('Acctmast')
 dbsetorder(1)
 if Acctmast->(dbseek( nacct ))
    if Udihist->(dbseek( Acctmast->Acctno ) )
       nretval:=.t.
    else
      error('No Payment yet.')
    endif
 else
    error('Account Does not exist.')
 endif

 return nretval

/*--------------------*/
  Function Prnhist02()
/*--------------------*/
 local pgn:=1,xdate:=Cmonth( Flag->Prevdate )+' '+str(Day( Flag->Prevdate ),2)+', '+str(year(Flag->Prevdate ),4)
 local tot_amrt := 0, tot_pen := 0, npent_s := 0,ncredamt:= ( Acctmast->Credamt - ( Acctmast->Principal + Acctmast->Incentive ) )
 local Pay_:={ 'Accrual','Adjustment','Review','','','','','','Balance Forwarded' }
 local tot_or:=0, tot_am := 0, tot_penal := 0
 local xoramount := xamort := xpenal:=0,pprd:={},pperiod,unpd_pen := 0
 local xacctno,xornum,xrefdate,xcode,nrow:= { 05,19,32,43,60,86,93,117 }
 local prate:=xprate,pdate:= gTrandate, xblk

 Headhist01(pgn,xdate)
 Headhist02()
 Head_det()
 Udihist->(dbseek(Acctmast->Acctno) )
 //ncredamt:= Acctmast->Credamt
 while Udihist->Acctno == Acctmast->Acctno
       if prow() > 60
          __eject()
          pgn++
          setfont('UNCONDENSD')
          Headhist01(pgn,xdate)
          Head_det()
       endif
       xrefdate := Udihist->Refdate
       xornum   := Udihist->Ornumber
       xacctno  := Udihist->Acctno
       xcode    := Udihist->Paycode

       while Udihist->Acctno == xAcctno .and. Udihist->Ornumber == xornum .and. Udihist->Refdate == xrefdate .and. Udihist->Paycode == xcode
           xamort    += Udihist->Intamt
           Udihist->(dbskip())
       enddo
       
       @ prow()+1, 05 say Pay_[ val( xcode ) ]
       @ prow()  , 19 + if( xcode == '9',5,0) ;
                      say if( xcode == '9','',Dtoc( xRefdate ) )
       @ prow()  , 33 say if( xcode == '9','',xOrnum )
       @ prow()  , 45 say trans(xamort, '@( 999,999,999.99')
       @ prow()  , 62 say Tran( (nCredamt -= ( xamort ) ) ,'@( 999,999,999.99' )
       pprd:={}
       tot_or += xOramount
       tot_am += xamort
       tot_penal += xPenal
       xoramount := xamort := xpenal:=0
 enddo

 @ prow()+1 ,02 say Repl('Ä',77 )
 if Prow() > 52
      __eject()
      pgn++
      Headhist01(pgn,xdate)
 endif
 if Prow() > if(tot_amrt <> 0 .or.  tot_pen <> 0, 53,55 )
      __eject()
      pgn++
      Headhist01(pgn,xdate)
 endif

 setfont('UNCONDENSD')
 //setfont('NLQ')
 setfont('ELITE')
 prnnoted()
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
@ PROW(), 50 SAY 'Noted by : '
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
@ PROW(), 50 SAY '           '
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
@ prow()+1,02 say PADC('CONSOLIDATED ORIX LEASING AND FINANCE CORPORATION',94)
setfont('BOLD')
@ prow()+1,02 say padc( 'INCOME ACCRUAL',94 )
setfont('UNBOLD')
@ prow()+1,02 say padc('As of '+ xdate,94)
@ prow()+1,02 say ''
return nil

/*--------------------------*/
 Static Function Headhist02()
/*---------------------------*/
local lcol := 58
//setfont('NLQ')
//setfont('PICA')

@ prow()+1,02 say 'Account Number  : ' + tran(Acctmast->Acctno,'@R 9999-99999-99999')
@ prow()+1,02 say 'Account Name    : ' + Acctmast->Acctname
@ prow()+1,02 say ''

@ prow()+1,02   say 'Date Booked     : ' + Dtoc(Acctmast->Valdate)
@ prow()  ,lcol say 'Amount Financed  : ' + Tran(Acctmast->Principal,'999,999,999.99')

@ prow()+1,02   say 'Term            : ' + Tran(Acctmast->Term,'999') + ' ' + gettermunit( Acctmast->Termunit )
@ prow()  ,lcol say 'Guaranty Deposit : ' + Tran( (Acctmast->GD/100) * Acctmast->Principal,'999,999,999.99')

@ prow()+1,02   say 'First Due Date  : ' + Dtoc( Acctmast->Firstdue )
@ prow()  ,lcol say 'Residual Value   : ' + Tran( ( Acctmast->Rv/100 ) * Acctmast->Principal, '999,999,999.99' )

@ prow()+1,02   say 'Pay. Frequency  : ' + getpayfreq( Acctmast->Payfreq )
@ prow()  ,lcol say 'Amortization     : ' + Tran( Acctmast->Amort,'999,999,999.99')

@ prow()+1,02   say 'True Rate       : ' + Tran( Acctmast->Truerate,'99.99999' ) +' %'
//@ prow()  ,lcol say 'Net-To-Close     : '+ tran( if( Acctmast->Osbal > 0, nGetnetcls(Acctmast->Acctno), 0 ), '999,999,999.99')

@ prow()+1,02 say ''
@ prow()+1,02 say 'Collateral      : '+ Acctmast->Unit
if !empty(Acctmast->Unit2)
  @ prow()+1,02 say '                  ' + Acctmast->Unit2
endif
@ prow()+1,02 say ''
return nil
/*-------------------------*/
 Static Function Head_det()
/*-------------------------*/

//setfont('DRAFT')
setfont('NLQ')
setfont('PICA')
//setfont('CONDENSED')

@ prow()+1, 05 say '-----------   -----------   ---------   --------------   --------------'
@ prow()+1, 05 say 'Type  of      Date  of      Reference      Amount          UDI Balance '
@ prow()+1, 05 say 'Transaction   Transaction   Number                                     '
@ prow()+1, 05 say '-----------   -----------   ---------   --------------   --------------'

setfont('DRAFT')
return nil

/*-------------------------*/
 Static Function aOpenhist()
/*-------------------------*/

if !netuse( 'Acctmast', .f., 10 )              && Account master file
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( 'AcctSub2' )                    && set index on substr( acctno, -5,5 )
   ordlistadd( 'Acctclnt' )                    && set index on Clientcode
endif

if !netuse( '&g_Cis_Path\Client', .f., 10 )              && Client Master file
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_Cis_Path\Clienm' )                    && set Client Name
endif

if !netuse( 'Udihist', .f., 10 )              && Account Payment history file
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( 'Udihist' )                    && set index on acctno
   //ordlistadd( 'Acctclnt' )
endif

if !netuse( 'Udispred', .f., 10 )              && Account Review file
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( 'Udispred' )                    && set index on acctno
   //ordlistadd( 'Acctclnt' )
endif


if !netuse( '&g_Grf_path\Personel', .f., 10 )              && Account Review file
   break
else
   if !.f.; ordlistclear(); endif
   //ordlistadd( '&g_Grf_path\Personel' )                    && set index on acctno
   ordlistadd( '&g_Grf_path\Initials' )                    && set index on Initials
   //ordlistadd( 'Acctclnt' )
endif

if !netuse( 'Parametr', .f., 10 )              && Account Review file
   break
endif

if !netuse( 'Flag', .f., 10 )              && Account Review file
   break
endif
return nil
/*
123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
         1         2         3         4         5         6         7         8         9         0         1         2
    -----------   -----------   ---------   --------------   --------------'
    Type  of      Date  of      Reference      Amount          UDI Balance '
    Transaction   Transaction   Number                                     '
    -----------   -----------   ---------   --------------   --------------'
    xxxxxxxxxxx   99/99/9999   99999999     999,999,999.99   999,999,999.99

    ncol := { 5,19,33,45,62 }
*/
