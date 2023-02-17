SET DEFINE OFF;
CREATE OR REPLACE PACKAGE pck_sftp_process AS
   PROCEDURE PRC_PROCESS_INSTRUMENT_SBR (p_err_code IN OUT VARCHAR2,p_err_msg IN OUT VARCHAR2);
END PCK_SFTP_PROCESS;
/


CREATE OR REPLACE PACKAGE BODY pck_sftp_process
IS
    pkgctx plog.log_ctx;
    C_PACKAGENAME CONSTANT CHAR(12) := 'SFTP_PROCESS';
PROCEDURE PRC_PROCESS_INSTRUMENT_SBR (p_err_code IN OUT VARCHAR2,p_err_msg IN OUT VARCHAR2)
IS
  --Lay du lieu can xu ly
  CURSOR c_DataProcess IS
    SELECT *
    FROM FILE_INSTRUMENT_SBR
    WHERE PROCESS='N'  AND BOARDID='G1'
    ORDER BY SEQUENCENUMBER ;

    v_Count Number;
    v_TradePlace sbsecurities.tradeplace%TYPE;
    v_StockType ho_sec_info.stock_type%TYPE;
    v_TradingUnit ho_sec_info.trading_unit%TYPE;
    v_strErrM VARCHAR2(200);
    v_CountResultSussces Number;
    v_CountResultError Number;
