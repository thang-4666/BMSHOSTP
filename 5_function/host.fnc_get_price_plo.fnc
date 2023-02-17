SET DEFINE OFF;
CREATE OR REPLACE FUNCTION FNC_GET_PRICE_PLO(
v_strSYMBOL IN Varchar2,
v_strEXECTYPE IN Varchar2
)
 RETURN NUMBER IS
 v_plobycloseprice varchar2(5);
 v_price number;
BEGIN
  v_price := 0;
  BEGIN
  select s.varvalue into v_plobycloseprice
  from sysvar s where s.grname ='SYSTEM' and s.varname = 'PLOBYCLOSEPRICE';
  EXCEPTION
    when OTHERS Then
    v_plobycloseprice :=  'N';
  END;

  IF ( v_plobycloseprice = 'N') THEN
    IF(v_strEXECTYPE = 'NB') THEN
      SELECT NVL(S.CEILINGPRICE, 0)/ S.TRADEUNIT INTO v_price FROM SECURITIES_INFO S WHERE S.SYMBOL = v_strSYMBOL ;
    ELSIF (v_strEXECTYPE = 'NS') THEN
      SELECT NVL(S.FLOORPRICE, 0)/ S.TRADEUNIT INTO v_price FROM SECURITIES_INFO S WHERE S.SYMBOL = v_strSYMBOL ;
    END IF;
  ELSE
     IF(v_strEXECTYPE = 'NB') THEN
        
      SELECT  CASE WHEN  HB.TRADINGSESSIONID = 'PCLOSE' THEN TO_NUMBER(NVL(S.CLOSEPRICE,NVL(se.ceilingprice,'0'))) / SE.TRADEUNIT
       ELSE  TO_NUMBER(NVL(se.ceilingprice,'0')) / SE.TRADEUNIT  END
      INTO v_price
      from hasecurity_req hr, HA_BRD hb, STOCKINFOR S , SECURITIES_INFO SE
      WHERE  hr.tradingsessionsubid = hb.BRD_CODE
      AND HR.SYMBOL = S.SYMBOL(+) 
      AND HR.Symbol = SE.Symbol
      AND HR.SYMBOL = v_strSYMBOL ;
    ELSIF (v_strEXECTYPE = 'NS') THEN
      SELECT NVL(S.FLOORPRICE, 0)/S.TRADEUNIT INTO v_price FROM SECURITIES_INFO S WHERE S.SYMBOL = v_strSYMBOL ;
    END IF;
  END IF;

   RETURN v_price;

EXCEPTION when OTHERS Then
    Return 0;
END;
 
/
