SET DEFINE OFF;
CREATE OR REPLACE FUNCTION GETBONDTOTALQTTY(bond_codeid varchar2)
  RETURN  NUMBER
-- Lua chon Ma trai phieu, Load ra LISTINGQTTY

  IS
    v_COUPON NUMBER(20,4);
    v_currdate varchar2(100);
   -- Declare program variables as shown above
BEGIN


    SELECT TO_NUMBER(SE.LISTINGQTTY) * TO_NUMBER(SB.parvalue)
    INTO v_COUPON
    FROM securities_info SE, sbsecurities SB
        WHERE SE.CODEID = SB.CODEID AND SE.CODEID = bond_codeid;
    RETURN v_COUPON;

EXCEPTION
   WHEN others THEN
    RETURN 0;
END;

 
 
 
 
 
 
/
