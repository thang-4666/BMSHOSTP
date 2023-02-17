SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW CRM_SEC_VIEW
(SYMBOL, TRADEPLACE, FULLNAME, CODEID, SECTYPE, 
 BASICPRICE, CEILINGPRICE, FLOORPRICE, TRADINGDATE)
BEQUEATH DEFINER
AS 
select sb.symbol,decode(sb.tradeplace,'001','HOSE','002','HASTC','OTC') tradeplace,
i.fullname , s.codeid,sb.sectype,s.basicprice,s.ceilingprice,s.floorprice, trunc(sysdate) tradingdate
from sbsecurities sb, ISSUERS i, securities_info s
where sb.issuerid=i.issuerid
and sb.codeid=s.codeid
/
