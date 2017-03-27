//Function to calculate the total outstanding in currency and the total amount of line
//This is a pre-checking of the data to be processed later
#include 'inkey.ch'
#include 'colf.ch'

***************************
*
function count_total()
***************************
local mhead_  := {}, propfc_ := {}, unavca_ := {}, unavcg_ := {}
local unavot_ := {}, unavog_ := {}
local re:= Caheader->(recno()),es:=Cadetail->(recno()),weng
local xbreak, mline, mhead, mdbf_ := savedbf()
local mtrue, s := 1, c := 1, motnum:={}, mcanum:={},cnt:=1
local mleftbal := 0, mrightbal := 0
local sw:=.f.,ctr:=0,npage:=1,mclient
local xx,zzz,mgroup
local re2:= OLCAHEAD->(recno()),es2:=OLCADET->(recno())
memvar mtotblnc,mtotcrdt,mipp
private gen_term:=.t.

    //ÄÄÄproposed facilitiesÄÄÄ1
         aeval( include(,@weng), { | mray_ | actual_p( mray_,1 ) } )
         if weng == nil         //filter if account is include in proposal
            weng:= 'xxxxx'
         endif
         if !gen_term
            set device to screen
            set console on
            restdbf(mdbf_)
            return .f.
         endif

    //ÄÄÄunavailed ca lineÄÄÄ2
         if chkclntactaken( , @mline, @mhead, @mcanum,weng )
            for xx :=1 to len(mcanum)
              aeval( include2( mcanum[xx],mhead,@sw,@ctr,@mline),{|mray_| actual_p2(mray_,mline) } )
            next xx
         endif

    //ÄÄÄunavailed ca line of group membersÄÄÄ3
        mcanum := {}
        mgroup:=chkgrpcode()
		//for xx:= 1 to len( mgroup:=chkgrpcode() )
        for xx:= 1 to len( mgroup )

            mcanum := {}

            if chkclntactaken( mgroup[xx],@mline,@mhead,@mcanum,weng )

                for zzz:= 1 to len(mcanum)
                     aeval( include2( mcanum[zzz],mhead,@sw,@ctr,@mline,mgroup[xx]), ;
                     { | i_ | actual_p2(i_,mline)  } )
                next zzz
            endif
        next xx

    //ÄÄÄunavailed otÄÄÄ4
         if chkotktactaken( , @mline, @mhead, @motnum )
            aeval( exclude( motnum, @mhead ), { | i_ | actual_p3( i_, 1,@mhead,@cnt)  } )
            //addarray( unavot_, mhead, 1 )
         endif
    //ÄÄÄunavailed ot of group membersÄÄÄ5
         aeval( chkgrpcode(), { | g_ |;
                if( chkotktactaken( g_,@mline,@mhead,@motnum),;
                aeval( exclude( motnum,@mhead ), ;
                { | i_ | actual_p3(i_,2,@mhead,@cnt ) } ),.f. )  }  )

     sw:= .f.
     ctr:= 0
    //ÄÄÄÄthe Old Maid stopped here...
    //ÄÄÄexisting liabilitiesÄÄÄ6

    Caheader->(dbgoto(re))
    aeval( include3(,@sw,@ctr,1 ), {|mray_| actual_p4(mray_,1) } )

    Caheader->(dbgoto(re))

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


    //ÄÄÄcommitteesÄÄÄ8


restdbf(mdbf_)
Caheader->( dbgoto(re) )
CAdetail->( dbgoto(es) )

OLCAHEAD->( dbgoto(re2) )
OLCADET->( dbgoto(es2) )

return  .t.


***************************************
*
static function include( mcanum,weng)
***************************************
local arr_ := {},xCredamTz:= 0  ,genray_:={}
local nprincipal := 0, nxxx := 0, nxxx2 := 0
mcanum := if( mcanum == nil, Caheader->canumber, mcanum )

Cadetail->( dbseek( Caheader->brcode+mcanum ) )   //( !found() .and. Cadetail->Include == .F.) .or. Caheader->Catype <> '4'

if eval( { || if( Caheader->Catype <> '4',;
                  eval( { || !CADETAIL->(found()) .and. ;      && RED 013006 ADDED 'CADETAIL->' Another loose programming
                              Cadetail->Include == .F. ;
                        } ;
                      ),.f.) } ) .and. ;
    eval( { || if( Caheader->Catype == '1',;
               .t.,;
               .f. ) ;
          } ;
        )

   set device to screen
   set console on
   error ( 'Facility entered is not included..Check entry..' )
   gen_term:= .f.
   return arr_
endif

do while Cadetail->(!eof())           .and. ;
         Cadetail->Canumber == mCanum .and. ;
         Cadetail->brcode   == Caheader->brcode

  if !empty(Cadetail->Fcltycode)
     //
     // aadd( genray_,{ Cadetail->Fcltycode,cadetail->Ratetype,getosbal(),getAmt(@xCredamTz),xCredamTz } )
     //

     nxxx := getosbal()
     aadd ( genray_,{ Cadetail->Fcltycode,;
                      cadetail->Ratetype ,;
                      nxxx ,;
                      getAmt(@xCredamTz,@nprincipal) ,;
                      xCredamTz          ,;
                      nprincipal          ; // 12.23.2002 abb
                    } ;
          )


     weng := mcanum
  endif
  Cadetail->( dbskip(+1) )
enddo

return genray_

////

*********************************************************
*
static function include2( mcanum, mhead,sw,ctr,mline,g_)
*********************************************************
local arr_ := {},xCredamTz:= 0,genray_:={},caln_avld:=0
local renum := CAheader->(recno()),mu:=CAheader->(indexord()),xxx
local renum2 := OLCAHEAD->(recno()),mu2:=OLCAHEAD->(indexord())
//mcanum := if( mcanum == nil, Caheader->canumber, mcanum )
LOCAL CALIN := 0

if !empty(g_) .or. g_ != nil

   dbselectarea('Caheader')
   Caheader->(dbsetorder(1))
   Caheader->(dbseek(SUBSTR(g_,1,3)+RIGHT(mcanum,5))) // RLV 03162010 GROUPCODES
