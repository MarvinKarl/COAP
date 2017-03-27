/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   PROGRAM ID.........:  AMST100D.prg                                         ³
³   Description........:  account execution - collateral information           ³
³   Author.............:  Ariel B. Bulan                                       ³
³   Date...............:  12:22pm 15-Nov-1994                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                         U P D A T E S                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        Who        ³     When      ³               Why                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Janet L. Bautista ³  26-Apr-1996  ³ additional insurance information         ³
³ renan evangelsita ³  10-Jun-1996  ³ Add F3<other Collateral>                 ³
³                   ³               ³ Remove asset code                        ³
³   abb             ³  07.28.2004   ³  insurance co. validation                ³
³                   ³               ³  -- accredited insurance co.             ³
³                   ³               ³  -- only                                 ³
³                   ³               ³                                          ³
³   ABB             ³ 10.18.2004    ³  FOR ONLINE USE                          ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include "Colf.ch"
#include "Inkey.ch"
#define sound_good  tone( 60, .5 )
******************************************************************
function collatral_information( macctno, mis_add_one,misentered  )
******************************************************************
   local  mscr := savescreen( ,,, ), i, mdbf := savedbf(),w_rec:=.f.
   local  mcolor := setcolor(), mrow := 8, mpos := 1, mlastrec := 0
   local  mkey, mcontinue := .t., mkey_ := { '<Ins>\-Add ', '<F2>\Edit ','<F3>\Others ', '<Del>\ ', '<Esc>\' }
   memvar ax_level,g_user_id
   priva  mcoltype , mcolmodel, masetcode, mplateno , mserialno, mmotorno  ,;
          mcrnumber, mcrorno  , mcrexpiry, mlocation, mtctno   , mretrno  , mretrdate,;
          mappdate , mappvalue, mapreyser, mappfreq , minsured , minsby   , minsco   ,;
          minsprem , minsdate , minsexpry, minscover, minspolcy, minsor   , mremarks,;
          mamtins  , munitgrp , cBRCODE

   if !chkpass( procname(),ax_level,g_user_id )
      return nil
   endif
   scr_make( mkey_, 6, 1, 23, 78,, .f., 'n/gr' )
   devpos( 6, 2 ); devout( 'Collateral Information', 'w+/gr' )
   dbselectarea ( 'Ctrlinfo' )
///
///   if Ctrlinfo->( dbseek( Acctdaly->acctno ) )
///

   if Ctrlinfo->( dbseek( mACCTNO ))  && RED sbrcode+Acctdaly->acctno ) )
**   if Ctrlinfo->( dbseek( Acctdaly->brcode+Acctdaly->ACCTNO ))  && RED sbrcode+Acctdaly->acctno ) )
      waiton ( 'wait a second, please!',, 'n/w' )
      Ctrlinfo->( dbeval( { || mlastrec++ },,;
                          { || Ctrlinfo->acctno == Acctdaly->acctno .and.;
                               Ctrlinfo->brcode == sbrcode ;
                          } ;
                        ) ;
                )
      waitoff()
   endif

   Ctrlinfo->( dbseek( Acctdaly->brcode+Acctdaly->ACCTNO ) )

