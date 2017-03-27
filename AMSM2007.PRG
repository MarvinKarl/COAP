/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³   program id.........:  amsm2007.prg                                 ³
 ³   description........:  Invoices file maintenance                    ³
 ³   author.............:  Ariel B. Bulan                               ³
 ³   date...............:  11:59pm 18-Sep-1995                          ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³                         U P D A T E S                                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³        Who        ³     When      ³               Why                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³                   ³               ³                                  ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

#include "COLF.CH"
#include "INKEY.CH"

memvar ax_level,g_user_id
if chkpass( procname(),ax_level,g_user_id )
   if amsm2007open()
      nosnow (.t.)
      fm2007 ()
      nosnow (.f.)
   endif
   release all
   close data
endif
return
******************************************
*   Description   program's main function
*   Parameters    none
*   Return Value  nil
static function fm2007()
******************************************
   local cb, mbanner := 'Invoices File Maintenance', mrow := 1, nrow := 5
   local mblock := { | x | Inv_dtls->acctno == x }, mcolor := 'w+/b'
   local keys_  := { '<Ins>\-Add ', '<F2>\Edit ', '<F3>\Color ', '<F4>\Search ', '<Tab>\-Window ', '<Del>\ ', '<Esc>\' }
   local tbcol_ := { tbcolumnnew( padr( 'Invoice Date'  , 12 ), { || tran( Inv_dtls->invdate, '@D'             ) } ),;
                     tbcolumnnew( padr( 'Invoice Amount', 14 ), { || tran( Inv_dtls->invamt , '999,999,999.99' ) } ),;
                     tbcolumnnew( padr( 'Invoice N§'    , 15 ), { || tran( Inv_dtls->invno  , '@!'             ) } ),;
                     tbcolumnnew( padr( 'Invoice Status', 14 ), { || dispstatus( Inv_dtls->status              ) } ) }
                     
   dbselectarea ( "Inv_head" )
   Inv_head->( dbgotop() )
   if( Inv_head->( eof() ), eval({|| ERROR("No Record Found!"), __keyboard(chr(K_INS))}),nil)
   mdbf_ := savedbf()
   dbselectar( "Inv_dtls" )
   Inv_dtls->( dbseek( Inv_head->acctno ) )
   cb := tb_maker( tbcol_, keys_,,,,, mbanner,,, Inv_head->acctno, mblock, 5,,, )
   restdbf( mdbf_ )
   while eval ( {|| disphead ( mcolor )          ,; // header
                    gkey2007( cb, @mrow, @nrow ) ; // wait key
                } )
   enddo   
   __mxrelease( tbkill_cel, tbkill_arg, tbkill_lastrec,;
                tbkill_code, tbkill_where, tbkill_color, tbkill_rel,;
                tbkill_mtop, tbkill_mleft, tbkill_mbottom, tbkill_mright )  
return nil
***************************************
static function gkey2007( cb, mrow, nrow )
***************************************
   local  mretval := .t., mkey, mdbf_
   memvar ax_level,g_user_id, tbkill_lastrec, tbkill_code
   
   mdbf_ := savedbf()
   dbselectar( "Inv_dtls" )      
   Inv_dtls->( dbseek( tbkill_code := Inv_head->acctno ) )      
   tb_refresh( cb )
   restdbf( mdbf_ )

   mkey := inkey( 0 )

   do case
      case mkey == K_UP .or. mkey == K_PGUP
           if chkpass('S',ax_level,g_user_id)
              Inv_head-> ( dbskip ( -1 ) )
           endif   
      case mkey == K_DOWN .or. mkey == K_PGDN
           if chkpass('S',ax_level,g_user_id)
              Inv_head-> ( dbskip ( +1 ) )
           endif   
      case mkey == K_HOME
           if chkpass('S',AX_LEVEL,G_USER_ID)
              Inv_head->(dbgotop())
           endif 
      case mkey == K_END
           if chkpass('S',AX_LEVEL,G_USER_ID)
              Inv_head->(dbgobottom())
           endif   
      case mkey == K_INS
           if chkpass('A',AX_LEVEL,G_USER_ID)
              updatehead('A')
           endif   
      case mkey == K_DEL
           if chkpass('D',AX_LEVEL,G_USER_ID)
              if Inv_head->( eof() )
                 error('Nothing to Delete!')
              else
                 if confirm ('Delete Acct N§ '+tran(Inv_head->ACCTNO, '@R 9999-99999-99999' )+'?')
                    delete_head()
                 endif
              endif   
           endif   
      case mkey == K_F2
           if chkpass('E',AX_LEVEL,G_USER_ID)
              if(Inv_head->( eof() ), error('Nothing to Edit!'),updatehead('E'))
           endif   
      case mkey == K_F4
           if chkpass('S',AX_LEVEL,G_USER_ID)
              if Inv_head->( eof() )
                 error( 'Nothing to Search!' )
              else
                 search_head ( space(len(Inv_head->ACCTNO)) )
              endif
           endif   
      case mkey == K_TAB
           if !Inv_head->( eof() )
              mdbf_ := savedbf()                                 
              dbselectar( 'Inv_dtls' )
              tbkill_lastrec := 1
              Inv_dtls->( dbseek( tbkill_code := Inv_head->acctno ) )
              Inv_dtls->( dbeval( { || tbkill_lastrec++ },, { || Inv_dtls->acctno == Inv_head->acctno } ) )
              tbkill_lastrec := max( tbkill_lastrec, 1 )
              Inv_dtls->( dbseek( tbkill_code := Inv_head->acctno ) )              
              Inv_dtls->( tb_stabilizer( cb, { | o, k | case2007( o, k ) } ) )
              restdbf( mdbf_ )           
           endif   
      case mkey == K_ESC
           if exitmod()
              mretval := .f.
           endif
   endcase
   tb_indicator( mkey, @mrow, @nrow, 77, 5, 6 )   
return mretval
***************************************************************
*   Description   add/edits INV_HEAD.DBF
*   Parameters    type >> 'A' = Add else Edit
*   Return Value  nil
static function updatehead( mWHAT )
***********************************
   local  mACCTNO, mCLNTCODE, mRECDATE, mRECEIVER,macctnoful
   local  mPERFORMING := .t. , mRECNO := recno(), mcolor := setcolor()
   memvar g_USER_ID,g_CIS_PATH, getlist

   if ( upper( mWHAT ) == 'A', Inv_head->(dbgoto(lastrec()+1)) , mWHAT := 'R')
   macctno    := right( Inv_head->ACCTNO,5 )
   macctnoful := Inv_head->ACCTNO
   mclntcode  := Inv_head->CLNTCODE
   mrecdate   := Inv_head->RECDATE
   mreceiver  := Inv_head->RECEIVER
   if mwhat == 'A'
      center ( 24, 'w+/n','® Add Record ¯')
   else
      center ( 24, 'w+/n','® Edit Record ¯')
   endif
   setcolor( 'gr+/b, w+/g,,, gr+/b' ) 
   do while mPERFORMING
      @ 5, 36 say dispCLNTNAME( mCLNTCODE, 40 )
      @ 7, 33 say dispRECEIVER( mRECEIVER ) 
      if mWHAT == 'A'
         @ 04, 37 get mACCTNO   pict '@KR 99999' when getclear() valid chkacctno( @macctno,@mclntcode,@macctnoful )
      endif   
      @ 05, 26 get mCLNTCODE pict '@R 99-99999' when .f.
      @ 06, 26 get mRECDATE  pict '@D'
      @ 07, 26 get mRECEIVER pict '@X' when fchkreceiver ( @mRECEIVER ) valid !empty ( mRECEIVER )
      setcursor( 3 )                                 
      read
      setcursor( 0 )
      if lastkey() == K_ESC
         if esckey()
            exit
         else
            loop
         endif
      endif
      if CONFIRM('Are all entries correct?')
         if Inv_head-> ( NETLOCK( mWHAT, 0 ) )
            eval({|| Inv_head->ACCTNO   := macctnoful,;
                     Inv_head->CLNTCODE := mCLNTCODE ,;
                     Inv_head->RECDATE  := mRECDATE  ,;
                     Inv_head->RECEIVER := mRECEIVER  ;
                })
            Inv_head-> ( dbunlock() ) ; Inv_head->( dbcommit() )
            mRECNO := recno()
            exit
         endif
      endif
   enddo
   setcolor( mcolor )
   go mRECNO
   center( 24, 'w+/n', '                         ' )
return nil

////
static function getclear()
@ 4, 26 say Inv_head->acctno pict '@R 9999-99999-99999' color 'gr+/b' 
return( .t. )
**********************************************
static function fchkreceiver ( mRECEIVER )
**********************************************
   center ( 24, 'w+/n','® Select Receiver ¯' )
   lb_lkup('Personel',1,1,@mRECEIVER, 1 , 2, 11, 12, 21, 75, 'W/GR+,W/N,,,W/GR+')
   @ 7, 33 say dispreceiver( mreceiver ) color 'gr+/b'
   center ( 24, 'w+/n','                   ' )
return .f.
**********************************************************
static function chkacctno ( macctno,mclntcode,macctnoful )
**********************************************************
   local mDBF := select(), mNTX := indexord(), mRECNO:= recno()
   local mRETVAL := .t.
   if ( empty( mACCTNO ), mRETVAL := .f., nil )
   macctno := right( '00000'+ alltrim(macctno), 5 )
   if mretval
      if !Acctmast->( dbseek ( mACCTNO ) )
        error ( 'No such Acct N§!' )
        mretval := .f.
      else
        if Inv_head -> ( dbseek( Acctmast->ACCTNO ) )
           error( 'Duplicate Acct N§!' ); mRETVAL := .f.
        else
           macctnoful:= Acctmast->ACCTNO
           mclntcode := Acctmast->CLNTCODE
           @ 5, 36 say dispclntname( mclntcode, 40 ) color 'gr+/b'
        endif
      endif
   endif
   select ( mDBF ); set order to (mNTX ) ; go mRECNO
return mretval
**********************************************
*   Description    displays CLIENT NAME/CODES
*   Parameters     CLIENT CODE
*   Return Value   .f.
static function chkCLNTCODE( mCLNTCODE )
****************************************
   center ( 24,'w+/n','® Select Client Name ¯' )
   lb_lkup('Client',1,2,@mCLNTCODE, 3 , 1, 11, 12, 21, 75, 'W/GR+,W/N,,,W/GR+')
   @ 5, 36 say dispCLNTNAME( mCLNTCODE, 40 ) color 'gr+/b'
   center ( 24,'w+/n','                      ' )
return .f.
/*
***************************************
*   Description   displays client name
*   Parameters    client code
*   Return value  client name
static function dispCLNTNAME( mCLNTCODE )
*****************************************
return eval ( {|x,y,z| x := savedbf (x)                  ,;
                       z := Client->( indexord() )       ,;
                       Client->( dbsetorder(1) )         ,;
                       Client->( dbseek ( mCLNTCODE ) )  ,;
                       y := left( Client->FULLNAME, 40 ) ,;
                       Client->( dbsetorder(z) )         ,;
                       restdbf ( x )                     ,;
                       y                                  ;
              })
*/
*************************************************************************
*   Description   seeks record from Inv_head.DBF using ACCTNO as the key
*   Parameters    type >> 'A' = Add else Edit
*   Return Value  nil
static function search_head( macctno )
*************************************************************************
   local mRECNO := Inv_head->( recno() ) , mCURSOR := setcursor ( setcursor() ),st:=select()
   local mSCR   := savescreen ( ,,, ),mClntcode:=spac(7),mu:={},mlog:={},bf:=Client->(recno())
   local l,c,mposition:=0,gf := Client->(indexord()),ppy := Inv_head->(indexord())

   memvar getlist
   dbselectarea('Client')
   Client->(dbsetorder(2))
   center( 24, 'w+/n' , '® Search Record ¯' )
   setcolor( 'gr+/b, w+/g,,, gr+/b' ) 
   *@ 05, 26 get mclntcode pict '@R 99-99999' when eval( {|| mClntcode:=flook(.t.,'Client',Client->Fullname,'CLIENT MASTER',1,3,4,1,.f. ), .F. } )
   @ 05, 26 get mclntcode pict '@R 99-99999' when eval( {|| mClntcode:=flook_online(.t.,'Client',Client->Fullname,'CLIENT MASTER',1,3,4,,1,.f. ), .F. } )
   setcursor( 0 )
   read
   setcursor( 0 )
   if !empty(mclntcode) .and. lastkey() != K_ESC
      Inv_head-> ( Dbsetorder( 2 ) )
      Client-> ( dbsetorder( 1 ) )
      if Inv_head->(dbseek(mclntcode))
         mu := { '  Client N§  ' + tran( mclntcode, '@R 99-99999' )    ,;
                 '  Client Name  ' + left( dispclntname( mclntcode, 40 ),15 ),;
                    repl( 'Ä', 29 ), ' Acct. N§   Date Received', repl( 'Ä',29 ) }
         Inv_head->( dbeval({|| aadd( mu,' '+Substr(Inv_head->Acctno,-5,5)+space(7)+dtoc(Inv_head->Recdate))},,;
                            {|| Inv_head->CLNTCODE==mclntcode .and. !Inv_head->(eof()) }) )
         if len(mu) > 1
            mlog := aclone( mu )
            aeval( mlog, { | l, c | mlog[ c ] := if( c <= 5, .f., .t. ), c } )
            mposition := val( gen_achoice( mu, 6, 'Search', mlog ) )
         endif
         if !empty(mposition) .and. lastkey() <> K_ESC
            Inv_head->(dbsetorder(3))
            Inv_head->(dbseek(substr(mu[mposition],2,5)))
            mrecno := Inv_head->(recno())
            bf:=Client->(recno())
         endif
      else
         error('Record not found in Invoice File.')
      endif
   endif
   restscreen( ,,,, mSCR )
   Client->(dbgoto( bf ))
   Client->(dbsetorder(gf))
   Inv_head->(dbsetorder(ppy))
   Inv_head->( dbgoto ( mRECNO ) ) ; setcursor ( mCURSOR )
   dbselectarea(st)
return nil
***************************
static function delete_head
***************************
   local mSCR , mDBF := select(), mNTX := indexord(), mRECNO := recno()
   select Inv_head
   if netlock ( 'R', 0 )
      dbdelete()
      select Inv_dtls
      if dbseek ( Inv_head->ACCTNO )
         dbeval ( {|| NETLOCK( 'R', 0 )                               ,;
                      dbdelete()                                      ,;
                      dbunlock()                                       ;
                   }                                                  ,,;
                  { ||  Inv_dtls->ACCTNO == Inv_head->ACCTNO .and. ;
                       !Inv_dtls->( eof() )                            ;
                  }                                               ,,.t.)
      endif
      dbunlock()
      select Inv_head
      skip
      if eof()
         skip-1
      endif
      mRECNO := recno()
   endif
   dbunlock()
   select( mDBF ) ; set order to ( mNTX ) ; go ( mRECNO )
return nil
*******************************************
static function disphead( mCOLOR )
*******************************************
   eval({|| dispbegin(),;
         devpos ( 04, 09    ) , devout ( '    Account N§  '      , 'w/b' )  ,;
         devpos ( 04, col() ) , devoutpict( Inv_head->ACCTNO         , '@R 9999-99999-99999',mCOLOR)  ,;
         devpos ( 05, 09    ) , devout ( '     Client N§  '      , 'w/b' )  ,;
         devpos ( 05, col() ) , devoutpict( Inv_head->CLNTCODE       , '@R 99-99999',mCOLOR ),;
         devpos ( 05, 36    ) , devout ( dispCLNTNAME( Inv_head->BRCODE+Inv_head->CLNTCODE, 40 ), mCOLOR)  ,;
         devpos ( 06, 09 )    , devout ( ' Date Received  '      , 'w/b' )  ,;
         devpos ( 06, col() ) , devout ( dtoc( Inv_head->RECDATE) , mCOLOR)  ,;
         devpos ( 07, 09 )    , devout ( '   Received by  '      , 'w/b' )  ,;
         devpos ( 07, col() ) , devout ( Inv_head->RECEIVER + '  ', mCOLOR),;
         devpos ( 07, col() ) , devout ( dispRECEIVER( Inv_head->RECEIVER ), mCOLOR),;
         dispend();
      })
return nil
/*
*******************************************
static function dispreceiver( mreceiver )
*******************************************
return eval ({|x,y| x := savedbf (x),Personel->( dbseek ( mRECEIVER ) ) ,;
                    y := Personel ->FULLNAME,restdbf (x),y})
*/
////
static function case2007( cb, mkey )
local mcolor := setcolor(), mscreen := savescreen( ,,, ), mreturn := .t.
memvar AX_LEVEL, G_USER_ID

do case            
   case mkey == K_INS
        if chkpass('A',AX_LEVEL,G_USER_ID)
           update_detail( 'A' )
           tb_refresh( cb, 'a' )
        endif    
    case mkey == K_F2
         if chkpass('E',AX_LEVEL,G_USER_ID)
            if( Inv_dtls->acctno != Inv_head->acctno, eval({|| ERROR('Nothing to Edit!'), dbseek( Inv_head->acctno )}),update_detail('E'))
            tb_refresh( cb, 'c' )            
         endif   
    case mkey == K_DEL
         if chkpass('D',AX_LEVEL,G_USER_ID)
            if Inv_dtls->acctno != Inv_head->acctno
               eval({|| error('Nothing to Delete!'),dbseek( Inv_head->acctno )})
            else
               delete_detail( Inv_head->acctno )
               tb_refresh( cb, 'a' )               
            endif
         endif   
    case mkey == K_F4
         if chkpass('S',AX_LEVEL,G_USER_ID)
            if Inv_dtls->acctno != Inv_head->acctno
               eval({|| ERROR('Nothing to Search!'),dbseek( Inv_head->acctno )})
            else
               search_detail( Inv_head->acctno, cb:rowpos + 11 )
               tb_refresh( cb, 'a' )               
            endif
         endif   
    otherwise
         mreturn := !mreturn     
endcase
setcolor( mcolor )
restscreen( ,,,, mscreen )
return( mreturn )         
***********************************************
*   Description   input module for Inv_DET.dbf
*   Parameters    type >> 'A' = Add else Edit
*   Return Value 
*
static function update_detail( mWHAT )
***********************************************
   local mscr    := savescreen (,,,)
   local macctno := Inv_head->ACCTNO
   local minvdate,minvamt,minvno,mstatus
   local mrecno := recno()
   local misreturned  := .f.
   local mstatchoices := { '1 = Active','2 = Paid  ' }
   memvar getlist
   if ( upper( mwhat ) == 'A', Inv_dtls->(dbgoto(lastrec()+1)) , mwhat := 'R')
   minvdate := Inv_dtls -> INVDATE
   minvamt  := Inv_dtls -> INVAMT
   minvno   := Inv_dtls -> INVNO
   mstatus  := Inv_dtls -> STATUS
   if mwhat == 'A'
      Inv_dtls -> ( dbgoto ( lastrec()+1 ) )
      center ( 24, 'w+/n', '® Add Details ¯' )
   else
      mwhat := 'R'
      center ( 24, 'w+/n', '® Edit Details ¯' )
   endif
   fshadow( 11, 39, 16, 70, 2, 'n/w' )
   setcolor( 'bg+/w, w+/n,,, gr+/w' ) 
   if !empty ( mstatus )
      @ 15, 57 say subs( mstatchoices [ val( mstatus ) ], 5 ) color 'gr+/w'
   endif
   do while .t.
       @ 12, 40 say 'Invoice Date ' gget minvdate   picture '@D' when mwhat == 'A' valid chkdate ( macctno, minvdate )
       @ 13, 40 say ' Invoice Amt ' gget minvamt    calculator  picture '999,999,999.99' valid minvamt > 0
       @ 14, 40 say '  Invoice N§ ' gget minvno     picture  '@X'
       @ 15, 40 say '      Status ' gget mstatus    picture '9' when selchkstat ( mstatchoices, @mstatus, 15 )
       setcursor( 3 )
       read
       setcursor( 0 )
       if lastkey() == K_ESC
          if esckey()
             exit
          else
             loop
          endif
       endif
       if Inv_dtls->( netlock( mwhat, 0 ) )
          Inv_dtls -> ACCTNO  := macctno
          Inv_dtls -> INVDATE := minvdate
          Inv_dtls -> INVAMT  := minvamt
          Inv_dtls -> INVNO   := minvno
          Inv_dtls -> STATUS  := mstatus
          Inv_dtls-> ( dbunlock() )
          Inv_dtls-> ( dbcommit() )
          mrecno := recno()
          exit
       endif
   enddo
   go mrecno
return nil
*********************************************************
static function selchkstat(mSTATCHOICES, mSTATTYPE, mROW)
*********************************************************
   mstattype := gen_achoice( mstatchoices, val( mstattype ), 'Status', 16, 56, 19, 77, 'W/GR+,W/N,,,W/GR+' )
   @ mROW, 57 say dispstatus( mstattype ) color 'gr+/w'
return .f.
*********************************************
static function dispstatus ( mstattype )
*********************************************
   local mlist := space(07) + 'Active '+'Paid   '
return substr ( mlist,7*val( mstattype )+1,7 )
*********************************************
static function chkDATE ( mACCTNO, minvDATE )
*********************************************
   local mretval := .t. , mdbf := savedbf(mdbf)
   if empty (minvdate)
      return .f.
   endif
   if Inv_dtls->( dbseek(macctno+dtos(minvdate)) )
      error ( 'Duplicate Invoice Date!' ) ; mRETVAL := .f.
   endif
   restdbf (mdbf)
return mretval
/*
*************************************************
static function chkDEPDATE ( mCHKDATE, mDEPDATE )
*************************************************
    local mRETVAL := .t.
    if mCHKDATE > mDEPDATE
       ERROR('Check Date must be "<" Deposit Date!'); mRETVAL := .f.
    endif
return mRETVAL
*/
***************************************************************************
*   Description   seeks record from Pld_dtls.DBF using ACCTNO as the key
*   Parameters    ACCTNO
*   Return Value  nil
static function search_detail( mACCTNO, mROW )
************************************************************
   local mRECNO   := recno(), mSCR := savescreen ( ,,, ), mLCOLOR := setcolor()
   local mCHKDATE := ctod ('//')
   memvar getlist

   center ( 24, 'w+/n', '® Search Record ¯' )
   fshadow( 11, 14, 13, 40, 2, 'n/w' )
   setcolor( 'bg+/w, w+/n,,, gr+/w' )    
   @ 12, 15 say 'Invoice Date ' get mCHKDATE pict '@D'
   setcursor ( 3 )
   read
   setcursor ( 0 )
   if dbseek ( mACCTNO+dtos( mCHKDATE ) )
      mRECNO := recno()
   else
      if( lastkey()!=K_ESC .and. !empty( mCHKDATE ), ERROR( 'No such Invoice Date!' ), nil )
   endif
   dbgoto ( mRECNO ); restscreen( ,,,, mSCR ); setcursor ( 0 ); setcolor( mLCOLOR )
return nil
/*
***************************************
static function dispchktype( mCHKTYPE )
***************************************
   local mLIST := space (12 ) +'Metro Manila'+'Regional    '+'Out-Of-Town '
return left( substr ( mLIST, val ( mCHKTYPE ) * 12 + 1, 12 ), 8 )
*/
**********************************************************
*  Description   deletes ACCOUNT NUMBER from Inv_dtls.dbf
*  Parameters    ACCOUNT NUMBER
*  Return Value  nil
static function delete_detail( mACCTNO )
******************************************************
   if CONFIRM('Delete Invoice Date ' + tran( Inv_dtls->invdate, '@D' )+'?')
      if NETLOCK( 'R', 0 )
         Inv_dtls->( dbdelete() )
         Inv_dtls->( dbskip ( +1 ) )
         if( Inv_dtls->( eof()  ) .or. Inv_dtls->ACCTNO != mACCTNO, Inv_dtls->( dbseek ( mACCTNO ) ), nil )
      endif
      Inv_dtls->( dbunlock() )
   endif
return nil
*************************************************
*   Description   opens all needed files
*   Parameters    none
*   Return Value  .t. = successful opening
*                  .f. = error in opening files
static function amsm2007open()
******************************
   local mretval := .f.
   if netuse('Inv_head',.f.,5)
      set index to Inv_head,Inv_clnt,Inv_sub1
      if netuse('Inv_dtls',.f.,5)
         set index to Inv_dtls
         if netuse('&g_GRF_PATH'+'\Personel',.f.,5)
            set index to &g_GRF_PATH\Initials
            if netuse('&g_CIS_PATH'+'\Client.dbf',.f.,5)
               set index to &g_CIS_PATH\Cliecd, &g_CIS_PATH\Clienm
               if netuse('Acctmast',.f.,5)
                  set index to Acctsub2
                  mretval := .t.
               endif
            endif
         endif
      endif
   endif
return mretval
*
*                 End of the program ( amsm2007.prg )
*
