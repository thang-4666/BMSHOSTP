SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('RM0008','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('RM0008', 'Sinh bảng kê cắt tiền từ khoản phụ sang tài khoản chính', 'Sinh bảng kê cắt tiền từ khoản phụ sang tài khoản chính', 'select     cra.trfcode trftype,cf.custodycd,
            cf.fullname,cf.address,cf.idcode license,
            af.acctno afacctno,af.acctno CATXNUM,af.bankacctno,cra.refacctno desacctno,cra.refacctname desacctname,
            af.bankname bankcode,af.bankname || '':'' || crb.bankname bankname , af.careby,
            ci.holdbalance- greatest(least(ci.holdbalance,
                                           getavlpp(af.acctno) - af.advanceline,
                                           ci.balance - CI.ovamt - CI.dueamt - ci.dfdebtamt - ci.dfintdebtamt
                                           - ramt - ci.depofeeamt- nvl(trf.trfinday,0)
                                           ),0
                                    ) trfamt
       from cimast ci, afmast af ,cfmast cf,crbdefacct cra,crbdefbank crb,
       --(select * from vw_gettrfbuyamt_byDay) trf
        (SELECT MST.AFACCTNO, sum(MST.AMT + od.feeacr) trfinday
            FROM STSCHD MST, SBSECURITIES SEC, ODMAST OD
            WHERE MST.CODEID=SEC.CODEID AND SEC.TRADEPLACE  <> ''003''
            AND MST.DUETYPE=''SM'' AND MST.STATUS=''N'' AND MST.DELTD<>''Y''
            AND MST.ORGORDERID = OD.ORDERID
            and MST.CLEARDATE <= getcurrdate
            group by mst.afacctno) trf
       where ci.acctno = af.acctno and af.custid= cf.custid
       and af.corebank =''N'' and af.alternateacct=''Y''
       and ci.holdbalance>0
       and ci.holdbalance- greatest(least(ci.holdbalance,
                                           getavlpp(af.acctno) - af.advanceline,
                                           ci.balance - CI.ovamt - CI.dueamt - ci.dfdebtamt - ci.dfintdebtamt
                                           - ramt - ci.depofeeamt- nvl(trf.trfinday,0)
                                           ),0
                                    ) >0
       and af.bankname=cra.refbank and cra.trfcode=''TRFCICAMT''
       and af.bankname=crb.bankcode
       and af.acctno = trf.afacctno(+)
', 'CRBTRFLOG', '', '', '6650', 0, 50, 'N', 30, '', 'Y', 'T', '', 'Y', 'ACCTNO', '');COMMIT;