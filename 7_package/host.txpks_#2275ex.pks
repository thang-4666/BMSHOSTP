SET DEFINE OFF;
CREATE OR REPLACE PACKAGE TXPKS_#2275EX
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#2275EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      10/04/2020     Created
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


CREATE OR REPLACE PACKAGE BODY TXPKS_#2275EX
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_trftxnum         CONSTANT CHAR(2) := '01';
   c_autoid           CONSTANT CHAR(2) := '15';
   c_custodycd        CONSTANT CHAR(2) := '02';
   c_afacctno         CONSTANT CHAR(2) := '03';
   c_acctno           CONSTANT CHAR(2) := '04';
   c_custname         CONSTANT CHAR(2) := '05';
   c_address          CONSTANT CHAR(2) := '06';
   c_frbiccode        CONSTANT CHAR(2) := '07';
   c_frfullname       CONSTANT CHAR(2) := '08';
   c_fromcustodycd    CONSTANT CHAR(2) := '09';
   c_codeid           CONSTANT CHAR(2) := '10';
   c_block            CONSTANT CHAR(2) := '11';
   c_trade            CONSTANT CHAR(2) := '12';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
   v_exist    VARCHAR2(1);
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
    -- Check he thong da xu ly thong bao hay chua
    if ( p_txmsg.txfields(c_autoid).value is not null) then 
        SELECT decode(COUNT(1), 1, 'Y', 'N') INTO v_exist
        FROM sereceived
        WHERE autoid = p_txmsg.txfields(c_autoid).value
          AND status = 'P';

       IF v_exist <> 'Y' THEN
          p_err_code := '-905556'; -- Pre-defined in DEFERROR table
          plog.setendsection (pkgctx, 'fn_txPreAppCheck');
          RETURN errnums.C_BIZ_RULE_INVALID;
       END IF;
     end if;
   
     IF p_txmsg.txfields('11').VALUE > 0 AND  p_txmsg.txfields('12').VALUE > 0 THEN
         p_err_code:= -900058;
         plog.setendsection (pkgctx, 'fn_txPreAppCheck');
         RETURN errnums.C_BIZ_RULE_INVALID;
      end if;
    
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
l_symbol sbsecurities.symbol%type;
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    select symbol into l_symbol from sbsecurities where codeid = p_txmsg.txfields(c_codeid).value;
    IF p_txmsg.deltd <> 'Y' THEN
       -- Cap nhat so tieu khoan se hach toan
       if ( p_txmsg.txfields(c_autoid).value is not null) then
         UPDATE sereceived SET reseacctno = p_txmsg.txfields(c_acctno).value, status = 'A'
         WHERE autoid = p_txmsg.txfields(c_autoid).value;
       else
         INSERT INTO SERECEIVED(autoid,VSDMSGID,trfdate,trftxnum,frbiccode,
                                custodycd,recustodycd,symbol,trade,blocked,
                                Selldaas,Sellpcod,reseacctno,status )
         select  seq_SERECEIVED.nextval, p_txmsg.TXNUM|| to_char (p_txmsg.TXDATE, 'RRRRMMDD'), getcurrdate, p_txmsg.txfields(c_trftxnum).value, nvl(de.biccode, ''),
                  p_txmsg.txfields(c_fromcustodycd).value, p_txmsg.txfields(c_custodycd).value,l_symbol,
                  p_txmsg.txfields(c_trade).value,p_txmsg.txfields(c_block).value,
                  p_txmsg.txfields('22').value,p_txmsg.txfields('19').value,p_txmsg.txfields(c_acctno).value,'A'
         FROM deposit_member de 
         where de.depositid =  p_txmsg.txfields(c_frbiccode).value;
         
       end if;
    ELSE
      if ( p_txmsg.txfields(c_autoid).value is not null) then
          UPDATE sereceived SET reseacctno = '', status = 'P'
       WHERE autoid = p_txmsg.txfields(c_autoid).value;
       else
         delete SERECEIVED where VSDMSGID = p_txmsg.TXNUM|| to_char (p_txmsg.TXDATE, 'RRRRMMDD') ;
       end if;
      
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
         plog.init ('TXPKS_#2275EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#2275EX;
/
