SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#8846ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#8846EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      22/08/2012     Created
 **
 ** (c) 2008 by Financial Software Solutions. JSC.
 ** ----------------------------------------------------------------------------------------------------*/
IS
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_txAftAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_txPreAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_txAftAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
END;

 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY txpks_#8846ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_orderid          CONSTANT CHAR(2) := '01';
   c_custodycd        CONSTANT CHAR(2) := '02';
   c_afacctno         CONSTANT CHAR(2) := '03';
   c_txdate           CONSTANT CHAR(2) := '08';
   c_cleardate        CONSTANT CHAR(2) := '09';
   c_codeid           CONSTANT CHAR(2) := '07';
   c_exectype         CONSTANT CHAR(2) := '22';
   c_orderqtty        CONSTANT CHAR(2) := '10';
   c_quoteprice       CONSTANT CHAR(2) := '11';
   c_matchqtty        CONSTANT CHAR(2) := '12';
   c_matchamt         CONSTANT CHAR(2) := '14';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
    l_AAMT  NUMBER;
    l_DFAMT NUMBER;
BEGIN
   plog.setbeginsection (pkgctx, 'fn_txPreAppCheck');
   plog.debug(pkgctx,'BEGIN OF fn_txPreAppCheck');
   /***************************************************************************************************
    * PUT YOUR SPECIFIC RULE HERE, FOR EXAMPLE:
    * IF NOT <<YOUR BIZ CONDITION>> THEN
    *    p_err_code := '<<ERRNUM>>'; -- Pre-defined in DEFERROR table
    *    plog.setendsection (pkgctx, 'fn_txPreAppCheck');
    *    RETURN errnums.C_BIZ_RULE_INVALID;
    * END IF;
    ***************************************************************************************************/

    -- Kiem tra xem lenh con UT (lenh ban) hay ko
    IF instr('NS/SS/MS',p_txmsg.txfields('22').value) > 0 THEN
        SELECT sts.aamt - sts.paidamt aamt
        INTO l_AAMT
        FROM stschd sts
        WHERE sts.orgorderid = p_txmsg.txfields('01').value AND sts.duetype = 'RM' AND sts.deltd = 'N';
        IF l_AAMT >0 THEN
            p_err_code := ERRNUMS.C_OD_ORDER_HAD_ADVANCEPAYMENT;
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;
    END IF;

    -- Kiem tra xem lenh con tham gia tao deal hay ko (lenh mua)
    IF instr('NB/BC',p_txmsg.txfields('22').value) > 0 THEN
        SELECT sts.aqtty dfqtty
        INTO l_DFAMT
        FROM stschd sts
        WHERE sts.orgorderid = p_txmsg.txfields('01').value AND sts.duetype = 'RS' AND sts.deltd = 'N';
        IF l_DFAMT >0 THEN
            p_err_code := ERRNUMS.C_OD_ORDER_HAD_DEAL;
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;
    END IF;

    plog.debug (pkgctx, '<<END OF fn_txPreAppCheck');
    plog.setendsection (pkgctx, 'fn_txPreAppCheck');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'fn_txPreAppCheck');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txPreAppCheck;

FUNCTION fn_txAftAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
BEGIN
   plog.setbeginsection (pkgctx, 'fn_txAftAppCheck');
   plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppCheck>>');
   /***************************************************************************************************
    * PUT YOUR SPECIFIC RULE HERE, FOR EXAMPLE:
    * IF NOT <<YOUR BIZ CONDITION>> THEN
    *    p_err_code := '<<ERRNUM>>'; -- Pre-defined in DEFERROR table
    *    plog.setendsection (pkgctx, 'fn_txAftAppCheck');
    *    RETURN errnums.C_BIZ_RULE_INVALID;
    * END IF;
    ***************************************************************************************************/
   plog.debug (pkgctx, '<<END OF fn_txAftAppCheck>>');
   plog.setendsection (pkgctx, 'fn_txAftAppCheck');
   RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'fn_txAftAppCheck');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txAftAppCheck;

FUNCTION fn_txPreAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
    l_orderid varchar2(20);
    v_tllogrow  tllog%ROWTYPE;
    l_currdate  DATE;
    l_matchdate DATE;
    l_count number;
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txPreAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txPreAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC PROCESS HERE. . DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/

    SELECT getcurrdate INTO l_currdate FROM dual;
    l_matchdate := to_date(p_txmsg.txfields('08').value,'DD/MM/YYYY');
    l_orderid := p_txmsg.txfields('01').value;

    IF l_matchdate = l_currdate THEN
        -- Update TLLOG
        UPDATE TLLOG SET
            DELTD = 'Y'
        WHERE TLTXCD in( '8804','8809','8814') AND MSGACCT = l_orderid;

        FOR I IN
            (
                SELECT * FROM TLLOG WHERE TLTXCD in( '8804','8809','8814') AND MSGACCT = l_orderid
            )
        LOOP
 /*         SELECT * INTO v_tllogrow
            FROM TLLOG
            WHERE TLTXCD in( '8804','8809','8814') AND MSGACCT = l_orderid AND TXNUM = i.TXNUM;
 */

            -- REVERT AFTRAN
            UPDATE AFTRAN SET
                DELTD = 'Y'
            WHERE TXNUM = i.TXNUM;
