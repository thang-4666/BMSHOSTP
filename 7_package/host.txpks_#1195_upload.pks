SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#1195_upload
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

     FUNCTION fn_PrepareData(p_err_code out varchar2,p_err_param out varchar2)
      RETURN NUMBER ;


  FUNCTION fn_BatchAppCheck(p_err_code out varchar2,p_err_param out varchar2)
      RETURN NUMBER ;

  FUNCTION fn_BatchAppUpdate(p_err_code out varchar2,p_err_param out varchar2)
      RETURN NUMBER ;
END; -- Package spec

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY txpks_#1195_upload
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;
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

   FUNCTION fn_PrepareData(p_err_code out varchar2,p_err_param out varchar2)
    RETURN NUMBER
    IS
      -- Enter the procedure variables here. As shown below
    v_busdate DATE;
    v_count NUMBER;

   BEGIN

        -- get CURRDATE
        SELECT to_date(varvalue,'DD/MM/RRRR')
                INTO v_busdate
        FROM sysvar
        WHERE varname = 'CURRDATE'
        AND grname = 'SYSTEM';
        UPDATE tx1195_uploaddtl
        SET txdate = v_busdate;

        -- Huy bo refnum trung lap:
        FOR rec_duplicate IN
        (
            SELECT refnum,bankid, count(1)
            FROM
            (SELECT * FROM tx1195_uploaddtl WHERE txdate = v_busdate
                UNION ALL
            SELECT * FROM tx1195_uploaddtlhist WHERE txdate = v_busdate)
            HAVING count(1) > 1
            GROUP BY refnum,bankid
        )
        loop
            UPDATE tx1195_uploaddtl
            SET deltd = 'Y',ERRORDESC = '[refnum] HAS BEEN DUPLICATED'
            WHERE refnum = rec_duplicate.refnum;
        END loop;

        -- lay thong tin custodycd tu description:
        UPDATE tx1195_uploaddtl
        SET custodycd = CASE WHEN INSTR(description,'017C') > 0 then substr(description,INSTR(description,'017C'),10)
                             WHEN INSTR(description,'017F') > 0 then substr(description,INSTR(description,'017F'),10)
                             WHEN INSTR(description,'017P') > 0 then substr(description,INSTR(description,'017P'),10)
                             WHEN INSTR(description,'017E') > 0 then substr(description,INSTR(description,'017E'),10)
                            ELSE '' END;

        -- Lay thong tin GLMAST va BANKACCTNO
        FOR rec IN
        (
            SELECT * FROM banknostro
        )
        LOOP
            UPDATE tx1195_uploaddtl
            SET glmast = rec.glaccount, bankacctno = rec.bankacctno
            WHERE bankid = rec.shortname;
        END LOOP;

        -- kiem tra cac truong mandatory va CHECK gia tri so tien.
        UPDATE tx1195_uploaddtl
        SET deltd = 'Y', errordesc = 'data missing: ' || CASE WHEN bankid IS NULL OR bankid = '' THEN ' [bankid] IS NULL '
                                                            WHEN description IS NULL OR description = '' THEN ' [description] IS NULL '
                                                            WHEN fileid IS NULL OR fileid = '' THEN ' [fileid] IS NULL '
                                                            WHEN busdate IS NULL THEN ' [busdate] IS NULL '
                                                            WHEN amt <= 0 THEN ' [amt] < 0 '
                                                            WHEN glmast IS NULL OR glmast = '' THEN ' [glmast] IS NULL '
                                                            WHEN bankacctno IS NULL OR bankacctno = '' THEN ' [bankacctno] IS NULL '
                                                            WHEN busdate <> v_busdate THEN ' [busdate] IS NOT SYSTEM DATE' END
        WHERE bankid IS NULL OR bankid = ''
        OR description IS NULL OR description = ''
        OR fileid IS NULL OR fileid = ''
        OR busdate IS NULL
        OR glmast IS NULL OR glmast = ''
        OR amt <= 0
        OR busdate <> v_busdate;

        -- Kiem tra DELETE het cac dong ko co trong glmast
        UPDATE tx1195_uploaddtl a
        SET deltd = 'Y', errordesc = '[glmast] DOES NOT EXISTS IN SYSTEM'
        WHERE NOT EXISTS (SELECT 1 FROM glmast WHERE acctno = trim(a.glmast) AND glmast.actype = 'B');

        -- xu ly tuan tu
        FOR tx1195_rec  IN
        (
            SELECT tx1195.*  FROM tx1195_uploaddtl tx1195
        )
        LOOP
            SELECT count(1)
                INTO v_count
            FROM afmast af, cfmast cf
            WHERE cf.custid = af.custid
            AND af.acctno = tx1195_rec.acctno
            AND cf.custodycd = tx1195_rec.custodycd;

            IF v_count = 0 then
                UPDATE tx1195_uploaddtl
                SET acctno = NULL
                WHERE refnum = tx1195_rec.refnum;

                UPDATE tx1195_uploaddtl t1
                SET acctno = (  SELECT nvl(  af.acctno,null)
                                FROM afmast af, cfmast cf , tx1195_uploaddtl t2
                                WHERE cf.custid = af.custid
                                AND cf.custodycd = t1.custodycd
                                AND t1.refnum = t2.refnum
                                AND af.status = 'A'
                                and ROWNUM = 1)
                WHERE refnum = tx1195_rec.refnum;
            END IF;

            IF tx1195_rec.acctno IS NULL then
                UPDATE tx1195_uploaddtl  t1
                SET acctno = (  SELECT nvl(  af.acctno,null)
                                FROM afmast af, cfmast cf , tx1195_uploaddtl t2
                                WHERE cf.custid = af.custid
                                AND cf.custodycd = t2.custodycd
                                AND t1.refnum = t2.refnum
                                AND af.status = 'A'
                                and ROWNUM = 1)
                WHERE refnum = tx1195_rec.refnum
                and acctno is null or acctno = '';
            END IF;



        END LOOP;



        RETURN systemnums.C_SUCCESS;

   EXCEPTION
      WHEN OTHERS THEN
          ROLLBACK;
            p_err_code := errnums.C_SYSTEM_ERROR;
            p_err_param := 'SYSTEM_ERROR';
          RETURN errnums.C_SYSTEM_ERROR;
   END;


