SET DEFINE OFF;
CREATE OR REPLACE FUNCTION GETCOSTPRICE(acctno IN  varchar, in_date IN varchar)
  RETURN number IS
  v_Result number(18,5);

  v_acctno  varchar(200) ;
  v_in_date   varchar(20);
  v_strnextdate date;
BEGIN
	v_acctno:=acctno;
	v_in_date:=in_date;
	select min(sbdate) into v_strnextdate from sbcldr where cldrtype='000' and sbdate > to_date(v_in_date,'DD/MM/YYYY') and HOLIDAY='N';
  SELECT COSTPRICE INTO V_RESULT
    FROM SECOSTPRICE SECO,
    ( SELECT max(autoid) autoid ,ACCTNO ,MAX(TXDATE) TXDATE FROM SECOSTPRICE
      WHERE TXDATE <= v_strnextdate  AND ACCTNO = v_acctno
      GROUP BY ACCTNO
      )SECOMAX
      WHERE SECO.TXDATE = SECOMAX.TXDATE
      AND SECO.autoid = SECOMAX.autoid
      AND SECO.ACCTNO = SECOMAX.ACCTNO;
    RETURN v_Result;
END;
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
