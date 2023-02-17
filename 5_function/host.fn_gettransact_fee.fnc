SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_gettransact_fee(pv_feecode varchar2, pv_amount number)
return number is
v_return number;
begin
    for rec in (
        select * from FEEMASTER where FEECD =pv_feecode
    )
    loop
        if rec.forp = 'F' then
            v_return:= rec.feeamt;
        else
            v_return := round(pv_amount*rec.feerate/100);
            v_return := least(v_return, rec.maxval);
            v_return := greatest(v_return, rec.minval);
        end if;
        return v_return;
    end loop;
    return 0;
exception when others then
    return 0;
end;

 
 
 
 
 
 
 
 
 
 
 
/
