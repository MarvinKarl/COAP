//
// program idúúú fchoice()
// descriptionúú achoice maker
// authorúúúúúúú rlv
//
#include 'inkey.ch'
#include "Achoice.ch"
#include 'colf.ch'
#define   cursorless    K_TAB * K_CTRL_C - K_ESC  

					 //DBF	, CLIENM,CLIECD
function main_achoice(mfname,mntx1,mntx2,mntx3,mrw1,mcl1,mrw2,mcl2,mheadr,mfnc,mn)
local mlog
private mnctrk:=0,marrpos:={},mod_titl:=mfnc
private mfile := mfname, _ntx1:= mntx1, _ntx2:= mntx2,_ntx3:= mntx3
private mrow_1 := mrw1 ,  mrow_2 := mrw2
private mcol_1 := mcl1 ,  mcol_2 := mcl2 - 1
private nRecChoice := 0, mlastpressed:='', nleft :=mcol_1 + 2 , _enable :=0
private _knw:= .t.,xrecno:=0, mnme:=mn

public aNRECNO,mpos:=1,mchoices:={}
(mfile)->(dbgotop())
_callfnc()


//alert()

        if len(mchoices) > 1
            mlog := aclone( mchoices )         
            aeval ( mlog, { | l, c | mlog[ c ] := if( c <=0 , .f., .t. ), c } )
            mpos := val( temp_achoice(1, mheadr , mlog) )

        endif	

	/*	if mpos > 0 .and. lastkey() == K_ENTER
				cKEY := substr( ltrim(mchoices[mpos]),44,3)+substr( ltrim(mchoices[mpos]),50,2)+;
				substr( ltrim(mchoices[mpos]),53,5)
				(mfile)->(dbsetorder(_ntx2))
				
             if (mfile)->( dbseek (alltrim(cKEY)) )   
                aNRECNO  := (mfile)->(RECNO())
				
            endif		 
		ENDIF
*/

function temp_achoice(mdefault, mhead, mgetrue)  

local mkey := { | k | k == K_ENTER .or. k == K_ESC }
local mdbf_ := savedbf(), mposition, mcolor := setcolor(), mtrue := !.f.
local mreturn := { | s, k, c, n | restscreen( ,,,, s ), __mrelease( k, .t. ), setcursor( c ), ltrim( str( n, 4, 0 ) ) }
local mscr := savescreen( ,,, ), maxcol := 0
local k := lastkey()
//private mrow_1 := 8 /*if( valtype( mgetrue ) == 'A', 8, 12 ),*/, mrow_2 := 21
//private mcol_1 := 40 - eval( { || aeval( mchoices, { | a_ | maxcol := max( maxcol, len( a_ ) ) } ), max( maxcol, len( trim( mhead ) ) ) / 2 } )
//alert(str(eval( { || aeval( mchoices, { | a_ | maxcol := max( maxcol, len( a_ ) ) } ), max( maxcol, len( trim( mhead ) ) ) / 2 } )))
//private mcol_2 := mcol_1 + max( maxcol, len( trim( mhead ) ) ) + 1

private kill_arr_ := aclone( mchoices ), kill_1_col := kill_ind := 1, mwatch := '”'
private kill_1_row, kill_2_col := mcol_2, kill_2_row := mrow_1, kill_getrue, mcursor := setcursor( setcursor() )


kill_1_row := mdefault := if( mdefault == 0, 1, mdefault )
mgetrue := if( valtype( mgetrue ) == 'A', mgetrue, .t. )

 //alert(str(maxcol))
//alert(str(mrow_1))
//alert(str(mcol_1))
//alert(str(mrow_2))
//alert(str(mcol_2))

dispbegin()
 screen_2_disp( mrow_1, mcol_1, mrow_2, mcol_2, mhead, maxcol )
 
dispend()
             
do while  _enable != 1
 
      mposition := achoice( mrow_1 + 3, mcol_1 + 1, mrow_2 - 1, mcol_2 - 1, mchoices, mgetrue,'FKEYS',0)

      mtrue := if( eval( mkey, lastkey() ), !mtrue, mtrue ) 
  
enddo       
restdbf ( mdbf_ )
********setcolor( mcolor )ÿ
return( eval( mreturn, mscr, 'kill_*', mcursor, if( mposition == 0, mdefault, mposition ) ) )   
////

