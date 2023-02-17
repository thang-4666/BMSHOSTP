SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#2246ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#2246EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      08/10/2010     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#2246ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_autoid           CONSTANT CHAR(2) := '05';
   c_codeid           CONSTANT CHAR(2) := '01';
   c_afacctno         CONSTANT CHAR(2) := '02';
   c_custodycd        CONSTANT CHAR(2) := '88';
   c_acctno           CONSTANT CHAR(2) := '03';
   c_custname         CONSTANT CHAR(2) := '90';
   c_address          CONSTANT CHAR(2) := '91';
   c_license          CONSTANT CHAR(2) := '92';
   c_depotrade        CONSTANT CHAR(2) := '06';
   c_depoblock        CONSTANT CHAR(2) := '04';
   c_qttytype         CONSTANT CHAR(2) := '08';
   c_qtty             CONSTANT CHAR(2) := '10';
   c_parvalue         CONSTANT CHAR(2) := '11';
   c_price            CONSTANT CHAR(2) := '09';
   c_desc             CONSTANT CHAR(2) := '30';
   c_pdate            CONSTANT CHAR(2) := '07';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
    L_COUNT NUMBER;
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
    IF p_txmsg.deltd = 'N' THEN
        if txpks_prchk.fn_RoomLimitCheck(p_txmsg.txfields('02').value, p_txmsg.txfields('01').value,
            greatest(to_number(p_txmsg.txfields('06').value),0), p_err_code) <> 0 then
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;
    else
        --check k thuc hien 1 gd 2 lan
        SELECT COUNT(1) into L_COUNT FROM SEDEPOSIT WHERE STATUS='C' AND AUTOID = P_TXMSG.TXFIELDS('05').VALUE;
        if L_COUNT > 0 then
            p_err_code := '-100778'; -- Pre-defined in DEFERROR table
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;
    end if;
    plog.debug (pkgctx, '<<END OF fn_txPreAppCheck');
    plog.setendsection (pkgctx, 'fn_txPreAppCheck');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'fn_txPreAppCheck');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txPreAppCheck;

FUNCTION fn_txAftAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
l_depotrade  number ;
l_depoblock  number ;
l_status varchar2(100);
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

    select status into l_status  from SEDEPOSIT WHERE AUTOID = p_txmsg.txfields('05').VALUE;

     IF l_status ='C'  THEN
        p_err_code := '-904458';
        plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
     END IF;


   plog.debug (pkgctx, '<<END OF fn_txAftAppCheck>>');
   plog.setendsection (pkgctx, 'fn_txAftAppCheck');
   RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
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
      plog.error (pkgctx, SQLERRM);
       plog.setendsection (pkgctx, 'fn_txPreAppUpdate');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txPreAppUpdate;

