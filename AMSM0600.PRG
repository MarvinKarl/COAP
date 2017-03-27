/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³   program id.........:  amsm0600.prg                                 ³
 ³   Description........:  Acquired Assets                              ³
 ³   Author.............:  Ariel B. Bulan                               ³
 ³   Date...............:  02:50pm 04-May-1995                          ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³                         U P D A T E S                                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³        Who        ³     When      ³               Why                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³                   ³               ³                                  ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

#incl "Colf.ch"
#incl "Inkey.ch"
#incl "Memoedit.ch"

#xtrans disphead( <mcolor> ) => eval ({|| dispbegin(),;
                                          devpos( 04, 04 ) , devout( "      Account N§  ", 'w/b' ),;
                                          devpos( 04, 23 ) , devoutpict( Acqaseth->ACCTNO, "@R 9999-99999-99999", (<mcolor>) ),;
                                          devpos( 04, 41 ) , devoutpict( dispacctno( Acqaseth->ACCTNO ), "@X", (<mcolor>) ),;
                                          devpos( 05, 04 ) , devout( "        Facility  ", 'w/b' ),;
                                          devpos( 05, 23 ) , devout( tran( Acctmast->FCLTYCODE, '@R 999-99' ) + " " + dispfcltycode( Acctmast->FCLTYCODE ), (<mcolor>) ),;
                                          devpos( 06, 04 ) , devout( "Date Repossessed  ", 'w/b' ),;
                                          devpos( 06, 23 ) , devoutpict( Acqaseth->ACQDATE, "@D", (<mcolor>) ),;
                                          devpos( 07, 04 ) , devout( "            Unit  ", 'w/b' ) ,;
                                          devpos( 07, 23 ) , devoutpict( Acctmast->UNIT, "@X", (<mcolor>) ),;
                                          devpos( 08, 04 ) , devout( "                  ", 'w/b' ) ,;
                                          devpos( 08, 23 ) , devoutpict( Acctmast->UNIT2, "@X", (<mcolor>) ),;
                                          devpos( 09, 04 ) , devout( "        Location  ", 'w/b' ) ,;
                                          devpos( 09, 23 ) , devoutpict( Acqaseth->LOCATION, "@X", (<mcolor>) ),;
                                          devpos( 10, 04 ) , devout( "   Legal-Counsel  ", 'w/b' ) ,;
                                          devpos( 10, 23 ) , devoutpict( Acqaseth->COUNSEL, "@X", (<mcolor>) ),;
                                          devpos( 11, 04 ) , devout( "    Net-to-Close  ", 'w/b' ),;
                                          devpos( 11, 23 ) , devout( space( len( trans(Acqaseth->CLOSENET,"999,999,999.99") )), (<mcolor>) ),;
                                          devpos( 11, 23 ) , devout( ltrim( trans(Acqaseth->CLOSENET,"999,999,999.99") ), (<mcolor>) ),;
                                          dispend();
                                      })

memvar ax_level,g_user_id
if chkpass( procname(),ax_level,g_user_id )
   if amsm0600open()
      nosnow(.t.)
      fm0600()
      nosnow(.f.)
   endif
