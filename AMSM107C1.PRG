/*
 ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³   PROGRAM ID.........:  amsm100h.prg                                 ³
 ³   Description........:  credit application printing                  ³
 ³   Author.............:  Ariel B. Bulan                               ³
 ³   Date...............:  08:56am 25-Aug-1994                          ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³                         U P D A T E S                                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³        Who        ³     When      ³               Why                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³ Gener C. Singson  ³  08-Mar-1996  ³ printing overhaul                ³
 ³ Janet L. Bautista ³  02-Apr-1996  ³ because the Old Maid did not     ³
 ³                   ³               ³ finish the program & to follow   ³
 ³                   ³               ³ standard coding structure        ³
 ³ Renan Evangelista ³  25-May-1996  ³ as what the 'Old Maid' did       ³
 ³ Janet L. Bautista ³  10-Sep-1997  ³ gd, rv to 5 decimal places       ³
 ³                   ³               ³                                  ³
 ³ Noel B. Santos    ³  18-Sep-2001  ³ suppress liabilities section from³
 ³                   ³               ³ appearing when outstanding debt  ³
 ³                   ³               ³ is zero.                         ³
 ³ abb               ³ 10.27.2004    ³      online                      ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

////
#defin begin_caprint { | p_, c_, a_, o_, t_ |beg_caprint( p_, c_, a_, o_, t_ ) }
#defin sound_bad     tone( 480, 0.25 ); tone( 240, 0.25 )
#xtran gettrantype   ( <cnum> ) => if( <cnum> == '1'  , 'Revolving', 'Special' )
#xtran getpaytype    ( <cnum> ) => if( <cnum> == '1'  , 'In Advance', 'In Arrears' )
#xtran getratetype   ( <cnum> ) => if( <cnum> == '1'  , 'Fixed', 'Floating' )
#xtran gettermunit   ( <cnum> ) => if( <cnum> == '1'  , 'Day(s)', 'Month(s)' )
#xtran getnotifition ( <cnum> ) => if( <cnum> == '1'  , 'With', 'Without' )
#xtran getcollection ( <cnum> ) => if( <cnum> == '1'  , 'Ours', 'Theirs' )
#xtran getrecourse   ( <cnum> ) => if( <cnum> == '1'  , 'With', 'Without' )
#xtran getcredrisk   ( <cnum> ) => if( <cnum> == 'I'  , 'Current    ',;
                                   if( <cnum> == 'II' , 'Watchlist  ',;
                                   if( <cnum> == 'III', 'Substandard',;
                                   if( <cnum> == 'IV' , 'Doubtful   ',;
                                   if( <cnum> == 'V'  , 'Loss       ', '           ' ) ) ) ) )
#xtran getpayfreq    ( <cnum> ) => if( <cnum> == '1'  , 'Monthly',;
                                   if( <cnum> == '2'  , 'Bi-Monthly',;
                                   if( <cnum> == '3'  , 'Quarterly',;
                                   if( <cnum> == '4'  , 'Semi-Annual',;
                                   if( <cnum> == '5'  , 'Annual',;
                                   if( <cnum> == '6'  , 'Lumpsum', 'Irregular' ) ) ) ) ) )

////
#include 'inkey.ch'
#include 'colf.ch'

////
*************************
*
function caprint()
*************************
local mhead_  := {}, propfc_ := {}, unavca_ := {}, unavcg_ := {}
local unavot_ := {}, unavog_ := {},xx,zzz,mgroup
local xbreak, mline, mhead, mdbf_ := savedbf()
local mtrue, s := 1, c := 1, motnum:={}, mcanum:={},cnt:=1
local re:= Caheader->(recno()),es:=Cadetail->(recno()),weng
memvar mtotblnc,mtotcrdt,appray_,appray2_,mcomname,mcomname2
private mleftbal := 0, mrightbal := 0,gen_term:=.t.,npending := 0
private sw:=.f.,ctr:=0,npage:=1,mclient
begin sequence

    //ÄÄÄheadingÄÄÄ0
    setfont('PICA')
    SETFONT('CONDENSED')
    head1(@mclient)

    //ÄÄÄproposed facilitiesÄÄÄ1
         aeval ( include(,@weng), { |mray_| actual_p(mray_,1) } )
         weng := if( weng == nil,'XXXX',weng )

         if !gen_term
            set device to screen
            set console on
            break
         endif


    //ÄÄÄunavailed ca lineÄÄÄ2

         mcanum := {}

         if chkclntactaken( , @mline, @mhead, @mcanum,weng )
            
            for xx := 1 to len(mcanum)

              if mcanum[xx] <> Caheader->canumber

                mhead  := alltrim;
                      (getclntname( 'xxxxx' ) +;
                      if( Caheader->linetype == '1', ' Omnibus', ' Regular' ) +;
                         ' Line CA N§ ' + mcanum[xx] )

              endif

              aeval ( include2 ( mcanum[xx],mhead,@sw,@ctr,@mline),;
                      { |mray_| actual_p2(mray_,mline) } ;
                    )
              
            next xx

         endif



    //ÄÄÄunavailed ca line of group membersÄÄÄ3
        
        for xx:= 1 to len( mgroup:=chkgrpcode() )

             mcanum := {}

             if chkclntactaken( mgroup[xx],@mline,@mhead,@mcanum,weng )
                for zzz:= 1 to len(mcanum)
                     aeval( include2( mcanum[zzz],mhead,@sw,@ctr,@mline,mgroup[xx]), ;
                     { | i_ | actual_p2(i_,mline)  } )

                next zzz
            endif
			
        next xx


    //ÄÄÄunavailed otÄÄÄ4
         sw := .f.
         ctr:=  0
         cnt:=  0
         if chkotktactaken( , @mline, @mhead, @motnum )
            aeval ( exclude( motnum, @sw, @ctr ),;
                    { | i_ | actual_p3( i_, 1,mhead,++cnt )  ;
                    } ;
                  )
         endif


    //ÄÄÄunavailed ot of group membersÄÄÄ5
         cnt:=  0
         aeval ( chkgrpcode(),;
                 { | g_ | ;
                   if ( chkotktactaken ( g_,@mline,@mhead,@motnum ) ,;
                        aeval( exclude( motnum,@sw, @ctr) ,;
                               { | i_ | actual_p3(i_,2,mhead,++cnt) } ;
                              ),;
                        .f. ;
                      );
                 } ;
               )
     sw:= .f.
     ctr:= 0

    //ÄÄÄÄthe Old Maid stopped here...
    //ÄÄÄexisting liabilitiesÄÄÄ6


    aeval( include3(,@sw,@ctr,1), {|mray_| actual_p4(mray_,1) } )


    //ÄÄÄexisting liabilities of group membersÄÄÄ7
			mgroup:=chkgrpcode() 
			 
			OLSMAST->   ( dbsetorder(8) )
			OALPMAST->   ( dbsetorder(8) )
			
			if OLSMAST->( dbseek(CAHEADER->brcode+CAHEADER->clntcode ) ) .or. OALPMAST->( dbseek(CAHEADER->brcode+CAHEADER->clntcode ) )
				aadd(mgroup,CAHEADER->brcode+CAHEADER->clntcode)
			endif
	 
    aeval( mgroup, { | g_ |;
           aeval( include3(g_,@sw,@ctr,2), {|mray_| actual_p4(mray_,1) } );
          } )

lastpage ( mtotblnc,mtotcrdt )
__eject  ( )
recover using xbreak
        if xbreak == nil
           __mxrelease( mleftbal, mrightbal )
        endif
end sequence
restdbf( mdbf_ )
Caheader->( dbgoto(re) )
CAdetail->( dbgoto(es) )
return( nil )
////
////

*************************************
*
static function include(mcanum,weng )                    //create an aray for the proposal
*************************************
local arr_ := {},xCredamTz:= 0,genray_:={},tText         //facility
local nprincipal := 0
mcanum := if( mcanum == nil, Caheader->canumber, mcanum )

Cadetail->( dbsetorder(1) )
Cadetail->( dbseek( Caheader->brcode+mcanum ) )

if eval( { || if( Caheader->Catype <> '4', eval( { || !CADETAIL->(found()) .and. Cadetail->Include == .F. } ),.f.) } ) ;   && RED 013006 ADDED 'CADETAIL->' Another loose programming
   .and. eval( { || if( Caheader->Catype == '1',.t.,.f.) } )
   set device to screen
   Error('Facility entered is not included..Check out')
   break
endif

tText:= if( alltrim(Caheader->Catype) == '1', 'PROPOSED FACILITIES:',  ;
        if( alltrim(Caheader->Catype) == '2', 'REVIEW OF FACILITIES:', ;
        if( alltrim(Caheader->Catype) == '3', 'PROPOSAL AND REVIEW OF FACILITIES:', ;
        if( alltrim(Caheader->Catype) == '4', 'RECLASSIFICATION OF CREDIT RISK:','') ) ) )

hd_fclty (tText)
while Cadetail->(!eof()) .and. Cadetail->Canumber == mCanum .and. ;
      Cadetail->brcode == Caheader->brcode
   if !empty(Cadetail->Fcltycode)
      nprincipal+= Cadetail->principal

      /***************
      aadd ( genray_,{ Cadetail->Fcltycode,;
                       cadetail->Ratetype ,;
                       getosbal(),;
                       getAmt(@xCredamTz),;
                       xCredamTz ;
                     } ;
           )
      ***************/

      aadd ( genray_,{ Cadetail->Fcltycode,;
                       cadetail->Ratetype ,;
                       getosbal (),;
                       getAmt   (@xCredamTz,@nprincipal),;
                       xCredamTz          ,;
                       nprincipal          ;   // 12.23.2002 abb
                     } ;
           )
      weng := mCanum
   endif
   Cadetail->( dbskip() )
enddo

return genray_
/*
************************************
*
Static Function trantyper(xfcl,nca)
************************************
local gf:=savedbf(),ctype:='',bf:=Cadetail->(indexord())
dbselectarea('Cadetail')
Cadetail->(dbsetorder(2))
if Cadetail->( dbseek(Caheader->brcode+nca + xfcl) )
   ctype:=Cadetail->Trantype
endif
restdbf(gf)
Cadetail->(dbsetorder(bf))
return ctype
*/
/////
//para -> clncode<Clntocde>,sw & ctr<switch& counter to print subheader>,rep<group member>

**********************************************
* abb 12.23.2002
*
static function include3( clncode,sw,ctr,rep )                         //Create an array for the
**********************************************
  local arr_ := {},xCredamTz:= 0,nray_:={},mu:=Acctmast->(indexord())
  local xclncode := if( clncode == nil, Caheader->brcode+Caheader->clntcode, clncode )
  local mdbf_ := savedbf(),msetcode,tType,cType
  local __fcltycode := Cadetail->fcltycode

  dbselectarea ( 'Acctmast' )
  Acctmast->   ( dbsetorder(7) )

if clncode != CAHEADER->brcode+CAHEADER->clntcode 
  if Acctmast->( dbseek( xclncode ) )//if Acctmast->( dbseek( Caheader->Brcode+xclncode ) )//

    cType    := Caheader->Catype
    msetcode := eval( {|| Facility->(dbseek(Acctmast->Fcltycode)),Facility->Setcode })
    do while Acctmast->(!eof())             .and. ;
             Acctmast->Clntcode == right(xclncode,7) .AND. ;
             ACCTMAST->BRCODE   == left(xclncode,3) 

      tType := trantyper(Acctmast->Fcltycode,Caheader->Canumber)

