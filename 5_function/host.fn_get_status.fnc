SET DEFINE OFF;
CREATE OR REPLACE FUNCTION FN_GET_STATUS(pv_valdate VARCHAR2,pv_strSTATUS VARCHAR2)
    RETURN VARCHAR2 IS
    v_Result  VARCHAR2(1);
    v_currdate DATE;
    v_nextdate DATE;
    v_count NUMBER;

BEGIN
  --v_Result:=pv_strSTATUS;
  /*-- trang thai la P thi moi cho sua, <>P then return luon trang thai hien tai
   if(pv_strSTATUS <> 'P')
    THEN
    RETURN v_Result;
    END IF;*/
        -- neu trang thai hien tai la P

            SELECT to_Date(varvalue, 'DD/MM/RRRR')
              INTO v_currdate
              FROM sysvar
             WHERE varname = 'CURRDATE';
           -- neu ngay hieu luc la ngay hien tai: return: A
             if(to_date(pv_valdate,'DD/MM/RRRR') <= v_currdate) THEN
             v_Result:='A';
             ELSIF(to_date(pv_valdate,'DD/MM/RRRR') > v_currdate) THEN
             v_Result:='P';
             END IF;

    RETURN v_Result;

EXCEPTION
   WHEN OTHERS THEN
    RETURN 0;
END;

 
 
 
 
 
 
 
 
 
 
 
 
 
/
