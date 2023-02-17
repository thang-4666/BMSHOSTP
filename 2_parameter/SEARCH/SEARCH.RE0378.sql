SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('RE0378','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('RE0378', 'Tra cứu thông tin KH được gán cho user đặt lệnh trên home', 'Tra cứu thông tin KH được gán cho user đặt lệnh trên home', 'select lnk.txdate, lnk.tlid, tl.tlname, cf.custodycd, cf.fullname, lnk.afacctno,
    lnk.clstxdate, a1.cdcontent status
from afuserlnk lnk, cfmast cf, tlprofiles tl, allcode a1
where lnk.tlid = tl.tlid and lnk.custodycd = cf.custodycd
    and lnk.deltd <> ''Y'' and lnk.status = a1.cdval
    and a1.cdtype = ''SA'' and a1.cdname = ''STATUS''', 'RE.REMAST', '', '', '', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;