***   Ctrlinfo->( dbseek( mACCTNO )) && RED sbrcode+Acctdaly->ACCTNO ) )

   if ( mlastrec == 0,;
         eval( { || if( !mis_add_one, error( "No Record Found!" ), nil ),;
                    __keyboard( chr( K_INS ) ) ;
               } ), nil )

   do while mcontinue
      if( Ctrlinfo->(eof()),w_rec:=.f.,nil )
      disp_record( )
      //
      // dispstatus( @mrow, mpos, mlastrec )
      //
      mkey := inkey( 0 )
      do case
         case mkey == K_UP

              if chkpass( 'S', ax_level, g_user_id )
                 Ctrlinfo->( dbskip( -1 ) )
                 mpos--
                 if Ctrlinfo->( bof() ) .or. CTRLINFO->BRCODE+Ctrlinfo->acctno != ACCTDALY->BRCODE+Acctdaly->acctno
                    mpos++
                    sound_good
                    waiton( 'First Record', .f., 'n/w', 5 )
                    inkey( .1 )
                    waitoff()
                    Ctrlinfo->(dbseek(Acctdaly->brcode+Acctdaly->acctno))
                 endif

              endif

         case mkey == K_DOWN
              if chkpass( 'S', ax_level, g_user_id )
                if Ctrlinfo->ACCTNO == Acctdaly->ACCTNO       .and. ;
                  !Ctrlinfo->(bof()) .and. !Ctrlinfo->(eof()) .and. ;
                   Ctrlinfo->brcode == Acctdaly->brcode
                   w_rec:= .t.
                   Ctrlinfo->(dbskip(+1))
                endif
                 mpos++

                 if Ctrlinfo->(eof()) .or. ;
                    Ctrlinfo->ACCTNO!=Acctdaly->ACCTNO .or. ;
                    Ctrlinfo->brcode != Acctdaly->brcode
                    mpos--
                    sound_good
                    waiton('Last Record', .f., 'n/w', 5 )
                    Ctrlinfo->(dbskip(-1))
                    inkey( .1 )
                    waitoff()
                 endif

                if Ctrlinfo->ACCTNO <> Acctdaly->acctno .and. ;
                   w_rec .and. ;
                   Ctrlinfo->brcode != Acctdaly->brcode
                   Ctrlinfo->(dbskip(-1))
                endif

                if Ctrlinfo->ACCTNO <> Acctdaly->ACCTNO .or. ;
                   Ctrlinfo->brcode != Acctdaly->brcode
                   Ctrlinfo->(dbseek(ACCTDALY->BRCODE+Acctdaly->Acctno,.f.) ) && RED sbrcode
                endif

              endif
         case mkey == K_INS
              if chkpass( 'A', ax_level, g_user_id )
                 if t100d_update( macctno, 'A', mis_add_one, @misentered )
                    mlastrec++
                    **up_pos ( @mpos )
                    if ( mis_add_one, mcontinue:=.f., nil )
                 endif
              endif
         case mkey == K_F2
              if chkpass( 'E', ax_level, g_user_id )
                 if ( Ctrlinfo->( eof() ) .or. ;
                      CTRLINFO->BRCODE+Ctrlinfo->acctno != ACCTDALY->BRCODE+Acctdaly->acctno,;
                      error( 'Nothing to Edit!' ),;
                      t100d_update( ACCTDALY->BRCODE+Acctdaly->acctno, 'e', mis_add_one, @misentered ) ;
                    )
              endif
         case mkey == K_DEL
              if chkpass( 'D', ax_level, g_user_id )
                 if( Ctrlinfo->( eof() ), error( 'Nothing to Delete!' ), amsmdelete( 'Delete this Collateral Information', @mpos, @mlastrec ) )
                 update_sequence()
              endif
         case mkey == K_ESC
              if exitmod()
                 mcontinue := .f.
              endif
         case mkey == K_F3
              if Acctdaly->(!eof()) .and. acctdaly->(!bof()) .and. !empty( Acctdaly->Acctno )
                 othercoltrl( ACCTDALY->BRCODE+Acctdaly->Acctno)
              endif
      endcase

   enddo
   setcolor  ( mcolor  )
   restscreen( ,,,,mscr)
   restdbf   ( mdbf   )
