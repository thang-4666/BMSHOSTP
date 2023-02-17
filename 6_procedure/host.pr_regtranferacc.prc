SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE pr_regtranferacc(p_type in varchar2,-- 0 : Chuyen khoan noi bo.  1: Chuyen khoan ra NH
                        p_afacctno in varchar2,-- So tieu khoan goc
                        p_ciacctno in varchar2,-- So tieu khoan nhan trong truong hop chuyen khoan noi bo
                        p_ciname in varchar2,  -- Ten tieu khoan nhan trong truong hop chuyen khoan noi bo
                        p_bankacc in varchar2, -- So tk Ngan hang
                        p_bankacname in varchar2, -- Ten chu TK ngan hang
                        p_bankname in varchar2,  -- Ten Ngan Hang
                        p_cityef in varchar2,    -- Ten CHI NHANH
                        p_citybank in varchar2,  -- TEN THANH PHO
                        P_BANKID IN VARCHAR2,    -- BANK_NO.SB_BRANCH_CODE
                        P_bankorgno IN VARCHAR2, -- bank_no.org_bank
                        p_err_code out varchar2,
                        p_err_message out VARCHAR2
                        )
    IS
   v_currdate  date;
   v_count number;
  pkgctx plog.log_ctx;
  logrow tlogdebug%rowtype;
BEGIN
  for i in (select * from tlogdebug)
  loop
    logrow.loglevel  := i.loglevel;
    logrow.log4table := i.log4table;
    logrow.log4alert := i.log4alert;
    logrow.log4trace := i.log4trace;
  end loop;

  pkgctx := plog.init('fopks_api',
                      plevel     => nvl(logrow.loglevel, 30),
                      plogtable  => (nvl(logrow.log4table, 'N') = 'Y'),
                      palert     => (nvl(logrow.log4alert, 'N') = 'Y'),
                      ptrace     => (nvl(logrow.log4trace, 'N') = 'Y'));

 Select TO_DATE (varvalue, systemnums.c_date_format) into v_currdate
 From sysvar
 Where varname='CURRDATE';
 plog.setbeginsection(pkgctx, 'pr_regtranferacc');
 p_err_code := systemnums.C_SUCCESS;
    -- Check host & branch active or inactive
    p_err_code := fopks_api.fn_CheckActiveSystem;
    IF p_err_code <> systemnums.C_SUCCESS THEN
        p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
        plog.error(pkgctx, 'Error:'  || p_err_message);
        plog.setendsection(pkgctx, 'pr_regtranferacc');
        return;
    END IF;
    IF p_type='0' then
        v_count:=0;
        Begin
            Select count(1) into v_count
            From afmast
            Where acctno=p_ciacctno ;
        EXCEPTION
         When others then
         v_count:=0;
        End;
        IF v_count=0 then
            p_err_code:=errnums.C_CF_AFMAST_NOTFOUND;
            p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
            plog.error(pkgctx, 'Error:'  || p_err_message);
            plog.setendsection(pkgctx, 'pr_regtranferacc');
            return;
        else
            v_count:=0;
            Begin
                Select count(1) into v_count
                From afmast
                Where acctno=p_ciacctno and status = 'A' AND COREBANK='N';
            EXCEPTION
            When others then
                 v_count:=0;
            End;
            If v_count=0 then
                p_err_code:=errnums.C_CF_AFMAST_STATUS_INVALIDE;
                p_err_message:=cspks_system.fn_get_errmsg(p_err_code);
                plog.error(pkgctx, 'Error:'  || p_err_message);
                plog.setendsection(pkgctx, 'pr_regtranferacc');
                return;
            end if;
        end if;
    End if;

        For vc in(select distinct a1.custid
                 from afmast a1, afmast a2
                 where a1.custid=a2.custid
                       and a2.acctno= p_afacctno)
       Loop
           v_count:=0;
           Select count(1) into v_count
           From cfotheracc
           Where cfcustid=vc.custid--afacctno=vc.acctno
             and ((p_type='0' and ciaccount = p_ciacctno)
                  or
                  (p_type='1'and bankacc = p_bankacc)
                 );
           If   v_count = 0 then
                        insert into cfotheracc( autoid, cfcustid, ciaccount, ciname, custid, bankacc,
                                 bankacname, bankname, type, acnidcode, acniddate,
                                 acnidplace, feecd, cityef, citybank,BANKCODE)
                          values(seq_cfotheracc.nextval,vc.custid, p_ciacctno, p_ciname, null, p_bankacc,
                                 p_bankacname, p_bankname, p_type, null, null,
                                 null, DECODE(p_type,'0','0008','2','0011','0012'), p_cityef, p_citybank,P_BANKID);
           End if;
      End loop;

  plog.setendsection(pkgctx, 'pr_regtranferacc');
EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'pr_regtranferacc');
    p_err_code := errnums.C_SYSTEM_ERROR;
END;

 
 
 
 
/
