SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_GL_STOCK_INFO
(SYMBOL, COMPANY_NAME, SECTYPEID, SECTYPENAME, PARVALUE, 
 TRADEPLACE, TRADEPLACENAME)
BEQUEATH DEFINER
AS 
select DISTINCT(sb.symbol),i.fullname,sb.sectype sectypeid , a.cdcontent sectypename,
  sb.parvalue, sb.tradeplace ,a1.cdcontent tradename
  from sbsecurities sb ,allcode a ,allcode a1 ,issuers i
  where sb.sectype = a.cdval(+)
  and nvl(a.cdname,'SECTYPE')='SECTYPE'
  and sb.tradeplace = a1.cdval
  and nvl(a1.cdname,'TRADEPLACE')='TRADEPLACE'
  and sb.issuerid = i.issuerid
/
