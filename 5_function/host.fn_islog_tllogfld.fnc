SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_islog_tllogfld(pv_tltxcd IN varchar2, pv_MatchType IN varchar2)
  RETURN BOOLEAN IS
  v_Result BOOLEAN;
BEGIN
    v_Result := false;
    -- Doi voi cac GD MUA ban, neu lenh thoa thuan --> log tllogfld, lenh thuong ==> ko log.
    If pv_MatchType = 'P' then 
       v_Result := true; 
    End If;
    RETURN v_Result;
EXCEPTION
   WHEN OTHERS THEN
    RETURN false;
END;
/
