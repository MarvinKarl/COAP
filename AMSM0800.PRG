/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   PROGRAM ID.........:  amsm0800.prg                                         ³
³   Description........:  credit facility codes file maintenance               ³
³   Author.............:  Janet L. Bautista                                    ³
³   Date...............:  10:17am 29-Jul-1994                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                         U P D A T E S                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        Who        ³     When      ³               Why                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        MTS        ³   09.05.2007  ³ added facility group (FACILITY->fcltygrp)³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include "COLF.CH"
#include "INKEY.CH"
#include "ADDEDIT.CH"

if CHKPASS( procname(), ax_level, g_user_id )
   if m800open()
       m800main()
   endif   
   dbcloseall()
endif
return 

////
static function m800main()
local mbanner := 'Credit Facility Codes File Maintenance', cb, mdbf := savedbf()
local keys_   := { '<Ins>\-Add ', '<F2>\Edit ', '<F3>\Color ', '<F4>\Search ', '<Del>\ ', '<Esc>\' }
local tbcol_  := { tbcolumnnew( padr( 'Code'           ,  6 ), { || tran( FACILITY->fcltycode , '@R 999-99' ) } ),;
                   tbcolumnnew( padr( 'Alias'          , 10 ), { || tran( FACILITY->fcltyalias, '@!'        ) } ),;
                   tbcolumnnew( padr( 'Credit Facility', 30 ), { || tran( FACILITY->fcltyname , '@!'        ) } ),;
                   tbcolumnnew( padr( 'SetCode'        , 5 ), { || tran( FACILITY->setcode  ,  '9'          ) } ),;
                   tbcolumnnew( padr( 'Group' , 5 ), { || tran( FACILITY->fcltygrp ,  '9'          ) } ) }

if( FACILITY->( eof() ), eval( { || ERROR( "No record found!" ), __keyboard( chr( K_INS ) ) } ), nil )
cb := tb_maker( tbcol_, keys_,,,,, mbanner, FACILITY->( lastrec() ) )
tb_stabilizer( cb, { | o, k | case0800( o, k ) } )
restdbf( mdbf )
return(  nil )

////
static function case0800( cb, mkey )
local mretval := .t., mscreen := savescreen( ,,, )
local mrecno := FACILITY->( recno() ), mcolor := setcolor() 
memvar ax_level, g_user_id
   
do case
   case mkey == K_INS
        if CHKPASS( 'A', ax_level, g_user_id )
           scatter memvar add
           if !amsmupdate( 'A' )
              if CONFIRM( 'All entries correct?' )
                 MSGWIN(10,20,'Saving','W+/BG','R*/BG','ON')

                 if NETLOCK( 'A', 0 )
                    *if CONFIRM( 'All entries correct?' )
                       gather memvar
                    *endif
                    FACILITY->( dbunlock() )
                 endif

                 MSGWIN(10,20,'Saving','W+/BG','R*/BG','OFF')
              endif
              tb_refresh( cb, 'a' )
           else
              FACILITY->( dbgoto( mrecno ) )                 
           endif
        endif
   case mkey == K_F2
        if CHKPASS( 'E', ax_level, g_user_id )
           if FACILITY->( eof() )
              ERROR( 'Nothing to edit!' )
           else
              scatter memvar edit
              if !amsmupdate( 'R' )
                 if CONFIRM( 'All entries correct?' )
                    MSGWIN(10,20,'Saving','W+/BG','R*/BG','ON')

                    if NETLOCK( 'R', 0 )
                       *if CONFIRM( 'All entries correct?' )
                          gather memvar
                       *endif
                       FACILITY->( dbunlock() )
                    endif

                    MSGWIN(10,20,'Saving','W+/BG','R*/BG','OFF')
                 endif
                 tb_refresh( cb, 'c' )            
              endif   
           endif   
        endif
   case mkey == K_DEL
        if CHKPASS( 'D', ax_level, g_user_id )
           if FACILITY->( eof() )
              ERROR( 'Nothing to delete!' )
           else   
              amsmdelete()
              tb_refresh( cb, 'a' )            
           endif   
         endif
   case mkey == K_F4
        if CHKPASS( 'S', ax_level, g_user_id )
           if FACILITY->( eof() )
              ERROR( 'Nothing to search!' )
           else
              amsmsearch()
              tb_refresh( cb, 'a' )            
           endif   
        endif
   otherwise
        mretval := !mretval   
endcase
restscreen( ,,,, mscreen )
setcolor( mcolor )
return( mretval )

////
static function amsmupdate( mcode )
memvar _m_fcltycode, _m_fcltyalias, _m_fcltyname, _m_setcode, _m_fcltygrp
private mKEYS, mGROUP 

center( 24, 'w+/n', '® ' + if( mcode == 'A', 'Add', 'Edit' ) + ' Record ¯' ) 
fshadow( 9, 5, 15, 44, 2, 'n/w' )
setcolor( 'R/w, w+/n,,, gr/w' )

if( mcode == 'A', nil,fgroup(_m_fcltygrp))

@ 10, 6  say '  Facility Code ' get _m_fcltycode  picture '@R 999-99' when mcode == 'A' valid chkfcltycode( _m_fcltycode ) .AND. !EMPTY(_M_FCLTYCODE)
@ 11, 6  say ' Facility Alias ' get _m_fcltyalias picture '@!'                          valid !empty( _m_fcltyalias )
@ 12, 6  say 'Credit Facility ' get _m_fcltyname  picture '@!S20'                       valid !empty( _m_fcltyname  )
@ 13, 6  say ' Facility Group ' get _m_fcltygrp   picture '9'				 valid !empty( _m_fcltygrp ) .and. _m_fcltygrp $ '1234'          
@ 13, 26 get   mGROUP when eval({|| FGROUP(_m_fcltygrp),.f. })
@ 14, 6  say '        Setcode ' get _m_setcode    picture '9'                           valid !empty( _m_setcode    )

setcursor( 3 )
setkey( K_ESC, { || fEscape( 'Abort?' ) } )
read
setkey( K_ESC, nil ) 
setcursor( 0 )
return( lastkey() == K_ESC )

////
static function chkfcltycode( mcode )
local mreturn := .t., mrecno := FACILITY->( recno() )

if FACILITY->( dbseek( mcode ) )
   ERROR('Duplicate facility code!')
   FACILITY->( dbgoto( mrecno ) )
   mreturn := !mreturn
endif   
return( mreturn )

******************************
*
static function FGROUP(gcode)
******************************
do case
	case gcode == '1'
	     mGROUP := '- LEASE      '
	case gcode == '2'
	     mGROUP := '- LOAN       '
	case gcode == '3'
	     mGROUP := '- RECEIVABLES'
	case gcode == '4'
	     mGROUP := '- OTHERS     '
endcase
return 

////
static function amsmdelete()

if CONFIRM( 'Delete facility code ' + tran( FACILITY->Fcltycode, '@R 999-99' ) + '?' )
   MSGWIN(9,35,'Deleting','W+/BG','R*/BG','ON')

   if NETLOCK( 'R', 0 )
      FACILITY->( dbdelete() )
      FACILITY->( dbskip( +1 ) )
      if FACILITY->( eof() )
         FACILITY->( dbgobottom() )
      endif
      FACILITY->( dbunlock() )
   endif

   MSGWIN(9,35,'Deleting','W+/BG','R*/BG','OFF')
endif
return( nil )

////
static function amsmsearch()
local mcode := space( 5 ), mrecno := FACILITY->( recno() )

center( 24, 'w+/n', 'Search Record' )
fshadow( 11, 13, 13, 36, 2, 'n/w' )
setcolor( 'bg+/w, w+/n,,, gr+/w' ) 
@ 12, 14 say 'Facility Code ' get mcode picture '@R 999-99'

setcursor( 3 )
read
setcursor( 0 )

if !FACILITY->( dbseek( mcode ) )
   ERROR('No such record!')
   FACILITY->( dbgoto( mrecno ) )
endif   
return( nil )

// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   static function m800open()
// ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   if !NETUSE('&g_AMS_PATH\FACILITY',.f.,5)
      return .f.
   endif
   set index to &g_AMS_PATH\Fcltycd
   return .t.

// Eop: AMSM0800.prg //
