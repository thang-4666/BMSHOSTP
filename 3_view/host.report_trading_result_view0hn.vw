SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW REPORT_TRADING_RESULT_VIEW0HN
(BRID, TRANS_DATE, STOCK_CODE, TRANS_TYPE_TEXT, TRANS_TYPE, 
 STOCK_QTTY, PRICE, ACCOUNT_NO, FEE_TYPE, FEE_RATE)
BEQUEATH DEFINER
AS 
select cf.brid brid, iod.txdate TRANS_DATE,iod.symbol  STOCK_CODE ,decode (iod.bors,'B','MUA','BAN') TRANS_TYPE_TEXT, decode (iod.bors,'B',2,1)  TRANS_TYPE
,sum(iod.matchqtty) STOCK_QTTY ,iod.matchprice PRICE,iod.custodycd ACCOUNT_NO ,4 FEE_TYPE, max(OD. FEE_RATE) FEE_RATE
from vw_iod_all iod,( SELECT MAX(OD.feeacr)*100/sum(iod.matchqtty*iod.matchprice) FEE_RATE,OD.ORDERID
FROM vw_odmast_all OD ,vw_iod_all IOD
WHERE OD.ORDERID = IOD.orgorderid
GROUP BY OD.ORDERID) od,cfmast cf
where od.orderid = iod.orgorderid
and iod.deltd <>'Y'
and iod.custodycd=cf.custodycd
and cf.brid like '00%'
group by iod.txdate,iod.custodycd,iod.symbol,iod.bors,iod.matchprice,iod.orgorderid,cf.brid
order by iod.txdate,iod.custodycd,iod.symbol,decode (iod.bors,'B',2,1) ,iod.matchprice
/
