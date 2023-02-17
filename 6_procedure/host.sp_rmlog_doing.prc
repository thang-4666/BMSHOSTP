SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE sp_rmlog_doing
   (p_ACTION    IN varchar2,
    p_RMTYPE    IN varchar2,
    p_IPADDRESS IN varchar2,
    p_BUSDATE   IN varchar2,
    P_TLID      IN varchar2,
    p_err_code  OUT varchar2)
   IS
v_count number;
V_strERROR VARCHAR2(1000);
BEGIN
    IF p_ACTION = 'I' THEN
        INSERT INTO RMLOG (RMTYPE,IPADDRESS,SERVERDATE,SERVERTIME,TXDATE,TLID)
        SELECT p_RMTYPE, p_IPADDRESS, TO_CHAR(SYSDATE, 'DD/MM/RRRR'),
            TO_CHAR (SYSDATE, 'HH24:MI:SS'), p_BUSDATE,P_TLID FROM DUAL;
        p_err_code := '0';
    ELSIF p_ACTION = 'D' THEN
        DELETE FROM RMLOG WHERE RMTYPE = p_RMTYPE AND IPADDRESS = p_IPADDRESS;
    END IF;

EXCEPTION
    WHEN OTHERS
   THEN

p_err_code := '-670407';
END; -- Procedure

 
 
 
 
/
