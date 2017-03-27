/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   program id.........:  amsm400h.prg                                         ³
³   description........:  Schedule of payments generation (availments)         ³
³   author.............:  Ariel B. Bulan                                       ³
³   date...............:  2:52pm 18-Nov-1994                                   ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                         U P D A T E S                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        Who        ³     When      ³               Why                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        aga        ³  14.02.2007   ³ neo paysked support for modules          ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include "Colf.ch"
#include "Inkey.ch"
*****************************************
function gen_sked ( mwhat )
*****************************************
   local mdbf := savedbf(mdbf), mcolor := setcolor() , mscr := savescreen( ,,, ) 
   local mterm := Acctmast->TERM, mamort := Acctmast->AMORT, mprincipal := Acctmast->PRINCIPAL
   local mcredamt := Acctmast->CREDAMT, mstep := 0

   if !chkpass( procname(),ax_level,g_user_id )
      return nil
   endif
   center( 24, 'w+*/n', '® Generating Schedule of Payment... ¯' )
   if Facility->SETCODE $ '1234'
      if Acctmast->PAYFREQ $ '123456'
         del_old_sked()
      endif
      do case
         case Acctmast->PAYFREQ == '1'            // Monthly
              mstep  := 1
         case Acctmast->PAYFREQ == '2'            // Bi-monthly
              mstep  := 2 ; mterm  /= 2 ; mamort *= 2
         case Acctmast->PAYFREQ == '3'            // Quarterly
              mstep  := 4 ; mterm /= 4    ; mamort *= 4
         case Acctmast->PAYFREQ == '4'            // Semi-Annual
              mstep  := 6 ; mterm /= 6    ; mamort *= 6
         case Acctmast->PAYFREQ == '5'            // Annual
              mstep  := 12; mterm /= 12   ; mamort *= 12
         case Acctmast->PAYFREQ == '6'            // Lumpsum
              update_skedfile ( ACCTMAST->BRCODE+Acctmast->ACCTNO,1,Acctmast->MATDATE,Acctmast->CREDAMT-Acctmast->PRINCIPAL,Acctmast->PRINCIPAL)
         case Acctmast->PAYFREQ == '7'            // Irregular
              if mwhat != 'A'
                 if confirm ( 'Erase all Previous Schedule of Payment?' )
                    del_old_sked()
                 endif
              endif
              browse_schedule( ACCTMAST->BRCODE+Acctmast->ACCTNO )
      endcase
   else
      do case
         //aga.19.05.2008.ipp monthly patch for acctmast
         /*
         case Acctmast->PAYFREQ == '1'            // Monthly
              if mwhat != 'A'
                 del_old_sked()
              end if

              mstep  := 1
              create_sked( mterm,mamort,mprincipal,mcredamt,mstep )
              error ( 'Schedule Generated...' )
         */
         //..............................

         case Acctmast->PAYFREQ == '6'            // Lumpsum
              del_old_sked()
              update_skedfile ( ACCTMAST->BRCODE+Acctmast->ACCTNO,1,Acctmast->MATDATE,Acctmast->CREDAMT-Acctmast->PRINCIPAL,Acctmast->PRINCIPAL)
         case Acctmast->PAYFREQ == '7'            // Irregular
              if mwhat != 'A'
                 if confirm ( 'Erase all Previous Schedule of Payment?' )
                    del_old_sked()
                 endif
              endif
              browse_schedule( ACCTMAST->BRCODE+Acctmast->ACCTNO )
      endcase
   endif

   if !(Acctmast->PAYFREQ $ '67')
      create_sked( mterm,mamort,mprincipal,mcredamt,mstep )
      error ( 'Schedule Generated...' )
   endif

   restdbf(mdbf);setcolor(mcolor);restscreen(,,,,mscr)