FUNCTION fn_txAftAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
v_strCODEID varchar2(10);
v_strAFACCTNO varchar2(20);
v_strACCTNO varchar2(20);
v_strTYPEDEPOBLOCK varchar2(20);
v_nAMT number;
v_nPRICE number;
v_nDEPOTRADE number;
v_nDEPOBLOCK number;
v_txnum varchar2(20);
V_txdate date;
v_rdate date ;
v_currmonth VARCHAR2(10);
v_TBALDT DATE;
v_count_days NUMBER;
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/


    v_strAFACCTNO := p_txmsg.txfields('02').VALUE;
    v_strACCTNO := p_txmsg.txfields('03').VALUE;
    v_nAMT := p_txmsg.txfields('10').VALUE;
    v_nDEPOTRADE := p_txmsg.txfields('06').VALUE;
    v_nDEPOBLOCK := p_txmsg.txfields('04').VALUE;
    v_strTYPEDEPOBLOCK := p_txmsg.txfields('08').VALUE;
    v_rdate := to_date(p_txmsg.txfields('13').VALUE,'dd/mm/yyyy');

    v_txnum:= p_txmsg.txnum;
    V_txdate:= p_txmsg.txdate;
    v_TBALDT:= Greatest(to_date ( p_txmsg.txfields('32').value,'DD/MM/RRRR')+1, p_txmsg.busdate);
    -- so ngay tinh phi luu ky chua den han
    v_count_days:= p_txmsg.txdate - v_TBALDT;
    v_currmonth := to_char(to_date(V_txdate,'DD/MM/RRRR'),'RRRRMM');

    IF p_txmsg.deltd <> 'Y' THEN

        IF v_strTYPEDEPOBLOCK ='002' then
            INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0043',ROUND(p_txmsg.txfields('04').value,0),NULL,'',p_txmsg.deltd,p_txmsg.txfields ('08').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

        ELSE

            INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0087',ROUND(p_txmsg.txfields('04').value,0),NULL,'',p_txmsg.deltd,p_txmsg.txfields ('08').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

        END IF ;
        INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0051',ROUND(p_txmsg.txfields('10').value*p_txmsg.txfields('09').value,0),NULL,p_txmsg.txfields ('03').value,p_txmsg.deltd,p_txmsg.txfields ('03').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

        INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0052',ROUND(p_txmsg.txfields('10').value,0),NULL,p_txmsg.txfields ('03').value,p_txmsg.deltd,p_txmsg.txfields ('03').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

        INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0059',ROUND(p_txmsg.txfields('10').value,0),NULL,'',p_txmsg.deltd,'',seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

        INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0012',ROUND(p_txmsg.txfields('06').value,0),NULL,'',p_txmsg.deltd,'',seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'Luu ky chung khoan');

        INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0079',ROUND(p_txmsg.txfields('14').value,0),NULL,'',p_txmsg.deltd,'',seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

        IF v_strTYPEDEPOBLOCK ='002' then
            UPDATE SEMAST
            SET
            BLOCKED = BLOCKED + (ROUND(p_txmsg.txfields('04').value,0)),
            DCRQTTY = DCRQTTY + (ROUND(p_txmsg.txfields('10').value,0)),
            WTRADE = WTRADE + (ROUND(p_txmsg.txfields('14').value,0)),
            SENDDEPOSIT = SENDDEPOSIT - (ROUND(p_txmsg.txfields('10').value,0)),
            DCRAMT = DCRAMT + (ROUND(p_txmsg.txfields('10').value*p_txmsg.txfields('09').value,0)),
            TRADE = TRADE + (ROUND(p_txmsg.txfields('06').value,0)), LAST_CHANGE = SYSTIMESTAMP
            WHERE ACCTNO=p_txmsg.txfields('03').value;
        ELSE
            UPDATE SEMAST
            SET
            EMKQTTY = EMKQTTY + (ROUND(p_txmsg.txfields('04').value,0)),
            DCRQTTY = DCRQTTY + (ROUND(p_txmsg.txfields('10').value,0)),
            WTRADE = WTRADE + (ROUND(p_txmsg.txfields('14').value,0)),
            SENDDEPOSIT = SENDDEPOSIT - (ROUND(p_txmsg.txfields('10').value,0)),
            DCRAMT = DCRAMT + (ROUND(p_txmsg.txfields('10').value*p_txmsg.txfields('09').value,0)),
            TRADE = TRADE + (ROUND(p_txmsg.txfields('06').value,0)), LAST_CHANGE = SYSTIMESTAMP
            WHERE ACCTNO=p_txmsg.txfields('03').value;

        END IF ;

        UPDATE SEDEPOSIT SET STATUS='C' WHERE AUTOID = p_txmsg.txfields('05').VALUE;
        -- chi tang phi luu ky voi TK nhan
        --IF ( p_txmsg.txfields('33').VALUE > 0 ) THEN
        IF  p_txmsg.txdate <> p_txmsg.BUSDATE  then
        /* INSERT INTO SEDEPOBAL (AUTOID, ACCTNO, TXDATE, DAYS, QTTY, DELTD,ID,amt)
         VALUES (SEQ_SEDEPOBAL.NEXTVAL, p_txmsg.txfields('03').value,v_TBALDT,v_count_days, p_txmsg.txfields('12').value, 'N',to_char(V_txdate)||V_txnum, p_txmsg.txfields('33').VALUE );
*/          cspks_ciproc.PR_LOGSEDEPOBAL(SUBSTR( p_txmsg.txfields('03').value,11,6),SUBSTR( p_txmsg.txfields('03').value,0,10),
            v_count_days,TO_NUMBER(P_TXMSG.TXFIELDS('33').value),
            TO_NUMBER(P_TXMSG.TXFIELDS('12').VALUE),v_TBALDT,to_char(V_txdate)||V_txnum);

        END IF;
         -- ghi nhan them mot dong phi LK den han
         --   IF ( p_txmsg.txfields('15').VALUE > 0 ) THEN
        IF  p_txmsg.txdate <> p_txmsg.BUSDATE  then
            IF cspks_ciproc.fn_FeeDepoMaturityBackdate(p_txmsg,p_err_code) <> systemnums.C_SUCCESS THEN
                RETURN errnums.C_BIZ_RULE_INVALID;
            END IF;
        END IF;
        secmast_generate(p_txmsg.txnum, p_txmsg.txdate, p_txmsg.busdate, p_txmsg.txfields('02').value,
        p_txmsg.txfields('01').value, 'D', 'I', NULL, NULL,  p_txmsg.txfields('10').value, p_txmsg.txfields('09').value, 'Y');
        -- PhuongHT add: cap nhat trang thai A trong sedepowftlog de co the lam 2225
        UPDATE SEDEPOWFTLOG SET STATUS='A' WHERE REF=TO_NUMBER( p_txmsg.txfields('05').VALUE);
    ELSE

        IF v_strTYPEDEPOBLOCK ='002' THEN

            UPDATE SEMAST
            SET
            BLOCKED=BLOCKED - (ROUND(p_txmsg.txfields('04').value,0)),
            DCRQTTY=DCRQTTY - (ROUND(p_txmsg.txfields('10').value,0)),
            WTRADE=WTRADE - (ROUND(p_txmsg.txfields('14').value,0)),
            SENDDEPOSIT=SENDDEPOSIT + (ROUND(p_txmsg.txfields('10').value,0)),
            DCRAMT=DCRAMT - (ROUND(p_txmsg.txfields('10').value*p_txmsg.txfields('09').value,0)),
            TRADE=TRADE - (ROUND(p_txmsg.txfields('06').value,0)), LAST_CHANGE = SYSTIMESTAMP
            WHERE ACCTNO=p_txmsg.txfields('03').value;

        ELSE

             UPDATE SEMAST
             SET
             EMKQTTY=EMKQTTY - (ROUND(p_txmsg.txfields('04').value,0)),
             DCRQTTY=DCRQTTY - (ROUND(p_txmsg.txfields('10').value,0)),
             WTRADE=WTRADE - (ROUND(p_txmsg.txfields('14').value,0)),
             SENDDEPOSIT=SENDDEPOSIT + (ROUND(p_txmsg.txfields('10').value,0)),
             DCRAMT=DCRAMT - (ROUND(p_txmsg.txfields('10').value*p_txmsg.txfields('09').value,0)),
             TRADE=TRADE - (ROUND(p_txmsg.txfields('06').value,0)), LAST_CHANGE = SYSTIMESTAMP
             WHERE ACCTNO=p_txmsg.txfields('03').value;

        END IF;

        UPDATE SEDEPOSIT SET STATUS='S' WHERE AUTOID = p_txmsg.txfields('05').VALUE;

         -- PhuongHT edit: log phi luu ky backdate
        IF ( p_txmsg.txfields('33').VALUE > 0 ) THEN
            UPDATE sedepobal SET deltd='Y' WHERE id=to_char(V_txdate)||V_txnum ;
            UPDATE SEDEPOBAL_HIST SET deltd='Y' WHERE id=to_char(V_txdate)||V_txnum ;
        END IF;
--            IF ( p_txmsg.txfields('15').VALUE > 0 ) THEN
        IF  p_txmsg.txdate <> p_txmsg.BUSDATE  then
            IF cspks_ciproc.fn_FeeDepoMaturityBackdate(p_txmsg,p_err_code) <> systemnums.C_SUCCESS THEN
                RETURN errnums.C_BIZ_RULE_INVALID;
                END IF;
            END IF;
             -- end of PhuongHT
        secnet_un_map(p_txmsg.txnum, p_txmsg.txdate);
         -- PhuongHT add: cap nhat trang thai A trong sedepowftlog de co the lam 2225
        UPDATE SEDEPOWFTLOG SET STATUS='P' WHERE REF=TO_NUMBER( p_txmsg.txfields('05').VALUE);
        update setran set  deltd ='Y' WHERE TXNUM = p_txmsg.txnum AND TXDATE = TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT);
    End if;

    plog.debug (pkgctx, '<<END OF fn_txAftAppUpdate');
    plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
    RETURN systemnums.C_SUCCESS;
    EXCEPTION
    WHEN OTHERS
       THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
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
         plog.init ('TXPKS_#2246EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#2246EX;
/
