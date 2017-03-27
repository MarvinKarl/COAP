/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   PROGRAM ID.........:  amsm107b.prg                                         ³
³   Description........:  availment sheet maintenance printing routine         ³
³   Author.............:  Ariel B. Bulan                                       ³
³   Date...............:  08:35am 13-Jan-1995                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                         U P D A T E S                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        Who        ³     When      ³               Why                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Janet L. Bautista ³  23-Apr-1996  ³ printing of o/b must include             ³
³                   ³               ³ only lower acctno pending                ³
³                   ³               ³ availments                               ³
³ Janet L. Bautista ³  10-Sep-1997  ³ gd, rv to 5 decimal places               ³
³ Janet L. Bautista ³  18-Aug-1998  ³ tot. rec'bls must include rv             ³
³ abb               ³  09-Aug-2000  ³ credit committee selection               ³
³ Janet B. Salvador ³  25-Jan-2001  ³ get crecom code from parametr.dbf        ³
³ ABB               ³  10.14.2004   ³ ONLINE                                   ³
³ MTS               ³  09/30/2013   ³ When PAYMENT TYPE is changed from        ³
³                   ³               ³ IN ARREARS to IN ADVANCE it will display ³
³ 					³        		³ "REMARKS" instead of "DEVIATION"         ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#define MAXROW 49

#xtran f_dsm_ref ( <refn> , < dref> ) =>  { | x, y | <refn> != x .and. <dref> != y }

#xtran gettermunit   ( <cnum> ) => if( <cnum> == '1'  , 'Day(s)', 'Month(s)' )
#xtran getratetype   ( <cnum> ) => if( <cnum> == '1'  , 'Fixed', 'Floating' )
#xtran getpaymode    ( <cnum> ) => if( <cnum> == '1'  , 'PDC',;
                                   if( <cnum> == '2'  , 'CASH','AUTOMATIC DEBIT') )
#xtran getdocref     ( <cnum> ) => if( <cnum> == '1'  , 'CA','OT')
#include "COLF.CH"
#include "INKEY.CH"


*****************************
*
function AMS1007PRINT()
*****************************
local mu:=SAVEDBF(),menulist,pchoice,st:=savescreen(,,,)
private _ar_term := {}    , _ar_rv       := {},_ar_gd := {}
private _ar_truerate := {}, _ar_ratetype := {}, _ar_paytype := {}
private _ar_fcltycode := {},_ar_termunit := {}
private _ar_sublimit := {}

   /// select which report to print
   if eval( {|| Facility->(Dbseek(Acctwait->Fcltycode)),Facility->Setcode } ) == '1'

      fshadow(13,56,21,78,2,'w+/bg')
      setcolor('n/gr,w+/gr','w+/gr,n/gr')
      @ 13,58 say 'Report Option' color 'n/bg'
      @ 15,77 say 'Ü'  color 'n/bg'
      @ 16,58 say repl('ß',20) color 'n/bg'
      @ 17,77 say 'Ü'  color 'n/bg'
      @ 18,58 say repl('ß',20) color 'n/bg'
      @ 19,77 say 'Ü'  color 'n/bg'
      @ 20,58 say repl('ß',20) color 'n/bg'

      while .t.
         @ 15,57 prompt ' ~Availment Sheet    '  triggercolor 'w+/gr'
         @ 17,57 prompt ' ~Check List         '  triggercolor 'w+/gr'
         @ 19,57 prompt ' ~Payment Schedule   '  triggercolor 'w+/gr'
         menu to pchoice

         if lastkey() <> K_ESC .and. !empty(pchoice)
            exit
         elseif Lastkey() == K_ESC
            exit
         endif
      enddo

      do case
         case pchoice == 1
            xxx := savescreen( ,,, )
            @ 15,57 say repl(' ',21) color 'n/bg'
            @ 16,57 say repl(' ',21) color 'n/bg'
            @ 15,58 say ' Availment Sheet    ' color 'w+/gr'
            inkey(.5)
            restscreen( ,,,,xxx )
            @ 15,76 say 'û'  color 'w/gr'
            pval := 1
            PRINT_AVAILMENT()
         case pchoice == 2
            xxx := savescreen( ,,, )
            @ 17,57 say repl(' ',21) color 'n/bg'
            @ 18,57 say repl(' ',21) color 'n/bg'
            @ 17,58 say ' Check List         ' color 'w+/gr'
            inkey(.5)
            restscreen( ,,,,xxx )
            @ 17,76 say 'û'  color 'w/gr'
            pval := 2
            *REPCONTROL( 'print_Chklst()' )
            REPCON_OL( 'print_Chklst()',,,,,,,.F. )
			*reportprint( 'print_Chklst()' )
         case pchoice == 3
            xxx := savescreen( ,,, )
            @ 19,57 say repl(' ',21) color 'n/bg'
            @ 20,57 say repl(' ',21) color 'n/bg'
            @ 19,58 say ' Payment Schedule   ' color 'w+/gr'
            inkey(.5)
            restscreen( ,,,,xxx )
            @ 19,76 say 'û'  color 'w/gr'
            pval := 3
            *Repcontrol( 'print_Payschd()')
            Repcon_ol( 'print_Payschd()',,,,,,,.F.)
         case pchoice == 0
            pval := 0
      endcase
   else
      PRINT_AVAILMENT()
   endif
   RESTDBF(mu)
   restscreen(,,,,st)
   return (nil)
/*---------------------------*/
 Static Function headchklst(mtitle)
/*---------------------------*/
 local pt_:=Client->(Indexord())
 setfont('DRAFT')
 SETFONT('ELITE')
 @ prow()+1,03  say 'ORIX METRO LEASING AND FINANCE CORPORATION'
 @ PROW(),COL() SAY PADL( ('AMS '+DTOC(DATE())+' '+TIME()), 97-COL() )
 @ PROW()+1,03  SAY CHR(14)+mtitle+CHR(14)
 Client->(Dbsetorder(1))
 Client->(dbseek(ACCTWAIT->BRCODE+Acctwait->Clntcode))      && RED 112504 ADDED 'ACCTWAIT->BRCODE+
 Client->(Dbsetorder(pt_))
 RETURN NIL
/*------------------------*/
 Function print_Payschd()
/*------------------------*/
 local mu:=savedbf(),st:=savescreen(,,,)
 local nPURC_USD, nGD_USD, nRV_USD,nRENT_USD
 
 nPURC_USD := round(Acctwait->principal / Acctwait->USDRATE,2)
 nGD_USD   := round(round(Acctwait->PRINCIPAL*(Acctwait->GD/100),2) / Acctwait->USDRATE,2)
 nRV_USD   := round(round(Acctwait->PRINCIPAL*(Acctwait->RV/100),2) / Acctwait->USDRATE,2)
 nRENT_USD := round(Acctwait->Amort / Acctwait->USDRATE,2)
 
 headchklst('PAYMENT SCHEDULE')
 @ prow()+1,03 say repl('Ä',94)
 @ prow()+1,03 say 'Account Number  : '+tran(ACCTWAIT->BRCODE+Acctwait->Acctno,'@R 999-9999-99999-99999')  && RED 112504 ADDED '999- 'ACCTWAIT->BRCODE+
 @ prow()  ,col() say  padl( ('Date : '+dtoc(Acctwait->Valdate)), 93-col() )  && RED 112604 REPLACED '97 WITH 93
 @ prow()+1,03 say 'Client          : '+alltrim(Acctwait->Acctname)
 @ prow()  ,71 say 'Doc. Ref. : '+ getdocref(Acctwait->Docref)+ ' #'+TRAN(ACCTWAIT->BRCODE+Acctwait->Refno,'@R 999-99999')    && RED 112504 CHANGED 75 TO 71 ADDED 'ACCTWAIT->BRCODE+ '999-
 @ prow()+1,03 say 'Address         : ' + Client->Address1

 if !empty(Acctwait->Docref2)
    @ prow(), 71 say '            '+ getdocref(Acctwait->Docref2)+ ' #'+TRAN(ACCTWAIT->BRCODE+Acctwait->Refno2,'@R 999-99999')     && RED 112504 CHANGED 75 TO 71 ADDED 'ACCTWAIT->BRCODE+ '999-
 endif
 @ prow()+1,03 say '                  ' +Client->Address2
 if !empty(Client->Address3)
    @ prow()+1,03 say '                  '+Client->Address3
 endif

 @ prow()+1,03 say 'Industry        : '+Client->INDCODE+" "+dispindustry (Client->INDCODE)
 @ prow()+1,03 say 'Signer/Title    : '
 dispsigner( ACCTWAIT->BRCODE+Acctwait->CLNTCODE,prow() )
 @ prow()+1,03 say 'Account Officer : '+dispAONAME( Acctwait->AOCODE )
 @ prow()+1,03 say repl('Ä',94)
 @ prow()+1,15 say '      Lease Item : ' + Acctwait->Unit
 if !empty(Acctwait->Unit2)
    @ prow()+1,15 say '                   ' +Acctwait->Unit2
 endif
 @ prow()+1,15 say ' Purchase Amount : ' + Tran(Acctwait->principal,'999,999,999.99') + if(round(Acctwait->usdrate,2) > 0,(' = US$ '+ Tran(nPURC_USD,'999,999.99') +'  @ US$ 1 = Php '+Tran(Acctwait->usdrate,'99.99')),space(1))
 @ prow()+1,15 say '            Term : ' + tran(Acctwait->Term,'999') + ' '+Gettermunit(Acctwait->TErmunit)
 @ prow()+1,15 say '       True Rate : ' + tran(Acctwait->Truerate,'99.9999') +'%'+ ' '+getratetype(Acctwait->Ratetype)
 @ prow()+1,15 say '    Lease Factor : ' + tran(Acctwait->Factor,'99.9999') +'%'
 @ prow()+1,15 say 'Guaranty Deposit : ' + tran(Acctwait->Gd,'99.999999' ) +'%'  +' '+ '[' + ( trans( round(Acctwait->PRINCIPAL*(Acctwait->GD/100),2),'999,999,999.99'))+']'+ if(round(Acctwait->usdrate,2) > 0,(' = US$ '+ Tran(nGD_USD,'999,999.99')),space(1))
 @ prow()+1,15 say '  Residual Value : ' + tran(Acctwait->Rv,'99.999999') +'%'   +' '+ '[' + ( trans( round(Acctwait->PRINCIPAL*(Acctwait->RV/100),2),'999,999,999.99'))+']'+ if(round(Acctwait->usdrate,2) > 0,(' = US$ '+ Tran(nRV_USD,'999,999.99')),space(1))
 @ prow()+1,15 say '          Rental : ' + Tran(Acctwait->Amort,'999,999,999.99')+ if(round(Acctwait->usdrate,2) > 0,(' = US$ '+ Tran(nRENT_USD,'999,999.99')),space(1))
 @ prow()+1,15 say 'Total Receivable : ' + Tran(Acctwait->Credamt+(Acctwait->RV/100*Acctwait->Principal),'999,999,999.99')
 @ prow()+1,15 say ' Mode of Payment : ' + getpaymode(Acctwait->Paymode)
 @ prow()+1,15 say '   Contract Date : '  // + Dtoc(Acctwait->Condate)
 @ prow()+1,15 say '  Execution Date : '  // + Dtoc(Acctwait->Valdate)
 @ prow()+1,15 say '  First Due Date : '  // + Dtoc(Acctwait->Firstdue)
 @ prow()+1,15 say '          Surety : ' + Acctwait->surety1
 If !empty(Acctwait->Surety2)
    @ prow()+1,15 say '                   ' + Acctwait->Surety2
 endif
 @ prow()+1,03 say repl('Ä',94)
 @ prow()+1,03 say ' 1 ___________________ ___________ ___________  31 ___________________ ___________ ___________'
 @ prow()+1,03 say ' 2 ___________________ ___________ ___________  32 ___________________ ___________ ___________'
 @ prow()+1,03 say ' 3 ___________________ ___________ ___________  33 ___________________ ___________ ___________'
 @ prow()+1,03 say ' 4 ___________________ ___________ ___________  34 ___________________ ___________ ___________'
 @ prow()+1,03 say ' 5 ___________________ ___________ ___________  35 ___________________ ___________ ___________'
 @ prow()+1,03 say ' 6 ___________________ ___________ ___________  36 ___________________ ___________ ___________'
 @ prow()+1,03 say ' 7 ___________________ ___________ ___________  37 ___________________ ___________ ___________'                                                                        
 @ prow()+1,03 say ' 8 ___________________ ___________ ___________  38 ___________________ ___________ ___________'
 @ prow()+1,03 say ' 9 ___________________ ___________ ___________  39 ___________________ ___________ ___________'
 @ prow()+1,03 say '10 ___________________ ___________ ___________  40 ___________________ ___________ ___________'
 @ prow()+1,03 say '11 ___________________ ___________ ___________  41 ___________________ ___________ ___________'
 @ prow()+1,03 say '12 ___________________ ___________ ___________  42 ___________________ ___________ ___________'
 @ prow()+1,03 say '13 ___________________ ___________ ___________  43 ___________________ ___________ ___________'
 @ prow()+1,03 say '14 ___________________ ___________ ___________  44 ___________________ ___________ ___________'
 @ prow()+1,03 say '15 ___________________ ___________ ___________  45 ___________________ ___________ ___________'
 @ prow()+1,03 say '16 ___________________ ___________ ___________  46 ___________________ ___________ ___________'
 @ prow()+1,03 say '17 ___________________ ___________ ___________  47 ___________________ ___________ ___________'
 @ prow()+1,03 say '18 ___________________ ___________ ___________  48 ___________________ ___________ ___________'
 @ prow()+1,03 say '19 ___________________ ___________ ___________  49 ___________________ ___________ ___________'
 @ prow()+1,03 say '20 ___________________ ___________ ___________  50 ___________________ ___________ ___________'
 @ prow()+1,03 say '21 ___________________ ___________ ___________  51 ___________________ ___________ ___________'
 @ prow()+1,03 say '22 ___________________ ___________ ___________  52 ___________________ ___________ ___________'
 @ prow()+1,03 say '23 ___________________ ___________ ___________  53 ___________________ ___________ ___________'
 @ prow()+1,03 say '24 ___________________ ___________ ___________  54 ___________________ ___________ ___________'
 @ prow()+1,03 say '25 ___________________ ___________ ___________  55 ___________________ ___________ ___________'
 @ prow()+1,03 say '26 ___________________ ___________ ___________  56 ___________________ ___________ ___________'
 @ prow()+1,03 say '27 ___________________ ___________ ___________  57 ___________________ ___________ ___________'
 @ prow()+1,03 say '28 ___________________ ___________ ___________  58 ___________________ ___________ ___________'
 @ prow()+1,03 say '29 ___________________ ___________ ___________  59 ___________________ ___________ ___________'
 @ prow()+1,03 say '30 ___________________ ___________ ___________  60 ___________________ ___________ ___________'
 __eject()
 return nil

