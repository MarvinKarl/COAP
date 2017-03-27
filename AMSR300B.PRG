/*
 ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ·
 ³   Program ID.........:  AMSR300B.prg                                 Ì»
 ³   Description........:  top clients                                  ºº
 ³   Author.............:  Ariel B. Bulan                               ºº
 ³   Date...............:  01:53pm 21-Apr-1995                          ºº
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶º
 ³                         U P D A T E S                                ºº
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶º
 ³        Who        ³     When      ³               Why                ºº
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶º
 ³ Janet L. Bautista ³  18-Jun-1998  ³ include past due & items         ºº
 ³ abb               ³  09-May-2001  ³ balances for previous dates      ºº
 ³ abb               ³  27-Aug-2001  ³ add sold rec'bles validations    ºº
 ³ abb               ³  27-Aug-2001  ³ add sold rec'bles validations    ºº
 ³ mts               ³  29-Dec-2006  ³ added AMSHIST2                   ºº
 ³ aga               ³  14.02.2007   ³ removed paysked reference        ºº
 ³ RLV               ³  03-FEB-2012  ³ Filter for cancelled accounts    ºº
 ÔËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼º
  ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
*/

#include "Colf.ch"
#include "Inkey.ch"

#define MAXROW 53
#xtrans getlastrec(<(mlastrec)>) => Acctmast->( dbeval({|| if( (Acctmast->STATUS=='1'.or. Acctmast->STATUS=='2' .or. Acctmast->STATUS=='3'),<mlastrec>++, nil )},,{||!Acctmast->(eof())}) )
// #xtrans getlastrec(<(mlastrec)>) => Acctmast->( dbeval({|| if( (Acctmast->STATUS=='1'),<mlastrec>++, nil )},,{||!Acctmast->(eof())}) )
memvar ax_level,g_user_id

if chkpass( procname(),ax_level,g_user_id )
   if amsr300Bopen()
      ******* nosnow(.t.)
      amsr300Bmain()
      ******* nosnow(.f.)
   endif
   eval ({|| __mrelease( "*", .t.), dbcloseall() })
   ferase('c:\amsr300b.dbf')
   ferase('c:\amsr300b.ntx')
endif
return
******************************
static function amsr300Bmain()
******************************
   memvar  gtrandate
   local   mdbf   := savedbf (mdbf), mcolor := setcolor(), mcursor := setcursor()
   private mlimit := 0,mdate := gTRANDATE   && RED 031005 Flag->trandate     // EVR 01112007- changed from PARAMETR->TRANDATE
   private _sold_choice
	///chi051809*******************
	if true_brch == '001'
		crea_dbf()
		tmpdbf := 'amsr300b'
	else
		xstr := chk_par(g_user_id)
		tmpdbf := CPS_REQST(xstr,'_CREADBF032') 
	endif
   dbselectarea ( "Acctmast" )
   if _get_sold_choice()
      if getlimit()
         *repcontrol ('_amsr300Bprint()',,,8,33)
         xSTR := CHK_PAR(_SOLD_CHOICE)+CHK_PAR(mLIMIT)+CHK_PAR(mDATE)+;
                 CHK_PAR(gSYS_NAME)+CHK_PAR(gCOMPANY)+CHK_PAR(tmpdbf)
         REPCON_OL ('_AMSR300BPRINT()',,,8,33,,xSTR,.T.)
         restdbf    (mdbf)
         setcolor   (mcolor)
         setcursor  (mcursor)
      endif
   endif
return nil

**********************************
*
static function _get_sold_choice()
**********************************
   local _cscr := savescreen (,,,),menulist := {}
   _sold_choice := 1
   @ 15,40 clear to 18,62
   @ 15,40 to 18,62
   @ 16,41 prompt "All (excluding sold) "
   @ 17,41 prompt "With Sold Rec'bles"
   menu to _sold_choice
   do case
      case _sold_choice == 1
//         alert ( str(_sold_choice) )
      case _sold_choice == 2
