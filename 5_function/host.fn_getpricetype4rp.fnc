SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_getpricetype4rp (pv_TRADEPLACE IN VARCHAR2)
RETURN varchar2
iS
    v_result VARCHAR2(003);
    l_hnxTRADINGID varchar2(20);
    l_HOmktstatus varchar2(20);
BEGIN
    If pv_TRADEPLACE = '005' then
       v_result:='LO';
    elsif pv_TRADEPLACE = '002'  then
         SELECT sysvalue
            INTO l_hnxTRADINGID
         FROM ordersys_ha
         WHERE sysname = 'TRADINGID';
         If l_hnxTRADINGID in ('CLOSE','CLOSE_BL') then
            v_result:='ATC';
         else
            v_result:='LO';
         end if;
    elsif pv_TRADEPLACE = '001'   then
        SELECT sysvalue
             INTO l_HOmktstatus
        FROM ordersys
        WHERE sysname = 'CONTROLCODE';

        If l_HOmktstatus IN ('P','J') THEN
           v_result:='ATO';
        elsif  l_HOmktstatus IN ('A')   THEN
            v_result:='ATC';
        ELSE
             v_result:='LO';
        END IF;
    End if;
    RETURN v_result;
EXCEPTION WHEN OTHERS THEN
    RETURN 'LO';
END;
 
 
 
 
/
