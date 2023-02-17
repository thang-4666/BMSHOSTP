SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_get_cdval(p_CDVAL in varchar2, p_CDTYPE in varchar2, p_CDNAME in varchar2)
  RETURN  varchar2 IS
  V_RESULT  number;
  v_checkloop boolean;
  v_count   number;
BEGIN
    if nvl(p_CDVAL,'XXXX') = 'XXXX' then
        if p_CDNAME = 'TLGROUP' then
            begin
                SELECT nvl(to_number(MAX(CDVAL)),0) into V_RESULT FROM ALLCODE where cdtype = p_CDTYPE and cdname = p_CDNAME;
            exception when others then
                V_RESULT := '0';
            end;
            v_checkloop := true;
            WHILE v_checkloop
            LOOP
               V_RESULT := V_RESULT +1;
               SELECT count(*) into v_count FROM ALLCODE
               where cdtype = p_CDTYPE and cdname = p_CDNAME and cdval =  V_RESULT;
               if v_count = 0 then
                    v_checkloop := false;
               end if;
            END LOOP;
            return lpad(to_char(V_RESULT),3,'0');
        else
            return NULL;
        end if;
    else
       return p_CDVAL;
    end if;
EXCEPTION
   WHEN OTHERS THEN
    RETURN NULL;
END;
 
 
 
/