//         alert ( str(_sold_choice) )
   endcase

   restscreen  (,,,,_cscr)
return lastkey () != K_ESC

*******************************
static function getlimit()
*******************************
   memvar mlimit,mdate 
   local getlist := {}, mcolor := setcolor()

   fshadow  ( 10, 30, 13, 55, 2, 'gr+/g' )
   setcolor ( 'w/g, w+/n,,, w+/g' )

   @ 11, 31 say 'Limit       ' ;
            get mlimit          ;
            pict '99,999'       ;
            valid mlimit > 0

   @ 12, 31 say 'As of Date  ' ;
            get  mdate          ;
            when !empty( mdate := getdate( mdate, 13, 41, 'w/gr, gr+/gr,,, n/gr' ) )

   setcursor( 3 )   
   read
   setcursor( 0 )

   setcolor( mcolor )

return lastkey() != K_ESC
*******************************
function _amsr300Bprint()
*******************************
   local mscr := savescreen(,,,)
   memvar gtrandate
   private mpage := 1,mmonth,mdays,myear,mtitle

/**************

   mmonth := month ( FLAG->PREVDATE )
   mdays  := day   ( FLAG->PREVDATE )
   myear  := year  ( FLAG->PREVDATE )

**************/

   mmonth := month ( mdate )
   mdays  := day   ( mdate )
   myear  := year  ( mdate )

   setprc     (0,0)
   setfont    ( upper('condensed') )
   printrec   ()
   restscreen (,,,,mscr)
return nil

******************************
*
static function printrec()
******************************
   memvar mlimit
   local  mar := {}, mclntcode, mindcode,nosbal2 := 0
   local  mosbal   , mnoaccts , mrecno := 0 , mgtotal := 0, mlastrec := 0
   local  mprincipal := 0

   Acctmast->   ( dbgotop() )
   getlastrec   ( mlastrec  )
   Acctmast->   ( dbgotop() )
   disp_message ()

//    _sold_choice := 1

   if _sold_choice==1            // EXCLUDING SOLD RECEIVABLES

