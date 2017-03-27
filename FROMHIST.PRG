****************************
*
static function _get_outs( )
****************************
   local nretval := &tempfile->credamt, ddate := ctod ('')
   local dretval := ctod('')
   local pgn:=1
   local tot_amrt := 0, tot_pen := 0, npent_s := 0,ncredamt:= &tempfile->Credamt
//   local tot_amrt := 0, tot_pen := 0, npent_s := 0,ncredamt:= Acctmast->Credamt
   local Pay_:={ 'Paymt',;              // 1
                 'Ret. Check',;         // 2
                 'ROPOA',;              // 3
                 'Db_Memo ',;           // 4
                 'Misposting',;         // 5
                 'Terminatx',;          // 6
                 'Cr_Memo  ',;          // 7
                 'REVIEW ',;            // 8
                 ' ',;                  // 9
                 'O_T Check',;          //10
                 'PDR ',;               //11
                 'LEGAL ',;             //12
                 'LEGAL ',;             //13
                 'Current',;            //14
                 'Current',;            //15
                 'Balance Forwarded' }  //16
   local tot_or:=0, tot_am := 0, tot_penal := 0
   local xoramount := xamort := xpenal:=0,pprd:={},pperiod,unpd_pen := 0
   local xacctno,xornum,xrefdate,xcode,nrow:= { 05,19,32,43,60,86,93,117 }
   memvar _ddate

   xblk := { || Paysked->Lastpay <= pdate }

   Amshist->  ( dbseek(&tempfile->Acctno) )
   ncredamt := &tempfile->Credamt

   do while Amshist->Acctno == &tempfile->Acctno .and. !Amshist->(eof())

         xrefdate  := Amshist->Refdate
         xornum    := Amshist->Ornumber
         xacctno   := Amshist->Acctno
         xcode     := Amshist->Paycode
         unpd_pen  += Amshist->Unpd_pnlty

         do while Amshist->Acctno   == xAcctno  .and. ;
                  Amshist->Ornumber == xornum   .and. ;
                  Amshist->Refdate  == xrefdate .and. ;
                  Amshist->Paycode  == xcode    .and. ;
                 !Amshist->(eof())

             if xrefdate <= _ddate

                xOramount += if ( val( Amshist->Paycode ) < 8,;
                                  Amshist->Oramount,;
                                  0;
                                )
                xamort    += Amshist->Amort
                xpenal    += Amshist->Penalty
                if ( !empty( Amshist->Paydate ) ,;
                      aadd ( pprd,Amshist->Paydate ),;
                      nil ;
                   )

             endif

             Amshist->(dbskip(+1))
         enddo

         pperiod := if ( len (pprd) > 0,;
                         dtoc( pprd[ 1 ] ) + ;
                         if ( len(pprd ) > 1,;
                              '-' +dtoc(atail(pprd)),;
                              ' ' ;
                            ),;
                         ' ' ;
                       )


         nretval -= (xamort)

         pprd      := {}
         tot_or    += xOramount
         tot_am    += xamort
         tot_penal += xPenal
         xoramount := xamort := xpenal:=0

   enddo



return nretval

****************************
static function _sked_open()
****************************
   local lretval := .t.

   if netuse( 'Acctmast',.f., 5 )
      set index to Acctmast,Acctclnt,Sureclnt,Acctfa2,Acctsub2,Acctaonm,Acctacno,Acctval
      Acctmast->( dbsetorder (1) )
   else
      lretval := .f.
   endif

   if netuse ( 'Stathist',.f.,5 )
      set index to Stathist
   else
      lretval := .f.
   endif

   if netuse( 'Amshist', .f., 10 )              && Account Payment history file
      ordlistadd( 'Amshist' )                   && set index on acctno
   else
      lretval := .f.
   endif
