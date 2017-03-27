/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ·
³   colf-iis .... Account Management System                                    º
³   Program id... Amsr1300.prg                                                 º
³   Description . Weekly Delinquency Report                                    º
³   Author....... Engr. Michael B. Espina                                      º
³   Date ........ April 12, 2000 2:15 P.M.                                     º
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶
³                             u p d a t e s                                    º
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶
³        who        ³       when        ³               why                    º
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶
³  add gd/rv column ³   oct. 24, 2000   ³  era,yasu requested for it           º
³  include per      ³   01.16.2004      ³                                      º
³                   ³                   ³                                      º
³  Select per       ³   02.16.2004      ³  request ng mancom                   º
³    Facility       ³                   ³                                      º
³                   ³                   ³                                      º
³  Modify Deliquency³   01-Mar-2004     ³  classify according to facility      º
³  Report           ³                   ³                                      º
³  ABB              ³   10.27.2004      ³  ONLINE                              º
³  aga              ³   14.02.2007      ³ neo paysked support for modules      º
ÔÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
*/

#include "COLF.CH"
#include "INKEY.CH"
#include "DBSTRUCT.CH"
#include "ACHOICE.CH"

#define MAXROW 54
#defi K_SPACEBAR   32

memvar ax_level,g_user_id

&& NOTE: PARAMETR->BRCODE IS THE SAME WITH g_PAR_BRCH. - RED 121004

if chkpass( procname(),ax_level,g_user_id )
   if amsr1300open()
      amsr1300main()
   endif
   eval ({|| __mrelease( "*", .t.), dbcloseall() })
endif
return

******************************
static function amsr1300main()
******************************
   local  mdbf   := savedbf (mdbf), mcolor := setcolor(), mcursor := setcursor()
   LOCAL xSTR
   memvar gtrandate, g_lastclosed
   private mpage := 1,mmonth,mdays,myear,mtitle,mlm,mdate,clntflag:='',nchoice
   private _cfacility := space(5), aFacility  := {}, _afcltySum := {}, arFacility := {}
   PRIVATE xTMP := ''

   mtitle := 'Weekly Delinquency Report'
   mlm    := 0
   mdate  := g_lastclosed

        xget_mdate( 7 )
         xTMP := CREATTEMP()   //external function on amsr2200
         mpage := 1
         _comp_menu()

		if lastkey() == K_ESC
			return
		endif	
		 
      if nchoice != 4                   // abb 01.16.2004

        if TRUE_BRCH == '001' 
			TRANSFER2('A',xTMP)
		endif
		
         eval({ || mmonth := month(mdate)    ,;
                   mdays  :=day  ( mdate )   ,;
                   myear  :=year ( mdate )   ,;
                   xSTR := CHK_PAR(mpage)    +;
                           CHK_PAR(mmonth)   +;
                           CHK_PAR(mdays)    +;
                           CHK_PAR(myear)    +;
                           CHK_PAR(mtitle)   +;
                           CHK_PAR(mlm)      +;
                           CHK_PAR(mdate)    +;
                           CHK_PAR(clntflag) +;
                           CHK_PAR(gSYS_NAME)+;
                           CHK_PAR(gCOMPANY) +;
                           CHK_PAR(nCHOICE)  ,;
                           REPCON_OL( '_weekly_delinquent_print()',;
                                      '132 Column<Cont.>',,8,33,,xSTR,.T.);
          })
          (xTMP)->(DBCLOSEAREA())
          //repcontrol  ( '_weekly_delinquent_print()','132 Column<Cont.>',,8,33);
      endif
   //enddo
   setcolor  (mcolor)
   setcursor (mcursor)
   restdbf   (mdbf)
return nil

********************************
*
static function _comp_menu()
********************************
   local mscr := savescreen (,,,), _ar2 := {}
   local menulist, mcolor := setcolor()
   local fcnm := spac(10)
   local Pick
   LOCAL xSTR
   private gt_fclty :=space(0), fcltysel := space(1), affirmation := .f. //aga.19.12.2005.new var

   private ind  := 1, mrow := 1, mcol := 1
   nchoice    := 0
   aFacility  := {}
   _afcltySum := {}
   arFacility := {}

   set color to 'w/n'
   @ 10,30 clear to 20,50
   @ 10,30 to 20,50 double
   @ 12,33 prompt 'FMLC Accounts '
   @ 14,33 prompt 'PBC  Accounts '
   @ 16,33 prompt 'ORIX Accounts '
   @ 18,33 prompt 'ALL  Accounts '
   menu to nchoice

   if nchoice == 4

      Facility->(dbgotop())
      DO WHILE !Facility -> (EOF())

         if left ( alltrim(Facility->fcltycode),4)      == '1045' .or. ;
                   left(alltrim(Facility->fcltycode),5) == '10499'     ;
                 //
                 //  abb 03.22.04
                 //
            aadd ( aFacility,' ' + ' ³ ' + padr( Facility->fcltycode,6 ) + '³ ' + padr( Facility->fcltyalias,11) + '³ ' + padr( Facility->fcltyname ,40) )
            aadd ( _ar2,.f. )
         else
            aadd ( aFacility,'û' + ' ³ ' + padr( Facility->fcltycode,6 ) + '³ ' + padr( Facility->fcltyalias,11) + '³ ' + padr( Facility->fcltyname ,40) )
            aadd ( _ar2,.t. )
         endif
         Facility -> (dbskip(+1))
      ENDDO

      DO WHILE .T.

        if TRUE_BRCH == '001'           // HEAD OFFICE? 03.15.2004

            fBookamsr()
            setcolor('w/n' )

            Pick := ACHOICE(10,06,17,72, aFacility,_ar2,"fUdf0700",mrow,mcol)
            if lastkey() == K_ESC
                exit
            endif


            if lastkey() == K_ENTER

               TRANSFER2('B',xTMP)

               //aga.19.12.2005.check the facility                 

               for h := 1 to len(aFacility)
                   if (substr(aFacility[h],1,1) == "û")
                      gt_fclty += '1'     
                   else
                      gt_fclty += '0'
                   endif
               next

               if gt_fclty == '11111111101111000000'              //without cml auto
                   fcltysel := '1'
               elseif gt_fclty == '00000000010000100000'
                   fcltysel := '2'                                //with cml auto
               else
                   fcltysel := '3' 
               end if
               //.................................. 

               //if fcltysel $ '12' //aga.24.02.2006.removed by RSA request
                  if confirm('Is the delinquency report final?' + if(fcltysel $ '12' ,if(fcltysel == '1',' (w/o cml/autoloan) ',' (cml/autoloan only) '),' ') + dtodmy(date()) ) 
                     affirmation := .t.                   
                  end if
               //end if

               _cfacility := '00000'

               mmonth := month ( mdate )
               mdays  := day   ( mdate )
               myear  := year  ( mdate )
               //repcon  ( '_ALLweekly_delinquent_print()','132 Column<Cont.>',,8,33)


               repcon_ol  ( '_ALLweekly_delinquent_print()','132 Column<Cont.>',,8,33,,,.F.)
               exit
            endif

        else
            //aga.01.03.2006.branch confirmation for delq save
            if confirm('Is the delinquency report final? ' + dtodmy(date()) ) 
               affirmation := .t.                   
            end if
            //.....................................

            mmonth := month ( mdate )
            mdays:=day  ( mdate )
            myear:=year ( mdate )
            &&repcontrol  ( '_ALLweekly_delinquent_print()','132 Column<Cont.>',,8,33 )

            xSTR := CHK_PAR(mPAGE) + CHK_PAR(mMONTH)   + CHK_PAR(mDAYS)     +;
                    CHK_PAR(mYEAR) + CHK_PAR(mTITLE)   + CHK_PAR(mLM)       +;
                    CHK_PAR(mDATE) + CHK_PAR(cLNTFLAG) + CHK_PAR(gSYS_NAME) +;
                    CHK_PAR(gCOMPANY) + CHK_PAR(nCHOICE) + chk_par(affirmation)
            REPCON_OL( '_ALLweekly_delinquent_print()','132 Column<Cont.>',,8,33,,xSTR,.T. )
            exit
        endif

     ENDDO

   endif
   setcolor(mcolor)
   restscreen ( ,,,, mscr )
