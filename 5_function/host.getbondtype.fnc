SET DEFINE OFF;
CREATE OR REPLACE FUNCTION getbondtype(bond_codeid varchar2)
  RETURN  varchar2
-- Lua chon Ma trai phieu, Load ra loai trai phieu tuong ung
--
-- ---------   ------  -------------------------------------------
  IS
    v_bondtype varchar2(100);
   -- Declare program variables as shown above
BEGIN
    SELECT ALLCODE.CDCONTENT INTO v_bondtype
    FROM ALLCODE,SBSECURITIES
        WHERE ALLCODE.CDTYPE = 'SA'
            AND ALLCODE.CDNAME = 'BUSINESSTYPE'
            AND ALLCODE.CDVAL = SBSECURITIES.BONDTYPE
            AND SBSECURITIES.symbol = bond_codeid
            AND SBSECURITIES.SECTYPE IN ('003','006','222');
    RETURN v_bondtype;
EXCEPTION
   WHEN others THEN
    RETURN bond_codeid;
END;

 
 
 
 
/
