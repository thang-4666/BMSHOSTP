SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_cal_fee_amt2229(pv_QTTY IN number,pv_PARVALUE IN number, pv_feecd IN varchar2)
  RETURN number IS
  v_Result number(20,4);
BEGIN
    v_Result := 0;
    begin
        select LEAST(GREATEST(round((feerate/100)*pv_QTTY*pv_PARVALUE,0),MINVAL),MAXVAL) into v_Result
        from feemaster where feecd = pv_feecd    ;
    EXCEPTION when OTHERS THEN
        v_Result := 0;
    end;
    RETURN v_Result;
EXCEPTION
   WHEN OTHERS THEN
    RETURN 0;
END;
 
 
 
 
/
