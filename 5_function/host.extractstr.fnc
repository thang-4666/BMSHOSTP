SET DEFINE OFF;
CREATE OR REPLACE FUNCTION extractstr
  ( STR VARCHAR2,
    DELIMITER CHAR,
    POST INTEGER)
  RETURN  VARCHAR2 IS
  E INTEGER;
  tmp INTEGER;
  tmpSTR VARCHAR2(200);
BEGIN
  E:=INSTR(STR,DELIMITER);
  if E>0 then
    tmp:=1;
    tmpSTR:=STR;
    WHILE tmp<POST LOOP
    tmpSTR:=SUBSTR(tmpSTR,E+1,LENGTH(tmpSTR)-E);
    E:=INSTR(tmpSTR,DELIMITER);
    tmp:=tmp+1;
    END LOOP;
    RETURN SUBSTR(tmpSTR,1,E-1);
  else
    if POST=1 then
      return STR;
    else
      return '';
    end if;
  end if;
EXCEPTION
   WHEN OTHERS THEN
      RETURN '';

END;
 
 

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
