SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_calc_intdue(
  v_lncldr varchar2,
  v_Tier1 IN number,
  v_Tier1_rate IN number,
  v_Tier2 IN number,
  v_Tier2_rate IN number,
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

  if v_dateDiff <= v_Tier1 then
     v_Result:=(v_intDay/360)*(v_Tier1_rate/100);
  end if;

  if v_dateDiff > v_Tier1 AND v_dateDiff <= v_Tier2 then
     --NEU v_tier1 trung vao t7 hoac cn va todate roi vao t2 thi van tinh theo tier1
     IF getnextdt(getduedate (v_frdate,v_lncldr,'000',v_tier1))=v_Todate THEN
        v_Result:=(v_intDay/360)*(v_Tier1_rate/100);
     ELSE
        v_Result:=(v_intDay/360)*(v_Tier2_rate/100);
     END IF;
  end if;

  if v_dateDiff > v_Tier2 AND v_dateDiff <= v_Tier3 then
     --NEU v_tier1 trung vao t7 hoac cn va todate roi vao t2 thi van tinh theo tier2
     IF getnextdt(getduedate (v_frdate,v_lncldr,'000',v_tier2))=v_Todate THEN
        v_Result:=(v_intDay/360)*(v_Tier2_rate/100);
     ELSE
        v_Result:=(v_intDay/360)*(v_Tier3_rate/100);
     END IF;
  end if;

  if v_dateDiff > v_Tier3 then
    -- Bo lai ngay dau tien
     --v_Result:=((fn_get_date_diff(v_Frdate, v_DueDate, v_lncldr)-1)/360)*(v_Tier2_rate/100);
          --NEU v_tier1 trung vao t7 hoac cn va todate roi vao t2 thi van tinh theo tier3
     IF getnextdt(getduedate (v_frdate,v_lncldr,'000',v_tier3))=v_Todate THEN
        v_Result:=(v_intDay/360)*(v_Tier3_rate/100);
     ELSE
        v_Result:=(v_Tier3/360)*(v_Tier3_rate/100);
     END IF;
  end if;
  RETURN v_Result;
END;
 
 
 
 
 
 
 
 
 
 
 
 
 
/
