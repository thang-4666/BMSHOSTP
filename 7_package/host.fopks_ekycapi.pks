SET DEFINE OFF;
CREATE OR REPLACE PACKAGE fopks_ekycapi is

  -- Author  : TanPN
  -- Created : 30/09/2021 10:45:00 PM
  -- Purpose :

    C_LANG_VI  constant varchar2(10) := 'vi-VN';
    C_LANG_EN  constant varchar2(10) := 'en';
    C_MAX_RETRY  constant NUMBER := 3;
    C_ERR_OTP_INVALID constant NUMBER := -901216;
    C_ERR_TLNAME_INVALID constant NUMBER := 101;
    C_ERR_PIN_INVALID constant NUMBER := 102;
  type ref_cursor is ref cursor;

  --------------------------------Lay thong tin chi nhanh--------------------------
PROCEDURE pr_get_brachinfo( p_refcursor in out ref_cursor,
                            p_iscareby  in varchar2);
  --------------------------------Lay thong tin quoc tich--------------------------
PROCEDURE pr_get_country( p_refcursor in out ref_cursor);
  --------------------------------Lay thong tin tinh thanh--------------------------
PROCEDURE pr_get_province( p_refcursor in out ref_cursor);
  --------------------------------Mo TK-----------------------------------------------------
PROCEDURE pr_checkacct_control (pv_typeinvestor         IN VARCHAR2,
                                pv_fullname             IN VARCHAR2,
                                pv_mobile               IN VARCHAR2,
                                pv_branch               IN VARCHAR2,
                                pv_typeacct             IN VARCHAR2,
                                pv_carebyid             IN VARCHAR2,
                                pv_reqid                OUT VARCHAR2,
                                p_err_code              OUT VARCHAR2,
                                p_err_param             OUT VARCHAR2);
PROCEDURE pr_openaccount_control (pv_typeinvestor         IN VARCHAR2,
                                  pv_fullname             IN VARCHAR2,
                                  pv_mobile               IN VARCHAR2,
                                  pv_typeacct             IN VARCHAR2,
                                  pv_carebyid             IN VARCHAR2 DEFAULT '0002',
                                  pv_branch               IN VARCHAR2,
                                  pv_reqid                IN VARCHAR2,
                                  p_err_code              OUT VARCHAR2,
                                  p_err_param             OUT VARCHAR2);
PROCEDURE pr_check_openaccount(pv_fullname              IN VARCHAR2,
                              pv_sex                   IN VARCHAR2,
                              pv_dateofbirth           IN VARCHAR2,
                              pv_country               IN VARCHAR2,
                              pv_idtype                IN VARCHAR2,
                              pv_idcode                IN VARCHAR2,
                              pv_iddate                IN VARCHAR2,
                              pv_idplace               IN VARCHAR2,
                              pv_email                 IN VARCHAR2,
                              pv_address               IN VARCHAR2,
                              pv_address2              IN VARCHAR2,
                              pv_province              IN VARCHAR2,
                              pv_reqid                 IN VARCHAR2,
                              p_err_code               OUT VARCHAR2,
                              p_err_param              OUT VARCHAR2);
PROCEDURE pr_openaccount_auto(pv_fullname              IN VARCHAR2,
                              pv_sex                   IN VARCHAR2,
                              pv_dateofbirth           IN VARCHAR2,
                              pv_country               IN VARCHAR2,
                              pv_idtype                IN VARCHAR2,
                              pv_idcode                IN VARCHAR2,
                              pv_iddate                IN VARCHAR2,
                              pv_idplace               IN VARCHAR2,
                              pv_email                 IN VARCHAR2,
                              pv_address               IN VARCHAR2,
                              pv_address2              IN VARCHAR2,
                              pv_province              IN VARCHAR2,
                              pv_reqid                 IN VARCHAR2,
                              pv_ekycai                IN NUMBER,
                              pv_america               IN VARCHAR2 DEFAULT 'N',
                              pv_national              IN VARCHAR2,
                              pv_company1              IN VARCHAR2,
                              pv_position1             IN VARCHAR2,
                              pv_company2              IN VARCHAR2,
                              pv_position2             IN VARCHAR2,
                              pv_company3              IN VARCHAR2,
                              pv_opnsource             IN VARCHAR2,
                              p_err_code               OUT VARCHAR2,
                              p_err_param              OUT VARCHAR2);
PROCEDURE pr_openaccount (pv_reqid                 IN VARCHAR2,
                          pv_custodycd             IN VARCHAR2,
                          pv_afacctno              IN VARCHAR2,
                          pv_actype                IN VARCHAR2,
                          pv_fullname              IN VARCHAR2,
                          pv_sex                   IN VARCHAR2,
                          pv_dateofbirth           IN VARCHAR2,
                          pv_country               IN VARCHAR2,
                          pv_idtype                IN VARCHAR2,
                          pv_idcode                IN VARCHAR2,
                          pv_iddate                IN VARCHAR2,
                          pv_idplace               IN VARCHAR2,
                          pv_email                 IN VARCHAR2,
                          pv_mobile                IN VARCHAR2,
                          pv_address               IN VARCHAR2,
                          pv_address2              IN VARCHAR2,
                          pv_brid                  IN VARCHAR2,
                          pv_careby                IN VARCHAR2,
                          pv_tradeonline           IN VARCHAR2,
                          pv_ekycai                IN NUMBER,
                          pv_province              IN VARCHAR2,
                          pv_opnsource             IN VARCHAR2,
                          p_err_code              OUT VARCHAR2,
                          p_err_param             OUT VARCHAR2);
PROCEDURE pr_add_register (pv_reqid        IN VARCHAR2,
                           pv_typeofacc    IN VARCHAR2,
                           pv_service      IN VARCHAR2,
                           pv_SMARTOTP     IN VARCHAR2,
                           pv_menthod      IN VARCHAR2,
                           p_err_code      OUT varchar2,
                           p_err_message   out VARCHAR2);
/*PROCEDURE pr_insert_sign (p_reqid IN  VARCHAR2,
                            p_sign  IN  CLOB,
                            p_type  IN  VARCHAR2,--001: mat truoc CMND, 002: mat sau cmnd, 003: chu ky
                            p_err_code    OUT VARCHAR2,
                            p_err_param   OUT VARCHAR2);*/

/*PROCEDURE pr_block_afacctno (p_afacctno         in  VARCHAR2,
                             p_err_code         OUT VARCHAR2,
                             p_err_param        OUT VARCHAR2);*/
PROCEDURE pr_add_image (pv_reqid        IN VARCHAR2,
                        pv_IDATTACH     IN CLOB,
                        pv_type         IN VARCHAR2,
                        p_err_code      OUT varchar2,
                        p_err_message   out VARCHAR2);
PROCEDURE pr_openaccount_full(pv_fullname              IN VARCHAR2,
                              pv_sex                   IN VARCHAR2,
                              pv_dateofbirth           IN VARCHAR2,
                              pv_country               IN VARCHAR2,
                              pv_idtype                IN VARCHAR2,
                              pv_idcode                IN VARCHAR2,
                              pv_iddate                IN VARCHAR2,
                              pv_idplace               IN VARCHAR2,
                              pv_email                 IN VARCHAR2,
                              pv_address               IN VARCHAR2,
                              pv_address2              IN VARCHAR2,
                              pv_province              IN VARCHAR2,
                              pv_reqid                 IN VARCHAR2,
                              pv_ekycai                IN NUMBER,
                              pv_america               IN VARCHAR2 DEFAULT 'N',
                              pv_national              IN VARCHAR2,
                              pv_company1              IN VARCHAR2,
                              pv_position1             IN VARCHAR2,
                              pv_company2              IN VARCHAR2,
                              pv_position2             IN VARCHAR2,
                              pv_company3              IN VARCHAR2,
                              pv_IDATTACH              IN CLOB,
                              pv_IDATTACH1             IN CLOB,
                              pv_typeofacc             IN VARCHAR2,
                              pv_service               IN VARCHAR2,
                              pv_SMARTOTP              IN VARCHAR2,
                              pv_menthod               IN VARCHAR2,
                              p_err_code               OUT VARCHAR2,
                              p_err_param              OUT VARCHAR2);
PROCEDURE pr_SMS_OTP ( p_custodycd         IN  VARCHAR2,
                       p_TOKENID   IN  VARCHAR2,
                       p_err_code          OUT varchar2,
                       p_err_message       out VARCHAR2);
procedure pr_GenOTP(
          p_JSonInput  Clob,
          p_via  IN  varchar2,
          p_tlid  IN  varchar2,
          p_language in varchar2 default C_LANG_VI,
          p_objname  in varchar2 default '',
          p_err_code in out varchar2,
          p_err_param in out varchar2 );
Procedure pr_VerifyOTP(
          p_JSonInput  Clob,
          p_CFSign  Clob,
          p_via  IN  varchar2,
          p_tlid  IN  varchar2,
          p_language in varchar2 default C_LANG_VI,
          p_objname  in varchar2 default '',
          p_JSonMsgOut out clob,
          p_err_code in out varchar2,
          p_err_param in out varchar2 );
procedure pr_Maintainlog(
        p_strSQL IN VARCHAR2,
        p_ObjectName IN VARCHAR2,
        p_RecordKey IN VARCHAR2,
        p_RecordValue IN VARCHAR2,
        p_ChildObjectName IN VARCHAR2,
        p_ChildRecordKey IN VARCHAR2,
        p_ChildRecordValue IN VARCHAR2,
        p_makerid  IN VARCHAR2,
        p_makerdt  IN VARCHAR2  default '',
        p_checkerid  IN VARCHAR2 default ''
        ) ;
PROCEDURE pr_register_login (p_custodycd VARCHAR2,
                               p_username VARCHAR2,
                               p_loginpwd VARCHAR2,
                               p_tradingpwd VARCHAR2,
                               p_err_code    OUT varchar2,
                               p_err_message out VARCHAR2);
Procedure pr_GetViewOpenAcc
        (p_refcursor in out pkg_report.ref_cursor,
        p_fdate IN varchar2,
        p_tdate IN varchar2,
        p_custodycd in varchar2,
        p_idcode in varchar2,
        p_openactype in varchar2,
        p_status in varchar2,
        p_brid in varchar2,
        p_via  IN  varchar2,
        p_tlid  IN  varchar2,
        p_language in varchar2 default C_LANG_VI,
        p_objname  in varchar2 default ''
        );
PROCEDURE GenTemplate313E(
        p_fullname      varchar2,
        p_custodycd     varchar2,
        p_orgLoginpwd   varchar2,
        p_orgTradingpwd varchar2,
        p_email         varchar2
    );
PROCEDURE GenTemplate315E(
        p_fullname      varchar2,
        p_custodycd     varchar2,
        p_mobile        varchar2,
        p_email         varchar2
    );
Procedure pr_VerifyTLID(
          p_JSonInput  Clob,
          p_err_code in out varchar2,
          p_err_param in out varchar2 );
Function fn_random_str(v_length number) return varchar2;
function fn_random_num(v_length number) return VARCHAR2;
Function fn_data_from_json(p_jSonData fss_json, p_fldname VARCHAR2) return varchar2;
Function fn_get_errmsg (p_errnum in varchar2, p_language in varchar2 default C_LANG_VI) return VARCHAR2;

end fopks_Ekycapi;
/


CREATE OR REPLACE PACKAGE BODY fopks_ekycapi is

  pkgctx plog.log_ctx;
  logrow tlogdebug%rowtype;

  --------------------------------Lay thong tin chi nhanh--------------------------
PROCEDURE pr_get_brachinfo( p_refcursor in out ref_cursor,
                            p_iscareby  in varchar2)
AS
BEGIN
    IF p_iscareby ='Y' THEN
       OPEN p_refcursor FOR
            select BRID, DESCRIPTION,brphone PHONE,braddress ADDRESS from BRGRP WHERE STATUS ='A' and isactive = 'Y' and AFTYPE is not null;
    ELSE
       OPEN p_refcursor FOR
            select BRID, DESCRIPTION,brphone PHONE,braddress ADDRESS from BRGRP WHERE STATUS ='A' and isactive = 'Y' and AFTYPE is not null;
    END IF;
    plog.setendsection(pkgctx, 'pr_get_brachinfo');
exception
    when others THEN
      --plog.error(pkgctx, sqlerrm);
      plog.setendsection(pkgctx, 'pr_get_brachinfo');
end;

  --------------------------------Lay thong tin quoc tich--------------------------
PROCEDURE pr_get_country( p_refcursor in out ref_cursor)
AS
BEGIN

  OPEN p_refcursor FOR
       select cdval, cdcontent from allcode where cdname ='COUNTRY' and cdval in ('234','00');

    plog.setendsection(pkgctx, 'pr_get_country');
exception
    when others THEN
      --plog.error(pkgctx, sqlerrm);
      plog.setendsection(pkgctx, 'pr_get_country');
end;

  --------------------------------Lay thong tin tinh thanh--------------------------
PROCEDURE pr_get_province( p_refcursor in out ref_cursor)
AS
BEGIN

  OPEN p_refcursor FOR
       select cdval, cdcontent from allcode where cdname ='PROVINCE' AND CDTYPE ='CF';

    plog.setendsection(pkgctx, 'pr_get_country');
exception
    when others THEN
      --plog.error(pkgctx, sqlerrm);
      plog.setendsection(pkgctx, 'pr_get_country');
end;
  --------------------------------Mo TK-------------------------------------------
PROCEDURE pr_checkacct_control (pv_typeinvestor         IN VARCHAR2,
                                pv_fullname             IN VARCHAR2,
                                pv_mobile               IN VARCHAR2,
                                pv_branch               IN VARCHAR2,
                                pv_typeacct             IN VARCHAR2,
                                pv_carebyid             IN VARCHAR2,
                                pv_reqid                OUT VARCHAR2,
                                p_err_code              OUT VARCHAR2,
                                p_err_param             OUT VARCHAR2)
IS
l_reqid    VARCHAR2(14);
v_careby   varchar2(10);
v_busdate  DATE;
v_count    NUMBER;
l_autoid   number;
v_mobile_number  number;
l_CURRDATE Date;
l_datasource varchar2(2000);
l_emailmg varchar2(100);
pv_status varchar2(100);
BEGIN
  plog.setBeginSection(pkgctx, 'pr_openaccount_control');
  p_err_code := systemnums.C_SUCCESS;
  p_err_param := '';
  l_CURRDATE := getcurrdate;

  SELECT to_date(varvalue,systemnums.c_date_format) INTO v_busdate
  FROM sysvar
  WHERE varname = 'CURRDATE' AND grname = 'SYSTEM';
  l_reqid := to_char(v_busdate,'rrrrmmdd')||LPAD (seq_apiopenaccount.NEXTVAL, 6, '0');
  pv_reqid := l_reqid;
  l_autoid := SEQ_EKYC_CFINFOR.NEXTVAL;

  SELECT CAREBY INTO v_careby FROM BRGRP WHERE BRID = pv_branch;
  --Check required
  IF pv_typeinvestor is null OR pv_mobile is null OR pv_branch is null THEN
      p_err_code  := '-260265';
      p_err_param := cspks_system.fn_get_errmsg(p_err_code);
      plog.setendsection(pkgctx, 'pr_openaccount_control');
      return;
  END IF;

  --Check du lieu dau vao
    IF isnumber(pv_mobile) = 'N' THEN
      p_err_code  := '-260262';
      p_err_param := cspks_system.fn_get_errmsg(p_err_code);
      plog.setendsection(pkgctx, 'pr_openaccount_control');
      RETURN;
    END IF;

    SELECT COUNT(*) into v_count FROM EKYC_CFINFOR WHERE mobile = trim(pv_mobile) and txdate = l_CURRDATE;
    SELECT to_number(VARVALUE,'99999') into v_mobile_number FROM SYSVAR S WHERE S.VARNAME='EKYC_TIMES_MOBILE';
    IF v_count > v_mobile_number THEN
      p_err_code  := '-260259';
      p_err_param := cspks_system.fn_get_errmsg(p_err_code);
      plog.setendsection(pkgctx, 'pr_openaccount_control');
      RETURN;
    END IF;

    IF pv_typeinvestor <> '0001' THEN

      insert into EKYC_CFINFOR (AUTOID, TXDATE, TYPEINVEST, FULLNAME, MOBILE, TYPEACCT, CAREBYID, BRANCH, REQID, CARENAME)
      values (SEQ_EKYC_CFINFOR.NEXTVAL, l_CURRDATE, pv_typeinvestor, trim(pv_fullname), trim(pv_mobile), pv_typeacct, nvl(v_careby,'0002'), pv_branch, pv_reqid, trim(pv_carebyid));

      insert into APIOpenAccount (autoid, FULLNAME, MOBILE, BRID, APINAME, LASTDATE, REQID)
      values (seq_apiopenaccount.nextval, trim(pv_fullname), trim(pv_mobile), pv_branch, 'pr_checkacct_control', v_busdate, pv_reqid );

      insert into REGISTERONLINE (AUTOID, TXDATE, CUSTOMERTYPE, CUSTOMERNAME, MOBILE, BRID, REQID)
      values(SEQ_REGISTER_AUTOID.nextval, l_CURRDATE, pv_typeinvestor, trim(pv_fullname),trim(pv_mobile), pv_branch, pv_reqid );

      insert into registeronlinelog (AUTOID, TXDATE, CUSTOMERTYPE, CUSTOMERNAME, MOBILE, BRID, REQID)
      values(seq_registeronlinelog.nextval, l_CURRDATE, pv_typeinvestor, trim(pv_fullname),trim(pv_mobile), pv_branch, pv_reqid );

      begin
        select varvalue into l_emailmg from sysvar where varname='EKYC_EMAIL';
      exception WHEN OTHERS THEN
             l_emailmg := '';
      end;

      begin
        select cdcontent into pv_status from allcode where cdname='STATUS_EMAIL' and cdtype='CF' and cdval = 'W';
      exception WHEN OTHERS THEN
             pv_status := '';
      end;

         l_datasource := 'select '''||pv_fullname||''' fullname, '''' custodycd, '''' iddate, '''' idplace, '''' address, '''
                                ||pv_mobile||''' mobile, '''' email, '''
                                ||pv_status||''' status, '''' PV_IDCODE from dual';
         nmpks_ems.InsertEmailLog(l_emailmg, '315E', l_datasource, '');

    END IF;

  plog.setEndSection(pkgctx, 'pr_openaccount_control');
