SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "PRC_COMPARE_UPCOMRESULT"
   IS
    v_flag VARCHAR2(10)   ;
   v_duplicate varchar (10);
BEGIN

     v_flag := 'FALSE';
     v_duplicate := 'FALSE';
     dbms_output.put_line(' start '||to_char(sysdate,'hh24:mi:ss'));
     delete tradingresultexp;
     delete matchresult;
      dbms_output.put_line(SYSTIMESTAMP);
     delete iodcompare;
     commit;
     insert into iodcompare
     (select orgorderid, exorderid, codeid, symbol, custodycd,
       bors, norp, aorn, price, qtty, refcustcd,
       matchprice, matchqtty, txnum, txdate, deltd,
       confirm_no, txtime
     from vw_iod_all where txdate = (SELECT TO_DATE(TRADING_DATE) FROM hnxtradingresult WHERE ROWNUM = 1));
     commit;
       dbms_output.put_line(SYSTIMESTAMP);
     FOR J IN (
     Select * from
                 (
                     SELECT SYMBOL, PRICE, QTTY , MATCHAMOUNT, 'S' BORS , h.SELLACCOUNT  CUSTODYCD FROM hnxtradingresult h , cfmast b where h.SELLACCOUNT = B.CUSTODYCD
                     UNION ALL
                     SELECT SYMBOL, PRICE, QTTY , MATCHAMOUNT, 'B' BORS , h.BUYACCOUNT CUSTODYCD FROM hnxtradingresult h , cfmast b where h.buyaccount = B.CUSTODYCD
                  )
   )
     LOOP
             FOR I IN (
                 Select * from
                 (
                  SELECT IO.CONFIRM_NO AUTOID, IO.SYMBOL, IO.MATCHPRICE, IO.MATCHQTTY, IO.MATCHPRICE*IO.MATCHQTTY MATCHAMOUNT, IO.BORS, IO.CUSTODYCD FROM IODCOMPARE IO, sbsecurities SB WHERE IO.SYMBOL = SB.SYMBOL AND SB.TRADEPLACE = '005'
                 )
               )
             LOOP
                v_flag := 'FALSE';
                IF ( J.SYMBOL = I.SYMBOL AND J.PRICE = I.MATCHPRICE AND J.QTTY = I.MATCHQTTY
                 AND J.MATCHAMOUNT = I.MATCHAMOUNT AND J.BORS = I.BORS AND J.CUSTODYCD = I.CUSTODYCD ) THEN

                    FOR M IN ( SELECT AUTOID FROM matchresult )
                    LOOP
                         IF ( I.AUTOID = M.AUTOID) THEN
                             v_duplicate := 'TRUE';
                             exit;
                         ELSE
                         v_duplicate := 'FALSE';
                         END IF;
                    END LOOP;

                    IF( v_duplicate = 'FALSE') THEN
                    INSERT INTO  matchresult (AUTOID , TXDATE,SYMBOL,PRICE,QTTY,MATCHAMOUNT,BORS,CUSTODYCD,CONFIRM_NO)  VALUES
                      (I.AUTOID, TO_CHAR(SYSDATE,'DD/MM/RRRR'), I.SYMBOL, I.MATCHPRICE, I.MATCHQTTY, I.MATCHAMOUNT, I.BORS, I.CUSTODYCD, 'UPCOM');

                    v_flag := 'TRUE';
                    COMMIT;
                    EXIT;
                    END IF;
                ELSE v_flag := 'FALSE';
                END IF;

             END LOOP  ;
             dbms_output.put_line(v_flag);
             IF v_flag = 'FALSE' THEN
             INSERT INTO  tradingresultexp (AUTOID , TXDATE,SYMBOL,PRICE,QTTY,MATCHAMOUNT,BORS,CUSTODYCD,CONFIRM_NO, REASON)  VALUES
                      (seq_compareorder.NEXTVAL, TO_CHAR(SYSDATE,'DD/MM/RRRR'), J.SYMBOL, J.PRICE, J.QTTY, J.MATCHAMOUNT, J.BORS, J.CUSTODYCD, 'UPCOM','N');

             END IF;


END LOOP;



    FOR J IN (
     Select * from
                 (
                  SELECT IO.CONFIRM_NO AUTOID, IO.SYMBOL, IO.MATCHPRICE, IO.MATCHQTTY, IO.MATCHPRICE*IO.MATCHQTTY MATCHAMOUNT, IO.BORS, IO.CUSTODYCD FROM IODCOMPARE IO, sbsecurities SB WHERE IO.SYMBOL = SB.SYMBOL AND SB.TRADEPLACE = '005'   AND  NOT EXISTS ( SELECT * FROM matchresult WHERE AUTOID = IO.CONFIRM_NO )
                 )
   )
     LOOP


             FOR I IN (
                 Select * from
                 (
                     SELECT SYMBOL, PRICE, QTTY , MATCHAMOUNT, 'S' BORS , h.SELLACCOUNT  CUSTODYCD FROM hnxtradingresult h , cfmast b where h.SELLACCOUNT = B.CUSTODYCD
                     UNION ALL
                     SELECT SYMBOL, PRICE, QTTY , MATCHAMOUNT, 'B' BORS , h.BUYACCOUNT CUSTODYCD FROM hnxtradingresult h , cfmast b where h.buyaccount = B.CUSTODYCD
                 )
               )
             LOOP
                IF ( J.SYMBOL = I.SYMBOL AND J.MATCHPRICE = I.PRICE AND J.MATCHQTTY = I.QTTY
                 AND J.MATCHAMOUNT = I.MATCHAMOUNT AND J.BORS = I.BORS AND J.CUSTODYCD = I.CUSTODYCD ) THEN
                v_flag := 'TRUE';
                EXIT;
                ELSE
                v_flag := 'FALSE';
                END IF;
             END LOOP  ;
             dbms_output.put_line(v_flag);
             IF v_flag = 'FALSE' THEN
             INSERT INTO  tradingresultexp (AUTOID , TXDATE,SYMBOL,PRICE,QTTY,MATCHAMOUNT,BORS,CUSTODYCD,CONFIRM_NO, REASON)  VALUES
                      (J.AUTOID, TO_CHAR(SYSDATE,'DD/MM/RRRR'), J.SYMBOL, J.MATCHPRICE, J.MATCHQTTY, J.MATCHAMOUNT, J.BORS, J.CUSTODYCD, 'UPCOM','N');

             END IF;


END LOOP;


   EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
       INSERT INTO log_err
                  (id,date_log, POSITION, text
                  )
           VALUES ( seq_log_err.NEXTVAL,SYSDATE, ' prc_compare_upcomresult ', 'abcd'
                  );

       COMMIT;
END;

 
 
 
 
/
