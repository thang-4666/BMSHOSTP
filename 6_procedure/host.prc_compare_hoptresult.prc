SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "PRC_COMPARE_HOPTRESULT"
   IS
  v_flag VARCHAR2(10)   ;
  v_duplicate varchar(10);
BEGIN

     v_flag := 'FALSE';
     v_duplicate := 'FALSE';
     delete tradingresultexp;
     delete matchresult;
      dbms_output.put_line(SYSTIMESTAMP);
     delete iodcompare;
     commit;
     insert into iodcompare
     select orgorderid, exorderid, codeid, symbol, custodycd,
       bors, norp, aorn, price, qtty, refcustcd,
       matchprice, matchqtty, txnum, txdate, deltd,
       confirm_no, txtime
     from vw_iod_all where txdate = (SELECT TO_DATE(deal_date, 'dd/mm/yyyy') FROM file_astpt WHERE ROWNUM = 1);
     commit;
       dbms_output.put_line(SYSTIMESTAMP);
     commit;

     FOR J IN (
     Select * from
                 (
                    SELECT 'VS'|| 'S' || deal_confirm_no AUTOID, TO_DATE(deal_date, 'dd/mm/yyyy') TXDATE, h.deal_security_symbol SYMBOL, TO_NUMBER(h.deal_price)*1000 PRICE,  (h.seller_brk_customer_vol + h.seller_brk_portfolio_vol) QTTY , 'S' BORS , h.seller_customer_id  CUSTODYCD, 'VS'|| 'S' || deal_confirm_no CONFIRM_NO
                    FROM file_astpt h , cfmast b where h.seller_customer_id = B.CUSTODYCD
                               UNION ALL
                    SELECT 'VS'|| 'B' || deal_confirm_no AUTOID, TO_DATE(deal_date, 'dd/mm/yyyy') TXDATE, h.deal_security_symbol SYMBOL, TO_NUMBER(h.deal_price)*1000 PRICE,  (h.buyer_brk_customer_vol + h.buyer_brk_portfolio_vol) QTTY , 'B' BORS , h.buyer_customer_id  CUSTODYCD, 'VS'|| 'B' || deal_confirm_no CONFIRM_NO
                    FROM file_astpt h , cfmast b where h.buyer_customer_id = B.CUSTODYCD

                  )
   )
     LOOP
             FOR I IN (
                 Select * from
                 (
                     SELECT IO.ORGORDERID AUTOID, TO_DATE(IO.TXDATE) TXDATE, IO.SYMBOL, IO.MATCHPRICE, IO.MATCHQTTY, IO.MATCHPRICE*IO.MATCHQTTY MATCHAMOUNT, IO.BORS, IO.CUSTODYCD FROM iodcompare IO, sbsecurities SB WHERE IO.SYMBOL = SB.SYMBOL AND SB.TRADEPLACE = '001' AND IO.NORP = 'P'
                    )
                 )
             LOOP
                v_flag := 'FALSE';
                IF ( TRIM(J.SYMBOL) = I.SYMBOL AND TRIM(J.PRICE) = I.MATCHPRICE AND TRIM(J.QTTY) = I.MATCHQTTY
                AND J.BORS = I.BORS AND J.CUSTODYCD = I.CUSTODYCD  ) THEN

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
                      (I.AUTOID, I.TXDATE, I.SYMBOL, I.MATCHPRICE, I.MATCHQTTY, I.MATCHAMOUNT, I.BORS, I.CUSTODYCD, 'HOPT');

                    v_flag := 'TRUE';
                    COMMIT;
                    EXIT;
                    END IF;
                ELSE v_flag := 'FALSE';
                END IF;
             END LOOP  ;
             IF v_flag = 'FALSE'  THEN
             INSERT INTO  tradingresultexp (AUTOID , TXDATE,SYMBOL,PRICE,QTTY,MATCHAMOUNT,BORS,CUSTODYCD, CONFIRM_NO, REASON)  VALUES
                      (J.AUTOID, J.TXDATE, J.SYMBOL, J.PRICE, J.QTTY, J.PRICE*J.QTTY, J.BORS, J.CUSTODYCD , J.CONFIRM_NO, 'N');

             COMMIT;
             END IF;


