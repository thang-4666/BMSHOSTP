SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#3392ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#3392EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      02/11/2010     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#3392ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_camastid         CONSTANT CHAR(2) := '06';
   c_codeid           CONSTANT CHAR(2) := '01';
   c_custodycd        CONSTANT CHAR(2) := '36';
   c_acctno           CONSTANT CHAR(2) := '03';
   c_dacctno          CONSTANT CHAR(2) := '02';
   c_custname         CONSTANT CHAR(2) := '90';
   c_address          CONSTANT CHAR(2) := '91';
   c_license          CONSTANT CHAR(2) := '92';
   c_iddate           CONSTANT CHAR(2) := '93';
   c_idplace          CONSTANT CHAR(2) := '94';
   c_custodycd        CONSTANT CHAR(2) := '38';
   c_cacctno          CONSTANT CHAR(2) := '04';
   c_acct2            CONSTANT CHAR(2) := '05';
   c_custname2        CONSTANT CHAR(2) := '95';
   c_address2         CONSTANT CHAR(2) := '96';
   c_license2         CONSTANT CHAR(2) := '97';
   c_iddate2          CONSTANT CHAR(2) := '98';
   c_idplace2         CONSTANT CHAR(2) := '99';
   c_amt              CONSTANT CHAR(2) := '21';
   c_symbol           CONSTANT CHAR(2) := '35';
   c_desc             CONSTANT CHAR(2) := '30';
   c_issname          CONSTANT CHAR(2) := '79';
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
l_CODEID varchar2(10);
l_OPTCODEID varchar2(10);
l_ACCTNO varchar2(20);
l_CAMASTID varchar2(20);
l_DAFACCTNO VARCHAR2 (30);
l_CAFACCTNO VARCHAR2 (30);
l_Qtty number;
l_CARcvQtty NUMBER;
l_TotalCAQtty NUMBER;
l_TotalCAPQtty NUMBER;
l_refid NUMBER;
l_count NUMBER;
l_rcasautoid NUMBER;
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
    l_OPTCODEID := p_txmsg.txfields('01').VALUE;
    l_Qtty := p_txmsg.txfields('21').VALUE;
    l_CAMASTID:= p_txmsg.txfields('06').VALUE;

    l_DAFACCTNO := p_txmsg.txfields('02').VALUE;
    l_CAFACCTNO := p_txmsg.txfields('04').VALUE;
    l_refid:= p_txmsg.txfields('31').VALUE;
    SELECT RCASCHDID INTO l_rcasautoid
    FROM catransfer
    WHERE autoid=l_refid;

    BEGIN
        SELECT pbalance, codeid INTO l_TotalCAPQtty, l_CODEID
        FROM caschd
        WHERE camastid = l_CAMASTID AND afacctno = l_CAFACCTNO and excodeid = l_OPTCODEID
        AND deltd='N' AND autoid=l_rcasautoid;
    EXCEPTION WHEN OTHERS THEN
        l_TotalCAPQtty:=0;
    END;
