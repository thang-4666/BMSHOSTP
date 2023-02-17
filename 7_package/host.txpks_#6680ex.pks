SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#6680ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#6680EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      28/10/2011     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#6680ex
IS
    PKGCTX       PLOG.LOG_CTX;
    LOGROW       TLOGDEBUG%ROWTYPE;

    C_BANKCODE   CONSTANT CHAR (2) := '01';
    C_STATUS     CONSTANT CHAR (2) := '02';
    C_DESC       CONSTANT CHAR (2) := '30';

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
        L_STRBANKCODE    VARCHAR2 (100);
        L_STRSTATUS      VARCHAR2 (1);
        L_STROLDSTATUS   VARCHAR2 (1);
    BEGIN
        PLOG.SETBEGINSECTION (PKGCTX, 'fn_txAftAppCheck');
        PLOG.DEBUG (PKGCTX, '<<BEGIN OF fn_txAftAppCheck>>');

        L_STRBANKCODE := P_TXMSG.TXFIELDS (C_BANKCODE).VALUE;
        L_STRSTATUS := P_TXMSG.TXFIELDS (C_STATUS).VALUE;

        BEGIN
            SELECT   STATUS
              INTO   L_STROLDSTATUS
              FROM   CRBDEFBANK
             WHERE   BANKCODE = L_STRBANKCODE;
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
                P_ERR_CODE := ERRNUMS.C_RM_BANKCODE_NOTFOUNDED;
                RETURN ERRNUMS.C_RM_BANKCODE_NOTFOUNDED;
        END;

        PLOG.DEBUG (PKGCTX,
                    'Old:' || L_STROLDSTATUS || ' - New:' || L_STRSTATUS);

        IF L_STROLDSTATUS = L_STRSTATUS
        THEN
            P_ERR_CODE := ERRNUMS.C_RM_BANKSTATUS_DUPLICATE;
            RETURN ERRNUMS.C_RM_BANKSTATUS_DUPLICATE;
        END IF;

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
        L_STRBANKCODE   VARCHAR2 (100);
        L_STRSTATUS     VARCHAR2 (1);
    BEGIN
        PLOG.SETBEGINSECTION (PKGCTX, 'fn_txAftAppUpdate');
        PLOG.DEBUG (PKGCTX, '<<BEGIN OF fn_txAftAppUpdate');

        PLOG.DEBUG (PKGCTX, 'BankCode:' || L_STRBANKCODE);
        PLOG.DEBUG (PKGCTX, 'Status:' || L_STRSTATUS);

        L_STRBANKCODE := P_TXMSG.TXFIELDS (C_BANKCODE).VALUE;
        L_STRSTATUS := P_TXMSG.TXFIELDS (C_STATUS).VALUE;

        UPDATE   CRBDEFBANK
           SET   STATUS = L_STRSTATUS
         WHERE   BANKCODE = L_STRBANKCODE;

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
        PLOG.INIT ('TXPKS_#6680EX',
                   PLEVEL      => NVL (LOGROW.LOGLEVEL, 30),
                   PLOGTABLE   => (NVL (LOGROW.LOG4TABLE, 'N') = 'Y'),
                   PALERT      => (NVL (LOGROW.LOG4ALERT, 'N') = 'Y'),
                   PTRACE      => (NVL (LOGROW.LOG4TRACE, 'N') = 'Y'));
END TXPKS_#6680EX;
/
