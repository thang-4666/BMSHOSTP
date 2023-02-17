SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_GetRootOrderID
    (p_OrderID       IN  VARCHAR2
    ) RETURN VARCHAR2
AS
    v_Found     BOOLEAN;
    v_TempOrderid   varchar2(20);
    v_TempRootOrderID varchar2(20);

BEGIN
    v_Found := FALSE;
    v_TempOrderid := p_OrderID;

    WHILE v_Found = FALSE
    LOOP
        SELECT NVL(OD.REFORDERID, '0000')
        INTO v_TempRootOrderID
        FROM ODMAST OD WHERE OD.ORDERID = v_TempOrderid;
        IF v_TempRootOrderID <> '0000' THEN
            v_TempOrderid := v_TempRootOrderID;
            v_Found := FALSE;
        ELSE
            v_Found := TRUE;
        END IF;
    END LOOP;

    RETURN v_TempOrderid;

EXCEPTION
  WHEN OTHERS THEN
    RETURN '0000';
END;
 
 
 
 
/