return nil
/*
************************************
*
static function _company_accounts()
************************************
   local cretval := 3        // 1-metro,2-pbc,3-orix

   if nchoice == 0
      cretval := 0
   else
      do case
         case substr(alltrim((xTMP)->acctno),1,4) == '9907'    // METRO
            cretval := 1
         case substr(alltrim((xTMP)->acctno),1,4) == '9908'    // PBC
            cretval := 2
      endcase
   endif

return cretval
*/
*************************************
*
function _weekly_delinquent_print()
*************************************
   memvar mdate, fcltysel, affirmation //aga.19.12.2005.new memvar
   local   mclntcode,t_rec:=0, nrec := 1
   private mamort,mtpastdue,mosbal,totpastdue := 0
   private mpamort,mptpastdue,mposbal,ncurosbal := 0
   private mgamort,mgtpastdue,mgosbal,mdiffdate
   private t_amort:=0, t_osbal:=0, t_pastdue := 0
   private lul:=0, mpdue:=0, ktr:=0
   private new := .t.
   private gt_amort, gt_osbal, gt_pastdue

   gt_amort := gt_osbal  := gt_pastdue := 0
   mpamort := mptpastdue := mposbal    := 0
   mgamort := mgtpastdue := mgosbal    := 0

   setprc(0,0)
   @ prow(),pcol() say chr(15)
   print_head()
   setfont('CONDENSED')
   print_subhead()
   //
   //     Acctmast->(dbgotop())
   //



   (xTMP)->(DBGOTOP())
   (xTMP)->(DBEVAL({ || EVAL ({ || mCLNTCODE := (xTMP)->ACCTNAME         ,;
                                   mDIFFDATE := 0                        ,;
                                   IF ( !(xTMP)->(DELETED()), NIL, NIL ) ,;
                                   (xTMP)->( DBEVAL( { || IF( ( VAL((xTMP)->STATUS) < 3 .OR. VAL((xTMP)->STATUS) == 6 );
                                                              .AND. !_EMPLOYEE_LOANS((xTMP)->FCLTYCODE) .AND.          ;
                                                              (xTMP)->OSBAL > 0 .AND. nCHOICE == _COMPANY_ACCOUNTS(xTMP),;
                                                              EVAL({|| TRAVERSE_SKED(), mGOSBAL += (xTMP)->OSBAL })   ,;
                                                              NIL                                                      ;
                                                            )                                                          ;
                                                     },,;
                                                     {|| !(xTMP)->(EOF()) .AND. (xTMP)->ACCTNAME == mCLNTCODE ;
                                                     }     ;
                                                   )      ;
                                           )             ,;
                                   (xTMP)->( DBSKIP(-1) ) ;
                             })                           ;
                   },,;
                   { || !(xTMP)->(EOF()) } ;
                  );
           )
    /*
    Acctmast->(dbseek(g_PAR_BRCH))
    Acctmast->(dbeval({|| if ( ( val(Acctmast->STATUS) < 3 .or. val( Acctmast->STATUS) == 6 );
                               .and. ;
                               Acctmast->Valdate <= mdate .and. ;
                               nchoice == _company_accounts(xTMP),;
                          eval ({ || mclntcode := Acctmast->Acctname ,;
                                     mdiffdate := 0 ,;
                                     if ( !Acctmast->(deleted()),;
                                          nil,;
                                          nil ;
                                        ) ,;
                                     Acctmast->( dbeval({|| if( ( val( Acctmast->STATUS ) < 3 .or. val( Acctmast->STATUS) == 6 );
                                                                .and. ;
                                                                !_employee_loans(Acctmast->fcltycode) .and. ;
                                                                Acctmast->osbal > 0 .and.                   ;
                                                                nchoice == _company_accounts(xTMP)         ,;
                                                                eval({||  ; // Paysked->(dbseek(Acctmast->ACCTNO+dtos(mdate),.t.)),
                                                                        traverse_sked()            ,;
                                                                        mgosbal += Acctmast->Osbal  ;
                                                                    }),;
                                                                nil ;
                                                              )},,;
                                     {|| !Acctmast->(eof()) .and. ;
                                          Acctmast->Acctname == mclntcode .and. ;
                                          Acctmast->brcode == g_PAR_BRCH ;
                                     } )),;
                                     Acctmast->( dbskip(-1) )         ;
                                }),;
                          nil ) ;
                      } ,,;
                ; //   {|| Acctmast->clntcode != '9500422'} ;  
                       {|| !Acctmast->(eof()) .and. Acctmast->brcode == g_PAR_BRCH } ;
                     )                        ;
              )
    */
         @ prow()+1, 00  say '³                 ³     ³                                      ³ TOTAL      ³ '
         @ prow()  , 92-1  say '³'+ transform(t_amort,'999,999,999,999.99')
         @ prow()  , 112-1 say '³'+ transform(t_osbal,'999,999,999,999.99') + ' ³'
         @ prow()  , 145-1 say '³'+ transform(t_pastdue,'999,999,999,999.99')+' ³              ³                                        ³'
         @ prow()+1, 0   say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'

         if prow() >= 52
            mpage++
            __eject()
            @ prow ()+1, 00 say 'Page : ' + trans(mpage, '999' )
            setprc ( 0,0 )
            print_subhead()
         endif

         @ prow()+1, 0     say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
         @ prow()+1, 00    say '³ this week       ³     ³                                      ³ GRAND TOTAL³ '
         @ prow()  , 92-1  say '³'+ transform(gt_amort  ,'999,999,999,999.99')
         @ prow()  , 112-1 say '³'+ transform(gt_osbal  ,'999,999,999,999.99') + ' ³'
         @ prow()  , 145-1 say '³'+ transform(gt_pastdue,'999,999,999,999.99')+' ³              ³                                        ³'
         @ prow()+1, 0     say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'

__eject()        


//////////////
//         for nctr := 1 to len(arfacility)
  //           @ prow() + 1, 00       say arfacility[nctr][1] 
    //         @ prow()    , pcol()+2 say arfacility[nctr][2] 
      //       @ prow()    , pcol()+2 say arfacility[nctr][3] 
        // next nctr

return nil

