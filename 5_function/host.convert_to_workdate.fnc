SET DEFINE OFF;
CREATE OR REPLACE FUNCTION CONVERT_TO_WORKDATE(pv_count_day In VARCHAR2)
    RETURN VARCHAR2 IS
    v_Result  NUMBER;
    v_currdate DATE;
    v_nextdate DATE;
    v_count NUMBER;

BEGIN
  v_count:= to_number(pv_count_day);
  v_Result:=0;
            SELECT to_Date(varvalue, 'DD/MM/YYYY')
              INTO v_currdate
              FROM sysvar
             WHERE varname = 'CURRDATE';
             v_nextdate:=v_currdate;

            WHILE (v_count > 0) LOOP
              BEGIN
                SELECT MIN(sbdate)
                  INTO v_nextdate
                  FROM sbcldr
                 WHERE sbdate > v_nextdate
                   AND holiday = 'N'
                   AND cldrtype = '000';
                   v_count:=v_count-1;
              END;
            END LOOP;
            v_Result:=v_nextdate- v_currdate;

    RETURN v_Result;

EXCEPTION
   WHEN OTHERS THEN
    RETURN 0;
END;

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
