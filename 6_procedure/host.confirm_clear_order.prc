SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CONFIRM_CLEAR_ORDER" (
   pv_orderid   IN   VARCHAR2
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
   v_codeid         VARCHAR2 (30);
   v_afaccount        VARCHAR2 (30);
   v_seacctno         VARCHAR2 (30);
   v_price            NUMBER (10,2);
   v_quantity         NUMBER (10,2);
   v_bratio           NUMBER (10,2);
   v_clearqtty       NUMBER (10,2);
   v_matchedqtty      NUMBER (10,2);
   v_advancedamount   NUMBER (10,2);
   v_execqtty         NUMBER (10,2);
   v_securedAmount   NUMBER (10,2);
   v_parvalue         NUMBER (10,2);
   v_reforderid       VARCHAR2 (30);
   v_tradeunit        NUMBER (10,2);
   v_desc             VARCHAR2 (300);
   v_bors             VARCHAR2 (30);
   v_txtime           VARCHAR2 (30);
   v_orstatus       char (1);
BEGIN
   --0 lay cac tham so
   v_brid := '0000';
   v_tlid := '0000';
   v_ipaddress := 'HOST';
   v_wsname := 'HOST';
   SELECT (CASE
              WHEN exectype in ('NB','BC')
                 THEN '8808'
              ELSE '8807'
           END), sb.symbol,sb.codeid,
          od.afacctno, od.seacctno, od.quoteprice, od.REMAINQTTY, od.bratio,
          od.reforderid, sb.tradeunit, od.edstatus,od.SECUREDAMT-od.RLSSECURED,sec.PARVALUE,'5'
     INTO v_tltxcd, v_symbol,v_codeid,
          v_afaccount, v_seacctno, v_price, v_quantity, v_bratio,
          v_reforderid, v_tradeunit, v_edstatus,v_securedAmount,v_parvalue,v_orstatus
     FROM odmast od, securities_info sb,sbsecurities sec
    WHERE od.codeid = sb.codeid and sec.codeid = sb.codeid  AND orderid = pv_orderid;

   v_advancedamount := 0;

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
      if v_tltxcd='8807'   then
            v_desc:='Clear sell putthrought order';
      else
            v_desc:='Clear buy putthrought order';
      end if;

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
                   '', '', '1', v_reforderid, v_quantity, '',
                   '', 'N', 'N', TO_DATE (v_txdate, 'DD/MM/YYYY'),
                   TO_DATE (v_txdate, 'DD/MM/YYYY'), '', '', v_ipaddress,
                   v_wsname, 'DAY', v_desc
                  );
      --2.them vao tllogfld
      INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
      VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/YYYY'),'03',0,pv_orderid,NULL);
      INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
      VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/YYYY'),'05',0,v_afaccount,NULL);
      INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
      VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/YYYY'),'06',0,v_seacctno,NULL);
      INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
      VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/YYYY'),'07',0,v_afaccount,NULL);
      INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
      VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/YYYY'),'10',v_quantity,NULL,NULL);
      INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
      VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/YYYY'),'11',v_securedAmount,NULL,NULL);
      INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
      VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/YYYY'),'12',v_parvalue,NULL,NULL);
      INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
      VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/YYYY'),'13',v_price,NULL,NULL);
      INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
      VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/YYYY'),'15',0,v_orstatus,NULL);
      INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
      VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/YYYY'),'30',0,v_desc,NULL);
      INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
      VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/YYYY'),'80',0,v_codeid,NULL);
      INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
      VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/YYYY'),'81',0,v_symbol,NULL);


      --3 CAP NHAT TRAN VA MAST
      IF v_tltxcd = '8807'
      THEN
         --sell
         UPDATE odmast
            SET ORSTATUS = v_orstatus,
                remainqtty = remainqtty - v_quantity,
                CANCELQTTY = CANCELQTTY + v_quantity
          WHERE orderid = pv_orderid;

