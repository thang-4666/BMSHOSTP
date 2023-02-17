SET DEFINE OFF;
CREATE OR REPLACE PACKAGE TXPKS_#0169EX
/**----------------------------------------------------------------------------------------------------
 ** Package: TXPKS_#0169EX
 ** and is copyrighted by FSS.
 **
 **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
 **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
 **    graphic, optic recording or otherwise, translated in any language or computer language,
 **    without the prior written permission of Financial Software Solutions. JSC.
 **
 **  MODIFICATION HISTORY
 **  Person      Date           Comments
 **  System      14/09/2021     Created
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


CREATE OR REPLACE PACKAGE BODY TXPKS_#0169EX
IS
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

   c_reqid            CONSTANT CHAR(2) := '03';
   c_txdate           CONSTANT CHAR(2) := '01';
   c_confirmstatus    CONSTANT CHAR(2) := '80';
   c_fullname         CONSTANT CHAR(2) := '04';
   c_idcode           CONSTANT CHAR(2) := '05';
   c_iddate           CONSTANT CHAR(2) := '06';
   c_idplace          CONSTANT CHAR(2) := '07';
   c_idtype           CONSTANT CHAR(2) := '13';
   c_customertype     CONSTANT CHAR(2) := '10';
   c_brid             CONSTANT CHAR(2) := '31';
   c_mobile           CONSTANT CHAR(2) := '21';
   c_email            CONSTANT CHAR(2) := '22';
   c_address          CONSTANT CHAR(2) := '08';
   c_dateofbirth      CONSTANT CHAR(2) := '11';
   c_sex              CONSTANT CHAR(2) := '09';
   c_province         CONSTANT CHAR(2) := '12';
   c_desc             CONSTANT CHAR(2) := '30';
FUNCTION fn_txPreAppCheck(p_txmsg in out tx.msg_rectype,p_err_code out varchar2)
RETURN NUMBER
IS
    l_reqid      varchar2(20);
    l_count      number;
    v_checkNameBirthday number;
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

    l_reqid       := p_txmsg.txfields('03').VALUE;
    if p_txmsg.deltd <> 'Y' then
        select count(*) into l_count from registeronline where reqid = l_reqid and status like 'P%';
        if l_count = 0 then
           p_err_code  := '-200608';
           plog.setendsection (pkgctx, 'fn_txPreAppCheck');
           RETURN errnums.C_BIZ_RULE_INVALID;
        end if;

        if p_txmsg.txfields('80').value = 'CONF' THEN
            v_checkNameBirthday := FN_CHECK_CFMAST_SAMENAMEBIRTH('----','086C------',p_txmsg.txfields('04').VALUE,p_txmsg.txfields('11').VALUE);
            if nvl(v_checkNameBirthday,0) > 0 then
                p_txmsg.txWarningException('-200113').value:= cspks_system.fn_get_errmsg('-200113');
                p_txmsg.txWarningException('-200113').errlev:= '1';
            end if;
        end if;
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
  l_reqid        varchar2(20);
  v_busdate      date;
  l_custid       varchar2(10);
  l_corebank     varchar2(1);
  l_autoadv      varchar2(1);
  l_atype        varchar2(5);
  p_tlid         varchar2(5);
  l_citype       varchar2(10);
  v_max_number   number;
  l_custodycd    varchar2(20);
  l_afacctno     varchar2(20);
  l_fullname     varchar2(1000);
  l_idcode       varchar2(20);
  l_iddate       varchar2(20);
  l_idtype       varchar2(10);
  l_mobile       varchar2(20);
  l_email        varchar2(100);
  l_address      varchar2(1000);
  l_dateofbirth  varchar2(20);
  l_sex          varchar2(20);
  l_province     varchar2(100);
  l_customertype varchar2(10);
  l_brid         varchar2(10);
  v_actype       varchar2(10);
  l_careby       varchar2(10);
  l_idplace      varchar2(1000);
  l_country      varchar2(100);
  l_service      varchar2(10);
  l_menthod      varchar2(10);
  l_orgLoginpwd   varchar2(20);
  l_Loginpwd      varchar2(1000);
  l_orgTradingpwd   varchar2(20);
  l_Tradingpwd      varchar2(1000);
  v_count1          number;
  v_count2          number;
  v_strSex          varchar2(50);
  v_chinhanh        varchar2(1000);
  v_diachi          varchar2(1000);
  l_tradingpass_send varchar2(50);
  l_datasourcesms   varchar2(2000);
  l_olautoid        number;
  v_sdt             varchar2(20);
  l_smartotp        varchar2(10);
  l_check           varchar2(1);
  v_count number;
  l_aftype varchar2(10);
  p_apptlid varchar2(20);
  l_balance number;
  l_isPM varchar2(1);
  l_strSQL        varchar2(3000);
  l_strObjectName     varchar2(1000);
  l_strRecordKey      varchar2(1000);
  l_strChildObjName   varchar2(1000);
  l_strChildRecordKey varchar2(1000);
  l_cftype VARCHAR2(20);
  l_orgPINpwd VARCHAR2(20);
  l_PINpass_send varchar2(100);
  l_ekyc_cus varchar2(10);
  l_datasource varchar2(2000);
  l_emailmg varchar2(100);
  p_offid varchar2(5);
  l_RejectReason VARCHAR2(3000); --BMSSUP-99

BEGIN
    plog.setbeginsection (pkgctx, 'fn_txAftAppUpdate');
    plog.debug (pkgctx, '<<BEGIN OF fn_txAftAppUpdate');
   /***************************************************************************************************
    ** PUT YOUR SPECIFIC AFTER PROCESS HERE. DO NOT COMMIT/ROLLBACK HERE, THE SYSTEM WILL DO IT
    ***************************************************************************************************/
    l_reqid          := p_txmsg.txfields('03').VALUE;
    l_fullname       := p_txmsg.txfields('04').VALUE;
    l_idcode         := p_txmsg.txfields('05').VALUE;
    l_iddate         := p_txmsg.txfields('06').VALUE;
    l_idplace        := p_txmsg.txfields('07').VALUE;
    l_idtype         := p_txmsg.txfields('13').VALUE;
    l_mobile         := p_txmsg.txfields('21').VALUE;
    --l_email          := p_txmsg.txfields('22').VALUE;
    l_address        := p_txmsg.txfields('08').VALUE;
    l_dateofbirth    := p_txmsg.txfields('11').VALUE;
    l_sex            := p_txmsg.txfields('09').VALUE;
    l_province       := p_txmsg.txfields('12').VALUE;
    l_customertype   := p_txmsg.txfields('10').VALUE;
    l_brid           := p_txmsg.txfields('31').VALUE;

    SELECT to_date(varvalue,systemnums.c_date_format) INTO v_busdate
    FROM sysvar
    WHERE varname = 'CURRDATE' AND grname = 'SYSTEM';

    begin
        select varvalue into l_ekyc_cus from sysvar where varname='EKYC_CUSTODYCD';
    EXCEPTION
    WHEN OTHERS THEN
        l_ekyc_cus := '69';
    end;

    SELECT nvl(CAREBY,'0002') INTO l_careby FROM BRGRP WHERE BRID = l_brid;

    v_actype  := '0001';
    select b.aftype into v_actype from brgrp b where brid = l_brid;

    p_tlid := p_txmsg.tlid;
    p_offid := p_txmsg.offid;

    SELECT VARVALUE into v_max_number FROM SYSVAR S WHERE S.VARNAME='MAX_NUMBER_VALUE';
    SELECT COUNTRY, AUTOID, EMAIL INTO l_country, l_olautoid, l_email from REGISTERONLINE WHERE REQID = l_reqid;

    ---- SINH SO CUSTID, CUSTODYCD, AFACCTNO
    BEGIN

    SELECT SUBSTR(INVACCT,1,4)|| l_ekyc_cus || lpad(MAX(ODR)+1,4,0) into l_custodycd FROM
    (SELECT ROWNUM ODR, INVACCT
    FROM (SELECT CUSTODYCD INVACCT FROM (select custodycd from cfmast
                                         union
                                         select custodycd from registeronline
                                         where   AUTOID not in (select OLAUTOID from CFMAST CF
                                                                where CF.OPENVIA='E'
                                                                  AND CF.CUSTODYCD IS NOT NULL)
                                         union
                                         select username from cfmast
                                         )CFMAST
    WHERE SUBSTR(CUSTODYCD,1,6)= '086' || 'C' || l_ekyc_cus AND TRIM(TO_CHAR(TRANSLATE(SUBSTR(CUSTODYCD,7,4),'0123456789',' '))) IS NULL
    ORDER BY CUSTODYCD) DAT
    WHERE TO_NUMBER(SUBSTR(INVACCT,7,4))=ROWNUM) INVTAB
    GROUP BY SUBSTR(INVACCT,1,4);

    exception when NO_DATA_FOUND then
      SELECT VARVALUE||'C' || l_ekyc_cus || '0001' into l_custodycd FROM SYSVAR WHERE VARNAME='COMPANYCD'AND GRNAME='SYSTEM';
    END;

    BEGIN
      SELECT SUBSTR(INVACCT,1,4) || TRIM(TO_CHAR(MAX(ODR)+1,'000000'))  into l_custid FROM
              (SELECT ROWNUM ODR, INVACCT
              FROM (SELECT CUSTID INVACCT FROM CFMAST WHERE SUBSTR(CUSTID,1,4)= trim(l_brid) ORDER BY CUSTID) DAT
              WHERE TO_NUMBER(SUBSTR(INVACCT,5,6))=ROWNUM) INVTAB
              GROUP BY SUBSTR(INVACCT,1,4);

    exception when NO_DATA_FOUND then
      l_custid     := l_brid||'000001';
    END;

    BEGIN
      SELECT SUBSTR(INVACCT,1,4) || lpad(MAX(ODR)+1,6,0) into l_afacctno
      FROM (SELECT ROWNUM ODR, INVACCT
            FROM (SELECT ACCTNO INVACCT FROM AFMAST WHERE SUBSTR(ACCTNO,1,4)= '0001' ORDER BY ACCTNO) DAT
            WHERE TO_NUMBER(SUBSTR(INVACCT,5,6))=ROWNUM) INVTAB
      GROUP BY SUBSTR(INVACCT,1,4);

    exception when NO_DATA_FOUND then
      l_afacctno := l_brid||'000001';
    END;

   ---------------------------------------------- MO TAI KHOAN -------------------------------------------------
    plog.error ('custid: ' || l_custid || 'username: ' || l_custodycd || 'brid: ' || l_brid);

  IF p_txmsg.txfields('80').value = 'CONF' THEN
    SELECT VARVALUE into l_cftype FROM SYSVAR S WHERE S.VARNAME='EKYC_CFTYPE';
    INSERT INTO CFMAST (CUSTID, CUSTODYCD, FULLNAME, MNEMONIC, IDCODE, IDDATE, IDPLACE,IDEXPIRED, IDTYPE, COUNTRY, ADDRESS, mobilesms, EMAIL, OPNDATE, TRADINGCODEDT, activedate,
    CAREBY, BRID, STATUS,PSTATUS, PROVINCE, CLASS, GRINVESTOR, INVESTRANGE, POSITION, TIMETOJOIN, STAFF, SEX, SECTOR, FOCUSTYPE ,BUSINESSTYPE,
    INVESTTYPE, EXPERIENCETYPE, INCOMERANGE, ASSETRANGE, LANGUAGE, BANKCODE, MARRIED, ISBANKING, DATEOFBIRTH,CUSTTYPE,CUSTATCOM,
    valudadded,occupation,education,experiencecd,tlid,risklevel,marginallow,t0loanlimit,mrloanlimit,USERNAME,
    --marginlimit, tradelimit, advancelimit, repolimit, depositlimit
    Mobile, OPENVIA, OLAUTOID,actype)
    VALUES (l_custid, l_custodycd, INITCAP(TRIM(l_fullname)), fn_CutOffUTF8(upper(l_fullname)), l_idcode, to_date(l_iddate,'dd/mm/rrrr'), l_idplace,
            case when l_idtype = '001' then add_months(to_date(l_iddate,'dd/mm/rrrr'), 15*12)
                 when l_idtype = '008' and MONTHS_BETWEEN(to_date(l_iddate,'dd/mm/rrrr'),to_date(l_dateofbirth,'dd/mm/rrrr')) < 276  then add_months(to_date(l_dateofbirth,'dd/mm/rrrr'), 25*12)
                 when l_idtype = '008' and (MONTHS_BETWEEN(to_date(l_iddate,'dd/mm/rrrr'),to_date(l_dateofbirth,'dd/mm/rrrr')) >= 276 AND MONTHS_BETWEEN(to_date(l_iddate,'dd/mm/rrrr'),to_date(l_dateofbirth,'dd/mm/rrrr')) <= 300 ) then add_months(to_date(l_dateofbirth,'dd/mm/rrrr'), 40*12)
                 when l_idtype = '008' and (MONTHS_BETWEEN(to_date(l_iddate,'dd/mm/rrrr'),to_date(l_dateofbirth,'dd/mm/rrrr')) > 300 AND MONTHS_BETWEEN(to_date(l_iddate,'dd/mm/rrrr'),to_date(l_dateofbirth,'dd/mm/rrrr')) < 456 ) then add_months(to_date(l_dateofbirth,'dd/mm/rrrr'), 40*12)
                 when l_idtype = '008' and (MONTHS_BETWEEN(to_date(l_iddate,'dd/mm/rrrr'),to_date(l_dateofbirth,'dd/mm/rrrr')) >= 456 AND MONTHS_BETWEEN(to_date(l_iddate,'dd/mm/rrrr'),to_date(l_dateofbirth,'dd/mm/rrrr')) <= 480 ) then add_months(to_date(l_dateofbirth,'dd/mm/rrrr'), 60*12)
                 when l_idtype = '008' and (MONTHS_BETWEEN(to_date(l_iddate,'dd/mm/rrrr'),to_date(l_dateofbirth,'dd/mm/rrrr')) > 480 AND MONTHS_BETWEEN(to_date(l_iddate,'dd/mm/rrrr'),to_date(l_dateofbirth,'dd/mm/rrrr')) < 696 ) then add_months(to_date(l_dateofbirth,'dd/mm/rrrr'), 60*12)
                 when l_idtype = '008' and (MONTHS_BETWEEN(to_date(l_iddate,'dd/mm/rrrr'),to_date(l_dateofbirth,'dd/mm/rrrr')) >= 696 ) then add_months(to_date(l_dateofbirth,'dd/mm/rrrr'), 90*12) end,
     l_idtype, l_country, l_address,
    l_mobile, l_email, v_busdate, v_busdate, v_busdate, l_careby, l_brid,'A','A',l_province,'001','001','001','001','001','001',l_sex
    ,'001','001','009','001','001','001','001','001','000','004','N',to_date(l_dateofbirth,'dd/mm/rrrr'),case when l_customertype = '0001' then 'I' else 'B' END,'Y',
    '000','005','004','00000',p_tlid,'M','Y',10000000000000,10000000000000,l_custodycd,
    --v_max_number, v_max_number, v_max_number, v_max_number, v_max_number,
    '', 'E', l_olautoid, l_cftype );

    -- INSERT VAO MAINTAIN_LOG CFMAST

    -- Log maintainlog mot so field quan trong cua cfmast
      Begin
                l_strSQL := 'SELECT CUSTID,FULLNAME,DATEOFBIRTH,IDTYPE,IDCODE,IDDATE,IDPLACE, ADDRESS,PHONE,MOBILE,MOBILESMS,EMAIL,
                                    CUSTTYPE,TLID,ISBANKING,genencryptpassword(PIN) PIN,USERNAME,OPNDATE,OPENVIA,VAT,ACTIVESTS,CUSTODYCD,TRADEONLINE,
                                    T0LOANLIMIT, MRLOANLIMIT
                                    FROM CFMAST WHERE CUSTID=''' || l_CUSTID || '''';
                l_strObjectName := 'CFMAST';
                l_strRecordKey  := 'CUSTID';
                fopks_ekycapi.pr_maintainlog(l_strSQL, l_strObjectName, l_strRecordKey, l_CUSTID, '','','', p_tlid, to_char(v_busdate,'DD/MM/RRRR'),p_offid);
      End;

     UPDATE REGISTERONLINE SET STATUS ='C', last_change = CURRENT_TIMESTAMP WHERE REQID = l_reqid;
     UPDATE APIOPENACCOUNT SET STATUS ='C', last_change = CURRENT_TIMESTAMP WHERE REQID = l_reqid;
     UPDATE APIOPENACCOUNTLOG SET STATUS ='C', last_change = CURRENT_TIMESTAMP WHERE REQID = l_reqid;
    --------------Sinh AF-----------
     l_corebank :='N';
     l_autoadv  :='N';
     v_actype   := '0001';
     select b.aftype into v_actype from brgrp b where brid = l_brid;

     SELECT AFTYPE INTO l_atype FROM AFTYPE WHERE ACTYPE= v_actype;
     SELECT corebank into  l_corebank FROM AFTYPE WHERE ACTYPE= v_actype;
     BEGIN
        select substr(registerservices,2,1) into l_check from REGISTERONLINE where REQID = l_reqid;
        exception WHEN OTHERS THEN
            l_check := 'N';
     END;

       --- SINH TAI KHOAN AFMAST

       --Neu chua co tieu khoan thi mo moi
       for rec in (
        select aft.actype, aft.AFTYPE,aft.corebank,aft.autoadv,aft.citype,aft.k1days,aft.k2days,
                aft.producttype, substr(cf.custodycd,4,1) custype,
                cf.brid,cf.careby,cf.tlid,
                mrt.MRIRATE,mrt.MRMRATE,mrt.MRLRATE,mrt.MRCRLIMIT,
                mrt.MRLMMAX,mrt.mriratio,mrt.mrmratio,mrt.mrlratio,mrt.mrcrate,mrt.mrwrate,mrt.mrexrate,
                nvl(cf.last_ofid,nvl(cf.approveid,cf.tlid)) appid
         from cfmast cf, cfaftype cfaf , aftype aft, mrtype mrt
         where cf.actype = cfaf.cftype and cfaf.aftype = aft.actype
             and aft.mrtype = mrt.actype and mrt.mrtype ='N' and PRODUCTTYPE not in ('QT','QD')
             and cf.custid =l_custid and aft.actype = v_actype
        )
        loop

         ---- Kiem tra truong hop da co CFMAST nhung chua co AFMAST thi moi sinh
         select count(1) into v_count from afmast where custid = l_custid and actype = rec.actype;

         if v_count =0 then
            l_aftype:=rec.AFTYPE;
            l_corebank:=rec.corebank;
            --l_autoadv:=rec.autoadv;
            l_autoadv := 'N';
            --l_custid:=p_CUSTID;
            p_tlid:=rec.tlid;
            p_apptlid := rec.appid;
            if rec.custype = 'P' then
                l_balance:= 1000000000000;
                l_isPM:= 'Y';
            else
                l_balance:=0;
                l_isPM:='N';
            end if;

         INSERT INTO AFMAST (ACTYPE,CUSTID,ACCTNO,AFTYPE,
            BANKACCTNO,BANKNAME,STATUS,lastdate,bratio,k1days,k2days,
            ADVANCELINE,DESCRIPTION,ISOTC,PISOTC,OPNDATE,VIA,producttype,
            MRIRATE,MRMRATE,MRLRATE,MRCRLIMIT,MRCRLIMITMAX,
            mriratio,mrmratio,mrlratio,mrcrate,mrwrate,mrexrate,
            T0AMT,BRID,CAREBY,corebank,AUTOADV,TLID,TERMOFUSE,isdebtt0,isPM)
            VALUES(rec.actype,l_custid,l_afacctno,l_aftype, '' ,'---', 'A',TO_DATE( v_busdate ,'DD/MM/RRRR'),100,rec.k1days,rec.k2days,
            0,'','Y','N',TO_DATE( v_busdate ,'DD/MM/RRRR'),'E',rec.producttype,
            rec.MRIRATE,rec.MRMRATE,rec.MRLRATE,rec.MRCRLIMIT,rec.MRLMMAX,
            rec.mriratio,rec.mrmratio,rec.mrlratio,rec.mrcrate,rec.mrwrate,rec.mrexrate,
            0,rec.brid, rec.careby,l_corebank,l_AUTOADV, rec.tlid,'001','N',l_isPM);

       -- INSERT VAO MAINTAIN_LOG AFMAST

         -- Log maintainlog mot so field quan trong cua afmast
            Begin
                l_strSQL := 'SELECT ACTYPE,ACCTNO,AFTYPE,BANKACCTNO,BANKNAME,AUTOADV,ALTERNATEACCT,VIA,COREBANK,TLID,BRID,CAREBY FROM AFMAST WHERE ACCTNO=''' || l_afacctno || '''';
                l_strObjectName := 'CFMAST';
                l_strRecordKey  := 'CUSTID';
                l_strChildObjName := 'AFMAST';
                l_strChildRecordKey  := 'ACCTNO';
                fopks_ekycapi.pr_maintainlog(l_strSQL, l_strObjectName, l_strRecordKey, l_CUSTID, l_strChildObjName,l_strChildRecordKey,l_afacctno, p_tlid,to_char(v_busdate,'DD/MM/RRRR'),p_offid);
            End;

       --- lay CITYPE de sinh tai khoan CI
       SELECT CITYPE into l_citype FROM AFTYPE WHERE ACTYPE = v_actype ;
       --l_citype:=rec.citype;

       --- Sinh tai khoan CI
       INSERT INTO CIMAST (ACTYPE,ACCTNO,CCYCD,AFACCTNO,CUSTID,OPNDATE,CLSDATE,LASTDATE,DORMDATE,STATUS,PSTATUS,BALANCE,CRAMT,DRAMT,CRINTACR,CRINTDT,ODINTACR,ODINTDT,AVRBAL,MDEBIT,MCREDIT,AAMT,RAMT,BAMT,EMKAMT,MMARGINBAL,MARGINBAL,ICCFCD,ICCFTIED,ODLIMIT,ADINTACR,ADINTDT,FACRTRADE,FACRDEPOSITORY,FACRMISC,MINBAL,ODAMT,NAMT,FLOATAMT,HOLDBALANCE,PENDINGHOLD,PENDINGUNHOLD,COREBANK,RECEIVING,NETTING,MBLOCK,OVAMT,DUEAMT,T0ODAMT,MBALANCE,MCRINTDT,TRFAMT,LAST_CHANGE,DFODAMT,DFDEBTAMT,DFINTDEBTAMT,CIDEPOFEEACR)
       VALUES(l_citype,l_afacctno,'00',l_afacctno,l_custid,TO_DATE(v_busdate,'DD/MM/RRRR'),NULL,TO_DATE(v_busdate,'DD/MM/RRRR'),NULL,'A',NULL,0,0,0,0,TO_DATE(v_busdate,'DD/MM/RRRR'),0,TO_DATE(v_busdate,'DD/MM/RRRR'),0,0,0,0,0,0,0,0,0,NULL,'Y',0,0,NULL,0,0,0,0,0,0,0,0,0,0,'N',0,0,0,0,0,0,0,TO_DATE(v_busdate,'DD/MM/RRRR'),0,TO_DATE(v_busdate,'DD/MM/RRRR'),0,0,0,0);

       end if; ---- Kiem tra truong hop da co CFMAST nhung chua co AFMAST thi moi sinh

       UPDATE apiOpenAccount SET afacctno = l_afacctno, custodycd = l_custodycd, status = 'A' WHERE REQID = l_reqid;
      UPDATE apiOpenAccountlog SET afacctno = l_afacctno, custodycd = l_custodycd, status = 'A' WHERE REQID = l_reqid;

      END LOOP;

   ---------------------update thong tin cf,af----------------------------------------
   IF l_customertype = '0001' THEN
    begin
        SELECT service , menthod, SMARTOTP into l_service, l_menthod, l_smartotp FROM EKYCACCT_EX where reqid = l_reqid;
    exception WHEN OTHERS THEN
        l_service := '';
        l_menthod := '';
        l_smartotp := '';
    end;
      if instr(l_service,'P') <> 0 then
         update afmast set autoadv ='Y' where acctno = l_afacctno;
      else
         update afmast set autoadv ='N' where acctno = l_afacctno;
      end if;
      if instr(l_service,'T') <> 0 then
         update cfmast set tradetelephone ='Y' where custodycd = l_custodycd;
      else
         update cfmast set tradetelephone ='N' where custodycd = l_custodycd;
      end if;
      if instr(l_service,'O') <> 0 then
         update cfmast set tradeonline ='Y' where custodycd = l_custodycd;
      else
         update cfmast set tradeonline ='N' where custodycd = l_custodycd;
      end if;

      FOR rec IN
      (
        SELECT code FROM templates WHERE require_register = 'Y' AND isdefault = 'Y'
        AND code NOT IN (SELECT template_code FROM aftemplates WHERE custid = l_custid)
        )
      LOOP
        INSERT INTO aftemplates (autoid,custid,template_code)
        VALUES (seq_aftemplates.nextval, l_custid, rec.code);
      END LOOP;

      update afmast set brid = l_brid, via ='C' where acctno = l_afacctno;

   --------------Sinh dich vu truc tuyen------------
      Delete from otright where cfcustid = l_custid;
      INSERT INTO otright (AUTOID, CFCUSTID, AUTHCUSTID,AUTHTYPE,VALDATE,EXPDATE,DELTD, VIA, LASTDATE,LASTCHANGE)
      VALUES(seq_otright.nextval,l_custid, l_custid, '1',v_busdate,ADD_MONTHS(v_busdate,30*12),'N','A',NULL,v_busdate);
      if l_smartotp <> '1' then
      INSERT INTO otright (AUTOID, CFCUSTID, AUTHCUSTID,AUTHTYPE,VALDATE,EXPDATE,DELTD, VIA, LASTDATE,LASTCHANGE)
      VALUES(seq_otright.nextval,l_custid, l_custid, l_smartotp,v_busdate,ADD_MONTHS(v_busdate,30*12),'N','O',NULL,v_busdate);
      end if;

      --Tao otrightdtl
      Delete from otrightdtl where cfcustid = l_custid;
        for rec in
        (
            SELECT * FROM ALLCODE WHERE CDTYPE = 'SA' AND CDNAME = 'OTFUNC' AND CDUSER='Y' ORDER BY LSTODR
        )loop
            IF rec.cdval NOT IN ('COND_ORDER','ORDINPUT','GROUP_ORDER','ISSUEINPUT') THEN
                insert into otrightdtl(autoid,cfcustid,authcustid,otmncode,otright,deltd,via)
                VALUES( seq_otrightdtl.nextval,l_custid,l_custid,rec.cdval,'YYYYYNYNN','N','A');
                if l_smartotp <> '1' then
                    insert into otrightdtl(autoid,cfcustid,authcustid,otmncode,otright,deltd,via)
                    VALUES( seq_otrightdtl.nextval,l_custid,l_custid,rec.cdval,'YYYYNNNNN','N','O');
                end if;
            ELSE
                insert into otrightdtl(autoid,cfcustid,authcustid,otmncode,otright,deltd,via)
                VALUES( seq_otrightdtl.nextval,l_custid,l_custid,rec.cdval,'YYYYYNYNN','N','A');
                if l_smartotp <> '1' then
                    insert into otrightdtl(autoid,cfcustid,authcustid,otmncode,otright,deltd,via)
                    VALUES( seq_otrightdtl.nextval,l_custid,l_custid,rec.cdval,'YYYYNNNNY','N','O');
                end if;
            END IF;
        end loop;

   if instr(l_service,'O') <> 0 then
      l_orgLoginpwd  := cspks_system.fn_PasswordGenerator(6);
      l_Loginpwd     := genencryptpassword(trim(l_orgLoginpwd));
      l_orgTradingpwd  := cspks_system.fn_PasswordGenerator(6);
      l_Tradingpwd     := genencryptpassword(trim(l_orgTradingpwd));

      update userlogin set status = 'E' where USERNAME = l_custodycd;
      --28/12/2021: Dac thu cua BMS Userlogin pv_SMARTOTP = 1 moi chuyen tien tren web khong loi
      INSERT INTO userlogin (USERNAME,HANDPHONE,LOGINPWD,TRADINGPWD,AUTHTYPE,STATUS,LOGINSTATUS,LASTCHANGED,NUMBEROFDAY,LASTLOGIN,ISRESET,ISMASTER,TOKENID)
      VALUES(l_custodycd,NULL,l_Loginpwd,l_Tradingpwd,'1'/*l_smartotp*/,'A','O',v_busdate,30,v_busdate,'Y','N','{MSBS{SMS{'||NVL(l_mobile,'SDT')||'}}}');
   end if;

   if instr(l_service,'T') <> 0 then
        l_orgPINpwd := cspks_system.fn_PasswordGenerator(6);

        update cfmast set pin = l_orgPINpwd where custodycd = l_custodycd;

        l_PINpass_send := 'BMSC thong bao: Mat khau GD qua dien thoai cua so tai khoan ' || l_custodycd || ' la: ' || l_orgPINpwd || '. ';
        nmpks_ems.InsertEmailLog(l_mobile, '314S', l_PINpass_send, '');

    end if;

      --Tao Emaillog
        fopks_ekycapi.GenTemplate313E(l_fullname,l_custodycd,l_orgLoginpwd,l_orgTradingpwd,l_email);

    /*If length(l_mobile)>0 then
       l_tradingpass_send := ' - Mat khau dat lenh: ' || l_orgTradingpwd;
       l_datasourcesms:='select ''' || l_custodycd || ''' username, ''' || l_orgLoginpwd || ''' loginpwd, ''' || l_tradingpass_send || ''' tradingpwd from dual';
       nmpks_ems.InsertEmailLog(l_mobile, '304B', l_datasourcesms, '');
    end if;*/

     END IF;
  ELSE
      DELETE REGISTERONLINE WHERE reqid = l_reqid;
      DELETE APIOPENACCOUNT WHERE reqid = l_reqid;
      DELETE apiOpenAccountlog WHERE reqid = l_reqid;
      update registeronlinelog set DELETEDATE = v_busdate, last_change = CURRENT_TIMESTAMP where reqid = l_reqid;

      begin
        select varvalue into l_emailmg from sysvar where varname='EKYC_EMAIL';
      exception WHEN OTHERS THEN
             l_emailmg := '';
      end;
      l_RejectReason := p_txmsg.txfields('32').VALUE;
      begin
        select nvl(l_RejectReason,cdcontent) into l_RejectReason from allcode where cdname = 'REASON_REJECTEMAIL' and cdtype = 'CF' and cdval = 'P';
      exception WHEN OTHERS THEN
             l_RejectReason := p_txmsg.txfields('32').VALUE;
      end;

      l_datasource := 'select '''||l_fullname||''' fullname, '''||l_RejectReason||''' reason from dual';
         nmpks_ems.InsertEmailLog(l_email, '316E', l_datasource, '');
         nmpks_ems.InsertEmailLog(l_emailmg, '316E', l_datasource, '');

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
         plog.init ('TXPKS_#0169EX',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
END TXPKS_#0169EX;
/