/*-----------------------------*/
 Function print_Chklst()
/*-----------------------------*/
 local mu:=savedbf(),st:=savescreen(,,,)
 local nPURC_USD, nGD_USD, nRV_USD, nRENT_USD
 
 nPURC_USD := round(Acctwait->principal / Acctwait->USDRATE,2)
 nGD_USD   := round(round(Acctwait->PRINCIPAL*(Acctwait->GD/100),2) / Acctwait->USDRATE,2)
 nRV_USD   := round(round(Acctwait->PRINCIPAL*(Acctwait->RV/100),2) / Acctwait->USDRATE,2)
 nRENT_USD := round(Acctwait->Amort / Acctwait->USDRATE,2)
  
 headchklst('CHECK LIST')
 @ prow()+1,03 say repl('Ä',94)
 @ prow()+1,03 say 'Account Number  : '+tran(ACCTWAIT->BRCODE+Acctwait->Acctno,'@R 999-9999-99999-99999')   && RED 112504 ADDED 'ACCTWAIT->BRCODE '999-
 @ prow()  ,col() say  padl( ('Date : '+dtoc(Acctwait->Valdate)), 93-col() )     && RED 112604 REPLACED 97 WITH 93
 @ prow()+1,03 say 'Client          : '+alltrim(Acctwait->Acctname)
 @ prow()  ,71 say 'Doc. Ref. : '+ getdocref(Acctwait->Docref)+ ' #'+TRAN(ACCTWAIT->BRCODE+Acctwait->Refno,'@R 999-99999') && RED 112504 CHANGED 75 TO 71 ADDED 'ACCTWAIT->BRCODE '999-
 @ prow()+1,03 say 'Address         : ' + Client->Address1
 if !empty(Acctwait->Docref2)
   @ prow(),71 say '            '+ getdocref(Acctwait->Docref2)+ ' #'+TRAN(ACCTWAIT->BRCODE+Acctwait->Refno2,'@R 999-99999') && RED 112504 CHANGED 75 TO 71 ADDED 'ACCTWAIT->BRCODE '999-
 endif
 @ prow()+1,03 say '                  ' +Client->Address2
 if !empty(Client->Address3)
    @ prow()+1,03 say '                  '+Client->Address3
 endif
 @ prow()+1,03 say 'Industry        : '+Client->INDCODE+" "+dispindustry (Client->INDCODE)
 @ prow()+1,03 say 'Signer/Title    : '
 dispsigner( ACCTWAIT->BRCODE+Acctwait->CLNTCODE,prow() )
 @ prow()+1,03 say 'Account Officer : '+dispAONAME( Acctwait->AOCODE )
 @ prow()+1,03 say repl('Ä',94)
 @ prow()+1,15 say '      Lease Item : ' + Acctwait->Unit
 if !empty(Acctwait->Unit2)
    @ prow()+1,15 say '                   ' +Acctwait->Unit2
 endif
 @ prow()+1,15 say ' Purchase Amount : ' + Tran(Acctwait->principal,'999,999,999.99')+ if(round(Acctwait->usdrate,2) > 0,(' = US$ '+ Tran(nPURC_USD,'999,999.99') +'  @ US$ 1 = Php '+Tran(Acctwait->usdrate,'99.99')),space(1))
 @ prow()+1,15 say '            Term : ' + tran(Acctwait->Term,'999') + ' '+Gettermunit(Acctwait->TErmunit)
 @ prow()+1,15 say '       True Rate : ' + tran(Acctwait->Truerate,'99.9999') +'%'+ ' '+getratetype(Acctwait->Ratetype)
 @ prow()+1,15 say '    Lease Factor : ' + tran(Acctwait->Factor,'99.9999') +'%' 
 @ prow()+1,15 say 'Guaranty Deposit : ' + tran(Acctwait->Gd,'99.9999' ) +'%'  +' '+ '[' + ( trans( round(Acctwait->PRINCIPAL*(Acctwait->GD/100),2),'999,999,999.99'))+']'+ if(round(Acctwait->usdrate,2) > 0,(' = US$ '+ Tran(nGD_USD,'999,999.99')),space(1))
 @ prow()+1,15 say '  Residual Value : ' + tran(Acctwait->Rv,'99.999999') +'%' +' '+ '[' + ( trans( round(Acctwait->PRINCIPAL*(Acctwait->RV/100),2),'999,999,999.99'))+']'+ if(round(Acctwait->usdrate,2) > 0,(' = US$ '+ Tran(nRV_USD,'999,999.99')),space(1))
 @ prow()+1,15 say '          Rental : ' + Tran(Acctwait->Amort,'999,999,999.99')+ if(round(Acctwait->usdrate,2) > 0,(' = US$ '+ Tran(nRENT_USD,'999,999.99')),space(1))
 @ prow()+1,15 say 'Total Receivable : ' + Tran(Acctwait->Credamt+(Acctwait->RV/100*Acctwait->Principal),'999,999,999.99')
 @ prow()+1,15 say ' Mode of Payment : ' + getpaymode(Acctwait->Paymode)
 @ prow()+1,15 say '   Contract Date : '  // + Dtoc(Acctwait->Condate)
 @ prow()+1,15 say '  Execution Date : '  // + Dtoc(Acctwait->Valdate)
 @ prow()+1,15 say '  First Due Date : '  // + Dtoc(Acctwait->Firstdue)
 @ prow()+1,15 say '          Surety : ' + Acctwait->surety1
 If !empty(Acctwait->Surety2)
    @ prow()+1,15 say '                   ' + Acctwait->Surety2
 endif
 @ prow()+1,03 say repl('Ä',94)
 @ prow()+1,03 say 'ITEM                   CHECKED BY     KEPT BY     ITEM                 CHECKED BY      KEPT BY'
 @ prow()+1,03 say repl('Ä',94)
 @ prow()+1,03 say ''
 @ PROW()+1,03 say 'LEASE AGREEMENT        ______________________     INSURANCE POLICY     _______________________';@ prow()+1,03 say ''
 @ prow()+1,03 say 'LEASE SCHEDULE         ______________________     3RD PARTY INSURANCE  _______________________';@ prow()+1,03 say ''
 @ PROW()+1,03 SAY 'AGREE TO SELL (XXIII)  ______________________     DEPOSIT              _______________________';@ prow()+1,03 say ''
 @ PROW()+1,03 SAY 'DISCLOSURE STATEMENT   ______________________     FIRST RENTAL         _______________________';@ prow()+1,03 say ''
 @ PROW()+1,03 SAY 'PURCHASE ORDER         ______________________     POST DATED CHECKS    _______________________';@ prow()+1,03 say ''
 @ PROW()+1,03 SAY 'CONTINUING GUARANTY    ______________________     OWNERSHIP CERT.      _______________________';@ prow()+1,03 say ''
 @ PROW()+1,03 SAY 'MORTGAGE               ______________________     SALES INVOICE        _______________________';@ prow()+1,03 say ''
 @ PROW()+1,03 SAY 'MORTGAGE CERT. & OR    ______________________     DEED OF SALE         _______________________';@ prow()+1,03 say ''
 @ PROW()+1,03 SAY 'BOARD RESOLUTION       ______________________     EXECUTON SLIP        _______________________';@ prow()+1,03 say ''
 @ PROW()+1,03 SAY "SECRETARY'S CERT.      ______________________     REQUEST FOR PAYMENT  _______________________";@ prow()+1,03 say ''
 @ PROW()+1,03 SAY '_____________________  ______________________     ___________________  _______________________';@ prow()+1,03 say ''
 @ PROW()+1,03 SAY '_____________________  ______________________     ___________________  _______________________';@ prow()+1,03 say ''
 @ PROW()+1,03 SAY '_____________________  ______________________     ___________________  _______________________';@ prow()+1,03 say ''
 @ PROW()+1,03 SAY '_____________________  ______________________     ___________________  _______________________'
 __EJECT()
return nil

