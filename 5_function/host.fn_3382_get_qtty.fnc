SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_3382_get_qtty( pv_CAMASTID IN VARCHAR2, pv_qtty IN NUMBER)
    RETURN NUMBER IS
    v_Result  NUMBER;
    l_left_rightoffrate varchar2(30);
    l_right_rightoffrate varchar2(30);
    l_roundtype number(20,4);
BEGIN
    v_Result := 0;
    BEGIN
        SELECT substr(rightoffrate,1,instr(rightoffrate,'/')-1),
                   substr(rightoffrate,instr(rightoffrate,'/') + 1,length(rightoffrate)),
                   roundtype
        INTO l_left_rightoffrate, l_right_rightoffrate, l_roundtype
        from camast where camastid = pv_CAMASTID and deltd <> 'Y';
    exception when others then
        v_Result := 0;
        RETURN v_Result;
    end;
    if (l_left_rightoffrate = 0) then
        v_Result := 0;
        RETURN v_Result;
    end if;
    v_Result := TRUNC(FLOOR((pv_qtty * l_right_rightoffrate)/l_left_rightoffrate),l_roundtype);
    RETURN v_Result;

EXCEPTION
   WHEN OTHERS THEN
    RETURN 0;
END;

 
 
 
 
 
 
 
 
 
 
 
/
