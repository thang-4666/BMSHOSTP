SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_CHECKPRICE_EOD
(SYMBOL, BASICPRICE, FLOORPRICE, CEILINGPRICE, AVGPRICE, 
 NEWBASICPRICE, NEWFLOORPRICE, NEWCEILINGPRICE, NEWPRICE)
BEQUEATH DEFINER
AS 
SELECT S.SYMBOL, S.BASICPRICE,S.floorprice,S.ceilingprice
,S.AVGPRICE,S.NEWBASICPRICE,S.newfloorprice,S.newceilingprice,
 S.NEWPRICE
--H.trading_date,H.delist,H.suspension,H.halt_resume_flag
FROM SECURITIES_INFO S, ho_sec_info H
WHERE S.SYMBOL=H.CODE AND S.NEWPRICE='0'
AND  NVL(H.SUSPENSION,'1') <>'S'
                And NVL(H.delist,'1') <>'D'
                and trim(H.stock_type)in ('1','3')
                And NVL(H.halt_resume_flag,'1') not in ('H','A')

UNION ALL
-- HNX, UPCOM
SELECT S.SYMBOL, S.BASICPRICE,S.floorprice,S.ceilingprice,
S.AVGPRICE,S.NEWBASICPRICE,S.newfloorprice,S.newceilingprice,
 S.NEWPRICE
FROM SECURITIES_INFO S, hasecurity_req H
WHERE S.SYMBOL=H.SYMBOL AND S.NEWPRICE='0'
 AND H.SECURITYTRADINGSTATUS in ('17','24','25','26','1','27','28')
 and s.symbol not in('E1SSHN30')
/
