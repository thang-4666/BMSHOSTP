SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#2202ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#2202EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      25/07/2013     Created
 **
 ** (c) 2008 by Financial Software Solutions. JSC.
 ** ----------------------------------------------------------------------------------------------------*/
IS
FUNCTION fn_txPreAppCheck(p_txmsg in out tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_txAftAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_txPreAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_txAftAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
END;
 
 
 
/


CREATE OR REPLACE PACKAGE BODY txpks_#2202ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_custodycd        CONSTANT CHAR(2) := '88';
   c_codeid           CONSTANT CHAR(2) := '01';
   c_afacctno         CONSTANT CHAR(2) := '02';
   c_acctno           CONSTANT CHAR(2) := '03';
   c_custname         CONSTANT CHAR(2) := '90';
   c_address          CONSTANT CHAR(2) := '91';
   c_license          CONSTANT CHAR(2) := '92';
   c_qttytype         CONSTANT CHAR(2) := '12';
   c_tamt             CONSTANT CHAR(2) := '08';
   c_amt              CONSTANT CHAR(2) := '10';
   c_parvalue         CONSTANT CHAR(2) := '11';
   c_price            CONSTANT CHAR(2) := '09';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in out tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS

    l_mrrate number;
    l_mrirate number;
    l_marginrate number;
    v_balance   NUMBER;
    v_bchsts    varchar2(4);
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

     --Canh bao neu GD su dung tien ung truoc
         BEGIN
            SELECT nvl(bchsts, 'N') INTO v_bchsts FROM sbbatchsts WHERE bchdate = getcurrdate AND bchmdl = 'SAAFINDAYPROCESS';
        EXCEPTION WHEN NO_DATA_FOUND THEN
            v_bchsts := 'N';
        END;
        IF v_bchsts = 'Y' then
            SELECT balance INTO v_balance FROM cimast ci WHERE ci.acctno = p_txmsg.txfields('02').value;
            IF p_txmsg.tlid <> '0000' AND p_txmsg.tlid <> '6868' AND p_txmsg.txfields('41').value+p_txmsg.txfields('47').value > v_balance THEN
                p_txmsg.txWarningException('-4001411').value:= cspks_system.fn_get_errmsg('-400141');
                p_txmsg.txWarningException('-4001411').errlev:= '1';
            END IF;
        END IF;


    select nvl(max(rsk.mrratiorate * least(rsk.mrpricerate,se.margincallprice) / 100),0)
        into l_mrrate
    from afserisk rsk, afmast af, aftype aft, mrtype mrt, securities_info se
    where af.actype = rsk.actype and af.actype = aft.actype and aft.mrtype = mrt.actype and mrt.mrtype = 'T' and aft.istrfbuy = 'N'
    and af.acctno = p_txmsg.txfields('02').value and rsk.codeid = p_txmsg.txfields('01').value and rsk.codeid = se.codeid;

    if l_mrrate > 0 then -- check them khi chuyen chung khoan di, tai san con lai phai dam bao ty le.
        select round((case when ci.balance +LEAST(nvl(af.MRCRLIMIT,0),nvl(sec.secureamt,0) + ci.trfbuyamt)+ nvl(sec.avladvance,0) - ci.odamt - nvl(sec.secureamt,0) - ci.trfbuyamt - ci.ramt>=0 then 100000
                --else least( greatest(nvl(sec.SEASS,0) - to_number(p_txmsg.txfields('10').value) * l_mrrate,0), af.mrcrlimitmax - dfodamt)
                 else  greatest(nvl(sec.SEASS,0) - to_number(p_txmsg.txfields('10').value) * l_mrrate,0)
                    / abs(ci.balance +LEAST(nvl(af.MRCRLIMIT,0),nvl(sec.secureamt,0) + ci.trfbuyamt)+ nvl(sec.avladvance,0) - ci.odamt - nvl(sec.secureamt,0) - ci.trfbuyamt - ci.ramt) end),4) * 100 MARGINRATE,
                af.mrirate
                    into l_marginrate, l_mrirate
        from afmast af, cimast ci, v_getsecmarginratio sec
        where af.acctno = ci.acctno and af.acctno = sec.afacctno(+)
        and af.acctno = p_txmsg.txfields('02').value;

        if l_marginrate < l_mrirate then
            p_err_code:='-180064';
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
L_COUNT NUMBER(20,0);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/

    IF p_txmsg.deltd <> 'Y' THEN -- Normal TRANSACTION
      SELECT COUNT(*) INTO L_COUNT FROM SEBLOCKED WHERE AFACCTNO=p_txmsg.txfields('02').VALUE
      AND CODEID=p_txmsg.txfields('01').VALUE AND BLOCKTYPE=p_txmsg.txfields('06').VALUE;

     IF p_txmsg.txfields ('12').value ='002' THEN

        INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0043',ROUND(p_txmsg.txfields('10').value,0),NULL,p_txmsg.txfields ('12').value,p_txmsg.deltd,p_txmsg.txfields ('12').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

        UPDATE SEMAST
         SET
           BLOCKED = BLOCKED + (ROUND(p_txmsg.txfields('10').value,0)),
           TRADE = TRADE - (ROUND(p_txmsg.txfields('10').value,0)), LAST_CHANGE = SYSTIMESTAMP
           WHERE ACCTNO=p_txmsg.txfields('03').value;
        /*IF L_COUNT=0 THEN
            -- ghi vao bang seblocked
            INSERT INTO SEBLOCKED(AFACCTNO,CODEID,BLOCKED,EMKQTTY,BLOCKTYPE,txnum,txdate,txdesc)
            VALUES(p_txmsg.txfields('02').value,p_txmsg.txfields('01').VALUE,
                   ROUND(p_txmsg.txfields('10').value,0),0,p_txmsg.txfields('06').value,p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txdesc);
        ELSE
            UPDATE SEBLOCKED SET BLOCKED=BLOCKED+ROUND(p_txmsg.txfields('10').value,0)
            WHERE AFACCTNO=p_txmsg.txfields('02').VALUE
            AND CODEID=p_txmsg.txfields('01').VALUE AND BLOCKTYPE=p_txmsg.txfields('06').VALUE;
        END IF;*/
        -- ghi vao bang seblocked
        INSERT INTO SEBLOCKED(AFACCTNO,CODEID,BLOCKED,EMKQTTY,BLOCKTYPE,txnum,txdate,txdesc)
        VALUES(p_txmsg.txfields('02').value,p_txmsg.txfields('01').VALUE,
               ROUND(p_txmsg.txfields('10').value,0),0,p_txmsg.txfields('06').value,p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txdesc);


     ELSE
      INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
      VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0087',ROUND(p_txmsg.txfields('10').value,0),NULL,p_txmsg.txfields ('12').value,p_txmsg.deltd,p_txmsg.txfields ('12').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

        UPDATE SEMAST
        SET
           EMKQTTY = EMKQTTY + (ROUND(p_txmsg.txfields('10').value,0)),
           TRADE = TRADE - (ROUND(p_txmsg.txfields('10').value,0)), LAST_CHANGE = SYSTIMESTAMP
           WHERE ACCTNO=p_txmsg.txfields('03').value;
        /*IF L_COUNT=0 THEN
            -- ghi vao bang seblocked
            INSERT INTO SEBLOCKED(AFACCTNO,CODEID,BLOCKED,EMKQTTY,BLOCKTYPE,txnum,txdate,txdesc)
            VALUES(p_txmsg.txfields('02').value,p_txmsg.txfields('01').value,
                   0,ROUND(p_txmsg.txfields('10').value,0),p_txmsg.txfields('06').value,p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txdesc);
        ELSE
            UPDATE SEBLOCKED SET EMKQTTY=EMKQTTY+ROUND(p_txmsg.txfields('10').value,0)
            WHERE AFACCTNO=p_txmsg.txfields('02').VALUE
            AND CODEID=p_txmsg.txfields('01').VALUE AND BLOCKTYPE=p_txmsg.txfields('06').VALUE;
        END IF;*/
         -- ghi vao bang seblocked
        INSERT INTO SEBLOCKED(AFACCTNO,CODEID,BLOCKED,EMKQTTY,BLOCKTYPE,txnum,txdate,txdesc,UNITREQ)
        VALUES(p_txmsg.txfields('02').value,p_txmsg.txfields('01').value,
               0,ROUND(p_txmsg.txfields('10').value,0),p_txmsg.txfields('06').value,p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txdesc,p_txmsg.txfields('93').value);

     END IF;

      INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('03').value,'0040',ROUND(p_txmsg.txfields('10').value,0),NULL,p_txmsg.txfields ('12').value,p_txmsg.deltd,p_txmsg.txfields ('12').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

   ELSE -- Reversal
       UPDATE TLLOG
       SET DELTD = 'Y'
       WHERE TXNUM = p_txmsg.txnum AND TXDATE = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT);
       UPDATE SETRAN        SET DELTD = 'Y'
       WHERE TXNUM = p_txmsg.txnum AND TXDATE = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT);

       update SEBLOCKED  set deltd ='Y' where TXNUM = p_txmsg.txnum AND TXDATE = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT);

       IF p_txmsg.txfields ('12').value ='002' THEN

            UPDATE SEMAST
            SET
                 BLOCKED=BLOCKED - (ROUND(p_txmsg.txfields('10').value,0)),
                 TRADE=TRADE + (ROUND(p_txmsg.txfields('10').value,0)), LAST_CHANGE = SYSTIMESTAMP
              WHERE ACCTNO=p_txmsg.txfields('03').value;

            /*UPDATE SEBLOCKED SET BLOCKED=BLOCKED-(ROUND(p_txmsg.txfields('10').value,0))
            WHERE AFACCTNO=p_txmsg.txfields('02').VALUE
            AND CODEID=p_txmsg.txfields('01').VALUE AND BLOCKTYPE=p_txmsg.txfields('06').VALUE;*/

        ELSE

            UPDATE SEMAST
            SET
                 EMKQTTY=EMKQTTY - (ROUND(p_txmsg.txfields('10').value,0)),
                 TRADE=TRADE + (ROUND(p_txmsg.txfields('10').value,0)), LAST_CHANGE = SYSTIMESTAMP
              WHERE ACCTNO=p_txmsg.txfields('03').value;
            /*UPDATE SEBLOCKED SET EMKQTTY=EMKQTTY-(ROUND(p_txmsg.txfields('10').value,0))
            WHERE AFACCTNO=p_txmsg.txfields('02').VALUE
            AND CODEID=p_txmsg.txfields('01').VALUE AND BLOCKTYPE=p_txmsg.txfields('06').VALUE;*/

        END IF;

   END IF;

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
         plog.init ('TXPKS_#2202EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#2202EX;
/
