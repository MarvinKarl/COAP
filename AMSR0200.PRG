/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   colf-iis -- account management system    (RP)                              ³
³   program idúúú amsr0200                                                     ³
³   descriptionúú Statement of Account                                         ³
³   authorúúúúúúú renan s. evangelista                                         ³
³   dateúúúúúúúúú 9:20:am úú 06-27-96                                          ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                             u p d a t e s                                    ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        who        ³       when        ³               why                    ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                   ³                   ³                                      ³
³   abb             ³  04/12/2000       ³  revisions requested by rsa          ³
³   abb             ³  07/13/2000       ³  one account per s/a for             ³
³                   ³                   ³  clients found in saformat.dbf       ³
³                   ³                   ³                                      ³
³   nbs             ³  01/14/2002       ³  custom paper length (9 in.)         ³
³                   ³                   ³  for the statement of account        ³
³   aga             ³  14.02.2007       ³  neo paysked support for modules     ³
³   BUDS            ³  Jul-02-2014      ³  Return TERMS of ACCTMAST            ³
³   FOM             ³  Jul-30-2014      ³  Change footnote                     ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

////
#defi K_SPACEBAR   32
#define _MAXROW    30
#defi microfeed    chr( 27 ) + 'J' + chr( 18 )
#xtran getprntr (<xnum>) => if ( <xnum> == 1, "'Epson FX-1170'",;
                              if ( <xnum> == 2, "'OKI Microline 321'",;
                              if ( <xnum> == 3, "'OKI Microline 521'","")))
////
#include 'inkey.ch'
#include 'colf.ch'
#include 'dbstruct.ch'

memvar  AX_LEVEL, gUSER_ID
private nPREfBY, nNOTEDBY, mpage := 1, mnewclnt
private dstart := date() ,dend := date()+7

setcursor(0)
setblink(.t.)
if !chkpass( procname(), AX_LEVEL, gUSER_ID )
   //NOTHING WILL HAPPEN
else
   begin sequence
     aOpen6000()
//     do while _getfromto()
		_getfromto()
        aMain6000()
//     enddo
   end sequence
   dbcloseall()
endif
__mrelease( '*', .t. )
return nil

*****************************
*
static function _getfromto()
*****************************
*********   local cscr := savescreen(,,,)
   memvar dstart,dend


   chksignee()

   setkey   ( K_ESC,nil )
   setcolor ( 'n/gr,w+/gr','w+/gr,n/gr' )
   fshadow  ( 04, 34, 9, 56, 2, 'w+/bg')

   @ 05,35 say '<<< Maturity Date >>>'
   @ 07,35 say 'From  ' get dstart pict '@D'
   @ 08,35 say 'To    ' get dend   pict '@D'

   setcursor(3)
   read
   setcursor(0)


return lastkey() != K_ESC

/*-------------------------*/
 Static Function Amain6000()
/*-------------------------*/
local mu:=savedbf(),re:=setcursor(),bf:=savescreen(,,,),gf:=setcolor()
local cchoice,menulist,xxx
private xtemp,xdate:=gTrandate,max2,xlastsa  // ,pval

setkey   ( K_ESC,nil )
setcolor ( 'n/gr,w+/gr','w+/gr,n/gr' )

fshadow  ( 09, 39, 14, 55, 2, 'w+/bg')
@ 10,54 say 'Ü'  color 'n/bg'
@ 11,41 say repl('ß',14) color 'n/bg'

@ 13,41 say repl('ß',14) color 'n/bg'
@ 10, 40 prompt ' By ~Client    ' triggercolor "w+/gr"
@ 12, 40 prompt ' ~All Clients  ' triggercolor "w+/gr"

menu to cchoice
do case
   case cchoice == 1
        xxx:=savescreen( ,,, )
        @ 10,40 say repl(' ',15) color 'n/bg'
        @ 11,40 say repl(' ',15) color 'n/bg'
        @ 10,41 say ' By Client    '  color 'w+/gr'
        inkey(.5)
        restscreen( ,,,,xxx)
        @ 10,53 say 'û' color 'w/gr'
        byclient ( cchoice,.f. )
        return .t.
   case cchoice == 2
        xxx:=savescreen( ,,, )
        @ 12,40 say repl(' ',15) color 'n/bg'
        @ 13,40 say repl(' ',15) color 'n/bg'
        @ 12,41 say '  All Clients  '  color 'w+/gr'
        inkey(.5)
        restscreen( ,,,,xxx)
        @ 12,53 say 'û' color 'w/gr'
        byclient ( cchoice,.t. )
        return .t.
   case cchoice == 07
        return .f.
   //     return
endcase
restdbf(mu);restscreen(,,,,bf);setcursor(re);setcolor(gf)
return nil

/*-------------------------------*/
 Static Function byduedate(cchoice)
/*-------------------------------*/
local mu:=savedbf(),re:=setcursor(),bf:=savescreen(,,,),gf:=setcolor()
local ztemp:=substr(crea_Xtemp(),1,7),temp_:={},xddate:=gTrandate
local temp1:=substr(ztemp,2,7)+'1',prntcnt:=0,nrec
private swdue:= .f.

setkey( K_F10,nil )
setkey(K_ESC,nil)
mt:=setkey( K_ESC, { || abrupt() })
fshadow(14,39,16,65,2,'w+/w')
set color to 'n/w','w/n',,,'w+/w'
@ 23,00 say repl(' ' ,80) color 'w/n'
@ 23,01 say ' <Esc> - Exit Printing   <F10> - Exit Current Client' color 'w/n'
@ 23,02 say '<Esc>' color 'w+/n'
@ 23,26 say '<F10>' color 'w+/n'

begin sequence
do while .t.
   setcursor(3)
   @ 15,40 say 'Due date  'get xddate pict '@D'  valid !empty(xddate)
   setkey( K_F10, { || f10escape('Abort this client?') } )

   setcursor(3)
   read
   setcursor(0)

   if lastkey() == K_F10 .or. Lastkey() == K_ENTER .or. swdue
      EXIT
   endif
enddo

if !swdue     //lastkey() <> K_F10

   waiton    ('Creating swap file..please wait.',,'n*/w')
   setkey    ( K_F10, nil )
   setcursor (0)
   dbcreate( (ztemp),{{'ACCTNO','C',14,0},{'BRCODE','C',4,0}} )
   while !netuse( (ztemp), .t., 10);enddo
   index on BRCODE+Acctno to (temp1)
   dbselectarea('Paysked')
   dbsetorder(2)

   Paysked->( dbseek( xddate,.t. ) )
   while Paysked->Paydate <= xddate .and. !eof()
         if !(ztemp)->(dbseek(PAYSKED->BRCODE+Paysked->Acctno))
            (ztemp)->(dbappend())
            (ztemp)->BRCODE := Paysked->BRCODE
            (ztemp)->Acctno := Paysked->Acctno
         endif
         Paysked->(dbskip())
   enddo
   waitoff()
   (ztemp)->(dbcommit())
   dbselectarea( (ztemp) )
   (ztemp)->( dbgotop() )

   mt := setkey( K_ESC, { || abrupt() })

   while (ztemp)->(!eof())
         nrec :=(ztemp)->(recno())
         if !empty( st_:=chkacct( (ztemp)->BRCODE+(ztemp)->Acctno ) )
             if !empty( tl_:=chkclnt(ACCTMAST->BRCODE+Acctmast->Clntcode) )
                prntcnt++
                fmsrduedt( st_,xddate,tl_,ztemp,prntcnt,cchoice )
             endif
         endif

         ( ztemp )->(dbgoto(nrec))
         ( ztemp )->(dbskip())
   enddo

endif
end sequence
(ztemp)->(dbclosearea())
altd()
restdbf(mu);restscreen(,,,,bf);setcursor(re);setcolor(gf)

ferase ( (ztemp) +'.dbf' )
ferase ( (temp1) +'.ntx' )
return nil
/*
/*-------------------------------*/
 Static Function Chkacct(xacctno)
/*-------------------------------*/
local mu:=savedbf(),re:=setcursor(),bf:=savescreen(,,,),gf:=setcolor()
local tmp_:={},xclnt

//setkey(K_ESC,nil)
dbselectarea('Acctmast')
dbsetorder(1)
xclnt := if(dbseek( xacctno ),ACCTMAST->BRCODE+Acctmast->Clntcode,spac(14))
dbsetorder(2)
dbeval( {|| if(Acctmast->Paymode == '2',aadd( tmp_,{ ACCTMAST->BRCODE+Acctmast->Acctno,Acctmast->Oldno,Acctmast->Term,Acctmast->Unit } ),nil) },,;
{|| ACCTMAST->BRCODE+Acctmast->Clntcode == xclnt .and. !eof() } )
DBSKIP(-1)
restdbf(mu);restscreen(,,,,bf);setcursor(re);setcolor(gf)
return tmp_

/*-------------------------------*/
 Static Function ChkClnt( xclnt )
/*-------------------------------*/
local mu:=savedbf(),re:=setcursor(),bf:=savescreen(,,,),gf:=setcolor()
dbselectarea( 'Client' )
dbsetorder( 1 )
dbseek( xclnt )
altd()
return (CLIENT->BRCODE+Client->Clntcode)
*/
/*-------------------------------*/
 Static Function fmsrduedt( st_, xddate, tl_, ztemp, prntcnt, cchoice )
/*-------------------------------*/
local mu:=savedbf(),re:=setcursor(),bf:=savescreen(,,,),gf:=setcolor()

if !empty(st_)
   fshadow(14,01,20,33,2,'w/n')
   @ 14,02 say 'Client Being Processed' color 'w+/n'
   @ 16,02 say substr(Client->Fullname,1,30) color 'w+/n'
   @ 17,02 say 'No. of Account     : ' color 'w/n'
   @ 17,24 say tran(len(st_),'9999')   color 'w+/n'
   @ 18,02 say 'No. of Payment due : ' color 'w/n'

   if fdata1014(st_,xddate,ztemp,cchoice)
      fdata1114( tl_,prntcnt,cchoice )
   endif
endif

restdbf(mu);restscreen(,,,,bf);setcursor(re);setcolor(gf)
return nil

/*-------------------------------*/
 Static Function byclient ( cchoice,lallclients )
/*-------------------------------*/
local mu := savedbf(), bf:=savescreen(,,,), gf:=setcolor()
local re := setcursor(), tmp_:={}, sw:=.f., st_, xxx
local xclient:=spac(10), xddate:=gTrandate, xchoice, menulist
local nmonth
PRIVATE xSTR

setkey(K_ESC,nil)
dbselectarea ( 'Client' )
Client->     ( dbsetorder(2) )

do while !sw

  if !get_param(@xclient,@xddate,@sw,lallclients)
     exit
  else
     sw := .t.
  endif

enddo

if lastkey() != K_ESC

   if lallclients

      __keyboard(chr(K_ENTER))

      setcolor ( 'n/gr,w+/gr','w+/gr,n/gr' )
      fshadow  ( 10,47,13,59+5,2,'w+/bg'   )

      @ 11,56 say 'Ü'           color 'n/bg'
      @ 12,51 say repl('ß',6+6) color 'n/bg'
      @ 11,50 prompt ' ~All Accounts ' triggercolor 'w+/gr'

      menu to xchoice

      if lastkey() != K_ESC
         xchoice := 2
      else
         xchoice := 0
      endif

   else

      setcolor ( 'n/gr,w+/gr','w+/gr,n/gr' )
      fshadow  ( 12-2,47,17-2,59+5,2,'w+/bg' )

      @ 13-2,56-1 say 'Ü'           color 'n/bg'
      @ 14-2,51-1 say repl('ß',6+6) color 'n/bg'
      @ 15-2,56-1 say 'Ü'  color 'n/bg'
      @ 16-2,51-1 say repl('ß',6+6) color 'n/bg'

      @ 11,50-1 prompt ' ~One Account  ' triggercolor 'w+/gr'
      @ 13,50-1 prompt ' ~All Accounts ' triggercolor 'w+/gr'

      menu to xchoice

   endif

   do case
      case xchoice == 2                    ///////// All
           xxx:=savescreen( ,,, )

           if lallclients
              @ 11,50 say repl(' ',7+5) color 'n/bg'
              @ 12,50 say repl(' ',7+5) color 'n/bg'
              @ 11,51 say ' All Accounts '  color 'w+/gr'
           else
              @ 13,50 say repl(' ',7+5) color 'n/bg'
              @ 14,50 say repl(' ',7+5) color 'n/bg'
              @ 13,51 say ' All Accounts '  color 'w+/gr'
           endif

           inkey(.5)
           restscreen( ,,,,xxx )
           @ 15-2,50+12 say 'û' color 'w/gr'

