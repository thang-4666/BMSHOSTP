SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_calc_intovddue(
  v_lncldr varchar2,
  v_Tier3 IN number,
  v_Tier3_rate IN number,
  v_Frdate IN Date,
  v_DueDate IN Date,
  v_Todate IN Date)
  RETURN number IS
  v_Result number(18,7);
  v_intDay number(10,0);
  v_dateDiff number(10,0);
BEGIN
  v_dateDiff:= fn_get_date_diff(v_Frdate, v_Todate, v_lncldr);
  v_intDay := v_dateDiff - 1;
  
  if v_dateDiff > v_Tier3 then
     v_Result:=(v_intDay/360)*(v_Tier3_rate*1.5/100);
  ELSE
     v_Result:=0;
  end if;
  RETURN v_Result;
END;
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
