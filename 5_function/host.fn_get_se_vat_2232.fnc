SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_get_se_vat_2232( PV_CUSTODYCD IN VARCHAR2,pv_fee IN NUMBER , pv_feecode varchar2)
RETURN NUMBER IS
v_return NUMBER;
V_ISVAT NUMBER;
BEGIN

select decode ( vat,'Y',1,0) into v_isvat from cfmast WHERE CUSTODYCD = PV_CUSTODYCD;


  for rec in (
        select * from FEEMASTER where FEECD =pv_feecode
             )
     loop

            v_return := v_isvat* round(pv_fee*rec.vatrate/100);


    end loop;

RETURN v_return;

--RETURN 0;
EXCEPTION
   WHEN OTHERS THEN
    RETURN 0;
END;
 
 
 
 
/
