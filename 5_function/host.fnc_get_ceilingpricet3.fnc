SET DEFINE OFF;
CREATE OR REPLACE FUNCTION FNC_GET_CeilingPriceT3(p_dblBasicPrice IN number,p_strCODEID IN Varchar2)
RETURN NUMBER
IS v_price number;
BEGIN
  v_price := 0;
  SELECT ROUND(floor(CEILINGPRICE/st.ticksize)*st.ticksize) CEILINGPRICE Into v_price
  FROM(
         SELECT sb.codeid,
                floor((25/100 + 1) * p_dblBasicPrice)  CEILINGPRICE
         FROM sbsecurities sb
         WHERE sb.codeid = p_strCODEID) sec, securities_ticksize st
  WHERE sec.codeid = st.codeid
        AND sec.CEILINGPRICE >= st.fromprice
        AND sec.CEILINGPRICE <= st.toprice;

RETURN v_price;
EXCEPTION when OTHERS Then
   plog.error('FNC_GET_CeilingPriceT3:.p_strCODEID=' || p_strCODEID || ',p_dblBasicPrice=' || p_dblBasicPrice || ':' || SQLERRM || dbms_utility.format_error_backtrace);
    Return 0;
END;
/
