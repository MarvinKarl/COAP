/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³   Program ID.........:  amsr600b.prg                                 ³
 ³   Description........:  account executed for the month ( FUNCTIONS ) ³
 ³   Author.............:  Ariel B. Bulan                               ³
 ³   Date...............:  01:40pm 20-Jan-1995                          ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³                         U P D A T E S                                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³        Who        ³     When      ³               Why                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³                   ³               ³                                  ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

#include "Colf.ch"
#include "Inkey.ch"

#define MAXROW 56
#define ZERO   0
*************************************************
*
function get_monames()
*************************************************
return eval ({|| get_month(),if (confirm('Include Resructuring Accounts?'),cRESTR := 1,cRESTR := 2), g_names2() })
/*
******************************
*
function get_month()
******************************
   local mretval := .t., getlist := {}, mcolor := setcolor()
   memvar mmonth, myear
   setcolor( 'n/g,w+/n,,, w+/g' )
   @  8, 31 say 'Transaction Date'                color 'w+/g'
   @  9, 31 say 'Month ' get mmonth pict '99'   when  select_month( @mmonth, 9, 46, 18, 56 )
   @ 10, 31 say ' Year ' get myear  pict '9999' valid myear > 1970
   read
   setcolor( mcolor )
return lastkey() != K_ESC
*/
*************************************************
*
function get_perc_watr ( mrecords, mts )
*************************************************
   local mt1 := 1, mt2 := 1, mfcltycd

   while mt1<=len( mts )
      mfcltycd := mts [mt1] [4]
      while mrecords [mt2] [1] == mfcltycd
         mrecords [mt2] [14] := f0600percent ( mrecords[mt2], mts[mt1] )
         mrecords [mt2] [15] := f0600watr    ( mrecords[mt2], mts[mt1] )
         mt2++
         if mt2>len(mrecords)
            exit
         endif
      enddo
      mt1++
   enddo

return nil
********************************************
*
static function f0600percent( x,y )
********************************************
return eval ({|z| z:= if( x[16] == '1', x[11]/y[1], x[13]/y[3]*100 ) })
********************************************
*
static function f0600watr ( x,y )
********************************************
return eval ({|z| z:= if ( x[16] == '1',x[10]*x[11]/y[1],(x[10]*x[13])/y[3] ) })
*************************************************
*
function get_left_totals ( mrecords, mts )
*************************************************
    local mt1 := 1, mt2 := 1, mfcltycd
    local mfin    , mnetfin , mcredamt

    while mt1 <= len (mrecords)

         mfcltycd  := mrecords [mt1] [1]
         mfin      := mnetfin := mcredamt := 0

         while mrecords [mt1] [1] == mfcltycd

              mfin     += mrecords [mt1] [11]
              mnetfin  += mrecords [mt1] [12]
              mcredamt += mrecords [mt1] [13]

              mt1++
              if mt1 > len ( mrecords )
                 exit
              endif

         enddo

         aadd ( mts, { mfin,mnetfin,mcredamt,mfcltycd } )

    enddo

return nil
********************************************
*
function f0600netfinanced ()
********************************************
return eval ({|x,y| x := Acctmast->PRINCIPAL, y := if ( getsetcode(Acctmast->FCLTYCODE) == '1', x - ( Acctmast->GD/100 * x ) , x ) , y } )
********************************************
*
function f0600financed ()
********************************************
return eval ({|x,y| x := Acctmast->PRINCIPAL, y := if ( getsetcode(Acctmast->FCLTYCODE) == '1', x - ( Acctmast->GD/100 * x ) - Acctmast->AMORT, ZERO  ) , y } )
********************************************
*
static function getsetcode( mfcltycd)
********************************************
return eval ({|| Facility->(dbseek(mfcltycd)),Facility->SETCODE })
********************************************
*
function f0600term ( mtermunit )
********************************************
return if( alltrim(mtermunit) $ '12' , if( mtermunit == '1', 'DAYS'    , 'MONTHS'   ),' ')
	

********************************************
*
function f2500curr( mcurrcode )
********************************************
return if( mcurrcode == 'P ',  'PHP'  ,  'USD'   )


********************************************
*
function f0600head()
********************************************
    memvar mtitle,mpage,gsys_name,gcompany,mlm,mmonth,myear
    eval ({|| mtitle := 'Accounts Executed for the Month',;
              prnreptitle  ( 132,mlm,mpage,upper(mtitle),'Program ID:AMSR2500',gsys_name,gcompany),;
              pagecenter   ( prow()+1,132, upper( fr0100month(trans(mmonth,'99')) )+' '+str(myear,4,0) );
          })
return nil
********************************************
*
function f0600sbhead()
********************************************
   local mleft := 5
   //                          1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0          1        2
   //                0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
   //                     5                22                                                 73             88             103            118            133        144      153            168            183            198       208
   @ prow()+1, mleft say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄ'
   @ prow()+1, mleft say ' Account Number  Account Name                                        Currency     Purchase       Guaranty    Residual Value  Amortization     Term      True      Amount        Net Amount    Total Percent    WATR   '
   @ prow()+1, mleft say '                                                                                   Amount         Deposit                                               Rate     Financed        Financed      Receivables                    '
   @ prow()+1, mleft say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄ'