static function screen_2_disp( mrow_1, mcol_1, mrow_2, mcol_2, mhead, maxcol )

fshadow( mrow_1, mcol_1, mrow_2, mcol_2, 2, 'w+/gr+' )   
devpos(  mrow_1 + 1, mcol_1 + 1 ); devout( trim( mhead ), 'w+/gr+' )   
devpos(  mrow_1 + 2, mcol_1 - 0 ); devout( 'Ã' + repl( 'Ä', max( maxcol, len( ( mhead ) ) ) ) + '´', 'w/gr+' )   
dispbox( mrow_1 + 3, mcol_1 + 1, mrow_2 - 1, mcol_2 - 1, '', 'n/bg' )   
dispbox( mrow_1 + 3, mcol_2, mrow_2 - 1, mcol_2, '°', 'w/n' )
devpos(  mrow_1 + 3, mcol_2 ); devout( chr( 24 ), 'n/w' )
devpos(  mrow_2 - 1, mcol_2 ); devout( chr( 25 ), 'n/w' )
if !empty(mnme)
	@ mrow_1,mcol_2 - 20 say  mnme 
else
devpos(  mrow_1 + 3, mcol_2 ); devout( chr( 24 ), 'n/w' )
endif
@ mrow_2,mcol_2 - 25 say '[PGDN]-NEXT / [PGUP]-PREV' color 'w+/gr+'
setcolor( 'n/bg, w+/n,,, n/bg' )
return( cursorless )

**********************
*  
function def_fnc()
********************** 
(' ' + substr((mfile)->FULLNAME,1,40)+'³  '+ (mfile)->BRCODE+' ³ '+;
 alltrim(TRAN(((mfile)->CLNTCODE),'@R 99-99999' ))+ '       ' )

********************** 
function acct_fnc()
********************** 
(' ' + substr((mfile)->ACCTNAME,1,40)+'³  '+ (mfile)->BRCODE+' ³ '+;
 alltrim(TRAN(((mfile)->ACCTNO),'@R 9999-99999-99999' ))+ '       ' )
 
********************** 
function daily_fnc()
********************** 
(' ' + substr((mfile)->ACCTNAME,1,38)+'   '+ (mfile)->CLNTCODE+'   '+;
 alltrim(TRAN(((mfile)->ACCTNO),'@R 99999999999999' ))+ '       ' )
 
**********************  
function def_cltype()
********************** 
(' ' + substr((mfile)->FULLNAME,1,40)+'³  '+ (mfile)->BRCODE+' ³ '+;
 alltrim(TRAN(((mfile)->CLNTCODE),'@R 99-99999' ))+' ³  '+ alltrim((mfile)->CLTYPE) )

**********************  
function _GROUP()
********************** 
('        ' + substr((mfile)->GRUPNAME,1,20)+' ³ '+ (mfile)->BRCODE+' ³     '+;
 (mfile)->GRUPCODE ) 
 
**********************
*  
function no_acct()
********************** 
(' ' + substr((mfile)->FULLNAME,1,40)+'³  '+ (mfile)->BRCODE+' ³ '+;
 alltrim(TRAN(((mfile)->CLNTCODE),'@R 99-99999' ))+ ' ³    '+(alltrim(str(_get_num_accts() ) ) ) ) 

*******************
*
static function _choose()
*******************

		do case
		
			case mod_titl == 'noacct'
				no_acct()
			case mod_titl == 'DEFAULT'	
				def_fnc()
			case mod_titl == 'acct_fnc'	
				acct_fnc()
			case mod_titl == 'daily'	
				daily_fnc()
			case mod_titl == 'WCLTYPE'		
				def_cltype()
			case mod_titl == 'group'
				_GROUP()
		endcase


		

