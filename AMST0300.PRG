/*
 ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³   program idúúú amst0300                                               ³
 ³   descriptionúú Accounts Review                                        ³
 ³   authorúúúúúúú renan s. evangelista                                   ³
 ³   dateúúúúúúúúú 9:20:am úú 07-24-96                                    ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³                             u p d a t e s                              ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³        who        ³       when        ³              why               ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³   ariel b. bulan  ³   june 11, 1999   ³  add refno validation to       ³
 ³                   ³                   ³  'g_gl_path\tranhead'          ³
 ³                   ³                   ³                                ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

////
#xtran getpaytype    ( <cnum> ) => if( <cnum> == '1'  , 'In Advance', 'In Arrears' )
#xtran gettermunit   ( <cnum> ) => if( <cnum> == '1'  , 'Day(s)', 'Month(s)' )

#include 'inkey.ch'
#include 'colf.ch'
////
#defi K_SPACEBAR   32
#defi microfeed    chr( 27 ) + 'J' + chr( 18 )

local mu:=savescreen( ,,, )
memvar  AX_LEVEL, gUSER_ID

set confirm on
setcursor(0)
setblink(.t.)
if !chkpass( procname(), AX_LEVEL, gUSER_ID )
   //NOTHING WILL HAPPEN
else
   begin sequence
      amsmopen0300()
      amsmMain0300()
   end sequence
   dbcloseall()
endif
setcursor(0)
restscreen( ,,,,mu )
__mrelease( '*', .t. )
return nil
/*-----------------------------*/
 Static Function amsmMain0300()
/*-----------------------------*/
local mu:=savescreen(,,,),npreval
private appflg:=.f.
if Acctmast->(bof()) .and. Acctmast->(Eof())
   error('Error:Account Master File is empty.')
   break
endif

scrntitle ( 'Account Review', gSYS_NAME, gUSER_ID, gTRANDATE )
dispbox   ( 3, 0, maxrow(), maxcol(), space( 9 ), 'n/n' )
optionmen ( '<Ins>-Add <F2>-Edit <F4>-Search <F5>-Status <Del>-Delete <Esc>-Exit<',23 )
setcolor  ( 'w/n' )
baks (3,2,22,77,,'w/n')
@ 11,2 say 'Æ'  color 'w/n'
@ 11,col() say repl('Í',74 )  color 'w/n'
Treview->(Dbgotop())
//Alcctmast->(dbseek(substr(Treview->Acctno,-5,5),.f.) )

if ( Treview->(eof()) .and. ;
     Treview->(bof()) ;
   ) .or.  !Acctmast->(dbseek(substr(Treview->Acctno,-5,5), .f.) )
   Acctmast-> ( dbgobottom() )
   Acctmast-> ( dbskip(+1) )
endif
scrn_rfrsh ( @npreval )

do while eval ( {|x| dispamsm0300     ( @npreval ) ,;
                     scrn_rfrsh       ( @npreval )   ,;
                     x := amst0300key ( npreval  ) ;
              } )
enddo

restscreen (,,,,mu)
return .f.

/*-------------------------------*/
 Static Function dispamsm0300(npreval)
/*-------------------------------*/
local nmrate,ntbrate,neffdate,napptrrate,mu:=savescreen( ,,, )
local napp_amrt:=0,ncomp_amrt:=0,napp_tr,ncomp_tr,nstatus,sw

if (Treview->(eof()) .and. Treview->(bof())) .or. empty(Treview->Acctno)
   appflg := .t.
   Acctmast->(dbgobottom())
   Acctmast->(dbskip())
else
   Acctmast->(Dbseek(substr(Treview->Acctno,-5,5), .f.))
   appflg:=.f.
endif
/*
*/
return nil

/*-------------------------------*/
 Static Function scrn_rfrsh(npreval)         //Refresh screen display
/*-------------------------------*/
local ax :=  0

@ 04,04    say '  Account Number : '                         color 'w/n'
@ 04,col() say ( ax := alltrim( Substr( Acctmast->oldno, 1,14 ) ) )+ ' '+ ;
               Substr( Acctmast->Acctname,1,31 ) + space( 14 - len(ax) ) color 'w+/n'