//           IF TRUE_BRCH == '001'
              st_ := doall(xclient,lallclients)
//           endif

      case xchoice == 1
           xxx:=savescreen( ,,, )         ////////// One
           @ 11,50 say repl(' ',7+5) color 'n/bg'
           @ 12,50 say repl(' ',7+5) color 'n/bg'
           @ 11,51 say ' One Account '  color 'w+/gr'

           inkey(.5)

           restscreen( ,,,,xxx )
           @ 13-2,50+12 say 'û' color 'w/gr'

           st_ := doone(xclient,lallclients)

      case xchoice == 0
           restdbf(mu);restscreen(,,,,bf);setcursor(re);setcolor(gf)
           return nil
   endcase

endif

if !empty(st_) 

   if TRUE_BRCH <> '001'

      xSTR := CHK_PAR(xCHOICE)+CHK_PAR(xCLIENT)+CHK_PAR(lALLCLIENTS)

      IF xCHOICE == 1
         xSTR := xSTR+;
              CHK_PAR(ST_[1,1])+CHK_PAR(ST_[1,2])+;
              CHK_PAR(ST_[1,3])+CHK_PAR(ST_[1,4])
         endif

   endif
 
 
   if fdata1014(st_,xddate,,cchoice)
      fdata1114(xclient,,cchoice,lallclients)
   endif

else
****alert ( 'not if !empty(st_)' )   
endif

restdbf(mu);restscreen(,,,,bf);setcursor(re);setcolor(gf)
return nil

**************************************************
*
static function get_param ( xclient,ddate,sw,lallclients )
**************************************************
   local mretval := .t., getlist := {}, mcolor := setcolor()
   local nmonth := month(ddate),nyear := year (ddate)


  fshadow      (6,30,8,55,2,'n/w')
  set color to 'n/w','w/n',,,'n/w'

  if lallclients                                 // print all clients
     @   7,32 say 'Client  ' + 'All Clients'
  else                                           // single client only
     @   7,32 say 'Client  '       ;
             get xclient            ;
             pict '@R 999-99-99999' ;       && RED 120804 REPLACED '@X'
             VALID IF(EMPTY(xCLIENT),;
                      EVAL( {|| xCLIENT := FLOOK_ONLINE( .T., 'CLIENT',NIL,'Client Master File',45,1,3,4,1,,,,,,.T.),;
                                IF(!EMPTY(xCLIENT) .AND. CURRBRCH(LEFT(xCLIENT,3)),;    &&RED 011005 VALBRCODE(LEFT(xCLIENT,3),g_USER_ID),;
                                   IF(CHKCLIENT( xCLIENT,@SW ),;
                                      .T.,;
                                      EVAL({|| xCLIENT:= SPACE(10), .F.})),;
                                   EVAL({|| xCLIENT:= SPACE(10), .F.});
                                  );
                          } ),;
                      IF( CURRBRCH(LEFT(xCLIENT,3)) ,;   &&RED 011005 VALBRCODE(LEFT(xCLIENT,3),g_USER_ID),;
                         IF(CHKCLIENT( xCLIENT,@SW ),;
                            .T.,;
                            EVAL({|| xCLIENT:= SPACE(10), .F.});
                           ),;
                         EVAL({|| xCLIENT:= SPACE(10), .F.});
                        );
                     )
           /*when lastkey() <> K_ESC .and. ;
             eval( {|| xclient := flook_ONLINE( .t., 'Client',nil,'Client Master File',45,1,3,4,1,), .t. } );
             valid eval( { || chkclient( xclient,@sw ),.t.} )*/
   endif


   setcursor(3)
   read
   setcursor(0)

   setcolor( mcolor )
return lastkey() != K_ESC

******************************************************
*
*
static function fdata1014(st_,ddate,ztemp,cchoice)
******************************************************
local mu:=savedbf(), re:=setcursor(), bf:=savescreen(,,,), gf:=setcolor()
local x, i, ctr:=0, gr_[500], compact:=''
local nntx := Acctmast->(indexord()) , nrecno := Acctmast->(recno())
local temp1, temp2, temp3, temp4
local nprint:=' ', CPS_RET
local xclntcode

memvar dstart, dend


swdue := .f.

if cchoice == 1
  setkey(K_ESC, NIL )
else
  setkey(K_F10,nil)
endif

xtemp := crea_Xtemp()
fshadow   ( 17+3,38-6,19+3,68,2,'w+/w' )
set color to 'n/w','w/n',,,'w+/w'
setcursor ( 3 )

 @ 18+3,39-6 say ' Statement Date  ' ;
         get xdate                ;
         pict '@D'                ;
         when .t.                 ;
         valid if(xdate < mTRANDATE,eval( { || error('Statement date should be ò Transaction Date!'),.f.} ), .t. )

 if ( cchoice==1,;
      setkey ( K_ESC, {|| fescape('Abort?') }),;
      setkey ( K_F10, {|| f10escape('Abort this client?') } );
    )

 setcursor(3)
 read
 setcursor(0)

 if ( cchoice == 1      ,;
      setkey(K_ESC,NIL) ,;
      setkey(K_F10,nil)  ;
    )

 if cchoice == 1
    if lastkey() == K_ESC
       restdbf    (mu)
       restscreen (,,,,bf)
       setcursor  (re)
       setcolor   (gf)
       return .f.
    endif
 elseif cchoice == 2
        if swdue  //lastkey() == K_F10
           restdbf    (mu)
           restscreen (,,,,bf)
           setcursor  (re)
           setcolor   (gf)
           return .f.
        endif
 endif

IF TRUE_BRCH == '001'
   waiton ( 'Transferring data...,please wait',,'n*/w' )
   setcursor(re)

