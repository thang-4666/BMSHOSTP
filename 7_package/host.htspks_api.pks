SET DEFINE OFF;
CREATE OR REPLACE PACKAGE htspks_api is

  -- Author  : THONG_000
  -- Created : 23/09/2013 10:15:49 AM
  -- Purpose : Home API

  -- Public type declarations
  -- type <TypeName> is <Datatype>;

  -- Public constant declarations
  -- <ConstantName> constant <Datatype> := <Value>;

  -- Public variable declarations
  -- <VariableName> <Datatype>;

  -- Public function and procedure declarations
  procedure sp_login(p_login_id in out varchar2, p_username varchar2,
                     p_password varchar2, p_loginsrcip varchar2,
                     p_logindstip varchar2, p_custid in out varchar2,
                     p_role in out varchar2, p_isreset IN OUT VARCHAR2, p_err_code in out varchar2,
                     p_err_message in out varchar2);

  procedure sp_audit_authenticate(p_loginid varchar2, p_userid char,
                                  p_loginsrcip varchar2,
                                  p_logindstip varchar2, p_type char);

  procedure sp_get_account_infor(p_refcursor in out pkg_report.ref_cursor,
                                 p_username varchar2, p_password varchar2,
                                 p_role varchar2);

  procedure sp_get_sub_account(p_refcursor in out pkg_report.ref_cursor,
                               p_custodycode varchar2, p_tlid varchar2,
                               p_role varchar2);

  procedure sp_refesh_orders_by_user(p_refcursor in out pkg_report.ref_cursor,
                                     p_tlname in varchar2, p_scn in varchar2,
                                     p_role in varchar2 default 'B');

  procedure sp_get_orders_by_user(p_refcursor in out pkg_report.ref_cursor,
                                  p_tlname in varchar2,
                                  p_rowperpage in number, p_page in number,
                                  p_role in varchar2 default 'B');

  procedure sp_get_orders_by_user_careby(p_refcursor in out pkg_report.ref_cursor,
                                         p_tlname in varchar2,
                                         p_numday in number,
                                         p_rowperpage in number,
                                         p_page in number,
                                         p_role in varchar2 default 'B');

  procedure sp_refesh_orders_careby(p_refcursor in out pkg_report.ref_cursor,
                                    p_tlname in varchar2, p_numday in number,
                                    p_scn in varchar2,
                                    p_role in varchar2 default 'B');

  procedure sp_get_time(p_tran_type in varchar2, p_err_code in out varchar2,
                        p_err_message in out varchar2);

  function fn_to_date(p_char_literal in varchar2, p_date_format in varchar2)
    return date;

  function fn_is_module_permission(p_module varchar2,
                                   p_permission_index number,
                                   p_custid varchar2, p_afacctno varchar2)
    return boolean;

  function fn_validation_type(p_module varchar2, p_custid varchar2)
    return varchar2;

  procedure sp_get_ot_rights(p_refcursor in out pkg_report.ref_cursor,
                             p_custid in varchar2);

  procedure sp_get_careby_by_name(p_refcursor in out pkg_report.ref_cursor,
                                  p_username in varchar2,
                                  p_afacctno in varchar2,
                                  p_role in varchar2);
  procedure sp_get_order_by_careby(p_refcursor in out pkg_report.ref_cursor,
                                   p_txdate in varchar2,
                                   p_tlid in varchar2,
                                   p_custodycd in varchar2,
                                   p_afacctno in varchar2,
                                   p_exectype in varchar2,
                                   p_symbol in varchar2);
  procedure sp_get_active_order_by_careby(p_refcursor in out pkg_report.ref_cursor,
                                   p_txdate in varchar2,
                                   p_tlid in varchar2,
                                   p_custodycd in varchar2,
                                   p_afacctno in varchar2,
                                   p_exectype in varchar2,
                                   p_symbol in varchar2);
  procedure sp_get_refresh_active_order(p_refcursor in out pkg_report.ref_cursor,
                                   p_txdate in varchar2,
                                   p_tlid in varchar2,
                                   p_custodycd in varchar2,
                                   p_afacctno in varchar2,
                                   p_exectype in varchar2,
                                   p_symbol in varchar2,
                                   p_scn in varchar2);
   procedure sp_loginToken(p_login_id in out varchar2, p_username varchar2,
                     p_password varchar2, p_loginsrcip varchar2,
                     p_logindstip varchar2, p_custid in out varchar2,
                     p_role in out varchar2, p_isreset in out varchar2,
                     p_err_code in out varchar2,
                     p_err_message in out varchar2);
