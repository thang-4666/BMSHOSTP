SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('CUSTREGIST_OL','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('CUSTREGIST_OL', 'Danh sách khách hàng đăng cý HĐ qua online', 'Customer register online', 'Select Autoid,a.CDcontent
,idcode,customername,customerbirth,address,privatephone,
mobile,fax,email,smsphonenumber
from registeronline re , allcode a
where re.customertype =a.cdval
And a.CDNAME=''CUSTTYPE'' and cdtype =''CF''', 'CFLINK', 'frmCFMAST', '', '', NULL, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;