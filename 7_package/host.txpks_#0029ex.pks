SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#0029ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#0029EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      19/03/2014     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#0029ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_custid           CONSTANT CHAR(2) := '03';
   c_custodycd        CONSTANT CHAR(2) := '04';
   c_fldkey           CONSTANT CHAR(2) := '20';
   c_fldval           CONSTANT CHAR(2) := '21';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
    v_strfldname varchar2(100);
    v_strfldval varchar2(500);
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
    v_strfldname := p_txmsg.txfields(c_fldkey).value;
    v_strfldval := p_txmsg.txfields(c_fldval).value;
    --if (v_strfldname not in ('DATEOFBIRTH','SEX','ADDRESS','MOBILESMS','MOBILE','EMAIL','TRADETELEPHONE')) then
    if (v_strfldname not in ('DATEOFBIRTH','SEX','MOBILESMS','EMAIL','MOBILE','ADDRESS')) then
        p_err_code := '-200500'; -- Pre-defined in DEFERROR table
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
    v_strfldname varchar2(100);
    v_strfldval varchar2(500);

    v_address       varchar2(250);
    v_phone         varchar2(100);
    v_email         varchar2(100);
    v_mobile        varchar2(100);
    v_sex           varchar2(10);
    v_dateofbirth   DATE;
    v_tradingcodedt   DATE;
    v_iddate   DATE;
    v_idexpired  DATE;
    v_fullname  varchar2(1000);
    v_idcode  varchar2(100);
    v_idplace varchar2(1000);
    v_tradingcode varchar2(6);
    v_custtype    varchar2(6);
    v_mobilesms     varchar2(100);
    v_tradetelephone    varchar2(10);
    v_stractivests      varchar2(10);

BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    v_strfldname := p_txmsg.txfields(c_fldkey).value;
    v_strfldval := p_txmsg.txfields(c_fldval).value;

    SELECT cf.address, cf.phone, cf.mobile, cf.mobilesms, cf.email, cf.sex, cf.dateofbirth, cf.tradetelephone,
    cf.fullname,cf.idcode,cf.iddate,cf.idplace,cf.idexpired,cf.tradingcode,cf.tradingcodedt,cf.custtype, activests
    INTO v_address, v_phone, v_mobile, v_mobilesms, v_email, v_sex, v_dateofbirth, v_tradetelephone,
    v_fullname,v_idcode,v_iddate,v_idplace,v_idexpired,v_tradingcode,v_tradingcodedt,v_custtype, v_stractivests
    FROM cfmast cf
    WHERE custid = p_txmsg.txfields(c_custid).value;

    --- ('DATEOFBIRTH','SEX','ADDRESS','MOBILESMS','MOBILE','EMAIL','TRADETELEPHONE')) then
    IF v_strfldname = 'ADDRESS' THEN
        if v_stractivests = 'Y' then
                 --NGOCVTT EDIT ADDRESS INSERT CFVSDLOG, THEO LUONG VSD
            insert into cfvsdlogtmp(autoid,custid,ofullname,nfullname,oaddress,naddress,
                    oidcode,nidcode,oiddate,niddate,oidexpired,nidexpired,
                    oidplace,nidplace,otradingcode,
                    ntradingcode,otradingcodedt,ntradingcodedt,
                    TXdate,txnum,confirmtxdate,confirmtxnum,ocusttype,ncusttype,status)
            values (seq_cfvsdlogtmp.NEXTVAL, p_txmsg.txfields(c_custid).value,
                    v_fullname, null,v_address,v_strfldval,v_idcode, null,
                    to_date(v_iddate,'DD/MM/RRRR'),null,
                    to_date(v_idexpired,'DD/MM/RRRR'),null,
                    v_idplace,null,v_tradingcode, null,
                    to_date(v_tradingcodedt,'DD/MM/RRRR'),null,
                    p_txmsg.txdate, p_txmsg.txnum, null,  null,v_custtype,v_custtype,'A');
        else
            UPDATE CFMAST SET ADDRESS = nvl(trim(v_strfldval),v_address)
            WHERE CUSTID = p_txmsg.txfields(c_custid).value;
            INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
                COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
            VALUES('CFMAST','CUSTID = ''' || p_txmsg.txfields(c_custid).value || '''',p_txmsg.tlid ,p_txmsg.txdate,'Y',p_txmsg.offid,
            p_txmsg.busdate,1,'ADDRESS',v_address,v_strfldval,'EDIT',NULL,NULL,to_char(sysdate,'hh24:mm:ss'));
        end if;

       /* UPDATE CFMAST SET ADDRESS = nvl(trim(v_strfldval),v_address)
        WHERE CUSTID = p_txmsg.txfields(c_custid).value;*/
/*        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
            COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
        VALUES('CFMAST','CUSTID = ''' || p_txmsg.txfields(c_custid).value || '''',p_txmsg.tlid ,p_txmsg.txdate,'Y',p_txmsg.offid,
        p_txmsg.busdate,1,'ADDRESS',v_address,v_strfldval,'EDIT',NULL,NULL,to_char(sysdate,'hh24:mm:ss'));*/


    END IF;
    IF v_strfldname = 'DATEOFBIRTH' THEN
        UPDATE CFMAST SET DATEOFBIRTH = nvl(to_date(v_strfldval,systemnums.C_DATE_FORMAT),v_dateofbirth)
        WHERE CUSTID = p_txmsg.txfields(c_custid).value;
        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
            COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
        VALUES('CFMAST','CUSTID = ''' || p_txmsg.txfields(c_custid).value || '''',p_txmsg.tlid ,p_txmsg.txdate,'Y',p_txmsg.tlid,
        p_txmsg.busdate,1,'DATEOFBIRTH',v_dateofbirth,v_strfldval,'EDIT',NULL,NULL,to_char(sysdate,'hh24:mm:ss'));
    END IF;
    IF v_strfldname = 'SEX' THEN
        UPDATE CFMAST SET SEX = nvl(v_strfldval,v_sex)
        WHERE CUSTID = p_txmsg.txfields(c_custid).value;
        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
            COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
        VALUES('CFMAST','CUSTID = ''' || p_txmsg.txfields(c_custid).value || '''',p_txmsg.tlid ,p_txmsg.txdate,'Y',p_txmsg.tlid,
        p_txmsg.busdate,1,'SEX',v_sex,v_strfldval,'EDIT',NULL,NULL,to_char(sysdate,'hh24:mm:ss'));
    END IF;
    IF v_strfldname = 'MOBILESMS' THEN
        UPDATE CFMAST SET MOBILESMS = nvl(v_strfldval,v_mobilesms)
        WHERE CUSTID = p_txmsg.txfields(c_custid).value;
        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
            COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
        VALUES('CFMAST','CUSTID = ''' || p_txmsg.txfields(c_custid).value || '''',p_txmsg.tlid ,p_txmsg.txdate,'Y',p_txmsg.tlid,
        p_txmsg.busdate,1,'MOBILESMS',v_mobilesms,v_strfldval,'EDIT',NULL,NULL,to_char(sysdate,'hh24:mm:ss'));
    END IF;
    IF v_strfldname = 'MOBILE' THEN
        UPDATE CFMAST SET MOBILE = nvl(v_strfldval,v_mobile)
        WHERE CUSTID = p_txmsg.txfields(c_custid).value;
        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
            COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
        VALUES('CFMAST','CUSTID = ''' || p_txmsg.txfields(c_custid).value || '''',p_txmsg.tlid ,p_txmsg.txdate,'Y',p_txmsg.tlid,
        p_txmsg.busdate,1,'MOBILE',v_mobile,v_strfldval,'EDIT',NULL,NULL,to_char(sysdate,'hh24:mm:ss'));
    END IF;
    IF v_strfldname = 'EMAIL' THEN
        UPDATE CFMAST SET EMAIL = nvl(v_strfldval,v_email)
        WHERE CUSTID = p_txmsg.txfields(c_custid).value;
        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
            COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
        VALUES('CFMAST','CUSTID = ''' || p_txmsg.txfields(c_custid).value || '''',p_txmsg.tlid ,p_txmsg.txdate,'Y',p_txmsg.tlid,
        p_txmsg.busdate,1,'EMAIL',v_email,v_strfldval,'EDIT',NULL,NULL,to_char(sysdate,'hh24:mm:ss'));
    END IF;
    IF v_strfldname = 'TRADETELEPHONE' THEN
        UPDATE CFMAST SET TRADETELEPHONE = nvl(v_strfldval,v_tradetelephone)
        WHERE CUSTID = p_txmsg.txfields(c_custid).value;
        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
            COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
        VALUES('CFMAST','CUSTID = ''' || p_txmsg.txfields(c_custid).value || '''',p_txmsg.tlid ,p_txmsg.txdate,'Y',p_txmsg.tlid,
        p_txmsg.busdate,1,'TRADETELEPHONE',v_tradetelephone,v_strfldval,'EDIT',NULL,NULL,to_char(sysdate,'hh24:mm:ss'));
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
         plog.init ('TXPKS_#0029EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#0029EX;

/