end htspks_api;
 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY htspks_api is

  -- Private type declarations

  -- Private constant declarations
  c_fo_login  constant char := 'I';
  c_fo_logout constant char := 'O';

  c_auth_by_pass_index  constant int := 5;
  c_auth_by_token_index constant int := 5;

  --c_fo_log    constant char := 'L';
  c_fo_default               constant number := 0;
  c_fo_time_over             constant number := -111;
  c_fo_user_does_not_existed constant number := -107;
  --c_fo_no_contract_in_list     constant number := -108;
  c_fo_customer_status_invalid constant number := -109;
  c_fo_user_convert_password   constant number := -110;
  c_fo_user_invalid_date       constant number := -101;

  -- Private variable declarations
  pkgctx plog.log_ctx;
  logrow tlogdebug%rowtype;

  -- Function and procedure implementations
  procedure sp_login(p_login_id in out varchar2, p_username varchar2,
                     p_password varchar2, p_loginsrcip varchar2,
                     p_logindstip varchar2, p_custid in out varchar2,
                     p_role in out varchar2,p_isreset IN OUT VARCHAR2, p_err_code in out varchar2,
                     p_err_message in out varchar2) as
    l_userid             varchar2(10);
    l_username           varchar2(50);
    l_fullname           varchar2(50);
    l_brid               char(4);
    l_customer_id        char(10);
    l_tokenid            varchar2(25);
    l_current_date       varchar2(25);
    l_login_time         varchar2(25);
    l_roles              char(1);
    l_isreset            char(1);
    l_status             char(1);
    l_customer_status    char(1);
    l_sub_account_status char(1);
    p_refcursor          pkg_report.ref_cursor;
    l_password           userlogin.loginpwd%type;
    l_sha_password       shauserlogin.password%type;
    l_salt               shauserlogin.salt%type;
    l_login_id           varchar2(50);
  begin

    plog.setbeginsection(pkgctx, 'sp_login');

    p_err_code    := systemnums.c_success;
    p_err_message := '-';
    l_login_id    := p_login_id;

    begin

      select tlid, tlname, tlfullname, brid, tokenid, currdate, logintime,
             role, custid, status, loginpwd, isreset
        into l_userid, l_username, l_fullname, l_brid, l_tokenid,
             l_current_date, l_login_time, l_roles, l_customer_id, l_status,
             l_password, l_isreset
        from (select tlid, tlname, tlfullname, brid, '' tokenid,
                      to_char(getcurrdate, 'DD/MM/RRRR') currdate,
                      to_char(sysdate, 'DD/MM/RRRR') || ' ' ||
                       fopks_api.fn_get_hose_time logintime, 'B' role,
                      '' custid, active status, tl.pin loginpwd, 'N' isreset
                 from tlprofiles tl
                where tl.tlname = p_username
               --and tl.pin = p_password
               union all
               select u.username tlid, c.username tlname,
                      c.fullname tlfullname, brid,
                      '{BSC{' || u.authtype || '{' || u.tokenid || '}}}' tokenid,
                      to_char(getcurrdate, 'DD/MM/RRRR') currdate,
                      to_char(sysdate, 'DD/MM/RRRR') || ' ' ||
                       fopks_api.fn_get_hose_time logintime, 'C' role,
                      c.custid, u.status, u.loginpwd, u.isreset
                 from userlogin u, cfmast c
                where u.username = c.username
                  and u.status = 'A'
                  and u.username = p_username);
      --and u.loginpwd = p_password);

      --plog.error(pkgctx, 'l_login_id::' || l_login_id);
      if (l_password is null and p_login_id is null) then

        select su.salt, su.password
          into l_salt, l_sha_password
          from shauserlogin su
         where su.username = p_username
           and su.ischeck = 'N';

        p_err_code := c_fo_user_convert_password;
        p_custid   := l_salt || ',' || l_sha_password;

        raise errnums.e_biz_rule_invalid;
      else
        if (p_login_id = 'true') then

          update userlogin
             set loginpwd = p_password
           where username = p_username;
          update shauserlogin
             set ischeck = 'Y'
           where username = p_username;
          commit;

        elsif (l_password <> p_password) then
          p_err_code := c_fo_user_does_not_existed;
          raise errnums.e_biz_rule_invalid;
        end if;
      end if;

      if nvl(l_roles, 'X') = 'B' then
        if nvl(l_status, 'X') <> 'Y' then
          p_err_code := c_fo_customer_status_invalid;
          raise errnums.e_biz_rule_invalid;
        end if;
      else
        if nvl(l_status, 'X') <> 'A' then
          p_err_code := c_fo_customer_status_invalid;
          raise errnums.e_biz_rule_invalid;
        end if;

        --Kiem tra trang thai khach hang, tieu khoan
        begin
          select status
            into l_customer_status
            from cfmast
           where custid = l_customer_id;

          if nvl(l_customer_status, 'X') <> 'A' then
            p_err_code := c_fo_customer_status_invalid;
            raise errnums.e_biz_rule_invalid;
          end if;

          /*--Kiem tra trang thai tieu khoan
          open p_refcursor for
            select status from afmast where custid = l_customer_id;

          loop
            fetch p_refcursor
              into l_sub_account_status;
            exit when p_refcursor%notfound;

            exit when nvl(l_sub_account_status, 'X') = 'A';

          end loop;

          if nvl(l_sub_account_status, 'X') <> 'A' then
            p_err_code := c_fo_customer_status_invalid;
            raise errnums.e_biz_rule_invalid;
          end if;*/

        end;

      end if;

    exception
      when no_data_found then
        p_err_code := c_fo_user_does_not_existed;
        raise errnums.e_biz_rule_invalid;
    end;

    p_login_id := sys_guid();
    p_role     := l_roles;
    p_custid   := l_customer_id;
    p_isreset  := l_isreset;

    sp_audit_authenticate(p_login_id,
                          p_username,
                          p_loginsrcip,
                          p_logindstip,
                          c_fo_login);

    /*    open p_refcursor for
    select l_userid, l_username, l_fullname, l_brid, l_tokenid,
           l_current_date, l_login_time, l_roles, l_status
      from dual;*/

    plog.setendsection(pkgctx, 'sp_login');
  exception
    when errnums.e_biz_rule_invalid then
      p_err_message := cspks_system.fn_get_errmsg(p_errnum => p_err_code);
      plog.error(pkgctx, p_err_message);
      --plog.error(pkgctx, sqlerrm);
      plog.setendsection(pkgctx, 'sp_login');
    when others then
      p_err_code    := errnums.c_system_error;
      p_err_message := cspks_system.fn_get_errmsg(p_errnum => p_err_code);
      plog.error(pkgctx, sqlerrm);
      plog.setendsection(pkgctx, 'sp_login');
  end;

  -- Get account information
  procedure sp_get_account_infor(p_refcursor in out pkg_report.ref_cursor,
                                 p_username varchar2, p_password varchar2,
                                 p_role varchar2) as
    l_roles char(1);
  begin

    plog.setbeginsection(pkgctx, 'sp_get_account_infor');

    l_roles := p_role;

    -- Nhom moi gioi 999 la nhom cho dai ly, diem ho tro
    -- usertype = 'A' diem ho tro, dai ly
    if nvl(l_roles, 'X') = 'B' then
      open p_refcursor for
        select tlid, tlname,'' username, tlfullname, brid, '' tokenid,
               to_char(getcurrdate, 'DD/MM/RRRR') currdate,
               to_char(sysdate, 'DD/MM/RRRR')|| ' ' || fopks_api.fn_get_hose_time logintime,
               '' custid, decode(tlgroup, '999', 'A', 'N') usertype, homeorder
          from tlprofiles tl
         where tl.active = 'Y'
           and tl.tlname = p_username;
           --and tl.pin = p_password;
    elsif nvl(l_roles, 'X') = 'C' then
      open p_refcursor for
        select '%%' tlid, c.custodycd tlname,u.username username, c.fullname tlfullname, brid,
               '{BMSC{SMS{'|| C.MOBILESMS ||'}}}' tokenid, to_char(getcurrdate, 'DD/MM/RRRR') currdate,
               to_char(sysdate, 'DD/MM/RRRR')|| ' ' || fopks_api.fn_get_hose_time logintime,
               c.custid, 'C' usertype, 'Y' homeorder
          from userlogin u, cfmast c
         where u.username = c.username
           and u.status = 'A'
           and u.username = p_username;
           --and u.loginpwd = p_password;
    end if;

    plog.setendsection(pkgctx, 'sp_get_account_infor');
  exception
    when others then
      plog.error(pkgctx, sqlerrm);
      plog.setendsection(pkgctx, 'sp_get_account_infor');
  end;

  procedure sp_get_sub_account(p_refcursor in out pkg_report.ref_cursor,
                               p_custodycode varchar2, p_tlid varchar2,
                               p_role varchar2) as
    l_roles char(1);
  begin

    plog.setbeginsection(pkgctx, 'sp_get_sub_account');

    l_roles := p_role;

    if nvl(l_roles, 'X') = 'B' then
      open p_refcursor for
         SELECT A.*, ROWNUM LSTODR
  FROM (SELECT A.ACCTNO CDVAL,
               A1.CDCONTENT|| '.' || C.CUSTODYCD || '.' || C.FULLNAME CDCONTENT,
               TRADETELEPHONE,
               A1.CDCONTENT|| '.' || c.CUSTODYCD || '.' || C.FULLNAME FULLNAME,
               CASE
                 WHEN A.COREBANK = 'Y' OR A.ALTERNATEACCT = 'Y' THEN
                  'Y'
                 ELSE
                  'N'
               END ISCOREBANK,
               C.FULLNAME CUSTOMERNAME,
               A.BANKACCTNO,
               A.BANKNAME,
               C.CUSTODYCD,
               T.PRODUCTTYPE
          FROM AFMAST A, CFMAST C, AFTYPE T, ALLCODE A1
         WHERE A.CUSTID = C.CUSTID
           AND A.ACTYPE = T.ACTYPE
           AND CUSTODYCD = UPPER(p_custodycode)
           AND A.STATUS IN ('A', 'P')
           AND A.ISFIXACCOUNT = 'N'
            and a1.cdtype = 'CF' and a1.cdname = 'PRODUCTTYPE' and A1.CDVAL = T.PRODUCTTYPE
           AND A.CAREBY IN
               (SELECT GRPID FROM TLGRPUSERS WHERE TLID LIKE p_tlid)
           and C.custid not in (SELECT custid FROM UNREAFLNK where status = 'A' and tlid like p_tlid)
        ) A;
    elsif nvl(l_roles, 'X') = 'C' then
      open p_refcursor for
        SELECT A.*, ROWNUM LSTODR
  FROM (SELECT A.ACCTNO CDVAL,
              A1.CDCONTENT|| '.' || C.CUSTODYCD || '.' || C.FULLNAME   CDCONTENT,
               TRADETELEPHONE,
              A1.CDCONTENT|| '.' || C.CUSTODYCD || '.' || C.FULLNAME  FULLNAME,
               CASE
                 WHEN A.COREBANK = 'Y' OR A.ALTERNATEACCT = 'Y' THEN
                  'Y'
                 ELSE
                  'N'
               END ISCOREBANK,
               C.FULLNAME CUSTOMERNAME,
               A.BANKACCTNO,
               A.BANKNAME,
               C.CUSTODYCD,
               T.PRODUCTTYPE
          FROM AFMAST A, CFMAST C, AFTYPE T, ALLCODE A1
         WHERE A.CUSTID = C.CUSTID
           AND A.ACTYPE = T.ACTYPE
           AND CUSTODYCD = UPPER(p_custodycode)
           AND A.STATUS IN ('A', 'P')
           AND A.ISFIXACCOUNT = 'N'
            and a1.cdtype = 'CF' and a1.cdname = 'PRODUCTTYPE' and A1.CDVAL = T.PRODUCTTYPE
           AND A.CAREBY IN
               (SELECT GRPID FROM TLGRPUSERS WHERE TLID LIKE p_tlid)
           UNION
         SELECT A1.ACCTNO CDVAL,
               A2.CDCONTENT|| '.' || C.CUSTODYCD || '.' || C.FULLNAME   CDCONTENT,
               C1.TRADETELEPHONE,
               A2.CDCONTENT|| '.' || C.CUSTODYCD || '.' || C.FULLNAME  FULLNAME,
               CASE
                 WHEN A.COREBANK = 'Y' OR A.ALTERNATEACCT = 'Y' THEN
                  'Y'
                 ELSE
                  'N'
               END ISCOREBANK,
               C1.FULLNAME CUSTOMERNAME,
               A.BANKACCTNO,
               A.BANKNAME,
               C1.CUSTODYCD,
               T.PRODUCTTYPE
          FROM AFMAST A, CFMAST C, AFTYPE T,otright O, AFMAST A1, CFMAST C1, ALLCODE A2
          WHERE A.CUSTID = C.CUSTID
           --AND A.ACTYPE = T.ACTYPE
           AND A1.actype = t.actype
           --AND C.CUSTODYCD = AFK.CUSTODYCD
           --AND A.ACCTNO = A1.ACCTNO
           AND a.custid = o.authcustid
           AND a1.custid = o.cfcustid
           AND o.cfcustid = c1.custid
           AND o.valdate <= getcurrdate
           AND o.expdate >= getcurrdate
           AND C.CUSTODYCD = UPPER(p_custodycode)
           AND A.STATUS IN ('A', 'P')
           AND A.ISFIXACCOUNT = 'N'
            and a2.cdtype = 'CF' and a2.cdname = 'PRODUCTTYPE' and A2.CDVAL = T.PRODUCTTYPE
          ) A;
    end if;

    plog.setendsection(pkgctx, 'sp_get_sub_account');
  exception
    when others then
      plog.error(pkgctx, sqlerrm);
      plog.setendsection(pkgctx, 'sp_get_sub_account');
  end;

  -- Logout function
  procedure fn_logout(p_login_id varchar2, p_err_code in out varchar2,
                      p_err_param out varchar2) as
    l_err_desc varchar2(1000);
  begin
    plog.setbeginsection(pkgctx, 'fn_logout');
    -- TO DO
    p_err_code := systemnums.c_success;
    sp_audit_authenticate(p_login_id, '', '', '', c_fo_logout);

    begin
      select errdesc
        into l_err_desc
        from deferror
       where errnum = p_err_code;
      p_err_param := l_err_desc;
    exception
      when no_data_found then
        p_err_param := 'Ma loi chua duoc dinh nghia.';
    end;

  exception
    when others then
      p_err_code := errnums.c_system_error;
      select errdesc
        into l_err_desc
        from deferror
       where errnum = p_err_code;
      plog.error(pkgctx, sqlerrm);
      plog.setendsection(pkgctx, 'fn_logout');
  end;

  -- Audit login/ logout
  procedure sp_audit_authenticate(p_loginid varchar2, p_userid char,
                                  p_loginsrcip varchar2,
                                  p_logindstip varchar2, p_type char) as
    --l_text varchar2(200);
  begin
    plog.setbeginsection(pkgctx, 'sp_audit_authenticate');

    --Ghi log xu ly
    if nvl(p_type, 'X') = c_fo_login then
      --Login
      insert into loginhist
        (loginid, userid, logintime, loginsrcip, logindstip)
      values
        (p_loginid, p_userid, sysdate, p_loginsrcip, p_logindstip);
    elsif nvl(p_type, 'X') = c_fo_logout then
      --Logout
      update loginhist
         set logouttime = sysdate
       where loginhist.loginid = p_loginid;
    end if;

    plog.setendsection(pkgctx, 'sp_audit_authenticate');
    commit;
  exception
    when others then
      plog.error(pkgctx, sqlerrm);
      plog.setendsection(pkgctx, 'sp_audit_authenticate');
  end;

  -- Get orders all list
  procedure sp_get_orders_by_user(p_refcursor in out pkg_report.ref_cursor,
                                  p_tlname in varchar2,
                                  p_rowperpage in number, p_page in number,
                                  p_role in varchar2 default 'B') is
    l_page         number;
    l_current_date date;
  begin

    l_page := p_page + 1;

    begin
      select sbdate
        into l_current_date
        from sbcurrdate
       where numday = 0
         and sbtype = 'N';
    exception
      when no_data_found then
        l_current_date := getcurrdate;
    end;

    if nvl(p_role, 'X') = 'B' then

      open p_refcursor for
        select *
          from (select a.*, rownum r
                   from (select decode(matchtypevalue,
                                         'P',
                                         exectype || matchtypevalue,
                                         exectype) exectype, pricetype,
                                 custodycd, afacctno, symbol, orderqtty,
                                 quoteprice * 1000 quoteprice, execqtty,
                                 case
                                   when execqtty > 0 and cancelqtty = 0 and
                                        adjustqtty = 0 then
                                    orstatus || ' ' || execqtty || '/' ||
                                    orderqtty
                                   when cancelqtty > 0 and adjustqtty = 0 then
                                    orstatus || ' ' || cancelqtty || '/' ||
                                    orderqtty
                                   when adjustqtty > 0 then
                                    orstatus || ' ' || adjustqtty || '/' ||
                                    orderqtty
                                   else
                                    orstatus
                                 end status, orderid, sdtime lastchange,
                                 remainqtty, desc_exectype, cancelqtty,
                                 adjustqtty, tradeplace, iscancel, isadmend,
                                 isdisposal, foacctno,
                                 nvl(limitprice * 1000, 0) limitprice, execamt,
                                 nvl(quoteqtty, 0) quoteqtty,
                                 to_char(odtimestamp,
                                          'RRRR/MM/DD hh24:mi:ss.ff9') odtimestamp,
                                 orstatusvalue, confirmed, orstatus,
                                 decode(tlname, 'USERONLINE', custodycd, tlname) tlname
                            from buf_od_account
                           where tlname = p_tlname
                             and txdate = l_current_date
                           order by orderid desc) a
                  where rownum <= p_rowperpage * l_page)
         where r > p_rowperpage * (l_page - 1);
    else
      open p_refcursor for
        select *
          from (select a.*, rownum r
                   from (select decode(matchtypevalue,
                                         'P',
                                         exectype || matchtypevalue,
                                         exectype) exectype, pricetype,
                                 custodycd, afacctno, symbol, orderqtty,
                                 quoteprice * 1000 quoteprice, execqtty,
                                 case
                                   when execqtty > 0 and cancelqtty = 0 and
                                        adjustqtty = 0 then
                                    orstatus || ' ' || execqtty || '/' ||
                                    orderqtty
                                   when cancelqtty > 0 and adjustqtty = 0 then
                                    orstatus || ' ' || cancelqtty || '/' ||
                                    orderqtty
                                   when adjustqtty > 0 then
                                    orstatus || ' ' || adjustqtty || '/' ||
                                    orderqtty
                                   else
                                    orstatus
                                 end status, orderid, sdtime lastchange,
                                 remainqtty, desc_exectype, cancelqtty,
                                 adjustqtty, tradeplace, iscancel, isadmend,
                                 isdisposal, foacctno,
                                 nvl(limitprice * 1000, 0) limitprice, execamt,
                                 nvl(quoteqtty, 0) quoteqtty,
                                 to_char(odtimestamp,
                                          'RRRR/MM/DD hh24:mi:ss.ff9') odtimestamp,
                                 orstatusvalue, confirmed, orstatus,
                                 decode(tlname, 'USERONLINE', custodycd, tlname) tlname
                            from buf_od_account
                           where custodycd = p_tlname
                             and txdate = l_current_date
                           order by orderid desc) a
                  where rownum <= p_rowperpage * l_page)
         where r > p_rowperpage * (l_page - 1);
    end if;
  end sp_get_orders_by_user;

  -- Get orders all list by user careby
  procedure sp_get_orders_by_user_careby(p_refcursor in out pkg_report.ref_cursor,
                                         p_tlname in varchar2,
                                         p_numday in number,
                                         p_rowperpage in number,
                                         p_page in number,
                                         p_role in varchar2 default 'B') is
    l_page         number;
    l_current_date date;
  begin

    l_page := p_page + 1;

    begin
      select sbdate
        into l_current_date
        from sbcurrdate
       where numday = p_numday
         and sbtype = 'N';
    exception
      when no_data_found then
        l_current_date := getcurrdate;
    end;

    if nvl(p_role, 'X') = 'B' then

      open p_refcursor for
        select *
          from (select a.*, rownum r
                   from (select txdate, custodycd, afacctno, desc_exectype,
                                 orderid, symbol, iscancel, isadmend,
                                 round(quoteprice * 1000, 15) quoteprice,
                                 execqtty, cancelqtty, adjustqtty, remainqtty,
                                 sdtime lastchange,
                                 decode(matchtypevalue,
                                         'P',
                                         exectype || matchtypevalue,
                                         exectype) exectype, pricetype,
                                 orderqtty, tradeplace, execamt, foacctno,
                                 isdisposal, orstatus, feedbackmsg, rootorderid,
                                 orstatusvalue,
                                 round(nvl(limitprice * 1000, 0), 15) limitprice,
                                 round(nvl(quoteqtty, 0), 15) quoteqtty,
                                 confirmed, via, txtime,
                                 round(case
                                         when execqtty > 0 then
                                          execamt / execqtty
                                         else
                                          0
                                       end,
                                       15) execprice,
                                 case
                                   when execqtty > 0 and cancelqtty = 0 and
                                        adjustqtty = 0 then
                                    orstatus || ' ' || execqtty || '/' ||
                                    orderqtty
                                   when cancelqtty > 0 and adjustqtty = 0 then
                                    orstatus || ' ' || cancelqtty || '/' ||
                                    orderqtty
                                   when adjustqtty > 0 then
                                    orstatus || ' ' || adjustqtty || '/' ||
                                    orderqtty
                                   else
                                    orstatus
                                 end status,
                                 decode(tlname, 'useronline', custodycd, tlname) tlname,
                                 to_char(odtimestamp,
                                          'RRRR/MM/DD hh24:mi:ss.ff9') odtimestamp
                            from buf_od_account
                           where careby in (select grpid
                                              from tlgrpusers
                                             where tlid = p_tlname)
                           order by orderid) a
                  where rownum <= p_rowperpage * l_page)
         where r > p_rowperpage * (l_page - 1);
    else
      open p_refcursor for
        select *
          from (select a.*, rownum r
                   from (select txdate, custodycd, afacctno, desc_exectype,
                                 orderid, symbol, iscancel, isadmend,
                                 round(quoteprice * 1000, 15) quoteprice,
                                 execqtty, cancelqtty, adjustqtty, remainqtty,
                                 sdtime lastchange,
                                 decode(matchtypevalue,
                                         'P',
                                         exectype || matchtypevalue,
                                         exectype) exectype, pricetype,
                                 orderqtty, tradeplace, execamt, foacctno,
                                 isdisposal, orstatus, feedbackmsg, rootorderid,
                                 orstatusvalue,
                                 round(nvl(limitprice * 1000, 0), 15) limitprice,
                                 round(nvl(quoteqtty, 0), 15) quoteqtty,
                                 confirmed, via, txtime,
                                 round(case
                                         when execqtty > 0 then
                                          execamt / execqtty
                                         else
                                          0
                                       end,
                                       15) execprice,
                                 case
                                   when execqtty > 0 and cancelqtty = 0 and
                                        adjustqtty = 0 then
                                    orstatus || ' ' || execqtty || '/' ||
                                    orderqtty
                                   when cancelqtty > 0 and adjustqtty = 0 then
                                    orstatus || ' ' || cancelqtty || '/' ||
                                    orderqtty
                                   when adjustqtty > 0 then
                                    orstatus || ' ' || adjustqtty || '/' ||
                                    orderqtty
                                   else
                                    orstatus
                                 end status,
                                 decode(tlname, 'useronline', custodycd, tlname) tlname,
                                 to_char(odtimestamp,
                                          'RRRR/MM/DD hh24:mi:ss.ff9') odtimestamp
                            from buf_od_account
                           where custodycd = p_tlname
                             and txdate = l_current_date
                           order by orderid desc) a
                  where rownum <= p_rowperpage * l_page)
         where r > p_rowperpage * (l_page - 1);
    end if;
  end sp_get_orders_by_user_careby;

  -- Refesh orders
  procedure sp_refesh_orders_by_user(p_refcursor in out pkg_report.ref_cursor,
                                     p_tlname in varchar2, p_scn in varchar2,
                                     p_role in varchar2 default 'B') is
    l_current_date date;
  begin

    begin
      select sbdate
        into l_current_date
        from sbcurrdate
       where numday = 0
         and sbtype = 'N';
    exception
      when no_data_found then
        l_current_date := getcurrdate;
    end;

    if nvl(p_role, 'X') = 'B' then

      open p_refcursor for
        select decode(matchtypevalue,
                       'P',
                       exectype || matchtypevalue,
                       exectype) exectype, pricetype, custodycd, afacctno,
               symbol, orderqtty, quoteprice * 1000 quoteprice,
               case
                 when execqtty > 0 and cancelqtty = 0 and adjustqtty = 0 then
                  orstatus || ' ' || execqtty || '/' || orderqtty
                 when cancelqtty > 0 and adjustqtty = 0 then
                  orstatus || ' ' || cancelqtty || '/' || orderqtty
                 when adjustqtty > 0 then
                  orstatus || ' ' || adjustqtty || '/' || orderqtty
                 else
                  orstatus
               end status, orderid, sdtime lastchange, remainqtty,
               cancelqtty, adjustqtty, tradeplace, desc_exectype, iscancel,
               isadmend, isdisposal, foacctno,
               to_char(odtimestamp, 'RRRR/MM/DD hh24:mi:ss.ff9') odtimestamp,
               orstatusvalue, nvl(limitprice * 1000, 0) limitprice,
               nvl(quoteqtty, 0) quoteqtty, confirmed, execqtty, execamt,
               orstatus,
               decode(tlname, 'USERONLINE', custodycd, tlname) tlname
          from buf_od_account
         where tlname = p_tlname
           and txdate = l_current_date
           and odtimestamp >
               to_timestamp(p_scn, 'RRRR/MM/DD hh24:mi:ss.ff9');
    else
      open p_refcursor for
        select decode(matchtypevalue,
                       'P',
                       exectype || matchtypevalue,
                       exectype) exectype, pricetype, custodycd, afacctno,
               symbol, orderqtty, quoteprice * 1000 quoteprice,
               case
                 when execqtty > 0 and cancelqtty = 0 and adjustqtty = 0 then
                  orstatus || ' ' || execqtty || '/' || orderqtty
                 when cancelqtty > 0 and adjustqtty = 0 then
                  orstatus || ' ' || cancelqtty || '/' || orderqtty
                 when adjustqtty > 0 then
                  orstatus || ' ' || adjustqtty || '/' || orderqtty
                 else
                  orstatus
               end status, orderid, sdtime lastchange, remainqtty,
               cancelqtty, adjustqtty, tradeplace, desc_exectype, iscancel,
               isadmend, isdisposal, foacctno,
               to_char(odtimestamp, 'RRRR/MM/DD hh24:mi:ss.ff9') odtimestamp,
               orstatusvalue, nvl(limitprice * 1000, 0) limitprice,
               nvl(quoteqtty, 0) quoteqtty, confirmed, execqtty, execamt,
               orstatus,
               decode(tlname, 'USERONLINE', custodycd, tlname) tlname
          from buf_od_account
         where custodycd = p_tlname
           and txdate = l_current_date
           and odtimestamp >
               to_timestamp(p_scn, 'RRRR/MM/DD hh24:mi:ss.ff9');
    end if;
  end sp_refesh_orders_by_user;

  -- Refesh orders by user careby
  procedure sp_refesh_orders_careby(p_refcursor in out pkg_report.ref_cursor,
                                    p_tlname in varchar2, p_numday in number,
                                    p_scn in varchar2,
                                    p_role in varchar2 default 'B') is
    l_current_date date;
  begin

    begin
      select sbdate
        into l_current_date
        from sbcurrdate
       where numday = 0
         and sbtype = 'N';
    exception
      when no_data_found then
        l_current_date := getcurrdate;
    end;

    if nvl(p_role, 'X') = 'B' then

      open p_refcursor for
        select txdate, custodycd, afacctno, desc_exectype, orderid, symbol,
               iscancel, isadmend, round(quoteprice * 1000, 15) quoteprice,
               execqtty, cancelqtty, adjustqtty, remainqtty,
               sdtime lastchange,
               decode(matchtypevalue,
                       'P',
                       exectype || matchtypevalue,
                       exectype) exectype, pricetype, orderqtty, tradeplace,
               execamt, foacctno, isdisposal, orstatus, feedbackmsg,
               rootorderid, orstatusvalue,
               round(nvl(limitprice * 1000, 0), 15) limitprice,
               round(nvl(quoteqtty, 0), 15) quoteqtty, confirmed, via,
               txtime,
               round(case
                       when execqtty > 0 then
                        execamt / execqtty
                       else
                        0
                     end,
                     15) execprice,
               case
                 when execqtty > 0 and cancelqtty = 0 and adjustqtty = 0 then
                  orstatus || ' ' || execqtty || '/' || orderqtty
                 when cancelqtty > 0 and adjustqtty = 0 then
                  orstatus || ' ' || cancelqtty || '/' || orderqtty
                 when adjustqtty > 0 then
                  orstatus || ' ' || adjustqtty || '/' || orderqtty
                 else
                  orstatus
               end status,
               decode(tlname, 'useronline', custodycd, tlname) tlname,
               to_char(odtimestamp, 'RRRR/MM/DD hh24:mi:ss.ff9') odtimestamp
          from buf_od_account
         where txdate = l_current_date
           and careby in
               (select grpid from tlgrpusers where tlid = p_tlname)
           and odtimestamp >
               to_timestamp(p_scn, 'RRRR/MM/DD hh24:mi:ss.ff9')
         order by orderid;
    else
      open p_refcursor for
        select txdate, custodycd, afacctno, desc_exectype, orderid, symbol,
               iscancel, isadmend, round(quoteprice * 1000, 15) quoteprice,
               execqtty, cancelqtty, adjustqtty, remainqtty,
               sdtime lastchange,
               decode(matchtypevalue,
                       'P',
                       exectype || matchtypevalue,
                       exectype) exectype, pricetype, orderqtty, tradeplace,
               execamt, foacctno, isdisposal, orstatus, feedbackmsg,
               rootorderid, orstatusvalue,
               round(nvl(limitprice * 1000, 0), 15) limitprice,
               round(nvl(quoteqtty, 0), 15) quoteqtty, confirmed, via,
               txtime,
               round(case
                       when execqtty > 0 then
                        execamt / execqtty
                       else
                        0
                     end,
                     15) execprice,
               case
                 when execqtty > 0 and cancelqtty = 0 and adjustqtty = 0 then
                  orstatus || ' ' || execqtty || '/' || orderqtty
                 when cancelqtty > 0 and adjustqtty = 0 then
                  orstatus || ' ' || cancelqtty || '/' || orderqtty
                 when adjustqtty > 0 then
                  orstatus || ' ' || adjustqtty || '/' || orderqtty
                 else
                  orstatus
               end status,
               decode(tlname, 'useronline', custodycd, tlname) tlname,
               to_char(odtimestamp, 'RRRR/MM/DD hh24:mi:ss.ff9') odtimestamp
          from buf_od_account
         where custodycd = p_tlname
           and txdate = l_current_date
           and odtimestamp >
               to_timestamp(p_scn, 'RRRR/MM/DD hh24:mi:ss.ff9')
         order by orderid desc;
    end if;
  end sp_refesh_orders_careby;

  -- Function and procedure implementations
  procedure sp_get_time(p_tran_type in varchar2, p_err_code in out varchar2,
                        p_err_message in out varchar2) as

    l_allow_diff_date boolean := false;
    l_start_name      varchar2(100);
    l_end_name        varchar2(100);

    l_date_format        varchar2(25) := 'DD/MM/RRRR hh24miss';
    l_current_date_value varchar2(10);
    l_start_value        varchar2(50);
    l_end_value          varchar2(50);

    l_start_time date;
    l_end_time   date;

    not_a_valid_date exception;
    pragma exception_init(not_a_valid_date, -101);

    time_over exception;
    pragma exception_init(not_a_valid_date, -111);
  begin
    plog.setbeginsection(pkgctx, 'sp_get_time');

    p_err_code := c_fo_default;

    if p_tran_type = '0' then
      l_start_name := 'ONLINETRF1120STARTTIME';
      l_end_name   := 'ONLINETRF1120ENDTIME';
    elsif p_tran_type = '1' then
      l_start_name := 'ONLINETRF1101STARTTIME';
      l_end_name   := 'ONLINETRF1101ENDTIME';
    else
      p_err_code    := '-1';
      p_err_message := 'Tham so khong hop le';
      return;
    end if;

    -- Ngay he thong oracle
    l_current_date_value := cspks_system.fn_get_sysvar(p_sys_grp  => 'SYSTEM',
                                                       p_sys_name => 'CURRDATE');

    -- Thoi gian bat dau duoc phep lam giao dich
    l_start_value := l_current_date_value || ' ' ||
                     cspks_system.fn_get_sysvar(p_sys_grp  => 'SYSTEM',
                                                p_sys_name => l_start_name);

    l_start_time := fn_to_date(l_start_value, l_date_format);

    -- Het thoi gian giao dich
    l_end_value := l_current_date_value || ' ' ||
                   cspks_system.fn_get_sysvar(p_sys_grp  => 'SYSTEM',
                                              p_sys_name => l_end_name);

    l_end_time := fn_to_date(l_end_value, l_date_format);

    -- 1. Ngay he thong va ngay oracle giong nhau
    if to_char(l_start_time, systemnums.c_date_format) =
       to_char(sysdate, systemnums.c_date_format) then
      if sysdate < l_start_time then
        raise time_over;
      elsif sysdate > l_end_time then
        raise time_over;
      end if;
    elsif l_allow_diff_date = false then
      raise time_over;
    end if;

    plog.setendsection(pkgctx, 'sp_get_time');
  exception
    when time_over then
      p_err_code    := c_fo_time_over;
      p_err_message := cspks_system.fn_get_errmsg(p_errnum => p_err_code);
      plog.setendsection(pkgctx, 'sp_get_time');
    when not_a_valid_date then
      p_err_code := c_fo_user_invalid_date;
      plog.setendsection(pkgctx, 'sp_get_time');
    when others then
      p_err_code := errnums.c_system_error;
      plog.error(pkgctx, sqlerrm);
      plog.setendsection(pkgctx, 'sp_get_time');
  end sp_get_time;

  function fn_to_date(p_char_literal in varchar2, p_date_format in varchar2)
    return date is
  begin
    -- in this situation it'll be safe to use `when others`.
    return to_date(p_char_literal, p_date_format);
  exception
    when others then
      raise_application_error(c_fo_user_invalid_date, 'Not a valid date');
  end;

  -- Audit login/ logout
  function fn_is_module_permission(p_module varchar2,
                                   p_permission_index number,
                                   p_custid varchar2, p_afacctno varchar2)
    return boolean as
    l_auth_cust_id varchar2(10);
    --l_otmn_code    varchar2(20);
    l_ot_right    varchar2(10);
    l_index_value varchar2(1);
  begin
    plog.setbeginsection(pkgctx, 'fn_is_module_permission');

    begin
      select d.authcustid, d.otright
        into l_auth_cust_id, l_ot_right
        from otright o, otrightdtl d, allcode a
       where o.authcustid = d.authcustid
         and o.cfcustid = d.cfcustid
         and d.deltd = 'N'
         and o.deltd = 'N'
         and o.authcustid = p_custid
         and o.cfcustid = p_afacctno
         and d.otmncode = p_module
         and a.cdval = d.otmncode
         and a.cdname = 'OTFUNC'
         and o.expdate >= getcurrdate;

    exception
      when no_data_found then
        return false;
    end;

    l_index_value := substr(l_ot_right, p_permission_index, 1);

    if (nvl(l_index_value, 'X') = 'Y') then
      return true;
    end if;

    return false;

    plog.setendsection(pkgctx, 'fn_is_module_permission');
  exception
    when others then
      plog.error(pkgctx, sqlerrm);
      plog.setendsection(pkgctx, 'fn_is_module_permission');
  end;

  -- Audit login/ logout
  function fn_validation_type(p_module varchar2, p_custid varchar2)
    return varchar2 as
    l_auth_cust_id varchar2(10);
    l_otmn_code    varchar2(20);
    l_ot_right     varchar2(10);
    l_type         varchar2(5);
    l_pass_value   varchar2(2);
    l_token_value  varchar2(2);
  begin
    plog.setbeginsection(pkgctx, 'fn_is_module_permission');

    begin
      select distinct d.authcustid,
                      substr(d.otright, 1, 4) ||
                       decode(u.authtype,
                              '0',
                              'NN',
                              '1',
                              'YN',
                              '2',
                              'NY',
                              '3',
                              'NY',
                              'YN') otright, u.authtype, d.otmncode
        into l_auth_cust_id, l_ot_right, l_type, l_otmn_code
        from otright o, otrightdtl d, allcode a, sysvar s, afmast af,
             userlogin u, cfmast c
       where o.authcustid = d.authcustid
         and o.cfcustid = d.cfcustid
         and o.cfcustid = af.custid
         and u.username = c.username
         and c.custid = o.authcustid
         and o.cfcustid = o.authcustid
         and d.deltd = 'N'
         and o.deltd = 'N'
         and a.cdval = d.otmncode
         and o.authcustid = p_custid
         and d.otmncode = p_module
         and a.cdname = 'OTFUNC'
         and s.varname = 'CURRDATE'
         and s.grname = 'SYSTEM'
         and o.expdate >= getcurrdate;

    exception
      when no_data_found then
        return 'NONE';
    end;

    l_pass_value  := substr(l_ot_right, c_auth_by_pass_index, 2);
    l_token_value := substr(l_ot_right, c_auth_by_token_index, 2);

    if (nvl(l_token_value, 'XX') = 'NY') and l_type = '2' then
      return 'TOKEN';
    end if;

    if (nvl(l_token_value, 'XX') = 'NY') and l_type = '3' then
      return 'MATRIX';
    end if;

    if (nvl(l_pass_value, 'XX') = 'YN') and l_type = '1' then
      return 'PASS';
    end if;

    return 'NONE';

    plog.setendsection(pkgctx, 'fn_is_module_permission');
  exception
    when others then
      plog.error(pkgctx, sqlerrm);
      plog.setendsection(pkgctx, 'fn_is_module_permission');
      return 'NONE';
  end;

  -- Get orders all list
  procedure sp_get_ot_rights(p_refcursor in out pkg_report.ref_cursor,
                             p_custid in varchar2) is
    l_current_date date;
  begin

    open p_refcursor for
      select d.*,a.acctno
        from otright o, otrightdtl d, afmast a
       where o.authcustid = d.authcustid
         and o.cfcustid = d.cfcustid
         AND a.custid = d.cfcustid
         and d.deltd = 'N'
         and o.deltd = 'N'
         and o.authcustid = p_custid
         and o.expdate >= getcurrdate;

  end sp_get_ot_rights;

  -- Get careby by username
  procedure sp_get_careby_by_name(p_refcursor in out pkg_report.ref_cursor,
                                  p_username in varchar2,
                                  p_afacctno in varchar2,
                                  p_role  in varchar2) is
  begin


    if p_role = 'C' then
      open p_refcursor for
      select a.acctno, c.custodycd
        from afmast a, cfmast c
       where a.custid = c.custid
         and a.status in ('A', 'P')
         and a.isfixaccount = 'N'
         and a.acctno = p_afacctno
         and c.username = p_username
         union
      select a.acctno, c.custodycd
        from otrightdtl o, cfmast c, afmast a
       where o.authcustid = c.custid
       AND a.custid = o.cfcustid
         and a.acctno = p_afacctno
         and c.username = p_username;
   else
     open p_refcursor for
      select a.acctno, c.custodycd
        from afmast a, cfmast c
       where a.custid = c.custid
         and a.status in ('A', 'P')
         and a.isfixaccount = 'N'
         and a.acctno = p_afacctno
         and a.careby in (select grpid
                            from tlgrpusers g, tlprofiles p
                           where g.tlid = p.tlid
                             and p.tlname = p_username)
      union
      select afk.afacctno, afk.custodycd
