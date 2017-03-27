/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   colf-iis -- account management system                                      ³
³   program idúúú amsr0800                                                     ³
³   descriptionúú NOTICE OF TERMINATION                                        ³
³   authorúúúúúúú renan s. evangelista                                         ³
³   dateúúúúúúúúú 9:20:am úú 06-18-96                                          ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                             u p d a t e s                                    ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        who        ³       when        ³               why                    ³
³        mts        ³    12-29-2006     ³   added AMSHIST2                     ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

////
#include 'inkey.ch'
#include 'colf.ch'
#include 'dbstruct.ch'
#include 'achoice.ch'
////
#defi K_SPACEBAR   32
#defi microfeed    chr( 27 ) + 'J' + chr( 18 )
////
#xtran gettermunit   ( <cnum> ) => if( <cnum> == '1'  , 'Day(s)', 'Month(s)' )

memvar  AX_LEVEL, gUSER_ID
setcursor(0)
setblink(.t.)
if !chkpass( procname(), AX_LEVEL, gUSER_ID )
   //NOTHING WILL HAPPEN
else
   begin sequence
	 aOpen1600R()
         while aMain1600R();enddo
   end sequence
   dbcloseall()
endif
__mrelease( '*', .t. )
return nil
/*---------------------------*/
 Static Function aOpen1600R()
/*---------------------------*/
memvar g_GRF_PATH

if !netuse( '&g_AMS_PATH\Amshist',.f.,5 )
   break
else
  //ordlistclear()
  //Ordlistadd('Amshist')
  set index to &g_AMS_PATH\Amshist
endif

if !netuse( '&g_AMS_PATH\AMSBACK\Amshist2',.f.,5 )
   break
else
  //ordlistclear()
  //Ordlistadd('Amshist')
  set index to &g_AMS_PATH\AMSBACK\Amshist2
endif

if !netuse( '&g_GRF_PATH\Personel',.f., 5 )
   break
else
  //ordlistclear()
  //Ordlistadd('&g_GRF_PATH\Personel')
  //set index to '&g_GRF_PATH\Personel'
  set index to '&g_GRF_PATH\Initials'
endif

if !netuse( '&g_AMS_PATH\Accthist',.f.,5 )
   break
else
   set index to &g_AMS_PATH\Acchclnt
endif
if !netuse( '&g_AMS_PATH\Acctmast',.f., 5 )
   break
else
   set index to &g_AMS_PATH\ACCTMAST,;
                &g_AMS_PATH\ACCTCLNT,;
                &g_AMS_PATH\ACCTFA,;
                &g_AMS_PATH\SURECLNT,;
                &g_AMS_PATH\ACCTSUB2,;
                &g_AMS_PATH\ACCTAONM,;
                &g_AMS_PATH\ACCTACNO,;
                &g_AMS_PATH\ACCTREV,;
                &g_AMS_PATH\ACCTSUB,;
                &g_AMS_PATH\ACCTVAL,;
                &g_AMS_PATH\ACCTFCLT,;
                &g_AMS_PATH\ACCTCDFT,;
                &g_AMS_PATH\ACCTCLMT,;
                &g_AMS_PATH\ACCTDAY,;
                &g_AMS_PATH\ACCTMATD
endif
// set index to ACCTMAST

//set index to Acctmast
return nil

/*--------------------------*/
  Static Function aMain1600R()
/*--------------------------*/
local mu:=savedbf(),bf:=savescreen( ,,, ),gf:=setcursor(),ppy:=setcolor(),pt_:={}
local maccnt,cont:=.t.,prnt := .t.,mkey
PRIVATE appray_:={},prepby:=spac(40),chkby:=spac(40),chkby2:=spac(40),noteby:=spac(40)
private _AtranPos := {}, noldrec := 0
private nrec := 0, crec := 0,st_:= {}


//waiton( 'Transferring data..,please wait', .f., 'bg+*/rb', 21)
dbselectarea('Acctmast')
Acctmast->(dbsetorder(1))            //index on acctname
Acctmast->(dbseek(g_PAR_BRCH))

