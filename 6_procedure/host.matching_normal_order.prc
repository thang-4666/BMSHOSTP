SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE matching_normal_order (
   firm               IN   VARCHAR2,
   order_number       IN   NUMBER,
   order_entry_date   IN   VARCHAR2,
   side_alph          IN   VARCHAR2,
   filler             IN   VARCHAR2,
   deal_volume        IN   NUMBER,
   deal_price         IN   NUMBER,
   confirm_number     IN   NUMBER

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
   mv_mtrfday           NUMBER(10);
   l_trfbuyext          number(10);
   mv_strconfirm_no     VARCHAR2 (30);
   mv_strmatch_date     VARCHAR2 (30);
   mv_desc              VARCHAR2 (30);
   v_strduetype         VARCHAR (2);
   v_matched            NUMBER (10,2);
   v_ex                 EXCEPTION;
   v_err                VARCHAR2 (100);
   v_temp               NUMBER(10);
   v_refconfirmno       VARCHAR2 (30);
   v_tradeplace         VARCHAR2 (30);
    pkgctx   plog.log_ctx;
    v_ticksize           NUMBER(10);
   Cursor c_Odmast(v_OrgOrderID Varchar2) Is
   SELECT REMAINQTTY,EXECQTTY,EXECAMT,CANCELQTTY,ADJUSTQTTY
   FROM ODMAST WHERE TIMETYPE ='G' AND ORDERID=v_OrgOrderID;
   vc_Odmast c_Odmast%Rowtype;


BEGIN
   --0 lay cac tham so
   v_brid := '0000';
   v_tlid := '0000';
   v_ipaddress := 'HOST';
   v_wsname := 'HOST';
   v_tltxcd := '8804';

 plog.error(pkgctx,'matching_normal_order order_number='||order_number);

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

   BEGIN
      SELECT varvalue
        INTO v_txdate
        FROM sysvar
       WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
   EXCEPTION
      WHEN OTHERS
      THEN
         v_err := SUBSTR ('sysvar ' || SQLERRM, 1, 100);
         RAISE v_ex;
   END;

   BEGIN
      SELECT orgorderid
        INTO mv_strorgorderid
        FROM ordermap
       WHERE ctci_order = order_number;
   EXCEPTION
      WHEN OTHERS
      THEN
         v_err :=
            SUBSTR (   'select mv_strorgorderid order_number= '
                    || order_number
                    || SQLERRM,
                    1,
                    100
                   );
         RAISE v_ex;
   END;
  --Kiem tra doi da thuc hien khop voi confirm number hay chua, neu da khop exit

    BEGIN
      SELECT COUNT(*)
        INTO V_TEMP
        FROM IOD
       WHERE ORGORDERID = MV_STRORGORDERID
       AND   CONFIRM_NO = TRIM(CONFIRM_NUMBER)
       AND IOD.deltd <>'Y';

       IF V_TEMP > 0 THEN
         RETURN;
       END IF;
    EXCEPTION
      WHEN OTHERS
      THEN
         v_err :=
            SUBSTR (   'Kiem tra confirm_number   '
                    || confirm_number
                    || SQLERRM,
                    1,
                    100
                   );
         RAISE v_ex;
    END;



   BEGIN
      SELECT od.remainqtty, sb.codeid, sb.symbol, ood.custodycd,
             ood.bors, ood.norp, ood.aorn, od.afacctno,
             od.ciacctno, od.seacctno, '', '',
             od.clearcd, ood.price, ood.qtty, deal_price * 1000,
             deal_volume, od.clearday, od.bratio,
             confirm_number, v_txdate, '', typ.mtrfday,SE.TRADEPLACE
        INTO mv_strremainqtty, mv_strcodeid, mv_strsymbol, mv_strcustodycd,
             mv_strbors, mv_strnorp, mv_straorn, mv_strafacctno,
             mv_strciacctno, mv_strseacctno, mv_reforderid, mv_refcustcd,
             mv_strclearcd, mv_strexprice, mv_strexqtty, mv_strprice,
             mv_strqtty, mv_strclearday, mv_strsecuredratio,
             mv_strconfirm_no, mv_strmatch_date, mv_desc,mv_mtrfday,v_tradeplace
        FROM odmast od, ood, securities_info sb, odtype typ, SBSECURITIES SE
       WHERE od.orderid = ood.orgorderid and od.actype = typ.actype
         AND od.codeid = sb.codeid AND SB.CODEID=SE.CODEID
         AND orderid = mv_strorgorderid;
   EXCEPTION
      WHEN OTHERS
      THEN
         v_err :=
            SUBSTR (   'odmast ,securities_info mv_strorgorderid= '
                    || mv_strorgorderid
                    || SQLERRM,
                    1,
                    100
                   );
         RAISE v_ex;
   END;



   --Day vao stctradebook, stctradeallocation de khong bi khop lai:
   v_refconfirmno :='VS'||mv_strbors||mv_strconfirm_no;
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
      INSERT INTO orderdeal
                  (firm, order_number, orderid, order_entry_date,
                   side_alph, filler, volume, price,
                   confirm_number, MATCHED
                  )
           VALUES (firm, order_number, mv_strorgorderid, order_entry_date,
                   side_alph, filler, deal_volume, deal_price,
                   confirm_number, 'Y'
                  );

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
      --4 CAP NHAT STSCHD
      SELECT COUNT (*)
        INTO v_matched
        FROM stschd
       WHERE orgorderid = mv_strorgorderid AND deltd <> 'Y';

      IF mv_strbors = 'B'
      THEN                                                          --Lenh mua
         --Tao lich thanh toan chung khoan
         v_strduetype := 'RS';
         --tinh gia von
         /*       UPDATE semast SET dcramt = dcramt + mv_strqtty * mv_strprice, dcrqtty = dcrqtty + mv_strqtty WHERE acctno = mv_strseacctno;
                 INSERT INTO setran
                        (txnum, txdate,acctno, txcd, namt, camt, REF, deltd, autoid)
                 VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'), mv_strseacctno, '0051', mv_strprice * mv_strqtty, NULL, NULL, 'N', seq_setran.NEXTVAL);

                INSERT INTO setran
                        (txnum, txdate, acctno, txcd, namt, camt, REF, deltd, autoid )
                 VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'), mv_strseacctno, '0052', mv_strqtty, NULL, NULL, 'N', seq_setran.NEXTVAL );
*/
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
                         qtty, aqtty, famt, status, deltd, costprice
                        )
                 VALUES (seq_stschd.NEXTVAL, mv_strorgorderid, mv_strcodeid,
                         v_strduetype, mv_strafacctno, mv_strseacctno,
                         mv_reforderid, v_txnum,
                         TO_DATE (v_txdate, 'DD/MM/YYYY'), mv_strclearday,
                         mv_strclearcd, mv_strprice * mv_strqtty, 0,
                         mv_strqtty, 0, 0, 'N', 'N', 0
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
                         v_strduetype, mv_strafacctno, mv_strafacctno,
                         mv_reforderid, v_txnum,
                         TO_DATE (v_txdate, 'DD/MM/YYYY'), least(mv_mtrfday,l_trfbuyext),
                         mv_strclearcd, mv_strprice * mv_strqtty, 0,
                         mv_strqtty, 0, 0, 'N', 'N', 0,
                         getduedate(TO_DATE (v_txdate, 'DD/MM/YYYY'),mv_strclearcd,/*'000'*/v_tradeplace,least(mv_mtrfday,l_trfbuyext)) --ngoc.vu-Jira561
                        );
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
                         qtty, aqtty, famt, status, deltd, costprice
                        )
                 VALUES (seq_stschd.NEXTVAL, mv_strorgorderid, mv_strcodeid,
                         v_strduetype, mv_strafacctno, mv_strseacctno,
                         mv_reforderid, v_txnum,
                         TO_DATE (v_txdate, 'DD/MM/YYYY'), 0,
                         mv_strclearcd, mv_strprice * mv_strqtty, 0,
                         mv_strqtty, 0, 0, 'N', 'N', 0
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
                         qtty, aqtty, famt, status, deltd, costprice
                        )
                 VALUES (seq_stschd.NEXTVAL, mv_strorgorderid, mv_strcodeid,
                         v_strduetype, mv_strafacctno, mv_strafacctno,
                         mv_reforderid, v_txnum,
                         TO_DATE (v_txdate, 'DD/MM/YYYY'), mv_strclearday,
                         mv_strclearcd, mv_strprice * mv_strqtty, 0,
                         mv_strqtty, 0, 0, 'N', 'N', 0
                        );
         END IF;
      END IF;

      --CAP NHAT TRAN VA MAST
            --BUY
      UPDATE odmast
         SET orstatus = '4'
       WHERE orderid = mv_strorgorderid;

      UPDATE odmast
         SET PORSTATUS = PORSTATUS||'4'
       WHERE orderid = mv_strorgorderid;

      UPDATE odmast
         SET execqtty = execqtty + mv_strqtty
       WHERE orderid = mv_strorgorderid;

      UPDATE odmast
         SET remainqtty = remainqtty - mv_strqtty
       WHERE orderid = mv_strorgorderid;

      UPDATE odmast
         SET execamt = execamt + mv_strqtty * mv_strprice
       WHERE orderid = mv_strorgorderid;

      UPDATE odmast
         SET matchamt = matchamt + mv_strqtty * mv_strprice
       WHERE orderid = mv_strorgorderid;

       UPDATE odmast
         SET HOSESESSION = (SELECT SYSVALUE  FROM ORDERSYS WHERE SYSNAME = 'CONTROLCODE')
       WHERE orderid = mv_strorgorderid And HOSESESSION ='N';


      --Neu khop het va co lenh huy cua lenh da khop thi cap nhat thanh refuse
      IF mv_strremainqtty = mv_strqtty THEN
          UPDATE odmast
             SET ORSTATUS = '0'
           WHERE REFORDERID = mv_strorgorderid;
        END IF;

      --Cap nhat tinh gia von
      IF mv_strbors = 'B' THEN
          UPDATE semast SET dcramt = dcramt + mv_strqtty*mv_strprice, dcrqtty = dcrqtty WHERE acctno = mv_strseacctno;
      END IF;
         -- TruongLD Add ngay 18/06/2013
        -- Cap nhat lai gia cho lenh MTL
        Begin
             Select max(ticksize) into v_ticksize
             From securities_ticksize tic, securities_info sb, sbsecurities mst
             Where mv_strprice BETWEEN tic.fromprice and tic.toprice
                   and mv_strprice < sb.ceilingprice
                   and mv_strprice > sb.floorprice
                   and sb.codeid = tic.codeid
                   and sb.codeid = mst.codeid
                   and mst.tradeplace in ('002') -- Chi xu ly doi voi CK san san HNX
                   and tic.symbol = mv_strsymbol;
        EXCEPTION WHEN OTHERS THEN
            v_ticksize := 0;
        END;

        IF mv_strbors = 'B' and v_ticksize <> 0 THEN
             Update odmast set quoteprice = mv_strprice + v_ticksize
             WHERE orderid = mv_strorgorderid and pricetype ='MTL' and remainqtty <> 0;
        ElsIf mv_strbors = 'S' and v_ticksize <> 0 THEN
             Update odmast set quoteprice = mv_strprice - v_ticksize
             WHERE orderid = mv_strorgorderid and pricetype ='MTL' and remainqtty <> 0;
        END IF;
        -- End TruongLD

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
                  );

      IF mv_strbors = 'B' THEN
          INSERT INTO setran
                  (txnum, txdate,
                   acctno, txcd, namt, camt,
                   REF, deltd, autoid
                  )
           VALUES (v_txnum, TO_DATE (v_txdate, 'DD/MM/YYYY'),
                   mv_strseacctno, '0051', mv_strqtty * mv_strprice, NULL,
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

   ELSE
      --ket qua tra ve khong hop le
              --2 THEM VAO TRONG orderdeal
      INSERT INTO orderdeal
                  (firm, order_number, orderid, order_entry_date,
                   side_alph, filler, volume, price,
                   confirm_number, MATCHED
                  )
           VALUES (firm, order_number, mv_strorgorderid, order_entry_date,
                   side_alph, filler, deal_volume, deal_price,
                   confirm_number, 'N'
                  );
   END IF;
   --Cap nhat cho GTC
   OPEN C_ODMAST(MV_STRORGORDERID);
   FETCH C_ODMAST INTO VC_ODMAST;
    IF C_ODMAST%FOUND THEN
          UPDATE FOMAST SET REMAINQTTY= REMAINQTTY - MV_STRQTTY
                            ,EXECQTTY= EXECQTTY + MV_STRQTTY
                            ,EXECAMT=  EXECAMT + MV_STRPRICE * MV_STRQTTY
          WHERE ORGACCTNO= MV_STRORGORDERID;
    END IF;
   CLOSE C_ODMAST;

   COMMIT;
EXCEPTION
   WHEN v_ex
   THEN
   ROLLBACK;
      INSERT INTO log_err
                  (id,date_log, POSITION, text
                  )
           VALUES ( seq_log_err.NEXTVAL,SYSDATE, ' MATCHING_NORMAL_ORDER ', v_err
                  );

      COMMIT;
END;
 
/
