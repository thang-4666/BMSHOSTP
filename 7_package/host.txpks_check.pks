SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_check
IS
   TYPE cimastcheck_rectype IS RECORD (
      actype           cimast.actype%TYPE,
      acctno           cimast.acctno%TYPE,
      ccycd            cimast.ccycd%TYPE,
      afacctno         cimast.afacctno%TYPE,
      custid           cimast.custid%TYPE,
      opndate          cimast.opndate%TYPE,
      clsdate          cimast.clsdate%TYPE,
      lastdate         cimast.lastdate%TYPE,
      dormdate         cimast.dormdate%TYPE,
      status           cimast.status%TYPE,
      pstatus          cimast.pstatus%TYPE,
      advanceline       number(20,0),
      balance          cimast.balance%TYPE,
      avlbal           number(38,4),
      cramt            cimast.cramt%TYPE,
      dramt            cimast.dramt%TYPE,
      crintacr         cimast.crintacr%TYPE,
      cidepofeeacr         cimast.cidepofeeacr%TYPE,
      crintdt          cimast.crintdt%TYPE,
      odintacr         cimast.odintacr%TYPE,
      odintdt          cimast.odintdt%TYPE,
      avrbal           cimast.avrbal%TYPE,
      mdebit           cimast.mdebit%TYPE,
      mcredit          cimast.mcredit%TYPE,
      aamt             cimast.aamt%TYPE,
      ramt             cimast.ramt%TYPE,
      bamt             cimast.bamt%TYPE,
      emkamt           cimast.emkamt%TYPE,
      mmarginbal       cimast.mmarginbal%TYPE,
      marginbal        cimast.marginbal%TYPE,
      iccfcd           cimast.iccfcd%TYPE,
      iccftied         cimast.iccftied%TYPE,
      odlimit          cimast.odlimit%TYPE,
      adintacr         cimast.adintacr%TYPE,
      adintdt          cimast.adintdt%TYPE,
      facrtrade        cimast.facrtrade%TYPE,
      facrdepository   cimast.facrdepository%TYPE,
      facrmisc         cimast.facrmisc%TYPE,
      minbal           cimast.minbal%TYPE,
      odamt            cimast.odamt%TYPE,
      dueamt            cimast.dueamt%TYPE,
      ovamt            cimast.ovamt%TYPE,
      namt             cimast.namt%TYPE,
      floatamt         cimast.floatamt%TYPE,
      holdbalance      cimast.holdbalance%TYPE,
      pendinghold      cimast.pendinghold%TYPE,
      pendingunhold    cimast.pendingunhold%TYPE,
      corebank         cimast.corebank%TYPE,
      allowcorebank    cimast.corebank%TYPE,
      receiving        cimast.receiving%TYPE,
      netting          cimast.netting%TYPE,
      mblock           cimast.mblock%TYPE,
      mrtype           varchar2(1),
      pp               NUMBER (38, 4),
      ppref               NUMBER (38, 4),
      avllimit         NUMBER (38, 4),
      deallimit         NUMBER (20, 4),
      navaccount       NUMBER (20, 4),
      outstanding      NUMBER (20, 4),
      se_navaccount       NUMBER (20, 4),
      se_outstanding      NUMBER (20, 4),
      mrirate          NUMBER (20, 4),
      avlwithdraw      NUMBER (20, 4),
      baldefovd        NUMBER (20, 4),
      baldefovd_released NUMBER (20, 4),
      dfdebtamt        NUMBER (20, 4),
      dfintdebtamt     NUMBER (20, 4),
      baldefovd_released_depofee NUMBER (20, 4),
      avladvance        number(38,4),
      advanceamount     number(38,4),
      paidamt           number(38,4),
      SEASS             number(38,4),
      SEAMT             number(38,4),
      marginrate        number(38,4),
      execbuyamt        number(38,4),
      bankbalance       number(38,4),
      bankavlbal        number(38,4),
      rcvamt            number(38,4),
      rcvadvamt         number(38,4),
      tdbalance         number(38,4),
      TDINTAMT          number(38,4),
      TDODAMT           number(38,4),
      TDODINTACR        number(38,4),
      CALLAMT           number(38,4),
      ADDAMT            number(38,4),
      depofeeamt            number(38,4),
      BALDEFOVD_HOLD_DEPOFEEAMT     NUMBER(20,4),
      baldefovd_released_adv            number(38,4),
      clamtlimit            AFMAST.clamtlimit%TYPE  ,
      dclamtlimit            number(38,4)
   );

   TYPE cimastcheck_arrtype IS TABLE OF cimastcheck_rectype
      INDEX BY PLS_INTEGER;

   FUNCTION fn_cimastcheck (
      pv_condvalue   IN   VARCHAR2,
      pv_tblname     IN   VARCHAR2,
      pv_fldkey      IN   VARCHAR2
   )
      RETURN cimastcheck_arrtype;

   TYPE semastcheck_rectype IS RECORD (
      actype          semast.actype%TYPE,
      acctno          semast.acctno%TYPE,
      codeid          semast.codeid%TYPE,
      afacctno        semast.afacctno%TYPE,
      opndate         semast.opndate%TYPE,
      clsdate         semast.clsdate%TYPE,
      lastdate        semast.lastdate%TYPE,
      status          semast.status%TYPE,
      pstatus         semast.pstatus%TYPE,
      irtied          semast.irtied%TYPE,
      ircd            semast.ircd%TYPE,
      costprice       semast.costprice%TYPE,
      trade           semast.trade%TYPE,
      mortage         semast.mortage%TYPE,
      dfmortage       semast.mortage%TYPE,
      margin          semast.margin%TYPE,
      netting         semast.netting%TYPE,
      standing        semast.standing%TYPE,
      withdraw        semast.withdraw%TYPE,
      deposit         semast.deposit%TYPE,
      loan            semast.loan%TYPE,
      blocked         semast.blocked%TYPE,
      receiving       semast.receiving%TYPE,
      transfer        semast.transfer%TYPE,
      prevqtty        semast.prevqtty%TYPE,
      dcrqtty         semast.dcrqtty%TYPE,
      dcramt          semast.dcramt%TYPE,
      depofeeacr      semast.depofeeacr%TYPE,
      repo            semast.repo%TYPE,
      pending         semast.pending%TYPE,
      tbaldepo        semast.tbaldepo%TYPE,
      custid          semast.custid%TYPE,
      costdt          semast.costdt%TYPE,
      secured         semast.secured%TYPE,
      iccfcd          semast.iccfcd%TYPE,
      iccftied        semast.iccftied%TYPE,
      tbaldt          semast.tbaldt%TYPE,
      senddeposit     semast.senddeposit%TYPE,
      sendpending     semast.sendpending%TYPE,
      ddroutqtty      semast.ddroutqtty%TYPE,
      ddroutamt       semast.ddroutamt%TYPE,
      dtoclose        semast.dtoclose%TYPE,
      sdtoclose       semast.sdtoclose%TYPE,
      qtty_transfer   semast.qtty_transfer%TYPE,
      trading         semast.trade%TYPE,
      EMKQTTY         semast.EMKQTTY%TYPE,
      BLOCKWITHDRAW         semast.BLOCKWITHDRAW%TYPE,
      BLOCKDTOCLOSE         semast.BLOCKDTOCLOSE%TYPE,
      absstanding           semast.standing%TYPE
   );

   TYPE semastcheck_arrtype IS TABLE OF semastcheck_rectype
      INDEX BY PLS_INTEGER;

   TYPE afmastcheck_rectype IS RECORD (
      actype            afmast.actype%TYPE,
      custid            afmast.custid%TYPE,
      acctno            afmast.acctno%TYPE,
      aftype            afmast.aftype%TYPE,
      tradefloor        cfmast.tradefloor%TYPE,
      tradetelephone    cfmast.tradetelephone%TYPE,
      tradeonline       cfmast.tradeonline%TYPE,
      pin               cfmast.pin%TYPE,
      bankacctno        afmast.bankacctno%TYPE,
      bankname          afmast.bankname%TYPE,
      swiftcode         afmast.swiftcode%TYPE,
      email             cfmast.email%TYPE,
      address           cfmast.address%TYPE,
      fax               cfmast.fax%TYPE,
      lastdate          afmast.lastdate%TYPE,
      status            afmast.status%TYPE,
      pstatus           afmast.pstatus%TYPE,
      advanceline       afmast.advanceline%TYPE,
      bratio            afmast.bratio%TYPE,
      termofuse         afmast.termofuse%TYPE,
      description       afmast.description%TYPE,
      isotc             afmast.isotc%TYPE,
      consultant        cfmast.consultant%TYPE,
      pisotc            afmast.pisotc%TYPE,
      opndate           afmast.opndate%TYPE,
      corebank          afmast.corebank%TYPE,
      via               afmast.via%type,
      mrirate           afmast.mrirate%TYPE,
      mrmrate           afmast.mrmrate%TYPE,
      mrlrate           afmast.mrlrate%TYPE,
      mrcrlimit         afmast.mrcrlimit%TYPE,
      mrcrlimitmax      afmast.mrcrlimitmax%TYPE,
      groupleader       afmast.groupleader%TYPE,
      t0amt             afmast.t0amt%TYPE,
      mrtype            CHAR (1),
      CUSTODIANTYP      char(1),
      CUSTTYPE          char(1),
      idexpdays         NUMBER(20),
      WARNINGTERMOFUSE  number(20),
      CLAMTLIMIT         afmast.CLAMTLIMIT%TYPE
   );

   TYPE afmastcheck_arrtype IS TABLE OF afmastcheck_rectype
      INDEX BY PLS_INTEGER;

   TYPE sewithdrawcheck_rectype IS RECORD (
      avlsewithdraw   NUMBER (20, 4)
   );

   TYPE sewithdrawcheck_arrtype IS TABLE OF sewithdrawcheck_rectype
      INDEX BY PLS_INTEGER;


   TYPE odmastcheck_rectype IS RECORD (
      ACTYPE                odmast.ACTYPE%TYPE,
      ORDERID                odmast.ORDERID%TYPE,
      CODEID                odmast.CODEID%TYPE,
      AFACCTNO                odmast.AFACCTNO%TYPE,
      SEACCTNO                odmast.SEACCTNO%TYPE,
      CIACCTNO                odmast.CIACCTNO%TYPE,
      TXNUM                odmast.TXNUM%TYPE,
      TXDATE                odmast.TXDATE%TYPE,
      TXTIME                odmast.TXTIME%TYPE,
      EXPDATE                odmast.EXPDATE%TYPE,
      BRATIO                odmast.BRATIO%TYPE,
      TIMETYPE                odmast.TIMETYPE%TYPE,
      EXECTYPE                odmast.EXECTYPE%TYPE,
      NORK                odmast.NORK%TYPE,
      MATCHTYPE                odmast.MATCHTYPE%TYPE,
      VIA                odmast.VIA%TYPE,
      CLEARDAY                odmast.CLEARDAY%TYPE,
      CLEARCD                odmast.CLEARCD%TYPE,
      ORSTATUS                odmast.ORSTATUS%TYPE,
      PRICETYPE                odmast.PRICETYPE%TYPE,
      QUOTEPRICE                odmast.QUOTEPRICE%TYPE,
      STOPPRICE                odmast.STOPPRICE%TYPE,
      LIMITPRICE                odmast.LIMITPRICE%TYPE,
      ORDERQTTY                odmast.ORDERQTTY%TYPE,
      REMAINQTTY                odmast.REMAINQTTY%TYPE,
      EXECQTTY                odmast.EXECQTTY%TYPE,
      STANDQTTY                odmast.STANDQTTY%TYPE,
      CANCELQTTY                odmast.CANCELQTTY%TYPE,
      ADJUSTQTTY                odmast.ADJUSTQTTY%TYPE,
      REJECTQTTY                odmast.REJECTQTTY%TYPE,
      REJECTCD                odmast.REJECTCD%TYPE,
      CUSTID                odmast.CUSTID%TYPE,
      EXPRICE                odmast.EXPRICE%TYPE,
      EXQTTY                odmast.EXQTTY%TYPE,
      ICCFCD                odmast.ICCFCD%TYPE,
      ICCFTIED                odmast.ICCFTIED%TYPE,
      EXECAMT                odmast.EXECAMT%TYPE,
      EXAMT                odmast.EXAMT%TYPE,
      FEEAMT                odmast.FEEAMT%TYPE,
      CONSULTANT                odmast.CONSULTANT%TYPE,
      VOUCHER                odmast.VOUCHER%TYPE,
      ODTYPE                odmast.ODTYPE%TYPE,
      FEEACR                odmast.FEEACR%TYPE,
      PORSTATUS                odmast.PORSTATUS%TYPE,
      RLSSECURED                odmast.RLSSECURED%TYPE,
      SECUREDAMT                odmast.SECUREDAMT%TYPE,
      MATCHAMT                odmast.MATCHAMT%TYPE,
      DELTD                odmast.DELTD%TYPE,
      REFORDERID                odmast.REFORDERID%TYPE,
      BANKTRFAMT                odmast.BANKTRFAMT%TYPE,
      BANKTRFFEE                odmast.BANKTRFFEE%TYPE,
      EDSTATUS                odmast.EDSTATUS%TYPE,
      CORRECTIONNUMBER                odmast.CORRECTIONNUMBER%TYPE,
      CONTRAFIRM                odmast.CONTRAFIRM%TYPE,
      TRADERID                odmast.TRADERID%TYPE,
      CLIENTID                odmast.CLIENTID%TYPE,
      CONFIRM_NO                odmast.CONFIRM_NO%TYPE,
      FOACCTNO                odmast.FOACCTNO%TYPE,
      HOSESESSION                odmast.HOSESESSION%TYPE,
      CONTRAORDERID                odmast.CONTRAORDERID%TYPE,
      PUTTYPE                odmast.PUTTYPE%TYPE,
      CONTRAFRM                odmast.CONTRAFRM %TYPE
   );

   TYPE odmastcheck_arrtype IS TABLE OF odmastcheck_rectype
      INDEX BY PLS_INTEGER;

    TYPE lnmastcheck_rectype IS RECORD (
        ACTYPE         LNMAST.ACTYPE%TYPE,
        ACCTNO         LNMAST.ACCTNO%TYPE,
        CCYCD         LNMAST.CCYCD%TYPE,
        BANKID         LNMAST.BANKID%TYPE,
        APPLID         LNMAST.APPLID%TYPE,
        OPNDATE         LNMAST.OPNDATE%TYPE,
        EXPDATE         LNMAST.EXPDATE%TYPE,
        EXTDATE         LNMAST.EXTDATE%TYPE,
        CLSDATE         LNMAST.CLSDATE%TYPE,
        RLSDATE         LNMAST.RLSDATE%TYPE,
        LASTDATE         LNMAST.LASTDATE%TYPE,
        ACRDATE         LNMAST.ACRDATE%TYPE,
        OACRDATE         LNMAST.OACRDATE%TYPE,
        STATUS         LNMAST.STATUS%TYPE,
        PSTATUS         LNMAST.PSTATUS%TYPE,
        TRFACCTNO         LNMAST.TRFACCTNO%TYPE,
        PRINAFT         LNMAST.PRINAFT%TYPE,
        INTAFT         LNMAST.INTAFT%TYPE,
        LNTYPE         LNMAST.LNTYPE%TYPE,
        LNCLDR         LNMAST.LNCLDR%TYPE,
        PRINFRQ         LNMAST.PRINFRQ%TYPE,
        PRINPERIOD         LNMAST.PRINPERIOD%TYPE,
        INTFRGCD         LNMAST.INTFRGCD%TYPE,
        INTDAY         LNMAST.INTDAY%TYPE,
        INTPERIOD         LNMAST.INTPERIOD%TYPE,
        NINTCD         LNMAST.NINTCD%TYPE,
        OINTCD         LNMAST.OINTCD%TYPE,
        RATE1         LNMAST.RATE1%TYPE,
        RATE2         LNMAST.RATE2%TYPE,
        RATE3         LNMAST.RATE3%TYPE,
        OPRINFRQ         LNMAST.OPRINFRQ%TYPE,
        OPRINPERIOD         LNMAST.OPRINPERIOD%TYPE,
        OINTFRQCD         LNMAST.OINTFRQCD%TYPE,
        OINTDAY         LNMAST.OINTDAY%TYPE,
        ORATE1         LNMAST.ORATE1%TYPE,
        ORATE2         LNMAST.ORATE2%TYPE,
        ORATE3         LNMAST.ORATE3%TYPE,
        DRATE         LNMAST.DRATE%TYPE,
        APRLIMIT         LNMAST.APRLIMIT%TYPE,
        RLSAMT         LNMAST.RLSAMT%TYPE,
        PRINPAID         LNMAST.PRINPAID%TYPE,
        PRINNML         LNMAST.PRINNML%TYPE,
        PRINOVD         LNMAST.PRINOVD%TYPE,
        INTNMLACR         LNMAST.INTNMLACR%TYPE,
        INTOVDACR         LNMAST.INTOVDACR%TYPE,
        INTNMLPBL         LNMAST.INTNMLPBL%TYPE,
        INTNMLOVD         LNMAST.INTNMLOVD%TYPE,
        INTDUE         LNMAST.INTDUE%TYPE,
        INTPAID         LNMAST.INTPAID%TYPE,
        INTPREPAID         LNMAST.INTPREPAID%TYPE,
        NOTES         LNMAST.NOTES%TYPE,
        LNCLASS         LNMAST.LNCLASS%TYPE,
        ADVPAY         LNMAST.ADVPAY%TYPE,
        ADVPAYFEE         LNMAST.ADVPAYFEE%TYPE,
        ORLSAMT         LNMAST.ORLSAMT%TYPE,
        OPRINPAID         LNMAST.OPRINPAID%TYPE,
        OPRINNML         LNMAST.OPRINNML%TYPE,
        OPRINOVD         LNMAST.OPRINOVD%TYPE,
        OINTNMLACR         LNMAST.OINTNMLACR%TYPE,
        OINTNMLOVD         LNMAST.OINTNMLOVD%TYPE,
        OINTOVDACR         LNMAST.OINTOVDACR%TYPE,
        OINTDUE         LNMAST.OINTDUE%TYPE,
        OINTPAID         LNMAST.OINTPAID%TYPE,
        OINTPREPAID         LNMAST.OINTPREPAID%TYPE,
        FEE         LNMAST.FEE%TYPE,
        FEEPAID         LNMAST.FEEPAID%TYPE,
        FEEDUE         LNMAST.FEEDUE%TYPE,
        FEEOVD         LNMAST.FEEOVD%TYPE,
        FEEPAID2         LNMAST.FEEPAID2%TYPE
   );

   TYPE lnmastcheck_arrtype IS TABLE OF lnmastcheck_rectype
      INDEX BY PLS_INTEGER;

    TYPE dfmastcheck_rectype IS RECORD (
        ACCTNO        dfmast.ACCTNO%TYPE,
        AFACCTNO        dfmast.AFACCTNO%TYPE,
        LNACCTNO        dfmast.LNACCTNO%TYPE,
        FULLNAME        cfmast.fullname%type,
        TXDATE        dfmast.TXDATE%TYPE,
        TXNUM        dfmast.TXNUM%TYPE,
        TXTIME        dfmast.TXTIME%TYPE,
        ACTYPE        dfmast.ACTYPE%TYPE,
        RRTYPE        dfmast.RRTYPE%TYPE,
        DFTYPE        dfmast.DFTYPE%TYPE,
        CUSTBANK        dfmast.CUSTBANK%TYPE,
        LNTYPE        dfmast.LNTYPE%TYPE,
        FEE        dfmast.FEE%TYPE,
        FEEMIN        dfmast.FEEMIN%TYPE,
        TAX        dfmast.TAX%TYPE,
        AMTMIN        dfmast.AMTMIN%TYPE,
        CODEID        dfmast.CODEID%TYPE,
        SYMBOL          varchar2(20),
        REFPRICE        dfmast.REFPRICE%TYPE,
        DFPRICE        dfmast.DFPRICE%TYPE,
        TRIGGERPRICE        dfmast.TRIGGERPRICE%TYPE,
        DFRATE        dfmast.DFRATE%TYPE,
        IRATE        dfmast.IRATE%TYPE,
        MRATE        dfmast.MRATE%TYPE,
        LRATE        dfmast.LRATE%TYPE,
        CALLTYPE        varchar2(500),
        DFQTTY        dfmast.DFQTTY%TYPE,
        BQTTY        dfmast.BQTTY%TYPE,
        RCVQTTY        dfmast.RCVQTTY%TYPE,
        CARCVQTTY        dfmast.CARCVQTTY%TYPE,
        BLOCKQTTY        dfmast.BLOCKQTTY%TYPE,
        RLSQTTY        dfmast.RLSQTTY%TYPE,
        DFAMT        dfmast.DFAMT%TYPE,
        RLSAMT        dfmast.RLSAMT%TYPE,
        AMT        dfmast.AMT%TYPE,
        INTAMTACR        dfmast.INTAMTACR%TYPE,
        FEEAMT        dfmast.FEEAMT%TYPE,
        RLSFEEAMT        dfmast.RLSFEEAMT%TYPE,
        STATUS        dfmast.STATUS%TYPE,
        DFREF        dfmast.DFREF%TYPE,
        DESCRIPTION        dfmast.DESCRIPTION%TYPE,
        PRINNML        lnmast.PRINNML%TYPE,
        PRINOVD        lnmast.PRINOVD%TYPE,
        INTNMLACR        lnmast.INTNMLACR%TYPE,
        INTOVDACR        lnmast.INTOVDACR%TYPE,
        INTNMLOVD        lnmast.INTNMLOVD%TYPE,
        INTDUE        lnmast.INTDUE%TYPE,
        INTPREPAID        lnmast.INTPREPAID%TYPE,
        OPRINNML        lnmast.OPRINNML%TYPE,
        OPRINOVD        lnmast.OPRINOVD%TYPE,
        OINTNMLACR        lnmast.OINTNMLACR%TYPE,
        OINTOVDACR        lnmast.OINTOVDACR%TYPE,
        OINTNMLOVD        lnmast.OINTNMLOVD%TYPE,
        OINTDUE        lnmast.OINTDUE%TYPE,
        OINTPREPAID        lnmast.OINTPREPAID%TYPE,
        FEEDUE        lnmast.FEEDUE%TYPE,
        FEEOVD        lnmast.FEEOVD%TYPE,
        DEALAMT         number(20,4),
        DEALFEE         number(20,4),
        RTT              number(20,4),
        REMAINQTTY    number(20,4),
        AVLFEEAMT        number(20,4),
        ODAMT        number(20,4),
        TAMT         number(20,4),
        CALLAMT     number(20,4),
        AVLRLSQTTY  number(20,4),
        AVLRLSAMT   number(20,4),
        DFTRADING      number(20,0),
        SECURED    number(20,0));
   TYPE dfmastcheck_arrtype IS TABLE OF dfmastcheck_rectype
      INDEX BY PLS_INTEGER;

    --TungNT added
   TYPE crbtrflogcheck_rectype IS RECORD (
        AUTOID crbtrflog.AUTOID%TYPE,
        VERSION crbtrflog.VERSION%TYPE,
        VERSIONLOCAL crbtrflog.VERSIONLOCAL%TYPE,
        TXDATE crbtrflog.TXDATE%TYPE,
        CREATETST crbtrflog.CREATETST%TYPE,
        SENDTST crbtrflog.SENDTST%TYPE,
        REFBANK crbtrflog.REFBANK%TYPE,
        TRFCODE crbtrflog.TRFCODE%TYPE,
        STATUS crbtrflog.STATUS%TYPE,
        PSTATUS crbtrflog.PSTATUS%TYPE,
        ERRCODE crbtrflog.ERRCODE%TYPE,
        FEEDBACK crbtrflog.FEEDBACK%TYPE,
        ERRSTS crbtrflog.ERRSTS%TYPE,
        REFVERSION crbtrflog.REFVERSION%TYPE,
        NOTES crbtrflog.NOTES%TYPE,
        TLID crbtrflog.TLID%TYPE,
        OFFID crbtrflog.OFFID%TYPE
   );

   TYPE crbtrflogcheck_arrtype IS TABLE OF crbtrflogcheck_rectype
      INDEX BY PLS_INTEGER;