return nil
*********************************************************************
static function create_sked( mterm,mamort,mprincipal,mcredamt,mstep )
*********************************************************************
    local i, mdivisor, macctno := ACCTMAST->BRCODE+Acctmast->ACCTNO, mpaydate := Acctmast->FIRSTDUE
    local mtermunit := Acctmast->TERMUNIT, mpaynumber := 0, mintamt, mprnamt, mosbal, moldmdays

    moldmdays  := day ( mpaydate )
    reckon_1stOSBAL( mintamt,mprnamt,mterm,mamort,mprincipal,mcredamt,@mosbal,@mdivisor )      //calls the function on amst100e
    for i:= mterm to 1 step-1
        mpaynumber++
        reckon_succOSBAL( @mintamt ,@mprnamt  ,i,mamort,mprincipal,mcredamt,@mosbal,mdivisor )    //calls the function on amst100e
        update_skedfile ( macctno  ,mpaynumber,mpaydate,mintamt,mprnamt,mosbal )
        reckon_paydate  ( @mpaydate,mtermunit ,mstep )
        if ( month(mpaydate)-1 ) == 2    // February ???
           mpaydate := ctod ( str(month(mpaydate),2,0)+'/'+str(moldmdays,2,0)+'/'+str(year(mpaydate),4,0) )
        endif
    next i

return nil
*****************************************************************
static function reckon_paydate ( mpaydate,mtermunit,mstep )
*****************************************************************
    local  mmonth := month ( mpaydate ) , myear  := year ( mpaydate )
    local  mdays  := day   ( mpaydate ) , i

    do case
       case mtermunit == '1'   // days
            mpaydate++
       case mtermunit == '2'   // months
            mmonth += mstep
            if mmonth > 12
               myear++
               if( mstep==12, mmonth-=12 ,mmonth:=mstep )
            endif
            if mmonth == 2                         // February ???
               if is_leap(myear)                   // 29 ???
                  mdays       := if( mdays>28,29,mdays )
               else
                  mdays := if( mdays>=28,28,mdays )
               endif
            endif
            mpaydate := ctod( ltrim( str( mmonth, 2, 0 ) ) + '/' +;
                              ltrim( str( mdays , 2, 0 ) ) + '/' +;
                              ltrim( str ( myear, 4, 0 ) ) )
    endcase

return .t.
******************************************************************************
static function update_skedfile( macctno,mpaynumber,mpaydate,mintamt,mprnamt )
******************************************************************************
   do while isholiday ( mpaydate )  ; mpaydate-- ; enddo  //Sat.|Sun.|Holidays?
   if mpaydate != Acctmast->MATDATE
   endif
   MSGWIN(12,35,'Saving','w+/bg','r*/bg','on')
   if Paysked->(netlock('A',0))
//aga.04.09.2006.new fields for new sked
      Paysked->ACCTNO    := RIGHT(macctno,14)
      Paysked->PAYNUM    := mpaynumber
      Paysked->PAYDATE   := mpaydate
      Paysked->INTAMT    := mintamt
      Paysked->PRNAMT    := mprnamt
      PAYSKED->BRCODE    := LEFT(mACCTNO,3)
      PAYSKED->status    := 'D'
      Paysked->(dbcommit())
      Paysked->( dbunlock() )
   endif
   MSGWIN(12,35,'Saving','w+/bg','r*/bg','on')
return nil

