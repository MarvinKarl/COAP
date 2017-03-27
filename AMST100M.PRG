/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ program id.....: amst0100.prg ®+¯ amst100m.prg                               Ã¿
³ description....: hotkey F3 for accounts maintenance JV's transaction         ³³
³ author.........: gener c. singson                                            ³³
³ date...........: 8:57:41.97am úúú 10.24.94                                   ³³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´³
³                              u p d a t e s                                   ³³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´³
³         who        ³    when      ³                why                       ³³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´³
³      ABB           ³  10.19.2004  ³  FOR ONLINE                              ³³
³  Emily V. Racasa   ³  25.09.2006  ³  change AMSJV? to TRAN????               ³³
³                    ³              ³  adjust fieldget and arr_                ³³
³  Marvin T. Sabile  ³  09.03.2008  ³  change tbrowse to achoice on F3         ³³
ÀÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

////
#incl 'colf.ch'
#incl 'inkey.ch'

////
#xtra xBrowse(<o>)  => eval( { | n | n := fBrow100m(<o>) , fSaid100m(<o>) } )
#xtra xWhile(<o>)   => while !eval( { | n | n := fKee100m(<o>), fSaid100m(<o>), fBrow100m(<o>), fSaid100m(<o>), fChkstJVx( Tranhead->Trantype ), n } );;
                       enddo 
#xtra xSum(<o>,<u>) => dbeval( { || if( Trandtls->drcr $ '1', <o> += Trandtls->amount, <u> += Trandtls->amount );
                               },, { || Tranhead->brcode+Tranhead->trnumber == Trandtls->BRCODE+Trandtls->trnumber } )  && RED 112204 REPLACED 'Acctdaly->brcode
#xtran getprntr (<xnum>) => if ( <xnum> == 1, "'Epson FX-1170'",;
                               "'OKI Microline 321'")

////
#defi colorcolo  'gr+/bg, w+/rb, w+/b, b/w, w+/g, b+/g, r+/n, w+/r, n/w, w+/rb'
#defi colormono  'gr+/n, n/w, n/w, w*/n, w/n, w+/n, w+/n, n/w, w+/gr, n/w'
#defi toneone     tone( 60, .5 )
#defi tonetwo     tone( 480, 0.25 ); tone( 240, 0.25 )
#defi frozen      0
#defi gR_CELL     { 1,  2 }
#defi gN_CELL     { 3,  9 }
#defi gD_CELL     { 9, 10 }
#defi microfeed   chr( 27 ) + 'J' + chr( 5 )

////
******************************
*
function amstvoucher()
******************************       // abb 10.19.2004
local mscreen := savescreen( ,,, ), mdbf_ := fZipp100m()
local mpullout, mcolor := setcolor(),mu:=savedbf(), xarr
memva AX_LEVEL, gUSER_ID
// EVR private mAMS0100 := ''

private  lJVFOUND := .f. , xFIRSTJV := ''


if !chkpass( 'A', AX_LEVEL, gUSER_ID )

else
 if amstopen1m()
 
/* dupfile('ACCTJVHD')

xarr := TRANHEAD->(DBSTRUCT())

   //cHEAD := tempName()
   DBCreate( 'c:\lotus\'+'ACCTJVHD', xarr )
   DBUseArea( .T.,, 'c:\lotus\'+'ACCTJVHD', , .F. )

dupfile('ACCTJVDT')   

xarr := {}
  
xarr := TRANDTLS->(DBSTRUCT())   
   
  // zDETL := tempName()
   DBCreate( 'c:\lotus\'+'ACCTJVDT', xarr )
   DBUseArea( .T.,, 'c:\lotus\'+'ACCTJVDT', , .F. )
   index on field->drcr+field->glcode to 'c:\lotus\'+'ACCTJVDT'
   set index to 'c:\lotus\'+'ACCTJVDT'
 
*/
 
     ***   Parametr->(dbclosearea())
    ***   if netuse('&g_Gl_Path\Parametr',.f.,0)
       if !empty( ACCTDALY->BRCODE+Acctdaly->acctno )
           begin sequence
            fMain100m()
            recover using mpullout
            if mpullout
               fUnzp100m( mdbf_ )
               setcolor( mcolor )
               restscreen( ,,,, mscreen )
            endif
           end sequence      
    ***    endif
    ***    Parametr->(dbclosearea())
       endif
       fJVDBFclose()                    && RED 051605
    endif
endif

***** netuse('Parametr',.f.,0)  //return the Ams\Parametr abb 10.14.2004
*fJVDBFclose()                      && RED 051605 MOVED UP
// EVR dbselectarea('Amsjvh')
// EVR dbclearindex()
// EVR ferase( (mAMS0100) + '.ntx' )
// EVR set index to &g_AMS_PATH\AMSJVH,&g_AMS_PATH\Amsjvt
restdbf(mu)
__mrelease( '*', mpullout )
return( mpullout )

*********************************
*
*
static function fMain100m()                  // ABB 10.19.2004
*********************************
local cb    // EVR , mwhat := ACCTDALY->BRCODE+subs( Acctdaly->acctno, -5, 5 ),mu:=Amsjvh->(indexord())
priva rel, lrr := gigi := where := 1, cel, arg
priva zax, color := iscolor(), zrow := 1, xrow := 7

***** Amsjvh->(dbsetorder(3))

//EVR Amsjvh->(dbsetorder(1))
dbselectar( 'Tranhead' )

*****
***** Amsjvh->  ( dbsetorder(2) )
*****

// Amsjvh->( dbseek( mwhat,.f. ) )               abb 10.19.2004
// EVR Amsjvh->( dbseek( mwhat,.f. ) ) && RED 112204 REMOVED 'Acctdaly->brcode+

Tranhead->(dbseek(g_PAR_BRCH))
do while Tranhead->BRCODE == g_PAR_BRCH .and. !Tranhead->(eof())
   if Tranhead->TRLOANNO == subs(Acctdaly->ACCTNO, -5, 5) .and. Tranhead->trantype != '3'
      lJVFOUND := .t.
	  xFIRSTJV := TRANHEAD->trnumber
      exit
   endif
   Tranhead->(dbskip())
enddo
   
if !lJVFOUND
	Tranhead->(dbgobottom())
	Tranhead->(dbskip())
endif

xBrowse( @cb )           // browse screen and return browse object variable

xWhile( cb )             // while !condition

//EVR Amsjvh->(dbsetorder(mu))
return( nil )

////
static function fSaid100m( cb )
/// DBP replaced with OL     jbs 10.25.2002
/// FSF replaced with AUTOL  jbs 10.28.2003
local mdbf, mmess := { 'LCR          ' , 'ML            ', 'IPP           ', 'RP            ',;
                       'AUTOL        ' , 'OL            ', 'CML           ', 'DOC. STAMP/ETC ',;
                       'OTHER         ', 'OLOALP         ',;
                       'OL-PLOANS      ';
                     }
local xmess := { 'Normal   ','Memo     ','Cancelled' }
memva zax

dbselectarea( 'Tranhead' )
//EVR Amsjvh->    ( dbsetorder(3) )

@  5, 27 say TRANHEAD->BRCODE+Tranhead->trnumber pict '@R 999-99999999'          color 'w+/g'
@  5, 66 say Tranhead->trandate picture '@D'                			 color 'w+/g'
@  6, 27 say Tranhead->tramount picture '999,999,999.99'    			 color 'w+/g'
@  6, 66 say Tranhead->Trantype picture '@!'                			 color 'w+/g'
@  7, 27 say if (Tranhead->Fcltytype != '0',Tranhead->Fcltytype,'10') picture if(Tranhead->Fcltytype != '0','9','99')  			 color 'w+/g'
@  8, 27 say substr( Tranhead->partix1,1,45 )  picture '@!' 			 color 'w+/g'
@  9, 27 say substr( Tranhead->partix2,1,45 )  picture '@!' 			 color 'w+/g'
@ 10, 27 say substr( Tranhead->partix3,1,45 )  picture '@!' 			 color 'w+/g'
@ 11, 27 say substr( Tranhead->partix4,1,45 )  picture '@!' 			 color 'w+/g'
@ 12, 27 say substr( Tranhead->partix5,1,45 )  picture '@!' 			 color 'w+/g'
if( Tranhead->(!eof()) .and. Tranhead->(!bof()) .and. Tranhead->Trantype  <> ' ' .and. Tranhead->brcode == Acctdaly->brcode ,fTran100m( 6, 68, xmess[val(Tranhead->Trantype)], 'bg+/g' ),nil)
if( Tranhead->(!eof()) .and. Tranhead->(!bof()) .and. Tranhead->fcltytype <> ' ' .and. Tranhead->brcode == Acctdaly->brcode ,fTran100m( 7, 30, if (Tranhead->Fcltytype != '0',mmess[val(Tranhead->Fcltytype)],mmess[10]), 'bg+/g' ),nil)  //mmess[val(Tranhead->Fcltytype)], 'bg+/g' ),nil)

for __nctr := 7 to 19
   @ __nctr, 2 say if(__nctr <=13,chr(219) ,chr(176) ) color if(__nctr <=13,'gr+/gr+','n/w')
next
		 
mdbf := fZipp100m()
dbselectar( 'Trandtls' )

//dbseek( zax := Amsjvh->trnumber )        // abb 10.19.2004

if Trandtls->(dbseek(Tranhead->BRCODE+Tranhead->Trnumber))    && RED 112204 REPLACED  'Acctdaly->brcode+ WITH Tranhead->BRCODE
   zax:= Tranhead->BRCODE+Tranhead->Trnumber                && RED 112204 REPLACED 'Acctdaly->brcode WITH Tranhead->BRCODE
else
   @ 16,3 clear to 20,76
   for nline := 16 to 20
       @ nline,3 say  '                                         ³               ³                '   color 'bg+/b'
   next
   zax:= spac(0)
   zax:= spac(0)
endif

fUnzp100m( mdbf )
return( !.t. )

////
static function fTran100m( mrow, mcol, mmess, mcolor )

if (mmess == '0','10',mmess)
@ mrow, mcol say mmess picture '@!' color mcolor 
return( nil )

////
static function fKee100m( cb ) 
local mkey, mtrue := !.t., mscreen, mdbf, mpullout := !.f., lMORE := .f.
local mwhat := ACCTDALY->BRCODE+subs( Acctdaly->acctno, -5, 5 ), msoft
// EVR local mhow  := AMSJVH->BRCODE+Amsjvh->trloanno     && RED 112204 ADDED 'AMSJVH->BRCODE
LOCAL nPRVPOS := 0
memva AX_LEVEL, gUSER_ID, lrr, zrow
private prntcnt:=0,nprntr:=0
private jventry := .t.  //pepe 09.24.2007

//dispbegin()
//@ 13, 2, 19, 2 box repl( '°', 9 ) color 'w+/n'  
//@ 7, 2, 13, 2 box repl( 'Û', 9 ) color 'gr+/w'  
//dispend()

mkey := inkey( 0 )

do case
   case mkey == K_PGUP .or. mkey == K_UP
        nPRVPOS := Tranhead->(RECNO())
        Tranhead->(dbskip(-1))

// EVR         if Tranhead->(bof()) .or. EMPTY(Tranhead->brcode) .OR. EMPTY(Tranhead->trloanno) .OR. ;
// EVR            Tranhead->brcode+Tranhead->trloanno != Acctdaly->brcode+subs( Acctdaly->acctno, -5, 5 )
// EVR            waiton('Beginning',,'n/w')
// EVR            inkey(.1)
// EVR            waitoff()
           *Amsjvh->( dbseek( Acctdaly->brcode + subs(Acctdaly->acctno,-5,5) ) )   && RED 112204 REPLACED WITH BELOW
// EVR            Tranhead->(DBGOTO(nPRVPOS))
// EVR         endif

        do while Tranhead->BRCODE == g_PAR_BRCH .and. !Tranhead->(bof())
           if Tranhead->TRLOANNO == subs(Acctdaly->ACCTNO, -5, 5) .and. Tranhead->trantype != '3'
              lMORE := .t.
              exit
           else
              lMORE := .f.
           endif
           Tranhead->(dbskip(-1))
        enddo
        if !lMORE
           waiton('Beginning',,'n/w')
           inkey(.1)
           waitoff()
           Tranhead->(dbgoto(nPRVPOS))
        endif
fBrow100m()

   case mkey == K_PGDN .or. mkey == K_DOWN
        nPRVPOS := Tranhead->(RECNO())
        Tranhead->(dbskip())

// EVR         if Tranhead->(eof()) .or. EMPTY(Tranhead->brcode) .OR. EMPTY(Tranhead->trloanno) .OR. ;
// EVR            Tranhead->brcode+Tranhead->trloanno != Acctdaly->brcode+subs( Acctdaly->acctno, -5, 5 )
// EVR            waiton('Ending',,'n/w')
// EVR            inkey(.1)
// EVR            waitoff()
           *Amsjvh->(dbskip(-1))    && RED 112204 REPLACED WITH BELOW
// EVR            Tranhead->(DBGOTO(nPRVPOS))
// EVR         endif

        do while Tranhead->BRCODE == g_PAR_BRCH .and. !Tranhead->(eof())
           if Tranhead->TRLOANNO == subs(Acctdaly->ACCTNO, -5, 5)  .and. Tranhead->trantype != '3'
              lMORE := .t.
              exit
           else
              lMORE := .f.
           endif
           Tranhead->(dbskip())
        enddo
        if !lMORE
           waiton('Ending',,'n/w')
           inkey(.1)
           waitoff()
           Tranhead->(dbgoto(nPRVPOS))
        endif
fBrow100m()

   case mkey == K_TAB
   
	     for __nctr := 7 to 19
		    @ __nctr, 2 say if(__nctr >13,chr(219) ,chr(176) ) color if(__nctr >13,'gr+/gr+','n/w')
		 next

        if Tranhead->( !eof()) .and. Tranhead->(!bof())
           if Tranhead->Trantype == '1'
              flitexxxx(.f.)
                AT0100( cb )
              flitexxxx(.t.)
			
           endif   
        endif   
   case mkey == K_INS

	jventry := .f.

        if chkpass( 'A', AX_LEVEL, gUSER_ID )
           if !fGete100m( 'a' )
             __keyboard( chr( K_TAB ) )
           endif   
        endif

   case mkey == K_F2
        if chkpass( 'E', AX_LEVEL, gUSER_ID )
		   If !FTLIST->(dbseek(ACCTDALY->brcode+ACCTDALY->acctno))
			   if Tranhead->brcode == g_par_brch
				   if Tranhead->( dbempty() )
					  //if Tranhead->( netlock( 'R', 5 ) )
						 if Tranhead->trantype <> '3'
							fGete100m( 'e' )
						 endif
					  //endif
					  //Tranhead->( dbunlock() )  
				   else
					  error( 'Nothing to Edit!' )                 
				   endif
			   else
				  error('Transaction number not found!')
			   endif
		   Else
		     ALERT('Cannot edit JV of Acct N§ ;;' + trans( ACCTDALY->acctno, '@R 9999-99999-99999' )+';; Fund Request already processed!')
		   EndIf
	    endif
   case mkey == K_F6
        if chkpass( 'S', AX_LEVEL, gUSER_ID )
		   If !FTLIST->(dbseek(ACCTDALY->brcode+ACCTDALY->acctno))
			   if Tranhead->( dbempty() )
				  //if Amsjvh->trstatus <> '3'
					 //fStat100m( 1 )
					 if Tranhead->Trantype <> '3'
						JvStatxxx( Tranhead->Trantype )
					 endif
				  //endif
			   else
				  error( 'Nothing to Change!' )                 
			   endif
		   Else
		       ALERT('Cannot cancel Acct N§ ;;' + trans( ACCTDALY->acctno, '@R 9999-99999-99999' )+';; Fund Request already processed!')
		   EndIf
        endif