***************************************
*
static function print_availment( )
***************************************
local   mSCR := savescreen (,,,), mcolor := setcolor()
private mpreparedby, mcheckedby, mnotedby1, mnotedby2
private mpcode,      mccode,     mncode,    mscreen

   mpreparedby := mcheckedby := mnotedby1:= mnotedby2 := space(40)
   mpcode      := mccode     := mncode   := space(05)
   mscreen     := savescreen( ,,, )

   *if( g_names2(), repcontrol('strtprinting()',,,12,33),nil )
   if( g_names2(), repcon_ol('strtprinting()',,,12,33,,,.F.),nil )
   inkey( .5 )
   setcolor(mcolor) ; restscreen ( ,,,, mSCR)
   return (nil)


//aga.06.05.2005.new and improved g_names2()...yay!
*******************************
static function g_names2()
*******************************
memvar mPREPAREDBY , mCHECKEDBY, mNOTEDBY1, mNOTEDBY2
local  getlist := {}, ax := setcolor()
private entryname [4]
entryname [1] := entryname [2] := entryname [3] := entryname [4] := space(40)

fshadow ( 08, 29, 13, 69, 2, 'n/w')
setcolor( 'bg+/w, w+/n,,, gr+/w' ) 

@ 9, 30 say 'Prepared by ' gget entryname[1] picture '@xs25'            ;
         when lastkey() != K_ESC valid !empty( mPREPAREDBY := get_initial(entryname[1], 1, 8, 44, 25 ) )
@ 10, 30 say ' Checked by ' gget entryname[2] picture '@xS25'            ;
         when lastkey() != K_ESC valid !empty( mCHECKEDBY  := get_initial(entryname[2], 2, 8, 44, 25 ) )
@ 11, 30 say 'Approved by ' gget entryname[3] picture '@xS25'            ;
         when lastkey() != K_ESC valid !empty( mNOTEDBY1   := get_initial(entryname[3], 3, 8, 44, 25 ) )
@ 12, 30 say '             ' gget entryname[4] picture '@xS25'            ;
         when lastkey() != K_ESC valid !empty( mNOTEDBY2   := get_initial(entryname[4], 4, 8, 44, 25 ) )

setcursor ( 3 )
read   
setcursor ( 0 )
setcolor  ( ax )

return( lastkey()!=K_ESC )
//.........................................


//**************************
//static function g_names2()
//**************************
//    memvar mPREPAREDBY , mCHECKEDBY, mNOTEDBY1, mNOTEDBY2
//    memvar mpcode      , mccode    , mncode
//    local getlist := {}
//
//    fshadow   ( 08, 29, 13, 69, 2, 'n/w')
//    setcolor  ( 'bg+/w, w+/n,,, gr+/w')
//    @ 09, 30 say 'Prepared by ' get mPREPAREDBY pict '@XS25' when luk_at_them( @mpcode, @mPREPAREDBY, '® Prepared by ¯' )
//    @ 10, 30 say ' Checked by ' get mCHECKEDBY  pict '@XS25' when luk_at_them( @mccode, @mCHECKEDBY , '® Checked by ¯'  )
//    @ 11, 30 say 'Approved by ' get mNOTEDBY1   pict '@XS25' when luk_at_them( @mncode, @mNOTEDBY1  , '® Approved by ¯' )
//    @ 12, 30 say '            ' get mNOTEDBY2   pict '@XS25' when luk_at_them( @mncode, @mNOTEDBY2  , '® Approved by ¯' )
//    setcursor( 3 )
//    read
//    setcursor( 0 )
//return ( lastkey()!=K_ESC )
//**************************************************
//static function luk_at_them( mcode,mname,mmess )
//**************************************************
//    if lastkey() != K_ESC
//       @ 24, 00 say repl(' ',78) color ( NRM )
//       center  ( 24, 'w+/n', mmess )
//       lb_lkup ( 'Personel' ,1,1, @mcode, 1 , 2, 13, 1, 21, 63, 'w/gr+,w/n,,,w/gr+' )
//       mname := Personel->FULLNAME
//       @ 24, 00 say repl (' ',78) color 'w+/n'
//    endif
//return .t.


***********************
*
function strtprinting()
***********************
    memvar  mSCREEN
    memvar mPREPAREDBY , mCHECKEDBY, mNOTEDBY1, mNOTEDBY2
    local i,mprinted := .f.
    local nsetcode:= eval( { || Facility->(dbseek(Acctwait->Fcltycode,.f.)),Facility->Setcode  } )
    local xx:= if (Acctwait->Docref == '1',Caheader->(indexord()),Oticket->(indexord()))
	local cDTLCODE := ACCTWAIT->DTLCODE
    private mpage     := 1
    private mtotal, mBALANCE, mguarantees, mthistransaction

	   if Acctwait->Docref == '1'
	       Caheader->(dbsetorder(1))
	       Caheader->(dbseek(Acctwait->brcode+Acctwait->Refno,.f.))
       else
	       Oticket->(dbsetorder(1))
	       Oticket->(dbseek(Acctwait->brcode+Acctwait->Refno,.f.))
       endif

	    compute_first    ( @mtotal, @mBALANCE, @mguarantees, @mthistransaction )

	    print_head       ()
	    print_subhead    (nil,nsetcode)
	    print_facility   ()

	    dispcomputations ( mtotal,  mBALANCE ,  mguarantees , mthistransaction, ACCTWAIT->usdrate )

	    _get_comm(cDTLCODE)         // 08/09/2000

	    //if !empty( Acctwait->REMARKS )

	       if prow()>=MAXROW
	          fejectpause   ()
	          print_subhead ( .f., nsetcode )
	          mdispcomm := .t.
	          print_remarks ()
	       else
	          print_remarks ()       
	          //print_names   ()
	       endif

	    //endif
	    __eject          ()
		
		if Acctwait->(netlock('R',0))
		   Acctwait->status := 'P'
		   Acctwait->(dbunlock())
		   Acctwait->(dbcommit())
		endif
return nil
 
****************************
*
static function _get_comm(cDTLCODE)
****************************
   local  mSCR        := savescreen ( ,,, )    ,;
          mCOLOR      := setcolor ()           ,;
          mdbf        := savedbf ( mdbf )      ,;
          mMERON      := .f.                   ,;
          mCOMCODE , i      , getlist := {}    ,;
          mSELECTED, mSIGNEE, mREQB,mreqa      ,;
          mOK_TO_SELECT                        , ncolor,;
          mGCTR := 0 , mCTR  := 0, mcomrec := Comcodes->(recno())
   local credcom:=.f.,aSlct:=0,bSlct:=0,members:={},member2:={},mCOMNAME
   local mcomcode2,mmeron2,mreqa2,mreqb2,mrecno2,msignees2,mtotal := 1
   private groups    := {}

   set device to screen

   if _change_from_proposal(cDTLCODE)


   mSCR := savescreen ( ,,, )
   mcolor:='w/n'

   if mtotal <= 0
      mu:=savescreen( ,,, )
      fshadow ( 4, 5, 6, 34, 2, 'n/w')
      mtotal := 0
      ncolor := setcolor()   
      setcolor( 'bg+/w, w+/n,,, gr+/w' )
      @ 5,  6 say 'Line Amount ' get mtotal pict '999,999,999.99'
      setcursor ( 3 )
      read
      setcursor ( 0 )
      setcolor( mcolor )
      restscreen(,,,,mu)
   endif

   center ( 24, 'w+/n', '® Select Signees ¯' )

**************    dbselectarea ( "Comcodes" )

   Comcodes->( dbgotop() )
   Comcodes->( dbeval ( { || ;
                  if ( COMCODES->BRCODE+Comcodes->comcode == g_PAR_BRCH+g_CREDCOM    ,;                  // if ( mTOTAL >= Comcodes->MINIMUM .and. mTOTAL <= Comcodes->MAXIMUM,;  // 01.25.01
                       eval({ || mcomrec  := Comcodes->(recno()) ,;     // EVR 29122006 - changed from Parametr->CREDCOM
                                 mMERON   := .t.                 ,;
                                 mCOMCODE := COMCODES->BRCODE+Comcodes->COMCODE   ,;
                                 mCOMNAME := Comcodes->COMNAME   ,;
                                 mSIGNEES := Comcodes->SIGNEES   ,;
                                 mREQB    := Comcodes->REQB      ,;
                                 mReqA    := Comcodes->REQA     ;
                            })                                                      ,;
                       Nil                                                           ;
                     )                                                               ;
               }                                                                   ,,;
               { || !Comcodes->( eof() )  }                                          ;
              );
             )

   credcom   := .t.
   mcomcode2 := g_PAR_BRCH+g_CREDCOM   // '02'   01.25.01     // EVR 29122006 - changed from PARAMETR->CREDCOM

   if credcom
      dbselectarea('Comember')
      if Comember->( dbseek(mcomcode2) )
         dbeval ( { || aadd( member2,'  '+substr(Comember->Fullname,1,30) +' ³ '+ Comember->Grupcode + Comember->Shortname ) } ,,;
                   { || Comember->(!eof()) .and. COMEMBER->BRCODE+Comember->comcode == mcomcode2 } )
         ********** comember->(dbgoto(mcomrec2))
      endif
   endif

	   if .t.

		  dbselectarea ( "Comember" )
		  if Comember->(dbseek ( mCOMCODE ) )
			 Comember->(dbeval    ( {||  aadd( members, '  '+substr(Comember->Fullname,1,30) +' ³ '+ Comember->GRUPCODE + Comember->Shortname );
									} ,,;
									{|| !Comember->( eof() ) .and. COMEMBER->BRCODE+Comember->COMCODE == mCOMCODE } ;
								  );
					   )
			 Comcodes->( dbgoto(mcomrec) )
		  endif

		  @ 7,2 clear to 18,40
		  fshadow ( 7, 2, 21, 41, 2, 'n/w')
		  @ 8 ,3 say padc(alltrim(mComname)+' Approves',38)  color 'w+/w'
		  @ 9 ,2 say 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´' color 'n/w'
		  @ 17,2 say 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´' color 'n/w'
		  @ 18,3 say '  Min. Requirement        Selected    ' color 'w+/w'
		  @ 19,3 say '     A - '+tran(mreqa,'99')+'                           ' color 'w+/w'
		  @ 20,3 say '     B - '+tran(mReqb,'99')+'                           ' color 'w+/w'
		  @ 19,32 say tran(aSlct,'99')  color 'n/w'
		  @ 20,32 say tran(bSlct,'99')  color 'n/w'

		  cont           := .t.
		  mselected      :=  0
		  mok_to_select  := .t.

		  do while cont
			appray_ := {}
			appray2_:= {}
			msignee  := 1
			aslct :=0
			bSlct :=0
			setcolor('w/n,n/w')

			do while .t.
			  mSIGNEE := achoice ( 10, 4, 16, 39, members,.t.,'myfunc', mSIGNEE,mSignee )
			  do case
				case lastkey() == K_ESC
					   *********** cont := .f.
					   *********** restscreen ( ,,,, mSCR )
					   *********** set device to print
					   *********** restdbf ( mdbf )

					   loop
					   **return .f.
				case lastkey () == K_ENTER //.or. lastkey() == K_ESC
				   mGCTR := 0
				   mCTR  := 0

				   if bslct < mReqb
					  error ( 'Insufficient Group B signees...!!' )
					  loop
				   elseif aslct < mReqa
					  Error('Insufficient Group A signees...!!')
					  loop
				   endif

				   for i := 1 to len ( members )
					   if substr( members [i],1,1) == chr(001)//'û'
						  aadd(appray_,alltrim( substr(members[i],37,60) ) )
					   endif
				   next i

				   set device to print


				   @ prow()+1,01 say ''
				   @ prow()+1,01 say 'DEVIATION FROM APPROVED TERMS AND CONDITION'
				   @ prow()+1,01 say 'CREDIT COMMITTEE APPROVES :'
				   @ prow()+1,01 say ''

				   _print_why()          // why they needed to deviate ?. . .(08/10/00)
				   
				   @ prow()+3,01 say repl( '-',90 )
				   @ prow()+1,01 say ''     

				   for i := 1 to len ( appray_ )
					   @ prow(),pcol()+4 say upper(appray_[i])   // _,alltrim( substr(members[i],37,60) ) )
				   next i

				   cont:=.f.
				   exit
				case lastkey () == 32
				  if bSlct+aSlct <= 7
				   if substr( members [ mSIGNEE ],1,1) = chr(001)//'û'
					  members [ mSIGNEE ] := '  ' + substr(members [ mSIGNEE ],3,len ( members [ mSIGNEE ]  ) - 1 )
					  if(substr(members[ msignee ],36,1) == 'B',bSlct--,aSlct--)
				   else
					  if substr(members[ msignee ],36,1) == 'B'
						 members [ mSIGNEE ] := chr(001)+' '+ substr(members [ mSIGNEE ],3,len ( members [ mSIGNEE ]  ) - 1 )
						 //
						 // mSELECTED++ ;
						 // mSIGNEE++
						 //
						 bslct++
						 if mSIGNEE > len ( members )
							mSIGNEE := len ( members )
						 endif
					  else
						 members [ mSIGNEE ] := chr(001)+' ' + substr(members [ mSIGNEE ],3,len ( members [ mSIGNEE ]  ) - 1 )
						 //mSELECTED++ ; //mSIGNEE++
						 aslct++
						 if mSIGNEE > len ( members )
							mSIGNEE := len ( members )
						 endif
					  endif
				   endif
				   @ 19,32 say tran(aSlct,'99')  color 'n/w'
				   @ 20,32 say tran(bSlct,'99')  color 'n/w'
				  else
					tone(1000,3)
				  endif
			 endcase
			 mSignee := mSignee+1
		   enddo

		   ************** gf := savescreen( ,,, )
		   
		   
		   if _lpaytype
			  set device to print
			  @ prow()+1,01 say ''
			  @ prow()+1,01 say 'REMARKS: CHANGES FROM APPROVED TERMS AND CONDITION'
			  @ prow()+1,01 say ''
			  if Acctwait->paytype == '1'
			     @ prow()+1,01 say padr( '(ú) Changed PAYMENT TYPE :from IN ARREARS to IN ADVANCE',80 )
			  else
			     @ prow()+1,01 say padr( '(ú) Changed PAYMENT TYPE :from IN ADVANCE to IN ARREARS',80 )
			  endif
		   endif
		   restscreen ( ,,,, mSCR )
	  

		   enddo

	   endif
	   restscreen ( ,,,, mSCR )

   
   ELSE
   
	  if _lpaytype
	     set device to print
	     @ prow()+1,01 say ''
	     @ prow()+1,01 say 'REMARKS: CHANGES FROM APPROVED TERMS AND CONDITION'
	     @ prow()+1,01 say ''
		 if Acctwait->paytype == '1'
		    @ prow()+1,01 say padr( '(ú) Changed PAYMENT TYPE :from IN ARREARS to IN ADVANCE',80 )
		 else
		    @ prow()+1,01 say padr( '(ú) Changed PAYMENT TYPE :from IN ADVANCE to IN ARREARS',80 )
		 endif
	  endif
      restscreen ( ,,,, mSCR )

   endif
   set device to print
   
   restdbf ( mdbf )

