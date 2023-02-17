SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#8840ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#8840EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      19/09/2011     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#8840ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_orderid          CONSTANT CHAR(2) := '01';
   c_custodycd        CONSTANT CHAR(2) := '02';
   c_afacctno         CONSTANT CHAR(2) := '03';
   c_desc             CONSTANT CHAR(2) := '30';
   c_matchqtty        CONSTANT CHAR(2) := '05';
   c_orderqtty        CONSTANT CHAR(2) := '06';
   c_matchvalue       CONSTANT CHAR(2) := '07';
   c_txdate           CONSTANT CHAR(2) := '08';
   c_cleardate        CONSTANT CHAR(2) := '09';
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
    l_nbrClearQtty number(23);
    l_nbrClearAmt number(23);
    l_vchrTxNum  varchar2(10);
    l_vchrOrderId varchar2(20);
    l_dtTxDate date;
    l_vchrAfAcctno varchar2(10);
    l_vchrCodeId varchar2(10);
    l_nbrIsMortgageSell number(2);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    l_vchrOrderId := p_txmsg.txfields('01').value;
    l_dtTxDate := to_date(p_txmsg.txfields('08').value,'dd/mm/yyyy');

	-- xoa gd khop lenh(8804)
	SELECT      log.txnum
	INTO        l_vchrTxNum
	FROM        vw_tllog_all log, vw_tllogfld_all logfld
	WHERE       log.txnum = logfld.txnum
				AND log.txdate = logfld.txdate
				AND log.tltxcd in ('8804','8809')
				AND logfld.fldcd = '03'
				AND logfld.cvalue = l_vchrOrderId
				AND log.txdate = l_dtTxDate;

	UPDATE      tllog
	SET         deltd = 'Y'
	WHERE       txnum = l_vchrTxNum
				AND txdate = l_dtTxDate;

	UPDATE      tllogall
	SET         deltd = 'Y'
	WHERE       txnum = l_vchrTxNum
				AND txdate = l_dtTxDate;

	UPDATE      citran
	SET         deltd = 'Y'
	WHERE       txnum = l_vchrTxNum
				AND txdate = l_dtTxDate;

	UPDATE      citrana
	SET         deltd = 'Y'
	WHERE       txnum = l_vchrTxNum
				AND txdate = l_dtTxDate;

	UPDATE      citran_gen
	SET         deltd = 'Y'
	WHERE       txnum = l_vchrTxNum
				AND txdate = l_dtTxDate;

	UPDATE      setran
	SET         deltd = 'Y'
	WHERE       txnum = l_vchrTxNum
				AND txdate = l_dtTxDate;

	UPDATE      setrana
	SET         deltd = 'Y'
	WHERE       txnum = l_vchrTxNum
				AND txdate = l_dtTxDate;

	UPDATE      setran_gen
	SET         deltd = 'Y'
	WHERE       txnum = l_vchrTxNum
				AND txdate = l_dtTxDate;

	UPDATE      odtran
	SET         deltd = 'Y'
	WHERE       txnum = l_vchrTxNum
				AND txdate = l_dtTxDate;

	UPDATE      odtrana
	SET         deltd = 'Y'
	WHERE       txnum = l_vchrTxNum
				AND txdate = l_dtTxDate;

	UPDATE		ODMAST
	SET			ORSTATUS = 2, REMAINQTTY = REMAINQTTY + EXECQTTY, EXECQTTY = 0, EXECAMT = 0, MATCHAMT = 0
	WHERE		ORDERID = l_vchrOrderId;

	-- xoa TTBT
    for i in (select * from stschd where orgorderid = l_vchrOrderId and status = 'C')
    loop
        l_dtTxDate := i.txdate;
        l_vchrAfAcctno := i.afacctno;
        l_vchrCodeId := i.codeid;
        --l_dtTxDate := i.cleardate;

        if i.duetype = 'SM' then
        -- xoa gd 8865
            SELECT      log.txnum
            INTO        l_vchrTxNum
            FROM        tllogall log, tllogfldall logfld
            WHERE       log.txnum = logfld.txnum
                        AND log.txdate = logfld.txdate
                        AND log.tltxcd = '8865'
                        AND logfld.fldcd = '03'
                        AND logfld.cvalue = l_vchrOrderId
                        AND log.txdate = l_dtTxDate;

            SELECT      nvalue
            INTO        l_nbrClearAmt
            FROM        tllogfldall
            WHERE       txnum = l_vchrTxNum
                        AND txdate = l_dtTxDate
                        AND fldcd = '11';

            SELECT      nvalue
            INTO        l_nbrClearQtty
            FROM        tllogfldall
            WHERE       txnum = l_vchrTxNum
                        AND txdate = l_dtTxDate
                        AND fldcd = '09';
            /*
            UPDATE      cimast
            SET         netting = netting - l_nbrClearAmt, trfamt = trfamt - l_nbrClearAmt, balance = balance + l_nbrClearAmt
            WHERE       afacctno = l_vchrAfAcctno;

            UPDATE      semast
            SET         receiving = receiving - l_nbrClearQtty
            WHERE       acctno = l_vchrAfAcctno || l_vchrCodeId;
            */
        elsif i.duetype = 'SS' then
        -- xoa 8867
            SELECT      log.txnum
            INTO        l_vchrTxNum
            FROM        tllogall log, tllogfldall logfld
            WHERE       log.txnum = logfld.txnum
                        AND log.txdate = logfld.txdate
                        AND log.tltxcd = '8867'
                        AND logfld.fldcd = '03'
                        AND logfld.cvalue = l_vchrOrderId
                        AND log.txdate = l_dtTxDate;

            SELECT      nvalue
            INTO        l_nbrClearAmt
            FROM        tllogfldall
            WHERE       txnum = l_vchrTxNum
                        AND txdate = l_dtTxDate
                        AND fldcd = '08';

            SELECT      nvalue
            INTO        l_nbrClearQtty
            FROM        tllogfldall
            WHERE       txnum = l_vchrTxNum
                        AND txdate = l_dtTxDate
                        AND fldcd = '11';

            SELECT      nvalue
            INTO        l_nbrIsMortgageSell
            FROM        tllogfldall
            WHERE       txnum = l_vchrTxNum
                        AND txdate = l_dtTxDate
                        AND fldcd = '60';
                        /*
            UPDATE      cimast
            SET         receiving = receiving - l_nbrClearAmt
            WHERE       afacctno = l_vchrAfAcctno;

            UPDATE      semast
            SET         trade = trade + (l_nbrClearQtty - l_nbrClearQtty*l_nbrIsMortgageSell),
                        netting = netting - l_nbrClearQtty,
                        prevqtty = prevqtty - l_nbrClearQtty,
                        mortage = mortage + l_nbrClearQtty*l_nbrIsMortgageSell
            WHERE       acctno = l_vchrAfAcctno || l_vchrCodeId;
            */
        end if;

        UPDATE      tllogall
        SET         deltd = 'Y'
        WHERE       txnum = l_vchrTxNum
                    AND txdate = l_dtTxDate;

        UPDATE      citrana
        SET         deltd = 'Y'
        WHERE       txnum = l_vchrTxNum
                    AND txdate = l_dtTxDate;

        UPDATE      citran_gen
        SET         deltd = 'Y'
        WHERE       txnum = l_vchrTxNum
                    AND txdate = l_dtTxDate;

        UPDATE      setrana
        SET         deltd = 'Y'
        WHERE       txnum = l_vchrTxNum
                    AND txdate = l_dtTxDate;

        UPDATE      setran_gen
        SET         deltd = 'Y'
        WHERE       txnum = l_vchrTxNum
                    AND txdate = l_dtTxDate;

        UPDATE      odmast
        SET         stsstatus = 'N'
        WHERE       orderid = l_vchrOrderId;
    end loop;

	UPDATE		STSCHD
	SET			deltd = 'Y'
	WHERE		ORGORDERID = l_vchrOrderId;

    plog.debug (pkgctx, '<<END OF fn_txAftAppUpdate');
    plog.setendsection (pkgctx, 'fn_txAftAppUpdate');
    RETURN systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
   THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.error (pkgctx, DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
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
         plog.init ('TXPKS_#8840EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#8840EX;
/
