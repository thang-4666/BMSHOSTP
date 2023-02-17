SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#5221ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#5221EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      04/01/2017     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#5221ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_custodycd        CONSTANT CHAR(2) := '88';
   c_acctno           CONSTANT CHAR(2) := '03';
   c_address          CONSTANT CHAR(2) := '91';
   c_license          CONSTANT CHAR(2) := '92';
   c_iddate           CONSTANT CHAR(2) := '93';
   c_idplace          CONSTANT CHAR(2) := '94';
   c_amt              CONSTANT CHAR(2) := '10';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
l_CLAMTLIMIT NUMBER ;
l_amt number;
l_SCLAMTLIMIT NUMBER ;
l_SDCLAMTLIMIT NUMBER ;
l_scldisb NUMBER ;
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
SELECT clamt-cldisb-clwith INTO l_CLAMTLIMIT FROM cldeallog WHERE DELTD <>'Y' AND AUTOID = p_txmsg.txfields('01').value ;


SELECT dclamtlimit INTO l_SDCLAMTLIMIT FROM V_GETSECMARGINRATIO  WHERE afacctno = p_txmsg.txfields('03').value;
SELECT clamtlimit INTO l_SCLAMTLIMIT FROM AFMAST  WHERE acctno = p_txmsg.txfields('03').value;

IF p_txmsg.deltd <>'Y' THEN
    l_amt := p_txmsg.txfields('10').value;

     IF  l_CLAMTLIMIT < l_amt THEN
        p_err_code := '-570355';
        RETURN errnums.C_BIZ_RULE_INVALID;
     END IF;

--neu rut han muc ngan hang phan con l?i khong duoc  qua phan da su dung
    IF  l_SCLAMTLIMIT -  l_amt < l_SDCLAMTLIMIT AND  p_txmsg.txfields('44').value ='001' THEN
        p_err_code := '-570355';
        RETURN errnums.C_BIZ_RULE_INVALID;
     END IF;
-- neu rut han muc do nh giai ngan khong duoc qua phan da su dung
  IF   l_amt > l_SDCLAMTLIMIT AND  p_txmsg.txfields('44').value ='000' THEN
        p_err_code := '-570356';
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
l_CLAMTLIMIT NUMBER ;
l_amt number;
l_SCLAMTLIMIT NUMBER ;
l_SDCLAMTLIMIT NUMBER ;
l_scldisb NUMBER ;
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/

    SELECT clamt-cldisb-clwith INTO l_CLAMTLIMIT FROM cldeallog WHERE DELTD <>'Y' AND AUTOID = p_txmsg.txfields('01').value ;

SELECT dclamtlimit INTO l_SDCLAMTLIMIT FROM V_GETSECMARGINRATIO  WHERE afacctno = p_txmsg.txfields('03').value;
SELECT clamtlimit INTO l_SCLAMTLIMIT FROM AFMAST  WHERE acctno = p_txmsg.txfields('03').value;


 IF p_txmsg.deltd <>'Y' THEN
   l_amt := p_txmsg.txfields('10').value;
   IF  l_CLAMTLIMIT < l_amt THEN

          p_err_code := '-570355';
        RETURN errnums.C_BIZ_RULE_INVALID;
     END IF;

         l_amt := p_txmsg.txfields('10').value;

     IF  l_CLAMTLIMIT < l_amt THEN
        p_err_code := '-570355';
        RETURN errnums.C_BIZ_RULE_INVALID;
     END IF;

--neu rut han muc ngan hang phan con l?i khong duoc  qua phan da su dung
    IF  l_SCLAMTLIMIT  < l_SDCLAMTLIMIT AND  p_txmsg.txfields('44').value ='001' THEN
          p_err_code := '-570355';
        RETURN errnums.C_BIZ_RULE_INVALID;
     END IF;
-- neu rut han muc do nh giai ngan khong duoc qua phan da su dung
  IF   0 > l_SDCLAMTLIMIT AND  p_txmsg.txfields('44').value ='000' THEN
        p_err_code := '-570356';
        RETURN errnums.C_BIZ_RULE_INVALID;
     END IF;

 UPDATE cldeallog SET cldisb=cldisb+ DECODE ( p_txmsg.txfields('44').value,'000', to_number(p_txmsg.txfields('10').value),0) WHERE AUTOID = p_txmsg.txfields('01').value;
 UPDATE cldeallog SET clwith=clwith+ DECODE ( p_txmsg.txfields('44').value,'001', to_number(p_txmsg.txfields('10').value),0) WHERE AUTOID = p_txmsg.txfields('01').value;
 ELSE
 UPDATE cldeallog SET cldisb=cldisb- DECODE ( p_txmsg.txfields('44').value,'000', to_number(p_txmsg.txfields('10').value),0) WHERE AUTOID = p_txmsg.txfields('01').value;
 UPDATE cldeallog SET clwith=clwith- DECODE ( p_txmsg.txfields('44').value,'001', to_number(p_txmsg.txfields('10').value),0) WHERE AUTOID = p_txmsg.txfields('01').value;
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
         plog.init ('TXPKS_#5221EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#5221EX;
/
