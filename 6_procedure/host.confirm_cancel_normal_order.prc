SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CONFIRM_CANCEL_NORMAL_ORDER" (
   pv_orderid   IN   VARCHAR2,
   pv_qtty      IN VARCHAR2
)
IS
   v_edstatus         VARCHAR2 (30);
   v_tltxcd           VARCHAR2 (30);
   v_txnum            VARCHAR2 (30);
   v_txdate           VARCHAR2 (30);
   v_tlid             VARCHAR2 (30);
   v_brid             VARCHAR2 (30);
   v_ipaddress        VARCHAR2 (30);
   v_wsname           VARCHAR2 (30);
   v_symbol           VARCHAR2 (30);
   v_afaccount        VARCHAR2 (30);
   v_seacctno         VARCHAR2 (30);
   v_price            NUMBER (10,2);
   v_quantity         NUMBER (10,2);
   v_bratio           NUMBER (10,2);
   v_oldbratio        NUMBER (10,2);
   v_cancelqtty       NUMBER (10,2);
   v_amendmentqtty    NUMBER (10,2);
   v_amendmentprice   NUMBER (10,2);
   v_matchedqtty      NUMBER (10,2);
   v_advancedamount   NUMBER (10,2);
   v_execqtty         NUMBER (10,2);
   v_trExectype       VARCHAR2 (30);
   v_reforderid       VARCHAR2 (30);
   v_tradeunit        NUMBER (10,2);
   v_desc             VARCHAR2 (300);
   v_bors             VARCHAR2 (30);
   v_txtime           VARCHAR2 (30);
   v_Count_lenhhuy    Number(2);
   v_OrderQtty_Cur    Number(10);
   v_RemainQtty_Cur   Number(10);
   v_ExecQtty_Cur     Number(10);
   v_CancelQtty_Cur   Number(10);
   v_Orstatus_Cur     VARCHAR2(10);
   v_err              VARCHAR2(300);
