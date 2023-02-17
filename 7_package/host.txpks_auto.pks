SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_auto
IS
     PROCEDURE pr_fo2od;

     PROCEDURE pr_init (p_level number);

     PROCEDURE pr_trade_allocating;

  PROCEDURE pr_fo2odsyn (p_orderid varchar2, p_err_code  OUT VARCHAR2, p_timetype varchar2 default 'T' );
  PROCEDURE pr_fo2odbyorder (p_orderid varchar2, p_err_code  OUT varchar2 );
  PROCEDURE pr_fobanksyn;
  PROCEDURE pr_ExternalTransfer(p_account varchar,p_bankid varchar2,p_benefbank varchar2,p_benefacct varchar2,p_benefcustname varchar2,p_beneflicense varchar2, p_amount number,p_feeamt number,p_vatamt number,p_desc varchar2,p_err_code  OUT varchar2,p_txdate  OUT varchar2,p_txnum  OUT varchar2);
  PROCEDURE pr_InternalTransfer(p_account varchar,p_toaccount  varchar2,p_amount number,p_desc varchar2,p_err_code  OUT varchar2,p_txdate  OUT varchar2,p_txnum  OUT varchar2);
  PROCEDURE pr_RightoffRegiter(p_camastid varchar,p_account varchar,p_qtty number,p_desc varchar2,p_err_code  OUT varchar2,p_txdate  OUT varchar2,p_txnum  OUT varchar2);

  PROCEDURE pr_RevertTransfer(p_tltxcd IN VARCHAR2,p_txdate IN  varchar2,p_txnum IN  VARCHAR2,p_err_code  OUT varchar2);
  PROCEDURE pr_ReceiveTransfer(p_account varchar,p_bankid varchar2,p_bankacctno varchar2, p_glmast varchar2,p_refnum varchar2,p_amount number,p_desc varchar2,p_err_code  OUT varchar2,p_txdate  OUT varchar2,p_txnum  OUT varchar2);
  PROCEDURE pr_AllocateGuarantee(p_account varchar,p_amount number,p_desc varchar2,p_err_code  OUT varchar2,p_txdate  OUT varchar2,p_txnum  OUT varchar2);
----GianhVG
  /*PROCEDURE pr_DealLoanPayment(p_account varchar2,p_prinAmount  varchar2,p_intAmount number,p_fee number,p_err_code  OUT varchar2,p_txdate  OUT varchar2,p_txnum  OUT varchar2);*/
  PROCEDURE pr_CreateDeal(p_afacctno varchar2,p_codeid varchar2,p_refpricetype varchar2,p_dftype varchar2,p_qtty number, p_refprice number, p_refnum varchar2,p_err_code  OUT varchar2,p_txdate  OUT varchar2,p_txnum  OUT varchar2);
  PROCEDURE pr_DealPayment(p_account varchar2,p_prinAmount  varchar2,p_err_code  OUT varchar2,p_txdate  OUT varchar2,p_txnum  OUT varchar2);

  PROCEDURE pr_WithdrawTermDeposit(p_acctno varchar2,p_amount number,p_err_code  OUT varchar2,p_txdate  OUT varchar2,p_txnum  OUT varchar2);

  PROCEDURE pr_gtc2od(pv_strFunctype varchar2);
  PROCEDURE pr_fo2odsyn_bl (p_orderid varchar2, p_err_code  OUT VARCHAR2, p_timetype varchar2 default 'T' );
  ----End of GianhVG
END;
 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY txpks_auto
-- Refactored procedure pr_autotxprocess

IS
   pkgctx   plog.log_ctx:= plog.init ('txpks_txpks_auto',
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
             --a.expdate fld21,
             getcurrdate fld21,
             a.exectype fld22,
             a.outpriceallow fld34,
             a.nork fld23,
             a.matchtype fld24,
             a.via fld25,
             a.clearday fld10,
             a.clearcd fld26,
             'O' fld72,                                       --puttype fld72,
             (CASE WHEN a.exectype IN ('AB','AS') AND a.pricetype='MTL' THEN 'LO'
                       WHEN a.pricetype = 'RP' THEN FN_GETPRICETYPE4RP(b.tradeplace) --DUCNV sua lenh RP
                       ELSE a.pricetype
                  END ) fld27,
              -- PhuongHT edit for sua lenh MTL
             a.quantity fld12,                      --a.ORDERQTTY       fld12,
             a.quoteprice fld11,
             0 fld18,                               --a.ADVSCRAMT       fld18,
             0 fld17,                               --a.ORGQUOTEPRICE   fld17,
             0 fld16,                               --a.ORGORDERQTTY    fld16,
             0 fld31,                               --a.ORGSTOPPRICE    fld31,
             a.bratio fld13,
             a.limitprice fld14,                               --a.LIMITPRICE      fld14,
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
             c.marginrefprice,
             b.tradeplace,
             b.sectype,
             c.tradelot,
             c.securedratiomin,
             c.securedratiomax,
             a.SPLOPT,
             a.SPLVAL,
             a.ISDISPOSAL,
             a.username username,
             a.SSAFACCTNO fld94,
             '' fld35,
             a.tlid tlid,
             a.quoteqtty fld80,
             a.blorderid
      FROM fomast a, sbsecurities b, securities_info c
      WHERE     a.book = 'A'
            AND a.timetype <> 'G'
            AND a.status = 'P'
            and a.direct='N'
            and ((a.pricetype = 'LO' and a.quoteprice <> 0) or (a.pricetype <> 'LO'))
            and a.quantity <> 0
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
   v_temp       number(10);
   l_trfbuyext  number(10);

   Cursor c_SqlMaster Is
        SELECT  * FROM (select * from
        (
        SELECT OD.ORDERID,OD.CODEID,SEC.SYMBOL,B.CUSTODYCD,OD.AFACCTNO,OD.SEACCTNO,OD.CIACCTNO,B.BSCA BORS,B.NORP,OD.NORK AORN,
        OD.QUOTEPRICE EXPRICE, OD.ORDERQTTY EXQTTY, A.VOLUME QTTY,A.PRICE PRICE,A.ORDERNUMBER REFORDERID, A.REFCONFIRMNUMBER CONFIRM_NO,
        OD.BRATIO,OD.CLEARDAY,OD.CLEARCD, B.CUSTODYCD || '.' || B.BSCA || '.' || SEC.SYMBOL || '.' || A.VOLUME || '.' || A.PRICE  DESCRIPTION
        , SEC.TRADEPLACE
        FROM ODMAST OD,afmast af,SBSECURITIES SEC,STCTRADEBOOK A,STCORDERBOOK B
        WHERE OD.ORDERID=B.ORDERID AND  A.ORDERNUMBER=B.ORDERNUMBER AND OD.CODEID=SEC.CODEID
        and od.afacctno = af.acctno
        MINUS
        SELECT OD.ORDERID,OD.CODEID,SEC.SYMBOL,B.CUSTODYCD,OD.AFACCTNO,OD.SEACCTNO,OD.CIACCTNO,B.BSCA BORS,B.NORP,OD.NORK AORN,
        OD.QUOTEPRICE EXPRICE, OD.ORDERQTTY EXQTTY, A.VOLUME QTTY,A.PRICE PRICE,A.ORDERNUMBER REFORDERID, A.REFCONFIRMNUMBER CONFIRM_NO,
        OD.BRATIO,OD.CLEARDAY,OD.CLEARCD , B.CUSTODYCD || '.' || B.BSCA || '.' || SEC.SYMBOL || '.' || A.VOLUME || '.' || A.PRICE  DESCRIPTION
        ,SEC.TRADEPLACE
        FROM ODMAST OD,afmast af,SBSECURITIES SEC, STCTRADEBOOK A,STCORDERBOOK B,STCTRADEALLOCATION C
        WHERE OD.ORDERID=B.ORDERID AND  A.ORDERNUMBER=B.ORDERNUMBER and od.afacctno = af.acctno
        AND A.REFCONFIRMNUMBER=C.REFCONFIRMNUMBER AND OD.CODEID=SEC.CODEID AND C.DELTD<>'Y'
        ) order by CONFIRM_NO );-- WHERE  ROWNUM <= 30;

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

       IF c_Odmast_check%FOUND THEN
            v_RemainQtty:=VC_ODMAST.REMAINQTTY;
       END IF;
       CLOSE c_Odmast_check;

       If v_RemainQtty >= i.QTTY THEN

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


              SELECT varvalue
                INTO v_txdate
                FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';


            v_txdesc := i.CUSTODYCD||'.'||i.BORS||'.'||i.SYMBOL||'.'||i.QTTY||'.'||i.PRICE;
  --1.TLLOG
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
/*

            UPDATE afmast
             SET dmatchamt = NVL(dmatchamt,0) + i.PRICE * i.QTTY
             WHERE acctno = i.AFACCTNO;*/


  --6.IOD
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
           --Cap nhat Odmast
           UPDATE odmast
           SET execamt = NVL(execamt,0) + i.PRICE * i.QTTY,
               execqtty = NVL(execqtty,0) + i.QTTY,
               matchamt = NVL(matchamt,0) + i.PRICE * i.QTTY,
               porstatus = porstatus || '4',
               orstatus = '4',
               remainqtty = remainqtty - i.QTTY
           WHERE orderid = i.orderid;



           INSERT INTO stctradeallocation
                        (txdate, txnum,
                         refconfirmnumber, orderid, bors, volume, price, deltd
                        )
                 VALUES (TO_DATE (v_txdate, 'dd/MM/yyyy'), v_txnum ,
                         i.CONFIRM_NO, i.ORDERID, i.BORS, i.QTTY, i.PRICE, 'N'
                        );
   --8.Tao lich thanh toan
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
                                 i.QTTY, 0, 0, 'N', 'N', 0, getduedate(TO_DATE (v_txdate, 'DD/MM/YYYY'),i.CLEARCD,/*'000'*/I.TRADEPLACE,i.CLEARDAY)--ngoc.vu-Jira561
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
                                 qtty, aqtty, famt, status, deltd, costprice, cleardate
                                )
                         VALUES (seq_stschd.NEXTVAL, i.ORDERID, i.CODEID,
                                 v_strduetype, i.AFACCTNO, i.AFACCTNO,
                                 i.REFORDERID, v_txnum,
                                 TO_DATE (v_txdate, 'DD/MM/YYYY'), least(v_mtrfday,l_trfbuyext),
                                 i.CLEARCD, i.PRICE * i.QTTY, 0,
                                 i.QTTY, 0, 0, 'N', 'N', 0, getduedate(TO_DATE (v_txdate, 'DD/MM/YYYY'),i.clearcd,/*'000'*/i.TRADEPLACE,least(v_mtrfday,l_trfbuyext)) --ngoc.vu-Jira561
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
                         i.QTTY, 0, 0, 'N', 'N', 0,getduedate(TO_DATE (v_txdate, 'DD/MM/YYYY'),i.CLEARCD,/*'000'*/i.TRADEPLACE,0) --ngoc.vu-Jira561
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
                         i.QTTY, 0, 0, 'N', 'N', 0,getduedate(TO_DATE (v_txdate, 'DD/MM/YYYY'),i.CLEARCD,/*'000'*/i.TRADEPLACE, i.CLEARDAY) --ngoc.vu-Jira561
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
              --WHERE ORGACCTNO= i.ORDERID;
             WHERE ACCTNO= VC_ODMAST.FOACCTNO;
        END IF;
       CLOSE C_ODMAST;

       COMMIT;
       END IF;
   End Loop;

  -- CLOSE c_SqlMaster;

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

         CLOSE c_SqlMaster;

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
      l_ordervia            odmast.via%TYPE;

      l_feeamountmin        NUMBER;
      l_feerate             NUMBER;
      l_feesecureratiomin   NUMBER;
      l_hosebreakingsize    NUMBER;
      l_hasebreakingsize    NUMBER;
      l_breakingsize        NUMBER;

      l_strMarginType       mrtype.mrtype%TYPE;
      l_dblMarginRatioRate  afserisk.MRRATIOLOAN%TYPE;
      l_dblSecMarginPrice   afserisk.MRPRICELOAN%TYPE;
      --</ Margin 74
      l_dblIsMarginAllow   afserisk.ISMARGINALLOW%TYPE;
      l_dblChkSysCtrl       lntype.chksysctrl%TYPE;
      --/>
      l_dblIsPPUsed         mrtype.ISPPUSED%TYPE;
      l_strEXECTYPE         odmast.exectype%TYPE;

      l_CUSTATCOM           cfmast.custatcom%TYPE; -- Them vao de sua lenh Bloomberg
      l_BlOrderid          varchar2(30);-- them vao de sua lenh BloomBer
      l_hnxTRADINGID        varchar2(20);
      l_ismortage           VARCHAR2(10);
      l_tradelot            number(30,4);
   BEGIN
      plog.setbeginsection (pkgctx, 'pr_fo2od');
      plog.debug (pkgctx, 'BEGIN OF pr_fo2od');
      /***************************************************************************************************
       ** PUT YOUR CODE HERE, FOLLOW THE BELOW TEMPLATE:
       ** IF NECCESSARY, USING BULK COLLECTION IN THE CASE YOU MUST POPULATE LARGE DATA
      ****************************************************************************************************/
      l_atcstarttime      :=
         cspks_system.fn_get_sysvar ('SYSTEM', 'ATCSTARTTIME');
      --l_hosebreakingsize   :=
         --cspks_system.fn_get_sysvar ('SYSTEM', 'HOSEBREAKSIZE');
      l_hosebreakingsize   :=least(cspks_system.fn_get_sysvar ('SYSTEM', 'HOSEBREAKSIZE'),
                                    cspks_system.fn_get_sysvar ('BROKERDESK', 'HOSE_MAX_QUANTITY')
                                  );
      l_hasebreakingsize:=cspks_system.fn_get_sysvar ('BROKERDESK', 'HNX_MAX_QUANTITY');

      /*plog.debug (pkgctx,
                     'got l_atcstarttime,l_hosebreakingsize,l_commit_freq'
                  || l_atcstarttime
                  || ','
                  || l_hosebreakingsize
                  || ','
                  || l_commit_freq
      );*/
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

                --PHuongHT truyen lai tham so cho lenh ban cam co
                l_ismortage :=l_build_msg(indx).fld60;
                IF l_build_msg(indx).fld22 ='AS' THEN
                  -- lay theo lenh goc
                  BEGIN
                    SELECT  DECODE (a.exectype, 'MS', '1', '0')
                    INTO l_ismortage
                    FROM odmast a  WHERE orderid =l_build_msg(indx).refacctno;
                  EXCEPTION WHEN OTHERS THEN
                  l_ismortage:= 0;
                  END;

                END IF;
                l_blOrderid:=l_build_msg(indx).BLORDERID;

                BEGIN
                  SELECT TRADELOT
                  INTO l_tradelot
                  FROM SECURITIES_INFO WHERE SYMBOL = l_build_msg(indx).fld07;
                EXCEPTION WHEN OTHERS THEN
                  l_tradelot:= 100;
                END;
  -- Ducnv check trang thai thi truong hnx
               IF l_build_msg(indx).tradeplace ='002' THEN
                   SELECT sysvalue
                   INTO l_hnxTRADINGID
                   FROM ordersys_ha
                   WHERE sysname = 'TRADINGID';
                   IF l_build_msg(indx).fld27 IN ('ATO') THEN
                        RAISE errnums.e_invalid_session;
                   END IF;
                   -- PHIEN DONG CUA KHONG DC NHAP LENH THI TRUONG
                   IF l_build_msg(indx).fld27 IN ('MTL','MOK','MAK') AND l_hnxTRADINGID IN ('CLOSE','CLOSE_BL') THEN
                        RAISE errnums.e_invalid_session;
                   END IF;
                   -- CHAN HUY SUA 10 PHUT CUOI
                   IF l_build_msg(indx).fld22 in ('AB','AS','CB','CS') AND l_hnxTRADINGID IN ('CLOSE_BL') THEN
                        RAISE errnums.e_invalid_session;
                   END IF;
                    -- lenh lo le chi dc dat trong phien lien tuc
                   --IF l_build_msg(indx).fld12<100 AND  l_hnxTRADINGID <> 'CONT' then
                   IF l_build_msg(indx).fld12<l_tradelot AND  l_hnxTRADINGID <> 'CONT' then
                      RAISE errnums.e_invalid_session;
                   end if;
                   -- LO LE CHI DC DAT LENH LO
                   --IF l_build_msg(indx).fld12<100 AND l_build_msg(indx).fld27 <>'LO' THEN
                   IF l_build_msg(indx).fld12<l_tradelot AND l_build_msg(indx).fld27 <>'LO' THEN
                      RAISE errnums.e_invalid_session;
                   END IF;
               ELSIF l_build_msg(indx).tradeplace ='005' THEN
                  -- UPCOM CHI DC DAT LENH LO
                   IF l_build_msg(indx).fld27 <>'LO' THEN
                      RAISE errnums.e_invalid_session;
                   END IF;
               END IF;

               --- end OF ducnv

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
               /*ELSIF l_build_msg (indx).fld27 = 'ATC'
               THEN
                  IF not(l_mktstatus = 'A'
                            or (l_mktstatus = 'O'
                                    AND l_atcstarttime <=
                                        TO_CHAR (SYSDATE, 'HH24MISS')))
                  THEN
                     RAISE errnums.e_invalid_session;
                  END IF;*/
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
                     l_strEXECTYPE:=i.exectype;
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

               --plog.debug (pkgctx, 'ACCTNO: ' || l_build_msg (indx).fld03);

               FOR i IN (SELECT MST.BRATIO, CF.CUSTODYCD,CF.FULLNAME,MST.ACTYPE,MRT.MRTYPE,MRT.ISPPUSED,
                        NVL(RSK.MRRATIOLOAN,0) MRRATIOLOAN, NVL(MRPRICELOAN,0) MRPRICELOAN,
                        --< Margin 74
                        nvl(ISMARGINALLOW,'N') ISMARGINALLOW, nvl(lnt.chksysctrl,'N') chksysctrl, cf.custatcom
                        --/>
                        FROM AFMAST MST, CFMAST CF ,AFTYPE AFT, MRTYPE MRT, LNTYPE LNT,
                        (SELECT * FROM AFSERISK WHERE CODEID=l_build_msg (indx).fld01 ) RSK  -- l_build_msg (indx).fld01
                        WHERE MST.ACCTNO=l_build_msg (indx).fld03
                        AND MST.CUSTID=CF.CUSTID
                        and mst.actype =aft.actype and aft.mrtype = mrt.actype and aft.lntype = lnt.actype(+)
                        AND AFT.ACTYPE =RSK.ACTYPE(+))
               LOOP
                  l_txmsg.txfields ('09').VALUE   := i.custodycd;
                  l_actype                        := i.actype;
                  l_afbratio                      := i.bratio;
                  --l_txmsg.txfields ('50').VALUE   := 'FO';
                  l_fullname                      := i.fullname;
                  l_strMarginType                 := i.MRTYPE;
                  l_dblMarginRatioRate            := i.MRRATIOLOAN;
                  l_dblSecMarginPrice             := i.MRPRICELOAN;
                  --</Margin 74
                  l_dblIsMarginAllow              := i.ISMARGINALLOW;
                  l_dblChkSysCtrl                 := i.CHKSYSCTRL;
                  --/>
                  l_dblIsPPUsed                   := i.ISPPUSED;
                  /*
                  If l_dblMarginRatioRate >= 100 Or l_dblMarginRatioRate < 0
                  Then
                        l_dblMarginRatioRate := 0;
                  END IF;
                  */

                  -- Them vao de sua cho lenh Bloomberg
                  -- DungNH, 02-Nov-2015
                  l_CUSTATCOM                       := i.custatcom;
                  -- Ket thuc: Them vao de sua cho lenh Bloomberg

                  If l_dblMarginRatioRate >= 100 Or l_dblMarginRatioRate < 0 or (l_dblIsMarginAllow = 'N' and l_dblChkSysCtrl = 'Y')
                  Then
                        l_dblMarginRatioRate := 0;
                  END IF;
                  if l_dblChkSysCtrl = 'Y' then
                      if l_build_msg (indx).marginrefprice > l_dblSecMarginPrice
                      then
                            l_dblSecMarginPrice := l_dblSecMarginPrice;
                      else
                            l_dblSecMarginPrice := l_build_msg (indx).marginrefprice;
                      end if;
                  else
                      if l_build_msg (indx).marginprice > l_dblSecMarginPrice
                      then
                            l_dblSecMarginPrice := l_dblSecMarginPrice;
                      else
                            l_dblSecMarginPrice := l_build_msg (indx).marginprice;
                      end if;
                  end if;
               END LOOP;

              /* plog.debug (pkgctx,
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
               );*/

               BEGIN
                    -- Neu lenh sua thi lay lai ti le ky quy va thong tin loai hinh nhu lenh goc
                    -- TheNN, 15-Feb-2012
                    IF substr(l_build_msg(indx).fld22,1,1) = 'A' THEN
                        SELECT OD.ACTYPE, OD.CLEARDAY, OD.BRATIO
                        INTO l_txmsg.txfields ('02').VALUE, l_txmsg.txfields ('10').VALUE, l_securedratio
                        FROM ODMAST OD
                        WHERE ORDERID = l_build_msg (indx).orgacctno;
                    ELSE
                        -- LAY THONG TIN VA TINH TY LE KY QUY NHU BINH THUONG
                        -- Trong loai hinh OD ko quy dinh kenh GD qua BrokerDesk nen se gan cung kenh voi tai san (Floor)
                        BEGIN
                              -- TheNN, 14-Feb-2012
                              l_ordervia := l_build_msg(indx).fld25;
                              if l_ordervia = 'B' then
                                  l_ordervia := 'F';
                              end if;
                              -- End: TheNN, 14-Feb-2012

                              SELECT actype, clearday, bratio, minfeeamt, deffeerate
                              --to_char(sysdate,systemnums.C_TIME_FORMAT) TXTIME
                              INTO l_txmsg.txfields ('02').VALUE,                 --ACTYPE
                                   l_txmsg.txfields ('10').VALUE,               --CLEARDAY
                                   l_typebratio,                          --BRATIO (fld13)
                                   l_feeamountmin,
                                   l_feerate
                              FROM (SELECT a.actype, a.clearday, a.bratio, a.minfeeamt, a.deffeerate, b.ODRNUM
                              FROM odtype a, afidtype b
                              WHERE     a.status = 'Y'
                                    AND (a.via = l_build_msg (indx).fld25 OR a.via = 'A') --VIA
                                    AND a.clearcd = l_build_msg (indx).fld26       --CLEARCD
                                    AND (a.exectype = l_strEXECTYPE           --l_build_msg (indx).fld22
                                         OR a.exectype = 'AA')                    --EXECTYPE
                                    AND (a.timetype = l_build_msg (indx).fld20
                                         OR a.timetype = 'A')                     --TIMETYPE
                                    AND (a.pricetype = l_build_msg (indx).fld27
                                         OR a.pricetype = 'AA')                  --PRICETYPE
                                    AND (a.matchtype = l_build_msg (indx).fld24
                                         OR a.matchtype = 'A')                   --MATCHTYPE
                                    AND (a.tradeplace = l_build_msg (indx).tradeplace
                                         OR a.tradeplace = '000')
            --                        AND (sectype = l_build_msg (indx).sectype
            --                             OR sectype = '000')
                                    ---001+002+006+003 -->333
                                    ---008+006+003 -->444
                                    ---001+002+008-->111
                                    ---006+003-->222
                                    AND (instr(case when l_build_msg (indx).sectype in ('001','002') then l_build_msg (indx).sectype || ',' || '111,333'
                                                    when l_build_msg (indx).sectype in ('003','006') then l_build_msg (indx).sectype || ',' || '222,333,444'
                                                    when l_build_msg (indx).sectype in ('008') then l_build_msg (indx).sectype || ',' || '111,444'
                                                    else l_build_msg (indx).sectype end , a.sectype)>0 OR a.sectype = '000')
                                    AND (a.nork = l_build_msg (indx).fld23 OR a.nork = 'A') --NORK
                                    AND (CASE WHEN A.CODEID IS NULL THEN l_build_msg (indx).fld01 ELSE A.CODEID END)=l_build_msg (indx).fld01
                                    AND a.actype = b.actype and b.aftype=l_actype and b.objname='OD.ODTYPE'
                                    --order by b.odrnum desc, A.deffeerate DESC
                                    --order BY A.deffeerate DESC, B.ACTYPE DESC
                                    order BY A.deffeerate, B.ACTYPE DESC -- Lay ti le phi nho nhat
                                    ) where rownum<=1;
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
                                    select (case when nvl(dfprice,0)>0 then least(nvl(dfrate,0),round(nvl(dfprice,0)/ l_build_msg (indx).fld11/l_build_msg (indx).fld98 * 100)) else nvl(dfrate,0) end ) dfrate
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
                    END IF;
                END;




               /*l_txmsg.txfields ('40').VALUE     :=
                    greatest(l_feerate/100 * TO_NUMBER (l_build_msg (indx).fld12)         --quantity
                     * TO_NUMBER (l_build_msg (indx).fld11)       --quoteprice
                     * TO_NUMBER (l_build_msg (indx).fld98),l_feeamountmin);*/

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

               --</2.2b Set tlid -  TruongLD Add
               --l_txmsg.tlid                      := l_build_msg(indx).tlid;
               --/>
               --if l_build_msg(indx).fld25 <> 'O' then
                l_txmsg.tlid := l_build_msg(indx).tlid;
               --else
               -- l_txmsg.tlid := '0001';
               --end if;

               --2.3 Set txdate
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
               l_txmsg.txfields ('60').VALUE     := l_ismortage; --set vale for Is mortage sell
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
               l_txmsg.txfields ('50').VALUE     := l_build_msg (indx).username; --set vale for Customer name

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

               l_txmsg.txfields ('81').defname   := 'ORGQUOTEQTTY';
               l_txmsg.txfields ('81').TYPE      := 'N';
               l_txmsg.txfields ('81').VALUE     := 0; --set vale for Limit price


               l_txmsg.txfields ('35').defname   := 'ADVIDREF';
               l_txmsg.txfields ('35').TYPE      := 'C';
               l_txmsg.txfields ('35').VALUE     := ' ';

              plog.error (pkgctx,'ADVIDREF: ' ||l_txmsg.txfields ('35').defname );

               l_txmsg.txfields ('90').defname   := 'TRADESTATUS';
               l_txmsg.txfields ('90').TYPE      := 'N';
               l_txmsg.txfields ('90').VALUE     := 0;

                 l_txmsg.txfields ('82').defname   := 'ORGLIMITPRICE';
               l_txmsg.txfields ('82').TYPE      := 'N';
              l_txmsg.txfields ('82').VALUE     := 0; --set vale for Limit price
               IF l_build_msg (indx).fld22 IN ('NS', 'MS', 'SS') THEN --gc_OD_PLACENORMALSELLORDER_ADVANCED
                   --HaiLT them cho GRPORDER
                   l_txmsg.txfields ('55').defname   := 'GRPORDER';
                   l_txmsg.txfields ('55').TYPE      := 'C';
                   l_txmsg.txfields ('55').VALUE     := 'N';
               END IF;

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

               l_txmsg.txfields ('80').defname   := 'QUOTEQTTY';
               l_txmsg.txfields ('80').TYPE      := 'N';
               l_txmsg.txfields ('80').VALUE     := l_build_msg (indx).fld80; --set vale for Top QTTY
               l_txmsg.txfields ('14').defname   := 'LIMITPRICE';
               l_txmsg.txfields ('14').TYPE      := 'N';
               l_txmsg.txfields ('14').VALUE     := l_build_msg (indx).fld14; --set vale for Stop price
               l_txmsg.txfields ('40').defname   := 'FEEAMT';
               l_txmsg.txfields ('40').TYPE      := 'N';
               --l_txmsg.txfields ('40').VALUE     := l_build_msg (indx).fld40; --set vale for Fee amount
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

               l_txmsg.txfields ('94').defname   := 'SSAFACCTNO';
               l_txmsg.txfields ('94').TYPE      := 'C';
               l_txmsg.txfields ('94').VALUE     := l_build_msg (indx).fld94; --set vale for short sale account

               l_txmsg.txfields ('90').defname   := 'TRADESTATUS';
               l_txmsg.txfields ('90').TYPE      := 'N';
               l_txmsg.txfields ('90').VALUE     := 0;

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
               l_txmsg.txfields ('74').defname   := 'ISDISPOSAL';
               l_txmsg.txfields ('74').TYPE      := 'C';
               l_txmsg.txfields ('74').VALUE     := l_build_msg(indx).ISDISPOSAL;
               l_txmsg.txfields ('31').defname   := 'CONTRAFIRM';
               l_txmsg.txfields ('31').TYPE      := 'C';
               l_txmsg.txfields ('31').VALUE     := l_build_msg (indx).fld31; --set vale for Contrafirm
                --TuanNH add filed 90
               l_txmsg.txfields ('90').defname   := 'TRADESTATUS';
               l_txmsg.txfields ('90').TYPE      := 'N';
               l_txmsg.txfields ('90').VALUE     := 0;

               IF l_txmsg.txfields ('22').VALUE = 'AB' or l_txmsg.txfields ('22').VALUE = 'AS'     then
                   l_txmsg.txfields ('16').defname   := 'ORGORDERQTTY';
                   l_txmsg.txfields ('16').TYPE      := 'N';
                   l_txmsg.txfields ('16').VALUE     := 0;
                   l_txmsg.txfields ('17').defname   := 'ORGQUOTEPRICE';
                   l_txmsg.txfields ('17').TYPE      := 'N';
                   l_txmsg.txfields ('17').VALUE     := 0;
               end if;


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

               l_order_count                     := 0;         --RESET COUNTER

               plog.debug (pkgctx, 'l_remainqtty: ' || l_remainqtty);
               if l_build_msg (indx).SPLOPT='Q' then --Tach theo so lenh
                        l_breakingsize:= l_build_msg (indx).SPLVAL;
               elsif l_build_msg (indx).SPLOPT='O' then
                        l_breakingsize:= round(l_remainqtty/to_number(l_build_msg (indx).SPLVAL) +
                                                case when l_build_msg (indx).tradeplace='001' then 5-0.01
                                                     when l_build_msg (indx).tradeplace='002' then 50-0.01
                                                     else 0.5-0.01 end,
                                                case when l_build_msg (indx).tradeplace='001' then -1
                                                     when l_build_msg (indx).tradeplace='002' then -2
                                                     else 0 end);
               else
                        l_breakingsize:= l_remainqtty;
               end if;

               /*IF l_build_msg  (indx).tradeplace = '001' then
                    --Neu san HN thi xe toi da theo l_hosebreakingsize
                    if l_breakingsize > l_hosebreakingsize then
                        l_breakingsize:=l_hosebreakingsize;
                    else
                        l_breakingsize:=l_breakingsize;
                    end if;
               end if;*/
               IF l_build_msg  (indx).tradeplace = '001' then
                    --Neu san HSX thi xe toi da theo l_hosebreakingsize
                    if l_breakingsize > l_hosebreakingsize then
                        l_breakingsize:=l_hosebreakingsize;
                    else
                        l_breakingsize:=l_breakingsize;
                    end if;
               ELSIF l_build_msg  (indx).tradeplace = '002' then
                    --Neu san HNX thi xe toi da theo l_hasebreakingsize
                    if l_breakingsize > l_hasebreakingsize then
                        l_breakingsize:=l_hasebreakingsize;
                    else
                        l_breakingsize:=l_breakingsize;
                    end if;
               end if;

               WHILE l_remainqtty > 0                               --quantity
               LOOP
                  SAVEPOINT sp#2;
                  l_order_count   := l_order_count + 1;

                  /*IF l_build_msg (indx).tradeplace = '001'
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
                  END IF;*/

                  l_txmsg.txfields ('12').VALUE   :=
                        CASE
                           WHEN l_remainqtty > l_breakingsize
                           THEN
                              l_breakingsize
                           ELSE
                              l_remainqtty
                        END;

                  -- SET FEE AMOUNT
                  l_txmsg.txfields ('40').VALUE     :=
                    greatest(l_feerate/100 * TO_NUMBER (l_txmsg.txfields('12').VALUE)         --quantity
                     * TO_NUMBER (l_build_msg(indx).fld11)       --quoteprice
                     * TO_NUMBER (l_build_msg(indx).fld98),l_feeamountmin);

                  --2.1 Set txnum
                  SELECT systemnums.c_fo_prefixed
                         || LPAD (seq_fotxnum.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;

                  --v_strOrderID = FO_PREFIXED & "00" & Mid(Replace(v_strTXDATE, "/", vbNullString), 1, 4) & Mid(Replace(v_strTXDATE, "/", vbNullString), 7, 2) & Strings.Right(gc_FORMAT_ODAUTOID & CStr(v_DataAccess.GetIDValue("ODMAST")), Len(gc_FORMAT_ODAUTOID))
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

                  -- Get tltxcd from EXECTYPE
                  IF l_txmsg.txfields ('22').VALUE = 'NB'               --8876
                  THEN
                     BEGIN
                        l_txmsg.tltxcd   := '8876'; -- gc_OD_PLACENORMALBUYORDER_ADVANCED
                        --85    ISBONDTRANSACT     C
                        l_txmsg.txfields ('85').defname   := 'ISBONDTRANSACT';
                        l_txmsg.txfields ('85').TYPE      := 'C';
                        l_txmsg.txfields ('85').value     := 'N';
                        --86    BONDINFO     C
                        l_txmsg.txfields ('86').defname   := 'BONDINFO';
                        l_txmsg.txfields ('86').TYPE      := 'C';
                        l_txmsg.txfields ('86').value     := null;

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
                           -- Neu lenh thieu suc mua thi dong bo lai ci
                          IF nvl(l_err_code,'0') = '-400116' THEN
                                jbpks_auto.pr_trg_account_log(l_build_msg (indx).fld03, 'CI');
                          END IF;
                           --EXIT; -- UNCOMMENT THIS IF YOU WANT TO EXIT LOOP WHEN GOT AN ERROR
                           RAISE errnums.e_biz_rule_invalid;
                       ELSE
                            -- Xu ly cho lenh dat direct tu Bloomberg
                            -- TheNN, 02-Oct-2013
                         IF l_build_msg(indx).fld25 = 'L' THEN
                            -- Update ODMAST
                                UPDATE odmast SET
                                    blorderid = l_build_msg(indx).blorderid
                                WHERE foacctno = l_build_msg(indx).acctno;
                                -- Cap nhat lai so CK da day vao bang lenh BL
                                update bl_odmast set
                                    sentqtty = sentqtty + TO_NUMBER(l_txmsg.txfields ('12').VALUE),
                                    REMAINQTTY = REMAINQTTY - TO_NUMBER(l_txmsg.txfields ('12').VALUE),
                                    LAST_CHANGE = systimestamp
                                where blorderid = l_build_msg(indx).blorderid;
                            END IF;
                            -- End: Xu ly cho lenh dat direct tu Bloomberg
                            -- TheNN, 02-Oct-2013
                        END IF;
                     END;                                               --8876
                  ELSIF l_build_msg (indx).fld22 IN ('NS', 'MS', 'SS')  --8877
                  THEN
                     BEGIN
                        l_txmsg.tltxcd   := '8877'; --gc_OD_PLACENORMALSELLORDER_ADVANCED
                        --85    ISBONDTRANSACT     C
                        l_txmsg.txfields ('85').defname   := 'ISBONDTRANSACT';
                        l_txmsg.txfields ('85').TYPE      := 'C';
                        l_txmsg.txfields ('85').value     := 'N';
                        --86    BONDINFO     C
                        l_txmsg.txfields ('86').defname   := 'BONDINFO';
                        l_txmsg.txfields ('86').TYPE      := 'C';
                        l_txmsg.txfields ('86').value     := null;

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
                        ELSE
                            -- Xu ly cho lenh dat direct tu Bloomberg
                            -- TheNN, 02-Oct-2013
                         IF l_build_msg(indx).fld25 = 'L' THEN
                            -- Update ODMAST
                                UPDATE odmast SET
                                    blorderid = l_build_msg(indx).blorderid
                                WHERE foacctno = l_build_msg(indx).acctno;
                                -- Cap nhat lai so CK da day vao bang lenh BL
                                update bl_odmast set
                                    sentqtty = sentqtty + TO_NUMBER(l_txmsg.txfields ('12').VALUE),
                                    REMAINQTTY = REMAINQTTY - TO_NUMBER(l_txmsg.txfields ('12').VALUE),
                                    LAST_CHANGE = systimestamp
                                where blorderid = l_build_msg(indx).blorderid;
                            END IF;
                            -- End: Xu ly cho lenh dat direct tu Bloomberg
                            -- TheNN, 02-Oct-2013
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
                           -- Neu lenh thieu suc mua thi dong bo lai ci
                          IF nvl(l_err_code,'0') = '-400116' THEN
                                jbpks_auto.pr_trg_account_log(l_build_msg (indx).fld03, 'CI');
                          END IF;
                           --EXIT; -- UNCOMMENT THIS IF YOU WANT TO EXIT LOOP WHEN GOT AN ERROR
                           RAISE errnums.e_biz_rule_invalid;
                       ELSE -- PhuongHT edit cho sua lenh link den lenh BloomBerg
                            if trim(l_build_msg(indx).BLORDERID) IS NOT NULL then
                            -- goi ham check sua lenh BloomBerg
                                l_err_code:=pck_fo_bl.fnc_check_blb_AMENDMENTOrder(l_BlOrderid,to_number(l_build_msg(indx).fld12),
                                                                                   l_build_msg(indx).fld22,to_number(l_build_msg(indx).fld11),
                                                                                   l_build_msg(indx).refacctno,'BLBAMENDMENTORDER',
                                                                                   l_build_msg(indx).fld25);
                                if l_err_code <> systemnums.C_SUCCESS then
                                   --ONLY ROLLBACK FOR THIS MESSAGE
                                   ROLLBACK TO SAVEPOINT sp#2;
                                   RAISE errnums.e_biz_rule_invalid;
                                end if;
                                -- plog.error(pkgctx, '8884: txpks_auto BLBAMENDMENTORDER 02'  || l_build_msg (indx).refacctno ||',' || l_build_msg (indx).acctno ||',' || l_BlOrderid ||',' || l_build_msg(indx).fld12 ||',' || l_BlRetlid);
                                fopks_api.pr_blbPlaceOrder_update('BLBAMENDMENTORDER',l_build_msg (indx).refacctno,
                                                                      l_build_msg (indx).acctno,
                                                                      l_BlOrderid,
                                                                      l_build_msg(indx).fld12,
                                                                      null,
                                                                      l_txmsg.txfields ('04').VALUE);
                            end if;
                            -- PhuongHT end 10.10.2013
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
                       ELSE -- PhuongHT edit cho sua lenh link den lenh BloomBerg
                            if trim(l_build_msg(indx).BLORDERID) IS NOT NULL then
                                 -- goi ham check sua lenh BloomBerg
                               l_err_code:=pck_fo_bl.fnc_check_blb_AMENDMENTOrder(l_BlOrderid,to_number(l_build_msg(indx).fld12),
                                                                                 l_build_msg(indx).fld22,to_number(l_build_msg(indx).fld11),
                                                                                 l_build_msg(indx).refacctno,'BLBAMENDMENTORDER',
                                                                                 l_build_msg(indx).fld25);
                               if l_err_code <> systemnums.C_SUCCESS then
                                 --ONLY ROLLBACK FOR THIS MESSAGE
                                 ROLLBACK TO SAVEPOINT sp#2;
                                 RAISE errnums.e_biz_rule_invalid;
                               end if;
                             -- plog.error(pkgctx, '8885: txpks_auto BLBAMENDMENTORDER 02'  || l_build_msg (indx).refacctno ||',' || l_build_msg (indx).acctno ||',' || l_BlOrderid ||',' || l_build_msg(indx).fld12 ||',' || l_build_msg(indx).retlid);
                                fopks_api.pr_blbPlaceOrder_update('BLBAMENDMENTORDER',l_build_msg (indx).refacctno,
                                                                    l_build_msg (indx).acctno,
                                                                    l_BlOrderid,
                                                                    l_build_msg(indx).fld12,
                                                                    null,
                                                                    l_txmsg.txfields ('04').VALUE);
                            end if;
                            -- PhuongHT end 10.10.2013
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
                       ELSE -- PhuongHT edit cho sua lenh link den lenh BloomBerg
                           --plog.error(pkgctx, '8882: txpks_auto BLBAMENDMENTORDER 01' || l_build_msg (indx).BLORDERID );
                            if trim(l_build_msg (indx).BLORDERID) IS NOT NULL then
                           --plog.error(pkgctx, '8882: txpks_auto BLBAMENDMENTORDER 02'  || l_build_msg (indx).refacctno ||',' || l_build_msg (indx).acctno ||',' || l_BlOrderid ||',' || l_build_msg(indx).fld12 ||',' || l_build_msg(indx).retlid);
                               fopks_api.pr_blbPlaceOrder_update('BLBCANCELORDER',l_build_msg (indx).refacctno,
                                                                  l_build_msg (indx).acctno,
                                                                  l_BlOrderid,
                                                                  l_build_msg(indx).fld12,
                                                                  null,
                                                                  l_txmsg.txfields ('04').VALUE);
                            end if;

                            -- PhuongHT end 10.10.2013
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
                       ELSE -- PhuongHT edit cho sua lenh link den lenh BloomBerg
                            if trim(l_build_msg (indx).BLORDERID) IS NOT NULL then
                           -- plog.error(pkgctx, '8885: txpks_auto BLBAMENDMENTORDER 02'  || l_build_msg (indx).refacctno ||',' || l_build_msg (indx).acctno ||',' || l_BlOrderid ||',' || l_build_msg(indx).fld12 ||',' || l_build_msg(indx).retlid);
                               fopks_api.pr_blbPlaceOrder_update('BLBCANCELORDER',l_build_msg (indx).refacctno,
                                                                  l_build_msg (indx).acctno,
                                                                  l_BlOrderid,
                                                                  l_build_msg(indx).fld12,
                                                                  null,
                                                                  l_txmsg.txfields ('04').VALUE);
                            end if;
                           -- PhuongHT end 10.10.2013
                        END IF;
                     END;
                  END IF;

                  UPDATE fomast
                  SET orgacctno    = l_txmsg.txfields ('04').VALUE,
                      status       = 'A',
                      feedbackmsg   =
                         'Order is active and sucessfull processed: '
                         || l_txmsg.txfields ('04').VALUE
                  WHERE acctno = l_build_msg (indx).acctno;

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
                  plog.error (pkgctx,
                                 'row:'
                              || dbms_utility.format_error_backtrace
                  );
                  UPDATE fomast
                  SET status    = 'R',
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
                  SET status    = 'R',
                      feedbackmsg   =
                         '[' || errnums.c_invalid_session || '] '
                         || cspks_system.fn_get_errmsg(errnums.c_invalid_session)
                  WHERE acctno = l_build_msg (indx).acctno;
               --LogOrderMessage(v_ds.Tables(0).Rows(i)("ACCTNO"))
               WHEN errnums.e_biz_rule_invalid
               THEN
                  -- KIEM TRA NEU TH CHIA LENH MA DA CO LENH CHIA THANH CONG THI KO CAP NHAT LENH TRONG FOMAST
                  IF NOT (l_remainqtty < l_build_msg(indx).fld12) THEN
                  -- Neu lenh Bloomberg, thieu tien hoac thieu CK thi de trang thai cho xu ly tiep
                        -- TheNN, 04-Jul-2013
                        IF (nvl(l_err_code,'0') = '-400116' OR nvl(l_err_code,'0') = '-900017') AND l_build_msg(indx).fld25 = 'L' AND l_CUSTATCOM = 'N' AND l_build_msg(indx).fld22 in ('NB','NS') THEN
                            UPDATE fomast
                              SET status        = 'T',
                                  feedbackmsg   = '[' || l_err_code || '] ' || l_err_param
                              WHERE acctno = l_build_msg (indx).acctno;
                          -- Ket thuc sua cho Bloomberg
                        ELSE
                          UPDATE fomast
                          SET status        = 'R',
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
                        end if;
                  END IF;
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
      plog.init ('txpks_txpks_auto',
                 plevel => NVL (logrow.loglevel, 30),
                 plogtable => (NVL (logrow.log4table, 'N') = 'Y'),
                 palert => (NVL (logrow.log4alert, 'N') = 'Y'),
                 ptrace => (NVL (logrow.log4trace, 'N') = 'Y')
      );
   -- plog.error('level2: ' || logrow.loglevel);
   END;

PROCEDURE pr_fo2odsyn (p_orderid varchar2, p_err_code  OUT varchar2, p_timetype varchar2 default 'T' )
   IS
      l_txmsg               tx.msg_rectype;
      l_orders_cache_size   NUMBER (10) := 10000;
      l_commit_freq         NUMBER (10) := 10;
      l_count               NUMBER (10) := 0;
      l_order_count         NUMBER (10) := 0;
      l_isHoliday           varchar2(10);
      l_err_param           deferror.errdesc%TYPE;

      l_mktstatus           ordersys.sysvalue%TYPE;
      l_atcstarttime        sysvar.varvalue%TYPE;

      l_typebratio          odtype.bratio%TYPE;
      l_afbratio            afmast.bratio%TYPE;
      l_securedratio        odtype.bratio%TYPE;
      l_actype              odtype.actype%TYPE;
      l_remainqtty          odmast.orderqtty%TYPE;
      l_fullname            cfmast.fullname%TYPE;
      l_ordervia            odtype.via%type;

      l_feeamountmin        NUMBER;
      l_feerate             NUMBER;
      l_feesecureratiomin   NUMBER;
      l_hosebreakingsize    NUMBER;
      l_hasebreakingsize    NUMBER;
      l_breakingsize        NUMBER;
      l_strMarginType       mrtype.mrtype%TYPE;
      l_dblMarginRatioRate  afserisk.MRRATIOLOAN%TYPE;
      l_dblSecMarginPrice   afserisk.MRPRICELOAN%TYPE;
      --</ Margin 74
      l_dblIsMarginAllow   afserisk.ISMARGINALLOW%TYPE;
      l_dblChkSysCtrl       lntype.chksysctrl%TYPE;
      --/>
      l_dblIsPPUsed         mrtype.ISPPUSED%TYPE;
      l_strEXECTYPE         odmast.exectype%TYPE;
      l_hnxTRADINGID        varchar2(30);
      l_ismortage           VARCHAR2(10);-- PhuongHT add

      l_CUSTATCOM           cfmast.custatcom%TYPE; -- Them vao de sua lenh Bloomberg
      l_clearday             odmast.clearday%TYPE;
      l_tradelot            number(30,4);
   BEGIN
      plog.setbeginsection (pkgctx, 'pr_fo2odsyn');
      plog.debug (pkgctx, 'BEGIN OF pr_fo2odsyn');
      plog.debug (pkgctx, 'p_orderid: '||p_orderid);
      plog.debug (pkgctx, 'p_timetype: '||p_timetype);
      /***************************************************************************************************
       ** PUT YOUR CODE HERE, FOLLOW THE BELOW TEMPLATE:
       ** IF NECCESSARY, USING BULK COLLECTION IN THE CASE YOU MUST POPULATE LARGE DATA
      ****************************************************************************************************/
      l_atcstarttime      :=
         cspks_system.fn_get_sysvar ('SYSTEM', 'ATCSTARTTIME');
      --l_hosebreakingsize   :=
         --cspks_system.fn_get_sysvar ('SYSTEM', 'HOSEBREAKSIZE');
      l_hosebreakingsize   :=least(cspks_system.fn_get_sysvar ('SYSTEM', 'HOSEBREAKSIZE'),
                                    cspks_system.fn_get_sysvar ('BROKERDESK', 'HOSE_MAX_QUANTITY')
                                  );
      l_hasebreakingsize:=cspks_system.fn_get_sysvar ('BROKERDESK', 'HNX_MAX_QUANTITY');

      /*plog.debug (pkgctx,
                     'got l_atcstarttime,l_hosebreakingsize,l_commit_freq'
                  || l_atcstarttime
                  || ','
                  || l_hosebreakingsize
                  || ','
                  || l_commit_freq
      );*/
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

     /* plog.debug (pkgctx,
                     'wsname,ipaddress:'
                  || l_txmsg.wsname
                  || ','
                  || l_txmsg.ipaddress
      );*/

      -- 2. Set specific value for each transaction
      for l_build_msg in
      (
         SELECT  a.codeid fld01,
                 a.symbol fld07,
                 DECODE (a.exectype, 'MS', '1', '0') fld60, --ismortage   fld60, -- FOR 8885
                 a.actype fld02,
                 a.afacctno || a.codeid fld06,                --seacctno    fld06,
                 a.afacctno fld03,
                 a.timetype fld20,
                 --'T' fld20,
                 a.effdate fld19,
                 --a.expdate fld21, -- Lenh GTC day vao ODMAST lay expdate = currdate
                 getcurrdate fld21,
                 a.exectype fld22,
                 a.outpriceallow fld34,
                 a.nork fld23,
                 a.matchtype fld24,
                 a.via fld25,
                 a.clearday fld10,
                 a.clearcd fld26,
                 'O' fld72,                                       --puttype fld72,
                 (CASE WHEN a.exectype IN ('AB','AS') AND a.pricetype='MTL' THEN 'LO'
                       WHEN a.pricetype = 'RP' THEN FN_GETPRICETYPE4RP(b.tradeplace) --DUCNV sua lenh RP
                       ELSE a.pricetype
                  END ) fld27,
                 -- PhuongHT edit for sua lenh MTL
                 case when timetype ='G' then a.remainqtty else a.quantity end fld12,                      --a.ORDERQTTY       fld12,
                 a.quoteprice fld11,
                 0 fld18,                               --a.ADVSCRAMT       fld18,
                 0 fld17,                               --a.ORGQUOTEPRICE   fld17,
                 0 fld16,                               --a.ORGORDERQTTY    fld16,
                 0 fld31,                               --a.ORGSTOPPRICE    fld31,
                 a.bratio fld13,
                 a.limitprice fld14,                               --a.LIMITPRICE      fld14,
                 0 fld40,                                                -- FEEAMT
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
                 c.marginrefprice,
                 b.tradeplace,
                 b.sectype,
                 c.tradelot,
                 c.securedratiomin,
                 c.securedratiomax,
                 a.SPLOPT,
                 a.SPLVAL,
                 a.ISDISPOSAL,
                 a.username username,
                 a.SSAFACCTNO fld94,
                 '' fld35,
                 a.tlid tlid,
                 a.quoteqtty fld80

          FROM fomast a, sbsecurities b, securities_info c
          WHERE     a.book = 'A'
                AND a.timetype = p_timetype
                AND a.status = 'P'
                --and a.direct= DECODE(p_timetype,'G',A.DIRECT,'Y')
                AND a.codeid = b.codeid
                AND a.codeid = c.codeid
                and a.acctno = p_orderid
      )
      LOOP
            BEGIN

                --PHuongHT truyen lai tham so cho lenh ban cam co
                l_ismortage :=l_build_msg.fld60;
                IF l_build_msg.fld22 ='AS' THEN
                  -- lay theo lenh goc
                  BEGIN
                    SELECT  DECODE (a.exectype, 'MS', '1', '0')
                    INTO l_ismortage
                    FROM odmast a  WHERE orderid =l_build_msg.refacctno;
                  EXCEPTION WHEN OTHERS THEN
                  l_ismortage:= 0;
                  END;

                END IF;
                -- Ducnv check trang thai thi truong HNX
                --thanpv TPDN
                BEGIN
                  SELECT TRADELOT
                  INTO l_tradelot
                  FROM SECURITIES_INFO WHERE SYMBOL = l_build_msg.fld07;
                EXCEPTION WHEN OTHERS THEN
                  l_tradelot:= 100;
                END;

               IF l_build_msg.tradeplace ='002' THEN
                   SELECT sysvalue
                   INTO l_hnxTRADINGID
                   FROM ordersys_ha
                   WHERE sysname = 'TRADINGID';
                   IF l_build_msg.fld27 IN ('ATO') THEN
                        RAISE errnums.e_invalid_session;
                   END IF;
                   -- PHIEN DONG CUA KHONG DC NHAP LENH THI TRUONG
                   IF l_build_msg.fld27 IN ('MTL','MOK','MAK') AND l_hnxTRADINGID IN ('CLOSE','CLOSE_BL') THEN
                        RAISE errnums.e_invalid_session;
                   END IF;
                   -- CHAN HUY SUA 10 PHUT CUOI
                   IF l_build_msg.fld22 in ('AB','AS','CB','CS') AND l_hnxTRADINGID IN ('CLOSE_BL') and l_build_msg.fld27 NOT IN ('PLO') THEN --17/10/2018 DieuNDA: Lenh PLO cho phep Huy/Sua o phien CLOSE_BL
                        RAISE errnums.e_invalid_session;
                   END IF;
                   -- lenh lo le chi dc dat trong phien lien tuc
                   --IF l_build_msg.fld12<100 AND  l_hnxTRADINGID <> 'CONT' then
                   IF l_build_msg.fld12<l_tradelot AND  l_hnxTRADINGID <> 'CONT' then
                      RAISE errnums.e_invalid_session;
                   end if;
                   -- LO LE CHI DC DAT LENH LO
                   --IF l_build_msg.fld12<100 AND l_build_msg.fld27 <>'LO' THEN
                   IF l_build_msg.fld12<l_tradelot AND l_build_msg.fld27 <>'LO' THEN
                      RAISE errnums.e_invalid_session;
                   END IF;
               ELSIF l_build_msg.tradeplace ='005' THEN
                  -- UPCOM CHI DC DAT LENH LO
                   IF l_build_msg.fld27 <>'LO' THEN
                      RAISE errnums.e_invalid_session;
                   END IF;
               END IF;
               -------------------------end of ducnv-----
               -- Check Market status
               SELECT sysvalue
               INTO l_mktstatus
               FROM ordersys
               WHERE sysname = 'CONTROLCODE';


               /*plog.debug (pkgctx,
                              'l_mktstatus,pricetype: '
                           || l_mktstatus
                           || ','
                           || l_build_msg.fld27
               );*/

               -- l_mktstatus=P: 8h30-->9h00 session 1 ATO
               -- l_mktstatus=O: 9h00-->10h15 session 2 MP
               -- l_mktstatus=A: 10h15-->10h30 session 3 ATC
               --plog.debug (pkgctx,'username: ' || l_build_msg.username);
               --plog.debug (pkgctx,'via: ' || l_build_msg.fld25);
               -- </ TruongLD Add
               --if l_build_msg.fld25 <> 'O' then
                l_txmsg.tlid := l_build_msg.tlid;
               /*else
                l_txmsg.tlid := '0001';
               end if;*/

               --/>
               --plog.debug (pkgctx,'pricetype: ' || l_build_msg.fld27);
               IF l_build_msg.fld27 = 'ATO'
               THEN                                        -- fld27: pricetype
                  IF l_mktstatus IN ('O', 'A')
                  THEN
                     RAISE errnums.e_invalid_session;
                  END IF;

                -- KO CHECK PHIEN GD NEU LA LENH ATC --> CHO PHEP DAT LENH ATC TRUOC GIO
               /*ELSIF l_build_msg.fld27 = 'ATC'
               THEN
                  IF not(l_mktstatus = 'A'
                            or (l_mktstatus = 'O'
                                    AND l_atcstarttime <=
                                        TO_CHAR (SYSDATE, 'HH24MISS')))
                  THEN
                     RAISE errnums.e_invalid_session;
                  END IF;*/
               ELSIF l_build_msg.fld27 = 'MO'
               THEN
                  IF l_mktstatus <> 'O'
                  THEN
                     RAISE errnums.e_invalid_session;
                  END IF;
               END IF;

               l_txmsg.txfields ('22').VALUE     := l_build_msg.fld22; --set vale for Execution TYPE
               l_strEXECTYPE:=l_build_msg.fld22;
               /*plog.debug (pkgctx,
                           'exectype: ' || l_txmsg.txfields ('22').VALUE
               );*/

               IF LENGTH (l_build_msg.refacctno) > 0
               THEN                                             --lENH HUY SUA
                  FOR i IN (SELECT exectype
                            FROM fomast
                            WHERE orgacctno = l_build_msg.refacctno)
                  LOOP
                     l_strEXECTYPE:=i.exectype;
                  END LOOP;
               END IF;

               IF l_build_msg.fld27 <> 'LO'
               THEN                                               -- Pricetype
                  IF l_strEXECTYPE='NB'--l_build_msg (indx).fld22 = 'NB'
                  THEN                                             -- exectype
                     l_build_msg.fld11   :=
                        l_build_msg.ceilingprice
                        / l_build_msg.fld98;                --tradeunit
                  ELSE
                     l_build_msg.fld11   :=
                        l_build_msg.floorprice
                        / l_build_msg.fld98;
                  END IF;
               END IF;

               -- T2 NAMNT: sua day lenh GTC vao dung theo chu ky thanh toan config
               IF p_timetype = 'G' THEN
                    select TO_NUMBER(VARVALUE)
                    into l_clearday
                    from sysvar
                    where grname like 'SYSTEM' and varname='CLEARDAY' and rownum<=1;
               ELSE
                    l_clearday := l_build_msg.fld10;
               END IF;
               -- End: T2 NAMNT: sua day lenh GTC vao dung theo chu ky thanh toan config


               FOR i IN (SELECT MST.BRATIO, CF.CUSTODYCD,CF.FULLNAME,MST.ACTYPE,MRT.MRTYPE,MRT.ISPPUSED,
                        NVL(RSK.MRRATIOLOAN,0) MRRATIOLOAN, NVL(MRPRICELOAN,0) MRPRICELOAN,
                        nvl(ISMARGINALLOW,'N') ISMARGINALLOW, nvl(lnt.chksysctrl,'N') chksysctrl, cf.custatcom
                        FROM AFMAST MST, CFMAST CF ,AFTYPE AFT, MRTYPE MRT, LNTYPE LNT,
                        (SELECT * FROM AFSERISK WHERE CODEID=l_build_msg.fld01 ) RSK
                        WHERE MST.ACCTNO=l_build_msg.fld03
                        AND MST.CUSTID=CF.CUSTID
                        and mst.actype =aft.actype and aft.mrtype = mrt.actype and aft.lntype = lnt.actype(+)
                        AND AFT.ACTYPE =RSK.ACTYPE(+))
               LOOP
                  l_txmsg.txfields ('09').VALUE   := i.custodycd;
                  l_actype                        := i.actype;
                  l_afbratio                      := i.bratio;
                  --l_txmsg.txfields ('50').VALUE   := 'FO';
                  l_fullname                      := i.fullname;
                  l_strMarginType                 := i.MRTYPE;
                  l_dblMarginRatioRate            := i.MRRATIOLOAN;
                  l_dblSecMarginPrice             := i.MRPRICELOAN;
                  --</ Margin 74
                  l_dblIsMarginAllow              := i.ISMARGINALLOW;
                  l_dblChkSysCtrl                 := i.CHKSYSCTRL;
                  --/>
                  l_dblIsPPUsed                   := i.ISPPUSED;

                  -- Them vao de sua cho lenh Bloomberg
                  -- DungNH, 02-Nov-2015
                  l_CUSTATCOM                       := i.custatcom;
                  -- Ket thuc: Them vao de sua cho lenh Bloomberg

                  If l_dblMarginRatioRate >= 100 Or l_dblMarginRatioRate < 0 or (l_dblIsMarginAllow = 'N' and l_dblChkSysCtrl = 'Y')
                  Then
                        l_dblMarginRatioRate := 0;
                  END IF;
                  if l_dblChkSysCtrl = 'Y' then
                      if l_build_msg.marginrefprice > l_dblSecMarginPrice
                      then
                            l_dblSecMarginPrice := l_dblSecMarginPrice;
                      else
                            l_dblSecMarginPrice := l_build_msg.marginrefprice;
                      end if;
                  else
                      if l_build_msg.marginprice > l_dblSecMarginPrice
                      then
                            l_dblSecMarginPrice := l_dblSecMarginPrice;
                      else
                            l_dblSecMarginPrice := l_build_msg.marginprice;
                      end if;
                  end if;
               END LOOP;
               /*plog.debug (pkgctx, 'VIA: ' || l_build_msg.fld25);
               plog.debug (pkgctx, 'CLEARCD: ' || l_build_msg.fld26);
               plog.debug (pkgctx, 'EXECTYPE: ' || l_build_msg.fld22);
               plog.debug (pkgctx, 'TIMETYPE: ' || l_build_msg.fld20);
               plog.debug (pkgctx, 'PRICETYPE: ' || l_build_msg.fld27);
               plog.debug (pkgctx, 'MATCHTYPE: ' || l_build_msg.fld24);
               plog.debug (pkgctx, 'NORK: ' || l_build_msg.fld23);
               plog.debug (pkgctx, 'sectype: ' || l_build_msg.sectype);
               plog.debug (pkgctx,
                           'tradeplace: ' || l_build_msg.tradeplace
               );*/

               BEGIN
                    -- Neu lenh sua thi lay lai ti le ky quy va thong tin loai hinh nhu lenh goc
                    -- TheNN, 15-Feb-2012
                    IF substr(l_build_msg.fld22,1,1) = 'A' THEN
                        SELECT OD.ACTYPE, OD.CLEARDAY, OD.BRATIO
                        INTO l_txmsg.txfields ('02').VALUE, l_txmsg.txfields ('10').VALUE, l_securedratio
                        FROM ODMAST OD
                        WHERE ORDERID = l_build_msg.orgacctno;
                    ELSE
                        -- LAY THONG TIN VA TINH TY LE KY QUY NHU BINH THUONG
                        -- Trong loai hinh OD ko quy dinh kenh GD qua BrokerDesk nen se gan cung kenh voi tai san (Floor)
                        BEGIN
                              -- TheNN, 14-Feb-2012
                              l_ordervia := l_build_msg.fld25;
                              if l_ordervia = 'B' then
                                  l_ordervia := 'F';
                              end if;
                              -- End: TheNN, 14-Feb-2012

                                SELECT actype, clearday, bratio, minfeeamt, deffeerate
                              --to_char(sysdate,systemnums.C_TIME_FORMAT) TXTIME
                              INTO l_txmsg.txfields ('02').VALUE,                 --ACTYPE
                                   l_txmsg.txfields ('10').VALUE,               --CLEARDAY
                                   l_typebratio,                          --BRATIO (fld13)
                                   l_feeamountmin,
                                   l_feerate
                              FROM (SELECT a.actype, a.clearday, a.bratio, a.minfeeamt, a.deffeerate, b.ODRNUM
                              FROM odtype a, afidtype b
                              WHERE     a.status = 'Y'
                                    AND (a.via = l_build_msg.fld25 OR a.via = 'A') --VIA
                                    AND a.clearcd = l_build_msg.fld26       --CLEARCD
                                    AND (a.exectype = l_strEXECTYPE           --l_build_msg.fld22
                                         OR a.exectype = 'AA')                    --EXECTYPE
                                    AND (a.timetype = l_build_msg.fld20
                                         OR a.timetype = 'A')                     --TIMETYPE
                                    AND (a.pricetype = l_build_msg.fld27
                                         OR a.pricetype = 'AA')                  --PRICETYPE
                                    AND (a.matchtype = l_build_msg.fld24
                                         OR a.matchtype = 'A')                   --MATCHTYPE
                                    AND (a.tradeplace = l_build_msg.tradeplace
                                         OR a.tradeplace = '000')
            --                        AND (sectype = l_build_msg.sectype
            --                             OR sectype = '000')

                                    AND (instr(case when l_build_msg.sectype in ('001','002') then l_build_msg.sectype || ',' || '111,333'
                                                   when l_build_msg.sectype in ('003','006') then l_build_msg.sectype || ',' || '222,333,444'
                                                   when l_build_msg.sectype in ('008') then l_build_msg.sectype || ',' || '111,444'
                                                   else l_build_msg.sectype end, a.sectype)>0 OR a.sectype = '000')
                                    AND (a.nork = l_build_msg.fld23 OR a.nork = 'A') --NORK
                                    AND (CASE WHEN A.CODEID IS NULL THEN l_build_msg.fld01 ELSE A.CODEID END)=l_build_msg.fld01
                                    AND a.actype = b.actype and b.aftype=l_actype and b.objname='OD.ODTYPE'
                                    --order by b.odrnum DESC, A.deffeerate DESC
                                    --order BY A.deffeerate DESC, B.ACTYPE DESC
                                    order BY A.deffeerate , B.ACTYPE DESC -- Lay ti le phi nho nhat
                                    ) where rownum<=1;
                           EXCEPTION
                              WHEN NO_DATA_FOUND
                              THEN
                              RAISE errnums.e_od_odtype_notfound;
                           END;

                           if l_strMarginType='S' or l_strMarginType='T' or l_strMarginType='N' then
                               --Tai khoan margin va tai khoan binh thuong ky quy 100%
                                l_securedratio:=100;
                           elsif l_strMarginType='L' then --Cho tai khoan margin loan
                                begin
                                    select (case when nvl(dfprice,0)>0 then least(nvl(dfrate,0),round(nvl(dfprice,0)/ l_build_msg.fld11/l_build_msg.fld98 * 100,4)) else nvl(dfrate,0) end ) dfrate
                                    into l_securedratio
                                    from (select * from dfbasket where symbol=l_build_msg.fld07) bk,
                                    aftype aft, dftype dft,afmast af
                                    where af.actype = aft.actype and aft.dftype = dft.actype and dft.basketid = bk.basketid (+)
                                    and af.acctno = l_build_msg.fld03;
                                    l_securedratio:=greatest (100-l_securedratio,0);
                                exception
                                when others then
                                     l_securedratio:=100;
                                end;
                           else
                                l_securedratio                    :=
                                GREATEST (LEAST (l_typebratio + l_afbratio, 100),
                                        l_build_msg.securedratiomin
                                );
                                l_securedratio                    :=
                                  CASE
                                     WHEN l_securedratio > l_build_msg.securedratiomax
                                     THEN
                                        l_build_msg.securedratiomax
                                     ELSE
                                        l_securedratio
                                  END;
                           end if;

                           --FeeSecureRatioMin = mv_dblFeeAmountMin * 100 / (CDbl(v_strQUANTITY) * CDbl(v_strQUOTEPRICE) * CDbl(v_strTRADEUNIT))
                           l_feesecureratiomin               :=
                              l_feeamountmin * 100
                              / (  TO_NUMBER (l_build_msg.fld12)         --quantity
                                 * TO_NUMBER (l_build_msg.fld11)       --quoteprice
                                 * TO_NUMBER (l_build_msg.fld98));      --tradeunit

                           IF l_feesecureratiomin > l_feerate
                           THEN
                              l_securedratio   := l_securedratio + l_feesecureratiomin;
                           ELSE
                              l_securedratio   := l_securedratio + l_feerate;
                           END IF;
                    END IF;
                END;
                -- End: TheNN modified, 15-Feb-2012


               /*l_txmsg.txfields ('40').VALUE     :=
                    greatest(l_feerate/100 * TO_NUMBER (l_build_msg.fld12)         --quantity
                     * TO_NUMBER (l_build_msg.fld11)       --quoteprice
                     * TO_NUMBER (l_build_msg.fld98),l_feeamountmin);*/
               l_txmsg.txfields ('13').VALUE     := l_securedratio;

               IF (  TO_NUMBER (l_build_msg.fld12)
                   * TO_NUMBER (l_build_msg.fld11)
                   * l_securedratio
                   / 100
                   -   TO_NUMBER (l_build_msg.refprice)
                     * TO_NUMBER (l_build_msg.refquantity)
                     * l_securedratio
                     / 100 > 0)
               THEN
                  l_txmsg.txfields ('18').VALUE   :=
                       TO_NUMBER (l_build_msg.fld12)
                     * TO_NUMBER (l_build_msg.fld11)
                     * l_securedratio
                     / 100
                     -   TO_NUMBER (l_build_msg.refprice)
                       * TO_NUMBER (l_build_msg.refquantity)
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
              /* select nvl(max(sbc.holiday),'N') into l_isHoliday from sbcldr sbc, sysvar sy
               where sbc.cldrtype = l_build_msg.tradeplace
                and sy.grname = 'SYSTEM' AND sy.varname = 'CURRDATE'
                and sbc.sbdate = TO_DATE (sy.varvalue, systemnums.c_date_format);
                if l_isHoliday = 'Y' then
                   SELECT TO_DATE (varvalue, systemnums.c_date_format)
                   INTO l_txmsg.txdate
                   FROM sysvar
                   WHERE grname = 'SYSTEM' AND varname = 'NEXTDATE';
                else*/
                   SELECT TO_DATE (varvalue, systemnums.c_date_format)
                   INTO l_txmsg.txdate
                   FROM sysvar
                   WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
                ----end if;

               /*SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO l_txmsg.txdate
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';*/


               l_txmsg.brdate                    := l_txmsg.txdate;
               l_txmsg.busdate                   := l_txmsg.txdate;

               --2.4 Set fld value
               l_txmsg.txfields ('01').defname   := 'CODEID';
               l_txmsg.txfields ('01').TYPE      := 'C';
               l_txmsg.txfields ('01').VALUE     := l_build_msg.fld01; --set vale for CODEID

               l_txmsg.txfields ('07').defname   := 'SYMBOL';
               l_txmsg.txfields ('07').TYPE      := 'C';
               l_txmsg.txfields ('07').VALUE     := l_build_msg.fld07; --set vale for Symbol



               l_txmsg.txfields ('60').defname   := 'ISMORTAGE';
               l_txmsg.txfields ('60').TYPE      := 'N';
               l_txmsg.txfields ('60').VALUE     := l_ismortage; --set vale for Is mortage sell
               l_txmsg.txfields ('02').defname   := 'ACTYPE';
               l_txmsg.txfields ('02').TYPE      := 'C';
               -- l_txmsg.txfields ('02').VALUE     := l_build_msg.fld02; --set vale for Product code
               -- this is set above
               l_txmsg.txfields ('03').defname   := 'AFACCTNO';
               l_txmsg.txfields ('03').TYPE      := 'C';
               l_txmsg.txfields ('03').VALUE     := l_build_msg.fld03; --set vale for Contract number
               l_txmsg.txfields ('06').defname   := 'SEACCTNO';
               l_txmsg.txfields ('06').TYPE      := 'C';
               l_txmsg.txfields ('06').VALUE     := l_build_msg.fld06; --set vale for SE account number

               l_txmsg.txfields ('50').defname   := 'CUSTNAME';
               l_txmsg.txfields ('50').TYPE      := 'C';
               l_txmsg.txfields ('50').VALUE     := l_build_msg.username; --set vale for Customer name
               /*if p_timetype <> 'G' then
                   l_txmsg.txfields ('50').VALUE     := l_build_msg.username; --set vale for Customer name
               else
                   l_txmsg.txfields ('50').VALUE     := l_build_msg.acctno; --set vale for Customer name
               end if;*/
               -- this was set above already
               l_txmsg.txfields ('20').defname   := 'TIMETYPE';
               l_txmsg.txfields ('20').TYPE      := 'C';
               l_txmsg.txfields ('20').VALUE     := l_build_msg.fld20; --set vale for Duration
               l_txmsg.txfields ('21').defname   := 'EXPDATE';
               l_txmsg.txfields ('21').TYPE      := 'D';
               l_txmsg.txfields ('21').VALUE     := l_txmsg.txdate; --set vale for Expired date
               l_txmsg.txfields ('19').defname   := 'EFFDATE';
               l_txmsg.txfields ('19').TYPE      := 'D';
               l_txmsg.txfields ('19').VALUE     := l_build_msg.fld19; --set vale for Expired date
               l_txmsg.txfields ('22').defname   := 'EXECTYPE';
               l_txmsg.txfields ('22').TYPE      := 'C';
               --l_txmsg.txfields ('22').VALUE     := l_build_msg.fld22; --set vale for Execution type
               l_txmsg.txfields ('23').defname   := 'NORK';
               l_txmsg.txfields ('23').TYPE      := 'C';
               l_txmsg.txfields ('23').VALUE     := l_build_msg.fld23; --set vale for All or none?
               l_txmsg.txfields ('34').defname   := 'OUTPRICEALLOW';
               l_txmsg.txfields ('34').TYPE      := 'C';
               l_txmsg.txfields ('34').VALUE     := l_build_msg.fld34; --set vale for Accept out amplitute price
               l_txmsg.txfields ('24').defname   := 'MATCHTYPE';
               l_txmsg.txfields ('24').TYPE      := 'C';
               l_txmsg.txfields ('24').VALUE     := l_build_msg.fld24; --set vale for Matching type
               l_txmsg.txfields ('25').defname   := 'VIA';
               l_txmsg.txfields ('25').TYPE      := 'C';
               l_txmsg.txfields ('25').VALUE     := l_build_msg.fld25; --set vale for Via
               l_txmsg.txfields ('10').defname   := 'CLEARDAY';
               l_txmsg.txfields ('10').TYPE      := 'N';
              -- l_txmsg.txfields ('10').VALUE     := l_build_msg.fld10; --set vale for Clearing day
               l_txmsg.txfields ('10').VALUE     := l_clearday;--l_build_msg.fld10; --set vale for Clearing day

               l_txmsg.txfields ('26').defname   := 'CLEARCD';
               l_txmsg.txfields ('26').TYPE      := 'C';
               l_txmsg.txfields ('26').VALUE     := l_build_msg.fld26; --set vale for Calendar
               l_txmsg.txfields ('72').defname   := 'PUTTYPE';
               l_txmsg.txfields ('72').TYPE      := 'C';
               l_txmsg.txfields ('72').VALUE     := l_build_msg.fld72; --set vale for Puthought type
               l_txmsg.txfields ('27').defname   := 'PRICETYPE';
               l_txmsg.txfields ('27').TYPE      := 'C';
               l_txmsg.txfields ('27').VALUE     := l_build_msg.fld27; --set vale for Price type

               l_txmsg.txfields ('11').defname   := 'QUOTEPRICE';
               l_txmsg.txfields ('11').TYPE      := 'N';
               l_txmsg.txfields ('11').VALUE     := l_build_msg.fld11; --set vale for Limit price

               l_txmsg.txfields ('80').defname   := 'QUOTEQTTY';
               l_txmsg.txfields ('80').TYPE      := 'N';
               l_txmsg.txfields ('80').VALUE     := 0; --set vale for Limit price

               l_txmsg.txfields ('81').defname   := 'ORGQUOTEQTTY';
               l_txmsg.txfields ('81').TYPE      := 'N';
               l_txmsg.txfields ('81').VALUE     := 0; --set vale for Limit price

               l_txmsg.txfields ('82').defname   := 'ORGLIMITPRICE';
               l_txmsg.txfields ('82').TYPE      := 'N';
               l_txmsg.txfields ('82').VALUE     := 0; --set vale for Limit price

               l_txmsg.txfields ('90').defname   := 'TRADESTATUS';
               l_txmsg.txfields ('90').TYPE      := 'N';
               l_txmsg.txfields ('90').VALUE     := 0;
               IF l_build_msg.fld22 IN ('NS', 'MS', 'SS') THEN --gc_OD_PLACENORMALSELLORDER_ADVANCED
                   --HaiLT them cho GRPORDER
                   l_txmsg.txfields ('55').defname   := 'GRPORDER';
                   l_txmsg.txfields ('55').TYPE      := 'C';
                   l_txmsg.txfields ('55').VALUE     := 'N';
               END IF;

               IF l_build_msg.fld27 <> 'LO'
               THEN                                               -- Pricetype
                  IF l_strEXECTYPE='NB' --l_build_msg.fld22 = 'NB'
                  THEN                                             -- exectype
                     l_txmsg.txfields ('11').VALUE   :=
                        l_build_msg.ceilingprice
                        / l_build_msg.fld98;                --tradeunit
                  ELSE
                     l_txmsg.txfields ('11').VALUE   :=
                        l_build_msg.floorprice
                        / l_build_msg.fld98;
                  END IF;
               END IF;

               l_txmsg.txfields ('12').defname   := 'ORDERQTTY';
               l_txmsg.txfields ('12').TYPE      := 'N';
               l_txmsg.txfields ('12').VALUE     := l_build_msg.fld12; --set vale for Quantity
               l_txmsg.txfields ('13').defname   := 'BRATIO';
               l_txmsg.txfields ('13').TYPE      := 'N';
               --l_txmsg.txfields ('13').VALUE     := l_build_msg.fld13; --set vale for Block ration
               l_txmsg.txfields ('80').defname   := 'QUOTEQTTY';
               l_txmsg.txfields ('80').TYPE      := 'N';
               l_txmsg.txfields ('80').VALUE   := l_build_msg.fld80;
               l_txmsg.txfields ('14').defname   := 'LIMITPRICE';
               l_txmsg.txfields ('14').TYPE      := 'N';
               l_txmsg.txfields ('14').VALUE     := l_build_msg.fld14; --set vale for Stop price
               l_txmsg.txfields ('40').defname   := 'FEEAMT';
               l_txmsg.txfields ('40').TYPE      := 'N';
               --l_txmsg.txfields ('40').VALUE     := l_build_msg.fld40; --set vale for Fee amount
               l_txmsg.txfields ('28').defname   := 'VOUCHER';
               l_txmsg.txfields ('28').TYPE      := 'C';
               l_txmsg.txfields ('28').VALUE     := ''; --l_build_msg.fld28; --set vale for Voucher status
               l_txmsg.txfields ('29').defname   := 'CONSULTANT';
               l_txmsg.txfields ('29').TYPE      := 'C';
               l_txmsg.txfields ('29').VALUE     := ''; --l_build_msg.fld29; --set vale for Consultant status
               l_txmsg.txfields ('04').defname   := 'ORDERID';
               l_txmsg.txfields ('04').TYPE      := 'C';
               --l_txmsg.txfields ('04').VALUE     := l_build_msg.fld04; --set vale for Order ID
               --this is set below
               l_txmsg.txfields ('15').defname   := 'PARVALUE';
               l_txmsg.txfields ('15').TYPE      := 'N';
               l_txmsg.txfields ('15').VALUE     := l_build_msg.fld15; --set vale for Parvalue
               l_txmsg.txfields ('30').defname   := 'DESC';
               l_txmsg.txfields ('30').TYPE      := 'C';
               l_txmsg.txfields ('30').VALUE     := l_build_msg.fld30; --set vale for Description

               l_txmsg.txfields ('95').defname   := 'DFACCTNO';
               l_txmsg.txfields ('95').TYPE      := 'C';
               l_txmsg.txfields ('95').VALUE     := l_build_msg.fld95; --set vale for deal id

               l_txmsg.txfields ('94').defname   := 'SSAFACCTNO';
               l_txmsg.txfields ('94').TYPE      := 'C';
               l_txmsg.txfields ('94').VALUE     := l_build_msg.fld94; --set vale for short sale account

               l_txmsg.txfields ('90').defname   := 'TRADESTATUS';
               l_txmsg.txfields ('90').TYPE      := 'N';
               l_txmsg.txfields ('90').VALUE     := 0;

               l_txmsg.txfields ('90').defname   := 'TRADESTATUS';
               l_txmsg.txfields ('90').TYPE      := 'N';
               l_txmsg.txfields ('90').VALUE     := 0;
               l_txmsg.txfields ('99').defname   := 'HUNDRED';
               l_txmsg.txfields ('99').TYPE      := 'N';
               If l_strMarginType = 'N' Then
                    l_txmsg.txfields ('99').VALUE     := l_build_msg.fld99;
               Else
                    If l_dblIsPPUsed = 1 Then
                        l_txmsg.txfields ('99').VALUE     := to_char(100 / (1 - l_dblMarginRatioRate / 100 * l_dblSecMarginPrice / l_build_msg.fld11 / l_build_msg.fld98));
                    Else
                        l_txmsg.txfields ('99').VALUE     := l_build_msg.fld99;
                    End If;
               End If;

               l_txmsg.txfields ('98').defname   := 'TRADEUNIT';
               l_txmsg.txfields ('98').TYPE      := 'N';
               l_txmsg.txfields ('98').VALUE     := l_build_msg.fld98; --set vale for Trade unit

               l_txmsg.txfields ('96').defname   := 'TRADEUNIT';
               l_txmsg.txfields ('96').TYPE      := 'N';
               l_txmsg.txfields ('96').VALUE     := 1; --l_build_msg.fld96; --set vale for GTC

               l_txmsg.txfields ('97').defname   := 'MODE';
               l_txmsg.txfields ('97').TYPE      := 'C';
               l_txmsg.txfields ('97').VALUE     := l_build_msg.fld97; --set vale for MODE DAT LENH
               l_txmsg.txfields ('33').defname   := 'CLIENTID';
               l_txmsg.txfields ('33').TYPE      := 'C';
               l_txmsg.txfields ('33').VALUE     := l_build_msg.fld33; --set vale for ClientID
               l_txmsg.txfields ('73').defname   := 'CONTRAFIRM';
               l_txmsg.txfields ('73').TYPE      := 'C';
               l_txmsg.txfields ('73').VALUE     := l_build_msg.fld73; --set vale for Contrafirm
               l_txmsg.txfields ('32').defname   := 'TRADERID';
               l_txmsg.txfields ('32').TYPE      := 'C';
               l_txmsg.txfields ('32').VALUE     := l_build_msg.fld32; --set vale for TraderID
               l_txmsg.txfields ('71').defname   := 'CONTRACUS';
               l_txmsg.txfields ('71').TYPE      := 'C';
               l_txmsg.txfields ('71').VALUE     := ''; --l_build_msg.fld71; --set vale for Contra custody
               l_txmsg.txfields ('74').defname   := 'ISDISPOSAL';
               l_txmsg.txfields ('74').TYPE      := 'C';
               l_txmsg.txfields ('74').VALUE     := l_build_msg.ISDISPOSAL;
               l_txmsg.txfields ('31').defname   := 'CONTRAFIRM';
               l_txmsg.txfields ('31').TYPE      := 'C';
               l_txmsg.txfields ('31').VALUE     := l_build_msg.fld31; --set vale for Contrafirm

               l_txmsg.txfields ('90').defname   := 'TRADESTATUS';
               l_txmsg.txfields ('90').TYPE      := 'N';
               l_txmsg.txfields ('90').VALUE     := 0;

               l_txmsg.txfields ('35').defname   := 'ADVIDREF';
               l_txmsg.txfields ('35').TYPE      := 'C';
               l_txmsg.txfields ('35').VALUE     := '';
               IF l_build_msg.fld22 = 'AB' or l_build_msg.fld22 = 'AS'     then
                   l_txmsg.txfields ('16').defname   := 'ORGORDERQTTY';
                   l_txmsg.txfields ('16').TYPE      := 'N';
                   l_txmsg.txfields ('16').VALUE     := 0;
                   l_txmsg.txfields ('17').defname   := 'ORGQUOTEPRICE';
                   l_txmsg.txfields ('17').TYPE      := 'N';
                   l_txmsg.txfields ('17').VALUE     := 0;
               end if;

               /*
               --</ TruongLD Add 05/10/2011
               -- ADVIDREF
               l_txmsg.txfields ('35').defname   := 'ADVIDREF';
               l_txmsg.txfields ('35').TYPE      := 'C';
               l_txmsg.txfields ('35').VALUE     := l_build_msg.fld35; --set vale for CONTRAFIRM
               --End TruongLD/>
               */

               l_remainqtty                      :=
                  l_txmsg.txfields ('12').VALUE;

               l_txmsg.txfields ('08').VALUE     :=
                  l_build_msg.orgacctno;
              /* plog.debug (pkgctx,
                           'cancel orderid: '
                           || l_txmsg.txfields ('08').VALUE
               );*/

               l_order_count                     := 0;         --RESET COUNTER

               plog.debug (pkgctx, 'l_remainqtty: ' || l_remainqtty);
               if l_build_msg.SPLOPT='Q' then --Tach theo so lenh
                        l_breakingsize:= l_build_msg.SPLVAL;
               elsif l_build_msg.SPLOPT='O' then
                        l_breakingsize:= round(l_remainqtty/to_number(l_build_msg.SPLVAL) +
                                                case when l_build_msg.tradeplace='001' then 5-0.01
                                                     when l_build_msg.tradeplace='002' then 50-0.01
                                                     else 0.5-0.01 end,
                                                case when l_build_msg.tradeplace='001' then -1
                                                     when l_build_msg.tradeplace='002' then -2
                                                     else 0 end);
               else
                        l_breakingsize:= l_remainqtty;
               end if;
               IF l_build_msg.tradeplace = '001' then
                    --Neu san HSX thi xe toi da theo l_hosebreakingsize
                    if l_breakingsize > l_hosebreakingsize then
                        l_breakingsize:=l_hosebreakingsize;
                    else
                        l_breakingsize:=l_breakingsize;
                    end if;
               ELSIF l_build_msg.tradeplace in( '002','005') then
                    --Neu san HNX thi xe toi da theo l_hasebreakingsize
                    if l_breakingsize > l_hasebreakingsize then
                        l_breakingsize:=l_hasebreakingsize;
                    else
                        l_breakingsize:=l_breakingsize;
                    end if;
               end if;
               WHILE l_remainqtty > 0                               --quantity
               LOOP
                  SAVEPOINT sp#2;
                  l_order_count   := l_order_count + 1;

                  /*IF l_build_msg.tradeplace = '001'
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
                  END IF;*/
                  l_txmsg.txfields ('12').VALUE   :=
                        CASE
                           WHEN l_remainqtty > l_breakingsize
                           THEN
                              l_breakingsize
                           ELSE
                              l_remainqtty
                        END;
                  -- SET FEE AMOUNT
                  l_txmsg.txfields ('40').VALUE     :=
                    greatest(l_feerate/100 * TO_NUMBER (l_txmsg.txfields('12').VALUE)         --quantity
                     * TO_NUMBER (l_build_msg.fld11)       --quoteprice
                     * TO_NUMBER (l_build_msg.fld98),l_feeamountmin);

                  --2.1 Set txnum
                  SELECT systemnums.c_fo_prefixed
                         || LPAD (seq_fotxnum.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;

                  --v_strOrderID = FO_PREFIXED & "00" & Mid(Replace(v_strTXDATE, "/", vbNullString), 1, 4) & Mid(Replace(v_strTXDATE, "/", vbNullString), 7, 2) & Strings.Right(gc_FORMAT_ODAUTOID & CStr(v_DataAccess.GetIDValue("ODMAST")), Len(gc_FORMAT_ODAUTOID))
                  /*SELECT    systemnums.c_fo_prefixed
                         || '00'
                         || TO_CHAR (SYSDATE, 'DDMMRR')
                         || LPAD (seq_odmast.NEXTVAL, 6, '0')
                  INTO l_txmsg.txfields ('04').VALUE
                  FROM DUAL;*/
                  /*SELECT    systemnums.c_fo_prefixed
                         || '00'
                         || TO_CHAR(TO_DATE (VARVALUE, 'DD\MM\RR'),'DDMMRR')
                         || LPAD (seq_odmast.NEXTVAL, 6, '0')
                  INTO l_txmsg.txfields ('04').VALUE
                  FROM SYSVAR WHERE VARNAME ='CURRDATE' AND GRNAME='SYSTEM';*/


                   SELECT    systemnums.c_fo_prefixed
                         || '10'
                         || TO_CHAR(TO_DATE (VARVALUE, 'DD\MM\RR'),'DDMMRR')
                         || LPAD (seq_odmast.NEXTVAL, 6, '0')
                  INTO l_txmsg.txfields ('04').VALUE
                  FROM SYSVAR WHERE VARNAME ='CURRDATE' AND GRNAME='SYSTEM';

              /*    plog.debug (pkgctx,
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
                  );*/

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

                 /* plog.debug (pkgctx,
                              'DESC: ' || l_txmsg.txfields ('30').VALUE
                  );*/

                  INSERT INTO rootordermap
                 (
                     foacctno,
                     orderid,
                     status,
                     MESSAGE,
                     id
                 )
                  VALUES (
                            l_build_msg.acctno,
                            l_txmsg.txfields ('04').VALUE,
                            'A',
                            '[' || systemnums.c_success || '] OK,',
                            l_order_count
                         );

                  -- Get tltxcd from EXECTYPE
                  IF l_txmsg.txfields ('22').VALUE = 'NB'               --8876
                  THEN
                     BEGIN

                        l_txmsg.tltxcd   := '8876'; -- gc_OD_PLACENORMALBUYORDER_ADVANCED
                        --85    ISBONDTRANSACT     C
                        l_txmsg.txfields ('85').defname   := 'ISBONDTRANSACT';
                        l_txmsg.txfields ('85').TYPE      := 'C';
                        l_txmsg.txfields ('85').value     := 'N';
                        --86    BONDINFO     C
                        l_txmsg.txfields ('86').defname   := 'BONDINFO';
                        l_txmsg.txfields ('86').TYPE      := 'C';
                        l_txmsg.txfields ('86').value     := null;
                        -- 2: Process
                        IF txpks_#8876.fn_autotxprocess (l_txmsg,
                                                         p_err_code,
                                                         l_err_param
                           ) <> systemnums.c_success
                        THEN
                           plog.debug (pkgctx,
                                       'got error 8876: ' || p_err_code
                           );
                           --ONLY ROLLBACK FOR THIS MESSAGE
                           ROLLBACK TO SAVEPOINT sp#2;
                           -- Neu lenh thieu suc mua thi dong bo lai ci
                          IF nvl(p_err_code,'0') = '-400116' THEN
                                jbpks_auto.pr_trg_account_log(l_build_msg.fld03, 'CI');
                          END IF;
                           --EXIT; -- UNCOMMENT THIS IF YOU WANT TO EXIT LOOP WHEN GOT AN ERROR
                           RAISE errnums.e_biz_rule_invalid;
                        END IF;
                     END;                                               --8876
                  ELSIF l_build_msg.fld22 IN ('NS', 'MS', 'SS')  --8877
                  THEN
                     BEGIN
                        l_txmsg.tltxcd   := '8877'; --gc_OD_PLACENORMALSELLORDER_ADVANCED
                        --85    ISBONDTRANSACT     C
                        l_txmsg.txfields ('85').defname   := 'ISBONDTRANSACT';
                        l_txmsg.txfields ('85').TYPE      := 'C';
                        l_txmsg.txfields ('85').value     := 'N';
                        --86    BONDINFO     C
                        l_txmsg.txfields ('86').defname   := 'BONDINFO';
                        l_txmsg.txfields ('86').TYPE      := 'C';
                        l_txmsg.txfields ('86').value     := null;
                        -- 2: Process
                        IF txpks_#8877.fn_autotxprocess (l_txmsg,
                                                         p_err_code,
                                                         l_err_param
                           ) <> systemnums.c_success
                        THEN
                           plog.debug (pkgctx,
                                          '8877: '
                                       || p_err_code
                                       || ':'
                                       || l_err_param
                           );
                           --ONLY ROLLBACK FOR THIS MESSAGE
                           ROLLBACK TO SAVEPOINT sp#2;
                           --EXIT; -- UNCOMMENT THIS IF YOU WANT TO EXIT LOOP WHEN GOT AN ERROR
                           RAISE errnums.e_biz_rule_invalid;
                        END IF;
                     END;                                              -- 8887
                  ELSIF l_build_msg.fld22 = 'AB'                 --8884
                  THEN
                     BEGIN
                        l_txmsg.tltxcd   := '8884';  --gc_OD_AMENDMENTBUYORDER

                        -- 2: Process
                        IF txpks_#8884.fn_autotxprocess (l_txmsg,
                                                         p_err_code,
                                                         l_err_param
                           ) <> systemnums.c_success
                        THEN
                           plog.debug (pkgctx,
                                       'got error 8884: ' || p_err_code
                           );
                           --ONLY ROLLBACK FOR THIS MESSAGE
                           ROLLBACK TO SAVEPOINT sp#2;
                           -- Neu lenh thieu suc mua thi dong bo lai ci
                          IF nvl(p_err_code,'0') = '-400116' THEN
                                jbpks_auto.pr_trg_account_log(l_build_msg.fld03, 'CI');
                          END IF;
                           --EXIT; -- UNCOMMENT THIS IF YOU WANT TO EXIT LOOP WHEN GOT AN ERROR
                           RAISE errnums.e_biz_rule_invalid;
                        END IF;
                     END;                                               --8884
                  ELSIF l_build_msg.fld22 = 'AS'                 --8885
                  THEN
                     BEGIN
                        l_txmsg.tltxcd   := '8885'; --gc_OD_AMENDMENTSELLORDER

                        -- 2: Process
                        IF txpks_#8885.fn_autotxprocess (l_txmsg,
                                                         p_err_code,
                                                         l_err_param
                           ) <> systemnums.c_success
                        THEN
                           plog.debug (pkgctx,
                                       'got error 8885: ' || p_err_code
                           );
                           --ONLY ROLLBACK FOR THIS MESSAGE
                           ROLLBACK TO SAVEPOINT sp#2;
                           --EXIT; -- UNCOMMENT THIS IF YOU WANT TO EXIT LOOP WHEN GOT AN ERROR
                           RAISE errnums.e_biz_rule_invalid;
                        END IF;
                     END;                                               --8885
                  ELSIF l_build_msg.fld22 = 'CB'                 --8882
                  THEN
                     BEGIN
                        l_txmsg.tltxcd   := '8882';     --gc_OD_CANCELBUYORDER

                        -- 2: Process
                        IF txpks_#8882.fn_autotxprocess (l_txmsg,
                                                         p_err_code,
                                                         l_err_param
                           ) <> systemnums.c_success
                        THEN
                           plog.debug (pkgctx,
                                       'got error 8882: ' || p_err_code
                           );
                           --ONLY ROLLBACK FOR THIS MESSAGE
                           ROLLBACK TO SAVEPOINT sp#2;
                           --EXIT; -- UNCOMMENT THIS IF YOU WANT TO EXIT LOOP WHEN GOT AN ERROR
                           RAISE errnums.e_biz_rule_invalid;
                        END IF;
                     END;                                               --8882
                  ELSIF l_build_msg.fld22 = 'CS'                 --8883
                  THEN
                     BEGIN
                        l_txmsg.tltxcd   := '8883';    --gc_OD_CANCELSELLORDER

                        -- 2: Process
                        IF txpks_#8883.fn_autotxprocess (l_txmsg,
                                                         p_err_code,
                                                         l_err_param
                           ) <> systemnums.c_success
                        THEN
                           plog.debug (pkgctx,
                                       'got error 8883: ' || p_err_code
                           );
                           --ONLY ROLLBACK FOR THIS MESSAGE
                           ROLLBACK TO SAVEPOINT sp#2;
                           --EXIT; -- UNCOMMENT THIS IF YOU WANT TO EXIT LOOP WHEN GOT AN ERROR
                           RAISE errnums.e_biz_rule_invalid;
                        END IF;
                     END;
                  END IF;

                  UPDATE fomast
                  SET orgacctno    = l_txmsg.txfields ('04').VALUE,
                      status       = 'A',
                      feedbackmsg   =
                         'Order is active and sucessfull processed: '
                         || l_txmsg.txfields ('04').VALUE
                  WHERE acctno = l_build_msg.acctno;



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
                  plog.error (pkgctx,
                                 'row:'
                              || dbms_utility.format_error_backtrace
                  );
                  p_err_code:=errnums.c_od_odtype_notfound;
                  UPDATE fomast
                  SET status    = 'R',
                             feedbackmsg   =
                                '[' || errnums.c_od_odtype_notfound || '] '
                                || cspks_system.fn_get_errmsg(errnums.c_od_odtype_notfound)
                  WHERE acctno = l_build_msg.acctno;
               WHEN errnums.e_invalid_session
               THEN
                  -- Log error and continue to process the next order
                  plog.error (pkgctx,
                                 'INVALID SESSION(pricetype,mktstatus):'
                              || l_build_msg.fld27
                              || ','
                              || l_mktstatus
                  );
                  p_err_code:=errnums.c_invalid_session;
                  UPDATE fomast
                  SET status    = 'R',
                      feedbackmsg   =
                         '[' || errnums.c_invalid_session || '] '
                         || cspks_system.fn_get_errmsg(errnums.c_invalid_session)
                  WHERE acctno = l_build_msg.acctno;
               --LogOrderMessage(v_ds.Tables(0).Rows(i)("ACCTNO"))
               WHEN errnums.e_biz_rule_invalid
               THEN
                  -- KIEM TRA NEU TH CHIA LENH MA DA CO LENH CHIA THANH CONG THI KO CAP NHAT LENH TRONG FOMAST
                  --- lenh GTC khong cap nhat.
                  --- 19/12/2022 TrungNQ: cap nhat fomast cho lenh dieu kien
                  IF NOT (l_remainqtty < l_build_msg.fld12) and p_timetype <> 'G' THEN
                  -- Neu lenh Bloomberg, thieu tien hoac thieu CK thi de trang thai cho xu ly tiep
                    -- DungNH, 02-Nov-2015
                    IF (nvl(p_err_code,'0') = '-400116' OR nvl(p_err_code,'0') = '-900017') AND l_build_msg.fld25 = 'L' AND l_CUSTATCOM = 'N' AND l_build_msg.fld22 in ('NB','NS') THEN
                        UPDATE fomast
                          SET status        = 'T',
                              feedbackmsg   = '[' || p_err_code || '] ' || l_err_param
                          WHERE acctno = l_build_msg.acctno;
                      -- Ket thuc sua cho Bloomberg
                    ELSE
                        UPDATE fomast
                          SET status        = 'R',
                              feedbackmsg   = '[' || p_err_code || '] ' || l_err_param
                          WHERE acctno = l_build_msg.acctno;

                          INSERT INTO rootordermap
                         (
                             foacctno,
                             orderid,
                             status,
                             MESSAGE,
                             id
                         )
                          VALUES (
                                    l_build_msg.acctno,
                                    '',
                                    'R',
                                    '[' || p_err_code || '] ' || l_err_param,
                                    l_order_count
                                 );
                     end if;
                  END IF;

                when others
                then
                  p_err_code:=errnums.C_SYSTEM_ERROR;
                  plog.error (pkgctx,'Error when send syn order!');
            END;
      END LOOP;
      COMMIT;                                -- Commit the last trunk (if any)
      /***************************************************************************************************
      ** END;
      ***************************************************************************************************/
      plog.debug (pkgctx, '<<END OF pr_fo2odsyn');
      plog.setendsection (pkgctx, 'pr_fo2odsyn');
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         plog.error (pkgctx, dbms_utility.format_error_backtrace);

         CLOSE curs_build_msg;

         plog.setendsection (pkgctx, 'pr_fo2odsyn');
   END pr_fo2odsyn;

   PROCEDURE pr_fo2odbyorder (p_orderid varchar2, p_err_code  OUT varchar2 )
   IS
      l_txmsg               tx.msg_rectype;
      l_orders_cache_size   NUMBER (10) := 10000;
      l_commit_freq         NUMBER (10) := 10;
      l_count               NUMBER (10) := 0;
      l_order_count         NUMBER (10) := 0;
      l_isHoliday           varchar2(10);
      l_err_param           deferror.errdesc%TYPE;

      l_mktstatus           ordersys.sysvalue%TYPE;
      l_atcstarttime        sysvar.varvalue%TYPE;

      l_typebratio          odtype.bratio%TYPE;
      l_afbratio            afmast.bratio%TYPE;
      l_securedratio        odtype.bratio%TYPE;
      l_actype              odtype.actype%TYPE;
      l_remainqtty          odmast.orderqtty%TYPE;
      l_fullname            cfmast.fullname%TYPE;
      l_ordervia            odtype.via%type;

      l_feeamountmin        NUMBER;
      l_feerate             NUMBER;
      l_feesecureratiomin   NUMBER;
      l_hosebreakingsize    NUMBER;
      l_hasebreakingsize    NUMBER;
      l_breakingsize        NUMBER;
      l_strMarginType       mrtype.mrtype%TYPE;
      l_dblMarginRatioRate  afserisk.MRRATIOLOAN%TYPE;
      l_dblSecMarginPrice   afserisk.MRPRICELOAN%TYPE;
      --</ Margin 74
      l_dblIsMarginAllow   afserisk.ISMARGINALLOW%TYPE;
      l_dblChkSysCtrl       lntype.chksysctrl%TYPE;
      --/>
      l_dblIsPPUsed         mrtype.ISPPUSED%TYPE;
      l_strEXECTYPE         odmast.exectype%TYPE;



   BEGIN
      plog.setbeginsection (pkgctx, 'pr_fo2odbyorder');
      plog.debug (pkgctx, 'BEGIN OF pr_fo2odbyorder');
      /***************************************************************************************************
       ** PUT YOUR CODE HERE, FOLLOW THE BELOW TEMPLATE:
       ** IF NECCESSARY, USING BULK COLLECTION IN THE CASE YOU MUST POPULATE LARGE DATA
      ****************************************************************************************************/
      l_atcstarttime      :=
         cspks_system.fn_get_sysvar ('SYSTEM', 'ATCSTARTTIME');
      --l_hosebreakingsize   :=
         --cspks_system.fn_get_sysvar ('SYSTEM', 'HOSEBREAKSIZE');
      l_hosebreakingsize   :=least(cspks_system.fn_get_sysvar ('SYSTEM', 'HOSEBREAKSIZE'),
                                    cspks_system.fn_get_sysvar ('BROKERDESK', 'HOSE_MAX_QUANTITY')
                                  );
      l_hasebreakingsize:=cspks_system.fn_get_sysvar ('BROKERDESK', 'HNX_MAX_QUANTITY');

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
      for l_build_msg in
      (
         SELECT  a.codeid fld01,
                 a.symbol fld07,
                 DECODE (a.exectype, 'MS', '1', '0') fld60, --ismortage   fld60, -- FOR 8885
                 a.actype fld02,
                 a.afacctno || a.codeid fld06,                --seacctno    fld06,
                 a.afacctno fld03,
                 a.timetype fld20,
                 a.effdate fld19,
                 --a.expdate fld21,
                 getcurrdate fld21,
                 a.exectype fld22,
                 a.outpriceallow fld34,
                 a.nork fld23,
                 a.matchtype fld24,
                 a.via fld25,
                 a.clearday fld10,
                 a.clearcd fld26,
                 'O' fld72,                                       --puttype fld72,
                (CASE WHEN a.exectype IN ('AB','AS') AND a.pricetype='MTL' THEN 'LO'
                       WHEN a.pricetype = 'RP' THEN FN_GETPRICETYPE4RP(b.tradeplace) --DUCNV sua lenh RP
                       ELSE a.pricetype
                  END ) fld27,
                -- PhuongHT edit for sua lenh MTL
                 a.quantity fld12,                      --a.ORDERQTTY       fld12,
                 a.quoteprice fld11,
                 0 fld18,                               --a.ADVSCRAMT       fld18,
                 0 fld17,                               --a.ORGQUOTEPRICE   fld17,
                 0 fld16,                               --a.ORGORDERQTTY    fld16,
                 0 fld31,                               --a.ORGSTOPPRICE    fld31,
                 a.bratio fld13,
                 0 fld14,                               --a.LIMITPRICE      fld14,
                 0 fld40,                                                -- FEEAMT
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
                 c.marginrefprice,
                 b.tradeplace,
                 b.sectype,
                 c.tradelot,
                 c.securedratiomin,
                 c.securedratiomax,
                 a.SPLOPT,
                 a.SPLVAL,
                 a.ISDISPOSAL,
                 a.username,
                 a.SSAFACCTNO fld94,
                 '' fld35,
                 a.tlid tlid,
                 a.Quoteqtty fld80

          FROM fomast a, sbsecurities b, securities_info c
          WHERE     a.book = 'A'
                AND a.timetype <> 'G'
                AND a.status = 'P'
                and a.direct='N'
                AND a.codeid = b.codeid
                AND a.codeid = c.codeid
                and ((a.pricetype = 'LO' and a.quoteprice <> 0) or (a.pricetype <> 'LO'))
                and a.quantity <> 0
                and a.acctno = p_orderid
      )
      LOOP
            BEGIN
                plog.error(pkgctx,'fo2odsyn:00 ' ||l_build_msg.fld60);
               -- Check Market status
               SELECT sysvalue
               INTO l_mktstatus
               FROM ordersys
               WHERE sysname = 'CONTROLCODE';

               plog.debug (pkgctx,
                              'l_mktstatus,pricetype: '
                           || l_mktstatus
                           || ','
                           || l_build_msg.fld27
               );

               -- l_mktstatus=P: 8h30-->9h00 session 1 ATO
               -- l_mktstatus=O: 9h00-->10h15 session 2 MP
               -- l_mktstatus=A: 10h15-->10h30 session 3 ATC

               -- </ TruongLD Add
               l_txmsg.tlid := l_build_msg.tlid;
               --/>

               IF l_build_msg.fld27 = 'ATO'
               THEN                                        -- fld27: pricetype
                  IF l_mktstatus IN ('O', 'A')
                  THEN
                     RAISE errnums.e_invalid_session;
                  END IF;

               /*ELSIF l_build_msg.fld27 = 'ATC'
               THEN
                  IF not(l_mktstatus = 'A'
                            or (l_mktstatus = 'O'
                                    AND l_atcstarttime <=
                                        TO_CHAR (SYSDATE, 'HH24MISS')))
                  THEN
                     RAISE errnums.e_invalid_session;
                  END IF;*/
               ELSIF l_build_msg.fld27 = 'MO'
               THEN
                  IF l_mktstatus <> 'O'
                  THEN
                     RAISE errnums.e_invalid_session;
                  END IF;
               END IF;

               l_txmsg.txfields ('22').VALUE     := l_build_msg.fld22; --set vale for Execution TYPE
               l_strEXECTYPE:=l_build_msg.fld22;
               plog.debug (pkgctx,
                           'exectype: ' || l_txmsg.txfields ('22').VALUE
               );

               IF LENGTH (l_build_msg.refacctno) > 0
               THEN                                             --lENH HUY SUA
                  FOR i IN (SELECT exectype
                            FROM fomast
                            WHERE orgacctno = l_build_msg.refacctno)
                  LOOP
                     --l_txmsg.txfields ('22').VALUE   := i.exectype;
                     l_strEXECTYPE:=i.exectype;
                     plog.debug (pkgctx,
                                 'cancel orders, set exectype: '
                                 || l_txmsg.txfields('22').VALUE
                     );
                  END LOOP;
               END IF;

               IF l_build_msg.fld27 <> 'LO'
               THEN                                               -- Pricetype
                  IF l_strEXECTYPE='NB'--l_build_msg (indx).fld22 = 'NB'
                  THEN                                             -- exectype
                     l_build_msg.fld11   :=
                        l_build_msg.ceilingprice
                        / l_build_msg.fld98;                --tradeunit
                  ELSE
                     l_build_msg.fld11   :=
                        l_build_msg.floorprice
                        / l_build_msg.fld98;
                  END IF;
               END IF;

               --plog.debug (pkgctx, 'ACCTNO: ' || l_build_msg.fld03);

               FOR i IN (SELECT MST.BRATIO, CF.CUSTODYCD,CF.FULLNAME,MST.ACTYPE,MRT.MRTYPE,MRT.ISPPUSED,
                        NVL(RSK.MRRATIOLOAN,0) MRRATIOLOAN, NVL(MRPRICELOAN,0) MRPRICELOAN,
                        nvl(ISMARGINALLOW,'N') ISMARGINALLOW, nvl(lnt.chksysctrl,'N') chksysctrl
                        FROM AFMAST MST, CFMAST CF ,AFTYPE AFT, MRTYPE MRT, LNTYPE LNT,
                        (SELECT * FROM AFSERISK WHERE CODEID=l_build_msg.fld01 ) RSK
                        WHERE MST.ACCTNO=l_build_msg.fld03
                        AND MST.CUSTID=CF.CUSTID
                        and mst.actype =aft.actype and aft.mrtype = mrt.actype and aft.lntype = lnt.actype(+)
                        AND AFT.ACTYPE =RSK.ACTYPE(+))
               LOOP
                  l_txmsg.txfields ('09').VALUE   := i.custodycd;
                  l_actype                        := i.actype;
                  l_afbratio                      := i.bratio;
                  --l_txmsg.txfields ('50').VALUE   := 'FO';
                  l_fullname                      := i.fullname;
                  l_strMarginType                 := i.MRTYPE;
                  l_dblMarginRatioRate            := i.MRRATIOLOAN;
                  l_dblSecMarginPrice             := i.MRPRICELOAN;
                  l_dblIsMarginAllow              := i.ISMARGINALLOW;
                  l_dblChkSysCtrl                 := i.CHKSYSCTRL;
                  l_dblIsPPUsed                   := i.ISPPUSED;
                  If l_dblMarginRatioRate >= 100 Or l_dblMarginRatioRate < 0 or (l_dblIsMarginAllow = 'N' and l_dblChkSysCtrl = 'Y')
                  Then
                        l_dblMarginRatioRate := 0;
                  END IF;
                  if l_dblChkSysCtrl = 'Y' then
                      if l_build_msg.marginrefprice > l_dblSecMarginPrice
                      then
                            l_dblSecMarginPrice := l_dblSecMarginPrice;
                      else
                            l_dblSecMarginPrice := l_build_msg.marginrefprice;
                      end if;
                  else
                      if l_build_msg.marginprice > l_dblSecMarginPrice
                      then
                            l_dblSecMarginPrice := l_dblSecMarginPrice;
                      else
                            l_dblSecMarginPrice := l_build_msg.marginprice;
                      end if;
                  end if;
               END LOOP;


               plog.debug (pkgctx, 'VIA: ' || l_build_msg.fld25);
               plog.debug (pkgctx, 'CLEARCD: ' || l_build_msg.fld26);
               plog.debug (pkgctx, 'EXECTYPE: ' || l_build_msg.fld22);
               plog.debug (pkgctx, 'TIMETYPE: ' || l_build_msg.fld20);
               plog.debug (pkgctx, 'PRICETYPE: ' || l_build_msg.fld27);
               plog.debug (pkgctx, 'MATCHTYPE: ' || l_build_msg.fld24);
               plog.debug (pkgctx, 'NORK: ' || l_build_msg.fld23);
               plog.debug (pkgctx, 'sectype: ' || l_build_msg.sectype);
               plog.debug (pkgctx,
                           'tradeplace: ' || l_build_msg.tradeplace
               );

               BEGIN
/* vinh comment de cap nhat tinh nang nhieu bieu phi
                  SELECT actype, clearday, bratio, minfeeamt, deffeerate
                  --to_char(sysdate,systemnums.C_TIME_FORMAT) TXTIME
                  INTO l_txmsg.txfields ('02').VALUE,                 --ACTYPE
                       l_txmsg.txfields ('10').VALUE,               --CLEARDAY
                       l_typebratio,                          --BRATIO (fld13)
                       l_feeamountmin,
                       l_feerate
                  FROM odtype a
                  WHERE     status = 'Y'
                        AND (via = l_build_msg.fld25 OR via = 'A') --VIA
                        AND clearcd = l_build_msg.fld26       --CLEARCD
                        AND (exectype = l_strEXECTYPE           --l_build_msg.fld22
                             OR exectype = 'AA')                    --EXECTYPE
                        AND (timetype = l_build_msg.fld20
                             OR timetype = 'A')                     --TIMETYPE
                        AND (pricetype = l_build_msg.fld27
                             OR pricetype = 'AA')                  --PRICETYPE
                        AND (matchtype = l_build_msg.fld24
                             OR matchtype = 'A')                   --MATCHTYPE
                        AND (tradeplace = l_build_msg.tradeplace
                             OR tradeplace = '000')
--                        AND (sectype = l_build_msg.sectype
--                             OR sectype = '000')
                        AND (instr(case when l_build_msg.sectype in ('001','002','008') then l_build_msg.sectype || ',' || '111'
                                       when l_build_msg.sectype in ('003','006') then l_build_msg.sectype || ',' || '222'
                                       else l_build_msg.sectype end , sectype)>0 OR sectype = '000')
                        AND (nork = l_build_msg.fld23 OR nork = 'A') --NORK
                        AND EXISTS
                              (SELECT 1
                               FROM afidtype
                               WHERE     objname = 'OD.ODTYPE'
                                     AND aftype = l_actype
                                     AND actype = a.actype);
*/
                  -- Neu lenh sua thi lay lai ti le ky quy va thong tin loai hinh nhu lenh goc
                    -- TheNN, 15-Feb-2012
                    IF substr(l_txmsg.txfields ('22').VALUE,1,1) = 'A' THEN
                        SELECT OD.ACTYPE, OD.CLEARDAY, OD.BRATIO
                        INTO l_txmsg.txfields ('02').VALUE, l_txmsg.txfields ('10').VALUE, l_securedratio
                        FROM ODMAST OD
                        WHERE ORDERID = l_build_msg.orgacctno;
                    ELSE
                        -- LAY THONG TIN VA TINH TY LE KY QUY NHU BINH THUONG
                        -- Trong loai hinh OD ko quy dinh kenh GD qua BrokerDesk nen se gan cung kenh voi tai san (Floor)
                        BEGIN
                              -- TheNN, 14-Feb-2012
                              l_ordervia := l_build_msg.fld25;
                              if l_ordervia = 'B' then
                                  l_ordervia := 'F';
                              end if;
                              -- End: TheNN, 14-Feb-2012

                                SELECT actype, clearday, bratio, minfeeamt, deffeerate
                              --to_char(sysdate,systemnums.C_TIME_FORMAT) TXTIME
                              INTO l_txmsg.txfields ('02').VALUE,                 --ACTYPE
                                   l_txmsg.txfields ('10').VALUE,               --CLEARDAY
                                   l_typebratio,                          --BRATIO (fld13)
                                   l_feeamountmin,
                                   l_feerate
                              FROM (SELECT a.actype, a.clearday, a.bratio, a.minfeeamt, a.deffeerate, b.ODRNUM
                              FROM odtype a, afidtype b
                              WHERE     a.status = 'Y'
                                    AND (a.via = l_build_msg.fld25 OR a.via = 'A') --VIA
                                    AND a.clearcd = l_build_msg.fld26       --CLEARCD
                                    AND (a.exectype = l_strEXECTYPE           --l_build_msg.fld22
                                         OR a.exectype = 'AA')                    --EXECTYPE
                                    AND (a.timetype = l_build_msg.fld20
                                         OR a.timetype = 'A')                     --TIMETYPE
                                    AND (a.pricetype = l_build_msg.fld27
                                         OR a.pricetype = 'AA')                  --PRICETYPE
                                    AND (a.matchtype = l_build_msg.fld24
                                         OR a.matchtype = 'A')                   --MATCHTYPE
                                    AND (a.tradeplace = l_build_msg.tradeplace
                                         OR a.tradeplace = '000')
            --                        AND (sectype = l_build_msg.sectype
            --                             OR sectype = '000')
                                    ---001+002+006+003 -->333
                                    ---008+006+003 -->444
                                    ---001+002+008-->111
                                    ---006+003-->222
                                    AND (instr(case when l_build_msg.sectype in ('001','002') then l_build_msg.sectype || ',' || '111,333'
                                                   when l_build_msg.sectype in ('003','006') then l_build_msg.sectype || ',' || '222,333,444'
                                                   when l_build_msg.sectype in ('008') then l_build_msg.sectype || ',' || '111,444'
                                                   else l_build_msg.sectype end, a.sectype)>0 OR a.sectype = '000')
                                    AND (a.nork = l_build_msg.fld23 OR a.nork = 'A') --NORK
                                    AND (CASE WHEN A.CODEID IS NULL THEN l_build_msg.fld01 ELSE A.CODEID END)=l_build_msg.fld01
                                    AND a.actype = b.actype and b.aftype=l_actype and b.objname='OD.ODTYPE'
                                    --order by b.odrnum DESC, A.deffeerate DESC
                                    --order BY A.deffeerate DESC, B.ACTYPE DESC
                                    order BY A.deffeerate , B.ACTYPE DESC -- Lay ti le phi nho nhat
                                    ) where rownum<=1;
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
                                    select (case when nvl(dfprice,0)>0 then least(nvl(dfrate,0),round(nvl(dfprice,0)/ l_build_msg.fld11/l_build_msg.fld98 * 100,4)) else nvl(dfrate,0) end ) dfrate
                                    into l_securedratio
                                    from (select * from dfbasket where symbol=l_build_msg.fld07) bk,
                                    aftype aft, dftype dft,afmast af
                                    where af.actype = aft.actype and aft.dftype = dft.actype and dft.basketid = bk.basketid (+)
                                    and af.acctno = l_build_msg.fld03;
                                    l_securedratio:=greatest (100-l_securedratio,0);
                                exception
                                when others then
                                     l_securedratio:=100;
                                end;
                           else
                                l_securedratio                    :=
                                GREATEST (LEAST (l_typebratio + l_afbratio, 100),
                                        l_build_msg.securedratiomin
                                );
                                l_securedratio                    :=
                                  CASE
                                     WHEN l_securedratio > l_build_msg.securedratiomax
                                     THEN
                                        l_build_msg.securedratiomax
                                     ELSE
                                        l_securedratio
                                  END;
                           end if;

                           --FeeSecureRatioMin = mv_dblFeeAmountMin * 100 / (CDbl(v_strQUANTITY) * CDbl(v_strQUOTEPRICE) * CDbl(v_strTRADEUNIT))
                           l_feesecureratiomin               :=
                              l_feeamountmin * 100
                              / (  TO_NUMBER (l_build_msg.fld12)         --quantity
                                 * TO_NUMBER (l_build_msg.fld11)       --quoteprice
                                 * TO_NUMBER (l_build_msg.fld98));      --tradeunit

                           IF l_feesecureratiomin > l_feerate
                           THEN
                              l_securedratio   := l_securedratio + l_feesecureratiomin;
                           ELSE
                              l_securedratio   := l_securedratio + l_feerate;
                           END IF;
                    END IF;
                END;


               /*l_txmsg.txfields ('40').VALUE     :=
                    greatest(l_feerate/100 * TO_NUMBER (l_build_msg.fld12)         --quantity
                     * TO_NUMBER (l_build_msg.fld11)       --quoteprice
                     * TO_NUMBER (l_build_msg.fld98),l_feeamountmin);*/

               l_txmsg.txfields ('13').VALUE     := l_securedratio;

               IF (  TO_NUMBER (l_build_msg.fld12)
                   * TO_NUMBER (l_build_msg.fld11)
                   * l_securedratio
                   / 100
                   -   TO_NUMBER (l_build_msg.refprice)
                     * TO_NUMBER (l_build_msg.refquantity)
                     * l_securedratio
                     / 100 > 0)
               THEN
                  l_txmsg.txfields ('18').VALUE   :=
                       TO_NUMBER (l_build_msg.fld12)
                     * TO_NUMBER (l_build_msg.fld11)
                     * l_securedratio
                     / 100
                     -   TO_NUMBER (l_build_msg.refprice)
                       * TO_NUMBER (l_build_msg.refquantity)
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
               -- l_count_date
               -- l_isHoliday


               /*select nvl(max(sbc.holiday),'N') into l_isHoliday from sbcldr sbc, sysvar sy
               where sbc.cldrtype = l_build_msg.tradeplace
                and sy.grname = 'SYSTEM' AND sy.varname = 'CURRDATE'
                and sbc.sbdate = TO_DATE (sy.varvalue, systemnums.c_date_format);
                if l_isHoliday = 'Y' then
                   SELECT TO_DATE (varvalue, systemnums.c_date_format)
                   INTO l_txmsg.txdate
                   FROM sysvar
                   WHERE grname = 'SYSTEM' AND varname = 'NEXTDATE';
                else*/
                   SELECT TO_DATE (varvalue, systemnums.c_date_format)
                   INTO l_txmsg.txdate
                   FROM sysvar
                   WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
                ---end if;

               l_txmsg.brdate                    := l_txmsg.txdate;
               l_txmsg.busdate                   := l_txmsg.txdate;

               --2.4 Set fld value
               l_txmsg.txfields ('01').defname   := 'CODEID';
               l_txmsg.txfields ('01').TYPE      := 'C';
               l_txmsg.txfields ('01').VALUE     := l_build_msg.fld01; --set vale for CODEID

               l_txmsg.txfields ('07').defname   := 'SYMBOL';
               l_txmsg.txfields ('07').TYPE      := 'C';
               l_txmsg.txfields ('07').VALUE     := l_build_msg.fld07; --set vale for Symbol
               plog.error(pkgctx,'fo2odsyn: ' ||l_build_msg.fld60);
               l_txmsg.txfields ('60').defname   := 'ISMORTAGE';
               l_txmsg.txfields ('60').TYPE      := 'N';
               l_txmsg.txfields ('60').VALUE     := l_build_msg.fld60; --set vale for Is mortage sell
               l_txmsg.txfields ('02').defname   := 'ACTYPE';
               l_txmsg.txfields ('02').TYPE      := 'C';
               -- l_txmsg.txfields ('02').VALUE     := l_build_msg.fld02; --set vale for Product code
               -- this is set above
               l_txmsg.txfields ('03').defname   := 'AFACCTNO';
               l_txmsg.txfields ('03').TYPE      := 'C';
               l_txmsg.txfields ('03').VALUE     := l_build_msg.fld03; --set vale for Contract number
               l_txmsg.txfields ('06').defname   := 'SEACCTNO';
               l_txmsg.txfields ('06').TYPE      := 'C';
               l_txmsg.txfields ('06').VALUE     := l_build_msg.fld06; --set vale for SE account number
               l_txmsg.txfields ('50').defname   := 'CUSTNAME';
               l_txmsg.txfields ('50').TYPE      := 'C';
               l_txmsg.txfields ('50').VALUE     := l_build_msg.username; --set vale for Customer name

               -- this was set above already
               l_txmsg.txfields ('20').defname   := 'TIMETYPE';
               l_txmsg.txfields ('20').TYPE      := 'C';
               l_txmsg.txfields ('20').VALUE     := l_build_msg.fld20; --set vale for Duration
               l_txmsg.txfields ('21').defname   := 'EXPDATE';
               l_txmsg.txfields ('21').TYPE      := 'D';
               l_txmsg.txfields ('21').VALUE     := l_build_msg.fld21; --set vale for Expired date
               l_txmsg.txfields ('19').defname   := 'EFFDATE';
               l_txmsg.txfields ('19').TYPE      := 'D';
               l_txmsg.txfields ('19').VALUE     := l_build_msg.fld19; --set vale for Expired date
               l_txmsg.txfields ('22').defname   := 'EXECTYPE';
               l_txmsg.txfields ('22').TYPE      := 'C';
               --l_txmsg.txfields ('22').VALUE     := l_build_msg.fld22; --set vale for Execution type
               l_txmsg.txfields ('23').defname   := 'NORK';
               l_txmsg.txfields ('23').TYPE      := 'C';
               l_txmsg.txfields ('23').VALUE     := l_build_msg.fld23; --set vale for All or none?
               l_txmsg.txfields ('34').defname   := 'OUTPRICEALLOW';
               l_txmsg.txfields ('34').TYPE      := 'C';
               l_txmsg.txfields ('34').VALUE     := l_build_msg.fld34; --set vale for Accept out amplitute price
               l_txmsg.txfields ('24').defname   := 'MATCHTYPE';
               l_txmsg.txfields ('24').TYPE      := 'C';
               l_txmsg.txfields ('24').VALUE     := l_build_msg.fld24; --set vale for Matching type
               l_txmsg.txfields ('25').defname   := 'VIA';
               l_txmsg.txfields ('25').TYPE      := 'C';
               l_txmsg.txfields ('25').VALUE     := l_build_msg.fld25; --set vale for Via
               l_txmsg.txfields ('10').defname   := 'CLEARDAY';
               l_txmsg.txfields ('10').TYPE      := 'N';
               l_txmsg.txfields ('10').VALUE     := l_build_msg.fld10; --set vale for Clearing day
               l_txmsg.txfields ('26').defname   := 'CLEARCD';
               l_txmsg.txfields ('26').TYPE      := 'C';
               l_txmsg.txfields ('26').VALUE     := l_build_msg.fld26; --set vale for Calendar
               l_txmsg.txfields ('72').defname   := 'PUTTYPE';
               l_txmsg.txfields ('72').TYPE      := 'C';
               l_txmsg.txfields ('72').VALUE     := l_build_msg.fld72; --set vale for Puthought type
               l_txmsg.txfields ('27').defname   := 'PRICETYPE';
               l_txmsg.txfields ('27').TYPE      := 'C';
               l_txmsg.txfields ('27').VALUE     := l_build_msg.fld27; --set vale for Price type

               l_txmsg.txfields ('11').defname   := 'QUOTEPRICE';
               l_txmsg.txfields ('11').TYPE      := 'N';
               l_txmsg.txfields ('11').VALUE     := l_build_msg.fld11; --set vale for Limit price
               --TUANNH add fileds 90
               l_txmsg.txfields ('90').defname   := 'TRADESTATUS';
               l_txmsg.txfields ('90').TYPE      := 'N';
               l_txmsg.txfields ('90').VALUE     := 0;
               IF l_build_msg.fld22 IN ('NS', 'MS', 'SS') THEN --gc_OD_PLACENORMALSELLORDER_ADVANCED
                   --HaiLT them cho GRPORDER
                   l_txmsg.txfields ('55').defname   := 'GRPORDER';
                   l_txmsg.txfields ('55').TYPE      := 'C';
                   l_txmsg.txfields ('55').VALUE     := 'N';
               END IF;

               IF l_build_msg.fld27 <> 'LO'
               THEN                                               -- Pricetype
                  IF l_strEXECTYPE='NB' --l_build_msg.fld22 = 'NB'
                  THEN                                             -- exectype
                     l_txmsg.txfields ('11').VALUE   :=
                        l_build_msg.ceilingprice
                        / l_build_msg.fld98;                --tradeunit
                  ELSE
                     l_txmsg.txfields ('11').VALUE   :=
                        l_build_msg.floorprice
                        / l_build_msg.fld98;
                  END IF;
               END IF;

               plog.debug (pkgctx,
                           'Quoteprice: ' || l_txmsg.txfields ('11').VALUE
               );

               l_txmsg.txfields ('12').defname   := 'ORDERQTTY';
               l_txmsg.txfields ('12').TYPE      := 'N';
               l_txmsg.txfields ('12').VALUE     := l_build_msg.fld12; --set vale for Quantity
               l_txmsg.txfields ('13').defname   := 'BRATIO';
               l_txmsg.txfields ('13').TYPE      := 'N';
               --l_txmsg.txfields ('13').VALUE     := l_build_msg.fld13; --set vale for Block ration
          l_txmsg.txfields ('80').defname   := 'QUOTEQTTY';
               l_txmsg.txfields ('80').TYPE      := 'N';
               l_txmsg.txfields ('80').VALUE   := l_build_msg.fld80;
               l_txmsg.txfields ('14').defname   := 'LIMITPRICE';
               l_txmsg.txfields ('14').TYPE      := 'N';
               l_txmsg.txfields ('14').VALUE     := l_build_msg.fld14; --set vale for Stop price
               l_txmsg.txfields ('40').defname   := 'FEEAMT';
               l_txmsg.txfields ('40').TYPE      := 'N';
               --l_txmsg.txfields ('40').VALUE     := l_build_msg.fld40; --set vale for Fee amount
               l_txmsg.txfields ('28').defname   := 'VOUCHER';
               l_txmsg.txfields ('28').TYPE      := 'C';
               l_txmsg.txfields ('28').VALUE     := ''; --l_build_msg.fld28; --set vale for Voucher status
               l_txmsg.txfields ('29').defname   := 'CONSULTANT';
               l_txmsg.txfields ('29').TYPE      := 'C';
               l_txmsg.txfields ('29').VALUE     := ''; --l_build_msg.fld29; --set vale for Consultant status
               l_txmsg.txfields ('04').defname   := 'ORDERID';
               l_txmsg.txfields ('04').TYPE      := 'C';
               --l_txmsg.txfields ('04').VALUE     := l_build_msg.fld04; --set vale for Order ID
               --this is set below
               l_txmsg.txfields ('15').defname   := 'PARVALUE';
               l_txmsg.txfields ('15').TYPE      := 'N';
               l_txmsg.txfields ('15').VALUE     := l_build_msg.fld15; --set vale for Parvalue
               l_txmsg.txfields ('30').defname   := 'DESC';
               l_txmsg.txfields ('30').TYPE      := 'C';
               l_txmsg.txfields ('30').VALUE     := l_build_msg.fld30; --set vale for Description

               l_txmsg.txfields ('95').defname   := 'DFACCTNO';
               l_txmsg.txfields ('95').TYPE      := 'C';
               l_txmsg.txfields ('95').VALUE     := l_build_msg.fld95; --set vale for deal id

               l_txmsg.txfields ('94').defname   := 'SSAFACCTNO';
               l_txmsg.txfields ('94').TYPE      := 'C';
               l_txmsg.txfields ('94').VALUE     := l_build_msg.fld94; --set vale for short sale account

               --TuanNH add filed 90
               l_txmsg.txfields ('90').defname   := 'TRADESTATUS';
               l_txmsg.txfields ('90').TYPE      := 'N';
               l_txmsg.txfields ('90').VALUE     := 0;

               l_txmsg.txfields ('99').defname   := 'HUNDRED';
               l_txmsg.txfields ('99').TYPE      := 'N';
               If l_strMarginType = 'N' Then
                    l_txmsg.txfields ('99').VALUE     := l_build_msg.fld99;
               Else
                    --plog.debug(pkgctx, 'l_dblIsPPUsed' || l_dblIsPPUsed || 'l_dblMarginRatioRate:' || to_char(l_dblMarginRatioRate) || 'l_dblSecMarginPrice:' || to_char(l_dblSecMarginPrice));
                    If l_dblIsPPUsed = 1 Then
                        l_txmsg.txfields ('99').VALUE     := to_char(100 / (1 - l_dblMarginRatioRate / 100 * l_dblSecMarginPrice / l_build_msg.fld11 / l_build_msg.fld98));
                    Else
                        l_txmsg.txfields ('99').VALUE     := l_build_msg.fld99;
                    End If;
               End If;

               plog.debug(pkgctx, 'TRADEUNIT' || l_build_msg.fld98);
               l_txmsg.txfields ('98').defname   := 'TRADEUNIT';
               l_txmsg.txfields ('98').TYPE      := 'N';
               l_txmsg.txfields ('98').VALUE     := l_build_msg.fld98; --set vale for Trade unit

               l_txmsg.txfields ('96').defname   := 'TRADEUNIT';
               l_txmsg.txfields ('96').TYPE      := 'N';
               l_txmsg.txfields ('96').VALUE     := 1; --l_build_msg.fld96; --set vale for GTC

               l_txmsg.txfields ('97').defname   := 'MODE';
               l_txmsg.txfields ('97').TYPE      := 'C';
               l_txmsg.txfields ('97').VALUE     := l_build_msg.fld97; --set vale for MODE DAT LENH
               l_txmsg.txfields ('33').defname   := 'CLIENTID';
               l_txmsg.txfields ('33').TYPE      := 'C';
               l_txmsg.txfields ('33').VALUE     := l_build_msg.fld33; --set vale for ClientID
               l_txmsg.txfields ('73').defname   := 'CONTRAFIRM';
               l_txmsg.txfields ('73').TYPE      := 'C';
               l_txmsg.txfields ('73').VALUE     := l_build_msg.fld73; --set vale for Contrafirm
               l_txmsg.txfields ('32').defname   := 'TRADERID';
               l_txmsg.txfields ('32').TYPE      := 'C';
               l_txmsg.txfields ('32').VALUE     := l_build_msg.fld32; --set vale for TraderID
               l_txmsg.txfields ('71').defname   := 'CONTRACUS';
               l_txmsg.txfields ('71').TYPE      := 'C';
               l_txmsg.txfields ('71').VALUE     := ''; --l_build_msg.fld71; --set vale for Contra custody
               l_txmsg.txfields ('74').defname   := 'ISDISPOSAL';
               l_txmsg.txfields ('74').TYPE      := 'C';
               l_txmsg.txfields ('74').VALUE     := l_build_msg.ISDISPOSAL;
               l_txmsg.txfields ('31').defname   := 'CONTRAFIRM';
               l_txmsg.txfields ('31').TYPE      := 'C';
               l_txmsg.txfields ('31').VALUE     := l_build_msg.fld31; --set vale for Contrafirm
                --TuanNH add filed 90
               l_txmsg.txfields ('90').defname   := 'TRADESTATUS';
               l_txmsg.txfields ('90').TYPE      := 'N';
               l_txmsg.txfields ('90').VALUE     := 0;

               /*
               --</ TruongLD Add 05/10/2011
               -- ADVIDREF
               l_txmsg.txfields ('35').defname   := 'ADVIDREF';
               l_txmsg.txfields ('35').TYPE      := 'C';
               l_txmsg.txfields ('35').VALUE     := l_build_msg.fld35; --set vale for CONTRAFIRM
               --End TruongLD/>
               */


               l_remainqtty                      :=
                  l_txmsg.txfields ('12').VALUE;

               l_txmsg.txfields ('08').VALUE     :=
                  l_build_msg.orgacctno;
               plog.debug (pkgctx,
                           'cancel orderid: '
                           || l_txmsg.txfields ('08').VALUE
               );

               l_order_count                     := 0;         --RESET COUNTER

               plog.debug (pkgctx, 'l_remainqtty: ' || l_remainqtty);
               if l_build_msg.SPLOPT='Q' then --Tach theo so lenh
                        l_breakingsize:= l_build_msg.SPLVAL;
               elsif l_build_msg.SPLOPT='O' then
                        l_breakingsize:= round(l_remainqtty/to_number(l_build_msg.SPLVAL) +
                                                case when l_build_msg.tradeplace='001' then 5-0.01
                                                     when l_build_msg.tradeplace='002' then 50-0.01
                                                     else 0.5-0.01 end,
                                                case when l_build_msg.tradeplace='001' then -1
                                                     when l_build_msg.tradeplace='002' then -2
                                                     else 0 end);
               else
                        l_breakingsize:= l_remainqtty;
               end if;
               /*IF l_build_msg.tradeplace = '001' then
                    --Neu san HN thi xe toi da theo l_hosebreakingsize
                    if l_breakingsize > l_hosebreakingsize then
                        l_breakingsize:=l_hosebreakingsize;
                    else
                        l_breakingsize:=l_breakingsize;
                    end if;
               end if;*/
               IF l_build_msg.tradeplace = '001' then
                    --Neu san HSX thi xe toi da theo l_hosebreakingsize
                    if l_breakingsize > l_hosebreakingsize then
                        l_breakingsize:=l_hosebreakingsize;
                    else
                        l_breakingsize:=l_breakingsize;
                    end if;
               ELSIF l_build_msg.tradeplace in( '002','005') then
                    --Neu san HNX thi xe toi da theo l_hasebreakingsize
                    if l_breakingsize > l_hasebreakingsize then
                        l_breakingsize:=l_hasebreakingsize;
                    else
                        l_breakingsize:=l_breakingsize;
                    end if;
               end if;
               WHILE l_remainqtty > 0                               --quantity
               LOOP
                  SAVEPOINT sp#2;
                  l_order_count   := l_order_count + 1;

                  /*IF l_build_msg.tradeplace = '001'
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
                  END IF;*/
                  l_txmsg.txfields ('12').VALUE   :=
                        CASE
                           WHEN l_remainqtty > l_breakingsize
                           THEN
                              l_breakingsize
                           ELSE
                              l_remainqtty
                        END;

                  -- SET FEE AMOUNT
                  l_txmsg.txfields ('40').VALUE     :=
                    greatest(l_feerate/100 * TO_NUMBER (l_txmsg.txfields('12').VALUE)         --quantity
                     * TO_NUMBER (l_build_msg.fld11)       --quoteprice
                     * TO_NUMBER (l_build_msg.fld98),l_feeamountmin);

                  --2.1 Set txnum
                  SELECT systemnums.c_fo_prefixed
                         || LPAD (seq_fotxnum.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;

                  --v_strOrderID = FO_PREFIXED & "00" & Mid(Replace(v_strTXDATE, "/", vbNullString), 1, 4) & Mid(Replace(v_strTXDATE, "/", vbNullString), 7, 2) & Strings.Right(gc_FORMAT_ODAUTOID & CStr(v_DataAccess.GetIDValue("ODMAST")), Len(gc_FORMAT_ODAUTOID))
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
                                                         p_err_code,
                                                         l_err_param
                           ) <> systemnums.c_success
                        THEN
                           plog.debug (pkgctx,
                                       'got error 8876: ' || p_err_code
                           );
                           --ONLY ROLLBACK FOR THIS MESSAGE
                           ROLLBACK TO SAVEPOINT sp#2;
                           --EXIT; -- UNCOMMENT THIS IF YOU WANT TO EXIT LOOP WHEN GOT AN ERROR
                           RAISE errnums.e_biz_rule_invalid;
                        END IF;
                     END;                                               --8876
                  ELSIF l_build_msg.fld22 IN ('NS', 'MS', 'SS')  --8877
                  THEN
                     BEGIN
                        l_txmsg.tltxcd   := '8877'; --gc_OD_PLACENORMALSELLORDER_ADVANCED

                        -- 2: Process
                        IF txpks_#8877.fn_autotxprocess (l_txmsg,
                                                         p_err_code,
                                                         l_err_param
                           ) <> systemnums.c_success
                        THEN
                           plog.debug (pkgctx,
                                          '8877: '
                                       || p_err_code
                                       || ':'
                                       || l_err_param
                           );
                           --ONLY ROLLBACK FOR THIS MESSAGE
                           ROLLBACK TO SAVEPOINT sp#2;
                           --EXIT; -- UNCOMMENT THIS IF YOU WANT TO EXIT LOOP WHEN GOT AN ERROR
                           RAISE errnums.e_biz_rule_invalid;
                        END IF;
                     END;                                              -- 8887
                  ELSIF l_build_msg.fld22 = 'AB'                 --8884
                  THEN
                     BEGIN
                        l_txmsg.tltxcd   := '8884';  --gc_OD_AMENDMENTBUYORDER

                        -- 2: Process
                        IF txpks_#8884.fn_autotxprocess (l_txmsg,
                                                         p_err_code,
                                                         l_err_param
                           ) <> systemnums.c_success
                        THEN
                           plog.debug (pkgctx,
                                       'got error 8884: ' || p_err_code
                           );
                           --ONLY ROLLBACK FOR THIS MESSAGE
                           ROLLBACK TO SAVEPOINT sp#2;
                           --EXIT; -- UNCOMMENT THIS IF YOU WANT TO EXIT LOOP WHEN GOT AN ERROR
                           RAISE errnums.e_biz_rule_invalid;
                        END IF;
                     END;                                               --8884
                  ELSIF l_build_msg.fld22 = 'AS'                 --8885
                  THEN
                     BEGIN
                        l_txmsg.tltxcd   := '8885'; --gc_OD_AMENDMENTSELLORDER

                        -- 2: Process
                        IF txpks_#8885.fn_autotxprocess (l_txmsg,
                                                         p_err_code,
                                                         l_err_param
                           ) <> systemnums.c_success
                        THEN
                           plog.debug (pkgctx,
                                       'got error 8885: ' || p_err_code
                           );
                           --ONLY ROLLBACK FOR THIS MESSAGE
                           ROLLBACK TO SAVEPOINT sp#2;
                           --EXIT; -- UNCOMMENT THIS IF YOU WANT TO EXIT LOOP WHEN GOT AN ERROR
                           RAISE errnums.e_biz_rule_invalid;
                        END IF;
                     END;                                               --8885
                  ELSIF l_build_msg.fld22 = 'CB'                 --8882
                  THEN
                     BEGIN
                        l_txmsg.tltxcd   := '8882';     --gc_OD_CANCELBUYORDER

                        -- 2: Process
                        IF txpks_#8882.fn_autotxprocess (l_txmsg,
                                                         p_err_code,
                                                         l_err_param
                           ) <> systemnums.c_success
                        THEN
                           plog.debug (pkgctx,
                                       'got error 8882: ' || p_err_code
                           );
                           --ONLY ROLLBACK FOR THIS MESSAGE
                           ROLLBACK TO SAVEPOINT sp#2;
                           --EXIT; -- UNCOMMENT THIS IF YOU WANT TO EXIT LOOP WHEN GOT AN ERROR
                           RAISE errnums.e_biz_rule_invalid;
                        END IF;
                     END;                                               --8882
                  ELSIF l_build_msg.fld22 = 'CS'                 --8883
                  THEN
                     BEGIN
                        l_txmsg.tltxcd   := '8883';    --gc_OD_CANCELSELLORDER

                        -- 2: Process
                        IF txpks_#8883.fn_autotxprocess (l_txmsg,
                                                         p_err_code,
                                                         l_err_param
                           ) <> systemnums.c_success
                        THEN
                           plog.debug (pkgctx,
                                       'got error 8883: ' || p_err_code
                           );
                           --ONLY ROLLBACK FOR THIS MESSAGE
                           ROLLBACK TO SAVEPOINT sp#2;
                           --EXIT; -- UNCOMMENT THIS IF YOU WANT TO EXIT LOOP WHEN GOT AN ERROR
                           RAISE errnums.e_biz_rule_invalid;
                        END IF;
                     END;
                  END IF;

                  UPDATE fomast
                  SET orgacctno    = l_txmsg.txfields ('04').VALUE,
                      status       = 'A',
                      feedbackmsg   =
                         'Order is active and sucessfull processed: '
                         || l_txmsg.txfields ('04').VALUE
                  WHERE acctno = l_build_msg.acctno;

                  INSERT INTO rootordermap
                 (
                     foacctno,
                     orderid,
                     status,
                     MESSAGE,
                     id
                 )
                  VALUES (
                            l_build_msg.acctno,
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
                    plog.error (pkgctx,
                                 'row:'
                              || dbms_utility.format_error_backtrace
                  );
                  p_err_code:=errnums.c_od_odtype_notfound;
                  UPDATE fomast
                  SET status    = 'R',
                             feedbackmsg   =
                                '[' || errnums.c_od_odtype_notfound || '] '
                                || cspks_system.fn_get_errmsg(errnums.c_od_odtype_notfound)
                  WHERE acctno = l_build_msg.acctno;
               WHEN errnums.e_invalid_session
               THEN
                  -- Log error and continue to process the next order
                  plog.error (pkgctx,
                                 'INVALID SESSION(pricetype,mktstatus):'
                              || l_build_msg.fld27
                              || ','
                              || l_mktstatus
                  );
                  p_err_code:=errnums.c_invalid_session;
                  UPDATE fomast
                  SET status    = 'R',
                      feedbackmsg   =
                         '[' || errnums.c_invalid_session || '] '
                         || cspks_system.fn_get_errmsg(errnums.c_invalid_session)
                  WHERE acctno = l_build_msg.acctno;
               --LogOrderMessage(v_ds.Tables(0).Rows(i)("ACCTNO"))
               WHEN errnums.e_biz_rule_invalid
               THEN
                -- KIEM TRA NEU TH CHIA LENH MA DA CO LENH CHIA THANH CONG THI KO CAP NHAT LENH TRONG FOMAST
                  IF NOT (l_remainqtty < l_build_msg.fld12) THEN
                      UPDATE fomast
                      SET status        = 'R',
                          feedbackmsg   = '[' || p_err_code || '] ' || l_err_param
                      WHERE acctno = l_build_msg.acctno;

                      INSERT INTO rootordermap
                     (
                         foacctno,
                         orderid,
                         status,
                         MESSAGE,
                         id
                     )
                      VALUES (
                                l_build_msg.acctno,
                                '',
                                'R',
                                '[' || p_err_code || '] ' || l_err_param,
                                l_order_count
                             );
                     END IF;
                when others
                then
                  p_err_code:=errnums.C_SYSTEM_ERROR;
                  plog.error (pkgctx,'Error when send syn order!');
                  plog.error (pkgctx,sqlerrm);
            END;
      END LOOP;
      COMMIT;                                -- Commit the last trunk (if any)
      /***************************************************************************************************
      ** END;
      ***************************************************************************************************/
      plog.debug (pkgctx, '<<END OF pr_fo2odbyorder');
      plog.setendsection (pkgctx, 'pr_fo2odbyorder');
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         plog.error (pkgctx, SQLERRM);

         CLOSE curs_build_msg;

         plog.setendsection (pkgctx, 'pr_fo2odbyorder');
   END pr_fo2odbyorder;

  PROCEDURE pr_fobanksyn
  IS
    p_error_code varchar2(300);
  BEGIN
    plog.setbeginsection (pkgctx, 'pr_fobanksyn');
    --Xu ly lenh
    FOR i IN
    (
        SELECT FO.ACCTNO FOORDERID
        FROM FOMAST FO,SYSVAR SYS, SECURITIES_INFO INF
        WHERE FO.STATUS='W' AND SYS.VARNAME='CURRDATE'
            AND TRUNC(FO.EXPDATE)>=TO_DATE(SYS.VARVALUE,'DD/MM/RRRR')
            AND FO.EFFDATE <= TO_DATE(SYS.VARVALUE,'DD/MM/RRRR')
            AND FO.CODEID = INF.CODEID
            AND CASE WHEN FO.TIMETYPE = 'G' AND FO.PRICETYPE = 'LO'
                          THEN FO.QUOTEPRICE*INF.TRADEUNIT ELSE INF.CEILINGPRICE END <= INF.CEILINGPRICE
            AND CASE WHEN FO.TIMETYPE = 'G' AND FO.PRICETYPE = 'LO'
                          THEN FO.QUOTEPRICE*INF.TRADEUNIT ELSE INF.FLOORPRICE END >= INF.FLOORPRICE
            AND NOT EXISTS (
                SELECT * FROM CRBTXREQ REQ WHERE REQ.TRFCODE='HOLD'
                AND REQ.REFCODE = FO.ACCTNO AND REQ.OBJTYPE='V'
                AND REQ.OBJNAME='FOMAST'
        )
        ORDER BY FO.ACCTNO ASC
    )
    LOOP
        fopks_api.pr_fo_fobannk2od(i.FOORDERID);
    END LOOP;
    --Xu ly day 3384
    FOR i IN
    (
        SELECT REQ.AUTOID
        FROM BORQSLOG REQ,SYSVAR SYS
        WHERE REQ.STATUS='W' AND SYS.VARNAME='CURRDATE'
        AND REQ.TXDATE=TO_DATE(SYS.VARVALUE,'DD/MM/RRRR')
        AND NOT EXISTS (
            SELECT * FROM CRBTXREQ RQ WHERE RQ.TRFCODE='HOLD'
            AND RQ.REFCODE = TO_CHAR(REQ.AUTOID)
            AND RQ.OBJTYPE='V' AND RQ.OBJNAME='CAR'
        )
    )
    LOOP
        cspks_rmproc.pr_createholdrqsfor3384(i.AUTOID,p_error_code);
    END LOOP;

    plog.setendsection (pkgctx, 'pr_fobanksyn');
  EXCEPTION
   WHEN OTHERS
   THEN
      ROLLBACK;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'pr_fobanksyn');
  END pr_fobanksyn;

  PROCEDURE pr_CreateDeal(p_afacctno varchar2,p_codeid varchar2,p_refpricetype varchar2,p_dftype varchar2,p_qtty number, p_refprice number, p_refnum varchar2,p_err_code  OUT varchar2,p_txdate  OUT varchar2,p_txnum  OUT varchar2)
  IS
      l_txmsg               tx.msg_rectype;
      v_strCURRDATE varchar2(20);
      l_err_param varchar2(300);
      v_TradeQtty number;
      v_seacctno    varchar2(30);
      mv_strDFTYPE  char(1);
      v_PendingQtty number;
      v_RLSAMT  number;
      v_BlockQtty number;
      v_PendingCAQtty number;
      v_strDEALACCOUNT  varchar2(50);
      v_fullname varchar2(500);
      v_address varchar2(500);
      v_license varchar2(500);
      v_custodycd varchar2(20);
      l_count number;
  BEGIN
    plog.setbeginsection(pkgctx, 'pr_CreateDeal');
    plog.debug(pkgctx, 'Begin pr_CreateDeal');
    v_BlockQtty:=0;
    v_PendingQtty:=0;
    v_TradeQtty:=0;
    v_RLSAMT:=0;
    v_PendingCAQtty:=0;
    SELECT TO_date (varvalue, systemnums.c_date_format)
               INTO v_strCURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    l_txmsg.msgtype:='T';
    l_txmsg.local:='N';
    l_txmsg.tlid        := systemnums.c_system_userid;
    SELECT SYS_CONTEXT ('USERENV', 'HOST'),
             SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
      INTO l_txmsg.wsname, l_txmsg.ipaddress
    FROM DUAL;
    plog.debug(pkgctx, 'check1');
    l_txmsg.off_line    := 'N';
    l_txmsg.deltd       := txnums.c_deltd_txnormal;
    l_txmsg.txstatus    := txstatusnums.c_txcompleted;
    l_txmsg.msgsts      := '0';
    l_txmsg.ovrsts      := '0';
    l_txmsg.batchname   := 'INT';
    l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.busdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    plog.debug(pkgctx, 'check2');
    l_txmsg.tltxcd:='2670';
    --Set txnum
    SELECT systemnums.C_BATCH_PREFIXED
                     || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
              INTO l_txmsg.txnum
              FROM DUAL;
    l_txmsg.brid        := substr(p_afacctno,1,4);

    p_txnum:=l_txmsg.txnum;
    p_txdate:=l_txmsg.txdate;

    plog.debug(pkgctx, 'check3');
    ---------------------------------------------------------
    begin
        plog.debug(pkgctx, 'check4:p_dftype' || p_dftype);
        select dftype into mv_strDFTYPE from dftype where actype =p_dftype;
    exception when others then
        p_err_code:=-260001; --Loai hinh deal khong ton tai
        plog.setendsection(pkgctx, 'pr_CreateDeal');
        return;
    end;
    plog.debug(pkgctx, 'p_refnum:' || nvl(p_refnum,'XXXXXXXX'));
    if nvl(p_refnum,'XXXXXXXX') ='XXXXXXXX' or length (p_refnum)<=0 THEN
        begin
            plog.debug(pkgctx, 'check4:p_codeid' || p_codeid);
            plog.debug(pkgctx, 'check4:p_afacctno' || p_afacctno);
            SELECT TRADE, ACCTNO into v_TradeQtty,v_seacctno FROM SEMAST WHERE AFACCTNO = p_afacctno AND CODEID = p_codeid;
        exception when others then
            p_err_code:=-900004; --Tai khoan chung khoan khong ton tai
            return;
        end;
        v_TradeQtty:= least(p_qtty,v_TradeQtty);
        plog.debug(pkgctx, 'v_TradeQtty:' || v_TradeQtty);
        plog.debug(pkgctx, 'p_codeid:' || p_codeid);
        plog.debug(pkgctx, 'p_afacctno:' || p_afacctno);
    else
        if mv_strDFTYPE in ('F','L') then
            begin
                SELECT distinct NVL((QTTY-AQTTY),'0') PENDINGTRADE,
                     CASE WHEN MRT.MRTYPE IN ('L','N') THEN
                     LEAST(
                     greatest((1-b.BRATIO/100) * (a.QTTY-a.AQTTY)/a.QTTY * a.AMT,0),
                     GREATEST(AF.MRCRLIMITMAX-CI.DFODAMT-CI.ODAMT,0) )
                     ELSE
                     (A.QTTY-A.AQTTY) *  nvl(rsk.mrratioloan,0)/100 * least(NVL(RSK.MARGINPRICE,0),nvl(rsk.mrpriceloan,0))
                     END RLSAMT
                into v_PendingQtty,v_RLSAMT
                FROM vw_stschd_dealgroup a, (SELECT afacctno, codeid, bratio FROM odmast ) b, AFMAST AF,CIMAST CI, AFTYPE AFT, MRTYPE MRT,
                     (SELECT RSK.ACTYPE,RSK.MRRATIOLOAN,RSK.MRPRICELOAN ,SB.MARGINPRICE FROM AFSERISK RSK,SECURITIES_INFO SB
                     WHERE RSK.CODEID= SB.CODEID AND RSK.CODEID=(SELECT CODEID FROM vw_stschd_dealgroup WHERE AUTOID =p_refnum)) RSK
                WHERE a.afacctno=b.afacctno AND a.codeid = b.codeid AND a.DUETYPE = 'RS'
                     AND B.AFACCTNO = AF.ACCTNO  AND AF.ACCTNO = CI.ACCTNO AND AF.ACTYPE = AFT.ACTYPE AND AFT.MRTYPE = MRT.ACTYPE
                     AND AFT.ACTYPE = RSK.ACTYPE (+) AND a.AUTOID = p_refnum;
            exception when others then
                v_PendingQtty:=0;
                v_RLSAMT:=0;
            end;
            v_PendingQtty:= least(p_qtty,v_PendingQtty);

        end if;
        plog.debug(pkgctx, 'v_PendingQtty:' || v_PendingQtty);
        plog.debug(pkgctx, 'check4:mv_strDFTYPE' || mv_strDFTYPE);
        if mv_strDFTYPE in ('B') then
            /*If InStr(p_refnum,'/') > 0 Then
                begin
                    SELECT  NVL((QTTY-DFQTTY),'0') BLOCKQTTY
                    into v_BlockQtty
                    FROM SEMASTDTL
                    WHERE DELTD<>'Y' AND txnum || to_char(txdate,'DD/MM/YYYY') = p_refnum;
                exception when others then
                    v_BlockQtty:=0;
                end;
            else*/
                begin
                    SELECT  NVL((QTTY-DFQTTY),'0') PENDINGCA
                    into v_PendingCAQtty
                    FROM CASCHD
                    WHERE DELTD<>'Y' AND STATUS in ('S','M') AND AUTOID = p_refnum;
                exception when others then
                    v_PendingCAQtty:=0;
                end;
            --end if;
            v_BlockQtty:= least(p_qtty,v_BlockQtty);
            v_PendingCAQtty:= least(p_qtty,v_PendingCAQtty);
        end if;
        plog.debug(pkgctx, 'v_BlockQtty:' || v_BlockQtty);
        plog.debug(pkgctx, 'v_PendingCAQtty:' || v_PendingCAQtty);
    end if;
    v_strDEALACCOUNT:= '0001' || substr(to_char(l_txmsg.txdate,'DD/MM/YYYY'),1,2) || substr(to_char(l_txmsg.txdate,'DD/MM/YYYY'),4,2) || substr(to_char(l_txmsg.txdate,'DD/MM/YYYY'),9,2) || lpad(seq_dfmast.nextval,6,'0');
    plog.debug(pkgctx, 'check4:v_strDEALACCOUNT' || v_strDEALACCOUNT);
    select cf.fullname, cf.address, cf.idcode ,cf.custodycd
    into v_fullname, v_address, v_license, v_custodycd
    from cfmast cf, afmast af
    where cf.custid = af.custid and af.acctno = p_afacctno;
    plog.debug(pkgctx, 'check4:v_fullname' || v_fullname);
    l_count:=0;
    for rec in
    (
        SELECT a.BASKETID,a.SYMBOL,
                 (case when a.REFPRICE<=0 then inf.BASICPRICE else a.REFPRICE end) REFPRICE,
                 (case when a.DFPRICE <=0 then round((case when a.REFPRICE<=0 then inf.BASICPRICE else a.REFPRICE end)* a.dfrate/100,0) else a.DFPRICE end) DFPRICE ,
                 (case when a.TRIGGERPRICE<=0 then round((case when a.REFPRICE<=0 then inf.BASICPRICE else a.REFPRICE end)* a.lrate/100,0) else a.TRIGGERPRICE end) TRIGGERPRICE ,
                 a.DFRATE,
                 a.IRATE,
                 a.MRATE,
                 a.LRATE,
                 a.CALLTYPE,
                 b.RRTYPE, b.OPTPRICE, b.LIMITCHK, b.CUSTBANK,b.CIACCTNO,
                 a.IMPORTDT, B.TYPENAME, B.DFTYPE,B.AUTODRAWNDOWN,CD.CDCONTENT DFNAME,CD3.CDCONTENT CALLTYPENAME, CD2.CDCONTENT RRNAME
                 FROM DFBASKET A, DFTYPE B, securities_info inf ,ALLCODE CD,ALLCODE CD2, ALLCODE CD3
                 WHERE A.BASKETID = B.BASKETID AND B.ACTYPE = p_dftype AND B.STATUS <>'N' AND inf.codeid = p_codeid
                AND CD.CDTYPE ='DF' AND CD.CDNAME ='DFTYPE' AND CD.CDVAL =B.DFTYPE
                AND CD3.CDTYPE ='DF' AND CD3.CDNAME ='CALLTYPE' AND CD3.CDVAL =a.CALLTYPE
                AND CD2.CDTYPE ='DF' AND CD2.CDNAME ='RRTYPE' AND CD2.CDVAL =B.RRTYPE
                 and a.symbol = inf.symbol
    )
    loop
        plog.debug(pkgctx, 'check4:Begin set field');
        l_count:=l_count+1;
        --Set cac field giao dich
        --01    CODEID          C       Internal securities code
        l_txmsg.txfields ('01').defname   := 'CODEID';
        l_txmsg.txfields ('01').TYPE      := 'C';
        l_txmsg.txfields ('01').VALUE     := p_codeid;
        --02    ACCTNO          C       Deal ID
        l_txmsg.txfields ('02').defname   := 'ACCTNO';
        l_txmsg.txfields ('02').TYPE      := 'C';
        l_txmsg.txfields ('02').VALUE     := v_strDEALACCOUNT;
        --03    AFACCTNO        C       Contract number
        l_txmsg.txfields ('03').defname   := 'AFACCTNO';
        l_txmsg.txfields ('03').TYPE      := 'C';
        l_txmsg.txfields ('03').VALUE     := p_afacctno;
        --04    ACTYPE          C       DF type
        l_txmsg.txfields ('04').defname   := 'ACTYPE';
        l_txmsg.txfields ('04').TYPE      := 'C';
        l_txmsg.txfields ('04').VALUE     := p_dftype;
        --05    SEACCTNO        C       SE account
        l_txmsg.txfields ('05').defname   := 'SEACCTNO';
        l_txmsg.txfields ('05').TYPE      := 'C';
        l_txmsg.txfields ('05').VALUE     := p_afacctno || p_codeid;
        --06    PRICE           N       Ref price
        l_txmsg.txfields ('06').defname   := 'PRICE';
        l_txmsg.txfields ('06').TYPE      := 'N';
        l_txmsg.txfields ('06').VALUE     := rec.REFPRICE;
        --07    DFRATE          N       Deal rate
        l_txmsg.txfields ('07').defname   := 'DFRATE';
        l_txmsg.txfields ('07').TYPE      := 'N';
        l_txmsg.txfields ('07').VALUE     := rec.DFRATE;
        --08    MRATE           N       Maintanance rate
        l_txmsg.txfields ('08').defname   := 'MRATE';
        l_txmsg.txfields ('08').TYPE      := 'N';
        l_txmsg.txfields ('08').VALUE     := rec.MRATE;
        --09    LRATE           N       Liquidity rate
        l_txmsg.txfields ('09').defname   := 'LRATE';
        l_txmsg.txfields ('09').TYPE      := 'N';
        l_txmsg.txfields ('09').VALUE     := rec.LRATE;
        --10    DFPRICE         N       Deal price
        l_txmsg.txfields ('10').defname   := 'DFPRICE';
        l_txmsg.txfields ('10').TYPE      := 'N';
        l_txmsg.txfields ('10').VALUE     := p_refprice*rec.DFRATE/100;
        --11    TRIGGERPRICE    N       Trigger price
        l_txmsg.txfields ('11').defname   := 'TRIGGERPRICE';
        l_txmsg.txfields ('11').TYPE      := 'N';
        l_txmsg.txfields ('11').VALUE     := rec.TRIGGERPRICE;
        --12    AVLQTTY         N       Trading quantity
        l_txmsg.txfields ('12').defname   := 'AVLQTTY';
        l_txmsg.txfields ('12').TYPE      := 'N';
        l_txmsg.txfields ('12').VALUE     := v_TradeQtty;
        --13    RCVQTTY         N       Receiving quantity
        l_txmsg.txfields ('13').defname   := 'RCVQTTY';
        l_txmsg.txfields ('13').TYPE      := 'N';
        l_txmsg.txfields ('13').VALUE     := v_PendingQtty;
        --14    IRATE           N       Initial rate
        l_txmsg.txfields ('14').defname   := 'IRATE';
        l_txmsg.txfields ('14').TYPE      := 'N';
        l_txmsg.txfields ('14').VALUE     := rec.IRATE;
        --15    CALLTYPE        C       Trigger type
        l_txmsg.txfields ('15').defname   := 'CALLTYPE';
        l_txmsg.txfields ('15').TYPE      := 'C';
        l_txmsg.txfields ('15').VALUE     := rec.CALLTYPE;
        --16    AUTODRAWNDOWN   C       Auto drawndown
        l_txmsg.txfields ('16').defname   := 'AUTODRAWNDOWN';
        l_txmsg.txfields ('16').TYPE      := 'C';
        l_txmsg.txfields ('16').VALUE     := case when mv_strDFTYPE='M' then 0 else rec.AUTODRAWNDOWN end;
        --18    RLSAMT          N       Release to settlement
        l_txmsg.txfields ('18').defname   := 'RLSAMT';
        l_txmsg.txfields ('18').TYPE      := 'N';
        l_txmsg.txfields ('18').VALUE     := v_RLSAMT;
        --22    BLOCKQTTY       N       Block quantity
        l_txmsg.txfields ('22').defname   := 'BLOCKQTTY';
        l_txmsg.txfields ('22').TYPE      := 'N';
        l_txmsg.txfields ('22').VALUE     := v_BlockQtty;
        --23    CARCVQTTY       N       Ca receiving quantity
        l_txmsg.txfields ('23').defname   := 'CARCVQTTY';
        l_txmsg.txfields ('23').TYPE      := 'N';
        l_txmsg.txfields ('23').VALUE     := v_PendingCAQtty;
        --25    REFPRICETYPE    C       Ref price type
        l_txmsg.txfields ('25').defname   := 'REFPRICETYPE';
        l_txmsg.txfields ('25').TYPE      := 'C';
        l_txmsg.txfields ('25').VALUE     := p_refpricetype;
        --29    REF             C       Reference
        l_txmsg.txfields ('29').defname   := 'REF';
        l_txmsg.txfields ('29').TYPE      := 'C';
        l_txmsg.txfields ('29').VALUE     := p_refnum;
        --30    DESC            C       Description
        l_txmsg.txfields ('30').defname   := 'DESC';
        l_txmsg.txfields ('30').TYPE      := 'C';
        l_txmsg.txfields ('30').VALUE     := 'Tao deal online';
        --40    QTTY            N       Quantity
        l_txmsg.txfields ('40').defname   := 'QTTY';
        l_txmsg.txfields ('40').TYPE      := 'N';
        l_txmsg.txfields ('40').VALUE     := v_PendingCAQtty + v_TradeQtty+ v_PendingQtty+ v_BlockQtty;
        --41    AMT             N       Amount
        l_txmsg.txfields ('41').defname   := 'AMT';
        l_txmsg.txfields ('41').TYPE      := 'N';
        l_txmsg.txfields ('41').VALUE     := ROUND((v_PendingCAQtty + v_TradeQtty+ v_PendingQtty+ v_BlockQtty) * p_refprice * rec.DFRATE/100);
        --50    RRID            C       Drawndown ID
        l_txmsg.txfields ('50').defname   := 'RRID';
        l_txmsg.txfields ('50').TYPE      := 'C';
        l_txmsg.txfields ('50').VALUE     := case when rec.RRTYPE='O' then rec.CIACCTNO when rec.RRTYPE='B' then rec.CUSTBANK else '' end ;
        --51    CIDRAWNDOWN     C       Cash drawndown
        l_txmsg.txfields ('51').defname   := 'CIDRAWNDOWN';
        l_txmsg.txfields ('51').TYPE      := 'C';
        l_txmsg.txfields ('51').VALUE     := case when rec.RRTYPE='O' then '1' else '0' end;
        --52    BANKDRAWNDOWN   C       Bank drawndown
        l_txmsg.txfields ('52').defname   := 'BANKDRAWNDOWN';
        l_txmsg.txfields ('52').TYPE      := 'C';
        l_txmsg.txfields ('52').VALUE     := case when rec.RRTYPE='B' then '1' else '0' end;
        --53    CMPDRAWNDOWN    C       Company drawndown
        l_txmsg.txfields ('53').defname   := 'CMPDRAWNDOWN';
        l_txmsg.txfields ('53').TYPE      := 'C';
        l_txmsg.txfields ('53').VALUE     := case when rec.RRTYPE <> 'B' and rec.RRTYPE <> 'O'  then '1' else '0' end;
        --57    CUSTNAME        C       Fullname
        l_txmsg.txfields ('57').defname   := 'CUSTNAME';
        l_txmsg.txfields ('57').TYPE      := 'C';
        l_txmsg.txfields ('57').VALUE     := v_fullname;
        --58    ADDRESS         C       Address
        l_txmsg.txfields ('58').defname   := 'ADDRESS';
        l_txmsg.txfields ('58').TYPE      := 'C';
        l_txmsg.txfields ('58').VALUE     := v_address;
        --59    LICENSE         C       License
        l_txmsg.txfields ('59').defname   := 'LICENSE';
        l_txmsg.txfields ('59').TYPE      := 'C';
        l_txmsg.txfields ('59').VALUE     := v_license;
        --86    CONTRACTCHK     C       Contract sign
        l_txmsg.txfields ('86').defname   := 'CONTRACTCHK';
        l_txmsg.txfields ('86').TYPE      := 'C';
        l_txmsg.txfields ('86').VALUE     := 'Y';
        --88    CUSTODYCD       C       Custody code
        l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
        l_txmsg.txfields ('88').TYPE      := 'C';
        l_txmsg.txfields ('88').VALUE     := v_custodycd;
        --99    LIMITCHECK      C       Limit check
        l_txmsg.txfields ('99').defname   := 'LIMITCHECK';
        l_txmsg.txfields ('99').TYPE      := 'C';
        l_txmsg.txfields ('99').VALUE     := case when rec.LIMITCHK='N' then 0 else 1 end;
        plog.debug(pkgctx, 'check4:End set field');
        BEGIN
            IF txpks_#2670.fn_autotxprocess (l_txmsg,
                                             p_err_code,
                                             l_err_param
               ) <> systemnums.c_success
            THEN
               plog.debug (pkgctx,
                           'got error 2670: ' || p_err_code
               );
               ROLLBACK;
               plog.setendsection (pkgctx, 'pr_CreateDeal');
               RETURN;
            END IF;
        END;

    end loop;
    if l_count=0 then
        p_err_code:='-400115'; --Loai hinh khong hop le hoac chung khoan khong co trong ro tao deal
        return;
        plog.setendsection(pkgctx, 'pr_CreateDeal');
    end if;
    p_err_code:=0;
    plog.setendsection(pkgctx, 'pr_CreateDeal');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on pr_CreateDeal');
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_CreateDeal');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_CreateDeal;
  ---------------------------------pr_DealPayment------------------------------------------------
  --p_account: so hieu deal can thanh ly (DFMAST.ACCTNO)
  --p_prinAmount: So tien tra goc --> so lai va chung khoan giai toa tuong ung theo ty le
  PROCEDURE pr_DealPayment(p_account varchar2,p_prinAmount  varchar2,p_err_code  OUT varchar2,p_txdate  OUT varchar2,p_txnum  OUT varchar2)
  IS
      l_txmsg               tx.msg_rectype;
      v_dtCURRDATE date;
      l_err_param varchar2(300);

  BEGIN
    plog.setbeginsection(pkgctx, 'pr_DealPayment');
    plog.debug(pkgctx, 'begin pr_DealPayment');
    SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO v_dtCURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    l_txmsg.msgtype:='T';
    l_txmsg.local:='N';
    l_txmsg.tlid        := systemnums.c_system_userid;
    SELECT SYS_CONTEXT ('USERENV', 'HOST'),
             SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
      INTO l_txmsg.wsname, l_txmsg.ipaddress
    FROM DUAL;
    l_txmsg.off_line    := 'N';
    l_txmsg.deltd       := txnums.c_deltd_txnormal;
    l_txmsg.txstatus    := txstatusnums.c_txcompleted;
    l_txmsg.msgsts      := '0';
    l_txmsg.ovrsts      := '0';
    l_txmsg.batchname   := 'INT';
    l_txmsg.txdate:=v_dtCURRDATE;
    l_txmsg.busdate:=v_dtCURRDATE;
    l_txmsg.tltxcd:='2642';
    plog.debug(pkgctx, 'gianh1');
    for rec in (
        select v.*,cd.cdcontent DEALTYPE_DESC,
            v.PRINNML+v.INTNMLACR+v.INTDUE+v.OPRINNML+v.OINTNMLACR+v.OINTDUE+v.FEE+v.FEEDUE -nvl(sts.NML,0) INDUEAMT,
            nvl(sts.NML,0) DUEAMT, v.PRINOVD+v.INTOVDACR+v.INTNMLOVD+v.OPRINOVD+v.OINTOVDACR+v.OINTNMLOVD+v.FEEOVD OVERDUEAMT,
            mst.EXPDATE, (CASE WHEN TYP.NINTCD='000' THEN 1 ELSE 0 END) FLAGINTACR, -- N?U L? 000 L? C?CH T?H NHU CU
            0 INTDAY,
            0 INTOVDDAY,
            v.INTNMLACR+ v.OINTNMLACR + v.OINTOVDACR + v.INTOVDACR INTACR, greatest(v.INTAMTACR+v.feeamt,v.FEEMIN-v.RLSFEEAMT) DEALFEEAMT
            from v_getDealInfo v, allcode cd, securities_info sb,
             (SELECT S.ACCTNO, SUM(NML) NML, M.TRFACCTNO FROM LNSCHD S, LNMAST M
                    WHERE S.OVERDUEDATE = TO_DATE((select varvalue from sysvar where grname ='SYSTEM' and varname ='CURRDATE'),'DD/MM/RRRR') AND S.NML > 0 AND S.REFTYPE IN ('P')
                        AND S.ACCTNO = M.ACCTNO AND M.STATUS NOT IN ('P','R','C')
                    GROUP BY S.ACCTNO, M.TRFACCTNO
                    ORDER BY S.ACCTNO) sts, lnmast mst, lntype typ, (select TO_DATE(VARVALUE,'DD/MM/RRRR') currdate from sysvar where varname='CURRDATE') dt
            where v.status='A' and v.lnacctno = sts.acctno (+) and v.codeid=sb.codeid
            and mst.actype=typ.actype and v.lnacctno=mst.acctno
            and cd.cdname='DFTYPE' and cd.cdtype='DF' and cd.cdval=v.dftype
            AND V.ACCTNO = p_account

    )
    loop
        plog.debug(pkgctx, 'gianh3');
        --Set txnum
        SELECT systemnums.C_BATCH_PREFIXED
                         || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;
        l_txmsg.brid        := substr(p_account,1,4);

        p_txnum:=l_txmsg.txnum;
        p_txdate:=l_txmsg.txdate;
        plog.debug(pkgctx, 'gianh3');
        --01    CODEID          C
        l_txmsg.txfields ('01').defname   := 'CODEID';
        l_txmsg.txfields ('01').TYPE      := 'C';
        l_txmsg.txfields ('01').VALUE     := rec.CODEID;
        --02    ACCTNO          C
        l_txmsg.txfields ('02').defname   := 'ACCTNO';
        l_txmsg.txfields ('02').TYPE      := 'C';
        l_txmsg.txfields ('02').VALUE     := p_account;
        --03    LNACCTNO        C
        l_txmsg.txfields ('03').defname   := 'LNACCTNO';
        l_txmsg.txfields ('03').TYPE      := 'C';
        l_txmsg.txfields ('03').VALUE     := rec.LNACCTNO;
        --05    AFACCTNO        C
        l_txmsg.txfields ('05').defname   := 'AFACCTNO';
        l_txmsg.txfields ('05').TYPE      := 'C';
        l_txmsg.txfields ('05').VALUE     := rec.AFACCTNO;
        plog.debug(pkgctx, 'gianh4');
        --06    SEACCTNO        C
        l_txmsg.txfields ('06').defname   := 'SEACCTNO';
        l_txmsg.txfields ('06').TYPE      := 'C';
        l_txmsg.txfields ('06').VALUE     := '';
        --07    LNTYPE          C
        l_txmsg.txfields ('07').defname   := 'LNTYPE';
        l_txmsg.txfields ('07').TYPE      := 'C';
        l_txmsg.txfields ('07').VALUE     := rec.LNTYPE;
        --08    GLMAST          C
        l_txmsg.txfields ('08').defname   := 'GLMAST';
        l_txmsg.txfields ('08').TYPE      := 'C';
        l_txmsg.txfields ('08').VALUE     := '';
        plog.debug(pkgctx, 'gianh5');
        --13    PRINOVD         N
        l_txmsg.txfields ('13').defname   := 'PRINOVD';
        l_txmsg.txfields ('13').TYPE      := 'N';
        l_txmsg.txfields ('13').VALUE     := rec.PRINOVD;
        --14    DEALPRINAMT     N   0
        l_txmsg.txfields ('14').defname   := 'DEALPRINAMT';
        l_txmsg.txfields ('14').TYPE      := 'N';
        l_txmsg.txfields ('14').VALUE     := rec.DEALPRINAMT;
        --15    PRINNML         N
        l_txmsg.txfields ('15').defname   := 'PRINNML';
        l_txmsg.txfields ('15').TYPE      := 'N';
        l_txmsg.txfields ('15').VALUE     := rec.PRINNML;
        --16    PRINPAIDAMT     N   0
        l_txmsg.txfields ('16').defname   := 'PRINPAIDAMT';
        l_txmsg.txfields ('16').TYPE      := 'N';
        l_txmsg.txfields ('16').VALUE     := p_prinAmount;
        plog.debug(pkgctx, 'gianh6');
        --18    DEALFEE         N   0
        l_txmsg.txfields ('18').defname   := 'DEALFEE';
        l_txmsg.txfields ('18').TYPE      := 'N';
        l_txmsg.txfields ('18').VALUE     := rec.DEALFEE;
        --19    DEALINTPAIDAMT  N   0
        l_txmsg.txfields ('19').defname   := 'DEALINTPAIDAMT';
        l_txmsg.txfields ('19').TYPE      := 'N';
        l_txmsg.txfields ('19').VALUE     := 0;
        --23    INTNMLOVD       N
        l_txmsg.txfields ('23').defname   := 'INTNMLOVD';
        l_txmsg.txfields ('23').TYPE      := 'N';
        l_txmsg.txfields ('23').VALUE     := rec.INTNMLOVD;
        --26    INTOVDACR       N
        l_txmsg.txfields ('26').defname   := 'INTOVDACR';
        l_txmsg.txfields ('26').TYPE      := 'N';
        l_txmsg.txfields ('26').VALUE     := rec.INTOVDACR;
        --29    DFREF           C
        l_txmsg.txfields ('29').defname   := 'DFREF';
        l_txmsg.txfields ('29').TYPE      := 'C';
        l_txmsg.txfields ('29').VALUE     := rec.DFREF;
        --30    DESC            C
        l_txmsg.txfields ('30').defname   := 'DESC';
        l_txmsg.txfields ('30').TYPE      := 'C';
        l_txmsg.txfields ('30').VALUE     := 'Thanh ly deal online';
        --31    INTDUE          N
        l_txmsg.txfields ('31').defname   := 'INTDUE';
        l_txmsg.txfields ('31').TYPE      := 'N';
        l_txmsg.txfields ('31').VALUE     := rec.INTDUE;
        plog.debug(pkgctx, 'gianh7');
        --35    INTNMLACR       N
        l_txmsg.txfields ('35').defname   := 'INTNMLACR';
        l_txmsg.txfields ('35').TYPE      := 'N';
        l_txmsg.txfields ('35').VALUE     := rec.INTNMLACR;
        --36    FEEPAID         N   0
        l_txmsg.txfields ('36').defname   := 'FEEPAID';
        l_txmsg.txfields ('36').TYPE      := 'N';
        l_txmsg.txfields ('36').VALUE     := rec.AVLFEEAMT;
        --37    DFQTTY          N   0
        l_txmsg.txfields ('37').defname   := 'DFQTTY';
        l_txmsg.txfields ('37').TYPE      := 'N';
        l_txmsg.txfields ('37').VALUE     := rec.DFTRADING;
        --38    RCVQTTY         N   0
        l_txmsg.txfields ('38').defname   := 'RCVQTTY';
        l_txmsg.txfields ('38').TYPE      := 'N';
        l_txmsg.txfields ('38').VALUE     := rec.RCVQTTY;
        plog.debug(pkgctx, 'gianh8');
        --39    CARCVQTTY       N   0
        l_txmsg.txfields ('39').defname   := 'CARCVQTTY';
        l_txmsg.txfields ('39').TYPE      := 'N';
        l_txmsg.txfields ('39').VALUE     := rec.CARCVQTTY;
        --40    BLOCKQTTY       N   0
        l_txmsg.txfields ('40').defname   := 'BLOCKQTTY';
        l_txmsg.txfields ('40').TYPE      := 'N';
        l_txmsg.txfields ('40').VALUE     := rec.BLOCKQTTY    ;
        --41    ODAMT           N   0
        l_txmsg.txfields ('41').defname   := 'ODAMT';
        l_txmsg.txfields ('41').TYPE      := 'N';
        l_txmsg.txfields ('41').VALUE     := rec.ODAMT        ;
        --42    BQTTY           N   0
        l_txmsg.txfields ('42').defname   := 'BQTTY';
        l_txmsg.txfields ('42').TYPE      := 'N';
        l_txmsg.txfields ('42').VALUE     := rec.BQTTY        ;
        plog.debug(pkgctx, 'gianh9');
        --43    SECURED         N   0
        l_txmsg.txfields ('43').defname   := 'SECURED';
        l_txmsg.txfields ('43').TYPE      := 'N';
        l_txmsg.txfields ('43').VALUE     := rec.SECURED     ;
        --45    AMT             N   0
        l_txmsg.txfields ('45').defname   := 'AMT';
        l_txmsg.txfields ('45').TYPE      := 'N';
        l_txmsg.txfields ('45').VALUE     := 0;
        --46    QTTY            N   0
        l_txmsg.txfields ('46').defname   := 'QTTY';
        l_txmsg.txfields ('46').TYPE      := 'N';
        l_txmsg.txfields ('46').VALUE     := 0;
        --47    TRADELOT        N   0
        l_txmsg.txfields ('47').defname   := 'TRADELOT';
        l_txmsg.txfields ('47').TYPE      := 'N';
        l_txmsg.txfields ('47').VALUE     := rec.TRADELOT  ;
        --48    MAXQTTY         N   0
        l_txmsg.txfields ('48').defname   := 'MAXQTTY';
        l_txmsg.txfields ('48').TYPE      := 'N';
        l_txmsg.txfields ('48').VALUE     := 0;
        --49    RLSDATE         C
        l_txmsg.txfields ('49').defname   := 'RLSDATE';
        l_txmsg.txfields ('49').TYPE      := 'C';
        l_txmsg.txfields ('49').VALUE     := rec.RLSDATE;
        plog.debug(pkgctx, 'gianh10');
        --50    RLSQTTY         N   0
        l_txmsg.txfields ('50').defname   := 'RLSQTTY';
        l_txmsg.txfields ('50').TYPE      := 'N';
        l_txmsg.txfields ('50').VALUE     := rec.RLSQTTY;
        --51    RLSAMT          N   0
        l_txmsg.txfields ('51').defname   := 'RLSAMT';
        l_txmsg.txfields ('51').TYPE      := 'N';
        l_txmsg.txfields ('51').VALUE     := rec.RLSAMT       ;
        --52    DEALAMT         N   0
        l_txmsg.txfields ('52').defname   := 'DEALAMT';
        l_txmsg.txfields ('52').TYPE      := 'N';
        l_txmsg.txfields ('52').VALUE     := rec.DEALAMT      ;
        --53    DEALFEE         N   0
        l_txmsg.txfields ('53').defname   := 'DEALFEE';
        l_txmsg.txfields ('53').TYPE      := 'N';
        l_txmsg.txfields ('53').VALUE     := rec.DEALFEE     ;
        plog.debug(pkgctx, 'gianh11');
        --57    CUSTNAME        C
        l_txmsg.txfields ('57').defname   := 'CUSTNAME';
        l_txmsg.txfields ('57').TYPE      := 'C';
        l_txmsg.txfields ('57').VALUE     := rec.FULLNAME     ;
        --58    ADDRESS         C
        l_txmsg.txfields ('58').defname   := 'ADDRESS';
        l_txmsg.txfields ('58').TYPE      := 'C';
        l_txmsg.txfields ('58').VALUE     := rec.ADDRESS      ;
        --59    LICENSE         C
        l_txmsg.txfields ('59').defname   := 'LICENSE';
        l_txmsg.txfields ('59').TYPE      := 'C';
        l_txmsg.txfields ('59').VALUE     := rec.IDCODE   ;
        --63    PPRINOVD        N   0
        l_txmsg.txfields ('63').defname   := 'PPRINOVD';
        l_txmsg.txfields ('63').TYPE      := 'N';
        l_txmsg.txfields ('63').VALUE     := 0;
        plog.debug(pkgctx, 'gianh12');
        --65    PPRINNML        N   0
        l_txmsg.txfields ('65').defname   := 'PPRINNML';
        l_txmsg.txfields ('65').TYPE      := 'N';
        l_txmsg.txfields ('65').VALUE     := 0;
        --72    PINTNMLOVD      N   0
        l_txmsg.txfields ('72').defname   := 'PINTNMLOVD';
        l_txmsg.txfields ('72').TYPE      := 'N';
        l_txmsg.txfields ('72').VALUE     := 0;
        --74    PINTOVDACR      N   0
        l_txmsg.txfields ('74').defname   := 'PINTOVDACR';
        l_txmsg.txfields ('74').TYPE      := 'N';
        l_txmsg.txfields ('74').VALUE     := 0;
        --77    PINTDUE         N   0
        l_txmsg.txfields ('77').defname   := 'PINTDUE';
        l_txmsg.txfields ('77').TYPE      := 'N';
        l_txmsg.txfields ('77').VALUE     := 0;
        --80    PINTNMLACR      N   0
        l_txmsg.txfields ('80').defname   := 'PINTNMLACR';
        l_txmsg.txfields ('80').TYPE      := 'N';
        l_txmsg.txfields ('80').VALUE     := 0;
        plog.debug(pkgctx, 'gianh13');
        --88    CUSTODYCD       C
        l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
        l_txmsg.txfields ('88').TYPE      := 'C';
        l_txmsg.txfields ('88').VALUE     := rec.CUSTODYCD    ;
        --90    PFEEPAID        N   0
        l_txmsg.txfields ('90').defname   := 'PFEEPAID';
        l_txmsg.txfields ('90').TYPE      := 'N';
        l_txmsg.txfields ('90').VALUE     := 0;
        --91    PDFQTTY         N   0
        l_txmsg.txfields ('91').defname   := 'PDFQTTY';
        l_txmsg.txfields ('91').TYPE      := 'N';
        l_txmsg.txfields ('91').VALUE     := 0;
        --92    PRCVQTTY        N   0
        l_txmsg.txfields ('92').defname   := 'PRCVQTTY';
        l_txmsg.txfields ('92').TYPE      := 'N';
        l_txmsg.txfields ('92').VALUE     := 0;
        --93    PCARCVQTTY      N   0
        l_txmsg.txfields ('93').defname   := 'PCARCVQTTY';
        l_txmsg.txfields ('93').TYPE      := 'N';
        l_txmsg.txfields ('93').VALUE     := 0;
        --94    PBLOCKQTTY      N   0
        l_txmsg.txfields ('94').defname   := 'PBLOCKQTTY';
        l_txmsg.txfields ('94').TYPE      := 'N';
        l_txmsg.txfields ('94').VALUE     := 0;
        plog.debug(pkgctx, 'gianh14');
        --95    RRID            C
        l_txmsg.txfields ('95').defname   := 'RRID';
        l_txmsg.txfields ('95').TYPE      := 'C';
        l_txmsg.txfields ('95').VALUE     := rec.RRID    ;
        --96    CIDRAWNDOWN     C
        l_txmsg.txfields ('96').defname   := 'CIDRAWNDOWN';
        l_txmsg.txfields ('96').TYPE      := 'C';
        l_txmsg.txfields ('96').VALUE     := rec.CIDRAWNDOWN ;
        --97    BANKDRAWNDOWN   C
        l_txmsg.txfields ('97').defname   := 'BANKDRAWNDOWN';
        l_txmsg.txfields ('97').TYPE      := 'C';
        l_txmsg.txfields ('97').VALUE     := rec.BANKDRAWNDOWN;
        --98    CMPDRAWNDOWN    C
        l_txmsg.txfields ('98').defname   := 'CMPDRAWNDOWN';
        l_txmsg.txfields ('98').TYPE      := 'C';
        l_txmsg.txfields ('98').VALUE     := rec.CMPDRAWNDOWN ;
        --99    LIMITCHECK      C
        l_txmsg.txfields ('99').defname   := 'LIMITCHECK';
        l_txmsg.txfields ('99').TYPE      := 'C';
        l_txmsg.txfields ('99').VALUE     := rec.LIMITCHECK     ;
        plog.debug(pkgctx, 'gianh15');
        --06  &   05&01
        l_txmsg.txfields ('06').VALUE   := l_txmsg.txfields ('05').VALUE || l_txmsg.txfields ('01').VALUE;
        plog.debug(pkgctx, 'gianh field 06:' || l_txmsg.txfields ('06').VALUE);
        --72  EX  23**16//14
        l_txmsg.txfields ('72').VALUE   := round(l_txmsg.txfields ('23').VALUE * l_txmsg.txfields ('16').VALUE /l_txmsg.txfields ('14').VALUE);
        plog.debug(pkgctx, 'gianh field 72:' || l_txmsg.txfields ('72').VALUE);
        --74  EX  26**16//14
        l_txmsg.txfields ('74').VALUE   := round(l_txmsg.txfields ('26').VALUE * l_txmsg.txfields ('16').VALUE /l_txmsg.txfields ('14').VALUE);
        plog.debug(pkgctx, 'gianh field 74:' || l_txmsg.txfields ('74').VALUE);
        --77  EX  31**16//14
        l_txmsg.txfields ('77').VALUE   := round(l_txmsg.txfields ('31').VALUE * l_txmsg.txfields ('16').VALUE /l_txmsg.txfields ('14').VALUE);
        plog.debug(pkgctx, 'gianh field 77:' || l_txmsg.txfields ('77').VALUE);
        --80  EX  35**16//14
        l_txmsg.txfields ('80').VALUE   := round(l_txmsg.txfields ('35').VALUE * l_txmsg.txfields ('16').VALUE /l_txmsg.txfields ('14').VALUE);
        plog.debug(pkgctx, 'gianh field 80:' || l_txmsg.txfields ('80').VALUE);
        --90  EX  36**16//14
        l_txmsg.txfields ('90').VALUE   := round(l_txmsg.txfields ('36').VALUE * l_txmsg.txfields ('16').VALUE /l_txmsg.txfields ('14').VALUE);
        plog.debug(pkgctx, 'gianh field 90:' || l_txmsg.txfields ('90').VALUE);
        --63  IP  16                                                  13
        l_txmsg.txfields ('63').VALUE   := greatest(least(l_txmsg.txfields ('16').VALUE , l_txmsg.txfields ('13').VALUE),0);
        plog.debug(pkgctx, 'gianh field 63:' || l_txmsg.txfields ('63').VALUE);
        --65  IP  16--63                                              15
        l_txmsg.txfields ('65').VALUE   := greatest(least(l_txmsg.txfields ('16').VALUE-l_txmsg.txfields ('63').VALUE , l_txmsg.txfields ('15').VALUE),0);
        plog.debug(pkgctx, 'gianh field 65:' || l_txmsg.txfields ('65').VALUE);
        --19  EX  72++74++77++80++90
        l_txmsg.txfields ('19').VALUE   := round(l_txmsg.txfields ('72').VALUE + l_txmsg.txfields ('74').VALUE + l_txmsg.txfields ('77').VALUE + l_txmsg.txfields ('80').VALUE + l_txmsg.txfields ('90').VALUE);
        plog.debug(pkgctx, 'gianh field 19:' || l_txmsg.txfields ('19').VALUE);
        --45  EX  16++19
        l_txmsg.txfields ('45').VALUE   := round(l_txmsg.txfields ('16').VALUE + l_txmsg.txfields ('19').VALUE);
        plog.debug(pkgctx, 'gianh field 45:' || l_txmsg.txfields ('45').VALUE);
        --48  FM  ((51++16))//52**((43++37++38++39++40++50++42))--50  37++38++39++40
        l_txmsg.txfields ('48').VALUE   := floor(greatest(least((l_txmsg.txfields ('51').VALUE+l_txmsg.txfields ('16').VALUE)/l_txmsg.txfields ('52').VALUE * (l_txmsg.txfields ('43').VALUE+l_txmsg.txfields ('37').VALUE+l_txmsg.txfields ('38').VALUE+l_txmsg.txfields ('39').VALUE+l_txmsg.txfields ('40').VALUE+l_txmsg.txfields ('50').VALUE+l_txmsg.txfields ('42').VALUE),
                                                                l_txmsg.txfields ('37').VALUE + l_txmsg.txfields ('38').VALUE + l_txmsg.txfields ('39').VALUE + l_txmsg.txfields ('40').VALUE
                                                                )
                                                        ,0)
                                                );
        plog.debug(pkgctx, 'gianh field 48:' || l_txmsg.txfields ('48').VALUE);
        l_txmsg.txfields ('46').VALUE   :=floor(l_txmsg.txfields ('48').VALUE/rec.TRADELOT) * rec.TRADELOT;
        plog.debug(pkgctx, 'gianh field 46:' || l_txmsg.txfields ('46').VALUE);
        --94  IP  46                                                  40
        l_txmsg.txfields ('94').VALUE   := greatest(least(l_txmsg.txfields ('46').VALUE , l_txmsg.txfields ('40').VALUE),0);
        plog.debug(pkgctx, 'gianh field 94:' || l_txmsg.txfields ('94').VALUE);
        --93  IP  46--94                                              39
        l_txmsg.txfields ('93').VALUE   := greatest(least(l_txmsg.txfields ('46').VALUE-l_txmsg.txfields ('94').VALUE , l_txmsg.txfields ('39').VALUE),0);
        plog.debug(pkgctx, 'gianh field 93:' || l_txmsg.txfields ('93').VALUE);
        --92  IP  46--93--94                                          38
        l_txmsg.txfields ('92').VALUE   := greatest(least(l_txmsg.txfields ('46').VALUE-l_txmsg.txfields ('93').VALUE-l_txmsg.txfields ('94').VALUE , l_txmsg.txfields ('38').VALUE),0);
        plog.debug(pkgctx, 'gianh field 92:' || l_txmsg.txfields ('92').VALUE);
        --91  IP  46--92--93--94                                      37
        l_txmsg.txfields ('91').VALUE   := greatest(least(l_txmsg.txfields ('46').VALUE-l_txmsg.txfields ('92').VALUE-l_txmsg.txfields ('93').VALUE-l_txmsg.txfields ('94').VALUE , l_txmsg.txfields ('37').VALUE),0);
        plog.debug(pkgctx, 'gianh field 91:' || l_txmsg.txfields ('91').VALUE);
        BEGIN
            IF txpks_#2642.fn_autotxprocess (l_txmsg,
                                             p_err_code,
                                             l_err_param
               ) <> systemnums.c_success
            THEN
               plog.debug (pkgctx,
                           'got error 2642: ' || p_err_code
               );
               ROLLBACK;
               RETURN;
            END IF;
        END;
        plog.debug(pkgctx, 'End pr_DealPayment');
    end loop;


    p_err_code:=0;
    plog.setendsection(pkgctx, 'pr_DealPayment');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on pr_DealPayment');
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_DealPayment');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_DealPayment;
  ---------------------------------pr_DealLoanPayment------------------------------------------------
  PROCEDURE pr_DealLoanPayment(p_account varchar2,p_prinAmount  varchar2,p_intAmount number,p_fee number,p_err_code  OUT varchar2,p_txdate  OUT varchar2,p_txnum  OUT varchar2)
  IS
      l_txmsg               tx.msg_rectype;
      v_dtCURRDATE date;
      l_err_param varchar2(300);

  BEGIN
    plog.setbeginsection(pkgctx, 'pr_DealLoanPayment');
    SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO v_dtCURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    l_txmsg.msgtype:='T';
    l_txmsg.local:='N';
    l_txmsg.tlid        := systemnums.c_system_userid;
    SELECT SYS_CONTEXT ('USERENV', 'HOST'),
             SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
      INTO l_txmsg.wsname, l_txmsg.ipaddress
    FROM DUAL;
    l_txmsg.off_line    := 'N';
    l_txmsg.deltd       := txnums.c_deltd_txnormal;
    l_txmsg.txstatus    := txstatusnums.c_txcompleted;
    l_txmsg.msgsts      := '0';
    l_txmsg.ovrsts      := '0';
    l_txmsg.batchname   := 'INT';
    l_txmsg.txdate:=v_dtCURRDATE;
    l_txmsg.busdate:=v_dtCURRDATE;
    l_txmsg.tltxcd:='5540';
    for rec in (
        SELECT MST.ACCTNO, MST.TRFACCTNO, LNTYPE, CD3.CDCONTENT DESC_LNTYPE, CF.CUSTODYCD,
        OPRINNML+OPRINOVD T0ODAMT, OPRINNML-NVL(SCHD_T0.NML,0) T0PRINNML, NVL(SCHD_T0.NML,0) T0PRINDUE, OPRINOVD T0PRINOVD,
        PRINOVD, NVL(SCHD.NML,0) PRINDUE, PRINNML - NVL(SCHD.NML,0) PRINNML,
        FEEOVD, INTNMLOVD + OINTNMLOVD SUMINTNMLOVD, INTNMLOVD, OINTNMLOVD T0INTNMLOVD,
        INTOVDACR + OINTOVDACR SUMINTOVDACR, INTOVDACR, OINTOVDACR T0INTOVDACR,
        FEEDUE, INTDUE + OINTDUE SUMINTDUE, INTDUE, OINTDUE T0INTDUE,
        FEE, INTNMLACR + OINTNMLACR SUMINTNMLACR, INTNMLACR, OINTNMLACR T0INTNMLACR,
        CD2.CDCONTENT ADVPAY, ADVPAYFEE,
        OPRINNML + OPRINOVD + PRINOVD + PRINNML + FEEOVD + INTNMLOVD +  OINTNMLOVD + INTOVDACR + OINTOVDACR + FEEDUE + INTDUE + OINTDUE + FEE + INTNMLACR + OINTNMLACR ODAMT,
        PRINNML - NVL(SCHD.NML,0) + FEE + INTNMLACR + OINTNMLACR NMLAMT,
        PRINNML - NVL(SCHD.NML,0) PRINNMLAMT,
        FEE + INTNMLACR + OINTNMLACR INTNMLAMT,
        OPRINNML + OPRINOVD + PRINNML + PRINOVD PRINODAMT,
        FEEOVD + INTNMLOVD +  OINTNMLOVD + INTOVDACR + OINTOVDACR + FEEDUE + INTDUE + OINTDUE + FEE + INTNMLACR + OINTNMLACR INTODAMT,
        MST.STATUS, CD1.CDCONTENT DES_STATUS
        FROM LNMAST MST, ALLCODE CD1, ALLCODE CD2, ALLCODE CD3, AFMAST AF, CFMAST CF,
            (SELECT ACCTNO, SUM(NML) NML
                FROM LNSCHD S
                WHERE S.REFTYPE = 'P' AND S.OVERDUEDATE = v_dtCURRDATE AND  S.NML > 0
                GROUP BY S.ACCTNO) SCHD,
            (SELECT ACCTNO, SUM(NML) NML
                FROM LNSCHD S
                WHERE S.REFTYPE = 'GP' AND S.OVERDUEDATE = v_dtCURRDATE AND  S.NML > 0
                GROUP BY S.ACCTNO) SCHD_T0
        WHERE CD1.CDTYPE='LN' AND CD1.CDNAME='STATUS' AND CD1.CDVAL=MST.STATUS
            AND CD2.CDTYPE='SY' AND CD2.CDNAME='YESNO' AND CD2.CDVAL=MST.ADVPAY
            AND CD3.CDTYPE='LN' AND CD3.CDNAME='LNTYPE' AND CD3.CDVAL=MST.LNTYPE
            AND AF.ACCTNO = MST.TRFACCTNO AND AF.CUSTID = CF.CUSTID
            AND MST.STATUS NOT IN ('R','C','P') AND MST.FTYPE='AF'
            AND OPRINNML + OPRINOVD + PRINOVD + PRINNML + FEEOVD + INTNMLOVD +  OINTNMLOVD + INTOVDACR + OINTOVDACR + FEEDUE + INTDUE + OINTDUE + FEE + INTNMLACR + OINTNMLACR > 0
            AND MST.ACCTNO = SCHD.ACCTNO(+) AND MST.ACCTNO = SCHD_T0.ACCTNO(+)
            and mst.acctno = p_account
    )
    loop
        --Set txnum
        SELECT systemnums.C_BATCH_PREFIXED
                         || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;
        l_txmsg.brid        := substr(p_account,1,4);

        p_txnum:=l_txmsg.txnum;
        p_txdate:=l_txmsg.txdate;
        --Set cac field giao dich
        --03    ACCTNO          C
        l_txmsg.txfields ('03').defname   := 'ACCTNO';
        l_txmsg.txfields ('03').TYPE      := 'C';
        l_txmsg.txfields ('03').VALUE     := rec.ACCTNO;
        --05    CIACCTNO        C
        l_txmsg.txfields ('05').defname   := 'CIACCTNO';
        l_txmsg.txfields ('05').TYPE      := 'C';
        l_txmsg.txfields ('05').VALUE     := rec.TRFACCTNO;
        --07    LNTYPE          C
        l_txmsg.txfields ('07').defname   := 'LNTYPE';
        l_txmsg.txfields ('07').TYPE      := 'C';
        l_txmsg.txfields ('07').VALUE     := rec.LNTYPE;
        --09    T0ODAMT         N
        l_txmsg.txfields ('09').defname   := 'T0ODAMT';
        l_txmsg.txfields ('09').TYPE      := 'N';
        l_txmsg.txfields ('09').VALUE     := rec.T0ODAMT;
        --10    T0PRINOVD       N
        l_txmsg.txfields ('10').defname   := 'T0PRINOVD';
        l_txmsg.txfields ('10').TYPE      := 'N';
        l_txmsg.txfields ('10').VALUE     := rec.T0PRINOVD;
        --11    T0PRINDUE       N
        l_txmsg.txfields ('11').defname   := 'T0PRINDUE';
        l_txmsg.txfields ('11').TYPE      := 'N';
        l_txmsg.txfields ('11').VALUE     := rec.T0PRINDUE;
        --12    T0PRINNML       N
        l_txmsg.txfields ('12').defname   := 'T0PRINNML';
        l_txmsg.txfields ('12').TYPE      := 'N';
        l_txmsg.txfields ('12').VALUE     := rec.T0PRINNML       ;
        --13    PRINOVD         N
        l_txmsg.txfields ('13').defname   := 'PRINOVD';
        l_txmsg.txfields ('13').TYPE      := 'N';
        l_txmsg.txfields ('13').VALUE     := rec.PRINOVD;
        --14    PRINDUE         N
        l_txmsg.txfields ('14').defname   := 'PRINDUE';
        l_txmsg.txfields ('14').TYPE      := 'N';
        l_txmsg.txfields ('14').VALUE     := rec.PRINDUE;
        --15    PRINNML         N
        l_txmsg.txfields ('15').defname   := 'PRINNML';
        l_txmsg.txfields ('15').TYPE      := 'N';
        l_txmsg.txfields ('15').VALUE     := rec.PRINNML;
        --20    FEEOVD          N
        l_txmsg.txfields ('20').defname   := 'FEEOVD';
        l_txmsg.txfields ('20').TYPE      := 'N';
        l_txmsg.txfields ('20').VALUE     := rec.FEEOVD;
        --21    SUMINTNMLOVD    N
        l_txmsg.txfields ('21').defname   := 'SUMINTNMLOVD';
        l_txmsg.txfields ('21').TYPE      := 'N';
        l_txmsg.txfields ('21').VALUE     := rec.SUMINTNMLOVD;
        --22    T0INTNMLOVD     N
        l_txmsg.txfields ('22').defname   := 'T0INTNMLOVD';
        l_txmsg.txfields ('22').TYPE      := 'N';
        l_txmsg.txfields ('22').VALUE     := rec.T0INTNMLOVD;
        --23    INTNMLOVD       N
        l_txmsg.txfields ('23').defname   := 'INTNMLOVD';
        l_txmsg.txfields ('23').TYPE      := 'N';
        l_txmsg.txfields ('23').VALUE     := rec.INTNMLOVD;
        --24    SUMINTOVDACR    N
        l_txmsg.txfields ('24').defname   := 'SUMINTOVDACR';
        l_txmsg.txfields ('24').TYPE      := 'N';
        l_txmsg.txfields ('24').VALUE     := rec.SUMINTOVDACR;
        --25    T0INTOVDACR     N
        l_txmsg.txfields ('25').defname   := 'T0INTOVDACR';
        l_txmsg.txfields ('25').TYPE      := 'N';
        l_txmsg.txfields ('25').VALUE     := rec.T0INTOVDACR;
        --26    INTOVDACR       N
        l_txmsg.txfields ('26').defname   := 'INTOVDACR';
        l_txmsg.txfields ('26').TYPE      := 'N';
        l_txmsg.txfields ('26').VALUE     := rec.INTOVDACR;
        --27    FEEDUE          N
        l_txmsg.txfields ('27').defname   := 'FEEDUE';
        l_txmsg.txfields ('27').TYPE      := 'N';
        l_txmsg.txfields ('27').VALUE     := rec.FEEDUE;
        --28    SUMINTDUE       N
        l_txmsg.txfields ('28').defname   := 'SUMINTDUE';
        l_txmsg.txfields ('28').TYPE      := 'N';
        l_txmsg.txfields ('28').VALUE     := rec.SUMINTDUE;
        --29    T0INTDUE        N
        l_txmsg.txfields ('29').defname   := 'T0INTDUE';
        l_txmsg.txfields ('29').TYPE      := 'N';
        l_txmsg.txfields ('29').VALUE     := rec.T0INTDUE;
        --30    DESC            C
        l_txmsg.txfields ('30').defname   := 'DESC';
        l_txmsg.txfields ('30').TYPE      := 'C';
        l_txmsg.txfields ('30').VALUE     := 'Tra no deal online';
        --31    INTDUE          N
        l_txmsg.txfields ('31').defname   := 'INTDUE';
        l_txmsg.txfields ('31').TYPE      := 'N';
        l_txmsg.txfields ('31').VALUE     := rec.INTDUE;
        --32    FEE             N
        l_txmsg.txfields ('32').defname   := 'FEE';
        l_txmsg.txfields ('32').TYPE      := 'N';
        l_txmsg.txfields ('32').VALUE     := rec.FEE;
        --33    SUMINTNMLACR    N
        l_txmsg.txfields ('33').defname   := 'SUMINTNMLACR';
        l_txmsg.txfields ('33').TYPE      := 'N';
        l_txmsg.txfields ('33').VALUE     := rec.SUMINTNMLACR;
        --34    T0INTNMLACR     N
        l_txmsg.txfields ('34').defname   := 'T0INTNMLACR';
        l_txmsg.txfields ('34').TYPE      := 'N';
        l_txmsg.txfields ('34').VALUE     := rec.T0INTNMLACR;
        --35    INTNMLACR       N
        l_txmsg.txfields ('35').defname   := 'INTNMLACR';
        l_txmsg.txfields ('35').TYPE      := 'N';
        l_txmsg.txfields ('35').VALUE     := rec.INTNMLACR;
        --40    ODAMT           N
        l_txmsg.txfields ('40').defname   := 'ODAMT';
        l_txmsg.txfields ('40').TYPE      := 'N';
        l_txmsg.txfields ('40').VALUE     := rec.ODAMT;
        --41    PRINODAMT       N
        l_txmsg.txfields ('41').defname   := 'PRINODAMT';
        l_txmsg.txfields ('41').TYPE      := 'N';
        l_txmsg.txfields ('41').VALUE     := rec.PRINODAMT;
        --42    PRINNMLAMT      N
        l_txmsg.txfields ('42').defname   := 'PRINNMLAMT';
        l_txmsg.txfields ('42').TYPE      := 'N';
        l_txmsg.txfields ('42').VALUE     := rec.PRINNMLAMT;
        --43    INTODAMT        N
        l_txmsg.txfields ('43').defname   := 'INTODAMT';
        l_txmsg.txfields ('43').TYPE      := 'N';
        l_txmsg.txfields ('43').VALUE     := rec.INTODAMT;
        --44    INTNMLAMT       N
        l_txmsg.txfields ('44').defname   := 'INTNMLAMT';
        l_txmsg.txfields ('44').TYPE      := 'N';
        l_txmsg.txfields ('44').VALUE     := rec.INTNMLAMT;
        --45    PRINAMT         N
        l_txmsg.txfields ('45').defname   := 'PRINAMT';
        l_txmsg.txfields ('45').TYPE      := 'N';
        l_txmsg.txfields ('45').VALUE     := p_prinAmount;
        --46    INTAMT          N
        l_txmsg.txfields ('46').defname   := 'INTAMT';
        l_txmsg.txfields ('46').TYPE      := 'N';
        l_txmsg.txfields ('46').VALUE     := p_intAmount;
        --47    ADVFEE          N
        l_txmsg.txfields ('47').defname   := 'ADVFEE';
        l_txmsg.txfields ('47').TYPE      := 'N';
        l_txmsg.txfields ('47').VALUE     := p_fee;
        --50    PERCENT         N
        l_txmsg.txfields ('50').defname   := 'PERCENT';
        l_txmsg.txfields ('50').TYPE      := 'N';
        l_txmsg.txfields ('50').VALUE     := 100;
        --60    PT0PRINOVD      N
        l_txmsg.txfields ('60').defname   := 'PT0PRINOVD';
        l_txmsg.txfields ('60').TYPE      := 'N';
        l_txmsg.txfields ('60').VALUE     := 0;
        --61    PT0PRINDUE      N
        l_txmsg.txfields ('61').defname   := 'PT0PRINDUE';
        l_txmsg.txfields ('61').TYPE      := 'N';
        l_txmsg.txfields ('61').VALUE     := 0;
        --62    PT0PRINNML      N
        l_txmsg.txfields ('62').defname   := 'PT0PRINNML';
        l_txmsg.txfields ('62').TYPE      := 'N';
        l_txmsg.txfields ('62').VALUE     := 0;
        --63    PPRINOVD        N
        l_txmsg.txfields ('63').defname   := 'PPRINOVD';
        l_txmsg.txfields ('63').TYPE      := 'N';
        l_txmsg.txfields ('63').VALUE     := 0;
        --64    PPRINDUE        N
        l_txmsg.txfields ('64').defname   := 'PPRINDUE';
        l_txmsg.txfields ('64').TYPE      := 'N';
        l_txmsg.txfields ('64').VALUE     := 0;
        --65    PPRINNML        N
        l_txmsg.txfields ('65').defname   := 'PPRINNML';
        l_txmsg.txfields ('65').TYPE      := 'N';
        l_txmsg.txfields ('65').VALUE     := 0;
        --70    PFEEOVD         N
        l_txmsg.txfields ('70').defname   := 'PFEEOVD';
        l_txmsg.txfields ('70').TYPE      := 'N';
        l_txmsg.txfields ('70').VALUE     := 0;
        --71    PT0INTNMLOVD    N
        l_txmsg.txfields ('71').defname   := 'PT0INTNMLOVD';
        l_txmsg.txfields ('71').TYPE      := 'N';
        l_txmsg.txfields ('71').VALUE     := 0;
        --72    PINTNMLOVD      N
        l_txmsg.txfields ('72').defname   := 'PINTNMLOVD';
        l_txmsg.txfields ('72').TYPE      := 'N';
        l_txmsg.txfields ('72').VALUE     := 0;
        --73    PT0INTOVDACR    N
        l_txmsg.txfields ('73').defname   := 'PT0INTOVDACR';
        l_txmsg.txfields ('73').TYPE      := 'N';
        l_txmsg.txfields ('73').VALUE     := 0;
        --74    PINTOVDACR      N
        l_txmsg.txfields ('74').defname   := 'PINTOVDACR';
        l_txmsg.txfields ('74').TYPE      := 'N';
        l_txmsg.txfields ('74').VALUE     := 0;
        --75    PFEEDUE         N
        l_txmsg.txfields ('75').defname   := 'PFEEDUE';
        l_txmsg.txfields ('75').TYPE      := 'N';
        l_txmsg.txfields ('75').VALUE     := 0;
        --76    PT0INTDUE       N
        l_txmsg.txfields ('76').defname   := 'PT0INTDUE';
        l_txmsg.txfields ('76').TYPE      := 'N';
        l_txmsg.txfields ('76').VALUE     := 0;
        --77    PINTDUE         N
        l_txmsg.txfields ('77').defname   := 'PINTDUE';
        l_txmsg.txfields ('77').TYPE      := 'N';
        l_txmsg.txfields ('77').VALUE     := 0;
        --78    PFEE            N
        l_txmsg.txfields ('78').defname   := 'PFEE';
        l_txmsg.txfields ('78').TYPE      := 'N';
        l_txmsg.txfields ('78').VALUE     := 0;
        --79    PT0INTNMLACR    N
        l_txmsg.txfields ('79').defname   := 'PT0INTNMLACR';
        l_txmsg.txfields ('79').TYPE      := 'N';
        l_txmsg.txfields ('79').VALUE     := 0;
        --80    PINTNMLACR      N
        l_txmsg.txfields ('80').defname   := 'PINTNMLACR';
        l_txmsg.txfields ('80').TYPE      := 'N';
        l_txmsg.txfields ('80').VALUE     := 0;
        --81    ADVPAYAMT       N
        l_txmsg.txfields ('81').defname   := 'ADVPAYAMT';
        l_txmsg.txfields ('81').TYPE      := 'N';
        l_txmsg.txfields ('81').VALUE     := 0;
        --82    FEEAMT          N
        l_txmsg.txfields ('82').defname   := 'FEEAMT';
        l_txmsg.txfields ('82').TYPE      := 'N';
        l_txmsg.txfields ('82').VALUE     := 0;
        --83    PAYAMT          N
        l_txmsg.txfields ('83').defname   := 'PAYAMT';
        l_txmsg.txfields ('83').TYPE      := 'N';
        l_txmsg.txfields ('83').VALUE     := 0;
        --Set lai tham so theo fldval
        --IP  60  45                                          10
        l_txmsg.txfields ('60').VALUE:=greatest(least(l_txmsg.txfields ('45').VALUE,l_txmsg.txfields ('10').VALUE),0);
        --IP  61  45--60                                      11
        l_txmsg.txfields ('61').VALUE:=greatest(least(l_txmsg.txfields ('45').VALUE-l_txmsg.txfields ('60').VALUE,l_txmsg.txfields ('11').VALUE),0);
        --IP  62  45--60--61                                  12
        l_txmsg.txfields ('62').VALUE:=greatest(least(l_txmsg.txfields ('45').VALUE-l_txmsg.txfields ('60').VALUE-l_txmsg.txfields ('61').VALUE,l_txmsg.txfields ('12').VALUE),0);
        --IP  63  45--60--61--62                              13
        l_txmsg.txfields ('63').VALUE:=greatest(least(l_txmsg.txfields ('45').VALUE-l_txmsg.txfields ('60').VALUE-l_txmsg.txfields ('61').VALUE-l_txmsg.txfields ('62').VALUE,l_txmsg.txfields ('13').VALUE),0);
        --IP  64  45--60--61--62--63                          14
        l_txmsg.txfields ('64').VALUE:=greatest(least(l_txmsg.txfields ('45').VALUE-l_txmsg.txfields ('60').VALUE-l_txmsg.txfields ('61').VALUE-l_txmsg.txfields ('62').VALUE-l_txmsg.txfields ('63').VALUE,l_txmsg.txfields ('14').VALUE),0);
        --IP  65  45--60--61--62--63--64                      15
        l_txmsg.txfields ('65').VALUE:=greatest(least(l_txmsg.txfields ('45').VALUE-l_txmsg.txfields ('60').VALUE-l_txmsg.txfields ('61').VALUE-l_txmsg.txfields ('62').VALUE-l_txmsg.txfields ('63').VALUE-l_txmsg.txfields ('64').VALUE,l_txmsg.txfields ('15').VALUE),0);
        --IP  70  46                                          20
        l_txmsg.txfields ('70').VALUE:=greatest(least(l_txmsg.txfields ('46').VALUE,l_txmsg.txfields ('20').VALUE),0);
        --IP  71  46--70                                      22
        l_txmsg.txfields ('71').VALUE:=greatest(least(l_txmsg.txfields ('46').VALUE-l_txmsg.txfields ('70').VALUE,l_txmsg.txfields ('22').VALUE),0);
        --IP  72  46--70--71                                  23
        l_txmsg.txfields ('72').VALUE:=greatest(least(l_txmsg.txfields ('46').VALUE-l_txmsg.txfields ('70').VALUE-l_txmsg.txfields ('71').VALUE,l_txmsg.txfields ('23').VALUE),0);
        --IP  73  46--70--71--72                              25
        l_txmsg.txfields ('73').VALUE:=greatest(least(l_txmsg.txfields ('46').VALUE-l_txmsg.txfields ('70').VALUE-l_txmsg.txfields ('71').VALUE-l_txmsg.txfields ('72').VALUE,l_txmsg.txfields ('25').VALUE),0);
        --IP  74  46--70--71--72--73                          26
        l_txmsg.txfields ('74').VALUE:=greatest(least(l_txmsg.txfields ('46').VALUE-l_txmsg.txfields ('70').VALUE-l_txmsg.txfields ('71').VALUE-l_txmsg.txfields ('72').VALUE-l_txmsg.txfields ('73').VALUE,l_txmsg.txfields ('26').VALUE),0);
        --IP  75  46--70--71--72--73--74                      27
        l_txmsg.txfields ('75').VALUE:=greatest(least(l_txmsg.txfields ('46').VALUE-l_txmsg.txfields ('70').VALUE-l_txmsg.txfields ('71').VALUE-l_txmsg.txfields ('72').VALUE-l_txmsg.txfields ('73').VALUE-l_txmsg.txfields ('74').VALUE,l_txmsg.txfields ('27').VALUE),0);
        --IP  76  46--70--71--72--73--74--75                  29
        l_txmsg.txfields ('76').VALUE:=greatest(least(l_txmsg.txfields ('46').VALUE-l_txmsg.txfields ('70').VALUE-l_txmsg.txfields ('71').VALUE-l_txmsg.txfields ('72').VALUE-l_txmsg.txfields ('73').VALUE-l_txmsg.txfields ('74').VALUE-l_txmsg.txfields ('75').VALUE,l_txmsg.txfields ('29').VALUE),0);
        --IP  77  46--70--71--72--73--74--75--76              31
        l_txmsg.txfields ('77').VALUE:=greatest(least(l_txmsg.txfields ('46').VALUE-l_txmsg.txfields ('70').VALUE-l_txmsg.txfields ('71').VALUE-l_txmsg.txfields ('72').VALUE-l_txmsg.txfields ('73').VALUE-l_txmsg.txfields ('74').VALUE-l_txmsg.txfields ('75').VALUE-l_txmsg.txfields ('76').VALUE,l_txmsg.txfields ('31').VALUE),0);
        --IP  78  46--70--71--72--73--74--75--76--77          32
        l_txmsg.txfields ('78').VALUE:=greatest(least(l_txmsg.txfields ('46').VALUE-l_txmsg.txfields ('70').VALUE-l_txmsg.txfields ('71').VALUE-l_txmsg.txfields ('72').VALUE-l_txmsg.txfields ('73').VALUE-l_txmsg.txfields ('74').VALUE-l_txmsg.txfields ('75').VALUE-l_txmsg.txfields ('76').VALUE-l_txmsg.txfields ('77').VALUE,l_txmsg.txfields ('32').VALUE),0);
        --IP  79  46--70--71--72--73--74--75--76--77--78      34
        l_txmsg.txfields ('79').VALUE:=greatest(least(l_txmsg.txfields ('46').VALUE-l_txmsg.txfields ('70').VALUE-l_txmsg.txfields ('71').VALUE-l_txmsg.txfields ('72').VALUE-l_txmsg.txfields ('73').VALUE-l_txmsg.txfields ('74').VALUE-l_txmsg.txfields ('75').VALUE-l_txmsg.txfields ('76').VALUE-l_txmsg.txfields ('77').VALUE-l_txmsg.txfields ('78').VALUE,l_txmsg.txfields ('34').VALUE),0);
        --IP  80  46--70--71--72--73--74--75--76--77--78--79  35
        l_txmsg.txfields ('80').VALUE:=greatest(least(l_txmsg.txfields ('46').VALUE-l_txmsg.txfields ('70').VALUE-l_txmsg.txfields ('71').VALUE-l_txmsg.txfields ('72').VALUE-l_txmsg.txfields ('73').VALUE-l_txmsg.txfields ('74').VALUE-l_txmsg.txfields ('75').VALUE-l_txmsg.txfields ('76').VALUE-l_txmsg.txfields ('77').VALUE-l_txmsg.txfields ('78').VALUE-l_txmsg.txfields ('79').VALUE,l_txmsg.txfields ('35').VALUE),0);
        --IP  81  65++78++79++80                              65++78++79++80
        l_txmsg.txfields ('81').VALUE:=greatest(l_txmsg.txfields ('65').VALUE+l_txmsg.txfields ('80').VALUE+l_txmsg.txfields ('78').VALUE+l_txmsg.txfields ('79').VALUE,0);
        --IP  82  81**47//50                                  81**47//50
        l_txmsg.txfields ('82').VALUE:=ROUND(greatest(l_txmsg.txfields ('81').VALUE*l_txmsg.txfields ('47').VALUE/l_txmsg.txfields ('50').VALUE,0),0);
        --IP  83  45++46++82                                  45++46++82
        l_txmsg.txfields ('83').VALUE:=greatest(l_txmsg.txfields ('45').VALUE+l_txmsg.txfields ('46').VALUE+l_txmsg.txfields ('82').VALUE,0);

        BEGIN
            IF txpks_#5540.fn_autotxprocess (l_txmsg,
                                             p_err_code,
                                             l_err_param
               ) <> systemnums.c_success
            THEN
               plog.debug (pkgctx,
                           'got error 5540: ' || p_err_code
               );
               ROLLBACK;
               RETURN;
            END IF;
        END;
    end loop;


    p_err_code:=0;
    plog.setendsection(pkgctx, 'pr_DealLoanPayment');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on pr_DealLoanPayment');
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_DealLoanPayment');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_DealLoanPayment;
---------------------------------pr_InternalTransfer------------------------------------------------
  PROCEDURE pr_InternalTransfer(p_account varchar,p_toaccount  varchar2,p_amount number,p_desc varchar2,p_err_code  OUT varchar2,p_txdate  OUT varchar2,p_txnum  OUT varchar2)
  IS
      l_txmsg               tx.msg_rectype;
      v_strCURRDATE varchar2(20);
      l_err_param varchar2(300);

  BEGIN
    plog.setbeginsection(pkgctx, 'pr_InternalTransfer');
    SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO v_strCURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    l_txmsg.msgtype:='T';
    l_txmsg.local:='N';
    l_txmsg.tlid        := systemnums.c_system_userid;
    SELECT SYS_CONTEXT ('USERENV', 'HOST'),
             SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
      INTO l_txmsg.wsname, l_txmsg.ipaddress
    FROM DUAL;
    l_txmsg.off_line    := 'N';
    l_txmsg.deltd       := txnums.c_deltd_txnormal;
    l_txmsg.txstatus    := txstatusnums.c_txcompleted;
    l_txmsg.msgsts      := '0';
    l_txmsg.ovrsts      := '0';
    l_txmsg.batchname   := 'INT';
    l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.busdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.tltxcd:='1120';

    --Set txnum
    SELECT systemnums.C_BATCH_PREFIXED
                     || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
              INTO l_txmsg.txnum
              FROM DUAL;
    l_txmsg.brid        := substr(p_account,1,4);

  p_txnum:=l_txmsg.txnum;
  p_txdate:=l_txmsg.txdate;
    --Set cac field giao dich
    --03   DACCTNO     C
    l_txmsg.txfields ('03').defname   := 'DACCTNO';
    l_txmsg.txfields ('03').TYPE      := 'C';
    l_txmsg.txfields ('03').VALUE     := p_account;
    --05   CACCTNO     C
    l_txmsg.txfields ('05').defname   := 'CACCTNO';
    l_txmsg.txfields ('05').TYPE      := 'C';
    l_txmsg.txfields ('05').VALUE     := p_toaccount;
    --10   AMT         N
    l_txmsg.txfields ('10').defname   := 'AMT';
    l_txmsg.txfields ('10').TYPE      := 'N';
    l_txmsg.txfields ('10').VALUE     := round(p_amount,0);
    --30   DESC        C
    l_txmsg.txfields ('30').defname   := 'DESC';
    l_txmsg.txfields ('30').TYPE      := 'C';
    l_txmsg.txfields ('30').VALUE :=p_desc;
    --31   FULLNAME            C
    l_txmsg.txfields ('31').defname   := 'FULLNAME';
    l_txmsg.txfields ('31').TYPE      := 'C';
    l_txmsg.txfields ('31').VALUE :='';
    --87   AVLCASH     N
    l_txmsg.txfields ('87').defname   := 'AVLCASH';
    l_txmsg.txfields ('87').TYPE      := 'N';
    l_txmsg.txfields ('87').VALUE     := 0;
    --88   CUSTODYCD   C
    l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
    l_txmsg.txfields ('88').TYPE      := 'C';
    l_txmsg.txfields ('88').VALUE :='';
    --89   CUSTODYCD   C
    l_txmsg.txfields ('89').defname   := 'CUSTODYCD';
    l_txmsg.txfields ('89').TYPE      := 'C';
    l_txmsg.txfields ('89').VALUE :='';
    --90   CUSTNAME    C
    l_txmsg.txfields ('90').defname   := 'CUSTNAME';
    l_txmsg.txfields ('90').TYPE      := 'C';
    l_txmsg.txfields ('90').VALUE :='';
    --91   ADDRESS     C
    l_txmsg.txfields ('91').defname   := 'ADDRESS';
    l_txmsg.txfields ('91').TYPE      := 'C';
    l_txmsg.txfields ('91').VALUE :='';
    --92   LICENSE     C
    l_txmsg.txfields ('92').defname   := 'LICENSE';
    l_txmsg.txfields ('92').TYPE      := 'C';
    l_txmsg.txfields ('92').VALUE :='';
    --93   CUSTNAME2   C
    l_txmsg.txfields ('93').defname   := 'CUSTNAME2';
    l_txmsg.txfields ('93').TYPE      := 'C';
    l_txmsg.txfields ('93').VALUE :='';
    --94   ADDRESS2    C
    l_txmsg.txfields ('94').defname   := 'ADDRESS2';
    l_txmsg.txfields ('94').TYPE      := 'C';
    l_txmsg.txfields ('94').VALUE :='';
    --95   LICENSE2    C
    l_txmsg.txfields ('95').defname   := 'LICENSE2';
    l_txmsg.txfields ('95').TYPE      := 'C';
    l_txmsg.txfields ('95').VALUE :='';
    --96   IDDATE      C
    l_txmsg.txfields ('96').defname   := 'IDDATE';
    l_txmsg.txfields ('96').TYPE      := 'C';
    l_txmsg.txfields ('96').VALUE :='';
    --97   IDPLACE     C
    l_txmsg.txfields ('97').defname   := 'IDPLACE';
    l_txmsg.txfields ('97').TYPE      := 'C';
    l_txmsg.txfields ('97').VALUE :='';
    --98   IDDATE2     C
    l_txmsg.txfields ('98').defname   := 'IDDATE2';
    l_txmsg.txfields ('98').TYPE      := 'C';
    l_txmsg.txfields ('98').VALUE :='';
    --99   IDPLACE2    C
    l_txmsg.txfields ('99').defname   := 'IDPLACE2';
    l_txmsg.txfields ('99').TYPE      := 'C';
    l_txmsg.txfields ('99').VALUE :='';
    --79   REFID    C
    l_txmsg.txfields ('79').defname   := 'REFID';
    l_txmsg.txfields ('79').TYPE      := 'C';
    l_txmsg.txfields ('79').VALUE :='';

    BEGIN
        IF txpks_#1120.fn_autotxprocess (l_txmsg,
                                         p_err_code,
                                         l_err_param
           ) <> systemnums.c_success
        THEN
           plog.debug (pkgctx,
                       'got error 1120: ' || p_err_code
           );
           ROLLBACK;
           RETURN;
        END IF;
    END;
    p_err_code:=0;
    plog.setendsection(pkgctx, 'pr_InternalTransfer');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on pr_InternalTransfer');
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_InternalTransfer');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_InternalTransfer;


---------------------------------pr_ExternalTransfer------------------------------------------------
  PROCEDURE pr_ExternalTransfer(p_account varchar,p_bankid varchar2,p_benefbank varchar2,p_benefacct varchar2,p_benefcustname varchar2,p_beneflicense varchar2, p_amount number,p_feeamt number,p_vatamt number,p_desc varchar2,p_err_code  OUT varchar2,p_txdate  OUT varchar2,p_txnum  OUT varchar2)
  IS
      l_txmsg               tx.msg_rectype;
      v_strCURRDATE varchar2(20);
      l_err_param varchar2(300);

  BEGIN
    plog.setbeginsection(pkgctx, 'pr_ExternalTransfer');
    SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO v_strCURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    l_txmsg.msgtype:='T';
    l_txmsg.local:='N';
    l_txmsg.tlid        := systemnums.c_system_userid;
    SELECT SYS_CONTEXT ('USERENV', 'HOST'),
             SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
      INTO l_txmsg.wsname, l_txmsg.ipaddress
    FROM DUAL;
    l_txmsg.off_line    := 'N';
    l_txmsg.deltd       := txnums.c_deltd_txnormal;
    l_txmsg.txstatus    := txstatusnums.c_txcompleted;
    l_txmsg.msgsts      := '0';
    l_txmsg.ovrsts      := '0';
    l_txmsg.batchname   := 'INT';
    l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.busdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.tltxcd:='1101';

    --Set txnum
    SELECT systemnums.C_BATCH_PREFIXED
                     || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
              INTO l_txmsg.txnum
              FROM DUAL;
    l_txmsg.brid        := substr(p_account,1,4);

  p_txnum:=l_txmsg.txnum;
  p_txdate:=l_txmsg.txdate;
  --Set cac field giao dich
    --03   ACCTNO          C
    l_txmsg.txfields ('03').defname   := 'ACCTNO';
    l_txmsg.txfields ('03').TYPE      := 'C';
    l_txmsg.txfields ('03').VALUE     := p_account;
    --05   BANKID          C
    l_txmsg.txfields ('05').defname   := 'BANKID';
    l_txmsg.txfields ('05').TYPE      := 'C';
    l_txmsg.txfields ('05').VALUE     := p_bankid;
    --09   IORO            C
    l_txmsg.txfields ('09').defname   := 'IORO';
    l_txmsg.txfields ('09').TYPE      := 'C';
    l_txmsg.txfields ('09').VALUE     := 0;
    --10   TRFAMT          N
    l_txmsg.txfields ('10').defname   := 'TRFAMT';
    l_txmsg.txfields ('10').TYPE      := 'N';
    l_txmsg.txfields ('10').VALUE     := round(p_amount,0)-round(p_feeamt,0)-round(p_vatamt,0);
    --11   FEEAMT          N
    l_txmsg.txfields ('11').defname   := 'FEEAMT';
    l_txmsg.txfields ('11').TYPE      := 'N';
    l_txmsg.txfields ('11').VALUE     := round(p_feeamt,0);
    --12   VATAMT          N
    l_txmsg.txfields ('12').defname   := 'VATAMT';
    l_txmsg.txfields ('12').TYPE      := 'N';
    l_txmsg.txfields ('12').VALUE     := round(p_vatamt,0);
    --13   AMT             N
    l_txmsg.txfields ('13').defname   := 'AMT';
    l_txmsg.txfields ('13').TYPE      := 'N';
    l_txmsg.txfields ('13').VALUE     := round(p_amount,0);
    --30   DESC            C
    l_txmsg.txfields ('30').defname   := 'DESC';
    l_txmsg.txfields ('30').TYPE      := 'C';
    l_txmsg.txfields ('30').VALUE :=p_desc;
    --80   BENEFBANK       C --Ten ngan hang thu huong
    l_txmsg.txfields ('80').defname   := 'BENEFBANK';
    l_txmsg.txfields ('80').TYPE      := 'C';
    l_txmsg.txfields ('80').VALUE :=p_benefbank;
    --81   BENEFACCT       C --So tai khoan thu huong
    l_txmsg.txfields ('81').defname   := 'BENEFACCT';
    l_txmsg.txfields ('81').TYPE      := 'C';
    l_txmsg.txfields ('81').VALUE :=p_benefacct;
    --82   BENEFCUSTNAME   C
    l_txmsg.txfields ('82').defname   := 'BENEFCUSTNAME';
    l_txmsg.txfields ('82').TYPE      := 'C';
    l_txmsg.txfields ('82').VALUE :=p_benefcustname;
    --83   BENEFLICENSE    C
    l_txmsg.txfields ('83').defname   := 'BENEFLICENSE';
    l_txmsg.txfields ('83').TYPE      := 'C';
    l_txmsg.txfields ('83').VALUE :=p_beneflicense;
    --88   CUSTODYCD   C
    l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
    l_txmsg.txfields ('88').TYPE      := 'C';
    l_txmsg.txfields ('88').VALUE :='';
    --89   AVLCASH         N
    l_txmsg.txfields ('89').defname   := 'AVLCASH';
    l_txmsg.txfields ('89').TYPE      := 'N';
    l_txmsg.txfields ('89').VALUE :=0;
    --90   CUSTNAME        C
    l_txmsg.txfields ('90').defname   := 'CUSTNAME';
    l_txmsg.txfields ('90').TYPE      := 'C';
    l_txmsg.txfields ('90').VALUE :='';
    --91   ADDRESS         C
    l_txmsg.txfields ('91').defname   := 'ADDRESS';
    l_txmsg.txfields ('91').TYPE      := 'C';
    l_txmsg.txfields ('91').VALUE :='';
    --92   LICENSE         C
    l_txmsg.txfields ('92').defname   := 'LICENSE';
    l_txmsg.txfields ('92').TYPE      := 'C';
    l_txmsg.txfields ('92').VALUE :='';
    --93   IDDATE          C
    l_txmsg.txfields ('93').defname   := 'IDDATE';
    l_txmsg.txfields ('93').TYPE      := 'C';
    l_txmsg.txfields ('93').VALUE :='';
    --94   IDPLACE         C
    l_txmsg.txfields ('94').defname   := 'IDPLACE';
    l_txmsg.txfields ('94').TYPE      := 'C';
    l_txmsg.txfields ('94').VALUE :='';
    --95   BENEFIDDATE     C
    l_txmsg.txfields ('95').defname   := 'BENEFIDDATE';
    l_txmsg.txfields ('95').TYPE      := 'C';
    l_txmsg.txfields ('95').VALUE :='';
    --96   BENEFIDPLACE    C
    l_txmsg.txfields ('96').defname   := 'BENEFIDPLACE';
    l_txmsg.txfields ('96').TYPE      := 'C';
    l_txmsg.txfields ('96').VALUE :='';
    --97   LICENSE    C
    l_txmsg.txfields ('97').defname   := 'LICENSE';
    l_txmsg.txfields ('97').TYPE      := 'C';
    l_txmsg.txfields ('97').VALUE :='';
    --98   IDDATE    C
    l_txmsg.txfields ('98').defname   := 'IDDATE';
    l_txmsg.txfields ('98').TYPE      := 'C';
    l_txmsg.txfields ('98').VALUE :='';
    --99   IDPLACE    C
    l_txmsg.txfields ('99').defname   := 'IDPLACE';
    l_txmsg.txfields ('99').TYPE      := 'C';
    l_txmsg.txfields ('99').VALUE :='';
    --66   FEECD    C
    l_txmsg.txfields ('66').defname   := '$FEECD';
    l_txmsg.txfields ('66').TYPE      := 'C';
    l_txmsg.txfields ('66').VALUE :='';
    --79   REFID    C
    l_txmsg.txfields ('79').defname   := 'REFID';
    l_txmsg.txfields ('79').TYPE      := 'C';
    l_txmsg.txfields ('79').VALUE :='';

    BEGIN
        IF txpks_#1101.fn_autotxprocess (l_txmsg,
                                         p_err_code,
                                         l_err_param
           ) <> systemnums.c_success
        THEN
           plog.debug (pkgctx,
                       'got error 1101: ' || p_err_code
           );
           ROLLBACK;
           RETURN;
        END IF;
    END;
    p_err_code:=0;
    plog.setendsection(pkgctx, 'pr_ExternalTransfer');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on pr_ExternalTransfer');
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_ExternalTransfer');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_ExternalTransfer;

  ---------------------------------pr_ReceiveTransfer------------------------------------------------
  PROCEDURE pr_ReceiveTransfer(p_account varchar,p_bankid varchar2,p_bankacctno varchar2, p_glmast varchar2,p_refnum varchar2,p_amount number,p_desc varchar2,p_err_code  OUT varchar2,p_txdate  OUT varchar2,p_txnum  OUT varchar2)
  IS
      l_txmsg               tx.msg_rectype;
      v_strCURRDATE varchar2(20);
      l_err_param varchar2(300);

  BEGIN
    plog.setbeginsection(pkgctx, 'pr_ReceiveTransfer');
    SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO v_strCURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    l_txmsg.msgtype:='T';
    l_txmsg.local:='N';
    l_txmsg.tlid        := systemnums.c_system_userid;
    SELECT SYS_CONTEXT ('USERENV', 'HOST'),
             SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
      INTO l_txmsg.wsname, l_txmsg.ipaddress
    FROM DUAL;
    l_txmsg.off_line    := 'N';
    l_txmsg.deltd       := txnums.c_deltd_txnormal;
    l_txmsg.txstatus    := txstatusnums.c_txcompleted;
    l_txmsg.msgsts      := '0';
    l_txmsg.ovrsts      := '0';
    l_txmsg.batchname   := 'INT';
    l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.busdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.tltxcd:='1141';

    --Set txnum
    SELECT systemnums.C_BATCH_PREFIXED
                     || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
              INTO l_txmsg.txnum
              FROM DUAL;
    l_txmsg.brid        := substr(p_account,1,4);

    p_txnum:=l_txmsg.txnum;
    p_txdate:=l_txmsg.txdate;
  --Set cac field giao dich
    --03   ACCTNO          C
    l_txmsg.txfields ('03').defname   := 'ACCTNO';
    l_txmsg.txfields ('03').TYPE      := 'C';
    l_txmsg.txfields ('03').VALUE     := p_account;
    --02   BANKID          C
    l_txmsg.txfields ('02').defname   := 'BANKID';
    l_txmsg.txfields ('02').TYPE      := 'C';
    l_txmsg.txfields ('02').VALUE     := p_bankid;

    --05   BANKID          C
    l_txmsg.txfields ('05').defname   := 'BANKACCTNO';
    l_txmsg.txfields ('05').TYPE      := 'C';
    l_txmsg.txfields ('05').VALUE     := p_bankacctno;

    --06   GLMAST          C
    l_txmsg.txfields ('06').defname   := 'GLMAST';
    l_txmsg.txfields ('06').TYPE      := 'C';
    l_txmsg.txfields ('06').VALUE     := p_glmast;

    --10   AMT          N
    l_txmsg.txfields ('10').defname   := 'AMT';
    l_txmsg.txfields ('10').TYPE      := 'N';
    l_txmsg.txfields ('10').VALUE     := round(p_amount,0);

    --30   DESC            C
    l_txmsg.txfields ('30').defname   := 'DESC';
    l_txmsg.txfields ('30').TYPE      := 'C';
    l_txmsg.txfields ('30').VALUE :=p_desc;

    --31   REFNUM            C
    l_txmsg.txfields ('31').defname   := 'REFNUM';
    l_txmsg.txfields ('31').TYPE      := 'C';
    l_txmsg.txfields ('31').VALUE :=p_refnum;

    --82   CUSTODYCD   C
    l_txmsg.txfields ('82').defname   := 'CUSTODYCD';
    l_txmsg.txfields ('82').TYPE      := 'C';
    l_txmsg.txfields ('82').VALUE :='';

    --90   CUSTNAME        C
    l_txmsg.txfields ('90').defname   := 'CUSTNAME';
    l_txmsg.txfields ('90').TYPE      := 'C';
    l_txmsg.txfields ('90').VALUE :='';
    --91   ADDRESS         C
    l_txmsg.txfields ('91').defname   := 'ADDRESS';
    l_txmsg.txfields ('91').TYPE      := 'C';
    l_txmsg.txfields ('91').VALUE :='';
    --92   LICENSE         C
    l_txmsg.txfields ('92').defname   := 'LICENSE';
    l_txmsg.txfields ('92').TYPE      := 'C';
    l_txmsg.txfields ('92').VALUE :='';
    --93   IDDATE          C
    l_txmsg.txfields ('93').defname   := 'IDDATE';
    l_txmsg.txfields ('93').TYPE      := 'C';
    l_txmsg.txfields ('93').VALUE :='';
    --94   IDPLACE         C
    l_txmsg.txfields ('94').defname   := 'IDPLACE';
    l_txmsg.txfields ('94').TYPE      := 'C';
    l_txmsg.txfields ('94').VALUE :='';

    BEGIN
        IF txpks_#1141.fn_autotxprocess (l_txmsg,
                                         p_err_code,
                                         l_err_param
           ) <> systemnums.c_success
        THEN
           plog.debug (pkgctx,
                       'got error 1141: ' || p_err_code
           );
           ROLLBACK;
           RETURN;
        END IF;
    END;
    p_err_code:=0;
    plog.setendsection(pkgctx, 'pr_ReceiveTransfer');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on pr_ReceiveTransfer');
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_ReceiveTransfer');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_ReceiveTransfer;


   ---------------------------------pr_AllocateGuarantee------------------------------------------------
  PROCEDURE pr_AllocateGuarantee(p_account varchar,p_amount number,p_desc varchar2,p_err_code  OUT varchar2,p_txdate  OUT varchar2,p_txnum  OUT varchar2)
  IS
      l_txmsg               tx.msg_rectype;
      v_strCURRDATE varchar2(20);
      l_err_param varchar2(300);

  BEGIN
    plog.setbeginsection(pkgctx, 'pr_AllocateGuarantee');
    SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO v_strCURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    l_txmsg.msgtype:='T';
    l_txmsg.local:='N';
    l_txmsg.tlid        := systemnums.c_system_userid;
    SELECT SYS_CONTEXT ('USERENV', 'HOST'),
             SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
      INTO l_txmsg.wsname, l_txmsg.ipaddress
    FROM DUAL;
    l_txmsg.off_line    := 'N';
    l_txmsg.deltd       := txnums.c_deltd_txnormal;
    l_txmsg.txstatus    := txstatusnums.c_txcompleted;
    l_txmsg.msgsts      := '0';
    l_txmsg.ovrsts      := '0';
    l_txmsg.batchname   := 'INT';
    l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.busdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.tltxcd:='1158';

    --Set txnum
    SELECT systemnums.C_BATCH_PREFIXED
                     || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
              INTO l_txmsg.txnum
              FROM DUAL;
    l_txmsg.brid        := substr(p_account,1,4);

  p_txnum:=l_txmsg.txnum;
  p_txdate:=l_txmsg.txdate;
  --Set cac field giao dich
    --03   ACCTNO          C
    l_txmsg.txfields ('03').defname   := 'ACCTNO';
    l_txmsg.txfields ('03').TYPE      := 'C';
    l_txmsg.txfields ('03').VALUE     := p_account;

    --10   AMT          N
    l_txmsg.txfields ('10').defname   := 'AMT';
    l_txmsg.txfields ('10').TYPE      := 'N';
    l_txmsg.txfields ('10').VALUE     := round(p_amount,0);

    --30   DESC            C
    l_txmsg.txfields ('30').defname   := 'DESC';
    l_txmsg.txfields ('30').TYPE      := 'C';
    l_txmsg.txfields ('30').VALUE :=p_desc;

    BEGIN
        IF txpks_#1158.fn_autotxprocess (l_txmsg,
                                         p_err_code,
                                         l_err_param
           ) <> systemnums.c_success
        THEN
           plog.debug (pkgctx,
                       'got error 1158: ' || p_err_code
           );
           ROLLBACK;
           RETURN;
        END IF;
    END;
    p_err_code:=0;
    plog.setendsection(pkgctx, 'pr_AllocateGuarantee');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on pr_AllocateGuarantee');
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_AllocateGuarantee');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_AllocateGuarantee;

---------------------------------pr_RightoffRegiter------------------------------------------------
  PROCEDURE pr_RightoffRegiter(p_camastid varchar,p_account varchar,p_qtty number,p_desc varchar2,p_err_code  OUT varchar2,p_txdate  OUT varchar2,p_txnum  OUT varchar2)
  IS
      l_txmsg               tx.msg_rectype;
      v_strCURRDATE varchar2(20);
      l_err_param varchar2(300);
      l_symbol  varchar2(20);
      l_codeid   varchar2(20);
      l_exprice number;
      l_optcodeid varchar2(20);
      l_iscorebank  number;
      l_balance number;
      l_caschdautoid NUMBER;
    l_maxqtty NUMBER;
    l_parvalue NUMBER;
  BEGIN
    plog.setbeginsection(pkgctx, 'pr_RightoffRegiter');
    SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO v_strCURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    l_txmsg.msgtype:='T';
    l_txmsg.local:='N';
    l_txmsg.tlid        := systemnums.c_system_userid;
    SELECT SYS_CONTEXT ('USERENV', 'HOST'),
             SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
      INTO l_txmsg.wsname, l_txmsg.ipaddress
    FROM DUAL;
    l_txmsg.off_line    := 'N';
    l_txmsg.deltd       := txnums.c_deltd_txnormal;
    l_txmsg.txstatus    := txstatusnums.c_txcompleted;
    l_txmsg.msgsts      := '0';
    l_txmsg.ovrsts      := '0';
    l_txmsg.batchname   := 'INT';
    l_txmsg.txdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.busdate:=to_date(v_strCURRDATE,systemnums.c_date_format);
    l_txmsg.tltxcd:='3384';

    --Set txnum
    SELECT systemnums.C_BATCH_PREFIXED
                     || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
              INTO l_txmsg.txnum
              FROM DUAL;
    l_txmsg.brid        := substr(p_account,1,4);

  p_txnum:=l_txmsg.txnum;
  p_txdate:=l_txmsg.txdate;

  select ca.autoid, b.SYMBOL,a.exprice,a.codeid,optcodeid,CA.balance + CA.pbalance balance, ca.pqtty,a.parvalue,
        (case when ci.corebank ='Y' then 0 else 1 end) iscorebank
    into l_caschdautoid,l_symbol,l_exprice , l_codeid,l_optcodeid,l_balance,l_maxqtty, l_parvalue,l_iscorebank
  from camast a, caschd ca, sbsecurities b,cimast ci
        where a.codeid = b.codeid and a.camastid=p_camastid and ca.camastid=a.camastid
        and ca.afacctno=p_account
        and ci.acctno=ca.afacctno;

    --Set cac field giao dich
    --01   AUTOID      C
    l_txmsg.txfields ('01').defname   := 'AUTOID';
    l_txmsg.txfields ('01').TYPE      := 'C';
    l_txmsg.txfields ('01').VALUE     := to_char(nvl(l_caschdautoid,''));
    --02   CAMASTID      C
    l_txmsg.txfields ('02').defname   := 'CAMASTID';
    l_txmsg.txfields ('02').TYPE      := 'C';
    l_txmsg.txfields ('02').VALUE     := p_camastid;
    --03   AFACCTNO      C
    l_txmsg.txfields ('03').defname   := 'AFACCTNO';
    l_txmsg.txfields ('03').TYPE      := 'C';
    l_txmsg.txfields ('03').VALUE     := p_account;
    --06   SEACCTNO      C
    l_txmsg.txfields ('06').defname   := 'SEACCTNO';
    l_txmsg.txfields ('06').TYPE      := 'C';
    l_txmsg.txfields ('06').VALUE     := p_account || l_codeid;
    --08   FULLNAME      C
    l_txmsg.txfields ('08').defname   := 'FULLNAME';
    l_txmsg.txfields ('08').TYPE      := 'C';
    l_txmsg.txfields ('08').VALUE     := '';
    --09   OPTSEACCTNO   C
    l_txmsg.txfields ('09').defname   := 'OPTSEACCTNO';
    l_txmsg.txfields ('09').TYPE      := 'C';
    l_txmsg.txfields ('09').VALUE     := p_account || l_optcodeid;
    --04   SYMBOL        C
    l_txmsg.txfields ('04').defname   := 'SYMBOL';
    l_txmsg.txfields ('04').TYPE      := 'C';
    l_txmsg.txfields ('04').VALUE     := l_symbol;
    --05   EXPRICE       N
    l_txmsg.txfields ('05').defname   := 'EXPRICE';
    l_txmsg.txfields ('05').TYPE      := 'N';
    l_txmsg.txfields ('05').VALUE     := l_exprice;
    --07   BALANCE       N
    l_txmsg.txfields ('07').defname   := 'BALANCE';
    l_txmsg.txfields ('07').TYPE      := 'N';
    l_txmsg.txfields ('07').VALUE     := 0;
    --20   MAXQTTY          N
    l_txmsg.txfields ('20').defname   := 'MAXQTTY';
    l_txmsg.txfields ('20').TYPE      := 'N';
    l_txmsg.txfields ('20').VALUE     := l_maxqtty;
    --21   QTTY          N
    l_txmsg.txfields ('21').defname   := 'QTTY';
    l_txmsg.txfields ('21').TYPE      := 'N';
    l_txmsg.txfields ('21').VALUE     := p_qtty;
    --22   PARVALUE          N
    l_txmsg.txfields ('22').defname   := 'PARVALUE';
    l_txmsg.txfields ('22').TYPE      := 'N';
    l_txmsg.txfields ('22').VALUE     := l_parvalue;
    --23   REPORTDATE          N
    l_txmsg.txfields ('23').defname   := 'REPORTDATE';
    l_txmsg.txfields ('23').TYPE      := 'C';
    l_txmsg.txfields ('23').VALUE     := '';
    --30   DESCRIPTION   C
    l_txmsg.txfields ('30').defname   := 'DESCRIPTION';
    l_txmsg.txfields ('30').TYPE      := 'C';
    l_txmsg.txfields ('30').VALUE :=p_desc;
    --16   TASKCD        C
    l_txmsg.txfields ('16').defname   := 'TASKCD';
    l_txmsg.txfields ('16').TYPE      := 'C';
    l_txmsg.txfields ('16').VALUE     := '';
    --40   STATUS        C
    l_txmsg.txfields ('40').defname   := 'STATUS';
    l_txmsg.txfields ('40').TYPE      := 'C';
    l_txmsg.txfields ('40').VALUE :='M';
    --60   ISCOREBANK        C
    l_txmsg.txfields ('60').defname   := 'ISCOREBANK';
    l_txmsg.txfields ('60').TYPE      := 'N';
    l_txmsg.txfields ('60').VALUE :=l_iscorebank;
    --90   CUSTNAME    C
    l_txmsg.txfields ('90').defname   := 'CUSTNAME';
    l_txmsg.txfields ('90').TYPE      := 'C';
    l_txmsg.txfields ('90').VALUE :='';
    --91   ADDRESS     C
    l_txmsg.txfields ('91').defname   := 'ADDRESS';
    l_txmsg.txfields ('91').TYPE      := 'C';
    l_txmsg.txfields ('91').VALUE :='';
    --92   LICENSE     C
    l_txmsg.txfields ('92').defname   := 'LICENSE';
    l_txmsg.txfields ('92').TYPE      := 'C';
    l_txmsg.txfields ('92').VALUE :='';
    --93   IDDATE    C
    l_txmsg.txfields ('93').defname   := 'IDDATE';
    l_txmsg.txfields ('93').TYPE      := 'C';
    l_txmsg.txfields ('93').VALUE :='';
    --94   IDPLACE    C
    l_txmsg.txfields ('94').defname   := 'IDPLACE';
    l_txmsg.txfields ('94').TYPE      := 'C';
    l_txmsg.txfields ('94').VALUE :='';
    --95   ISSNAME    C
    l_txmsg.txfields ('95').defname   := 'ISSNAME';
    l_txmsg.txfields ('95').TYPE      := 'C';
    l_txmsg.txfields ('95').VALUE :='';
    --96   CUSTODYCD    C
    l_txmsg.txfields ('96').defname   := 'CUSTODYCD';
    l_txmsg.txfields ('96').TYPE      := 'C';
    l_txmsg.txfields ('96').VALUE :='';
    --10   AMT          N
    l_txmsg.txfields ('10').defname   := 'AMT';
    l_txmsg.txfields ('10').TYPE      := 'N';
    l_txmsg.txfields ('10').VALUE     := round(nvl(p_qtty,0) * nvl(l_exprice,0),0);

    BEGIN
        IF txpks_#3384.fn_autotxprocess (l_txmsg,
                                         p_err_code,
                                         l_err_param
           ) <> systemnums.c_success
        THEN
           plog.debug (pkgctx,
                       'got error 3384: ' || p_err_code
           );
           ROLLBACK;
           RETURN;
        END IF;
    END;
    p_err_code:=0;
    plog.setendsection(pkgctx, 'pr_RightoffRegiter');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on pr_RightoffRegiter');
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_RightoffRegiter');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_RightoffRegiter;



---------------------------------pr_InternalTransfer------------------------------------------------
  PROCEDURE pr_RevertTransfer(p_tltxcd IN VARCHAR2,p_txdate IN  varchar2,p_txnum IN  VARCHAR2,p_err_code  OUT varchar2)
  IS
      l_err_param varchar2(300);

  BEGIN
    plog.setbeginsection(pkgctx, 'pr_RevertTransfer');

    BEGIN
        IF p_tltxcd = '1120' THEN
            IF txpks_#1120.fn_txrevert(p_txnum, p_txdate, p_err_code, l_err_param) <> systemnums.c_success
            THEN
               plog.debug (pkgctx,
                           'got error 1120 revert: ' || p_err_code
               );
               ROLLBACK;
               RETURN;
            END IF;
        ELSE
            IF txpks_#1101.fn_txrevert(p_txnum, p_txdate, p_err_code, l_err_param) <> systemnums.c_success
            THEN
               plog.debug (pkgctx,
                           'got error 1101 revert: ' || p_err_code
               );
               ROLLBACK;
               RETURN;
            END IF;
        END IF;
    END;
    p_err_code:=0;
    plog.setendsection(pkgctx, 'pr_InternalTransfer');
  EXCEPTION
  WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on pr_InternalTransfer');
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_InternalTransfer');
      RAISE errnums.E_SYSTEM_ERROR;
  END pr_RevertTransfer;



PROCEDURE pr_WithdrawTermDeposit(p_acctno varchar2,p_amount number,p_err_code  OUT varchar2,p_txdate  OUT varchar2,p_txnum  OUT varchar2)
IS
    --p_err_code in this procedure mean
    --=1: Tai khoan khong ton tai
    --=2: So tien rut phai lon hon 0
    --=3: So tien rut phai nho hon du goc hien tai
      l_txmsg               tx.msg_rectype;
      l_err_param varchar2(300);
      v_fullname varchar2(300);
      v_address varchar2(300);
      v_idcode  varchar2(300);
      v_count number;
      v_dtCURRDATE date;
  BEGIN
    plog.setbeginsection(pkgctx, 'pr_WithdrawTermDeposit');
    SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO v_dtCURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    l_txmsg.msgtype:='T';
    l_txmsg.local:='N';
    l_txmsg.tlid        := systemnums.c_system_userid;
    SELECT SYS_CONTEXT ('USERENV', 'HOST'),
             SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
      INTO l_txmsg.wsname, l_txmsg.ipaddress
    FROM DUAL;
    l_txmsg.off_line    := 'N';
    l_txmsg.deltd       := txnums.c_deltd_txnormal;
    l_txmsg.txstatus    := txstatusnums.c_txcompleted;
    l_txmsg.msgsts      := '0';
    l_txmsg.ovrsts      := '0';
    l_txmsg.batchname   := 'INT';
    l_txmsg.txdate:=v_dtCURRDATE;
    l_txmsg.busdate:=v_dtCURRDATE;
    l_txmsg.tltxcd:='1600';
    v_count:=0;
    for rec in (
        SELECT MST.ACCTNO, MST.AFACCTNO, CF.CUSTODYCD, CF.FULLNAME,
            MST.ORGAMT, MST.BALANCE, MST.PRINTPAID, MST.INTNMLACR, MST.INTPAID, MST.TAXRATE, MST.BONUSRATE, MST.INTRATE, MST.TDTERM, MST.OPNDATE, MST.FRDATE, MST.TODATE,
            FN_TDMASTINTRATIO(MST.ACCTNO,TO_DATE(SYSVAR.VARVALUE,'DD/MM/YYYY'),MST.BALANCE) INTAVLAMT, MST.BALANCE-MST.MORTGAGE AVLWITHDRAW, MST.MORTGAGE,MST.CUSTBANK,
            A0.CDCONTENT DESC_TDSRC, A1.CDCONTENT DESC_AUTOPAID, A2.CDCONTENT DESC_BREAKCD, A3.CDCONTENT DESC_SCHDTYPE, A4.CDCONTENT DESC_TERMCD, A5.CDCONTENT DESC_STATUS
        FROM TDMAST MST, AFMAST AF, CFMAST CF, TDTYPE TYP, ALLCODE A0, ALLCODE A1, ALLCODE A2, ALLCODE A3, ALLCODE A4, ALLCODE A5, SYSVAR
        WHERE MST.ACTYPE=TYP.ACTYPE AND MST.AFACCTNO=AF.ACCTNO AND AF.CUSTID=CF.CUSTID AND SYSVAR.VARNAME='CURRDATE'
            AND MST.DELTD<>'Y' AND MST.status in ('N','A')
            AND A0.CDTYPE='TD' AND A0.CDNAME='TDSRC' AND MST.TDSRC=A0.CDVAL
            AND A1.CDTYPE='SY' AND A1.CDNAME='YESNO' AND MST.AUTOPAID=A1.CDVAL
            AND A2.CDTYPE='SY' AND A2.CDNAME='YESNO' AND MST.BREAKCD=A2.CDVAL
            AND A4.CDTYPE='TD' AND A4.CDNAME='TERMCD' AND MST.TERMCD=A4.CDVAL
            AND A5.CDTYPE='TD' AND A5.CDNAME='STATUS' AND MST.STATUS=A5.CDVAL
            AND A3.CDTYPE='TD' AND A3.CDNAME='SCHDTYPE' AND MST.SCHDTYPE=A3.CDVAL
            AND MST.ACCTNO=p_acctno
    )
    loop
        v_count:=v_count+1;
        --Set txnum
        SELECT systemnums.C_BATCH_PREFIXED
                         || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;
        l_txmsg.brid        := substr(rec.afacctno,1,4);

        p_txnum:=l_txmsg.txnum;
        p_txdate:=l_txmsg.txdate;

        --03    C   ACCTNO
        l_txmsg.txfields ('03').defname   := 'ACCTNO';
        l_txmsg.txfields ('03').TYPE      := 'C';
        l_txmsg.txfields ('03').VALUE     := rec.ACCTNO;
        --05    C   AFACCTNO
        l_txmsg.txfields ('05').defname   := 'AFACCTNO';
        l_txmsg.txfields ('05').TYPE      := 'C';
        l_txmsg.txfields ('05').VALUE     := rec.AFACCTNO;
        --09    N   BALANCE
        l_txmsg.txfields ('09').defname   := 'BALANCE';
        l_txmsg.txfields ('09').TYPE      := 'N';
        l_txmsg.txfields ('09').VALUE     := rec.BALANCE;
        --10    N   AMT
        l_txmsg.txfields ('10').defname   := 'AMT';
        l_txmsg.txfields ('10').TYPE      := 'N';
        l_txmsg.txfields ('10').VALUE     := p_amount;
        --11    N   INTAMT
        l_txmsg.txfields ('11').defname   := 'INTAMT';
        l_txmsg.txfields ('11').TYPE      := 'N';
        l_txmsg.txfields ('11').VALUE     := fn_tdmastintratio(rec.ACCTNO,v_dtCURRDATE,p_amount);
        --12    N   INTAVLAMT
        l_txmsg.txfields ('12').defname   := 'INTAVLAMT';
        l_txmsg.txfields ('12').TYPE      := 'N';
        l_txmsg.txfields ('12').VALUE     := rec.INTAVLAMT;
        --13    N   MORTGAGE
        l_txmsg.txfields ('13').defname   := 'MORTGAGE';
        l_txmsg.txfields ('13').TYPE      := 'N';
        l_txmsg.txfields ('13').VALUE     := rec.MORTGAGE;
        --15    N   DIRECTAMT
        l_txmsg.txfields ('15').defname   := 'DIRECTAMT';
        l_txmsg.txfields ('15').TYPE      := 'N';
        l_txmsg.txfields ('15').VALUE     := GREATEST(LEAST(l_txmsg.txfields ('09').VALUE-l_txmsg.txfields ('13').VALUE,p_amount),0);
        --30    C   DESC
        l_txmsg.txfields ('30').defname   := 'DESC';
        l_txmsg.txfields ('30').TYPE      := 'C';
        l_txmsg.txfields ('30').VALUE     := 'Rut tien tiet kiem online';

        --32  TODATE      C
          l_txmsg.txfields ('32').defname   := 'TODATE';
          l_txmsg.txfields ('32').TYPE      := 'D';
          l_txmsg.txfields ('32').VALUE     := rec.TODATE;
          --31  INTRATE      N
          l_txmsg.txfields ('31').defname   := 'INTRATE';
          l_txmsg.txfields ('31').TYPE      := 'N';
          l_txmsg.txfields ('31').VALUE     := rec.INTRATE;
          --33  CUSTBANK      C
          l_txmsg.txfields ('33').defname   := 'CUSTBANK';
          l_txmsg.txfields ('33').TYPE      := 'C';
          l_txmsg.txfields ('33').VALUE     := rec.CUSTBANK;


        plog.debug(pkgctx, 'field 10:' || l_txmsg.txfields ('10').VALUE);
        plog.debug(pkgctx, 'field 09:' || l_txmsg.txfields ('09').VALUE);
        if not (l_txmsg.txfields ('10').VALUE>0) then
            p_err_code:='625'; --So tien RUT phai lon hon 0
            return;
        end if;
        if not (to_number(l_txmsg.txfields ('10').VALUE)<=to_number(l_txmsg.txfields ('09').VALUE)) then
            p_err_code:='626'; --Lai suat gui khong hop le
            return;
        end if;

        BEGIN
            IF txpks_#1600.fn_autotxprocess (l_txmsg,
                                             p_err_code,
                                             l_err_param
               ) <> systemnums.c_success
            THEN
               plog.debug (pkgctx,
                           'got error 1670: ' || p_err_code
               );
               ROLLBACK;
               RETURN;
            END IF;
        END;
    end loop;
    if v_count<>1 then
        p_err_code:='627';
        return;
    end if;
    p_err_code:=0;
    plog.setendsection(pkgctx, 'pr_WithdrawTermDeposit');
EXCEPTION
  WHEN OTHERS
   THEN
      plog.debug (pkgctx,'got error on pr_WithdrawTermDeposit');
      ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'pr_WithdrawTermDeposit');
      RAISE errnums.E_SYSTEM_ERROR;
END pr_WithdrawTermDeposit;

PROCEDURE pr_gtc2od(pv_strFunctype varchar2)
IS
    l_count         NUMBER (10) := 0;
    p_err_code      varchar2(100);
    v_strTXDATE     varchar2(20);
    v_hostatus      varchar2(10);

    v_STR_GTC2OD_TIME   number(20);
    v_END_GTC2OD_TIME   number(20);
    V_CURRTIME          number(10);
BEGIN
    plog.setbeginsection (pkgctx, 'pr_gtc2od');
    plog.debug (pkgctx, 'BEGIN OF pr_gtc2od');
    plog.debug (pkgctx, 'pv_strFunctype: ' || pv_strFunctype);
    SELECT      VARVALUE
        INTO        V_HOSTATUS
    FROM        SYSVAR
    WHERE       VARNAME = 'HOSTATUS';


    SELECT to_number(VARVALUE) into v_STR_GTC2OD_TIME
    FROM SYSVAR WHERE GRNAME = 'SYSTEM' AND VARNAME = 'STR_GTC2OD_TIME';

    SELECT to_number(VARVALUE) into v_END_GTC2OD_TIME
    FROM SYSVAR WHERE GRNAME = 'SYSTEM' AND VARNAME = 'END_GTC2OD_TIME';

    SELECT to_number(to_char(sysdate,'HH24MISS')) INTO V_CURRTIME FROM DUAL;


    IF V_HOSTATUS <> '1' THEN
        return;
    end if;

    if V_CURRTIME > v_STR_GTC2OD_TIME  and V_CURRTIME < v_END_GTC2OD_TIME then
        return ;
    end if;

    v_strTXDATE:=cspks_system.fn_get_sysvar('SYSTEM','CURRDATE');
    if pv_strFunctype = 'GTC-HO' then
        for rec in (
              SELECT * FROM
              (
                  SELECT MST.ACCTNO,MSt.ACTYPE,MSt.AFACCTNO,MSt.STATUS,MSt.EXECTYPE,MSt.PRICETYPE,MSt.TIMETYPE,
                              MSt.MATCHTYPE,MSt.NORK,MSt.CLEARCD,MSt.CLEARDAY,MSt.CODEID,MSt.SYMBOL,MSt.QUANTITY,
                              0 PRICE,MSt.QUOTEPRICE,MSt.TRIGGERPRICE,MSt.EXECQTTY,MSt.EXECAMT,MSt.REMAINQTTY,
                              MSt.CANCELQTTY,MSt.AMENDQTTY,MSt.CONFIRMEDVIA,MSt.BOOK,MSt.ORGACCTNO,MSt.REFACCTNO,
                              MSt.REFQUANTITY,MSt.REFPRICE,MSt.REFQUOTEPRICE,MSt.FEEDBACKMSG,MSt.ACTIVATEDT,
                              MSt.CREATEDDT,MSt.REFORDERID,MSt.REFUSERNAME,MSt.TXDATE,MSt.TXNUM,MSt.EFFDATE,
                              MSt.EXPDATE,MSt.BRATIO,MSt.VIA,MSt.DELTD,MSt.OUTPRICEALLOW,MSt.USERNAME,
                              SEC.TRADEPLACE, SEC.SECTYPE, SEC.PARVALUE, INF.TRADELOT,
                              INF.TRADEUNIT, INF.SECUREDRATIOMIN, INF.SECUREDRATIOMAX,INF.CEILINGPRICE,INF.FLOORPRICE,INF.MARGINPRICE
                    FROM FOMAST MST, SBSECURITIES SEC, SECURITIES_INFO INF, ordersys o, CFMAST CF, AFMAST AF --19/12/2022 TrungNQ CHECK THEM DIEU KIEN KICH HOAT VSD
                   WHERE MST.DELTD<>'Y' AND MST.BOOK = 'A' AND  MST.REMAINQTTY>0
                     AND MST.EXECTYPE IN ('NB','BC','CB') AND PRICETYPE<>'SL'
                     AND MST.TIMETYPE = 'G'
                     AND MST.STATUS = 'P'
                     AND MST.AFACCTNO = AF.ACCTNO
                     AND AF.CUSTID = CF.CUSTID
                     AND CF.ACTIVESTS = 'Y' --19/12/2022 TrungNQ CHECK THEM DIEU KIEN KICH HOAT VSD
                     AND SEC.HALT ='N'
                     AND MST.CODEID = SEC.CODEID
                     AND SEC.TRADEPLACE='001'
                     AND MST.CODEID = INF.CODEID
                     AND MST.EFFDATE <= to_date(v_strTxdate,'dd/mm/rrrr')
                     AND SYSNAME ='CONTROLCODE'
                     AND (
                           (o.SYSVALUE='O' AND PRICETYPE ='LO') or o.SYSVALUE <>'O'
                          )
                     AND CASE WHEN MST.EXECTYPE IN ('NB','BC') THEN
                                CHECKGTCBUYORDERNEW(mst.afacctno,MST.REMAINQTTY,
                                      (CASE WHEN PRICETYPE='LO' THEN MST.QUOTEPRICE
                                            ELSE INF.CEILINGPRICE/INF.TRADEUNIT
                                       END),
                                      MST.actype,SEC.codeid
                                )
                            ELSE 0 END >=0
                     AND CASE WHEN MST.EXECTYPE IN ('NB','BC') AND MST.PRICETYPE = 'LO'
                                THEN MST.QUOTEPRICE*INF.TRADEUNIT ELSE INF.CEILINGPRICE END <= INF.CEILINGPRICE
                     AND CASE WHEN MST.EXECTYPE IN ('NB','BC') AND MST.PRICETYPE = 'LO'
                                THEN MST.QUOTEPRICE*INF.TRADEUNIT ELSE INF.FLOORPRICE END >= INF.FLOORPRICE
                  UNION
                  SELECT MST.ACCTNO,MSt.ACTYPE,MSt.AFACCTNO,MSt.STATUS,MSt.EXECTYPE,PRICETYPE,MSt.TIMETYPE,
                              MSt.MATCHTYPE,MSt.NORK,MSt.CLEARCD,MSt.CLEARDAY,MSt.CODEID,MSt.SYMBOL,MSt.QUANTITY,
                              0 PRICE,MSt.QUOTEPRICE,MSt.TRIGGERPRICE,MSt.EXECQTTY,MSt.EXECAMT,MSt.REMAINQTTY,
                              MSt.CANCELQTTY,MSt.AMENDQTTY,MSt.CONFIRMEDVIA,MSt.BOOK,MSt.ORGACCTNO,MSt.REFACCTNO,
                              MSt.REFQUANTITY,MSt.REFPRICE,MSt.REFQUOTEPRICE,MSt.FEEDBACKMSG,MSt.ACTIVATEDT,
                              MSt.CREATEDDT,MSt.REFORDERID,MSt.REFUSERNAME,MSt.TXDATE,MSt.TXNUM,MSt.EFFDATE,
                              MSt.EXPDATE,MSt.BRATIO,MSt.VIA,MSt.DELTD,MSt.OUTPRICEALLOW,MSt.USERNAME,
                              SEC.TRADEPLACE, SEC.SECTYPE, SEC.PARVALUE, INF.TRADELOT,
                         INF.TRADEUNIT, INF.SECUREDRATIOMIN, INF.SECUREDRATIOMAX,INF.CEILINGPRICE,INF.FLOORPRICE,INF.MARGINPRICE
                           FROM FOMAST MST, SBSECURITIES SEC, SECURITIES_INFO INF,SEMAST SE,v_getsellorderinfo V, ordersys o, CFMAST CF, AFMAST AF --19/12/2022 TrungNQ CHECK THEM DIEU KIEN KICH HOAT VSD
                   WHERE MST.DELTD<>'Y' AND MST.BOOK = 'A' AND  MST.REMAINQTTY>0
                     AND SE.ACCTNO=V.seacctno(+)
                     AND MST.EXECTYPE IN ('MS','SS','NS','CS')  AND PRICETYPE<>'SL'
                     AND MST.TIMETYPE = 'G'
                     AND MST.STATUS = 'P'
                     AND MST.AFACCTNO = AF.ACCTNO
                     AND AF.CUSTID = CF.CUSTID
                     AND CF.ACTIVESTS = 'Y' --19/12/2022 TrungNQ CHECK THEM DIEU KIEN KICH HOAT VSD
                     AND SEC.HALT ='N'
                     AND MST.CODEID = SEC.CODEID
                     AND SEC.TRADEPLACE='001'
                     AND MST.CODEID = INF.CODEID
                     AND MST.EFFDATE <= to_date(v_strTxdate,'dd/mm/rrrr')
                     AND SYSNAME ='CONTROLCODE'
                     AND (
                           (o.SYSVALUE='O' AND PRICETYPE ='LO') or o.SYSVALUE <>'O'
                          )
                     AND SE.ACCTNO =MST.AFACCTNO || MST.CODEID
                     AND (CASE WHEN MST.EXECTYPE='MS' THEN SE.MORTAGE-nvl(v.securemtg,0)
                                WHEN MST.exectype = 'CS' THEN MST.remainqtty
                                ELSE SE.TRADE-nvl(V.secureamt,0) END)  >= MST.REMAINQTTY
                     AND CASE WHEN MST.EXECTYPE IN ('MS','SS','NS') AND MST.PRICETYPE = 'LO'
                                THEN MST.QUOTEPRICE*INF.TRADEUNIT ELSE INF.CEILINGPRICE END <= INF.CEILINGPRICE
                     AND CASE WHEN MST.EXECTYPE IN ('MS','SS','NS') AND MST.PRICETYPE = 'LO'
                                THEN MST.QUOTEPRICE*INF.TRADEUNIT ELSE INF.FLOORPRICE END >= INF.FLOORPRICE
                 )
                 ORDER BY activatedt
           )
        loop
            SELECT count(1) into l_count from
            (select mst.acctno
                   FROM FOMAST MST, SBSECURITIES SEC, SECURITIES_INFO INF,CIMAST CI,v_getbuyorderinfo V
                  WHERE MST.DELTD<>'Y' AND MST.BOOK = 'A' AND  MST.REMAINQTTY>0 AND CI.ACCTNO=V.afacctno(+)
                    AND MST.EXECTYPE IN ('NB','BC','CB')
                    AND MST.TIMETYPE = 'G'
                    AND MST.STATUS = 'P'
                    AND SEC.HALT ='N'
                    AND MST.CODEID = SEC.CODEID
                    AND MST.CODEID = INF.CODEID
                    AND CI.ACCTNO =MST.AFACCTNO
                    AND CASE WHEN MST.EXECTYPE IN ('NB','BC') THEN
                                    CHECKGTCBUYORDERNEW(mst.afacctno,MST.REMAINQTTY,
                                            (CASE WHEN PRICETYPE='LO' THEN MST.QUOTEPRICE
                                                  WHEN PRICETYPE='SL' THEN to_number(rec.QUOTEPRICE)
                                                  ELSE INF.CEILINGPRICE/INF.TRADEUNIT
                                             END),
                                                MST.actype,SEC.codeid
                                    )
                             ELSE 0 END >=0
                    AND MST.ACCTNO=rec.acctno
                 UNION
                 SELECT mst.acctno
                          FROM FOMAST MST, SBSECURITIES SEC, SECURITIES_INFO INF,SEMAST SE,v_getsellorderinfo V
                  WHERE MST.DELTD<>'Y' AND MST.BOOK = 'A' AND  MST.REMAINQTTY>0 AND SE.ACCTNO=V.seacctno(+)
                    AND MST.EXECTYPE IN ('MS','SS','NS','CS')
                    AND MST.TIMETYPE = 'G'
                    AND MST.STATUS = 'P'
                    AND SEC.HALT ='N'
                    AND MST.CODEID = SEC.CODEID
                    AND MST.CODEID = INF.CODEID
                    AND SE.ACCTNO =MST.AFACCTNO || MST.CODEID
                    AND (CASE WHEN MST.EXECTYPE='MS' THEN SE.MORTAGE-nvl(v.securemtg,0)
                                WHEN MST.exectype = 'CS' THEN MST.remainqtty
                                ELSE SE.TRADE-nvl(V.secureamt,0)+nvl(V.sereceiving,0) END)  >= MST.REMAINQTTY
                    AND MST.ACCTNO=rec.acctno);
             if l_count>0 THEN
                txpks_auto.pr_fo2odsyn(rec.acctno, p_err_code, 'G');
                commit;
             end if;
        end loop;

    elsif pv_strFuncType = 'GTC-HA' THEN
        for rec in (
              SELECT * FROM (SELECT MST.ACCTNO,MSt.ACTYPE,MSt.AFACCTNO,MSt.STATUS,MSt.EXECTYPE,PRICETYPE,MSt.TIMETYPE,
                          MSt.MATCHTYPE,MSt.NORK,MSt.CLEARCD,MSt.CLEARDAY,MSt.CODEID,MSt.SYMBOL,MSt.QUANTITY,
                          0 PRICE,MSt.QUOTEPRICE,MSt.TRIGGERPRICE,MSt.EXECQTTY,MSt.EXECAMT,MSt.REMAINQTTY,
                          MSt.CANCELQTTY,MSt.AMENDQTTY,MSt.CONFIRMEDVIA,MSt.BOOK,MSt.ORGACCTNO,MSt.REFACCTNO,
                          MSt.REFQUANTITY,MSt.REFPRICE,MSt.REFQUOTEPRICE,MSt.FEEDBACKMSG,MSt.ACTIVATEDT,
                          MSt.CREATEDDT,MSt.REFORDERID,MSt.REFUSERNAME,MSt.TXDATE,MSt.TXNUM,MSt.EFFDATE,
                          MSt.EXPDATE,MSt.BRATIO,MSt.VIA,MSt.DELTD,MSt.OUTPRICEALLOW,MSt.USERNAME,
                           SEC.TRADEPLACE, SEC.SECTYPE, SEC.PARVALUE, INF.TRADELOT,
                     INF.TRADEUNIT, INF.SECUREDRATIOMIN, INF.SECUREDRATIOMAX,INF.CEILINGPRICE,INF.FLOORPRICE,INF.MARGINPRICE
                FROM FOMAST MST, SBSECURITIES SEC, SECURITIES_INFO INF
               WHERE MST.DELTD<>'Y' AND MST.BOOK = 'A' AND  MST.REMAINQTTY>0
                 AND MST.EXECTYPE IN ('NB','BC','CB')  AND PRICETYPE<>'SL'
                 AND MST.TIMETYPE = 'G'
                 AND MST.STATUS = 'P'
                 AND SEC.HALT ='N'
                 AND MST.CODEID = SEC.CODEID
                 AND SEC.TRADEPLACE IN ('002','005')
                 AND MST.CODEID = INF.CODEID
                 AND MST.EFFDATE <= to_date(v_strtxdate,'dd/mm/rrrr')
                 AND CASE WHEN MST.EXECTYPE IN ('NB','BC') THEN
                            CHECKGTCBUYORDERNEW(mst.afacctno,MST.REMAINQTTY,
                                  (CASE WHEN PRICETYPE='LO' THEN MST.QUOTEPRICE
                                       ELSE INF.CEILINGPRICE/INF.TRADEUNIT
                                   END),
                                  MST.actype,SEC.codeid
                            )
                        ELSE 0 END >=0
                 AND CASE WHEN MST.EXECTYPE IN ('NB','BC') AND MST.PRICETYPE = 'LO'
                          THEN MST.QUOTEPRICE*INF.TRADEUNIT ELSE INF.CEILINGPRICE END <= INF.CEILINGPRICE
                 AND CASE WHEN MST.EXECTYPE IN ('NB','BC') AND MST.PRICETYPE = 'LO'
                          THEN MST.QUOTEPRICE*INF.TRADEUNIT ELSE INF.FLOORPRICE END >= INF.FLOORPRICE
              UNION
              SELECT MST.ACCTNO,MSt.ACTYPE,MSt.AFACCTNO,MSt.STATUS,MSt.EXECTYPE,PRICETYPE,MSt.TIMETYPE,
                          MSt.MATCHTYPE,MSt.NORK,MSt.CLEARCD,MSt.CLEARDAY,MSt.CODEID,MSt.SYMBOL,MSt.QUANTITY,
                          0 PRICE,MSt.QUOTEPRICE,MSt.TRIGGERPRICE,MSt.EXECQTTY,MSt.EXECAMT,MSt.REMAINQTTY,
                          MSt.CANCELQTTY,MSt.AMENDQTTY,MSt.CONFIRMEDVIA,MSt.BOOK,MSt.ORGACCTNO,MSt.REFACCTNO,
                          MSt.REFQUANTITY,MSt.REFPRICE,MSt.REFQUOTEPRICE,MSt.FEEDBACKMSG,MSt.ACTIVATEDT,
                          MSt.CREATEDDT,MSt.REFORDERID,MSt.REFUSERNAME,MSt.TXDATE,MSt.TXNUM,MSt.EFFDATE,
                          MSt.EXPDATE,MSt.BRATIO,MSt.VIA,MSt.DELTD,MSt.OUTPRICEALLOW,MSt.USERNAME,
                           SEC.TRADEPLACE, SEC.SECTYPE, SEC.PARVALUE, INF.TRADELOT,
                     INF.TRADEUNIT, INF.SECUREDRATIOMIN, INF.SECUREDRATIOMAX,INF.CEILINGPRICE,INF.FLOORPRICE,INF.MARGINPRICE
                       FROM FOMAST MST, SBSECURITIES SEC, SECURITIES_INFO INF,SEMAST SE ,v_getsellorderinfo V
               WHERE MST.DELTD<>'Y' AND MST.BOOK = 'A' AND  MST.REMAINQTTY>0
                 AND SE.ACCTNO=V.seacctno(+)
                 AND MST.EXECTYPE IN ('MS','SS','NS','CS')  AND PRICETYPE<>'SL'
                 AND MST.TIMETYPE = 'G'
                 AND MST.STATUS = 'P'
                 AND SEC.HALT ='N'
                 AND MST.CODEID = SEC.CODEID
                 AND SEC.TRADEPLACE IN ('002','005')
                 AND MST.CODEID = INF.CODEID
                 AND MST.EFFDATE <= to_date(v_strtxdate,'dd/mm/rrrr')
                 AND SE.ACCTNO =MST.AFACCTNO || MST.CODEID
                 AND (CASE WHEN MST.EXECTYPE='MS' THEN SE.MORTAGE-nvl(v.securemtg,0)
                            WHEN MST.exectype = 'CS' THEN MST.remainqtty
                            ELSE SE.TRADE-nvl(V.secureamt,0) END)  >= MST.REMAINQTTY
                 AND CASE WHEN MST.EXECTYPE IN ('MS','SS','NS') AND MST.PRICETYPE = 'LO'
                          THEN MST.QUOTEPRICE*INF.TRADEUNIT ELSE INF.CEILINGPRICE END <= INF.CEILINGPRICE
                 AND CASE WHEN MST.EXECTYPE IN ('MS','SS','NS') AND MST.PRICETYPE = 'LO'
                          THEN MST.QUOTEPRICE*INF.TRADEUNIT ELSE INF.FLOORPRICE END >= INF.FLOORPRICE
                 )
                 ORDER BY activatedt
           )
        loop
            --2.KIEM TRA XEM CO DU KY QUY KHONG
                 SELECT count(1) into l_count from
                 (select mst.acctno
                   FROM FOMAST MST, SBSECURITIES SEC, SECURITIES_INFO INF,CIMAST CI,v_getbuyorderinfo V
                  WHERE MST.DELTD<>'Y' AND MST.BOOK = 'A' AND  MST.REMAINQTTY>0 AND CI.ACCTNO=V.afacctno(+)
                    AND MST.EXECTYPE IN ('NB','BC','CB')
                    AND MST.TIMETYPE = 'G'
                    AND MST.STATUS = 'P'
                    AND MST.CODEID = SEC.CODEID
                    AND MST.CODEID = INF.CODEID
                    AND CI.ACCTNO =MST.AFACCTNO
                    AND CASE WHEN MST.EXECTYPE IN ('NB','BC') THEN
                                    CHECKGTCBUYORDERNEW(mst.afacctno,MST.REMAINQTTY,
                                            (CASE WHEN PRICETYPE='LO' THEN MST.QUOTEPRICE
                                                  WHEN PRICETYPE='SL' THEN to_number(rec.QUOTEPRICE)
                                                  ELSE INF.CEILINGPRICE/INF.TRADEUNIT
                                             END),
                                                MST.actype,SEC.codeid
                                    )
                             ELSE 0 END >=0
                    AND MST.ACCTNO=rec.acctno
                 UNION
                 SELECT mst.acctno
                          FROM FOMAST MST, SBSECURITIES SEC, SECURITIES_INFO INF,SEMAST SE,v_getsellorderinfo V
                  WHERE MST.DELTD<>'Y' AND MST.BOOK = 'A' AND  MST.REMAINQTTY>0 AND SE.ACCTNO=V.seacctno(+)
                    AND MST.EXECTYPE IN ('MS','SS','NS','CS')
                    AND MST.TIMETYPE = 'G'
                    AND MST.STATUS = 'P'
                    AND MST.CODEID = SEC.CODEID
                    AND MST.CODEID = INF.CODEID
                    AND SE.ACCTNO =MST.AFACCTNO || MST.CODEID
                    AND (CASE WHEN MST.EXECTYPE='MS' THEN SE.MORTAGE-nvl(v.securemtg,0)
                                WHEN MST.exectype = 'CS' THEN MST.remainqtty
                                ELSE SE.TRADE-nvl(V.secureamt,0)+nvl(V.sereceiving,0) END)  >= MST.REMAINQTTY
                    AND MST.ACCTNO=rec.acctno );
            if l_count>0 THEN
                txpks_auto.pr_fo2odsyn(rec.acctno, p_err_code, 'G');
                commit;
            end if;
        end loop;
    end if;
    COMMIT;                                -- Commit the last trunk (if any)
    /***************************************************************************************************
    ** END;
    ***************************************************************************************************/
    plog.debug (pkgctx, '<<END OF pr_gtc2od');
    plog.setendsection (pkgctx, 'pr_gtc2od');
EXCEPTION
when others then
   ROLLBACK;
   plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
   plog.setendsection (pkgctx, 'pr_gtc2od');
END pr_gtc2od;
PROCEDURE pr_fo2odsyn_bl (p_orderid varchar2, p_err_code  OUT varchar2, p_timetype varchar2 default 'T' )
   IS
      l_txmsg               tx.msg_rectype;
      l_orders_cache_size   NUMBER (10) := 10000;
      l_commit_freq         NUMBER (10) := 10;
      l_count               NUMBER (10) := 0;
      l_order_count         NUMBER (10) := 0;
      l_isHoliday           varchar2(10);
      l_err_param           deferror.errdesc%TYPE;

      l_mktstatus           ordersys.sysvalue%TYPE;
      l_atcstarttime        sysvar.varvalue%TYPE;

      l_typebratio          odtype.bratio%TYPE;
      l_afbratio            afmast.bratio%TYPE;
      l_securedratio        odtype.bratio%TYPE;
      l_actype              odtype.actype%TYPE;
      l_remainqtty          odmast.orderqtty%TYPE;
      l_fullname            cfmast.fullname%TYPE;
      l_ordervia            odtype.via%type;

      l_feeamountmin        NUMBER;
      l_feerate             NUMBER;
      l_feesecureratiomin   NUMBER;
      l_hosebreakingsize    NUMBER;
      l_hasebreakingsize    NUMBER;
      l_breakingsize        NUMBER;
      l_strMarginType       mrtype.mrtype%TYPE;
      l_dblMarginRatioRate  afserisk.MRRATIOLOAN%TYPE;
      l_dblSecMarginPrice   afserisk.MRPRICELOAN%TYPE;
      --</ Margin 74
      l_dblIsMarginAllow   afserisk.ISMARGINALLOW%TYPE;
      l_dblChkSysCtrl       lntype.chksysctrl%TYPE;
      --/>
      l_dblIsPPUsed         mrtype.ISPPUSED%TYPE;
      l_strEXECTYPE         odmast.exectype%TYPE;
      l_hnxTRADINGID        varchar2(30);
      l_ismortage           VARCHAR2(10);-- PhuongHT add

      l_CUSTATCOM           cfmast.custatcom%TYPE; -- Them vao de sua lenh Bloomberg
      l_clearday             odmast.clearday%TYPE;
      l_tradelot            number(30,4);
   BEGIN
      plog.setbeginsection (pkgctx, 'pr_fo2odsyn_bl');
      plog.debug (pkgctx, 'BEGIN OF pr_fo2odsyn_bl');
      plog.debug (pkgctx, 'p_orderid: '||p_orderid);
      plog.debug (pkgctx, 'p_timetype: '||p_timetype);
      /***************************************************************************************************
       ** PUT YOUR CODE HERE, FOLLOW THE BELOW TEMPLATE:
       ** IF NECCESSARY, USING BULK COLLECTION IN THE CASE YOU MUST POPULATE LARGE DATA
      ****************************************************************************************************/
      l_atcstarttime      :=
         cspks_system.fn_get_sysvar ('SYSTEM', 'ATCSTARTTIME');
      --l_hosebreakingsize   :=
         --cspks_system.fn_get_sysvar ('SYSTEM', 'HOSEBREAKSIZE');
      l_hosebreakingsize   :=least(cspks_system.fn_get_sysvar ('SYSTEM', 'HOSEBREAKSIZE'),
                                    cspks_system.fn_get_sysvar ('BROKERDESK', 'HOSE_MAX_QUANTITY')
                                  );
      l_hasebreakingsize:=cspks_system.fn_get_sysvar ('BROKERDESK', 'HNX_MAX_QUANTITY');

      /*plog.debug (pkgctx,
                     'got l_atcstarttime,l_hosebreakingsize,l_commit_freq'
                  || l_atcstarttime
                  || ','
                  || l_hosebreakingsize
                  || ','
                  || l_commit_freq
      );*/
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

     /* plog.debug (pkgctx,
                     'wsname,ipaddress:'
                  || l_txmsg.wsname
                  || ','
                  || l_txmsg.ipaddress
      );*/

      -- 2. Set specific value for each transaction
      for l_build_msg in
      (
         SELECT  a.codeid fld01,
                 a.symbol fld07,
                 DECODE (a.exectype, 'MS', '1', '0') fld60, --ismortage   fld60, -- FOR 8885
                 a.actype fld02,
                 a.afacctno || a.codeid fld06,                --seacctno    fld06,
                 a.afacctno fld03,
                 a.timetype fld20,
                 --'T' fld20,
                 a.effdate fld19,
                 --a.expdate fld21, -- Lenh GTC day vao ODMAST lay expdate = currdate
                 getcurrdate fld21,
                 a.exectype fld22,
                 a.outpriceallow fld34,
                 a.nork fld23,
                 a.matchtype fld24,
                 a.via fld25,
                 a.clearday fld10,
                 a.clearcd fld26,
                 'O' fld72,                                       --puttype fld72,
                 (CASE WHEN a.exectype IN ('AB','AS') AND a.pricetype='MTL' THEN 'LO'
                       WHEN a.pricetype = 'RP' THEN FN_GETPRICETYPE4RP(b.tradeplace) --DUCNV sua lenh RP
                       ELSE a.pricetype
                  END ) fld27,
                 -- PhuongHT edit for sua lenh MTL
                 case when timetype ='G' then a.remainqtty else a.quantity end fld12,                      --a.ORDERQTTY       fld12,
                 a.quoteprice fld11,
                 0 fld18,                               --a.ADVSCRAMT       fld18,
                 0 fld17,                               --a.ORGQUOTEPRICE   fld17,
                 0 fld16,                               --a.ORGORDERQTTY    fld16,
                 0 fld31,                               --a.ORGSTOPPRICE    fld31,
                 a.bratio fld13,
                 a.limitprice fld14,                               --a.LIMITPRICE      fld14,
                 0 fld40,                                                -- FEEAMT
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
                 c.marginrefprice,
                 b.tradeplace,
                 b.sectype,
                 c.tradelot,
                 c.securedratiomin,
                 c.securedratiomax,
                 a.SPLOPT,
                 a.SPLVAL,
                 a.ISDISPOSAL,
                 a.username username,
                 a.SSAFACCTNO fld94,
                 '' fld35,
                 a.tlid tlid,
                 a.quoteqtty fld80

          FROM fomast a, sbsecurities b, securities_info c
          WHERE     a.book = 'A'
                AND a.timetype = p_timetype
                AND a.status = 'P'
                --and a.direct= DECODE(p_timetype,'G',A.DIRECT,'Y')
                AND a.codeid = b.codeid
                AND a.codeid = c.codeid
                and a.acctno = p_orderid
      )
      LOOP
            BEGIN


                --PHuongHT truyen lai tham so cho lenh ban cam co
                l_ismortage :=l_build_msg.fld60;
                IF l_build_msg.fld22 ='AS' THEN
                  -- lay theo lenh goc
                  BEGIN
                    SELECT  DECODE (a.exectype, 'MS', '1', '0')
                    INTO l_ismortage
                    FROM odmast a  WHERE orderid =l_build_msg.refacctno;
                  EXCEPTION WHEN OTHERS THEN
                  l_ismortage:= 0;
                  END;

                END IF;
                -- Ducnv check trang thai thi truong HNX
                --thangpv TPDN
                BEGIN
                  SELECT TRADELOT
                  INTO l_tradelot
                  FROM SECURITIES_INFO WHERE SYMBOL = l_build_msg.fld07;
                EXCEPTION WHEN OTHERS THEN
                  l_tradelot:= 100;
                END;

               IF l_build_msg.tradeplace ='002' THEN
                   SELECT sysvalue
                   INTO l_hnxTRADINGID
                   FROM ordersys_ha
                   WHERE sysname = 'TRADINGID';
                   IF l_build_msg.fld27 IN ('ATO') THEN
                        RAISE errnums.e_invalid_session;
                   END IF;
                   -- PHIEN DONG CUA KHONG DC NHAP LENH THI TRUONG
                   IF l_build_msg.fld27 IN ('MTL','MOK','MAK') AND l_hnxTRADINGID IN ('CLOSE','CLOSE_BL') THEN
                        RAISE errnums.e_invalid_session;
                   END IF;
                   -- CHAN HUY SUA 10 PHUT CUOI
                   IF l_build_msg.fld22 in ('AB','AS','CB','CS') AND l_hnxTRADINGID IN ('CLOSE_BL') THEN
                        RAISE errnums.e_invalid_session;
                   END IF;
                   -- lenh lo le chi dc dat trong phien lien tuc
                   --IF l_build_msg.fld12<100 AND  l_hnxTRADINGID <> 'CONT' then
                   IF l_build_msg.fld12<l_tradelot AND  l_hnxTRADINGID <> 'CONT' then
                      RAISE errnums.e_invalid_session;
                   end if;
                   -- LO LE CHI DC DAT LENH LO
                   --IF l_build_msg.fld12<100 AND l_build_msg.fld27 <>'LO' THEN
                   IF l_build_msg.fld12<l_tradelot AND l_build_msg.fld27 <>'LO' THEN
                      RAISE errnums.e_invalid_session;
                   END IF;
               ELSIF l_build_msg.tradeplace ='005' THEN
                  -- UPCOM CHI DC DAT LENH LO
                   IF l_build_msg.fld27 <>'LO' THEN
                      RAISE errnums.e_invalid_session;
                   END IF;
               END IF;
               -------------------------end of ducnv-----
               -- Check Market status
               SELECT sysvalue
               INTO l_mktstatus
               FROM ordersys
               WHERE sysname = 'CONTROLCODE';


               /*plog.debug (pkgctx,
                              'l_mktstatus,pricetype: '
                           || l_mktstatus
                           || ','
                           || l_build_msg.fld27
               );*/

               -- l_mktstatus=P: 8h30-->9h00 session 1 ATO
               -- l_mktstatus=O: 9h00-->10h15 session 2 MP
               -- l_mktstatus=A: 10h15-->10h30 session 3 ATC
               --plog.debug (pkgctx,'username: ' || l_build_msg.username);
               --plog.debug (pkgctx,'via: ' || l_build_msg.fld25);
               -- </ TruongLD Add
               --if l_build_msg.fld25 <> 'O' then
                l_txmsg.tlid := l_build_msg.tlid;
               /*else
                l_txmsg.tlid := '0001';
               end if;*/

               --/>
               --plog.debug (pkgctx,'pricetype: ' || l_build_msg.fld27);
               IF l_build_msg.fld27 = 'ATO'
               THEN                                        -- fld27: pricetype
                  IF l_mktstatus IN ('O', 'A')
                  THEN
                     RAISE errnums.e_invalid_session;
                  END IF;

                -- KO CHECK PHIEN GD NEU LA LENH ATC --> CHO PHEP DAT LENH ATC TRUOC GIO
               /*ELSIF l_build_msg.fld27 = 'ATC'
               THEN
                  IF not(l_mktstatus = 'A'
                            or (l_mktstatus = 'O'
                                    AND l_atcstarttime <=
                                        TO_CHAR (SYSDATE, 'HH24MISS')))
                  THEN
                     RAISE errnums.e_invalid_session;
                  END IF;*/
               ELSIF l_build_msg.fld27 = 'MO'
               THEN
                  IF l_mktstatus <> 'O'
                  THEN
                     RAISE errnums.e_invalid_session;
                  END IF;
               END IF;

               l_txmsg.txfields ('22').VALUE     := l_build_msg.fld22; --set vale for Execution TYPE
               l_strEXECTYPE:=l_build_msg.fld22;
               /*plog.debug (pkgctx,
                           'exectype: ' || l_txmsg.txfields ('22').VALUE
               );*/

               IF LENGTH (l_build_msg.refacctno) > 0
               THEN                                             --lENH HUY SUA
                  FOR i IN (SELECT exectype
                            FROM fomast
                            WHERE orgacctno = l_build_msg.refacctno)
                  LOOP
                     l_strEXECTYPE:=i.exectype;
                  END LOOP;
               END IF;

               IF l_build_msg.fld27 <> 'LO'
               THEN                                               -- Pricetype
                  IF l_strEXECTYPE='NB'--l_build_msg (indx).fld22 = 'NB'
                  THEN                                             -- exectype
                     l_build_msg.fld11   :=
                        l_build_msg.ceilingprice
                        / l_build_msg.fld98;                --tradeunit
                  ELSE
                     l_build_msg.fld11   :=
                        l_build_msg.floorprice
                        / l_build_msg.fld98;
                  END IF;
               END IF;

               -- T2 NAMNT: sua day lenh GTC vao dung theo chu ky thanh toan config
               IF p_timetype = 'G' THEN
                    select TO_NUMBER(VARVALUE)
                    into l_clearday
                    from sysvar
                    where grname like 'SYSTEM' and varname='CLEARDAY' and rownum<=1;
               ELSE
                    l_clearday := l_build_msg.fld10;
               END IF;
               -- End: T2 NAMNT: sua day lenh GTC vao dung theo chu ky thanh toan config


               FOR i IN (SELECT MST.BRATIO, CF.CUSTODYCD,CF.FULLNAME,MST.ACTYPE,MRT.MRTYPE,MRT.ISPPUSED,
                        NVL(RSK.MRRATIOLOAN,0) MRRATIOLOAN, NVL(MRPRICELOAN,0) MRPRICELOAN,
                        nvl(ISMARGINALLOW,'N') ISMARGINALLOW, nvl(lnt.chksysctrl,'N') chksysctrl, cf.custatcom
                        FROM AFMAST MST, CFMAST CF ,AFTYPE AFT, MRTYPE MRT, LNTYPE LNT,
                        (SELECT * FROM AFSERISK WHERE CODEID=l_build_msg.fld01 ) RSK
                        WHERE MST.ACCTNO=l_build_msg.fld03
                        AND MST.CUSTID=CF.CUSTID
                        and mst.actype =aft.actype and aft.mrtype = mrt.actype and aft.lntype = lnt.actype(+)
                        AND AFT.ACTYPE =RSK.ACTYPE(+))
               LOOP
                  l_txmsg.txfields ('09').VALUE   := i.custodycd;
                  l_actype                        := i.actype;
                  l_afbratio                      := i.bratio;
                  --l_txmsg.txfields ('50').VALUE   := 'FO';
                  l_fullname                      := i.fullname;
                  l_strMarginType                 := i.MRTYPE;
                  l_dblMarginRatioRate            := i.MRRATIOLOAN;
                  l_dblSecMarginPrice             := i.MRPRICELOAN;
                  --</ Margin 74
                  l_dblIsMarginAllow              := i.ISMARGINALLOW;
                  l_dblChkSysCtrl                 := i.CHKSYSCTRL;
                  --/>
                  l_dblIsPPUsed                   := i.ISPPUSED;

                  -- Them vao de sua cho lenh Bloomberg
                  -- DungNH, 02-Nov-2015
                  l_CUSTATCOM                       := i.custatcom;
                  -- Ket thuc: Them vao de sua cho lenh Bloomberg

                  If l_dblMarginRatioRate >= 100 Or l_dblMarginRatioRate < 0 or (l_dblIsMarginAllow = 'N' and l_dblChkSysCtrl = 'Y')
                  Then
                        l_dblMarginRatioRate := 0;
                  END IF;
                  if l_dblChkSysCtrl = 'Y' then
                      if l_build_msg.marginrefprice > l_dblSecMarginPrice
                      then
                            l_dblSecMarginPrice := l_dblSecMarginPrice;
                      else
                            l_dblSecMarginPrice := l_build_msg.marginrefprice;
                      end if;
                  else
                      if l_build_msg.marginprice > l_dblSecMarginPrice
                      then
                            l_dblSecMarginPrice := l_dblSecMarginPrice;
                      else
                            l_dblSecMarginPrice := l_build_msg.marginprice;
                      end if;
                  end if;
               END LOOP;
               /*plog.debug (pkgctx, 'VIA: ' || l_build_msg.fld25);
               plog.debug (pkgctx, 'CLEARCD: ' || l_build_msg.fld26);
               plog.debug (pkgctx, 'EXECTYPE: ' || l_build_msg.fld22);
               plog.debug (pkgctx, 'TIMETYPE: ' || l_build_msg.fld20);
               plog.debug (pkgctx, 'PRICETYPE: ' || l_build_msg.fld27);
               plog.debug (pkgctx, 'MATCHTYPE: ' || l_build_msg.fld24);
               plog.debug (pkgctx, 'NORK: ' || l_build_msg.fld23);
               plog.debug (pkgctx, 'sectype: ' || l_build_msg.sectype);
               plog.debug (pkgctx,
                           'tradeplace: ' || l_build_msg.tradeplace
               );*/

               BEGIN
                    -- Neu lenh sua thi lay lai ti le ky quy va thong tin loai hinh nhu lenh goc
                    -- TheNN, 15-Feb-2012
                    IF substr(l_build_msg.fld22,1,1) = 'A' THEN
                        SELECT OD.ACTYPE, OD.CLEARDAY, OD.BRATIO
                        INTO l_txmsg.txfields ('02').VALUE, l_txmsg.txfields ('10').VALUE, l_securedratio
                        FROM ODMAST OD
                        WHERE ORDERID = l_build_msg.orgacctno;
                    ELSE
                        -- LAY THONG TIN VA TINH TY LE KY QUY NHU BINH THUONG
                        -- Trong loai hinh OD ko quy dinh kenh GD qua BrokerDesk nen se gan cung kenh voi tai san (Floor)
                        BEGIN
                              -- TheNN, 14-Feb-2012
                              l_ordervia := l_build_msg.fld25;
                              if l_ordervia = 'B' then
                                  l_ordervia := 'F';
                              end if;
                              -- End: TheNN, 14-Feb-2012

                                SELECT actype, clearday, bratio, minfeeamt, deffeerate
                              --to_char(sysdate,systemnums.C_TIME_FORMAT) TXTIME
                              INTO l_txmsg.txfields ('02').VALUE,                 --ACTYPE
                                   l_txmsg.txfields ('10').VALUE,               --CLEARDAY
                                   l_typebratio,                          --BRATIO (fld13)
                                   l_feeamountmin,
                                   l_feerate
                              FROM (SELECT a.actype, a.clearday, a.bratio, a.minfeeamt, a.deffeerate, b.ODRNUM
                              FROM odtype a, afidtype b
                              WHERE     a.status = 'Y'
                                    AND (a.via = l_build_msg.fld25 OR a.via = 'A') --VIA
                                    AND a.clearcd = l_build_msg.fld26       --CLEARCD
                                    AND (a.exectype = l_strEXECTYPE           --l_build_msg.fld22
                                         OR a.exectype = 'AA')                    --EXECTYPE
                                    AND (a.timetype = l_build_msg.fld20
                                         OR a.timetype = 'A')                     --TIMETYPE
                                    AND (a.pricetype = l_build_msg.fld27
                                         OR a.pricetype = 'AA')                  --PRICETYPE
                                    AND (a.matchtype = l_build_msg.fld24
                                         OR a.matchtype = 'A')                   --MATCHTYPE
                                    AND (a.tradeplace = l_build_msg.tradeplace
                                         OR a.tradeplace = '000')
            --                        AND (sectype = l_build_msg.sectype
            --                             OR sectype = '000')

                                    AND (instr(case when l_build_msg.sectype in ('001','002') then l_build_msg.sectype || ',' || '111,333'
                                                   when l_build_msg.sectype in ('003','006') then l_build_msg.sectype || ',' || '222,333,444'
                                                   when l_build_msg.sectype in ('008') then l_build_msg.sectype || ',' || '111,444'
                                                   else l_build_msg.sectype end, a.sectype)>0 OR a.sectype = '000')
                                    AND (a.nork = l_build_msg.fld23 OR a.nork = 'A') --NORK
                                    AND (CASE WHEN A.CODEID IS NULL THEN l_build_msg.fld01 ELSE A.CODEID END)=l_build_msg.fld01
                                    AND a.actype = b.actype and b.aftype=l_actype and b.objname='OD.ODTYPE'
                                    --order by b.odrnum DESC, A.deffeerate DESC
                                    --order BY A.deffeerate DESC, B.ACTYPE DESC
                                    order BY A.deffeerate , B.ACTYPE DESC -- Lay ti le phi nho nhat
                                    ) where rownum<=1;
                           EXCEPTION
                              WHEN NO_DATA_FOUND
                              THEN
                              RAISE errnums.e_od_odtype_notfound;
                           END;

                           if l_strMarginType='S' or l_strMarginType='T' or l_strMarginType='N' then
                               --Tai khoan margin va tai khoan binh thuong ky quy 100%
                                l_securedratio:=100;
                           elsif l_strMarginType='L' then --Cho tai khoan margin loan
                                begin
                                    select (case when nvl(dfprice,0)>0 then least(nvl(dfrate,0),round(nvl(dfprice,0)/ l_build_msg.fld11/l_build_msg.fld98 * 100,4)) else nvl(dfrate,0) end ) dfrate
                                    into l_securedratio
                                    from (select * from dfbasket where symbol=l_build_msg.fld07) bk,
                                    aftype aft, dftype dft,afmast af
                                    where af.actype = aft.actype and aft.dftype = dft.actype and dft.basketid = bk.basketid (+)
                                    and af.acctno = l_build_msg.fld03;
                                    l_securedratio:=greatest (100-l_securedratio,0);
                                exception
                                when others then
                                     l_securedratio:=100;
                                end;
                           else
                                l_securedratio                    :=
                                GREATEST (LEAST (l_typebratio + l_afbratio, 100),
                                        l_build_msg.securedratiomin
                                );
                                l_securedratio                    :=
                                  CASE
                                     WHEN l_securedratio > l_build_msg.securedratiomax
                                     THEN
                                        l_build_msg.securedratiomax
                                     ELSE
                                        l_securedratio
                                  END;
                           end if;

                           --FeeSecureRatioMin = mv_dblFeeAmountMin * 100 / (CDbl(v_strQUANTITY) * CDbl(v_strQUOTEPRICE) * CDbl(v_strTRADEUNIT))
                           l_feesecureratiomin               :=
                              l_feeamountmin * 100
                              / (  TO_NUMBER (l_build_msg.fld12)         --quantity
                                 * TO_NUMBER (l_build_msg.fld11)       --quoteprice
                                 * TO_NUMBER (l_build_msg.fld98));      --tradeunit

                           IF l_feesecureratiomin > l_feerate
                           THEN
                              l_securedratio   := l_securedratio + l_feesecureratiomin;
                           ELSE
                              l_securedratio   := l_securedratio + l_feerate;
                           END IF;
                    END IF;
                END;
                -- End: TheNN modified, 15-Feb-2012


               /*l_txmsg.txfields ('40').VALUE     :=
                    greatest(l_feerate/100 * TO_NUMBER (l_build_msg.fld12)         --quantity
                     * TO_NUMBER (l_build_msg.fld11)       --quoteprice
                     * TO_NUMBER (l_build_msg.fld98),l_feeamountmin);*/
               l_txmsg.txfields ('13').VALUE     := l_securedratio;

               IF (  TO_NUMBER (l_build_msg.fld12)
                   * TO_NUMBER (l_build_msg.fld11)
                   * l_securedratio
                   / 100
                   -   TO_NUMBER (l_build_msg.refprice)
                     * TO_NUMBER (l_build_msg.refquantity)
                     * l_securedratio
                     / 100 > 0)
               THEN
                  l_txmsg.txfields ('18').VALUE   :=
                       TO_NUMBER (l_build_msg.fld12)
                     * TO_NUMBER (l_build_msg.fld11)
                     * l_securedratio
                     / 100
                     -   TO_NUMBER (l_build_msg.refprice)
                       * TO_NUMBER (l_build_msg.refquantity)
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
               /*select nvl(max(sbc.holiday),'N') into l_isHoliday from sbcldr sbc, sysvar sy
               where sbc.cldrtype = l_build_msg.tradeplace
                and sy.grname = 'SYSTEM' AND sy.varname = 'CURRDATE'
                and sbc.sbdate = TO_DATE (sy.varvalue, systemnums.c_date_format);
                if l_isHoliday = 'Y' then
                   SELECT TO_DATE (varvalue, systemnums.c_date_format)
                   INTO l_txmsg.txdate
                   FROM sysvar
                   WHERE grname = 'SYSTEM' AND varname = 'NEXTDATE';
                else*/
                   SELECT TO_DATE (varvalue, systemnums.c_date_format)
                   INTO l_txmsg.txdate
                   FROM sysvar
                   WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
                ---end if;

               l_txmsg.brdate                    := l_txmsg.txdate;
               l_txmsg.busdate                   := l_txmsg.txdate;

               --2.4 Set fld value
               l_txmsg.txfields ('01').defname   := 'CODEID';
               l_txmsg.txfields ('01').TYPE      := 'C';
               l_txmsg.txfields ('01').VALUE     := l_build_msg.fld01; --set vale for CODEID

               l_txmsg.txfields ('07').defname   := 'SYMBOL';
               l_txmsg.txfields ('07').TYPE      := 'C';
               l_txmsg.txfields ('07').VALUE     := l_build_msg.fld07; --set vale for Symbol



               l_txmsg.txfields ('60').defname   := 'ISMORTAGE';
               l_txmsg.txfields ('60').TYPE      := 'N';
               l_txmsg.txfields ('60').VALUE     := l_ismortage; --set vale for Is mortage sell
               l_txmsg.txfields ('02').defname   := 'ACTYPE';
               l_txmsg.txfields ('02').TYPE      := 'C';
               -- l_txmsg.txfields ('02').VALUE     := l_build_msg.fld02; --set vale for Product code
               -- this is set above
               l_txmsg.txfields ('03').defname   := 'AFACCTNO';
               l_txmsg.txfields ('03').TYPE      := 'C';
               l_txmsg.txfields ('03').VALUE     := l_build_msg.fld03; --set vale for Contract number
               l_txmsg.txfields ('06').defname   := 'SEACCTNO';
               l_txmsg.txfields ('06').TYPE      := 'C';
               l_txmsg.txfields ('06').VALUE     := l_build_msg.fld06; --set vale for SE account number

               l_txmsg.txfields ('50').defname   := 'CUSTNAME';
               l_txmsg.txfields ('50').TYPE      := 'C';
               l_txmsg.txfields ('50').VALUE     := l_build_msg.username; --set vale for Customer name
               /*if p_timetype <> 'G' then
                   l_txmsg.txfields ('50').VALUE     := l_build_msg.username; --set vale for Customer name
               else
                   l_txmsg.txfields ('50').VALUE     := l_build_msg.acctno; --set vale for Customer name
               end if;*/
               -- this was set above already
               l_txmsg.txfields ('20').defname   := 'TIMETYPE';
               l_txmsg.txfields ('20').TYPE      := 'C';
               l_txmsg.txfields ('20').VALUE     := l_build_msg.fld20; --set vale for Duration
               l_txmsg.txfields ('21').defname   := 'EXPDATE';
               l_txmsg.txfields ('21').TYPE      := 'D';
               l_txmsg.txfields ('21').VALUE     := l_build_msg.fld21; --set vale for Expired date
               l_txmsg.txfields ('19').defname   := 'EFFDATE';
               l_txmsg.txfields ('19').TYPE      := 'D';
               l_txmsg.txfields ('19').VALUE     := l_build_msg.fld19; --set vale for Expired date
               l_txmsg.txfields ('22').defname   := 'EXECTYPE';
               l_txmsg.txfields ('22').TYPE      := 'C';
               --l_txmsg.txfields ('22').VALUE     := l_build_msg.fld22; --set vale for Execution type
               l_txmsg.txfields ('23').defname   := 'NORK';
               l_txmsg.txfields ('23').TYPE      := 'C';
               l_txmsg.txfields ('23').VALUE     := l_build_msg.fld23; --set vale for All or none?
               l_txmsg.txfields ('34').defname   := 'OUTPRICEALLOW';
               l_txmsg.txfields ('34').TYPE      := 'C';
               l_txmsg.txfields ('34').VALUE     := l_build_msg.fld34; --set vale for Accept out amplitute price
               l_txmsg.txfields ('24').defname   := 'MATCHTYPE';
               l_txmsg.txfields ('24').TYPE      := 'C';
               l_txmsg.txfields ('24').VALUE     := l_build_msg.fld24; --set vale for Matching type
               l_txmsg.txfields ('25').defname   := 'VIA';
               l_txmsg.txfields ('25').TYPE      := 'C';
               l_txmsg.txfields ('25').VALUE     := l_build_msg.fld25; --set vale for Via
               l_txmsg.txfields ('10').defname   := 'CLEARDAY';
               l_txmsg.txfields ('10').TYPE      := 'N';
              -- l_txmsg.txfields ('10').VALUE     := l_build_msg.fld10; --set vale for Clearing day
               l_txmsg.txfields ('10').VALUE     := l_clearday;--l_build_msg.fld10; --set vale for Clearing day

               l_txmsg.txfields ('26').defname   := 'CLEARCD';
               l_txmsg.txfields ('26').TYPE      := 'C';
               l_txmsg.txfields ('26').VALUE     := l_build_msg.fld26; --set vale for Calendar
               l_txmsg.txfields ('72').defname   := 'PUTTYPE';
               l_txmsg.txfields ('72').TYPE      := 'C';
               l_txmsg.txfields ('72').VALUE     := l_build_msg.fld72; --set vale for Puthought type
               l_txmsg.txfields ('27').defname   := 'PRICETYPE';
               l_txmsg.txfields ('27').TYPE      := 'C';
               l_txmsg.txfields ('27').VALUE     := l_build_msg.fld27; --set vale for Price type

               l_txmsg.txfields ('11').defname   := 'QUOTEPRICE';
               l_txmsg.txfields ('11').TYPE      := 'N';
               l_txmsg.txfields ('11').VALUE     := l_build_msg.fld11; --set vale for Limit price

               l_txmsg.txfields ('80').defname   := 'QUOTEQTTY';
               l_txmsg.txfields ('80').TYPE      := 'N';
               l_txmsg.txfields ('80').VALUE     := 0; --set vale for Limit price

               l_txmsg.txfields ('81').defname   := 'ORGQUOTEQTTY';
               l_txmsg.txfields ('81').TYPE      := 'N';
               l_txmsg.txfields ('81').VALUE     := 0; --set vale for Limit price

               l_txmsg.txfields ('82').defname   := 'ORGLIMITPRICE';
               l_txmsg.txfields ('82').TYPE      := 'N';
               l_txmsg.txfields ('82').VALUE     := 0; --set vale for Limit price

               l_txmsg.txfields ('90').defname   := 'TRADESTATUS';
               l_txmsg.txfields ('90').TYPE      := 'N';
               l_txmsg.txfields ('90').VALUE     := 0;
               IF l_build_msg.fld22 IN ('NS', 'MS', 'SS') THEN --gc_OD_PLACENORMALSELLORDER_ADVANCED
                   --HaiLT them cho GRPORDER
                   l_txmsg.txfields ('55').defname   := 'GRPORDER';
                   l_txmsg.txfields ('55').TYPE      := 'C';
                   l_txmsg.txfields ('55').VALUE     := 'N';
               END IF;

               IF l_build_msg.fld27 <> 'LO'
               THEN                                               -- Pricetype
                  IF l_strEXECTYPE='NB' --l_build_msg.fld22 = 'NB'
                  THEN                                             -- exectype
                     l_txmsg.txfields ('11').VALUE   :=
                        l_build_msg.ceilingprice
                        / l_build_msg.fld98;                --tradeunit
                  ELSE
                     l_txmsg.txfields ('11').VALUE   :=
                        l_build_msg.floorprice
                        / l_build_msg.fld98;
                  END IF;
               END IF;

               l_txmsg.txfields ('12').defname   := 'ORDERQTTY';
               l_txmsg.txfields ('12').TYPE      := 'N';
               l_txmsg.txfields ('12').VALUE     := l_build_msg.fld12; --set vale for Quantity
               l_txmsg.txfields ('13').defname   := 'BRATIO';
               l_txmsg.txfields ('13').TYPE      := 'N';
               --l_txmsg.txfields ('13').VALUE     := l_build_msg.fld13; --set vale for Block ration
               l_txmsg.txfields ('80').defname   := 'QUOTEQTTY';
               l_txmsg.txfields ('80').TYPE      := 'N';
               l_txmsg.txfields ('80').VALUE   := l_build_msg.fld80;
               l_txmsg.txfields ('14').defname   := 'LIMITPRICE';
               l_txmsg.txfields ('14').TYPE      := 'N';
               l_txmsg.txfields ('14').VALUE     := l_build_msg.fld14; --set vale for Stop price
               l_txmsg.txfields ('40').defname   := 'FEEAMT';
               l_txmsg.txfields ('40').TYPE      := 'N';
               --l_txmsg.txfields ('40').VALUE     := l_build_msg.fld40; --set vale for Fee amount
               l_txmsg.txfields ('28').defname   := 'VOUCHER';
               l_txmsg.txfields ('28').TYPE      := 'C';
               l_txmsg.txfields ('28').VALUE     := ''; --l_build_msg.fld28; --set vale for Voucher status
               l_txmsg.txfields ('29').defname   := 'CONSULTANT';
               l_txmsg.txfields ('29').TYPE      := 'C';
               l_txmsg.txfields ('29').VALUE     := ''; --l_build_msg.fld29; --set vale for Consultant status
               l_txmsg.txfields ('04').defname   := 'ORDERID';
               l_txmsg.txfields ('04').TYPE      := 'C';
               --l_txmsg.txfields ('04').VALUE     := l_build_msg.fld04; --set vale for Order ID
               --this is set below
               l_txmsg.txfields ('15').defname   := 'PARVALUE';
               l_txmsg.txfields ('15').TYPE      := 'N';
               l_txmsg.txfields ('15').VALUE     := l_build_msg.fld15; --set vale for Parvalue
               l_txmsg.txfields ('30').defname   := 'DESC';
               l_txmsg.txfields ('30').TYPE      := 'C';
               l_txmsg.txfields ('30').VALUE     := l_build_msg.fld30; --set vale for Description

               l_txmsg.txfields ('95').defname   := 'DFACCTNO';
               l_txmsg.txfields ('95').TYPE      := 'C';
               l_txmsg.txfields ('95').VALUE     := l_build_msg.fld95; --set vale for deal id

               l_txmsg.txfields ('94').defname   := 'SSAFACCTNO';
               l_txmsg.txfields ('94').TYPE      := 'C';
               l_txmsg.txfields ('94').VALUE     := l_build_msg.fld94; --set vale for short sale account

               l_txmsg.txfields ('90').defname   := 'TRADESTATUS';
               l_txmsg.txfields ('90').TYPE      := 'N';
               l_txmsg.txfields ('90').VALUE     := 0;

               l_txmsg.txfields ('90').defname   := 'TRADESTATUS';
               l_txmsg.txfields ('90').TYPE      := 'N';
               l_txmsg.txfields ('90').VALUE     := 0;
               l_txmsg.txfields ('99').defname   := 'HUNDRED';
               l_txmsg.txfields ('99').TYPE      := 'N';
               If l_strMarginType = 'N' Then
                    l_txmsg.txfields ('99').VALUE     := l_build_msg.fld99;
               Else
                    If l_dblIsPPUsed = 1 Then
                        l_txmsg.txfields ('99').VALUE     := to_char(100 / (1 - l_dblMarginRatioRate / 100 * l_dblSecMarginPrice / l_build_msg.fld11 / l_build_msg.fld98));
                    Else
                        l_txmsg.txfields ('99').VALUE     := l_build_msg.fld99;
                    End If;
               End If;

               l_txmsg.txfields ('98').defname   := 'TRADEUNIT';
               l_txmsg.txfields ('98').TYPE      := 'N';
               l_txmsg.txfields ('98').VALUE     := l_build_msg.fld98; --set vale for Trade unit

               l_txmsg.txfields ('96').defname   := 'TRADEUNIT';
               l_txmsg.txfields ('96').TYPE      := 'N';
               l_txmsg.txfields ('96').VALUE     := 1; --l_build_msg.fld96; --set vale for GTC

               l_txmsg.txfields ('97').defname   := 'MODE';
               l_txmsg.txfields ('97').TYPE      := 'C';
               l_txmsg.txfields ('97').VALUE     := l_build_msg.fld97; --set vale for MODE DAT LENH
               l_txmsg.txfields ('33').defname   := 'CLIENTID';
               l_txmsg.txfields ('33').TYPE      := 'C';
               l_txmsg.txfields ('33').VALUE     := l_build_msg.fld33; --set vale for ClientID
               l_txmsg.txfields ('73').defname   := 'CONTRAFIRM';
               l_txmsg.txfields ('73').TYPE      := 'C';
               l_txmsg.txfields ('73').VALUE     := l_build_msg.fld73; --set vale for Contrafirm
               l_txmsg.txfields ('32').defname   := 'TRADERID';
               l_txmsg.txfields ('32').TYPE      := 'C';
               l_txmsg.txfields ('32').VALUE     := l_build_msg.fld32; --set vale for TraderID
               l_txmsg.txfields ('71').defname   := 'CONTRACUS';
               l_txmsg.txfields ('71').TYPE      := 'C';
               l_txmsg.txfields ('71').VALUE     := ''; --l_build_msg.fld71; --set vale for Contra custody
               l_txmsg.txfields ('74').defname   := 'ISDISPOSAL';
               l_txmsg.txfields ('74').TYPE      := 'C';
               l_txmsg.txfields ('74').VALUE     := l_build_msg.ISDISPOSAL;
               l_txmsg.txfields ('31').defname   := 'CONTRAFIRM';
               l_txmsg.txfields ('31').TYPE      := 'C';
               l_txmsg.txfields ('31').VALUE     := l_build_msg.fld31; --set vale for Contrafirm

               l_txmsg.txfields ('90').defname   := 'TRADESTATUS';
               l_txmsg.txfields ('90').TYPE      := 'N';
               l_txmsg.txfields ('90').VALUE     := 0;

               l_txmsg.txfields ('35').defname   := 'ADVIDREF';
               l_txmsg.txfields ('35').TYPE      := 'C';
               l_txmsg.txfields ('35').VALUE     := '';
               IF l_build_msg.fld22 = 'AB' or l_build_msg.fld22 = 'AS'     then
                   l_txmsg.txfields ('16').defname   := 'ORGORDERQTTY';
                   l_txmsg.txfields ('16').TYPE      := 'N';
                   l_txmsg.txfields ('16').VALUE     := 0;
                   l_txmsg.txfields ('17').defname   := 'ORGQUOTEPRICE';
                   l_txmsg.txfields ('17').TYPE      := 'N';
                   l_txmsg.txfields ('17').VALUE     := 0;
               end if;

               /*
               --</ TruongLD Add 05/10/2011
               -- ADVIDREF
               l_txmsg.txfields ('35').defname   := 'ADVIDREF';
               l_txmsg.txfields ('35').TYPE      := 'C';
               l_txmsg.txfields ('35').VALUE     := l_build_msg.fld35; --set vale for CONTRAFIRM
               --End TruongLD/>
               */

               l_remainqtty                      :=
                  l_txmsg.txfields ('12').VALUE;

               l_txmsg.txfields ('08').VALUE     :=
                  l_build_msg.orgacctno;
              /* plog.debug (pkgctx,
                           'cancel orderid: '
                           || l_txmsg.txfields ('08').VALUE
               );*/

               l_order_count                     := 0;         --RESET COUNTER

               plog.debug (pkgctx, 'l_remainqtty: ' || l_remainqtty);
               if l_build_msg.SPLOPT='Q' then --Tach theo so lenh
                        l_breakingsize:= l_build_msg.SPLVAL;
               elsif l_build_msg.SPLOPT='O' then
                        l_breakingsize:= round(l_remainqtty/to_number(l_build_msg.SPLVAL) +
                                                case when l_build_msg.tradeplace='001' then 5-0.01
                                                     when l_build_msg.tradeplace='002' then 50-0.01
                                                     else 0.5-0.01 end,
                                                case when l_build_msg.tradeplace='001' then -1
                                                     when l_build_msg.tradeplace='002' then -2
                                                     else 0 end);
               else
                        l_breakingsize:= l_remainqtty;
               end if;
               IF l_build_msg.tradeplace = '001' then
                    --Neu san HSX thi xe toi da theo l_hosebreakingsize
                    if l_breakingsize > l_hosebreakingsize then
                        l_breakingsize:=l_hosebreakingsize;
                    else
                        l_breakingsize:=l_breakingsize;
                    end if;
               ELSIF l_build_msg.tradeplace in( '002','005') then
                    --Neu san HNX thi xe toi da theo l_hasebreakingsize
                    if l_breakingsize > l_hasebreakingsize then
                        l_breakingsize:=l_hasebreakingsize;
                    else
                        l_breakingsize:=l_breakingsize;
                    end if;
               end if;
               WHILE l_remainqtty > 0                               --quantity
               LOOP
                  SAVEPOINT sp#2;
                  l_order_count   := l_order_count + 1;

                  /*IF l_build_msg.tradeplace = '001'
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
                  END IF;*/
                  l_txmsg.txfields ('12').VALUE   :=
                        CASE
                           WHEN l_remainqtty > l_breakingsize
                           THEN
                              l_breakingsize
                           ELSE
                              l_remainqtty
                        END;
                  -- SET FEE AMOUNT
                  l_txmsg.txfields ('40').VALUE     :=
                    greatest(l_feerate/100 * TO_NUMBER (l_txmsg.txfields('12').VALUE)         --quantity
                     * TO_NUMBER (l_build_msg.fld11)       --quoteprice
                     * TO_NUMBER (l_build_msg.fld98),l_feeamountmin);

                  --2.1 Set txnum
                  SELECT systemnums.c_fo_prefixed
                         || LPAD (seq_fotxnum.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;

                  --v_strOrderID = FO_PREFIXED & "00" & Mid(Replace(v_strTXDATE, "/", vbNullString), 1, 4) & Mid(Replace(v_strTXDATE, "/", vbNullString), 7, 2) & Strings.Right(gc_FORMAT_ODAUTOID & CStr(v_DataAccess.GetIDValue("ODMAST")), Len(gc_FORMAT_ODAUTOID))
                  /*SELECT    systemnums.c_fo_prefixed
                         || '00'
                         || TO_CHAR (SYSDATE, 'DDMMRR')
                         || LPAD (seq_odmast.NEXTVAL, 6, '0')
                  INTO l_txmsg.txfields ('04').VALUE
                  FROM DUAL;*/

                  SELECT    systemnums.c_fo_prefixed
                         || '10'
                         || TO_CHAR(TO_DATE (VARVALUE, 'DD\MM\RR'),'DDMMRR')
                         || LPAD (seq_odmast.NEXTVAL, 6, '0')
                  INTO l_txmsg.txfields ('04').VALUE
                  FROM SYSVAR WHERE VARNAME ='CURRDATE' AND GRNAME='SYSTEM';

              /*    plog.debug (pkgctx,
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
                  );*/

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

                 /* plog.debug (pkgctx,
                              'DESC: ' || l_txmsg.txfields ('30').VALUE
                  );*/

                  INSERT INTO rootordermap
                 (
                     foacctno,
                     orderid,
                     status,
                     MESSAGE,
                     id
                 )
                  VALUES (
                            l_build_msg.acctno,
                            l_txmsg.txfields ('04').VALUE,
                            'A',
                            '[' || systemnums.c_success || '] OK,',
                            l_order_count
                         );

                  -- Get tltxcd from EXECTYPE
                  IF l_txmsg.txfields ('22').VALUE = 'NB'               --8876
                  THEN
                     BEGIN
                        l_txmsg.tltxcd   := '8876'; -- gc_OD_PLACENORMALBUYORDER_ADVANCED
                        --85    ISBONDTRANSACT     C
                        l_txmsg.txfields ('85').defname   := 'ISBONDTRANSACT';
                        l_txmsg.txfields ('85').TYPE      := 'C';
                        l_txmsg.txfields ('85').value     := 'N';
                        --86    BONDINFO     C
                        l_txmsg.txfields ('86').defname   := 'BONDINFO';
                        l_txmsg.txfields ('86').TYPE      := 'C';
                        l_txmsg.txfields ('86').value     := null;
                        -- 2: Process
                        IF txpks_#8876.fn_autotxprocess (l_txmsg,
                                                         p_err_code,
                                                         l_err_param
                           ) <> systemnums.c_success
                        THEN
                           plog.debug (pkgctx,
                                       'got error 8876: ' || p_err_code
                           );
                           --ONLY ROLLBACK FOR THIS MESSAGE
                           ROLLBACK TO SAVEPOINT sp#2;
                           -- Neu lenh thieu suc mua thi dong bo lai ci
                          IF nvl(p_err_code,'0') = '-400116' THEN
                                jbpks_auto.pr_trg_account_log(l_build_msg.fld03, 'CI');
                          END IF;
                           --EXIT; -- UNCOMMENT THIS IF YOU WANT TO EXIT LOOP WHEN GOT AN ERROR
                           RAISE errnums.e_biz_rule_invalid;
                        END IF;
                     END;                                               --8876
                  ELSIF l_build_msg.fld22 IN ('NS', 'MS', 'SS')  --8877
                  THEN
                     BEGIN
                        l_txmsg.tltxcd   := '8877'; --gc_OD_PLACENORMALSELLORDER_ADVANCED
                        --85    ISBONDTRANSACT     C
                        l_txmsg.txfields ('85').defname   := 'ISBONDTRANSACT';
                        l_txmsg.txfields ('85').TYPE      := 'C';
                        l_txmsg.txfields ('85').value     := 'N';
                        --86    BONDINFO     C
                        l_txmsg.txfields ('86').defname   := 'BONDINFO';
                        l_txmsg.txfields ('86').TYPE      := 'C';
                        l_txmsg.txfields ('86').value     := null;
                        -- 2: Process
                        IF txpks_#8877.fn_autotxprocess (l_txmsg,
                                                         p_err_code,
                                                         l_err_param
                           ) <> systemnums.c_success
                        THEN
                           plog.debug (pkgctx,
                                          '8877: '
                                       || p_err_code
                                       || ':'
                                       || l_err_param
                           );
                           --ONLY ROLLBACK FOR THIS MESSAGE
                           ROLLBACK TO SAVEPOINT sp#2;
                           --EXIT; -- UNCOMMENT THIS IF YOU WANT TO EXIT LOOP WHEN GOT AN ERROR
                           RAISE errnums.e_biz_rule_invalid;
                        END IF;
                     END;                                              -- 8887
                  ELSIF l_build_msg.fld22 = 'AB'                 --8884
                  THEN
                     BEGIN
                        l_txmsg.tltxcd   := '8884';  --gc_OD_AMENDMENTBUYORDER

                        -- 2: Process
                        IF txpks_#8884.fn_autotxprocess (l_txmsg,
                                                         p_err_code,
                                                         l_err_param
                           ) <> systemnums.c_success
                        THEN
                           plog.debug (pkgctx,
                                       'got error 8884: ' || p_err_code
                           );
                           --ONLY ROLLBACK FOR THIS MESSAGE
                           ROLLBACK TO SAVEPOINT sp#2;
                           -- Neu lenh thieu suc mua thi dong bo lai ci
                          IF nvl(p_err_code,'0') = '-400116' THEN
                                jbpks_auto.pr_trg_account_log(l_build_msg.fld03, 'CI');
                          END IF;
                           --EXIT; -- UNCOMMENT THIS IF YOU WANT TO EXIT LOOP WHEN GOT AN ERROR
                           RAISE errnums.e_biz_rule_invalid;
                        END IF;
                     END;                                               --8884
                  ELSIF l_build_msg.fld22 = 'AS'                 --8885
                  THEN
                     BEGIN
                        l_txmsg.tltxcd   := '8885'; --gc_OD_AMENDMENTSELLORDER

                        -- 2: Process
                        IF txpks_#8885.fn_autotxprocess (l_txmsg,
                                                         p_err_code,
                                                         l_err_param
                           ) <> systemnums.c_success
                        THEN
                           plog.debug (pkgctx,
                                       'got error 8885: ' || p_err_code
                           );
                           --ONLY ROLLBACK FOR THIS MESSAGE
                           ROLLBACK TO SAVEPOINT sp#2;
                           --EXIT; -- UNCOMMENT THIS IF YOU WANT TO EXIT LOOP WHEN GOT AN ERROR
                           RAISE errnums.e_biz_rule_invalid;
                        END IF;
                     END;                                               --8885
                  ELSIF l_build_msg.fld22 = 'CB'                 --8882
                  THEN
                     BEGIN
                        l_txmsg.tltxcd   := '8882';     --gc_OD_CANCELBUYORDER

                        -- 2: Process
                        IF txpks_#8882.fn_autotxprocess (l_txmsg,
                                                         p_err_code,
                                                         l_err_param
                           ) <> systemnums.c_success
                        THEN
                           plog.debug (pkgctx,
                                       'got error 8882: ' || p_err_code
                           );
                           --ONLY ROLLBACK FOR THIS MESSAGE
                           ROLLBACK TO SAVEPOINT sp#2;
                           --EXIT; -- UNCOMMENT THIS IF YOU WANT TO EXIT LOOP WHEN GOT AN ERROR
                           RAISE errnums.e_biz_rule_invalid;
                        END IF;
                     END;                                               --8882
                  ELSIF l_build_msg.fld22 = 'CS'                 --8883
                  THEN
                     BEGIN
                        l_txmsg.tltxcd   := '8883';    --gc_OD_CANCELSELLORDER

                        -- 2: Process
                        IF txpks_#8883.fn_autotxprocess (l_txmsg,
                                                         p_err_code,
                                                         l_err_param
                           ) <> systemnums.c_success
                        THEN
                           plog.debug (pkgctx,
                                       'got error 8883: ' || p_err_code
                           );
                           --ONLY ROLLBACK FOR THIS MESSAGE
                           ROLLBACK TO SAVEPOINT sp#2;
                           --EXIT; -- UNCOMMENT THIS IF YOU WANT TO EXIT LOOP WHEN GOT AN ERROR
                           RAISE errnums.e_biz_rule_invalid;
                        END IF;
                     END;
                  END IF;

                  UPDATE fomast
                  SET orgacctno    = l_txmsg.txfields ('04').VALUE,
                      status       = 'A',
                      feedbackmsg   =
                         'Order is active and sucessfull processed: '
                         || l_txmsg.txfields ('04').VALUE
                  WHERE acctno = l_build_msg.acctno;



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
                  plog.error (pkgctx,
                                 'row:'
                              || dbms_utility.format_error_backtrace
                  );
                  p_err_code:=errnums.c_od_odtype_notfound;
                  UPDATE fomast
                  SET status    = 'R',
                             feedbackmsg   =
                                '[' || errnums.c_od_odtype_notfound || '] '
                                || cspks_system.fn_get_errmsg(errnums.c_od_odtype_notfound)
                  WHERE acctno = l_build_msg.acctno;
               WHEN errnums.e_invalid_session
               THEN
                  -- Log error and continue to process the next order
                  plog.error (pkgctx,
                                 'INVALID SESSION(pricetype,mktstatus):'
                              || l_build_msg.fld27
                              || ','
                              || l_mktstatus
                  );
                  p_err_code:=errnums.c_invalid_session;
                  UPDATE fomast
                  SET status    = 'R',
                      feedbackmsg   =
                         '[' || errnums.c_invalid_session || '] '
                         || cspks_system.fn_get_errmsg(errnums.c_invalid_session)
                  WHERE acctno = l_build_msg.acctno;
               --LogOrderMessage(v_ds.Tables(0).Rows(i)("ACCTNO"))
               WHEN errnums.e_biz_rule_invalid
               THEN
                  -- KIEM TRA NEU TH CHIA LENH MA DA CO LENH CHIA THANH CONG THI KO CAP NHAT LENH TRONG FOMAST
                  --- lenh GTC khong cap nhat.
                  IF NOT (l_remainqtty < l_build_msg.fld12) and p_timetype <> 'G' THEN
                  -- Neu lenh Bloomberg, thieu tien hoac thieu CK thi de trang thai cho xu ly tiep
                    -- DungNH, 02-Nov-2015
                    IF (nvl(p_err_code,'0') = '-400116' OR nvl(p_err_code,'0') = '-900017') AND l_build_msg.fld25 = 'L' AND l_CUSTATCOM = 'N' AND l_build_msg.fld22 in ('NB','NS') THEN
                        UPDATE fomast
                          SET status        = 'T',
                              feedbackmsg   = '[' || p_err_code || '] ' || l_err_param
                          WHERE acctno = l_build_msg.acctno;
                      -- Ket thuc sua cho Bloomberg
                    ELSE
                        UPDATE fomast
                          SET status        = 'R',
                              feedbackmsg   = '[' || p_err_code || '] ' || l_err_param
                          WHERE acctno = l_build_msg.acctno;

                          INSERT INTO rootordermap
                         (
                             foacctno,
                             orderid,
                             status,
                             MESSAGE,
                             id
                         )
                          VALUES (
                                    l_build_msg.acctno,
                                    '',
                                    'R',
                                    '[' || p_err_code || '] ' || l_err_param,
                                    l_order_count
                                 );
                     end if;
                  END IF;

                when others
                then
                  p_err_code:=errnums.C_SYSTEM_ERROR;
                  plog.error (pkgctx,'Error when send syn order!');
            END;
      END LOOP;
      /***************************************************************************************************
      ** END;
      ***************************************************************************************************/
      plog.debug (pkgctx, '<<END OF pr_fo2odsyn_bl');
      plog.setendsection (pkgctx, 'pr_fo2odsyn_bl');
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         plog.error (pkgctx, dbms_utility.format_error_backtrace);

         CLOSE curs_build_msg;

         plog.setendsection (pkgctx, 'pr_fo2odsyn_bl');
   END pr_fo2odsyn_bl;
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
      plog.init ('txpks_txpks_auto',
                 plevel => NVL (logrow.loglevel, 30),
                 plogtable => (NVL (logrow.log4table, 'N') = 'Y'),
                 palert => (NVL (logrow.log4alert, 'N') = 'Y'),
                 ptrace => (NVL (logrow.log4trace, 'N') = 'Y')
      );
   -- plog.error('level2: ' || logrow.loglevel);

END txpks_auto;
/
