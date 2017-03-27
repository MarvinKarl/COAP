/*
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   PROGRAM ID.........:  amsm0100.prg                                         ³
³   Description........:  credit application file maintenance                  ³
³   Author.............:  Ariel B. Bulan                                       ³
³   Date...............:  11:54pm 15-Aug-1994                                  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                        ³  U P D A T E S  ³
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³        Who        ³     When      ³               Why                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Janet L. Bautista ³  22-Apr-1996  ³ follow standard coding structure         ³
³ Renan Evangeslita ³  25-May-1996  ³ Reconstruct the CA Line printing         ³
³ Renan Evangelista ³  25-Jun-1996  ³ limit the access of Ao                   ³
³ Janet L. Bautista ³  10-Sep-1997  ³ rv & gd to 5 decimal places              ³
³ ariel b. bulan    ³  january 21,00³ rv & gd to 6 decimal places              ³
³ ariel b. bulan    ³  march 16,2001³ add another selection if total           ³
³                   ³               ³ receivables <= maximum of                ³
³                   ³               ³ subcredit II committee                   ³
³ abb               ³  02.20.2003   ³ AMS - CA & OT Tagging for                ³
³                   ³               ³                                          ³
³                   ³               ³                                          ³
³                   ³               ³ -- FOR ONLINE USE --  10.25.04abb        ³
³ mts               ³  7/21/2008    ³  comment out (Scanning for valid branch/ ³
³                   ³               ³  user records) & modified for exlusive   ³
³                   ³               ³  use according to user's branch code     ³
³ mts               ³  8/18/2010    ³  added Orix rental & OALP facility       ³
³ mts               ³  8/31/2011    ³  added wtax on CADETAIL for CML & ML     ³
³ RLV               ³  9/20/2011    ³  Modified Structure for DOSRI Tagging    ³
³ mts               ³  9/09/2013    ³  added validation that net proceeds/     ³
³                   ³               ³  purchase amount of sub-limit should be  ³
³                   ³               ³  higher than the net proceeds of the main³
³                   ³               ³  facility                                ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include "COLF.CH"
#include "INKEY.CH"
#include "MEMOEDIT.CH"

private xTEMP     // EVR 28112006

if CHKPASS ( procname(),ax_level,g_user_id )  // if the user can access this function
   if amsm0100open()                          // if all .dbf files are opened
//      nosnow ( .t. )                          // turn on screen snow checking

      //drop   ( '[û]'+alltrim(g_user_id)+' '+'Enters CA Maintenace' )   //aga.15.10.2007.essential trace only
	  
	  

      fm0100 ()                               // call the main program

      (xTEMP)->(dbclosearea())     // EVR 28112006
      ferase(xTEMP+'.DBF')
      ferase(xTEMP+'.NTX')

      //drop   ( '[X]'+alltrim(g_user_id)+' '+'quits CA Maintenance' )   //aga.15.10.2007.essential trace only

  //    nosnow ( .f. )                          // turn off screen snow checking

   endif
endif
__mrelease ( "*",.t. )                        // release all private variables
dbcloseall ()                                 // close all .dbf's
return                                       // return to the calling program
******************************************
*   Description   program's main function
*   Parameters    none
*   Return Value  nil
static function fm0100()
******************************************
local cb, mbanner := 'Credit Application File Maintenance', mrow := 1, cAO := ' '     // EVR 28112006
LOCAL mBLOCK := { | X | CADETAIL->BRCODE+CADETAIL->CANUMBER == X }, mCOLOR := 'GR+/B', nROW := 5  && RED 'local mblock := { | x | Cadetail->canumber == x .and. Cadetail->brcode == Caheader->brcode}, mcolor := 'gr+/b', nrow := 5
local keys_  := { '<Ins>\-Add ', '<F2>\Edit ', '<F3>\Color ', '<F4>\Search ', '<F6>\Action ', '<F9>\Print ', '<Tab>\-Window' }
local tbcol_ := { tbcolumnnew( padr( 'Facility' , 11 ), { || dispfaculty( Cadetail->fcltycode ) + ' ' + dispalias( Cadetail->fcltycode ) } ),;
                  tbcolumnnew( padr( 'Amount'   , 14 ), { || tran( Cadetail->principal, '999,999,999.99' ) } ),;
                  tbcolumnnew( padr( 'Term'     ,  8 ),;
                               { || tran( Cadetail->term, '999' ) + ' ' + ;
                                    if( Cadetail->termunit == '1',;
                                        'Days    ',;
                                        if( Cadetail->termunit == '2',;
                                            'Month(s)',;
                                            if( Cadetail->termunit == '3',;
                                                'Year(s) ',;
                                                if ( Cadetail->termunit == '4',;
                                                     'Week(s)',;
                                                     space(8);
                                                   );
                                              );
                                          );
                                      );
                               };
                             ),;
                  tbcolumnnew( padr( 'Eff Rate' ,  8 ), { || tran( Cadetail->truerate, '99.9999' ) } ),;
                  tbcolumnnew( padr( 'Availment', 14 ), { || tran( Cadetail->prnavail, '999,999,999.99' ) } ),;
                  tbcolumnnew( padr( 'Balance'  , 14 ), { || tran( Cadetail->principal - Cadetail->prnavail, '999,999,999.99' ) } ) }
private cdivhead := space(5)       , cdivpost     := space(30)
private creason  := space(1)       , _reason_desc := space(40)
private sbrcode := g_PAR_BRCH, cbrcode := g_PAR_BRCH
private scanumber := space(8) 
private mclntcode

dbselectar((xTEMP))     // EVR 28112006
if Aoaccess->(dbseek(g_PAR_BRCH+g_USER_ID))
   do while !Aoaccess->(eof()) .and. Aoaccess->BRCODE+Aoaccess->AOCODE == g_PAR_BRCH+g_USER_ID
      if Aoaccess->AOACCESS <> cAO
         if Ao->(dbseek(padr(alltrim(Aoaccess->AOACCESS),5,' ')))
            append blank
            (xTEMP)->AOCODE := Ao->AOCODE
            (xTEMP)->AONAME := Ao->AONAME
         endif
      endif
      cAO := Aoaccess->AOACCESS
      Aoaccess->(dbskip())
   enddo
endif

dbselectarea( 'Caheader' )
Caheader->( dbgotop() )

   @ 8,30 clear to 10,65
   @ 8,30 to 10,65
   @ 9,31 say 'Credit Application No. : '
   @ 9,56 get scanumber pict '@R 999-99999' VALID ( EMPTY(SCANUMBER) .OR. IF(VALBRCODE( LEFT(SCANUMBER,3), g_USER_ID),.T.,EVAL({|| SCANUMBER:=SPACE(8),.F.})) )

   setcursor(3)
   read
   setcursor(0)

   if lastkey() == K_ESC
      return
   endif

   nrecno := 0
   if empty(scanumber)

      nrecno := Caheader->(recno())

      if !fsearch (sbrcode)  //aga.22.11.2005.marker...returns "no existing ca on file"

         if Client->brcode != sbrcode

            //error ( 'Client not found in branch ' + Parametr->brcode + '-' + _get_branch(g_PAR_BRCH) )
            sbrcode := Client->brcode
            mclntcode := CLIENT->BRCODE+Client->brcode      && RED 112404 ADDED 'CLIENT->BRCODE
            // return
         else

            sbrcode   := Client->brcode            // abb 10.25.2004
            mclntcode := CLIENT->BRCODE+Client->clntcode    && RED 112404 ADDED 'CLIENT->BRCODE
            __keyboard( chr( K_INS ) )
         endif

      else

         *if !_rights ( CAHEADER->BRCODE, Caheader->aocode ) .or. Caheader->(eof())
         if !_rights ( Caheader->aocode ) .or. Caheader->(eof())
            error ( 'CA belongs to '+Caheader->aocode )
            Caheader->(dbgoto(nrecno))
            return
         endif

         if !_BR_rights ( g_USER_ID, 'CAHEADER' )   // ABB 10.12.2004
            error ( 'Cannot access CA of ' + _get_branch(Caheader->brcode) )
            Caheader->( dbgoto(nrecno) )
            return   // abb 10.22.04
         else

            *if !_rights ( CAHEADER->BRCODE, Caheader->aocode ) .or. Caheader->(eof())
            if !_rights ( Caheader->aocode ) .or. Caheader->(eof())
               error ( 'CA belongs to '+Caheader->aocode )
               Caheader->(dbgoto(nrecno))
               return  // abb 10.22.04
            else
               sbrcode   := Caheader->brcode
               scanumber := CAHEADER->BRCODE+Caheader->canumber       // abb 10.25.2004      && RED 112404 ADDED 'CAHEADER->BRCODE
            endif

         endif

      endif

      if lastkey() == K_ESC
         return
      endif

   else
      *scanumber := right ( '00000'+alltrim(scanumber),5 )     && RED 112304
      IF LEN(ALLTRIM(SCANUMBER)) < 8
         SCANUMBER := LEFT(SCANUMBER,3) + PADL(ALLTRIM(SUBSTR(SCANUMBER,4,5)),5,'0')
      ENDIF
   endif

   if !empty(scanumber)

      sbrcode   := g_PAR_BRCH

//      mclntcode := Client->clntcode

      if !Caheader->(dbseek(scanumber))  && RED REMOVED 'sbrcode+
         error ( 'CA No. '+scanumber+' for branch '+sbrcode+' not found' )
         return
      endif

      *if !_rights ( CAHEADER->BRCODE, Caheader->aocode )
      if !_rights ( Caheader->aocode )
         error ( 'CA belongs to '+Caheader->aocode )
         Caheader->( dbgoto(nrecno) )
         return // abb 10.22.04
      endif

      nscanctr := 0
	  /** PEPE 10:03 AM 7/23/2008
      *do while !_rights ( CAHEADER->BRCODE, Caheader->aocode ) .and. !Caheader->(eof())
      do while !_rights ( Caheader->aocode ) .and. !Caheader->(eof())
         nscanctr :=  nscanctr + 1
         @ 22,1 say 'Scanning for valid branch/user records : '+padr( alltrim(trans(nscanctr,"99,999,999" )), 12 )
         Caheader->(dbskip(+1))
      enddo


	  if !_rights(Caheader->aocode)
	      error ( 'CA belongs to '+Caheader->aocode )
		  Caheader->(dbgobottom())
		  Caheader->(dbskip(+1))
	  endif
	  **/
	  
   endif

   // if Caheader->( eof() )
   //    error( "No Record Found!" )
   //    sbrcode := Client->brcode            // abb 10.25.2004
   //    __keyboard( chr( K_INS ) )
   // endif

   mdbf_ := savedbf()
   dbselectar( 'Cadetail' )
   Cadetail->( dbseek( Caheader->brcode+Caheader->canumber ) )

   cb := __tb_maker( tbcol_, keys_,  , 1,   , 78, mbanner ,,    ,;
         CAHEADER->BRCODE+Caheader->canumber, mblock, 9 ,,,,,sbrcode )    && RED 112404 ADDED 'CAHEADER->BRCODE

   restdbf( mdbf_ )

//ALERT(CAHEADER->BRCODE+Caheader->canumber)
*do while !_rights ( CAHEADER->BRCODE, Caheader->aocode ) .and. !Caheader->(eof())
//do while !_rights ( Caheader->aocode ) .and. !Caheader->(eof())
//   Caheader->(dbskip(+1))
//enddo

if Caheader->( eof() )
   error      ( "No record found!" )
   sbrcode := Client->brcode            // abb 10.25.2004
   __keyboard ( chr( K_INS ) )
endif

while eval( { || disphead( 'w+/b' )         ,; // header
                 gkey0100( cb, @mrow, @nrow ) ; // wait key
            } )
enddo

__mxrelease( tbkill_cel  , tbkill_arg    , tbkill_lastrec, tbkill_code,;
             tbkill_where, tbkill_color  , tbkill_rel    , tbkill_mtop,;
             tbkill_mleft, tbkill_mbottom, tbkill_mright )  
return( nil )

***************************************
*
*
static function gkey0100( cb, mrow, nrow )
***************************************
local  mretval := .t., mkey, mdbf_, nrecno := 0
memvar AX_LEVEL,G_USER_ID, tbkill_lastrec, tbkill_code
private mscreen,mtotblnc:=0,mtotcrdt:=0,appray_:={},appray2_:={}, mipp := 0
Private mcomname:='',mcomname2:=''
mdbf_ := savedbf()
dbselectar( 'Cadetail' )
//
// Cadetail->( dbseek( tbkill_code := Caheader->canumber ) )
//
Cadetail-> ( dbseek( TBKILL_CODE := Caheader->brcode+Caheader->canumber ) )

_tb_refresh ( cb )

restdbf (mdbf_)

mkey := inkey(0)

do case

   case mkey == K_UP .or. mkey == K_PGUP

        if g_PAR_BRCH == '001'

        if CHKPASS( 'S', AX_LEVEL, G_USER_ID )
            nrecno := Caheader->(recno())

            Caheader->( dbskip( -1 ) )

            if alltrim(Caheader->brcode) != alltrim(sbrcode)
               error ( 'Top of Branch File' )
               Caheader->(dbgoto(nrecno))

            else

               nscanctr := 0
               cscr := savescreen (,,,)
			   
			   /** pepe 2:12 PM 7/21/2008
               *do while !_rights(CAHEADER->BRCODE, Caheader->aocode)  .and. !Caheader->(bof())
               do while !_rights( Caheader->aocode)  .and. !Caheader->(bof())
                  nscanctr :=  nscanctr + 1
                  @ 22,1 say 'Scanning for valid branch/user records : '+padr( alltrim(trans(nscanctr,"99,999,999" )), 12 )
                  Caheader->(dbskip(-1))

                  if alltrim(Caheader->brcode) != alltrim(sbrcode)
                     restscreen (,,,,cscr )
                     if alltrim(sbrcode) == '001'
                        error ( 'Top of Head Office File' )
                     else
                        error ( 'Top of Branch File' )
                     endif
                     Caheader->(dbgoto(nrecno))
                     exit
                  endif
     
               enddo
			   **/
			   
			   if !_rights(CAHEADER->aocode)
		 	      CAHEADER->(dbskip(-1))
		          if !aoaccess->(dbseek(alltrim(CAHEADER->brcode)+left(alltrim(G_USER_ID)+'   ',6)+alltrim(CAHEADER->aocode)))

			       do while !CAHEADER->(bof())
			         if aoaccess->(dbseek(alltrim(CAHEADER->brcode)+left(alltrim(G_USER_ID)+'   ',6)+alltrim(CAHEADER->aocode)))
			 	        exit
			         endif
			       CAHEADER->(dbskip(-1))
			      enddo
			    endif
			   endif
			   
               restscreen (,,,,cscr )

               if Caheader->(bof())
                  error ( 'This is the first record'  )
                  Caheader->(dbgoto(nrecno))
               endif
            endif

        endif
        endif

   case mkey == K_DOWN .or. mkey == K_PGDN

        if g_PAR_BRCH == '001'

        if CHKPASS ( 'S', AX_LEVEL, G_USER_ID )

            nrecno := Caheader->(recno())

            Caheader->( dbskip( +1 ) )
			
			IF Caheader->BRCODE ==  g_PAR_BRCH
			
	            cscr := savescreen (,,,)
	            nscanctr := 0
				
				/** pepe 2:12 PM 7/21/2008
	            *do while !_rights ( CAHEADER->BRCODE, Caheader->aocode ) .and. !Caheader->(eof())
	            do while !_rights ( Caheader->aocode ) .and. !Caheader->(eof())
	               nscanctr :=  nscanctr + 1
	               @ 22,1 say 'Scanning for valid branch/user records : '+padr( alltrim(trans(nscanctr,"99,999,999" )), 12 )
	               Caheader->(dbskip(+1))

	               if alltrim(Caheader->brcode) != alltrim(sbrcode)
	                  restscreen (,,,,cscr )

	                  if alltrim(sbrcode) == '001'         // abb 10.13.2004
	                     error ( 'End of Head Office File' )
	                  else
	                     error ( 'End of Branch File' )
	                  endif
	                  Caheader->(dbgoto(nrecno))
	                  exit
	               endif

	            enddo
				**/

				if !_rights(Caheader->aocode)
		 		   Caheader->(dbskip(+1))
			           if !aoaccess->(dbseek(alltrim(Caheader->brcode)+left(alltrim(G_USER_ID)+'   ',6)+alltrim(Caheader->aocode)))

					      do while !Caheader->(eof())
						     if Caheader->brcode == g_PAR_BRCH
						          if aoaccess->(dbseek(alltrim(Caheader->brcode)+left(alltrim(G_USER_ID)+'   ',6)+alltrim(Caheader->aocode)))
							         exit
						          endif
							 endif 
					      Caheader->(dbskip(+1))
						  enddo
					   endif
				endif

	            restscreen (,,,,cscr )
			
			ELSE
		        Caheader->(dbgobottom())
	            Caheader->(dbskip(+1))
			ENDIF
			
			if Caheader->(eof())
               error ( 'This is the last record' )
               Caheader->( dbgoto(nrecno) )
            endif

        endif
        endif

   case mkey == K_INS
        if CHKPASS( 'A', AX_LEVEL, G_USER_ID )
           cbrcode := sbrcode
           updatehead( 'A' )
        endif   
   case mkey == K_DEL

        if CURRBRCH(CAHEADER->BRCODE) .AND. chkpass ( 'D', AX_LEVEL, G_USER_ID ) .and. Caheader->actaken == '1'

           if Caheader->( eof() )
              error( 'Nothing to Delete!' )    
           else

              *if _rights( CAHEADER->BRCODE, Caheader->aocode )
              if _rights( Caheader->aocode )
                 if confirm ( 'Delete CA N§ '+ tran( CAHEADER->BRCODE+Caheader->canumber, '@R 999-99999' )+ '?' )

                    delete_head ()
                    **nrecno := Caheader->(recno())

                    **do while !_rights ( Caheader->aocode ) .and. !Caheader->(eof())
                      ** Caheader->(dbskip(+1))
                    **enddo

                    **if Caheader->(eof())
                      ** error ( 'No Records left' )
                       **Caheader->( dbgoto(nrecno) )
                    **endif

                     nrecno := Caheader->(recno())

                     Caheader->( dbskip( +1 ) )
                     cscr := savescreen (,,,)
                     nscanctr := 0
					 
			         /** pepe 2:12 PM 7/21/2008
                     *do while !_rights ( CAHEADER->BRCODE, Caheader->aocode ) .and. !Caheader->(eof())
                     do while !_rights ( Caheader->aocode ) .and. !Caheader->(eof())
                        nscanctr :=  nscanctr + 1
                        @ 22,1 say 'Scanning for valid branch/user records : '+padr( alltrim(trans(nscanctr,"99,999,999" )), 12 )
                        Caheader->(dbskip(+1))

                        if alltrim(Caheader->brcode) != alltrim(sbrcode)
                           restscreen (,,,,cscr )

                           if alltrim(sbrcode) == '001'         // abb 10.13.2004
                              error ( 'End of Head Office File' )
                           else
                              error ( 'End of Branch File' )
                           endif
                           Caheader->(dbgoto(nrecno))
                           exit
                        endif

                     enddo
				     **/
				  
					  if !_rights(Caheader->aocode)
				 	     Caheader->(dbskip(-1))
				         if !aoaccess->(dbseek(alltrim(Caheader->brcode)+left(alltrim(G_USER_ID)+'   ',6)+alltrim(Caheader->aocode)))

						     do while !Caheader->(bof())
						       if aoaccess->(dbseek(alltrim(Caheader->brcode)+left(alltrim(G_USER_ID)+'   ',6)+alltrim(Caheader->aocode)))
						 	      exit
						       endif
						     Caheader->(dbskip(-1))
						    enddo
						  endif
					  endif
				  
                     restscreen (,,,,cscr )

                     if Caheader->(eof())
                        error ( 'This is the last record' )
                        Caheader->( dbgoto(nrecno) )
                     endif

                 endif

              else
                 error ( 'Cannot delete CA of '+Caheader->aocode )
              endif

           endif   
        endif   
   case mkey == K_F2

        if CURRBRCH(CAHEADER->BRCODE)                   .AND. ;
           CHKPASS( 'E', AX_LEVEL, G_USER_ID )          .and. ;
           _chkright(Caheader->Aocode,Caheader->brcode) .and. ;
           Caheader->actaken == '1'

           if Caheader->( eof() )
              error( 'Nothing to Edit!' )
           else

              if Caheader->actaken == '3'
                 error( 'Application already APPROVED!' )
              else
                 updatehead( 'E' )
              endif

           endif

        endif

   case mkey == K_F4

        if CHKPASS( 'S', AX_LEVEL, G_USER_ID )

           if Caheader->( eof() )
              error( 'Nothing to Search!' )
           else
              nrecno := Caheader->(recno())
              search_head( sbrcode,space( len( CAHEADER->BRCODE+Caheader->canumber ) ) )

              if Caheader->BRCODE <> g_PAR_BRCH //pepe 2:27 PM 7/23/2008 {!_BR_rights ( g_USER_ID, 'CAHEADER' )   // ABB 10.12.2004}
                 error ( 'Cannot access CA of ' + _get_branch(Caheader->brcode) )
                 Caheader->(dbgoto(nrecno))
              else

                 *if !_rights ( CAHEADER->BRCODE, Caheader->aocode ) .or. Caheader->(eof())
                 if !_rights ( Caheader->aocode ) .or. Caheader->(eof())
                    error ( 'CA belongs to '+Caheader->aocode )
                    Caheader->(dbgoto(nrecno))
                 else
                    sbrcode := Caheader->brcode
                 endif

