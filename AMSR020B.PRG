/*
 ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³   colfsys  -- Account Management System                                  ³
 ³   program idúúú amsr020a                                                 ³
 ³   descriptionúú Statement of Account (Collection)                        ³
 ³   authorúúúúúúú Engr. Michael B. Espina                                  ³
 ³   dateúúúúúúúúú 10:05:am úú 06-16-2000                                   ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³                             u p d a t e s                                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³        who        ³       when        ³               why                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³                   ³                   ³                                  ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 */

////
#defi K_SPACEBAR   32
#define _MAXROW    42
#defi microfeed    chr( 27 ) + 'J' + chr( 18 )
#xtran getprntr (<xnum>) => if ( <xnum> == 1, "'Epson FX-1170'",;
                              if ( <xnum> == 2, "'OKI Microline 321'",;
                              if ( <xnum> == 3, "'OKI Microline 521'","")))
////
#include 'inkey.ch'
#include 'colf.ch'
#include 'dbstruct.ch'

memvar  AX_LEVEL, gUSER_ID
private dstart := date() ,dend := date()+7
setcursor(0)
setblink(.t.)
if !chkpass( procname(), AX_LEVEL, gUSER_ID )
   //NOTHING WILL HAPPEN
else
   begin sequence
     aOpen6000()
     do while _getfromto()
        aMain6000()
     enddo
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

   setkey   ( K_ESC,nil )
   setcolor ( 'n/gr,w+/gr','w+/gr,n/gr' )
   fshadow  ( 04, 34, 9, 56, 2, 'w+/bg')

   @ 05,35 say '<<< Maturity Date >>>'
   @ 07,35 say 'From  ' get dstart pict '@D'
   @ 08,35 say 'To    ' get dend   pict '@D'

   setcursor(3)
   read
   setcursor(0)

******  restscreen (,,,,cscr )

return lastkey() != K_ESC

/*-------------------------*/
 Static Function Amain6000()
/*-------------------------*/
local mu:=savedbf(),re:=setcursor(),bf:=savescreen(,,,),gf:=setcolor()
local cchoice,menulist,xxx
private xtemp,xdate:=gTrandate,pval,max2,xlastsa

setkey   ( K_ESC,nil )
setcolor ( 'n/gr,w+/gr','w+/gr,n/gr' )
************** fshadow( 09, 39, 14, 55, 2, 'w+/bg')

fshadow  ( 09, 39, 14, 55, 2, 'w+/bg')
@ 10,54 say 'Ü'  color 'n/bg'
@ 11,41 say repl('ß',14) color 'n/bg'

************** @ 12,54 say 'Ü'  color 'n/bg'
************** @ 12,54 say 'Ü'  color 'n/bg'
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
        ************* byduedate(cchoice)
        byclient ( cchoice,.t. )
        return .t.
   case cchoice == 0
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
  ENDIF
enddo

if !swdue     //lastkey() <> K_F10

  waiton    ('Creating swap file..please wait.',,'n*/w')
  setkey    ( K_F10, nil )
  setcursor (0)
  dbcreate( (ztemp),{{'ACCTNO','C',14,0}} )
  while !netuse( (ztemp), .t., 10);enddo
  index on Acctno to (temp1)
  dbselectarea('Paysked')
  dbsetorder(2)
  Paysked->( dbseek( xddate,.t. ) )
  while Paysked->Paydate <= xddate .and. !eof()
      if !(ztemp)->(dbseek(Paysked->Acctno))
         (ztemp)->(dbappend())
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
     if !empty( st_:=chkacct( (ZTEMP)->BRCODE+(ztemp)->Acctno ) )
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
xclnt := if(dbseek( xacctno ),Acctmast->Clntcode,spac(14))
dbsetorder(2)
dbeval( {|| if(Acctmast->Paymode == '2',aadd( tmp_,{ Acctmast->Acctno,Acctmast->Oldno,Acctmast->Term,Acctmast->Unit } ),nil) },,;
{|| Acctmast->Clntcode == xclnt .and. !eof() } )
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
return (Client->Clntcode)
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
local mu := savedbf(),bf:=savescreen(,,,),gf:=setcolor()
local re := setcursor(),tmp_:={}, sw:=.f.,st_,xxx
local xclient:=spac(7),xddate:=gTrandate,xchoice,menulist
local nmonth

setkey(K_ESC,nil)
dbselectarea ( 'Client' )
Client->     ( dbsetorder(2) )

do while !sw


/****************
  @ 16,40 say 'Due date  ' ;
          get xddate        ;
          pict '@D'         ;
          when eval ({|| nmonth := month(xddate),;
                         nyear  := year (xddate),;
                         get_month(@xddate,@nmonth,@nyear)
                    };
               .and. lastkey() <> K_ESC
*****************/
****************               when sw .and. lastkey() <> K_ESC


  
**********  setkey ( K_ESC,{|| fescape('Abort?') } )

  *********8setcursor(3)
  *********read
  *********setcursor(0)

  if !get_param(@xclient,@xddate,@sw,lallclients)
     exit
  else
     sw := .t.
  endif

enddo

********** setkey( K_ESC, nil )
********** setcursor(0)

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

      @ 13-2,56 say 'Ü'           color 'n/bg'
      @ 14-2,51 say repl('ß',6+6) color 'n/bg'
      @ 15-2,56 say 'Ü'  color 'n/bg'
      @ 16-2,51 say repl('ß',6+6) color 'n/bg'

      @ 11,50 prompt ' ~One Account  ' triggercolor 'w+/gr'
      @ 13,50 prompt ' ~All Accounts ' triggercolor 'w+/gr'

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
           @ 15-2,50 say 'û' color 'w/gr'
           st_ := doall(xclient,lallclients)


      case xchoice == 1
           xxx:=savescreen( ,,, )         ////////// One
           @ 11,50 say repl(' ',7+5) color 'n/bg'
           @ 12,50 say repl(' ',7+5) color 'n/bg'
           @ 11,51 say ' One Account '  color 'w+/gr'
           inkey(.5)
           restscreen( ,,,,xxx )
           @ 13-2,50 say 'û' color 'w/gr'
           st_ := doone(xclient,lallclients)
      case xchoice == 0
           restdbf(mu);restscreen(,,,,bf);setcursor(re);setcolor(gf)
           return nil
   endcase

endif

if !empty(st_)

   if fdata1014(st_,xddate,,cchoice)


      fdata1114(xclient,,cchoice,lallclients)

   endif

