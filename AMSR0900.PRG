/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   Colfsys --  Account Management System                                      ³
³   Program idúúú AMSR0900                                                     ³
³   Descriptionúú Printing of Collection Letters                               ³
³   Authorúúúúúúú Engr. Michael B. Espina                                      ³
³   Dateúúúúúúúúú 9:33:24 am úú 05-16-2000                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                             U P D A T E S                                    ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        who        ³       when        ³               why                    ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        aga        ³  14.02.2007       ³ neo paysked support for modules      ³                                                                   
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
////
#include 'inkey.ch'
#include 'colf.ch'
#include 'dbstruct.ch'
////
#defi K_SPACEBAR   32
#defi microfeed    chr( 27 ) + 'J' + chr( 18 )
memvar  AX_LEVEL, gUSER_ID

setcursor(0)

if !chkpass( procname(), AX_LEVEL, gUSER_ID )
   //NOTHING WILL HAPPEN
else
   begin sequence
         aOpen0900()
         aMain0900()
   end sequence
   dbcloseall()
endif
__mrelease( '*', .t. )
return nil

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
 Static Function aMain0900()
/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

 local mu:=savescreen(,,,),gf:=savedbf(),bf:=setcursor()
 private mmonth := month(gtrandate), myear := year(gtrandate)
 private  accts:={}, ctr,nacctno:=space(7+3)       && RED 070805 ADDED '+3

 fshadow( 11,30,13,60,2,'n/bg' )
 @ 12, 31 say 'Account Number  ' get nacctno picture '@R 9999999' when eval( { || getacctno(), .f. } )
 read
 restdbf(gf);restscreen(,,,,mu);setcursor(bf)
 letter_option()
 return nil

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
 Static function xgetno()
/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
local ndbf:=select(),nclntno:=space(7),nval,mu
local o_scr:=savescreen(,,,),msel,xx_,mclntcode
local col_ := { ;
               tbcolumnnew( 'Client Name ' , { || Substr(Client->Fullname, 1, 30 ) } ),;
               tbcolumnnew( 'Short Name '  , { || Client->Shrtname } ),;
               tbcolumnnew( 'Code '        , { || Client->Clntcode } ) }

nval:=.t.
Client->(dbsetorder(2))
*nclntno :=flook( .t.,'Client','space(30)','Client File',3,4,1,1,.f.,col_ )
nclntno :=flook_online( .t.,'Client','space(30)','Client File',3,4,1,,1,.f.,col_ )
restscreen(,,,,o_scr)
dbselectarea(ndbf)

return nclntno

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
 Static function getacctno()
/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
local ndbf:=select(),nclntno:=space(7+3),nval,mu            && RED 070805 ADDED '+3
local o_scr:=savescreen(,,,),msel,xx_,mclntcode
local col_ := { ;
               tbcolumnnew( 'Client Name ' , { || Substr(Client->Fullname, 1, 30 ) } ),;
               tbcolumnnew( 'Short Name '  , { || Client->Shrtname } )                ,;
               TBCOLUMNNEW( 'Branch '      , { || CLIENT->BRCODE   } )                ,;         && RED 070805
               tbcolumnnew( 'Code '        , { || Client->Clntcode } ) }
local mcx,cnt
ctr:=1
nval:=.t.
Client->(dbsetorder(2))

nclntno :=flook_ONLINE( .t.,'Client','space(30)','Client File',3,4,45,1,1,.f.,col_,,,,.t. )

