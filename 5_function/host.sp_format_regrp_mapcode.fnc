SET DEFINE OFF;
CREATE OR REPLACE FUNCTION SP_FORMAT_REGRP_MAPCODE (p_grpid IN NUMBER) return varchar2
IS
    l_format VARCHAR2(10);
    l_mapcode VARCHAR2(250);
    l_segment VARCHAR2(10);
    l_prid NUMBER;
    l_length NUMBER;
BEGIN
    l_format := '000000';
    l_length := length(l_format);
    l_prid := p_grpid;
    l_segment := l_format || to_char(l_prid);
    l_segment := SUBSTR(l_segment, length(l_segment)-l_length+1,l_length);
    l_mapcode := l_segment;
    LOOP
         SELECT NVL(PRGRPID,0) INTO l_prid FROM REGRP WHERE AUTOID=l_prid;
         EXIT WHEN l_prid = 0;
         l_segment := l_format || to_char(l_prid);
         l_segment := SUBSTR(l_segment, length(l_segment)-l_length+1,l_length);
         l_mapcode :=  l_segment || '.' || l_mapcode;
    END LOOP;
    RETURN l_mapcode;
EXCEPTION
WHEN OTHERS
   THEN
      RETURN NULL;
END;

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