//aga.09.05.2006.marked for modification
   dbselectarea ( 'Paysked' )
   Paysked->    ( dbsetorder(1) )    //checked for index

   temp_ := Paysked->(dbstruct())

   aadd( temp_,{ 'PENSTAT' ,'N',1 ,0 } )   
   aadd( temp_,{ 'GRUPSTAT','N',1 ,0 } )   
   aadd( temp_,{ 'OLDNO'   ,'C',16,0 } )   
   aadd( temp_,{ 'CLNTCODE','C',7 ,0 } )

   dbcreate( 'c:\'+xtemp, temp_ )

   while !netuse( 'c:\'+xtemp,.t.,10 )
   enddo

   temp1 := 'c:\'+substr(xtemp,1,7) +'1'
   temp2 := 'c:\'+substr(xtemp,1,7) +'2'
   temp3 := 'c:\'+substr(xtemp,1,7) +'3'
   temp4 := 'c:\'+substr(xtemp,1,7) +'4'

   (xtemp)->(dbcreateindex( (temp1),'penstat',{ || penstat } ))  //corruption check Numeric?
   (xtemp)->(dbcreateindex( (temp2),'Acctno+str( Grupstat,1)',{ || Acctno+str(Grupstat,1) } ))
   (xtemp)->(dbcreateindex( (temp3),'Acctno+dtos(Paydate)',{ || Acctno+dtos(Paydate) },.t. ))   //not used  
   (xtemp)->(dbcreateindex( (temp4),'clntcode+Acctno+dtos(Paydate)',{ || clntcode+Acctno+dtos(Paydate) } )) 

   set index to (temp1), (temp2), (temp3), (temp4)

   for x:= 1 to len(st_)

       dbselectarea ('Paysked')
       Paysked->(dbsetorder(3))  //aga.05.06.2007.to change 

       ctr := 0

       if Paysked->(dbseek( st_[ x,1 ]+'D' ) )   

         ddate := dend

         do while PAYSKED->BRCODE+Paysked->Acctno == st_[ x,1 ] .and. Paysked->Paydate <= dend .and. Paysked->status == 'D'

                 if ztemp != nil
                     if (ztemp)->(dbseek(PAYSKED->BRCODE+Paysked->Acctno))
                        (ztemp)->(dbdelete())
                     endif
                 endif

                 ctr++
                 gr_[ctr] := (xtemp)->(recno())

                 Acctmast->(dbsetorder(1))

                 if Acctmast->(dbseek(PAYSKED->BRCODE+Paysked->acctno))
                    xclntcode := Acctmast->clntcode
                 else
                    //alert('no client match')
                 endif


                 if (xtemp)->( netlock('A',5) )
                    (xtemp)->acctno     := Paysked->acctno
                    (xtemp)->paynum     := Paysked->paynum
                    (xtemp)->paydate    := Paysked->paydate
                    (xtemp)->amtdue     := Paysked->amtdue        //Paysked->amort
                    (xtemp)->penalty    := 0                      //Paysked->penalty
                    (xtemp)->oldno      := st_[ x,2 ]
                    (xtemp)->brcode     := Paysked->brcode        //LEFT( ST_[ X,1 ], 3 )
                    (xtemp)->clntcode   := xclntcode
                    (xtemp)->grupstat   := 0  //will be replace if in group later


                    if Paysked->Paydate+5 < xdate  // five days grace period (06/09/2000)
                       (xtemp)->Penstat := 1
                    else 
                       (xtemp)->Penstat := 0   
                    endif

                    (xtemp)->(dbcommit())
                 endif

                 rnum:= (xtemp)->(recno())
                 Paysked->(dbskip(+1))

           enddo


         if ctr > 1
            (xtemp)->(dbgoto(gr_[1]))

            do while (xtemp)->BRCODE+(xtemp)->Acctno == st_[ x,1 ]
               if (xtemp)->( netlock('R',5) )
                  (xtemp)->grupstat := 1
                  (xtemp)->(dbcommit())
               endif

              (xtemp)->(dbskip(+1))
            enddo
         endif

       endif

   next x
//...................................


   waitoff()
   _filter_xtemp()
ELSE
   xSTR := xSTR+CHK_PAR(dDATE)+CHK_PAR(xDATE)+CHK_PAR(dSTART)+CHK_PAR(dEND)

   xTEMP := CPS_REQST(xSTR, 'fDATA1014')

   IF xTEMP == NIL .OR. EMPTY(xTEMP)
      RETURN .F.
   ELSE
      TEMP1 := g_AMS_PATH+'\'+substr(xTEMP,1,7) +'1'
      TEMP2 := g_AMS_PATH+'\'+substr(xTEMP,1,7) +'2'
      TEMP3 := g_AMS_PATH+'\'+substr(xTEMP,1,7) +'3'
      TEMP4 := g_AMS_PATH+'\'+substr(xTEMP,1,7) +'4'

      WHILE !NETUSE( g_AMS_PATH+'\'+xTEMP,.T.,10 ); ENDDO
      SET INDEX TO (TEMP1), (TEMP2), (TEMP3), (TEMP4)
   endif
endif

if cchoice == 2
   @ 18,24 say tran( (xtemp)->(lastrec()),'9999' ) color 'w+/n'
endif

Acctmast->(dbsetorder(nntx))
Acctmast->(dbgoto(nrecno))

if (xtemp)->(eof()) .and. (xtemp)->(bof())
   waiton('No S/A generated for this Client ',,'n/w')
   inkey(3)
   waitoff()
   return .f.
else
   ( xtemp )->(dbcommit())
   return .t.
endif

return .t.
**********************************
*
static function _filter_xtemp()
**********************************
   local nrecno := (xtemp)->(recno()),nntx := (xtemp)->(indexord())
   local cacctno,ddate,nrec2 := 0, nrec3 := 0,nrec4 := 0, cBRCODE
   memvar dstart,dend
   (xtemp)->(dbsetorder(4))   // clntcode+Acctno+dtos(Paydate)

   (xtemp)->(dbgotop())
   (xtemp)->(dbgotop())

   do while !(xtemp)->(eof())
      cacctno  := (xtemp)->acctno
      ddate    := ctod ('')
      nrec2    := (xtemp)->(recno())
      cBRCODE  := (xTEMP)->(BRCODE)

      do while !(xtemp)->(eof()) .and. (XTEMP)->BRCODE+(xtemp)->acctno  == cBRCODE+cacctno
         ddate := (xtemp)->paydate
         nrec3 := (xtemp)->(recno())
         (xtemp)->(dbskip(+1))
         nrec4 := (xtemp)->(recno())
      enddo

      if ddate < dstart .or. ddate > dend

         (xtemp)->(dbgoto(nrec3))
         (xtemp)->(dbdelete())

         if nrec2 == nrec3
            (xtemp)->(dbgoto(nrec4))
         else
            (xtemp)->(dbgoto(nrec2))

            if (xtemp)->(deleted())
               (xtemp)->(dbskip(-1))
               if (xtemp)->(bof())
                  (xtemp)->(dbgobottom())
                  (xtemp)->(dbskip(+1))
               endif
            endif

         endif
      endif

   enddo

   (xtemp)->(dbgoto(nrecno))
   (xtemp)->(dbsetorder(nntx))

   (xtemp)->(dbgotop())

return nil
/*------------------------------*/
Static Function fdata1114(xclient,prntcnt,cchoice,lallclients)
/*------------------------------*/
local mu:=savedbf(),re:=setcursor(),bf:=savescreen(,,,),gf:=setcolor(),xxx
local temp1 := substr(xtemp,1,7) +'1',temp2:=substr(xtemp,1,7) + '2'
local temp3 := substr(xtemp,1,7) +'3',temp4:=substr(xtemp,1,7) + '4',nprint:=' '
local pdate := xdate, prate := 0, pchoice := 0, menulist, xms, ppy, ttl
LOCAL xSTR

memvar nPREFBY

prntcnt := if(prntcnt == nil, 1, prntcnt)
swdue := .f.
if(cchoice == 1, setkey(K_ESC,NIL), setkey(K_F10,nil) )

dbselectarea ( xtemp )

(xtemp)->(dbsetorder(1))
if (xtemp)->(dbseek(1))
   do while .t.
      fShadow(15,33,18,72,2,'n/w')
      setcursor(1)
      set color to 'n/w','w/n',,,'w+/w'
      @ 16,35 say 'Penalty reference date  '
      @ 17,35 say '         Penalty rate      %'
      @ 16,61 get pdate  ;
              pict '@D'  ;
              valid  if ( ( pdate < xdate .or. ;
                            empty(pdate)       ;
                          ),;
                          eval ( { || error('Penalty Reference date should be ò Statement Date!'),;
                                      .f. ;
                                 };
                               ),;
                          .t. ;
                        )
      @ 17,61 get prate  ;
              pict '99'  ;
              when eval( { || prate:=g_PENRATE * 100, .t. } )  ;     // EVR 01052007 - changed from Parametr->PENRATE
              valid prate >= 0

      if ( cchoice == 1,;
           setkey ( K_ESC, {|| fescape('Abort?') }),;
           setkey ( K_F10, {|| f10escape('Abort this Client?') } ) ;
         )

      setcursor(3)
      read
      setcursor(0)

      prate := prate * .01
      if ( cchoice == 1      ,;
           setkey(K_ESC,NIL) ,;
           setkey(K_F10,nil)  ;
         )

      setcursor(re)

      if cchoice == 1
         if lastkey() == K_ESC .or. lastkey() == K_ENTER
            exit
         endif
      elseif cchoice == 2
          if lastkey() == K_F10 .or. lastkey() == K_ENTER
             exit
          endif
      endif

   enddo

   if cchoice == 1
      if lastkey() == K_ESC
         restdbf(mu)
         restscreen(,,,,bf)
         setcursor(re)
         setcolor(gf)
         return .f.
      endif
   elseif cchoice == 2
      if swdue       //lastkey() == K_F10
         restdbf(mu)
         restscreen(,,,,bf)
         setcursor(re)
         setcolor(gf)
         return .f. 
      endif
   endif

   IF TRUE_BRCH == '001'
      waiton ( 'Computing penalty..,please wait.',,'n*/w' )
      do while (xtemp)->(!eof())
			if (xtemp)->Penstat == 1 //.and. (xtemp)
				(xtemp)->Penalty := ( ( (xtemp)->amtdue ) * prate /30 ) * ( pdate - (xtemp)->Paydate )
         endif
          (xtemp)->(dbskip(+1))
      enddo
      waitoff ()
      (xtemp)->(dbcommit())
   ELSE
      xSTR := CHK_PAR(xTEMP)+CHK_PAR((xTEMP)->(RECNO()))+CHK_PAR(PRATE)+;
              CHK_PAR(PDATE)+CHK_PAR(TEMP1)+CHK_PAR(TEMP2)             +;
              CHK_PAR(TEMP3)+CHK_PAR(TEMP4)+CHK_PAR((xTEMP)->(DBSETORDER()))

      (xTEMP)->(DBCLOSEAREA())
      xTEMP := CPS_REQST(xSTR,'COMP_PEN')

      TEMP1 := g_AMS_PATH+'\'+substr(xTEMP,1,7) +'1'
      TEMP2 := g_AMS_PATH+'\'+substr(xTEMP,1,7) +'2'
      TEMP3 := g_AMS_PATH+'\'+substr(xTEMP,1,7) +'3'
      TEMP4 := g_AMS_PATH+'\'+substr(xTEMP,1,7) +'4'

      WHILE !NETUSE( g_AMS_PATH+'\'+xTEMP,.T.,10 ); ENDDO
      SET INDEX TO (TEMP1), (TEMP2), (TEMP3), (TEMP4)
   endif
endif

ppy := setkey( K_ESC )
ttl := setkey( K_F10 )

// if pval <> 0
// pval := 3

max2 := 1

if lallclients
   *prncontrol( 'prntso2()')    // call the printing routine (04/12/00) abb
   IF TRUE_BRCH <> '001'
      (xTEMP)->(DBCLOSEAREA())
   endif

   xSTR := CHK_PAR(xTEMP)+CHK_PAR(xDATE)+CHK_PAR(TEMP1)+;
           CHK_PAR(TEMP2)+CHK_PAR(TEMP3)+CHK_PAR(TEMP4)+CHK_PAR(nPREFBY)

   REPCON_OL( 'PRNTSO2()',,,,,, xSTR, .T.)

   IF TRUE_BRCH <> '001'

      TEMP1 := g_AMS_PATH+'\'+substr(xTEMP,1,7) +'1'
      TEMP2 := g_AMS_PATH+'\'+substr(xTEMP,1,7) +'2'
      TEMP3 := g_AMS_PATH+'\'+substr(xTEMP,1,7) +'3' 
      TEMP4 := g_AMS_PATH+'\'+substr(xTEMP,1,7) +'4'

      WHILE !NETUSE( g_AMS_PATH+'\'+xTEMP,.T.,10); ENDDO
      SET INDEX TO (TEMP1), (TEMP2), (TEMP3), (TEMP4)
   endif
else
	*reportprint('prntsoform()')
   prncontrol( 'prntsoform()')    // call the printing routine (04/12/00) abb
endif



setkey ( K_ESC,ppy )
setkey ( K_F10,ttl )
(xtemp)->(dbclosearea())
//ferase( xtemp + '.dbf' )
//ferase( temp1 + '.ntx' )
//ferase( temp2 + '.ntx' )
//ferase( temp3 + '.ntx' )
// pepe restdbf(mu);restscreen(,,,,bf);setcursor(re);setcolor(gf)
return nil

*********************************
*
function prntsoform()
*********************************
 local mu:=savedbf(),re:=setcursor(),bf:=savescreen(,,,),gf:=setcolor()
 local xacct,amrt_4:={},lcount:=0     // EVR 01052007 - removed lastprnt:=1, sanum:=Parametr->lastsa
 local tot_amort :=0,tot_pnlty := 0,grd_tot:=0,recst_:={},x,nrec
 local ac_set,nrent,cacctno := space(16) ,nswitch := 0,nsubtotal := 0
 local nrec2 := 0,lfound := .f.
 local cunit,npage  := 1
 local lunitprinted := .f.,lone_account := .f.,nlrec := 0,nlacctno := 0
 local termctr := 0
 //aga.13.09.2005.get name
 memvar nprefby 

 dbselectarea ( xtemp )
 (xtemp)->( dbsetorder(4) )   //aga.19.06.2007.from 2
 (xTEMP)->(DBGOTOP())                  && RED 070705
 setprc ( 0, 0 )

 // set length of paper to 9 inches (EPSON FX emulation)

 @ prow(), pcol() say chr(27) + chr(67) + chr(0) + chr(9)

 setfont('NLQ')
 setfont('ELITE')

 @ prow()+1,pcol() say ' '
 lochead()

 (xtemp)->(dbgotop())

  if !(xtemp)->(eof())

     ac_set := Acctmast->(indexord())
     Acctmast->(dbsetorder(1))

     Acctmast->( dbseek( (XTEMP)->BRCODE+(xtemp)->Acctno ) )

     nrent := Acctmast->Fcltycode
     cunit := Acctmast->unit

     nrent  := if( eval (  { || Facility->(dbseek(nrent))   ,;
                                Facility->Setcode ;
                           };
                        ) == '1' ,;
                        'Rental',;
                        'Amort.' ;
                     )

     Acctmast->(dbsetorder(ac_set))

     @ prow()+1, 0 say ' '
     tot_pnlty := 0

     do while !(xtemp)->(eof())
        cacctno   := (XTEMP)->BRCODE+(xtemp)->Acctno
        nswitch   := 0
        nsubtotal := 0
        termctr   := 0

        do while !(xtemp)->(eof()) .and. (XTEMP)->BRCODE+(xtemp)->acctno == cacctno

           if nswitch == 0 .and. prow() <= _MAXROW     // d' next 2 lines 'says' must be printed

                                 // once each account number only, abb0412200
                                 //

              nrec2  := (xtemp)->(recno())
              lfound := .f.
              do while !(xtemp)->(eof()) .and. (XTEMP)->BRCODE+(xtemp)->acctno == cacctno

                  if (xtemp)->penalty > 0
                      lfound := .t.
                  endif

                  (xtemp)->(dbskip(+1))
              enddo
              (xtemp)->(dbgoto(nrec2))

              if alltrim( (xtemp)->acctno ) != alltrim((xtemp)->Oldno)
                 @ prow()+1, 1 say right( alltrim((xtemp)->Acctno),5) + '/'+ padr( (xtemp)->Oldno,16 )
              else
                 @ prow()+1, 1 say right( alltrim((xtemp)->Acctno),5)
              endif

              @ prow()  ,23 say 'Unpaid Rental/Amortization Due'
  
              nswitch := 1
           endif

           if prow() >  _MAXROW
			footnote()
			/*  if Acctmast->revfreq <> '4'
				SETFONT('CONDENSED')
				@ prow()+1, 1 say 'Note : R.F. '+_get_rate_type(cacctno)
				@ prow()+1, 1 say '     : Please present this Statement of Account upon payment.'
				@ prow()+1, 1 say '     : Please disregard if payment has been made.'
				@ prow()+1, 1 say '     : Effective June 1, 2003, rentals/leases of personal properties under financial lease agreements are no longer'
				@ prow()+1, 1 say '       subject to 5% withholding tax per Sec. 2.5.7.2 of Rev. Reg. #17-2003 dated March 31, 2003.'
				@ prow()+1, 1 say '     : For over the counter payment to any Metrobank Branch, kindly use METROBANK PAYMENT SLIP which will ensure proper'
				@ prow()+1, 1 say '       posting of your payments. '// 06.26.13 BONG We have initially filled-out the attached payment slip for your guidance.'
		//		@ prow()+1, 1 say '       Please refer to BILLS PAYMENT GUIDELINE for the instructions in accomplishing the form.'
				SETFONT(UPPER('UNCONDENSD'))
			 else
				SETFONT('CONDENSED')
				@ prow()+1, 1 say 'Note : Please present this Statement of Account upon payment.'
				@ prow()+1, 1 say '     : Please disregard if payment has been made.'
				@ prow()+1, 1 say '     : Effective June 1, 2003, rentals/leases of personal properties under financial lease agreements are no longer'
				@ prow()+1, 1 say '       subject to 5% withholding tax per Sec. 2.5.7.2 of Rev. Reg. #17-2003 dated March 31, 2003.'
				@ prow()+1, 1 say '     : For over the counter payment to any Metrobank Branch, kindly use METROBANK PAYMENT SLIP which will ensure proper'
				@ prow()+1, 1 say '       posting of your payments. '// 06.26.13 BONG We have initially filled-out the attached payment slip for your guidance.'
		//		@ prow()+1, 1 say '       Please refer to BILLS PAYMENT GUIDELINE for the instructions in accomplishing the form.'
				SETFONT(UPPER('UNCONDENSD'))
          endif
 */
              //aga.13.09.2005.authorized sig name
              @ prow()+5  ,57 say nprefby

              npage++
              __eject()
              @ prow()+1,pcol() say ' '
              lochead()
			  @ prow()+1,pcol() say ' '
			  @ prow()+1,pcol() say ' '

           endif


           //if lfound
           //   @ prow()+1, 23-9 say _get_remterm(cacctno,paydate,termctr)+' '+dtoc(paydate)
           //else
           //   @ prow()+1, 23-9 say _get_remterm(cacctno,paydate,termctr)+' '+dtoc(paydate)
           //endif

           //aga.16.08.2007.xtemp paydate source
           @ prow()+1, 23-9 say _get_remterm(cacctno,(xtemp)->paydate,termctr) + ' ' + dtoc((xtemp)->paydate) 

           termctr ++

           @ prow()  , pcol()+1  say tran ( (xtemp)->amtdue,'999,999,999.99')
                         
           if prow() > _MAXROW
			footnote()
		/* 	 if Acctmast->revfreq <> '4'
				SETFONT('CONDENSED')
				@ prow()+1, 1 say 'Note : R.F. '+_get_rate_type(cacctno)
				@ prow()+1, 1 say '     : Please present this Statement of Account upon payment.'
				@ prow()+1, 1 say '     : Please disregard if payment has been made.'
				@ prow()+1, 1 say '     : Effective June 1, 2003, rentals/leases of personal properties under financial lease agreements are no longer'
				@ prow()+1, 1 say '       subject to 5% withholding tax per Sec. 2.5.7.2 of Rev. Reg. #17-2003 dated March 31, 2003.'
				@ prow()+1, 1 say '     : For over the counter payment to any Metrobank Branch, kindly use METROBANK PAYMENT SLIP which will ensure proper'
				@ prow()+1, 1 say '       posting of your payments. '// 06.26.13 BONG We have initially filled-out the attached payment slip for your guidance.'
		//		@ prow()+1, 1 say '       Please refer to BILLS PAYMENT GUIDELINE for the instructions in accomplishing the form.'
				SETFONT(UPPER('UNCONDENSD'))
			 else
				SETFONT('CONDENSED')
				@ prow()+1, 1 say 'Note : Please present this Statement of Account upon payment.'
				@ prow()+1, 1 say '     : Please disregard if payment has been made.'
				@ prow()+1, 1 say '     : Effective June 1, 2003, rentals/leases of personal properties under financial lease agreements are no longer'
				@ prow()+1, 1 say '       subject to 5% withholding tax per Sec. 2.5.7.2 of Rev. Reg. #17-2003 dated March 31, 2003.'
				@ prow()+1, 1 say '     : For over the counter payment to any Metrobank Branch, kindly use METROBANK PAYMENT SLIP which will ensure proper'
				@ prow()+1, 1 say '       posting of your payments. '// 06.26.13 BONG We have initially filled-out the attached payment slip for your guidance.'
		//		@ prow()+1, 1 say '       Please refer to BILLS PAYMENT GUIDELINE for the instructions in accomplishing the form.'
				SETFONT(UPPER('UNCONDENSD'))
          endif */


              //aga.13.09.2005.authorized sig name
              @ prow()+5  ,57 say nprefby

              npage++
              __eject ()
              @ prow()+1,pcol() say ' '
              lochead ()
			  @ prow()+1,pcol() say ' '
			  @ prow()+1,pcol() say ' '
              // noels - add new line?
           endif

           if (xtemp)->Penalty  > 0
              @ prow() , 48 say tran ( round((xtemp)->Penalty,0)  ,'9,999,999.99' )
              tot_pnlty += round((xtemp)->Penalty,0)
           else
              @ prow() , 48 say space(12)
           endif
           
           if lfound
              @ prow()  , pcol()+2 say tran ( (xtemp)->amtdue+round((xtemp)->penalty,0),'999,999,999.99')
           else
              @ prow()  , pcol()+2 say tran ( (xtemp)->amtdue,'999,999,999.99')
           endif

           nsubtotal += (xtemp)->amtdue + round((xtemp)->Penalty,0)
           grd_tot   += (xtemp)->amtdue + round((xtemp)->Penalty,0)


           lunitprinted := .f.
           if _one_acct_per_page( (XTEMP)->BRCODE+(xtemp)->acctno )    // 07/12/2000 ( abb )

              nlrec    := (xtemp)->(recno())
              nlacctno := (XTEMP)->BRCODE+(xtemp)->acctno
              (xtemp)->(dbskip(+1))

              if (XTEMP)->BRCODE+(xtemp)->acctno != nlacctno // .and. !(xtemp)->(eof())

                 (xtemp)->(dbgoto(nlrec))

                 lunitprinted := .t.
                 lone_account := .t.

                 @ prow()+1,23   say padr( _get_unit( cacctno),38 )
                 @ prow()  ,62   say repl('-',15)
                              

                 if tot_pnlty > 0
                    @ prow()+1,29 say 'Total Penalties '
                    @ prow()  ,60 say 'P ' + tran( round(tot_pnlty,0) ,'999,999,999.99')
                    @ prow()+1,62 say repl('-',15)
                    tot_pnlty := 0
                 endif

                 @ prow()+1,29    say 'TOTAL AMOUNT DUE'
                 @ prow()  ,60    say 'P ' + tran(grd_tot,'999,999,999.99')
                 @ prow()+1,62    say repl('=',15)
                 grd_tot := 0
				 footnote()
				 /* if Acctmast->revfreq <> '4'
					SETFONT('CONDENSED')
					@ prow()+1, 1 say 'Note : R.F. '+_get_rate_type(cacctno)
					@ prow()+1, 1 say '     : Please present this Statement of Account upon payment.'
					@ prow()+1, 1 say '     : Please disregard if payment has been made.'
					@ prow()+1, 1 say '     : Effective June 1, 2003, rentals/leases of personal properties under financial lease agreements are no longer'
					@ prow()+1, 1 say '       subject to 5% withholding tax per Sec. 2.5.7.2 of Rev. Reg. #17-2003 dated March 31, 2003.'
					@ prow()+1, 1 say '     : For over the counter payment to any Metrobank Branch, kindly use METROBANK PAYMENT SLIP which will ensure proper'
					@ prow()+1, 1 say '       posting of your payments. '// 06.26.13 BONG We have initially filled-out the attached payment slip for your guidance.'
			//		@ prow()+1, 1 say '       Please refer to BILLS PAYMENT GUIDELINE for the instructions in accomplishing the form.'
					SETFONT(UPPER('UNCONDENSD'))
				 else
					SETFONT('CONDENSED')
					@ prow()+1, 1 say 'Note : Please present this Statement of Account upon payment.'
					@ prow()+1, 1 say '     : Please disregard if payment has been made.'
					@ prow()+1, 1 say '     : Effective June 1, 2003, rentals/leases of personal properties under financial lease agreements are no longer'
					@ prow()+1, 1 say '       subject to 5% withholding tax per Sec. 2.5.7.2 of Rev. Reg. #17-2003 dated March 31, 2003.'
					@ prow()+1, 1 say '     : For over the counter payment to any Metrobank Branch, kindly use METROBANK PAYMENT SLIP which will ensure proper'
					@ prow()+1, 1 say '       posting of your payments. '// 06.26.13 BONG We have initially filled-out the attached payment slip for your guidance.'
			//		@ prow()+1, 1 say '       Please refer to BILLS PAYMENT GUIDELINE for the instructions in accomplishing the form.'
					SETFONT(UPPER('UNCONDENSD'))
             endif */


                 //aga.13.09.2005.authorized sig name
                 @ prow()+5  ,57 say nprefby

                 nlrec := (xtemp)->(recno())
                 (xtemp)->(dbskip(+1))
                 if !(xtemp)->(eof())
                    (xtemp)->(dbgoto(nlrec))

                    npage++
                    __eject ()
                    @ prow()+1,pcol() say ' '
                    lochead()
					@ prow()+1,pcol() say ' '
					@ prow()+1,pcol() say ' '

                 else
                    (xtemp)->(dbgoto(nlrec))
                 endif

              else
                 (xtemp)->(dbgoto(nlrec))
              endif

           endif

           (xtemp)->(dbskip(+1))

        enddo

        if !lone_account

           if prow() > _MAXROW
			 footnote()
			 /* if Acctmast->revfreq <> '4'
				SETFONT('CONDENSED')
				@ prow()+1, 1 say 'Note : R.F. '+_get_rate_type(cacctno)
				@ prow()+1, 1 say '     : Please present this Statement of Account upon payment.'
				@ prow()+1, 1 say '     : Please disregard if payment has been made.'
				@ prow()+1, 1 say '     : Effective June 1, 2003, rentals/leases of personal properties under financial lease agreements are no longer'
				@ prow()+1, 1 say '       subject to 5% withholding tax per Sec. 2.5.7.2 of Rev. Reg. #17-2003 dated March 31, 2003.'
				@ prow()+1, 1 say '     : For over the counter payment to any Metrobank Branch, kindly use METROBANK PAYMENT SLIP which will ensure proper'
				@ prow()+1, 1 say '       posting of your payments. '// 06.26.13 BONG We have initially filled-out the attached payment slip for your guidance.'
		//		@ prow()+1, 1 say '       Please refer to BILLS PAYMENT GUIDELINE for the instructions in accomplishing the form.'
				SETFONT(UPPER('UNCONDENSD'))
			 else
				SETFONT('CONDENSED')
				@ prow()+1, 1 say 'Note : Please present this Statement of Account upon payment.'
				@ prow()+1, 1 say '     : Please disregard if payment has been made.'
				@ prow()+1, 1 say '     : Effective June 1, 2003, rentals/leases of personal properties under financial lease agreements are no longer'
				@ prow()+1, 1 say '       subject to 5% withholding tax per Sec. 2.5.7.2 of Rev. Reg. #17-2003 dated March 31, 2003.'
				@ prow()+1, 1 say '     : For over the counter payment to any Metrobank Branch, kindly use METROBANK PAYMENT SLIP which will ensure proper'
				@ prow()+1, 1 say '       posting of your payments. '// 06.26.13 BONG We have initially filled-out the attached payment slip for your guidance.'
		//		@ prow()+1, 1 say '       Please refer to BILLS PAYMENT GUIDELINE for the instructions in accomplishing the form.'
				SETFONT(UPPER('UNCONDENSD'))
          endif */


              //aga.13.09.2005.authorized sig name
              @ prow()+5  ,57 say nprefby

              npage++
              __eject()
              @ prow()+1,pcol() say ' '
              lochead()
			  @ prow()+1,pcol() say ' '
			  @ prow()+1,pcol() say ' '

              // noels - add new line?
           endif

        endif

        if !lunitprinted
           @ prow()+1,23   say padr( _get_unit( cacctno),38 )
           @ prow()  ,62   say repl('-',15)
                              
        endif

     enddo

  endif


  if !lone_account

     if tot_pnlty > 0
        @ prow()+1,29 say 'Total Penalties '
        @ prow()  ,60   say 'P ' + tran( round(tot_pnlty,0) ,'999,999,999.99')
        @ prow()+1,62   say repl('-',15)
     endif

     @ prow()+1,29   say 'TOTAL AMOUNT DUE'
     @ prow()  ,60   say 'P ' + tran(grd_tot,'999,999,999.99')
     @ prow()+1,62   say repl('=',15)
	 footnote()
     /* if Acctmast->revfreq <> '4'
	 	SETFONT('CONDENSED')
        @ prow()+1, 1 say 'Note : R.F. '+_get_rate_type(cacctno)
        @ prow()+1, 1 say '     : Please present this Statement of Account upon payment.'
        @ prow()+1, 1 say '     : Please disregard if payment has been made.'
        @ prow()+1, 1 say '     : Effective June 1, 2003, rentals/leases of personal properties under financial lease agreements are no longer'
        @ prow()+1, 1 say '       subject to 5% withholding tax per Sec. 2.5.7.2 of Rev. Reg. #17-2003 dated March 31, 2003.'
        @ prow()+1, 1 say '     : For over the counter payment to any Metrobank Branch, kindly use METROBANK PAYMENT SLIP which will ensure proper'
        @ prow()+1, 1 say '       posting of your payments. '// 06.26.13 BONG We have initially filled-out the attached payment slip for your guidance.'
    //    @ prow()+1, 1 say '       Please refer to BILLS PAYMENT GUIDELINE for the instructions in accomplishing the form.'
		SETFONT(UPPER('UNCONDENSD'))
     else
	 	SETFONT('CONDENSED')
        @ prow()+1, 1 say 'Note : Please present this Statement of Account upon payment.'
        @ prow()+1, 1 say '     : Please disregard if payment has been made.'
        @ prow()+1, 1 say '     : Effective June 1, 2003, rentals/leases of personal properties under financial lease agreements are no longer'
        @ prow()+1, 1 say '       subject to 5% withholding tax per Sec. 2.5.7.2 of Rev. Reg. #17-2003 dated March 31, 2003.'
        @ prow()+1, 1 say '     : For over the counter payment to any Metrobank Branch, kindly use METROBANK PAYMENT SLIP which will ensure proper'
        @ prow()+1, 1 say '       posting of your payments. '// 06.26.13 BONG We have initially filled-out the attached payment slip for your guidance.'
   //     @ prow()+1, 1 say '       Please refer to BILLS PAYMENT GUIDELINE for the instructions in accomplishing the form.'
		SETFONT(UPPER('UNCONDENSD'))
     endif */


     //aga.13.09.2005.authorized sig name

     @ prow()+5  ,57 say nprefby

  endif

  __eject()

// EVR xlastsa := sanum + lastprnt
  setfont("NORMAL")
  restdbf(mu);restscreen(,,,,bf);setcursor(re);setcolor(gf)

return nil
**************************
static function footnote()
**************************
/* SETFONT('CONDENSED')
        @ prow()+1, 1 say 'Note : Please present this Statement of Account upon payment '
        @ prow()+1, 1 say '     : Please disregard if payment has been made.'
        @ prow()+1, 1 say '     : Effective June 1, 2003, rentals/leases of personal properties under financial lease agreements are no longer'
        @ prow()+1, 1 say '       subject to 5% withholding tax per Sec. 2.5.7.2 of Rev. Reg. #17-2003 dated March 31, 2003.'
        @ prow()+1, 1 say '     : For over the counter payment to any Metrobank Branch, kindly use METROBANK PAYMENT SLIP which will ensure proper'
        @ prow()+1, 1 say '       posting of your payments. '// 06.26.13 BONG We have initially filled-out the attached payment slip for your guidance.'
   //     @ prow()+1, 1 say '       Please refer to BILLS PAYMENT GUIDELINE for the instructions in accomplishing the form.'
		SETFONT(UPPER('UNCONDENSD')) */
SETFONT('CONDENSED')
		@       32, 1 say 'Note : Please present this Statement of Account upon payment or kindly disregard if payment has been made.'
		@ prow()+1, 1 say '     : Effective june 1, 2003 rental/leases of personal properties under financial lease agreement are no longer'
		@ prow()+1, 1 say '       subject to 5% withholding tax per Sec. 2.5.7 of Rev. Reg. # 17-2003 dated March 31, 2003.'
		setfont('BOLD')
		SETFONT(UPPER('UNCONDENSD'))
		@ prow()+2, 1 say chr(27)+chr(52)+'   : For Metrobank depositors you may pay thru internet banking via'
		@ prow()+1, 1 say '     METROBANK DIRECT FACILITY. You may visit www.metrobank.com.ph' 
		@ prow()+1, 1 say '     for details.'+chr(27)+chr(53)       
		SETFONT('CONDENSED')
		setfont('UNBOLD')
		@ prow()+2, 1 say '     : For non-Metrobank depositors, you may pay over the counter at any Metrobank branch by using METROBANK'
		@ prow()+1, 1 say '       PAYMENT SLIP.'
		@ prow()+1, 1 say "     : Payments made after the 12:00 noon cut-off shall be considered next day's payment"
SETFONT(UPPER('UNCONDENSD'))
return nil

*********************************
*
*      all clients ( 04/13/2000 )
*
function prntso2()
*********************************
 local mu:=savedbf(),re:=setcursor(),bf:=savescreen(,,,),gf:=setcolor()
 local xacct,amrt_4:={},lcount:=0     // EVR 01052007 - removed lastprnt:=1, sanum:=Parametr->lastsa
 local tot_amort :=0,tot_pnlty := 0,grd_tot:=0,recst_:={},x,nrec
 local ac_set,nrent,cacctno := space(16) ,nswitch := 0,nsubtotal := 0,cclntcode
 local _nntx := Client->(indexord()), _nrecno := Client->(recno())
 local nrec2 := 0, lfound := .f.
 local cunit,npage := 1
 local lunitprinted := .f.,lone_account := .f.,nlrec := 0,nlacctno := 0,cclnt2
 local termctr := 0

 //aga.13.09.2005.get name
 memvar nprefby 

 Client->(dbsetorder(1))            // clntcode

 dbselectarea ( xtemp )
 (xtemp)->( dbsetorder(4) )

 setprc   ( 0, 0 )

 // set length of paper to 9 inches (EPSON FX emulation)

 @ prow(), pcol() say chr(27) + chr(67) + chr(0) + chr(9)
 setfont  ( 'NLQ' )
 setfont  ( 'ELITE' )

 (xtemp)->(dbgotop())

  if !(xtemp)->(eof())

     do while !(xtemp)->(eof())

        *IF (xTEMP)->BRCODE == g_PAR_BRCH

           @ prow()+1, 0 say ' '
           lochead2((XTEMP)->BRCODE+(xtemp)->clntcode)

           cclntcode := (XTEMP)->BRCODE+(xtemp)->clntcode
           grd_tot   := 0
           tot_pnlty := 0
		   
           do while !(xtemp)->(eof()) .and. (XTEMP)->BRCODE+(xtemp)->clntcode == cclntcode

               ac_set := Acctmast->(indexord())
               Acctmast->(dbsetorder(1))
               nrent  := eval ({|| Acctmast->(dbseek( (XTEMP)->BRCODE+(xtemp)->Acctno )),;
                                   Acctmast->Fcltycode ;
                              })

               cunit  := Acctmast->unit
               nrent  := if( eval ({|| Facility->(dbseek(nrent))   ,;
                                          Facility->Setcode ;
                                   };
                                  ) == '1' ,;
                                  'Rental' ,;
                                  'Amort.'  ;
                               )

               Acctmast->(dbsetorder(ac_set))

               @ prow()+1, 0 say ' '

               cacctno   := (XTEMP)->BRCODE+(xtemp)->Acctno
               nswitch   := 0
               nsubtotal := 0
               termctr   := 0

               lone_account := .f.
               lunitprinted := .f.

               do while !(xtemp)->(eof())             .and. ;
                         (XTEMP)->BRCODE+(xtemp)->acctno   == cacctno .and. ;
                         (XTEMP)->BRCODE+(xtemp)->clntcode == cclntcode

                  if nswitch == 0 .and. prow() <= _MAXROW

                     nrec2  := (xtemp)->(recno())
                     lfound := .f.
                     do while !(xtemp)->(eof()) .and. (XTEMP)->BRCODE+(xtemp)->acctno == cacctno

                        if (xtemp)->penalty > 0
                            lfound := .t.
                        endif

                        (xtemp)->(dbskip(+1))
                     enddo
                     (xtemp)->(dbgoto(nrec2))

                     if alltrim( (xtemp)->acctno ) != alltrim((xtemp)->Oldno)
                        @ prow()+1, 1 say right( alltrim((xtemp)->Acctno),5) + '/'+ padr( (xtemp)->Oldno,16 )
                     else
                        @ prow()+1, 1 say right( alltrim((xtemp)->Acctno),5)
                     endif

                     @ prow(), 23 say 'Unpaid Rental/Amortization Due'
                      
                     nswitch := 1

                  endif

                  if prow() > _MAXROW
					footnote()
					 /* if Acctmast->revfreq <> '4'
						SETFONT('CONDENSED')
						@ prow()+1, 1 say 'Note : R.F. '+_get_rate_type(cacctno)
						@ prow()+1, 1 say '     : Please present this Statement of Account upon payment.'
						@ prow()+1, 1 say '     : Please disregard if payment has been made.'
						@ prow()+1, 1 say '     : Effective June 1, 2003, rentals/leases of personal properties under financial lease agreements are no longer'
						@ prow()+1, 1 say '       subject to 5% withholding tax per Sec. 2.5.7.2 of Rev. Reg. #17-2003 dated March 31, 2003.'
						@ prow()+1, 1 say '     : For over the counter payment to any Metrobank Branch, kindly use METROBANK PAYMENT SLIP which will ensure proper'
						@ prow()+1, 1 say '       posting of your payments. '// 06.26.13 BONG We have initially filled-out the attached payment slip for your guidance.'
				//		@ prow()+1, 1 say '       Please refer to BILLS PAYMENT GUIDELINE for the instructions in accomplishing the form.'
						SETFONT(UPPER('UNCONDENSD'))
					 else
						SETFONT('CONDENSED')
						@ prow()+1, 1 say 'Note : Please present this Statement of Account upon payment.'
						@ prow()+1, 1 say '     : Please disregard if payment has been made.'
						@ prow()+1, 1 say '     : Effective June 1, 2003, rentals/leases of personal properties under financial lease agreements are no longer'
						@ prow()+1, 1 say '       subject to 5% withholding tax per Sec. 2.5.7.2 of Rev. Reg. #17-2003 dated March 31, 2003.'
						@ prow()+1, 1 say '     : For over the counter payment to any Metrobank Branch, kindly use METROBANK PAYMENT SLIP which will ensure proper'
						@ prow()+1, 1 say '       posting of your payments. '// 06.26.13 BONG We have initially filled-out the attached payment slip for your guidance.'
				//		@ prow()+1, 1 say '       Please refer to BILLS PAYMENT GUIDELINE for the instructions in accomplishing the form.'
						SETFONT(UPPER('UNCONDENSD'))
                endif */

                     //aga.13.09.2005.authorized sig name
                     @ prow()+4  ,57 say nprefby
                     __eject ()
					 setprc( 0, 0 )
                     npage++	
                      @ prow()+1, 0 say ''
                     lochead2((XTEMP)->BRCODE+(xtemp)->clntcode)

                     @ prow()+1, 0 say ' '    // noels - to adjust next page's details
                  endif

                  if lfound

                     if prow() > _MAXROW
						footnote()
						/*  if Acctmast->revfreq <> '4'
							SETFONT('CONDENSED')
							@ prow()+1, 1 say 'Note : R.F. '+_get_rate_type(cacctno)
							@ prow()+1, 1 say '     : Please present this Statement of Account upon payment.'
							@ prow()+1, 1 say '     : Please disregard if payment has been made.'
							@ prow()+1, 1 say '     : Effective June 1, 2003, rentals/leases of personal properties under financial lease agreements are no longer'
							@ prow()+1, 1 say '       subject to 5% withholding tax per Sec. 2.5.7.2 of Rev. Reg. #17-2003 dated March 31, 2003.'
							@ prow()+1, 1 say '     : For over the counter payment to any Metrobank Branch, kindly use METROBANK PAYMENT SLIP which will ensure proper'
							@ prow()+1, 1 say '       posting of your payments. '// 06.26.13 BONG We have initially filled-out the attached payment slip for your guidance.'
					//		@ prow()+1, 1 say '       Please refer to BILLS PAYMENT GUIDELINE for the instructions in accomplishing the form.'
							SETFONT(UPPER('UNCONDENSD'))
						 else
							SETFONT('CONDENSED')
							@ prow()+1, 1 say 'Note : Please present this Statement of Account upon payment.'
							@ prow()+1, 1 say '     : Please disregard if payment has been made.'
							@ prow()+1, 1 say '     : Effective June 1, 2003, rentals/leases of personal properties under financial lease agreements are no longer'
							@ prow()+1, 1 say '       subject to 5% withholding tax per Sec. 2.5.7.2 of Rev. Reg. #17-2003 dated March 31, 2003.'
							@ prow()+1, 1 say '     : For over the counter payment to any Metrobank Branch, kindly use METROBANK PAYMENT SLIP which will ensure proper'
							@ prow()+1, 1 say '       posting of your payments. '// 06.26.13 BONG We have initially filled-out the attached payment slip for your guidance.'
					//		@ prow()+1, 1 say '       Please refer to BILLS PAYMENT GUIDELINE for the instructions in accomplishing the form.'
							SETFONT(UPPER('UNCONDENSD'))
                   endif */

                        //aga.13.09.2005.authorized sig name
                        @ prow()+4  ,57 say nprefby
                        __eject ()
						setprc( 0, 0 )
                        npage++
                         @ prow()+1, 0 say ' '
                        lochead2((XTEMP)->BRCODE+(xtemp)->clntcode)
						 @ prow()+1, 0 say ' '
                        // noels - add new line?
                     endif

                     //aga.16.08.2007.xtemp paydate source
                     @ prow()+1, 23-9 say _get_remterm(cacctno,(xtemp)->paydate,termctr) + ' ' + dtoc((xtemp)->paydate)

                     termctr ++
                      
                  else

                     if prow() > _MAXROW
						footnote()
						/*  if Acctmast->revfreq <> '4'
							SETFONT('CONDENSED')
							@ prow()+1, 1 say 'Note : R.F. '+_get_rate_type(cacctno)
							@ prow()+1, 1 say '     : Please present this Statement of Account upon payment.'
							@ prow()+1, 1 say '     : Please disregard if payment has been made.'
							@ prow()+1, 1 say '     : Effective June 1, 2003, rentals/leases of personal properties under financial lease agreements are no longer'
							@ prow()+1, 1 say '       subject to 5% withholding tax per Sec. 2.5.7.2 of Rev. Reg. #17-2003 dated March 31, 2003.'
							@ prow()+1, 1 say '     : For over the counter payment to any Metrobank Branch, kindly use METROBANK PAYMENT SLIP which will ensure proper'
							@ prow()+1, 1 say '       posting of your payments. '// 06.26.13 BONG We have initially filled-out the attached payment slip for your guidance.'
					//		@ prow()+1, 1 say '       Please refer to BILLS PAYMENT GUIDELINE for the instructions in accomplishing the form.'
							SETFONT(UPPER('UNCONDENSD'))
						 else
							SETFONT('CONDENSED')
							@ prow()+1, 1 say 'Note : Please present this Statement of Account upon payment.'
							@ prow()+1, 1 say '     : Please disregard if payment has been made.'
							@ prow()+1, 1 say '     : Effective June 1, 2003, rentals/leases of personal properties under financial lease agreements are no longer'
							@ prow()+1, 1 say '       subject to 5% withholding tax per Sec. 2.5.7.2 of Rev. Reg. #17-2003 dated March 31, 2003.'
							@ prow()+1, 1 say '     : For over the counter payment to any Metrobank Branch, kindly use METROBANK PAYMENT SLIP which will ensure proper'
							@ prow()+1, 1 say '       posting of your payments. '// 06.26.13 BONG We have initially filled-out the attached payment slip for your guidance.'
					//		@ prow()+1, 1 say '       Please refer to BILLS PAYMENT GUIDELINE for the instructions in accomplishing the form.'
							SETFONT(UPPER('UNCONDENSD'))
                   endif */

                        //aga.13.09.2005.authorized sig name
                        @ prow()+4  ,57 say nprefby
                        __eject  ()
						setprc( 0, 0 )
                        npage++
                         @ prow  ()+1, 0 say ' '
                        lochead2((XTEMP)->BRCODE+(xtemp)->clntcode)
						 @ prow()+1, 0 say ' '
                        // noels - add new line?

                     endif
 
                     //aga.16.08.2007.xtemp paydate source                          
                     @ prow()+1, 23-9 say _get_remterm(cacctno,(xtemp)->paydate,termctr) + ' ' + dtoc((xtemp)->paydate)

                     termctr ++
                    
                  endif

                  @ prow()  , pcol()+1  say tran ( (xtemp)->amtdue,'999,999,999.99')

                  if (xtemp)->Penalty  > 0
                    @ prow() , 48 say tran ( round( (xtemp)->Penalty,0)  ,'9,999,999.99' )
                    tot_pnlty += round((xtemp)->Penalty,0)
                  else
                    @ prow() , 48 say space(12)
                  endif

                  if lfound
                     @ prow()  , pcol()+1 say tran ( (xtemp)->amtdue+round((xtemp)->penalty,0),'999,999,999.99')
                  else
                     @ prow()  , pcol()+1 say tran ( (xtemp)->amtdue,'999,999,999.99')
                  endif

                  nsubtotal += (xtemp)->amtdue + round((xtemp)->Penalty,0)
                  grd_tot   += (xtemp)->amtdue + round((xtemp)->Penalty,0)

                 lunitprinted := .f.
                 if _one_acct_per_page( (XTEMP)->BRCODE+(xtemp)->acctno )    // 07/12/2000 ( abb )

                    nlrec    := (xtemp)->(recno())
                    nlacctno := (XTEMP)->BRCODE+(xtemp)->acctno
                    (xtemp)->(dbskip(+1))

                    if (XTEMP)->BRCODE+(xtemp)->acctno != nlacctno // .and. !(xtemp)->(eof())

                       (xtemp)->(dbgoto(nlrec))

                       lunitprinted := .t.
                       lone_account := .t.

                       @ prow()+1,23   say padr( _get_unit( cacctno),38 )
                       @ prow()  ,62   say repl('-',15)
                        

                       if tot_pnlty > 0
                          @ prow()+1,29 say 'Total Penalties '
                          @ prow()  ,60 say 'P ' + tran( round(tot_pnlty,0) ,'999,999,999.99')
                          @ prow()+1,62 say repl('-',15)
                          tot_pnlty := 0
                           
                       endif

                       @ prow()+1,29    say 'TOTAL AMOUNT DUE'
                       @ prow()  ,60    say 'P ' + tran(grd_tot,'999,999,999.99')
                       @ prow()+1,62    say repl('=',15)
                       grd_tot := 0
                        
						footnote()
						/*  if Acctmast->revfreq <> '4'
							SETFONT('CONDENSED')
							@ prow()+1, 1 say 'Note : R.F. '+_get_rate_type(cacctno)
							@ prow()+1, 1 say '     : Please present this Statement of Account upon payment.'
							@ prow()+1, 1 say '     : Please disregard if payment has been made.'
							@ prow()+1, 1 say '     : Effective June 1, 2003, rentals/leases of personal properties under financial lease agreements are no longer'
							@ prow()+1, 1 say '       subject to 5% withholding tax per Sec. 2.5.7.2 of Rev. Reg. #17-2003 dated March 31, 2003.'
							@ prow()+1, 1 say '     : For over the counter payment to any Metrobank Branch, kindly use METROBANK PAYMENT SLIP which will ensure proper'
							@ prow()+1, 1 say '       posting of your payments. '// 06.26.13 BONG We have initially filled-out the attached payment slip for your guidance.'
					//		@ prow()+1, 1 say '       Please refer to BILLS PAYMENT GUIDELINE for the instructions in accomplishing the form.'
							SETFONT(UPPER('UNCONDENSD'))
						 else
							SETFONT('CONDENSED')
							@ prow()+1, 1 say 'Note : Please present this Statement of Account upon payment.'
							@ prow()+1, 1 say '     : Please disregard if payment has been made.'
							@ prow()+1, 1 say '     : Effective June 1, 2003, rentals/leases of personal properties under financial lease agreements are no longer'
							@ prow()+1, 1 say '       subject to 5% withholding tax per Sec. 2.5.7.2 of Rev. Reg. #17-2003 dated March 31, 2003.'
							@ prow()+1, 1 say '     : For over the counter payment to any Metrobank Branch, kindly use METROBANK PAYMENT SLIP which will ensure proper'
							@ prow()+1, 1 say '       posting of your payments. '// 06.26.13 BONG We have initially filled-out the attached payment slip for your guidance.'
					//		@ prow()+1, 1 say '       Please refer to BILLS PAYMENT GUIDELINE for the instructions in accomplishing the form.'
							SETFONT(UPPER('UNCONDENSD'))
                   endif */

                       //aga.13.09.2005.authorized sig name
                       @ prow()+4  ,57 say nprefby
                        __eject  ()
						setprc( 0, 0 )
                        npage++
                         @ prow  ()+1, 0 say ' '
                        lochead2((XTEMP)->BRCODE+(xtemp)->clntcode)
						 @ prow()+1, 0 say ' '

/*                        nlrec  := (xtemp)->(recno())
                       cclnt2 := (XTEMP)->BRCODE+(xtemp)->clntcode
                       (xtemp)->(dbskip(+1))
                       if !(xtemp)->(eof())

                          if (XTEMP)->BRCODE+(xtemp)->clntcode == cclnt2
                             npage++
                             __eject()
                             @ prow()+1,pcol() say ' '
                             lochead2((XTEMP)->BRCODE+(xtemp)->clntcode)
							 @ prow()+1, 0 say ' '
                          else
                             npage := 1
                             __eject()
                          endif

                          (xtemp)->(dbgoto(nlrec))

                       else
                          (xtemp)->(dbgoto(nlrec))
                       endif */

                    else
                       (xtemp)->(dbgoto(nlrec))
                    endif

                 endif

                 (xtemp)->(dbskip(+1))

               enddo // !(xtemp)->(eof()) .and. (xtemp)->acctno == cacctno

               if !lunitprinted
                  @ prow()+1,23   say padr( _get_unit( cacctno),38 )
                  @ prow()  ,62   say repl('-',15) 
               endif

               if !lone_account

                  if prow() > _MAXROW         // added by ariel ( 06/28/2000 )
						footnote()
						/*  if Acctmast->revfreq <> '4'
							SETFONT('CONDENSED')
							@ prow()+1, 1 say 'Note : R.F. '+_get_rate_type(cacctno)
							@ prow()+1, 1 say '     : Please present this Statement of Account upon payment.'
							@ prow()+1, 1 say '     : Please disregard if payment has been made.'
							@ prow()+1, 1 say '     : Effective June 1, 2003, rentals/leases of personal properties under financial lease agreements are no longer'
							@ prow()+1, 1 say '       subject to 5% withholding tax per Sec. 2.5.7.2 of Rev. Reg. #17-2003 dated March 31, 2003.'
							@ prow()+1, 1 say '     : For over the counter payment to any Metrobank Branch, kindly use METROBANK PAYMENT SLIP which will ensure proper'
							@ prow()+1, 1 say '       posting of your payments. '// 06.26.13 BONG We have initially filled-out the attached payment slip for your guidance.'
					//		@ prow()+1, 1 say '       Please refer to BILLS PAYMENT GUIDELINE for the instructions in accomplishing the form.'
							SETFONT(UPPER('UNCONDENSD'))
						 else
							SETFONT('CONDENSED')
							@ prow()+1, 1 say 'Note : Please present this Statement of Account upon payment.'
							@ prow()+1, 1 say '     : Please disregard if payment has been made.'
							@ prow()+1, 1 say '     : Effective June 1, 2003, rentals/leases of personal properties under financial lease agreements are no longer'
							@ prow()+1, 1 say '       subject to 5% withholding tax per Sec. 2.5.7.2 of Rev. Reg. #17-2003 dated March 31, 2003.'
							@ prow()+1, 1 say '     : For over the counter payment to any Metrobank Branch, kindly use METROBANK PAYMENT SLIP which will ensure proper'
							@ prow()+1, 1 say '       posting of your payments. '// 06.26.13 BONG We have initially filled-out the attached payment slip for your guidance.'
							@ prow()+1, 1 say '       Please refer to BILLS PAYMENT GUIDELINE for the instructions in accomplishing the form.'
					//		SETFONT(UPPER('UNCONDENSD'))
                   endif */

                     //aga.13.09.2005.authorized sig name
                     @ prow()+4  ,57 say nprefby

                     npage++
                     __eject  ()
					 setprc( 0, 0 )
                      @ prow()+1, 0 say ' '
                     lochead2((XTEMP)->BRCODE+(xtemp)->clntcode)
					  @ prow()+1, 0 say ' '
                     // noels - add new line?
                  endif

               endif

             //  if !lunitprinted
             //     @ prow()+1,62   say repl('-',15)
                   
             //  endif

               if !lone_account

                  if prow() > _MAXROW
						footnote()
						/*  if Acctmast->revfreq <> '4'
							SETFONT('CONDENSED')
							@ prow()+1, 1 say 'Note : R.F. '+_get_rate_type(cacctno)
							@ prow()+1, 1 say '     : Please present this Statement of Account upon payment.'
							@ prow()+1, 1 say '     : Please disregard if payment has been made.'
							@ prow()+1, 1 say '     : Effective June 1, 2003, rentals/leases of personal properties under financial lease agreements are no longer'
							@ prow()+1, 1 say '       subject to 5% withholding tax per Sec. 2.5.7.2 of Rev. Reg. #17-2003 dated March 31, 2003.'
							@ prow()+1, 1 say '     : For over the counter payment to any Metrobank Branch, kindly use METROBANK PAYMENT SLIP which will ensure proper'
							@ prow()+1, 1 say '       posting of your payments. '// 06.26.13 BONG We have initially filled-out the attached payment slip for your guidance.'
					//		@ prow()+1, 1 say '       Please refer to BILLS PAYMENT GUIDELINE for the instructions in accomplishing the form.'
							SETFONT(UPPER('UNCONDENSD'))
						 else
							SETFONT('CONDENSED')
							@ prow()+1, 1 say 'Note : Please present this Statement of Account upon payment.'
							@ prow()+1, 1 say '     : Please disregard if payment has been made.'
							@ prow()+1, 1 say '     : Effective June 1, 2003, rentals/leases of personal properties under financial lease agreements are no longer'
							@ prow()+1, 1 say '       subject to 5% withholding tax per Sec. 2.5.7.2 of Rev. Reg. #17-2003 dated March 31, 2003.'
							@ prow()+1, 1 say '     : For over the counter payment to any Metrobank Branch, kindly use METROBANK PAYMENT SLIP which will ensure proper'
							@ prow()+1, 1 say '       posting of your payments. '// 06.26.13 BONG We have initially filled-out the attached payment slip for your guidance.'
					//		@ prow()+1, 1 say '       Please refer to BILLS PAYMENT GUIDELINE for the instructions in accomplishing the form.'
							SETFONT(UPPER('UNCONDENSD'))
                   endif */

                     //aga.13.09.2005.authorized sig name
                     @ prow()+4  ,57 say nprefby

                     __eject  ()
					 setprc( 0, 0 )
                     @ prow   ()+1, 0 say ' '
                     npage++
                     lochead2((XTEMP)->BRCODE+(xtemp)->clntcode)
					 @ prow()+1, 0 say ' '
                     // noels - add new line?
                  endif

               endif

           enddo  // !(xtemp)->(eof()) .and. (xtemp)->clntcode == cclntcode

           if tot_pnlty > 0
              @ prow()+1,29 say 'Penalties        :'
              @ prow()  ,60   say 'P ' + tran( round(tot_pnlty,0) ,'999,999,999.99')
              @ prow()+1,62   say repl('-',15)
               
           endif

           if !lone_account

              @ prow()+1,29 say    'TOTAL AMOUNT DUE :'
              @ prow()  ,60 say 'P ' + tran(grd_tot,'999,999,999.99')
              @ prow()+1,62 say repl('=',15)
					footnote()

						/*  if Acctmast->revfreq <> '4'
							SETFONT('CONDENSED')
							@ prow()+1, 1 say 'Note : R.F. '+_get_rate_type(cacctno)
							@ prow()+1, 1 say '     : Please present this Statement of Account upon payment.'
							@ prow()+1, 1 say '     : Please disregard if payment has been made.'
							@ prow()+1, 1 say '     : Effective June 1, 2003, rentals/leases of personal properties under financial lease agreements are no longer'
							@ prow()+1, 1 say '       subject to 5% withholding tax per Sec. 2.5.7.2 of Rev. Reg. #17-2003 dated March 31, 2003.'
							@ prow()+1, 1 say '     : For over the counter payment to any Metrobank Branch, kindly use METROBANK PAYMENT SLIP which will ensure proper'
							@ prow()+1, 1 say '       posting of your payments. '// 06.26.13 BONG We have initially filled-out the attached payment slip for your guidance.'
					//		@ prow()+1, 1 say '       Please refer to BILLS PAYMENT GUIDELINE for the instructions in accomplishing the form.'
							SETFONT(UPPER('UNCONDENSD'))
						 else
							SETFONT('CONDENSED')
							@ prow()+1, 1 say 'Note : Please present this Statement of Account upon payment.'
							@ prow()+1, 1 say '     : Please disregard if payment has been made.'
							@ prow()+1, 1 say '     : Effective June 1, 2003, rentals/leases of personal properties under financial lease agreements are no longer'
							@ prow()+1, 1 say '       subject to 5% withholding tax per Sec. 2.5.7.2 of Rev. Reg. #17-2003 dated March 31, 2003.'
							@ prow()+1, 1 say '     : For over the counter payment to any Metrobank Branch, kindly use METROBANK PAYMENT SLIP which will ensure proper'
							@ prow()+1, 1 say '       posting of your payments. '// 06.26.13 BONG We have initially filled-out the attached payment slip for your guidance.'
					//		@ prow()+1, 1 say '       Please refer to BILLS PAYMENT GUIDELINE for the instructions in accomplishing the form.'
							SETFONT(UPPER('UNCONDENSD'))
                   endif */

              //aga.13.09.2005.authorized sig name
              @ prow()+4  ,57 say nprefby

              npage++
              __eject  ()
			  setprc( 0, 0 )
              //lochead2 ()
           endif

        *endif

     enddo            // do while !(temp)->(eof())

  endif

  __eject()
  setprc( 0, 0 )

// EVR xlastsa := sanum + lastprnt
  setfont ( "NORMAL" )

  Client->( dbsetorder ( _nntx   ) )
  Client->( dbgoto     ( _nrecno ) )

  restdbf    ( mu )
  restscreen ( ,,,,bf )
  setcursor  ( re )
  setcolor   ( gf )

return nil

/*------------------------------*/
Static Function lochead()
/*------------------------------*/
 LOCAL nIDX := CLIENT->(INDEXORD())

 CLIENT->(DBSETORDER(1))
 CLIENT->(DBSEEK((xTEMP)->BRCODE+(XTEMP)->CLNTCODE))          && RED 062805 ADDED

 setprc( 0, 0 )

 do while prow() < 3                  // prow() < 6  changed date 07/13/2000
    @ prow() +1,0 say  ' '
 enddo

 @ prow()+1,0 say microfeed
 @ prow()  ,57+4 say cmonth(xdate) +' '+ str(day(xdate),2)+', '+ str(year(xdate),4)

 @ prow()+1, 0 say ' '
 @ prow()+1, 0 say ' '
 @ prow()+1, 0 say ' '

 @ prow()+2, 8+5 say Client->Fullname + '   Page' + transf(mpage,'9999') 
 @ prow()+1, 8+5 say Client->Address1
 @ prow()+1, 8+5 say Client->Address2
 @ prow()+1, 8+5 say Client->Address3
 @ prow()+1, 8+5 say ' '
 @ prow()+1, 8+5 say iif(Client->CLTYPE='1', 'ATTENTION:  '+Client->Collect,  ' ')
 @ prow()+1, 8+5 say iif(Client->CLTYPE='1', '            '+Client->Position, ' ')
 @ prow()+1, 0 say ' '
 @ prow()+1, 0 say ' '
 @ prow()+1, 0 say ' '

 CLIENT->(DBSETORDER(nIDX))
 mpage++
return nil

*******************************
*
Static Function lochead2()
*******************************

// alert ( Client->(indexkey()) )
if mnewclnt != (xTEMP)->BRCODE+(xtemp)->clntcode
	mpage := 1
	mnewclnt := (xTEMP)->BRCODE+(xtemp)->clntcode
else
	mpage++
	mnewclnt := (xTEMP)->BRCODE+(xtemp)->clntcode
endif
 Client->( dbseek( (xTEMP)->BRCODE+(xtemp)->clntcode) )              && RED 062805 '(xTEMP)->BRCODE+

 setprc( 0, 0 )

 do while prow() < 3               // abb july 13, 2000
    @ prow() +1,0 say  ' '
 enddo

 @ prow()+1,0 say microfeed
 @ prow()  ,57+4 say cmonth(xdate) +' '+ str(day(xdate),2)+', '+ str(year(xdate),4)
 @ prow()+1, 0 say ' '
 @ prow()+1, 0 say ' '
 @ prow()+1, 0 say ' '

 @ prow()+2, 8+5 say Client->Fullname + '   Page' + transf(mpage,'9999') 
 @ prow()+1, 8+5 say Client->Address1
 @ prow()+1, 8+5 say Client->Address2
 @ prow()+1, 8+5 say Client->Address3
 @ prow()+1, 8+5 say ' '
 @ prow()+1, 8+5 say iif(Client->CLTYPE='1', 'ATTENTION:  '+Client->Collect,  ' ')
 @ prow()+1, 8+5 say iif(Client->CLTYPE='1', '            '+Client->Position, ' ')
 @ prow()+1, 0 say ' '
 @ prow()+1, 0 say ' '
 @ prow()+1, 0 say ' '

return nil

/*----------------------------------------*/
Static Function DoAll(xclient,lallclients)
/*----------------------------------------*/
local mu:=savedbf(), re:=setcursor(), bf:=savescreen(,,,), gf:=setcolor()
local tmp_:={}, nrecno := Client->(recno())
local bcond := .t.

waiton  ( 'Filtering accounts per client, please wait...',,'n+*/w' )

if lallclients

   //alert ( 'all clients' )

   Client->(dbgotop())

   do while !Client->(eof())

      if !lallclients
         bcond := .f.
      else
         xclient := CLIENT->BRCODE+Client->clntcode
      endif

      dbselectarea ( 'Acctmast' )
      Acctmast->   ( dbsetorder(2) )
      Acctmast->   ( dbseek( xclient ) )

      Acctmast->   ( dbeval( {||;
                                if ( Paymode == '2' .and. ACCTMAST->BRCODE == g_PAR_BRCH .AND. ACCTMAST->OSBAL<>0 ,; // substr(Acctmast->acctno,3,2) != '07' .and.; // FMLFC substr(Acctmast->acctno,3,2) != '08'     ,; // PBC     && RED 081205 ADDED BRANCH CHECKING
                                      aadd ( tmp_,{ ACCTMAST->BRCODE+Acctmast->Acctno,;
                                                    Acctmast->Oldno ,;
                                                    Acctmast->Term  ,;
                                                    Acctmast->Unit   ;
                                                 };
                                           ),;
                                      nil ;
                                    ) ;
                             },,;
                             {|| ACCTMAST->BRCODE+Acctmast->Clntcode == Xclient .and. !Acctmast->(eof()) };
                           );
                  )

      Client->(dbskip(+1))
   enddo
else

     //alert ( 'one client only' )

      dbselectarea ( 'Acctmast' )
      Acctmast->   ( dbsetorder(2) )
      Acctmast->   ( dbseek( xclient ) )

      Acctmast->   ( dbeval( {||;
                                if ( Paymode == '2' .and. .t.,; // substr(Acctmast->acctno,3,2) != '07' .and.; // FMLFC substr(Acctmast->acctno,3,2) != '08'     ,; // PBC
                                      aadd ( tmp_,{ ACCTMAST->BRCODE+Acctmast->Acctno,;
                                                    Acctmast->Oldno ,;
                                                    Acctmast->Term  ,;
                                                    Acctmast->Unit   ;
                                                 };
                                           ),;
                                      nil ;
                                    ) ;
                             },,;
                             {|| ACCTMAST->BRCODE+Acctmast->Clntcode == Xclient .and. !Acctmast->(eof()) };
                           );
                  )

endif

waitoff()

restdbf(mu);restscreen(,,,,bf);setcursor(re);setcolor(gf)
Client->(dbgoto(nrecno))
return tmp_

/*------------------------------*/
Static Function Doone(xclient)
/*------------------------------*/
local mu := savedbf(),gf:=setcolor()
local re := setcursor(), naccnt:=spac(14+3), ztemp, xval, nctr := 0
local tmp_:= { { 'ACCTNO'  ,'C',14,0  },;
               { 'CLNTCODE','C', 7,0  },;
               { 'ACCTNAME','C',50,0  },;
               { 'OLDNO',   'C',16,0  },;
               { 'TERM',    'N', 3,0  },;
               { 'UNIT',    'C',40,0  },;
               { 'BRCODE',  'C', 3,0  } ;
             }
IF TRUE_BRCH == '001'
   waiton ( 'Tranfering data...Please wait',,'n*/w' )

   ztemp := crea_Xtemp()
   DBCREATE ( ztemp,tmp_ )
   while !netuse( ztemp,.t.,10 );enddo
   index on acctname to &ztemp
   dbselectarea ( 'Acctmast' )

   Acctmast->   ( dbsetorder(2) )
   Acctmast->   ( dbseek(xclient) )

   do while ACCTMAST->BRCODE+Acctmast->Clntcode == xclient .and. !Acctmast->(eof())

      nctr++

      if Acctmast->Paymode == '2'             .and. ;
         substr(Acctmast->acctno,3,2) != '07' .and.;       //  9907
         substr(Acctmast->acctno,3,2) != '08'              //  9908


         //dbselectarea('xtemp')
         (ztemp)->(dbappend())
         (ztemp)->Acctno   := Acctmast->Acctno
         (ztemp)->Clntcode := Acctmast->Clntcode
         (ztemp)->Acctname := Acctmast->Acctname
         (ztemp)->Oldno    := Acctmast->Oldno
         (ztemp)->Term     := Acctmast->Term
         (ztemp)->Unit     := Acctmast->Unit
         (ztemp)->Brcode   := Acctmast->Brcode
      endif
      Acctmast->(dbskip(+1))

   enddo

   ( ztemp )->(dbcommit())
   ( ztemp )->(dbsetindex(xtemp))
   waitoff ()
ELSE
   zTEMP := CPS_REQST(CHK_PAR(xCLIENT),'ONECLIENT')
   IF zTEMP <> NIL
      WHILE !NETUSE( g_AMS_PATH+'\'+zTEMP,.T.,10 );ENDDO
      INDEX ON ACCTNAME TO (g_AMS_PATH+'\'+zTEMP)
   endif
endif
// ( ztemp )->(browse())
IF zTEMP <> NIL
   if (ztemp)->(!eof()) .and. (ztemp)->(!bof())

      fshadow(17,32,19,68+4,2,'n/w')
      set color to 'n/w','w/n',,,'w+/w'
      setcursor(3)
      @ 18,33 say 'Account Number  ' ;
              get naccnt              ;
              pict '@R 999-9999-99999-99999' ;
              VALID IF(EMPTY(nACCNT),;
                       EVAL( {|| nACCNT := FLOOK_ONLINE( .T., zTEMP   ,NIL,'Account Master File',7,1,3,2,1,,,,,,.T.),;
                                 IF(!EMPTY(nACCNT) .AND. VALBRCODE(LEFT(nACCNT,3),g_USER_ID),;
                                    .T.,;
                                    EVAL({|| nACCNT:= SPACE(17), .F.});
                                      );
                           } ),;
                       IF(VALBRCODE(LEFT(nACCNT,3),g_USER_ID),;
                          .T.,;
                          EVAL({|| nACCNT:= SPACE(17), .F.});
                         );
                      )
              //when !empty(nacct:=eval( { || flook_ONLINE(.t.,(ztemp),nil,'Account Master File',45,1,3,2,1) } ) )

      setcursor(3)
      read
      setcursor(0)

      if lastkey() != K_ESC
         xval := { { naccnt,(ztemp)->oldno,(ztemp)->term,Substr((ztemp)->Unit,1,26) } }
      else
         xval := nil
      endif

   endif

   //dbselectarea( &xtemp )
   (ztemp)->(dbclosearea())
endif
IF TRUE_BRCH == '001'
   ferase( (ztemp) + '.dbf' )
   ferase( (ztemp) + '.ntx' )
ELSEIF zTEMP <> NIL
   ferase( (g_AMS_PATH+'\'+ztemp) + '.dbf' )
   ferase( (g_AMS_PATH+'\'+ztemp) + '.ntx' )
endif

restdbf(mu)
********* restscreen(,,,,bf)
setcursor(re)
setcolor(gf)

return  xval
/*
/*---------------------------------*/
Static Function chkclient( xclient,sw )
/*--------------------------------*/
local mu:=savedbf(),re:=setcursor(),bf:=savescreen(,,,),gf:=setcolor()

dbselectarea('Acctmast')
dbsetorder(2)
if !dbseek(xclient)
   error('Client has no existing account!')
   restdbf(mu);restscreen(,,,,bf);setcursor(re);setcolor(gf)
   sw:=.f.
   return .f.
else
   restdbf(mu);restscreen(,,,,bf);setcursor(re);setcolor(gf)
   sw:=.t.
   return .t.
endif
return .t.
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
/*
/*-----------------------------*/
Static Function f10escape(mess1)
/*-----------------------------*/
loca ax := setkey( K_F10, nil ),sw
mess1 := if( mess1 == nil, 'You have pressed the <F10> key.  Abort editing?' , mess1 )

if lastkey() == K_F10
   if CONFIRM( mess1,.f. )
      clear gets
      swdue:=.t.
      __keyboard(chr(-9))
   else
      swdue:=.f.
      setkey( K_F10, ax )
   endif
endif
return( nil )

/*-------------------------*/
 Static Function Abrupt()
/*-------------------------*/
//setkey( K_ESC, NIL )
setkey( K_F10, NIL )
clear gets
if Confirm('Cancel the whole printing process?')
   break
endif
return nil
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
 Static Function aOpen6000()
/*-------------------------*/
if !netuse( '&g_AMS_PATH\Acctmast', .f., 10 )              && Account master file
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_AMS_PATH\Acctmast' )                    && set index on acctno
   ordlistadd( '&g_AMS_PATH\Acctclnt' )                    && index on Clntcode + acctno
endif

if !netuse( '&g_AMS_PATH\Paysked', .f., 10 )               && Payment Schedule file
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_AMS_PATH\Paysked' )                     && set index on acctno + paydate
   ordlistadd( '&g_AMS_PATH\Paydsked' )                    && set index on paydate
   ordlistadd( '&g_AMS_PATH\Paystat' )                     && set index on status
endif

if !netuse('&g_AMS_PATH\payimage',.f.,5)
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_AMS_PATH\Payimage' )
endif


if !netuse( '&g_Grf_path\Personel', .f., 10 )   && Account Review file
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_Grf_path\Initials' )         && set index on initials
   //ordlistadd( '&g_Grf_path\Personel' )         && set index on acctno
   //ordlistadd( 'Acctclnt' )
endif

if !netuse( '&g_Cis_path\Client', .f., 10 )               && Client file
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_Cis_path\Cliecd' )                    && set index on clntcode
   ordlistadd( '&g_Cis_path\Clienm' )                    && set index on Fullname
endif

if !netuse( '&g_AMS_PATH\Saformat', .f., 10 )                         && Statement of Account Format file
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_AMS_PATH\Saformat' )                               && set index on clntcode
endif

if !netuse( '&g_AMS_PATH\Facility', .f., 10 )                         && Statement of Account Format file
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_AMS_PATH\Fcltycd' )                               && set index on clntcode
endif

// EVR if !netuse( 'Parametr', .f., 10 )                         && Parametr file
// EVR    break
*--->      && RED 033005
// EVR ELSE
// EVR    IF NETUSE('&g_AMS_PATH\OL_PARAM',.F.,5)
// EVR       SET INDEX TO &g_AMS_PATH\OL_PARAM
// EVR       OL_PARAM->(DBSEEK(g_PAR_BRCH))
// EVR    ELSE
// EVR       BREAK
// EVR    endif
*--->
// EVR endif

//scrntitle( 'Statement of Account Maintenance', gSYS_NAME, gUSER_ID, gTRANDATE )
//dispbox( 3, 0, maxrow(), maxcol(), space( 9 ), 'n/n' )

return( nil )
/*
         1         2         3         4         5         6         7         8         9         0
1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
               Plus:Penalty as of 06/30/1996
                            TOTAL AMOUNT DUE
*/


***************************************
*               
static function _get_remterm(cacctno,dpaydate,dtermctr)
***************************************
local nntx    := Acctmast->(indexord()),nrecno := Acctmast->(recno())
local cretval := space (5),nremterm := 0,cret2 := ' '
Acctmast->(dbsetorder(1))              // account number
Acctmast->(dbseek(cacctno))

//aga.09.05.2006.marked for modification

//dbselectarea('Paysked')
Paysked->(dbsetorder(3))

//Paysked->(dbseek(cacctno+dtos(dpaydate)+'D',.t.))  

Paysked->(dbseek(cacctno+'D'))

if Paysked->paynum != 0 .and. PAYSKED->BRCODE+Paysked->acctno == cacctno .and. paysked->status == 'D' //note, no changes
   nremterm := Paysked->paynum + dtermctr 
else
   Payimage->(dbseek(cacctno+dtos(dpaydate),.t.))

   if PAYIMAGE->BRCODE+Payimage->acctno == cacctno
      nremterm := Payimage->paynum
   endif

endif
//.......................................

cretval := padl(alltrim(str(nremterm)),3)+'/'
cret2   := padr(alltrim(str(Acctmast->term)),3)

/*if Acctmast->term <= 72  //get on acctmast if less then 72, else count image
   cret2   := padr(alltrim(str(Acctmast->term)),3)
else
   cret2   := padr(alltrim(str(_get_term(ACCTMAST->BRCODE+Acctmast->acctno))),3)
endif */
cretval := cretval + cret2

//alert(Paysked->acctno + ' ' + cretval + ' ' + dtos(Paysked->paydate))

Acctmast->(dbsetorder(nntx))
Acctmast->(dbgoto(nrecno))
return cretval

***************************************
*
static function _get_term(cacctno)           //called only by _get_remterm
***************************************
local nntx    := Acctmast->(indexord()),nrecno := Acctmast->(recno())
local nretval := 0
local xrecno  //aga.16.08.2007.save pos  

dbselectarea('Acctmast')
Acctmast->(dbsetorder(1))              // account number
Acctmast->(dbseek(cacctno)) 

dbselectarea('Payimage')

//aga.09.05.2006.marked for modification
if Payimage->(dbseek(cacctno))
   do while PAYIMAGE->BRCODE+Payimage->acctno == cacctno .and. !Payimage->(eof())
      nretval++
      Payimage->(dbskip(+1))
   enddo
else
   //alert('run the new algo in paysked' + indexkey())
   //count in paysked replace by last term record 
   xrecno := paysked->(recno())

   if paysked->(dbseek(cacctno))
      do while paysked->BRCODE+paysked->acctno == cacctno .and. !paysked->(eof())
         nretval := paysked->term
         paysked->(dbskip(+1))
      enddo
   endif
 
   paysked->(dbgoto(xrecno))   
endif
//............................

Acctmast->(dbsetorder(nntx))
Acctmast->(dbgoto(nrecno))
return nretval

************************************************
*             ( added date -> July 12 , 2000 abb
*
static function _one_acct_per_page( cacctno )
************************************************
   local nrec := Acctmast->(recno()),nntx := Acctmast->(indexord())
   local lretval := .f.,cclntcode := space(len(Acctmast->clntcode))

   Acctmast->(dbsetorder(1))            // account number
   if Acctmast->(dbseek(cacctno))
      if Saformat->(dbseek(ACCTMAST->BRCODE+Acctmast->clntcode))
         lretval := .t.
      endif
   endif

   Acctmast-> (dbsetorder(nntx))
   Acctmast->(dbgoto(nrec))
return lretval

//aga.13.05.2005.new and improved chksignee()...yay!
*******************************
static function chksignee()
*******************************
memvar nPREfBY, nNOTEDBY
local  getlist := {}, ax := setcolor()

private entryname [2]
entryname [1] := entryname [2] := space(40)

fshadow ( 12, 18, 15, 65, 2, 'n/w')
setcolor( 'bg+/w, w+/n,,, gr+/w' ) 

@ 13, 19 say ' Signatory     ' ;
         gget entryname[1]      ;
         picture '@xs28'            ;
         when lastkey() != K_ESC valid !empty( nprefby := get_initial(entryname[1], 1, 12, 36, 28 ) )

setcursor ( 3 )
read   
setcursor ( 0 )
setcolor  ( ax )

return( lastkey()!=K_ESC )