return nil
*****************************
static function disp_record()
*****************************
local mrow := 7 , mleft := 2 , mrayt := 35
local unit_:={ ' SafeTnet',' LTO     ',' Others  ' }

    dispbegin()
    @ mrow   , 07    say 'Vehicle/Chattel Type  ' color 'w/gr'
    @ mrow   , col() say Ctrlinfo->COLTYPE  color 'w+/gr' pict '@X'
    @ row()+1, mleft say '          Model  ' color 'w/gr'
    @ row()  , col() say Ctrlinfo->COLMODEL color 'w+/gr' pict '@X'
    @ row()  , mrayt say '     Appraisal Date  ' color 'w/gr'
    @ row()  , col() say Ctrlinfo->APPDATE  color 'w+/gr' pict '@D'
    @ row()+1, mleft say "     Asset Code  " color 'w/gr'
    @ row()  , col() say Ctrlinfo->ASETCODE color 'w+/gr' pict '@X'
    @ row()  , col()+1 say left( disp_asetname ( Ctrlinfo->ASETCODE ), 09 ) color 'w+/gr'
    @ row()+1, mleft say '     Unit Group  ' color 'w/gr'
    @ row()  , col() say Ctrlinfo->Unitgrp  color 'w+/gr'
    @ row()  , col() say if( Ctrlinfo->Unitgrp <> ' ',unit_[ val(Ctrlinfo->Unitgrp ) ],'             ') color 'w+/gr'
    @ row(), mrayt say '    Appraisal Value  ' color 'w/gr'
    @ row()  , col()   say Ctrlinfo->APPVALUE color 'w+/gr' pict '999,999,999.99'
    @ row()+1, mleft say '       Plate N§  ' color 'w/gr'
    @ row()  , col() say Ctrlinfo->PLATENO  color 'w+/gr' pict '@X'
    @ row()  , mrayt say '          Appraiser  ' color 'w/gr'
    @ row()  , col() say Ctrlinfo->APREYSER color 'w+/gr' pict '@X'
    @ row()+1, mleft say '      Serial N§  ' color 'w/gr'
    @ row()  , col() say substr(Ctrlinfo->SERIALNO,1,14) color 'w+/gr' pict '@X'
    @ row()  , mrayt say 'Appraisal Frequency  ' color 'w/gr'
    @ row()  , col() say Ctrlinfo->APPFREQ  color 'w+/gr' pict '@X'
    @ row()  , col() say ' '+ dispappfreq( Ctrlinfo->APPFREQ ) color 'w+/gr'
    //
    @ row()+1, mleft say '       Motor N§  ' color 'w/gr'
    @ row()  , col() say Ctrlinfo->MOTORNO  color 'w+/gr' pict '@X'
    @ row()  , mrayt say '            Insured  ' color 'w/gr'
    @ row()  , col() say dispinsured(Ctrlinfo->INSURED) color 'w+/gr'

    //
    @ row()+1, mleft say '          CR N§  ' color 'w/gr'
    @ row()  , col() say Ctrlinfo->CRNUMBER color 'w+/gr' pict '@X'
    @ row()  , mrayt say '       Insured thru  ' color 'w/gr'
    @ row()  , col() say left( Ctrlinfo->INSBY,1 ) + ' ' + dispinsthru( Ctrlinfo->INSBY ) color 'w+/gr' pict '@X'
    //
    @ row()+1, mleft say '          OR N§  ' color 'w/gr'
    @ row()  , col() say Ctrlinfo->CRORNO   color 'w+/gr' pict '@X'
    @ row()  , mrayt say '      Insurance Co.  ' color 'w/gr'
    @ row()  , col() say Ctrlinfo->INSCO    color 'w+/gr' pict '@X'
    @ row()  , col() say ' '+ left( dispinsname(Ctrlinfo->INSCO),16 ) color 'w+/gr'
    //
    @ row()+1, mrayt say '  Insurance Premium  ' color 'w/gr'
    @ row()  , col() say Ctrlinfo->INSPREM  color 'w+/gr' pict '999,999,999.99'
    //
    @ row()+1, mleft say "   Reg'n Expiry  " color 'w/gr'
    @ row()  , col() say Ctrlinfo->CREXPIRY color 'w+/gr' pict '@D'
    @ row()  , mrayt say '     Amount Insured  ' color 'w/gr'
    @ row()  , col() say Ctrlinfo->Amtins   color 'w+/gr' pict '999,999,999.99'
    //
    @ row()+1, mleft say ' Prop. Location  ' color 'w/gr'
    @ row()  , col() say Ctrlinfo->LOCATION color 'w+/gr' pict '@X'
    @ row()  , mrayt say '       Date Insured  ' color 'w/gr'
    @ row()  , col() say Ctrlinfo->INSDATE  color 'w+/gr' pict '@D'
    //
    @ row()+1, mleft say '         TCT N§  ' color 'w/gr'
    @ row()  , col() say Ctrlinfo->TCTNO    color 'w+/gr' pict '@X'
    @ row()  , mrayt say 'Insurance Exp. Date  ' color 'w/gr'
    @ row()  , col() say Ctrlinfo->INSEXPRY color 'w+/gr' pict '@D'
    //
    @ row()+1, mleft say ' Latest RETR N§  ' color 'w/gr'
    @ row()  , col() say Ctrlinfo->RETRNO   color 'w+/gr' pict '@X'
    @ row()  , mrayt say '   Type of Coverage  ' color 'w/gr'
    @ row()  , col() say Ctrlinfo->INSCOVER color 'w+/gr' pict '@X'
    @ row()  , col() say ' '+ dispcover( Ctrlinfo->INSCOVER ) color 'w+/gr'
    //
    @ row()+1, mleft say 'Latest RETR Dt.  ' color 'w/gr'
    @ row()  , col() say Ctrlinfo->RETRDATE color 'w+/gr' pict '@D'
    @ row()  , mrayt say '          Policy N§  ' color 'w/gr'
    @ row()  , col() say Ctrlinfo->INSPOLCY color 'w+/gr' pict '@X'
    //
    @ row()+1, mleft say 'Remarks   ' color 'w/gr'
    @ row()  , col() say Ctrlinfo->REMARKS color 'w+/gr' pict '@X'
    @ row()  , mrayt say '          Ins OR N§  ' color 'w/gr'
    @ row()  , col() say Ctrlinfo->INSOR  color 'w+/gr' pict '@X'
    dispend()