/********* pepe 11:36 AM 8/1/2008 new {function browse_schedule}


***************************************************
//function browse_schedule( _macctno, misfromsubmenu )      //called form amsm0400b - sec_menu
function browse13_schedule( _macctno, misfromsubmenu )
***************************************************
local cb, mdbf_, mswitch := .t., mcolor := setcolor() 
local keys_  := { '<Ins>\-Add ', '<F2>\Edit ', '<F3>\Color ', '<Del>\ ', '<Esc>\' }, mscreen := savescreen( ,,, )

local tbcol_ := { tbcolumnnew( padr( "Pay't N§"      , 10 ), { || tran( Paysked->paynum , '@R 999'            ) } ),;
                  tbcolumnnew( padr( "Pay't Date"    , 10 ), { || tran( Paysked->paydate, '@D'                ) } ),;
                  tbcolumnnew( padr( "Amort/Rental"  , 15 ), { || tran( Paysked->Amtdue  , '99,999,999,999.99' ) } ) }
                  
memvar tbkill_lastrec, ax_level, g_user_id

//aga.15.05.2006.marked for modification

dbselectarea('Paysked')
Paysked->( dbsetorder(1) )

private mis_add_one := Paysked->( dbseek( _macctno,.f.) ), macctno := _macctno+'D'

mdbf_ := savedbf()   
tbkill_lastrec := 1                              

waiton( 'wait a second, please!',, 'n/w' )   

dbselectar( "Paysked" )
Paysked->( dbseek( tbkill_code := macctno) )
Paysked->( dbeval( { || tbkill_lastrec++, mswitch := .f. },, { || PAYSKED->BRCODE+Paysked->acctno+'D' == macctno } ) )

waitoff()  


if mswitch
   if !mis_add_one
      error( "No Record Found!" )
      IF CURRBRCH(LEFT(mACCTNO,3))
         __keyboard( chr( K_INS ) )
      ENDIF
   endif   
endif  

Paysked->( dbseek( tbkill_code := macctno,.f. ) )



mblock := { | x | PAYSKED->BRCODE+Paysked->ACCTNO+'D' == x  .and. paysked->status == 'D'} //new mblock for D status limit
    //tb_maker( tbcol_, key_, mtop, mleft, mbottom, mright, mbanner, mlastrec, mdisplay,       mcode, mblock, atop, aleft, abottom, aright )
cb := __tb_maker( tbcol_, keys_,   6,     2,      18,     59,        ,         ,      .f., macctno, mblock,     ,      ,        ,       ,)


Paysked->( __tb_stabilize( cb, { | o, k | caseh400( o, k ) } ) )//Paysked->( tb_stabilizer( cb, { | o, k | caseh400( o, k ) } ) )


//.....................................

// Update_image( _macctno )
restdbf( mdbf_ )                             
setcolor( mcolor )
restscreen( ,,,, mscreen )
return( nil )

*********/


/*--------------------------------------*/
 Static Function Update_image( macctno )
/*--------------------------------------*/
local nsel := select(), mmage := Payimage->(indexord())
local tot_amt := 0

Paysked->(dbseek( macctno ))
Paysked->(dbeval({|| tot_amt += Paysked->Amort },,{|| PAYSKED->BRCODE+Paysked->Acctno == macctno }))
if round( tot_amt,2) == round( Acctmast->Credamt,2)
   dbselectarea('Payimage')
endif

return nil

/********* pepe 11:36 AM 8/1/2008 new {function browse_schedule}

*****************************************
*
static function caseh400( mbrowse, mkey )
*****************************************
local misfromsubmenu := mreturn := .t., mcolor := setcolor(), mscreen := savescreen( ,,, )	
local msum := 0 ,mosbal := 0
memvar mis_add_one, ax_level, g_user_id, macctno


misfromsubmenu := if ( mis_add_one, .f., misfromsubmenu )


//aga.15.05.2006.marked for modification.
do case
   case mkey == K_ESC

        if !prnamt_equal_to_principal(@msum,@mosbal)
           // alert("Kage Bunshin no Jutsu")
           if esckey( 'Sked Total '    +alltrim(trans(msum  ,"999,999,999.99"))+;
                      ' is <> to Osbal '+alltrim(trans(mosbal,"999,999,999.99"))+',Exit anyway?' )
              mreturn := !mreturn
           endif

        else  
           mreturn := !mreturn  
        endif

   case mkey == K_INS

        if CURRBRCH(LEFT(mACCTNO,3)) .AND. chkpass( 'A', ax_level, g_user_id )
           if payment_sked( 'A', misfromsubmenu )
              tb_refresh( mbrowse, 'a' )
           endif
        endif      
   case mkey == K_F2

        if CURRBRCH(PAYSKED->BRCODE) .AND. chkpass( 'E', ax_level, g_user_id )
           if PAYSKED->BRCODE+Paysked->acctno+'D' != macctno
              error( 'Nothing to Edit!' )
              Paysked->( dbseek( macctno ) )
           else  
              if payment_sked( 'E', misfromsubmenu )
                 tb_refresh( mbrowse, 'c' )
              endif
           endif
        endif    
   case mkey == K_DEL

        if CURRBRCH(PAYSKED->BRCODE) .AND. chkpass( 'D', ax_level, g_user_id )
           if PAYSKED->BRCODE+Paysked->acctno+'D' != macctno
              error( 'Nothing to Delete!' )
              Paysked->( dbseek( macctno ) )
           else 
              if confirm( 'Delete Payment N§ ' + trim( tran( Paysked->paynum, '@R 999' ) ) + '?' )
                 Paysked->( netlock( 'R', 0 ) )
                 Paysked->( dbdelete() )
                 Paysked->( dbskip( +1 ) )
                 if PAYSKED->BRCODE+Paysked->acctno+'D' != macctno
                    Paysked->( dbseek( macctno ) )
                 endif

                 tb_refresh( mbrowse, 'a' )
              endif
           endif
        endif   
   otherwise        
        mreturn := !mreturn
endcase         
//..........................


setcolor( mcolor )
restscreen( ,,,, mscreen )
return( mreturn )

*********/

