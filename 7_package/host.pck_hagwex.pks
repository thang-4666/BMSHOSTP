SET DEFINE OFF;
CREATE OR REPLACE PACKAGE pck_hagwex
  IS

  PROCEDURE matching_normal_order (
   firm               IN   VARCHAR2,
   order_number       IN   VARCHAR2,
   order_entry_date   IN   VARCHAR2,
   side_alph          IN   VARCHAR2,
   filler             IN   VARCHAR2,
   deal_volume        IN   NUMBER,
   deal_price         IN   NUMBER,
   confirm_number     IN   VARCHAR2,
   v_CheckProcess      in  OUT BOOLEAN
);
 PROCEDURE confirm_cancel_normal_order (
    pv_orderid   IN   VARCHAR2,
    pv_qtty      IN   NUMBER,
    v_CheckProcess in OUT BOOLEAN
);

  PROCEDURE CONFIRM_REPLACE_NORMAL_ORDER (
   pv_ordernumber   IN   VARCHAR2,
   pv_qtty       IN   NUMBER,
   pv_price      IN   NUMBER,
   pv_LeavesQty IN   NUMBER,
   v_CheckProcess       in OUT BOOLEAN
);
FUNCTION getduedate (busdate IN DATE,
    clearcd IN VARCHAR2,
    pv_tradeplace IN VARCHAR2,
    clearday IN NUMBER)
  RETURN  DATE;
END; -- Package spec
 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY pck_hagwex
IS
    pkgctx plog.log_ctx;
    logrow tlogdebug%ROWTYPE;
FUNCTION getduedate (busdate IN DATE,
    clearcd IN VARCHAR2,
    pv_tradeplace IN VARCHAR2,
    clearday IN NUMBER)
  RETURN  DATE IS

   duedate  DATE;
   v_err varchar2(200);

BEGIN
    --ngoc.vu-Jira561
    /*SELECT SBDATE INTO duedate
                FROM sbcurrdate
                WHERE sbtype=clearcd AND NUMDAY=clearday ;*/
    SELECT SBDATE INTO duedate
                FROM sbcurrdate4new
                WHERE sbtype=clearcd AND NUMDAY=clearday and tradeplace= pv_tradeplace;
    RETURN duedate ;
EXCEPTION when others then
   v_err:=substr(sqlerrm,1,199);
       RETURN '01-JAN-2000';
