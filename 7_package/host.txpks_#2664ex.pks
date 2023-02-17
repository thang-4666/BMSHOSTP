SET DEFINE OFF;
CREATE OR REPLACE PACKAGE TXPKS_#2664EX
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#2664EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      16/08/2013     Created
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


CREATE OR REPLACE PACKAGE BODY TXPKS_#2664EX
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_groupid          CONSTANT CHAR(2) := '20';
   c_lnacctno         CONSTANT CHAR(2) := '21';
   c_custodycd        CONSTANT CHAR(2) := '88';
   c_afacctno         CONSTANT CHAR(2) := '03';
   c_custname         CONSTANT CHAR(2) := '90';
   c_address          CONSTANT CHAR(2) := '91';
   c_license          CONSTANT CHAR(2) := '92';
   c_dfblockorg       CONSTANT CHAR(2) := '25';
   c_dfblockamt       CONSTANT CHAR(2) := '26';
   c_ciavlwithdraw    CONSTANT CHAR(2) := '27';
   c_prinnml          CONSTANT CHAR(2) := '40';
   c_pprinnml         CONSTANT CHAR(2) := '50';
   c_prinovd          CONSTANT CHAR(2) := '41';
   c_pprinovd         CONSTANT CHAR(2) := '51';
   c_intnmlacr        CONSTANT CHAR(2) := '42';
   c_pintnmlacr       CONSTANT CHAR(2) := '52';
   c_intdue           CONSTANT CHAR(2) := '43';
   c_pintdue          CONSTANT CHAR(2) := '53';
   c_intovd           CONSTANT CHAR(2) := '44';
   c_pintovd          CONSTANT CHAR(2) := '54';
   c_intovdprin       CONSTANT CHAR(2) := '45';
   c_pintovdprin      CONSTANT CHAR(2) := '55';
   c_feeintnmlacr     CONSTANT CHAR(2) := '46';
   c_pfeeintnmlacr    CONSTANT CHAR(2) := '56';
   c_feeintdue        CONSTANT CHAR(2) := '47';
   c_pfeeintdue       CONSTANT CHAR(2) := '57';
   c_feeintnmlovd     CONSTANT CHAR(2) := '48';
   c_pfeeintnmlovd    CONSTANT CHAR(2) := '58';
   c_feeintovdacr     CONSTANT CHAR(2) := '49';
   c_pfeeintovdacr    CONSTANT CHAR(2) := '59';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
