SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#2210ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#2210EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      01/04/2015     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#2210ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_exectype         CONSTANT CHAR(2) := '12';
   c_custodycd        CONSTANT CHAR(2) := '01';
   c_fullname         CONSTANT CHAR(2) := '02';
   c_afacctno         CONSTANT CHAR(2) := '03';
   c_codeid           CONSTANT CHAR(2) := '05';
   c_qtty             CONSTANT CHAR(2) := '06';
   c_amt              CONSTANT CHAR(2) := '07';
   c_feeamt           CONSTANT CHAR(2) := '11';
   c_clearday         CONSTANT CHAR(2) := '08';
   c_txdate           CONSTANT CHAR(2) := '09';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
    l_exectype  varchar2(10);
    l_status    VARCHAR2(1);
    l_cimastcheck_arr txpks_check.cimastcheck_arrtype;
    l_BALDEFOVD number(20,4);
    l_PP number(20,4);
    l_PPse number(20,4);
    l_AVLLIMIT number(20,4);
    l_margintype            CHAR (1);
    l_actype                VARCHAR2 (4);
    V_ADVAMT        NUMBER;
    l_marginrefprice number(20,4);
    l_marginprice number(20,4);
    l_istrfbuy char(1);
    l_seclimit number;
    l_mrpriceloan number(20,4);
    l_mrratiorate number(20,4);
    l_remainamt number;
    l_PPMax number(20,0);
    l_chksysctrl varchar2(1);
    l_ismarginallow varchar2(1);
    l_semastcheck_arr txpks_check.semastcheck_arrtype;
    l_trade apprules.field%TYPE;

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
    if p_txmsg.deltd <> 'Y' then
        l_exectype := p_txmsg.txfields(c_exectype).value;
        select status into l_status from cimast where afacctno = p_txmsg.txfields(c_afacctno).value;
            IF ( INSTR('G',l_STATUS) > 0) THEN
                p_err_code := '-400100';
                RETURN errnums.C_BIZ_RULE_INVALID;
            END IF;
        if(l_exectype = 'NB') then
            l_CIMASTcheck_arr := txpks_check.fn_CIMASTcheck(p_txmsg.txfields(c_afacctno).value,'CIMAST','ACCTNO');
            l_PP := l_CIMASTcheck_arr(0).PP;
            l_AVLLIMIT := l_CIMASTcheck_arr(0).AVLLIMIT;
            l_STATUS := l_CIMASTcheck_arr(0).STATUS;
            V_ADVAMT:=l_CIMASTcheck_arr(0).AVLADVANCE;
            l_BALDEFOVD := l_CIMASTcheck_arr(0).BALDEFOVD;
            IF NOT (to_number(l_PP) >= to_number(p_txmsg.txfields('07').value+p_txmsg.txfields('11').value)) THEN
                p_err_code := '-400116';
                plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                RETURN errnums.C_BIZ_RULE_INVALID;
            END IF;
            IF NOT ( INSTR('AT',l_STATUS) > 0) THEN
                p_err_code := '-400100';
                plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                RETURN errnums.C_BIZ_RULE_INVALID;
            END IF;
           /* IF NOT (ceil(to_number(l_PP)) >= to_number(ROUND(p_txmsg.txfields(c_amt).value,0))) THEN
                p_err_code := '-400116';
                plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                RETURN errnums.C_BIZ_RULE_INVALID;
            END IF;*/
            IF NOT (to_number(l_AVLLIMIT) >= to_number(ROUND(p_txmsg.txfields(c_amt).value,0))) THEN
                p_err_code := '-400117';
                plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                RETURN errnums.C_BIZ_RULE_INVALID;
            END IF;
        else
            /*if not cspks_odproc.fn_checkTradingAllow(p_txmsg.txfields('03').value, p_txmsg.txfields('01').value, 'S', p_err_code) then
                plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                Return errnums.C_BIZ_RULE_INVALID;
            end if;*/
            l_SEMASTcheck_arr := txpks_check.fn_SEMASTcheck(p_txmsg.txfields('03').value||p_txmsg.txfields('05').value,'SEMAST','ACCTNO');
            l_TRADE := l_SEMASTcheck_arr(0).TRADE;
            IF NOT (greatest(to_number(l_TRADE),0) >= to_number(p_txmsg.txfields(c_qtty).value)) THEN
                p_err_code := '-900017';
                plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                RETURN errnums.C_BIZ_RULE_INVALID;
            END IF;
        end if;
    END IF ;
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
    l_exectype  varchar2(10);
    l_strORDERID varchar2(30);
    l_dblQuoteQtty number(30,4);
    l_strTLID varchar2(30);
    l_dblORDERQTTY number(30,4);
    l_dblQUOTEPRICE number(20);
    l_strCLEARCD    VARCHAR2(1);
    l_dblCLEARDAY NUMBER(10);
    l_strMATCHTYPE  VARCHAR2(1);
    l_strNORK   VARCHAR2(1);
    l_strEXECTYPE   VARCHAR2(10);
    l_dblBRATIO NUMBER(10,4);
    l_strTXTIME varchar2(30);
    l_strCIACCTNO   VARCHAR2(30);
    l_strSEACCTNO   VARCHAR2(40);
    l_strAFACCTNO VARCHAR2(30);
    l_strCODEID VARCHAR2(10);
    l_strACTYPE varchar2(10);
    mv_strAFACTYPE varchar2(10);
    l_strCUSTID VARCHAR2(20);
    l_strBRID varchar2(6);
    l_strCUSTODYCD varchar2(20);
    l_strSYMBOL varchar2(50);
    l_count number(10);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    l_exectype := p_txmsg.txfields(c_exectype).value;
    l_dblQuoteQtty := p_txmsg.txfields(c_qtty).value;
    l_strTLID := p_txmsg.tlid;
    l_dblORDERQTTY := p_txmsg.txfields(c_qtty).value;
    l_strCLEARCD := 'B';
    l_dblCLEARDAY := p_txmsg.txfields(c_clearday).value;
    l_strMATCHTYPE := 'P';
    l_strNORK := 'N';
    l_strEXECTYPE := p_txmsg.txfields(c_exectype).value;
    l_dblBRATIO := 100;
    l_strTXTIME :=p_txmsg.TXTIME;
    l_strCIACCTNO := p_txmsg.txfields(c_afacctno).value;
    l_strAFACCTNO := p_txmsg.txfields(c_afacctno).value;
    l_strCODEID := p_txmsg.txfields(c_codeid).value;
    l_strSEACCTNO := l_strAFACCTNO || l_strCODEID;
    l_strBRID := p_txmsg.brid;
    l_strCUSTODYCD := p_txmsg.txfields(c_custodycd).value;
    l_strSYMBOL:='';
    SELECT SYMBOL into l_strSYMBOL FROM SBSECURITIES WHERE CODEID = l_strCODEID ;
    SELECT ACTYPE, CUSTID INTO mv_strAFACTYPE, l_strCUSTID FROM AFMAST WHERE ACCTNO = l_strAFACCTNO;
    BEGIN
        select actype into l_strACTYPE from vw_odmast_all od where od.orderid = p_txmsg.txfields('14').value;
    EXCEPTION WHEN OTHERS THEN
        l_strACTYPE := '0000';
    END ;

    IF l_dblQuoteQtty <> 0 THEN
        l_dblQUOTEPRICE := ROUND(p_txmsg.txfields(c_amt).value/l_dblQuoteQtty,0);
    ELSE
        select MAX(basicprice) INTO l_dblQUOTEPRICE from securities_info where CODEID = p_txmsg.txfields(c_codeid).value;
    END IF;

