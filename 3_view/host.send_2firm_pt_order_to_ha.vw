SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW SEND_2FIRM_PT_ORDER_TO_HA
(BORS, FIRM, CONTRAFIRM, ORDERID, CODEID, 
 SYMBOL, QUOTEPRICE, ORDERQTTY, BCUSTODIAN, SCUSTODIAN, 
 BCLIENTID, SCLIENTID, ADVIDREF, SENDNUM)
BEQUEATH DEFINER
AS 
SELECT
    a.bors,
    s.sysvalue firm,
    c.contrafirm,
    a.orgorderid orderid,
    a.codeid,
    a.symbol,
    c.quoteprice  quoteprice,
    c.orderqtty,
    SUBSTR (c.clientid, 4, 1) bcustodian,
    SUBSTR (a.custodycd, 4, 1) scustodian,
    c.clientid bclientid,
    a.custodycd sclientid,
    c.advidref advidref,
    a.sendnum
FROM
    ood a,
    sbsecurities b,
    odmast c,
    securities_info l,
    ordersys_ha s,
    hasecurity_req hr
WHERE
    a.codeid = b.codeid
    AND b.codeid = l.codeid
    AND a.orgorderid = c.orderid
    AND b.tradeplace in ('002','005')
    AND a.bors = 'S'
    AND a.oodstatus ='N'
    AND c.quoteprice <= l.ceilingprice
    AND c.quoteprice >= l.floorprice
    and( LENGTH(TRIM(TRANSLATE (c.contrafirm, ' +-.0123456789',' '))) is null
         AND TO_NUMBER(c.contrafirm)<>TO_NUMBER(s.sysvalue)
        )
    AND c.orstatus NOT IN ('3', '0', '6','7')
    AND c.deltd <> 'Y'
    AND c.matchtype = 'P'
    AND s.sysname = 'FIRM'
    AND hr.symbol =a.symbol
    AND HR.SECURITYTRADINGSTATUS in ('17','24','25','26','1','27','28')
/