endif

 //if Cadetail->( dbseek(IF(!empty(g_) .or. g_ != nil ,SUBSTR(g_,1,3)+RIGHT(mcanum,5),g_PAR_BRCH+RIGHT(mcanum,5) ) )) // RLV 03162010 GROUPCODES
 if Cadetail->( dbseek(IF(!empty(g_) .or. g_ != nil ,SUBSTR(g_,1,3)+RIGHT(mcanum,5),mcanum ) ))

	 while Cadetail->(!eof()) .and. Cadetail->Canumber == RIGHT(mcanum,5)

	  if !empty(Cadetail->Fcltycode)
	   if mline == '1'
		  aadd( genray_,{Cadetail->Fcltycode,cadetail->Ratetype,Cadetail->(recno()),'CADETAIL' } )

		  if substr(Cadetail->fcltycode,1,3) == '104'    // abb 12.27.2002
			 //caln_avld := eval( {|| Caheader->(dbseek(g_PAR_BRCH+RIGHT(mcanum,5),.f.)), (Caheader->Caline - Caheader->Availed) } )
			 caln_avld := eval( {|| Caheader->(dbseek(mcanum,.f.)), (Caheader->Caline - Caheader->Availed) } )
		  else
			 //caln_avld := eval( {|| Caheader->(dbseek(g_PAR_BRCH+RIGHT(mcanum,5),.f.)), (Caheader->Caline - Caheader->Availed) } )
			 caln_avld := eval( {|| Caheader->(dbseek(mcanum,.f.)), (Caheader->Caline - Caheader->Availed) } )
		  endif
	   elseif mline == '2'
		  aadd( genray_,{Cadetail->Fcltycode,cadetail->Ratetype,Cadetail->(recno()),'CADETAIL' } )

		  if substr(Cadetail->fcltycode,1,3) == '104'   // abb 12.27.2002
			 //caln_avld := eval( {|| Caheader->(dbseek(g_PAR_BRCH+RIGHT(mcanum,5),.f.)), (Caheader->Caline - Caheader->Availed) } )
			 caln_avld := eval( {|| Caheader->(dbseek(mcanum,.f.)), (Caheader->Caline - Caheader->Availed) } )
		  else
			 //caln_avld := eval( {|| Caheader->(dbseek(g_PAR_BRCH+RIGHT(mcanum,5),.f.)), (Caheader->Caline - Caheader->Availed) } )
			 caln_avld := eval( {|| Caheader->(dbseek(mcanum,.f.)), (Caheader->Caline - Caheader->Availed) } )
		  endif

	   endif
	  endif
	  Cadetail->( dbskip() )
	 enddo

 Caheader->(dbgoto(renum))
 CAheader->(dbsetorder(mu))
 //mtotcrdt += caln_avld
 endif

 if !empty(g_) .or. g_ != nil
   dbselectarea('OLCAHEAD')
   OLCAHEAD->(dbsetorder(1))
   OLCAHEAD->(dbseek( mcanum)) 
endif

 if OLCADET->( dbseek( mcanum ) ) 
     /****
	 while OLCADET->(!eof()) .and. OLCADET->BRCODE+OLCADET->Canumber == mCanum
	  if !empty(OLCADET->Fcltycode)
	   if mline == '1'
		  aadd( genray_,{OLCADET->Fcltycode,OLCADET->Ratetype,OLCADET->(recno()),'OLCADET' } )

		  if substr(OLCADET->fcltycode,1,3) == '105'    // abb 12.27.2002
			 IF OLCADET->INCLUDE
			   caln_avld += OLCADET->CREDAMT - OLCADET->AVAILED
			   CALIN+=caln_avld
			 ENDIF
		  else
			 IF OLCADET->INCLUDE
			   caln_avld += OLCADET->CREDAMT - OLCADET->AVAILED
			   CALIN+=caln_avld
			 ENDIF
		  endif
	   elseif mline == '2'
		  aadd( genray_,{OLCADET->Fcltycode,OLCADET->Ratetype,OLCADET->(recno()),'OLCADET' } )

		  if substr(OLCADET->fcltycode,1,3) == '105'   // abb 12.27.2002
			 IF OLCADET->INCLUDE
			   caln_avld += OLCADET->CREDAMT - OLCADET->AVAILED
			   CALIN+=caln_avld
			 ENDIF
		  else
			 IF OLCADET->INCLUDE
			   caln_avld += OLCADET->CREDAMT - OLCADET->AVAILED
			   CALIN+=caln_avld
			 ENDIF
		  endif

	   endif
	  endif
	  OLCADET->( dbskip() )
	 enddo
	 ****/

	 while OLCADET->(!eof()) .and. OLCADET->brcode+OLCADET->Canumber == mCanum
	 
	  if !empty(OLCADET->Fcltycode)
		if mline == '1'
			//aadd( genray_,{OLCADET->Fcltycode,OLCADET->Ratetype,OLCADET->(recno()) } )
			aadd( genray_,{OLCADET->Fcltycode,OLCADET->Ratetype,OLCADET->(recno()),'OLCADET' } )

			if substr(OLCADET->fcltycode,1,3) == '105'    // abb 12.27.2002
				//caln_avld := eval( {|| OLCAHEAD->(dbseek(mCanum,.f.)), (OLCAHEAD->Caline - OLCAHEAD->Availed)+(OLCAHEAD->Caline2 - OLCAHEAD->Availed2) } )
				caln_avld := eval( {|| OLCAHEAD->(dbseek(mCanum,.f.)), (OLCAHEAD->Caline - OLCAHEAD->Availed) } )
				CALIN+=caln_avld
			else
			    caln_avld := eval( {|| OLCAHEAD->(dbseek(mCanum,.f.)), (OLCAHEAD->Caline - OLCAHEAD->Availed)+(OLCAHEAD->Caline2 - OLCAHEAD->Availed2) } )
				CALIN+=caln_avld
			endif

		elseif mline == '2'

			//aadd( genray_,{OLCADET->Fcltycode,OLCADET->Ratetype,OLCADET->(recno()) } )
			aadd( genray_,{OLCADET->Fcltycode,OLCADET->Ratetype,OLCADET->(recno()),'OLCADET' } )

			if substr(OLCADET->fcltycode,1,3) == '105'   // abb 12.27.2002
			    caln_avld := eval( {|| OLCAHEAD->(dbseek(mCanum,.f.)), (OLCAHEAD->Caline - OLCAHEAD->Availed)+(OLCAHEAD->Caline2 - OLCAHEAD->Availed2) } )
				CALIN+=caln_avld
			else
			    caln_avld := eval( {|| OLCAHEAD->(dbseek(mCanum,.f.)), (OLCAHEAD->Caline - OLCAHEAD->Availed)+(OLCAHEAD->Caline2 - OLCAHEAD->Availed2) } )
				CALIN+=caln_avld
			endif
	 
		endif
	  endif
	  OLCADET->( dbskip() )
	 enddo
	 
	 
	 ****

	 OLCAHEAD->(dbgoto(renum2))
	 OLCAHEAD->(dbsetorder(mu2))
	 
 endif
//ALERT(STR(caln_avld))
 mtotcrdt += caln_avld
 
 return genray_
