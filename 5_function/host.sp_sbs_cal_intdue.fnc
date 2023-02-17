SET DEFINE OFF;
CREATE OR REPLACE FUNCTION SP_SBS_CAL_INTDUE(
  v_Tier1 IN number,
  v_Tier1_rate IN number,
  v_Tier2 IN number,
  v_Tier2_rate IN number,
  v_Tier3 IN number,
  v_Tier3_rate IN number,
  v_Frdate IN Date,
  v_Todate IN Date)
  RETURN number IS
  v_Result number(18,5);
  v_intDay number(10,0);
BEGIN
  v_intDay:=v_Todate-v_Frdate;

  if v_intDay<=v_Tier1 then
     v_Result:=(v_intDay/360)*(v_Tier1_rate/100);
  end if;

  if v_intDay>v_Tier1 AND v_intDay<=v_Tier2 then
     --NEU v_tier1 trung vao t7 hoac cn va todate roi vao t2 thi van tinh theo tier1
     IF getnextdt(v_Frdate+v_Tier1)=v_Todate THEN
        v_Result:=(v_intDay/360)*(v_Tier1_rate/100);
     ELSE
        v_Result:=(v_intDay/360)*(v_Tier2_rate/100);
     END IF;
  end if;

  if v_intDay>v_Tier2 AND v_intDay<=v_Tier3 then
     --NEU v_tier1 trung vao t7 hoac cn va todate roi vao t2 thi van tinh theo tier2
     IF getnextdt(v_Frdate+v_Tier2)=v_Todate THEN
        v_Result:=(v_intDay/360)*(v_Tier2_rate/100);
     ELSE
        v_Result:=(v_intDay/360)*(v_Tier3_rate/100);
     END IF;
  end if;

  if v_intDay>v_Tier3 then
     --NEU v_tier1 trung vao t7 hoac cn va todate roi vao t2 thi van tinh theo tier3
     IF getnextdt(v_Frdate+v_Tier3)=v_Todate THEN
        v_Result:=(v_intDay/360)*(v_Tier3_rate/100);
     ELSE
        v_Result:=(v_Tier3/360)*(v_Tier3_rate/100);
     END IF;
  end if;
  RETURN v_Result;
END;

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
