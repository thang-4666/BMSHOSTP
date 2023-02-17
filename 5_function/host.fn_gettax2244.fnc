SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_gettax2244(p_custodycd varchar2, pv_curValue NUMBER, pv_feecode varchar2, pv_qtty number, pv_caculateType varchar2, pv_tranprice number)
    RETURN NUMBER IS
v_return number;
v_price number;
v_amount number;
v_feetype varchar2(1);
v_feerate number;
v_vat   number;
begin
   /* if pv_trantype = '001' then -- Chuyen khoan chung khoan
        v_price:=pv_parvalue;
    else -- Chuyen nhuong chung khoan khong qua san
        v_price:=pv_tranprice;
    end if;*/
    IF pv_CaculateType = '02' THEN
        RETURN pv_curValue;
    end if;

    select case when vat = 'Y' then 1 else 0 end*pv_tranprice * pv_qtty,
        case when vat = 'Y' then 1 else 0 end
            into v_amount, v_vat
    from cfmast where custodycd = p_custodycd;
    for rec in (
        select * from FEEMASTER where FEECD =pv_feecode
    )
    loop
        if rec.forp = 'F' then
            --v_return:= rec.feeamt;
            v_return:= LEAST(GREATEST((rec.feeamt*pv_qtty),rec.minval),rec.maxval)*v_vat;
        else
            v_return := round(v_amount*rec.feerate/100);
            v_return := least(v_return, rec.maxval);
            v_return := greatest(v_return, rec.minval);
        end if;

        --v_return := round(v_amount*rec.vatrate/100);
        v_return := round(v_return*rec.vatrate/100);
    IF pv_CaculateType = '02' THEN
        RETURN pv_curValue;
    ELSE
        return v_return;
    END IF;
        return v_return;
    end loop;
RETURN 0;
EXCEPTION
   WHEN OTHERS THEN
    RETURN 0;
END;
/
