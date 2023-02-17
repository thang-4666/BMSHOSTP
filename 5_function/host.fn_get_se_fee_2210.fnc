SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_get_se_fee_2210(PV_CURVALUE NUMBER,PV_CALTYPE VARCHAR2, PV_TYPE IN VARCHAR2, PV_AMT IN NUMBER)
return number is
v_return number;
v_amount number;

begin

    v_amount := PV_AMT;
    v_return := (PV_TYPE/100)*v_amount;
    IF PV_CALTYPE ='01' THEN
        return v_return;
    ELSE
        RETURN PV_CURVALUE;
    END IF;

exception when others then
    return 0;
end;

 
 
 
 
/
