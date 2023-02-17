SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_getSYSCLEARDAY( I_DATE IN VARCHAR2)
  RETURN number IS
    v_Result NUMBER;
    v_effdate DATE;

BEGIN
  SELECT to_date(varvalue,'DD/MM/RRRR') INTO v_effdate FROM sysvar WHERE varname ='CHGBCHORDERSTARTDATE';
 If  to_date(I_DATE,'DD/MM/RRRR') >=v_effdate then --Neu ngay thanh toan >=04/01/2015 chu ky 2 nguoc lai chu ky thanh toan 3
        select TO_NUMBER(varvalue) into v_Result from sysvar where grname='SYSTEM' and varname='CLEARDAY' and rownum<=1;
    else
        v_Result:=3;
    end IF;
RETURN v_Result;
END;

 
 
 
 
/
