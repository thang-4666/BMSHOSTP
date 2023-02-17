SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE sp_db_getauthcontractinfo (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   PV_AFACCTNO    IN       VARCHAR2,
   pv_EXECTYPE    IN       VARCHAR2,
   pv_TLTXCD        IN      VARCHAR2
)
IS
--
-- PURPOSE: Lay danh sach UQ cua TK
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- TruongLD
-- TheNN        27-Feb-2012 Modified
-- ---------   ------  -------------------------------------------
   V_AFACCTNO       VARCHAR2 (10);
   v_BUYSELL       VARCHAR2 (10);
   V_NOTE           VARCHAR2 (1000);
-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
    l_expdate_default   varchar2(100);
    v_AFTYPE    VARCHAR2(4);
    v_CURRDATE  DATE;
    v_TLTXCD    VARCHAR2(4);
    v_RIGHTPOS  NUMBER;
    BEGIN

        V_AFACCTNO :=  PV_AFACCTNO;
        v_BUYSELL :=  pv_EXECTYPE;
        v_TLTXCD := pv_TLTXCD;
        pr_error('EXECTYPE', v_BUYSELL);
        select '31/12/2099' into l_expdate_default from dual;

        SELECT getcurrdate INTO v_CURRDATE FROM DUAL;

        -- TUY GD CAN LAY QUYEN DUOC GAN
        IF v_TLTXCD = '1153' THEN -- UNG TRUOC
            v_RIGHTPOS := 10;
        ELSIF v_TLTXCD = '3384' THEN -- DANG KY QUYEN MUA
            v_RIGHTPOS := 8;
        ELSIF v_TLTXCD = '2250' THEN -- CAM CO
            v_RIGHTPOS := 11;
        ELSIF v_TLTXCD = '2240' OR v_TLTXCD = '2200' THEN -- GUI/ RUT CK
            v_RIGHTPOS := 9;
        ELSIF INSTR('1100/1140/1101/1120/1132/1134/1139/1130/1108/1107/1110/1121',v_TLTXCD) >0 THEN -- GUI/RUT/CK TIEN
            v_RIGHTPOS := 3;
        ELSE
            v_RIGHTPOS := 0;
        END IF;

        -- LAY THONG TIN KHACH HANG
        SELECT AF.AFTYPE
        INTO v_AFTYPE
        FROM AFMAST AF
        WHERE AF.ACCTNO = V_AFACCTNO;

        IF v_AFTYPE = '001' THEN
            -- CA NHAN, CHI LAY TRONG CFAUTH
            OPEN PV_REFCURSOR FOR
                SELECT AU.AUTOID, 'A' TYP, AU.CUSTID,
                    case when au.custid is null then au.licenseno else CF2.IDCODE end idcode,
                    case when au.custid is null then au.lniddate else CF2.IDDATE end iddate,
                    case when au.custid is null then au.lnplace else CF2.IDPLACE end idplace,
                    case when au.custid is null then au.fullname else CF2.FULLNAME end fullname, A1.CDCONTENT REF,
                    AF.ACCTNO,TO_CHAR(AU.VALDATE,'DD/MM/YYYY') EFFDATE ,TO_CHAR(AU.EXPDATE,'DD/MM/YYYY') EXPDATE,
                    case when au.custid is null then au.address else CF2.address end address
                FROM CFAUTH AU, CFMAST CF1, AFMAST AF, CFMAST CF2, ALLCODE A1
                WHERE AU.CFCUSTID = CF1.CUSTID AND CF1.CUSTID= AF.CUSTID AND AU.CUSTID= CF2.CUSTID(+) AND TRIM(AF.ACCTNO)=V_AFACCTNO AND AU.deltd='N'
                    --AND substr(AU.linkauth,4,2) IN ('YN','NY','YY')
                    and AU.expdate >= v_CURRDATE and AU.valdate <= v_CURRDATE
                    AND A1.CDTYPE = 'CF' AND A1.CDNAME = 'AUTHTYPE' AND A1.CDVAL = 'AUTHORIZED'
                    AND NVL(AU.CHSTATUS,'C') <> 'A'
                    AND CASE WHEN v_RIGHTPOS >0 THEN SUBSTR(AU.LINKAUTH,v_RIGHTPOS,1) ELSE 'Y' END = 'Y' ;

        ELSIF v_AFTYPE = '002' THEN
            -- TO CHUC, LAY CFAUTH VA CFLINK
            OPEN PV_REFCURSOR FOR
                SELECT AU.AUTOID, 'A' TYP, AU.CUSTID,
                    case when au.custid is null then au.licenseno else CF2.IDCODE end idcode,
                    case when au.custid is null then au.lniddate else CF2.IDDATE end iddate,
                    case when au.custid is null then au.lnplace else CF2.IDPLACE end idplace,
                    case when au.custid is null then au.fullname else CF2.FULLNAME end fullname, A1.CDCONTENT REF,
                    AF.ACCTNO,TO_CHAR(AU.VALDATE,'DD/MM/YYYY') EFFDATE ,TO_CHAR(AU.EXPDATE,'DD/MM/YYYY') EXPDATE,
                    case when au.custid is null then au.address else CF2.address end address
                FROM CFAUTH AU, CFMAST CF1, AFMAST AF, CFMAST CF2, ALLCODE A1
                WHERE AU.CFCUSTID = CF1.CUSTID AND CF1.CUSTID= AF.CUSTID AND AU.CUSTID= CF2.CUSTID(+) AND TRIM(AF.ACCTNO)=V_AFACCTNO AND AU.deltd='N'
                    --AND substr(AU.linkauth,4,2) IN ('YN','NY','YY')
                    and AU.expdate >= v_CURRDATE  and AU.valdate <= v_CURRDATE
                    AND A1.CDTYPE = 'CF' AND A1.CDNAME = 'AUTHTYPE' AND A1.CDVAL = 'AUTHORIZED'
                    AND NVL(AU.CHSTATUS,'C') <> 'A'
                    AND CASE WHEN v_RIGHTPOS >0 THEN SUBSTR(AU.LINKAUTH,v_RIGHTPOS,1) ELSE 'Y' END = 'Y'
                UNION ALL
                SELECT 0 AUTOID, 'M' TYP, CF.CUSTID, CF.IDCODE, CF.IDDATE, CF.IDPLACE, CF.FULLNAME, CD.CDCONTENT REF,
                    LNK.ACCTNO,to_char(cf.iddate,'DD/MM/RRRR') EFFDATE,nvl(to_char(cf.idexpired,'DD/MM/RRRR'),l_expdate_default) EXPDATE, cf.address
                FROM CFMAST CF, CFLINK LNK, ALLCODE CD
                WHERE TRIM(CF.CUSTID)=TRIM(LNK.CUSTID)
                    AND TRIM(LNK.LINKTYPE)=CD.CDVAL AND CD.CDTYPE='CF' AND CD.CDNAME='LINKTYPE'
                    --AND SUBSTR(LNK.LINKAUTH,4,2) IN ('YN','NY','YY')
                    AND TRIM(LNK.ACCTNO)=V_AFACCTNO
                    AND CASE WHEN v_RIGHTPOS >0 THEN SUBSTR(LNK.LINKAUTH,v_RIGHTPOS,1) ELSE 'Y' END = 'Y' ;

        END IF;

