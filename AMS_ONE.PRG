#INCLUDE "COLF.CH"
#INCLUDE "INKEY.CH"
#INCLUDE "DBSTRUCT.CH"

*-------------------------------------------------------------------------------
*FUNCTION _RIGHTS ( cBRCODE, cAOCODE )
*local lretval := .f.,nrec := aoaccess->(recno())
*
*if aoaccess->(dbseek(cBRCODE+left(alltrim(g_USER_ID)+'   ',6)+cAOCODE ))
*   lretval := .t.
*endif
*
*aoaccess->(dbgoto(nrec))
*
*RETURN LRETVAL
*-------------------------------------------------------------------------------
*FUNCTION CHKRATETYPE( mRATECHOICES, mRATETYPE, xROW, xCOL, lSEL )
*
*IF lSEL
*   mRATETYPE := gen_achoice( mRATECHOICES, val( mRATETYPE ), 'Rate Type', 15, 56, 18, 77, 'W/GR+,W/N,,,W/GR+' )
*ENDIF
*
*@ xrow, xcol say upper( if( mRATETYPE == '1', 'Fixed   ', 'Floating' ) ) color 'gr+/gr'
*
*RETURN .F.
*-------------------------------------------------------------------------------
FUNCTION DISPAONAME( mAOCODE )

Ao->(dbseek(mAOCODE))

return Ao->AONAME
*-------------------------------------------------------------------------------
FUNCTION DISP_DEALER(mDLRCODE, mROW)

DEALER-> ( dbseek ( g_PAR_BRCH+mDLRCODE  ) )

return DEALER->DLRNAME
*-------------------------------------------------------------------------------
FUNCTION CHKCREDITTYPE(mCREDTYPE, mROW, mCOL, X2, Y2)
local mscreen := savescreen( ,,, )

center ( 24, 'w+/n', '® Select Credit Type ¯' )
lb_lkup( 'Credtype' ,1,1,@mcredtype, 2 , 1, 10, X2, Y2, 75, 'W/GR+,W/N,,,W/GR+')
restscreen( ,,,, mscreen )
@ mROW, mCOL say upper( left( disp_cred_type(mcredtype), 20 ) ) color 'gr+/b'

return .f.
*-------------------------------------------------------------------------------
FUNCTION DISPCLNTNAME( mCLNTCODE, nLEN )

IF nLEN == NIL .OR. EMPTY(nLEN)
   nLEN := 50
ENDIF

return eval ({ |x,y| x:= savedbf ( x ),;
                     Client->( dbsetorder(1) ),;
                     Client->( dbseek(mclntcode) ),;
                     y:= left( Client->FULLNAME, nLEN ),;
                     restdbf( x ),;
                     y })
*-------------------------------------------------------------------------------
FUNCTION DISP_MODE_PAY(mPAYMODE)
return if( mPAYMODE $ '123' ,if( mPAYMODE == '1', 'Post-dated checks',if( mPAYMODE == '2','Cash             ','Automatic Debit  ' ) ), space ( 17 ) )
*-------------------------------------------------------------------------------
FUNCTION DISPDLRNAME( mDLRCODE )
   local mdbf := savedbf( mdbf )
   Dealer->( dbsetorder(1) )
   Dealer->( dbseek(mdlrcode) )
   restdbf ( mdbf )
return left( Dealer->DLRNAME, 15 )
*-------------------------------------------------------------------------------
FUNCTION DISPALIAS( mFCLTYCODE, nLEN, cSEL )
LOCAL cRETVAL := SPACE(0)

IF cSEL == NIL .OR. EMPTY(cSEL)
   cSEL := 'A'
ELSE
   cSEL := UPPER(cSEL)
ENDIF

IF nLEN == NIL .OR. EMPTY(nLEN)
   nLEN := 5
ENDIF

Facility->( dbseek ( mFCLTYCODE ) )

IF UPPER(cSEL) == 'N'
   cRETVAL := Facility->FCLTYNAME
ELSE
   cRETVAL := Facility->FCLTYALIAS
ENDIF