//dbgotop()

// waiton('Processing....',.f.,'n*/w',10 )

//Acctmast->(dbeval({|| nrec++ },,{|| !Acctmast->(eof()) .and. Acctmast->Brcode == g_PAR_BRCH }))
//waitoff()
fshadow(10,25,12,50,2,'w/bg')
//@ 11,31 say repl('±',30 ) color 'w/n'
@ 11,31 say 'Initializing...' color 'w+/bg'

st_:= {}

Acctmast->(dbseek(g_PAR_BRCH))

do while Acctmast->brcode == g_PAR_BRCH .and.;
	 !Acctmast->(eof())


if empty(Acctmast->Osbal) .and. crec <= 4000 .or. Acctmast->Osbal <= 0.00 .and. crec <= 4000

//statterm(crec++,nrec)
crec++

aadd( st_,'  '+Acctmast->Acctno+' ³ '+  ;
    Substr(Acctmast->Acctname,1,30)+' ' )


noldrec := Acctmast->(recno())

endif 

Acctmast->(dbskip(+1))

enddo


*//////////////////

cont:= if(empty(st_), .f., .t. )
optionmen( ' <Arrows>-Up/Down <Space>-Select/Unselect <Enter>-Accept <Esc>-Reject/Exit< ',23)
fshadow( 8,20,20,75,2,'w/n' )
@  9,22 say '  Account Number            Account Name            ' color 'n/w'
@ 10,20 say 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´' color 'w/n'
@ 20,20 say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ         ÄÄÄÄÄ        ÄÄÄÄÙ' color 'w/n'
@ 20,49 say '<F5>-Begin' color 'bg+/n'
@ 20,62 say '<F6>-Next' color 'bg+/n'



for i := 11 to 19
    @ i,39 say '³' color 'w/n'
next i
maccnt:=1

while cont
    setcolor('w/n,n/w')
    maccnt := achoice ( 11,22,19,73, st_,.t.,'myfunc', maccnt,maccnt )
    do case

      case lastkey() == K_F5

         if _Picked()
            error ( 'Please CONFIRM selected account number first' )

	 else

		crec := 0
		maccnt := 0
		st_:= {}

		Acctmast->(dbseek(g_PAR_BRCH))

		do while Acctmast->brcode == g_PAR_BRCH .and.;
	 		!Acctmast->(eof())


		if empty(Acctmast->Osbal) .and. crec <= 4000 .or. Acctmast->Osbal <= 0.00 .and. crec <= 4000

		//statterm(crec++,nrec)
		crec++

		aadd( st_,'  '+Acctmast->Acctno+' ³ '+  ;
    		Substr(Acctmast->Acctname,1,30)+' ' )


		noldrec := Acctmast->(recno())

		endif 

		Acctmast->(dbskip(+1))

		enddo
	 endif

      case lastkey() == K_F6

         if _Picked()
            error ( 'Please CONFIRM selected account number first' )

	 else       

		Acctmast->(dbgoto(noldrec))
		Acctmast->(dbskip(+1))

		if Acctmast->brcode == g_PAR_BRCH

		crec := 0
		maccnt := 0
		st_:= {}

		Acctmast->(dbgoto(noldrec))
		Acctmast->(dbskip(+1))

		do while Acctmast->brcode == g_PAR_BRCH .and.;
	 		!Acctmast->(eof())

			if empty(Acctmast->Osbal) .and. crec <= 4000 .or. Acctmast->Osbal <= 0.00 .and. crec <= 4000

			crec++

			aadd( st_,'  '+Acctmast->Acctno+' ³ '+  ;
    			Substr(Acctmast->Acctname,1,30)+' ' )

			endif 

			noldrec := Acctmast->(recno())

		Acctmast->(dbskip(+1))

		enddo
		else
		alert('END OF FILE')
		
		endif
	endif

      case lastkey() == K_ESC

               if confirm('Exit this process?')
                   cont := .f.
                   appray_:={}
               else
                  loop
               endif

       case lastkey() == K_ENTER //.or. lastkey() == K_ESC
               for i := 1 to len ( st_ )
                   if substr( st_ [i],1,1) == chr(001)//'û'
                      aadd(appray_,alltrim( substr(st_[i],3,14) ) )
                   endif
               next i
               if empty(appray_) .and. confirm('No record/s selected. Continue selecting?')
                  loop
               endif
               cont:=.f.
       case lastkey () == 32
               if substr( st_ [ maccnt ],1,1) = chr(001)//'û'
                  st_ [ maccnt ] := '  ' + substr(st_ [ maccnt ],3,len ( st_ [ maccnt ]  ) - 1 )
               else
                     st_ [ maccnt ] := chr(001)+' '+ substr(st_ [ maccnt ],3,len ( st_ [ maccnt ]  ) - 1 )
                     if maccnt > len ( st_ )
                        maccnt := len ( st_ )
                     endif
               endif

      endcase

    maccnt := maccnt
