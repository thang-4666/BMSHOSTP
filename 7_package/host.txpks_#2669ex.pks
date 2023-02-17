SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#2669ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#2669EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      14/08/2013     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#2669ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_autoid           CONSTANT CHAR(2) := '01';
   c_acctno           CONSTANT CHAR(2) := '03';
   c_afacctno         CONSTANT CHAR(2) := '04';
   c_custodycd        CONSTANT CHAR(2) := '88';
   c_fullname         CONSTANT CHAR(2) := '90';
   c_productname      CONSTANT CHAR(2) := '13';
   c_address          CONSTANT CHAR(2) := '91';
   c_license          CONSTANT CHAR(2) := '92';
   c_todate           CONSTANT CHAR(2) := '05';
   c_overduedate      CONSTANT CHAR(2) := '06';
   c_amt              CONSTANT CHAR(2) := '10';
   c_intamt           CONSTANT CHAR(2) := '20';
   c_paidint          CONSTANT CHAR(2) := '31';
   c_feeamt           CONSTANT CHAR(2) := '21';
   c_paidfee          CONSTANT CHAR(2) := '32';
   c_paidamt          CONSTANT CHAR(2) := '33';
   c_orate1           CONSTANT CHAR(2) := '41';
   c_rate1            CONSTANT CHAR(2) := '51';
   c_orate2           CONSTANT CHAR(2) := '42';
   c_rate2            CONSTANT CHAR(2) := '52';
   c_orate3           CONSTANT CHAR(2) := '43';
   c_rate3            CONSTANT CHAR(2) := '53';
   c_ocfrate1         CONSTANT CHAR(2) := '44';
   c_cfrate1          CONSTANT CHAR(2) := '54';
   c_ocfrate2         CONSTANT CHAR(2) := '45';
   c_cfrate2          CONSTANT CHAR(2) := '55';
   c_ocfrate3         CONSTANT CHAR(2) := '46';
   c_cfrate3          CONSTANT CHAR(2) := '56';
   c_oautoapply       CONSTANT CHAR(2) := '60';
   c_autoapply        CONSTANT CHAR(2) := '61';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
V_TODATE date;
V_OVERDUEDATE date;
V_CURRDATE  DATE ;
l_count  number;

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
    SELECT TO_DATE(VARVALUE,'DD/MM/YYYY') INTO V_CURRDATE  FROM SYSVAR WHERE VARNAME ='CURRDATE' ;
    V_TODATE := TO_DATE( p_txmsg.txfields(c_todate).VALUE,'DD/MM/RRRR');
    V_OVERDUEDATE := TO_DATE(p_txmsg.txfields(c_overduedate).VALUE,'DD/MM/RRRR');

    IF not V_CURRDATE <= V_OVERDUEDATE  THEN
        p_err_code:= '-540236';
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;

    IF V_TODATE <= V_OVERDUEDATE  THEN
        p_err_code:= '-540214'    ;
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;
    IF V_TODATE <= V_CURRDATE  THEN
        p_err_code:= '-540218';
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;

    --Check ngay den han ko be hon hay bang ngay den han cu
    IF TO_DATE(p_txmsg.txfields(c_overduedate).VALUE, 'DD/MM/RRRR') >= TO_DATE(p_txmsg.txfields(c_todate).VALUE, 'DD/MM/RRRR')  THEN
        p_err_code := '-540219';
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;

    --Check isWorkingDay
    select COUNT(sbcldr.holiday) into l_count from sbcldr where sbdate =  TO_DATE( p_txmsg.txfields(c_todate).VALUE ,'DD/MM/RRRR' )and  sbcldr.holiday  = 'Y';
    IF l_count > 0 THEN
        p_err_code := '-540212';
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
v_strAFACCTNO varchar2(20);
v_strACCTNO varchar2(20);
v_nAMT number;
v_txnum varchar2(20);
V_txdate date;
V_TODATE date;
V_OVERDUEDATE date;
V_CURRDATE  DATE ;
V_AUTOID VARCHAR2(300);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    SELECT TO_DATE(VARVALUE,'DD/MM/RRRR') INTO V_CURRDATE  FROM SYSVAR WHERE VARNAME ='CURRDATE' ;
    V_AUTOID := p_txmsg.txfields('01').VALUE;
    v_strAFACCTNO := p_txmsg.txfields('04').VALUE;
    v_strACCTNO := p_txmsg.txfields('03').VALUE;
    v_nAMT := p_txmsg.txfields('10').VALUE;
    V_TODATE := TO_DATE( p_txmsg.txfields('05').VALUE,'DD/MM/YYYY');
    V_OVERDUEDATE := TO_DATE(p_txmsg.txfields('06').VALUE,'DD/MM/YYYY');
    v_txnum:= p_txmsg.txnum;
    V_txdate:= p_txmsg.txdate;

    for rec in
    (
        select * from lnschd where autoid = V_AUTOID
    )
    loop
        if rec.overduedate = V_txdate then
            --DEN HAN --> Chuyen thanh trong han.
            UPDATE LNSCHD
                    SET
                    INTNMLACR = INTNMLACR + INTDUE,
                    INTDUE = 0,
                    FEEINTNMLACR = FEEINTNMLACR + FEEINTDUE,
                    FEEINTDUE = 0
                WHERE AUTOID = V_AUTOID;
            INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, INTDUE, INTNMLACR, FEEINTDUE, FEEINTNMLACR)
                VALUES(V_AUTOID,
                    p_txmsg.txnum,
                    TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),
                    - rec.intdue,
                    rec.intdue,
                    - rec.feeintdue,
                    rec.feeintdue);
            update lnmast
            set INTNMLACR = INTNMLACR + INTDUE,
                    INTDUE = 0,
                    FEEINTNMLACR = FEEINTNMLACR + FEEINTDUE,
                    FEEINTDUE = 0
            where acctno = v_strACCTNO;

            delete lnschdlog where autoid = (select autoid from lnschd where refautoid = V_AUTOID);
            delete lnschdloghist where autoid = (select autoid from lnschd where refautoid = V_AUTOID);
            delete lnschd where refautoid = V_AUTOID and reftype in ('I','GI');
        end if;