return nil

****************************
*
static function _print_why()
****************************
   local nctr := 1
   local cmesterm     := 'Changed TERM',lterm := .f.
   local cmesrv       := 'Changed RV'  ,lrv := .f.
   local cmesgd       := 'Changed GD'  ,lgd := .f.
   local cmestruerate := 'Changed TRUERATE', ltruerate := .f.
   local cmesratetype := 'Changed RATETYPE', lratetype := .f.
   local cmespaytype  := 'Changed PAYTYPE', lpaytype  := .f.

   ******* _lpaytype:= _lratetype := _ltruerate := _lgd  := _lrv := _lterm := .t.

   nctr := 1
   for nctr := 1 to len (_ar_term)


       if _lterm

          cmesterm := cmesterm + ' :from '+alltrim(str(_ar_term[nctr]))+' to '+ alltrim(str(Acctwait->term))

          if alltrim(_ar_termunit[nctr]) == '1'
             cmesterm := cmesterm + ' DAYS'
          else
             cmesterm := cmesterm + ' MONTHS'
          endif

          lterm    := .t.
       endif

       if _lrv
          cmesrv := cmesrv + ' :from '+alltrim(str(_ar_rv[nctr]))+' to '+ alltrim(str(Acctwait->rv))
          lrv   := .t.
       endif

       if _lgd .and. Acctwait->fcltycode == _ar_fcltycode [nctr]
          cmesgd := cmesgd + ' :from '+alltrim(str(_ar_gd[nctr]))+' to '+ alltrim(str(Acctwait->gd))
		  
		  if !_ar_sublimit[nctr]
		     cmesgd := cmesgd + ' (Sub-limit)'
		  endif
		  
          lgd    := .t.
       endif

       if _ltruerate
          cmestruerate := cmestruerate + ' :from '+alltrim(str(_ar_truerate[nctr]))+' to '+ alltrim(str(Acctwait->truerate))
          ltruerate := .t.
       endif

       if _lratetype
          if alltrim(_ar_ratetype[nctr]) == '1'
             cmesratetype := cmesratetype + ' :from '+' FIXED ' + ' to '+ ' FLOATING '
          else
             cmesratetype := cmesratetype + ' :from '+' FLOATING' + ' to '+ ' FIXED '
          endif
          lratetype := .t.

       endif

	   
	   /****
       if _lpaytype
          if alltrim(_ar_paytype[nctr]) == '1'
             cmespaytype := cmespaytype + ' :from '  + 'IN ADVANCE'+' to '+ 'IN ARREARS'
          else
             cmespaytype := cmespaytype + ' :from '  + 'IN ARREARS'+' to '+ 'IN ADVANCE'
          endif
          lpaytype := .t.
       endif
	   ****/

   next nctr

   if lterm
      @ prow()+1,01 say padr( '(ú) '+cmesterm,80 )
   endif

   if lrv
      @ prow()+1,01 say padr( '(ú) '+cmesrv,80 )
   endif

   if lgd
      @ prow()+1,01 say padr( '(ú) '+cmesgd,85 )
   endif

   if ltruerate
      @ prow()+1,01 say padr( '(ú) '+cmestruerate,80 )
   endif

   if lratetype
      @ prow()+1,01 say padr( '(ú) '+cmesratetype,80 )
   endif

   if lpaytype
      @ prow()+1,01 say padr( '(ú) '+cmespaytype,80 )
   endif

   if Acctwait->oldcredamt > 0            // abb 09.15.2005

      if Acctwait->oldcredamt != Acctwait->credamt

         cmespaytype := 'Changed CREDIT AMOUNT from '+alltrim(trans(Acctwait->oldcredamt,"999,999,999.99")) + ' to '+;
                        alltrim(trans(Acctwait->credamt,"999,999,999.99"))
         @ prow()+1,01 say padr( '(ú) '+cmespaytype,80 )
      endif

      if Acctwait->oldamort != Acctwait->amort

         cmespaytype := 'Changed MONTHLY AMORTIZATION/RENTAL  from '+alltrim(trans(Acctwait->oldamort,"999,999,999.99")) + ' to '+;
                        alltrim(trans(Acctwait->amort,"999,999,999.99"))
         @ prow()+1,01 say padr( '(ú) '+cmespaytype,80 )
      endif

   endif

return nil

