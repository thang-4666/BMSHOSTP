SET DEFINE OFF;
CREATE OR REPLACE FUNCTION GETBONDLISTINGQTTY(bond_codeid varchar2)
  RETURN  NUMBER
-- Lua chon Ma trai phieu, Load ra LISTINGQTTY

  IS
    v_COUPON NUMBER(20,4);
    v_currdate varchar2(100);
   -- Declare program variables as shown above
BEGIN


    SELECT TO_NUMBER(LISTINGQTTY)
    INTO v_COUPON
    FROM securities_info
        WHERE CODEID = bond_codeid;
    RETURN v_COUPON;

EXCEPTION
   WHEN others THEN
    RETURN 0;
END;

 
 
 
 
 
 
/
