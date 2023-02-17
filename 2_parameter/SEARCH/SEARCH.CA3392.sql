SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('CA3392','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('CA3392', 'Chuyển nhượng quyền mua trong nội bộ công ty', 'Transfer', 'select catrf.autoid refid, cfcr.custodycd custodycdcr, SUBSTR(catrf.optseacctnocr,1,10) ACCTNOCR, cfdr.custodycd custodycddr,SUBSTR(catrf.optseacctnodr,1,10) ACCTNODR , catrf.AMT QTTY,catrf.camastid,sb.symbol ISSNAME
,sb.symbol,ca.optcodeid codeid, cfcr.fullname fullnamecr, cfdr.fullname fullnamedr,cdcontenT status,CFCR.IDDATE IDDATECR,CFCR.IDCODE IDCODECR,CFCR.ADDRESS ADDRESSCR,CFCR.IDPLACE IDPLACECR,
CFDR.IDDATE IDDATEDR,CFDR.IDCODE IDCODEDR,CFDR.ADDRESS ADDRESSDR,CFDR.IDPLACE IDPLACEDR,
ca.codeid orgcodeid,
cas.autoid,nvl(ca.tocodeid,ca.codeid) tocodeid,
sb_org.symbol symbol_org, ca.isincode
from catransfer catrf ,sbsecurities sb, afmast afcr, cfmast cfcr , afmast afdr, cfmast cfdr,camast ca, allcode al1, caschd cas,
caschd car, sbsecurities sb_org
where catrf.camastid=ca.camastid
and SUBSTR(catrf.optseacctnocr,1,10)=afcr.acctno and afcr.custid =cfcr.custid
and SUBSTR(catrf.optseacctnodr,1,10)=afdr.acctno and afdr.custid =cfdr.custid
and al1.cdtype =''CA'' and al1.cdname=''CASTATUS'' and al1.cdval = ca.status
and sb.codeid = nvl(ca.tocodeid,ca.codeid )and ca.status in(''M'',''V'')
and cas.camastid = ca.camastid  and car.pbalance >= catrf.AMT
AND catrf.status = ''N''
AND cas.autoid= catrf.caschdid
and car.autoid= catrf.rcaschdid and car.deltd=''N''
and ca.codeid=sb_org.codeid', 'CAMAST', '', '', '3392', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;