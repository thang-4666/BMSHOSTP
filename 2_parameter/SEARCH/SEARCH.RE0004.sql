SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('RE0004','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('RE0004', 'Tra cứu khách hàng chưa gán môi giới', 'View custommer not belong to any Remiser/Broker', 'SELECT DISTINCT NVL(cf.custodycd,''A'')custodycd , cf.fullname , cf.opndate,  br.brname description, nvl(tp.tradename, '' '') OFFICE
FROM cfmast cf, brgrp br, tradeplace tp, tradecareby tc
WHERE cf.custodycd IS NOT NULL AND cf.isbanking <> ''Y'' AND cf.status <> ''C'' and br.brid = cf.brid
AND NVL(cf.custodycd,''A'') NOT IN
(SELECT DISTINCT cf.custodycd
FROM reaflnk LNK, remast MST, RETYPE TP, afmast af, cfmast cf
WHERE LNK.status = ''A'' AND LNK.reacctno = MST.acctno AND MST.actype = TP.actype
    and lnk.afacctno = af.custid and af.custid = cf.custid
    AND TP.rerole in (''CS'',''RM'')
    /*AND TP.rerole = ''RM''*/)
 AND cf.careby = tc.grpid(+)
 AND tc.tradeid = tp.traid(+)', 'RE.REMAST', 'frmREMAST', '', '', 0, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', 'CUSTODYCD');COMMIT;