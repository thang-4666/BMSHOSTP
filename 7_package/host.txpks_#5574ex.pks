SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#5574ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#5574EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      02/11/2011     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#5574ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_autoid           CONSTANT CHAR(2) := '01';
   c_afacctno         CONSTANT CHAR(2) := '04';
   c_acctno           CONSTANT CHAR(2) := '03';
   c_custodycd        CONSTANT CHAR(2) := '02';
   c_custname         CONSTANT CHAR(2) := '14';
   c_overduedate      CONSTANT CHAR(2) := '90';
   c_todate           CONSTANT CHAR(2) := '05';
   c_productname      CONSTANT CHAR(2) := '13';
   c_desc             CONSTANT CHAR(2) := '30';
   c_rlsdate          CONSTANT CHAR(2) := '91';
   c_prinperiod       CONSTANT CHAR(2) := '92';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS

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
    l_strTmpDate  Varchar2(20);
    l_count NUMBER(4);
    l_MarginAllow Char(1);
    l_MaxDebtDays NUMBER(4);
    l_MaxTotalDebtDays NUMBER(4);
    L_EXTIMES NUMBER;
    L_EXDAYS  NUMBER;
    L_ALLOW_EXTIMES NUMBER;
    L_ALLOW_MAXEXDAYS NUMBER;
    L_MRIRATE       NUMBER;
    L_NML           NUMBER;
    L_BALDEFOVD     NUMBER;
    L_INTDUE        NUMBER;
    L_FEEDUE        NUMBER;
    L_INTNMLACR        NUMBER;
    L_FEE       NUMBER;
    L_OVERDUEDATE date;
    L_AVLBAL     NUMBER ;
    l_cimastcheck_arr txpks_check.cimastcheck_arrtype;
    l_mrwrate   NUMBER ;
    l_mrerate   NUMBER ;
    L_PRINPERIOD NUMBER;
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

    IF not p_txmsg.txdate <= TO_DATE(p_txmsg.txfields(c_overduedate).VALUE, 'DD/MM/RRRR')  THEN
        p_err_code:= '-540236';
        plog.setendsection (pkgctx, 'fn_txAftAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;

    --Check ngay gia han khong duoc be hon ngay hien tai
    IF p_txmsg.txdate >= TO_DATE(p_txmsg.txfields(c_todate).VALUE, 'DD/MM/RRRR')  THEN
        p_err_code := '-540214';
        plog.setendsection (pkgctx, 'fn_txAftAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;

    --Check ngay den han ko be hon hay bang ngay den han cu
    IF TO_DATE(p_txmsg.txfields(c_overduedate).VALUE, 'DD/MM/RRRR') >= TO_DATE(p_txmsg.txfields(c_todate).VALUE, 'DD/MM/RRRR')  THEN
        p_err_code := '-540219';
        plog.setendsection (pkgctx, 'fn_txAftAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;

    --Check isWorkingDay
    select COUNT(sbcldr.holiday) into l_count from sbcldr where sbdate =  TO_DATE( p_txmsg.txfields(c_todate).VALUE ,'DD/MM/RRRR' )and  sbcldr.holiday  = 'Y';
    IF l_count > 0 THEN
        p_err_code := '-540212';
        plog.setendsection (pkgctx, 'fn_txAftAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;

    --If LNACCTNO is CHKSYSCTRL = Y then
    select count(1) into l_count from lnmast ln, lntype lnt where ln.actype = lnt.actype and ln.acctno = p_txmsg.txfields(c_acctno).VALUE and chksysctrl = 'Y';
    if l_count > 0 then
        --Check Margin Allow
        SELECT SYS.VARVALUE INTO l_MarginAllow FROM SYSVAR SYS WHERE GRNAME = 'MARGIN'  AND VARNAME = 'MARGINALLOW';
        IF l_MarginAllow <> 'Y' THEN
                p_err_code := '-200099';
                plog.setendsection (pkgctx, 'fn_txAftAppCheck');
                RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;

        SELECT to_number(VARVALUE) INTO l_MaxDebtDays FROM SYSVAR WHERE GRNAME = 'MARGIN' AND VARNAME = 'MAXDEBTDAYS' ;
        SELECT to_number(VARVALUE) INTO l_MaxTotalDebtDays FROM SYSVAR WHERE GRNAME = 'MARGIN' AND VARNAME = 'MAXTOTALDEBTDAYS';

        --Check MaxDebtDays
        IF to_number(TO_DATE(p_txmsg.txfields(c_todate).VALUE  ,'DD/MM/RRRR') - TO_DATE( p_txmsg.txfields(c_overduedate).VALUE ,'DD/MM/RRRR')) > l_MaxDebtDays THEN
            p_err_code := '-540217';
            plog.error(pkgctx,'5574: p_err_code='||p_err_code
                                || ', AUTOID='||p_txmsg.txfields('01').VALUE
                                || ', c_overduedate='||p_txmsg.txfields(c_overduedate).VALUE
                                || ', c_todate='||p_txmsg.txfields(c_todate).VALUE
                                || ', l_MaxDebtDays='||l_MaxDebtDays
            );
            plog.setendsection (pkgctx, 'fn_txAftAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;

        --Check MaxTotalDebtDays
        --select count(*) DAYS INTO l_MaxTotalDebtDays from sbcldr where sbdate BETWEEN TO_DATE(p_txmsg.txfields(c_rlsdate).VALUE ,'DD/MM/RRRR') and TO_DATE(p_txmsg.txfields(c_todate).VALUE ,'DD/MM/RRRR') and cldrtype = '000';
        IF to_number(TO_DATE(p_txmsg.txfields(c_todate).VALUE ,'DD/MM/RRRR') - TO_DATE(p_txmsg.txfields(c_rlsdate).VALUE ,'DD/MM/RRRR')) > l_MaxTotalDebtDays THEN
            p_err_code := '-540218';
            plog.error(pkgctx,'5574: p_err_code='||p_err_code
                                || ', AUTOID='||p_txmsg.txfields('01').VALUE
                                || ', c_rlsdate='||p_txmsg.txfields(c_rlsdate).VALUE
                                || ', c_todate='||p_txmsg.txfields(c_todate).VALUE
                                || ', l_MaxTotalDebtDays='||l_MaxTotalDebtDays
            );
            plog.setendsection (pkgctx, 'fn_txAftAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;
    end if;

    --Check ngay gia han moi phai lon hon ngay het han cua deal
    IF TO_DATE( p_txmsg.txfields(c_todate).VALUE,'DD/MM/RRRR') - TO_DATE(p_txmsg.txfields(c_overduedate).VALUE  ,'DD/MM/RRRR') <= 0 THEN
        p_err_code := '-540219';
        plog.error(pkgctx,'5574: p_err_code='||p_err_code
                                || ', AUTOID='||p_txmsg.txfields('01').VALUE
                                || ', c_overduedate='||p_txmsg.txfields(c_overduedate).VALUE
                                || ', c_todate='||p_txmsg.txfields(c_todate).VALUE
            );
        plog.setendsection (pkgctx, 'fn_txAftAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;

    --PhuongHT add
   SELECT EXTIMES,NML,EXDAYS,INTDUE,FEEDUE,INTNMLACR,FEE,OVERDUEDATE INTO L_EXTIMES,L_NML,L_EXDAYS,L_INTDUE,L_FEEDUE,L_INTNMLACR,L_FEE,L_OVERDUEDATE FROM LNSCHD WHERE AUTOID=p_txmsg.txfields('01').VALUE;
   SELECT EXTIMES,MAXEXDAYS, PRINPERIOD INTO L_ALLOW_EXTIMES,L_ALLOW_MAXEXDAYS, L_PRINPERIOD FROM LNTYPE WHERE ACTYPE=p_txmsg.txfields('13').VALUE;

      plog.error (pkgctx, 'NamTv: ' || to_char(TO_DATE(p_txmsg.txfields(c_todate).VALUE, 'DD/MM/RRRR')) || ':' || to_char(L_EXDAYS)  || ':' || to_char(L_ALLOW_MAXEXDAYS) || ':' || to_char(getcurrdate)) ;
   --Check ngay den han ko be hon hay bang ngay den han cu
    IF L_OVERDUEDATE >= TO_DATE(p_txmsg.txfields(c_todate).VALUE, 'DD/MM/RRRR')  THEN
        p_err_code := '-540219';
        plog.error(pkgctx,'5574: p_err_code='||p_err_code
                                || ', AUTOID='||p_txmsg.txfields('01').VALUE
                                || ', L_OVERDUEDATE='||L_OVERDUEDATE
                                || ', c_todate='||p_txmsg.txfields(c_todate).VALUE
            );
        plog.setendsection (pkgctx, 'fn_txAftAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;

   IF L_EXTIMES>=L_ALLOW_EXTIMES THEN
        p_err_code := '-540237';
        plog.setendsection (pkgctx, 'fn_txAftAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
   END IF;

   IF L_EXDAYS + to_number(get_t_date(TO_DATE(p_txmsg.txfields(c_todate).VALUE  ,'DD/MM/RRRR'),1) - getcurrdate) >= L_ALLOW_MAXEXDAYS THEN
        p_err_code := '-540239';
        plog.error(pkgctx,'5574: p_err_code='||p_err_code
                                || ', AUTOID='||p_txmsg.txfields('01').VALUE
                                || ', L_EXDAYS='||L_EXDAYS
                                || ', c_todate='||p_txmsg.txfields(c_todate).VALUE
                                || ', L_ALLOW_MAXEXDAYS='||L_ALLOW_MAXEXDAYS
            );
        plog.setendsection (pkgctx, 'fn_txAftAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
   END IF;

   IF to_number(get_t_date(TO_DATE(p_txmsg.txfields(c_todate).VALUE  ,'DD/MM/RRRR'),1) - getcurrdate) >= L_PRINPERIOD THEN
        p_err_code := '-540239';
        plog.error(pkgctx,'5574: p_err_code='||p_err_code
                                || ', AUTOID='||p_txmsg.txfields('01').VALUE
                                || ', L_PRINPERIOD='||L_PRINPERIOD
                                || ', c_todate='||p_txmsg.txfields(c_todate).VALUE
            );
        plog.setendsection (pkgctx, 'fn_txAftAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
   END IF;

/*
   SELECT mrwrate INTO l_mrwrate FROM AFMAST WHERE ACCTNO=p_txmsg.txfields('04').VALUE;
   IF TO_NUMBER(P_TXMSG.TXFIELDS('22').VALUE) < l_mrwrate THEN
        p_err_code := '-540238';
        plog.setendsection (pkgctx, 'fn_txAftAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
   END IF;*/
   --CHECKK TY LE RA HAN > MRTYPE.MRERATE

      SELECT mrt.mrerate INTO l_mrerate FROM AFMAST af, aftype aft, mrtype mrt WHERE af.actype = aft.actype AND aft.mrtype = mrt.actype AND  ACCTNO=p_txmsg.txfields('04').VALUE;
   IF TO_NUMBER(P_TXMSG.TXFIELDS('22').VALUE) < l_mrerate THEN
        p_err_code := '-540240';
        plog.setendsection (pkgctx, 'fn_txAftAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
   END IF;

     --l_BALDEFOVD := getbaldefovd_released_depofee(p_txmsg.txfields('04').value);
   --  select balance into l_BALDEFOVD from cimast where  acctno = p_txmsg.txfields('04').VALUE;
     -- neu gia han vao ngay den han : can cong phan den han vap baldefovd
     /*IF p_txmsg.txdate = TO_DATE(p_txmsg.txfields(c_overduedate).VALUE, 'DD/MM/RRRR')THEN
        l_BALDEFOVD:=l_BALDEFOVD+L_NML+L_INTDUE+L_FEEDUE;
     END IF;

      l_BALDEFOVD:=l_BALDEFOVD + L_INTNMLACR+L_FEE;*/


     l_CIMASTcheck_arr := txpks_check.fn_CIMASTcheck(p_txmsg.txfields('04').value,'CIMAST','ACCTNO');

     l_avlbal := GREATEST( l_CIMASTcheck_arr(0).avlbal,0);

   IF NOT (to_number(l_avlbal) >= to_number(p_txmsg.txfields('68').value)) THEN
        p_err_code := '-400110';
        plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
     END IF;
    --end of PhuongHT add
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
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    if TO_DATE(p_txmsg.txfields(c_overduedate).VALUE, systemnums.C_DATE_FORMAT) = p_txmsg.txdate then
        --DEN HAN --> Chuyen thanh trong han.
        for rec in
        (
            select * from lnschd where autoid = p_txmsg.txfields(c_autoid).VALUE
        )
        loop
            UPDATE LNSCHD
                    SET
                    INTNMLACR = INTNMLACR + INTDUE,
                    INTDUE = 0,
                    FEEINTNMLACR = FEEINTNMLACR + FEEINTDUE,
                    FEEINTDUE = 0
                WHERE AUTOID = p_txmsg.txfields(c_autoid).VALUE;
            INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, INTDUE, INTNMLACR, FEEINTDUE, FEEINTNMLACR)
                VALUES(p_txmsg.txfields(c_autoid).VALUE,
                    p_txmsg.txnum,
                    TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),
                    - rec.intdue,
                    rec.intdue,
                    - rec.feeintdue,
                    rec.feeintdue);
            update lnmast
            set INTNMLACR = INTNMLACR + rec.INTDUE,
                    INTDUE = INTDUE-rec.INTDUE,
                    FEEINTNMLACR = FEEINTNMLACR + rec.FEEINTDUE,
                    FEEINTDUE = FEEINTDUE- rec.FEEINTDUE
            where acctno = rec.acctno;

            delete lnschdlog where autoid = (select autoid from lnschd where refautoid = rec.autoid);
            delete lnschdloghist where autoid = (select autoid from lnschd where refautoid = rec.autoid);
            delete lnschd where refautoid = rec.autoid and reftype in ('I','GI');
            UPDATE CIMAST SET DUEAMT=DUEAMT-REC.NML-REC.INTDUE-REC.FEEINTDUE WHERE AFACCTNO=P_TXMSG.TXFIELDS('04').VALUE;
        end loop;
    end if;


    insert into lnschdextlog (txnum, txdate, lnschdid, orgoverduedate, froverduedate,
       tooverduedate, nml, intnmlacr, feeintnmlacr, deltd)
    select p_txmsg.txnum, TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'), autoid, nvl(log.orgoverduedate,overduedate),TO_DATE(p_txmsg.txfields(c_overduedate).VALUE ,'DD/MM/RRRR'),
        TO_DATE(p_txmsg.txfields(c_todate).VALUE ,'DD/MM/RRRR'), nml, intnmlacr, feeintnmlacr, 'N'
    from lnschd, (select lnschdid, max(orgoverduedate) orgoverduedate from lnschdextlog where lnschdid = p_txmsg.txfields(c_autoid).VALUE group by lnschdid) log
    where lnschd.autoid =  log.lnschdid(+) and autoid = p_txmsg.txfields(c_autoid).VALUE;

    UPDATE LNSCHD
    SET OVERDUEDATE = TO_DATE(p_txmsg.txfields(c_todate).VALUE ,'DD/MM/RRRR'),
        EXTIMES     =EXTIMES+1,
        exdays      = exdays + to_number(TO_DATE(p_txmsg.txfields(c_todate).VALUE  ,'DD/MM/RRRR') - getcurrdate)
    WHERE AUTOID = p_txmsg.txfields(c_autoid).VALUE;

    BEGIN
    -- Ghi du lieu cho bao cao gia han margin
        FOR rec IN
        (
            SELECT lnschd.*  FROM lnschd WHERE  lnschd.autoid = p_txmsg.txfields(c_autoid).VALUE
        )
        LOOP
            INSERT INTO rpt_change_term_4_margin (txnum, txdate, afacctno, rlsdate, overduedate, lnschdid, lnprinamt, lnintamt, lnfeeamt)
            VALUES (p_txmsg.txnum,
                    p_txmsg.txdate,
                    p_txmsg.txfields(c_afacctno).value,
                    rec.rlsdate,
                    TO_DATE(p_txmsg.txfields(c_todate).VALUE ,'DD/MM/RRRR'),
                    rec.autoid,
                    rec.nml + rec.ovd,
                    rec.intnmlacr + rec.intdue,
                    rec.feeintnmlacr + rec.feeintdue  );
        END LOOP;
    END;
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
         plog.init ('TXPKS_#5574EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#5574EX;
/