TYPE crbdefbankcheck_rectype IS RECORD (
        AUTOID crbdefbank.AUTOID%TYPE,
        BANKCODE crbdefbank.BANKCODE%TYPE,
        ROOTCODE crbdefbank.ROOTCODE%TYPE,
        BANKNAME crbdefbank.BANKNAME%TYPE,
        USERIDKEY crbdefbank.USERIDKEY%TYPE,
        ACCESSKEY crbdefbank.ACCESSKEY%TYPE,
        PRIVATEKEY crbdefbank.PRIVATEKEY%TYPE,
        STATUS crbdefbank.STATUS%TYPE,
        PASSWORD crbdefbank.PASSWORD%TYPE,
        PFXKEYNAME crbdefbank.PFXKEYNAME%TYPE,
        PFXKEYPASS crbdefbank.PFXKEYPASS%TYPE,
        MINAMOUNTI crbdefbank.MINAMOUNTI%TYPE,
        MINAMOUNTG crbdefbank.MINAMOUNTG%TYPE,
        SIGNER crbdefbank.SIGNER%TYPE,
        SIGNERPASS crbdefbank.SIGNERPASS%TYPE,
        RECEIVER crbdefbank.RECEIVER%TYPE
   );

   TYPE crbdefbankcheck_arrtype IS TABLE OF crbdefbankcheck_rectype
      INDEX BY PLS_INTEGER;
   --End

  FUNCTION fn_afmastcheck (
      pv_condvalue   IN   VARCHAR2,
      pv_tblname     IN   VARCHAR2,
      pv_fldkey      IN   VARCHAR2
   )
      RETURN afmastcheck_arrtype;
  FUNCTION fn_sewithdrawcheck (
      pv_condvalue   IN   VARCHAR2,
      pv_tblname     IN   VARCHAR2,
      pv_fldkey      IN   VARCHAR2
   )
      RETURN sewithdrawcheck_arrtype;
  FUNCTION fn_semastcheck (
      pv_condvalue   IN   VARCHAR2,
      pv_tblname     IN   VARCHAR2,
      pv_fldkey      IN   VARCHAR2
   )
      RETURN semastcheck_arrtype;
  FUNCTION fn_dfmastcheck (
      pv_condvalue   IN   VARCHAR2,
      pv_tblname     IN   VARCHAR2,
      pv_fldkey      IN   VARCHAR2
   )
      RETURN dfmastcheck_arrtype;

FUNCTION fn_aftxmapcheck (
      pv_acctno   IN   VARCHAR2,
      pv_tblname     IN   VARCHAR2,
      pv_acfld       IN varchar2,
      pv_tltxcd in varchar2
   )
      RETURN VARCHAR2;
     PROCEDURE pr_txcorecheck (
        pv_refcursor   IN OUT   pkg_report.ref_cursor,
        pv_condvalue   IN       VARCHAR2,
        pv_tblname     IN       VARCHAR2,
        pv_fldkey      IN       VARCHAR2,
        pv_busdate      IN       VARCHAR2
     );