***************************
*
static function _callfnc()
***************************
private cbrcode := g_PAR_BRCH, lock, _key
 
        (mfile)->(dbsetorder(_ntx1))
		if _knw
			(mfile)->(dbseek(cbrcode))	
			
 		endif
	
	do while (mfile)->BRCODE == cBRCODE// ////!client->(eof())!(mfile)->(eof())
		
	
		IF mnctrk != 10 //(mfile)->BRCODE == cBRCODE
			if _knw
				xrecno:=(mfile)->(recno())
				_knw:= .f.
			endif
			
			mnctrk++
	
			//_key:=aadd(mchoices, ' ' + substr((mfile)->FULLNAME,1,40)+'   '+ (mfile)->BRCODE+'   '+ alltrim(TRAN(((mfile)->CLNTCODE),'@R 99-99999' ))+ '  ') 
			
			
			aadd(mchoices, _choose())	
			
			
			aadd( marrpos,(mfile)->(recno()) )
		ENDIF	

		(mfile)->(dbskip(1))
		if mnctrk == 10
			exit
		endif

	enddo

  return nil

**********************************
*
function _get_num_accts()          // abb 09.19.2007
**********************************
   local nrec := Acctmast->(recno()), nntx := Acctmast->(indexord())
   local nretval := 0

   Acctmast->(dbsetorder(2))


   if Acctmast->(dbseek(cbrcode+(mfile)->CLNTCODE))
      Acctmast-> ( dbeval( { || nretval++ },, ;
                           { || Acctmast->brcode+Acctmast->Clntcode == cbrcode+(mfile)->CLNTCODE } ;
                         ))
   endif

   Acctmast->(dbsetorder(nntx))
   Acctmast->(dbgoto(nrec))
return nretval

*****************
function fkeys()
*****************
local cbrcode := g_PAR_BRCH
local k := lastkey(), ret_val := AC_CONT


