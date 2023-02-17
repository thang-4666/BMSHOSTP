SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "PRC_MAP_ORDERBOOK"
   IS
   V_COUNT NUMBER(10);
      v_err varchar(3000);
    v_tradeplace varchar2(20);


    CURSOR C_STCORDER(V_CUSTODYCD VARCHAR2,V_SYMBOL VARCHAR2,V_ORDERTYPE VARCHAR2,V_NORP VARCHAR2,V_BSCA VARCHAR2,V_VOLUME NUMBER,V_PRICE NUMBER,v_puttype varchar2)
        IS
         Select * from
         (
            -- HNX
           SELECT MST.TXTIME, ORDERID,MST.QUOTEPRICE FROM ODMAST MST, OOD, SBSECURITIES CD, AFMAST AF, CFMAST CF
            WHERE MST.CODEID=CD.CODEID AND MST.AFACCTNO=AF.ACCTNO AND AF.CUSTID=CF.CUSTID
            AND MST.ORDERID=OOD.ORGORDERID AND OOD.DELTD<>'Y' AND OOD.OODSTATUS='S'
            -- new add
            AND MST.CANCELQTTY = 0
            AND CF.CUSTODYCD=trim(V_CUSTODYCD) AND CD.SYMBOL=trim(V_SYMBOL)
            AND MST.PRICETYPE=trim(V_ORDERTYPE) AND MST.MATCHTYPE=trim(V_NORP)
            and ( cd.tradeplace<>'005' )
            AND (CASE WHEN (MST.EXECTYPE='NB' OR MST.EXECTYPE='BC') THEN 'B' WHEN (MST.EXECTYPE = 'NS' OR MST.EXECTYPE = 'MS') Then 'S' END)=trim(V_BSCA)
            AND MST.ORDERQTTY=V_VOLUME AND MST.QUOTEPRICE=(CASE WHEN MST.PRICETYPE<>'LO' THEN MST.QUOTEPRICE ELSE V_PRICE END)
            AND  NOT EXISTS (SELECT ORDERID FROM STCORDERBOOK WHERE ORDERID = MST.ORDERID)
            Union all
             -- UPcom
            SELECT MST.TXTIME, ORDERID,
                   (CASE WHEN (MST.EXECTYPE='NB' OR MST.EXECTYPE='BC') THEN QUOTEPRICE
                      WHEN (MST.EXECTYPE = 'NS' OR MST.EXECTYPE = 'MS') Then -1*QUOTEPRICE END) QUOTEPRICE
            FROM ODMAST MST, OOD, SBSECURITIES CD, AFMAST AF, CFMAST CF
            WHERE MST.CODEID=CD.CODEID AND MST.AFACCTNO=AF.ACCTNO AND AF.CUSTID=CF.CUSTID
            AND MST.ORDERID=OOD.ORGORDERID AND OOD.DELTD<>'Y' AND OOD.OODSTATUS='S'
            AND CF.CUSTODYCD=trim(V_CUSTODYCD)
            AND CD.SYMBOL=trim(V_SYMBOL)
            AND MST.PRICETYPE=trim(V_ORDERTYPE)
            AND MST.MATCHTYPE=trim(V_NORP)
            AND  cd.tradeplace = '005'
            AND ( mst.puttype = trim(v_puttype) )
            AND (CASE WHEN (MST.EXECTYPE='NB' OR MST.EXECTYPE='BC') THEN 'B'
                      WHEN (MST.EXECTYPE = 'NS' OR MST.EXECTYPE = 'MS') Then 'S' END)=trim(V_BSCA)
            AND MST.ORDERQTTY=V_VOLUME

            AND ( (MST.EXECTYPE in ('NB','BC') and MST.QUOTEPRICE = V_PRICE)
                   or
                  (MST.EXECTYPE in ('NS','MS') and MST.QUOTEPRICE = V_PRICE)
                 )
            AND  NOT EXISTS (SELECT ORDERID FROM STCORDERBOOK WHERE ORDERID = MST.ORDERID)
          )
        ORDER BY TXTIME, ORDERID, QUOTEPRICE;




   V_STCORDER C_STCORDER%rowtype;
   V_SQL varchar2(500);