fBrow100m()		
   case mkey == K_F9  
        if chkpass( 'S', AX_LEVEL, gUSER_ID )           
           if Tranhead->( dbempty() )   
              if Tranhead->trantype <> '3' //.and. prnset(@prntcnt,@nprntr)
                 *if nprntr == -1
                    *repcontrol( 'f100mPrnta()', 'JV N§ ' + Amsjvh->trnumber )   // Epson Fx-1170
                     *repcon_ol( 'f100mPrnt()', 'JV N§ ' + Tranhead->trnumber,,,,,,.F. )
                 *else
                     *repcontrol( 'f100mPrnt()', 'JV N§ ' + Amsjvh->trnumber )   // OKI 321
                    repcon_ol( 'f100mPrnta()', 'JV N§ ' + Tranhead->trnumber,,,,,,.F. )
                 *endif
              endif
           else
              error( 'Nothing to Print!' )      
           endif   
        endif   
   case mkey ==K_ESC
		//nPRVPOS := Tranhead->(RECNO())
        tonetwo
		//Trandtls->  ( dbseek( Tranhead->BRCODE+Tranhead->trnumber ) )
		
		//mdr := 0
		//mcr := 0
		
		//do while !Trandtls->(eof()) .and. Tranhead->trnumber == Trandtls->trnumber .and. Tranhead->brcode == Trandtls->brcode
		//	if( Trandtls->drcr $ '1', mdr += Trandtls->amount, mcr += Trandtls->amount )
		//	Trandtls->(dbskip(+1))
		//end do
		
		//if mdr == mcr        //ÄÄÄwill not leave till dr and cr aren't equal
			if yes_no2( 'Exit?',, ' Yes ', ' No ', .f. )       
				//ACCTJVHD->( dbclosearea() )
				//ACCTJVDT->( dbclosearea() )
				break( mpullout )  // begin sequence break      
			endif
		//else
		//	error( 'Please check the JV entries before leaving!!' ) 
		//	 alert("Debit: "+ trans(mdr,'999,999,999.99') + " <> Credit: " + trans(mcr,'999,999,999.99'))
		//	Tranhead->(dbgoto(nPRVPOS))
		//	fBrow100m()
		//endif
endc

return( mtrue ) 

////
static function AT0100(cb)   //fVo100m( cb )
local mtrue := !.f., msaver := fZipp100m()
local mdr := mcr := 0, mrec, mdbf, mscreen := savescreen( ,,, )
memva AX_LEVEL, gUSER_ID, zax, color, rel, cel, arg, gigi
private aSubrecs := {}, _APalmSub := {}, _APalmGL := {}, mPASS := .F., aDR := 0, aCR := 0

//IF (TRANHEAD->TRANTYPE != '3' .AND. TRANHEAD->FCLTYTYPE == '9',SS:=.T.,SS:=.F.) 

IF !Trandtls->(dbseek(Tranhead->BRCODE+Tranhead->Trnumber))
    dbselectarea('Trandtls')
    fGete100m( 'a')
ENDIF

Trandtls->(dbseek(Tranhead->BRCODE+Tranhead->Trnumber))
 mRECNO := Trandtls->(RECNO())

	___GetSubRecs()
 
     setcolor ( 'bg+/b, n/w' )   //( 'i/gr,gr+/bg' )
	 
     @ 16,3 clear to 20,76								  //color 'bg+/b'
	// @ 16,3  to 20,74
     @ 13,3 say  'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'   color 'w+/g'
     @ 14,3 say  '         Account Code/Title              ³     Debit     ³     Credit     '   color 'gr+/bg'
     @ 15,3 say  'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'   color 'w+/g'
	 
	 @ 22,46  say  tran(aDR, '@Z 999,999,999.99') color 'gr+/g'
	 @ 22,62  say  tran(aCR, '@Z 999,999,999.99') color 'gr+/g'
     for nline := 16 to 20
       @ nline,3 say  '                                         ³               ³                '   color 'bg+/b'
	 next
	 
     do while .t.

		@ 22,46  say  tran(aDR, '@Z 999,999,999.99') color 'gr+/g'
		@ 22,62  say  tran(aCR, '@Z 999,999,999.99') color 'gr+/g'

	 mBX := achoice(16,3, 20, 76, aSubrecs, .t.,'fVo100m')

      do case
         //case lastkey() == K_ESC
         //      exit
  
         case lastkey() == K_TAB
	     //if mPRESS
            exit
	     //endif
		 case lastkey() == K_ENTER
		      IF mPASS
		         EXIT
			  ENDIF
		 
      endcase
	  
	 @ 16,3 clear to 20,76
     for nline := 16 to 20
       @ nline,3 say  '                                         ³               ³                '   color 'bg+/b'
	 next
	 
     enddo

return MBX //(cb)

******************************************************
*
static function fFind100m( mcode, mlength, sw )
******************************************************
local nretval:=''
sw:=if(sw == nil,.f.,sw )
if sw
   nretval := ( eval( { | x | Glcode->( dbseek( mcode ) ),;     && RED 062805 REMOVED'Acctdaly->brcode+
                x := transform( mcode, '@R 999-999-99-99-9999' ),;
                chr(15)+ x + ' ' + padr( Glcode->glname, mlength )+chr(18) } ) )
else
   nretval := ( eval( { | x | Glcode->( dbseek( mcode ) ),;     && RED 062805 REMOVED'Acctdaly->brcode+
                x := transform( mcode, '@R 999-999-99-99-9999' ),;
                x + ' ' + padr( Glcode->glname, mlength ) } ) )

endif

return nretval

////
***************************************
*
static function fBrow100m( cb )
***************************************
local mdbf := fZipp100m(), col_
memva zax, color, rel, cel, arg
private aSubrecs := {}, _APalmSub := {}, _APalmGL := {}, aDR := 0, aCR := 0

dispbox   ( 4, 2, 21, 77, 'ÚÄ¿³ÙÄÀ³ ', 'w+/g' )
fJour100m ()
//EVR fEval100m ()
//EVR fChek100m ()

dbselectar( 'Trandtls' )

// zax:=if ( Trandtls->(dbseek(Amsjvh->Trnumber)),;      10.19.2004

if Trandtls->(dbseek(Tranhead->BRCODE+Tranhead->Trnumber))   && RED 112204 REPLACED 'Acctdaly->brcode
   zax := Tranhead->BRCODE+Tranhead->Trnumber              && RED 112204 REPLACED 'Acctdaly->brcode
else
   zax := spac(0)
endif

@ 6,2  say chr(24)    color 'n/w' 
@ 20,2  say chr(25)   color 'n/w' 

//dbseek( zax := Amsjvh->trnumber )

setcolor ( 'w/n', 'w/n' )
@ 0,0  clear to 0,79 
/***** pepe
cb               := tbrowsedb() 
//cb:ntop          := ( 13 + 1 )
//cb:nleft         := (  2 + 1 )
//cb:nbottom       := ( 21 - 1 )
//cb:nright        := ( 77 - 1 )
cb:headsep       := 'ÄÂÄ'
cb:colsep        := ' ³ '
cb:gotopblock    := { |   | fRecp100m( 'top'   , zax ) }
cb:gobottomblock := { |   | fRecp100m( 'bottom', zax ) }

cb:skipblock     := { | n | fRecp100m( 'skip'  , zax,  ;
                    { | x | Trandtls->brcode+Trandtls->trnumber == Tranhead->BRCODE+Tranhead->trnumber ;  && RED 112204 REPLACED 'Acctdaly->brcode
                    }, n ) }


//
//                    { | x | Trandtls->trnumber == x }, n ) }  abb 10.19.2004
//
cb:colorspec     := if( color, colorcolo, colormono )
col_ := {                                                        ;
     tbcolumnnew( '          Account Code/Title'                ,;
        { || fFind100m( Trandtls->BRCODE+Trandtls->glcode, 24-3 )  } ),;         && RED 062805 ADDED 'Trandtls->BRCODE+
     tbcolumnnew( '     Debit '                                 ,;
        { || transform( if( Trandtls->drcr $ '1',                  ;
               Trandtls->amount, 0.00 ), '@Z 999,999,999.99' ) } ),;
     tbcolumnnew( '    Credit'                                  ,;
        { || transform( if( Trandtls->drcr $ '2',                  ;
               Trandtls->amount, 0.00 ), '@Z 999,999,999.99' ) } ) ;
        } 
for n := 1 to len( col_ )
    cb:addcolumn( col_[ n ] )
    if n == 1
       col_[ n ]:colorblock := { || gR_CELL }
    else
       col_[ n ]:colorblock := { || gN_CELL }
    endif
next n


cb:freeze   := frozen
cb:colpos   := cb:freeze + 1
cb:autolite := .f.
arg         := ( ( cb:colpos + 1 ) / cb:colcount ) * ( cb:nright - cb:nleft )
cel         := cb:nleft + 2
rel         := 1
@ cb:ntop    + 2, cb:nright + 1 say chr( 24 )      color 'n/+w'
@ cb:nbottom    , cb:nright + 1 say chr( 25 )      color 'n/+w' 
@ cb:nbottom + 1, cb:nleft  + 1 say chr( 27 )      color 'n/+w'
@ cb:nbottom + 1, cb:nright - 1 say chr( 26 )      color 'n/+w' 
@ cb:ntop    + 3, cb:nright + 1,;
  cb:nbottom - 1, cb:nright + 1 box repl( '°', 9 ) color '+w/n'
@ cb:nbottom + 1, cb:nleft  + 2,;
  cb:nbottom + 1, cb:nright - 2 box repl( '°', 9 ) color '+w/n' 
@ cb:ntop    - 1, cb:nleft      say repl( 'Ä',;
                    ( cb:nright - cb:nleft ) + 1 ) color 'w+/g'  
cb:refreshall()

*****/

 //fShadow( 16, 4, 22, 75, 2, 'w+/g' ) //w+/GR

 //dbselectarea('Trandtls')
 Trandtls->(dbseek(Tranhead->BRCODE+Tranhead->Trnumber))
 mRECNO := Trandtls->(RECNO())

if Tranhead->TRLOANNO == subs(Acctdaly->ACCTNO, -5, 5)
	___GetSubRecs()
else
	aadd ( aSubrecs,  padr(' ',' ')   		+ ' '  +  ;
		   space(40)       	+ '³ ' +  ;
		   space(14)		+ '³ ' +  ;
		   space(14   )     + ' '     ;
		 )
		 
endif

     setcolor ( 'bg+/b, bg+/b' )   //( 'i/gr,gr+/bg' )
	 
     @ 16,3 clear to 20,76								  //color 'bg+/b'
	 // @ 16,3  to 20,74
     @ 13,3 say  'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'   color 'w+/g'
     @ 14,3 say  '         Account Code/Title              ³     Debit     ³     Credit     '   color 'gr+/bg'
     @ 15,3 say  'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'   color 'w+/g'
	 @ 21,3 say  'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'   color 'w+/g'
	 @ 22,2 say repl(' ',76)                                                                    color 'g/g' 
	 
	 @ 22,35 say "TOTAL ¯"                                                                      color 'r+/g' 
	 
	
	@ 22,46  say  tran(aDR, '@Z 999,999,999.99') color 'gr+/g'
	@ 22,62  say  tran(aCR, '@Z 999,999,999.99') color 'gr+/g'
	
	 
     for nline := 16 to 20
	     @ nline,3 say  '                                         ³               ³                '   color 'bg+/b'
	 next

     do while .t.
      mBX := achoice(16,3, 20, 76, aSubrecs, .f.)
	  exit
      do case
         case lastkey() == K_ESC
               exit
  
         case lastkey() == K_ENTER
	      //if mPRESS
               exit
	      //endif
		
      endcase

     enddo


fUnzp100m( mdbf )

return (cb)


*******************************
static function unBALANCED(nDR,nCR)
*******************************
local mscreen := savescreen( ,,, )
local aSUBDTLS :={}

for i := 1 to len(adtls)

	aadd ( aSUBDTLS,  padr(' ',' ')   		+ ' '  +  ;
			   fFind100m( aDTLS[i][6]+aDTLS[i][2], 21 )       	+ '³ ' +  ;
			   trans( if( aDTLS[i][3] $ '1',aDTLS[i][5], 0.00 ), '@Z 999,999,999.99' )		+ '³ ' +  ;
			   trans( if( aDTLS[i][3] $ '2',aDTLS[i][5], 0.00 ), '@Z 999,999,999.99' )     + ' '     ;
			 )

next i


 fShadow( 8, 2, 19, 77, 2, 'w+/r' )

 setcolor ( 'bg+/n, n/w' )   //( 'i/gr,gr+/bg' )
 
 @ 12,3 clear to 16,76								  //color 'bg+/b'
// @ 16,3  to 20,74
 @ 9,3 say  'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'   color 'gr+/n'
 @ 10,3 say  '         Account Code/Title              ³     Debit     ³     Credit     '   color 'gr+/n'
 @ 11,3 say  'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'   color 'gr+/n'
 
 @ 18,35 say "TOTAL ¯"                                                                      color 'gr+/r'  
 @ 18,46  say  tran(nDR, '@Z 999,999,999.99') color 'gr+/r'
 @ 18,62  say  tran(nCR, '@Z 999,999,999.99') color 'gr+/r'
 for nline := 12 to 17
   @ nline,3 say  '                                         ³               ³                '   color 'bg+/n'
 next
 
 CENTER(22,gBLINKING,[ UNBALANCED ENTRIES!! PRESS ANY KEY.. ])

     do while .t.
      mBX := achoice(12,3, 16, 76, aSUBDTLS, .t.)
	  exit
      do case
         case lastkey() == K_ESC
               exit
  
         case lastkey() == K_ENTER
	      //if mPRESS
               exit
	      //endif
		
      endcase

     enddo


restscreen( ,,,, mscreen )

return


********************************
*
STATIC FUNCTION ___GetSubRecs()
********************************
local NCTR := 0
	aCR := 0
	aDR := 0


      dbselectar( 'Trandtls' )
	  Trandtls->(dbseek(Tranhead->BRCODE+Tranhead->Trnumber))
	  mRECNO := TRANDTLS->(RECNO())
	  //ALERT(Tranhead->BRCODE+Tranhead->Trnumber)
	      do while Trandtls->brcode   == Tranhead->BRCODE   .and. ;
		           Trandtls->Trnumber == Tranhead->Trnumber .and. ;
			      !Trandtls->(eof()) 

			        nctr++

	        	    aadd ( aSubrecs,  padr(' ',' ')   		+ ' '  +  ;
	                           fFind100m( Trandtls->BRCODE+Trandtls->glcode, 21 )       	+ '³ ' +  ;
	                           trans( if( Trandtls->drcr $ '1',Trandtls->amount, 0.00 ), '@Z 999,999,999.99' )		+ '³ ' +  ;
	                           trans( if( Trandtls->drcr $ '2',Trandtls->amount, 0.00 ), '@Z 999,999,999.99' )     + ' '     ;
	              	         )
							 
							 
				if Trandtls->drcr $ '1'
					aDR += Trandtls->amount
				else	
					aCR += Trandtls->amount
				endif	

			    aadd ( _APalmSub,Trandtls->amount)
			    aadd ( _APalmGL,Trandtls->(recno())) //Trandtls->BRCODE+Trandtls->glcode)
				
				
				
	      Trandtls->(dbskip(+1))
	      enddo
	 Trandtls->(dbGOTO(mRECNO))

