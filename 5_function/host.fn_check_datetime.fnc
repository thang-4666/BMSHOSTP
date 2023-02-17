SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_check_datetime (pv_fromtime IN VARCHAR2, pv_totime IN varchar2)
  RETURN VARCHAR2 IS
  v_Result number(10,4);
  v_fromhour VARCHAR2(2);
  v_tohour VARCHAR2(2);
  v_frommin VARCHAR2(2);
  v_tomin VARCHAR2(2);
  v_fromtime VARCHAR2(4);
  v_totime VARCHAR2(4);
BEGIN
    v_Result := 0;
    v_fromtime := rpad(replace(pv_fromtime,' ','0'),4,'0');
    v_fromhour := substr(v_fromtime,0,2);
    v_frommin := substr(v_fromtime,3,2);
    v_totime := rpad(replace(pv_totime,' ','0'),4,'0');
    v_tohour := substr(v_totime,0,2);
    v_tomin := substr(v_totime,3,2);

    begin
       IF  v_fromhour > v_tohour OR v_fromhour > 24 OR v_fromhour < 0
         OR v_tohour > 24 OR v_tohour< 0
         OR v_frommin >60 OR v_frommin<0
         OR v_tomin > 60 OR v_frommin < 0 THEN
            v_result := 0;
        ELSE
          v_result := 1;
        END IF;
    EXCEPTION when OTHERS THEN
        v_Result := 0;
    end;
    RETURN v_Result;
EXCEPTION
   WHEN OTHERS THEN
    RETURN 0;
END;
 
 
 
 
/
