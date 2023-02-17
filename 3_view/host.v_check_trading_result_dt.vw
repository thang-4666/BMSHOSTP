SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_CHECK_TRADING_RESULT_DT
(CONFIRM_NO, TRADING_DATE, ACCTNO, BORS, SEC_CODE, 
 PRICE, QTTY, LECH, TRADEPLACE)
BEQUEATH DEFINER
AS 
select "CONFIRM_NO", "TRADING_DATE","ACCTNO","BORS","SEC_CODE","PRICE","QTTY","LECH","TRADEPLACE"
from
(-- SAN KHOP
    select a.confirm_no, a.trading_date,a.acctno,a.bors,a.sec_code,a.price,a.qtty ,
        'SAN KHOP' LECH,b.tradeplace
    from  -------- trading_result minus IOD
    (
        select confirm_no, trading_date , acctno, bors, sec_code, price,qtty
        FROM
        (-- HOSE SELL
            select h.confirm_no, h.trading_date,h.s_account_no acctno,'S' BORS,
                h.sec_code,decode(h.floor_code,'02',h.price,h.price*1000)
                price,sum(h.quantity) qtty
             from trading_result h
            where trading_date=(SELECT   TO_DATE (varvalue,'DD/MM/YYYY')
                               FROM  sysvar WHERE   varname = 'CURRDATE' AND grname = 'SYSTEM')
                AND (EXISTS (SELECT   1
                                FROM   cfmast
                               WHERE   custodycd =h.s_account_no)
                         OR h.s_account_no LIKE '086%')
                and nvl(h.s_code_trade,'086') = '086'
            group by
                h.confirm_no, h.trading_date,h.s_account_no,h.sec_code,
                decode(h.floor_code,'02',h.price,h.price*1000)
            union all
            -- HOSE BUY
            select h.confirm_no,  h.trading_date,h.b_account_no acctno,'B' BORS,
                h.sec_code,decode(h.floor_code,'02',h.price,h.price*1000)
                price,sum(h.quantity) qtty
            from trading_result h
            where trading_date=(SELECT   TO_DATE (varvalue,'DD/MM/YYYY')
                               FROM  sysvar WHERE   varname = 'CURRDATE' AND grname = 'SYSTEM')
                AND (EXISTS (SELECT   1
                                FROM   cfmast
                               WHERE   custodycd =h.b_account_no)
                         OR h.b_account_no LIKE '086%')
                and nvl(h.b_code_trade,'086') = '086'
            group BY h.confirm_no, h.trading_date,h.b_account_no,h.sec_code,
                decode(h.floor_code,'02',h.price,h.price*1000)
            union all
            -- HNX SELL
             SELECT   h.ORDER_CONFIRM_NO confirm_no, h.order_date trading_date,
                    h.account_no acctno,
                    'S' bors,
                    substr(h.order_no,1,3) sec_code,
                    h.order_price price,
                    SUM (h.order_qtty) qtty
             FROM   vw_sts_orders_hnx_upcom h
             where (h.norc = 5 OR (h.norc= 7 AND H.STATUS=4 ))
                and   h.order_date =(SELECT   TO_DATE (varvalue,'DD/MM/YYYY')
                               FROM  sysvar WHERE   varname = 'CURRDATE' AND grname = 'SYSTEM')
                      AND h.member_id = 48
             GROUP BY  h.ORDER_CONFIRM_NO,  h.order_date,
                    h.account_no ,
                    substr(h.order_no,1,3),
                    h.order_price
            Union all
            -- HNX BUY
            SELECT   h.ORDER_CONFIRM_NO confirm_no, h.order_date trading_date,
                    h.co_account_no acctno,
                    'B' bors,
                    substr(h.order_no,1,3) sec_code,
                    h.order_price price,
                    SUM (h.order_qtty) qtty
             FROM   vw_sts_orders_hnx_upcom h
             where (h.norc = 5 OR (h.norc= 7 AND H.STATUS=4 ))
                   and   h.order_date =(SELECT   TO_DATE (varvalue,'DD/MM/YYYY')
                               FROM  sysvar WHERE   varname = 'CURRDATE' AND grname = 'SYSTEM')
                    AND h.co_member_id = 48
             GROUP BY h.ORDER_CONFIRM_NO,   h.order_date,
                    h.co_account_no ,
                    substr(h.order_no,1,3),
                    h.order_price
        )
        where confirm_no not in (SELECT CONFIRM_NO FROM IOD WHERE CONFIRM_NO IS NOT NULL)
    ) a,
    sbsecurities b
    where a.sec_code=b.symbol
    ----- FLEX KHOP -----------
    UNION ALL
    select a.confirm_no, a.trading_date,a.acctno,a.bors,a.sec_code,a.price,a.qtty,
        'FLEX KHOP' , b.tradeplace LECH
    from
    (-- LENH KHOP TRONG FLEX
        select i.orgorderid confirm_no, i.txdate trading_date,i.custodycd
            acctno,i.bors,to_char(i.symbol) sec_code,
            i.matchprice price, sum(i.matchqtty) qtty
        from iod i
            where i.txdate = (SELECT TO_DATE(varvalue,'DD/MM/YYYY')
                           FROM sysvar WHERE varname = 'CURRDATE' AND grname = 'SYSTEM')
            and i.deltd <> 'Y' and i.confirm_no is null
        group by i.orgorderid, i.txdate,i.custodycd ,i.bors,i.symbol, i.matchprice
        union all
        select i.orgorderid confirm_no, i.txdate trading_date,i.custodycd
            acctno,i.bors,to_char(i.symbol) sec_code,
            i.matchprice price, sum(i.matchqtty) qtty
        from iod i
            where i.txdate = (SELECT TO_DATE(varvalue,'DD/MM/YYYY')
                           FROM sysvar WHERE varname = 'CURRDATE' AND grname = 'SYSTEM')
            and i.deltd <> 'Y' and i.confirm_no is not null
            and i.confirm_no not in (
                select order_confirm_no from vw_sts_orders_hnx_upcom
                where order_date =(SELECT   TO_DATE (varvalue,'DD/MM/YYYY')
                               FROM  sysvar WHERE   varname = 'CURRDATE' AND grname = 'SYSTEM')
                union all
                select confirm_no from trading_result
                where trading_date=(SELECT   TO_DATE (varvalue,'DD/MM/YYYY')
                               FROM  sysvar WHERE   varname = 'CURRDATE' AND grname = 'SYSTEM')
                )
        group by i.orgorderid, i.txdate,i.custodycd ,i.bors,i.symbol, i.matchprice
    ) a,
    sbsecurities b
    where a.sec_code=b.symbol
) where 0=0 and qtty <> 0 ORDER BY ACCTNO,SEC_CODE
/