@ 06,04    say '   Maturity Date : '                         color 'w/n'
@ 06,col() say Acctmast->Matdate                             color 'w+/n'

@ 07,04    say '    Net Proceeds : '                         color 'w/n'
@ 07,col() say Trans( Acctmast->Principal,'999,999,999.99')  color 'w+/n'
@ 07,44    say ' Payment Type : '                            color 'w/n'
@ 07,col() say Acctmast->Paytype + ' ' +;
		 getpaytype( Acctmast->Paytype )             color 'w+/n'

@ 08,04    say '    Present Rate : '                         color 'w/n'
@ 08,col() say Trans(Acctmast->Truerate,'99.9999')           color 'w+/n'
@ 08,44    say ' Amortization : '                            color 'w/n'
@ 08,col() say Trans( Acctmast->Amort,'999,999,999.99' )     color 'w+/n'

@ 09,04    say '   Original Term : '                         color 'w/n'
@ 09,col() say Trans( Acctmast->Term,'999') + ' ' +;
		 gettermunit( Acctmast->Termunit )           color 'w+/n'
@ 09,44    say '  O/S Balance : '                            color 'w/n'
@ 09,col() say Trans( Acctmast->Osbal,'999,999,999.99')      color 'w+/n'

@ 10,04    say '  Remaining Term : '                         color 'w/n'
@ 10,col() say Trans( Acctmast->Remterm,'999') + ' ' +;
		 gettermunit( Acctmast->Termunit )           color 'w+/n'
@ 10,44    say 'Present Value : '                            color 'w/n'
@ 10,col() say Trans( (npreval:=agetpremval()),'999,999,999.99') color 'w+/n'
//////region below
@ 13,04    say '   MRR Increment : '                         color 'w/n'
@ 13,col() say Trans(Acctmast->Mrr_rate,'99.9999')           color 'w+/n'
@ 12,39    say 'Computed True Rate : '                       color 'w/n'
@ 12,col() say Trans(Treview->Comp_tr,'99.9999')             color 'w+/n'

@ 14,04    say '         New MRR : '                         color 'w/n'
@ 14,col() say Trans(Treview->New_mrr,'99.9999')             color 'w+/n'
@ 13,39    say '      Amortization : '                       color 'w/n'
@ 13,col() say Trans(Treview->Comp_amrt,'99,999,999.99')            color 'w+/n'

@ 15,04    say '                  ÄÄÄÄÄÄÄÄÄ'                 color 'w/n'

@ 14,39    say '            STATUS : '                       color 'w/n'
@ 14,col() say Trans(Treview->Status,'9') + ' '+ ;
			dispstat(Treview->Status)            color 'w+/n'

@ 16,04    say '                   '+tran(Treview->New_mrr+;
			       Acctmast->Mrr_rate,'99.9999') color 'w+/n'

@ 15,39    say '     No. of Months : '                       color 'w/n'
@ 15,60    say Trans( Treview->Monthno,'99')                 color 'w+/n'


@ 16,32    say 'EFFECTIVITY DATE < From > :'                       color 'w/n'
@ 16,60    say Dtoc(Treview->Effdate1)                        color 'w+/n'

@ 17,39    say '            < To > : '                       color 'w/n'
@ 17,60    say Dtoc(Treview->Effdate2 )                      color 'w+/n'

@ 18,39    say '         JV Number : '                       color 'w/n'
@ 18,60    say Treview->Refno                                color 'w+/n'

@ 18,04    say 'TBills Increment : '                         color 'w/n'
@ 18,col() say Trans(Acctmast->TB_rate,'99.9999')            color 'w+/n'

@ 19,04    say '      New TBills : '                         color 'w/n'
@ 19,col() say Trans(Treview->New_tb,'99.9999')              color 'w+/n'

@ 19,39    say '       Review Date : '                        color 'w/n'
@ 19,60    say dtoc(Treview->REvdate)                         color 'w+/n'

@ 20,04    say '                  ÄÄÄÄÄÄÄÄÄ'                 color 'w/n'

@ 20,39    say 'Approved True Rate : '                       color 'w/n'
@ 20,col() say Trans(Treview->App_tr,'99.9999')              color 'w+/n'

