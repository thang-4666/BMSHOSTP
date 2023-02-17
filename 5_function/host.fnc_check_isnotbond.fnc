SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fnc_check_isnotbond
  ( v_Symbol IN Varchar2)
  RETURN  number IS
Cursor c_Sbsecurities(v_Symbol_Sec varchar2)  is
    Select * from sbsecurities Where trim(SYMBOL) =trim(v_Symbol_Sec);
v_Sbsecurities   c_Sbsecurities%Rowtype;
v_Return Number;
BEGIN
 Open c_Sbsecurities(v_Symbol);
 Fetch c_Sbsecurities into v_Sbsecurities;
 Close c_Sbsecurities;

 If v_Sbsecurities.SECTYPE ='006' then --Trai phieu
     v_Return:= 0;
 Else
    v_Return:= 1;
 End if;
 Return v_Return;
END;
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
