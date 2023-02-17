SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE prc_maintainlog(
    p_strSQL IN VARCHAR2,
    p_ObjectName IN VARCHAR2,
    p_RecordKey IN VARCHAR2,
    p_RecordValue IN VARCHAR2,
    p_ChildObjectName IN VARCHAR2,
    p_ChildRecordKey IN VARCHAR2,
    p_ChildRecordValue IN VARCHAR2,
    p_tlid  IN VARCHAR2,
    p_action  IN VARCHAR2
)
IS
l_fldval            varchar2(1000);
l_count             NUMBER;
l_refcursor         pkg_report.ref_cursor;
v_desc_tab          dbms_sql.desc_tab;
v_cursor_number     NUMBER;
v_columns           NUMBER;
v_number_value      NUMBER;
v_varchar_value     VARCHAR(200);
v_date_value        DATE;
l_fldname           varchar2(100);
v_logSQL            varchar2(3000);
v_strObjectName     varchar2(1000);
v_strRecordKey      varchar2(1000);
v_strChildObjName   varchar2(1000);
v_strChildRecordKey varchar2(1000);
l_tlid              varchar2(1000) := p_tlid;
l_currdate          date;
l_modNum            NUMBER;
BEGIN
    --l_modNum    := 0;
    l_currdate  := getcurrdate;

    v_strObjectName     := p_ObjectName;
    v_strRecordKey      := p_RecordKey || ' = ''''' || p_RecordValue || '''''';

    if not(p_ChildObjectName is null or LENGTH(p_ChildObjectName) = 0) then
        v_strChildObjName   := p_ChildObjectName;
        v_strChildRecordKey := p_ChildRecordKey || ' = ''''' || p_ChildRecordValue || '''''';
    else
        v_strChildObjName := '';
        v_strChildRecordKey := '';
    End If;

    begin
        select max(MOD_NUM+1) into l_modNum from maintain_log where TABLE_NAME = v_strObjectName and RECORD_KEY = v_strRecordKey;
      EXCEPTION WHEN OTHERS THEN
        l_modNum    := 0;
    end;
    l_modNum := nvl(l_modNum,0);

    OPEN l_refcursor FOR p_strSQL;
    v_cursor_number := dbms_sql.to_cursor_number(l_refcursor);
    dbms_sql.describe_columns(v_cursor_number, v_columns, v_desc_tab);
    --define colums
    FOR i IN 1 .. v_desc_tab.COUNT LOOP
            IF v_desc_tab(i).col_type = dbms_types.typecode_number THEN
            --Number
                dbms_sql.define_column(v_cursor_number, i, v_number_value);
            ELSIF v_desc_tab(i).col_type = dbms_types.typecode_varchar
                OR  v_desc_tab(i).col_type = dbms_types.typecode_char THEN
            --Varchar, char
                dbms_sql.define_column(v_cursor_number, i, v_varchar_value,200);
            ELSIF v_desc_tab(i).col_type = dbms_types.typecode_date THEN
            --Date,
               dbms_sql.define_column(v_cursor_number, i, v_date_value);
            END IF;
    END LOOP;
    WHILE dbms_sql.fetch_rows(v_cursor_number) > 0 LOOP
        FOR i IN 1 .. v_desc_tab.COUNT LOOP
              v_logSQL  := '';
              l_fldname :=  upper(v_desc_tab(i).col_name);
              l_modNum  := i;
              IF v_desc_tab(i).col_type = dbms_types.typecode_number THEN
                   dbms_sql.column_value(v_cursor_number, i, v_number_value);
                   l_fldval := to_char(v_number_value);
              ELSIF  v_desc_tab(i).col_type = dbms_types.typecode_varchar
                OR  v_desc_tab(i).col_type = dbms_types.typecode_char
                THEN
                   dbms_sql.column_value(v_cursor_number, i, v_varchar_value);
                   l_fldval := v_varchar_value;
              ELSIF v_desc_tab(i).col_type = dbms_types.typecode_date THEN
                   dbms_sql.column_value(v_cursor_number, i, v_date_value);
                   l_fldval:=to_char(v_date_value,'DD/MM/RRRR');
              END IF;

              if not(l_fldval is null or LENGTH(l_fldval) = 0) then
                continue;
              end if;

              v_logSQL := v_logSQL || ' INSERT INTO MAINTAIN_LOG(TABLE_NAME, RECORD_KEY,'
                            ||' MAKER_ID, MAKER_DT, APPROVE_RQD, COLUMN_NAME,'
                            ||' FROM_VALUE, TO_VALUE, MOD_NUM, ACTION_FLAG, CHILD_TABLE_NAME,'
                            ||' CHILD_RECORD_KEY, MAKER_TIME) VALUES';
              v_logSQL := v_logSQL || ' ('''|| v_strObjectName || ''',''' || v_strRecordKey || ''','''
                            || l_tlid || ''','''|| l_currdate ||''', ''Y';
              v_logSQL := v_logSQL || ''',''' || l_fldname || ''',''' ||''
                            || ''',''' ||to_char( l_fldval) || ''',' || TO_CHAR( l_modNum) || ', ''ADD'','''
                            || v_strChildObjName ||''', ''' || v_strChildRecordKey || ''','''|| TO_CHAR( SYSTIMESTAMP,'HH:MI:SS') ||''')';

              dbms_output.put_line('v_logSQL:' || v_logSQL);
              Begin
                execute immediate v_logSQL;
              Exception when others then
                plog.error( 'prc_maintainlog.SQL:' || v_logSQL );
                plog.error( 'prc_maintainlog.Error: '||sqlerrm|| dbms_utility.format_error_backtrace);
                continue;
              End;

        END LOOP;
    END LOOP;

EXCEPTION WHEN OTHERS THEN
    plog.error( 'prc_maintainlog.Error: '||sqlerrm|| dbms_utility.format_error_backtrace);
    raise errnums.E_BIZ_RULE_INVALID;
END;
/