enddo


if !empty(appray_)

   //fshadow(11,26,16,71,2,'n/w')
   //setcolor('w+/w,w/n,,,n/w')
   //
   //@ 12,28 say '  Prepared by  ' get prepby pict '@!S25' when eval( {|| prepby:= flook(.t.,'Personel',if(!empty(prepby),prepby,nil),;
   //                             'Personnel File',,,,2,,,,,g_GRF_PATH ),.f. } )
   //@ 13,28 say 'Checked by(1)  ' get chkby pict '@!S25' when eval( {|| chkby:= flook(.t.,'Personel',if(!empty(chkby),chkby,nil),;
   //                             'Personnel File',,,,2,,,,,g_GRF_PATH ),.f. } )
   //@ 14,28 say 'Checked by(2)  ' get chkby2 pict '@!S25' when eval( {|| chkby2:= flook(.t.,'Personel',if(!empty(chkby2),chkby2,nil),;
   //                             'Personnel File',,,,2,,,,,g_GRF_PATH ),.f. } )
   //@ 15,28 say '     Noted by  ' get noteby pict '@!S25' when eval( {|| noteby:= flook(.t.,'Personel',if(!empty(noteby),noteby,nil),;
   //                             'Personnel File',,,,2,,,,,g_GRF_PATH ),.f. } )
   //setkey( K_ESC,{|| fescape('Abort?') } )
   //read
   //setkey( K_ESC,nil )

   //if lastkey() <> K_ESC .and. !empty(prepby) .and. !empty(chkby) .and. !empty(chkby2) .and. !empty(noteby)

   if g_names2() == .T. .and. lastkey() <> K_ESC 
      error('You will print no more no less than '+alltrim(str(len(appray_),6))+' page/s.')
      error('Turn on the printer and insert paper< 8.5" x 11" >..,')
      @ 24,00 say repl(' ',80) color 'w/n';@24,00 say padc('şşşşş Printing Notice of Termination şşşşş') color 'w*/n'
      do while !isprinter()
         if !Confirm('Printer is either off or out of paper.,Continue?')
            prnt := .f.
            exit
         endif
      enddo
      if prnt
         set device to print
         for i := 1 to len(appray_)
                
                

Acctmast->(dbseek(g_PAR_BRCH+appray_[i]))

   Amshist->(dbseek(g_PAR_BRCH+appray_[i]))

   if Amshist->(dbseek(g_PAR_BRCH+appray_[i]))
//alert('1')
		
                Amshist->(dbeval( { || nil },,{ || Amshist->brcode + Amshist->Acctno == g_PAR_BRCH + appray_[i] .and.    Amshist->(!eof()) }))
                Amshist->(dbskip(-1))
                if Amshist->Paycode == '3'
                   while Amshist->Paycode == '3'
                         Amshist->(dbskip(-1))
                   enddo
                endif
                prnt16000()      //printing

   else
	 Amshist2->(dbseek(g_PAR_BRCH+appray_[i]))
	 if Amshist2->(dbseek(g_PAR_BRCH+appray_[i]))
