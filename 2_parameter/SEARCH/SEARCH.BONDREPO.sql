SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('BONDREPO','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('BONDREPO', 'Danh sách lệnh repo', 'Danh sách lệnh repo', 'SELECT CF.custodycd, CF.fullname, OD.AFacctno, sb.symbol, a1.cdcontent IBDEALTYPE,
    bo.qtty, bo.amt1, bo.interrestrate, bo.txdate, bo.busdate1, (CASE WHEN bo.leg = ''V'' THEN ''Chiều về'' ELSE ''Chiều di'' END) leg, A2.cdcontent orstatus, BO.REPOACCTNO, BO.REFREPOACCTNO, BO.ENDDATE,
   BO.PARTNER, BO.AMT2, BO.BUSDATE2, BO.TERM
FROM BONDREPO BO, vw_odmast_all OD, AFMAST AF, CFMAST CF, sbsecurities SB,
    allcode a1, ALLCODE A2
WHERE BO.orderid = OD.orderid AND OD.afacctno = AF.acctno
    AND AF.custid = CF.custid AND OD.deltd <> ''Y''
    AND OD.CODEID = SB.codeid and a1.cdname = ''IBDEALTYPE'' and a1.cdtype = ''SA''
    AND SUBSTR(CF.CUSTODYCD,4,1) <> ''P''
    and (case when od.exectype = ''NB'' then ''BONRPB'' else ''BONRPS'' end) = a1.cdval
    AND A2.cdname = ''ORSTATUS'' AND A2.cdtype = ''OD'' AND A2.cdval = OD.orstatus ', 'BONDDEAL', 'frmBONDDEAL', 'TXDATE DESC', '', NULL, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', 'CUSTODYCD');COMMIT;