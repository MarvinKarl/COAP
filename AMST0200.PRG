/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³   colf-iis -- account management system                                  ³
 ³   program idúúú amst0200                                                 ³
 ³   descriptionúú Accounts Pretermination                                  ³
 ³   authorúúúúúúú renan s. evangelista                                     ³
 ³   dateúúúúúúúúú 9:20:am úú 07-24-96                                      ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³                             u p d a t e s                                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³        who        ³       when        ³               why                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 */
///////Program not yet installed
//error('Program not yet installed.....')
#include 'inkey.ch'
#include 'colf.ch'

#xtran getpaytype    ( <cnum> ) => if( <cnum> == ' ' ,'          ',;
                                   if( <cnum> == '1'  , 'In Advance', 'In Arrears' ) )
#xtran gettermunit   ( <cnum> ) => if( <cnum> == ' '  , '      ',;
                                   if( <cnum> ==  '1'  , 'Day(s)', 'Month(s)' ) )

local mu:=savescreen( ,,, )
memvar  AX_LEVEL, gUSER_ID

setcursor(0)
setblink(.t.)
if !chkpass( procname(), AX_LEVEL, gUSER_ID )
   //NOTHING WILL HAPPEN
else
   begin sequence
	 aMsopen0300()
	 amsmMain0300()
   end sequence
   dbcloseall()
endif
setcursor(0)
restscreen( ,,,,mu )
__mrelease( '*', .t. )
return nil

/*----------------------------*/
 Static Function aMsopen0300()
/*----------------------------*/

if !netuse('Acctmast',.f.,5)
   break
else
   ordlistclear()
   ordlistadd('AcctSub2')       //open index file for Acctmast
   ordlistadd('Acctacno')       // acctname
   dbsetorder(1)
endif

if !netuse('Tpreterm',.f.,5)
   break
else
   ordlistclear()
   ordlistadd('Tpreterm')       //open index file Tpreterm
   //ordlistadd('Tpreterm2')
endif
return nil
/*-----------------------------*/
 Static Function amsmMain0300()
/*-----------------------------*/

local mu:=savescreen(,,,),npreval
private appflg:=.f.,trec := 0, cval := 1, cpos := 5,lrr:= 5

if Acctmast->(bof()) .and. Acctmast->(Eof())
   error('Error:Account Master File is empty.')
   break
endif
scrntitle( 'Account Pretermination', gSYS_NAME, gUSER_ID, gTRANDATE )
dispbox( 3, 0, maxrow(), maxcol(), space( 9 ), 'n/n' )
optionmen( '<Ins>-Add <F2>-Edit <F4>-Search <Del>-Delete <Esc>-Exit<',23 )
setcolor('w/n')
baks(3,2,22,77,,'w/n')

@ 11,2 say 'Æ'  color 'w/n'
@ 11,col() say repl('Í',74 )  color 'w/n'
Tpreterm->(Dbgotop())
Tpreterm->( dbeval({|| trec++ },,{ || Tpreterm->(!eof()) } ) )
Tpreterm->(Dbgotop())
//Acctmast->(dbseek(substr(Tpreterm->Acctno,-5,5),.f.) )
if ( Tpreterm->(eof()) .and. Tpreterm->(bof())) .or.  !Acctmast->(dbseek(substr(Tpreterm->Acctno,-5,5), .f.) )
    Acctmast->(Dbgobottom())
    Acctmast->(dbskip())
endif
fshowstat()
scrn_rfrsh(@npreval)
while eval( {| x | dispamsm0300(@npreval), scrn_rfrsh(npreval), x:= amsm0300key(npreval) } ) ;enddo
restscreen(,,,,mu)
return .f.

/*-------------------------------*/
 Static Function dispamsm0300(npreval)
/*-------------------------------*/

local nslvrate,mu:=savescreen( ,,, )

if (Tpreterm->(eof()) .and. Tpreterm->(bof())) .or. empty(Tpreterm->Acctno)
   appflg:=.t.
   Acctmast->(Dbgobottom())
   Acctmast->(dbskip())
else
   appflg:=.f.
   Acctmast->(Dbseek(substr(Tpreterm->Acctno,-5,5), .f.))
endif
return nil

/*-------------------------------*/
 Static Function scrn_rfrsh(npreval)         //Refresh screen display
/*-------------------------------*/

local lcol := 0

@ 04,04    say '  Account Number : '                         color 'w/n'
@ 04,col() say Substr( Acctmast->Acctno, -5, 5 ) + ' '+ ;
	       Substr( Acctmast->Acctname,1,40 )             color 'w+/n'