**************************************
*
function _ALLweekly_delinquent_print()
**************************************
    memvar mdate, fcltysel, affirmation //aga.19.12.2005.new memvar
    local   mclntcode,t_rec:=0, nrec := 1, goprint := .f.
    private mamort,mtpastdue,mosbal,totpastdue := 0
    private mpamort,mptpastdue,mposbal,ncurosbal := 0
    private mgamort,mgtpastdue,mgosbal,mdiffdate
    private t_amort:=0, t_osbal:=0, t_pastdue := 0
    private lul:=0, mpdue:=0, ktr:=0
    private new := .t.
    private gt_amort, gt_osbal, gt_pastdue

    gt_amort := gt_osbal  := gt_pastdue := 0
    mpamort := mptpastdue := mposbal :=0
    mgamort := mgtpastdue := mgosbal :=0

    setprc(0,0)

    @ prow(),pcol() say chr(15)

    print_head    ()
    setfont       ( 'CONDENSED' )
    print_subhead ()
    //
    //  Acctmast->(dbgotop())
    //

    (xTMP)->(DBGOTOP())

    (xTMP)->(DBEVAL({ || EVAL ({ || mCLNTCODE := (xTMP)->ACCTNAME        ,;
                                    mDIFFDATE := 0                       ,;
                                    IF ( !(xTMP)->(DELETED()), NIL, NIL ),;
                                    (xTMP)->( DBEVAL({|| IF( (VAL((xTMP)->STATUS) < 3 .OR. VAL((xTMP)->STATUS) == 6) .AND. !_EMPLOYEE_LOANS((xTMP)->FCLTYCODE) .AND. (xTMP)->OSBAL > 0,;
                                                             EVAL({|| IF ( .T.,;
                                                                           IF ( _FILTER_AFACILITY ( g_PAR_BRCH+(xTMP)->ACCTNO,AFACILITY ),;
                                                                                EVAL({|| TRAVERSE_SKED()         ,;
                                                                                         mGOSBAL += (xTMP)->OSBAL ;
                                                                                    }),;
                                                                                NIL;
                                                                              ),;
                                                                           EVAL ({|| TRAVERSE_SKED()         ,;
                                                                                     mGOSBAL += (xTMP)->OSBAL ;
                                                                                });
                                                                         );
                                                                 })  ,;
                                                             NIL ;
                                                           );
                                                     },,;
                                                     {|| !(xTMP)->(EOF()) .AND. (xTMP)->ACCTNAME == mCLNTCODE };
                                                    );
                                            ),;
                                    (xTMP)->( DBSKIP(-1) ) ;
                              }) ;
                    },,;
                    { || !(xTMP)->(EOF()) } ;
                   );
            )
    /*
    ACCTMAST->(DBSETORDER(1))
    Acctmast->(dbseek(g_PAR_BRCH))
    Acctmast->(dbeval({|| if ( ( val(Acctmast->STATUS) < 3 .or. val(Acctmast->STATUS) == 6 ) .and. Acctmast->Valdate <= mdate,;
                          eval ({ || mclntcode := Acctmast->Acctname ,;
                                     mdiffdate := 0 ,;
                                     if ( !Acctmast->(deleted()), nil, nil ) ,;
                                     Acctmast->( dbeval({|| if( ( val(Acctmast->STATUS) < 3 .or. val(Acctmast->STATUS) == 6);
                                                                 .and. ;
                                                                !_employee_loans(Acctmast->fcltycode) .and. ;
                                                                Acctmast->osbal > 0 ,;
                                                                eval({||  if (  .t. ,;
                                                                                if (  _filter_afacility ( g_PAR_BRCH+Acctmast->acctno,afacility ) ,;
                                                                                      eval ( {|| traverse_sked()            ,;
                                                                                                 mgosbal += Acctmast->Osbal  ;
                                                                                             };
                                                                                           ),;
                                                                                     nil;
                                                                                   ),;
                                                                                eval ({|| traverse_sked()            ,;
                                                                                         mgosbal += Acctmast->Osbal  ;
                                                                                      } ;
                                                                                     );
                                                                           );
                                                                    }),;
                                                                nil ;
                                                              )},,;
                                     {|| !Acctmast->(eof()) .and. ;
                                          Acctmast->Acctname == mclntcode .and. ;
                                          Acctmast->brcode   == g_PAR_BRCH ;
                                     } )),;
                                     Acctmast->( dbskip(-1) )        ;
                                }),;
                          nil ) ;
                      } ,,;
                 {|| !Acctmast->(eof()) .and. Acctmast->brcode == g_PAR_BRCH ;
                  } ;  //   {|| Acctmast->clntcode != '9500422'} ;
                ) ;
              )
    */
         @ prow()+1, 00  say '³                 ³     ³                                      ³ TOTAL      ³ '
         @ prow()  , 92-1  say '³'+ transform(t_amort,'999,999,999,999.99')
         @ prow()  , 112-1 say '³'+ transform(t_osbal,'999,999,999,999.99') + ' ³'
         @ prow()  , 145-1 say '³'+ transform(t_pastdue,'999,999,999,999.99')+' ³              ³                                        ³'
         @ prow()+1, 0   say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'

         if prow() >= 52
            mpage++
            __eject()
            @ prow ()+1, 00 say 'Page : ' + trans(mpage, '999' )
            setprc ( 0,0 )
            print_subhead()
         endif

         @ prow()+1, 0     say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
         //aga.19.12.2005.add text      
         @ prow()+1, 00    say '³ this week       ³     ³                                      ³ GRAND TOTAL³ '
         @ prow()  , 92-1  say '³'+ transform(gt_amort  ,'999,999,999,999.99')
         @ prow()  , 112-1 say '³'+ transform(gt_osbal  ,'999,999,999,999.99') + ' ³'
         @ prow()  , 145-1 say '³'+ transform(gt_pastdue,'999,999,999,999.99')+' ³              ³                                        ³'
         @ prow()+1, 0     say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
         //__eject()

//aga.12.12.2005.insert last weeks data

        if TRUE_BRCH == '001'

dbselectarea ('delqdrop')
delqdrop->(dbsetorder(1))

if affirmation
   //take snapshot
   delqdrop->(dbappend())
   delqdrop->grosbal   := gt_osbal
   delqdrop->gramort   := gt_amort
   delqdrop->grpastdue := gt_pastdue
   delqdrop->date      := date()
   delqdrop->time      := time()
   delqdrop->user_id   := g_USER_ID
   delqdrop->facility  := fcltysel
   delqdrop->brcode    := g_PAR_BRCH
   delqdrop->(dbunlock())
   delqdrop->(dbcommit())

   //get data
   delqdrop->(dbskip(-1))         
   if delqdrop->grosbal > 0
      goprint := .t.
   end if
else                                             //fcltysel d3, or a1/a2 
   delqdrop->(dbseek( g_par_brch+alltrim(str(val(fcltysel) + 1)) ))
//   alert(indexkey() + ' ' + g_par_brch+alltrim(str(val(fcltysel) + 1)) + ' ' + if(found(),"T","F"))

   if found()
      delqdrop->(dbskip(-1))         
      if delqdrop->grosbal > 0
         goprint := .t.
      end if
   end if
end if


if goprint
   @ prow()+1, 0     say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
   @ prow()+1, 00    say '³ last week       ³     ³                                      ³ GRAND TOTAL³ '
   @ prow()  , 92-1  say '³'+ transform(delqdrop->gramort,'999,999,999,999.99')
   @ prow()  , 112-1 say '³'+ transform(delqdrop->grosbal,'999,999,999,999.99') + ' ³'
   @ prow()  , 145-1 say '³'+ transform(delqdrop->grpastdue,'999,999,999,999.99')+' ³              ³                                        ³'
   @ prow()+1, 0     say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
end if

        end if

__eject()        
//..............................

         @ prow()+1, 0 say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
         @ prow()+1, 0 say '³ Facility           ³ Facility                                   ³ Total              ³ Outstanding       ³'
         @ prow()+1, 0 say '³ Code               ³ Name                                       ³ Pastdue            ³ Balance           ³'
         @ prow()+1, 0 say 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
         grntpastdue := 0
         grntosbal  := 0   


        arfacility := asort ( arfacility,,,{ |x,y| x[1] < y[1]} )
        nctr := 1
 
        do while nctr <= len(arfacility)

             __cfcltycode := arfacility[nctr] [1]
             __ntpastdue  := 0
             __ntosbal    := 0

             do while alltrim(arfacility[nctr] [1]) == alltrim(__cfcltycode)

                __ntpastdue  += arfacility[nctr] [2]     // total pastdue 03.16.04
                __ntosbal    += arfacility[nctr] [3]     // total osbal 03.16.04

                grntpastdue  += arfacility[nctr] [2]
                grntosbal    += arfacility[nctr] [3]

                nctr++
                if nctr > len(arfacility)
                   exit
                endif
             enddo