@ 21,04    say '                   '+tran(Treview->New_tb+;
			       Acctmast->Tb_rate,'99.9999')  color 'w+/n'
@ 21,39    say '      Amortization : '                       color  'w/n'
@ 21,col() say Trans(Treview->App_amrt,'99,999,999.99')      color 'w+/n'

return nil

/*----------------------------------*/
 Static Function amst0300key(npreval)
/*----------------------------------*/
 local nkey,nflg:=.t. ,recnum:=0,x
 if !appflg
    nkey:=  inkey(0)
 else
    nkey:=  22
 endif
 do case
   case nkey == K_PGUP .or. nkey == K_UP
	Treview->(dbskip( -1 ))
	if Treview->(bof())
	   waiton( 'Beginning of file!' )
	   waitoff()
	   Treview->(dbgotop())
	endif
	//Acctmast->(Dbseek(substr(Treview->Acctno,-5,5), .f.))
   case nkey == K_PGDN .or. nkey == K_DOWN
	Treview->(dbskip()) 
	if Treview->(eof())
	   waiton( 'End of file!' )
	   waitoff()
	   Treview->(dbskip( -1 ))
	endif
	//Acctmast->(Dbseek(substr(Treview->Acctno,-5,5), .f. ))
   case nkey == K_END              //recnum:= Treview->(lastrec())
	Treview->(dbgobottom())
	//Acctmast->(Dbseek(substr(Treview->Acctno,-5,5), .f. ))
   case nkey == K_HOME
	Treview->(dbgotop())
	//Acctmast->(Dbseek(substr(Treview->Acctno,-5,5), .f. ))
    case nkey == K_INS            //review another account
	 if agetamsm0300()
	    sw := .t.  //checktrev( Substr( Acctmast->Acctno,-5,5 ) ) //control the duplicate entry
	    if(sw, eval( {|| scrn_rfrsh(@npreval), getreview1('1',npreval,,) } ),nil )
	    nflg:=.t.
	 else
	    if (Treview->(eof()) .and. Treview->(bof())) //.or. empty( Treview->Acctno )
	       nflg:= .f.
	    endif
	 endif
    case nkey == K_F2            //review the current account
	 getreview1('2',npreval,,)
	 nflg:=.t.
    case nkey == K_F4            //search account to be review
	if Treview->(!eof()) .and. Treview->(!bof())
	   agetamsm0300(.f.)
	   //Acctmast->(Dbseek(substr(Treview->Acctno,-5,5), .f. ))
	endif
	nflg:=.t.
    case nkey == K_DEL          //delete current account in the Treview file
	 if treview->(!eof()) .and. Confirm('Delete this record<'+Trans(Treview->Acctno,'@R 99999-9999-99999')+'>?')
	    Treview->(Rlock())
	    Treview->(dbdelete())
	    Treview->(dbunlock())
	    Treview->(dbskip())
	    if Treview->(eof())
	       Treview->(dbskip(-1))
	    endif
	    //Acctmast->(Dbseek(substr(Treview->Acctno,-5,5), .f. ))
	 endif
	 nflg:=.t.
    case nkey == K_F5            //edit status of current account
	 getreview1('2',npreval,.t.)
	 nflg:=.t.
    case nkey == K_ESC          //exit module
	 if Confirm('Are you sure you want to Exit?')
	    nflg:=.f.
	 endif
 otherwise
   tone(800,1)
   nflg:=.t.
 endcase
 return nflg

/*-----------------------------*/
 Static Function agetamsm0300(sw)
/*-----------------------------*/
local naccnt:=spac(5),st:=setcursor(),tl:=savescreen(,,,),nselect:= alias(),nord:=(alias())->(indexord())
local nretval:=.t.,mord := Acctmast->( indexord() ),xname := Acctmast->Acctname, xdbf
local ax := Treview->( recno() )
sw:=if( sw == nil,.t.,sw )
//if sw
  dbselectarea('Acctmast')
  dbsetorder(2)
  xdbf := 'Acctmast' 
/*
else
  dbselectarea('Treview')
  dbsetorder(1)
  xdbf := 'Treview'
endif
*/

fshadow( 9,18,11,50,2,'w+/w' )
setcolor('n/w,w/n,,,w+/w')
setcursor(1)