return nil
********************************************
*
function f0600ftotal( mftotals )
********************************************
   local mleft := 84, mcol := { 84,99,114,129,164,179,194,209,219 }
   @ prow()+1, mleft     say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄ'
   @ prow()+1, 22        say 'Facility Total '
   @ prow()  , mcol [1]  say mftotals [1]  pict '999,999,999.99'
   @ prow()  , mcol [2]  say mftotals [2]  pict '999,999,999.99'
   @ prow()  , mcol [3]  say mftotals [3]  pict '999,999,999.99'
   @ prow()  , mcol [4]  say mftotals [4]  pict '999,999,999.99'
   @ prow()  , mcol [5]  say mftotals [5]  pict '999,999,999.99'
   @ prow()  , mcol [6]  say mftotals [6]  pict '999,999,999.99'
   @ prow()  , mcol [7]  say mftotals [7]  pict '999,999,999.99'
   @ prow()  , mcol [8]  say mftotals [8]  pict '999.9999%'
   @ prow()  , mcol [9]  say mftotals [9]  pict '999.9999%'
   @ prow()+1, mleft    say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄ'
return nil
/*
********************************************
*   
static function select_month ( mmonth )
********************************************
return eval( { | x, y, z | x := setcolor(), y := savescreen( ,,, ),;
                          fshadow( 9, 46, 18, 56, 2, 'w/gr' ),;
                          devpos( 10, 49 ), devout( 'Month', 'bg+/gr' ),;
                          devpos( 11, 46 ) , devout( 'ÃÄÄÄÄÄÄÄÄÄ´', 'w/gr' ),;
                          setcolor( 'w/gr, w+/n,,, n/gr' ),;
                          z := achoice( 12, 47, 17, 55,;
                               { 'January', 'February', 'March', 'April',;
                                 'May', 'June', 'July', 'August', 'September',;
                                 'October', 'November', 'December' },,, mmonth ),;
                          setcolor( x ), restscreen( ,,,, y ), mmonth := if( z == 0, mmonth, z ), .f. } )
*/
//aga.06.05.2005.new and improved g_names2()...yay!
*******************************
static function g_names2()
*******************************
memvar mpreparedby , mcheckedby, mnotedby
local  getlist := {}, ax := setcolor()
private entryname [3]
entryname [1] := entryname [2] := entryname [3] := space(30)

fshadow( 10, 4, 14, 44, 2, 'gr+/g')
setcolor( 'w/g, w+/n,,, w+/g')

@ 10, 5 say 'Signatories' color 'bg+/g'
@ 11, 5 say 'Prepared by ' gget entryname[1] picture '@xs25'            ;
         when lastkey() != K_ESC valid !empty( mpreparedby := get_initial(entryname[1], 1, 10, 19, 25 ) )
@ 12, 5 say ' Checked by ' gget entryname[2] picture '@xS25'            ;
         when lastkey() != K_ESC valid !empty( mcheckedby  := get_initial(entryname[2], 2, 10, 19, 25 ) )
@ 13, 5 say '   Noted by ' gget entryname[3] picture '@xS25'            ;
         when lastkey() != K_ESC valid !empty( mnotedby := get_initial(entryname[3], 3, 10, 19, 25 ) )

setcursor ( 3 )
read   
setcursor ( 0 )
setcolor  ( ax )

return( lastkey()!=K_ESC )
//.........................................


//**********************************************
//*
//static function g_names2()
//**********************************************
//    memvar mpreparedby , mcheckedby, mnotedby
//    memvar mpcode      , mccode    , mncode
//    local getlist := {}, mscreen := savescreen( ,,, ), mcolor := setcolor()
//
//if lastkey() != K_ESC    
//    fshadow( 10, 4, 14, 44, 2, 'gr+/g')
//    setcolor( 'w/g, w+/n,,, w+/g')
//    @ 10, 5 say 'Signatories' color 'bg+/g'
//    @ 11, 5 say 'Prepared by ' get mpreparedby pict '@XS25' when luk_at_them( @mpcode, @mpreparedby, '® Prepared by ¯' )
//    @ 12, 5 say ' Checked by ' get mcheckedby  pict '@XS25' when luk_at_them( @mccode, @mcheckedby , '® Checked by ¯'  )
//    @ 13, 5 say '   Noted by ' get mnotedby    pict '@XS25' when luk_at_them( @mncode, @mnotedby   , '® Noted by ¯'    )
//    setcursor( 3 )
//    read
//    setcursor( 0 )
//    setcolor( mcolor )
//    restscreen( ,,,, mscreen )
//endif    
//return ( lastkey()!=K_ESC )
//***************************************************
//*
//static function luk_at_them( mcode, mname, mmess )
//***************************************************
//    if lastkey() != K_ESC
//       @ 24, 00 say repl(' ',78) color ( NRM )
//       center  ( 24, 'w+/n', mmess )
//       lb_lkup ( 'Personel' ,1,1, @mcode, 2, 1, 12, 19, 19, 73, 'w/gr+,w/n,,,w/gr+' )
//       mname := Personel->FULLNAME
//       @ 24, 00 say repl (' ',78) color ( NRM )
//    endif
//return .f.
*
*                         End of the program ( amsr600b.prg )
*
