SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_cutoffutf8 (p_string in varchar2) return varchar2 is
l_string varchar2(3200);
begin
    l_string:= p_string;
    FOR J In 1..length(p_string) LOOP
        if instr(UTF8NUMS.c_FindText,substr(p_string,J,1)) > 0 then
            l_string:= replace(l_string,substr(p_string,J,1),substr(UTF8NUMS.c_ReplText,instr(UTF8NUMS.c_FindText,substr(p_string,J,1)),1));
        end if;
    END LOOP;

    l_string := Replace(l_string, ',','');
    l_string := Replace(l_string, '%','');
    l_string := Replace(l_string, '^','');
    l_string := Replace(l_string, '&','');
    l_string := Replace(l_string, '>','');
    l_string := Replace(l_string, '<','');
    l_string := Replace(l_string, '-','');
    l_string := Replace(l_string, '.','');

    return l_string;
end;
 
 
/
