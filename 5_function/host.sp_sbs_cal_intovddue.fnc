SET DEFINE OFF;
CREATE OR REPLACE FUNCTION SP_SBS_CAL_INTOVDDUE(
  v_Tier3 IN number,
  v_Tier3_rate IN number,
  v_Frdate IN Date,
  v_Todate IN Date)
  RETURN number IS
  v_Result number(18,5);
  v_intDay number(10,0);
BEGIN
  v_intDay:=v_Todate-v_Frdate;
  if v_intDay>v_Tier3 then
     IF getnextdt(v_Frdate+v_Tier3)=v_Todate THEN
        v_Result:=0;
     ELSE
        v_Result:=((v_intDay-v_Tier3)/360)*(v_Tier3_rate*1.5/100);
     END IF;
  ELSE
     v_Result:=0;
  end if;
  RETURN v_Result;
END;

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
