SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_ISSUER_MEMBER
(CUSTID, CUSTODYCD, FULLNAME, COMPANYNAME, CODEID, 
 SYMBOL, CDCONTENT)
BEQUEATH DEFINER
AS 
Select cf.custid, cf.custodycd, cf.fullname, ie.fullname companyname, sb.codeid, sb.symbol, a1.cdcontent
from sbsecurities sb, issuers ie, ISSUER_MEMBER im, ALLCODE A1, cfmast cf
where sb.issuerid = ie.issuerid
      and im.issuerid = ie.issuerid
      and a1.cdtype = 'SA'
      and a1.cdname ='ROLECD'
      and sb.sectype <> '004'
      and a1.cdval = im.rolecd
      and cf.custid = im.custid
/