*************************************************
 Static function prnamt_equal_to_principal(msum,mosbal)
*************************************************
   local mrecno  := Paysked->(recno()),mAmrtotal:=0
   local mretval := .t.

//aga.15.05.2006.marked for modification
   Paysked->(dbseek(ACCTMAST->BRCODE+Acctmast->ACCTNO+'D'))
   Paysked->(dbeval({|| mAmrtotal+=Paysked->Amtdue },,{||!Paysked->(eof()) .and. PAYSKED->BRCODE+Paysked->ACCTNO==ACCTMAST->BRCODE+Acctmast->ACCTNO .and. Paysked->status == 'D'}))

   if ( tran( round( mAmrtotal        , 0 ), '9,999,999,999.99' ) <> ;
        tran( round( Acctmast->osbal  , 0 ), '9,999,999,999.99' ),;
        mretval := .f.,;
        nil ;
      )

   msum   := mamrtotal
   mosbal := acctmast->osbal

   Paysked->(dbgoto(mrecno))
//......................................

return mretval
*************************************
static function payment_sked( mwhat,misfromsubmenu)
*************************************
   local mrecno    := Paysked->(recno()), mscr := savescreen(,,,)
   local mcursor   := setcursor(), mcolor := setcolor(), mmess
   local mcontinue := .t., mpaynumber, mpaydate, mamort
   local mrow      := 13, mcol := 4, mretval := .f., getlist := {}

   //aga.06.12.2005.new param
   local tpaydate, tamort
   //..................................

   misfromsubmenu := if ( misfromsubmenu==nil, .f. , misfromsubmenu )
   mcol := if(!misfromsubmenu,mcol+=12,mcol)


