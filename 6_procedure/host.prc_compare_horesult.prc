SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "PRC_COMPARE_HORESULT"
   IS
  v_flag VARCHAR2(10)   ;
BEGIN

     v_flag := 'FALSE';
     delete tradingresultexp;
     --delete matchresult;
      dbms_output.put_line(SYSTIMESTAMP);
     delete iodcompare;
     commit;
     insert into iodcompare
     select orgorderid, exorderid, codeid, symbol, custodycd,
       bors, norp, aorn, price, qtty, refcustcd,
       matchprice, matchqtty, txnum, txdate, deltd,
       confirm_no, txtime
     from vw_iod_all where txdate = (SELECT TO_DATE(buyer_order_date, 'dd/mm/yyyy') FROM file_astdl WHERE ROWNUM = 1);
     commit;
       dbms_output.put_line(SYSTIMESTAMP);
     commit;

        INSERT INTO TRADINGRESULTEXP (REASON, TXDATE, SYMBOL, PRICE, QTTY,MATCHAMOUNT,BORS,CUSTODYCD,CONFIRM_NO)
            SELECT   min(REASON) REASON, TXDATE, SYMBOL, PRICE, QTTY,MATCHAMOUNT,BORS,CUSTODYCD, trim(CONFIRM_NO)

            FROM
            (
            select  'N' as  REASON , N.TXDATE, TO_CHAR(N.SYMBOL) SYMBOL, N.PRICE, N.QTTY, N.MATCHAMOUNT, N.BORS, N.CUSTODYCD, N.CONFIRM_NO FROM
                     (
                     SELECT TO_DATE(buyer_order_date, 'dd/mm/yyyy') TXDATE, h.scrip_symbol SYMBOL, TO_NUMBER(h.deal_price)*1000 PRICE, TO_NUMBER(h.deal_volume) QTTY , TO_NUMBER(h.deal_price)*1000*h.deal_volume MATCHAMOUNT , 'S' BORS , h.seller_customerid  CUSTODYCD, 'VS'|| 'S' || deal_confirm_no CONFIRM_NO
                       FROM file_astdl h , cfmast b where h.seller_customerid = B.CUSTODYCD
                      UNION
                      SELECT TO_DATE(buyer_order_date, 'dd/mm/yyyy') TXDATE, h.scrip_symbol SYMBOL, TO_NUMBER(h.deal_price)*1000 PRICE, TO_NUMBER(h.deal_volume) QTTY , TO_NUMBER(h.deal_price)*1000*h.deal_volume MATCHAMOUNT , 'B' BORS , h.buyer_customerid  CUSTODYCD, 'VS'|| 'B' || deal_confirm_no CONFIRM_NO
                       FROM file_astdl h , cfmast b where h.buyer_customerid = B.CUSTODYCD) N
              UNION ALL
              select 'P' as REASON  , P.TXDATE, TO_CHAR(P.SYMBOL) SYMBOL, P.PRICE, P.QTTY, P.MATCHAMOUNT,P.BORS, P.CUSTODYCD, P.CONFIRM_NO FROM
               (
              SELECT TO_DATE(IO.TXDATE) TXDATE, IO.SYMBOL, IO.MATCHPRICE PRICE, IO.MATCHQTTY QTTY, IO.MATCHPRICE*IO.MATCHQTTY MATCHAMOUNT, IO.BORS, IO.CUSTODYCD, CONFIRM_NO
                     FROM iodcompare IO, sbsecurities SB
                     WHERE IO.SYMBOL = SB.SYMBOL AND SB.TRADEPLACE = '001') P
              )
              GROUP BY TXDATE, SYMBOL,PRICE, QTTY,MATCHAMOUNT,BORS,CUSTODYCD,trim(CONFIRM_NO)
              HAVING COUNT(*) = 1
              ORDER BY TXDATE, SYMBOL,PRICE, QTTY,MATCHAMOUNT,BORS,CUSTODYCD,trim(CONFIRM_NO);

              COMMIT;


dbms_output.put_line(SYSTIMESTAMP);


   EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
       INSERT INTO log_err
                  (id,date_log, POSITION, text
                  )
           VALUES ( seq_log_err.NEXTVAL,SYSDATE, ' PRC_COMPARE_HNXRESULT ', 'abcd'
                  );

       COMMIT;
END;

 
 
 
 
/
