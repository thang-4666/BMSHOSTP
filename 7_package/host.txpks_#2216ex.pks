SET DEFINE OFF;
CREATE OR REPLACE PACKAGE TXPKS_#2216EX
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#2216EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      31/08/2014     Created
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


CREATE OR REPLACE PACKAGE BODY TXPKS_#2216EX
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_custodycd        CONSTANT CHAR(2) := '88';
   c_acctno           CONSTANT CHAR(2) := '03';
   c_custname         CONSTANT CHAR(2) := '90';
   c_address          CONSTANT CHAR(2) := '91';
   c_license          CONSTANT CHAR(2) := '92';
   c_bors             CONSTANT CHAR(2) := '08';
   c_codeid           CONSTANT CHAR(2) := '01';
   c_seacctno         CONSTANT CHAR(2) := '04';
   c_valdate          CONSTANT CHAR(2) := '95';
   c_qtty             CONSTANT CHAR(2) := '10';
   c_amt              CONSTANT CHAR(2) := '11';
   c_addonamt         CONSTANT CHAR(2) := '12';
   c_feerate          CONSTANT CHAR(2) := '13';
   c_feeamt           CONSTANT CHAR(2) := '14';
   c_chkqtty          CONSTANT CHAR(2) := '09';
   c_cleanprice       CONSTANT CHAR(2) := '15';
   c_dirtyprice       CONSTANT CHAR(2) := '16';
   c_yieldval         CONSTANT CHAR(2) := '17';
   c_intpaidcnt       CONSTANT CHAR(2) := '32';
   c_unit             CONSTANT CHAR(2) := '31';
   c_taxrate          CONSTANT CHAR(2) := '33';
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
    v_strAFACCTNO varchar2(10);
    v_strCODEID     varchar2(10);
    v_strDEALTYPE   varchar2(10);
    v_strDESCRIPTION    varchar2(1000);
    v_strVALDATE    varchar2(20);
    v_strEXPDATE varchar2(20);
    v_dblQTTY   number;
    v_dblAMT    number;
    v_dblADDONAMT   number;
    v_dblFEERATE    number;
    v_dblTAXRATE    number;
    v_dblYIELD      number;
    v_dblHAIRCUT    number;
    v_dblCLEAN      number;
    v_dblDIRTY      number;
    v_dblCLEANAFTER number;
    v_dblDIRTYAFTER number;
    v_dblINTPAIDCNT number;
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    
    IF p_txmsg.deltd = 'Y' THEN
        DELETE FROM IBDEALS WHERE TXNUM=p_txmsg.txnum AND TXDATE=TO_DATE(p_txmsg.txdate,'DD/MM/RRRR');
    else
        v_strAFACCTNO:= p_txmsg.txfields('03').value;
        v_strCODEID:= p_txmsg.txfields('01').value;
        v_strDEALTYPE:= p_txmsg.txfields('08').value;
        v_strDESCRIPTION:= p_txmsg.txfields('30').value;
        v_dblQTTY:= to_number(p_txmsg.txfields('10').value);
        v_dblAMT:= to_number(p_txmsg.txfields('11').value);
        v_dblADDONAMT:= to_number(p_txmsg.txfields('12').value);
        v_dblFEERATE:= to_number(p_txmsg.txfields('13').value);
        v_dblTAXRATE:= to_number(p_txmsg.txfields('33').value);
        v_dblCLEAN:= to_number(p_txmsg.txfields('15').value);
        v_dblDIRTY:= to_number(p_txmsg.txfields('16').value);
        v_dblYIELD:= to_number(p_txmsg.txfields('17').value);
        --v_dblHAIRCUT:= to_number(p_txmsg.txfields('18').value);
        v_dblHAIRCUT:=0;
        --v_dblCLEANAFTER:= to_number(p_txmsg.txfields('25').value);
        v_dblCLEANAFTER:=0;
        --v_dblDIRTYAFTER:= to_number(p_txmsg.txfields('26').value);    
        v_dblDIRTYAFTER:=0;
        v_dblINTPAIDCNT:= to_number(p_txmsg.txfields('32').value);        
        v_strVALDATE:= p_txmsg.txfields('95').value;
        --v_strEXPDATE:= p_txmsg.txfields('96').value; 
        v_strEXPDATE:=v_strVALDATE;
        
        /*If length(nvl(v_strEXPDATE,''))= 0 Then
            v_strEXPDATE := v_strVALDATE;
        End If;*/
        INSERT INTO IBDEALS (TXDATE, TXNUM, AFACCTNO, CODEID, RFCODEID, DEALTYPE,
                             QUOTEQTTY, QUOTEAMT, QUOTEPRICE, EXEQTTY, EXEAMT, SETQTTY, SETAMT, STATUS, NOTES, 
                             ADDONAMT, FEERATE, TAXRATE, YIELDVAL, HAIRCUTVAL, INPAIDCNT, 
                             CLEANPRICE, DIRTYPRICE, CLEANPRICEA, DIRTYPRICEA, VALDATE, DUEDATE) 
                    VALUES (TO_DATE(p_txmsg.txdate,'DD/MM/RRRR'),p_txmsg.txnum,v_strAFACCTNO,v_strCODEID,v_strCODEID,v_strDEALTYPE,
                             v_dblQTTY ,v_dblAMT , 0, 0, 0, 0, 0,'P',v_strDESCRIPTION,
                             v_dblADDONAMT ,v_dblFEERATE,v_dblTAXRATE,v_dblYIELD,v_dblHAIRCUT,v_dblINTPAIDCNT,
                             v_dblCLEAN,v_dblDIRTY,v_dblCLEANAFTER,v_dblDIRTYAFTER, 
                             TO_DATE(v_strVALDATE,'DD/MM/RRRR'), TO_DATE(v_strEXPDATE,'DD/MM/RRRR'));
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
         plog.init ('TXPKS_#2216EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#2216EX; 
/