RETURN 0


****************************************************
*
FUNCTION fVo100m (status, curr_elem, curr_row)
****************************************************
local key    := lastkey(),mSAY,cSRCH := space(10)
local __nctr := 0, getlist := {}, menulist := {},nORGPOS := 0
local _lfound := .f., mscreen1 := savescreen1( ,,, ), INDKEY := INDEXORD()

   do case
	  case key == K_TAB

				mdf := fZipp100m()
				mdr := mcr := 0.00

				//aga.11.07.2005.new validation check for unbalanced jv's 
				Tranhead->( dbseek(Tranhead->BRCODE+Tranhead->trnumber) ) && RED 112204 REPLACED 'Acctdaly->brcode
				Trandtls->( dbseek(Tranhead->BRCODE+Tranhead->trnumber) )  
				do while !Trandtls->(eof()) .and. Tranhead->trnumber == Trandtls->trnumber .and. Tranhead->brcode == Trandtls->brcode
				    if( Trandtls->drcr $ '1', mdr += Trandtls->amount, mcr += Trandtls->amount )
				    Trandtls->(dbskip(+1))
				end do                

				fUnzp100m  ( mdf )
					
					
				if 	(round ( mdr, 2 ) == 0.00 .and. round( mcr, 2 ) == 0.00)
				    mtrue := !.t.
				    for __nctr := 7 to 19
				     @ __nctr, 2 say if(__nctr <=13,chr(219) ,chr(176) ) color if(__nctr <=13,'gr+/gr+','n/w')
				  next
				  return 1
				endif
				
					
				if 	round(mdr,2) != round(mcr,2)

					alert("Debit: "+ trans(mdr,'999,999,999.9999') + " <> Credit: " + trans(mcr,'999,999,999.9999'))
					
				elseif (round( mdr, 2 ) == Tranhead->tramount .and. round( mcr, 2 ) == Tranhead->tramount) 
				    mtrue := !.t.
				    for __nctr := 7 to 19
				     @ __nctr, 2 say if(__nctr <=13,chr(219) ,chr(176) ) color if(__nctr <=13,'gr+/gr+','n/w')
				  next
				  return 1
				    //cb:gotop()
				else
				   //alert("Debit: "+ trans(mdr,'999,999,999.99') + " <> Credit: " + trans(mcr,'999,999,999.99'))
				   //alert("Transaction Amount: "+ trans(Tranhead->tramount,'999,999,999.99') + " <> JV Entries Total: " + trans(mcr,'999,999,999.99'))
				   WARN("Transaction Amount: "+ trans(Tranhead->tramount,'999,999,999.99') + " <> JV Entries Total: " + trans(mcr,'999,999,999.99'),1)
				endif

         case key == K_F2

   		      if chkpass( 'E', AX_LEVEL, gUSER_ID )
                 if Tranhead->brcode == g_par_brch
				    Trandtls->( dbseek(Tranhead->BRCODE+Tranhead->trnumber) )
					
                    if Tranhead->brcode+Tranhead->trnumber == Trandtls->BRCODE+Trandtls->trnumber       && RED 112204 REPLACED 'Acctdaly->brcode
					   do while Tranhead->brcode+Tranhead->trnumber == Trandtls->BRCODE+Trandtls->trnumber
						   if Trandtls->(recno()) == _APalmGL[curr_elem]
	                          //if Trandtls->( netlock( 'R', 5 ) ) 
	                            IF fGete100m( 'e' ,curr_elem) 
							      aSubrecs  := {}
								  _APalmSub := {}
								  _APalmGL  := {}
								  ___GetSubRecs()
								ENDIF
	                          //endif
	                          //Trandtls->( dbunlock() )
                              exit
						   endif
					   Trandtls->(dbskip())
					   enddo
					   
                    endif
                 else
                    error('Transaction number not found!')
                 endif
              endif
			  return 1

         case key == K_INS

              if chkpass ( 'A', AX_LEVEL, gUSER_ID )
                 mdf := fZipp100m()
                 mdr := mcr := 0.00
                 Trandtls->  ( dbseek( Tranhead->BRCODE+Tranhead->trnumber ) )
			     xSum      ( mdr, mcr )        //ÄÄÄwill not leave till dr and cr aren't equal
			     fUnzp100m ( mdf )
			     if round( mdr, 2 ) == Tranhead->tramount .and.;
			        round( mcr, 2 ) == Tranhead->tramount                
			        waiton( 'Balanced!',, 'w+/r' )   
			        inkey( .2 )
			        waitoff()         
			     else
			        fGete100m( 'a',curr_elem )
					aSubrecs  := {}
					_APalmSub := {}
					_APalmGL  := {}
					___GetSubRecs()
			     endif
			  endif
			  return 1
			  
         case key == K_DEL

              if chkpass( 'D', AX_LEVEL, gUSER_ID )
			     Trandtls->( dbseek(Tranhead->BRCODE+Tranhead->trnumber) )
				 
                 if Tranhead->brcode+Tranhead->trnumber == Trandtls->BRCODE+Trandtls->trnumber       && RED 112204 REPLACED 'Acctdaly->brcode
					do while Tranhead->brcode+Tranhead->trnumber == Trandtls->BRCODE+Trandtls->trnumber
					   if Trandtls->(recno()) == _APalmGL[curr_elem]  //if Trandtls->BRCODE+Trandtls->glcode == _APalmGL[curr_elem]
			                 fEras100m( !.t.,curr_elem)
							 aSubrecs  := {}
							 _APalmSub := {}
							 _APalmGL  := {}
							 ___GetSubRecs()
					         exit   
					   endif
				    Trandtls->(dbskip())
					enddo
                 endif   
              endif
			  
			  if !Trandtls->(dbseek(Tranhead->BRCODE+Tranhead->trnumber))
                  __keyboard( chr( K_ENTER ) )
	              mPASS := .T.
			  endif
			  
			  return 1

   endcase
   
RETURN 2

////
*********************************************
*
static function fGete100m( addedit,curr_elem )
*********************************************
/// DBP replaced with OL      jbs 10.25.2002
/// FSF replaced with AUTOL   jbs 10.25.2002

memva gTRANDATE, gUSER_ID

local mrec := recno(), cx, msign := !.t., yy_:= .f. ,mfacil:='', glMISSING := .f.
local getlist := {}, mscreen := savescreen( ,,, ), mcolor := setcolor(),xx_
local ach_ := { 'LCR           -1', 'ML            -2', 'IPP           -3', 'RP            -4',;
                'AUTOL         -5', 'OL            -6', 'CML           -7', 'DOC. STAMP/ETC-8',;
                'OTHERS        -9','OLOALP        -10',;
                'OL-PLOANS     -11';
              }
local ach2_:= { '1. Normal   ',;
                '2. Memo     ',;
                '3. Cancelled' }
				
private mjvnumber,Xmjvnumber, aDTLS := {}, lDO := .t.
private arr_ := fInit100m( addedit )


mJVNUMBER := g_PAR_BRCH+repl( 'X', len(TRANHEAD->TRNUMBER) )

