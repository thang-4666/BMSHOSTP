SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#5540ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#5540EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      15/02/2012     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#5540ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_autoid           CONSTANT CHAR(2) := '01';
   c_acctno           CONSTANT CHAR(2) := '03';
   c_t0odamt          CONSTANT CHAR(2) := '09';
   c_t0prinovd        CONSTANT CHAR(2) := '10';
   c_t0prinnml        CONSTANT CHAR(2) := '12';
   c_t0prindue        CONSTANT CHAR(2) := '11';
   c_prinovd          CONSTANT CHAR(2) := '13';
   c_prindue          CONSTANT CHAR(2) := '14';
   c_prinnml          CONSTANT CHAR(2) := '15';
   c_feeovd           CONSTANT CHAR(2) := '20';
   c_sumintnmlovd     CONSTANT CHAR(2) := '21';
   c_t0intnmlovd      CONSTANT CHAR(2) := '22';
   c_intnmlovd        CONSTANT CHAR(2) := '23';
   c_feeintnmlovd     CONSTANT CHAR(2) := '93';
   c_sumintovdacr     CONSTANT CHAR(2) := '24';
   c_t0intovdacr      CONSTANT CHAR(2) := '25';
   c_feeintovdacr     CONSTANT CHAR(2) := '96';
   c_intovdacr        CONSTANT CHAR(2) := '26';
   c_feedue           CONSTANT CHAR(2) := '27';
   c_sumintdue        CONSTANT CHAR(2) := '28';
   c_t0intdue         CONSTANT CHAR(2) := '29';
   c_feeintdue        CONSTANT CHAR(2) := '91';
   c_intdue           CONSTANT CHAR(2) := '31';
   c_fee              CONSTANT CHAR(2) := '32';
   c_sumintnmlacr     CONSTANT CHAR(2) := '33';
   c_t0intnmlacr      CONSTANT CHAR(2) := '34';
   c_intnmlacr        CONSTANT CHAR(2) := '35';
   c_feeintnmlacr     CONSTANT CHAR(2) := '95';
   c_ciacctno         CONSTANT CHAR(2) := '05';
   c_odamt            CONSTANT CHAR(2) := '40';
   c_prinodamt        CONSTANT CHAR(2) := '41';
   c_prinnmlamt       CONSTANT CHAR(2) := '42';
   c_intodamt         CONSTANT CHAR(2) := '43';
   c_intnmlamt        CONSTANT CHAR(2) := '44';
   c_lntype           CONSTANT CHAR(2) := '07';
   c_prinamt          CONSTANT CHAR(2) := '45';
   c_intamt           CONSTANT CHAR(2) := '46';
   c_advfee           CONSTANT CHAR(2) := '47';
   c_advpayamt        CONSTANT CHAR(2) := '81';
   c_feeamt           CONSTANT CHAR(2) := '82';
   c_percent          CONSTANT CHAR(2) := '50';
   c_payamt           CONSTANT CHAR(2) := '83';
   c_pt0prinovd       CONSTANT CHAR(2) := '60';
   c_pt0prindue       CONSTANT CHAR(2) := '61';
   c_pt0prinnml       CONSTANT CHAR(2) := '62';
   c_pprinovd         CONSTANT CHAR(2) := '63';
   c_pprindue         CONSTANT CHAR(2) := '64';
   c_pprinnml         CONSTANT CHAR(2) := '65';
   c_pfeeovd          CONSTANT CHAR(2) := '70';
   c_pt0intnmlovd     CONSTANT CHAR(2) := '71';
   c_pfeeintnmlovd    CONSTANT CHAR(2) := '92';
   c_pintnmlovd       CONSTANT CHAR(2) := '72';
   c_pt0intovdacr     CONSTANT CHAR(2) := '73';
   c_pfeeintovdacr    CONSTANT CHAR(2) := '84';
   c_pintovdacr       CONSTANT CHAR(2) := '74';
   c_pfeedue          CONSTANT CHAR(2) := '75';
   c_pt0intdue        CONSTANT CHAR(2) := '76';
   c_pintdue          CONSTANT CHAR(2) := '77';
   c_pfeeintdue       CONSTANT CHAR(2) := '97';
   c_pfee             CONSTANT CHAR(2) := '78';
   c_pt0intnmlacr     CONSTANT CHAR(2) := '79';
   c_pfeeintnmlacr    CONSTANT CHAR(2) := '90';
   c_pintnmlacr       CONSTANT CHAR(2) := '80';
   c_desc             CONSTANT CHAR(2) := '30';
   c_accrualsamt      CONSTANT CHAR(2) := '85';
   c_notaccrualsamt   CONSTANT CHAR(2) := '86';
