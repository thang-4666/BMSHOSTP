SET DEFINE OFF;
CREATE OR REPLACE PACKAGE trdpks_auto
IS
     PROCEDURE pr_fo2od;

     PROCEDURE pr_init (p_level number);

     PROCEDURE pr_trade_allocating;

     PROCEDURE pr_cancel_order;

END;
 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY trdpks_auto
-- Refactored procedure pr_autotxprocess

IS
   pkgctx   plog.log_ctx:= plog.init ('txpks_trdpks_auto',
                 plevel => 30,
                 plogtable => true,
                 palert => false,
                 ptrace => false);
   logrow   tlogdebug%ROWTYPE;

CURSOR curs_build_msg
   IS
      SELECT --'' fld09,                                    --custodycd   fld09,
            a.codeid fld01,
             a.symbol fld07,
             DECODE (a.exectype, 'MS', '1', '0') fld60, --ismortage   fld60, -- FOR 8885
             a.actype fld02,
             a.afacctno || a.codeid fld06,                --seacctno    fld06,
             a.afacctno fld03,
             --'' fld50,                            --a.CUSTNAME        fld50,
             a.timetype fld20,
             a.effdate fld19,
             a.expdate fld21,
             a.exectype fld22,
             a.outpriceallow fld34,
             a.nork fld23,
             a.matchtype fld24,
             a.via fld25,
             a.clearday fld10,
             a.clearcd fld26,
             'O' fld72,                                       --puttype fld72,
             a.pricetype fld27,
             a.quantity fld12,                      --a.ORDERQTTY       fld12,
             a.quoteprice fld11,
             0 fld18,                               --a.ADVSCRAMT       fld18,
             0 fld17,                               --a.ORGQUOTEPRICE   fld17,
             0 fld16,                               --a.ORGORDERQTTY    fld16,
             0 fld31,                               --a.ORGSTOPPRICE    fld31,
             a.bratio fld13,
             0 fld14,                               --a.LIMITPRICE      fld14,
             0 fld40,                                                -- FEEAMT
             --'' fld28,                           --a.VOUCHER         fld28,
             --'' fld29,                           --a.CONSULTANT      fld29,
             --'' fld04,                           --a.ORDERID         fld04,
             a.reforderid fld08,
             b.parvalue fld15,
             a.dfacctno fld95,
             100 fld99,                             --a.HUNDRED         fld99,
             c.tradeunit fld98,
             1 fld96,                                                   -- GTC
             '' fld97,                                                  --mode
             '' fld33,                                              --clientid
             '' fld73,                                            --contrafirm
             '' fld32,                                              --traderid
             '' fld71,                                             --contracus
             a.acctno,                              -- only for test mktstatus
             '' fld30,                              --a.DESC            fld30,
             a.refacctno,
             a.orgacctno,
             a.refprice,
             a.refquantity,
             c.ceilingprice,
             c.floorprice,
             c.marginprice,
             b.tradeplace,
             b.sectype,
             c.tradelot,
             c.securedratiomin,
             c.securedratiomax
      FROM fomast a, sbsecurities b, securities_info c
      WHERE     a.book = 'A'
            AND a.timetype <> 'G'
            AND a.status = 'P'
            AND a.codeid = b.codeid
            AND a.codeid = c.codeid;

