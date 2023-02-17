SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_get_cadesc(pv_catype IN VARCHAR2,
                                         pv_codeid IN VARCHAR2,
                                         pv_reportdate IN VARCHAR2,
                                         pv_rate IN VARCHAR2)
  RETURN VARCHAR2 IS
  l_return      VARCHAR2(200);
  l_catype_desc VARCHAR2(200);
  l_symbol      VARCHAR2(20);
BEGIN
  SELECT cdcontent INTO l_catype_desc
    FROM allcode
   WHERE cdtype = 'CA' AND cdname = 'CATYPE' AND cdval = pv_catype;

  SELECT symbol INTO l_symbol
    FROM sbsecurities
   WHERE codeid = pv_codeid;

  l_return :=  l_catype_desc || ', ' || l_symbol || ', ngày chốt ' || pv_reportdate || ', tỷ lệ ' || pv_rate;
  IF pv_catype IN ('010', '022', '023') THEN 
     l_return := l_return || '%';
  END IF;
  RETURN l_return;
END;
 
/