*****************************************
*        August 9, 2000 (abb)
*
static function _change_from_proposal(cDTLCODE)
*****************************************
   local lretval  := .f. , nrecno := Acctwait->(recno())
   local nctr     := 1
   local cterm    := ''
   memvar _ltruerate,_lterm,_lgd,_lrv,_lratetype,_lpaytype,_lcredamt, _lamort

   _ar_term      := {} ; _ar_rv       := {} ;  _ar_gd      := {}
   _ar_truerate  := {} ; _ar_ratetype := {} ;  _ar_paytype := {}
   _ar_fcltycode := {} ; _ar_termunit := {}
   _ar_sublimit  := {}

   _ltruerate    := _lterm := _lgd := _lrv := _lratetype := _lpaytype := .f.

   do case
      case Acctwait->docref == '1'  // FROM Credit Application

           if Caheader->(dbseek(alltrim(ACCTWAIT->BRCODE+Acctwait->refno))) && RED 112504 ADDED 'ACCTWAIT->BRCODE+

              if Cadetail->(dbseek(alltrim(ACCTWAIT->BRCODE+Acctwait->refno)))  && RED 112504 ADDED 'ACCTWAIT->BRCODE+

                 do while !Cadetail->(eof()) .and. ;
                           CADETAIL->BRCODE+Cadetail->canumber == CAHEADER->BRCODE+Caheader->canumber  && RED 112504 ADDED 'CAHEADER->BRCODE 'CADETAIL->BRCODE
					if cDTLCODE == CADETAIL->DTLCODE

                       aadd ( _ar_term     , Cadetail->term      )
                       aadd ( _ar_rv       , Cadetail->rv        )
                       aadd ( _ar_gd       , Cadetail->gd        )
                       aadd ( _ar_truerate , Cadetail->truerate  )
                       aadd ( _ar_ratetype , Cadetail->ratetype  )
                       aadd ( _ar_paytype  , Cadetail->paytype   )
                       aadd ( _ar_fcltycode, Cadetail->fcltycode )
                       aadd ( _ar_termunit ,  Cadetail->termunit  )
					   aadd ( _ar_sublimit ,  Cadetail->include  )
					
					endif

                    Cadetail->(dbskip(+1))

                 enddo

              endif

              _lpaytype:= _lratetype := _ltruerate := _lgd  := _lrv := _lterm := .t.
			  
              nctr  := 1
              for nctr := 1 to len (_ar_term)

                  if _ar_term      [nctr] >= Acctwait->term      .and. ;
                     _ar_fcltycode [nctr] == Acctwait->fcltycode
                     _lterm := .f.
                  endif

                  if ( _ar_rv [nctr]*0.05   >= Acctwait->rv .and. ;
                       _ar_fcltycode [nctr] == Acctwait->fcltycode ;
                     ) .or.;
                     ( _ar_rv [nctr]        >= Acctwait->rv .and. ;
                       _ar_fcltycode [nctr] == Acctwait->fcltycode ;
                     )
                     _lrv   := .f.
                  endif

                  if _ar_gd  [nctr]       <= Acctwait->gd .and. ;
                     _ar_fcltycode [nctr] == Acctwait->fcltycode
                     _lgd   := .f.
                  endif

                  if _ar_truerate [nctr]  <= Acctwait->truerate .and. ;
                     _ar_fcltycode [nctr] == Acctwait->fcltycode
                     _ltruerate := .f.
                  endif

                  if _ar_ratetype  [nctr] == Acctwait->ratetype .and. ;
                     _ar_fcltycode [nctr] == Acctwait->fcltycode
                     _lratetype := .f.
                  endif

                  if _ar_paytype  [nctr] == Acctwait->paytype .and. ;
                     _ar_fcltycode [nctr] == Acctwait->fcltycode
                     _lpaytype := .f.
                  endif

              next nctr

              if !empty(alltrim(Acctwait->docref2))
                 IF Acctwait->docref2 == '1' 
					 if Caheader->(dbseek(alltrim(ACCTWAIT->BRCODE+Acctwait->refno2))) // refno2 = CA     && RED 112504 ADDED 'ACCTWAIT->BRCODE
						if Cadetail->(dbseek(alltrim(ACCTWAIT->BRCODE+Acctwait->refno2)))                 && RED 112504 ADDED 'ACCTWAIT->BRCODE

						   do while !Cadetail->(eof()) .and. ;
									 CADETAIL->BRCODE+Cadetail->canumber == CAHEADER->BRCODE+Caheader->canumber
									 
                              if CADETAIL->DTLCODE == cDTLCODE
							     aadd ( _ar_term    ,Cadetail->term )
							     aadd ( _ar_rv      ,Cadetail->rv   )
							     aadd ( _ar_gd      ,Cadetail->gd   )
							     aadd ( _ar_truerate,Cadetail->truerate   )
							     aadd ( _ar_ratetype,Cadetail->ratetype   )
							     aadd ( _ar_paytype ,Cadetail->paytype    )
							     aadd ( _ar_fcltycode,Cadetail->fcltycode )
							     aadd ( _ar_termunit, Cadetail->termunit )
							     aadd ( _ar_sublimit ,Cadetail->include  )
							  endif

							  Cadetail->(dbskip(+1))
						   enddo
						endif

						nctr  := 1
						for nctr := 1 to len (_ar_term)

							if _ar_term      [nctr] >= Acctwait->term .and. ;
							   _ar_fcltycode [nctr] == Acctwait->fcltycode .AND. !_lterm
							   _lterm := .f.
							endif

							if ( _ar_rv [nctr]*0.05   >= Acctwait->rv .and. ;
								 _ar_fcltycode [nctr] == Acctwait->fcltycode .AND. !_lrv ;
							   ) .or.;
							   ( _ar_rv [nctr]        >= Acctwait->rv .and. ;
								 _ar_fcltycode [nctr] == Acctwait->fcltycode .AND. !_lrv ;
							   ) 
							   _lrv   := .f.
							endif

							if _ar_gd  [nctr]       <= Acctwait->gd .and. ;
							   _ar_fcltycode [nctr] == Acctwait->fcltycode .AND. !_lgd
							   _lgd   := .f.
							endif

							if _ar_truerate [nctr]  <= Acctwait->truerate .and. ;
							   _ar_fcltycode [nctr] == Acctwait->fcltycode .AND. !_ltruerate
							   _ltruerate := .f.
							endif

							if _ar_ratetype  [nctr] == Acctwait->ratetype .and. ;
							   _ar_fcltycode [nctr] == Acctwait->fcltycode .AND. !_lratetype

							   _lratetype := .f.
							endif

							if _ar_paytype  [nctr] == Acctwait->paytype .and. ;
							   _ar_fcltycode [nctr] == Acctwait->fcltycode .AND. !_lpaytype

							   _lpaytype := .f.
							endif

						next nctr
                     endif
                 else              // refno2 is from offering ticket

                    if Oticket->(dbseek(alltrim(ACCTWAIT->BRCODE+Acctwait->refno2))) && RED 112504 ADDED 'ACCTWAIT->BRCODE

                       aadd ( _ar_term     , Oticket->term )
                       aadd ( _ar_rv       , Oticket->rv   )
                       aadd ( _ar_gd       , Oticket->gd   )
                       aadd ( _ar_truerate , Oticket->truerate   )
                       aadd ( _ar_ratetype , Oticket->ratetype   )
                       aadd ( _ar_paytype  , Oticket->paytype    )
                       aadd ( _ar_fcltycode, Oticket->fcltycode )
                       aadd ( _ar_termunit , Oticket->termunit )
					   aadd ( _ar_sublimit , .T. )

                       ****** _lpaytype := _lratetype := _ltruerate := _lgd  := _lrv := _lterm := .t.

                       if Oticket->term >= Acctwait->term
                          _lterm := .f.
                       endif

                       if ((Oticket->rv*0.05) >= Acctwait->rv .AND. !_lrv) .or. ;
                           (Oticket->rv       >= Acctwait->rv .AND. !_lrv)
                          _lrv := .f.
                       endif

                       if Oticket->gd <= Acctwait->gd .AND. !_lgd
                          _lgd := .f.
                       endif

                       if Oticket->truerate <= Acctwait->truerate .AND. !_ltruerate
                          _ltruerate := .f.
                       endif

                       if Oticket->ratetype == Acctwait->ratetype .AND. !_lratetype
                          _lratetype := .f.
                       endif

                       if Oticket->paytype  == Acctwait->paytype .AND. !_lpaytype
                          _lpaytype := .f.
                       endif

                    endif

                 endif


              endif

           endif

      case Acctwait->docref == '2'      // FROM Offering Ticket

           if Oticket->(dbseek(alltrim(ACCTWAIT->BRCODE+Acctwait->refno)))    && RED 112504 ADDED 'ACCTWAIT->BRCODE+

              aadd ( _ar_term     , Oticket->term )
              aadd ( _ar_rv       , Oticket->rv   )
              aadd ( _ar_gd       , Oticket->gd   )
              aadd ( _ar_truerate , Oticket->truerate   )
              aadd ( _ar_ratetype , Oticket->ratetype   )
              aadd ( _ar_paytype  , Oticket->paytype    )
              aadd ( _ar_fcltycode, Oticket->fcltycode )
              aadd ( _ar_termunit , Oticket->termunit )
			  aadd ( _ar_sublimit , .T. )

              _lpaytype := _lratetype := _ltruerate := _lgd  := _lrv := _lterm := .t.

              if Oticket->term >= Acctwait->term
                 _lterm := .f.
              endif

              if (Oticket->rv*0.05) >= Acctwait->rv .or. ;
                  Oticket->rv       >= Acctwait->rv
                 _lrv := .f.
              endif

              if Oticket->gd <= Acctwait->gd
                 _lgd := .f.
              endif

              if Oticket->truerate <= Acctwait->truerate
                 _ltruerate := .f.
              endif

              if Oticket->ratetype == Acctwait->ratetype
                 _lratetype := .f.
              endif

              if Oticket->paytype  == Acctwait->paytype
                 _lpaytype := .f.
              endif

           endif

   endcase

   Acctwait->(dbgoto(nrecno))

   lretval :=  _ltruerate .or. _lterm .or. _lgd .or. _lrv .or. _lratetype .or. _lpaytype
   lretval :=  _ltruerate .or. _lterm .or. _lgd .or. _lrv .or. _lratetype //.or. _lpaytype  PEPE 11:01 AM 9/30/2013
   
   _lcredamt := .f.
   _lamort   := .f.

   if Acctwait->oldcredamt != 0

      if Acctwait->oldcredamt != Acctwait->credamt .or. ;
         Acctwait->oldamort   != Acctwait->amort
         _lcredamt := .t.
         _lamort   := .t.
         lretval   := lretval .or. _lcredamt .or. _lamort
      endif

   endif
///
/// XXXXXX
return lretval

************************************************************************************************
*
static function dispcomputations ( mtotal, mBALANCE, mguarantees, mthistransaction, nusdrate )
************************************************************************************************

   @ prow() + 2 , 13 say 'Balance Outstanding     : ' + transform ( mBALANCE   , '999,999,999.99' )
   @ prow() + 1 , 13 say 'Plus : Other Guarantees : ' + transform ( mguarantees, '999,999,999.99' )
   @ prow() + 1 , 13 say 'Sub-Total               : ' + transform ( mBALANCE + mguarantees , '999,999,999.99' )
   @ prow() + 1 , 13 say 'This Transaction        : ' + transform ( mthistransaction, '999,999,999.99' ) + if(round(nusdrate,2) > 0,' = US$ '+ Tran(round(mthistransaction/ nusdrate,2),'999,999.99') ,space(1)) 
   @ prow() + 1 , 13 say '                           ÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   @ prow() + 1 , 13 say 'TOTAL                   : ' + transform ( mtotal, '999,999,999.99' )
   @ prow() + 1 , 13 say '                           ÍÍÍÍÍÍÍÍÍÍÍÍÍ'

return nil

******************************************************************************
*  Desc ¯ accumulate "BALANCE OUTSTANDING" with Acctwait -> CREDAMT
*           where other Acctwait -> CLNTCODE == current Acctwait->CLNTCODE and
*                 other Acctwait -> VALDATE  <  current Acctwait->VALDATE
*
static function accu_mBALANCE ( cbrcode,mBALANCE )
******************************************************************************
   local mrec := Acctwait -> ( recno() ) , mord := Acctwait -> ( indexord() )
   local macctno := acctwait->acctno
   local mclntcode := Acctwait -> CLNTCODE , mvaldate := Acctwait -> VALDATE

   Acctwait -> ( dbsetorder ( 4 ) )
   if Acctwait -> ( dbseek ( cbrcode+mclntcode ) )
      Acctwait -> ( dbeval ( {|| if ( Acctwait -> VALDATE <= mvaldate .and.;
                                      Acctwait -> (recno()) != mrec .and. right(acctwait->acctno,5) < right(macctno,5) ,;
                                      mBALANCE += Acctwait -> CREDAMT ,;
                                      nil ;
                                    );
                             };
                             ,,;
                             {|| Acctwait -> CLNTCODE == mclntcode .and. ;
                                 Acctwait -> brcode   == cbrcode   .and. ;
                                !Acctwait -> ( eof() ) ;
                             };
                           );
                  )
   endif
   Acctwait -> ( dbsetorder ( mord  ) )
   Acctwait -> ( dbgoto ( mrec ) )
   return nil
/*----------------------------*/
 Static Function agetp_val(sw)
/*----------------------------*/

div_or:= if(empty(Acctwait->Appval),Acctwait->Principal,Acctwait->Appval )
div_nt:= if( sw, Acctwait->Downpay, Acctwait->Incentive )
return tran((div_nt/div_or)*100,'999.99')

*******************************************
static function print_names ()
*******************************************
    memvar mPREPAREDBY, mCHECKEDBY, mNOTEDBY1,mNOTEDBY2
    local  ml := 04, mc := 35, mr := 66
    while prow() < 50; @ prow()+1,0 say '';enddo
    @ prow()+1, ml say repl( chr(196), 92 )
    @ prow()+1, ml say 'Prepared by :'
    @ prow()  , mc say 'Checked by  :'
    @ prow()  , mr say 'Approved by :'
    @ prow()+2, ml say repl( 'Ä', 28 )
    @ prow()  , mc say repl( 'Ä', 28 )
    @ prow()  , mr say repl( 'Ä', 30 )
    @ prow()+1, ml say left( mPREPAREDBY, 30 )
    @ prow()  , mc say left( mCHECKEDBY , 30 )
    @ prow()  , mr say left( mNOTEDBY1  , 30 )
    @ prow()+2, mr say repl( 'Ä', 30 )
    @ prow()+1, mr say left( mNOTEDBY2  , 30 )