END LOOP;



FOR J IN (
     Select * from
                 (
                       SELECT IO.ORGORDERID AUTOID, TO_DATE(IO.TXDATE) TXDATE, IO.SYMBOL, IO.MATCHPRICE, IO.MATCHQTTY, IO.MATCHPRICE*IO.MATCHQTTY MATCHAMOUNT, IO.BORS, IO.CUSTODYCD FROM iodcompare IO, sbsecurities SB WHERE IO.SYMBOL = SB.SYMBOL AND SB.TRADEPLACE = '001' AND IO.NORP = 'P'
                 )
   )
     LOOP

             FOR I IN (
                 Select * from
                 (
                    SELECT 'VS'|| 'S' || deal_confirm_no AUTOID, TO_DATE(deal_date, 'dd/mm/yyyy') TXDATE, h.deal_security_symbol SYMBOL, TO_NUMBER(h.deal_price)*1000 PRICE,  (h.seller_brk_customer_vol + h.seller_brk_portfolio_vol) QTTY , 'S' BORS , h.seller_customer_id  CUSTODYCD, 'VS'|| 'S' || deal_confirm_no CONFIRM_NO
                    FROM file_astpt h , cfmast b where h.seller_customer_id = B.CUSTODYCD
                               UNION ALL
                    SELECT 'VS'|| 'B' || deal_confirm_no AUTOID, TO_DATE(deal_date, 'dd/mm/yyyy') TXDATE, h.deal_security_symbol SYMBOL, TO_NUMBER(h.deal_price)*1000 PRICE,  (h.buyer_brk_customer_vol + h.buyer_brk_portfolio_vol) QTTY , 'B' BORS , h.buyer_customer_id  CUSTODYCD, 'VS'|| 'B' || deal_confirm_no CONFIRM_NO
                    FROM file_astpt h , cfmast b where h.buyer_customer_id = B.CUSTODYCD
                 )
               )
             LOOP
             v_flag := 'FALSE';
                IF (J.TXDATE = I.TXDATE AND J.SYMBOL = I.SYMBOL AND J.MATCHPRICE = I.PRICE AND J.MATCHQTTY= I.QTTY
                AND J.BORS = I.BORS AND J.CUSTODYCD = I.CUSTODYCD ) THEN
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
                      (I.AUTOID, I.TXDATE, I.SYMBOL, I.PRICE, I.QTTY, J.MATCHAMOUNT, I.BORS, I.CUSTODYCD, 'HOPT');
                    v_flag := 'TRUE';
                    COMMIT;
                    EXIT;
                    END IF;
                ELSE v_flag := 'FALSE';
                END IF;

             END LOOP  ;
             dbms_output.put_line(v_flag);
             IF v_flag = 'FALSE' THEN
             INSERT INTO  tradingresultexp (AUTOID , TXDATE,SYMBOL,PRICE,QTTY,MATCHAMOUNT,BORS,CUSTODYCD, CONFIRM_NO ,REASON)  VALUES
                      (J.AUTOID, J.TXDATE, J.SYMBOL, J.MATCHPRICE, J.MATCHQTTY, J.MATCHAMOUNT, J.BORS, J.CUSTODYCD , J.AUTOID, 'P');

             END IF;


END LOOP;



   EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
       INSERT INTO log_err
                  (id,date_log, POSITION, text
                  )
           VALUES ( seq_log_err.NEXTVAL,SYSDATE, ' PRC_COMPARE_PTHORESULT ', 'abcd'
                  );

       COMMIT;
END;

 
 
 
 
/