RETURN LEFT( cRETVAL, nLEN )
*-------------------------------------------------------------------------------
FUNCTION DISPAOPOST(mAOCODE)

AO->(DBSEEK(mAOCODE))

RETURN ALLTRIM(AO->AOPOST)
*---------------------------------------------------------------------------------
FUNCTION DISPINDUSTRY(mINDCODE)
return eval ({|x,y| x := savedbf( x ), Industry->(dbseek( mindcode )),;
                    y:=Industry->INDNAME, restdbf( x ), y })
*---------------------------------------------------------------------------------
FUNCTION SUB_LIMIT()
memvar momnibus
return eval ({|| devpos ( prow(), pcol() ),;
                 devout ( if ( momnibus , '     (SUB-LIMIT)','') );
            })
*---------------------------------------------------------------------------------
FUNCTION DISP_PAYTYPE( mPAYTYPE )

return if ( mpaytype $ '12', if( mpaytype == '1',' In Advance',' In Arrears'),'' )
*---------------------------------------------------------------------------------
FUNCTION GETINTAMT( nINTAMT, nPRNAMT, nPAYDATE, xPRATE, nPRVDTE )
local nretval:=0,xblk:={ || Paysked->Lastpay <= nPrvdte }

nretval := ( ( nIntamt + nPrnamt ) * (xprate/30)) * ( nPrvdte - nPaydate )

RETURN nRETVAL
*---------------------------------------------------------------------------------
FUNCTION CHKCLIENT( xCLIENT, SW )
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

RETURN .T.
*---------------------------------------------------------------------------------
FUNCTION F10ESCAPE(MESS1)
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
*---------------------------------------------------------------------------------
FUNCTION ABRUPT()
setkey( K_F10, NIL )
clear gets
if Confirm('Cancel the whole printing process?')
   break
endif
return nil
*---------------------------------------------------------------------------------
FUNCTION SELECT_MONTH ( mMONTH, X1, Y1, X2, Y2 )
return eval( { | x, y, z | x := setcolor(), y := savescreen( ,,, ),;
                          fshadow( X1, Y1, X2, Y2, 2, 'w/gr' ),;
                          devpos( X1+1, Y1+3 ), devout( 'Month', 'bg+/gr' ),;
                          devpos( X1+2, Y1 ) , devout( 'ÃÄÄÄÄÄÄÄÄÄ´', 'w/gr' ),;
                          setcolor( 'w/gr, w+/n,,, n/gr' ),;
                          z := achoice( X1+3, Y1+1, X2-1, Y2-1,;
                               { 'January', 'February', 'March', 'April',;
                                 'May', 'June', 'July', 'August', 'September',;
                                 'October', 'November', 'December' },,, mmonth ),;
                          setcolor( x ), restscreen( ,,,, y ), mmonth := if( z == 0, mmonth, z ), .f. } )
*---------------------------------------------------------------------------------
FUNCTION _GET_RATE_TYPE(cACCTNO)
local nntx    := Acctmast->(indexord()),nrecno := Acctmast->(recno())
local cretval := space (5)
Acctmast->(dbsetorder(1))              // account number
Acctmast->(dbseek(cacctno))

do case
   case Acctmast->revfreq = '1'
        cretval := 'QUARTERLY'
   case Acctmast->revfreq = '2'
        cretval := 'SEMI-ANNUAL'
   case Acctmast->revfreq = '3'
        cretval := 'ANNUAL'
endcase

Acctmast->(dbsetorder(nntx))
Acctmast->(dbgoto(nrecno))
return cretval
*---------------------------------------------------------------------------------
FUNCTION _GET_UNIT(cACCTNO)
local nntx := Acctmast->(indexord()),nrecno := Acctmast->(recno())
local cunit
Acctmast->(dbsetorder(1))              // account number
Acctmast->(dbseek(cacctno))
cunit := Acctmast->unit
Acctmast->(dbsetorder(nntx))
Acctmast->(dbgoto(nrecno))
return cunit
*---------------------------------------------------------------------------------
FUNCTION PRNTERMUNIT ( mTERMUNIT )
   local mretval

   do case
      case alltrim( mtermunit ) == '1'
         mretval := 'DAYS'
      case alltrim( mtermunit ) == '2'
         mretval := 'MONTHS'
      otherwise
         mretval := 'YEARS'
   endcase
