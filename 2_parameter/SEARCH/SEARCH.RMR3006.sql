SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('RMR3006','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('RMR3006', 'Tra cứu khoản vay đã giải ngân', 'View loan released', '
SELECT lns.autoid, cf.custodycd, rls.afacctno, cf.fullname, lns.acctno LNACCTNO, rls.rlsdate, rls.overduedate,
    rls.RLSAMT, nvl(rls.custbank,''BSC'') custbank, LN.actype LNTYPE,
    CASE WHEN LN.ftype = ''AF'' AND LNS.reftype = ''P'' THEN ''MARGIN''
        WHEN LN.ftype = ''AF'' AND LNS.reftype = ''GP'' THEN ''BAO LANH'' ELSE '''' END REFTYPE
FROM rlsrptlog_eod rls, cfmast cf, vw_lnschd_all lns, vw_lnmast_all ln
WHERE lns.autoid = rls.lnschdid and rls.custid = cf.custid
    AND ln.acctno = lns.acctno
', 'LNMAST', '', 'autoid', '', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;