//               nctr--

             @ prow()+1, 00       say '³ '     + __cfcltycode // facility code
             @ prow()  , 21       say '³ '     + padr ( _get_facility_name(__cfcltycode),40) pict '@!'// facility name
             @ prow()  , pcol()+2 say ' ³ '   + transform  ( __ntpastdue ,'999,999,999.99' )
             @ prow()  , pcol()+2 say '   ³ '  + transform ( __ntosbal  ,'999,999,999.99' ) + '    ³'
         enddo

//           next nctr

         @ prow()+1, 0  say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
         @ prow()+1, 0  say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
         @ prow()+1, 0  say '³                    ³                                 GRAND TOTAL³'  + transform( grntpastdue,'999,999,999.99' ) + '      ³' + transform( grntosbal  ,'999,999,999.99' ) + '     ³'
         @ prow()+1, 0  say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'


         @ prow()+3, 0  say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
         @ prow()+1, 0  say '³Other Facilities NOT Included :                      ³'
         @ prow()+1, 0  say 'ÃÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
         @ prow()+1, 0  say '³Code     ³ Name                                      ³'
         @ prow()+1, 0  say 'ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'

         for nctr := 1 to len (afacility)
             if (substr( afacility[nctr],1,1) == ' ')
                @ prow() + 1, 00         say '³'
                @ prow()    , 02         say substr(afacility[nctr],5,5)   pict '@!'
//                @ prow()    , pcol()+2 say substr(afacility[nctr],13,8)  pict '@!'
                @ prow()    , pcol()+3   say '³'
                @ prow()    , pcol()+2   say substr(afacility[nctr],26,28) pict '@!'
                @ prow()    , pcol()+13   say '³'
                lretval := .t.
             endif
         next nctr

         @ prow()+1, 0  say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'

         @ prow()+1, 00 say '/eor'

         arfacility := {}
         __eject()

return nil

***********************************************************
*
static function _filter_afacility( cacctno, afacility )
***********************************************************
        local lretval := .f., nctr
        tot_pastdue := 0
        tot_osbal := 0
        fctr := 0

        for nctr := 1 to len (afacility)
                if (substr( afacility[nctr],1,1) == 'û')
                        if (substr(aFacility[nctr],5,5) == substr(cacctno,5+3,5))
                                lretval := .t.
                        endif
                endif
        next nctr
return lretval

****************************************************
*
static function _get_facility_name(cfcltycode)             // abb 03.16.2004
****************************************************
   local cretval := space (len(Facility->fcltycode))

   if Facility->(dbseek(cfcltycode))
      cretval := Facility->fcltyname
   endif

return cretval
/*
****************************************************
static function _employee_loans(cfcltycode)
****************************************************
   local lretval := .f.

   if cfcltycode == '10451' .or. cfcltycode == '10452' .or. ;
      cfcltycode == '10453' .or. cfcltycode == '10454'
      lretval := .t.
   endif

return lretval
*/
********************************
static function print_clntcode()
********************************
 if Paysked->(dbseek( g_PAR_BRCH+(xTMP)->Acctno)) ; // .and. Paysked->Paydate + 5 < mdate ;
    .and. chkacct() > (xTMP)->Amort * 0.10
   new := .t.
   eval ({|| devpos(prow()+1,000)                              ,;
             devoutpict (g_PAR_BRCH+(xTMP)->CLNTCODE,'@R 999-99-99999')     ,;
             devpos(prow()  ,9)                                ,;
             devout(left(dispclntname(g_PAR_BRCH+(xTMP)->CLNTCODE,40),20))  ;
        })
 endif
return nil
//////////
Static function Chkacct()
local mval,retval:=0

      // mval:= if( Paysked->Paydate + 5 > mdate, 5, 0 )
      mval:= 0
      while PAYSKED->BRCODE+Paysked->ACCTNO == g_PAR_BRCH+(xTMP)->ACCTNO .and. Paysked->Paydate <= mdate

         if Paysked->Paydate + mval < mdate
            retval += Paysked->Amort
         endif
         Paysked->(dbskip())
      enddo
return retval

*********************************
*
static function traverse_sked()
*********************************
    local  mclntno  ,macctno, mu := 0,mval:=0, mBRCODE
    local  mnextpaydate,mmatdate,mpayfreq,mremterm:=0,date_ok := .f.
    local  mdiff := 0,sw:=.f., p_due:= .f.
    memvar mdate,lul, mpdue, mdiffdate
    memvar mamort,m1_30,m31_60,m61_90,m91_180,m180_above,mtpastdue,mosbal
    memvar mpamort,mp1_30,mp31_60,mp61_90,mp91_180,mp180_above,mptpastdue,mposbal
    memvar mgamort,mg1_30,mg31_60,mg61_90,mg91_180,mg180_above,mgtpastdue,mgosbal

    mamort := m1_30  := m31_60 := m61_90  := m91_180  := m180_above  := mtpastdue  := mosbal  :=0
    mpdue:=0
    if (prow() >= MAXROW)
       mpage++
       @ prow()+1, 0 say 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
       __eject()
       @ prow()+1, 00 say 'Page : ' + trans(mpage, '999' )
       SETPRC( 0,0 )
       print_subhead()
       @ prow()+1, 0 say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
                          
    endif


//aga.08.05.2006.marked for modification
    dbselectarea('Paysked')
    Paysked->( dbsetorder(2) )

    Paysked->(dbseek(g_PAR_BRCH+(xTMP)->ACCTNO+'D'))

    mu := Paysked->(recno())
    Paysked-> ( dbeval ( { || mremterm++ },,;
                         { || Paysked->Acctno == (xTMP)->Acctno .and. Paysked->Status == 'D' .and. Paysked->brcode == g_PAR_BRCH   ;
                         };
                       );
              )

    Paysked-> ( dbgoto(mu) )

    mclntno  := (xTMP)->CLNTCODE
    macctno  := right((xTMP)->ACCTNO,5)
    mamort   := (xTMP)->AMORT
    mBRCODE  := (xTMP)->BRCODE
    mmatdate := if ( empty(dtos((xTMP)->MATDATE)),;
                     space(10),;
                     (xTMP)->MATDATE ;
                   )

    mpayfreq := (xTMP)->PAYFREQ


