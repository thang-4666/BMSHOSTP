SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE pr_insert_trfauth_log(
p_orderid in varchar2,p_acctno in varchar2,
p_codeid in varchar2,p_otauthtype in varchar2,
p_ipaddress in varchar2,p_orderdata in varchar2,
p_macaddress in varchar2,p_via in varchar2,
p_err_code out varchar2,p_err_message out varchar2)
IS
    l_afacctno varchar2(20);
    l_via varchar2(5);
    l_authtype varchar2(5);
    v_txnum varchar2(20);
    v_txdate date;
    v_serialtoken varchar2(100);
    l_custid varchar2(20);
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;
   PRAGMA AUTONOMOUS_TRANSACTION;
begin
    l_authtype:=p_otauthtype;
    l_afacctno:=p_acctno;
    l_via:=p_via;

    select custid into l_custid from afmast where acctno=l_afacctno and rownum=1;

    begin
        select max(txnum), txdate into v_txnum, v_txdate
        from tllog tl where msgacct=l_afacctno and tltxcd=p_orderid
        group by txdate;
    exception when others then
        select max(txnum), txdate into v_txnum, v_txdate
        from tllog tl where tltxcd=p_orderid
        group by txdate;
    end;
    begin
        select serialtoken into v_serialtoken
        from otright
        where cfcustid=l_custid
        and deltd='N';
    exception when others then
        v_serialtoken:='';
    end;

    IF p_otauthtype='4' THEN
        insert into odauth_log(autoid, ORDERID, otauthtype, txnum, txdate, via, ipaddress, macaddress, serialtoken, ORDERDATESIGNE, lastchange, acctno)
        values(seq_odauth_log.nextval, to_char(v_txdate,'DD/MM/RRRR')||v_txnum, p_otauthtype, v_txnum, to_date(v_txdate,'DD/MM/RRRR'), l_via, p_ipaddress, p_macaddress, v_serialtoken, p_orderdata, sysdate, p_acctno);
    ELSE
        insert into odauth_log(autoid, ORDERID, otauthtype, txnum, txdate, via, ipaddress, macaddress, SERIALTOKEN, orderdata, lastchange, acctno)
        values(seq_odauth_log.nextval, to_char(v_txdate,'DD/MM/RRRR')||v_txnum, p_otauthtype, v_txnum, to_date(v_txdate,'DD/MM/RRRR'), l_via, p_ipaddress, p_macaddress, v_serialtoken, p_orderdata, sysdate, p_acctno);
    END IF;

    commit;

    p_err_code    := '0';
    p_err_message := 'Cap nhat log CI odauth_log thanh cong';
exception
  when NO_DATA_FOUND then
    p_err_code    := '-1';
    p_err_message := 'Cap nhat log CI odauth_log khong thanh cong';
    rollback;
  when others then
      p_err_code := errnums.C_SYSTEM_ERROR;
      plog.error (pkgctx, SQLERRM);
      plog.setendsection (pkgctx, 'fn_txPreAppUpdate');
      RAISE errnums.E_SYSTEM_ERROR;
end;
 
/
