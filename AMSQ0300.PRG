/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   colf-iis -- account management system                                      ³
³   program idúúú amsr3600                                                     ³
³   description ..... Matured Account                                          ³
³   authorúúúúúúú Engr. Michael B. Espina                                      ³
³   dateúúúúúúúúú December 3, 1998 10:20 a.m.                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                             u p d a t e s                                    ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        who        ³       when        ³               why                    ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³   abb                  08.13.2001          add old account no. column        ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include 'colf.ch'
#include 'inkey.ch'
#include 'box.ch'

#define normal setcolor('w/n')
#define date_today(y1)  @ y1,60 say CMONTH(DATE()) + STR(DAY(DATE())) + "," + STR(YEAR(DATE()))
#define saving bx:=savescreen(0,0,maxrow(),maxcol())
#define restoring restscreen(0,0,maxrow(),maxcol(),bx)
memvar  AX_LEVEL, gUSER_ID 
local ktr
public fromdate,todate,xkey,ctr2,mike2,mike,kunter
 
setcursor(0)
setblink(.t.)
if chkpass( procname(), AX_LEVEL, gUSER_ID )
   begin sequence
         mainmodal()
   end sequence
   dbcloseall()
endif
__mrelease( '*', .t. )
return nil 

static function mainmodal()
ktr:=0
 
 Do while  ktr <> 2 
    saving
    getdate()
   if !confirm("Would you like to match records again?")
       ktr:=2
   Endif   
   restoring
 Enddo
 
Return

static function Acct_Multiple()
   local i,ctr,browse2,obrowse2,flaging:=0,many:=array(10)
   LOCAL xTEMP := ''
   
   //FOM  02132014*********************************************
	//IF TRUE_BRCH == '001'
		if !netuse('&g_AMS_PATH\Acctmast',.F.,0)
			return(nil)
		else
			set index to &g_AMS_PATH\Acctmatd
		endif
     	ACCTMAST->(dbseek(g_PAR_BRCH))	// RLV 1:18 PM 10/20/2008
	//ENDIF
    //********************************************************
   IF TRUE_BRCH == '001'                      && RED 081505
  
  
      select Acctmast
   
      if !netlock('R',5)
         close acctmast
         return(nil)
      endif
	  
         dbcreate ( 'MATURITY',{ {'acctname' ,'c',50,00 },;
                                               {'oldno'    ,'c',20,00 },;
                                               {'acctno'   ,'c',14,00 },;
                                               {'termunit' ,'c',03,00 },;
                                               {'term'     ,'n',03,00 },;
                                               {'valdate'  ,'d',08,00 },;
                                               {'matdate'  ,'d',08,00 },;
                                               {'principal','n',12,02 },;
                                               {'rv'       ,'n',09,06 },;
                                               {'gd'       ,'n',09,06 },;
                                               {'osbal'     ,'n',12,02},;
                                               {'BRCODE'   ,'C',03,00 } ;
                                      };
                           )
           	  
      waiton ('Processing data')
//      copy fields acctname, acctno, BRCODE, principal, valdate,matdate, osbal,term,termunit,oldno to maturity for ACCTMAST->BRCODE == g_PAR_BRCH .and. acctmast->matdate >=fromdate .and. acctmast->matdate <= todate
//aga.13.10.2005.inserted gdrv fields on maturity temp dbf
 //     copy fields acctname, acctno, BRCODE, principal, valdate,matdate, osbal,term,termunit,oldno,gd,rv to maturity for ACCTMAST->BRCODE == g_PAR_BRCH .and. acctmast->matdate >=fromdate .and. acctmast->matdate <= todate
      
	  if !netuse('maturity',.F.,0)
          return(nil)
	  else
	  
      endif
   
	  do while ACCTMAST->BRCODE == g_PAR_BRCH
		if acctmast->matdate >=fromdate .and. acctmast->matdate <= todate
			if MATURITY->(netlock('A',5))	
					MATURITY->acctname :=	ACCTMAST->acctname
					MATURITY->acctno   :=	ACCTMAST->acctno
					MATURITY->BRCODE   :=	ACCTMAST->BRCODE
					MATURITY->principal:=	ACCTMAST->principal
					MATURITY->valdate  :=	ACCTMAST->valdate
					MATURITY->matdate  :=	ACCTMAST->matdate
					MATURITY->osbal    :=	ACCTMAST->osbal
					MATURITY->term     :=	ACCTMAST->term
					MATURITY->termunit :=	ACCTMAST->termunit
					MATURITY->oldno    :=	ACCTMAST->oldno
					MATURITY->gd       :=	ACCTMAST->gd
					MATURITY->rv	   :=	ACCTMAST->rv
			endif		
		endif
		ACCTMAST->(dbskip(1))
	  enddo
	  MATURITY->(dbunlock())
	  MATURITY->(dbcommit())
