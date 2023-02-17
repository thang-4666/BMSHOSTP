SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#0015ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#0015EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      07/12/2011     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#0015ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_tliduser         CONSTANT CHAR(2) := '03';
   c_username         CONSTANT CHAR(2) := '04';
   c_t0               CONSTANT CHAR(2) := '16';
   c_t0_old           CONSTANT CHAR(2) := '17';
   c_t0_max           CONSTANT CHAR(2) := '18';
   c_usertype         CONSTANT CHAR(2) := '25';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
    V_T0SYSTEMLIMIT     NUMBER;
    V_T0USERLIMIT       NUMBER;
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
    SELECT TO_NUMBER(MAX(varvalue)) INTO V_T0SYSTEMLIMIT FROM SYSVAR WHERE GRNAME = 'SYSTEM' AND VARNAME = 'T0SYSTEMLIMIT';
    V_T0SYSTEMLIMIT := NVL(V_T0SYSTEMLIMIT,0);

    SELECT SUM(T0) INTO V_T0USERLIMIT FROM USERLIMIT WHERE USERTYPE = 'Flex' AND TLIDUSER <> p_txmsg.txfields('03').VALUE;
    V_T0USERLIMIT := NVL(V_T0USERLIMIT,0);

    if V_T0SYSTEMLIMIT < V_T0USERLIMIT + NVL(p_txmsg.txfields('16').VALUE,0) then
        p_err_code := '-180075';
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
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
    V_T0SYSTEMLIMIT     NUMBER;
    V_T0USERLIMIT       NUMBER;
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
    SELECT TO_NUMBER(MAX(varvalue)) INTO V_T0SYSTEMLIMIT FROM SYSVAR WHERE GRNAME = 'SYSTEM' AND VARNAME = 'T0SYSTEMLIMIT';
    V_T0SYSTEMLIMIT := NVL(V_T0SYSTEMLIMIT,0);

    SELECT SUM(T0) INTO V_T0USERLIMIT FROM USERLIMIT WHERE USERTYPE = 'Flex' AND TLIDUSER <> p_txmsg.txfields('03').VALUE;
    V_T0USERLIMIT := NVL(V_T0USERLIMIT,0);

    if V_T0SYSTEMLIMIT < V_T0USERLIMIT + p_txmsg.txfields('16').VALUE then
        p_err_code := '-180075';
        plog.setendsection (pkgctx, 'fn_txAftAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    end if;
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
v_strTLID   varchar2(4);
v_USERTYPE  varchar2(20);
v_count     number;
v_T0        number;
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/

     --Kiem tra xem khach hang da duoc cap han muc hay chua, neu chua co thi insert, co roi thi Update.

        SELECT count(*) into v_count FROM USERLIMIT WHERE TLIDUSER = p_txmsg.txfields('03').VALUE;
        if v_count > 0 then
            SELECT T0 into v_T0 FROM USERLIMIT WHERE TLIDUSER = p_txmsg.txfields('03').VALUE;
            --SELECT nvl(USERTYPE,'') into v_USERTYPE FROM USERLIMIT WHERE TLIDUSER = p_txmsg.txfields('03').VALUE;
            IF p_txmsg.txfields('18').VALUE<0 then
                p_err_code:= -200080;
                RETURN -200080;
            end if;
            UPDATE USERLIMIT SET T0= to_number(p_txmsg.txfields('16').VALUE), T0MAX = to_number(p_txmsg.txfields('18').VALUE) WHERE TLIDUSER=p_txmsg.txfields('03').VALUE;
        else
            INSERT INTO USERLIMIT (TLIDUSER, T0, T0MAX, USERTYPE) VALUES (p_txmsg.txfields('03').VALUE,p_txmsg.txfields('16').VALUE ,p_txmsg.txfields('18').VALUE ,p_txmsg.txfields('25').VALUE );
        end if;
        -- Cap nhat vao bang Userlimit log ------------------

        INSERT INTO USERLIMITLOG (TXDATE,TXNUM,TLIDUSER,T0, T0MAX, USERTYPE,TYPERECEIVE)
                VALUES (to_date( p_txmsg.txdate,'DD/MM/RRRR'),systemnums.C_BATCH_PREFIXED || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0'),p_txmsg.txfields('03').VALUE,p_txmsg.txfields('16').VALUE, p_txmsg.txfields('18').VALUE,p_txmsg.txfields('25').VALUE,'T0');


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
         plog.init ('TXPKS_#0015EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#0015EX;
/
