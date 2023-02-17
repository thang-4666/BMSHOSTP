SET DEFINE OFF;
CREATE OR REPLACE FUNCTION getclearday(clearcd IN char,sbcldrtype in varchar, FromDate IN Date, ToDate IN Date)
  RETURN number IS
  v_Result number(18,5);
BEGIN
	if FromDate=ToDate then
	RETURN 0;
	end if;
	if clearcd = 'N'  then
        v_Result:=ToDate-FromDate;
	elsif clearcd = 'B' then
	    SELECT nvl(SUM(CASE WHEN HOLIDAY='Y' THEN 0 ELSE 1 END),0) into v_Result FROM SBCLDR
            WHERE SBDATE >FromDate AND SBDATE <=ToDate
            AND CLDRTYPE='004';
	end if;
    RETURN v_Result;
END;
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