// OLD    if Paysked->( dbseek(g_PAR_BRCH+(xTMP)->ACCTNO),.t.) .and. ;	// PEPE 05152007
// OLD       Paysked->Paydate <= mdate .and. Paysked->Status == 'D'	// PEPE 05152007

    Paysked->(dbseek(g_PAR_BRCH+(xTMP)->ACCTNO+'D'))  // REVISED

    if Paysked->acctno  ==  (xTMP)->acctno 	.and. ;	// REVISED
       Paysked->Paydate <=  mdate 	        .and. ;	// REVISED
       Paysked->Status  ==  'D' 	        .and. ;	// REVISED
       Paysked->brcode  ==  g_PAR_BRCH


       mosbal   := (xTMP)->OSBAL
       mnextpaydate := if ( Paysked->Amtdue > (xTMP)->Amort * 0.10 ,;
                            eval( {|| sw:=.t. ,;
                                      Paysked->Paydate ;
                                  };
                                ),;
                            nil ;
                         )

       mval := 0

       do while Paysked->acctno  == (xTMP)->acctno .and. Paysked->Paydate <= mdate .and. Paysked->Status == 'D' .and. Paysked->brcode  == g_PAR_BRCH

         if Paysked->Paydate <= mdate      
            mnextpaydate:= if( !sw,;
                               eval ( {|| sw:=.t.,;
                                          Paysked->Paydate ;
                                      };
                                    ),;
                               mnextpaydate ;
                             )

            mtpastdue += Paysked->Amtdue
            mpdue++

            if ( ( Paysked->Amtdue ) > ( (xTMP)->Amort * .10 ) )

               p_due     := .t.
               mdiffdate := if ( !date_ok,;
                                 eval ( { || date_ok := .t.          ,;
                                             mdate - Paysked->Paydate ;
                                        };
                                      ),;
                                 mdiffdate ;
                               )

            else
               sw:=.f.
            endif

         endif
         Paysked->(dbskip(+1))

       enddo

       if mtpastdue > 0 .and. mdiffdate > 0
          mosbal   := (xTMP)->OSBAL
          print_it( g_PAR_BRCH+macctno,mamort,m1_30,m31_60,m61_90,m91_180,m180_above,mtpastdue,mosbal,mnextpaydate,mmatdate,mpayfreq,mremterm)
          new := .f.
       else
          mosbal := 0
       endif
    endif
//.........................................


    mpamort     += mamort     
    mptpastdue  += mtpastdue
    mposbal     += mosbal
    mgamort     += mamort    
    mgtpastdue  += mtpastdue 
    ncurosbal   += mosbal

return nil


*****************************************************************************************************************************************
static function print_it( macctno,mamort,m1_30,m31_60,m61_90,m91_180,m180_above,mtpastdue,mosbal,mnextpaydate,mmatdate,mpayfreq,mremterm)
*****************************************************************************************************************************************
 local linda:=0, new_date, ispacio:=0, pasok:=.f., ispacio2:=0
 local rev:=0, drevdate, m_date:=ctod(''), _cclntname := (xTMP)->acctname

 memvar lul, mdiffdate
 memvar t_amort, t_osbal, t_pastdue, ktr

  if mamort * .10 < mtpastdue

    if clntflag != (xTMP)->clntcode

       if lul == 0

          @ prow()+1, 00 say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
          lul:=1
          ktr:=0

       else

        if ktr > 1
          @ prow()+1, 00 say '³                 ³     ³                                      ³ TOTAL      ³ '
          @ prow(),   92-1 say '³'+ transform(t_amort,'999,999,999,999.99')
          @ prow(),  112-1 say '³'+ transform(t_osbal,'999,999,999,999.99') + ' ³'
          @ prow(),  145-1 say '³'+ transform(t_pastdue,'999,999,999,999.99')+' ³              ³                                        ³'
        endif

         t_amort   := 0
         t_pastdue := 0
         t_osbal   := 0
         ktr       := 0
         @ prow()+1, 00 say 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'

       endif

       @ prow()+1, 00 say '³                 ³     ³' +DISPCLNTNAME( (XTMP)->BRCODE+(XTMP)->CLNTCODE, 35 )+ '   ³            ³              ³                   ³                   ³            ³                   ³              ³                                        ³'      && RED 121305 left(_dispclntname( (xTMP)->brcode,(xTMP)->clntcode),35)

        if Signers->(dbseek(g_PAR_BRCH+(xTMP)->clntcode))
          @ prow()+1, 00 say '³                 ³     ³'+ padr(Signers->signer,30) + '        ³            ³              ³                   ³                   ³            ³                   ³              ³                                        ³'
       else
          @ prow()+1, 00 say '³                 ³     ³                                      ³            ³              ³                   ³                   ³            ³                   ³              ³                                        ³'
       endif

       linda := 1

    endif

    mdiffdate := 0

//if g_PAR_BRCH+(xTMP)->ACCTNO == "00105011040717631" 
//   alert(indexkey()+' you complete my faith')
//end if

//aga.08.05.2006.marked for modification
    Paysked->    ( dbsetorder(2) )
    Paysked->    ( dbseek(g_PAR_BRCH+(xTMP)->acctno+'D') )

//if g_PAR_BRCH+(xTMP)->ACCTNO == "00105011040717631" .and. !found()   
//   alert(indexkey()+' the sum of all fears')
//end if

    m_date := Paysked->paydate
    Payimage->(dbsetorder(1))
    Payimage->(dbseek(g_PAR_BRCH+(xTMP)->acctno+dtos(m_date),.t.))

    if g_PAR_BRCH+(xTMP)->ACCTNO != g_PAR_BRCH+payimage->acctno .and. found() //new records missing in payimage
// pepe       alert(g_PAR_BRCH+payimage->acctno+' <> '+g_PAR_BRCH+(xTMP)->acctno+' - soft seek failed')
// pepe       alert(dtos(m_date)+' earthbound spirits ' +g_PAR_BRCH+paysked->acctno+' '+g_PAR_BRCH+(xTMP)->ACCTNO)
// pepe       alert(dtos(Payimage->Paydate)+' personbound spirits ' +g_PAR_BRCH+payimage->acctno+' '+g_PAR_BRCH+(xTMP)->ACCTNO)

       Paysked->    ( dbsetorder(1) )
       Paysked->    ( dbseek(g_PAR_BRCH+(xTMP)->acctno+dtos(m_date)+'D',.t.) )
   
       mdiffdate := mdate-Paysked->Paydate

       new_date := if(mdiffdate/30 > int(mdiffdate/30), int(mdiffdate/30)+1, int(mdiffdate/30))
// pepe       alert ('new date ' + str(new_date))

    else
       mdiffdate := mdate-Payimage->Paydate
    end if


    if Payimage->(eof())
       Payimage->(dbgobottom())
    else
       Payimage->(dbskip(-1))
       if Payimage->acctno != (xTMP)->acctno .and. ;
          Payimage->brcode != g_PAR_BRCH
          Payimage->(dbseek('xxx'))
       endif
    endif