PROCEDURE pr_trade_allocating
   IS

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
        SELECT  * FROM (select * from
        (
        SELECT OD.ORDERID,OD.CODEID,SEC.SYMBOL,B.CUSTODYCD,OD.AFACCTNO,OD.SEACCTNO,OD.CIACCTNO,B.BSCA BORS,B.NORP,OD.NORK AORN,
        OD.QUOTEPRICE EXPRICE, OD.ORDERQTTY EXQTTY, A.VOLUME QTTY,A.PRICE PRICE,A.ORDERNUMBER REFORDERID, A.REFCONFIRMNUMBER CONFIRM_NO,
        OD.BRATIO,OD.CLEARDAY,OD.CLEARCD, B.CUSTODYCD || '.' || B.BSCA || '.' || SEC.SYMBOL || '.' || A.VOLUME || '.' || A.PRICE  DESCRIPTION
        ,SEC.TRADEPLACE
        FROM ODMAST OD,SBSECURITIES SEC,STCTRADEBOOK A,STCORDERBOOK B WHERE OD.ORDERID=B.ORDERID AND  A.ORDERNUMBER=B.ORDERNUMBER AND OD.CODEID=SEC.CODEID AND SEC.TRADEPLACE<>'007'
        MINUS
        SELECT OD.ORDERID,OD.CODEID,SEC.SYMBOL,B.CUSTODYCD,OD.AFACCTNO,OD.SEACCTNO,OD.CIACCTNO,B.BSCA BORS,B.NORP,OD.NORK AORN,
        OD.QUOTEPRICE EXPRICE, OD.ORDERQTTY EXQTTY, A.VOLUME QTTY,A.PRICE PRICE,A.ORDERNUMBER REFORDERID, A.REFCONFIRMNUMBER CONFIRM_NO,
        OD.BRATIO,OD.CLEARDAY,OD.CLEARCD , B.CUSTODYCD || '.' || B.BSCA || '.' || SEC.SYMBOL || '.' || A.VOLUME || '.' || A.PRICE  DESCRIPTION
        ,SEC.TRADEPLACE
        FROM ODMAST OD,SBSECURITIES SEC, STCTRADEBOOK A,STCORDERBOOK B,STCTRADEALLOCATION C  WHERE OD.ORDERID=B.ORDERID AND  A.ORDERNUMBER=B.ORDERNUMBER
        AND A.REFCONFIRMNUMBER=C.REFCONFIRMNUMBER AND OD.CODEID=SEC.CODEID AND C.DELTD<>'Y' AND SEC.TRADEPLACE<>'007'
        ) order by CONFIRM_NO ) WHERE  ROWNUM <= 30;

   Cursor c_Odmast(v_OrgOrderID Varchar2) Is
   SELECT FOACCTNO,REMAINQTTY,EXECQTTY,EXECAMT,CANCELQTTY,ADJUSTQTTY
   FROM ODMAST WHERE TIMETYPE ='G' AND ORDERID=v_OrgOrderID;
   vc_Odmast c_Odmast%Rowtype;

   Cursor c_Odmast_check(v_OrgOrderID Varchar2) Is
   SELECT FOACCTNO,REMAINQTTY,EXECQTTY,EXECAMT,CANCELQTTY,ADJUSTQTTY
   FROM ODMAST WHERE ORDERID=v_OrgOrderID;

   BEGIN
      plog.setbeginsection (pkgctx, 'pr_trade_allocating');
      plog.debug (pkgctx, 'BEGIN OF pr_trade_allocating');
      /***************************************************************************************************
       ** PUT YOUR CODE HERE, FOLLOW THE BELOW TEMPLATE:
       ** IF NECCESSARY, USING BULK COLLECTION IN THE CASE YOU MUST POPULATE LARGE DATA
      ****************************************************************************************************/

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

                select typ.mtrfday
                    into v_mtrfday
                from odmast od, odtype typ, afmast af
                where od.actype=typ.actype
                and od.afacctno = af.acctno
                and od.orderid=i.ORDERID;

                --Tao lich thanh toan chung khoan
                 v_strduetype := 'RS';

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
                                 i.QTTY, 0, 0, 'N', 'N', 0, getduedate(TO_DATE (v_txdate, 'DD/MM/YYYY'),i.CLEARCD,/*'000'*/ i.TRADEPLACE,i.CLEARDAY)--ngoc.vu-Jira561
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
                                 i.QTTY, 0, 0, 'N', 'N', 0, getduedate(TO_DATE (v_txdate, 'DD/MM/YYYY'),i.CLEARCD,/*'000'*/i.TRADEPLACE,least(v_mtrfday,l_trfbuyext))--ngoc.vu-Jira561
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

       COMMIT;
       END IF;
   End Loop;

   --CLOSE c_SqlMaster;
            IF c_SqlMaster%ISOPEN THEN
             CLOSE c_SqlMaster;
             END IF;

   COMMIT;                                -- Commit the last trunk (if any)
      /***************************************************************************************************
      ** END;
      ***************************************************************************************************/
      plog.debug (pkgctx, '<<END OF pr_trade_allocating');
      plog.setendsection (pkgctx, 'pr_trade_allocating');
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         plog.error (pkgctx, SQLERRM);

         --CLOSE c_SqlMaster;
                  IF c_SqlMaster%ISOPEN THEN
         CLOSE c_SqlMaster;
         END IF;

         plog.setendsection (pkgctx, 'pr_trade_allocating');
   END pr_trade_allocating;

   PROCEDURE pr_fo2od
   IS
      l_txmsg               tx.msg_rectype;
      l_orders_cache_size   NUMBER (10) := 10000;
      l_commit_freq         NUMBER (10) := 10;
      l_count               NUMBER (10) := 0;
      l_order_count         NUMBER (10) := 0;
      l_err_code            deferror.errnum%TYPE;
      l_err_param           deferror.errdesc%TYPE;

      TYPE build_msg_arrtype
      IS
         TABLE OF curs_build_msg%ROWTYPE
            INDEX BY PLS_INTEGER;

      l_build_msg           build_msg_arrtype;
      l_mktstatus           ordersys.sysvalue%TYPE;
      l_atcstarttime        sysvar.varvalue%TYPE;

      l_typebratio          odtype.bratio%TYPE;
      l_afbratio            afmast.bratio%TYPE;
      l_securedratio        odtype.bratio%TYPE;
      l_actype              odtype.actype%TYPE;
      l_remainqtty          odmast.orderqtty%TYPE;
      l_fullname            cfmast.fullname%TYPE;

      l_feeamountmin        NUMBER;
      l_feerate             NUMBER;
      l_feesecureratiomin   NUMBER;
      l_hosebreakingsize    NUMBER;

      l_strMarginType       mrtype.mrtype%TYPE;
      l_dblMarginRatioRate  afserisk.MRRATIOLOAN%TYPE;
      l_dblSecMarginPrice   afserisk.MRPRICELOAN%TYPE;
      l_dblIsPPUsed         mrtype.ISPPUSED%TYPE;
      l_strEXECTYPE         odmast.exectype%TYPE;



   BEGIN
      plog.setbeginsection (pkgctx, 'pr_fo2od');
      plog.debug (pkgctx, 'BEGIN OF pr_fo2od');
      /***************************************************************************************************
       ** PUT YOUR CODE HERE, FOLLOW THE BELOW TEMPLATE:
       ** IF NECCESSARY, USING BULK COLLECTION IN THE CASE YOU MUST POPULATE LARGE DATA
      ****************************************************************************************************/
      l_atcstarttime      :=
         cspks_system.fn_get_sysvar ('SYSTEM', 'ATCSTARTTIME');
      l_hosebreakingsize   :=
         cspks_system.fn_get_sysvar ('SYSTEM', 'HOSEBREAKSIZE');

      plog.debug (pkgctx,
                     'got l_atcstarttime,l_hosebreakingsize,l_commit_freq'
                  || l_atcstarttime
                  || ','
                  || l_hosebreakingsize
                  || ','
                  || l_commit_freq
      );
      -- 1. Set common values
      l_txmsg.brid        := systemnums.c_ho_brid;
      l_txmsg.tlid        := systemnums.c_system_userid;
      l_txmsg.off_line    := 'N';
      l_txmsg.deltd       := txnums.c_deltd_txnormal;
      l_txmsg.txstatus    := txstatusnums.c_txcompleted;
      l_txmsg.msgsts      := '0';
      l_txmsg.ovrsts      := '0';
      l_txmsg.batchname   := 'AUTO';

      SELECT SYS_CONTEXT ('USERENV', 'HOST'),
             SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
      INTO l_txmsg.wsname, l_txmsg.ipaddress
      FROM DUAL;

      plog.debug (pkgctx,
                     'wsname,ipaddress:'
                  || l_txmsg.wsname
                  || ','
                  || l_txmsg.ipaddress
      );

      -- 2. Set specific value for each transaction
      OPEN curs_build_msg;

      LOOP
         FETCH curs_build_msg
            BULK COLLECT INTO l_build_msg
            LIMIT l_orders_cache_size;

         plog.debug (pkgctx, 'total orders: ' || l_build_msg.COUNT);
         EXIT WHEN l_build_msg.COUNT = 0;

         FOR indx IN 1 .. l_build_msg.COUNT
         LOOP
            plog.debug (pkgctx, 'inside for indx: ' || indx);

            BEGIN
               SAVEPOINT sp#1;
               l_count                           := l_count + 1; -- increase the commit freq counter

               -- Check Market status
               SELECT sysvalue
               INTO l_mktstatus
               FROM ordersys
               WHERE sysname = 'CONTROLCODE';

               plog.debug (pkgctx,
                              'l_mktstatus,pricetype: '
                           || l_mktstatus
                           || ','
                           || l_build_msg (indx).fld27
               );

               -- l_mktstatus=P: 8h30-->9h00 session 1 ATO
               -- l_mktstatus=O: 9h00-->10h15 session 2 MP
               -- l_mktstatus=A: 10h15-->10h30 session 3 ATC

               IF l_build_msg (indx).fld27 = 'ATO'
               THEN                                        -- fld27: pricetype
                  IF l_mktstatus IN ('O', 'A')
                  THEN
                     RAISE errnums.e_invalid_session;
                  END IF;
               ELSIF l_build_msg (indx).fld27 = 'ATC'
               THEN
                  IF not(l_mktstatus = 'A'
                            or (l_mktstatus = 'O'
                                    AND l_atcstarttime <=
                                        TO_CHAR (SYSDATE, 'HH24MISS')))
                  THEN
                     RAISE errnums.e_invalid_session;
                  END IF;
               ELSIF l_build_msg (indx).fld27 = 'MO'
               THEN
                  IF l_mktstatus <> 'O'
                  THEN
                     RAISE errnums.e_invalid_session;
                  END IF;
               END IF;

               l_txmsg.txfields ('22').VALUE     := l_build_msg (indx).fld22; --set vale for Execution TYPE
               l_strEXECTYPE:=l_build_msg (indx).fld22;
               plog.debug (pkgctx,
                           'exectype: ' || l_txmsg.txfields ('22').VALUE
               );

               IF LENGTH (l_build_msg (indx).refacctno) > 0
               THEN                                             --lENH HUY SUA
                  FOR i IN (SELECT exectype
                            FROM fomast
                            WHERE orgacctno = l_build_msg (indx).refacctno)
                  LOOP
                     --l_txmsg.txfields ('22').VALUE   := i.exectype;
                     l_strEXECTYPE:=i.exectype;
                     plog.debug (pkgctx,
                                 'cancel orders, set exectype: '
                                 || l_txmsg.txfields ('22').VALUE
                     );
                  END LOOP;
               END IF;

               IF l_build_msg (indx).fld27 <> 'LO'
               THEN                                               -- Pricetype
                  IF l_strEXECTYPE='NB'--l_build_msg (indx).fld22 = 'NB'
                  THEN                                             -- exectype
                     l_build_msg (indx).fld11   :=
                        l_build_msg (indx).ceilingprice
                        / l_build_msg (indx).fld98;                --tradeunit
                  ELSE
                     l_build_msg (indx).fld11   :=
                        l_build_msg (indx).floorprice
                        / l_build_msg (indx).fld98;
                  END IF;
               END IF;



               plog.debug (pkgctx, 'ACCTNO: ' || l_build_msg (indx).fld03);

               /*FOR i IN (SELECT mst.bratio, cf.custodycd, cf.fullname, mst.actype
                         FROM afmast mst, cfmast cf
                         WHERE acctno = l_build_msg (indx).fld03
                               AND mst.custid = cf.custid)
               LOOP
                  l_txmsg.txfields ('09').VALUE   := i.custodycd;
                  l_actype                        := i.actype;
                  l_afbratio                      := i.bratio;
                  l_txmsg.txfields ('50').VALUE   := i.fullname;
               END LOOP;*/

               FOR i IN (SELECT MST.BRATIO, CF.CUSTODYCD,CF.FULLNAME,MST.ACTYPE,MRT.MRTYPE,MRT.ISPPUSED,
                        NVL(RSK.MRRATIOLOAN,0) MRRATIOLOAN, NVL(MRPRICELOAN,0) MRPRICELOAN
                        FROM AFMAST MST, CFMAST CF ,AFTYPE AFT, MRTYPE MRT,
                        (SELECT * FROM AFSERISK WHERE CODEID=l_build_msg (indx).fld01 ) RSK
                        WHERE MST.ACCTNO=l_build_msg (indx).fld03
                        AND MST.CUSTID=CF.CUSTID
                        and mst.actype =aft.actype and aft.mrtype = mrt.actype
                        AND AFT.ACTYPE =RSK.ACTYPE(+))
               LOOP
                  l_txmsg.txfields ('09').VALUE   := i.custodycd;
                  l_actype                        := i.actype;
                  l_afbratio                      := i.bratio;
                  l_txmsg.txfields ('50').VALUE   := 'FO';
                  l_fullname                      := i.fullname;
                  l_strMarginType                 := i.MRTYPE;
                  l_dblMarginRatioRate            := i.MRRATIOLOAN;
                  l_dblSecMarginPrice             := i.MRPRICELOAN;
                  l_dblIsPPUsed                   := i.ISPPUSED;
                  If l_dblMarginRatioRate >= 100 Or l_dblMarginRatioRate < 0
                  Then
                        l_dblMarginRatioRate := 0;
                  END IF;
                  if l_build_msg (indx).marginprice > l_dblSecMarginPrice
                  then
                        l_dblSecMarginPrice := l_dblSecMarginPrice;
                  else
                        l_dblSecMarginPrice := l_build_msg (indx).marginprice;
                  end if;
               END LOOP;

               plog.debug (pkgctx,
                           'FULLNAME: ' || l_txmsg.txfields ('50').VALUE
               );

               plog.debug (pkgctx, 'VIA: ' || l_build_msg (indx).fld25);
               plog.debug (pkgctx, 'CLEARCD: ' || l_build_msg (indx).fld26);
               plog.debug (pkgctx, 'EXECTYPE: ' || l_build_msg (indx).fld22);
               plog.debug (pkgctx, 'TIMETYPE: ' || l_build_msg (indx).fld20);
               plog.debug (pkgctx, 'PRICETYPE: ' || l_build_msg (indx).fld27);
               plog.debug (pkgctx, 'MATCHTYPE: ' || l_build_msg (indx).fld24);
               plog.debug (pkgctx, 'NORK: ' || l_build_msg (indx).fld23);
               plog.debug (pkgctx, 'sectype: ' || l_build_msg (indx).sectype);
               plog.debug (pkgctx,
                           'tradeplace: ' || l_build_msg (indx).tradeplace
               );

               BEGIN
                  SELECT actype, clearday, bratio, minfeeamt, deffeerate
                  --to_char(sysdate,systemnums.C_TIME_FORMAT) TXTIME
                  INTO l_txmsg.txfields ('02').VALUE,                 --ACTYPE
                       l_txmsg.txfields ('10').VALUE,               --CLEARDAY
                       l_typebratio,                          --BRATIO (fld13)
                       l_feeamountmin,
                       l_feerate
                  FROM odtype a
                  WHERE     status = 'Y'
                        AND (via = l_build_msg (indx).fld25 OR via = 'A') --VIA
                        AND clearcd = l_build_msg (indx).fld26       --CLEARCD
                        AND (exectype = l_strEXECTYPE           --l_build_msg (indx).fld22
                             OR exectype = 'AA')                    --EXECTYPE
                        AND (timetype = l_build_msg (indx).fld20
                             OR timetype = 'A')                     --TIMETYPE
                        AND (pricetype = l_build_msg (indx).fld27
                             OR pricetype = 'AA')                  --PRICETYPE
                        AND (matchtype = l_build_msg (indx).fld24
                             OR matchtype = 'A')                   --MATCHTYPE
                        AND (tradeplace = l_build_msg (indx).tradeplace
                             OR tradeplace = '000')
                        AND (sectype = l_build_msg (indx).sectype
                             OR sectype = '000')
                        AND (nork = l_build_msg (indx).fld23 OR nork = 'A') --NORK
                         AND EXISTS
                              (SELECT 1
                               FROM afidtype
                               WHERE     objname = 'OD.ODTYPE'
                                     AND aftype = l_actype
                                     AND actype = a.actype);

               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                  RAISE errnums.e_od_odtype_notfound;
               END;

               plog.debug (pkgctx,
                           'ACTYPE: ' || l_txmsg.txfields ('02').VALUE
               );
               if l_strMarginType='S' or l_strMarginType='T' or l_strMarginType='N' then
                   --Tai khoan margin va tai khoan binh thuong ky quy 100%
                    l_securedratio:=100;
               elsif l_strMarginType='L' then --Cho tai khoan margin loan
                    begin
                        select nvl(dfrate,0) dfrate
                        into l_securedratio
                        from (select * from dfbasket where symbol=l_build_msg (indx).fld07) bk,
                        aftype aft, dftype dft,afmast af
                        where af.actype = aft.actype and aft.dftype = dft.actype and dft.basketid = bk.basketid (+)
                        and af.acctno = l_build_msg (indx).fld03;
                        l_securedratio:=greatest (100-l_securedratio,0);
                    exception
                    when others then
                         l_securedratio:=100;
                    end;
               else
                    l_securedratio                    :=
                    GREATEST (LEAST (l_typebratio + l_afbratio, 100),
                            l_build_msg (indx).securedratiomin
                    );
                    l_securedratio                    :=
                      CASE
                         WHEN l_securedratio > l_build_msg (indx).securedratiomax
                         THEN
                            l_build_msg (indx).securedratiomax
                         ELSE
                            l_securedratio
                      END;
               end if;

               --FeeSecureRatioMin = mv_dblFeeAmountMin * 100 / (CDbl(v_strQUANTITY) * CDbl(v_strQUOTEPRICE) * CDbl(v_strTRADEUNIT))
               l_feesecureratiomin               :=
                  l_feeamountmin * 100
                  / (  TO_NUMBER (l_build_msg (indx).fld12)         --quantity
                     * TO_NUMBER (l_build_msg (indx).fld11)       --quoteprice
                     * TO_NUMBER (l_build_msg (indx).fld98));      --tradeunit

               IF l_feesecureratiomin > l_feerate
               THEN
                  l_securedratio   := l_securedratio + l_feesecureratiomin;
               ELSE
                  l_securedratio   := l_securedratio + l_feerate;
               END IF;

               l_txmsg.txfields ('13').VALUE     := l_securedratio;

               IF (  TO_NUMBER (l_build_msg (indx).fld12)
                   * TO_NUMBER (l_build_msg (indx).fld11)
                   * l_securedratio
                   / 100
                   -   TO_NUMBER (l_build_msg (indx).refprice)
                     * TO_NUMBER (l_build_msg (indx).refquantity)
                     * l_securedratio
                     / 100 > 0)
               THEN
                  l_txmsg.txfields ('18').VALUE   :=
                       TO_NUMBER (l_build_msg (indx).fld12)
                     * TO_NUMBER (l_build_msg (indx).fld11)
                     * l_securedratio
                     / 100
                     -   TO_NUMBER (l_build_msg (indx).refprice)
                       * TO_NUMBER (l_build_msg (indx).refquantity)
                       * l_securedratio
                       / 100;
               ELSE
                  l_txmsg.txfields ('18').VALUE   := '0'; --AdvanceSecuredAmount
               END IF;



               --2.2 Set txtime
               l_txmsg.txtime                    :=
                  TO_CHAR (SYSDATE, systemnums.c_time_format);

               l_txmsg.chktime                   := l_txmsg.txtime;
               l_txmsg.offtime                   := l_txmsg.txtime;

               --2.3 Set txdate
               SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO l_txmsg.txdate
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';

               l_txmsg.brdate                    := l_txmsg.txdate;
               l_txmsg.busdate                   := l_txmsg.txdate;

               --2.4 Set fld value
               l_txmsg.txfields ('01').defname   := 'CODEID';
               l_txmsg.txfields ('01').TYPE      := 'C';
               l_txmsg.txfields ('01').VALUE     := l_build_msg (indx).fld01; --set vale for CODEID

               l_txmsg.txfields ('07').defname   := 'SYMBOL';
               l_txmsg.txfields ('07').TYPE      := 'C';
               l_txmsg.txfields ('07').VALUE     := l_build_msg (indx).fld07; --set vale for Symbol

               l_txmsg.txfields ('60').defname   := 'ISMORTAGE';
               l_txmsg.txfields ('60').TYPE      := 'N';
               l_txmsg.txfields ('60').VALUE     := l_build_msg (indx).fld60; --set vale for Is mortage sell
               l_txmsg.txfields ('02').defname   := 'ACTYPE';
               l_txmsg.txfields ('02').TYPE      := 'C';
               -- l_txmsg.txfields ('02').VALUE     := l_build_msg (indx).fld02; --set vale for Product code
               -- this is set above
               l_txmsg.txfields ('03').defname   := 'AFACCTNO';
               l_txmsg.txfields ('03').TYPE      := 'C';
               l_txmsg.txfields ('03').VALUE     := l_build_msg (indx).fld03; --set vale for Contract number
               l_txmsg.txfields ('06').defname   := 'SEACCTNO';
               l_txmsg.txfields ('06').TYPE      := 'C';
               l_txmsg.txfields ('06').VALUE     := l_build_msg (indx).fld06; --set vale for SE account number
               l_txmsg.txfields ('50').defname   := 'CUSTNAME';
               l_txmsg.txfields ('50').TYPE      := 'C';
               --l_txmsg.txfields ('50').VALUE     := ''; --set vale for Customer name

               -- this was set above already
               l_txmsg.txfields ('20').defname   := 'TIMETYPE';
               l_txmsg.txfields ('20').TYPE      := 'C';
               l_txmsg.txfields ('20').VALUE     := l_build_msg (indx).fld20; --set vale for Duration
               l_txmsg.txfields ('21').defname   := 'EXPDATE';
               l_txmsg.txfields ('21').TYPE      := 'D';
               l_txmsg.txfields ('21').VALUE     := l_build_msg (indx).fld21; --set vale for Expired date
               l_txmsg.txfields ('19').defname   := 'EFFDATE';
               l_txmsg.txfields ('19').TYPE      := 'D';
               l_txmsg.txfields ('19').VALUE     := l_build_msg (indx).fld19; --set vale for Expired date
               l_txmsg.txfields ('22').defname   := 'EXECTYPE';
               l_txmsg.txfields ('22').TYPE      := 'C';
               --l_txmsg.txfields ('22').VALUE     := l_build_msg (indx).fld22; --set vale for Execution type
               l_txmsg.txfields ('23').defname   := 'NORK';
               l_txmsg.txfields ('23').TYPE      := 'C';
               l_txmsg.txfields ('23').VALUE     := l_build_msg (indx).fld23; --set vale for All or none?
               l_txmsg.txfields ('34').defname   := 'OUTPRICEALLOW';
               l_txmsg.txfields ('34').TYPE      := 'C';
               l_txmsg.txfields ('34').VALUE     := l_build_msg (indx).fld34; --set vale for Accept out amplitute price
               l_txmsg.txfields ('24').defname   := 'MATCHTYPE';
               l_txmsg.txfields ('24').TYPE      := 'C';
               l_txmsg.txfields ('24').VALUE     := l_build_msg (indx).fld24; --set vale for Matching type
               l_txmsg.txfields ('25').defname   := 'VIA';
               l_txmsg.txfields ('25').TYPE      := 'C';
               l_txmsg.txfields ('25').VALUE     := l_build_msg (indx).fld25; --set vale for Via
               l_txmsg.txfields ('10').defname   := 'CLEARDAY';
               l_txmsg.txfields ('10').TYPE      := 'N';
               l_txmsg.txfields ('10').VALUE     := l_build_msg (indx).fld10; --set vale for Clearing day
               l_txmsg.txfields ('26').defname   := 'CLEARCD';
               l_txmsg.txfields ('26').TYPE      := 'C';
               l_txmsg.txfields ('26').VALUE     := l_build_msg (indx).fld26; --set vale for Calendar
               l_txmsg.txfields ('72').defname   := 'PUTTYPE';
               l_txmsg.txfields ('72').TYPE      := 'C';
               l_txmsg.txfields ('72').VALUE     := l_build_msg (indx).fld72; --set vale for Puthought type
               l_txmsg.txfields ('27').defname   := 'PRICETYPE';
               l_txmsg.txfields ('27').TYPE      := 'C';
               l_txmsg.txfields ('27').VALUE     := l_build_msg (indx).fld27; --set vale for Price type

               l_txmsg.txfields ('11').defname   := 'QUOTEPRICE';
               l_txmsg.txfields ('11').TYPE      := 'N';
               l_txmsg.txfields ('11').VALUE     := l_build_msg (indx).fld11; --set vale for Limit price

               IF l_build_msg (indx).fld27 <> 'LO'
               THEN                                               -- Pricetype
                  IF l_strEXECTYPE='NB' --l_build_msg (indx).fld22 = 'NB'
                  THEN                                             -- exectype
                     l_txmsg.txfields ('11').VALUE   :=
                        l_build_msg (indx).ceilingprice
                        / l_build_msg (indx).fld98;                --tradeunit
                  ELSE
                     l_txmsg.txfields ('11').VALUE   :=
                        l_build_msg (indx).floorprice
                        / l_build_msg (indx).fld98;
                  END IF;
               END IF;

               plog.debug (pkgctx,
                           'Quoteprice: ' || l_txmsg.txfields ('11').VALUE
               );

               l_txmsg.txfields ('12').defname   := 'ORDERQTTY';
               l_txmsg.txfields ('12').TYPE      := 'N';
               l_txmsg.txfields ('12').VALUE     := l_build_msg (indx).fld12; --set vale for Quantity
               l_txmsg.txfields ('13').defname   := 'BRATIO';
               l_txmsg.txfields ('13').TYPE      := 'N';
               --l_txmsg.txfields ('13').VALUE     := l_build_msg (indx).fld13; --set vale for Block ration
               l_txmsg.txfields ('14').defname   := 'LIMITPRICE';
               l_txmsg.txfields ('14').TYPE      := 'N';
               l_txmsg.txfields ('14').VALUE     := l_build_msg (indx).fld14; --set vale for Stop price
               l_txmsg.txfields ('40').defname   := 'FEEAMT';
               l_txmsg.txfields ('40').TYPE      := 'N';
               l_txmsg.txfields ('40').VALUE     := l_build_msg (indx).fld40; --set vale for Fee amount
               l_txmsg.txfields ('28').defname   := 'VOUCHER';
               l_txmsg.txfields ('28').TYPE      := 'C';
               l_txmsg.txfields ('28').VALUE     := ''; --l_build_msg (indx).fld28; --set vale for Voucher status
               l_txmsg.txfields ('29').defname   := 'CONSULTANT';
               l_txmsg.txfields ('29').TYPE      := 'C';
               l_txmsg.txfields ('29').VALUE     := ''; --l_build_msg (indx).fld29; --set vale for Consultant status
               l_txmsg.txfields ('04').defname   := 'ORDERID';
               l_txmsg.txfields ('04').TYPE      := 'C';
               --l_txmsg.txfields ('04').VALUE     := l_build_msg (indx).fld04; --set vale for Order ID
               --this is set below
               l_txmsg.txfields ('15').defname   := 'PARVALUE';
               l_txmsg.txfields ('15').TYPE      := 'N';
               l_txmsg.txfields ('15').VALUE     := l_build_msg (indx).fld15; --set vale for Parvalue
               l_txmsg.txfields ('30').defname   := 'DESC';
               l_txmsg.txfields ('30').TYPE      := 'C';
               l_txmsg.txfields ('30').VALUE     := l_build_msg (indx).fld30; --set vale for Description

               l_txmsg.txfields ('95').defname   := 'DFACCTNO';
               l_txmsg.txfields ('95').TYPE      := 'C';
               l_txmsg.txfields ('95').VALUE     := l_build_msg (indx).fld95; --set vale for deal id

               l_txmsg.txfields ('99').defname   := 'HUNDRED';
               l_txmsg.txfields ('99').TYPE      := 'N';
               If l_strMarginType = 'N' Then
                    l_txmsg.txfields ('99').VALUE     := l_build_msg (indx).fld99;
               Else
                    If l_dblIsPPUsed = 1 Then
                        l_txmsg.txfields ('99').VALUE     := to_char(100 / (1 - l_dblMarginRatioRate / 100 * l_dblSecMarginPrice / l_build_msg (indx).fld11 / l_build_msg (indx).fld98));
                    Else
                        l_txmsg.txfields ('99').VALUE     := l_build_msg (indx).fld99;
                    End If;
               End If;

               l_txmsg.txfields ('98').defname   := 'TRADEUNIT';
               l_txmsg.txfields ('98').TYPE      := 'N';
               l_txmsg.txfields ('98').VALUE     := l_build_msg (indx).fld98; --set vale for Trade unit

               l_txmsg.txfields ('96').defname   := 'TRADEUNIT';
               l_txmsg.txfields ('96').TYPE      := 'N';
               l_txmsg.txfields ('96').VALUE     := 1; --l_build_msg (indx).fld96; --set vale for GTC

               l_txmsg.txfields ('97').defname   := 'MODE';
               l_txmsg.txfields ('97').TYPE      := 'C';
               l_txmsg.txfields ('97').VALUE     := l_build_msg (indx).fld97; --set vale for MODE DAT LENH
               l_txmsg.txfields ('33').defname   := 'CLIENTID';
               l_txmsg.txfields ('33').TYPE      := 'C';
               l_txmsg.txfields ('33').VALUE     := l_build_msg (indx).fld33; --set vale for ClientID
               l_txmsg.txfields ('73').defname   := 'CONTRAFIRM';
               l_txmsg.txfields ('73').TYPE      := 'C';
               l_txmsg.txfields ('73').VALUE     := l_build_msg (indx).fld73; --set vale for Contrafirm
               l_txmsg.txfields ('32').defname   := 'TRADERID';
               l_txmsg.txfields ('32').TYPE      := 'C';
               l_txmsg.txfields ('32').VALUE     := l_build_msg (indx).fld32; --set vale for TraderID
               l_txmsg.txfields ('71').defname   := 'CONTRACUS';
               l_txmsg.txfields ('71').TYPE      := 'C';
               l_txmsg.txfields ('71').VALUE     := ''; --l_build_msg (indx).fld71; --set vale for Contra custody
               l_txmsg.txfields ('31').defname   := 'CONTRAFIRM';
               l_txmsg.txfields ('31').TYPE      := 'C';
               l_txmsg.txfields ('31').VALUE     := l_build_msg (indx).fld31; --set vale for Contrafirm
               --TuanNH add field 90 giao dich sua loi
               l_txmsg.txfields ('90').defname   := 'TRADESTATUS';
               l_txmsg.txfields ('90').TYPE      := 'N';
               l_txmsg.txfields ('90').VALUE     := 0;
               l_remainqtty                      :=
                  l_txmsg.txfields ('12').VALUE;

               l_txmsg.txfields ('08').VALUE     :=
                  l_build_msg (indx).orgacctno;
               plog.debug (pkgctx,
                           'cancel orderid: '
                           || l_txmsg.txfields ('08').VALUE
               );

               l_order_count                     := 0;         --RESET COUNTER

               plog.debug (pkgctx, 'l_remainqtty: ' || l_remainqtty);

               WHILE l_remainqtty > 0                               --quantity
               LOOP
                  SAVEPOINT sp#2;
                  l_order_count   := l_order_count + 1;

                  IF l_build_msg (indx).tradeplace = '001'
                  THEN                                                 -- HOSE
                     l_txmsg.txfields ('12').VALUE   :=
                        CASE
                           WHEN l_remainqtty > l_hosebreakingsize
                           THEN
                              l_hosebreakingsize
                           ELSE
                              l_remainqtty
                        END;
                  ELSE
                     l_txmsg.txfields ('12').VALUE   := l_remainqtty; --quantity
                  END IF;

                  --2.1 Set txnum
                  SELECT systemnums.c_fo_prefixed
                         || LPAD (seq_fotxnum.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;

                  --v_strOrderID = FO_PREFIXED & "00" 1(Replace(v_strTXDATE, "/", vbNullString), 1, 4) 1(Replace(v_strTXDATE, "/", vbNullString), 7, 2) Right(gc_FORMAT_ODAUTOID (v_DataAccess.GetIDValue("ODMAST")), Len(gc_FORMAT_ODAUTOID))
                  /*SELECT    systemnums.c_fo_prefixed
                         || '00'
                         || TO_CHAR (SYSDATE, 'DDMMRR')
                         || LPAD (seq_odmast.NEXTVAL, 6, '0')
                  INTO l_txmsg.txfields ('04').VALUE
                  FROM DUAL;*/
                  SELECT    systemnums.c_fo_prefixed
                         || '00'
                         || TO_CHAR(TO_DATE (VARVALUE, 'DD\MM\RR'),'DDMMRR')
                         || LPAD (seq_odmast.NEXTVAL, 6, '0')
                  INTO l_txmsg.txfields ('04').VALUE
                  FROM SYSVAR WHERE VARNAME ='CURRDATE' AND GRNAME='SYSTEM';

                  plog.debug (pkgctx,
                              'ORDERID: ' || l_txmsg.txfields ('04').VALUE
                  );

                  plog.debug (pkgctx,
                              'MATCHTYPE: ' || l_txmsg.txfields ('24').VALUE
                  );
                  plog.debug (pkgctx,
                              'ORGEXECTYPE: '
                              || l_txmsg.txfields ('22').VALUE
                  );
                  plog.debug (pkgctx,
                              'SYMBOL: ' || l_txmsg.txfields ('07').VALUE
                  );
                  plog.debug (pkgctx,
                              'QTTY: ' || l_txmsg.txfields ('12').VALUE
                  );
                  plog.debug (pkgctx,
                              'QUOTEPRICE: ' || l_txmsg.txfields ('11').VALUE
                  );

                  SELECT REGEXP_REPLACE (l_txmsg.txfields ('04').VALUE,
                                         '(^[[:digit:]]{4})([[:digit:]]{2})([[:digit:]]{10}$)',
                                         '\1.\2.\3.'
                         )
                         || l_fullname
                         || '.'
                         || l_txmsg.txfields ('24').VALUE          --MATCHTYPE
                         || l_txmsg.txfields ('22').VALUE       ---ORGEXECTYPE
                         || '.'
                         || l_txmsg.txfields ('07').VALUE             --SYMBOL
                         || '.'
                         || l_txmsg.txfields ('12').VALUE
                         || '.'
                         || l_txmsg.txfields ('11').VALUE         --QUOTEPRICE
                  INTO l_txmsg.txfields ('30').VALUE
                  FROM DUAL;

                  plog.debug (pkgctx,
                              'DESC: ' || l_txmsg.txfields ('30').VALUE
                  );


                  -- Get tltxcd from EXECTYPE
                  IF l_txmsg.txfields ('22').VALUE = 'NB'               --8876
                  THEN
                     BEGIN
                        l_txmsg.tltxcd   := '8876'; -- gc_OD_PLACENORMALBUYORDER_ADVANCED

                        -- 2: Process
                        IF txpks_#8876.fn_autotxprocess (l_txmsg,
                                                         l_err_code,
                                                         l_err_param
                           ) <> systemnums.c_success
                        THEN
                           plog.debug (pkgctx,
                                       'got error 8876: ' || l_err_code
                           );
                           --ONLY ROLLBACK FOR THIS MESSAGE
                           ROLLBACK TO SAVEPOINT sp#2;
                           --EXIT; -- UNCOMMENT THIS IF YOU WANT TO EXIT LOOP WHEN GOT AN ERROR
                           RAISE errnums.e_biz_rule_invalid;
                        END IF;
                     END;                                               --8876
                  ELSIF l_build_msg (indx).fld22 IN ('NS', 'MS', 'SS')  --8877
                  THEN
                     BEGIN
                        l_txmsg.tltxcd   := '8877'; --gc_OD_PLACENORMALSELLORDER_ADVANCED

                        -- 2: Process
                        IF txpks_#8877.fn_autotxprocess (l_txmsg,
                                                         l_err_code,
                                                         l_err_param
                           ) <> systemnums.c_success
                        THEN
                           plog.debug (pkgctx,
                                          '8877: '
                                       || l_err_code
                                       || ':'
                                       || l_err_param
                           );
                           --ONLY ROLLBACK FOR THIS MESSAGE
                           ROLLBACK TO SAVEPOINT sp#2;
                           --EXIT; -- UNCOMMENT THIS IF YOU WANT TO EXIT LOOP WHEN GOT AN ERROR
                           RAISE errnums.e_biz_rule_invalid;
                        END IF;
                     END;                                              -- 8887
                  ELSIF l_build_msg (indx).fld22 = 'AB'                 --8884
                  THEN
                     BEGIN
                        l_txmsg.tltxcd   := '8884';  --gc_OD_AMENDMENTBUYORDER

                        -- 2: Process
                        IF txpks_#8884.fn_autotxprocess (l_txmsg,
                                                         l_err_code,
                                                         l_err_param
                           ) <> systemnums.c_success
                        THEN
                           plog.debug (pkgctx,
                                       'got error 8884: ' || l_err_code
                           );
                           --ONLY ROLLBACK FOR THIS MESSAGE
                           ROLLBACK TO SAVEPOINT sp#2;
                           --EXIT; -- UNCOMMENT THIS IF YOU WANT TO EXIT LOOP WHEN GOT AN ERROR
                           RAISE errnums.e_biz_rule_invalid;
                        END IF;
                     END;                                               --8884
                  ELSIF l_build_msg (indx).fld22 = 'AS'                 --8885
                  THEN
                     BEGIN
                        l_txmsg.tltxcd   := '8885'; --gc_OD_AMENDMENTSELLORDER

                        -- 2: Process
                        IF txpks_#8885.fn_autotxprocess (l_txmsg,
                                                         l_err_code,
                                                         l_err_param
                           ) <> systemnums.c_success
                        THEN
                           plog.debug (pkgctx,
                                       'got error 8885: ' || l_err_code
                           );
                           --ONLY ROLLBACK FOR THIS MESSAGE
                           ROLLBACK TO SAVEPOINT sp#2;
                           --EXIT; -- UNCOMMENT THIS IF YOU WANT TO EXIT LOOP WHEN GOT AN ERROR
                           RAISE errnums.e_biz_rule_invalid;
                        END IF;
                     END;                                               --8885
                  ELSIF l_build_msg (indx).fld22 = 'CB'                 --8882
                  THEN
                     BEGIN
                        l_txmsg.tltxcd   := '8882';     --gc_OD_CANCELBUYORDER

                        -- 2: Process
                        IF txpks_#8882.fn_autotxprocess (l_txmsg,
                                                         l_err_code,
                                                         l_err_param
                           ) <> systemnums.c_success
                        THEN
                           plog.debug (pkgctx,
                                       'got error 8882: ' || l_err_code
                           );
                           --ONLY ROLLBACK FOR THIS MESSAGE
                           ROLLBACK TO SAVEPOINT sp#2;
                           --EXIT; -- UNCOMMENT THIS IF YOU WANT TO EXIT LOOP WHEN GOT AN ERROR
                           RAISE errnums.e_biz_rule_invalid;
                        END IF;
                     END;                                               --8882
                  ELSIF l_build_msg (indx).fld22 = 'CS'                 --8883
                  THEN
                     BEGIN
                        l_txmsg.tltxcd   := '8883';    --gc_OD_CANCELSELLORDER

                        -- 2: Process
                        IF txpks_#8883.fn_autotxprocess (l_txmsg,
                                                         l_err_code,
                                                         l_err_param
                           ) <> systemnums.c_success
                        THEN
                           plog.debug (pkgctx,
                                       'got error 8883: ' || l_err_code
                           );
                           --ONLY ROLLBACK FOR THIS MESSAGE
                           ROLLBACK TO SAVEPOINT sp#2;
                           --EXIT; -- UNCOMMENT THIS IF YOU WANT TO EXIT LOOP WHEN GOT AN ERROR
                           RAISE errnums.e_biz_rule_invalid;
                        END IF;
                     END;
                  END IF;

                  UPDATE fomast
                  SET orgacctno    = l_txmsg.txfields ('04').VALUE, last_change = SYSTIMESTAMP ,
                      status       = 'A',
                      feedbackmsg   =
                         'Order is active and sucessfull processed: '
                         || l_txmsg.txfields ('04').VALUE
                  WHERE acctno = l_build_msg (indx).acctno;

                  INSERT INTO rootordermap
                 (
                     foacctno,
                     orderid,
                     status,
                     MESSAGE,
                     id
                 )
                  VALUES (
                            l_build_msg (indx).acctno,
                            l_txmsg.txfields ('04').VALUE,
                            'A',
                            '[' || systemnums.c_success || '] OK,',
                            l_order_count
                         );

                  l_remainqtty    :=
                     l_remainqtty - TO_NUMBER (l_txmsg.txfields ('12').VALUE);
                  plog.debug (pkgctx,
                                 'l_remainqtty('
                              || l_order_count
                              || '):'
                              || l_remainqtty
                  );

                  -- COMMIT IN CASE OF ORDER BREAKING
                  IF l_count >= l_commit_freq
                  THEN
                     l_count   := 0;          -- reset the commit freq counter
                     COMMIT;
                  END IF;
               END LOOP;

               IF l_count >= l_commit_freq
               THEN
                  l_count   := 0;             -- reset the commit freq counter
                  COMMIT;
               END IF;
            EXCEPTION
               WHEN errnums.e_od_odtype_notfound
               THEN
                  UPDATE fomast
                  SET status    = 'R', last_change = SYSTIMESTAMP,
                             feedbackmsg   =
                                '[' || errnums.c_od_odtype_notfound || '] '
                                || cspks_system.fn_get_errmsg(errnums.c_od_odtype_notfound)
                  WHERE acctno = l_build_msg (indx).acctno;
               WHEN errnums.e_invalid_session
               THEN
                  -- Log error and continue to process the next order
                  plog.error (pkgctx,
                                 'INVALID SESSION(pricetype,mktstatus):'
                              || l_build_msg (indx).fld27
                              || ','
                              || l_mktstatus
                  );

                  UPDATE fomast
                  SET status    = 'R', last_change = SYSTIMESTAMP,
                      feedbackmsg   =
                         '[' || errnums.c_invalid_session || '] '
                         || cspks_system.fn_get_errmsg(errnums.c_invalid_session)
                  WHERE acctno = l_build_msg (indx).acctno;
               --LogOrderMessage(v_ds.Tables(0).Rows(i)("ACCTNO"))
               WHEN errnums.e_biz_rule_invalid
               THEN
                  UPDATE fomast
                  SET status        = 'R', last_change = SYSTIMESTAMP,
                      feedbackmsg   = '[' || l_err_code || '] ' || l_err_param
                  WHERE acctno = l_build_msg (indx).acctno;

                  INSERT INTO rootordermap
                 (
                     foacctno,
                     orderid,
                     status,
                     MESSAGE,
                     id
                 )
                  VALUES (
                            l_build_msg (indx).acctno,
                            '',
                            'R',
                            '[' || l_err_code || '] ' || l_err_param,
                            l_order_count
                         );
            END;
         END LOOP;
      END LOOP;

      CLOSE curs_build_msg;

      COMMIT;                                -- Commit the last trunk (if any)
      /***************************************************************************************************
      ** END;
      ***************************************************************************************************/
      plog.debug (pkgctx, '<<END OF pr_fo2od');
      plog.setendsection (pkgctx, 'pr_fo2od');
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         plog.error (pkgctx, SQLERRM);

         CLOSE curs_build_msg;

         plog.setendsection (pkgctx, 'pr_fo2od');
   END pr_fo2od;
   PROCEDURE pr_init (p_level number)
   IS
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
      plog.init ('txpks_trdpks_auto',
                 plevel => NVL (logrow.loglevel, 30),
                 plogtable => (NVL (logrow.log4table, 'N') = 'Y'),
                 palert => (NVL (logrow.log4alert, 'N') = 'Y'),
                 ptrace => (NVL (logrow.log4trace, 'N') = 'Y')
      );
   -- plog.error('level2: ' || logrow.loglevel);
   END;