return mretval
*---------------------------------------------------------------------------------
FUNCTION PRNAO( mAOCODE )
   Ao -> ( dbseek ( maocode ) )
return Ao -> AONAME
*---------------------------------------------------------------------------------
FUNCTION DDMMMYYYY( mDATE )
   local md,mm,my

   md := right( '0'+ ltrim(trans(day(mdate),'99')),2 )
   mm := left( cmonth(mdate),3   )
   my := trans( year(mdate),'9999')
return ( md + '-' + mm + '-' + my )
*---------------------------------------------------------------------------------
FUNCTION CHKMEND( mSTART, mEND )
   local mretval := .f.
   if !empty ( mend )
      if mend < mstart
         error ( 'End Date is "<" Beginning Date.' )
      else
         mretval := .t.
      endif
   endif
return mretval
*---------------------------------------------------------------------------------
FUNCTION DISPBAR( )
   memvar mstart,mend

   set device to screen
   dispbegin()
   fshadow ( 14, 10, 20, 66, 2, 'w/gr' )
   @ 15, 11 say ' Report Date  ' color 'bg+/gr'
   @ 16, 11 say 'Acct Officer  ' color 'bg+/gr'
   @ 17, 11 say '   Acct Name  ' color 'bg+/gr'
   @ 18, 11 say '              ' color 'bg+/gr'
   @ 19, 11 say '              ' color 'bg+/gr'
   @ 15, 26 say dtoc ( mstart ) + '-' + dtoc ( mend ) color 'w+/gr'
   dispend()
   set device to printer
return nil
*---------------------------------------------------------------------------------
FUNCTION DISPREC()
   set device to screen
   dispbegin ()
   scroll    ( 17,26,19,65,1 )
   @ 19,26 say left( Acctmast -> ACCTNAME, 40 ) color 'w+/gr'
   dispend   ()
   set device to printer
return nil
*---------------------------------------------------------------------------------
FUNCTION CHKPDCDATE(dDATE)
   local mu:=savedbf(), re:=setcursor(), bf:=savescreen(,,,), gf:=setcolor()
   dbselectarea('pdc_dtls')
   dbsetorder(1)

   if !dbseek(ddate)
      error('pdc deposit date not found.')
      return .f.
   else
      return .t.
   endif

   restdbf(mu)
   restscreen(,,,,bf)
   setcursor(re)
   setcolor(gf)
return .t.
*---------------------------------------------------------------------------------
FUNCTION DISPCHKTYPE( mCHKTYPE )
   local mLIST := space (12 ) +'Metro Manila'+'Regional    '+'Out-Of-Town '
return substr ( mLIST, val ( mCHKTYPE ) * 12 + 1, 12 )
*---------------------------------------------------------------------------------
FUNCTION DISPRECEIVER( mRECEIVER )
return eval ({|x,y| x := savedbf (x) ,;
                    Personel->( dbseek ( mRECEIVER ) ) ,;
                    y := Personel ->FULLNAME           ,;
                    restdbf (x)      ,;
                    y;
            })
*---------------------------------------------------------------------------------
FUNCTION MYFUNC ( STATUS, CURR_ELEM, CURR_ROW )
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
*---------------------------------------------------------------------------------
FUNCTION CHKACCT(xACCTNO)
local mu:=savedbf(),re:=setcursor(),bf:=savescreen(,,,),gf:=setcolor()
local tmp_:={},xclnt

