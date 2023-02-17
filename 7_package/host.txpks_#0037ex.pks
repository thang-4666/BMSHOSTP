SET DEFINE OFF;
CREATE OR REPLACE PACKAGE txpks_#0037ex
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#0037EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      26/08/2014     Created
 **
 ** (c) 2008 by Financial Software Solutions. JSC.
 ** ----------------------------------------------------------------------------------------------------*/
 IS
  FUNCTION FN_TXPREAPPCHECK(P_TXMSG    IN TX.MSG_RECTYPE,
                            P_ERR_CODE OUT VARCHAR2) RETURN NUMBER;
  FUNCTION FN_TXAFTAPPCHECK(P_TXMSG    IN TX.MSG_RECTYPE,
                            P_ERR_CODE OUT VARCHAR2) RETURN NUMBER;
  FUNCTION FN_TXPREAPPUPDATE(P_TXMSG    IN TX.MSG_RECTYPE,
                             P_ERR_CODE OUT VARCHAR2) RETURN NUMBER;
  FUNCTION FN_TXAFTAPPUPDATE(P_TXMSG    IN TX.MSG_RECTYPE,
                             P_ERR_CODE OUT VARCHAR2) RETURN NUMBER;
END;
 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY txpks_#0037ex
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_idcode           CONSTANT CHAR(2) := '88';
   c_fullname         CONSTANT CHAR(2) := '90';
   c_address          CONSTANT CHAR(2) := '91';
   c_oldstatus        CONSTANT CHAR(2) := '06';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
v_count number;
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

    SELECT count(*) INTO v_count FROM CFMAST where idcode = p_txmsg.txfields('88').value AND STATUS <> 'C';
    if v_count <> 0 then
        p_err_code:= -200020;
        plog.setendsection (pkgctx, 'fn_txAftAppCheck');
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
v_count number;
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
    SELECT count(*) INTO v_count FROM CFMAST where idcode = p_txmsg.txfields('88').value AND STATUS <> 'C';
    if v_count <> 0 then
        p_err_code:= -200020;
        plog.setendsection (pkgctx, 'fn_txAftAppCheck');
        RETURN errnums.C_BIZ_RULE_INVALID;
    end if;
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
v_brid          varchar2(4);
v_custid        varchar2(10);
v_isonltrade    varchar2(1);
v_tlid          varchar2(4);
v_opndate       date;
v_DATEOFBIRTH   date;
v_IDDATE        date;
v_IDPLACE       varchar2(1000);
v_IDEXPIRED     date;
v_fullname      varchar2(1000);
v_ADDRESS       varchar2(1000);
v_MOBILESMS     varchar2(20);
v_email         varchar2(1000);
v_GRINVESTOR    varchar2(10);
v_CAREBY        varchar2(4);
v_custodycd     varchar2(10);
v_prefix          varchar2(4);
v_AUTOINV         varchar2(6);
v_AUTOINVTEMP     varchar2(6);
v_startnum    number;
v_endnum      number;
v_startnumtemp  number;
          v_endnumtemp    number;
          V_SSYSVAR VARCHAR2(100);
          v_loginpwd varchar2(10);
          v_tradingpwd varchar2(10);
          v_actype varchar2(4);
          v_branch varchar2(4);

                    v_cfcontactautoid NUMBER;
                    v_receiveaddress VARCHAR2(1000);
                    v_TRADETELEPHONE varchar2(1);
    v_count number(10);
    v_strbankname varchar2(100);
    v_strbankcode varchar2(100);
    v_strCFOTHERACCid number(20);
    V_strvcbaccount varchar2(20);
    v_strIDCODE varchar2(50);
BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    v_ACTYPE:= p_txmsg.txfields('08').value;
    v_CAREBY:=p_txmsg.txfields('07').value;
    select varvalue into V_SSYSVAR from sysvar where varname = 'COMPANYCD';

    begin
        select brid into v_branch from brgrp where mapid in (select area from cfmasttemp where idcode = p_txmsg.txfields('88').value) AND STATUS <> 'A';
    exception when others then
        v_branch := '0001';
    end;

    select v_branch , tlid, isonltrade, to_date(opndate,'dd/mm/rrrr') into v_brid, v_tlid, v_isonltrade, v_opndate from cfmasttemp where idcode = p_txmsg.txfields('88').value AND STATUS <> 'A';
 --sinh ma khach hang
    SELECT SUBSTR(INVACCT,1,4)||ltrim(to_char(MAX(ODR)+1,'000000')) into v_custid FROM
      (
            SELECT ROWNUM ODR, INVACCT
            FROM (SELECT CUSTID INVACCT FROM CFMAST WHERE SUBSTR(CUSTID,1,4)= v_brid ORDER BY CUSTID) DAT
            WHERE TO_NUMBER(SUBSTR(INVACCT,5,6))=ROWNUM
      ) INVTAB
    GROUP BY SUBSTR(INVACCT,1,4);

     --sinh so custodycd
            begin
                SELECT CUSTODYCDFROM,CUSTODYCDTO
                       INTO v_startnumtemp,v_endnumtemp
                      FROM BRGRP WHERE BRID = V_BRID;
            exception when others then
                v_startnum:= 0;
                v_endnum:= 999999;
            end;
            v_startnum:= v_startnumtemp;
            v_endnum:= v_endnumtemp;
            begin
                SELECT SUBSTR(INVACCT,1,4), (v_startnum) + MAX(ODR)+1 AUTOINV
                into v_prefix, v_AUTOINV
                FROM
                (SELECT ROWNUM ODR, INVACCT
                    FROM (SELECT CUSTODYCD INVACCT
                                  FROM ( select custodycd FROM CFMAST
                                        WHERE SUBSTR(CUSTODYCD,1,4)= V_SSYSVAR || 'C' AND TRIM(TO_CHAR(TRANSLATE(SUBSTR(CUSTODYCD,5,6),'0123456789',' '))) IS NULL
                                        union all
                                        select custodycd FROM CFMASTMEMO
                                        WHERE SUBSTR(CUSTODYCD,1,4)= V_SSYSVAR || 'C' AND TRIM(TO_CHAR(TRANSLATE(SUBSTR(CUSTODYCD,5,6),'0123456789',' '))) IS NULL
                                        )CFMAST
                        WHERE TRIM( TO_NUMBER(SUBSTR(CUSTODYCD,5,6))) >= v_startnum and TRIM( TO_NUMBER(SUBSTR(CUSTODYCD,5,6)))<=v_endnum
                            ORDER BY CUSTODYCD
                         ) DAT
                    WHERE TO_NUMBER(SUBSTR(INVACCT,5,6))=ROWNUM+v_startnum
                ) INVTAB
                GROUP BY SUBSTR(INVACCT,1,4);

            exception when others then
              v_prefix:='';
              v_AUTOINV:=v_startnum + 1;
            end;
        v_custodycd := v_prefix || LPAD(v_autoinv,6,'000000');

    plog.error(pkgctx,'custid = ' || v_custid || '; v_custodycd = ' || v_custodycd || '; txfields(88).value = ' ||p_txmsg.txfields('88').value || ', '|| p_txmsg.tlid);

    insert into CFMAST (CUSTID, SHORTNAME, FULLNAME, MNEMONIC, DATEOFBIRTH, IDTYPE, IDCODE, IDDATE,
        IDPLACE, IDEXPIRED, ADDRESS, PHONE, MOBILE, FAX,
        EMAIL, COUNTRY, PROVINCE, POSTCODE, RESIDENT, CLASS, GRINVESTOR, INVESTRANGE, TIMETOJOIN, CUSTODYCD, STAFF, COMPANYID, POSITION, SEX, SECTOR,
        BUSINESSTYPE, INVESTTYPE, EXPERIENCETYPE, INCOMERANGE, ASSETRANGE, FOCUSTYPE, BRID, CAREBY, APPROVEID, LASTDATE, AUDITORID, AUDITDATE, LANGUAGE,
        BANKACCTNO, BANKCODE, VALUDADDED, ISSUERID, DESCRIPTION, MARRIED, TAXCODE, INTERNATION, OCCUPATION, EDUCATION, CUSTTYPE, STATUS, PSTATUS,
        INVESTMENTEXPERIENCE, PCUSTODYCD, EXPERIENCECD, ORGINF, TLID, ISBANKING, PIN,  MRLOANLIMIT, RISKLEVEL, TRADINGCODE, TRADINGCODEDT,
        LAST_CHANGE, OPNDATE, CFCLSDATE, MARGINALLOW, CUSTATCOM, T0LOANLIMIT, DMSTS, ACTIVEDATE, AFSTATUS, MOBILESMS, OPENVIA, OLAUTOID, VAT, REFNAME,
        TRADEFLOOR, TRADETELEPHONE, TRADEONLINE, COMMRATE, CONSULTANT, ACTIVESTS, LAST_MKID, LAST_OFID, ONLINELIMIT, ISCHKONLIMIT, MANAGETYPE, actype)

    select v_custid, '' SHORTNAME, FULLNAME, fn_convert_to_vn(upper(fullname)) MNEMONIC, to_date(DATEOFBIRTH,'DD/MM/RRRR') dateofbirth,
        '001' IDTYPE, IDCODE, to_date(IDDATE,'DD/MM/RRRR') iddate,
        IDPLACE, to_date(IDDATE,'DD/MM/RRRR') + 15*365 IDEXPIRED,nvl(receiveaddress,' ')  ADDRESS, PHONE, MOBILE ,
        '' FAX, EMAIL, '234' COUNTRY, '--' PROVINCE, '' postcode, '001' resident, '001' class, grinvestor,
        '000' investrange, '000' timetojoin, v_custodycd custodycd, '000' staff, '' companyid, '000' position,
        sex, '000' sector, '009' businesstype, '000' investtype, '000' experiencetype, '000' incomerage,
        '000' assetrange, '000' focustype, v_brid brid, v_CAREBY CAREBY, p_txmsg.offid APPROVEID, to_date(OPNDATE,'DD/MM/RRRR') LASTDATE, '' AUDITORID,
        to_date(OPNDATE,'DD/MM/RRRR') AUDITDATE, '001' language, '' bankacctno, '000' bankcode, '000' valudadded, '' issuerid, '' description, '004' married, '' taxcode, '' internation,
        '000' occupation, '000' education,'I' CUSTTYPE, 'P' STATUS, NULL PSTATUS, '' investmentexperience, '' pcustodycd, '00000' experiencecd, '' orginf, nvl(p_txmsg.tlid,'6868') "TLID",
        'N' ISBANKING,  NULL  PIN, 10000000000000 mrloanlimit, 'O' RISKLEVEL, '' TRADINGCODE, to_date(OPNDATE,'DD/MM/RRRR') TRADINGCODEDT,
        to_date(getcurrdate,'DD/MM/RRRR') LAST_CHANGE, to_date(getcurrdate,'DD/MM/RRRR') OPNDATE, NULL CFCLSDATE, 'Y' MARGINALLOW,
        'Y' CUSTACOM, 10000000000000 T0LOANLIMIT, 'N' DMSTS, NULL  ACTIVEDATE, 'N' AFSTATUS, MOBILE MOBILESMS, VIA OPENVIA, NULL OLAUTOID,
        'Y' VAT, '' REFNAME, 'Y' TRADEFLOOR, case when ISTELTRADE = '1' then 'Y' else 'N' end  TRADETELEPHONE,
        case when ISONLTRADE = '1' then 'Y' else 'N' end TRADEONLINE, 100 COMMRATE, 'Y' CONSULTANT, 'N' ACTIVESTS,  p_txmsg.tlid LAST_MKID,  p_txmsg.offid LAST_OFID,
        0 ONLINELIMIT, 'Y' ISCHKONLIMIT, 'A' MANAGETYPE, v_actype actype
   FROM cfmasttemp
   where idcode = p_txmsg.txfields('88').value AND status = 'C';

   /* if v_isonltrade = 'Y' then
        --phan quyen onl
        insert into otright (AUTOID, CFCUSTID, AUTHCUSTID, AUTHTYPE, VALDATE, EXPDATE, DELTD, LASTDATE, LASTCHANGE, SERIALTOKEN)
        select seq_otright.NEXTVAL, v_custid, v_custid, '1', getcurrdate, to_date(getcurrdate + 20*365,'DD/MM/RRRR'),'N',null,getcurrdate,'' from cfmasttemp
            where idcode = p_txmsg.txfields('88').value;
        --gen pass
        select cspks_system.fn_passwordgenerator(6), cspks_system.fn_passwordgenerator(6) into v_loginpwd, v_tradingpwd from dual;
        --tao tai khoan dang nhap online
        INSERT INTO userlogin (USERNAME,HANDPHONE,LOGINPWD,TRADINGPWD,AUTHTYPE,STATUS,LOGINSTATUS,LASTCHANGED,NUMBEROFDAY,ISRESET,ISMASTER,TOKENID,LOGINFAIL,LOGINFAILMAX)
        VALUES(v_autoinv,NULL,genencryptpassword(v_loginpwd),genencryptpassword(v_tradingpwd),'1','A','O',TO_DATE(getcurrdate, 'DD/MM/RRRR'),30,'Y','N',NULL,0,3);
        --insert vao emaillog 2 template: sms va email gui thong tin cho kh : 0212, 304B
    end if;*/

    select fullname, to_date(DATEOFBIRTH,'DD/MM/RRRR'), to_date(IDDATE,'DD/MM/RRRR'), IDPLACE, to_date(iddate,'DD/MM/RRRR') + 365*15, ADDRESS, mobile, email, GRINVESTOR, nvl(receiveaddress,' '),
        case when ISTELTRADE = '1' then 'Y' else NULL end
        into v_fullname, v_DATEOFBIRTH, v_IDDATE,  v_IDPLACE, v_IDEXPIRED,  v_ADDRESS, v_MOBILESMS, v_email, v_GRINVESTOR, v_receiveaddress, v_TRADETELEPHONE
    from cfmasttemp where idcode = p_txmsg.txfields('88').value AND status = 'C';

    -------- insert vao maintain_log

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'CUSTID', '', '' || v_custid || '', 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'TRADEFLOOR', '', 'Y', 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'FULLNAME', '', v_fullname, 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'MNEMONIC', '', v_fullname, 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'TRADETELEPHONE', '', v_TRADETELEPHONE, 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'TRADEONLINE', '', 'Y', 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'DATEOFBIRTH', '', v_DATEOFBIRTH, 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'IDTYPE', '', '001', 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'IDCODE', '', p_txmsg.txfields('88').value, 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'COMMRATE', '', '100', 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'IDDATE', '', v_IDDATE, 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'IDPLACE', '', v_IDPLACE, 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'IDEXPIRED', '', v_IDEXPIRED, 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'ADDRESS', '', v_receiveaddress, 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'MOBILESMS', '', v_MOBILESMS, 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'EMAIL', '', v_email, 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'COUNTRY', '', CASE WHEN v_GRINVESTOR = '001' THEN '234' ELSE '0' END , 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'PROVINCE', '', '--', 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'RESIDENT', '', '001', 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'CLASS', '', '000', 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'GRINVESTOR', '', v_GRINVESTOR, 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'INVESTRANGE', '', '000', 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'CUSTATCOM', '', 'Y', 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'CONSULTANT', '', 'Y', 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'VAT', '', 'Y', 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'TIMETOJOIN', '', '000', 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'STAFF', '', '000', 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'POSITION', '', '000', 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'SEX', '', '000', 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'SECTOR', '', '000', 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'FOCUSTYPE', '', '000', 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'BUSINESSTYPE', '', '009', 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'INVESTTYPE', '', '000', 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'EXPERIENCETYPE', '', '000', 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'INCOMERANGE', '', '000', 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'ASSETRANGE', '', '000', 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'BRID', '', '' || v_brid || '', 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'CAREBY', '', v_CAREBY, 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'APPROVEID', '', '' || v_tlid || '', 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'LASTDATE', '', v_opndate, 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'AUDITDATE', '', v_opndate, 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'MRLOANLIMIT', '', '10000000000000', 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'T0LOANLIMIT', '', '10000000000000', 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'LANGUAGE', '', '001', 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'BANKCODE', '', '000', 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'VALUDADDED', '', '000', 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'TLID', '', '' || v_tlid || '', 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'MARRIED', '', '004', 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'OCCUPATION', '', '000', 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'EDUCATION', '', '000', 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'CUSTTYPE', '', 'I', 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'EXPERIENCECD', '', '00000', 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'STATUS', '', 'P', 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'ACTIVESTS', '', 'N', 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'MANAGETYPE', '', 'A', 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'ISBANKING', '', 'N', 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'RISKLEVEL', '', 'O', 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'TRADINGCODEDT', '', '23/07/2014', 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'ISCHKONLIMIT', '', 'Y', 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'ONLINELIMIT', '', '0', 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'MARGINALLOW', '', 'Y', 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
    values ('CFMAST', 'CUSTID = ''' || v_custid || '''', '' || v_tlid || '', v_opndate, 'Y', '', null, 0, 'OPNDATE', '', v_opndate, 'ADD', '', '', to_char(SYSTIMESTAMP,'hh:mm:ss'), '');
    --- them thong tin chuyen khoang truc tuyen
     -----------them dia chi lien he
     select count(*) into v_count from CRBBANKLIST ;
     if v_count = 1 then
        select bankname,bankcode into v_strbankname, v_strbankcode from CRBBANKLIST;
     else
        v_strbankname := null;
        v_strbankcode := null;
     end if;

        select seq_cfotheracc.NEXTVAL into v_strCFOTHERACCid from dual;
        SELECT max(vcbaccount), max(idcode) into V_strvcbaccount, v_strIDCODE
        FROM cfmasttemp where idcode = p_txmsg.txfields('88').value AND status = 'C' and vcbaccount is not null;

        INSERT INTO CFOTHERACC (AUTOID,CFCUSTID,CIACCOUNT,CINAME,CUSTID,BANKACC,BANKACNAME,BANKNAME,TYPE,ACNIDCODE,ACNIDDATE,ACNIDPLACE,FEECD,CITYEF,CITYBANK,BANKCODE)
        values (v_strCFOTHERACCid, v_custid,NULL, NULL, NULL, V_strvcbaccount, v_fullname, v_strbankname, '1',v_strIDCODE,v_IDDATE,v_IDPLACE,null, 'HN','VCB',v_strbankcode);

        insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
        values ('CFMAST', 'CUSTID = '''||v_custid||'''',v_tlid, v_opndate, 'Y', null, null, 0, 'CFCUSTID', null, v_custid, 'ADD', 'CFOTHERACC',  'AUTOID = '''||v_strCFOTHERACCid ||'''', to_char(SYSTIMESTAMP,'hh:mm:ss'), null);
        insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
        values ('CFMAST', 'CUSTID = '''||v_custid||'''',v_tlid, v_opndate, 'Y', null, null, 0, 'BANKACC', null, V_strvcbaccount, 'ADD', 'CFOTHERACC',  'AUTOID = '''||v_strCFOTHERACCid ||'''', to_char(SYSTIMESTAMP,'hh:mm:ss'), null);
        insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
        values ('CFMAST', 'CUSTID = '''||v_custid||'''',v_tlid, v_opndate, 'Y', null, null, 0, 'BANKNAME', null, v_strbankname, 'ADD', 'CFOTHERACC',  'AUTOID = '''||v_strCFOTHERACCid ||'''', to_char(SYSTIMESTAMP,'hh:mm:ss'), null);
        insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
        values ('CFMAST', 'CUSTID = '''||v_custid||'''',v_tlid, v_opndate, 'Y', null, null, 0, 'CITYBANK', null, 'VCB', 'ADD', 'CFOTHERACC',  'AUTOID = '''||v_strCFOTHERACCid ||'''', to_char(SYSTIMESTAMP,'hh:mm:ss'), null);
        insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
        values ('CFMAST', 'CUSTID = '''||v_custid||'''',v_tlid, v_opndate, 'Y', null, null, 0, 'BANKCODE', null, v_strbankcode, 'ADD', 'CFOTHERACC',  'AUTOID = '''||v_strCFOTHERACCid ||'''', to_char(SYSTIMESTAMP,'hh:mm:ss'), null);

    -----------them dia chi lien he
        SELECT seq_cfcontact.nextval INTO v_cfcontactautoid FROM dual;
        insert into CFCONTACT (AUTOID, CUSTID, TYPE, PERSON, ADDRESS, PHONE, FAX, EMAIL, DESCRIPTION)
    SELECT v_cfcontactautoid, v_custid,'001', fullname, address, mobile, NULL, email, 'Tai khoan mo tu online'
        FROM cfmasttemp
    where idcode = p_txmsg.txfields('88').value AND status = 'C';


        insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
        values ('CFMAST', 'CUSTID = '''||v_custid||'''',v_tlid,v_opndate, 'Y', null, null, 0, 'CUSTID', null, v_custid, 'ADD', 'CFCONTACT', 'AUTOID = '''||v_cfcontactautoid ||'''', to_char(SYSTIMESTAMP,'hh:mm:ss'), null);

        insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
        values ('CFMAST', 'CUSTID = '''||v_custid||'''',v_tlid,v_opndate, 'Y', null, null, 0, 'TYPE', null, '001', 'ADD', 'CFCONTACT',  'AUTOID = '''||v_cfcontactautoid ||'''',  to_char(SYSTIMESTAMP,'hh:mm:ss'), null);

        insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
        values ('CFMAST', 'CUSTID = '''||v_custid||'''',v_tlid, v_opndate, 'Y', null, null, 0, 'PERSON', null, v_fullname, 'ADD', 'CFCONTACT',  'AUTOID = '''||v_cfcontactautoid ||'''', to_char(SYSTIMESTAMP,'hh:mm:ss'), null);

        insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
        values ('CFMAST', 'CUSTID = '''||v_custid||'''',v_tlid, v_opndate, 'Y', null, null, 0, 'ADDRESS', null, V_ADDRESS, 'ADD', 'CFCONTACT',  'AUTOID = '''||v_cfcontactautoid ||'''', to_char(SYSTIMESTAMP,'hh:mm:ss'), null);

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
        values ('CFMAST', 'CUSTID = '''||v_custid||'''',v_tlid, v_opndate, 'Y', null, null, 0, 'PHONE', null, v_MOBILESMS, 'ADD', 'CFCONTACT',  'AUTOID = '''||v_cfcontactautoid ||'''', to_char(SYSTIMESTAMP,'hh:mm:ss'), null);

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
        values ('CFMAST', 'CUSTID = '''||v_custid||'''',v_tlid, v_opndate, 'Y', null, null, 0, 'EMAIL', null, v_email, 'ADD', 'CFCONTACT',  'AUTOID = '''||v_cfcontactautoid ||'''', to_char(SYSTIMESTAMP,'hh:mm:ss'), null);

    insert into maintain_log (TABLE_NAME, RECORD_KEY, MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, MOD_NUM, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG, CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME, APPROVE_TIME)
        values ('CFMAST', 'CUSTID = '''||v_custid||'''',v_tlid, v_opndate, 'Y', null, null, 0, 'DESCRIPTION', null, 'Tai khoan mo tu online', 'ADD', 'CFCONTACT',  'AUTOID = '''||v_cfcontactautoid ||'''', to_char(SYSTIMESTAMP,'hh:mm:ss'), null);

        ------------------------------------

    update cfmasttemp set status = 'A', pstatus = pstatus || status where idcode = p_txmsg.txfields('88').value AND status = 'C';

    ---


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
         plog.init ('TXPKS_#0037EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#0037EX;
/
