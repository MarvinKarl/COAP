/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³   colf-iis -- account management system                                  ³
 ³   program idúúú amsr0100                                                 ³
 ³   descriptionúú Account Review for the Week                              ³
 ³   authorúúúúúúú renan s. evangelista                                     ³
 ³   dateúúúúúúúúú 9:20:am úú 09-30-96                                      ³
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

/*-------------------------*/
 Static Function aOpenhist()
/*-------------------------*/
LOCAL pim_dir:=''
if !netuse( 'Acctmast', .f., 10 )              && Account master file
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( 'AcctSub2' )                    && set index on acctno
   //ordlistadd( 'Acctclnt' )                    && index on Clntcode + acctno
endif

if !netuse( 'Review', .f., 10 )              && Account Review file
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( 'Review' )                    && set index on acctno+effdate
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
   ordlistadd( '&g_Grf_path\Personel' )                    && set index on acctno
   //ordlistadd( 'Acctclnt' )
endif

if !netuse( 'Parametr', .f., 10 )   
   break
endif
pim_dir:=alltrim(Parametr->Pim_path)

if !netuse( (Pim_dir)+'\Empmast',.f.,10)
   break
else
  set index to  (pim_dir)+'\empname'
endif

if !netuse( (pim_dir)+'\Position',.f.,10)
   break
else
  set index to  (pim_dir)+'\Position'
endif

if !netuse( 'Flag', .f., 10 )              && Account Review file
   break
endif


return nil


/*---------------------------*/
 Static Function  aMainhist()
/*---------------------------*/
 local mu:= savescreen(,,,),gf:=savedbf(),bf:=setcolor()
 local nacct:=spac(5)
 private nprepby:=spac(40),nNoted1:=spac(40),nNoted2:=spac(40),napprv1:=spac(40)
 private napprv3:=spac(40),napprv2:=spac(40),ncheck:=spac(40)
 private prepos:=spac(20), chkpos:=spac(20), notpos1:=spac(20),notpos2:=spac(20)
 private apppos1:=spac(20),apppos2:=spac(20),apppos3:=spac(20)
 private st_date:=Flag->Trandate-5,end_date:=Flag->Trandate,totcount:=0


 fshadow(09,13,12,48,2,'n/w')
 setcolor('n/w,w/n,,,w+/w' )
 setcursor(1)
 while lastkey() <> K_ESC  .and. .t.
     @ 10,15 say ' Beginning date  ' get st_date Pict '@D' valid !empty(st_date) .and. st_date <= Flag->Trandate
     @ 11,15 say ' Ending date     ' get end_date pict '@D' ;
                                          valid ( !empty(end_date) .and. end_date <= Flag->Trandate )
     setkey( K_ESC,{ || Fescape('Abort?') } )
     read
     setkey( K_ESC,nil )
     if lastkey() == K_ENTER .and. Confirm('Are all entries correct',.f.)
        exit
     elseif lastkey() == K_ESC
        exit
     endif
 enddo
 if empty( totcount:=countall() )
    error('Error:The Report generated is empty.,')
    restscreen(,,,,mu)
    restdbf(gf)
    return nil
 endif
 setcolor(bf)
 setcursor(0)
 if lastkey() <> K_ESC
    if chksignee()
       nprepby:=substr(nPrepby,1,29)
       ncheck :=substr(ncheck,1,29)
       nNoted1:=substr(nNoted1,1,29)
       nNoted2:=substr(nNoted2,1,29)
       nApprv1:=alltrim(nApprv1)
       nApprv2:=alltrim(nApprv2)
       nApprv3:=alltrim(nApprv3)
       *repcontrol('Prnrev16()','Legal Size(Long) of paper<side ways>' )
       repcon_ol('Prnrev16()','Legal Size(Long) of paper<side ways>',,,,,,.F. )
    endif
 endif
 restscreen(,,,,mu)
 restdbf(gf)
 return nil
/*----------------------------*/
 Static function getpostn(ncode)
/*----------------------------*/
local nretval:=' '
Position->(dbsetorder(1))
if Position->(dbseek(ncode))
   nretval := alltrim( Position->Posname )
endif
return nretval

/*----------------------------*/
 Static Function chksignee()