**************************************
function dispcover( minscover,mrow,mcol )
**************************************
if Coverage->(dbseek(minscover,.f.))
   if !empty(mrow) .and. !empty(mcol)
      @ mrow,mcol + 3 say UPPER(substr(Coverage->coverdesc,1,15)) color 'w+/gr'
      return .t.
   else
      return UPPER(substr(Coverage->coverdesc,1,15))
   endif
else
   return space(15)
endif
return ' '
***************************************
function dispappfreq( mappfreq )
***************************************
   local mlist := space(11) + 'Quarterly  Semi-AnnualAnnual     '
return upper( ( substr(mlist,val(mappfreq)*11+1,11) ) )
/*
***************************************
function dispinsured( minsured )
***************************************
return upper( if ( minsured,'Yes   ','Waived' ) )
*/
************************************************************************
*
static function t100d_update ( macctno, mwhat, mis_add_one, misentered )
************************************************************************
   local mcolor          := setcolor (), mcursor := setcursor(), mscreen := savescreen( ,,, )
   local mretval         := .f., mcontinue := .t. ,mrecno := Ctrlinfo->( recno() )
   local mleft           := 20 , mrayt := 57, mrow := 7
   local minsbychoices   := { '1 = Client','2 = Colf  ','3 = Dealer' }   
   local minschoices     := { '1 = Yes   ', '2 = Waived' }, minstring
   local mappfreqchoices := { '1 = Quarterly  ','2 = Semi-annual','3 = Annual     '}
   local munitchoices    := { '1 = SafeTNET','2 = LTO     ','3 = Others  ' }
   local getlist         := {}
   memvar mcoltype , mcolmodel, masetcode, mplateno , mserialno, mmotorno  ,;
          mcrnumber, mcrorno  , mcrexpiry, mlocation, mtctno   , mretrno  , mretrdate,;
          mappdate , mappvalue, mapreyser, mappfreq , minsured , minsby   , minsco   ,;
          minsprem , minsdate , minsexpry, minscover, minspolcy, minsor, mamtins,;
          munitgrp , mremarks, cBRCODE

   if upper( mwhat ) == chr(65)
      Ctrlinfo->( dbgoto( lastrec() + 1 ) )
      center( 24, 'w+/n', padc( '® Add Record ¯', 80 ) )
   else
      mwhat := chr(82)
      center( 24, 'w+/n', padc( '® Edit Record ¯', 80 ) )      
   endif   
   assign_ctrlinfo ()
   disp_record     ()
   setcolor        ( 'gr+/gr, w+/n,,, gr+/gr' )

   //@ 10, 23 say left( disp_asetname ( masetcode ),13 )
   @ 13, 57 say dispinsured ( minsured )
   do while mcontinue
      minstring := upper( if ( minsured,'Yes   ','Waived' ) )
      @ mrow   , 30    get mcoltype  pict '@X'
      @ row()+1, mleft get mcolmodel pict '@X'
      @ row()+1, mleft get masetcode pict '@X' when chkasetcode ( @masetcode, 9, mleft )
      @ row()+1, mleft get munitgrp  pict '9'  when get_unitgrp( munitchoices,@munitgrp, 10)
      @ row()+1, mleft get mplateno  pict '@X'
      @ row()+1, mleft get mserialno pict '@XS14'
      @ row()+1, mleft get mmotorno  pict '@X'
      @ row()+1, mleft get mcrnumber pict '@X'
      @ row()+1, mleft get mcrorno   pict '@X'
      @ row()+2, mleft get mcrexpiry pict '@X'
      @ row()+1, mleft get mlocation pict '@XS15'
      @ row()+1, mleft get mtctno    pict '@X'
      @ row()+1, mleft get mretrno   pict '@X'
      @ row()+1, mleft get mretrdate pict '@D'
      @ row()+1, mleft-8 get mremarks pict '@XS30'
      @ mrow+1 , mrayt get mappdate  pict '@D'
      @ row()+2, mrayt get mappvalue pict '999,999,999.99' valid (mappvalue>=0)
      @ row()+1, mrayt get mapreyser pict '@X'
      @ row()+1, mrayt get mappfreq  pict '@X' when get_appfreq( mappfreqchoices,@mappfreq,12 )
      @ row()+1, mrayt get minstring pict '@X' when get_insured( minschoices,@minsured,@minstring, 13 )
      @ row()+1, mrayt get minsby    pict '@X' when upper(alltrim(minstring)) <> 'WAIVED' .and. get_insby  ( minsbychoices,@minsby,14 )
      @ row()+1, mrayt get minsco    pict '@X' when upper(alltrim(minstring)) <> 'WAIVED' .and. chkinscode( @minsco, cBRCODE ) && RED 121404 ADDED cBRCODE PARAMETER
      @ row()+1, mrayt get minsprem  pict '999,999,999.99' when upper(alltrim(minstring)) <> 'WAIVED'  valid !empty(minsprem)
      @ row()+1, mrayt get mamtins   pict '999,999,999.99' when upper(alltrim(minstring)) <> 'WAIVED'  valid !empty(mamtins)
      @ row()+1, mrayt get minsdate  pict '@D' when upper(alltrim(minstring)) <> 'WAIVED' valid eval( {|| minsexpry:=dispnextyr(minsdate),.t.} )
      @ row()+1, mrayt get minsexpry pict '@D' when upper(alltrim(minstring)) <> 'WAIVED'
      @ row()+1, mrayt get minscover ;
                       pict '@X'     ;
                       when upper(alltrim(minstring)) <> 'WAIVED' .AND. ;
                             eval({ || minscover:= flook_online(.t.,'Coverage',minscover,'Coverage Code',,,,1,,,,,g_ams_path),;      &&flook(.t.,'Coverage',minscover,'Coverage Code',,,,1,,,,,g_ams_path),;
                            if(lastkey() <> K_ESC,dispcover(minscover,20,mrayt),nil),.f. } )
                            //valid lastkey() != K_ESC .and. eval({ || dispcover(minscover,row(),mrayt), .t. })
      @ row()+1, mrayt get minspolcy pict '@X' when lastkey() <> K_ESC .and. upper(alltrim(minstring)) <> 'WAIVED'
      @ row()+1, mrayt get minsor    pict '@X' when lastkey() <> K_ESC .and. upper(alltrim(minstring)) <> 'WAIVED'
      setcursor( 3 )
      read
      setcursor( 0 )

      if lastkey() == K_ESC
         if esckey()
            mcontinue := .f.; mretval := .f. ; misentered := .f.
         endif
         loop
      endif
      if !mis_add_one
         if confirm('Are all entries correct?')
            if upper(alltrim(minstring)) == 'WAIVED'
               minsby    := spac( len(minsby) )
               minsco    := spac( len(minsco) )
               minsprem  := 0
               mamtins   := 0
               minsdate  := ctod('  /  /  ')
               minsexpry := ctod('  /  /  ')
               minscover := spac( len(minscover) )
               minspolcy := spac( len(minspolcy) )
               minsor    := spac( len(minsor) )
            endif
            save_ctrlinfo( mwhat , .t.        )
            mrecno := Ctrlinfo->(recno())
            mretval := .t. ; misentered := .t.
         else
            loop
         endif
      else
         mretval := .t.; misentered := .t.
      endif
      mcontinue := .f.
  enddo
  dbgoto    ( mrecno  )
  setcolor  ( mcolor  )
  restscreen( ,,,, mscreen )
