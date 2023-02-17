SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('LN5574','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('LN5574', 'Danh sách deal Margin có thể gia hạn', 'Extendable Margin Deal', 'SELECT   aft.mnemonic,chd.autoid, chd.acctno, chd.overduedate, mst.actype lntype,
         cf.fullname, af.acctno afacctno, cf.custodycd, mst.prinperiod,
         chd.rlsdate, cf.idcode, cf.iddate, cf.idplace,
         cf.address, chd.nml + chd.ovd lnprinamt,
         chd.intnmlacr + chd.intdue + chd.intovd + chd.intovdprin + chd.feedue + chd.feeovd+
         chd.feeintnmlacr +chd.feeintnmlovd+chd.feeintovdacr+ chd.feeintdue + chd.feeintovd lnintamt,
         chd.rate2 intrate,
         ci.balance + decode( sy1.varvalue,''Y'',0,''N'', nvl(adv.avladvance,0)) Baldefovd,
     chd.nml + chd.ovd +chd.paid rlsamt,
         chd.extimes,getprevdate(chd.overduedate,type.exdays) begindate,
  getduedate(get_t_date(getcurrdate()+ LEAST(TYPE.MAXEXDAYS- chd.exdays,type.PRINPERIOD),1) ,''B'',''000'',1)    TODATE
--TO_DATE(''28/03/2015'',''DD/MM/YYYY'') TODATE
  FROM   lnschd chd, lnmast mst, (SELECT * FROM sysvar WHERE varname = ''CURRDATE'') sy,
        (SELECT * FROM sysvar WHERE varname = ''ISSTOPADV'') sy1,
         cfmast cf, afmast af, aftype aft,lntype type, cimast ci,
         (select sum(depoamt) avladvance,afacctno, sum(advamt) advanceamount, sum(paidamt) paidamt, sum(rcvamt) rcvamt, sum(aamt) aamt
          from v_getAccountAvlAdvance
          group by afacctno) adv
 WHERE   chd.overduedate IS NOT NULL
         AND sy.varname = ''CURRDATE'' AND chd.acctno = mst.acctno
         AND cf.custid = af.custid AND af.acctno = mst.trfacctno and af.acctno = ci.acctno
         AND CI.ACCTNO = ADV.AFACCTNO(+)
         and af.actype = aft.actype
         and mst.actype=type.actype
         AND mst.ftype = ''AF'' AND chd.reftype = ''P''
         AND chd.EXTIMES < type.EXTIMES
         AND TO_DATE (chd.overduedate, ''DD/MM/RRRR'') >= TO_DATE (sy.varvalue, ''DD/MM/RRRR'')
         AND  (chd.nml) + (chd.ovd) + (chd.intnmlacr) + (chd.fee) + (chd.intdue) + (chd.intovd) + (intovdprin) + (chd.feedue) + (chd.feeovd) > 0', 'LN5574', 'frmLN5574', 'OVERDUEDATE,ACCTNO ', '', NULL, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', 'CUSTODYCD');COMMIT;