SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE pr_batch_auto_check(p_batchtype in varchar2, p_batchDate in date, p_bchmdl in varchar2, p_err_code in out varchar2, p_err_desc in out varchar2)
    --p_batchtype = BF batch giua ngay
    --p_batchtype = AF batch cuoi ngay
is
    pkgctx   plog.log_ctx;
    logrow   tlogdebug%ROWTYPE;
    l_SQLERRM       varchar2(2000);
    l_strBatchDate  date;
    l_count         number;
    l_HOSTATUS      varchar2(5);
    l_CMDID         varchar2(20);
begin
    pkgctx    :=  plog.init ('pr_batch_auto_check',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
    plog.setbeginsection (pkgctx, 'pr_batch_auto_check');
    l_strBatchDate  :=  to_char(p_batchDate, systemnums.C_DATE_FORMAT);

    if p_batchtype = 'BF' then
        l_CMDID := '011009';
    else
        l_CMDID := '011005';
    end if;
    --Check he thong co dang batch tren may khac khong
    SELECT count(*) into l_count
    FROM BATCHLOG
    WHERE ISACTIVE = 'Y' AND cmdid = l_CMDID AND (serverdate = p_batchDate OR txdate = p_batchDate)
        AND TLID <> systemnums.C_SYSTEM_USERID;
    IF l_count > 0 THEN
        p_err_code := '-1';
        p_err_desc := 'BatchAuto ngay: '||l_strBatchDate||'. He thong dang Batch tren 1 may khac.';
        plog.setendsection (pkgctx, 'pr_batch_auto_check');
        RETURN;
    END IF;

    --Check giao dich
    SELECT count(*) into l_count FROM TLLOG WHERE deltd <> 'Y' and txstatus in ('4','7','3');
    IF l_count > 0 THEN
        p_err_code := '-100148';
        p_err_desc := 'BatchAuto ngay: '||l_strBatchDate||'. Con GD chua duoc Duyet.';
        plog.setendsection (pkgctx, 'pr_batch_auto_check');
        RETURN;
    END IF;

    IF nvl(p_batchtype,'AF')<>'BF' THEN
        --Check dong cua chi nhanh
        SELECT count(*) into l_count
        FROM brgrp
        WHERE STATUS = 'A';
        IF l_count > 0 THEN
            p_err_code := '-100029';
            p_err_desc := 'BatchAuto ngay: '||l_strBatchDate||'. Van con chi nhanh dang hoat dong.';
            plog.setendsection (pkgctx, 'pr_batch_auto_check');
            RETURN;
        END IF;

        --Check dong cua hoi so
        SELECT varvalue into l_HOSTATUS
        FROM SYSVAR
        WHERE grname='SYSTEM' AND varname = 'HOSTATUS';
        IF l_HOSTATUS <> '0' THEN
            p_err_code := '-100022';
            p_err_desc := 'BatchAuto ngay: '||l_strBatchDate||'. Hoi so van dang hoat dong.';
            plog.setendsection (pkgctx, 'pr_batch_auto_check');
            RETURN;
        END IF;
    END IF;

    p_err_code  := systemnums.C_SUCCESS;
    plog.error(pkgctx,'End BatchAuto ngay: '||l_strBatchDate);
    plog.setendsection (pkgctx, 'pr_batch_auto_check');
    RETURN;
exception when others then
    rollback;
    l_SQLERRM   := SQLERRM;
    plog.error (pkgctx, l_SQLERRM || dbms_utility.format_error_backtrace);
    p_err_code  := errnums.C_SYSTEM_ERROR;
    p_err_desc  := '[-1] Loi he thong: '||l_SQLERRM;
    plog.setendsection (pkgctx, 'pr_batch_auto_check');

    return;
end;
 
/
