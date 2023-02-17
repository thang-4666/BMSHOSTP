SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE export_script(P_TABLENAME IN VARCHAR2, P_KEY1 IN VARCHAR2, P_KEY2 IN VARCHAR2, P_KEY3 IN VARCHAR2, P_ORDER IN VARCHAR2, P_PATH IN VARCHAR2)
IS
    L_FILENAME VARCHAR(200);
    L_SQL VARCHAR2(1000);
    L_SQL_GR VARCHAR2(1000);
    L_SQL_WHERE VARCHAR2(1000);
    L_SQL_WHERE2 VARCHAR2(1000);
    L_SQL2 VARCHAR2(1000);
    L_CONTENT VARCHAR2(4000);
    L_INSERT VARCHAR2(4000);
    L_VALUES VARCHAR2(4000);
    L_SQL_ORDER VARCHAR2(100);

    L_KEY1_TYPE VARCHAR2(10);
    L_KEY2_TYPE VARCHAR2(10);
    L_KEY3_TYPE VARCHAR2(10);
BEGIN

    UPDATE EXPORT_SCRIPT_LOG SET STATUS = 'D' WHERE TABLENAME =  P_TABLENAME;

    L_FILENAME := '';
    L_SQL := '';
    L_SQL_GR := '';
    L_SQL_WHERE := '1 = 1';
    L_SQL_WHERE2 := '1 = 1';
    L_SQL2 := '';
    L_INSERT := 'Insert into ' || UPPER(P_TABLENAME) || CHR(13) || '   ' ||'(';
    L_VALUES := ' Values' || CHR(13) || '   ' || '(';
    L_SQL_ORDER := '';

    FOR REC IN (
        SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, DATA_LENGTH
        FROM USER_TAB_COLUMNS
        WHERE TABLE_NAME = P_TABLENAME
        ORDER BY COLUMN_ID
    )
    LOOP
        L_INSERT := L_INSERT || REC.COLUMN_NAME || ', ';
        IF REC.DATA_TYPE IN ('NUMBER','FLOAT') THEN
            L_VALUES := L_VALUES || ''' || NVL(REC3.' || REC.COLUMN_NAME || ',1233219999) || '', ';
        ELSIF REC.DATA_TYPE IN ('DATE') THEN
            L_VALUES := L_VALUES || 'TO_DATE('''''' || TO_CHAR(REC3.' || REC.COLUMN_NAME || ', ''DD/MM/RRRR'') || '''''',''''DD/MM/RRRR''''), ';
        ELSIF REC.DATA_TYPE IN ('TIMESTAMP(6)') THEN
            L_VALUES := L_VALUES || 'TO_TIMESTAMP('''''' || TO_CHAR(REC3.' || REC.COLUMN_NAME || ', ''DD/MM/RRRR HH24:MI:SS'') || '''''',''''DD/MM/RRRR HH24:MI:SS''''), ';
        ELSE
            L_VALUES := L_VALUES || ''''''' || REPLACE(REC3.' || REC.COLUMN_NAME || ','''''''','''''''''''') || '''''', ';
        END IF;
        IF P_KEY1 IS NOT NULL AND P_KEY1 = REC.COLUMN_NAME THEN
            L_KEY1_TYPE := REC.DATA_TYPE;
        END IF;
        IF P_KEY2 IS NOT NULL AND P_KEY2 = REC.COLUMN_NAME THEN
            L_KEY2_TYPE := REC.DATA_TYPE;
        END IF;
        IF P_KEY3 IS NOT NULL AND P_KEY3 = REC.COLUMN_NAME THEN
            L_KEY3_TYPE := REC.DATA_TYPE;
        END IF;
    END LOOP;

    L_INSERT := SUBSTR(L_INSERT,0,LENGTH(L_INSERT) - 2) || ')';
    L_VALUES := SUBSTR(L_VALUES,0,LENGTH(L_VALUES) - 2) || ');';

    IF P_KEY1 IS NOT NULL THEN
        L_SQL_GR := L_SQL_GR || P_KEY1 || ', ';
        IF L_KEY1_TYPE IN ('NUMBER','FLOAT') THEN
            L_SQL_WHERE := L_SQL_WHERE || ' AND ' || P_KEY1 || ' = REC2.' || P_KEY1 || '';
            L_SQL_WHERE2 := L_SQL_WHERE2 || ' AND ' || P_KEY1 || ' = '' || REC2.' || P_KEY1 || ' || ''';
        ELSE
            L_SQL_WHERE := L_SQL_WHERE || ' AND NVL(' || P_KEY1 || ',''NULL'') = NVL(REC2.' || P_KEY1 || ',''NULL'')';
        L_SQL_WHERE2 := L_SQL_WHERE2 || ' AND NVL(' || P_KEY1 || ',''''NULL'''') = NVL('''''' || REC2.' || P_KEY1 || ' || '''''',''''NULL'''')';
        END IF;
        L_FILENAME :=  L_FILENAME || ' REGEXP_REPLACE(REC2.' || P_KEY1 || ',''[\/:*?"<>|.'''']'','''') || ''.'' || ';
    END IF;

    IF P_KEY2 IS NOT NULL THEN
        L_SQL_GR := L_SQL_GR || P_KEY2 || ', ';
        IF L_KEY1_TYPE IN ('NUMBER','FLOAT') THEN
            L_SQL_WHERE := L_SQL_WHERE || ' AND ' || P_KEY2 || ' = REC2.' || P_KEY2 || '';
            L_SQL_WHERE2 := L_SQL_WHERE2 || ' AND ' || P_KEY2 || ' = '' || REC2.' || P_KEY2 || ' || ''';
        ELSE
            L_SQL_WHERE := L_SQL_WHERE || ' AND NVL(' || P_KEY2 || ',''NULL'') = NVL(REC2.' || P_KEY2 || ',''NULL'')';
            L_SQL_WHERE2 := L_SQL_WHERE2 || ' AND NVL(' || P_KEY2 || ',''''NULL'''') = NVL('''''' || REC2.' || P_KEY2 || ' || '''''',''''NULL'''')';
        END IF;
        L_FILENAME := L_FILENAME || ' REC2.' || P_KEY2 || ' || ''.'' || ';
    END IF;

    IF P_KEY3 IS NOT NULL THEN
        L_SQL_GR := L_SQL_GR || P_KEY3 || ', ';
        IF L_KEY1_TYPE IN ('NUMBER','FLOAT') THEN
            L_SQL_WHERE := L_SQL_WHERE || ' AND ' || P_KEY3 || ' = REC2.' || P_KEY3 || '';
            L_SQL_WHERE2 := L_SQL_WHERE2 || ' AND ' || P_KEY3 || ' = '' || REC2.' || P_KEY3 || ' || ''';
        ELSE
            L_SQL_WHERE := L_SQL_WHERE || ' AND NVL(' || P_KEY3 || ',''NULL'') = NVL(REC2.' || P_KEY3 || ',''NULL'')';
            L_SQL_WHERE2 := L_SQL_WHERE2 || ' AND NVL(' || P_KEY3 || ',''''NULL'''') = NVL('''''' || REC2.' || P_KEY3 || ' || '''''',''''NULL'''')';
        END IF;
        L_FILENAME := L_FILENAME || ' REC2.' || P_KEY3 || ' || ''.'' || ';
    END IF;

    IF P_ORDER IS NOT NULL THEN
        L_SQL_ORDER := 'ORDER BY ' || P_ORDER;
    END IF;

    IF P_KEY1 IS NULL AND P_KEY2 IS NULL AND P_KEY3 IS NULL THEN
        L_SQL := 'SELECT * FROM ' || P_TABLENAME || ' ' || L_SQL_ORDER;
        L_FILENAME := '''' || P_TABLENAME || '.sql''';
        L_CONTENT := 'SET DEFINE OFF;' || CHR(13) || CHR(13) || 'DELETE FROM ' || P_TABLENAME || ';' || CHR(13) || CHR(13);

        EXECUTE IMMEDIATE '
        DECLARE
        L_CONTENT CLOB;
        L_FILENAME VARCHAR(200);
        BEGIN
            L_FILENAME := ' || L_FILENAME || ';
            L_CONTENT := TO_CLOB(''' || L_CONTENT || ''');
            FOR REC3 IN ('|| L_SQL || ') LOOP
                L_CONTENT := L_CONTENT || TO_CLOB(''' || L_INSERT || ''') || CHR(13) || TO_CLOB(''' || L_VALUES || ''') || CHR(13) || CHR(13);
            END LOOP;

            DELETE FROM EXPORT_SCRIPT_LOG WHERE FILENAME = L_FILENAME;

            L_CONTENT := L_CONTENT || TO_CLOB(''COMMIT;'');
            INSERT INTO EXPORT_SCRIPT_LOG(FILENAME, CONTENT, TABLENAME, STATUS, PATHNAME)
            VALUES (L_FILENAME, L_CONTENT, ''' || P_TABLENAME || ''', ''P'', ''' || P_PATH || ''');
            COMMIT;
        END;
        ';
    ELSE
        L_SQL_GR := SUBSTR(L_SQL_GR,0,LENGTH(L_SQL_GR) - 2);
        L_SQL := 'SELECT ' || L_SQL_GR || ' FROM ' || P_TABLENAME || ' GROUP BY ' || L_SQL_GR;
        L_SQL2 := 'SELECT * FROM ' || P_TABLENAME || ' WHERE ' || L_SQL_WHERE || ' ' || L_SQL_ORDER;
        L_FILENAME := '''' || P_TABLENAME || '.'' || ' || SUBSTR(L_FILENAME,0,LENGTH(L_FILENAME) - 11) || ' || ''.sql''';
        L_CONTENT := 'SET DEFINE OFF;' || CHR(13) || CHR(13) || 'DELETE FROM ' || P_TABLENAME || ' WHERE ' || L_SQL_WHERE2 || ';' || CHR(13) || CHR(13);

        EXECUTE IMMEDIATE '
        DECLARE
        L_CONTENT CLOB;
        L_FILENAME VARCHAR(200);
        BEGIN
        FOR REC2 IN (' || L_SQL || ') LOOP
            L_FILENAME := ' || L_FILENAME || ';
            L_CONTENT := TO_CLOB(''' || L_CONTENT || ''');
            FOR REC3 IN ('|| L_SQL2 || ') LOOP
                L_CONTENT := L_CONTENT || TO_CLOB(''' || L_INSERT || ''') || CHR(13) || TO_CLOB(''' || L_VALUES || ''') || CHR(13) || CHR(13);
            END LOOP;

            DELETE FROM EXPORT_SCRIPT_LOG WHERE FILENAME = L_FILENAME;

            L_CONTENT := L_CONTENT || TO_CLOB(''COMMIT;'');
            INSERT INTO EXPORT_SCRIPT_LOG(FILENAME, CONTENT, TABLENAME, STATUS, PATHNAME)
            VALUES (L_FILENAME, L_CONTENT, ''' || P_TABLENAME || ''', ''P'', ''' || P_PATH || ''');
        END LOOP;
        COMMIT;
        END;
        ';
    END IF;


EXCEPTION WHEN OTHERS THEN
    PLOG.ERROR ('EXPORT_SCRIPT: ' || SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
    RETURN;
END;
/
