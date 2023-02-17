SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#2649ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#2649EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      18/04/2012     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#2649ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_groupid          CONSTANT CHAR(2) := '20';
   c_dfacctno         CONSTANT CHAR(2) := '25';
   c_acctno           CONSTANT CHAR(2) := '05';
   c_custodycd        CONSTANT CHAR(2) := '88';
   c_afacctno         CONSTANT CHAR(2) := '03';
   c_codeid           CONSTANT CHAR(2) := '01';
   c_dfqtty           CONSTANT CHAR(2) := '41';
   c_cacashqtty       CONSTANT CHAR(2) := '45';
   c_blockqtty        CONSTANT CHAR(2) := '44';
   c_rcvqtty          CONSTANT CHAR(2) := '42';
   c_carcvqtty        CONSTANT CHAR(2) := '43';
   c_dealtype         CONSTANT CHAR(2) := '55';
   c_limitcheck       CONSTANT CHAR(2) := '99';
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
   l_ReleaseQTTY number;
    v_dblCARCVQTTY number;
    v_dblRCVQTTY number;
    v_dblBLOCKQTTY number;
    v_dblAVLQTTY NUMBER;
    v_dblCACASHQTTY number;
    v_dblRemainRCVQTTY number;
    v_dblExecRCVQTTY NUMBER;
    v_dblReleaseAMT NUMBER;
    l_DFACCTNO varchar2(20);
    l_AFACCTNO varchar2(20);
    l_GROUPID  varchar2(20);
    l_INTPAIDMETHOD varchar2(1);
    l_DEALTYPE VARCHAR2(1);
    l_DFREF varchar2(500);
    l_CODEID varchar2(6);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/


        v_dblCARCVQTTY:=p_txmsg.txfields('43').VALUE;
        v_dblRCVQTTY:=p_txmsg.txfields('42').VALUE;
        v_dblAVLQTTY:=p_txmsg.txfields('41').VALUE;
        v_dblBLOCKQTTY:=p_txmsg.txfields('44').VALUE;
        v_dblCACASHQTTY:=p_txmsg.txfields('45').VALUE;
        l_DFACCTNO:= p_txmsg.txfields('25').VALUE;
        l_AFACCTNO:= p_txmsg.txfields('03').VALUE;
        l_CODEID:= p_txmsg.txfields('01').VALUE;
        l_DEALTYPE:= p_txmsg.txfields('55').VALUE;
        l_ReleaseQTTY:= ROUND(p_txmsg.txfields('41').value+p_txmsg.txfields('42').value+p_txmsg.txfields('43').value+p_txmsg.txfields('44').value+p_txmsg.txfields('45').value,0);


        IF p_txmsg.deltd <> 'Y' THEN -- normal transactions
            UPDATE securities_info
            SET SYROOMUSED=NVL(SYROOMUSED,0)- l_ReleaseQTTY
            WHERE CODEID= l_codeid;
        ELSE -- reverse transactions
            UPDATE securities_info
            SET SYROOMUSED=NVL(SYROOMUSED,0)+ l_ReleaseQTTY
            WHERE CODEID= l_codeid;
        END IF;

