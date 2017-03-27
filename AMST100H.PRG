/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   program ID.........:  amst100h.prg                                         ³
³   description........:  Documents Checklist ( Availments sub-module )        ³
³   author.............:  Ariel B. Bulan                                       ³
³   date...............:  02:49pm 02-Dec-1994                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                         U P D A T E S                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        Who        ³     When      ³               Why                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                   ³               ³                                          ³
³    ABB            ³  10.22.2004   ³     FOR ONLINE                           ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include "Colf.ch"
#include "Inkey.ch"

***********************************************************
*
*
function doc_checklist( _macctno, add_one_miss, misentered )
***********************************************************
local mblock := { | x | Docday->acctno == x }, cb, mdbf_, mswitch := .t., mcolor := setcolor()        && RED 062305 REMOVED 'DOCDAY->BRCODE+
local keys_  := { '<Ins>\-Add ', '<F2>\Edit ', '<F3>\Color ', '<Del>\ ', '<Esc>\' }, mscreen := savescreen( ,,, )
local tbcol_ := { tbcolumnnew( padr( "Document Name", 13 ), { || tran( Docday->doccode + ' ' + dispdocname( Docday->doccode ), '@!' ) } ),;     && RED 031405 ADDED 'DOCDAY->BRCODE
                  tbcolumnnew( padr( "Status"       , 14 ), { || Docday->status + ' ' + if( Docday->status $ '12', if( Docday->status == '1', 'On-Hand', 'Lacking'), space( 7 ) ) } ),;
                  tbcolumnnew( padr( "Doc Date"     , 10 ), { || tran( Docday->docdate , '@D' ) } ),;
                  tbcolumnnew( padr( "Date Rec'd"   , 10 ), { || tran( Docday->recdate , '@D' ) } ),;
                  tbcolumnnew( padr( "Recby"        ,  5 ), { || tran( Docday->receiver, '@!' ) } ),;
                  tbcolumnnew( padr( "Chkby"        ,  5 ), { || tran( Docday->checker , '@!' ) } ),;
                  tbcolumnnew( padr( "Remarks"      , 10 ), { || tran( Docday->remarks , '@!' ) } ) }

memvar tbkill_lastrec, ax_level, g_user_id
private mis_add_one := add_one_miss, macctno := RIGHT(_macctno,14), mBRCODE := LEFT(_mACCTNO,3)

if chkpass( procname(), ax_level, g_user_id )
   mdbf_ := savedbf()   
   tbkill_lastrec := 1                              
   waiton( 'wait a second, please!',, 'n/w' )

   dbselectar ( "Docday" )
   IF Docday->   ( dbseek( tbkill_code := g_PAR_BRCH+macctno ) )   && RED REMOVED 'sbrcode+
      mSWITCH := .F.
   ENDIF
   /*
   Docday->   ( dbeval( { || tbkill_lastrec++ ,;
                             mswitch := .f.    ;
                        },,;
                        { || DOCDAY->BRCODE+Docday->acctno == macctno .and.;   && RED REMOVED 'Docday->brcode == Acctdaly->brcode .and. ;
                            !Docday->(eof()) ;
                        } ;
                      ) ;
              )
   */
   waitoff ()
   if mswitch
      if !mis_add_one
         error( "No Record Found!" )
         IF CURRBRCH(mBRCODE)
            __keyboard( chr( K_INS ) )
         ENDIF
      endif   
   endif

//    Docday->( dbseek( tbkill_code := macctno ) )    abb 10.22.2004

   Docday->( dbseek( g_PAR_BRCH+macctno ) )   && RED REMOVED 'sbrcode+     && RED 062306 'g_PAR_BRCH

   cb := __tb_maker( tbcol_, keys_, 09, 2, 21, 64,,, .f., macctno, mblock,,,,,,sbrcode )
   Docday->( __tb_stabilizer( cb, { | o, k | caseh100( o, k ) } ) )
   restdbf( mdbf_ )                             
   __mrelease( '*', .t. )
endif             
setcolor( mcolor )
restscreen( ,,,, mscreen )
return( nil )
********************************************************************
static function caseh100( mbrowse, mkey )
********************************************************************
local misfromsubmenu := mreturn := .t., mcolor := setcolor(), mscreen := savescreen( ,,, )
memvar mis_add_one, ax_level, g_user_id, macctno

misfromsubmenu := if( mis_add_one, .f., misfromsubmenu )

do case
   case mkey == K_INS
        if CURRBRCH(mBRCODE) .AND. chkpass( 'A', ax_level, g_user_id )      &&RED 062305 LEFT(mACCTNO,3)
           if docday_update( 'A', misfromsubmenu, macctno )
              tb_refresh( mbrowse, 'a' )
           endif
        endif              
   case mkey == K_F2
        if CURRBRCH(mBRCODE) .AND. chkpass( 'E', ax_level, g_user_id )
           if DOCDAY->BRCODE+Docday->acctno != g_PAR_BRCH+macctno
              error( 'Nothing to Edit!' )
              Docday->( dbseek( macctno ) )   && RED REMOVED 'sbrcode+
           else  
              if docday_update( 'E', misfromsubmenu, macctno )
                 tb_refresh( mbrowse, 'c' )
              endif
           endif
        endif            
   case mkey == K_DEL
        if CURRBRCH(mBRCODE) .AND. chkpass( 'D', ax_level, g_user_id )
           if DOCDAY->BRCODE+Docday->acctno != g_PAR_BRCH+macctno
              error( 'Nothing to Delete!' )
              Docday->( dbseek( macctno ) )  && RED REMOVED 'sbrcode+
           else 
              if confirm( 'Delete ' + tran( alltrim( Docday->doccode +;
                 ' ' + dispdocname( Docday->doccode ) ), '@!' ) + '?' )
                 Docday->( netlock( 'R', 0 ) )
                 Docday->( dbdelete() )
                 Docday->( dbskip( +1 ) )
                 if DOCDAY->BRCODE+Docday->acctno != g_PAR_BRCH+macctno &&RED REMOVED '.or. Docday->brcode != sbrcode
                    Docday->( dbseek( macctno ) )  && RED REMOVED 'sbrcode+
                 endif
                 tb_refresh( mbrowse, 'a' )
              endif
           endif
        endif   
   otherwise        
         mreturn := !mreturn
endcase         
setcolor( mcolor )
restscreen( ,,,, mscreen )
return( mreturn )
/*
*************************************************
function dispdocname(mdoccode)
*************************************************
   Doccodes->(dbseek(mdoccode))
return Doccodes->DOCNAME
*/
************************************************************************
static function Docday_update( mwhat,misfromsubmenu,macctno)
************************************************************************
local mretval := .t., mrecno := Docday->(recno()), mscr := savescreen (,,,)
local mcursor := setcursor(), mcolor := setcolor (), mmess, mcontinue := .t.
local mrow := 13, mcol := 14, getlist := {}, mdoccode, mdocdate, mrecdate
local mreceiver, mchecker, mstatus, mremarks
local mstat_choices := { '1 = On-Hand','2 = Lacking' }

   misfromsubmenu := if ( misfromsubmenu==nil, .f. , misfromsubmenu )
   /*    RED 040405  PANG PATAGAL LANG ITO.
   if mwhat == 'A'
      if no_available()           // if all document codes were already used ?
         return .f.               // return to calling program ...
      endif
   endif
   */
   if ( upper(mwhat)==chr(65), Docday->(dbgoto(lastrec()+1)), mwhat:=chr(82) )
   mmess := if(upper(mwhat)==chr(65),'® Add Record ¯','® Edit Record ¯')
   eval({|| mdoccode := Docday->DOCCODE, mdocdate  := Docday->DOCDATE ,;
            mrecdate := Docday->RECDATE, mreceiver := Docday->RECEIVER,;
            mchecker := Docday->CHECKER, mstatus   := Docday->STATUS  ,;
            mremarks := Docday->REMARKS })
   fshadow ( mrow, mcol, mrow+8, 61, 2, 'n/gr' )
   setcolor( 'w/gr, n+/w,,, w+/gr' )
   center  ( 24, 'w+/n',mmess )
   @ mrow+1, 36 say upper ( left(dispdocname (mdoccode) ,20) ) color 'w/gr'
   @ mrow+4, 36 say upper ( left(dispreceiver(mreceiver),25) ) color 'w/gr'
   @ mrow+5, 36 say upper ( left(dispreceiver(mchecker ),25) ) color 'w/gr'
   @ mrow+6, 36 say upper (if(mstatus $ '12', if(mstatus=='1','On-Hand','Lacking'),space(7)) ) color 'w/gr'
   do while mcontinue
      @ mrow+1,mcol+1 say 'Document Code ' get mdoccode  pict '@X' VALID NEWDOC(@mDOCCODE,mACCTNO,mWHAT,mROW+1) .and. !empty(mdoccode)  && RED 040505 when check_doccode( mwhat, @mdoccode, mrow+1,macctno )
      @ mrow+2,mcol+1 say 'Document Date ' get mdocdate  pict '@D' 
      @ mrow+3,mcol+1 say 'Date Received ' get mrecdate  pict '@D' 
      @ mrow+4,mcol+1 say '  Received by ' get mreceiver pict '@X' when check_receiver( @mreceiver, mrow+4 )
      @ mrow+5,mcol+1 say '   Checked by ' get mchecker  pict '@X' when check_checker ( @mchecker , mrow+5 )
      @ mrow+6,mcol+1 say '  Doc. Status ' get mstatus   pict '@X' when if ( lastkey() != K_ESC, check_status  ( mstat_choices, @mstatus, mrow+6 ), .t. ) valid !empty(mstatus) .and. mstatus $ '1_2'
      @ mrow+7,mcol+1 say '      Remarks ' get mremarks  pict '@X' 
      setcursor( 3 )      
      read
      setcursor( 0 )
      if lastkey() == K_ESC
         if esckey()
            mcontinue := .f.
         endif   
         loop
      endif
      if lastkey() == K_ENTER
         if !misfromsubmenu
            save_docday( mwhat,macctno, mdoccode  , mdocdate, mrecdate, mreceiver, mchecker, mstatus, mremarks)
            mcontinue := .f. ; mretval := .t.
         else
            if confirm( 'Are all entries correct?' )
               save_docday( mwhat,macctno, mdoccode, mdocdate, mrecdate, mreceiver, mchecker, mstatus, mremarks)
               mrecno:= Docday->(recno()) ; mcontinue := .f. ; mretval := .t.
            endif
         endif
      endif
   enddo
   Docday->   (dbgoto(mrecno))
   setcursor  (mcursor )
   setcolor   (mcolor  )
   restscreen (,,,,mscr)
return (mretval)
*-------------------------------------------------------------------------------
STATIC FUNCTION NEWDOC(mDOCCODE,mACCTNO,mWHAT,mROW)              && RED 040405
LOCAL lRETVAL := .T.     && RED 062205 REMOVED '.F. AS ORDERED BY AVP.

IF !EMPTY(mDOCCODE)
   IF DOCCODES->(DBSEEK(mDOCCODE))         && RED 062305 REMOVED 'g_PAR_BRCH+
      IF mWHAT <> 'R' .AND. DOCDAY->(DBSEEK(g_PAR_BRCH+mACCTNO+mDOCCODE))     && RED 062205 ADDED 'g_PAR_BRCH
         ERROR('Document Code already Exists!')
         lRETVAL := .T.
      ELSE
         lRETVAL := .T.
      ENDIF
      @ mROW, 36 SAY UPPER ( LEFT(DISPDOCNAME(mDOCCODE),20) )         COLOR 'W/GR'
   ELSE
      ERROR('Invalid document code.')
   ENDIF
ELSE
   DOCNAME(@mDOCCODE,mACCTNO)
   @ mROW, 36 SAY UPPER ( LEFT(DISPDOCNAME(mDOCCODE),20) )            COLOR 'W/GR'
   IF EMPTY(mDOCCODE)
      check_doccode( mwhat, @mdoccode, mrow,macctno )
   ENDIF
ENDIF

RETURN lRETVAL
*-------------------------------------------------------------------------------
STATIC FUNCTION DOCNAME(mDOCCODE,mACCTNO)                         && RED 040405
LOCAL cDOCNAME := SPACE(40)
LOCAL SCRBOX := SAVESCREEN(13,13,15,65)
LOCAL aDOC := {}, nIDX, SCR := SAVESCREEN(15,14+11,19,64+11), lRETVAL := .F.
LOCAL nNTX := DOCCODES->(INDEXORD()), cCOLOR := SETCOLOR()
LOCAL GETLIST := {}

@ 13,13 CLEAR TO 15,65
@ 13,13 TO 15,65
@ 14,14 SAY 'DOC NAME ' GET cDOCNAME PICT '@!' VALID VALDOCNME(cDOCNAME)
READ

IF LASTKEY() == K_ENTER

   DOCCODES->(DBSETORDER(2))

   IF !EMPTY(cDOCNAME) .AND. DOCCODES->(DBSEEK(RTRIM(cDOCNAME)))

      DO WHILE DOCCODES->DOCNAME = RTRIM(cDOCNAME) .AND. !DOCCODES->(EOF())
         *IF DOCCODES->BRCODE == g_PAR_BRCH
            *IF !DOCDAY->(DBSEEK(mACCTNO+DOCCODES->DOCCODE))
               AADD(aDOC,DOCCODES->DOCNAME)
            *ENDIF
         *ENDIF
         DOCCODES->(DBSKIP())
      ENDDO

      IF LEN(aDOC) > 1
         SET COLOR TO 'N/W,R/BG'

         nIDX := ACHOICE(15,14+11,19,64+11,aDOC)
         RESTSCREEN(15,14+11,19,64+11,SCR)

         IF LASTKEY() == K_ENTER
            cDOCNAME := aDOC[nIDX]
            IF DOCCODES->(DBSEEK(cDOCNAME))     && RED 062305 REMOVED '+g_PAR_BRCH
               mDOCCODE := DOCCODES->DOCCODE
            ELSE
               mDOCCODE := SPACE(03)
            ENDIF
         ELSE
            mDOCCODE := SPACE(03)
         ENDIF
      ELSEIF LEN(aDOC) = 1
             cDOCNAME := aDOC[1]
             IF DOCCODES->(DBSEEK(cDOCNAME))           && RED 062305 REMOVED '+g_PAR_BRCH
                mDOCCODE := DOCCODES->DOCCODE
             ELSE
                mDOCCODE := SPACE(03)
             ENDIF
      ELSE
         ERROR('Document name not found.')
         *mDOCCODE := SPACE(03)              && RED 062305
      ENDIF
   ENDIF

   DOCCODES->(DBSETORDER(nNTX))

ELSE
   mDOCCODE := SPACE(03)
ENDIF

RESTSCREEN(13,13,15,65,SCRBOX)
SETCOLOR(cCOLOR)

RETURN mDOCCODE
*-------------------------------------------------------------------------------
STATIC FUNCTION VALDOCNME(cDOCNAME)
LOCAL lRETVAL := .F.

DOCCODES->(DBSETORDER(2))
IF DOCCODES->(DBSEEK(RTRIM(cDOCNAME)))
   lRETVAL := .T.
ENDIF
DOCCODES->(DBSETORDER(1))

RETURN lRETVAL
*-------------------------------------------------------------------------------
**************************************************************
static function check_status ( mstat_choices, mstatus, mrow )
**************************************************************
   mstatus := gen_achoice( mstat_choices, val( mstatus ), 'Status Code', mrow+2, 56, mrow+2+len( mstat_choices ), 77, 'w/gr+,w/n,,,w/gr+' )
   @ mrow,  36 say upper(if( mstatus == '1', 'On-Hand', 'Lacking') ) color 'w/gr'
return .f.
************************************************************************
static function check_receiver( mreceiver, mrow)
************************************************************************
   local mcontinue := .t., mscr := savescreen(20,0,24,79)

   center ( 24, 'w+/n','® Search Receiver Code ¯' )
   lb_lkup('Personel',1,1,@mreceiver, 2 , 1, 09, 27, 21, 75, 'W/GR+,W/N,,,W/GR+')
   @ mrow, 36 say upper ( left(dispreceiver(mreceiver),25) ) color 'w/gr'
   restscreen(20,0,24,79,mscr)
return .f.
************************************************************************
static function check_checker( mchecker, mrow)
************************************************************************
   local mcontinue := .t., mscr := savescreen(20,0,24,79)

   center ( 24, 'w+/n','® Search Checker Code ¯' )
   lb_lkup('Personel',1,1,@mchecker, 2 , 1, 09, 27, 21, 75, 'W/GR+,W/N,,,W/GR+')
   @ mrow, 36 say upper ( left(dispreceiver(mchecker),25) ) color 'w/gr'
   restscreen(20,0,24,79,mscr)
return .f.
/*
************************************************************************
static function dispreceiver(mreceiver)
************************************************************************
   Personel->(dbseek(mreceiver))
return Personel->FULLNAME
*/
************************************************************************
static function check_doccode( mwhat,mdoccode,mrow,macctno )
************************************************************************
   local mscr := savescreen(20,0,24,79)

   if mwhat == 'A'
      center ( 24, 'w+/n','® Search Document Code ¯' )
      while .t.
         *---RED 031105---
         *lb_lkup('Doccodes',1,2,@mdoccode, 2 , 1, 09, 27, 21, 75, 'W/GR+,W/N,,,W/GR+')
         *__lb_lkup('Doccodes',1,2,@mdoccode, 2, 3, 1, 09, 13, 21, 75, 'W/GR+,W/N,,,W/GR+')
         __lb_lkup('Doccodes',1,2,@mdoccode, 2, 1, , 09, 13, 21, 75, 'W/GR+,W/N,,,W/GR+')
         *----------------
         Doccodes -> ( dbsetorder (1) )
         if lastkey() != K_ESC
            if Docday->(dbseek(g_PAR_BRCH+macctno+mdoccode))  && RED REMOVED 'sbrcode+   && RED 062305 ADDED 'g_PAR_BRCH
               error('Document Code already Exists!')
               @ mROW, 36 SAY UPPER ( LEFT(DISPDOCNAME(mDOCCODE),20) )     COLOR 'W/GR'
               EXIT           && RED 062205 ADDED AS INSTRUCTED BY AVP.
            else
               @ mrow, 36 say upper ( left(dispdocname(mdoccode),20) ) color 'w/gr'
               exit
            endif
         else
            exit
         endif
      enddo
   endif
   restscreen(20,0,24,79,mscr)
return .f.
*******************************************************************************************************************
static function save_docday( mwhat,macctno, mdoccode  , mdocdate, mrecdate, mreceiver, mchecker, mstatus, mremarks)
*******************************************************************************************************************
   if netlock( mwhat, 0 )
      eval ( {|| Docday->ACCTNO  := RIGHT(macctno,14)  , Docday->DOCCODE := mdoccode,;
                 Docday->DOCDATE  := mdocdate , Docday->RECDATE := mrecdate,;
                 Docday->RECEIVER := mreceiver, Docday->CHECKER := mchecker,;
                 Docday->STATUS   := mstatus  , Docday->REMARKS := mremarks ,;
                 Docday->brcode   := g_PAR_BRCH ;        && RED 062305 REPLACED 'sbrcode
             };
           )
           Docday->( dbunlock() ) ; Docday->( dbcommit() )
   endif
return nil
**************************************************************
static function no_available( mpaycode )
**************************************************************
   local mretval  := .f.  , mrecno := Docday->(recno())
   local mavail   := 0
   Doccodes->(dbgotop())
   *IF DOCCODES->(DBSEEK(g_PAR_BRCH))      && RED 031105 ADDED
      Doccodes->( dbeval({|| if(!Doccodes->(deleted()),mavail++,nil)},,;
                         {|| !Doccodes->(eof()) }))      && RED 062305 '{|| !Doccodes->(eof()) .AND. DOCCODES->BRCODE == g_PAR_BRCH }) )    && RED 031105 ADDED '->BRCODE == g_PAR_BRCH

      Doccodes->( dbgotop())                && RED 031105 REMOVED
      *DOCCODES->(DBSEEK(g_PAR_BRCH))      && RED 031105 ADDED
      Doccodes->( dbeval({|| if( Docday->(dbseek(Acctdaly->brcode+Acctdaly->ACCTNO+Doccodes->DOCCODE)),mavail--,nil ) },,;
                        {|| !Doccodes->(eof()) }))             && RED 062305 '{|| !Doccodes->(eof()) .AND. DOCCODES->BRCODE == g_PAR_BRCH }) )    && RED 031105 ADDED '->BRCODE == g_PAR_BRCH
      if(mavail == 0 ,eval({|| error('No Document Code Available!'),mretval:=.t.}),nil)
   *ENDIF
   Docday->   ( dbgoto(mrecno))
return mretval
*************************************
function del_docday (macctno)
*************************************
   local mscr := savescreen (,,,)
   center  ( 24, 'w+/n', '® Deleting Records in Daily Documents File ¯' )
   Docday->( netlock ('F',0) )
   Docday->( dbseek(g_PAR_BRCH+macctno) ) && RED REMOVED 'sbrcode+      && RED 062305 ADDED 'g_PAR_BRCH
   Docday->( dbeval ( {|| Docday->(dbdelete() )},,;
                      {|| DOCDAY->BRCODE+Docday->acctno==g_PAR_BRCH+macctno .and. ;
                          !Docday->(eof());     && RED REMOVED '.and. == sbrcode ;
                      };
                    ) ;
           )
   Docday->( dbunlock())
   restscreen (,,,,mscr)
return nil
*
*                      End of the program ( amst100h.prg )
*