//.....................................


    new_date := if(mdiffdate/30 > int(mdiffdate/30), int(mdiffdate/30)+1, int(mdiffdate/30))
    if new_date = 0
       new_date:=1
    endif

    aadd ( arfacility,{ (xTMP)->fcltycode,; // 03.16.2004 abb
                        mtpastdue          ,;
                        (xTMP)->osbal     ;
                      } ;
         )

    @ prow()+1,00 say '³'      + padr(substr ( (xTMP)->Oldno ,1 ,5 ),5) + '-'+ padr(alltrim(_getalias((xTMP)->fcltycode )),9)
    @ prow(), 18  say '³'      + substr ( (xTMP)->acctno,10,5  )
    if (xTMP)->paymode == '1'        // PDC
       @ prow(), 24  say '³'   + substr ( (xTMP)->unit  ,1 ,34 )+'*'
    else
       @ prow(), 24  say '³'   + substr ( (xTMP)->unit  ,1 ,35 )
    endif

    @ prow(), 63  say '³'   + transform((xTMP)->valdate,'99/99/9999')
    ndiff := nrv   := ngd   := 0

    if left(alltrim((xTMP)->fcltycode),3) != '104'      // LOAN HAS NO GD/RV
       nrv   :=  ( (xTMP)->Rv/100 ) * (xTMP)->Principal
       ngd   :=  ( (xTMP)->GD/100 ) * (xTMP)->Principal
       ndiff := nrv - ngd
    endif

    @ prow(), 80-3-1  say '³'+ tran( ndiff,'999,999,999.99' )

    @ prow(), 92-1   say '³'+ iif(mamort<>0,transform(mamort,'999,999,999,999.99'), "     irregular")
    @ prow(), 112-1  say '³'+ transform(mosbal,'999,999,999,999.99')
    @ prow(), 132-1  say '³'+ transform(new_date, '99') + ' month/s'
    @ prow(), 145-1  say '³'+ transform(mtpastdue,'999,999,999,999.99')
    @ prow(), 165-1  say '³'+ transform((xTMP)->matdate,'99/99/9999')
    pasok := .f.

       Delqdtls->(dbgotop())

       __nrecno := Delqdtls->(recno())
       if Delqdtls->(dbseek(g_PAR_BRCH+(xTMP)->acctno))      // abb 06.28.2002
          __nrecno := Delqdtls->(recno())
       endif

       Delqdtls->(dbgoto(__nrecno))
       actnum  := Delqdtls->acctno
       ACTBRCD := DELQDTLS->BRCODE

       Do while alltrim(Delqdtls->acctno)  == alltrim(actnum)  .and. ;
                !Delqdtls->(eof()) .and. ;
                Delqdtls->brcode == g_PAR_BRCH

          if Delqdtls->acctno == (xTMP)->acctno .and. ;
             Delqdtls->brcode == g_PAR_BRCH

             if Delqdtls->date == mdate .and. ispacio == 0
                pasok := .t.
                @ prow(), 180-1 say  '³' + padr(delqdtls->status,40) + '³'
             elseif Delqdtls->date == mdate .and. ispacio <> 0
                pasok := .t.
                @ prow()+1,   00 say '³                 ³     ³                                      ³            ³              ³                   ³                   ³            ³                   ³              ³' + padr(delqdtls->status,40) + '³'
             else
                ispacio2:=1
             endif

          endif

          Delqdtls->(dbskip(+1))
          ispacio := 1
          if ispacio2 == 1
             ispacio  := 0
             ispacio2 := 0
          endif
       Enddo


       ispacio := 0

       ******if pasok == .f.

       if !pasok                 // = .f.

          rev      := 0
          delqdtls->(dbskip(-1))
          drevdate := Delqdtls->date

          if Delqdtls->(dbseek(g_PAR_BRCH+alltrim((xTMP)->acctno)))
             ***** if Delqdtls->(dbseek(alltrim((xTMP)->acctnum)))
             Do while alltrim(Delqdtls->acctno)  == alltrim(actnum) .and. ;
                      !Delqdtls->(bof()) .and.;
                      Delqdtls->brcode == g_PAR_BRCH

                if alltrim(Delqdtls->acctno) == alltrim((xTMP)->acctno) .and. ;
                   Delqdtls->brcode == g_PAR_BRCH

                   if drevdate == Delqdtls->date   .and. rev == 0
                      @ prow(), 180-1 say  '³' + padr(delqdtls->status,40) + '³'
                      rev++
                   elseif drevdate == Delqdtls->date .and. rev != 0
                        @ prow()+1,   00 say '³                 ³     ³                                      ³            ³              ³                   ³                   ³            ³                   ³              ³' + padr(delqdtls->status,40) + '³'

                      rev++
                   else
                      // until then my linda
                   endif

                endif

                Delqdtls->(dbskip(+1))
             Enddo
          else
             @ prow(), 180-1 say '³                                        ³'
          endif
       endif

//aga.08.05.2006.marked for modification 
       Paysked->(dbseek(g_PAR_BRCH+(xTMP)->acctno+'D'))
       Paysked->( dbsetorder(2) )

       clntflag   := (xTMP)->clntcode
       t_amort    += mamort
       t_osbal    += mosbal
       t_pastdue  += mtpastdue

       gt_amort   += mamort
       gt_osbal   += mosbal
       gt_pastdue += mtpastdue

       ktr++


    **endif

  endif


return nil

************************************
static function _getalias(cfacltycd )
************************************
local cretval := space(len(Facility->fcltyalias))
   if Facility->(dbseek(cfacltycd))
      cretval := Facility->fcltyalias
   endif
return cretval

************************************
*
static function amsr13head()
************************************
local  mdate := 'For the Month of ' + ;
                { 'January', 'February', 'March',;
                  'April'  , 'May'     , 'June' ,;
                  'July', 'August', 'September' ,;
                  'October', 'November', 'December' ;
                } [ mmonth ] +  ;
                ' ' + padr( myear, 4 )

setprc(0,0)
setfont('DRAFT')
setfont('ELITE')
@ prow()+1,03 say 'ACCOUNT MANAGEMENT SYSTEM'
@ prow()+1,03 say 'AMSR130b'
@ prow()  ,03+len('AMSR130b');
              say PADL( dtoc(DATE())+' '+TIME(), 90-len('AMSR130b'))
@ prow()+1,03 say PADC('ORIX METRO Leasing and Finance Corporation',90)
*********@ prow()+1,03 say PADC('CONSOLIDATED ORIX LEASING AND FINANCE CORPORATION',90)
SETFONT('BOLD')
@ prow()+1,03 say padc('WEEKLY DELINQUENCY REPORT',90)
SETFONT('UNBOLD')
@ prow()+1,03 say padc(mdate, 90)

return


******************************
*
static function print_head()
******************************
    memvar mtitle,mpage,gsys_name,gcompany,mlm,mmonth,mdays,myear
    eval ( {|| ;
              mtitle := 'Weekly Delinquency Report',;
              prnreptitle  ( 132,mlm,mpage,mtitle,'Program ID:AMSR130b',gsys_name,gcompany),;
              pagecenter   ( prow()+1,132,'As of '+fr0100month( trans(mmonth,'99') )+' '+trans(mdays,'99')+', '+trans(myear,'9999') );
           } ;
         )
       @ prow()+1,0 say ''
return nil

*********************************
*
static function print_subhead()
*********************************
setfont('CONDENSED')

/****************
eval({|| ;
        devpos( prow()+1, 01 ) , devout( "ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿" ),;
        devpos( prow()+1, 01 ) , devout( "³ Client LA No   ³ ACCT ³            CLIENT / PRINCIPAL        ³     DATE OF   ³ EXCESS GD/³   MONTHLY RATE    ³    OUTSTANDING    ³  MONTHS    ³     TOTAL AMOUNT  ³   MATURITY   ³             R E M A R K S              ³" ),;
        devpos( prow()+1, 01 ) , devout( "³                ³  NO  ³                COLLATERAL            ³    EXECUTION  ³ UNPAID RV ³  AMORTIZATION     ³      BALANCE      ³ PAST DUE   ³       PASTDUE     ³     DATE     ³                                        ³" ),;
        devpos( prow()+1, 01 ) , devout( "ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ" );
    })
*********************/

eval({|| ;
        devpos( prow()+1, 00 ) , devout( "ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿" ),;
        devpos( prow()+1, 00 ) , devout( "³ Client LA No    ³ACCT.³            CLIENT / PRINCIPAL        ³  DATE OF   ³  EXCESS GD/  ³   MONTHLY RATE    ³    OUTSTANDING    ³  MONTHS    ³     TOTAL AMOUNT  ³   MATURITY   ³             R E M A R K S              ³" ),;
        devpos( prow()+1, 00 ) , devout( "³                 ³ NO. ³                COLLATERAL            ³ EXECUTION  ³  UNPAID RV   ³  AMORTIZATION     ³      BALANCE      ³ PAST DUE   ³       PASTDUE     ³     DATE     ³                                        ³" ),;
        devpos( prow()+1, 00 ) , devout( "ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ" );
    })