FUNCTION fn_BatchAppCheck(p_err_code out varchar2,p_err_param out varchar2)
    RETURN NUMBER
    IS
      -- Enter the procedure variables here. As shown below
    l_err_code varchar2(30);
    l_err varchar2(30);
    l_txmsg               tx.msg_rectype;
   BEGIN
       l_err_code:= systemnums.C_SUCCESS;
    l_err:= systemnums.C_SUCCESS;

        FOR rec IN
        (
            SELECT * from tx1195_uploaddtl WHERE deltd <> 'Y' AND status <> 'C'
        )
        LOOP
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



                l_txmsg.txfields ('03').VALUE := rec.acctno;
                l_txmsg.txfields ('05').VALUE := rec.glmast;
                l_txmsg.txfields ('10').VALUE := rec.amt;
                l_txmsg.txfields ('30').VALUE := rec.description;
                l_txmsg.txfields ('31').VALUE := rec.refnum;
                l_txmsg.txfields ('82').VALUE := rec.custodycd;

            IF txpks_#1195.fn_txAppCheck(P_TXMSG=>l_txmsg, P_ERR_CODE=>l_err_code) <> systemnums.C_SUCCESS THEN
                --RETURN errnums.C_BIZ_RULE_INVALID;
                -- UPDATE error log;
                UPDATE tx1195_uploaddtl
                SET status = 'E',errordesc = l_err_code
                WHERE refnum = rec.refnum;
                l_err:= errnums.C_SYSTEM_ERROR;
                p_err_code := errnums.C_SYSTEM_ERROR;
            ELSE
                UPDATE tx1195_uploaddtl
                SET status = 'A',errordesc = null
                WHERE refnum = rec.refnum;
            END IF;
        END LOOP;
        RETURN l_err;
   EXCEPTION
      WHEN OTHERS THEN
          ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      p_err_param := 'SYSTEM_ERROR';
    dbms_output.put_line('loi trong others');
      RETURN errnums.C_SYSTEM_ERROR;
   END;