//aga.15.05.2006.marked for modification
   if(upper(mwhat)==chr(65),Paysked->(dbgoto(lastrec()+1)),mwhat:=chr(82))

   mmess := if(upper(mwhat)==chr(65),'® Add Record ¯','® Edit Record ¯')

   eval({|| mpaynumber := Paysked->PAYNUM, mpaydate := Paysked->PAYDATE,;
            mAmort     := Paysked->Amtdue  })

   center( 24, 'w+/n',mmess )
   fshadow ( mrow,mcol,mrow+4,mcol+37,2,'n/bg' )
   setcolor( 'w/bg, n+/w,,, w+/bg' )
   do while mcontinue
      @ mrow+1,mcol+1 say '      Payment N§ ' get mpaynumber pict '999' when (mwhat=='A') valid chkmpaynumber( mpaynumber )
      @ mrow+2,mcol+1 say '    Payment Date ' get mpaydate   pict '@D'  valid checkmpaydate( mwhat, mpaydate )
      @ mrow+3,mcol+1 say '    Amort/Rental ' get mAmort     pict '99,999,999,999.99' valid mAmort >= 0
      setcursor( 3 )
      read
      setcursor( 0 )
      if lastkey() == K_ESC
         if esckey()
            mcontinue := .f.
         endif   
         loop
      endif
      if lastkey() == K_ENTER
         if confirm( 'Are all entries correct?' )
            MSGWIN(14,23,'Saving','w+/bg','r*/bg','on')
            if Paysked->( netlock( mwhat, 0 ) )

               //aga.06.12.2005.save the former values
               tpaydate := Paysked->PAYDATE 
               tamort   := Paysked->AMTDUE   
               //.........................

               eval( { || Paysked->ACCTNO  := Acctmast->ACCTNO,;
                          Paysked->PAYNUM  := mpaynumber      ,;
                          Paysked->PAYDATE := mpaydate        ,;
                          Paysked->amtdue  := mamort          ,;
                          Paysked->status  := 'D'             ,;
                          PAYSKED->BRCODE  := ACCTMAST->BRCODE } )
               Paysked->( dbcommit() ) 
               Paysked->( dbunlock() )
            endif

            //aga.02.12.2005.marker payimage insertion
            if (Paysked->PAYDATE != tpaydate      ,drop ( alltrim(g_user_id)+' '+'Edits '+ substr(Acctmast->acctno,-5,5) + " " + alltrim(str(Paysked->PAYNUM)) + " sked payment from " + dtos(tpaydate)  + " to " + dtos(Paysked->PAYDATE)),)  
            if (Paysked->AMTDUE  != tamort        ,drop ( alltrim(g_user_id)+' '+'Edits '+ substr(Acctmast->acctno,-5,5) + " " + alltrim(str(Paysked->PAYNUM)) + " sked amort from "   + str(tamort)     + " to " + str(Paysked->AMTDUE)),)  
            //.............................

            MSGWIN(14,23,'Saving',,,'oFF')
            mrecno:= Paysked->(recno()) ; mcontinue := .f. ; mretval := .t.
         endif
      endif
   enddo
   Paysked->(dbgoto(mrecno))
//...................................

   setcursor  (mcursor )
   setcolor   (mcolor  )
   restscreen (,,,,mscr)
return (mretval)
*****************************************
static function checkmpaydate( mwhat, mpaydate )
*****************************************
   local mretval := .t., mrecno := Paysked->( recno() )
   do case
      case lastkey()==K_ESC .or. empty( mpaydate )
           mretval := .f.
      case Acctmast->FIRSTDUE > mpaydate
           error ( 'Due Date is ">" Payment Date.' )
           mretval := .f.
      case Acctmast->MATDATE  < mpaydate
           error ( 'Payment Date is ">" Maturity Date.' )
           mretval := .f.

//aga.15.05.2006.marked for modification
      case eval( { || Paysked->( dbseek( ACCTMAST->BRCODE+Acctmast->acctno+'D') ),                 ;
                      Paysked->( dbeval( { || nil },, { || ACCTMAST->BRCODE+Acctmast->acctno == ;
                      PAYSKED->BRCODE+Paysked->acctno .and. Paysked->paydate != mpaydate .and. Paysked->status == 'D'} ) ),;
                      if( upper(mwhat) == 'A', Paysked->paydate == mpaydate,.f. ) } )
           error ( 'Duplicate Payment Date!' )
           mretval := .f.
//.............................

   endcase
   Paysked->( dbgoto(mrecno) )
return (mretval)

***************************************************
static function chkmpaynumber( mpaynumber,macctno )
***************************************************
   local mretval := .t. , mrecno := Paysked->(recno())
   if lastkey() == K_ESC .or. empty( mpaynumber )
      return .f.
   endif

//aga.15.05.2006.marked for modification
   Paysked->( dbseek( ACCTMAST->BRCODE+Acctmast->acctno+'D',.f. ) )
   Paysked->( dbeval({||nil},, {|| ACCTMAST->BRCODE+Acctmast->acctno == PAYSKED->BRCODE+Paysked->acctno .and. Paysked->PAYNUM!=mpaynumber.and. Paysked->status == 'D'}) )
   if Paysked->PAYNUM == mpaynumber .and. PAYSKED->BRCODE+Paysked->Acctno == ACCTMAST->BRCODE+Acctmast->Acctno .and. Paysked->status == 'D'
      error ( 'Payment N§ already Exists!' )
      mretval := .f.
   endif
   Paysked->(dbgoto(mrecno))
