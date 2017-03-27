/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³   Program ID.........:  amsm100c.prg                                 ³
 ³   Description........:  credit application maintenance (sub-module)  ³
 ³   Author.............:  Ariel B. Bulan                               ³
 ³   Date...............:  08:56am 25-Aug-1994                          ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³                         U P D A T E S                                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³        Who        ³     When      ³               Why                ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³                   ³               ³                                  ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/

#include "Colf.ch"
#include "Inkey.ch"
#include "Memoedit.ch"

#define ROWLIMIT  47
************************************************************
*  Desc ¯  This is for Memoedit only ( when F1 was pressed )
*
function get_value( mtype, mmessage, mlen)
************************************************************
   local mRETVAL , mpict
   local mSCR := savescreen( ,,, ) , mCOLOR := setcolor()
   local getlist := {}, mget

   do case
      case mTYPE == 'C'
           mget    := 15
           mpict   := '@XS15' 
           mretval := space(40)
      case mTYPE == 'N'
           mget    := 14
           mpict   := '999,999,999.99'
           mretval := 0
      case mTYPE == 'D'
           mget    := 10
           mpict   := '@D'
           mretval := ctod('//')
   endcase
   fshadow( 4, 4, 6, 4 + len( mmessage ) + 2 + mget, 2 , 'n/w')
   setcolor( 'bg+/w, w+/n,,, gr+/w' )
   @ 5, 5 say mMESSAGE get mRETVAL pict (mpict) valid ( !empty(mRETVAL) .and. lastkey()!=K_ESC )
   setcursor( 3 )
   read
   setcursor( 0 )
   if valtype( mretval )     == 'D'
      mRETVAL := dtoc ( mRETVAL )
   elseif valtype( mRETVAL ) == 'N'
      mRETVAL := transform ( mRETVAL,'999,999,999.99' )
   endif
   setcolor    ( mCOLOR    )
   restscreen  ( ,,,, mSCR )
return alltrim (  mRETVAL  )

**********************************************************
*  Desc ¯  Add values to an empty array
*
function transfer_value( mlevel )
**********************************************************
   local mARRAY := {}

   do case
      case mLEVEL == 1
         mARRAY := { ' 1 = Guarantees                    ',;
                     ' 2 = Real Estate Mortgage          ',;
                     ' 3 = Chattel Mortgage              ',;
                     ' 4 = Pledge and Assignment         ',;
                     ' 5 = Lease Agreements              ',;
                     ' 6 = Purchase/Repurchase Agreements',;
                     ' 7 = Surety Bond                   ',;
                     ' 8 = Promissory Note               ',;
                     ' 9 = Standby Letter of credit      ',;
                     '10 = Lodgement                     ' ;
                   }
      case mLEVEL == 2
         mARRAY := { '1 = Original joint and several          ',;
                     '  = Original inter-company              ',;
                     '  = Original third party                ',;
                     '  = Original parent                     ',;
                     '2 = guaranty for lease obligations for  ',;
                     '  = guaranty for                        ',;
                     '3 = ( Get Amount and Date of Execution )' ;
                   }
      case mLEVEL == 3
         mARRAY := { '1 = Registered                       ',;
                     '  = Unregistered                     ',;
                     '2 = 1st Mortgage                     ',;
                     '  = 2nd Mortgage                     ',;
                     '3 = land for                         ',;
                     '  = building for                     ',;
                     '  = land and building for            ',;
                     '4 = ( Get Amount )                   ',;
                     '5 = with cost value                  ',;
                     '  = with market value                ',;
                     '  = with book value                  ',;
                     '  = with replacement value           ',;
                     '6 = ( Get Value and Evaluation Date )',;
                     '7 = by                               ',;
                     '  = per                              ',;
                     '8 = client.                          ',;
                     '  = us.                              ',;
                     '  = appraiser.                       ' ;
                   }
      case mLEVEL == 4
         mARRAY := { '1 = Registered Chattel Mortgage      ',;
                     '  = Unregistered Chattel Mortgage    ',;
                     '2 = equipment                        ',;
                     '  = raw materials                    ',;
                     '  = goods in process                 ',;
                     '  = finished products                ',;
                     '3 = ( Get Amount )                   ',;
                     '4 = with cost value                  ',;
                     '  = with market value                ',;
                     '  = with book value                  ',;
                     '  = with replacement value           ',;
                     '5 = ( Get Value and Evaluation Date )',;
                     '6 = by                               ',;
                     '  = per                              ',;
                     '7 = client.                          ',;
                     '  = us.                              ',;
                     '  = appraiser.                       ' ;
                   }
      case mLEVEL == 5
         mARRAY := { '1 = Pledge Agreement                 ',;
                     '  = Deed of Assignment               ',;
                     '2 = of                               ',;
                     '  = over and up to ( Get N§ of Days )',;
                     '3 = trade receivables                ',;
                     '  = other receivables                ',;
                     '  = listed securities                ',;
                     '  = unlisted securites               ',;
                     '  = others ( Get Specs )             ',;
                     '4 = ( Get Amount )                   ',;
                     '5 = by                               ',;
                     '  = per                              ',;
                     '6 = client.                          ',;
                     '  = us.                              ',;
                     '  = appraiser.                       ' ;
                   }
      case mLEVEL == 6
         mARRAY := { '1 = Registered ownership over       ',;
                     '2 = land                            ',;
                     '  = building                        ',;
                     '  = equipment                       ',;
                     '3 = with                            ',;
                     '4 = cost value                      ',;
                     '  = market value                    ',;
                     '  = bank value                      ',;
                     '  = replacement value               ',;
                     '5 = ( Get Value and Valuation Date )',;
                     '6 = by                              ',;
                     '  = per                             ',;
                     '7 = client.                         ',;
                     '  = us.                             ',;
                     '  = appraiser.                      ' ;
                   }
      case mLEVEL == 7
         mARRAY := { '1 = Original Purchase Agreement  ',;
                     '  = Original Repurchase Agreement',;
                     '2 = ( Get Executors )            ' ;
                   }
      case mLEVEL == 8
         mARRAY := { '1 = SURETY BOND for',;
                     '2 = ( Get Amount ) ' ;
                   }
      case mLEVEL == 9
         mARRAY := { '1 = PROMISSORY NOTE CO-SIGNED BY',;
                     "2 = ( Get Co-Signer's Name )    " ;
                   }
      case mLEVEL == 10
         mARRAY := { '1 = STANDBY LETTER OF CREDIT for',;
                     '2 = ( Get Amount )              ' ;
                   }
      case mLEVEL == 11
         mARRAY := { '1 = LODGEMENT OF              ',;
                     '2 = Title Deed covering       ',;
                     '  = Insurance Policy          ',;
                     '  = Listed/Unlisted Securities',;
                     '3 = ( Get Details )           ',;
                     '4 = negotiable form.          ',;
                     '  = non-negotiable form.      ' ;
                   }
   endcase
return mARRAY
*
*                      End of the program ( amsm100c.prg )
*