/***************
   Acctmast->( dbeval( {|| if ( Acctmast->STATUS !='4' .and.  ;
                                Acctmast->STATUS !='5' .and.  ;
                                _stathist ( Acctmast->acctno,mdate ) != '6' ,;
*************/

   Acctmast->( dbeval( {|| if ( !(_stathist ( ACCTMAST->BRCODE+Acctmast->acctno,mdate ) $ '456') .AND. ;
                                 ACCTMAST->BRCODE == g_PAR_BRCH .AND.       ;  && RED 031105
                                 ACCTMAST->VALDATE <= mDATE  .and.          ;  && RED 012006
								 ACCTMAST->STATUS != '0'				   ,; // RLV 10:31 AM Friday, February 03, 2012
                                eval ({|| mclntcode  := Acctmast->CLNTCODE ,;
                                          mindcode   := getindustry()      ,;
                                          mosbal     := mnoaccts  := 0     ,;
                                          mprincipal := 0                  ,;
                                          Acctmast->( dbeval( {||  if (  !(_stathist ( ACCTMAST->BRCODE+Acctmast->acctno,mdate ) $ '456') ,;
                                                                         eval ({||  nosbal2 := 0 ,;
                                                                                    nosbal2 := _get_outs(),;
                                                                                    if ( round(nosbal2,2) <> 0 .and. Acctmast->valdate <= mdate,;
                                                                                         eval({|| ;
                                                                                                  mnoaccts++  ,;
                                                                                                  mrecno++    ,;
                                                                                                  mosbal  += nosbal2 ,;                 // Acctmast->OSBAL,;
                                                                                                  mprincipal += Acctmast->principal ,;  // Acctmast->PRINCIPAL
                                                                                                  mgtotal += nosbal2  ;                 // Acctmast->OSBAL,;
                                                                                            }) ,;
                                                                                         nil ;
                                                                                       ),;
                                                                                    disp_bar( mrecno,mlastrec,mclntcode,mindcode,mnoaccts,mosbal );
                                                                               }),;
                                                                    nil ) ;
                                                               },,;
                                                               {|| !Acctmast->(eof()) .and. ;
                                                                    Acctmast->CLNTCODE == mclntcode .AND. ;
                                                                    ACCTMAST->BRCODE   == g_PAR_BRCH ;
                                                               };
                                                             );
                                                     ),;
                                          Acctmast->( dbskip(-1) ),;
                                          add2temp(mclntcode,mindcode,mnoaccts,mosbal);
                                           }),;
                              nil );
                       },,;
                       {|| !Acctmast->(eof()) };
                     );
             )
			 
   
   ///chi051809 for backup
   /* aadd( mar,{ dispclntname(g_PAR_BRCH+mclntcode,40) ,;
                                                       mindcode                ,;
                                                       dispindustry(mindcode ) ,;
                                                       mnoaccts                ,;
                                                       mosbal                  ,;
                                                          ;
                                                     };
                                               ) */


   else                         // INCLUDING SOLD RECEIVABLES . . .

   Acctmast->( dbeval( {|| if ( !(_stathist ( ACCTMAST->BRCODE+Acctmast->acctno,mdate ) $ '45') .AND. ;
                                  ACCTMAST->BRCODE == g_PAR_BRCH .AND.     ;        && RED 031105
                                  ACCTMAST->VALDATE <= mDATE   .and.            ;        && RED 012006
								  ACCTMAST->STATUS != '0'				   ,; // RLV 10:31 AM Friday, February 03, 2012
                                eval ({|| mclntcode := Acctmast->CLNTCODE ,;
                                          mindcode  := getindustry()      ,;
                                          mosbal    := mnoaccts  := 0     ,;
                                          mprincipal := 0 ,;
                                          Acctmast->( dbeval( {||  if ( !(_stathist ( ACCTMAST->BRCODE+Acctmast->acctno,mdate ) $ '45') ,;
                                                                         eval ({||  nosbal2 := 0 ,;
                                                                                    nosbal2 := _get_outs(),;
                                                                                    mprincipal := 0 ,;
                                                                                    if ( round(nosbal2,2) <> 0 .and. Acctmast->valdate <= mdate,;
                                                                                         eval({|| mnoaccts++  ,;
                                                                                                  mrecno++    ,;
                                                                                                  mosbal  += nosbal2 ,;  // Acctmast->OSBAL,;
                                                                                                  mprincipal += Acctmast->principal ,;  // Acctmast->PRINCIPAL
                                                                                                  mgtotal += nosbal2  ;  // Acctmast->OSBAL,;
                                                                                            }) ,;
                                                                                         nil ;
                                                                                       ),;
                                                                                    disp_bar( mrecno,mlastrec,mclntcode,mindcode,mnoaccts,mosbal );
                                                                              }),;
                                                                    nil ) ;
                                                               },,;
                                                               {|| !Acctmast->(eof()) .and. ;
                                                                    Acctmast->CLNTCODE == mclntcode .AND. ;
                                                                    ACCTMAST->BRCODE == g_PAR_BRCH        ;
                                                               };
                                                             );
                                                     ),;
                                          Acctmast->( dbskip(-1) ),;
										  add2temp(mclntcode,mindcode,mnoaccts,mosbal,mprincipal);
                                          }),;
                              nil );
                       },,;
                       {|| !Acctmast->(eof()) };
                     );
             )
   //traverse_array( mar,mgtotal )


   endif
   amsr300b->(dbcommit())
   amsr300b->(dbunlock())
   traverse_array( mar,mgtotal )
return nil

