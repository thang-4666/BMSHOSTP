SET DEFINE OFF;
CREATE OR REPLACE FUNCTION getbondissuedate(bond_codeid In varchar2)
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

    SELECT nvl(to_char(SBSECURITIES.ISSUEDATE,'DD/MM/RRRR'),v_currdate) INTO v_bondissuedate
    FROM SBSECURITIES
        WHERE SBSECURITIES.SYMBOL = bond_codeid
            AND SBSECURITIES.SECTYPE IN ('003','006','222');
    RETURN v_bondissuedate;

EXCEPTION
   WHEN others THEN
    RETURN v_currdate;
END;

 
 
 
 
/
