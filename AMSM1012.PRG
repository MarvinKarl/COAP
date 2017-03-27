/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³   colf-iis -- account management system                                      ³
³   program idúúú amsm1012                                                     ³
³   descriptionúú transaction entries ( GL Codes ) table                       ³
³   authorúúúúúúú gener c. singson                                             ³
³   dateúúúúúúúúú 4:28:21ú67pm úú 5-10-95                                      ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³                             u p d a t e s                                    ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³        who        ³       when        ³               why                    ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

////
#include 'inkey.ch'
#include 'colf.ch'

////
local mlogic 
memva AX_LEVEL, gUSER_ID

if !chkpass( procname(), AX_LEVEL, gUSER_ID ) 
else
   begin sequence
         Open1012()
         Main1012()
   recover using mlogic
         if mlogic
            dbcloseall()         
            __mrelease( '*', mlogic )
         endif   
   end sequence
endif   
return

////
static function Main1012()
local mcolor := setcolor(), mscreen := savescreen( ,,, ), mlogic := .t.
local mbanner := 'Transaction Entries Table Maintenance', cb
local keys_  := { '<Ins>\-Add ', '<F2>\Edit ', '<F3>\Color ', '<Del>\ ', '<Esc>\' }   
local tbcol_ := { tbcolumnnew( 'JV Type'    , { || AMSGL->jvtype+'-'+fType1012( Amsgl->jvtype    ) } ),;
                  tbcolumnnew( 'Class'   , { || fDrcr1012( Amsgl->drcr      ) } ),;
                  tbcolumnnew( 'GL Code/ Name'    , { || fFind1012( AMSGL->BRCODE+Amsgl->glcode    ) } ),;
                  tbcolumnnew( 'Formula' , { || Amsgl->formula } )               ,;
                  tbcolumnnew( 'Facility', { || Amsgl->Docfclty+'-'+fFclty1012( Amsgl->Docfclty ) } ) }


Amsgl->( dbgotop() )
Amsgl->(dbseek(g_PAR_BRCH))
cb := __tb_maker( tbcol_, keys_,,,,, mbanner, Amsgl->( lastrec() ),.f.,g_PAR_BRCH,{||Amsgl->brcode == g_PAR_BRCH} )
__tb_stabilizer( cb, { | o, k | case1012( o, k ) } )
setcolor( mcolor )
restscreen( ,,,, mscreen )
break( mlogic )
return( nil )

////
static function case1012( cb, mkey )
local mreturn := .t.

do case
   case mkey == K_INS
        if chkpass( 'A', AX_LEVEL, gUSER_ID )
            if fGete1012( 'a' )
               tb_refresh( cb, 'a' )
            endif
        endif
   case mkey == K_DEL
        if CURRBRCH(AMSGL->BRCODE) .AND. chkpass( 'D', AX_LEVEL, gUSER_ID )
           IF VALBRCODE(AMSGL->BRCODE,g_USER_ID)
              if Amsgl->( dbempty() )
                 if Amsgl->( netlock( 'R', 5 ) )
                     if fEras1012()
                        tb_refresh( cb, 'a' )
                     endif
                    Amsgl->( dbunlock() )
                 endif
              endif
           ENDIF
        endif   
   case mkey == K_F2
        if CURRBRCH(AMSGL->BRCODE) .AND. chkpass( 'E', AX_LEVEL, gUSER_ID )
           IF VALBRCODE(AMSGL->BRCODE,g_USER_ID)
              if Amsgl->( dbempty() )
                 if Amsgl->( netlock( 'R', 5 ) )
                    if fGete1012( 'e' )
                       tb_refresh( cb, 'c' )
                    endif
                    Amsgl->( dbunlock() )
                 endif
              endif
           ENDIF
        endif
   otherwise
        mreturn := !mreturn
endcase                 
return( mreturn )

////
static function fType1012( mcode )
/// DBP replaced with OL (6)       jbs 10.25.2002
mcode := alltrim(mcode)
return( padr( if( mcode == '1', 'LCR',;
              if( mcode == '2', 'ML' ,;
              if( mcode == '3', 'IPP',;
              if( mcode == '4', 'RP' ,;
              if( mcode == '5', 'AUTOL',;
              if( mcode == '6', 'OL',;
              if( mcode == '7', 'CML',;
              if( mcode == '8', 'DSTAMP',;
              if( mcode == '9', 'OTHER',;
              if( mcode == '11', 'OL-PLOANS',;
              if( mcode == '0', 'OLOALP', '' ) ) ) ) ) ) ) ) ) ) ), 6 ) )
			  
static function fFclty1012( mcode )
mcode := alltrim(mcode)
return( padr( if( mcode == '1', 'LCR',;
              if( mcode == '2', 'ML' ,;
              if( mcode == '3', 'IPP',;
              if( mcode == '4', 'RP' ,;
              if( mcode == '5', 'AUTOL',;
              if( mcode == '6', 'OL',;              
              if( mcode == '7', 'CML',;
              if( mcode == '0', 'OLOALP','') ) ) ) ) ) ) ), 6 ) )
////
static function fDrcr1012( mcode )
return( padr( if( mcode == '1', 'DEBIT', if( mcode == '2', 'CREDIT', '' ) ), 6 ) )

////
static function fFind1012( mcode )
return( eval( { | x | Glcode->( dbseek( mcode ) ),;
        x := transform( substr(mcode,4,14), '@R 999-99-99-9999' ),;     && RED 11122004 ADDED '999-'
        x + ' ' + padr( Glcode->glname, 35 ) } ) )             && RED 11122004 REPLACED 36 WITH 45

////
static function fGete1012( addedit )
local mrec := recno(), mtrue := .f., arr_ := fInit1012( addedit )
local ach_1_ := { 'LCR   -1', 'ML    -2', 'IPP   -3', 'RP    -4',;
                  'AUTOL -5', 'OL    -6', 'CML   -7', 'DSTAMP-8', 'OLOALP-9' }
local ach_2_ := { 'DEBIT -1', 'CREDIT-2' }
local getlist := {}, mscreen := savescreen( ,,, ), mcolor := setcolor()

center( maxrow(), 'w+/n', '® ' + if( addedit == 'a', 'Add', 'Edit' ) + ' ¯' )
if addedit $ 'e'
  fShadow( 8, 5, 14, 72, 2, 'n/bg' )
  setcolor( 'n/bg, w+/n,,, gr+/bg' )
  @  9, 6 say '   Account Type ¯'    
  @  9, 24 say tran( arr_[ 1 ], '@R 9' ) + ' ' + fType1012( arr_[ 1 ] ) 
else
  fShadow( 8, 5, 14, 72, 2, 'n/bg' )
  setcolor( 'n/bg, w+/n,,, gr+/bg' )
  @  9, 6 say '   Account Type ¯' get arr_[ 1 ] picture '@R 9'               ;
          when !empty( eval( { || arr_[ 1 ] := subs( ach_1_[ max( fAch1012( 9,;
                          24, 15, 31, ach_1_, arr_[ 1 ] ), 1 ) ], 8, 1 ) } ) );
          valid eval( { || fKind1012( ach_1_, arr_[ 1 ] ), !if( arr_[ 1 ] $   ;
                          '1_2_3_4_5_6_7_8_9' .and. !empty( arr_[ 1 ] ), .f., .t. ) } )
endif
  
@ 10, 6 say '   Account Code ¯' get arr_[ 2 ] picture '@R 999-999-99-99-9999'     ;
        when  !empty( arr_[ 2 ] := eval( { || fOrdr1012( addedit, arr_[ 2 ] ) } ) );
        valid eval( { || fAcct1012( arr_[ 2 ] ), if( arr_[ 2 ] $ repl( '0', 9 ), !.t., !.f. ) } )
@ 11, 6 say '  Account Class ¯' get arr_[ 3 ] picture '@R 9'                ;
        when !empty( eval( { || arr_[ 3 ] := subs( ach_2_[ max( fAch1012( 11,;
                       24, 14, 31, ach_2_, arr_[ 3 ] ), 1 ) ], 8, 1 ) } ) )  ; 
        valid eval( { || fKind1012( ach_2_, arr_[ 3 ] ), !if( arr_[ 3 ] $    ;
                               '1_2' .and. !empty( arr_[ 3 ] ), .f., .t. ) } )
@ 12, 6 say 'Account Formula ¯' get arr_[ 4 ] picture '@!S48' valid !empty( arr_[ 4 ] )
@ 13, 6 say '  Facility Code ¯' get arr_[ 6 ] picture '9' valid arr_[ 6 ] $ ' _1_2_3_4_5_6_7_9'

setcursor( 3 )
setkey( K_ESC, { || fescape( 'Abort?' ) } )
read
setkey( K_ESC, nil )
setcursor( 0 )

if lastkey() != K_ESC
   if confirm( 'Are all entries correct?' )
      MSGWIN(9,24,'Saving','W+/BG','R*/BG','ON')

      if netlock( if( addedit == 'a', 'A', 'R' ), 0 )
         _field->Amsgl->jvtype  := if(arr_[ 1 ] == '9','0',arr_[ 1 ])
         _field->Amsgl->glcode  := RIGHT(arr_[ 2 ],11)
         _field->Amsgl->drcr    := arr_[ 3 ]
         _field->Amsgl->formula := arr_[ 4 ]
         _field->Amsgl->docfclty:= arr_[ 6 ]
         _field->Amsgl->BRCODE  := IF( ADDEDIT == 'a', g_PAR_BRCH, arr_[ 7 ])
         dbunlock()
         dbcommit()
      endif

      MSGWIN(9,24,'Saving','W+/BG','R*/BG','OFF')
      mtrue := !mtrue
   endif   
else
   inkey( .5 )
   dbgoto( mrec )
endif
restscreen( ,,,, mscreen )
setcolor( mcolor )
return( mtrue )

////
static function fKind1012( arr_, mcode )
local mwhich := ascan( arr_, { | v | subs( v, -1, 1 ) == mcode } )

@ row(), 26 say padr( if( mwhich < 0, '', arr_[ mwhich ] ), 6 ) color 'n/bg'           // if( mwhich < 1, '', arr_[ mwhich ] ), 6 ) color 'n/bg'
return( nil )

////
static function fAcct1012( mcode )
@ row(), 43 say eval( { || Glcode->( dbseek( mcode ) ),;
                     padr( Glcode->glname, 29 ) } ) color 'n/bg'
return( nil )

////
static function fOrdr1012( addedit, pcode )
local mdbf, mcode, mname, mcursor := setcursor( setcursor() )
LOCAL nORGORD := GLCODE->(DBSETORDER())
local col_ := {                                                          ;
                tbcolumnnew( 'Account Title',                            ;
                  { || transform( Glcode->glname, '@!' ) } ),            ;
                tbcolumnnew( 'Code'         ,                            ;
                  { || transform( Glcode->Brcode+Glcode->glcode, '@R 999-999-99-99-9999' ) } ),;
                tbcolumnnew( 'Class'        ,                            ;
                  { || if( Glcode->gldrcr $ '2', 'Cr', 'Dr' ) } )        ;
              }

setcursor( 0 )
while .t.
      eval( { || mdbf := stackin(), dbselectar( 'Glcode' ),ordsetfocus( 1 ) } )

      GLCODE->(DBSETORDER(2))
      mcode := eval( { || fLook_ONLINE( .t., 'Glcode',pcode,'Account Name',;
                          2, 6, 1, 3, 1, .f., col_,,,g_AMS_PATH, .t. ) } )
      GLCODE->(DBSETORDER(nORGORD))

      eval( { || ordsetfocus( 1 ), dbseek( mcode ), stackout( mdbf ) } )

      if lastkey() == K_ESC
         mcode := if( addedit $ 'a', repl( '0', 11 ), pcode )
         exit
      endif

      if fGoodlevel( 'Glcode',1,Glcode->gLevel )
         exit
      else
         waiton( 'Unable code!',, 'w+/r' )   
         inkey( .2 )
         waitoff()
      endif
enddo                                       
setcursor( mcursor )
return( mcode )

////
static function fAch1012( _1, _2, _3, _4, ma_, mb_ )
local max, mscreen, mesc := setkey( K_ESC, nil ) 
local mxx := 1, mc_, md_ := 1 

mscreen := savescreen( _1, _2, _3 + 1, _4 + 2 )
fShadow( _1, _2, _3, _4, 2, 'n/w' )
if ( mxx := ascan( ma_, { | v | subs( v, 8, 1 ) == mb_ } ) ) > 0
   mc_ := mxx      
else         
   mc_ := mxx  
endif   
max := achoice( _1 + 1, _2 + 1, _3 - 1, _4 - 1, ma_,,, mc_, md_ ) 
restscreen( _1, _2, _3 + 1, _4 + 2, mscreen ) 
setkey( K_ESC, mesc )
return( max ) 

////
static function fEras1012()
local mtrue := .f.

if confirm( 'Delete?' )
   MSGWIN(10,35,'Deleting','W+/BG','R*/BG','ON')
   if Amsgl->( netlock( 'R', 0 ) )
      Amsgl->( dbdelete() )
      Amsgl->( dbskip( +1 ) )
      if Amsgl->( eof() )
         Amsgl->( dbgobottom() )
      endif  
      mtrue := !mtrue
      Amsgl->( dbunlock() )
   endif
   MSGWIN(10,35,'Deleting','W+/BG','R*/BG','OFF')
endif   
return( mtrue )

////
static function fInit1012( addedit )
loca arr_, c

arr_ := eval( { || if( addedit $ 'a',;
        eval( { || dbgobottom(), dbskip() } ), nil ), {} } )

for c := 1 to fcount()
    IF FIELDGET(C) == "GLCODE"
       aadd( arr_, GLCODE->BRCODE+fieldget( c ) )
    ELSE
       aadd( arr_, fieldget( c ) )
    ENDIF
next 
return( arr_ ) 

////
static function Open1012()
local mlogic := .t.

if !netuse( '&g_GL_PATH\Glcode', .f., 10 ) && general ledger code
   break mlogic
else 
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_GL_PATH\Glcode' )       && set index on glcode
   ordlistadd( '&g_GL_PATH\Glname' )       && set index on glname   
endif

if !netuse( '&g_AMS_PATH\Amsgl', .f., 10 )             && acct mngt general ledger
   break mlogic
else 
   if !.f.; ordlistclear(); endif
   ordlistadd( '&g_AMS_PATH\Amsgl' )                   && set index on jvtype + drcr
endif
return( nil )