//....................................
      waitoff ()


      select maturity
      index on matdate to maturity

      statusbar('w+/bg','r/b','gr+/bg', ' checking for matches ',1000)
      set color to 'gr+/gr+','gr+/n'

      if reccount() = 0
         fshadow(10,30,14,55,1,'gr+/b' ,'Records')
         @ 12,32 say "No matching Records"    color "gr+/b"
         inkey(0)
         close maturity
         close acctmast
         erase maturity.dbf
         RETURN(NIL)
      endif



   ELSE
      xSTR := CHK_PAR(DTOC(FROMDATE))+CHK_PAR(DTOC(TODATE))
      xTEMP := CPS_REQST( xSTR, 'MAT_ACC1')

      IF xTEMP == NIL .OR. EMPTY(xTEMP)
         FSHADOW(10,30,14,55,1,'GR+/B' ,'RECORDS')
         @ 12,32 SAY "No matching Records"    COLOR "GR+/B"
         INKEY(0)
         RETURN(NIL)
      ENDIF
   ENDIF

   *repcontrol('matprnt()')
   xSTR := CHK_PAR(xTEMP)+CHK_PAR(DTOC(FROMDATE))+CHK_PAR(DTOC(TODATE))
   REPCON_OL('MATPRNT()',,,,,,xSTR, .T.)

   IF TRUE_BRCH == '001'                      && RED 081505
      close maturity
      close acctmast
      erase maturity.dbf
      erase maturity.ntx
   ENDIF
  
 RETURN(nil)
 
 
 
static function _TERM()

      mike:=maturity->termunit
	  
      Do case
         case mike = '1'
              mike2 := 'Day/s  '
         case mike = '2'
              mike2 := 'Month/s'
         case mike =  '3'
              mike2 := 'Year/s  '
      Endcase

return nil

  
static function getdate()
  local ctr:=0
     
   saving 
   Do while ctr <> 2 
      set color to 'gr+/gr+','gr+/b'
      fshadow(10,30,14,50,1,'gr+/b' ,'Date')
      todate:=ctod(' ')
      fromdate:=ctod(' ')
      set cursor on
      
      @ 12,32 say "FROM"        color  'gr+/b'
      @ 13,32 say "TO"             color 'gr+/b'
      @ 12,39 get fromdate        pict '@D' 
      @ 13,39 get todate           pict '@D'
      read
      set cursor off 
     
    if lastkey() = K_ESC
         restoring
         return(nil)
    endif
    if empty(fromdate) 
         Error('Do not leave it blank')
         loop
    endif 
    if empty(todate)
         todate := date()
         @ 13,39 say todate    color 'gr+/b'        
    endif
    if todate < fromdate
         Error("Not Valid To date must be greater or equal to From date")
	   loop
    endif 
     
    Acct_multiple()
    ctr:=2
    Enddo   
    restoring
 RETURN (nil)
      
//aga.23.10.2006.do nothing, unnecessary delay
/*
static function delay(ctr2)
 local i,j
 i:=1
 j:=1
 ctr:=100
 for j:=1 to ctr2
	 do while i <> ctr
		 i++
	 enddo
	 ctr++
 next
 
RETURN
*/