//              if !_rights ( Caheader->aocode ) .or. Caheader->(eof())
  //               error ( 'CA belongs to '+Caheader->aocode )
    //             Caheader->(dbgoto(nrecno))
      //        endif
             endif

           endif
        endif

   case mkey == K_F6

        if chkpass  ( 'E', AX_LEVEL, G_USER_ID ) .and. ;
           _chkright ( Caheader->Aocode,Caheader->brcode)
		   if Client->(dbseek(Caheader->brcode+Caheader->clntcode))
		   if Client->status != '3'
			   error('Client not yet reviewed!')
		   else
           IF CADETAIL->(DBSEEK(Caheader->brcode+Caheader->CANUMBER)) .or. Caheader->CATYPE == '2'
			   if look_approver ( G_USER_ID )
                  IF CHK_AVAIL(Caheader->brcode,Caheader->CANUMBER,Caheader->actaken)
					 if Caheader->( eof() )
					    error( 'Nothing to Edit!' )
					 else
					    if _rights ( Caheader->aocode )
						  if alltrim(Caheader->AOCODE) != alltrim(G_USER_ID)
						     updatehead ( 'E', .t.)
						  else
						     alert ( 'ERROR : User cannot approve own Credit Application / Offering Ticket' )
						  endif
					   else
						  error ( 'Cannot update CA of '+ Caheader->aocode )
					   endif
					 endif
				  ENDIF
			   else
				  error ( 'User '+alltrim(G_USER_ID)+' Cannot Proceed ' )
			   endif
		   ELSE
	
		       ERROR('Cannot update CA status! No facility found!')		   

		   ENDIF
		   endif
		   endif

        endif

   case mkey == K_F9

        if chkpass ( 'S', AX_LEVEL, G_USER_ID )

           if Caheader->( eof() )
              error( 'Nothing to Print!' )
           else

              *if _rights ( CAHEADER->BRCODE, Caheader->aocode )
              if _rights ( Caheader->aocode )

                 if includes_are_ok()
                    mscreen := savescreen( ,,, )
                    waiton( 'Generating report..,pls. wait..',, 'n*/+w' )
                    if count_total()
                       waitoff()
                       if _getdivhead(Caheader->AOCODE)  // division head 10/10/2000
					   
                          if checkcomtt ( mtotblnc+mtotcrdt,CAheader->catype)
                             *repcontrol ( 'caprint()' )
                             repcon_ol ( 'caprint()',,,,,,,.F. )
                             drop       ( alltrim(g_user_id)+' '+'Prints CA No. '+Caheader->CANUMBER )
                          endif
                       endif
                    else
                       waitoff()
                    endif

                 endif

              else
                 error ( 'Cannot print CA of '+ Caheader->aocode )
              endif
           endif
        endif

   case mkey == K_TAB
        if !Caheader->( eof() )

           *if _rights ( CAHEADER->BRCODE, Caheader->aocode )
           if _rights ( Caheader->aocode )

              if Caheader->actaken == '1'
                 mdbf_ := savedbf ()
                 dbselectar ( 'Cadetail' )
                 tbkill_lastrec := 1
////                 Cadetail-> ( dbseek( tbkill_code := Caheader->brocode+Caheader->canumber ) )

                 Cadetail-> ( dbseek( TBKILL_CODE := Caheader->brcode+Caheader->canumber ) )
                 Cadetail-> ( dbeval( { || tbkill_lastrec++ },,;
                            { || Cadetail->brcode+Cadetail->canumber == Caheader->brcode+Caheader->canumber };
                                                             ) )

                 tbkill_lastrec := max( tbkill_lastrec, 1 )
///                 Cadetail-> ( dbseek( tbkill_code := Caheader->brcode + Caheader->canumber ) )

                 Cadetail-> ( dbseek( TBKILL_CODE := Caheader->brcode + Caheader->canumber ) )
                 Cadetail-> ( __tb_stabilizer( cb, { | o, k | case0100( o, k ) } ) )
                 restdbf    ( mdbf_ )

              else

                 if Caheader->actaken == '3'
                    error( 'Application already APPROVED!' )
                 endif

              endif

           else
              error ( 'Cannot update CA of '+ Caheader->aocode )
           endif

        endif   
   case mkey == K_ESC
        if exitmod()
           mretval := .f.
        endif
endcase
tb_indicator( mkey, @mrow, @nrow, 78, 5, 10 )
return( mretval )


*******************************************************
*
STATIC FUNCTION CHK_AVAIL(mbr_code,mca_num,mact_taken)
*******************************************************
local lretval := .t., mdbf := alias()

if mact_taken == '5'
   lretval := .f.
   error("C.A. already CLOSED!")
endif

/*****
if mact_taken <> '1'


   if NETUSE(  '&g_AMS_path\Acctdaly',.f.,5)
      set index  to &g_AMS_path\Acctdaly
   endif
   

	if Acctdaly->(dbseek(mbr_code))
	   do while Acctdaly->brcode == mbr_code .and. ;
			   !Acctdaly->(eof())
		  if Acctdaly->docref == '1' .or. Acctdaly->docref2 == '1'
			 if Acctdaly->refno == mca_num
				error("Cannot change status! CA is already been used!")
				lretval := .f.
			 endif
		  endif
	   Acctdaly->(dbskip())
	   enddo
	endif
    Acctdaly->(dbclosearea())

	
	if lretval
		waitntx := Acctwait->(indexord())
		Acctwait->(dbsetorder(5))
		if Acctwait->(dbseek(mbr_code+mca_num))
		   error("Cannot change status! CA is already been used!")
		   lretval := .f.
		else
		   Acctwait->(dbsetorder(6))
		   if Acctwait->(dbseek(mbr_code+mca_num))
			  error("Cannot change status! CA is already been used!")
			  lretval := .f.
		   endif
		endif
		Acctwait->(dbsetorder(waitntx))
	endif
	
	if lretval
		mastntx := Acctmast->(indexord())
		Acctmast->(dbsetorder(8))
		if Acctmast->(dbseek(mbr_code+mca_num))
		   error("Cannot change status! CA is already been used!")
		   lretval := .f.
		else
		   Acctmast->(dbsetorder(9))
		   if Acctmast->(dbseek(mbr_code+mca_num))
			  error("Cannot change status! CA is already been used!")
			  lretval := .f.
		   endif
		endif
		Acctmast->(dbsetorder(mastntx))
	endif
	
	dbselectarea(mdbf)
endif
*****/
RETURN lretval

***************************************
*
static function _rights ( caocode )
***************************************
    local lretval := .f.,nrec := aoaccess->(recno())
//    if aoaccess->(dbseek(alltrim(Caheader->brcode+G_USER_ID)))
    if aoaccess->( dbseek( alltrim(Caheader->brcode)+;
                           left(alltrim(G_USER_ID)+'   ',6)+;
                           alltrim(Caheader->aocode);
                         );
                 )

//       do while !aoaccess->(eof()) .and. ;
  //              alltrim(aoaccess->aocode) == alltrim(G_USER_ID) .and. ;
    //            alltrim(aoaccess->brcode) == alltrim(aoaccess->brcode)  ;

      //    if alltrim(aoaccess->aoaccess) == alltrim(caocode)
             lretval := .t.
        //  endif

          //aoaccess->(dbskip(+1))
       //enddo

    endif

    aoaccess->(dbgoto(nrec))

return lretval

//////////
//
static function case0100( cb, mkey )            
local mcolor := setcolor(), mscreen := savescreen( ,,, ), mreturn := .t.
local lsublimit := .F.
local mDTLCODE := 0, grecno
memvar AX_LEVEL, G_USER_ID

do case            
   case mkey == K_INS
        if CHKPASS( 'A', AX_LEVEL, G_USER_ID )
		
		   if CADETAIL->(dbseek(CAHEADER->brcode+CAHEADER->canumber))
			  if confirm("Create a sub-limit under this main facility?")
			 	 lsublimit := .T.
				 grecno := CADETAIL->(recno())
			     DO WHILE CADETAIL->BRCODE+CADETAIL->CANUMBER == CAHEADER->brcode+CAHEADER->canumber .AND.; 
				         !CADETAIL->(eof())
			        mDTLCODE := val(CADETAIL->DTLCODE) + 1
				 CADETAIL->(DBSKIP())
				 ENDDO
				 CADETAIL->(dbgoto(grecno))
			  else
			     grecno := CADETAIL->(recno())
			     DO WHILE CADETAIL->BRCODE+CADETAIL->CANUMBER == CAHEADER->brcode+CAHEADER->canumber .AND.; 
				         !CADETAIL->(eof())
						 
			        mfrstCODE := val(substr(CADETAIL->DTLCODE,1,2)) + 1
					mscndCODE := right('00'+alltrim(str(mfrstCODE)),2)+'01'							
					mDTLCODE  := val(mscndCODE)					
					
				 CADETAIL->(DBSKIP())
				 ENDDO
				 CADETAIL->(dbgoto(grecno))
			  endif
		   else
		      mDTLCODE := 101
		   endif
		   
	       if lastkey() <> K_ESC
              update_detail( 'A',lsublimit,mDTLCODE )
              _tb_refresh( cb, 'a' )
		   endif

        endif   
   case mkey == K_F2
        if CURRBRCH(CADETAIL->BRCODE)          .AND. ;
           CHKPASS( 'E', AX_LEVEL, G_USER_ID ) .and. ;
           _chkright(Caheader->Aocode,Caheader->brcode)

           if CADETAIL->BRCODE+Cadetail->canumber != CAHEADER->BRCODE+Caheader->canumber
              //Cadetail->(browse())
              error( 'Nothing to Edit!' )
              Cadetail->( dbseek( CAHEADER->BRCODE+Caheader->canumber ) )
           else
              update_detail( 'E' )
              _tb_refresh( cb, 'c' )
			  
           endif

        endif   
   case mkey == K_DEL
        if CURRBRCH(CADETAIL->BRCODE) .AND. CHKPASS( 'D', AX_LEVEL, G_USER_ID )
           if CADETAIL->BRCODE+Cadetail->canumber != CAHEADER->BRCODE+Caheader->canumber
              error( 'Nothing to Delete!' )
              Cadetail->( dbseek( CAHEADER->BRCODE+Caheader->canumber ) )
           else
              delete_detail()
              _tb_refresh( cb, 'a' )
           endif
        endif   
   case mkey == K_F4

        if CHKPASS( 'S', AX_LEVEL, G_USER_ID )
           if CADETAIL->BRCODE+Cadetail->canumber != CAHEADER->BRCODE+Caheader->canumber
              error( 'Nothing to Search!' )
              Cadetail->( dbseek( CAHEADER->BRCODE+Caheader->canumber ) )
           else
              search_detail( CAHEADER->BRCODE+Caheader->canumber, space( len( Cadetail->fcltycode ) ), cb:rowpos + 17 )
              _tb_refresh( cb, 'a' )
           endif
        endif    
   otherwise
        mreturn := !mreturn     

endcase
setcolor( mcolor )
restscreen( ,,,, mscreen )
return( mreturn )                 
*******************************************************************
*  Desc ¯ deletes record from Caheader.dbf and all the records from
*         Cadetail.dbf with the same CANUMBER
static function delete_head()
*******************************************************************
local mdbf := select(), mntx := indexord(), mrecno := recno()

select Caheader
if Caheader -> ( netlock('R',0) )
   select Cadetail

   if Cadetail->( dbseek ( CAHEADER->BRCODE+Caheader->CANUMBER ) ) // seek record to Cadetail
                                                  // if found then ...

      ***if Cadetail->( netlock( 'F', 0 ) )          // lock Cadetail.dbf and
                                                  // delete all records with
                                                  // matching CANUMBER
                                                  //
         Cadetail->( dbeval ( { || Cadetail->(netlock('R',0)) ,;
                                   Cadetail->(dbdelete())     ,;
                                   Cadetail->(dbunlock())      ;
                              } ,,;
                              { || CADETAIL->BRCODE+Cadetail->CANUMBER == CAHEADER->BRCODE+Caheader->CANUMBER .and. ;
                                  !Cadetail->( eof() ) ;
                              },,,;
                              .t. ;
                            );
                   )
         Cadetail->( dbunlock() )               // unlock Cadetail.dbf
      *** endif
   endif
   Cadetail->(dbcommit())
   select Caheader                        // select Caheader again!
   drop ( alltrim(g_user_id)+' '+'Deletes CA No. '+Caheader->CANUMBER )
   Caheader->( dbdelete() )               // delete the current record
   Caheader->( dbunlock() )                  // unlock Caheader

   Caheader->( dbskip(+1) )               // move to the next record
   if Caheader->( eof() )                 // if end-of-file
      Caheader->( dbskip(-1) )            // skip to the last record
   endif
   mrecno := Caheader->( recno() )        // save Caheader's record number
endif
Caheader->( dbcommit() )
select ( mdbf )                           // select last dbf used
set order to ( mntx )                     // select last index order
Caheader -> ( dbgoto ( mrecno ) )         // move the Caheader's record
return( nil )

****************************************************
*  Description   deletes CANUMBER from Cadetail.dbf
*  Parameters    CANUMBER
*  Return Value  nil
static function delete_detail()
******************************************************
   local mRECNO := Cadetail->(recno()),mretval := .f.
   local lmain_fclty := .f.
   
   if Cadetail->include

      alert("NOTE: All Sub-limits of this facility will also be deleted!")
      if confirm( 'Delete Facility Code ' + dispfaculty( Cadetail->fcltycode ) + ' ' +;
									  rtrim( dispalias( Cadetail->fcltycode ) ) + '?' )
									  
		  do while Cadetail->brcode+Cadetail->canumber == CAHEADER->BRCODE+Caheader->canumber .and. ;
		          !Cadetail->(eof())
				  
		     if !lmain_fclty
			 
				 drop ( alltrim(g_user_id)+' '+'Deletes facility ('+CADETAIL->FCLTYCODE+') of CA No. '+Caheader->CANUMBER )			  
				 
				 if Cadetail->(netlock( 'R', 0 ))
					Cadetail->( dbdelete() ); Cadetail->( dbskip ( 1 ) )
					if( Cadetail->( eof()  ) .or. CADETAIL->BRCODE+Cadetail->canumber != CAHEADER->BRCODE+Caheader->canumber,;
						Cadetail->( dbseek( CAHEADER->BRCODE+Caheader->canumber ) ), nil )
					mRECNO  := Cadetail->(recno())
					mretval := .t.
				 endif
				 Cadetail->( dbunlock() )
			 
	         //Cadetail->(dbskip())
		     lmain_fclty := Cadetail->include
			 else
			     exit
		     endif
			 
		  enddo
		  
	   endif
	   Cadetail->(dbgoto( mRECNO ))
	     
   else
	   if confirm( 'Delete Facility Code ' + dispfaculty( Cadetail->fcltycode ) + ' ' +;
									  rtrim( dispalias( Cadetail->fcltycode ) ) + '?' ) 
									  
		  drop ( alltrim(g_user_id)+' '+'Deletes facility ('+CADETAIL->FCLTYCODE+') of CA No. '+Caheader->CANUMBER )
		  
		  if Cadetail->(netlock( 'R', 0 ))
			 Cadetail->( dbdelete() ); Cadetail->( dbskip ( 1 ) )
			 if( Cadetail->( eof()  ) .or. CADETAIL->BRCODE+Cadetail->canumber != CAHEADER->BRCODE+Caheader->canumber,;
				 Cadetail->( dbseek( CAHEADER->BRCODE+Caheader->canumber ) ), nil )
			 mRECNO  := Cadetail->(recno())
			 mretval := .t.
		  endif
		  Cadetail->( dbunlock() )
	   endif
	   Cadetail->(dbgoto( mRECNO ))
   endif