//alert('2')
		
                Amshist2->(dbeval( { || nil },,{ || Amshist2->brcode + Amshist2->Acctno == g_PAR_BRCH + appray_[i] .and.    Amshist2->(!eof()) }))
                Amshist2->(dbskip(-1))
                if Amshist2->Paycode == '3'
                   while Amshist2->Paycode == '3'
                         Amshist2->(dbskip(-1))
                   enddo
                endif
                prnt16000B()     //printing   

	 endif
   endif

                trnsfr1600()
		
         next i
         setfont('NORMAL')
         set device to screen
         //set console on
      endif
   endif
//else
//   error('No terminated account/s found.')
endif
//cd:=achoice(10,10,20,60,appray_,.t.)
restscreen(bf);restdbf(mu);setcolor(gf);setcursor(ppy)
return .f.

//////
Static Function statterm(crec,nrec)
//////
@ 11,31 say repl('Û',(crec/nrec) * 30 ) color 'w+/n'

//aga.28.09.2005.test on array fill
//? '  '+Acctmast->Acctno+' ³ '+ Substr(Acctmast->Acctname,1,30)+' '+str(crec)+' '+str(nrec) 

return nil

*****************************
*
static function _Picked()
*****************************
local i := 0
for i := 1 to len ( st_ )
	if substr( st_ [i],1,1) == chr(001) //'û'
           return .t.
	endif
next i

return .f.
/*---------------------*/
  Function Prnt16000()
/*---------------------*/
local xdate:=cmonth(mTrandate)+' '+str(day(mTrandate),2)+', '+str(year(mTrandate),4)
LOCAL x
setprc()
//@ prow()+1,00 say chr(27)+'C'+ '0' + chr(11)
@ prow()+1,00 say ''
setfont('DRAFT')
setfont('ELITE')
@ prow()+1,02 say 'Account Management System'
@ prow(),02+len('Account Management System');
              say Padl(dtoc(date()),95-(len('Account Management System')+2))
@ prow()+1,02 say 'Program ID : AMSR0800'
@ PROW()  ,02+LEN('Program ID : AMSR0800') ;
              SAY Padl(time(),95-(LEN('Program ID : AMSR0800')+2))
@ prow()+1,02 say ''
@ prow()+1,02 say chr(14)
@ prow()  ,02 say padc('NOTICE OF TERMINATION',46)
@ PROW()+1,02 say chr(18)
setfont('NORMAL')
setfont('PICA')
@ prow()  ,02 say padc(xdate,79)
@ PROW()+1,00 SAY ''
@ prow()+1,02 say PADC('DETAILS OF CONTRACT',80)
@ PROW()+1,02 say repl('Ä',77)
@ PROW()+1,00 SAY ''
@ PROW()+1,00 SAY ''
@ prow()+1,02 say 'Account N§             : ' + tran(Acctmast->Acctno,'@R 9999-99999-99999')
@ prow()+1,02 say 'Account Name           : ' + Acctmast->Acctname
@ prow()+1,02 say ' '
@ prow()+1,02 say 'Unit                   : ' + Acctmast->Unit
if !empty( Acctmast->Unit2 )
   @ prow()+1,02 say '                       : ' + Acctmast->Unit2