return nil

********************************
static function amsr1300open()
********************************
   local mretval := .f.
   memvar g_cis_path

//aga.19.12.2005.delqdrop path
   if !netuse('&g_ams_path\delqdrop',.f.,5)
      return 
   endif
   set index to &g_ams_path\delqdrop
//...........................

    if netuse( '&g_AMS_PATH\Acctmast',.f.,5)
       set index to &g_AMS_PATH\Acctmast,;      &&BRCODE+ACCTNO
                    &g_AMS_PATH\Acctclnt,;      &&BRCODE+CLNTCODE+ACCTNO
                    &g_AMS_PATH\Sureclnt,;      &&BRCODE+SURETY+ACCTNO
                    &g_AMS_PATH\Acctacno        &&ACCTNAME+BRCODE+ACCTNO
       set order to 4
       if netuse( '&g_AMS_PATH\Paysked',.f.,5)
          set index to &g_AMS_PATH\Paysked, &g_AMS_PATH\Paystat //aga
          if netuse( '&g_AMS_PATH\Payimage',.f.,5)
             set index to &g_AMS_PATH\Payimage
             if netuse(  '&g_cis_path'+'\Client.dbf',.f.,5)
                set index  to &g_cis_path\Cliecd, &g_cis_path\Clienm
                if netuse( '&g_AMS_PATH\Delqdtls',.f.,5)
                   set index to &g_AMS_PATH\Delqdtls
                   if netuse(  '&g_cis_path'+'\Signers.dbf',.f.,5)
                      set index to &g_cis_path\Signers
                      if netuse(  '&g_AMS_PATH\Facility',.f.,5)
                         set index  to &g_AMS_PATH\Fcltycd
// EVR                   if netuse(   'Parametr',.f.,5 )
                            mretval := .t.
// EVR                   endif
                      endif
                   endif
                endif
             endif
          endif
      endif
   endif

return mretval
*                     End of the program ( amsr1300.prg )

function fBookamsr()
fShadow( 7, 3, 20, 74  , 2, 'w+/n', ' FACILITY ' )
@  8, 04 say ' Tag   Code     Alias                      Name                      '  color 'w+/bg'  && RED 020105
@  9, 04 say 'ÚÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'  color 'w/n'    && ÄÄÄ
@ 10, 04 say '³   ³       ³            ³                                          ³'  color 'w/n'
@ 11, 04 say '³   ³       ³            ³                                          ³'  color 'w/n'
@ 12, 04 say '³   ³       ³            ³                                          ³'  color 'w/n'
@ 13, 04 say '³   ³       ³            ³                                          ³'  color 'w/n'
@ 14, 04 say '³   ³       ³            ³                                          ³'  color 'w/n'
@ 15, 04 say '³   ³       ³            ³                                          ³'  color 'w/n'
@ 16, 04 say '³   ³       ³            ³                                          ³'  color 'w/n'
@ 17, 04 say '³   ³       ³            ³                                          ³'  color 'w/n'
@ 18, 04 say 'ÀÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'  color 'w/n'    && ÄÄÄ
@ 19, 04 say '<ESC> <ENTER>-Save  <S_bar>-Select/Unselect  <+/->Select/Unselect All '  color 'n/w'
@19, 05 say 'ESC'    color 'w+/w'
@19, 11 say 'ENTER'  color 'w+/w'
@19, 25 say 'S_BAR'  color 'w+/w'
@19, 50 say '+'      color 'w+/w'
@19, 52 say '-'      color 'w+/w'
@ 11, 73  , 16, 73   box repl( '°', 9 )                       color '+w/n'
@ 10, 73   say chr( 24 )                                    color 'n/w+'
@ 17, 73   say chr( 25 )                                    color 'n/w+'

return nil


function fUdf0700( a_, b_, c_ )

  local k := lastkey(), ret_val := AC_CONT, h

  memvar ind, mrow, mcolf //cpy_

  do case
    case a_ == AC_HITTOP
       ret_val := AC_ABORT
    case a_ == AC_HITBOTTOM
       ret_val := AC_ABORT

    case a_ == AC_IDLE .or. k == 255
      if len( aFacility ) > 9
        @ 10 + ind + 1, 73 say '°' color '+w/n'
        ind = min( ( b_ / len( aFacility ) ) * 6, 5 )
        @ 10 + ind + 1, 73 say 'Û' color 'w/n'
      endif

    case k == K_SPACEBAR
      aFacility[b_] := stuff ( aFacility[b_],1,1,;
                               if(substr(aFacility[b_],1,1) == ' ', 'û', ' ' ) )
      mrow     := b_
      mcol     := c_
      ret_val := AC_ABORT
    case k == 43 .or. k == 45
      waiton( 'a second pls.!',, 'w+*/r', 6 )
      for h := 1 to len( aFacility )
        //if not_just(aFacility[h])
        aFacility[ h ] := stuff( aFacility[ h ], 1, 1,;
        if( lastkey() == 43, 'û', ' ' ) )
        //endif
      next
      waitoff()
      mrow     := b_
      mcol     := c_
      ret_val  := AC_ABORT

    case k == K_ENTER .or. k == K_ESC
      mrow     := b_
      mcol     := c_
      ret_val := AC_ABORT

  endcase
return( ret_val )
*-------------------------------------------------------------------------------
STATIC FUNCTION TRANSFER(Type,xTMP)

LOCAL aSTRUC := {}

AADD( aSTRUC , {'ACCTNO'   ,'C',14,00} )
AADD( aSTRUC , {'CLNTCODE' ,'C',07,00} )
AADD( aSTRUC , {'CLNTNAME' ,'C',50,00} )
AADD( aSTRUC , {'ACCTNAME' ,'C',50,00} )
AADD( aSTRUC , {'FCLTYCODE','C',05,00} )
AADD( aSTRUC , {'PRINCIPAL','N',12,02} )
AADD( aSTRUC , {'UNIT'     ,'C',40,00} )
AADD( aSTRUC , {'GD'       ,'N',09,06} )
AADD( aSTRUC , {'RV'       ,'N',09,06} )
AADD( aSTRUC , {'OSBAL'    ,'N',12,02} )
AADD( aSTRUC , {'AMORT'    ,'N',12,02} )
AADD( aSTRUC , {'VALDATE'  ,'D',10,00} )
AADD( aSTRUC , {'PAYMODE'  ,'C',01,00} )
AADD( aSTRUC , {'PAYFREQ'  ,'C',01,00} )
AADD( aSTRUC , {'MATDATE'  ,'D',10,00} )
AADD( aSTRUC , {'OLDNO'    ,'C',20,00} )
AADD( aSTRUC , {'STATUS'   ,'C',01,00} )
AADD( aSTRUC , {'BRCODE'   ,'C',03,00} )

DBCREATE(xTMP,aSTRUC)

