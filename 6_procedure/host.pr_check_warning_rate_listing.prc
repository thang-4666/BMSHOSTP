SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE pr_check_warning_rate_listing (
        PV_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
        p_custodycd IN VARCHAR2,
        p_symbol IN VARCHAR2,
        p_qtty IN number
        )
  IS
    l_count number;
    l_trade number ;
    l_listingqtty number;
    l_warning_rate number;
BEGIN
    SELECT TO_NUMBER( varvalue)  INTO L_warning_rate from SYSVAR where varname = 'WARNING_RATE';

OPEN PV_REFCURSOR FOR
    SELECT MST.SETRADE+NVL(OD.ODQTTY,0) TRADE, MST.LISTINGQTTY,
        (case when mst.LISTINGQTTY <=0 then 'Y' else (case when (MST.SETRADE+NVL(OD.ODQTTY,0) + p_qtty)/MST.LISTINGQTTY > L_warning_rate/100 then 'Y' else 'N' end ) end ) WARNINGRATE
    FROM
        (
            SELECT SUM(SETRADE) SETRADE,  CUSTODYCD, MAX( LISTINGQTTY) LISTINGQTTY
            FROM
            (
            SELECT SUM(SE.TRADE+SE.MORTAGE+SE.WITHDRAW+SE.BLOCKED+SE.SENDPENDING+
            SE.DTOCLOSE+SE.SDTOCLOSE+SE.EMKQTTY+SE.BLOCKWITHDRAW+SE.BLOCKDTOCLOSE+SE.RECEIVING-SE.NETTING) SETRADE, CF.CUSTODYCD, MAX(SEC.LISTINGQTTY) LISTINGQTTY
            FROM SEMAST SE, SECURITIES_INFO SEC, AFMAST AF, CFMAST CF
            WHERE SE.CODEID(+) = SEC.CODEID AND SEC.SYMBOL = P_SYMBOL
            AND SE.AFACCTNO = AF.ACCTNO AND AF.CUSTID = CF.CUSTID
            AND CF.CUSTODYCD = p_CUSTODYCD
            GROUP BY CF.CUSTODYCD
            UNION ALL
            SELECT 0 SETRADE, p_CUSTODYCD CUSTODYCD, MAX(SEC.LISTINGQTTY) LISTINGQTTY
            FROM  SECURITIES_INFO SEC
            WHERE SEC.SYMBOL = P_SYMBOL
            )
            GROUP BY CUSTODYCD
        )MST,
    (SELECT SUM(CASE WHEN OD.EXECTYPE = 'NB' THEN OD.ORDERQTTY-(OD.CANCELQTTY+OD.ADJUSTQTTY)
    ELSE -OD.EXECQTTY END) ODQTTY, CF.CUSTODYCD
    FROM ODMAST OD, AFMAST AF, CFMAST CF , SECURITIES_INFO SEC
    WHERE OD.AFACCTNO = AF.ACCTNO AND AF.CUSTID = CF.CUSTID
    AND CF.CUSTODYCD = p_CUSTODYCD AND OD.CODEID = SEC.CODEID
    AND SEC.SYMBOL = P_SYMBOL AND OD.TXDATE = GETCURRDATE AND EXECTYPE IN ('NB','NS','MS')
    GROUP BY CF.CUSTODYCD)OD
    WHERE MST.CUSTODYCD =  OD.CUSTODYCD(+);

EXCEPTION
    WHEN others THEN
        return;
END;
 
 
 
 
/
