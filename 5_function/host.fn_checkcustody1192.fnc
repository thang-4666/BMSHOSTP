SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_checkcustody1192(v_strAFACCTNO IN varchar2) RETURN  varchar2 IS
--
-- Purpose: Tao format so TK luu ky
--
-- MODIFICATION HISTORY
-- Person      Date         Comments
-- ---------   ------       -------------------------------------------
-- TUNH        10/04/2010   Created

    v_result        NUMBER;
    v_strCusType    varchar2(1);
    v_count         NUMBER;

BEGIN
    v_result:=0;
    v_count:=0;
    v_strCusType:='';
    --Lay noi luu ky
     select count(1) into  v_count from cfmast CF, AFMAST AF where  AF.ACCTNO = replace(upper(v_strAFACCTNO),'.','')
        AND CF.CUSTID = AF.custid;
     if v_count>0 then
            select CF.CUSTATCOM into v_strCusType from cfmast CF, AFMAST AF
            where  AF.ACCTNO = replace(upper(v_strAFACCTNO),'.','')
                AND CF.CUSTID = AF.custid;
            if v_strCusType ='Y' then
                v_result:=-1;
                return v_result;
            else
                 v_result:=0;
                 return v_result;
            end if;
     else
        v_result:=-1;
        return v_result;
     end if;
    RETURN -1;
EXCEPTION
   WHEN others THEN
   return -1;
END;

 
 
 
 
/