endif
@ prow()+1,02 say ''
@ prow()+1,02 say 'Date Executed          : ' + dtoc(Acctmast->Valdate)
@ prow()  ,45 say 'Guaranty Deposit : ' + trans( (Acctmast->Gd/100) * Acctmast->Principal,'999,999,999.99')
@ prow()+1,02 say 'Term                   : ' + str(Acctmast->Term,3) + ' ' + Gettermunit(Acctmast->Termunit )
@ prow()  ,45 say 'Residual Value   : ' + trans( (Acctmast->Rv/100) * Acctmast->Principal,'999,999,999.99')
@ prow()+1,02 say 'Net Proceeds           : ' + trans(Acctmast->Principal,'999,999,999.99')
@ prow()  ,45 say 'Amortization     : ' + trans(Acctmast->Amort,'999,999,999.99')
@ prow()+1,02 say ''
@ prow()+1,02 say 'Date of Last Payment   : '+ dtoc( Amshist->Paydate )
@ prow()+1,02 say 'Amount of Last Payment : '+ trans(Amshist->Oramount,'999,999,999.99')
@ prow()+1,02 say ''
@ prow()+1,02 say 'Outstanding Amort      : '+ trans(Acctmast->Osbal,'999,999,999.99')
@ prow()+1,02 say ''
@ prow()+1,02 say 'Date Terminated        : '+ dtoc( Amshist->Paydate )
@ prow()+1,02 say 'Reason for Termination : FULLY PAID'
@ prow()+1,02 say ''
@ PROW()+1,02 say repl('Ä',77)
@ prow()+1,02 say ''
@ prow()+1,02 say ''
@ prow()+1,02 say 'Prepared by : '+repl('_',30)
@ prow()+1,16 say padr(alltrim(Prepby),30)
@ prow()+1,02 say ''
@ prow()+1,02 say ''
@ prow()+1,02 say 'Checked by  : '+repl('_',30) +'  '+ repl('_',30)
@ prow()+1,16 say padr(alltrim(chkby),30)
@ prow()  ,16+30+2 say padr(alltrim(chkby2),30)
@ prow()+1,02 say ''
@ prow()+1,02 say ''
@ prow()+1,02 say 'Noted by    : '+repl('_',30)
@ prow()+1,16 say padr(alltrim(noteby),30)
__eJECT()
//@ prow(),00 say chr(12)
return nil

/*---------------------*/
  Function Prnt16000B()
/*---------------------*/
local xdate:=cmonth(mTrandate)+' '+str(day(mTrandate),2)+', '+str(year(mTrandate),4)
LOCAL x
setprc()
//@ prow()+1,00 say chr(27)+'C'+ '0' + chr(11)
@ prow()+1,00 say ''
setfont('DRAFT')
setfont('ELITE')
@ prow()+1,02 say 'Account Management System'
@ prow(),02+len('Account Management System');
              say Padl(dtoc(date()),95-(len('Account Management System')+2))
@ prow()+1,02 say 'Program ID : AMSR0800'
@ PROW()  ,02+LEN('Program ID : AMSR0800') ;
              SAY Padl(time(),95-(LEN('Program ID : AMSR0800')+2))
@ prow()+1,02 say ''
@ prow()+1,02 say chr(14)
@ prow()  ,02 say padc('NOTICE OF TERMINATION',46)
@ PROW()+1,02 say chr(18)
setfont('NORMAL')
setfont('PICA')
@ prow()  ,02 say padc(xdate,79)
@ PROW()+1,00 SAY ''
@ prow()+1,02 say PADC('DETAILS OF CONTRACT',80)
@ PROW()+1,02 say repl('Ä',77)
@ PROW()+1,00 SAY ''
@ PROW()+1,00 SAY ''
@ prow()+1,02 say 'Account N§             : ' + tran(Acctmast->Acctno,'@R 9999-99999-99999')
@ prow()+1,02 say 'Account Name           : ' + Acctmast->Acctname
@ prow()+1,02 say ' '
@ prow()+1,02 say 'Unit                   : ' + Acctmast->Unit
if !empty( Acctmast->Unit2 )
   @ prow()+1,02 say '                       : ' + Acctmast->Unit2