return( mretval )  
**************************************
static function assign_ctrlinfo()
**************************************
memvar mcoltype , mcolmodel, masetcode, mplateno , mserialno, mmotorno,;
       mcrnumber, mcrorno  , mcrexpiry, mlocation, mtctno   , mretrno , mretrdate,;
       mappdate , mappvalue, mapreyser, mappfreq , minsured , minsby  , minsco   ,;
       minsprem , minsdate , minsexpry, minscover, minspolcy, minsor  , mamtins,  ;
       munitgrp , mremarks, cBRCODE

eval( { || mcoltype  := Ctrlinfo->COLTYPE , mcolmodel := Ctrlinfo->COLMODEL,;
           masetcode := Ctrlinfo->ASETCODE, mplateno  := Ctrlinfo->PLATENO ,;
           mserialno := Ctrlinfo->SERIALNO, mmotorno  := Ctrlinfo->MOTORNO ,;
           mcrnumber := Ctrlinfo->CRNUMBER, mcrorno   := Ctrlinfo->CRORNO  ,;
           mcrexpiry := Ctrlinfo->CREXPIRY, mlocation := Ctrlinfo->LOCATION,;
           mtctno    := Ctrlinfo->TCTNO   , mretrno   := Ctrlinfo->RETRNO  ,;
           mretrdate := Ctrlinfo->RETRDATE, mappdate  := Ctrlinfo->APPDATE ,;
           mappvalue := Ctrlinfo->APPVALUE, mapreyser := Ctrlinfo->APREYSER,;
           mappfreq  := Ctrlinfo->APPFREQ , minsured  := Ctrlinfo->INSURED ,;
           minsby    := Ctrlinfo->INSBY   , minsco    := Ctrlinfo->INSCO   ,;
           minsprem  := Ctrlinfo->INSPREM , minsdate  := Ctrlinfo->INSDATE ,;
           minsexpry := Ctrlinfo->INSEXPRY, minscover := Ctrlinfo->INSCOVER,;
           minspolcy := Ctrlinfo->INSPOLCY, minsor    := Ctrlinfo->INSOR,   ;
           mamtins   := Ctrlinfo->AMTINS  , munitgrp  := Ctrlinfo->Unitgrp, ;
           mremarks  := Ctrlinfo->Remarks , cBRCODE   := CTRLINFO->BRCODE } )
