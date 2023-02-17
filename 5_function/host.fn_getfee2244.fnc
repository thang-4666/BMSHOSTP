SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_getfee2244(pv_curValue NUMBER,  pv_feecode varchar2, pv_qtty number, pv_CaculateType VARCHAR2, pv_tranprice number)
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
    IF NVL(pv_CaculateType,'02') ='02' THEN
          RETURN pv_curValue;
    end if;

    v_amount := pv_tranprice * pv_qtty;
    for rec in (
        select * from FEEMASTER where FEECD =pv_feecode
    )
    loop
        if rec.forp = 'F' then
            --v_return:= rec.feeamt;
            v_return:= LEAST(GREATEST((rec.feeamt*pv_qtty),rec.minval),rec.maxval);
        else
            v_return := round(v_amount*rec.feerate/100);
            v_return := least(v_return, rec.maxval);
            v_return := greatest(v_return, rec.minval);
        end if;
    end loop;
    return NVL(v_return,0);
exception when others then
    return 0;
end;
/