else
****  alert ( 'not if !empty(st_)' )
endif

restdbf(mu);restscreen(,,,,bf);setcursor(re);setcolor(gf)
return nil

**************************************************
*
static function get_param ( xclient,ddate,sw,lallclients )
**************************************************
   local mretval := .t., getlist := {}, mcolor := setcolor()
   local nmonth := month(ddate),nyear := year (ddate)
   ******** setcolor( 'n/g,w+/n,,, w+/g' )

**********  fshadow      (6,30,10,55,2,'n/w')

  fshadow      (6,30,8,55,2,'n/w')
  set color to 'n/w','w/n',,,'n/w'

  if lallclients                                 // print all clients
     @   7,32 say 'Client  ' + 'All Clients'
  else                                           // single client only
     @   7,32 say 'Client  ' ;
             get xclient       ;
             pict '@X'         ;
             when lastkey() <> K_ESC .and. ;
                  eval( {|| xclient := flook_online( .t., 'Client',nil,'Client Master File',1,3,4,,1,), .t. } );          &&eval( {|| xclient := flook( .t., 'Client',nil,'Client Master File',1,3,4,1,), .t. } );
             valid eval( { || chkclient( xclient,@sw ),.t.} )
   endif

*********   @  8, 32 say 'Month    ' get nmonth pict '99'   when  select_month( @nmonth )
**********   @  9, 32 say ' Year    ' get nyear  pict '9999' valid nyear > 1970

   setcursor(3)
   read
   setcursor(0)

   if lastkey() != K_ESC

/****************
      do case
         case ltrim(trans(nmonth,'999')) $ '_4_6_9_11'
            ddate := ctod ( right('0'+alltrim(str(nmonth)),2)+'/'+'30/'+alltrim(str(nyear)) )
         case ltrim(trans(nmonth,'999')) $ '_1_3_5_7_8_10_12'
            ddate := ctod ( right('0'+alltrim(str(nmonth)),2)+'/'+'31/'+alltrim(str(nyear)) )
         otherwise

            if is_leap(nyear)
               ddate := ctod ( '02/29'+alltrim(str(nyear) ))
            else
               ddate := ctod ( '02/28'+alltrim(str(nyear) ))
            endif
      endcase
********************/

   endif


   setcolor( mcolor )
return lastkey() != K_ESC

******************************************************
*
*
static function fdata1014(st_,ddate,ztemp,cchoice)
******************************************************
local mu:=savedbf(),re:=setcursor(),bf:=savescreen(,,,),gf:=setcolor()
local x, i,ctr:=0,gr_[500],compact:=''
local nntx := Acctmast->(indexord()) , nrecno := Acctmast->(recno())
local temp1,temp2,temp3,temp4
local nprint:=' '
memvar dstart,dend

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

waiton ( 'Transferring data...,please wait',,'n*/w' )
setcursor(re)
dbselectarea ( 'Paysked' )
Paysked->    ( dbsetorder(1) )

temp_ := Paysked->(dbstruct())

aadd( temp_,{ 'PENSTAT' ,'N',1 ,0 } )
aadd( temp_,{ 'GRUPSTAT','N',1 ,0 } )
aadd( temp_,{ 'OLDNO'   ,'C',16,0 } )
aadd( temp_,{ 'TERM'    ,'N',3 ,0 } )
aadd( temp_,{ 'UNIT'    ,'C',26,0 } )
aadd( temp_,{ 'CLNTCODE','C',7 ,0 } )

//aadd( temp_,{ 'FULLNAME','C',50,0 } )
//aadd( temp_,{ 'ADDRESS1','C',30,0 } )
//aadd( temp_,{ 'ADDRESS2','C',30,0 } )
//aadd( temp_,{ 'ADDRESS3','C',30,0 } )
//aadd( temp_,{ 'COLLECT', 'C',40,0 } )
//aadd( temp_,{ 'POSITION','C',40,0 } )

dbcreate( xtemp, temp_ )

while !netuse( xtemp,.t.,10 )
enddo

temp1 := substr(xtemp,1,7) +'1'
temp2 := substr(xtemp,1,7) +'2'
temp3 := substr(xtemp,1,7) +'3'
temp4 := substr(xtemp,1,7) +'4'

(xtemp)->(dbcreateindex( (temp1),'penstat',{ || penstat } ))
(xtemp)->(dbcreateindex( (temp2),'Acctno + str( Grupstat,1)',{ || Acctno + str(Grupstat,1) } ))
(xtemp)->(dbcreateindex( (temp3),'Acctno+dtos(Paydate)',{ || Acctno+dtos(Paydate) },.t. ))
(xtemp)->(dbcreateindex( (temp4),'clntcode+Acctno+dtos(Paydate)',{ || clntcode+Acctno+dtos(Paydate) } ))

set index to (temp1), (temp2), (temp3), (temp4)

for x:= 1 to len(st_)

    dbselectarea ( 'Paysked' )
    Paysked->    ( dbsetorder(1) )

    ctr := 0

    if Paysked->(dbseek( st_[ x,1 ] ) ) .and. Paysked->Paydate <= dend

/******
    if Paysked->(dbseek( st_[ x,1 ] ) ) .and. ;
       Paysked->Paydate >= dstart       .and. ;
       Paysked->Paydate <= dend
******/
ddate := dend

      do while Paysked->Acctno == st_[ x,1 ] .and. Paysked->Paydate <= dend

***        do while Paysked->Acctno == st_[ x,1 ] .and. ;
***                 Paysked->Paydate >= dstart       .and. ;
***                 Paysked->Paydate <= dend

              if ztemp != nil
                  if (ztemp)->(dbseek(Paysked->Acctno))
                     (ztemp)->(dbdelete())
                  endif
              endif

              ctr++
              gr_[ctr] := (xtemp)->(recno())

              if ( xtemp )->( netlock('A',5) )
                 (xtemp)->acctno     := Paysked->acctno
                 (xtemp)->Paynum     := Paysked->paynum
                 (xtemp)->paydate    := Paysked->paydate
                 (xtemp)->amort      := Paysked->amort
                 (xtemp)->sanumber1  := Paysked->sanumber1
                 (xtemp)->sanumber2  := Paysked->sanumber2
                 (xtemp)->sadate1    := Paysked->sadate1
                 (xtemp)->sadate2    := Paysked->sadate2
                 (xtemp)->penalty    := 0            //Paysked->penalty
                 (xtemp)->Oldno      := st_[ x,2 ]
                 (xtemp)->Term       := st_[ x,3 ]
                 (xtemp)->Unit       := st_[ x,4 ]

                 Acctmast->(dbsetorder(1))

                 if Acctmast->(dbseek(Paysked->acctno))
                    (xtemp)->clntcode := Acctmast->clntcode
                 endif

              endif

              rnum:= (xtemp)->(recno())

