SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_cal_fee_amt(pv_amt IN number, pv_feecd IN varchar2)
  RETURN number IS
  v_Result number(10,4);
BEGIN
    v_Result := 0;
    begin
        select round((feerate/100)*pv_amt,0) into v_Result
        from feemaster where feecd = pv_feecd
            and pv_amt >= minval and pv_amt <= maxval ;
    EXCEPTION when OTHERS THEN
        v_Result := 0;
    end;
    RETURN v_Result;
EXCEPTION
   WHEN OTHERS THEN
    RETURN 0;
END;

 
 
 
 
 
 
 
 
 
 
 
/