/*        --Neu tra phi, tra lai > phi, lai hien tai. Ghi cap nhat tang trong lnschd va LNSCHDLOG
        if greatest(round(to_number(p_txmsg.txfields(c_paidint).value),0) - (rec.intnmlacr+rec.intdue),0) +
                greatest(round(to_number(p_txmsg.txfields(c_paidfee).value),0) - (rec.feeintnmlacr+rec.feeintdue),0) > 0 then
            UPDATE LNSCHD
                    SET
                    INTNMLACR = INTNMLACR - greatest(round(to_number(p_txmsg.txfields(c_paidint).value),0) - (rec.intnmlacr+rec.intdue),0),
                    intpaid = intpaid + greatest(round(to_number(p_txmsg.txfields(c_paidint).value),0) - (rec.intnmlacr+rec.intdue),0),
                    FEEINTNMLACR = FEEINTNMLACR - greatest(round(to_number(p_txmsg.txfields(c_paidfee).value),0) - (rec.feeintnmlacr+rec.feeintdue),0),
                    feeintpaid = feeintpaid + greatest(round(to_number(p_txmsg.txfields(c_paidfee).value),0) - (rec.feeintnmlacr+rec.feeintdue),0)
                WHERE AUTOID = V_AUTOID;
            INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, INTNMLACR, INTPAID, FEEINTNMLACR, FEEINTPAID)
                VALUES(V_AUTOID,
                    p_txmsg.txnum,
                    TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),
                    - greatest(round(to_number(p_txmsg.txfields(c_paidint).value),0) - (rec.intnmlacr+rec.intdue),0),
                    greatest(round(to_number(p_txmsg.txfields(c_paidint).value),0) - (rec.intnmlacr+rec.intdue),0),
                    - greatest(round(to_number(p_txmsg.txfields(c_paidfee).value),0) - (rec.feeintnmlacr+rec.feeintdue),0),
                    greatest(round(to_number(p_txmsg.txfields(c_paidfee).value),0) - (rec.feeintnmlacr+rec.feeintdue),0));
        end if;*/

        --TRONG HAN
        -- Tra no.
        /*UPDATE LNSCHD
                SET
                INTNMLACR = INTNMLACR - round(to_number(p_txmsg.txfields(c_paidint).value),0),
                intpaid = intpaid + round(to_number(p_txmsg.txfields(c_paidint).value),0),
                FEEINTNMLACR = FEEINTNMLACR - round(to_number(p_txmsg.txfields(c_paidfee).value),0),
                feeintpaid = feeintpaid + round(to_number(p_txmsg.txfields(c_paidfee).value),0)
            WHERE AUTOID = V_AUTOID;
        INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, INTNMLACR, INTPAID, FEEINTNMLACR, FEEINTPAID)
            VALUES(V_AUTOID,
                p_txmsg.txnum,
                TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),
                - round(to_number(p_txmsg.txfields(c_paidint).value),0),
                round(to_number(p_txmsg.txfields(c_paidint).value),0),
                - round(to_number(p_txmsg.txfields(c_paidfee).value),0),
                round(to_number(p_txmsg.txfields(c_paidfee).value),0));


        insert into lnschdextlog (txnum, txdate, lnschdid, orgoverduedate, froverduedate,
          tooverduedate, nml, intnmlacr, feeintnmlacr, deltd)
        select p_txmsg.txnum, TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'), autoid, nvl(log.orgoverduedate,overduedate),V_OVERDUEDATE,
           V_TODATE, nml, intnmlacr, feeintnmlacr, 'N'
        from lnschd, (select lnschdid, max(orgoverduedate) orgoverduedate from lnschdextlog where lnschdid = V_AUTOID group by lnschdid) log
        where lnschd.autoid =  log.lnschdid(+) and autoid = V_AUTOID;*/

        UPDATE lnschd SET overduedate = V_TODATE, extimes = extimes + 1   -- Tang them 1 lan gia han
                WHERE AUTOID = V_AUTOID;
    end loop;

    UPDATE lnmast
    set autoapply = p_txmsg.txfields('61').VALUE,
        rate1 = to_number(p_txmsg.txfields('41').VALUE),
        rate2 = to_number(p_txmsg.txfields('42').VALUE),
        rate3 = to_number(p_txmsg.txfields('43').VALUE),
        cfrate1 = to_number(p_txmsg.txfields('44').VALUE),
        cfrate2 = to_number(p_txmsg.txfields('45').VALUE),
        cfrate3 = to_number(p_txmsg.txfields('46').VALUE)
    where acctno  = v_strACCTNO;

    UPDATE lnschd
    set rate1 = to_number(p_txmsg.txfields('41').VALUE),
        rate2 = to_number(p_txmsg.txfields('42').VALUE),
        rate3 = to_number(p_txmsg.txfields('43').VALUE),
        cfrate1 = to_number(p_txmsg.txfields('44').VALUE),
        cfrate2 = to_number(p_txmsg.txfields('45').VALUE),
        cfrate3 = to_number(p_txmsg.txfields('46').VALUE)
    where autoid  = V_AUTOID;

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
         plog.init ('TXPKS_#2669EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#2669EX;

/