dbselectarea('Acctmast')
dbsetorder(1)
xclnt := if(dbseek( xacctno ),ACCTMAST->BRCODE+Acctmast->Clntcode,spac(14))
dbsetorder(2)
dbeval( {|| if(Acctmast->Paymode == '2',aadd( tmp_,{ ACCTMAST->BRCODE+Acctmast->Acctno,Acctmast->Oldno,Acctmast->Term,Acctmast->Unit } ),nil) },,;
{|| ACCTMAST->BRCODE+Acctmast->Clntcode == xclnt .and. !eof() } )
DBSKIP(-1)
restdbf(mu);restscreen(,,,,bf);setcursor(re);setcolor(gf)
return tmp_
*---------------------------------------------------------------------------------
FUNCTION CHKCLNT( xCLNT )
local mu:=savedbf(),re:=setcursor(),bf:=savescreen(,,,),gf:=setcolor()
dbselectarea( 'Client' )
dbsetorder( 1 )
dbseek( xclnt )
altd()
return (CLIENT->BRCODE+Client->Clntcode)
*---------------------------------------------------------------------------------
FUNCTION GETDATES()
   memvar mstart,mend

   fshadow( 11, 30, 14, 48, 2 , 'gr+/g' )
   setcolor( 'w/g, w+/n,,, w+/g' )
   @ 11, 31 say 'Report Date' color 'bg+/g'
   @ 12, 31 say 'From ' get mstart pict '@D' valid !empty ( mstart )
   @ 13, 31 say '  To ' get mend   pict '@D' valid chkmend( mstart, mend )
   setcursor ( 3 )
   read
   setcursor ( 0 )
return lastkey() != K_ESC
*---------------------------------------------------------------------------------
FUNCTION SAVEDBF( mARNAME )

return( { select(), indexord(), recno() } )
*---------------------------------------------------------------------------------
FUNCTION RESTDBF( mARNAME )

IF !EMPTY(mARNAME[1]) .AND. mARNAME[1] > 0
   dbselectarea ( mARNAME [1] )
   dbsetorder   ( mARNAME [2] )
   dbgoto       ( mARNAME [3] )
ENDIF
return(  nil )
*---------------------------------------------------------------------------------
FUNCTION UNIQFILE( cFILEEXT )
  local mfiname, mrandnum


IF EMPTY(cFILEEXT) .OR. cFILEEXT == NIL
   cFILEEXT := 'DBF'
ENDIF

  do while .t.

    mrandnum := substr(time(),1,2) + substr(time(),4,2) + substr(time(),7,2)

    mfiname  := 'TF' + mrandnum

    if file(mfiname + '.' + cFileExt)          // test if text file exist
      loop
    else
      exit
    endif

  enddo

return mfiname
*---------------------------------------------------------------------------------
FUNCTION GETSETCD ( mFCLTYCODE )
   Facility->(dbseek(mfcltycode))
return Facility->SETCODE
*---------------------------------------------------------------------------------
FUNCTION TRANTYPER(xFCL,nCA)
local gf:=savedbf(),ctype:='',bf:=Cadetail->(indexord())
dbselectarea('Cadetail')
Cadetail->(dbsetorder(2))
if Cadetail->( dbseek(Caheader->brcode+nca + xfcl) )
   ctype:=Cadetail->Trantype
endif
restdbf(gf)
Cadetail->(dbsetorder(bf))
return ctype
*---------------------------------------------------------------------------------
FUNCTION CHKGRPCODE()
local arr_ := {}, mdbf_ := savedbf(), mmem:= '000'
local mindx := Grpmembr->( indexord() ),xCode:=Caheader->Clntcode, _seek := .t., cbrcode
//local OLSBRCD := SPACE (3)
/**
dbselectar( 'Grpmembr' )
Grpmembr->( ordsetfocus( 3 ) )

If Grpmembr->( dbseek( Caheader->brcode+Caheader->clntcode ) )
   OLSBRCD := Grpmembr->brcode
endif

mmem := Grpmembr->grupcode
Grpmembr->( ordsetfocus( 1 ) )

Grpmembr->( dbseek( OLSBRCD+mmem ) )
Grpmembr->( dbeval( { || if(Grpmembr->BRCODE2+Grpmembr->Clntcode # g_PAR_BRCH+xCode,aadd( arr_, Grpmembr->brcode2+Grpmembr->clntcode ),.f.) },,;
                    { || mmem == Grpmembr->grupcode .and. Grpmembr->brcode == OLSBRCD } ) )  
					
Grpmembr->( ordsetfocus( mindx ) )
**/