//.....................................

return mretval

*****************************************
static function del_old_sked()
*****************************************

//aga.15.06.2006.marked for modification
   Paysked->( dbseek( ACCTMAST->BRCODE+Acctmast->ACCTNO+'D' ) )
   Paysked->( dbeval( {|| Paysked->(netlock('R',0)),Paysked->(dbdelete()),Paysked->(dbunlock()) },,;
                      {|| !Paysked->(eof()) .and. PAYSKED->BRCODE+Paysked->ACCTNO==ACCTMAST->BRCODE+Acctmast->ACCTNO .and. Paysked->status == 'D' }))

//....................................

return nil


*
*                    End of the Program ( amst400h.prg )
*


**************************************************
*
function browse_schedule(_macctno,misfromsubmenu )
**************************************************
local mcolor  := setcolor(), mscreen := savescreen( ,,, ), mm := INDEXORD(),zz := ALIAS()
private macctno := _macctno, NCTR := 0
private mfsubmenu := misfromsubmenu, mreturn := .t.

 aTranrecs := {}
 aTranpos  := {}
 _APalmSec := {}
 //aRECNO    := {}

 if !PAYSKED->(dbseek(macctno))
      error( "No Record Found!" )
      IF CURRBRCH(LEFT(mACCTNO,3))
         __keyboard( chr( K_INS ) )
      ENDIF
 endif

 fShadow( 6, 2, 18, 47, 2, 'w+/g' ) //w+/GR

 dbselectarea('PAYSKED')

 PAYSKED->(dbseek(macctno+'D'))

 GBrows_schedule()
 
     setcolor ( 'i/gr, w+/bg' )

     @ 7,3 say  "  Pay't N§     Pay't Date     Amort/Rental"    color 'w+/g'
	 @ 8,3 say  "ÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"  color 'w+/g'
	 
     do while .t.
	 
      fShadow( 6, 2, 18, 47, 2, 'w+/g' ) //w+/GR
	  @ 7,3 say  "  Pay't N§     Pay't Date     Amort/Rental"    color 'w+/g'
	  @ 8,3 say  "ÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"  color 'w+/g'
	  
      mBX := achoice(9, 3, 17, 46, aTranRecs, .t.,'caseh400')

      do case
         case lastkey() == K_ESC
		      if !mreturn
                 exit
			  endif
			  
         case lastkey() == K_ENTER
		      if !mreturn
                 exit
			  endif
  
      endcase

    restscreen     ( 9, 3, 17, 46, mscreen )
	
     enddo

    setcolor       ( mcolor )
    restscreen     ( ,,,, mscreen )
	
DBSELECTAREA(ZZ)
DBSETORDER(mm)

return mBX

**************************************
*
STATIC FUNCTION GBrows_schedule()
**************************************

NCTR := 0

  dbselectarea('PAYSKED')

     PAYSKED->(dbseek(macctno+'D'))
//	 PAYSKED->(dbGOTO(mRECNO))
      do while PAYSKED->BRCODE+PAYSKED->acctno+PAYSKED->status == macctno+'D' .and. ;
		      !PAYSKED->(eof()) 

		       nctr++
			   
        	    aadd ( aTranRecs,  padr(' ',' ')   		+ '   ' +   ;
                           trans ( PAYSKED->Paynum,"999")        	+ '     ³   ' +  ;
                           padr  ( PAYSKED->Paydate,10)		        + '  ³ ' +  ;
                           trans ( PAYSKED->Amtdue,"999,999,999.99")       ;
              	         )

		        aadd ( _APalmSec,PAYSKED->brcode+PAYSKED->acctno+PAYSKED->status+dtos(PAYSKED->Paydate)+str(PAYSKED->Paynum))

      PAYSKED->(dbskip(+1))
      enddo
	  
	  if nctr == 0
        	    aadd ( aTranRecs,  padr(' ',' ')   		+ '   ' +   ;
                           trans ( PAYSKED->Paynum,"999")        	+ '     ³   ' +  ;
                           padr  ( PAYSKED->Paydate,10)		        + '  ³ ' +  ;
                           trans ( PAYSKED->Amtdue,"999,999,999.99")       ;
              	         )

		        aadd ( _APalmSec,PAYSKED->brcode+PAYSKED->acctno+PAYSKED->status+dtos(PAYSKED->Paydate)+str(PAYSKED->Paynum))
	  endif
	  