from afmast a, afuserlnk afk, tlprofiles p
where afk.afacctno = p_afacctno
         and afk.afacctno = a.acctno
         and a.status in ('A', 'P')
         and a.isfixaccount = 'N'
         and afk.tlid = p.tlid
         and p.tlname = p_username;
  end if;
  end sp_get_careby_by_name;

-- Get Order by user careby
procedure sp_get_order_by_careby(p_refcursor in out pkg_report.ref_cursor,
                                   p_txdate in varchar2,
                                   p_tlid in varchar2,
                                   p_custodycd in varchar2,
                                   p_afacctno in varchar2,
                                   p_exectype in varchar2,
                                   p_symbol in varchar2) is
   begin
     open p_refcursor for

     select distinct od.custodycd,od.txdate, od.afacctno,a.cdval accounttype, od.desc_exectype, od.orderid, od.symbol,
       od.iscancel, od.isadmend,round(od.quoteprice*1000,15) quoteprice, od.execqtty, od.cancelqtty,
       od.adjustqtty,od.remainqtty, od.sdtime lastchange,
       decode(od.matchtypevalue, 'p', od.exectype || od.matchtypevalue, od.exectype ) exectype,od.pricetype,
       od.orderqtty, decode(od.hosesession, 'o', ' Li?t?c ', 'a', ' ?nh k? ', 'p', ' ?nh k? ') hosesession,
       od.tradeplace, od.execamt,od.foacctno, od.isdisposal, od.orstatus,od.feedbackmsg, od.rootorderid,
       od.orstatusvalue,round(nvl(limitprice*1000,0),15) limitprice, round(nvl(quoteqtty,0),15) quoteqtty,
       od.confirmed, od.via, od.txtime,round( case when od.execqtty > 0 then od.execamt/od.execqtty else 0 end,15) execprice,
       case when od.execqtty > 0 and od.cancelqtty = 0 and od.adjustqtty = 0 then od.orstatusvalue || ' ' || od.execqtty || '/' || od.orderqtty
       when od.cancelqtty > 0 and od.adjustqtty=0 then od.orstatusvalue || ' ' || od.cancelqtty || '/' || od.orderqtty
       when od.adjustqtty > 0 then od.orstatusvalue || ' ' || od.adjustqtty || '/' || od.orderqtty else od.orstatusvalue end status
       , decode(od.tlname, 'useronline', od.custodycd, od.tlname) tlname,
       greatest(od.remainqtty*round(od.quoteprice*1000,15),0)  remainamt
    from buf_od_account od, sbcurrdate d, afuserlnk afu, cfmast cf, afmast af, aftype aft, allcode a
    where od.txdate = d.sbdate and d.sbtype = 'B' and od.custodycd = afu.custodycd(+)
       and od.afacctno = afu.afacctno(+)
       AND od.afacctno = af.acctno(+)
       AND af.actype = aft.actype
       and d.numday = p_txdate
       and a.cdtype='CF' and a.cdname='PRODUCTTYPE' and a.cdval=aft.producttype
       and (od.careby in (select t.grpid from tlgrpusers t where t.tlid like p_tlid) or afu.tlid like p_tlid)
       AND ((od.TIMETYPEVALUE='T') -- Lenh binh thuong, bao gom ca lenh goc va lenh sua
            OR (od.TIMETYPEVALUE='G' AND od.ORSTATUSVALUE NOT IN ('5', 'P', '6', 'W', 'R')) --Het hieu luc, tu choi, R:lenh dieu kien chua active, bi huy
          )
       AND od.username = cf.custid
       and (cf.custodycd like p_custodycd or od.custodycd like p_custodycd)
       and od.afacctno like p_afacctno
       and od.exectype like p_exectype
       and od.symbol like p_symbol
    order by od.orderid;

   end sp_get_order_by_careby;

