SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_get_se_vat_2232_new(pv_fee IN NUMBER , pv_feecode varchar2,pv_qtty IN NUMBER , pv_pavalue IN number)
RETURN NUMBER IS
v_return NUMBER;

v_FORP  varchar2(1);
v_feeamt number(20,4);
v_feerate number(20,4);
v_min   NUMBER;
v_max   NUMBER;

p_min NUMBER;
v_fee NUMBER;
BEGIN

select forp, feeamt, feerate, minval, maxval into v_FORP, v_feeamt, v_feerate, v_min, v_max
from  FEEMASTER WHERE FEECD=pv_feecode;


v_fee:=v_feerate*pv_qtty*pv_pavalue/100;
if v_FORP = 'F' then
  p_min:=least(GREATEST(v_min,v_feeamt),v_max);
  else
  p_min:=least(GREATEST(v_min,v_fee),v_max);
end if;

 v_return := round(p_min-pv_fee);
/*
  for rec in (
        select * from FEEMASTER where FEECD =pv_feecode
             )
     loop

            v_return := v_isvat* round(pv_fee*rec.vatrate/100);


    end loop;*/

RETURN v_return;

--RETURN 0;
EXCEPTION
   WHEN OTHERS THEN
    RETURN 0;
END;

 
 
 
 
/
