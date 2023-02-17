SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('RM1002','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('RM1002', 'Corebank status', 'Corebank status', 'select g.txdate,G.batchid, g.transtype, g.secaccount
,g.bankaccountname,g.bankaccount,g.amount,g.descriptions,
g.processed,
CASE
WHEN g.transtate IS NULL THEN ''Chưa gửi BIDV''
WHEN g.transtate =''0'' THEN ''Thành công''
WHEN g.transtate =''-1'' THEN ''Lỗi''
WHEN g.transtate =''-670230'' THEN ''Đã gửi BIDV''
WHEN g.transtate =''-670300'' THEN ''Chờ BIDV xử lý''
WHEN g.transtate =''-670301'' THEN ''BIDV Đã giải mã''
WHEN g.transtate =''-670310'' THEN ''BIDV Đã xử lý''
else g.transtate
END transtate,
g.errordesc,g.desaccountname,
g.desaccount
from gwtransferlog g
where processed <>''D''', 'ODMAST', '', '', '', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;