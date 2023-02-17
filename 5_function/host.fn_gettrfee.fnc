SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_gettrfee(PV_CURVALUE NUMBER,PV_CALTYPE VARCHAR2,PV_AFACCTNO IN VARCHAR2,P_FEETYPE IN VARCHAR2, p_CLOSETYPE in varchar2 DEFAULT '000')
    RETURN NUMBER IS
-- PURPOSE: PHI CHUYEN KHOAN CHUNG KHOAN
-- MODIFICATION HISTORY
-- PERSON      DATE         COMMENTS
-- ---------   ------       -------------------------------------------
-- THANHNM   03/02/2012     CREATED
    V_RESULT NUMBER;
    V_FEERATE NUMBER;
    V_FEEMAX NUMBER;
    V_FEEMIN NUMBER;
    V_ACCNUM NUMBER;
    V_FEETYPE varchar2(4);
BEGIN
if p_CLOSETYPE = '002' then
    IF PV_CALTYPE = '01' THEN
        return 0;
    ELSE
        RETURN PV_CURVALUE;
    END IF;
end if;
V_FEERATE :=0;
V_FEEMAX :=0;
V_FEEMIN := 0;
V_RESULT :=0;
V_ACCNUM :=0;
/*
KIEM TRA XEM CO PHAI TIEU KHOAN CUOI CUNG KHONG
DUNG: RETURN FEE
SAI: RETURN 0
*/
-- Check theo p_CLOSETYPE
/* SELECT COUNT(ACCTNO) INTO V_ACCNUM  FROM AFMAST WHERE
 CUSTID = (SELECT CUSTID FROM AFMAST WHERE  ACCTNO=PV_AFACCTNO )
 AND STATUS NOT IN ( 'N','C') AND ACCTNO <> PV_AFACCTNO;

 IF V_ACCNUM >0 THEN
    RETURN 0;
 END IF;*/

        begin
            SELECT FEERATE/100, MAXVAL, minval, FORP, feeamt INTO V_FEERATE, V_FEEMAX, V_FEEMIN, V_FEETYPE, V_RESULT
            FROM FEEMASTER WHERE FEECD = P_FEETYPE AND STATUS ='A';
        EXCEPTION WHEN OTHERS THEN
            V_RESULT := 0;
            V_FEETYPE := 'F';
        end ;

        if V_FEETYPE <> 'F' then
            SELECT SUM(nvl(se.amt,0)) INTO V_RESULT
            FROM
                      (SELECT SUM( V_FEERATE*NVL((SE.TRADE + SE.MORTAGE + SE.BLOCKED + SE.WITHDRAW
                       + SE.DEPOSIT  + SE.SENDDEPOSIT),0)) amt,custid
                       FROM SEMAST SE, sbsecurities sym
                       WHERE se.codeid=sym.codeid
                       AND sym.sectype <> '004'
                       GROUP BY se.codeid,se.custid) se
            WHERE se.custid IN  (SELECT custid FROM semast WHERE afacctno=  PV_AFACCTNO);
            V_RESULT := nvl(V_RESULT,0);
            if V_RESULT > V_FEEMAX then
                V_RESULT := V_FEEMAX;
            end if;
            if V_RESULT < V_FEEMIN then
                V_RESULT := V_FEEMIN;
            end if;
        end if ;


    IF PV_CALTYPE = '01' THEN
        return V_RESULT;
    ELSE
        RETURN PV_CURVALUE;
    END IF;

----RETURN V_RESULT;
EXCEPTION
   WHEN OTHERS THEN
    RETURN 0;
END;

 
 
 
 
/
