SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#2267ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#2267EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      08/06/2015     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#2267ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_codeid           CONSTANT CHAR(2) := '01';
   c_trade            CONSTANT CHAR(2) := '20';
   c_mortage          CONSTANT CHAR(2) := '12';
   c_blocked          CONSTANT CHAR(2) := '29';
   c_emkqtty          CONSTANT CHAR(2) := '49';
   c_standing         CONSTANT CHAR(2) := '15';
   c_withdraw         CONSTANT CHAR(2) := '16';
   c_deposit          CONSTANT CHAR(2) := '17';
   c_senddeposit      CONSTANT CHAR(2) := '32';
   c_dtoclose         CONSTANT CHAR(2) := '35';
   c_blockwithdraw    CONSTANT CHAR(2) := '47';
   c_blockdtoclose    CONSTANT CHAR(2) := '48';
   c_parvalue         CONSTANT CHAR(2) := '11';
   c_price            CONSTANT CHAR(2) := '09';
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
   L_TXMSG       TX.MSG_RECTYPE;
    V_STRCURRDATE VARCHAR2(20);
    V_STRPREVDATE VARCHAR2(20);
    V_STRNEXTDATE VARCHAR2(20);
    V_STRDESC     VARCHAR2(1000);
    L_ERR_PARAM   VARCHAR2(300);
    L_MAXROW      NUMBER(20, 0);
    V_COMPANYCD   VARCHAR2(10);
    L_ISMARGIN    VARCHAR2(1);
    L_COUNT       NUMBER(20);
    L_ROOMREMAIN  NUMBER(20);
    L_BLOCKEDAVL  NUMBER(20);
    L_TRADEAVL    NUMBER(20);
    P_BCHMDL     VARCHAR2(300);
    l_afacctno   VARCHAR2(300);
    l_sectype    VARCHAR2(300);
    l_custid     VARCHAR2(300);