@ 06,04    say '    Net Proceeds : '                         color 'w/n'
@ 06,col() say Trans( Acctmast->Principal,'999,999,999.99')  color 'w+/n'
@ 06,44    say ' Payment Type : '                            color 'w/n'
@ 06,col() say Acctmast->Paytype + ' ' +;
		 getpaytype( Acctmast->Paytype )             color 'w+/n'
@ 07,04    say '    Present Rate : '                         color 'w/n'
@ 07,col() say Trans(Acctmast->Truerate,'99.9999')           color 'w+/n'
@ 07,44    say ' Amortization : '                            color 'w/n'
@ 07,col() say Trans( Acctmast->Amort,'999,999,999.99' )     color 'w+/n'
@ 08,04    say '   Original Term : '                         color 'w/n'
@ 08,col() say Trans( Acctmast->Term,'999') + ' ' +;
		 gettermunit( Acctmast->Termunit )           color 'w+/n'
@ 08,44    say '  O/S Balance : '                            color 'w/n'
@ 08,col() say Trans( Acctmast->Osbal,'999,999,999.99')      color 'w+/n'
@ 09,04    say '  Remaining Term : '                         color 'w/n'
@ 09,col() say Trans( Acctmast->Remterm,'999') + ' ' + ;
		 gettermunit( Acctmast->Termunit )           color 'w+/n'
@ 09,44    say 'Present Value : '                            color 'w/n'
@ 09,col() say Trans( (npreval:=agetpremval()),'999,999,999.99') color 'w+/n'
//////region below
@ 13,32    say 'SLV Rate : '                                 color 'w/n'
@ 13,lcol:=col() say Tran( Tpreterm->Slvrate * 100 ,'99.99');
                     + '%'                                   color 'w+/n'
@ 14,lcol  say repl('=',5)                                   color 'w/n'
@ 15,19    say 'Pretermination Amount : '                    color 'w/n'
@ 15,lcol:=col() say tran( Tpreterm->Preterm,'999,999,999.99') color 'w+/n'
@ 16,lcol  say repl('=',14)                                  color 'w/n'
return nil

/*----------------------------------*/
 Static Function amsm0300key(npreval)
/*----------------------------------*/

 local nkey,nflg:=.t. ,recnum:=0,x
 local o_sel
 if !appflg
    nkey:=  inkey(0)
 else
    nkey:=  22
 endif
 do case
   case nkey == K_PGUP .or. nkey == K_UP
	Tpreterm->(dbskip( -1 ))
	if Tpreterm->(bof())
	   waiton( 'Beginning of file!' )
	   waitoff()
	   Tpreterm->(dbgotop())
           cval:=1
        else
           cval--
	endif
        
	Acctmast->(Dbseek(substr(Tpreterm->Acctno,-5,5), .f.))
   case nkey == K_PGDN .or. nkey == K_DOWN
	Tpreterm->(dbskip())
	if Tpreterm->(eof())
	   waiton( 'End of file!' )
	   waitoff()
	   Tpreterm->(dbskip( -1 ))
           cval := trec
        else
           cval++
	endif
	Acctmast->(Dbseek(substr(Tpreterm->Acctno,-5,5), .f. ))
   case nkey == K_END              //recnum:= Tpreterm->(lastrec())
	Tpreterm->(dbgobottom())
        cval := trec
	Acctmast->(Dbseek(substr(Tpreterm->Acctno,-5,5), .f. ))
   case nkey == K_HOME
	Tpreterm->(dbgotop())
        cval := 1
	Acctmast->(Dbseek(substr(Tpreterm->Acctno,-5,5), .f. ))
    case nkey == K_INS            //review another account
	 if agetamsm0300()
	    sw := checktrev( Substr( Acctmast->Acctno,-5,5 ) )
	    if(sw,eval( {|| scrn_rfrsh(@npreval),geTpreterm1('1',npreval,,) } ),nil )
	    nflg:=.t.
            trec++
	 else
	    if (Tpreterm->(eof()) .and. Tpreterm->(bof())) .or. empty(Tpreterm->Acctno)
	       nflg:= .f.
	    endif
	 endif
    case nkey == K_F2            //review the current account
	 geTpreterm1('2',npreval,,)
	 nflg:=.t.
    case nkey == K_F4            //search account to be review
	if Tpreterm->(!eof()) .and. Tpreterm->(!bof())
	   agetamsm0300(.f.)
	   Acctmast->(Dbseek(substr(Tpreterm->Acctno,-5,5), .f. ))
	endif
	nflg:=.t.
    case nkey == K_DEL          //delete current account in the Tpreterm file
	 if Tpreterm->(!eof()) .and. Confirm('Delete this record<'+Trans(Tpreterm->Acctno,'@R 99999-9999-99999')+'>?')
            o_sel := selec()
            Dbselectarea('Tpreterm')
	    //Tpreterm->(Rlock())
            if netlock( 'R',5 )
	       Tpreterm->(dbdelete())
	       Tpreterm->(dbunlock())
	       Tpreterm->(dbskip())
	       if Tpreterm->(eof()) .and. !Tpreterm->(bof())
	          Tpreterm->(dbskip(-1))
	       endif
               if (Tpreterm->(eof()) .and. Tpreterm->(bof())) .or. empty(Tpreterm->Acctno)
                  Acctmast->(dbgobottom())
                  Acctmast->(dbskip())
               else
	          Acctmast->(Dbseek(substr(Tpreterm->Acctno,-5,5), .f. ))
               endif
               trec--
            endif
            dbselectarea(o_sel)
	 endif
	 nflg:=.t.
    case nkey == K_F5            //edit status of current account
	 geTpreterm1('2',npreval,.t.)
	 nflg:=.t.
    case nkey == K_ESC          //exit module
	 if Confirm('Are you sure you want to Exit?')
	    nflg:=.f.
	 endif
 otherwise
   tone(800,1)
   nflg:=.t.
 endcase
 lrr := if( cval == 1, 5,if( ( (cval/trec) * 16 ) + 4 < 5, 5,( (cval/trec) * 16 ) + 4) )
 fshowstat()
 return nflg