////------------------------------
/*
Static Function trantyper(xfcl,nca)
local gf:=savedbf(),ctype:='',bf:=Cadetail->(indexord())
dbselectarea('Cadetail')
dbsetorder(2)
if cadetail->( dbseek(Caheader->brcode+nca + xfcl) )
   ctype:=Cadetail->Trantype
endif
restdbf(gf)
Cadetail->(dbsetorder(bf))
return ctype
*/
/////
//para -> clncode<Clntocde>,sw & ctr<switch& counter to print subheader>,rep<group member>
**************************************************
*
static function include3( clncode,sw,ctr,rep )
**************************************************
local arr_ := {},xCredamTz:= 0,nray_:={},mu:=Acctmast->(indexord())
local xclncode := if( clncode == nil, Caheader->brcode+Caheader->clntcode, clncode )
local mdbf_ := savedbf(),msetcode,tType,cType

    dbselectarea('Acctmast')
    Acctmast->(dbsetorder(7))
if clncode != CAHEADER->brcode+CAHEADER->clntcode 
	if Acctmast->( dbseek( xclncode ) )//if Acctmast->( dbseek( Caheader->Brcode+xclncode ) )//
	   cType:=Caheader->Catype
	   msetcode:= eval( {|| Facility->(dbseek(Acctmast->Fcltycode)),Facility->Setcode })

	   do while Acctmast->(!eof()) .and. Acctmast->Clntcode == right(xclncode,7) .and. ;
				ACCTMAST->BRCODE   == left(xclncode,3)
		 tType:= trantyper(Acctmast->Fcltycode,Caheader->Canumber)

		// if alltrim(tType) # '1' .and. (alltrim(msetcode) # '4' .or. alltrim(msetcode) # '5' ) .and. (alltrim(cType) # '2' .or. alltrim(cType) # '3' )
			if !empty(Acctmast->Fcltycode) .and. !empty(Acctmast->Acctno)
			   aadd( nray_,{ Acctmast->Fcltycode,getbalc(xclncode),getrec(xclncode) } )
			   
			   //aadd( nray_,{ Acctmast->Fcltycode,getbalc(xclncode) } )
			   //mtotblnc +=  getbalc(xclncode)
			endif
		// endif
		  acctmast->( dbskip() )
	   enddo
	endif
	Acctmast->(Dbsetorder())
endif

if clncode <> nil

	dbselectarea('OLSMAST')
	nntx := OLSMAST->(INDEXORD())
	OLSMAST->(dbsetorder(8))

	if OLSMAST->( dbseek( xclncode ) )//if OLSMAST->( dbseek( Caheader->Brcode+xclncode ) )//
	   cType:=Caheader->Catype
	   msetcode:= eval( {|| Facility->(dbseek(OLSMAST->Fcltycode)),Facility->Setcode })

	   do while OLSMAST->(!eof()) .and. OLSMAST->Clntcode == right(xclncode,7) .and. ;
				OLSMAST->BRCODE2   == left(xclncode,3)
		 tType:= trantyper(OLSMAST->Fcltycode,Caheader->Canumber)

	//	 if alltrim(tType) # '1' .and. (alltrim(msetcode) # '4' .or. alltrim(msetcode) # '5' ) .and. (alltrim(cType) # '2' .or. alltrim(cType) # '3' )
			if !empty(OLSMAST->Fcltycode) .and. !empty(OLSMAST->Acctno)
			   IF OLSMAST->OSBAL <> 0.00 .and. OLSMAST->OSBAL > 0.00 // RLV 8:58 AM 2/29/2012
				  aadd( nray_,{ OLSMAST->Fcltycode,OLSMAST->OSBAL,getrec2(xclncode,.T.) } )
				  //aadd( nray_,{ OLSMAST->Fcltycode,OLSMAST->OSBAL} )
				  //mtotblnc +=  OLSMAST->OSBAL
			   ENDIF
			endif
	//	 endif
	   OLSMAST->( dbskip() )
	   enddo
	endif
	OLSMAST->(Dbsetorder(nntx))
endif

if clncode <> nil
	dbselectarea('OALPMAST')
	nntx := OALPMAST->(INDEXORD())
	OALPMAST->(dbsetorder(8))

	if OALPMAST->( dbseek( xclncode ) )//if OALPMAST->( dbseek( Caheader->Brcode+xclncode ) )//
	   cType:=Caheader->Catype
	   msetcode:= eval( {|| Facility->(dbseek(OALPMAST->Fcltycode)),Facility->Setcode })

	   do while OALPMAST->(!eof()) .and. OALPMAST->Clntcode == right(xclncode,7) .and. ;
				OALPMAST->BRCODE2   == left(xclncode,3)
		 tType:= trantyper(OALPMAST->Fcltycode,Caheader->Canumber)

	//	 if alltrim(tType) # '1' .and. (alltrim(msetcode) # '4' .or. alltrim(msetcode) # '5' ) .and. (alltrim(cType) # '2' .or. alltrim(cType) # '3' )
			if !empty(OALPMAST->Fcltycode) .and. !empty(OALPMAST->Acctno)
			   IF OALPMAST->OSBAL <> 0.00 .and. OALPMAST->OSBAL > 0.00 // RLV 8:58 AM 2/29/2012
				  aadd( nray_,{ OALPMAST->Fcltycode,OALPMAST->OSBAL,getrec2(xclncode,.F.) } )
				  //aadd( nray_,{ OALPMAST->Fcltycode,OALPMAST->OSBAL} )
				  //mtotblnc +=  OALPMAST->OSBAL
			   ENDIF
			endif
	//	 endif
		  OALPMAST->( dbskip() )
	   enddo
	endif
	OALPMAST->(Dbsetorder(nntx))
endif

restdbf( mdbf_ )
return nray_

**********************************
*  abb 12.23.2002
*
Static function getbalc(clncode)
**********************************
local mosbal := 0, mfacil:= Acctmast->Fcltycode
local mclntcod := Caheader->Clntcode,nrecno:=Acctmast->(recno())

/******************
Acctmast ->;
        (dbeval( {|| if(val( Acctmast->Status ) < 4 , mosbal += Acctmast->Osbal,.f.) } ,, ;
        {|| Acctmast->(!eof()) .and. Acctmast->Fcltycode == mFacil .and.;
            Acctmast->Clntcode == Clncode } ) )
*****************/

