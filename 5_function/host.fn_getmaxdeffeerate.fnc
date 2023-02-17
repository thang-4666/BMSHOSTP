SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_getmaxdeffeerate(p_afacctno varchar2)
return number
is
l_maxdeffeerate number(10,4);
begin
select max(odt.deffeerate) into l_maxdeffeerate
from afmast af, afidtype afid, odtype odt
where af.actype = afid.aftype and afid.objname = 'OD.ODTYPE' and odt.actype = afid.actype and odt.status = 'Y' and af.acctno = p_afacctno;
return nvl(l_maxdeffeerate,0.3)/100;
exception when others then
select nvl(max(deffeerate),0) into l_maxdeffeerate from odtype where status = 'Y';
return l_maxdeffeerate;
end;

 
 
 
 
 
 
 
 
 
 
 
 
 
/
