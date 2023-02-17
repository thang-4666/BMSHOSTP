SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_get_controlcode
  ( p_symbol IN varchar2, p_oddlot IN varchar2 default 'N')
  RETURN  VARCHAR2 IS
   v_tradeplace varchar2(10);
   v_controlcode varchar2(10);
BEGIN
    v_controlcode:='-1';
    Select Tradeplace into v_tradeplace
    From sbsecurities
    Where symbol=p_symbol;
    --Thang chinh sua lo le HSX 27-04-2022
    /*If v_tradeplace = '001' then
        Select sysvalue into v_controlcode
        From ordersys
        Where sysname='CONTROLCODE';*/
    If v_tradeplace = '001' AND p_oddlot = 'N'  then
        Select sysvalue into v_controlcode
        From ordersys
        Where sysname='CONTROLCODE';
    ELSIF v_tradeplace = '001' AND p_oddlot = 'Y' THEN
      SELECT sysvalue into v_controlcode
      FROM ordersys
      WHERE sysname='CONTROLCODE_ODD_LOT';
  --End Thang chinh sua lo le HSX 27-04-2022
    Else
        --Begin HNX_update|iss1569
         SELECT hb.tradingsessionid into v_controlcode
         From hasecurity_req hr,  HA_BRD hb
         Where
           hb.BRD_CODE = hr.tradingsessionsubid
           AND hr.symbol=p_symbol;
      --End HNX_update|iss1569

    End if;
    RETURN v_controlcode ;
EXCEPTION
   WHEN others THEN
    RETURN v_controlcode ;
END;
 
/
