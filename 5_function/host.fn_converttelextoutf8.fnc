SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_converttelextoutf8 (p_string in varchar2) return varchar2 is
l_string varchar2(4000);
l_telexStr varchar2(4000);
l_matchpos number;
l_nextpos number;
l_curpos number;
l_idx   number;
l_frchar  varchar2(20);
l_tochar  varchar2(20);
begin
    l_string:= p_string;
    if(length(p_string) > 0) then
        l_telexStr := UTF8NUMS.c_ReplTextTelex;
        l_telexStr := REPLACE(l_telexStr,2);

        l_idx := 0;
        WHILE (length(l_telexStr)>0)
        LOOP
            l_nextpos := instr(l_telexStr,'|');
            l_frchar := substr(l_telexStr,1,l_nextpos-1);
            if length(l_frchar)>0 then
                l_idx := l_idx + 1;
                l_tochar := substr(UTF8NUMS.c_FindText,l_idx,1);
                l_string := replace(l_string,l_frchar,l_tochar);
            end if;
            l_telexStr := substr(l_telexStr,l_nextpos+1);
            
        END LOOP;
        
        
    end if;
    

    return l_string;
exception
   when others then
     return p_string;
end;
 
/
