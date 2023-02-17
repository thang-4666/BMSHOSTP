SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('CF0018','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('CF0018', 'Danh sách cần xác nhận từ VSD hoàn tất thay đổi thông tin khách hàng', 'Danh sách cần xác nhận từ VSD hoàn tất thay đổi thông tin khách hàng', 'select cfv.txnum || to_char(cfv.txdate,''DD/MM/RRRR'') txkey, cf.custodycd, cfv.*,
cfv.ofullname vofullname,
case when cfv.ofullname <> NVL(cfv.nfullname,cfv.ofullname) then cfv.nfullname else null end vnfullname,
cfv.oaddress voaddress,
case when cfv.oaddress <> NVL(cfv.naddress,cfv.oaddress) then cfv.naddress else null end vnaddress,
cfv.oidcode voidcode,
case when cfv.oidcode <> NVL(cfv.nidcode,cfv.oidcode) then cfv.nidcode else null end vnidcode,
cfv.oiddate voiddate,
case when cfv.oiddate <> NVL(cfv.niddate,cfv.oiddate) then cfv.niddate else null end vniddate,
cfv.oidexpired voidexpired,
case when cfv.oidexpired <> NVL(cfv.nidexpired,cfv.oidexpired) then cfv.nidexpired else null end vnidexpired,
cfv.oidplace voidplace,
case when cfv.oidplace <> nvl(cfv.nidplace,cfv.oidplace) then cfv.nidplace else null end vnidplace,
cfv.otradingcode votradingcode,
case when cfv.otradingcode <> nvl(cfv.ntradingcode,cfv.otradingcode) then cfv.ntradingcode else null end vntradingcode,
cfv.otradingcodedt votradingcodedt,
case when cfv.otradingcodedt <> nvl(cfv.ntradingcodedt,cfv.otradingcodedt) then cfv.ntradingcodedt else null end vntradingcodedt,
cfv.ocountry vocountry,
case when cfv.ocountry <> nvl(cfv.ncountry,cfv.ocountry) then cfv.ncountry else null end vncountry
from cfvsdlog cfv, cfmast cf where cfv.custid = cf.custid and confirmtxdate is null and confirmtxnum is null and cfv.deltd <>''Y''', 'CFMAST', 'frm', '', '0018', 0, 50, 'N', 30, '', 'Y', 'T', 'CUSTODYCD', 'N', '', 'CUSTID');COMMIT;