RETURN 0

****************************************************
*
FUNCTION caseh400 (status, curr_elem, curr_row)
****************************************************
local key    := lastkey(),mSAY,cSRCH := space(10)
local __nctr := 0, getlist := {}, menulist := {},nORGPOS := 0
local _lfound := .f., mscreen1 := savescreen1( ,,, ), INDKEY := INDEXORD()
local msum := 0 ,mosbal := 0

   do case
      case key == K_ESC
        if !prnamt_equal_to_principal(@msum,@mosbal)
           // alert("Kage Bunshin no Jutsu")
           if esckey( 'Sked Total '    +alltrim(trans(msum  ,"999,999,999.99"))+;
                      ' is <> to Osbal '+alltrim(trans(mosbal,"999,999,999.99"))+',Exit anyway?' )
              mreturn := !mreturn
           endif
        else
           mreturn := !mreturn  
        endif
	  
         return mreturn//0

      case key == K_INS

        if CURRBRCH(LEFT(mACCTNO,3)) .AND. chkpass( 'A', ax_level, g_user_id )
           if payment_sked( 'A', mfsubmenu )
		      aTranrecs := {}
              _APalmSec := {}
              GBrows_schedule()
           endif
        endif 
	
	return 1

   case key  == K_F2
   
        __mseekvar := _APalmSec[curr_elem]
   
        //if CURRBRCH(PAYSKED->BRCODE) .AND. chkpass( 'E', ax_level, g_user_id )
		if CURRBRCH(LEFT(mACCTNO,3)) .AND. chkpass( 'E', ax_level, g_user_id )  //PEPE 10:51 AM 5/31/2012
           if !PAYSKED->(dbseek(__mseekvar))                        // PAYSKED->BRCODE+Paysked->acctno+'D' != macctno
              error( 'Nothing to Edit!' )
              Paysked->( dbseek( macctno ) )
           else  
              if payment_sked( 'E', mfsubmenu )
                 aTranrecs := {}
                 _APalmSec := {}
                 GBrows_schedule()
              endif
           endif
        endif    
		
		return 1
		
   case key  == K_DEL
   
   	    __mseekvar := _APalmSec[curr_elem]

        //if CURRBRCH(PAYSKED->BRCODE) .AND. chkpass( 'D', ax_level, g_user_id )
        if CURRBRCH(LEFT(mACCTNO,3)) .AND. chkpass( 'D', ax_level, g_user_id )   //PEPE 10:51 AM 5/31/2012
           if !PAYSKED->(dbseek(__mseekvar))                        // PAYSKED->BRCODE+Paysked->acctno+'D' != macctno
              error( 'Nothing to Delete!' )
              Paysked->( dbseek( macctno ) )
           else 
              if confirm( 'Delete Payment N§ ' + trim( tran( Paysked->paynum, '@R 999' ) ) + '?' )
                 Paysked->( netlock( 'R', 0 ) )
                 Paysked->( dbdelete() )
                 Paysked->( dbskip( +1 ) )
                 if PAYSKED->BRCODE+Paysked->acctno+'D' != macctno
                    Paysked->( dbseek( macctno ) )
                 endif
                 aTranrecs := {}
                 _APalmSec := {}
                 GBrows_schedule()
              endif
           endif
        endif   

		return 1

    endcase

RETURN  2