-- Get Order by user careby
procedure sp_get_active_order_by_careby(p_refcursor in out pkg_report.ref_cursor,
                                   p_txdate in varchar2,
                                   p_tlid in varchar2,
                                   p_custodycd in varchar2 ,
                                   p_afacctno in varchar2,
                                   p_exectype in varchar2,
                                   p_symbol in varchar2) is
   begin
     open p_refcursor for

     select distinct od.custodycd,od.txdate, od.afacctno,a.cdval accounttype, od.desc_exectype, od.orderid, od.symbol,
       od.iscancel, od.isadmend,round(od.quoteprice*1000,15) quoteprice, od.execqtty, od.cancelqtty,
       od.adjustqtty,od.remainqtty, od.sdtime lastchange,
       decode(od.matchtypevalue, 'p', od.exectype || od.matchtypevalue, od.exectype ) exectype,od.pricetype,
       od.orderqtty, decode(od.hosesession, 'o', ' Li?t?c ', 'a', ' ?nh k? ', 'p', ' ?nh k? ') hosesession,
       od.tradeplace, od.execamt,od.foacctno, od.isdisposal, od.orstatus,od.feedbackmsg, od.rootorderid,
       od.orstatusvalue,round(nvl(limitprice*1000,0),15) limitprice, round(nvl(quoteqtty,0),15) quoteqtty,
       od.confirmed, od.via, od.txtime,round( case when od.execqtty > 0 then od.execamt/od.execqtty else 0 end,15) execprice,
       case when od.execqtty > 0 and od.cancelqtty = 0 and od.adjustqtty = 0 then od.orstatusvalue || ' ' || od.execqtty || '/' || od.orderqtty
       when od.cancelqtty > 0 and od.adjustqtty=0 then od.orstatusvalue || ' ' || od.cancelqtty || '/' || od.orderqtty
       when od.adjustqtty > 0 then od.orstatusvalue || ' ' || od.adjustqtty || '/' || od.orderqtty else od.orstatusvalue end status
       , decode(od.tlname, 'useronline', od.custodycd, od.tlname) tlname,
       greatest(od.remainqtty*round(od.quoteprice*1000,15),0)  remainamt,
       od.odtimestamp
    from buf_od_account od, sbcurrdate d, afuserlnk afu, cfmast cf, afmast af, aftype aft, allcode a
    where od.txdate = d.sbdate and d.sbtype = 'B' and od.custodycd = afu.custodycd(+)
       and od.afacctno = afu.afacctno(+)
       AND od.afacctno = af.acctno(+)
       AND af.actype = aft.actype
       and d.numday = p_txdate
       and a.cdtype='CF' and a.cdname='PRODUCTTYPE' and a.cdval=aft.producttype
       and (od.careby in (select t.grpid from tlgrpusers t where t.tlid like p_tlid) or afu.tlid like p_tlid)
       AND ((od.TIMETYPEVALUE='T' AND od.ORSTATUSVALUE <> '10') -- Lenh binh thuong, bao gom ca lenh goc va lenh sua
            OR (od.TIMETYPEVALUE='G' AND od.ORSTATUSVALUE NOT IN ('5', 'P', '6', 'W', 'R')) --Het hieu luc, tu choi, R:lenh dieu kien chua active, bi huy
          )
       AND od.username = cf.custid
       and (cf.custodycd like p_custodycd or od.custodycd like p_custodycd)
       and od.afacctno like p_afacctno
       and od.exectype like p_exectype
       and od.symbol like p_symbol
       and od.remainqtty > 0
    order by od.orderid;

   end sp_get_active_order_by_careby;

