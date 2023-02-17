SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('CFREVIEWDTL','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('CFREVIEWDTL', 'Chỉ tiêu xếp hạng khách hàng', 'Customer rank indicators', 'select dtl.autoid, dtl.cfrevid, dtl.cftype,
cft.typename,  dtl.tradevalue, dtl.nav, dtl.feeamt,
dtl.finrevenue, dtl.numoverdeal, dtl.calldays,dtl.NAVCURR,dtl.NUMKEEPCF,dtl.TYPEREVIEW
from cfreview hdr , cfreviewdtl dtl , cftype cft
where  hdr.autoid=dtl.cfrevid
    and dtl.cftype=cft.actype
    and dtl.cfrevid=''<$KEYVAL>''', 'SA.CFREVIEWDTL', 'frmTDTYPE', '', '', 0, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;