*********              if Paysked->Paydate < xdate

              if Paysked->Paydate+5 < xdate  // five days grace period (06/09/2000)
                 ( xtemp )->Penstat := 1
              endif
              Paysked->(dbskip(+1))

        enddo

        if ctr > 1
          (xtemp)->(dbgoto(gr_[1]))
          do while (xtemp)->Acctno == st_[ x,1 ]
              (xtemp)->grupstat := 1
              (xtemp)->(dbskip(+1))
          enddo
       else
          replace (xtemp)->grupstat with 0
       endif

       ( xtemp )->(dbcommit())

    endif
next x
waitoff()

_filter_xtemp()

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
   local cacctno,ddate,nrec2 := 0, nrec3 := 0,nrec4 := 0
   memvar dstart,dend
   (xtemp)->(dbsetorder(4))   // clntcode+Acctno+dtos(Paydate)

   (xtemp)->(dbgotop())
   (xtemp)->(dbgotop())

   do while !(xtemp)->(eof())
      cacctno  := (xtemp)->acctno
      ddate    := ctod ('')
      nrec2    := (xtemp)->(recno())

      do while !(xtemp)->(eof()) .and. (xtemp)->acctno  == cacctno
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
local temp3 := substr(xtemp,1,7) +'3',nprint:=' '
local pdate:=xdate,prate:=0,pchoice:=0,menulist,xms,ppy,ttl
prntcnt := if(prntcnt == nil, 1, prntcnt)
swdue := .f.
if(cchoice == 1, setkey(K_ESC,NIL), setkey(K_F10,nil) )


dbselectarea ( xtemp )

********88(xtemp)->(dbcreateindex( (temp1),'penstat',{ || penstat } ))
*********(xtemp)->(dbcreateindex( (temp2),'Acctno + str( Grupstat,1)',{ || Acctno + str(Grupstat,1) } ))
*******88(xtemp)->(dbcreateindex( (temp3),'Acctno+dtos(Paydate)',{ || Acctno+dtos(Paydate) },.t. ))
*********(xtemp)->(dbcreateindex( (temp4),'clntcode+Acctno+dtos(Paydate)',{ || clntcode+Acctno+dtos(Paydate) } ))

//index on penstat to &temp1
*********8set index to (temp1), (temp2), (temp3), (temp4)

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
             when eval( { || prate:=Parametr->Penrate * 100, .t. } )  ;
             valid prate >= 0
             ************ valid !empty(prate)

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
         restdbf(mu);restscreen(,,,,bf);setcursor(re);setcolor(gf)
         return .f.
      endif
   elseif cchoice == 2
      if swdue       //lastkey() == K_F10
         restdbf(mu);restscreen(,,,,bf);setcursor(re);setcolor(gf)
         return .f.
      endif
   endif
   waiton ( 'Computing penalty..,please wait.',,'n*/w' )

   do while (xtemp)->Penstat == 1

       (xtemp)->Penalty:= ( ( (xtemp)->amort ) * prate /30 );
                          * ( pdate - (xtemp)->Paydate )
       (xtemp)->(dbskip(+1))
   enddo

   waitoff ()
   (xtemp)->(dbcommit())
endif

ppy := setkey( K_ESC )
ttl := setkey( K_F10 )

************8888if pval <> 0

pval := 3
max2 := 1


if lallclients
   prncontrol( 'forms2print()')    // call the printing routine (04/12/00) abb
else
   prncontrol( 'printforms()')    // call the printing routine (04/12/00) abb
endif


setkey ( K_ESC,ppy )
setkey ( K_F10,ttl )
(xtemp)->(dbclosearea())
//ferase( xtemp + '.dbf' )
//ferase( temp1 + '.ntx' )
//ferase( temp2 + '.ntx' )
//ferase( temp3 + '.ntx' )
restdbf(mu);restscreen(,,,,bf);setcursor(re);setcolor(gf)
return nil
/*-------------------------*/
//Static Function Savest01( xms )
/*-------------------------*/
/* EVR 01022007 - no use
local mu:=savedbf(),re:=setcursor(),bf:=savescreen(,,,),gf:=setcolor()
waiton('Updating payment schedule file..,please wait.',,'n/w')
dbselectarea('Paysked')
dbsetorder(1)
(xtemp)->( dbsetorder(3) )
(xtemp)->(dbgotop())
while (xtemp)->(!eof())
    if Paysked->(dbseek( (xtemp)->Acctno+dtos((xtemp)->Paydate) ) )
       //while Paysked->Acctno == (xtemp)->Acctno .and. Paysked->(!eof())
         if Paysked->(netlock( 'R', 0 ))
            Paysked->Penalty    := (xtemp)->Penalty
            Paysked->(dbcommit())
            Paysked->(dbunlock())
            Paysked->(dbskip())
         endif
         //(xtemp)->(dbskip())
       //enddo
    endif
    (xtemp)->(dbskip())
enddo

 Parametr->(netlock('R',5) )
 Parametr->Lastsa  := xlastsa
 Parametr->(dbunlock())
 Parametr->(dbcommit())

 UPDT_OL()              && RED 033005

waitoff()
restdbf(mu);restscreen(,,,,bf);setcursor(re);setcolor(gf)
return nil
*/
*********************************
*
function printforms()
*********************************
 local mu:=savedbf(),re:=setcursor(),bf:=savescreen(,,,),gf:=setcolor()
 local xacct,amrt_4:={},lcount:=0,lastprnt:=1,sanum:=Parametr->lastsa
 local tot_amort :=0,tot_pnlty := 0,grd_tot:=0,recst_:={},x,nrec
 local ac_set,nrent,cacctno := space(16) ,nswitch := 0,nsubtotal := 0
 local nrec2 := 0,lfound := .f.
 local cunit,npage := 1

 dbselectarea ( xtemp )
 (xtemp)->( dbsetorder(2) )
 setprc ( 0, 0 )

 if pval == 1 .or. pval  == 3
    setfont('NLQ')
    setfont('ELITE')
 elseif pval == 2
    @ prow(),pcol() say chr(27) + chr(58)
 endif

 lochead  ()

 (xtemp)->(dbgotop())

  if !(xtemp)->(eof())

     ac_set := Acctmast->(indexord())
     Acctmast->(dbsetorder(1))

     Acctmast->( dbseek( (xtemp)->Acctno ) )

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

        cacctno   := (xtemp)->Acctno
        nswitch   := 0
        nsubtotal := 0

        do while !(xtemp)->(eof()) .and. (xtemp)->acctno == cacctno

           if nswitch == 0 .and. prow() <= _MAXROW-5     // d' next 2 lines 'says' must be printed
                                 // once each account number only, abb0412200
                                 //

              nrec2  := (xtemp)->(recno())
              lfound := .f.
              do while !(xtemp)->(eof()) .and. (xtemp)->acctno == cacctno

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

