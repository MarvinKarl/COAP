/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³   program id.........:  amsm300d.prg                                 ³
 ³   description........:  loan offering ticket ( printing )            ³
 ³   author.............:  Ariel B. Bulan                               ³
 ³   date...............:  03:26pm 13-Oct-1994                          ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³                         u p d a t e s                                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³        Who        ³     When      ³               Why                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

********************************************
*
/*
****************************
function savedbf ( mARNAME )
****************************

return( { select(), indexord(), recno() } )

****************************
 function restdbf( mARNAME )
****************************

IF !EMPTY(mARNAME[1]) .AND. mARNAME[1] > 0
   dbselectarea ( mARNAME [1] )
   dbsetorder   ( mARNAME [2] )
   dbgoto       ( mARNAME [3] )
ENDIF
return(  nil )
*/
**************************************************
*
function disp_committee( mtotal, isca, mlimitrow, mcatype )
**************************************************
   memvar members , fullname , msignees , mcomname
   memvar members2, fullname2, msignees2, mcomname2, mtotal2
   local  moutstanding     , mtotcred
   local  i, mlastcomm
   local  members_str:='', membersstr  := '', mspaces := 0  , mspaces2 := 0 , mline_length
   isca := if ( isca == nil, .f., isca )
   
   do case
      case prow() >= mlimitrow
           fejectpause()
           if ( !isca, dispfirsthead( .t. ), nil )
      otherwise
           for i:= prow() to 47 ; devpos ( i, 0 ) ; devout ( ' ' ) ; next i
   endcase
   if isca
      if alltrim ( mcatype ) == '4'
         mlastcomm := alltrim ( Comcodes -> COMCODE )
         if mlastcomm == Parametr -> RISK_COMM .and. mlastcomm != Parametr -> BOARD_COMM
           Comcodes -> ( dbseek ( Parametr -> CREDCOM ) )
           mline_length := 65
           mtotal2      := Comcodes->MINIMUM
           if empty ( mcomname2 )
              check_committee( mtotal2, @mcomname2, members2, fullname2, @msignees2 )
           endif
           setfont ( upper("condensed") )
           @ prow() +1 , 000       say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
           @ prow() +1 , 000       say '³'
           @ prow()    , pcol()+28 say mCOMNAME2
           @ prow()    , pcol()+07 say '³'
           @ prow()    , pcol()+20 say mCOMNAME
           @ prow()    , pcol()+16 say '³'
           @ prow() +1 , 000       say 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
           determine_spacing ( members , mline_length, @members_str, @mspaces , msignees  )
           determine_spacing ( members2, mline_length, @membersstr2, @mspaces2, msignees2 )
           for i := 1 to 3
               @ prow() +1 , 000   say '³'
               @ prow()    , 066   say '³'
               @ prow()    , 133   say '³'
           next i
           @ prow()+1 , 000        say '³'
           @ prow()   , pcol()     say membersstr2
           @ prow()   , 066        say '³'
           @ prow()   , pcol()     say members_str
           @ prow()   , 133        say '³'
           @ prow() +1 , 000 say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
           return nil
         endif
      endif
   endif
   do case
      case alltrim ( mcomname ) == default_committee()
           mline_length := 132
           setfont ( upper( "condensed") )
           @ prow() +1 , 000       say  'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
           @ prow() +1 , 000       say  '³'
           @ prow()    , ( 134 - len ( alltrim( mCOMNAME ) ) ) / 2 say mCOMNAME
           @ prow()    , 134       say +'³'
           @ prow() +1 , 000       say  'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
           determine_spacing ( members, mline_length, @members_str, @mspaces, msignees )
           for i := 1 to 3
               @ prow() +1 , 000   say '³'
               @ prow()    , 134   say '³'
           next i
           @ prow() +1 , 000       say '³'
           @ prow()    , pcol()    say members_str
           @ prow()    , 134       say '³'
           @ prow() +1 , 000       say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
      case mTOTAL   <=  Comcodes->MINIMUM
           mline_length := 132
           setfont ( upper("condensed") )
           @ prow() +1 , 000       say  'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
           @ prow() +1 , 000       say  '³'
           @ prow()    , ( 134 - len ( alltrim( mCOMNAME ) ) ) / 2 say mCOMNAME
           @ prow()    , 134       say +'³'
           @ prow() +1 , 000       say  'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
           determine_spacing ( members, mline_length, @members_str, @mspaces, msignees )
           for i := 1 to 3
               @ prow() +1 , 000   say '³'
               @ prow()    , 134   say '³'
           next i
           @ prow() +1 , 000       say '³'
           @ prow()    , pcol()    say members_str
           @ prow()    , 134       say '³'
           @ prow() +1 , 000       say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
      case mTOTAL   >=  Comcodes->MAXIMUM
           mline_length := 65
           mtotal2      := Comcodes->MINIMUM
           if empty ( mcomname2 )
              check_committee( mtotal2, @mcomname2, members2, fullname2, @msignees2 )
           endif
           setfont ( upper("condensed") )
           @ prow() +1 , 000       say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
           @ prow() +1 , 000       say '³'
           @ prow()    , pcol()+28 say mCOMNAME2
           @ prow()    , pcol()+07 say '³'
           @ prow()    , pcol()+20 say mCOMNAME
           @ prow()    , pcol()+16 say '³'
           @ prow() +1 , 000       say 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
           determine_spacing ( members , mline_length, @members_str, @mspaces , msignees  )
           determine_spacing ( members2, mline_length, @membersstr2, @mspaces2, msignees2 )
           for i := 1 to 3
               @ prow() +1 , 000   say '³'
               @ prow()    , 066   say '³'
               @ prow()    , 133   say '³'
           next i
           @ prow()+1 , 000        say '³'
           @ prow()   , pcol()     say membersstr2
           @ prow()   , 066        say '³'
           @ prow()   , pcol()     say members_str
           @ prow()   , 133        say '³'
           @ prow() +1 , 000 say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
   endcase