********************************************************************************
static function disp_bar( mrecno,mlastrec,mclntcode,mindcode,mnoaccts,mbalance )
// static function disp_bar( mrecno,mlastrec,mclntcode,mindcode,mnoaccts,mbalance )
********************************************************************************
   local mcol,mcolor,mper := (mrecno/mlastrec)*100
   set device to screen
   dispbegin()
   mcol := 22 + ((mrecno/mlastrec)/100) * 33 * 100
   setpos ( 14,35 ); dispout ( left ( dispclntname(g_PAR_BRCH+mclntcode,40),20),'w+/gr' )
   setpos ( 15,35 ); dispout ( left ( dispindustry(mindcode ),20),'w+/gr' )
   setpos ( 16,35 ); dispout ( padr ( ltrim(trans(mnoaccts,'9,999')),20),'w+/gr' )
   setpos ( 17,35 ); dispout ( padr ( ltrim(trans(mbalance,'999,999,999.99')),20),'w+/gr' )
   setpos ( 19,22 ); dispout ( repl ( ' ',mcol-22) ,'n/w' )
   if col() >= 38
      do case
         case col() == 38
            setpos ( 19,37 ); dispout ( left ( ltrim(trans(mper,'999')),1)       ,'n/w'   )
            setpos ( 19,38 ); dispout ( right( rtrim(trans(mper,'999')),1)+ '%'  ,'w+/gr' )
         otherwise
            setpos ( 19,37 ); dispout ( ltrim( trans( mper, '999' ) ) + '%','n/w')
      endcase
   else
      setpos ( 19,37 ); dispout ( ltrim( trans( mper, '999' ) ) + '%','w+/gr')
   endif
   dispend()
   set device to printer
return nil
*************************************
static function disp_message( mmess )
*************************************
  set device to screen
  dispbegin()
  fshadow( 13, 21, 20, 55, 2, 'w/gr' )
  setpos ( 14, 22 ); dispout ( '    Client  ', 'bg+/gr' )
  setpos ( 15, 22 ); dispout ( '  Industry  ', 'bg+/gr' )
  setpos ( 16, 22 ); dispout ( '# of Accts  ', 'bg+/gr' )
  setpos ( 17, 22 ); dispout ( '   Balance  ', 'bg+/gr' )
  setpos ( 18, 21 ); dispout ('ÆÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍµ','w/gr')
  dispend()
  set device to printer
return nil
**********************************************
static function traverse_array ( mar,mgtotal )
**********************************************
   local  mtnoaccts := 0, mtosbal := 0,acctcnt := 1
   memvar mlimit
   ///chi051809*****************************
	amsr300b->(dbgobottom())
	printhead()
	printsubhead() 
	do while .t.
		if acctcnt <= mlimit
			disp_rec( amsr300b->fullname,amsr300b->indcode,amsr300b->indname,amsr300b->noacct,amsr300b->osbal,@mtnoaccts,@mtosbal,amsr300b->principal)
		else
			exit
		endif
		acctcnt++
		amsr300b->(dbskip(-1))
	enddo
	printfooter(mtnoaccts,mtosbal,mgtotal)
	__eject()
   ///**************************************
   /* eval ({|| asort( mar,,,{|x,y| x[5]>y[5] } ) ,;
             if( len(mar)>mlimit,asize(mar,mlimit),nil ) ,;
             printhead()                       ,;
             printsubhead()                    ,;
             aeval ( mar, {|x| if ( x[1] != nil ,;
                                    disp_rec( x[1],x[2],x[3],x[4],x[5],@mtnoaccts,@mtosbal,x[6]);
                                    ,nil ) } ), printfooter(mtnoaccts,mtosbal,mgtotal), __eject()}) */
return nil
***********************************************************************************************
static function disp_rec( mclntname,mindcode,mindname,mnoaccts,mosbal,mtnoaccts,mtosbal,nprincipal)
***********************************************************************************************
   local mcol := { 4,49,96,104}
   eval ({|| devpos ( prow()+1, mcol[1]  ), devout ( padr(mclntname,40) ) ,;
             devpos ( prow()  , mcol[2]  ), devout ( mindcode  ) ,;
             devpos ( prow()  , pcol()+1 ), devout ( mindname  ) ,;
             devpos ( prow()  , mcol[3]  ), devout ( trans(mnoaccts,'9,999') ) ,;
             devpos ( prow()  , mcol[4]  ), devout ( trans(nprincipal,'999,999,999,999.99') ) ,;
             devpos ( prow()  , pcol()+2 ), devout ( trans(mosbal,'999,999,999,999.99') ) ,;
             mtnoaccts += mnoaccts ,;
             mtosbal   += mosbal   ,;
             check_eject( MAXROW )})