l_mblock number;
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
    select mblock into l_mblock from cimast where acctno = p_txmsg.txfields('03').value;

    if (l_mblock < p_txmsg.txfields('26').value)
        or ((getbaldefovd(p_txmsg.txfields('03').value) + p_txmsg.txfields('26').value)
                < (to_number(p_txmsg.txfields('50').value) + to_number(p_txmsg.txfields('51').value)
                + to_number(p_txmsg.txfields('52').value) + to_number(p_txmsg.txfields('53').value) + to_number(p_txmsg.txfields('54').value) + to_number(p_txmsg.txfields('55').value)
                + to_number(p_txmsg.txfields('56').value) + to_number(p_txmsg.txfields('57').value) + to_number(p_txmsg.txfields('58').value) + to_number(p_txmsg.txfields('59').value))    ) then
            p_err_code:= '-400039';
            RETURN errnums.C_BIZ_RULE_INVALID;
    end if;
    for rec_lnschd in
    (
        select * from lnschd where acctno = p_txmsg.txfields(c_lnacctno).value and reftype = 'P'
    )
    loop
        IF round(to_number(p_txmsg.txfields(c_pprinovd).value),0) > ceil(rec_lnschd.OVD) THEN
             p_err_code := '-540003'; -- Pre-defined in DEFERROR table
             plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
             RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;
        IF round(to_number(p_txmsg.txfields(c_pprinnml).value),0) > ceil(rec_lnschd.NML) THEN
             p_err_code := '-540002'; -- Pre-defined in DEFERROR table
             plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
             RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;
        IF round(to_number(p_txmsg.txfields(c_pintnmlacr).value),0) > ceil(rec_lnschd.INTNMLACR) THEN
            p_err_code := '-540006'; -- Pre-defined in DEFERROR table
            plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
            RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;
        IF round(to_number(p_txmsg.txfields(c_pintdue).value),0) > ceil(rec_lnschd.INTDUE) THEN
            p_err_code := '-540006'; -- Pre-defined in DEFERROR table
            plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
            RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;
        IF round(to_number(p_txmsg.txfields(c_pintovd).value),0) > ceil(rec_lnschd.INTOVD) THEN
            p_err_code := '-540006'; -- Pre-defined in DEFERROR table
            plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
            RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;
        IF round(to_number(p_txmsg.txfields(c_intovdprin).value),0) > ceil(rec_lnschd.INTOVDPRIN) THEN
            p_err_code := '-540006'; -- Pre-defined in DEFERROR table
            plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
            RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;
        IF round(to_number(p_txmsg.txfields(c_pfeeintnmlovd).value),0) > ceil(rec_lnschd.FEEINTNMLOVD) THEN
            p_err_code := '-540013'; -- Pre-defined in DEFERROR table
            plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
            RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;
        IF round(to_number(p_txmsg.txfields(c_pfeeintovdacr).value),0) > ceil(rec_lnschd.FEEINTOVDACR) THEN
            p_err_code := '-540013'; -- Pre-defined in DEFERROR table
            plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
            RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;
        IF round(to_number(p_txmsg.txfields(c_pfeeintdue).value),0) > ceil(rec_lnschd.FEEINTDUE) THEN
            p_err_code := '-540013'; -- Pre-defined in DEFERROR table
            plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
            RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;
        IF round(to_number(p_txmsg.txfields(c_pfeeintnmlacr).value),0) > ceil(rec_lnschd.FEEINTNMLACR) THEN
            p_err_code := '-540013'; -- Pre-defined in DEFERROR table
            plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
            RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;

    end loop;
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
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    for rec_lnschd in
    (
    select * from lnschd where acctno = p_txmsg.txfields(c_lnacctno).value and reftype = 'P'
    )
    loop
        UPDATE LNSCHD
            SET OVD = OVD - round(to_number(p_txmsg.txfields(c_pprinovd).value),0),
            NML = NML - round(to_number(p_txmsg.txfields(c_pprinnml).value),0),
            INTNMLACR = INTNMLACR - round(to_number(p_txmsg.txfields(c_pintnmlacr).value),0),
            INTDUE = INTDUE - round(to_number(p_txmsg.txfields(c_pintdue).value),0),
            INTOVD = INTOVD - round(to_number(p_txmsg.txfields(c_pintovd).value),0),
            INTOVDPRIN = INTOVDPRIN - round(to_number(p_txmsg.txfields(c_intovdprin).value),0),
            FEEINTNMLOVD = FEEINTNMLOVD - round(to_number(p_txmsg.txfields(c_pfeeintnmlovd).value),0),
            FEEINTOVDACR = FEEINTOVDACR - round(to_number(p_txmsg.txfields(c_pfeeintovdacr).value),0),
            FEEINTDUE = FEEINTDUE - round(to_number(p_txmsg.txfields(c_pfeeintdue).value),0),
            FEEINTNMLACR = FEEINTNMLACR - round(to_number(p_txmsg.txfields(c_pfeeintnmlacr).value),0),
            PAID = PAID + round(to_number(p_txmsg.txfields(c_pprinovd).value),0) + round(to_number(p_txmsg.txfields(c_pprinnml).value),0),
            FEEINTPAID =  FEEINTPAID + round(to_number(p_txmsg.txfields(c_pfeeintnmlacr).value),0) + round(to_number(p_txmsg.txfields(c_pfeeintdue).value),0)
                            + round(to_number(p_txmsg.txfields(c_pfeeintovdacr).value),0) + round(to_number(p_txmsg.txfields(c_pfeeintnmlovd).value),0),
            INTPAID = INTPAID + round(to_number(p_txmsg.txfields(c_pintnmlacr).value),0) + round(to_number(p_txmsg.txfields(c_pintdue).value),0)
                        + round(to_number(p_txmsg.txfields(c_pintovd).value),0) + round(to_number(p_txmsg.txfields(c_intovdprin).value),0),
            PAIDDATE = p_txmsg.txdate
        WHERE AUTOID = rec_lnschd.AUTOID;
        INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, INTDUE, INTOVD, INTOVDPRIN,
                    FEEINTOVD, FEEINTOVDPRIN, FEEINTDUE, FEEINTNMLACR,
                    FEEINTPAID, INTPAID)
        VALUES(rec_lnschd.AUTOID,
            p_txmsg.txnum,
            TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),
            - round(to_number(p_txmsg.txfields(c_pprinnml).value),0),

            - round(to_number(p_txmsg.txfields(c_pprinovd).value),0),

             round(to_number(p_txmsg.txfields(c_pprinnml).value),0) + round(to_number(p_txmsg.txfields(c_pprinovd).value),0),

            - round(to_number(p_txmsg.txfields(c_pintnmlacr).value),0),
            - round(to_number(p_txmsg.txfields(c_pintdue).value),0),
            - round(to_number(p_txmsg.txfields(c_pintovd).value),0),
            - round(to_number(p_txmsg.txfields(c_pintovdprin).value),0),
            - round(to_number(p_txmsg.txfields(c_pfeeintnmlovd).value),0),
            - round(to_number(p_txmsg.txfields(c_pfeeintovdacr).value),0),
            - round(to_number(p_txmsg.txfields(c_pfeeintdue).value),0),
            - round(to_number(p_txmsg.txfields(c_pfeeintnmlacr).value),0),

            round(to_number(p_txmsg.txfields(c_pfeeintnmlovd).value),0) + round(to_number(p_txmsg.txfields(c_pfeeintovdacr).value),0)
                            + round(to_number(p_txmsg.txfields(c_pfeeintdue).value),0) + round(to_number(p_txmsg.txfields(c_pfeeintnmlacr).value),0),

            round(to_number(p_txmsg.txfields(c_pintnmlacr).value),0) + round(to_number(p_txmsg.txfields(c_pintdue).value),0)
                        + round(to_number(p_txmsg.txfields(c_pintovd).value),0) + round(to_number(p_txmsg.txfields(c_pintovdprin).value),0));
    end loop;
    for rec_int in
    (
    select * from lnschd where acctno = p_txmsg.txfields(c_lnacctno).value and reftype = 'I'
    )
    loop
        UPDATE LNSCHD
        SET OVD = OVD - round(to_number(p_txmsg.txfields(c_pintovd).value),0),
        NML = NML - round(to_number(p_txmsg.txfields(c_pintdue).value),0),
        PAID = PAID + round(to_number(p_txmsg.txfields(c_pintovd).value),0) + to_number(p_txmsg.txfields(c_intdue).value),
        NMLFEEINT = NMLFEEINT - to_number(p_txmsg.txfields(c_pfeeintdue).value),
        OVDFEEINT = OVDFEEINT - to_number(p_txmsg.txfields(c_pfeeintnmlovd).value),
        PAIDFEEINT = PAIDFEEINT + to_number(p_txmsg.txfields(c_pfeeintdue).value) + to_number(p_txmsg.txfields(c_pfeeintnmlovd).value),
        PAIDDATE=p_txmsg.txdate
        WHERE AUTOID = rec_int.AUTOID;

        INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, NMLFEEINT, OVDFEEINT, PAIDFEEINT)
        VALUES(rec_int.AUTOID, p_txmsg.txnum, TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),
            - round(to_number(p_txmsg.txfields(c_pintdue).value),0),
            - round(to_number(p_txmsg.txfields(c_pintovd).value),0),
            round(to_number(p_txmsg.txfields(c_pintdue).value),0) + to_number(p_txmsg.txfields(c_pintovd).value),
            - to_number(p_txmsg.txfields(c_pfeeintdue).value),
            - to_number(p_txmsg.txfields(c_pfeeintnmlovd).value),
            to_number(p_txmsg.txfields(c_pfeeintdue).value) + to_number(p_txmsg.txfields(c_pfeeintnmlovd).value));
    end loop;

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
         plog.init ('TXPKS_#2664EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#2664EX;
/
