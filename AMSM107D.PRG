/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   program id.........:  amsm107d.prg                                         ³
³   description........:  Stipulated Loss Value                                ³
³   author.............:  Ariel B. Bulan                                       ³
³   date...............:  11:58am 17-May-1995                                  ³
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

#xtrans ass_slv(<mslv>,<macctno>) => eval ({|| Slv->( dbseek(<macctno>) ),;
                                        Slv->( dbeval( {|| if (!Slv->(deleted()),;
                                                                   aadd( <mslv>,{ SLV->BRCODE+Slv->ACCTNO ,;      && RED 112504 ADDED 'SLV->BRCODE+
                                                                                  Slv->SLVNO  ,;
                                                                                  Slv->SLVALUE,;
                                                                                  'Initial'    ;
                                                                                };
                                                                       ),nil;
                                                              );
                                                        },,;
                                                        {|| SLV->BRCODE+Slv->ACCTNO == <macctno> .and.;
                                                            !Slv->(eof()) ;
                                                        };
                                                      );
                                             );
                                      })

#xtrans dump_rec( <macctno>,<mslvno>,<mslvalue> ) => eval ({|| SLV->BRCODE := LEFT(<macctno>,3)  ,;
                                                               Slv->ACCTNO := RIGHT(<macctno>,14),;
                                                               Slv->SLVNO  := <mslvno>   ,;
                                                               Slv->SLVALUE:= <mslvalue> ,;
                                                               Slv->(dbcommit())          ;
                                                          })

#xtrans sav_slv( <mslv>,<macctno>,<mslvno>,<mslvalue>,<mstatus> ) => ;
                  eval({|| aeval( <mslv>, {|x,y| <mslvno>   := x\[2] ,;
                                                 <mslvalue> := x\[3] ,;
                                                 <mstatus>  := x\[5] ,;     && RED 061805    <mstatus>  := x\[4] ,;
                                                 y := if(Slv->(dbseek(<macctno>+str(<mslvno>,1))),'R','A'),;
                                                 if( Slv->(netlock(y,0)) ,;
                                                    if ( <mstatus> != 'Deleted' ,;
                                                         dump_rec( <macctno>,<mslvno>,<mslvalue> ) ,;
                                                         Slv->(dbdelete())  ;
                                                       ),;
                                                    nil;
                                                  ),;
                                                Slv->(dbunlock()) ;
                                          };
                                );
                      })

***********************************
function assign_slv( mslv,macctno )
***********************************
   ass_slv( mslv, macctno )
return nil
**********************************
function save_slv ( mslv,macctno )
**********************************
   local mslvno,mslvalue,mstatus
   sav_slv( mslv,macctno,mslvno,mslvalue,mstatus )