dbselectar( 'Grpmembr' )

Grpmembr->( ordsetfocus( 2 ) )

//if Grpmembr->( dbseek( Caheader->brcode+Caheader->clntcode ) )
//   OLSBRCD := Caheader->brcode
//else
	Grpmembr->( ordsetfocus( 3 ) )
	if Grpmembr->( dbseek( Caheader->brcode+Caheader->clntcode ) )
	   OLSBRCD := GRPMEMBR->BRCODE
    else
	   OLSBRCD := cbrcode
	endif
//endif

mmem := Grpmembr->grupcode
Grpmembr->( ordsetfocus( 1 ) )
IF OLSBRCD <> NIL
   Grpmembr->( dbseek( OLSBRCD+mmem ) )
   Grpmembr->( dbeval( { || if(Grpmembr->Clntcode # xCode ,aadd( arr_, Grpmembr->brcode2+Grpmembr->clntcode ),.f.) },,;
   					   { || mmem == Grpmembr->grupcode .and. Grpmembr->brcode == OLSBRCD } ) )    && RED 020805 REPLACED 'OLCAHEAD->brcode WITH g_PAR_BRCH
   Grpmembr->( ordsetfocus( mindx ) )
ENDIF

/*******
dbselectar( 'Grpmembr' )
Grpmembr->( ordsetfocus( 2 ) )
if Grpmembr->( dbseek( Caheader->brcode+Caheader->clntcode ) )
	   do while Caheader->brcode+Caheader->clntcode == GRPMEMBR->BRCODE+GRPMEMBR->CLNTCODE
			if Caheader->brcode == GRPMEMBR->BRCODE2
			   mmem := Grpmembr->grupcode
				exit
			else
				GRPMEMBR->(dbskip(1))
			endif
		enddo  
else
	Grpmembr->( ordsetfocus( 3 ) )
	if Grpmembr->( dbseek( Caheader->brcode+Caheader->clntcode ) )
		mmem := Grpmembr->grupcode
		_seek := .f.
		cbrcode := GRPMEMBR->BRCODE
	endif
endif		

Grpmembr->( ordsetfocus( 1 ) )
if _seek
	Grpmembr->( dbseek( Caheader->brcode+mmem ) )
else
	Grpmembr->( dbseek( cbrcode+mmem ) )
endif
	

Grpmembr->( dbeval( { || if(Grpmembr->Clntcode != xCode,aadd( arr_, if(Grpmembr->brcode != Grpmembr->brcode2,Grpmembr->brcode2+Grpmembr->clntcode,Grpmembr->brcode+Grpmembr->clntcode) ),.f.) },,; //if(Grpmembr->brcode != Grpmembr->brcode2,Grpmembr->brcode2+Grpmembr->clntcode,Grpmembr->brcode+Grpmembr->clntcode)
                    { || mmem == Grpmembr->grupcode .and. Grpmembr->brcode == if(_seek,Caheader->brcode,cbrcode) } ) )    && RED 020805 REPLACED 'Caheader->brcode WITH g_PAR_BRCH
Grpmembr->( ordsetfocus( mindx ) )
*******/
restdbf( mdbf_ )
return( arr_ )
/*---------------------------------------------------------------------------------
FUNCTION FSTATUDF( nMODE, nE1, nROW )
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
*---------------------------------------------------------------------------------*/
FUNCTION CHKWHAT( mARRAY_, mVARIABLE, mROW, mCOL, mTITLE )
mvariable := gen_achoice( marray_, val( mvariable ), mtitle )
@ mrow, mcol say subs( marray_[ val( mvariable ) ], at( '=',;
                       marray_[ val( mvariable ) ] ) + 2 ) color 'gr+/gr'
return( .f. )
*---------------------------------------------------------------------------------
FUNCTION GETHOLIDATE ( mMATDATE )
local mmonth := right( '0'+alltrim (str(month(mmatdate),2,0)), 2)
local mdays  := right( '0'+alltrim (str(day  (mmatdate),2,0)), 2)
return mmonth+'/'+mdays
*---------------------------------------------------------------------------------
FUNCTION DISPDOCNAME ( mDOCCODE )
Doccodes-> ( dbseek ( mDOCCODE ) )
return Doccodes->DOCNAME
*---------------------------------------------------------------------------------
FUNCTION DISPINSURED( mINSURED )
return upper( if ( minsured,'Yes   ','Waived' ) )
*---------------------------------------------------------------------------------
FUNCTION DISP_ORIX_UNIT ( mUNITCODE )
Orixunit -> ( dbseek( munitcode ) )
return Orixunit -> UNITNAME
*---------------------------------------------------------------------------------
FUNCTION DISP_PAYMENT_FREQ(mPAYFREQ)
local mLIST := space ( 11 ) + 'Monthly    Bi-monthly Quarterly  Semi-annualAnnual     Lumpsum    Irregular  '
return substr ( mLIST, val ( mPAYFREQ ) * 11 + 1, 11 )
*---------------------------------------------------------------------------------
FUNCTION GETCLNME( nCODE )
local mu:=stackin()

dbselectarea('Client')
Client ->( dbsetorder( 1 ) )
Client ->( dbseek ( ncode ) )

stackout( mu )
return substr( Client->shrtname, 1, 17 )
*---------------------------------------------------------------------------------
FUNCTION SEEKGRUP()
local arr_ := {}, mdbf_ := stackin(), mgrupcode:='000', _seek := .t., cbrcode

dbselectar( 'Grpmembr' )

IF Grpmembr->( dbseek( OTICKET->BRCODE+OTICKET->clntcode ) )
	   do while OTICKET->BRCODE+OTICKET->clntcode == GRPMEMBR->BRCODE+GRPMEMBR->CLNTCODE
			if OTICKET->BRCODE == GRPMEMBR->BRCODE2
			   mgrupcode := Grpmembr->grupcode
				exit
			else
				GRPMEMBR->(dbskip(1))
			endif
		enddo  
else
	Grpmembr->( ordsetfocus( 3 ) )
	if Grpmembr->( dbseek( OTICKET->BRCODE+OTICKET->clntcode ) )
		mgrupcode := Grpmembr->grupcode
		_seek := .f.
		cbrcode := GRPMEMBR->BRCODE
	endif
endif		


   //mgrupcode := GRPMEMBR->BRCODE+Grpmembr->grupcode
   Grpmembr->( ordsetfocus( 1 ) )
   //Grpmembr->( dbseek( mgrupcode ) )
if _seek
	Grpmembr->( dbseek( OTICKET->BRCODE+mgrupcode ) )
else
	Grpmembr->( dbseek( cbrcode+mgrupcode ) )
endif

   Grpmembr->( dbeval( { || if( if(Grpmembr->brcode != Grpmembr->brcode2,Grpmembr->brcode2,Grpmembr->brcode)+Grpmembr->clntcode == OTICKET->BRCODE+OTICKET->clntcode,;
                         nil, aadd( arr_, if(Grpmembr->brcode != Grpmembr->brcode2,Grpmembr->brcode2+Grpmembr->clntcode,Grpmembr->brcode+Grpmembr->clntcode) ) ) },,; //GRPMEMBR->BRCODE+Grpmembr->clntcode
                    { || GRPMEMBR->BRCODE+Grpmembr->grupcode == if(_seek,OTICKET->BRCODE,cbrcode)+mgrupcode } ) )
   Grpmembr->( ordsetfocus( 2 ) )
   
stackout( mdbf_ )
return( arr_ )
*---------------------------------------------------------------------------------
FUNCTION CHKDEPDATE ( mCHKDATE, mDEPDATE )
local mRETVAL := .t.
if mCHKDATE > mDEPDATE
   ERROR('Check Date must be "<" to Deposit Date!'); mRETVAL := .f.
endif
return mRETVAL
*---------------------------------------------------------------------------------
FUNCTION CHECK_CODE( mCODE )
local mretval := .t., mdbf := savedbf ( mdbf )

if( (alias())->(dbseek(mcode)) .and. !empty ( mcode ) .and. lastkey() != K_ESC, eval ({|| error ( 'Duplicate Code Found!' ) , mretval := .f. }), nil )
if( empty ( mcode ), mretval := .f., nil  )
restdbf   ( mdbf  )
return mretval
*---------------------------------------------------------------------------------
FUNCTION MESS_TONES( MESS )
    tones ()
return confirm ( mmess )
*---------------------------------------------------------------------------------
Function TONES ()
   tone( 1600, 1 ) ; tone ( 800, 1)
return nil
*---------------------------------------------------------------------------------
FUNCTION FPADXXXX( MCD, nLEN )
local log := !.f.

IF nLEN == NIL .OR. EMPTY(nLEN)
   nLEN := 5
ENDIF

if !dbseek( mcd := padr( mcd, nLEN ) )
   log := !.t.
   error( 'No such Record!' )
endif
return( log )
*---------------------------------------------------------------------------------
FUNCTION CHECKCLNT(xCLNTCODE)
local mu:=savedbf(),re:=setcursor(),bf:=savescreen(,,,),gf:=setcolor()
local nval
dbselectarea('Acctmast')
dbsetorder(1)
if dbseek( xclntcode )
   nval := .t.
else
   error('No account found for this client.')
   nval := .f.
endif
restdbf(mu);restscreen(,,,,bf);setcursor(re);setcolor(gf)
return nval
*---------------------------------------------------------------------------------
FUNCTION _COMPANY_ACCOUNTS(xFILE)
   local cretval := 3        // 1-metro,2-pbc,3-orix

   if nchoice == 0
      cretval := 0
   else
      do case
*         case substr(alltrim(Acctmast->acctno),1,4) == '9907'    // METRO
         CASE SUBSTR(ALLTRIM((xFILE)->ACCTNO),1,4) == '9907'
            cretval := 1

*         case substr(alltrim(Acctmast->acctno),1,4) == '9908'    // PBC
         CASE SUBSTR(ALLTRIM((xFILE)->ACCTNO),1,4) == '9908'
            cretval := 2

      endcase
   endif

return cretval
*---------------------------------------------------------------------------------
FUNCTION _EMPLOYEE_LOANS(cFCLTYCODE)
LOCAL lRETVAL := .F.

IF cFCLTYCODE == '10451' .OR. cFCLTYCODE == '10452' .OR. ;
   cFCLTYCODE == '10453' .OR. cFCLTYCODE == '10454'
   LRETVAL := .T.
ENDIF

RETURN lRETVAL
*---------------------------------------------------------------------------------
FUNCTION GETCLIENT ()
   Client -> ( dbseek ( Acctmast -> CLNTCODE ) )
return Client -> SHRTNAME
*---------------------------------------------------------------------------------
FUNCTION PRINTCLNT()
return Client->(dbseek(CAHEADER->BRCODE+Caheader->CLNTCODE)), Client->FULLNAME
*---------------------------------------------------------------------------------
FUNCTION PRINTDATE()
   memvar mtrandate
return alltrim(cmonth(mtrandate))+' '+ltrim(trans(day(mtrandate),'99'))+', '+ltrim(trans(year(mtrandate),'9999'))
*---------------------------------------------------------------------------------
FUNCTION GETPERCENT( mDIVIDEND,mDIVISOR )
   local mretval := 0
   mretval := ( mdividend/ if(mdivisor==0,1,mdivisor) ) * 100
return mretval
*---------------------------------------------------------------------------------
FUNCTION GET_MONTH()
local mretval := .t., getlist := {}, mcolor := setcolor()
memvar mmonth, myear
setcolor( 'n/g,w+/n,,, w+/g' )
@  8, 31 say 'Transaction Date'                color 'w+/g'
@  9, 32 say 'Month '
@ 10, 32 say ' Year '
@  9, 42 get mmonth pict '99'   when  select_month( @mmonth, 09, 46, 18, 56 )
@ 10, 41 get myear  pict '9999' valid myear > 1970
read
setcolor( mcolor )
return lastkey() != K_ESC

//ÄÄÄdesc...word to be written in check
//ÄÄÄpara...namount - numeric
//ÄÄÄretu...word
function fChar0700( namount )
local cstring := '', temp, xx

for xx := 6 to 0 step -3
   if namount >= 10 ^ xx
      temp := int( namount / 10 ^ xx )
      cstring += fConv0700( temp ) + if( xx == 6, ' million',;
				     if( xx == 3, ' thousand', '' ) )
      namount -= temp * 10 ^ xx
      if namount > 0
	 cstring += ' '
      endif
   endif
next
if namount != int( namount )
   cstring += if(!empty(cstring),'and ','') + str( ( namount - int( namount ) ) * 100, 2 ) + '/100'
else
   cstring += ''
endif
return( cstring )

////
//ÄÄÄdesc...convert number into word
//ÄÄÄpara...namount - numeric
//ÄÄÄretu...word
static function fConv0700( namount )
static words := { 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven',    ;
		  'Eight', 'Nine', 'Ten', 'Eleven', 'Twelve', 'Thirteen',   ;
		  'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen',;
		  'Nineteen', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty',;
		  'Seventy', 'Eighty', 'Ninety' }
local cstring := '', temp

if namount > 99
   temp := int( namount / 100 )
   cstring += words[ temp ] + ' hundred'
   namount -= temp * 100
   if namount > 0
      cstring += ' '
   endif
endif

do case
   case namount > 0 .and. namount < 20
	cstring += words[ namount ]
   case namount > 19
	temp := int( namount / 10 )
	cstring += words[ temp + 18 ]
	namount -= temp * 10
	if namount != 0
	   cstring += '-' + words[ namount ]
	endif
endcase
return( cstring )    
*---------------------------------------------------------
FUNCTION WARN(cWARN,nPAUSE)
LOCAL nLEN    := LEN(cWARN)
LOCAL lPAUSE  := IF(nPAUSE <> NIL .AND. nPAUSE = 1,.T.,.F.)
LOCAL nX1     := 12
LOCAL nY1     := (80 - (nLEN + 4)) / 2
LOCAL nX2     := IF(lPAUSE,15,14)
LOCAL nY2     := 80 - nY1
LOCAL COLORS  := SETCOLOR()
LOCAL cSCR    := SAVESCREEN(nX1,nY1,nX2+1,nY2+1)
LOCAL nCURSOR := SETCURSOR()

SET COLOR TO 'W+/R'
SETCURSOR(0)
@ nX1,nY1 CLEAR TO nX2,nY2
@ nX1,nY1 SAY REPL('Í',nY2+1-nY1) COLOR 'GR+/R'
@ nX2,nY1 SAY REPL('Í',nY2+1-nY1) COLOR 'GR+/R'
BOXSHADOW(nX1,nY1,nX2,nY2)
@ nX1+1,nY1+2 SAY cWARN           COLOR 'GR+/R'

IF lPAUSE
   @ nX1+2,32 SAY 'Press any Key!'   COLOR 'GR+/R'
ENDIF

IF lPAUSE
   INKEY(0)
ELSE
   INKEY(1)
ENDIF

SETCOLOR(COLORS)
SETCURSOR(nCURSOR)
RESTSCREEN(nX1,nY1,nX2+1,nY2+1,cSCR)

RETURN
***********************************************
function amsmdelete( message, mpos, mlastrec )
***********************************************
    if confirm( message +'?')
       MSGWIN(12,35,'Deleting','W+/BG','R*/BG','ON')

       if netlock( 'R', 0 )
          dbdelete()
          dbskip(+1)

          if eof()
             dbgobottom()
          endif

          dbunlock()
       endif

       MSGWIN(12,35,'Deleting','W+/BG','R*/BG','OFF')
    endif
return nil