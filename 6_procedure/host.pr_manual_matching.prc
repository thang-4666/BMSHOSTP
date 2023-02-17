SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE pr_manual_matching(p_strOrderId VARCHAR2, p_nbrMatchQtty NUMBER, p_nbrMatchPrice NUMBER)
   IS

   pkgctx   plog.log_ctx:= plog.init ('pr_manual_matching',
                 plevel => 30,
                 plogtable => true,
                 palert => false,
                 ptrace => false);
   logrow   tlogdebug%ROWTYPE;

   v_brid       varchar2(10);
   v_tlid       varchar2(10);
   v_ipaddress  varchar2(50);
   v_wsname     varchar2(50);
   v_tltxcd     varchar2(10);
   v_RemainQtty number(20);
   v_txnum      varchar2(10);
   v_txdate     varchar2(20);
   v_txtime     varchar2(20);
   v_txdesc     varchar2(2000);
   v_matched    number(20);
   v_strduetype varchar2(20);
   v_mtrfday    number(10);
   l_trfbuyext  number(10);
   v_temp       number(10);

   Cursor c_SqlMaster Is
        SELECT      OD.ORDERID,OD.CODEID,SEC.SYMBOL,CF.CUSTODYCD,OD.AFACCTNO,OD.SEACCTNO,OD.CIACCTNO,SUBSTR(OD.EXECTYPE,2,1) BORS,null NORP,OD.NORK AORN,
                    OD.QUOTEPRICE EXPRICE, OD.ORDERQTTY EXQTTY, OD.ORDERQTTY QTTY,OD.QUOTEPRICE PRICE,OD.ORDERID REFORDERID,
                    'SY' ||OD.ORDERID CONFIRM_NO, OD.BRATIO,OD.CLEARDAY,OD.CLEARCD,SEC.TRADEPLACE,
                    CF.CUSTODYCD || '.' || OD.EXECTYPE || '.' || SEC.SYMBOL || '.' || OD.ORDERQTTY || '.' || OD.QUOTEPRICE  DESCRIPTION
        FROM        ODMAST OD,SBSECURITIES SEC, AFMAST AF, CFMAST CF
        WHERE       OD.CODEID=SEC.CODEID AND SEC.TRADEPLACE<>'005' AND OD.AFACCTNO = AF.ACCTNO AND AF.CUSTID = CF.CUSTID
                    AND OD.ORDERID = p_strOrderId;

   Cursor c_Odmast(v_OrgOrderID Varchar2) Is
   SELECT FOACCTNO,REMAINQTTY,EXECQTTY,EXECAMT,CANCELQTTY,ADJUSTQTTY
   FROM ODMAST WHERE TIMETYPE ='G' AND ORDERID=v_OrgOrderID;
   vc_Odmast c_Odmast%Rowtype;

   Cursor c_Odmast_check(v_OrgOrderID Varchar2) Is
   SELECT FOACCTNO,REMAINQTTY,EXECQTTY,EXECAMT,CANCELQTTY,ADJUSTQTTY
   FROM ODMAST WHERE ORDERID=v_OrgOrderID;

   BEGIN

   FOR i IN (SELECT *
             FROM tlogdebug)
   LOOP
      logrow.loglevel    := i.loglevel;
      logrow.log4table   := i.log4table;
      logrow.log4alert   := i.log4alert;
      logrow.log4trace   := i.log4trace;
   END LOOP;

   -- plog.error('level1: ' || logrow.loglevel);
   pkgctx    :=
      plog.init ('pr_manual_matching',
                 plevel => NVL (logrow.loglevel, 30),
                 plogtable => (NVL (logrow.log4table, 'N') = 'Y'),
                 palert => (NVL (logrow.log4alert, 'N') = 'Y'),
                 ptrace => (NVL (logrow.log4trace, 'N') = 'Y')
      );

      plog.setbeginsection (pkgctx, 'pr_manual_matching');
      plog.debug (pkgctx, 'BEGIN OF pr_manual_matching');


      -- 1. Set common values

      v_brid := '0000';
      v_tlid := '0000';
      v_ipaddress := 'HOST';
      v_wsname := 'HOST';
      v_tltxcd := '8804';

      For i in c_SqlMaster
      Loop
       OPEN c_Odmast_check(i.ORDERID);
       FETCH c_Odmast_check INTO VC_ODMAST;

      plog.debug (pkgctx, 'i.ORDERID' || i.ORDERID);
       IF c_Odmast_check%FOUND THEN
            v_RemainQtty:=VC_ODMAST.REMAINQTTY;
       END IF;
       CLOSE c_Odmast_check;

            plog.debug (pkgctx, i.ORDERID || ' ' || i.qtty || ' ' || v_RemainQtty);
       If v_RemainQtty >= i.QTTY THEN
             SELECT    '6000'
                  || SUBSTR ('000000' || seq_batchtxnum.NEXTVAL,
                             LENGTH ('000000' || seq_batchtxnum.NEXTVAL) - 5,
                             6
                            )
             INTO v_txnum
             FROM DUAL;
             SELECT TO_CHAR (SYSDATE, 'HH24:MI:SS')
              INTO v_txtime
              FROM DUAL;

              SELECT varvalue
                INTO v_txdate
                FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';

            v_txdesc := i.CUSTODYCD||'.'||i.BORS||'.'||i.SYMBOL||'.'||i.QTTY||'.'||i.PRICE;
  --1.TLLOG
              plog.debug (pkgctx, 'Begin insert tllog' || v_txnum);
            INSERT INTO tllog
                    (autoid, txnum,
                     txdate, txtime, brid,
                     tlid, offid, ovrrqs, chid, chkid, tltxcd, ibt, brid2, tlid2,
                     ccyusage, txstatus, msgacct, msgamt, chktime, offtime, off_line,
                     deltd, brdate,
                     busdate, msgsts, ovrsts, ipaddress, wsname,
                     batchname, carebygrp, txdesc
                    )
             VALUES (seq_tllog.NEXTVAL, v_txnum,
                     TO_DATE (v_txdate, 'dd/MM/yyyy'), v_txtime, v_brid,
                     v_tlid, '', '', '', '', '8814', '', '', '',
                     '00', '1', i.ORDERID, i.PRICE, '', '', 'N',
                     'N', TO_DATE (v_txdate, 'dd/MM/yyyy'),
                     TO_DATE (v_txdate, 'dd/MM/yyyy'), '0', '0', v_ipaddress, v_wsname,
                     'DAY', '', v_txdesc
                    );


  --2.TLLOGFLD
            INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd, cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     TO_DATE (v_txdate, 'dd/MM/yyyy'), '03', i.ORDERID, 0
                    );
            INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd, cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     TO_DATE (v_txdate, 'dd/MM/yyyy'), '04', i.AFACCTNO, 0
                    );
            INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd, cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     TO_DATE (v_txdate, 'dd/MM/yyyy'), '05', i.AFACCTNO, 0
                    );
            INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd, cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     TO_DATE (v_txdate, 'dd/MM/yyyy'), '06', i.SEACCTNO, 0
                    );
            INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd, cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     TO_DATE (v_txdate, 'dd/MM/yyyy'), '07', i.REFORDERID, 0
                    );
            INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd, cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     TO_DATE (v_txdate, 'dd/MM/yyyy'), '08', '', 0
                    );
            INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd, cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     TO_DATE (v_txdate, 'dd/MM/yyyy'), '09', i.CLEARCD, 0
                    );

            INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd, cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     TO_DATE (v_txdate, 'dd/MM/yyyy'), '10', '', i.PRICE
                    );
            INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd, cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     TO_DATE (v_txdate, 'dd/MM/yyyy'), '11', '', i.QTTY
                    );

            INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd, cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     TO_DATE (v_txdate, 'dd/MM/yyyy'), '12', '', i.EXPRICE
                    );
            INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd, cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     TO_DATE (v_txdate, 'dd/MM/yyyy'), '13', '', i.EXQTTY
                    );
            INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd, cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     TO_DATE (v_txdate, 'dd/MM/yyyy'), '14', '', i.CLEARDAY
                    );
            INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd, cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     TO_DATE (v_txdate, 'dd/MM/yyyy'), '15', '', i.BRATIO
                    );
            INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd, cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     TO_DATE (v_txdate, 'dd/MM/yyyy'), '16', i.CONFIRM_NO, 0
                    );
            INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd, cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     TO_DATE (v_txdate, 'dd/MM/yyyy'), '17', '', 0
                    );

            INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd,
                     cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     TO_DATE (v_txdate, 'dd/MM/yyyy'), '30',
                     v_txdesc, 0
                    );

            INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd, cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     TO_DATE (v_txdate, 'dd/MM/yyyy'), '80', i.CODEID, 0
                    );
            INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd, cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     TO_DATE (v_txdate, 'dd/MM/yyyy'), '81', i.SYMBOL, 0
                    );
            INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd, cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     TO_DATE (v_txdate, 'dd/MM/yyyy'), '82', i.CUSTODYCD, 0
                    );
            INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd, cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     TO_DATE (v_txdate, 'dd/MM/yyyy'), '83', i.BORS, 0
                    );
            INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd, cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     TO_DATE (v_txdate, 'dd/MM/yyyy'), '84', i.NORP, 0
                    );
            INSERT INTO tllogfld
                    (autoid, txnum,
                     txdate, fldcd, cvalue, nvalue
                    )
             VALUES (seq_tllogfld.NEXTVAL, v_txnum,
                     TO_DATE (v_txdate, 'dd/MM/yyyy'), '85', i.AORN, 0
                    );

  --3.AFTRAN
                plog.debug (pkgctx, 'Update AFTRAN' || v_txnum);
            --Thuc hien tran
            INSERT INTO aftran
                    (acctno, txnum,
                     txdate, txcd, namt, camt, REF,
                     deltd, autoid
                    )
             VALUES (i.AFACCTNO, v_txnum,
                     TO_DATE (v_txdate, 'dd/MM/yyyy'), '0088', i.PRICE * i.QTTY, '', '',
                     'N', seq_aftran.NEXTVAL
                    );

  --4.ODTRAN
                plog.debug (pkgctx, 'Insert ODTRAN' || v_txnum);
            INSERT INTO odtran
                    (acctno, txnum,
                     txdate, txcd, namt, camt, REF,
                     deltd, autoid
                    )
             VALUES (i.ORDERID, v_txnum,
                     TO_DATE (v_txdate, 'dd/MM/yyyy'), '0028', i.PRICE * i.QTTY, '', '',
                     'N', seq_odtran.NEXTVAL
                    );
            INSERT INTO odtran
                    (acctno, txnum,
                     txdate, txcd, namt, camt,
                     REF, deltd, autoid
                    )
             VALUES (i.ORDERID, v_txnum,
                     TO_DATE (v_txdate, 'dd/MM/yyyy'), '0013', i.QTTY, '',
                     i.CIACCTNO, 'N', seq_odtran.NEXTVAL
                    );
            INSERT INTO odtran
                    (acctno, txnum,
                     txdate, txcd, namt, camt, REF,
                     deltd, autoid
                    )
             VALUES (i.ORDERID, v_txnum,
                     TO_DATE (v_txdate, 'dd/MM/yyyy'), '0034', i.PRICE * i.QTTY, '', '',
                     'N', seq_odtran.NEXTVAL
                    );
            INSERT INTO odtran
                    (acctno, txnum,
                     txdate, txcd, namt, camt, REF, deltd,
                     autoid
                    )
             VALUES (i.ORDERID, v_txnum,
                     TO_DATE (v_txdate, 'dd/MM/yyyy'), '0001', 0, '4', '', 'N',
                     seq_odtran.NEXTVAL
                    );
            INSERT INTO odtran
                    (acctno, txnum,
                     txdate, txcd, namt, camt,
                     REF, deltd, autoid
                    )
             VALUES (i.ORDERID, v_txnum,
                     TO_DATE (v_txdate, 'dd/MM/yyyy'), '0011', i.QTTY, '',
                     i.CIACCTNO, 'N', seq_odtran.NEXTVAL
                    );

  --5.AFMAST