return mretval
/*
*****************************************
*  Description   displays FACILITY ALIAS
*  Parameters    FACILITY CODE
*  Return Value  FACILITY ALIAS
function dispalias( mFCLTYCODE )
********************************
   Facility->( dbseek ( mFCLTYCODE ) )
return left( Facility->FCLTYALIAS, 5 )
*/
*********************************************************
*   Description   updates CADETAIL.DBF
*   Parameters    type >> 'A' = Add else Edit
*   Return Value  nil
static function update_detail( mWHAT,lsublimit,mDTLCODE )
*********************************************************
   local mSCR := savescreen(,,,)
   local mFCLTYCODE := if( mWHAT == 'A', space( len ( Cadetail->FCLTYCODE ) ), Cadetail->FCLTYCODE )
   local mCANUMBER  := Cadetail->CANUMBER
   local mCALINE2, mprnline
   
   nrecno := Cadetail->(recno())

   if mWHAT == 'A'
	  
		do while .t.
			lb_lkup('Facility', 1, 1,@mFCLTYCODE, 3 , 1, 06, 02, 16, 50, 'W/GR+,W/N,,,W/GR+')
		
			if lastkey() == K_ESC
				mFCLTYCODE := ''
				exit
			endif
			
			if mFCLTYCODE == '10520'
				error('Invalid Facility!!')
				loop
			else
				exit
			endif
			
		enddo

   endif
		
   if !empty ( mFCLTYCODE )
      get_setcode( mFCLTYCODE )

      if upper( mWHAT ) == 'A'
         center( 24, 'w+/n','® Add Record ¯')
      else   
         center( 24, 'w+/n', '® Edit Record ¯')
      endif
	  
      do case
         case Facility->SETCODE == '1'
            setcode_one  ( mWHAT, mFCLTYCODE,lsublimit,mDTLCODE )
         case Facility->SETCODE == '2'
            setcode_two  ( mWHAT, mFCLTYCODE,lsublimit,mDTLCODE )
         case Facility->SETCODE == '3'
            setcode_three( mWHAT, mFCLTYCODE,lsublimit,mDTLCODE )
         case Facility->SETCODE == '4' .or.;
              Facility->SETCODE == '5'
             setcode_five( mWHAT, mFCLTYCODE,lsublimit,mDTLCODE )
      endcase

      center( 24, 'w+/n', '               ')
   endif  
	  
	   eval( { |x| x := Cadetail->(recno()), mcaline2 := 0, mprnline := 0,;
				   Cadetail -> ( dbseek ( CAHEADER->BRCODE+Caheader->CANUMBER ) ) ,; && RED 112404 ADDED 'CAHEADER->BRCODE
				   Cadetail -> ( dbeval ( {|| if ( Cadetail -> INCLUDE,;
												 eval ({|| mcaline2 += Cadetail->CREDAMT  ,;
														   mprnline += Cadetail->PRINCIPAL ;
													  }), nil ) },,;
										  {|| CADETAIL->BRCODE+Cadetail->CANUMBER == ;
											  CAHEADER->BRCODE+Caheader->CANUMBER .and. ;
											  !Cadetail->(eof())})),;
				   Cadetail->(dbgoto(x))})
	   *MSGWIN(12,18,'Saving','W*/BG','R*/BG','ON')
	   if Caheader -> ( netlock('R',0) )
		  Caheader -> CALINE  := mcaline2
		  Caheader -> PRNLINE := mprnline    // August 3, 1995
		  Caheader -> (dbunlock())
		  Caheader -> (dbcommit())
	   endif
	   
	   if mWHAT == 'E'
		  drop ( alltrim(g_user_id)+' '+'Edits facility ('+CADETAIL->FCLTYCODE+') of CA No. '+Caheader->CANUMBER )
	   endif

	   Cadetail->(dbgoto(nrecno))
	
   *MSGWIN(12,18,'Saving','W*/BG','R*/BG','OFF')
   restscreen(,,,,mscr)
   
return nil

****************************************************************************************
*
static function chk_limits(mCANUMBER,mFCLTYCODE,mPRINCIPAL,mCREDAMT,minclude,lsublimit,mWHAT)
****************************************************************************************
local l_retval := .t., mrecno := cadetail->(RECNO())
local pre_purc := pre_crd := 0
local npurc := 0, ncred := 0
local ledit_include := .f.
local mdtlcd := cadetail->dtlcode


if upper(mWHAT) == 'A'

	if lsublimit == minclude
	   if lsublimit
		  error("You have selected this facility as Sub-limit!")
		  minclude := .f.
	   else
		  error("You have selected this facility as MAIN facility!")
		  minclude := .t.
	   endif
	endif
	
	
	if cadetail->(dbseek(g_PAR_BRCH+mCANUMBER))
	   do while cadetail->BRCODE + cadetail->CANUMBER == g_PAR_BRCH+mCANUMBER .and. ;
			   !cadetail->(eof())
			   
		  if cadetail->include
			 npurc := cadetail->principal
			 ncred := cadetail->credamt	     
		  endif

	   cadetail->(dbskip())
	   enddo
	   
	   //credit amount validation !!
	   
       if !minclude
		  if npurc < mPRINCIPAL
			 l_retval := .f.
			 error("Sub-limit(Purcamt) should not be higher than the main line.")
		  elseif ncred < mCREDAMT
			 l_retval := .f.
			 error("Sub-limit(Credcamt) should not be higher than the main line.")
		  endif
	   endif
	   
	endif
	cadetail->(dbgoto(mrecno))
		
else

	if CADETAIL->INCLUDE <> minclude
 	   error("Changing inclusion of line is not allowed.")
	   l_retval := .f.
	endif
	
    if !CADETAIL->INCLUDE
		if cadetail->(dbseek(g_PAR_BRCH+mCANUMBER))
		   do while cadetail->BRCODE + cadetail->CANUMBER == g_PAR_BRCH+mCANUMBER .and. ;
				   !cadetail->(eof())
				   
			  if cadetail->include
				 npurc := cadetail->principal
				 ncred := cadetail->credamt	     
			  endif
			  
			  if cadetail->(recno()) == mrecno
				 if npurc < mPRINCIPAL
				    l_retval := .f.
				    error("Sub-limit(Purcamt) should not be higher than the main line.")
				    exit
					
				 elseif ncred < mCREDAMT
				    l_retval := .f.
				    error("Sub-limit(Credamt) should not be higher than the main line.")
				    exit
					
			     endif
			  endif
		
		   cadetail->(dbskip())
		   enddo
		   
		endif
		cadetail->(dbgoto(mrecno))
	else
		if cadetail->(dbseek(g_PAR_BRCH+mCANUMBER))
		   do while cadetail->BRCODE + cadetail->CANUMBER == g_PAR_BRCH+mCANUMBER .and. ;
				   !cadetail->(eof())
		  
			  if cadetail->dtlcode == mdtlcd .and. !CADETAIL->INCLUDE     // ledit_include
				 if cadetail->principal > mPRINCIPAL
				    l_retval := .f.
				    error("Main facility(Purcamt) should not be lower than sub-limit.")
				    exit
				 elseif cadetail->credamt > mCREDAMT
				    l_retval := .f.
				    error("Main facility(Credamt) should not be lower than sub-limit.")
				    exit
			     endif
			  endif
			  
			  //if cadetail->(recno()) == mrecno
			  //   ledit_include := .t.
			  //endif
			  
		   cadetail->(dbskip())
		   enddo
		   
		endif
		cadetail->(dbgoto(mrecno))
	endif
	
endif




/***
IF !minclude
    
	if cadetail->(dbseek(g_PAR_BRCH+mCANUMBER))
	   do while cadetail->BRCODE + cadetail->CANUMBER == g_PAR_BRCH+mCANUMBER .and. ;
			   !cadetail->(eof())
	   
		  if cadetail->include
			 //if cadetail->FCLTYCODE == mFCLTYCODE
				if cadetail->purcamt > 0
				   //pre_purc := cadetail->purcamt
				   pre_purc += cadetail->purcamt
				else
				   //pre_purc := cadetail->principal
				   pre_purc += cadetail->principal
				endif
				pre_crd  += cadetail->credamt
			 //endif
		  else
             if cadetail->purcamt > 0
			    //pre_purc := cadetail->purcamt
			    pre_purc -= cadetail->purcamt
			 else
			    //pre_purc := cadetail->principal
			    pre_purc -= cadetail->principal
			 endif
			 pre_crd  -= cadetail->credamt
		  endif
	   
	   cadetail->(dbskip())
	   enddo
	   
	   cadetail->(dbgoto(mrecno))

	   //ALERT(STR(pre_purc)+' '+STR(mPRINCIPAL))
	   if round(pre_purc,2) > 0  
	      if round(pre_purc,2) < round(mPRINCIPAL,2)
		     l_retval := .f.
		     error("Sub-limit(Purcamt) should not be higher than the main line.")
	      elseif round(pre_crd,2) < round(mCREDAMT,2)
	         l_retval := .f.
		     error("Sub-limit(Credamt) should not be higher than the main line.")
	      endif  
	   elseif round(pre_purc,2) < 0  
	      l_retval := .f.
		  error("Main line is already exhausted.")
	   endif
	else
	   error("Please make a main line before making sub-limits!")
	   l_retval := .f.
	endif
ENDIF
***/

return l_retval

**************************************************************************
*   Description   input module for Cadetail.dbf ( Faculty->SETCODE == 1 )
*   Parameters    type >> 'A' = Add else Edit
*   Return Value 
static function setcode_one( mWHAT , mFCLTYCODE, lsublimit, mDTLCODE )
**************************************************************************
local mCANUMBER := Caheader->CANUMBER, mPRINCIPAL, mPAYTYPE, mGD, mRV, ;
      mTERM, mTRUERATE, mFACTOR, mAMORT, mCREDAMT, mAMENDED, mAMENDREF,;
      mRATETYPE, munit, munit2, minclude, mRECNO := recno(), mISRETURNED := .f.,;
	  mTRANTYPE
local mPAYCHOICES  := { '1 = IN ADVANCE','2 = IN ARREARS' }, mcolor := setcolor()
local mTRANCHOICES := { '1 = REVOLVING ','2 = REGULAR   ' }
local mMINSPRED, nrecno := Cadetail->(recno())
memvar getlist

if( upper( mWHAT ) == 'A', Cadetail->(dbgoto(lastrec()+1)) , mWHAT := 'R')
eval({|| mPRINCIPAL := Cadetail->PRINCIPAL, mPAYTYPE  := Cadetail->PAYTYPE ,;
         mGD        := Cadetail->GD       , mRV       := Cadetail->RV      ,;
         mTERM      := Cadetail->TERM     , mTRUERATE := Cadetail->TRUERATE,;
         mFACTOR    := Cadetail->FACTOR   , mAMORT    := Cadetail->AMORT   ,;
         mCREDAMT   := Cadetail->CREDAMT  , mAMENDED  := if(Cadetail->AMENDED==.t.,'Y','N'),;
         mAMENDREF  := Cadetail->AMENDREF , mRATETYPE := Cadetail->RATETYPE,;
         minclude   := Cadetail->INCLUDE  , munit     := Cadetail->UNIT,;
         munit2     := Cadetail->UNIT2    , mMINSPRED := Cadetail->MINSPRED,;
		 mTRANTYPE  := Cadetail->TRANTYPE ;
         } )

   fshadow  ( 4, 29, 22, 75, 2, 'w+/gr' )
   setcolor ( 'bg+/gr, w+/n,,, gr+/gr' )

   @  4, 30 say propercase( rtrim( Facility->fcltyname ) ) color 'bg+/gr'   
   @  6, 56 say if( empty( mTRANTYPE ), '', subs( mTRANCHOICES[ val( mTRANTYPE ) ], 5 ) ) color 'gr+/gr'
   @ 10, 57 say if( mPAYTYPE $ '12', if( mPAYTYPE == '1', 'IN ADVANCE', 'IN ARREARS' ), '') color 'gr+/gr'
   @ 13, 58 say 'MONTH(s)' color 'gr+/gr'
   @ 14, 62 say if( mRATETYPE $ '12', if( mRATETYPE == '1', 'FIXED', 'FLOATING' ), '') color 'gr+/gr'

   if upper( mWHAT ) == 'A'
      if (lsublimit,minclude := .f.,minclude := .t.)
   else
      mDTLCODE	:= Cadetail->DTLCODE 
   endif
   
   do while .t.
       @  5, 30 say '             Facility ' gget mFCLTYCODE picture '@R 999-99' when .f.
	   
	   @  6, 30 say '     Transaction Type ' gget mTRANTYPE  picture '@X' when eval({|| IF (mFCLTYCODE == '10301',chkwhat( mTRANCHOICES, @mTRANTYPE, 6, 56, 'Transaction Type' ),.f.)}) valid mTRANTYPE $ '12'
	   
       @  7, 30 say '      Purchase Amount ' gget mPRINCIPAL calculator picture '999,999,999.99' when eval({|| mISRETURNED := .t., .t.}) valid mPRINCIPAL > 0
       @  8, 30 say '      Items for Lease ' gget munit      picture '@!S21'
       @  9, 30 say '                      ' gget munit2     picture '@!S21'
       @ 10, 30 say '         Payment Type ' gget mPAYTYPE   picture 'X' when chkwhat( mPAYCHOICES, @mPAYTYPE,10, 57, 'Payment Type' )
       @ 11, 30 say '     Guaranty Deposit ' gget mGD        picture '99.999999%'
       @ 12, 30 say '       Residual Value ' gget mRV        picture '99.999999%'
       @ 13, 30 say '                 Term ' gget mTERM      picture '999'     valid mTERM > 0
       @ 14, 30 say '            True Rate ' gget mTRUERATE  picture '99.9999' valid mTRUERATE > 0 .and. compute_1( mPRINCIPAL, mPAYTYPE, mGD, mRV, mTRUERATE, mTERM, @mFACTOR, @mAMORT, @mCREDAMT, @mRATETYPE, 14, 62 )
	   
       @ 15, 30 say '       Minimum Spread ' gget mMINSPRED picture '99.9999' valid mMINSPRED > 0 .and. !empty( mMINSPRED )

       @ 16, 30 say 'Monthly Rental Factor ' gget mFACTOR    picture '99.9999'        when .f.
       @ 17, 30 say '       Monthly Rental ' gget mAMORT     calculator picture '999,999,999.99' when .f.
       @ 18, 30 say '        Credit Amount ' gget mCREDAMT   calculator picture '999,999,999.99' when .f.
	   @ 19, 30 say '     Include in Line? ' gget minclude   picture 'YN' when eval({||if (upper(mWHAT) == 'A',.t.,.t.)}) valid (eval({|| chk_limits(mCANUMBER,mFCLTYCODE,mPRINCIPAL,mCREDAMT,@minclude,lsublimit,mWHAT) }))
	   //@ 18, 30 say '     Include in Line? ' gget minclude   picture 'YN' when eval({||if (upper(mWHAT) == 'A',chk_include(g_par_brch,mCANUMBER,@minclude,lsublimit),.f.)}) valid (eval({|| chk_limits(mCANUMBER,mFCLTYCODE,mPRINCIPAL,mCREDAMT,minclude) }))
       //@ 18, 30 say '     Include in Line? ' gget minclude   picture 'YN' valid (eval({|| chk_limits(mCANUMBER,mFCLTYCODE,mPRINCIPAL,mCREDAMT,minclude) }))
       @ 20, 30 say '       Terms Amended? ' gget mAMENDED   picture 'YN'
       @ 21, 30 say '  Amendment Reference ' gget mAMENDREF  picture '@X'

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
	   if lastkey() == K_ENTER
		   if CONFIRM( 'Are all entries correct?')
			//alert(Cadetail->CANUMBER+' 1 '+mwhat+' X '+mDTLCODE)
			  MSGWIN(10,55,'Saving','W+/BG','R*/BG','ON')
			  if Cadetail->( NETLOCK( mWHAT, 0 ) )
				 Cadetail->CANUMBER  := mCANUMBER ; Cadetail->FCLTYCODE := mFCLTYCODE
				 Cadetail->PRINCIPAL := mPRINCIPAL; Cadetail->PAYTYPE   := mPAYTYPE  
				 Cadetail->GD       := mGD        ; Cadetail->RV        := mRV       
				 Cadetail->TERM     := mTERM      ; Cadetail->TERMUNIT  := '2'       
				 Cadetail->TRUERATE := mTRUERATE  ; Cadetail->FACTOR    := mFACTOR   
				 Cadetail->AMORT    := mAMORT     ; Cadetail->CREDAMT   := mCREDAMT  
				 Cadetail->AMENDED  := if(mAMENDED=='Y',.t.,.f.)
				 Cadetail->AMENDREF := mAMENDREF ; Cadetail->RATETYPE  := mRATETYPE 
				 Cadetail->UNIT     := mUNIT     ; Cadetail->UNIT2     := mUNIT2    
				 Cadetail->INCLUDE  := minclude  ; Cadetail->MINSPRED  := mMINSPRED
				 Cadetail->brcode   := Caheader->brcode
				 Cadetail->TRANTYPE := IF (mTRANTYPE == '2',' ','1')
				 if upper(mWHAT) == 'A'
					Cadetail->DTLCODE  := right ( '0000'+alltrim(str(mDTLCODE)),4 )
				 endif
				 Cadetail->( dbunlock() )

				 mRECNO := recno()
			  endif
			  MSGWIN(10,55,'Saving','W+/BG','R*/BG','OFF')
			  EXIT
		   endif
	   endif
   enddo
   Cadetail->( dbcommit() )

	   
   go mRECNO; setcolor( mcolor )
return nil

**************************************************************************
*   Description   input module for Cadetail.dbf ( Faculty->SETCODE == 2 )
*   Parameters    type >> 'A' = Add else Edit
*   Return Value 
static function setcode_two( mWHAT , mFCLTYCODE, lsublimit, mDTLCODE )
**************************************************************************
local mCANUMBER := Caheader->CANUMBER, mPRINCIPAL, mPAYTYPE, mTERM, mTRUERATE,;
      mFACTOR, mRATETYPE, mADDON, mAMORT, mCREDAMT, mAMENDED, mAMENDREF,;
      munit, munit2, minclude, mRECNO := recno(), mISRETURNED := .f.,;
	  mTRANTYPE
local mINCENTIVE,mWTAX,mNERATE,mMINSPRED
local mPAYCHOICES := { '1 = IN ADVANCE','2 = IN ARREARS' }, mcolor := setcolor()
local mTRANCHOICES := { '1 = REVOLVING ','2 = REGULAR   ' }
memvar getlist

