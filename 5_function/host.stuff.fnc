SET DEFINE OFF;
CREATE OR REPLACE FUNCTION stuff
   (SORIGIN VARCHAR, NSTART NUMBER, NLEN NUMBER, SREPTEXT VARCHAR) RETURN VARCHAR2 IS

STEMP VARCHAR2(2000);
BEGIN
STEMP := TRIM(SORIGIN);
IF (NSTART <= 0) OR (NLEN < 0) OR (NSTART > LENGTH(STEMP)) THEN
    STEMP := NULL;
ELSE
    STEMP := SUBSTR(STEMP,1,NSTART-1) || TRIM(SREPTEXT)
          || SUBSTR(STEMP,NSTART+NLEN,LENGTH(STEMP)-NSTART-NLEN+1);
END IF;
RETURN STEMP;
END;
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
