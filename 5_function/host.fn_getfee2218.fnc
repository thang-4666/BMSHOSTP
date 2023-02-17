SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_getfee2218(PV_CURVALUE NUMBER, PV_CALTYPE VARCHAR2, PV_TYPE IN VARCHAR2, p_EXECAMT in NUMBER)
    RETURN NUMBER IS

    V_RESULT NUMBER;
    V_FEERATE NUMBER(20,4);
    V_FEEMAX number (20);
    V_FEEMIN number(20);
    V_FEETYPE varchar2(1);
BEGIN

/*SELECT FEERATE/100, MAXVAL, minval, FORP INTO V_FEERATE, V_FEEMAX, V_FEEMIN, V_FEETYPE
FROM FEEMASTER WHERE FEECD = P_FEETYPE AND STATUS ='A';

if V_FEETYPE = 'F' then --loai phi co dinh
    select MAX(feeamt) into V_RESULT from feemaster where  FEECD = P_FEETYPE AND STATUS ='A';
else
    V_RESULT := V_FEERATE*p_EXECAMT ;
    V_RESULT := least(V_RESULT, V_FEEMAX);
    V_RESULT := greatest(V_RESULT, V_FEEMIN);
end if ;*/
----RETURN PV_CALTYPE;
IF PV_CALTYPE = '02' THEN
    RETURN PV_CURVALUE;
END IF;
for rec in (
        select * from FEEMASTER where FEECD =PV_TYPE
    )
    loop
        if rec.forp = 'F' then
            V_RESULT := rec.feeamt;
        else
            V_RESULT := round(p_EXECAMT*rec.feerate/100);
            V_RESULT := least(V_RESULT, rec.maxval);
            V_RESULT := greatest(V_RESULT, rec.minval);
        end if;
        IF PV_CALTYPE = '01' THEN
            return V_RESULT;
        ELSE RETURN PV_CURVALUE;
        END IF;
    end loop;
    return 0;



RETURN V_RESULT;

EXCEPTION
   WHEN OTHERS THEN
    RETURN 0;
END;

 
 
 
 
/
