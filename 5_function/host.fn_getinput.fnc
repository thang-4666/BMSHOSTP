SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_getinput(pv_refcursor IN pkg_report.ref_cursor)
RETURN VARCHAR2
IS
  v_result        VARCHAR2(2500);
  v_refcursor pkg_report.ref_cursor;
  v_cursor_number NUMBER;
  v_columns       NUMBER;
  v_desc_tab      dbms_sql.desc_tab;
  l_number_value  NUMBER;
  l_varchar_value VARCHAR(200);
  l_date_value    DATE;
BEGIN
  v_result := '{';
  v_refcursor := pv_refcursor;
  --Convert cursor to DBMS_SQL CURSOR
  v_cursor_number := dbms_sql.to_cursor_number(v_refcursor);
   --Get information on the columns
   dbms_sql.describe_columns(v_cursor_number, v_columns, v_desc_tab);
   FOR i IN 1 .. v_desc_tab.COUNT LOOP
       IF v_desc_tab(i).col_type = dbms_types.typecode_number THEN
          dbms_sql.define_column(v_cursor_number, i, l_number_value);
       ELSIF v_desc_tab(i).col_type = dbms_types.typecode_varchar
             OR v_desc_tab(i).col_type = dbms_types.typecode_char THEN
          dbms_sql.define_column(v_cursor_number, i, l_varchar_value,200);
       ELSIF v_desc_tab(i).col_type = dbms_types.typecode_date THEN
          dbms_sql.define_column(v_cursor_number, i, l_date_value);
       END IF;
   END LOOP;
   WHILE dbms_sql.fetch_rows(v_cursor_number) > 0 LOOP
     FOR i IN 1 .. v_desc_tab.COUNT LOOP
         IF v_desc_tab(i).col_type = dbms_types.typecode_number THEN
            dbms_sql.column_value(v_cursor_number, i, l_number_value);
            v_result := v_result || '"' || v_desc_tab(i).col_name || '"' || ':' || '"' || NVL(l_number_value, '') || '"' ||',';
         ELSIF v_desc_tab(i).col_type = dbms_types.typecode_varchar
           OR v_desc_tab(i).col_type = dbms_types.typecode_char
         THEN
           dbms_sql.column_value(v_cursor_number, i, l_varchar_value);
           v_result := v_result || '"' || v_desc_tab(i).col_name || '"' || ':' || '"' || NVL(l_varchar_value, '') || '"' ||',';
         ELSIF v_desc_tab(i).col_type = dbms_types.typecode_date THEN
            dbms_sql.column_value(v_cursor_number, i, l_date_value);
            v_result := v_result || '"' || v_desc_tab(i).col_name || '"' || ':' || '"' || NVL(TO_DATE(l_date_value, 'DD/MM/RRRR'), '') || '"' ||',';
         END IF;
     END LOOP;
   END LOOP;
   v_result := v_result || '}';
   v_result := REPLACE(v_result, ',}', '}');
   RETURN v_result;
EXCEPTION WHEN OTHERS THEN
  RETURN '';
END FN_GETINPUT;
/
