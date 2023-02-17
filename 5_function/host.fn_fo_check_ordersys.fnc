SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_fo_check_ordersys
  (
  p_tradeplace IN varchar2
  )
  RETURN  number IS
--
-- To modify this template, edit file FUNC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Check status of tradeplace
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- SONLT    16/04/2015 Created
-- ---------   ------  -------------------------------------------
   v_controlcode varchar2(10);
   v_tradingid varchar2(10);
   v_tradeplace varchar2(10);
   v_status number;

   -- Declare program variables as shown above
BEGIN
    v_status := 0;
    v_tradeplace := p_tradeplace;
    plog.error('v_tradeplace: '||v_tradeplace);
    IF p_tradeplace = '001' THEN --Voi HOSE thi check control code  = C thi chan ko cho lenh len nua
        begin
            select nvl(sysvalue,'') into v_controlcode from ordersys where sysname = 'CONTROLCODE'; --C
        EXCEPTION
          WHEN OTHERS THEN
            v_controlcode := '';
        end;
        IF v_controlcode = 'C' THEN
            v_status := -1;
        END IF;
    ELSIF p_tradeplace = '002' THEN
        begin
            select nvl(sysvalue,'') into v_tradingid from ordersys_ha where sysname = 'TRADINGID';
            select nvl(sysvalue,'') into v_controlcode from ordersys_ha where sysname = 'CONTROLCODE';
        EXCEPTION
          WHEN OTHERS THEN
            v_tradingid := '';
        end;
        IF (v_tradingid = 'PCLOSE' or v_tradingid = 'CLOSE_BL')   and v_controlcode = '1' THEN
            v_status := -1;
        END IF;
    END IF;
    plog.error(v_status);
    return v_status;
EXCEPTION
   WHEN others THEN
    plog.error(sqlerrm || dbms_utility.format_error_backtrace);
       RETURN 0 ;
END;
 
/
