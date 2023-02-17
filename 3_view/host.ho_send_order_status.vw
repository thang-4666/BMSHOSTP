SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW HO_SEND_ORDER_STATUS
(BORS, FIRM, ORDERID, CODEID, SYMBOL, 
 QUOTEPRICE, ORDERQTTY, CUSTODYCD, PRICETYPE, VIA, 
 SENDNUM, ORDER_STATUS)
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
                     , a.SENDNUM
                     , case when  not (

                               (   tt.sysvalue <> 'P' and c.pricetype in ('ATO','LO')
                                 AND (pck_hogw.fn_caculate_hose_time  > (SELECT SYSVALUE FROM ORDERSYS WHERE SYSNAME='QUEUETIMEFR') )
                                 AND (pck_hogw.fn_caculate_hose_time  < (SELECT SYSVALUE FROM ORDERSYS WHERE SYSNAME='QUEUETIMETO') )
                                 And ((select Count(*) from ho_1i) < 300) -- Toi da 300 lenh
                               )
                             or
                               (tt.sysvalue ='P' and c.pricetype in ('LO','ATO'))
                             or
                               ( tt.sysvalue ='O' and c.pricetype in ('LO'))
                             or
                               ( tt.sysvalue ='O'
                                 And c.pricetype in ('MP')
                                 AND (pck_hogw.fn_caculate_hose_time  >=to_char(mp.sysvalue) )
                                )
                             or
                               (tt.sysvalue ='A' and c.pricetype in ('ATC','LO'))
                            ) then 'Lenh dat sai phien'
                    when b.symbol not in (select trim(code) from ho_sec_info
                                 where NVL(SUSPENSION,'1') <>'S'
                                And NVL(delist,'1') <>'D'
                                and trim(stock_type)in ('1','3')
                                And NVL(halt_resume_flag,'1') not in ('H','A')
                                ) then 'Trang thai chung khoan khong hop le'
                    when (c.quoteprice > l.ceilingprice or c.quoteprice < l.floorprice) then 'Sai gia tran san'
                    when (select sysvalue from ordersys where sysname ='HOSEGWSTATUS') <> 0 then 'GW chua ket noi'
                    else 'Cho boc lenh'
                    end order_status
               FROM ood a,
                    sbsecurities b,
                    odmast c,
                    securities_info l,
                    ordersys s,
                    ordersys tt,
                    ordersys mp
              WHERE     a.codeid = b.codeid
                AND a.orgorderid = c.orderid
                AND b.codeid = l.codeid
                AND c.orstatus = '8'
                AND b.tradeplace = '001'
                AND s.sysname = 'FIRM'
                AND a.oodstatus = 'N'
                AND A.deltd <> 'Y'
                AND c.matchtype = 'N'
                AND tt.sysname ='CONTROLCODE'
                and mp.sysname ='TIMESTAMPO'
                AND c.EXECTYPE <> 'CB' AND c.EXECTYPE <> 'CS'
                AND b.SECTYPE <>'006'
            ORDER BY  C.LAST_CHANGE
/