return nil
**********************************************************
static function printfooter(mtnoaccts,mtosbal,mgtotal)
**********************************************************
   memvar mlimit
   check_eject( 45 )

//    @ prow() + 1, 096 say 'ÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   @ prow() + 1, 096 say 'ÄÄÄÄÄÄ                     ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   @ prow() + 1, 040 say 'TOTAL : '
   @ prow()    , 095 say trans( mtnoaccts,'99,999' )
   @ prow()    , 104+20 say trans( mtosbal,'999,999,999,999.99' )
   @ prow() + 1, 096 say 'ÍÍÍÍÍÍ                     ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ'
   @ prow() + 2, 040 say 'CURRENT LEASE CONTRACTS RECEIVABLES'
   @ prow() + 1, 040 say 'AND FINANCE RECEIVABLES'
   @ prow()    , 104+20 say trans( mgtotal,'999,999,999,999.99' )
   @ prow() + 1, 096 say '                           ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ'
   @ prow() + 2, 040 say '% OF TOTAL RECEIVABLES FROM TOP '+ltrim(trans(mlimit,'99,999'))+' CLIENTS'
   @ prow() + 1, 040 say 'AND FINANCE RECEIVABLES'
   @ prow() + 1, 096 say (mtosbal/mgtotal)*100 pict '999.99 %'
   @ prow() + 1, 096 say 'ÍÍÍÍÍÍÍÍ'
return nil
******************************
static function getindustry()
******************************
return  eval ({|x,y| x := savedbf(x), Client->(dbseek(ACCTMAST->BRCODE+Acctmast->CLNTCODE)),;
                y := Client->INDCODE, restdbf(x), y })
********************************************
static function check_eject(mmaxrow)
********************************************
   if prow() > mmaxrow
      __eject() ; printhead() ; printsubhead()
   endif
return nil
**********************************
static function printhead()
**********************************
    memvar mtitle,mpage,gsys_name,gcompany,mmonth,mdays,myear,mlimit
    setfont( upper("normal") )
    eval ({|| mtitle := 'TOP '+ltrim(trans(mlimit,'99,999'))+' CLIENTS',prnreptitle  ( 80,0,mpage,mtitle,'Program ID:AMSR300B',gsys_name,gcompany),pagecenter   ( prow()+1,80,'As of '+fr0100month( trans(mmonth,'99') )+' '+trans(mdays,'99')+', '+trans(myear,'9999'),mpage++ )})
    setfont( upper("condensed") )
return nil
******************************
static function printsubhead()
******************************
/*****
   @ prow() + 2 , 04 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   @ prow() + 1 , 04 say 'Client Name                                  Industry                                       No. of     Outstanding'
   @ prow() + 1 , 04 say '                                                                                            Accts.       Balance  '
   @ prow() + 1 , 04 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
*****/

   @ prow() + 2 , 04 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
   @ prow() + 1 , 04 say 'Client Name                                  Industry                                       No. of     Principal          Outstanding'
   @ prow() + 1 , 04 say '                                                                                            Accts.                          Balance  '
   @ prow() + 1 , 04 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'

return nil
/*
*****************************************
static function dispindustry(mindcode)
*****************************************
return eval ({|x,y| x := savedbf( x ), Industry->(dbseek( mindcode )),;
                    y:=Industry->INDNAME, restdbf( x ), y })
*/
****************************
*
static function _get_outs( )
****************************
   local nretval := Acctmast->credamt, ddate := ctod ('')
   local dretval := ctod('')
   local pgn:=1
   local tot_amrt := 0, tot_pen := 0, npent_s := 0,ncredamt:= Acctmast->Credamt
   local Pay_:={ 'Paymt',;              // 1
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
                 'Balance Forwarded' }  //16
   local tot_or:=0, tot_am := 0, tot_penal := 0
   local xoramount := xamort := xpenal:=0,pprd:={},pperiod,unpd_pen := 0
   local xacctno,xornum,xrefdate,xcode,nrow:= { 05,19,32,43,60,86,93,117 }, xBRCODE
   local _ddate := mdate