plog.error('l_CODEID:'||l_CODEID);
plog.error('l_AFACCTNO:'||l_CAFACCTNO);
plog.error('l_CAMASTID:'||l_CAMASTID);
plog.error('l_Qtty:'||l_Qtty);
plog.error('l_TotalCAPQtty:'||l_TotalCAPQtty);
    IF l_Qtty > nvl(l_TotalCAPQtty,0)  THEN
        p_err_code := '-300034'; -- Pre-defined in DEFERROR table
        plog.setendsection (pkgctx, 'fn_txAftAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;

    BEGIN
        SELECT sum(carcvqtty) INTO l_CARcvQtty
        FROM dfmast
        WHERE codeid = l_CODEID AND afacctno = l_CAFACCTNO GROUP BY codeid, afacctno;
    EXCEPTION WHEN OTHERS THEN
        l_CARcvQtty:=0;
    END;
/*plog.error('l_CARcvQtty:'||l_CARcvQtty);
    BEGIN
        SELECT balance INTO l_TotalCAQtty
        FROM caschd
        WHERE camastid = l_CAMASTID AND afacctno = l_CAFACCTNO and codeid = l_CODEID;
    EXCEPTION WHEN OTHERS THEN
        l_TotalCAQtty:=0;
    END;*/
/*plog.error('l_TotalCAQtty:'||l_TotalCAQtty);
    IF l_Qtty > nvl(l_TotalCAQtty,0) THEN
        p_err_code := '-300034'; -- Pre-defined in DEFERROR table
        plog.setendsection (pkgctx, 'fn_txAftAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    END IF;*/

    SELECT count(1) INTO l_count FROM catransfer
    WHERE camastid = l_CAMASTID AND amt = l_Qtty AND status = 'N' AND autoid = l_refid;
    IF l_count = 0 THEN
        p_err_code := '-300034'; -- Pre-defined in DEFERROR table
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
v_strCODEID varchar2(10);
v_strACCTNO varchar2(20);
v_strDAFACCTNO varchar2(20);
v_strCAFACCTNO varchar2(20);
v_strcamastid varchar2(20);
v_nAMT number;
v_txnum varchar2(20);
V_txdate date;
v_RIGHTOFRATE number;
v_LEFTOFRATE number;
v_ROUNDTYPE number;
v_EXPRICE number;
v_refid NUMBER;
isDiffCust NUMBER;
l_inamt NUMBER;
l_retailbal NUMBER;
l_sendinamt NUMBER;
L_sendretailbal NUMBER;
l_rcaschid NUMBER;

BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/

v_strCODEID := p_txmsg.txfields('01').VALUE;
v_strDAFACCTNO := p_txmsg.txfields('02').VALUE;
v_strCAFACCTNO := p_txmsg.txfields('04').VALUE;
v_nAMT := p_txmsg.txfields('21').VALUE;
v_txnum:= p_txmsg.txnum;
V_txdate:= p_txmsg.txdate;
v_strcamastid:= p_txmsg.txfields('06').VALUE;
v_refid:= p_txmsg.txfields('31').VALUE;

 SELECT inamt,retailbal,sendinamt,sendretailbal,RCASCHDID INTO l_inamt,l_retailbal,l_sendinamt,l_sendretailbal,l_rcaschid
 FROM catransfer
    WHERE camastid = v_strCAMASTID AND amt = v_nAMT AND status = 'N' AND autoid = v_refid;


SELECT   SUBSTR( rightoffrate,INSTR(rightoffrate,'/')+1 ) , SUBSTR( rightoffrate,1 ,INSTR(rightoffrate,'/')-1 ) ,ROUNDTYPE,EXPRICE
INTO v_RIGHTOFRATE,v_LEFTOFRATE,v_ROUNDTYPE,v_EXPRICE
FROM camast where camastid =v_strcamastid ;
-- xet xem co pai dung so LK ko
 if(p_txmsg.txfields(36).value=p_txmsg.txfields(38).value) THEN
         isDiffCust:= 0;
           ELSE
              isDiffCust:= 1;
             END IF;

 IF p_txmsg.deltd <> 'Y' THEN

 UPDATE CASCHD  SET PBALANCE = PBALANCE + v_nAMT  ,RETAILBAL= RETAILBAL + l_sendretailbal ,
 outbalance=outbalance-v_nAMT,inbalance=inbalance+l_sendinamt,
 PQTTY = TRUNC( FLOOR(( (PBALANCE +  v_nAMT  ) * v_RIGHTOFRATE ) / v_LEFTOFRATE )  , v_ROUNDTYPE ) ,
 PAAMT=  v_EXPRICE  * TRUNC(  FLOOR(( ( PBALANCE +v_nAMT ) *  v_RIGHTOFRATE)  /  v_LEFTOFRATE ) ,v_ROUNDTYPE )

 WHERE AFACCTNO =v_strDAFACCTNO  AND camastid =  v_strCAMASTID  and  deltd <> 'Y' AND autoid= p_txmsg.txfields('09').VALUE;

 UPDATE CASCHD  SET PBALANCE = PBALANCE - v_nAMT  ,INBALANCE=INBALANCE-l_inamt,
 RETAILBAL= RETAILBAL - l_retailbal ,
 PQTTY = TRUNC( FLOOR(( (PBALANCE -  v_nAMT  ) * v_RIGHTOFRATE ) / v_LEFTOFRATE )  , v_ROUNDTYPE ) ,
 PAAMT=  v_EXPRICE  * TRUNC(  FLOOR(( ( PBALANCE - v_nAMT ) *  v_RIGHTOFRATE)  /  v_LEFTOFRATE ) ,v_ROUNDTYPE )
 WHERE AFACCTNO =v_strCAFACCTNO  AND camastid =  v_strCAMASTID  and  deltd <> 'Y' AND autoid=l_rcaschid;

 UPDATE catransfer SET status = 'Y'
 WHERE autoid = v_refid;
 -- update ref trong setran la caschd.autoid nhan chuyen nhuong de len bao cao
 UPDATE setran SET ref=l_rcaschid,acctref=l_rcaschid
 WHERE txnum=p_txmsg.txnum AND txdate=p_txmsg.txdate
 AND acctno= p_txmsg.txfields('05').VALUE;

else

 UPDATE CASCHD  SET PBALANCE = PBALANCE - v_nAMT  ,RETAILBAL= RETAILBAL - l_sendretailbal ,
  outbalance=outbalance+v_nAMT,inbalance=inbalance-l_sendinamt,
 PQTTY = TRUNC( FLOOR(( (PBALANCE -  v_nAMT  ) * v_RIGHTOFRATE ) / v_LEFTOFRATE )  , v_ROUNDTYPE ) ,
 PAAMT=  v_EXPRICE  * TRUNC(  FLOOR(( ( PBALANCE -v_nAMT ) *  v_RIGHTOFRATE)  /  v_LEFTOFRATE ) ,v_ROUNDTYPE )
 WHERE AFACCTNO =v_strDAFACCTNO  AND camastid =  v_strCAMASTID  and  deltd <> 'Y' AND autoid= p_txmsg.txfields('09').VALUE;

 UPDATE CASCHD  SET PBALANCE = PBALANCE + v_nAMT  ,INBALANCE=INBALANCE+l_inamt,
 RETAILBAL= RETAILBAL + l_retailbal ,
 PQTTY = TRUNC( FLOOR(( (PBALANCE +  v_nAMT  ) * v_RIGHTOFRATE ) / v_LEFTOFRATE )  , v_ROUNDTYPE ) ,
 PAAMT=  v_EXPRICE  * TRUNC(  FLOOR(( ( PBALANCE + v_nAMT ) *  v_RIGHTOFRATE)  /  v_LEFTOFRATE ) ,v_ROUNDTYPE )
 WHERE AFACCTNO =v_strCAFACCTNO  AND camastid =  v_strCAMASTID  and  deltd <> 'Y' AND autoid=l_rcaschid;

 UPDATE catransfer SET status = 'N'
 WHERE autoid = v_refid;

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
         plog.init ('TXPKS_#3392EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#3392EX;

/
