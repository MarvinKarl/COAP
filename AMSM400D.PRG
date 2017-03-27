/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   program id.........:  amsm400d.prg                                         ³
³   description........:  Acctmast data entry ( Collateral Info. )             ³
³   author.............:  Ariel B. Bulan                                       ³
³   date...............:  01:35pm 02-Jan-1994                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                         U P D A T E S                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        Who        ³     When      ³               Why                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                   ³               ³                                          ³
³   abb             ³  07.28.2004   ³  insurance co. validation                ³
³                   ³               ³  -- accredited insurance co.             ³
³                   ³               ³  -- only                                 ³
³   mts             ³   9/26/2013   ³  Added F5 option for editing of Appraisal³
³                   ³               ³     Value, Date and Appraiser            ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
#include "Colf.ch"
#include "Inkey.ch"
#define sound_good  tone( 60, .5 )
******************************************************************
*
function coll_info ( macctno, mis_add_one,misentered  )
******************************************************************
   local  mscr := savescreen( ,,, ), i, mdbf := savedbf(),w_rec:= .f.
   local  mcolor := setcolor(), mrow := 8, mpos := 1, mlastrec := 0
   local  mkey, mcontinue := .t., mkey_ := { '<Ins>\-Add ', '<F2>\Edit ', '<F3>\Others ', '<F5>\Apprsl ', '<Del>\ ', '<Esc>\' }
   memvar ax_level,g_user_id
   priva  mcoltype , mcolmodel, masetcode, mplateno , mserialno, mmotorno  ,;
          mcrnumber, mcrorno  , mcrexpiry, mlocation, mtctno   , mretrno  , mretrdate,;
          mappdate , mappvalue, mapreyser, mappfreq , minsured , minsby   , minsco   ,;
          minsprem , minsdate , minsexpry, minscover, minspolcy, minsor   , mremarks ,;
          mamtins  , munitgrp , mmrvno

   if !chkpass( procname(),ax_level,g_user_id )
      return nil
   endif

   scr_make( mkey_, 6, 1, 23, 78,, .f., 'n/gr' )
   devpos( 6, 2 ); devout( 'Collateral Information', 'w+/gr' )
   dbselectarea ( 'Ctrlinfo' )
   /*       && RED 040705 PANG PATAGAL LANG...
   if Ctrlinfo->( dbseek ( mACCTNO,.f. ) )    && RED 112604 REPLACED 'Acctmast->BRCODE+Acctmast->acctno WITH 'mACCTNO
      waiton( 'wait a second, please!',, 'n/w' )
      Ctrlinfo->( dbeval ( { || mlastrec++ },, { || Ctrlinfo->BRCODE+Ctrlinfo->acctno == mACCTNO } ) )   && RED 112604 REPLACED 'Acctmast->BRCODE+Acctmast->acctno WITH mACCTNO
      waitoff()
   endif
   */
   *Ctrlinfo->( dbseek ( mACCTNO,.f. ) )        && RED 040705
   IF !Ctrlinfo->( dbseek ( mACCTNO,.f. ) )
      if( mlastrec==0 , eval({|| if( !mis_add_one, error( "No Record Found!" ),nil), IF(CURRBRCH(LEFT(mACCTNO,3)),__keyboard(chr(K_INS)),NIL) }), nil)
   ENDIF

   do while mcontinue
      if( Ctrlinfo->(eof()),w_rec:=.f.,nil )
      disp_record ()
      *dispstatus  ( @mrow, mpos, mlastrec )       && RED 040705

      mkey := inkey(0)
      do case
         case mkey == K_UP
              if chkpass('S',ax_level,g_user_id)
                 Ctrlinfo->(dbskip(-1))
                 mpos--
                 if Ctrlinfo->(bof()) .or. CTRLINFO->BRCODE+Ctrlinfo->ACCTNO!=mACCTNO
                    mpos++
                    sound_good
                    waiton('First Record', .f., 'n/w', 5 )
                    inkey( .1 )
                    waitoff()
                    dbseek(mACCTNO,.f.)
                 endif
              endif
         case mkey == K_DOWN
              if chkpass('S',ax_level,g_user_id)
                if CTRLINFO->BRCODE+Ctrlinfo->ACCTNO == mACCTNO .and. !Ctrlinfo->(bof()) .and. !Ctrlinfo->(eof())
                   w_rec:= .t.
                   Ctrlinfo->(dbskip(+1))
                endif
                 //Ctrlinfo->(dbskip(+1))
                 mpos++
                 if Ctrlinfo->(eof()) .or. CTRLINFO->BRCODE+Ctrlinfo->ACCTNO!=mACCTNO
                    mpos--
                    sound_good
                    waiton('Last Record', .f., 'n/w', 5 )
                    inkey( .1 )
                    waitoff()
                 endif
                if ( CTRLINFO->BRCODE+Ctrlinfo->ACCTNO <> mACCTNO ) // .and. w_rec
                   Ctrlinfo->(dbskip(-1))
                endif
                if ( CTRLINFO->BRCODE+Ctrlinfo->ACCTNO <> mACCTNO )
                   Ctrlinfo->(dbseek(mACCTNO,.f.) )
                endif
                 //update_sequence()
              endif
         case mkey == K_INS
              if CURRBRCH(LEFT(mACCTNO,3)) .AND. chkpass('A',ax_level,g_user_id)
                 if t100d_update ( macctno, 'A', mis_add_one, @misentered )
                    mlastrec++
                    *up_pos ( @mpos )                      && RED 040705
                    if ( mis_add_one, mcontinue:=.f., nil )
                 endif
              endif
         case mkey == K_F2
              if CURRBRCH(CTRLINFO->BRCODE) .AND. chkpass('E',ax_level,g_user_id)
                 if ( Ctrlinfo->(eof()) .or. CTRLINFO->BRCODE+Ctrlinfo->ACCTNO!=Acctmast->BRCODE+Acctmast->ACCTNO, error( 'Nothing to Edit!'), t100d_update(mACCTNO,'E',mis_add_one,@misentered) )
              endif
         case mkey == K_DEL
              if CURRBRCH(CTRLINFO->BRCODE) .AND. chkpass('D',ax_level,g_user_id)
                 if ( Ctrlinfo->(eof()), error('Nothing to Delete!'), amsmdelete( 'Delete this Collateral Information',@mpos,@mlastrec ) )
                 update_sequence()
              endif
         case mkey == K_ESC
              if exitmod()
                 mcontinue := .f.
              endif
         case mkey == K_F3
              if Acctmast->(!eof()) .and. Acctmast->(!bof()) .and. !empty( Acctmast->Acctno )
                 othercoltrl( mACCTNO )
             endif
         case mkey == K_F5
              if CURRBRCH(CTRLINFO->BRCODE) .AND. chkpass('S',ax_level,g_user_id)
                 if ( Ctrlinfo->(eof()) .or. CTRLINFO->BRCODE+Ctrlinfo->ACCTNO!=Acctmast->BRCODE+Acctmast->ACCTNO, error( 'Nothing to Edit!'), edit_apprsl( mACCTNO ))
              endif
      endcase
   enddo
   setcolor  ( mcolor  )
   restscreen( ,,,,mscr)
   restdbf   ( mdbf   )
return nil

*************************************
*
static function edit_apprsl( mACCTNO )
*************************************
local mcolor  := setcolor (), mcursor := setcursor(), mscreen := savescreen( ,,, )
local mretval := .f., mcontinue := .t. ,mrecno := Ctrlinfo->( recno() )
local mrayt := 57,mrow := 7
local getlist := {}

mappdate    :=  Ctrlinfo -> APPDATE
mappvalue   :=  Ctrlinfo -> APPVALUE
mapreyser   :=  Ctrlinfo -> APREYSER
	  
if chkpass('E',ax_level,g_user_id)

   setcolor( 'w/gr, n/w,,, w+/gr' )
   
   do while mcontinue 

      @ mrow+1 , mrayt get mappdate  pict '@D' VALID !EMPTY(mappdate) .AND. mappdate <= gTRANDATE
      @ row()+1, mrayt get mappvalue pict '999,999,999.99' valid (mappvalue>0)
	  @ row()+1, mrayt get mapreyser pict '@X' when eval({|| get_ci(@mapreyser),.f. }) valid !empty(mapreyser)
	    
      setcursor( 3 )
      read
      setcursor( 0 )
	  
      if lastkey() == K_ESC
         if esckey()
            mcontinue := .f.; mretval := .f. ; misentered := .f.
         endif
         loop
      endif

      if confirm('Are all entries correct?')
	  
		 if Ctrlinfo->APPDATE <> mappdate
		    drop( alltrim(g_user_id)+' '+'Edits appraisal date of '+ substr(Ctrlinfo->acctno,-5,5) + " from " + dtos(Ctrlinfo->APPDATE) + " to " + dtos(mappdate))
		 endif
		 if Ctrlinfo->APPVALUE <> mappvalue
		    drop( alltrim(g_user_id)+' '+'Edits appraisal value of '+ substr(Ctrlinfo->acctno,-5,5) + " from " + str(Ctrlinfo->APPVALUE) + " to " + str(mappvalue))
		 endif
		 if Ctrlinfo->APREYSER <> mapreyser
		    drop( alltrim(g_user_id)+' '+'Edits appraiser of '+ substr(Ctrlinfo->acctno,-5,5) + " from " + alltrim(Ctrlinfo->APREYSER) + " to " + alltrim(mapreyser))
		 endif
		 
         MSGWIN(9,35,'Saving','W+/BG','R*/BG','ON') 
         if Ctrlinfo->( netlock('R',0) )
		    Ctrlinfo->APPDATE  := mappdate
		    Ctrlinfo->APPVALUE := mappvalue
			Ctrlinfo->APREYSER := mapreyser
		    Ctrlinfo->(dbunlock())
		    Ctrlinfo->(dbcommit())
		 endif
         mrecno := Ctrlinfo->(recno())
         mretval := .t. ; misentered := .t.

         MSGWIN(9,35,'Saving',,,'OFF')
      else
         loop
      endif

      mcontinue := .f.
	  
   enddo
  dbgoto    ( mrecno  )
  setcolor  ( mcolor  )
  restscreen( ,,,, mscreen )
endif

return ( mretval )

*******************************
*
static function get_ci(mapreyser)
*******************************

lb_lkup ( 'Personel',1,1,@mapreyser, 2 , 1, 10, 47, 21, 75,'w/gr','@XS15','@X',2 )
mapreyser := left(mapreyser,20)

return

*******************************
*
static function disp_record()
*******************************
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
    @ row()  , col()+1 say left( disp_asetname ( Ctrlinfo->ASETCODE ), 13 ) color 'w+/gr'
    @ row()  , mrayt say '    Appraisal Value  ' color 'w/gr'
    @ row()  , col() say Ctrlinfo->APPVALUE color 'w+/gr' pict '999,999,999.99'
    @ row()+1, mleft say '     Unit Group  ' color 'w/gr'
    @ row()  , col() say Ctrlinfo->unitgrp color 'w+/gr'
    @ row()  , col() say if( Ctrlinfo->Unitgrp <> ' ',unit_[ val(Ctrlinfo->Unitgrp) ],'             ') color 'w+/gr'
    @ row()  , mrayt say '          Appraiser  ' color 'w/gr'
    @ row()  , col() say Ctrlinfo->APREYSER color 'w+/gr' pict '@X'
    @ row()+1, mleft say '       Plate N§  ' color 'w/gr'
    @ row()  , col() say Ctrlinfo->PLATENO  color 'w+/gr' pict '@X'
    @ row()  , mrayt say 'Appraisal Frequency  ' color 'w/gr'
    @ row()  , col() say Ctrlinfo->APPFREQ  color 'w+/gr' pict '@X'
    @ row()  , col() say ' '+ dispappfreq( Ctrlinfo->APPFREQ ) color 'w+/gr'
    @ row()+1, mleft say '      Serial N§  ' color 'w/gr'
    @ row()  , col() say Ctrlinfo->SERIALNO color 'w+/gr' pict '@X'
    @ row()+1, mleft say '       Motor N§  ' color 'w/gr'
    @ row()  , col() say Ctrlinfo->MOTORNO  color 'w+/gr' pict '@X'
    @ row()  , mrayt say '            Insured  ' color 'w/gr'
    @ row()  , col() say dispinsured(Ctrlinfo->INSURED) color 'w+/gr'
    @ row()+1, mleft say '          CR N§  ' color 'w/gr'
    @ row()  , col() say Ctrlinfo->CRNUMBER color 'w+/gr' pict '@X'
    @ row()  , mrayt say '       Insured thru  ' color 'w/gr'
    @ row()  , col() say left( Ctrlinfo->INSBY,1 ) + ' ' + dispinsthru( Ctrlinfo->INSBY ) color 'w+/gr' pict '@X'
    @ row()+1, mleft say '          OR N§  ' color 'w/gr'
    @ row()  , col() say Ctrlinfo->CRORNO   color 'w+/gr' pict '@X'
    @ row()  , mrayt say '      Insurance Co.  ' color 'w/gr'
    @ row()  , col() say Ctrlinfo->INSCO    color 'w+/gr' pict '@X'
    @ row()  , col() say ' '+ left( dispinsname(Ctrlinfo->INSCO),16 ) color 'w+/gr'

    //noels

    @ row()+1, mleft say "   M.V. File N§  " color 'w/gr'
    @ row()  , col() say Ctrlinfo->MRVno color 'w+/gr' 
    @ row()  , mrayt say '     Amount Insured  ' color 'w/gr'
    @ row()  , col() say Ctrlinfo->AMTINS color 'w+/gr' pict '999,999,999.99'
    @ row()+1, mleft say "   Reg'n Expiry  " color 'w/gr'
    @ row()  , col() say Ctrlinfo->CREXPIRY color 'w+/gr' pict '@D'
    @ row()  , mrayt say '  Insurance Premium  ' color 'w/gr'
    @ row()  , col() say Ctrlinfo->INSPREM  color 'w+/gr' pict '999,999,999.99'
    @ row()+1, mleft say ' Prop. Location  ' color 'w/gr'
    @ row()  , col() say Ctrlinfo->LOCATION color 'w+/gr' pict '@X'
    @ row()  , mrayt say '       Date Insured  ' color 'w/gr'
    @ row()  , col() say Ctrlinfo->INSDATE  color 'w+/gr' pict '@D'
    @ row()+1, mleft say '         TCT N§  ' color 'w/gr'
    @ row()  , col() say Ctrlinfo->TCTNO    color 'w+/gr' pict '@X'
    @ row()  , mrayt say 'Insurance Exp. Date  ' color 'w/gr'
    @ row()  , col() say Ctrlinfo->INSEXPRY color 'w+/gr' pict '@D'
    @ row()+1, mleft say ' Latest RETR N§  ' color 'w/gr'
    @ row()  , col() say Ctrlinfo->RETRNO   color 'w+/gr' pict '@X'
    @ row()  , mrayt say '   Type of Coverage  ' color 'w/gr'
    @ row()  , col() say Ctrlinfo->INSCOVER color 'w+/gr' pict '@X'
    @ row()  , col() say ' '+ dispcover( Ctrlinfo->INSCOVER ) color 'w+/gr'
    @ row()+1, mleft say 'Latest RETR Dt.  ' color 'w/gr'
    @ row()  , col() say Ctrlinfo->RETRDATE color 'w+/gr' pict '@D'
    @ row()  , mrayt say '          Policy N§  ' color 'w/gr'
    @ row()  , col() say Ctrlinfo->INSPOLCY color 'w+/gr' pict '@X'
    @ row()+1, mleft say 'Remarks  ' color 'w/gr'
    @ row()  , col() say Ctrlinfo->REMARKS color 'w+/gr' pict '@X'
    @ row()  , mrayt+10 say 'Ins OR N§  ' color 'w/gr'
    @ row()  , col() say Ctrlinfo->INSOR  color 'w+/gr' pict '@X'
    dispend()
return nil
************************************************************************
*
static function t100d_update( macctno, mwhat, mis_add_one, misentered )
************************************************************************
   local mcolor  := setcolor (), mcursor := setcursor(), mscreen := savescreen( ,,, )
   local mretval := .f., mcontinue := .t. ,mrecno := Ctrlinfo->( recno() )
   local mleft   := 20 , mrayt := 57, mrow := 7
   local minsbychoices   := { '1 = Client','2 = Colf  ','3 = Dealer' }
   local minschoices     := { '1 = Yes','2 = Waived' }       , minstring
   local mappfreqchoices := { '1 = Quarterly  ','2 = Semi-annual','3 = Annual     '}
   local munitchoices    := { '1 = SafeTNET','2 = LTO     ','3 = Others  ' }
   local getlist := {}
   memvar mcoltype , mcolmodel, masetcode, mplateno , mserialno, mmotorno ,;
          mcrnumber, mcrorno  , mcrexpiry, mlocation, mtctno   , mretrno  ,;
          mretrdate, mappdate , mappvalue, mapreyser, mappfreq , minsured ,;
          minsby   , minsco   , minsprem , minsdate , minsexpry, minscover,;
          minspolcy, minsor   , mremarks , mamtins  , munitgrp , mmrvno

   if upper( mwhat ) == chr(65)
      Ctrlinfo->( dbgoto( lastrec() + 1 ) )
      center( 24, 'w+/n', padc( '® Add Record ¯', 80 ) )
   else
      mwhat := chr(82)
      center( 24, 'w+/n', padc( '® Edit Record ¯', 80 ) )      
   endif

   assign_ctrlinfo()
   disp_record()   
   setcolor( 'w/gr, n/w,,, w+/gr' )

   @ 09  , 23 say left( disp_asetname ( masetcode ),13 ) color 'w/gr'
   @ 13  , 57 say dispinsured ( minsured ) color 'w/gr'
   @ 14  , 59 say dispinsthru ( minsby   ) color 'w/gr'

   do while mcontinue 
      minstring := upper( if ( minsured,'Yes   ','Waived' ) )
      @ mrow   , 30    get mcoltype  pict '@X'
      @ row()+1, mleft get mcolmodel pict '@X'
      @ row()+1, mleft get masetcode pict '@X' when chkasetcode ( @masetcode, row()+1, mleft )
      @ row()+1, mleft get munitgrp  pict '9' when get_unitgrp( munitchoices,@munitgrp, 10 )
      @ row()+1, mleft get mplateno  pict '@X'
      @ row()+1, mleft get mserialno pict '@X'
      @ row()+1, mleft get mmotorno  pict '@X'
      @ row()+1, mleft get mcrnumber pict '@X'
      @ row()+1, mleft get mcrorno   pict '@X'
      // noels
      @ row()+1, mleft get mmrvno    pict '@X'
      @ row()+1, mleft get mcrexpiry pict '@X'
      @ row()+1, mleft get mlocation pict '@XS15'
      @ row()+1, mleft get mtctno    pict '@X' when masetcode == '12'
      @ row()+1, mleft get mretrno   pict '@X' when masetcode == '12'
      @ row()+1, mleft get mretrdate pict '@D' when masetcode == '12'
      @ row()+1, mleft-8 get mremarks  pict '@X' 
      @ mrow+1 , mrayt get mappdate  pict '@D' 
      @ row()+1, mrayt get mappvalue pict '999,999,999.99' valid (mappvalue>=0)
      @ row()+1, mrayt get mapreyser pict '@X' 
      @ row()+1, mrayt get mappfreq  pict '@X' when get_appfreq( mappfreqchoices,@mappfreq,11 )
      @ row()+2, mrayt get minstring pict '@X' when get_insured( minschoices,@minsured,@minstring, 13 )
      @ row()+1, mrayt get minsby    pict '@X' when upper(alltrim(minstring)) <> 'WAIVED' .and. get_insby  ( minsbychoices,@minsby,14 )
      @ row()+1, mrayt get minsco    pict '@X' when upper(alltrim(minstring)) <> 'WAIVED' .and. chkinscode ( @minsco )
      @ row()+1, mrayt get mamtins   pict '999,999,999.99' when upper(alltrim(minstring)) <> 'WAIVED' valid ( mamtins >=0)
      @ row()+1, mrayt get minsprem  pict '999,999,999.99' when upper(alltrim(minstring)) <> 'WAIVED'valid ( minsprem>=0) //.and. (minsprem<mamtins) 
      @ row()+1, mrayt get minsdate  pict '@D' when lastkey() <> K_ESC .and. upper(alltrim(minstring)) <> 'WAIVED' ;
                                               valid eval( {|| minsexpry:=dispnextyr(minsdate),.t.} )
      @ row()+1, mrayt get minsexpry pict '@D' when lastkey() <> K_ESC .and. upper(alltrim(minstring)) <> 'WAIVED'
      @ row()+1, mrayt get minscover pict '@X' when upper(alltrim(minstring)) <> 'WAIVED' .AND. eval({|| minscover:=flook_ONLINE(.t.,'Coverage',minscover,'Coverage Code',,,,1),;
                                                    if( lastkey() <> K_ESC,dispcover(minscover,20,mrayt),nil),.f. } )
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
            MSGWIN(9,35,'Saving','W+/BG','R*/BG','ON')
            save_ctrlinfo( mwhat , .t.        )
            mrecno := Ctrlinfo->(recno())
            mretval := .t. ; misentered := .t.
            MSGWIN(9,35,'Saving',,,'OFF')
         else
            loop
         endif
      else
         mretval := .t.; misentered := .t.
      endif
      mcontinue := .f.
      if (minsprem >mamtins)
      	alert("Insurance premium should be less than sum insured")
      endif
  enddo
  dbgoto    ( mrecno  )
  setcolor  ( mcolor  )
  restscreen( ,,,, mscreen )
return ( mretval )
********************************************************
*
static function get_insby  ( minsbychoices,minsby,mrow )
********************************************************
   minsby := gen_achoice  ( minsbychoices, val( minsby ), 'Insured thru', mrow+1, 56, mrow+1+len (minsbychoices), 77, 'w/gr+,w/n,,,w/gr+' )
   @ 14, 59 say dispinsthru( minsby ) color 'w/gr'
return .f.
*************************************
*
static function dispinsthru( minsby )
*************************************
   local mlist := space(6)+'Client'+'Colf  '+'Dealer'
return upper( substr( mlist, val( alltrim( minsby ) ) * 6 + 1, 6 ) )
**************************************
*
static function assign_ctrlinfo()
**************************************
   memvar mcoltype , mcolmodel, masetcode, mplateno , mserialno, mmotorno , mmrvno , ;
          mcrnumber, mcrorno  , mcrexpiry, mlocation, mtctno   , mretrno  , mretrdate,;
          mappdate , mappvalue, mapreyser, mappfreq , minsured , minsby   , minsco   ,;
          minsprem , minsdate , minsexpry, minscover, minspolcy, minsor   , munitgrp, mamtins

   eval({||                                   ;
      mcoltype    :=  Ctrlinfo -> COLTYPE    , mcolmodel   :=  Ctrlinfo -> COLMODEL   ,;
      masetcode   :=  Ctrlinfo -> ASETCODE   , mplateno    :=  Ctrlinfo -> PLATENO    ,;
      mserialno   :=  Ctrlinfo -> SERIALNO   , mmotorno    :=  Ctrlinfo -> MOTORNO    ,;
      mcrnumber   :=  Ctrlinfo -> CRNUMBER   , mcrorno     :=  Ctrlinfo -> CRORNO     ,;
      mcrexpiry   :=  Ctrlinfo -> CREXPIRY   , mlocation   :=  Ctrlinfo -> LOCATION   ,;
      mtctno      :=  Ctrlinfo -> TCTNO      , mretrno     :=  Ctrlinfo -> RETRNO     ,;
      mretrdate   :=  Ctrlinfo -> RETRDATE   , mappdate    :=  Ctrlinfo -> APPDATE    ,;
      mappvalue   :=  Ctrlinfo -> APPVALUE   , mapreyser   :=  Ctrlinfo -> APREYSER   ,;
      mappfreq    :=  Ctrlinfo -> APPFREQ    , minsured    :=  Ctrlinfo -> INSURED    ,;
      minsby      :=  Ctrlinfo -> INSBY      , minsco      :=  Ctrlinfo -> INSCO      ,;
      minsprem    :=  Ctrlinfo -> INSPREM    , minsdate    :=  Ctrlinfo -> INSDATE    ,;
      minsexpry   :=  Ctrlinfo -> INSEXPRY   , minscover   :=  Ctrlinfo -> INSCOVER   ,;
      minspolcy   :=  Ctrlinfo -> INSPOLCY   , minsor      :=  Ctrlinfo -> INSOR      ,;
      mremarks    :=  Ctrlinfo -> REMARKS    , mamtins     :=  Ctrlinfo -> AMTINS     ,;
      munitgrp    :=  Ctrlinfo -> Unitgrp    , mmrvno      :=  Ctrlinfo -> MRVno       ;
   })
return nil
*********************************************
*
static function save_ctrlinfo( mwhat, misentered )
*********************************************
   memvar mcoltype , mcolmodel, masetcode, mplateno , mserialno, mmotorno , mmrvno, ;
          mcrnumber, mcrorno  , mcrexpiry, mlocation, mtctno   , mretrno  , mretrdate,;
          mappdate , mappvalue, mapreyser, mappfreq , minsured , minsby   , minsco   ,;
          minsprem , minsdate , minsexpry, minscover, minspolcy, minsor   , mamtins, munitgrp

   if misentered
      if Ctrlinfo->( netlock(mwhat,0) )
         eval({||                                ;
           Ctrlinfo -> ACCTNO    :=  Acctmast->ACCTNO, Ctrlinfo -> COLTYPE   :=  mcoltype   ,;
           Ctrlinfo -> COLMODEL  :=  mcolmodel       , Ctrlinfo -> ASETCODE  :=  masetcode  ,;
           Ctrlinfo -> PLATENO   :=  mplateno        , Ctrlinfo -> SERIALNO  :=  mserialno  ,;
           Ctrlinfo -> MOTORNO   :=  mmotorno        , Ctrlinfo -> CRNUMBER  :=  mcrnumber  ,;
           Ctrlinfo -> CRORNO    :=  mcrorno         , Ctrlinfo -> CREXPIRY  :=  mcrexpiry  ,;
           Ctrlinfo -> LOCATION  :=  mlocation       , Ctrlinfo -> TCTNO     :=  mtctno     ,;
           Ctrlinfo -> RETRNO    :=  mretrno         , Ctrlinfo -> RETRDATE  :=  mretrdate  ,;
           Ctrlinfo -> APPDATE   :=  mappdate        , Ctrlinfo -> APPVALUE  :=  mappvalue  ,;
           Ctrlinfo -> APREYSER  :=  mapreyser       , Ctrlinfo -> APPFREQ   :=  mappfreq   ,;
           Ctrlinfo -> INSURED   :=  minsured        , Ctrlinfo -> Unitgrp   :=  munitgrp   ,;
           Ctrlinfo -> MRVno     :=  mmrvno          , CTRLINFO -> BRCODE    := ACCTMAST->BRCODE ,;
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
         Ctrlinfo -> (dbunlock())
         Ctrlinfo -> (dbcommit())
      endif
   endif
return nil
*********************************
*
static function update_sequence()
*********************************
   if Ctrlinfo->( eof() ) .or. Ctrlinfo->ACCTNO!=Acctmast->ACCTNO
      do while CTRLINFO->BRCODE+Ctrlinfo->ACCTNO != ACCTMAST->BRCODE+Acctmast->ACCTNO .and. ;
         !Ctrlinfo->(bof())
         Ctrlinfo->(dbskip(-1))
      enddo
      if(Ctrlinfo->(bof()) .or. CTRLINFO->BRCODE+Ctrlinfo->ACCTNO != ACCTMAST->BRCODE+Acctmast->ACCTNO,;
         Ctrlinfo->(dbseek(ACCTMAST->BRCODE+Acctmast->ACCTNO,.F.)),nil)
   endif
return nil
*************************************************
*
static function dispstatus( mrow, mpos, mlastrec)
*************************************************
  local mrecno := recno() , mok := .t.
  mlastrec := if ( mlastrec==0, mlastrec :=1, mlastrec )
  dispbegin()
  @ mrow, 78 say chr(176) color 'w/n'
  mrow := max( 8, mpos / mlastrec * 21 )
  mrow := if ( mrow > 21, 21, mrow     )
  if ( eval({ || dbskip(-1) , (Ctrlinfo->(bof()) .or. CTRLINFO->BRCODE+Ctrlinfo->ACCTNO!=ACCTMAST->BRCODE+Acctmast->ACCTNO) }), eval({|| mrow := 08, devPos( mrow, 78 ) , devout( chr(219), "w+/w" ),mok:=.f. }),nil)
  if ( eval({ || dbskip(+1) , (Ctrlinfo->(eof()) .or. CTRLINFO->BRCODE+Ctrlinfo->ACCTNO!=ACCTMAST->BRCODE+Acctmast->ACCTNO) .and. mok  }), eval({|| mrow := 21, devPos( mrow, 78 ) , devout( chr(219), "w+/w" ),mok:=.f. }),nil)
  if ( mok  , eval ({|| devPos( mrow, 78 ) , devout( chr(219), "w+/w" ) }), nil)
  dispend()
  dbgoto ( mrecno )
return nil
****************************************
*
static function up_pos ( mpos )
****************************************
   local mrecno := Ctrlinfo->( recno() )
   mpos         := 0
   Ctrlinfo-> (dbgotop())
   Ctrlinfo-> (dbeval({|| if ( !Ctrlinfo->(deleted())  .and. CTRLINFO->BRCODE+Ctrlinfo->ACCTNO==ACCTMAST->BRCODE+Acctmast->ACCTNO, mpos++, nil )},,;
                      {|| Ctrlinfo->(recno())!= mrecno .and. !Ctrlinfo->(eof()) }))
   mpos++
return nil
**********************************************************
*
static function get_appfreq(mappfreqchoices,mappfreq,mrow)
**********************************************************
   mappfreq  := gen_achoice  ( mappfreqchoices, val( mappfreq ), 'App. Freq. ', mrow+1, 56, mrow+1+len (mappfreqchoices), 77, 'w/gr+,w/n,,,w/gr+' )
   @ mrow, 59 say dispappfreq( mappfreq ) color 'w/gr'
return .f.
******************************************************************
*
static function get_insured( minschoices,minsured,minstring,mrow )
******************************************************************
   local minstr := if(minsured,'1','2')
   if lastkey() != K_ESC
      minstr    := gen_achoice( minschoices, val( minstr ), 'Insured?', mrow+1, 56, mrow+1+len ( minschoices ), 77, 'w/gr+,w/n,,,w/gr+' )
      minsured  := if ( minstr == '1',.t.,.f. )
      minstring := upper( if ( minsured,'Yes   ','Waived'  ) )
      @ mrow, 57 say dispinsured( minsured ) color 'w/gr'
   endif
return .f.
************************************
*
static function chkinscode( minsco )
************************************
   local mscr, getlist := {}, nORD := INSURANC->(INDEXORD())
   LOCAL mINSNME := '', nRECNO := INSURANC->(RECNO())        && RED 033005

   IF INSURANC->(DBSEEK(g_PAR_BRCH+mINSCO))    && RED 033005
      mINSNME := INSURANC->INSNAME+g_PAR_BRCH
   ENDIF

   do while .t.
      mscr := savescreen (,,,)
      center ( 24, 'w+/n', padc( '® Search Insurance Name ¯', 80 ) )
      *lb_lkup('Insuranc', 1, 1, @minsco, 2 , 1, 13, 16, 21, 75, 'W/GR+,W/N,,,W/GR+')     && RED 032305
      __LB_LKUP('INSURANC', 2, 2, @mINSNME, 2 ,10, 1, 13, 13, 21, 75, 'W/GR+,W/N,,,W/GR+',,,,2)
      restscreen ( ,,,, mscr )
      *@ 15, 62 say upper( left(dispinsname(minsco),16) ) color 'w/gr'           && RED 033005

      mINSCO := INSURANC->INSCODE
      @ 15, 62 SAY LEFT(mINSNME,16)  COLOR 'W/GR'

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

   INSURANC->(DBSETORDER(1))     && RED 032305

return .f.
/*
***************************************
*
static function dispinsured(minsured)
***************************************
return upper( if( minsured,'Yes   ', 'Waived' ) )
*/
******************************************************
*
static function chkasetcode  ( masetcode, mrow, mcol )
******************************************************
   local mcolor := setcolor(), mscreen := savescreen( ,,, )
   center ( 24, 'w+/n', padc( '® Select Asset Name ¯', 80 ) )
   lb_lkup('Asetcode',1,1,@masetcode, 2 , 1, 10, 12, 22, 75, 'W/GR+,W/N,,,W/GR+')
   restscreen( ,,,, mscreen )
   if masetcode != '12'
	mtctno := 'N.A.'
	mretrno := 'N.A.'
   endif
   @ mrow, mcol+3 say left ( disp_asetname( masetcode ), 13 ) color 'w/gr'
return .f.
*************************************************
*
static function disp_asetname ( masetcode )
*************************************************
   Asetcode->( dbseek ( masetcode ) )
return upper( Asetcode->ASETNAME )
*
*                     End of the Program ( amsm400d.prg )
*
