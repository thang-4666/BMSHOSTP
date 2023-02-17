SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#5502ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#5502EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      26/06/2012     Created
 **
 ** (c) 2008 by Financial Software Solutions. JSC.
 ** ----------------------------------------------------------------------------------------------------*/
IS
FUNCTION fn_txPreAppCheck(p_txmsg IN OUT tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_txAftAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_txPreAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_txAftAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
END;

 
 
 
 
 
 
 
 
 
 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY txpks_#5502ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_lnsautoid        CONSTANT CHAR(2) := '01';
   c_lnacctno         CONSTANT CHAR(2) := '02';
   c_custodycd        CONSTANT CHAR(2) := '88';
   c_afacctno         CONSTANT CHAR(2) := '05';
   c_custname         CONSTANT CHAR(2) := '57';
   c_intnmlacr        CONSTANT CHAR(2) := '23';
   c_newintnmlacr     CONSTANT CHAR(2) := '33';
   c_intdue           CONSTANT CHAR(2) := '24';
   c_newintdue        CONSTANT CHAR(2) := '34';
   c_intnmlovd        CONSTANT CHAR(2) := '25';
   c_newintnmlovd     CONSTANT CHAR(2) := '35';
   c_intovdacr        CONSTANT CHAR(2) := '26';
   c_newintovdacr     CONSTANT CHAR(2) := '36';
   c_feeintnmlacr     CONSTANT CHAR(2) := '28';
   c_newfeeintnmlacr   CONSTANT CHAR(2) := '38';
   c_feeintdue        CONSTANT CHAR(2) := '29';
   c_newfeeintdue     CONSTANT CHAR(2) := '39';
   c_feeintnmlovd     CONSTANT CHAR(2) := '30';
   c_newfeeintnmlovd   CONSTANT CHAR(2) := '40';
   c_feeintovdacr     CONSTANT CHAR(2) := '31';
   c_newfeeintovdacr   CONSTANT CHAR(2) := '41';
   c_desc             CONSTANT CHAR(2) := '50';
FUNCTION fn_txPreAppCheck(p_txmsg IN out tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
    V_CURRDATE  DATE;
    V_LNACCTNO  VARCHAR2(20);
    V_LNSAUTOID VARCHAR2(20);
    V_AD_INTNMLACR  NUMBER;
    V_AD_INTDUE     NUMBER;
    V_AD_INTNMLOVD  NUMBER;
    V_AD_INTOVDACR  NUMBER;
    V_AD_FEEINTNMLACR   NUMBER;
    V_AD_FEEINTDUE      NUMBER;
    V_AD_FEEINTNMLOVD   NUMBER;
    V_AD_FEEINTOVDACR   NUMBER;
    V_OVERDUEDATE       DATE;
    V_DUEDATE           DATE;
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

    SELECT getcurrdate INTO V_CURRDATE FROM DUAL;

    SELECT LNS.overduedate, LNS.duedate
    INTO V_OVERDUEDATE, V_DUEDATE
    FROM LNSCHD LNS
    WHERE AUTOID = p_txmsg.txfields ('01').value;

    V_LNACCTNO := p_txmsg.txfields ('02').value;
    V_LNSAUTOID := p_txmsg.txfields ('01').value;
    V_AD_INTNMLACR := TO_NUMBER(p_txmsg.txfields ('33').value) - TO_NUMBER(p_txmsg.txfields ('23').value);
    V_AD_INTDUE := TO_NUMBER(p_txmsg.txfields ('34').value) - TO_NUMBER(p_txmsg.txfields ('24').value);
    V_AD_INTNMLOVD := TO_NUMBER(p_txmsg.txfields ('35').value) - TO_NUMBER(p_txmsg.txfields ('25').value);
    V_AD_INTOVDACR := TO_NUMBER(p_txmsg.txfields ('36').value) - TO_NUMBER(p_txmsg.txfields ('26').value);
    V_AD_FEEINTNMLACR := TO_NUMBER(p_txmsg.txfields ('38').value) - TO_NUMBER(p_txmsg.txfields ('28').value);
    V_AD_FEEINTDUE := TO_NUMBER(p_txmsg.txfields ('39').value) - TO_NUMBER(p_txmsg.txfields ('29').value);
    V_AD_FEEINTNMLOVD := TO_NUMBER(p_txmsg.txfields ('40').value) - TO_NUMBER(p_txmsg.txfields ('30').value);
    V_AD_FEEINTOVDACR := TO_NUMBER(p_txmsg.txfields ('41').value) - TO_NUMBER(p_txmsg.txfields ('31').value);

    -- NEU THAY DOI PHI/LAI DEN HAN THI KIEM TRA NGAY HIEN TAI CO PHAI NGAY DEN HAN HAY KO
    IF (V_AD_INTDUE <> 0 OR V_AD_FEEINTDUE <> 0) AND (V_CURRDATE <> V_OVERDUEDATE) THEN
        --plog.error(pkgctx, 'V_AD_INTNMLACR: ' || V_AD_INTNMLACR || ' V_AD_INTDUE: ' || V_AD_INTDUE);
        p_err_code:= errnums.C_MR_CURRDATE_NOT_DUEDATE;
        plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
        RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;
    plog.error(pkgctx, 'V_OVERDUEDATE: ' || to_char(V_OVERDUEDATE,'dd/mm/yyyy') || ' V_AD_INTDUE: ' || V_AD_INTDUE);
    -- KIEM TRA NGAY GD
    IF V_CURRDATE < V_OVERDUEDATE THEN
        -- CHUA DEN NGAY QUA HAN, KO DC SUA LAI/PHI QUA HAN
        IF V_AD_INTNMLOVD <> 0 OR V_AD_INTOVDACR <> 0 OR V_AD_FEEINTNMLOVD <> 0 OR V_AD_FEEINTOVDACR <> 0 THEN
            p_err_code := errnums.C_MR_CURRDATE_SMALLER_DUEDATE;
            plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
            RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;
    ELSIF V_CURRDATE > V_OVERDUEDATE THEN
        -- DA QUA HAN, KO DC SUA LAI/PHI TRONG HAN
        IF V_AD_INTNMLACR <> 0 OR V_AD_INTDUE <> 0 OR V_AD_FEEINTNMLACR <> 0 OR V_AD_FEEINTDUE <> 0 THEN
           /* p_err_code:= errnums.C_MR_CURRDATE_LARGER_DUEDATE;
            plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
            RETURN errnums.C_BIZ_RULE_INVALID;*/
            p_txmsg.txWarningException('-1800631').value:= cspks_system.fn_get_errmsg('-180063');
            p_txmsg.txWarningException('-1800631').errlev:= '1';

        END IF;
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
    V_CURRDATE  DATE;
    --V_LNSAUTOID NUMBER;
    V_LNACCTNO  VARCHAR2(20);
    V_LNSAUTOID VARCHAR2(20);
    V_ACRDATE   DATE;
    V_RATE1     NUMBER;
    V_RATE2     NUMBER;
    V_RATE3     NUMBER;
    V_NML       NUMBER;
    V_CFRATE1   NUMBER;
    V_CFRATE2   NUMBER;
    V_CFRATE3   NUMBER;
    V_REFTYPE   VARCHAR2(5);
    V_AD_INTNMLACR  NUMBER;
    V_AD_INTDUE     NUMBER;
    V_AD_INTNMLOVD  NUMBER;
    V_AD_INTOVDACR  NUMBER;
    V_AD_FEEINTNMLACR   NUMBER;
    V_AD_FEEINTDUE      NUMBER;
    V_AD_FEEINTNMLOVD   NUMBER;
    V_AD_FEEINTOVDACR   NUMBER;
    V_OVERDUEDATE       DATE;
    V_OVDACRDATE        DATE;
    V_DUEDATE           DATE;
    V_OVD               NUMBER;

    l_txdesc VARCHAR2(1000);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/

    SELECT getcurrdate INTO V_CURRDATE FROM DUAL;

    SELECT LNS.acrdate, LNS.rate1,LNS.rate2, LNS.RATE3, LNS.cfrate1, LNS.cfrate2, LNS.cfrate3, LNS.nml, LNS.ovd, LNS.reftype, LNS.overduedate, LNS.ovdacrdate, LNS.duedate
    INTO V_ACRDATE, V_RATE1, V_RATE2, V_RATE3, V_CFRATE1, V_CFRATE2, V_CFRATE3, V_NML, V_OVD, V_REFTYPE, V_OVERDUEDATE, V_OVDACRDATE, V_DUEDATE
    FROM LNSCHD LNS
    WHERE AUTOID = p_txmsg.txfields ('01').value;

    V_LNACCTNO := p_txmsg.txfields ('02').value;
    V_LNSAUTOID := p_txmsg.txfields ('01').value;
    V_AD_INTNMLACR := TO_NUMBER(p_txmsg.txfields ('33').value) - TO_NUMBER(p_txmsg.txfields ('23').value);
    V_AD_INTDUE := TO_NUMBER(p_txmsg.txfields ('34').value) - TO_NUMBER(p_txmsg.txfields ('24').value);
    V_AD_INTNMLOVD := TO_NUMBER(p_txmsg.txfields ('35').value) - TO_NUMBER(p_txmsg.txfields ('25').value);
    V_AD_INTOVDACR := TO_NUMBER(p_txmsg.txfields ('36').value) - TO_NUMBER(p_txmsg.txfields ('26').value);
    V_AD_FEEINTNMLACR := TO_NUMBER(p_txmsg.txfields ('38').value) - TO_NUMBER(p_txmsg.txfields ('28').value);
    V_AD_FEEINTDUE := TO_NUMBER(p_txmsg.txfields ('39').value) - TO_NUMBER(p_txmsg.txfields ('29').value);
    V_AD_FEEINTNMLOVD := TO_NUMBER(p_txmsg.txfields ('40').value) - TO_NUMBER(p_txmsg.txfields ('30').value);
    V_AD_FEEINTOVDACR := TO_NUMBER(p_txmsg.txfields ('41').value) - TO_NUMBER(p_txmsg.txfields ('31').value);

    -- update trong LNMAST cac truong lai qua han:
    IF V_REFTYPE='GP' THEN -- neu la phat vay bao lanh
       l_txdesc:= cspks_system.fn_DBgen_trandesc(p_txmsg,'5502','LN','0059');
       INSERT INTO LNTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
       VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('02').value,'0059',ROUND(p_txmsg.txfields('35').value-p_txmsg.txfields('25').value,0),NULL,'',p_txmsg.deltd,'',seq_LNTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || l_txdesc || '');

       l_txdesc:= cspks_system.fn_DBgen_trandesc(p_txmsg,'5502','LN','0063');
       INSERT INTO LNTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
       VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('02').value,'0063',ROUND(p_txmsg.txfields('36').value-p_txmsg.txfields('26').value,4),NULL,'',p_txmsg.deltd,'',seq_LNTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || l_txdesc || '');
       UPDATE LNMAST
         SET
          OINTNMLOVD = OINTNMLOVD + (ROUND(p_txmsg.txfields('35').value-p_txmsg.txfields('25').value,0)),

          OINTOVDACR = OINTOVDACR + (ROUND(p_txmsg.txfields('36').value-p_txmsg.txfields('26').value,4))
         WHERE ACCTNO=p_txmsg.txfields('02').value;
    ELSE-- phat vay margin
         l_txdesc:= cspks_system.fn_DBgen_trandesc(p_txmsg,'5502','LN','0028');
       INSERT INTO LNTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
       VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('02').value,'0028',ROUND(p_txmsg.txfields('35').value-p_txmsg.txfields('25').value,0),NULL,'',p_txmsg.deltd,'',seq_LNTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || l_txdesc || '');

       l_txdesc:= cspks_system.fn_DBgen_trandesc(p_txmsg,'5502','LN','0044');
       INSERT INTO LNTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
       VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('02').value,'0044',ROUND(p_txmsg.txfields('36').value-p_txmsg.txfields('26').value,4),NULL,'',p_txmsg.deltd,'',seq_LNTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || l_txdesc || '');
       UPDATE LNMAST
         SET
          INTNMLOVD = INTNMLOVD + (ROUND(p_txmsg.txfields('35').value-p_txmsg.txfields('25').value,0)),

          INTOVDACR = INTOVDACR + (ROUND(p_txmsg.txfields('36').value-p_txmsg.txfields('26').value,4))
         WHERE ACCTNO=p_txmsg.txfields('02').value;
    END if;

    /*-- NEU THAY DOI PHI/LAI DEN HAN THI KIEM TRA NGAY HIEN TAI CO PHAI NGAY DEN HAN HAY KO
    IF (V_AD_INTDUE <> 0 OR V_AD_FEEINTDUE <> 0) AND (V_CURRDATE <> V_OVERDUEDATE) THEN
        plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
        RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;

    -- KIEM TRA NGAY GD
    IF V_CURRDATE < V_OVERDUEDATE THEN
        -- CHUA DEN NGAY QUA HAN, KO DC SUA LAI/PHI QUA HAN
        IF V_AD_INTNMLOVD <> 0 OR V_AD_INTOVDACR <> 0 OR V_AD_FEEINTNMLOVD <> 0 OR V_AD_FEEINTOVDACR <> 0 THEN
            plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
            RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;
    ELSIF V_CURRDATE > V_OVERDUEDATE THEN
        -- DA QUA HAN, KO DC SUA LAI/PHI TRONG HAN
        IF V_AD_INTNMLACR <> 0 OR V_AD_INTDUE <> 0 OR V_AD_FEEINTNMLACR <> 0 OR V_AD_FEEINTDUE <> 0 THEN
            plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
            RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;
    END IF;*/

    plog.error(pkgctx, 'V_LNSAUTOID: ' || V_LNSAUTOID || ' V_AD_INTDUE: ' || V_AD_INTDUE);
    -- GHI NHAN VAO CAC BANG LOG
    -- INTNMLACR: LAI TRONG HAN
    -- FEEINTNMLACR: PHI TRONG HAN
    IF (V_AD_INTNMLACR <> 0) OR (V_AD_FEEINTNMLACR <> 0) THEN
        INSERT INTO LNINTTRAN (AUTOID, ACCTNO, INTTYPE, FRDATE, TODATE, ICRULE, IRRATE, INTBAL, INTAMT,Cfirrate,Feeintamt, LNSCHDID)
        VALUES(SEQ_CIINTTRAN.NEXTVAL, V_LNACCTNO, DECODE(V_REFTYPE,'P','I','GP','GI','I'), V_ACRDATE, V_CURRDATE, 'S', V_RATE1, V_NML, V_AD_INTNMLACR,V_CFRATE1,V_AD_FEEINTNMLACR, V_LNSAUTOID);

        INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE, INTDUE, INTOVD, INTOVDPRIN, FEEDUE, FEEOVD, INTPAID, FEEPAID,FEEINTNMLACR)
        VALUES(V_LNSAUTOID, NULL, TO_DATE(V_CURRDATE,'dd/mm/yyyy'), 0, 0, 0, V_AD_INTNMLACR, 0, 0, 0, 0, 0, 0, 0 ,0,V_AD_FEEINTNMLACR);
    END IF;

    -- INTDUE: LAI TOI HAN
    -- FEEINTDUE: PHI TOI HAN
    IF V_AD_INTDUE <> 0 THEN
        INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE, INTDUE, INTOVD, INTOVDPRIN, FEEDUE, FEEOVD, INTPAID, FEEPAID,FEEINTNMLACR)
        VALUES(V_LNSAUTOID, NULL, TO_DATE(V_CURRDATE,'dd/mm/yyyy'), 0, 0, 0, 0, 0, V_AD_INTDUE, 0, 0, 0, 0, 0 ,0,0);
    END IF;
    IF V_AD_FEEINTDUE <> 0 THEN
        INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE, INTDUE, INTOVD, INTOVDPRIN, FEEDUE, FEEOVD, INTPAID, FEEPAID,FEEINTNMLACR)
        VALUES(V_LNSAUTOID, NULL, TO_DATE(V_CURRDATE,'dd/mm/yyyy'), 0, 0, 0, 0, 0, 0, 0, 0, V_AD_FEEINTDUE, 0, 0 ,0,0);
    END IF;

    -- INTNMLOVD: LAI QUA HAN
    IF V_AD_INTNMLOVD <> 0 THEN
        INSERT INTO LNINTTRAN (AUTOID, ACCTNO, INTTYPE, FRDATE, TODATE, ICRULE, IRRATE, INTBAL, INTAMT,CFIRRATE,FEEINTAMT, LNSCHDID)
        VALUES(SEQ_CIINTTRAN.NEXTVAL, V_LNACCTNO, 'O', V_OVDACRDATE, V_CURRDATE, 'S', V_RATE3, V_OVD, V_AD_INTNMLOVD,V_CFRATE3,0, V_LNSAUTOID);

        INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE, INTDUE, INTOVD, INTOVDPRIN, FEEDUE, FEEOVD, INTPAID, FEEPAID,FEEINTOVDPRIN)
        VALUES(V_LNSAUTOID, NULL, TO_DATE(V_CURRDATE,'dd/mm/yyyy'), 0, 0, 0, 0, 0, 0, V_AD_INTNMLOVD, 0, 0, 0, 0 ,0,0);
    END IF;
    -- FEEINTNMLOVD: PHI QUA HAN
    IF V_AD_FEEINTNMLOVD <> 0 THEN
        INSERT INTO LNINTTRAN (AUTOID, ACCTNO, INTTYPE, FRDATE, TODATE, ICRULE, IRRATE, INTBAL, INTAMT,CFIRRATE,FEEINTAMT, LNSCHDID)
        VALUES(SEQ_CIINTTRAN.NEXTVAL, V_LNACCTNO, 'FO', V_OVDACRDATE, V_CURRDATE, 'S', V_RATE3, V_OVD, 0,V_CFRATE3,V_AD_FEEINTNMLOVD, V_LNSAUTOID);

        INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE, INTDUE, INTOVD, INTOVDPRIN, FEEDUE, FEEOVD, INTPAID, FEEPAID,FEEINTOVDPRIN)
        VALUES(V_LNSAUTOID, NULL, TO_DATE(V_CURRDATE,'dd/mm/yyyy'), 0, 0, 0, 0, 0, 0, 0, 0, 0, V_AD_FEEINTNMLOVD, 0 ,0,0);
    END IF;
    -- INTOVDACR: LAI TREN GOC QUA HAN
    IF V_AD_INTOVDACR <> 0 THEN
        INSERT INTO LNINTTRAN (AUTOID, ACCTNO, INTTYPE, FRDATE, TODATE, ICRULE, IRRATE, INTBAL, INTAMT,CFIRRATE,FEEINTAMT, LNSCHDID)
        VALUES(SEQ_CIINTTRAN.NEXTVAL, V_LNACCTNO, 'FIO', V_OVDACRDATE, V_CURRDATE, 'S', V_RATE3, V_OVD, V_AD_INTOVDACR,V_CFRATE3,0, V_LNSAUTOID);

        INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE, INTDUE, INTOVD, INTOVDPRIN, FEEDUE, FEEOVD, INTPAID, FEEPAID,FEEINTOVDPRIN)
        VALUES(V_LNSAUTOID, NULL, TO_DATE(V_CURRDATE,'dd/mm/yyyy'), 0, 0, 0, 0, 0, 0, 0, V_AD_INTOVDACR, 0, 0, 0 ,0,0);
    END IF;
    -- FEEINTOVDACR: PHI TREN GOC QUA HAN
    IF V_AD_FEEINTOVDACR <> 0 THEN
        INSERT INTO LNINTTRAN (AUTOID, ACCTNO, INTTYPE, FRDATE, TODATE, ICRULE, IRRATE, INTBAL, INTAMT,CFIRRATE,FEEINTAMT, LNSCHDID)
        VALUES(SEQ_CIINTTRAN.NEXTVAL, V_LNACCTNO, 'FFO', V_OVDACRDATE, V_CURRDATE, 'S', V_RATE3, V_OVD, 0,V_CFRATE3,V_AD_FEEINTOVDACR, V_LNSAUTOID);

        INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE, NML, OVD, PAID, INTNMLACR, FEE, INTDUE, INTOVD, INTOVDPRIN, FEEDUE, FEEOVD, INTPAID, FEEPAID,FEEINTOVDPRIN)
        VALUES(V_LNSAUTOID, NULL, TO_DATE(V_CURRDATE,'dd/mm/yyyy'), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ,0,V_AD_FEEINTOVDACR);
    END IF;

    -- UPDATE LNSCHD
    UPDATE LNSCHD SET
        INTNMLACR = INTNMLACR + V_AD_INTNMLACR,
        FEEINTNMLACR = FEEINTNMLACR + V_AD_FEEINTNMLACR,
        INTDUE = INTDUE + V_AD_INTDUE,
        FEEINTDUE = FEEINTDUE + V_AD_FEEINTDUE,
        INTOVD = INTOVD + V_AD_INTNMLOVD,
        FEEINTNMLOVD = FEEINTNMLOVD + V_AD_FEEINTNMLOVD,
        INTOVDPRIN = INTOVDPRIN + V_AD_INTOVDACR,
        FEEINTOVDACR = FEEINTOVDACR + V_AD_FEEINTOVDACR,
        ACCRUALSAMT =ACCRUALSAMT +V_AD_INTNMLACR+V_AD_FEEINTNMLACR+V_AD_INTDUE+V_AD_FEEINTDUE+V_AD_INTNMLOVD+V_AD_FEEINTNMLOVD+V_AD_INTOVDACR+V_AD_FEEINTOVDACR
    WHERE AUTOID = V_LNSAUTOID;

    INSERT INTO LNSCHDLOG(AUTOID, TXNUM, TXDATE,ACCRUALSAMT)
     VALUES(V_LNSAUTOID, NULL, TO_DATE(V_CURRDATE,'dd/mm/yyyy'), V_AD_INTNMLACR+V_AD_FEEINTNMLACR+V_AD_INTDUE+V_AD_FEEINTDUE+V_AD_INTNMLOVD+V_AD_FEEINTNMLOVD+V_AD_INTOVDACR+V_AD_FEEINTOVDACR);

    --Reset cimast : ovamt, odamt, dueamt
     UPDATE CIMAST SET ODAMT = 0, DUEAMT=0, OVAMT=0
        WHERE ACCTNO = p_txmsg.txfields ('05').value;
     -- update cimast set odamt
    for rec_af in
    (
        select trfacctno, sum(PRINNML + PRINOVD + INTNMLACR + INTOVDACR + INTNMLOVD + INTDUE + INTPREPAID +
                                OPRINNML + OPRINOVD + OINTNMLACR + OINTOVDACR + OINTNMLOVD + OINTDUE + OINTPREPAID +
                                FEE + FEEDUE + FEEOVD + FEEINTNMLACR + FEEINTOVDACR + FEEINTNMLOVD + FEEINTDUE + FEEINTPREPAID) ODAMT
               from lnmast
               where ftype = 'AF' AND trfacctno = p_txmsg.txfields ('05').value
               group by trfacctno

    )
    loop -- rec_af
        UPDATE CIMAST SET ODAMT = rec_af.ODAMT
        WHERE ACCTNO = rec_af.TRFACCTNO;
    end loop; -- rec_af
    -- update cimast set dueamt
    FOR REC IN
    (
        select m.trfacctno, sum(nml + INTDUE + FEEINTDUE) nml
        from
        (SELECT ACCTNO, SUM(NML) NML
            FROM LNSCHD
            WHERE OVERDUEDATE = TO_DATE(cspks_system.fn_get_sysvar('SYSTEM','CURRDATE'),'DD/MM/YYYY') AND nml + INTDUE + FEEINTDUE > 0 AND REFTYPE IN ('P') group by acctno) S,
            LNMAST M
        where S.ACCTNO = M.ACCTNO AND M.STATUS NOT IN ('P','R','C') and M.FTYPE<>'DF'
        AND trfacctno = p_txmsg.txfields ('05').value
        GROUP BY M.TRFACCTNO

    )
    LOOP
        UPDATE CIMAST SET DUEAMT = round(DUEAMT + REC.NML,0) WHERE ACCTNO = REC.TRFACCTNO;
    END LOOP;

    -- update cimast set ovamt
    for rec_af in
    (
        select trfacctno, sum(PRINOVD + INTOVDACR + INTNMLOVD + INTPREPAID +
                                OPRINNML + OPRINOVD + OINTNMLACR + OINTOVDACR + OINTNMLOVD + OINTDUE + OINTPREPAID +
                                FEE + FEEDUE + FEEOVD + FEEINTOVDACR + FEEINTNMLOVD + FEEINTPREPAID) OVAMT
        from lnmast
        where ftype = 'AF'  AND trfacctno = p_txmsg.txfields ('05').value
        group by trfacctno

    )
    loop -- rec_af
        UPDATE CIMAST SET OVAMT = rec_af.OVAMT
        WHERE ACCTNO = rec_af.TRFACCTNO;
    end loop; -- rec_af

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
         plog.init ('TXPKS_#5502EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#5502EX;
/
