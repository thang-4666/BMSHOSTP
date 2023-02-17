SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "LN_CLNSCHD"
   (INDATE IN VARCHAR2)
   IS
BEGIN
   INSERT INTO LNSCHDHIST
       SELECT * FROM LNSCHD WHERE NML = 0 AND OVD = 0 AND INTNMLACR = 0 AND FEE = 0 AND INTDUE = 0 AND INTOVD = 0 AND FEEDUE = 0 AND FEEOVD = 0 AND INTOVDPRIN = 0;
   DELETE LNSCHD WHERE NML = 0 AND OVD = 0 AND INTNMLACR = 0 AND FEE = 0 AND INTDUE = 0 AND INTOVD = 0 AND FEEDUE = 0 AND FEEOVD = 0 AND INTOVDPRIN = 0;
EXCEPTION
     WHEN others THEN
        return;
END; -- Procedure

 
 
 
 
/
