SET DEFINE OFF;
CREATE OR REPLACE PACKAGE TXPKS_#1126EX
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#1126EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      15/09/2011     Created
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


CREATE OR REPLACE PACKAGE BODY TXPKS_#1126EX
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_custodycd        CONSTANT CHAR(2) := '87';
   c_afacctno         CONSTANT CHAR(2) := '04';
   c_crintacr         CONSTANT CHAR(2) := '10';
   c_decrease         CONSTANT CHAR(2) := '11';
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
l_count NUMBER(20);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txPreAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txPreAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC PROCESS HERE. . DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    IF p_txmsg.deltd = 'Y' THEN
      SELECT COUNT(*) INTO l_count FROM cimast
      WHERE ACCTNO=p_txmsg.txfields('04').value
      AND CIDEPOFEEACR < ROUND(p_txmsg.txfields('11').value,4);
      IF l_count > 0 THEN
        p_err_code := '-400212';
        RETURN errnums.C_BIZ_RULE_INVALID;
      END IF;
    END IF;
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
v_acctno VARCHAR2(10);
v_cidepofeeacr NUMBER (20,4);
v_blnReversal boolean;
l_icrate NUMBER;
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
     if p_txmsg.deltd='Y' then
        v_blnReversal:=true;
    else
        v_blnReversal:=false;
    end if;
     v_acctno:= p_txmsg.txfields(c_afacctno).value;
     v_cidepofeeacr:= p_txmsg.txfields(c_decrease).value;
     /* SELECT icdef.ICFLAT INTO l_icrate FROM  cimast ci, citype typ,iccftypedef icdef
        WHERE ci.actype=typ.actype AND typ.actype=icdef.actype AND icdef.modcode='CI'
        AND icdef.EVENTCODE='FEEDEPOSITSE' AND ci.acctno=v_acctno; */
         BEGIN
      SELECT icdef.ICFLAT INTO l_icrate FROM  cimast ci, citype typ,iccftypedef icdef
        WHERE ci.actype=typ.actype AND typ.actype=icdef.actype AND icdef.modcode='CI'
        AND icdef.EVENTCODE='FEEDEPOSITSE' AND ci.acctno=v_acctno;
      EXCEPTION WHEN OTHERS THEN
        l_icrate:=0;
      END;
   /* If Not v_blnREVERSAL THEN


   \*  insert into cidepofeetran(AUTOID,	AFACCTNO,	FRDATE,	TODATE,	DEPOQTTY,	DEPORATE,	DEPOTYPE,	CIDEPOFEEACR)
               select seq_cidepofeetran.nextval autoid, mt.acctno afacctno, TO_DATE( p_txmsg.txdate ,'DD/MM/RRRR' ) frdate, TO_DATE( p_txmsg.txdate ,'DD/MM/RRRR' ) todate,
                      mt.depoqtty, l_icrate deporate, 'C' depotype,v_cidepofeeacr cidepofeeacr
               from (select ci.acctno, sum(se.trade + se.margin + se.mortage + se.blocked + se.secured + se.repo + se.netting + se.dtoclose + se.withdraw) depoqtty

                         from   semast se, sbsecurities sb, cimast ci
                         WHERE ci.acctno = se.afacctno
                              and se.codeid = sb.codeid
                              and sb.sectype in ('001','002','007','008','009')
                              and sb.tradeplace in ('001','002','005')
                              AND ci.acctno=v_acctno
                         group by ci.acctno
                       ) mt;*\
  -- ELSE
     -- xoa jao dich
\*     insert into cidepofeetran(AUTOID,	AFACCTNO,	FRDATE,	TODATE,	DEPOQTTY,	DEPORATE,	DEPOTYPE,	CIDEPOFEEACR)
               select seq_cidepofeetran.nextval autoid, mt.acctno afacctno, TO_DATE( p_txmsg.txdate ,'DD/MM/RRRR' ) frdate, TO_DATE( p_txmsg.txdate ,'DD/MM/RRRR' ) todate,
                      mt.depoqtty, mt.deporate, 'C' depotype,-v_cidepofeeacr cidepofeeacr
               from (select ci.acctno, sum(se.trade + se.margin + se.mortage + se.blocked + se.secured + se.repo + se.netting + se.dtoclose + se.withdraw) depoqtty,
                         icdef.icflat  deporate
                         from   semast se, sbsecurities sb, cimast ci, citype typ,iccftypedef icdef
                         WHERE ci.acctno = se.afacctno
                              and se.codeid = sb.codeid
                              and sb.sectype in ('001','002','007','008','009')
                              and sb.tradeplace in ('001','002','005')
                              AND ci.actype=typ.actype
                              AND typ.actype=icdef.actype and icdef.modcode ='CI' and eventcode='FEEDEPOSITSE'

                         group by ci.acctno
                       ) mt;*\
     END IF;*/
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
         plog.init ('TXPKS_#1126EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#1126EX;

/
