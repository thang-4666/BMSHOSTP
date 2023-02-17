SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW SEND_2FIRM_PT_ORDER_TO_HOSE
(BORS, FIRM, STRADERID, BTRADERID, CONTRAFIRM, 
 ORDERID, CODEID, SYMBOL, QUOTEPRICE, ORDERQTTY, 
 BCUSTODIAN, SCUSTODIAN, BCLIENTID, SCLIENTID, SENDNUM, 
 ODDLOT, TRADELOT)
BEQUEATH DEFINER
AS 
SELECT
    a.bors,
    s.sysvalue firm,
    t.sysvalue STRADERID,
    C.TRADERID BTRADERID,
    c.contrafirm,
    a.orgorderid orderid,
    a.codeid,
    a.symbol,
    c.quoteprice / l.tradeunit quoteprice,
    c.orderqtty,
    SUBSTR (c.clientid, 4, 1) bcustodian,
    SUBSTR (a.custodycd, 4, 1) scustodian,
    c.clientid bclientid,
    a.custodycd sclientid,
    A.SENDNUM,
    Case when c.orderqtty < l.tradelot THEN 'Y' else 'N' end oddlot, --ThangPV chinh sua lo le HSX 05-12-2022
    l.tradelot      --ThangPV chinh sua lo le HSX 30-05-2022 ROC 1.3
FROM ood a,
    sbsecurities b,
    odmast c,
    securities_info l,
    ordersys s,
    ordersys t
WHERE
    a.codeid = b.codeid
    AND b.codeid = l.codeid
    AND c.quoteprice <= l.ceilingprice
    AND c.quoteprice >= l.floorprice
    AND a.orgorderid = c.orderid
    AND a.bors = 'S'
    AND TO_NUMBER(c.contrafirm)<>TO_NUMBER(s.sysvalue)
    AND c.orstatus NOT IN ('3', '0', '6','7')
    AND b.tradeplace = '001'
    AND s.sysname = 'FIRM'
    AND t.sysname = 'BROKERID'
    AND a.oodstatus = 'N'
    AND c.deltd <> 'Y'
    AND c.matchtype = 'P'
    AND A.symbol in (select trim(code) from ho_sec_info
                 where NVL(SUSPENSION,'1') <>'S'
                And NVL(delist,'1') <>'D'
                --LoLeHSX
                --And NVL(halt_resume_flag,'1') not in ('H','P')
                And ((NVL(halt_resume_flag,'1') not in ('H','P') AND c.orderqtty >= l.tradelot )
                   OR(NVL(Odd_Lot_Halt_Resume_Flag,'1') not in ('H','P') AND c.orderqtty < l.tradelot)
                   )
                --End --LoLeHSX
                )
/