END;
PROCEDURE matching_normal_order (
    firm               IN   VARCHAR2,
    order_number       IN   VARCHAR2,
    order_entry_date   IN   VARCHAR2,
    side_alph          IN   VARCHAR2,
    filler             IN   VARCHAR2,
    deal_volume        IN   NUMBER,
    deal_price         IN   NUMBER,
    confirm_number     IN   VARCHAR2,
    v_CheckProcess in OUT BOOLEAN
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
   mv_strconfirm_no     VARCHAR2 (30);
   mv_strmatch_date     VARCHAR2 (30);
   mv_desc              VARCHAR2 (30);
   v_strduetype         VARCHAR (2);
   v_matched            NUMBER (10,2);
   v_ex                 EXCEPTION;
   v_err                VARCHAR2 (100);
   v_temp               NUMBER(10);
   v_refconfirmno       VARCHAR2 (30);
   v_order_number       VARCHAR2(30);
   mv_mtrfday                NUMBER(10);
   l_trfbuyext              number(10);
   mv_strtradeplace      VARCHAR2(3);
   v_ticksize           NUMBER(20,4);
   l_dblExecQtty        number(20,0);
   v_strcorebank char(1);

   Cursor c_Odmast(v_OrgOrderID Varchar2) Is
   SELECT FOACCTNO,REMAINQTTY,EXECQTTY,EXECAMT,CANCELQTTY,ADJUSTQTTY
   FROM ODMAST WHERE TIMETYPE ='G' AND ORDERID=v_OrgOrderID;
   vc_Odmast c_Odmast%Rowtype;


BEGIN
    plog.setbeginsection (pkgctx, 'matching_normal_order');
   --0 lay cac tham so
   v_brid := '0000';
   v_tlid := '0000';
   v_ipaddress := 'HOST';
   v_wsname := 'HOST';
   v_tltxcd := '8804';

   mv_strtradeplace:='002';

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
      WHEN OTHERS
      THEN
        plog.error(pkgctx,SQLERRM || '--' || dbms_utility.format_error_backtrace);
        plog.setendsection (pkgctx, 'matching_normal_order');
        Return;
   END;
   v_order_number :=order_number;
   BEGIN
      SELECT orgorderid
        INTO mv_strorgorderid
        FROM ordermap_ha
       WHERE order_number = v_order_number;
   EXCEPTION
      WHEN OTHERS
      THEN
        plog.error(pkgctx,SQLERRM || '--' || dbms_utility.format_error_backtrace);
        plog.error(pkgctx,'HAGW-Matching cant not find ordermap  order_number '||order_number);
        v_CheckProcess := FALSE;
        plog.setendsection (pkgctx, 'matching_normal_order');
        return;
   END;
  --Kiem tra doi da thuc hien khop voi confirm number hay chua, neu da khop exit


    /*  SELECT COUNT(*)
        INTO V_TEMP
        FROM IOD
       WHERE ORGORDERID = MV_STRORGORDERID
       AND   CONFIRM_NO = TRIM(CONFIRM_NUMBER)
       AND IOD.deltd <>'Y';

        IF V_TEMP > 0 THEN
            plog.error(pkgctx,'HAGW-Matching duplicate CONFIRM_NUMBER '||CONFIRM_NUMBER||' order_number ='||order_number);
            plog.setendsection (pkgctx, 'matching_normal_order');
            RETURN;
            END IF;*/



    --TungNT modified - for T2 late send money
   BEGIN
      SELECT od.remainqtty, ood.codeid, ood.symbol, ood.custodycd,
             ood.bors, ood.norp, ood.aorn, od.afacctno,
             od.ciacctno, od.seacctno, '', '',
             od.clearcd, ood.price, ood.qtty, deal_price,
             deal_volume, od.clearday, od.bratio,
             confirm_number, v_txdate, '', typ.mtrfday,
             /*'002'*/ sb.tradeplace,
             od.execqtty
        INTO mv_strremainqtty, mv_strcodeid, mv_strsymbol, mv_strcustodycd,
             mv_strbors, mv_strnorp, mv_straorn, mv_strafacctno,
             mv_strciacctno, mv_strseacctno, mv_reforderid, mv_refcustcd,
             mv_strclearcd, mv_strexprice, mv_strexqtty, mv_strprice,
             mv_strqtty, mv_strclearday, mv_strsecuredratio,
             mv_strconfirm_no, mv_strmatch_date, mv_desc,mv_mtrfday,
             mv_strtradeplace,
             l_dblExecQtty
        FROM odmast od, ood, odtype typ, SBSECURITIES sb
       WHERE orderid = mv_strorgorderid and od.codeid=sb.codeid
         and  od.orderid = ood.orgorderid and od.actype = typ.actype;

   EXCEPTION
      WHEN OTHERS
      THEN
        plog.error(pkgctx,SQLERRM || '--' || dbms_utility.format_error_backtrace);
        plog.error(pkgctx,'HAGW-Matching Lay thong tin lenh goc orderid '||mv_strorgorderid);
        plog.setendsection (pkgctx, 'matching_normal_order');
        RETURN;
   END;

    BEGIN
        INSERT INTO iodqueue (TXDATE,BORS,CONFIRM_NO,SYMBOL,NORP)
        VALUES(TO_DATE (v_txdate, 'DD/MM/YYYY'),mv_strbors,mv_strconfirm_no,mv_strsymbol,mv_strnorp);

    EXCEPTION
      WHEN OTHERS
      THEN
             plog.error(pkgctx,SQLERRM || '--' || dbms_utility.format_error_backtrace);
             plog.error(pkgctx,'HAGW-Matching duplicate CONFIRM_NUMBER '||CONFIRM_NUMBER||' order_number ='||order_number);
             plog.setendsection (pkgctx, 'matching_normal_order');
       RETURN;
    END;

   IF ( mv_strbors ='B' and mv_strexprice < deal_price) or
     ( mv_strbors ='S' and mv_strexprice > deal_price) Then
        rollback;
        v_CheckProcess := FALSE;
        plog.error(pkgctx,'HAGW-Matching Sai gia khop '||mv_strorgorderid);
        plog.setendsection (pkgctx, 'matching_normal_order');
        Return;
   End if;


   --Day vao stctradebook, stctradeallocation de khong bi khop lai:
   v_refconfirmno :='VN'||mv_strbors||mv_strconfirm_no;

   /*
   INSERT INTO stctradebook
            (txdate, confirmnumber, refconfirmnumber, ordernumber, bors,
             volume, price
            )
     VALUES (to_date(v_txdate,'dd/mm/yyyy'), mv_strconfirm_no, v_refconfirmno, order_number, mv_strbors,
             mv_strqtty, mv_strprice
            );


   INSERT INTO stctradeallocation
            (txdate, txnum, refconfirmnumber, orderid, bors, volume,
             price, deltd
            )
     VALUES (to_date(v_txdate,'dd/mm/yyyy'), v_txnum, v_refconfirmno, mv_strorgorderid, mv_strbors, mv_strqtty,
             mv_strprice, 'N'
            );
*/

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
                   v_txtime , 'N', 'N', TO_DATE (v_txdate, 'DD/MM/YYYY'),
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
                   TO_DATE (v_txdate, 'DD/MM/YYYY'), '16', 0, TRIM(CONFIRM_NUMBER), NULL
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

      --2 THEM VAO TRONG orderdeal
      /*INSERT INTO orderdeal
                  (firm, order_number, orderid, order_entry_date,
                   side_alph, filler, volume, price,
                   confirm_number, MATCHED
                  )
           VALUES (firm, order_number, mv_strorgorderid, order_entry_date,
                   side_alph, filler, deal_volume, deal_price,
                   confirm_number, 'Y'
                  );*/


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
                   mv_strprice, mv_strqtty, mv_strconfirm_no,to_char(sysdate,'hh24:mi:ss')
                  );

    ---- GHI NHAT VAO BANG TINH GIA VON CUA TUNG LAN KHOP.
      SECMAST_GENERATE(v_txnum, v_txdate, v_txdate, mv_strafacctno, mv_strcodeid, 'T', (CASE WHEN mv_strbors = 'B' THEN 'I' ELSE 'O' END), null, mv_strorgorderid, mv_strqtty, mv_strprice, 'Y');
    --    INSERT INTO SECMAST_GENERATE_LOG (TXNUM,TXDATE,BUSDATE,AFACCTNO,SYMBOL,SECTYPE,PTYPE,CAMASTID,ORDERID,QTTY,COSTPRICE,MAPAVL,STATUS,LOGTIME,APPLYTIME)
      --  VALUES(v_txnum,v_txdate,v_txdate,mv_strafacctno,mv_strcodeid,'T',(CASE WHEN mv_strbors = 'B' THEN 'I' ELSE 'O' END),NULL,mv_strorgorderid,mv_strqtty,mv_strprice,'Y','P',SYSTIMESTAMP,NULL);

            -- if instr('/NS/MS/SS/', :newval.exectype) > 0 then
            if mv_strbors = 'S' then
                -- quyet.kieu : Them cho LINHLNB 21/02/2012
                -- Begin Danh sau tai san LINHLNB
                INSERT INTO odchanging_trigger_log (AFACCTNO,CODEID,AMT,TXNUM,TXDATE,ERRCODE,LAST_CHANGE,ORDERID,ACTIONFLAG,QTTY)
                VALUES( mv_strafacctno,mv_strcodeid ,mv_strprice * mv_strqtty ,v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'),NULL,systimestamp,mv_strorgorderid,'M',mv_strqtty);
                -- End Danh dau tai san LINHLNB
            end if;

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
                   amt = amt + mv_strprice * mv_strqtty
             WHERE orgorderid = mv_strorgorderid AND duetype = v_strduetype;
         ELSE
            INSERT INTO stschd
                        (autoid, orgorderid, codeid,
                         duetype, afacctno, acctno,
                         reforderid, txnum,
                         txdate, clearday,
                         clearcd, amt, aamt,
                         qtty, aqtty, famt, status, deltd, costprice,
                         CLEARDATE
                        )
                 VALUES (seq_stschd.NEXTVAL, mv_strorgorderid, mv_strcodeid,
                         v_strduetype, mv_strafacctno, mv_strseacctno,
                         mv_reforderid, v_txnum,
                         TO_DATE (v_txdate, 'DD/MM/YYYY'), mv_strclearday,
                         mv_strclearcd, mv_strprice * mv_strqtty, 0,
                         mv_strqtty, 0, 0, 'N', 'N', 0,
                        getduedate(TO_DATE (v_txdate, 'DD/MM/YYYY'),mv_strclearcd,/*'000'*/mv_strtradeplace,mv_strclearday) --ngoc.vu-Jira561
                        );
         END IF;

         --Tao lich thanh toan tien
       /* select case when mrt.mrtype <> 'N' and aft.istrfbuy <> 'N' then trfbuyext
            else 0 end into l_trfbuyext
        from afmast af, aftype aft, mrtype mrt
        where af.actype = aft.actype and aft.mrtype = mrt.actype and af.acctno = mv_strafacctno;*/
        l_trfbuyext:=0;

         v_strduetype := 'SM';

         IF v_matched > 0
         THEN
            UPDATE stschd
               SET qtty = qtty + mv_strqtty,
                   amt = amt + mv_strprice * mv_strqtty
             WHERE orgorderid = mv_strorgorderid AND duetype = v_strduetype;
         ELSE
            --TungNT modified , for late T2 send money
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
                         mv_strclearcd, mv_strprice * mv_strqtty, 0,
                         mv_strqtty, 0, 0, 'N', 'N', 0,
                         getduedate(TO_DATE (v_txdate, 'DD/MM/YYYY'),mv_strclearcd,/*'000'*/mv_strtradeplace,least(mv_mtrfday,l_trfbuyext)) --ngoc.vu-Jira561
                        );
            --Emd
         END IF;

      ELSE                                                          --Lenh ban
         --Tao lich thanh toan chung khoan
         v_strduetype := 'SS';

         IF v_matched > 0
         THEN
            UPDATE stschd
               SET qtty = qtty + mv_strqtty,
                   amt = amt + mv_strprice * mv_strqtty
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
                         mv_strclearcd, mv_strprice * mv_strqtty, 0,
                         mv_strqtty, 0, 0, 'N', 'N', 0, getduedate(TO_DATE (v_txdate, 'DD/MM/YYYY'),mv_strclearcd,/*'000'*/mv_strtradeplace,0) --ngoc.vu-Jira561
                        );
         END IF;

         --Tao lich thanh toan tien
         v_strduetype := 'RM';

         IF v_matched > 0
         THEN
            UPDATE stschd
               SET qtty = qtty + mv_strqtty,
                   amt = amt + mv_strprice * mv_strqtty
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
                         mv_strclearcd, mv_strprice * mv_strqtty, 0,
                         mv_strqtty, 0, 0, 'N', 'N', 0, getduedate(TO_DATE (v_txdate, 'DD/MM/YYYY'),mv_strclearcd,/*'000'*/mv_strtradeplace,mv_strclearday) --ngoc.vu-Jira561
                        );
         END IF;
      END IF;


      --CAP NHAT TRAN VA MAST
            --BUY
      UPDATE OOD
      SET OODSTATUS = 'S', TXTIME = TO_CHAR(SYSDATE,'HH24:MI:SS')
      WHERE ORGORDERID = mv_strorgorderid AND OODSTATUS <> 'S';



       UPDATE odmast
         SET orstatus = '4',
             PORSTATUS = '4',
             execqtty = execqtty + mv_strqtty ,
             remainqtty = remainqtty - mv_strqtty,
             execamt = execamt + mv_strqtty * mv_strprice,
             matchamt = matchamt + mv_strqtty * mv_strprice
       WHERE orderid = mv_strorgorderid;
       /*UPDATE odmast
         SET HOSESESSION = (SELECT SYSVALUE  FROM ORDERSYS WHERE SYSNAME = 'CONTROLCODE')
       WHERE orderid = mv_strorgorderid And HOSESESSION ='N';*/



      --Neu khop het va co lenh huy cua lenh da khop thi cap nhat thanh refuse
      IF mv_strremainqtty = mv_strqtty THEN
          UPDATE odmast
             SET ORSTATUS = '0'
           WHERE REFORDERID = mv_strorgorderid;
            /*Update ood O set oodstatus ='N' where oodstatus ='B' and REFORDERID = mv_strorgorderid
           and EXISTS   (select orderid from odmast where ORDERID=O.orgorderid AND orstatus ='0');*/
        Else
        -- hoac lenh sua ve khoi luong <= khoi luong khop cung refuse
          UPDATE odmast
             SET ORSTATUS = '0'
           WHERE exectype in ('AS','AB') And orderqtty <= l_dblExecQtty + mv_strqtty
           And REFORDERID = mv_strorgorderid;

          /* Update ood O set oodstatus ='N' where oodstatus ='B' and REFORDERID = mv_strorgorderid
           and  EXISTS   (select orderid from odmast where ORDERID=O.orgorderid AND orstatus ='0');*/
        END IF;

      --Cap nhat tinh gia von

      IF mv_strbors = 'B' THEN
          UPDATE semast SET dcramt = dcramt + mv_strqtty*mv_strprice, dcrqtty = dcrqtty+mv_strqtty WHERE acctno = mv_strseacctno;
      END IF;

      IF mv_strbors = 'B' THEN
            INSERT INTO setran
                   (txnum, txdate,
                    acctno, txcd, namt, camt,
                    REF, deltd, autoid,TLTXCD
                   )
            VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'),
                    mv_strseacctno, '0051', mv_strqtty * mv_strprice, NULL,
                    NULL, 'N', seq_setran.NEXTVAL,'8804'
                   );

            INSERT INTO setran
                   (txnum, txdate,
                    acctno, txcd, namt, camt,
                    REF, deltd, autoid,TLTXCD
                   )
            VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'),
                    mv_strseacctno, '0052', mv_strqtty, NULL,
                    NULL, 'N', seq_setran.NEXTVAL,'8804'
                   );
        END IF;

        IF mv_strbors = 'S' THEN
          UPDATE semast SET DDROUTAMT = DDROUTAMT + mv_strqtty*mv_strprice, DDROUTQTTY = DDROUTQTTY+mv_strqtty WHERE acctno = mv_strseacctno;
      END IF;

      IF mv_strbors = 'S' THEN
            INSERT INTO setran
                   (txnum, txdate,
                    acctno, txcd, namt, camt,
                    REF, deltd, autoid,TLTXCD
                   )
            VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'),
                    mv_strseacctno, '0067', mv_strqtty * mv_strprice, NULL,
                    NULL, 'N', seq_setran.NEXTVAL,'8804'
                   );

            INSERT INTO setran
                   (txnum, txdate,
                    acctno, txcd, namt, camt,
                    REF, deltd, autoid,TLTXCD
                   )
            VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'),
                    mv_strseacctno, '0068', mv_strqtty, NULL,
                    NULL, 'N', seq_setran.NEXTVAL,'8804'
                   );
        END IF;

   /*   INSERT INTO odtran
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
                   mv_strorgorderid, '0028', mv_strqtty * mv_strprice, NULL,
                   NULL, 'N', NULL, seq_odtran.NEXTVAL
                  );

      INSERT INTO odtran
                  (txnum, txdate,
                   acctno, txcd, namt, camt,
                   acctref, deltd, REF, autoid
                  )
           VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'),
                   mv_strorgorderid, '0034', mv_strqtty * mv_strprice, NULL,
                   NULL, 'N', NULL, seq_odtran.NEXTVAL
                  );*/



      --TungNT added , giai toa khi sua lenh
        /*if mv_strbors ='B' and mv_strexprice > mv_strprice then
          --select corebank into v_strcorebank from afmast where acctno =v_afaccount;
          select (case when af.corebank = 'Y' then af.corebank else af.alternateacct end)  into v_strcorebank
          from afmast af where acctno =mv_strafacctno;
          if v_strcorebank ='Y' then

             BEGIN
               cspks_rmproc.pr_RM_Unholdaccount(mv_strafacctno, v_err);
             EXCEPTION WHEN OTHERS THEN
                null;
             END;
          end if;
        end if;*/
        --End

  ELSE
      --ket qua tra ve khong hop le
              --2 THEM VAO TRONG orderdeal
      /*INSERT INTO orderdeal
                  (firm, order_number, orderid, order_entry_date,
                   side_alph, filler, volume, price,
                   confirm_number, MATCHED
                  )
           VALUES (firm, order_number, mv_strorgorderid, order_entry_date,
                   side_alph, filler, deal_volume, deal_price,
                   confirm_number, 'N'
                  );*/
                  null;
   END IF;
   --Cap nhat cho GTC
   OPEN C_ODMAST(MV_STRORGORDERID);
   FETCH C_ODMAST INTO VC_ODMAST;
    IF C_ODMAST%FOUND THEN
         UPDATE FOMAST SET REMAINQTTY= REMAINQTTY - MV_STRQTTY
                            ,EXECQTTY= EXECQTTY + MV_STRQTTY
                            ,EXECAMT=  EXECAMT + MV_STRPRICE * MV_STRQTTY
          --WHERE ORGACCTNO= MV_STRORGORDERID;
          WHERE ACCTNO= VC_ODMAST.FOACCTNO;
    END IF;
   CLOSE C_ODMAST;
    plog.setendsection (pkgctx, 'matching_normal_order');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx,SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.error(pkgctx,'HAGW-matching_normal_order order_number='||order_number);
    v_CheckProcess := FALSE;
    plog.setendsection (pkgctx, 'matching_normal_order');
    rollback;
