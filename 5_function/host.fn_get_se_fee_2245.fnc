SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_get_se_fee_2245(PV_CURVALUE NUMBER,PV_CALTYPE VARCHAR2, PV_TYPE IN VARCHAR2, PV_QTTY IN VARCHAR2, PV_TRFVALUE IN NUMBER)
return number is
v_return number;
v_price number;
v_amount number;

begin
   /* if pv_trantype = '001' then -- Chuyen khoan chung khoan
        v_price:=pv_parvalue;
    else -- Chuyen nhuong chung khoan khong qua san
        v_price:=pv_tranprice;
    end if;*/

    v_amount:= PV_TRFVALUE * PV_QTTY;
    for rec in (
        select * from FEEMASTER where FEECD =PV_TYPE
    )
    loop
        if rec.forp = 'F' then
            v_return:= rec.feeamt;
        else
            v_return := round(v_amount*rec.feerate/100);
            v_return := least(v_return, rec.maxval);
            v_return := greatest(v_return, rec.minval);
        end if;
        IF PV_CALTYPE ='01' THEN
        return v_return;
        ELSE RETURN PV_CURVALUE;
        END IF;
    end loop;
    return 0;
exception when others then
    return 0;
end;
 
 
 
 
/
