/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   PROGRAM ID.........:  AMSM0700.prg                                         ³
³   Description........:  required documents per facility maintenance          ³
³   Author.............:  Ariel B. Bulan                                       ³
³   Date...............:  09:56pm 04-Oct-1994                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                         U P D A T E S                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        Who        ³     When      ³               Why                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Janet L. Bautista ³  28-Oct-1994  ³ close browse corners                     ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include "COLF.CH"
#include "INKEY.CH"

memvar ax_level,g_user_id
if chkpass( procname(),ax_level,g_user_id )
   if amsm0700open()
      nosnow( .t. )
      fm0700()
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
*
static function fm0700()
******************************************
local mbrowse, mcolor := setcolor()
local mbanner := 'Required Documents File Maintenance'
local keys_   := { '<Ins>\-Add ', '<F2>\Edit ', '<F3>\Color ', '<F4>\Search ', '<F6>\Code ', '<Del>\ ', '<Esc>\' }
local tbcol_  := { tbcolumnnew( '         Facility Code          '      , { || tran( Reqdocs->fcltycode, '@R 999-99' ) + space( 1 ) + dispalias( Reqdocs->fcltycode, 26, 'N' ) } ),;
                   tbcolumnnew( '          Required Document           ', { || Reqdocs->doccode   + space( 1 ) + PADR(dispdocname( Reqdocs->doccode ),34) } ) }

dbselectarea( "Reqdocs" )
if( ( alias() )->( eof() ), eval( { || ERROR( "No Record Found!" ),;
                                __keyboard( chr( K_INS ) ) } ), nil )
mbrowse := tb_maker( tbcol_, keys_,,,,, mbanner, Reqdocs->( lastrec() ) ) 
tb_stabilize( mbrowse, { | o, k | case0700( o, k ) } )
setcolor( mcolor )
return( nil )

/////   
static function case0700( cb, mkey )
local mreturn := .t., mscreen := savescreen( ,,, ), mcolor := setcolor()
memvar ax_level,g_user_id

do case
   case mkey == K_INS
        if chkpass('A',ax_level,g_user_id)
           center( 24, 'w+/n', '® Add Record ¯' )
           update ( 'A' )
           tb_refresh( cb, 'a' )
           center( 24, 'w+/n', '              ' )
        endif
   case mkey == K_F2
        if chkpass('E',ax_level,g_user_id)
           if ( alias() ) -> ( eof() )
               error( 'Nothing to Edit!' )
           else
               center( 24, 'w+/n', '® Edit Record ¯' )
               update ( 'E' )
               tb_refresh( cb, 'c' )               
               center( 24, 'w+/n', '               ' )               
           endif
        endif   
   case mkey == K_F4
        if chkpass('S',ax_level,g_user_id)
           if ( alias() ) -> ( eof() )
              error( 'Nothing to Search!' )
           else
              center( 24, 'w+/n', '® Search Record ¯' )                   
              search_head()
              tb_refresh( cb, 'a' )              
              center( 24, 'w+/n', '                 ' )              
           endif
        endif
   case mkey == K_F6
        if chkpass('S',ax_level,g_user_id)
           document_codes()
        endif
   case mkey == K_DEL
        if chkpass('D',ax_level,g_user_id)
           if ( alias() ) -> ( eof() )
               error( 'Nothing to Delete!' )
           else
               delete_head ( (alias()) -> FCLTYCODE )
               tb_refresh( cb, 'a' )               
           endif        
        endif
   otherwise     
        mreturn := .f.
endcase
setcolor( mcolor )
restscreen( ,,,, mscreen )
return( mreturn )   
************************************
*
static function document_codes()
************************************
   local mdbf := select(), mntx := indexord(), mrecno := recno()
   local keys_ := { '<Ins>\-Add ', '<F2>\Edit ', '<F3>\Color ', '<F4>\Search ', '<Del>\ ', '<Esc>\' }   
   local mbrowse, tbcol_ := { tbcolumnnew( 'Code'       , { || Doccodes->doccode } ),;
                              tbcolumnnew( 'Description', { || Doccodes->docname } ) }

   dbselectarea( "Doccodes" )
   Doccodes->( dbgotop() )
   save all like tbkill_* to mvar
   mbrowse := tb_maker( tbcol_, keys_, 10, 25, 20, 74,, Doccodes->( lastrec() ), .f. ) 
   tb_stabilize( mbrowse, { | o, k | casea700( o, k ) } )
   restore from mvar additive
   dbselectarea( mdbf )
   dbsetorder( mntx )
   dbgoto( mrecno )
   return nil   

////
static function casea700( cb, mkey )   
local mreturn := .t., mscreen := savescreen( ,,, ), mcolor := setcolor()
memvar ax_level,g_user_id

do case   
   case mkey == K_INS
        if chkpass('A',ax_level,g_user_id)
           center( 24, 'w+/n', '® Add Record ¯' )
           update_doc ( 'A' )
           tb_refresh( cb, 'a' )
           center( 24, 'w+/n', '              ' )
        endif   
   case mkey == K_F2
        if chkpass('E',ax_level,g_user_id)
           center( 24, 'w+/n', '® Edit Record ¯' )
           update_doc ( 'E' )
           tb_refresh( cb, 'c' )        
           center( 24, 'w+/n', '               ' )            
        endif   
   case mkey == K_F4
        if chkpass('S',ax_level,g_user_id)
           center( 24, 'w+/n', '® Search Record ¯' )      
           search_doc()
           tb_refresh( cb, 'a' )        
           center( 24, 'w+/n', '                 ' )
        endif   
   case mkey == K_DEL
        if chkpass('D',ax_level,g_user_id)
           delete_doc( Doccodes->doccode )
           tb_refresh( cb, 'a' )        
        endif   
   otherwise
        mreturn := !mreturn   
endcase
setcolor( mcolor )
restscreen( ,,,, mscreen )
return( mreturn )

////
static function update_doc ( mWHAT  )
   local getlist := {}
   local mDOCCODE, mDOCNAME
   local mRECNO  := recno()
   local mCURSOR := setcursor()
   local mCOLOR  := setcolor()

   fshadow( 16, 38, 19, 70, 2, 'n/w' )
   setcolor( 'bg+/w, w+/n,,, gr+/w' ) 
   if ( upper( mWHAT )=='A',( alias() )->(dbgoto(lastrec()+1)), mWHAT :='R')
   eval ({|| mDOCCODE := ( alias() )->DOCCODE, mDOCNAME := ( alias() )->DOCNAME})
   do while .t.
      @ 17, 39 say 'Document Code ' get mDOCCODE pict '999' when mWHAT == 'A' valid doc_validate( mDOCCODE )
      @ 18, 39 say 'Document Name ' get mDOCNAME pict '@XS15' valid !empty ( mDOCNAME )
      setcursor( 3 )                                      
      read
      setcursor( 0 )
      if lastkey() != K_ESC
         if confirm ( 'Are all entries correct?')
            MSGWIN(17,55,'Saving','w+/bg','r*/bg','on')

            if netlock ( mWHAT, 0 )
               eval ({|| ( alias() )->DOCCODE := mDOCCODE,;
                         ( alias() )->DOCNAME := mDOCNAME,;
                         ( ALIAS() )->(dbunlock())       ,;
                         ( ALIAS() )->(dbcommit()) })
            endif

            mRECNO   := recno()
            MSGWIN(17,55,'Saving','w+/bg','r*/bg','off')
            exit
         else
            loop
         endif
      else
         if esckey()
            exit
         endif
      endif
   enddo
   dbgoto(mRECNO)
   setcursor ( mCURSOR ) ; setcolor ( mCOLOR )
   return nil

////
static function doc_validate( mDOCCODE )
   local mRETVAL := .t.
   
   if empty ( mDOCCODE )
      return .f.
   endif
   if dbseek ( mDOCCODE )
      ERROR ('Document already Exists!' )
      mRETVAL := .f.
   endif
   return mRETVAL

////
static function update( mWHAT )
   local getlist := {}
   local mFCLTYCODE, mDOCCODE
   local mRECNO  := recno()
   local mCURSOR := setcursor()
   local mCOLOR  := setcolor()

   fshadow( 7, 6, 10, 29, 2, 'n/w' )
   setcolor( 'bg+/w, w+/n,,, gr+/w' ) 
   if ( upper( mWHAT )=='A',( alias() )->(dbgoto(lastrec()+1)), mWHAT :='R')
   eval ({|| mFCLTYCODE := ( alias() )->FCLTYCODE, mDOCCODE := ( alias() )->DOCCODE})
   do while .t.
      @ 08, 07 say 'Facility Code ' get mFCLTYCODE pict '@R 999-99' ;
                    VALID IF(EMPTY(mFCLTYCODE) .AND. LASTKEY() == K_ENTER,;
                           eval({|| lb_lkup('Facility', 1, 1,@mFCLTYCODE, 3 , 1, 09, 19, 19, 75, 'W/GR+,W/N,,,W/GR+'),;
                           IF(LASTKEY() == K_ENTER, .T., .F.) }), IF(EMPTY(mFCLTYCODE), .F., FACILITY->(DBSEEK(mFCLTYCODE)) ))
      @ 09, 07 say 'Document Code ' get mDOCCODE   pict '999' ;
                    VALID IF(EMPTY(mDOCCODE) .AND. LASTKEY() == K_ENTER,;
                           eval({|| lb_lkup('Doccodes', 1, 1,@mDOCCODE, 1 , 2, 10, 19, 19, 75 , 'W/GR+,W/N,,,W/GR+'),;
                           IF(LASTKEY() == K_ENTER, .T., .F.) }), IF(EMPTY(mDOCCODE), .F., DOCCODES->(DBSEEK(mDOCCODE)) ))

      setcursor( 3 )                                      
      read
      setcursor( 0 )
      if lastkey() != K_ESC
         if confirm ( 'Are all entries correct?')
            MSGWIN(8,23,'Saving','w+/bg','r*/bg','on')

            if netlock ( mWHAT, 0 )
               eval ({|| ( alias() ) -> FCLTYCODE :=  mFCLTYCODE,;
                         ( alias() ) -> DOCCODE   :=  mDOCCODE  ,;
                         ( alias() ) -> ( dbunlock() )          ,;
                         ( alias() ) -> ( dbcommit() )          })
            endif
            mRECNO   := recno()

            MSGWIN(8,23,'Saving','w+/bg','r*/bg','off')
            exit
         else
            loop
         endif
      else
         if esckey()
            exit
         endif
      endif
   enddo
   dbgoto(mRECNO)
   setcursor ( mCURSOR ) ; setcolor ( mCOLOR )
   return nil

////
/*
static function dispalias( mFCLTYCODE )
   Facility->( dbseek ( mFCLTYCODE ) )
   return padr( Facility->FCLTYNAME, 26 )

////
static function dispdocname ( mDOCCODE )
   Doccodes-> ( dbseek ( mDOCCODE ) )
   return padr( Doccodes->DOCNAME, 34 )
*/
////
static function delete_head( mFCLTYCODE )
   local mRECNO := Reqdocs ->( recno() )
   if Reqdocs  -> ( eof() )
      ERROR ( 'Nothing to Delete!' )
   else
      if CONFIRM('Delete Facility Code ' +tran(mFCLTYCODE, '@R 999-99')+ '?')
         MSGWIN(8,24,'Deleting','w+/bg','r*/bg','on')
         if NETLOCK( 'R', 0 )
            Reqdocs  -> ( dbdelete(  ) )
            Reqdocs  -> ( dbskip  (+1) )
            if ( Reqdocs-> ( eof() ), Reqdocs-> ( dbgobottom() ), nil )
            mRECNO := Reqdocs -> ( recno() )
            Reqdocs -> ( dbunlock() )
         endif
         MSGWIN(8,24,'Deleting','w+/bg','r*/bg','oFF')
      endif
   endif
   Reqdocs -> ( dbgoto( mRECNO ) )
   return nil

////
static function search_head()
   local mFCLTYCODE := space ( 5 )
   local mRECNO := recno()
   local getlist := {}
   local mcolor := setcolor()
   
   if ( alias() ) -> ( eof() )
      ERROR ( 'Nothing to Search!' )
   else
      CENTER( 24, 'w+/n', '® Search Record ¯' )
      fshadow( 7, 6, 9, 29, 2, 'n/w' )
      setcolor( 'bg+/w, w+/n,,, gr+/w' ) 
      @ 08, 07 say 'Facility Code ' get mFCLTYCODE pict '@R 999-99' VALID IF(EMPTY(mFCLTYCODE) .AND. LASTKEY() == K_ENTER,;
                    eval({|| Lb_lkup('Facility',1,1,@mFCLTYCODE,03,01,09,19,19,75,'W/GR+,W/N,,,W/GR+'), IF(LASTKEY() == K_ENTER, .T., .F.) }), .T.)
      setcursor( 3 )
      read
      setcursor( 0 )

      if !empty ( mFCLTYCODE ) .and. lastkey() != K_ESC
         if !dbseek ( mFCLTYCODE )
            ERROR ( 'Facility Code not Found!' )
            dbgoto( mRECNO )
         endif
      else
         *mRECNO := recno()
         dbgoto( mRECNO )
      endif

      CENTER( 24, 'w+/n', '                 ' )
   endif
   setcolor( mcolor )
   return nil

////
static function SEARCH_DOC()
   local mDOCCODE := space ( 3 ), mcolor := setcolor()
   local mRECNO   := recno()    , getlist := {}
   if ( alias() ) -> ( eof() )
      ERROR ( 'Nothing to Search!' )
   else
      CENTER( 24, 'w+/n', '® Search Record ¯' )
      fshadow( 16, 38, 18, 58, 2, 'n/w' )
      setcolor( 'bg+/w, w+/n,,, gr+/w' ) 
      @ 17, 39 say 'Document Code ' get mDOCCODE pict '999'

      setcursor( 3 )
      read
      setcursor( 0 )
      if !empty ( mDOCCODE ) .and. lastkey() != K_ESC
         if !dbseek ( mDOCCODE )
            dbgoto ( mRECNO )
            ERROR ( 'Document Code not Found!')
         endif
      else
         *mRECNO := recno()
         dbgoto ( mRECNO )
      endif
      CENTER( 24, 'w+/n', '                 ' )
   endif

   setcolor( mcolor )
   return nil

////
static function DELETE_DOC( mDOCCODE )
   local mRECNO := recno()
   if ( alias() ) -> ( eof() )
      ERROR ( 'Nothing to delete!' )
   else
      if CONFIRM('Delete Document Code ' +mDOCCODE+ '?')
         MSGWIN(17,39,'Deleting','w+/bg','r*/bg','on')
         if NETLOCK( 'R', 0 )
            Doccodes  -> ( dbdelete(    ) )
            Doccodes  -> ( dbskip  ( +1 ) )
            if ( Doccodes-> ( eof() ), Doccodes-> ( dbgobottom() ), nil )
            mRECNO := Doccodes -> ( recno() )
            Doccodes -> ( dbunlock() )
         endif
         MSGWIN(17,39,'Deleting','w+/bg','r*/bg','off')
      endif
    endif
    dbgoto   ( mRECNO )
    return nil

////
static function AMSM0700OPEN()
   local mRETVAL := .f.
   if NETUSE( '&g_AMS_PATH\Doccodes', .f., 5 )
      set index to &g_AMS_PATH\Doccodes,;
                   &g_AMS_PATH\Doccname
      if NETUSE( '&g_AMS_PATH\Facility', .f., 5 )
         set index to &g_AMS_PATH\Fcltycd
         if NETUSE( '&g_AMS_PATH\Reqdocs', .f., 5 )
            set index to &g_AMS_PATH\Reqdocs
            mretval := .t.
         endif
      endif
   endif
   return mretval

// Eop: AMSM0700.prg //
