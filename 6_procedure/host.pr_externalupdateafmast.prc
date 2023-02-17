SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "PR_EXTERNALUPDATEAFMAST" (pv_err_code in out varchar2, pv_acctno in varchar2, pv_applyacctno in varchar2)
is
v_custid varchar2(20);
v_mrtype char(1);
v_corebank char(1);
begin
    --Cap nhat thong tin tu khach hang sang tieu khoan.
    --select custid into v_custid from afmast where acctno = pv_acctno;
    select af.custid, mrt.mrtype, af.corebank into v_custid , v_mrtype, v_corebank from afmast af, aftype aft, mrtype mrt
    where af.actype = aft.actype and aft.mrtype= mrt.actype
    and af.acctno = pv_acctno;
    --Cap nhat cho Ung truoc tu dong
    if v_corebank <> 'Y' and v_mrtype='N' then
        for rec in (
        select af.autoadv
        from afmast af, aftype aft, mrtype mrt
            where af.actype = aft.actype and aft.mrtype= mrt.actype
            --and af.corebank <>'Y' and mrt.mrtype ='N'
            and af.acctno=pv_applyacctno)
        loop
            update afmast set autoadv= rec.autoadv where acctno = pv_acctno;
        end loop;
    end if;

    for rec in (select * from afmast where acctno=pv_applyacctno)
    loop
        --Dich vu SMS
/*        insert into AFTEMPLATES (autoid, afacctno, template_code)
        select seq_AFTEMPLATES.nextval , pv_acctno afacctno, template_code from AFTEMPLATES where afacctno =rec.acctno;
        --Thong tin uy quyen
        INSERT INTO cfauth (AUTOID,ACCTNO,CUSTID,FULLNAME,ADDRESS,TELEPHONE,LICENSENO,VALDATE,EXPDATE,DELTD,LINKAUTH,SIGNATURE,ACCOUNTNAME,BANKACCOUNT,BANKNAME,LNPLACE,LNIDDATE)
        select seq_cfauth.nextval, pv_acctno ACCTNO,CUSTID,FULLNAME,ADDRESS,TELEPHONE,LICENSENO,VALDATE,EXPDATE,DELTD,LINKAUTH,SIGNATURE,ACCOUNTNAME,BANKACCOUNT,BANKNAME,LNPLACE,LNIDDATE
        from cfauth where acctno =rec.acctno;*/ -- Quan ly CFMAST
        --GD qua ?
        --Giao dich Online
/*        update afmast set tradefloor=rec.tradefloor, tradetelephone=rec.tradetelephone, tradeonline= rec.tradeonline
        where acctno =pv_acctno;*/
        --Thong tin chuyen khoan
/*        INSERT INTO cfotheracc (AUTOID,AFACCTNO,CIACCOUNT,CINAME,CUSTID,BANKACC,BANKACNAME,BANKNAME,TYPE,ACNIDCODE,ACNIDDATE,ACNIDPLACE,FEECD,CITYEF,CITYBANK)
        select seq_cfotheracc.nextval, pv_acctno AFACCTNO,CIACCOUNT,CINAME,CUSTID,BANKACC,BANKACNAME,BANKNAME,TYPE,ACNIDCODE,ACNIDDATE,ACNIDPLACE,FEECD,CITYEF,CITYBANK
        from cfotheracc where afacctno = rec.acctno;*/
        --TT dang ky dich vu giao dich truc tuyen
/*        INSERT INTO otright (AUTOID,AFACCTNO,AUTHCUSTID,AUTHTYPE,VALDATE,EXPDATE,DELTD,LASTDATE,LASTCHANGE)
        select seq_otright.nextval,pv_acctno AFACCTNO,AUTHCUSTID,AUTHTYPE,VALDATE,EXPDATE,DELTD,LASTDATE,sysdate
        from otright where afacctno =  rec.acctno;
        INSERT INTO otrightdtl (AUTOID,AFACCTNO,AUTHCUSTID,OTMNCODE,OTRIGHT,DELTD)
        select seq_otrightdtl.nextval,pv_acctno AFACCTNO,AUTHCUSTID,OTMNCODE,OTRIGHT,DELTD
        from otrightdtl where AFACCTNO = rec.acctno;*/

        Return;--Chi cap nhat dich vu theo tai khoan dau tien
    end loop;
end;

 
 
 
 
/
