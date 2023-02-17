SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE pr_processafterreject(p_tlid  varchar2, p_ATTR_TABLE varchar2, p_strClause varchar2,p_err_code in out varchar2)
is
    v_currdate          date;

    V_STRSQL            varchar2(500);
    V_STRSQL_update     varchar2(500);
    v_data_type         varchar2(30);
    v_strClause         varchar2(100);
    V_count             number(10);
    pkgctx plog.log_ctx;
begin
    v_strClause := REPLACE(p_strClause,'=','_');
    v_strClause := REPLACE(v_strClause,'''','_');
    plog.error (pkgctx, 'p_tlid = ' || p_tlid || ' p_ATTR_TABLE = ' || p_ATTR_TABLE || ' p_strClause = ' || p_strClause);
    for rec in
    (
        SELECT TABLE_NAME, RECORD_KEY, COLUMN_NAME, FROM_VALUE, TO_VALUE, ACTION_FLAG,
            CHILD_TABLE_NAME, CHILD_RECORD_KEY, MAKER_TIME
        FROM MAINTAIN_LOG
        WHERE TABLE_NAME = P_ATTR_TABLE
            AND APPROVE_ID IS NULL AND APPROVE_DT IS NULL AND APPROVE_TIME IS NULL
            AND RECORD_KEY like v_strClause
        ORDER BY MAKER_TIME DESC
    )
    LOOP
        V_STRSQL := '';
        IF REC.ACTION_FLAG = 'ADD' THEN
            if rec.child_table_name is not null then
                V_STRSQL := 'DELETE FROM ' || REC.CHILD_TABLE_NAME || ' WHERE ' || REC.CHILD_RECORD_KEY;
                EXECUTE IMMEDIATE V_STRSQL;

                 /*V_STRSQL_update := 'UPDATE MAINTAIN_LOG SET APPROVE_DT = TO_DATE(sysdate, ''DD/MM/RRRR''), APPROVE_ID = ''' || p_tlid || ''' ,
                approve_time = to_char(SYSDATE,''hh24:mi:ss'') WHERE TABLE_NAME = ''' || REC.TABLE_NAME ||
                ''' AND CHILD_TABLE_NAME = ''' || REC.CHILD_TABLE_NAME || ''' AND COLUMN_NAME = ''' || REC.COLUMN_NAME  || ''' AND ACTION_FLAG = ''ADD'' AND RECORD_KEY = ''' || Replace(REC.RECORD_KEY, '''', '''''') || ''' AND CHILD_RECORD_KEY = ''' || Replace(REC.CHILD_RECORD_KEY, '''', '''''') || ''' AND APPROVE_ID IS NULL AND APPROVE_TIME IS NULL ';*/
                V_STRSQL_update := 'DELETE FROM MAINTAIN_LOG  WHERE TABLE_NAME = ''' || REC.TABLE_NAME ||
                ''' AND CHILD_TABLE_NAME = ''' || REC.CHILD_TABLE_NAME || ''' AND COLUMN_NAME = ''' || REC.COLUMN_NAME  || ''' AND ACTION_FLAG = ''ADD'' AND RECORD_KEY = ''' || Replace(REC.RECORD_KEY, '''', '''''') || ''' AND CHILD_RECORD_KEY = ''' || Replace(REC.CHILD_RECORD_KEY, '''', '''''') || ''' AND APPROVE_ID IS NULL AND APPROVE_TIME IS NULL ';
                EXECUTE IMMEDIATE V_STRSQL_update;
            else
                V_STRSQL := 'DELETE FROM ' || REC.TABLE_NAME || ' WHERE ' || REC.RECORD_KEY;
                EXECUTE IMMEDIATE V_STRSQL;

                 /*V_STRSQL_update := 'UPDATE MAINTAIN_LOG SET APPROVE_DT = TO_DATE(sysdate, ''DD/MM/RRRR''), APPROVE_ID = ''' || p_tlid || ''' ,
                approve_time = to_char(SYSDATE,''hh24:mi:ss'') WHERE TABLE_NAME = ''' || REC.TABLE_NAME ||
                '''  AND COLUMN_NAME = ''' || REC.COLUMN_NAME  || ''' AND ACTION_FLAG = ''ADD'' AND RECORD_KEY = ''' || Replace(REC.RECORD_KEY, '''', '''''') || ''' AND APPROVE_ID IS NULL AND APPROVE_TIME IS NULL ';*/
                V_STRSQL_update := 'DELETE FROM MAINTAIN_LOG  WHERE TABLE_NAME = ''' || REC.TABLE_NAME ||
                '''  AND COLUMN_NAME = ''' || REC.COLUMN_NAME  || ''' AND ACTION_FLAG = ''ADD'' AND RECORD_KEY = ''' || Replace(REC.RECORD_KEY, '''', '''''') || ''' AND APPROVE_ID IS NULL AND APPROVE_TIME IS NULL ';
                EXECUTE IMMEDIATE V_STRSQL_update;
            end if;
            commit;
        ELSIF REC.ACTION_FLAG = 'EDIT' THEN
            if nvl(rec.from_value,'xxx') <> nvl(rec.to_value,'xxx') then
                if rec.child_table_name is null then
                    Select nvl(data_type,'VARCHAR2') into v_data_type
                    from user_tab_cols
                    where column_name = UPPER(REC.COLUMN_NAME) and table_name = UPPER(REC.TABLE_NAME);
                    IF (v_data_type = 'DATE') THEN
                        V_STRSQL := 'UPDATE ' || REC.TABLE_NAME || ' SET ' ||
                        REC.COLUMN_NAME || ' = TO_DATE (''' || REC.FROM_VALUE || ''',''DD/MM/RRRR'') WHERE ' || REC.RECORD_KEY;
                    ELSIF (v_data_type = 'VARCHAR2') THEN
                        V_STRSQL := 'UPDATE ' || REC.TABLE_NAME || ' SET ' ||
                        REC.COLUMN_NAME || ' = ''' || REC.FROM_VALUE || ''' WHERE ' || REC.RECORD_KEY;
                    ELSE
                        V_STRSQL := 'UPDATE ' || REC.TABLE_NAME || ' SET ' ||
                        REC.COLUMN_NAME || ' = ' || REC.FROM_VALUE || ' WHERE ' || REC.RECORD_KEY;
                    END IF;
                    EXECUTE IMMEDIATE V_STRSQL;
                    /*V_STRSQL_update := 'UPDATE MAINTAIN_LOG SET APPROVE_DT = TO_DATE(sysdate, ''DD/MM/RRRR''), APPROVE_ID = ''' || p_tlid || ''' ,
                    approve_time = to_char(SYSDATE,''hh24:mi:ss'') WHERE TABLE_NAME = ''' || REC.TABLE_NAME ||
                    ''' AND RECORD_KEY = ''' || Replace(REC.RECORD_KEY, '''', '''''') || ''' AND COLUMN_NAME = ''' || REC.COLUMN_NAME  || ''' AND ACTION_FLAG = ''EDIT''  AND APPROVE_ID IS NULL AND APPROVE_TIME IS NULL ';*/
                    V_STRSQL_update := 'DELETE FROM MAINTAIN_LOG  WHERE TABLE_NAME = ''' || REC.TABLE_NAME ||
                    ''' AND RECORD_KEY = ''' || Replace(REC.RECORD_KEY, '''', '''''') || ''' AND COLUMN_NAME = ''' || REC.COLUMN_NAME  || ''' AND ACTION_FLAG = ''EDIT''  AND APPROVE_ID IS NULL AND APPROVE_TIME IS NULL ';
                    EXECUTE IMMEDIATE V_STRSQL_update;
                else
                    Select nvl(data_type,'VARCHAR2') into v_data_type
                    from user_tab_cols
                    where column_name = UPPER(REC.COLUMN_NAME) and table_name = UPPER(rec.child_table_name);
                    IF (v_data_type = 'DATE') THEN
                        V_STRSQL := 'UPDATE ' || rec.child_table_name || ' SET ' ||
                        REC.COLUMN_NAME || ' = TO_DATE (''' || REC.FROM_VALUE || ''',''DD/MM/RRRR'') WHERE ' || REC.CHILD_RECORD_KEY;
                    ELSIF (v_data_type = 'VARCHAR2') THEN
                        V_STRSQL := 'UPDATE ' || rec.child_table_name || ' SET ' ||
                        REC.COLUMN_NAME || ' = ''' || REC.FROM_VALUE || ''' WHERE ' || REC.CHILD_RECORD_KEY;
                    ELSE
                        V_STRSQL := 'UPDATE ' || rec.child_table_name || ' SET ' ||
                        REC.COLUMN_NAME || ' = ' || REC.FROM_VALUE || ' WHERE ' || REC.CHILD_RECORD_KEY;
                    END IF;
                    EXECUTE IMMEDIATE V_STRSQL;
                    /*V_STRSQL_update := 'UPDATE MAINTAIN_LOG SET APPROVE_DT = TO_DATE(sysdate, ''DD/MM/RRRR''), APPROVE_ID = ''' || p_tlid || ''' ,
                    approve_time = to_char(SYSDATE,''hh24:mi:ss'') WHERE TABLE_NAME = ''' || REC.TABLE_NAME ||
                    ''' AND CHILD_TABLE_NAME = ''' || REC.CHILD_TABLE_NAME || ''' AND COLUMN_NAME = ''' || REC.COLUMN_NAME  || ''' AND ACTION_FLAG = ''EDIT'' AND RECORD_KEY = ''' || Replace(REC.RECORD_KEY, '''', '''''') || ''' AND CHILD_RECORD_KEY = ''' || Replace(REC.CHILD_RECORD_KEY, '''', '''''') || ''' AND APPROVE_ID IS NULL AND APPROVE_TIME IS NULL ';*/
                    V_STRSQL_update := 'DELETE FROM MAINTAIN_LOG  WHERE TABLE_NAME = ''' || REC.TABLE_NAME ||
                    ''' AND RECORD_KEY = ''' || Replace(REC.RECORD_KEY, '''', '''''') || ''' AND COLUMN_NAME = ''' || REC.COLUMN_NAME  || ''' AND ACTION_FLAG = ''EDIT''  AND APPROVE_ID IS NULL AND APPROVE_TIME IS NULL ';
                    EXECUTE IMMEDIATE V_STRSQL_update;

                    Select count(*) into V_COUNT
                    from user_tab_cols
                    where column_name = 'CHSTATUS' and table_name = UPPER(rec.child_table_name);
                    if V_COUNT > 0 then
                        V_STRSQL_update := 'UPDATE ' || rec.child_table_name || ' SET CHSTATUS = ''C''  WHERE ' || REC.CHILD_RECORD_KEY;
                        EXECUTE IMMEDIATE V_STRSQL_update;
                    end if;
                end if;
                COMMIT;
            end if;
        ELSIF REC.ACTION_FLAG = 'DELETE' THEN
            if rec.child_table_name is not null then
                SELECT COUNT(TABLE_NAME) INTO V_COUNT FROM USER_TABLES WHERE TABLE_NAME = REC.CHILD_TABLE_NAME || 'MEMO';
                if V_COUNT > 0 then
                    V_STRSQL := 'DELETE FROM ' || REC.CHILD_TABLE_NAME || ' WHERE ' || REC.CHILD_RECORD_KEY || ' AND (SELECT count(*) FROM ' || REC.CHILD_TABLE_NAME || 'MEMO WHERE ' || REC.CHILD_RECORD_KEY || ' ) > 0';
                    EXECUTE IMMEDIATE V_STRSQL;
                    V_STRSQL := 'INSERT INTO ' || REC.CHILD_TABLE_NAME || ' (SELECT * FROM ' || REC.CHILD_TABLE_NAME || 'MEMO WHERE ' || REC.CHILD_RECORD_KEY || ' )';
                    EXECUTE IMMEDIATE V_STRSQL;
                    V_STRSQL := 'DELETE FROM ' || REC.CHILD_TABLE_NAME || 'MEMO WHERE ' || REC.CHILD_RECORD_KEY;
                    EXECUTE IMMEDIATE V_STRSQL;
                    /*V_STRSQL_update := 'UPDATE MAINTAIN_LOG SET APPROVE_DT = TO_DATE(sysdate, ''DD/MM/RRRR''), APPROVE_ID = ''' || p_tlid || ''' ,
                    approve_time = to_char(SYSDATE,''hh24:mi:ss'') WHERE TABLE_NAME = ''' || REC.TABLE_NAME ||
                    ''' AND CHILD_TABLE_NAME = ''' || REC.CHILD_TABLE_NAME || ''' AND ACTION_FLAG = ''DELETE'' AND RECORD_KEY = ''' || Replace(REC.RECORD_KEY, '''', '''''') || ''' AND CHILD_RECORD_KEY = ''' || Replace(REC.CHILD_RECORD_KEY, '''', '''''') || ''' AND APPROVE_ID IS NULL AND APPROVE_TIME IS NULL ';*/
                    V_STRSQL_update := 'DELETE FROM MAINTAIN_LOG  WHERE TABLE_NAME = ''' || REC.TABLE_NAME ||
                    ''' AND CHILD_TABLE_NAME = ''' || REC.CHILD_TABLE_NAME || ''' AND ACTION_FLAG = ''DELETE'' AND RECORD_KEY = ''' || Replace(REC.RECORD_KEY, '''', '''''') || ''' AND CHILD_RECORD_KEY = ''' || Replace(REC.CHILD_RECORD_KEY, '''', '''''') || ''' AND APPROVE_ID IS NULL AND APPROVE_TIME IS NULL ';
                    EXECUTE IMMEDIATE V_STRSQL_update;
                end if;
            else
                SELECT COUNT(TABLE_NAME) INTO V_COUNT FROM USER_TABLES WHERE TABLE_NAME = REC.TABLE_NAME || 'MEMO';
                if V_COUNT > 0 then
                    V_STRSQL := 'DELETE FROM ' || REC.TABLE_NAME || ' WHERE ' || REC.RECORD_KEY || ' AND (SELECT count(*) FROM ' || REC.TABLE_NAME || 'MEMO WHERE ' || REC.RECORD_KEY || ' ) > 0';
                    EXECUTE IMMEDIATE V_STRSQL;
                    V_STRSQL := 'INSERT INTO ' || REC.TABLE_NAME || ' (SELECT * FROM ' || REC.TABLE_NAME || 'MEMO WHERE ' || REC.RECORD_KEY || ' )';
                    EXECUTE IMMEDIATE V_STRSQL;
                    V_STRSQL := 'DELETE FROM ' || REC.TABLE_NAME || 'MEMO WHERE ' || REC.RECORD_KEY;
                    EXECUTE IMMEDIATE V_STRSQL;
                    /*V_STRSQL_update := 'UPDATE MAINTAIN_LOG SET APPROVE_DT = TO_DATE(sysdate, ''DD/MM/RRRR''), APPROVE_ID = ''' || p_tlid || ''' ,
                    approve_time = to_char(SYSDATE,''hh24:mi:ss'') WHERE TABLE_NAME = ''' || REC.TABLE_NAME ||
                    ''' AND ACTION_FLAG = ''DELETE'' AND RECORD_KEY = ''' || Replace(REC.RECORD_KEY, '''', '''''') || ''' AND APPROVE_ID IS NULL AND APPROVE_TIME IS NULL ';*/
                    V_STRSQL_update := 'DELETE FROM MAINTAIN_LOG  WHERE TABLE_NAME = ''' || REC.TABLE_NAME ||
                    ''' AND ACTION_FLAG = ''DELETE'' AND RECORD_KEY = ''' || Replace(REC.RECORD_KEY, '''', '''''') || ''' AND APPROVE_ID IS NULL AND APPROVE_TIME IS NULL ';
                    EXECUTE IMMEDIATE V_STRSQL_update;
                end if;
            end if;
            COMMIT;
        ELSE
           COMMIT;
        END IF;
    END LOOP;
    p_err_code := 0;
exception when others then
    plog.error (pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    p_err_code := -1;
    return;
end;

 
 
 
 
/