/**********************
Acctmast ->;
        (dbeval( {|| if( val( Acctmast->Status ) < 4 .or. ;
                         val( Acctmast->Status ) == 6    ,;
                         if ( substr(Acctmast->fcltycode,1,3) == '104',;
                              mosbal += (Acctmast->Osbal-Acctmast->udibal),;
                              mosbal += Acctmast->Osbal;
                            ),;
                         .f. ;
                       );
                  },, ;
        {|| Acctmast->(!eof()) .and. Acctmast->Fcltycode == mFacil .and.;
            Acctmast->Clntcode == Clncode ;
        } ) )

        PINABALIK YUNG DATI  01.21.2003
***********************/
Acctmast ->;
        (dbeval( {|| if( ( val( Acctmast->Status ) < 4 .or.   ;
                         val( Acctmast->Status ) == 6 ) .AND. ;
                         ACCTMAST->BRCODE == left(clncode,3) .AND. val( Acctmast->Status ) <> 0 ,;
                         if ( substr(Acctmast->fcltycode,1,3) == '104',;
                              mosbal += Acctmast->Osbal,;
                              mosbal += Acctmast->Osbal;
                            ),;
                         .f. ;
                       );
                  },, ;
        {|| Acctmast->(!eof()) .and. Acctmast->Fcltycode == mFacil .and.;
            Acctmast->Clntcode == right(clncode,7) ;
        } ) )

Acctmast->(dbgoto(nrecno))
return( mosbal )
////

Static Function getrec(clncode)
local arr_ := {}, mfclty := Acctmast->fcltycode, xbreak

 Acctmast->( dbeval( { || if( val( Acctmast->Status ) < 4 .AND. ;
                              ACCTMAST->BRCODE == left(clncode,3)   ,;
                              aadd( arr_, Acctmast->( recno() ) ),.f.) },,;
                     { || Acctmast->Clntcode == right(clncode,7) .and.;
                            Acctmast->fcltycode == mfclty } ) )
if !empty(arr_)
   Acctmast->( dbskip( -1 ) )
endif
return (arr_)
////
// para -> canumber, header<Omni./Reg.>,switch<if 'UNAVAILED CREDIT LINE:' was printed>,counter<count for
//         group members' facility occurences>,linetype< for group members/current >
////

**********************************
*  abb 12.23.2002
*
Static function getbalc2(clncode,lCODE)
**********************************
local mosbal := 0, mfacil:= OLSMAST->Fcltycode, mfacil2:= OALPMAST->Fcltycode
local mclntcod := CAHEADER->Clntcode,nrecno:=OLSMAST->(recno()),mrecno:=OALPMAST->(recno())

IF lCODE
	OLSMAST ->;
			(dbeval( {|| if( ( val( OLSMAST->Status ) < 4 .or.   ;
							 val( OLSMAST->Status ) == 6 ) .AND. ;
							 OLSMAST->BRCODE == left(clncode,3)      ,;
							 if ( substr(OLSMAST->fcltycode,1,3) == '105',;
								  mosbal += ROUND(OLSMAST->Osbal,2),;
								  mosbal += ROUND(OLSMAST->Osbal,2);
								),;
							 .f. ;
						   );
					  },, ;
			{|| OLSMAST->(!eof()) .and. OLSMAST->Fcltycode == mFacil .and.;
				OLSMAST->Clntcode == right(clncode,7) ;
			} ) )

	OLSMAST->(dbgoto(nrecno))
ELSE
	OALPMAST ->;
			(dbeval( {|| if( ( val( OALPMAST->Status ) < 4 .or.   ;
							 val( OALPMAST->Status ) == 6 ) .AND. ;
							 OALPMAST->BRCODE == left(clncode,3)      ,;
							 if ( substr(OALPMAST->fcltycode,1,3) == '105',;
								  mosbal += ROUND(OALPMAST->Osbal,2),;
								  mosbal += ROUND(OALPMAST->Osbal,2);
								),;
							 .f. ;
						   );
					  },, ;
			{|| OALPMAST->(!eof()) .and. OALPMAST->Fcltycode == mfacil2 .and.;
				OALPMAST->Clntcode == right(clncode,7) ;
			} ) )

	OALPMAST->(dbgoto(mrecno))

ENDIF

return( mosbal )
*************************************
*
Static Function getrec2(clncode,lCODE)
*************************************
local arr_ := {}, mfclty := OLSMAST->fcltycode, mfclty2 := OALPMAST->fcltycode, xbreak
/***************************
IF lCODE
	 OLSMAST->( dbeval( { || if( val( OLSMAST->Status ) < 4 .AND. ;
								  OLSMAST->BRCODE == left(clncode,3)   ,;
								  aadd( arr_, OLSMAST->( recno() ) ),.f.) },,;
						 { || OLSMAST->Clntcode == right(clncode,7) .and.;
								OLSMAST->fcltycode == mfclty } ) )
	if !empty(arr_)
	   OLSMAST->( dbskip( -1 ) )
	endif

ELSE
	 OALPMAST->( dbeval( { || if( val( OALPMAST->Status ) < 4 .AND. ;
								  OALPMAST->BRCODE == left(clncode,3)   ,;
								  aadd( arr_, OALPMAST->( recno() ) ),.f.) },,;
						 { || OALPMAST->Clntcode == right(clncode,7) .and.;
								OALPMAST->fcltycode == mfclty } ) )
	if !empty(arr_)
	   OALPMAST->( dbskip( -1 ) )
	endif

ENDIF
***************************/
aadd( arr_, Acctmast->( recno() ) )

return (arr_)
****************************
*
Static function getosbal()
****************************
local mosbal := 0, mtrantype := ( Cadetail->trantype == '1' )
local meval := { | f, s | f, s } 
local mcodeset := eval( meval, Facility->( dbseek( Cadetail->fcltycode ) ),;
                               Facility->setcode )
local msetcode := ( mcodeset == '4' .or. mcodeset == '5' )
local mcatype := ( Caheader->catype == '2' .or. Caheader->catype == '3' )
local mactntx := Acctmast->( indexord() )

if msetcode .and. mcatype .and. mtrantype

/*****************************
   Acctmast->( ordsetfocus( 2 ) )
   Acctmast->( dbseek( Caheader->clntcode ) )
   Acctmast->( dbeval( { || if( val( Acctmast->Status ) < 4 .and. ;
                                Acctmast->fcltycode == Cadetail->fcltycode,;
                                eval ({|| if ( substr(Acctmast->fcltycode,1,3) == '104',;
                                               mosbal += (Acctmast->osbal-Acctmast->udibal),;
                                               mosbal +=  Acctmast->osbal ;
                                             );
                                     }),;
                            nil ) ;
                       },,;
                       { || Acctmast->clntcode == Caheader->clntcode } ) )
   Acctmast->( ordsetfocus( mactntx ) )

   PINABALIK YUNG DATI, 01.21.2003 (ABB)
****************************/

   Acctmast->( ordsetfocus( 2 ) )
   Acctmast->( dbseek( Caheader->brcode+Caheader->clntcode ) )
   Acctmast->( dbeval( { || if( val( Acctmast->Status ) < 4 .and. ;
                                Acctmast->fcltycode == Cadetail->fcltycode,;
                                eval ({|| if ( substr(Acctmast->fcltycode,1,3) == '104',;
                                               mosbal +=  Acctmast->osbal ,;
                                               mosbal +=  Acctmast->osbal  ;
                                             );
                                     }),;
                            nil ) ;
                       },,;
                       { || Acctmast->clntcode == Caheader->clntcode } ) )
   Acctmast->( ordsetfocus( mactntx ) )                       


