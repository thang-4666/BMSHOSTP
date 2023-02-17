SET DEFINE OFF;
CREATE OR REPLACE FUNCTION GETBONDCOUPON(bond_codeid varchar2)
  RETURN  NUMBER
-- Lua chon Ma trai phieu, Load ra TI LO COUPON
--
-- ---------   ------  -------------------------------------------
  IS
    v_COUPON NUMBER(20,4);
    v_currdate varchar2(100);
   -- Declare program variables as shown above
BEGIN


    SELECT TO_NUMBER(INTCOUPON)
    INTO v_COUPON
    FROM SBSECURITIES
        WHERE SBSECURITIES.CODEID = bond_codeid
            AND SBSECURITIES.SECTYPE IN ('003','006','222');
    RETURN v_COUPON;

EXCEPTION
   WHEN others THEN
    RETURN 0;
END;

 
 
 
 
 
 
/
