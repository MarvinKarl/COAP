/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   PROGRAM ID.........:  amsm1015.prg                                         ³
³   Description........:  Statement of Account Format File                     ³
³   Author.............:  renan s. evangelista                                 ³
³   Date...............:  03:50pm 25-Jun-1996                                  ³
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
   if ( amsm1015open(), eval ({ || nosnow( .t. ), mainfunction( 'Client Code ' ),nosnow( .f. ) } ), nil )
   eval ({|| __mrelease("*", .t.), dbcloseall() })
endif
return
******************************
*
static function amsm1015open()
******************************
   local mretval := .f.
         if netuse( '&g_Cis_path\Client', .f., 10 )               && Client file
            if !.f.; ordlistclear(); endif
            ordlistadd( '&g_Cis_path\Clienm' )                    && set index on Fullname
            if  netuse( '&g_AMS_PATH\Saformat', .f. ,5 )
                dbsetindex ( '&g_AMS_PATH\Saformat' )
                MRETVAL := .t.
            endif
         endif
return mretval

*************************************
STatic function mainfunction( mess1 )
*************************************
   local mbanner := mess1 + ' File Maintenance', cb, mdbf := savedbf()
   local keys_   := { '<Ins>\-Add ', '<F2>\Edit ', '<F3>\Color ', '<F4>\Search ', '<Del>\ ', '<Esc>\' }
   //LOCAL cBRCODES := ACC_BRCH(g_USER_ID)
   local tbcol_  := { tbcolumnnew( mess1, { || TRAN( (alias())->(fieldget(2))+(alias())->(fieldget(1) ), '@R 999-99-99999' ) } ) }
   private dplay_1 := mess1

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
           if CURRBRCH( (ALIAS())->BRCODE ) .AND. ;
              chkpass('E',ax_level,g_user_id) .AND. ;
              VALBRCODE( (ALIAS())->BRCODE,g_USER_ID)
              if( ( alias() )->( eof() ),;
                  error('Nothing to Edit!'),;
                  amsmupdate('E') )
              tb_refresh( cb, 'c' )
           endif
      case mKEY == K_DEL
           if CURRBRCH( (ALIAS())->BRCODE ) .AND. ;
              chkpass('D',ax_level,g_user_id) .AND. ;
              VALBRCODE((ALIAS())->BRCODE,g_USER_ID)
              if( ( alias() )->( eof() ),;
                 ERROR('Nothing to Delete!'),;
                 amsmdelete( 'Delete this record? ' );
                )
                tb_refresh( cb, 'a' )
           endif
      case mKEY == K_F4
           if chkpass('S',ax_level,g_user_id)
              if( (alias())->(eof()) , ERROR('Nothing to Search!'), amsmsearch() )
              tb_refresh( cb, 'a' )
           endif
      otherwise
         mretval := !mretval   
endcase
restscreen( ,,,, mscreen )
setcolor( mcolor )
return( mretval )
******************************************
static function amsmupdate( mwhat )
******************************************
    local mrecno := recno(), mcontinue := .t., mscr := savescreen ( 08,25,13,62 )
    local mess3  := if ( mwhat == 'A', '® Add Record ¯', '® Edit Record ¯' )
    local mfield1, getlist := {}
    local max_1 :=  len( trim( dplay_1 ) )
    memvar dplay_1

    if( upper( mwhat ) == chr(65), dbgoto( lastrec() + 1 ), mwhat := chr(82) )
    eval( {|| mfield1 := (alias())->(fieldget(2))+(alias())->(fieldget(1)) } )
    center( 24, 'w+/n', mess3 )
    fshadow( 9, 25, 11, 28 + max_1 + 4 + 12, 2, 'n/w' )
    setcolor( 'bg+/w, w+/n,,, gr+/w' )

    do while mcontinue
       @ 10, 26 say dplay_1+' ' get mfield1 pict '@R 999-99-99999' VALID IF( !EMPTY(RIGHT(mFIELD1,7)) .AND. LASTKEY() == K_ENTER,;
                                                                              IF( VALBRCODE(LEFT(mFIELD1,3),g_USER_ID),;
                                                                                  IF( mWHAT == 'A', ;
                                                                                      CHECK_CODE(mFIELD1) ,;
                                                                                      .T.;
                                                                                    ) ,;
                                                                                  EVAL({|| mFIELD1 := SPACE(10),;
                                                                                           .F.;
                                                                                      });
                                                                                ) ,;
                                                                              EVAL({|| mfield1:= eval({|| FLOOK_ONLINE( .t.,'Client',mfield1,'Client Master File',45,1,3,4,1,,,,,,.T.) }),;
                                                                                       IF( LASTKEY() == K_ENTER,;
                                                                                           EVAL({|| IF( VALBRCODE(LEFT(mFIELD1,3),g_USER_ID),;
                                                                                                        .T.,;
                                                                                                        EVAL({|| mFIELD1 := SPACE(10),;
                                                                                                                 .F.;
                                                                                                            });
                                                                                                      );
                                                                                               }),;
                                                                                           EVAL({|| mFIELD1:=SPACE(10),;
                                                                                                    .F.;
                                                                                               });
                                                                                         );
                                                                                  });
                                                                            )
                                 /*
                                 when !empty(mfield1:= eval({|| FLOOK_ONLINE( .t.,'Client',mfield1,'Client Master File',1,3,,4,1) } )) ;
                                 valid check_code ( mfield1 )
                                 */
       setcursor( 3 )
       read
       setcursor( 0 )

       if ( lastkey() == K_ESC,;
            if( esckey(), mcontinue := .f., nil ),;
            if ( lastkey() == K_ENTER,;
                 if ( confirm( 'Are all entries correct?' ) ,;
                      EVAL({|| MSGWIN(11,36,'Saving','W+/BG','R*/BG','ON'),;
                               if( (alias())->( netlock(mwhat,0) ),;
                                   eval ({|| fieldput ( 1, RIGHT(mfield1,7) ),;
                                             fieldput ( 2, LEFT(mfield1,3) ),;
                                             mrecno := (alias())->(recno()),;
                                             (ALIAS())->(DBUNLOCK()),;
                                             mcontinue := .f.;
                                        }),;
                                   nil;
                                 ),;
                               MSGWIN(11,36,'Saving','W+/BG','R*/BG','OFF');
                          }) ,;
                      nil;
                    ),;
                 nil;
               );
          )
    enddo
    center( 24, 'w+/n', padr( '', len( mess3 ) ) )    
    dbgoto(mrecno); setcursor( 0 ); setcolor ( NRM ) ; restscreen ( 08,25,13,62, mscr )
return nil
/*
*****************************
static function check_code( mcode )
*****************************
    local mretval := .t., mdbf := savedbf ( mdbf )
    
    if( (alias())->(dbseek(mcode)) .and. !empty ( mcode ) .and. lastkey() != K_ESC, eval ({|| error ( 'Duplicate Code Found!' ) , mretval := .f. }), nil )
    if( empty ( mcode ), mretval := .f., nil  )
    restdbf   ( mdbf  )
return mretval
************************************
static function mess_tones( mmess )
************************************
    tones ()
return confirm ( mmess )
*****************
static function tones ()
*****************
   tone( 1600, 1 ) ; tone ( 800, 1)
return nil
*/
***********************************************
static function amsmdelete( message, mpos, mlastrec )
***********************************************
    if confirm( message +'?')
       MSGWIN(10,35,'Deleting','W+/BG','R*/BG','ON')
       if netlock( 'R', 0 )
          dbdelete()
          dbskip(+1)
          if eof()
             dbgobottom()
          endif
          dbunlock()
       endif
       MSGWIN(10,35,'Deleting','W+/BG','R*/BG','OFF')
    endif
return nil
************************************
static function amsmsearch ()
************************************
    local mrecno  := (alias()) ->(recno()) , mscr  := savescreen ( 08,25,13,62 )
    local mess3   := '® Search Record ¯'
    local mfield1 := space( len( (alias())->(fieldget(2))+(alias())->(fieldget(1)) ) )
    local getlist := {}
    memvar dplay_1
    
    center    ( 24, 'w+/n', mess3 )
    fshadow   ( 11, 13, 13, 18 + len( trim( dplay_1 ) ) + 4 + len( mfield1 ), 2, 'n/w' )
    setcolor  ( 'bg+/w, w+/n,,, gr+/w' )

    @ 12, 14 say dplay_1 + ' ' + chr( 16 ) get mfield1 pict '@R 999-99-99999' VALID VALBRCODE(LEFT(mFIELD1,3),g_USER_ID) && RED 11112004 REPLACED '@X'

    setcursor ( 3 )
    read
    setcursor ( 0 )

    if ( lastkey () != K_ESC .and. !empty  ( mfield1 ),;
         if (  (alias())-> ( dbseek ( mfield1 ) ),;
               mrecno := (alias())->( recno()),;
               error ( 'Record does not Exists');
              ),;
             nil;
            )

    center( 24, 'w+/n', padr( '', len( mess3 ) ) )
    dbgoto(mrecno); setcursor ( 0 ) ; setcolor ( NRM ) ; restscreen ( 08,25,13,62, mscr )
return nil


*                         End of the program ( amsm1015.prg )