END;
 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY txpks_check
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   PROCEDURE pr_txcorecheck (
      pv_refcursor   IN OUT   pkg_report.ref_cursor,
      pv_condvalue   IN       VARCHAR2,
      pv_tblname     IN       VARCHAR2,
      pv_fldkey      IN       VARCHAR2,
      pv_busdate      IN       VARCHAR2
   )
   IS
      v_fldkey                VARCHAR2 (50);
      v_tblname               VARCHAR2 (50);
      v_txdate                DATE;
      v_cmdsql                VARCHAR2 (2000);
      v_margintype            CHAR (1);
      v_actype                VARCHAR2 (4);
      v_groupleader           VARCHAR2 (10);
      v_baldefovd             NUMBER (20, 0);
      v_pp                    NUMBER (20, 0);
      v_avllimit              NUMBER (20, 0);
      v_navaccount            NUMBER (20, 0);
      v_outstanding           NUMBER (20, 0);
      v_mrirate               NUMBER (20, 4);
      v_deallimit             number(20,4);
      l_cimastcheck_rectype   cimastcheck_rectype;
      l_cimastcheck_arrtype   cimastcheck_arrtype;
      l_ismarginallow varchar2(1);
      l_count number;
      l_isMarginAcc varchar2(2);
   BEGIN                                                               -- Proc
      v_tblname := UPPER (pv_tblname);
      v_fldkey := pv_fldkey;

      SELECT TO_DATE (varvalue, 'dd/MM/yyyy')
        INTO v_txdate
        FROM sysvar
       WHERE UPPER (varname) = 'CURRDATE';

    plog.setbeginsection(pkgctx, 'pr_txcorecheck');
    plog.debug(pkgctx, 'pv_condvalue=' || pv_condvalue || '::pv_tblname=' || pv_tblname || '::pv_fldkey=' || pv_fldkey);

    if v_tblName = 'ODMAST' then
        OPEN PV_REFCURSOR FOR
        SELECT * FROM ODMAST WHERE ORDERID = pv_CONDVALUE;
    elsif v_tblName = 'FNMAST' then
        OPEN PV_REFCURSOR FOR
        SELECT FNMAST.*, FNTYPE.FNTYPE, FNTYPE.CODEID FROM FNMAST, FNTYPE
        WHERE FNMAST.ACCTNO = pv_CONDVALUE AND FNTYPE.ACTYPE = FNMAST.ACTYPE;
    elsif v_tblName = 'TDMAST' then
        OPEN PV_REFCURSOR FOR
        SELECT TXDATE, TXNUM, ACCTNO, AFACCTNO, ACTYPE, STATUS, PSTATUS, DELTD, CIACCTNO,
               CUSTBANK, TDSRC, TDTYPE, ORGAMT, BALANCE, PRINTPAID, AUTOPAID, INTNMLACR, INTPAID,
               TAXRATE, BONUSRATE, TPR, SCHDTYPE, INTRATE, TERMCD, TDTERM, BREAKCD, MINBRTERM, INTTYPBRCD,
               FLINTRATE, OPNDATE, FRDATE, TODATE, AUTORND, INTDUECD, INTFRQ, BUYINGPOWER, MORTGAGE,
               BALANCE-MORTGAGE AVLWITHDRAW, BLOCKAMT
        FROM TDMAST WHERE ACCTNO = pv_CONDVALUE;
    elsif v_tblName = 'OOD' then
        OPEN PV_REFCURSOR FOR
        SELECT * FROM OOD WHERE ORGORDERID = pv_CONDVALUE;

    elsif v_tblName = 'LNMAST' then
        OPEN PV_REFCURSOR FOR
        SELECT ACTYPE,ACCTNO,CCYCD,BANKID,APPLID,OPNDATE,EXPDATE,EXTDATE,CLSDATE,RLSDATE,LASTDATE,ACRDATE,OACRDATE,STATUS,PSTATUS,
            TRFACCTNO,PRINAFT,INTAFT,LNTYPE,LNCLDR,PRINFRQ,PRINPERIOD,INTFRGCD,INTDAY,INTPERIOD,NINTCD,OINTCD,RATE1,RATE2,RATE3,
            OPRINFRQ,OPRINPERIOD,OINTFRQCD,OINTDAY,ORATE1,ORATE2,ORATE3,DRATE,APRLIMIT,RLSAMT,PRINPAID,
            ceil(PRINNML) PRINNML, ceil(PRINOVD) PRINOVD,
            ceil(INTNMLACR) INTNMLACR, ceil(INTOVDACR) INTOVDACR, INTNMLPBL, ceil(INTNMLOVD) INTNMLOVD,
            INTDUE,INTPAID,INTPREPAID,NOTES,LNCLASS,ADVPAY,ADVPAYFEE,
            ORLSAMT,OPRINPAID,OPRINNML,OPRINOVD,ceil(OINTNMLACR) OINTNMLACR,ceil(OINTNMLOVD) OINTNMLOVD,
            ceil(OINTOVDACR) OINTOVDACR,OINTDUE,OINTPAID,OINTPREPAID,
            FEE,FEEPAID,FEEDUE,FEEOVD,FEEPAID2,FTYPE,LAST_CHANGE
        FROM LNMAST
        WHERE acctno = pv_CONDVALUE;

    elsif v_tblName = 'CIMAST' then
        SELECT MR.MRTYPE,af.actype,mst.groupleader into v_margintype,v_actype,v_groupleader from afmast mst,aftype af, mrtype mr where mst.actype=af.actype and af.mrtype=mr.actype and mst.acctno=pv_CONDVALUE;
        if v_margintype='N' or v_margintype='L' then
            --Tai khoan binh thuong khong Margin
            OPEN PV_REFCURSOR FOR
                SELECT ci.actype,ci.acctno,ci.ccycd,ci.afacctno,ci.custid,ci.opndate,ci.clsdate,ci.lastdate,ci.dormdate,ci.status,ci.pstatus,
                ci.balance -nvl(secureamt,0) - ci.trfbuyamt balance,
                ci.balance  + nvl(adv.avladvance,0) avlbal,
                ci.DFDEBTAMT, ci.HOLDMNLAMT,
                ci.cramt,ci.dramt,ci.crintacr,ci.cidepofeeacr,ci.crintdt,ci.odintacr,ci.odintdt,ci.avrbal,ci.mdebit,ci.mcredit,ci.aamt,ci.ramt,
                nvl(secureamt,0) + ci.trfbuyamt bamt,
                ci.emkamt,ci.mmarginbal,ci.marginbal,ci.iccfcd,ci.iccftied,ci.odlimit,ci.adintacr,ci.adintdt,
                ci.facrtrade,ci.facrdepository,ci.facrmisc,ci.minbal,ci.odamt,ci.namt,ci.floatamt,ci.holdbalance,
                ci.pendinghold,ci.pendingunhold,
                ci.corebank,(case when ci.corebank = 'Y' then ci.corebank else af.alternateacct end) allowcorebank,
                ci.receiving,ci.netting,ci.mblock,
                greatest(nvl(adv.avladvance,0) + balance  - odamt - ci.dfdebtamt - ci.dfintdebtamt - NVL (advamt, 0) - nvl(secureamt,0)- ci.trfbuyamt - ramt-nvl(pd.dealpaidamt,0) - ci.depofeeamt-CEIL(CI.CIDEPOFEEACR),0) AVLWITHDRAW,
                   greatest(
                        nvl(adv.avladvance,0) + balance - ci.buysecamt - ovamt - dueamt - ci.dfdebtamt - ci.dfintdebtamt - NVL (overamt, 0) - nvl(secureamt,0) + LEAST(AF.MRCRLIMIT,nvl(secureamt,0)+ ci.trfbuyamt) - ci.trfbuyamt - ramt-nvl(pd.dealpaidamt,0) - CI.DEPOFEEAMT-CEIL(CI.CIDEPOFEEACR)
                        ,0) BALDEFOVD,
                greatest(nvl(adv.avladvance,0) + balance  - odamt - ci.dfdebtamt - ci.dfintdebtamt - NVL (advamt, 0) - nvl(secureamt,0)+ LEAST(AF.MRCRLIMIT,nvl(secureamt,0)+ ci.trfbuyamt) - ci.trfbuyamt - ramt-nvl(pd.dealpaidamt,0),0) baldefovd_released_depofee,
                greatest(nvl(adv.avladvance,0) + balance  - ci.dfdebtamt - ci.dfintdebtamt - NVL (advamt, 0) - nvl(secureamt,0)+ LEAST(AF.MRCRLIMIT,nvl(secureamt,0)+ ci.trfbuyamt) - ci.trfbuyamt - ramt - nvl(pd.dealpaidamt,0),0) BALDEFOVD_RLSODAMT ,
                greatest(round(least(nvl(adv.avladvance,0) + balance ,nvl(adv.avladvance,0) + balance   + af.advanceline -NVL (advamt, 0)-nvl(secureamt,0) - ci.trfbuyamt+LEAST(AF.MRCRLIMIT,nvl(secureamt,0) + ci.trfbuyamt)-ramt),0) ,0) baldefovd_released,
                round(
                    nvl(adv.avladvance,0) + nvl(balance ,0) - nvl(odamt,0) - nvl(dfdebtamt,0) - nvl(dfintdebtamt,0) - NVL (advamt, 0)- nvl(secureamt,0) - ci.trfbuyamt + advanceline - nvl(ramt,0) /*- ci.depofeeamt*/ + least(af.mrcrlimitmax+af.mrcrlimit - ci.dfodamt,af.mrcrlimit)
                    ,0) pp,
                nvl(adv.avladvance,0) + AF.mrcrlimitmax + af.mrcrlimit - dfodamt
                        + af.advanceline + balance  - odamt - ci.dfdebtamt - ci.dfintdebtamt - nvl (overamt, 0)-nvl(secureamt,0) - ci.trfbuyamt - ramt /*- CI.DEPOFEEAMT- CEIL(CI.CIDEPOFEEACR)*/ avllimit,
                greatest(least(AF.mrcrlimitmax - dfodamt,
                        AF.mrcrlimitmax - dfodamt + af.advanceline -ODAMT/* - CI.DEPOFEEAMT-CEIL(CI.CIDEPOFEEACR)*/),0) deallimit
                from cimast ci inner join afmast af on ci.acctno=af.acctno
                left join
                (select * from v_getbuyorderinfo where afacctno = pv_CONDVALUE) b
                on  ci.acctno = b.afacctno
                left join
                (select sum(depoamt) avladvance,afacctno
                    from v_getAccountAvlAdvance where afacctno = pv_CONDVALUE group by afacctno) adv
                on adv.afacctno=ci.acctno
                LEFT JOIN
                    (select * from v_getdealpaidbyaccount p where p.afacctno = pv_CONDVALUE) pd
                    on pd.afacctno=ci.acctno
                WHERE ci.acctno = pv_CONDVALUE;
        elsif v_margintype in ('S','T') and (length(v_groupleader)=0 or  v_groupleader is null) then
            select count(1)
                into l_count
            from afmast af
            where af.acctno = pv_condvalue
            and (exists (select 1 from aftype aft, lntype lnt where aft.actype = af.actype and aft.lntype = lnt.actype and lnt.chksysctrl = 'Y')
                or exists (select 1 from afidtype afi, lntype lnt where afi.aftype = af.actype and afi.objname = 'LN.LNTYPE' and afi.actype = lnt.actype and lnt.chksysctrl = 'Y'));

            if l_count > 0 then
                l_isMarginAcc:='Y';
            else
                l_isMarginAcc:='N';
            end if;

            --Tai khoan margin khong tham gia group
            OPEN PV_REFCURSOR FOR
                SELECT
                ACTYPE,ACCTNO,CCYCD,AFACCTNO,CUSTID,OPNDATE,CLSDATE,LASTDATE,
                DORMDATE,STATUS,PSTATUS,BALANCE,AVLBAL,CRAMT,DRAMT,CRINTACR,CRINTDT,ODINTACR,ODINTDT,
                AVRBAL,MDEBIT,MCREDIT,AAMT,RAMT,BAMT,EMKAMT,MMARGINBAL,MARGINBAL,ICCFCD,ICCFTIED,
                ODLIMIT,ADINTACR,ADINTDT,FACRTRADE,FACRDEPOSITORY,FACRMISC,MINBAL,ODAMT,NAMT,FLOATAMT,
                HOLDBALANCE,PENDINGHOLD,PENDINGUNHOLD,
                COREBANK,allowcorebank,
                RECEIVING,NETTING,MBLOCK,PP,AVLLIMIT,DEALLIMIT,
                NAVACCOUNT,OUTSTANDING,MRIRATE, DFDEBTAMT, HOLDMNLAMT,
                TRUNC(
                        GREATEST(
                            (CASE WHEN MRIRATE>0 THEN least(NAVACCOUNT*100/MRIRATE + (OUTSTANDING-ADVANCELINE),AVLLIMIT-ADVANCELINE) ELSE NAVACCOUNT + OUTSTANDING END)
                        ,0)
                    ,0) AVLWITHDRAW,
                --Neu co bao lanh T0 thi khong duoc rut
                TRUNC(greatest(
                        (CASE WHEN MRIRATE>0  THEN LEAST(GREATEST((100* NAVACCOUNT + (OUTSTANDING-ADVANCELINE) * MRIRATE)/MRIRATE,0),BALDEFOVD,AVLLIMIT-ADVANCELINE) ELSE BALDEFOVD END)
                    ,0),0) BALDEFOVD,
                BALDEFOVD_5540, baldefovd_released_depofee

                FROM
                    (SELECT af.advanceline,ci.actype,ci.acctno,ci.ccycd,ci.afacctno,ci.custid,ci.opndate,ci.clsdate,ci.lastdate,ci.dormdate,ci.status,ci.pstatus,
                    ci.balance -nvl(se.secureamt,0) - ci.trfbuyamt balance,
                    ci.balance  + nvl(se.avladvance,0) avlbal,
                    ci.DFDEBTAMT, ci.HOLDMNLAMT,
                    ci.cramt,ci.dramt,ci.crintacr,ci.crintdt,ci.odintacr,ci.odintdt,ci.avrbal,ci.mdebit,ci.mcredit,ci.aamt,ci.ramt,
                    nvl(se.secureamt,0) + ci.trfbuyamt bamt,
                    ci.emkamt,ci.mmarginbal,ci.marginbal,ci.iccfcd,ci.iccftied,ci.odlimit,ci.adintacr,ci.adintdt,
                    ci.facrtrade,ci.facrdepository,ci.facrmisc,ci.minbal,ci.odamt,ci.namt,ci.floatamt,ci.holdbalance,
                    ci.pendinghold,ci.pendingunhold,
                    ci.corebank,(case when ci.corebank = 'Y' then ci.corebank else af.alternateacct end) allowcorebank,
                    ci.receiving,ci.netting,ci.mblock,
                    nvl(se.avladvance,0) + balance - ci.buysecamt - CI.ovamt-CI.dueamt - dfdebtamt - dfintdebtamt - ramt-af.advanceline baldefovd_released_depofee,
                    greatest(nvl(se.avladvance,0) + balance - ci.buysecamt  - ci.dfdebtamt - ci.dfintdebtamt /*- ci.depofeeamt*/ - NVL (se.advamt, 0) - ramt,0) baldefovd_5540,
                    greatest(
                         nvl(se.avladvance,0) + balance - ci.buysecamt - CI.ovamt - CI.dueamt - ci.dfdebtamt - ci.dfintdebtamt - ramt - CI.DEPOFEEAMT-CEIL(CI.CIDEPOFEEACR)
                         ,0) BALDEFOVD,
                   greatest(round(least(nvl(se.avladvance,0) + balance - ci.buysecamt,nvl(se.avladvance,0) + balance - ci.buysecamt  + af.advanceline -NVL (se.advamt, 0)-nvl(se.secureamt,0) - ci.trfbuyamt-ramt),0) ,0) baldefovd_released,
                   round(ci.balance  - nvl(se.secureamt,0) - ci.trfbuyamt
                           + nvl(se.avladvance,0) + least(nvl(se.mrcrlimitmax,0)+nvl(af.mrcrlimit,0) - dfodamt,nvl(af.mrcrlimit,0) + nvl(se.seamt,0)) - nvl(ci.odamt,0) - ci.dfdebtamt - ci.dfintdebtamt - ramt  /*- ci.depofeeamt*/,0)
                        PP,
                   nvl(se.avladvance,0) + nvl(af.advanceline,0) + nvl(SE.mrcrlimitmax,0)+nvl(af.mrcrlimit,0)- dfodamt + balance  - odamt - ci.dfdebtamt - ci.dfintdebtamt /*- CI.DEPOFEEAMT-CEIL(CI.CIDEPOFEEACR) */- nvl(se.secureamt,0) - ci.trfbuyamt - ramt avllimit,
                   greatest(least(nvl(SE.mrcrlimitmax,0) - dfodamt,
                        nvl(SE.mrcrlimitmax,0) - dfodamt + nvl(af.advanceline,0) -odamt),0) deallimit,
                   least( nvl(se.SEASS,0),nvl(SE.mrcrlimitmax,0) - dfodamt) NAVACCOUNT,
                   nvl(af.advanceline,0) + ci.balance  +least(nvl(af.mrcrlimit,0),nvl(se.secureamt,0) + ci.trfbuyamt) + nvl(se.avladvance,0)- ci.odamt - ci.dfdebtamt - ci.dfintdebtamt /*- ci.depofeeamt*/ - NVL (se.advamt, 0)-nvl(se.secureamt,0) - ci.trfbuyamt - ci.ramt OUTSTANDING, --kHI DAT LENH THI THEM PHAN T0
                     nvl(af.advanceline,0) + ci.balance  +least(nvl(af.mrcrlimit,0),nvl(se.secureamt,0) + ci.trfbuyamt) + nvl(se.avladvance,0)- ci.odamt - ci.dfdebtamt - ci.dfintdebtamt - CI.DEPOFEEAMT-CEIL(CI.CIDEPOFEEACR) - NVL (se.advamt, 0)-nvl(se.secureamt,0) - ci.trfbuyamt - ci.ramt OUTSTANDING_HOLD_DEPOFEE, --kHI DAT LENH THI THEM PHAN T0
                   af.mrirate, nvl(margin74amt,0) margin74amt, nvl(se.avladvance,0) avladvance,
                   depofeeamt, CI.dueamt,CI.ovamt, nvl(se.seass,0) seass,
                   nvl(se74.marginrate74,0) marginrate74, nvl(se74.MRIRATIO,0) MRIRATIO, nvl(se74.SEREAL,0) SEREAL
                   from cimast ci inner join afmast af on ci.acctno=af.acctno
                               inner join aftype aft on af.actype = aft.actype
                        left join (select * from v_getsecmarginratio where afacctno = pv_CONDVALUE) se on se.afacctno=ci.acctno
                        left join (select * from v_getsecmarginratio_74 where afacctno = pv_CONDVALUE) se74 on se74.afacctno=ci.acctno
                        left join (select TRFACCTNO, nvl(sum(ln.PRINOVD + ln.INTOVDACR + ln.INTNMLOVD + ln.OPRINOVD + ln.OPRINNML + ln.OINTNMLOVD + ln.OINTOVDACR+ln.OINTDUE+ln.OINTNMLACR + nvl(lns.nml,0) + nvl(lns.intdue,0)),0) OVDAMT,
                                                       nvl(sum(ln.OPRINOVD + ln.OPRINNML + ln.OINTNMLOVD + ln.OINTOVDACR+ln.OINTDUE+ln.OINTNMLACR),0) T0AMT,
                                                       nvl(sum(ln.PRINNML - nvl(nml,0) + ln.INTNMLACR),0) NMLMARGINAMT,
                                            nvl(sum(decode(lnt.chksysctrl,'Y',1,0)*(ln.prinnml+ln.prinovd+ln.intnmlacr+ln.intdue+ln.intovdacr+ln.intnmlovd+ln.feeintnmlacr+ln.feeintdue+ln.feeintovdacr+ln.feeintnmlovd)),0) margin74amt
                               from lnmast ln, lntype lnt, (select acctno, sum(nml) nml, sum(intdue) intdue  from lnschd
                                                   where reftype = 'P' and  overduedate = to_date(cspks_system.fn_get_sysvar('SYSTEM','CURRDATE'),'DD/MM/RRRR') group by acctno) lns
                               where ln.actype = lnt.actype and ln.acctno = lns.acctno(+) and ln.ftype = 'AF'
                               and ln.trfacctno = pv_CONDVALUE
                               group by ln.trfacctno) OVDAF on OVDAF.TRFACCTNO = ci.acctno
                   left join (select afacctno, sum(amt) receivingamt from stschd where afacctno = pv_CONDVALUE and duetype = 'RM' and status <> 'C' and deltd <> 'Y' group by afacctno) sts_rcv
                             on ci.acctno = sts_rcv.afacctno
                   WHERE ci.acctno = pv_CONDVALUE);
        else
            --Tai khoan margin join theo group
            SELECT LEAST(SUM(NVL(AF.MRCRLIMIT,0) + NVL(SE.SEAMT,0))
                            ,sum(greatest(NVL(AF.MRCRLIMITMAX,0)+NVL(AF.MRCRLIMIT,0)- dfodamt,0)))
                       + sum(balance  + NVL(adv.avladvance,0) - ODAMT - NVL (ADVAMT, 0)-NVL(SECUREAMT,0) - RAMT /*- ci.depofeeamt*/) PP,
                   greatest(sum(nvl(adv.avladvance,0) + nvl(AF.mrcrlimitmax,0)+NVL(AF.MRCRLIMIT,0)- dfodamt + balance  - odamt - ci.dfdebtamt - ci.dfintdebtamt - nvl(secureamt,0) - ramt/* - CI.DEPOFEEAMT-CEIL(CI.CIDEPOFEEACR)*/),0) avllimit,
                   greatest(least(sum(nvl(AF.mrcrlimitmax,0) - dfodamt),
                        sum(nvl(AF.mrcrlimitmax,0) - dfodamt + nvl(af.advanceline,0) -odamt)),0) deallimit,
                   GREATEST(SUM(nvl(adv.avladvance,0) + balance - ci.buysecamt - ovamt-dueamt - ci.dfdebtamt - ci.dfintdebtamt - RAMT- CI.DEPOFEEAMT-CEIL(CI.CIDEPOFEEACR)),0) baldefovd,
                   SUM(/*nvl(af.MRCRLIMIT,0) +*/ nvl(se.SEASS,0))  NAVACCOUNT,
                   SUM(ci.balance +least(nvl(af.MRCRLIMIT,0),nvl(b.secureamt,0)) + nvl(adv.avladvance,0)- ci.odamt - ci.dfdebtamt - ci.dfintdebtamt- nvl(b.secureamt,0) - ci.ramt) OUTSTANDING,
                   SUM(CASE WHEN AF.ACCTNO <> v_groupleader THEN 0 ELSE AF.MRIRATE END) MRIRATE
               into v_pp,v_avllimit,v_deallimit, v_baldefovd,v_navaccount,v_outstanding,v_mrirate
               from cimast ci inner join afmast af on ci.acctno=af.acctno and af.groupleader=v_groupleader
               left join
                (select b.* from v_getbuyorderinfo  b, afmast af where b.afacctno =af.acctno and af.groupleader=v_groupleader) b
                on  ci.acctno = b.afacctno
                LEFT JOIN
                (select b.* from v_getsecmargininfo b, afmast af where b.afacctno =af.acctno and af.groupleader=v_groupleader) se
                on se.afacctno=ci.acctno
                left join
                (select sum(depoamt) avladvance,afacctno
                    from v_getAccountAvlAdvance b , afmast af where b.afacctno =af.acctno and af.groupleader=v_groupleader group by afacctno) adv
                on adv.afacctno=ci.acctno
                ;
            OPEN PV_REFCURSOR FOR
            SELECT ci.actype,ci.acctno,ci.ccycd,ci.afacctno,ci.custid,ci.opndate,ci.clsdate,ci.lastdate,ci.dormdate,ci.status,ci.pstatus,
                ci.balance -nvl(secureamt,0) balance,
                ci.balance  + nvl(adv.avladvance,0) avlbal,
                ci.DFDEBTAMT, ci.HOLDMNLAMT,
                ci.cramt,ci.dramt,ci.crintacr,ci.CIDEPOFEEACR,ci.crintdt,ci.odintacr,ci.odintdt,ci.avrbal,ci.mdebit,ci.mcredit,ci.aamt,ci.ramt,
                nvl(secureamt,0) bamt,
                ci.emkamt,ci.mmarginbal,ci.marginbal,ci.iccfcd,ci.iccftied,ci.odlimit,ci.adintacr,ci.adintdt,
                ci.facrtrade,ci.facrdepository,ci.facrmisc,ci.minbal,ci.odamt,ci.namt,ci.floatamt,ci.holdbalance,
                ci.pendinghold,ci.pendingunhold,
                ci.corebank,(case when ci.corebank = 'Y' then ci.corebank else af.alternateacct end) allowcorebank,
                ci.receiving,ci.netting,ci.mblock,
                greatest(nvl(af.advanceline,0) + v_pp,0) pp,nvl(af.advanceline,0) + v_avllimit avllimit,v_avllimit avlmrlimit,v_deallimit deallimit,
                TRUNC(GREATEST((CASE WHEN v_mrirate>0 THEN least(v_navaccount*100/v_mrirate + v_outstanding,v_avllimit) ELSE v_navaccount + v_outstanding  END),0),0) AVLWITHDRAW,
                TRUNC((case when v_mrirate>0
                                then least(greatest((100* v_navaccount + v_outstanding * v_mrirate)/v_mrirate,0),
                                                    greatest( nvl(adv.avladvance,0) + balance  - ovamt-dueamt- dfdebtamt - dfintdebtamt - ramt-(af.advanceline) -nvl(pd.dealpaidamt,0) - CI.DEPOFEEAMT-CEIL(CI.CIDEPOFEEACR),0),
                                                    v_avllimit)
                             else greatest(nvl(adv.avladvance,0) + balance - ci.buysecamt - odamt - NVL (advamt, 0)-nvl(secureamt,0)-dfdebtamt - dfintdebtamt - ramt - CI.DEPOFEEAMT-CEIL(CI.CIDEPOFEEACR),0)
                             end),0) baldefovd,
                TRUNC((case when v_mrirate>0
                                then least(greatest((100* v_navaccount + v_outstanding * v_mrirate)/v_mrirate,0),
                                                    greatest( nvl(adv.avladvance,0) + balance - ci.buysecamt - ovamt-dueamt- dfdebtamt - dfintdebtamt - ramt-af.advanceline-nvl(pd.dealpaidamt,0),0),
                                                    v_avllimit)
                             else greatest(nvl(adv.avladvance,0) + balance - ci.buysecamt - odamt - NVL (advamt, 0)-nvl(secureamt,0)-dfdebtamt - dfintdebtamt - ramt,0)
                             end),0) baldefovd_released_depofee
               from cimast ci inner join afmast af on ci.acctno=af.acctno
               left join
                (select * from v_getbuyorderinfo where afacctno = pv_CONDVALUE) b
                on  ci.acctno = b.afacctno
                LEFT JOIN
                (select * from v_getsecmargininfo SE where se.afacctno = pv_CONDVALUE) se
                on se.afacctno=ci.acctno
                LEFT JOIN
                (select aamt,depoamt avladvance, advamt advanceamount,afacctno, paidamt from v_getAccountAvlAdvance where afacctno = pv_CONDVALUE ) adv
                on adv.afacctno=ci.acctno
                LEFT JOIN
                (select * from v_getdealpaidbyaccount p where p.afacctno = pv_CONDVALUE) pd
                on pd.afacctno=ci.acctno
                WHERE ci.acctno = pv_CONDVALUE;
        end if;
    elsif v_tblname='DFMAST' then
        OPEN PV_REFCURSOR FOR
        select * from v_getDealInfo df where df.acctno = pv_CONDVALUE;

    elsif v_tblName = 'CAMAST' then
        OPEN PV_REFCURSOR FOR
        SELECT * FROM CAMAST WHERE CAMASTID = pv_CONDVALUE;

    elsif v_tblName = 'CASCHD' then
        OPEN PV_REFCURSOR FOR
        SELECT * FROM CASCHD WHERE TRIM(AUTOID) = pv_CONDVALUE;

    elsif v_tblName = 'CFMAST' then
        OPEN PV_REFCURSOR FOR
        SELECT * FROM CFMAST WHERE CUSTID = pv_CONDVALUE;

    elsif v_tblName = 'AFMAST' then
        OPEN PV_REFCURSOR FOR
        SELECT AF.*, MR.MRTYPE,
        (CASE WHEN CF.CUSTATCOM='Y' THEN 'C' ELSE 'T' END) CUSTODIANTYP,
        substr(cf.custodycd,4,1) CUSTTYPE,
        (cf.idexpired - v_txdate) idexpdays,
        decode(af.TERMOFUSE,'003',0,1) WARNINGTERMOFUSE
        FROM CFMAST CF, AFMAST AF,AFTYPE AFT,MRTYPE MR, sysvar sys
        WHERE AF.actype =AFT.actype --AND AF.aftype =AFT.aftype
        AND AF.CUSTID=CF.CUSTID
        AND sys.grname ='SYSTEM' and sys.varname ='COMPANYCD'
        AND AFT.mrtype =MR.actype AND AF.ACCTNO =pv_CONDVALUE;
    elsif v_tblName = 'SEMAST' then
       OPEN PV_REFCURSOR FOR
        select semast.actype, semast.acctno, semast.codeid, semast.afacctno, semast.opndate, semast.clsdate,
                    semast.lastdate, semast.status, semast.pstatus, semast.irtied, semast.ircd, semast.costprice,
                    semast.trade - nvl(b.secureamt,0) trade, semast.mortage-nvl(b.securemtg,0) mortage,nvl(df.sumdfqtty,0)-nvl(b.securemtg,0) dfmortage, semast.margin, semast.netting, abs(semast.standing) standing, semast.withdraw,
                   semast.deposit, semast.loan, semast.blocked, semast.receiving, semast.transfer,
                   semast.prevqtty, semast.dcrqtty, semast.dcramt, semast.depofeeacr, semast.repo, semast.pending,
                   semast.tbaldepo, semast.custid, semast.costdt,nvl(b.securemtg,0)+nvl(b.secureamt,0) secured, semast.iccfcd, semast.iccftied,
                   semast.tbaldt, semast.senddeposit, semast.sendpending, semast.ddroutqtty,
                   semast.ddroutamt, semast.dtoclose, semast.sdtoclose, semast.qtty_transfer,
                   greatest(semast.trade - nvl(b.secureamt,0) + nvl(b.sereceiving,0),0) trading,
                   abs(semast.standing) absstanding, mod(semast.trade,seinfo.tradelot) retaillot,semast.emkqtty,semast.blockwithdraw,semast.blockdtoclose
            from SEMAST,
                v_getsellorderinfo b, (select codeid, tradelot from securities_info) seinfo,
                (SELECT afacctno,codeid, sum(dfqtty) sumdfqtty FROM dfmast GROUP BY afacctno, codeid) df
            WHERE acctno = pv_CONDVALUE AND semast.codeid = seinfo.codeid(+) AND ACCTNO = b.seacctno(+) AND df.afacctno(+) = semast.afacctno AND df.codeid(+) = semast.codeid;
    elsif v_tblName = 'SEREVERT' then
                OPEN PV_REFCURSOR FOR
                        select SUM(serevert) SESTATUS
                      from ((SELECT count(*) serevert FROM SEMAST
                            WHERE afacctno = pv_CONDVALUE and status = 'N')
                            UNION ALL (SELECT count(*) serevert FROM caschd
                            WHERE afacctno = pv_CONDVALUE and status = 'O' AND deltd='N'));

    elsif v_tblName = 'CFBANK' then
          if length(trim(pv_CONDVALUE)) > 0 then
             OPEN PV_REFCURSOR FOR
                        select count(1) ISBANKSTATUS
                      from CFMAST
                            WHERE custid = pv_CONDVALUE and isbanking = 'Y' and status = 'A';
          else
             OPEN PV_REFCURSOR FOR
                        select 1 ISBANKSTATUS
                      from dual;
          end if;

    elsif v_tblName = 'SEBLOCKDEAL' then
             OPEN PV_REFCURSOR FOR
                     SELECT sum(nvl(s.blocked,0) + nvl(d.blockqtty,0)) BLOCKQTTY
                     FROM   semast s,
                                 (SELECT sum(blockqtty) blockqtty,afacctno,codeid,acctno FROM dfmast WHERE afacctno || codeid = pv_CONDVALUE GROUP BY afacctno,codeid,acctno) d
                     WHERE d.afacctno(+) = s.afacctno AND d.codeid(+) = s.codeid
                                 AND s.acctno = pv_CONDVALUE;

    elsif v_tblName = 'SEWITHDRAW' then
        SELECT MR.MRTYPE,af.actype,mst.groupleader into v_margintype,v_actype,v_groupleader from afmast mst,aftype af, mrtype mr where mst.actype=af.actype and af.mrtype=mr.actype and mst.acctno=substr(pv_CONDVALUE,1,10);
        if v_margintype='N' or v_margintype='L' then
        OPEN PV_REFCURSOR FOR
            SELECT 1000000000 AVLSEWITHDRAW FROM DUAL;
        elsif v_margintype in ('S','T') and (length(v_groupleader)=0 or  v_groupleader is null) then
            --Tai khoan margin khong tham gia group
            OPEN PV_REFCURSOR FOR


            select least(se.trade- nvl(od.SELLQTTY,0),
                            (CASE WHEN LEAST(NVL(SB.MARGINCALLPRICE,0),NVL(RSK.MRPRICERATE,0)) * NVL(RSK.MRRATIORATE,0) <=0 THEN 1000000000
                                ELSE
                            trunc(GREATEST((100* SEASS + (OUTSTANDING) * sec.MRIRATE)/sec.MRIRATE,0)/LEAST(SB.MARGINCALLPRICE,RSK.MRPRICERATE) / (MRRATIORATE/100),0)
                            END)) avlsewithdraw
             from semast se, securities_info sb, cimast ci,
             (select af.acctno afacctno,af.advanceline,af.MRIRATE, nvl(rsk.mrpricerate,1) mrpricerate, nvl(rsk.mrratiorate,0) mrratiorate
                from afmast af, (select * from afserisk where codeid = substr(pv_condvalue,11,6)) rsk
                where af.acctno = substr(pv_CONDVALUE,1,10) and af.actype = rsk.actype(+)) rsk,
             (select * from v_getsecmarginratio where afacctno = substr(pv_CONDVALUE,1,10)) sec,
             (select od.seacctno,
                        sum(case when od.exectype in ('NS','SS') and to_date(sy.varvalue,'DD/MM/RRRR') = od.txdate then remainqtty + execqtty else 0 end) SELLQTTY,
                        sum(case when od.exectype in ('NS','SS') and to_date(sy.varvalue,'DD/MM/RRRR') = od.txdate then execqtty else 0 end) EXECSELLQTTY,
                        sum(case when od.exectype in ('MS') and to_date(sy.varvalue,'DD/MM/RRRR') = od.txdate then remainqtty + execqtty else 0 end) MTGSELLQTTY,
                        sum(case when od.exectype = 'NB' then sts.qtty - sts.aqtty else 0 end) RECEIVING,
                        sum(CASE WHEN OD.EXECTYPE = 'NB' and to_date(sy.varvalue,'DD/MM/RRRR') = od.txdate then od.REMAINQTTY ELSE 0 END) REMAINQTTY
                        from odmast od, (select * from stschd where duetype in ('RS','SS')) sts, sysvar sy
                        where od.orderid = sts.orgorderid(+)
                        and sy.varname = 'CURRDATE'
                        group by od.seacctno) od
             where se.acctno = pv_CONDVALUE and se.afacctno = sec.afacctno(+)
                and se.afacctno = rsk.afacctno(+)
                and se.acctno = od.seacctno(+)
                and se.codeid = sb.codeid and ci.acctno = se.afacctno;
        else
            --Tai khoan margin join theo group
            OPEN PV_REFCURSOR FOR
            SELECT
                (CASE WHEN LEAST(NVL(SB.MARGINCALLPRICE,0),NVL(RSK.MRPRICERATE,0)) * NVL(RSK.MRRATIORATE,0) <=0 THEN 1000000000
                ELSE
                trunc((NAVACCOUNT*100+OUTSTANDING*MRIRATE)/LEAST(SB.MARGINCALLPRICE,RSK.MRPRICERATE) / MRRATIORATE,0)
                END) AVLSEWITHDRAW FROM (
                SELECT AF.ACCTNO,AF.ACTYPE,AF.MRIRATE, NAVACCOUNT,OUTSTANDING

                                FROM
                                (SELECT substr(pv_CONDVALUE,1,10) AFACCTNO,
                                           SUM(/*NVL(AF.MRCRLIMIT,0)*/ + NVL(SE.SEASS,0)) NAVACCOUNT,
                                           SUM(balance  +least(NVL(AF.MRCRLIMIT,0),NVL(SECUREAMT,0)) + NVL(SE.RECEIVINGAMT,0)- ODAMT - NVL (ADVAMT, 0)-NVL(SECUREAMT,0) - RAMT) OUTSTANDING
                                   FROM CIMAST ci INNER JOIN AFMAST AF ON AF.ACCTNO = ci.AFACCTNO AND AF.GROUPLEADER=v_groupleader
                                   LEFT JOIN
                                    (SELECT B.* FROM V_GETBUYORDERINFO B,AFMAST AF WHERE B.AFACCTNO = AF.ACCTNO AND AF.GROUPLEADER=v_groupleader) B
                                    ON  ci.ACCTNO = B.AFACCTNO

                                   LEFT JOIN
                                    (SELECT B.* FROM V_GETSECMARGININFO B,AFMAST AF WHERE B.AFACCTNO = AF.ACCTNO AND AF.GROUPLEADER=v_groupleader) SE
                                    ON SE.AFACCTNO=ci.ACCTNO
                                    GROUP BY AF.GROUPLEADER
                                ) A, AFMAST AF WHERE A.AFACCTNO =AF.ACCTNO) MST,
                AFSERISK RSK,SECURITIES_INFO SB
                WHERE MST.ACTYPE =RSK.ACTYPE(+) AND SB.CODEID=substr(pv_CONDVALUE,11,6) AND RSK.CODEID(+)=substr(pv_CONDVALUE,11,6);
        end if;
    else
        v_cmdSQL := 'SELECT * FROM ' || v_tblname
                    || ' WHERE ' || v_fldkey || ' = ''' || pv_condvalue || '''';
        OPEN PV_REFCURSOR FOR
        v_cmdSQL;
    end if;

        plog.setendsection(pkgctx, 'pr_txcorecheck');

   EXCEPTION
      WHEN OTHERS
      THEN
           plog.error(pkgctx, SQLERRM);
        plog.setendsection(pkgctx, 'pr_txcorecheck');
         RETURN;
   END pr_txcorecheck;

   FUNCTION fn_cimastcheck (
      pv_condvalue   IN   VARCHAR2,
      pv_tblname     IN   VARCHAR2,
      pv_fldkey      IN   VARCHAR2
   )
      RETURN cimastcheck_arrtype
   IS
      l_margintype            CHAR (1);
      l_actype                VARCHAR2 (4);
      l_groupleader           VARCHAR2 (10);
      l_baldefovd             NUMBER (20, 0);
      l_baldefovd_Released    NUMBER (20, 0);

      l_pp                    NUMBER (20, 0);
      l_avllimit              NUMBER (20, 0);
      l_deallimit             NUMBER (20, 0);
      l_navaccount            NUMBER (20, 0);
      l_outstanding           NUMBER (20, 0);
      l_mrirate               NUMBER (20, 4);

      l_baldefovd_Released_depofee    NUMBER (20, 0);

      l_cimastcheck_rectype   cimastcheck_rectype;
      l_cimastcheck_arrtype   cimastcheck_arrtype;
      l_i                     NUMBER (10);
      pv_refcursor            pkg_report.ref_cursor;
      l_count number;
      l_isMarginAcc varchar2(1);

      l_avladvance  NUMBER; -- TheNN added
      l_advanceamount NUMBER; -- TheNN added
      l_paidamt       NUMBER; -- TheNN added
      l_execbuyamt      number;
      l_ISSTOPADV  varchar2(1);
   BEGIN
      SELECT mr.mrtype, af.actype, mst.groupleader
        INTO l_margintype, l_actype, l_groupleader
        FROM afmast mst, aftype af, mrtype mr
       WHERE mst.actype = af.actype
         AND af.mrtype = mr.actype
         AND mst.acctno = pv_condvalue;

      select varvalue INTO l_ISSTOPADV  from sysvar where varname like 'ISSTOPADV' AND grname ='SYSTEM';

      IF l_margintype = 'N' or l_margintype = 'L'
      THEN
         --Tai khoan binh thuong khong Margin
         OPEN pv_refcursor FOR
            SELECT ci.actype, ci.acctno, ci.ccycd,
                   ci.afacctno, ci.custid, ci.opndate,
                   ci.clsdate, ci.lastdate, ci.dormdate,
                   ci.status, ci.pstatus,
                   af.advanceline,
                   ci.balance  - NVL (secureamt, 0) - ci.trfbuyamt balance,
                   ci.balance  + nvl(adv.avladvance,0) avlbal,
                   ci.cramt,
                   ci.dramt, ci.crintacr,ci.CIDEPOFEEACR, ci.crintdt,
                   ci.odintacr, ci.odintdt, ci.avrbal,
                   ci.mdebit, ci.mcredit, ci.aamt, ci.ramt,
                   NVL (secureamt, 0) + ci.trfbuyamt bamt, ci.emkamt, ci.mmarginbal,
                   ci.marginbal, ci.iccfcd, ci.iccftied,
                   ci.odlimit, ci.adintacr, ci.adintdt,
                   ci.facrtrade, ci.facrdepository, ci.facrmisc,
                   ci.minbal, ci.odamt, ci.dueamt, ci.ovamt, ci.namt, ci.floatamt,
                   ci.holdbalance, ci.pendinghold,
                   ci.pendingunhold,
                   ci.corebank,
                   (case when ci.corebank = 'Y' then ci.corebank else af.alternateacct end) allowcorebank,
                   ci.receiving,
                   ci.netting, ci.mblock, l_margintype mrtype,
                   round(
                   decode (l_ISSTOPADV,'Y',0,'N', nvl(adv.avladvance,0)) + nvl(balance ,0) - nvl(odamt,0) - nvl(dfdebtamt,0) - nvl(dfintdebtamt,0) - NVL (advamt, 0)- nvl(secureamt,0) - ci.trfbuyamt + advanceline - nvl(ramt,0) /*- ci.depofeeamt*/ + least(af.mrcrlimitmax + af.mrcrlimit- ci.dfodamt,af.mrcrlimit)+ af.clamtlimit
                    ,0) pp,
                   round(
                     decode (l_ISSTOPADV,'Y',0,'N',nvl(adv.avladvance,0)) + nvl(balance ,0) + nvl(bankavlbal,0) - nvl(odamt,0) - nvl(dfdebtamt,0) - nvl(dfintdebtamt,0) - NVL (advamt, 0)- nvl(secureamt,0) - ci.trfbuyamt + advanceline - nvl(ramt,0) /*- ci.depofeeamt*/ + least(af.mrcrlimitmax + af.mrcrlimit - ci.dfodamt,af.mrcrlimit)+ af.clamtlimit
                    ,0) ppref,
                    nvl(adv.avladvance,0)
                   + AF.mrcrlimitmax +af.mrcrlimit - dfodamt
                   + af.advanceline
                   + balance
                   - odamt
                   - dfdebtamt
                   - dfintdebtamt
                   - NVL (overamt, 0)
                   - NVL (secureamt, 0) - ci.trfbuyamt
                   - ramt + af.clamtlimit
                   /*- ci.depofeeamt
                   -CI.CIDEPOFEEACR*/ AVLLIMIT,
                   greatest(least(
                                    AF.mrcrlimitmax - dfodamt,
                                    AF.mrcrlimitmax - dfodamt + af.advanceline -odamt
                                    ),
                                0
                        ) deallimit,
                   0 navaccount, 0 outstanding, 0 se_navaccount, 0 se_outstanding, af.mrirate,
                   GREATEST ( nvl(adv.avladvance,0) + balance
                             - odamt
                             - dfdebtamt
                             - dfintdebtamt
                             - NVL (advamt, 0)
                             - NVL (secureamt, 0) - ci.trfbuyamt
                             - ramt
                             - nvl(pd.dealpaidamt,0),
                             - CI.DEPOFEEAMT
                             -CEIL(CI.CIDEPOFEEACR),
                             0
                            ) avlwithdraw,
                   greatest(
                        decode (l_ISSTOPADV,'Y',0,'N', nvl(adv.avladvance,0)) + balance - ci.buysecamt
                        - ovamt - dueamt - ci.dfdebtamt - ci.dfintdebtamt - NVL (overamt, 0) - nvl(secureamt,0)+LEAST(AF.MRCRLIMIT,nvl(secureamt,0)+ ci.trfbuyamt) - ci.trfbuyamt - ramt-nvl(pd.dealpaidamt,0)- CI.DEPOFEEAMT-CEIL(CI.CIDEPOFEEACR)
                        ,0) BALDEFOVD,
                   GREATEST (  round(least(nvl(adv.avladvance,0) + balance - ci.buysecamt ,
                                    nvl(adv.avladvance,0) + balance - ci.buysecamt  +
                                    af.advanceline -NVL (advamt, 0)-
                                    nvl(secureamt,0) - ci.trfbuyamt -RAMT
                                    +LEAST(AF.MRCRLIMIT,nvl(secureamt,0) + ci.trfbuyamt)
                            ),0
                   ) ,0) baldefovd_released,
                   dfdebtamt,
                   dfintdebtamt,
                  /* nvl(adv.avladvance,0)*/decode (l_ISSTOPADV,'Y',0,'N', nvl(adv.avladvance,0)) + balance - ci.buysecamt
                             - odamt
                             - dfdebtamt
                             - dfintdebtamt
                             - NVL (advamt, 0)
                             - NVL (secureamt, 0) - CI.TRFBUYAMT
                             + LEAST(AF.MRCRLIMIT,nvl(secureamt,0) + ci.trfbuyamt)
                             - ramt
                             - nvl(pd.dealpaidamt,0) baldefovd_released_depofee,  -- Su dung de check khi thu phi luu ky
                   nvl(adv.avladvance,0) avladvance, nvl(adv.advanceamount,0) advanceamount, nvl(adv.paidamt,0) paidamt,
                   0 SEASS, 0 SEAMT, 100000 marginrate,
                   nvl(b.execbuyamt,0) execbuyamt,
                   ci.bankbalance,ci.bankavlbal,
                   nvl(adv.rcvamt,0) rcvamt, --Tien cho ve tru phi thue
                   nvl(adv.aamt,0) rcvadvamt, --Tien dang ung truoc
                   nvl(td.tdbalance,0) tdbalance,
                   nvl(td.TDINTAMT,0) TDINTAMT,
                   nvl(td.TDODAMT,0) TDODAMT,
                   nvl(td.ODINTACR,0) ODINTACR,
                   /*case when dueamt>1 then
                     greatest(ROUND(dueamt)+ROUND(ovamt)+ROUND(depofeeamt) - balance - avladvance,0)
                   else 0 end  CALLAMT,*/
                   0 CALLAMT,
                   greatest(-(nvl(adv.avladvance,0) + nvl(balance ,0) - nvl(odamt,0) - nvl(dfdebtamt,0) - nvl(dfintdebtamt,0) - NVL (advamt, 0)
                            - nvl(secureamt,0) - ci.trfbuyamt  - nvl(ramt,0) /*- ci.depofeeamt*/
                            + least(af.mrcrlimitmax + af.mrcrlimit- ci.dfodamt,af.mrcrlimit)),0) addamt, --Phan PP bi am
                   /*case when ovamt+dueamt>1 then
                     round(greatest(dueamt + ovamt+depofeeamt - balance - nvl(avladvance,0),0),0)
                   else 0 end addamt*/
                   ci.depofeeamt,
                   greatest(
                      nvl(adv.avladvance,0) + balance - ci.buysecamt
                      - ovamt - dueamt - ci.dfdebtamt - ci.dfintdebtamt - NVL (overamt, 0) - nvl(secureamt,0) - ci.trfbuyamt - ramt-nvl(pd.dealpaidamt,0) - ci.depofeeamt-CEIL(CI.CIDEPOFEEACR)
                      ,0) BALDEFOVD_HOLD_DEPOFEEAMT,
                  greatest(
                         balance - ci.buysecamt
                        - ovamt - dueamt - ci.dfdebtamt - ci.dfintdebtamt - NVL (overamt, 0) - nvl(secureamt,0) - ci.trfbuyamt - ramt-nvl(pd.dealpaidamt,0)- CI.DEPOFEEAMT-CEIL(CI.CIDEPOFEEACR)
                        ,0) baldefovd_released_adv,af.clamtlimit,
                        GREATEST(LEAST(nvl(b.secureamt,0) -
                                 GREATEST( ci.balance + af.advanceline +  nvl(adv.avladvance,0)+
                                           + LEAST(nvl(af.MRCRLIMIT,0),nvl(b.secureamt,0) + ci.trfbuyamt)
                                         ,0)
                         , af.clamtlimit)  ,0) Dclamtlimit
              FROM cimast ci INNER JOIN afmast af ON ci.acctno = af.acctno
                   LEFT JOIN (SELECT *
                                FROM v_getbuyorderinfo
                               WHERE afacctno = pv_condvalue) b
                               ON ci.acctno = b.afacctno
                   left join
                            (select sum(depoamt) avladvance,afacctno, sum(advamt) advanceamount, sum(paidamt) paidamt, sum(rcvamt) rcvamt, sum(aamt) aamt
                                from v_getAccountAvlAdvance
                                where afacctno = pv_condvalue group by afacctno) adv
                                on adv.afacctno=ci.acctno
                   LEFT JOIN
                            (select *
                                from v_getdealpaidbyaccount p
                                where p.afacctno = pv_CONDVALUE) pd
                            on pd.afacctno=ci.acctno
                   left join
                            (select mst.afacctno, sum(MST.BALANCE) TDBALANCE,
                                    sum(FN_TDMASTINTRATIO(MST.ACCTNO,getcurrdate,
                                                    MST.BALANCE)) TDINTAMT, sum(ODAMT) TDODAMT, sum(ODINTACR) ODINTACR
                                from tdmast mst
                                where  MST.DELTD<>'Y' AND MST.status in ('N','A') and afacctno = pv_CONDVALUE
                                group by mst.afacctno) td
                            on td.afacctno = ci.acctno
             WHERE ci.acctno = pv_condvalue;
      ELSIF     l_margintype in  ('S','T','F')
            AND (LENGTH (l_groupleader) = 0 OR l_groupleader IS NULL)
      THEN
            select count(1)
                into l_count
            from afmast af
            where af.acctno = pv_condvalue
            and (exists (select 1 from aftype aft, lntype lnt where aft.actype = af.actype and aft.lntype = lnt.actype and lnt.chksysctrl = 'Y')
                or exists (select 1 from afidtype afi, lntype lnt where afi.aftype = af.actype and afi.objname = 'LN.LNTYPE' and afi.actype = lnt.actype and lnt.chksysctrl = 'Y'));

            if l_count > 0 then
                l_isMarginAcc:='Y';
            else
                l_isMarginAcc:='N';
            end if;

         --Tai khoan margin khong tham gia group
         OPEN pv_refcursor FOR
                SELECT
                ACTYPE,ACCTNO,CCYCD,AFACCTNO,CUSTID,OPNDATE,CLSDATE,LASTDATE,
                DORMDATE,STATUS,PSTATUS, ADVANCELINE, BALANCE,AVLBAL,CRAMT,DRAMT,CRINTACR, cidepofeeacr, CRINTDT,ODINTACR,ODINTDT,
                AVRBAL,MDEBIT,MCREDIT,AAMT,RAMT,BAMT,EMKAMT,MMARGINBAL,MARGINBAL,ICCFCD,ICCFTIED,
                ODLIMIT,ADINTACR,ADINTDT,FACRTRADE,FACRDEPOSITORY,FACRMISC,MINBAL,ODAMT,dueamt, ovamt,NAMT,FLOATAMT,
                HOLDBALANCE,PENDINGHOLD,PENDINGUNHOLD,COREBANK,ALLOWCOREBANK,RECEIVING,NETTING,MBLOCK,l_margintype mrtype,PP,PPREF,AVLLIMIT,DEALLIMIT,
                NAVACCOUNT,OUTSTANDING,SE_NAVACCOUNT,SE_OUTSTANDING,MRIRATE,
                TRUNC(
                    GREATEST(
                        (CASE WHEN MRIRATE>0 THEN least(NAVACCOUNT*100/MRIRATE + (OUTSTANDING_HOLD_DEPOFEE-ADVANCELINE),AVLLIMIT-ADVANCELINE) ELSE NAVACCOUNT + OUTSTANDING_HOLD_DEPOFEE END)
                    ,0)
                ,0) AVLWITHDRAW,
                TRUNC(
                    greatest(
                        (CASE WHEN MRIRATE>0  THEN LEAST(GREATEST((100* NAVACCOUNT + (OUTSTANDING_HOLD_DEPOFEE-ADVANCELINE) * MRIRATE)/MRIRATE,0),BALDEFOVD,AVLLIMIT-ADVANCELINE) ELSE BALDEFOVD END)
                    ,0)
                ,0) BALDEFOVD,
                baldefovd_Released,
                DFDEBTAMT, dfintdebtamt,
                TRUNC
                ((CASE
                     WHEN mrirate > 0
                        THEN LEAST (GREATEST (  (  100 * navaccount
                                                 +   (  OUTSTANDING_IS_STOPADV /*+ depofeeamt*/
                                                      - advanceline
                                                     )
                                                   * mrirate
                                                )
                                              / mrirate,
                                              0
                                             ),
                                    Baldefovd_Released_Depofee,
                                    avllimit /*+ DEPOFEEAMT+CIDEPOFEEACR */- advanceline
                                   )
                     ELSE Baldefovd_Released_Depofee
                  END
                 )  ,
                 0
                ) Baldefovd_Released_Depofee,  -- Su dung de check khi thu phi luu ky
                avladvance, advanceamount, paidamt, SEASS, SEAMT,marginrate, execbuyamt,
                bankbalance,bankavlbal,rcvamt,rcvadvamt,
                tdbalance,TDINTAMT,TDODAMT,TDODINTACR,
                case when (mrlrate <= marginrate AND marginrate < mrmrate) then
                     greatest(round((case when nvl(marginrate,0) * mrmrate =0 then - nvl(se_outstanding,0)
                            else greatest( 0,- nvl(se_outstanding,0) - nvl(se_navaccount,0) *100/mrmrate) end),0),0)
                else 0 end  CALLAMT,
                case when (marginrate<mrlrate) or dueamt + ovamt>1 then
                    round(greatest(round((case when marginrate*mrmrate =0 then - se_outstanding else
                                            greatest( 0,- se_outstanding - se_navaccount *100/mrmrate) end),0),
                                     greatest(ovamt + dueamt - greatest(balance + nvl(avladvance,0)/* - depofeeamt*/,0),0)
                                   )
                         ,0)
                else 0 end addamt,
                depofeeamt,
                TRUNC(
                    greatest(
                        (CASE WHEN MRIRATE>0  THEN LEAST(GREATEST((100* NAVACCOUNT + (OUTSTANDING_HOLD_DEPOFEE-ADVANCELINE) * MRIRATE)/MRIRATE,0),BALDEFOVD,AVLLIMIT-ADVANCELINE) ELSE BALDEFOVD END)
                    ,0)
                ,0) BALDEFOVD_HOLD_DEPOFEEAMT,
                 TRUNC(
                    greatest(
                        (CASE WHEN MRIRATE>0  THEN LEAST(GREATEST((100* NAVACCOUNT + (OUTSTANDING_HOLD_DEPOFEE_RLS-ADVANCELINE) * MRIRATE)/MRIRATE,0),baldefovd_released_adv,AVLLIMIT-ADVANCELINE) ELSE baldefovd_released_adv END)
                    ,0)
                ,0)
                baldefovd_released_adv,clamtlimit,dclamtlimit
                FROM
                    (SELECT cidepofeeacr, af.advanceline,ci.actype,ci.acctno,ci.ccycd,ci.afacctno,ci.custid,ci.opndate,ci.clsdate,ci.lastdate,ci.dormdate,ci.status,ci.pstatus,
                        ci.balance -nvl(se.secureamt,0) - ci.trfbuyamt balance,
                        ci.balance  + nvl(se.avladvance,0) avlbal,
                        ci.DFDEBTAMT,
                        ci.cramt,ci.dramt,ci.crintacr,ci.crintdt,ci.odintacr,ci.odintdt,ci.avrbal,ci.mdebit,ci.mcredit,ci.aamt,ci.ramt,
                        nvl(se.secureamt,0) + ci.trfbuyamt bamt,
                        ci.emkamt,ci.mmarginbal,ci.marginbal,ci.iccfcd,ci.iccftied,ci.odlimit,ci.adintacr,ci.adintdt,
                        ci.facrtrade,ci.facrdepository,ci.facrmisc,ci.minbal,ci.odamt,ci.namt,ci.floatamt,ci.holdbalance,
                        ci.pendinghold,ci.pendingunhold,
                        ci.corebank,
                        (case when ci.corebank = 'Y' then ci.corebank else af.alternateacct end) allowcorebank,
                        ci.receiving,ci.netting,ci.mblock, ci.dfintdebtamt,
                        greatest(
                            decode (l_ISSTOPADV,'Y',0,'N',  nvl(se.avladvance,0)) + balance - ci.buysecamt - CI.ovamt - CI.dueamt - ci.dfdebtamt - ci.dfintdebtamt - ramt - CI.DEPOFEEAMT-CEIL(CI.CIDEPOFEEACR)
                             ,0) BALDEFOVD,

                        nvl(se.avladvance,0) + balance - ci.buysecamt - CI.ovamt - CI.dueamt - ci.dfdebtamt - ci.dfintdebtamt - ramt
                        Baldefovd_Released_Depofee,
                        greatest(ci.balance - ci.buysecamt - nvl(se.secureamt,0) - ci.trfbuyamt + nvl(se.avladvance,0) - ci.dfdebtamt - ci.dfintdebtamt - CI.DEPOFEEAMT-CEIL(CI.CIDEPOFEEACR) - af.advanceline,0) BALDEFOVD_RLSODAMT ,
                        greatest(round(least(nvl(se.avladvance,0) + balance - ci.buysecamt ,nvl(se.avladvance,0) + balance - ci.buysecamt  + af.advanceline -NVL (se.advamt, 0)-nvl(se.secureamt,0) - ci.trfbuyamt -ramt),0) ,0) baldefovd_released,
                        round(ci.balance  - nvl(se.secureamt,0) - ci.trfbuyamt - nvl(se.overamt,0) +  decode (l_ISSTOPADV,'Y',0,'N', nvl(se.avladvance,0)) + af.advanceline
                            + least(nvl(se.mrcrlimitmax,0)+ nvl(af.mrcrlimit,0)  - dfodamt,nvl(af.mrcrlimit,0) + nvl(se.seamt,0))
                            - nvl(ci.odamt,0) - ci.dfdebtamt - ci.dfintdebtamt - ramt + af.clamtlimit /*- ci.depofeeamt*/,0)
                            PP,
                        round(ci.balance  + nvl(bankavlbal,0) - nvl(se.secureamt,0) - ci.trfbuyamt - nvl(se.overamt,0) +  decode (l_ISSTOPADV,'Y',0,'N',nvl(se.avladvance,0)) + af.advanceline
                                 + least(nvl(se.mrcrlimitmax,0) + nvl(af.mrcrlimit,0)- dfodamt,nvl(af.mrcrlimit,0) + nvl(se.seamt,0))
                            - nvl(ci.odamt,0) - ci.dfdebtamt - ci.dfintdebtamt - ramt+ af.clamtlimit  /*- ci.depofeeamt*/,0)
                            PPREF, -- Luon luon ban PP khi ko tra cham
                        round(
                            nvl(se.avladvance,0) + nvl(af.advanceline,0) + nvl(se.mrcrlimitmax,0) + nvl(af.mrcrlimit,0)- dfodamt + balance  - odamt - ci.dfdebtamt - ci.dfintdebtamt - nvl(se.secureamt,0) - ci.trfbuyamt - ramt + af.clamtlimit /*- CI.DEPOFEEAMT-CEIL(CI.CIDEPOFEEACR)*/
                        ,0) AVLLIMIT,
                        greatest(least(nvl(se.mrcrlimitmax,0) - dfodamt,
                                nvl(se.mrcrlimitmax,0) - dfodamt + nvl(af.advanceline,0) -odamt),0) deallimit,
                        least( nvl(se.SEASS,0),nvl(SE.mrcrlimitmax,0) - dfodamt) NAVACCOUNT,
                        nvl(af.advanceline,0) + ci.balance  + nvl(se.avladvance,0)- ci.odamt - ci.dfdebtamt - ci.dfintdebtamt /*- ci.depofeeamt*/ - NVL (se.advamt, 0)-nvl(se.secureamt,0) - ci.trfbuyamt+ LEAST(AF.MRCRLIMIT,nvl(se.secureamt,0) + ci.trfbuyamt) - ci.ramt OUTSTANDING, --kHI DAT LENH THI THEM PHAN T0
                        nvl(af.advanceline,0) + ci.balance  + decode (l_ISSTOPADV,'Y',0,'N',  nvl(se.avladvance,0))- ci.odamt - ci.dfdebtamt - ci.dfintdebtamt /*- ci.depofeeamt*/ - NVL (se.advamt, 0)-nvl(se.secureamt,0) - ci.trfbuyamt+ LEAST(AF.MRCRLIMIT,nvl(se.secureamt,0) + ci.trfbuyamt) - ci.ramt OUTSTANDING_IS_STOPADV, --kHI DAT LENH THI THEM PHAN T0
                                                nvl(af.advanceline,0) + ci.balance  + /*nvl(se.avladvance,0)*/ decode (l_ISSTOPADV,'Y',0,'N',  nvl(se.avladvance,0))- ci.odamt - ci.dfdebtamt - ci.dfintdebtamt - ci.depofeeamt-CEIL(CI.CIDEPOFEEACR) - NVL (se.advamt, 0)-nvl(se.secureamt,0) - ci.trfbuyamt+ LEAST(AF.MRCRLIMIT,nvl(se.secureamt,0) + ci.trfbuyamt) - ci.ramt OUTSTANDING_HOLD_DEPOFEE, --kHI DAT LENH THI THEM PHAN T0
                         nvl(af.advanceline,0) + ci.balance  - ci.odamt - ci.dfdebtamt - ci.dfintdebtamt - ci.depofeeamt-CEIL(CI.CIDEPOFEEACR) - NVL (se.advamt, 0)-nvl(se.secureamt,0) - ci.trfbuyamt - ci.ramt OUTSTANDING_HOLD_DEPOFEE_RLS, --kHI DAT LENH THI THEM PHAN T0
                        af.mrirate,af.mrmrate,af.mrlrate,
                        se.chksysctrl,
                        nvl(se.avladvance,0) avladvance, nvl(se.advanceamount,0) advanceamount, nvl(se.paidamt,0) paidamt,
                        nvl(se.SEASS,0) SEASS, nvl(se.SEAMT,0) SEAMT, nvl(margin74amt,0) margin74amt,
                        af.MRIRATIO, depofeeamt, CI.dueamt, CI.ovamt, nvl(se.execbuyamt,0) execbuyamt,
                        ci.bankbalance,ci.bankavlbal,
                        nvl(se.rcvamt,0) rcvamt, --Tien cho ve tru phi thue
                        nvl(se.aamt,0) rcvadvamt, --Tien dang ung truoc
                        nvl(td.tdbalance,0) tdbalance,
                       nvl(td.TDINTAMT,0) TDINTAMT,
                       nvl(td.TDODAMT,0) TDODAMT,
                       nvl(td.TDODINTACR,0) TDODINTACR,
                       se.MARGINRATE,
                       nvl(se.navaccount,0) se_navaccount,
                       nvl(se.outstanding,0) se_outstanding,
                       greatest(
                          balance - ci.buysecamt - CI.ovamt - CI.dueamt - ci.dfdebtamt - ci.dfintdebtamt - ramt - CI.DEPOFEEAMT-CEIL(CI.CIDEPOFEEACR)
                             ,0) baldefovd_released_adv,af.clamtlimit,se.dclamtlimit
                   from cimast ci inner join afmast af on ci.acctno=af.acctno
                        left join (select * from v_getsecmarginratio where afacctno = pv_CONDVALUE) se on se.afacctno=ci.acctno
                        left join (select TRFACCTNO, nvl(sum(ln.PRINOVD + ln.INTOVDACR + ln.INTNMLOVD + ln.OPRINOVD + ln.OPRINNML + ln.OINTNMLOVD + ln.OINTOVDACR+ln.OINTDUE+ln.OINTNMLACR + nvl(lns.nml,0) + nvl(lns.intdue,0)),0) OVDAMT,
                                                       nvl(sum(ln.PRINNML - nvl(nml,0)+ ln.INTNMLACR),0) NMLMARGINAMT,
                                            nvl(sum(decode(lnt.chksysctrl,'Y',1,0)*(ln.prinnml+ln.prinovd+ln.intnmlacr+ln.intdue+ln.intovdacr+ln.intnmlovd+ln.feeintnmlacr+ln.feeintdue+ln.feeintovdacr+ln.feeintnmlovd)),0) margin74amt
                                        from lnmast ln, lntype lnt, (select acctno, sum(nml) nml, sum(intdue) intdue  from lnschd
                                                            where reftype = 'P' and  overduedate = to_date(cspks_system.fn_get_sysvar('SYSTEM','CURRDATE'),'DD/MM/RRRR') group by acctno) lns
                                        where ln.actype = lnt.actype and ln.acctno = lns.acctno(+) and ln.ftype = 'AF'
                                        and ln.trfacctno = pv_CONDVALUE
                                        group by ln.trfacctno) OVDAF on OVDAF.TRFACCTNO = ci.acctno
                        left join (select afacctno, sum(amt) receivingamt from stschd where afacctno = pv_CONDVALUE and duetype = 'RM' and status <> 'C' and deltd <> 'Y' group by afacctno) sts_rcv
                                on ci.acctno = sts_rcv.afacctno
                        left join
                            (select mst.afacctno, sum(MST.BALANCE) TDBALANCE,
                                    sum(FN_TDMASTINTRATIO(MST.ACCTNO,getcurrdate,
                                                    MST.BALANCE)) TDINTAMT, sum(ODAMT) TDODAMT, sum(ODINTACR) TDODINTACR
                                from tdmast mst
                                where  MST.DELTD<>'Y' AND MST.status in ('N','A') and afacctno = pv_CONDVALUE
                                group by mst.afacctno) td
                            on td.afacctno = ci.acctno
                   WHERE ci.acctno = pv_CONDVALUE);

      ELSE
         --Tai khoan margin join theo group
         SELECT LEAST(SUM((NVL(AF.MRCRLIMIT,0) + NVL(SE.SEAMT,0)+
                                    NVL(adv.avladvance,0)))
                            ,sum(nvl(adv.avladvance,0)+ greatest(NVL(AF.MRCRLIMITMAX,0)+NVL(AF.MRCRLIMIT,0)- dfodamt,0)))
                       + sum(balance  - ODAMT- dfdebtamt- dfintdebtamt - NVL (ADVAMT, 0)-NVL(SECUREAMT,0) - RAMT/* - ci.depofeeamt*/) PP,
                GREATEST (SUM ( NVL (AF.mrcrlimitmax, 0)+ NVL(AF.MRCRLIMIT,0) - dfodamt
                               + balance
                               - odamt
                               - dfdebtamt
                               - dfintdebtamt
                               - NVL (secureamt, 0)
                               - ramt
                               /*- CI.DEPOFEEAMT
                               - CEIL(CI.CIDEPOFEEACR)*/
                              ),
                          0
                         ) avllimit,
                greatest(least(sum(nvl(AF.mrcrlimitmax,0) - dfodamt),
                        sum(nvl(AF.mrcrlimitmax,0) - dfodamt + nvl(af.advanceline,0) -odamt)),0) deallimit,
                GREATEST (SUM (nvl(adv.avladvance,0) + balance  - dfdebtamt
                             - dfintdebtamt- ovamt - dueamt - RAMT- ci.depofeeamt-CEIL(CI.CIDEPOFEEACR)), 0) baldefovd,
                greatest(round(least(sum(nvl(adv.avladvance,0) + balance - ci.buysecamt ),
                                    sum(nvl(adv.avladvance,0) + balance - ci.buysecamt  +
                                    af.advanceline -NVL (advamt, 0)-
                                    nvl(secureamt,0)-ramt)
                            ),0
                   ),0) baldefovd_released,
                SUM (  /*NVL (af.mrcrlimit, 0)
                     +*/ NVL (se.seass, 0)
                    ) navaccount,
                SUM (  ci.balance
                     + NVL (adv.avladvance, 0)
                     - ci.odamt
                     - ci.dfdebtamt
                     - ci.dfintdebtamt
                     - NVL (b.secureamt, 0)
                     - ci.ramt
                     + least(nvl(af.mrcrlimit,0),NVL (b.secureamt, 0))
                    ) outstanding,
                SUM (CASE
                        WHEN af.acctno <> pv_condvalue
                           THEN 0
                        ELSE af.mrirate
                     END) mrirate,
                GREATEST (SUM (nvl(adv.avladvance,0) + balance - ci.buysecamt - dfdebtamt
                             - dfintdebtamt- ovamt - dueamt - ramt), 0) baldefovd_released_depofee, -- Su dung de check khi thu phi luu ky,
                nvl(adv.avladvance,0) avladvance, nvl(adv.advanceamount,0) advanceamount, nvl(adv.paidamt,0) paidamt, nvl(b.execbuyamt,0) EXECBUYAMT
           INTO l_pp,
                l_avllimit,
                l_deallimit,
                l_baldefovd,
                l_baldefovd_Released,
                l_navaccount,
                l_outstanding,
                l_mrirate,
                l_baldefovd_Released_depofee,
                l_avladvance,
                l_advanceamount,
                l_paidamt,
                l_execbuyamt
           FROM cimast ci INNER JOIN afmast af ON ci.acctno = af.acctno
                                          AND af.groupleader = l_groupleader
                LEFT JOIN (SELECT b.*
                             FROM v_getbuyorderinfo b, afmast af
                            WHERE b.afacctno = af.acctno
                              AND af.groupleader = l_groupleader) b ON ci.acctno =
                                                                         b.afacctno
                LEFT JOIN (SELECT b.*
                             FROM v_getsecmargininfo b, afmast af
                            WHERE b.afacctno = af.acctno
                              AND af.groupleader = l_groupleader) se ON se.afacctno =
                                                                          ci.acctno
                left join
                        (select sum(depoamt) avladvance,afacctno, sum(advamt) advanceamount, sum(paidamt) paidamt
                            from v_getAccountAvlAdvance b , afmast af where b.afacctno =af.acctno and af.groupleader=l_groupleader group by afacctno) adv
                        on adv.afacctno=ci.acctno
                ;

         OPEN pv_refcursor FOR
            SELECT ci.actype, ci.acctno, ci.ccycd,
                   ci.afacctno, ci.custid, ci.opndate,
                   ci.clsdate, ci.lastdate, ci.dormdate,
                   ci.status, ci.pstatus,
                   af.advanceline ,
                   ci.balance   - NVL (secureamt, 0) balance,
                   ci.balance  + l_avladvance avlbal,
                   ci.cramt,
                   ci.dramt, ci.crintacr,ci.CIDEPOFEEACR, ci.crintdt,
                   ci.odintacr, ci.odintdt, ci.avrbal,
                   ci.mdebit, ci.mcredit, ci.aamt, ci.ramt,
                   NVL (secureamt, 0) bamt, ci.emkamt, ci.mmarginbal,
                   ci.marginbal, ci.iccfcd, ci.iccftied,
                   ci.odlimit, ci.adintacr, ci.adintdt,
                   ci.facrtrade, ci.facrdepository, ci.facrmisc,
                   ci.minbal, ci.odamt, ci.namt, ci.floatamt,
                   ci.holdbalance, ci.pendinghold,
                   ci.pendingunhold, ci.corebank,
                   (case when ci.corebank = 'Y' then ci.corebank else af.alternateacct end) allowcorebank,
                   ci.receiving,
                   ci.netting, ci.mblock,l_margintype mrtype,
                   greatest(NVL (af.advanceline, 0) + l_pp,0) pp,
                   NVL (af.advanceline, 0) + l_avllimit avllimit,
                   l_deallimit deallimit,
                   l_navaccount navaccount, l_outstanding outstanding,
                   l_mrirate mrirate,
                   TRUNC
                      (GREATEST ((CASE
                                     WHEN l_mrirate > 0
                                        THEN   least(l_navaccount * 100 / l_mrirate
                                             + l_outstanding,l_avllimit)
                                     ELSE l_navaccount + l_outstanding
                                  END
                                 )- nvl(pd.dealpaidamt,0),
                                 0
                                ),
                       0
                      ) avlwithdraw,
                   TRUNC
                      ((CASE
                           WHEN l_mrirate > 0
                              THEN LEAST (GREATEST (  (  100 * l_navaccount
                                                       +   l_outstanding
                                                         * l_mrirate
                                                      )
                                                    / l_mrirate,
                                                    0
                                                   ),
                                          --l_baldefovd,
                                          greatest(balance - ci.buysecamt - dfdebtamt-dfintdebtamt - ovamt-dueamt - ramt-af.advanceline,0),
                                          l_avllimit
                                         )
                           ELSE GREATEST (  balance - ci.buysecamt
                                          - odamt
                                          - dfdebtamt-dfintdebtamt
                                          - NVL (advamt, 0)
                                          - NVL (secureamt, 0)
                                          - ramt,
                                          0
                                         )
                        END
                       ) - nvl(pd.dealpaidamt,0) - CI.DEPOFEEAMT-CEIL(CI.CIDEPOFEEACR),
                       0
                      ) baldefovd,
                      l_baldefovd_Released baldefovd_Released,
                      dfdebtamt, dfintdebtamt,
                      TRUNC
                      ((CASE
                           WHEN l_mrirate > 0
                              THEN LEAST (GREATEST (  (  100 * l_navaccount
                                                       +   l_outstanding
                                                         * l_mrirate
                                                      )
                                                    / l_mrirate,
                                                    0
                                                   ),
                                          --l_baldefovd,
                                          greatest(balance - ci.buysecamt - dfdebtamt-dfintdebtamt - ovamt-dueamt - ramt-af.advanceline,0),
                                          l_avllimit
                                         )
                           ELSE GREATEST (  balance - ci.buysecamt
                                          - odamt
                                          - dfdebtamt-dfintdebtamt
                                          - NVL (advamt, 0)
                                          - NVL (secureamt, 0)
                                          - ramt,
                                          0
                                         )
                        END
                       ) - nvl(pd.dealpaidamt,0),
                       0
                      ) baldefovd_Released_depofee, -- Su dung check khi thu phi luu ky
                      l_avladvance avladvance,
                        l_advanceamount advanceamount,
                        l_paidamt paidamt,  nvl(se.SEASS,0) SEASS, nvl(se.SEAMT,0) SEAMT, l_execbuyamt execbuyamt,
                   ci.bankbalance,ci.bankavlbal, ci.depofeeamt,
                    TRUNC
                      ((CASE
                           WHEN l_mrirate > 0
                              THEN LEAST (GREATEST (  (  100 * l_navaccount
                                                       +   l_outstanding
                                                         * l_mrirate
                                                      )
                                                    / l_mrirate,
                                                    0
                                                   ),
                                          --l_baldefovd,
                                          greatest(balance - ci.buysecamt - dfdebtamt-dfintdebtamt - ovamt-dueamt - ramt-af.advanceline,0),
                                          l_avllimit
                                         )
                           ELSE GREATEST (  balance - ci.buysecamt
                                          - odamt
                                          - dfdebtamt-dfintdebtamt
                                          - NVL (advamt, 0)
                                          - NVL (secureamt, 0)
                                          - ramt,
                                          0
                                         )
                        END
                       ) - nvl(pd.dealpaidamt,0) - CI.DEPOFEEAMT-CEIL(CI.CIDEPOFEEACR),
                       0
                      ) BALDEFOVD_HOLD_DEPOFEEAMT,

                      TRUNC
                      ((CASE
                           WHEN l_mrirate > 0
                              THEN LEAST (GREATEST (  (  100 * l_navaccount
                                                       +   l_outstanding
                                                         * l_mrirate
                                                      )
                                                    / l_mrirate,
                                                    0
                                                   ),
                                          --l_baldefovd,
                                          greatest(balance - ci.buysecamt - dfdebtamt-dfintdebtamt - ovamt-dueamt - ramt-af.advanceline,0),
                                          l_avllimit
                                         )
                           ELSE GREATEST (  balance - ci.buysecamt
                                          - odamt
                                          - dfdebtamt-dfintdebtamt
                                          - NVL (advamt, 0)
                                          - NVL (secureamt, 0)
                                          - ramt,
                                          0
                                         )
                        END
                       ) - nvl(pd.dealpaidamt,0) - CI.DEPOFEEAMT-CEIL(CI.CIDEPOFEEACR),
                       0
                      ) baldefovd_released_adv

              FROM cimast ci INNER JOIN afmast af ON ci.acctno = af.acctno
                   LEFT JOIN (SELECT *
                                FROM v_getbuyorderinfo
                               WHERE afacctno = pv_condvalue) b ON ci.acctno =
                                                                     b.afacctno
                   LEFT JOIN (SELECT *
                                FROM v_getsecmargininfo se
                               WHERE se.afacctno = pv_condvalue) se ON se.afacctno =
                                                                         ci.acctno
                   LEFT JOIN
                              (select *
                                  from v_getdealpaidbyaccount p where p.afacctno = pv_condvalue) pd
                              on pd.afacctno=ci.acctno
             WHERE ci.acctno = pv_condvalue;
      END IF;

      l_i := 0;
      LOOP
         FETCH pv_refcursor
          INTO l_cimastcheck_rectype;

         l_cimastcheck_arrtype (l_i) := l_cimastcheck_rectype;
         EXIT WHEN pv_refcursor%NOTFOUND;
         l_i := l_i + 1;
      END LOOP;
      --close pv_refcursor;
      /*FETCH pv_refcursor
          bulk collect INTO l_cimastcheck_arrtype;
      close pv_refcursor;*/
      RETURN l_cimastcheck_arrtype;
   EXCEPTION
      WHEN OTHERS
      THEN
         plog.error(dbms_utility.format_error_backtrace);
         if pv_refcursor%ISOPEN THEN
            CLOSE pv_refcursor;
         END IF;
         RETURN l_cimastcheck_arrtype;
   END fn_cimastcheck;

   FUNCTION fn_semastcheck (
      pv_condvalue   IN   VARCHAR2,
      pv_tblname     IN   VARCHAR2,
      pv_fldkey      IN   VARCHAR2
   )
      RETURN semastcheck_arrtype
   IS
      l_semastcheck_rectype   semastcheck_rectype;
      l_semastcheck_arrtype   semastcheck_arrtype;
      l_i                     NUMBER (10);
      pv_refcursor            pkg_report.ref_cursor;
      l_txdate                DATE;
      l_setype                setype.actype%TYPE;
      l_custid                semast.custid%TYPE;
       L_COUNT                NUMBER(5);
   BEGIN                                                               -- Proc
      SELECT TO_DATE (varvalue, 'DD/MM/YYYY')
        INTO l_txdate
        FROM sysvar
       WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';

       SELECT COUNT(*) INTO L_COUNT FROM SEMAST WHERE ACCTNO = pv_condvalue;
       L_COUNT := NVL(L_COUNT,0);
    IF L_COUNT > 0 THEN
      OPEN pv_refcursor FOR
         SELECT semast.actype, semast.acctno, semast.codeid, semast.afacctno,
                semast.opndate, semast.clsdate, semast.lastdate,
                semast.status, semast.pstatus, semast.irtied, semast.ircd,
                semast.costprice, greatest(semast.trade - NVL (b.secureamt, 0) + NVL(b.sereceiving,0),0) trade,
                semast.mortage - NVL (b.securemtg, 0) mortage,nvl(df.sumdfqtty,0) - NVL (b.securemtg, 0) dfmortage, semast.margin,
                semast.netting, abs(semast.standing)standing, semast.withdraw,
                semast.deposit, semast.loan, semast.blocked, semast.receiving,
                semast.transfer, semast.prevqtty, semast.dcrqtty,
                semast.dcramt, semast.depofeeacr, semast.repo, semast.pending,
                semast.tbaldepo, semast.custid, semast.costdt,
                NVL (b.securemtg, 0) + NVL (b.secureamt, 0) secured,
                semast.iccfcd, semast.iccftied, semast.tbaldt,
                semast.senddeposit, semast.sendpending, semast.ddroutqtty,
                semast.ddroutamt, semast.dtoclose, semast.sdtoclose,
                semast.qtty_transfer,
                greatest(semast.trade - nvl(b.secureamt,0) + nvl(b.sereceiving,0),0) trading,
                semast.emkqtty,semast.blockwithdraw,semast.blockdtoclose,
                abs(semast.standing) absstanding

           FROM semast, v_getsellorderinfo b,
           (SELECT afacctno,codeid, sum(dfqtty) sumdfqtty FROM dfmast GROUP BY afacctno, codeid) df
          WHERE acctno = pv_condvalue AND acctno = b.seacctno(+) AND df.afacctno(+) = semast.afacctno AND df.codeid(+) = semast.codeid;

      l_i := 0;

      LOOP
         FETCH pv_refcursor
          INTO l_semastcheck_rectype;
         EXIT WHEN pv_refcursor%NOTFOUND;
         l_semastcheck_arrtype (l_i) := l_semastcheck_rectype;
         l_i := l_i + 1;
      END LOOP;
      --close pv_refcursor;
      /*FETCH pv_refcursor
          bulk collect INTO l_semastcheck_arrtype;
      close pv_refcursor;*/

      --- IF (l_semastcheck_arrtype.count) <= 0   THEN
      else
         --Securities account does not exits
         --Automatic open sub securities account
         SELECT aft.setype, af.custid
           INTO l_setype, l_custid
           FROM afmast af, aftype aft
          WHERE af.actype = aft.actype AND af.acctno = SUBSTR(pv_condvalue,1,10);

         INSERT INTO semast
                     (actype, custid, acctno,
                      codeid,
                      afacctno, opndate, lastdate,
                      costdt, tbaldt, status, irtied, ircd, costprice, trade,
                      mortage, margin, netting, standing, withdraw, deposit,
                      loan
                     )
              VALUES (l_setype, l_custid, pv_condvalue,
                      SUBSTR (pv_condvalue, 11, 6),
                      SUBSTR (pv_condvalue, 1, 10), l_txdate, l_txdate,
                      l_txdate, l_txdate, 'A', 'Y', '000', 0, 0,
                      0, 0, 0, 0, 0, 0,
                      0
                     )
           RETURNING actype,
                     custid,
                     acctno,
                     codeid,
                     afacctno,
                     opndate,
                     lastdate,
                     costdt,
                     tbaldt,
                     status,
                     irtied,
                     ircd,
                     costprice,
                     trade,
                     mortage,
                     margin,
                     netting,
                     standing,
                     withdraw,
                     deposit,
                     loan,
                     l_txdate,    --      clsdate         semast.clsdate%TYPE,
                     '',          --      pstatus         semast.pstatus%TYPE,
                     0,           --      blocked         semast.blocked%TYPE,
                     0,         --      receiving       semast.receiving%TYPE,
                     0,          --      transfer        semast.transfer%TYPE,
                     0,          --      prevqtty        semast.prevqtty%TYPE,
                     0,           --      dcrqtty         semast.dcrqtty%TYPE,
                     0,            --      dcramt          semast.dcramt%TYPE,
                     0,        --      depofeeacr      semast.depofeeacr%TYPE,
                     0,              --      repo            semast.repo%TYPE,
                     0,           --      pending         semast.pending%TYPE,
                     0,          --      tbaldepo        semast.tbaldepo%TYPE,
                     0,           --      secured         semast.secured%TYPE,
                     '',           --      iccfcd          semast.iccfcd%TYPE,
                     '',         --      iccftied        semast.iccftied%TYPE,
                     0,       --      senddeposit     semast.senddeposit%TYPE,
                     0,       --      sendpending     semast.sendpending%TYPE,
                     0,        --      ddroutqtty      semast.ddroutqtty%TYPE,
                     0,         --      ddroutamt       semast.ddroutamt%TYPE,
                     0,          --      dtoclose        semast.dtoclose%TYPE,
                     0,         --      sdtoclose       semast.sdtoclose%TYPE,
                     0,       --      qtty_transfer   semast.qtty_transfer%TYPE
                     0,
                    emkqtty,       --      emkqtty   semast.emkqtty%TYPE
                     blockwithdraw,       --      blockwithdraw   semast.blockwithdraw%TYPE
                    blockdtoclose,       --      blockdtoclose   semast.blockdtoclose%TYPE
                    abs(standing)
                INTO l_semastcheck_arrtype (0).actype,
                     l_semastcheck_arrtype (0).custid,
                     l_semastcheck_arrtype (0).acctno,
                     l_semastcheck_arrtype (0).codeid,
                     l_semastcheck_arrtype (0).afacctno,
                     l_semastcheck_arrtype (0).opndate,
                     l_semastcheck_arrtype (0).lastdate,
                     l_semastcheck_arrtype (0).costdt,
                     l_semastcheck_arrtype (0).tbaldt,
                     l_semastcheck_arrtype (0).status,
                     l_semastcheck_arrtype (0).irtied,
                     l_semastcheck_arrtype (0).ircd,
                     l_semastcheck_arrtype (0).costprice,
                     l_semastcheck_arrtype (0).trade,
                     l_semastcheck_arrtype (0).mortage,
                     l_semastcheck_arrtype (0).margin,
                     l_semastcheck_arrtype (0).netting,
                     l_semastcheck_arrtype (0).standing,
                     l_semastcheck_arrtype (0).withdraw,
                     l_semastcheck_arrtype (0).deposit,
                     l_semastcheck_arrtype (0).loan,
                     l_semastcheck_arrtype (0).clsdate,
                     l_semastcheck_arrtype (0).pstatus,
                     l_semastcheck_arrtype (0).blocked,
                     l_semastcheck_arrtype (0).receiving,
                     l_semastcheck_arrtype (0).transfer,
                     l_semastcheck_arrtype (0).prevqtty,
                     l_semastcheck_arrtype (0).dcrqtty,
                     l_semastcheck_arrtype (0).dcramt,
                     l_semastcheck_arrtype (0).depofeeacr,
                     l_semastcheck_arrtype (0).repo,
                     l_semastcheck_arrtype (0).pending,
                     l_semastcheck_arrtype (0).tbaldepo,
                     l_semastcheck_arrtype (0).secured,
                     l_semastcheck_arrtype (0).iccfcd,
                     l_semastcheck_arrtype (0).iccftied,
                     l_semastcheck_arrtype (0).senddeposit,
                     l_semastcheck_arrtype (0).sendpending,
                     l_semastcheck_arrtype (0).ddroutqtty,
                     l_semastcheck_arrtype (0).ddroutamt,
                     l_semastcheck_arrtype (0).dtoclose,
                     l_semastcheck_arrtype (0).sdtoclose,
                     l_semastcheck_arrtype (0).qtty_transfer,
                     l_semastcheck_arrtype (0).trading,
                     l_semastcheck_arrtype (0).emkqtty,
                     l_semastcheck_arrtype (0).blockwithdraw,
                     l_semastcheck_arrtype (0).dtoclose,
                     l_semastcheck_arrtype (0).absstanding

                     ;
      END IF;

      RETURN l_semastcheck_arrtype;
   EXCEPTION
      WHEN OTHERS
      THEN
        if pv_refcursor%ISOPEN THEN
            CLOSE pv_refcursor;
         END IF;
         RETURN l_semastcheck_arrtype;
   END fn_semastcheck;

   FUNCTION fn_afmastcheck (
      pv_condvalue   IN   VARCHAR2,
      pv_tblname     IN   VARCHAR2,
      pv_fldkey      IN   VARCHAR2
   )
      RETURN afmastcheck_arrtype
   IS
      l_afmastcheck_rectype   afmastcheck_rectype;
      l_afmastcheck_arrtype   afmastcheck_arrtype;
      l_i                     NUMBER (10);
      pv_refcursor            pkg_report.ref_cursor;
      l_currdate              DATE;
   BEGIN                                                               -- Proc

      l_currdate:= to_date(cspks_system.fn_get_sysvar('SYSTEM', 'CURRDATE'),SYSTEMNUMS.c_date_format);
      OPEN pv_refcursor FOR
         SELECT af.actype, af.custid, af.acctno, af.aftype, cf.tradefloor,
                cf.tradetelephone, cf.tradeonline, cf.pin, af.bankacctno, af.bankname,
                af.swiftcode, cf.email, cf.address, cf.fax,
                af.lastdate, af.status, af.pstatus,
                af.advanceline, af.bratio, af.termofuse, af.description, af.isotc,
                cf.consultant, af.pisotc, af.opndate, af.corebank, af.via,
                af.mrirate, af.mrmrate, af.mrlrate, af.mrcrlimit, af.mrcrlimitmax, af.groupleader,
                af.t0amt, mr.mrtype,
                (case when cf.custatcom= 'Y' then 'C' else 'T' end) CUSTODIANTYP,
                substr(cf.custodycd,4,1) CUSTTYPE,
                (cf.idexpired - l_currdate) idexpdays,
                decode(af.TERMOFUSE,'003',0,1) WARNINGTERMOFUSE,af.clamtlimit
           FROM afmast af, aftype aft, mrtype mr, cfmast cf
          WHERE af.custid = cf.custid
            and af.actype = aft.actype
            --AND af.aftype = aft.aftype
            AND aft.mrtype = mr.actype
            AND af.acctno = pv_condvalue;

         l_i := 0;
         LOOP
             FETCH pv_refcursor
              INTO l_afmastcheck_rectype;

             l_afmastcheck_arrtype (l_i) := l_afmastcheck_rectype;
             EXIT WHEN pv_refcursor%NOTFOUND;
             l_i := l_i + 1;
         END LOOP;
         --close pv_refcursor;
         /*FETCH pv_refcursor
          bulk collect INTO l_afmastcheck_arrtype;
         close pv_refcursor;*/


      RETURN l_afmastcheck_arrtype;
   EXCEPTION
      WHEN OTHERS
      THEN
         if pv_refcursor%ISOPEN THEN
            CLOSE pv_refcursor;
         END IF;
         RETURN l_afmastcheck_arrtype;
   END fn_afmastcheck;

   FUNCTION fn_dfmastcheck (
      pv_condvalue   IN   VARCHAR2,
      pv_tblname     IN   VARCHAR2,
      pv_fldkey      IN   VARCHAR2
   )
      RETURN dfmastcheck_arrtype
   IS
      l_dfmastcheck_rectype   dfmastcheck_rectype;
      l_dfmastcheck_arrtype   dfmastcheck_arrtype;
      l_i                     NUMBER (10);
      pv_refcursor            pkg_report.ref_cursor;
   BEGIN                                                               -- Proc
      OPEN pv_refcursor FOR
         select
            ACCTNO,AFACCTNO,LNACCTNO,FULLNAME,TXDATE,TXNUM,TXTIME,ACTYPE,RRTYPE,DFTYPE,
            CUSTBANK,LNTYPE,FEE,FEEMIN,TAX,AMTMIN,CODEID,SYMBOL,REFPRICE,DFPRICE,
            TRIGGERPRICE,DFRATE,IRATE,MRATE,LRATE,CALLTYPE,DFQTTY,BQTTY,RCVQTTY,CARCVQTTY,BLOCKQTTY,
            RLSQTTY,DFAMT,RLSAMT,AMT,INTAMTACR,FEEAMT,RLSFEEAMT,STATUS,DFREF,DESCRIPTION,
            PRINNML,PRINOVD,INTNMLACR,INTOVDACR,INTNMLOVD,INTDUE,INTPREPAID,
            OPRINNML,OPRINOVD,OINTNMLACR,OINTOVDACR,OINTNMLOVD,OINTDUE,OINTPREPAID,
            FEEDUE,FEEOVD,DEALAMT,DEALFEE,RTT,REMAINQTTY ,AVLFEEAMT,ODAMT,TAMT,CALLAMT,AVLRLSQTTY,AVLRLSAMT,DFTRADING,SECURED
        from v_getDealInfo df where df.acctno =pv_condvalue;
         l_i := 0;
         LOOP
             FETCH pv_refcursor
              INTO l_dfmastcheck_rectype;

             l_dfmastcheck_arrtype (l_i) := l_dfmastcheck_rectype;
             EXIT WHEN pv_refcursor%NOTFOUND;
             l_i := l_i + 1;
         END LOOP;

         --close pv_refcursor;
         /*FETCH pv_refcursor
          bulk collect INTO l_afmastcheck_arrtype;
         close pv_refcursor;*/


      RETURN l_dfmastcheck_arrtype;
   EXCEPTION
      WHEN OTHERS
      THEN
         if pv_refcursor%ISOPEN THEN
            CLOSE pv_refcursor;
         END IF;
         RETURN l_dfmastcheck_arrtype;
   END fn_dfmastcheck;

   FUNCTION fn_sewithdrawcheck (
      pv_condvalue   IN   VARCHAR2,
      pv_tblname     IN   VARCHAR2,
      pv_fldkey      IN   VARCHAR2
   )
      RETURN sewithdrawcheck_arrtype
   IS
      l_margintype                CHAR (1);
      l_actype                    VARCHAR2 (4);
      l_groupleader               VARCHAR2 (10);
      l_baldefovd                 NUMBER (20, 0);
      l_pp                        NUMBER (20, 0);
      l_avllimit                  NUMBER (20, 0);
      l_navaccount                NUMBER (20, 0);
      l_outstanding               NUMBER (20, 0);
      l_mrirate                   NUMBER (20, 4);
      l_sewithdrawcheck_rectype   sewithdrawcheck_rectype;
      l_sewithdrawcheck_arrtype   sewithdrawcheck_arrtype;
      l_i                         NUMBER (10);
      pv_refcursor                pkg_report.ref_cursor;
      l_count number;
   BEGIN                                                               -- Proc
      SELECT mr.mrtype, af.actype, mst.groupleader
        INTO l_margintype, l_actype, l_groupleader
        FROM afmast mst, aftype af, mrtype mr
       WHERE mst.actype = af.actype
         AND af.mrtype = mr.actype
         AND mst.acctno = SUBSTR (pv_condvalue, 1, 10);

      IF l_margintype = 'N' or l_margintype = 'L'
      THEN
         OPEN pv_refcursor FOR
            SELECT 1000000000 avlsewithdraw
              FROM DUAL;
      ELSIF     l_margintype in ('S','T','F')
            AND (LENGTH (l_groupleader) = 0 OR l_groupleader IS NULL)
      THEN
         --Tai khoan margin khong tham gia group
         OPEN pv_refcursor FOR
            select least(se.trade- nvl(od.SELLQTTY,0),
                            (CASE WHEN LEAST(NVL(SB.MARGINCALLPRICE,0),NVL(RSK.MRPRICERATE,0)) * NVL(RSK.MRRATIORATE,0) <=0 THEN 1000000000
                                ELSE
                            trunc(GREATEST((100* SEASS + (OUTSTANDING-CI.CIDEPOFEEACR-CI.DEPOFEEAMT) * sec.MRIRATE)/sec.MRIRATE,0)/LEAST(SB.MARGINCALLPRICE,
                            RSK.MRPRICERATE) / (MRRATIORATE/100),0)
                            END)) avlsewithdraw
             from semast se, securities_info sb, cimast ci,
             (select af.acctno afacctno,af.advanceline,af.MRIRATE, nvl(rsk.mrpricerate,1) mrpricerate, nvl(rsk.mrratiorate,0) mrratiorate
                from afmast af, (select * from afserisk where codeid = substr(pv_condvalue,11,6)) rsk
                where af.acctno = substr(pv_CONDVALUE,1,10) and af.actype = rsk.actype(+)) rsk,
             (select * from v_getsecmarginratio where afacctno = substr(pv_CONDVALUE,1,10)) sec,
             (select od.seacctno,
                        sum(case when od.exectype in ('NS','SS') and to_date(sy.varvalue,'DD/MM/RRRR') = od.txdate then remainqtty + execqtty else 0 end) SELLQTTY,
                        sum(case when od.exectype in ('NS','SS') and to_date(sy.varvalue,'DD/MM/RRRR') = od.txdate then execqtty else 0 end) EXECSELLQTTY,
                        sum(case when od.exectype in ('MS') and to_date(sy.varvalue,'DD/MM/RRRR') = od.txdate then remainqtty + execqtty else 0 end) MTGSELLQTTY,
                        sum(case when od.exectype = 'NB' then sts.qtty - sts.aqtty else 0 end) RECEIVING,
                        sum(CASE WHEN OD.EXECTYPE = 'NB' and to_date(sy.varvalue,'DD/MM/RRRR') = od.txdate then od.REMAINQTTY ELSE 0 END) REMAINQTTY
                        from odmast od, (select * from stschd where duetype in ('RS','SS')) sts, sysvar sy
                        where od.orderid = sts.orgorderid(+)
                        and sy.varname = 'CURRDATE'
                        group by od.seacctno) od
             where se.acctno = pv_CONDVALUE and se.afacctno = sec.afacctno(+)
                and se.afacctno = rsk.afacctno(+)
                and se.acctno = od.seacctno(+)
                and se.codeid = sb.codeid and ci.acctno = se.afacctno;
      ELSE
         --Tai khoan margin join theo group
         OPEN pv_refcursor FOR
            SELECT (CASE
                       WHEN   LEAST (NVL (sb.margincallprice, 0),
                                     NVL (rsk.mrpricerate, 0)
                                    )
                            * NVL (rsk.mrratiorate, 0) <= 0
                          THEN 1000000000
                       ELSE TRUNC (  (navaccount * 100 + outstanding * mrirate
                                     )
                                   / LEAST (sb.margincallprice, rsk.mrpricerate)
                                   / mrratiorate,
                                   0
                                  )
                    END
                   ) avlsewithdraw
              FROM (SELECT af.acctno, af.actype, af.mrirate, navaccount,
                           outstanding
                      FROM (SELECT   SUBSTR (pv_condvalue, 1, 10) afacctno,
                                     SUM (  NVL (af.mrcrlimit, 0)
                                          + NVL (se.seass, 0)
                                         ) navaccount,
                                     SUM (  balance
                                          + NVL (se.receivingamt, 0)
                                          - odamt
                                          - NVL (advamt, 0)
                                          - NVL (secureamt, 0)
                                          - ramt
                                         ) outstanding
                                FROM cimast ci INNER JOIN afmast af ON af.acctno =
                                                                      ci.afacctno
                                                               AND af.groupleader =
                                                                      l_groupleader
                                     LEFT JOIN (SELECT b.*
                                                  FROM v_getbuyorderinfo b,
                                                       afmast af
                                                 WHERE b.afacctno = af.acctno
                                                   AND af.groupleader =
                                                                 l_groupleader) b ON ci.acctno =
                                                                                       b.afacctno
                                     LEFT JOIN (SELECT b.*
                                                  FROM v_getsecmargininfo b,
                                                       afmast af
                                                 WHERE b.afacctno = af.acctno
                                                   AND af.groupleader =
                                                                 l_groupleader) se ON se.afacctno =
                                                                                        ci.acctno
                            GROUP BY af.groupleader) a,
                           afmast af
                     WHERE a.afacctno = af.acctno) mst,
                   afserisk rsk,
                   securities_info sb
             WHERE mst.actype = rsk.actype(+)
               AND sb.codeid = SUBSTR (pv_condvalue, 11, 6)
               AND rsk.codeid(+) = SUBSTR (pv_condvalue, 11, 6);
      END IF;

      l_i := 0;

      LOOP
         FETCH pv_refcursor
          INTO l_sewithdrawcheck_rectype;

         l_sewithdrawcheck_arrtype (l_i) := l_sewithdrawcheck_rectype;
         EXIT WHEN pv_refcursor%NOTFOUND;
         l_i := l_i + 1;
      END LOOP;
      --close pv_refcursor;
      /*FETCH pv_refcursor
          bulk collect INTO l_sewithdrawcheck_arrtype;
      close pv_refcursor;*/

      RETURN l_sewithdrawcheck_arrtype;
   EXCEPTION
      WHEN OTHERS
      THEN
         if pv_refcursor%ISOPEN THEN
            CLOSE pv_refcursor;
         END IF;
         RETURN l_sewithdrawcheck_arrtype;
   END fn_sewithdrawcheck;

FUNCTION fn_aftxmapcheck (
      pv_acctno   IN   VARCHAR2,
      pv_tblname     IN   VARCHAR2,
      pv_acfld       IN varchar2,
      pv_tltxcd in varchar2
   )
      RETURN VARCHAR2
   IS
     l_result boolean;
     l_afacctno varchar2(10);
     l_currdate date;
     l_count number(5);
     l_actype VARCHAR2(4);
     l_ChgTypeAllow VARCHAR2(1);
   BEGIN
      /*if pv_acfld='05' and pv_tltxcd='1120' then
         --Khong check voi tai khoan duoc chuyen den trong giao dich chuyen doi ung
         return 'TRUE';
      end if;*/
      l_result:=true;
      l_afacctno:='';
      select to_date(varvalue,systemnums.c_date_format) into l_currdate from sysvar where varname ='CURRDATE' and grname ='SYSTEM';
      if pv_tblname='AFMAST' then
          l_afacctno:=   pv_acctno;
      elsif pv_tblname='CIMAST' then
          l_afacctno:=   pv_acctno;
      elsif pv_tblname='SEMAST' then
          l_afacctno:=   substr(pv_acctno,1,10);
      elsif pv_tblname='LNMAST' then
          select trfacctno into l_afacctno from lnmast where acctno =   pv_acctno;
      elsif pv_tblname='DFMAST' then
          select afacctno into l_afacctno from dfmast where acctno =   pv_acctno;
      elsif pv_tblname='ODMAST' then
          select afacctno into l_afacctno from odmast where orderid =   pv_acctno;
      end if;

      -- TruongLD Add
      -- Lay loai hinh cua tieu khoan
      if l_afacctno is not null THEN
         SELECT actype INTO l_actype FROM afmast WHERE acctno = l_afacctno;
      END IF;

      l_count := 0;
      if l_actype is not null THEN
         BEGIN
           SELECT COUNT(1) INTO l_count FROM aftxmap WHERE actype = l_actype AND upper(afacctno) = 'ALL';
           EXCEPTION
                  WHEN OTHERS THEN
                       l_count := 0;
         END;
      END IF;
      -- End TruongLD

      IF l_count <> 0 THEN
         -- Chan theo loai hinh.
         l_count := 0;
         select count(1) into l_count from aftxmap where actype = l_actype and tltxcd = pv_tltxcd
            and effdate<=l_currdate and expdate>l_currdate;
            l_result:= case when l_count>0 then false else true end;
      end if;
      if l_result then
          IF l_afacctno is not null THEN
                -- Chan theo tieu khoan.
                l_count := 0;
                select count(1) into l_count from aftxmap where afacctno = l_afacctno and tltxcd = pv_tltxcd
                and effdate<=l_currdate and expdate>l_currdate;
                l_result:= case when l_count>0 then false else true end;
          END IF;
      end if;
/*
       -- HaiLT them
      select ChgTypeAllow into l_ChgTypeAllow from tltx where tltxcd = pv_tltxcd;
      --Neu check duyet thay doi loai hinh
      if l_ChgTypeAllow = 'N' then
        select COUNT(1) INTO l_count FROM afmast WHERE acctno = l_afacctno and CHGACTYPE = 'Y' and status = 'P';
        l_result:= case when l_count>0 then false else true end;
      end if;
      -- End of HaiLT them

*/

      RETURN case when l_result then 'TRUE' else 'FALSE' end;
   exception when others then
        return 'TRUE';
   END fn_aftxmapcheck;

BEGIN
   FOR i IN (SELECT *
               FROM tlogdebug)
   LOOP
      logrow.loglevel := i.loglevel;
      logrow.log4table := i.log4table;
      logrow.log4alert := i.log4alert;
      logrow.log4trace := i.log4trace;
   END LOOP;

   pkgctx :=
      plog.init ('TXPKS_CHECK',
                 plevel         => NVL (logrow.loglevel, 30),
                 plogtable      => (NVL (logrow.log4table, 'N') = 'Y'),
                 palert         => (NVL (logrow.log4alert, 'N') = 'Y'),
                 ptrace         => (NVL (logrow.log4trace, 'N') = 'Y')
                );
END txpks_check;
/