l_codeid          VARCHAR2(300);
   --   PKGCTX PLOG.LOG_CTX;
  --LOGROW TLOGDEBUG%ROWTYPE;
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/

        PLOG.SETBEGINSECTION(PKGCTX, 'pr_CaWatingfortrade');
    P_BCHMDL := 'CAW';
    P_ERR_CODE:=0;
    V_COMPANYCD := CSPKS_SYSTEM.FN_GET_SYSVAR('SYSTEM', 'COMPANYCD');

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
    L_TXMSG.TLTXCD    := '2262';

    FOR REC IN (

    SELECT SB.PARVALUE,
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
                       TRADE,
                       MORTAGE,
                       MARGIN,
                       NETTING,
                       STANDING,
                       WITHDRAW,
                       DEPOSIT,
                       LOAN,
                       BLOCKED,
                       RECEIVING,
                       TRANSFER,
                       SENDDEPOSIT,
                       SENDPENDING,
                       DTOCLOSE,
                       SDTOCLOSE,
                       EMKQTTY,
                       BLOCKWITHDRAW,
                       BLOCKDTOCLOSE
                  FROM SEMAST          SE,
                       AFMAST          AF,
                       CFMAST          CF,
                       SBSECURITIES    SB,
                       SBSECURITIES    SBWFT,
                       SECURITIES_INFO SEINFO
                 WHERE SE.AFACCTNO = AF.ACCTNO
                   AND AF.CUSTID = CF.CUSTID
                   AND SB.CODEID = SEINFO.CODEID
                   AND SE.CODEID = SBWFT.CODEID
                   AND SBWFT.REFCODEID = SB.CODEID
                   AND SBWFT.TRADEPLACE = '006'
                   AND TRADE + MORTAGE + STANDING + WITHDRAW + DEPOSIT +
                       BLOCKED + SENDDEPOSIT + DTOCLOSE + EMKQTTY +
                       BLOCKWITHDRAW + BLOCKDTOCLOSE > 0
                   and   SB.CODEID= p_txmsg.txfields('01').value

                ) LOOP


    SELECT count(*) INTO l_count
    FROM SEMAST
    WHERE ACCTNO= REC.SEACCTNOCR;


  IF l_count = 0 THEN
         l_afacctno := substr(REC.SEACCTNOCR,1,10);
         l_codeid := substr(REC.SEACCTNOCR,11);
         BEGIN
             SELECT b.setype,a.custid
             INTO l_sectype,l_custid
             FROM AFMAST A, aftype B
             WHERE  A.actype= B.actype
             AND a.ACCTNO = l_afacctno;
         EXCEPTION
             WHEN NO_DATA_FOUND THEN
             p_err_code := errnums.C_CF_REGTYPE_NOT_FOUND;
             RAISE errnums.E_CF_REGTYPE_NOT_FOUND;
         END;


         INSERT INTO SEMAST
         (ACTYPE,CUSTID,ACCTNO,CODEID,AFACCTNO,OPNDATE,LASTDATE,COSTDT,TBALDT,STATUS,IRTIED,IRCD,
         COSTPRICE,TRADE,MORTAGE,MARGIN,NETTING,STANDING,WITHDRAW,DEPOSIT,LOAN)
         VALUES(
         l_sectype, l_custid,REC.SEACCTNOCR,l_codeid,l_afacctno,
         TO_DATE(  p_txmsg.txdate , systemnums.C_DATE_FORMAT ),TO_DATE(  p_txmsg.txdate ,   systemnums.C_DATE_FORMAT ),
         TO_DATE(  p_txmsg.txdate , systemnums.C_DATE_FORMAT ),TO_DATE(  p_txmsg.txdate ,   systemnums.C_DATE_FORMAT ),
         'A','Y','000', 0,0,0,0,0,0,0,0,0);
    END IF;


      --Set txnum
      SELECT SYSTEMNUMS.C_BATCH_PREFIXED ||
             LPAD(SEQ_BATCHTXNUM.NEXTVAL, 8, '0')
        INTO L_TXMSG.TXNUM
        FROM DUAL;
      L_TXMSG.BRID := SUBSTR(REC.AFACCTNO, 1, 4);

      --Set cac field giao dich
      --01   N   CODEID
      L_TXMSG.TXFIELDS('01').DEFNAME := 'CODEID';
      L_TXMSG.TXFIELDS('01').TYPE := 'N';
      L_TXMSG.TXFIELDS('01').VALUE := REC.CODEID;
      --02   C   AFACCTNO
      L_TXMSG.TXFIELDS('02').DEFNAME := 'AFACCTNO';
      L_TXMSG.TXFIELDS('02').TYPE := 'C';
      L_TXMSG.TXFIELDS('02').VALUE := REC.AFACCTNO;
      --03   C   SEACCTNODR
      L_TXMSG.TXFIELDS('03').DEFNAME := 'SEACCTNODR';
      L_TXMSG.TXFIELDS('03').TYPE := 'C';
      L_TXMSG.TXFIELDS('03').VALUE := REC.SEACCTNODR;
      --04   C   CUSTODYCD
      L_TXMSG.TXFIELDS('04').DEFNAME := 'CUSTODYCD';
      L_TXMSG.TXFIELDS('04').TYPE := 'C';
      L_TXMSG.TXFIELDS('04').VALUE := REC.CUSTODYCD;
      --05   C   SEACCTNOCR
      L_TXMSG.TXFIELDS('05').DEFNAME := 'SEACCTNOCR';
      L_TXMSG.TXFIELDS('05').TYPE := 'C';
      L_TXMSG.TXFIELDS('05').VALUE := REC.SEACCTNOCR;
      --09   C   PRICE
      L_TXMSG.TXFIELDS('09').DEFNAME := 'PRICE';
      L_TXMSG.TXFIELDS('09').TYPE := 'N';
      L_TXMSG.TXFIELDS('09').VALUE := REC.PRICE;
      --10   N   TRADE
      L_TXMSG.TXFIELDS('10').DEFNAME := 'TRADE';
      L_TXMSG.TXFIELDS('10').TYPE := 'N';
      L_TXMSG.TXFIELDS('10').VALUE := REC.TRADE;
      --11   N   PARVALUE
      L_TXMSG.TXFIELDS('11').DEFNAME := 'PARVALUE';
      L_TXMSG.TXFIELDS('11').TYPE := 'N';
      L_TXMSG.TXFIELDS('11').VALUE := REC.PARVALUE;
      --12   N   MORTAGE
      L_TXMSG.TXFIELDS('12').DEFNAME := 'MORTAGE';
      L_TXMSG.TXFIELDS('12').TYPE := 'N';
      L_TXMSG.TXFIELDS('12').VALUE := REC.MORTAGE;

      --14   N   NETTING
      L_TXMSG.TXFIELDS('14').DEFNAME := 'NETTING';
      L_TXMSG.TXFIELDS('14').TYPE := 'N';
      L_TXMSG.TXFIELDS('14').VALUE := REC.NETTING;

      --15   N   STANDING
      L_TXMSG.TXFIELDS('15').DEFNAME := 'STANDING';
      L_TXMSG.TXFIELDS('15').TYPE := 'N';
      L_TXMSG.TXFIELDS('15').VALUE := REC.STANDING;
      --16   N   WITHDRAW
      L_TXMSG.TXFIELDS('16').DEFNAME := 'WITHDRAW';
      L_TXMSG.TXFIELDS('16').TYPE := 'N';
      L_TXMSG.TXFIELDS('16').VALUE := REC.WITHDRAW;

      --17   N   DEPOSIT
      L_TXMSG.TXFIELDS('17').DEFNAME := 'DEPOSIT';
      L_TXMSG.TXFIELDS('17').TYPE := 'N';
      L_TXMSG.TXFIELDS('17').VALUE := REC.DEPOSIT;

      --19   N   BLOCKED
      L_TXMSG.TXFIELDS('19').DEFNAME := 'BLOCKED';
      L_TXMSG.TXFIELDS('19').TYPE := 'N';
      L_TXMSG.TXFIELDS('19').VALUE := REC.BLOCKED;

      --20   N   RECEIVING
      L_TXMSG.TXFIELDS('20').DEFNAME := 'RECEIVING';
      L_TXMSG.TXFIELDS('20').TYPE := 'N';
      L_TXMSG.TXFIELDS('20').VALUE := REC.RECEIVING;

      --21   N   TRANSFER
      L_TXMSG.TXFIELDS('21').DEFNAME := 'TRANSFER';
      L_TXMSG.TXFIELDS('21').TYPE := 'N';
      L_TXMSG.TXFIELDS('21').VALUE := REC.TRANSFER;

      --22   N   SENDDEPOSIT
      L_TXMSG.TXFIELDS('22').DEFNAME := 'SENDDEPOSIT';
      L_TXMSG.TXFIELDS('22').TYPE := 'N';
      L_TXMSG.TXFIELDS('22').VALUE := REC.SENDDEPOSIT;

      --23   N   SENDPENDING
      L_TXMSG.TXFIELDS('23').DEFNAME := 'SENDPENDING';
      L_TXMSG.TXFIELDS('23').TYPE := 'N';
      L_TXMSG.TXFIELDS('23').VALUE := REC.SENDPENDING;

      --25   C   DTOCLOSE
      L_TXMSG.TXFIELDS('25').DEFNAME := 'DTOCLOSE';
      L_TXMSG.TXFIELDS('25').TYPE := 'N';
      L_TXMSG.TXFIELDS('25').VALUE := REC.DTOCLOSE;

      --26   C   EMKQTTY
      L_TXMSG.TXFIELDS('26').DEFNAME := 'EMKQTTY';
      L_TXMSG.TXFIELDS('26').TYPE := 'N';
      L_TXMSG.TXFIELDS('26').VALUE := REC.EMKQTTY;

      --27   C   BLOCKWITHDRAW
      L_TXMSG.TXFIELDS('27').DEFNAME := 'BLOCKWITHDRAW';
      L_TXMSG.TXFIELDS('27').TYPE := 'N';
      L_TXMSG.TXFIELDS('27').VALUE := REC.BLOCKWITHDRAW;

      --25   C   BLOCKDTOCLOSE
      L_TXMSG.TXFIELDS('28').DEFNAME := 'BLOCKDTOCLOSE';
      L_TXMSG.TXFIELDS('28').TYPE := 'N';
      L_TXMSG.TXFIELDS('28').VALUE := REC.BLOCKDTOCLOSE;

      --44   N   PARVALUE
      L_TXMSG.TXFIELDS('30').DEFNAME := 'DESC';
      L_TXMSG.TXFIELDS('30').TYPE := 'C';
      L_TXMSG.TXFIELDS('30').VALUE := UTF8NUMS.C_CONST_TLTX_TXDESC_2262;

      --90   N   CUSTNAME
      L_TXMSG.TXFIELDS('90').DEFNAME := 'CUSTNAME';
      L_TXMSG.TXFIELDS('90').TYPE := 'C';
      L_TXMSG.TXFIELDS('90').VALUE := REC.FULLNAME;

      --91   N   ADDRESS
      L_TXMSG.TXFIELDS('91').DEFNAME := 'ADDRESS';
      L_TXMSG.TXFIELDS('91').TYPE := 'N';
      L_TXMSG.TXFIELDS('91').VALUE := REC.ADDRESS;

      --53   N   LICENSE
      L_TXMSG.TXFIELDS('92').DEFNAME := 'LICENSE';
      L_TXMSG.TXFIELDS('92').TYPE := 'C';
      L_TXMSG.TXFIELDS('92').VALUE := REC.IDCODE;
      BEGIN
        IF TXPKS_#2262.FN_BATCHTXPROCESS(L_TXMSG, P_ERR_CODE, L_ERR_PARAM) <>
           SYSTEMNUMS.C_SUCCESS THEN
          PLOG.ERROR (PKGCTX, 'got error 2262: ' || P_ERR_CODE ||REC.AFACCTNO);
          ROLLBACK;
         RETURN p_err_code;
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
         plog.init ('TXPKS_#2267EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#2267EX;

/
