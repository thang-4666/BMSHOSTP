SET DEFINE OFF;
CREATE OR REPLACE PACKAGE TXPKS_#2229EX
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#2229EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      07/12/2016     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#2229ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_codeid           CONSTANT CHAR(2) := '01';
   c_custodycd        CONSTANT CHAR(2) := '88';
   c_afacct2          CONSTANT CHAR(2) := '03';
   c_acct2            CONSTANT CHAR(2) := '05';
   c_custname         CONSTANT CHAR(2) := '90';
   c_address          CONSTANT CHAR(2) := '91';
   c_license          CONSTANT CHAR(2) := '92';
   c_shareholdersid   CONSTANT CHAR(2) := '22';
   c_custodycdcr      CONSTANT CHAR(2) := '89';
   c_afacctnocr       CONSTANT CHAR(2) := '13';
   c_seacctnocr       CONSTANT CHAR(2) := '15';
   c_typepon          CONSTANT CHAR(2) := '08';
   c_shareholdersidcr   CONSTANT CHAR(2) := '33';
   c_trademax         CONSTANT CHAR(2) := '21';
   c_trade            CONSTANT CHAR(2) := '10';
   c_blockedmax       CONSTANT CHAR(2) := '17';
   c_blocked          CONSTANT CHAR(2) := '06';
   c_qtty             CONSTANT CHAR(2) := '12';
   c_parvalue         CONSTANT CHAR(2) := '11';
   c_price            CONSTANT CHAR(2) := '09';
   c_feetype          CONSTANT CHAR(2) := '40';
   c_feerate          CONSTANT CHAR(2) := '41';
   c_minval           CONSTANT CHAR(2) := '42';
   c_maxval           CONSTANT CHAR(2) := '43';
   c_feeamt           CONSTANT CHAR(2) := '46';
   c_tax              CONSTANT CHAR(2) := '44';
   c_taxamt           CONSTANT CHAR(2) := '45';
   c_desc             CONSTANT CHAR(2) := '30';
   c_iddate           CONSTANT CHAR(2) := '93';
   c_idplace          CONSTANT CHAR(2) := '94';
   c_delegate         CONSTANT CHAR(2) := '95';
   c_position         CONSTANT CHAR(2) := '96';
   c_conaddress       CONSTANT CHAR(2) := '97';
   c_fullnamecr       CONSTANT CHAR(2) := '80';
   c_dateofbirthcr    CONSTANT CHAR(2) := '81';
   c_idcodecr         CONSTANT CHAR(2) := '82';
   c_iddatecr         CONSTANT CHAR(2) := '83';
   c_phonecr          CONSTANT CHAR(2) := '86';
   c_idplacecr        CONSTANT CHAR(2) := '84';
   c_addresscr        CONSTANT CHAR(2) := '85';
   c_delegatecr       CONSTANT CHAR(2) := '77';
   c_positioncr       CONSTANT CHAR(2) := '78';
   c_conaddresscr     CONSTANT CHAR(2) := '79';
   c_countrycr        CONSTANT CHAR(2) := '76';
   c_issname          CONSTANT CHAR(2) := '99';
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
L_TRADE NUMBER ;
L_BLOCKED NUMBER ;
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/



    --CHECK CO DU CHUNG KHOAN KHONG
    IF p_txmsg.DELTD <>'N' THEN
     SELECT TRADE, BLOCKED INTO L_TRADE, L_BLOCKED FROM SEMAST WHERE ACCTNO =p_txmsg.txfields('15').value;

      IF   (to_number(L_TRADE) < 0) THEN
        p_err_code := '-100192';
        plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
      END IF;

      IF   (to_number(L_BLOCKED) < 0) THEN
        p_err_code := '-100193';
        plog.setendsection (pkgctx, 'fn_txAppAutoCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
      END IF;

    END IF;


    IF p_txmsg.DELTD <> 'Y' THEN
    INSERT INTO SEOTCTRANLOG (AUTOID,TXNUM,TXDATE,TLTXCD,OLDSEACCTNO,SEACCTNO,TYPEPON,OLDSHAREHOLDERSID,SHAREHOLDERSID,STATUS,AMOUNT,DELTD,TRADE,BLOCKED,
                            SERIES,OLDSERIES,FEECD,FEERATE,FEEAMT,TAX,TAXAMT)
    VALUES(seq_SEOTCTRANLOG.NEXTVAL,p_txmsg.txnum,TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT), p_txmsg.tltxcd,p_txmsg.txfields('05').value,
        p_txmsg.txfields('15').value,p_txmsg.txfields('08').value,p_txmsg.txfields('22').value,p_txmsg.txfields('33').value,'A',p_txmsg.txfields('12').value,'N',
        p_txmsg.txfields('10').value,p_txmsg.txfields('06').value, p_txmsg.txfields('51').value,p_txmsg.txfields('50').value, p_txmsg.txfields('40').value,
        p_txmsg.txfields('41').value, p_txmsg.txfields('46').value, p_txmsg.txfields('44').value, p_txmsg.txfields('45').value);

    UPDATE SEMAST SET OLDshareholdersid = shareholdersid,  shareholdersid= p_txmsg.txfields('33').value WHERE ACCTNO =p_txmsg.txfields('15').value;
ELSE
   UPDATE  SEOTCTRANLOG SET DELTD ='Y' WHERE TXDATE = TO_DATE(p_txmsg.txdate, systemnums.C_DATE_FORMAT) AND TXNUM =p_txmsg.TXNUM;
    UPDATE SEMAST SET shareholdersid=OLDshareholdersid ,OLDshareholdersid='' WHERE ACCTNO =p_txmsg.txfields('15').value;
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
         plog.init ('TXPKS_#2229EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#2229EX;
/