if ( upper( mWHAT ) == 'A', Cadetail->(dbgoto(lastrec()+1)) , mWHAT := 'R')
eval({|| mPRINCIPAL := Cadetail->PRINCIPAL, mPAYTYPE  := Cadetail->PAYTYPE ,;
         mTERM      := Cadetail->TERM     , mTRUERATE := Cadetail->TRUERATE,;
         mFACTOR    := Cadetail->FACTOR   , mAMORT    := Cadetail->AMORT   ,;
         mADDON     := Cadetail->ADDON    , mCREDAMT  := Cadetail->CREDAMT ,;
         mAMENDED   := if(Cadetail->AMENDED==.t.,'Y','N'),;
         mAMENDREF  := Cadetail->AMENDREF , mRATETYPE := Cadetail->RATETYPE,;
         munit      := Cadetail->UNIT     , munit2    := Cadetail->UNIT2   , minclude := Cadetail->INCLUDE,;
		 mINCENTIVE := Cadetail->INCENTIVE, mWTAX     := Cadetail->WTAX    , mNERATE := Cadetail->NERATE,  ;
		 mMINSPRED  := Cadetail->MINSPRED , mTRANTYPE := Cadetail->TRANTYPE  } )


   if upper( mWHAT ) == 'A'
      if (lsublimit,minclude := .f.,minclude := .t.)
   else
      mDTLCODE	:= Cadetail->DTLCODE 
   endif
   
   fshadow( 4, 28, 23, 75, 2, 'w+/gr' )
   setcolor( 'bg+/gr, w+/n,,, gr+/gr' )    
   @  4, 29 say propercase( rtrim( Facility->fcltyname ) ) color 'bg+/gr'
   @  6, 56 say if( empty( mTRANTYPE ), '', subs( mTRANCHOICES[ val( mTRANTYPE ) ], 5 ) ) color 'gr+/gr'
   @ 12, 54 say if( mPAYTYPE $ '12', if( mPAYTYPE == '1', 'IN ADVANCE', 'IN ARREARS' ), '' ) color 'gr+/gr'
   @ 13, 56 say 'MONTH(s)' color 'gr+/gr'
   @ 14, 60 say if( mRATETYPE $ '12', if( mRATETYPE == '1', 'FIXED', 'FLOATING' ), '' ) color 'gr+/gr'
   do while .t.
      @  5, 29 say '            Facility ' gget mFCLTYCODE picture '@R 999-99' when .f.
      @  6, 29 say '    Transaction Type ' gget mTRANTYPE  picture '@X' when eval({|| IF (mFCLTYCODE == '10401',chkwhat( mTRANCHOICES, @mTRANTYPE, 6, 56, 'Transaction Type' ),.f.)}) valid mTRANTYPE $ '12'
      @  7, 29 say '        Net Proceeds ' gget mPRINCIPAL calculator picture '999,999,999.99' when eval({|| mISRETURNED := .t., .t.})  valid mPRINCIPAL > 0
      @  8, 29 say '         Collaterals ' gget munit      picture '@!S23'
      @  9, 29 say '                     ' gget mUNIT2     picture '@!S23'
	  
	  @ 10, 29 say '         D.I. / S.I. ' gget mINCENTIVE calculator   picture '999,999,999.99' 
	  @ 11, 29 say '     Withholding Tax ' gget mWTAX      calculator   picture '999,999,999.99' 
	    
      @ 12, 29 say '        Payment Type ' gget mPAYTYPE   picture 'X' when chkwhat( mPAYCHOICES, @mPAYTYPE, 12, 54, 'Payment Type' )
      @ 13, 29 say '                Term ' gget mTERM      picture '999' valid mTERM > 0
      @ 14, 29 say 'Gross Effective Rate ' gget mTRUERATE  picture '99.9999' valid mTRUERATE > 0 .and. compute_2(mPRINCIPAL,mPAYTYPE,mTRUERATE,mTERM,@mADDON,@mAMORT,@mCREDAMT,@mRATETYPE, 14, 60)
	  
      @ 15, 29 say '  Net Effective Rate ' gget mNERATE   picture '99.9999%' when eval({ || mNERATE := NETRATE( mPRINCIPAL+mINCENTIVE+mWTAX, mAMORT, mTERM, mPAYTYPE ),.f.})
	  
      @ 16, 29 say '      Minimum Spread ' gget mMINSPRED picture '99.9999' valid mMINSPRED > 0 .and. !empty( mMINSPRED )

      @ 17, 29 say '         Add-On Rate ' gget mADDON     picture '99.9999'        when .f.
      @ 18, 29 say 'Monthly Amortization ' gget mAMORT     calculator   picture '999,999,999.99' when .f.
      @ 19, 29 say '       Credit Amount ' gget mCREDAMT   calculator   picture '999,999,999.99' when .f.
      @ 20, 29 say '    Include in Line? ' gget minclude   picture 'YN' when eval({||if (upper(mWHAT) == 'A',.t.,.t.)}) valid (eval({|| chk_limits(mCANUMBER,mFCLTYCODE,mPRINCIPAL,mCREDAMT,@minclude,lsublimit,mWHAT) }))
      @ 21, 29 say '      Terms Amended? ' gget mAMENDED   picture 'YN'
      @ 22, 29 say ' Amendment Reference ' gget mAMENDREF  picture '@X'
	  
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
	   if lastkey() == K_ENTER
		   if CONFIRM( 'Are all entries correct?' )
		   //alert(Cadetail->CANUMBER+' 2 '+mwhat+' X '+mDTLCODE)
			  if Cadetail->( netlock( mwhat, 0 ) )
				 Cadetail->CANUMBER  := mCANUMBER           ; Cadetail->FCLTYCODE := mFCLTYCODE
				 Cadetail->PRINCIPAL := mPRINCIPAL          ; Cadetail->PAYTYPE   := mPAYTYPE  
				 Cadetail->TERM      := mTERM               ; Cadetail->TERMUNIT  := '2'       
				 Cadetail->TRUERATE  := mTRUERATE           ; Cadetail->AMORT     := mAMORT    
				 Cadetail->ADDON     := mADDON              ; Cadetail->CREDAMT   := mCREDAMT  
				 Cadetail->AMENDED   := if(mAMENDED=='Y',.t.,.f.)
				 Cadetail->AMENDREF  := mAMENDREF           ; Cadetail->RATETYPE  := mRATETYPE 
				 Cadetail->UNIT      := munit               ; Cadetail->UNIT2     := munit2    
				 Cadetail->INCLUDE   := minclude  
				 Cadetail->INCENTIVE := mINCENTIVE          ; Cadetail->WTAX      := mWTAX     
				 Cadetail->NERATE    := mNERATE             ; Cadetail->MINSPRED  := mMINSPRED 
				 Cadetail->brcode    := Caheader->brcode    ; Cadetail->TRANTYPE  := IF (mTRANTYPE == '2',' ','1')
				 if upper(mWHAT) == 'A'
					Cadetail->DTLCODE  := right ( '0000'+alltrim(str(mDTLCODE)),4 )
				 endif						  
				 Cadetail->( dbunlock() )

				  mRECNO := recno()
				  exit
			   endif
			endif
		endif
   enddo
   Cadetail->( dbcommit() )
   go mRECNO; setcolor( mcolor )
return nil

**************************************************************************
*   Description   input module for Cadetail.dbf ( Faculty->SETCODE == 3 )
*   Parameters    type >> 'A' = Add else Edit
*   Return Value 
static function setcode_three( mWHAT, mFCLTYCODE, lsublimit, mDTLCODE )
**************************************************************************
local mCANUMBER := Caheader->CANUMBER, mPRINCIPAL, mPAYTYPE, mTERM, mTRUERATE,;
      mFACTOR, mRATETYPE, mDLRCODE, mSALESREP, mPURCAMT, mDOWNPAY, mINCENTIVE,;
      mAMORT, mCREDAMT, mAMENDED, mAMENDREF, mNERATE, minclude, munit, munit2, mRECNO := recno(), mISRETURNED  := .f.,;
      mAppval, mWTAX
local mPAYCHOICES  := { '1 = IN ADVANCE','2 = IN ARREARS' }, mRATECHOICES := { '1 = FIXED     ','2 = FLOATING  ' }
local o_down := mdownpay
local mcolor := setcolor()
local npercent := 0
memvar getlist


if( upper( mWHAT ) == 'A', Cadetail->(dbgoto(lastrec()+1)) , mWHAT := 'R')
eval({|| mDLRCODE   := Cadetail->DLRCODE  , mSALESREP  := Cadetail->SALESREP ,;
         mPURCAMT   := Cadetail->PURCAMT  , mDOWNPAY   := Cadetail->DOWNPAY  ,;
         mINCENTIVE := Cadetail->INCENTIVE, mPRINCIPAL := Cadetail->PRINCIPAL,;
         mPAYTYPE   := Cadetail->PAYTYPE  , mTERM      := Cadetail->TERM     ,;
         mTRUERATE  := Cadetail->TRUERATE , mNERATE    := Cadetail->NERATE   ,;
         mAMORT     := Cadetail->AMORT    , mCREDAMT   := Cadetail->CREDAMT  ,;
         mAMENDED   := if(Cadetail->AMENDED==.t.,'Y','N'),;
         mAMENDREF  := Cadetail->AMENDREF , mRATETYPE  := Cadetail->RATETYPE ,;
         minclude   := Cadetail->INCLUDE  , munit      := Cadetail->UNIT     ,;
         mAppval    := Cadetail->APPVAL   , munit2     := Cadetail->UNIT2    ,;
		 mWTAX      := Cadetail->WTAX      } )

   if upper( mWHAT ) == 'A'
      if (lsublimit,minclude := .f.,minclude := .t.)
   else
      mDTLCODE	:= Cadetail->DTLCODE 
   endif
   
   fshadow( 3, 28, 23, 77, 2, 'w+/gr' )
   setcolor( 'bg+/gr, w+/n,,, gr+/gr' )    
   @  3, 29 say propercase( rtrim( Facility->fcltyname ) ) color 'bg+/gr'
   @  7, 57 say dispDLRNAME( mDLRCODE ) color 'gr+/gr'
   @ 14, 46 say if( mPAYTYPE $ '12', if( mPAYTYPE == '1', 'IN ADVANCE', 'IN ARREARS' ),'') color 'gr+/gr'
   @ 14, 69 say 'MONTH(s)' color 'gr+/gr'
   @ 15, 60 say if( mRATETYPE $ '12', if( mRATETYPE == '1', 'FIXED', 'FLOATING' ),'') color 'gr+/gr'

   do while .t.

      @  4, 29 say '            Facility ' get mFCLTYCODE  picture '@R 999-99' when .f.
      @  5, 29 say '                Unit ' get mUNIT       picture '@!S23'
      @  6, 29 say '                     ' get mUNIT2      picture '@!S23'
      @  7, 29 say '              Dealer ' get mDLRCODE    picture '@X' when chkdlrcode ( @mDLRCODE,8) valid !empty ( mDLRCODE )
      @  8, 29 say 'Sales Representative ' get mSALESREP   picture '@XS20'
      @  9, 29 say '     Appraised Value ' gget mappval    calculator picture '999,999,999.99' valid mappval > 0
      @ 10, 29 say '     Purchase Amount ' gget mPURCAMT   calculator picture '999,999,999.99' valid mPURCAMT > 0
      @ 11, 29 say '        Down Payment ' ;
               gget mDOWNPAY                ;
               calculator                   ;
               picture '999,999,999.99'
//      @ 12, 29 say "  Dealer's Incentive " gget mINCENTIVE calculator picture '999,999,999.99'
      @ 12, 29 say "         D.I. / S.I. " gget mINCENTIVE  calculator picture '999,999,999.99'  ;
	                                             valid eval (  { ||  ;
                                                             if (  mpurcamt < mappval ,;
                                                                   mPrincipal := mPurcamt - mDownpay,;
                                                                   mPrincipal := mappval  - mDownpay;
                                                                ),;
                                                             .t. ;
                                                        };
                                                      )
      @ 13, 29 say "     Withholding Tax " gget mWTAX  calculator picture '999,999,999.99'
	  	  
      @ 14, 29 say '        Net Proceeds ' gget mPRINCIPAL calculator picture '999,999,999.99' when eval({|| mISRETURNED := .t.,.f.})  valid mPRINCIPAL > 0
      @ 15, 29 say 'Payment Type ' get mPAYTYPE   picture 'X' when chkwhat( mPAYCHOICES, @mPAYTYPE, 15, 46, 'Payment Type' )
      @ 15, 58 say 'Term ' get mTERM      picture '999' valid mTERM > 0
      @ 16, 29 say 'Gross Effective Rate ' get mTRUERATE  picture '99.9999' valid mTRUERATE > 0 .and. compute_3(mPRincipal,mPAYTYPE,mTRUERATE,mTERM,@mNERATE,@mAMORT,@mCREDAMT,@mRATETYPE, 16, 60 )
      @ 17, 29 say '  Net Effective Rate ' get mNERATE    picture '99.9999'  when eval({ || mNERATE := NETRATE( mPRINCIPAL+mINCENTIVE+mWTAX, mAMORT, mTERM, mPAYTYPE ),.f.})
      @ 18, 29 say 'Monthly Amortization ' get mAMORT     picture '999,999,999.99' when .f.
	  @ 19, 29 say '       Credit Amount ' get mCREDAMT   picture '999,999,999.99' when .f.
	  @ 20, 29 say '    Include in Line? ' gget minclude   picture 'YN' when eval({||if (upper(mWHAT) == 'A',.t.,.t.)}) valid (eval({|| chk_limits(mCANUMBER,mFCLTYCODE,mPRINCIPAL,mCREDAMT,@minclude,lsublimit,mWHAT) }))
	  //@ 20, 29 say '     Include in Line? ' gget minclude   picture 'YN' when eval({||if (upper(mWHAT) == 'A',chk_include(g_par_brch,mCANUMBER,@minclude,lsublimit),.f.)}) valid (eval({|| chk_limits(mCANUMBER,mFCLTYCODE,mPRINCIPAL,mCREDAMT,minclude) }))
      //@ 20, 29 say '    Include in Line? ' get minclude   picture 'YN' valid (eval({|| chk_limits(mCANUMBER,mFCLTYCODE,mPRINCIPAL,mCREDAMT,minclude) }))
      @ 21, 29 say '      Terms Amended? ' get mAMENDED   picture '!' valid mAMENDED $ 'YN'
      @ 22, 29 say ' Amendment Reference ' get mAMENDREF  picture '@X'

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
	  
	  if lastkey() == K_ENTER
		  if CONFIRM( 'Are all entries correct?' )
		//alert(Cadetail->CANUMBER+' 3 '+mwhat+' X '+mDTLCODE)
			 if Cadetail->( NETLOCK( mWHAT, 0 ) )
				Cadetail->CANUMBER  := mCANUMBER ; Cadetail->FCLTYCODE := mFCLTYCODE
				Cadetail->DLRCODE   := mDLRCODE  ; Cadetail->SALESREP  := mSALESREP 
				Cadetail->PURCAMT   := mPURCAMT  ; Cadetail->DOWNPAY   := mDOWNPAY  
				Cadetail->INCENTIVE := mINCENTIVE; Cadetail->PRINCIPAL := mPRINCIPAL
				Cadetail->PAYTYPE   := mPAYTYPE  ; Cadetail->TERM      := mTERM     
				Cadetail->TERMUNIT  := '2'       ; Cadetail->TRUERATE  := mTRUERATE 
				Cadetail->NERATE    := mNERATE   ; Cadetail->AMORT     := mAMORT    
				Cadetail->CREDAMT   := mCREDAMT  ; Cadetail->AMENDED   := if(mAMENDED=='Y',.t.,.f.)
				Cadetail->AMENDREF  := mAMENDREF ; Cadetail->RATETYPE  := mRATETYPE 
				Cadetail->INCLUDE   := minclude  ; Cadetail->UNIT      := mUNIT     
				Cadetail->Appval    := mAppval   ; Cadetail->brcode    := Caheader->brcode  
				Cadetail->UNIT2     := mUNIT2    ; Cadetail->WTAX      := mWTAX  
				
				if upper(mWHAT) == 'A'
				   Cadetail->DTLCODE  := right ( '0000'+alltrim(str(mDTLCODE)),4 )
				endif
				 
				Cadetail->( dbunlock() )

				mRECNO := recno()
				exit
			 endif

		  endif
	  endif

   enddo
   Cadetail->( dbcommit() )
   
   go mRECNO; setcolor( mcolor )
return nil

**************************************************************************
*   Description   input module for Cadetail.dbf ( Facility->SETCODE == 5 )
*   Parameters    type >> 'A' = Add else Edit
*   Return Value 
function setcode_five( mWHAT, mFCLTYCODE, lsublimit, mDTLCODE ) 
*********************************************************************************
local mPRINCIPAL, mTERM, mTRUERATE, mAMORT, mPAYFREQ, mCOLATRL, mMINSPRED
local mCREDAMT, mAMENDED, mAMENDREF, mRATETYPE, mINCLUDE, mRECOURSE, mTERMUNIT
local mTRANTYPE, mNOTFCTN, mOBLIGOR, mFORMULA, mCOLEXION, mPAYTYPE
local mminspread
local mCANUMBER := Caheader->CANUMBER, mRECNO := recno(), mISRETURNED  := .f.
local mFORMCHOICES := { '1 = SIMPLE INTEREST ', '2 = TRUE DISCOUNTING' }
local mFREQCHOICES := { '1 = MONTHLY    ', '2 = BI-MONTHLY ', '3 = QUARTERLY  ',;
                      '4 = SEMI-ANNUAL', '5 = ANNUAL     ', '6 = LUMPSUM    ',;
                      '7 = IRREGULAR  ' }
local mNOTCHOICES  := { '1 = WITH      ','2 = WITHOUT   ' }
local mRATECHOICES := { '1 = FIXED     ','2 = NEGOTIABLE' }
local mTRANCHOICES := { '1 = REVOLVING ','2 = SPECIAL   ' }
local mCOLCHOICES  := { '1 = OURS      ','2 = THEIRS    ' }
local mRECHOICES   := { '1 = WITH      ','2 = WITHOUT   ' }
local mTERMCHOICES := { '1 = DAY(s)    ','2 = MONTH(s)  ' }
local getlist := {}, mcolor := setcolor(), mSCR := savescreen ( ,,, )
   