do while lDO // JV LOOP
	
	if alias() == upper( 'Tranhead' )
	   arr_[34] := if(addedit == 'a',fgetfctly(Acctdaly->Fcltycode),arr_[34] )        && EVR 25092006 - before arr_[ 13 ]
	   arr_[ 1] := gTRANDATE                                                          && EVR 25092006 - before arr_[  2 ]
	   cx := eval( { | xx | xx := if( addedit $ 'e',                             ;
					   fWind100m( 09, 5, 22, 78, 'w+/gr', ' Edit ', 'bg+/gr' ),  ;
					   fWind100m( 09, 5, 22, 78, 'w+/g' , ' Add ' , 'bg+/g'  ) ),;
					   xx                                                        ;
				   } )

	mJVNUMBER := if ( UPPER(ADDEDIT) != 'A',;
				   TRANHEAD->BRCODE+TRANHEAD->TRNUMBER,;
					mJVNUMBER ;
					)


	   @ 10, 6 say '          JV Number ¯' ;
			   get mJVNUMBER pict '@R 999-99999999' when .f.
		 
	   @ 11, 6 say ' Transaction Amount ¯' gget arr_[ 6 ] calculator picture '999,999,999.99'  when eval( { || arr_[ 6 ]:=if( addedit == 'a', agetCredamt(Acctdaly->Credamt,Acctdaly->RV,Acctdaly->Principal,Acctdaly->Fcltycode), arr_[ 6 ] ),.t. } ) ;
										   valid lastkey() == K_UP .or. !empty(Arr_[ 6 ])
	   @ 12, 6 say '   Transaction Date ¯' get arr_[ 1 ] picture '@D' when .f. valid !empty( arr_[ 1 ] )     && EVR 25092006 - before arr_[ 2 ]
	   @ 13, 6 say '   Transaction Type ¯' get arr_[ 5 ] picture '9'            ;     && EVR 25092006 - before arr_[ 4 ]
			   when eval( { || arr_[ 5 ] :=                             ;
					 substr( ach2_[ max( fAcho100m( 12, 28, 16, 42,               ;
					 ach2_, arr_[ 5 ] ), 1 ) ], 1,1 ),;
					 if(lastkey() <> K_ESC,fTran100m( 13, 31, substr( ach2_[ val( arr_[ 5 ] ) ],4,9), cx ) ,nil), .f. } )
					 
					 
					 
	   @ 14, 6 say '      Facility Type ¯' get arr_[ 34 ] picture '99'            ;    && EVR 25092006 - before arr_[ 13 ]
			   when  addedit == 'a' .and. eval( { || arr_[ 34 ] :=                             ;
					 substr( ach_[ max( fAcho100m( 12, 28, 18, 43,               ;
					 ach_, arr_[ 34 ] ), 1 ) ],16,2 ),;
					 if(lastkey() <> K_ESC,fTran100m( 14, 31, substr( ach_[ val( arr_[ 34 ] ) ],1,14), cx ) ,nil), .f. } )
	 //
	 //          valid eval( { || if( arr_[ 4 ] $ '1_2_3_4_5_6_7_8', eval( { ||               ;
	 //                fTran100m( 12, 30, padr( ach_[ val( arr_[ 4 ] ) ], 6 ), cx ), !.f. } ),;
	 //                !.t. ) } )
	 //
		
		
	if addedit == 'e' .and. xFIRSTJV == TRANHEAD->trnumber
		@ 15, 6 say '        Particulars ¯ ' color 'bg+/gr'
		@ 15, col() say arr_[  7 ] picture '@!S50' color 'gr+/gr'
		@ 16, 6 say '                    ¯ ' color 'bg+/gr'
		@ 16, col() say arr_[  8 ] picture '@!S50' color 'gr+/gr'
	else		
		@ 15, 6 say '        Particulars ¯' gget arr_[  7 ] picture '@!S50' when lastkey() <> K_ESC .and. !empty(xFIRSTJV) 
		@ 16, 6 say '                    ¯' gget arr_[  8 ] picture '@!S50' when lastkey() <> K_ESC .and. !empty(xFIRSTJV) 
	endif

	if addedit == 'e'
		@ 15, 6 say '        Particulars ¯ ' color 'bg+/gr'
		@ 15, col() say arr_[  7 ] picture '@!S50' color 'gr+/gr'
		@ 16, 6 say '                    ¯ ' color 'bg+/gr'
		@ 16, col() say arr_[  8 ] picture '@!S50' color 'gr+/gr'
		@ 17, 6 say '                    ¯ ' color 'bg+/gr'
		@ 17, col() say  arr_[ 18 ] picture '@!S50' color 'gr+/gr'
		@ 18, 6 say '                    ¯ ' color 'bg+/gr'
		@ 18, col() say arr_[ 19 ] picture '@!S50' color 'gr+/gr'
		@ 19, 6 say '                    ¯ ' color 'bg+/gr'
		@ 19, col() say arr_[ 20 ] picture '@!S50' color 'gr+/gr'
		@ 20, 6 say '                    ¯ ' color 'bg+/gr'
		@ 20, col() say arr_[ 22 ] picture '@!S50' color 'gr+/gr'
		@ 21, 6 say '                    ¯ ' color 'bg+/gr'
		@ 21, col() say arr_[ 23 ] picture '@!S50' color 'gr+/gr'
	endif
	
		@ 17, 6 say '                    ¯' gget arr_[ 18 ] picture '@!S50' when lastkey() <> K_ESC .and. !empty(xFIRSTJV)    && EVR 25092006 - before arr_[  9 ]
		@ 18, 6 say '                    ¯' gget arr_[ 19 ] picture '@!S50' when lastkey() <> K_ESC .and. !empty(xFIRSTJV)    && EVR 25092006 - before arr_[ 10 ]
		@ 19, 6 say '                    ¯' gget arr_[ 20 ] picture '@!S50' when lastkey() <> K_ESC     && EVR 25092006 - before arr_[ 11 ]
		@ 20, 6 say '                    ¯' gget arr_[ 22 ] picture '@!S50' when lastkey() <> K_ESC .and. !empty(xFIRSTJV)    && EVR 25092006 - before arr_[ 14 ]
		@ 21, 6 say '                    ¯' gget arr_[ 23 ] picture '@!S50' when lastkey() <> K_ESC     && EVR 25092006 - before arr_[ 15 ]
	else

	   if addedit == 'e'
		  arr_[ 4 ] := _APalmSub[curr_elem]
	   endif
	   cx := eval ( { | xx | xx := if( addedit $ 'e',                             ;
						fWind100m( 14, 5, 17, 55, 'w+/gr', ' Edit ', 'bg+/gr' ),  ;
						fWind100m( 14, 5, 17, 55, 'w+/g' , ' Add ' , 'bg+/g'  ) ),;
						xx                                                        ;
					} ;
				  )

	   @ 15, 6 say 'Account Code ¯' ;
			   gget arr_[ 2 ]       ;
			   picture '@R 999-99-99-9999'       ;
			   when eval ( { || arr_[ 2 ] := fOrdr100m( addedit, arr_[ 2 ]), ;
								if( lastkey() <> K_ESC,;
									fAcct100m( arr_[ 2 ], cx, 15),nil),;
									.f. ;
						   };
						 )
						 
	   @ 16, 6 say '      Amount ¯' gget arr_[ 4 ] calculator picture '999,999,999.99' when lastkey() <> K_ESC ;
			   valid eval( { || fAmnt100m( addedit, @arr_,curr_elem ) } )
	endif
	
	setcursor( 3 )
	setkey( K_ESC, { || fEscape( 'Abort?') } )
	read  //timeout 20 exitevent blankscr3( -1 )
	getlist:={}
	setkey( K_ESC, nil )
	setcursor( 0 )
	
	if lastkey() != K_ESC
	   lERR := .f.     // EVR 15122006 - additional
	   lSAVEJV := .f.

		if lower(addedit) == 'a' .and. alias() == upper('Tranhead')
			if Tranhead->(dbseek(g_PAR_BRCH+arr_[2]))
				Error('Error:JV number ' + arr_[2] + ' already exist..!!!!')
				lERR := .t.
			endif
		endif
		
		if !lERR

			if confirm ( 'Are all entries correct?' )
			//if netlock( if( addedit == 'a', 'A', 'R' ), 0 )
			MSGWIN(12,36,'Saving','W+/BG','R*/BG','ON')
			if alias() == upper( 'Tranhead' )	
				if arr_[ 5 ] == '1'     && EVR 25092006 - before arr_[ 4 ]
		//          if( addedit == 'e',( yy_:= Trandtls->(dbseek(Amsjvh->Trnumber))),nil )   abb 10.19.2004
						if !lJVFOUND .or. xFIRSTJV == TRANHEAD->trnumber// for first JV 
							if addedit == 'e'
								TRANDTLS->(ordsetfocus(1))
								yy_:= Trandtls->(dbseek(Acctdaly->brcode+(IF( UPPER(addedit) == 'A', Xmjvnumber, RIGHT(mjvNUMBER,8) ) )))
								xDTRECNO := TRANDTLS->(recno())
								nDTCNT := 0

								//TRANDTLS->(dbgoto(xDTRECNO))
								
							endif	
							  
							
						   //if (  Tranhead->Fcltytype == '8',;
						   if (  arr_[ 34 ] == '8',;
								 eval({ || mfacil := fgetfctly(Acctdaly->Fcltycode) } ),;
								 nil ;
							  )
							
							xnRECNO := 0
							
							
							if arr_[ 34 ] == '9' .or. arr_[ 34 ] == '10'
								lSAVEJV := .t.
							else
							//alert(Acctdaly->brcode + arr_[ 34 ] + mfacil)
								if !Amsgl->( dbseek( Acctdaly->brcode + arr_[ 34 ] + mfacil ) )   && RED 112204 REMOVED 'Acctdaly->brcode
									alert('Facilities are missing in AMSGL!!')
									//lDO := .f.
									
									//mSIGN := .t.
									loop
									return .t.
								else
									xnRECNO := Amsgl->(recno())
								endif
								
							    xx_:=select()

								xnCTR  := 0
								nDR    := 0
								nCR    := 0
								aDTLS  := {}
								nFLOAT := 0
								lCAP := .f.
								
								//while Amsgl->jvtype == Tranhead->Fcltytype .and. alltrim(Amsgl->Docfclty) == alltrim(mfacil) .and. ;
								while alltrim(Amsgl->jvtype) == alltrim(arr_[ 34 ]) .and. alltrim(Amsgl->Docfclty) == alltrim(mfacil) .and. ;
									Amsgl->brcode == Acctdaly->BRCODE    
										aADD(aDTLS,{Tranhead->trnumber,Amsgl->glcode,Amsgl->drcr,'1',(eval( &('{ || '+ Amsgl->formula +'}') )),AMSGL->BRCODE})
									Amsgl->(dbskip(+1))
								enddo	 
								
								for i := 1 to len(aDTLS)
								
									if !GLCODE->(dbseek(aDTLS[i][6]+aDTLS[i][2]+aDTLS[i][3]))
										glMISSING := .t.
										alert ( "GLCODE < "+ aDTLS[i][2]+ " > in AMSGL was not found in Chart of Accounts. "+;
												"Please contact the Accounting Department for clarifications..  ",,'W+/RB' )
										//exit
									endif
									
									if aDTLS[i][3] == '1'
										nDR += round(aDTLS[i][5],2)
									else	
										nCR += round(aDTLS[i][5],2)
									endif
									
								next i
									
									//alert( str(ndr)+'   '+str(ncr))
								if glMISSING
									//WARN("GLCODES  in AMSGL not found in Chart of Accounts. Pls. Contact the Accounting Dept.",1)
									
								elseif round(nDR,2) <> round(nCR,2)
									
									//WARN("Debit: "+ trans(nDR,'999,999,999.99') + " is not equal to Credit: " + trans(nCR,'999,999,999.99'),1)
									
									unBALANCED(nDR,nCR)
									
									dbselectarea(xx_)
									mSIGN := .t.
								elseif nDR == 0.00 .and. nCR == 0.00
									Error("Debit and Credit side are both 0.00 !!")
									//return .F.
									dbselectarea(xx_)
									mSIGN := .t.
								else
									lSAVEJV := .t.
								endif	
								
								Amsgl->(dbgoto(xnRECNO))
							endif
						else
							lSAVEJV := .t.
						endif
							
						if lSAVEJV // Saving Jv with Entries if nothing goes wrong.. //RLV
						
							save_JVHEAD(addedit)
							
							if !lJVFOUND //first booking..
								xFIRSTJV := TRANHEAD->trnumber
							endif	
							
							if !lJVFOUND .and. (xFIRSTJV == TRANHEAD->trnumber .and. arr_[ 34 ] != '9' .and. arr_[ 34 ] != '10' ) // for first JV )
								
								if yy_ 
									do while TRANHEAD->BRCODE+TRANHEAD->TRNUMBER == TRANDTLS->brcode+TRANDTLS->trnumber 
										nDTCNT++
										
										if Trandtls->( netlock('R' ,5) )
											Trandtls->(dbdelete())
											Trandtls->(dbunlock())
										endif	
											Trandtls->(dbcommit())
										TRANDTLS->(dbskip(1))
									enddo
								endif
								
								while Amsgl->jvtype == Tranhead->Fcltytype          .and. ;
									 alltrim(Amsgl->Docfclty) == alltrim(mfacil) .and. ;
									 Amsgl->brcode == Tranhead->BRCODE      && RED 112204 REPLACED 'Acctdaly->brcode
									 //dbselectarea ( 'Trandtls' )
										
											//Editing will be deleting the old details to be replaced by new appended ones RLV 2:09 PM 6/19/2013
										
											Trandtls->(netlock('A',0))  //( netlock( if( addedit == 'a'.or. !yy_ .or. nFLOAT > nDTCNT , 'A', 'R' ),0) )
											Trandtls->trnumber := Tranhead->trnumber
											Trandtls->glcode   := Amsgl->glcode
											Trandtls->drcr     := Amsgl->drcr
											Trandtls->amount   := eval( &('{ || '+ Amsgl->formula +'}') )
											Trandtls->TRANCODE := '1'     && EVR 25092006
											Trandtls->brcode   := AMSGL->BRCODE        && RED 112204 REPLACED 'Acctdaly->brcode    // abb 10.19.2004
											Trandtls->(dbunlock())
										
									/*if addedit == 'e'
										if Trandtls->(!eof())
											Trandtls->(dbskip(+1))
										endif
									endif	*/
									   
									 Amsgl->(dbskip(+1))
								enddo
								
								Trandtls->     ( dbcommit() )
							endif	
						   lDO := .f.
						   lJVFOUND := .t.
						endif   
						   dbselectarea(xx_)
					elseif arr_[ 5 ] == '2' .and. addedit == 'e'     && EVR 25092006 - before arr_[ 4 ]
					   del_Trn_JV( ARR_[3]+arr_[2] )              && EVR 25092006 - before arr_[ 16 ] + arr_[ 3 ]
					endif
			else
				  //aga.05.01.2005.editing booking jv drop

					drop(alltrim(g_user_id)+" edits JV#"+Tranhead->Trnumber+" dated "+dtos(Tranhead->trandate)+" from ")
					drop(" glcode "+Trandtls->glcode+" to "+arr_[ 2 ] + " drcr "  +Trandtls->drcr+" to "+arr_[ 3 ])
					drop(" amount "+str(Trandtls->amount)+" to "+str(arr_[ 4 ]))
				  //........................
					if Trandtls->(netlock( if( addedit == 'a', 'A', 'R' ), 0 ))
					   Trandtls->brcode   := Acctdaly->brcode
					   Trandtls->trnumber := arr_[ 1 ] := Tranhead->trnumber
					   Trandtls->glcode   := arr_[ 2 ]
					   Trandtls->drcr     := arr_[ 3 ]
					   Trandtls->amount   := arr_[ 4 ]
					   Trandtls->TRANCODE := '1'     && EVR 25092006
					   zax := Tranhead->Trnumber
					   msign := .t.
					   Trandtls->( dbunlock() )
					   Trandtls->( dbcommit() )
					endif
				// endif 
					lDO := .f.
			endif
				
			MSGWIN(12,36,'Saving','W+/BG','R*/BG','OFF')
			ENDIF    // END OF CONFIRM	
		endif     // END OF lERR

	else

	   IF ALIAS() == upper( 'Trandtls' )
		  IF !Trandtls->(dbseek(Tranhead->BRCODE+Tranhead->Trnumber))
			 __keyboard( chr( K_ENTER ) )
			 mPASS := .T.
		  ENDIF
	   ENDIF
	   
	   inkey( .5 )
	   dbgoto( mrec )
	   if alias() == upper( 'Tranhead' )
		  msign := !.f.
	   endif
		lDO := .f.
	endif
enddo	

restscreen( ,,,, mscreen )
setcolor( mcolor )
return( msign )

********************************
static function save_JVHEAD(addedit)
********************************

	if upper(addedit) == 'A'
		if !jventry
			if Ol_param->(dbseek(g_PAR_BRCH))
				if Ol_param->(netlock('R', 0))
					XmJVNUMBER := ltrim(str(val(Ol_param->LASTJVNO)+1)) 
					Ol_param->LASTJVNO := XmJVNUMBER  		       //:= 	right('0000'+ltrim(str(val(Ol_param->LASTJVNO)+1)),8)
					Ol_param->(dbunlock())	   
				endif
				Ol_param->(dbcommit())
			endif
	   jventry := .t.
		endif
	endif

		if Tranhead->(netlock( if( addedit == 'a', 'A', 'R' ), 0 ))
		
			Tranhead->trandate   := arr_[  1 ]                                          && EVR 25092006 - before arr_[  2 ]
			Tranhead->trnumber   := IF( UPPER(addedit) == 'A', Xmjvnumber, RIGHT(mjvNUMBER,8) ) 
			Tranhead->brcode     := Acctdaly->brcode
			Tranhead->TRANCODE   := '1'                                                 && EVR 25092006
			Tranhead->trantype   := arr_[  5 ]                                          && EVR 25092006 - before arr_[  4 ]
			Tranhead->tramount   := arr_[  6 ] //:= Acctdaly->principal                 && EVR 25092006 - before arr_[  5 ]
			Tranhead->partix1    := arr_[  7 ]
			Tranhead->partix2    := arr_[  8 ]
			Tranhead->usercode   := arr_[  9 ] := gUSER_ID                              && EVR 25092006 - before arr_[ 12 ]
			Tranhead->ADJMNTCODE := '7'                                                 && EVR 25092006
			Tranhead->ORIGIN     := .t.                                                 && EVR 25092006
			Tranhead->partix3    := arr_[ 18 ]                                          && EVR 25092006 - before arr_[  9 ]
			Tranhead->partix4    := arr_[ 19 ]                                          && EVR 25092006 - before arr_[ 10 ]
			Tranhead->partix5    := arr_[ 20 ]                                          && EVR 25092006 - before arr_[ 11 ]
			Tranhead->partix6    := arr_[ 22 ]                                          && EVR 25092006 - before arr_[ 14 ]
			Tranhead->partix7    := arr_[ 23 ]                                          && EVR 25092006 - before arr_[ 15 ]
			Tranhead->post_date  :=  IF( UPPER(addedit) == 'A', date(),Tranhead->post_date ) //pepe 06.27.2007 
			Tranhead->trloanno   := arr_[ 33 ] := subs( Acctdaly->acctno, -5, 5 )       && EVR 25092006 - before arr_[  1 ]
			Tranhead->Fcltytype  := if(arr_[ 34 ] == '10','0',arr_[ 34 ])                && EVR 25092006 - before arr_[ 13 ]
				  // EVR      Amsjvh->trstatus := arr_[  6 ] := '1'

			Tranhead->approved   := .T.        // MVCAMPOS - Tempo Lang - 2009.09.14 (Default Should Be .F.)

			Tranhead->(dbunlock())
			Tranhead->(dbcommit())
		endif
//PEPE 11.21.2007

		if lower(ADDEDIT) == 'a'

			IF JV_LOG->( netlock( 'A', 0 ) )

			   JV_LOG->brcode     := TRANHEAD->brcode
			   JV_LOG->trnumber   := TRANHEAD->trnumber 
			   JV_LOG->amount     := TRANHEAD->tramount 
			   JV_LOG->trandate   := TRANHEAD->trandate 
			   JV_LOG->post_date  := TRANHEAD->post_date
			   JV_LOG->trancode   := TRANHEAD->trancode
			   JV_LOG->trantype   := TRANHEAD->trantype

				 IF !EMPTY(TRANHEAD->trpayee)
				   JV_LOG->PAYOR      := TRANHEAD->trpayee
				 ELSE
				   JV_LOG->PAYOR      := TRANHEAD->PARTIX1
				 ENDIF

			JV_LOG->( dbunlock() )
		ENDIF
				
				
			if AMSJVLOG->( netlock( 'A', 0 ) )
			   AMSJVLOG->brcode     := TRANHEAD->brcode
			   AMSJVLOG->trnumber   := TRANHEAD->trnumber 
			   AMSJVLOG->acctno     := ACCTDALY->acctno
			   AMSJVLOG->amount     := TRANHEAD->tramount 
			   AMSJVLOG->JVDATE     := TRANHEAD->trandate 
			   AMSJVLOG->postdate   := TRANHEAD->post_date
			   AMSJVLOG->( dbunlock() )
			endif
				
	else
		if JV_LOG->(dbseek(Tranhead->brcode+Tranhead->trnumber))	

			IF JV_LOG->( netlock( 'R', 0 ) )

			   JV_LOG->brcode     := TRANHEAD->brcode
			   JV_LOG->trnumber   := TRANHEAD->trnumber 
			   JV_LOG->amount     := TRANHEAD->tramount 
			   JV_LOG->trandate   := TRANHEAD->trandate 
			   JV_LOG->post_date  := TRANHEAD->post_date
			   JV_LOG->trancode   := TRANHEAD->trancode
			   JV_LOG->trantype   := TRANHEAD->trantype

				 IF !EMPTY(TRANHEAD->trpayee)
				   JV_LOG->PAYOR      := TRANHEAD->trpayee
				 ELSE
				   JV_LOG->PAYOR      := TRANHEAD->PARTIX1
				 ENDIF

			JV_LOG->( dbunlock() )
			ENDIF
	   endif
			if AMSJVLOG->(dbseek(Tranhead->brcode+ACCTDALY->acctno+Tranhead->trnumber))						
				if AMSJVLOG->( netlock( 'R', 0 ) )
				   AMSJVLOG->brcode     := TRANHEAD->brcode
				   AMSJVLOG->acctno     := ACCTDALY->acctno
				   AMSJVLOG->trnumber   := TRANHEAD->trnumber 
				   AMSJVLOG->amount     := TRANHEAD->tramount 
				   AMSJVLOG->JVDATE     := TRANHEAD->trandate 
				   AMSJVLOG->postdate   := TRANHEAD->post_date
				   AMSJVLOG->( dbunlock() )
				endif
			endif
			AMSJVLOG->( dbunlock() )
	endif	    

	zax := Tranhead->Trnumber
	
	AMSJVLOG->(DBCOMMIT() )
	JV_LOG->(DBCOMMIT())
	Tranhead->( dbunlock() )
	Tranhead->( dbcommit() )

return

/*-----------------------------------*/
 Static Function fgetfctly(Fcode)
/*-----------------------------------*/
local nretval
do case
   case fcode == '10301'
        nretval := '1'
   case fcode == '10401'
        nretval := '2'
   case fcode == '10402'
        nretval := '3'
   case fcode == '10403'
        nretval := '4'
   case fcode == '10405'
        nretval := '5'
   case fcode == '10404'
        nretval := '6'
   case fcode == '10407'
        nretval := '7'
   case fcode == '10413'                    //PEPE 09.01.2008
        nretval := '10'
		
