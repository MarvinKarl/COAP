/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   program id.........:  amsm1011.prg                                         ³
³   description........:  Approvers                                            ³
³   author.............:  Ariel B. Bulan                                       ³
³   date...............:  08:59pm 18-Aug-1995                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                         U P D A T E S                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        Who        ³     When      ³               Why                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#incl "Colf.ch"
#incl "Inkey.ch"

memvar ax_level,g_user_id
if chkpass( procname(),ax_level,g_user_id )
   if amsm1011open()
      nosnow( .t. )
      fm1011()
      nosnow( .f. )
   endif
   eval ({|| __mrelease("*", .t.), dbcloseall() })
endif
return

////
static function fm1011()
return( eval( { | n | fmd1011(), n } ) )

////
static function fmd1011()
local mcolor := setcolor(), mscreen := savescreen( ,,, )
local mbanner := 'Approvers Maintenance', cb
local keys_  := { '<Ins>\-Add ', '<F2>\Edit ', '<F3>\Color ', '<F4>\Search ', '<Del>\ ', '<Esc>\' }   
local tbcol_ := { tbcolumnnew( padr( 'Initial' ,  7 ), { || Approvers->approver                 } ),;
                  tbcolumnnew( padr( 'Fullname', 40 ), { || dispname( Approvers->approver, 40 ) } ) }

Approvers->( dbgotop() )
if( Approvers->( eof() ), eval( { || error( "No Record Found!" ), __keyboard( chr( K_INS ) ) } ), nil )
cb := tb_maker( tbcol_, keys_,,,,, mbanner, Approvers->( lastrec() ) )
tb_stabilizer( cb, { | o, k | case1011( o, k ) } )
setcolor( mcolor )
restscreen( ,,,, mscreen )
return( nil )   

////
static function dispname( mapprover, mwidth )
return( padr( eval( { || Personel->( dbseek( mapprover ) ),;
                         Personel->fullname } ), mwidth ) )

////
static function case1011( cb, mkey )
local mscreen := savescreen( ,,, ), mcolor := setcolor(), mreturn := .t.
memvar ax_level,g_user_id 

do case
   case mkey == K_INS
        if chkpass('A',ax_level,g_user_id)
           update_1011( 'A' )
           tb_refresh( cb, 'a' )
        endif
   case mkey == K_F2
        if chkpass('E',ax_level,g_user_id)
           if Approvers -> ( eof() )       
              error('Nothing to Edit!')            
           else   
              update_1011( 'E' )
              tb_refresh( cb, 'c' )           
           endif   
        endif
   case mkey == K_DEL
        if chkpass('D',ax_level,g_user_id)
           if Approvers -> ( eof() )
              error('Nothing to Delete!')
           else
              delete1011()
              tb_refresh( cb, 'a' )              
           endif
         endif
   case mkey == K_F4
        if chkpass('S',ax_level,g_user_id)
           if Approvers -> ( eof() )
              error('Nothing to Search!')
           else
              search1011()
              tb_refresh( cb, 'a' )              
           endif
        endif
   otherwise     
        mreturn := !mreturn   
endcase
setcolor( mcolor )
restscreen( ,,,, mscreen )
return( mreturn )

////
static function search1011()
local mrec := Approvers->( recno() ), mwhat := .t.
local mapprove := space( len( Approvers->approver ) )

center( 24, 'w+/n', '® Search Record ¯' )
fshadow( 10, 5, 12, 23, 2, 'n/w' )
setcolor( 'bg+/w, w+/n,,, gr+/w' ) 
@ 11, 6 say 'Approver ' + chr( 16 ) get mapprove pict '@!K'

setcursor( 3 )
read
setcursor( 0 )

if !empty( mapprove ) .and. lastkey() != K_ESC
   Approvers->( dbgotop() )
   Approvers->( dbeval( { || nil },, { || Approvers->approver != mapprove } ) )
   if Approvers->approver != mapprove
      Approvers->( dbgoto( mrec ) )
      error( 'Approver does not Exists!' )
   endif   
endif
center( 24, 'w+/n', '                    ' )
return nil

////
static function delete1011()

if confirm ( 'Delete Initial ' + trim( Approvers->approver ) + '?' )
   MSGWIN(10,35,'Deleting','W+/BG','R*/BG','ON')
   if Approvers->( netlock ( 'R', 0 ) )
      Approvers->( dbdelete() )
      Approvers->( dbskip( +1 ) )
      if Approvers->( eof() )
         Approvers->( dbgobottom() )
      endif
      Approvers->( dbunlock() )
   endif   
   MSGWIN(10,35,'Deleting','W+/BG','R*/BG','OFF')
endif
return( nil )

////
static function update_1011( mwhat )
local mrec := Approvers->( recno() ), mapprover

if mwhat == 'A'
   Approvers->( dbgoto( lastrec() + 1 ) )
   center ( 24, 'w+/n', '® Add Details ¯' )
else
   mwhat := 'R'
   center ( 24, 'w+/n', '® Edit Details ¯' )
endif

mapprover := padr( Approvers->approver, 5 )
fshadow( 10, 5, 12, 46, 2, 'n/w' )
setcolor( 'bg+/w, w+/n,,, gr+/w' ) 
@ 11, 6 say 'Approver ' + chr( 16 ) get mapprover pict '@!K' valid chkapprover( mapprover )
@ 11, 23 say dispname( mapprover, 23 )
setcursor( 3 )
read
setcursor( 0 )
if lastkey() != K_ESC
   MSGWIN(12,16,'Saving','W+/BG','R*/BG','ON')
   if Approvers->( netlock( mwhat, 0 ) )
      Approvers->approver := mapprover
      Approvers->( dbunlock() )
      Approvers->( dbcommit() )
   endif
   MSGWIN(12,16,'Saving','W+/BG','R*/BG','OFF')
else
   Approvers->( dbgoto( mrec ) )
endif
return( nil )

////
static function chkapprover( mapprover )
local mr := Approvers->( recno() ), mretval := .f.

if lastkey() != K_ESC .and. !empty ( mapprover )
   do case
      case empty( dispname( mapprover, 22 ) )
           error ( 'User ID does not Exists!' )
      otherwise
           Approvers -> ( dbgotop() )
           Approvers -> ( dbeval ({|| if ( alltrim(Approvers -> APPROVER ) == mapprover, mretval := .t.,nil ) },,;
                                  {|| !Approvers -> ( eof() ) .and. !mretval };
                                 ) )
           Approvers -> ( dbgoto ( mr ) )
           if mretval
              error ( 'Approver already Exists!' )
              mretval := .f.
           else
              mretval := .t.
           endif
   endcase
endif
return( mretval )

////
static function amsm1011open()
local mretval := .f.
memvar g_grf_path

if netuse( '&g_AMS_PATH\Axmast',.f., 5 )
   set index to &g_AMS_PATH\User_id

   if netuse( '&g_grf_path'+'\Personel.dbf',.f.,5)
      set index to &g_grf_path\Initials.ntx

      if netuse( '&g_AMS_PATH\Approvers',.f.,5)
         mretval := .t.
      endif
   endif
endif
return( mretval )
*
*                    End of the program ( amsm1011.prg )
*
