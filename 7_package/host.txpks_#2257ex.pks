SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#2257ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#2257EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      05/08/2014     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#2257ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_autoid           CONSTANT CHAR(2) := '04';
   c_codeid           CONSTANT CHAR(2) := '01';
   c_custodycd        CONSTANT CHAR(2) := '88';
   c_afacctno         CONSTANT CHAR(2) := '02';
   c_acctno           CONSTANT CHAR(2) := '03';
   c_custname         CONSTANT CHAR(2) := '90';
   c_address          CONSTANT CHAR(2) := '91';
   c_license          CONSTANT CHAR(2) := '92';
   c_amt              CONSTANT CHAR(2) := '10';
   c_parvalue         CONSTANT CHAR(2) := '11';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
v_qtty NUMBER;
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
    select sendqtty into v_qtty from semortage where autoid = p_txmsg.txfields('04').VALUE;

    --check k thuc hien 1 gd 2 lan
    if v_qtty = 0 then
       p_err_code := '-100778'; -- Pre-defined in DEFERROR table
       plog.setendsection (pkgctx, 'fn_txPreAppCheck');
       RETURN errnums.C_BIZ_RULE_INVALID;
    end if;

    if  v_qtty < p_txmsg.txfields(c_amt).VALUE then
         p_err_code:='-900057';
         plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
        return errnums.C_BIZ_RULE_INVALID;
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
v_sefulltransferid  number;
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/

    IF p_txmsg.deltd <> 'Y' THEN

       UPDATE semortage SET sendqtty = sendqtty -  p_txmsg.txfields(c_amt).VALUE
            WHERE AUTOID = p_txmsg.txfields('04').VALUE;
            --PHUCTQ 25/01/2021 THUE CO TUC 5%
        v_sefulltransferid  := seq_SEFullTransfer_log.NEXTVAL;
            insert into sefulltransfer_log(autoid, txdate, txnum, codeid, custodycd, afacctno, acctno, inward, rcvcustodycd, trade, blocked, mortage, status, deltd)
            SELECT v_sefulltransferid autoid, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT) txdate, p_txmsg.txnum txnum,
                p_txmsg.txfields('01').value codeid, p_txmsg.txfields('88').value custodycd, p_txmsg.txfields('02').value afacctno, p_txmsg.txfields('03').value acctno,
                p_txmsg.txfields('48').value inward, p_txmsg.txfields('47').value rcvcustodycd, to_number(p_txmsg.txfields('10').value) trade,
                to_number(p_txmsg.txfields('06').value) blocked, to_number(p_txmsg.txfields('19').value) mortage, 'P' status, 'N' deltd
              FROM dual ;
        for rec in (
            select * from sepitlog where acctno = p_txmsg.txfields('03').value
            and deltd <> 'Y' and qtty - mapqtty >0 and pitrate > 0
            order by txdate
        )
        loop
            update sepitlog set mapqtty = mapqtty + rec.qtty - rec.mapqtty where autoid = rec.autoid;

            INSERT INTO se2244_log (sendoutid, codeid, camastid, afacctno, qtty, deltd, sepitid,tltxcd)
                    VALUES (v_sefulltransferid, rec.codeid, rec.camastid, rec.afacctno, rec.qtty - rec.mapqtty, 'N', rec.autoid, p_txmsg.tltxcd);

        end loop;
    ELSE

       UPDATE semortage SET sendqtty = sendqtty +  p_txmsg.txfields(c_amt).VALUE
            WHERE AUTOID = p_txmsg.txfields('04').VALUE;
            --PHUCTQ 25/01/2021 THUE CO TUC 5%
         for rec in (select lg.* from se2244_log lg, sefulltransfer_log mst
                    where lg.sendoutid = mst.autoid and lg.tltxcd = p_txmsg.tltxcd
                        and mst.txdate = TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT) and mst.txnum = p_txmsg.txnum and mst.deltd <> 'Y'
                        and lg.deltd <> 'Y'
                        and mst.acctno = p_txmsg.txfields('03').value
                    )
        loop
            update sepitlog set mapqtty = mapqtty - rec.qtty where autoid = rec.sepitid;
            update se2244_log set deltd = 'Y'
            where sendoutid = rec.sendoutid and sepitid = rec.sepitid and afacctno = rec.afacctno and tltxcd = p_txmsg.tltxcd;
        end loop;
        update sefulltransfer_log
        set deltd = 'Y'
        where txdate = TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT) and txnum = p_txmsg.txnum;
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
         plog.init ('TXPKS_#2257EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#2257EX;
/
