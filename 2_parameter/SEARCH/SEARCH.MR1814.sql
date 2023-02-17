SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('MR1814','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('MR1814', 'Danh sách tiểu khoản chờ thu hồi hạn mức margin', 'General view of allocated to account', 'select cf.custid , cf.fullname, cf.custodycd,
nvl(AF.mrcrlimitmax,0) mrcrlimitmax, AF.acctno,
AFT.TYPENAME,aft.mnemonic,
nvl(AF.mrcrlimitmax,0) avlmrlimit
from cfmast cf, afmast af,   aftype aft
where cf.custid = af.custid
and nvl(AF.mrcrlimitmax,0) > 0
AND af.actype = aft.actype', 'MRTYPE', 'frmSATLID', 'custid', '1814', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;