//aga.09.01.2005.cap marker

     if ( alltrim(msetcode) # '4' .or. alltrim(msetcode) # '5' ) .and. ;
        ( alltrim (cType) # '2' .or.  alltrim(cType) # '3' )

//...................................

        if !empty ( Acctmast->Fcltycode ) .and. !empty ( Acctmast->Acctno )    // .and. Acctmast->osbal > 0

//===section modified by noels===============================================


          if substr(Acctmast->fcltycode,1,3) == '104' // LOANS 12.23.2002 abb
             nTotBalc := getbalc(right(xclncode,7),.f.)//xclncode
          else
             nTotBalc := getbalc(right(xclncode,7),.f.)//xclncode
          endif



          if nTotBalc > 0 
            aadd( nray_,{ Acctmast->Fcltycode, nTotBalc,getrec(right(xclncode,7)), ACCTMAST->Acctname,'ACCTMAST',ACCTMAST->BRCODE } )
          endif

//===section modified by noels===============================================

        endif
      endif
     acctmast->( dbskip(+1) )
    enddo
  endif
endif

if clncode <> nil
  dbselectarea ( 'OLSMAST' )
  OLSMAST->   ( dbsetorder(8) )

  if OLSMAST->( dbseek( xclncode ) ) 

    cType    := CAHEADER->Catype

    msetcode := eval( {|| Facility->(dbseek(OLSMAST->Fcltycode)),Facility->Setcode })
		do while OLSMAST->(!eof()) .and. OLSMAST->Clntcode == RIGHT(xclncode,7) .AND. ;
				 OLSMAST->BRCODE2 == LEFT(xclncode,3)
		  
			  tType := trantyper(OLSMAST->Fcltycode,CAHEADER->Canumber)
			   
			  if ( alltrim(msetcode) # '4' .or. alltrim(msetcode) # '5' ) .and. ;
				 ( alltrim (cType) # '2' .or.  alltrim(cType) # '3' )
			
				if !empty ( OLSMAST->Fcltycode ) .and. !empty ( OLSMAST->Acctno )

				    nTotBalc := getbalc2(RIGHT(xclncode,7),.F.)

				    if nTotBalc > 0
					   aadd( nray_,{ OLSMAST->Fcltycode, nTotBalc,getrec2(RIGHT(xclncode,7),.T.), OLSMAST->Acctname,'OLSMAST',OLSMAST->BRCODE } )
				    endif
  
				endif
			  endif

		 OLSMAST->( dbskip(+1) )
		enddo

  endif
endif
if clncode <> nil
  dbselectarea ( 'OALPMAST' )
  OALPMAST->   ( dbsetorder(8) )

  if OALPMAST->( dbseek( xclncode ) ) 

    cType    := CAHEADER->Catype

    msetcode := eval( {|| Facility->(dbseek(OALPMAST->Fcltycode)),Facility->Setcode })
		do while OALPMAST->(!eof()) .and. OALPMAST->Clntcode == RIGHT(xclncode,7) .AND. ;
				 OALPMAST->BRCODE2 == LEFT(xclncode,3)
		  
			  tType := trantyper(OALPMAST->Fcltycode,CAHEADER->Canumber)
			   
			  if ( alltrim(msetcode) # '4' .or. alltrim(msetcode) # '5' ) .and. ;
				 ( alltrim (cType) # '2' .or.  alltrim(cType) # '3' )
			
				if !empty ( OALPMAST->Fcltycode ) .and. !empty ( OALPMAST->Acctno )

				    nTotBalc := getbalc2(RIGHT(xclncode,7),.T.)

				    if nTotBalc > 0
					   aadd( nray_,{ OALPMAST->Fcltycode, nTotBalc,getrec2(RIGHT(xclncode,7),.F.), OALPMAST->Acctname,'OALPMAST',OALPMAST->BRCODE } )
				    endif
  
				endif
			  endif

		 OALPMAST->( dbskip(+1) )
		enddo

  endif
endif

if !empty(nray_)
   if !sw .and. ctr < 1
      sw:=.t.
      ctr++
      hd_fclty('EXISTING LIABILITIES:')
   endif
ENDIF

if rep == 2  .and. !empty(nray_)
   chkpage()
   @ prow()+1,0 say '³'+ getclntname( xclncode ) +' '+_getbrch(Client->Brcode)
   @ prow(),97 say '³                   ³                     ³'
endif
Acctmast->(Dbsetorder())
restdbf( mdbf_ )

return nray_

****************************************
*
static function getbalc2(clncode,lloans)
****************************************
local mosbal := 0, mfacil:= OLSMAST->Fcltycode,mfacil2:= OALPMAST->Fcltycode
local nrecno:=OLSMAST->(recno()),nrecno2:=OALPMAST->(recno())

if lloans

   OALPMAST ->;
           (dbeval( {|| if ( OALPMAST->status <> '4' .and. ;
                             OALPMAST->status <> '5' .and. OALPMAST->status != '0',;
                             mosbal += OALPMAST->Osbal,;
                             nil ;
                           ) ;
                    } ,, ;
                    {|| OALPMAST->(!eof())            .and. ;
                        OALPMAST->Fcltycode == mfacil2 .and. ;
                        OALPMAST->Clntcode  == Clncode  ;
                    } ;
                  );
           )
		   
   
else
   OLSMAST ->;
           (dbeval( {|| if ( OLSMAST->status <> '4' .and. ;
                             OLSMAST->status <> '5' .and. OLSMAST->status != '0',;
                             mosbal += OLSMAST->Osbal,;
                             nil ;
                           ) ;
                    } ,, ;
                    {|| OLSMAST->(!eof())            .and. ;
                        OLSMAST->Fcltycode == mFacil .and. ;
                        OLSMAST->Clntcode  == Clncode  ;
                    } ;
                  );
           )
endif

OLSMAST->(dbgoto(nrecno))
OALPMAST->(dbgoto(nrecno2))
return ( mosbal )

*************************************
*
static function getrec2(clncode,lCODE)                               //Generate array of record nos. to be printed
*************************************
local arr_ := {}, mfclty := OLSMAST->fcltycode,mfclty2 := OALPMAST->fcltycode, xbreak

IF lCODE
 OLSMAST->( dbeval( { || if( OLSMAST->Status <>  '4' .and. OLSMAST->Status <>  '5' ;
                     ,aadd( arr_, OLSMAST->( recno() ) ),.f.) },,;
                     { || OLSMAST->Clntcode == clncode .and.;
                            OLSMAST->fcltycode == mfclty } ) )
							
 if !empty(arr_)
    OLSMAST->( dbskip( -1 ) )
 endif
ELSE
 OALPMAST->( dbeval( { || if( OALPMAST->Status <>  '4' .and. OALPMAST->Status <>  '5' ;
                     ,aadd( arr_, OALPMAST->( recno() ) ),.f.) },,;
                     { || OALPMAST->Clntcode == clncode .and.;
                            OALPMAST->fcltycode == mfclty2 } ) )
							
 if !empty(arr_)
    OALPMAST->( dbskip( -1 ) )
 endif
ENDIF

return (arr_)

*************************************
*
static function getrec(clncode)                               //Generate array of record nos. to be printed
*************************************
local arr_ := {}, mfclty := Acctmast->fcltycode, xbreak
 Acctmast->( dbeval( { || if( Acctmast->Status <>  '4' .and. Acctmast->Status <>  '5' .and. Acctmast->status != '0'; //RLV ;
                     ,aadd( arr_, Acctmast->( recno() ) ),.f.) },,;
                     { || Acctmast->Clntcode == clncode .and.;
                            Acctmast->fcltycode == mfclty } ) )
if !empty(arr_)
   Acctmast->( dbskip( -1 ) )
endif
return (arr_)
////
//
// para -> canumber, header<Omni./Reg.>,switch<if 'UNAVAILED CREDIT LINE:' was printed>,counter<count for
//         group members' facility occurences>,linetype< for group members/current >
//
**********************************************************
*
static function include2( mcanum, mhead,sw,ctr,mline,g_)    //generate array for
**********************************************************
local renum := CAheader->(recno()),mu:=Caheader->(indexord())                                                         //Unavailed Credit Line
local arr_ := {},xCredamTz:= 0,genray_:={},xxx
local renum2 := OLCAHEAD->(recno()),mu2:=OLCAHEAD->(indexord())
local caln_avld := 0
//mcanum := if( mcanum == nil, { Caheader->canumber }, mcanum )

if !empty(g_)
   dbselectarea('Caheader')
   Caheader->(dbsetorder(1))
   Caheader->(dbseek(g_PAR_BRCH+RIGHT(mcanum,5)))
endif

if Cadetail->( dbseek( Caheader->brcode+RIGHT(mcanum,5) ) )

   if !sw .and. ctr < 1
      sw:=.t.
      ctr++
      hd_fclty('UNAVAILED CREDIT LINE:')
   endif

	do while Cadetail->(!eof())           .and. ;
			 Cadetail->Canumber == RIGHT(mcanum,5) .and. ;
			 Cadetail->brcode   == Caheader->brcode

	  if !empty(Cadetail->Fcltycode)

		 if mline == '1'
			aadd ( genray_,{Cadetail->Fcltycode,cadetail->Ratetype,Cadetail->(recno()),'CADETAIL' } )

			   caln_avld := eval (  {|| Caheader->(dbseek(g_PAR_BRCH+RIGHT(mcanum,5),.f.)),(Caheader->Caline - Caheader->Availed)})

			   CAheader->(dbsetorder(mu))
			   Caheader->(dbgoto(renum))


		 elseif mline == '2'

			aadd ( genray_,{Cadetail->Fcltycode,cadetail->Ratetype,Cadetail->(recno()),'CADETAIL' } )

			   caln_avld := eval ( {|| Caheader->(dbseek(g_PAR_BRCH+RIGHT(mcanum,5),.f.)),(Caheader->Caline - Caheader->Availed)})

			   CAheader->(dbsetorder(mu))
			   Caheader->(dbgoto(renum))

		 endif

	  endif

	  Cadetail->( dbskip(+1) )

	enddo

	chkpage ()

	IF caln_avld <> 0
		if mline == '1'
		   @ prow()+1,0 say '³' + mhead+' Line CA N§ ' + LEFT(mcanum,3)+'-'+RIGHT(mcanum,5)
		   @ prow(),97 say '³                   ³'
		   @ prow(),119 say trans(caln_avld,'@Z 999,999,999,999.99') + '  ³'
		elseif mline == '2'
		   @ prow()+1,0 say '³' + mhead+' Line CA N§ ' + LEFT(mcanum,3)+'-'+RIGHT(mcanum,5)
		   @ prow(),97 say '³                   ³'
		   @ prow(),119 say trans(caln_avld,'@Z 999,999,999,999.99') + '  ³'
		endif
    ENDIF
	
	CAheader->(dbsetorder(mu))
	Caheader->(dbgoto(renum))
endif


if !empty(g_)
   dbselectarea('OLCAHEAD')
   OLCAHEAD->(dbsetorder(1))
   OLCAHEAD->(dbseek(mcanum))
endif

if OLCADET->( dbseek( mcanum ) )

   if !sw .and. ctr < 1
      sw:=.t.
      ctr++
      hd_fclty('UNAVAILED CREDIT LINE:')
   endif
   
	do while OLCADET->(!eof())           .and. ;
			 OLCADET->brcode+OLCADET->Canumber == mCanum

	  if !empty(OLCADET->Fcltycode)

		 if mline == '1'
			aadd ( genray_,{OLCADET->Fcltycode,OLCADET->Ratetype,OLCADET->(recno()),'OLCADET' } )

			IF OLCADET->INCLUDE
			   caln_avld += OLCADET->CREDAMT - OLCADET->AVAILED
			ENDIF
			   OLCAHEAD->(dbsetorder(mu))
			   OLCAHEAD->(dbgoto(renum))


		 elseif mline == '2'

			aadd ( genray_,{OLCADET->Fcltycode,OLCADET->Ratetype,OLCADET->(recno()),'OLCADET' } )

			IF OLCADET->INCLUDE
			   caln_avld += OLCADET->CREDAMT - OLCADET->AVAILED
			ENDIF

			   OLCAHEAD->(dbsetorder(mu))
			   OLCAHEAD->(dbgoto(renum))

		 endif

	  endif

	  OLCADET->( dbskip(+1) )

	enddo

	chkpage ()
	IF caln_avld <> 0
		if mline == '1'
		   @ prow()+1,0 say '³' + mhead+' Line CA N§ ' + LEFT(mcanum,3)+'-'+RIGHT(mcanum,5)
		   @ prow(),97 say '³                   ³'
		   @ prow(),119 say trans(caln_avld,'@Z 999,999,999,999.99') + '  ³'
		elseif mline == '2'
		   @ prow()+1,0 say '³' + mhead+' Line CA N§ ' + LEFT(mcanum,3)+'-'+RIGHT(mcanum,5)  
		   @ prow(),97 say '³                   ³'
		   @ prow(),119 say trans(caln_avld,'@Z 999,999,999,999.99') + '  ³'
		endif
    ENDIF
	OLCAHEAD->(dbsetorder(mu2))
	OLCAHEAD->(dbgoto(renum2))

endif

return genray_
///
static function exclude( motnum,sw,ctr )      //Creat an array for the
local arr_ := {}, mdbf_ := savedbf(),x              //Offering Ticket
local mindx := Oticket->( indexord() )

if !empty(motnum)
   if !sw .and. ctr < 1
      sw:=.t.
      ctr++
      hd_fclty('UNAVAILED OT')
   endif
endif
dbselectar( 'Oticket' )
Oticket->( dbsetorder( 1 ) )
for x:= 1 to len(motnum)
  if Oticket->( dbseek( Caheader->Brcode+motnum[x] ) )
     aadd ( arr_, { Oticket->Fcltycode,Oticket->Ratetype,Oticket->(recno());
                  } ;
          )
  endif
next x
Oticket->( dbsetorder( mindx ) )
restdbf( mdbf_ )                   
return( arr_ )

//////////////////////////////////////////////////
// Generate Outstanding Balance
//////////////////////////////////////////////////

*****************************************
*
// static function getbalc(clncode)
static function getbalc(clncode,lloans)  // abb 12.23.2002
*****************************************
local mosbal := 0, mfacil:= Acctmast->Fcltycode
local mclntcod := Caheader->Clntcode,nrecno:=Acctmast->(recno())

if lloans
/***********************
   Acctmast ->;
           (dbeval( {|| if ( Acctmast->status <> '4' .and. ;
                             Acctmast->status <> '5',;
                             mosbal += ( Acctmast->Osbal - Acctmast->udibal ) ,;
                             nil ;
                           ) ;
                    } ,, ;
                    {|| Acctmast->(!eof())            .and. ;
                        Acctmast->Fcltycode == mFacil .and. ;
                        Acctmast->Clntcode  == Clncode  ;
                    } ;
                  );
           )
           PINABALIK YUNG DATI, 01.21.2003 ( ABB )
**********************/
   Acctmast ->;
           (dbeval( {|| if ( Acctmast->status <> '4' .and. ;
                             Acctmast->status <> '5' .and. Acctmast->status != '0',; //RLV,;
                             mosbal += Acctmast->Osbal,;
                             nil ;
                           ) ;
                    } ,, ;
                    {|| Acctmast->(!eof())            .and. ;
                        Acctmast->Fcltycode == mFacil .and. ;
                        Acctmast->Clntcode  == Clncode  ;
                    } ;
                  );
           )

else
   Acctmast ->;
           (dbeval( {|| if ( Acctmast->status <> '4' .and. ;
                             Acctmast->status <> '5' .and. Acctmast->status != '0',; //RLV,;
                             mosbal += Acctmast->Osbal,;
                             nil ;
                           ) ;
                    } ,, ;
                    {|| Acctmast->(!eof())            .and. ;
                        Acctmast->Fcltycode == mFacil .and. ;
                        Acctmast->Clntcode  == Clncode  ;
                    } ;
                  );
           )

endif

Acctmast->(dbgoto(nrecno))
return ( mosbal )

////
********************************
*
Static function getosbal()                                      //get the O's Balance
********************************
local mosbal := 0, mtrantype := ( Cadetail->trantype == '1' )
local meval := { | f, s | f, s } 
local mcodeset := eval( meval, Facility->( dbseek( Cadetail->fcltycode ) ),;
                               Facility->setcode )
local msetcode := ( mcodeset == '4' .or. mcodeset == '5' )
local mcatype := ( Caheader->catype == '2' .or. Caheader->catype == '3' )
local mactntx := Acctmast->( indexord() )

if msetcode .and. mcatype .and. mtrantype
   Acctmast->( ordsetfocus( 2 ) )
   Acctmast->( dbseek( Caheader->brcode+Caheader->clntcode ) )
   Acctmast->( dbeval( { || if( Acctmast->fcltycode == Cadetail->fcltycode .and. ( Acctmast->Status <> '4' .and. Acctmast->Status <> '5' .and. Acctmast->status != '0') ,;
                            mosbal += Acctmast->osbal, nil ) },,;
                       { || Acctmast->clntcode == Caheader->clntcode .and. Acctmast->brcode == Caheader->Brcode } ) )
   Acctmast->( ordsetfocus( mactntx ) )                       
endif

return( mosbal )

********************************************
*
**Static Function getamt(xCredamTz)     //Get the Credit Amount
Static Function getamt(xCredamTz,nprincipal)     //Get the Credit Amount abb 12.23.2002
********************************************
local arr_ := {}, mfclty := Cadetail->fcltycode, xbreak
if Cadetail->include
   aadd( arr_, Cadetail->( recno() ) )
   xCredamTz  := Cadetail->Credamt
   nprincipal := Cadetail->principal
   Cadetail->( dbskip(+1) )
   Cadetail->( dbeval( { || aadd( arr_, Cadetail->( recno() ) ) },,;
                       { || Caheader->canumber == Cadetail->canumber .and.;
                            Cadetail->fcltycode == mfclty .and. !Cadetail->include } ) )
   Cadetail->( dbskip( -1 ) )
else
   xCredamTz  := 0
   nprincipal := 0
   aadd( arr_, Cadetail->( recno() ) )
   Cadetail->(dbskip())
   Cadetail->( dbeval( { || aadd( arr_, Cadetail->( recno() ) ) },,;
                       { || Caheader->canumber == Cadetail->canumber .and.;
                            Cadetail->fcltycode == mfclty .and. !Cadetail->include } ) )
   cadetail->(dbskip(-1))
endif
return (arr_)

***********************************************************************
*   abb 12.20.2002
*
*
static Function Actual_p(genray_,rpt)   //Printing of Proposed facility
***********************************************************************
local mdata:={},mdata1:={},mdata2:={},mdata3:={},mdata4:={},mdata5:={},mdata6:={}
local mdata3a:={},mdata31:={},mdata32:={},mdata33:={},mdata34:={}
local m,n,q,x,y,z,g,j,h,mtext
local _totnprincipal := 0

//for x:=1 to len(genray_)


    if len(genray_[4]) > 1


       mSEtcode:=if(Facility->(dbseek(genray_[1])),Facility->SEtcode,'')
       topstr := tran( Facility->fcltycode, '@R 999-99' ) + " (" +;
                 rtrim( Facility->fcltyalias ) + ") " + rtrim(Facility->fcltyname)+;
                 if(empty(genray_[5]),' (SUB-LIMIT) ','')
       
       chkpage()
       @ prow()+1,0 say '³'+topstr+spac(96-len(topstr))+'³'
       @ prow(),98 say if(empty(genray_[ 3]) ,spac(18),tran(genray_[ 3],'@Z 999,999,999,999.99') ) + ' ³'

       if left(genray_[1],3) == '104'
          //
          // PRINCIPAL LANG ANG IPIPRINT (  12.23.2002 abb )
          //

/***********
          @ prow(),119 say if(empty(genray_[6]),;
                                    spac(18),;
                                    trans(genray_[6],'@Z 999,999,999,999.99');
                                   )+'  ³'
***********/

          //
          // PINABALIK YUNG DATING PROGRAM ( 01.21.2003)
          //
          @ prow(),119 say if(empty(genray_[ 5]),spac(18),trans(genray_[ 5],'@Z 999,999,999,999.99') )+'  ³'

       else
          @ prow(),119 say if(empty(genray_[ 5]),spac(18),trans(genray_[ 5],'@Z 999,999,999,999.99') )+'  ³'
       endif


       do case
          case mSEtcode == '1'
              aadd(mdata1,;
                        {'       Purchase Amount       :',;
                         '       Guaranty Deposit      :',;
                         '       Residual Value        :',;
                         '       Term                  :',;
                         '       Effective Rate        :',;
                         '       Rate Type             :',;
                         '       Monthly Rental        :',;
                         '       Payment Type          :',;
                         '       Monthly Rental Factor :';
                         } )

              
              for y:=1 to len(genray_[ 4])
                 //aadd(mdata,topstr)
                 CAdetail->(dbgoto(genray_[ 4,y]))
                 topstr2:={ tran(Cadetail->Principal,'@Z 999,999,999.99'),;
                            tran(CAdetail->GD,'@B 99.999999') + '%',          ;
                            tran(Cadetail->RV,'@B 99.999999') + '%',          ;
                            tran(Cadetail->term,'@B 999') + ' '+          ;
                            tran(gettermunit(Cadetail->Termunit),'@X'),;
                            tran(Cadetail->Truerate,'@B 99.9999') + '%'  ,;
                            tran(getRatetype(CAdetail->Ratetype),'@X'),;
                            tran(Cadetail->amort,'@Z 999,999,999.99'), ;
                            Tran(getpaytype(Cadetail->Paytype),'@X'), ;
                            tran(Cadetail->Factor,'@B 99.9999')           ;
                            }
                  aadd(mdata1,topstr2)
                  if !empty(Cadetail->Unit)
                      aadd(mdata2,Cadetail->Unit)
                  endif
                  if !empty(Cadetail->Unit2)
                     aadd(mdata2,Cadetail->Unit2)
                  endif

              next y
              //
              //  printing
              //
              for m:= 1 to len(mdata1[1])
                  chkpage()
                  @ prow()+1,0 say '³'
                  n := 1


                  if m == 7

************                     if left(genray_[1],5) == '10407' .or. ;  // CML or AUTO-LOANS
************                        left(genray_[1],5) == '10452'         // abb 01.09.2004

                        @ prow()   , 32 say 'provided that a margin of       % is maintained'
                        @ prow()   , 97 say '³                   ³                     ³'
                        @ prow()+1 , 0  say '³'
                        @ prow()   , 32 say 'over one-year MBTC money at time of availment'
                        @ prow()   , 97 say '³                   ³                     ³'
                        @ prow()+1 , 0  say '³'

***********                     else  // branches
***********                        @ prow()   , 32 say 'or prevailing market rate at the time of'
***********                        @ prow()   , 97 say '³                   ³                     ³'
***********                        @ prow()+1 , 0  say '³'
***********                        @ prow()   , 32 say 'drawdown, whichever is higher'
***********                        @ prow()   , 97 say '³                   ³                     ³'
***********                        @ prow()+1 , 0  say '³'
***********                     endif

                  endif

                  do while n <= len(mdata1)
                     mcol:=if(n == 1,1,if(n == 2,32,if(n == 3,46,if(n== 4,63,80) ) ) )
                     @prow(),mcol say if( n > 2 ,' ; ','') + mdata1[n,m]
                     n++
                  endd

                  @ prow(),97 say '³                   ³                     ³'
              next q

              chkpage()
              @ prow()+1,0 say '³'
              @ prow(),8 say 'Items for Lease       :'
              if !empty(mdata2)
                 @ prow(),32 say mdata2[1]
              endif
              @ prow(),97 say '³                   ³                     ³'
              for q:= 2 to len(mdata2)
                  chkpage()
                  @ prow()+1,0 say '³'
                  @ prow(),32 say mdata2[q]
                  @ prow(),97 say '³                   ³                     ³'
              next q
              @ prow()+1,0 say '³                                                                                                ³                   ³                     ³'

          case mSEtcode == '2'

              aadd(mdata1,;
                     {'       Net Proceeds          :',;
                      '       Term                  :',;
                      '       Effective Rate        :',;
                      '       Rate Type             :',;
                      '       Monthly Amortization  :',;
                      '       Payment Type          :';
                      } )
              
              for y:= 1 to len(genray_[ 4])
                  CAdetail->(dbgoto(genray_[ 4,y]))
                  top2:={ tran(Cadetail->Principal,'@Z 999,999,999.99'), ;
                          tran(Cadetail->term,'@B 999') +' '            +;
                          tran(Gettermunit(Cadetail->Termunit),'@X'), ;
                          tran(CAdetail->Truerate,'@B 99.9999'),          ;
                          tran(getratetype(Cadetail->Ratetype),'@X'), ;
                          tran(Cadetail->Amort,'@Z 999,999,999.99'),     ;
                          tran(getpaytype(Cadetail->Paytype),'@X')    ;
                         }
                  aadd(mdata1,top2)
                  if !empty(Cadetail->Colatrl)
                     aadd(mdata2,top3)
                  endif

                  if !empty(Cadetail->Unit)                // ABB 02.03.2009
                      aadd(mdata2,Cadetail->Unit)
                  endif
                  if !empty(Cadetail->Unit2)
                     aadd(mdata2,Cadetail->Unit2)
                  endif

              next y

              for m:=1 to len(mdata1[1])
                  chkpage()
                  @ prow()+1,0 say '³'

                  if m == 5

********                     if Parametr->brcode == '01'        // HEAD OFFICE 12.23.2003
                        @ prow()   , 32 say 'provided that a margin of       % is maintained'
                        @ prow()   , 97 say '³                   ³                     ³'
                        @ prow()+1 , 0  say '³'
                        @ prow()   , 32 say 'over one-year MBTC money at time of availment'
                        @ prow()   , 97 say '³                   ³                     ³'
                        @ prow()+1 , 0  say '³'
********                     else
********                        @ prow()   , 32 say 'or prevailing market rate at the time of'
********                        @ prow()   , 97 say '³                   ³                     ³'
********                        @ prow()+1 , 0  say '³'
********                        @ prow()   , 32 say 'drawdown, whichever is higher'
********                        @ prow()   , 97 say '³                   ³                     ³'
********                        @ prow()+1 , 0  say '³'
********                     endif


                  endif

                  n:=1
                  do while n <= len(mdata1)
                     mcol:=if(n == 1,1,if(n == 2,32,if(n == 3,46,if(n== 4,63,80) ) ) )
                     @prow(),mcol say if( n > 2 ,' ; ','') + mdata1[n,m]
                     n++
                  enddo

                  @ prow(),97 say '³                   ³                     ³'
              next m


              if !empty(mdata2)
                 chkpage()
                 @ prow()+1,0 say '³'
                 @ prow(),8 say 'Collaterals           :'
                 @ prow(),32 say mdata2[1]
                 @ prow(),97 say '³                   ³                     ³'
              endif


              for m:= 2 to len(mdata2)
                  chkpage()
                  @ prow()+1,0 say '³'
                  @ prow(),32 say mdata2[m]
                  @ prow(),97 say '³                   ³                     ³'
              next m
              @ prow()+1,0 say '³                                                                                                ³                   ³                     ³'


          case mSEtcode == '3'


              for g:=1 to len(genray_[ 4])
                  Cadetail->(dbgoto(genray_[ 4,g]))
                  if !empty(Cadetail->Unit)
                     aadd(mdata31,Tran(Cadetail->Unit,'@X') )
                  endif
                  if !empty(Cadetail->Unit2)
                      aadd(mdata31,Tran(Cadetail->Unit2,'@X'))
                  endif
                  if !empty(eval({|| Dealer->(dbseek(Cadetail->brcode+Cadetail->Dlrcode)),Dealer->Dlrname } ) )
                      aadd(mdata32,tran(eval({|| Dealer->(dbseek(Cadetail->brcode+Cadetail->Dlrcode)),Dealer->Dlrname } ),'@X') )
                  endif
                  if !empty(Cadetail->Salesrep)
                     aadd(mdata33,tran(Cadetail->Salesrep,'@X'))
                  endif
              next g
              mdata3a := ;
                      {'       Cash Price            :',;
                       '       Down Payment          :',;
                       '       Net Proceeds          :',;
                       '       Term                  :',;
                       '       Gross Rate            :',;
                       '       Net Effective Rate    :',;
                       '       Rate Type             :',;
                       '       Monthly Amortization  :',;
                       '       Payment Type          :' ;
                       }
              aadd(mdata34,mdata3a)
              for g:=1 to len(genray_[ 4])
                  mray:='mdata'+str(g,1)
                  &mray:={}
                  Cadetail->(dbgoto(genray_[ 4,g]))
                  &mray:=;
                          { tran(Cadetail->Purcamt,'@Z 999,999,999.99'),   ;
                            tran(Cadetail->Downpay,'@Z 999,999,999.99'),   ;
                            tran(Cadetail->Principal,'@Z 999,999,999.99'), ;
                            tran(Cadetail->term,'@B 999')+' '+             ;
                            tran(gettermunit(Cadetail->termunit),'@X'), ;
                            tran(Cadetail->Truerate,'@B 99.9999')+'%',      ;
                            tran(Cadetail->Nerate,'@B 99.9999')+'%',        ;
                            tran(getratetype(Cadetail->Ratetype),'@X'),  ;
                            tran(Cadetail->Amort,'@Z 999,999,999.99'),     ;
                            tran(getPaytype(Cadetail->Paytype),'@X');
                            }
                    cr_amnt:=if(Cadetail->Include,Cadetail->Credamt,0)

                 aadd(mdata34,&mray)
              next g
              //
              mrow:=prow()
              chkpage()
              @ prow()+1,0 say '³'
              @ prow(),8 say 'Unit                  :'
              @ prow(),32 say alltrim(mdata31[ 1 ]) //+ spac(66-len(alltrim(mdata31[ 1 ]) ))
              @ prow(),97 say '³                   ³                     ³'

              for m:= 2 to len(mdata31)
                  chkpage()
                  @ prow()+1,0 say '³'
                  @ prow(),32 say mdata31[ m ]
                  @ prow(),97 say '³                   ³                     ³'
              next m
              chkpage()
              @ prow()+1,0 say '³'
              @ prow(),8 say 'Dealer                :'
              @ prow(),32 say mdata32[ 1 ]
              @ prow(),97 say '³                   ³                     ³'

              for m:=2 to len(mdata32)
                  chkpage()
                  @ prow()+1,0 say '³'
                  @ prow()  ,32 say mdata32[ m ]
                  @ prow(),97 say '³                   ³                     ³'
              next m

//              alert ( 'asdf' )

              //mrow:=prow()
              chkpage()
              @ prow()+1,0 say '³'
              @ prow(),8 say 'Sales Representative  :'

              if len(mdata33) > 0
                 @ prow(), 32 say mdata33[ 1 ]
              endif

              @ prow(),97 say '³                   ³                     ³'

              for m:= 2 to len(mdata33)
                  chkpage()
                  @ prow()+1,0 say '³'
                  @ prow(), 32 say mdata33[ m ]
                  @ prow(),97 say '³                   ³                     ³'
              next m

              mrow:=prow()+1
              for m:=1 to len(mdata34[1])
                  chkpage()
                  @ prow()+1,0 say '³'
                  n:=1
                  do while n <= len(mdata34)
                     mcol:=if(n == 1,1,if(n == 2,32,if(n == 3,46,if(n== 4,63,80) ) ) )
                     @prow(),mcol say if( n > 2 ,' ; ','') + mdata34[n,m]
                     n++
                  endd
                  @ prow(),97 say '³                   ³                     ³'
                  //mrow++
              next m

//              @ prow()+1,0 say '³                                                                                                ³                   ³                     ³'

              @ prow()+1,0  say '³'
              @ prow()  ,97 say '³                   ³                     ³'

          otherwise
          
              if genray_[ 2] == '1'  //negotiable
                 aadd(mdata1, {'       Type                  :',;
                               '       Term                  :' ;
                               })
                                
                 aadd(mdata3, { '       Payment Frequency     :', ;
                                '       Notification          :', ;
                                '       Collection            :', ;
                                '       Recourse              :'  ;
                              } )

                 for g:=1 to len(genray_[ 4])
                     Cadetail->(dbgoto(genray_[ 4,g]))

                     //Generate the first group of data
                     aadd( mdata1, { tran(gettrantype(Cadetail->Trantype),'@X') , ;
                                     tran(Cadetail->Term,'999')+' '+              ;
                                     tran(gettermunit(Cadetail->Termunit),'@X') ;
                                    } )

                     //for the second group of data
                     aadd(mdata2,'Minimum spread of ' + Tran(Cadetail->Truerate,'99.99') + '% over the average cost of funds')

                     //for the third group of data
                     aadd( mdata3,{ Tran(getpayfreq(Cadetail->Payfreq),'@X' ), ;
                                     Tran(getnotifition(Cadetail->Notfctn),'@X'), ;
                                     Tran(getcollection(Cadetail->Colexion),'@X'), ;
                                     Tran(getRecourse(Cadetail->Recourse),'@X')    ;
                                    } )
                     //for the 4th
                     if !empty(CAdetail->Obligor)
                        Aadd( mdata4,Tran(Cadetail->Obligor,'@X') )
                     endif
                     //for the 5th
                     if !empty(Cadetail->Colatrl)
                        aadd( mdata5,Tran(Cadetail->Colatrl,'@X') )
                     endif
                 next g
                  for m:=  1 to len(mdata1[1])
                      chkpage()
                      @ prow()+1,0 say '³'
                      n:=1
                      do while n <= len(mdata1)
                         mcol:=if(n == 1,1,if(n == 2,32,if(n == 3,46,if(n== 4,63,80) ) ) )
                         @prow(),mcol say if( n > 2 ,' ; ','') + mdata1[n,m]
                         n++
                      endd
                      @ prow(),97 say '³                   ³                     ³'
                 next m
                 chkpage()
                 @ prow()+1,0 say '³'
                 @ prow(),8 say 'Effective Rate        :'
                 @ prow(),32 say alltrim(mdata2[ 1 ]) //+ spac(66-len(alltrim(mdata31[ 1 ]) ))
                 @ prow(),97 say '³                   ³                     ³'

                 for m:= 2 to len(mdata2)
                     chkpage()
                     @ prow()+1,0 say '³'
                     @ prow(),32 say mdata2[ m ]
                     @ prow(),97 say '³                   ³                     ³'
                 next m

                  for m:=  1 to len(mdata3[1])
                      chkpage()
                      @ prow()+1,0 say '³'
                      n:=1
                      do while n <= len(mdata3)
                         mcol:=if(n == 1,1,if(n == 2,32,if(n == 3,46,if(n== 4,63,80) ) ) )
                         @prow(),mcol say if( n > 2 ,' ; ','') + mdata3[n,m]
                         n++
                      endd
                      @ prow(),97 say '³                   ³                     ³'
                 next m
                 if !empty(mdata4)
                    chkpage()
                    @ prow()+1,0 say '³'
                    @ prow(),8 say 'Obligor               :'
                    @ prow(),32 say alltrim(mdata4[ 1 ]) //+ spac(66-len(alltrim(mdata31[ 1 ]) ))
                    @ prow(),97 say '³                   ³                     ³'
                 endif

                 for m:= 2 to len(mdata4)
                     chkpage()
                     @ prow()+1,0 say '³'
                     @ prow(),32 say mdata4[ m ]
                     @ prow(),97 say '³                   ³                     ³'
                 next m

                 if !empty(mdata5)
                    chkpage()
                    @ prow()+1,0 say '³'
                    @ prow(),8 say 'Collateral            :'
                    @ prow(),32 say alltrim(mdata5[ 1 ]) //+ spac(66-len(alltrim(mdata31[ 1 ]) ))
                    @ prow(),97 say '³                   ³                     ³'
                 endif

                 for m:= 2 to len(mdata5)
                     chkpage()
                     @ prow()+1,0 say '³'
                     @ prow(),32 say mdata5[ m ]
                     @ prow(),97 say '³                   ³                     ³'
                 next m
                 @ prow()+1,0 say '³                                                                                                ³                   ³                     ³'
              elseif genray_[ 2] == '2'  //<fixed>
                                  
                  aadd( mdata1, { '       Net Proceeds          :',;
                                  '       Type                  :',;
                                  '       Term                  :',;
                                  '       Effective Rate        :',;
                                  '       Payment Frequency     :',;
                                  '       Amortization          :',;
                                  '       Notification          :',;
                                  '       Collection            :',;
                                  '       Recourse              :' ;
                                 }    )

                 for g:=1 to len(genray_[ 4])
                     Cadetail->(dbgoto(genray_[ 4,g]))
                     aadd( mdata1, { tran(CAdetail->Principal,'@Z 999,999,999.99'),    ;
                                      tran(gettrantype(Cadetail->Trantype),'@X'),    ;
                                      tran(Cadetail->Term,'@B 999')+' '+                ;
                                      tran(gettermunit(Cadetail->termunit),'@X' ),   ;
                                      tran(Cadetail->Truerate,'@B 99.9999')+'%',        ;
                                      tran(getpayfreq(Cadetail->Payfreq),'@X'),      ;
                                      tran(Cadetail->Amort,'@Z 999,999,999.99'),        ;
                                      tran(getnotifition(Cadetail->Notfctn),'@X'),   ;
                                      tran(getcollection(Cadetail->Colexion),'@X'),  ;
                                      tran(getrecourse(Cadetail->Recourse),'@X')     ;
                                     } )
                     if !empty(Cadetail->Obligor)
                        aadd( mdata2, tran(Cadetail->Obligor,'@X') )
                     endif
                     if !empty(Cadetail->Colatrl)
                        aadd( mdata3, tran(Cadetail->Colatrl,'@X') )
                     endif
                 next g
                  for m:=  1 to len(mdata1[1])
                      chkpage()
                      @ prow()+1,0 say '³'
                      n:=1
                      do while n <= len(mdata1)
                         mcol:=if(n == 1,1,if(n == 2,32,if(n == 3,46,if(n== 4,63,80) ) ) )
                         @prow(),mcol say if( n > 2 ,' ; ','') + mdata1[n,m]
                         n++
                      endd
                      @ prow(),97 say '³                   ³                     ³'
                  next m
                 if !empty(mdata2)
                    chkpage()
                    @ prow()+1,0 say '³'
                    @ prow(),8 say 'Obligor               :'
                    @ prow(),32 say alltrim(mdata2[ 1 ]) //+ spac(66-len(alltrim(mdata31[ 1 ]) ))
                    @ prow(),97 say '³                   ³                     ³'
                 endif

                 for m:= 2 to len(mdata2)
                     chkpage()
                     @ prow()+1,0 say '³'
                     @ prow(),32 say mdata2[ m ]
                     @ prow(),97 say '³                   ³                     ³'
                 next m

                 if !empty(mdata5)
                    chkpage()
                    @ prow()+1,0 say '³'
                    @ prow(),8 say 'Collateral            :'
                    @ prow(),32 say alltrim(mdata3[ 1 ]) //+ spac(66-len(alltrim(mdata31[ 1 ]) ))
                    @ prow(),97 say '³                   ³                     ³'
                 endif

                 for m:= 2 to len(mdata3)
                     chkpage()
                     @ prow()+1,0 say '³'
                     @ prow(),32 say mdata3[ m ]
                     @ prow(),97 say '³                   ³                     ³'
                 next m
                 @ prow()+1,0 say '³                                                                                                ³                   ³                     ³'
              endif



       endcase
    else  //single Facility


       mSEtcode:=if(Facility->(dbseek(genray_[ 1])),Facility->SEtcode,'')
       topstr := tran( Facility->fcltycode, '@R 999-99' ) + " (" +;
                 rtrim( Facility->fcltyalias ) + ") " + rtrim(Facility->fcltyname) + ;
                 if(empty(genray_[5]),' ( SUB-LIMIT )','')

       chkpage ()
       
       @ prow()+1,0 say '³'+topstr+spac(96-len(topstr))+'³'
       @ prow(),98  say if(empty(genray_[ 3]),spac(18),tran(genray_[ 3],'@Z 999,999,999,999.99') ) + ' ³'
//
       if left(genray_[1],3) == '104'                    // 12.20.2002
//

/*************
          @ prow(),119 say if(empty(genray_[ 5]),spac(18),trans(genray_[ 6],'@Z 999,999,999,999.99') )+'  ³'

          PINABALIK YUNG DATI . . . 01.21.2003

*************/

          @ prow(),119 say if(empty(genray_[ 5]),spac(18),trans(genray_[ 5],'@Z 999,999,999,999.99') )+'  ³'
       else
          @ prow(),119 say if(empty(genray_[ 5]),spac(18),trans(genray_[ 5],'@Z 999,999,999,999.99') )+'  ³'
       endif

       Cadetail->(dbgoto(genray_[ 4,1]))

       do case
          case mSetcode == '1'

*****               mdata1:= ;
*****                   {'       Purchase Amount       : '+tran(Cadetail->Principal,'@Z 999,999,999.99'),   ;
*****                    '       Guaranty Deposit      : '+tran(Cadetail->Gd,'@B 99.999999')+'%',                 ;
*****                    '       Residual Value        : '+tran(Cadetail->Rv,'@B 99.999999')+'%',                 ;
*****                    '       Term                  : '+tran(Cadetail->term,'@B 999') +'  '+tran(gettermunit(Cadetail->termunit),'@X') , ;
*****                    '       Effective Rate        : '+tran(Cadetail->Truerate,'@B 99.9999')+'%'+ '       '+tran(getratetype(Cadetail->Ratetype),'@X'), ;
*****                    '                               or prevailing market rate at the time of' ,;
*****                    '                               drawdown, whichever is higher' ,;
*****                    '       Monthly Rental        : '+tran(Cadetail->Amort,'@Z 999,999,999.99')+ ' '+ tran(getpaytype(Cadetail->Paytype),'@X'), ;
*****                    '       Monthly Rental Factor : '+tran(Cadetail->Factor,'@B 99.9999'),    ;
*****                    '       Item for Lease        : '+tran(Cadetail->Unit,'@X')    ;
*****                    }

//     if Parametr->brcode == '01'        // HEAD OFFICE  12.23.2003

               mdata1:= ;
                   {'       Purchase Amount       : '+tran(Cadetail->Principal,'@Z 999,999,999.99'),   ;
                    '       Guaranty Deposit      : '+tran(Cadetail->Gd,'@B 99.999999')+'%',                 ;
                    '       Residual Value        : '+tran(Cadetail->Rv,'@B 99.999999')+'%',                 ;
                    '       Term                  : '+tran(Cadetail->term,'@B 999') +'  '+tran(gettermunit(Cadetail->termunit),'@X') , ;
                    '       Effective Rate        : '+tran(Cadetail->Truerate,'@B 99.9999')+'%'+ '       '+tran(getratetype(Cadetail->Ratetype),'@X'), ;
                    '                               provided that a margin of       % is maintained' ,;
                    '                               over one-year MBTC money at time of availment',;
                    '       Monthly Rental        : '+tran(Cadetail->Amort,'@Z 999,999,999.99')+ ' '+ tran(getpaytype(Cadetail->Paytype),'@X'), ;
                    '       Monthly Rental Factor : '+tran(Cadetail->Factor,'@B 99.9999'),    ;
                    '       Item for Lease        : '+tran(Cadetail->Unit,'@X')    ;
                    }

                    
                    if !Empty(Cadetail->Unit2)
                       aadd(mdata1,;
                                '                               '+tran(Cadetail->Unit2,'@X') )
                    endif
                    for m:= 1 to len(mdata1)
                       chkpage()
                       @ prow()+1,0 say '³'
                       @ prow(),  1 say mdata1[ m ]
                       @ prow(),97 say '³                   ³                     ³'
                    next m
                    @ prow()+1,0 say '³                                                                                                ³                   ³                     ³'

          case mSEtcode == '2'

*****                     '                               or prevailing market rate at the time of' ,;
*****                     '                               drawdown, whichever is higher' ,;


                mdata1:=;
                    {'       Net Proceeds          : '+tran(Cadetail->Principal,'@Z 999,999,999.99') , ;
                     '       Term                  : '+tran(Cadetail->Term,'@B 999') + '  '+tran(gettermunit(Cadetail->termunit),'@X'), ;
                     '       Effective Rate        : '+tran(Cadetail->Truerate,'@B 99.9999') + '%' + '       '+tran(getratetype(Cadetail->ratetype),'@X'), ;
                     '                               provided that a margin of       % is maintained',;
                     '                               over one-year MBTC money at time of availment',;
                     '       Monthly Amortization  : '+tran(Cadetail->Amort,'@Z 999,999,999.99') + ' '+ tran(getpaytype(Cadetail->Paytype),'@X'),  ;
                     '       Collateral/s          : '+tran(Cadetail->Unit,'@X') ;
                     }

                     
                if !empty(Cadetail->Unit2)
                   aadd(mdata1,;
                      '                               '+Cadetail->Unit2)

                endif
                for m:= 1 to len(mdata1)
                    chkpage()
                    @ prow()+1,0 say '³'
                    @ prow(),  1 say mdata1[ m ]
                    @ prow(),97 say '³                   ³                     ³'
                next m
                @ prow()+1,0 say '³                                                                                                ³                   ³                     ³'

                
          case mSEtcode == '3'

//
               aadd(mdata1,'       Unit                  : '+tran(Cadetail->Unit,'@X') )
               if !Empty(Cadetail->unit2)
                  aadd(mdata1,;
                    '                             : '+tran(Cadetail->Unit2,'@X') ;
                    )
               endif
               aadd(mdata1,'       Dealer                : '+tran(eval({|| Dealer->(dbseek(Cadetail->brcode+Cadetail->Dlrcode)),Dealer->Dlrname } ),'@X') )
               aadd(mdata1,'       Sales Representative  : '+tran(Cadetail->Salesrep,'@X') )
               aadd(mdata1,'       Cash Price            : '+tran(Cadetail->Purcamt,'@Z 999,999,999.99') )
               aadd(mdata1,'       Down Payment          : '+tran(Cadetail->Downpay,'@Z 999,999,999.99') )
               aadd(mdata1,'       Net Proceeds          : '+tran(Cadetail->Principal,'@Z 999,999,999.99') )
               aadd(mdata1,'       Term                  : '+tran(Cadetail->term,'@B 999')+ '  '+tran(gettermunit(Cadetail->termunit),'@X') )
               aadd(mdata1,'       Gross Rate            : '+tran(Cadetail->Truerate,'@B 99.9999')+'%       '+tran(getratetype(Cadetail->ratetype),'@X') )
               aadd(mdata1,'       Net Effective Rate    : '+tran(Cadetail->Nerate,'@B 99.9999')+'%' )
               aadd(mdata1,'       Monthly Amortization  : '+tran(Cadetail->Amort,'@Z 999,999,999.99') + ' '+tran(getpaytype(Cadetail->Paytype),'@X') )

                for m:= 1 to len(mdata1)
                    chkpage()
                    @ prow()+1,0 say '³'
                    @ prow(),  1 say mdata1[ m ]
                    @ prow(),97 say '³                   ³                     ³'
                next m
                @ prow()+1,0 say '³                                                                                                ³                   ³                     ³'
          Otherwise    //SEtcode == 4/5
              if genray_[ 2] == '1'  // <negotiable>
                  mdata1:=;
                     { '       Type                  : '+tran(gettrantype(Cadetail->trantype),'@X'),  ;
                       '       Term                  : '+tran(Cadetail->term,'@B 999')+'  '+tran(gettermunit(Cadetail->termunit),'@X'), ;
                       '       Effective Rate        : Minimum spread of '+tran(Cadetail->Truerate,'99.99')+' % over the average cost of funds', ;
                       '                               provided that a margin of       % is maintained',;
                       '                               over one-year MBTC money at time of availment',;
                       '       Payment Frequency     : '+tran(getpayfreq(Cadetail->Payfreq),'@X'), ;
                       '       Notification          : '+tran(getnotifition(CAdetail->Notfctn),'@X'), ;
                       '       Collection            : '+tran(getcollection(CAdetail->Colexion),'@X'), ;
                       '       Recourse              : '+tran(getrecourse(Cadetail->Recourse),'@X');
                      }
                       if !empty(Cadetail->Obligor)
                          Aadd(mdata1,'       Obligor               : '+tran(CAdetail->Obligor,'@X') )
                       endif
                       if !empty(Cadetail->Colatrl)
                          aadd(mdata1,'       Collateral            : '+tran(Cadetail->Colatrl,'@X') )
                       endif

                for m:= 1 to len(mdata1)
                    chkpage()
                    @ prow()+1,0 say '³'
                    @ prow(),  1 say mdata1[ m ]
                    @ prow(),97 say '³                   ³                     ³'
                next m
                @ prow()+1,0 say '³                                                                                                ³                   ³                     ³'

              else  //<fixed>
                  mdata1:=;
                     { '       Net Proceeds          : '+tran(CAdetail->Principal,'@Z 999,999,999.99'), ;
                       '       Type                  : '+tran(gettrantype(Cadetail->Trantype),'@X'), ;
                       '       Term                  : '+tran(Cadetail->term,'@B 999') + '  '+tran(gettermunit(Cadetail->termunit),'@X'), ;
                       '       Effective Rate        : '+Tran(Cadetail->Truerate,'@B 99.9999')+'%' , ;
                       '                               provided that a margin of       % is maintained',;
                       '                               over one-year MBTC money at time of availment',;
                       '       Payment Frequency     : '+tran(getpayfreq(Cadetail->Payfreq),'@X'), ;
                       '       Amortization          : '+tran(Cadetail->Amort,'@Z 999,999,999.99'), ;
                       '       Notification          : '+tran(getnotifition(Cadetail->Notfctn),'@X'), ;
                       '       Collection            : '+tran(getcollection(Cadetail->Colexion),'@X'), ;
                       '       Recourse              : '+tran(getrecourse(Cadetail->Recourse),'@X') ;
                     }
                       if !empty(Cadetail->Obligor)
                          Aadd(mdata1,'       Obligor               : '+tran(CAdetail->Obligor,'@X') )
                       endif
                       if !empty(Cadetail->Colatrl)
                          aadd(mdata1,'       Collateral            : '+tran(Cadetail->Colatrl,'@X') )
                       endif

                for m:= 1 to len(mdata1)
                    chkpage()
                    @ prow()+1,0 say '³'
                    @ prow(),  1 say mdata1[ m ]
                    @ prow(),97 say '³                   ³                     ³'
                next m
                @ prow()+1,0 say '³                                                                                                ³                   ³                     ³'
              endif
       endcase

       /**********
       @ prow()+1,0 say '³       LESS Pending Availment(s) : '
       @ prow(),97  say '³                   ³                     ³'
       npending := _prn_pending( 21 )
       **********/

    endif
//next x
return nil


*************************************
*
static function _prn_pending ( ncol )
*************************************
local nretval := 0 , cdbf  := savedbf(),nntx := Acctwait->(indexord()),nrecno := Acctwait->(recno())
local ncred2  := 0 , nrec2 := 0, lok := .f., ndiff := 0, arecno := {} , nctr  := 0
local nretold := 0

   Acctwait ->( dbsetorder( 5 ) )
   if Acctwait->(dbseek(alltrim(Caheader->brcode+Caheader->canumber)))

      do while !Acctwait->(eof()) .and. alltrim(Acctwait->refno) == alltrim(Caheader->canumber)

         if !Acctwait->(deleted())

            if empty(Acctwait->refno2)
               @ prow()+1, 0       say '³'
               @ prow()  ,ncol     say 'Ref. No. : '+ Acctwait->refno
               @ prow()  ,pcol()+4 say substr ( Acctwait->acctno,-5,5 ) +' ; '+;
                                       dtoc   ( Acctwait->valdate )     +' ; '+;
                                       trans  ( Acctwait->credamt,"999,999,999.99" )
               @ prow(),97         say '³                   ³'
               @ prow(),pcol()+6   say trans  ( abs(Acctwait->credamt)*-1,"@(999,999,999.99" )
               @ prow(),pcol()+1   say '³'
               nretval += Acctwait->credamt
            else

               nretold := nretval
               ncred2  := nretval
               nrec2   := Acctwait->(recno())
               do while !Acctwait->(eof()) .and. ;
                        alltrim(Acctwait->refno) == alltrim(Caheader->canumber)

                  if !empty(Acctwait->refno2)
                     ncred2 += Acctwait->credamt
                     aadd ( arecno, Acctwait->(recno()) )
                  endif

                  Acctwait->(dbskip(+1))
               enddo

               Acctwait->(dbgoto(nrec2))
               do while !Acctwait->(eof()) .and. ;
                        alltrim(Acctwait->refno) == alltrim(Caheader->canumber)

                  lok := .f.
                  if !empty(Acctwait->refno2)

                     for nctr := 1 to len(arecno)
                         if arecno[nctr] == Acctwait->(recno())
                            exit
                         endif
                     next nctr

                     ndiff := ncred2 - Acctwait->credamt
                     ndiff := ( ncred2 - ( ncred2 - Caheader->caline ) ) - nretold

                     @ prow()+1, 0       say '³'
                     @ prow()  ,ncol     say 'Ref. No. : '+ Acctwait->refno
                     @ prow()  ,pcol()+4 say substr ( Acctwait->acctno,-5,5 ) +' ; '+;
                                             dtoc   ( Acctwait->valdate )     +' ; '+;
                                             trans  ( Acctwait->credamt ,"999,999,999.99" )
                     @ prow(),97         say '³                   ³'
                     @ prow(),pcol()+6   say trans  ( abs(ndiff) * -1,"@(999,999,999.99" )
                     @ prow(),pcol()+1   say '³'
                     nretval += ndiff        && Acctwait->credamt

                  endif

                  Acctwait->(dbskip(+1))
               enddo

            endif

         endif
         Acctwait->(dbskip(+1))

      enddo

   endif

   ******** nretval := _prn_pend2 ( 21,nretval )

   restdbf ( cdbf )
   Acctwait->(dbsetorder(nntx))
   Acctwait->(dbgoto(nrecno))
return nretval

/********
********************************************
*
static function _prn_pend2 ( ncol,nretval2 )
********************************************
   local nretval := 0 , cdbf   := savedbf(),nntx := Acctwait->(indexord()),nrecno := Acctwait->(recno())
   local ncred2  := 0 , nrec2  := 0, lok := .f., ndiff := 0, arecno := {} , nctr  := 0,nrec2
   local nretold := 0 , nrefno2,nrefno3

   Acctwait ->( dbsetorder( 6 ) )
   if Acctwait->(dbseek(alltrim(Caheader->Brcode+Caheader->canumber)))

      ncred2 := nretval2

      do while !Acctwait->(eof()) .and. ;
               alltrim(Acctwait->refno2) == alltrim(Caheader->canumber)

         if !Acctwait->(deleted()) .and. !empty(alltrim(Acctwait->refno2))
            ncred2 += Acctwait->credamt
            aadd ( arecno, Acctwait->(recno()) )
         endif

         Acctwait->(dbskip(+1))

      enddo


      for nctr := 1 to len(arecno)

         Acctwait->(dbgoto(arecno[nctr]))

         nrefno2 := Caheader->refno
         nrefno3 := Acctwait->refno2

         nrec2   := 0
         Acctwait->(dbsetorder(5))
         if Acctwait->(dbsetorder(alltrim(nrefno2)))

            do while alltrim(Acctwait->refno) == alltrim(nrefno2) .and. ;
                    !Acctwait->(eof())

               if alltrim(Acctwait->refno2) == alltrim(nrefno3)
                  nrec2 := Acctwait->(recno())
                  exit
               endif

               Acctwait->(dbskip(+1))
            enddo

         endif

         if nrec2 > 0

            Acctwait->(dbgoto(nrec2))
            nrefno3 := Acctwait->refno2
            ndiff   := 0
            do while Acctwait->refno == nrefno3 .and. !Acctwait->(eof())
               ndiff += Acctwait->
               Acctwait->(dbskip(+1))
            enddo

            ndiff := ncred2 - Acctwait->credamt
            ndiff := ncred2 - ( ncred2 - Caheader->caline )

            Acctwait->(dbsetorder(6))

            @ prow()+1, 0       say '³'
            @ prow()  ,ncol     say 'Ref. Nø 2: '+ Acctwait->refno2
            @ prow()  ,pcol()+4 say substr ( Acctwait->acctno,-5,5 ) +' ; '+;
                                    dtoc   ( Acctwait->valdate )     +' ; '+;
                                    trans  ( Acctwait->credamt ,"999,999,999.99" )
            @ prow(),97         say '³                   ³'
            @ prow(),pcol()+6   say trans  ( abs(ndiff) * -1,"@(999,999,999.99" )
            @ prow(),pcol()+1   say '³'

         endif
      next nctr
      nretval2 += ndiff

   endif

   restdbf ( cdbf )
   Acctwait->(dbsetorder(nntx))
   Acctwait->(dbgoto(nrecno))

return nretval2
**********/

////
*****************************************************
*
Static function Actual_p2(genray_,mline)  //Printing of Unavailed CA Line
*****************************************************

local mdata:={},mdata1:={},mdata2:={},mdata3:={},mdata4:={},mdata5:={},mdata6:={}
local mdata3a:={},mdata31:={},mdata32:={},mdata33:={},mdata34:={}
local m,n,q,x,y,z,g,j,h,mtext,omni:= ( mline == '1' )
local tempdbf

tempdbf := genray_[4]


if mline == '1' .or. mline == '2'
   (TEMPDBF)->(dbgoto(genray_[3]))
   mSEtcode:=if(Facility->(dbseek(genray_[ 1])),Facility->SEtcode,'')
   topstr := tran( Facility->fcltycode, '@R 999-99' ) + " (" +;
             rtrim( Facility->fcltyalias ) + ") " + rtrim(Facility->fcltyname)
   chkpage()
   @ prow()+1,0 say '³'+topstr+spac(96-len(topstr))
   if mline == '1'
      @ prow(),97 say '³                   ³                     ³'
   elseif mline == '2'
      @ prow(),97 say '³                   ³                     ³'
      //@ prow(),97 say '³                   ³'
      //@ prow(),119 say trans(genray_[4],'@Z 999,999,999,999.99') + '  ³'
   endif
   do case
          case mSetcode == '1'
               mdata1:= ;
                   {'       Purchase Amount       : '+tran((TEMPDBF)->Principal,'@Z 999,999,999.99') + if(omni,' (SUB-LIMIT)','') ,   ;
                    '       Guaranty Deposit      : '+tran((TEMPDBF)->Gd,'@B 99.999999')+'%',                 ;
                    '       Residual Value        : '+tran((TEMPDBF)->Rv,'@B 99.999999')+'%',                 ;
                    '       Term                  : '+tran((TEMPDBF)->term,'@B 999') +'  '+tran(gettermunit((TEMPDBF)->termunit),'@X') , ;
                    '       Effective Rate        : '+tran((TEMPDBF)->Truerate,'@B 99.9999')+'%'+ '       '+tran(getratetype((TEMPDBF)->Ratetype),'@X'), ;
                    '       Monthly Rental        : '+tran((TEMPDBF)->Amort,'@Z 999,999,999.99')+ ' '+ tran(getpaytype((TEMPDBF)->Paytype),'@X'), ;
                    '       Monthly Rental Factor : '+tran((TEMPDBF)->Factor,'@B 99.9999'),    ;
                    '       Item for Lease        : '+tran((TEMPDBF)->Unit,'@X')    ;
                    }
                    
                    if !Empty((TEMPDBF)->Unit2)
                       aadd(mdata1,;
                                '                               '+tran((TEMPDBF)->Unit2,'@X') )
                    endif       
                    for m:= 1 to len(mdata1)
                       chkpage()
                       @ prow()+1,0 say '³'
                       @ prow(),  1 say mdata1[ m ]
                       @ prow(),97 say '³                   ³                     ³'
                    next m
                    @ prow()+1,0 say '³                                                                                                ³                   ³                     ³'

          case mSEtcode == '2'

                mdata1:=;
                    {'       Net Proceeds          : '+tran((TEMPDBF)->Principal,'@Z 999,999,999.99') + if(omni,' (SUB-LIMIT)','') , ;
                     '       Term                  : '+tran((TEMPDBF)->Term,'@B 999') + '  '+tran(gettermunit((TEMPDBF)->termunit),'@X'), ;
                     '       Effective Rate        : '+tran((TEMPDBF)->Truerate,'@B 99.9999') + '%' + '       '+tran(getratetype((TEMPDBF)->ratetype),'@X'), ;
                     '       Monthly Amortization  : '+tran((TEMPDBF)->Amort,'@Z 999,999,999.99') + ' '+ tran(getpaytype((TEMPDBF)->Paytype),'@X'),  ;
                     '       Collateral/s          : '+tran((TEMPDBF)->Unit,'@X') ;
                     }

                     
                if !empty((TEMPDBF)->Unit2)
                   aadd(mdata1,;
                      '                               '+(TEMPDBF)->Unit2)

                endif
                for m:= 1 to len(mdata1)
                    chkpage()
                    @ prow()+1,0 say '³'
                    @ prow(),  1 say mdata1[ m ]
                    @ prow(),97 say '³                   ³                     ³'
                next m
                @ prow()+1,0 say '³                                                                                                ³                   ³                     ³'

          case mSEtcode == '3'
               aadd(mdata1,'       Unit                  : '+tran((TEMPDBF)->Unit,'@X') )
               if !Empty((TEMPDBF)->unit2)
                  aadd(mdata1,;
                    '                             : '+tran((TEMPDBF)->Unit2,'@X') ;
                    )
               endif
               aadd(mdata1,'       Dealer                : '+tran(eval({|| Dealer->(dbseek((TEMPDBF)->brcode+(TEMPDBF)->Dlrcode)),Dealer->Dlrname } ),'@X') )
               aadd(mdata1,'       Sales Representative  : '+tran((TEMPDBF)->Salesrep,'@X') )
               aadd(mdata1,'       Cash Price            : '+tran((TEMPDBF)->Purcamt,'@Z 999,999,999.99') )
               aadd(mdata1,'       Down Payment          : '+tran((TEMPDBF)->Downpay,'@Z 999,999,999.99') )
               aadd(mdata1,'       Net Proceeds          : '+tran((TEMPDBF)->Principal,'@Z 999,999,999.99') + if(omni,' (SUB-LIMIT)','') )
               aadd(mdata1,'       Term                  : '+tran((TEMPDBF)->term,'@B 999')+ '  '+tran(gettermunit((TEMPDBF)->termunit),'@X') )
               aadd(mdata1,'       Gross Rate            : '+tran((TEMPDBF)->Truerate,'@B 99.9999')+'%       '+tran(getratetype((TEMPDBF)->ratetype),'@X') )
               aadd(mdata1,'       Net Effective Rate    : '+tran((TEMPDBF)->Nerate,'@B 99.9999')+'%' )
               aadd(mdata1,'       Monthly Amortization  : '+tran((TEMPDBF)->Amort,'@Z 999,999,999.99') + ' '+tran(getpaytype((TEMPDBF)->Paytype),'@X') )
                          
                for m:= 1 to len(mdata1)
                    chkpage()
                    @ prow()+1,0 say '³'
                    @ prow(),  1 say mdata1[ m ]
                    @ prow(),97 say '³                   ³                     ³'
                next m
                @ prow()+1,0 say '³                                                                                                ³                   ³                     ³'

          Otherwise    //SEtcode == 4/5
              if genray_[ 2] == '1'  // <negotiable>
                  mdata1:=;
                     { '       Type                  : '+tran(gettrantype((TEMPDBF)->trantype),'@X') + if(omni,' (SUB-LIMIT)','') ,  ;
                       '       Term                  : '+tran((TEMPDBF)->term,'@B 999')+'  '+tran(gettermunit((TEMPDBF)->termunit),'@X'), ;
                       '       Effective Rate        : Minimum spread of '+tran((TEMPDBF)->Truerate,'99.99')+' % over the average cost of funds', ;
                       '       Payment Frequency     : '+tran(getpayfreq((TEMPDBF)->Payfreq),'@X'), ;
                       '       Notification          : '+tran(getnotifition((TEMPDBF)->Notfctn),'@X'), ;
                       '       Collection            : '+tran(getcollection((TEMPDBF)->Colexion),'@X'), ;
                       '       Recourse              : '+tran(getrecourse((TEMPDBF)->Recourse),'@X');
                      }
                       if !empty((TEMPDBF)->Obligor)
                          Aadd(mdata1,'       Obligor               : '+tran((TEMPDBF)->Obligor,'@X') )
                       endif
                       if !empty((TEMPDBF)->Colatrl)
                          aadd(mdata1,'       Collateral            : '+tran((TEMPDBF)->Colatrl,'@X') )
                       endif

                for m:= 1 to len(mdata1)
                    chkpage()
                    @ prow()+1,0 say '³'
                    @ prow(),  1 say mdata1[ m ]
                    @ prow(),97 say '³                   ³                     ³'
                next m
                @ prow()+1,0 say '³                                                                                                ³                   ³                     ³'

              else  //<fixed>
                  mdata1:=;
                     { '       Net Proceeds          : '+tran((TEMPDBF)->Principal,'@Z 999,999,999.99') + if(omni,' (SUB-LIMIT)','') , ;
                       '       Type                  : '+tran(gettrantype((TEMPDBF)->Trantype),'@X'), ;
                       '       Term                  : '+tran((TEMPDBF)->term,'@B 999') + '  '+tran(gettermunit((TEMPDBF)->termunit),'@X'), ;
                       '       Effective Rate        : '+Tran((TEMPDBF)->Truerate,'@B 99.9999')+'%' , ;
                       '       Payment Frequency     : '+tran(getpayfreq((TEMPDBF)->Payfreq),'@X'), ;
                       '       Amortization          : '+tran((TEMPDBF)->Amort,'@Z 999,999,999.99'), ;
                       '       Notification          : '+tran(getnotifition((TEMPDBF)->Notfctn),'@X'), ;
                       '       Collection            : '+tran(getcollection((TEMPDBF)->Colexion),'@X'), ;
                       '       Recourse              : '+tran(getrecourse((TEMPDBF)->Recourse),'@X') ;
                     }
                       if !empty((TEMPDBF)->Obligor)
                          Aadd(mdata1,'       Obligor               : '+tran((TEMPDBF)->Obligor,'@X') )
                       endif
                       if !empty((TEMPDBF)->Colatrl)
                          aadd(mdata1,'       Collateral            : '+tran((TEMPDBF)->Colatrl,'@X') )
                       endif

                for m:= 1 to len(mdata1)
                    chkpage()
                    @ prow()+1,0 say '³'
                    @ prow(),  1 say mdata1[ m ]
                    @ prow(),97 say '³                   ³                     ³'
                next m
                @ prow()+1,0 say '³                                                                                                ³                   ³                     ³'
              endif
       endcase
endif
return nil

////
Static function Actual_p3(genray_,mline,header_,cnt)   //Printing of Unavailed OT

local mdata:={},mdata1:={},mdata2:={},mdata3:={},mdata4:={},mdata5:={},mdata6:={}
local mdata3a:={},mdata31:={},mdata32:={},mdata33:={},mdata34:={}
local m,n,q,x,y,z,g,j,h,mtext

   chkpage()
   Oticket->( dbgoto(genray_[ 3 ]) )
   if mline == 2
       if cnt > len(header_);cnt:=len(header_);endif
       cnt:=if(cnt < 1,1,cnt)
       chkpage()
       @prow()+1,0 say '³'+ getclntname( Oticket->clntcode ) +' '+ header_[cnt]
       @ prow(),97 say '³                   ³                     ³'
       //cnt++
   else
       if cnt > len(header_);cnt:=len(header_);endif
       cnt:=if(cnt < 1,1,cnt)
       chkpage()
       @ prow()+1,0 say '³' + header_[cnt]
       @ prow(),97 say '³                   ³                     ³'
       //cnt++
   endif

   mSEtcode:=if(Facility->(dbseek(genray_[1])),Facility->SEtcode,'')
   topstr := tran( Facility->fcltycode, '@R 999-99' ) + " (" +;
             rtrim( Facility->fcltyalias ) + ") " + rtrim(Facility->fcltyname)
   chkpage()
   @ prow()+1,0 say '³'+topstr+spac(96-len(topstr))
   @ prow(), 97 say '³                   ³'
   @ prow(),119 say tran(Oticket->Credamt-Oticket->Crdavail,'@Z 999,999,999,999.99') + '  ³'

   do case
          case mSetcode == '1'
               mdata1:= ;
                   {'       Purchase Amount       : '+tran(Oticket->Proceeds,'@Z 999,999,999.99'),   ;
                    '       Guaranty Deposit      : '+tran(Oticket->Gd,'@B 99.999999')+'%',                 ;
                    '       Residual Value        : '+tran(Oticket->Rv,'@B 99.999999')+'%',                 ;
                    '       Term                  : '+tran(Oticket->term,'@B 999') +'  '+tran(gettermunit(Oticket->termunit),'@X') , ;
                    '       Effective Rate        : '+tran(Oticket->Truerate,'@B 99.9999')+'%'+ '       '+tran(getratetype(Oticket->Ratetype),'@X'), ;
                    '       Monthly Rental        : '+tran(Oticket->Amort,'@Z 999,999,999.99')+ ' '+ tran(getpaytype(Oticket->Paytype),'@X'), ;
                    '       Monthly Rental Factor : '+tran(Oticket->Factor,'@B 99.9999'),    ;
                    '       Item for Lease        : '+tran(Oticket->Unit,'@X')    ;
                    }
                    
                    if !Empty(Oticket->Unit2)
                       aadd(mdata1,;
                                '                               '+tran(Oticket->Unit2,'@X') )
                    endif       
                    for m:= 1 to len(mdata1)
                       chkpage()
                       @ prow()+1,0 say '³'
                       @ prow(),  1 say mdata1[ m ]
                       @ prow(),97 say '³                   ³                     ³'
                    next m
                    @ prow()+1,0 say '³                                                                                                ³                   ³                     ³'

          case mSEtcode == '2'
                mdata1:=;
                    {'       Net Proceeds          : '+tran(Oticket->Proceeds,'@Z 999,999,999.99') , ;
                     '       Term                  : '+tran(Oticket->Term,'@B 999') + '  '+tran(gettermunit(Oticket->termunit),'@X'), ;
                     '       Effective Rate        : '+tran(Oticket->Truerate,'@B 99.9999') + '%' + '       '+tran(getratetype(Oticket->ratetype),'@X'), ;
                     '       Monthly Amortization  : '+tran(Oticket->Amort,'@Z 999,999,999.99') + ' '+ tran(getpaytype(Oticket->Paytype),'@X'),  ;
                     '       Collateral/s          : '+tran(Oticket->Unit,'@X') ;
                     }

                     
                if !empty(Oticket->Unit2)
                   aadd(mdata1,;
                      '                               '+Oticket->Unit2)

                endif
                for m:= 1 to len(mdata1)
                    chkpage()
                    @ prow()+1,0 say '³'
                    @ prow(),  1 say mdata1[ m ]
                    @ prow(),97 say '³                   ³                     ³'
                next m
                @ prow()+1,0 say '³                                                                                                ³                   ³                     ³'

          case mSEtcode == '3'
               aadd(mdata1,'       Unit                  : '+tran(Oticket->Unit,'@X') )
               if !Empty(Oticket->unit2)
                  aadd(mdata1,;
                    '                             : '+tran(Oticket->Unit2,'@X') ;
                    )
               endif
               aadd(mdata1,'       Dealer                : '+tran(eval({|| Dealer->(dbseek(Oticket->brcode+Oticket->Dlrcode)),Dealer->Dlrname } ),'@X') )
               aadd(mdata1,'       Sales Representative  : '+tran(Oticket->Salesrep,'@X') )
               aadd(mdata1,'       Cash Price            : '+tran(Oticket->Purcamt,'@Z 999,999,999.99') )
               aadd(mdata1,'       Down Payment          : '+tran(Oticket->Downpay,'@Z 999,999,999.99') )
               aadd(mdata1,'       Net Proceeds          : '+tran(Oticket->Proceeds,'@Z 999,999,999.99') )
               aadd(mdata1,'       Term                  : '+tran(Oticket->term,'@B 999')+ '  '+tran(gettermunit(Oticket->termunit),'@X') )
               aadd(mdata1,'       Gross Rate            : '+tran(Oticket->Truerate,'@B 99.9999')+'%       '+tran(getratetype(Oticket->ratetype),'@X') )
               aadd(mdata1,'       Net Effective Rate    : '+tran(Oticket->Nerate,'@B 99.9999')+'%' )
               aadd(mdata1,'       Monthly Amortization  : '+tran(Oticket->Amort,'@Z 999,999,999.99') + ' '+tran(getpaytype(Oticket->Paytype),'@X') )

                for m:= 1 to len(mdata1)
                    chkpage()
                    @ prow()+1,0 say '³'
                    @ prow(),  1 say mdata1[ m ]
                    @ prow(),97 say '³                   ³                     ³'
                next m
                @ prow()+1,0 say '³                                                                                                ³                   ³                     ³'

          Otherwise    //SEtcode == 4/5
              if genray_[ 2] == '1'  // <negotiable>
                  mdata1:=;
                     { '       Type                  : '+tran(gettrantype(Oticket->trantype),'@X'),  ;
                       '       Term                  : '+tran(Oticket->term,'@B 999')+'  '+tran(gettermunit(Oticket->termunit),'@X'), ;
                       '       Effective Rate        : Minimum spread of '+tran(Oticket->Truerate,'99.99')+' % over the average cost of funds', ;
                       '       Payment Frequency     : '+tran(getpayfreq(Oticket->Payfreq),'@X'), ;
                       '       Notification          : '+tran(getnotifition(Oticket->Notfctn),'@X'), ;
                       '       Collection            : '+tran(getcollection(Oticket->Colexion),'@X'), ;
                       '       Recourse              : '+tran(getrecourse(Oticket->Recourse),'@X');
                      }
                       if !empty(Oticket->Obligor)
                          Aadd(mdata1,'       Obligor               : '+tran(Oticket->Obligor,'@X') )
                       endif
                       if !empty(Oticket->Colatrl)
                          aadd(mdata1,'       Collateral            : '+tran(Oticket->Colatrl,'@X') )
                       endif

                for m:= 1 to len(mdata1)
                    chkpage()
                    @ prow()+1,0 say '³'
                    @ prow(),  1 say mdata1[ m ]
                    @ prow(),97 say '³                   ³                     ³'
                next m
                @ prow()+1,0 say '³                                                                                                ³                   ³                     ³'

              else  //<fixed>
                  mdata1:=;
                     { '       Net Proceeds          : '+tran(Oticket->Proceeds,'@Z 999,999,999.99'), ;
                       '       Type                  : '+tran(gettrantype(Oticket->Trantype),'@X'), ;
                       '       Term                  : '+tran(Oticket->term,'@B 999') + '  '+tran(gettermunit(Oticket->termunit),'@X'), ;
                       '       Effective Rate        : '+Tran(Oticket->Truerate,'@B 99.9999')+'%' , ;
                       '       Payment Frequency     : '+tran(getpayfreq(Oticket->Payfreq),'@X'), ;
                       '       Amortization          : '+tran(Oticket->Amort,'@Z 999,999,999.99'), ;
                       '       Notification          : '+tran(getnotifition(Oticket->Notfctn),'@X'), ;
                       '       Collection            : '+tran(getcollection(Oticket->Colexion),'@X'), ;
                       '       Recourse              : '+tran(getrecourse(Oticket->Recourse),'@X') ;
                     }
                       if !empty(Oticket->Obligor)
                          Aadd(mdata1,'       Obligor               : '+tran(Oticket->Obligor,'@X') )
                       endif
                       if !empty(Oticket->Colatrl)
                          aadd(mdata1,'       Collateral            : '+tran(Oticket->Colatrl,'@X') )
                       endif

                for m:= 1 to len(mdata1)
                    chkpage()
                    @ prow()+1,0 say '³'
                    @ prow(),  1 say mdata1[ m ]
                    @ prow(),97 say '³                   ³                     ³'
                next m
                @ prow()+1,0 say '³                                                                                                ³                   ³                     ³'
              endif
  endcase
return nil


///////////////////////////////////////////
// printing of Existing Liabilities
///////////////////////////////////////////

Static Function Actual_p4(genray_,rpt)    
local mdata:={},mdata1:={},mdata2:={},mdata3:={},mdata4:={},mdata5:={},mdata6:={}
local mdata3a:={},mdata31:={},mdata32:={},mdata33:={},mdata34:={},mdata6a:={}
local m,n,q,x,y,z,g,j,h,mtext,xAmnt:=0
local tempdbf
//for x:=1 to len(genray_)

    tempdbf := genray_[ 5]

    if len(genray_[3]) > 1

       mSEtcode:=if(Facility->(dbseek(genray_[1])),Facility->SEtcode,'')
       topstr := tran( Facility->fcltycode, '@R 999-99' ) + " (" +;
                 rtrim( Facility->fcltyalias ) + ") " + rtrim(Facility->fcltyname)
	   prntbrnch := rtrim(EVAL({||BRANCHES->(DBSEEK(genray_[6])),'('+BRANCHES->BRCODE+'-'+rtrim(BRANCHES->BRNAME)+') '+rtrim(genray_[4])}))
       chkpage()
       @ prow()+1,0 say '³'+topstr+spac(96-len(topstr))               +  '³'
       @ prow(),98  say trans ( genray_[ 2],'@Z 999,999,999,999.99')  + ' ³'
       @ prow(),119 say trans ( 0,'@Z 999,999,999,999.99' )           +'  ³'
	   
	   @ prow()+1,0 say '³' +SPACE(7)+ prntbrnch +spac(89-len(prntbrnch))               +  '³'
       @ prow(),117 say '³'
       @ prow(),139 say '³'
	   
IF UPPER(tempdbf) == 'ACCTMAST'
       do case
          case mSEtcode == '1'
              for y:=1 to len(genray_[ 3 ])
                 (tempdbf)->(dbgoto(genray_[ 3,y]))
                 aadd(mdata1,(tempdbf)->Gd)
                 aadd(mdata2,(tempdbf)->Rv)
                 aadd(mdata3,(tempdbf)->Truerate)
                 aadd(mdata4,(tempdbf)->Amort)
                 if(!empty((tempdbf)->Matdate) .and. ascan(mdata5,(tempdbf)->matdate) == 0,;
                    aadd(mdata5,(tempdbf)->Matdate), .f. )
                 if(!empty((tempdbf)->Orixunit) .and. ascan(mdata6,(tempdbf)->Orixunit) == 0,;
                    aadd(mdata6,(tempdbf)->Orixunit),.f.)
              next y
              asort(mdata1)
              asort(mdata2)
              asort(mdata3)
              asort(mdata5)
              asort(mdata6)
              if( mdata1[ 1 ] == atail(mdata1),eval({|| asize(mdata1,1)}),.f.)
              if( mdata2[ 1 ] == atail(mdata2),eval({|| asize(mdata2,1)}),.f.)
              if( mdata3[ 1 ] == atail(mdata3),eval({|| asize(mdata3,1)}),.f.)
              if( mdata5[ 1 ] == atail(mdata5),eval({|| asize(mdata5,1)}),.f.)
              if( mdata6[ 1 ] == atail(mdata6),eval({|| asize(mdata6,1)}),.f.)
              aeval(mdata6,{ |i_| if( Orixunit->(dbseek(i_)),;
                  aadd(mdata6a,Orixunit->unitname ),.f.) } )
              mdata31:=;
                {'       Guaranty Deposit      : '+tran(mdata1[1],'@B 99.9999') +if(len(mdata1) == 1, '%', '% - '+tran(atail(mdata1),'@B 99.9999') + '%'),;
                 '       Residual Value        : '+tran(mdata2[1],'@B 99.9999') + if(len(mdata2) == 1,'%','% - '+tran(atail(mdata2),'@B 99.9999') + '%'), ;
                 '       Effective Rate        : '+tran(mdata3[1],'@B 99.9999') + if(len(mdata3) == 1,'%','% - '+tran(atail(mdata3),'@B 99.9999') + '%'), ;
                 '       Total Monthly Rental  : '+tran(eval( {|| aeval(mdata4,{|c_| xAmnt+= c_ } ),xAmnt} ) ,'@Z 999,999,999.99'), ;
                 '       Maturity Date         : '+dtoc(mdata5[1])+if(len(mdata5) == 1,'', ' - ' + dtoc(atail(mdata5) ) ) ;
                 }
                for x:= 1 to len(mdata31)
                    chkpage()
                    @ prow()+1,0 say '³'+mdata31[x]
                    @ prow(),97 say '³                   ³                     ³'
                next x
                if !empty(mdata6a)
                   chkpage()
                   @prow()+1,0 say '³'
                   @prow(), 8 say 'Item for Lease        : '+mdata6a[1]
                   @ prow(),97 say '³                   ³                     ³'
                endif
                for x:= 2 to len(mdata6a)
                  chkpage()
                  @prow()+1,0 say '³'
                  @ prow(),32 say mdata6a[x]
                  @ prow(),97 say '³                   ³                     ³'
                next x
                @ prow()+1,0 say '³                                                                                                ³                   ³                     ³'
          case mSEtcode == '2'
              for y:= 1 to len(genray_[ 3])
                  (tempdbf)->(dbgoto(genray_[ 3,y]))
                  if alltrim((tempdbf)->termunit) == '2'
                     if(ascan(mdata1,(tempdbf)->Term) == 0, aadd(mdata1,(tempdbf)->term), .f. )
                  else
                     if( ascan(mdata1,conv_unit((tempdbf)->term) ) == 0,aadd(mdata1,conv_unit((tempdbf)->term)), .f.)
                  endif
                  //aadd(mdata2,if((tempdbf)->termunit == '2',
                  aadd(mdata2,(tempdbf)->truerate)
                  aadd(mdata3,(tempdbf)->amort)
                  //aadd(mdata4,(tempdbf)->matdate)
                  if(!empty((tempdbf)->Matdate) .and. ascan(mdata4,(tempdbf)->matdate) == 0,;
                    aadd(mdata4,(tempdbf)->Matdate), .f. )
                 if(!empty((tempdbf)->Orixunit) .and. ascan(mdata6,(tempdbf)->Orixunit) == 0,;
                    aadd(mdata6,(tempdbf)->Orixunit),.f.)
              next y
              asort(mdata1)
              if( mdata1[ 1 ] = atail(mdata1),eval({|| asize(mdata1,1)}),.f.)
              asort(mdata2)
              if( mdata2[ 1 ] = atail(mdata2),eval({|| asize(mdata2,1)}),.f.)
              asort(mdata4)
              if( mdata4[ 1 ] = atail(mdata4),eval({|| asize(mdata4,1)}),.f.)
              aeval(mdata6,{ |i_| if( Orixunit->(dbseek(i_)),;
                  aadd(mdata6a,Orixunit->unitname ),.f.) } )
              mdata31:=;
                     {'       Term                  : '+tran(mdata1[1],'@B 999') +if(len(mdata1) == 1,'',' - '+tran(atail(mdata1),'@B 999')) + ' Month/s' ,;
                      '       Effective Rate        : '+tran(mdata2[1],'@B 99.9999') +if(len(mdata2) == 1,'%','% - '+ tran(atail(mdata2),'@B 99.9999')+'%'),;
                      '       Total Amortization    : '+tran(eval( {|| aeval(mdata3,{|c_| xAmnt+= c_ } ),xAmnt} ) ,'@Z 999,999,999.99'), ;
                      '       Maturity Date         : '+dtoc(mdata4[1])+if(len(mdata4) == 1,'',' - ' +dtoc(atail(mdata4) ) ) ;
                      }
              for x:= 1 to len(mdata31)
                  chkpage()
                  @ prow()+1,0 say '³' + mdata31[ x ]
                  @ prow(),97 say '³                   ³                     ³'
              next x
              if !empty(mdata6a)
                 chkpage()
                 @ prow()+1,0 say '³'
                 @ prow(),  8 say 'Collateral            : '+ mdata6a[1]
                 @ prow(),97 say '³                   ³                     ³'
              endif
              for x:= 2 to len(mdata6a)
                 chkpage()
                 @ prow()+1,0 say '³'
                 @ prow() ,32 say mdata6a[x]
                 @ prow(),97 say '³                   ³                     ³'
              next x
              @ prow()+1,0 say '³                                                                                                ³                   ³                     ³'
          case mSEtcode == '3'

              for y:=1 to len(genray_[ 3 ])
                  (tempdbf)->(dbgoto(genray_[ 3,y]))
                  //aadd(mdata1,(tempdbf)->term)
                  if alltrim((tempdbf)->termunit) == '2'
                     if(ascan(mdata1,(tempdbf)->Term) == 0, aadd(mdata1,(tempdbf)->term), .f. )
                  else
                     if( ascan(mdata1,conv_unit((tempdbf)->term)) == 0,aadd(mdata1,conv_unit((tempdbf)->term) ), .f.)
                  endif
                  aadd(mdata2,(tempdbf)->Truerate)
                  aadd(mdata3,(tempdbf)->amort)
                  if(!empty((tempdbf)->Orixunit) .and. ascan(mdata6,(tempdbf)->Orixunit) == 0,;
                    aadd(mdata6,(tempdbf)->Orixunit),.f.)
              next y
              asort( mdata1)
              if( mdata1[ 1 ] = atail(mdata1),eval({|| asize(mdata1,1)}),.f.)
              asort( mdata2)
              if( mdata2[ 1 ] = atail(mdata2),eval({|| asize(mdata2,1)}),.f.)
              asort( mdata3)
              if( mdata3[ 1 ] = atail(mdata3),eval({|| asize(mdata3,1)}),.f.)
              aeval(mdata6,{ |i_| if( Orixunit->(dbseek(i_)),;
                  aadd(mdata6a,Orixunit->unitname ),.f.) } )
              mdata31:=;
                     {'       Term                  : '+tran(mdata1[1],'@B 999') +if(len(mdata1) == 1,'',' - '+tran(atail(mdata1),'@B 999')) + ' Month/s' ,;
                      '       Gross Rate            : '+tran(mdata2[1],'@B 99.9999') +if(len(mdata2) == 1,'%','% - '+ tran(atail(mdata2),'@B 99.9999')+'%'),;
                      '       Total Amortization    : '+tran(eval( {|| aeval(mdata3,{|c_| xAmnt+= c_ } ),xAmnt} ) ,'@Z 999,999,999.99');
                      }
              for x:= 1 to len(mdata31)
                  chkpage()
                  @ prow()+1,0 say '³' + mdata31[ x ]
                  @ prow(),97 say '³                   ³                     ³'
              next x
              if !empty(mdata6a)
                 chkpage()
                 @ prow()+1,0 say '³'
                 @ prow(),  8 say 'Collateral            : '+ mdata6a[1]
                 @ prow(),97 say '³                   ³                     ³'
              endif
              for x:= 2 to len(mdata6a)
                 chkpage()
                 @ prow()+1,0 say '³'
                 @ prow() ,32 say mdata6a[x]
                 @ prow(),97 say '³                   ³                     ³'
              next x
              @ prow()+1,0 say '³                                                                                                ³                   ³                     ³'
          case mSetcode == '4' .or. mSetcode == '5'   //otherwise
               for y:=1 to len(genray_[ 3])
                  (tempdbf)->(dbgoto(genray_[ 3,y]))
                  if alltrim((tempdbf)->termunit) == '2'
                     if(ascan(mdata1,(tempdbf)->Term) == 0, aadd(mdata1,(tempdbf)->term), .f. )
                  else
                     if( ascan(mdata1,conv_unit((tempdbf)->term)) == 0,aadd(mdata1,conv_unit((tempdbf)->term) ), .f.)
                  endif
                  aadd(mdata2,(tempdbf)->truerate)
                  //aadd(mdata3,(tempdbf)->Matdate)
                  if(!empty((tempdbf)->Matdate) .and. ascan(mdata3,(tempdbf)->matdate) == 0,;
                    aadd(mdata3,(tempdbf)->Matdate), .f. )
              next y
              asort(mdata1)
              if( mdata1[ 1 ] = atail(mdata1),eval({|| asize(mdata1,1)}),.f.)
              asort(mdata2)
              if( mdata2[ 1 ] = atail(mdata2),eval({|| asize(mdata2,1)}),.f.)
              asort(mdata3)
              if( mdata3[ 1 ] = atail(mdata3),eval({|| asize(mdata3,1)}),.f.)
              mdata31:=;
                     {'       Term                  : '+tran(mdata1[1],'@B 999') +if(len(mdata1) == 1,'',' - '+tran(atail(mdata1),'@B 999') ) + ' Month/s' ,;
                      '       Effective Rate        : '+tran(mdata2[1],'@B 99.9999') +if(len(mdata2) == 1,'%','% - '+ tran(atail(mdata2),'@B 99.9999')+'%' ), ;
                      '       Maturity Date         : '+dtoc(mdata3[1]) +if(len(mdata3) == 1,'',' - '+ dtoc(atail(mdata3) ) )  ;
                      }
              for x:= 1 to len(mdata31)
                  chkpage()
                  @ prow()+1,0 say '³' + mdata31[ x ]
                  @ prow(),97 say '³                   ³                     ³'
              next x
               @ prow()+1,0 say '³                                                                                                ³                   ³                     ³'
       endcase
ENDIF
    else  //single Facility

     ***** if genray_[2] > 0

       mSEtcode:=if(Facility->(dbseek(genray_[ 1])),Facility->SEtcode,'')
       topstr := tran( Facility->fcltycode, '@R 999-99' ) + " (" +;
                 rtrim( Facility->fcltyalias ) + ") " + rtrim(Facility->fcltyname)
	   prntbrnch := rtrim(EVAL({||BRANCHES->(DBSEEK(genray_[6])),'('+BRANCHES->BRCODE+'-'+rtrim(BRANCHES->BRNAME)+') '+rtrim(genray_[4])}))
       chkpage()
       @ prow()+1,0 say '³'+topstr+spac(96-len(topstr))+'³'
       @ prow(),98 say tran(genray_[ 2],'@Z 999,999,999,999.99')  + ' ³'
       @ prow(),119 say tran(0,'@Z 999,999,999,999.99')+'  ³'
	   
	   @ prow()+1,0 say '³' +SPACE(7)+ prntbrnch +spac(89-len(prntbrnch))               +  '³'
       @ prow(),117 say '³'
       @ prow(),139 say '³'
	   
IF UPPER(tempdbf) == 'ACCTMAST'
       (tempdbf)->(dbgoto(genray_[ 3,1]))

       do case
          case mSetcode == '1'
               mdata1:= ;
                   {'       Purchase Amount       : '+tran((tempdbf)->Principal,'@Z 999,999,999.99'),   ;
                    '       Guaranty Deposit      : '+tran((tempdbf)->Gd,'@B 99.999999')+'%',                 ;
                    '       Residual Value        : '+tran((tempdbf)->Rv,'@B 99.999999')+'%',                 ;
                    '       Term                  : '+tran((tempdbf)->term,'@B 999') +'  '+tran(gettermunit((tempdbf)->termunit),'@X') , ;
                    '       Effective Rate        : '+tran((tempdbf)->Truerate,'@B 99.9999')+'%'+ '       '+tran(getratetype((tempdbf)->Ratetype),'@X'), ;
                    '       Monthly Rental        : '+tran((tempdbf)->Amort,'@Z 999,999,999.99')+ ' '+ tran(getpaytype((tempdbf)->Paytype),'@X'), ;
                    '       Monthly Rental Factor : '+tran((tempdbf)->Factor,'@B 99.9999'),    ;
                    '       Item for Lease        : '+tran((tempdbf)->Unit,'@X')    ;
                    }
                    
                    if !Empty((tempdbf)->Unit2)
                       aadd(mdata1,;
                                '                               '+tran((tempdbf)->Unit2,'@X') )
                    endif
                    for m:= 1 to len(mdata1)
                       chkpage()
                       @ prow()+1,0 say '³'
                       @ prow(),  1 say mdata1[ m ]
                       @ prow(),97 say '³                   ³                     ³'
                    next m
                    @ prow()+1,0 say '³                                                                                                ³                   ³                     ³'

          case mSEtcode == '2'
                mdata1:=;
                    {'       Net Proceeds          : '+tran((tempdbf)->Principal,'@Z 999,999,999.99') , ;
                     '       Term                  : '+tran((tempdbf)->Term,'@B 999') + '  '+tran(gettermunit((tempdbf)->termunit),'@X'), ;
                     '       Effective Rate        : '+tran((tempdbf)->Truerate,'@B 99.9999') + '%' + '       '+tran(getratetype((tempdbf)->ratetype),'@X'), ;
                     '       Monthly Amortization  : '+tran((tempdbf)->Amort,'@Z 999,999,999.99') + ' '+ tran(getpaytype((tempdbf)->Paytype),'@X'),  ;
                     '       Collateral/s          : '+tran((tempdbf)->Unit,'@X') ;
                     }

                     
                if !empty((tempdbf)->Unit2)
                   aadd(mdata1,;
                      '                               '+(tempdbf)->Unit2)

                endif
                for m:= 1 to len(mdata1)
                    chkpage()
                    @ prow()+1,0 say '³'
                    @ prow(),  1 say mdata1[ m ]
                    @ prow(),97 say '³                   ³                     ³'
                next m
                @ prow()+1,0 say '³                                                                                                ³                   ³                     ³'

          case mSEtcode == '3'
               aadd(mdata1,'       Unit                  : '+tran((tempdbf)->Unit,'@X') )
               if !Empty((tempdbf)->unit2)
                  aadd(mdata1,;
                    '                             : '+tran((tempdbf)->Unit2,'@X') ;
                    )
               endif
               aadd(mdata1,'       Dealer                : '+tran(eval({|| Dealer->(dbseek((tempdbf)->brcode+(tempdbf)->Dlrcode)),Dealer->Dlrname } ),'@X') )
               aadd(mdata1,'       Sales Representative  : '+tran((tempdbf)->Salesrep,'@X') )
               aadd(mdata1,'       Cash Price            : '+tran((tempdbf)->Purcamt,'@Z 999,999,999.99') )
               aadd(mdata1,'       Down Payment          : '+tran((tempdbf)->Downpay,'@Z 999,999,999.99') )
               aadd(mdata1,'       Net Proceeds          : '+tran((tempdbf)->Principal,'@Z 999,999,999.99') )
               aadd(mdata1,'       Term                  : '+tran((tempdbf)->term,'@B 999')+ '  '+tran(gettermunit((tempdbf)->termunit),'@X') )
               aadd(mdata1,'       Gross Rate            : '+tran((tempdbf)->Truerate,'@B 99.9999')+'%       '+tran(getratetype((tempdbf)->ratetype),'@X') )
               aadd(mdata1,'       Net Effective Rate    : '+tran((tempdbf)->Nerate,'@B 99.9999')+'%' )
               aadd(mdata1,'       Monthly Amortization  : '+tran((tempdbf)->Amort,'@Z 999,999,999.99') + ' '+tran(getpaytype((tempdbf)->Paytype),'@X') )

                for m:= 1 to len(mdata1)
                    chkpage()
                    @ prow()+1,0 say '³'
                    @ prow(),  1 say mdata1[ m ]
                    @ prow(),97 say '³                   ³                     ³'
                next m
                @ prow()+1,0 say '³                                                                                                ³                   ³                     ³'
          case mSetcode == '4' .or. mSetcode == '5' //Otherwise    //SEtcode == 4/5
                  //mdata1:=;
                    aadd(mdata1, '       Net Proceeds          : '+tran((tempdbf)->Principal,'@Z 999,999,999.99') )
                    aadd(mdata1, '       Type                  : '+tran(gettrantype((tempdbf)->Trantype),'@X') )
                    aadd(mdata1, '       Term                  : '+tran((tempdbf)->term,'@B 999') + '  '+tran(gettermunit((tempdbf)->termunit),'@X') )
                    aadd(mdata1, '       Effective Rate        : '+Tran((tempdbf)->Truerate,'@B 99.9999')+'%' )
                    aadd(mdata1, '       Payment Frequency     : '+tran(getpayfreq((tempdbf)->Payfreq),'@X') )
                    if(!empty((tempdbf)->Amort), aadd(mdata1, '       Amortization          : '+tran((tempdbf)->Amort,'999,999,999.99') ),.f.)
                    aadd(mdata1, '       Notification          : '+tran(getnotifition((tempdbf)->Notfctn),'@X') )
                    aadd(mdata1, '       Collection            : '+tran(getcollection((tempdbf)->Colexion),'@X') )
                    aadd(mdata1, '       Recourse              : '+tran(getrecourse((tempdbf)->Recourse),'@X') )

                       if !empty((tempdbf)->Obligor)
                          Aadd(mdata1,'       Obligor               : '+tran((tempdbf)->Obligor,'@X') )
                       endif
                       if !empty((tempdbf)->Colatrl)
                          aadd(mdata1,'       Collateral            : '+tran((tempdbf)->Colatrl,'@X') )
                       endif

                for m:= 1 to len(mdata1)
                    chkpage()
                    @ prow()+1,0 say '³'
                    @ prow(),  1 say mdata1[ m ]
                    @ prow(),97 say '³                   ³                     ³'
                next m
                @ prow()+1,0 say '³                                                                                                ³                   ³                     ³'
       endcase
     ****** endif
ENDIF
    endif
return nil
////
*static
function chkotktactaken( xclnt, mline, mhead, mcanum )    //Check Unavailed OT
local mtrue := .f., mclnt := if( xclnt == nil, Caheader->clntcode, xclnt )
local mdbf_ := savedbf(), mindx := Oticket->( indexord() )
mhead:={}
mcanum:={}
dbselectar( 'Oticket' )
Oticket->( ordsetfocus( 2 ) )
if Oticket->( dbseek( Caheader->brcode+mclnt ) )
   while Oticket->Clntcode == mclnt
     if Oticket->actaken == '3'
      if Oticket->proceeds - Oticket->prnavail > 0
         mtrue  := .t.
         aadd(mcanum,Oticket->otnumber)
         mline  := ''
         aadd( mhead, alltrim( 'OT N§ ' + Oticket->otnumber) )
      endif
     endif
     oticket->(dbskip())
   ENDDO
endif
Oticket->( ordsetfocus( mindx ) )
restdbf( mdbf_ )

return( mtrue )

*****************************************************************************
*
*
static function chkclntactaken( xclnt, mline, mhead, mcanum, weng )          //Check unavailed CA Line
*****************************************************************************
local mtrue := .f., mclnt:= if( xclnt == nil,Caheader->clntcode, xclnt )
local mdbf_ := savedbf(),x,mu:=Caheader->(indexord()),recnum := 0
local _nrecno := Caheader->(recno())
local mu2:=OLCAHEAD->(indexord()), _nrecno2 := OLCAHEAD->(recno())

// weng := if(weng==nil,Caheader->Canumber,weng )
dbselectar ( 'Caheader' )
Caheader-> ( ordsetfocus( 3 ) )

  
if Caheader->( dbseek( if( xclnt == nil,g_PAR_BRCH+mclnt, mclnt ) ) )
  while Caheader->Clntcode == if(len(mclnt) == 10,substr(mclnt,4,10),mclnt) .and. !Caheader->(eof()) .and. ;
        Caheader->brcode == g_PAR_BRCH
   if Caheader->Actaken == '3' .and. Caheader->Canumber <> weng
      if Caheader->caline - Caheader->availed > 0

         mtrue  := .t.
					 
         aadd( mcanum, CAHEADER->BRCODE+Caheader->canumber )
         mline  := Caheader->linetype
         mhead  := alltrim;
                   (getclntname( xclnt ) +;
                   if( mline == '1', ' Omnibus', ' Regular' ) ) // +;
                      //' Line CA N§ ' + Caheader->canumber )

         recnum := Caheader->(recno())

      endif

   endif
   Caheader->(dbskip(+1))
  enddo
endif
Caheader->(dbsetorder(mu))
Caheader->(dbgoto(_nrecno))  // abb 02.01.2005

IF mclnt <> nil
	dbselectar ( 'OLCAHEAD' )
	OLCAHEAD-> ( ordsetfocus( 3 ) )

	//if OLCAHEAD->( dbseek( if( xclnt == nil,g_PAR_BRCH+mclnt, mclnt ) ) )
	if OLCAHEAD->( dbseek(  mclnt ) )

	  while OLCAHEAD->brcode+OLCAHEAD->Clntcode == mclnt .and. !OLCAHEAD->(eof())

	   if OLCAHEAD->Actaken == '3' .and. OLCAHEAD->Canumber <> weng
		  if OLCAHEAD->caline - OLCAHEAD->availed > 0

			 mtrue  := .t.
						 
			 aadd( mcanum, OLCAHEAD->BRCODE+OLCAHEAD->canumber )
			 mline  := OLCAHEAD->linetype
			 mhead  := alltrim;
					   (getclntname( xclnt ) +;
					   if( mline == '1', ' Omnibus', ' Regular' ) ) // +;
						  //' Line CA N§ ' + OLCAHEAD->canumber )

			 recnum := OLCAHEAD->(recno())

		  endif

	   endif
	   OLCAHEAD->(dbskip(+1))
	  enddo
	endif
	OLCAHEAD->(dbsetorder(mu2))
	OLCAHEAD->(dbgoto(_nrecno2))  // abb 02.01.2005
ENDIF

restdbf ( mdbf_ )
//
//if recnum <> 0
  // Caheader->(dbgoto(recnum))
//endif
//
return( mtrue )

////
*static
function getclntname( xclnt )       //Display the Client name
local mindx := Client->( indexord() )
local mdbf_ := savedbf(), mname := ''

if valtype( xclnt ) != 'U'
   dbselectar( 'Client' )
   Client->( ordsetfocus( 1 ) )
   Client->( dbseek( xclnt ) )//Client->( dbseek( Caheader->brcode+xclnt ) )
   mname := alltrim( Client->fullname )
   Client->( ordsetfocus( mindx ) )
endif
restdbf( mdbf_ )
return( mname )

*********************************
static function _getbrch(cbrcode)
*********************************
local reval
if branches->(dbseek(cbrcode))
	reval := '['+branches->brcode+']'+' - '+ Branches->brname
endif

return reval
/*
***********************************
*
static function chkgrpcode()
***********************************
local arr_ := {}, mdbf_ := savedbf(), mmem   // and the existing liabilities
local mindx := Grpmembr->( indexord() ),xCode:=Caheader->Clntcode

dbselectar( 'Grpmembr' )
Grpmembr->( ordsetfocus( 2 ) )
Grpmembr->( dbseek( Caheader->brcode+Caheader->clntcode ) )
mmem := Grpmembr->grupcode
Grpmembr->( ordsetfocus( 1 ) )
Grpmembr->( dbseek( Caheader->brcode+mmem ) )

Grpmembr->( dbeval( { || if ( Grpmembr->Clntcode # xCode ,;
                              aadd( arr_, Grpmembr->clntcode ),;
                              .f. ;
                            ) ;
                    },,;
                    { || mmem == Grpmembr->grupcode .and. Grpmembr->brcode == g_PAR_BRCH } ) )    && RED 020805 REPLACED 'Caheader->brcode WITH g_PAR_BRCH
Grpmembr->( ordsetfocus( mindx ) )
restdbf( mdbf_ )
return( arr_ )
*/
////
////
static function bye_bye( xbreak )
return( eval( { | n | break( xbreak ), n } ) )
///
Static Function ind_take(xcode)
local mfg
Industry->(dbseek(xcode))
mfg:=Industry->Indcode +' '+Substr(Industry->Indname,1,33)
return mfg
////
Static Function Conv_unit(xterm)
local  retval:=0
retval:=round(xterm/30,0)
return retval

////
Static Function Getrisk(xcode)
local gdf:=spac(16),mdf
if Corpinfo->(dbseek(Caheader->brcode+xcode))
   mdf:=getcredrisk(alltrim(Corpinfo->Credrisk))
   gdf:=Corpinfo->Credrisk+' '+mdf
endif
return gdf

////
static Function head1(mclient)             //Primary header
local cdf:=client->(indexord()),bf:=select(),gf:=indexord(),mu:=recno()
dbselectarea('client')
dbsetorder(1)
Client->(dbseek(Caheader->Brcode+Caheader->Clntcode))
mclient := Client->Fullname
setprc(0,0)
@ prow()+1,0 say 'ORIX METRO Leasing & Finance Corporation                                                                           Account Management System'
@ prow()+1,0 say 'Credit Application                                                                                                       '+dtoc(date())+' '+time()
@ prow()+1,0 say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
@ prow()+1,0 say '³    Client Number       : '+tran(Caheader->Clntcode,'@R 99-99999')+'                                            CA Number     : '+Caheader->Canumber+ '                                       ³'
@ prow()+1,0 say '³    Client Name         : '+Client->Fullname+'  CA Date       : '+dtoc(Caheader->Cadate)+'                                  ³'
@ prow()+1,0 say '³    Address             : '+Client->Address1+'                      Review Date   : '+dtoc(Caheader->Revdate)+'                                  ³'
@ prow()+1,0 say '³                          '+client->Address2+'                      Industry      : '+ind_take(Client->Indcode)+ '      ³'
@ prow()+1,0 say '³                                                                 Credit Risk Classification : '+getrisk(Caheader->CLntcode)+'                           ³'
@ prow()+1,0 say 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
@ prow()+1,0 say '³                                                                                                ³ OUTSTANDING IN    ³AMOUNT OF LINE AND/OR³'
@ prow()+1,0 say '³                          DESCRIPTION OF CREDIT FACILITIES                                      ³ CURRENCY OF DEBT  ³SPECIAL TRANSACTION  ³'
@ prow()+1,0 say 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
Client->(dbsetorder(cdf))
dbselectarea(bf)
dbsetorder(gf)
dbgoto(mu)

return nil
///
Static Function hd_fclty(mtext)       //Display the Underlined Group Heading

chkpage()
@ prow()+1,0 say '³'
SETFONT('UNDERLINE')
@ PROW(),pcol() SAY mtext 
SETFONT('OFFUNDERLINE')
@ PROW(),103 SAY '³                   ³                     ³'
chkpage()
@ prow()+1,0 say '³                                                                                                ³                   ³                     ³'
return nil

Static Function Chkpage()    //Check if new page is to printed

if npage == 1
   if prow() > 42
      @ prow()+1,0 say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
      @ prow()+1,0 say '( Next Page Please.)'
      approver()
      //npage++
      Head2()
   endif
else
   if prow() > 52
      @ prow()+1,0 say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
      Head2()
   endif
endif
return nil

Static Function Head2(ewan)                                          //Secondary heading other than page 1
local mao:=eval({ || Ao->(dbseek(Caheader->Aocode)), Ao->Aoname } )
local mpost:=Ao->Aopost
ewan:=if(ewan == nil, .f.,ewan)

npage++
if npage > 2  .and. !ewan
   @ prow()+2,1    say mao

   if !empty(cdivhead)
      @ prow()  ,100   say upper(cdivhead)
   endif

   @ prow()+1,1    say upper(mpost)
   if !empty(cdivhead)
         @ prow()  ,100   say upper(cdivpost)
   endif


endif
__eject()
setprc(0,0)
@ prow()+1,0 say ' CA Number       : '+Caheader->Canumber+'                                                                                                         Page: '+tran(npage,'99999')
@ prow()+1,0 say ' Client Name     : '+ mclient
if !ewan
   @ prow()+1,0 say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
endif
return nil

*****************************************
*
Static Function lastpage(mtot1,mtot2)                     //Display the last page to be printed
*****************************************
local mao:=eval({ || Ao->(dbseek(Caheader->Aocode)), Ao->Aoname } )
local mpost:=Ao->Aopost
local sSECHELD:= COLLMEM( 'CA_SEC', CAHEADER->CANUMBER, CAHEADER->BRCODE )
local sOBTAIN := COLLMEM( 'CA_OBT', CAHEADER->CANUMBER, CAHEADER->BRCODE )
local scline  := mlcount(sSECHELD,133),is_app:=.f.       && RED 112905 Caheader->Secheld
local obline  := mlcount(sOBTAIN ,133),i,prnt_ao:=.f.    && RED 112905 Caheader->Obtain
memvar mtotblnc,mtotcrdt

if prow() <= 39    // .and. ( !empty(Caheader->Secheld) .or. !empty(Cahedear->Obtain) )


   @ prow()+1, 0 say 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
   @ prow()+1, 0 say '³   TOTAL  :'
   @ prow(),  97 say '³'
   @ prow(),  98 say tran(mtot1,'@Z 999,999,999,999.99') + ' ³'
   @ prow(), 119 say tran(mtot1+mtot2-npending,'@Z 999,999,999,999.99') + '  ³'
   @ prow()+1,0 say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
   IF CA_SEC->(DBSEEK(CAHEADER->BRCODE+CAHEADER->CANUMBER))     && RED 112905 if !empty(CAheader->Secheld)
      if prow() > 42
        is_app:=.t.
        if npage == 1
           @ prow()+1,0 say ''
           @ prow()+1,0 say '( Next Page Please.)'
        endif
        approver()
        head2(.t.)
        @ prow()+1,0 say ''
      endif
      prnt_ao:=.t.
      @ prow()+1,0 say ''
      setprc(prow(),0)
      SETFONT('UNDERLINE')
      @ prow(),pcol()say 'SECURITY HELD'
      SETFONT('OFFUNDERLINE')
   ENDIF
   for i:=1 to scline
      if prow() > 42
        is_app:=.t.
        if npage == 1
           @ prow()+1,0 say ''
           @ prow()+1,0 say '( Next Page Please.)'
        endif
        approver()
        head2(.t.)
        @ prow()+1,0 say ''
      endif
       @ prow()+1,1 say memoline( sSECHELD, 133, i )    && RED 112905 REPLACED 'Caheader->Secheld
   next i
   @ prow()+1,0 say ''


   IF CA_OBT->(DBSEEK(CAHEADER->BRCODE+CAHEADER->CANUMBER))      && RED 112905 if !empty(Caheader->Obtain)
      if prow() > 42
        is_app:=.t.
        if npage == 1
           @ prow()+1,0 say ''
           @ prow()+1,0 say '( Next Page Please.)'
        endif
        approver()
        head2(.t.)
        @ prow()+1,0 say ''
      endif
      prnt_ao:=.t.
      @ prow()+1,0 say ''
      setprc(prow(),0)
      SETFONT('UNDERLINE')
      @ prow(),pcol() say 'TO BE OBTAINED / OTHER CONDITIONS'
      SETFONT('OFFUNDERLINE')
   ENDIF
   for i:= 1 to obline
      if prow() > 42
        is_app:=.t.
        if npage == 1
           @ prow()+1,0 say ''
           @ prow()+1,0 say '( Next Page Please.)'
        endif
        approver()
        head2(.t.)
        @ prow()+1,0 say ''
      endif
      @ prow()+1,1 say memoline( sOBTAIN,133,i )      && RED 112905 Caheader->Obtain
   next i
   if !is_app
     approver()
   endif
else

   @ prow()+1,0 say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
   if npage == 1
      @ prow()+1,0 say '( Next Page Please.)'
      approver()
   endif
   head2()
   //@ prow()+1, 0 say 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
   @ prow()+1, 0 say '³   TOTAL  :'
   @ prow(),  97 say '³'
   @ prow(),  98 say tran(mtotblnc,'@Z 999,999,999,999.99') + ' ³'
   @ prow(), 119 say tran(mtotblnc+mtotcrdt,'@Z 999,999,999,999.99') + '  ³'
   @ prow()+1,0 say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
   IF CA_SEC->(DBSEEK(CAHEADER->BRCODE+CAHEADER->CANUMBER))   && RED 112905 if !empty(CAheader->Secheld)
      if prow() > 42
        is_app:=.t.
        if npage == 1
           @ prow()+1,0 say ''
           @ prow()+1,0 say '( Next Page Please.)'
        endif
        approver()
        head2(.t.)
        @ prow()+1,0 say ''
      endif
      @ prow()+1,0 say ''
      setprc(prow(),0)
      SETFONT('UNDERLINE')
      @ prow(),pcol() say 'SECURITY HELD'
      SETFONT('OFFUNDERLINE')
   ENDIF
   for i:=1 to scline
      if prow() > 42
        is_app:=.t.
        if npage == 1
           @ prow()+1,0 say ''
           @ prow()+1,0 say '( Next Page Please.)'
        endif
        approver()
        head2(.t.)
        @ prow()+1,0 say ''
      endif
       @ prow()+1,1 say memoline( sSECHELD,133,i )    && RED 112905 Caheader->Secheld
   next i
   @ prow()+1,0 say ''
   IF CA_OBT->(DBSEEK(CAHEADER->BRCODE+CAHEADER->CANUMBER))     && RED 112905 if !empty(Caheader->Obtain)
      if prow() > 42
        is_app:=.t.
        if npage == 1
           @ prow()+1,0 say ''
           @ prow()+1,0 say '( Next Page Please.)'
        endif
        approver()
        head2(.t.)
        @ prow()+1,0 say ''
      endif
      @ prow()+1,0 say ''
      setprc(prow(),0)
      SETFONT('UNDERLINE')
      @ prow(),pcol() say 'TO BE OBTAINED / OTHER CONDITIONS'
      SETFONT('OFFUNDERLINE')
   ENDIF
   for i:= 1 to obline
       if prow() > 42
        is_app:=.t.
        if npage == 1
           @ prow()+1,0 say ''
           @ prow()+1,0 say '( Next Page Please.)'
        endif
        approver()
        head2(.t.)
        @ prow()+1,0 say ''
      endif
      @ prow()+1,1 say memoline( sOBTAIN, 133, i )       && RED 112905 Caheader->Obtain
   next i
   if !is_app
     approver()
   endif
endif
if is_app .and. prnt_ao
   do while prow() < 47
      @ prow()+1,0 say ''
   enddo
   @ prow()+1,0 say mao
   if !empty(cdivhead)
      @ prow()  ,100   say cdivhead
   endif

   @ prow()+1,0 say upper(mpost)

   if !empty(cdivhead)
      @ prow()  ,100   say upper(cdivpost)
   endif

endif
return nil

Static Function Approver()     //display the Approval< 1st and Last page >

local mao:=eval({ || Ao->(dbseek(Caheader->Aocode)), Ao->Aoname } )
local mpost:=Ao->Aopost
local mcol1:='',spc1:=0,spc2:=0,txtr:='',txtr2:='',i
memvar appray_,appray2_,mcomname,mcomname2
memvar cdivhead,cdivpost

do while prow() <= 47
   @ prow()+1,0 say ''
enddo
@ prow()+1,1    say mao

if !empty(cdivhead)
   @ prow()  ,100   say cdivhead
endif

@ prow()+1,1    say upper(mpost)

if !empty(cdivhead)
   @ prow()  ,100   say upper(cdivpost)
endif

if !empty( appray2_ )
    spc2 :=if(len(appray_) == 7,1,if(len(appray_) == 6,2,if(len(appray_) == 5,4,if(len(appray_) == 4,5,6  ) ) ) )
    mcol1:=if(len(appray2_) == 7,1,if(len(appray2_) == 6,2,if(len(appray2_) == 5,3,if(len(appray2_) == 4,7,12 ) ) ) )
    spc1 :=if(len(appray2_) == 7,1,if(len(appray2_) == 6,2,if(len(appray2_) == 5,4,if(len(appray2_) == 4,5,6  ) ) ) )
    for i:= 1 to len(appray2_)
        txtr+= appray2_[ i ] + space(spc1)
    next i
    txtr  := alltrim(txtr)
    for i:= 1 to len(appray_)
        txtr2+= appray_[i] + spac(spc2)
    next i
    txtr2:=alltrim(txtr2)
   @ prow()+1,0    say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'

   @ prow()+1,0    say '³'
   @ prow(), 1     say padc(alltrim(mcomname2),68)
   @ prow(), 70    say '³'
   @ prow(), 71    say padc(alltrim(mcomname),68)
   @ prow(),139    say '³'

   @ PROW()+1,0    SAY 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
   @ PROW()+1,0    SAY '³                                                                     ³                                                                    ³'
   @ PROW()+1,0    SAY '³                                                                     ³                                                                    ³'
   @ PROW()+1,0    SAY '³'
   @ prow() ,1     say padc(txtr,68)
   @ prow() ,70    say '³'
   @ prow() ,71    say padc(txtr2,68)
   @ prow() ,139   say '³'
   @ prow()+1,0    say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
else

   aeval( appray_, { | a_ |  mcol1+= a_ } )
   spc1 :=int( ;
               ( 138-len(mcol1) ) /;
               ( len(appray_) + 1 );
             )
    txtr2 := spac(spc1)
    for i:= 1 to len(appray_)
        txtr2+= appray_[i] + spac(spc1)
    next i
   @ prow()+1,0    say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'

   @ prow()+1,0    say '³'
   @ prow(), 1     say padc(alltrim(mcomname),138)
   @ prow(),139    say '³'

   @ PROW()+1,0    SAY 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
   @ PROW()+1,0    SAY '³                                                                                                                                          ³'
   @ PROW()+1,0    SAY '³                                                                                                                                          ³'
   @ PROW()+1,0    SAY '³'
   @ prow()  ,1    say padc(txtr2,138)
   @ prow() ,139   say '³'
   @ prow()+1,0    say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
endif
return nil

//////-*-*-*-*-*-*-*-*-E-O-F-*-*-*-*-*-*-*-*-*-*///////
