SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_2244_get_righttax( pv_TRFTYPE IN VARCHAR2,pv_CACULATETYPE IN VARCHAR2, pv_AFACCTNO IN VARCHAR2,pv_CODEID IN VARCHAR2,pv_RIGHTQTTY IN VARCHAR2, pv_PRICE  IN VARCHAR2, pv_CATAX  IN VARCHAR2)
    RETURN NUMBER IS
    v_Result    number;
    v_caqtty    number;
    v_tax       number;
    v_parvalue  number;
BEGIN
    if pv_CACULATETYPE = '02' then
        v_Result    :=  to_number(pv_CATAX);
    elsif pv_TRFTYPE = '002' and pv_CACULATETYPE = '01' then --Neu loai la Chuyen nhuong CK khong qua san + tinh theo Bieu phi
        v_Result    :=  to_number(pv_CATAX);
        v_caqtty := to_number(pv_RIGHTQTTY);
        v_tax   := 0;
        begin
            SELECT PARVALUE INTO v_parvalue from sbsecurities where codeid=pv_CODEID;
            EXCEPTION  WHEN OTHERS THEN
            v_parvalue  := 10000;
        end;

        if to_number(pv_PRICE) < v_parvalue then
            v_parvalue := to_number(pv_PRICE);
        end if;

        for rec in (
            select * from sepitlog where acctno = pv_AFACCTNO|| pv_CODEID
            and deltd <> 'Y' and qtty - mapqtty >0 and pitrate > 0
            order by txdate
        )
        loop

            if v_caqtty > rec.qtty - rec.mapqtty then
                v_tax   := v_tax + (rec.qtty-rec.mapqtty)*rec.pitrate/100*v_parvalue;
                v_caqtty:=v_caqtty-(rec.qtty-rec.mapqtty);
            else
                v_tax   := v_tax + v_caqtty*rec.pitrate/100*v_parvalue;
                v_caqtty:=0;
            end if;


            exit when v_caqtty<=0;
        end loop;
        return v_tax;
    else
        v_Result    := 0;
    end if;

    RETURN v_Result;

EXCEPTION
   WHEN OTHERS THEN
    RETURN 0;
END;
 
/
