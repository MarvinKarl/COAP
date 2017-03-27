/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   PROGRAM ID.........:  amsm1001.prg                                         ³
³   Description........:  collateral type file maintenance                     ³
³   Author.............:  Ariel B. Bulan                                       ³
³   Date...............:  01:16pm 03-Nov-1994                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                         U P D A T E S                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        Who        ³     When      ³               Why                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                   ³               ³                                          ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include "Colf.ch"
#include "Inkey.ch"

memvar ax_level,g_user_id
if chkpass( procname(),ax_level,g_user_id )
   if amsm1001open()
      nosnow( .t. )
      mainfunction( 'CB Collateral Type', 'CB Collateral Name'  )
      nosnow( .f. )
   endif
   release all
   close data
endif
return
*************************************
function mainfunction( mess1, mess2 )
*************************************
   local mbanner := mess1 + ' File Maintenance', cb, mdbf := savedbf()
   local keys_   := { '<Ins>\-Add ', '<F2>\Edit ', '<F3>\Color ', '<F4>\Search ', '<Del>\ ', '<Esc>\' }
   local tbcol_  := { tbcolumnnew( mess1, { || ( alias() )->( fieldget( 1 ) ) } ),;
                      tbcolumnnew( mess2, { || left( ( alias() )->( fieldget( 2 ) ), 30 ) } ) }
   private dplay_1 := mess1, dplay_2 := mess2

   if( ( alias() ) ->( eof() ), eval({|| ERROR("No Record Found!"), __keyboard(chr(K_INS))}), nil)
   cb := tb_maker( tbcol_, keys_,,,,, mbanner, ( alias() )->( lastrec() ) )
   tb_stabilizer( cb, { | o, k | case1001( o, k ) } )
   restdbf( mdbf )
return nil
************************************************************
static function case1001( cb, mkey )
************************************************************
   local mretval := .t., mscreen := savescreen( ,,, ), mcolor := setcolor() 
   memvar ax_level,g_user_id
   
   do case
      case mkey == K_INS
         if chkpass('A',ax_level,g_user_id)
            amsmupdate( 'A' )
            tb_refresh( cb, 'a' )
         endif
      case mKEY == K_F2
         if chkpass('E',ax_level,g_user_id)
            if( ( alias() )->( eof() ), error('Nothing to Edit!'), amsmupdate('E') )
            tb_refresh( cb, 'c' )            
         endif
      case mKEY == K_DEL
         if chkpass('D',ax_level,g_user_id)
            if( ( alias() )->( eof() ),;
            ERROR('Nothing to Delete!'),;
            amsmdelete( 'Delete '+ alltrim( (alias())->(fieldget(2))   )))
            tb_refresh( cb, 'a' )            
         endif
      case mKEY == K_F4
         if chkpass('S',ax_level,g_user_id)
            if( ( alias() )->( eof() ) , ERROR('Nothing to Search!'), amsmsearch() )
            tb_refresh( cb, 'a' )            
         endif
      otherwise
         mretval := !mretval   
endcase
restscreen( ,,,, mscreen )
setcolor( mcolor )
return( mretval )
******************************************
function amsmupdate( mwhat )
******************************************
    local mrecno := recno(), mcontinue := .t., mscr := savescreen ( 08,25,13,62 )
    local mess3  := if ( mwhat == 'A', '® Add Record ¯', '® Edit Record ¯' )
    local mfield1 , mfield2, getlist := {}
    local max_1 := max( len( trim( dplay_1 ) ), len( trim( dplay_2 ) ) )
    memvar dplay_1, dplay_2
    
    if( upper( mwhat ) == chr(65), dbgoto( lastrec() + 1 ), mwhat := chr(82) )
    eval({|| mfield1 := (alias())->(fieldget(1)), mfield2 := (alias())->(fieldget(2))})
    center( 24, 'w+/n', mess3 )
    fshadow( 9, 25, 12, 25 + max_1 + 4 + 12, 2, 'n/w' )
    setcolor( 'bg+/w, w+/n,,, gr+/w' )

    do while mcontinue
       @ 10, 26 say dplay_1+' ' get mfield1 pict '@X' when ( upper( mwhat ) == chr ( 65 ) ) valid check_code( mfield1 ) .AND. !EMPTY(mFIELD1)
       @ 11, 26 say dplay_2+' ' get mfield2 pict '@XS12'

       setcursor( 3 )
       read
       setcursor( 0 )

       if ( lastkey() == K_ESC,;
            if( esckey(), mcontinue := .f., nil ),;
            if ( lastkey() == K_ENTER,;
                 if ( confirm( 'Are all entries correct?' ) ,;
                      EVAL({ || MSGWIN(9,38,'Saving','W+/BG','R*/BG','ON'),;
                      if( (alias())->( netlock(mwhat,0) ), ;
                          eval ({|| fieldput ( 1, mfield1 ),;
                                    fieldput ( 2 , mfield2 ),;
                                    mrecno := (alias())->(recno()),;
                                    (ALIAS())->(DBUNLOCK()),;
                                    mcontinue := .f.;
                               }),;
                          nil ),;
                      MSGWIN(9,38,'Saving','W+/BG','R*/BG','OFF') }),;
                    nil ),;
               nil );
          )
    enddo

    center( 24, 'w+/n', padr( '', len( mess3 ) ) )    
    dbgoto(mrecno)
    setcursor( 0 )
    setcolor ( NRM )
    restscreen ( 08,25,13,62, mscr )
return nil
/*
*****************************
function check_code( mcode )
*****************************
    local mretval := .t., mdbf := savedbf ( mdbf )
    
    if( (alias())->(dbseek(mcode)) .and. !empty ( mcode ) .and. lastkey() != K_ESC, eval ({|| error ( 'Duplicate Code Found!' ) , mretval := .f. }), nil )
    if( empty ( mcode ), mretval := .f., nil  )
    restdbf   ( mdbf  )
return mretval
************************************
function mess_tones( mmess )
************************************
    tones ()
return confirm ( mmess )
*****************
function tones ()
*****************
   tone( 1600, 1 ) ; tone ( 800, 1)
return nil
*/

************************************
function amsmsearch ()
************************************
    local mrecno  := (alias()) ->(recno()) , mscr  := savescreen ( 08,25,13,62 )
    local mess3   := '® Search Record ¯'
    local mfield1 := space ( len ( (alias())->( fieldget (1) ) ) )
    local mfield2 := space ( len ( (alias())->( fieldget (2) ) ) )
    local getlist := {}
    memvar dplay_1, dplay_2
    
    center( 24, 'w+/n', mess3 )
    fshadow( 11, 13, 13, 13 + len( trim( dplay_1 ) ) + 4 + len( mfield1 ), 2, 'n/w' )
    setcolor( 'bg+/w, w+/n,,, gr+/w' ) 
    @ 12, 14 say dplay_1 + ' ' + chr( 16 ) get mfield1 pict '@X'
    setcursor( 3 )
    read
    setcursor( 0 )
    if ( lastkey() != K_ESC .and. !empty( mfield1 ), if( (alias())-> ( dbseek ( mfield1 ) ), mrecno := (alias())->( recno()), error ( 'Record does not Exists') ), nil )
    center( 24, 'w+/n', padr( '', len( mess3 ) ) )
    dbgoto(mrecno); setcursor ( 0 ) ; setcolor ( NRM ) ; restscreen ( 08,25,13,62, mscr )
return nil
******************************
static function amsm1001open()
******************************
   local mretval
   if ( netuse ( '&g_ams_path\Colatral', .f. , 5 ), eval ({ || dbsetindex ( '&g_AMS_PATH\Colatral' ), mretval := .t. }) , mretval := .f. )
return mretval
*
*                     End of the program ( amsm1001.prg )
*
