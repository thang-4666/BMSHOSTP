SET DEFINE OFF;
CREATE OR REPLACE FUNCTION datediff(DatePart IN char, FromDate IN Date, ToDate IN Date)
  RETURN number IS

	v_DatePart varchar2(20);
	v_Result number(18,5);
	v_MonthFrom number(18,0);
	v_MonthTo number(18,0);
	v_YearFrom number(18,0);
	v_YearTo number(18,0);

BEGIN
	v_DatePart := trim(lower(DatePart));

	v_MonthFrom := to_number(to_char(FromDate,'MM'));
	v_MonthTo := to_number(to_char(ToDate,'MM'));

	v_YearFrom := to_number(to_char(FromDate,'RRRR'));
	v_YearTo := to_number(to_char(ToDate,'RRRR'));

	if v_DatePart = 'd' or v_DatePart = 'day' then
		v_Result := ToDate - FromDate;
	elsif v_DatePart = 'm' or v_DatePart = 'month' then
		v_Result := 12*(v_YearTo - v_YearFrom) + (v_MonthTo - v_MonthFrom);
	elsif v_DatePart = 'q' or v_DatePart = 'quarter' then
		v_Result := 12*(v_YearTo - v_YearFrom) + (v_MonthTo - v_MonthFrom);
		v_Result := floor(v_Result/3);
	elsif v_DatePart = 'h' or v_DatePart = 'halfyear' then
		v_Result := 12*(v_YearTo - v_YearFrom) + (v_MonthTo - v_MonthFrom);
		v_Result := floor(v_Result/6);
	elsif v_DatePart = 'y' or v_DatePart = 'year' then
		v_Result := v_YearTo - v_YearFrom;
	end if;

    RETURN v_Result;


END;
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
