SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_checkTradSesStatus (p_symbol       IN VARCHAR2,
                                                  p_quantity     IN NUMBER,
                                                  p_functionName IN VARCHAR2,
                                                  p_strPRICETYPE IN VARCHAR2,
                                                  p_matchType    IN VARCHAR2,
                                                  p_isBuyIn      IN VARCHAR2,
                                                  p_isActive     IN VARCHAR2,
                                                  p_orstatus     IN VARCHAR2 DEFAULT '')
RETURN VARCHAR2
IS
 v_TradeLot       number;
 v_TradSesStatus  VARCHAR2(20);
 v_Result         VARCHAR2(20);
 v_BRD_CODE       VARCHAR2(20);
 v_grpCode        ho_sec_info.statuscode%TYPE;
 v_boardId        VARCHAR2(10);
 l_isPostSession  VARCHAR2(10);
 l_tradeplace     sbsecurities.tradeplace%TYPE;
BEGIN
  v_TradSesStatus:='';
  v_BRD_CODE:='';
  v_Result:=systemnums.C_SUCCESS;

  SELECT sif.TRADELOT, sb.tradeplace
  INTO v_TradeLot, l_tradeplace
  FROM SBSECURITIES sb , SECURITIES_INFO sif  WHERE sb.CODEID = sif.CODEID AND sb.SYMBOL = p_symbol;

  IF l_tradeplace IN ('001','002','005') THEN

    BEGIN
        SELECT tradsesstatus, brd_code, h.statuscode INTO v_TradSesStatus, v_BRD_CODE, v_grpCode
        FROM HO_SEC_INFO h where CODE = p_symbol;
    exception
    when no_data_found then
         v_TradSesStatus:='';
         v_BRD_CODE:='';
         v_grpCode:='';
    end;


    IF v_grpCode != ho_tx.C_SYMBOL_STATUS_CONTROL THEN -- Phien cua ck kiem soat lay theo HO_SEC_INFO

        SELECT varvalue INTO l_isPostSession FROM sysvar WHERE grname = 'SYSTEM' AND varname = 'OPEN_POST_SESSION';
        -- Get BoardId
        v_boardId := pck_gw_common.fnc_GetBoardId(v_BRD_CODE,
                                                  p_quantity,
                                                  v_TradeLot,
                                                  p_matchType,
                                                  p_isBuyIn,
                                                  l_isPostSession,
                                                  p_strPRICETYPE);

        IF v_TradSesStatus is null AND v_BRD_CODE is not null THEN
            SELECT decode(v_boardId, 'G1', board_g1,
                                     'G4', board_g4,
                                     'G7', board_g7,
                                     'T1', board_t1,
                                     'T3', board_t3,
                                     'T4', board_t4,
                                     'T6', board_t6)
            INTO v_TradSesStatus
            FROM HO_BRD WHERE BRD_CODE = v_BRD_CODE;
        END IF;
    ELSE
      IF p_functionName in ('PLACEORDER','CANCELORDER') THEN
        IF p_strPRICETYPE IN ('MTL','MOK','MAK') THEN
          v_Result:='-700118';
          RETURN v_Result;
        END IF;
      ELSIF p_functionName in ('AMENDMENTORDER') THEN
        v_Result:='-700108';
        RETURN v_Result;
      ELSIF p_functionName in ('CANCELORDER','AMENDMENTORDER') AND p_orstatus = '2' THEN
        v_Result:='-700100';
      RETURN v_Result;
      END IF;

    END IF;

    IF p_functionName in ('CANCELORDER','AMENDMENTORDER') AND p_orstatus <> '8' THEN
        IF v_TradeLot>0 AND p_quantity < v_TradeLot AND v_TradSesStatus IN ('AA1','CC1','AB2','AB1','AW8','AW9') THEN
            -- Lo Le Khong Huy/Sua Trong Phien Dinh Ky
            v_Result:='-700100';
            RETURN v_Result;
        END IF;
    END IF;

    IF p_functionName IN ('PLACEORDER', 'BLBPLACEORDER') AND p_isActive IN('Y','T') THEN
        IF (
              (p_strPRICETYPE = 'ATO' AND INSTR('/BB1/BC1/AC2/CD3', v_TradSesStatus) > 0) OR -- Dat Lenh ATO Sau Phien ATO
            --(p_strPRICETYPE = 'MO' AND v_TradSesStatus not in ('CD1','CD3' )) OR
              (p_strPRICETYPE IN ('MTL','MOK','MAK') AND INSTR('/BC1/AC2/CD3', v_TradSesStatus) > 0 ) -- Dat Lenh Thi Truong Phien Dinh Ky
          ) THEN

          v_Result:='-100113';
          RETURN v_Result;
        END IF;
    END IF;

    IF p_functionName in ('CANCELORDER','AMENDMENTORDER','BLBAMENDMENTORDER','BLBCANCELORDER') AND p_orstatus <> '8' AND
        v_TradSesStatus in ('AA1','BC1','CD3') THEN
        v_Result:='-100113';
        RETURN v_Result;
    END IF;

    IF p_isBuyIn = 'Y' THEN
      IF p_functionName <> 'PLACEORDER' AND p_orstatus <> '8' THEN
        v_Result:='-700101';
        RETURN v_Result;
      END IF;
      IF v_TradSesStatus <> 'AB1' THEN
         v_Result:='-100113';
         RETURN v_Result;
      END IF;
      IF p_strPRICETYPE IN ('MTL','MOK','MAK') THEN
          v_Result:='-700113';
          RETURN v_Result;
      END IF;
    END IF;
  END IF;
  RETURN v_Result;
EXCEPTION
  WHEN OTHERS THEN
    plog.error('fn_CheckTradSesStatus:.p_symbol=' || p_symbol || ',p_funcName=' || p_functionName || ':' || SQLERRM || dbms_utility.format_error_backtrace);
    RETURN -1;
END;
/