/*
            IF SQL%ROWCOUNT <> 1 THEN
                dbms_output.put_line('Error: Duplicate AFTRAN. Going to rollback');
                rollback;
            END IF;*/

            -- REVERT ODTRAN
            UPDATE ODTRAN SET
                DELTD = 'Y'
            WHERE TXNUM = i.TXNUM AND ACCTNO = l_orderid;
            secnet_un_map(i.txnum,to_char(i.txdate,'DD/MM/RRRR'));
        END LOOP;
    ELSE
        -- Update TLLOG
        UPDATE TLLOGALL SET
            DELTD = 'Y'
        WHERE TLTXCD in( '8804','8809','8814') AND MSGACCT = l_orderid;

        SELECT COUNT(*) INto l_count FROM TLLOGALL WHERE TLTXCD in( '8804','8809','8814') AND MSGACCT = l_orderid;

        if l_count>0 then

            FOR I IN
                (
                    SELECT * FROM TLLOGALL WHERE TLTXCD in( '8804','8809','8814') AND MSGACCT = l_orderid
                )
            LOOP
               /* SELECT * INTO v_tllogrow
                FROM TLLOGALL
                WHERE TLTXCD in( '8804','8809','8814') AND MSGACCT = l_orderid AND TXNUM = i.TXNUM AND TXDATE = I.txdate;*/

                -- REVERT AFTRAN
                UPDATE AFTRANA SET
                    DELTD = 'Y'
                WHERE TXNUM = i.TXNUM AND TXDATE = i.txdate;

        /*        IF SQL%ROWCOUNT <> 1 THEN
                    dbms_output.put_line('Error: Duplicate AFTRAN. Going to rollback');
                    rollback;
                END IF;*/

                -- REVERT ODTRAN
                UPDATE ODTRANA SET
                    DELTD = 'Y'
                WHERE TXNUM = i.TXNUM AND ACCTNO = l_orderid AND TXDATE = i.txdate;
                secnet_un_map(v_tllogrow.txnum,to_char(v_tllogrow.txdate,'DD/MM/RRRR'));
            END LOOP;
        end if;
    END IF;


/*    -- REVERT AFMAST
    UPDATE  afmast SET
        dmatchamt = NVL(dmatchamt,0) - TO_NUMBER(p_txmsg.txfields('14').value)
    WHERE acctno = p_txmsg.txfields('03').value;
    IF SQL%ROWCOUNT <> 1 THEN
        dbms_output.put_line('Error: Duplicate AFMAST. Going to rollback');
        rollback;
    END IF;*/

    -- REVERT IOD
    UPDATE IOD SET
        DELTD = 'Y'
    WHERE ORGORDERID = l_orderid;

    UPDATE IODHIST SET
        DELTD = 'Y'
    WHERE ORGORDERID = l_orderid;

    -- REVERT orderdeal

    DELETE orderdeal
    WHERE orderid = l_orderid;

    -- REVERT ODMAST
    UPDATE odmast SET
        execamt = NVL(execamt,0) - TO_NUMBER(p_txmsg.txfields('14').value),
        execqtty = NVL(execqtty,0) - TO_NUMBER(p_txmsg.txfields('12').value),
        matchamt = NVL(matchamt,0) - TO_NUMBER(p_txmsg.txfields('14').value),
        orstatus = '2',
        remainqtty = remainqtty + TO_NUMBER(p_txmsg.txfields('12').value),
        last_change = SYSTIMESTAMP--,
        --feeacr = 0,
        --feeamt = 0
    WHERE       orderid = L_orderid;
    IF SQL%ROWCOUNT <> 1 THEN
        dbms_output.put_line('Error: Duplicate ODMAST. Going to rollback');
        rollback;
    END IF;

    -- update odtran
    --0027
    INSERT INTO ODTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
    VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),L_orderid,'0027',p_txmsg.txfields ('14').value,NULL,'',p_txmsg.deltd,'',seq_ODTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');
    --0033
    INSERT INTO ODTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
    VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),L_orderid,'0033',p_txmsg.txfields ('14').value,NULL,'',p_txmsg.deltd,'',seq_ODTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');
    --0001
    INSERT INTO ODTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
    VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),L_orderid,'0001',0,'2','',p_txmsg.deltd,'',seq_ODTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');
    --0012
    INSERT INTO ODTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
    VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),L_orderid,'0012',p_txmsg.txfields ('12').value,NULL,'',p_txmsg.deltd,'',seq_ODTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');


    -- REVERT STSCHD
    UPDATE STSCHD SET
        DELTD = 'Y'
    WHERE ORGORDERID = L_orderid;
    /*
    for rec in (
        select * from secmast where orderid is not null and orderid = L_orderid
        )
    loop
        secnet_un_map(rec.txnum,
                   to_char(rec.txdate,'DD/MM/RRRR'));
    end loop; */

    plog.debug (pkgctx, '<<END OF fn_txPreAppUpdate');
    plog.setendsection (pkgctx, 'fn_txPreAppUpdate');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
       plog.setendsection (pkgctx, 'fn_txPreAppUpdate');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txPreAppUpdate;

FUNCTION fn_txAftAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/

    plog.debug (pkgctx, '<<END OF fn_txAftAppUpdate');
    plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
       plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txAftAppUpdate;

BEGIN
      FOR i IN (SELECT *
                FROM tlogdebug)
      LOOP
         logrow.loglevel    := i.loglevel;
         logrow.log4table   := i.log4table;
         logrow.log4alert   := i.log4alert;
         logrow.log4trace   := i.log4trace;
      END LOOP;
      pkgctx    :=
         plog.init ('TXPKS_#8846EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#8846EX;

/