/*----------------------------*/
 
 local mu:=setcolor(),nretval := .f.
 local lcol:= { ;
              tbcolumnnew( 'Employee Name ',   ;
                          { || alltrim( Empmast->Fname )+' '+substr(empmast->mname,1,1)+'. ' + ;
                               alltrim( Empmast->Lname ) } ), ;
              tbcolumnnew( ' Position ',       ;
                           { || getpostn(Empmast->Poscode) } ) }
 fshadow(12,18,20,65,2,'w+/w')
 setcolor('n/w,w+/n,,,w+/w')
 setcursor(1)
 dbselectarea('Empmast')
 dbsetorder(1)
 while   .t.
   @ 13, 19 say '   Prepared By  ' get nprepby  pict '@!XS25' ;
                                 when eval( { || !empty( eval( { || nprepby := flook_online(.t.,'Empmast',,'Prepared By',,,,,3,,lcol ),;     &&flook(.t.,'Empmast',,'Prepared By',,,,3,,lcol ),;
                                 nprepby := getnextnme(nprepby),prepos:=getposition(Empmast->Poscode)  } ) ),.t. } ) ;
                                 valid !empty(nprepby)
   @ 14, 19 say '    Checked By  ' get ncheck pict '@!XS25' ;
                                 when eval( { || !empty( eval( { || ncheck := flook_online(.t.,'Empmast',,'Checked By',,,,,3,,lcol ),;    &&flook(.t.,'Empmast',,'Checked By',,,,3,,lcol ),;
                                 ncheck := getnextnme(ncheck),chkpos:=getposition(Empmast->Poscode)  } ) ),.t. } )

   @ 15, 19 say '   Noted By(1)  ' get nNoted1 pict '@!XS25' ;
                                    when eval( { || nNoted1 := eval( { || flook_online(.t.,'Empmast',,'Noted By(1)',,,,,3,,lcol )}),;    &&flook(.t.,'Empmast',,'Noted By(1)',,,,3,,lcol )}),;
                                    nNoted1 :=getnextnme(nNoted1), notpos1:=getposition(Empmast->Poscode), .t. } ) ;
                                    valid !empty(nNoted1)
   @ 16, 19 say '   Noted By(2)  ' get nNoted2 pict '@!XS25' ;
                                 when eval( { || nNoted2 := flook_online(.t.,'Empmast',,'Noted By(2)',,,,,3,,lcol ),;      &&flook(.t.,'Empmast',,'Noted By(2)',,,,3,,lcol ),;
                                 nNoted2 := getnextnme(nNoted2),notpos2:=getposition(Empmast->Poscode),.t. } ) ;
                                 valid !empty(nNoted2)
   @ 17, 19 say 'Approved By(1)  ' get napprv1 pict '@!XS25' ;
                                 when eval( { || !empty( eval( { || napprv1 := flook_online(.t.,'Empmast',,'Approved By(1)',,,,,3,,lco ),;     &&flook(.t.,'Empmast',,'Approved By(1)',,,,3,,lco ),;
                                 napprv1 := getnextnme(napprv1),apppos1:=getposition(Empmast->Poscode)  } ) ),.t. } ) ;
                                 valid !empty(napprv1)
   @ 18, 19 say 'Approved By(2)  ' get napprv2 pict '@!XS25' ;
                                 when eval( { || !empty( eval( { || napprv2 := flook_online(.t.,'Empmast',,'Approved By(2)',,,,,3,,lcol ),;     &&flook(.t.,'Empmast',,'Approved By(2)',,,,3,,lcol ),;
                                 napprv2 := getnextnme(napprv2),apppos2:=getposition(Empmast->Poscode)  } ) ),.t. } ) ;
                                 valid !empty(napprv2)
   @ 19, 19 say 'Approved By(3)  ' get napprv3 pict '@!XS25' ;
                                 when eval( { || !empty( eval( { || napprv3 := flook_online(.t.,'Empmast',,'Approved By(3)',,,,,3,,lcol ),;     &&flook(.t.,'Empmast',,'Approved By(3)',,,,3,,lcol ),;
                                 napprv3 := getnextnme(napprv3),apppos3:=getposition(Empmast->Poscode)  } ) ),.t. } ) ;
                                 valid !empty(napprv3)

   setkey(K_ESC, { || Fescape('Abort? ') } )
   read
   if lastkey() == K_ESC
      nprepby:=spac(40);nNoted1:=spac(40);nNoted2:=spac(40);napprv1:=spac(40)
      napprv3:=spac(40);napprv2:=spac(40);ncheck:=spac(40)
      prepos:=spac(20); chkpos:=spac(20); notpos1:=spac(20);notpos2:=spac(20)
      apppos1:=spac(20);apppos2:=spac(20);apppos3:=spac(20)
      exit
   elseif Lastkey() == K_ENTER
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
 Static Function getnextnme(nname)
/*----------------------------*/
local mu:=savedbf(),nretval:=''
dbselectarea('Empmast')
nretval:=alltrim(nname)+' '+substr(fieldget(4),1,1)+'. '+alltrim(fieldget(2))
restdbf(mu)
return nretval


/*-----------------------------------*/
 Static Function getposition(nPoscode)    //get position  from PIM