@ 10,20 say 'Account Number  ' ;
        get naccnt  ;
        pict '@R 99999'  ;
        when eval({|| naccnt := substr( flook_online(.t.,'Acctmast',xname,'Master File',1,3,58,,1 ),-5,5), .f. })     &&flook(.t.,'Acctmast',xname,'Master File',1,3,58,1 ),-5,5), .f. })  //valid ncheckacct(naccnt,sw)
//        when eval({|| naccnt := substr( flook(.t.,'Acctmast',xname,'Master File',58,3,1,1 ),-5,5), .f. })  //valid ncheckacct(naccnt,sw)
setkey(K_ESC,if( sw, { || fescape('Abort?') },nil ) )
read

if lastkey() == K_ESC
   nretval := .f.
endif
if sw
   Acctmast->( dbsetorder( 1 ) )
   Acctmast->( dbseek( naccnt ) )
else
   Treview->(dbsetorder(1))
   if !Treview->(dbseek(naccnt))
      Treview->(dbgoto( ax ))
   endif
endif
setkey(K_ESC,NIL)
setcursor(st)
Acctmast->(dbsetorder( mord ))
restscreen(,,,,tl)
return nretval

/*--------------------------------*/
 Static Function ncheckacct(naccnt,sw)
/*--------------------------------*/
 local nretval:=.f.,nrec:=recno(),nset
 naccnt:=right('00000'+ alltrim(naccnt),5)
 if dbseek(naccnt,.f.)
    if sw
       nset := eval( {|| Facility->(dbseek(Acctmast->Fcltycode)), Facility->Setcode } )
       if alltrim(nset) == '1' .or. alltrim(nset) == '2'
	  nretval:=.t.
       else
	  error('Error:Record Not for review.')
       endif
    else
       nretval:=.t.
    endif
 else
    error('Error:Record Not found.')
    dbgoto(nrec)
 endif
 return nretval

/*--------------------------------*/
 Static Function checktrev(nacct)
/*--------------------------------*/
 local gf:=Savedbf(),nretval:=.t.
 dbselectarea('Treview')
 dbsetorder(1)
 //if !eof() .or. bof()
  if dbseek(nacct,.f.)
     nretval := .f.
  endif
 //endif
 restdbf(gf)
 return nretval

/*------------------------------------------------------------------*/
 Static Function initialval(nacct,nmrate,ntbrate,neffdate,napprate,nstatus,ncomp_tr,ncomp_amrt,napp_amrt,neffdate2,nmo,nrefno, nrevdate )
/*------------------------------------------------------------------*/
 local gf:=Savedbf()
 dbselectarea('Treview')
 dbsetorder(1)
 dbseek(nacct,.f.)
 nmrate     := Treview->New_mrr
 ntbrate    := Treview->New_tb
 neffdate   := Treview->Effdate1
 napprate   := Treview->App_tr
 nstatus    := Treview->Status
 ncomp_tr   := Treview->Comp_tr
 ncomp_amrt := Treview->Comp_amrt
 napp_amrt  := Treview->App_amrt
 neffdate2  := Treview->Effdate2
 nmo        := Treview->Monthno
 nrefno     := Treview->Refno
 nrevdate   := Treview->Revdate
 restdbf(gf)
 return nil

/*----------------------------*/
 Static Function dispcomp_tr( ncomp_amrt,ncomp_tr,nrow,ncol )
/*----------------------------*/
if ncomp_tr <> NIl
   @ 12,60 say trans(ncomp_tr,'99.9999')          color 'w+/n'
endif
@ nrow,ncol say trans(ncomp_amrt,'99,999,999.99') color 'w+/n'
return .t.

/*----------------------------*/
 Static Function dispmrate(rate2,nmrate,nrow,ncol)
/*----------------------------*/
@ nrow,ncol say tran( rate2 + nmrate,'99.9999') color 'w+/n'
return .t.

/*---------------------------------*/
 Static Function getreview1 ( nmode,npreval,nsearch )
 //
 // nwhat, nmrate, ntbrate, neffdate, napp_tr, ncomp_tr, nstatus, npreval, napp_amrt, ncomp_amrt )
 //