return nil
*********************
*
function next_page()
dispfirsthead( .t. )
return( nil )
**************************************************************************************
*
function determine_spacing ( members, mline_length, members_str , mspaces, msignees )
**************************************************************************************
    get_co_members( members, @members_str, 0       )
    mspaces     := ( mline_length - len  ( members_str ) ) / ( msignees + 1 )
    members_str := ''
    get_co_members( members, @members_str, mspaces )
return nil
***************************************************************
*
static function get_co_members( members, members_str, mspaces )
***************************************************************
    aeval ( members , { |member| if( left( member, 1)  == 'û', add2str( @members_str, member, mspaces ) , Nil )  })
return nil
****************************************
*
function default_committee()
****************************************
   local mDBF := savedbf ( mDBF )
   Comcodes->( dbseek ( Parametr->CREDCOM ) )
   restdbf ( mDBF )
return alltrim( Comcodes->COMNAME )
********************************************
*
static function dispfirsthead( misnextpage )
********************************************
   local  mHEADMESS := 'OFFERING TICKET'
   local  mLASTDBF  := savedbf( mLASTDBF )
   memvar gCOMPANY, gSYS_NAME, mPAGE, mtrandate

   misnextpage := if ( misnextpage == nil, .f. , .t. )

   if !misnextpage
      setfont( "ELITE" )
      devpos ( prow()+1, 00 ) ; devout( gcompany )
      devpos ( prow()  , 71 ) ; devout( gsys_name )
      devpos ( prow()+1, 00 ) ; devout( mheadmess )
      devpos ( prow()  , 77 ) ; devout( date() )
      devpos ( prow()  , pcol()+1) ; devout( time() )
      setfont( 'PICA' )
      devpos ( prow()+1, 00 ) ; devout( repl ( 'Ä', 80 ) )
      devpos ( prow()+1, 10 ) ; devout( 'OT Number : ' + (alias())->OTNUMBER )
      devpos ( prow()  , 50 ) ; devout( 'OT Date   : ' + dtoc( (alias() )-> OTDATE) )
      devpos ( prow()+1, 00 ) ; devout( repl ( 'Ä', 80 ) )
      devpos ( prow()+1, 00 ) ; devout( 'Client Number : ' )
      devpos ( prow()  , pcol() )    ; devoutpict ( (alias())->CLNTCODE, '@R 99-99999' )
      devpos ( prow()  , pcol()+10 ) ; devout     ( 'Industry : '+dispindustry ( CLIENT->INDCODE ) )
      devpos ( prow()+1, 00 )        ; devout     ( 'Client Name   : '+dispclntname( (alias())->BRCODE+(alias())->CLNTCODE, 40 ) )
      if CLIENT->CLTYPE == '1'
         @ prow()+1 , 00 say  'Credit Risk   : ' + dispCRD ( ( alias() )->CLNTCODE )
      endif
      devpos ( prow()+1, 00 ) ; devout ( 'Address       : ' )
      dispaddress( CLIENT->ADDRESS1, prow()   )
      dispaddress( CLIENT->ADDRESS2, prow()+1 )
      dispaddress( CLIENT->ADDRESS3, prow()+1 )
    else
       setfont ( 'PICA' )
       mPAGE++
       devpos ( prow()+1, 00 ) ; devout( repl ( 'Ä', 80 ) )
       devpos ( prow()+1, 00 ) ; devout( 'OT Number      : ' + (alias())->OTNUMBER )
       devpos ( prow()  , 70 ) ; devout( 'Page : '+transform( mPAGE, '999') )
       devpos ( prow()+1, 00 ) ; devout( 'Client Name    : '+dispclntname( (alias())->BRCODE+(alias())->CLNTCODE, 40 ) )
   endif
   devpos ( prow()+1, 00 ) ; devout( repl ( 'Ä', 80 ) )
   restdbf( mLASTDBF )
return( nil )
*******************************************************
*
static function add2str( members_str, member, mspaces )
*******************************************************
     members_str := members_str +  space ( mspaces ) + alltrim ( substr( member,3,15 ) )
return( nil )
**********************************************
*
static function dispaddress( maddress, mprow )
**********************************************
   if !empty ( maddress )
      @ mprow, 16 say maddress
   endif
return( nil )