procedure sp_get_refresh_active_order(p_refcursor in out pkg_report.ref_cursor,
                                   p_txdate in varchar2,
                                   p_tlid in varchar2,
                                   p_custodycd in varchar2 ,
                                   p_afacctno in varchar2,
                                   p_exectype in varchar2,
                                   p_symbol in varchar2,
                                   p_scn in varchar2) is
   begin
     open p_refcursor for

     select distinct od.custodycd,od.txdate, od.afacctno,a.cdcontent accounttype, od.desc_exectype, od.orderid, od.symbol,
       od.iscancel, od.isadmend,round(od.quoteprice*1000,15) quoteprice, od.execqtty, od.cancelqtty,
       od.adjustqtty,od.remainqtty, od.sdtime lastchange,
       decode(od.matchtypevalue, 'p', od.exectype || od.matchtypevalue, od.exectype ) exectype,od.pricetype,
       od.orderqtty, decode(od.hosesession, 'o', ' Li?t?c ', 'a', ' ?nh k? ', 'p', ' ?nh k? ') hosesession,
       od.tradeplace, od.execamt,od.foacctno, od.isdisposal, od.orstatus,od.feedbackmsg, od.rootorderid,
       od.orstatusvalue,round(nvl(limitprice*1000,0),15) limitprice, round(nvl(quoteqtty,0),15) quoteqtty,
       od.confirmed, od.via, od.txtime,round( case when od.execqtty > 0 then od.execamt/od.execqtty else 0 end,15) execprice,
       case when od.execqtty > 0 and od.cancelqtty = 0 and od.adjustqtty = 0 then od.orstatus || ' ' || od.execqtty || '/' || od.orderqtty
       when od.cancelqtty > 0 and od.adjustqtty=0 then od.orstatus || ' ' || od.cancelqtty || '/' || od.orderqtty
       when od.adjustqtty > 0 then od.orstatus || ' ' || od.adjustqtty || '/' || od.orderqtty else od.orstatus end status
       , decode(od.tlname, 'useronline', od.custodycd, od.tlname) tlname,
       greatest(od.remainqtty*round(od.quoteprice*1000,15),0)  remainamt,
       od.odtimestamp
    from buf_od_account od, sbcurrdate d, afuserlnk afu, cfmast cf, afmast af, aftype aft, allcode a
    where od.txdate = d.sbdate and d.sbtype = 'B' and od.custodycd = afu.custodycd(+)
       and od.afacctno = afu.afacctno(+)
       AND od.afacctno = af.acctno(+)
       AND af.actype = aft.actype
       and d.numday = p_txdate
       and a.cdtype='CF' and a.cdname='PRODUCTTYPE' and a.cdval=aft.producttype
       and (od.careby in (select t.grpid from tlgrpusers t where t.tlid like p_tlid) or afu.tlid like p_tlid)
       AND (od.TIMETYPEVALUE='T' --AND od.ORSTATUSVALUE <> '10') -- Lenh binh thuong, bao gom ca lenh goc va lenh sua
            OR (od.TIMETYPEVALUE='G' AND od.ORSTATUSVALUE NOT IN ('5', 'P', '6', 'W', 'R')) --Het hieu luc, tu choi, R:lenh dieu kien chua active, bi huy
          )
       AND od.username = cf.custid
       and (cf.custodycd like p_custodycd or od.custodycd like p_custodycd)
       and od.afacctno like p_afacctno
       and od.exectype like p_exectype
       and od.symbol like p_symbol
       --and od.remainqtty > 0
       AND od.odtimestamp >
               to_timestamp(p_scn, 'RRRR/MM/DD hh24:mi:ss.ff9')
    order by od.orderid;

   end sp_get_refresh_active_order;


