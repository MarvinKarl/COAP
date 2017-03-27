/*
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё   PROGRAM ID.........:  AMSM0900.prg                                         Ё
Ё   Description........:  approving committees file maintenance                Ё
Ё   Author.............:  Ariel B. Bulan                                       Ё
Ё   Date...............:  03:29pm 28-Sep-1994                                  Ё
цдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё                         U P D A T E S                                        Ё
цдддддддддддддддддддбдддддддддддддддбдддддддддддддддддддддддддддддддддддддддддд╢
Ё        Who        Ё     When      Ё               Why                        Ё
цдддддддддддддддддддедддддддддддддддедддддддддддддддддддддддддддддддддддддддддд╢
Ё        aga        Ё  21.06.2005   Ё online version                           Ё
Ё                   Ё               Ё                                          Ё
юдддддддддддддддддддадддддддддддддддадддддддддддддддддддддддддддддддддддддддддды
*/

#include "COLF.CH"
#include "INKEY.CH"

memvar ax_level,g_user_id
if chkpass( procname(),ax_level,g_user_id )
   if amsm0300open()
      nosnow( .t. )
      fm0900()
      nosnow( .f. )
   endif
   release all
   close data
endif

return
******************************************
*   Description   program's main function
*   Parameters    none
*   Return Value  nil
static function fm0900()
**************************
   local cb, mKEY, mcolor := 'gr+/b', mdbf_, mrow := 1, nrow := 5
   local mbanner := 'Approving Committees File Maintenance'
   local mblock := { | x | Comember->comcode == x .and. !Comember->( deleted() ) }
   local keys_  := { '<Ins>\-Add ', '<F2>\Edit ', '<F3>\Color ', '<F4>\Search ','<F9>\Print ', '<Tab>\-Window ', '<Del>\ ', '<Esc>\' }
   local tbcol_ := { tbcolumnnew( 'Group'                               , { || Comember->grupcode  } ),;
                     tbcolumnnew( 'Initial'                             , { || Comember->initials  } ),;
                     tbcolumnnew( 'Short Name     '                     , { || padstr( Comember->shortname, 15 ) } ),;
                     tbcolumnnew( 'Full Name                          ' , { || padstr( Comember->fullname , 35 ) } ) }
   memvar g_SYS_NAME, g_USER_ID, mTRANDATE, tbkill_lastrec, tbkill_code
                     
   dbselectarea( "Comcodes" )
   if( Comcodes->( eof() ), eval({|| ERROR("No Record Found!"),;
                                   __Keyboard(chr(K_INS))}), nil)

   Comcodes->( dbseek( g_par_brch )) //aga.20.06.2005.per branch

   mdbf_ := savedbf()                                 
   dbselectar( "Comember" )
   Comember->( dbseek( g_par_brch + Comcodes->comcode ) )
   cb := tb_maker( tbcol_, keys_,,,,, mbanner,,, Comcodes->comcode, mblock, 8,,, )
   restdbf( mdbf_ )
   
   do while .t. 

      dispheadrec( mcolor )
      mdbf_ := savedbf()
      dbselectar( "Comember" )      
      tbkill_code := Comcodes->comcode
      Comember->( dbseek( g_par_brch + Comcodes->comcode ) )      
      tb_refresh( cb )
      restdbf( mdbf_ )
      
      mKEY := inkey( 0 )
      
      do case
         case mKEY == K_UP .or. mKEY == K_PGUP
            if chkpass('S',AX_LEVEL,G_USER_ID)
               Comcodes->( dbskip( -1 ) )
               if Comcodes->brcode != g_par_brch
                  Comcodes->( dbskip( +1 ) ) //aga.20.06.2005.per branch
               end if
             endif
         case mKEY == K_DOWN .or. mKEY == K_PGDN
            if chkpass('S',AX_LEVEL,G_USER_ID)
               Comcodes->( dbskip( +1 ) )
               if Comcodes->brcode != g_par_brch
                  Comcodes->( dbskip( -1 ) ) //aga.20.06.2005.same as above, and the two below
               end if
            endif
         case mKEY == K_HOME
            if chkpass('S',AX_LEVEL,G_USER_ID)
               Comcodes->( dbseek( g_par_brch ) )
            endif
         case mKEY == K_END
            if chkpass('S',AX_LEVEL,G_USER_ID)
               //alert( padl(val(g_par_brch) + 1, 3, "0")  )
               Comcodes->(dbseek(padl(val(g_par_brch) + 1, 3, "0")))
               Comcodes->( dbskip( -1 ) )
            endif
         case mKEY == K_INS
            if chkpass('A',AX_LEVEL,G_USER_ID)
                updatehead('A')
            endif
         case mKEY == K_F2
            if chkpass('E',AX_LEVEL,G_USER_ID)
               if( Comcodes->( eof() ), ERROR('Nothing to Edit!'),updatehead('E'))
            endif
         case mKEY == K_F4
            if chkpass('S',AX_LEVEL,G_USER_ID)
               if Comcodes->( eof() )
                  ERROR( 'Nothing to Search!' )
                else
                  search_head ( space( len ( Comcodes-> COMCODE  ) ) )
               endif            
            endif
			
         case mKEY == K_F9
			private _USER_choice := 1,cbrcode := '   '
				_SELCT_BY()
			do while .t.
				if lastkey() != K_ESC
					REPCON_OL( '_fprint0900()','80 columns',,,,,,.f.)
					exit
				endif
				
				if lastkey() == K_ESC
					exit
				endif	
			enddo
			
         case mKEY == K_TAB
              if !Comcodes->( eof() )
                 mdbf_ := savedbf()                                 
                 dbselectar( 'Comember' )
                 tbkill_lastrec := 0
                 tbkill_code := Comcodes->comcode
                 Comember->( dbseek( Comcodes->brcode + Comcodes->comcode ) )
                 Comember->( dbeval( { || tbkill_lastrec++ },, { || Comember->comcode == Comcodes->comcode } ) )              
                 tbkill_lastrec := max( tbkill_lastrec, 1 )
                 tbkill_code := Comcodes->comcode
                 Comember->( dbseek( Comcodes->brcode + Comcodes->comcode ) )              
                 Comember->( tb_stabilizer( cb, { | o, k | case0900( o, k ) } ) )
                 restdbf( mdbf_ )
              endif   
         case mKEY == K_ESC
            if exitmod()
               exit
            endif
         case mKEY == K_DEL
            if chkpass('D',AX_LEVEL,G_USER_ID)
               if CONFIRM ( 'Delete Committee Code N╖ ' + Comcodes->comcode + '?')
                  MSGWIN(12,35,'Deleting','w+/bg','r*/bg','on')
                  delete_head()
                  MSGWIN(12,35,'Deleting','w+/bg','r*/bg','off')
               endif
            endif
      endcase
      tb_indicator( mkey, @mrow, @nrow, 77, 5, 9 )
   enddo
   __mxrelease( tbkill_cel, tbkill_arg, tbkill_lastrec,;
                tbkill_code, tbkill_where, tbkill_color, tbkill_rel,;
                tbkill_mtop, tbkill_mleft, tbkill_mbottom, tbkill_mright )  
return nil

////
function padstr( mname, mmany )
return( padr( mname, mmany ) )

***************************************************************
*   Description   displays current Comcodes.dbf record
*   Parameters    none
*   Return Value  nil
static function dispheadrec( mcolor )
*************************************
   dispbegin()
   @ 04, 03 say '                    Committee Code  ' color 'bg+/b'
   @ row(), col() say Comcodes->brcode + "-" + Comcodes->COMCODE color (mcolor)
   @ 05, 03 say '                    Committee Name  ' color 'bg+/b' 
   @ row(), col() say Comcodes->COMNAME color (mcolor)
   @ 06, 03 say '            Credit Limit:  Minimum  ' color 'bg+/b'
   @ row(), col() say transform( Comcodes->MINIMUM, '999,999,999.99' ) color (mcolor)
   @ 07, 03 say '                           Maximum  ' color 'bg+/b'
   @ row(), col() say transform( Comcodes->MAXIMUM, '999,999,999.99' ) color (mcolor)
   @ 08, 03 say '        Required Number of Signees  ' color 'bg+/b'
   @ row(), col() say transform( Comcodes->SIGNEES, '99' ) color (mcolor)
   @ 09, 03 say '                        Required A  ' color 'bg+/b'
   @ row(), col() say transform( Comcodes->REQA   , '99' ) color (mcolor)
   @ 10, 03 say '                        Required B  ' color 'bg+/b'
   @ row(), col() say transform( Comcodes->REQB   , '99' ) color (mcolor)
   dispend()
return nil
******************************************************************
*   Description   displays Comember.dbf records per COMCODE only
*   Parameters    COMCODE
*   Return Value  nil
static function case0900( cb, mkey )
****************************************************************
local mcolor := setcolor(), mscreen := savescreen( ,,, ), mreturn := .t.

do case   
   case mkey == K_INS
        if chkpass( 'A', AX_LEVEL ,g_USER_ID )
           update_detail( 'A' )
           tb_refresh( cb, 'a' )
         endif   
   case mkey == K_F2
        if chkpass( 'E', AX_LEVEL, g_USER_ID )
           if( Comember->COMCODE != Comcodes->comcode, eval({|| ERROR('Nothing to Edit!'), dbseek( Comcodes->brcode+Comcodes->comcode )}),update_detail('E'))
           tb_refresh( cb, 'c' )           
        endif
   case mkey == K_DEL
        if chkpass( 'D', AX_LEVEL, g_USER_ID )
           if( Comember->COMCODE != Comcodes->comcode, eval({|| ERROR('Nothing to Delete!'), dbseek( Comcodes->brcode+Comcodes->comcode )}),delete_detail( Comcodes->comcode, Comember->GRUPCODE ))               
           tb_refresh( cb, 'a' )           
        endif
   case mkey == K_F4
        if chkpass( 'S', AX_LEVEL, g_USER_ID )
           if Comember->comcode != Comcodes->comcode
              eval({|| ERROR('Nothing to Search!'),dbseek( Comcodes->brcode+Comcodes->comcode )})
           else
              search_detail( Comcodes->comcode, space( len ( Comember->GRUPCODE ) ), cb:rowpos + 15 )
              tb_refresh( cb, 'a' )              
           endif
        endif
   otherwise
        mreturn := !mreturn     
endcase
setcolor( mcolor )
restscreen( ,,,, mscreen )
return( mreturn )
***************************
static function delete_head()
*****************************
   local mDBF := select(), mNTX := indexord(), mRECNO := recno()

   dbselectarea( "Comcodes" )
   if netlock ( 'R', 0 )
      Comcodes->( dbdelete() )
      dbselectarea( "Comember" )
      if Comember->( dbseek ( Comcodes->brcode + Comcodes->COMCODE ) )
         dbeval ( {|| NETLOCK( 'R', 0 )                               ,;
                      Comember->( dbdelete() )                        ,;
                      Comember->( dbunlock() )                         ;
                  }                                                  ,,;
                  { ||  Comember->COMCODE == Comcodes->COMCODE .and.   ;
                       !Comember->( eof() )                            ;
                  }                                               ,,.t.)
      endif
      dbunlock()

      dbselectarea( "Comcodes" )
      Comcodes->( dbskip ( +1 ) )
      if Comcodes->( eof() )
         Comcodes->( dbskip ( -1 ) )
      endif
      mRECNO := Comcodes->( recno() )
   endif

   *dbunlock()  && RED 11102004 WHAT FOR??
   select( mDBF ) ; set order to ( mNTX ) ; go ( mRECNO )
return nil
***************************************************************
*   Description   add/edits COMCODES.DBF
*   Parameters    type >> 'A' = Add else Edit
*   Return Value  nil
static function updatehead( mWHAT )
***********************************
   local mCOMCODE , mCOMNAME , mMINIMUM , mMAXIMUM , mSIGNEES , mREQA , mREQB
   local mPERFORMING  := .t. , mRECNO := recno(), mcolor := setcolor()
   local getlist      := {}, mscreen := savescreen( ,,, )

   if ( upper( mWHAT ) == 'A', eval({|| COMCODES->(dbgoto(lastrec()+1)), CENTER( 24, 'w+/n','╝ Add Record ╞')}),;
                               eval({|| mWHAT := 'R', CENTER ( 24, 'w+/n', '╝ Edit Record ╞')}))
   eval({|| mCOMCODE  := COMCODES->COMCODE ,;
            mCOMNAME  := COMCODES->COMNAME ,;
            mMINIMUM  := COMCODES->MINIMUM ,;
            mMAXIMUM  := COMCODES->MAXIMUM ,;
            mSIGNEES  := COMCODES->SIGNEES ,;
            mREQA     := COMCODES->REQA    ,;
            mREQB     := COMCODES->REQB    })
   setcolor( 'gr+/b, w+/g,,, gr+/b' )
   do while mPERFORMING
      @ 04, 44 get mCOMCODE   pict '@X' when mWHAT == 'A' valid chkmCOMCODE ( mCOMCODE ) .AND. !EMPTY(mCOMCODE)
      @ 05, 40 get mCOMNAME   pict '@XS20'          VALID !EMPTY(mCOMNAME)
      @ 06, 40 get mMINIMUM   pict '999,999,999.99' valid mMINIMUM > 0
      @ 07, 40 get mMAXIMUM   pict '999,999,999.99' valid chkMaxMin ( mMINIMUM, mMAXIMUM )
      @ 08, 40 get mSIGNEES   pict '99'             VALID !EMPTY(mSIGNEES)
      @ 09, 40 get mREQA      pict '99'            
      @ 10, 40 get mREQB      pict '99'

      setcursor( 3 )
      read
      setcursor( 0 )

      if lastkey() == K_ESC
         if ESC_PRESSED( mWHAT )
            exit
         else
            loop
         endif
      endif
      if CONFIRM('Are all entries correct?')
         MSGWIN(5,40,'Saving','w+/bg','r*/bg','on')
         if COMCODES-> ( NETLOCK( mWHAT, 0 ) )
               eval({||;
                     COMCODES->COMCODE :=  mCOMCODE             ,;
                     COMCODES->COMNAME :=  mCOMNAME             ,;
                     COMCODES->MINIMUM :=  mMINIMUM             ,;
                     COMCODES->MAXIMUM :=  mMAXIMUM             ,;
                     COMCODES->SIGNEES :=  mSIGNEES             ,;
                     COMCODES->REQA    :=  mREQA                ,;
                     COMCODES->REQB    :=  mREQB                ,;
                     COMCODES->brcode  :=  g_par_brch           ;
                })
                COMCODES-> ( dbunlock() )
                COMCODES->( dbcommit() )
                mRECNO := recno()
                exit
         endif
         MSGWIN(5,40,'Saving','w+/bg','r*/bg','off')
      endif
   enddo
   center( 24, 'w+/n', padr( '', 20 ) )
   go mRECNO ; setcursor( 0 )
   setcolor( mcolor )
   restscreen( ,,,, mscreen )
return nil
****************************************
static function chkmCOMCODE ( mCOMCODE )
****************************************
   local mRETVAL := .t. , mRECNO := recno(), mDBF := select(), mNTX := indexord()
   if dbseek ( Comcodes->brcode+mCOMCODE )
      ERROR ('Duplicate Committee Code!')
      mRETVAL := .f.
   endif
   select ( mDBF ) ; set order to ( mNTX ) ; dbgoto ( mRECNO )
return mRETVAL
************************************
static function ESC_PRESSED( mWHAT )
************************************
   local mRETVAL := .f.
   if ESCKEY()
      if( upper( mWHAT ) == 'A', Comcodes->( dbskip( -1 ) ), nil )
      mRETVAL := .t.
   endif
return mRETVAL
****************************************
static function search_head( mCOMCODE )
****************************************
   local mRECNO := Comcodes->( recno() ) , mCURSOR := setcursor ( setcursor() )
   local mSCR   := savescreen ( ,,, ), mBrcode := g_par_brch
   memvar getlist

   center( 24, 'w+/n', '╝ Search Record ╞' )
   setcolor( 'gr+/b, w+/g,,, gr+/b' )   
   @ 04,40 get mBrcode pict '@999'
   @ 04,44 get mCOMCODE pict '@99'

   setcursor( 3 )   
   read
   setcursor( 0 )

   if COMCODES->( dbseek ( mBrcode+mCOMCODE ) )
      mRECNO := recno()
   else
      if lastkey() != K_ESC .and. !empty( mCOMCODE )
         ERROR ( 'No such Committee Code!' )
      endif
   endif

   restscreen( ,,,, mSCR )
   Comcodes->( dbgoto ( mRECNO ) )
   setcursor ( mCURSOR )
return nil
************************************************************
static function search_detail( mCOMCODE, mGRUPCODE, mROW )
************************************************************
   local mRECNO := recno(), mSCR := savescreen ( ,,, ), mLCOLOR := setcolor()
   memvar getlist

   center( 24, 'w+/n', '╝ Search Record ╞' )
   fshadow( 15, 11, 17, 26, 2, 'n/w' )
   setcolor( 'bg+/w, w+/n,,, gr+/w' )
   @ 16, 12 say 'Group Code ' get mGRUPCODE pict 'X'

   setcursor( 3 )
   read
   setcursor( 0 )

   if dbseek ( g_PAR_BRCH+mCOMCODE + mGRUPCODE )
      mRECNO := recno()
   else
      if( lastkey()!=K_ESC .and. !empty( mGRUPCODE ), ERROR( 'No such Group Code!' ), nil )
   endif
   dbgoto ( mRECNO ); restscreen( ,,,, mSCR ); setcursor ( 0 ); setcolor( mLCOLOR )
return nil
******************************************************
static function delete_detail( mCOMEMBER, mGRUPCODE )
******************************************************
   if CONFIRM('Delete Group Code ' +mGRUPCODE+ '?')
      MSGWIN(12,35,'Deleting','W+/BG','R*/BG','ON')

      if NETLOCK( 'R', 0 )
         Comember->( dbdelete() )
         Comember -> ( dbskip ( 1 ) )
         if( Comember->( eof()  ) .or. Comember->COMCODE != mCOMEMBER, Comember->( dbseek ( Comcodes->brcode + mCOMEMBER ) ), nil )
         Comember->( dbunlock() )
      endif

      MSGWIN(12,35,'Deleting','W+/BG','R*/BG','OFF')
   endif
return nil
***************************************
static function update_detail ( mWHAT )
***************************************
   local mSCR := savescreen(,,,), mCOMCODE := Comcodes->COMCODE
   local mGRUPCODE, mINITIALS, mSHORTNAME, mFULLNAME
   local mRECNO   := recno(), mCURSOR  := setcursor(), getlist := {}
   
   if( upper( mWHAT ) == 'A', eval({|| Comember->(dbgoto(lastrec()+1)), CENTER( 24, 'w+/n','╝ Add Record ╞')}),;
                              eval({|| mWHAT := 'R', CENTER ( 24, 'w+/n', '╝ Edit Record ╞')}))
   eval({|| mGRUPCODE  := Comember->GRUPCODE ,;
            mINITIALS  := Comember->INITIALS ,;
            mSHORTNAME := Comember->SHORTNAME,;
            mFULLNAME  := Comember->FULLNAME })
   fshadow( 15, 34, 20, 68, 2, 'n/w')
   setcolor( 'bg+/w, w+/n,,, gr+/w' )

   do while .t.
      @ 16, 35 say 'Group Code ' get mGRUPCODE  pict '@X'    when mWHAT == 'A' valid chkGRUPCODE ( mGRUPCODE ) .AND. !EMPTY(mGRUPCODE)
      @ 17, 35 say '  Initials ' get mINITIALS  pict '@X'    valid !empty ( mINITIALS )
      @ 18, 35 say 'Short Name ' get mSHORTNAME pict '@X'    valid !empty ( mSHORTNAME)
      @ 19, 35 say ' Full Name ' get mFULLNAME  pict '@XS20' valid !empty ( mFULLNAME )

      setcursor( 3 )
      read
      setcursor( 0 )

      if lastkey() == K_ESC
         if esckey()
            exit
         else
            loop
         endif
      endif

      if ( CONFIRM ( 'Are all entries correct?' ) )
         MSGWIN(16,44,'Saving','w+/bg','r*/bg','on')
         if Comember->( NETLOCK( mWHAT, 0 ) )
            eval({|| Comember->COMCODE   := mCOMCODE  ,;
                     Comember->GRUPCODE  := mGRUPCODE ,;
                     Comember->INITIALS  := mINITIALS ,;
                     Comember->SHORTNAME := mSHORTNAME,;
                     Comember->brcode    := comcodes->brcode,;
                     Comember->FULLNAME  := mFULLNAME})
           Comember->( dbunlock() )
           Comember->( dbcommit() )
           mRECNO := recno()
           *exit     && RED 11102004 TO EARLY TO EXIT
         endif
         MSGWIN(16,44,'Saving','w+/bg','r*/bg','off')
         EXIT
      endif
   enddo
   go mRECNO; setcursor( mCURSOR ) ; setcolor ( NRM )
   restscreen(,,,,mSCR)
return nil
*****************************************
static function chkGRUPCODE ( mGRUPCODE )
*****************************************
   local mRETVAL := .t. , mRECNO := recno()
   if empty ( mGRUPCODE ) 
      return .f.
   endif
   if !mGRUPCODE $ 'AB'
      ERROR ( 'Invalid Group Code!')
      mRETVAL := .f.
   endif
   dbgoto ( mRECNO )
return mRETVAL
************************************************
static function chkMaxMin ( mMINIMUM, mMAXIMUM )
************************************************
 loca mretval
 if ( mMINIMUM <= 0       , mRETVAL := .f., mRETVAL := .t. )
 if ( mMINIMUM > mMAXIMUM , eval({|| ERROR ('Minimum Exceeds Limit'), mRETVAL :=.f.}), Nil )
return mRETVAL
******************************
Static function amsm0300open()
******************************
   local mRETVAL := .f.
   if NETUSE('&g_AMS_PATH\Comcodes',.f.,5)
      set index to &g_AMS_PATH\Comcodes
      if NETUSE('&g_AMS_PATH\Comember',.f.,5)
         set index to &g_AMS_PATH\Comember
		 if NETUSE('&g_grf_PATH\branches',.F.,5)
			dbsetindex('&g_grf_PATH\branches')
				mRETVAL := .t.
		 endif		
      endif
   endif
return mRETVAL

**********************************
*
static function _SELCT_BY()     
**********************************
   local _cscr := savescreen (,,,),menulist := {},bx := setcolor()
   
   setcolor  ( 'bg/gr+,n/w,,, w/gr+' )
   @ 08,25 clear to 11,35
   @ 08,25 to 11,35
   @ 08, 26 say 'Print' color 'W+/bg'
   @ 09,26 prompt 'By Branch'
   @ 10,26 prompt 'All  '
   menu to _USER_choice
   do case
      case _user_choice == 1
			 fbrch4300()
      case _user_choice == 2
			
   endcase
setcolor  ( bx )
   restscreen  (,,,,_cscr)
return lastkey () != K_ESC


***************************
*
static function fbrch4300()
***************************
local  ax := !.t., getlist := {}, bx := setcolor()
//memvar dit, mpage

fshadow ( 10, 30, 12, 49, 2, 'bg/gr+' )

setcolor  ( 'bg/gr+,n/w,,, w/gr+' )
setcursor (1)
//@  10, 31 say 'Execution Date' color 'n/bg'
@ 11, 32 say 'Branch Code  '
@ 11, 45 get cbrcode pict '@R 999'  valid !empty(cbrcode)  


setcursor ( 3 )
read           // timeout 20 exitevent blankscr3( -1 )
setkey    ( K_ESC, nil )

setcursor ( 0  )
setcolor  ( bx )


return 

************************
*
function _fprint0900()
************************
memvar _USER_choice
private mpage := 1, _ghead:= .t., nbrcode

fHead0900()
if _USER_choice == 1
	COMCODES->(dbseek(cBRCODE))
endif	

nbrcode:=COMCODES->BRCODE
Branches->(dbseek(nbrcode))

@ prow()+ 1   , 02 say 'Branch: '
SETFONT('BOLD')
@ prow()   , 12 say BRANCHES->BRCODE+'-'+BRANCHES->BRNAME
SETFONT('UNBOLD')
do while if(_USER_choice == 2, !COMCODES->(eof()), cBRCODE == COMCODES->BRCODE  )
					
			if prow() >= 57
			  // setfont( upper( 'uncondensd' ) )
				__eject()
				fHead0900()
			endif				
		
		if COMCODES->BRCODE != nbrcode
				__eject()
				fHead0900()
				_ghead := .t.
				nbrcode:=COMCODES->BRCODE
				Branches->(dbseek(nbrcode))
				@ prow()+ 1   , 02 say 'Branch: '
				SETFONT('BOLD')
				@ prow()   , 12 say BRANCHES->BRCODE+'-'+BRANCHES->BRNAME
				SETFONT('UNBOLD')
		endif
		
		@ prow()+ 1   , 02 say 'Committee Code            :'+' '+Comcodes->brcode + "-" + Comcodes->COMCODE
		@ prow()+ 1   , 02 say 'Committee Name            :'+' '+Comcodes->COMNAME
		@ prow()+ 1   , 02 say 'Credit Limit:  Minimum    :'+' '+transform( Comcodes->MINIMUM, '999,999,999.99' )
		@ prow()+ 1   , 02 say '               Maximum    :'+' '+transform( Comcodes->MAXIMUM, '999,999,999.99' )
		@ prow()+ 1   , 02 say 'Required Number of Signees:'+' '+transform( Comcodes->SIGNEES, '99' )
		@ prow()+ 1   , 02 say 'Required A                :'+' '+transform( Comcodes->REQA   , '99' )
		@ prow()+ 1   , 02 say 'Required B                :'+' '+transform( Comcodes->REQB   , '99' )
		
		//@ prow()+ 1   , 3 say 'Group   Initial   Short Name        Full Name'
			if prow() >= 57
				__eject()
				fHead0900()
/*			 setfont( upper( 'normal' ) )	
		     @ prow() + 1, 1 say 'здддддддддбдддддддддбддддддддддддддддбддддддддддддддддддддддддддддддддддддддддд©'
		     @ prow() + 1, 1 say 'Ё  Group  Ё Initial Ё   Short Name   Ё             Full Name                   Ё'
		     @ prow() + 1, 1 say 'юдддддддддадддддддддаддддддддддддддддаддддддддддддддддддддддддддддддддддддддддды'		
*/			endif					
	/*	if  _ghead .and. COMCODES->BRCODE == nbrcode
			_ghead := .f.
			
			 setfont( upper( 'normal' ) )	
		     @ prow() + 1, 1 say 'здддддддддбдддддддддбддддддддддддддддбддддддддддддддддддддддддддддддддддддддддд©'
		     @ prow() + 1, 1 say 'Ё  Group  Ё Initial Ё   Short Name   Ё             Full Name                   Ё'
		     @ prow() + 1, 1 say 'юдддддддддадддддддддаддддддддддддддддаддддддддддддддддддддддддддддддддддддддддды'		
		else
		//	 @ prow() + 1, 1 say '  '
		endif*/
		if COMEMBER->(dbseek(COMCODES->BRCODE+COMCODES->COMCODE))
			
			do while COMCODES->BRCODE+COMCODES->COMCODE == COMEMBER->BRCODE+COMEMBER->COMCODE	
				if prow() >= 57
				 //  setfont( upper( 'uncondensd' ) )
					__eject()
					fHead0900()
				endif		
				
				@ prow()+ 1   , 5 say COMEMBER->grupcode+'       '+COMEMBER->initials+'      '+COMEMBER->Shortname+'   '+substr(COMEMBER->Fullname,1,40)
				COMEMBER->(dbskip(1))
			enddo
		endif
		@ prow()+ 1   , 1 say '  '
	COMCODES->(dbskip(1))
enddo

return  

// ддддддддддддддддддддддддддд
   static function fHead0900()
// ддддддддддддддддддддддддддд
   memvar mpage, gSYS_NAME, gCOMPANY, nwpage
   
   setfont( upper( 'INIT' ) )
   setprc  ( 0,0 ) 
   setfont( upper( 'uncondensd' ) )
   SETFONT('PICA')
   @ prow()+1,0 say gSYS_NAME
   @ prow(),80-11-0 say 'Page : ' + str(mpage++,4)
   @ prow()+1,0        say 'AMSM0900'
   @ prow() ,80-19-0 say dtoc(date()) + ' ' + time()
   @ prow()+1,0        say 'User: ' + g_user_id

      PAGECENTER(prow()+2,80,'ORIX METRO LEASING and FINANCE CORPORATION')
      SETFONT('BOLD')
      PAGECENTER(prow()+1,80,'APPROVING COMMITTEES ')
      SETFONT('UNBOLD')
  @ prow() + 1, 1 say '  ' 
 // setfont( upper( 'uncondensd' ) )
	// prnreptitle( 80, 5, mpage++, 'ACCOUNTS WITH LACKING DOCUMENTS', 'MISU4300', gSYS_NAME, gCOMPANY )
	//PAGECENTER(prow()+1,80,'Execution Date for the Period '+alltrim(dtoc(sdate)) + ' to ' +alltrim(dtoc(edate)))
   //  @ prow() + 1, ( 80 - 16 ) / 2 say 'As of ' + dtoc( Flag->lastclosed )
	
			 setfont( upper( 'normal' ) )	
		     @ prow() + 1, 1 say 'здддддддддбдддддддддбддддддддддддддддбддддддддддддддддддддддддддддддддддддддддд©'
		     @ prow() + 1, 1 say 'Ё  Group  Ё Initial Ё   Short Name   Ё             Full Name                   Ё'
		     @ prow() + 1, 1 say 'юдддддддддадддддддддаддддддддддддддддаддддддддддддддддддддддддддддддддддддддддды'		
	
 /*    setfont( upper( 'condensed' ) )
     @ prow() + 1, 1 say 'здддддддддбддддддддддбддддддддддбдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©'
     @ prow() + 1, 1 say 'Ё         Ё          Ё          Ё                                                                                                          Ё'
     @ prow() + 1, 1 say 'Ё User ID Ё   Date   Ё   Time   Ё                                                  Action                                                  Ё'
     @ prow() + 1, 1 say 'юдддддддддаддддддддддаддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды'
*/	 
   return


*
*                      End of the program ( amsm0900.prg )
*
