SET DEFINE OFF;
CREATE OR REPLACE FUNCTION getcheckkey (TotalAcc in varchar2) RETURN varchar2 IS

   m1 integer;
   m2 integer;
   m3 integer;
    i integer;
 BEGIN
    m1 := 0;
    m2 := 0;
    m3 := 0;
    i:=1;
    loop
      exit when i>length(TotalAcc);
      m1 := m1 + to_number(substr(TotalAcc, i, 1));
      i := i + 3;
    end loop;

    i := 2;
    loop
      exit when i>length(TotalAcc);
      m2 := m2 + to_number(substr(TotalAcc, i, 1))*3;
      i := i + 3;
    end loop;
    i := 3;
    loop
      exit when i>length(TotalAcc);
      m3 := m3 + to_number(substr(TotalAcc, i, 1))*7;
      i := i + 3;
    end loop;
    return to_char((m1 + m2 + m3) Mod 10);

EXCEPTION
   WHEN others THEN
       return SQLCODE ;
END;
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
