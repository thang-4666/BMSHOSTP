SET DEFINE OFF;
CREATE OR REPLACE FUNCTION FN_GETFEEAMT2669(P_FEETYPE IN VARCHAR2, P_AMT in number)
RETURN NUMBER IS
v_FORP  varchar2(1);
V_RESULT NUMBER;
v_feeamt number(20,4);
v_feerate number(20,4);
v_min   NUMBER;
v_max   NUMBER;
BEGIN

select forp, feeamt, feerate, minval, maxval into v_FORP, v_feeamt, v_feerate, v_min, v_max from  FEEMASTER WHERE FEECD=P_FEETYPE;

if v_FORP = 'F' then
    V_RESULT:=v_feeamt;
else
    V_RESULT:= v_feerate*P_AMT/100 ;
    V_RESULT:= least(GREATEST(v_min,V_RESULT),v_max);


end if;

RETURN V_RESULT;
EXCEPTION
   WHEN OTHERS THEN
    RETURN 0;
END;

 
 
 
 
/
