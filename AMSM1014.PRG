/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   PROGRAM ID.........:  amsm1014.prg                                         ³
³   Description........:  Ao Access Code                                       ³
³   Author.............:  renan s. evangelista                                 ³
³   Date...............:  09:20am 25-Jun-1996                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                         U P D A T E S                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        Who        ³     When      ³               Why                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³     ABB           ³  10.13.2004   ³        ONLINE use                        ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include "Colf.ch"
#include "Inkey.ch"

memvar ax_level,g_user_id
if chkpass( procname(),ax_level,g_user_id )
   if ( amsm1014open(), eval ({ || nosnow( .t. ), mainfunction( 'AO Code', 'AO Access', 'Branch'  ),nosnow( .f. ) } ), nil )
   eval ({|| __mrelease("*", .t.), dbcloseall() })
endif
return
******************************
*
Static Function amsm1014open()
******************************
   local mretval :=  .t.

// EVR if !netuse ( 'Parametr', .f. ,5 )
// EVR    return .f.
// EVR endif

   if !netuse ( '&g_AMS_PATH\Aoaccess', .f. ,5 )
      return .f.
   endif
   dbsetindex ( '&g_AMS_PATH\Aoaccess' )


return mretval
*************************************
Static Function mainfunction( mess1, mess2 )
*************************************
   local mbanner := mess1 + ' File Maintenance', cb, mdbf := savedbf()
   local keys_   := { '<Ins>\-Add ', '<F2>\Edit ', '<F3>\Color ', '<F4>\Search ', '<Del>\ ', '<Esc>\' }
   LOCAL cBRCODES := g_PAR_BRCH  //ACC_BRCH(g_USER_ID)
   local tbcol_  := { tbcolumnnew( mess1, { || TRANS(Aoaccess->brcode+(alias())->(fieldget(1)),'@R 999-XXXXXX') } ),;
                      tbcolumnnew( mess2, { || left( ( alias() )->( fieldget( 2 ) ), 30 ) } ) ;
                    }
   private dplay_1 := mess1, dplay_2 := mess2

   if( ( alias() ) ->( eof() ),;
         eval({|| ERROR("No Record Found!"),;
          __keyboard(chr(K_INS))}), nil)
   cb := tb_maker( tbcol_, keys_,,,,, mbanner, ( alias() )->( lastrec() ) )
   tb_stabilizer( cb, { | o, k | case1001( o, k, cBRCODES ) } )
   restdbf( mdbf )
return nil
************************************************************
static Function case1001( cb, mkey, cBRCODES )
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
           IF CURRBRCH( AOACCESS->BRCODE) .AND. chkpass('E',ax_level,g_user_id)
              if( ( alias() )->( eof() ), error('Nothing to Edit!'), amsmupdate('E') )
              tb_refresh( cb, 'c' )
           ENDIF
      case mKEY == K_DEL
           IF CURRBRCH(AOACCESS->BRCODE) .AND. chkpass('D',ax_level,g_user_id)
              if( ( alias() )->( eof() ),;
                 ERROR('Nothing to Delete!'),;
                 amsmdelete( 'Delete '+ alltrim( (alias())->(fieldget(2))   )))
              tb_refresh( cb, 'a' )
           ENDIF
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
Static Function amsmupdate( mwhat )
******************************************
    local mrecno := recno(), mcontinue := .t., mscr := savescreen ( 08,25,13,62 )
    local mess3  := if ( mwhat == 'A', '® Add Record ¯', '® Edit Record ¯' )
    local mfield1 , mfield2, mfield3, getlist := {}
    local max_1 := max( len( trim( dplay_1 ) ), len( trim( dplay_2 ) ) )
    local cbrcode := if ( mwhat == 'A', g_PAR_BRCH, Aoaccess->brcode )
    memvar dplay_1, dplay_2
    
    if( upper( mwhat ) == chr(65), dbgoto( lastrec() + 1 ), mwhat := chr(82) )

    mfield1 := (ALIAS())->(FIELDGET(3))+(alias())->(fieldget(1))
    mfield2 := (alias())->(fieldget(2))
    mfield3 := Aoaccess->brcode

    center   ( 24, 'w+/n', mess3 )
    fshadow  ( 9, 25, 12, 30 + max_1 + 4 + 12, 2, 'n/w' )
    setcolor ( 'bg+/w, w+/n,,, gr+/w' )

    do while mcontinue
       @ 10, 26 say dplay_1+' ' get mfield1 pict '@R 999-XXXXXX' when ( upper( mwhat ) == chr ( 65 ) );   && RED 11112004 REPLACED '@!X'
                                                                  VALID IF( !EMPTY(RIGHT(mFIELD1,6)) .AND. LASTKEY() == K_ENTER,;
                                                                            IF( VALBRCODE( LEFT( mFIELD1, 3), g_USER_ID),;
                                                                                .T.,;
                                                                                EVAL({|| mFIELD1 := SPACE(9),;
                                                                                         .F.;
                                                                                    });
                                                                              ),;
                                                                            EVAL({|| mFIELD1 := SPACE(9),;
                                                                                     .F.;
                                                                                });
                                                                          )
       @ 11, 26 say dplay_2+' ' get mfield2 pict '@!XS12' valid IF(mWHAT=='A',check_code( mfield1,mfield2,mfield3 ),.T.)

       setcursor( 3 )
       read
       setcursor( 0 )

       if ( lastkey() == K_ESC,;
            if( esckey(), mcontinue := .f., nil ),;
              if ( lastkey() == K_ENTER,;
                   if ( confirm( 'Are all entries correct?' )  ,;
                         EVAL({ || MSGWIN(9,36,'Saving','W+/BG','R*/BG','ON')  ,;
                           if( (alias())->( netlock(mwhat,0) ), ;
                           eval ( {||  fieldput ( 1 , RIGHT(mfield1,6) ),;
                                       fieldput ( 2 , mfield2 ),;
                                       fieldput ( 3 , LEFT(mFIELD1,3) ),;    && RED 11112004 REPLACED 'cbrcode'
                                       mrecno    := (alias())->(recno()),;
                                       mcontinue := .f. ,;
                                       (ALIAS())->(DBUNLOCK()) ;
                                } ), nil ), ;
                         MSGWIN(9,36,'Saving','W+/BG','R*/BG','OFF') }) ,;
                      nil ), ;
                 nil ))
    enddo

    center( 24, 'w+/n', padr( '', len( mess3 ) ) )    
    dbgoto(mrecno)
    setcursor( 0 )
    setcolor( NRM )
    restscreen( 08,25,13,62, mscr )
return nil
*****************************
Static Function check_code( mcode1,mcode2,mcode3 )
*****************************
    local mretval := .t., mdbf := savedbf ( mdbf )
    
//     if (alias())->(dbseek(mcode1)) .and. !empty ( mcode1 ) .and. !empty ( mcode2 ) .and. lastkey() != K_ESC

    if (alias())->(dbseek(mcode3+mcode1)) .and. !empty ( mcode1 ) .and. !empty ( mcode2 ) .and. !empty(mcode3) .and. lastkey() != K_ESC
       while alltrim((alias())->(fieldget(1))) == Alltrim(mcode1) .and. ;
             alltrim((alias())->(fieldget(3))) == Alltrim(mcode3)       ;

        if alltrim(fieldget(2)) == alltrim(mcode2)
          error ( 'Duplicate Code Found!' )
          mretval := .f.
          exit
        endif
        dbskip()
       enddo

    endif
    if( empty ( mcode1 ) .OR. empty ( mcode2 ), mretval := .f., nil  )
    restdbf   ( mdbf  )
return mretval
/*
************************************
Static Function mess_tones( mmess )
************************************
    tones ()
return confirm ( mmess )
*****************
Static Function tones ()
*****************
   tone( 1600, 1 ) ; tone ( 800, 1)
return nil
*/
***********************************************
Static Function amsmdelete( message, mpos, mlastrec )
***********************************************
    if confirm( message +'?')
       MSGWIN(12,35,'Deleting','W+/BG','R*/BG','ON')
       if netlock( 'R', 0 )
          dbdelete()
          dbskip(+1)
          if eof()
             dbgobottom()
          endif
          dbunlock()
       endif
       MSGWIN(12,35,'Deleting','W+/BG','R*/BG','OFF')
    endif
return nil
************************************
Static Function amsmsearch ()
************************************
    local mrecno  := (alias()) ->(recno()) , mscr  := savescreen ( 08,25,13,62 )
    local mess3   := '® Search Record ¯'
    local mfield1 := space ( len ( (alias())->(BRCODE)+(alias())->( fieldget (1) ) ) )
    local mfield2 := space ( len ( (alias())->( fieldget (2) ) ) )
    local getlist := {}
    memvar dplay_1, dplay_2
    
    center( 24, 'w+/n', mess3 )
    fshadow( 11, 13, 13, 18 + len( trim( dplay_1 ) ) + 4 + len( mfield1 ), 2, 'n/w' )
    setcolor( 'bg+/w, w+/n,,, gr+/w' ) 
    @ 12, 14 say dplay_1 + ' ' + chr( 16 ) get mfield1 pict '@R 999-XXXXXX' VALID VALBRCODE(LEFT(mFIELD1,3),g_USER_ID)  && RED 11112004 REPLACED '@X'

    setcursor( 3 )
    read
    setcursor( 0 )

    if ( lastkey() != K_ESC .and. !empty( mfield1 ), if( (alias())-> ( dbseek ( mfield1 ) ), mrecno := (alias())->( recno()), error ( 'Record does not Exists') ), nil )

    center( 24, 'w+/n', padr( '', len( mess3 ) ) )
    dbgoto(mrecno)
    setcursor( 0 )
    setcolor( NRM )
    restscreen ( 08,25,13,62, mscr )
return nil

*                         End of the program ( amsm1014.prg )
