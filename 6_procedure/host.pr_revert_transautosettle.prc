SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE pr_revert_transautosettle
   (p_bchmdl varchar,
    p_afacctno varchar2,
    p_list_tltxcd varchar,
    p_err_code  OUT varchar2,
    p_err_param OUT varchar2)
IS
    pkgctx plog.log_ctx;
BEGIN
    plog.setbeginsection(pkgctx, 'pr_revert_transautosettle');
--    plog.error ('p_bchmdl:'|| p_bchmdl);
--    plog.error ('p_afacctno:'|| p_afacctno);
--    plog.error ('p_list_tltxcd:'|| p_list_tltxcd);
    for rec in
    (
        select *
        from tllog
        where trim(batchname)='AUTO_SETTLEMENT' and msgacct=p_afacctno and deltd <> 'Y'
            and tltxcd in
            (
                SELECT TLTXCD FROM (select trim(regexp_substr(VARVALUE,'[^,]+', 1, level)) TLTXCD
                from (select p_list_tltxcd VARVALUE from dual)
                connect by regexp_substr(VARVALUE, '[^,]+', 1, level) is not NULL)
            )
        order by autoid desc
    ) loop
--        plog.error ('rec.tltxcd:'|| rec.tltxcd);
        IF rec.tltxcd='8851' THEN
            begin
                if txpks_#8851.fn_txrevert(rec.txnum,rec.txdate,p_err_code,p_err_param) <> 0 then
                    p_err_param := p_err_param || '-TRAN 8851';
                    plog.error (pkgctx, p_err_param);
                    plog.error (pkgctx, dbms_utility.format_error_backtrace);
                    plog.setendsection(pkgctx, 'pr_revert_transautosettle');
                    return;
                end if;
            end;
        ELSIF rec.tltxcd='0066' THEN
            begin
                if txpks_#0066.fn_txrevert(rec.txnum,rec.txdate,p_err_code,p_err_param) <> 0 then
                    p_err_param := p_err_param || '-TRAN 0066';
                    plog.error (pkgctx, p_err_param);
                    plog.error (pkgctx, dbms_utility.format_error_backtrace);
                    plog.setendsection(pkgctx, 'pr_revert_transautosettle');
                    return;
                end if;
            end;
        ELSIF rec.tltxcd='8866' THEN
            begin
--            plog.error (pkgctx, '8866');
                if txpks_#8866.fn_txrevert(rec.txnum,rec.txdate,p_err_code,p_err_param) <> 0 then
                    p_err_param := p_err_param || '-TRAN 8866';
                    plog.error (pkgctx, p_err_param);
                    plog.error (pkgctx, dbms_utility.format_error_backtrace);
                    plog.setendsection(pkgctx, 'pr_revert_transautosettle');
                    return;
                end if;
            end;
        ELSIF rec.tltxcd='8856' THEN
            begin
                if txpks_#8856.fn_txrevert(rec.txnum,rec.txdate,p_err_code,p_err_param) <> 0 then
                    p_err_param := p_err_param || '-TRAN 8856';
                    plog.error (pkgctx, p_err_param);
                    plog.error (pkgctx, dbms_utility.format_error_backtrace);
                    plog.setendsection(pkgctx, 'pr_revert_transautosettle');
                    return;
                end if;
            end;
        ELSIF rec.tltxcd='2661' THEN
            begin
                if txpks_#2661.fn_txrevert(rec.txnum,rec.txdate,p_err_code,p_err_param) <> 0 then
                    p_err_param := p_err_param || '-TRAN 2661';
                    plog.error (pkgctx, p_err_param);
                    plog.error (pkgctx, dbms_utility.format_error_backtrace);
                    plog.setendsection(pkgctx, 'pr_revert_transautosettle');
                    return;
                end if;
            end;
        ELSIF rec.tltxcd='8868' THEN
            begin
                if txpks_#8868.fn_txrevert(rec.txnum,rec.txdate,p_err_code,p_err_param) <> 0 then
                    p_err_param := p_err_param || '-TRAN 8868';
                    plog.error (pkgctx, p_err_param);
                    plog.error (pkgctx, dbms_utility.format_error_backtrace);
                    plog.setendsection(pkgctx, 'pr_revert_transautosettle');
                    return;
                end if;
            end;
        END IF;
    end loop;
    p_err_code:=0;
    plog.setendsection(pkgctx, 'pr_revert_transautosettle');
EXCEPTION
WHEN OTHERS
THEN
  p_err_code := errnums.C_SYSTEM_ERROR;
  plog.error (pkgctx, dbms_utility.format_error_backtrace);
  plog.error (pkgctx, SQLERRM);
  plog.setendsection (pkgctx, 'pr_revert_transautosettle');
  RAISE errnums.E_SYSTEM_ERROR;
END pr_revert_transautosettle;
/
