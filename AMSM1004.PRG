/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   program id.........:  amsm1004.prg                                         ³
³   description........:  currency code file maintenance                       ³
³   author.............:  Ariel B. Bulan                                       ³
³   date...............:  01:16pm 03-Nov-1994                                  ³
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
   if amsm1004open()
      nosnow( .t. )
      amsm1004main()
      nosnow( .f. )
   endif
endif
release all
close data
return
***********************************************
static function amsm1004main()
***********************************************
   local mbanner := 'Currency Code File Maintenance', cb  
   local keys_  := { '<Ins>\-Add ', '<F2>\Edit ', '<F3>\Color ', '<F4>\Search ', '<Del>\ ', '<Esc>\' }   
   local tbcol_  := { tbcolumnnew( 'Code         ', { || trans( Currency->currcode, '@!'        ) } ),;
                      tbcolumnnew( 'Currency Name', { || trans( Currency->currname, '@!'        ) } ),;
                      tbcolumnnew( 'Exchange Rate', { || trans( Currency->rate    , '9999.9999' ) } ) }

   if( ( alias() )->( eof() ), eval( { || error("No record found!"), __keyboard( chr( K_INS ) ) } ), nil )
   cb := tb_maker( tbcol_, keys_,,,,, mbanner, Currency->( lastrec() ) )
   tb_stabilizer( cb, { | o, k | case1004( o, k ) } )
return( nil )
*******************************************************************
static function case1004( cb, mkey )
*******************************************************************
   local mretval := .t., mscreen := savescreen( ,,, ), mcolor := setcolor()
   memvar ax_level,g_user_id
   
   do case
      case mkey == K_INS
         if chkpass('A',ax_level,g_user_id)
            amsm_add_edit( 'A' )
            tb_refresh( cb, 'a' )
         endif
      case mKEY == K_F2
         if chkpass('E',ax_level,g_user_id)
            if( ( alias() )->( eof() ), ERROR('Nothing to edit!'), amsm_add_edit('E'))
            tb_refresh( cb, 'c' )            
         endif
      case mKEY == K_DEL
         if chkpass('D',ax_level,g_user_id)
            if( ( alias() )->( eof() )                               ,;
            error('Nothing to delete!'),                              ;
            amsmdelete( 'Delete '+ alltrim( (alias())->(fieldget(2)))))
            tb_refresh( cb, 'a' )            
         endif
      case mKEY == K_F4
         if chkpass('S',ax_level,g_user_id)
            if( ( alias() )->( eof() ) , ERROR('Nothing to search!'), amsmfind())
            tb_refresh( cb, 'a' )            
         endif
      otherwise
         mretval := !mretval   
      endcase
setcolor( mcolor )
restscreen( ,,,, mscreen )      
return ( mretval )
**********************************************************
static function amsm_add_edit( mwhat )
**********************************************************
    local mrecno := recno()      , mcontinue := .t., mscr := savescreen ( 08,25,14,62 )
    local mfield1 ,  mfield2, mfield3, getlist := {}
    if( upper( mwhat ) == chr(65), dbgoto( lastrec() + 1 ), mwhat := chr(82) )
    eval     ({|| mfield1 := (alias())->( fieldget(1) ), mfield2 := (alias())->( fieldget(2)), mfield3 := (alias())->(fieldget(3)) })
    
    if mwhat == 'A'
       center ( 24, 'w+/n', '® Add Details ¯' )
   else
       center ( 24, 'w+/n', '® Edit Details ¯' )
    endif
    fshadow( 9, 25, 13, 57, 2, 'n/w')
    setcolor( 'bg+/w, w+/n,,, gr+/w' )
    do while mcontinue
       @ 10, 26 say 'Currency Code ' get mfield1 pict '@X'    when ( upper( mwhat ) == chr ( 65 ) ) valid check_code ( mfield1 )
       @ 11, 26 say 'Currency Name ' get mfield2 pict '@XS15'
       @ 12, 26 say 'Currency Rate ' get mfield3 pict '9999.9999'

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
                   EVAL({ || MSGWIN(9,39,'Saving','w+/bg','r*/bg','on'),;
                             if( (alias())->( netlock(mwhat,0) ),;
                                 eval({|| fieldput( 1, mfield1 ),;
                                          fieldput ( 2 , mfield2 ),;
                                          fieldput ( 3 , mfield3 ),;
                                          mrecno := (alias())->(recno()),;
                                          (ALIAS())->(DBUNLOCK()),;
                                          mcontinue := .f.;
                                     }),;
                                 nil;
                               ),;
                             MSGWIN(9,39,'Saving','w+/bg','r*/bg','off') }),;
                   nil;
                 ),;
               nil;
             );
         )
    enddo
    dbgoto   (mrecno) ; setcursor ( 0 ) ; setcolor ( NRM ) ; restscreen ( 08,25,14,62, mscr )
return nil
**************************
static function amsmfind ( mess1, mess2, mess3 )
************************************************
    local mrecno     := (alias()) ->(recno()) , mscr  := savescreen ( 08,25,14,62 )
    local mfield1    := space ( len ( (alias())->( fieldget (1) ) ) )
    local mfield2    := space ( len ( (alias())->( fieldget (2) ) ) )
    local mfield3    := 0
    local getlist    := {}
    
    center( 24, 'w+/n', '® Search Record ¯' )
    fshadow( 12, 25, 14, 44, 2, 'n/w')
    setcolor( 'bg+/w, w+/n,,, gr+/w' )

    @ 13, 26 say 'Currency Code ' + chr( 16 ) get mfield1 pict '@X'

    setcursor( 3 )
    read
    setcursor( 0 )

    if( lastkey() != K_ESC .and. !empty( mfield1 ),;
       if( (alias())->(dbseek(mfield1)),;
           mrecno := (alias())->(recno()),;
           error('No such record!');
         ),;
       nil;
      )
    dbgoto(mrecno)
    setcursor( 0 )
    setcolor( NRM )
    restscreen( 08,25,14,62, mscr )
return nil
******************************
static function amsm1004open()
******************************
   local mretval
   if( netuse ( '&g_AMS_PATH\Currency', .f. , 5 ),;
       eval ({ || dbsetindex( '&g_AMS_PATH\Currency' ),;
                  mretval := .t.;
            }),;
       mretval := .f.;
     )
return mretval

// Eop: AMSM1004.prg //
