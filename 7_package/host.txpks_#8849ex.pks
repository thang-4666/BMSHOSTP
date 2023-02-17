SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#8849ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#8849EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      29/08/2012     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#8849ex
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
    l_count NUMBER;
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
    -- Kiem tra xem lenh sinh ra da khop het hay chua
    SELECT count(od2.orderid)
    INTO l_count
    FROM ODMAST OD, ODMAST OD2
    WHERE OD.orderid = OD2.reforderid
        AND od.errod = 'Y' AND od.errreason <> '02'
        AND OD2.DELTD = 'N' AND OD2.FERROD = 'Y' AND OD2.remainqtty >0 AND OD.ERRSTS = 'N';

    IF l_count >0 THEN
        p_err_code := errnums.C_OD_NEWORDER_NOT_MATCH_ALL; -- Pre-defined in DEFERROR table
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
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
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txPreAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txPreAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC PROCESS HERE. . DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
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
    l_errreason     varchar2(2);
    l_remainqtty    NUMBER;
    l_trfbuydt      DATE;
    l_trfamt        NUMBER;
    l_trfqtty       NUMBER;
    l_currdate      DATE;
    l_seacctno      varchar2(20);
    l_corebank      char(1);
    l_feeamt        number;
    l_cleardate     date;
    l_clearday      number;
    TYPE v_CurTyp  IS REF CURSOR;
    c0        v_CurTyp;
   v_blnREVERSAL boolean;
   l_lngErrCode    number(20,0);
   v_strOBJTYPE    varchar2(100);
   v_strTRFCODE    varchar2(100);
   v_strBANK    varchar2(200);
   v_strAMTEXP    varchar2(200);
   v_strAFACCTNO    varchar2(100);
   v_strREFCODE    varchar2(100);
   v_strBANKACCT    varchar2(100);
   v_strFLDAFFECTDATE    varchar2(100);
   v_strAFFECTDATE    varchar2(100);
   v_strNOTES    varchar2(1000);
   v_strVALUE     varchar2(1000);
   v_strFLDNAME     varchar2(100);
   v_strFLDTYPE     varchar2(100);
   v_strCUSTODYCD   varchar2(100);
   v_strREFAUTOID     number;
   v_strSQL     varchar2(4000);
   v_strStatus char(1);
   v_strCOREBANK    char(1);
   v_strafbankname varchar(100);
   v_strafbankacctno    varchar2(100);
   v_refdorc char(1);
   v_refunhold char(1);
   V_ISCUSTATCOM char(1);

BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    -- NEU LENH LOI DO VSD HUY KET QUA GD THI REVERT LAI TIEN/CK
     SELECT CUSTATCOM INTO V_ISCUSTATCOM  FROM CFMAST WHERE CUSTODYCD =p_txmsg.txfields(c_custodycd).value;

    SELECT od.remainqtty, od.errreason, sts.txdate, sts.amt, sts.qtty, sts.clearday, od.feeamt, sts.cleardate
    INTO l_remainqtty, l_errreason, l_trfbuydt, l_trfamt, l_trfqtty, l_clearday, l_feeamt, l_cleardate
    FROM odmast od, stschd sts
    WHERE od.orderid = sts.orgorderid
        AND sts.duetype IN ('SM','SS') AND  od.orderid = p_txmsg.txfields(c_orderid).value;

    select corebank into l_corebank from cimast where acctno =p_txmsg.txfields(c_afacctno).value;

    IF l_errreason = '02' AND l_remainqtty > 0 THEN
        SELECT getcurrdate INTO l_currdate FROM dual;

        -- CAP NHAT LENH LOI DA HET HIEU LUC
        UPDATE ODMAST SET
            ORSTATUS = '3',
            CANCELQTTY = CANCELQTTY + REMAINQTTY,
            REMAINQTTY = 0
        WHERE ORDERID = p_txmsg.txfields(c_orderid).value;

        -- Xoa lenh trong OOD
        UPDATE OOD SET
            DELTD = 'Y'
        WHERE ORGORDERID = p_txmsg.txfields(c_orderid).value;

        -- Neu lenh tu ngay truoc thi revert lai tien/CK
        l_seacctno := p_txmsg.txfields(c_afacctno).value || p_txmsg.txfields(c_codeid).value;
        IF l_currdate <> to_date(p_txmsg.txfields(c_txdate).value,'DD/MM/YYYY') THEN
            IF p_txmsg.txfields(c_exectype).value IN ('NS','MS','SS') THEN
                IF p_txmsg.txfields(c_exectype).value = 'MS' THEN
                    UPDATE SEMAST SET
                        NETTING = NETTING - l_remainqtty,
                        PREVQTTY = PREVQTTY + l_remainqtty,
                        MORTAGE = MORTAGE + l_remainqtty
                    WHERE ACCTNO = l_seacctno;
                    -- MORTAGE
                    INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                    VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_seacctno,'0065',l_remainqtty,NULL,p_txmsg.txfields (c_afacctno).value,p_txmsg.deltd,p_txmsg.txfields (c_afacctno).value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');
                ELSE
                    UPDATE SEMAST SET
                        TRADE = TRADE + l_remainqtty,
                        NETTING = NETTING - l_remainqtty,
                        PREVQTTY = PREVQTTY + l_remainqtty
                    WHERE ACCTNO = l_seacctno;
                    -- Insert to SETRAN
                    -- TRADE
                    INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                    VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_seacctno,'0012',l_remainqtty,NULL,p_txmsg.txfields (c_afacctno).value,p_txmsg.deltd,p_txmsg.txfields (c_afacctno).value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');
                END IF;

                -- NETTING
                INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_seacctno,'0020',l_remainqtty,NULL,p_txmsg.txfields (c_afacctno).value,p_txmsg.deltd,p_txmsg.txfields (c_afacctno).value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');
                -- PREVQTTY
                INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_seacctno,'0063',l_remainqtty,NULL,p_txmsg.txfields (c_afacctno).value,p_txmsg.deltd,p_txmsg.txfields (c_afacctno).value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

             IF V_ISCUSTATCOM ='Y' THEN
                UPDATE cimast SET
                    RECEIVING = RECEIVING - l_trfamt
                WHERE acctno = p_txmsg.txfields(c_afacctno).value;
                -- INSERT TO CITRAN
                -- RECEIVING
                INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields (c_afacctno).value,'0045',l_trfamt,NULL,p_txmsg.txfields (c_afacctno).value,p_txmsg.deltd,p_txmsg.txfields (c_afacctno).value,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');
           END IF;
           END IF;

            /*IF p_txmsg.txfields(c_exectype).value IN ('NB') THEN
                UPDATE SEMAST SET
                    RECEIVING = RECEIVING - l_trfqtty
                WHERE AFACCTNO = p_txmsg.txfields(c_afacctno).value AND CODEID = p_txmsg.txfields(c_codeid).value;
                -- Insert to SETRAN
                -- TRADE
                INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_seacctno,'0015',l_trfqtty,NULL,p_txmsg.txfields (c_afacctno).value,p_txmsg.deltd,p_txmsg.txfields (c_afacctno).value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');


                UPDATE cimast SET
                    NETTING = NETTING - l_trfamt,
                    TRFAMT = TRFAMT - l_trfamt,
                    FACRTRADE = FACRTRADE - l_trfamt,
                    BALANCE = BALANCE + l_trfamt * (case when l_corebank='Y' then 0 else 1 end)
                WHERE acctno = p_txmsg.txfields(c_afacctno).value;
                -- INSERT TO CITRAN
                -- NETTING
                INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields (c_afacctno).value,'0047',l_trfamt,NULL,p_txmsg.txfields (c_afacctno).value,p_txmsg.deltd,p_txmsg.txfields (c_afacctno).value,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');
                -- TRFAMT
                INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields (c_afacctno).value,'0069',l_trfamt,NULL,p_txmsg.txfields (c_afacctno).value,p_txmsg.deltd,p_txmsg.txfields (c_afacctno).value,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');
                -- FACRTRADE
                INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields (c_afacctno).value,'0036',l_trfamt,NULL,p_txmsg.txfields (c_afacctno).value,p_txmsg.deltd,p_txmsg.txfields (c_afacctno).value,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');
                -- BALANCE
                IF l_trfamt > 0 THEN
                    INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                    VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields (c_afacctno).value,'0012',l_trfamt,NULL,p_txmsg.txfields (c_afacctno).value,p_txmsg.deltd,p_txmsg.txfields (c_afacctno).value,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');
                    --Doan xu ly ghi vao corebank nay neu sua thi bao lai de xem xet phan chinh sua day bang ke sang ngan hang
                    if l_corebank='Y' then --Neu tai khoan corebank thi Cat tien di ngay
                        INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields (c_afacctno).value,'0011',l_trfamt,NULL,p_txmsg.txfields (c_afacctno).value,p_txmsg.deltd,p_txmsg.txfields (c_afacctno).value,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');
                    end if;
                END IF;

                -- TK tra cham thi ko update balance
                IF l_trfbuydt = to_date(p_txmsg.txfields(c_txdate).value,'DD/MM/YYYY') THEN
                    UPDATE cimast SET
                        BALANCE = BALANCE + l_trfamt * (case when l_corebank='Y' then 0 else 1 end)
                    WHERE acctno = p_txmsg.txfields(c_afacctno).value;
                    -- INSERT TO CITRAN
                    -- BALANCE
                    INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                    VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields (c_afacctno).value,'0012',l_trfamt,NULL,p_txmsg.txfields (c_afacctno).value,p_txmsg.deltd,p_txmsg.txfields (c_afacctno).value,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');
                    --Doan xu ly ghi vao corebank nay neu sua thi bao lai de xem xet phan chinh sua day bang ke sang ngan hang
                    if l_corebank='Y' then --Neu tai khoan corebank thi Cat tien di ngay
                        INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields (c_afacctno).value,'0011',l_trfamt,NULL,p_txmsg.txfields (c_afacctno).value,p_txmsg.deltd,p_txmsg.txfields (c_afacctno).value,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');
                    end if;
                END IF;
            END IF;*/
            IF p_txmsg.txfields(c_exectype).value IN ('NB') THEN
                --Revert 8889
                UPDATE SEMAST SET
                    RECEIVING = RECEIVING - l_trfqtty
                WHERE AFACCTNO = p_txmsg.txfields(c_afacctno).value AND CODEID = p_txmsg.txfields(c_codeid).value;
                -- Insert to SETRAN
                -- TRADE
                INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_seacctno,'0015',l_trfqtty,NULL,p_txmsg.txfields (c_afacctno).value,p_txmsg.deltd,p_txmsg.txfields (c_afacctno).value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');


             IF V_ISCUSTATCOM ='Y' THEN
                UPDATE cimast SET
                    NETTING = NETTING - l_trfamt, --Revert appmap 8889
                    TRFBUYAMT = TRFBUYAMT - (l_trfamt+l_feeamt)*(case when l_clearday >0 then 1 else 0 end) --Revert appmap 8889
                    --BALANCE = BALANCE + l_trfamt-- * (case when l_corebank='Y' then 0 else 1 end) --Revert appmap 8865
                WHERE acctno = p_txmsg.txfields(c_afacctno).value;
                -- INSERT TO CITRAN
                -- NETTING
                INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields (c_afacctno).value,'0047',l_trfamt,NULL,p_txmsg.txfields (c_afacctno).value,p_txmsg.deltd,p_txmsg.txfields (c_afacctno).value,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');
                -- TRFBUYAMT
                INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields (c_afacctno).value,'0082',(l_trfamt+l_feeamt)*(case when l_clearday >0 then 1 else 0 end),NULL,p_txmsg.txfields (c_afacctno).value,p_txmsg.deltd,p_txmsg.txfields (c_afacctno).value,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');
            END IF;
                if l_cleardate <l_currdate THEN
                    --Revert 8865

             IF V_ISCUSTATCOM ='Y' THEN
                    UPDATE cimast SET
                    TRFBUYAMT = TRFBUYAMT + (l_trfamt)*(case when l_clearday >0 then 1 else 0 end), --Revert appmap 8865
                    BALANCE = BALANCE + l_trfamt-- * (case when l_corebank='Y' then 0 else 1 end) --Revert appmap 8865
                    WHERE acctno = p_txmsg.txfields(c_afacctno).value;
                    -- BALANCE
                    INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                    VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields (c_afacctno).value,'0012',l_trfamt,NULL,p_txmsg.txfields (c_afacctno).value,p_txmsg.deltd,p_txmsg.txfields (c_afacctno).value,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');
                    -- TRFBUYAMT
                    INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                    VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields (c_afacctno).value,'0083',(l_trfamt)*(case when l_clearday >0 then 1 else 0 end),NULL,p_txmsg.txfields (c_afacctno).value,p_txmsg.deltd,p_txmsg.txfields (c_afacctno).value,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');
                END IF;

                     plog.setbeginsection (pkgctx, 'fn_genBankRequest');
                     plog.debug (pkgctx, '<<BEGIN OF fn_GenBankRequest');
                     v_blnREVERSAL:=case when p_txmsg.deltd ='Y' then true else false end;

                     if not v_blnREVERSAL then
                         v_strAFACCTNO:=p_txmsg.txfields('03').value;
                         --Kiem tra neu la TK corebank thi tiep tuc
                         select corebank,bankname,bankacctno into v_strCOREBANK, v_strafbankname, v_strafbankacctno from afmast where acctno = v_strAFACCTNO;
                         if v_strCOREBANK ='Y' then

                                 --Begin Gen yeu cau sang ngan hang 0088-TRFNML
                           v_strOBJTYPE:='T';
                           v_strTRFCODE:='TRFRLSBUY';
                           v_strREFCODE:= to_char(p_txmsg.txdate,'DD/MM/RRRR') || p_txmsg.txnum;
                           v_strAFFECTDATE:= to_char(p_txmsg.txdate,'DD/MM/RRRR');
                           v_strBANK:=v_strafbankname;
                           v_strBANKACCT:=v_strafbankacctno;
                           v_strNOTES:= utf8nums.c_const_RM_RM8848ex_diengiai_1 ||v_strCUSTODYCD;
                           v_strVALUE:=l_trfamt + l_feeamt;
                           if length(v_strBANK)>0 and length(v_strBANKACCT)>0 and v_strVALUE >0 then
                               --Ghi nhan vao CRBTXREQ
                               select seq_CRBTXREQ.nextval into v_strREFAUTOID from dual;
                               INSERT INTO CRBTXREQ (REQID, OBJTYPE, OBJNAME, OBJKEY, TRFCODE, REFCODE, TXDATE, AFFECTDATE, AFACCTNO, TXAMT, BANKCODE, BANKACCT, STATUS, REFVAL, NOTES)
                                   VALUES (v_strREFAUTOID, 'T', p_txmsg.tltxcd,p_txmsg.txnum, v_strTRFCODE,v_strREFCODE, TO_DATE(p_txmsg.txdate, 'dd/mm/rrrr'), TO_DATE(v_strAFFECTDATE , 'dd/mm/rrrr'),
                                           v_strAFACCTNO , v_strVALUE , v_strBANK,v_strBANKACCT, 'P', NULL,v_strNOTES);

                             IF V_ISCUSTATCOM ='Y' THEN
                            UPDATE cimast SET
                                BALANCE = BALANCE - (l_trfamt+l_feeamt)
                                WHERE acctno = p_txmsg.txfields(c_afacctno).value;
                             -- INSERT TO CITRAN
                                -- RECEIVING
                                INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                                VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields (c_afacctno).value,'0011',l_trfamt+l_feeamt,NULL,p_txmsg.txfields (c_afacctno).value,p_txmsg.deltd,p_txmsg.txfields (c_afacctno).value,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');
                            END IF;

                                      end if;
                                  End if;
                                   else
                                       v_strTRFCODE:='TRFRLSADV';
                                       v_strAFACCTNO:=p_txmsg.txfields('03').value;
                                       v_strVALUE:=p_txmsg.txfields('10').value-p_txmsg.txfields('11').value;
                                       begin
                                           SELECT STATUS into v_strStatus FROM CRBTXREQ MST WHERE MST.OBJNAME=p_txmsg.tltxcd AND MST.OBJKEY=p_txmsg.txnum AND MST.TXDATE=TO_DATE(p_txmsg.txdate, 'DD/MM/RRRR') and trfcode =v_strTRFCODE;
                                           if  v_strStatus = 'P' then
                                               update CRBTXREQ set status ='D' WHERE OBJNAME=p_txmsg.tltxcd AND OBJKEY=p_txmsg.txnum AND TXDATE=TO_DATE(p_txmsg.txdate, 'DD/MM/RRRR');

                                               --Revert Dr HoldBalance transfer amount
                                               update cimast set holdbalance = holdbalance + v_strVALUE where acctno = v_strAFACCTNO;

                                           else
                                               plog.setendsection (pkgctx, 'fn_txAppUpdate');
                                               p_err_code:=-670101;--Trang thai bang ke khong hop le
                                               Return errnums.C_BIZ_RULE_INVALID;
                                           end if;
                                       exception when others then
                                           null; --Khong co bang ke can xoa
                                       end;
                                   End if;
                               cspks_rmproc.sp_exec_create_crbtrflog_auto(TO_char(p_txmsg.txdate, 'dd/mm/rrrr'), p_txmsg.txnum,p_err_code);

                               plog.debug (pkgctx, '<<END OF fn_GenBankRequest');
                               plog.setendsection (pkgctx, 'fn_GenBankRequest');


                    /*IF l_trfamt > 0 THEN
                        INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields (c_afacctno).value,'0012',l_trfamt,NULL,p_txmsg.txfields (c_afacctno).value,p_txmsg.deltd,p_txmsg.txfields (c_afacctno).value,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');
                        --Doan xu ly ghi vao corebank nay neu sua thi bao lai de xem xet phan chinh sua day bang ke sang ngan hang
                        if l_corebank='Y' then --Neu tai khoan corebank thi Cat tien di ngay
                            INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields (c_afacctno).value,'0011',l_trfamt,NULL,p_txmsg.txfields (c_afacctno).value,p_txmsg.deltd,p_txmsg.txfields (c_afacctno).value,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');
                        end if;


                    END IF;*/
                    --revert 8855
                    IF V_ISCUSTATCOM ='Y' THEN
                    UPDATE cimast SET
                    TRFBUYAMT = TRFBUYAMT + (l_feeamt)*(case when l_clearday >0 then 1 else 0 end), --Revert appmap 8865
                    BALANCE = BALANCE + l_feeamt,-- * (case when l_corebank='Y' then 0 else 1 end) --Revert appmap 8865
                    FACRTRADE=FACRTRADE-l_feeamt
                    WHERE acctno = p_txmsg.txfields(c_afacctno).value;
                    --Revert lai Fee tinh cho lenh
                    update odmast set feeamt=0, feeacr=0 where orderid =p_txmsg.txfields(c_orderid).value;
                    --Cr TRFBUYAMT
                    INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                    VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields (c_afacctno).value,'0083',(l_feeamt)*(case when l_clearday >0 then 1 else 0 end),NULL,p_txmsg.txfields (c_afacctno).value,p_txmsg.deltd,p_txmsg.txfields (c_afacctno).value,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');
                    --Cr BALANCE
                    INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                    VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields (c_afacctno).value,'0012',l_feeamt,NULL,p_txmsg.txfields (c_afacctno).value,p_txmsg.deltd,p_txmsg.txfields (c_afacctno).value,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');
                    --Dr FACRTRADE
                    INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                    VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields (c_afacctno).value,'0036',l_feeamt,NULL,p_txmsg.txfields (c_afacctno).value,p_txmsg.deltd,p_txmsg.txfields (c_afacctno).value,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');
                    end if;
                    END IF;

               /* -- TK tra cham chua thanh toan thi ko update balance
                --IF l_trfbuydt = to_date(p_txmsg.txfields(c_txdate).value,'DD/MM/YYYY') THEN
                IF l_trfbuydt < l_currdate THEN
                    UPDATE cimast SET
                        BALANCE = BALANCE + l_trfamt * (case when l_corebank='Y' then 0 else 1 end)
                    WHERE acctno = p_txmsg.txfields(c_afacctno).value;
                    -- INSERT TO CITRAN
                    -- BALANCE
                    INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                    VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields (c_afacctno).value,'0012',l_trfamt,NULL,p_txmsg.txfields (c_afacctno).value,p_txmsg.deltd,p_txmsg.txfields (c_afacctno).value,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');
                    --Doan xu ly ghi vao corebank nay neu sua thi bao lai de xem xet phan chinh sua day bang ke sang ngan hang
                    if l_corebank='Y' then --Neu tai khoan corebank thi Cat tien di ngay
                        INSERT INTO CITRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
                        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields (c_afacctno).value,'0011',l_trfamt,NULL,p_txmsg.txfields (c_afacctno).value,p_txmsg.deltd,p_txmsg.txfields (c_afacctno).value,seq_CITRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');
                    end if;
                END IF;*/
                /*
                -- Xoa GD 8865
                UPDATE tllogall SET
                    deltd = 'Y'
                WHERE txdate = l_txdate AND txnum = l_txnum;
                UPDATE citrana SET
                    deltd = 'Y'
                WHERE txdate = l_txdate AND txnum = l_txnum;
                UPDATE citran_gen SET
                    deltd = 'Y'
                WHERE txdate = l_txdate AND txnum = l_txnum;
                UPDATE setrana SET
                    deltd = 'Y'
                WHERE txdate = l_txdate AND txnum = l_txnum;
                UPDATE setran_gen SET
                    deltd = 'Y'
                WHERE txdate = l_txdate AND txnum = l_txnum;*/
            END IF;
        END IF;
    END IF;
    -- KET THUC: NEU LENH LOI DO VSD HUY KET QUA GD THI REVERT LAI TIEN/CK

    -- CAP NHAT LENH SINH DE SUA LOI TRANG THAI SUA LOI LA HOAN TAT
    UPDATE ODMAST SET
        ERRSTS = 'C'
    WHERE REFORDERID = p_txmsg.txfields(c_orderid).value AND FERROD = 'Y';

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
         plog.init ('TXPKS_#8849EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#8849EX;
/
