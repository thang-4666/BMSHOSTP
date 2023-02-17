SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#0099ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#0099EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      31/01/2012     Created
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


CREATE OR REPLACE PACKAGE BODY txpks_#0099ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_custid           CONSTANT CHAR(2) := '03';
   c_custodycd        CONSTANT CHAR(2) := '04';
   c_address          CONSTANT CHAR(2) := '20';
   c_phone            CONSTANT CHAR(2) := '21';
   c_mobile           CONSTANT CHAR(2) := '22';
   c_coaddress        CONSTANT CHAR(2) := '23';
   c_cophone          CONSTANT CHAR(2) := '24';
   c_email            CONSTANT CHAR(2) := '25';
   c_mobilesms        CONSTANT CHAR(2) := '26';
   c_sex              CONSTANT CHAR(2) := '27';
   c_birthdate        CONSTANT CHAR(2) := '28';
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
    v_address       varchar2(250);
    v_phone         varchar2(100);
    v_coaddress     varchar2(250);
    v_cophone       varchar2(100);
    v_email         varchar2(100);
    v_mobile        varchar2(100);
    v_sex           varchar2(10);
    v_dateofbirth   DATE;
    v_mobilesms     varchar2(100);
    v_count         NUMBER;
    v_currdate      DATE;
    v_udaddress     varchar2(200);
    v_udphone       varchar2(100);
    v_udcoaddress   varchar2(250);
    v_udcophone     varchar2(100);
    v_udemail       varchar2(100);
    v_udsex         varchar2(10);
    v_uddateofbirth DATE;
    v_udmobilesms   varchar2(100);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/

    -- Lay thong tin cu truoc khi cap nhat de so sanh
    SELECT cf.address, cf.phone, cf.mobile, cf.mobilesms, cf.email, cf.sex, cf.dateofbirth
    INTO v_address, v_phone, v_mobile, v_mobilesms, v_email, v_sex, v_dateofbirth
    FROM cfmast cf
    WHERE custid = p_txmsg.txfields(c_custid).value;

    SELECT count(custid)
    INTO v_count
    FROM cfcontact
    WHERE custid = p_txmsg.txfields(c_custid).value;
    IF v_count >0 THEN
        SELECT cfc.address, cfc.phone, cfc.email
        INTO v_coaddress, v_cophone, v_email
        FROM cfcontact cfc
        WHERE cfc.custid = p_txmsg.txfields(c_custid).value;
    ELSE
        v_coaddress := '';
        v_cophone := '';
        v_email := '';
    END IF;

    -- Cap nhat thong tin vao CFMAST va CFCONTACT
    UPDATE CFMAST SET
        ADDRESS = nvl(p_txmsg.txfields(c_address).value,v_address),
        PHONE = nvl( p_txmsg.txfields(c_phone).value,v_phone),
        email = nvl(p_txmsg.txfields(c_email).value,v_email),
        mobile= nvl(p_txmsg.txfields(c_mobile).value,v_mobile),
        mobileSMS= nvl(p_txmsg.txfields(c_mobilesms).value,v_mobile),
        sex = nvl(p_txmsg.txfields(c_sex).value,sex),
        dateofbirth = nvl(to_date(p_txmsg.txfields(c_birthdate).value,systemnums.C_DATE_FORMAT),dateofbirth)
    WHERE CUSTID = p_txmsg.txfields(c_custid).value;

    IF v_count >0 THEN
        -- CAP NHAT CFCONTACT
        UPDATE CFCONTACT SET
            ADDRESS = p_txmsg.txfields(c_coaddress).value,
            PHONE = p_txmsg.txfields(c_cophone).value,
            EMAIL = p_txmsg.txfields(c_email).value
        WHERE CUSTID = p_txmsg.txfields(c_custid).value;
    ELSE
        -- CHUA CO THI THEM MOI
        INSERT INTO CFCONTACT (AUTOID,CUSTID,TYPE,PERSON,ADDRESS,PHONE,FAX,EMAIL,DESCRIPTION)
        VALUES (seq_cfcontact.NEXTVAL, p_txmsg.txfields(c_custid).value, '001', '', p_txmsg.txfields(c_coaddress).value,
                p_txmsg.txfields(c_cophone).value, '', p_txmsg.txfields(c_email).value, '');
    END IF;

    -- GHI NHAN BANG LOG THAY DOI
    IF v_address <> p_txmsg.txfields(c_address).value THEN
        v_udaddress := p_txmsg.txfields(c_address).value || '**';
        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
            COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
        VALUES('CFMAST','CUSTID = ''' || p_txmsg.txfields(c_custid).value || '''',p_txmsg.tlid ,p_txmsg.txdate,'Y',p_txmsg.offid,
        p_txmsg.busdate,1,'ADDRESS',v_address,p_txmsg.txfields(c_address).value,'EDIT',NULL,NULL,to_char(sysdate,'hh24:mm:ss'));
    END IF;
    IF v_mobilesms <> p_txmsg.txfields(c_mobilesms).value THEN
        v_udphone := p_txmsg.txfields(c_phone).value || '**';
        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
            COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
        VALUES('CFMAST','CUSTID = ''' || p_txmsg.txfields(c_custid).value || '''',p_txmsg.tlid ,p_txmsg.txdate,'Y',p_txmsg.offid,
        p_txmsg.busdate,1,'MOBILESMS',v_mobilesms,p_txmsg.txfields(c_mobilesms).value,'EDIT',NULL,NULL,to_char(sysdate,'hh24:mm:ss'));
    END IF;
    plog.ERROR (pkgctx, 'v_dateofbirth = ' || v_dateofbirth || '  p_txmsg.txfields(c_birthdate).value = ' || p_txmsg.txfields(c_birthdate).value);
    IF v_dateofbirth <> to_date(p_txmsg.txfields(c_birthdate).value,'dd/mm/rrrr') THEN
        v_udphone := p_txmsg.txfields(c_phone).value || '**';
        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
            COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
        VALUES('CFMAST','CUSTID = ''' || p_txmsg.txfields(c_custid).value || '''',p_txmsg.tlid ,p_txmsg.txdate,'Y',p_txmsg.offid,
        p_txmsg.busdate,1,'DATEOFBIRTH',v_dateofbirth,p_txmsg.txfields(c_birthdate).value,'EDIT',NULL,NULL,to_char(sysdate,'hh24:mm:ss'));
    END IF;
    IF v_email <> p_txmsg.txfields(c_email).value THEN
        v_udphone := p_txmsg.txfields(c_phone).value || '**';
        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
            COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
        VALUES('CFMAST','CUSTID = ''' || p_txmsg.txfields(c_custid).value || '''',p_txmsg.tlid ,p_txmsg.txdate,'Y',p_txmsg.offid,
        p_txmsg.busdate,1,'EMAIL',v_dateofbirth,p_txmsg.txfields(c_email).value,'EDIT',NULL,NULL,to_char(sysdate,'hh24:mm:ss'));
    END IF;
    IF v_sex <> p_txmsg.txfields(c_sex).value THEN
        v_udphone := p_txmsg.txfields(c_phone).value || '**';
        INSERT INTO maintain_log (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,
            COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY,MAKER_TIME)
        VALUES('CFMAST','CUSTID = ''' || p_txmsg.txfields(c_custid).value || '''',p_txmsg.tlid ,p_txmsg.txdate,'Y',p_txmsg.offid,
        p_txmsg.busdate,1,'SEX',v_sex,p_txmsg.txfields(c_sex).value,'EDIT',NULL,NULL,to_char(sysdate,'hh24:mm:ss'));
    END IF;

    IF v_coaddress <> p_txmsg.txfields(c_coaddress).value THEN
        v_udcoaddress := p_txmsg.txfields(c_coaddress).value || '**';
    ELSE
        v_udcoaddress := p_txmsg.txfields(c_coaddress).value;
    END IF;
    IF v_cophone <> p_txmsg.txfields(c_cophone).value THEN
        v_udcophone := p_txmsg.txfields(c_cophone).value || '**';
    ELSE
        v_udcophone := p_txmsg.txfields(c_cophone).value;
    END IF;
    IF v_email <> p_txmsg.txfields(c_email).value THEN
        v_udemail := p_txmsg.txfields(c_email).value || '**';
    ELSE
        v_udemail := p_txmsg.txfields(c_email).value;
    END IF;

    SELECT getcurrdate INTO v_currdate FROM dual;

    INSERT INTO cfolchglog (AUTOID,changedate,CUSTID,custodycd,ADDRESS,PHONE,mobile,coaddress,cophone,EMAIL,DESCRIPTION)
        VALUES (seq_cfolchglog.NEXTVAL, v_currdate, p_txmsg.txfields(c_custid).value, p_txmsg.txfields(c_custodycd).value,
                v_udaddress, v_udphone, p_txmsg.txfields(c_mobile).value, v_udcoaddress, v_udcophone, v_udemail, p_txmsg.txfields(c_desc).value);


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
         plog.init ('TXPKS_#0099EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#0099EX;

/
