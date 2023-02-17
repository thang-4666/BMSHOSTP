SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('BO2505','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('BO2505', 'Xác nhận lệnh chiều về (Giao dịch 2505)', 'Xác nhận lệnh chiều về (Giao dịch 2505)', 'SELECT CF.FULLNAME, CF.CUSTODYCD, BON.ORDERID, AF.ACCTNO, BON.REPOACCTNO, BON.TXDATE, BON.BUSDATE1, BON.BUSDATE2,
    BON.ENDDATE, BON.INTERRESTRATE, BON.AMT2, BON.AMT1, BON.QTTY, BON.PARTNER, SB.SYMBOL, SB.CODEID, od.exectype
from  bondrepo bon, vw_odmast_all od, afmast af, cfmast cf, sbsecurities SB
where bon.refrepoacctno Is null
 And bon.enddate <= getcurrdate and bon.status = ''A''
 and bon.orderid = od.orderid and od.afacctno = af.acctno
 and af.custid = cf.custid AND OD.codeid = SB.codeid', 'BONDIPO', 'frmBONDIPO', '', '2505', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;