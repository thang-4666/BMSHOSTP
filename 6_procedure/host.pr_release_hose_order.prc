SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE pr_release_hose_order
IS
  pkgctx     plog.log_ctx;
  logrow     tlogdebug%ROWTYPE;
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
   pv_orderid         VARCHAR2(100);
BEGIN

 --Init log
  SELECT *
    INTO logrow
    FROM tlogdebug
   WHERE rownum <= 1;

  pkgctx := plog.init('ReleaseHOOrders',

                      plevel => logrow.loglevel,

                      plogtable => (logrow.log4table = 'Y'),

                      palert => (logrow.log4alert = 'Y'),

                      ptrace => (logrow.log4trace = 'Y'));

  plog.setbeginsection(pkgctx, 'ReleaseHOOrders');

  plog.error(pkgctx, 'Start releasing');


   --0 lay cac tham so
   v_brid := '0000';
   v_tlid := '0000';
   v_ipaddress := 'HOST';
   v_wsname := 'HOST';
   --v_cancelqtty := pv_qtty;
         --NEU CHAU BI HUY THI KHI NHAN DUOC MESSAGE TRA VE SE THUC HIEN HUY LENH
      SELECT varvalue
        INTO v_txdate
        FROM sysvar
       WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';


   FOR I IN(SELECT      CCY.SYMBOL, MST.*
            FROM        ODMAST MST, AFMAST AF, CFMAST CF, SBSECURITIES CCY
            WHERE       MST.AFACCTNO = AF.ACCTNO
                        AND MST.REMAINQTTY>0 AND MST.DELTD<> 'Y'
                        AND AF.CUSTID = CF.CUSTID AND MST.CODEID = CCY.CODEID
                        AND MST.ORSTATUS IN ('1', '2', '4','8')
                        AND MST.ORDERQTTY <> MST.EXECQTTY
                        AND CCY.TRADEPLACE = '001'
                        and txdate = to_date(v_txdate, 'dd/mm/yyyy')
                        AND MST.EXECTYPE IN ('NB','NS','MS') AND MATCHTYPE <> 'P')
   LOOP

   V_ORDERQTTY_CUR := I.ORDERQTTY;
   V_REMAINQTTY_CUR := I.REMAINQTTY;
   V_EXECQTTY_CUR := I.EXECQTTY;
   V_CANCELQTTY_CUR := I.CANCELQTTY;
   V_ORSTATUS_CUR := I.ORSTATUS;
   v_trExectype := I.EXECTYPE;
   pv_orderid := I.ORDERID;
   v_symbol := I.SYMBOL;
   v_seacctno := I.AFACCTNO || I.CODEID;
   v_afaccount := I.AFACCTNO;
   v_price := I.QUOTEPRICE;
  -- dbms_output.put_line('2');

   IF V_REMAINQTTY_CUR - V_CANCELQTTY_CUR < 0 OR V_EXECQTTY_CUR >= V_ORDERQTTY_CUR
                 OR V_CANCELQTTY = 0
   THEN
--      dbms_output.put_line(I.ORDERID || ' ' || V_REMAINQTTY_CUR||' ' ||V_CANCELQTTY || ' '|| V_EXECQTTY_CUR || ' ' || V_ORDERQTTY_CUR);
         INSERT INTO log_err
                  (id,date_log, POSITION, text
                  )
           VALUES ( seq_log_err.NEXTVAL,SYSDATE, ' confirm_cancel_normal_order ', I.ORDERID || ' ' || V_REMAINQTTY_CUR||' ' ||V_CANCELQTTY || ' '|| V_EXECQTTY_CUR || ' ' || V_ORDERQTTY_CUR || ' Not enough quantity to release'
                  );
    RETURN;
   END IF;

    v_cancelqtty := V_REMAINQTTY_CUR;

    IF V_TREXECTYPE = 'NB' THEN
        V_TLTXCD := '8808';
    ELSE
        V_TLTXCD := '8807';
    END IF;

   SELECT bratio
     INTO v_oldbratio
     FROM odmast
    WHERE orderid = pv_orderid;

      SELECT    '7000'
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
                   '', '', '1', pv_orderid, v_cancelqtty, '',
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
      VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/YYYY'),'12',V_ORDERQTTY_CUR,NULL,NULL);
      --2 THEM VAO TRONG TLLOGFLD

      --3 CAP NHAT TRAN VA MAST
      dbms_output.put_line(pv_orderid);
         UPDATE odmast
            SET ORSTATUS = '5',
                cancelqtty = cancelqtty + v_cancelqtty,
                remainqtty = remainqtty - v_cancelqtty
          WHERE orderid = pv_orderid;
   END LOOP;

  plog.setendsection(pkgctx, 'Finish releasing');
   --COMMIT;
EXCEPTION
   WHEN others
   THEN
  plog.setendsection(pkgctx, 'Finish releasing with exception');
   ROLLBACK;
   v_err:=substr(sqlerrm,1,200);
      INSERT INTO log_err
                  (id,date_log, POSITION, text
                  )
           VALUES ( seq_log_err.NEXTVAL,SYSDATE, ' pr_release_hose_order ', v_err
                  );
  plog.setendsection(pkgctx, v_err);
      --COMMIT;

END;
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