do case
	
		case lastkey() == K_ESC
		//alert((mpos))
		_enable:=1
         return 0
	
		case k == K_ENTER
		//alert(client->fullname)
		//test11()
		_enable:=1
		 ret_val    := if( k == K_ENTER, AC_SELECT, AC_ABORT )
		
		return( ret_val )
		//alert(ckey)

		case lastkey() == K_PGDN
			mlastpressed:=''
			@ mrow_2,mcol_1+2 say REPL('Ä',32)    color 'w+/gr'
		             ___noldrec := (mfile)->(recno())
                     _npgrecno  :=  marrpos [ len(marrpos) ]

                     if mnctrk >= 10
					 
						 (mfile)->(dbgoto(_npgrecno))
	                     (mfile)->(dbskip(+1))
					 
						if (mfile)->BRCODE == cBRCODE
					 
		                        mnctrk	    := 0
		                        mchoices    := {}
		                        marrpos     := {} 
		                       _callfnc() 
							  // @  11,5 clear to 20,72
							  @ mrow_1 + 3, mcol_1 + 1 clear to mrow_2 - 1, mcol_2 - 1
						else
								waiton('END OF FILE',.f.,'n/w' )
								inkey( .01 )
								waitoff()
						endif
                       
                     else
						waiton('END OF FILE',.f.,'n/w' )
						inkey( .01 )
						waitoff()
					 endif
                     
					return 0
					
		case LASTKEY() == K_PGUP
			mlastpressed:=''
			@ mrow_2,mcol_1+2 say REPL('Ä',32)    color 'w+/gr'
			
		        if marrpos[1] == xrecno
					waiton('BEGINNING OF FILE',.f.,'n/w' )
					inkey( .01 )
					waitoff()
				else
					X_:=0
					
                     ___noldrec := (mfile)->(recno())
                     _npgrecno  :=  marrpos[1]
					 
						 
                     (mfile)->(dbgoto(_npgrecno))

					/* if (mfile)->BRCODE == cBRCODE
						 (mfile)->(dbskip(-1))
					endif*/
					 
					 do while x_ != 11 .and. xrecno != (mfile)->(recno())
					 
						//if (mfile)->BRCODE == cBRCODE
							x_++
						//endif
							if X_ == 11
								exit
							endif
							
					(mfile)->(dbskip(-1))
					enddo	
					
					if xrecno == (mfile)->(recno())
						(mfile)->(dbgoto(xrecno))
					endif
					
                    if mnctrk > 0

                        mnctrk	    := 0
                        mchoices    := {}
                        marrpos     := {} 
						
                       _callfnc()
                        //@  7,2 clear to 20,78


                     endif
				 ENDIF
					return 0
		
	     case lastkey() == K_BS
	        if !empty( mlastpressed )
	           mlastpressed := subs( mlastpressed, 1, len( mlastpressed ) - 1 )
	            if empty( mlastpressed )
					@ 21, nleft + 1 say 'ÄÄ' color 'w+/gr'
	              else
					@ 21, nleft + 2 say upper( mlastpressed ) + 'Ä' color 'w+/gr'
				endif	
			endif
					return 0
		
		 case lastkey() >= 32 .and. lastkey() <= 165 
			FND:= .F.
				do while .t.
	                 if empty( mlastpressed )
	                    mlastpressed := upper(chr( lastkey() )) //chr( mkey )
	                 else
	                    IF lastkey() == K_BS
	                       mlastpressed := LEFT(mlastpressed,LEN(mLASTPRESSED)-1)
						   
	                    ELSEIF lastkey() <> K_ENTER .AND. lastkey() <> K_ESC
	                       mlastpressed := mlastpressed + upper(chr( lastkey() ))
	                    ENDIF
	                 endif
					 //alert('1')
					IF (lastkey() == K_DEL  .or. lastkey() == K_INS .or. ;
						lastkey() == K_HOME .or. lastkey() == K_END .or. ;
						lastkey() == K_PGUP .or. lastkey() == K_PGDN .or.;
						lastkey() == K_TAB  .or. lastkey() == K_F1 .or.  ;
						lastkey() == K_F2   .or. lastkey() == K_F3 .or.  ;
						lastkey() == K_F4   .or. lastkey() == K_F5 .or.  ;
						lastkey() == K_F6   .or. lastkey() == K_F7 .or.  ;
						lastkey() == K_F8   .or. lastkey() == K_F9 .or.  ;
						lastkey() == K_F10  .or. lastkey() == K_F11 .or. ;
						lastkey() == K_F12  .or. lastkey() == K_UP  .or. ;
						lastkey() == K_DOWN .or. lastkey() == K_LEFT .or.;
						lastkey() == K_RIGHT) .AND. !empty( mlastpressed )
						
						mlastpressed := LEFT(mlastpressed,LEN(mLASTPRESSED)-1)
					ENDIF	
					
					IF lastkey() == K_BS .AND. empty( mlastpressed )
						@ mrow_2,mcol_1+2 say REPL('Ä',32)    color 'w+/gr'
						EXIT
					ENDIF
					
	                 if len( mlastpressed ) > 30
	                    mlastpressed := left( mlastpressed,30 )
	                 endif

	                 @ mrow_2, nleft + 1 say '' + REPL('Ä',30)    color 'w+/gr'
	                 @ mrow_2, nleft + 2 say upper( mlastpressed ) color 'w+/gr'
					  INKEY(0)
					 
					IF LASTKEY() == K_ENTER
						(mfile)->(dbsetorder(_ntx1))
					 	 FND := (mfile)->(DBSEEK(cbrcode + upper(mLASTPRESSED) ))				
						if !FND
						mlastpressed:=''
							error('No Record/s Found..')
							
							@ mrow_2,mcol_1+2 say REPL('Ä',32)    color 'w+/gr'
							
							
							exit
						else
							//mlastpressed:=''
							//_try()
							//return 2
							exit
							
						endif
					endif
					
					IF LASTKEY() == K_ESC
					 mlastpressed:=''
	                   @ mrow_2,mcol_1+2 say REPL('Ä',32)    color 'w+/gr'
	                    EXIT
	                 endif						 

					enddo
					//alert('rom')
			

				
				if lastkey() != K_ESC .and. FND
					//alert('r')
						 mnctrk	    := 0
						 mchoices    := {}
						marrpos     := {} 
						//@  11,11 clear to 20,70 
						@ mrow_1 + 3, mcol_1 + 1 clear to mrow_2 - 1, mcol_2 - 1
						_callfnc()
		
				endif
				//alert('loop')
				
				
				return 1		
			
				
	
  endcase
  
  
  
  return 2

******************  
*
function _try()
*******************
  
				mnctrk	    := 0
		        mchoices    := {}
		        marrpos     := {} 
				_callfnc()
				//@  11,11 clear to 20,70
				@ mrow_1 + 3, mcol_1 + 1 clear to mrow_2 - 1, mcol_2 - 1
//return 1






