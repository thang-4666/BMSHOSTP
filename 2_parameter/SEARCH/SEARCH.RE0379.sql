SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('RE0379','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('RE0379', 'Xóa thông tin KH được gán cho user đặt lệnh trên home', 'Xóa thông tin KH được gán cho user đặt lệnh trên home', 'select lnk.txdate, lnk.tlid, tl.tlname, cf.custodycd, cf.fullname, lnk.afacctno,
    lnk.clstxdate, a1.cdcontent status, lnk.autoid
from afuserlnk lnk, cfmast cf, tlprofiles tl, allcode a1
where lnk.tlid = tl.tlid and lnk.custodycd = cf.custodycd
    and lnk.deltd <> ''Y'' and lnk.status = a1.cdval and lnk.status = ''A''
    and a1.cdtype = ''SA'' and a1.cdname = ''STATUS''', 'RE.REMAST', '', '', '0379', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', 'CUSTODYCD');COMMIT;