static function Ultimate_box(y1,x1,y2,x2,border,border2,kulay,kulay2,close)
  local i,j,ctr,xpos,ypos,xpart,k,l,xx,yy

  xpos := abs(x2-x1)
  ypos := abs(y2-y1)
  xpart =  x1
  xpart2 = x2
  ypart =  y1
  ypart2 = y2
  ylow:=   y1
   
  Do case
     case border = 1
          border:= chr(250)
     case border = 2
          border:= chr(221)
     case border = 3
          border:= chr(223)
     case border = 4
          border:= chr(219)
     case border = 5
          border:= chr(176)
     case border = 6
          border:= chr(178)
     case border = 7
          border:= chr(232) 
     case border = 8
          border:= chr(177)
  Endcase
 
    setcolor(kulay)
	for i:= 1 to xpos
		@ y1,xpart say border
		xpart++
	next
	for j:= 1 to ypos
		@ ypart,x2 say border
		ypart++
	next
	for k:= 1 to xpos
		@ y2,xpart2 say border
		xpart2--
	next
	for l:= 1 to ypos
		@ ypart2,x1 say border
		ypart2--
	next
	
    xx:=x1+1
    yy:=y1+1
    setcolor(kulay2) 
    for j:= 1 to (ypos-1)
        for i:= 1 to ((xpos-1)-x1)
            @ yy,xx say border2
            xx++
        next
        xx:=x1+1
        yy++
    next
    if close == 0
       dispbox(y1,x1,y2,x2,1,kulay)
    endif
    if close == 1
       dispbox(y1,x1,y2,x2,2,kulay)
    endif
RETURN

static function statusbar(bkcolor,runcolor,txtcolor,Message,DEL)
   local bokal,ctr,i
   bokal:=savescreen(12,14,22,55)
   fshadow(14,18,19,50,2,bkcolor,Message) 
   @ 16,22 say replicate(chr(176),26)
   ctr:=0 	 
   i:=0
   Do while ctr <> 26
      setcolor(runcolor)
      @ 16,22+ctr say chr(219)
      //delay(DEL)
      setcolor(txtcolor)
      @ 18,22 say "Percent Complete      %"
      @ 18,40 say ltrim(str(i))
      i:=i+4
      ctr++
   Enddo
   setcolor('w/n')
   //delay(3000)
   restscreen(12,14,22,55,bokal)
RETURN   
      
function matprnt()
local mu:=savedbf(),re:=setcursor(),bf:=savescreen(,,,),gf:=setcolor()
local pgn:=1,nacct,sw:=.t.

dbselectarea('maturity')
dbsetorder(2)
mathead(pgn)

do while !eof()
   IF MATURITY->BRCODE == g_PAR_BRCH
      if prow() >= 55
         pgn++
         __eject()
         @ prow()+1,0 say ''
         SETFONT('CONDENSED')
         mathead(pgn)
         sw:=.t.
      endif

	  _TERM()
/*
      @ prow()+1,02 say substr(maturity->acctname,1,30)   + '  '  + ;
                        padr(if(empty(Maturity->oldno),'No LA NO.',maturity->oldno),20)   + '  '   + ;
                        TRAN(MATURITY->BRCODE+substr(Maturity->Acctno,10),'@R 999-99999') + ' '   + ;
                        tran(Maturity->principal,'999,999,999.99') + '  ' + ;
                        str(Maturity->term) + ' ' + mike2 + '    ' + ;
                        dtoc(Maturity->valdate)   + '    '         + ;
                        dtoc(Maturity->matdate)   + '  '           + ;
                        tran(Maturity->osbal,'999,999,999.99')    + '  '           + ;
                        tran(Maturity->gd / 100 * Maturity->principal,'999,999,999.99')   + '  '           + ;
                        tran(Maturity->rv / 100 * Maturity->principal,'999,999,999.99')
*/

