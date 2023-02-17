SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE pr_insert_odauth_log(p_orderid in varchar2,p_acctno in varchar2,p_codeid in varchar2,p_otauthtype in varchar2,p_ipaddress in varchar2,p_orderdata in varchar2, p_macaddress in varchar2, p_err_code out varchar2,p_err_message out varchar2)
IS
    l_afacctno varchar2(20);
    l_via varchar2(5);
    l_exectype varchar2(5);
    l_authtype varchar2(5);
    l_serialNumSig varchar2(100);
    l_getcurrendate TIMESTAMP;
    l_txdate date;
begin
    l_authtype:=p_otauthtype;
    l_getcurrendate:= to_date(to_char(getcurrdate,'DD/MM/RRRR') || to_char(sysdate,' HH24:MI:SS'),'DD/MM/RRRR HH24:MI:SS');
    begin
        select afacctno, via, exectype, txdate
        into l_afacctno, l_via, l_exectype,l_txdate
        from
        (select orderid, afacctno, via, exectype, to_date(to_char(txdate,'DD/MM/RRRR') ||' '|| txtime, 'DD/MM/RRRR HH24:MI:SS') txdate from odmast
            union all
            select acctno, afacctno, via, exectype, l_getcurrendate txdate from fomast)
        where orderid=p_orderid;
    exception when others then
        l_afacctno:='';
        l_via:='';
        l_exectype:='';
        l_txdate:='';
    end;
    begin
        SELECT OT.SERIALNUMSIG
        INTO l_serialNumSig
        FROM OTRIGHT OT, AFMAST AF
        WHERE OT.CFCUSTID = AF.CUSTID
        AND OT.DELTD <> 'Y'
        AND OT.AUTHTYPE = l_authtype
        AND AF.ACCTNO= l_afacctno;
    exception when others then
        l_serialNumSig:='';
    end;

    if l_afacctno is not null then
        if l_authtype='4' then
            insert into odauth_log(autoid, orderid, acctno, codeid, otauthtype, ipaddress, lastchange, via, EXECTYPE,ORDERDATESIGNE, macaddress,txdate,SERIALNUMSIG)
            values(seq_odauth_log.nextval, p_orderid, l_afacctno, p_codeid, p_otauthtype, p_ipaddress, sysdate, l_via, l_exectype,p_orderdata, p_macaddress,l_txdate,l_serialNumSig);
        else
            insert into odauth_log(autoid, orderid, acctno, codeid, otauthtype, ipaddress, orderdata, lastchange, via, EXECTYPE, macaddress,txdate,SERIALNUMSIG)
            values(seq_odauth_log.nextval, p_orderid, l_afacctno, p_codeid, p_otauthtype, p_ipaddress, p_orderdata, sysdate, l_via, l_exectype, p_macaddress,l_txdate,l_serialNumSig);
        end if;
    end if;

    p_err_code    := '0';
    p_err_message := 'Cap nhat log ODAUTH thanh cong';
exception
  when NO_DATA_FOUND then
    p_err_code    := '-1';
    p_err_message := 'Cap nhat log ODAUTH khong thanh cong';
    rollback;
    plog.error ('pr_insert_odauth_log.error:'|| SQLERRM  || dbms_utility.format_error_backtrace);
  when others then
    p_err_code    := '-2';
    p_err_message := 'Cap nhat log ODAUTH khong thanh cong';
    rollback;
    plog.error ('pr_insert_odauth_log.error:'|| SQLERRM  || dbms_utility.format_error_backtrace);
end;
 
/