endcase
return if(nretval == nil,'8',nretval )

/*--------------------------------------------------*/
 Static Function agetCredamt(mCredamt,mRV,mPrincipal,mfacil)
/*--------------------------------------------------*/
local nretval:=0,rvamt:= 0,flc:=eval( { || Facility->(dbseek(mfacil)), Facility->Setcode} )
rvamt := ( mRv/100 ) * mprincipal
nretval := if(flc == '1',mCredamt + Rvamt,mCredamt )
return nretval

*****************************************           abb 10.19.2004
*
*
Function fJvgetno( arr2,ordset )
*****************************************
local nretval := .t.
local nrec:=Tranhead->(recno()),bf:=select()     //EVR ,nord:=amsjvh->(indexord())

ordset:=if( ordset = nil, 2, ordset )
arr2:=right('00000000'+ Alltrim(arr2), 8 )
//dbselectarea('amsjvh')
//EVR Amsjvh->( dbsetorder(2) )
if Amsjvh->( dbseek( g_PAR_BRCH+arr2 ) )     && RED 102705   Acctdaly->brcode
   Error('Error:JV number ' + arr2 + ' already exist..!!!!')
   nretval:=.f.
elseif FMSjvh->(dbseek( g_PAR_BRCH+arr2 ))     && RED 102705   Acctdaly->brcode
   Error('Error:JV number ' + arr2 + ' already exist..!!!!')
   nretval:=.f.
// EVR elseif PLSjvh->(dbseek( g_PAR_BRCH+arr2 ))     && RED 102705   Acctdaly->brcode
// EVR    Error('Error:JV number ' + arr2 + ' already exist..!!!!')
// EVR    nretval:=.f.
elseif Tranhead->( dbseek( g_PAR_BRCH+arr2 ) )     && RED 102705   Acctdaly->brcode     && EVR 25092006 - removed + '1'
   Error('Error:JV number ' + arr2 + ' already exist..!!!!')
   nretval:=.f.
// EVR elseif Tranhead->(dbseek( g_PAR_BRCH+arr2 + '3' ) )     && RED 102705   Acctdaly->brcode
// EVR    Error('Error:JV number ' + arr2 + ' already exist..!!!!')
// EVR    nretval:=.f.
elseif Gltranhd->(dbseek( g_PAR_BRCH+arr2 + '1' ) )     && RED 102705   Acctdaly->brcode
   Error('Error:JV number ' + arr2 + ' already exist..!!!!')
   nretval:=.f.
elseif Glhdback->(dbseek( g_PAR_BRCH+arr2 + '1' ) )     && RED 102705   Acctdaly->brcode
   Error('Error:JV number ' + arr2 + ' already exist..!!!!')
   nretval:=.f.
endif
dbselectarea(bf)
Tranhead->(Dbgoto(nrec))
//EVR amsjvh->(dbsetorder(nord))
return nretval

////
static function fwholeno( pvalue )
local mvalue := pvalue

if round( mvalue, 2 ) > int( mvalue )
   mvalue := int( mvalue ) + 1
endif
return( mvalue )   

////
static function fAcho100m( _1, _2, _3, _4, ma_, mb_ )
local max, mzz, mex := setkey( K_ESC, nil ) 
local mxx := 1, mc_, md_ := 1, ax := if( len( ma_ ) > 3, 16,2 )
local msel := if(len(ma_) == 3, {.t.,.t.,.f.},nil )
md_:=if(mb_ == nil, 1, val(mb_) )
mzz := savescreen( _1, _2, _3 + 1, _4 + 2 )

fShadow( _1, _2, _3, _4, 2, 'n/w' )
if ( mxx := ascan( ma_, { | v | subs( v, ax, 1 ) == mb_ } ) ) > 0
   mc_ := mxx      
else         
   mc_ := mxx  
endif

while .t.
   max := achoice( _1 + 1, _2 + 1, _3 - 1, _4 - 1, ma_,msel,,mc_,md_ )
   if lastkey() <> K_LEFT .and.  Lastkey() <> K_RIGHT
      exit
   endif
enddo

restscreen( _1, _2, _3 + 1, _4 + 2, mzz )
setkey( K_ESC, mex )
return( max )

////
//ÄÄÄdescúúúlook-up table
//ÄÄÄparaúúúcax - add or edit, "a" or "e" respectively
//ÄÄÄ        dx - account code
//ÄÄÄretuúúúaccount code
*****************************************
*
*          abb 10.19.2004
*
static function fOrdr100m( cax, dx )
*****************************************
local db, ax, cx, ex := setcursor( setcursor() )  
local col_ := {                                                          ;
                tbcolumnnew( 'Account Title',                            ;
                  { || transform( Glcode->glname, '@!' ) } ),            ;
                tbcolumnnew( 'Code'         ,                            ;
                  { || transform( Glcode->glcode, '@R 999-99-99-9999' ) } ),;
                tbcolumnnew( 'Class'        ,                            ;
                  { || if( Glcode->gldrcr $ '2', 'Cr', 'Dr' ) } )        ;
              } 

private nCLIENT := space(11)
setcursor( 0 )

while .t.

      Glcode->(ordsetfocus( 1 ))

  ax := getTranrecs(1)	//PEPE 09.28.2007
  ax := nCLIENT		//PEPE 09.28.2007


      GLCODE->(dbsetorder(1))
      Glcode->(dbseek( Acctdaly->brcode+ax ))      //  abb 03.01.2005

      if lastkey() == K_ESC
         ax := if ( cax $ 'a', repl( '0', 9 ), dx )
         exit
      endif

      if Glcode->brcode != Acctdaly->brcode
         waiton( 'Invalid branch code!',, 'w+/r' )
         inkey( .5 )
         waitoff()
         loop
      endif
	  
/*	if __JVSYSAX(GLCODE->brcode+ax,GLCODE->ENTERED)
	
    else
		loop
	endif	 */
	  
     // if fGoodlevel( Glcode->gLevel )//Glcode->glevel $ '3_4'   //aga.27.05.2008.glcode index fix //fGoodlevel( 'Glcode',1,Glcode->gLevel )
         exit
     // else
     //    waiton( 'Unable code!',, 'w+/r' )
     //    inkey( .2 )
     //    waitoff()
     // endif

enddo
        
setcursor( ex )                                        
return( ax )

*-------------------------------------------------------------------------------
static FUNCTION __JVSYSAX(cACCTCODE,_entered)

local nretval := .f.


if _entered == 'S'
	if !JVSYSAX->(dbseek(gUSER_ID+cACCTCODE))
		alert('ACCESS DENIED!! Fill-up a GLCODE Access Form and forward it to ICT Division, QAASD for approval and access of the said GLCODE.')
	else
		nretval := .t.
	endif
else
	nretval := .t.
endif

return nretval

*******************************
*
function GetTranRecs(lfound,nVAR)
******************************
local mcolor  := setcolor(), mscreen := savescreen( ,,, ), mlogic := .t., mm := INDEXORD(),zz := ALIAS()
private nPREVSELECT := 0, PRO := 0,PROS := .F., nTOP := .F.,mPRESS := .F.,mRECNO := 0, _keys, nVAR2

 aTranrecs := {}
 aTranpos  := {}
 _APalmSec := {}
 aRECNO    := {}

do case

case lfound == 1

 fShadow( 5, 4, 22, 75, 2, 'w+/g' ) //w+/GR

 dbselectarea('GLCODE')
 GLCODE->(dbseek(g_par_brch))
// mGlname := Glcode->Glname
 mRECNO := Glcode->(RECNO())

 ___GetTranRecs(1)

     setcolor ( 'i/gr, w+/bg' )


     @ 5,6  say 'GLCODE'						  color 'gr+/g'
     @ 6,20 say  'GLNAME                              BRCODE   GLCODE'   color 'w+/g'
     @ 7,5 to 7,74								  color 'w+/g'
     @ 22,46 say '[PGDN]-NEXT' 					  		  color 'bg+/g'
     @ 22,59 say '[PGUP]-PREVIOUS'     					  	  color 'bg+/g'

     do while .t.
      mBX := achoice(8,5, 22, 74, aTranRecs, .t.,'AMSFUNC')

      do case
         case lastkey() == K_ESC
               exit
  
         case lastkey() == K_ENTER
	      if mPRESS
                 exit
	      endif
	    
      endcase
     enddo

   setcolor       ( mcolor )
   restscreen     ( ,,,, mscreen )

endcase

DBSELECTAREA(ZZ)
DBSETORDER(mm)

return mBX

**************************************
*
STATIC FUNCTION ___GetTranRecs(lfound,nVAR2)
**************************************
//LOCAL NCTR := 0, NCTR2 := 0
local NCTR := 0


DO CASE

 CASE lfound == 1

  _keys := 1

  dbselectarea('GLCODE')
  Glcode->(dbsetorder(3))

  GLCODE->(dbGOTO(mRECNO))

      do while   GLCODE->brcode == g_par_brch .and. ;
		 !GLCODE->(eof()) 

		   nctr++

        	    aadd ( aTranRecs,  padr(' ',' ')   		+ ' '  +  ;
                           padr ( GLCODE->GLNAME,50)        	+ '  ' +  ;
                           padr ( GLCODE->BRCODE,3)		+ '  ' +  ;
                           padr ( GLCODE->GLCODE,11)  	        + ' '     ;
              	         )

		    aadd ( _APalmSec,GLCODE->brcode+GLCODE->glname)

		  if !nTOP

		    IF alltrim(str(NCTR)) == '1'
		       pro++

		      if pro > len(aRECNO) 
		         AADD ( aRECNO,{GLCODE->(RECNO()),0} )
		      ENDIF

		    endif

		  endif


		IF nctr > 13
           		exit
		endif

         	GLCODE->(dbskip(+1))
      enddo
  ENDCASE

RETURN

****************************************************
*
FUNCTION AMSFUNC (status, curr_elem, curr_row)
****************************************************
local key    := lastkey(),mSAY,cSRCH := space(10)
local __nctr := 0, getlist := {}, menulist := {},nORGPOS := 0
local _lfound := .f., mscreen1 := savescreen1( ,,, ), INDKEY := INDEXORD()

DO CASE

 CASE _keys == 1

   do case
      case key == K_ESC
         return 0

      case key == K_ENTER

	mPRESS := .T.

	__mseekvar := _APalmSec[curr_elem]

	if GLCODE->(dbseek(__mseekvar))

	  IF GL_DEPO->(DBSEEK(g_PAR_BRCH+GLCODE->GLCODE)) //pepe 01.16.2008

	    if gTRANDATE > FLAG->LASTCLOSED .and. TIME() <= ALLTRIM(FLAG->closing)
	       nClient := GLCODE->glcode
	    ELSE
	       ERROR('TRANSACTION FOR '+DTOC(FLAG->LASTCLOSED)+' IS ALREADY CLOSED!')
	    ENDIF
	  else
	    nClient := GLCODE->glcode
	  endif
	endif

	return 0

      case key >= 32 .and. key <= 254

        Glcode->(dbsetorder(3))

	lchar	:= upper(chr(lastkey()))
	nORGPOS := recno()

        __keyboard(lchar)

	@22,6  say 'SEARCH ' 			color 'w+/g'	
	@22,16 get cSRCH pict '@!' 	color 'w+/g'


	setcursor( 3 )
	read
	setcursor( 0 )


        restscreen1     ( ,,,, mscreen1 )

	if lastkey() == K_ENTER

	mPRESS := .F.

	   if GLCODE->(dbseek(g_Par_Brch + rtrim(cSRCH))) // GLCODE->(dbseek(g_Par_Brch+lchar+rtrim(cSRCH)))

  	       mRECNO := GLCODE->(RECNO())

               aTranRecs   := {}
               _APalmSec   := {}
               ___GetTranRecs(1)

               @ 8,5 clear to 21, 74

	   else
		error('GLNAME not found!')
		dbgoto(nORGPOS)
	   endif

	endif

	//GLCODE->(dbsetorder(indkey))

	return 0

      case key == K_PGUP

	nTOP 	   := .T.
        IF(alltrim(str(pro)) == '1',pros := .T.,pro--)

	if pros   // GLCODE->(bof()) .OR. GLCODE->BRCODE != g_PAR_BRCH
          mSAY := 'BEGINNING OF FILE'    
          WAITON( mSAY,, 'W+/R' )
          // INKEY( 1 )
          WAITOFF()
	  pros := .F.
	endif

	dbgoto(aRECNO[pro][1]) //GLCODE->(dbgoto(aRECNO[pro][1]) )

	if GLCODE->brcode == g_PAR_BRCH 
 	mRECNO := GLCODE->(RECNO())

               aTranRecs   := {}
               _APalmSec   := {}
               ___GetTranRecs(1)

               @ 8,5 clear to 21, 74
	endif

	return 

      case key == K_PGDN

	nTOP := .F.
	GLCODE->(dbskip(+1))

	if GLCODE->(eof()) .OR. GLCODE->BRCODE != g_PAR_BRCH
          mSAY := 'END OF FILE' 
          WAITON( mSAY,, 'W+/R' )
          //INKEY( 1 )
          WAITOFF()
	endif

	 if GLCODE->brcode == g_PAR_BRCH 
 	 mRECNO := GLCODE->(RECNO())
               aTranRecs   := {}
               _APalmSec   := {}
               ___GetTranRecs(1)

               @ 8,5 clear to 21, 74
	endif

        return


    endcase

 ENDCASE

RETURN  2

////
/* EVR 01022007 - no use
static function fPara100m( cax, ar_ )
local mdbf := fZipp100m(), xx := ar_ 

dbselectar( 'Parametr' )
if netlock( 'R', 0 ) .and. cax $ 'a' 
           
   //ÄÄÄÄ replacing field value
   
   _field->Parametr->lastjv := ( xx := Parametr->lastjv + 1 )
   dbcommit()
   xx := padl( xx, 8, '0' )
endif
dbunlock()
fUnzp100m( mdbf )

UPDT_OL()         && RED 033005

return( xx )
*/

////
//ÄÄÄdescúúúdetermine if cr is greater than dr, 
//ÄÄÄ                 if both dr & cr are equal to zero
//ÄÄÄparaúúúaddedit - add or edit, "a" or "e" respectively
//ÄÄÄretuúúúlogical
****************************************************
*
*
static function fAmnt100m( addedit, mdrcr_,curr_elem)
****************************************************
local mamount := Tranhead->tramount, mdr := 0.00, mcr := 0.00

local mtrue := !.t., mdbf := fZipp100m(), mvalue

dbseek( Tranhead->BRCODE+Tranhead->trnumber )  && RED 112204 REPLACED 'Acctdaly->brcode

xSum( mdr, mcr )
fUnzp100m( mdbf )        

if addedit $ 'e'
   if Trandtls->drcr $ '1'
      mdr -= _APalmSub[curr_elem]
   else 
      mcr -= _APalmSub[curr_elem]
   endif   
endif

if trans( ( mdr + mdrcr_[ 4 ] ),'999,999,999.99') <= trans( mamount,'999,999,999.99') .and.;
   ( mdr + mdrcr_[ 4 ] ) > 0.00     .and.;
   mdrcr_[ 4 ] > 0.00
   mvalue := '1'
   mtrue := !.f.
endif
   
