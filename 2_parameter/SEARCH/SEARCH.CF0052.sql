SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('CF0052','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('CF0052', 'Danh sach khach hang theo careby', ' export securities basket', 'Select CF.BRID, custid,custodycd,fullname, TO_CHAR(cf.dateofbirth,''DD/MM/YYYY'') dateofbirth,idcode, TO_CHAR(cf.iddate,''DD/MM/YYYY'') iddate,idplace,address,phone,mobile,email,  cf.careby carebyid , tl.grpname carebyname,cf.actype,
cf.idtype,tradingcode,TO_CHAR(cf.tradingcodedt,''DD/MM/YYYY'') tradingcodedt,VAT,AL.CDCONTENT SEX ,
 CF.MOBILESMS, CF.MNEMONIC,  CF.FAX,   CF.PROVINCE, CF.COUNTRY, CF.CLASS,
 CF.CUSTTYPE, CF.custatcom ISDEPO
, CF.CAREBY, CF.PIN,    CF.OPNDATE
, CF.tradeonline ISONLINE, CF.tradetelephone, CF.STATUS, A0.CDCONTENT CFSTATUS,
BR.BRNAME, CFT.TYPENAME CFTYPE,cf.TAXCODE,CF.WHTAX
from cfmast cf , tlgroups tl,ALLCODE AL, ALLCODE A0, BRGRP BR,CFTYPE CFT
where cf.careby = tl.grpid
and cf.sex = al.cdval
and al.cdname=''SEX''
and al.cdtype=''CF''
AND A0.CDTYPE=''CF'' AND A0.CDNAME=''STATUS'' AND A0.CDVAL=CF.STATUS
AND CF.BRID=BR.BRID
AND CF.ACTYPE=CFT.ACTYPE', 'AFMAST', '', '', '', NULL, 100, 'N', 30, '', 'Y', 'T', '', 'N', '', 'CUSTID');COMMIT;