SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW SEND_ORDER_TO_HA
(BORS, ORDERID, CODEID, SYMBOL, PRICETYPE, 
 QUOTEPRICE, LIMITPRICE, ORDERQTTY, CUSTODYCD, QUOTEQTTY, 
 SENDNUM)
BEQUEATH DEFINER
AS 
SELECT
    a.bors,
    a.orgorderid orderid,
    a.codeid,
    a.symbol,
    C.pricetype,
    c.quoteprice quoteprice,
    c.limitprice,
    c.orderqtty,
    a.custodycd,
    c.QUOTEQTTY,
    A.SENDNUM
FROM
    ood a,
    odmast c,
    sbsecurities b,
    securities_info l,
    ordersys_ha s,
    hasecurity_req hr,
     HA_BRD hb
WHERE
    a.codeid = b.codeid
    AND b.codeid = l.codeid
    AND a.orgorderid = c.orderid
    AND c.quoteprice <= l.ceilingprice
    AND c.quoteprice >= l.floorprice
    and b.tradeplace in ('002','005')
    AND a.oodstatus = 'N'
    AND A.deltd <> 'Y'
    AND c.orstatus ='8'
    AND c.matchtype = 'N'
    AND c.EXECTYPE in ( 'NB','NS','MS')
    AND hr.symbol =a.symbol
    and s.sysname ='FIRM'
    AND HR.SECURITYTRADINGSTATUS in ('17','24','25','26','1','27','28')
    AND hb.BRD_CODE = hr.tradingsessionsubid
                --begin HNX_update |iss 1199
                --ma <> 1, 27 theo co bang
                AND( (HR.SECURITYTRADINGSTATUS in ('17','24','25','26','28') AND hb.TRADSESSTATUS ='1')
                    OR    --ma = 1, 27 theo co bang va co ma
                    (HR.SECURITYTRADINGSTATUS in ('1','27')
                    AND hb.TRADSESSTATUS ='1'
                    AND hr.TRADSESSTATUS ='1'
                    AND hb.TRADINGSESSIONID= hr.TradingSessionID )
                    )
                --end  HNX_update |iss 1199
                 AND
                    (
                        (hb.TRADINGSESSIONID in ('CONT','CONTUP') and c.pricetype in ('LO','MTL','MAK','MOK'))
                          or
                          ( hb.TRADINGSESSIONID = 'CLOSE' and c.pricetype in ('ATC','LO'))
                          or
                          ( hb.TRADINGSESSIONID = 'CLOSE_BL' and c.pricetype in ('ATC','LO'))
                          or
                          ( hb.TRADINGSESSIONID = 'PCLOSE' and c.pricetype in ('PLO'))

                     )

ORDER BY c.last_change
/