/*        INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_DFACCTNO,'0043',v_dblBLOCKQTTY,NULL,l_AFACCTNO,p_txmsg.deltd,l_AFACCTNO,seq_DFTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

        INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_DFACCTNO,'0045',v_dblCARCVQTTY,NULL,l_AFACCTNO,p_txmsg.deltd,l_AFACCTNO,seq_DFTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

        INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_DFACCTNO,'0087',v_dblCACASHQTTY,NULL,l_AFACCTNO,p_txmsg.deltd,l_AFACCTNO,seq_DFTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

        INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_DFACCTNO,'0041',v_dblRCVQTTY,NULL,l_AFACCTNO,p_txmsg.deltd,l_AFACCTNO,seq_DFTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

        INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_DFACCTNO,'0011',v_dblAVLQTTY,NULL,l_AFACCTNO,p_txmsg.deltd,l_AFACCTNO,seq_DFTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

        INSERT INTO DFTRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
        VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_DFACCTNO,'0016',v_dblCACASHQTTY,NULL,l_AFACCTNO,p_txmsg.deltd,l_AFACCTNO,seq_DFTRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');
*/

         SELECT DFREF INTO l_DFREF FROM DFMAST WHERE ACCTNO= L_DFACCTNO;

         IF  l_DEALTYPE = 'T' THEN

               INSERT INTO CITRAN (TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,REF,DELTD,ACCTREF,AUTOID,TLTXCD,BKDATE,TRDESC)
               VALUES(p_txmsg.txnum,TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),l_AFACCTNO,'0046',l_ReleaseQTTY,NULL,NULL,'N',NULL,SEQ_CITRAN.NEXTVAL,'2646',TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),NULL);

               UPDATE caschd set dfamt= dfamt - (ROUND(l_ReleaseQTTY,0)) where autoid=l_DFREF;
               UPDATE CIMAST set receiving= receiving + (ROUND(l_ReleaseQTTY,0)) where ACCTNO=l_AFACCTNO;

         END IF;

         if l_DEALTYPE = 'P' THEN
               UPDATE caschd set dfqtty= dfqtty - ROUND(l_ReleaseQTTY,0) where autoid=l_DFREF;
         elsif l_DEALTYPE = 'R' then

                 --- Chung khoan cho ve
                v_dblRemainRCVQTTY:= v_dblRCVQTTY;
                v_dblExecRCVQTTY:=0;
                v_dblReleaseAMT:=0;
                FOR rec_rcvdf IN
                (
                SELECT * FROM stschd WHERE (to_char(txdate,'DD/MM/YYYY') || afacctno || codeid || to_char(clearday)) = l_DFREF
                and duetype ='RS' and status <> 'C' AND deltd <> 'Y'
                order BY autoid
                )
                LOOP
                    v_dblExecRCVQTTY:= least(v_dblRemainRCVQTTY, rec_rcvdf.AQTTY);
                    update odmast set dfqtty = dfqtty - v_dblExecRCVQTTY where orderid = rec_rcvdf.ORGORDERID;
                    update stschd set aqtty = aqtty - v_dblExecRCVQTTY where autoid = rec_rcvdf.autoid;
                    v_dblRemainRCVQTTY:= v_dblRemainRCVQTTY - v_dblExecRCVQTTY;
                    If v_dblRemainRCVQTTY = 0 Then
                        EXIT;
                    End IF;
                END LOOP;

         else

               INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
               VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_AFACCTNO||l_CODEID,'0043',v_dblBLOCKQTTY,NULL,l_DFACCTNO,p_txmsg.deltd,l_DFACCTNO,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

               INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
               VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_AFACCTNO||l_CODEID,'0012',v_dblAVLQTTY,NULL,l_DFACCTNO,p_txmsg.deltd,l_DFACCTNO,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

               INSERT INTO SETRAN(TXNUM,TXDATE,ACCTNO,TXCD,NAMT,CAMT,ACCTREF,DELTD,REF,AUTOID,TLTXCD,BKDATE,TRDESC)
               VALUES (p_txmsg.txnum, TO_DATE (p_txmsg.txdate, systemnums.C_DATE_FORMAT),l_AFACCTNO||l_CODEID,'0066',v_dblAVLQTTY+v_dblBLOCKQTTY,NULL,l_DFACCTNO,p_txmsg.deltd,l_DFACCTNO,seq_SETRAN.NEXTVAL,p_txmsg.tltxcd,p_txmsg.busdate,'' || '' || '');

               UPDATE SEMAST SET
                   BLOCKED = BLOCKED + v_dblBLOCKQTTY,
                   TRADE = TRADE + v_dblAVLQTTY,
                   MORTAGE = MORTAGE - (v_dblAVLQTTY+v_dblBLOCKQTTY), LAST_CHANGE = SYSTIMESTAMP
               WHERE ACCTNO=l_AFACCTNO||l_CODEID;

         end if;




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
         plog.init ('TXPKS_#2649EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#2649EX;
/
