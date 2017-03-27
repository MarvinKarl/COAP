/*дддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
 Ё   PROGRAM ID...: amsu0200.prg                                        Ё
 Ё   Description..: update contact information                          Ё
 Ё   Author.......: Marvin T. Sabile                                    Ё
 Ё   Date.........: 9:04 AM 7/12/2011                                   Ё
 цдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
 Ё                         U P D A T E S                                Ё
 цдддддддддддддддддддбдддддддддддддддбдддддддддддддддддддддддддддддддддд╢
 Ё        Who        Ё     When      Ё               Why                Ё
 цдддддддддддддддддддедддддддддддддддедддддддддддддддддддддддддддддддддд╢
 Ё                   Ё               Ё                                  Ё
 юдддддддддддддддддддадддддддддддддддадддддддддддддддддддддддддддддддддд*/

#include 'BOX.CH'
#include 'COLF.CH'
#include 'INKEY.CH'

****************************
*
FUNCTION CHANGE_BR()
****************************
   
if empty(alias())

   if !NETUSE('&g_AMS_PATH\REGHEAD',.F.,5)
      return
   endif
   set index to &g_AMS_PATH\REGHEAD
   
   if REGHEAD->(dbseek(gUSER_ID)) 
	  Begin sequence
		fOpen0200()
		fMain0200()
	  End sequence
   else
     error('You have no rights to access this utility!')   
   endif

   dbcloseall ()
   //BRANCHES->(dbclosearea())
   //REGHEAD->(dbclosearea())
   //AXMAST->(dbclosearea())
   
   __mrelease ( "*",.t. )
else
   //error('Cannot change branch! There are open database!')
endif

return

// ддддддддддддддддддддддддддд
   static function fMain0200()
// ддддддддддддддддддддддддддд
local mscreen := SAVESCREEN(6,1,22,80)
local cCode:=space(3)

local mainsel    := 1, mx, moldwrap := set( _SET_WRAP, .t. ), mmainsel
local moldcursor := setcursor( 0 ), mcol, msubsel, action, mtick
local moldmessrow, maxwidth, mbuffer, mtempsel, max, mbx, mSCR
local BRNAME := SPACE(18)
local aBranch := {}

fshadow   ( 8,24,10,58,2,'w+/gr' )
setcursor ( 1 )

cCode   := g_PAR_BRCH

aBranch := aBranches( gUSER_ID )

//@  9,25  say 'BRANCH ╞'               COLOR 'w+/gr'
//@  9,36  get cCode when eval({|| if (BRANCHES->(dbseek(cCode)),BRNAME := subs(BRANCHES->BRNAME,1,18),space(18)),.t.}) valid CHK_BRCODE(gUSER_ID,cCode)
//@  9,39  say '-'+BRNAME  COLOR 'w+/gr' //eval({|| BRANCHES->(dbseek(cCode)),subs(BRANCHES->BRNAME,1,18)}) COLOR 'w+/gr'


   @ 9,25,13,57 get cCode LISTBOX aBranch DROP;
                 valid CHK_BRCODE(gUSER_ID,cCode)
				 
setcursor(3)
read
setcursor(1)


//@  9,39  say '-'+eval({|| BRANCHES->(dbseek(cCode)),alltrim(BRANCHES->BRNAME)})
if lastkey() == K_ESC
   restscreen(6,1,22,80, mscreen )
   return
endif

if lastkey() == K_ENTER
	//If confirm('Save new Entry?')

	   g_PAR_BRCH := cCode
	   
	   BRANCHES->(dbseek(g_par_brch))
	   gbranch := '('+g_PAR_BRCH+'-'+RTRIM(BRANCHES->BRNAME)+')'
   
	   //setkey(K_ESC,{ || change_br()})
	   
	   gSYS_NAME := subs(gSYS_NAME,1,38)+' '+gbranch
       
	   //@  2,  0 say padr( gSYS_NAME,80)+' '+'('+g_PAR_BRCH+'-'+curr_branch+')' color 'w/n'
	   //@  2, 79 - ( ( len( alltrim( gUSER_ID ) ) + 7 ) ) say  'User : ' + alltrim( gUSER_ID )  color 'w/n'
       
	   dispbegin ()
	   setcolor  ( gNORMAL )
	   @  1,  0 say padr(gCOMPANY,80) color 'w/n'
	   @  1, 69 say dtoc( gTRANDATE ) color 'w/n'
	   @  2,  0 say padr( gSYS_NAME,80) color 'w/n'
	   @  2, 79 - ( ( len( alltrim( gUSER_ID ) ) + 7 ) ) say  'User : ' + alltrim( gUSER_ID )  color 'w/n'
	   
	   dispend()
	  
	//endif