BEGIN
    plog.setbeginsection (pkgctx, 'PRC_PROCESS_INSTRUMENT_SBR');
    v_CountResultSussces := 0;
    v_CountResultError := 0;
    FOR i IN c_DataProcess
    LOOP
      p_err_code :='';
      p_err_msg :='';
      BEGIN
        -- 0. Kiem tra du lieu da ton tai chua
        BEGIN
          SELECT COUNT(*) INTO v_Count
          FROM ho_sec_info i where i.Code = i.TICKERCODE;
        EXCEPTION WHEN OTHERS THEN
          v_Count:= 0;
          plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
          plog.error(pkgctx,C_PACKAGENAME||'.PRC_PROCESS_INSTRUMENT_SBR '||'Ma chung khoan khong hop le: '|| i.TICKERCODE);
        END;
        -- 0.1 Lay du lieu
        SELECT Case when i.productgroupid = 'STO' THEN '1'
                    when i.productgroupid = 'BDO' THEN '2'
                    when i.productgroupid = 'RPO' THEN '3'
                    when i.productgroupid = 'STX' THEN '4'
                    else '0' END StockType,
               Case when i.securityexchange = 'HO' THEN 10
                    when i.securityexchange = 'HX' THEN 100
                    else 100 END TradingUnit,
               Case when i.productgroupid IN ('STO','BDO','RPO') THEN '001'
                    when i.productgroupid IN ('STX','BDX','HCX') THEN '002'
                    when i.productgroupid = 'UPX' THEN '005' END TradePlace
               INTO  v_StockType, v_TradingUnit ,v_TradePlace
        FROM DUAL;
        plog.error('pr_update_secinfo sequencenumber ='|| i.sequencenumber );
        IF v_Count > 0 THEN -- 1. Ma chung khoan da ton tai.
          -- 1.1 Update ho_sec_info
          UPDATE HO_SEC_INFO SET
                 TRADING_DATE = trunc(sysdate) ,
                 TIME = to_char(sysdate,'hh24miss') ,
                 STOCK_TYPE = v_StockType ,
                 TRADING_UNIT = v_TradingUnit ,
                 TOTAL_ROOM = i.totalroom ,
                 CURRENT_ROOM = i.currentroom ,
                 BASIC_PRICE = i.referenceprice,
                 CLOSE_PRICE = i.closeprice ,
                 HIGHEST_PRICE = i.highestorderprice,
                 LOWEST_PRICE = i.lowestorderprice,
                 CEILING_PRICE = i.upperlimitprice,
                 FLOOR_PRICE = i.lowerlimitprice,
                 PARVALUE = i.parvalue,
                 HALT_RESUME_FLAG = i.halt ,
                 ISSUERNAME = i.issuerid ,
                 LASTTRADINGDATE= TO_DATE(TRIM(i.lasttradingdate),'RRRRMMDD') ,
                 EXERCISERATIO = i.elwconversionratio,
                 EXERCISEPRICE = i.exerciseprice ,
                 BRD_CODE = i.marketid,
                 STATUSCODE = i.symbolstatuscode
          WHERE STOCK_ID = i.symbolshortcode ;
        ELSE -- 2. Ma chung khoan chua ton tai
          -- 2.2 Insert ho_sec_info
          INSERT INTO HO_SEC_INFO(FLOOR_CODE, DATE_NO, TRADING_DATE, TIME, STOCK_ID,
          CODE, STOCK_TYPE, TRADING_UNIT, TOTAL_ROOM, CURRENT_ROOM,
          BASIC_PRICE, CLOSE_PRICE, HIGHEST_PRICE, LOWEST_PRICE, CEILING_PRICE,
          FLOOR_PRICE, PARVALUE, HALT_RESUME_FLAG,ISSUERNAME, LASTTRADINGDATE,
          EXERCISERATIO, EXERCISEPRICE, BRD_CODE, STATUSCODE)
          VALUES ('10', '10', trunc(sysdate), to_char(sysdate,'hh24miss'), i.symbolshortcode,
          i.tickercode, v_StockType, v_TradingUnit, NVL(i.totalroom,0), NVL(i.currentroom,0),
          NVL(i.referenceprice,0), NVL(i.closeprice,0), NVL(i.highestorderprice,0), NVL(i.lowestorderprice,0), NVL(i.upperlimitprice,0),
          NVL(i.lowerlimitprice,0), i.parvalue, i.halt,i.issuerid, TO_DATE(TRIM(i.lasttradingdate),'RRRRMMDD'),
          i.elwconversionratio, i.exerciseprice,i.marketid,i.symbolstatuscode);
        END IF;

        -- 3. G?i ph?n x? l? sbsecurities,securities_info v?i m?h?ng kho?m?i, v?huy?n s?
        BEGIN
          /*cspks_odproc.pr_update_secinfo(i.tickercode, i.upperlimitprice, i.lowerlimitprice, i.referenceprice,
                            v_TradePlace,i.productgroupid, p_err_code, i.halt,
                            i.securitygroupid,i.symbol );*/
        --thangpv
        cspks_odproc.pr_update_secinfo(i.tickercode, i.upperlimitprice, i.lowerlimitprice, i.referenceprice,
                            v_TradePlace,'N', p_err_code, i.halt,i.productgroupid,
                            i.securitygroupid,i.symbol );
        EXCEPTION WHEN OTHERS THEN
          plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
          plog.error('pr_update_secinfo xu ly loi sequencenumber ='|| i.sequencenumber );
        END;

        -- 4. Update SBSECURITIES
        UPDATE SBSECURITIES SET
               ISINCODE = i.symbol,
               coveredwarranttype = i.rightstypecode,   /*Loai chung quyen*/
               maturitydate = TO_DATE(trim(i.subscriptionrightsdelistdt),'RRRRMMDD'),   /*Ngay het han chung quyen*/
               lasttradingdate = TO_DATE(TRIM(i.lasttradingdate),'RRRRMMDD'),   /*Ngay giao dich cuoi cung*/
               exerciseprice = ROUND(nvl(trim(i.exerciseprice),0)/10000,4),   /*Gia thuc hien*/
               exerciseratio = nvl(trim(i.elwconversionratio),''), /*Ty le thuc hien*/
               HALT = i.halt
        WHERE SYMBOL=TRIM(i.tickercode);

        UPDATE securities_info SET
               CLOSEPRICE = i.closeprice
        WHERE  SYMBOL=TRIM(i.tickercode);

        -- 5. Call proc pr_updatepricefromgw
        BEGIN
          pr_updatepricefromgw(i.tickercode, nvl(i.referenceprice,0),i.lowerlimitprice ,i.upperlimitprice,'CN',p_err_code,v_strErrM,'Y');
        EXCEPTION WHEN OTHERS THEN
          plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
          plog.error(pkgctx,'PRC_PROCESS_INSTRUMENT_SBR.pr_updatepricefromgw '||'Cant not process sequencenumber = '||i.sequencenumber||'v_strErrM : '||v_strErrM);
        END;

        -- 6. Call proc pr_updateroomfromgw
        BEGIN
          pr_updateroomfromgw(i.symbol, i.totalroom, i.currentroom, p_err_code, v_strErrM);
        EXCEPTION WHEN OTHERS THEN
          plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
          plog.error(pkgctx,'PRC_PROCESS_INSTRUMENT_SBR.pr_updateroomfromgw '||'Cant not process sequencenumber = '||i.sequencenumber||'v_strErrM : '||v_strErrM);
        END;

        IF p_err_code='0' THEN
           UPDATE FILE_INSTRUMENT_SBR SET PROCESS='Y' WHERE SEQUENCENUMBER= i.sequencenumber AND PROCESS = 'N';
           v_CountResultSussces := v_CountResultSussces + 1;
           plog.error(pkgctx,'PRC_PROCESS_INSTRUMENT_SBR '||'Process done sequencenumber = '||i.sequencenumber);
        ELSE
          UPDATE FILE_INSTRUMENT_SBR SET PROCESS ='E' WHERE SEQUENCENUMBER= i.sequencenumber AND PROCESS = 'N';
          v_CountResultError := v_CountResultError + 1;
          plog.error(pkgctx,'PRC_PROCESS_INSTRUMENT_SBR '||'Cant not process sequencenumber = '||i.sequencenumber);
        END IF;

      EXCEPTION WHEN OTHERS THEN
        UPDATE FILE_INSTRUMENT_SBR SET PROCESS ='E' WHERE SEQUENCENUMBER= i.sequencenumber AND PROCESS = 'N';
        v_CountResultError := v_CountResultError + 1;
        plog.error(pkgctx,'PRC_PROCESS_INSTRUMENT_SBR '||'Cant not process sequencenumber = '||i.sequencenumber);
      END;
    END LOOP;
    COMMIT;
    p_err_msg := p_err_code || ': Process success ' || to_char(v_CountResultSussces) || ' row' || ' Process error ' || to_char(v_CountResultError)  || ' row';
    plog.setendsection (pkgctx, 'PRC_PROCESS_INSTRUMENT_SBR');
EXCEPTION WHEN OTHERS THEN
    plog.error(pkgctx, SQLERRM || '--' || dbms_utility.format_error_backtrace);
    plog.setendsection (pkgctx, 'PRC_PROCESS_INSTRUMENT_SBR');
    ROLLBACK;
    RAISE errnums.E_SYSTEM_ERROR;
END;

END PCK_SFTP_PROCESS;
/
