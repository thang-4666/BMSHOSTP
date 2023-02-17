SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_getcfrptname( p_afacctno IN VARCHAR2)
    RETURN varchar2 IS
    l_reportname varchar2(100);
    V_COUNT NUMBER;
BEGIN
  SELECT COUNT(*) INTO V_COUNT FROM CFMAST CF WHERE CF.CUSTID  IN (SELECT CUSTBANK FROM ADVRESLNK WHERE CUSTID=p_afacctno )
            AND CF.ISBANKING='Y' AND EXISTS (SELECT BANKID FROM CFLIMIT WHERE LMSUBTYPE='ADV' AND BANKID= CF.CUSTID);
 --locpt chinh lai vi hien tai bms chua phan biet cac mau voi tung loai khach hang
 IF V_COUNT< 1  THEN
  /*SELECT max(case when cf.custtype = 'I' and cf.country = '234' then 'CFAF01|CFAF11|CFAF15'
            when cf.custtype = 'B' and cf.country = '234' then 'CFAF02|CFAF12|CFAF15'
            when cf.custtype = 'I' and cf.country <> '234' then 'CFAF03|CFAF13|CFAF15'
            when cf.custtype = 'B' and cf.country <> '234' then 'CFAF04|CFAF14|CFAF15'
            else '' end)
           into l_reportname
    from cfmast cf
    where cf.custid = p_afacctno;*/
    l_reportname:='CFAF01|CFAF02|CFAF15|CFAF03';

ELSE
  /*  SELECT max(case when cf.custtype = 'I' and cf.country = '234' then 'CFAF01|CFAF11|CFAF15|CFAF16'
            when cf.custtype = 'B' and cf.country = '234' then 'CFAF02|CFAF12|CFAF15|CFAF16'
            when cf.custtype = 'I' and cf.country <> '234' then 'CFAF03|CFAF13|CFAF15|CFAF16'
            when cf.custtype = 'B' and cf.country <> '234' then 'CFAF04|CFAF14|CFAF15|CFAF16'
            else '' end)
           into l_reportname
    from cfmast cf
    where cf.custid = p_afacctno;*/
     l_reportname:='CFAF01|CFAF02|CFAF15|CFAF03';
END IF;
    RETURN l_reportname;


EXCEPTION
   WHEN OTHERS THEN
    RETURN '';
END;
 
 
 
/