return nil
**************************************
static function print_subhead( mwhat,nsetcode )
**************************************
    local mpayfreqchoices := { '1 = Monthly    ','2 = Bi-monthly ','3 = Quarterly  ','4 = Semi-annual','5 = Annual     ','6 = Lumpsum    ','7 = Irregular  ' }
    local mleft := 67, lm := 4, refsw:= .f., refsw2:=.f.

    mwhat := if ( mwhat == nil, .t., mwhat )
    @ prow()+1, 000+lm say replicate( chr(196),90 )
    @ prow()+1, 000+lm say 'Account Number : '
    @ prow()  , pcol() say ACCTWAIT->BRCODE+Acctwait->ACCTNO pict '@R 999-9999-99999-99999'  && RED 112504 ADDED 'ACCTWAIT->BRCODE '999-
    if mwhat
       if nsetcode == '3'
	      if Acctwait->docref == '1'  //pepe
		     @ prow(),mleft + 1 say '  CA Date : ' + Dtoc(Caheader->Cadate)
		  else
             @ prow(),mleft + 1 say '  OT Date : ' + Dtoc(Oticket->Otdate)
		  endif
       else
          @ prow()  , mleft + 1  say "     Date : "
          @ prow()  , pcol()     say dtoc( Acctwait->VALDATE )
       endif
       @ prow()+1, 000+lm     say 'Client         : '
       @ prow(), pcol()   say upper(dispclntname(Acctwait->brcode+Acctwait->CLNTCODE,40 ))
       if nsetcode == '3'
	       if Acctwait->docref == '1'  //pepe
              @ prow(), mleft-1 say 'CA Approval : ' + Dtoc(Caheader->ACTDATE)
		   else
		      @ prow(), mleft-1 say 'OT Approval : ' + Dtoc(Oticket->ACTDATE)
		   endif
       else
          @ prow(), mleft+1  say ' Doc. Ref : '
          @ prow(), pcol()   say if( Acctwait->DOCREF == '1','CA','OT' )+ ' #'
          @ prow(), pcol()   say ACCTWAIT->BRCODE+'-'+Acctwait->REFNO
       endif
    else
       @ prow()  , pcol()+1 say ' '
       @ prow()  , mleft+16 say 'Page : ' + ltrim(trans(mpage,'9,999'))
       @ prow()+1, 000+lm   say 'Client         : '
       @ prow()  , pcol()   say upper ( dispclntname(ACCTWAIT->BRCODE+Acctwait->CLNTCODE,40 ) )
    endif

    if mwhat
        @ prow()+1, 000+lm say 'Address        : '
        @ prow()  , 017+lm say Client->ADDRESS1
        if nsetcode == '3'
              @ prow(), mleft+1 say 'Doc. Ref. : '
              @ prow(), pcol()   say if( Acctwait->DOCREF == '1','CA','OT' )+ ' #'
              @ prow(), pcol()   say TRANS(ACCTWAIT->BRCODE+Acctwait->REFNO,'@R 999-99999')
        else
            if !empty(Acctwait->Docref2)
                 @ prow(), mleft+4  say '       '
                 @ prow(), pcol()   say if( Acctwait->DOCREF2 == '1','CA','OT' )+ ' #'
                 @ prow(), pcol()   say TRANS(ACCTWAIT->BRCODE+Acctwait->REFNO2,'@R 999-99999')
            endif
        endif
        if !empty( Client->ADDRESS2 )
           @ prow()+1, 017+lm say Client->ADDRESS2
           if nsetcode == '3' .and. !empty(Acctwait->Docref2)
              @ prow(), mleft+1  say '       '
              @ prow(), pcol()   say if( Acctwait->DOCREF2 == '1','CA','OT' )+ ' #'
              @ prow(), pcol()   say TRANS(ACCTWAIT->BRCODE+Acctwait->REFNO2,'@R 999-99999')
              refsw:=.t.
           endif
        endif
        if !empty( Client->ADDRESS3 )
           @ prow()+1, 017+lm say Client->ADDRESS3
        endif
        @ prow()+1, 000+lm say 'Industry       : '
        @ prow()  , pcol() say Client->INDCODE+" "+dispindustry (Client->INDCODE)
        if !refsw .and. nsetcode == '3' .and. !empty(Acctwait->Docref2)
              @ prow(), mleft+1  say '        '
              @ prow(), pcol()   say if( Acctwait->DOCREF2 == '1','CA','OT' )+ ' #'
              @ prow(), pcol()   say TRAN(ACCTWAIT->BRCODE+Acctwait->REFNO2,'@R 999-99999')
        endif
        @ prow()+1, 000+lm say 'Signer/Title   : '
        dispsigner( ACCTWAIT->BRCODE+Acctwait->CLNTCODE,prow() )
    endif
    if nsetcode == '3'
       @ prow()+1,0 say ''
       @ prow()+1, 4 say 'Unit                : ' + Acctwait->Unit
       if !empty(Acctwait->Unit2)
          @ prow()+1, 4 say '                    : ' + Acctwait->Unit2
       endif
       @ prow()+1, 4 say 'Surety              : ' + Acctwait->surety1
       if !empty(Acctwait->Surety2)
          @ prow()+1, 4 say '                    : ' + Acctwait->Surety2
       endif
       @ Prow()+1, 4 say "Dealer              : " + eval({|| Dealer->(dbseek(ACCTWAIT->BRCODE+Acctwait->Dlrcode)), substr( Dealer->Dlrname,1,20 ) } )
       @ prow()+1, 4 say 'Salesman            : ' + Acctwait->Salesrep
       @ prow()+1, 4 say 'Cash Price          : ' + Trans( Acctwait->Purcamt,'999,999,999.99')
       @ prow()+1, 4 say 'Appraised Value     : ' + Trans( Acctwait->Appval,'999,999,999.99')   + '  '  + trans( if(empty(Acctwait->Appval),0.00,100.00),'999.99') + '%'
       @ prow()+1, 4 say 'Down Payment        : ' + Trans( Acctwait->Downpay,'999,999,999.99') + '  '  + agetp_val(.t.) + '%'
       @ prow()  ,57 say 'Payment Frequency : ' + Acctwait->PAYFREQ + ' ' +  if ( !empty( Acctwait->PAYFREQ ), substr ( mpayfreqchoices [ val(Acctwait->PAYFREQ) ], 5, 11 ), '  ' )
//       @ prow()+1, 4 say "Dealer's Incentives : " + Trans( Acctwait->Incentive,'999,999,999.99') + '  '+ agetp_val(.f.) + '%'
       @ prow()+1, 4 say "D.I. / S.I.         : " + Trans( Acctwait->Incentive,'999,999,999.99') + '  '+ agetp_val(.f.) + '%'
       @ prow()  ,57 say '  Mode of Payment : ' + upper( disp_mode_pay  ( Acctwait->PAYMODE ) )
    endif
    @ prow()+1, 000+lm say replicate( chr(196),90 )
return nil
********************************************
static function dispsigner( mclntcode,mrow )
********************************************
   if Signers -> ( dbseek( mclntcode ) )
      Signers -> ( dbeval( {|| devpos ( mrow++, 21 ) ,;
                               devout ( trim(Signers ->SIGNER) + '/' + Signers -> TITLE ) ;
                           },,{|| SIGNERS->BRCODE+Signers->CLNTCODE == mclntcode .and. ;
                                 !Signers -> ( eof() ) ;
                           };
                         );
                 )
   endif
return nil
/*
**************************************
static function dispindustry(mindcode)
**************************************
return eval ({|x,y| x := savedbf( x )              ,;
                    Industry->(dbseek( mindcode )) ,;
                    y:=Industry->INDNAME           ,;
                    restdbf( x )                   ,;
                    y                               ;
            })
*/
***********************************
static function print_head( mwhat )
***********************************
   memvar gcompany, gsys_name, gheadmess, mpage, mtrandate
   local  mtitle  :=  'AVAILMENT SHEET'; lm := 4 ; lothr := .f.

   
   othrcomp->(dbgotop())
   do while !othrcomp->(eof())
      if g_PAR_BRCH == othrcomp->brcode
	     lothr := .t.
	  endif
   othrcomp->(dbskip())
   enddo
   
   setfont ( upper("elite") )
   if mwhat == nil
      
      if !lothr
         @ prow()+1, 00+lm say gcompany
         @ prow()  , 67+lm say 'AMS'+ ' '+dtoc(date())+ ' '+ time()
         @ prow()+1, 00+lm say chr(14)+mtitle+chr(14)
	  else
	     @ prow()+1, 00+lm say gsys_name
         @ prow()+1, 00+lm say chr(14)+mtitle+chr(14)
         @ prow()  , 67+lm say ' '+dtoc(date())+ ' '+ time()
	  endif

      setfont ( upper("elite") )
   else
      @ prow()+1 , 000+lm say 'Page : '
      @ prow()   , pcol() say mpage pict '9,999'
      @ prow()+1 , 32+lm  say 'AVAILMENT SHEET'
   endif
   mpage++
return nil
********************************
static function print_facility()
********************************
   local mpayfreqchoices := { '1 = Monthly    ','2 = Bi-monthly ','3 = Quarterly  ','4 = Semi-annual','5 = Annual     ','6 = Lumpsum    ','7 = Irregular  ' }
   local msetcode, mleft := 13
   local nPURC_USD, nGD_USD, nRV_USD, nRENT_USD
 
   nPURC_USD := round(Acctwait->principal / Acctwait->USDRATE,2)
   nGD_USD   := round(round(Acctwait->PRINCIPAL*(Acctwait->GD/100),2) / Acctwait->USDRATE,2)
   nRV_USD   := round(round(Acctwait->PRINCIPAL*(Acctwait->RV/100),2) / Acctwait->USDRATE,2)
   nRENT_USD := round(Acctwait->AMORT / Acctwait->USDRATE,2)
   
   msetcode := Facility->SETCODE
   do case
      case msetcode == '1'
           @ prow()+1, mleft say 'Facility              : ' + trans(Acctwait->FCLTYCODE,'@R 999-99') + ' ' + dispfcltyname( Acctwait->FCLTYCODE )
           @ prow()+1, mleft say 'Lease Item            : ' + Acctwait->UNIT
           if !empty(Acctwait->UNIT2)
              @ prow()+1, mleft say '                        ' + Acctwait->UNIT2
           endif
           if !empty(Acctwait->DLRCODE)
              @ prow()+1, mleft say 'Supplier              : ' + dispsupplier( Acctwait->DLRCODE,Acctwait->brcode )
           endif
           if !empty( Acctwait->PONUM )
              @ prow()+1, mleft say 'PO No.                : ' + Acctwait->PONUM
           endif
           if !empty(Acctwait->UNITLOCA)
              @ prow()+1, mleft say 'Unit Location         : ' + Acctwait->UNITLOCA
           endif
           @ prow()+1, mleft say 'Purchase Amount       : ' + ltrim( trans( Acctwait->PRINCIPAL,'999,999,999.99' ) ) + if(round(Acctwait->usdrate,2) > 0,(' = US$ '+ Tran(nPURC_USD,'999,999.99') +'  @ US$ 1 = Php '+Tran(Acctwait->usdrate,'99.99')),space(1))