endif
@ prow()+1,02 say ''
@ prow()+1,02 say 'Date Executed          : ' + dtoc(Acctmast->Valdate)
@ prow()  ,45 say 'Guaranty Deposit : ' + trans( (Acctmast->Gd/100) * Acctmast->Principal,'999,999,999.99')
@ prow()+1,02 say 'Term                   : ' + str(Acctmast->Term,3) + ' ' + Gettermunit(Acctmast->Termunit )
@ prow()  ,45 say 'Residual Value   : ' + trans( (Acctmast->Rv/100) * Acctmast->Principal,'999,999,999.99')
@ prow()+1,02 say 'Net Proceeds           : ' + trans(Acctmast->Principal,'999,999,999.99')
@ prow()  ,45 say 'Amortization     : ' + trans(Acctmast->Amort,'999,999,999.99')
@ prow()+1,02 say ''
@ prow()+1,02 say 'Date of Last Payment   : '+ dtoc( Amshist2->Paydate )
@ prow()+1,02 say 'Amount of Last Payment : '+ trans(Amshist2->Oramount,'999,999,999.99')
@ prow()+1,02 say ''
@ prow()+1,02 say 'Outstanding Amort      : '+ trans(Acctmast->Osbal,'999,999,999.99')
@ prow()+1,02 say ''
@ prow()+1,02 say 'Date Terminated        : '+ dtoc( Amshist2->Paydate )
@ prow()+1,02 say 'Reason for Termination : FULLY PAID'
@ prow()+1,02 say ''
@ PROW()+1,02 say repl('Ä',77)
@ prow()+1,02 say ''
@ prow()+1,02 say ''
@ prow()+1,02 say 'Prepared by : '+repl('_',30)
@ prow()+1,16 say padr(alltrim(Prepby),30)
@ prow()+1,02 say ''
@ prow()+1,02 say ''
@ prow()+1,02 say 'Checked by  : '+repl('_',30) +'  '+ repl('_',30)
@ prow()+1,16 say padr(alltrim(chkby),30)
@ prow()  ,16+30+2 say padr(alltrim(chkby2),30)
@ prow()+1,02 say ''
@ prow()+1,02 say ''
@ prow()+1,02 say 'Noted by    : '+repl('_',30)
@ prow()+1,16 say padr(alltrim(noteby),30)
__eJECT()
//@ prow(),00 say chr(12)
return nil

/*--------------------------*/
 Static Function trnsfr1600()
/*--------------------------*/
local mu:=savedbf()
//@ 24,00 say repl(' ',80) color 'w/n';@24,00 say padc('şşşşş Transferring data to Account History File. şşşşş') color 'w*/n'
dbselectarea('Acctmast')
if Acctmast->(netlock('R',0))
   dbselectarea('Accthist')
   Accthist->(dbsetorder(1))

   if netlock( 'A',0 )
     Accthist->Acctno      := Acctmast->Acctno
     Accthist->Clntcode    := Acctmast->Clntcode
     Accthist->Acctname    := Acctmast->Acctname
     Accthist->Refno       := Acctmast->Refno
     Accthist->Aocode      := Acctmast->Aocode
     Accthist->Fcltycode   := Acctmast->Fcltycode
     Accthist->Principal   := Acctmast->Principal
     Accthist->Paytype     := Acctmast->Paytype
     Accthist->Term        := Acctmast->Term
     Accthist->Termunit    := Acctmast->Termunit
     Accthist->Remterm     := Acctmast->Remterm
     Accthist->Truerate    := Acctmast->Truerate
     Accthist->Ratetype    := Acctmast->Ratetype
     Accthist->Surety      := Acctmast->Surety
     Accthist->Unit        := Acctmast->Unit
     Accthist->Unit2       := Acctmast->Unit2
     Accthist->Addon       := Acctmast->Addon
     Accthist->Gd          := Acctmast->Gd
     Accthist->Rv          := Acctmast->Rv
     Accthist->Factor      := Acctmast->Factor
     Accthist->Dlrcode     := Acctmast->Dlrcode
     Accthist->Salesrep    := Acctmast->Salesrep
     Accthist->Purcamt     := Acctmast->Purcamt
     Accthist->Downpay     := Acctmast->Downpay
     Accthist->Incentive   := Acctmast->Incentive
     Accthist->Nerate      := Acctmast->Nerate
     Accthist->Trantype    := Acctmast->Trantype
     Accthist->Notfctn     := Acctmast->Notfctn
     Accthist->Colexion    := Acctmast->Colexion
     Accthist->Recourse    := Acctmast->Recourse
     Accthist->Obligor     := Acctmast->Obligor
     Accthist->Colatrl     := Acctmast->Colatrl
     Accthist->Tdsassign   := Acctmast->Tdsassign
     Accthist->Tdsfield    := Acctmast->Tdsfield
     Accthist->User_id     := Acctmast->User_id
     Accthist->Amort       := Acctmast->Amort
     Accthist->Credamt     := Acctmast->Credamt
     Accthist->Docref      := Acctmast->Docref
     Accthist->Valdate     := Acctmast->Valdate
     Accthist->Condate     := Acctmast->Condate
     Accthist->Paymode     := Acctmast->Paymode
     Accthist->Payfreq     := Acctmast->Payfreq
     Accthist->Revfreq     := Acctmast->Revfreq
     Accthist->Cltrltype   := Acctmast->Cltrltype
     Accthist->Unitcode    := Acctmast->Unitcode
     Accthist->Credtype    := Acctmast->Credtype
     Accthist->Unitloca    := Acctmast->Unitloca
     Accthist->Firstdue    := Acctmast->Firstdue
     Accthist->Matdate     := Acctmast->Matdate
     Accthist->Currcode    := Acctmast->Currcode
     Accthist->Orixunit    := Acctmast->Orixunit
     Accthist->Oldno       := Acctmast->Oldno
     Accthist->Status      := Acctmast->Status
     Accthist->Revdate     := Acctmast->Revdate
     Accthist->Mrr_rate    := Acctmast->Mrr_rate
     Accthist->Tb_rate     := Acctmast->Tb_rate
     dbunlock()
     dbcommit()
   endif
   dbselectarea('Acctmast')
   // Acctmast->(dbdelete())
   // Acctmast->(dbunlock())
