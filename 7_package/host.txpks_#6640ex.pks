SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#6640ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#6640EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      10/01/2012     Created
 **
 ** (c) 2008 by Financial Software Solutions. JSC.
 ** ----------------------------------------------------------------------------------------------------*/
IS
    FUNCTION FN_TXPREAPPCHECK (P_TXMSG      IN     TX.MSG_RECTYPE,
                               P_ERR_CODE      OUT VARCHAR2)
        RETURN NUMBER;

    FUNCTION FN_TXAFTAPPCHECK (P_TXMSG      IN     TX.MSG_RECTYPE,
                               P_ERR_CODE      OUT VARCHAR2)
        RETURN NUMBER;

    FUNCTION FN_TXPREAPPUPDATE (P_TXMSG      IN     TX.MSG_RECTYPE,
                                P_ERR_CODE      OUT VARCHAR2)
        RETURN NUMBER;

    FUNCTION FN_TXAFTAPPUPDATE (P_TXMSG      IN     TX.MSG_RECTYPE,
                                P_ERR_CODE      OUT VARCHAR2)
        RETURN NUMBER;
END;

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY txpks_#6640ex
IS
    PKGCTX         PLOG.LOG_CTX;
    LOGROW         TLOGDEBUG%ROWTYPE;

    C_CUSTODYCD    CONSTANT CHAR (2) := '88';
    C_SECACCOUNT   CONSTANT CHAR (2) := '03';
    C_CUSTNAME     CONSTANT CHAR (2) := '90';
    C_ADDRESS      CONSTANT CHAR (2) := '91';
    C_LICENSE      CONSTANT CHAR (2) := '92';
    C_CAREBY       CONSTANT CHAR (2) := '97';
    C_BANKACCT     CONSTANT CHAR (2) := '93';
    C_BANKNAME     CONSTANT CHAR (2) := '95';
    C_BANKAVAIL    CONSTANT CHAR (2) := '11';
    C_BANKHOLDED   CONSTANT CHAR (2) := '12';
    C_AVLRELEASE   CONSTANT CHAR (2) := '13';
    C_HOLDAMT      CONSTANT CHAR (2) := '96';
    C_AMOUNT       CONSTANT CHAR (2) := '10';
    C_DESC         CONSTANT CHAR (2) := '30';

    FUNCTION FN_TXPREAPPCHECK (P_TXMSG      IN     TX.MSG_RECTYPE,
                               P_ERR_CODE      OUT VARCHAR2)
        RETURN NUMBER
    IS
    BEGIN
        PLOG.SETBEGINSECTION (PKGCTX, 'fn_txPreAppCheck');
        PLOG.DEBUG (PKGCTX, 'BEGIN OF fn_txPreAppCheck');
        /***************************************************************************************************
         * PUT YOUR SPECIFIC RULE HERE, FOR EXAMPLE:
         * IF NOT <<YOUR BIZ CONDITION>> THEN
         *    p_err_code := '<<ERRNUM>>'; -- Pre-defined in DEFERROR table
         *    plog.setendsection (pkgctx, 'fn_txPreAppCheck');
         *    RETURN errnums.C_BIZ_RULE_INVALID;
         * END IF;
         ***************************************************************************************************/
        PLOG.DEBUG (PKGCTX, '<<END OF fn_txPreAppCheck');
        PLOG.SETENDSECTION (PKGCTX, 'fn_txPreAppCheck');
        RETURN SYSTEMNUMS.C_SUCCESS;
    EXCEPTION
        WHEN OTHERS
        THEN
            P_ERR_CODE := ERRNUMS.C_SYSTEM_ERROR;
            PLOG.ERROR (PKGCTX, SQLERRM);
            PLOG.SETENDSECTION (PKGCTX, 'fn_txPreAppCheck');
            RAISE ERRNUMS.E_SYSTEM_ERROR;
    END FN_TXPREAPPCHECK;

    FUNCTION FN_TXAFTAPPCHECK (P_TXMSG      IN     TX.MSG_RECTYPE,
                               P_ERR_CODE      OUT VARCHAR2)
        RETURN NUMBER
    IS
    BEGIN
        PLOG.SETBEGINSECTION (PKGCTX, 'fn_txAftAppCheck');
        PLOG.DEBUG (PKGCTX, '<<BEGIN OF fn_txAftAppCheck>>');
        /***************************************************************************************************
         * PUT YOUR SPECIFIC RULE HERE, FOR EXAMPLE:
         * IF NOT <<YOUR BIZ CONDITION>> THEN
         *    p_err_code := '<<ERRNUM>>'; -- Pre-defined in DEFERROR table
         *    plog.setendsection (pkgctx, 'fn_txAftAppCheck');
         *    RETURN errnums.C_BIZ_RULE_INVALID;
         * END IF;
         ***************************************************************************************************/
        PLOG.DEBUG (PKGCTX, '<<END OF fn_txAftAppCheck>>');
        PLOG.SETENDSECTION (PKGCTX, 'fn_txAftAppCheck');
        RETURN SYSTEMNUMS.C_SUCCESS;
    EXCEPTION
        WHEN OTHERS
        THEN
            P_ERR_CODE := ERRNUMS.C_SYSTEM_ERROR;
            PLOG.ERROR (PKGCTX, SQLERRM);
            PLOG.SETENDSECTION (PKGCTX, 'fn_txAftAppCheck');
            RAISE ERRNUMS.E_SYSTEM_ERROR;
    END FN_TXAFTAPPCHECK;

    FUNCTION FN_TXPREAPPUPDATE (P_TXMSG      IN     TX.MSG_RECTYPE,
                                P_ERR_CODE      OUT VARCHAR2)
        RETURN NUMBER
    IS
    BEGIN
        PLOG.SETBEGINSECTION (PKGCTX, 'fn_txPreAppUpdate');
        PLOG.DEBUG (PKGCTX, '<<BEGIN OF fn_txPreAppUpdate');
        /***************************************************************************************************
         ** PUT YOUR SPECIFIC PROCESS HERE. . DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
         ***************************************************************************************************/
        PLOG.DEBUG (PKGCTX, '<<END OF fn_txPreAppUpdate');
        PLOG.SETENDSECTION (PKGCTX, 'fn_txPreAppUpdate');
        RETURN SYSTEMNUMS.C_SUCCESS;
    EXCEPTION
        WHEN OTHERS
        THEN
            P_ERR_CODE := ERRNUMS.C_SYSTEM_ERROR;
            PLOG.ERROR (PKGCTX, SQLERRM);
            PLOG.SETENDSECTION (PKGCTX, 'fn_txPreAppUpdate');
            RAISE ERRNUMS.E_SYSTEM_ERROR;
    END FN_TXPREAPPUPDATE;

    FUNCTION FN_TXAFTAPPUPDATE (P_TXMSG      IN     TX.MSG_RECTYPE,
                                P_ERR_CODE      OUT VARCHAR2)
        RETURN NUMBER
    IS
    BEGIN
        PLOG.SETBEGINSECTION (PKGCTX, 'fn_txAftAppUpdate');
        PLOG.DEBUG (PKGCTX, '<<BEGIN OF fn_txAftAppUpdate');
        /***************************************************************************************************
         ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
         ***************************************************************************************************/
        PLOG.DEBUG (PKGCTX, '<<END OF fn_txAftAppUpdate');
        PLOG.SETENDSECTION (PKGCTX, 'fn_txAftAppUpdate');
        RETURN SYSTEMNUMS.C_SUCCESS;
    EXCEPTION
        WHEN OTHERS
        THEN
            P_ERR_CODE := ERRNUMS.C_SYSTEM_ERROR;
            PLOG.ERROR (PKGCTX, SQLERRM);
            PLOG.SETENDSECTION (PKGCTX, 'fn_txAftAppUpdate');
            RAISE ERRNUMS.E_SYSTEM_ERROR;
    END FN_TXAFTAPPUPDATE;
BEGIN
    FOR I IN (SELECT   * FROM TLOGDEBUG)
    LOOP
        LOGROW.LOGLEVEL := I.LOGLEVEL;
        LOGROW.LOG4TABLE := I.LOG4TABLE;
        LOGROW.LOG4ALERT := I.LOG4ALERT;
        LOGROW.LOG4TRACE := I.LOG4TRACE;
    END LOOP;

    PKGCTX :=
        PLOG.INIT ('TXPKS_#6640EX',
                   PLEVEL      => NVL (LOGROW.LOGLEVEL, 30),
                   PLOGTABLE   => (NVL (LOGROW.LOG4TABLE, 'N') = 'Y'),
                   PALERT      => (NVL (LOGROW.LOG4ALERT, 'N') = 'Y'),
                   PTRACE      => (NVL (LOGROW.LOG4TRACE, 'N') = 'Y'));
END TXPKS_#6640EX;

/
