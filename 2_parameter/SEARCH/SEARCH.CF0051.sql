SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('CF0051','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('CF0051', 'Danh sách tiểu khoản theo loại hình hợp đồng', ' margin customer list', 'Select CF.CUSTID, cf.custodycd,af.acctno,cf.fullname,cf.dateofbirth,cf.idcode,TO_CHAR(cf.iddate,''DD/MM/YYYY'') iddate,cf.idplace,cf.address,cf.phone,cf.mobile,cf.email,cf.tradetelephone,
    tradeonline,af.mrcrlimitmax,cf.vat,
    cf.careby carebyid , tl.grpname carebyname , aft.actype ,aft.typename,
    cf.custatcom, af.corebank, af.bankname, af.bankacctno, af.status,cf.idtype
from cfmast cf ,afmast af , aftype aft,  tlgroups tl
where cf.careby = tl.grpid
and af.custid = cf.custid and af.actype =aft.actype', 'AFMAST', '', '', '', NULL, 100, 'N', 30, '', 'Y', 'T', '', 'N', '', 'CUSTID');COMMIT;