if( upper( mWHAT ) == 'A', Cadetail->(dbgoto(lastrec()+1)) , mWHAT := 'R')
eval( { || mPRINCIPAL := Cadetail->PRINCIPAL, mTERM := Cadetail->TERM,;
           mTRUERATE := Cadetail->TRUERATE, mAMORT := Cadetail->AMORT,;  
           mAMENDED := Cadetail->AMENDED,;
           mTERMUNIT := Cadetail->TERMUNIT,;
           mAMENDREF := Cadetail->AMENDREF, mRATETYPE := Cadetail->RATETYPE,;
           mINCLUDE := Cadetail->INCLUDE, mRECOURSE := Cadetail->RECOURSE,;
           mTRANTYPE := Cadetail->TRANTYPE, mNOTFCTN := Cadetail->NOTFCTN,;
           mOBLIGOR := Cadetail->OBLIGOR, mCOLEXION := Cadetail->COLEXION,;
           mCREDAMT := Cadetail->CREDAMT, mCOLATRL := Cadetail->COLATRL,;
           mPAYFREQ := Cadetail->PAYFREQ, mFORMULA := Cadetail->FORMULA,;
           mTERMUNIT := Cadetail->TERMUNIT, mMINSPRED := Cadetail->MINSPRED;
           } )
		   
   if upper( mWHAT ) == 'A'
      if (lsublimit,minclude := .f.,minclude := .t.)
   else
      mDTLCODE	:= Cadetail->DTLCODE 
   endif
   
   fshadow( 3, 29, 23, 75, 2, 'w+/gr' )
   setcolor( 'bg+/gr, w+/n,,, gr+/gr' )    
   @  3, 30 say propercase( rtrim( Facility->fcltyname ) ) color 'bg+/gr'      
   @  5, 54 say if( empty( mTRANTYPE ), '', subs( mTRANCHOICES[ val( mTRANTYPE ) ], 5 ) ) color 'gr+/gr'
   @  7, 56 say if( empty( mTERMUNIT ), '', subs( mTERMCHOICES[ val( mTERMUNIT ) ], 5 ) ) color 'gr+/gr'
   @  8, 54 say if( empty( mRATETYPE ), '', subs( mRATECHOICES[ val( mRATETYPE ) ], 5 ) ) color 'gr+/gr'
   @ 11, 54 say if( empty( mFORMULA  ), '', subs( mFORMCHOICES[ val( mFORMULA  ) ], 5 ) ) color 'gr+/gr'
   @ 12, 54 say if( empty( mPAYFREQ  ), '', subs( mFREQCHOICES[ val( mPAYFREQ  ) ], 5 ) ) color 'gr+/gr'
   @ 15, 54 say if( empty( mNOTFCTN  ), '', subs( mNOTCHOICES [ val( mNOTFCTN  ) ], 5 ) ) color 'gr+/gr'
   @ 16, 54 say if( empty( mCOLEXION ), '', subs( mCOLCHOICES [ val( mCOLEXION ) ], 5 ) ) color 'gr+/gr'
   @ 17, 54 say if( empty( mRECOURSE ), '', subs( mRECHOICES  [ val( mRECOURSE ) ], 5 ) ) color 'gr+/gr'
   mPAYTYPE := '2'
   do while .t.
      @  4, 30 say '           Facility ' gget mFCLTYCODE picture '@R 999-99' when .f.
      @  5, 30 say '   Transaction Type ' gget mTRANTYPE  picture '@X' when chkwhat( mTRANCHOICES, @mTRANTYPE, 5, 54, 'Transaction Type' ) valid mTRANTYPE $ '12'
      @  6, 30 say '       Net Proceeds ' gget mPRINCIPAL calculator picture '999,999,999.99'  valid mPRINCIPAL > 0
      @  7, 30 say '               Term ' gget mTERM      picture '999' valid mTERM > 0 .and. eval( { || chkwhat( mTERMCHOICES, @mTERMUNIT, 7, 56, 'Term Unit' ), .t. } )
      @  8, 30 say '          Rate Type ' gget mRATETYPE  picture '@X' when chkwhat( mRATECHOICES, @mRATETYPE, 8, 54, 'Rate Type' )
      @  9, 30 say '      Interest Rate ' gget mTRUERATE  picture '99.9999' valid mTRUERATE > 0 .and. !empty( mtruerate )
	  
	  @ 10, 30 say '     Minimum Spread ' gget mMINSPRED picture '99.9999' valid mMINSPRED > 0 .and. !empty( mMINSPRED )
	  
	  
      @ 11, 30 say '            Formula ' gget mFORMULA   picture '@X' when if( mRATETYPE != '1', .t., eval( { || mFORMULA := ' ', setpos( 11, 54 ), qqout( padr( '', 16 ) ), .f. } ) ) .and. chkwhat( mFORMCHOICES, @mFORMULA, 11, 54, 'Formula' )
      @ 12, 30 say '  Payment Frequency ' gget mPAYFREQ   picture '@X' when if( mRATETYPE != '1', .t.,.t.) .and.;
                                                                          !chkwhat( mFREQCHOICES, @mPAYFREQ, 12, 54, 'Payment Frequency' );
                                                                          valid chk_pay_freq( mTERM, mTERMUNIT, mPAYFREQ, mFREQCHOICES,12 ) .and.;
                                                                          formulation( mFORMULA, mTERMUNIT,mPRINCIPAL, mTRUERATE, mTERM, mPAYFREQ, @mCREDAMT, @mAMORT,mRATETYPE )
                                                                          //eval( { || mPAYFREQ := ' ', mAMORT := 0, mCREDAMT := Cadetail->principal, setpos( 12, 54 ), qqout( padr( '', 16 ) ), .t. } ) )
      @ 13, 30 say '       Amortization ' gget mAMORT     picture '999,999,999.99' when .f.
      @ 14, 30 say '      Credit Amount ' gget mCREDAMT   picture '999,999,999.99' when .f.
      @ 15, 30 say '       Notification ' gget mNOTFCTN   picture '@X' when chkwhat( mNOTCHOICES, @mNOTFCTN, 15, 54, 'Notification' )
      @ 16, 30 say '         Collection ' gget mCOLEXION  picture '@X' when chkwhat( mCOLCHOICES, @mCOLEXION, 16, 54, 'Collection' )
      @ 17, 30 say '           Recourse ' gget mRECOURSE  picture '@X' when chkwhat( mRECHOICES , @mRECOURSE, 17, 54, 'Recourse' )
      @ 18, 30 say '            Obligor ' gget mOBLIGOR   picture '@XS23' valid !empty ( mOBLIGOR )
      @ 19, 30 say '         Collateral ' gget mCOLATRL   picture '@XS23' valid !empty ( mCOLATRL )
	  @ 20, 30 say '     Include in Line? ' gget minclude   picture 'Y' when eval({||if (upper(mWHAT) == 'A',.t.,.t.)}) valid (eval({|| chk_limits(mCANUMBER,mFCLTYCODE,mPRINCIPAL,mCREDAMT,@minclude,lsublimit,mWHAT) }))
      //@ 20, 30 say '   Include in Line? ' gget mINCLUDE   picture 'Y' valid (eval({|| chk_limits(mCANUMBER,mFCLTYCODE,mPRINCIPAL,mCREDAMT,minclude) }))
      @ 21, 30 say '     Terms Amended? ' gget mAMENDED   picture 'Y'
      @ 22, 30 say 'Amendment Reference ' gget mAMENDREF  picture '@X'
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
	   if lastkey() == K_ENTER
		   if confirm( 'Are all entries correct?' )
			  if Cadetail->( NETLOCK( mWHAT, 0 ) )
				 Cadetail->CANUMBER  := mCANUMBER ; Cadetail->FCLTYCODE := mFCLTYCODE
				 Cadetail->PRINCIPAL := mPRINCIPAL; Cadetail->TERM      := mTERM     
				 Cadetail->TERMUNIT  := mTERMUNIT ; Cadetail->PAYTYPE   := mPAYTYPE
				 Cadetail->TRUERATE  := mTRUERATE ; Cadetail->AMORT     := mAMORT    
				 Cadetail->AMENDED   := mAMENDED  ; Cadetail->AMENDREF  := mAMENDREF 
				 Cadetail->RATETYPE  := mRATETYPE ; Cadetail->INCLUDE   := mINCLUDE  
				 Cadetail->RECOURSE  := mRECOURSE ; Cadetail->TRANTYPE  := mTRANTYPE
				 Cadetail->NOTFCTN   := mNOTFCTN  ; Cadetail->OBLIGOR   := mOBLIGOR  
				 Cadetail->COLEXION  := mCOLEXION ; Cadetail->CREDAMT   := mCREDAMT  
				 Cadetail->COLATRL   := mCOLATRL  ; Cadetail->PAYFREQ   := mPAYFREQ  
				 Cadetail->FORMULA   := mFORMULA  ; Cadetail->MINSPRED  := mMINSPRED 
				 Cadetail->brcode    := Caheader->brcode 
				 
				 if upper(mWHAT) == 'A'
					Cadetail->DTLCODE  := right ( '0000'+alltrim(str(mDTLCODE)),4 )
				 endif
				 
				 Cadetail->( dbunlock() )

				 
				 mRECNO := recno()
				 exit
			  endif
		   endif
	  endif
  enddo
  Cadetail->( dbcommit() )
  go mRECNO; setcolor( mcolor )
  return( nil )
  
********************************************************************
*  
static function chk_include(g_par_brch,mCANUMBER,minclude,lsublimit)
********************************************************************
local lretval := .t.

if lsublimit
   minclude := .f.
   lretval := .f.  
else
   if cadetail->(dbseek(g_par_brch+mCANUMBER))
      minclude := .t.
      lretval := .f.
   endif
endif

Return lretval

***********************************************************
*   Description   checks for the validity of FACILITY CODE
*   Parameters    FACILITY CODE
*   Return Value  .t. = found() else .f.
static function chk_fcltycode( mcanumber, mfcltycode )
******************************************************
   local mRETVAL := .t.
   local mDBF := select(), mNTX := indexord(), mRECNO := recno()
   if !empty( mFCLTYCODE )
      if !Facility->( dbseek ( mFCLTYCODE ) )
         ERROR( 'No such Facility Code!' ) ; mRETVAL := .f.
      endif
      if mRETVAL
         if Cadetail->( dbseek ( mCANUMBER+mFCLTYCODE ) )
            Cadetail->( dbeval ({|| if(Cadetail->FCLTYCODE == mfcltycode,mretval := .f.,nil )},,;
                                {|| !Cadetail->(eof()) .and. Cadetail->CANUMBER==mCANUMBER}))
            if !mretval
               error('Duplicate Facility Code!')
            endif
         endif
      endif
   endif
   select( mDBF ) ; set order to ( mNTX ) ; go ( mRECNO )
   return mRETVAL

**************************************************
*   Description   gets SETCODE from FACULTY.DBF
*   Parameters    FACILITY CODE
*   Return Value  .t. = found() else .f.
function get_setcode( mFCLTYCODE )
*****************************************
   local mRETVAL := .t.
   if !Facility->( dbseek ( mFCLTYCODE ) )
      ERROR( 'No such Facility Code!') ; mRETVAL := .f.
   endif
return mRETVAL

************************************
*
*
static function FSEARCH(cbrcode)
************************************
   local mRECNO := Caheader->( recno() )
   local mntx   := Caheader->( indexord() )
   local mSCR   := savescreen ( ,,, ), mcolor := setcolor()
   local mCLNTCODE := space( len(Caheader->CLNTCODE) )
   local mar, mposition := 1, mlog := {}, mRETVAL := .t.
   local nrecno := 0
   local cfullname := space ( len( Client->fullname ) )
   LOCAL cKEY
   memvar GETLIST

   &&nrecno := _getclwin ( mclntcode,2,client->(indexord()) )            // abb 10.18.2004 )   // client code + indexord
   nRECNO := _GETCLWIN ( mCLNTCODE,1,CLIENT->(INDEXORD()) )

   IF nRECNO = 0 .AND. LASTKEY() == K_ENTER

      center     ( 24,'w+/n', '® Search Record ¯' )
      __lb_lkup  ( 'CLIENT',1,2,@mCLNTCODE,03,45,01,08,12-7,21,75,'W/GR+,W/N,,,W/GR+','@XS40','999','@R 99-99999',,cbrcode,'NAME',cfullname,' Client name','Branch','Code' )
      center     ( 24, 'w+/n', '                 ' )

      IF LASTKEY() == K_ENTER
         nRECNO := CLIENT->(RECNO())
      ENDIF
   ENDIF

   if lastkey() != K_ESC      &&.and. nrecno > 0

      Client->  ( dbgoto(nrecno) )

      mclntcode := CLIENT->BRCODE+Client->clntcode
      cfullname := alltrim(Client->fullname)

      *center     ( 24,'w+/n', '® Search Record ¯' )
      *__lb_lkup  ( 'CLIENT',1,2,@mCLNTCODE,03,45,01,08,12-7,21,75,'W/GR+,W/N,,,W/GR+','@XS40','999','@R 99-99999',,cbrcode,'NAME',cfullname' Client name','Branch','Code' )
      *center     ( 24, 'w+/n', '                 ' )

      if lastkey() == K_ENTER .and. nrecno > 0 .AND. VALBRCODE( LEFT(mCLNTCODE,3), g_USER_ID)

         Caheader->(dbsetorder(3))   // brcode+clntcode

         if Caheader->( dbseek ( mclntcode) )      && RED 112404 REMOVED 'Client->brcode+

            mar := { '  Client N§  ' + tran( mCLNTCODE, '@R 999-99-99999' )    ,;
                     'Client Name  ' + left( dispclntname( mCLNTCODE, 40 ),15 ),;
                     repl( 'Ä', 43 ), ;
                     ' Branch Name   CA Number   Action Taken', ;
                     repl( 'Ä',43 ) ;
                   }

            Caheader->( dbeval( {|| aadd( mar,Caheader->brcode;
                                    +' '+                     ;
                                    padr(_get_branch(Caheader->brcode),10)+;
                                    ' '+;
                                    CAHEADER->BRCODE+'-'+Caheader->CANUMBER+;
                                    space(3)+;              && RED 112404 REPLACED 7 WITH 3
                                    alltrim(upper(dispactaken(Caheader->ACTAKEN))) ) },,;
                               {|| Caheader->brcode +Caheader->CLNTCODE == mCLNTCODE ;
                                   .AND. !Caheader->(eof()) }) )

            if len(mar) > 1
               mlog := aclone( mar )
               aeval ( mlog, { | l, c | mlog[ c ] := if( c <= 5, .f., .t. ), c } )
               mposition := val( gen_achoice( mar, 6, 'Search', mlog ) )
            endif

            if mposition > 0 .and. lastkey() != K_ESC
               Caheader->(dbsetorder(1))  // BRCODE + OTNUMBER
               cKEY := SUBSTR(LTRIM(MAR[mPOSITION]),16,03) + substr(ltrim(mar[mposition]),20,05)

               if Caheader-> ( dbseek ( cKEY ) )
//
//                                 left(ltrim(mar[mposition]),5) ) )
//
                   mrecno  := Caheader->(recno())
                   mretval := .t.

               endif

            endif
         else
            error ( 'No existing CA on file!' )
            mretval := .f.
//         __keyboard ( chr( K_INS ) )
         endif

      endif

   endif

   setcolor    ( mcolor )
   restscreen  ( ,,,, mSCR )
   Caheader->  ( dbsetorder ( mntx ) )
   Caheader->  ( dbgoto ( mRECNO ) )

return mRETVAL

***************************************************************************
*   Description   seeks record from CAHEADER.DBF using CANUMBER as the key
*   Parameters    type >> 'A' = Add else Edit
*   Return Value  nil
static function search_head( cbrcode,mCANUMBER )
************************************************

/*************************
local mRECNO := Caheader->( recno() )
local mntx   := Caheader->( indexord() )
local mSCR   := savescreen ( ,,, ), mcolor := setcolor()
local mclntcode := space( len(CAHEADER->BRCODE+Caheader->CLNTCODE) ) && RED 112404 ADDED 'CAHEADER->BRCODE+
local mar, mposition := 1, mlog := {}
LOCAL cKEY, SCANUMBER := SPACE(8)
memvar getlist

/* center( 24, 'w+/n', '® Search Record ¯' )
   lb_lkup('Client',1,2,@mclntcode,3,1,8,11,21,74,'W/GR+,W/N,,,W/GR+')
   center( 24, 'w+/n', '                  ' )

   if lastkey() == K_ENTER
      mCLNTCODE := CLIENT->BRCODE+mCLNTCODE
      Caheader->(dbsetorder(3))
      if Caheader->( dbseek(mclntcode) )
         mar := { '  Client N§  ' + tran( mclntcode, '@R 999-99-99999' ),;     && RED 112404 ADDED '999-
                  'Client Name  ' + left( dispclntname( mclntcode, 40 ),15 ),;     && RED 112404 REMOVED 'CLIENT->BRCODE
                  repl( 'Ä', 29 ),;
                  ' CA N§       Action Taken',;
                  repl( 'Ä',29 ) }
         Caheader->( dbeval({|| aadd( mar,' '+CAHEADER->BRCODE+'-'+Caheader->CANUMBER+;
                                          space(3)+;     && RED REPLACED 7 WITH 3
                                          alltrim(upper(dispactaken(Caheader->ACTAKEN))) ) },,;
                            {|| CAHEADER->BRCODE+Caheader->CLNTCODE==mclntcode .and. ;
                                !Caheader->(eof()) }) )
         if len(mar) > 1
            mlog := aclone( mar )         
            aeval( mlog, { | l, c | mlog[ c ] := if( c <= 5, .f., .t. ), c } ) 
            mposition := val( gen_achoice( mar, 6, 'Search', mlog ) )
         endif

         if mposition > 0 .and. lastkey() != K_ESC
            Caheader->(dbsetorder(1))  // CANUMBER
            cKEY := LEFT(LTRIM(MAR[MPOSITION]),3))+SUBSTR(MAR[MPOSITION]),5,5)

            if Caheader->(dbseek( cKEY )
               mRECNO := Caheader->(recno())
            endif
         endif
      else
         error ( 'Client N§ not Found!' )
      endif
   endif

   setcolor  ( mcolor )
   restscreen( ,,,, mSCR )
   Caheader->( dbsetorder( mntx ) )
   Caheader->( dbgoto ( mRECNO ) ) */
*********************************/

   local mRECNO := Caheader->( recno() )
   local mntx   := Caheader->( indexord() )
   local mSCR   := savescreen ( ,,, ), mcolor := setcolor()
   local mCLNTCODE := space( len(Caheader->CLNTCODE) )
   local mar, mposition := 1, mlog := {}, mRETVAL := .f.
   local nrecno := 0
   local cfullname := space ( len( Client->fullname ) )
   LOCAL cKEY, SCANUMBER := SPACE(8), SRCHSCR
   memvar GETLIST
/*
   nrecno := _getClwin ( mclntcode,2,Client->(indexord()) )            // abb 10.18.2004 )   // client code + indexord

   if lastkey() != K_ESC .and. nrecno > 0

//       Client->  ( dbsetorder( 1 ) )       // clntname + brcode
      Client->  ( dbgoto(nrecno) )

      mclntcode := Client->clntcode
      cfullname := alltrim(Client->fullname)

      center     ( 24,'w+/n', '® Search Record ¯' )
      __lb_lkup  ( 'CLIENT',1,2,@mCLNTCODE,3,1,45,8,12-7,21,75,'W/GR+,W/N,,,W/GR+',,,,,cbrcode,'NAME',cfullname )
      center     ( 24, 'w+/n', '                 ' )

   if lastkey() == K_ENTER .and. nrecno > 0

      Caheader->(dbsetorder(3))
//
//      if Caheader->( dbseek(mCLNTCODE) )
//
      if Caheader->( dbseek ( alltrim(Client->brcode)+mclntcode) )

         mar := { '  Client N§  ' + tran( mCLNTCODE, '@R 99-99999' )    ,;
                  'Client Name  ' + DISPCLNTNAME( CAHEADER->BRCODE+mCLNTCODE, 15 )     &&left( _dispclntname( Caheader->brcode,mCLNTCODE ),15 ),;
                   repl( 'Ä', 39 ), ' Branch Name   OT N§       Action Taken', repl( 'Ä',39 ) ;
                }

         Caheader->( dbeval( {|| aadd( mar,Caheader->brcode+' '+padr(_get_branch(Caheader->brcode),10)+' '+Caheader->CANUMBER+space(7)+alltrim(upper(dispactaken(Caheader->ACTAKEN))) ) },,;
                            {|| Caheader->CLNTCODE == mCLNTCODE        .and. ;
                                Caheader->brcode   == Client->brcode .and. ;
                                !Caheader->(eof()) }) )

         if len(mar) > 1
            mlog := aclone( mar )         
            aeval ( mlog, { | l, c | mlog[ c ] := if( c <= 5, .f., .t. ), c } )
            mposition := val( gen_achoice( mar, 6, 'Search', mlog ) )
         endif

         if mposition > 0 .and. lastkey() != K_ESC

            Caheader->(dbsetorder(1))  // BRCODE + CANUMBER

            if Caheader-> ( dbseek ( alltrim(Client->brcode)+;
                                    substr( ltrim(mar[mposition]),16,5) ) )
//
//                                    left(ltrim(mar[mposition]),5) ) )
//
                mrecno  := Caheader->(recno())
                mretval := .t.

            endif

         endif

      else
         ERROR ( 'No existing CA on file!' )
      endif

   endif

   endif

   setcolor   ( mcolor )
   restscreen ( ,,,, mSCR )
   Caheader->  ( dbsetorder ( mntx ) )
   Caheader->  ( dbgoto ( mRECNO ) )
*/