return nil
************************************
function browse_slv( mslv_, macctno )
************************************
   local cb, mscreen := savescreen( ,,, ), mcolor := setcolor( setcolor() )
   local mcursor := setcursor( setcursor() ), mdbf_ := savedbf() 
   local mfile := 'slv' + padl( gfrand( 255 ), 5, '0' ), c := 1
   local keys_ := { '<Ins>\-Add ', '<F2>\Edit ', '<Del>\ ', '<Esc>\' }
   local tbcol_ := { tbcolumnnew( 'N§'                   , { || tran( ( mfile )->slvno  ,'9' )              } ),;
                     tbcolumnnew( 'Stipulated Loss Value', { || tran( ( mfile )->slvalue,'999,999,999.99' ) } ) }
   private mdbf := mfile, _macctno := macctno

   setcursor( 0 )   
   dbcreate( mfile, Slv->( dbstruct() ) )
   netuse( mfile, .t., 0 )
   dbcreateind( mfile, 'slvno', { || slvno } )
   /*                            && RED 0617
   aeval( mslv_, { | s_ | ( mfile )->( dbappend() )    ,;
                          ( mfile )->acctno  := s_[ 1 ],;
                          ( mfile )->slvno   := s_[ 2 ],;
                          ( mfile )->slvalue := s_[ 3 ] } )
   */
   AEVAL( mSLV_, { | S_ | ( mFILE )->( DBAPPEND() )    ,;
                          ( mFILE )->ACCTNO  := S_[ 1 ],;
                          ( mFILE )->SLVNO   := S_[ 2 ],;
                          ( mFILE )->SLVALUE := S_[ 3 ],;
                          ( mFILE )->BRCODE  := S_[ 4 ]} )

   ( mfile )->( dbcommit() )                     
   mslv_ := {}
   ( mfile )->( dbgotop() )
   cb := tb_maker( tbcol_, keys_, 11, 10, 20, 41,, ( mfile )->( lastrec() ), .f. )
   ( mfile )->( tb_stabilizer( cb, { | o, k | case107d( o, k ) } ) )
   set delete off
   ( mfile )->( dbgotop() )
   ( mfile )->( dbeval( { || aadd( mslv_, { ( mfile )->acctno ,;
                                            ( mfile )->slvno  ,;
                                            ( mfile )->slvalue,;
                                            ( mFILE )->BRCODE ,;           && RED 061705 ADDED
                             if( !( mdbf )->( delete() ), 'Initial', 'Deleted' ) } ) },,;
                        { || !( mfile )->( eof() ) } ) )     
   set delete on                     
   ( mfile )->( dbclearind() )                        
   ( mfile )->( dbclosearea() )
   __mrelease( '*', .t. )
   ferase( ( mfile ) + '.dbf' )
   ferase( ( mfile ) + '.ntx' )
   inkey( .5 )

   restdbf( mdbf_ )
   setcolor( mcolor )
   setcursor( mcursor )
   restscreen( ,,,, mscreen )
   inkey( .5 )
return( nil )   

////
static function case107d( cb, mkey )
local mreturn := .t.
memvar mdbf

do case
   case mkey == K_INS
        update_slv( 'A' )
        tb_refresh( cb, 'a' )
   case mkey == K_F2
        if ( mdbf )->slvno == 0
           error( 'Nothing to Edit!' )
        else
           update_slv( 'R' )
           tb_refresh( cb, 'c' )
        endif   
   case mkey == K_DEL
        if ( mdbf )->slvno == 0
           error( 'Nothing to Delete!' )        
        else
           if confirm( 'Delete SLV N§ ' + tran( ( mdbf )->slvno, '9' ) + '?' )
              ( mdbf )->( dbdelete() )
              ( mdbf )->( dbskip( +1 ) )  
              if ( mdbf )->( eof() )
                 ( mdbf )->( dbskip( -1 ) )
              endif
              tb_refresh( cb, 'a' )
           endif
        endif
   otherwise
        mreturn := !mreturn     
endcase
return( mreturn )
**************************************************
static function update_slv( mwhat )
**************************************************
memva mdbf, _macctno
local mretval := .f., mcolor := setcolor( setcolor() )
local mrecno := ( mdbf )->( recno() ), mslvno, mslvalue
local mscreen := savescreen( ,,, )
   
if mwhat == 'A'
   ( mdbf )->( dbgoto( lastrec() + 1 ) )
   center( 24, 'w+/n', '® Add Record ¯' )
else
   center( 24, 'w+/n', '® Edit Record ¯' )
endif
mslvno := ( mdbf )->slvno; mslvalue := ( mdbf )->slvalue
fshadow( 14, 36, 17, 60, 2, 'n/w' )
setcolor( 'bg+/w, w+/n,,, gr+/w' ) 
@ 15, 37 say 'SLV N§ ' get mslvno   pict '9' when mwhat == 'A' valid chk_mslvno( mslvno )
@ 16, 37 say ' Value ' get mslvalue pict '999,999,999.99'
setcursor( 3 )
read
setcursor( 0 )
if lastkey() != K_ESC
   if ( mdbf )->( netlock( mwhat, 0 ) )
      ( mdbf )->acctno  := RIGHT(_macctno,14)
      ( mdbf )->slvno   :=  mslvno
      ( mdbf )->slvalue :=  mslvalue
      ( mdbf )->( dbunlock() ) 
   endif
      ( mdbf )->( dbcommit() )  
else
   ( mdbf )->( dbgoto( mrecno ) )
endif
setcolor( mcolor )
restscreen( ,,,, mscreen )
return mretval
***************************************
static function chk_mslvno( mslvno )
***************************************
   local mretval := .t.
   memvar mdbf
   
   if ( mdbf )->( dbseek( mslvno ) )
      error( 'SLV N§ already Exists!' )
      mretval := .f.
   endif
return( mslvno > 0 .and. mretval )
*************************************
function print_slv( macctno, nusdrate )
*************************************
   local mrow := prow()+2 ; mcol := 37
   @ mrow, 13 say 'SLV                   : '
   if Slv->( dbseek(macctno) )
      Slv->( dbeval({|| devpos(mrow,mcol)    , devoutpict(Slv->SLVNO,'9') ,;
                        devpos(mrow,pcol())  , devout( ' Ä ' ) ,;
                        devpos(mrow,pcol()+1), devout( trans(Slv->SLVALUE,'999,999,999.99' )) + if(round(nusdrate,2) > 0,' = US$ '+ Tran(round(Slv->SLVALUE / nusdrate,2),'999,999.99') ,space(1))  ,;
                        mrow++;
                    },,;
                    {|| SLV->BRCODE+Slv->ACCTNO == macctno .and. !Slv->(eof()) } ))
   endif
return nil
*
*                     End of the program ( amsm107d.prg )
*