BEGIN
   --0 lay cac tham so
   v_brid := '0000';
   v_tlid := '0000';
   v_ipaddress := 'HOST';
   v_wsname := 'HOST';
   v_cancelqtty := pv_qtty;
   --Kiem tra thoa man dieu kien huy
   BEGIN
    SELECT ORDERQTTY,REMAINQTTY,EXECQTTY,CANCELQTTY,ORSTATUS,Exectype
    INTO V_ORDERQTTY_CUR,V_REMAINQTTY_CUR,V_EXECQTTY_CUR,V_CANCELQTTY_CUR,V_ORSTATUS_CUR,v_trExectype
    FROM ODMAST WHERE ORDERID =PV_ORDERID;
   EXCEPTION WHEN OTHERS THEN
     RETURN;
   END;
   IF V_REMAINQTTY_CUR - V_CANCELQTTY < 0 OR V_EXECQTTY_CUR >= V_ORDERQTTY_CUR
                 OR V_CANCELQTTY = 0
   THEN
    RETURN;
   END IF;

    --v_cancelqtty := V_REMAINQTTY_CUR;
   --Lenh huy thong thuong: Co lenh huy 1C
   SELECT count(*) INTO v_Count_lenhhuy FROM odmast WHERE reforderid =pv_orderid AND exectype IN ('CB','CS');
   IF v_Count_lenhhuy >0 Then
        SELECT (CASE
                      WHEN exectype = 'CB'
                         THEN '8890'
                      ELSE '8891'
                   END), sb.symbol,
                  od.afacctno, od.seacctno, od.quoteprice, od.orderqtty, od.bratio,
                  0, od.quoteprice, 0, od.execqtty,
                  od.reforderid, sb.tradeunit, od.edstatus
             INTO v_tltxcd, v_symbol,
                  v_afaccount, v_seacctno, v_price, v_quantity, v_bratio,
                  v_amendmentqtty, v_amendmentprice, v_matchedqtty, v_execqtty,
                  v_reforderid, v_tradeunit, v_edstatus
             FROM odmast od, securities_info sb
            WHERE od.codeid = sb.codeid AND reforderid = pv_orderid;
   ELSE
    --Giai toa ATO
            SELECT (CASE
                      WHEN EXECTYPE LIKE '%B'
                         THEN '8808'
                      ELSE '8807'
                   END), sb.symbol,
                  od.afacctno, od.seacctno, od.quoteprice, od.orderqtty, od.bratio,
                  0, od.quoteprice, 0, od.execqtty,
                  od.reforderid, sb.tradeunit, od.edstatus
             INTO v_tltxcd, v_symbol,
                  v_afaccount, v_seacctno, v_price, v_quantity, v_bratio,
                  v_amendmentqtty, v_amendmentprice, v_matchedqtty, v_execqtty,
                  v_reforderid, v_tradeunit, v_edstatus
             FROM odmast od, securities_info sb
            WHERE od.codeid = sb.codeid AND orderid = pv_orderid;
    END IF;


   v_advancedamount := 0;


   SELECT bratio
     INTO v_oldbratio
     FROM odmast
    WHERE orderid = pv_orderid;

      --NEU CHAU BI HUY THI KHI NHAN DUOC MESSAGE TRA VE SE THUC HIEN HUY LENH
      SELECT varvalue
        INTO v_txdate
        FROM sysvar
       WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';

      SELECT    '8000'
             || SUBSTR ('000000' || seq_batchtxnum.NEXTVAL,
                        LENGTH ('000000' || seq_batchtxnum.NEXTVAL) - 5,
                        6
                       )
        INTO v_txnum
        FROM DUAL;

      SELECT TO_CHAR (SYSDATE, 'HH24:MI:SS')
        INTO v_txtime
        FROM DUAL;

      --1 them vao trong tllog
      INSERT INTO tllog
                  (autoid, txnum,
                   txdate, txtime, brid,
                   tlid, offid, ovrrqs, chid, chkid, tltxcd, ibt, brid2,
                   tlid2, ccyusage, txstatus, msgacct, msgamt, chktime,
                   offtime, off_line, deltd, brdate,
                   busdate, msgsts, ovrsts, ipaddress,
                   wsname, batchname, txdesc
                  )
           VALUES (seq_tllog.NEXTVAL, v_txnum,
                   TO_DATE (v_txdate, 'DD/MM/YYYY'), v_txtime, v_brid,
                   v_tlid, '', 'N', '', '', v_tltxcd, 'Y', '',
                   '', '', '1', pv_orderid, v_quantity, '',
                   '', 'N', 'N', TO_DATE (v_txdate, 'DD/MM/YYYY'),
                   TO_DATE (v_txdate, 'DD/MM/YYYY'), '', '', v_ipaddress,
                   v_wsname, 'DAY', v_desc
                  );
      --them vao tllogfld
      INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
      VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/YYYY'),'07',0,v_symbol,NULL);
      INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
      VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/YYYY'),'03',0,v_afaccount,NULL);
      INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
      VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/YYYY'),'04',0,pv_orderid,NULL);
      INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
      VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/YYYY'),'06',0,v_seacctno,NULL);
      INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
      VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/YYYY'),'08',0,pv_orderid,NULL);
      INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
      VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/YYYY'),'14',v_cancelqtty,NULL,NULL);
      INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
      VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/YYYY'),'11',v_price,NULL,NULL);
      INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
      VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/YYYY'),'12',v_quantity,NULL,NULL);
      --2 THEM VAO TRONG TLLOGFLD
          v_edstatus := 'W';
          UPDATE odmast
             SET edstatus = v_edstatus
          WHERE orderid = pv_orderid;

      If v_Count_lenhhuy >0 then
          v_edstatus := 'W';
          UPDATE odmast
             SET edstatus = v_edstatus
          WHERE orderid = pv_orderid;

          UPDATE OOD SET OODSTATUS = 'S'
          WHERE   ORGORDERID IN (SELECT ORDERID FROM ODMAST  WHERE REFORDERID = pv_orderid)
          and OODSTATUS <> 'S';

      Else
        --OOD: Cap nhat E
        --ODMAST:
        --Update OOD set OODSTATUS ='E' where ORGORDERID =pv_orderid;
        Update ODMAST set ORSTATUS ='5' where Orderqtty =Remainqtty And ORDERID =pv_orderid;

      End if;
      --3 CAP NHAT TRAN VA MAST
      IF v_tltxcd = '8890' OR v_tltxcd = '8808'
      THEN
         --BUY
         UPDATE odmast
            SET cancelqtty = cancelqtty + v_cancelqtty,
                remainqtty = remainqtty - v_cancelqtty
          WHERE orderid = pv_orderid;

