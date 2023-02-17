SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#3315ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#3315EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      20/01/2015     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#3315ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_camastid         CONSTANT CHAR(2) := '03';
   c_codeid           CONSTANT CHAR(2) := '16';
   c_symbol           CONSTANT CHAR(2) := '04';
   c_catypeval        CONSTANT CHAR(2) := '09';
   c_catype           CONSTANT CHAR(2) := '05';
   c_tocodeid         CONSTANT CHAR(2) := '40';
   c_begindate        CONSTANT CHAR(2) := '02';
   c_duedate          CONSTANT CHAR(2) := '01';
   c_reportdate       CONSTANT CHAR(2) := '06';
   c_frdatetransfer   CONSTANT CHAR(2) := '12';
   c_todatetransfer   CONSTANT CHAR(2) := '13';
   c_actiondate       CONSTANT CHAR(2) := '07';
   c_rate             CONSTANT CHAR(2) := '10';
   c_rightoffrate     CONSTANT CHAR(2) := '11';
   c_trade            CONSTANT CHAR(2) := '23';
   c_tvprice          CONSTANT CHAR(2) := '15';
   c_roprice          CONSTANT CHAR(2) := '14';
   c_status           CONSTANT CHAR(2) := '20';
   c_tradedate        CONSTANT CHAR(2) := '18';
   c_desc             CONSTANT CHAR(2) := '30';
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
      plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
      plog.setendsection (pkgctx, 'fn_txPreAppCheck');
      RAISE errnums.E_SYSTEM_ERROR;
END fn_txPreAppCheck;

