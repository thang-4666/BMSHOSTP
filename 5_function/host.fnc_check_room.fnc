SET DEFINE OFF;
CREATE OR REPLACE FUNCTION FNC_CHECK_ROOM
  ( v_Symbol IN varchar2,
    v_Volumn In number,
    v_Custodycd in varchar2,
    v_BorS in  Varchar2)
  RETURN  number IS

Cursor c_SecInfo(vc_Symbol varchar2) is
    Select CURRENT_ROOM from ho_Sec_info where
    Trim(CODE) =Trim(vc_Symbol);
 v_CurrentRoom Number;
 v_Result varchar2(10);
BEGIN
--  return '1';
   If v_BorS ='B' and substr(v_Custodycd,4,1) ='F' then
        Open c_SecInfo(v_Symbol);
        Fetch c_SecInfo into v_CurrentRoom;
        If c_SecInfo%notfound  Or v_CurrentRoom < v_Volumn Then
           v_Result :='0';
        Else
           v_Result :='1';
        End if;
        Close c_SecInfo;
   Else
        v_Result :='1';
   End if;
   RETURN v_Result;
END;
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