return nil
*********************************************
function save_ctrlinfo( mwhat, misentered )
*********************************************
memvar mcoltype , mcolmodel, masetcode, mplateno , mserialno, mmotorno,;
       mcrnumber, mcrorno  , mcrexpiry, mlocation, mtctno   , mretrno , mretrdate,;
       mappdate , mappvalue, mapreyser, mappfreq , minsured , minsby  , minsco   ,;
       minsprem , minsdate , minsexpry, minscover, minspolcy, minsor  , mamtins  ,;
       munitgrp , cBRCODE

if misentered
   if Ctrlinfo->( netlock( mwhat, 0 ) )
      eval( { || Ctrlinfo->ACCTNO   := Acctdaly->ACCTNO,;
                 Ctrlinfo->COLTYPE  := mcoltype , Ctrlinfo->COLMODEL := mcolmodel,;
                 Ctrlinfo->ASETCODE := masetcode, Ctrlinfo->PLATENO  := mplateno ,;
                 Ctrlinfo->SERIALNO := mserialno, Ctrlinfo->MOTORNO  := mmotorno ,;
                 Ctrlinfo->CRNUMBER := mcrnumber, Ctrlinfo->CRORNO   := mcrorno  ,;
                 Ctrlinfo->CREXPIRY := mcrexpiry, Ctrlinfo->LOCATION := mlocation,;
                 Ctrlinfo->TCTNO    := mtctno   , Ctrlinfo->RETRNO   := mretrno  ,;
                 Ctrlinfo->RETRDATE := mretrdate, Ctrlinfo->APPDATE  := mappdate ,;
                 Ctrlinfo->APPVALUE := mappvalue, Ctrlinfo->APREYSER := mapreyser,;
                 Ctrlinfo->APPFREQ  := mappfreq , Ctrlinfo->INSURED  := minsured ,;
                 Ctrlinfo->Unitgrp  := munitgrp , Ctrlinfo->brcode   := sbrcode  ,;
           if( minsured,                        ;
              eval( {|| Ctrlinfo -> INSBY     :=  minsby ,    ;
              Ctrlinfo -> INSCO     :=  minsco          , Ctrlinfo -> INSPREM   :=  minsprem   ,;
              Ctrlinfo -> INSDATE   :=  minsdate        , Ctrlinfo -> INSEXPRY  :=  minsexpry  ,;
              Ctrlinfo -> INSCOVER  :=  minscover       , Ctrlinfo -> INSPOLCY  :=  minspolcy  ,;
              Ctrlinfo -> INSOR     :=  minsor          , ;
              Ctrlinfo -> AMTINS    :=  mamtins }), ;
              eval( {|| Ctrlinfo -> INSBY     :=  space(len(minsby)),     ;
              Ctrlinfo -> INSCO     :=  space(len(minsco))     , Ctrlinfo -> INSPREM   :=  0   ,;
              Ctrlinfo -> INSDATE   :=  ctod('')        , Ctrlinfo -> INSEXPRY  :=  ctod(''),;
              Ctrlinfo -> INSCOVER  :=  space(len(minscover))       , Ctrlinfo -> INSPOLCY  :=  space(len(minspolcy))  ,;
              Ctrlinfo -> INSOR     :=  space(len(minsor))          , ;
              Ctrlinfo -> AMTINS    :=  0 }) ;
              ), ;
              Ctrlinfo -> REMARKS   :=  mremarks ;
         })
      Ctrlinfo->( dbunlock() )
      Ctrlinfo->( dbcommit() )
   endif