PROCEDURE PR_CANCEL_ORDER IS
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

   Cursor c_SqlMaster Is
        SELECT  * FROM
        (
        SELECT OD.ORDERID,OD.CODEID,SEC.SYMBOL,B.CUSTODYCD,OD.AFACCTNO,OD.SEACCTNO,OD.CIACCTNO,B.BSCA BORS,B.NORP,OD.NORK AORN,
        OD.QUOTEPRICE EXPRICE, OD.ORDERQTTY EXQTTY, A.CANCELQUANTITY QTTY,A.ORDERNUMBER REFORDERID,
        OD.BRATIO,OD.CLEARDAY,OD.CLEARCD, 'Huy lenh ' || OD.ORDERID DESCRIPTION
        FROM ODMAST OD,SBSECURITIES SEC,STCCANCELORDERBOOK A,STCORDERBOOK B
        WHERE OD.ORDERID=B.ORDERID
            AND  A.ORDERNUMBER=B.ORDERNUMBER
            AND OD.CODEID=SEC.CODEID
            AND SEC.TRADEPLACE<>'005'
            AND OD.EDSTATUS <> 'W'
            AND od.remainqtty > 0)
        order by REFORDERID;
        -- WHERE  ROWNUM <= 30;

BEGIN

      plog.setbeginsection (pkgctx, 'pr_cancel_order');
      plog.debug (pkgctx, 'BEGIN OF pr_cancel_order');
      plog.debug (pkgctx, 'BEGIN OF pr_cancel_order1111');
      /***************************************************************************************************
       ** PUT YOUR CODE HERE, FOLLOW THE BELOW TEMPLATE:
       ** IF NECCESSARY, USING BULK COLLECTION IN THE CASE YOU MUST POPULATE LARGE DATA
      ****************************************************************************************************/

      -- 1. Set common values

      v_brid := '0000';
      v_tlid := '0000';
      v_ipaddress := 'HOST';
      v_wsname := 'HOST';

      For i in c_SqlMaster
      Loop
       --0 lay cac tham so
       v_brid := '0000';
       v_tlid := '0000';
       v_ipaddress := 'HOST';
       v_wsname := 'HOST';
       v_cancelqtty := i.qtty;
       --Kiem tra thoa man dieu kien huy
   BEGIN
      plog.debug (pkgctx, 'i.orderid' || i.orderid);
    v_desc := i.description;
    SELECT ORDERQTTY,REMAINQTTY,EXECQTTY,CANCELQTTY,ORSTATUS,Exectype
    INTO V_ORDERQTTY_CUR,V_REMAINQTTY_CUR,V_EXECQTTY_CUR,V_CANCELQTTY_CUR,V_ORSTATUS_CUR,v_trExectype
    FROM ODMAST WHERE ORDERID =i.orderid;
   EXCEPTION WHEN OTHERS THEN
             plog.setendsection (pkgctx, 'pr_cancel_order');
     RETURN;
   END;
   IF V_REMAINQTTY_CUR - V_CANCELQTTY < 0 OR V_EXECQTTY_CUR >= V_ORDERQTTY_CUR  OR V_CANCELQTTY = 0
   THEN
                plog.setendsection (pkgctx, 'pr_cancel_order');
    RETURN;
   END IF;

   --Lenh huy thong thuong: Co lenh huy 1C
   SELECT count(*) INTO v_Count_lenhhuy FROM odmast WHERE reforderid =I.ORDERID AND exectype IN ('CB','CS');
