SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_gen_desc_1113 (p_description varchar2,p_custodycd varchar2, p_fullname varchar2) return string
is
v_desc varchar2(500);
v_custodycd varchar2(500);
v_fullname varchar2(500);
begin
       v_desc:=nvl(p_description,'') ;
       v_custodycd:=nvl(p_custodycd,'');
       v_fullname:=nvl(p_fullname,'');
       if length(replace(v_custodycd,'.',''))=10 then
          v_desc:= replace(v_desc,'<$88CUSTODYCD>',v_custodycd);
       end if;
       if length(v_fullname)>0 then
          v_desc:= replace(v_desc,'<$90FULLNAME>',v_fullname);
       end if;
       return v_desc;
exception when others then
       return 'Chuyen khoan ra ngan hang qua CMND';
end;

 
 
 
 
 
 
 
 
 
 
 
/