*-------------------------------
   SRCHSCR := SAVESCREEN(08,30,10,65)
   @ 8,30 clear to 10,65
   @ 8,30 to 10,65
   @ 9,31 say 'Credit Application No. : '
   @ 9,56 get scanumber pict '@R 999-99999' VALID ( EMPTY(SCANUMBER) .OR. IF(VALBRCODE( LEFT(SCANUMBER,3), g_USER_ID),.T.,EVAL({|| SCANUMBER:=SPACE(8),.F.})) )

   setcursor(3)
   read
   setcursor(0)

   RESTSCREEN(08,30,10,65,SRCHSCR)

   if lastkey() == K_ESC
      return
   endif

   nrecno := 0
   if empty(scanumber)

      nrecno := Caheader->(recno())

      if !fsearch (sbrcode)  

         if Client->brcode != sbrcode
            //error ( 'Client not found in branch ' + Parametr->brcode + '-' + _get_branch(g_PAR_BRCH) )
            sbrcode := Client->brcode
            mclntcode := CLIENT->BRCODE+Client->brcode      && RED 112404 ADDED 'CLIENT->BRCODE
            // return
         else
            sbrcode   := Client->brcode            // abb 10.25.2004
            mclntcode := CLIENT->BRCODE+Client->clntcode    && RED 112404 ADDED 'CLIENT->BRCODE
            __keyboard( chr( K_INS ) )
         endif

      else

         *if !_rights ( CAHEADER->BRCODE, Caheader->aocode ) .or. Caheader->(eof())
         if !_rights ( Caheader->aocode ) .or. Caheader->(eof())
            error ( 'CA belongs to '+Caheader->aocode )
            Caheader->(dbgoto(nrecno))
            return
         endif

         if !_BR_rights ( g_USER_ID, 'CAHEADER' )   // ABB 10.12.2004
            error ( 'Cannot access CA of ' + _get_branch(Caheader->brcode) )
            Caheader->( dbgoto(nrecno) )
            return   // abb 10.22.04
         else

            *if !_rights ( CAHEADER->BRCODE, Caheader->aocode ) .or. Caheader->(eof())
            if !_rights ( Caheader->aocode ) .or. Caheader->(eof())
               error ( 'CA belongs to '+Caheader->aocode )
               Caheader->(dbgoto(nrecno))
               return  // abb 10.22.04
            else
               sbrcode   := Caheader->brcode
               scanumber := CAHEADER->BRCODE+Caheader->canumber       // abb 10.25.2004      && RED 112404 ADDED 'CAHEADER->BRCODE
            endif

         endif

      endif

      if lastkey() == K_ESC
         return
      endif

   else
      *scanumber := right ( '00000'+alltrim(scanumber),5 )     && RED 112304
      IF LEN(ALLTRIM(SCANUMBER)) < 8
         SCANUMBER := LEFT(SCANUMBER,3) + PADL(ALLTRIM(SUBSTR(SCANUMBER,4,5)),5,'0')
      ENDIF
   endif

   if !empty(scanumber)

      sbrcode   := g_PAR_BRCH

//      mclntcode := Client->clntcode

      if !Caheader->(dbseek(scanumber))  && RED REMOVED 'sbrcode+
         error ( 'CA No. '+scanumber+' for branch '+sbrcode+' not found' )
         return
      endif

      *if !_rights ( CAHEADER->BRCODE, Caheader->aocode )
      if !_rights ( Caheader->aocode )
         error ( 'CA belongs to '+Caheader->aocode )
         Caheader->( dbgoto(nrecno) )
         return // abb 10.22.04
      endif

   endif

*-------------------------------

return nil
***************************************************************************
*   Description   seeks record from CADETAIL.DBF using CANUMBER as the key
*   Parameters    CANUMBER, FACILITY CODE , ROW
*   Return Value  nil
static function search_detail( mCANUMBER, mFCLTYCODE, mROW )
************************************************************
   local mRECNO := recno(), mSCR := savescreen ( ,,, ), mLCOLOR := setcolor(),mretval := .f.
   memvar getlist
   
   center ( 24, 'w+/n', '® Search Record ¯' )
   fshadow( 11, 12, 13, 35, 2, 'n/w' )
   setcolor( 'bg+/w, w+/n,,, gr+/w' )    
   @ 12, 13 say 'Facility Code ' get mFCLTYCODE pict '@R 999-99'

   setcursor ( 3 )
   read
   setcursor ( 0 )

   if dbseek ( mcanumber )
      dbeval ( {|| if( FCLTYCODE == mfcltycode, mRECNO := recno(), nil )},,;
               {|| !eof() .and. BRCODE+CANUMBER == mcanumber })
   else
      if( lastkey()!=K_ESC .and. !empty( mFCLTYCODE ), error( 'No such Facility Code!' ), nil )
   endif

   dbgoto ( mRECNO ); restscreen( ,,,, mSCR ); setcursor ( 0 ); setcolor( mLCOLOR )
   return nil
**********************************
function dispfaculty( mfcltycode )
**********************************
return left(mFCLTYCODE,3)+'-'+right(mFCLTYCODE,2)
***********************************************
*   Description   displays CAHEADER.DBF record
*   Parameters    none
*   Return Value  nil
static function disphead( mcolor )
*************************************
return( eval( { | n | dispbegin() ,;
                      devpos( 04, 03        ), devout( "        CA N§  ", 'w/b' ),;
                      devpos( 04, col()     ), devout( TRAN(CAHEADER->BRCODE+Caheader->CANUMBER,'@R 999-99999'), mcolor ),;
                      devpos( 04, col()+2     ), devout( padr( _get_branch(Caheader->brcode),15) , mcolor ),;
                      devpos( 04, 44        ), devout( "Credit Line Type  ", 'w/b' ),;
                      devpos( 04, col()     ), devout( Caheader->LINETYPE, mcolor ),;
                      devpos( 04, col() + 1 ), devout( displinetype( Caheader->LINETYPE ), mcolor ),;
                      devpos( 05, 03        ), devout( "      CA Type  ", 'w/b' ),;
                      devpos( 05, col()     ), devout( Caheader->CATYPE, mcolor ),;
                      devpos( 05, col() + 1 ), devout( dispcatype( Caheader->CATYPE ), mcolor ),;
                      devpos( 05, 44        ), devout( "    Action Taken  ", 'w/b' ),;
                      devpos( 05, col()     ), devout( Caheader->ACTAKEN, mcolor ),;
                      devpos( 05, col() + 1 ), devout( upper( dispactaken( Caheader->ACTAKEN ) ), mcolor ),;
                      devpos( 06, 03        ), devout( "      CA Date  ", 'w/b' ),;
                      devpos( 06, col()     ), devout( dtoc ( Caheader->CADATE ), mcolor ),;
                      devpos( 06, 44        ), devout( "     Action Date  ", 'w/b' ),;
                      devpos( 06, col()     ), devout( Caheader->ACTDATE, mcolor ),;
                      devpos( 07, 03        ), devout( "  Review Date  ", 'w/b' ),;
                      devpos( 07, col()     ), devout( dtoc( Caheader->REVDATE ), mcolor ),;
                      devpos( 07, 44        ), devout( " CA Reference N§  ", 'w/b' ),;
                      devpos( 07, col()     ), devout( TRAN(IF(EMPTY(CAHEADER->CAREFNO),SPACE(8),CAHEADER->BRCODE+PADL(ALLTRIM(Caheader->CAREFNO),5,'0')),'@R 999-99999'), mcolor ),;
                      devpos( 08, 03        ), devout( "    Client N§  ", 'w/b' ),;
                      devpos( 08, col()     ), devout( dispClcode( CAHEADER->BRCODE+Caheader->CLNTCODE ), mcolor ),;    && RED 112404 ADDED 'CAHEADER->BRCODE
                      devpos( 08, col() + 1 ), devout( dispCLNTNAME( CAHEADER->BRCODE+Caheader->CLNTCODE, 40 ), mcolor ),;   && RED 112404 REPLACED '_DFISPCLNTNAME WITH DISPCLNTNAME
                      devpos( 09, 03        ), devout( '  Credit Risk  ', 'w/b' ),;
                      devpos( 09, col()     ), devout( dispcrd( CAHEADER->BRCODE+Caheader->CLNTCODE ) + space( 10 ), mcolor ),;  && RED 112404 ADDED 'CAHEADER->BRCODE REPLACED '_DISPCRD WITH DISPCRD
                      devpos( 09, 44        ), devout( '           DOSRI  ', 'w/b' ),;
					  devpos( 09, col()     ), devout( if(CAHEADER->DOSRI != 'NO ','YES '+'['+CAHEADER->DOSRI+']' ,'NO           '), mcolor ),;
                      devpos( 10, 03        ), devout( "           AO  ", 'w/b' ),;
                      devpos( 10, col()     ), devout( Caheader->AOCODE  , mcolor ),;
                      devpos( 10, col() + 1 ), devout( dispAONAME( Caheader->AOCODE ), mcolor ),;
                      devpos( 11, 03        ), devout( "Security Held  ", 'w/b' ),;
                      devpos( 11, col()     ), devout( '< Memo >', mcolor ),;
                      devpos( 11, 44        ), devout( "  To Be Obtained  ", 'w/b' ),;
                      devpos( 11, col()     ), devout( '< Memo >', mcolor ),;
                      dispend(), n } ) )
/*          && RED 100505
**********************************
*   Description   displays AONAME
*   Parameters    ao code
*   Return Value  nil
function dispAONAME( mAOCODE )
**********************************
   Ao->( dbseek ( mAOCODE ) )
return Ao->AONAME
*/
*************************************************
*   Description   displays formatted client code
*   Parameters    client code
*   Return Value  nil
function dispClcode( mCLNTCODE )
********************************
*return left( mCLNTCODE,2)+'-'+right( mCLNTCODE,5)
RETURN TRANS(mCLNTCODE,'@R 999-99-99999')
***************************************
function dispactaken( mACTAKEN )
***************************************
   local mACTCHOICES := space(12) + 'FOR APPROVALAMENDED     APPROVED    DISAPPROVED CLOSED      '
return substr( mACTCHOICES, val( mACTAKEN ) * 12 + 1 , 12 )
***************************************
function dispcatype( mCATYPE )
***************************************
   local mCACHOICES := space(23)+'PROPOSAL               '+'REVIEW                 '+'PROPOSAL & REVIEW      '+'RECLASS. OF CREDIT RISK'
return substr( mCACHOICES, val( mCATYPE ) * 23 + 1 , 23 )
***************************************************************
*   Description   add/edits CAHEADER.DBF
*   Parameters    type >> 'A' = Add else Edit
*   Return Value  nil
static function updatehead( mwhat, misf3 )
***************************************************************
local mcanumber , mcadate   , mrevdate ,  maocode  , mactaken,;
      mactdate  , msecheld  , mobtain  , muser_id , mcarefno  , mcatype,;
      mguarantor, mcancelold, mlinetype, mapprover, mcredrisk , mbrcode, mDOSRI,mbrclnt 
local mperforming  := .t. , mrecno := recno()
local mactchoices  := { '1 = FOR APPROVAL', '2 = AMENDED', '3 = APPROVED', '4 = DISAPPROVED','5 = CLOSED'}
local mtypechoices := { '1 = PROPOSAL', '2 = REVIEW', '3 = PROPOSAL & REVIEW','4 = RECLASSIFICATION OF CREDIT RISK' }
local mlinechoices := { '1 = OMNIBUS ', '2 = REGULAR' }
local mcredchoices := { 'I   = UNCLASSIFIED'    , 'II  = LOANS ESP. MENTIONED',;
                        'III = SUBSTANDARD SECURED'    , 'IV  = DOUBTFUL'       , 'V   = LOSS','VI  = SUBSTANDARD UNSECURED' }
local mDOSRICHOICES := { '1 = DIRECTORS', '2 = OFFICERS', '3 = STOCKHOLDERS', '4 = RELATED INTERESTS'}
local mRELINTERESTS := { '1 = DIRECT', '2 = INDIRECT'}

local mupdated := .f., getlist := {},coldact
LOCAL XmCANUMBER, mCLNTCODE := SPACE(10), cPRVCOL := SETCOLOR()
memvar g_user_id,g_cis_path, mtrandate

misf3 := if ( misf3 == nil, .f., .t. )
mcanumber := g_PAR_BRCH+repl( 'X', len(Caheader->CANUMBER) )      && RED 112404 ADDED 'g_PAR_BRCH+

if ( upper( mWHAT ) == 'A',;
     eval({|| Caheader->(dbgoto(lastrec()+1)),;
              center( 24, 'w+/n','® Add Record ¯');
         }),;
     eval({|| mWHAT := 'R',;
              CENTER ( 24, 'w+/n', '® Edit Record ¯') ;
         });
   )

mcanumber := if ( upper( mWHAT ) != 'A',;
                  CAHEADER->BRCODE+Caheader->CANUMBER,;
                  mCANUMBER ;
                )

mcadate    := Caheader->CADATE
mrevdate   := Caheader->REVDATE

if upper( mWHAT ) != 'A'                      // abb 10.27.2004
   mclntcode  := CAHEADER->BRCODE+Caheader->CLNTCODE  && RED 112404 ADDED 'CAHEADER->BRCODE
   cbrcode    := mbrcode    := Caheader->brcode
endif

maocode    := Caheader->AOCODE
mactaken   := Caheader->ACTAKEN
mactdate   := Caheader->ACTDATE
msecheld   := COLLMEM('CA_SEC',CAHEADER->CANUMBER,CAHEADER->BRCODE)       && RED 112505  Caheader->SECHELD
mobtain    := COLLMEM('CA_OBT',CAHEADER->CANUMBER,CAHEADER->BRCODE)       && RED 112505  Caheader->OBTAIN
muser_id   := Caheader->USER_ID
mcarefno   := g_PAR_BRCH+Caheader->CAREFNO
mcatype    := Caheader->CATYPE
mcancelold := Caheader->CANCELOLD
mlinetype  := Caheader->LINETYPE
mapprover  := Caheader->APPROVER
mcredrisk  := dispcrd(mclntcode)    && RED 112404 REPLACED '_DISPCRD WITH DISPCRD
mbrcode    := cbrcode := Caheader->brcode          // abb 10.25.2004
mbrclnt	   := client->brcode
//mDOSRI     := if(CAHEADER->DOSRI != 'NO ','YES '+'['+CAHEADER->DOSRI+']','NO')

if upper( mWHAT ) == 'A'
   mbrcode    := cbrcode := sbrcode   // abb 10.25.2004
   *mclntcode  := CLIENT->BRCODE+Client->CLNTCODE      && RED 112404 ADDED 'CLIENT->BRCODE
   mACTAKEN   := '1'
endif
creason      := Caheader->disapptype            // abb
_reason_desc := Caheader->dreason               // 11.26.2003

coldact    := mactaken
setcolor ( 'gr+/b, w+/g,,, gr+/b' )

   disphead()      

   do while mperforming

      @ 04, 19 get mCANUMBER pict '@R 999-99999' when .f.   && RED 112404 REPLACED '@X' WITH '@R 999-99999'
      @ 05, 19 get mCATYPE   pict '@X' when if ( !misf3, chkcatype( mtypechoices, @mcatype ),.f. ) valid !empty ( mCATYPE )
      @ 06, 19 get mCADATE   pict '@D' when !mISF3 valid !empty ( mCADATE   )
      @ 07, 19 get mREVDATE  pict '@D' when !mISF3 valid !empty ( mREVDATE  ) .and. mREVDATE >= mCADATE
      @ 04, 63 get mLINETYPE pict '@X' when if ( !mISF3, chkline( mLINECHOICES, @mLINETYPE ),.f. ) valid !empty ( mLINETYPE )
      @ 05, 63 get mACTAKEN  pict '@X' ;
                             when if ( mISF3,(lastkey() != K_PGDN .and. ;
                                       lastkey() != K_ESC       ,;
                                       chkactaken( mACTCHOICES, @mACTAKEN, mWHAT,@mapprover),;
                                       .f. ),.F. ;
                                     )
      @ 06, 63 get mACTDATE  pict '@D' ;
                             when if ( lastkey() != K_ESC, mACTAKEN != '1' .and. mWHAT != 'A',.f. );
                             valid chkactdate( mCADATE, mACTDATE ) .and. .t. ;
//                                   !empty(mactdate)
      @ 07, 63 get mCAREFNO  pict '@R 999-99999';
                             when ( mWHAT != 'A' .and. lastkey()!= K_ESC );   && RED 112604 REPLACED '@X' WITH '@R 999-99999'
                             VALID IF( CURRBRCH(LEFT(mCAREFNO,3)), .T., EVAL({|| mCAREFNO := g_PAR_BRCH+SPACE(5), .F.}) )
      @ 08, 19 get mCLNTCODE ;
               pict '@R 999-99-99999' ;  && RED 112404 ADDED '999-
               when  if ( !mISF3 .and. lastkey() != K_ESC,;
                          chkclntcode( @mCLNTCODE,@mCANCELOLD,mCANUMBER,@cbrcode ),;
                          .f. ;
                        ) ;
               valid !empty  ( mCLNTCODE  )
      @ 09, 19 get mcredrisk pict '@X' when if ( !misF3 .and. lastkey() != K_ESC .and. alltrim(mcatype) == '4',chkcredrisk(@mcredrisk,mcredchoices),.f. )
	  @ 09 ,68 get mDOSRI    pict '@X' when lastkey() <> K_ESC .and. if(!misf3 ,if(if(yes_no2( 'DOSRI?',, ' Yes ', ' No ', .f.,'w+/rb','w+/rb' ),;
										chkDOSRI( mDOSRICHOICES,@mDOSRI,mRELINTERESTS,9,63 ), noDOSRI(@mDOSRI,9,63) ) == 'YES',.f.,.f.) , .f. )
										
      @ 10, 19 get mAOCODE   pict '@X' when  if( !mISF3 .and. lastkey() != K_ESC ,chkaocode( mbrcode,@mAOCODE ), .f. ) valid !empty ( mAOCODE ) .AND. AOACCESS->(DBSEEK(mbrcode+g_USER_ID))
	  //@ 10, 19 get mAOCODE   pict '@X' when  if( !mISF3 .and. lastkey() != K_ESC ,chkaocode( @mAOCODE ), .f. ) valid !empty ( mAOCODE )
	  
      @ 11, 19 say '< Memo >'
      @ 11, 63 say '< Memo >'

      setcursor( 3 )
      read
      setcursor( 0 )

      do case
         case lastkey() == K_ESC
            if esckey()
               exit
            else
               loop
            endif
         case lastkey() == K_ENTER

            if !empty( mcadate ) .and. !mISF3
               update_memo( @mSECHELD, @mOBTAIN,, 11, 11, 19, 63,, 14 )
            endif

            if confirm ( 'Are all entries correct?' )
               if Caheader-> ( netlock( mWHAT, 0 ) )
                  MSGWIN(06,35,'Saving','w+/bg','r*/bg','on')

                  if upper(mwhat) == 'A'
// EVR               if Parametr->( netlock( 'R', 0 ) )
// EVR                  _field->Parametr->lastcano := Xmcanumber := right( '0000' + ltrim( str( val( Parametr->lastcano ) + 1 ) ), 5 )    && RED 112404 REPLACED 'mCANUMBER WITH XmCANUMBER
// EVR                  Parametr->( dbcommit() )
// EVR               endif
// EVR               Parametr->( dbunlock() )                        
                     if Ol_param->(dbseek(g_PAR_BRCH))
                        if Ol_param->(netlock('R', 0))
                           Ol_param->LASTCANO := Xmcanumber := right('0000'+ltrim(str(val(Ol_param->LASTCANO)+1)),5)
                           Ol_param->(dbunlock())
                        endif
                        Ol_param->(dbcommit())
                     endif
                  endif

