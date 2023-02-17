SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW SEND_PUTTHROUGH_ORDER_TO_HA
(BORS, FIRM, ORDERID, CODEID, SYMBOL, 
 QUOTEPRICE, ORDERQTTY, BCUSTODIAN, SCUSTODIAN, BCLIENTID, 
 SCLIENTID, ADVIDREF, BORDERID, SENDNUM)
BEQUEATH DEFINER
AS 
SELECT
    a.bors,
    s.sysvalue firm,
    a.orgorderid orderid,
    a.codeid,
    a.symbol,
    c.quoteprice,
    c.orderqtty,
    SUBSTR (c.clientid, 4, 1) bcustodian,
    SUBSTR (a.custodycd, 4, 1) scustodian,
    c.clientid bclientid,
    a.custodycd sclientid,
    c.advidref advidref,
    aa.orgorderid borderid,
    a.sendnum

FROM
    ood a,
    ood aa,
    sbsecurities b,
    odmast c,
    odmast cc,
    securities_info l,
    ordersys_ha s
WHERE
    a.codeid = b.codeid
    AND a.orgorderid = c.orderid
    And b.tradeplace IN('002','005')
    AND b.codeid = l.codeid
    AND c.quoteprice <= l.ceilingprice
    AND c.quoteprice >= l.floorprice
    and cc.orderid=aa.orgorderid
    AND NVL(c.ptdeal,'xx')=nvl(cc.ptdeal,'yy')
    AND c.matchtype = 'P'
    AND cc.matchtype = 'P'
    AND s.sysname = 'FIRM'
    and c.clientid=aa.custodycd
    and a.qtty=aa.qtty
    and a.price=aa.price
    and a.bors<> aa.bors
    AND a.bors = 'S'
    AND a.oodstatus = 'N'
    AND aa.oodstatus  ='N'
    AND c.orstatus NOT IN ('3', '0', '6','7')
    AND c.deltd <> 'Y'
    AND cc.deltd <> 'Y'
    AND A.symbol IN (SELECT SYMBOL
                     FROM hasecurity_req HR
                     WHERE HR.SECURITYTRADINGSTATUS in ('17','24','25','26','1','27','28'))
/