/*-----------------------------------*/
 local mu:=savedbf(),nretval:=''
 dbselectarea('Position')
 dbsetorder(1)
 dbseek(nPoscode)
 nretval := alltrim( Position->Posname )
 restdbf(mu)
 return nretval

/*------------------------------------*/
 Static Function Headhist01(pgn,xdate)
/*------------------------------------*/
setprc(0,0)

setfont('DRAFT')
setfont('ELITE')
@ prow()+1,05 say 'ACCOUNT MANAGEMENT SYSTEM'
@ prow(),  05+len('ACCOUNT MANAGEMENT SYSTEM');
              say PADL('Page No. ' + tran(pgn,'999'),136-len('ACCOUNT MANAGEMENT SYSTEM'))
@ prow()+1,05 say 'AMSR1600'
@ prow()  ,05+len('AMSQ9999');
              say PADL( dtoc(DATE())+' '+TIME(), 136-len('AMSQ1000'))
@ prow()+1,05 say PADC('CONSOLIDATED ORIX LEASING AND FINANCE CORPORATION',136)
setfont('BOLD')
@ prow()+1,05 say padc('ACCOUNTS REVIEWED FOR THE WEEK',136)
SETFONT('UNBOLD')
@ prow()+1,05 say padc('As of '+ xdate,136)
@ prow()+1,05 say ''
@ prow()+1,05 say '-----------------------------------  --------  --------  --------  --------  -------------  -------------  --------  ----------  -------'
@ prow()+1,05 say '                                     Original  Previous  T. R.                    Previous                                       Payment'
@ prow()+1,05 say '              Account Name             T.R.     T.R.     Formula   New T.R.         Rental     New Rental   Remarks  Effective      Mode'
@ prow()+1,05 say '-----------------------------------  --------  --------  --------  --------  -------------  -------------  --------  ----------  -------'
return nil
/*--------------------------*/
 Static Function getwpdcs()     //check mode of payment
/*--------------------------*/
return nretval:= if(Acctmast->Paymode == '1',"W/PDC's","W/O")

/*----------------------------------------*/
 Static Function getremarks(nAmort1,Amort2)    //for Remarks purpose only
/*----------------------------------------*/
local nretval:=''
return nretval:=if( nAmort1 == Amort2,'Retain  ',;
                if( nAmort1 <  Amort2,'Decrease',;
                                      'Increase'))
/*--------------------------------*/
 Static function getorgtr(nAcctno)    //get original Truerate
/*--------------------------------*/
local nrecno:=Review->(recno()),nretval:=''
dbselectarea('Review')
dbsetorder(1)
if dbseek(nAcctno)
   nretval:=tran(Review->App_tr,'99.9999') + '%'
endif
Review->(dbgoto(nrecno))
return nretval
/*------------------------*/
 Static function Countall()
/*------------------------*/
local nretval:=0
 dbselectarea('Review')
 Review->(dbsetorder(1))
 Review->(dbgotop())
 do while Review->(!eof())
    if Review->Revdate >= St_date .and. Review->Revdate <= End_date
      nretval++
    endif
    Review->(dbskip())
 enddo
return nretval

/*-------------------*/
  Function Prnrev16()
