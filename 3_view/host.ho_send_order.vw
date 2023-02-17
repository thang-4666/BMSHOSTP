SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW HO_SEND_ORDER
(BORS, FIRM, ORDERID, CODEID, SYMBOL, 
 QUOTEPRICE, ORDERQTTY, CUSTODYCD, PRICETYPE, VIA, 
 SENDNUM, ODDLOT, TRADELOT)
BEQUEATH DEFINER
AS 
SELECT a.bors, s.sysvalue firm, a.orgorderid orderid, a.codeid, a.symbol,
                    CASE WHEN c.pricetype='ATO' THEN 'ATO'
                          WHEN c.pricetype='ATC' THEN 'ATC'
                          WHEN c.pricetype='MP' THEN 'MP'
                           ELSE TO_CHAR(c.quoteprice / l.tradeunit)
                     END  QUOTEPRICE,
                    c.orderqtty,
                    a.custodycd,
                    c.pricetype,
                     c.via--, c.ordertime
                     , a.SENDNUM,
                     Case when c.orderqtty < l.tradelot THEN 'Y' else 'N' end oddlot,
                     l.tradelot     --ThangPV chinh sua lo le HSX 30-05-2022 ROC 1.3
               FROM ood a,
                    sbsecurities b,
                    odmast c,
                    securities_info l,
                    ordersys s,
                    ordersys tt,
                    ordersys mp,
                    ho_sec_info h,
                    ordersys lot
              WHERE    a.codeid = B.codeid
                     AND b.codeid = l.codeid
               AND  a.orgorderid = c.orderid
               AND c.quoteprice <= l.ceilingprice
                AND c.quoteprice >= l.floorprice
                AND b.tradeplace = '001'
               AND a.oodstatus = 'N'
               AND A.deltd <> 'Y'
                AND c.orstatus = '8'
                 AND c.matchtype = 'N'
                  AND c.EXECTYPE in ( 'NB','NS','MS')
                AND s.sysname = 'FIRM'
                AND tt.sysname ='CONTROLCODE'
                and mp.sysname ='TIMESTAMPO'
                AND lot.sysname='CONTROLCODE_ODD_LOT'
                AND L.symbol= H.code
                and NVL(H.SUSPENSION,'1') <>'S'
                And NVL(H.delist,'1') <>'D'
                and trim(H.stock_type)in ('1','3','4')
                And NVL(H.halt_resume_flag,'1') not in ('H','A')
                --and h.trading_date=trunc(sysdate)
                AND (

                      ( tt.sysvalue ='O' and c.pricetype in ('LO') AND  c.orderqtty  >= l.tradelot)--ThangPV chinh sua lo le HSX 27-04-2022
                      or
                       (tt.sysvalue ='P' and c.pricetype in ('LO','ATO') AND  c.orderqtty  >= l.tradelot)--ThangPV chinh sua lo le HSX 27-04-2022
                      or
                       ( tt.sysvalue ='O'
                         And c.pricetype in ('MP')
                         AND (pck_hogw.fn_caculate_hose_time  >=to_char(mp.sysvalue) AND  c.orderqtty  >= l.tradelot)--ThangPV chinh sua lo le HSX 27-04-2022
                        )
                     or
                       (tt.sysvalue ='A' and c.pricetype in ('ATC','LO') and c.orderqtty  >= l.tradelot) --ThangPV chinh sua lo le HSX 27-04-2022
                     OR (   tt.sysvalue not in( 'P','O','A') and c.pricetype in ('ATO','LO')
                         AND (pck_hogw.fn_caculate_hose_time  > (SELECT SYSVALUE FROM ORDERSYS WHERE SYSNAME='QUEUETIMEFR') )
                         AND (pck_hogw.fn_caculate_hose_time  < (SELECT SYSVALUE FROM ORDERSYS WHERE SYSNAME='QUEUETIMETO') )
                         And ((select Count(*) from ho_1i) < 300) -- Toi da 300 lenh
                       )
                        OR(lot.sysvalue = 'E' AND c.pricetype ='LO' AND c.orderqtty< l.tradelot )--Phien lo le lenh LO ThangPV chinh sua lo le HSX 27-04-2022
                    )
                ORDER BY  C.LAST_CHANGE
/