EXCEPTION
  WHEN OTHERS THEN
    p_err_code := errnums.C_SYSTEM_ERROR;
    p_err_param := 'SYSTEM ERROR';
    plog.error(pkgctx, SQLERRM || ' AT ' || dbms_utility.format_error_backtrace);
    plog.setendsection(pkgctx, 'pr_openaccount_control');
END;

PROCEDURE pr_openaccount_control (pv_typeinvestor         IN VARCHAR2,
                                  pv_fullname             IN VARCHAR2,
                                  pv_mobile               IN VARCHAR2,
                                  pv_typeacct             IN VARCHAR2,
                                  pv_carebyid             IN VARCHAR2,
                                  pv_branch               IN VARCHAR2,
                                  pv_reqid                IN VARCHAR2,
                                  p_err_code              OUT VARCHAR2,
                                  p_err_param             OUT VARCHAR2)
IS
v_careby   varchar2(10);
v_busdate  DATE;
v_count    NUMBER;
l_autoid   number;
v_mobile_number  number;
l_CURRDATE Date;
BEGIN
  plog.setBeginSection(pkgctx, 'pr_openaccount_control');
  p_err_code := systemnums.C_SUCCESS;
  p_err_param := '';
  l_CURRDATE := getcurrdate;

  SELECT to_date(varvalue,systemnums.c_date_format) INTO v_busdate
  FROM sysvar
  WHERE varname = 'CURRDATE' AND grname = 'SYSTEM';

  l_autoid := SEQ_EKYC_CFINFOR.NEXTVAL;

    SELECT CAREBY INTO v_careby FROM BRGRP WHERE BRID = pv_branch;
  --Ghi log
    insert into EKYC_CFINFOR (AUTOID, TXDATE, TYPEINVEST, FULLNAME, MOBILE, TYPEACCT, CAREBYID, BRANCH, REQID, CARENAME)
    values (l_autoid, l_CURRDATE, pv_typeinvestor, trim(pv_fullname), trim(pv_mobile), pv_typeacct, nvl(v_careby,'0002'), pv_branch, pv_reqid, trim(pv_carebyid));

  plog.setEndSection(pkgctx, 'pr_openaccount_control');
EXCEPTION
  WHEN OTHERS THEN
    p_err_code := errnums.C_SYSTEM_ERROR;
    p_err_param := 'SYSTEM ERROR';
    plog.error(pkgctx, SQLERRM || ' AT ' || dbms_utility.format_error_backtrace);
    plog.setendsection(pkgctx, 'pr_openaccount_control');
END;

PROCEDURE pr_check_openaccount(pv_fullname              IN VARCHAR2,
                              pv_sex                   IN VARCHAR2,
                              pv_dateofbirth           IN VARCHAR2,
                              pv_country               IN VARCHAR2,
                              pv_idtype                IN VARCHAR2,
                              pv_idcode                IN VARCHAR2,
                              pv_iddate                IN VARCHAR2,
                              pv_idplace               IN VARCHAR2,
                              pv_email                 IN VARCHAR2,
                              pv_address               IN VARCHAR2,
                              pv_address2              IN VARCHAR2,
                              pv_province              IN VARCHAR2,
                              pv_reqid                 IN VARCHAR2,
                              p_err_code               OUT VARCHAR2,
                              p_err_param              OUT VARCHAR2)
IS
l_reqid       VARCHAR2(14);
v_busdate     DATE;
v_count       number;
l_dateofbirth DATE;
BEGIN
  plog.setBeginSection(pkgctx, 'pr_openaccount_auto');
  p_err_code := systemnums.C_SUCCESS;
  p_err_param := '';
  --pv_lifecycle:='';

  SELECT to_date(varvalue,systemnums.c_date_format) INTO v_busdate
  FROM sysvar
  WHERE varname = 'CURRDATE' AND grname = 'SYSTEM';
  l_reqid := pv_reqid;

  --Check required
  IF pv_reqid is null OR trim(pv_fullname) is null OR pv_sex is null OR pv_dateofbirth IS NULL
    OR trim(pv_idcode) is null OR pv_iddate is null OR pv_country is null
    OR trim(pv_idplace) is null OR trim(pv_email) is null OR pv_province is null
    OR trim(pv_address) is null OR pv_idtype is null THEN
      p_err_code  := '-260265';
      p_err_param := cspks_system.fn_get_errmsg(p_err_code);
      UPDATE APIOpenAccount SET ERRNUM = p_err_code, ERRDESC = p_err_param, last_change = CURRENT_TIMESTAMP WHERE REQID = l_reqid;
      plog.setendsection(pkgctx, 'pr_check_openaccount');
      return;
  END IF;
    --Check du lieu dau vao
  BEGIN
    --Check CMND
      SELECT COUNT(1) INTO v_count FROM cfmast WHERE idcode = trim(pv_idcode) AND status <> 'C' and substr(custodycd,1,3) <> 'OTC';
      IF v_count > 0 THEN
         p_err_code  := '-200020';
         p_err_param := cspks_system.fn_get_errmsg(p_err_code);
         UPDATE APIOpenAccount SET ERRNUM = p_err_code, ERRDESC = p_err_param, last_change = CURRENT_TIMESTAMP WHERE REQID = l_reqid;
         plog.setendsection(pkgctx, 'pr_check_openaccount');
         return;
      END IF;
      SELECT COUNT(1) INTO v_count FROM registeronline WHERE idcode = trim(pv_idcode);
      IF v_count > 0 THEN
         p_err_code  := '-200020';
         p_err_param := cspks_system.fn_get_errmsg(p_err_code);
         UPDATE APIOpenAccount SET ERRNUM = p_err_code, ERRDESC = p_err_param, last_change = CURRENT_TIMESTAMP WHERE REQID = l_reqid;
         plog.setendsection(pkgctx, 'pr_check_openaccount');
         return;
      END IF;
      SELECT COUNT(1) INTO v_count FROM APIOPENACCOUNTLOG WHERE idcode = trim(pv_idcode);
      IF v_count > 0 THEN
         p_err_code  := '-200020';
         p_err_param := cspks_system.fn_get_errmsg(p_err_code);
         UPDATE APIOpenAccount SET ERRNUM = p_err_code, ERRDESC = p_err_param, last_change = CURRENT_TIMESTAMP WHERE REQID = l_reqid;
         plog.setendsection(pkgctx, 'pr_check_openaccount');
         return;
      END IF;
    --Check reqid
      SELECT COUNT(1) INTO v_count FROM registeronline WHERE reqid = l_reqid;
      IF v_count > 0 THEN
        p_err_code  := '-260267';
        p_err_param := cspks_system.fn_get_errmsg(p_err_code);
        UPDATE APIOpenAccount SET ERRNUM = p_err_code, ERRDESC = p_err_param, last_change = CURRENT_TIMESTAMP WHERE REQID = l_reqid;
        plog.setendsection(pkgctx, 'pr_check_openaccount');
        return;
      END IF;
      IF isnumber(pv_idcode) = 'N' THEN
        p_err_code  := '-260264';
        p_err_param := cspks_system.fn_get_errmsg(p_err_code);
        plog.setendsection(pkgctx, 'pr_check_openaccount');
        RETURN;
      END IF;
      BEGIN
        select to_date(pv_dateofbirth,'DD/MM/RRRR') into l_dateofbirth from dual;
      EXCEPTION
        WHEN OTHERS THEN
        p_err_code     :='-260268';
        p_err_param    := cspks_system.fn_get_errmsg(p_err_code);
        UPDATE APIOpenAccount SET ERRNUM = p_err_code, ERRDESC = p_err_param, last_change = CURRENT_TIMESTAMP WHERE REQID = l_reqid;
        plog.error(pkgctx, 'Error:'  || p_err_param);
        plog.setendsection(pkgctx, 'pr_openaccount_auto');
        RETURN;
      END;
    --Check ngay sinh du 18 tuoi
      IF MONTHS_BETWEEN(v_busdate,to_date(pv_dateofbirth,'dd/mm/rrrr')) < 216 THEN
        p_err_code  := '-200090';
        p_err_param := cspks_system.fn_get_errmsg(p_err_code);
        UPDATE APIOpenAccount SET ERRNUM = p_err_code, ERRDESC = p_err_param, last_change = CURRENT_TIMESTAMP WHERE REQID = l_reqid;
        plog.setendsection(pkgctx, 'pr_check_openaccount');
        return;
      END IF;
    --Check ngay cap CMND ngay sinh - ngay cap >= 14
      IF MONTHS_BETWEEN(to_date(pv_iddate,'dd/mm/rrrr'),to_date(pv_dateofbirth,'dd/mm/rrrr')) < 168
      THEN
        p_err_code  := '-260263';
        p_err_param := cspks_system.fn_get_errmsg(p_err_code);
        UPDATE APIOpenAccount SET ERRNUM = p_err_code, ERRDESC = p_err_param, last_change = CURRENT_TIMESTAMP WHERE REQID = l_reqid;
        plog.setendsection(pkgctx, 'pr_check_openaccount');
        return;
      END IF;
    --ngay hien tai - ngay cap  <= 15
      IF MONTHS_BETWEEN(v_busdate,to_date(pv_iddate,'dd/mm/rrrr')) > 180
      THEN
        p_err_code  := '-200207';
        p_err_param := cspks_system.fn_get_errmsg(p_err_code);
        UPDATE APIOpenAccount SET ERRNUM = p_err_code, ERRDESC = p_err_param, last_change = CURRENT_TIMESTAMP WHERE REQID = l_reqid;
        plog.setendsection(pkgctx, 'pr_check_openaccount');
        return;
      END IF;
    --Check email
      IF NOT REGEXP_LIKE(pv_email, '\w+@\w') THEN
        p_err_code  := '-260260';
        p_err_param := cspks_system.fn_get_errmsg(p_err_code);
        UPDATE APIOpenAccount SET ERRNUM = p_err_code, ERRDESC = p_err_param, last_change = CURRENT_TIMESTAMP WHERE REQID = l_reqid;
        plog.setendsection(pkgctx, 'pr_check_openaccount');
        return;
      END IF;
    if not nmpks_ems.CheckEmail(pv_email) then
      p_err_code    :='-260260';
      p_err_param   := cspks_system.fn_get_errmsg(p_err_code);
      UPDATE APIOpenAccount SET ERRNUM = p_err_code, ERRDESC = p_err_param, last_change = CURRENT_TIMESTAMP WHERE REQID = l_reqid;
      plog.error(pkgctx, 'Error:'  || p_err_param);
      plog.setendsection(pkgctx, 'pr_check_openaccount');
      RETURN;
    end if;

  END;

  plog.setEndSection(pkgctx, 'pr_check_openaccount');
EXCEPTION
  WHEN OTHERS THEN
    p_err_code := errnums.C_SYSTEM_ERROR;
    p_err_param := 'SYSTEM ERROR';
    plog.error(pkgctx, SQLERRM || ' AT ' || dbms_utility.format_error_backtrace);
    plog.setendsection(pkgctx, 'pr_check_openaccount');
END;

PROCEDURE pr_openaccount_auto(pv_fullname              IN VARCHAR2,
                              pv_sex                   IN VARCHAR2,
                              pv_dateofbirth           IN VARCHAR2,
                              pv_country               IN VARCHAR2,
                              pv_idtype                IN VARCHAR2,
                              pv_idcode                IN VARCHAR2,
                              pv_iddate                IN VARCHAR2,
                              pv_idplace               IN VARCHAR2,
                              pv_email                 IN VARCHAR2,
                              pv_address               IN VARCHAR2,
                              pv_address2              IN VARCHAR2,
                              pv_province              IN VARCHAR2,
                              pv_reqid                 IN VARCHAR2,
                              pv_ekycai                IN NUMBER,
                              pv_america               IN VARCHAR2 DEFAULT 'N',
                              pv_national              IN VARCHAR2,
                              pv_company1              IN VARCHAR2,
                              pv_position1             IN VARCHAR2,
                              pv_company2              IN VARCHAR2,
                              pv_position2             IN VARCHAR2,
                              pv_company3              IN VARCHAR2,
                              pv_opnsource             IN VARCHAR2,
                              p_err_code               OUT VARCHAR2,
                              p_err_param              OUT VARCHAR2)
IS
l_reqid       VARCHAR2(14);
v_busdate     DATE;
v_count       number;
v_custodycd   varchar2(20);
v_afacctno    varchar2(20);
v_actype      varchar2(20);
v_mobile      varchar2(20);
v_careby      varchar2(20);
v_brid        varchar2(20);
v_NVCS        varchar2(200);
l_CURRDATE    Date;
l_dateofbirth Date;
l_ekyc_cus    varchar2(10);
BEGIN
  plog.setBeginSection(pkgctx, 'pr_openaccount_auto');
  p_err_code := systemnums.C_SUCCESS;
  p_err_param := '';
  --pv_lifecycle:='';
  l_CURRDATE := getcurrdate;

  SELECT to_date(varvalue,systemnums.c_date_format) INTO v_busdate
  FROM sysvar
  WHERE varname = 'CURRDATE' AND grname = 'SYSTEM';
  l_reqid := pv_reqid;

  begin
    select varvalue into l_ekyc_cus from sysvar where varname='EKYC_CUSTODYCD';
  EXCEPTION
  WHEN OTHERS THEN
    l_ekyc_cus := '69';
  end;

  BEGIN
    select MOBILE, CAREBYID, BRANCH, CARENAME into v_mobile, v_careby, v_brid, v_NVCS FROM
    (SELECT td.*, ROW_NUMBER() OVER (PARTITION BY reqid ORDER BY AUTOID DESC) RN
     FROM EKYC_CFINFOR td WHERE TXDATE = l_CURRDATE and reqid = l_reqid ORDER BY AUTOID DESC) WHERE RN = 1 ;
  EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, 'select EKYC_CFINFOR: l_reqid='||l_reqid||'.Error:' ||SQLERRM || ' AT ' || dbms_utility.format_error_backtrace);
    v_mobile   := 0;
    v_careby   := 0;
    v_brid     := 0;
  END;

  -- gen custodycd, afacctno
  BEGIN
    SELECT SUBSTR(INVACCT,1,4)|| l_ekyc_cus || lpad(MAX(ODR)+1,4,0) into v_custodycd FROM
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
      SELECT VARVALUE||'C' || l_ekyc_cus || '0001' into v_custodycd FROM SYSVAR WHERE VARNAME='COMPANYCD'AND GRNAME='SYSTEM';
  END;

  BEGIN

    SELECT SUBSTR(INVACCT,1,4) || lpad(MAX(ODR)+1,6,0) into v_afacctno
    FROM (SELECT ROWNUM ODR, INVACCT
          FROM (SELECT ACCTNO INVACCT FROM AFMAST WHERE SUBSTR(ACCTNO,1,4)= '0001' ORDER BY ACCTNO) DAT
          WHERE TO_NUMBER(SUBSTR(INVACCT,5,6))=ROWNUM) INVTAB
    GROUP BY SUBSTR(INVACCT,1,4);
  exception when NO_DATA_FOUND then
      v_afacctno := v_brid||'000001';
  END;

  --check custodycd
  select count(*) into v_count from cfmast where custodycd = v_custodycd;
  if v_count > 0 then
     p_err_code     :='-200019';
     p_err_param    := cspks_system.fn_get_errmsg(p_err_code);
     UPDATE APIOpenAccount SET ERRNUM = p_err_code, ERRDESC = p_err_param, last_change = CURRENT_TIMESTAMP WHERE REQID = l_reqid;
     plog.error(pkgctx, 'Error:'  || p_err_param);
     plog.setendsection(pkgctx, 'pr_openaccount_auto');
     RETURN;
  end if;

  --check user_name
  select count(*) into v_count from cfmast where username = v_custodycd;
  if v_count > 0 then
     p_err_code     :='-200066';
     p_err_param    := cspks_system.fn_get_errmsg(p_err_code);
     UPDATE APIOpenAccount SET ERRNUM = p_err_code, ERRDESC = p_err_param, last_change = CURRENT_TIMESTAMP WHERE REQID = l_reqid;
     plog.error(pkgctx, 'Error:'  || p_err_param);
     plog.setendsection(pkgctx, 'pr_openaccount_auto');
     RETURN;
  end if;

  --check tieu khoan
  select count(*) into v_count from afmast where acctno = v_afacctno;
  if v_count > 0 then
     p_err_code     :='-200048';
     p_err_param    := cspks_system.fn_get_errmsg(p_err_code);
     UPDATE APIOpenAccount SET ERRNUM = p_err_code, ERRDESC = p_err_param, last_change = CURRENT_TIMESTAMP WHERE REQID = l_reqid;
     plog.error(pkgctx, 'Error:'  || p_err_param);
     plog.setendsection(pkgctx, 'pr_openaccount_auto');
     RETURN;
  end if;

  BEGIN
       insert into APIOpenAccount (autoid, FULLNAME, SEX, DATEOFBIRTH, COUNTRY, IDTYPE,
                  IDCODE, IDDATE, IDPLACE, EMAIL, MOBILE, ADDRESS, BRID, CAREBY, APINAME, LASTDATE, REQID,
                  company1, position1, company2, position2, company3, isamerica, national, TXDATE, OPNSOURCE, CARENAME, STATUS)
       values (seq_apiopenaccount.nextval, INITCAP(TRIM(pv_fullname)), pv_sex, to_date(pv_dateofbirth,'dd/mm/rrrr'), pv_country, pv_idtype,
               trim(pv_idcode), to_date(pv_iddate,'dd/mm/rrrr'), trim(pv_idplace), trim(pv_email), v_mobile, trim(pv_address), v_brid, v_careby, 'pr_openaccount_auto', v_busdate, l_reqid,
               pv_company1, pv_position1, pv_company2, pv_position2, pv_company3, pv_america, pv_national, l_CURRDATE, pv_opnsource, v_NVCS,'P');

       insert into APIOPENACCOUNTLOG(AUTOID,IDTYPE,IDCODE,IDDATE,IDPLACE,MOBILE,APINAME,EKYCAI,REQID,ERRNUM,ERRDESC,STATUS)
       values (seq_APIOPENACCOUNTLOG.nextval,pv_idtype,trim(pv_idcode),to_date(pv_iddate,'dd/mm/rrrr'),trim(pv_idplace),v_mobile,
               'pr_openaccount_auto',round(pv_ekycai,0),l_reqid,null,null,'P');
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
     p_err_code     :='-200020';
     p_err_param    := cspks_system.fn_get_errmsg(p_err_code);
     UPDATE APIOpenAccount SET ERRNUM = p_err_code, ERRDESC = p_err_param, last_change = CURRENT_TIMESTAMP WHERE REQID = l_reqid;
     plog.error(pkgctx, 'Error:'  || p_err_param);
     plog.setendsection(pkgctx, 'pr_openaccount_auto');
     RETURN;
  END;

  v_actype  := '0001';
  select b.aftype into v_actype from brgrp b where brid = v_brid;

  pr_openaccount (l_reqid, v_custodycd, v_afacctno, v_actype, pv_fullname, pv_sex, pv_dateofbirth, pv_country,
                  pv_idtype, pv_idcode, pv_iddate, pv_idplace, pv_email, v_mobile, pv_address, pv_address2,
                  v_brid, v_careby,'Y', round(pv_ekycai,0), pv_province, pv_opnsource, p_err_code, p_err_param);

  plog.setEndSection(pkgctx, 'pr_openaccount_auto');
