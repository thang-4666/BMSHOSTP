SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fnc_check_sec_hcm
  ( v_Symbol IN varchar2)
  RETURN  number IS

Cursor c_SecInfo(vc_Symbol varchar2) is
    Select 1 from ho_Sec_info where
    Trim(CODE) =Trim(vc_Symbol) and FLOOR_CODE ='10';
  v_Number Number(10);
  v_Result varchar2(10);
BEGIN
  Open c_SecInfo(v_Symbol);
  Fetch c_SecInfo into v_Number;
  If c_SecInfo%notfound  Then
      v_Result :='0';
  Else
     v_Result :='1';
  End if;
  Close c_SecInfo;
  RETURN v_Result;
END;
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
