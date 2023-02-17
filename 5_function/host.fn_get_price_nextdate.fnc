SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_get_price_nextdate (pv_codeid IN VARCHAR2,pv_BasicPrice IN NUMBER,pv_Type IN VARCHAR2)
RETURN NUMBER
  IS
    v_Result_Price  NUMBER;
    v_N_Basic_Price NUMBER;
    v_sectype varchar2(20);
    v_tradeplace varchar2(20);
BEGIN
    -- Tinh gia tuy theo Type truyen vao
    -- B: Basic Price
    -- C: Ceiling Price
    -- F: Floor Price

    --Ngay 01/02/2019 NamTv chinh lai gia tran san cho TPDN
    select sectype, tradeplace into v_sectype,v_tradeplace from sbsecurities where codeid=pv_codeid;

    -- Tinh lai gia tham chieu
    SELECT max(round(pv_BasicPrice / st.ticksize) * st.ticksize)
    INTO v_N_Basic_Price
    FROM securities_ticksize st
    WHERE st.codeid = pv_codeid
        AND st.fromprice <= pv_BasicPrice AND st.toprice >=  pv_BasicPrice;

    if v_sectype='012' and v_tradeplace = '002' then
        IF pv_type = 'B' THEN
            v_Result_Price := v_N_Basic_Price;
        --Chinh sua lay gia tran san cho TPDN theo tham so he thong
        ELSIF pv_Type = 'C' THEN
           BEGIN
               SELECT to_number(a.varvalue) INTO v_Result_Price FROM SYSVAR A WHERE A.GRNAME='SYSTEM' AND a.varname='TPDNCEIL';
           EXCEPTION WHEN OTHERS THEN
               v_Result_Price := 2000000000;
           END;
            /*begin
            select sb.ceilingprice into v_Result_Price
            from securities_info sb  WHERE sb.codeid = pv_codeid ;
            EXCEPTION WHEN others THEN
            v_Result_Price := 10000000;
            END;*/
        ELSIF pv_Type = 'F' THEN
            BEGIN
               SELECT to_number(a.varvalue) INTO v_Result_Price FROM SYSVAR A WHERE A.GRNAME='SYSTEM' AND a.varname='TPDNFLOOR';
            EXCEPTION WHEN OTHERS THEN
               v_Result_Price := 1;
            END;
            /*begin
                select sb.floorprice into v_Result_Price
                from securities_info sb  WHERE sb.codeid = pv_codeid ;
            EXCEPTION WHEN others THEN
                v_Result_Price := 1000;
            END;*/
        END IF;
        --END Chinh sua lay gia tran san cho TPDN theo tham so he thong
        RETURN v_Result_Price;
    end if;
    --NamTv End;

    IF pv_type = 'B' THEN
        v_Result_Price := v_N_Basic_Price;
    ELSIF pv_Type = 'C' THEN
        SELECT max(ROUND(floor(CEILINGPRICE/st.ticksize)*st.ticksize)) CEILINGPRICE
        INTO v_Result_Price
        FROM
            (SELECT sb.codeid,
                floor((CASE WHEN sb.tradeplace = '001' THEN TO_NUMBER(SYS2.VARVALUE)/100
                WHEN sb.tradeplace = '002' THEN TO_NUMBER(SYS1.VARVALUE)/100
                WHEN sb.tradeplace = '005' THEN TO_NUMBER(SYS3.VARVALUE)/100
                ELSE 0 END + 1) * v_N_Basic_Price/100)*100  CEILINGPRICE
            FROM sbsecurities sb, sysvar sys1, sysvar sys2, sysvar sys3
            WHERE sb.codeid = pv_codeid
                AND SYS1.grname = 'SYSTEM' AND SYS1.VARNAME = 'PRICELIMIT_HNX'
                AND SYS2.grname = 'SYSTEM' AND SYS2.VARNAME = 'PRICELIMIT_HOSE'
                AND SYS3.grname = 'SYSTEM' AND SYS3.VARNAME = 'PRICELIMIT_UPCOM'
            ) sec,
            securities_ticksize st
        WHERE sec.codeid = st.codeid
            AND sec.CEILINGPRICE >= st.fromprice AND sec.CEILINGPRICE <= st.toprice;
    ELSIF pv_Type = 'F' THEN
        SELECT max(ROUND(ceil(FLOORPRICE/st.ticksize)*st.ticksize)) FLOORPRICE
        INTO v_Result_Price
        FROM
            (SELECT sb.codeid,
                ceil((1 - CASE WHEN sb.tradeplace = '001' THEN TO_NUMBER(SYS2.VARVALUE)/100
                WHEN sb.tradeplace = '002' THEN TO_NUMBER(SYS1.VARVALUE)/100
                WHEN sb.tradeplace = '005' THEN TO_NUMBER(SYS3.VARVALUE)/100
                ELSE 0 END) * v_N_Basic_Price/100)*100  FLOORPRICE
            FROM sbsecurities sb, sysvar sys1, sysvar sys2, sysvar sys3
            WHERE sb.codeid = pv_codeid
                AND SYS1.grname = 'SYSTEM' AND SYS1.VARNAME = 'PRICELIMIT_HNX'
                AND SYS2.grname = 'SYSTEM' AND SYS2.VARNAME = 'PRICELIMIT_HOSE'
                AND SYS3.grname = 'SYSTEM' AND SYS3.VARNAME = 'PRICELIMIT_UPCOM'
            ) sec,
            securities_ticksize st
        WHERE sec.codeid = st.codeid
            AND sec.FLOORPRICE >= st.fromprice AND sec.FLOORPRICE <= st.toprice;
    END IF;

    RETURN v_Result_Price;
EXCEPTION WHEN others THEN
    plog.error(dbms_utility.format_error_backtrace);
    return  pv_BasicPrice;
END;
 
/
