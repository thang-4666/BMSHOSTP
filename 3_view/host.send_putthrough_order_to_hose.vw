SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW SEND_PUTTHROUGH_ORDER_TO_HOSE
(BORS, FIRM, TRADERID, ORDERID, CODEID, 
 SYMBOL, QUOTEPRICE, ORDERQTTY, BCUSTODIAN, SCUSTODIAN, 
 BCLIENTID, SCLIENTID, BUYORDERID, SENDNUM, ODDLOT, 
 TRADELOT)
BEQUEATH DEFINER
AS 
SELECT
    a.bors,
    s.sysvalue firm,
    C.TRADERID,
    a.orgorderid orderid,
    a.codeid,
    a.symbol,
    c.quoteprice / l.tradeunit quoteprice,
    c.orderqtty,
    SUBSTR (c.clientid, 4, 1) bcustodian,
    SUBSTR (a.custodycd, 4, 1) scustodian,
    c.clientid bclientid,
    a.custodycd sclientid,
    aa.orgorderid BUYORDERID,
    A.SENDNUM SENDNUM,
    Case when c.orderqtty < l.tradelot THEN 'Y' else 'N' end oddlot,     --ThangPV chinh sua lo le HSX 05-12-2022
    l.tradelot              --ThangPV chinh sua lo le HSX 30-05-2022 ROC 1.3
FROM
    ood a,
    ood aa,
    sbsecurities b,
    odmast c,
    odmast cc,
    securities_info l,
    ordersys s
WHERE
    a.codeid = b.codeid
    AND a.orgorderid = c.orderid
    And b.tradeplace = '001'
    AND b.codeid = l.codeid
    AND c.quoteprice <= l.ceilingprice
    AND c.quoteprice >= l.floorprice
    and cc.orderid=aa.orgorderid
    AND NVL(c.ptdeal,'xx')=nvl(cc.ptdeal,'yy')
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
    AND c.matchtype = 'P'
    AND cc.matchtype = 'P'
    AND s.sysname = 'FIRM'
    AND A.symbol in (Select trim(code)
                   From ho_sec_info
                   Where NVL(SUSPENSION,'1') <>'S'
                    And NVL(delist,'1') <>'D'
                    --LoLeHSX
                    --And NVL(halt_resume_flag,'1') not in ('H','P')
                    And ((NVL(halt_resume_flag,'1') not in ('H','P') AND c.orderqtty >= l.tradelot)
                       OR(NVL(Odd_Lot_Halt_Resume_Flag,'1') not in ('H','P') AND c.orderqtty < l.tradelot)
                       )
                    --End LoLeHSX
                    )
/
