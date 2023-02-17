SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "PRC_COMPARE_HNXRESULT"
   IS
  v_flag VARCHAR2(10)   ;
   v_duplicate varchar (10);
BEGIN

     v_flag := 'FALSE';
     v_duplicate := 'FALSE';
     dbms_output.put_line(' start '||to_char(sysdate,'hh24:mi:ss'));
     delete tradingresultexp;
     --delete matchresult;
      dbms_output.put_line(SYSTIMESTAMP);
     delete iodcompare;
     commit;
     insert into iodcompare
     (select orgorderid, exorderid, codeid, symbol, custodycd,
       bors, norp, aorn, price, qtty, refcustcd,
       matchprice, matchqtty, txnum, txdate, deltd,
       confirm_no, txtime
      from vw_iod_all io where txdate = (SELECT TO_DATE(TRADING_DATE) FROM hnxtradingresult WHERE ROWNUM = 1));
     commit;
     dbms_output.put_line(SYSTIMESTAMP);

      INSERT INTO TRADINGRESULTEXP (REASON, TXDATE, SYMBOL, PRICE, QTTY,MATCHAMOUNT,BORS,CUSTODYCD,CONFIRM_NO)
            SELECT   MIN(REASON)as REASON, TXDATE, SYMBOL, PRICE, QTTY,MATCHAMOUNT,BORS,CUSTODYCD,'HNX' CONFIRM_NO

            FROM
            (
            select  'N' as  REASON , N.TXDATE, TO_CHAR(N.SYMBOL) SYMBOL, N.PRICE, N.QTTY, N.MATCHAMOUNT, N.BORS, N.CUSTODYCD FROM
                     (
                     SELECT AUTOID || 'S' AUTOID, TO_DATE(TRADING_DATE) TXDATE, SYMBOL, PRICE, QTTY , MATCHAMOUNT, 'S' BORS , h.SELLACCOUNT  CUSTODYCD FROM hnxtradingresult h , cfmast b  where h.SELLACCOUNT = B.CUSTODYCD
                     UNION ALL
                     SELECT AUTOID || 'B' AUTOID,  TO_DATE(TRADING_DATE) TXDATE, SYMBOL, PRICE, QTTY , MATCHAMOUNT, 'B' BORS , h.BUYACCOUNT CUSTODYCD FROM hnxtradingresult h , cfmast b
                     where h.buyaccount = B.CUSTODYCD) N
              UNION ALL
              select 'P' as REASON  , P.TXDATE, TO_CHAR(P.SYMBOL) SYMBOL, P.PRICE, P.QTTY, P.MATCHAMOUNT, P.BORS, P.CUSTODYCD FROM
               (
              SELECT IO.CONFIRM_NO AUTOID, TO_DATE(IO.TXDATE) TXDATE, IO.SYMBOL, IO.MATCHPRICE PRICE, IO.MATCHQTTY QTTY, IO.MATCHPRICE*IO.MATCHQTTY MATCHAMOUNT, IO.BORS, IO.CUSTODYCD FROM iodcompare IO, sbsecurities SB
              WHERE IO.SYMBOL = SB.SYMBOL  AND SB.TRADEPLACE = '002' ) P
              )
              GROUP BY TXDATE, SYMBOL,PRICE, QTTY,MATCHAMOUNT,BORS,CUSTODYCD
              HAVING COUNT(*) = 1
              ORDER BY TXDATE, SYMBOL,PRICE, QTTY,MATCHAMOUNT,BORS,CUSTODYCD;

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