END matching_normal_order;
PROCEDURE CONFIRM_REPLACE_NORMAL_ORDER (
    pv_ordernumber   IN   VARCHAR2,
    pv_qtty       IN   NUMBER,
    pv_price      IN   NUMBER,
    pv_LeavesQty IN   NUMBER,
    v_CheckProcess in OUT BOOLEAN
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
   v_ReplaceQtty_Cur   Number(10);
   v_Orstatus_Cur     VARCHAR2(10);
   v_CustID           VARCHAR2 (30);
   v_Actype           VARCHAR2 (30);
   v_CodeID           VARCHAR2 (30);
   v_TimeType         VARCHAR2 (30);
   v_ExecType         VARCHAR2 (30);
   v_NorK             VARCHAR2 (30);
   v_ClearDay         VARCHAR2 (30);
   v_MATCHTYPE        VARCHAR2 (30);
   v_Via              VARCHAR2 (30);
   v_CLEARCD          VARCHAR2 (30);
   v_PRICETYPE        VARCHAR2 (30);
   v_CUSTODYCD        VARCHAR2 (30);
   v_LIMITPRICE       Number(20,2);
   v_VOUCHER          VARCHAR2 (30);
   v_CONSULTANT       VARCHAR2 (30);
   v_OrderID          VARCHAR2 (30);
   v_replaceqtty      Number(10,2);
   PV_ORDERID          VARCHAR2 (30);
   v_err              VARCHAR2(300);
   v_strcorebank        char(1);
   v_ex                 EXCEPTION;
   v_DFACCTNO         varchar(20); --TheNN added
   v_ISDISPOSAL       varchar(20); --GianhVG added
   l_err_code         VARCHAR2(100);

   v_retlid           varchar2(10);
   v_blorderid        varchar2(50);
   v_isblorder        varchar2(2);
   Cursor c_Odmast(v_OrgOrderID Varchar2) Is
   SELECT REMAINQTTY,EXECQTTY,EXECAMT,CANCELQTTY,ADJUSTQTTY
   FROM ODMAST WHERE TIMETYPE ='G' AND ORDERID=v_OrgOrderID;
   vc_Odmast c_Odmast%Rowtype;
BEGIN
    plog.setbeginsection (pkgctx, 'CONFIRM_REPLACE_NORMAL_ORDER');
   --0 lay cac tham so
   v_brid := '0000';
   v_tlid := '0000';
   v_ipaddress := 'HOST';
   v_wsname := 'HOST';
   v_replaceqtty := pv_qtty;
   Select Orgorderid into PV_ORDERID from Ordermap_Ha where Order_number =pv_ordernumber;
   SELECT ORDERQTTY,REMAINQTTY,EXECQTTY,CANCELQTTY,ORSTATUS,Exectype, TLID
INTO V_ORDERQTTY_CUR,V_REMAINQTTY_CUR,V_EXECQTTY_CUR,V_REPLACEQTTY_CUR,V_ORSTATUS_CUR,v_Exectype, v_tlid
    FROM ODMAST WHERE ORDERID = PV_ORDERID;

    Select TLID, blorderid,isblorder,via into v_tlid, v_blorderid,v_isblorder, v_Via from odmast where reforderid = PV_ORDERID and orstatus <> '6';
-- TheNN, 23-Dec-2013
    -- Neu lenh Bloomberg thi lay so hieu lenh moi trong bl_odmast
     /*   IF v_blorderid IS NOT NULL THEN
            SELECT od.blorderid
            INTO v_blorderid
            FROM odmast od
            WHERE od.reforderid = PV_ORDERID AND edstatus = 'A';
        END IF;*/

  /*  IF V_REMAINQTTY_CUR - v_replaceqtty < 0 OR V_EXECQTTY_CUR >= V_ORDERQTTY_CUR
                 OR v_replaceqtty = 0
   THEN
    RETURN;
   END IF;
*/

   SELECT (CASE
                      WHEN exectype = 'AB'
                         THEN '8890'
                      ELSE '8891'
                   END), sb.symbol,
                  od.afacctno, od.seacctno, od.quoteprice, od.orderqtty, od.bratio,
                  0, od.quoteprice, 0, od.orderqtty - pv_qtty,
                  od.reforderid, sb.tradeunit, od.edstatus,custid,actype,timetype,
                  NorK,MATCHTYPE,Via,CLEARDAY,CLEARCD,PRICETYPE,CUSTODYCD,
                  OD.LIMITPRICE,VOUCHER,CONSULTANT, od.codeid
             INTO v_tltxcd, v_symbol,
                  v_afaccount, v_seacctno, v_price, v_quantity, v_bratio,
                  v_amendmentqtty, v_amendmentprice, v_matchedqtty, v_execqtty,
                  v_reforderid, v_tradeunit, v_edstatus,v_custid,v_actype,v_timetype,
                  v_NorK,v_MATCHTYPE,v_Via,v_CLEARDAY,v_CLEARCD,v_PRICETYPE,v_CUSTODYCD,
                  v_LIMITPRICE,v_VOUCHER,v_CONSULTANT,v_codeid
             FROM odmast od, ood ,  securities_info sb
            WHERE od.codeid = sb.codeid AND od.orderid = ood.orgorderid AND od.reforderid = pv_orderid
             AND OD.orstatus<>'6' and od.exectype in('AB','AS');

   v_advancedamount := 0;


   SELECT bratio, DFACCTNO, ISDISPOSAL
     INTO v_oldbratio, v_DFACCTNO,v_ISDISPOSAL
     FROM odmast
    WHERE orderid = pv_orderid;


      SELECT varvalue
        INTO v_txdate
        FROM sysvar
       WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';

     Select '0001'||to_char(to_date(v_txdate,'dd/mm/yyyy'),'ddmmyy')||lpad(SEQ_ODMAST.NEXTVAL,6,'0')
     into v_OrderID from dual;

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
                   v_txtime, 'N', 'N', TO_DATE (v_txdate, 'DD/MM/YYYY'),
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

      v_edstatus := 'S';
      UPDATE odmast
         SET edstatus = v_edstatus
      WHERE orderid = pv_orderid;
      update odmast set edstatus = v_edstatus
      where reforderid = pv_orderid and exectype = 'AB';
      --Cap nhat lenh sua thanh da Send.
      UPDATE OOD SET OODSTATUS = 'S'
      WHERE ORGORDERID IN (SELECT ORDERID FROM ODMAST  WHERE REFORDERID = pv_orderid)
      and OODSTATUS <> 'S';
      UPDATE ODMAST SET ORSTATUS = '2' WHERE ORDERID IN (SELECT ORDERID FROM ODMAST  WHERE REFORDERID = pv_orderid)
                                       AND ORSTATUS = '8';


      --3 CAP NHAT TRAN VA MAST
       UPDATE odmast
        SET adjustqtty = v_replaceqtty,-- - pv_LeavesQty ,
            remainqtty = v_OrderQtty_Cur + pv_LeavesQty - v_replaceqtty - v_ExecQtty_Cur
        WHERE orderid = pv_orderid;

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
      IF v_tltxcd = '8890'
      THEN
         v_BORS :='B';
      ELSE                                                   --v_tltxcd='8891'
         v_BORS :='S';
      END IF;


   --4 Sinh lenh moi.

   INSERT INTO ODMAST (ORDERID,CUSTID,ACTYPE,CODEID,AFACCTNO
                 ,SEACCTNO,CIACCTNO,
                 TXNUM,TXDATE,TXTIME,EXPDATE,BRATIO,TIMETYPE,
                 EXECTYPE,NORK,MATCHTYPE,VIA,CLEARDAY,CLEARCD,ORSTATUS,PORSTATUS,PRICETYPE,
                 QUOTEPRICE,STOPPRICE,LIMITPRICE,ORDERQTTY,REMAINQTTY,EXPRICE,EXQTTY,SECUREDAMT,
                 EXECQTTY,STANDQTTY,CANCELQTTY,ADJUSTQTTY,REJECTQTTY,REJECTCD,VOUCHER,CONSULTANT,REFORDERID,CORRECTIONNUMBER,TLID,DFACCTNO,ISDISPOSAL
                ,blorderid,isblorder
                 )
          VALUES ( v_ORDERID , v_CUSTID , v_ACTYPE , v_CODEID , v_afaccount
                  ,v_SEACCTNO ,v_afaccount
                  , v_TXNUM ,TO_DATE (v_txdate, 'DD/MM/YYYY'), v_TXTIME
                  ,TO_DATE (v_txdate, 'DD/MM/YYYY'),v_BRATIO ,v_TIMETYPE
                  ,v_EXECTYPE ,v_NORK ,v_MATCHTYPE ,v_VIA ,v_CLEARDAY , v_CLEARCD ,'2','2',v_PRICETYPE
                  ,v_amendmentprice ,0,v_LIMITPRICE ,v_ReplaceQTTY,v_ReplaceQTTY ,v_amendmentprice ,v_ReplaceQTTY,0
                  ,0,0,0,0,0,'001', v_VOUCHER , v_CONSULTANT , pv_orderid , 1, v_tlid, v_DFACCTNO,v_ISDISPOSAL,v_blorderid,v_isblorder
                  );

       --Ghi nhan vao so lenh day di
       INSERT INTO OOD (ORGORDERID,CODEID,SYMBOL,CUSTODYCD,
            BORS,NORP,AORN,PRICE,QTTY,SECUREDRATIO,OODSTATUS,
            TXDATE,TXTIME,TXNUM,DELTD,BRID,REFORDERID)
            VALUES ( v_ORDERID , v_CODEID , v_Symbol ,Replace(v_CUSTODYCD,'.',''),
            v_BORS ,v_MATCHTYPE ,v_NORK ,v_amendmentprice ,v_ReplaceQTTY ,v_BRATIO ,'S' ,
            TO_DATE (v_txdate, 'DD/MM/YYYY'),  v_TXTIME , v_TXNUM ,'N',v_BRID , pv_orderid );

        --Tao ban ghi trong ODQUEUE,ODQUEUELOG xac nhan lenh da day len san
        INSERT INTO ODQUEUE SELECT * FROM OOD WHERE ORGORDERID =  v_ORDERID;
        INSERT INTO ODQUEUELOG SELECT * FROM OOD WHERE ORGORDERID = v_ORDERID;
        --Cap nhat lai ODRERMAP_HA theo so hieu lenh moi cua lenh sua.
        Update Ordermap_ha set rejectcode =  orgorderid where orgorderid =pv_orderid;
        Update Ordermap_ha set orgorderid =  v_ORDERID where orgorderid =pv_orderid;

        --TungNT added , giai toa khi sua lenh
        if v_BORS ='B' then
          --select corebank into v_strcorebank from afmast where acctno =v_afaccount;
          select (case when af.corebank = 'Y' then af.corebank else af.alternateacct end)  into v_strcorebank from afmast af where acctno =v_afaccount;
          if v_strcorebank ='Y' then

             BEGIN
               cspks_rmproc.pr_RM_Unholdaccount(v_afaccount, v_err);
             EXCEPTION WHEN OTHERS THEN
               plog.error(pkgctx,'Error when gen unhold for amend order : ' || v_afaccount);
               plog.error(pkgctx, SQLERRM);
             END;
          end if;
        end if;
        --End

 --Cap nhat cho GTC
   OPEN C_ODMAST(pv_orderid);
   FETCH C_ODMAST INTO VC_ODMAST;
    IF C_ODMAST%FOUND THEN
        --LENH YEU CAU GTO SE BI HUY, DO LENH CON TREN SAN DA THAY DOI
        UPDATE FOMAST SET DELTD='Y' WHERE ORGACCTNO= pv_orderid;

        INSERT INTO FOMAST (ACCTNO, ORGACCTNO, ACTYPE, AFACCTNO, STATUS, EXECTYPE, PRICETYPE,
                    TIMETYPE, MATCHTYPE, NORK, CLEARCD, CODEID, SYMBOL, CONFIRMEDVIA,
                    BOOK, FEEDBACKMSG, ACTIVATEDT, CREATEDDT,
                    CLEARDAY, QUANTITY, PRICE, QUOTEPRICE,
                    TRIGGERPRICE, EXECQTTY, EXECAMT, REMAINQTTY,TXDATE,TXNUM,
                    EFFDATE,EXPDATE,BRATIO,VIA,OUTPRICEALLOW,TLID)
             SELECT v_ORDERID,v_ORDERID,v_ACTYPE,v_afaccount,'A',EXECTYPE,v_PRICETYPE,
                    v_TIMETYPE,v_MATCHTYPE,v_NORK,CLEARCD,v_CODEID,v_Symbol,'N'
                    ,'A','',TO_CHAR(SYSDATE,'DD/MM/RRRR HH:MM:SS'),TO_CHAR(SYSDATE,'DD/MM/RRRR HH:MM:SS'),
                    v_CLEARDAY ,v_ReplaceQTTY, v_amendmentprice/ v_tradeunit ,v_amendmentprice / v_tradeunit ,
                     0 , 0 , 0 ,v_ReplaceQTTY ,TO_DATE(v_txdate, 'dd/mm/rrrr'),v_TXNUM,
                    EFFDATE,EXPDATE,v_BRATIO,v_VIA,OUTPRICEALLOW,TLID
                    FROM FOMAST WHERE ORGACCTNO= pv_orderid;

    END IF;
   CLOSE C_ODMAST;
    plog.setendsection (pkgctx, 'CONFIRM_REPLACE_NORMAL_ORDER');
EXCEPTION WHEN others THEN
    plog.error(pkgctx,SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.error(pkgctx,'CONFIRM_REPLACE_NORMAL_ORDER pv_ordernumber='||pv_ordernumber);
    v_CheckProcess := FALSE;
    plog.setendsection (pkgctx, 'CONFIRM_REPLACE_NORMAL_ORDER');
    rollback;
END CONFIRM_REPLACE_NORMAL_ORDER;
--LAY MESSAGE DAY LEN GW.
PROCEDURE confirm_cancel_normal_order (
    pv_orderid   IN   VARCHAR2,
    pv_qtty      IN   NUMBER,
    v_CheckProcess in OUT BOOLEAN
) IS
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
   v_strCodeid        VARCHAR2(10);

   v_strcorebank      char(1);
   v_stralternateacct char(1);
   v_ex                 EXCEPTION;

   Cursor c_Odmast(v_OrgOrderID Varchar2) Is
   SELECT FOACCTNO,REMAINQTTY,EXECQTTY,EXECAMT,CANCELQTTY,ADJUSTQTTY
   FROM ODMAST WHERE TIMETYPE ='G' AND ORDERID=v_OrgOrderID;
   vc_Odmast c_Odmast%Rowtype;
   v_Count_lenhRP number;
   p_err_code  VARCHAR2(300);
     p_err_message  VARCHAR2(300);

BEGIN
    plog.setbeginsection (pkgctx, 'confirm_cancel_normal_order');
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
        plog.error(pkgctx, 'HAGW_CONFIRM_CANCEL: Error when trying get informations of original order PV_ORDERID='||PV_ORDERID);
        plog.setendsection (pkgctx, 'confirm_cancel_normal_order');
        RETURN;
   END;
   IF V_REMAINQTTY_CUR - V_CANCELQTTY < 0 OR V_EXECQTTY_CUR >= V_ORDERQTTY_CUR
                 OR V_CANCELQTTY = 0
   THEN
        plog.error(pkgctx, 'HAGW_CONFIRM_CANCEL: SAI DK SUA PV_ORDERID='||PV_ORDERID);
        plog.setendsection (pkgctx, 'confirm_cancel_normal_order');
        RETURN;
   END IF;


   --Lenh huy thong thuong: Co lenh huy 1C
   SELECT count(*) INTO v_Count_lenhhuy FROM odmast WHERE reforderid =pv_orderid AND exectype IN ('CB','CS') AND ORSTATUS<>'6';
   IF v_Count_lenhhuy >0 Then
        SELECT (CASE
                      WHEN exectype = 'CB'
                         THEN '8890'
                      ELSE '8891'
                   END), sb.symbol,
                  od.afacctno, od.seacctno, od.quoteprice, od.orderqtty, od.bratio,
                  0, od.quoteprice, 0, od.orderqtty - pv_qtty,
                  od.reforderid, sb.tradeunit, od.edstatus,od.codeid
             INTO v_tltxcd, v_symbol,
                  v_afaccount, v_seacctno, v_price, v_quantity, v_bratio,
                  v_amendmentqtty, v_amendmentprice, v_matchedqtty, v_execqtty,
                  v_reforderid, v_tradeunit, v_edstatus , v_strCodeid
             FROM odmast od, securities_info sb
            WHERE od.codeid = sb.codeid AND reforderid = pv_orderid
             and od.orstatus<>'6';
   ELSE
    --Giai toa ATO
            SELECT (CASE
                      WHEN EXECTYPE LIKE '%B'
                         THEN '8890'
                      ELSE '8891'
                   END), sb.symbol,
                  od.afacctno, od.seacctno, od.quoteprice, od.orderqtty, od.bratio,
                  0, od.quoteprice, 0, od.orderqtty - pv_qtty,
                  od.reforderid, sb.tradeunit, od.edstatus
             INTO v_tltxcd, v_symbol,
                  v_afaccount, v_seacctno, v_price, v_quantity, v_bratio,
                  v_amendmentqtty, v_amendmentprice, v_matchedqtty, v_execqtty,
                  v_reforderid, v_tradeunit, v_edstatus
             FROM odmast od, securities_info sb
            WHERE od.codeid = sb.codeid AND orderid = pv_orderid
                and od.orstatus<>'6';
    END IF;


   v_advancedamount := 0;




      --NEU CHAU BI HUY THI KHI NHAN DUOC MESSAGE TRA VE SE THUC HIEN HUY LENH
      SELECT varvalue
        INTO v_txdate
        FROM sysvar
       WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';

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
                   v_txtime, 'N', 'N', TO_DATE (v_txdate, 'DD/MM/YYYY'),
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
      If v_Count_lenhhuy >0 then
          v_edstatus := 'W';
          UPDATE odmast
             SET edstatus = v_edstatus, cancelstatus ='C' --Huy do san tra ve
          WHERE orderid = pv_orderid;

          UPDATE OOD O SET OODSTATUS = 'S'
          WHERE ORGORDERID IN (SELECT ORDERID FROM ODMAST  WHERE REFORDERID = pv_orderid)
          and OODSTATUS <> 'S';

      Else
        --OOD: Cap nhat E
        --ODMAST:
        --Update OOD set OODSTATUS ='E' where ORGORDERID =pv_orderid;
        Update ODMAST set ORSTATUS ='5' , cancelstatus ='C' --Huy do san tra ve
        where Orderqtty =Remainqtty And ORDERID =pv_orderid;

      End if;
      --3 CAP NHAT TRAN VA MAST
       UPDATE odmast
            SET cancelqtty = cancelqtty + v_cancelqtty,
                remainqtty = remainqtty - v_cancelqtty
          WHERE orderid = pv_orderid;
      /* INSERT INTO odtran
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
                     );*/
     /* IF v_tltxcd = '8890' OR v_tltxcd = '8808'
      THEN
         --BUY
         if v_tltxcd = '8890' OR v_tltxcd='8808' then
                -- quyet.kieu : Them cho LINHLNB 21/02/2012
                -- Begin Danh sau tai san LINHLNB
                INSERT INTO odchanging_trigger_log (AFACCTNO,CODEID,AMT,TXNUM,TXDATE,ERRCODE,LAST_CHANGE,ORDERID,ACTIONFLAG,QTTY)
                VALUES( v_afaccount,v_strCodeid ,v_cancelqtty * v_price ,v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'),NULL,systimestamp,pv_orderid,'C',v_cancelqtty);
                -- End Danh dau tai san LINHLNB
          end if ;

            --TungNT added , giai toa khi huy lenh

          select  af.corebank,af.alternateacct  into v_strcorebank,v_stralternateacct from afmast af where acctno =v_afaccount;
          if v_strcorebank ='Y' then
              BEGIN
                cspks_odproc.pr_RM_UnholdCancelOD(pv_orderid, v_cancelqtty, v_err);
              EXCEPTION WHEN OTHERS THEN
                plog.error(pkgctx,'Error when gen unhold for cancel order : ' || pv_orderid || ' qtty : ' || v_cancelqtty);
                plog.error(pkgctx, SQLERRM);
              END;
          elsif v_stralternateacct='Y' then
               BEGIN
                 cspks_rmproc.pr_RM_UnholdAccount(v_afaccount, v_err);
               EXCEPTION WHEN OTHERS THEN
                 plog.error(pkgctx,'Error when gen unhold for modify order : ' || v_afaccount);
                 plog.error(pkgctx, SQLERRM);
               END;
          end if;
         --End

      END IF;*/

 --Cap nhat cho GTC
   OPEN C_ODMAST(pv_orderid);
   FETCH C_ODMAST INTO VC_ODMAST;
    IF C_ODMAST%FOUND AND  v_Count_lenhhuy >0 THEN
         UPDATE FOMAST SET   REMAINQTTY= REMAINQTTY - v_cancelqtty
                            ,cancelqtty= cancelqtty + v_cancelqtty
          --WHERE ORGACCTNO= pv_orderid;
          WHERE ACCTNO= VC_ODMAST.FOACCTNO;
    END IF;
   CLOSE C_ODMAST;
   ------Ducnv sinh lenh RP

     -- Lenh RP phien 2, khi chuyen sang ATC
    v_Count_lenhRP:= 0;
         Select count(o.orderid) into v_Count_lenhRP
          From odmast o, fomast f, logrporder l, rootordermap R
          Where o.orderid=pv_orderid
              and o.pricetype='LO'
              and o.orderid=R.orderid
              and r.foacctno = f.acctno
              and f.pricetype='RP'
              and o.orderid=l.orderid
              and o.txdate=TO_DATE (v_txdate, 'DD/MM/YYYY');



      If  v_Count_lenhRP>0 then
        For vc in (Select f.username,
                       '' acctno,
                       f.afacctno,
                       f.exectype ,
                       f.symbol,
                      pv_qtty quantity,
                       f.quoteprice,
                       f.pricetype,
                       f.timetype,
                       f.book,
                       f.via,
                      '' dealid,
                      f.direct,
                      f.effdate,
                      f.expdate,
                      f.tlid,
                      f.quoteqtty,
                      f.limitprice
                from fomast f
                where orgacctno=pv_orderid )
         Loop
               fopks_api.pr_PlaceOrder('PLACEORDER',
                        vc.username,
                        vc.acctno ,
                        vc.afacctno ,
                        vc.exectype  ,
                        vc.symbol  ,
                        vc.quantity  ,
                        vc.quoteprice  ,
                        vc.pricetype ,
                        vc.timetype ,
                        vc.book ,
                        vc.via ,
                        vc.dealid ,
                        vc.direct ,
                        vc.effdate ,
                        vc.expdate ,
                        vc.tlid  ,
                        vc.quoteqtty ,
                        vc.limitprice ,
                        p_err_code ,
                        p_err_message
                        );
        End loop;
      End if;  --v_Count_lenhRP>0

----- End of DUCNV
    plog.setendsection (pkgctx, 'confirm_cancel_normal_order');
EXCEPTION WHEN others THEN
    plog.error(pkgctx,SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.error(pkgctx,'HAGW-CONFIRM_CANCEL_NORMAL_ORDER PV_ORDERID='||PV_ORDERID);
    v_CheckProcess := FALSE;
    plog.setendsection (pkgctx, 'confirm_cancel_normal_order');
    rollback;
END CONFIRM_CANCEL_NORMAL_ORDER;
BEGIN
FOR i IN (SELECT * FROM tlogdebug) LOOP
logrow.loglevel  := i.loglevel;
logrow.log4table := i.log4table;
logrow.log4alert := i.log4alert;
logrow.log4trace := i.log4trace;
END LOOP;
pkgctx := plog.init('pck_hagwEX',
          plevel => NVL(logrow.loglevel,30),
          plogtable => (NVL(logrow.log4table,'Y') = 'Y'),
          palert => (logrow.log4alert = 'Y'),
          ptrace => (logrow.log4trace = 'Y'));

END;
/