*********           @ prow()+1, mleft say 'Term                  : ' + ltrim( trans( Acctwait->TERM, '999' )) + ' Month(s)'
           @ prow()+1, mleft say 'Term                  : ' + ltrim( trans( Acctwait->TERM, '999' )) + ' '+Gettermunit(Acctwait->TErmunit)
           @ prow()+1, mleft say 'True Rate             : ' + ltrim( trans( Acctwait->TRUERATE,'99.9999') ) + ' ' +if( Acctwait->RATETYPE $ '12', if( Acctwait->RATETYPE == '1', 'Fixed   ', 'Floating' ), ' ')
           @ prow()+1, mleft say 'Lease Factor          : ' + ltrim(trans( Acctwait->FACTOR,'99.9999'))
		   @ prow()+1, mleft say 'Guaranty Deposit      : ' + trans( Acctwait->GD, '99.999999%') +'   '+ '[' + ( trans( round(Acctwait->PRINCIPAL*(Acctwait->GD/100),2),'999,999,999.99'))+']'+ if(round(Acctwait->usdrate,2) > 0,(' = US$ '+ Tran(nGD_USD,'999,999.99')),space(1))
           @ prow()+1, mleft say 'Residual Value        : ' + trans( Acctwait->RV, '99.999999%') +'   '+ '[' + ( trans( round(Acctwait->PRINCIPAL*(Acctwait->RV/100),2),'999,999,999.99'))+']'+ if(round(Acctwait->usdrate,2) > 0,(' = US$ '+ Tran(nRV_USD,'999,999.99')),space(1))
           @ prow()+1, mleft say 'Rental                : ' + trans( Acctwait->AMORT   , '999,999,999.99' ) + ' '+ if( Acctwait->PAYTYPE $ '12', if( Acctwait->PAYTYPE == '1', 'IN ADVANCE', 'IN ARREARS' ), ' ')+ if(round(Acctwait->usdrate,2) > 0,(' = US$ '+ Tran(nRENT_USD,'999,999.99')),space(1))
           @ prow()+1, mleft say 'Total Receivables     : ' + trans( Acctwait->CREDAMT+(Acctwait->RV/100*Acctwait->PRINCIPAL), '999,999,999.99' )
           @ prow()+1, mleft say 'Mode of Payment       : ' + upper( disp_mode_pay  ( Acctwait->PAYMODE ) ) // Acctwait -> PAYMODE   + space(2) +
           @ prow()+1, mleft say 'Payment Frequency     : ' + if(!empty( Acctwait->PAYFREQ ), substr ( mpayfreqchoices[val(Acctwait->PAYFREQ)], 5, 11 ), '  ' ) //Acctwait->PAYFREQ + ' ' +
           @ prow()+1, mleft say 'Surety                : ' + Acctwait->surety1
           if !empty(Acctwait->SURETY2)
              @ prow()+1, mleft say '                        ' + Acctwait->SURETY2
           endif
           print_slv( ACCTWAIT->BRCODE+Acctwait->ACCTNO, Acctwait->USDRATE )
      case msetcode == '2'
           @ prow()+2, mleft say 'Facility              : ' + trans(Acctwait->FCLTYCODE,'@R 999-99') + ' ' + dispfcltyname( Acctwait->FCLTYCODE )
           @ prow()+1, mleft say 'Net Proceeds          : ' + (trans( Acctwait->PRINCIPAL ,'999,999,999.99' ))
           @ prow()+1, mleft say 'Credit Amount         : ' + (trans( Acctwait->CREDAMT, '999,999,999.99' ))
																																											//PURCAMT RLV 12:37 PM 4/5/2013
		   @ prow()+1, mleft say 'D.I. / S.I.           : ' + (trans( Acctwait->INCENTIVE, '999,999,999.99' )) +' '+ '[' + ltrim( trans( round((Acctwait->INCENTIVE/Acctwait->PRINCIPAL)*100,2),'99.999999%'))+']'
		   @ prow()+1, mleft say 'Withholding Tax       : ' + (trans( Acctwait->WTAX, '999,999,999.99' ))      +' '+ '['+ ltrim( trans( round((Acctwait->WTAX/Acctwait->PRINCIPAL)*100,2),'99.999999%')) +']'
		   
		   //pepe @ prow()+1, mleft say 'UDI Amount            : ' + ltrim(trans( Acctwait->UDI, '999,999,999.99' ))
		   @ prow()+1, mleft say 'UDI Amount            : ' + ltrim(trans( Acctwait->UDIAMT, '999,999,999.99' ))
           @ prow()+1, mleft say 'Term                  : ' + ltrim(trans( Acctwait->TERM, '999') )  + ' '+Gettermunit(Acctwait->TErmunit)
           @ prow()+1, mleft say 'Effective Rate        : ' + ltrim(trans( Acctwait->TRUERATE,'99.9999')) + ' ' +if( Acctwait->RATETYPE $ '12', if( Acctwait->RATETYPE == '1', 'Fixed   ', 'Floating' ), ' ')
		   
		   @ prow()+1, mleft say 'Net Effective Rate    : ' + ltrim(trans( Acctwait->NERATE,'@B 99.9999') )+ '%'
		   
           @ prow()+1, mleft say 'Amortization          : ' + trans( Acctwait->AMORT  , '999,999,999.99' )+ ' '+ if( Acctwait->PAYTYPE $ '12', if( Acctwait->PAYTYPE == '1', 'IN ADVANCE', 'IN ARREARS' ), ' ')
           @ prow()+1, mleft say 'Surety                : ' + Acctwait->surety1
           if !empty(Acctwait->SURETY2)
              @ prow()+1, mleft say '                        ' + Acctwait->SURETY2
           endif
           @ prow()+1, mleft say 'Security              : ' + Acctwait->UNIT
           if !empty(Acctwait->UNIT2)
              @ prow()+1, mleft say '                        ' + Acctwait->UNIT2
           endif
           @ prow()+1, mleft say 'Mode of Payment       : ' + upper( disp_mode_pay  (Acctwait->PAYMODE) )  //Acctwait -> PAYMODE   + space(2) +
           @ prow()+1, mleft say 'Payment Frequency     : ' + if ( !empty( Acctwait->PAYFREQ ), substr ( mpayfreqchoices [ val(Acctwait->PAYFREQ) ], 5, 11 ), '  ' )  // Acctwait->PAYFREQ + ' ' +
      case msetcode == '3'
           @ prow()+1, mleft say 'Facility                : ' + trans(Acctwait->FCLTYCODE,'@R 999-99') + ' '
           setfont('BOLD')
           @ prow()  , PCOL() SAY dispfcltyname( Acctwait->FCLTYCODE )
           setfont('UNBOLD')
           //@ prow()+2, 00 say trans( Acctwait->FCLTYCODE,'@R 999-99') + ' ' + dispfcltyname( Acctwait->FCLTYCODE )
           @ prow()+1, mleft say 'Net Proceeds            : ' + (trans( Acctwait->PRINCIPAL , '999,999,999.99' ))
																																												//PURCAMT RLV 12:37 PM 4/5/2013
		   @ prow()+1, mleft say 'D.I. / S.I.             : ' + (trans( Acctwait->INCENTIVE, '999,999,999.99' )) +' '+ '[' + ltrim( trans( round((Acctwait->INCENTIVE/Acctwait->PRINCIPAL)*100,2),'99.999999%'))+']'
		   @ prow()+1, mleft say 'Withholding Tax         : ' + (trans( Acctwait->WTAX, '999,999,999.99' ))      +' '+ '['+ ltrim( trans( round((Acctwait->WTAX/Acctwait->PRINCIPAL)*100,2),'99.999999%')) +']'
		   		                                                                                             
           @ prow()+1, mleft say 'Term                    : ' + ltrim(trans( Acctwait->TERM , '999' )) + ' '+Gettermunit(Acctwait->TErmunit)
           @ prow()+1, mleft say 'Gross Rate              : ' + ltrim(trans( Acctwait->TRUERATE  , '@B 99.9999') )+ '% ' +if( Acctwait->RATETYPE $ '12', if( Acctwait->RATETYPE == '1', 'Fixed   ', 'Floating' ), ' ')
           @ prow()+1, mleft say 'Net Effective Rate      : ' + Trans(Acctwait->Nerate,'@B 99.9999')        + '%'
           @ prow()+1, mleft say 'Add-on Rate             : ' + Trans((Acctwait->addon*100),'@B 99.9999' ) + '%'
           @ prow()+1, mleft say 'Amortization            : ' + trans( Acctwait->AMORT  , '999,999,999.99' )
           @ prow(), pcol() + 2 say if( Acctwait->PAYTYPE $ '12', if( Acctwait->PAYTYPE == '1', 'In advance', 'In arrears' ), ' ')
           @ prow()+1, mleft say 'Credit Amount           : ' + trans( Acctwait->CREDAMT, '999,999,999.99' )
           //@ prow()+1, mleft say 'UDI Amount              : ' + trans( Acctwait->CREDAMT - Acctwait->PRINCIPAL - Acctwait->INCENTIVE, '999,999,999.99' )
		   @ prow()+1, mleft say 'UDI Amount              : ' + trans( Acctwait->UDIAMT, '999,999,999.99' )
           //@ prow()+1, mleft say 'First Due Date        : ' + dtoc ( Acctwait->FIRSTDUE )
           //@ prow()+1, mleft say 'Payment Frequency     : ' + Acctwait->PAYFREQ + ' ' +  if ( !empty( Acctwait->PAYFREQ ), substr ( mpayfreqchoices [ val(Acctwait->PAYFREQ) ], 5, 11 ), '  ' )
      case msetcode == '4' .or. msetcode == '5'
           @ prow()+1, mleft say 'Facility              : ' + trans(Acctwait->FCLTYCODE,'@R 999-99') + ' ' + dispfcltyname( Acctwait->FCLTYCODE )
           @ prow()+1, mleft say 'Transaction Type      : ' + Acctwait->TRANTYPE  + ' ' + if( Acctwait->TRANTYPE == '1', 'Revolving', 'Special  ' )
           @ prow()+1, mleft say 'Net Proceeds          : ' + ltrim(trans( Acctwait->PRINCIPAL, '999,999,999.99' ))
           @ prow()+1, mleft say 'Payment Type          : ' + Acctwait->PAYTYPE + ' '+ if( Acctwait->PAYTYPE $ '12', if( Acctwait->PAYTYPE == '1', 'In advance', 'In arrears' ), ' ')
           @ prow()+1, mleft say 'Term                  : ' + ltrim(trans( Acctwait->TERM, '999' ) )+ if( Acctwait->TERMUNIT == '1', ' Days',' Month(s)' )
           @ prow()+1, mleft say 'Effective Rate        : ' + ltrim(trans( Acctwait->TRUERATE,'99.9999')) + ' ' +if( Acctwait->RATETYPE $ '12', if( Acctwait->RATETYPE == '1', 'Fixed   ', 'Floating' ), ' ')
           @ prow()+1, mleft say 'Notification          : ' + Acctwait->NOTFCTN  + ' ' + if( Acctwait->NOTFCTN  $ '12', if( Acctwait->NOTFCTN  == '1', 'With   '   , 'Without'    ), ' ' )
           @ prow()+1, mleft say 'Collection            : ' + Acctwait->COLEXION + ' ' + if( Acctwait->COLEXION $ '12', if( Acctwait->COLEXION == '1', 'Ours  '    , 'Theirs'     ), ' ' )
           @ prow()+1, mleft say 'Recourse              : ' + Acctwait->RECOURSE + ' ' + if( Acctwait->RECOURSE $ '12', if( Acctwait->RECOURSE == '1', 'With   '   , 'Without'    ), ' ' )
           @ prow()+1, mleft say 'Obligor               : ' + Acctwait->OBLIGOR
           @ prow()+1, mleft say 'Collateral            : ' + Acctwait->COLATRL
           @ prow()+1, mleft say 'Payment Frequency     : ' + Acctwait->PAYFREQ + ' ' +  if ( !empty( Acctwait->PAYFREQ ), substr ( mpayfreqchoices [ val(Acctwait->PAYFREQ) ], 5, 11 ), '  ' )
           @ prow()+1, mleft say 'Amortization          : ' + trans( Acctwait->AMORT   , '999,999,999.99' )
           @ prow()+1, mleft say 'Credit Amount         : ' + trans( Acctwait->CREDAMT , '999,999,999.99' )
           @ prow()+1, mleft say 'UDI Amount            : ' + trans( Acctwait->UDI     , '999,999,999.99' )
   endcase