FUNCTION fn_txPreAppCheck(p_txmsg in out tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
    l_count number;
    l_ovamt number;
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
         --29/01/2018 DieuNDA: Check chan nhap so am
        if to_number(p_txmsg.txfields('45').value) < 0
            or to_number(p_txmsg.txfields(c_intamt).value) < 0
            or to_number(p_txmsg.txfields(c_payamt).value) <= 0
        then
            p_err_code := '-100810';
            plog.error (pkgctx, p_err_code || ': Lnschdid='||p_txmsg.txfields(c_autoid).value
                                 ||', c_prinamt='||p_txmsg.txfields('45').value
                                 ||', c_intamt='||p_txmsg.txfields(c_intamt).value
                                 ||', c_payamt='||p_txmsg.txfields(c_payamt).value
                       );
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;
        --End 29/01/2018 DieuNDA: Check chan nhap so am

        select (dueamt + ovamt)-p_txmsg.txfields(c_odamt).value into l_ovamt from cimast where acctno = p_txmsg.txfields('05').value;
        if l_ovamt > 0 then
             p_txmsg.txWarningException('-540030').value:= cspks_system.fn_get_errmsg('-540030');
             p_txmsg.txWarningException('-540030').errlev:= '1';
        end if;

        IF NOT fn_getavlbal(p_txmsg.txfields(c_ciacctno).value, to_number(p_txmsg.txfields(c_autoid).value)) >= to_number(p_txmsg.txfields(c_payamt).value) THEN
            p_err_code := '-400101'; -- Pre-defined in DEFERROR table
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;
        for rec_lnschd in
        (
            select * from lnschd where autoid = p_txmsg.txfields(c_autoid).value
        )
        loop
            IF round(to_number(p_txmsg.txfields(c_pt0prinovd).value),0)
                + round(to_number(p_txmsg.txfields(c_pprinovd).value),0) > ceil(rec_lnschd.OVD) THEN
                 p_err_code := '-540003'; -- Pre-defined in DEFERROR table
                 plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
                 RETURN errnums.C_BIZ_RULE_INVALID;
            END IF;
            IF round(to_number(p_txmsg.txfields(c_pt0prinnml).value),0)
                + round(to_number(p_txmsg.txfields(c_pprinnml).value),0)
                + round(to_number(p_txmsg.txfields(c_pprindue).value),0)
                + round(to_number(p_txmsg.txfields(c_pt0prindue).value),0) > ceil(rec_lnschd.NML) THEN
                 p_err_code := '-540002'; -- Pre-defined in DEFERROR table
                 plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
                 RETURN errnums.C_BIZ_RULE_INVALID;
            END IF;
            IF round(to_number(p_txmsg.txfields(c_pfeeovd).value),0) > ceil(rec_lnschd.FEEOVD) THEN
                p_err_code := '-540013'; -- Pre-defined in DEFERROR table
                plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
                RETURN errnums.C_BIZ_RULE_INVALID;
            END IF;
            IF round(to_number(p_txmsg.txfields(c_pfeeovd).value),0) > ceil(rec_lnschd.FEEOVD) THEN
                p_err_code := '-540013'; -- Pre-defined in DEFERROR table
                plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
                RETURN errnums.C_BIZ_RULE_INVALID;
            END IF;
            IF round(to_number(p_txmsg.txfields(c_pfeedue).value),0) > ceil(rec_lnschd.FEEDUE) THEN
                p_err_code := '-540013'; -- Pre-defined in DEFERROR table
                plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
                RETURN errnums.C_BIZ_RULE_INVALID;
            END IF;
            IF round(to_number(p_txmsg.txfields(c_pfee).value),0) > ceil(rec_lnschd.FEE) THEN
                p_err_code := '-540013'; -- Pre-defined in DEFERROR table
                plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
                RETURN errnums.C_BIZ_RULE_INVALID;
            END IF;
            IF round(to_number(p_txmsg.txfields(c_pt0intnmlacr).value),0)
                + round(to_number(p_txmsg.txfields(c_pintnmlacr).value),0) > ceil(rec_lnschd.INTNMLACR) THEN
                p_err_code := '-540006'; -- Pre-defined in DEFERROR table
                plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
                RETURN errnums.C_BIZ_RULE_INVALID;
            END IF;
            IF round(to_number(p_txmsg.txfields(c_pt0intdue).value),0)
                + round(to_number(p_txmsg.txfields(c_pintdue).value),0) > ceil(rec_lnschd.INTDUE) THEN
                p_err_code := '-540006'; -- Pre-defined in DEFERROR table
                plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
                RETURN errnums.C_BIZ_RULE_INVALID;
            END IF;
            IF round(to_number(p_txmsg.txfields(c_pt0intnmlovd).value),0)
                + round(to_number(p_txmsg.txfields(c_pintnmlovd).value),0) > ceil(rec_lnschd.INTOVD) THEN
                p_err_code := '-540006'; -- Pre-defined in DEFERROR table
                plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
                RETURN errnums.C_BIZ_RULE_INVALID;
            END IF;
            IF round(to_number(p_txmsg.txfields(c_pt0intovdacr).value),0)
                + round(to_number(p_txmsg.txfields(c_pintovdacr).value),0) > ceil(rec_lnschd.INTOVDPRIN) THEN
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

            select count(1) into l_count
            from lnmast ln, lnschd ls
            where ln.acctno = ls.acctno
            and ls.autoid = to_number(p_txmsg.txfields(c_autoid).value) and ln.rrtype = 'B'
            and getduedate(ls.rlsdate, ln.lncldr, '000', ln.minterm) > p_txmsg.txdate;

            if l_count > 0 then
                p_txmsg.txWarningException('-5402251').value:= cspks_system.fn_get_errmsg('-540225');
                p_txmsg.txWarningException('-5402251').errlev:= '1';
            end if;

        end loop;
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
    l_PaidAmt number(20,0);
    l_ADVFEE number(20,0);
    l_FTYPE varchar2(2);
    l_AFAcctno varchar2(10);
    l_FeeAmt number(20,0);
    l_SumFee number(20,0);
    l_ADVPAYFEE number(20,0);
    l_Amt number(20,0);
    l_FEEINTNMLACRTERM number(20,0);
    l_T0RETRIEVED number(20,0);
    v_REMAINLNAMT   NUMBER;
    l_err_param varchar2(200);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    IF p_txmsg.deltd = 'N' THEN

        for rec_lnschd in
        (
            select * from lnschd where autoid = p_txmsg.txfields(c_autoid).value
        )
        loop
            UPDATE LNSCHD
                SET OVD = OVD - round(to_number(p_txmsg.txfields(c_pt0prinovd).value),0) - round(to_number(p_txmsg.txfields(c_pprinovd).value),0),
                NML = NML - round(to_number(p_txmsg.txfields(c_pt0prinnml).value),0) - round(to_number(p_txmsg.txfields(c_pprinnml).value),0)
                            - round(to_number(p_txmsg.txfields(c_pprindue).value),0) - round(to_number(p_txmsg.txfields(c_pt0prindue).value),0),
                FEE = FEE - round(to_number(p_txmsg.txfields(c_pfee).value),0),
                FEEOVD = FEEOVD - round(to_number(p_txmsg.txfields(c_pfeeovd).value),0),
                FEEDUE = FEEDUE - round(to_number(p_txmsg.txfields(c_pfeedue).value),0),
                INTNMLACR = INTNMLACR - round(to_number(p_txmsg.txfields(c_pt0intnmlacr).value),0) - round(to_number(p_txmsg.txfields(c_pintnmlacr).value),0),
                INTDUE = INTDUE - round(to_number(p_txmsg.txfields(c_pt0intdue).value),0) - round(to_number(p_txmsg.txfields(c_pintdue).value),0),
                INTOVD = INTOVD - round(to_number(p_txmsg.txfields(c_pt0intnmlovd).value),0) - round(to_number(p_txmsg.txfields(c_pintnmlovd).value),0),
                INTOVDPRIN = INTOVDPRIN - round(to_number(p_txmsg.txfields(c_pt0intovdacr).value),0) - round(to_number(p_txmsg.txfields(c_pintovdacr).value),0),
                FEEINTNMLOVD = FEEINTNMLOVD - round(to_number(p_txmsg.txfields(c_pfeeintnmlovd).value),0),
                FEEINTOVDACR = FEEINTOVDACR - round(to_number(p_txmsg.txfields(c_pfeeintovdacr).value),0),
                FEEINTDUE = FEEINTDUE - round(to_number(p_txmsg.txfields(c_pfeeintdue).value),0),
                FEEINTNMLACR = FEEINTNMLACR - round(to_number(p_txmsg.txfields(c_pfeeintnmlacr).value),0),
                PAID = PAID + round(to_number(p_txmsg.txfields(c_pt0prinovd).value),0) + round(to_number(p_txmsg.txfields(c_pprinovd).value),0)
                                + round(to_number(p_txmsg.txfields(c_pt0prinnml).value),0) + round(to_number(p_txmsg.txfields(c_pprinnml).value),0)
                            + round(to_number(p_txmsg.txfields(c_pprindue).value),0) + round(to_number(p_txmsg.txfields(c_pt0prindue).value),0),
                FEEPAID = FEEPAID + round(to_number(p_txmsg.txfields(c_pfee).value),0) + round(to_number(p_txmsg.txfields(c_pfeeovd).value),0)
                                    + round(to_number(p_txmsg.txfields(c_pfeedue).value),0),
                FEEINTPAID =  FEEINTPAID + round(to_number(p_txmsg.txfields(c_pfeeintnmlovd).value),0) + round(to_number(p_txmsg.txfields(c_pfeeintovdacr).value),0)
                                + round(to_number(p_txmsg.txfields(c_pfeeintdue).value),0) + round(to_number(p_txmsg.txfields(c_pfeeintnmlacr).value),0),
                INTPAID = INTPAID + round(to_number(p_txmsg.txfields(c_pt0intnmlacr).value),0) + round(to_number(p_txmsg.txfields(c_pintnmlacr).value),0)
                            + round(to_number(p_txmsg.txfields(c_pt0intdue).value),0) + round(to_number(p_txmsg.txfields(c_pintdue).value),0)
                            + round(to_number(p_txmsg.txfields(c_pt0intnmlovd).value),0) + round(to_number(p_txmsg.txfields(c_pintnmlovd).value),0)
                            + round(to_number(p_txmsg.txfields(c_pt0intovdacr).value),0) + round(to_number(p_txmsg.txfields(c_pintovdacr).value),0),
               ACCRUALSAMT=ACCRUALSAMT-to_number(p_txmsg.txfields(c_accrualsamt).value),
               PAIDDATE = p_txmsg.txdate
            WHERE AUTOID = rec_lnschd.AUTOID;
            INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, FEE, FEEOVD, FEEDUE, INTNMLACR, INTDUE, INTOVD, INTOVDPRIN,
                        FEEINTOVD, FEEINTOVDPRIN, FEEINTDUE, FEEINTNMLACR,
                        FEEINTPAID, INTPAID,ACCRUALSAMT)
            VALUES(rec_lnschd.AUTOID,
                p_txmsg.txnum,
                TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),
                - round(to_number(p_txmsg.txfields(c_pt0prinnml).value),0) - round(to_number(p_txmsg.txfields(c_pprinnml).value),0)
                            - round(to_number(p_txmsg.txfields(c_pprindue).value),0) - round(to_number(p_txmsg.txfields(c_pt0prindue).value),0),

                - round(to_number(p_txmsg.txfields(c_pt0prinovd).value),0) - round(to_number(p_txmsg.txfields(c_pprinovd).value),0),

                 round(to_number(p_txmsg.txfields(c_pt0prinovd).value),0) + round(to_number(p_txmsg.txfields(c_pprinovd).value),0)
                 + round(to_number(p_txmsg.txfields(c_pt0prinnml).value),0) + round(to_number(p_txmsg.txfields(c_pprinnml).value),0)
                  + round(to_number(p_txmsg.txfields(c_pprindue).value),0) + round(to_number(p_txmsg.txfields(c_pt0prindue).value),0),
                - round(to_number(p_txmsg.txfields(c_pfee).value),0),
                - round(to_number(p_txmsg.txfields(c_pfeeovd).value),0),
                - round(to_number(p_txmsg.txfields(c_pfeedue).value),0),
                - round(to_number(p_txmsg.txfields(c_pt0intnmlacr).value),0) - round(to_number(p_txmsg.txfields(c_pintnmlacr).value),0),
                - round(to_number(p_txmsg.txfields(c_pt0intdue).value),0) - round(to_number(p_txmsg.txfields(c_pintdue).value),0),
                - round(to_number(p_txmsg.txfields(c_pt0intnmlovd).value),0) - round(to_number(p_txmsg.txfields(c_pintnmlovd).value),0),
                - round(to_number(p_txmsg.txfields(c_pt0intovdacr).value),0) - round(to_number(p_txmsg.txfields(c_pintovdacr).value),0),
                - round(to_number(p_txmsg.txfields(c_pfeeintnmlovd).value),0),
                - round(to_number(p_txmsg.txfields(c_pfeeintovdacr).value),0),
                - round(to_number(p_txmsg.txfields(c_pfeeintdue).value),0),
                - round(to_number(p_txmsg.txfields(c_pfeeintnmlacr).value),0),
                round(to_number(p_txmsg.txfields(c_pfeeintnmlovd).value),0) + round(to_number(p_txmsg.txfields(c_pfeeintovdacr).value),0)
                                + round(to_number(p_txmsg.txfields(c_pfeeintdue).value),0) + round(to_number(p_txmsg.txfields(c_pfeeintnmlacr).value),0),
                round(to_number(p_txmsg.txfields(c_pt0intnmlacr).value),0) + round(to_number(p_txmsg.txfields(c_pintnmlacr).value),0)
                            + round(to_number(p_txmsg.txfields(c_pt0intdue).value),0) + round(to_number(p_txmsg.txfields(c_pintdue).value),0)
                            + round(to_number(p_txmsg.txfields(c_pt0intnmlovd).value),0) + round(to_number(p_txmsg.txfields(c_pintnmlovd).value),0)
                            + round(to_number(p_txmsg.txfields(c_pt0intovdacr).value),0) + round(to_number(p_txmsg.txfields(c_pintovdacr).value),0),
                            -1*to_number(p_txmsg.txfields(c_accrualsamt).value));

                --Kiem tra xem co phai lan tra cuoi cung khong
                 SELECT trunc(lns.nml)+trunc(lns.ovd)+trunc(lns.FEE)+trunc(lns.FEEOVD)+trunc(lns.FEEDUE)+trunc(lns.INTNMLACR)
                        +trunc(lns.INTDUE)+trunc(lns.INTOVD)+trunc(lns.INTOVDPRIN)+trunc(lns.FEEINTNMLOVD)
                        +trunc(lns.FEEINTOVDACR)+trunc(lns.FEEINTDUE)+trunc(lns.FEEINTNMLACR)
                 INTO v_REMAINLNAMT
                 FROM lnschd lns
                 WHERE autoid = rec_lnschd.AUTOID;
                 -- Neu la lan tra cuoi cung thi update vao LNSCHDLOG
                 IF v_REMAINLNAMT <1 THEN
                    UPDATE lnschdlog SET
                        LASTPAID = 'Y'
                    WHERE AUTOID = rec_lnschd.AUTOID AND TXNUM = p_txmsg.txnum AND txdate = TO_DATE(p_txmsg.txdate,'DD/MM/RRRR');
                 END IF;

            for rec_fee in
                (SELECT * FROM LNSCHD WHERE REFAUTOID = p_txmsg.txfields(c_autoid).value AND REFTYPE = 'F')
            loop
                UPDATE LNSCHD
                SET OVD = OVD - round(to_number(p_txmsg.txfields(c_pfeeovd).value),0),
                    NML = NML - round(to_number(p_txmsg.txfields(c_pfeedue).value),0) - round(to_number(p_txmsg.txfields(c_pfee).value),0),
                    PAID = PAID + round(to_number(p_txmsg.txfields(c_pfeeovd).value),0)
                            + round(to_number(p_txmsg.txfields(c_pfeedue).value),0) + round(to_number(p_txmsg.txfields(c_pfee).value),0),
                    PAIDDATE=p_txmsg.txdate
                WHERE AUTOID = rec_fee.AUTOID;

                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID)
                VALUES(rec_fee.AUTOID, p_txmsg.txnum, TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),
                - round(to_number(p_txmsg.txfields(c_pfeedue).value),0) - round(to_number(p_txmsg.txfields(c_pfee).value),0),
                - round(to_number(p_txmsg.txfields(c_pfeeovd).value),0),
                round(to_number(p_txmsg.txfields(c_pfeeovd).value),0)+ round(to_number(p_txmsg.txfields(c_pfeedue).value),0)
                    + round(to_number(p_txmsg.txfields(c_pfee).value),0));
            end loop;

            for rec_int in
                (SELECT * FROM LNSCHD WHERE REFAUTOID = p_txmsg.txfields(c_autoid).value AND REFTYPE = 'I')
            loop
                UPDATE LNSCHD
                SET OVD = OVD - round(to_number(p_txmsg.txfields(c_pt0intnmlovd).value),0) - to_number(p_txmsg.txfields(c_pintnmlovd).value),
                NML = NML - round(to_number(p_txmsg.txfields(c_pt0intdue).value),0) - to_number(p_txmsg.txfields(c_pintdue).value),
                PAID = PAID + round(to_number(p_txmsg.txfields(c_pt0intnmlovd).value),0) + to_number(p_txmsg.txfields(c_pintnmlovd).value),
                NMLFEEINT = NMLFEEINT - to_number(p_txmsg.txfields(c_pfeeintdue).value),
                OVDFEEINT = OVDFEEINT - to_number(p_txmsg.txfields(c_pfeeintnmlovd).value),
                PAIDFEEINT = PAIDFEEINT + to_number(p_txmsg.txfields(c_pfeeintdue).value) + to_number(p_txmsg.txfields(c_pfeeintnmlovd).value),
                PAIDDATE=p_txmsg.txdate
                WHERE AUTOID = rec_int.AUTOID;

                INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, NMLFEEINT, OVDFEEINT, PAIDFEEINT)
                VALUES(rec_int.AUTOID, p_txmsg.txnum, TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),
                    - round(to_number(p_txmsg.txfields(c_pt0intdue).value),0) - to_number(p_txmsg.txfields(c_pintdue).value),
                    - round(to_number(p_txmsg.txfields(c_pt0intnmlovd).value),0) - to_number(p_txmsg.txfields(c_pintnmlovd).value),
                    round(to_number(p_txmsg.txfields(c_pt0intnmlovd).value),0) + to_number(p_txmsg.txfields(c_pintnmlovd).value),
                    - to_number(p_txmsg.txfields(c_pfeeintdue).value),
                    - to_number(p_txmsg.txfields(c_pfeeintnmlovd).value),
                    to_number(p_txmsg.txfields(c_pfeeintdue).value) + to_number(p_txmsg.txfields(c_pfeeintnmlovd).value));
            end loop;
        end loop;


        -- Thu hoi T0 da giai ngan theo thu tu uu tien, cap truoc thu hoi truoc
        l_T0RETRIEVED := to_number(p_txmsg.txfields(c_pt0prinovd).value) + to_number(p_txmsg.txfields(c_pt0prinnml).value) + to_number(p_txmsg.txfields(c_pt0prindue).value);

        select trfacctno into l_afacctno from lnmast where acctno = p_txmsg.txfields(c_acctno).value;

        IF l_T0RETRIEVED > 0 THEN
            FOR REC_T0 IN
                (
                    SELECT AUTOID, TLID, TYPEALLOCATE, ALLOCATEDLIMIT - RETRIEVEDLIMIT AMT
                    FROM (select * from T0LIMITSCHD
                            union all
                         select * from T0LIMITSCHDHIST)
                    WHERE ACCTNO = l_afacctno AND ALLOCATEDLIMIT - RETRIEVEDLIMIT > 0
                    ORDER BY AUTOID
                )
            LOOP
                IF l_T0RETRIEVED > 0 THEN
                    IF l_T0RETRIEVED > REC_T0.AMT THEN
                        l_Amt := REC_T0.AMT;
                    ELSE
                        l_Amt := l_T0RETRIEVED;
                    END IF;
                    l_T0RETRIEVED := l_T0RETRIEVED - l_Amt;

                    UPDATE T0LIMITSCHD SET RETRIEVEDLIMIT = RETRIEVEDLIMIT + l_Amt WHERE AUTOID = REC_T0.AUTOID;
                    UPDATE T0LIMITSCHDHIST SET RETRIEVEDLIMIT = RETRIEVEDLIMIT + l_Amt WHERE AUTOID = REC_T0.AUTOID;

                    UPDATE USERAFLIMIT SET ACCLIMIT = ACCLIMIT - l_Amt
                    WHERE ACCTNO = l_afacctno AND TLIDUSER = REC_T0.TLID AND typereceive = 'T0';

                    INSERT INTO USERAFLIMITLOG (TXNUM,TXDATE,ACCTNO,ACCLIMIT,TLIDUSER,TYPEALLOCATE,TYPERECEIVE)
                    VALUES (p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),l_afacctno,-l_Amt,REC_T0.TLID,REC_T0.TYPEALLOCATE,'T0');

                    INSERT INTO RETRIEVEDT0LOG(TXDATE, TXNUM, AUTOID, TLID, RETRIEVEDAMT)
                    VALUES(TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),p_txmsg.txnum, REC_T0.AUTOID, REC_T0.TLID, l_Amt);
                END IF;
            END LOOP;
        END IF;

    else

        for rec_lnschd in
        (
            select * from lnschd where autoid = p_txmsg.txfields(c_autoid).value
        )
        loop
            UPDATE LNSCHD
                SET OVD = OVD + round(to_number(p_txmsg.txfields(c_pt0prinovd).value),0) + round(to_number(p_txmsg.txfields(c_pprinovd).value),0),
                NML = NML + round(to_number(p_txmsg.txfields(c_pt0prinnml).value),0) + round(to_number(p_txmsg.txfields(c_pprinnml).value),0)
                            + round(to_number(p_txmsg.txfields(c_pprindue).value),0) + round(to_number(p_txmsg.txfields(c_pt0prindue).value),0),
                FEE = FEE + round(to_number(p_txmsg.txfields(c_pfee).value),0),
                FEEOVD = FEEOVD + round(to_number(p_txmsg.txfields(c_pfeeovd).value),0),
                FEEDUE = FEEDUE + round(to_number(p_txmsg.txfields(c_pfeedue).value),0),
                INTNMLACR = INTNMLACR + round(to_number(p_txmsg.txfields(c_pt0intnmlacr).value),0) + round(to_number(p_txmsg.txfields(c_pintnmlacr).value),0),
                INTDUE = INTDUE + round(to_number(p_txmsg.txfields(c_pt0intdue).value),0) + round(to_number(p_txmsg.txfields(c_pintdue).value),0),
                INTOVD = INTOVD + round(to_number(p_txmsg.txfields(c_pt0intnmlovd).value),0) + round(to_number(p_txmsg.txfields(c_pintnmlovd).value),0),
                INTOVDPRIN = INTOVDPRIN + round(to_number(p_txmsg.txfields(c_pt0intovdacr).value),0) + round(to_number(p_txmsg.txfields(c_pintovdacr).value),0),
                FEEINTNMLOVD = FEEINTNMLOVD + round(to_number(p_txmsg.txfields(c_pfeeintnmlovd).value),0),
                FEEINTOVDACR = FEEINTOVDACR + round(to_number(p_txmsg.txfields(c_pfeeintovdacr).value),0),
                FEEINTDUE = FEEINTDUE + round(to_number(p_txmsg.txfields(c_pfeeintdue).value),0),
                FEEINTNMLACR = FEEINTNMLACR + round(to_number(p_txmsg.txfields(c_pfeeintnmlacr).value),0),
                PAID = PAID - round(to_number(p_txmsg.txfields(c_pt0prinovd).value),0) - round(to_number(p_txmsg.txfields(c_pprinovd).value),0)
                                - round(to_number(p_txmsg.txfields(c_pt0prinnml).value),0) - round(to_number(p_txmsg.txfields(c_pprinnml).value),0)
                            - round(to_number(p_txmsg.txfields(c_pprindue).value),0) - round(to_number(p_txmsg.txfields(c_pt0prindue).value),0),
                FEEPAID = FEEPAID - round(to_number(p_txmsg.txfields(c_pfee).value),0) - round(to_number(p_txmsg.txfields(c_pfeeovd).value),0)
                                    - round(to_number(p_txmsg.txfields(c_pfeedue).value),0),
                FEEINTPAID =  FEEINTPAID - round(to_number(p_txmsg.txfields(c_pfeeintnmlovd).value),0) - round(to_number(p_txmsg.txfields(c_pfeeintovdacr).value),0)
                                - round(to_number(p_txmsg.txfields(c_pfeeintdue).value),0) - round(to_number(p_txmsg.txfields(c_pfeeintnmlacr).value),0),
                INTPAID = INTPAID - round(to_number(p_txmsg.txfields(c_pt0intnmlacr).value),0) - round(to_number(p_txmsg.txfields(c_pintnmlacr).value),0)
                            - round(to_number(p_txmsg.txfields(c_pt0intdue).value),0) - round(to_number(p_txmsg.txfields(c_pintdue).value),0)
                            - round(to_number(p_txmsg.txfields(c_pt0intnmlovd).value),0) - round(to_number(p_txmsg.txfields(c_pintnmlovd).value),0)
                            - round(to_number(p_txmsg.txfields(c_pt0intovdacr).value),0) - round(to_number(p_txmsg.txfields(c_pintovdacr).value),0),
               ACCRUALSAMT=ACCRUALSAMT+to_number(p_txmsg.txfields(c_accrualsamt).value),
               PAIDDATE = p_txmsg.txdate
            WHERE AUTOID = rec_lnschd.AUTOID;

            update LNSCHDLOG set deltd ='Y' where txnum = p_txmsg.txnum and txdate = TO_DATE(p_txmsg.txdate,'DD/MM/RRRR') and autoid =rec_lnschd.AUTOID;


            for rec_fee in
                (SELECT * FROM LNSCHD WHERE REFAUTOID = p_txmsg.txfields(c_autoid).value AND REFTYPE = 'F')
            loop
                UPDATE LNSCHD
                SET OVD = OVD + round(to_number(p_txmsg.txfields(c_pfeeovd).value),0),
                    NML = NML + round(to_number(p_txmsg.txfields(c_pfeedue).value),0) + round(to_number(p_txmsg.txfields(c_pfee).value),0),
                    PAID = PAID - round(to_number(p_txmsg.txfields(c_pfeeovd).value),0)
                            - round(to_number(p_txmsg.txfields(c_pfeedue).value),0) - round(to_number(p_txmsg.txfields(c_pfee).value),0),
                    PAIDDATE=p_txmsg.txdate
                WHERE AUTOID = rec_fee.AUTOID;

                update LNSCHDLOG set deltd ='Y' where txnum = p_txmsg.txnum and txdate = TO_DATE(p_txmsg.txdate,'DD/MM/RRRR') and autoid =rec_fee.AUTOID;

            end loop;

            for rec_int in
                (SELECT * FROM LNSCHD WHERE REFAUTOID = p_txmsg.txfields(c_autoid).value AND REFTYPE = 'I')
            loop
                UPDATE LNSCHD
                SET OVD = OVD + round(to_number(p_txmsg.txfields(c_pt0intnmlovd).value),0) + to_number(p_txmsg.txfields(c_pintnmlovd).value),
                NML = NML + round(to_number(p_txmsg.txfields(c_pt0intdue).value),0) + to_number(p_txmsg.txfields(c_pintdue).value),
                PAID = PAID - round(to_number(p_txmsg.txfields(c_pt0intnmlovd).value),0) - to_number(p_txmsg.txfields(c_pintnmlovd).value),
                NMLFEEINT = NMLFEEINT + to_number(p_txmsg.txfields(c_pfeeintdue).value),
                OVDFEEINT = OVDFEEINT + to_number(p_txmsg.txfields(c_pfeeintnmlovd).value),
                PAIDFEEINT = PAIDFEEINT - to_number(p_txmsg.txfields(c_pfeeintdue).value) - to_number(p_txmsg.txfields(c_pfeeintnmlovd).value),
                PAIDDATE=p_txmsg.txdate
                WHERE AUTOID = rec_int.AUTOID;

                update LNSCHDLOG set deltd ='Y' where txnum = p_txmsg.txnum and txdate = TO_DATE(p_txmsg.txdate,'DD/MM/RRRR') and autoid =rec_int.AUTOID;

            end loop;
        end loop;


        -- Thu hoi T0 da giai ngan theo thu tu uu tien, cap truoc thu hoi truoc
        l_T0RETRIEVED := to_number(p_txmsg.txfields(c_pt0prinovd).value) + to_number(p_txmsg.txfields(c_pt0prinnml).value) + to_number(p_txmsg.txfields(c_pt0prindue).value);

        select trfacctno into l_afacctno from lnmast where acctno = p_txmsg.txfields(c_acctno).value;

        IF l_T0RETRIEVED > 0 THEN
            FOR REC_T0 IN
                (
                    SELECT AUTOID, TLID, TYPEALLOCATE, RETRIEVEDLIMIT AMT --ALLOCATEDLIMIT - RETRIEVEDLIMIT AMT
                    FROM (select * from T0LIMITSCHD
                            union all
                         select * from T0LIMITSCHDHIST)
                    WHERE ACCTNO = l_afacctno AND RETRIEVEDLIMIT> 0 --ALLOCATEDLIMIT - RETRIEVEDLIMIT > 0
                    ORDER BY AUTOID DESC
                )
            LOOP
                IF l_T0RETRIEVED > 0 THEN
                    IF l_T0RETRIEVED > REC_T0.AMT THEN
                        l_Amt := REC_T0.AMT;
                    ELSE
                        l_Amt := l_T0RETRIEVED;
                    END IF;
                    l_T0RETRIEVED := l_T0RETRIEVED - l_Amt;

                    UPDATE T0LIMITSCHD SET RETRIEVEDLIMIT = RETRIEVEDLIMIT - l_Amt WHERE AUTOID = REC_T0.AUTOID;
                    UPDATE T0LIMITSCHDHIST SET RETRIEVEDLIMIT = RETRIEVEDLIMIT - l_Amt WHERE AUTOID = REC_T0.AUTOID;

                    UPDATE USERAFLIMIT SET ACCLIMIT = ACCLIMIT + l_Amt
                    WHERE ACCTNO = l_afacctno AND TLIDUSER = REC_T0.TLID AND typereceive = 'T0';

                    delete from USERAFLIMITLOG where TXNUM = p_txmsg.txnum and txdate = TO_DATE(p_txmsg.txdate,'DD/MM/RRRR') and ACCTNO = l_afacctno;
                    delete from RETRIEVEDT0LOG where TXNUM = p_txmsg.txnum and txdate = TO_DATE(p_txmsg.txdate,'DD/MM/RRRR') and AUTOID =  REC_T0.AUTOID;
                END IF;
            END LOOP;
        END IF;
    end if;
    IF p_txmsg.deltd = 'N' THEN
        cspks_rmproc.pr_rmSUBBAMTTRFByAccount(p_txmsg.txfields('05').value,p_txmsg.txnum,'DAY', p_err_code);
    else
        --Xoa giao dich cat tien tu tai khoan Phu sang TK chinh
        for rec in
        (
            select * from tllog where reftxnum =p_txmsg.txnum
        )
        loop
            if txpks_#6668.fn_txrevert(rec.txnum,to_char(rec.txdate,'dd/mm/rrrr'),p_err_code,l_err_param) <> 0 then
                plog.error (pkgctx, 'Loi khi thuc hien xoa giao dich');
                plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
                return errnums.C_SYSTEM_ERROR;
            end if;
        end loop;
    end if;
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
         plog.init ('TXPKS_#5540EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#5540EX;
/