// EVR            UPDT_OL()            && RED 033005

                  mbrcode := cbrcode          // abb 10.27.04

                  Caheader->CANUMBER := IF( UPPER(mWHAT) == 'A', Xmcanumber, RIGHT(mCANUMBER,5) )  && RED 112404 REPLACED mCANUMBER WITH XmCANUMBER
                  Caheader->CADATE   := mcadate
                  Caheader->REVDATE  := mrevdate
                  Caheader->CLNTCODE := RIGHT(mclntcode,7)     && RED 112404 FORMAT RIGHT(,7)
                  Caheader->AOCODE   := maocode
                  Caheader->ACTAKEN  := mactaken
                  Caheader->ACTDATE  := mactdate

                  //if !empty( mcadate ) .and. !mISF3   // ADDED BY ARIEL
                    *---> RED 112505
                    *Caheader->SECHELD  := msecheld   // may 31, 1999
                    *Caheader->OBTAIN   := mobtain    //
                    SAVEMEM( mSECHELD,'CA_SEC', IF( UPPER(mWHAT) == 'A', Xmcanumber, RIGHT(mCANUMBER,5) ), mBRCODE )
                    SAVEMEM( mOBTAIN,'CA_OBT', IF( UPPER(mWHAT) == 'A', Xmcanumber, RIGHT(mCANUMBER,5) ), mBRCODE )
                    *--->
                  //endif

                  Caheader->USER_ID    := muser_id
                  Caheader->TRANDATE   := mtrandate
                  Caheader->CAREFNO    := RIGHT(mcarefno,5)
                  Caheader->USER_ID    := g_user_id
                  Caheader->CATYPE     := mcatype
                  Caheader->CANCELOLD  := mcancelold
                  Caheader->LINETYPE   := mlinetype
                  Caheader->APPROVER   := mapprover
                  Caheader->DATE_APROV := mtrandate
                  Caheader->TIME       := time()

                  Caheader->brcode  :=  mbrcode       // abb 10.25.2004
				 // Caheader->brcode2 := mbrclnt
				  //caheader->brcode3 := mbrcode
                  //
                  //   creason := space(1) ,
                  //   _reason_desc
                  //
                  Caheader->disapptype := creason           // abb
                  Caheader->dreason    := _reason_desc      // 03.26.2003
				  if !misf3
					Caheader->dosri       := mDOSRI //if(mDOSRI == 'YES',.t.,.f.) // RLV 10:30 AM 5/30/2011 
				  endif
                  Caheader-> ( dbunlock() )
                  Caheader-> ( dbcommit() )

                      if ( alltrim(mcatype ) == '4' , upd_corpinfo( mcredrisk ), nil  )
                      mrecno := Caheader->( recno() )
                      mupdated := .t.

                  if mwhat == 'A'
                     drop   ( alltrim(g_user_id)+' '+'Adds CA No. '+Caheader->CANUMBER )
                  else
                     if misf3
                        drop   ( alltrim(g_user_id)+' '+'Edits CA.'+Caheader->CANUMBER+' '+mactchoices[val(coldact)] +'to'+mactchoices[val(mactaken)] )
                     else
                        drop   ( alltrim(g_user_id)+' '+'Edits CA No. '+Caheader->CANUMBER )
                     endif
                  endif

                  MSGWIN(06,35,'Saving','w+/bg','r*/bg','off')

                  exit

               endif
            endif
      endcase

   enddo

   SETCOLOR(cPRVCOL)    && RED 11262004

   center( 24, 'w+/n', '               ')   
   go mRECNO
return mupdated

**************************************************
function chkDOSRI( mDOSRICHOICES,mDOSRI,mRELINTERESTS,nX,nY )
**************************************************
mDOSRI := '1'

	mDOSRI := gen_achoice( mDOSRICHOICES ,val(mDOSRI), 'DOSRI Types', 05, 58, 12, 78, 'W/GR+,W/N,,,W/GR+' )

	if mDOSRI == '4'
		mDOSRI :=  gen_achoice( mRELINTERESTS ,val(mDOSRI), 'DOSRI-Related Interests', 05, 80, 04, 98, 'W/GR+,W/N,,,W/GR+' )
		if lastkey() == K_ENTER
			mDOSRI := '4' + mDOSRI
		endif
	endif
	
	if mDOSRI == '1'
		mDOSRI := 'DIR'
	elseif mDOSRI == '2'
		mDOSRI := 'OFC'	
	elseif mDOSRI == '3'
		mDOSRI := 'STK'	
	elseif mDOSRI == '41'
		mDOSRI := 'RID'	
	elseif mDOSRI == '42'
		mDOSRI := 'RII'	
	endif

@ nX , nY say 'YES '+'['+mDOSRI+']'
	
return mDOSRI

*************************
function noDOSRI(mDOSRI,nX,nY)
*************************

@ nX , nY say '            '

	mDOSRI := 'NO '

return mDOSRI


*******************************************************
*  Desc ¯ look-up table for credit risk+
static function chkcredrisk( mcredrisk,mcredchoices )
*******************************************************
local mcred := { 'I UNCLASSIFIED     ', 'II LOANS ESP. MEN  ', 'III SUBSTANDARD SEC', 'IV DOUBTFUL        ', 'V LOSS             ', 'VI SUBSTANDARD UNSE' }

   do case
      case left(mcredrisk,at(' ',mcredrisk)-1 ) == 'I'
         mcredrisk := '1'
      case left(mcredrisk,at(' ',mcredrisk)-1 ) == 'II'
         mcredrisk := '2'
      case left(mcredrisk,at(' ',mcredrisk)-1 ) == 'III'
         mcredrisk := '3'
      case left(mcredrisk,at(' ',mcredrisk)-1 ) == 'IV'
         mcredrisk := '4'
      case left(mcredrisk,at(' ',mcredrisk)-1 ) == 'V'
         mcredrisk := '5'
      case left(mcredrisk,at(' ',mcredrisk)-1 ) == 'VI'
         mcredrisk := '6'
   endcase
   mcredrisk := gen_achoice( mcredchoices, val( mcredrisk ), 'Credit Risk', 11, 19, 16, 42, 'w/gr+,w/n,,,w/gr+' )
   mcredrisk := mcred [ val ( mcredrisk ) ]
   @ 9, 19 say mcredrisk
return .f.
*******************************************************
*  Desc ¯ update Corpinfo.dbf
static function upd_corpinfo ( mcredrisk )
*******************************************************
   local mpos := at ( chr(32), alltrim( mcredrisk ) )

   if Corpinfo -> ( dbseek ( CAHEADER->BRCODE+Caheader->CLNTCODE ) )
      if Corpinfo -> ( netlock( 'R',0 ) )
         Corpinfo -> CREDRISK := left( alltrim( mcredrisk ) , mpos-1 )
         Corpinfo -> ( dbunlock() )
         Corpinfo -> ( dbcommit() )
      endif
   endif
return nil
**************************************************
static function chkLINE( mLINECHOICES, mLINETYPE )
**************************************************
   mLINETYPE := gen_achoice( mLINECHOICES, val( mLINETYPE ), 'Credit Line Type', 05, 58, 8, 78, 'W/GR+,W/N,,,W/GR+' )
   @ 04, 65 say displinetype( mLINETYPE )
return .f.
*******************************************************
static function displinetype( mLINETYPE )
*****************************************
return substr( space(7)+'OMNIBUSREGULAR', val(mLINETYPE)*7+1,7 )
*******************************************************
*   Description   Checks Action Date
*   Parameters    Action Date, Credit Application Date
*   Return Value  None
static function chkactdate( mACTDATE, mCADATE )
***********************************************
   local mRETVAL := .t.
   if mactdate > mcadate
      error('Action Date must not be earlier than the CA Date!') ; mRETVAL := .f.
   endif
return mRETVAL
**************************************************
static function chkcatype( mtypechoices, mcatype )
**************************************************
   mCATYPE := gen_achoice( mTYPECHOICES, val( mCATYPE ), 'CA Type', 06, 21, 11, 41, 'W/GR+,W/N,,,W/GR+' )
   @ 05, 21 say dispcatype( mCATYPE )
return .f.

********************************************************************
*   Description    displays action taken
*   Parameters     Action Taken Code
*   Return Value   .f.
static function chkactaken( mactchoices, mactaken, mwhat,mapprover )
********************************************************************
local old_takn := mactaken 
local cscr := savescreen (,,,)
local getlist := {}
local _disappchoices := space(37) + ;
                      'Financials                           '+;
                      'Credit/Findings in Company/Principals'+;
                      'Industry Outlook                     '+;
                      'Others, specify                      '
local _adisapproved  := { '1 = Financials' ,;
                          '2 = Credit Findings in Company/Principals' ,;
                          '3 = Industry Outlook',;
                          '4 = Others, specify'  ;
                        }
// local mPAYCHOICES    := { '1 = IN ADVANCE','2 = IN ARREARS' }, mcolor := setcolor()

//
//                     1234567890123456789012345678901234567
//

/*
   if mactaken == Disapproved
      select 1 of the following :
         1. Financials
         2. Credit Findings in Company/Principals
            1234567890123456789012345678901234567
                     1         2         3      7
         3. Industry Outlook
         4. Others, specify

         Disapptype  Char  1
         Disapprem   Char  40

         ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         ³ Reason : Û                                          ³
         ³ Desc   : ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ ³
         ³                                                     ³
         ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

   endif
*/

   mwhat    := if ( mwhat != 'A', 'R', 'A' )
   do while .t.
   
      if mwhat == 'R' 
         mactaken := gen_achoice( mACTCHOICES, val( mACTAKEN ), 'Action Taken', 06, 57, 11, 77, 'w/gr+,w/n,,,w/gr+' )
      else
         mactaken := '1'
      endif
      @ 05, 65 say upper( dispactaken( mactaken ) )

      if mactaken == '4'                     // Disapproved 3.18.2003
         @ 10,10 clear to 13,65
         @ 10,10 to 13,65
         creason := gen_achoice( _adisapproved, val( creason ), 'Disapproved', 06, 57, 11, 77, 'w/gr+,w/n,,,w/gr+' )

         @ 11,11 say 'Reason ? : ' get creason     ;
                                   pict '@!S40'    ;
                                   valid creason $ '1234' ;
                                   when .f.

         do case
            case creason == '1'
                 _reason_desc := '1 = Financials         '
            case creason == '2'
                 _reason_desc := '2 = Credit Findings in Company/Principals'
            case creason == '3'
                 _reason_desc := '3 = Industry Outlook'
            otherwise
                 if empty(Caheader->dreason)
                    _reason_desc := space(len(_reason_desc))
                 else
                    _reason_desc := _reason_desc
                 endif
         endcase

         @ 12,11 say 'Others   : ' get  _reason_desc    ;
                                   when creason == '4'  ;
                                   pict '@!'            ;
                                   valid !empty(_reason_desc)

         setcursor(3)
         read

         restscreen(,,,,cscr)
         @ 05, 65 say upper( dispactaken( mactaken ) )
         if lastkey() != K_ESC
            //alert ( _reason_desc )
         endif

      endif

      if mwhat == 'R' .and. old_takn <> mactaken .and. lastkey() != K_ESC

         if actvalidate   ( mactaken,@mapprover )
            look_approver ( alltrim(mapprover) )
            exit
         endif

      elseif lastkey() == K_ESC
         mactaken := old_takn
         exit
      else
         exit
      endif

   enddo

return .f.

*************************************************************************
*   Description    displays CLIENT NAME/CODES
*   Parameters     CLIENT CODE
*   Return Value   .f.
static function chkclntcode( Mclntcode, Mcancelold, Mcanumber,cbrcode )
*************************************************************************
local cINFO :=  space(1)
  //
  // lb_lkup( 'Client',1,2,@mCLNTCODE,3,1,10,12,21,75, 'w/gr+,w/n,,,w/gr+' )
  // @ 8, 28 say dispclntname( mCLNTCODE )

  // alert ( '--' + mclntcode )
  // alert ( '--' + cbrcode   )

   __lb_lkup ( 'Client',1,2,@mclntcode,03,45,01,08,5,21,75, 'w/gr+,w/n,,,w/gr+',,,,,cbrcode, )
   cbrcode := alltrim(Client->brcode)           // abb 10.13.2004
   mCLNTCODE := CLIENT->BRCODE+mCLNTCODE

   @ 08,28+4 say dispclntname( mCLNTCODE, 40 )  // display the client name && RED 112404 REMOVED 'cbrcode REPLACED '_DISPCLNTCODE WITH DISPCLNTCODE

   if cbrcode != g_PAR_BRCH
      error ( 'Cannot add/edit client for branch '+cbrcode )
      __keyboard( chr( 27 ) )
   else
        if CLIENT->(dbseek(mCLNTCODE))
		   if CLIENT->CLTYPE == '2'                                 //CONSUMER  pepe 2:21 PM 08.05.2008 
				if !SIGNERS->(DBSEEK(mclntcode)) 
				    cINFO := 'SIGNEE'
			    else
				   if EMPTY(SIGNERS->SIGNER)
				      cINFO := 'SIGNEE'
				   endif
				endif
				if !Indvcntc->(DBSEEK(mclntcode))
				    cINFO := if (!empty(cINFO),cINFO+';CONTACT PERSON','CONTACT PERSON')
			    else
				   if EMPTY(Indvcntc->CONTACT)
				      cINFO := if (!empty(cINFO),cINFO+';CONTACT PERSON','CONTACT PERSON')
				   endif
				endif
				if !Indvinfo->(DBSEEK(mclntcode))
					cINFO := if (!empty(cINFO),cINFO+';PERSONAL INFORMATION','PERSONAL INFORMATION')
			    else
				   if EMPTY(Indvinfo->NATION)
				      cINFO := if (!empty(cINFO),cINFO+';PERSONAL INFORMATION','PERSONAL INFORMATION') 
				   endif
				endif

				IF !EMPTY(cINFO)
				   alert('Cannont add/edit client without completing the following information:;;'+cINFO)
				   __keyboard( chr( 27 ) )
				ENDIF
		   endif
	    endif
   endif
   
return if (  lastkey()!=K_ESC,;
              exist_clnt(mclntcode,@mCANCELOLD,mCANUMBER),;
              .t. ;
          )

*************************************************************
static function exist_clnt( mclntcode, mCANCELOLD,mCANUMBER )
*************************************************************
return eval({|x,y| x:= savedbf(x) , y := .f.           ,;
                   Caheader->  ( dbsetorder(3) )       ,;
                   Caheader->  ( dbseek( mclntcode ) ) ,;
                   val_clntcode( @y,@mCANCELOLD,mclntcode,mCANUMBER ) ,;
                   restdbf (x), y })
*************************************************************************
*
static function val_clntcode( mretval, mcancelold, mclntcode, mcanumber )
*************************************************************************
   local munavailed, mrecno := Caheader->( recno() )
   while !Caheader->(eof()) .and. ;
         CAHEADER->BRCODE+Caheader->CLNTCODE == mclntcode .and. ;   && RED 112404 ADDED 'CAHEADER->BRCODE
         !mretval
      do case
         case Caheader->ACTAKEN == '1' .and. CAHEADER->BRCODE+Caheader->CANUMBER!=mCANUMBER  // for approval
             eval({|| error('Client has an EXISTING CA for APPROVAL N§ '+CAHEADER->BRCODE+Caheader->CANUMBER+','),mretval:=.t. })
         case Caheader->ACTAKEN == '2' .and. CAHEADER->BRCODE+Caheader->CANUMBER!=mCANUMBER  // approved
             if ( munavailed := Caheader->CALINE - Caheader->AVAILED ) > 0
                ?? chr(7)
                if confirm( 'Client has UNAVAILED LINE of ('+ltrim( transform(munavailed,'999,999,999.99') )+')'+', CANCEL?')
                   mcancelold := .T.
                else
                   mcancelold := .F.
                endif
             endif
      endcase
      Caheader->(dbskip(+1))
   enddo
   Caheader->( dbgoto( mrecno ) )
   
return nil
**********************************************
*   Description    displays CLIENT NAME/CODES
*   Parameters     CLIENT CODE
*   Return Value   .f.
static function chkGUARANTOR( mGUARANTOR )
******************************************
   lb_lkup('Client',1,2,@mGUARANTOR, 3 , 1, 10, 12, 22, 75, 'W/GR+,W/N,,,W/GR+')
   @ 9, 28 say dispCLNTNAME( mGUARANTOR, 40 )
return .f.
/***
***********************************************
*   Description   displays client name
*   Parameters    client code
*   Return value  client name
static function dispclntname(  mCLNTCODE, nLEN )
***********************************************
IF nLEN == NIL .OR. EMPTY(nLEN)
   nLEN := 50
ENDIF

return eval ({ |x,y| x:= savedbf ( x ),;
                     Client->( dbsetorder(1) ),;
                     Client->( dbseek(mclntcode) ),;
                     y:= left( Client->FULLNAME, nLEN ),;
                     restdbf( x ),;
                     y })
***/
/* EVR 21122006 - no use
**********************************************
*   Description    updates parametr->LASTCANO
*   Parameters     none
*   Return Value   nil
static function update_parametr()
*********************************
   local mdbf := savedbf( mdbf )
   Parametr->( dbunlock() )
   if Parametr->( netlock ( 'R', 0 ) )
      Parametr->LASTCANO  := Caheader->CANUMBER
      Parametr->( dbcommit() ) ; Parametr->( dbunlock() )
   endif
   restdbf ( mdbf )

   UPDT_OL()         && RED 033005

return nil
*/

******************************************************************
*    Description  
*    Parameters    SECHELD and OBTAIN
*    Return Value  .f.
static function chkaocode( mbrcode,mAOCODE )
************************************
lRETVAL := .T.
   lb_lkup((xTEMP), 1, 1, @mAOCODE, 2 , 1, 11, 22, 21, 75, 'W/GR+,W/N,,,W/GR+')     // EVR 28112006
   @ 10, 25 say dispaoname( maocode )
   
   IF AOACCESS->(DBSEEK(mbrcode+mAOCODE))
      lRETVAL := .F.
   ELSE
      ERROR('YOU HAVE NO AO ACCESS!!!')
   ENDIF
return lRETVAL
************************************************************************************
*    Description   updates all memo fields ( SECHELD and OBTAIN )
*    Parameters    SECHELD and OBTAIN
*    Return Value  nil
function update_memo( mSECHELD, mOBTAIN, mREMARKS ,mROW1,mROW2, mCOL1,mCOL2,mISCA, xrow )
**********************************************************************************
   if ( misca == nil , misca := .t., misca )

   devpos ( mROW1, mCOL1 )
   devout ( "< Memo >", 'gr+/b' )
   memo   ( @mSECHELD , "S",misca,, xrow )
   devpos ( mROW1, mCOL1 )
   devout ( "< Memo >", 'gr+/b' )
   devpos ( mROW2, mCOL2 )
   devout ( "< Memo >", 'gr+/b' )
   memo   ( @mOBTAIN  , "O",misca,, xrow )
   devpos ( mROW2, mCOL2 )
   devout ( "< Memo >", 'gr+/b' )

   if mremarks != Nil
      devpos ( mrow2+1, mcol2 ) ; devout( "< Memo >", 'gr+/b' )
      memo   ( @mremarks , "R", misca,, xrow )
      devpos ( mrow2+1, mcol2 ) ; devout( "< Memo >", 'gr+/b' )
   endif
