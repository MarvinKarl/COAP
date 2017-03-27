/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   program ID.........:  Amsm400e.prg                                         ³
³   description........:  Acctmast maintenance ( Initial Cash Outlay )         ³
³   author.............:  Ariel B. Bulan                                       ³
³   date...............:  08:40am 03-Dec-1995                                  ³
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
********************************************************************
function cash_outlay( _macctno, add_one_miss, misentered )
********************************************************************
local mblock := { | x | CASHOUT->BRCODE+Cashout->acctno == x }, cb, mdbf_, mswitch := .t., mcolor := setcolor()
local keys_  := { '<Ins>\-Add ', '<F2>\Edit ', '<F3>\Color ', '<Del>\ ', '<Esc>\' }, mscreen := savescreen( ,,, )
local tbcol_ := { tbcolumnnew( padr( 'Initial Cash Outlay', 19 ), { || tran( Cashout->paycode + ' ' + left( disppayname( Cashout->paycode ), 17 ), '@!' ) } ),;
                  tbcolumnnew( padr( 'Amount'             , 14 ), { || tran( Cashout->amount , '99,999,999,999.99'                                      ) } ),;
                  tbcolumnnew( padr( 'Ref'                ,  3 ), { || tran( Cashout->refcode, '@!'                                                     ) } ),;
                  tbcolumnnew( padr( 'Ref #'              ,  5 ), { || tran( Cashout->refno  , '@!'                                                     ) } ) }
memvar tbkill_lastrec, ax_level, g_user_id
private mis_add_one := add_one_miss, macctno := _macctno

if chkpass( procname(), ax_level, g_user_id )
   mdbf_ := savedbf()   
   tbkill_lastrec := 1                              
   waiton( 'wait a second, please!',, 'n/w' )   
   dbselectar( "Cashout" )
   Cashout->( dbseek( tbkill_code := macctno ) )
   Cashout->( dbeval( { || tbkill_lastrec++, mswitch := .f. },, { || CASHOUT->BRCODE+Cashout->acctno == macctno } ) )

   waitoff()

   if mswitch
      if !mis_add_one
         error( "No Record Found!" )
         IF CURRBRCH(LEFT(mACCTNO,3))
            __keyboard( chr( K_INS ) )
         ENDIF
      endif   
   endif

   Cashout->( dbseek( tbkill_code := macctno ) )
   cb := tb_maker( tbcol_, keys_, 09, 2, 21, 59,,, .f., macctno, mblock )
   Cashout->( tb_stabilizer( cb, { | o, k | casee400( o, k ) } ) )
   restdbf( mdbf_ )                             
   __mrelease( '*', .t. )
endif             
setcolor( mcolor )
restscreen( ,,,, mscreen )
return( nil )
********************************************************************
static function casee400( mbrowse, mkey )
********************************************************************
local misfromsubmenu := mreturn := .t., mcolor := setcolor(), mscreen := savescreen( ,,, )
memvar mis_add_one, ax_level, g_user_id, macctno

misfromsubmenu := if( mis_add_one, .f., misfromsubmenu )

do case
   case mkey == K_INS
        if CURRBRCH(LEFT(mACCTNO,3)) .AND. chkpass( 'A', ax_level, g_user_id )
           if cashout_update( 'A', misfromsubmenu, macctno )
              tb_refresh( mbrowse, 'a' )
           endif
        endif      
   case mkey == K_F2
        if CURRBRCH(CASHOUT->BRCODE) .AND. chkpass( 'E', ax_level, g_user_id )
           if CASHOUT->BRCODE+Cashout->acctno != macctno
              error( 'Nothing to Edit!' )
              Cashout->( dbseek( macctno ) )
           else  
              if cashout_update( 'E', misfromsubmenu, macctno )
                 tb_refresh( mbrowse, 'c' )
              endif
           endif
        endif    
   case mkey == K_DEL
        if CURRBRCH(CASHOUT->BRCODE) .AND. chkpass( 'D', ax_level, g_user_id )
           if CASHOUT->BRCODE+Cashout->acctno != macctno
              error( 'Nothing to Delete!' )
              Cashout->( dbseek( macctno ) )
           else 
              if confirm( 'Delete ' + tran( alltrim( Cashout->paycode +;
                 ' ' + disppayname( Cashout->paycode ) ), '@!' ) + '?' )
                 Cashout->( netlock( 'R', 0 ) )
                 Cashout->( dbdelete() )
                 Cashout->( dbskip( +1 ) )
                 if CASHOUT->BRCODE+Cashout->acctno != macctno
                    Cashout->( dbseek( macctno ) )
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
*****************************************************
static function cashout_update( mwhat,misfromsubmenu,macctno)
*****************************************************
   local mretval := .f., mrecno := Cashout->(recno()), mscr := savescreen(,,,)
   local mcursor := setcursor(), mcolor := setcolor (), mmess, mcontinue := .t.
   local mrow := 15, mcol := 14, getlist := {}
   local mref_choices := { '1 = Official Receipt','2 = Journal Voucher ' }
   local mpaycode, mamount , mrefcode, mrefno

   misfromsubmenu := if ( misfromsubmenu==nil, .f. , misfromsubmenu )
   if mwhat == 'A'
      if no_available()             // if all payment codes were already used ?
        return .f.                  // return to calling program ...
      endif
   endif
   if(upper(mwhat)==chr(65),Cashout->(dbgoto(lastrec()+1)),mwhat:=chr(82))
   mmess := if(upper(mwhat)==chr(65),'® Add Record ¯','® Edit Record ¯')
   eval({|| mpaycode := Cashout->PAYCODE, mamount := Cashout->AMOUNT,;
            mrefcode := Cashout->REFCODE, mrefno  := Cashout->REFNO })
   fshadow   ( mrow,mcol,mrow+5,mcol+36,2, 'n/gr' )
   center    ( 24, 'w+/n',mmess )
   setcolor( 'w/gr,n+/w,,, w+/gr' )
   @ mrow+1, 35 say upper ( left(disppayname(mpaycode),15) ) color 'w/gr'
   @ mrow+3, 35 say padr( upper(if(mrefcode $ '12',if(mrefcode=='1','Official Receipt','Journal Voucher'),'')), 15 ) color 'w/gr'
   do while mcontinue
      @ mrow+1,mcol+1 say '  Payment Code ' get mpaycode pict '@X'    when check_paycode( mwhat, @mpaycode, mrow+1, macctno )
      @ mrow+2,mcol+1 say '   Amount Paid ' get mamount  pict '999,999,999.99' when lastkey() != K_ESC valid mamount > 0
      @ mrow+3,mcol+1 say 'Reference Code ' get mrefcode pict '@X'    when if( lastkey() != K_ESC, check_mrefcode(mref_choices,@mrefcode,mrow+3),.f. )
      @ mrow+4,mcol+1 say '  Reference N§ ' get mrefno   pict '99999999' when lastkey() != K_ESC
      setcursor(3)
      read
      setcursor(0)

      if lastkey() == K_ESC
         if esckey()
            mcontinue := .f.
            loop
         endif   
      endif

      if lastkey() == K_ENTER
         if !misfromsubmenu
            // mrefno:=right('00000000'+alltrim(mrefno),8)
            MSGWIN(16,25,'Saving','w+/bg','r*/bg','on')
            save_cashout( mwhat,macctno,mpaycode,mamount,mrefcode,mrefno )
            mcontinue := .f. ; mretval := .t.
            MSGWIN(16,25,'Saving',,,'off')
         else
            if confirm( 'Are all entries correct?' )
               MSGWIN(16,25,'Saving','w+/bg','r*/bg','on')
               mrefno:=right('00000000'+alltrim(mrefno),8)
               save_cashout( mwhat,macctno,mpaycode,mamount,mrefcode,mrefno )
               mrecno:= Cashout->(recno()) ; mcontinue := .f. ; mretval := .t.
               MSGWIN(16,25,'Saving',,,'off')
            endif
         endif
      endif
   enddo
   Cashout->  (dbgoto(mrecno))
   setcursor  (mcursor )
   setcolor   (mcolor  )
   restscreen (,,,,mscr)
return (mretval)
**************************************************************
static function check_paycode( mwhat, mpaycode,mrow,macctno )
**************************************************************
   local mscr := savescreen(20,0,24,79)
   if mwhat == 'A'
      center ( 24, 'w+/n','® Search Payment Code ¯' )
      while .t.
         lb_lkup('Paycodes',1,1,@mpaycode, 2, 1, 09, 31, 21, 75, 'W/GR+,W/N,,,W/GR+')
         if lastkey () != K_ESC
            if Cashout->(dbseek(macctno+mpaycode))
               error('Payment Code already Exists!')
            else
               @ mrow, 35 say upper ( left(disppayname(mpaycode),15) ) color 'w/gr'
               exit
            endif
         else
            exit
         endif
      enddo
   endif
   restscreen(20,0,24,79,mscr)
return .f.
**************************************************************
static function no_available( mpaycode )
**************************************************************
   local mretval  := .f.  , mrecno := Cashout->(recno())
   local mavail   := 0

   Paycodes->(dbgotop())
   Paycodes->( dbeval({|| if(!Paycodes->(deleted()),mavail++,nil)},,{||!Paycodes->(eof())}) )
   Paycodes->(dbgotop())
   Paycodes->( dbeval({|| if( Cashout->(dbseek(ACCTMAST->BRCODE+Acctmast->ACCTNO+Paycodes->PAYCODE)),mavail--,nil ) },,;
                      {|| !Paycodes->(eof()) }))
   if(mavail == 0 ,eval({|| error('No Payment Code Available!'),mretval:=.t.}),nil)
   Cashout->(dbgoto(mrecno))
return mretval
**************************************************************
static function check_mrefcode ( mref_choices, mrefcode, mrow )
**************************************************************
   mrefcode := gen_achoice( mref_choices, val( mrefcode ), 'Reference Code', mrow+1, 56, mrow+1+len( mref_choices ), 77, 'w/gr+,w/n,,,w/gr+' )
   @ mrow, 35 say padr( upper(if( mrefcode == '1', 'Official Receipt', 'Journal Voucher') ), 15 ) color 'w/gr'
return .f.
******************************************************************************
static function save_cashout( mwhat,macctno,mpaycode,mamount,mrefcode,mrefno )
******************************************************************************
    Cashout->(netlock(mwhat,0))
    eval({|| Cashout->ACCTNO := RIGHT(macctno,14), Cashout->PAYCODE := mpaycode,;
             Cashout->AMOUNT := mamount, Cashout->REFCODE := mrefcode,;
             Cashout->REFNO  := mrefno , CASHOUT->BRCODE  := LEFT(mACCTNO,3),;
             Cashout->(dbunlock()), Cashout->(dbcommit()) })
return nil
*
*                        End of the program ( amst400e.prg )
*
