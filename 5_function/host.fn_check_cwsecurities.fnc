SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_check_cwsecurities
  ( p_symbol IN varchar2)
  RETURN  VARCHAR2 IS
   v_currdate date;
   v_count number;
BEGIN

    v_currdate := cspks_system.fn_get_sysvar('SYSTEM','CURRDATE');

    select count(*) into v_count
    from sbsecurities
    where symbol=p_symbol and sectype='011' and lasttradingdate<to_date(v_currdate,'DD/MM/RRRR');

    RETURN v_count;

EXCEPTION
   WHEN others THEN
    RETURN v_count ;
END;
 
/