plog.debug (pkgctx, 'v_Count_lenhhuy' || v_Count_lenhhuy);
   IF v_Count_lenhhuy >0 Then
        SELECT (CASE
                      WHEN exectype = 'CB'
                         THEN '8890'
                      ELSE '8891'
                   END), sb.symbol,
                  od.afacctno, od.seacctno, od.quoteprice, od.orderqtty, od.bratio,
                  0, od.quoteprice, 0, od.orderqtty - i.qtty,
                  od.reforderid, sb.tradeunit, od.edstatus
             INTO v_tltxcd, v_symbol,
                  v_afaccount, v_seacctno, v_price, v_quantity, v_bratio,
                  v_amendmentqtty, v_amendmentprice, v_matchedqtty, v_execqtty,
                  v_reforderid, v_tradeunit, v_edstatus
             FROM odmast od, securities_info sb
            WHERE od.codeid = sb.codeid AND reforderid = i.orderid;
   ELSE
    --Giai toa ATO
            SELECT (CASE
                      WHEN EXECTYPE LIKE '%B'
                         THEN '8808'
                      ELSE '8807'
                   END), sb.symbol,
                  od.afacctno, od.seacctno, od.quoteprice, od.orderqtty, od.bratio,
                  0, od.quoteprice, 0, od.orderqtty - i.qtty,
                  od.reforderid, sb.tradeunit, od.edstatus
             INTO v_tltxcd, v_symbol,
                  v_afaccount, v_seacctno, v_price, v_quantity, v_bratio,
                  v_amendmentqtty, v_amendmentprice, v_matchedqtty, v_execqtty,
                  v_reforderid, v_tradeunit, v_edstatus
             FROM odmast od, securities_info sb
            WHERE od.codeid = sb.codeid AND orderid = i.orderid;
    END IF;


   v_advancedamount := 0;



   SELECT bratio
     INTO v_oldbratio
     FROM odmast
    WHERE orderid = i.orderid;

      --NEU CHUA BI HUY THI KHI NHAN DUOC MESSAGE TRA VE SE THUC HIEN HUY LENH
      SELECT varvalue
        INTO v_txdate
        FROM sysvar
       WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';

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
                   '', '', '1', i.orderid, v_quantity, '',
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
      VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/YYYY'),'04',0,i.orderid,NULL);
      INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
      VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/YYYY'),'06',0,v_seacctno,NULL);
      INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
      VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/YYYY'),'08',0,i.orderid,NULL);
      INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
      VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/YYYY'),'14',v_cancelqtty,NULL,NULL);
      INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
      VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/YYYY'),'11',v_price,NULL,NULL);
      INSERT INTO tllogfld(AUTOID,TXNUM,TXDATE,FLDCD,NVALUE,CVALUE,TXDESC)
      VALUES (seq_tllogfld.NEXTVAL,v_txnum,TO_DATE (v_txdate, 'DD/MM/YYYY'),'12',v_quantity,NULL,NULL);
      --2 THEM VAO TRONG TLLOGFLD

          v_edstatus := 'W';
          UPDATE odmast
             SET edstatus = v_edstatus,last_change = SYSTIMESTAMP
          WHERE orderid = i.orderid;

      If v_Count_lenhhuy >0 then
          v_edstatus := 'W';
          UPDATE odmast
             SET edstatus = v_edstatus,last_change = SYSTIMESTAMP
          WHERE orderid = i.orderid;

          UPDATE OOD SET OODSTATUS = 'S'
          WHERE   ORGORDERID IN (SELECT ORDERID FROM ODMAST  WHERE REFORDERID = i.orderid)
          and OODSTATUS <> 'S';

      Else
        --OOD: Cap nhat E
        --ODMAST:
        --Update OOD set OODSTATUS ='E' where ORGORDERID =i.orderid;
        Update ODMAST set ORSTATUS ='5', last_change = SYSTIMESTAMP where Orderqtty =Remainqtty And ORDERID =i.orderid;

      End if;
      --3 CAP NHAT TRAN VA MAST
      IF v_tltxcd = '8890' OR v_tltxcd = '8808'
      THEN
         --BUY
         UPDATE odmast
            SET cancelqtty = cancelqtty + v_cancelqtty,
                remainqtty = remainqtty - v_cancelqtty, last_change = SYSTIMESTAMP
          WHERE orderid = i.orderid;
          plog.debug (pkgctx, 'BEGIN OF pr_cancel_order6');