//aga.13.10.2005.inserted gdrv printing code
      @ prow()+1,02 say substr(maturity->acctname,1,30)   + ' '  + ;
                        padr(if(empty(Maturity->oldno),'No LA NO.',maturity->oldno),20)   + ' '   + ;
                        TRAN(MATURITY->BRCODE+Maturity->Acctno,'@R 999-9999-99999-99999') + '  '   + ;
                        tran(Maturity->principal,'999,999,999.99') + ' ' + ;
                        str(Maturity->term) + ' ' + mike2 + ' ' + ;
                        dtoc(Maturity->valdate)   + '  '         + ;
                        dtoc(Maturity->matdate)   + '  '           + ;
                        tran(Maturity->osbal,'999,999,999.99')    + '  '           + ;
                        tran(Maturity->gd / 100 * Maturity->principal,'999,999,999.99')   + '  '           + ;
                        tran(Maturity->rv / 100 * Maturity->principal,'999,999,999.99')
//........................................



   ENDIF
   dbskip()
   
enddo
restdbf(mu);restscreen(,,,,bf);setcursor(re);setcolor(gf)

return nil
 
     
Static Function mathead(pgn)

setprc(0,0)
setfont('DRAFT')
setfont('ELITE')
@ prow()+1,02 say 'ACCOUNT MANAGEMENT SYSTEM'
@ prow(),  02+len('ACCOUNT MANAGEMENT SYSTEM');
              say PADL('Page No. ' + tran(pgn,'99'),94-len('ACCOUNT MANAGEMENT SYSTEM'))
@ prow()+1,02 say 'AMSQ0300'
@ prow()  ,02+len('AMSQ0300');
              say PADL( dtoc(DATE())+' '+TIME(), 96-len('AMSQ0300'))
@ prow()+1,02 say PADC('ORIX METRO LEASING AND FINANCE CORPORATION',98)
@ prow()+1,27 say 'MATURING ACCOUNTS on ' + dtoc(fromdate) + ' to '  + dtoc(todate)
@ prow()+1,00 say ''

setfont('ELITE')
SETFONT('CONDENSED')

//@ prow()+1,01 SAY ' ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄ    ÄÄÄÄÄÄÄÄÄÄÄÄÄ    ÄÄÄÄÄÄÄÄÄÄÄÄÄ    ÄÄÄÄÄÄÄÄÄÄÄÄÄ'
//@ prow()+1,01 SAY '   ACCOUNT NAME                    OLD ACCOUNT NO.      ACCT NO.     PRINCIPAL      TERM       VALUE DATE    MAT. DATE      O/S BALANCE           GD               RV     '
//@ prow()+1,01 SAY ' ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄ    ÄÄÄÄÄÄÄÄÄÄÄÄÄ    ÄÄÄÄÄÄÄÄÄÄÄÄÄ    ÄÄÄÄÄÄÄÄÄÄÄÄÄ'

//aga.13.10.2005.inserted gdrv print headers
*@ prow()+1,01 SAY ' ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄ'
*@ prow()+1,01 SAY '   ACCOUNT NAME                   OLD ACCOUNT NO.     ACCT NO.      PRINCIPAL     TERM     VALUE DATE  MAT. DATE     O/S BALANCE          GD              RV     '
*@ prow()+1,01 SAY ' ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄ'
@ prow()+1,01 SAY ' ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄ'
@ prow()+1,01 SAY '   ACCOUNT NAME                   OLD ACCOUNT NO.        ACCOUNT NO.           PRINCIPAL     TERM     VALUE DATE  MAT. DATE     O/S BALANCE          GD              RV     '
@ prow()+1,01 SAY ' ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄ   ÄÄÄÄÄÄÄÄÄÄÄÄÄ'
//..........................................

return(nil)


/*
static function not_eof()
memvar grd_rv_total, grd_gd_total

if eval( mtrue( Acctmast->rv, Acctmast->gd ), 0 )
   @ prow()    , 47 say Acctmast->gd / 100 * Acctmast->principal picture '###,###,###.##'
   @ prow()    , 62 say Acctmast->rv / 100 * Acctmast->principal picture '###,###,###.##'
   grd_gd_total += ( Acctmast->gd / 100 * Acctmast->principal )
   grd_rv_total += ( Acctmast->rv / 100 * Acctmast->principal )
endif

return( nil )
*/