IF NETUSE('c:\'+xTMP,.F.,5)
   INDEX ON CLNTNAME+BRCODE+ACCTNO TO ('c:\'+xTMP)
   SET INDEX TO ('c:\'+xTMP)
ELSE
   RETURN
ENDIF

ACCTMAST->(DBSETORDER(1))
ACCTMAST->(DBSEEK(g_PAR_BRCH))

IF TYPE == 'A'
   ACCTMAST->(DBEVAL( {|| IF ( ( VAL(ACCTMAST->STATUS) < 3 .OR. VAL( ACCTMAST->STATUS) == 6 .AND.       ;
                                ACCTMAST->BRCODE == g_PAR_BRCH) .AND. ACCTMAST->VALDATE <= mDATE .AND.  ;
                                nCHOICE == _COMPANY_ACCOUNTS(xTMP)                                     ,;
                                POPULATE( xTMP )                                                       ,;
                                NIL )                                                                   ;
                      } ,,                                                                              ;
                      {|| !ACCTMAST->(EOF()) .AND. ACCTMAST->BRCODE == g_PAR_BRCH                       ;
                      }                                                                                 ;
                    )                                                                                   ;
             )

ELSEIF TYPE == 'B'
       ACCTMAST->(DBEVAL( {|| IF ( ( VAL(ACCTMAST->STATUS) < 3 .OR. VAL(ACCTMAST->STATUS) == 6 ) .AND. ;
                                   ACCTMAST->VALDATE <= mDATE .AND. ACCTMAST->BRCODE == g_PAR_BRCH    ,;
                                   POPULATE( xTMP )                                                   ,;
                                   NIL )                                                               ;
                          } ,,                                                                         ;
                          {|| !ACCTMAST->(EOF()) .AND. ACCTMAST->BRCODE == g_PAR_BRCH                  ;
                          }                                                                            ;
                        )                                                                              ;
                 )
ENDIF

RETURN
*-------------------------------------------------------------------------------
STATIC FUNCTION TRANSFER2(Type,xTMP)

LOCAL aSTRUC := {}
LOCAL SCR    := SAVESCREEN(11,31,13,50)
LOCAL cMSG   := 'Gathering data..'

@ 11,31 CLEAR TO 13,50
@ 11,31 TO 13,50
@ 12,33 SAY 'Gathering data..'  COLOR 'GR+*/BG'

AADD( aSTRUC , {'ACCTNO'   ,'C',14,00} )
AADD( aSTRUC , {'CLNTCODE' ,'C',07,00} )
AADD( aSTRUC , {'CLNTNAME' ,'C',50,00} )
AADD( aSTRUC , {'ACCTNAME' ,'C',50,00} )
AADD( aSTRUC , {'FCLTYCODE','C',05,00} )
AADD( aSTRUC , {'PRINCIPAL','N',12,02} )
AADD( aSTRUC , {'UNIT'     ,'C',40,00} )
AADD( aSTRUC , {'GD'       ,'N',09,06} )
AADD( aSTRUC , {'RV'       ,'N',09,06} )
AADD( aSTRUC , {'OSBAL'    ,'N',12,02} )
AADD( aSTRUC , {'AMORT'    ,'N',12,02} )
AADD( aSTRUC , {'VALDATE'  ,'D',10,00} )
AADD( aSTRUC , {'PAYMODE'  ,'C',01,00} )
AADD( aSTRUC , {'PAYFREQ'  ,'C',01,00} )
AADD( aSTRUC , {'MATDATE'  ,'D',10,00} )
AADD( aSTRUC , {'OLDNO'    ,'C',20,00} )
AADD( aSTRUC , {'STATUS'   ,'C',01,00} )
AADD( aSTRUC , {'BRCODE'   ,'C',03,00} )

DBCREATE('C:\'+xTMP,aSTRUC)

IF NETUSE('C:\'+xTMP,.F.,5)
   INDEX ON CLNTNAME+BRCODE+ACCTNO TO ('C:\'+xTMP)
   SET INDEX TO ('C:\'+xTMP)
ELSE
   RETURN
ENDIF

ACCTMAST->(DBSETORDER(1))
ACCTMAST->(DBSEEK(g_PAR_BRCH))

IF TYPE == 'A'

   DO WHILE !ACCTMAST->(EOF()) .AND. ACCTMAST->BRCODE == g_PAR_BRCH

      IF (VAL(ACCTMAST->STATUS) < 3 .OR. VAL( ACCTMAST->STATUS) == 6 .AND.     ;
         ACCTMAST->BRCODE == g_PAR_BRCH) .AND. ACCTMAST->VALDATE <= mDATE .AND.;
         nCHOICE == _COMPANY_ACCOUNTS(xTMP)

         POPULATE( xTMP )

      ENDIF

      ACCTMAST->(DBSKIP())
   ENDDO
   
       (xTMP)->(DBUNLOCK())
       (xTMP)->(DBCOMMIT())
   
   
ELSEIF TYPE == 'B'



       DO WHILE !ACCTMAST->(EOF()) .AND. ACCTMAST->BRCODE == g_PAR_BRCH




          IF (VAL(ACCTMAST->STATUS) < 3 .OR. VAL(ACCTMAST->STATUS) == 6 ) .AND. ;
             ACCTMAST->VALDATE <= mDATE .AND. ACCTMAST->BRCODE == g_PAR_BRCH


             POPULATE( xTMP )

          ENDIF

          ACCTMAST->(DBSKIP(+1))
       ENDDO
       (xTMP)->(DBUNLOCK())
       (xTMP)->(DBCOMMIT())

ENDIF

RESTSCREEN(11,31,13,50,SCR)

RETURN
*-------------------------------------------------------------------------------
FUNCTION POPULATE(xTMP)

(xTMP)->(DBAPPEND())
REPLACE (xTMP)->ACCTNO    WITH ACCTMAST->ACCTNO
REPLACE (xTMP)->CLNTCODE  WITH ACCTMAST->CLNTCODE
REPLACE (xTMP)->CLNTNAME  WITH DISPCLNTNAME(ACCTMAST->BRCODE+ACCTMAST->CLNTCODE,50)     &&RED 121305 _DISPCLNTNAME(ACCTMAST->BRCODE,ACCTMAST->CLNTCODE,50)
REPLACE (xTMP)->ACCTNAME  WITH ACCTMAST->ACCTNAME
REPLACE (xTMP)->FCLTYCODE WITH ACCTMAST->FCLTYCODE
REPLACE (xTMP)->PRINCIPAL WITH ACCTMAST->PRINCIPAL
REPLACE (xTMP)->UNIT      WITH ACCTMAST->UNIT
REPLACE (xTMP)->GD        WITH ACCTMAST->GD
REPLACE (xTMP)->RV        WITH ACCTMAST->RV
REPLACE (xTMP)->OSBAL     WITH ACCTMAST->OSBAL
REPLACE (xTMP)->AMORT     WITH ACCTMAST->AMORT
REPLACE (xTMP)->VALDATE   WITH ACCTMAST->VALDATE
REPLACE (xTMP)->PAYMODE   WITH ACCTMAST->PAYMODE
REPLACE (xTMP)->PAYFREQ   WITH ACCTMAST->PAYFREQ
REPLACE (xTMP)->MATDATE   WITH ACCTMAST->MATDATE
REPLACE (xTMP)->OLDNO     WITH ACCTMAST->OLDNO
REPLACE (xTMP)->STATUS    WITH ACCTMAST->STATUS
REPLACE (xTMP)->BRCODE    WITH ACCTMAST->BRCODE


RETURN

******************************         && RED COPIED IN THIS PRG FROM AMSR2200.PRG
static function xget_mdate( mrow )
******************************
    local mcolor := setcolor(), mcursor:= setcursor(), mretval, getlist := {}
    memvar mdate

    fshadow( mrow, 21, mrow + 2, 51, 2, 'gr+/g' )
    setcolor( 'w/g, w+/n,,, w+/g' )
    @ mrow + 1, 22 say 'Transaction Date ' get mdate  when .f. //when !empty( mdate := getdate( mdate, mrow + 1, 41, 'w/gr, gr+/gr,,, n/gr' ) )
    setcursor( 3 )
    read
    if ( lastkey()==K_ESC, mretval:=.f.,mretval:=.t. )
    setcolor( mcolor ); setcursor( mcursor )
return mretval