return nil
****************************************
static function dispsupplier( mdlrcode,mbrcode )
****************************************
   Dealer -> ( dbseek ( mbrcode+mdlrcode ) )
return Dealer -> DLRNAME
*******************************
static function print_remarks()
*******************************
   local mctr, mnumlines, i, mnamesprinted := .f.
   LOCAL sREMARKS := COLLMEM( 'AW_REM', ACCTWAIT->ACCTNO, ACCTWAIT->BRCODE )  && RED 112305

   *mnumlines  := mlcount ( Acctwait->REMARKS ,78)
   mnumlines  := mlcount ( sREMARKS ,78)
   *if !empty( Acctwait->REMARKS )                          && RED 112305
   IF LEN(sREMARKS) > 0
      mnamesprinted := .f.
      @ prow()+2 , 04 say 'Remarks : '
      for mctr   := 1 to mnumlines + 1
          *@ prow() + 1, 04 say memoline ( Acctwait->REMARKS , 78, mCTR ,, .f. )    && RED 112305
          @ PROW() + 1, 04 SAY MEMOLINE ( sREMARKS , 78, mCTR ,, .F. )
          if prow() >= MAXROW
             //mnamesprinted := .t.
             for i := prow() to 49 ; @ i,00 say '' ; next i
             print_names ()
             if mctr < mnumlines
                fejectpause()
                print_subhead (.f.)
             else
               setprc( 0,0 )
             endif
          endif
      next mctr
    //  if !mnamesprinted
    //    mnamesprinted := .t.
	if prow() < 49
        for i := prow() to 49 ; @ i,00 say '' ; next i
        print_names ()
	else
	    print_names ()
	endif
    //  endif
      @ prow() , pcol() say ' '
   else
     print_names ()
   endif
return nil
******************************************************************************
*   Desc ¯ computes for the outstanding balance, guarantees,
*          current transaction's CREDAMT and Total Amount
static function compute_first( mtotal,mBALANCE,mguarantees,mthistransaction )
******************************************************************************
   mBALANCE         := computebal ( ACCTWAIT->BRCODE+Acctwait->CLNTCODE )
   accu_mbalance    ( Acctwait->brcode,@mBALANCE )
   mguarantees      := get_group_guarantees( Acctwait->brcode, Acctwait->CLNTCODE )
   mthistransaction := Acctwait->CREDAMT
   mtotal           := mBALANCE + mguarantees + mthistransaction
   return nil
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function get_group_guarantees( cbrcode,mclntcode )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   local mretval := 0,mar2:={}
   local mDBF := savedbf(mDBF), i, mar1 := {}, mgrupcode:='000', marpos
   local mu := { Acctwait->(indexord()),Acctwait->(recno()) }
   local mvaldate := Acctwait->Valdate, xacct:=Substr(Acctwait->Acctno,-5,5 )
   local xrecno := Acctwait->(Recno()),_seek := .t., nbrcode := cbrcode
   
   Grpmembr->(dbsetorder(2))

   if Grpmembr->( dbseek( cbrcode+mclntcode ) )
       mgrupcode := Grpmembr->grupcode
	   do while cbrcode+mclntcode == GRPMEMBR->BRCODE+GRPMEMBR->CLNTCODE
			if cbrcode == GRPMEMBR->BRCODE2
				mgrupcode := Grpmembr->grupcode
				exit
			else
				GRPMEMBR->(dbskip(1))
			endif
		enddo  
  else
	Grpmembr->( ordsetfocus( 3 ) )
	if Grpmembr->( dbseek( cbrcode+mclntcode ) )
		mgrupcode := Grpmembr->grupcode
		_seek := .f.
		nbrcode := GRPMEMBR->BRCODE
	endif
  endif	
   
Grpmembr->( ordsetfocus( 1 ) )
if _seek
	Grpmembr->( dbseek( cbrcode+mgrupcode ) )
else
	Grpmembr->( dbseek( nbrcode+mgrupcode ) )
endif
      //mgrupcode := Grpmembr->GRUPCODE
	 // Grpmembr->( dbseek( cbrcode ) ) //RLV 5:07 PM 12/16/2008
     // Grpmembr->( dbgotop() ) RLV 5:07 PM 12/16/2008
	 
      Grpmembr->( dbeval( {|| if( Grpmembr->GRUPCODE == mgrupcode,;
                                  aadd( mar1,{ if(Grpmembr->brcode != Grpmembr->brcode2,Grpmembr->brcode2+Grpmembr->clntcode,Grpmembr->brcode+Grpmembr->clntcode),;
                                               Grpmembr->GRUPCODE ;
                                              };
                                      ),;
                                  nil;
                                 );
                          },,;
                          {|| !Grpmembr->(eof()) .and. ;
                               Grpmembr->brcode == nbrcode;
                          };
                        );
                 )

      marpos := ascan(mar1,{|x| x[1] == cbrcode+mclntcode })
      adel  ( mar1,marpos )
      asize ( mar1,len(mar1)-1 )    
      mar2 := aclone( mar1 )
      ACCTMAST->( dbsetorder(2) )            // CLIENT CODE
      for i := 1 to len(mar1)
          if ACCTMAST->(dbseek(mar1[i][1]))
		  
		     do while ACCTMAST->brcode+ACCTMAST->CLNTCODE == mar1[i][1] .and. ;
			         !ACCTMAST->( eof() )
		        if ACCTMAST->status != '0'
				   mretval += ACCTMAST->OSBAL
				endif
		   
		     ACCTMAST->(dbskip())
		     enddo
			 
             //ACCTMAST->( dbeval ( { || mretval += ACCTMAST->OSBAL },,;
             //                     { || !ACCTMAST->( eof() ) .and. ;
             //                          ACCTMAST->brcode+ACCTMAST->CLNTCODE == mar1[i][1] .and. ACCTMAST->status != '0' ;
             //                     };
             //                   );
             //          )
          endif
      next i
      Acctwait->(dbsetorder(4))
      for i := 1 to len(mar2)
          if ACCTwait->(dbseek(mar2[i][1]))
             ACCTwait->( dbeval ( { || mretval += if( Acctwait->Clntcode <> mclntcode .AND. Acctwait->Valdate <= mValdate .and. Substr(Acctwait->Acctno,-5,5 ) < xacct , ACCTwait->Credamt,;
                                                  if( Acctwait->(recno()) <> xrecno .AND. Acctwait->Valdate <= mValdate .and. Substr(Acctwait->Acctno,-5,5 ) < xacct, Acctwait->Credamt, 0 ) ) },,;
                                     { || !ACCTwait->( eof() ) .and. ;
                                       ACCTwait->brcode+ACCTwait->CLNTCODE == mar2[i][1] ;
                                  };
                                );
                       )
          endif
      next i
   //endif
   Acctwait->(dbsetorder(mu[1]))
   Acctwait->(dbgoto(mu[2]))
   restdbf ( mDBF )
   return mretval
   
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function computebal( mclntcode )
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ   
   local mDBF := savedbf( mDBF )
   local mBALANCE := 0

   dbselectarea ("ACCTMAST")
   ACCTMAST->( dbsetorder(2) )
   ACCTMAST->( dbseek(mclntcode) )
   DO WHILE ACCTMAST->BRCODE+ACCTMAST->CLNTCODE == mclntcode .and. ;
           !ACCTMAST->(eof())
      If ACCTMAST->status != '0' 
	     mBALANCE += ACCTMAST->OSBAL 
	  EndIf
   ACCTMAST->(DBSKIP())
   ENDDO
   
   /****
   dbselectarea ("ACCTMAST")
   ACCTMAST->( dbsetorder(2) )
   ACCTMAST->( dbseek(mclntcode) )
   ACCTMAST->( dbeval({|| mBALANCE += ACCTMAST->OSBAL } ,,;
                      {|| ACCTMAST->BRCODE+ACCTMAST->CLNTCODE == mclntcode .and. ;
                         !ACCTMAST->(eof()) .and. ACCTMAST->status != '0' ;
                      };
                     );
             )
   ****/

   restdbf (mDBF)
   return (mBALANCE)

// Eop: AMSM107B.prg //
/*
1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
         1         2         3         4         5         6         7         8         9         0
  ----------------------------------------------x-----------------------------------------------

   1 ___________________ ___________ ___________  31 ___________________ ___________ ___________
   2 ___________________ ___________ ___________  32 ___________________ ___________ ___________
   3 ___________________ ___________ ___________  33 ___________________ ___________ ___________
   4 ___________________ ___________ ___________  34 ___________________ ___________ ___________
   5 ___________________ ___________ ___________  35 ___________________ ___________ ___________
   6 ___________________ ___________ ___________  36 ___________________ ___________ ___________
   7 ___________________ ___________ ___________  37 ___________________ ___________ ___________                                                                        Doc. Ref. : xx #99999
   8 ___________________ ___________ ___________  38 ___________________ ___________ ___________
   9 ___________________ ___________ ___________  39 ___________________ ___________ ___________
  10 ___________________ ___________ ___________  40 ___________________ ___________ ___________
  11 ___________________ ___________ ___________  41 ___________________ ___________ ___________
  12 ___________________ ___________ ___________  42 ___________________ ___________ ___________
  13 ___________________ ___________ ___________  43 ___________________ ___________ ___________
  14 ___________________ ___________ ___________  44 ___________________ ___________ ___________
  15 ___________________ ___________ ___________  45 ___________________ ___________ ___________
  16 ___________________ ___________ ___________  46 ___________________ ___________ ___________
  17 ___________________ ___________ ___________  47 ___________________ ___________ ___________
  18 ___________________ ___________ ___________  48 ___________________ ___________ ___________
  19 ___________________ ___________ ___________  49 ___________________ ___________ ___________
  20 ___________________ ___________ ___________  50 ___________________ ___________ ___________
  21 ___________________ ___________ ___________  51 ___________________ ___________ ___________
  22 ___________________ ___________ ___________  52 ___________________ ___________ ___________
  23 ___________________ ___________ ___________  53 ___________________ ___________ ___________
  24 ___________________ ___________ ___________  54 ___________________ ___________ ___________
  25 ___________________ ___________ ___________  55 ___________________ ___________ ___________
  26 ___________________ ___________ ___________  56 ___________________ ___________ ___________
  27 ___________________ ___________ ___________  57 ___________________ ___________ ___________
  28 ___________________ ___________ ___________  58 ___________________ ___________ ___________
  29 ___________________ ___________ ___________  59 ___________________ ___________ ___________
  30 ___________________ ___________ ___________  60 ___________________ ___________ ___________
  ITEM                   Checked by     Kept by     ITEM                 Checked by      Kept By
  ----------------------------------------------------------------------------------------------
  xxxxxxxxxxxxxxxxxxxxx  ----------------------     xxxxxxxxxxxxxxxxxxx  -----------------------
  ---------------------  ----------------------     -------------------  -----------------------
  LEASE AGREEMENT        ______________________     INSURANCE POLICY     _______________________
  AGREE TO SELL (XXIII)  ______________________

*/