/*    SELECT SUBSTR(l_strBRID,1,4) || TO_CHAR(TO_DATE (varvalue, 'DD\MM\RR'),'DDMMRR') || LPAD (seq_odmast.NEXTVAL, 6, '0')
        INTO l_strORDERID
    FROM sysvar WHERE varname ='CURRDATE' AND grname='SYSTEM';*/

    l_strORDERID:= p_txmsg.txfields('19').value;


    if p_txmsg.deltd <> 'Y' then
        select count(*) into l_count from bondrepo where ORDERID = l_strORDERID and leg = 'V';
        if l_count < 1 then
            INSERT INTO ODMAST (ORDERID,CUSTID,ACTYPE,CODEID,AFACCTNO,SEACCTNO,CIACCTNO,
                             TXNUM,TXDATE,TXTIME,EXPDATE,BRATIO,TIMETYPE,
                             EXECTYPE,NORK,MATCHTYPE,VIA,CLEARDAY,CLEARCD,ORSTATUS,PORSTATUS,PRICETYPE,
                             QUOTEPRICE,STOPPRICE,LIMITPRICE,ORDERQTTY,REMAINQTTY,EXPRICE,EXQTTY,SECUREDAMT,
                             EXECQTTY,STANDQTTY,CANCELQTTY,ADJUSTQTTY,REJECTQTTY,REJECTCD,VOUCHER,
                             CONSULTANT,FOACCTNO,PUTTYPE,CONTRAORDERID,CONTRAFRM, TLID,SSAFACCTNO,QUOTEQTTY,PTDEAL,ADVIDREF)
             VALUES ( l_strORDERID , l_strCUSTID , l_strACTYPE , l_strCODEID , l_strAFACCTNO , l_strSEACCTNO , l_strCIACCTNO
                             , p_txmsg.txnum ,TO_DATE( p_txmsg.txdate ,  systemnums.C_DATE_FORMAT ), l_strTXTIME
                             ,TO_DATE( p_txmsg.txdate ,  systemnums.C_DATE_FORMAT ), l_dblBRATIO , 'T'
                             , l_strEXECTYPE , l_strNORK , l_strMATCHTYPE , 'F'
                             , l_dblCLEARDAY , l_strCLEARCD ,'2','2', 'LO'
                             , l_dblQUOTEPRICE ,0, l_dblQUOTEPRICE , l_dblORDERQTTY , l_dblORDERQTTY , l_dblQUOTEPRICE ,
                             l_dblORDERQTTY ,0,0,0,0,0,0,'001', NULL, NULL , null , 'O' ,
                             null , null, l_strTLID,NULL ,l_dblQuoteQtty,NULL,0);
            --Ghi nhan vao OOD 24 18 13 12
            INSERT INTO OOD (ORGORDERID,CODEID,SYMBOL,CUSTODYCD,
                             BORS,NORP,AORN,PRICE,QTTY,SECUREDRATIO,OODSTATUS,TXDATE,TXNUM,DELTD,BRID)
            VALUES ( l_strORDERID , l_strCODEID , l_strSYMBOL , l_strCUSTODYCD ,SUBSTR(l_strEXECTYPE,2,1), l_strMATCHTYPE
                             , l_strNORK , l_dblQUOTEPRICE , l_dblORDERQTTY , l_dblBRATIO ,'S',TO_DATE( p_txmsg.txdate ,  systemnums.C_DATE_FORMAT ), p_txmsg.txnum ,'N', l_strBRID );

            MATCHING_NORMAL_ORDER_REPO(l_strORDERID, l_dblORDERQTTY, l_dblQUOTEPRICE,p_txmsg.txfields(c_amt).value,p_txmsg.txfields(c_feeamt).value);

            INSERT INTO bondrepo (ORDERID,REPOACCTNO,TXDATE,BUSDATE1,TERM,ENDDATE,BUSDATE2,INTERRESTRATE,AMT2,PARTNER,DESCRIPTION,
                    REFREPOACCTNO,STATUS,leg,qtty,amt1,FEEAMT)
                VALUES (l_strORDERID, to_char(p_txmsg.txdate,'ddmmrrrr') || p_txmsg.txnum,
                    TO_DATE(p_txmsg.txdate,systemnums.C_DATE_FORMAT),TO_DATE(p_txmsg.txfields('10').value,systemnums.C_DATE_FORMAT),0,NULL,NULL, 0,0,
                    NULL,p_txmsg.txfields('30').value,p_txmsg.txfields('13').value,'C','V',l_dblORDERQTTY,
                    p_txmsg.txfields(c_amt).value, p_txmsg.txfields(c_feeamt).value);

            update bondrepo set REFREPOACCTNO = to_char(p_txmsg.txdate,'ddmmrrrr') || p_txmsg.txnum, status = 'C'
            where REPOACCTNO = p_txmsg.txfields('13').value;
        end if;
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
         plog.init ('TXPKS_#2210EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#2210EX;

/
