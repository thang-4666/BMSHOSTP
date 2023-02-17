SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_gen_desc_2268 (p_desccription varchar2,p_custodycd varchar2, p_DesCustodycd varchar2) return string
is
v_desc varchar2(500);
v_custodycd varchar2(500);
v_DesCustodycd varchar2(500);
v_FromType varchar2(50);
v_ToType varchar2(50);
begin
       v_desc:=nvl(p_desccription,'') ;
       v_custodycd:=nvl(p_custodycd,'');
       v_DesCustodycd:=nvl(p_DesCustodycd,'');

       if length(replace(v_custodycd,'.',''))=10 and  length(replace(v_DesCustodycd,'.',''))=10 then
          select aft.mnemonic into v_FromType from afmast af, aftype aft where af.actype = aft.actype and af.acctno = v_custodycd;
          select aft.mnemonic into v_ToType from afmast af, aftype aft where af.actype = aft.actype and af.acctno = v_DesCustodycd;

          --v_desc:= replace(v_desc,'<$88CUSTODYCD>',v_FromType);
          --v_desc:= replace(v_desc,'<$89CUSTODYCD>',v_ToType);
            v_desc:= 'Từ tiểu khoản (' || p_custodycd || '-' || v_FromType || ') sang tiểu khoản (' || p_DesCustodycd || '-'  || v_ToType || ') (Tele)';
       end if;
       return v_desc;
exception when others then
       return 'Chuyen khoan noi bo (Tele)';
end;

 
 
 
 
 
 
/
