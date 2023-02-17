SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_get_se_fee_2232_new(PV_CUSTODYCD IN VARCHAR2, PV_FEETYPE IN VARCHAR2,pv_qtty IN NUMBER , pv_pavalue IN number)
    RETURN NUMBER IS
v_FORP  varchar2(1);
v_isvat  varchar2(1);
V_RESULT NUMBER;
v_feeamt number(20,4);
v_feerate number(20,4);
v_vatrate number(20,4);
v_min   NUMBER;
v_max   NUMBER;

p_min NUMBER;
p_fee NUMBER;


BEGIN
select vat into v_isvat from cfmast WHERE CUSTODYCD = PV_CUSTODYCD;

select forp, feeamt, feerate,vatrate, minval, maxval into v_FORP, v_feeamt, v_feerate,v_vatrate, v_min, v_max
from  FEEMASTER WHERE FEECD=PV_FEETYPE;


p_fee:=v_feerate*pv_qtty*pv_pavalue/100;
if v_FORP = 'F' then
  p_min:=least(GREATEST(v_min,v_feeamt),v_max);
  else
  p_min:=least(GREATEST(v_min,p_fee),v_max);
end if;

IF v_isvat='N' THEN 
  V_RESULT:= round(p_min);
ELSE
    V_RESULT:= round(p_min/(1+v_vatrate/100));
END IF;

RETURN V_RESULT;

RETURN V_RESULT;
EXCEPTION
   WHEN OTHERS THEN
    RETURN 0;
END;

 
 
 
 
/