/*--------------------------*/
 Static Function fshowstat()
/*--------------------------*/
local mu,tpos := 16
//mu:=if((cval/trec) * cpos < 1, 1, (cval/trec) * tpos )
@ cpos,77 say '°' color 'w+/n'
@ lrr, 77 say 'Û' color 'w+/n'
cpos := lrr
return nil

/*-----------------------------*/
 Static Function agetamsm0300(sw)
/*-----------------------------*/

local naccnt:=spac(5),st:=setcursor(),tl:=savescreen(,,,),nselect:= alias(),nord:=(alias())->(indexord())
local nretval:=.t.,o_sel

sw:=if( sw == nil,.t.,sw )
if sw
  dbselectarea('Acctmast')
  dbsetorder(1)
else
  dbselectarea('Tpreterm')
  dbsetorder(1)
endif
fshadow( 9,18,11,50,2,'w+/w' )
setcolor('n/w,w/n,,,w+/w')
setcursor(1)
o_sel:= Acctmast->(indexord())
@ 10,20 say 'Account Number  ' get naccnt pict '@R 99999' when if( sw,eval({ || Acctmast->(dbsetorder(2)),naccnt := substr( flook_online(.t.,'Acctmast',nil,'Master File',3,1,2,,1),-5,5),;     &&flook(.t.,'Acctmast',nil,'Master File',3,1,2,1),-5,5),;
                                                           Acctmast->(dbsetorder(o_sel)),.t.}),.t.) ;
                                                           valid ncheckacct(naccnt,sw)
setkey(K_ESC,if(sw, { || fescape('Abort?') },nil ) )
read
if lastkey() == K_ESC
   nretval := .f.
endif
setkey(K_ESC,NIL)
setcursor(st)
restscreen(,,,,tl)
return nretval

/*--------------------------------*/
 Static Function ncheckacct(naccnt,sw)
/*--------------------------------*/

 local nretval:=.f.,nrec:=Tpreterm->(recno()),nset
 naccnt:=right('00000'+ alltrim(naccnt),5)

 if dbseek(naccnt,.f.)
    if sw
       if !Tpreterm->( dbseek( naccnt, .f.) )
           nretval:=.t.
       else
          error('Error:Record already exists.')
       endif
    else
       nretval :=.t.
    endif
 else
    error('Error:Record Not found.')
    Tpreterm->(dbgoto(nrec))
 endif
 return nretval



/*--------------------------------*/
 Static Function checktrev(nacct)
/*--------------------------------*/

 local gf:=Savedbf(),nretval:=.t.
 dbselectarea('Tpreterm')
 dbsetorder(1)
 if dbseek(nacct,.f.)
     nretval := .f.
 endif
 restdbf(gf)
 return nretval


/*---------------------------------*/
 Static Function geTpreterm1(nmode,npreval,nsearch)    //nwhat, nslvrate, ntbrate, neffdate, napp_tr, ncomp_tr, nstatus, npreval, napp_amrt, ncomp_amrt )
/*---------------------------------*/

