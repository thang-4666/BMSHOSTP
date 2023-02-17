SET DEFINE OFF;
CREATE OR REPLACE FUNCTION FN_GET_ISTRFCA (PV_BLOCKED IN NUMBER ,--06
                                           PV_TRADE IN NUMBER, --10
                                           PV_RIGHTOFFQTTY IN NUMBER,--14
                                           PV_CAQTTYRECEIV IN NUMBER,--15
                                           PV_CAQTTYDB IN NUMBER, --16
                                           PV_CAAMTRECEIV IN NUMBER, --17
                                           PV_RIGHTQTTY IN NUMBER )--18
RETURN VARCHAR2
iS
    v_result VARCHAR2(1);
BEGIN
    IF PV_RIGHTOFFQTTY + PV_CAQTTYRECEIV + PV_CAQTTYDB + PV_CAAMTRECEIV + PV_RIGHTQTTY >0 THEN
      IF PV_TRADE > 0 THEN
        v_result := 'T';
      ELSIF PV_BLOCKED >0 THEN
        v_result := 'H';
      ELSE
        v_result := 'N';
      END IF;
    ELSE
      v_result := 'N';
    END IF;
    RETURN v_result;
EXCEPTION WHEN OTHERS THEN
    RETURN 'N';
END;
/