endif
return nil
*********************************
static function update_sequence()
*********************************
   if Ctrlinfo->( eof() ) .or. Ctrlinfo->ACCTNO!=Acctdaly->ACCTNO .or. Ctrlinfo->brcode != Acctdaly->brcode
      do while Ctrlinfo->ACCTNO != Acctdaly->ACCTNO .and. ;
              !Ctrlinfo->(bof())                    .and. ;
               Ctrlinfo->brcode == Acctdaly->brcode
         Ctrlinfo->(dbskip(-1))
      enddo
      if ( Ctrlinfo->(bof())                    .or. ;
           Ctrlinfo->ACCTNO != Acctdaly->ACCTNO .or. ;
           Ctrlinfo->brcode != Acctdaly->brcode  ,;
           Ctrlinfo->(dbseek(ACCTDALY->BRCODE+Acctdaly->ACCTNO,.F.)),;      && RED sbrcode
           nil ;
         )
   endif
return nil
*************************************************
static function dispstatus( mrow, mpos, mlastrec)
*************************************************
  local mrecno := recno() , mok := .t.
  mlastrec := if ( mlastrec==0, mlastrec :=1, mlastrec )
  @ mrow, 78 say chr(176) color 'w/n'
  mrow := max( 8, mpos / mlastrec * 21 )
  mrow := if ( mrow > 21, 21, mrow     )
  if ( eval({ || dbskip(-1) , (Ctrlinfo->brcode == g_PAR_BRCH .or. Ctrlinfo->(bof()) .or. Ctrlinfo->ACCTNO!=Acctdaly->ACCTNO) }), eval({|| mrow := 08, devPos( mrow, 78 ) , devout( chr(219), "w+/w" ),mok:=.f. }),nil)
  if ( eval({ || dbskip(+1) , (Ctrlinfo->brcode == g_PAR_BRCH .or. Ctrlinfo->(eof()) .or. Ctrlinfo->ACCTNO!=Acctdaly->ACCTNO) .and. mok  }), eval({|| mrow := 21, devPos( mrow, 78 ) , devout( chr(219), "w+/w" ),mok:=.f. }),nil)
  if ( mok  , eval ({|| devPos( mrow, 78 ) , devout( chr(219), "w+/w" ) }), nil)
  dbgoto ( mrecno )
return nil
****************************************
static function up_pos ( mpos )
****************************************
   local mrecno := Ctrlinfo->( recno() )
   mpos         := 0
**   Ctrlinfo-> (dbgotop())
   Ctrlinfo-> (dbseek(Acctdaly->brcode+Acctdaly->acctno))
   Ctrlinfo-> (dbeval({|| if ( !Ctrlinfo->(deleted())  .and. Ctrlinfo->ACCTNO==Acctdaly->ACCTNO, mpos++, nil )},,;
                      {|| Ctrlinfo->(recno())!= mrecno .and. ;
                          Ctrlinfo->brcode == Acctdaly->brcode .and. ;
                          !Ctrlinfo->(eof()) }))
   mpos++
return nil
**********************************************************
static function get_appfreq(mappfreqchoices,mappfreq,mrow)
**********************************************************
   mappfreq  := gen_achoice  ( mappfreqchoices, val( mappfreq ), 'App. Freq. ', mrow+1, 56, mrow+1+len (mappfreqchoices), 77, 'w/gr+,w/n,,,w/gr+' )
   @ mrow, 59 say dispappfreq( mappfreq ) color 'gr+/gr'
return .f.

**********************************************************
function get_unitgrp( munitchoices,munitgrp,mrow)
**********************************************************
   munitgrp  := gen_achoice  ( munitchoices, val( munitgrp ), 'Unit Group', mrow+1, 20, mrow+1+len (munitchoices), 35, 'w/gr+,w/n,,,w/gr+' )
   if  val( munitgrp ) > 0
      @ mrow, 22 say substr( munitchoices[ val( munitgrp) ], 5, 8 )  color 'gr+/gr'
   endif
