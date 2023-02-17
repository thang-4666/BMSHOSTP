SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_check_maxsameorder
  ( v_strCODEID     IN varchar2,
    v_strAFACCTNO   IN varchar2,
    v_strEXECTYPE   IN varchar2,
    v_strMATCHTYPE  IN varchar2,
    v_strPRICETYPE  IN varchar2,
    v_dblQUOTEPRICE IN varchar2,
    v_dblORDERQTTY  IN varchar2)
  RETURN  VARCHAR2 IS

    l_strTRADEPLACE varchar2(30);
    v_MaxSameOrd    NUMBER;
    l_count         NUMBER;
    l_strAFACCTNO   varchar2(30);
    l_strEXPDATE    varchar2(30);
    l_strEXECTYPE   varchar2(30);
    l_strMATCHTYPE  varchar2(30);
    l_strPRICETYPE  varchar2(30);
    l_dblQUOTEPRICE number(30,9);
    l_dblORDERQTTY  number(30,4);
    l_strCODEID     varchar2(30);

    l_currdate      date;

    v_Result        varchar2(10);

BEGIN
    v_Result    := '0';
    l_strCODEID := v_strCODEID;

    l_strAFACCTNO   := v_strAFACCTNO;
    l_strEXECTYPE   := v_strEXECTYPE;
    l_strMATCHTYPE  := v_strMATCHTYPE;
    l_strPRICETYPE  := v_strPRICETYPE;
    l_dblQUOTEPRICE := v_dblQUOTEPRICE;
    l_dblORDERQTTY  := v_dblORDERQTTY;

    select TO_DATE(VARVALUE,'DD/MM/RRRR') INTO l_currdate from sysvar where varname = 'CURRDATE';

    BEGIN
        SELECT TRADEPLACE INTO l_strTRADEPLACE FROM SBSECURITIES WHERE CODEID= l_strCODEID;
    EXCEPTION
    WHEN no_data_found THEN
        v_Result := errnums.C_OD_SECURITIES_INFO_UNDEFINED;
        RETURN v_Result;
    END;
    IF l_strTRADEPLACE = errnums.gc_TRADEPLACE_HNCSTC OR  l_strTRADEPLACE = errnums.gc_TRADEPLACE_UPCOM  THEN
    --Lay tham so max order trung nhau trong ordersys.
        Begin
            SELECT sysvalue INTO v_MaxSameOrd FROM ordersys_ha WHERE sysname ='MAXSAMEORD';
        Exception When OTHERS Then
            v_MaxSameOrd := 20;
        End;

        SELECT COUNT(*) into l_count FROM ODMAST
        WHERE CODEID= l_strCODEID
            AND AFACCTNO IN
                (SELECT ACCTNO FROM AFMAST WHERE CUSTID=(SELECT CUSTID FROM AFMAST WHERE ACCTNO= l_strAFACCTNO ))
            AND PRICETYPE = l_strPRICETYPE
            ---AND EXECTYPE=   l_strEXECTYPE
            AND decode(EXECTYPE,'MS','NS',EXECTYPE)= decode(l_strEXECTYPE,'MS','NS',l_strEXECTYPE)
            AND NVL(CANCELSTATUS,'N') <> 'X'
            AND DELTD = 'N'
            AND QUOTEPRICE = l_dblQUOTEPRICE * 1000
            AND MATCHTYPE =  l_strMATCHTYPE
            AND ORDERQTTY  = l_dblORDERQTTY
            AND REFORDERID IS  NULL ---lenh moi sinh ra tu lenh sua khong tinh.
            AND TXDATE = l_currdate;

        IF l_count > v_MaxSameOrd - 1 THEN
            v_Result := '-95046';
            RETURN  v_Result;
        END IF;

    ELSE
        RETURN v_Result;
    END IF;
    RETURN v_Result;
EXCEPTION
   WHEN OTHERS THEN
    RETURN errnums.C_SYSTEM_ERROR;
END;

 
 
 
 
/
