SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('CF0012','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('CF0012', 'Danh sách cần xác nhận trạng thái VSD', 'Danh sách cần xác nhận trạng thái VSD', '
select distinct CUSTID, FULLNAME, CUSTODYCD, IDCODE, ADDRESS, OPNDATE, c1.cdcontent ACTIVESTS, c2.cdcontent status,
(CASE WHEN CF.CLASS=''000'' THEN ''Có'' ELSE ''Không'' END) PV_CLASS
from cfmast cf, allcode c1, allcode c2
where activests = ''N'' and isbanking = ''N''
AND(CF.NSDSTATUS = ''A'' OR (CF.NSDSTATUS <>''C'' AND INSTR(CF.pstatus,''A'') <> 0))
and cf.custodycd is not null
and c1.cdtype = ''CF'' and c1.cdname = ''ACTIVESTS'' and c1.cdval = cf.activests
and c2.cdtype = ''SA'' and c2.cdname = ''NSDSTATUS'' and c2.cdval = cf.NSDstatus
and SUBSTR(cf.custodycd,1,3) =''086''', 'CFMAST', 'frm', 'CUSTID', '0012', 0, 50, 'N', 30, '', 'Y', 'T', 'CUSTODYCD', 'N', '', 'CUSTID');COMMIT;