endif

return( mosbal )

********************************************
*
Static Function getamt(xCredamTz,nprincipal)
********************************************
local arr_ := {}, mfclty := Cadetail->fcltycode, xbreak
if Cadetail->include
   aadd( arr_, Cadetail->( recno() ) )
   xCredamTz  := Cadetail->Credamt
   nprincipal := Cadetail->principal
   Cadetail->( dbskip() )
   Cadetail->( dbeval( { || aadd( arr_, Cadetail->( recno() ) ) },,;
                       { || CAHEADER->BRCODE+Caheader->canumber == CADETAIL->BRCODE+Cadetail->canumber .and.;
                            Cadetail->fcltycode == mfclty .and. !Cadetail->include } ) )
   Cadetail->( dbskip( -1 ) )
else
   xCredamTz  := 0
   nprincipal := 0
   aadd( arr_, Cadetail->( recno() ) )
   Cadetail->(dbskip())
   Cadetail->( dbeval( { || aadd( arr_, Cadetail->( recno() ) ) },,;
                       { || CAHEADER->BRCODE+Caheader->canumber == CADETAIL->BRCODE+Cadetail->canumber .and.;
                            Cadetail->fcltycode == mfclty .and. !Cadetail->include } ) )
   cadetail->(dbskip(-1))
endif

return (arr_)

////
****************************************
* abb 12.23.2002
*
Static Function Actual_p( genray_,rpt)
****************************************
local mdata:={},mdata1:={},mdata2:={},mdata3:={},mdata4:={},mdata5:={},mdata6:={}
local mdata3a:={},mdata31:={},mdata32:={},mdata33:={},mdata34:={}
local m,n,q,x,y,z,g,j,h,mtext
local msetcode:=eval( { || Facility->(Dbseek(genray_[ 1 ]) ),Facility->Setcode } )
local tType:= trantyper( genray_[ 1 ],Caheader->Canumber ),ctype:=Caheader->Catype

if len(genray_[4]) > 1

   if substr(genray_[1],1,3) == '104'             // LOANS 12.23.2002
   //   if alltrim(ttype) <> '1' .and. (alltrim(msetcode) # '4' .or. alltrim(msetcode) # '5' ) .and. (alltrim(cType) # '2' .or. alltrim(cType) # '3' ) .and. !empty(genray_[5])
      if !empty(genray_[5])
