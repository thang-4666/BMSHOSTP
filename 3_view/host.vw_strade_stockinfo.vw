SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_STRADE_STOCKINFO
(CODEID, FULLNAME, SYMBOL, TRADELOT, TRADEUNIT, 
 OPENPRICE, CEILINGPRICE, FLOORPRICE, BASICPRICE, CURRPRICE, 
 MARGINPRICE, HALT, TRADEPLACE)
BEQUEATH DEFINER
AS 
SELECT      SEC.CODEID, ISS.FULLNAME, SEC.SYMBOL,SEC.TRADELOT,SEC.TRADEUNIT, SEC.OPENPRICE, SEC.CEILINGPRICE, SEC.FLOORPRICE,SEC.BASICPRICE,SEC.CURRPRICE,SEC.MARGINPRICE,
             SBSEC.HALT, SBSEC.TRADEPLACE
FROM        ISSUERS ISS, SECURITIES_INFO SEC, SBSECURITIES SBSEC
WHERE       ISS.ISSUERID = SBSEC.ISSUERID
            AND SBSEC.CODEID = SEC.CODEID
            and SBSEC.SECTYPE in ('001','008')
/