EXCEPTION
  WHEN OTHERS THEN
    p_err_code := errnums.C_SYSTEM_ERROR;
    p_err_param := 'SYSTEM ERROR';
    plog.error(pkgctx, SQLERRM || ' AT ' || dbms_utility.format_error_backtrace);
    plog.setendsection(pkgctx, 'pr_openaccount_auto');
END;

PROCEDURE pr_openaccount (pv_reqid                 IN VARCHAR2,
                          pv_custodycd             IN VARCHAR2,
                          pv_afacctno              IN VARCHAR2,
                          pv_actype                IN VARCHAR2,
                          pv_fullname              IN VARCHAR2,
                          pv_sex                   IN VARCHAR2,
                          pv_dateofbirth           IN VARCHAR2,
                          pv_country               IN VARCHAR2,
                          pv_idtype                IN VARCHAR2,
                          pv_idcode                IN VARCHAR2,
                          pv_iddate                IN VARCHAR2,
                          pv_idplace               IN VARCHAR2,
                          pv_email                 IN VARCHAR2,
                          pv_mobile                IN VARCHAR2,
                          pv_address               IN VARCHAR2,
                          pv_address2              IN VARCHAR2,
                          pv_brid                  IN VARCHAR2,
                          pv_careby                IN VARCHAR2,
                          pv_tradeonline           IN VARCHAR2,
                          pv_ekycai                IN NUMBER,
                          pv_province              IN VARCHAR2,
                          pv_opnsource             IN VARCHAR2,
                          p_err_code              OUT VARCHAR2,
                          p_err_param             OUT VARCHAR2)
  IS
  l_reqid      VARCHAR2(14);
  v_busdate    DATE;
  l_custid     VARCHAR2(10);
  l_corebank   VARCHAR2(1);
  l_autoadv    VARCHAR2(1);
  l_atype      VARCHAR2(5);
  p_tlid       VARCHAR2(5);
  l_citype     VARCHAR2(10);
  v_max_number    number;
  v_typeacc    VARCHAR2(10);
  v_EKYC_AI    number;
  v_iscareby   varchar2(10);
  l_olautoid   number;
  l_CURRDATE   Date;
  l_strSQL        varchar2(3000);
  l_strObjectName     varchar2(1000);
  l_strRecordKey      varchar2(1000);
  l_strChildObjName   varchar2(1000);
  l_strChildRecordKey varchar2(1000);
  v_count number;
  l_aftype varchar2(10);
  p_apptlid varchar2(20);
  l_balance number;
  l_isPM varchar2(1);
  l_afacctno VARCHAR2(20);
  l_cftype VARCHAR2(20);
  l_emailmg VARCHAR2(100);
  l_datasource VARCHAR2(2000);
  pv_status VARCHAR2(100);
  v_opndate date;
  --BMSSUP-95
  v_checkNameBirthday varchar2(2);
  v_RegistNote varchar2(2000);
  v_RegistNoteVal varchar2(2000);
  --End BMSSUP-95
  BEGIN
    plog.setBeginSection(pkgctx, 'pr_openaccount');
    p_err_code := systemnums.C_SUCCESS;
    p_err_param := '';
    l_CURRDATE := getcurrdate;

    SELECT to_date(varvalue,systemnums.c_date_format) INTO v_busdate
    FROM sysvar
    WHERE varname = 'CURRDATE' AND grname = 'SYSTEM';

    SELECT to_number(varvalue) into v_EKYC_AI
    FROM sysvar
    WHERE varname = 'EKYC_AI' AND grname = 'SYSTEM';

    p_tlid     := systemnums.C_ONLINE_USERID;
    l_reqid    := pv_reqid;
    l_olautoid := SEQ_REGISTER_AUTOID.nextval;

    SELECT VARVALUE into v_max_number FROM SYSVAR S WHERE S.VARNAME='MAX_NUMBER_VALUE';
    SELECT E.TYPEINVEST, E.TYPEACCT, E.TXDATE into v_typeacc, v_iscareby, v_opndate FROM EKYC_CFINFOR E WHERE REQID = pv_reqid;

    ---- SINH SO CUSTID
    BEGIN
    SELECT SUBSTR(INVACCT,1,4) || TRIM(TO_CHAR(MAX(ODR)+1,'000000'))  into l_custid FROM
            (SELECT ROWNUM ODR, INVACCT
            FROM (SELECT CUSTID INVACCT FROM CFMAST WHERE SUBSTR(CUSTID,1,4)= trim(pv_brid) ORDER BY CUSTID) DAT
            WHERE TO_NUMBER(SUBSTR(INVACCT,5,6))=ROWNUM) INVTAB
            GROUP BY SUBSTR(INVACCT,1,4);
    exception when NO_DATA_FOUND then
      l_custid := pv_brid||'000001';
    END;

    v_checkNameBirthday:= FN_CHECK_CFMAST_SAMENAMEBIRTH(l_custid,pv_custodycd,pv_fullname,pv_dateofbirth); --BMSSUP-95
    plog.debug(pkgctx, 'Sinh tai khoan CFMAST');
    --- MO TAI KHOAN
    IF pv_ekycai >= v_EKYC_AI and v_checkNameBirthday = 0 THEN --BMSSUP-95: them dieu kien khong trung Ten va Ngay sinh
      SELECT VARVALUE into l_cftype FROM SYSVAR S WHERE S.VARNAME='EKYC_CFTYPE';

      INSERT INTO CFMAST (CUSTID, CUSTODYCD, FULLNAME, MNEMONIC, IDCODE, IDDATE, IDPLACE,IDEXPIRED, IDTYPE, COUNTRY, ADDRESS, mobilesms, EMAIL, OPNDATE, TRADINGCODEDT, activedate,
      CAREBY, BRID, STATUS, PSTATUS, PROVINCE, CLASS, GRINVESTOR, INVESTRANGE, POSITION, TIMETOJOIN, STAFF, SEX, SECTOR, FOCUSTYPE ,BUSINESSTYPE,
      INVESTTYPE, EXPERIENCETYPE, INCOMERANGE, ASSETRANGE, LANGUAGE, BANKCODE, MARRIED, ISBANKING, DATEOFBIRTH,CUSTTYPE,CUSTATCOM,
      valudadded,occupation,education,experiencecd,tlid,risklevel,marginallow,t0loanlimit,mrloanlimit,USERNAME,
      --marginlimit, tradelimit, advancelimit, repolimit, depositlimit,
      Mobile, OPENVIA, Olautoid, actype)
      VALUES (l_custid, pv_custodycd, INITCAP(TRIM(pv_fullname)), fn_CutOffUTF8(upper(pv_fullname)), pv_idcode, to_date(pv_iddate,'dd/mm/rrrr'), pv_idplace, add_months(to_date(pv_iddate,'dd/mm/rrrr'), 15*12) , pv_idtype, pv_country, pv_address2,
      pv_mobile, pv_email, v_busdate, v_busdate, v_busdate, pv_careby,pv_brid,'A','A',pv_province,'001','001','001','001','001','001',pv_sex
      ,'001','001','009','001','001','001','001','001','000','004','N',to_date(pv_dateofbirth,'dd/mm/rrrr'),'I','Y',
      '000','005','004','00000',p_tlid,'M','Y',10000000000000,10000000000000,pv_custodycd,
      --v_max_number, v_max_number, v_max_number, v_max_number, v_max_number,
      '', 'E', l_olautoid, l_cftype);
      -- INSERT VAO MAINTAIN_LOG CFMAST

      -- Log maintainlog mot so field quan trong cua cfmast
      Begin
                l_strSQL := 'SELECT CUSTID,FULLNAME,DATEOFBIRTH,IDTYPE,IDCODE,IDDATE,IDPLACE, ADDRESS,PHONE,MOBILE,MOBILESMS,EMAIL,
                                    CUSTTYPE,TLID,ISBANKING,genencryptpassword(PIN) PIN,USERNAME,OPNDATE,OPENVIA,VAT,ACTIVESTS,CUSTODYCD,TRADEONLINE,
                                    T0LOANLIMIT, MRLOANLIMIT
                                    FROM CFMAST WHERE CUSTID=''' || l_CUSTID || '''';
                l_strObjectName := 'CFMAST';
                l_strRecordKey  := 'CUSTID';
                fopks_ekycapi.pr_maintainlog(l_strSQL, l_strObjectName, l_strRecordKey, l_CUSTID, '','','', p_tlid,to_char(v_opndate,'DD/MM/RRRR'),p_tlid);
      End;

      --------------Sinh AF-----------
       l_corebank:='N';
       l_autoadv:='N';

       SELECT AFTYPE INTO l_atype FROM BRGRP WHERE brid= pv_brid;
       SELECT corebank into  l_corebank FROM AFTYPE WHERE ACTYPE= pv_actype;

       --SELECT autoadv into  l_autoadv FROM AFTYPE WHERE ACTYPE= pv_actype;

       --FOR recMRTYPE  IN
         --(
          -- SELECT * FROM MRTYPE WHERE ACTYPE IN(SELECT MRTYPE FROM AFTYPE WHERE ACTYPE= pv_actype)
         --)
       -- LOOP

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
             and cf.custid =l_custid and aft.actype = l_atype
        )
        loop

         ---- Kiem tra truong hop da co CFMAST nhung chua co AFMAST thi moi sinh
         select count(1) into v_count from afmast where custid = l_custid and actype = rec.actype;

         if v_count = 0 then
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
            VALUES(rec.actype,l_custid,pv_afacctno,l_aftype, '' ,'---', 'A',TO_DATE( v_busdate ,'DD/MM/RRRR'),100,rec.k1days,rec.k2days,
            0,'','Y','N',TO_DATE( v_busdate ,'DD/MM/RRRR'),'E',rec.producttype,
            rec.MRIRATE,rec.MRMRATE,rec.MRLRATE,rec.MRCRLIMIT,rec.MRLMMAX,
            rec.mriratio,rec.mrmratio,rec.mrlratio,rec.mrcrate,rec.mrwrate,rec.mrexrate,
            0,rec.brid, rec.careby,l_corebank,l_AUTOADV, rec.tlid,'001','N',l_isPM);

         -- INSERT VAO MAINTAIN_LOG AFMAST

         -- Log maintainlog mot so field quan trong cua afmast
            Begin
                l_strSQL := 'SELECT ACTYPE,ACCTNO,AFTYPE,BANKACCTNO,BANKNAME,AUTOADV,ALTERNATEACCT,VIA,COREBANK,TLID,BRID,CAREBY FROM AFMAST WHERE ACCTNO=''' || pv_afacctno || '''';
                l_strObjectName := 'CFMAST';
                l_strRecordKey  := 'CUSTID';
                l_strChildObjName := 'AFMAST';
                l_strChildRecordKey  := 'ACCTNO';
                fopks_ekycapi.pr_maintainlog(l_strSQL, l_strObjectName, l_strRecordKey, l_CUSTID, l_strChildObjName,l_strChildRecordKey,pv_afacctno, p_tlid,to_char(v_opndate,'DD/MM/RRRR'),p_tlid);
            End;

         --- lay CITYPE de sinh tai khoan CI
         SELECT CITYPE into l_citype FROM AFTYPE WHERE ACTYPE = pv_actype ;
         --l_citype:=rec.citype;

         --- Sinh tai khoan CI
         INSERT INTO CIMAST (ACTYPE,ACCTNO,CCYCD,AFACCTNO,CUSTID,OPNDATE,CLSDATE,LASTDATE,DORMDATE,STATUS,PSTATUS,BALANCE,CRAMT,DRAMT,CRINTACR,CRINTDT,ODINTACR,ODINTDT,AVRBAL,MDEBIT,MCREDIT,AAMT,RAMT,BAMT,EMKAMT,MMARGINBAL,MARGINBAL,ICCFCD,ICCFTIED,ODLIMIT,ADINTACR,ADINTDT,FACRTRADE,FACRDEPOSITORY,FACRMISC,MINBAL,ODAMT,NAMT,FLOATAMT,HOLDBALANCE,PENDINGHOLD,PENDINGUNHOLD,COREBANK,RECEIVING,NETTING,MBLOCK,OVAMT,DUEAMT,T0ODAMT,MBALANCE,MCRINTDT,TRFAMT,LAST_CHANGE,DFODAMT,DFDEBTAMT,DFINTDEBTAMT,CIDEPOFEEACR)
         VALUES(l_citype,pv_afacctno,'00',pv_afacctno,l_custid,TO_DATE(v_busdate,'DD/MM/RRRR'),NULL,TO_DATE(v_busdate,'DD/MM/RRRR'),NULL,'A',NULL,0,0,0,0,TO_DATE(v_busdate,'DD/MM/RRRR'),0,TO_DATE(v_busdate,'DD/MM/RRRR'),0,0,0,0,0,0,0,0,0,NULL,'Y',0,0,NULL,0,0,0,0,0,0,0,0,0,0,'N',0,0,0,0,0,0,0,TO_DATE(v_busdate,'DD/MM/RRRR'),0,TO_DATE(v_busdate,'DD/MM/RRRR'),0,0,0,0);

        end if; ---- Kiem tra truong hop da co CFMAST nhung chua co AFMAST thi moi sinh
    END LOOP;

      -------------------------------Chan GD 1101,1111,1118,1120,1132,1133,1184,1185,1201-------------------

      --insert into AFTXMAP (AUTOID, AFACCTNO, TLTXCD, EFFDATE, EXPDATE, TLID, DELTD, LAST_CHANGE, ACTYPE, STATUS, PSTATUS)
      --values (seq_aftxmap.nextval, pv_afacctno, '1101', l_CURRDATE, add_months(l_CURRDATE, 15*12), p_tlid, 'N', null, null, null, null);
      --insert into AFTXMAP (AUTOID, AFACCTNO, TLTXCD, EFFDATE, EXPDATE, TLID, DELTD, LAST_CHANGE, ACTYPE, STATUS, PSTATUS)
      --values (seq_aftxmap.nextval, pv_afacctno, '1111', l_CURRDATE, add_months(l_CURRDATE, 15*12), p_tlid, 'N', null, null, null, null);
      --insert into AFTXMAP (AUTOID, AFACCTNO, TLTXCD, EFFDATE, EXPDATE, TLID, DELTD, LAST_CHANGE, ACTYPE, STATUS, PSTATUS)
      --values (seq_aftxmap.nextval, pv_afacctno, '1118', l_CURRDATE, add_months(l_CURRDATE, 15*12), p_tlid, 'N', null, null, null, null);
      --insert into AFTXMAP (AUTOID, AFACCTNO, TLTXCD, EFFDATE, EXPDATE, TLID, DELTD, LAST_CHANGE, ACTYPE, STATUS, PSTATUS)
      --values (seq_aftxmap.nextval, pv_afacctno, '1120', l_CURRDATE, add_months(l_CURRDATE, 15*12), p_tlid, 'N', null, null, null, null);
      --insert into AFTXMAP (AUTOID, AFACCTNO, TLTXCD, EFFDATE, EXPDATE, TLID, DELTD, LAST_CHANGE, ACTYPE, STATUS, PSTATUS)
      --values (seq_aftxmap.nextval, pv_afacctno, '1132', l_CURRDATE, add_months(l_CURRDATE, 15*12), p_tlid, 'N', null, null, null, null);
      --insert into AFTXMAP (AUTOID, AFACCTNO, TLTXCD, EFFDATE, EXPDATE, TLID, DELTD, LAST_CHANGE, ACTYPE, STATUS, PSTATUS)
      --values (seq_aftxmap.nextval, pv_afacctno, '1133', l_CURRDATE, add_months(l_CURRDATE, 15*12), p_tlid, 'N', null, null, null, null);
      --insert into AFTXMAP (AUTOID, AFACCTNO, TLTXCD, EFFDATE, EXPDATE, TLID, DELTD, LAST_CHANGE, ACTYPE, STATUS, PSTATUS)
      --values (seq_aftxmap.nextval, pv_afacctno, '1184', l_CURRDATE, add_months(l_CURRDATE, 15*12), p_tlid, 'N', null, null, null, null);
      --insert into AFTXMAP (AUTOID, AFACCTNO, TLTXCD, EFFDATE, EXPDATE, TLID, DELTD, LAST_CHANGE, ACTYPE, STATUS, PSTATUS)
      --values (seq_aftxmap.nextval, pv_afacctno, '1185', l_CURRDATE, add_months(l_CURRDATE, 15*12), p_tlid, 'N', null, null, null, null);
      --insert into AFTXMAP (AUTOID, AFACCTNO, TLTXCD, EFFDATE, EXPDATE, TLID, DELTD, LAST_CHANGE, ACTYPE, STATUS, PSTATUS)
      --values (seq_aftxmap.nextval, pv_afacctno, '1201', l_CURRDATE, add_months(l_CURRDATE, 15*12), p_tlid, 'N', null, null, null, null);

    --Log lai custid va acctno
      select acctno into l_afacctno from afmast where custid = l_custid;
      UPDATE apiOpenAccount SET afacctno = l_afacctno, custodycd = pv_custodycd, status = 'A', EKYCAI = pv_ekycai, last_change = CURRENT_TIMESTAMP WHERE REQID = l_reqid;
      UPDATE apiOpenAccountlog SET afacctno = l_afacctno, custodycd = pv_custodycd, status = 'A', last_change = CURRENT_TIMESTAMP WHERE REQID = l_reqid;


      insert into REGISTERONLINE (AUTOID, CUSTOMERTYPE, CUSTOMERNAME, CUSTOMERBIRTH, IDTYPE, IDCODE, IDDATE, IDPLACE, EXPIREDATE, SEX,
                ADDRESS, contactAddress, PRIVATEPHONE, MOBILE, FAX, EMAIL, OFFICE, POSITION, COUNTRY, CUSTOMERCITY,BENEFICIARYNAME, BENEFICIARYBIRTHDAY,
                BENEFICIARYPHONE, BENEFICIARYID, BENEFICIARYIDDATE, BENEFICIARYIDPLACE,
                AUTHORIZEDNAME, AUTHORIZEDPHONE, AUTHORIZEDID, AUTHORIZEDIDDATE, AUTHORIZEDIDPLACE,
                CUSTODYCD, BRID, REREGISTER, RERELATIONSHIP, TXDATE, STATUS,
                REFULLNAME, RETLID, REGISTERSERVICES, REGISTERNOTITRAN, AUTHENTYPEONLINE, AUTHENTYPEMOBILE,
                AREAOPENACCOUNT, BRANCHOPENACCOUNT, ACCTYPE, reqid)
      values (l_olautoid, v_typeacc, INITCAP(TRIM(pv_fullname)), to_date(pv_dateofbirth,'dd/mm/rrrr'),pv_idtype, pv_idcode, to_date(pv_iddate,'dd/mm/rrrr'), pv_idplace, add_MONTHS(to_date(pv_iddate,'dd/mm/rrrr'),15*12), pv_sex,
                pv_address, pv_address2, null, pv_mobile, null, pv_email, pv_email, '001', pv_country, pv_province, null, null,
                null, null, null, null, null, null, null, null, null, null, pv_brid, v_iscareby, null, l_CURRDATE, 'A',
                null, pv_careby, 'NNNNN', 'NNN', 'NN', null, null, null, 'E', l_reqid);

      begin
            select varvalue into l_emailmg from sysvar where varname='EKYC_EMAIL';
        exception WHEN OTHERS THEN
             l_emailmg := '';
        end;

        GenTemplate315E(INITCAP(TRIM(pv_fullname)),pv_custodycd,pv_mobile,l_emailmg);

    ELSE
        --BMSSUP-95
        v_RegistNote := '';
        if pv_ekycai < v_EKYC_AI  then
            --v_RegistNote := v_RegistNote || 'Diem eKYC khong dat';
            v_RegistNoteVal := 'P';
            begin
                select cdcontent into v_RegistNote from allcode where cdname='EKYC_ERRDESC' and cdtype='CF' and cdval = v_RegistNoteVal;
                exception WHEN OTHERS THEN
                     v_RegistNote := 'Diem eKYC khong dat';
            end;

        end if;

        if v_checkNameBirthday = 1 then
            if v_RegistNoteVal = 'P' then
                --v_RegistNote := v_RegistNote || ' + ' || 'Trung Ho ten va Ngay sinh voi tai khoan da co trong he thong';
                v_RegistNoteVal := 'P3';
                begin
                    select cdcontent into v_RegistNote from allcode where cdname='EKYC_ERRDESC' and cdtype='CF' and cdval = v_RegistNoteVal;
                    exception WHEN OTHERS THEN
                         v_RegistNote := v_RegistNote || ' + ' || 'Trung Ho ten va Ngay sinh voi tai khoan da co trong he thong';
                end;
            else
                --v_RegistNote := v_RegistNote  || 'Trung Ho ten va Ngay sinh voi tai khoan da co trong he thong';
                v_RegistNoteVal := 'P2';
                begin
                    select cdcontent into v_RegistNote from allcode where cdname='EKYC_ERRDESC' and cdtype='CF' and cdval = v_RegistNoteVal;
                    exception WHEN OTHERS THEN
                         v_RegistNote := v_RegistNote  || 'Trung Ho ten va Ngay sinh voi tai khoan da co trong he thong';
                end;
            end if;
        end if;
        --End BMSSUP-95
         insert into REGISTERONLINE (AUTOID, CUSTOMERTYPE, CUSTOMERNAME, CUSTOMERBIRTH, IDTYPE, IDCODE, IDDATE, IDPLACE, EXPIREDATE, SEX,
                ADDRESS, contactAddress, PRIVATEPHONE, MOBILE, FAX, EMAIL, OFFICE, POSITION, COUNTRY, CUSTOMERCITY,BENEFICIARYNAME, BENEFICIARYBIRTHDAY,
                BENEFICIARYPHONE, BENEFICIARYID, BENEFICIARYIDDATE, BENEFICIARYIDPLACE, AUTHORIZEDNAME, AUTHORIZEDPHONE, AUTHORIZEDID,
                AUTHORIZEDIDDATE, AUTHORIZEDIDPLACE, CUSTODYCD, BRID, REREGISTER, RERELATIONSHIP, TXDATE,STATUS,
                REFULLNAME, RETLID, REGISTERSERVICES, REGISTERNOTITRAN, AUTHENTYPEONLINE, AUTHENTYPEMOBILE, AREAOPENACCOUNT, BRANCHOPENACCOUNT, ACCTYPE, reqid,
                NOTE)
         values (l_olautoid, v_typeacc, INITCAP(TRIM(pv_fullname)), to_date(pv_dateofbirth,'dd/mm/rrrr'),pv_idtype, pv_idcode, to_date(pv_iddate,'dd/mm/rrrr'), pv_idplace, add_MONTHS(to_date(pv_iddate,'dd/mm/rrrr'),15*12), pv_sex,
                pv_address, pv_address2, null, pv_mobile, null, pv_email, pv_email, '001', pv_country, pv_province, null, null,
                null, null, null, null, null, null, null, null, null, null, pv_brid, v_iscareby, null, l_CURRDATE,v_RegistNoteVal,
                null, pv_careby, 'NNNNN', 'NNN', 'NN', null, null, null, 'E', l_reqid,
                v_RegistNote);

         UPDATE apiOpenAccount SET EKYCAI = pv_ekycai, last_change = CURRENT_TIMESTAMP WHERE REQID = l_reqid;
         UPDATE apiOpenAccountlog SET status = 'E', last_change = CURRENT_TIMESTAMP WHERE REQID = l_reqid;

        insert into registeronlinelog (AUTOID, CUSTOMERTYPE, CUSTOMERNAME, CUSTOMERBIRTH, IDTYPE,
                    IDCODE, IDDATE, IDPLACE, EXPIREDATE, MOBILE, EMAIL, COUNTRY,
                    CUSTOMERCITY, SEX, CONTACTADDRESS, CUSTODYCD, BRID, TXDATE, DELETEDATE, REQID,
                    NOTE)
        values (seq_registeronlinelog.nextval, v_typeacc, INITCAP(TRIM(pv_fullname)), to_date(pv_dateofbirth,'dd/mm/rrrr'), pv_idtype,
               pv_idcode, to_date(pv_iddate,'dd/mm/rrrr'), pv_idplace, add_MONTHS(to_date(pv_iddate,'dd/mm/rrrr'),15*12), pv_mobile, pv_email, pv_country,
               pv_province, pv_sex, pv_address, NULL, pv_brid, l_CURRDATE, null,l_reqid,
               v_RegistNote);

        COMMIT;

    begin
        select varvalue into l_emailmg from sysvar where varname='EKYC_EMAIL';
    exception WHEN OTHERS THEN
             l_emailmg := '';
    end;

    begin
        select cdcontent into pv_status from allcode where cdname='STATUS_EMAIL' and cdtype='CF' and cdval = v_RegistNoteVal;
    exception WHEN OTHERS THEN
             pv_status := '';
    end;

         l_datasource := 'select '''||INITCAP(TRIM(pv_fullname))||''' fullname, '''' custodycd, '''
                                ||pv_iddate||''' iddate, '''
                                ||pv_idplace||''' idplace, '''
                                ||pv_address||''' address, '''
                                ||pv_mobile||''' mobile, '''
                                ||pv_email||''' email, '''
                                ||pv_status||''' status, '''
                                ||pv_idcode||''' PV_IDCODE from dual';
         nmpks_ems.InsertEmailLog(l_emailmg, '315E', l_datasource, '');

    END IF;

   p_err_code   := 0;
   p_err_param  := 'Successfull';
   plog.setEndSection(pkgctx, 'pr_openaccount');
EXCEPTION
  WHEN OTHERS THEN
    p_err_code := errnums.C_SYSTEM_ERROR;
    p_err_param := 'SYSTEM ERROR';
    plog.error(pkgctx, SQLERRM || ' AT ' || dbms_utility.format_error_backtrace);
    plog.setendsection(pkgctx, 'pr_openaccount');
END;

PROCEDURE pr_add_register (pv_reqid        IN VARCHAR2,
                           pv_typeofacc    IN VARCHAR2,
                           pv_service      IN VARCHAR2,
                           pv_SMARTOTP     IN VARCHAR2,
                           pv_menthod      IN VARCHAR2,
                           p_err_code      OUT varchar2,
                           p_err_message   out VARCHAR2)
IS
 l_ekycai        NUMBER;
 l_afacctno      VARCHAR2(20);
 l_custodycd     VARCHAR2(20);
 v_busdate       DATE;
 l_custid        VARCHAR2(10);
 l_orgLoginpwd   varchar2(20);
 l_Loginpwd      varchar2(1000);
 l_orgTradingpwd   varchar2(20);
 l_Tradingpwd      varchar2(1000);
 l_templateid    VARCHAR2(10);
 l_email         varchar2(100);
 l_mobile        varchar2(100);
 l_fullname      varchar2(1000);
 v_strtypetrade  varchar2(1000);
 l_datasourcesql varchar2(1000);
 v_registerservices  VARCHAR2(10);
 v_registernotitran  VARCHAR2(10);
 v_authentypeonline  VARCHAR2(10);
 l_brid          varchar2(10);
 v_count1        number;
 v_count2        number;
 l_sex           varchar2(10);
 v_strSex        varchar2(50);
 v_chinhanh      varchar2(1000);
 v_diachi        varchar2(1000);
 l_datasourcesms varchar2(2000);
 v_EKYC_AI       number;
 l_tradingpass_send   varchar2(100);
 v_sdt           varchar2(20);
 l_CURRDATE      Date;
 l_orgPINpwd   varchar2(20);
 l_PINpwd      varchar2(1000);
 l_PINpass_send   varchar2(100);
BEGIN
  plog.setBeginSection (pkgctx, 'pr_register_email');
  p_err_code := 0;
  p_err_message := '';
  l_CURRDATE := getcurrdate;

  SELECT to_date(varvalue,'DD/MM/RRRR') INTO v_busdate
  FROM sysvar
  WHERE varname = 'CURRDATE' AND grname = 'SYSTEM';

  SELECT to_number(varvalue) INTO v_EKYC_AI
  FROM sysvar
  WHERE varname = 'EKYC_AI' AND grname = 'SYSTEM';

  BEGIN

    SELECT EKYCAI, AFACCTNO, CUSTODYCD, FULLNAME, EMAIL, MOBILE, BRID, SEX
      into l_ekycai, l_afacctno, l_custodycd, l_fullname, l_email, l_mobile, l_brid, l_sex
    FROM (SELECT td.*, ROW_NUMBER() OVER (PARTITION BY reqid ORDER BY AUTOID DESC) RN
          FROM APIOPENACCOUNT td
          WHERE TXDATE = l_CURRDATE and reqid = pv_reqid
          ORDER BY AUTOID DESC) WHERE RN = 1 ;

    SELECT CUSTID into l_custid from AFMAST WHERE ACCTNO = l_afacctno;
  EXCEPTION
  WHEN OTHERS THEN
    l_ekycai        := 0;
    l_custodycd     := 0;
    l_custid        := 0;
  END;

    insert into EKYCACCT_EX (AUTOID, CUSTODYCD, REQID, typeofacc, service , SMARTOTP, menthod, txdate)
    values (SEQ_EKYCACCT_EX.Nextval, l_custodycd, pv_reqid, pv_typeofacc, pv_service, pv_SMARTOTP, pv_menthod, v_busdate);

    BEGIN
      SELECT
      case when substr(pv_service,1,1) = 'O' then 'Y' ELSE 'N' end ||
      case when substr(pv_service,instr(pv_service,',',1,1)+1,1) = 'T' then 'Y' ELSE 'N' end ||
      case when substr(pv_service,instr(pv_service,',',1,2)+1,1) = 'P' then 'Y' ELSE 'N' end ||
      case when substr(pv_typeofacc,1,2) = 'SA' then '' end ||
      case when substr(pv_typeofacc,instr(pv_typeofacc,',',1,1)+1,2) = 'MA' then 'Y' else 'N' end  ||
      case when substr(pv_typeofacc,instr(pv_typeofacc,',',1,2)+1,2) = 'PS' then 'Y' else 'N' end into v_registerservices FROM DUAL;

      SELECT
      case when substr(pv_menthod,1,1) = 'E' then 'Y' ELSE 'N' end ||
      case when substr(pv_menthod,instr(pv_menthod,',',1,1)+1,1) = 'S' then 'Y' ELSE 'N' end ||
      case when substr(pv_menthod,instr(pv_menthod,',',1,2)+1,1) = 'A' then 'Y' else 'N' end into v_registernotitran FROM DUAL;

      SELECT
      case when substr(pv_SMARTOTP,1,2)= '1'then 'Y' else 'N' end  ||
      case when substr(pv_SMARTOTP,3,2)= '4'then 'Y' else 'N' end into v_authentypeonline FROM DUAL;
    END;

    UPDATE REGISTERONLINE SET registerservices = v_registerservices,
                              registernotitran = v_registernotitran,
                              authentypeonline = v_authentypeonline,
                              last_change = CURRENT_TIMESTAMP WHERE REQID = pv_reqid;

    IF l_ekycai >= v_EKYC_AI THEN -->= 90 THEN
      --------------update thong tin cf,af------------
      if instr(pv_service,'P') <> 0 then
         update afmast set autoadv ='Y' where acctno = l_afacctno;
      else
         update afmast set autoadv ='N' where acctno = l_afacctno;
      end if;
      if instr(pv_service,'T') <> 0 then
         update cfmast set tradetelephone ='Y' where custodycd = l_custodycd;
      else
         update cfmast set tradetelephone ='N' where custodycd = l_custodycd;
      end if;
      if instr(pv_service,'O') <> 0 then
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

         update afmast set brid = l_brid where acctno = l_afacctno;
      --------------Sinh dich vu truc tuyen------------
      Delete from otright where cfcustid = l_custid;
      INSERT INTO otright (AUTOID, CFCUSTID, AUTHCUSTID,AUTHTYPE,VALDATE,EXPDATE,DELTD, VIA, LASTDATE,LASTCHANGE)
      VALUES(seq_otright.nextval,l_custid, l_custid, '1',v_busdate,ADD_MONTHS(v_busdate,30*12),'N','A',NULL,v_busdate);
      if pv_SMARTOTP <> '1' then
          INSERT INTO otright (AUTOID, CFCUSTID, AUTHCUSTID,AUTHTYPE,VALDATE,EXPDATE,DELTD, VIA, LASTDATE,LASTCHANGE)
          VALUES(seq_otright.nextval,l_custid, l_custid, pv_SMARTOTP,v_busdate,ADD_MONTHS(v_busdate,30*12),'N','O',NULL,v_busdate);
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
                if pv_SMARTOTP <> '1' then
                    insert into otrightdtl(autoid,cfcustid,authcustid,otmncode,otright,deltd,via)
                    VALUES( seq_otrightdtl.nextval,l_custid,l_custid,rec.cdval,'YYYYNNNNN','N','O');
                end if;
            ELSE
                insert into otrightdtl(autoid,cfcustid,authcustid,otmncode,otright,deltd,via)
                VALUES( seq_otrightdtl.nextval,l_custid,l_custid,rec.cdval,'YYYYYNYNN','N','A');
                if pv_SMARTOTP <> '1' then
                    insert into otrightdtl(autoid,cfcustid,authcustid,otmncode,otright,deltd,via)
                    VALUES( seq_otrightdtl.nextval,l_custid,l_custid,rec.cdval,'YYYYNNNNY','N','O');
                end if;
            END IF;
        end loop;

    if instr(pv_service,'O') <> 0 then
      l_orgLoginpwd  := cspks_system.fn_PasswordGenerator(6);
      l_Loginpwd     := genencryptpassword(trim(l_orgLoginpwd));
      l_orgTradingpwd  := cspks_system.fn_PasswordGenerator(6);
      l_Tradingpwd     := genencryptpassword(trim(l_orgTradingpwd));

      update userlogin set status = 'E' where USERNAME = l_custodycd;
      --28/12/2021: Dac thu cua BMS Userlogin pv_SMARTOTP = 1 moi chuyen tien tren web khong loi
      INSERT INTO userlogin (USERNAME,HANDPHONE,LOGINPWD,TRADINGPWD,AUTHTYPE,STATUS,LOGINSTATUS,LASTCHANGED,NUMBEROFDAY,LASTLOGIN,ISRESET,ISMASTER,TOKENID)
      VALUES(l_custodycd,NULL,l_Loginpwd,l_Tradingpwd,'1'/*pv_SMARTOTP*/,'A','O',v_busdate,30,v_busdate,'Y','N','{MSBS{SMS{'||NVL(l_mobile,'SDT')||'}}}');
    end if;

    if instr(pv_service,'T') <> 0 then
        l_orgPINpwd := cspks_system.fn_PasswordGenerator(6);

        update cfmast set pin = l_orgPINpwd where custodycd = l_custodycd;

        l_PINpass_send := 'BMSC thong bao: Mat khau GD qua dien thoai cua so tai khoan ' || l_custodycd || ' la: ' || l_orgPINpwd || '. ';
        nmpks_ems.InsertEmailLog(l_mobile, '314S', l_PINpass_send, '');

    end if;

    --Tao Emaillog
        GenTemplate313E(l_fullname,l_custodycd,l_orgLoginpwd,l_orgTradingpwd,l_email);

      /*If length(l_mobile)>0 then
         l_tradingpass_send := ' - Mat khau dat lenh: ' || l_orgTradingpwd;
         l_datasourcesms:='select ''' || l_custodycd || ''' username, ''' || l_orgLoginpwd || ''' loginpwd, ''' || l_tradingpass_send || ''' tradingpwd from dual';
         nmpks_ems.InsertEmailLog(l_mobile, '304B', l_datasourcesms, '');
      end if;*/
    END IF;

  p_err_code   := 0;
  p_err_message  := 'Successfull';
  plog.setEndSection (pkgctx, 'pr_add_register');
EXCEPTION
  WHEN OTHERS THEN
    p_err_code := errnums.C_SYSTEM_ERROR;
    p_err_message := 'SYSTEM ERROR';
    plog.error (pkgctx, SQLERRM || ' AT ' || dbms_utility.format_error_backtrace);
    plog.setEndSection (pkgctx, 'pr_add_register');
END;

PROCEDURE pr_add_image (pv_reqid        IN VARCHAR2,
                        pv_IDATTACH     IN CLOB,
                        pv_type         IN VARCHAR2,
                        p_err_code      OUT varchar2,
                        p_err_message   out VARCHAR2) is
BEGIN

  plog.setBeginSection (pkgctx, 'pr_add_image');
  p_err_code := 0;
  p_err_message := '';

   if pv_type = '1' then
      UPDATE REGISTERONLINE SET IDATTACH = pv_IDATTACH, last_change = CURRENT_TIMESTAMP WHERE REQID = pv_reqid;
   elsif pv_type ='2' then
      UPDATE REGISTERONLINE SET IDATTACH1 = pv_IDATTACH, last_change = CURRENT_TIMESTAMP WHERE REQID = pv_reqid;
   else
      UPDATE REGISTERONLINE SET IDATTACH2 = pv_IDATTACH, last_change = CURRENT_TIMESTAMP WHERE REQID = pv_reqid;
   end if;

  p_err_code   := 0;
  p_err_message  := 'Successfull';
  plog.setEndSection (pkgctx, 'pr_add_image');
EXCEPTION
  WHEN OTHERS THEN
    p_err_code := errnums.C_SYSTEM_ERROR;
    p_err_message := 'SYSTEM ERROR';
    plog.error (pkgctx, SQLERRM || ' AT ' || dbms_utility.format_error_backtrace);
    plog.setEndSection (pkgctx, 'pr_add_image');
END;

PROCEDURE pr_openaccount_full(pv_fullname              IN VARCHAR2,
                              pv_sex                   IN VARCHAR2,
                              pv_dateofbirth           IN VARCHAR2,
                              pv_country               IN VARCHAR2,
                              pv_idtype                IN VARCHAR2,
                              pv_idcode                IN VARCHAR2,
                              pv_iddate                IN VARCHAR2,
                              pv_idplace               IN VARCHAR2,
                              pv_email                 IN VARCHAR2,
                              pv_address               IN VARCHAR2,
                              pv_address2              IN VARCHAR2,
                              pv_province              IN VARCHAR2,
                              pv_reqid                 IN VARCHAR2,
                              pv_ekycai                IN NUMBER,
                              pv_america               IN VARCHAR2 DEFAULT 'N',
                              pv_national              IN VARCHAR2,
                              pv_company1              IN VARCHAR2,
                              pv_position1             IN VARCHAR2,
                              pv_company2              IN VARCHAR2,
                              pv_position2             IN VARCHAR2,
                              pv_company3              IN VARCHAR2,
                              pv_IDATTACH              IN CLOB,
                              pv_IDATTACH1             IN CLOB,
                              pv_typeofacc             IN VARCHAR2,
                              pv_service               IN VARCHAR2,
                              pv_SMARTOTP              IN VARCHAR2,
                              pv_menthod               IN VARCHAR2,
                              p_err_code               OUT VARCHAR2,
                              p_err_param              OUT VARCHAR2)
IS
l_reqid       VARCHAR2(14);
v_busdate     DATE;
v_count       number;
v_custodycd   varchar2(20);
v_afacctno    varchar2(20);
v_actype      varchar2(20);
v_mobile      varchar2(20);
v_careby      varchar2(20);
v_brid        varchar2(20);
l_CURRDATE    Date;
BEGIN
  plog.setBeginSection(pkgctx, 'pr_openaccount_full');
  p_err_code := systemnums.C_SUCCESS;
  p_err_param := '';
  --pv_lifecycle:='';
  l_CURRDATE := getcurrdate;

  SELECT to_date(varvalue,systemnums.c_date_format) INTO v_busdate
  FROM sysvar
  WHERE varname = 'CURRDATE' AND grname = 'SYSTEM';
  l_reqid := pv_reqid;

  BEGIN
    select MOBILE, CAREBYID, BRANCH into v_mobile, v_careby, v_brid FROM
    (SELECT td.*, ROW_NUMBER() OVER (PARTITION BY reqid ORDER BY AUTOID DESC) RN
     FROM EKYC_CFINFOR td WHERE TXDATE = l_CURRDATE and reqid = l_reqid ORDER BY AUTOID DESC) WHERE RN = 1 ;
  EXCEPTION
  WHEN OTHERS THEN
    v_mobile   := 0;
    v_careby   := 0;
    v_brid     := 0;
  END;

  --Check required
  IF pv_reqid is null OR trim(pv_fullname) is null OR pv_sex is null OR pv_dateofbirth IS NULL
    OR trim(pv_idcode) is null OR pv_iddate is null OR pv_country is null
    OR trim(pv_idplace) is null OR trim(pv_email) is null OR pv_province is null
    OR trim(pv_address) is null OR pv_idtype is null THEN
      p_err_code  := '-260265';
      p_err_param := cspks_system.fn_get_errmsg(p_err_code);
      UPDATE APIOpenAccount SET ERRNUM = p_err_code, ERRDESC = p_err_param, last_change = CURRENT_TIMESTAMP WHERE REQID = l_reqid;
      plog.setendsection(pkgctx, 'pr_openaccount_full');
      return;
  END IF;
    --Check du lieu dau vao
  BEGIN
    --Check CMND
      SELECT COUNT(1) INTO v_count FROM cfmast WHERE idcode = trim(pv_idcode) AND status <> 'C';
      IF v_count > 0 THEN
        p_err_code  := '-200020';
        p_err_param := cspks_system.fn_get_errmsg(p_err_code);
        UPDATE APIOpenAccount SET ERRNUM = p_err_code, ERRDESC = p_err_param, last_change = CURRENT_TIMESTAMP WHERE REQID = l_reqid;
        plog.setendsection(pkgctx, 'pr_openaccount_full');
        return;
      END IF;
      IF isnumber(pv_idcode) = 'N' THEN
        p_err_code  := '-260264';
        p_err_param := cspks_system.fn_get_errmsg(p_err_code);
        plog.setendsection(pkgctx, 'pr_openaccount_full');
        RETURN;
      END IF;
    --Check ngay sinh du 18 tuoi
      IF MONTHS_BETWEEN(v_busdate,to_date(pv_dateofbirth,'dd/mm/rrrr')) < 216 THEN
        p_err_code  := '-200090';
        p_err_param := cspks_system.fn_get_errmsg(p_err_code);
        UPDATE APIOpenAccount SET ERRNUM = p_err_code, ERRDESC = p_err_param, last_change = CURRENT_TIMESTAMP WHERE REQID = l_reqid;
        plog.setendsection(pkgctx, 'pr_openaccount_full');
        return;
      END IF;
    --Check ngay cap CMND ngay sinh - ngay cap >= 14
      IF MONTHS_BETWEEN(to_date(pv_iddate,'dd/mm/rrrr'),to_date(pv_dateofbirth,'dd/mm/rrrr')) < 168
      THEN
        p_err_code  := '-260263';
        p_err_param := cspks_system.fn_get_errmsg(p_err_code);
        UPDATE APIOpenAccount SET ERRNUM = p_err_code, ERRDESC = p_err_param, last_change = CURRENT_TIMESTAMP WHERE REQID = l_reqid;
        plog.setendsection(pkgctx, 'pr_openaccount_full');
        return;
      END IF;
    --ngay hien tai - ngay cap  <= 15
      IF MONTHS_BETWEEN(v_busdate,to_date(pv_iddate,'dd/mm/rrrr')) > 180
      THEN
        p_err_code  := '-200207';
        p_err_param := cspks_system.fn_get_errmsg(p_err_code);
        UPDATE APIOpenAccount SET ERRNUM = p_err_code, ERRDESC = p_err_param, last_change = CURRENT_TIMESTAMP WHERE REQID = l_reqid;
        plog.setendsection(pkgctx, 'pr_openaccount_full');
        return;
      END IF;
    --Check email
      IF NOT REGEXP_LIKE(pv_email, '\w+@\w') THEN
        p_err_code  := '-260260';
        p_err_param := cspks_system.fn_get_errmsg(p_err_code);
        UPDATE APIOpenAccount SET ERRNUM = p_err_code, ERRDESC = p_err_param, last_change = CURRENT_TIMESTAMP WHERE REQID = l_reqid;
        plog.setendsection(pkgctx, 'pr_openaccount_full');
        return;
      END IF;
    if not nmpks_ems.CheckEmail(pv_email) then
      p_err_code    :='-260260';
      p_err_param   := cspks_system.fn_get_errmsg(p_err_code);
      UPDATE APIOpenAccount SET ERRNUM = p_err_code, ERRDESC = p_err_param, last_change = CURRENT_TIMESTAMP WHERE REQID = l_reqid;
      plog.error(pkgctx, 'Error:'  || p_err_param);
      plog.setendsection(pkgctx, 'pr_openaccount_full');
      RETURN;
    end if;

  END;

  -- gen custodycd, afacctno
  BEGIN
    SELECT SUBSTR(INVACCT,1,4) || lpad(MAX(ODR)+1,6,0) into v_custodycd FROM
    (SELECT ROWNUM ODR, INVACCT
    FROM (SELECT CUSTODYCD INVACCT FROM (select custodycd from cfmast
                                         union
                                         select custodycd from registeronline
                                         where   AUTOID not in (select OLAUTOID from CFMAST CF
                                                                where CF.OPENVIA='O'
                                                                  AND CF.CUSTODYCD IS NOT NULL)
                                         union
                                         select username from cfmast
                                         )CFMAST
    WHERE SUBSTR(CUSTODYCD,1,4)= '086' || 'C' AND TRIM(TO_CHAR(TRANSLATE(SUBSTR(CUSTODYCD,5,6),'0123456789',' '))) IS NULL
    ORDER BY CUSTODYCD) DAT
    WHERE TO_NUMBER(SUBSTR(INVACCT,5,6))=ROWNUM) INVTAB
    GROUP BY SUBSTR(INVACCT,1,4);

    SELECT SUBSTR(INVACCT,1,4) || lpad(MAX(ODR)+1,6,0) into v_afacctno
    FROM (SELECT ROWNUM ODR, INVACCT
          FROM (SELECT ACCTNO INVACCT FROM AFMAST WHERE SUBSTR(ACCTNO,1,4)= '0001' ORDER BY ACCTNO) DAT
          WHERE TO_NUMBER(SUBSTR(INVACCT,5,6))=ROWNUM) INVTAB
    GROUP BY SUBSTR(INVACCT,1,4);
  EXCEPTION
  WHEN OTHERS THEN
    p_err_code  := '-260266';
    p_err_param := cspks_system.fn_get_errmsg(p_err_code);
    plog.setendsection(pkgctx, 'pr_openaccount_full');
    return;
  END;

  --check custodycd
  select count(*) into v_count from cfmast where custodycd = v_custodycd;
  if v_count > 0 then
     p_err_code     :='-200019';
     p_err_param    := cspks_system.fn_get_errmsg(p_err_code);
     UPDATE APIOpenAccount SET ERRNUM = p_err_code, ERRDESC = p_err_param, last_change = CURRENT_TIMESTAMP WHERE REQID = l_reqid;
     plog.error(pkgctx, 'Error:'  || p_err_param);
     plog.setendsection(pkgctx, 'pr_openaccount_full');
     RETURN;
  end if;

  --check user_name
  select count(*) into v_count from cfmast where username = v_custodycd;
  if v_count > 0 then
     p_err_code     :='-200066';
     p_err_param    := cspks_system.fn_get_errmsg(p_err_code);
     UPDATE APIOpenAccount SET ERRNUM = p_err_code, ERRDESC = p_err_param, last_change = CURRENT_TIMESTAMP WHERE REQID = l_reqid;
     plog.error(pkgctx, 'Error:'  || p_err_param);
     plog.setendsection(pkgctx, 'pr_openaccount_full');
     RETURN;
  end if;

  --check tieu khoan
  select count(*) into v_count from afmast where acctno = v_afacctno;
  if v_count > 0 then
     p_err_code     :='-200048';
     p_err_param    := cspks_system.fn_get_errmsg(p_err_code);
     UPDATE APIOpenAccount SET ERRNUM = p_err_code, ERRDESC = p_err_param, last_change = CURRENT_TIMESTAMP WHERE REQID = l_reqid;
     plog.error(pkgctx, 'Error:'  || p_err_param);
     plog.setendsection(pkgctx, 'pr_openaccount_full');
     RETURN;
  end if;

       insert into APIOpenAccount (autoid, FULLNAME, SEX, DATEOFBIRTH, COUNTRY, IDTYPE,
                  IDCODE, IDDATE, IDPLACE, EMAIL, MOBILE, ADDRESS, BRID, CAREBY, APINAME, LASTDATE, REQID,
                  company1, position1, company2, position2, company3, isamerica, national, TXDATE)
       values (seq_apiopenaccount.nextval, INITCAP(TRIM(pv_fullname)), pv_sex, to_date(pv_dateofbirth,'dd/mm/rrrr'), pv_country, pv_idtype,
               trim(pv_idcode), to_date(pv_iddate,'dd/mm/rrrr'), trim(pv_idplace), trim(pv_email), v_mobile, trim(pv_address), v_brid, v_careby, 'pr_openaccount_auto', v_busdate, l_reqid,
               pv_company1, pv_position1, pv_company2, pv_position2, pv_company3, pv_america, pv_national, l_CURRDATE);

  v_actype  := '0001';
  select b.aftype into v_actype from brgrp b where brid = v_brid;

  pr_openaccount (l_reqid, v_custodycd, v_afacctno, v_actype, pv_fullname, pv_sex, pv_dateofbirth, pv_country,
                  pv_idtype, pv_idcode, pv_iddate, pv_idplace, pv_email, v_mobile, pv_address, pv_address2,
                  v_brid, v_careby,'Y', round(pv_ekycai,0), pv_province, '', p_err_code, p_err_param);

      UPDATE REGISTERONLINE SET IDATTACH = pv_IDATTACH, IDATTACH1 = pv_IDATTACH, last_change = CURRENT_TIMESTAMP WHERE REQID = pv_reqid;

   pr_add_register(pv_reqid, pv_typeofacc, pv_service, pv_SMARTOTP, pv_menthod, p_err_code, p_err_param);

  plog.setEndSection(pkgctx, 'pr_openaccount_full');
EXCEPTION
  WHEN OTHERS THEN
    p_err_code := errnums.C_SYSTEM_ERROR;
    p_err_param := 'SYSTEM ERROR';
    plog.error(pkgctx, SQLERRM || ' AT ' || dbms_utility.format_error_backtrace);
    plog.setendsection(pkgctx, 'pr_openaccount_full');
END;


--Dang ki so dien thoai OTP
PROCEDURE pr_SMS_OTP ( p_custodycd         IN  VARCHAR2,
                     p_TOKENID             IN  VARCHAR2,
                     p_err_code            OUT varchar2,
                     p_err_message         out VARCHAR2)
IS
  l_txmsg tx.msg_rectype;
  l_txdesc        VARCHAR2(500);
  l_en_txdesc     VARCHAR2(500);
  l_CURRDATE      Date;
  l_reqid   VARCHAR2(14);
  v_count   number;
  BEGIN
    plog.setBeginSection (pkgctx, 'pr_SMS_OTP');
    p_err_code := 0;
    p_err_message := '';
    l_CURRDATE := getcurrdate;

    l_reqid := to_char(l_CURRDATE,'rrrrmmdd')||LPAD (seq_apiopenaccount.NEXTVAL, 6, '0');

    insert into APIOpenAccount (REQID, CUSTODYCD, TOKENID , APINAME, LASTDATE)
      values (l_reqid, p_custodycd, p_TOKENID, 'pr_SMS_OTP', l_CURRDATE);

    --check stk luu ky
    select count(*) into v_count from cfmast where custodycd = p_custodycd and status <> 'C';
    if v_count = 0 then
      p_err_code:='-200216';
      p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
      UPDATE APIOpenAccount SET ERRNUM = p_err_code, ERRDESC = p_err_message, last_change = CURRENT_TIMESTAMP WHERE REQID = l_reqid;
      plog.error(pkgctx, 'Error:'  || p_err_message);
      plog.setendsection(pkgctx, 'pr_SMS_OTP');
      RETURN;
    end if;

    IF (regexp_like(p_TOKENID,'^\0\d{9}$') AND substr(p_TOKENID,1,2) <> '02') OR regexp_like(p_TOKENID,'^\02\d{9}$') THEN
      SELECT TXDESC,EN_TXDESC into l_txdesc, l_en_txdesc FROM  TLTX WHERE TLTXCD= '0033';

       FOR REC_SMS IN (
         SELECT CUSTID,FULLNAME,USERNAME ,case when CUSTODYCD is null then '' else CUSTODYCD end CUSTODYCD
         FROM CFMAST WHERE CUSTODYCD = p_custodycd
       )
       LOOP
        l_txmsg.msgtype:='T';
        l_txmsg.local:='N';
        l_txmsg.tlid        := systemnums.C_ONLINE_USERID;

        SELECT SYS_CONTEXT ('USERENV', 'HOST'),
                 SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15)
          INTO l_txmsg.wsname, l_txmsg.ipaddress
        FROM DUAL;
        l_txmsg.off_line    := 'N';
        l_txmsg.deltd       := txnums.c_deltd_txnormal;
        l_txmsg.txstatus    := txstatusnums.c_txcompleted;
        l_txmsg.msgsts      := '0';
        l_txmsg.ovrsts      := '0';
        l_txmsg.batchname   := 'DAY';
        l_txmsg.txdate      := l_CURRDATE;
        l_txmsg.busdate     := l_CURRDATE;
        l_txmsg.tltxcd      := '0033';

        BEGIN
            --set txnum
            SELECT systemnums.C_OL_PREFIXED
                     || LPAD (seq_BATCHTXNUM.NEXTVAL, 8, '0')
            INTO l_txmsg.txnum
            FROM DUAL;

            --Set cac field giao dich
            --03  CUSTID      C
            l_txmsg.txfields ('03').defname   := 'CUSTID';
            l_txmsg.txfields ('03').TYPE      := 'C';
            l_txmsg.txfields ('03').VALUE     := REC_SMS.CUSTID;

            --88   C   CUSTODYCD
            l_txmsg.txfields ('88').defname   := 'CUSTODYCD';
            l_txmsg.txfields ('88').TYPE      := 'C';
            l_txmsg.txfields ('88').VALUE     := REC_SMS.CUSTODYCD;

            --05  USERNAME
            l_txmsg.txfields ('05').defname   := 'USERNAME';
            l_txmsg.txfields ('05').TYPE      := 'C';
            l_txmsg.txfields ('05').VALUE     := REC_SMS.USERNAME;

            --08  FULLNAME    C
            l_txmsg.txfields ('08').defname   := 'FULLNAME';
            l_txmsg.txfields ('08').TYPE      := 'C';
            l_txmsg.txfields ('08').VALUE     := REC_SMS.FULLNAME;

            --15  TOKENID     C
            l_txmsg.txfields ('15').defname   := 'TOKENID';
            l_txmsg.txfields ('15').TYPE      := 'C';
            l_txmsg.txfields ('15').VALUE     := p_TOKENID;

            --30  DESC
            l_txmsg.txfields ('30').defname   := 'DESC';
            l_txmsg.txfields ('30').TYPE      := 'C';
            l_txmsg.txfields ('30').VALUE     := l_txdesc;

            /*BEGIN
                IF txpks_#0033.fn_AutoTxProcess (l_txmsg,
                                                 p_err_code,
                                                 p_err_message
                   ) <> systemnums.c_success
                THEN
                   plog.error (pkgctx, 'got  0033: ' || p_err_code);
                   ROLLBACK;
                   p_err_message  := cspks_system.fn_get_errmsg(p_err_code);
                   plog.error(pkgctx, 'Error: 0error033:'  || p_err_message);
                   plog.setendsection(pkgctx, 'pr_SMS_OTP');
                   RETURN;
                END IF;
            END;*/
         END;
      END LOOP;
    ELSE
      p_err_code    := '-100999';
      p_err_message := cspks_system.fn_get_errmsg(p_err_code);
      UPDATE APIOpenAccount SET ERRNUM = p_err_code, ERRDESC = p_err_message, last_change = CURRENT_TIMESTAMP WHERE REQID = l_reqid;
      plog.error(pkgctx, 'Error:'  || p_err_message);
      plog.setendsection(pkgctx, 'pr_SMS_OTP');
      return;
    END IF;

    p_err_code   := 0;
    p_err_message  := 'Successfull';
    plog.setEndSection (pkgctx, 'pr_SMS_OTP');
  EXCEPTION
    WHEN OTHERS THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      p_err_message := 'SYSTEM ERROR';
      plog.error (pkgctx, SQLERRM || ' AT ' || dbms_utility.format_error_backtrace);
      plog.setEndSection (pkgctx, 'pr_SMS_OTP');
  END pr_SMS_OTP;

procedure pr_GenOTP(
        p_JSonInput  Clob,
        p_via  IN  varchar2,
        p_tlid  IN  varchar2,
        p_language in varchar2 default C_LANG_VI,
        p_objname  in varchar2 default '',
        p_err_code in out varchar2,
        p_err_param in out varchar2 )
Is
/*
  **    Description: Tao OTP va gui cho KH, khi mo tai khoan (eKYC)
  **    Person            Date           Comments
  **    TruongLD          03/03/2021         Created
  **    Input:
        ==> p_JSonInput: '{"otpkey":"<So CMND cua KH>_<ma_KH>","OTPType":"<$Loai OTP, mac dinh la SMS>","mobile":"<$So dien thoai>","email":"<$Email>"}'
                         '{"otpkey":"250567964_01","OTPType": "SMS","mobile":"0988818196","email":"leductruong@gmail.com"}'
        ==> p_via: Kenh yeu cau
        ==> p_tlid: User yeu cau
        ==> p_language: Ngon ngu dang su dung
        ==> p_objname: Key de check quyen neu can.
 **    Output:
        ==> p_err_code: Ma loi
        ==> p_err_param: Mo ta loi
*/
    l_count         number(20);
    l_OTPLength     number(20);
    l_OTPTimeOut    number(20);
    v_shortname     varchar2(200);
    l_OTPValue      varchar2(200);
    l_OTPEncrypt    varchar2(500);
    l_currdate      Date;
    l_ViaDesc       varchar2(100);
    l_DataContent   varchar2(3000);
    l_DataSource    varchar2(3000);

    l_strJSonInput  Clob;
    l_JSonData      fss_json;
    l_OtpKey        varchar2(200);
    l_Mobile        varchar2(200);
Begin
    plog.setBeginsection(pkgctx, 'pr_GenOTP');
    p_err_code  := systemnums.C_SUCCESS;
    p_err_param := 'SUCCESS';
    l_currdate  := Getcurrdate;

    l_strJSonInput := p_JSonInput;
    Begin
        l_JSonData      := json_parser.parser((l_strJSonInput));
        l_OtpKey        := json_ext.get_string(l_JSonData, 'otpkey', 1);
        l_Mobile        := json_ext.get_string(l_JSonData, 'mobile', 1);
    Exception
    When others then
        plog.error(pkgctx, 'JSonData invalid '
            ||',p_JSonInput='|| substr(p_JSonInput,1,3000)
            ||',p_via='||p_via
            ||',p_tlid='||p_tlid
            ||',p_objname='||p_objname
            ||',p_language='||p_language);
      plog.setEndsection(pkgctx, 'pr_GenOTP');
      p_err_code := errnums.C_SYSTEM_ERROR;
      --p_err_param := fn_get_errmsg(p_err_code,p_language);
      raise errnums.E_BIZ_RULE_INVALID;
    End;

    Begin
        SELECT TO_NUMBER(VARVALUE) INTO l_OTPLength FROM SYSVAR WHERE VARNAME = 'OTPPASSLENG' AND GRNAME='SYSTEM';
    Exception
        When others then l_OTPLength := 6;
        plog.error(pkgctx, 'Not found OTPPASSLENG in SYSVAR. Error:' ||SQLERRM|| dbms_utility.format_error_backtrace);
    End;

    Begin
        SELECT TO_NUMBER(VARVALUE) INTO l_OTPTimeOut FROM SYSVAR WHERE VARNAME = 'OTPPASSTIMEOUT' AND GRNAME='SYSTEM';
    Exception
        When others then l_OTPTimeOut := 5; --> Mac dinh 5P
        plog.error(pkgctx, 'Not found OTPPASSTIMEOUT in SYSVAR. Error:' ||SQLERRM|| dbms_utility.format_error_backtrace);
    End;

    Begin
        select varvalue into v_shortname from sysvar where varname='COMPANYSHORTNAME' AND GRNAME='SYSTEM';
    Exception
        When others then v_shortname:='BMSC';
        plog.error(pkgctx, 'Not found COMPANYSHORTNAME in SYSVAR. Error:' ||SQLERRM|| dbms_utility.format_error_backtrace);
    End;

    -- Gen OTP
    SELECT LOWER(fopks_ekycapi.fn_random_num(l_OTPLength)) INTO l_OTPValue FROM DUAL;
    -- Encrypt OTP
    SELECT genencryptpassword(l_OTPValue) INTO l_OTPEncrypt FROM DUAL;

    --IF p_via= C_VIA_ONLINE THEN
        --l_ViaDesc:=' Online Trading. ';
    --ELSIF p_via= C_VIA_MOBILE THEN
        --l_ViaDesc:=' Mobile Trading. ';
    --END IF;

    If p_language = C_LANG_VI then
        --l_DataContent := '''' || v_shortname||'-TB: Quy khach dang thuc hien mo tai khoan truc tuyen tren '|| l_ViaDesc || ', OTP la  '||l_OTPValue||' hieu luc trong ' || l_otpTimeOut || ' phut''';
        l_DataContent := v_shortname||'-TB: Quy khach dang thuc hien dang ky mo tai khoan truc tuyen, vui long nhap OTP '||l_OTPValue||' trong ' || l_otpTimeOut || ' phut de xac nhan';
    Else
        l_DataContent := v_shortname||'-Notice: You are open account '|| l_ViaDesc || ', OTP is '||l_OTPValue||' valid in ' || l_otpTimeOut || ' minutes';
    End If;

    l_DataSource:= 'SELECT ''' || l_DataContent || ''' detail from dual';

    UPDATE tblOtplog SET PSTATUS=PSTATUS||STATUS,STATUS='E',lastchange=SYSDATE
    WHERE OTPKEY=UPPER(OTPKEY) and VIA=p_via;

    insert into tblOtplog (autoid,otpkey,otpvalue,via,status,txdate,expdt, retry,maxretry,description,lastchange)
    VALUES(seq_otplog.nextval,l_OtpKey,l_OTPEncrypt,p_via,'P',l_currdate,SYSDATE + l_otpTimeOut/1440,0,C_MAX_RETRY,'OTP for open account',SYSDATE);

    IF( TRIM(l_Mobile) IS NOT NULL) THEN
        Begin
            --nmpks_ems.InsertEmailLog(l_Mobile, '337S', l_DataSource,'');
            insert into emaillog
                (autoid, email, templateid, datasource, status, createtime,
                    afacctno)
            values
                (seq_emaillog.nextval, l_Mobile, '338A', l_DataSource, 'A', sysdate,
                '');
        Exception
            When others then
                plog.error(pkgctx, 'l_Mobile:' || l_Mobile || ',l_DataSource:' || l_DataSource);
        End;
    END IF;

    plog.setEndsection(pkgctx, 'pr_GenOTP');
Exception
    When others then
      plog.error(pkgctx, sqlerrm|| dbms_utility.format_error_backtrace
            ||',p_JSonInput='|| substr(p_JSonInput,1,3000)
            ||',p_via='||p_via
            ||',p_tlid='||p_tlid
            ||',p_objname='||p_objname
            ||',p_language='||p_language);
      plog.setendsection(pkgctx, 'pr_GenOTP');
      p_err_code := errnums.C_SYSTEM_ERROR;
      p_err_param := fn_get_errmsg(p_err_code,p_language);
      raise errnums.E_BIZ_RULE_INVALID;
End;

Procedure pr_VerifyOTP(
        p_JSonInput  Clob,
        p_CFSign  Clob,
        p_via  IN  varchar2,
        p_tlid  IN  varchar2,
        p_language in varchar2 default C_LANG_VI,
        p_objname  in varchar2 default '',
        p_JSonMsgOut out clob,
        p_err_code in out varchar2,
        p_err_param in out varchar2 )
Is
/*
  **    Description: Kiem tra OTP, khi mo tai khoan (eKYC)
  **    Person            Date           Comments
  **    TruongLD          03/03/2021         Created
  **    Input:
        ==> p_JSonInput: '{"otpkey": "<So CMND cua KH>_<ma_KH>","idcode": "<$SoCMND>","regcfmastid": "<$regcfmastid>","otptype": "<$Loai OTP, mac dinh la SMS>","otpvalue":"12345"}'
                         '{"otpkey": "250567964_01","idcode": "250567964","regcfmastid": "01","OTPType": "SMS","otpvalue":"12345"}'
        ==> p_CFSign: Chu ky cua khach hang.
        ==> p_via: Kenh yeu cau
        ==> p_tlid: User yeu cau
        ==> p_language: Ngon ngu dang su dung
        ==> p_objname: Key de check quyen neu can.
  **    Output:
        ==> p_JSonMsgOut: Data can tra ve
            "'{custinfo": {"custodycd": "<$custodycd>"}}'
        ==> p_err_code: Ma loi
        ==> p_err_param: Mo ta loi
*/
    l_count         number(20);
    l_OTPLength     number(20);
    l_OTPTimeOut    number(20);
    v_shortname     varchar2(200);
    l_OTPValue      varchar2(200);
    l_OTPEncrypt    varchar2(500);
    l_currdate      Date;
    l_ViaDesc       varchar2(100);
    l_DataContent    varchar2(3000);
    l_DataSource    varchar2(3000);
    l_strJSonInput  Clob;
    l_JSonData      fss_json;
    l_OtpKey        varchar2(200);
    l_otptype       varchar2(200);
    l_regcfmastid   varchar2(200);
    l_idcode        varchar2(200);
    l_custodycd     varchar2(200);
    l_custid        varchar2(200);
    l_JSonMsgOut    clob;
    l_cfsign        clob;
    l_jsonInput      clob;
    l_fullname      varchar2(200);
    l_idcodeReg     varchar2(200);
    l_mobile        varchar2(200);
    l_email         varchar2(200);
    l_openactype    varchar2(200);
    l_custtype      varchar2(200);
    l_dof           varchar2(200);
    l_brid          varchar2(200);
    l_brokerid      varchar2(200);

Begin
    plog.setBeginsection(pkgctx, 'pr_VerifyOTP');
    p_err_code  := systemnums.C_SUCCESS;
    p_err_param := 'SUCCESS';
    l_currdate  := Getcurrdate;

    l_JSonMsgOut    := '{"custinfo": {"custodycd": "<$custodycd>"}}';

    l_jsonInput    := '{"custodycd":"<$custodycd>","fullname":"<$fullname>",'
                                        ||'"idcode":"<$idcode>","mobile":"<$mobile>","email":"<$email>","openactype":"<$openactype>",'
                                        ||'"custtype":"<$custtype>","dof":"<$dof>","brid":"<$brid>","brokerid":"<$brokerid>"}';

    l_strJSonInput := p_JSonInput;
    Begin
        l_JSonData      := json_parser.parser((l_strJSonInput));
        l_OtpKey        := fn_data_from_json(l_JSonData,'otpkey');
        l_OTPValue      := fn_data_from_json(l_JSonData,'otpvalue');
        l_otptype       := fn_data_from_json(l_JSonData,'otptype');
        l_regcfmastid   := fn_data_from_json(l_JSonData,'regcfmastid');
        l_idcode        := fn_data_from_json(l_JSonData,'idcode');

    Exception
    When others then
        plog.error(pkgctx, 'JSonData invalid '
            ||',p_JSonInput='|| substr(p_JSonInput,1,3000)
            ||',p_via='||p_via
            ||',p_tlid='||p_tlid
            ||',p_objname='||p_objname
            ||',p_language='||p_language);
      plog.setEndsection(pkgctx, 'prc_VerifyBeforeOpenAcct');
      p_err_code := errnums.C_SYSTEM_ERROR;
      p_err_param := fn_get_errmsg(p_err_code,p_language);
      raise errnums.E_BIZ_RULE_INVALID;
    End;

    select substr(l_OtpKey,1,instr(l_OtpKey,'_')-1) into l_idcode from dual;
    select substr(l_OtpKey,instr(l_OtpKey,'_')+1) into l_regcfmastid from dual;
    Begin
        select count(1) into l_count
        from tblOtplog
        where upper(otpkey) = upper(l_OtpKey)
            and otpvalue = genencryptpassword(l_OTPValue)
            and retry <= fopks_ekycapi.C_MAX_RETRY
            and status  =   'P'
            and via=p_via
            and expdt >= sysdate;
    Exception
        When others then
            plog.error(pkgctx, sqlerrm|| dbms_utility.format_error_backtrace
            ||',p_JSonInput='||p_JSonInput
            ||',sysdate='||sysdate
            ||',p_via='||p_via
            ||',p_tlid='||p_tlid
            ||',p_objname='||p_objname
            ||',p_language='||p_language);
            plog.setendsection(pkgctx, 'prc_VerifyOTP');
            p_err_code := C_ERR_OTP_INVALID;
            p_err_param := fn_get_errmsg(p_err_code,p_language);
            raise errnums.E_BIZ_RULE_INVALID;
    End;

    If l_count = 0 then
        plog.error(pkgctx, 'OTP Invalid'
            ||',p_JSonInput='||p_JSonInput
            ||',sysdate='||sysdate
            ||',p_via='||p_via
            ||',p_tlid='||p_tlid
            ||',p_objname='||p_objname
            ||',p_language='||p_language);
            plog.setendsection(pkgctx, 'prc_VerifyOTP');
            p_err_code := C_ERR_OTP_INVALID;
            p_err_param := fn_get_errmsg(p_err_code,p_language);

            update tblOtplog set retry = retry + 1 where upper(otpkey)=upper(l_OtpKey);

            return ;
    Else
        update tblOtplog set pstatus=pstatus||status,status='A',lastchange=sysdate
        where upper(otpkey) = upper(l_OtpKey)
            and otpvalue = genencryptpassword(l_OTPValue)
            and status = 'P'
            and via = p_via;

    End If;

    plog.setEndsection(pkgctx, 'pr_VerifyOTP');
Exception
    When others then
      plog.error(pkgctx, sqlerrm|| dbms_utility.format_error_backtrace
            ||',p_JSonInput='|| substr(p_JSonInput,1,3000)
            ||',p_via='||p_via
            ||',p_tlid='||p_tlid
            ||',p_objname='||p_objname
            ||',p_language='||p_language);
      plog.setendsection(pkgctx, 'pr_VerifyOTP');
      p_err_code := errnums.C_SYSTEM_ERROR;
      p_err_param := fn_get_errmsg(p_err_code,p_language);
      raise errnums.E_BIZ_RULE_INVALID;
End;

Function fn_get_errmsg (p_errnum in varchar2, p_language in varchar2 default C_LANG_VI) return VARCHAR2
Is
    l_errdesc   VARCHAR2(2000);
Begin
    plog.setBeginsection(pkgctx, 'fn_get_errmsg');
    l_errdesc := '';
    for i in
    (
        select errdesc, en_errdesc
        from deferror
        where errnum = p_errnum and rownum=1
    )loop
        l_errdesc   := i.errdesc;
        if p_language <> C_LANG_VI then
            l_errdesc := i.en_errdesc;
        else
            l_errdesc := i.errdesc;
        end if;
    end loop;
    plog.setEndsection(pkgctx, 'fn_get_errmsg');
    return l_errdesc;
Exception when others then
      plog.error(pkgctx, sqlerrm|| dbms_utility.format_error_backtrace
            ||',p_errnum='||p_errnum
            ||',p_language='||p_language);

      plog.setEndsection(pkgctx, 'fn_get_errmsg');
      return 'Loi chua duoc dinh nghia!';
End;

Function fn_random_str(v_length number) return varchar2
Is
    my_str varchar2(4000);
Begin
    for i in 1..v_length loop
        my_str := my_str || dbms_random.string(
            case when dbms_random.value(0, 1) < 0.5 then 'l' else 'x' end, 1);
    end loop;
    return my_str;
End;

Function fn_random_num(v_length number) return varchar2 is
    my_str varchar2(4000);
    begin
    for i in 1..v_length loop
        my_str := my_str || TRUNC(DBMS_RANDOM.value(1,9));
    end loop;
    return my_str;
END;

Function fn_data_from_json(p_jSonData fss_json, p_fldname VARCHAR2) return varchar2
Is
    l_ReturnValue varchar2(1000);
Begin
    Begin
        plog.setBeginsection(pkgctx, 'fn_data_from_json');
        l_ReturnValue       := trim(json_ext.get_string(p_jSonData, p_fldname, 1));
        plog.setEndsection(pkgctx, 'fn_data_from_json');
        Return l_ReturnValue;
    Exception When others then
        plog.error(pkgctx, 'Can not found ' || p_fldname || ' from Json' || sqlerrm|| dbms_utility.format_error_backtrace);
        l_ReturnValue := null;
        plog.setEndsection(pkgctx, 'fn_data_from_json');
        Return l_ReturnValue;
    End;
End;

Function fn_isStringNotNull(p_fldname VARCHAR2) return BOOLEAN
Is
    l_bldReturn boolean;
Begin
    l_bldReturn:= true;
    If p_fldname is null then
        l_bldReturn := false;
    Elsif LENGTH(p_fldname) = 0 then
        l_bldReturn :=  false;
    End If;
    return l_bldReturn;
End;

--Cap nhat user/password login online
  PROCEDURE pr_register_login (p_custodycd VARCHAR2,
                               p_username VARCHAR2,
                               p_loginpwd VARCHAR2,
                               p_tradingpwd VARCHAR2,
                               p_err_code    OUT varchar2,
                               p_err_message out VARCHAR2)
  IS
  v_count number;
  l_reqid   VARCHAR2(14);
  v_busdate  DATE;
  p_tlid    VARCHAR2(6);
  l_custid  VARCHAR2(10);
  BEGIN
    plog.setBeginSection (pkgctx, 'pr_register_login');
    p_err_code := 0;
    p_err_message := '';

    SELECT to_date(varvalue,systemnums.c_date_format) INTO v_busdate
    FROM sysvar
    WHERE varname = 'CURRDATE' AND grname = 'SYSTEM';
    l_reqid := to_char(v_busdate,'rrrrmmdd')||LPAD (seq_apiopenaccount.NEXTVAL, 6, '0');
    p_tlid := systemnums.C_OPENAPI_USERID;

    insert into APIOpenAccount (REQID, CUSTODYCD, USERNAME, LOGINPWD, TRADINGPWD, APINAME, LASTDATE)
      values (l_reqid, p_custodycd, p_username, p_loginpwd, p_tradingpwd, 'pr_register_login', v_busdate);

    --check stk luu ky
    select count(*) into v_count from cfmast where custodycd = p_custodycd and status <> 'C';
    if v_count = 0 then
      p_err_code:='-200216';
      p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
      UPDATE APIOpenAccount SET ERRNUM = p_err_code, ERRDESC = p_err_message, last_change = CURRENT_TIMESTAMP WHERE REQID = l_reqid;
      plog.error(pkgctx, 'select cfmast.custodycd='||p_custodycd||', reqid='||l_reqid||'. Error:'  || p_err_message);
      plog.setendsection(pkgctx, 'pr_register_login');
      RETURN;
    end if;
    --check ten dang nhap
    select count(*) into v_count from userlogin where username = p_username and status = 'A';
    if v_count <> 0 then
      p_err_code:='-200214';
      p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
      UPDATE APIOpenAccount SET ERRNUM = p_err_code, ERRDESC = p_err_message, last_change = CURRENT_TIMESTAMP WHERE REQID = l_reqid;
      plog.error(pkgctx, 'select cfmast.username='||p_username||', reqid='||l_reqid||'. Error:'  || p_err_message);
      plog.setendsection(pkgctx, 'pr_register_login');
      RETURN;
     end if;

    INSERT INTO userlogin (USERNAME,HANDPHONE,LOGINPWD,TRADINGPWD,AUTHTYPE,STATUS,LOGINSTATUS,LASTCHANGED,NUMBEROFDAY,LASTLOGIN,ISRESET,ISMASTER,TOKENID)
    VALUES(p_username,NULL,genencryptpassword(p_loginpwd),genencryptpassword(p_tradingpwd),'N','A','O',TO_DATE(v_busdate,'DD/MM/RRRR'),30,TO_DATE(v_busdate,'DD/MM/RRRR'),'Y','N',NULL);

    SELECT CUSTID INTO l_custid FROM CFMAST WHERE CUSTODYCD = p_custodycd and status <> 'C';

    UPDATE CFMAST SET USERNAME = p_username WHERE CUSTODYCD = p_custodycd;
    INSERT INTO MAINTAIN_LOG (TABLE_NAME,RECORD_KEY,MAKER_ID,MAKER_DT,APPROVE_RQD,APPROVE_ID,APPROVE_DT,MOD_NUM,COLUMN_NAME,FROM_VALUE,TO_VALUE,ACTION_FLAG,CHILD_TABLE_NAME,CHILD_RECORD_KEY)
    VALUES('CFMAST','CUSTID = ''' || l_custid || '''', p_tlid ,TO_DATE( v_busdate ,'DD/MM/RRRR'),'Y',
     '' ,null,0,'USERNAME','',p_username ,'EDIT',NULL,NULL);

    p_err_code   := 0;
    p_err_message  := 'Successfull';
    plog.setEndSection (pkgctx, 'pr_register_login');
  EXCEPTION
    WHEN OTHERS THEN
      p_err_code := errnums.C_SYSTEM_ERROR;
      p_err_message := 'SYSTEM ERROR';
      plog.error (pkgctx, SQLERRM || ' AT ' || dbms_utility.format_error_backtrace);
      plog.setEndSection (pkgctx, 'pr_register_login');
  END;

  Procedure pr_GetViewOpenAcc
    (p_refcursor in out pkg_report.ref_cursor,
        p_fdate IN varchar2,
        p_tdate IN varchar2,
        p_custodycd in varchar2,
        p_idcode in varchar2,
        p_openactype in varchar2,
        p_status in varchar2,
        p_brid in varchar2,
        p_via  IN  varchar2,
        p_tlid  IN  varchar2,
        p_language in varchar2 default C_LANG_VI,
        p_objname  in varchar2 default ''
    )
Is
/*
  **    Description: Lay thong tin KH mo tk truc tuyen
  **    Person            Date           Comments
  **    TanPN          22/04/2021         Created
  **    Input:
        ==> p_via: Kenh yeu cau
        ==> p_tlid: User yeu cau
        ==> p_language: Ngon ngu dang su dung
        ==> p_objname: Key de check quyen neu can.
 **    Output:
        ==> p_err_code: Ma loi
        ==> p_err_param: Mo ta loi
*/
    l_fdate date;
    l_tdate date;
    l_custodycd varchar2(20);
    l_idcode varchar2(20);
    l_openactype varchar2(20);
    l_status varchar2(20);
    l_mapid  varchar2(500);
    l_brid   varchar2(20);
Begin
    plog.setBeginsection(pkgctx, 'pr_GetViewOpenAcc');

    l_fdate := TO_DATE(p_fdate, SYSTEMNUMS.C_DATE_FORMAT);
    l_tdate := TO_DATE(p_tdate, SYSTEMNUMS.C_DATE_FORMAT);

    If p_custodycd = 'ALL' then
        l_custodycd := '%%';
    else
        l_custodycd := p_custodycd;
    end if;

    If p_idcode = 'ALL' then
        l_idcode := '%%';
    else
        l_idcode := p_idcode;
    end if;

    begin
        select brid into l_brid from tlprofiles where tlid = p_tlid;
    exception
    WHEN OTHERS THEN
        l_brid:= '';
    end;

    If p_custodycd = 'ALL' then
        OPEN p_refcursor for

            select rownum stt, api.custodycd, api.fullname, reg.idcode, reg.mobile MOBILESMS ,BRGRP.BRNAME brid, TO_CHAR(reg.txdate,'dd/MM/RRRR') opndate,
                TO_CHAR(api.txdate,'dd/MM/RRRR') txdate,a3.cdcontent openvia, a1.cdcontent status,a2.cdcontent customertype
            from registeronline reg, apiopenaccount api,BRGRP, allcode a1, allcode a2, allcode a3
            where api.idcode = reg.idcode
                AND reg.BRID = BRGRP.BRID
                and a1.cdtype = 'CF' and a1.cdname = 'STATUS' and a1.cdval = substr(reg.status,1,1)
                and a2.cdtype = 'CF' and a2.cdname = 'TYPEINVESTOR' and a2.cdval = reg.customertype
                and a3.cdtype = 'CF' and a3.cdname = 'OPENVIA' and a3.cdval = reg.acctype
                --and api.custodycd like l_custodycd
                and reg.idcode like l_idcode
                and api.txdate between l_fdate and l_tdate
                and reg.brid like l_brid;
    else
        OPEN p_refcursor for

            select rownum stt, api.custodycd, api.fullname, reg.idcode, reg.mobile MOBILESMS,BRGRP.BRNAME brid, TO_CHAR(reg.txdate,'dd/MM/RRRR') opndate,
                TO_CHAR(api.txdate,'dd/MM/RRRR') txdate,a3.cdcontent openvia, a1.cdcontent status,a2.cdcontent customertype
            from registeronline reg, apiopenaccount api,BRGRP, allcode a1, allcode a2, allcode a3
            where api.idcode = reg.idcode
                AND reg.BRID = BRGRP.BRID
                and a1.cdtype = 'CF' and a1.cdname = 'STATUS' and a1.cdval = substr(reg.status,1,1)
                and a2.cdtype = 'CF' and a2.cdname = 'TYPEINVESTOR' and a2.cdval = reg.customertype
                and a3.cdtype = 'CF' and a3.cdname = 'OPENVIA' and a3.cdval = reg.acctype
                and api.custodycd like l_custodycd
                and reg.idcode like l_idcode
                and api.txdate between l_fdate and l_tdate
                and reg.brid like l_brid;
    end if;

    plog.setEndsection(pkgctx, 'pr_GetViewOpenAcc');
Exception when others then
      plog.error(pkgctx, sqlerrm|| dbms_utility.format_error_backtrace
            ||',p_via='||p_via
            ||',p_tlid='||p_tlid
            ||',p_objname='||p_objname
            ||',p_language='||p_language);
      plog.setEndsection(pkgctx, 'pr_GetViewOpenAcc');
      raise errnums.E_BIZ_RULE_INVALID;
End;

PROCEDURE GenTemplate313E(
        p_fullname      varchar2,
        p_custodycd     varchar2,
        p_orgLoginpwd   varchar2,
        p_orgTradingpwd   varchar2,
        p_email         varchar2
    )
IS
    l_datasource  varchar2(2000);
    p_idcode varchar2(20);
    v_acctno        varchar2(20);
    v_img_footer VARCHAR2(250);

    BEGIN
        plog.setBeginSection(pkgctx, 'GenTemplate313E');

        select varvalue INTO v_img_footer from sysvar where varname='IMG_FOOTER';

        begin
            select max(af.acctno) INTO v_acctno from cfmast cf, afmast af where cf.custid = af.custid and cf.custodycd = p_custodycd;
        exception WHEN OTHERS THEN
             v_acctno := '';
        end;

        begin
            select idcode into p_idcode from cfmast where custodycd=p_custodycd;
        exception WHEN OTHERS THEN
            p_idcode := '';
        end;

        l_datasource := 'select '''||p_fullname||''' fullname, '''
                                ||p_custodycd||''' custodycd, '''
                                ||p_orgLoginpwd||''' loginpwd, '''
                                ||p_orgTradingpwd||''' tradingpwd, '''
                                ||p_idcode||''' PV_IDCODE,'''||v_img_footer||''' sys_logo_footer from dual';

        nmpks_ems.InsertEmailLog(p_email, '313E', l_datasource, v_acctno);

        plog.setEndSection(pkgctx, 'GenTemplate313E');
    EXCEPTION
        WHEN OTHERS THEN
            plog.error(pkgctx, sqlerrm);
            plog.setEndSection(pkgctx, 'GenTemplate313E');
END;

PROCEDURE GenTemplate315E(
        p_fullname      varchar2,
        p_custodycd     varchar2,
        p_mobile        varchar2,
        p_email         varchar2
    )
IS
    l_datasource  varchar2(2000);
    p_idcode varchar2(20);
    v_acctno        varchar2(20);
    p_iddate  varchar2(20);
    p_idplace  varchar2(500);
    p_address  varchar2(500);
    p_emailkh  varchar2(100);
    p_status  varchar2(100);

    BEGIN
        plog.setBeginSection(pkgctx, 'GenTemplate315E');

        begin
            select max(af.acctno) INTO v_acctno from cfmast cf, afmast af where cf.custid = af.custid and cf.custodycd = p_custodycd;
        exception WHEN OTHERS THEN
             v_acctno := '';
        end;

        begin
            select cf.idcode, cf.iddate, cf.idplace,cf.address, cf.email, a1.cdcontent status
            into p_idcode, p_iddate, p_idplace, p_address, p_emailkh, p_status
            from cfmast cf, allcode a1
            where cf.custodycd = p_custodycd
                and a1.cdtype = 'CF' and a1.cdname = 'STATUS_EMAIL' and a1.cdval = cf.status;
        exception WHEN OTHERS THEN
            p_idcode := '';
            p_iddate := '';
            p_idplace := '';
            p_address := '';
            p_emailkh := '';
            p_status := '';
        end;

        l_datasource := 'select '''||p_fullname||''' fullname, '''
                                ||p_custodycd||''' custodycd, '''
                                ||p_iddate||''' iddate, '''
                                ||p_idplace||''' idplace, '''
                                ||p_address||''' address, '''
                                ||p_mobile||''' mobile, '''
                                ||p_emailkh||''' email, '''
                                ||p_status||''' status, '''
                                ||p_idcode||''' PV_IDCODE from dual';

        nmpks_ems.InsertEmailLog(p_email, '315E', l_datasource, v_acctno);

        plog.setEndSection(pkgctx, 'GenTemplate315E');
    EXCEPTION
        WHEN OTHERS THEN
            plog.error(pkgctx, sqlerrm);
            plog.setEndSection(pkgctx, 'GenTemplate315E');
END;

Procedure pr_VerifyTLID(
        p_JSonInput  Clob,
        p_err_code in out varchar2,
        p_err_param in out varchar2 )
Is
    l_count         number(20);
    l_tlid          varchar2(4);
    l_tlname        varchar2(50);
    l_pin          varchar2(100);

    l_OTPLength     number(20);
    l_OTPTimeOut    number(20);
    v_shortname     varchar2(200);
    l_OTPValue      varchar2(200);
    l_OTPEncrypt    varchar2(500);
    l_currdate      Date;
    l_ViaDesc       varchar2(100);
    l_DataContent    varchar2(3000);
    l_DataSource    varchar2(3000);
    l_strJSonInput  Clob;
    l_JSonData      fss_json;
    l_OtpKey        varchar2(200);
    l_otptype       varchar2(200);
    l_regcfmastid   varchar2(200);
    l_idcode        varchar2(200);
    l_custodycd     varchar2(200);
    l_custid        varchar2(200);
    l_JSonMsgOut    clob;
    l_cfsign        clob;
    l_jsonInput      clob;
    l_fullname      varchar2(200);
    l_idcodeReg     varchar2(200);
    l_mobile        varchar2(200);
    l_email         varchar2(200);
    l_openactype    varchar2(200);
    l_custtype      varchar2(200);
    l_dof           varchar2(200);

    l_brokerid      varchar2(200);

Begin
    plog.setBeginsection(pkgctx, 'pr_VerifyTLID');
    p_err_code  := systemnums.C_SUCCESS;
    p_err_param := 'SUCCESS';
    l_currdate  := Getcurrdate;

    l_strJSonInput := p_JSonInput;
    Begin
        l_JSonData      := json_parser.parser((l_strJSonInput));
        l_tlname        := fn_data_from_json(l_JSonData,'tlname');
        l_pin      := fn_data_from_json(l_JSonData,'tlpin');

    Exception
    When others then
        plog.error(pkgctx, 'JSonData invalid '
            ||',p_JSonInput='|| substr(p_JSonInput,1,3000)
           );
      plog.setEndsection(pkgctx, 'pr_VerifyTLID');
      p_err_code := errnums.C_SYSTEM_ERROR;
      p_err_param := fn_get_errmsg(p_err_code);
      raise errnums.E_BIZ_RULE_INVALID;
    End;

    select substr(l_OtpKey,1,instr(l_OtpKey,'_')-1) into l_idcode from dual;
    select substr(l_OtpKey,instr(l_OtpKey,'_')+1) into l_regcfmastid from dual;
    Begin
        select count(1) into l_count
        from tlprofiles
        where upper(tlname) = upper(l_tlname);

    Exception
        When others then
            plog.error(pkgctx, sqlerrm|| dbms_utility.format_error_backtrace
            ||',p_JSonInput='||p_JSonInput
            ||',sysdate='||sysdate);
            plog.setendsection(pkgctx, 'pr_VerifyTLID');
            p_err_code := C_ERR_TLNAME_INVALID;
            p_err_param := fn_get_errmsg(p_err_code);
            raise errnums.E_BIZ_RULE_INVALID;
    End;

    If l_count = 0 then
        plog.error(pkgctx, 'TLID Invalid'
            ||',p_JSonInput='||p_JSonInput
            ||',sysdate='||sysdate      );
            plog.setendsection(pkgctx, 'pr_VerifyTLID');
            p_err_code := C_ERR_TLNAME_INVALID;
            p_err_param := fn_get_errmsg(p_err_code);

            plog.setEndsection(pkgctx, 'pr_VerifyTLID');
            return ;
    Else
               Begin
                select count(1) into l_count
                from tlprofiles
                where upper(tlname) = upper(l_tlname)
                    and pin=genencryptpassword(l_pin);

            Exception
                When others then
                    plog.error(pkgctx, sqlerrm|| dbms_utility.format_error_backtrace
                    ||',p_JSonInput='||p_JSonInput
                    ||',sysdate='||sysdate);
                    plog.setendsection(pkgctx, 'pr_VerifyTLID');
                    p_err_code := C_ERR_PIN_INVALID;
                    p_err_param := fn_get_errmsg(p_err_code);
                    raise errnums.E_BIZ_RULE_INVALID;
            End;
           If l_count = 0 then
            plog.error(pkgctx, 'TLID Invalid'
                ||',p_JSonInput='||p_JSonInput
                ||',sysdate='||sysdate      );
                plog.setendsection(pkgctx, 'pr_VerifyTLID');
                p_err_code := C_ERR_PIN_INVALID;
                p_err_param := fn_get_errmsg(p_err_code);

                plog.setEndsection(pkgctx, 'pr_VerifyTLID');
                return ;
            else
                select tlid into p_err_param
                from tlprofiles
                where upper(tlname) = upper(l_tlname)
                    and pin=genencryptpassword(l_pin);
            End If;
    End If;
    -- neu thanh cong,

    plog.setEndsection(pkgctx, 'pr_VerifyTLID');
Exception
    When others then
      plog.error(pkgctx, sqlerrm|| dbms_utility.format_error_backtrace
            ||',p_JSonInput='|| substr(p_JSonInput,1,3000)       );
      plog.setendsection(pkgctx, 'pr_VerifyTLID');
      p_err_code := errnums.C_SYSTEM_ERROR;
      p_err_param := fn_get_errmsg(p_err_code);
      raise errnums.E_BIZ_RULE_INVALID;
End;
  procedure pr_Maintainlog(
    p_strSQL IN VARCHAR2,
    p_ObjectName IN VARCHAR2,
    p_RecordKey IN VARCHAR2,
    p_RecordValue IN VARCHAR2,
    p_ChildObjectName IN VARCHAR2,
    p_ChildRecordKey IN VARCHAR2,
    p_ChildRecordValue IN VARCHAR2,
    p_makerid  IN VARCHAR2,
    p_makerdt  IN VARCHAR2  default '',
    p_checkerid  IN VARCHAR2 default ''
)
IS
l_fldval            varchar2(1000);
l_count             NUMBER;
l_refcursor         pkg_report.ref_cursor;
v_desc_tab          dbms_sql.desc_tab;
v_cursor_number     NUMBER;
v_columns           NUMBER;
v_number_value      NUMBER;
v_varchar_value     VARCHAR(200);
v_date_value        DATE;
l_fldname           varchar2(100);
v_logSQL            varchar2(3000);
v_strObjectName     varchar2(1000);
v_strRecordKey      varchar2(1000);
v_strChildObjName   varchar2(1000);
v_strChildRecordKey varchar2(1000);
l_tlid              varchar2(1000) := p_makerid;
l_currdate          date;
l_modNum            NUMBER;
l_makerdt           varchar2(40);
l_strCurrdate       varchar2(40);
BEGIN
    plog.setBeginsection(pkgctx, 'prc_maintainlog');
    --l_modNum    := 0;
    l_currdate  := getcurrdate;
    l_strCurrdate := to_char(l_currdate,'DD/MM/RRRR');
    l_makerdt   := nvl(p_makerdt,l_strCurrdate);

    v_strObjectName     := p_ObjectName;
    v_strRecordKey      := p_RecordKey || ' = ''''' || p_RecordValue || '''''';

    if fn_isstringnotnull(p_ChildObjectName) then
        v_strChildObjName   := p_ChildObjectName;
        v_strChildRecordKey := p_ChildRecordKey || ' = ''''' || p_ChildRecordValue || '''''';
    else
        v_strChildObjName := '';
        v_strChildRecordKey := '';
    End If;

    begin
        select max(MOD_NUM+1) into l_modNum from maintain_log where TABLE_NAME = v_strObjectName and RECORD_KEY = v_strRecordKey;
      EXCEPTION WHEN OTHERS THEN
        l_modNum    := 0;
    end;
    l_modNum := nvl(l_modNum,0);

    OPEN l_refcursor FOR p_strSQL;
    v_cursor_number := dbms_sql.to_cursor_number(l_refcursor);
    dbms_sql.describe_columns(v_cursor_number, v_columns, v_desc_tab);
    --define colums
    FOR i IN 1 .. v_desc_tab.COUNT LOOP
            IF v_desc_tab(i).col_type = dbms_types.typecode_number THEN
            --Number
                dbms_sql.define_column(v_cursor_number, i, v_number_value);
            ELSIF v_desc_tab(i).col_type = dbms_types.typecode_varchar
                OR  v_desc_tab(i).col_type = dbms_types.typecode_char THEN
            --Varchar, char
                dbms_sql.define_column(v_cursor_number, i, v_varchar_value,200);
            ELSIF v_desc_tab(i).col_type = dbms_types.typecode_date THEN
            --Date,
               dbms_sql.define_column(v_cursor_number, i, v_date_value);
            END IF;
    END LOOP;
    WHILE dbms_sql.fetch_rows(v_cursor_number) > 0 LOOP
        FOR i IN 1 .. v_desc_tab.COUNT LOOP
              v_logSQL  := '';
              l_fldname :=  upper(v_desc_tab(i).col_name);
              --l_modNum  := i;
              IF v_desc_tab(i).col_type = dbms_types.typecode_number THEN
                   dbms_sql.column_value(v_cursor_number, i, v_number_value);
                   l_fldval := to_char(v_number_value);
              ELSIF  v_desc_tab(i).col_type = dbms_types.typecode_varchar
                OR  v_desc_tab(i).col_type = dbms_types.typecode_char
                THEN
                   dbms_sql.column_value(v_cursor_number, i, v_varchar_value);
                   l_fldval := v_varchar_value;
              ELSIF v_desc_tab(i).col_type = dbms_types.typecode_date THEN
                   dbms_sql.column_value(v_cursor_number, i, v_date_value);
                   l_fldval:=to_char(v_date_value,'DD/MM/RRRR');
              END IF;

              if not fn_isstringnotnull(l_fldval) then
                continue;
              end if;

              v_logSQL := v_logSQL || ' INSERT INTO MAINTAIN_LOG(TABLE_NAME, RECORD_KEY,'
                            ||' MAKER_ID, MAKER_DT, APPROVE_RQD, APPROVE_ID, APPROVE_DT, COLUMN_NAME,'
                            ||' FROM_VALUE, TO_VALUE, MOD_NUM, ACTION_FLAG, CHILD_TABLE_NAME,'
                            ||' CHILD_RECORD_KEY, MAKER_TIME) VALUES';
              v_logSQL := v_logSQL || ' ('''|| v_strObjectName || ''',''' || v_strRecordKey || ''','''
                            || p_makerid || ''',to_date('''|| p_makerdt ||''',''DD/MM/RRRR''), ''Y'|| ''','''|| p_checkerid || ''',to_date('''|| l_strCurrdate||''',''DD/MM/RRRR'')';
              v_logSQL := v_logSQL || ',''' || l_fldname || ''',''' ||''
                            || ''',''' ||to_char( l_fldval) || ''',' || TO_CHAR( l_modNum) || ', ''ADD'','''
                            || v_strChildObjName ||''', ''' || v_strChildRecordKey || ''','''|| TO_CHAR( SYSTIMESTAMP,'HH:MI:SS') ||''')';

              dbms_output.put_line('v_logSQL:' || v_logSQL);
              Begin
                execute immediate v_logSQL;
              Exception when others then
                plog.error(pkgctx, 'SQL:' || v_logSQL || ',' || sqlerrm|| dbms_utility.format_error_backtrace);
                plog.setEndsection(pkgctx, 'prc_maintainlog');
                continue;
              End;

        END LOOP;
    END LOOP;

    plog.setEndsection(pkgctx, 'prc_maintainlog');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm|| dbms_utility.format_error_backtrace);
    plog.setEndsection(pkgctx, 'prc_maintainlog');
    raise errnums.E_BIZ_RULE_INVALID;
END;
---------------------------------End----------------------------------------
begin
  -- Initialization
  for i in (select * from tlogdebug) loop
    logrow.loglevel  := i.loglevel;
    logrow.log4table := i.log4table;
    logrow.log4alert := i.log4alert;
    logrow.log4trace := i.log4trace;
  end loop;

  pkgctx := plog.init('fopks_Ekycapi', plevel => nvl(logrow.loglevel, 30),
                      plogtable => (nvl(logrow.log4table, 'N') = 'Y'),
                      palert => (nvl(logrow.log4alert, 'N') = 'Y'),
                      ptrace => (nvl(logrow.log4trace, 'N') = 'Y'));
end fopks_Ekycapi;
/
