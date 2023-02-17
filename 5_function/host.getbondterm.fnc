SET DEFINE OFF;
CREATE OR REPLACE FUNCTION getbondterm(bond_codeid varchar2)
  RETURN  varchar2
-- Lua chon Ma trai phieu, Load ra ky han tuong ung
--
-- ---------   ------  -------------------------------------------
  IS
    v_bondterm varchar2(100);
   -- Declare program variables as shown above
BEGIN
    SELECT  term || ' ' || (case typeterm when 'Y' then 'Năm' when 'M' then 'Tháng' else 'Tuần' end) INTO v_bondterm
        FROM SBSECURITIES WHERE SBSECURITIES.symbol = bond_codeid
            AND SBSECURITIES.SECTYPE IN ('003','006','222');
    RETURN v_bondterm;
EXCEPTION
   WHEN others THEN
    RETURN bond_codeid;
END;
 
 
 
 
/
