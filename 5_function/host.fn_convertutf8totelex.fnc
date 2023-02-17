SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_convertutf8totelex (p_string in varchar2) return varchar2 is
l_string varchar2(3200);
l_matchpos number;
l_nextpos number;
l_curpos number;
begin
    l_string:= p_string;
    if(length(p_string) > 0) then
        FOR J In 1..length(p_string) LOOP
            if instr(UTF8NUMS.c_FindText,substr(p_string,J,1)) > 0 then
               l_curpos:= instr(UTF8NUMS.c_FindText,substr(p_string,J,1));
                l_matchpos:= instr(UTF8NUMS.c_ReplTextTelex,'|',1,l_curpos);
                l_nextpos:= instr(UTF8NUMS.c_ReplTextTelex,'|',1,l_curpos+1);
                l_string:= replace(l_string,substr(p_string,J,1), substr(UTF8NUMS.c_ReplTextTelex,l_matchpos+1,l_nextpos-l_matchpos-1));
            end if;
        END LOOP;
    end if;
    /*l_string := Replace(l_string, ',','');
    l_string := Replace(l_string, '%','');
    l_string := Replace(l_string, '^','');
    l_string := Replace(l_string, '&','');
    l_string := Replace(l_string, '>','');
    l_string := Replace(l_string, '<','');
    l_string := Replace(l_string, '-','');
    l_string := Replace(l_string, '.','');*/

    return l_string;
exception
   when others then
     return p_string;
end;
 
/
