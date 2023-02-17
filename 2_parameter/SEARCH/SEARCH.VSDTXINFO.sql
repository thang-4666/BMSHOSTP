SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('VSDTXINFO','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('VSDTXINFO', 'Điện thông báo từ VSD', 'Manage the notification messages from VSD', 'select l.autoid, l.sender, l.msgtype, l.funcname, l.refmsgid,
       l.referenceid, l.finfilename, to_char(l.timecreated,''hh24:mi:ss'')timecreated , l.timeprocess,
       l.status, l.autoconf, l.errdesc, l.symbol, l.reclas, l.reqtty,
       l.refcustodycd, l.reccustodycd, l.vsdeffdate , c.CDCONTENT description, l.timecreated datecreated
from vsdtrflog l, (select trfcode, description CDCONTENT, en_description EN_CDCONTENT,type from vsdtrfcode) c
where l.funcname = c.trfcode
and c.type = ''INF''', 'TTDIENR', 'VSDTXINFO', 'DATECREATED DESC, TIMECREATED DESC', '', 0, 50, 'Y', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;