endif
restscreen(6,1,22,80, mscreen )

return

/*
static function change_br()

gSYS_NAME := subs(gSYS_NAME,1,38)+' '+gbranch
        
dispbegin ()
setcolor  ( gNORMAL )
@  1,  0 say padr(gCOMPANY,80) color 'w/n'
@  1, 69 say dtoc( gTRANDATE ) color 'w/n'
@  2,  0 say padr( gSYS_NAME,80) color 'w/n'
@  2, 79 - ( ( len( alltrim( gUSER_ID ) ) + 7 ) ) say  'User : ' + alltrim( gUSER_ID )  color 'w/n'
dispend()


return
*/

static function aBranches( cUser )
   local aList := {}
   local ax_found := .f.

   if !NETUSE('&g_GRF_PATH\AXBRANCH',.F.,5)
      USER_OK = .F.
      return nil
   endif
   set index to &g_GRF_PATH\AXBRANCH
   
   IF BRANCHES->( dbseek(g_PAR_BRCH) )
      aAdd( aList, { padr( trim(branches->brname) +"-"+branches->brcode, 40), ;
                branches->brcode } )
	  default_br := g_PAR_BRCH	
   ENDIF
   
   //AXBRANCH->( dbseek(cUser) )
   
   if REGHEAD->(dbseek(cUser))
	   while ! REGHEAD->( eof() ) .AND. REGHEAD->user_id == cUser
		  BRANCHES->( dbseek(REGHEAD->brcode) )
		  //if BRANCHES->brcode <> '701' .and. BRANCHES->brcode <> '801'                        //ORC & OALP
		  if BRANCHES->brcode <> default_br

				aAdd( aList, { padr( trim(branches->brname) +"-"+branches->brcode, 40), ;
						 branches->brcode } )

		  endif
		  ax_found := .t.	 
		  //endif
	   REGHEAD->( dbskip() )
	   enddo
   endif
   //AXBRANCH->(dbclosearea())
   
   if !ax_found
      aList := {}
   endif
   
return aList


****************************************
*
STATIC FUNCTION CHK_BRCODE(gUSER_ID,cCode)
****************************************
LOCAL lRETVAL := .T.
//local ax := axmast->(recno())

if cCode == "701" .or. cCode == "801"
   lRETVAL  := .F.
   error([Your Branch Code is not allowed in this system!])
   //gUSER_ID := SPACE(6)
else

   IF REGHEAD->(DBSEEK(gUSER_ID+cCode))

      IF NETUSE('&g_GRF_PATH\BRCODE',.F.,5)
         DBSETINDEX('&g_GRF_PATH\USER')
         IF BRCODE->(DBSEEK( gUSER_ID ))
	        if BRCODE->(netlock('R',0))
	           BRCODE->AMS := cCode
			   BRCODE->(dbunlock())
			   BRCODE->(dbcommit())
		    endif
         ENDIF
        BRCODE->(DBCLOSEAREA())
      ENDIF

      //dbselectarea('AXMAST')
      //AXMAST->(dbgoto(ax))
   ELSE
   
      ERROR('YOU DO NOT HAVE ACCESS IN THIS BRANCH!')
	  BRNAME   := space(18)
      lRETVAL  := .F.
	  
   ENDIF
endif

RETURN lRETVAL


// ддддддддддддддддддддддддддд
   static function fOpen0200()
// ддддддддддддддддддддддддддд

   
   if !NETUSE('&g_GRF_PATH\BRANCHES',.F.,5)
      USER_OK = .F.
      return nil
   endif
   set index to &g_GRF_PATH\BRCODE,&g_GRF_PATH\BRANCHES
