SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#0018ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#0018EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      24/07/2013     Created
 **
 ** (c) 2008 by Financial Software Solutions. JSC.
 ** ----------------------------------------------------------------------------------------------------*/
IS
FUNCTION fn_txPreAppCheck(p_txmsg in out tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_txAftAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_txPreAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
FUNCTION fn_txAftAppUpdate(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER;
END;

 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY txpks_#0018ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_custid           CONSTANT CHAR(2) := '03';
   c_txnum            CONSTANT CHAR(2) := '18';
   c_custodycd        CONSTANT CHAR(2) := '88';
   c_fullname         CONSTANT CHAR(2) := '28';
   c_nfullname        CONSTANT CHAR(2) := '38';
   c_idcode           CONSTANT CHAR(2) := '21';
   c_nidcode          CONSTANT CHAR(2) := '31';
   c_iddate           CONSTANT CHAR(2) := '22';
   c_txdate           CONSTANT CHAR(2) := '19';
   c_niddate          CONSTANT CHAR(2) := '32';
   c_idexpired        CONSTANT CHAR(2) := '23';
   c_nidexpired       CONSTANT CHAR(2) := '33';
   c_idplace          CONSTANT CHAR(2) := '24';
   c_nidplace         CONSTANT CHAR(2) := '34';
   c_tradingcode      CONSTANT CHAR(2) := '25';
   c_ntradingcode     CONSTANT CHAR(2) := '35';
   c_tradingcodedt    CONSTANT CHAR(2) := '26';
   c_ntradingcodedt   CONSTANT CHAR(2) := '36';
   c_address          CONSTANT CHAR(2) := '27';
   c_naddress         CONSTANT CHAR(2) := '37';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in out tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
    l_count number;
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
    for rec in
    (
    select * from cfvsdlog where txnum = p_txmsg.txfields(c_txnum).value and txdate = to_date(p_txmsg.txfields(c_txdate).value,'DD/MM/RRRR')
    )
    loop
    if rec.confirmtxnum is not null and rec.confirmtxdate is not null then
        p_err_code := '-100146'; -- Pre-defined in DEFERROR table
        plog.setendsection (pkgctx, 'fn_txPreAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    end if;
    end loop;
    if nvl(p_txmsg.txfields('45').value,'XYZ') <> nvl(p_txmsg.txfields('46').value,'XYZ') then
        p_txmsg.txWarningException('-2004201').value := cspks_system.fn_get_errmsg('-200420');
        p_txmsg.txWarningException('-2004201').errlev := '1';
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
l_cutmark varchar2(200);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/

        -- Cap nhat CFMAST
    l_cutmark:= p_txmsg.txfields(c_nfullname).value;
        IF length(p_txmsg.txfields(c_nfullname).value || ' ' ) > 1 THEN
    FOR J In 1..length(p_txmsg.txfields(c_nfullname).value) LOOP
        if instr(UTF8NUMS.c_FindText,substr(p_txmsg.txfields(c_nfullname).value,J,1)) > 0 then
            l_cutmark:= replace(l_cutmark,substr(p_txmsg.txfields(c_nfullname).value,J,1),substr(UTF8NUMS.c_ReplText,instr(UTF8NUMS.c_FindText,substr(p_txmsg.txfields(c_nfullname).value,J,1)),1));
        end if;
    END LOOP;
        ELSE
             FOR J In 1..length(p_txmsg.txfields(c_fullname).value) LOOP
        if instr(UTF8NUMS.c_FindText,substr(p_txmsg.txfields(c_fullname).value,J,1)) > 0 then
            l_cutmark:= replace(l_cutmark,substr(p_txmsg.txfields(c_nfullname).value,J,1),substr(UTF8NUMS.c_ReplText,instr(UTF8NUMS.c_FindText,substr(p_txmsg.txfields(c_nfullname).value,J,1)),1));
        end if;
    END LOOP;
        END IF;
    update cfmast
    set fullname = nvl(replace(p_txmsg.txfields(c_nfullname).value,'''''',''''),fullname),
        mnemonic = nvl(replace(l_cutmark,'''''',''''),mnemonic),
        address = nvl(replace(p_txmsg.txfields(c_naddress).value,'''''',''''),address),
        idcode = nvl(p_txmsg.txfields(c_nidcode).value,idcode),
        iddate = nvl(to_date(p_txmsg.txfields(c_niddate).value,'DD/MM/RRRR'),to_date(iddate,'DD/MM/RRRR')),
        idexpired = nvl(to_date(p_txmsg.txfields(c_nidexpired).value,'DD/MM/RRRR'),to_date(idexpired,'DD/MM/RRRR')),
        idplace = nvl(replace(p_txmsg.txfields(c_nidplace).value,'''''',''''),idplace),
        tradingcode = nvl(p_txmsg.txfields(c_ntradingcode).value,tradingcode),
        tradingcodedt = nvl(to_date(p_txmsg.txfields(c_ntradingcodedt).value,'DD/MM/RRRR'),to_date(tradingcodedt,'DD/MM/RRRR')),
        custtype = nvl(p_txmsg.txfields('46').value,custtype),
                country = nvl(p_txmsg.txfields('89').value,country),
        last_mkid = p_txmsg.tlid,
        last_ofid = nvl(p_txmsg.offid,p_txmsg.tlid)
    where custid = p_txmsg.txfields(c_custid).value;

    /*if p_txmsg.txfields(c_fullname).value <> p_txmsg.txfields(c_nfullname).value AND length(p_txmsg.txfields(c_nfullname).value||' ') > 1
    then
        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
        VALUES('CFMAST','CUSTID = ''' || p_txmsg.txfields(c_custid).value || '''',p_txmsg.tlid,p_txmsg.txdate,'Y',p_txmsg.offid,
            p_txmsg.txdate,0,'FULLNAME',p_txmsg.txfields(c_fullname).value,p_txmsg.txfields(c_nfullname).value,'EDIT',NULL,NULL,TO_CHAR(SYSDATE,'HH:MM:SS'));
    end if;

    if p_txmsg.txfields(c_idcode).value <> p_txmsg.txfields(c_nidcode).value AND length(p_txmsg.txfields(c_nidcode).value||' ') > 1
    then
        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
        VALUES('CFMAST','CUSTID = ''' || p_txmsg.txfields(c_custid).value || '''',p_txmsg.tlid,p_txmsg.txdate,'Y',p_txmsg.offid,
            p_txmsg.txdate,0,'IDCODE',p_txmsg.txfields(c_idcode).value,p_txmsg.txfields(c_nidcode).value,'EDIT',NULL,NULL,TO_CHAR(SYSDATE,'HH:MM:SS'));
    end if;
    if to_date(p_txmsg.txfields(c_iddate).value,'DD/MM/RRRR') <> to_date(p_txmsg.txfields(c_niddate).value,'DD/MM/RRRR')  AND length(p_txmsg.txfields(c_niddate).value||' ') > 1
    then
        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
        VALUES('CFMAST','CUSTID = ''' || p_txmsg.txfields(c_custid).value || '''',p_txmsg.tlid,p_txmsg.txdate,'Y',p_txmsg.offid,
            p_txmsg.txdate,0,'IDDATE',to_date(p_txmsg.txfields(c_iddate).value,'DD/MM/RRRR'),to_date(p_txmsg.txfields(c_niddate).value,'DD/MM/RRRR'),'EDIT',NULL,NULL,TO_CHAR(SYSDATE,'HH:MM:SS'));
    end if;
    if to_date(p_txmsg.txfields(c_idexpired).value,'DD/MM/RRRR') <> to_date(p_txmsg.txfields(c_nidexpired).value,'DD/MM/RRRR') AND length(p_txmsg.txfields(c_nidexpired).value || ' ') > 1
    then
        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
        VALUES('CFMAST','CUSTID = ''' || p_txmsg.txfields(c_custid).value || '''',p_txmsg.tlid,p_txmsg.txdate,'Y',p_txmsg.offid,
            p_txmsg.txdate,0,'IDEXPIRED',to_date(p_txmsg.txfields(c_idexpired).value,'DD/MM/RRRR'),to_date(p_txmsg.txfields(c_nidexpired).value,'DD/MM/RRRR'),'EDIT',NULL,NULL,TO_CHAR(SYSDATE,'HH:MM:SS'));
    end if;
    if p_txmsg.txfields(c_idplace).value <> p_txmsg.txfields(c_nidplace).value AND length(p_txmsg.txfields(c_nidplace).value || ' ') > 1
    then
        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
        VALUES('CFMAST','CUSTID = ''' || p_txmsg.txfields(c_custid).value || '''',p_txmsg.tlid,p_txmsg.txdate,'Y',p_txmsg.offid,
            p_txmsg.txdate,0,'IDPLACE',p_txmsg.txfields(c_idplace).value,p_txmsg.txfields(c_nidplace).value,'EDIT',NULL,NULL,TO_CHAR(SYSDATE,'HH:MM:SS'));
    end if;
    if p_txmsg.txfields(c_tradingcode).value <> p_txmsg.txfields(c_ntradingcode).value AND length(p_txmsg.txfields(c_ntradingcode).value || ' ') >1
    then
        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
        VALUES('CFMAST','CUSTID = ''' || p_txmsg.txfields(c_custid).value || '''',p_txmsg.tlid,p_txmsg.txdate,'Y',p_txmsg.offid,
            p_txmsg.txdate,0,'TRADINHCODE',p_txmsg.txfields(c_tradingcode).value,p_txmsg.txfields(c_ntradingcode).value,'EDIT',NULL,NULL,TO_CHAR(SYSDATE,'HH:MM:SS'));
    end if;
    if to_date(p_txmsg.txfields(c_tradingcodedt).value,'DD/MM/RRRR') <> to_date(p_txmsg.txfields(c_ntradingcodedt).value,'DD/MM/RRRR') AND length(p_txmsg.txfields(c_ntradingcodedt).value || ' ') > 1
    then
        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
        VALUES('CFMAST','CUSTID = ''' || p_txmsg.txfields(c_custid).value || '''',p_txmsg.tlid,p_txmsg.txdate,'Y',p_txmsg.offid,
            p_txmsg.txdate,0,'TRADINGCODEDT',to_date(p_txmsg.txfields(c_tradingcodedt).value,'DD/MM/RRRR'),to_date(p_txmsg.txfields(c_ntradingcodedt).value,'DD/MM/RRRR'),'EDIT',NULL,NULL,TO_CHAR(SYSDATE,'HH:MM:SS'));
    end if;

    if p_txmsg.txfields(c_address).value <> p_txmsg.txfields(c_naddress).value AND length( p_txmsg.txfields(c_naddress).value || ' ') > 1
    then
        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
        VALUES('CFMAST','CUSTID = ''' || p_txmsg.txfields(c_custid).value || '''',p_txmsg.tlid,p_txmsg.txdate,'Y',p_txmsg.offid,
            p_txmsg.txdate,0,'ADDRESS',p_txmsg.txfields(c_address).value,p_txmsg.txfields(c_naddress).value,'EDIT',NULL,NULL,TO_CHAR(SYSDATE,'HH:MM:SS'));
    end if;

    if p_txmsg.txfields('45').value <> p_txmsg.txfields('46').value
    then
        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
        VALUES('CFMAST','CUSTID = ''' || p_txmsg.txfields(c_custid).value || '''',p_txmsg.tlid,p_txmsg.txdate,'Y',p_txmsg.offid,
            p_txmsg.txdate,0,'CUSTTYPE',p_txmsg.txfields('45').value,p_txmsg.txfields('46').value,'EDIT',NULL,NULL,TO_CHAR(SYSDATE,'HH:MM:SS'));
    end if;*/


    update cfvsdlog
    set confirmtxnum = p_txmsg.txnum,
        confirmtxdate = p_txmsg.txdate
    where custid = p_txmsg.txfields(c_custid).value
    and txnum = p_txmsg.txfields(c_txnum).value and txdate = to_date(p_txmsg.txfields(c_txdate).value,'DD/MM/RRRR');
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
         plog.init ('TXPKS_#0018EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#0018EX;

/
