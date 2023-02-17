SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fnc_check_p_stockbond
  ( v_Msgtype Varchar2,v_Symbol IN Varchar2)
  RETURN  number IS

Cursor c_Msgmast(v_Msgtype varchar2)  is
    Select * from Msgmast Where RORS ='S' And trim(msgtype) =trim(v_Msgtype);
Cursor c_Sbsecurities(v_Symbol_Sec varchar2)  is
    Select * from sbsecurities Where trim(SYMBOL) =trim(v_Symbol_Sec);
Cursor c_Sc is select SYSVALUE from ordersys where SYSNAME ='CONTROLCODE';
v_Sc varchar2(10);

v_Msgmast   c_Msgmast%Rowtype;
v_Sbsecurities   c_Sbsecurities%Rowtype;
v_Return Number;
BEGIN
 Open c_Sc;
 Fetch c_Sc into v_Sc;
 Close c_Sc;

 Open c_Msgmast(v_Msgtype);
 Fetch c_Msgmast into v_Msgmast;
 Close c_Msgmast;

 Open c_Sbsecurities(v_Symbol);
 Fetch c_Sbsecurities into v_Sbsecurities;
 Close c_Sbsecurities;

 If v_Sbsecurities.SECTYPE ='006' then --Trai phieu
   If instr(Nvl(v_Msgmast.bond,' '),v_Sc)>0 then
     v_Return:= 1;
    Else
    v_Return:= 0;
    End if;
 Else
    If instr(nvl(v_Msgmast.stock,' '),v_Sc)>0 then
     v_Return:= 1;
    Else
     v_Return:= 0;
    End if;
 End if;
 Return v_Return;
END;
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