if trans( ( mcr + mdrcr_[ 4 ] ),'999,999,999.99') <= trans( mamount,'999,999,999.99') .and.;
   ( mcr + mdrcr_[ 4 ] ) > 0.00     .and.;
   mdrcr_[ 4 ] > 0.00 .and. trans( mdr,'999,999,999.99')  == trans(mamount,'999,999,999.99')
   mvalue := '2'
   mtrue := !.f. 
endif   
if addedit $ 'a'
   mdrcr_[ 3 ] := mvalue
endif   
return( mtrue )   

////
static function fAcct100m( ax, cx,nrow )
@ nrow, 36 say padr( Glcode->glname, 18 ) picture '@!' color cx
return( nil )

////
static function fEras100m( ax,curr_elem )
local  xx, mtrnum := Tranhead->BRCODE+Tranhead->trnumber
memvar lrr, zax
toneone

if yes_no2( 'Erase?',, ' Yes ', ' No ', .f. )
   waiton( 'Deleting...',, 'w+/r' )

	if Trandtls->(netlock( 'R', 0 ))
	   Trandtls->(dbdelete())
	   Trandtls->(dbunlock())
	   Trandtls->(dbcommit())
	endif
	
   inkey( .2 )
   waitoff()  

/** pepe 08.29.2008

   eval( { || ( alias() )->( dbdelete() ),;
              ( alias() )->( dbskip( +1 ) ) } )
   
   if ax
      //alert('jv deletion')
      xx := fZipp100m()
      dbselectar( 'Trandtls' )
      Trandtls->( dbseek( mtrnum ) )  && RED 112204 REMOVED 'Acctdaly->brcode+
      if Trandtls->( netlock( 'R', 0 ) )
         Trandtls->( dbeval(   { || dbdelete() },,;
                             { || mtrnum == Trandtls->BRCODE+Trandtls->trnumber ;     && RED 112204 REMOVED '.and. Trandtls->brcode == Acctdaly->brcode ;
                             } ;
                         ) ;
                 )
      endif
      Trandtls->( dbunlock() )
      fUnzp100m( xx )
      if Tranhead->( eof() )
         Tranhead->( dbgobottom() )
      endif
      lrr := max( 1, lrr-- )
   else
      if Tranhead->brcode+Tranhead->trnumber != Trandtls->BRCODE+Trandtls->trnumber               && RED 112204 REMOVED 'Acctdaly->brcode
         if Trandtls->( dbseek( mtrnum ) )                                                  && RED 112204 REMOVED 'Acctdaly->brcode+
            Trandtls->( dbseek( subs(  mtrnum + Trandtls->drcr,1, len( mtrnum ) + len( Trandtls->drcr ) - 1 ) + ':', .t. ) )                             && RED 112204 REMOVED 'Acctdaly->brcode+
            Trandtls->( dbskip( -1 ) )
         endif  
      endif
   endif

   zax := if(dbseek( Tranhead->BRCODE+ Tranhead->trnumber,.f.),Tranhead->BRCODE+Tranhead->Trnumber,spac(0))    && RED 112204 REMOVED 'Acctdaly->brcode
**/

endif   
return (nil)

////
/*------------------------------------------------------*/
function f100mPrnt()
local   zz := fZipp100m()
local   mt := cmonth( Tranhead->trandate )
local   dy := day   ( Tranhead->trandate )
local   yr := year  ( Tranhead->trandate )
local   sw1:= 0, sw2 := 0, laps := 0
private lg := -1
setprc( 0,0 )
setfont( upper( 'draft' ) )
setfont( upper( 'elite' ) )
@ prow() + 6-1, 00 say '' //microfeed
//@ prow() , pcol()+1 say microfeed
@ prow() , 77+1 say TRANS(Tranhead->BRCODE+Tranhead->TRNUMBER,'@R 999-99999999')
@ prow() +  1, 74 say padc( mt + ' ' + ltrim( str( dy, 2 ) ) +;
                          ', ' + ltrim( str( yr, 4 ) ) , 21 )
@ prow() +  5, 10 say Tranhead->partix1  picture '@!'
@ prow() +  1, 10 say Tranhead->partix2  picture '@!'
@ prow() +  1, 10 say Tranhead->partix3  picture '@!'
@ prow() +  1, 10 say Tranhead->partix4  picture '@!'
@ prow() +  1, 10 say Tranhead->partix5  picture '@!'
@ prow() +  1, 10 say Tranhead->partix6  picture '@!'
@ prow() +  1, 10 say Tranhead->partix7  picture '@!'
@ prow()     , 76 say 'P'
@ prow()     , 77 say Tranhead->tramount picture '99,999,999,999.99'
@ prow() +  1, 76 say repl('Í',len('99,999,999,999.99') + 1 )
@ prow() +  1,  0 say ''
@ prow() +  1,  0 say ''
@ prow() , pcol()+1 say microfeed
@ prow() , pcol()+1 say microfeed
@ prow() , pcol()+1 say microfeed
@ prow() , pcol()+1 say microfeed
Trandtls->( dbseek( Tranhead->brcode+Tranhead->trnumber ) )
Trandtls->( dbeval( { || fPone100m( @sw1,@sw2,@laps ) },,;
                  { || Trandtls->brcode+Trandtls->trnumber == Tranhead->brcode+Tranhead->trnumber } ) )
if laps < 1
  while prow() < 30
      @ prow()+1,00 say ''
  enddo
  //@ prow(),pcol() say microfeed
  @ prow()+2,8 say padc( alltrim(gUser_id),10 )
  @ PROW()  ,70 SAY 'SALES ADMIN'
elseif laps > 1
  otherpage('1')
endif
__eject()
fUnzp100m( zz )
return( nil )

////
static function fPone100m( sw1,sw2,laps )
local ax := 'ORIX METRO LEASING AND FINANCE CORPORATION'
local mt := cmonth( Tranhead->trandate )
local dy := day   ( Tranhead->trandate )
local yr := year  ( Tranhead->trandate )
local bx := mt + ' ' + ltrim( str( dy, 2 ) ) + ', ' + ltrim( str( yr, 4 ) )
local cx := 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
local dx := '³     JOURNAL VOUCHER N§ ' + padr( Tranhead->trnumber, 8 ) + '  ³'
local ex := 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
memva lg

if prow() <= 28 .and. lg <= 0
   if Trandtls->drcr $ '1'
      @ prow(), pcol() say microfeed            && printer font
      @ prow() + 1, 07 say fFind100m( Trandtls->BRCODE+Trandtls->glcode, 50, .t. )      && RED 062805 ADDED 'Trandtls->BRCODE
**      @ prow()    , 61 say if( sw1 < 1, 'P','' )
  **    @ prow()    , 62 say Trandtls->amount picture '99,999,999,999.99'
  ** abb 06.01.2004

      @ prow()    , pcol()+10 say if( sw1 < 1, 'P','' )
      @ prow()    , pcol()+ 1 say Trandtls->amount picture '99,999,999,999.99'

      sw1++
   else
      @ prow(), pcol() say microfeed            && printer font
      @ prow() + 1, 09 say fFind100m( Trandtls->BRCODE+Trandtls->glcode, 50,.t. ) + space(17)       && RED 062805 ADDED 'Trandtls->BRCODE

**      @ prow()    , 76 say if( sw2 < 1, 'P','' )
  **    @ prow()    , 77 say Trandtls->amount picture '99,999,999,999.99'


      @ prow()    , pcol()+10 say if( sw2 < 1, 'P','' )
      @ prow()    , pcol()+1  say Trandtls->amount picture '99,999,999,999.99'

      sw2++
   endif

   if prow() == 28
      laps := 1
      while prow() < 30
         @ prow()+1,00 say ''
      enddo
      @ prow(),pcol() say microfeed
      @ prow()+1,8 say padc( alltrim(gUser_id),10 )
      @ PROW()  ,70 SAY 'SALES ADMIN'
   endif

else
   laps := 2
   
   if lg <= 0
      sw1  := 0
      sw2  := 0
      lg := +1
      setprc( 0,0 )
      __eject()
      @ prow() +  1, ( 96 - len( ax ) ) / 2 say ax
      @ prow() +  1, ( 96 - len( bx ) ) / 2 say bx
      @ prow() +  1, ( 96 - len( cx ) ) / 2 say cx
      @ prow() +  1, ( 96 - len( dx ) ) / 2 say dx
      @ prow() +  1, ( 96 - len( ex ) ) / 2 say ex
      @ prow() +  1,   2 say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
      @ prow() +  1,   2 say '³                   Account Title                    ³      Debit        ³    Credit       ³'
      @ prow() +  1,   2 say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
   endif
   if Trandtls->drcr $ '1'
      @ prow() + 1,  3 say fFind100m( Trandtls->BRCODE+Trandtls->glcode, 45,.t. )       && RED 062805 ADDED 'Trandtls->BRCODE
      @ prow()    , 56 say if( sw1 < 1, 'P','' )
      @ prow()    , 57 say Trandtls->amount picture '99,999,999,999.99'
      sw1++
   else
      @ prow() + 1, 5 say fFind100m( Trandtls->BRCODE+Trandtls->glcode, 45,.t. ) + space(17)        && RED 062805 ADDED 'Trandtls->BRCODE+
      @ prow()    , 76 say if( sw2 < 1, 'P','' )
      @ prow()    , 77 say Trandtls->amount picture '99,999,999,999.99'
      sw2++
   endif               
endif
return( .t. )

***********************
*
function f100mPrnta()
***********************
local   zz := fZipp100m()
local   mt := cmonth( Tranhead->trandate )
local   dy := day   ( Tranhead->trandate )
local   yr := year  ( Tranhead->trandate )
local   sw1:= 0, sw2 := 0, laps := 0
local   dPosDAte := Tranhead->Post_date, tDR:= 0, tCR := 0
private lg := -1
private mpage := 1

setprc( 0,0 )
@ prow() + 1, 00 say ''
setfont( upper( 'draft' ) )
setfont( upper( 'elite' ) )

//prnreptitle( 84, 1,mpage, ' ',;
//                              gBRANCH,gCOMPANY,' ')

@ prow() + 1, 02 say 'ORIX METRO Leasing & Finance Corporation'
@ prow()    , 86 say 'Page :    '+ALLTRIM(STR(MPAGE))
@ prow() + 1, 02 say '('+g_PAR_BRCH+'-'+if(BRANCHES->(DBSEEK(g_PAR_BRCH)),RTRIM(BRANCHES->BRNAME),'BRANCH NOT FOUND')+')' 
@ prow()    , 78 say ctod( str( month(date()),2 )+'/'+str( day(date()),2 )+'/'+str( year(date()),4 ) )
@ prow()    , 89 say time()

setfont('BOLD')
@ prow() +1,37 SAY chr(14)+'JOURNAL VOUCHER'+chr(14)
setfont('UNBOLD')

@ prow() +  2 , 64 say 'JV No.           : '+TRANS(Tranhead->BRCODE+Tranhead->TRNUMBER,'@R 999-99999999')
//@ prow()      , 96 say '(AE)'
@ prow() +  1 , 64 say 'Transaction Date : ' + padR( mt + ' ' + ltrim( str( dy, 2 ) ) +;
                          ', ' + ltrim( str( yr, 4 ) ) , 21 )
@ prow() +  1 , 64 say 'Date Encoded     : ' +padR(cmonth(dPosDate) + " " + ltrim( str(day(dPosDate),2)) + ", " + ltrim(str(year(dPosDate),4)),21)



@ prow() + 3, 02 say chr(15) +padc("Í",89, "Í")+chr(18)+padc("Í", 24 , "Í")+"Ñ"+padc("Í", 20-2 , "Í")
@ prow() + 1, 34 say 'PARTICULARS'
@ prow()     , 77 say chr(15) +space(4)+chr(18)+"³"
@ prow()    , 89 say 'AMOUNT'
@ prow() + 1, 02 say chr(15) +padc("Ä",89, "Ä")+chr(18)+padc("Ä", 24 , "Ä")+"Å"+padc("Ä", 20-2 , "Ä")

@ prow()     , 77 say chr(15) +space(4)+chr(18)+"³"
@ prow()     , 77 say chr(15) +space(4)+chr(18)+"³"
@ prow() +  1, 7 say Tranhead->partix1  picture '@!'
@ prow()     , 77 say chr(15) +space(4)+chr(18)+"³"
@ prow()     , 87 say TRANHEAD->tramount picture '999,999,999.99'
@ prow() +  1, 7 say Tranhead->partix2  picture '@!'
@ prow()     , 77 say chr(15) +space(4)+chr(18)+"³"
@ prow() +  1, 7 say Tranhead->partix3  picture '@!'
@ prow()     , 77 say chr(15) +space(4)+chr(18)+"³"
@ prow() +  1, 7 say Tranhead->partix4  picture '@!'
@ prow()     , 77 say chr(15) +space(4)+chr(18)+"³"
@ prow() +  1, 7 say Tranhead->partix5  picture '@!'
@ prow()     , 77 say chr(15) +space(4)+chr(18)+"³"
@ prow() +  1, 7 say Tranhead->partix6  picture '@!'
@ prow()     , 77 say chr(15) +space(4)+chr(18)+"³"
@ prow() +  1, 7 say Tranhead->partix7  picture '@!'
@ prow()     , 77 say chr(15) +space(4)+chr(18)+"³"

@ prow() + 1, 02 say chr(15) +padc("Í",89, "Í")+chr(18)+"Ñ"+padc("Í", 23 , "Í")+"Ø"+padc("Í", 20-2 , "Í")
@ prow() + 1, 21 say 'ACCOUNT TITLE'
@ prow()    , 35  say chr(15)+space(34)+chr(18)+"³"+space(9)+'DEBIT'+space(9)+"³"+space(7)+'CREDIT'
@ prow() + 1, 02 say chr(15) +padc("Ä",89, "Ä")+chr(18)+"Å"+padc("Ä", 23 , "Ä")+"Å"+padc("Ä", 20-2 , "Ä")

@ prow() +  1,  2 say chr(15) +space(89)+chr(18)+"³"+space(23)+"³"
@ prow() +  1,  2 say chr(15) +space(89)+chr(18)+"³"+space(23)+"³"

Trandtls->( dbseek( Tranhead->brcode+Tranhead->trnumber ) )
Trandtls->( dbeval( { || fPon100ma( @sw1,@sw2,@laps,@tDR,@tCR ) },,;
                  { || Trandtls->brcode+Trandtls->trnumber == Tranhead->brcode+Tranhead->trnumber } ) )
	
@ prow() + 1, 02 say chr(15) +padc("Í",89, "Í")+chr(18)+"Ï"+padc("Í", 23 , "Í")+"Ï"+padc("Í", 20-2 , "Í")

	@ prow(), pcol() say ' ' // microfeed           && printer font
	@ prow() + 1, 05 say '                           TOTALS : '          
	@ prow()    , pcol() say chr(15) +space(4)+chr(18)
	@ prow()    , pcol()+10  say ' '
	@ prow()    , pcol()+10 say tDR picture '999,999,999.99'
	@ prow()    , pcol()+1 say " "
	@ prow()    , pcol()+3 say tCR picture '999,999,999.99'

if laps < 1
  while prow() < 53
    @ prow()+1,00 say ' '
  enddo

  otherpage('1')

elseif laps > 1

  otherpage('1')
endif
  @ prow()+1, 28 say '-END OF REPORT <Account Eexcution JV> ('+ALLTRIM(STR(MPAGE))+'/'+ALLTRIM(STR(MPAGE))+')-'
__eject()

