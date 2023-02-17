SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_get_date_diff(v_frdate date, v_todate date, v_lncldr varchar2, v_tradeplace varchar2  DEFAULT '000') RETURN NUMBER is
v_datediff number;
begin
    IF v_lncldr = 'B' THEN
        SELECT      COUNT(1)
        INTO        v_datediff
        FROM        SBCLDR
        WHERE       HOLIDAY = 'N' /*AND CLDRTYPE='000'*/ AND CLDRTYPE=v_tradeplace --ngoc.vu-Jira561
                    AND SBDATE BETWEEN v_frdate AND v_todate ;
    ELSE
        SELECT      COUNT(1)
        INTO        v_datediff
        FROM        SBCLDR
        WHERE      /* CLDRTYPE='000'*/ CLDRTYPE=v_tradeplace AND SBDATE BETWEEN v_frdate AND v_todate ;
    END IF;

    RETURN v_datediff;
end;
 
 
 
 
/
