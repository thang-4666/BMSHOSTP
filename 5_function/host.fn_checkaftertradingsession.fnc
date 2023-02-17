SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_checkaftertradingsession
  RETURN number
  IS
  l_CONTROLCODE varchar2 (10);
  BEGIN
    --Kiem tra xem chung khoan co bi chan boi phien giao dich hay khong
    --01 Kiem tra xem da het phien Giao dich chua
    --Chi cho phep thuc hien khi da het phien giao dich
    /*if to_char(sysdate, 'hh24:mi')<='15:05' then
        Return -1;
    end if;
    --Check phien HO <> 'O,A,P'
    select trim(sysvalue) into l_CONTROLCODE from ordersys where sysname ='CONTROLCODE';
    if l_CONTROLCODE in ('P','O','A') then
        Return -1;
    end if;
    --Check phien HA <> '1'
    select trim(sysvalue) into l_CONTROLCODE from ordersys_ha where sysname ='CONTROLCODE';
    if l_CONTROLCODE in ('1') then
        Return -1;
    end if;*/
    return 0;

  EXCEPTION
  WHEN OTHERS
   THEN
      return -1;
  END fn_checkAfterTradingSession;
 
 
 
 
/