fUnzp100m( zz )
return( nil )

////
static function fPon100ma( sw1,sw2,laps, tDR, tCR)
local ax := 'ORIX METRO LEASING AND FINANCE CORPORATION'
local mt := cmonth( Tranhead->trandate )
local dy := day   ( Tranhead->trandate )
local yr := year  ( Tranhead->trandate )
local bx := mt + ' ' + ltrim( str( dy, 2 ) ) + ', ' + ltrim( str( yr, 4 ) )
local cx := 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
local dx := '³     JOURNAL VOUCHER N§ ' + padr( Tranhead->trnumber, 8 ) + '  ³'
local ex := 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
memva lg

if prow() <= 52 .and. lg <= 0
   if Trandtls->drcr $ '1'
      @ prow(), pcol() say ' ' // microfeed           && printer font
      @ prow() + 1, 05 say fFind100m( Trandtls->BRCODE+Trandtls->glcode, 50,.t. )          && RED 062805 ADDED 'Trandtls->BRCODE+

      @ prow(), pcol()+ 9 say "³"
      @ prow()    , pcol()+1  say if( sw1 < 1, 'P',' ' )
      @ prow()    , pcol()+6 say Trandtls->amount picture '999,999,999.99'
      @ prow(), pcol()+1 say "³"

      sw1++
	  tDR += Trandtls->amount
   else
      @ prow() + 1, 07 say fFind100m( Trandtls->BRCODE+Trandtls->glcode, 50,.t. ) + space(4)          && RED 062805 ADDED 'Trandtls->BRCODE+

      @ prow()    , pcol()+3 say "³" 
      @ prow()    , pcol()+23 say "³"       
      @ prow()    , pcol()+1 say if( sw2 < 1, 'P',' ' )
      @ prow()    , pcol()+1 say Trandtls->amount picture '999,999,999.99'

      sw2++
	  tCR += Trandtls->amount
   endif

   if prow() == 50 // pepe before 31
      laps := 1

	@ prow() + 1, 02 say chr(15) +padc("Í",89, "Í")+chr(18)+"Ï"+padc("Í", 23 , "Í")+"Ï"+padc("Í", 20 , "Í")
        otherpage('1')
   endif
else
   laps := 2
   
   if lg <= 0
      sw1  := 0
      sw2  := 0
      lg := +1
      mpage++

      __eject()

      setprc( 0,0 )
      setfont( upper( 'init' ) )
      prnreptitle( 84, 1,mpage, ' ',;
                              gBRANCH,gCOMPANY,' ')
      setfont( upper( 'draft' ) )
      setfont( upper( 'elite' ) )

      @ prow() +  1, ( 96 - len( cx ) ) / 2 say cx
      @ prow() +  1, ( 96 - len( dx ) ) / 2 say dx
      @ prow() +  1, ( 96 - len( ex ) ) / 2 say ex


@ prow() + 1, 02 say chr(15) +padc("Ä",89, "Ä")+chr(18)+"Â"+padc("Ä", 23 , "Ä")+"Â"+padc("Ä", 20 , "Ä")
@ prow() + 1, 21 say 'ACCOUNT TITLE'
@ prow()    , 35  say chr(15)+space(34)+chr(18)+"³"+space(9)+'DEBIT'+space(9)+"³"+space(7)+'CREDIT'
@ prow() + 1, 02 say chr(15) +padc("Ä",89, "Ä")+chr(18)+"Å"+padc("Ä", 23 , "Ä")+"Å"+padc("Ä", 20 , "Ä")

   endif
   if Trandtls->drcr $ '1'
      @ prow(), pcol() say ' '
      @ prow() + 1,  5 say fFind100m( Trandtls->BRCODE+Trandtls->glcode, 50,.t. )       && RED 062805 ADDED 'Trandtls->BRCODE

      @ prow(), pcol()+9 say "³"
      @ prow()    , pcol()+1  say if( sw1 < 1, 'P',' ' )
      @ prow()    , pcol()+3 say Trandtls->amount picture '99,999,999,999.99'
      @ prow(), pcol()+1 say "³"
      sw1++
   else
      @ prow() + 1, 7 say fFind100m( Trandtls->BRCODE+Trandtls->glcode, 50,.t. )  + space(4)          && RED 062805 ADDED 'Trandtls->BRCODE
      @ prow()    , pcol()+3 say "³" 
      @ prow()    , pcol()+23 say "³"       
      @ prow()    , pcol()+1 say if( sw2 < 1, 'P',' ' )
      @ prow()    , pcol()+1 say Trandtls->amount picture '99,999,999,999.99'
      sw2++
   endif               
endif

return( .t. )

////
static function fNavi100m( brow, knob )
loca did := .t.

do case
   case knob == K_UP    
        brow:up()
   case knob == K_DOWN  
        brow:down()
   case knob == K_LEFT  
        brow:left()
   case knob == K_RIGHT 
        brow:right()
   case knob == K_PGUP
        brow:pageup()
   case knob == K_PGDN
        brow:pagedown()
   case knob == K_CTRL_PGUP
        brow:gotop()
   case knob == K_CTRL_PGDN
        brow:gobottom()
   case knob == K_HOME
        brow:home()
   case knob == K_END
        brow:end()
   case knob == K_CTRL_HOME
        brow:panhome()
   case knob == K_CTRL_END
        brow:panend()                
   othe
        did := .f.     
endc        
return( did )

////
static function fInit100m( cax )
local arr_, cx, xarr

xarr := (DBSTRUCT())

arr_ := eval( { || if( cax $ 'a',;
        eval( { || dbgobottom(), dbskip() } ), nil ), {} } )
for cx := 1 to len(xarr) //fcount()
    aadd( arr_, fieldget( cx ) )
next 

	if cax == 'a' .and. empty(xFIRSTJV)
		
		arr_[  7 ] := 'EXECUTION OF ' +ALLTRIM(DISPALIAS( ACCTDALY->FCLTYCODE,10 )) +' ACCT# '+ TRANS(ACCTDALY->BRCODE+ACCTDALY->ACCTNO, '@R 999-9999-99999-99999')
		arr_[  8 ] := 'CLIENT   : ' + ALLTRIM(ACCTDALY->ACCTNAME)
		
		if empty(ACCTDALY->UNIT)
			arr_[ 18 ] := 'COLLATERAL : ' + ALLTRIM(ACCTDALY->COLATRL)
		else
			arr_[ 18 ] := 'ITEM     : ' + ALLTRIM(ACCTDALY->UNIT)
			arr_[ 19 ] := '         : ' + ALLTRIM(ACCTDALY->UNIT2)
		endif	
		
		arr_[ 20 ] := 'PAYEE    : '+ space(50)  
		arr_[ 22 ] := 'EXECUTED : ' + TRANS(ACCTDALY->VALDATE, '@D' ) 
		IF ROUND(ACCTDALY->USDRATE,2) > 0
		   arr_[ 23 ] := '            US$ 1.00 @ PhP ' + TRANS(ACCTDALY->USDRATE, '99.99' ) 
		ENDIF
		//arr_[ 23 ] := ''  
		
	endif

return( arr_ ) 

////
//EVR static function fEval100m()
//EVR local mrec, mdbf := fZipp100m() 
//EVR memva gigi

//EVR dbselectar( 'Trandtls' )
//EVR mrec := eval ( { | x | x := recno(),;
//EVR                        dbseek( AMSJVH->BRCODE+Amsjvh->trnumber ),;  && RED 112204 REMOVED 'Acctdaly->brcode
//EVR                        x ;
//EVR                } ;
//EVR              )
//EVR gigi := 0
//EVR Trandtls-> ( dbeval( { || gigi++ },,;
//EVR                    { || AMSJVH->BRCODE +Amsjvh->trnumber == Trandtls->brcode+Trandtls->trnumber };   && RED 112204 REMOVED 'Acctdaly->brcode
//EVR                  );
//EVR          )
//EVR Trandtls->    ( dbgoto(mrec) )
//EVR gigi := max ( gigi, 1 )
//EVR fUnzp100m   ( mdbf )
//EVR return( nil )

////

//EVR static function fChek100m()
//EVR local mrec, mdf := fZipp100m(),mu:=Amsjvh->(indexord())
//EVR local mwhat := ACCTDALY->BRCODE+subs( Acctdaly->acctno, -5, 5 )
//EVR memva lrr


//EVR dbselectar( 'Amsjvh' )
//EVR Amsjvh->  ( dbsetorder(1) )

//EVR mrec := eval( { | x | x := recno(), dbseek( mwhat ), x } )  && RED 112204 REMOVED 'Acctdaly->brcode+
//EVR lrr := 0
//EVR dbeval( { || lrr++ },,;
//EVR         { || mwhat == Amsjvh->brcode+Amsjvh->trloanno  } )   && RED 112204 '.and. Acctdaly->brcode == Amsjvh->brcode

//EVR lrr := max( lrr, 1 )
//EVR fUnzp100m( mdf )
//EVR Amsjvh->(dbgoto( mrec ))
//EVR Amsjvh->(dbsetorder(mu))
//EVR return( nil )

////
function dbempty()
local mcount := 0, mrecno := ( alias() )->( recno() )

eval( { || ( alias() )->( dbgotop() ),;
           ( alias() )->( dbeval( { || mcount++ },, { || !eof() .and. mcount == 0 } ) ),;
           ( alias() )->( dbgoto( mrecno ) ) } )
return( mcount > 0 )

STatic Function flitexxxx(ax)

if ax
   @ 23, 02 say 'Ins'      color 'w+/n'
   @ 23, 12 say 'F2'       color 'w+/n'
   @ 23, 22 say 'F3'       color 'w/n'
   @ 23, 33 say 'F6'       color 'w+/n'
   @ 23, 45 say 'F9'       color 'w+/n'
   @ 23, 56 say 'Tab'      color 'w+/n'
   @ 23, 69 say 'Del'      color 'w/n'
   @ 23, 75 say 'Esc'      color 'w+/n'
else
    @ 23, 02 say 'Ins'      color 'w+/n'
    @ 23, 12 say 'F2'       color 'w+/n'
    @ 23, 22 say 'F3'       color 'w+/n'
    @ 23, 33 say 'F6'       color 'w/n'
    @ 23, 45 say 'F9'       color 'w/n'
    @ 23, 56 say 'Tab'      color 'w+/n'
    @ 23, 69 say 'Del'      color 'w+/n'
    @ 23, 75 say 'Esc'      color 'w/n'
endif
return nil
////
static function fJour100m()

dispbegin()           
@  5,  5 say ' Journal Voucher N§ ¯' color 'bg+/g'
@  5, 44 say '         Value Date ¯' color 'bg+/g'
@  6,  5 say '       Total Amount ¯' color 'bg+/g'
@  6, 44 say '   Transaction Type ¯' color 'bg+/g'
@  7,  5 say '      Facility Type ¯' color 'bg+/g'
@  8,  5 say '        Particulars ¯' color 'bg+/g'
@  9,  5 say '                    ¯' color 'bg+/g'
@ 10,  5 say '                    ¯' color 'bg+/g'
@ 11,  5 say '                    ¯' color 'bg+/g'
@ 12,  5 say '                    ¯' color 'bg+/g'
@  6,  2 say chr( 24 )               color 'n/+w'
@ 20,  2 say chr( 25 )               color 'n/+w' 
//@  6, 77 say chr( 24 )               color 'n/+w'
//@ 12, 77 say chr( 25 )               color 'n/+w' 
//@ 23,  0, 23, 80 box repl( ' ', 9 )  color 'n/n'
//@  7,  2, 19,  2 box repl( '°', 9 )  color 'w+/n'
//@  7, 77, 11, 77 box repl( '°', 9 )  color 'w+/n' 
//@  7,  2, 13,  2 box repl( 'Û', 9 )  color 'gr+/w' 
//@  7, 77 say 'Û'                     color 'gr+/w'
/*
         1         2         3         4         5         6         7
12345678901234567890123456789012345678901234567890123456789012345678901234567890
<Ins>-Add <F2>-Edit <F3>-Color <F6>-Status <F9>-Print <Tab>-Window <DEL> <ESC>
*/
@ 23, 1 say '<Ins>-Add <F2>-Edit <F3>-Color <F6>-Status <F9>-Print <Tab>-Window <Del> <Esc>'   color 'w/n'
@ 23, 02 say 'Ins'      color 'w+/n'
@ 23, 12 say 'F2'       color 'w+/n'
@ 23, 22 say 'F3'       color 'w/n'
@ 23, 33 say 'F6'       color 'w+/n'
@ 23, 45 say 'F9'       color 'w+/n'
@ 23, 56 say 'Tab'      color 'w+/n'
@ 23, 69 say 'Del'      color 'w/n'
@ 23, 75 say 'Esc'      color 'w+/n'
dispend()
//__keyboard( chr( K_UP ) )
return( nil )


////
static function fWind100m( a_, b_, c_, d_, e_, f_, g_ )

fShadow( a_, b_, c_, d_, 2, e_, f_ )
setcolor( g_ + ', w+/n,,, gr+/' + subs( g_, 5, 2 ) )
return( g_ )

////
static function fZipp100m()
return( { select(), indexord(), recno() } )

////
static function fUnzp100m( x_ )
return( eval( { | x | dbselectar( x_[ 1 ] ),;
                      dbsetorder( x_[ 2 ] ),;
                      dbgoto(     x_[ 3 ] ), x } ) )

/*-------------------*/
 Function prnset()
/*-------------------*/
local pchoice:=0,menulist,zz:=savescreen( ,,, )
local nretval := .f.,xxx
if prntcnt < 1   //filter the multiple printing by duedate
   /////IDENTIFY PRINTER
   fshadow(10,35,16,57,2,'w+/bg')
   setcolor('n/gr,w+/gr','w+/gr,n/gr')
   @ 10,37 say 'Printer' color 'n/bg'
   @ 12,56 say 'Ü'  color 'n/bg'
   @ 13,37 say repl('ß',20) color 'n/bg'
   @ 14,56 say 'Ü'  color 'n/bg'
   @ 15,37 say repl('ß',20) color 'n/bg'

   while .t.
      @ 12,36 prompt ' EPSON or OKI        '  triggercolor 'w+/gr'
      @ 14,36 prompt ' REVISED JV          '  triggercolor 'w+/gr'
      menu to pchoice

      if lastkey() <> K_ESC .and. !empty(pchoice)
         nprint := getprntr( pchoice )
         //if Confirm('Set '+nprint+' as a default printer?' )
            exit
         //endif
      elseif Lastkey() == K_ESC
         exit
      endif
   enddo

   do case
      case pchoice == 1
            xxx := savescreen( ,,, )
            @ 12,36 say repl(' ',21) color 'n/bg'
            @ 13,36 say repl(' ',21) color 'n/bg'
            @ 12,37 say ' Epson FX-1170      ' color 'w+/gr'
            inkey(.5)
            restscreen( ,,,,xxx )
            @ 12,55 say 'û'  color 'w/gr'
            prntcnt := 11
            nprntr  := -1
            nretval := .t.
      case pchoice == 2
            xxx := savescreen( ,,, )
            @ 14,36 say repl(' ',21) color 'n/bg'
            @ 15,36 say repl(' ',21) color 'n/bg'
            @ 14,37 say ' OKI Microline 321  ' color 'w+/gr'
            inkey(.5)
            restscreen( ,,,,xxx )
            @ 14,55 say 'û'  color 'w/gr'
            nprntr  := +1
            prntcnt := 11
            nretval := .t.
      case pchoice == 0
            //cancel choices
            //pval := 0
   endcase