//              if lfound
//                 @ prow()  ,pcol()+1 say ' Penalties      Total'
//              else
//                 @ prow()  ,pcol()+1 say '                Total'
//              endif

              ********** @ prow()  ,24 say 'Unpaid '+nRent+' for the month(s) of'
              nswitch := 1
           endif

           if prow() >  _MAXROW-5

**********              @ _MAXROW-5  , 1 say 'ù Page '+ trans ( npage,'999,999' )
//              @ _MAXROW-5+1, 1 say 'ù R.F. '+_get_rate_type(cacctno)
//              @ _MAXROW-5+2, 1 say 'ù Please present this Statement of Account upon payment'
//              @ _MAXROW-5+3, 1 say 'ù Please disregard if payment has been made.'
              @ prow()+5, 1 say 'ù R.F. '+_get_rate_type(cacctno)
              @ prow()+1, 1 say 'ù Please present this Statement of Account upon payment'
              @ prow()+1, 1 say 'ù Please disregard if payment has been made.'

              npage++
              __eject()
              lochead()
           endif

******           @ prow()+1, 30 say padr(cmonth( (xtemp)->paydate ),10) + '   '+;
******                            alltrim(str(year((xtemp)->paydate )))

           if lfound
//
//              @ prow()+1, 23 say padr(cmonth( (xtemp)->paydate ),3) +'.'+' '+ ;
//                                 alltrim(str(year((xtemp)->paydate )))
//
              @ prow()+1, 23-9 say _get_remterm(cacctno,paydate)+' '+dtoc(paydate)
           else
//
//              @ prow()+1, 23 say padr(cmonth( (xtemp)->paydate ),3) +'.'+' '+ ;
//                                 alltrim(str(year((xtemp)->paydate )))
//
              @ prow()+1, 23-9 say _get_remterm(cacctno,paydate)+' '+dtoc(paydate)
           endif


**********           @ prow()  , 62 say tran ( (xtemp)->amort,'999,999,999.99')
           @ prow()  , pcol()+1  say tran ( (xtemp)->amort,'999,999,999.99')

           if prow() > _MAXROW-5

*************              @ prow()+5  , 1 say 'ù Page '+ trans ( npage,'999,999' )
              @ prow()+5, 1 say 'ù R.F. '+_get_rate_type(cacctno)
              @ prow()+1, 1 say 'ù Please present this Statement of Account upon payment'
              @ prow()+1, 1 say 'ù Please disregard if payment has been made.'

              npage++

              __eject()
              lochead()
           endif
           if (xtemp)->Penalty  > 0

              ********* @ prow()+1,24 say 'Plus:Penalty as of '+dtoc( (xtemp)->Paydate)
              ********  @ prow()  ,62 say tran ( (xtemp)->Penalty  ,'999,999,999.99' )
              @ prow() , 48 say tran ( round((xtemp)->Penalty,0)  ,'9,999,999.99' )
              tot_pnlty += round((xtemp)->Penalty,0)
           else
              @ prow() , 48 say space(12)
           endif
           
           if lfound
              @ prow()  , pcol()+2 say tran ( (xtemp)->amort+round((xtemp)->penalty,0),'999,999,999.99')
           else
              @ prow()  , pcol()+2 say tran ( (xtemp)->amort,'999,999,999.99')
           endif

           nsubtotal += (xtemp)->amort + round((xtemp)->Penalty,0)
           grd_tot   += (xtemp)->amort + round((xtemp)->Penalty,0)
           (xtemp)->(dbskip(+1))

        enddo

        if prow() > _MAXROW-5

******              @ prow()+5  , 1 say 'ù Page '+ trans ( npage,'999,999' )
              @ prow()+5, 1 say 'ù R.F. '+_get_rate_type(cacctno)
              @ prow()+1, 1 say 'ù Please present this Statement of Account upon payment'
              @ prow()+1, 1 say 'ù Please disregard if payment has been made.'
           npage++

           __eject()
           lochead()
        endif

**********        @ prow()+1,23   say padr( cunit,38 )

        @ prow()+1,23   say padr( _get_unit( cacctno),38 )

        @ prow()  ,62   say repl('-',15)
//        @ prow()+1,29 say 'Sub Total '
//        @ prow()  ,60   say 'P ' + tran(nsubtotal,'999,999,999.99')
//        @ prow()+1,62   say repl('-',15)

     enddo

  endif

*************   @ prow()+1,58+4 say repl('-',15)

  if tot_pnlty > 0
     @ prow()+1,29 say 'Total Penalties '
     @ prow()  ,60   say 'P ' + tran( round(tot_pnlty,0) ,'999,999,999.99')
     @ prow()+1,62   say repl('-',15)
  endif

  @ prow()+1,29   say 'TOTAL AMOUNT DUE'
  @ prow()  ,60   say 'P ' + tran(grd_tot,'999,999,999.99')
  @ prow()+1,62   say repl('=',15)


********  @ prow()+2  , 1 say 'ù Page '+ trans ( npage,'999,999' )
  @ prow()+2, 1 say 'ù R.F. '+_get_rate_type(cacctno)
  @ prow()+1, 1 say 'ù Please present this Statement of Account upon payment'
  @ prow()+1, 1 say 'ù Please disregard if payment has been made.'

  __eject()

  xlastsa := sanum + lastprnt
  setfont("NORMAL")
  restdbf(mu);restscreen(,,,,bf);setcursor(re);setcolor(gf)

return nil

