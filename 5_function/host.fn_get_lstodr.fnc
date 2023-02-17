SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_get_lstodr(p_LSTODR in number,p_CDTYPE in varchar2, p_CDNAME in varchar2)
  RETURN  number IS
  V_RESULT         NUMBER;
BEGIN
    if nvl(p_LSTODR,9999999) = 9999999 then
        begin
        SELECT max(lstodr) into V_RESULT FROM ALLCODE where cdtype = p_CDTYPE and cdname = p_CDNAME;
        exception when others then
            V_RESULT := 0;
        end;
        RETURN V_RESULT + 1;
    else
        return p_LSTODR;
    end if;
EXCEPTION
   WHEN OTHERS THEN
    RETURN 0;
END;

 
 
 
 
/