/*
         UPDATE semast
            SET secured=secured -v_quantity, trade=trade + v_quantity
          WHERE acctno = v_seacctno;
*/
         INSERT INTO odtran
                     (txnum, txdate,
                      acctno, txcd, namt, camt, acctref, deltd,
                      REF, autoid
                     )
              VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'),
                      pv_orderid, '0014', v_quantity, NULL, NULL, 'N',
                      NULL, seq_odtran.NEXTVAL
                     );

         INSERT INTO odtran
                     (txnum, txdate,
                      acctno, txcd, namt, camt, acctref, deltd,
                      REF, autoid
                     )
              VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'),
                      pv_orderid, '0011', v_quantity, NULL, NULL, 'N',
                      NULL, seq_odtran.NEXTVAL
                     );
/*

        INSERT INTO setran
                     (txnum, txdate, acctno,
                      txcd, namt, camt, REF, deltd,
                      autoid
                     )
              VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'), v_seacctno,
                      '0018', v_quantity, NULL, pv_orderid, 'N',
                      seq_setran.NEXTVAL
                     );

        INSERT INTO setran
                     (txnum, txdate, acctno,
                      txcd, namt, camt, REF, deltd,
                      autoid
                     )
              VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'), v_seacctno,
                      '0045', v_quantity, NULL, pv_orderid, 'N',
                      seq_setran.NEXTVAL
                     );
*/
      ELSE--v_tltxcd='8808'
         --release buy
         UPDATE odmast
            SET ORSTATUS = v_orstatus,
                remainqtty = remainqtty - v_quantity,
                CANCELQTTY = CANCELQTTY + v_quantity,
                RLSSECURED=RLSSECURED+v_securedAmount
          WHERE orderid = pv_orderid;

/*
         UPDATE cimast
            SET balance=balance + v_securedAmount, bamt=bamt-v_securedAmount
          WHERE acctno = v_afaccount;
*/
         INSERT INTO odtran
                     (txnum, txdate,
                      acctno, txcd, namt, camt, acctref, deltd,
                      REF, autoid
                     )
              VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'),
                      pv_orderid, '0014', v_quantity, NULL, NULL, 'N',
                      NULL, seq_odtran.NEXTVAL
                     );

         INSERT INTO odtran
                     (txnum, txdate,
                      acctno, txcd, namt, camt, acctref, deltd,
                      REF, autoid
                     )
              VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'),
                      pv_orderid, '0011', v_quantity, NULL, NULL, 'N',
                      NULL, seq_odtran.NEXTVAL
                     );
         INSERT INTO odtran
                     (txnum, txdate,
                      acctno, txcd, namt, camt, acctref, deltd,
                      REF, autoid
                     )
              VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'),
                      pv_orderid, '0030', v_securedAmount, NULL, NULL, 'N',
                      NULL, seq_odtran.NEXTVAL
                     );

/*

        INSERT INTO citran
                     (txnum, txdate, acctno,
                      txcd, namt,
                      camt, REF, deltd, acctref, autoid
                     )
              VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'), v_afaccount,
                      '0012', v_securedAmount,
                      NULL, pv_orderid, 'N', NULL, seq_citran.NEXTVAL
                     );

         INSERT INTO citran
                     (txnum, txdate, acctno,
                      txcd, namt,
                      camt, REF, deltd, acctref, autoid
                     )
              VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'), v_afaccount,
                      '0017', v_securedAmount,
                      NULL, pv_orderid, 'N', NULL, seq_citran.NEXTVAL
                     );
*/
      END IF;

    --Cap nhat trang thai cua OOD
    UPDATE OOD SET OODSTATUS='E' WHERE ORGORDERID=pv_orderid AND OODSTATUS<>'E';

    --CAP NHAT TRANG THAI CUA ODQUEUE
    UPDATE ODQUEUE SET DELTD='Y' WHERE TRIM(ORGORDERID)=pv_orderid;
    COMMIT;
END;

 
 
 
 
/