/*
         UPDATE odmast
            SET
            rlssecured = rlssecured +
            v_cancelqtty * v_price * v_oldbratio / 100
          WHERE orderid = i.orderid;


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
                      i.orderid, '0014', v_cancelqtty, NULL, NULL, 'N',
                      NULL, seq_odtran.NEXTVAL
                     );

         INSERT INTO odtran
                     (txnum, txdate,
                      acctno, txcd, namt, camt, acctref, deltd,
                      REF, autoid
                     )
              VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'),
                      i.orderid, '0011', v_cancelqtty, NULL, NULL, 'N',
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
                      i.orderid, '0030',
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
                      NULL, i.orderid, 'N', NULL, seq_citran.NEXTVAL
                     );

         INSERT INTO citran
                     (txnum, txdate, acctno,
                      txcd, namt,
                      camt, REF, deltd, acctref, autoid
                     )
              VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'), v_afaccount,
                      '0017', v_cancelqtty * v_price * v_oldbratio / 100,
                      NULL, i.orderid, 'N', NULL, seq_citran.NEXTVAL
                     );
*/
      ELSE                                                   --v_tltxcd='8891' , '8807'
         --SELL
         UPDATE odmast
            SET cancelqtty = cancelqtty + v_cancelqtty,
                remainqtty = remainqtty - v_cancelqtty, last_change = SYSTIMESTAMP
          WHERE orderid = i.orderid;

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
                      i.orderid, '0014', v_cancelqtty, NULL, NULL, 'N',
                      NULL, seq_odtran.NEXTVAL
                     );

         INSERT INTO odtran
                     (txnum, txdate,
                      acctno, txcd, namt, camt, acctref, deltd,
                      REF, autoid
                     )
              VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'),
                      i.orderid, '0011', v_cancelqtty, NULL, NULL, 'N',
                      NULL, seq_odtran.NEXTVAL
                     );