procedure sp_loginToken(p_login_id in out varchar2, p_username in varchar2,
                     p_password varchar2, p_loginsrcip varchar2,
                     p_logindstip varchar2, p_custid in out varchar2,
                     p_role in out varchar2, p_isreset in out varchar2,
                     p_err_code in out varchar2,
                     p_err_message in out varchar2) as
    l_userid       varchar2(10);
    l_username     varchar2(50);
    l_fullname     varchar2(500);
    l_brid         char(4);
    l_customer_id  char(10);
    l_tokenid      varchar2(25);
    l_current_date varchar2(25);
    l_login_time   varchar2(25);
    l_roles        char(1);
    l_status       char(1);
    l_isreset      char(1);
    l_custody_code varchar2(10);
  begin

    plog.setbeginsection(pkgctx, 'sp_login');

    p_err_code    := systemnums.c_success;
    p_err_message := '-';

    if not fopks_api.fn_is_ho_active then

      p_err_code    := errnums.c_sa_host_operation_isinactive;
      p_err_message := cspks_system.fn_get_errmsg(p_err_code);
      return;

    end if;

    begin

      select tlid, tlname, tlfullname, brid, tokenid, currdate, logintime,
             role, custid, status, isreset, custodycd
        into l_userid, l_username, l_fullname, l_brid, l_tokenid,
             l_current_date, l_login_time, l_roles, l_customer_id, l_status,
             l_isreset, l_custody_code
        from (select tlid, tlname, tlfullname, brid, '' tokenid,
                      to_char(getcurrdate, 'DD/MM/RRRR') currdate,
                      to_char(sysdate, 'DD/MM/RRRR HH24:MI:SS') logintime,
                      'B' role, '' custid, active status, 'N' isreset,
                      '' custodycd
                 from tlprofiles tl
                where tl.tlname = p_username
                  --and tl.pin = p_password
               union all
               select u.username tlid, c.username tlname,
                      c.fullname tlfullname, brid, u.tokenid,
                      to_char(getcurrdate, 'DD/MM/RRRR') currdate,
                      to_char(sysdate, 'DD/MM/RRRR HH24:MI:SS') logintime,
                      'C' role, c.custid, u.status, u.isreset, c.custodycd
                 from userlogin u, cfmast c
                where u.username = c.username
                  and u.username = p_username
                  --and u.loginpwd = p_password
                  );

      if nvl(l_roles, 'X') = 'B' then
        if nvl(l_status, 'X') <> 'Y' then
          p_err_code := c_fo_customer_status_invalid;
          raise errnums.e_biz_rule_invalid;
        end if;
      else
        if nvl(l_status, 'X') <> 'A' then
          p_err_code := c_fo_customer_status_invalid;
          raise errnums.e_biz_rule_invalid;
        end if;
      end if;

    exception
      when no_data_found then
        p_err_code := c_fo_user_does_not_existed;
        raise errnums.e_biz_rule_invalid;
    end;

    p_login_id  := sys_guid();
    p_role      := l_roles;
    p_custid    := l_customer_id;
    p_isreset   := l_isreset;
    --p_custodycd := l_custody_code;

    sp_audit_authenticate(p_login_id,
                          p_username,
                          p_loginsrcip,
                          p_logindstip,
                          c_fo_login);

    /*    open p_refcursor for
    select l_userid, l_username, l_fullname, l_brid, l_tokenid,
           l_current_date, l_login_time, l_roles, l_status
      from dual;*/

    plog.setendsection(pkgctx, 'sp_login');
  exception
    when errnums.e_biz_rule_invalid then
      for i in (select errdesc, en_errdesc
                  from deferror
                 where errnum = p_err_code) loop
        p_err_message := i.errdesc;

      --sp_audit_authenticate(p_username, c_fo_log, '', p_err_param);
      end loop;
      plog.error(pkgctx, sqlerrm);
      plog.setendsection(pkgctx, 'sp_login');
    when others then
      p_err_code := errnums.c_system_error;
      for i in (select errdesc, en_errdesc
                  from deferror
                 where errnum = p_err_code) loop
        p_err_message := i.errdesc;
      end loop;
      plog.error(pkgctx, sqlerrm);
      plog.setendsection(pkgctx, 'sp_login');
  end;

begin
  -- Initialization
  for i in (select * from tlogdebug) loop
    logrow.loglevel  := i.loglevel;
    logrow.log4table := i.log4table;
    logrow.log4alert := i.log4alert;
    logrow.log4trace := i.log4trace;
  end loop;

  pkgctx := plog.init('htspks_api',
                      plevel      => nvl(logrow.loglevel, 30),
                      plogtable   => (nvl(logrow.log4table, 'N') = 'Y'),
                      palert      => (nvl(logrow.log4alert, 'N') = 'Y'),
                      ptrace      => (nvl(logrow.log4trace, 'N') = 'Y'));
end htspks_api;

-- Edited by : NinhDT :17/10/2013
/