local nslvrate,npreterm:= 0,mu:=savescreen( ,,, )
local mryt1:=43
local bf:=setcursor(),nretval
local mratechoices := { ' 1 -  9 % ' ,  ' 2 - 15 % ' }

initialval( Substr(Acctmast->Acctno,-5,5 ),nslvrate)
setcolor('w/n,n/w,,,w+/n')
setcursor(1)
while .t.
  @ 13, mryt1 get nslvrate   pict '99.99' when chkrate( mratechoices, @nslvrate, 5, mryt1,@npreterm )
  setkey(K_ESC,{ || fescape('Abort?') } )
  read
  setkey(K_ESC,nil)
  if lastkey() == K_RETURN .and. Confirm('Are all entries correct?')
     nretval:= .t.
     exit
  elseif lastkey() == K_ESC
     nretval:= .f.
     exit
  endif
enddo
altd()
if lastkey() <> K_ESC
   dbselectarea('Tpreterm')
   if( nmode=='1',netlock('A',5),netlock('R',5) )
   Tpreterm->Acctno   := Acctmast->Acctno
   Tpreterm->Preterm  := npreterm
   Tpreterm->Slvrate  := nslvrate
   Tpreterm->Valdate  := Acctmast->Valdate
   dbunlock()
   dbcommit()
elseif lastkey() == K_ESC
   if Tpreterm->(eof()) .or. Tpreterm->(bof())
      setcursor(bf)
      setcolor(mu)
      break
   endif
endif
setcursor(bf)
setcolor(mu)
return nretval

/*-----------------------------------------*/
 Static Function initialval(nacct,nslvrate)
/*-----------------------------------------*/

 local gf:=Savedbf()
 dbselectarea('Tpreterm')
 dbsetorder(1)
 dbseek(nacct,.f.)
 nslvrate     := Tpreterm->Slvrate
 restdbf(gf)
 return nil

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-----------ÄÄÄ*/
   static function chkrate(mstatchoices, mrate, mROW, mCOL, npreterm )
/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ------------ÄÄ*/

   local tstat:=if(mrate == nil,'1',if( mrate == 0.15,'2','1'))
   tstat := gen_achoice ( mstatchoices, val ( tstat ), 'SLV Rate',14, 62, 17, 78, 'W/GR+,W/N,,,W/GR+')
   if lastkey() <> K_ESC
      mrate := if( tstat == '1', 0.09, 0.15 )
      @ 15, 43 say tran(npreterm:=calcpreterm(mrate),'999,999,999.99')  color 'w+/n'
   endif
  return .f.

/*-------------------------------------------*/
 Static function calcpreterm(mrate)
/*-------------------------------------------*/

 local mratemth,mup,mdown,mpreterm
 //mratemth := (mrate /100 ) / 12
 mUp      := 1 - ( 1 + ( mrate/Acctmast->Remterm ) ) ** (-(Acctmast->Remterm - 1))
 mDown    := mrate/Acctmast->Remterm
 mpreterm := Acctmast->Amort * ( ( mUp/mDown ) + 1 )
 return  mpreterm

/*-----------------------------*/
  Static Function agetpremval()
/*-----------------------------*/

 local mratemo,mup,mdown,mpvalue:=0
 mratemo := ( Acctmast->Truerate/100 )/ 12
 mup     := mratemo * ( ( 1 + mratemo) ** Acctmast->Remterm )
 mdown   := (( 1 +  mratemo) ** Acctmast->RemTerm) - 1
 mpvalue := if( (Acctmast->Amort == 0 .or. mup == 0 .or. mdown == 0 ), 0,;
                Acctmast->Amort/ (mup/mdown) )
 return mpvalue


 /*
	    1         2         3         4         5         6         7         7
  012345678901234567890123456789012345678901234567890123456789012345678901234567890
 1
 2
 3  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 4  ³   Account Number : 99999 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX         ³
 5  ³                                                                          ³
 6  ³     Net Proceeds : 999,999,999.99        Payment Type : 9 XXXXXXXX       ³
 7  ³     Present Rate :                       Amortization : 999,999,999.99   ³
 8  ³    Original Term :                        O/S Balance : 999,999,999.99   ³
 9  ³   Remaining Term :                      Present Value : 999,999,999.99   ³
10  ³                                                                          ³
11  ÆÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍµ
12  ³                                                                          ³
13  ³                                                                          ³
14  ³                             SLV Rate : 99.99                             ³
15  ³                             ----------------                             ³
16  ³                                                                          ³
17  ³                Pretermination Amount : 999,999,999.99                    ³
18  ³                                        ==============                    ³
19  ³                                                                          ³
20  ³                                                                          ³
21  ³                                                                          ³
22  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