/*              plog.debug (pkgctx, 'Update AFMAST' || i.AFACCTNO);

            UPDATE afmast
             SET dmatchamt = NVL(dmatchamt,0) + i.PRICE * i.QTTY
             WHERE acctno = i.AFACCTNO;*/


  --6.IOD
                plog.debug (pkgctx, 'Insert OOD' || i.ORDERID);
            INSERT INTO iod
                    (orgorderid, codeid, symbol, custodycd, bors, norp,
                     txdate, txnum, aorn, price,
                     qtty, exorderid, refcustcd, matchprice, matchqtty, confirm_no,
                     txtime
                    )
             VALUES (i.ORDERID, i.CODEID, i.SYMBOL, i.CUSTODYCD, i.BORS, i.NORP,
                     TO_DATE (v_txdate, 'dd/MM/yyyy'), v_txnum , i.AORN, i.EXPRICE,
                     i.EXQTTY, i.REFORDERID, '', i.PRICE, i.QTTY, i.CONFIRM_NO,
                     v_txtime
                    );
  --7.ODMAST
                  plog.debug (pkgctx, 'Update ODMAST' || i.orderid);
           --Cap nhat Odmast
           UPDATE odmast
           SET execamt = NVL(execamt,0) + i.PRICE * i.QTTY,
               execqtty = NVL(execqtty,0) + i.QTTY,
               matchamt = NVL(matchamt,0) + i.PRICE * i.QTTY,
               porstatus = porstatus || '4',
               orstatus = '4',
               remainqtty = remainqtty - i.QTTY,
               last_change = SYSTIMESTAMP
           WHERE orderid = i.orderid;


                  plog.debug (pkgctx, 'Insert trade allocation' || i.CONFIRM_NO);
           INSERT INTO stctradeallocation
                        (txdate, txnum,
                         refconfirmnumber, orderid, bors, volume, price, deltd
                        )
                 VALUES (TO_DATE (v_txdate, 'dd/MM/yyyy'), v_txnum ,
                         i.CONFIRM_NO, i.ORDERID, i.BORS, i.QTTY, i.PRICE, 'N'
                        );
   --8.Tao lich thanh toan

                  plog.debug (pkgctx, 'Generate schedule' || i.ORDERID);
        SELECT COUNT (*)
        INTO v_matched
        FROM stschd
        WHERE orgorderid = i.ORDERID AND deltd <> 'Y';

        IF i.BORS = 'B' THEN  --Lenh mua
                select typ.mtrfday into v_mtrfday
                from odmast od, odtype typ
                where od.actype=typ.actype and od.orderid=i.ORDERID;
                --Tao lich thanh toan chung khoan
                 v_strduetype := 'RS';

                 -- cap nhat gia von
                 UPDATE semast SET dcramt = dcramt + i.PRICE * i.QTTY, dcrqtty = dcrqtty + i.QTTY WHERE acctno = i.SEACCTNO;
                 INSERT INTO setran
                        (txnum, txdate,acctno, txcd, namt, camt, REF, deltd, autoid)
                 VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'), i.SEACCTNO, '0051', i.PRICE * i.QTTY, NULL, NULL, 'N', seq_setran.NEXTVAL);

                INSERT INTO setran
                        (txnum, txdate, acctno, txcd, namt, camt, REF, deltd, autoid )
                 VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'), i.SEACCTNO, '0052', i.QTTY, NULL, NULL, 'N', seq_setran.NEXTVAL );

                 IF v_matched > 0
                 THEN
                    UPDATE stschd
                       SET qtty = qtty + i.QTTY,
                           amt = amt + i.PRICE * i.QTTY
                     WHERE orgorderid = i.ORDERID AND duetype = v_strduetype;
                 ELSE
                    INSERT INTO stschd
                                (autoid, orgorderid, codeid,
                                 duetype, afacctno, acctno,
                                 reforderid, txnum,
                                 txdate, clearday,
                                 clearcd, amt, aamt,
                                 qtty, aqtty, famt, status, deltd, costprice, cleardate
                                )
                         VALUES (seq_stschd.NEXTVAL, i.ORDERID, i.CODEID,
                                 v_strduetype, i.AFACCTNO, i.SEACCTNO,
                                 i.REFORDERID, v_txnum,
                                 TO_DATE (v_txdate, 'DD/MM/YYYY'), i.CLEARDAY,
                                 i.CLEARCD, i.PRICE * i.QTTY, 0,
                                 i.QTTY, 0, 0, 'N', 'N', 0, getduedate(TO_DATE (v_txdate, 'DD/MM/YYYY'),i.CLEARCD,/*'000'*/i.TRADEPLACE,i.CLEARDAY)--ngoc.vu-Jira561
                                );
                 END IF;

                 --Tao lich thanh toan tien
                 select case when mrt.mrtype <> 'N' and aft.istrfbuy <> 'N' then trfbuyext
                    else 0 end into l_trfbuyext
                from afmast af, aftype aft, mrtype mrt
                where af.actype = aft.actype and aft.mrtype = mrt.actype and af.acctno = i.AFACCTNO;


                 v_strduetype := 'SM';

                 IF v_matched > 0
                 THEN
                    UPDATE stschd
                       SET qtty = qtty + i.QTTY,
                           amt = amt + i.PRICE * i.QTTY
                     WHERE orgorderid = i.ORDERID AND duetype = v_strduetype;
                 ELSE
                    INSERT INTO stschd
                                (autoid, orgorderid, codeid,
                                 duetype, afacctno, acctno,
                                 reforderid, txnum,
                                 txdate, clearday,
                                 clearcd, amt, aamt,
                                 qtty, aqtty, famt, status, deltd, costprice,cleardate
                                )
                         VALUES (seq_stschd.NEXTVAL, i.ORDERID, i.CODEID,
                                 v_strduetype, i.AFACCTNO, i.AFACCTNO,
                                 i.REFORDERID, v_txnum,
                                 TO_DATE (v_txdate, 'DD/MM/YYYY'), least(v_mtrfday,l_trfbuyext),
                                 i.CLEARCD, i.PRICE * i.QTTY, 0,
                                 i.QTTY, 0, 0, 'N', 'N', 0,getduedate(TO_DATE (v_txdate, 'DD/MM/YYYY'),i.CLEARCD,/*'000'*/i.TRADEPLACE,least(v_mtrfday,l_trfbuyext)) --ngoc.vu-Jira561
                                );
                 END IF;


        ELSE  --Lenh ban

        --Tao lich thanh toan chung khoan
         v_strduetype := 'SS';

         IF v_matched > 0
         THEN
            UPDATE stschd
               SET qtty = qtty + i.QTTY,
                   amt = amt + i.PRICE * i.QTTY
             WHERE orgorderid = i.ORDERID AND duetype = v_strduetype;
         ELSE
            INSERT INTO stschd
                        (autoid, orgorderid, codeid,
                         duetype, afacctno, acctno,
                         reforderid, txnum,
                         txdate, clearday,
                         clearcd, amt, aamt,
                         qtty, aqtty, famt, status, deltd, costprice,cleardate
                        )
                 VALUES (seq_stschd.NEXTVAL, i.ORDERID, i.CODEID,
                         v_strduetype, i.AFACCTNO, i.SEACCTNO,
                         i.REFORDERID, v_txnum,
                         TO_DATE (v_txdate, 'DD/MM/YYYY'), 0,
                         i.CLEARCD, i.PRICE * i.QTTY, 0,
                         i.QTTY, 0, 0, 'N', 'N', 0,getduedate(TO_DATE (v_txdate, 'DD/MM/YYYY'),i.CLEARCD,/*'000'*/i.TRADEPLACE,0)--ngoc.vu-Jira561
                        );
         END IF;

         --Tao lich thanh toan tien
         v_strduetype := 'RM';

         IF v_matched > 0
         THEN
            UPDATE stschd
               SET qtty = qtty + i.QTTY,
                   amt = amt + i.PRICE * i.QTTY
             WHERE orgorderid = i.ORDERID AND duetype = v_strduetype;
         ELSE
            INSERT INTO stschd
                        (autoid, orgorderid, codeid,
                         duetype, afacctno, acctno,
                         reforderid, txnum,
                         txdate, clearday,
                         clearcd, amt, aamt,
                         qtty, aqtty, famt, status, deltd, costprice,cleardate
                        )
                 VALUES (seq_stschd.NEXTVAL, i.ORDERID, i.CODEID,
                         v_strduetype, i.AFACCTNO, i.AFACCTNO,
                         i.REFORDERID, v_txnum,
                         TO_DATE (v_txdate, 'DD/MM/YYYY'), i.CLEARDAY,
                         i.CLEARCD, i.PRICE * i.QTTY, 0,
                         i.QTTY, 0, 0, 'N', 'N', 0,getduedate(TO_DATE (v_txdate, 'DD/MM/YYYY'),i.CLEARCD,/*'000'*/i.TRADEPLACE, i.CLEARDAY)--ngoc.vu-Jira561
                        );
         END IF;
        END IF;
        --Cap nhat cho GTC
       OPEN C_ODMAST(i.ORDERID);
       FETCH C_ODMAST INTO VC_ODMAST;
       IF C_ODMAST%FOUND THEN
             UPDATE FOMAST SET REMAINQTTY= REMAINQTTY - i.QTTY
                                ,EXECQTTY= EXECQTTY + i.QTTY
                                ,EXECAMT=  EXECAMT + i.PRICE * i.QTTY
                                ,last_change = SYSTIMESTAMP
              --WHERE ORGACCTNO= i.ORDERID;
              WHERE ACCTNO= VC_ODMAST.FOACCTNO;

        END IF;
       CLOSE C_ODMAST;


       END IF;
   End Loop;

   --CLOSE c_SqlMaster;
            IF c_SqlMaster%ISOPEN THEN
             CLOSE c_SqlMaster;
             END IF;


      /***************************************************************************************************
      ** END;
      ***************************************************************************************************/
      plog.debug (pkgctx, '<<END OF pr_manual_matching');
      plog.setendsection (pkgctx, 'pr_manual_matching');
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         plog.error (pkgctx, SQLERRM);

         IF c_SqlMaster%ISOPEN THEN
         CLOSE c_SqlMaster;
         END IF;

         plog.setendsection (pkgctx, 'pr_manual_matching');
   END pr_manual_matching;
 
 
 
 
/
