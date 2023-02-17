SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_get_shareholdersid(pv_shareholdersid In VARCHAR2, pv_afacctno in varchar2, pv_codeid in varchar2  )
    RETURN VARCHAR2 IS
    v_Result  VARCHAR2(250);
    v_Symbol  VARCHAR2(100);
    v_AUTOINV  VARCHAR2(100);
    v_count NUMBER;
BEGIN

    BEGIN
    select shareholdersid  into v_Result from semast where acctno =pv_afacctno||pv_codeid  ;
    EXCEPTION
       WHEN OTHERS THEN
        v_Result:= '';
    END ;

    if  v_Result is not null then
      RETURN  v_Result  ;
    else
    -- tu sinh theo luat

IF  pv_afacctno IS NOT NULL  AND pv_codeid IS NOT NULL  THEN

    select symbol  into v_Symbol  from sbsecurities where codeid = pv_codeid ;

  /*  SELECT nvl( count(*),0) INTO v_count FROM   SEMAST  where instr( shareholdersid ,V_SYMBOL) >0
    AND LENGTH(TRIM(TRANSLATE(REPLACE ( SHAREHOLDERSID , v_Symbol ||'_') , ' +-.0123456789',' '))) IS NULL;

    IF v_count =0 THEN
       v_Result:= V_SYMBOL  ||'_'||'1'  ;
    ELSE*/

       SELECT NVL(MAX(ODR)+1,1) into v_AUTOINV  FROM
                  (SELECT ROWNUM ODR, INVACCT
                  FROM (
                      SELECT TO_NUMBER ( REPLACE ( SHAREHOLDERSID , V_SYMBOL ||'_')) INVACCT
                      FROM   SEMAST
                      WHERE INSTR( SHAREHOLDERSID ,V_SYMBOL) >0
                      AND LENGTH(TRIM(TRANSLATE(REPLACE ( SHAREHOLDERSID , V_SYMBOL ||'_') , ' +-.0123456789',' '))) IS NULL
                      ORDER BY TO_NUMBER ( REPLACE ( SHAREHOLDERSID , V_SYMBOL ||'_'))
                        ) DAT
                  WHERE TO_NUMBER(INVACCT)=ROWNUM


                 ) INVTAB
                 --group by INVACCT
                  ;
                /*
                    SELECT SUBSTR(INVACCT,1,4), MAX(ODR)+1 AUTOINV FROM
                  (SELECT ROWNUM ODR, INVACCT
                  FROM (SELECT CUSTID INVACCT FROM CFMAST WHERE SUBSTR(CUSTID,1,4)= V_BRID ORDER BY CUSTID) DAT
                  WHERE TO_NUMBER(SUBSTR(INVACCT,5,6))=ROWNUM) INVTAB
                  GROUP BY SUBSTR(INVACCT,1,4);*/

       v_Result:= V_SYMBOL  ||'_00'||v_AUTOINV  ;
      END IF;

        IF pv_shareholdersid IS   NOT NULL  THEN
        RETURN pv_shareholdersid;
        ELSE
        RETURN  v_Result;
       END If;

END IF;


EXCEPTION
   WHEN OTHERS THEN
    RETURN pv_shareholdersid;
END;
 
 
 
 
/
