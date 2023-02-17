SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#3327ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#3327EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      10/07/2012     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#3327ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_autoid           CONSTANT CHAR(2) := '01';
   c_camastid         CONSTANT CHAR(2) := '02';
   c_custodycd        CONSTANT CHAR(2) := '96';
   c_afacctno         CONSTANT CHAR(2) := '03';
   c_fullname         CONSTANT CHAR(2) := '08';
   c_symbol           CONSTANT CHAR(2) := '04';
   c_tocodeid         CONSTANT CHAR(2) := '21';
   c_codeid           CONSTANT CHAR(2) := '24';
   c_tosymbol         CONSTANT CHAR(2) := '05';
   c_qtty             CONSTANT CHAR(2) := '10';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
l_count NUMBER;
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
    SELECT COUNT(*) INTO l_count
    FROM caschd
    WHERE autoid=p_txmsg.txfields('01').value AND status='V'
    AND pqtty>= to_number(p_txmsg.txfields('10').value);

    if l_count <= 0 then
                p_err_code:='-300063';
                plog.setendsection(pkgctx, 'fn_txPreAppCheck');
                RETURN errnums.C_BIZ_RULE_INVALID;
    END if;
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
l_qtty NUMBER;
l_exrate VARCHAR2(50);
l_autoid NUMBER;
l_camastid VARCHAR2(30);
l_balance NUMBER;
l_roundcitype NUMBER;
l_parvalue NUMBER;
l_balance NUMBER;
l_left_exrate NUMBER;
l_right_exrate NUMBER;
l_interestrate NUMBER;
l_count NUMBER;
l_codeid VARCHAR2(20);
l_afacctno VARCHAR2(20);
l_sectype  VARCHAR2(20);
l_custid  VARCHAR2(20);
l_costprice  NUMBER;

BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    l_qtty:=to_number(p_txmsg.txfields('10').value);
    l_autoid:=to_number(p_txmsg.txfields('01').value);
    l_camastid:=p_txmsg.txfields('02').value;
    l_codeid:=p_txmsg.txfields('21').value;
    l_afacctno:=p_txmsg.txfields('03').value;

    select costprice into l_costprice from semast where afacctno = l_afacctno and codeid = p_txmsg.txfields('24').value;

    SELECT count(*) INTO l_count
    FROM SEMAST
    WHERE afACCTNO = l_afacctno and codeid = l_codeid;
    IF l_count = 0 THEN
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
         VALUES(l_sectype, l_custid, l_afacctno||l_codeid,l_codeid,l_afacctno,
         TO_DATE(p_txmsg.txdate , systemnums.C_DATE_FORMAT ),TO_DATE(  p_txmsg.txdate ,   systemnums.C_DATE_FORMAT ),
         TO_DATE(p_txmsg.txdate , systemnums.C_DATE_FORMAT ),TO_DATE(  p_txmsg.txdate ,   systemnums.C_DATE_FORMAT ),
         'A','Y','000', 0,0,0,0,0,0,0,0,0);
    END IF;
    l_count := 0;

    SELECT exrate ,ciroundtype,parvalue,interestrate/100
    INTO l_exrate,l_roundcitype,l_parvalue,l_interestrate
    FROM camast
    WHERE camastid=l_camastid;

    l_left_exrate := to_number(substr(l_exrate,0,instr(l_exrate,'/') - 1));
    l_right_exrate := to_number(substr(l_exrate,instr(l_exrate,'/') + 1,length(l_exrate)));
    if(p_txmsg.deltd <> 'Y') THEN-- chieu xuoi jao dich

         UPDATE caschd
         SET qtty=qtty+l_qtty,pqtty=pqtty-l_qtty,
         balance=trunc((trade-(qtty+l_qtty)*l_left_exrate/l_right_exrate),l_roundcitype),
         amt=round(trunc((trade-(qtty+l_qtty)*l_left_exrate/l_right_exrate),l_roundcitype)* (1+l_interestrate)*l_parvalue),
         intamt=round(trunc((trade-(qtty+l_qtty)*l_left_exrate/l_right_exrate),l_roundcitype)* (l_interestrate)*l_parvalue)
         WHERE autoid=l_autoid;

      INSERT INTO CATRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
      VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_autoid,'0058',l_qtty,'',p_txmsg.deltd,'',seq_CATRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');


      UPDATE SEMAST SET dcrqtty = dcrqtty+l_qtty, dcramt = dcramt+(l_qtty*l_costprice)  WHERE AFACCTNO = l_afacctno and codeid = l_codeid;
      INSERT INTO focaschd (CAMASTID,QTTY,STATUS,AFACCTNO,CODEID,DELTD,REPORTDATE,ACTIONDATE)
      VALUES(l_camastid,l_qtty,'N',l_afacctno,l_codeid,'N',TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),NULL);

    ELSE -- xoa jao dich
      SELECT COUNT(*) INTO l_count
      FROM caschd
      WHERE autoid=l_autoid AND qtty >=l_qtty
      AND status='V';
      if(l_count<=0) THEN
          p_err_code:='-300064';
          plog.setendsection(pkgctx, 'fn_txPreAppCheck');
          RETURN errnums.C_BIZ_RULE_INVALID;
      ELSE
           UPDATE caschd
           SET qtty=qtty-l_qtty,pqtty=pqtty+l_qtty,
           balance=trunc((trade-(qtty-l_qtty)*l_left_exrate/l_right_exrate),l_roundcitype),
           amt=round(trunc((trade-(qtty-l_qtty)*l_left_exrate/l_right_exrate),l_roundcitype)* (1+l_interestrate)*l_parvalue),
           intamt=round(trunc((trade-(qtty-l_qtty)*l_left_exrate/l_right_exrate),l_roundcitype)* (l_interestrate)*l_parvalue)
           WHERE autoid=l_autoid;
            UPDATE CATRAN
            SET DELTD = 'Y'
            WHERE TXNUM = p_txmsg.txnum AND TXDATE = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT);
      END IF;
      UPDATE SEMAST SET dcrqtty = dcrqtty-l_qtty, dcramt = dcramt-(l_qtty*l_costprice) WHERE AFACCTNO = l_afacctno and codeid = l_codeid;
       UPDATE focaschd SET DELTD = 'Y' WHERE CAMASTID = l_camastid AND AFACCTNO = l_afacctno AND CODEID = l_codeid;
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
         plog.init ('TXPKS_#3327EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#3327EX;

/
