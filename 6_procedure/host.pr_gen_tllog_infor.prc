SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE pr_gen_tllog_infor
is
    v_custodycd varchar2(100);
    v_fullname varchar2(100);
    v_ccycd varchar2(100);
    v_cfcustodycd varchar2(100);
    v_cffullname varchar2(100);
    v_cfccycd varchar2(100);
    v_msgacct varchar2(100);
    v_err varchar2(500);
    v_defname varchar2(100);
begin
v_fullname:='';
v_custodycd:='';
for rec in (
    select * from tllog
)
loop
    select cfcustodycd, cffullname,ccycd, msg_acct into v_cfcustodycd,v_cffullname,v_cfccycd, v_msgacct from tltx where tltxcd =rec.tltxcd;
    begin
        if v_cfcustodycd <> '##' then
            select replace (cvalue,'.','') into v_custodycd from tllogfld where txnum=rec.txnum and txdate = rec.txdate and fldcd=v_cfcustodycd;
            update tllog set cfcustodycd= v_custodycd where txnum=rec.txnum and txdate = rec.txdate;
        end if;
    exception when others then
        v_custodycd:='';
    end;
    begin
        if v_cffullname <> '##' then
            select replace (cvalue,'.','') into v_fullname from tllogfld where txnum=rec.txnum and txdate = rec.txdate and fldcd=v_cffullname;
            update tllog set cffullname= v_fullname where txnum=rec.txnum and txdate = rec.txdate;
        end if;
    exception when others then
        v_fullname:='';
    end;
    begin
        if v_cfccycd <> '##' then
            select replace (cvalue,'.','') into v_ccycd from tllogfld where txnum=rec.txnum and txdate = rec.txdate and fldcd=v_cfccycd;
            update tllog set ccyusage= v_ccycd where txnum=rec.txnum and txdate = rec.txdate;
        end if;
    exception when others then
        v_ccycd:='';
    end;

    if v_cfcustodycd = '##' or v_cffullname = '##' or v_custodycd ='' or v_fullname ='' then
        for rec_print in (
            SELECT DISTINCT APPTYPE, TBLNAME, FLDKEY, ACFLD, ISRUN
                    FROM V_APPCHK_BY_TLTXCD V WHERE V.TLTXCD = rec.tltxcd and ACFLD= v_msgacct
                    and tblname in ('SEMAST','REMAST','AFMAST','LNMAST','LNAPPL','LMMAST','CLMAST','GRMAST','CFMAST','CIMAST','TDMAST','ODMAST')
        )
        loop

            begin
                if rec_print.tblname ='AFMAST' then
                    SELECT CFMAST.FULLNAME,  CFMAST.CUSTODYCD
                        into v_fullname, v_custodycd
                        FROM CFMAST, AFMAST MST
                        WHERE CFMAST.CUSTID = MST.CUSTID AND
                        MST.ACCTNO =rec.msgacct;
                elsif rec_print.tblname ='CIMAST' then
                    SELECT CFMAST.FULLNAME,  CFMAST.CUSTODYCD
                        into v_fullname, v_custodycd
                        FROM CFMAST, CIMAST MST
                        WHERE CFMAST.CUSTID = MST.CUSTID AND
                        MST.ACCTNO =rec.msgacct;
                elsif rec_print.tblname ='SEMAST' then
                    SELECT CFMAST.FULLNAME,  CFMAST.CUSTODYCD
                        into v_fullname, v_custodycd
                        FROM CFMAST, SEMAST MST
                        WHERE CFMAST.CUSTID = MST.CUSTID AND
                        MST.ACCTNO =rec.msgacct;
                elsif rec_print.tblname ='LNMAST' then
                    SELECT CFMAST.FULLNAME, CFMAST.CUSTODYCD
                         into v_fullname, v_custodycd
                         FROM CFMAST, CIMAST, LNMAST MST
                         WHERE CFMAST.CUSTID = CIMAST.CUSTID AND CIMAST.ACCTNO=MST.TRFACCTNO AND
                         MST.ACCTNO =rec.msgacct;
                elsif rec_print.tblname ='REMAST' then
                    SELECT CFMAST.FULLNAME, CFMAST.CUSTODYCD
                        into v_fullname, v_custodycd
                         FROM CFMAST, REMAST MST
                         WHERE CFMAST.CUSTID = MST.CUSTID AND
                         MST.ACCTNO =rec.msgacct;

                elsif rec_print.tblname in ('CLMAST') then
                    SELECT CFMAST.FULLNAME, CFMAST.CUSTODYCD
                        into v_fullname, v_custodycd
                         FROM CFMAST, CLMAST MST
                         WHERE CFMAST.CUSTID = MST.CUSTID AND
                         MST.ACCTNO =rec.msgacct;
                elsif rec_print.tblname in ('GRMAST') then
                    SELECT CFMAST.FULLNAME, CFMAST.CUSTODYCD
                        into v_fullname, v_custodycd
                         FROM CFMAST, GRMAST MST
                         WHERE CFMAST.CUSTID = MST.CUSTID AND
                         MST.ACCTNO =rec.msgacct;
                elsif rec_print.tblname in ('CFMAST') then
                    SELECT CFMAST.FULLNAME, CFMAST.CUSTODYCD
                        into v_fullname, v_custodycd
                         FROM CFMAST
                         where custid =rec.msgacct;
                elsif rec_print.tblname in ('TDMAST') then
                    SELECT CFMAST.FULLNAME CUSTNAME,CFMAST.CUSTODYCD
                        into v_fullname, v_custodycd
                         FROM CFMAST, AFMAST, TDMAST mst
                         WHERE CFMAST.CUSTID = AFMAST.CUSTID AND AFMAST.ACCTNO=MST.AFACCTNO
                         AND MST.acctno =rec.msgacct;
                elsif rec_print.tblname in ('ODMAST') then
                    SELECT CFMAST.FULLNAME CUSTNAME,CFMAST.CUSTODYCD
                        into v_fullname, v_custodycd
                         FROM CFMAST, AFMAST, odmast mst
                         WHERE CFMAST.CUSTID = AFMAST.CUSTID AND AFMAST.ACCTNO=MST.AFACCTNO
                         AND MST.orderid =rec.msgacct;
                else
                    v_fullname:='';
                    v_custodycd:='';
                end if;
                if v_cffullname='##' and v_cfcustodycd='##' then
                    update tllog set cfcustodycd= v_custodycd,cffullname= v_fullname where txnum=rec.txnum and txdate = rec.txdate;
                else
                    if v_cfcustodycd='##' then
                        update tllog set cfcustodycd= v_custodycd where txnum=rec.txnum and txdate = rec.txdate;
                    end if;
                    if v_cffullname='##' then
                        update tllog set cffullname= v_fullname where txnum=rec.txnum and txdate = rec.txdate;
                    end if;
                end if;
            exception when others then
                v_fullname:='';
                v_custodycd:='';
                v_err:=substr(dbms_utility.format_error_backtrace || ' - ' || sqlerrm,1,199);
                --INSERT INTO log_err (id,date_log, POSITION, text)
                --    VALUES ( seq_log_err.NEXTVAL,SYSDATE, ' pr_gen_tllog_infor ', v_err);

            end;
        end loop;
        begin
            if v_fullname ='' or v_custodycd ='' or v_fullname is null or v_custodycd is null then
                select defname into v_defname from fldmaster where objname =rec.tltxcd and fldname=v_msgacct;
                if v_defname in ('CIACCTNO','ACCTNO','AFACCTNO','SEACCTNO') and LENGTH(replace(rec.msgacct,'.','')) >=10 then
                    SELECT CFMAST.FULLNAME,  CFMAST.CUSTODYCD
                            into v_fullname, v_custodycd
                            FROM CFMAST, AFMAST MST
                            WHERE CFMAST.CUSTID = MST.CUSTID AND
                            MST.ACCTNO =substr(replace(rec.msgacct,'.',''),1,10);
                elsif v_defname in ('CUSTID') then
                    SELECT CFMAST.FULLNAME, CFMAST.CUSTODYCD
                            into v_fullname, v_custodycd
                             FROM CFMAST
                             where custid =substr(replace(rec.msgacct,'.',''),1,10);
                end if;
                update tllog set cfcustodycd= v_custodycd,cffullname= v_fullname where txnum=rec.txnum and txdate = rec.txdate;
            end if;
        exception when others then
            v_err:=substr(dbms_utility.format_error_backtrace || ' - ' || sqlerrm,1,199);
            --INSERT INTO log_err (id,date_log, POSITION, text)
            --    VALUES ( seq_log_err.NEXTVAL,SYSDATE, ' pr_gen_tllog_infor ', v_err);

        end;
    end if;
end loop;
exception when others then
    v_err:=substr(dbms_utility.format_error_backtrace || ' - ' || sqlerrm,1,199);
     --INSERT INTO log_err (id,date_log, POSITION, text)
     --    VALUES ( seq_log_err.NEXTVAL,SYSDATE, ' pr_gen_tllog_infor ', v_err);

end;

 
 
 
 
 
 
 
 
 
 
 
 
 
/