endif
__mrelease("*", .t.)
dbcloseall()
return
******************************
static function fm0600()
******************************
   local cb, mbanner := 'ROPOA Status Maintenance', mrow := 1, nrow := 5
   local mblock := { | x | Acqasetd->acctno == x }, mcolor := 'w+/b'
   local keys_  := { '<Ins>\-Add ', '<F2>\Edit ', '<F3>\Color ', '<F4>\Search ', '<Tab>\-Window ', '<Del>\ ', '<Esc>\' }
   local tbcol_ := { tbcolumnnew( padr( 'Date'  , 10 ), { || tran( Acqasetd->statdate, '@D' ) } ),;
                     tbcolumnnew( padr( 'Status', 59 ), { || memoline( Acqasetd->status, 59 ) } ) }
                     
   dbselectarea( "Acqaseth" )
   Acqaseth->( dbgotop() )
   if( Acqaseth->( eof() ), eval({|| ERROR("No Record Found!"), __keyboard(chr(K_INS))}),nil)
   mdbf_ := savedbf()
   dbselectar( "Acqasetd" )
   Acqasetd->( dbseek( Acqaseth->acctno ) )
   cb := tb_maker( tbcol_, keys_,,,,, mbanner,,, Acqaseth->acctno, mblock, 9,,, )
   restdbf( mdbf_ )
   while eval ( {|| disphead( mcolor )          ,; // header
                    gkey0600( cb, @mrow, @nrow ) ; // wait key
                } )
   enddo
   __mxrelease( tbkill_cel, tbkill_arg, tbkill_lastrec,;
                tbkill_code, tbkill_where, tbkill_color, tbkill_rel,;
                tbkill_mtop, tbkill_mleft, tbkill_mbottom, tbkill_mright )  
return( nil )                

////                
static function gkey0600( cb, mrow, nrow )
local  mretval := .t., mkey, mdbf_
memvar AX_LEVEL,G_USER_ID, tbkill_lastrec, tbkill_code
   
mdbf_ := savedbf()
dbselectar( "Acqasetd" )      
Acqasetd->( dbseek( tbkill_code := Acqaseth->acctno ) )      
tb_refresh( cb )
restdbf( mdbf_ )

mkey := inkey( 0 )

do case
   case mkey == K_UP .or. mkey == K_PGUP
        if chkpass('S',ax_level,g_user_id)
           Acqaseth->(dbskip(-1))
        endif   
   case mkey == K_DOWN .or. mkey == K_PGDN
        if chkpass('S',ax_level,g_user_id)
           Acqaseth->(dbskip(+1))
        endif   
   case mkey == K_HOME
        if chkpass('S',ax_level,g_user_id)
           Acqaseth->(dbgotop())
        endif   
   case mkey == K_END
        if chkpass('S',ax_level,g_user_id)
           Acqaseth->(dbgobottom())
        endif   
   case mkey == K_INS
        if chkpass('A',ax_level,g_user_id)
           updatehead('A')
        endif
   case mkey == K_F2
        if chkpass('E',ax_level,g_user_id)
           if(Acqaseth->( eof() ), error('Nothing to Edit!'),updatehead('E'))
        endif   
   case mkey == K_F4
        if chkpass('S',ax_level,g_user_id)
           if Acqaseth->(eof())
              error ('Nothing to Search!')
           else
              search_head( space(len(Acqaseth->ACCTNO)) )
           endif
        endif   
   case mkey == K_DEL
        if chkpass('D',ax_level,g_user_id)
           if Acqaseth->(eof())
              error ('Nothing to Delete!')
           else
              delete_head( Acqaseth->ACCTNO )
           endif
        endif
   case mkey == K_TAB
        if !Acqaseth->( eof() ) 
           mdbf_ := savedbf()                                 
           dbselectar( 'Acqasetd' )
           tbkill_lastrec := 1
           Acqasetd->( dbseek( tbkill_code := Acqaseth->acctno ) )
           Acqasetd->( dbeval( { || tbkill_lastrec++ },, { || Acqasetd->acctno == Acqaseth->acctno } ) )              
           tbkill_lastrec := max( tbkill_lastrec, 1 )
           Acqasetd->( dbseek( tbkill_code := Acqaseth->acctno ) )              
           Acqasetd->( tb_stabilizer( cb, { | o, k | case0600( o, k ) } ) )
           restdbf( mdbf_ )           
        endif  
   case mkey == K_ESC
        if exitmod()
           mretval := .f.
        endif
endcase
tb_indicator( mkey, @mrow, @nrow, 77, 5, 10 )
return( mretval )                  
**************************************
static function search_head( macctno )
**************************************
   local  mscr := savescreen( 24,0,24,79 ),mr := Acqaseth->(recno())
   center( 24, 'w+/n','® Search Record ¯' )
   while .t.

      eval ({|x| x := Acctmast->(indexord()) ,;
                 lb_lkup('Acctmast', 1, 6,@macctno, 3 , 1, 05, 01, 21, 78, 'n/w,w/n,,,n/w' ,'@X','@R 9999-99999-99999'),;
                 Acctmast->(dbsetorder(x))})
      if lastkey() == K_ESC
         exit
      else
         if !Acqaseth->(dbseek(macctno))
            error( 'Acct N§ '+trans(macctno,'@R 9999-99999-99999')+' does not Exist!' )
         else
            mr := Acqaseth->(recno())
         endif
         exit
      endif
   enddo
   Acqaseth->(dbgoto(mr))
   restscreen( 24,0,24,79,mscr )
return nil
**************************************
static function delete_head( macctno )
**************************************
    if confirm ( 'Delete Acct N§ '+trans(macctno,'@R 9999-99999-99999') + '?' )
       if Acqaseth->(netlock('R',0))
          Acqaseth->(dbdelete())
          Acqaseth->(dbskip(+1))
          if Acqaseth->(eof())
             Acqaseth->(dbgobottom())
          endif
       endif
       Acqaseth->(dbunlock())
       if Acqasetd->(netlock('F',0))
          Acqasetd->(dbseek(macctno))
          Acqasetd->(dbeval({|| Acqasetd->(dbdelete()) },,{|| !Acqasetd->(eof()) .and. Acqasetd->ACCTNO == macctno }))
       endif
       Acqasetd->(dbunlock())
    endif
return nil
***********************************
static function updatehead( mwhat )
***********************************
   local mretval := .f., mcursor := setcursor(), mrecno := Acqaseth->(recno()),;
         macctno, mfcltycode, macqdate, munit, munit2, mlocation, mcounsel,;
         mclosenet, mcolor := setcolor(), mscr := savescreen(,,,)
   memvar getlist

   if upper (mwhat) == 'A'
      eval({|| Acqaseth->(dbgoto(lastrec()+1)),center(24, 'w+/n','® Add Record ¯')})
   else
      eval({|| mwhat := 'R', CENTER ( 24, 'w+/n', '® Edit Record ¯') })
   endif

   Acctmast->( dbseek(Acqaseth->ACCTNO) )

   eval ({|| macctno    := Acqaseth->ACCTNO    ,;
             mfcltycode := Acctmast->FCLTYCODE ,;
             macqdate   := Acqaseth->ACQDATE   ,;
             munit      := Acctmast->UNIT      ,;
             munit2     := Acctmast->UNIT2     ,;
             mlocation  := Acqaseth->LOCATION  ,;
             mcounsel   := Acqaseth->COUNSEL   ,;
             mclosenet  := Acqaseth->CLOSENET   ;
         })
   setcolor( 'gr+/b, w+/g,,, gr+/b' ) 
   disphead( 'gr+/b' )
   do while .t.
      @ 04, 23 gget macctno    picture '@R 9999-99999-99999' when chkacctno( @macctno,mwhat,@mfcltycode,@munit,@munit2 )
      @ 05, 23 gget mfcltycode picture '@R 999-99' when .f.
      @ 06, 23 gget macqdate   picture '@D'
      @ 07, 23 gget munit      picture '@X30' when .f.
      @ 08, 23 gget munit2     picture '@X30' when .f.
      @ 09, 23 gget mlocation  picture '@X'
      @ 10, 23 gget mcounsel   picture '@X'
      @ 11, 23 gget mclosenet  calculator picture '999,999,999.99' valid mclosenet > 0
      setcursor(3)
      read
      setcursor(0)
      if lastkey() == K_ESC
         if esckey()
            exit
         else
            loop
         endif
      endif
      if confirm('Are all entries correct?')
         if Acqaseth-> ( netlock(mwhat,0) )
            eval ({|| Acqaseth->ACCTNO    := macctno   ,;
                      Acqaseth->ACQDATE   := macqdate  ,;
                      Acqaseth->LOCATION  := mlocation ,;
                      Acqaseth->COUNSEL   := mcounsel  ,;
                      Acqaseth->CLOSENET  := mclosenet ,;
                      Acqaseth->(dbcommit()), Acqaseth->(dbunlock()) ,;
                      mrecno := Acqaseth->(recno()), mretval := .t.   ;
                  })
            exit
         endif
      endif
   enddo
   Acqaseth->(dbgoto(mrecno));setcolor(mcolor);restscreen(,,,,mscr)
return mretval
******************************************************************
static function chkacctno( macctno,mwhat,mfcltycode,munit,munit2 )
******************************************************************
   local mscr := savescreen( 24,0,24,79 )
   center( 24,'w+/n','® Search Acct N§ ¯' )
   while .t. .and. mwhat == 'A'
      eval ({|x| x := Acctmast->(indexord()) ,;
                 lb_lkup('Acctmast', 1, 6,@macctno, 3 , 1, 06, 02, 21, 78, 'n/w,w/n,,,n/w' ,'@X','@R 9999-99999-99999'),;
                 Acctmast->(dbsetorder(x))})
      if lastkey() == K_ESC
         __keyboard( chr( 27 ) )	
         exit
      else
         if Acqaseth->(dbseek(macctno))
            error( 'Acct N§ '+trans(macctno,'@R 9999-99999-99999')+' already Exists!' )
         else
            Acctmast->(dbseek(macctno))
            mfcltycode := Acctmast->FCLTYCODE
            munit      := Acctmast->UNIT
            munit2     := Acctmast->UNIT2
            @ 04, 41 say dispacctno    ( Acctmast->ACCTNO    )
            @ 05, 30 say dispfcltycode ( Acctmast->FCLTYCODE )
            exit
         endif
      endif
   enddo
   restscreen( 24,0,24,79,mscr )
return .f.

////
static function case0600( cb, mkey )
local mcolor := setcolor(), mscreen := savescreen( ,,, ), mreturn := .t.
memvar AX_LEVEL, G_USER_ID

do case            
   case mkey == K_INS
        if chkpass('A',AX_LEVEL,G_USER_ID)
           update_detail('A')
           tb_refresh( cb, 'a' )
        endif   
   case mkey == K_F2
        if chkpass('E',AX_LEVEL,G_USER_ID)
           if Acqasetd->acctno != Acqaseth->acctno
              error('Nothing to Edit!')
              Acqasetd->(dbseek(Acqaseth->acctno))
           else
              update_detail('E')
           endif        
           tb_refresh( cb, 'c' )           
        endif   
   case mkey == K_DEL
        if chkpass('D',AX_LEVEL,G_USER_ID)
           if Acqasetd->acctno != Acqaseth->acctno
              error('Nothing to Delete!')
           else
              delete_detail( Acqaseth->acctno )
           endif   
           tb_refresh( cb, 'a' )              
        endif   
   case mkey == K_F4
        if chkpass('S',AX_LEVEL,G_USER_ID)
           if Acqasetd->acctno != Acqaseth->acctno
              eval({|| error('Nothing to Search!'),Acqasetd->(dbseek(Acqaseth->acctno)) })
           else
              search_detail( Acqaseth->acctno )
           endif
           tb_refresh( cb, 'a' )              
        endif    
   otherwise
        mreturn := !mreturn     
endcase
setcolor( mcolor )
restscreen( ,,,, mscreen )
return( mreturn )                 
****************************************
static function delete_detail( macctno )
****************************************
   if confirm( 'Delete Status Date '+dtoc(Acqasetd->STATDATE)+ '?' )
      if Acqasetd->(netlock('R',0))
         Acqasetd->(dbdelete())
         Acqasetd->(dbskip(+1))
         if Acqasetd->acctno != Acqaseth->acctno         
            Acqasetd->(dbseek(Acqaseth->acctno))
         endif   
      endif
      Acqasetd->(dbunlock())
   endif
return nil 
****************************************
*
static function search_detail( macctno )
****************************************
   local  mr := Acqasetd->(recno()),mstatdate := ctod('//')
   memvar getlist

   center ( 24, 'w+/n', '® Search Record ¯' )
   fshadow( 17, 16, 19, 41, 2, 'n/w' )
   setcolor( 'bg+/w, w+/n,,, gr+/w' )    
   @ 18,17 say 'Status Date ' get mstatdate pict '@D'
   setcursor(3)
   read
   setcursor(0)
   if lastkey() != K_ESC .and. !empty(mstatdate)
      if !Acqasetd->(dbseek(macctno+dtos(mstatdate)))
         error ( 'Status Date not Found!' )
      else
         mr := Acqasetd->(recno())
      endif
   endif
   Acqasetd->(dbgoto(mr))
return nil
**************************************
static function update_detail( mwhat )
**************************************
   local  mretval := .f. ,macctno, mstatdate , mstatus,mcursor := setcursor(),;
          mscr := savescreen( ,,, ) , mcolor := setcolor(), mstat ,;
          mrecno := Acqasetd->(recno()), mlines, i, i2 := 0
   memvar getlist
   if mWHAT == 'A'
      Acqasetd->( dbgoto ( lastrec()+1 ) )
      center ( 24, 'w+/n', '® Add Details ¯' )
   else
      mWHAT := 'R'
      center ( 24, 'w+/n', '® Edit Details ¯' )
   endif
   fshadow( 13, 2, 21, 77, 2, 'w+/b' )
   setcolor( 'gr+/b, w+/g,,, gr+/b' ) 

   macctno   := Acqaseth->ACCTNO
   mstatdate := Acqasetd->STATDATE
   mstatus   := Acqasetd->STATUS
   do while .t.
      mlines := min( mlcount( mstatus,59),6 ) ; i2 := 0
      for i := 14 to 14+mlines 
          devpos ( i,17 ); devout( memoline(mstatus,59,i2), 'n/w' )
          devpos ( i,15 ); devout( '', 'gr+/b' )
          i2++
      next i
      @ 14, 03 say 'Status Date ' get mstatdate pict '@D' valid chkmstatdate( mstatdate )
      @ 15, 03 say '     Status ' get mstat     when  memo_get(@mstatus)
      setcursor( 3 )
      read
      setcursor( 0 )
      do case
         case lastkey() == K_ESC
            if esckey()
               exit
            endif
         otherwise
            if confirm ( 'Are all entries correct?' )
               if Acqasetd->(netlock(mwhat,0))
                  Acqasetd->ACCTNO   := macctno
                  Acqasetd->STATDATE := mstatdate
                  Acqasetd->STATUS   := mstatus
               endif
               Acqasetd->(dbcommit()) ; Acqasetd->(dbunlock()) ; mretval := .t.
               mrecno := Acqasetd->(recno())
               exit
            endif
      endcase

   enddo
   setcursor( mcursor ) ; setcolor(mcolor) ; restscreen( ,,,,mscr )
   Acqasetd->(dbgoto(mrecno))
return mretval
*****************************************
static function chkmstatdate( mstatdate )
*****************************************
   local mretval := .t. , mr := Acqasetd->(recno())
   if empty(mstatdate)
      return .f.
   endif
   if lastkey() != K_ESC
      if Acqasetd->(dbseek(Acqaseth->ACCTNO+dtos(mstatdate))) .and. ;
         Acqasetd->(recno()) != mr
         error ( 'Status Date already Exists!'); mretval := .f.
      endif
   endif
   Acqasetd->(dbgoto(mr))
return mretval
**********************************
static function memo_get (mstatus)
**********************************
   local   mcollength := 59, mediting := .t., mc := setcolor(), mfull, mscr,;
           mlastscr   := savescreen(23,0,23,79)
   private mtop_row := 15, mtop_col := 17, mold_row, mold_col,;
           m_win_row, m_win_col, me_command := 0

   @ 23, 00 say repl( ' ',78) color (NRM)
   center ( 23, NRM, '<F9>Save <Esc>Exit' )
   @23,35 say 'Save' color 'w+/n'
   @23,45 say 'Exit' color 'w+/n'
   setcolor ( REV )
   do while mediting

      mstatus := memoedit ( mstatus, mtop_row, mtop_col, 20, 76-1, .t. ,"udf_0600", mcollength,, mold_row, mold_col, m_win_row, m_win_col )

      if !empty( me_command )
         do case
            case me_command == 1
               mediting := .f.
               loop
         endcase
         me_command := 0
      endif
   enddo

   setcolor( mc ) ; restscreen(23,0,23,79,mlastscr)

return .f.
*********************************************************
*   Description   essential function for memoedit module
*   Parameters    mode, row and column
*   Return Value  default
function udf_0600( me_mode, me_row, me_col )
******************************************
   local  me_key   := lastkey()  , me_save
   local  mcolor   := setcolor() , mcursor := setcursor ( setcursor () )
   memvar marray   , mlevel
   memvar me_macros, me_file     , me_command
   memvar mold_row , mold_col    , m_win_row, m_win_col
   memvar mretval  , mselected   , mctr
   memvar msavescr , mhead
   memvar mk_f1disable, mchoice

   if mE_MODE == ME_INIT             // initialization mode
      return ME_DEFAULT              // tell memoedit to start
   elseif mE_MODE == ME_IDLE         // idle mode, update row/column

   else
      do case
         case mE_KEY == K_ESC
              mE_COMMAND := 1
              return mE_KEY
         case mE_KEY == K_F9
              mE_KEY     := K_CTRL_END
              mE_COMMAND := 1
              return mE_KEY
         case mE_KEY == K_INS

              if readinsert()
                 setcursor( 3 )
              else
                 setcursor( 1 )
              endif
              return K_INS

      endcase
   endif
   mold_row  := me_row ; mold_col  := me_col
   m_win_row := row()  ; m_win_col := col()
return ME_DEFAULT
*************************************
static function dispacctno( macctno )
*************************************
return eval ({|| Acctmast->(dbseek(macctno)) ,;
                 padr( Acctmast->ACCTNAME, 35 )})
*******************************************
static function dispfcltycode( mfcltycode )
*******************************************
return eval({|| Facility->(dbseek(mfcltycode)),Facility->FCLTYNAME })
******************************
static function amsm0600open()
******************************
   local mretval := .f.
   memvar g_cis_path
   if netuse( 'Acctmast',.f., 5 )
      set index to Acctmast,Acctclnt,Sureclnt,Acctfa,Acctsub2,Acctacno
      if netuse( 'Facility',.f.,5)
         set index to Fcltycd
         if netuse( 'Acqaseth',.f.,5)
            set index to Acqaseth
            if netuse( 'Acqasetd',.f.,5)
               set index to Acqasetd
               mretval := .t.
            endif
         endif
      endif
   endif
return mretval
*
*                      End of the program ( Amsm0600.prg )
*