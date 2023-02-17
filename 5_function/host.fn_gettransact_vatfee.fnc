SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_gettransact_vatfee(pv_feecode varchar2, pv_amount number)
return number is
v_return number;
V_FEEAMT number;
begin
    for rec in (
        select * from FEEMASTER where FEECD =pv_feecode
    )
    loop
        if rec.forp = 'F' then
            v_return:= round(rec.feeamt*rec.vatrate/100);
        else
            V_FEEAMT := ROUND((pv_amount*rec.feerate/100));
            V_FEEAMT := least(V_FEEAMT, rec.maxval);
            V_FEEAMT := greatest(V_FEEAMT, rec.minval);

            v_return := round((V_FEEAMT)*rec.vatrate/100);
            --v_return := least(v_return, rec.maxval);
            --v_return := greatest(v_return, rec.minval);
        end if;
        --v_return := 0;
        return v_return;
    end loop;
    return 0;
exception when others then
    return 0;
end;

 
 
 
 
 
 
 
 
 
 
 
/
