SET DEFINE OFF;
CREATE OR REPLACE PACKAGE gwpks_auto
  IS
--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter package declarations as shown below


     PROCEDURE prMoneyTransfer;

     PROCEDURE prCARightOffRegister;

END; -- Package spec

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY gwpks_auto
IS
--
-- To modify this template, edit file PKGBODY.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package body
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter procedure, function bodies as shown below

   PROCEDURE prMoneyTransfer
    IS
      -- Enter the procedure variables here. As shown below
      v_errcode NUMBER;
      v_rqsautoid varchar2(30);
      v_count integer;
      v_rqssrc varchar(3);
      v_rqstyp varchar(3);
      v_status varchar(3);
      v_custodycd varchar(20);
      v_subaccount varchar(20);
      v_tociacctno varchar(50);
      v_tocustid varchar(50);
      v_destination varchar(50);
      v_feecd varchar(50);
      v_errmsg varchar(250);
      v_txdate varchar(20);
      v_txnum varchar(10);
      v_timeallow NUMBER;
      v_benefbank varchar(250);
      v_benefacct varchar(250);
      v_benefcustname varchar(250);
      v_beneflicense varchar(250);
      v_trf_iore varchar(1);
      v_fee_forp varchar(1);
      v_fee_vat float;
      v_fee_rate    float;
      v_fee_amt     float;
      v_fee_min     float;
      v_fee_max     float;
      v_feeamt  float;
      v_vatamt  float;
      v_trfamt  float;
   BEGIN
       FOR rec IN
       (
            SELECT mst.*, rqs_ISSUBACCT.cvalue ISSUBACCT, rqs_REFACCTNO.cvalue REFACCTNO, rqs_REFID.nvalue REFID,
                    rqs_AMT.nvalue AMT, rqs_TRFDESC.cvalue TRFDESC
            FROM borqslog mst, borqslogdtl  rqs_ISSUBACCT, borqslogdtl  rqs_REFACCTNO,
                                borqslogdtl  rqs_REFID, borqslogdtl rqs_AMT, borqslogdtl rqs_TRFDESC
            WHERE rqstyp = 'TRF' AND status = 'P' AND rqssrc = 'ONL'
            AND rqs_ISSUBACCT.autoid = mst.autoid AND rqs_ISSUBACCT.varname = 'ISSUBACCT'
            AND rqs_REFACCTNO.autoid = mst.autoid AND rqs_REFACCTNO.varname = 'REFACCTNO'
            AND rqs_REFID.autoid = mst.autoid AND rqs_REFID.varname = 'REFID'
            AND rqs_AMT.autoid = mst.autoid AND rqs_AMT.varname = 'AMT'
            AND rqs_TRFDESC.autoid = mst.autoid AND rqs_TRFDESC.varname = 'TRFDESC'
            AND ROWNUM <= 10
            ORDER BY mst.autoid
       )
       LOOP
            v_rqsautoid:= rec.AUTOID;

             --Kiem tra thoi gian cho phep thuc hien chuyen tien.
            SELECT CASE WHEN max(case WHEN grname = 'SYSTEM' AND varname = 'HOSTATUS' THEN varvalue END) = 1
                AND to_date(to_char(SYSDATE,'hh24:mi:ss'),'hh24:mi:ss') >= to_date(max(case WHEN grname = 'STRADE' AND varname = 'MT_FRTIME' THEN varvalue END),'hh24:mi:ss')
                AND to_date(to_char(SYSDATE,'hh24:mi:ss'),'hh24:mi:ss') <= to_date(max(case WHEN grname = 'STRADE' AND varname = 'MT_TOTIME' THEN varvalue END),'hh24:mi:ss')
                THEN 1 ELSE 0 end
                INTO v_timeallow
            FROM sysvar;
            if v_timeallow = 0 then
                v_errcode:=-4;  --nam ngoai thoi gian cho phep thuc hien chuyen tien qua strade.
                v_errmsg:='OUT OF Operation time!';
                EXIT;
            end if;
          --kiem tra Custody Code hoac Sub-Account co ton tai khong
            IF rec.ISSUBACCT='Y' THEN
                begin
                SELECT AFMAST.ACCTNO, CFMAST.CUSTODYCD INTO v_subaccount, v_custodycd FROM AFMAST, CFMAST WHERE AFMAST.CUSTID=CFMAST.CUSTID AND AFMAST.STATUS <> 'C' AND AFMAST.ACCTNO=rec.REFACCTNO;
                exception
                when others then
                     v_errcode:=-3;  --khong thay subaccount
                     v_errmsg:='Cannot found subaccount!';
                    RAISE errnums.E_BIZ_RULE_INVALID;
                end;
            ELSE
                v_custodycd:=rec.REFACCTNO;
                SELECT count(1) INTO v_count FROM AFMAST AF, CFMAST CF WHERE CF.CUSTID=AF.CUSTID AND AF.STATUS <> 'C' AND CF.TRADEONLINE='Y' AND CF.CUSTODYCD=rec.REFACCTNO;
                if v_count > 1 then
                    v_errcode:=-5;  --Khai bao nhieu tai khoan dang ki online tren cung 1 ma luu ky chung khoan
                    v_errmsg:='Multi Custody Code has found!';
                    RAISE errnums.E_BIZ_RULE_INVALID;
                end if;

                SELECT AF.ACCTNO INTO v_subaccount FROM AFMAST AF, CFMAST CF WHERE CF.CUSTID=AF.CUSTID AND AF.STATUS <> 'C' AND CF.TRADEONLINE='Y' AND CF.CUSTODYCD=rec.REFACCTNO;
                IF SQL%NOTFOUND THEN
                    v_errcode:=-3;  --khong thay subaccount
                    v_errmsg:='Cannot found subaccount!';
                    RAISE errnums.E_BIZ_RULE_INVALID;
                END IF;
            END IF;
            --nhan yeu cau xu ly
            v_status:='P';
            v_feeamt:=0;
            v_vatamt:=0;
            --XU LY YEU CAU CHUYEN TIEN: 1120 OR 1101

            SELECT CIACCOUNT, CUSTID, FEECD,bankname,bankacc,bankacname INTO v_tociacctno, v_tocustid, v_feecd, v_benefbank,v_benefacct,v_benefcustname FROM CFOTHERACC WHERE AUTOID=rec.REFID;
            IF length(v_tociacctno)<>0 THEN
                v_trf_iore :='I';
                --1120
                txpks_auto.pr_InternalTransfer(v_subaccount, v_tociacctno, rec.AMT, rec.TRFDESC, v_errcode, v_txdate, v_txnum);
                v_destination:=v_tociacctno;
            ELSE
                BEGIN
                    /*v_trf_iore :='E';
                    --tinh toan phi cho giao dich chuyen tien ra ben ngoai
                    IF length(v_feecd)<>0 THEN
                        SELECT FORP, FEEAMT, FEERATE, MINVAL, MAXVAL, VATRATE INTO v_fee_forp, v_fee_amt, v_fee_rate, v_fee_min, v_fee_max, v_fee_vat  FROM FEEMASTER WHERE FEECD=v_feecd;
                        IF v_fee_forp='F' THEN
                            v_feeamt:=v_fee_amt;
                        ELSE
                            v_feeamt:=rec.AMT*v_fee_rate/100;
                            IF v_feeamt < v_fee_min THEN
                                v_feeamt:=v_fee_min;
                            END IF;
                            IF v_feeamt > v_fee_max THEN
                                v_feeamt:=v_fee_max;
                            END IF;
                        END IF;
                        v_vatamt:=v_feeamt*v_fee_vat/100;
                    END IF;*/
                    --TungNT Modified
                    v_trf_iore :='I';
                    v_feeamt:=0;
                    v_vatamt:=0;
                    --TungNT end
                    --1101
                    v_trfamt:=rec.AMT+v_feeamt+v_vatamt; --chuyen tien ra ben ngoai la thu phi ngoai
                    txpks_auto.pr_ExternalTransfer(v_subaccount, v_tocustid, v_benefbank, v_benefacct, v_benefcustname, v_beneflicense, v_trfamt, v_feeamt, v_vatamt, rec.TRFDESC, v_errcode, v_txdate, v_txnum);
                    v_destination:=v_tocustid;
                END;
            END IF;

            --XU LY LOI
            IF v_errcode=0 THEN
                v_status:='A';
            ELSE
                BEGIN
                    SELECT ERRDESC INTO v_errmsg FROM DEFERROR WHERE ERRNUM=v_errcode;
                EXCEPTION
                WHEN OTHERS THEN
                    v_errcode:= -10;
                    v_errmsg:='UNDEFINED ERROR!';
                END;
                v_status:='E';
            END IF;

            UPDATE BORQSLOG
            SET ERRNUM = v_errcode, ERRMSG = v_errmsg, STATUS = v_status, TXDATE= v_txdate, TXNUM=v_txnum
            WHERE autoid = v_rqsautoid;

            COMMIT;
       END LOOP;
   EXCEPTION
      WHEN errnums.E_BIZ_RULE_INVALID THEN
          UPDATE BORQSLOG
          SET ERRNUM = v_errcode, ERRMSG = v_errmsg, STATUS = 'E'
          WHERE autoid = v_rqsautoid;
      WHEN OTHERS THEN
        v_errmsg:= SQLERRM;
          UPDATE BORQSLOG
          SET ERRNUM = '-1', ERRMSG = 'Error in process: ' || v_errmsg, STATUS = 'E'
          WHERE autoid = v_rqsautoid;

   END;


   PROCEDURE prCARightOffRegister
   IS
        v_rqsautoid varchar2(30);
        v_count integer;
        v_errcode varchar2(30);
        v_errmsg varchar(250);
        v_custodycd varchar(20);
        v_subaccount varchar(20);
        v_caid varchar(20);
        v_txdate varchar(20);
        v_txnum varchar(10);
        v_rqssrc varchar(3);
        v_rqstyp varchar(3);
        v_status varchar(3);
        v_newafacctno varchar2(30);
        v_timeallow NUMBER;
        v_remark varchar2(500);
        v_symbol varchar(30);
   BEGIN
        FOR rec IN
        (
            SELECT mst.*, rqs_ISSUBACCT.cvalue ISSUBACCT, rqs_REFACCTNO.cvalue REFACCTNO, rqs_CAMASTID.cvalue REFID,
                    rqs_QTTY.nvalue QTTY
            FROM borqslog mst, borqslogdtl  rqs_ISSUBACCT, borqslogdtl  rqs_REFACCTNO,
                                borqslogdtl  rqs_CAMASTID, borqslogdtl rqs_QTTY
            WHERE rqstyp = 'CAR' AND status = 'P' AND rqssrc = 'ONL'
            AND rqs_ISSUBACCT.autoid = mst.autoid AND rqs_ISSUBACCT.varname = 'ISSUBACCT'
            AND rqs_REFACCTNO.autoid = mst.autoid AND rqs_REFACCTNO.varname = 'REFACCTNO'
            AND rqs_CAMASTID.autoid = mst.autoid AND rqs_CAMASTID.varname = 'CAMASTID'
            AND rqs_QTTY.autoid = mst.autoid AND rqs_QTTY.varname = 'QTTY'
            AND ROWNUM <= 10
            ORDER BY mst.autoid
        )
        LOOP
            v_rqsautoid:= rec.AUTOID;
            --Kiem tra thoi gian cho phep thuc hien chuyen tien.
            SELECT CASE WHEN max(case WHEN grname = 'SYSTEM' AND varname = 'HOSTATUS' THEN varvalue END) = 1
                AND to_date(to_char(SYSDATE,'hh24:mi:ss'),'hh24:mi:ss') >= to_date(max(case WHEN grname = 'STRADE' AND varname = 'CA_FRTIME' THEN varvalue END),'hh24:mi:ss')
                AND to_date(to_char(SYSDATE,'hh24:mi:ss'),'hh24:mi:ss') <= to_date(max(case WHEN grname = 'STRADE' AND varname = 'CA_TOTIME' THEN varvalue END),'hh24:mi:ss')
                THEN 1 ELSE 0 END
            INTO v_timeallow
            FROM sysvar;
            if v_timeallow = 0 then
                v_errcode:=-6;  --nam ngoai thoi gian cho phep thuc hien chuyen tien qua strade.
                v_errmsg:='OUT OF operation time';
                EXIT;
            end if;

            BEGIN
            --nhan yeu cau xu ly
            v_rqssrc:='ONL';
            v_rqstyp:='CAR';
            v_status:='P';

            BEGIN
                -- Neu truyen vao custodycd, thuc hien chuyen lai thanh afacctno voi tradeonline = Y
                IF rec.ISSUBACCT='N' THEN
                    BEGIN
                        SELECT AF.ACCTNO INTO v_newafacctno FROM AFMAST AF, CFMAST CF WHERE CF.CUSTID=AF.CUSTID AND AF.STATUS <> 'C' AND CF.TRADEONLINE='Y' AND CF.CUSTODYCD=rec.REFACCTNO;
                    EXCEPTION
                    WHEN OTHERS THEN
                        v_newafacctno:= rec.REFACCTNO;
                    END;
                ELSE
                    v_newafacctno:= rec.REFACCTNO;
                END IF;

                SELECT AFMAST.ACCTNO, CFMAST.CUSTODYCD INTO v_subaccount, v_custodycd FROM AFMAST, CFMAST WHERE AFMAST.CUSTID=CFMAST.CUSTID AND AFMAST.STATUS <> 'C' AND AFMAST.ACCTNO=v_newafacctno;
            EXCEPTION
                WHEN no_data_found THEN
                v_errcode:=-3;  --khong thay subaccount
                v_errmsg:='Cannot FOUND subaccount!';
                RAISE errnums.E_BIZ_RULE_INVALID;
            END;

            -- Format camastid
            v_caid:=replace(rec.REFID,'.','');
            -- Kiem tra trang thai quyen. Co cho phep thuc hien tiep dang ky quyen mua hay khong.
            BEGIN
                SELECT camastid INTO v_caid FROM camast WHERE status IN ('A','M') AND camastid = v_caid and deltd <> 'Y';
            EXCEPTION
                WHEN no_data_found THEN
                v_errcode:=-4;  --Trang thai ma quyen ko hop le: chi dang ki quyen mua khi trang thai camast la A, M
                v_errmsg:='CA status IS invalid!';
                RAISE errnums.E_BIZ_RULE_INVALID;
            END;
                -- Lay thong tin ma chung khoan de lam dien giai.
            BEGIN
                select s.symbol into v_symbol from camast c, sbsecurities s where s.codeid = c.codeid and c.status IN ('A','M') AND c.camastid = v_caid and c.deltd <> 'Y';
            EXCEPTION
                WHEN others THEN
                v_errcode:=-6;  --ma chung khoan khong ton tai.
                v_errmsg:='Symbol does NOT exists!';
                RAISE errnums.E_BIZ_RULE_INVALID;
            END;
                -- Kiem tra trang thai quyen. Co cho phep thuc hien tiep dang ky quyen mua hay khong.
            BEGIN
                SELECT camastid INTO v_caid FROM caschd WHERE status IN ('A','M') AND camastid = v_caid AND afacctno = v_subaccount and deltd <> 'Y';
            EXCEPTION
                WHEN no_data_found THEN
                v_errcode:=-4;  --Trang thai ma quyen ko hop le: chi dang ki quyen mua khi trang thai camast la A, M
                v_errmsg:='CA status IS invalid!';
                RAISE errnums.E_BIZ_RULE_INVALID;
            END;

            BEGIN
                -- Kiem tra: So luong dang ki mua co cho phep hay khong? PBALANCE > 0 AND PQTTY > 0
                SELECT camastid INTO v_caid
                FROM caschd
                WHERE status IN ('A','M') AND camastid = v_caid AND afacctno = v_subaccount AND PBALANCE > 0 AND PQTTY > 0 AND PQTTY >= rec.QTTY and deltd <> 'Y';
            EXCEPTION
                WHEN no_data_found THEN
                v_errcode:=-5;  --Khoi luong chung khoan dk quyen mua khong hop le.
                v_errmsg:='Over availble register qtty!';
                RAISE errnums.E_BIZ_RULE_INVALID;
            END;

                -- desc dang ky quyen mua:
                v_remark:='[STRADE]Dang ky quyen mua cp ' || v_symbol;
                --GOI HAM DANG KY QUYEN MUA
                txpks_auto.pr_RightoffRegiter(v_caid, v_subaccount, rec.QTTY, v_remark, v_errcode, v_txdate, v_txnum);

                --XU LY LOI
                IF v_errcode=0 THEN
                    v_status:='A';
                ELSE
                    begin
                        SELECT ERRDESC INTO v_errmsg FROM DEFERROR WHERE ERRNUM=v_errcode;
                    exception
                    when no_data_found then
                        v_errcode:= -10;
                        v_errmsg:='UNDEFINED ERROR!';
                    end;
                    v_status:='E';
                END IF;

                UPDATE BORQSLOG
                SET ERRNUM = v_errcode, ERRMSG = v_errmsg, STATUS = v_status, txdate = v_txdate, txnum = v_txnum
                WHERE autoid = v_rqsautoid;
            END;
        END LOOP;
        COMMIT;
   EXCEPTION
      WHEN errnums.E_BIZ_RULE_INVALID THEN
          UPDATE BORQSLOG
          SET ERRNUM = v_errcode, ERRMSG = v_errmsg, STATUS = 'E'
          WHERE autoid = v_rqsautoid;
      WHEN OTHERS THEN
        v_errmsg:= SQLERRM;
          UPDATE BORQSLOG
          SET ERRNUM = '-1', ERRMSG = 'Error in process: ' || v_errmsg, STATUS = 'E'
          WHERE autoid = v_rqsautoid;
   END;

   -- Enter further code below as specified in the Package spec.
END;
/