FUNCTION fn_BatchAppUpdate(p_err_code out varchar2,p_err_param out varchar2)
    RETURN NUMBER
    IS
      -- Enter the procedure variables here. As shown below
    l_err_code varchar2(30);
    l_err varchar2(10);
    l_err_param varchar2(500);
    l_txmsg               tx.msg_rectype;
   BEGIN
        plog.setbeginsection (pkgctx, 'fn_BatchAppUpdate');
        plog.debug(pkgctx, 'begin fn_BatchAppUpdate');
       l_err_code:= systemnums.C_SUCCESS;
    l_err:= systemnums.C_SUCCESS;

        FOR rec IN
        (
            SELECT * from tx1195_uploaddtl WHERE deltd <> 'Y' AND status <> 'C'
        )
        LOOP
            BEGIN
            -- 1. Set common VALUES
                plog.debug(pkgctx, 'begin SET common values');

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


            -- 2. SET TRANSACTION parameter.
                plog.debug(pkgctx, 'begin SET txfld values');

                l_txmsg.txfields ('03').VALUE := rec.acctno;
                l_txmsg.txfields ('05').VALUE := rec.glmast;
                l_txmsg.txfields ('10').VALUE := rec.amt;
                l_txmsg.txfields ('30').VALUE := rec.description;
                l_txmsg.txfields ('31').VALUE := rec.refnum;
                l_txmsg.txfields ('82').VALUE := rec.custodycd;

                SELECT fullname,address, idcode,iddate,idplace
                    INTO l_txmsg.txfields ('90').VALUE, l_txmsg.txfields ('91').VALUE, l_txmsg.txfields ('92').VALUE,l_txmsg.txfields ('93').VALUE, l_txmsg.txfields ('94').VALUE
                FROM cfmast WHERE custodycd = rec.custodycd;

                  --2.1 Set txnum
                  SELECT systemnums.c_fo_prefixed
                         || LPAD (seq_fotxnum.NEXTVAL, 8, '0')
                  INTO l_txmsg.txnum
                  FROM DUAL;
            -- txnum:
            SELECT systemnums.C_BATCH_PREFIXED
                             || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
                      INTO l_txmsg.txnum
                      FROM DUAL;
            --2.3 Set txdate
               SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO l_txmsg.txdate
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';

               l_txmsg.brdate                    := l_txmsg.txdate;
               l_txmsg.busdate                   := rec.busdate;

               --2.2 Set txtime
               l_txmsg.txtime                    :=
                  TO_CHAR (SYSDATE, systemnums.c_time_format);

               l_txmsg.chktime                   := l_txmsg.txtime;
               l_txmsg.offtime                   := l_txmsg.txtime;

                l_txmsg.offid:= systemnums.c_system_userid;
                --l_txmsg.ovrrqd
                --l_txmsg.chid
                --l_txmsg.chkid
                --l_txmsg.txaction
                l_txmsg.msgtype:= 'T';
                l_txmsg.tltxcd:='1195';
                --l_txmsg.ibt    --l_txmsg.brid2    --l_txmsg.tlid2    --l_txmsg.ccyusage    --l_txmsg.txdesc    --l_txmsg.msgamt    --l_txmsg.msgacct
                --l_txmsg.feeamt       --l_txmsg.vatamt       --l_txmsg.voucher      --l_txmsg.txtype       --l_txmsg.nosubmit     --l_txmsg.pretran
                --l_txmsg.late
                l_txmsg.local:='N';
                --l_txmsg.glgp         --l_txmsg.careby

                plog.debug(pkgctx, 'begin exec txpks_#1195.fn_autotxprocess');

                IF txpks_#1195.fn_autotxprocess(l_txmsg, l_err_code, l_err_param) <> systemnums.C_SUCCESS THEN
                        UPDATE tx1195_uploaddtl
                        SET status = 'E',errordesc = l_err_code
                        WHERE refnum = rec.refnum;

                        p_err_code := errnums.C_SYSTEM_ERROR;
                        l_err:= errnums.C_SYSTEM_ERROR;
                ELSE
                        UPDATE tx1195_uploaddtl
                        SET status = 'C',errordesc = null
                        WHERE refnum = rec.refnum;
                END IF;
           EXCEPTION
              WHEN OTHERS THEN
                 UPDATE tx1195_uploaddtl
                 SET status = 'E',errordesc = l_err_code
                 WHERE refnum = rec.refnum;

                 p_err_code := errnums.C_SYSTEM_ERROR;
                 l_err:= errnums.C_SYSTEM_ERROR;
            END;
        END LOOP;

   plog.setendsection (pkgctx, 'fn_BatchAppUpdate');
        RETURN l_err;
   EXCEPTION
      WHEN OTHERS THEN
          --ROLLBACK;
      p_err_code := errnums.C_SYSTEM_ERROR;
      p_err_param := 'SYSTEM_ERROR';
        plog.setendsection (pkgctx, 'fn_BatchAppUpdate');
          RETURN errnums.C_SYSTEM_ERROR;
   END;
   -- Enter further code below as specified in the Package spec.
END;

/
