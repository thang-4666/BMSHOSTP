SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW CRM_CF_OTC
(CUSTID, ACCTNO, CUSTODYCD, STATUS, SHORTNAME, 
 FULLNAME, IDCODE, DATEOFBIRTH, IDPLACE, SYMBOL, 
 TRADE, MORTAGE, BLOCKED, SECURED, SECURITIES)
BEQUEATH DEFINER
AS 
select af.custid, af.acctno, cf.custodycd, af.status,
		cf.shortname, cf.fullname, cf.idcode, cf.dateofbirth, cf.idplace, 
		sec.symbol, se.trade, se.mortage, se.blocked, se.secured, iu.fullname securities
from afmast af, cfmast cf, securities_info sec, semast se, issuers iu, sbsecurities sb
where cf.custid = af.custid
and af.acctno = se.afacctno
and sec.codeid = se.codeid
and sec.symbol like '%_UT%'
and sb.codeid = se.codeid
and se.codeid = substr(iu.issuerid,5,6)
and sb.tradeplace = '003'
and (se.trade + se.mortage + se.blocked + se.secured) <>0
order by af.acctno
/
