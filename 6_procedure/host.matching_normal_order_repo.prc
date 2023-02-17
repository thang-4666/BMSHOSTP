SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE matching_normal_order_repo
   (
                    order_number       IN   varchar2,
                    deal_volume        IN   NUMBER,
                    deal_price         IN   NUMBER,
                    deal_amt           IN   NUMBER,
                    deal_feeamt        IN   NUMBER
                    )
IS

v_tltxcd             VARCHAR2 (30);
    v_txnum              VARCHAR2 (30);
    v_txdate             VARCHAR2 (30);
    v_tlid               VARCHAR2 (30);
    v_brid               VARCHAR2 (30);
    v_ipaddress          VARCHAR2 (30);
    v_wsname             VARCHAR2 (30);
    v_txtime             VARCHAR2 (30);
    mv_strorgorderid     VARCHAR2 (30);
    mv_strcodeid         VARCHAR2 (30);
    mv_strsymbol         VARCHAR2 (30);
    mv_strcustodycd      VARCHAR2 (30);
    mv_strbors           VARCHAR2 (30);
    mv_strnorp           VARCHAR2 (30);
    mv_straorn           VARCHAR2 (30);
    mv_strafacctno       VARCHAR2 (30);
    mv_strciacctno       VARCHAR2 (30);
    mv_strseacctno       VARCHAR2 (30);
    mv_reforderid        VARCHAR2 (30);
    mv_refcustcd         VARCHAR2 (30);
    mv_strclearcd        VARCHAR2 (30);
    mv_strexprice        NUMBER (10);
    mv_strexqtty         NUMBER (10);
    mv_strprice          NUMBER (10);
    mv_strqtty           NUMBER (10);
    mv_strremainqtty     NUMBER (10);
    mv_strclearday       NUMBER (10);
    mv_strsecuredratio   NUMBER (10,2);
    ---mv_strconfirm_no     VARCHAR2 (30);
    mv_strmatch_date     VARCHAR2 (30);
    mv_desc              VARCHAR2 (30);
    v_strduetype         VARCHAR (2);
    v_matched            NUMBER (10,2);
    v_ex                 EXCEPTION;
    v_err                VARCHAR2 (100);
    v_temp               NUMBER(10);
    ---v_refconfirmno       VARCHAR2 (30);
    mv_mtrfday                NUMBER(10);
    l_trfbuyext          number(10);
    mv_strtradeplace     VARCHAR2(3);
    v_strcorebank char(1);
   -- Declare program variables as shown above
