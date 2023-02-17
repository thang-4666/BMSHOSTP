SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_getdepofeeval (pv_SecType varchar2 , pv_date date)
return NUMBER
is
v_value number;
begin
    if pv_SecType='TP' then --Trai phieu
        select MAX(feeamt) / MAX(lotday) into v_value from cifeedef where
        --Ngay 23/03/2017 CW NamTv chinh sua them sectype 011
         DECODE(SECTYPE,'001','111','002','111','007','111','008','111','011','111','003','222','006','222','111','111','222','222','')  ='222'
         AND  feetype ='VSDDEP';
    ELSE--Co phieu
        --Ngay 23/03/2017 CW NamTv chinh sua them sectype 011
        select MAX(feeamt) / MAX( lotday) into v_value from cifeedef where
         DECODE(SECTYPE,'001','111','002','111','007','111','008','111','011','111','003','222','006','222','111','111','222','222','')  ='111'
         AND  feetype ='VSDDEP';
    end if;
    return v_value;
exception when others then
    if pv_SecType='TP' then
        return 0.2/30;
    else
        return 0.4/30;
    end if;
end;
 
/
