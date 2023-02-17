SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#0025ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#0025EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      28/07/2014     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#0025ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_custodycd        CONSTANT CHAR(2) := '82';
   c_custname         CONSTANT CHAR(2) := '90';
   c_address          CONSTANT CHAR(2) := '91';
   c_license          CONSTANT CHAR(2) := '92';
   c_idplace          CONSTANT CHAR(2) := '94';
   c_iddate           CONSTANT CHAR(2) := '93';
   c_status           CONSTANT CHAR(2) := '25';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
v_mrcount number;
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
     -- Check trang thai tieu khoan.
    for rec in
    (
        select af.acctno, af.status, cf.status cfstatus, ci.odamt, ci.ODINTACR, ci.depofeeamt, ci.cidepofeeacr, nvl(curloan,0) curloan
        from afmast af, cfmast cf, cimast ci, (SELECT afacctno, sum(CURAMT+intamt) curloan FROM v_getgrpdealinfo group by afacctno) df
        where af.custid = cf.custid and af.acctno = ci.acctno and af.acctno = df.afacctno(+)
        and cf.custodycd = p_txmsg.txfields('82').value

    )
    loop
        if rec.status <> 'A' or rec.cfstatus <> 'A' then
            p_err_code := '-200010'; -- Pre-defined in DEFERROR table
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;

        --Kiem tra neu tai khoan la margin co ky han thi neu ODINT + ODAMT > 0 thi khong cho lam.
        --Bat phai tra no het theo ky han thi moi duoc lam
        if(rec.odamt +rec.ODINTACR)>0 then
            Begin
                SELECT count(1) INTO v_mrcount FROM AFMAST AF, AFTYPE AT, MRTYPE MT
                where AF.ACCTNO=rec.acctno
                AND AF.ACTYPE =AT.ACTYPE AND AT.MRTYPE = MT.ACTYPE AND MT.MRTYPE ='T';
            EXCEPTION
                WHEN OTHERS   THEN
                v_mrcount :=0;
            END;

            if v_mrcount>0 then
                p_err_code := '-200070'; -- Pre-defined in DEFERROR table
                plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
                RETURN errnums.C_BIZ_RULE_INVALID;
            end if;
        end if;

        -- Neu con no DF thi ko cho lam
        if rec.curloan > 0 then
            p_err_code := '-200070'; -- Pre-defined in DEFERROR table
                plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
                RETURN errnums.C_BIZ_RULE_INVALID;
        end if;


        --HaiLT them
      /*  -- Tien luu ky con thi ko cho chuyen
        if rec.depofeeamt + rec.cidepofeeacr >0 then
            p_err_code := '-100430';
            plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;*/

        -- End of HaiLT them

    end loop;

    -- Con` thanh toan' thi ko cho lam
    select count(*) into v_mrcount from stschd sts, afmast af, cfmast cf
    where sts.afacctno = af.acctno and af.custid = cf.custid and cf.custodycd = p_txmsg.txfields('82').value;
    if v_mrcount>0 then
        p_err_code := '-700005';
        plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
        RETURN errnums.C_BIZ_RULE_INVALID;
    end if;

    -- Con lenh. dat. trong ngay` thi ko cho chuyen
    select count(*) into v_mrcount from ODMAST sts, afmast af, cfmast cf
    where sts.afacctno = af.acctno and af.custid = cf.custid and cf.custodycd = p_txmsg.txfields('82').value;
    if v_mrcount>0 then
        p_err_code := '-700005';
        plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
        RETURN errnums.C_BIZ_RULE_INVALID;
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
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
      if p_txmsg.deltd ='N' then

  for rec in (
        select cf.custodycd, cf.custid, af.acctno from afmast af, cfmast cf where af.custid = cf.custid and cf.custodycd =  p_txmsg.txfields('82').value
            and af.status ='A'
    )
    loop

    UPDATE AFMAST
         SET
           PSTATUS=PSTATUS||STATUS,STATUS='G',
           LASTDATE = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT), LAST_CHANGE = SYSTIMESTAMP
        WHERE ACCTNO=rec.acctno;

     UPDATE CIMAST
         SET
            PSTATUS=PSTATUS||STATUS,STATUS='G',
            LASTDATE = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),
            LAST_CHANGE = SYSTIMESTAMP
        WHERE ACCTNO=rec.acctno;

    end loop;

    ELSE

      for rec in (
        select cf.custodycd, cf.custid, af.acctno from afmast af, cfmast cf where af.custid = cf.custid and cf.custodycd =  p_txmsg.txfields('82').value
            and af.status ='G'
    )
    loop

    UPDATE AFMAST
         SET
           PSTATUS=PSTATUS||STATUS,STATUS='A',
           LASTDATE = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT), LAST_CHANGE = SYSTIMESTAMP
        WHERE ACCTNO=rec.acctno;

     UPDATE CIMAST
         SET
            PSTATUS=PSTATUS||STATUS,STATUS='A',
            LASTDATE = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT),
            LAST_CHANGE = SYSTIMESTAMP
        WHERE ACCTNO=rec.acctno;

    end loop;


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
         plog.init ('TXPKS_#0025EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#0025EX;
/
