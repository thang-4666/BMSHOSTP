SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fnc_check_traderid
  ( v_Machtype IN varchar2,
    v_BORS IN varchar2,
    v_Via in varchar2 default null)
  RETURN  number IS

Cursor c_Putthourgh(v_BuySell varchar2) is
    Select TRADERID from Traderid where
    substr(firm,-2,2) = (select substr(sysvalue,-2,2) from ordersys where SYSNAME ='FIRM')
    and nvl(trim(status),' ') <>'S' And Via ='F'
    and nvl(trim(PUTTHROUGH_HALT),' ') <> 'A' and  nvl(trim(PUTTHROUGH_HALT),' ') <> trim(v_BuySell);

Cursor c_Normal(v_BuySell varchar2,vc_Via varchar2) is
    Select TRADERID from Traderid where
    substr(firm,-2,2) = (select substr(sysvalue,-2,2) from ordersys where SYSNAME ='FIRM')
    and nvl(trim(status),' ') <>'S' And Via =vc_Via
    and nvl(trim(AUTOMATCH_HALT),' ') <> 'A' and  nvl(trim(AUTOMATCH_HALT),' ') <> trim(v_BuySell);
 v_TraderID varchar2(10);
 v_Via_Tmp  varchar2(10);
BEGIN
    v_TraderID :='1';

    If v_Via ='O' then
        v_Via_Tmp :='O';
    Else  --tai san, hoac Tele deu cho ve F
        v_Via_Tmp :='F';
    End if;

    If v_Machtype ='P' then
        Open c_Putthourgh(v_BORS);
        Fetch c_Putthourgh into v_TraderID;
        If c_Putthourgh%notfound then
           v_TraderID :='0';
        End if;
        Close c_Putthourgh;
        RETURN v_TraderID;
    Else
        Open c_Normal(v_BORS,v_Via_Tmp);
        Fetch c_Normal into v_TraderID;
        If c_Normal%notfound then
             v_TraderID :='0';
        End if;
        Close c_Normal;
        RETURN v_TraderID;
    End if;
END;
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