return nil
/***   */
*******************************************
*
static function _chkright(xAocode,sbrcode)
*******************************************
 local mretval := .f.
 memvar G_USER_ID
 Aoaccess->( dbseek ( alltrim(Caheader->brcode) + G_USER_ID) )
 do while alltrim(Aoaccess->Aocode) == alltrim(G_USER_ID) .and. ;
          alltrim(Caheader->brcode)  == alltrim(sbrcode) .and. ;
          !Aoaccess->(eof())

    if alltrim(Aoaccess->aoaccess) == alltrim(xAocode)
       mretval := .t.
       exit
    endif
    Aoaccess->(dbskip())
 enddo
 if !mretval
    error('Access to this account denied.')
 endif
 return mretval

*********************************
*
*
function chkright(xAocode)
*********************************

 local mretval := .f.
 memvar G_USER_ID
 Aoaccess->( dbseek(G_USER_ID) )
 do while alltrim(Aoaccess->Aocode) == alltrim(G_USER_ID)
    if alltrim(Aoaccess->aoaccess) == alltrim(xAocode)
       mretval := .t.
       exit
    endif
    Aoaccess->(dbskip())
 enddo
 if !mretval
    error('Access to this account denied.')
 endif
 return mretval
**************************************
*  Desc ¯ displays the facility name
*
function dispfcltyname( mfcltycode )
**************************************
   Facility-> ( dbseek( mfcltycode ) )
return Facility->FCLTYNAME

*************************************************
*
function _getdivhead(cAOCODE)
*************************************************
   memvar cdivhead,cdivpost
   local mscreen := savescreen( ,,, ), mDBF := select(), yTEMP     // EVR 28112006
   center  ( 24, 'w+/n','® Select Division Head ¯')
   cdivhead := space(5)
   cdivpost := space(30)

   yTEMP := creattemp()     // EVR 28112006
   dbcreate((yTEMP), {{'AOCODE','C',5,0},{'AONAME','C',40,0}})
   while !NETUSE((yTEMP),.F.,5); enddo
   index on AOCODE to (yTEMP)

   if Aoaccess->(dbseek(g_PAR_BRCH))
      do while !Aoaccess->(eof()) .and. Aoaccess->BRCODE == g_PAR_BRCH
         if padr(alltrim(Aoaccess->AOACCESS),5,' ') == cAOCODE
            if !(yTEMP)->(dbseek(padr(alltrim(Aoaccess->AOCODE),5,' ')))
               if Ao->(dbseek(padr(alltrim(Aoaccess->AOCODE),5,' ')))
                  append blank
                  (yTEMP)->AOCODE := Ao->AOCODE
                  (yTEMP)->AONAME := Ao->AONAME
               endif
            endif
         endif
         Aoaccess->(dbskip())
      enddo
   endif

   lb_lkup ( (yTEMP), 1, 1, @cdivhead, 2 , 1, 11, 22, 21, 75, 'w/gr+,w/n,,,w/gr+' )
   if lastkey() != K_ESC
      Ao->(dbseek(cdivhead))
      cdivhead := upper ( Ao->aoname )
      cdivpost := upper ( Ao->aopost )
   endif

   (yTEMP)->(dbclosearea())
   ferase(yTEMP+'.DBF')
   ferase(yTEMP+'.NTX')

   select(mDBF)
   restscreen( ,,,, mscreen )
return lastkey() != K_ESC

*************************************************
*   Description   opens all needed files
*   Parameters    none
*   Return Value  .t. = successful opening
*                  .f. = error in opening files
static function amsm0100open()
******************************
   local mRETVAL := .f.
   local cscr := savescreen ( ,,, ),mcol
   @ 22,1 say 'Opening files .....'
   mcol := col()

   xTEMP := creattemp()     // EVR 28112006
   dbcreate((xTEMP), {{'AOCODE','C',5,0},{'AONAME','C',40,0}})
   while !NETUSE((xTEMP),.F.,5); enddo
   index on AOCODE to (xTEMP)

   if !netuse( '&g_grf_path\Branches', .f., 5 ) && branches
      return .f.
   else
      ordlistadd( '&g_grf_path\Brcode' )   && set index on branch code
   endif
   @ 22,mcol say '.'
   mcol := col()

   if NETUSE(  '&g_OLS_path\OLCAHEAD',.f.,5)
      set index  to &g_OLS_path\Caheader, &g_OLS_path\Carev, &g_OLS_path\Caclnt, &g_OLS_path\Caclnt2
      OLCAHEAD->( dbsetorder (1) )
   endif
   
   if NETUSE ( '&g_OLS_path\OLCADET',.f.,5)
      set index  to &g_OLS_path\Cadetail,&g_OLS_path\Cadetcfl
   endif
   
   if netuse(  '&g_OLS_path\OLSMAST' ,.f.,5 )
      set index  to &g_OLS_path\Acctmast,;
			        &g_OLS_path\Acctclnt,;
			        &g_OLS_path\Sureclnt,;
			        &g_OLS_path\Acctfa,;
			        &g_OLS_path\Acctsub2,;
			        &g_OLS_path\Acctfclt,;
			        &g_OLS_path\Acctcdft,;
			        &g_OLS_path\Acctcln2
      olsmast->(dbsetorder  (2))
   endif

   if netuse(  '&g_OALP_path\OALPMAST' ,.f.,5 )
      set index  to &g_OALP_path\Acctmast,;
			        &g_OALP_path\Acctclnt,;
			        &g_OALP_path\Sureclnt,;
			        &g_OALP_path\Acctfa,;
			        &g_OALP_path\Acctsub2,;
			        &g_OALP_path\Acctfclt,;
			        &g_OALP_path\Acctcdft,;
			        &g_OALP_path\Acctcln2
      OALPMAST->(dbsetorder  (2))
   endif
   
   if !netuse( '&g_grf_path'+'\Axbranch.dbf',.f.,5)
      return .f.
   endif
   set index to &g_grf_path\Axbranch
   @ 22,mcol say '.'
   mcol := col()

   if NETUSE(  '&g_AMS_PATH\Caheader',.f.,5)
      set index  to &g_AMS_PATH\Caheader, &g_AMS_PATH\Carev, &g_AMS_PATH\Caclnt  //, &g_AMS_PATH\Caclnt2 
      Caheader->( dbsetorder (1) )
      @ 22,mcol say '.'
      mcol := col()

      if NETUSE ( '&g_AMS_PATH\Cadetail',.f.,5)
         set index  to &g_AMS_PATH\Cadetail,&g_AMS_PATH\Cadetcfl
         @ 22,mcol say '.'
         mcol := col()

// EVR   if NETUSE ( 'Parametr',.f.,5)
// EVR   @ 22,mcol say '.'
// EVR   mcol := col()

         IF NETUSE('&g_AMS_PATH\OL_PARAM',.F.,5)         && RED 033005
            SET INDEX TO &g_AMS_PATH\OL_PARAM
            @ 22,mcol say '.'
            mcol := col()

            if NETUSE('  &g_AMS_PATH\Facility',.f.,5)
               set index to &g_AMS_PATH\Fcltycd
               @ 22,mcol say '.'
               mcol := col()

               if NETUSE( '&g_CIS_PATH'+'\Ao.dbf',.f.,5)
                  set index to &g_CIS_PATH\Ao.ntx
                  @ 22,mcol say '.'
                  mcol := col()

                  if NETUSE( '&g_CIS_PATH'+'\Client.dbf',.f.,5)
                     set index to &g_CIS_PATH\Cliecd, &g_CIS_PATH\Clienm
                     @ 22,mcol say '.'
                     mcol := col()

                     if NETUSE( '&g_CIS_PATH'+'\Dealer.dbf',.f.,5)
                        set index to &g_CIS_PATH\Dlrcode,&g_CIS_PATH\Dlrname
                        @ 22,mcol say '.'
                        mcol := col()

                        if NETUSE( '&g_CIS_PATH'+'\Industry.dbf',.f.,5)
                           set index to &g_CIS_PATH\Industry
                           @ 22,mcol say '.'
                           mcol := col()

                           if netuse( '&g_CIS_PATH'+'\Corpinfo.dbf',.f.,5)
                              set index to &g_CIS_PATH\Corpinfo
                              @ 22,mcol say '.'
                              mcol := col()

                              if netuse( '&g_AMS_PATH\Comcodes' ,.f., 5)
                                 set index to &g_AMS_PATH\Comcodes
                                 @ 22,mcol say '.'
                                 mcol := col()

                                 if netuse( '&g_AMS_PATH\Comember' ,.f.,5)
                                    set index  to &g_AMS_PATH\Comember
                                    @ 22,mcol say '.'
                                    mcol := col()

                                    if netuse(  '&g_AMS_PATH\Orixunit' ,.f.,5)
                                       set index  to &g_AMS_PATH\Orixunit
                                       @ 22,mcol say '.'
                                       mcol := col()

                                       if netuse(  '&g_AMS_PATH\Acctmast' ,.f.,5 )
                                          set index  to &g_AMS_PATH\Acctmast,;
                                                        &g_AMS_PATH\Acctclnt,;
                                                        &g_AMS_PATH\Sureclnt,;
                                                        &g_AMS_PATH\Acctfa,;
                                                        &g_AMS_PATH\Acctsub2,;
                                                        &g_AMS_PATH\Acctfclty,;
                                                        &g_AMS_PATH\Acctcdft,;
														&g_AMS_PATH\ACTMREF1,;
														&g_AMS_PATH\ACTMREF2
                                          Acctmast->(dbsetorder  (2))
                                          @ 22,mcol say '.'
                                          mcol := col()

                                          if netuse (  '&g_AMS_PATH\Grpcodes',.f.,5)
                                             set index   to &g_AMS_PATH\Grpcodes
                                             @ 22,mcol say '.'
                                             mcol := col()

                                             if netuse (  '&g_AMS_PATH\Grpmembr',.f.,5)
                                                set index   to &g_AMS_PATH\Grpmembr,&g_AMS_PATH\Grpclnt,&g_AMS_PATH\GRPCLNT2, &g_AMS_PATH\GRPMEMB2
                                                Grpmembr->( dbsetorder(2) )
                                                @ 22,mcol say '.'
                                                mcol := col()

                                                if netuse ( '&g_AMS_PATH\Oticket',.f.,5)
                                                   set index  to &g_AMS_PATH\Oticket,&g_AMS_PATH\Otclnt
                                                   Oticket->( dbsetorder(2) )
                                                   @ 22,mcol say '.'
                                                   mcol := col()

                                                   if netuse ( '&g_AMS_PATH\Approver',.f.,5)
                                                      @ 22,mcol say '.'
                                                      mcol := col()

                                                      if netuse( '&g_AMS_PATH\Axmast',.f.,5)
                                                         set index to &g_AMS_PATH\User_id
                                                         @ 22,mcol say '.'
                                                         mcol := col()

                                                         if netuse( '&g_AMS_PATH\Aoaccess',.f.,5)
                                                            set index to &g_AMS_PATH\Aoaccess
                                                            @ 22,mcol say '.'
                                                            mcol := col()

                                                            if netuse( '&g_AMS_PATH\Drop',.f.,5 )
                                                               set index to &g_AMS_PATH\Drop
                                                               @ 22,mcol say '.'
                                                               mcol := col()

                                                               if netuse( '&g_AMS_PATH\Subcred',.f.,5 )
                                                                  set index to &g_AMS_PATH\Subcred
                                                                  @ 22,mcol say '.'
                                                                  mcol := col()

                                                                  if netuse( '&g_AMS_PATH\ACCTWAIT',.f.,5)
                                                                     set index to &g_AMS_PATH\ACCTWAIT,;
                                                                                  &g_AMS_PATH\ACCTWSUB,;
                                                                                  &g_AMS_PATH\ACCTRECL,;
                                                                                  &g_AMS_PATH\ACCTWCLT,;
                                                                                  &g_AMS_PATH\ACCTREF1,;
                                                                                  &g_AMS_PATH\ACCTREF2
                                                                     @ 22,mcol say '.'
                                                                     mcol := col()

                                                                     IF NETUSE( '&g_AMS_PATH\CA_SEC',.f.,5)
                                                                        SET INDEX TO &g_AMS_PATH\CA_SEC
                                                                        @ 22,mcol say '.'
                                                                        mcol := col()

                                                                        IF NETUSE( '&g_AMS_PATH\CA_OBT',.f.,5)
                                                                           SET INDEX TO &g_AMS_PATH\CA_OBT
                                                                           @ 22,mcol say '.'
                                                                           mcol := col()
                                                                           mretval := .t.
																		   
	                                                                        IF NETUSE( '&g_CIS_PATH\SIGNERS',.f.,5)
	                                                                           SET INDEX TO &g_CIS_PATH\SIGNERS
	                                                                           @ 22,mcol say '.'
	                                                                           mcol := col()
	                                                                           mretval := .t.

		                                                                        IF NETUSE( '&g_CIS_PATH\Indvcntc',.f.,5)
		                                                                           SET INDEX TO &g_CIS_PATH\Indvcntc
		                                                                           @ 22,mcol say '.'
		                                                                           mcol := col()
		                                                                           mretval := .t.
																				   
			                                                                        IF NETUSE( '&g_CIS_PATH\Indvinfo',.f.,5)
			                                                                           SET INDEX TO &g_CIS_PATH\Indvinfo
			                                                                           @ 22,mcol say '.'
			                                                                           mcol := col()
			                                                                           mretval := .t.

			                                                                        ENDIF
		                                                                        ENDIF
	                                                                        ENDIF
                                                                        ENDIF
                                                                     ENDIF
                                                                  endif
                                                               endif
                                                            endif
                                                        endif
                                                     endif
                                                  endif
                                               endif
                                            endif
                                         endif
                                      endif
                                   endif
                                endif
                             endif
                          endif
                        endif
                     endif
                  endif
               endif
            endif
         ENDIF
// EVR   endif
      endif
   endif
   restscreen ( ,,,,cscr )

return mRETVAL
*****************************************
*
static function _BR_rights ( cusercode )   // ABB 10.12.2004
*****************************************
    local lretval := .f.,nrec := axbranch->(recno())

    if axbranch->(dbseek(alltrim(cusercode)))

       do while !axbranch->(eof()) .and. ;
                alltrim(axbranch->user_id) == alltrim(cusercode)

          *if alltrim(axbranch->brcode) == alltrim(Oticket->brcode)     && RED 031005 REPLACED BY BELOW
          IF ALLTRIM(AXBRANCH->BRCODE) == ALLTRIM(CAHEADER->BRCODE)
             lretval := .t.
          endif

          axbranch->(dbskip(+1))
       enddo

    endif

    axbranch->(dbgoto(nrec))

return lretval

****************************************************
*
static function _getClwin ( mclntcode,nneword,noldntx)           // abb 10.18.2004
****************************************************
   local nntx := Client->(indexord()),ccursor := setcursor()
   local cclntname := space(len(Client->fullname))
   local nretval   := 0
   LOCAL nCLNTCODE := SPACE(10)

   Client->(dbsetorder(nneword))
   cscr := savescreen ( ,,, )

   @ 10,10 clear to 12,52
   @ 10,10 to 12,52
   *@ 11,12 say 'Client Name  ' get cclntname pict '@!S20'
   @ 11,16 say 'Client Code  '
   @ 11,30 GET nCLNTCODE pict '@R 999-99-99999' VALID ( EMPTY(nCLNTCODE) .OR. IF(VALBRCODE(LEFT(nCLNTCODE,3),g_USER_ID),.T.,EVAL({|| nCLNTCODE := SPACE(10),.F.}) ) )

   setcursor(3)
   read
   setcursor(0)

   restscreen ( ,,,,cscr )

   if lastkey() != K_ESC

      *if Client->(dbseek(alltrim(cclntname)))
      IF EMPTY(nCLNTCODE)
         nRETVAL := 0
      ELSE
         IF CLIENT->(DBSEEK(ALLTRIM(nCLNTCODE)))  && RED REMOVED 'sBRCODE+
            nretval := Client->(recno())
         else
            error ( 'Client not found' )
            nCLNTCODE := SPACE(10)
         endif
      ENDIF

   endif

   Client->  ( dbsetorder(noldntx) )
   setcursor ( ccursor)

return nretval

*************************************
*  Desc ¯
*
static function _dispcrd ( mclntcode )
*************************************
   local mcred := {'UNCLASSIFIED','LOANS ESP. MENTIONED','SUBSTANDARD SECURED','DOUBTFUL','LOSS','SUBSTANDARD UNSECURED'}
   local mretval := space( len ( Corpinfo -> CREDRISK )+ 10 )
   local mrisk

   if Corpinfo -> ( dbseek( Caheader->brcode+mclntcode ) )

      mrisk := alltrim ( Corpinfo -> CREDRISK )

      do case
         case mrisk == 'I'
            mretval := mrisk + ' ' +  mcred [1]
         case mrisk == 'II'
            mretval := mrisk + ' ' +  mcred [2]
         case mrisk == 'III'
            mretval := mrisk + ' ' +  mcred [3]
         case mrisk == 'IV'
            mretval := mrisk + ' ' +  mcred [4]
         case mrisk == 'V'
            mretval := mrisk + ' ' +  mcred [5]
         case mrisk == 'VI'
            mretval := mrisk + ' ' +  mcred [6]
      endcase

   endif

return mretval

**************************************************
*
static function _is_downpay_valid(mdownpay,npercent,mpurcamt,mappval)
**************************************************
   local lretval := .f., nactualpercent := 0



   if mappval > mpurcamt                         // whichever is lower
      nactualpercent :=  ( mdownpay / mpurcamt ) * 100
   else
      nactualpercent :=  ( mdownpay / mappval  ) * 100
   endif

   if nactualpercent >= npercent
      lretval := .t.
   endif

return lretval

*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
*³ Function......: RATE( nPrincipal, nAmort, nTerm, nType )                   ³Û
*³ Description...: Compute Rate                                               ³Û
*ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´Û
*³    Arguments: nPrincipal - Amount Borrowed                                 ³Û
*³               nAmort     - Monthly Amortization                            ³Û
*³               nTerm      - Terms in Month(s)                               ³Û
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙÛ
*  ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
FUNCTION NETRATE( nCapital, nAmort, nTerm, nType )
   local nRate := 1.0    // return value
   local nTemp           // temporary rate
   local dAux, n1, n2
   local dEpsilon := 0.00001
   local dScale   := 1.0

   //DEFAULT nType := 0
   nType := nValToNum( nType )

   while (nRate < 1020.0 ) /* maximum anual rate */
      nTemp := nRate *  0.000833333 // ( 0.01 / 12 )
      if nType == 2
         n1 := (1.0 + nTemp) ** nTerm
      else
         n1 := (1.0 + nTemp) ** (nTerm - 1)
      endif
      n2 := ( (1.0 + nTemp) ** nTerm ) - 1.0

      dAux := nCapital * ( (n1 * nTemp) / n2 )
      if ( dAux == 0.0 )
         Error( "You entered an invalid value." )
         Return 0
      endif

      if (dAux > nAmort)
         nRate := nRate - dScale
         dScale := dScale * 0.10
         if ( dAux - nAmort) < dEpsilon
            exit
         endif
      else
         nRate := nRate + dScale
      endif
   enddo
   
RETURN nRate

*
*                      End of the program ( amsm0100.prg )
*