/*
If upper(v_BUYSELL) = 'TRUE' Then

    OPEN PV_REFCURSOR FOR
        SELECT 0 AUTOID, 'M' TYP, CF.CUSTID, CF.IDCODE, CF.IDDATE, CF.IDPLACE, CF.FULLNAME, CD.CDCONTENT REF,
        LNK.ACCTNO,to_char(cf.iddate,'DD/MM/RRRR') EFFDATE,nvl(to_char(cf.idexpired,'DD/MM/RRRR'),l_expdate_default) EXPDATE, cf.address
        FROM CFMAST CF, CFLINK LNK, ALLCODE CD
        WHERE TRIM(CF.CUSTID)=TRIM(LNK.CUSTID) AND TRIM(LNK.LINKTYPE)=CD.CDVAL AND CD.CDTYPE='CF' AND CD.CDNAME='LINKTYPE' AND SUBSTR(LNK.LINKAUTH,4,2) IN ('YN','NY','YY')
        AND TRIM(LNK.ACCTNO)=V_AFACCTNO

        UNION ALL

        SELECT AU.AUTOID, 'A' TYP, AU.CUSTID, CF.IDCODE, CF.IDDATE, CF.IDPLACE, CF.FULLNAME, CF.ADDRESS REF,
        AU.ACCTNO,TO_CHAR(AU.VALDATE,'DD/MM/YYYY') EFFDATE ,TO_CHAR(AU.EXPDATE,'DD/MM/YYYY') EXPDATE, CF.address
        FROM CFAUTH AU, CFMAST CF
        WHERE AU.CUSTID= CF.CUSTID AND TRIM(AU.ACCTNO)=V_AFACCTNO AND AU.deltd='N' AND substr(AU.linkauth,4,2) IN ('YN','NY','YY')  and AU.expdate > (SELECT TO_DATE (VARVALUE,'DD/MM/YYYY') FROM SYSVAR  WHERE VARNAME = 'CURRDATE' ) and AU.valdate <= (SELECT TO_DATE (VARVALUE,'DD/MM/YYYY') FROM SYSVAR  WHERE VARNAME = 'CURRDATE' );

Else
    OPEN PV_REFCURSOR FOR

        SELECT 0 AUTOID, 'M' TYP, CF.CUSTID, CF.IDCODE, CF.IDDATE, CF.IDPLACE, CF.FULLNAME, to_char(CD.CDCONTENT) REF, LNK.ACCTNO,to_char(cf.iddate,'DD/MM/RRRR') EFFDATE,nvl(to_char(cf.idexpired,'DD/MM/RRRR'),l_expdate_default) EXPDATE, cf.address
        FROM CFMAST CF, CFLINK LNK, ALLCODE CD
        WHERE TRIM(CF.CUSTID)=TRIM(LNK.CUSTID) AND TRIM(LNK.LINKTYPE)=CD.CDVAL AND CD.CDTYPE='CF' AND CD.CDNAME='LINKTYPE' AND substr(linkauth,3,1)='Y'
        AND TRIM(LNK.ACCTNO)=V_AFACCTNO

        UNION ALL

        SELECT AU.AUTOID, 'A' TYP, AU.CUSTID, CF.IDCODE, CF.IDDATE, CF.IDPLACE, CF.FULLNAME, '?y quy?n' REF,
        AU.ACCTNO,TO_CHAR(AU.VALDATE,'DD/MM/YYYY') EFFDATE ,TO_CHAR(AU.EXPDATE,'DD/MM/YYYY') EXPDATE, CF.address
        FROM CFAUTH AU, CFMAST CF
        WHERE AU.CUSTID= CF.CUSTID AND TRIM(AU.ACCTNO)=V_AFACCTNO AND   AU.deltd='N'
        AND substr(AU.linkauth,3,1)='Y'
        and AU.expdate > (SELECT TO_DATE (VARVALUE,'DD/MM/YYYY') FROM SYSVAR  WHERE VARNAME = 'CURRDATE' )
        and AU.valdate <= (SELECT TO_DATE (VARVALUE,'DD/MM/YYYY') FROM SYSVAR  WHERE VARNAME = 'CURRDATE' )

        UNION ALL

        SELECT 0 AUTOID, 'M' TYP, CF.CUSTID, CF.IDCODE, CF.IDDATE, CF.IDPLACE, CF.FULLNAME, to_char(A1.CDCONTENT) REF, CF.ACCTNO,to_char(cf.iddate,'DD/MM/RRRR') EFFDATE,nvl(to_char(cf.idexpired,'DD/MM/RRRR'),l_expdate_default) EXPDATE, cf.address
        FROM
        (
            SELECT CF.*, MST.RETYPE, MST.ACCTNO
            FROM CFMAST CF
            INNER JOIN
            (
                SELECT TRIM(RL.RECUSTID) RECUSTID, TRIM(RL.RETYPE) RETYPE, AF.ACCTNO FROM CFMAST CF, CFRELATION RL, AFMAST AF
                WHERE AF.CUSTID = CF.CUSTID
                      AND AF.ACCTNO = V_AFACCTNO
                      AND CF.custid = TRIM(RL.custid)
            )MST ON CF.CUSTID = MST.RECUSTID
        )CF INNER JOIN ALLCODE A1 ON  A1.CDTYPE='CF' AND A1.CDNAME ='RETYPE' AND A1.CDVAL = CF.RETYPE
;
End if;
*/


 EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE
 
 
 
 
/