/*-------------------*/
 local xmonth2:= if( month(St_date) == month(end_date),'',cmonth(end_date) )
 local xmonth1:= cmonth( st_date )
 local xyear1 := if ( year(st_date) == year(end_date),'',str(year(st_date),4) )
 local xyear2 := str( year(end_date),4)
 local xday2  := if( month(St_date) == month(end_date) .and. day(st_date) == Day(end_date),'',Str(day(end_date),2) )
 local xday1  := str( day( st_date ),2 )
 local xdate  := alltrim(xmonth1)+ ' ' + alltrim(xday1)+ if(!empty(alltrim(xyear1)),', ','')+alltrim(xyear1)+ ;  //this part displays character date format i.e. according to range
                 if(empty(alltrim(xday2)),'',' -') + if(!empty(alltrim(xmonth2)),' ','') + alltrim(xmonth2)+  ;  //(w/ two diff. months cited,same day,diff. year )
                 if(empty(alltrim(xday2)),'',' ')+alltrim(xday2) + ', '+ xyear2
 local aplen1 := max(len(apppos1),len(nApprv1))
 local aplen2 := max(len(apppos2),len(nApprv2))
 local aplen3 := max(len(apppos3),len(nApprv3))
 local pgn    := 1,x1,x2,x3,prnrec:=0
 Headhist01( pgn, xdate)
 dbselectarea('Review')
 Review->(dbsetorder(1))
 Review->(dbgotop())
 do while Review->(!eof()) .and. Totcount <> 0
    ALTD()
    if totcount > 20
       if totcount-prnrec == 5 
          @ prow()+1, 05 say Repl('Ä',136)
          //tot_count -= 20
          @ prow()+1, 05 say ''
          @ prow()+1, 05 say ''
          @ prow()+1, 05 say ''
          @ prow()+1, 05 say ''
          @ prow()+1, 05 say ''
          @ prow()+1, 05 say '.....next page pls.'
          pgn++
          __eject()
          Headhist01( pgn, xdate)
      elseif prow() > 38
          @ prow()+1, 05 say Repl('Ä',136)
          //tot_count -= 20
          pgn++
          @ prow()+1, 05 say ''
          @ prow()+1, 05 say ''
          @ prow()+1, 05 say ''
          @ prow()+1, 05 say ''
          @ prow()+1, 05 say ''
          @ prow()+1, 05 say '.....next page pls.'
          __eject()
          Headhist01( pgn, xdate)
      endif
    endif
    if Review->Revdate >= St_date .and. Review->Revdate <= End_date
       accnme := substr(eval( {|| Acctmast->(dbseek(SUBSTR(Review->Acctno,-5,5 ))), Acctmast->Acctname } ),1,29)
       prnrec++
       @ prow()+1,05 say substr( Review->Acctno,-5,5 ) +'-'+ accnme +'  ' +getorgtr( Review->Acctno ) + '  '+      ;
                         tran(Acctmast->truerate,'99.9999')+'%' +'  '+ tran(Review->Comp_tr,'99.9999') + '%'+'  '+ ;
                         tran(Review->App_tr,'99.9999') + '%' +'  '+ Tran(Review->App_amrt,'99,999,999.99')+'  '+    ;
                         TRAN(Acctmast->Amort,'99,999,999.99') +'  '+ getremarks(Acctmast->Amort,Review->App_amrt);
                         +'  '+ dtoc(Review->Effdate)+'   '+ getwpdcs()
    endif
    Review->(dbskip())
 enddo
 @ prow()+1, 05 say Repl('Ä',136)
 @ prow()+1, 05 say ''
 @ prow()+1, 05 say 'Prepared by:'+repl('_',29)+' Approved by:'+repl('_',aplen1)+'  '+ ;
                    repl('_',aplen2)+'  '+repl('_',aplen3)

 @ prow()+1, 05 say '            ' + nprepby
 @ prow()  ,                 (x1:=05+12+13+29)  say nApprv1
 @ prow()  ,        (x2:=x1+aplen1+2)  say nApprv2
 @ prow()  , (x3:=x2+aplen2+2)  say nApprv3

 @ prow()+1,05 say '            '+prepos
 @ prow()  ,x1 say apppos1
 @ prow()  ,x2 say apppos2
 @ prow()  ,x3 say apppos3
 @ prow()+1, 05 say ''

 @ prow()+1, 05 say ' Checked by:'+repl('_',29)
 @ prow()+1, 05 say '            '+ncheck
 @ prow()+1, 05 say '            '+chkpos
 @ prow()+1, 05 say ''

 @ prow()+1, 05 say '   Noted by:'+repl('_',29)
 @ prow()+1, 05 say '            '+nNoted1
 @ prow()+1, 05 say '            '+notpos1
 @ prow()+1, 05 say ''

 @ prow()+1, 05 say '            '+repl('_',29)
 @ prow()+1, 05 say '            '+nNoted2
 @ prow()+1, 05 say '            '+notpos2
 @ prow()+1, 05 say ''
 __eject()
return nil



/*
123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5
                                      Original  Previous  T. R.                    Previous
               Account Name             T.R.     T.R.     Formula   New T.R.         Rental     New Rental   Remarks  Effective
 -----------------------------------  --------  --------  --------  --------  -------------  -------------  --------  ----------  -------
 99999-12345678901234567890123456789  99.9999%  99.9999%  99.9999%  99.9999%  99,999,999.99  99,999,999.99  xxxxxxxx  99/99/9999  w/pdc's
 Prepared by:                             Approved by:                                                      
             -----------------------------            --------------------------  --------------------------  --------------------------
             XXXXXXXXXX X. XXXXXXXXXXXXXXX            XXXXXXXXXX X. XXXXXXXXXXXX  XXXXXXXXXX X. XXXXXXXXXXXX  XXXXXXXXXX X. XXXXXXXXXXXX
             xxxxxxxxxxxxxxxxxxx                      xxxxxxxxxxxxxxxxxxx         xxxxxxxxxxxxxxxxxxx         xxxxxxxxxxxxxxxxxxx

  Checked by:
             -----------------------------
             XXXXXXXXXX X. XXXXXXXXXXXXXXX
             xxxxxxxxxxxxxxxxxxx

    Noted by:
             -----------------------------
             XXXXXXXXXX X. XXXXXXXXXXXXXXX
             xxxxxxxxxxxxxxxxxxx
*/