/*          mtotblnc += genray_[ 3 ]
		 if substr(genray_[1],1,5) == '10402' .or. substr(genray_[1],1,5) == '10403'
			mipp += genray_[ 3 ]
			alert('3')
		 endif */
      endif
   else
      if alltrim(ttype) <> '1' .and. (alltrim(msetcode) # '4' .or. alltrim(msetcode) # '5' ) .and. (alltrim(cType) # '2' .or. alltrim(cType) # '3' ) .and. !empty(genray_[ 5 ])
     //    mtotblnc += genray_[ 3 ]
	//	 alert('4')
      endif
   endif

   if substr(genray_[1],1,3) == '104'             // LOANS 12.23.2002
      mtotcrdt+= genray_[ 5 ] - mipp
   else
      mtotcrdt+= genray_[ 5 ]
   endif

else  //single Facility

   if substr(genray_[1],1,3) == '104'             // LOANS 12.23.2002
    //  if alltrim(ttype) <> '1' .and. (alltrim(msetcode) # '4' .or. alltrim(msetcode) # '5' ) .and. (alltrim(cType) # '2' .or. alltrim(cType) # '3' ) .and. !empty(genray_[5])
      if !empty(genray_[5])
/*          mtotblnc += genray_[ 3 ]
		 if substr(genray_[1],1,5) == '10402' .or. substr(genray_[1],1,5) == '10403'
			mipp += genray_[ 3 ]
			alert('5')
		 endif */
      endif
   else
      if alltrim(ttype) <> '1' .and. (alltrim(msetcode) # '4' .or. alltrim(msetcode) # '5' ) .and. (alltrim(cType) # '2' .or. alltrim(cType) # '3' ) .and. !empty(genray_[5])
      //   mtotblnc += genray_[ 3 ]
	//	 alert('6')
      endif
   endif

   if substr(genray_[1],1,3) == '104'             // LOANS 12.23.2002
      mtotcrdt += genray_[ 5 ] - mipp
   else
      mtotcrdt += genray_[ 5 ]
   endif

endif

return nil

////
Static function Actual_p2(genray_,mline)

local mdata:={},mdata1:={},mdata2:={},mdata3:={},mdata4:={},mdata5:={},mdata6:={}
local mdata3a:={},mdata31:={},mdata32:={},mdata33:={},mdata34:={}
local m,n,q,x,y,z,g,j,h,mtext,omni:= ( mline == '1' )

   IF UPPER(genray_[4]) == 'CADETAIL'
      Cadetail->(dbgoto(genray_[3]))
   ELSE
      OLCADET->(dbgoto(genray_[3]))
   ENDIF
   
  if mline == '2'
  endif

return nil

////
Static function Actual_p3(genray_,mline,header_,cnt)

local mdata:={},mdata1:={},mdata2:={},mdata3:={},mdata4:={},mdata5:={},mdata6:={}
local mdata3a:={},mdata31:={},mdata32:={},mdata33:={},mdata34:={}
local m,n,q,x,y,z,g,j,h,mtext

Oticket->(dbgoto(genray_[ 3 ]))
mtotcrdt += (Oticket->Credamt-Oticket->Crdavail)

return nil
///
****************************************
*
static Function Actual_p4(genray_,rpt)
****************************************
local mdata:={},mdata1:={},mdata2:={},mdata3:={},mdata4:={},mdata5:={},mdata6:={}
local mdata3a:={},mdata31:={},mdata32:={},mdata33:={},mdata34:={},mdata6a:={}
local m,n,q,x,y,z,g,j,h,mtext,xAmnt:=0

 if len(genray_[3]) > 1
	 if substr(genray_[1],1,5) == '10402' .or. substr(genray_[1],1,5) == '10403'
		mipp += genray_[ 2 ]
//		alert('1')
	 endif
    mtotblnc +=  genray_[ 2 ]
 else  //single Facility
	 if substr(genray_[1],1,5) == '10402' .or. substr(genray_[1],1,5) == '10403'
		mipp += genray_[ 2 ]
//		alert('2')
	 endif
    mtotblnc +=  genray_[ 2 ]
 endif
return nil

////
static function exclude( motnum )
local arr_ := {}, mdbf_ := savedbf(),x
local mindx := Oticket->( indexord() )

dbselectar( 'Oticket' )
Oticket->( ordsetfocus( 1 ) )
for x:= 1 to len(motnum)
  //if Oticket->( dbseek( Caheader->brcode+motnum[x] ) ) .and. !empty(Oticket->Fcltycode)
  if Oticket->( dbseek( motnum[x] ) ) .and. !empty(Oticket->Fcltycode)
    aadd( arr_, {Oticket->Fcltycode,Oticket->Ratetype,Oticket->(recno());
                  } )
  endif
next x
Oticket->( ordsetfocus( mindx ) )                   
restdbf( mdbf_ )                   
return( arr_ )
////
/*
static function chkotktactaken( xclnt, mline, mhead, mcanum )
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
         aadd( mhead, alltrim( 'UNAVAILED OT N§ ' + Oticket->otnumber) )
      endif
     endif
     oticket->(dbskip())
   ENDDO
endif
Oticket->( ordsetfocus( mindx ) )
restdbf( mdbf_ )
return( mtrue )
*/
////
*******************************************************************
*
static function chkclntactaken( xclnt, mline, mhead, mcanum,weng )
*******************************************************************
local mtrue := .f., mclnt:= if( xclnt == nil,g_PAR_BRCH+Caheader->clntcode, xclnt )
local mdbf_ := savedbf(),x,mu:=Caheader->(indexord()),mu2:=OLCAHEAD->(indexord())

dbselectar( 'Caheader' )
Caheader->( ordsetfocus( 3 ) )
if Caheader->( dbseek( if( xclnt == nil,mclnt, mclnt ) ) )
   while Caheader->Clntcode == if(len(mclnt) == 10,substr(mclnt,4,10),mclnt) //mclnt
   if Caheader->actaken == '3' .and. Caheader->Canumber <> weng
      if Caheader->caline - Caheader->availed > 0
         mtrue  := .t.
         //mcanum := Caheader->canumber
         aadd( mcanum, CAHEADER->BRCODE+Caheader->canumber )
         mline  := Caheader->linetype
         mhead  := alltrim;
                   (getclntname( xclnt ) +;
                   if( mline == '1', ' Omnibus', ' Regular' ) +;
                      ' Line CA N§ ' + Caheader->canumber )

      endif
   endif
   Caheader->(dbskip())
  enddo
endif
Caheader->(dbsetorder(mu))

IF mclnt <> nil

	dbselectar( 'OLCAHEAD' )
	OLCAHEAD-> ( ordsetfocus( 4 ) ) //BRCODE2 + CLNTCODE //OLCAHEAD-> ( ordsetfocus( 3 ) ) BRCODE + CLNTCODE
	//if OLCAHEAD->( dbseek( if( xclnt == nil,g_PAR_BRCH+mclnt, mclnt ) ) )

	if OLCAHEAD->( dbseek(  mclnt ) )

	   while OLCAHEAD->brcode2+OLCAHEAD->Clntcode == mclnt .and. !OLCAHEAD->(eof())
		   if OLCAHEAD->actaken == '3' .and. OLCAHEAD->Canumber <> weng
			  if OLCAHEAD->caline - OLCAHEAD->availed > 0
				 mtrue  := .t.
				 //mcanum := OLCAHEAD->canumber
				 aadd( mcanum, OLCAHEAD->BRCODE+OLCAHEAD->canumber )
				 mline  := OLCAHEAD->linetype
				 mhead  := alltrim;
						   (getclntname( xclnt ) +;
						   if( mline == '1', ' Omnibus', ' Regular' ) +;
							  ' Line CA N§ ' + OLCAHEAD->canumber )

			  endif
		   endif
	   OLCAHEAD->(dbskip())
	   enddo
	endif
	OLCAHEAD->(dbsetorder(mu2))
ENDIF

restdbf( mdbf_ )
return( mtrue )
/*
////
static function getclntname( xclnt )
local mindx := Client->( indexord() )
local mdbf_ := savedbf(), mname := ''

if valtype( xclnt ) != 'U'
   dbselectar( 'Client' )
   Client->( ordsetfocus( 1 ) )
   Client->( dbseek( Caheader->brcode+xclnt ) )
   mname := padr( Client->fullname, 25 )
   Client->( ordsetfocus( mindx ) )
endif
restdbf( mdbf_ )
return( mname )

////
static function chkgrpcode()
local arr_ := {}, mdbf_ := savedbf(), mmem
local mindx := Grpmembr->( indexord() ),xCode:=Caheader->Clntcode

dbselectar( 'Grpmembr' )
Grpmembr->( ordsetfocus( 2 ) )
Grpmembr->( dbseek( Caheader->brcode+Caheader->clntcode ) )
mmem := Grpmembr->grupcode
Grpmembr->( ordsetfocus( 1 ) )
Grpmembr->( dbseek( Caheader->brcode+mmem ) )
Grpmembr->( dbeval( { || if(Grpmembr->Clntcode # xCode,aadd( arr_, Grpmembr->clntcode ),.f.) },,;
                    { || mmem == Grpmembr->grupcode .and. Grpmembr->brcode == g_PAR_BRCH } ) )    && RED 020805 REPLACED 'Caheader->brcode WITH g_PAR_BRCH
Grpmembr->( ordsetfocus( mindx ) )
restdbf( mdbf_ )
return( arr_ )
*/
////

function checkcomtt(  mTOTAL,mcatype )
**************************************************************************************
   local  mSCR        := savescreen ( ,,, )    ,;
          mCOLOR      := setcolor ()           ,;
          mdbf        := savedbf ( mdbf )      ,;
          mMERON      := .f.                   ,;
          mCOMCODE , i      , getlist := {}    ,;
          mSELECTED, mSIGNEE, mREQB,mreqa      ,;
          mOK_TO_SELECT                        , ncolor,;
          mGCTR := 0 , mCTR  := 0, mcomrec := Comcodes->(recno())
   local credcom:=.f.,aSlct:=0,bSlct:=0,members:={},member2:={}
   local mcomcode2,mmeron2,mreqa2,mreqb2,mrecno2,msignees2
   local lsubcred := .f.                 // abb 3.17.2001
   private groups    := {}
   set device to screen
   mSCR := savescreen ( ,,, )
   mcolor:='w/n'


   if mtotal <= 0

      mu:=savescreen( ,,, )
      fshadow ( 4, 5, 6, 34, 2, 'n/w')
      mtotal := 0
      ncolor := setcolor()   
      setcolor( 'bg+/w, w+/n,,, gr+/w' )
      @ 5,  6 say 'Line Amount ' get mtotal pict '999,999,999.99'

      setcursor ( 3 )
      read
      setcursor ( 0 )
      setcolor  ( mcolor )
      restscreen(,,,,mu)

   endif

   center ( 24, 'w+/n', '® Select Signees ¯' )

   dbselectarea ( "Comcodes" )
//   Comcodes->( dbgotop() )
   Comcodes->( dbseek(g_PAR_BRCH) )
   Comcodes->( dbeval ( { || ;
                  if ( mTOTAL >= Comcodes->MINIMUM .and. mTOTAL <= Comcodes->MAXIMUM,;
                       eval({ || mcomrec  := Comcodes->(recno()) ,;
                                 mMERON   := .t.,;
                                 mCOMCODE := Comcodes->COMCODE     ,;
                                 mCOMNAME := Comcodes->COMNAME     ,;
                                 mSIGNEES := Comcodes->SIGNEES     ,;
                                 mREQB    := Comcodes->REQB        ,;
                                 mReqA    := Comcodes->REQA        ,;
                                 if ( _sub_crecomm(@mcomcode)      ,;
                                      eval({|| ;
                                               mcomrec  := Comcodes->(recno()) ,;
                                               mMERON   := .t.,;
                                               mCOMCODE := Comcodes->COMCODE   ,;
                                               mCOMNAME := Comcodes->COMNAME   ,;
                                               mSIGNEES := Comcodes->SIGNEES   ,;
                                               mREQB    := Comcodes->REQB      ,;
                                               mReqA    := Comcodes->REQA      ,;
                                               Comcodes->(dbgobottom())        ,;
                                               lsubcred := .t. ;
                                          }),;
                                      nil;
                                    );
                            })  ,;
                       Nil       ;
                     )           ;
               }               ,,;
               { || !Comcodes->(eof()) .and. Comcodes->brcode == g_PAR_BRCH} ;
              );
             )

*****   if mcatype != nil

*****     if alltrim ( mcatype ) == '4' .and. mCOMCODE != g_BOARD_COMM     // EVR 29122006 - changed from Parametr->BOARD_COMM


*****         if Comcodes -> ( dbseek ( g_RISK_COMM ) )     // EVR 29122006 - changed from Parametr->RISK_COMM

*****            mcomrec  := Comcodes->(recno())
*****            mmeron   := .t.
*****            mCOMCODE := Comcodes->COMCODE
*****            mcomname := Comcodes->COMNAME
*****            msignees := Comcodes->SIGNEES
*****            mreqb    := Comcodes->REQB
*****            mreqa    := Comcodes->reqa

*****         endif

*****      endif
*****   endif

************
************ if mComcode == '04' .or. mComcode == '05' // 03 or 04 jbs 01.25.2001 board and execom
************
   if mComcode == g_EXEC_COMM  .or. ;
      mComcode == g_BOARD_COMM    // abb 3.16.2001     // EVR 29122006 - changed from Parametr->EXEC_COMM & Parametr->BOARD_COMM

      credcom:=.t.
      if Comcodes->(Dbseek( g_PAR_BRCH+g_CREDCOM) )     // EVR 29122006 - changed from Parametr->CREDCOM
            mcomrec2 := Comcodes->(recno())
            mmeron2  := .t.
            mCOMCODE2:= Comcodes->COMCODE
            mcomname2:= Comcodes->COMNAME
            msignees2:= Comcodes->SIGNEES
            mreqb2   := Comcodes->REQB
            mreqa2   := Comcodes->reqa
      endif

   endif

   if credcom
      dbselectarea('Comember')
      if Comember->( dbseek(g_PAR_BRCH+mcomcode2) )
         dbeval ( { || aadd( member2,'  '+substr(Comember->Fullname,1,30) +' ³ '+ Comember->Grupcode + Comember->Shortname ) } ,,;
                   { || Comember->(!eof()) .and. Comember->comcode == mcomcode2 } )
         comember->(dbgoto(mcomrec2))
      endif
   endif

   if !mmeron
       error ( 'Total Amount has No Range in Committee File.' )
       restscreen ( ,,,, mSCR )
       restdbf ( mdbf )
       return .f.
   else
      dbselectarea ( "Comember" )
      if Comember->( dbseek ( g_PAR_BRCH+mCOMCODE ) )
         dbeval    ( {||  aadd( members, '  '+substr(Comember->Fullname,1,30) +' ³ '+ Comember->GRUPCODE + Comember->Shortname );
                     }                                                    ,,;
                     {|| !Comember->( eof() ) .and. ;
                          Comember->COMCODE == mCOMCODE .and. ;
                          Comember->brcode == g_PAR_BRCH ;
                     } ;
                   )
         Comcodes->( dbgoto(mcomrec) )
      endif

      @ 7,2 clear to 18,40
      fshadow ( 7, 2, 21, 41, 2, 'n/w')
      @ 8 ,3 say padc(mComname,38)  color 'w+/w'
      @ 9 ,2 say 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´' color 'n/w'
      @ 17,2 say 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´' color 'n/w'
      @ 18,3 say '  Min. Requirement        Selected    ' color 'w+/w'
      @ 19,3 say '     A - '+tran(mreqa,'99')+'                           ' color 'w+/w'
      @ 20,3 say '     B - '+tran(mReqb,'99')+'                           ' color 'w+/w'
      @ 19,32 say tran(aSlct,'99')  color 'n/w'
      @ 20,32 say tran(bSlct,'99')  color 'n/w'
      cont := .t.
      mSELECTED      :=  0 ; mOK_TO_SELECT  := .t.
      while cont
        appray_ := {}
        appray2_:= {}
        msignee  := 1
        aslct :=0
        bSlct :=0
        setcolor('w/n,n/w')
        do while .t. // mSIGNEE != 0
          mSIGNEE := achoice ( 10, 4, 16, 39, members,.t.,'myfunc', mSIGNEE,mSignee )
          do case
            case lastkey() == K_ESC
                   cont := .f.
                   restscreen ( ,,,, mSCR )
                   restdbf ( mdbf )
                   return .f.
            case lastkey () == K_ENTER //.or. lastkey() == K_ESC
               mGCTR := 0
               mCTR  := 0
               if bslct < mReqb
                  Error('Insufficient Group B signees...!!')
                  loop
               elseif aslct < mReqa
                  Error('Insufficient Group A signees...!!')
                  loop
               endif
               for i := 1 to len ( members )
                   if substr( members [i],1,1) == chr(001)//'û'
                      aadd(appray_,alltrim( substr(members[i],37,60) ) )
                   endif
               next i
               cont:=.f.
               exit
            case lastkey () == 32
              if bSlct+aSlct <= 7
               if substr( members [ mSIGNEE ],1,1) = chr(001)//'û'
                  members [ mSIGNEE ] := '  ' + substr(members [ mSIGNEE ],3,len ( members [ mSIGNEE ]  ) - 1 )
                  if(substr(members[ msignee ],36,1) == 'B',bSlct--,aSlct--)
               else
                  if substr(members[ msignee ],36,1) == 'B'
                     members [ mSIGNEE ] := chr(001)+' '+ substr(members [ mSIGNEE ],3,len ( members [ mSIGNEE ]  ) - 1 )
                     //mSELECTED++ ; //mSIGNEE++
                     bslct++
                     if mSIGNEE > len ( members )
                        mSIGNEE := len ( members )
                     endif
                  else
                     members [ mSIGNEE ] := chr(001)+' ' + substr(members [ mSIGNEE ],3,len ( members [ mSIGNEE ]  ) - 1 )
                     //mSELECTED++ ; //mSIGNEE++
                     aslct++
                     if mSIGNEE > len ( members )
                        mSIGNEE := len ( members )
                     endif
                  endif
               endif
               @ 19,32 say tran(aSlct,'99')  color 'n/w'
               @ 20,32 say tran(bSlct,'99')  color 'n/w'
              else
                tone(1000,3)
              endif
         endcase
         mSignee := mSignee+1
       enddo
       gf:=savescreen( ,,, )
       if credcom
          cont := .t.
          bSlct:= 0
          aSlct:= 0
          @ 5,12 clear to 16,50
          //@ 8 ,12 to 16,50 double
          fshadow ( 5, 12, 19, 51, 2, 'n/w')
          @ 6 ,13 say padc(mComname2,38)  color 'w+/w'
          @ 7,12 say 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´' color 'n/w'
          @ 15,12 say 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´' color 'n/w'
          @ 16,13 say '  Min. Requirement        Selected    ' color 'w+/w'
          @ 17,13 say '     A - '+tran(mreqa2,'99')+'                           ' color 'w+/w'
          @ 18,13 say '     B - '+tran(mReqb2,'99')+'                           ' color 'w+/w'
          @ 17,42 say tran(aSlct,'99')  color 'n/w'
          @ 18,42 say tran(bSlct,'99')  color 'n/w'
          msignee  := 1
          mSELECTED      :=  0 ; mOK_TO_SELECT  := .t.
          setcolor('w/n,n/w')
          do while .t.  //mSIGNEE != 0
             mSIGNEE := achoice ( 8, 14, 14, 49, member2,.t.,'myfunc', mSIGNEE,mSignee )
             do case
                case lastkey() == K_ESC
                     //breaker:=.t.
                     cont := .t.
                     for i:=1 to len(members)
                         members[ i ]:= '  '+substr(members[i],3,len(members[i] ) -1 )
                     next i
                     for i := 1    to len(member2)
                         member2[ i ]:= '  '+substr(member2[i],3,len(member2[i] ) -1 )
                     next i
                     restscreen( , , , ,gf )
                     exit
                case lastkey () == K_ENTER   //.or. lastkey() == K_ESC
                     if bslct < mReqb2
                        Error('Insufficient Group B signees...!!')
                        loop
                     elseif aslct < mReqa2
                        Error('Insufficient Group A signees...!!')
                        loop
                     endif
                     for i := 1 to len ( member2 )
                         if substr( member2 [i],1,1) == chr(001) //'û'
                            aadd(appray2_,alltrim( substr(member2[i],37,60) ) )
                         endif
                     next i
                     cont := .f.
                     exit
                case lastkey () == 32
                    if bSlct+aSlct <= 7
                     if substr( member2[ mSIGNEE ],1,1) = chr(001)   //'û'
                        member2 [ mSIGNEE ] := '  '+substr(member2 [ mSIGNEE ],3,len ( member2 [ mSIGNEE ]  ) - 1 )
                        if(substr(member2[ msignee ],36,1) == 'B',bSlct--,aSlct--)
                     else
                        if substr(member2[ msignee ],36,1) == 'B'
                           member2 [ mSIGNEE ] := chr(001)+' ' + substr(member2 [ mSIGNEE ],3,len ( member2[ mSIGNEE ]  ) - 1 )
                           bslct++
                           if mSIGNEE > len ( member2 )
                              mSIGNEE := len ( member2 )
                           endif
                        else
                            member2 [ mSIGNEE ] := chr(001)+' ' + substr(member2 [ mSIGNEE ],3,len ( member2[ mSIGNEE ]  ) - 1 )
                            //mSELECTED++ ; //mSIGNEE++
                            aslct++
                            if mSIGNEE > len ( member2 )
                               mSIGNEE := len ( member2 )
                            endif
                        endif
                     endif
                     @ 17,42 say tran(aSlct,'99')  color 'n/w'
                     @ 18,42 say tran(bSlct,'99')  color 'n/w'
                    endif
                endcase
                mSignee := mSignee+1
             enddo
          endif
       enddo
   endif

   restscreen ( ,,,, mSCR )
   
   restdbf ( mdbf )
return .t.

*******************************************
*
*      abb 3.16.2001
*
static function _sub_crecomm ( ccommcode )
*******************************************
   local lretval := .f.
   subcred->(dbgotop())
//   subcred->(dbseek(Parametr->brcode)) // abb 12.08.2004
   do while !subcred->(eof()) // .and. Subcred->brcode == g_PAR_BRCH

      if ccommcode == subcred->comcode
         lretval := .t.
         _select_sub( @ccommcode )
         Comcodes->(dbseek(g_PAR_BRCH+ccommcode))
         return lretval
      endif

      subcred->(dbskip(+1))
   enddo

return lretval

***************************************
*
static function _select_sub (ccommcode)
***************************************
   local ccom2 := space(len(Comcodes->comcode)),nrec := Subcred->(recno())

   center  ( 24, 'w+/n','® Pick Sub-Credit Committee ¯')

   Subcred->( dbgotop() )
//   Subcred->( dbseek(Parametr->brcode) )   // abb 12.08.2004
   do while .t.
      lb_lkup  ( 'Subcred', 1, 1, @ccom2, 2 , 1, 11, 22, 21, 75, 'w/gr+,w/n,,,w/gr+' )
      if lastkey() == K_ENTER
	     IF g_PAR_BRCH == '001'
            ccommcode := ccom2
		 ELSE
		    IF ccom2 == '03'
			   ccommcode := '04'
			ELSE
			   ccommcode := '03'
			ENDIF
		 ENDIF
         exit
      endif
   enddo
   Subcred->(dbgoto(nrec))
return nil
/*
***********************************************
*
Static function myfunc ( status, curr_elem, curr_row )
***********************************************
   local key := lastkey()
   do case
      case key == K_ESC
         return 0
      case key == K_ENTER
         return 0
      case key == 32
         // tone( 1600, 1) ; tone( 800, 1)
         tone( 800, 1)
         return 1
    endcase
return 2
*/
***********************************************
