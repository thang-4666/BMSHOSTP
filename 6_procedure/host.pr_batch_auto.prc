SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE pr_batch_auto(p_batchtype in varchar2, p_bchmdl in varchar2)
    --p_batchtype = BF batch giua ngay
    --p_batchtype = AF batch cuoi ngay
is
    pkgctx   plog.log_ctx;
    logrow   tlogdebug%ROWTYPE;
    l_SQLERRM       varchar2(2000);
    l_errdesc       varchar2(4000);
    l_prevdate      date;
    l_currdate      date;
    l_nextdate      date;
    l_batchStatus   varchar2(2);
    l_batchDate     date;
    l_strBatchDate  date;
    l_count         number;
    p_err_code      varchar2(200);
    p_lastRun       varchar2(100);
    l_BCHSTS        varchar2(5);
    l_HOSTATUS      varchar2(20);
    l_batchtype     varchar2(20);
    l_varbatchsts   varchar2(100);
    l_CMDID         varchar2(20);
    v_string        varchar2(4000);
    l_bchmdl        varchar2(500);
begin
    pkgctx    :=  plog.init ('pr_Batch_Auto',
                    plevel => NVL(logrow.loglevel,30),
                    plogtable => (NVL(logrow.log4table,'N') = 'Y'),
                    palert => (NVL(logrow.log4alert,'N') = 'Y'),
                    ptrace => (NVL(logrow.log4trace,'N') = 'Y')
            );
    plog.setbeginsection (pkgctx, 'pr_Batch_Auto');

    if upper(trim(p_batchtype)) = 'BF' then
        l_batchtype := 'BF';
        l_varbatchsts   := 'AUTOBATCHBF_STATUS';
        l_CMDID := '011009';
    else
        l_batchtype := '%';
        l_varbatchsts   := 'AUTOBATCH_STATUS';
        l_CMDID := '011005';
    end if;

    l_bchmdl    := upper(trim(p_bchmdl));

    select max(decode(varname,'PREVDATE',to_date(varvalue,systemnums.C_DATE_FORMAT),null)) prevdate,
        max(decode(varname,'CURRDATE',to_date(varvalue,systemnums.C_DATE_FORMAT),null)) currdate,
        max(decode(varname,'NEXTDATE',to_date(varvalue,systemnums.C_DATE_FORMAT),null)) nextdate,
        max(decode(varname,l_varbatchsts,varvalue,'')) batchsts
        into l_prevdate, l_currdate, l_nextdate, l_batchStatus
    from sysvar
    where varname in ('PREVDATE','CURRDATE',l_varbatchsts,'NEXTDATE') and grname = 'SYSTEM';

    IF upper(trim(nvl(l_batchStatus,'X'))) = 'A' then --Neu trang thai la bat dau batch thi moi Thuc hien

        select count(*) into l_count from sbbatchsts where bchdate = l_prevdate and nvl(bchsts,'N')<> 'Y';
        if l_count > 0 then
            l_batchDate := l_prevdate;
        else
            l_batchDate := l_currdate;
        end if;
        l_strBatchDate  := to_char(l_batchDate, systemnums.C_DATE_FORMAT);

        -----------CHECK TRUOC BATCH--------------------
        l_errdesc:= '';
        pr_batch_auto_check(p_batchtype, l_batchDate, l_bchmdl, p_err_code , l_errdesc);
        IF p_err_code <> systemnums.C_SUCCESS THEN
            UPDATE SYSVAR SET VARVALUE = 'E' WHERE VARNAME = l_varbatchsts AND GRNAME = 'SYSTEM'; --chuyen trang thai dang batch
            UPDATE SYSVAR SET VARVALUE = l_errdesc WHERE VARNAME = 'AUTOBATCH_NOTE' AND GRNAME = 'SYSTEM';

            FOR recmb IN
            (
                    SELECT * FROM
                         (select trim(regexp_substr(VARVALUE,'[^,]+', 1, level)) phone
                         from (SELECT varvalue FROM sysvar WHERE varname = 'BATCHREMINDER' )
                         connect by regexp_substr(VARVALUE, '[^,]+', 1, level) is not NULL) a
            )
            LOOP
                v_string:= 'select '''|| l_errdesc || ''' detail from dual';
                nmpks_ems.InsertEmailLog(recmb.phone , '0305', v_string,'');
            END LOOP;
            COMMIT;
            plog.setendsection (pkgctx, 'pr_Batch_Auto');
            RETURN;
        END IF;

        --------END CHECK TRUOC BATCH-------------------


        -------------TIEN HANH BATCH-----------------------
        plog.error(pkgctx,'Begin BatchAuto ngay: '||l_strBatchDate||', buoc batch: '||l_bchmdl);
        IF l_bchmdl = 'ALL' THEN --Neu batch tung ALL buoc

            UPDATE SYSVAR SET VARVALUE = 'P' WHERE VARNAME = l_varbatchsts AND GRNAME = 'SYSTEM'; --chuyen trang thai dang batch
            UPDATE SYSVAR SET VARVALUE = 'Bat dau Batch tu dong ngay: '||l_strBatchDate WHERE VARNAME = 'AUTOBATCH_NOTE' AND GRNAME = 'SYSTEM';

            FOR recmb IN
                (
                        SELECT * FROM
                             (select trim(regexp_substr(VARVALUE,'[^,]+', 1, level)) phone
                             from (SELECT varvalue FROM sysvar WHERE varname = 'BATCHREMINDER' )
                             connect by regexp_substr(VARVALUE, '[^,]+', 1, level) is not NULL) a
                )
                LOOP
                    v_string:= 'select '''|| 'BatchAuto ngay '||l_strBatchDate||': He thong bat dau tien hanh Xu ly'||case when l_batchtype='BF' then ' truoc' else '' end || ' cuoi ngay'' detail from dual';
                    nmpks_ems.InsertEmailLog(recmb.phone , '0305', v_string,'');
                END LOOP;
            COMMIT;

            --Log du lieu bang BATCHLOG
            txpks_batch.PR_BATCHLOG_DOING('I',l_CMDID,sys_context('USERENV', 'IP_ADDRESS', 15),l_batchDate,systemnums.C_SYSTEM_USERID,'SystemUser','Auto', p_err_code);
            IF p_err_code <> systemnums.C_SUCCESS THEN
                UPDATE SYSVAR SET VARVALUE = 'E' WHERE VARNAME = l_varbatchsts AND GRNAME = 'SYSTEM'; --chuyen trang thai dang batch
                UPDATE SYSVAR SET VARVALUE = 'Batch ngay: '||l_strBatchDate||'. Error '||p_err_code||': '||cspks_system.fn_get_errmsg(p_err_code)
                WHERE VARNAME = 'AUTOBATCH_NOTE' AND GRNAME = 'SYSTEM';
                plog.error(pkgctx,'Error '||p_err_code||'. call PR_BATCHLOG_DOING');
                COMMIT;
                plog.setendsection (pkgctx, 'pr_Batch_Auto');
                RETURN;
            END IF;

            --Neu chua co du lieu Lich batch gen du lieu chay batch
            SELECT COUNT(*) into l_count FROM SBBATCHSTS WHERE BCHDATE = l_batchDate;
            IF l_count = 0 THEN
                IF  TO_CHAR(l_currdate,'RRRR') <> TO_CHAR(l_nextdate,'RRRR') THEN
                    --Neu la cuoi nam
                    INSERT INTO SBBATCHSTS (BCHDATE,BCHMDL,BCHSTS,CMPLTIME,ROWPERPAGE,BCHSUCPAGE)
                        SELECT l_batchDate BCHDATE, BCHMDL, ' ' BCHSTS, '' CMPLTIME, ROWPERPAGE,0 BCHSUCPAGE
                        FROM SBBATCHCTL
                        WHERE STATUS = 'Y'
                        ORDER BY BCHSQN;
                    COMMIT;
                ELSIF TO_CHAR(l_currdate,'MM') <> TO_CHAR(l_nextdate,'MM') THEN
                    --Neu la cuoi thang
                    INSERT INTO SBBATCHSTS (BCHDATE,BCHMDL,BCHSTS,CMPLTIME,ROWPERPAGE,BCHSUCPAGE)
                        SELECT l_batchDate BCHDATE, BCHMDL, ' ' BCHSTS, '' CMPLTIME, ROWPERPAGE,0 BCHSUCPAGE
                        FROM SBBATCHCTL
                        WHERE STATUS = 'Y' AND UPPER(RUNAT) <> 'EOY'
                        ORDER BY BCHSQN;
                    COMMIT;
                ELSE
                    --Neu la ngay lam viec binh thuong
                    INSERT INTO SBBATCHSTS (BCHDATE,BCHMDL,BCHSTS,CMPLTIME,ROWPERPAGE,BCHSUCPAGE)
                        SELECT l_batchDate BCHDATE, BCHMDL, ' ' BCHSTS, '' CMPLTIME, ROWPERPAGE,0 BCHSUCPAGE
                        FROM SBBATCHCTL
                        WHERE STATUS = 'Y' AND UPPER(RUNAT) <> 'EOY' AND UPPER(RUNAT) <> 'EOM'
                        ORDER BY BCHSQN;
                    COMMIT;
                END IF;
            END IF;

            FOR REC IN (
                SELECT CT.BCHSQN,CT.APPTYPE, CT.RUNMOD, STS.*, CT.BCHTITLE
                FROM SBBATCHSTS STS, SBBATCHCTL CT
                WHERE STS.BCHMDL = CT.BCHMDL  AND STS.BCHSTS <> 'Y'
                    AND STS.BCHDATE = L_BATCHDATE
                    and nvl(ct.action,'AF') like l_batchtype
                ORDER BY CT.BCHSQN
            ) LOOP
                --Kiem tra tuan tu buoc batch
                select count(1) into l_count from (
                    select * from (
                        select sts.bchmdl, ctl.bchsqn
                        from sbbatchsts sts, sbbatchctl ctl
                        where sts.bchdate = l_batchDate
                        and sts.bchmdl = ctl.bchmdl and ctl.status = 'Y' and sts.bchsts <> 'Y' and sts.cmpltime is null
                        order by bchsqn
                    )
                    where rownum = 1
                )
                where bchmdl = rec.BCHMDL;
                IF l_count = 0 THEN
                    UPDATE SYSVAR SET VARVALUE = 'E' WHERE VARNAME = l_varbatchsts AND GRNAME = 'SYSTEM'; --chuyen trang thai dang batch
                    UPDATE SYSVAR SET VARVALUE = 'Batch ngay: '||l_strBatchDate||'. Buoc batch phai xu ly tuan tu. Loi tai buoc Batch: '||rec.bchmdl
                    WHERE VARNAME = 'AUTOBATCH_NOTE' AND GRNAME = 'SYSTEM';
                    COMMIT;
                    plog.setendsection (pkgctx, 'pr_Batch_Auto');
                    FOR recmb IN
                            (
                                    SELECT * FROM
                                         (select trim(regexp_substr(VARVALUE,'[^,]+', 1, level)) phone
                                         from (SELECT varvalue FROM sysvar WHERE varname = 'BATCHREMINDER' )
                                         connect by regexp_substr(VARVALUE, '[^,]+', 1, level) is not NULL) a
                            )
                            LOOP
                                v_string:= 'select '''|| 'BatchAuto ngay '||l_strBatchDate||': Buoc batch phai xu ly tuan tu. Loi buoc Batch: '||rec.bchmdl|| ' '' detail from dual';
                                nmpks_ems.InsertEmailLog(recmb.phone , '0305', v_string,'');
                            END LOOP;
                    RETURN;
                END IF;
                IF REC.RUNMOD = 'DB' THEN
                    --Thuc thi buoc batch
                    SELECT MIN(BCHSTS) INTO l_BCHSTS FROM SBBATCHSTS WHERE bchdate = l_batchDate AND bchmdl = REC.bchmdl;
                    WHILE NVL(l_BCHSTS,'Y') <> 'Y' LOOP
                        TXPKS_BATCH.PR_BATCH(rec.APPTYPE, rec.bchmdl, p_err_code, p_lastRun);
                        IF p_err_code <> systemnums.C_SUCCESS THEN
                            ROLLBACK;
                            UPDATE SYSVAR SET VARVALUE = 'E' WHERE VARNAME = l_varbatchsts AND GRNAME = 'SYSTEM'; --chuyen trang thai dang batch
                            UPDATE SYSVAR SET VARVALUE = 'Batch ngay: '||l_strBatchDate||'. Error '||p_err_code||/*': '||cspks_system.fn_get_errmsg(p_err_code)||*/'. Loi tai buoc Batch: '||rec.bchmdl
                            WHERE VARNAME = 'AUTOBATCH_NOTE' AND GRNAME = 'SYSTEM';
                            plog.error(pkgctx,'Error '||p_err_code||'. call PR_BATCH: '||rec.bchmdl);
                            FOR recmb IN
                            (
                                    SELECT * FROM
                                         (select trim(regexp_substr(VARVALUE,'[^,]+', 1, level)) phone
                                         from (SELECT varvalue FROM sysvar WHERE varname = 'BATCHREMINDER' )
                                         connect by regexp_substr(VARVALUE, '[^,]+', 1, level) is not NULL) a
                            )
                            LOOP
                                v_string:= 'select '''|| 'BatchAuto ngay '||l_strBatchDate||': Loi buoc Batch: '||rec.bchmdl||'. '||cspks_system.fn_get_errmsg(p_err_code)|| ' '' detail from dual';
                                nmpks_ems.InsertEmailLog(recmb.phone , '0305', v_string,'');
                            END LOOP;
                            COMMIT;
                            plog.setendsection (pkgctx, 'pr_Batch_Auto');
                            RETURN;
                        ELSE
                            COMMIT;
                            SELECT MIN(BCHSTS) INTO l_BCHSTS FROM SBBATCHSTS WHERE bchdate = l_batchDate AND bchmdl = REC.bchmdl;
                        END IF;
                    END LOOP;
                ELSE --NEU RUNMOD = NET TAM THOI BO QUA BUOC BATCH NAY
                    UPDATE SBBATCHSTS SET BCHSTS = 'Y' WHERE bchdate = l_batchDate AND bchmdl = REC.bchmdl;
                    COMMIT;
                END IF;

            END LOOP;



            UPDATE SYSVAR SET VARVALUE = 'C' WHERE VARNAME = l_varbatchsts AND GRNAME = 'SYSTEM'; --update trang thai loi
            UPDATE SYSVAR SET VARVALUE = 'Hoan thanh' WHERE VARNAME = 'AUTOBATCH_NOTE' AND GRNAME = 'SYSTEM';
            FOR recmb IN
                (
                        SELECT * FROM
                             (select trim(regexp_substr(VARVALUE,'[^,]+', 1, level)) phone
                             from (SELECT varvalue FROM sysvar WHERE varname = 'BATCHREMINDER' )
                             connect by regexp_substr(VARVALUE, '[^,]+', 1, level) is not NULL) a
                )
                LOOP
                    v_string:= 'select '''|| 'BatchAuto ngay '||l_strBatchDate||': Xu ly'||case when l_batchtype='BF' then ' truoc' else '' end || ' cuoi ngay thanh cong'' detail from dual';
                    nmpks_ems.InsertEmailLog(recmb.phone , '0305', v_string,'');
                END LOOP;
            COMMIT;
            plog.error(pkgctx,'End BatchAuto ngay: '||l_strBatchDate||', buoc batch: '||l_bchmdl);
        ELSE --Neu batch tung buoc
            plog.error(pkgctx,'Begin BatchAuto ngay: '||l_strBatchDate||', buoc batch: '||l_bchmdl);


            plog.error(pkgctx,'End BatchAuto ngay: '||l_strBatchDate||', buoc batch: '||l_bchmdl);
        END IF;


    END IF;
    ----------END TIEN HANH BATCH----------------------

    plog.setendsection (pkgctx, 'pr_Batch_Auto');
exception when others then
    rollback;
    l_SQLERRM   := SQLERRM;
    plog.error (pkgctx, 'BatchType: '||p_batchtype||', BchMdl: '||p_bchmdl||', Error: '||l_SQLERRM || dbms_utility.format_error_backtrace);

    UPDATE SYSVAR SET VARVALUE = 'E' WHERE VARNAME = nvl(l_varbatchsts,'AUTOBATCH_STATUS') AND GRNAME = 'SYSTEM'; --update trang thai loi
    UPDATE SYSVAR SET VARVALUE = '[-1] Loi he thong: '||l_SQLERRM WHERE VARNAME = 'AUTOBATCH_NOTE' AND GRNAME = 'SYSTEM';
    COMMIT;
    plog.setendsection (pkgctx, 'pr_Batch_Auto');



    return;
end;
 
/
