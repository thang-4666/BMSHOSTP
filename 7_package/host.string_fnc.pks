SET DEFINE OFF;
CREATE OR REPLACE PACKAGE string_fnc
IS

TYPE t_array IS TABLE OF VARCHAR2(50)
   INDEX BY BINARY_INTEGER;

FUNCTION SPLIT (p_in_string VARCHAR2, p_delim VARCHAR2) RETURN t_array;

END;

 
 
 
 
 
 
 
 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY string_fnc
IS
   FUNCTION SPLIT (p_in_string VARCHAR2, p_delim VARCHAR2) RETURN t_array
   IS
        i       number :=0;
        pos     number :=0;
        lv_str  varchar2(50) := p_in_string;
        strings t_array;
   BEGIN
      pos := instr(lv_str,p_delim,1,1);
      WHILE ( pos != 0) LOOP
         i := i + 1;
         strings(i) := substr(lv_str,1,pos-1);
         lv_str := substr(lv_str,pos+1,length(lv_str));
         pos := instr(lv_str,p_delim,1,1);
         IF pos = 0 THEN
            strings(i+1) := lv_str;
         END IF;
      END LOOP;
      RETURN strings;
   END SPLIT;
END;

/
