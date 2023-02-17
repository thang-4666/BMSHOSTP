SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#2245ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#2245EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      12/09/2011     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#2245ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_codeid           CONSTANT CHAR(2) := '01';
   c_inward           CONSTANT CHAR(2) := '03';
   c_custodycd        CONSTANT CHAR(2) := '88';
   c_afacct2          CONSTANT CHAR(2) := '04';
   c_acct2            CONSTANT CHAR(2) := '05';
   c_custname         CONSTANT CHAR(2) := '90';
   c_address          CONSTANT CHAR(2) := '91';
   c_license          CONSTANT CHAR(2) := '92';
   c_price            CONSTANT CHAR(2) := '09';
   c_amt              CONSTANT CHAR(2) := '10';
   c_cidfpofeeacr     CONSTANT CHAR(2) := '13';
   c_depoblock        CONSTANT CHAR(2) := '06';
   c_qttytype         CONSTANT CHAR(2) := '14';
   c_parvalue         CONSTANT CHAR(2) := '11';
   c_qtty             CONSTANT CHAR(2) := '12';
   c_trtype           CONSTANT CHAR(2) := '31';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in out tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
    l_count number;
    l_qtty06 NUMBER;
    l_qtty10 NUMBER;
    v_custodycd     VARCHAR2(20);
    v_codeid        varchar2(20);
    v_qtty          NUMBER;
    l_af_status     afmast.status%TYPE;
    l_symbol        VARCHAR2(50);
    l_tradeqtty     NUMBER;
    l_blockedqtty   NUMBER;
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

   SELECT NVL(COUNT(*),0) INTO l_count FROM CFMAST WHERE custodycd = p_txmsg.txfields(c_custodycd).value AND status in('A','G');
   IF l_count<=0 THEN
    BEGIN
        p_err_code := errnums.C_CF_CFMAST_STAT_NOTVALID;
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    END;
   END IF;

   SELECT NVL(COUNT(*),0) INTO l_count FROM AFMAST WHERE acctno = p_txmsg.txfields(c_afacct2).value AND status in('A','G','B');
   IF l_count<=0 THEN
    BEGIN
        p_err_code := '-400100';
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    END;
   END IF;

    select count(1) into l_count
    from issuer_member iss, afmast af, sbsecurities sb, aftype aft, mrtype mrt
    where af.custid = iss.custid and iss.issuerid = sb.issuerid and sb.codeid = p_txmsg.txfields(c_codeid).value and af.acctno = p_txmsg.txfields(c_afacct2).value
        and af.actype = aft.actype and aft.mrtype = mrt.actype and mrt.mrtype = 'T';
    if l_count > 0 then
        p_txmsg.txWarningException('-9000941').value:= cspks_system.fn_get_errmsg('-900094');
        p_txmsg.txWarningException('-9000941').errlev:= '1';
    end if;
    IF p_txmsg.deltd = 'N' THEN
        if txpks_prchk.fn_RoomLimitCheck(p_txmsg.txfields('04').value, p_txmsg.txfields('01').value,
            greatest(to_number(p_txmsg.txfields('10').value),0), p_err_code) <> 0 then
            plog.setendsection (pkgctx, 'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        end if;
         ELSE --Neu la giao dich xoa
          SELECT trade, blocked+emkqtty INTO l_qtty10, l_qtty06 FROM semast WHERE acctno =p_txmsg.txfields(c_acct2).value;
          IF (l_qtty10< p_txmsg.txfields(c_amt).value OR l_qtty06 <p_txmsg.txfields(c_depoblock).value) THEN
                        p_err_code := '-900017';
                        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                        RETURN errnums.C_BIZ_RULE_INVALID;
            END IF;
    end if;

    --Neu giao dich lam tu bang duyet dien, check ma CK = ma CK nhan ve
    IF p_txmsg.txfields('02').value IS NOT NULL THEN
        BEGIN
            SELECT sb2.symbol, dtl.recustodycd, dtl.tradeqtty, dtl.blockedqtty
                INTO l_symbol, v_custodycd, l_tradeqtty, l_blockedqtty
            FROM
                (SELECT MAX(CASE WHEN vdtl.fldname = 'SYMBOL' THEN vdtl.fldval
                             WHEN vdtl.fldname = 'SYMBOL_CGD' THEN vdtl.fldval  || '_CGD'
                             ELSE '' END) symbol,
                        MAX(CASE WHEN vdtl.fldname = 'BLOCKEDQTTY' THEN TO_NUMBER(REPLACE (vdtl.fldval, ','))
                             ELSE 0 END) blockedqtty,
                        MAX(CASE WHEN vdtl.fldname = 'QTTY' THEN TO_NUMBER(REPLACE (vdtl.fldval, ','))
                             ELSE 0 END) tradeqtty,
                        MAX(CASE WHEN vdtl.fldname = 'VSDEFFDATE' THEN TO_DATE(vdtl.fldval,'RRRR/MM/DD')
                             ELSE null END) effdate,
                        MAX(CASE WHEN vdtl.fldname = 'CUSTODYCD' THEN vdtl.fldval
                             ELSE '' END) recustodycd,
                        MAX(CASE WHEN vdtl.fldname = 'REFCUSTODYCD' THEN substr(fldval, 1, 3)
                             ELSE '' END) inward,
                        MAX(lg.funcname) funcname,
                        MAX(CASE WHEN vdtl.fldname = 'SECTYPE' THEN fldval
                                 ELSE '' END) SECTYPE
                  FROM vsdtrflogdtl vdtl, vsdtrflog lg
                WHERE lg.autoid = vdtl.refautoid
                AND lg.autoid = p_txmsg.txfields('02').value) dtl , sbsecurities sb1, sbsecurities sb2
            where dtl.symbol = sb1.symbol
                  and case when dtl.SECTYPE like 'NORM' then sb2.codeid else sb2.refcodeid end = sb1.codeid;
        EXCEPTION WHEN OTHERS THEN
            l_symbol := '';
            v_custodycd := '';
            l_tradeqtty := 0;
            l_blockedqtty := 0;
        END;

        SELECT count(*) INTO l_count FROM sbsecurities WHERE UPPER(symbol) = UPPER(l_symbol) AND codeid = p_txmsg.txfields('01').value;

        IF l_count <= 0 THEN
             p_err_code := '-900006';
            plog.setEndSection(pkgctx,'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;

        IF v_custodycd <> p_txmsg.txfields('88').value THEN
             p_err_code := '-900005';
            plog.setEndSection(pkgctx,'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;

        v_qtty := NVL(l_tradeqtty,0) + NVL(l_blockedqtty,0);
        IF v_qtty <> p_txmsg.txfields('12').value THEN
             p_err_code := '-900007';
            plog.setEndSection(pkgctx,'fn_txPreAppCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;
    END IF;

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
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'fn_txAftAppCheck');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txAftAppCheck;

FUNCTION fn_txPreAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
    l_count     NUMBER;
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txPreAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txPreAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC PROCESS HERE. . DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    /*IF p_txmsg.txfields('02').value IS NOT NULL THEN
        SELECT COUNT(*) INTO l_count FROM vw_se2245 WHERE reqid = p_txmsg.txfields('02').value;
        IF l_count <= 0 THEN
            p_err_code := '-900136';
            plog.setendsection (pkgctx, 'fn_txPreAppUpdate');
            RETURN errnums.C_BIZ_RULE_INVALID;
        END IF;
    END IF;*/
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
v_strCODEID varchar2(10);
v_strAFACCTNO varchar2(20);
v_strACCTNO varchar2(20);
v_strTYPEDEPOBLOCK varchar2(20);
v_nAMT number;
v_nPRICE number;
v_nDEPOTRADE number;
v_nDEPOBLOCK number;
v_txnum varchar2(20);
V_txdate date;
v_currmonth VARCHAR2(10);
v_TBALDT DATE;
v_count_days NUMBER;
l_semastcheck_arr txpks_check.semastcheck_arrtype;
l_sewithdrawcheck_arr txpks_check.sewithdrawcheck_arrtype;
l_avlsewithdraw apprules.field%TYPE;
l_trade apprules.field%TYPE;
L_ISWFT CHar(1);
v_custid varchar(30);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/

    v_strAFACCTNO := p_txmsg.txfields('04').VALUE;
    v_strACCTNO := p_txmsg.txfields('05').VALUE;
    v_nAMT := p_txmsg.txfields('12').VALUE;
    v_nDEPOTRADE := p_txmsg.txfields('10').VALUE;
    v_nDEPOBLOCK := p_txmsg.txfields('06').VALUE;
    v_strTYPEDEPOBLOCK := p_txmsg.txfields('14').VALUE;
    v_strCODEID:=p_txmsg.txfields('01').VALUE;

    v_txnum:= p_txmsg.txnum;
    V_txdate:= p_txmsg.txdate;
    v_TBALDT:= Greatest(to_date ( p_txmsg.txfields('32').value,'DD/MM/RRRR')+1, p_txmsg.busdate);
    -- so ngay tinh phi luu ky chua den han
    v_count_days:= p_txmsg.txdate - v_TBALDT;

    v_currmonth := to_char(to_date(V_txdate,'DD/MM/RRRR'),'RRRRMM');

    IF p_txmsg.deltd <> 'Y' THEN
       -- begin binhvt
       select af.custid into v_custid from afmast af  where af.acctno = v_strAFACCTNO;
        insert into SETYPETRF(AUTOID,NAMT,TXNUM,TXDATE,TLTXCD,TYPETRF,DELTD,Busdate,Custid,Afacctno) valueS
        (SEQ_SETYPETRF.Nextval, p_txmsg.txfields('45').value,p_txmsg.txnum,p_txmsg.txdate,'2245',p_txmsg.txfields('98').value,'N',p_txmsg.busdate,v_custid,p_txmsg.txfields('04').value);
       -- end binhvt

        IF v_strTYPEDEPOBLOCK='002' then

          INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
          VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('05').value,'0043',ROUND(p_txmsg.txfields('06').value,0),NULL,p_txmsg.txfields ('05').value,p_txmsg.deltd,p_txmsg.txfields ('14').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');
         ELSE
          INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
          VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('05').value,'0087',ROUND(p_txmsg.txfields('06').value,0),NULL,p_txmsg.txfields ('05').value,p_txmsg.deltd,p_txmsg.txfields ('14').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');
        END IF;

        INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('05').value,'0051',ROUND(p_txmsg.txfields('12').value*p_txmsg.txfields('09').value,0),NULL,p_txmsg.txfields ('03').value,p_txmsg.deltd,p_txmsg.txfields ('03').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

        INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('05').value,'0052',ROUND(p_txmsg.txfields('12').value,0),NULL,p_txmsg.txfields ('03').value,p_txmsg.deltd,p_txmsg.txfields ('03').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

        INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
            VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),p_txmsg.txfields ('05').value,'0012',ROUND(p_txmsg.txfields('10').value,0),NULL,p_txmsg.txfields ('03').value,p_txmsg.deltd,p_txmsg.txfields ('03').value,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

        IF v_strTYPEDEPOBLOCK='002' then

            UPDATE SEMAST
             SET
               BLOCKED = BLOCKED + (ROUND(p_txmsg.txfields('06').value,0)),
               DCRQTTY = DCRQTTY + (ROUND(p_txmsg.txfields('12').value,0)),
               DCRAMT = DCRAMT + (ROUND(p_txmsg.txfields('12').value*p_txmsg.txfields('09').value,0)),
               TRADE = TRADE + (ROUND(p_txmsg.txfields('10').value,0)), LAST_CHANGE = SYSTIMESTAMP
            WHERE ACCTNO=p_txmsg.txfields('05').value;

        ELSE

             UPDATE SEMAST
             SET
               EMKQTTY = EMKQTTY + (ROUND(p_txmsg.txfields('06').value,0)),
               DCRQTTY = DCRQTTY + (ROUND(p_txmsg.txfields('12').value,0)),
               DCRAMT = DCRAMT + (ROUND(p_txmsg.txfields('12').value*p_txmsg.txfields('09').value,0)),
               TRADE = TRADE + (ROUND(p_txmsg.txfields('10').value,0)), LAST_CHANGE = SYSTIMESTAMP
            WHERE ACCTNO=p_txmsg.txfields('05').value;

        END IF ;

        plog.debug(pkgctx,'2245: fn_txAftAppUpdate ' || v_nDEPOBLOCK || ' ' || v_strTYPEDEPOBLOCK );

    -- ghi nhan phi giao dich
        IF ( p_txmsg.txfields('45').VALUE + p_txmsg.txfields('55').VALUE > 0 ) THEN
           IF cspks_ciproc.fn_feedepodebit(p_txmsg,p_err_code) <> systemnums.C_SUCCESS THEN
           RETURN errnums.C_BIZ_RULE_INVALID;
           END IF;
         END IF;

        -- log 1 dong vao sedepobal
        --    IF ( p_txmsg.txfields('13').VALUE > 0 ) THEN
        IF  p_txmsg.txdate <> p_txmsg.BUSDATE  then
            cspks_ciproc.PR_LOGSEDEPOBAL(v_strCODEID,v_strAFACCTNO,v_count_days,TO_NUMBER(P_TXMSG.TXFIELDS('13').value),
                                     v_nAMT,v_TBALDT,to_char(V_txdate)||V_txnum);
         /*INSERT INTO SEDEPOBAL (AUTOID, ACCTNO, TXDATE, DAYS, QTTY, DELTD,ID,amt)
         VALUES (SEQ_SEDEPOBAL.NEXTVAL, p_txmsg.txfields('05').value,v_TBALDT,v_count_days, p_txmsg.txfields('12').value, 'N',to_char(V_txdate)||V_txnum,p_txmsg.txfields('13').VALUE);
          */
        END IF;
        -- ghi nhan them mot dong phi LK den han
--        IF ( p_txmsg.txfields('15').VALUE > 0 ) THEN
        IF  p_txmsg.txdate <> p_txmsg.BUSDATE  then
           IF cspks_ciproc.fn_FeeDepoMaturityBackdate(p_txmsg,p_err_code) <> systemnums.C_SUCCESS THEN
           RETURN errnums.C_BIZ_RULE_INVALID;
           END IF;
        END IF;

-----    secmast_generate(p_txmsg.txnum, p_txmsg.txdate, p_txmsg.busdate, PV_AFACCTNO=>?, PV_SYMBOL=>?, PV_SECTYPE=>?, PV_PTYPE=>?, PV_CAMASTID=>?, PV_ORDERID=>?, PV_QTTY=>?, PV_COSTPRICE=>?, PV_MAPAVL=>?);
        secmast_generate(p_txmsg.txnum, p_txmsg.txdate, p_txmsg.busdate, p_txmsg.txfields('04').value,
        p_txmsg.txfields('01').value, 'D', 'I', NULL, NULL,  p_txmsg.txfields('10').value, p_txmsg.txfields('09').value, 'Y');
      -- check xem co phai la ck wft khong
        SELECT (CASE WHEN NVL(REFCODEID,'a') ='a' THEN 'N' ELSE 'Y' END)
        INTO  L_ISWFT
        FROM SBSECURITIES WHERE CODEID=V_STRCODEID;
        IF L_ISWFT='Y' THEN
          INSERT INTO SEDEPOWFTLOG (TXNUM,TXDATE,CODEID,AFACCTNO,TRADE,BLOCKED,ISWFT,DELTD,TRADEDATE,DEPOTYPE)
          VALUES(v_txnum,V_txdate,v_strCODEID,v_strAFACCTNO,ROUND(p_txmsg.txfields('10').value,0),ROUND(p_txmsg.txfields('06').value,0),'Y','N', NULL,p_txmsg.txfields('16').value);

        END IF;

        IF p_txmsg.txfields('02').value IS NOT NULL THEN
        --Cap nhat trang thai dien gui ve
            UPDATE vsdtxreq
               SET status = 'C', msgstatus = 'F', objkey = p_txmsg.txnum,
                  txdate = p_txmsg.txdate, afacctno = p_txmsg.txfields('04').value, msgacct = p_txmsg.txfields('88').value
             WHERE reqid = p_txmsg.txfields('02').value;

            -- Trang thai VSDTRFLOG
            UPDATE vsdtrflog
               SET status = 'C', timeprocess = SYSTIMESTAMP
             WHERE referenceid = p_txmsg.txfields('02').value;
        END IF;
    ELSE --- p_txmsg.deltd = 'Y'
     --Kiem tra sl du cho phep xoa hay khong
         l_SEWITHDRAWcheck_arr := txpks_check.fn_SEWITHDRAWcheck(p_txmsg.txfields('05').value,'SEWITHDRAW','ACCTNO');
         l_AVLSEWITHDRAW := l_SEWITHDRAWcheck_arr(0).AVLSEWITHDRAW;

         /*IF NOT (to_number(l_AVLSEWITHDRAW) >= to_number(p_txmsg.txfields('10').value)) THEN
            p_err_code := '-900017';
            plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
         END IF;*/
         l_SEMASTcheck_arr := txpks_check.fn_SEMASTcheck(p_txmsg.txfields('05').value,'SEMAST','ACCTNO');
         l_TRADE := l_SEMASTcheck_arr(0).TRADE;
         IF NOT (to_number(l_TRADE) >= to_number(p_txmsg.txfields('10').value)) THEN
            p_err_code := '-900017';
            plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
            RETURN errnums.C_BIZ_RULE_INVALID;
         END IF;
        IF v_strTYPEDEPOBLOCK='002' THEN

             UPDATE SEMAST
              SET
                   BLOCKED=BLOCKED - (ROUND(p_txmsg.txfields('06').value,0)),
                   DCRQTTY=DCRQTTY - (ROUND(p_txmsg.txfields('12').value,0)),
                   DCRAMT=DCRAMT - (ROUND(p_txmsg.txfields('12').value*p_txmsg.txfields('09').value,0)),
                   TRADE=TRADE - (ROUND(p_txmsg.txfields('10').value,0)), LAST_CHANGE = SYSTIMESTAMP
                WHERE ACCTNO=p_txmsg.txfields('05').value;

        ELSE
            UPDATE SEMAST
              SET
                   EMKQTTY = EMKQTTY - (ROUND(p_txmsg.txfields('06').value,0)),
                   DCRQTTY=DCRQTTY - (ROUND(p_txmsg.txfields('12').value,0)),
                   DCRAMT=DCRAMT - (ROUND(p_txmsg.txfields('12').value*p_txmsg.txfields('09').value,0)),
                   TRADE=TRADE - (ROUND(p_txmsg.txfields('10').value,0)), LAST_CHANGE = SYSTIMESTAMP
                WHERE ACCTNO=p_txmsg.txfields('05').value;

        END IF ;

            -- ghi nhan phi giao dich
                    IF ( p_txmsg.txfields('45').VALUE + p_txmsg.txfields('55').VALUE > 0 ) THEN
                       IF cspks_ciproc.fn_feedepodebit(p_txmsg,p_err_code) <> systemnums.C_SUCCESS THEN
                       RETURN errnums.C_BIZ_RULE_INVALID;
                       END IF;
                     END IF;


                -- PhuongHT edit: log phi luu ky backdate
       --         IF ( p_txmsg.txfields('13').VALUE > 0 ) THEN
               IF  p_txmsg.txdate <> p_txmsg.BUSDATE  then
                UPDATE sedepobal SET deltd='Y' WHERE id=to_char(V_txdate)||V_txnum ;
                UPDATE SEDEPOBAL_HIST SET deltd='Y' WHERE id=to_char(V_txdate)||V_txnum ;
                END IF;
       --             IF ( p_txmsg.txfields('15').VALUE > 0 ) THEN
          IF  p_txmsg.txdate <> p_txmsg.BUSDATE  then
                       IF cspks_ciproc.fn_FeeDepoMaturityBackdate(p_txmsg,p_err_code) <> systemnums.C_SUCCESS THEN
                       RETURN errnums.C_BIZ_RULE_INVALID;
                       END IF;
           END IF;
                     -- end of PhuongHT
                     secnet_un_map(p_txmsg.txnum, p_txmsg.txdate);
               UPDATE SEDEPOWFTLOG SET DELTD='Y' WHERE TXNUM=P_TXMSG.TXNUM AND TXDATE=P_TXMSG.TXDATE;
        UPDATE SETRAN        SET DELTD = 'Y'
        WHERE TXNUM = P_TXMSG.TXNUM AND TXDATE = P_TXMSG.TXDATE;
         -- begin binhvt 09-2016
        UPDATE SETYPETRF set DELTD = 'Y' where txnum = P_TXMSG.TXNUM AND TXDATE=P_TXMSG.TXDATE;
        -- end binhvt
    end if;
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
         plog.init ('TXPKS_#2245EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#2245EX;
/