//aga.26.04.2006.removed for delinquency reengineering
//   xblk := { || Paysked->Lastpay <= pdate }

   Amshist->  ( dbseek(ACCTMAST->BRCODE+Acctmast->Acctno) )
if Amshist->  ( dbseek(ACCTMAST->BRCODE+Acctmast->Acctno) )
   ncredamt := Acctmast->Credamt

   do while AMSHIST->BRCODE+Amshist->Acctno == ;                           && RED 031105 ADDED '->BRCODE
            ACCTMAST->BRCODE+Acctmast->Acctno .and. !Amshist->(eof())      && RED 031105 ADDED '->BRCODE
         xrefdate  := Amshist->Refdate
         xornum    := Amshist->Ornumber
         xacctno   := Amshist->Acctno
         xcode     := Amshist->Paycode
         xBRCODE   := AMSHIST->BRCODE     && RED 031105
         unpd_pen  += Amshist->Unpd_pnlty

         do while Amshist->Acctno   == xAcctno  .and. ;
                  Amshist->Ornumber == xornum   .and. ;
                  Amshist->Refdate  == xrefdate .and. ;
                  Amshist->Paycode  == xcode    .and. ;
                  AMSHIST->BRCODE   == xBRCODE  .AND. ;
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
         nretval -= (xamort)
         pprd      := {}
         tot_or    += xOramount
         tot_am    += xamort
         tot_penal += xPenal
         xoramount := xamort := xpenal:=0

   enddo
endif

   Amshist2->  ( dbseek(ACCTMAST->BRCODE+Acctmast->Acctno) )    && RED 031105 ADDED 'ACCTMAST->BRCODE+
if Amshist2->  ( dbseek(ACCTMAST->BRCODE+Acctmast->Acctno) )    && RED 031105 ADDED 'ACCTMAST->BRCODE+

   ncredamt := Acctmast->Credamt

   do while AMSHIST2->BRCODE+AMSHIST2->Acctno == ;                           && RED 031105 ADDED '->BRCODE
            ACCTMAST->BRCODE+Acctmast->Acctno .and. !AMSHIST2->(eof())      && RED 031105 ADDED '->BRCODE
         xrefdate  := AMSHIST2->Refdate
         xornum    := AMSHIST2->Ornumber
         xacctno   := AMSHIST2->Acctno
         xcode     := AMSHIST2->Paycode
         xBRCODE   := AMSHIST2->BRCODE     && RED 031105
         unpd_pen  += AMSHIST2->Unpd_pnlty

         do while AMSHIST2->Acctno   == xAcctno  .and. ;
                  AMSHIST2->Ornumber == xornum   .and. ;
                  AMSHIST2->Refdate  == xrefdate .and. ;
                  AMSHIST2->Paycode  == xcode    .and. ;
                  AMSHIST2->BRCODE   == xBRCODE  .AND. ;
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
         nretval -= (xamort)
         pprd      := {}
         tot_or    += xOramount
         tot_am    += xamort
         tot_penal += xPenal
         xoramount := xamort := xpenal:=0

   enddo
endif 

return nretval

**************************************************
*
static function _stathist ( cacctno,dend )
**************************************************
   local dretval := ctod ('') ,lfound := .f., cstatus := space(1)

   if Stathist->(dbseek(cacctno))
      lfound := .t.

      do while STATHIST->BRCODE+Stathist->acctno == cacctno .and. !Stathist->(eof())      && RED 031105 ADDED 'STATHIST->BRCODE+

         if Stathist->newstatus == Acctmast->status // '6' // SOLD REC'BLES
            if Stathist->trandate > dend
               cstatus := stathist->oldstatus   // get the latest 9.10.2001
            endif
         endif
         stathist->(dbskip(+1))

      enddo

   endif

   if !lfound
      cstatus := Acctmast->status
   else
      if empty(cstatus)
         cstatus := Acctmast->status
      endif
   endif

