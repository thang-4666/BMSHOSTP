SET DEFINE OFF;
CREATE OR REPLACE FUNCTION check_custodycd_duplucate (p_custodycd IN VARCHAR2) RETURN NUMBER
IS
    l_count NUMBER;
    l_return VARCHAR2(10);
    l_custodycd VARCHAR2(10);

BEGIN
    l_custodycd := SUBSTR(p_custodycd,5,6);
    FOR i IN 1..6
    LOOP
        SELECT SUBSTR(l_custodycd,i,1) INTO l_count FROM dual;
        IF INSTR(SUBSTR(l_custodycd,i+1,LENGTH(l_custodycd)),l_count) > 0 THEN
            l_return := 1;
            EXIT;
        ELSE
            l_return := 0;
        END IF;
    END LOOP;
    RETURN l_return;
EXCEPTION WHEN OTHERS THEN
    RETURN 0;
END;

 
 
 
 
/