BEGIN

   --  Set transaction read write;

    --0 lay cac tham so
    v_brid := '0000';
    v_tlid := '0000';
    v_ipaddress := 'HOST';
    v_wsname := 'HOST';
    v_tltxcd := '8804';
    --TungNT modified - for T2 late send money
    mv_strtradeplace:='001';
    --End

    SELECT    '8080'
    || SUBSTR ('000000' || seq_batchtxnum.NEXTVAL,
               LENGTH ('000000' || seq_batchtxnum.NEXTVAL) - 5,
               6
              )
    INTO v_txnum
    FROM DUAL;

    SELECT TO_CHAR (SYSDATE, 'HH24:MI:SS')
    INTO v_txtime
    FROM DUAL;

    BEGIN
        SELECT varvalue
        INTO v_txdate
        FROM sysvar
        WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    EXCEPTION
    WHEN OTHERS    THEN
        Return;
    END;
    mv_strorgorderid := order_number;
    --Lay thong tin lenh goc
    BEGIN
      SELECT od.remainqtty, sb.codeid, sb.symbol, ood.custodycd,
             ood.bors, ood.norp, ood.aorn, od.afacctno,
             od.ciacctno, od.seacctno, '', '',
             od.clearcd, ood.price, ood.qtty, deal_price ,
             deal_volume, od.clearday, od.bratio,
              v_txdate, '', typ.mtrfday,
             ss.tradeplace
        INTO mv_strremainqtty, mv_strcodeid, mv_strsymbol, mv_strcustodycd,
             mv_strbors, mv_strnorp, mv_straorn, mv_strafacctno,
             mv_strciacctno, mv_strseacctno, mv_reforderid, mv_refcustcd,
             mv_strclearcd, mv_strexprice, mv_strexqtty, mv_strprice,
             mv_strqtty, mv_strclearday, mv_strsecuredratio,
              mv_strmatch_date, mv_desc,mv_mtrfday,
             mv_strtradeplace
        FROM odmast od, ood, securities_info sb,odtype typ,afmast af,sbsecurities ss
       WHERE od.orderid = ood.orgorderid and od.actype = typ.actype
         AND od.codeid = sb.codeid and od.afacctno=af.acctno and od.codeid=ss.codeid
         AND orderid = mv_strorgorderid;
    EXCEPTION    WHEN OTHERS    THEN
        RETURN;
    END;
    mv_desc := 'Matching order';
    IF mv_strremainqtty >= mv_strqtty
    THEN
        --thuc hien khop voi ket qua tra ve
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
            '', '', '1', mv_strorgorderid, mv_strqtty, '',
            '', 'N', 'N', TO_DATE (v_txdate, 'DD/MM/YYYY'),
            TO_DATE (v_txdate, 'DD/MM/YYYY'), '', '', v_ipaddress,
            v_wsname, 'DAY', mv_desc
           );

    --tHEM VAO TRONG TLLOGFLD
      INSERT INTO tllogfld
                  (autoid, txnum,
                   txdate, fldcd, nvalue,
                   cvalue, txdesc
                  )
           VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                   TO_DATE (v_txdate, 'DD/MM/YYYY'), '03', 0,
                   mv_strorgorderid, NULL
                  );

      INSERT INTO tllogfld
                  (autoid, txnum,
                   txdate, fldcd, nvalue, cvalue,
                   txdesc
                  )
           VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                   TO_DATE (v_txdate, 'DD/MM/YYYY'), '80', 0, mv_strcodeid,
                   NULL
                  );

      INSERT INTO tllogfld
                  (autoid, txnum,
                   txdate, fldcd, nvalue, cvalue,
                   txdesc
                  )
           VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                   TO_DATE (v_txdate, 'DD/MM/YYYY'), '81', 0, mv_strsymbol,
                   NULL
                  );

      INSERT INTO tllogfld
                  (autoid, txnum,
                   txdate, fldcd, nvalue,
                   cvalue, txdesc
                  )
           VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                   TO_DATE (v_txdate, 'DD/MM/YYYY'), '82', 0,
                   mv_strcustodycd, NULL
                  );

      INSERT INTO tllogfld
                  (autoid, txnum,
                   txdate, fldcd, nvalue, cvalue,
                   txdesc
                  )
           VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                   TO_DATE (v_txdate, 'DD/MM/YYYY'), '04', 0, mv_strafacctno,
                   NULL
                  );

      INSERT INTO tllogfld
                  (autoid, txnum,
                   txdate, fldcd, nvalue, cvalue,
                   txdesc
                  )
           VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                   TO_DATE (v_txdate, 'DD/MM/YYYY'), '11', mv_strqtty, NULL,
                   NULL
                  );

      INSERT INTO tllogfld
                  (autoid, txnum,
                   txdate, fldcd, nvalue, cvalue,
                   txdesc
                  )
           VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                   TO_DATE (v_txdate, 'DD/MM/YYYY'), '10', mv_strprice, NULL,
                   NULL
                  );

      INSERT INTO tllogfld
                  (autoid, txnum,
                   txdate, fldcd, nvalue, cvalue, txdesc
                  )
           VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                   TO_DATE (v_txdate, 'DD/MM/YYYY'), '30', 0, mv_desc, NULL
                  );
      INSERT INTO tllogfld
                  (autoid, txnum,
                   txdate, fldcd, nvalue, cvalue, txdesc
                  )
           VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                   TO_DATE (v_txdate, 'DD/MM/YYYY'), '05', 0, mv_strafacctno, NULL
                  );
        INSERT INTO tllogfld
                  (autoid, txnum,
                   txdate, fldcd, nvalue, cvalue, txdesc
                  )
           VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                   TO_DATE (v_txdate, 'DD/MM/YYYY'), '16', 0, NULL, NULL
                  );
      IF mv_strbors = 'B' THEN
          INSERT INTO tllogfld
                  (autoid, txnum,
                   txdate, fldcd, nvalue, cvalue, txdesc
                  )
           VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                   TO_DATE (v_txdate, 'DD/MM/YYYY'), '86', mv_strprice*mv_strqtty, NULL, NULL
                  );

          INSERT INTO tllogfld
                  (autoid, txnum,
                   txdate, fldcd, nvalue, cvalue, txdesc
                  )
           VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                   TO_DATE (v_txdate, 'DD/MM/YYYY'), '87', mv_strqtty, NULL, NULL
                  );
      ELSE
          INSERT INTO tllogfld
                  (autoid, txnum,
                   txdate, fldcd, nvalue, cvalue, txdesc
                  )
           VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                   TO_DATE (v_txdate, 'DD/MM/YYYY'), '86', 0, NULL, NULL
                  );

          INSERT INTO tllogfld
                  (autoid, txnum,
                   txdate, fldcd, nvalue, cvalue, txdesc
                  )
           VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                   TO_DATE (v_txdate, 'DD/MM/YYYY'), '87', 0, NULL, NULL
                  );
      END IF;
        --3 THEM VAO TRONG IOD
        INSERT INTO iod
           (orgorderid, codeid, symbol,
            custodycd, bors, norp,
            txdate, txnum, aorn,
            price, qtty, exorderid, refcustcd,
            matchprice, matchqtty, confirm_no,txtime
           )
        VALUES (mv_strorgorderid, mv_strcodeid, mv_strsymbol,
            mv_strcustodycd, mv_strbors, mv_strnorp,
            TO_DATE (v_txdate, 'DD/MM/YYYY'), v_txnum, mv_straorn,
            mv_strexprice, mv_strexqtty, mv_reforderid, mv_refcustcd,
            mv_strprice, mv_strqtty, NULL,to_char(sysdate,'hh24:mi:ss')
           );
        --4 CAP NHAT STSCHD
        SELECT COUNT (*)
        INTO v_matched
        FROM stschd
        WHERE orgorderid = mv_strorgorderid AND deltd <> 'Y';
        IF mv_strbors = 'B'
        THEN                                                          --Lenh mua
        --Tao lich thanh toan chung khoan
        v_strduetype := 'RS';
        IF v_matched > 0
        THEN
           UPDATE stschd
              SET qtty = qtty + mv_strqtty,
                  amt = amt + deal_amt
            WHERE orgorderid = mv_strorgorderid AND duetype = v_strduetype;
        ELSE
           INSERT INTO stschd
                       (autoid, orgorderid, codeid,
                        duetype, afacctno, acctno,
                        reforderid, txnum,
                        txdate, clearday,
                        clearcd, amt, aamt,
                        qtty, aqtty, famt, status, deltd, costprice, cleardate
                       )
                VALUES (seq_stschd.NEXTVAL, mv_strorgorderid, mv_strcodeid,
                        v_strduetype, mv_strafacctno, mv_strseacctno,
                        mv_reforderid, v_txnum,
                        TO_DATE (v_txdate, 'DD/MM/YYYY'), mv_strclearday,
                        mv_strclearcd, deal_amt, 0,
                        mv_strqtty, 0, 0, 'N', 'N', 0, getduedate(TO_DATE (v_txdate, 'DD/MM/YYYY'),mv_strclearcd,/*'000'*/mv_strtradeplace,mv_strclearday)--ngoc.vu-Jira561
                       );
        END IF;
        --Tao lich thanh toan tien
        select case when mrt.mrtype <> 'N' and aft.istrfbuy <> 'N' then trfbuyext
           else 0 end into l_trfbuyext
        from afmast af, aftype aft, mrtype mrt
        where af.actype = aft.actype and aft.mrtype = mrt.actype and af.acctno = mv_strafacctno;
        v_strduetype := 'SM';
        IF v_matched > 0
        THEN
           UPDATE stschd
              SET qtty = qtty + mv_strqtty,
                  amt = amt + deal_amt
            WHERE orgorderid = mv_strorgorderid AND duetype = v_strduetype;
        ELSE
           INSERT INTO stschd
                       (autoid, orgorderid, codeid,
                        duetype, afacctno, acctno,
                        reforderid, txnum,
                        txdate, clearday,
                        clearcd, amt, aamt,
                        qtty, aqtty, famt, status, deltd, costprice, cleardate
                       )
                VALUES (seq_stschd.NEXTVAL, mv_strorgorderid, mv_strcodeid,
                        v_strduetype, mv_strafacctno, mv_strafacctno,
                        mv_reforderid, v_txnum,
                        TO_DATE (v_txdate, 'DD/MM/YYYY'), least(mv_mtrfday,l_trfbuyext),
                        mv_strclearcd, deal_amt, 0,
                        mv_strqtty, 0, 0, 'N', 'N', 0, getduedate(TO_DATE (v_txdate, 'DD/MM/YYYY'),mv_strclearcd,/*'000'*/mv_strtradeplace,least(mv_mtrfday,l_trfbuyext)) --ngoc.vu-Jira561
                       );
        END IF;

        ELSE                                                          --Lenh ban
        --Tao lich thanh toan chung khoan
        v_strduetype := 'SS';
        IF v_matched > 0
        THEN
           UPDATE stschd
              SET qtty = qtty + mv_strqtty,
                  amt = amt + deal_amt
            WHERE orgorderid = mv_strorgorderid AND duetype = v_strduetype;
        ELSE
           INSERT INTO stschd
                       (autoid, orgorderid, codeid,
                        duetype, afacctno, acctno,
                        reforderid, txnum,
                        txdate, clearday,
                        clearcd, amt, aamt,
                        qtty, aqtty, famt, status, deltd, costprice, cleardate
                       )
                VALUES (seq_stschd.NEXTVAL, mv_strorgorderid, mv_strcodeid,
                        v_strduetype, mv_strafacctno, mv_strseacctno,
                        mv_reforderid, v_txnum,
                        TO_DATE (v_txdate, 'DD/MM/YYYY'), 0,
                        mv_strclearcd, deal_amt, 0,
                        mv_strqtty, 0, 0, 'N', 'N', 0, getduedate(TO_DATE (v_txdate, 'DD/MM/YYYY'),mv_strclearcd,/*'000'*/mv_strtradeplace,0) --ngoc.vu-Jira561
                       );
        END IF;
        --Tao lich thanh toan tien
        v_strduetype := 'RM';
            IF v_matched > 0
            THEN
               UPDATE stschd
                  SET qtty = qtty + mv_strqtty,
                      amt = amt + deal_amt
                WHERE orgorderid = mv_strorgorderid AND duetype = v_strduetype;
            ELSE
               INSERT INTO stschd
                           (autoid, orgorderid, codeid,
                            duetype, afacctno, acctno,
                            reforderid, txnum,
                            txdate, clearday,
                            clearcd, amt, aamt,
                            qtty, aqtty, famt, status, deltd, costprice, cleardate
                           )
                    VALUES (seq_stschd.NEXTVAL, mv_strorgorderid, mv_strcodeid,
                            v_strduetype, mv_strafacctno, mv_strafacctno,
                            mv_reforderid, v_txnum,
                            TO_DATE (v_txdate, 'DD/MM/YYYY'), mv_strclearday,
                            mv_strclearcd, deal_amt, 0,
                            mv_strqtty, 0, 0, 'N', 'N', 0, getduedate(TO_DATE (v_txdate, 'DD/MM/YYYY'),mv_strclearcd,/*'000'*/mv_strtradeplace,mv_strclearday) --ngoc.vu-Jira561
                           );
            END IF;
        END IF;
        UPDATE odmast
        SET orstatus = '4',
        PORSTATUS = PORSTATUS || '4',
        execqtty = execqtty + mv_strqtty,
        remainqtty = remainqtty - mv_strqtty,
        execamt = execamt + deal_amt,
        matchamt = matchamt + deal_amt,
        feeacr = deal_feeamt
        WHERE orderid = mv_strorgorderid;
        UPDATE ood
        SET oodstatus = 'S'
        WHERE orgorderid = mv_strorgorderid;
        For v_Session in (SELECT SYSVALUE  FROM ORDERSYS WHERE SYSNAME = 'CONTROLCODE')
        Loop
            UPDATE odmast
            SET HOSESESSION =v_Session.SYSVALUE
            WHERE orderid = mv_strorgorderid And NVL(HOSESESSION,'N') ='N';
        End Loop;
        --Neu khop het va co lenh huy cua lenh da khop thi cap nhat thanh refuse
        IF mv_strremainqtty = mv_strqtty THEN
            UPDATE odmast
            SET ORSTATUS = '0'
            WHERE REFORDERID = mv_strorgorderid;
        END IF;
        --Cap nhat tinh gia von
        IF mv_strbors = 'B' THEN
            UPDATE semast
            SET dcramt = dcramt + deal_amt, dcrqtty = dcrqtty+mv_strqtty
            WHERE acctno = mv_strseacctno;
        END IF;
        INSERT INTO odtran
           (txnum, txdate,
            acctno, txcd, namt, camt, acctref, deltd,
            REF, autoid
           )
        VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'),
            mv_strorgorderid, '0013', mv_strqtty, NULL, NULL, 'N',
            NULL, seq_odtran.NEXTVAL
           );

        INSERT INTO odtran
           (txnum, txdate,
            acctno, txcd, namt, camt, acctref, deltd,
            REF, autoid
           )
        VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'),
            mv_strorgorderid, '0011', mv_strqtty, NULL, NULL, 'N',
            NULL, seq_odtran.NEXTVAL
           );
        INSERT INTO odtran
           (txnum, txdate,
            acctno, txcd, namt, camt,
            acctref, deltd, REF, autoid
           )
        VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'),
            mv_strorgorderid, '0028', deal_amt, NULL,
            NULL, 'N', NULL, seq_odtran.NEXTVAL
           );
        INSERT INTO odtran
           (txnum, txdate,
            acctno, txcd, namt, camt,
            acctref, deltd, REF, autoid
           )
        VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'),
            mv_strorgorderid, '0034', deal_amt, NULL,
            NULL, 'N', NULL, seq_odtran.NEXTVAL
           );
        IF mv_strbors = 'B' THEN
            INSERT INTO setran
                   (txnum, txdate,
                    acctno, txcd, namt, camt,
                    REF, deltd, autoid
                   )
            VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'),
                    mv_strseacctno, '0051', deal_amt, NULL,
                    NULL, 'N', seq_setran.NEXTVAL
                   );
            INSERT INTO setran
                   (txnum, txdate,
                    acctno, txcd, namt, camt,
                    REF, deltd, autoid
                   )
            VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'),
                    mv_strseacctno, '0052', mv_strqtty, NULL,
                    NULL, 'N', seq_setran.NEXTVAL
                   );
        END IF;
    END IF;
    --commit;
EXCEPTION
   WHEN OTHERS THEN
        BEGIN
            dbms_output.put_line('Error... ');
            rollback;
            raise;
            return;
        END;
END;
 
 
 
 
/