/*---------------------------------*/
local nmrate , ntbrate,neffdate,napptrrate,mu:=savescreen( ,,, ),neffdate2
local napp_amrt := 0,ncomp_amrt:=0,napp_tr,ncomp_tr,nstatus,sw,monno,nrefno
local mryt1     := 23,mryt2:=60,oldamrt,oldrt,olddte,nrevdate
local bf        := setcursor(),nretval
local mstatchoices := assign_elements( mstatchoices   , 5 )

nsearch   := if ( nsearch == Nil, .f., nsearch)
npreval   := if ( empty(npreval), Treview->PValue, npreval )
initialval ( Substr(Acctmast->Acctno,-5,5 ),@nmrate,@ntbrate,@neffdate,@napp_tr,@nstatus,@ncomp_tr,@ncomp_amrt,@napp_amrt,@neffdate2,@monno,@nrefno,@nrevdate )
neffdate2 := if( nmode == '1', Acctmast->Matdate, neffdate2 )
oldamrt   := nApp_amrt
olddte    := nEffdate
oldrt     := nApp_tr

setcolor  ( 'w/n,n/w,,,w+/n' )
setcursor ( 1 )

do while .t.

  @ 14, mryt1 get nmrate     ;
              pict '99.9999' ;
              when !nsearch  ;
              valid if ( empty(nmrate),;
                         eval( {|| Error('Error:Blank/Invalid Entry.'),.f.} ),;
                         .t. )  .and. ;
                         eval( { || dispmrate(Acctmast->Mrr_rate,nmrate,14,23),.t. } )

  @ 19, mryt1 get ntbrate    ;
              pict '99.9999' ;
              when !nsearch  ;
              valid if ( empty(ntbrate),;
                         eval( {|| error('Error:Blank/Invalid Entry.'),;
                                   .f. ;
                             } ),;
                         .t. ) .and. ;
                         eval ( {|| dispmrate(Acctmast->Tb_rate,ntbrate,21,23),;
                                    ncomp_amrt:= genamort ( (nmrate+Acctmast->Mrr_rate),;
                                                            (ntbrate+Acctmast->Tb_rate),;
                                                            @ncomp_tr,;
                                                            npreval,;
                                                            .t. ;
                                                          ),;
                                    dispcomp_tr(ncomp_amrt,ncomp_tr,13,60),;
                                   .t. ;
                              } )
  @ 14, mryt2 get nstatus  ;
              pict '@X'    ;
              when if ( lastkey() <> K_ESC,;
                        chkstat( mstatchoices, @nstatus,14,mryt2 ),;
                        .f. ;
                      )

  //@ 15, mryt2 get monno pict '99' when .f. .and. lastkey() <> K_ESC .and. nstatus == '1' valid lastkey() == K_UP .or. ( monno <> 0 ) //.and. chkrterm( Acctmast->Acctno, neffdate, monno ) )

  @ 16, mryt2 get neffdate pict '@D'  ;
              when lastkey() <> K_ESC .and. ;
              nstatus <> '2' valid if ( empty(neffdate),;
                                        eval( { || Error('Error:Blank/Invalid Entry.'),;
                                                  .f. ;
                                              };
                                            ),;
                                        .t. ;
                                      ) ;
                                      .and. ;
                                   chkimage( neffdate, Acctmast->Acctno, @monno ) // .and. chkrterm( Acctmast->Acctno, neffdate, monno )
  @ 17, mryt2 get neffdate2 pict '@D'  when .f. //.and. lastkey() <> K_ESC .and. nstatus <> '2' .and. eval({ || neffdate2 := chkeffdte(neffdate,monno), .t. } )  ;
                                                //valid if(empty(neffdate2),eval( {|| Error('Error:Blank/Invalid Entry.'),.f.} ),.t. )

  @ 18, mryt2 get nrefno          ;
              pict '99999999'     ;
              when lastkey() <> K_ESC .and. nstatus == '1' ;
              valid !empty( nrefno )  .and. ;
                    eval ({|| nrefno := right ('00000000'+alltrim(nrefno),8),.t. }) .and. ;
                    _chk_refno ( nrefno )

  @ 19, mryt2 get nrevdate  pict '@D' when lastkey() <> K_ESC .and. nstatus == '1' valid !empty( nrevdate )

  @ 20, mryt2 get napp_tr    ;
              pict '99.9999' ;
              when lastkey() <> K_ESC .and.  nstatus <> '2' ;
              valid if ( empty(napp_tr),;
                         eval ( {|| Error('Error:Blank/Invalid Entry.'),;
                                    .f. ;
                              } ),;
                         .t. ;
                       ) .and. ;
                       eval ( { || napp_amrt := genamort( nil,nil,napp_tr,npreval,.f.,neffdate,Acctmast->Acctno ),;
                                   dispcomp_tr(napp_amrt,,21,60),;
                                   .t. ;
                            } )

  @ 21, mryt2 get napp_amrt pict '99,999,999.99' when Lastkey() <> K_ESC .and.  nstatus <> '2' ;
                            valid eval( { || if( empty(napp_amrt),eval({|| error('Error:Invalid/Blank Entry.,'), .f. }), .t.) } )

  setkey(K_ESC,{ || fescape('Abort?') } )
  read
  setkey(K_ESC,nil)
  if nstatus == '2'
     napp_amrt:= oldamrt
     neffdate := olddte
     napp_tr  := oldrt
  endif
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
   dbselectarea('Treview')
   if( nmode=='1',netlock('A',0),netlock('R',0) )
   Treview->Acctno   := Acctmast->Acctno
   Treview->Pvalue   := npreval
   Treview->New_mrr  := nmrate
   Treview->New_tb   := nTbrate
   Treview->Comp_tr  := nComp_tr
   Treview->Comp_amrt:= nComp_amrt
   Treview->Status   := nstatus
   Treview->Effdate1 := neffdate
   Treview->App_tr   := napp_tr
   Treview->App_amrt := napp_amrt
   Treview->Revdate  := nRevdate
   Treview->Effdate2 := neffdate2
   Treview->Monthno  := monno
   Treview->Refno    := right('00000000'+alltrim(nrefno),8 )
   Treview->(dbunlock())
   Treview->(dbcommit())