endif
restscreen(,,,,zz)
return nretval
/*-------------------------*/
 Function otherpage(ftype)
/*-------------------------*/

  while prow() < 50
    @ prow()+1,00 say ''
  enddo

if ftype == '1'
  @ prow()+1, 4 say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
  @ prow()+1, 4 say '³  Prepared by:  ³  Checked by:  ³   Posted by:   ³ Approved by:  ³     Department      ³'
  @ prow()+1, 4 say '³'
  @ prow()  , 5 say padc(alltrim(gUser_id),15)
  @ prow()  ,21 say '³               ³                ³'
  @ prow()  ,70 say "³"
  @ prow()  ,76 say "SALES ADMIN"
  @ prow()  ,92 say "³"
  @ prow()+1, 4 say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
else
  @ prow()+1, 4 say '                                                              ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
  @ prow()+1, 4 say '                                                              ³   Check Received by:     ³'
  @ prow()+1, 4 say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´                          ³'
  @ prow()+1, 4 say '³Prepared by:   ³  Checked by: ³   Posted by: ³  Approved by: ³__________________________³'
  @ prow()+1, 4 say '³               ³              ³              ³               ³  Date     Designation    ³'
  @ prow()+1, 4 say '³'
  @ prow()  , 5 say padc(alltrim(gUser_id),15)
  @ prow()  ,20 say '³              ³              ³               ³'
  setfont(upper('Condensed'))
  @ prow()  ,80 say '(Signature over Printed Name)'
  setfont('UNCONDENSD')
  SETFONT('ELITE')
  @ prow()  ,93 say '³'
  @ prow()+1, 4 say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
endif

return nil

Static Function fJVDBFclose()

eval( { || Glcode->( dbclearind() ), Glcode->( dbclosearea() ) } )
eval( { || GLTranhd->( dbclearind() ), GLTranhd->( dbclosearea() ) } )
eval( { || Glhdback->( dbclearind() ), Glhdback->( dbclosearea() ) } )
eval( { || Amsjvh->( dbclearind() ), Amsjvh->( dbclosearea() ) } )
eval( { || Fmsjvh->( dbclearind() ), Fmsjvh->( dbclosearea() ) } )
// EVR eval( { || Plsjvh->( dbclearind() ), Plsjvh->( dbclosearea() ) } )
// EVR eval( { || drop->( dbclearind() ), drop->( dbclosearea() ) } )  //aga.15.07.2005.droppus closus!
// EVR eval( { || Tranhead->( dbclearind() ), Tranhead->( dbclosearea() ) } )
//eval( { || Trandtls->( dbclearind() ), Trandtls->( dbclosearea() ) } )
return nil
/*---------------------------*/
 Static Function amstopen1m()
/*---------------------------*/

// EVR while .t.
// EVR   mAMS0100 :=  substr(alltrim(gUSER_ID),1,2)+substr(time(),1,2)+substr(time(),4,2)+substr(time(),7,2)

// EVR   if file(mAMS0100+ '.ntx')
// EVR      loop
// EVR   else
// EVR      exit
// EVR   endif
// EVR enddo

if !NETUSE('&g_GL_PATH\GLCODE', .f.,5 )
    return .f.
endif
set index to &g_GL_PATH\GLCODE,;      // brcode+glcode
             &g_GL_PATH\GLNAME,;      // glname+brcode
	     &g_GL_PATH\Glnme        //brcode + glname //dbsetindex('&g_GLS_PATH\Glname')

if !netuse( '&g_GL_PATH\Gltranhd', .f., 10 )    && general ledger
   return .f.
else
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_GL_PATH\Gltranhd' )          && set index on Trnumber + Trancode
   ORDLISTADD( '&G_GL_PATH\GLTRNPAY' )
endif

if !netuse( '&g_GL_PATH\GLBACKUP\Glhdback ', .f., 10 )
   return .f.
else
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_GL_PATH\GLBACKUP\Gltranhd' )
endif

if !netuse( '&g_AMS_PATH\Amsjvh', .f., 10 )
   return .f.
else
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_AMS_PATH\Amsjvt' )            && set index on BRCODE + TRNUMBER
endif

if !netuse( '&g_FMS_path\Fmsjvh', .f., 10 )               && journal voucher header
   return .f.
else
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_FMS_path\Fmsjvh' )                     && set index on trnumber
   ordsetfocus( 1 )
endif

   //set index to &g_GL_path\JV_LOG
   //@ 22,mcol say '.'
  // mcol := col()


// EVR if !netuse( '&G_Pls_path\Plsjvh', .f., 10 )               && journal voucher header
// EVR    return .f.
// EVR else
// EVR    if !.f.; ordlistclear(); endif
// EVR    ordlistadd( '&G_Pls_path\Plsjvh' )                     && set index on trnumber
// EVR    ordsetfocus( 1 )
// EVR endif

//aga.15.07.2005.dropper
// EVR if !netuse('&g_AMS_PATH\Drop',.f.,5 )
// EVR    return .f.
// EVR endif
// EVR ordlistadd( '&g_AMS_PATH\Drop' )
// EVR ordsetfocus( 1 )
//......................

// EVR dbselectarea( 'Amsjvh')
// EVR Amsjvh->    ( dbclearindex() )
//
// index on Brcode+Trnumber to (mAMS0100) for Trloanno == subs( Acctdaly->acctno, -5, 5 ) unique
// set index to &g_AMS_PATH\AMSJVH,&g_AMS_PATH\Amsjvt,&mAMS0100
// dbsetorder(3)
//
// EVR set index to &g_AMS_PATH\AMSJVH,;         // brcode+trloanno
// EVR              &g_AMS_PATH\Amsjvt           // brcode+trnumber

return .t.

/*-----------------------*/
 function JvStatxxx( _13 )
/*-----------------------*/
local zz := savedbf()
local xx := Tranhead->Trantype,zxzx:= ( Tranhead->Trantype != '3' )

dbselectar( 'Tranhead' )
if !Tranhead->( eof() )
   if _13 $ '3' .or. lastkey() == K_F6
      if netlock( 'R', 0 )
	 //nirvana
         toneone
         if yes_no2( 'JV N§ ' + padr( Tranhead->Trnumber, 8 ) ;
		     + if( Tranhead->Trantype $ '12', ' will be cancelled.',+;
		     ' will be cancelled.' ),, ' Active ', ' Cancelled ',       +;
		     if( Tranhead->Trantype $ '12', .t., .f. ) )
	       _field->Tranhead->Trantype := Tranhead->Trantype
	  else
	    if lastkey() == K_ESC
	       _field->Tranhead->Trantype := xx
	    else
          if( confirm( ' Are you really sure? ' ), eval( { || del_Trn_JV(Tranhead->BRCODE+Tranhead->Trnumber), ;
	       _field->Tranhead->Trantype := if( zxzx, '3', Tranhead->Trantype ) , del_isfirst_JV(Tranhead->BRCODE+Tranhead->Trnumber) }), ;
	       _field->Tranhead->Trantype := xx )
				
                if JV_LOG->(dbseek(Tranhead->brcode+Tranhead->trnumber))
                  if JV_LOG->( netlock( 'R', 0 ) )
                    JV_LOG->Trantype   := _field->Tranhead->Trantype
				  endif
						JV_LOG->(dbunlock())
						
				endif
					

		endif
	 endif
     Tranhead->( dbunlock() )
      endif
	 Tranhead->( dbcommit() )
   endif
   
   			if xFIRSTJV == TRANHEAD->trnumber
				
			endif
   
   
endif
restdbf( zz )
return( nil )
/*----------------------------------*/
 Function del_Trn_JV(xTrnum)
/*----------------------------------*/
local zz :=savedbf()

dbselectarea('Trandtls')
if Trandtls->(dbseek(xTrnum) )
   //aga.15.07.2005.drop insertion
   drop(alltrim(g_user_id)+" cancelled JV#"+Tranhead->Trnumber+" dated "+dtos(Tranhead->trandate)+" containing")

   Trandtls->(dbeval( {|| Netlock( 'R',0 ),;
                          Trandtls->(dbdelete()),;
                          drop("    -glcode "+Trandtls->glcode+" "+if(Trandtls->drcr == '1',"debit ","credit")+" "+trans(Trandtls->amount, '@Z 999,999,999.99' ) ),;
                          dbunlock()   },,;
           {|| Trandtls->BRCODE+Trandtls->Trnumber == xTrnum  } ) )   
endif

			 		if AMSJVLOG->(dbseek(Tranhead->brcode+ACCTDALY->acctno+Tranhead->trnumber))
						if AMSJVLOG->( netlock( 'R', 0 ) )
							AMSJVLOG->cancelled     := .T.
							
						endif					
					endif
						AMSJVLOG->(dbunlock())
						AMSJVLOG->(dbcommit())

restdbf(zz)
return nil

/*----------------------------------*/
 static Function del_isfirst_JV(xTrnum)
/*----------------------------------*/
local zz :=savedbf()

//dbselectarea('Trandtls')

if xTrnum == xFIRSTJV

	if TRHANHEAD->(dbseek(g_PAR_BRCH))
		
		do while g_PAR_BRCH == TRANHEAD->brcode
			if TRANHEAD->trloanno == subs( Acctdaly->acctno, -5, 5 ) 
				
				if Trandtls->(dbseek(TRANHEAD->brcode+TRANHEAD->trnumber) )

				   drop(alltrim(g_user_id)+" cancelled JV#"+Tranhead->Trnumber+" dated "+dtos(Tranhead->trandate)+" containing")
					
				   Trandtls->(dbeval( {|| Netlock( 'R',0 ),;
										  Trandtls->(dbdelete()),;
										  drop("    -glcode "+Trandtls->glcode+" "+if(Trandtls->drcr == '1',"debit ","credit")+" "+trans(Trandtls->amount, '@Z 999,999,999.99' ) ),;
										  dbunlock()   },,;
						   {|| Trandtls->BRCODE+Trandtls->Trnumber == TRANHEAD->brcode+TRANHEAD->trnumber  } ) )   
				endif
				
				if AMSJVLOG->(dbseek(Tranhead->brcode+ACCTDALY->acctno+Tranhead->trnumber))
					if AMSJVLOG->( netlock( 'R', 0 ) )
						AMSJVLOG->cancelled     := .T.
					endif					
				endif
					AMSJVLOG->(dbunlock())
					AMSJVLOG->(dbcommit())
					
			endif							
				TRANHEAD->(dbskip(1))
		enddo
	endif						
endif
restdbf(zz)
return nil

/*-------------------------*/
 Function fChkstJVx( a_ )
/*-------------------------*/
local nretval := .f.
if a_ == '3'
   waiton('Cancelled!!!')
   inkey(.1)
   waitoff()
else
  nretval := .t.
endif
return nretval

//aga.27.05.2008.glcode index fix
*****************************
function fGoodlevel(nlevel)
*****************************
local nretval := .f. 
local zz :=savedbf()

dbselectarea('glcode')
glcode->(dbsetorder(1))   //glcode in netuse

if glcode->(!eof()) .and. glcode->(!bof())
   glcode->(dbskip())
   if nlevel >= glcode->glevel
      nretval := .t.
   endif
endif

restdbf(zz)

return nretval

/*
Function fGoodlevel( fDbf,xord,nlevel )

local nretval :=.f., 
local nrec :=(fdbf)->(recno())
local nord :=(fDbf)->(indexord())

(fDbf)->(dbsetorder(xord))

if (fDbf)->(!eof()) .and. (fDbf)->(!bof())
   (fDbf)->(dbskip())

   if nLevel >= (fDbf)->gLevel
      nretval := .t.
   endif
endif

(fDbf)->(dbsetorder(nord))
(fDbf)->(dbgoto(nrec))

return nretval
*/
*********************************************
*
static function fGeteVIN(addedit,curr_elem )
*********************************************
/// DBP replaced with OL      jbs 10.25.2002
/// FSF replaced with AUTOL   jbs 10.25.2002
local mrec := recno(), arr_ := fInit100m( addedit ), cx, msign := !.t.,yy_,mfacil:=''
local getlist := {}, mscreen := savescreen( ,,, ), mcolor := setcolor(),xx_
local ach_ := { 'LCR           -1', 'ML            -2', 'IPP           -3', 'RP            -4',;
                'AUTOL         -5', 'OL            -6', 'CML           -7', 'DOC. STAMP/ETC-8','OTHERS        -9' }
local ach2_:= { '1. Normal   ',;
                '2. Memo     ',;
                '3. Cancelled' }
local mjvnumber,Xmjvnumber
memva gTRANDATE, gUSER_ID

mJVNUMBER := g_PAR_BRCH+repl( 'X', len(TRANHEAD->TRNUMBER) )

   cx := eval ( { | xx | xx := if( addedit $ 'e',                             ;
                    fWind100m( 14, 5, 17, 55, 'w+/gr', ' Edit ', 'bg+/gr' ),  ;
                    fWind100m( 14, 5, 17, 55, 'w+/g' , ' Add ' , 'bg+/g'  ) ),;
                    xx                                                        ;
                } ;
              )

   @ 15, 6 say 'Account Code ¯' ;
           gget arr_[ 2 ]       ;
           picture '@R 999-99-99-9999'       ;
           when eval ( { || arr_[ 2 ] := fOrdr100m( addedit, arr_[ 2 ]), ;
                            if( lastkey() <> K_ESC,;
                                fAcct100m( arr_[ 2 ], cx, 15),nil),;
                                .f. ;
                       };
                     )
					 
					 arr_[ 4 ] := _APalmSub[curr_elem]
   @ 16, 6 say '      Amount ¯' gget arr_[ 4 ] calculator picture '999,999,999.99' when lastkey() <> K_ESC ;
           valid eval( { || fAmnt100m( addedit, @arr_,curr_elem ) } )

setcursor( 3 )
setkey( K_ESC, { || fEscape( 'Abort?') } )
read  //timeout 20 exitevent blankscr3( -1 )
getlist:={}
setkey( K_ESC, nil )
setcursor( 0 )
if lastkey() != K_ESC

        if confirm ( 'Are all entries correct?' )
          //aga.05.01.2005.editing booking jv drop

            drop(alltrim(g_user_id)+" edits JV#"+Tranhead->Trnumber+" dated "+dtos(Tranhead->trandate)+" from ")
            drop(" glcode "+Trandtls->glcode+" to "+arr_[ 2 ] + " drcr "  +Trandtls->drcr+" to "+arr_[ 3 ])
            drop(" amount "+str(Trandtls->amount)+" to "+str(arr_[ 4 ]))
          //........................

            Trandtls->brcode   := Acctdaly->brcode
            Trandtls->trnumber := arr_[ 1 ] := Tranhead->trnumber
            Trandtls->glcode   := arr_[ 2 ]
            Trandtls->drcr     := arr_[ 3 ]
            Trandtls->amount   := arr_[ 4 ]
            Trandtls->TRANCODE := '1'     && EVR 25092006
            zax := Tranhead->Trnumber
			msign := .t.
            Trandtls->( dbunlock() )
            Trandtls->( dbcommit() )
		endif	

endif

restscreen( ,,,, mscreen )
setcolor( mcolor )
return( msign )

********************************
*
static function dupfile(cFILE)
********************************
   local mfiname
   do while .t.
      if file('c:\lotus\'+cFILE+'.dbf')                 // test if text file exist
			ferase('c:\lotus\'+cFILE+'.dbf')
         loop
      else
         exit
      endif
   enddo
return mfiname
