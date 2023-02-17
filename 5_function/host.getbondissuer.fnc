SET DEFINE OFF;
CREATE OR REPLACE FUNCTION getbondissuer(bond_codeid varchar2)
  RETURN  varchar2
-- Lua chon Ma trai phieu, Load ra to chuc phat hanh tuong ung
--
-- ---------   ------  -------------------------------------------
  IS
    v_bondissuer varchar2(100);
   -- Declare program variables as shown above
BEGIN
    SELECT ISSUERS.FULLNAME INTO v_bondissuer
        FROM ISSUERS, SBSECURITIES
            WHERE ISSUERS.ISSUERID = SBSECURITIES.ISSUERID
            AND SBSECURITIES.symbol = bond_codeid
            AND SBSECURITIES.SECTYPE IN ('003','006','222');
    RETURN v_bondissuer;
EXCEPTION
   WHEN others THEN
    RETURN bond_codeid;
END;

 
 
 
 
/