return .f.

********************************************************
static function get_insby  ( minsbychoices,minsby,mrow )
********************************************************
   minsby := gen_achoice  ( minsbychoices, val( minsby ), 'Insured thru', mrow+1, 56, mrow+1+len (minsbychoices), 77, 'w/gr+,w/n,,,w/gr+' )
   @ mrow, 59 say dispinsthru( minsby ) color 'gr+/gr'
return .f.
*************************************
static function dispinsthru( minsby )
*************************************
   local mlist := space(6) + 'ClientColf  Dealer'
return upper( substr( mlist, val( alltrim( minsby ) ) * 6 + 1, 6 ) )
******************************************************************
static function get_insured( minschoices,minsured,minstring,mrow )
******************************************************************
   local minstr := if(minsured,'1','2')
   if lastkey() != K_ESC
      minstr    := gen_achoice( minschoices, val( minstr ), 'Insured?', mrow+1, 56, mrow+1+len ( minschoices ), 77, 'w/gr+,w/n,,,w/gr+' )
      minsured  := if ( minstr == '1',.t.,.f. )
      minstring := upper( if ( minsured,'Yes   ','Waived'  ) )
      @ mrow, 57 say dispinsured(minsured) color 'gr+/gr'
   endif
return .f.
************************************
static function chkinscode( minsco, cBRCODE )
************************************
   local mscr,getlist := {}
   LOCAL nPRVORD := INSURANC->(DBSETORDER())

   INSURANC->(DBSETORDER(2))
   INSURANC->(DBSEEK(cBRCODE+mINSCO))
   INSURANC->(DBSETORDER(nPRVORD))

   do while .t.
      mscr := savescreen (,,,)
      center ( 24, 'w+/n', '® Search Insurance Name ¯' )
      __lb_lkup('Insuranc', 1, 2, @minsco, 10, 1, 2, 13, 13, 22, 75, 'W/GR+,W/N,,,W/GR+', , , , , , )
      restscreen ( ,,,, mscr )
      @ 15, 62 say upper( left(dispinsname(minsco),16) ) color 'gr+/gr'

      if lastkey() == K_ESC
         exit
      endif

      if Insuranc->catcode != '01'            // NOT ACCREDITED
         error ( 'Insurance Company not accredited' )
         loop
      else
         exit
      endif

   enddo
return .f.
*************************************
function dispinsname( minsco )
*************************************
if Insuranc-> (dbseek(g_PAR_BRCH+minsco))
   return upper( Insuranc->INSNAME )
else
   return space(len(Insuranc->Insname ))
endif
return nil
****************************
function ctrldelete(macctno)
****************************
   local mscr := savescreen (,,,)
   center ( 24, 'w+/n', '® Deleting Records in Collateral Information File ¯' )
   Ctrlinfo->( netlock ('F',0) )
   Ctrlinfo->( dbseek(macctno) ) && RED REMOVED 'sbrcode+
   Ctrlinfo->( dbeval({||Ctrlinfo->(dbdelete())},,{|| Ctrlinfo->brcode == sbrcode .and. Ctrlinfo->ACCTNO==macctno .and. !Ctrlinfo->(eof())}) )
   Ctrlinfo->( dbunlock())
   restscreen (,,,,mscr)
return nil
*************************************************
function chkasetcode  ( masetcode, mrow, mcol )
*************************************************
   local mscreen := savescreen( ,,, )
   center ( 24, 'w+/n', '® Select Asset Name ¯' )
   lb_lkup('Asetcode',1,1,@masetcode, 2 , 1, 10, 12, 22, 75, 'W/GR+,W/N,,,W/GR+')
   restscreen( ,,,, mscreen )
   @ mrow, mcol+3 say left ( disp_asetname( masetcode ), 13 ) color 'gr+/gr'
return .f.
*************************************************
function disp_asetname ( masetcode )
*************************************************
   Asetcode->( dbseek ( masetcode ) )
return upper(  Asetcode->ASETNAME )

****************************
*
Function dispnextyr(olddate)
****************************
local yyear:=year( olddate ) + 1
local dday := substr( str( day( olddate )+100,3 ),2,2 )
local mmonth := substr( str(month(olddate)+100,3),2,2 )

if month(olddate) == 2 .and. day(olddate) == 29
   dday   := '01'
   mmonth := '03'
endif
return ctod( mmonth+'/'+dday+'/'+str(yyear,4) )

*
*                     End of the Program ( amst100d.prg )
*