BEGIN
     dbms_output.put_line(' start '||to_char(sysdate,'hh24:mi:ss'));
     V_SQL:='TRUNCATE TABLE STCORDERBOOKTEMP DROP STORAGE';
     EXECUTE IMMEDIATE V_SQL;
     --Ghi nhan cac lenh moi vao bang temp
     INSERT INTO STCORDERBOOKTEMP
     SELECT * FROM STCORDERBOOKBUFFER S WHERE NOT EXISTS
     (SELECT REFORDERNUMBER FROM STCORDERBOOK WHERE REFORDERNUMBER =S.REFORDERNUMBER);
     COMMIT;

    --Thuc hien mapping so hieu lenh tu bang temp cho cac lenh chua duoc map.
     FOR I IN (SELECT * FROM STCORDERBOOKTEMP ORDER BY ORDERNUMBER ASC)
     LOOP
     /*
        dbms_output.put_line(I.CUSTODYCD);
dbms_output.put_line(I.SYMBOL);
dbms_output.put_line(I.ORDERTYPE);
dbms_output.put_line(I.BSCA);
dbms_output.put_line(to_number(I.VOLUME));
dbms_output.put_line(to_number(I.PRICE));
dbms_output.put_line(i.puttype);      */
        OPEN C_STCORDER(I.CUSTODYCD,I.SYMBOL,I.ORDERTYPE,I.NORP,I.BSCA,to_number(I.VOLUME),to_number(I.PRICE),i.puttype);
        LOOP
        FETCH C_STCORDER INTO V_STCORDER;
        EXIT WHEN C_STCORDER%NOTFOUND;

        SELECT COUNT(1) INTO V_COUNT  FROM STCORDERBOOK WHERE REFORDERNUMBER = I.REFORDERNUMBER;
        IF V_COUNT = 0 THEN
           INSERT INTO STCORDERBOOK (ORDERID, TXDATE, ORDERNUMBER, REFORDERNUMBER, CUSTODYCD,
                                    SYMBOL, BSCA, NORP, ORDERTYPE, VOLUME, PRICE, TRADERID, MEMBERID, BOARD,PUTTYPE)
            VALUES(V_STCORDER.ORDERID,I.TXDATE,I.ORDERNUMBER,I.REFORDERNUMBER,I.CUSTODYCD,
                   I.SYMBOL, I.BSCA, I.NORP, I.ORDERTYPE, I.VOLUME, I.PRICE, I.TRADERID, I.MEMBERID, I.BOARD,i.PUTTYPE
                       )
                       ;

            update odmast set orstatus= '2' where orderid = V_STCORDER.ORDERID;
            commit;

            -- Doi voi lenh Huy HNX cap nhat HNXORDERID vao gtw_hnx_cancel_order
            /*SELECT tradeplace INTO v_tradeplace FROM sbsecurities WHERE symbol = TRIM(I.SYMBOL);
            IF v_tradeplace = '002' THEN -- HNX
                UPDATE gtw_hnx_cancel_order
                SET hnxorderid = TRIM(I.ORDERNUMBER)
                WHERE orderid = V_STCORDER.ORDERID;
            END IF;
            */
        END IF;
        END LOOP;
        CLOSE C_STCORDER;

     END LOOP;
   COMMIT;
   DELETE FROM STCORDERBOOKTEMP WHERE REFORDERNUMBER IN
                         (SELECT REFORDERNUMBER FROM STCORDERBOOK);


   DELETE FROM STCORDERBOOKEXP S WHERE  NOT EXISTS
                        (SELECT REFORDERNUMBER FROM STCORDERBOOKTEMP WHERE REFORDERNUMBER= S.REFORDERNUMBER);

   INSERT INTO STCORDERBOOKEXP SELECT * FROM STCORDERBOOKTEMP S WHERE  NOT EXISTS
   (SELECT REFORDERNUMBER FROM STCORDERBOOKEXP WHERE REFORDERNUMBER=S.REFORDERNUMBER);
   COMMIT;

   EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
       INSERT INTO log_err
                  (id,date_log, POSITION, text
                  )
           VALUES ( seq_log_err.NEXTVAL,SYSDATE, ' PRC_MAP_ORDERBOOK ', 'abcd'
                  );

       COMMIT;
END;

 
 
 
 
/