/*
         UPDATE odmast
            SET
            rlssecured = rlssecured +
            v_cancelqtty * v_price * v_oldbratio / 100
          WHERE orderid = pv_orderid;


         UPDATE cimast
            SET balance = balance + v_cancelqtty * v_price * v_oldbratio / 100,
                bamt = bamt - v_cancelqtty * v_price * v_oldbratio / 100
          WHERE acctno = v_afaccount;
*/
         INSERT INTO odtran
                     (txnum, txdate,
                      acctno, txcd, namt, camt, acctref, deltd,
                      REF, autoid
                     )
              VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'),
                      pv_orderid, '0014', v_cancelqtty, NULL, NULL, 'N',
                      NULL, seq_odtran.NEXTVAL
                     );

         INSERT INTO odtran
                     (txnum, txdate,
                      acctno, txcd, namt, camt, acctref, deltd,
                      REF, autoid
                     )
              VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'),
                      pv_orderid, '0011', v_cancelqtty, NULL, NULL, 'N',
                      NULL, seq_odtran.NEXTVAL
                     );

/*
         INSERT INTO odtran
                     (txnum, txdate,
                      acctno, txcd,
                      namt, camt, acctref,
                      deltd, REF, autoid
                     )
              VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'),
                      pv_orderid, '0030',
                      v_cancelqtty * v_price * v_oldbratio / 100, NULL, NULL,
                      'N', NULL, seq_odtran.NEXTVAL
                     );


         INSERT INTO citran
                     (txnum, txdate, acctno,
                      txcd, namt,
                      camt, REF, deltd, acctref, autoid
                     )
              VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'), v_afaccount,
                      '0012', v_cancelqtty * v_price * v_oldbratio / 100,
                      NULL, pv_orderid, 'N', NULL, seq_citran.NEXTVAL
                     );

         INSERT INTO citran
                     (txnum, txdate, acctno,
                      txcd, namt,
                      camt, REF, deltd, acctref, autoid
                     )
              VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'), v_afaccount,
                      '0017', v_cancelqtty * v_price * v_oldbratio / 100,
                      NULL, pv_orderid, 'N', NULL, seq_citran.NEXTVAL
                     );
*/
      ELSE                                                   --v_tltxcd='8891' , '8807'
         --SELL
         UPDATE odmast
            SET cancelqtty = cancelqtty + v_cancelqtty,
                remainqtty = remainqtty - v_cancelqtty
          WHERE orderid = pv_orderid;

/* Khong cap nhat Ky quy, Trade
         If v_trExectype ='MS' Then
             UPDATE semast
                SET MORTAGE = MORTAGE + v_cancelqtty
                ,secured = secured - v_cancelqtty
              WHERE acctno = v_seacctno;

         Else
             UPDATE semast
                SET trade = trade + v_cancelqtty,
                    secured = secured - v_cancelqtty
              WHERE acctno = v_seacctno;
         End if;
*/
         INSERT INTO odtran
                     (txnum, txdate,
                      acctno, txcd, namt, camt, acctref, deltd,
                      REF, autoid
                     )
              VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'),
                      pv_orderid, '0014', v_cancelqtty, NULL, NULL, 'N',
                      NULL, seq_odtran.NEXTVAL
                     );

         INSERT INTO odtran
                     (txnum, txdate,
                      acctno, txcd, namt, camt, acctref, deltd,
                      REF, autoid
                     )
              VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'),
                      pv_orderid, '0011', v_cancelqtty, NULL, NULL, 'N',
                      NULL, seq_odtran.NEXTVAL
                     );
/*
         INSERT INTO setran
                     (txnum, txdate, acctno,
                      txcd, namt, camt, REF, deltd,
                      autoid
                     )
              VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'), v_seacctno,
                      '0012', v_cancelqtty, NULL, pv_orderid, 'N',
                      seq_setran.NEXTVAL
                     );

         INSERT INTO setran
                     (txnum, txdate, acctno,
                      txcd, namt, camt, REF, deltd,
                      autoid
                     )
              VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'), v_seacctno,
                      '0018', v_cancelqtty, NULL, pv_orderid, 'N',
                      seq_setran.NEXTVAL
                     );
*/
      END IF;

   COMMIT;
EXCEPTION
   WHEN others
   THEN
   ROLLBACK;
   v_err:=substr(sqlerrm,1,200);
      INSERT INTO log_err
                  (id,date_log, POSITION, text
                  )
           VALUES ( seq_log_err.NEXTVAL,SYSDATE, ' confirm_cancel_normal_order ', v_err
                  );

      COMMIT;

END;

 
 
 
 
/