elseif lastkey() == K_ESC
   if Treview->(eof()) .or. Treview->(bof())
      setcursor(bf)
      setcolor(mu)
      break
   endif
endif
setcursor(bf)
setcolor(mu)
return nretval

****************************************
*
*  ( added by ariel ( june 11, 1999 )
*
static function _chk_refno ( nrefno )
****************************************
local lretval := .t.,nord := Tranhead->(indexord()) ,nrec := Tranhead->(recno())
   Tranhead->(dbsetorder(1))
   if !Tranhead->(dbseek( nrefno))
      error ( 'JV number NOT FOUND,pls. perform GL Adjustment Module First,' )
      lretval := .f.
   else

      if !Adjaccts->(dbseek(nrefno+alltrim(Acctmast->acctno) ))
         error ( 'Account No '+substr(Acctmast->acctno,-5,5)+ ' NOT found in JVNo. '+alltrim(nrefno) )
         lretval := .f.
      endif

   endif
   Tranhead->(dbsetorder(nord))
   Tranhead->(dbgoto(nrec))
return lretval

/*--------------------------------------------*/
 Static Function chkrterm( nAcctno, neffdate, nmo )
/*--------------------------------------------*/
local nval:= 0

Payimage->(dbseek( nAcctno+dtos(neffdate) ))
Payimage->( dbeval({|| nval++ },,{|| Payimage->Acctno == nAcctno }))
if nmo > nval
   error('No of month/s exceed remaining term..!!!.')
   if !Confirm('Continue data entry.?',.f.,15,"  OK  ","Cancel" )
      return .f.
   endif
endif
return .t.

/*----------------------------------------------------*/
 Static Function chkimage(neffdate,nAcct, monno )
/*----------------------------------------------------*/
local nval:=ctod(''), nget := .t.,oldscr := savescreen( ,,, )
local lwrange, uprange, no_months:=0

if !Payimage->(dbseek( nAcct + dtos(neffdate),.t.))

   Error ( 'Error: Not a valid payment date' )
   uprange := if( Payimage->Acctno == nAcct,dtoc(Payimage->Paydate),'')
   Payimage->( dbskip(-1) )
   lwrange := if( Payimage->Acctno == nAcct,dtoc(Payimage->Paydate),'')
   if !empty( ctod(uprange) ) .or. !empty( ctod(lwrange) )
      error ( 'Available date: ' + lwrange + ' & ' + uprange + '.'  )
   endif
   nget := .f.

   /*
   if !Confirm('Continue anyway?',.f.,15,"  OK  ","Cancel" )
      nget := .f.
   endif
   */

else
   while Payimage->Acctno == nAcct
      no_months ++
      Payimage->(dbskip(+1))
   enddo
   monno := no_months
endif
restscreen(,,,,oldscr)
@ 15,60 say no_months pict '99' color 'w+/n'
return nget

/*---------------------------------*/
 Static Function chkeffdte(neffdate,nmo )
/*---------------------------------*/
local nyr,nmm
nyr := int( (  month( neffdate ) + ( nmo-1 ) )/12 ) + year( neffdate )
nmm := ( month( neffdate ) + (nmo-1) ) % 12
return ctod( str( nmm,2)+'/'+str(day(neffdate),2)+'/'+str( nyr,4 ) )


/*----------------------------------------------------------*/
 Static function genamort( nmrate,ntbrate,ncomp_tr,npreval, sw, nrefdate,xacctno )
/*----------------------------------------------------------*/

local mratemth:=0,mup:=0,mdown:=0,mamort:=0,mgdamount:=0
local nset,mrvamount:=0,mPvless:=0,mPv,new_preval,nterm := 0

if nrefdate == nil
   new_preval := npreval
else
   if Payimage->( dbseek( xacctno + dtos(nrefdate) ) )
      while Payimage->Acctno == xAcctno
         nterm ++
         Payimage->(dbskip())
      enddo
   endif
   new_preval := agetpremval( nterm )
endif

nterm := if( nterm < 1, Acctmast->Remterm, nterm )
nset:=eval( {|| Facility->( dbseek( Acctmast->Fcltycode )), Facility->Setcode } )

if sw
   ncomp_tr:=max( nmrate, ntbrate )
endif

mratemth := ( ncomp_tr/100 ) /12

if substr( Acctmast->Fcltycode,1,3) == '104' 
   if Acctmast->Paytype == '1'
      mUp := mratemth * ( ( 1 + mratemth ) ** ( nterm-1 ) )  // in advance
   else
      mUp := mratemth * ( ( 1 + mratemth ) ** ( nterm ) )    // in arreas
   endif
   mdown  := ( ( 1+ mratemth ) ** nterm ) -1
   mamort :=  intround(if( (mup == 0 .or. mdown== 0), 0.00, round( (new_preval * ( mUp/mdown)), 2 ) ))
elseif substr( Acctmast->Fcltycode,1,3) == '103'
//   mPv     := npreval - ( ( Acctmast->Gd/100 ) * npreval )
   mPv     := new_preval
   mPvless := 0
   if Acctmast->Gd <> Acctmast->Rv
      mgdamount := new_preval * (Acctmast->Gd/100)
      mRvamount := new_preval * (Acctmast->Rv/100)
      mPvless   := ( Abs(mgdamount-mRvamount )) * ( (1 + mRatemth ) ** (-nterm ) )
   endif
   mPv := if(Acctmast->Gd > Acctmast->Rv, mPv+mPvless, mPv-mPvless)
   if Acctmast->Paytype == '1'
      mUp := mratemth * ( ( 1 + mratemth ) ** ( nterm - 1  ) )  //in advance
   else
      mUp := mratemth * ( ( 1 + mratemth ) ** ( nterm ) )     //in arrears
   endif
   mdown  := ( ( 1 + mratemth ) ** nterm ) -1
   mamort := intround(if( (mup == 0 .or. mdown== 0), 0.00, round( mPv * ( mUp/mDown),2 ) ))
endif
altd()
return mamort

//for comparisson only
/*-----------------------------*/
  Static Function agetpremval( mterm )
/*-----------------------------*/

 local mratemo,mup,mdown,mpvalue:=0

 mterm := if( mterm == nil .or. mterm < 1, Acctmast->Remterm, mterm )
 //altd()
 ////this is for comparisson

 mratemo := ( Acctmast->Truerate/100 )/ 12
 mup     := mratemo * ( ( 1 + mratemo) ** (mterm-1))
 mdown   := (( 1 +  mratemo) ** mterm) - 1
 mpvalue := if( (Acctmast->Amort == 0 .or. mup == 0 .or. mdown == 0 ), 0,;
                Acctmast->Amort/ (mup/mdown) )
 return mpvalue

/*-----------------------------*/
 Static Function amsmOpen0300()
/*-----------------------------*/
if !netuse('Acctmast',.f.,5)
   break
else
   ordlistclear ()
   ordlistadd   ( 'Acctsub2' )
   ordlistadd   ( 'Acctacno' )       //open index file for Acctmast
   Acctmast->   ( dbsetorder(1) )
endif

if !netuse('Payimage',.f.,5 )
   break
else
   ordlistclear()
   dbsetindex('Payimage')
endif

if !netuse('Treview',.f.,5)
   break
else
   ordlistclear()
   ordlistadd('Treview')       //open index file Treview
   ordlistadd('Trevref')
   Treview->( dbsetorder(1) )
endif


if !netuse( '&g_Gl_Path\Adjaccts',.f.,5)   //Adjustment File
   break
else
******   set index to Adjacctsr       //Trnumber + Accntno_1
   set index to '&g_Gl_Path\Adjacctsr'

endif


if !netuse('Facility',.f.,5)
   break
else
   ordlistclear()
   ordlistadd('Fcltycd')       //open index file Facility
   //ordlistadd('Treview2')
endif

   if !netuse( '&g_Gl_Path\Tranhead',.f.,5)   //JV, CV Detail File
      return .f.
   endif
//   set index to 'Tranhead,Trancode,Tranbank,Trandate
   set index to '&g_Gl_Path\Tranhead', '&g_Gl_Path\Trancode',;
                '&g_Gl_Path\Tranbank','&g_Gl_Path\Trandate'


return nil
/*--------------------------------------------*/
 Function optionmen( n1,nrow )
/*--------------------------------------------*/
local x,st_:={},n2:=n1,tl,ppy:={},ncol
ncol := 40-len(n1)/2
@ nrow,00 say repl(' ',79) color 'w/n'
while len(n2) > 1
   x:=n2
   if (tl := at('>',n2 )) <> 0
      aadd(st_, substr(n2,1,tl) )
      n2:=substr( n2,tl+1, len(n2) )
      aadd(ppy,substr( n2,1,at('<',n2)-1 ) )
      n2:=substr( n2,at('<',n2),len(n2) )
   endif
   if n2 == x .or. empty(n2)
      //if(!empty(n2),aadd(ppy, n2 ),nil )
      exit
   endif
enddo
if !empty(st_)
   //x:=len(st_)
   for x:= 1 to len(st_)
       @ nrow,ncol  say st_[x]   color 'w+/n'
       @ nrow,col() say if(x <= len(ppy), ppy[x],'') color 'w/n'
       ncol := col()
   next x
endif
return nil

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function chkstat(mstatchoices, mstat, mROW, mCOL)
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   mstat := gen_achoice ( mstatchoices, val ( mstat ), 'Status',  14, 62, 17, 78, 'W/GR+,W/N,,,W/GR+')
   @ mROW, mCOL + len( mstat ) + 1 say upper( dispstat(mstat) ) color 'w+/n'
   return .f.

///////
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
10  ÆÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍµ
11  ³                                                                          ³
12  ³    MRR Increment : 99.9999         Computed True Rate : 99.9999          ³
13  ³          NeW MRR : 99.9999               Amortization : 99,999,999.99    ³
14  ³                   ÄÄÄÄÄÄÄÄÄ                                              ³
15  ³                    99.9999         Approved True Rate : 99.9999          ³
16  ³                                          Amortization : 99,999,999.99    ³
17  ³ TBills Increment : 99.9999                                               ³
18  ³       New TBills : 99.9999                                               ³
19  ³                   ÄÄÄÄÄÄÄÄÄ                    Status : 9 XXXXXXXXXXXX   ³
20  ³                    99.9999           EFFECTIVITY DATE : 99/99/9999       ³
21  ³                                                                          ³
22  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