if lastkey() <> K_ESC
   Acctmast->(dbsetorder(3))
   if Acctmast->(dbseek(nacctno))
      mclntcode:=ACCTMAST->BRCODE+Acctmast->Clntcode        && RED 070805 ADDED 'ACCTMAST->BRCODE+

      fshadow(10,09,21,69,2,'n/w')
      @ 11,10 say '  Client N§  ' + tran( mclntcode, '@R 999-99-99999')     color 'w+/w'       && RED 070805 ADDED '999-
      @ 12,10 say '  Client Name  ' + left( dispclntname( mclntcode,40 ),40 )  color 'w+/w'
      @ 13,10 say    repl( 'Ä', 59 )                                         color 'w+/w'
      @ 14,10 say '  Acct. N§     Status     Unit '                          color 'w+/w'
      @ 15,10 say    repl( 'Ä',59 )                                          color 'w+/w'
      mu:={}
      *Acctmast->( dbeval({|| aadd( mu,' '+Substr(Acctmast->Acctno,-5,5)+space(7)+substr(upper(disp_status(Acctmast->Status)),1,12)+substr(Acctmast->Unit,1,30)) },,;         && RED 072105
      Acctmast->( dbeval({|| aadd( mu,' '+ACCTMAST->BRCODE+'-'+Substr(Acctmast->Acctno,-5,5)+space(7)+substr(upper(disp_status(Acctmast->Status)),1,12)+substr(Acctmast->Unit,1,30)) },,;
                         {|| ACCTMAST->BRCODE+Acctmast->CLNTCODE==mclntcode .and. !Acctmast->(eof()) }) )
   // msel:={ .f., .f., .f., .f., .f. }
      mcx := 1
      while .t.
        mcx := achoice( 16, 10, 20, 68, mu, .t.,'myfunc',mcx,mcx)
        if lastkey() <> K_LEFT .and. lastkey() <> K_RIGHT
           do case
              case lastkey() == 32
                   if substr( mu [ mcx ],1,1) == chr(001)//'û'
                      mu[mcx] := ' '+substr( mu[ mcx ],2,len ( mu [ mcx ]  ) - 1 )
                   else
                      mu[mcx] := chr(001)+ substr( mu[ mcx ],2,len ( mu [ mcx ]  ) - 1 )
                   endif
              case lastkey() == K_ENTER
                   nval := .f.
                   cnt  := 1
                   mcx  := 1
                   Do while cnt <> len(mu)+1
                      if substr( mu [ mcx ],1,1) == chr(001)
                         *aadd(accts,substr( mu[ mcx ], 2, 5 ) )        && RED 072105
                         AADD(ACCTS,SUBSTR( MU[ MCX ], 2, 3 )+SUBSTR( MU[ MCX ], 6, 5 ) )
                      endif
                      cnt++
                      mcx++
                   enddo
                   exit
           endcase
           mcx++
        endif
      enddo

      ctr++
   else
      nval:=.f.
      error('No existing Account....')
   endif
endif

restscreen(,,,,o_scr)
dbselectarea(ndbf)
return nval
/*
***********************************************
Static function myfunc ( status, curr_elem, curr_row )
***********************************************
   local key := lastkey()
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
/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
 Function letter1()
/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    local pgn:=1,xdate := cmonth(date())+ ' '+ right(str(day(date()) + 100,3,0),2 )+', '+str(year(date()),4 )
    local a_month := { 'Jan.','Feb.','Mar.','Apr.','May','June','July','Aug.','Sept.','Oct.','Nov.','Dec.','Xxxxx' }
    local ktr, penalty:=0, pentemp:=0
    memvar nacctno, cCONTACT, position, rate, cSIGN, cPOS
    dbselectarea('Client')
    Client->(dbseek(nacctno))
    setfont ( 'NORMAL' )
    SETFONT ( 'NLQ'    )
    setfont ( 'ELITE'  )
    setprc  ( 0, 0 )
    @ prow  () + 11, 14 say xdate
    setfont ('BOLD')
    @ prow  ()+2, 14 say Client->Fullname
    SETFONT ('UNBOLD')
    @ prow  ()+1, 14 say Client->Address1
    if !empty(Client->Address2)
       @ prow()+1, 14 say Client->Address2
    endif
    if !empty(Client->Address3)
       @ prow()+1, 14 say Client->Address3
    endif

    @ prow()+2, 14 say 'Attention: '+ alltrim(cCONTACT)
    @ prow()+1, 25 say alltrim(position)
    @ prow()+2, 16 say 'LA NUMBER            AMORTIZATION            PENALTY'
    @ prow()+1, 1 say ' '

    dbselectarea('Acctmast')
    Acctmast->(dbsetorder(2))
    ktr:=1

    Do while ktr <> len(accts)+1
       penalty:=0
       pentemp:=0
       Acctmast->(dbseek(accts[ktr]))
       @ prow()+1, 16 say Acctmast->oldno
       @ prow(),   33 say Acctmast->amort  pict '9,999,999,999.99'

//aga.09.05.2006.marked for modification
       dbselectarea('Paysked')
       Paysked->(dbsetorder(2))

       Paysked->(dbseek(Acctmast->brcode+Acctmast->acctno+'D'))

       Do while Acctmast->brcode+Acctmast->acctno == Paysked->brcode+Paysked->acctno .and. Paysked->paydate <= date() .and. Paysked->status == 'D' .and. !Paysked->(eof())
          pentemp:=Paysked->amtdue*rate*((date()-Paysked->paydate)/30)
          penalty:=penalty+pentemp
          Paysked->(dbskip())
       Enddo
//...................................

       @ prow(),   56 say penalty   pict '9,999,999.99'
       ktr++
    Enddo

    @ prow()+3, 14 say 'Gentlemen,'                                                                 //
    @ prow()+2, 14 say 'This is  regarding  your  account(s)  with our  company. It  has  come to our'
    @ prow()+1, 14 say 'attention that the above mentioned amortization/rental  has not been paid on.'
    @ prow()+1, 14 say 'their due date. Consequently, you have incurred penalty charges. '
    @ prow()+2, 14 say 'We hope to receive your payment within 3 days from receipt of this letter. If'
    @ prow()+1, 14 say 'however, you have already settled this liability by the time you receive this'
    @ prow()+1, 14 say 'letter, please disregard this notice. '
    @ prow()+2, 14 say 'For your convenience and consideration.'
    @ prow()+3, 14 say 'Sincerely Yours,'
    @ prow()+3, 14 say cSIGN        && RED 070805 REPLACED 'RONNIE S. ABESAMIS'
    @ prow()+1, 14 say cPOS         && RED 070805 REPLACED 'Assistant Manager'
    __eject()
 return nil

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
 Function letter2()
/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    local pgn:=1,xdate := cmonth(date())+ ' '+ right(str(day(date()) + 100,3,0),2 )+', '+str(year(date()),4 )
    local a_month := { 'Jan.','Feb.','Mar.','Apr.','May','June','July','Aug.','Sept.','Oct.','Nov.','Dec.','Xxxxx' }
    memvar nacctno, cCONTACT, position, rate
    
    dbselectarea('Client')
    Client->(dbseek(nacctno))
    setfont ( 'NORMAL' )
    SETFONT ( 'NLQ'    )
    setfont ( 'ELITE'  )
    setprc  ( 0, 0 )
    @ prow  () + 11, 14 say xdate
    setfont ('BOLD')
    @ prow  ()+2, 14 say Client->Fullname
    SETFONT ('UNBOLD')
    @ prow  ()+1, 14 say Client->Address1
    if !empty(Client->Address2)
       @ prow()+1, 14 say Client->Address2
    endif
    if !empty(Client->Address3)
       @ prow()+1, 14 say Client->Address3
    endif

    @ prow()+2, 14 say 'Attention: '+ alltrim(cCONTACT)
    @ prow()+1, 25 say alltrim(position)

    @ prow()+2, 16 say 'LA NUMBER            AMORTIZATION            PENALTY'
    @ prow()+1, 1 say ' '
    ktr:=1
    dbselectarea('Acctmast')
    Acctmast->(dbsetorder(2))
    Do while ktr <> len(accts)+1
       penalty:=0
       pentemp:=0
       Acctmast->(dbseek(accts[ktr]))
       @ prow()+1, 16 say Acctmast->oldno
       @ prow(),   33 say Acctmast->amort  pict '9,999,999,999.99'

//aga.09.05.2006.marked for modification
       dbselectarea('Paysked')
       Paysked->(dbsetorder(2))

       Paysked->(dbseek(Acctmast->brcode+Acctmast->acctno+'D'))

       Do while Acctmast->brcode+Acctmast->acctno == Paysked->brcode+Paysked->acctno .and. Paysked->paydate <= date() .and. Paysked->status == 'D' .and. !Paysked->(eof())
          pentemp:=Paysked->amtdue*rate*((date()-Paysked->paydate)/30)
          penalty:=penalty+pentemp
          Paysked->(dbskip())
       Enddo
//...............................

       @ prow(),   56 say penalty   pict '9,999,999.99'
       ktr++
    Enddo

    @ prow()+3, 14 say 'Gentlemen,'
    @ prow()+2, 14 say 'Our records show that despite reminders your account remains unpaid to date. '
    @ prow()+2, 14 say 'In view of the length of time your account  has been past due, we must insist'
    @ prow()+1, 14 say 'that you attend to this matter of payment without further delay. '
    @ prow()+2, 14 say 'We look forward to receiving payment from you or  hearing from you within the'
    @ prow()+1, 14 say 'next five(5) days from  date of this letter. For your  reference, attached is' 
    @ prow()+1, 14 say 'our Statement of Account as of to date.'
    @ prow()+3, 14 say 'Very Truly Yours,'
    @ prow()+3, 14 say cSIGN         && RED 070805 REPLACED 'RONNIE S. ABESAMIS'
    @ prow()+1, 14 say cPOS          && RED 070805 REPLACED 'Assistant Manager'
    __eject()

 return nil

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
 Function letter3()
/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
    local pgn:=1,xdate := cmonth(date())+ ' '+ right(str(day(date()) + 100,3,0),2 )+', '+str(year(date()),4 )
    local a_month := { 'Jan.','Feb.','Mar.','Apr.','May','June','July','Aug.','Sept.','Oct.','Nov.','Dec.','Xxxxx' }
    local araw
    memvar nacctno, cCONTACT, position
    
    dbselectarea('Client')
    Client->(dbseek(nacctno))
    setfont ( 'NORMAL' )
    SETFONT ( 'NLQ'    )
    setfont ( 'ELITE'  )
    setprc  ( 0, 0 )
    @ prow  () + 11, 14 say xdate
    setfont ('BOLD')
    @ prow  ()+2, 14 say Client->Fullname
    SETFONT ('UNBOLD')
    @ prow  ()+1, 14 say Client->Address1
    if !empty(Client->Address2)
       @ prow()+1, 14 say Client->Address2
    endif
    if !empty(Client->Address3)
       @ prow()+1, 14 say Client->Address3
    endif

    @ prow()+2, 14 say 'Attention: '+ alltrim(cCONTACT)
    @ prow()+1, 25 say alltrim(position)
    @ prow()+2, 16 say 'LA NUMBER            AMORTIZATION            PENALTY'
    @ prow()+1, 1 say ' '
    ktr:=1
    dbselectarea('Acctmast')
    Acctmast->(dbsetorder(2))
    Do while ktr <> len(accts)+1
       penalty:=0
       pentemp:=0
       Acctmast->(dbseek(accts[ktr]))
       @ prow()+1, 16 say Acctmast->oldno
       @ prow(),   33 say Acctmast->amort  pict '9,999,999,999.99'

//aga.09.05.2006.marked for modification
       dbselectarea('Paysked')
       Paysked->(dbsetorder(2))

       Paysked->(dbseek(Acctmast->brcode+Acctmast->acctno+'D'))

       Do while Acctmast->brcode+Acctmast->acctno == Paysked->brcode+Paysked->acctno .and. Paysked->paydate <= date() .and. Paysked->status == 'D' .and. !Paysked->(eof())
          pentemp:=Paysked->amtdue*rate*((date()-Paysked->paydate)/30)
          penalty:=penalty+pentemp
          Paysked->(dbskip())
       Enddo
//............................

       @ prow(),   56 say penalty   pict '9,999,999.99'
       ktr++
    Enddo

    @ prow()+3, 14 say 'Gentlemen,'
    @ prow()+2, 14 say 'We call your attention to the fact that no payment has been received from you'
    @ prow()+1, 14 say 'for the past two(2) months, despite all our efforts and reminders. '
    @ prow()+2, 14 say 'You have already enjoyed an extension of time in excess of that expected from'
    @ prow()+1, 14 say 'those of good credit standing. We are  constrained, therefore, from  allowing'
    @ prow()+1, 14 say 'further delays with respect to payment of your account.'
    @ prow()+2, 14 say 'We must inform you that  unless a full  updating of  your account is arranged'
    @ prow()+1, 14 say 'five (5) days  from  date of  this letter, we  shall  be  forced to  consider'
    @ prow()+1, 14 say 'referring your account to legal counsel for appropiate action.'
    @ prow()+2, 14 say 'We urge you again to either remit payment or call on  the undersigned so that' 
    @ prow()+1, 14 say 'we will not find it necessary to take steps to protect our interest. For your'
    @ prow()+1, 14 say 'convenience attached is our Statement of Account.'
    @ prow()+3, 14 say 'Very Truly Yours,'
    @ prow()+3, 14 say cSIGN           && RED 070805 REPLACED 'RONNIE S. ABESAMIS'
    @ prow()+1, 14 say cPOS            && RED 070805 REPLACED 'Assistant Manager'
    __eject()

return nil

static function letter_option()
local mu:=SAVEDBF(),menulist,pchoice,st:=savescreen(,,,)
private amount:={}, cCONTACT:=space(28), position:=space(28), rate:=0.05
Private cSIGN := SPACE(40), cPOS := SPACE(40)

fshadow(13,46,21,65,2,'w+/bg')
setcolor('n/gr,w+/gr','w+/gr,n/gr')
@ 13,49 say 'Letter Option' color 'n/bg'
@ 15,61 say 'Ü'  color 'n/bg'
@ 16,50 say repl('ß',12) color 'n/bg'
@ 17,61 say 'Ü'  color 'n/bg'
@ 18,50 say repl('ß',12) color 'n/bg'
@ 19,61 say 'Ü'  color 'n/bg'
@ 20,50 say repl('ß',12) color 'n/bg'

while .t.
      @ 15,49 prompt ' ~Letter I   ' triggercolor 'w+/gr'
      @ 17,49 prompt ' ~Letter II  ' triggercolor 'w+/gr'
      @ 19,49 prompt ' ~Letter III ' triggercolor 'w+/gr'
      menu to pchoice
      if lastkey() <> K_ESC .and. !empty(pchoice)
          exit
      elseif Lastkey() == K_ESC
          exit
      endif
Enddo
    dbselectarea('Signers')
    Signers->(dbseek(nacctno))
    fshadow(09,7,11,47,2, 'n/w')
    setcursor(1)
    cCONTACT:=Signers->signer
    @ 10,8  say 'Name  ' get cCONTACT picture '@!' VALID !EMPTY(cCONTACT)
    read

    fshadow(09,7,11,51,2, 'n/w')
    setcursor(1)
    position:=Signers->title
    @ 10,8  say 'Position  ' get position picture '@!' VALID !EMPTY(POSITION)
    read

    fshadow(09,7,11,51,2, 'n/w')
    @ 10,8  say 'Rate  ' get rate  picture '9.99'
    read

    fshadow(09,07,11,60,02, 'n/w')
    @ 10,8  say 'Signatory ' get cSIGN  picture '@!' WHEN EVAL({ || GETSIGN(@cSIGN),.F. }) VALID !EMPTY(cSIGN)
    read

    fshadow(09,07,11,60,02, 'n/w')
    @ 10,8  say 'Position ' get cPOS picture '@' VALID !EMPTY(cPOS)
    read

    setcursor(0)
      Do case
         case pchoice == 1
            xxx := savescreen( ,,, )
            @ 15,49 say repl(' ',12) color 'n/bg'
            @ 16,49 say repl(' ',12) color 'n/bg'
            @ 15,50 say ' Letter I   ' color 'w+/gr'
            inkey(.5)
            restscreen( ,,,,xxx )
            @ 15,61 say 'û'  color 'w/gr'
            reportprint('letter1()')
            *repcon_ol('letter1()',,,,,,,.F.)
            pval := 1
         case pchoice == 2
            xxx := savescreen( ,,, )
            @ 17,49 say repl(' ',12) color 'n/bg'
            @ 18,49 say repl(' ',12) color 'n/bg'
            @ 17,50 say ' Letter II  ' color 'w+/gr'
            inkey(.5)
            restscreen( ,,,,xxx )
            @ 17,61 say 'û'  color 'w/gr'   
            *repcontrol('letter2()')
            repcon_ol('letter2()',,,,,,,.F.)
            pval := 2
         case pchoice == 3
            xxx := savescreen( ,,, )
            @ 19,49 say repl(' ',12) color 'n/bg'
            @ 20,49 say repl(' ',12) color 'n/bg'
            @ 19,50 say ' Letter III ' color 'w+/gr'
            inkey(.5)
            restscreen( ,,,,xxx )
            @ 19,61 say 'û'  color 'w/gr'
            *repcontrol('letter3()')
            repcon_ol('letter3()',,,,,,,.F.)
            pval := 3
         case pchoice == 0
            pval := 0
      endcase
 RESTDBF(mu)
 restscreen(,,,,st)
return
                 
/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
 static function aOpen0900()
/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
memvar gSYS_NAME, gUSER_ID, gTRANDATE, mFMS0700

// EVR if !netuse( 'Parametr',.f.,10 )
// EVR    break
// EVR endif

if !netuse( '&g_AMS_PATH\Acctmast', .f., 10 )              && Account master file
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_AMS_PATH\Acctmast' )                     && set index on acctno
   ordlistadd( '&g_AMS_PATH\Acctsub2')                      && set index on substr(acctno,-5,5)
   ordlistadd( '&g_AMS_PATH\Acctclnt')
endif

if !netuse( '&g_AMS_PATH\Paysked',.f.,5)
    break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_AMS_PATH\Paysked' )                     && set index on acctno
endif

if !NETUSE('&g_CIS_PATH'+'\SIGNERS',.f.,5)
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_CIS_PATH\SIGNERS' )                  && set index on singers
endif

if !NETUSE('&g_CIS_PATH'+'\CLIENT',.f.,5)   && CLIENT MASTER file
   break
else
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_CIS_PATH\CLIECD' )                     && set index on clntcode
   ordlistadd( '&g_CIS_PATH\CLIENM' )                     && set index on Fullname
endif
*---> RED 070805 ADDED
IF !NETUSE('&g_GRF_PATH'+'\PERSONEL',.F.,5)
   BREAK
ELSE
   ORDLISTADD( '&g_GRF_PATH\PERSONEL' )
ENDIF

RETURN
*------------------------------------------------------------------------------>
STATIC FUNCTION GETSIGN(cSIGN)
   LOCAL COL_ := { ;
      TBCOLUMNNEW( 'Initials ' , { || PERSONEL->INITIALS } ),;
      TBCOLUMNNEW( 'Name '     , { || PERSONEL->FULLNAME } ),;
      TBCOLUMNNEW( 'Branch '   , { || PERSONEL->BRCODE   } ) }

   cSIGN :=flook_ONLINE( .t.,'PERSONEL',,'Personnel File',3,4,,1,2,.F.,COL_ )
RETURN .T.
