SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_CHECK_TRADING_RESULT
(TRADING_DATE, ACCTNO, BORS, SEC_CODE, PRICE, 
 QTTY, LECH, TRADEPLACE, TRADEPLACEDESC)
BEQUEATH DEFINER
AS 
select m.TRADING_DATE,m.ACCTNO,m.BORS,m.SEC_CODE,m.PRICE,m.QTTY,m.LECH,m.TRADEPLACE, a1.CDCONTENT TRADEPLACEDESC
from
(
    -- SAN KHOP
    select a.trading_date,a.acctno,a.bors,a.sec_code,a.price,a.qtty ,
        'SAN KHOP' LECH,b.tradeplace
    from  -------- trading_result minus IOD
    (
        select trading_date , acctno, bors, sec_code, price,qtty
        FROM
        ( -- trading_result sell\
            -- HOSE SELL
            select h.trading_date,h.s_account_no acctno,'S' BORS,
                h.sec_code,decode(h.floor_code,'02',h.price,h.price*1000)
                price,sum(h.quantity) qtty
             from trading_result h
            where trading_date=(SELECT   TO_DATE (varvalue,'DD/MM/YYYY')
                               FROM  sysvar WHERE   varname = 'CURRDATE' AND grname = 'SYSTEM')
                --and h.s_account_no like '002%'
                AND (EXISTS (SELECT   1
                                FROM   cfmast
                               WHERE   custodycd =h.s_account_no)
                         OR h.s_account_no LIKE '086%')
                and nvl(h.s_code_trade,'086') = '086'
            group by
                h.trading_date,h.s_account_no,h.sec_code,
                decode(h.floor_code,'02',h.price,h.price*1000)
            union all  -- trading_result buy
            -- HOSE BUY
            select h.trading_date,h.b_account_no acctno,'B' BORS,
                h.sec_code,decode(h.floor_code,'02',h.price,h.price*1000)
                price,sum(h.quantity) qtty
            from trading_result h
            where trading_date=(SELECT   TO_DATE (varvalue,'DD/MM/YYYY')
                               FROM  sysvar WHERE   varname = 'CURRDATE' AND grname = 'SYSTEM')
                --and h.b_account_no like '086%'
                AND (EXISTS (SELECT   1
                                FROM   cfmast
                               WHERE   custodycd =h.b_account_no)
                         OR h.b_account_no LIKE '086%')
                and nvl(h.b_code_trade,'086') = '086'

            group BY h.trading_date,h.b_account_no,h.sec_code,
                decode(h.floor_code,'02',h.price,h.price*1000)
            union all --vw_sts_orders_hnx_upcom sell
            -- HNX SELL
             SELECT   h.order_date trading_date,
                    h.account_no acctno,
                    'S' bors,
                    substr(h.order_no,1,3) sec_code,
                    h.order_price price,
                    SUM (h.order_qtty) qtty
             FROM   vw_sts_orders_hnx_upcom h
             where (h.norc = 5 OR (h.norc= 7 AND H.STATUS=4 )) --and h.oorb=1 and account_no like '002C%'
                and   h.order_date =(SELECT   TO_DATE (varvalue,'DD/MM/YYYY')
                               FROM  sysvar WHERE   varname = 'CURRDATE' AND grname = 'SYSTEM')
                      AND h.member_id = 48 /*(   h.account_no LIKE '086%'
                             OR
                             (  EXISTS (SELECT   1
                                      FROM   cfmast
                                      WHERE   custodycd =h.account_no)
                              AND EXISTS (SELECT 1 FROM OOD WHERE CUSTODYCD=H.ACCOUNT_NO)

                              )

                         )*/
             GROUP BY   h.order_date,
                    h.account_no ,
                    substr(h.order_no,1,3),
                    h.order_price
            Union all  --vw_sts_orders_hnx_upcom buy
            -- HNX BUY
            SELECT   h.order_date trading_date,
                    h.co_account_no acctno,
                    'B' bors,
                    substr(h.order_no,1,3) sec_code,
                    h.order_price price,
                    SUM (h.order_qtty) qtty
             FROM   vw_sts_orders_hnx_upcom h
             where (h.norc = 5 OR (h.norc= 7 AND H.STATUS=4 )) --and h.oorb=1 and co_account_no like '002C%'
                   and   h.order_date =(SELECT   TO_DATE (varvalue,'DD/MM/YYYY')
                               FROM  sysvar WHERE   varname = 'CURRDATE' AND grname = 'SYSTEM')
                    AND h.co_member_id = 48 /*(     h.co_account_no LIKE '086%'
                            OR
                              ( EXISTS(SELECT   1
                                       FROM   cfmast
                                       WHERE   custodycd =h.co_account_no)
                                AND EXISTS
                                (SELECT 1 FROM OOD WHERE CUSTODYCD=H.co_account_no)
                               )

                         )*/
             GROUP BY   h.order_date,
                    h.co_account_no ,
                    substr(h.order_no,1,3),
                    h.order_price
        )
        MINUS
        -- THONG TIN KHOP LENH TRONG FLEX
        select  i.txdate trading_date,i.custodycd
            acctno,i.bors,to_char(i.symbol) sec_code,
            i.matchprice price, sum(i.matchqtty) qtty
        from iod i
            where i.txdate = (SELECT   TO_DATE (varvalue,'DD/MM/YYYY')
                           FROM  sysvar WHERE   varname = 'CURRDATE' AND grname = 'SYSTEM')
            and i.deltd <>'Y'
        group by i.txdate,i.custodycd,i.bors,i.symbol,
            i.matchprice
    ) a,
    sbsecurities b
    where a.sec_code=b.symbol
    ----- FLEX KHOP -----------
    UNION ALL -------- IOD minus trading_result
    select a.trading_date,a.acctno,a.bors,a.sec_code,a.price,a.qtty,
        'FLEX KHOP' , b.tradeplace LECH
    from
    (
        -- LENH KHOP TRONG FLEX
        select  i.txdate trading_date,i.custodycd
            acctno,i.bors,to_char(i.symbol) sec_code,
            i.matchprice price, sum(i.matchqtty) qtty
        from iod i
            where i.txdate = (SELECT   TO_DATE (varvalue,'DD/MM/YYYY')
                           FROM  sysvar WHERE   varname = 'CURRDATE' AND grname = 'SYSTEM')
            and i.deltd <>'Y'
        group by i.txdate,i.custodycd ,i.bors,i.symbol, i.matchprice

        MINUS

        select trading_date , acctno, bors, sec_code, price,qtty
        FROM
        (
            -- HOSE SELL
            select h.trading_date,h.s_account_no acctno,'S' BORS,h.sec_code
                ,decode(h.floor_code,'02',h.price,h.price*1000)
                price,sum(h.quantity) qtty
             from trading_result h
            where trading_date=(SELECT   TO_DATE (varvalue,'DD/MM/YYYY')
                               FROM  sysvar WHERE   varname = 'CURRDATE' AND grname = 'SYSTEM')
                --and h.s_account_no like '086%'
                AND (EXISTS (SELECT   1
                                FROM   cfmast
                               WHERE   custodycd =h.s_account_no)
                         OR h.s_account_no LIKE '086%')
                and nvl(h.s_code_trade,'086') = '086'
            group BY h.trading_date,h.s_account_no,h.sec_code,
                decode(h.floor_code,'02',h.price,h.price*1000)
            union ALL
            -- HOSE BUY
            select h.trading_date,h.b_account_no acctno,'B' BORS,h.sec_code
                ,decode(h.floor_code,'02',h.price,h.price*1000)
                price,sum(h.quantity) qtty
             from trading_result h
            where trading_date=(SELECT   TO_DATE (varvalue,'DD/MM/YYYY')
                               FROM  sysvar WHERE   varname = 'CURRDATE' AND grname = 'SYSTEM')
                --and h.b_account_no like '086%'
                AND (EXISTS (SELECT   1
                                FROM   cfmast
                               WHERE   custodycd =h.b_account_no)
                         OR h.s_account_no LIKE '086%')
                and nvl(h.b_code_trade,'086') = '086'
            group BY h.trading_date,h.b_account_no,h.sec_code,
                decode(h.floor_code,'02',h.price,h.price*1000)
            union all --vw_sts_orders_hnx_upcom
            -- HNX SELL
            SELECT   h.order_date trading_date,
                h.account_no acctno,
                'S' bors,
                substr(h.order_no,1,3) sec_code,
                h.order_price price,
                SUM (h.order_qtty) qtty
             FROM   vw_sts_orders_hnx_upcom h
             where (h.norc = 5 OR (h.norc= 7 AND H.STATUS=4 ))-- and h.oorb=1 and account_no like '002C%'
                and   h.order_date =(SELECT   TO_DATE (varvalue,'DD/MM/YYYY')
                               FROM  sysvar WHERE   varname = 'CURRDATE' AND grname = 'SYSTEM')
                      AND h.member_id = 48  /*(   h.account_no LIKE '086%'
                           OR
                             (  EXISTS
                                (SELECT   1
                                 FROM   cfmast
                                WHERE   custodycd =h.account_no)
                                AND EXISTS
                                (SELECT 1 FROM OOD WHERE CUSTODYCD=H.account_no)
                              )
                         )*/
             GROUP BY   h.order_date,
                    h.account_no ,
                    substr(h.order_no,1,3),
                    h.order_price
            Union ALL
            -- HNX BUY
            SELECT   h.order_date trading_date,
                    h.co_account_no acctno,
                    'B' bors,
                    substr(h.order_no,1,3) sec_code,
                    h.order_price price,
                    SUM (h.order_qtty) qtty
             FROM   vw_sts_orders_hnx_upcom h
             where (h.norc = 5 OR (h.norc= 7 AND H.STATUS=4 )) --and h.oorb=1 and co_account_no like '002C%'
                   and   h.order_date =(SELECT   TO_DATE (varvalue,'DD/MM/YYYY')
                               FROM  sysvar WHERE   varname = 'CURRDATE' AND grname = 'SYSTEM')
                    AND h.co_member_id = 48 /*( h.co_account_no LIKE '086%'
                          OR (EXISTS
                             (SELECT   1
                                FROM   cfmast
                               WHERE   custodycd =h.co_account_no)
                           AND EXISTS
                                (SELECT 1 FROM OOD WHERE CUSTODYCD=H.co_account_no))
                         )*/
             GROUP BY   h.order_date,
                    h.co_account_no ,
                    substr(h.order_no,1,3),
                    h.order_price
        )
    ) a,
    sbsecurities b
    where a.sec_code=b.symbol
)m, (select * from allcode where cdname ='TRADEPLACE' and cdtype = 'OD') a1
where m.tradeplace = a1.cdval and m.qtty <> 0
ORDER BY m.ACCTNO,m.SEC_CODE
/
