SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_gen_desc_1120 (p_desccription varchar2,p_custodycd varchar2, p_DesCustodycd varchar2) return string
is
v_desc varchar2(500);
v_custodycd varchar2(500);
v_DesCustodycd varchar2(500);
v_FromType varchar2(50);
v_ToType varchar2(50);
begin
       v_desc:=nvl(p_desccription,'') ;
       --v_custodycd:=nvl(p_custodycd,'');
       ---v_DesCustodycd:=nvl(p_DesCustodycd,'');

       select max(cf.custodycd) into v_custodycd from cfmast cf, afmast af
       where af.custid = cf.custid and af.acctno = replace(p_custodycd,'.','');

       select max(cf.custodycd) into v_DesCustodycd from cfmast cf, afmast af
       where af.custid = cf.custid and af.acctno = replace(p_DesCustodycd,'.','');

       if length(replace(p_custodycd,'.',''))=10 and  length(replace(p_DesCustodycd,'.',''))=10 then
          select aft.mnemonic into v_FromType from afmast af, aftype aft where af.actype = aft.actype and af.acctno = replace(p_custodycd,'.','');
          select aft.mnemonic into v_ToType from afmast af, aftype aft where af.actype = aft.actype and af.acctno = replace(p_DesCustodycd,'.','');
            if v_custodycd = v_DesCustodycd then
                v_desc:= 'Chuyển khoản nội bộ cùng số lưu ký từ tiểu khoản (' || p_custodycd || '-' || v_FromType || ') sang tiểu khoản (' || p_DesCustodycd || '-'  || v_ToType || ')';
            else
                v_desc:= 'Chuyển khoản nội bộ khác số lưu ký từ tiểu khoản (' || p_custodycd || '-' || v_FromType || ') sang tiểu khoản (' || p_DesCustodycd || '-'  || v_ToType || ')';
            end if;
       end if;
       return v_desc;
exception when others then
       return 'Chuyen khoan noi bo';
end;
 
/