*********************************
*
*      all clients ( 04/13/2000 )
*
function forms2print()
*********************************
 local mu:=savedbf(),re:=setcursor(),bf:=savescreen(,,,),gf:=setcolor()
 local xacct,amrt_4:={},lcount:=0,lastprnt:=1,sanum:=Parametr->lastsa
 local tot_amort :=0,tot_pnlty := 0,grd_tot:=0,recst_:={},x,nrec
 local ac_set,nrent,cacctno := space(16) ,nswitch := 0,nsubtotal := 0,cclntcode
 local _nntx := Client->(indexord()), _nrecno := Client->(recno())
 local nrec2 := 0, lfound := .f.
 local cunit,npage := 1


 Client->(dbsetorder(1))            // clntcode

 dbselectarea ( xtemp )
 (xtemp)->( dbsetorder(4) )

 setprc   ( 0, 0 )
 setfont  ( 'NLQ' )
 setfont  ( 'ELITE' )

 (xtemp)->(dbgotop())

  if !(xtemp)->(eof())

     do while !(xtemp)->(eof())

        lochead2  ()

        cclntcode := (xtemp)->clntcode
        grd_tot   := 0
        tot_pnlty := 0

        do while !(xtemp)->(eof()) .and. (xtemp)->clntcode == cclntcode

            ac_set := Acctmast->(indexord())
            Acctmast->(dbsetorder(1))
            nrent  := eval ({|| Acctmast->(dbseek( (xtemp)->Acctno )),;
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

            *********do while !(xtemp)->(eof()) .and. .and. (xtemp)->clntcode == cclntcode

            cacctno   := (xtemp)->Acctno
            nswitch   := 0
            nsubtotal := 0

               do while !(xtemp)->(eof())             .and. ;
                         (xtemp)->acctno   == cacctno .and. ;
                         (xtemp)->clntcode == cclntcode

                  if nswitch == 0 .and. prow() <= _MAXROW-5      // d' next 2 lines 'says' must be printed
                                        // once every account number only, abb0412200
                                        //
*************                     @ prow()+1, 1 say Trans( (xtemp)->Acctno,'@R 9999-99999-99999')
*************                     @ prow()+1, 1 say right( alltrim((xtemp)->Acctno),5) + '/'+ padr( (xtemp)->Oldno,16 )
*************                     @ prow()  ,24 say 'Unpaid '+nRent+' for the month(s) of'

                     nrec2  := (xtemp)->(recno())
                     lfound := .f.
                     do while !(xtemp)->(eof()) .and. (xtemp)->acctno == cacctno

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

//                     if lfound
//                        @ prow()  ,pcol()+1 say ' Penalties      Total'
//                     else
//                        @ prow()  ,pcol()+1 say '                Total'
//                     endif

                     nswitch := 1

                  endif

                  if prow() > _MAXROW-5

**********                     @ prow()+5, 1 say 'ù Page '+ trans ( npage,'999,999' )
                     @ prow()+5, 1 say 'ù R.F. '+_get_rate_type(cacctno)
                     @ prow()+1, 1 say 'ù Please present this Statement of Account upon payment'
                     @ prow()+1, 1 say 'ù Please disregard if payment has been made.'

                     __eject ()
                     npage++
                     lochead2()
                  endif

**********                  @ prow()+1, 30 say padr(cmonth( (xtemp)->paydate ),10) + '   '+;
**********                                     alltrim(str(year((xtemp)->paydate )))
**********                  @ prow()  , 62 say tran ( (xtemp)->amort,'999,999,999.99')
**********
                  if lfound
//                     @ prow()+1, 23 say padr(cmonth( (xtemp)->paydate ),3) +'.'+' '+ ;
//                                        alltrim(str(year((xtemp)->paydate )))
                     **********88 @ prow()+1, 23 say paydate
                     @ prow()+1, 23-9 say _get_remterm(cacctno,paydate)+' '+dtoc(paydate)

                     if prow() > _MAXROW-5

**************                        @ prow()+5  , 1 say 'ù Page '+ trans ( npage,'999,999' )
                        @ prow()+5, 1 say 'ù R.F. '+_get_rate_type(cacctno)
                        @ prow()+1, 1 say 'ù Please present this Statement of Account upon payment'
                        @ prow()+1, 1 say 'ù Please disregard if payment has been made.'

                        __eject ()
                        npage++
                        lochead2()
                     endif

                  else
//                     @ prow()+1, 23 say padr(cmonth( (xtemp)->paydate ),3) +'.'+' '+ ;
//                                        alltrim(str(year((xtemp)->paydate )))
************                     @ prow()+1, 23 say paydate
                     @ prow()+1, 23-9 say _get_remterm(cacctno,paydate)+' '+dtoc(paydate)

                     if prow() > _MAXROW-5

**************                        @ prow()+5  , 1 say 'ù Page '+ trans ( npage,'999,999' )
                        @ prow()+5, 1 say 'ù R.F. '+_get_rate_type(cacctno)
                        @ prow()+1, 1 say 'ù Please present this Statement of Account upon payment'
                        @ prow()+1, 1 say 'ù Please disregard if payment has been made.'

                        __eject ()
                        npage++
                        lochead2()
                     endif

                  endif

                  @ prow()  , pcol()+1  say tran ( (xtemp)->amort,'999,999,999.99')

                  if (xtemp)->Penalty  > 0

                    ********* @ prow()+1,24 say 'Plus:Penalty as of '+dtoc( (xtemp)->Paydate)
                    ********* @ prow()  ,62 say tran ( (xtemp)->Penalty  ,'999,999,999.99' )

                    @ prow() , 48 say tran ( round( (xtemp)->Penalty,0)  ,'9,999,999.99' )
                    tot_pnlty += round((xtemp)->Penalty,0)

                  else
                    @ prow() , 48 say space(12)
                  endif

                  if lfound
                     @ prow()  , pcol()+1 say tran ( (xtemp)->amort+round((xtemp)->penalty,0),'999,999,999.99')
                  else
                     @ prow()  , pcol()+1 say tran ( (xtemp)->amort,'999,999,999.99')
                  endif

                  nsubtotal += (xtemp)->amort + round((xtemp)->Penalty,0)
                  grd_tot   += (xtemp)->amort + round((xtemp)->Penalty,0)

                  (xtemp)->(dbskip(+1))

               enddo // !(xtemp)->(eof()) .and. (xtemp)->acctno == cacctno


               @ prow()+1,23   say padr( _get_unit( cacctno),38 )

               if prow() > _MAXROW-5

*****************                  @ prow()+5  , 1 say 'ù Page '+ trans ( npage,'999,999' )
                  @ prow()+5, 1 say 'ù R.F. '+_get_rate_type(cacctno)
                  @ prow()+1, 1 say 'ù Please present this Statement of Account upon payment'
                  @ prow()+1, 1 say 'ù Please disregard if payment has been made.'

                  npage++
                  __eject  ()
                  lochead2 ()
               endif

//               @ prow()  ,62   say repl ( '-',15 )
//               @ prow()+1,29 say 'Sub Total '
//               @ prow()  ,60   say 'P ' + tran(nsubtotal,'999,999,999.99')

               @ prow()+1,62   say repl('-',15)

               if prow() > _MAXROW-5

******************                  @ prow()+5  , 1 say 'ù Page '+ trans ( npage,'999,999' )
                  @ prow()+5, 1 say 'ù R.F. '+_get_rate_type(cacctno)
                  @ prow()+1, 1 say 'ù Please present this Statement of Account upon payment'
                  @ prow()+1, 1 say 'ù Please disregard if payment has been made.'

                  __eject  ()
                  lochead2 ()
                  npage++
               endif


           ******* enddo

        enddo  // !(xtemp)->(eof()) .and. (xtemp)->clntcode == cclntcode

        if tot_pnlty > 0
//           @ prow()+1,29 say 'Total Penalties per client'
           @ prow()+1,29 say 'Penalties        :'
           @ prow()  ,60   say 'P ' + tran( round(tot_pnlty,0) ,'999,999,999.99')
           @ prow()+1,62   say repl('-',15)
        endif

//        @ prow()+1,29 say 'TOTAL AMOUNT DUE PER CLIENT'

        @ prow()+1,29 say    'TOTAL AMOUNT DUE :'
        @ prow()  ,60 say 'P ' + tran(grd_tot,'999,999,999.99')
        @ prow()+1,62 say repl('=',15)

***************        @ prow()+2 , 1 say 'ù Page '+ trans ( npage,'999,999' )
        @ prow()+2 , 1 say 'ù R.F. '+_get_rate_type(cacctno)
        @ prow()+1, 1 say 'ù Please present this Statement of Account upon payment.'
        @ prow()+1, 1 say 'ù Please disregard if payment has been made.'
        npage++

        __eject()

     enddo            // do while !(temp)->(eof())

  endif

********8  @ _MAXROW-5  , 1 say 'ù R.F. '+_get_rate_type(cacctno)
*********  @ _MAXROW-5+1, 1 say 'ù Please present this Statement of Account upon payment'

  __eject()

  xlastsa := sanum + lastprnt
  setfont ( "NORMAL" )

  Client->( dbsetorder ( _nntx   ) )
  Client->( dbgoto     ( _nrecno ) )

  restdbf    ( mu )
  restscreen ( ,,,,bf )
  setcursor  ( re )
  setcolor   ( gf )

  *************8alert ( 'end prntso2()' )

return nil

/*------------------------------*/
Static Function lochead()
/*------------------------------*/

 setprc( 0, 0 )
 /**************
 if pval == 1
   while prow() < 11;@ prow() +1,0 say  ' ';enddo
 elseif pval == 2
   while prow() < 08;@ prow() +1,0 say  ' ';enddo
 elseif pval  == 3
   while prow() < 13;@ prow() +1,0 say  ' ';enddo
 endif
 ****************/

 do while prow() < 6
    @ prow() +1,0 say  ' '
 enddo

 @ prow()+1,0 say microfeed
 @ prow()  ,57+4 say cmonth(xdate) +' '+ str(day(xdate),2)+', '+ str(year(xdate),4)
 @ prow()+1, 0 say ' '
 @ prow()+1, 0 say ' '
 @ prow()+1, 0 say ' '

 @ prow()+2, 8+5 say Client->Fullname
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

*******************************
*
Static Function lochead2()
*******************************

******** alert ( Client->(indexkey()) )

 Client->( dbseek( (xtemp)->clntcode) )

 setprc( 0, 0 )

 do while prow() < 6
    @ prow() +1,0 say  ' '
 enddo

 @ prow()+1,0 say microfeed
 @ prow()  ,57+4 say cmonth(xdate) +' '+ str(day(xdate),2)+', '+ str(year(xdate),4)
 @ prow()+1, 0 say ' '
 @ prow()+1, 0 say ' '
 @ prow()+1, 0 say ' '

 @ prow()+2, 8+5 say Client->Fullname
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
local mu:=savedbf(),re:=setcursor(),bf:=savescreen(,,,),gf:=setcolor()
local tmp_:={},nrecno := Client->(recno())
local bcond := .t.

waiton  ( 'Filtering accounts per client, please wait...',,'n+*/w' )

if lallclients

   ********** alert ( 'all clients' )

   Client->(dbgotop())

   do while !Client->(eof())

      if !lallclients
         bcond := .f.
      else
         xclient := Client->clntcode
      endif

      dbselectarea ( 'Acctmast' )
      Acctmast->   ( dbsetorder(2) )
      Acctmast->   ( dbseek( xclient ) )

      Acctmast->   ( dbeval( {||;
                                if ( Paymode == '2',;
                                      aadd ( tmp_,{ Acctmast->Acctno,;
                                                    Acctmast->Oldno ,;
                                                    Acctmast->Term  ,;
                                                    Acctmast->Unit   ;
                                                 };
                                           ),;
                                      nil ;
                                    ) ;
                             },,;
                             {|| Acctmast->Clntcode == Xclient .and. !Acctmast->(eof()) };
                           );
                  )

      Client->(dbskip(+1))
   enddo
else

     **********alert ( 'one client only' )

      dbselectarea ( 'Acctmast' )
      Acctmast->   ( dbsetorder(2) )
      Acctmast->   ( dbseek( xclient ) )

      Acctmast->   ( dbeval( {||;
                                if ( Paymode == '2',;
                                      aadd ( tmp_,{ Acctmast->Acctno,;
                                                    Acctmast->Oldno ,;
                                                    Acctmast->Term  ,;
                                                    Acctmast->Unit   ;
                                                 };
                                           ),;
                                      nil ;
                                    ) ;
                             },,;
                             {|| Acctmast->Clntcode == Xclient .and. !Acctmast->(eof()) };
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
********local mu := savedbf(),bf:=savescreen(,,,),gf:=setcolor()
local mu := savedbf(),gf:=setcolor()
local re := setcursor(),naccnt:=spac(14),ztemp,xval,nctr := 0
local tmp_:= { { 'ACCTNO'  ,'C',14,0  },;
               { 'CLNTCODE','C', 7,0  },;
               { 'ACCTNAME','C',50,0  },;
               { 'OLDNO',   'C',16,0  },;
               { 'TERM',    'N', 3,0  },;
               { 'UNIT',    'C',40,0  } ;
             }
waiton ( 'Tranfering data...Please wait',,'n*/w' )


ztemp := crea_Xtemp()
DBCREATE ( ztemp,tmp_ )
while !netuse( ztemp,.t.,10 );enddo
index on acctname to &ztemp
dbselectarea ( 'Acctmast' )

Acctmast->   ( dbsetorder(2)  )
Acctmast->   ( dbseek(xclient))

do while Acctmast->Clntcode == xclient .and. !Acctmast->(eof())

   nctr++
/*** ito lang ang naiba sa statement of account no if para pasok lahat ****/
//  if Acctmast->Paymode == '2'

      //dbselectarea('xtemp')
      (ztemp)->(dbappend())
      (ztemp)->Acctno   := Acctmast->Acctno
      (ztemp)->Clntcode := Acctmast->Clntcode
      (ztemp)->Acctname := Acctmast->Acctname
      (ztemp)->Oldno    := Acctmast->Oldno
      (ztemp)->TErm     := Acctmast->Term
      (ztemp)->UNIT     := Acctmast->Unit
//   endif
   Acctmast->(dbskip(+1))

enddo

( ztemp )->(dbcommit())
( ztemp )->(dbsetindex(xtemp))
waitoff ()

// ( ztemp )->(browse())

if (ztemp)->(!eof()) .and. (ztemp)->(!bof())
   
   fshadow(17,32,19,68,2,'n/w')
   set color to 'n/w','w/n',,,'w+/w'
   setcursor(3)
   @ 18,33 say 'Account Number  ' ;
           get naccnt              ;
           pict '@R 9999-99999-99999' ;
           when !empty(nacct:=eval( { || flook_online(.t.,(ztemp),nil,'Account Master File',1,3,2,,1) } ) )   &&!empty(nacct:=eval( { || flook(.t.,(ztemp),nil,'Account Master File',1,3,2,1) } ) )

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
ferase( (ztemp) + '.dbf' )
ferase( (ztemp) + '.ntx' )
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

if !netuse( 'Acctmast', .f., 10 )              && Account master file
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( 'Acctmast' )                    && set index on acctno
   ordlistadd( 'Acctclnt' )                    && index on Clntcode + acctno
endif

if !netuse( 'Paysked', .f., 10 )               && Payment Schedule file
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( 'Paysked' )                     && set index on acctno + paydate
   ordlistadd( 'Paydsked' )                    && set index on paydate
endif

if !netuse('payimage',.f.,5)
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( 'Payimage' )
endif

if !netuse( '&g_Cis_path\Client', .f., 10 )               && Client file
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_Cis_path\Cliecd' )                    && set index on clntcode
   ordlistadd( '&g_Cis_path\Clienm' )                    && set index on Fullname
endif

if !netuse( 'Saformat', .f., 10 )                         && Statement of Account Format file
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( 'Saformat' )                               && set index on clntcode
endif

if !netuse( 'Facility', .f., 10 )                         && Statement of Account Format file
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( 'Fcltycd' )                               && set index on clntcode
endif

if !netuse( 'Parametr', .f., 10 )                         && Parametr file
   break
*--->      && RED 033005
ELSE
   IF NETUSE('&g_AMS_PATH\OL_PARAM',.F.,5)
      SET INDEX TO &g_AMS_PATH\OL_PARAM
      OL_PARAM->(DBSEEK(g_PAR_BRCH))
   ELSE
      BREAK
   ENDIF
*--->
endif

//scrntitle( 'Statement of Account Maintenance', gSYS_NAME, gUSER_ID, gTRANDATE )
//dispbox( 3, 0, maxrow(), maxcol(), space( 9 ), 'n/n' )

return( nil )
/*
         1         2         3         4         5         6         7         8         9         0
1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
               Plus:Penalty as of 06/30/1996
                            TOTAL AMOUNT DUE
*/

/*********************************888
 function prrintforms()

 local mu:=savedbf(),re:=setcursor(),bf:=savescreen(,,,),gf:=setcolor()
 local xacct,amrt_4:={},lcount:=0,lastprnt:=1,sanum:=Parametr->lastsa
 local tot_amort :=0,tot_pnlty := 0,grd_tot:=0,recst_:={},x,nrec
 local ac_set,nrent

 dbselectarea ( xtemp )
 (xtemp)->( dbsetorder(2) )

 setprc ( 0, 0 )

 if pval == 1 .or. pval  == 3
    setfont('NLQ')
    setfont('ELITE')
 elseif pval == 2
    @ prow(),pcol() say chr(27) + chr(58)
 endif

 lochead()

 (xtemp)->(dbgotop())
 do while (xtemp)->(!eof())

     tot_amort:= 0
     tot_pnlty:= 0

     if (xtemp)->grupstat == 1
        xacct:=(xtemp)->Acctno
        do while (xtemp)->Acctno == xAcct .and. (xtemp)->grupstat == 1
           aadd( recst_,(xtemp)->( Recno() ) )
           aadd( amrt_4,(xtemp)->paydate )
           tot_amort += (xtemp)->Amort
           tot_pnlty += round((xtemp)->Penalty,0)
           (xtemp)->( dbskip(+1) )
        enddo
        (xtemp)->( dbskip(-1) )
     elseif (xtemp)->penalty > 0
         aadd( recst_,(xtemp)->( Recno() ) )
         aadd( amrt_4,(xtemp)->paydate )
         tot_amort := (xtemp)->Amort
         tot_pnlty := round((xtemp)->Penalty,0)
     else
         aadd( recst_,(xtemp)->( Recno() ) )
     endif

     asort(amrt_4)
     ac_set := Acctmast->(indexord())
     Acctmast->(dbsetorder(1))
     nrent  := eval ({|| Acctmast->(dbseek( (xtemp)->Acctno )),;
                         Acctmast->Fcltycode ;
                    })
     nrent  := if( eval (  { || Facility->(dbseek(nrent))   ,;
                                Facility->Setcode ;
                           };
                        ) == '1' ,;
                        'Rental',;
                        'Amort.' ;
                     )

     Acctmast->(dbsetorder(ac_set))

     if lcount >=  max2 .and. lcount <> 0
        lastprnt++
        @ prow()+1,58 say repl('-',15)
        @ prow()+1,29 say 'TOTAL AMOUNT DUE'
        @ prow()  ,56 say 'P ' + tran(grd_tot,'999,999,999.99')
        @ prow()+1,58 say repl('=',15)
        grd_tot := 0
        __eject()
        setprc(0,0)
        @ prow()+1,0 say ' '
        lochead()
        lcount:=0
     endif
     nrec := (xtemp)->( recno() )

     lcount++
     @ prow()+1, 0 say ' '
*************     @ prow()+1, 1 say Trans( (xtemp)->Acctno,'@R 9999-99999-99999')  //alltrim((xtemp)->Oldno)
     @ prow()+1, 1 say right( alltrim((xtemp)->Acctno),5) + ' / '+ padr( (xtemp)->Oldno,16 )


     if len(amrt_4) > 1

        ********alert ( ">1" )


        @ prow()  ,20 say 'Unpaid '+nRent+' for the  Month'
        @ prow()+1,20 say 'of '+cmonth(amrt_4[ 1 ] )+" '"+ substr(str( year( amrt_4[1] ),4 ),3,2) +' - '+ ;
                                cmonth(atail(amrt_4))+" '"+ substr(str(year(atail(amrt_4)),4),3,2)
        @ prow()  ,56 say 'P '+ tran(tot_amort,'999,999,999.99')
        @ prow()+1, 0 say ' '

        if tot_pnlty > 0
           @ prow()+1,20 say 'Plus: Penalty as of '+dtoc(xdate)
           @ prow()  ,58 say tran(round(tot_pnlty,0),'999,999,999.99')
        endif

     elseif tot_pnlty < 1

        ********alert ( "<1" )

        @ prow()  ,20 say alltrim(str((xtemp)->paynum,3))+'/'+alltrim(str( (xtemp)->term,3)) + ' Rent Covering '+cmonth((xtemp)->paydate)
        @ prow()  ,56 say 'P '+ tran((xtemp)->Amort,'999,999,999.99')
        @ prow() +1,0 say  ' '
        @ prow()+1,20 say  (xtemp)->Unit
        @ prow()+1, 0 say ' '
        @ prow()+1,20 say 'Due on '+;
                          cmonth( (xtemp)->paydate )    +' ' +;
                          str(day((xtemp)->paydate ),2) +', '+;
                          str(year( (xtemp)->paydate ),4)

        tot_amort+= (xtemp)->amort

     elseif tot_pnlty > 0

        ********** alert ( ">0" )

        @ prow()  ,20 say 'Unpaid '+nRent+' for the  Month'
        @ prow()+1,20 say 'of '+ cmonth(amrt_4[1])+" '"+ substr(str(year(amrt_4[1]),4),3,2)
        @ prow()  ,56 say 'P '+ tran(tot_amort,'999,999,999.99')
        @ prow()+1, 0 say ' '

        if tot_pnlty > 0
           @ prow()+1,20 say 'Plus:Penalty as of '+dtoc( (xtemp)->Paydate)
           @ prow()  ,58 say tran(round(tot_pnlty,0),'999,999,999.99')
        endif

     endif
     recst_ := {}
     amrt_4 := {}

     grd_tot += ( tot_amort + round(tot_pnlty,0) )
     (xtemp)->(dbskip(+1))
  enddo

  @ prow()+1,58 say repl('-',15)
  @ prow()+1,29 say 'TOTAL AMOUNT DUE'
  @ prow()  ,56 say 'P ' + tran(grd_tot,'999,999,999.99')
  @ prow()+1,58 say repl('=',15)
  __eject()
  xlastsa := sanum + lastprnt
  setfont("NORMAL")
  restdbf(mu);restscreen(,,,,bf);setcursor(re);setcolor(gf)
return nil
*****************************/
/*
**********************************
*
*
static function _get_unit(cacctno)
**********************************
local nntx := Acctmast->(indexord()),nrecno := Acctmast->(recno())
local cunit
Acctmast->(dbsetorder(1))              // account number
Acctmast->(dbseek(cacctno))
cunit := Acctmast->unit
Acctmast->(dbsetorder(nntx))
Acctmast->(dbgoto(nrecno))
return cunit

***************************************
*
static function _get_rate_type(cacctno)
***************************************
local nntx    := Acctmast->(indexord()),nrecno := Acctmast->(recno())
local cretval := space (5)
Acctmast->(dbsetorder(1))              // account number
Acctmast->(dbseek(cacctno))

if Acctmast->ratetype != '1'          // != FIXED
   cretval := 'ANNUAL'
endif

Acctmast->(dbsetorder(nntx))
Acctmast->(dbgoto(nrecno))
return cretval
*/
***************************************
*
static function _get_remterm(cacctno,dpaydate)
***************************************
local nntx    := Acctmast->(indexord()),nrecno := Acctmast->(recno())
local cretval := space (5),nremterm := 0,cret2 := ' '
Acctmast->(dbsetorder(1))              // account number
Acctmast->(dbseek(cacctno))

Paysked->(dbseek(cacctno+dtos(dpaydate),.t.))

if Paysked->paynum != 0 .and. Paysked->acctno == cacctno
   nremterm := Paysked->paynum
else
   Payimage->(dbseek(cacctno+dtos(dpaydate),.t.))

   if Payimage->acctno == cacctno
      nremterm := Payimage->paynum
   endif

endif

cretval := padl(alltrim(str(nremterm)),3)+'/'

if Acctmast->term <= 72
   cret2   := padr(alltrim(str(Acctmast->term)),3)
else
   cret2   := padr(alltrim(str(_get_term(Acctmast->acctno))),3)
endif
cretval := cretval + cret2

Acctmast->(dbsetorder(nntx))
Acctmast->(dbgoto(nrecno))
return cretval

***************************************
*
static function _get_term(cacctno)
***************************************
local nntx    := Acctmast->(indexord()),nrecno := Acctmast->(recno())
local nretval := 0
Acctmast->(dbsetorder(1))              // account number
Acctmast->(dbseek(cacctno))

if Payimage->(dbseek(cacctno))

   do while Payimage->acctno == cacctno .and. !Payimage->(eof())
      nretval++
      Payimage->(dbskip(+1))
   enddo

endif

Acctmast->(dbsetorder(nntx))
Acctmast->(dbgoto(nrecno))
return nretval