endif
restdbf(mu)
return nil

/*
*******************************************************
*
Static function marvz3( status, curr_elem, curr_row )
*******************************************************
   local key := lastkey()
   local __nctr := 0, getlist := {}, menulist := {}

   do case
      case key == K_ESC
         return 0
      case key == K_ENTER
         return 0
      case key == 32
          tone( 1600, 1) ; tone( 800, 1)
         tone( 800, 1)
         return 1
    endcase
return 2
*/

/*-------------------------*/
 Function creattemp()
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

//aga.13.05.2005.new and improved g_names2()...yay!
*******************************
static function g_names2()
*******************************
memvar prepby , chkby, chkby2, noteby
local  getlist := {}, ax := setcolor()

private entryname [4]
entryname [1] := entryname [2] := entryname [3] := entryname [4] := space(40)

fshadow(11,26,16,71,2,'n/w')
setcolor('w+/w,w/n,,,n/w')

@ 12, 28 say '  Prepared by  ' gget entryname[1] picture '@xs25'            ;
         when lastkey() != K_ESC valid !empty( prepby := get_initial(entryname[1], 1, 11, 45, 25 ) )
@ 13, 28 say 'Checked by(1)  ' gget entryname[2] picture '@xS25'            ;
         when lastkey() != K_ESC valid !empty( chkby  := get_initial(entryname[2], 2, 11, 45, 25 ) )
@ 14, 28 say 'Checked by(2)  ' gget entryname[3] picture '@xS25'            ;
         when lastkey() != K_ESC valid !empty( chkby2   := get_initial(entryname[3], 3, 11, 45, 25 ) )
@ 15, 28 say '     Noted by  ' gget entryname[4] picture '@xS25'            ;
         when lastkey() != K_ESC valid !empty( noteby   := get_initial(entryname[4], 4, 11, 45, 25 ) )

setcursor ( 3 )
read   
setcursor ( 0 )
setcolor  ( ax )

return( lastkey()!=K_ESC )
//.........................................

/*
123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
         1         2         3         4         5         6         7    a    8         0

 Date Executed          : 999,999,999.99    Guaranty Deposit : 999,999,999.99

                   ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                   ³   Account Number            Account Name             ³
                   ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
                   ³ & 12345678901234 ³ 123456789012345678901234567890    ³
                   ³                  ³                                   ³
                   ³                  ³                                   ³
                   ³                  ³                                   ³
                   ³                  ³                                   ³
                   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                   */
