/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   PROGRAM ID.........:  amsm1008.prg                                         ³
³   Description........:  Asset Codes                                          ³
³   Author.............:  Ariel B. Bulan                                       ³
³   Date...............:  08:53pm 29-Nov-1994                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                         U P D A T E S                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        Who        ³     When      ³               Why                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³renan evangelista  ³ 07-19-96      ³Add field depreciable life                ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include "Colf.ch"
#include "Inkey.ch"

memvar ax_level,g_user_id
if chkpass( procname(),ax_level,g_user_id )
   if ( amsm1008open(), eval ({ || nosnow( .t. ), mainfunction( 'Asset Code', 'Asset Name','Depreciable Life' ),nosnow( .f. ) } ), nil )
   eval ({|| __mrelease("*", .t.), dbcloseall() })
endif
return
******************************
*
static function amsm1008open()
******************************
   local mretval :=  if ( netuse ( '&g_AMS_PATH\Asetcode', .f. ,5 ), eval ({|| dbsetindex ( '&g_AMS_PATH\Asetcode' ), .t. } ), .f. )
return mretval

*************************************
Static function mainfunction( mess1, mess2, mess3 )
*************************************
   local mbanner := mess1 + ' File Maintenance', cb, mdbf := savedbf()
   local keys_   := { '<Ins>\-Add ', '<F2>\Edit ', '<F3>\Color ', '<F4>\Search ', '<Del>\ ', '<Esc>\' }
   local tbcol_  := { tbcolumnnew( mess1, { || ( alias() )->( fieldget( 1 ) ) } ),;
                      tbcolumnnew( mess2, { || left( ( alias() )->( fieldget( 2 ) ), 30 ) } ),;
                      tbcolumnnew( mess3, { || ( alias() )->( fieldget( 3 ) ) } );
                       }
   private dplay_1 := mess1, dplay_2 := mess2, dplay_3 := mess3

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
Static function amsmupdate( mwhat )
******************************************
    local mrecno := recno(), mcontinue := .t., mscr := savescreen ( 08,25,13,62 )
    local mess3  := if ( mwhat == 'A', '® Add Record ¯', '® Edit Record ¯' )
    local mfield1 , mfield2, mfield3, getlist := {}
    local max_1 := max( len( trim( dplay_1 ) ), len( trim( dplay_2 ) ) )
    memvar dplay_1, dplay_2,dplay_3
    max_1 := max( max_1, len( trim( dplay_3 ) ) )

    if( upper( mwhat ) == chr(65), dbgoto( lastrec() + 1 ), mwhat := chr(82) )
    eval({|| mfield1 := (alias())->(fieldget(1)), mfield2 := (alias())->(fieldget(2)), mfield3 := (alias())->(fieldget(3))})
    center( 24, 'w+/n', mess3 )
    fshadow( 9, 25, 13, 25 + max_1 + 4 + 12, 2, 'n/w' )
    setcolor( 'n/w, w+/n,,, w+/w' )
    do while mcontinue
       @ 10, 26 say dplay_1+' ' get mfield1 pict '@X' when ( upper( mwhat ) == chr ( 65 ) ) valid check_code ( mfield1 ) .AND. !EMPTY(mFIELD1)
       @ 11, 26 say dplay_2+' ' get mfield2 pict '@XS12'
       @ 12, 26 say dplay_3+' ' get mfield3 pict '@X'

       setcursor( 3 )
       read
       setcursor( 0 )

       if( lastkey() == K_ESC,;
           if( esckey(),;
               mcontinue := .f.,;
               nil;
             ),;
           if( lastkey() == K_ENTER,;
               if( confirm( 'Are all entries correct?' ),;
                   EVAL({ || MSGWIN(10,34,'Saving','w+/bg','r*/bg','on'),;
                             if( (alias())->( netlock(mwhat,0) ),;
                                 eval({|| fieldput ( 1, mfield1 ),;
                                          fieldput ( 2 , mfield2 ),;
                                          fieldput ( 3, mfield3 ),;
                                          mrecno := (alias())->(recno()),;
                                          (alias())->( DBUNLOCK() ),;
                                          MSGWIN(10,34,'Saving','w+/bg','r*/bg','off'),;
                                          mcontinue := .f.;
                                     }),;
                                 nil;
                               );
                       }),;
                   nil;
                 ),;
               nil;
             );
         )
    enddo
    center( 24, 'w+/n', padr( '', len( mess3 ) ) )    
    dbgoto(mrecno)
    setcursor( 0 )
    setcolor( NRM )
    restscreen( 08,25,13,62, mscr )
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
*/
***********************************************
static function amsmdelete( message, mpos, mlastrec )
***********************************************
    if confirm( message +'?')
       MSGWIN(10,26,'Deleting','w+/bg','r*/bg','on')
       if netlock( 'R', 0 )
          dbdelete()
          dbskip(+1)
          if eof()
             dbgobottom()
          endif
          dbunlock()
       endif
       MSGWIN(10,26,'Deleting','w+/bg','r*/bg','oFF')
    endif
return nil
************************************
Static function amsmsearch ()
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
    //dbgotop()
    //mrecno := RECNO()
    if( lastkey() != K_ESC .and. !empty( mfield1 ),;
        if( (alias())->( dbseek( mfield1 ) ),;
            mrecno := (alias())->( recno()),;
            error( 'Record does not Exists');
          ),;
        nil;
      )
    center( 24, 'w+/n', padr( '', len( mess3 ) ) )
    dbgoto(mrecno)
    setcursor ( 0 )
    setcolor ( NRM )
    restscreen ( 08,25,13,62, mscr )
return nil

*                         End of the program ( amsm1008.prg )