/*
         INSERT INTO setran
                     (txnum, txdate, acctno,
                      txcd, namt, camt, REF, deltd,
                      autoid
                     )
              VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'), v_seacctno,
                      '0012', v_cancelqtty, NULL, i.orderid, 'N',
                      seq_setran.NEXTVAL
                     );

         INSERT INTO setran
                     (txnum, txdate, acctno,
                      txcd, namt, camt, REF, deltd,
                      autoid
                     )
              VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'), v_seacctno,
                      '0018', v_cancelqtty, NULL, i.orderid, 'N',
                      seq_setran.NEXTVAL
                     );
*/
      END IF;
COMMIT;
    END LOOP;
             plog.setendsection (pkgctx, 'pr_cancel_order');
                   IF c_SqlMaster%ISOPEN THEN
             CLOSE c_SqlMaster;
             END IF;
   --COMMIT;
EXCEPTION
   WHEN others
   THEN
            plog.error (pkgctx, SQLERRM);
            plog.setendsection (pkgctx, 'pr_cancel_order');
   ROLLBACK;
END PR_CANCEL_ORDER;

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
      plog.init ('txpks_trdpks_auto',
                 plevel => NVL (logrow.loglevel, 30),
                 plogtable => (NVL (logrow.log4table, 'N') = 'Y'),
                 palert => (NVL (logrow.log4alert, 'N') = 'Y'),
                 ptrace => (NVL (logrow.log4trace, 'N') = 'Y')
      );
   -- plog.error('level2: ' || logrow.loglevel);

END trdpks_auto;
/
