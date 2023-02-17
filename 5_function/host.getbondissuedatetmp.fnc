SET DEFINE OFF;
CREATE OR REPLACE FUNCTION getbondissuedatetmp(bond_codeid In varchar2, PV_ISSDATETMP In VARCHAR2, PV_ISSDATE In VARCHAR2)
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
    BEGIN
    SELECT nvl(to_char(SBSECURITIES.ISSUEDATE,'DD/MM/RRRR'),v_currdate) INTO v_bondissuedate
    FROM SBSECURITIES
        WHERE SBSECURITIES.SYMBOL = bond_codeid
            AND SBSECURITIES.SECTYPE IN ('003','006','222');
    EXCEPTION   WHEN OTHERS THEN
       v_bondissuedate :=  v_currdate;
    END;
    IF TO_DATE(PV_ISSDATETMP,'DD/MM/RRRR') <> TO_DATE(v_bondissuedate,'DD/MM/RRRR') THEN
        RETURN v_bondissuedate;
    ELSE
        RETURN PV_ISSDATE;
    END IF;

EXCEPTION
   WHEN others THEN
    RETURN v_currdate;
END;

 
 
 
 
/