FUNCTION fn_txAftAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
L_COUNT NUMBER(20);
L_COUNT1 NUMBER(20);
L_ISWFT VARCHAR2(10);
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

   /* SELECT COUNT(*) INTO L_COUNT FROm CASCHD WHERE CAMASTID=P_TXMSG.TXFIELDS('03').VALUE
    AND DELTD <> 'Y' AND STATUS <> 'W';*/
    SELECT COUNT(*) INTO L_COUNT1 FROM CAMAST WHERE CAMASTID=P_TXMSG.TXFIELDS('03').VALUE
    AND DELTD <> 'Y' AND STATUS IN ('P','N','C','W');
    IF  L_COUNT1=1 THEN
        p_err_code := '-300014';
        plog.setendsection (pkgctx, 'fn_txAftAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;
    SELECT ISWFT INTO L_ISWFT FROM CAMAST WHERE CAMASTID=P_TXMSG.TXFIELDS('03').VALUE;
    IF L_ISWFT<> 'Y' THEN
        p_err_code := '-300073';
        plog.setendsection (pkgctx, 'fn_txAftAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;
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
L_TXMSG       TX.MSG_RECTYPE;
 V_STRCURRDATE VARCHAR2(20);
 V_STRDESC VARCHAR2(500);
 P_BCHMDL  VARCHAR2(500);
 L_ERR_PARAM   VARCHAR2(300);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    UPDATE CAMAST SET TRADEDATE=TO_DATE(P_TXMSG.TXFIELDS('18').VALUE,'DD/MM/RRRR')
    WHERE  CAMASTID=P_TXMSG.TXFIELDS('03').VALUE;

    P_BCHMDL :='CAW';

    SELECT TO_DATE(VARVALUE, SYSTEMNUMS.C_DATE_FORMAT)
      INTO V_STRCURRDATE
      FROM SYSVAR
     WHERE GRNAME = 'SYSTEM'
       AND VARNAME = 'CURRDATE';

    L_TXMSG.MSGTYPE := 'T';
    L_TXMSG.LOCAL   := 'N';
    L_TXMSG.TLID    := SYSTEMNUMS.C_SYSTEM_USERID;
    SELECT SYS_CONTEXT('USERENV', 'HOST'),
           SYS_CONTEXT('USERENV', 'IP_ADDRESS', 15)
      INTO L_TXMSG.WSNAME, L_TXMSG.IPADDRESS
      FROM DUAL;
    L_TXMSG.OFF_LINE  := 'N';
    L_TXMSG.DELTD     := TXNUMS.C_DELTD_TXNORMAL;
    L_TXMSG.TXSTATUS  := TXSTATUSNUMS.C_TXCOMPLETED;
    L_TXMSG.MSGSTS    := '0';
    L_TXMSG.OVRSTS    := '0';
    L_TXMSG.BATCHNAME := P_BCHMDL;
    L_TXMSG.TXDATE    := TO_DATE(V_STRCURRDATE, SYSTEMNUMS.C_DATE_FORMAT);
    L_TXMSG.BUSDATE   := TO_DATE(V_STRCURRDATE, SYSTEMNUMS.C_DATE_FORMAT);

    L_TXMSG.TLTXCD := '3356';
    SELECT TXDESC INTO V_STRDESC FROM TLTX WHERE TLTXCD = '3356';
    FOR REC IN (

                SELECT MST.*, SE.QTTY, (SE.QTTY - REALQTTY) DIFFQTTY
                  FROM (SELECT MAX(MSTAUTOID) AUTOID,
                                CAMASTID,
                                MAX(DESCRIPTION) DESCRIPTION,
                                MAX(TYPE) TYPE,
                                MAX(TRADEDATE) TRADEDATE,
                                MAX(PARVALUE) PARVALUE,
                                MAX(PRICE) PRICE,
                                SUM(TRADE) TRADE,
                                SUM(BLOCKED) BLOCKED,
                                MAX(CODEID) CODEID,
                                MAX(SYMBOL) SYMBOL,
                                MAX(CATYPE) CATYPE,
                                SUM(CAQTTY) CAQTTY,
                                SUM(REALQTTY) REALQTTY,
                                MAX(CODEIDWFT) CODEIDWFT
                           FROM (SELECT CAMAST.AUTOID MSTAUTOID,
                                        CA.AUTOID,
                                        CAMAST.CAMASTID,
                                        CAMAST.DESCRIPTION,
                                        '001' TYPE,
                                        CAMAST.TRADEDATE,
                                        SB.PARVALUE,
                                        SE.COSTPRICE PRICE,
                                        CF.CUSTODYCD,
                                        CF.CUSTID,
                                        AF.ACCTNO AFACCTNO,
                                        SB.CODEID,
                                        CF.FULLNAME,
                                        CF.IDCODE,
                                        CF.ADDRESS,
                                        SB.SYMBOL,
                                        SE.STATUS,
                                        AF.ACCTNO || SB.CODEID SEACCTNOCR,
                                        AF.ACCTNO || SBWFT.CODEID SEACCTNODR,
                                        LEAST(CA.QTTY, SE.TRADE) TRADE,
                                        (CASE
                                          WHEN (CA.QTTY > SE.TRADE) THEN
                                           LEAST((CA.QTTY - SE.TRADE), SE.BLOCKED)
                                          ELSE
                                           0
                                        END) BLOCKED,
                                        A1.CDCONTENT CATYPE,
                                        CA.QTTY CAQTTY,
                                        (LEAST(CA.QTTY, SE.TRADE) + (CASE
                                          WHEN (CA.QTTY > SE.TRADE) THEN
                                           LEAST((CA.QTTY - SE.TRADE), SE.BLOCKED)
                                          ELSE
                                           0
                                        END)) REALQTTY,
                                        SBWFT.CODEID CODEIDWFT,
                                        CAMAST.ISINCODE
                                   FROM VW_CAMAST_ALL   CAMAST,
                                        VW_CASCHD_ALL   CA,
                                        SEMAST          SE,
                                        AFMAST          AF,
                                        CFMAST          CF,
                                        SBSECURITIES    SB,
                                        SBSECURITIES    SBWFT,
                                        SECURITIES_INFO SEINFO,
                                        ALLCODE         A1
                                  WHERE CAMAST.CAMASTID = CA.CAMASTID
                                    AND CAMAST.ISWFT = 'Y'
                                    AND CA.ISSE = 'Y'
                                    AND NVL(CAMAST.TOCODEID, CAMAST.CODEID) =
                                        SB.CODEID
                                    AND CA.AFACCTNO = SE.AFACCTNO
                                    AND SE.AFACCTNO = AF.ACCTNO
                                    AND AF.CUSTID = CF.CUSTID
                                    AND SB.CODEID = SEINFO.CODEID
                                    AND SE.CODEID = SBWFT.CODEID
                                    AND SBWFT.REFCODEID = SB.CODEID /* and se.trade+se.blocked>0*/
                                    AND A1.CDVAL = CAMAST.CATYPE
                                    AND A1.CDNAME = 'CATYPE'
                                    AND A1.CDTYPE = 'CA'
                                    AND SBWFT.TRADEPLACE = '006'
                                    AND CA.STATUS IN ('C', 'S', 'G', 'H', 'J')
                                    AND INSTR(NVL(CA.PSTATUS, 'A'), 'W') <= 0
                                       -- DK DEN NGAY VA CHUA CHUYEN THANH CK GIAO DICH
                                    AND CAMAST.TRADEDATE <=
                                        TO_DATE(V_STRCURRDATE,
                                                SYSTEMNUMS.C_DATE_FORMAT)
                                    AND CAMAST.ISCHANGEWFT = 'N')
                          GROUP BY CAMASTID, ISINCODE) MST,
                        (SELECT CODEID,
                                SUM(SE2.TRADE + SE2.MORTAGE + SE2.STANDING +
                                    SE2.WITHDRAW + SE2.DEPOSIT + SE2.BLOCKED +
                                    SE2.SENDDEPOSIT + SE2.DTOCLOSE) QTTY
                           FROM SEMAST SE2
                          GROUP BY CODEID) SE
                 WHERE MST.CODEIDWFT = SE.CODEID) LOOP
      --Set txnum
      SELECT SYSTEMNUMS.C_BATCH_PREFIXED ||
             LPAD(SEQ_BATCHTXNUM.NEXTVAL, 8, '0')
        INTO L_TXMSG.TXNUM
        FROM DUAL;
      L_TXMSG.BRID := '0001';

      --Set cac field giao dich
      --03   C   camastid
      L_TXMSG.TXFIELDS('03').DEFNAME := 'CAMASTID';
      L_TXMSG.TXFIELDS('03').TYPE := 'C';
      L_TXMSG.TXFIELDS('03').VALUE := REC.CAMASTID;

      --04   C   SYMBOL
      L_TXMSG.TXFIELDS('04').DEFNAME := 'SYMBOL';
      L_TXMSG.TXFIELDS('04').TYPE := 'C';
      L_TXMSG.TXFIELDS('04').VALUE := REC.SYMBOL;

      --05   C   CATYPE
      L_TXMSG.TXFIELDS('05').DEFNAME := 'CATYPE';
      L_TXMSG.TXFIELDS('05').TYPE := 'C';
      L_TXMSG.TXFIELDS('05').VALUE := REC.CATYPE;

      --07   D   TRADEDATE
      L_TXMSG.TXFIELDS('07').DEFNAME := 'TRADEDATE';
      L_TXMSG.TXFIELDS('07').TYPE := 'D';
      L_TXMSG.TXFIELDS('07').VALUE := REC.TRADEDATE;

      --08   C   CODEID
      L_TXMSG.TXFIELDS('08').DEFNAME := 'CODEID';
      L_TXMSG.TXFIELDS('08').TYPE := 'C';
      L_TXMSG.TXFIELDS('08').VALUE := REC.CODEID;

      --09   C   PRICE
      L_TXMSG.TXFIELDS('09').DEFNAME := 'PRICE';
      L_TXMSG.TXFIELDS('09').TYPE := 'N';
      L_TXMSG.TXFIELDS('09').VALUE := REC.PRICE;

      --10   N   TRADE
      L_TXMSG.TXFIELDS('10').DEFNAME := 'TRADE';
      L_TXMSG.TXFIELDS('10').TYPE := 'N';
      L_TXMSG.TXFIELDS('10').VALUE := REC.TRADE;

      --13   C   CODEID
      L_TXMSG.TXFIELDS('13').DEFNAME := 'CONTENTS';
      L_TXMSG.TXFIELDS('13').TYPE := 'C';
      L_TXMSG.TXFIELDS('13').VALUE := REC.DESCRIPTION;

      --10   N   TRADE
      L_TXMSG.TXFIELDS('19').DEFNAME := 'BLOCKED';
      L_TXMSG.TXFIELDS('19').TYPE := 'N';
      L_TXMSG.TXFIELDS('19').VALUE := REC.BLOCKED;

      --20   N   REALQTTY
      L_TXMSG.TXFIELDS('20').DEFNAME := 'REALQTTY';
      L_TXMSG.TXFIELDS('20').TYPE := 'N';
      L_TXMSG.TXFIELDS('20').VALUE := REC.REALQTTY;

      --21   N   CAQTTY
      L_TXMSG.TXFIELDS('21').DEFNAME := 'CAQTTY';
      L_TXMSG.TXFIELDS('21').TYPE := 'N';
      L_TXMSG.TXFIELDS('21').VALUE := REC.CAQTTY;

      --10   N   QTTY
      L_TXMSG.TXFIELDS('22').DEFNAME := 'QTTY';
      L_TXMSG.TXFIELDS('22').TYPE := 'N';
      L_TXMSG.TXFIELDS('22').VALUE := REC.QTTY;

      --23   N   DIFFQTTY
      L_TXMSG.TXFIELDS('23').DEFNAME := 'DIFFQTTY';
      L_TXMSG.TXFIELDS('23').TYPE := 'N';
      L_TXMSG.TXFIELDS('23').VALUE := REC.DIFFQTTY;

      --44   N   PARVALUE
      L_TXMSG.TXFIELDS('30').DEFNAME := 'DESC';
      L_TXMSG.TXFIELDS('30').TYPE := 'C';
      L_TXMSG.TXFIELDS('30').VALUE := V_STRDESC;

      BEGIN
        IF TXPKS_#3356.FN_BATCHTXPROCESS(L_TXMSG, P_ERR_CODE, L_ERR_PARAM) <>
           SYSTEMNUMS.C_SUCCESS THEN
          PLOG.DEBUG(PKGCTX, 'got error 3356: ' || P_ERR_CODE);
          ROLLBACK;
        --  RETURN;
        END IF;
      END;
    END LOOP;

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
         plog.init ('TXPKS_#3315EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#3315EX;

/
