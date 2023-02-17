SET DEFINE OFF;
CREATE OR REPLACE FUNCTION getbondid(issdate varchar2,bond_codeid varchar2,term varchar2)
  RETURN  varchar2
-- Lua chon Ma trai phieu, Load ra to chuc phat hanh tuong ung
--
-- ---------   ------  -------------------------------------------
  IS
    v_bondissuer varchar2(100);
   -- Declare program variables as shown above
BEGIN
    SELECT REPLACE(issdate,'/','')||bond_codeid||term INTO v_bondissuer
        FROM dual ;
    RETURN v_bondissuer;
EXCEPTION
   WHEN others THEN
    RETURN bond_codeid;
END;
 
 
 
 
/
