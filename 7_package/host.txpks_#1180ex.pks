SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#1180ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#1180EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      21/10/2010     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#1180ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_custodycd        CONSTANT CHAR(2) := '88';
   c_acctno           CONSTANT CHAR(2) := '03';
   c_custname         CONSTANT CHAR(2) := '90';
   c_address          CONSTANT CHAR(2) := '91';
   c_license          CONSTANT CHAR(2) := '92';
   c_iddate           CONSTANT CHAR(2) := '98';
   c_idplace          CONSTANT CHAR(2) := '99';
   c_cidepofeeacr     CONSTANT CHAR(2) := '66';
   c_avlcash          CONSTANT CHAR(2) := '89';
   c_amt              CONSTANT CHAR(2) := '10';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
       l_feeacr  number;
BEGIN
   plog.setbeginsection (pkgctx, 'fn_txPreAppCheck');
   plog.debug(pkgctx,'BEGIN OF fn_txPreAppCheck');

     select ceil(nmlamt-nvl(paidamt,0)) into l_feeacr
     from CIFEESCHD where AUTOID = p_txmsg.txfields('00').value;

     IF (to_number(p_txmsg.txfields('10').value) > l_feeacr) THEN
        p_err_code := '-401180';
        RETURN errnums.C_BIZ_RULE_INVALID;
     END IF;
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
v_dblAMT NUMBER(20,4);
l_count NUMBER(20);
v_strAfAcctno VARCHAR2(10);
v_strTODATE VARCHAR2(50);
v_dblFEEAMT  NUMBER(20,4);
v_amt_temp      NUMBER(20,4);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txPreAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txPreAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC PROCESS HERE. . DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
     v_dblAMT:=to_number(p_txmsg.txfields('10').value);
    v_strAfAcctno:=p_txmsg.txfields('03').value;
    v_strTODATE:=p_txmsg.txfields('06').value;
    if(v_dblAMT>0) THEN
       if( p_txmsg.deltd <> 'Y') THEN
           /*SELECT COUNT(*) INTO l_count from cifeeschd
           WHERE  DELTD<>'Y' AND AFACCTNO=v_strAfAcctno
           AND TODATE=TO_DATE(v_strTODATE,'DD/MM/RRRR');

           if(L_count >0) THEN
                SELECT SUM(NMLAMT-PAIDAMT-FLOATAMT) INTO v_dblFEEAMT FROM cifeeschd
                WHERE  DELTD<>'Y' AND AFACCTNO=v_strAfAcctno
                AND TODATE=TO_DATE(v_strTODATE,'DD/MM/RRRR');
           ELSE
            --Th?b?kh?t?th?y ti?u kho?n d? thu ph?
                  p_err_code:='-400014';
                  plog.setendsection (pkgctx, 'fn_txPreAppCheck');
                  RETURN errnums.C_BIZ_RULE_INVALID;
           END IF;
               v_amt_temp := v_dblAMT;
            for rec in (
                 SELECT * FROM  CIFEESCHD WHERE  DELTD<>'Y' AND AFACCTNO=V_STRAFACCTNO
                AND TODATE=TO_DATE(V_STRTODATE,'DD/MM/RRRR'))
             loop
                 if v_amt_temp <=  rec.nmlamt - rec.paidamt then
                  update CIFEESCHD set paidamt  = paidamt + v_amt_temp,
                   paidtxdate=p_txmsg.busdate, paidtxnum=p_txmsg.txnum where autoid = rec.autoid ;
                   v_amt_temp:=0;
                 else
                   v_amt_temp := v_amt_temp - ( rec.nmlamt - rec.paidamt);
                  update CIFEESCHD set paidamt  = rec.nmlamt ,
                   paidtxdate=p_txmsg.busdate, paidtxnum=p_txmsg.txnum where autoid = rec.autoid ;

                 end if ;
                   exit when v_amt_temp <=0;
             end loop ;*/
             update CIFEESCHD set paidamt = paidamt + v_dblAMT,
                   paidtxdate=p_txmsg.busdate, paidtxnum=p_txmsg.txnum where autoid = p_txmsg.txfields('00').value;
       ELSE -- xoa jao dich
          UPDATE CIFEESCHD SET PAIDAMT = paidamt- v_dblAMT,
            paidtxnum='', paidtxdate=''
          WHERE autoid = p_txmsg.txfields('00').value;
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

BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/

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
         plog.init ('TXPKS_#1180EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#1180EX;
/