return cstatus

******************************
static function amsr300Bopen()
******************************
   local mretval := .f.
   memvar g_cis_path
   if netuse('&g_AMS_PATH\Acctmast',.f.,5)
      set index to &g_AMS_PATH\Acctmast,;
                   &g_AMS_PATH\Acctclnt,;
                   &g_AMS_PATH\Sureclnt
      set order to 2
      if netuse( '&g_cis_path'+'\Client.dbf',.f.,5)
         set index to &g_cis_path\Cliecd,;
                      &g_cis_path\Clienm
         if netuse( '&g_cis_path'+'\Industry.dbf',.f.,5)
            set index to &g_CIS_PATH\Industry
            if netuse('&g_AMS_PATH\FLAG',.f.,5)
// EVR      IF NETUSE('PARAMETR',.f.,5)
               if netuse( '&g_AMS_PATH\Amshist', .f., 5 )              && Account Payment history file
                  set index to &g_AMS_PATH\Amshist                     && set index on acctno
                  if netuse( '&g_AMS_PATH\AMSBACK\Amshist2', .f., 5 )              && Account Payment history file
                     set index to &g_AMS_PATH\AMSBACK\Amshist2                     && set index on acctno
                     if netuse ( '&g_AMS_PATH\Stathist',.f.,5 )
                        set index to &g_AMS_PATH\Stathist
                        //aga.26.04.2006.removed for delinquency reengineering
                        //if netuse( '&g_AMS_PATH\Paysked', .f., 5 )           && Account Payment schedule file
                        //   set index to &g_AMS_PATH\Paysked                  && set index on acctno
                           mretval := .t.
			//endif
                     endif
                  endif
               endif
// EVR         ENDIF
            endif
         endif
      endif
   endif

   return mretval
   
   static Function crea_dbf()
   ///*************************************
   do while .t.
	if !file('c:\amsr300b.dbf')
		if !file('c:\amsr300b.ntx')
			dbcreate ( 'c:\amsr300b',{ {'fullname' ,'c',50,00 },;
									   {'indcode'  ,'c',04,00 },;
                                       {'indname'  ,'c',40,00 },;
                                       {'noacct'   ,'n',12,00 },;
								       {'osbal'    ,'N',12,02 },;
									   {'principal','N',12,02 } ;
                                     };
                     )
				  netuse('c:\amsr300b',.t.,0)
				  amsr300b->(dbcreateindex('c:\amsr300b','osbal',{ || osbal } ))
		set index to c:\amsr300b
				  exit
		else
			ferase('c:\amsr300b.ntx')
		endif
	else
		ferase('c:\amsr300b.dbf')
      endif
	enddo
	
	  ///*******************************************
///chi051809
**************************
static function add2temp(mclntcode,mindcode,mnoaccts,mosbal,mprincipal)
**************************
if amsr300b->(netlock('A',0))
	replace amsr300b->fullname  with dispclntname(g_PAR_BRCH+mclntcode,40)
	replace amsr300b->indcode   with mindcode
	replace amsr300b->indname   with dispindustry(mindcode ) 
	replace amsr300b->noacct    with mnoaccts
	replace amsr300b->osbal     with mosbal
	replace amsr300b->principal with if(empty(mprincipal),0.00,mprincipal)
endif	
return  
	  /* aadd( mar,{ dispclntname(g_PAR_BRCH+mclntcode,40) ,;
                                                       mindcode                ,;
                                                       dispindustry(mindcode ) ,;
                                                       mnoaccts                ,;
                                                       mosbal          */         //,;
	  
*
*                         End of the program ( Amsr300b.prg )
*
*-----------