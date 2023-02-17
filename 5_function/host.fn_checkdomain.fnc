SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_checkdomain(
   pv_afacctno VARCHAR2,
   pv_symbol VARCHAR2,
   pv_isSymbol BOOLEAN DEFAULT TRUE)
RETURN BOOLEAN
IS
   v_strdomain varchar2(10);
   v_count number;
BEGIN

   --
   begin
        IF pv_isSymbol THEN
          SELECT domain INTO v_strdomain FROM sbsecurities WHERE symbol = pv_symbol;
       ELSE
          SELECT domain INTO v_strdomain FROM sbsecurities WHERE codeid = pv_symbol;
       END IF;
   EXCEPTION WHEN OTHERS THEN
    v_strdomain:='';
    END;

   SELECT count(d.domaincode) into v_count
   FROM afmast af, cfdomain d
   WHERE  D.CUSTID = af.CUSTID
   and d.vsdstatus in ('C','U')
   and d.deltd = 'N'
   and af.acctno = pv_afacctno
   and d.domaincode = v_strdomain;

   plog.error('day la log v_count: '||v_count);
   if v_count > 0 then
     return true;
   else
     return false;
   end if;
EXCEPTION WHEN OTHERS THEN

   RETURN FALSE;
END;
/
