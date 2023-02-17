SET DEFINE OFF;
CREATE OR REPLACE FUNCTION GETBONDEXPDATE(bond_codeid varchar2, RELEASEMOD VARCHAR2)
  RETURN  varchar2
-- Lua chon Ma trai phieu, Load ra ngay phat hanh tuong ung
--
-- ---------   ------  -------------------------------------------
  IS
    v_bondissuedate varchar2(100);
    v_currdate varchar2(100);
   -- Declare program variables as shown above
BEGIN
    SELECT varvalue INTO v_currdate FROM sysvar WHERE varname ='CURRDATE';

    SELECT CASE WHEN TRIM(RELEASEMOD) = 'O' THEN nvl(to_char(SBSECURITIES.EXPDATE,'DD/MM/RRRR'),v_currdate) ELSE v_currdate END

    INTO v_bondissuedate
    FROM SBSECURITIES
        WHERE SBSECURITIES.CODEID = bond_codeid;
    RETURN v_bondissuedate;

EXCEPTION
   WHEN others THEN
    RETURN v_currdate;
END;

 
 
 
 
 
 
/
