SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "RM0044"
   (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   --PV_TXDATE      IN VARCHAR2,
   --PV_BANKCODE    IN       VARCHAR2,
    PV_TXNUM       IN       VARCHAR2,
   PV_VERSION       IN       VARCHAR2
   )
   IS
   v_BankCode VARCHAR2(500);
   v_TxNum VARCHAR2(500);
   v_beginDate VARCHAR2(10);

   V_STROPTION         VARCHAR2  (5);                       ---HOANGND
   V_STRBRID           VARCHAR2  (16);
   v_brid               VARCHAR2(4);

BEGIN


    V_STROPTION := OPT;
    v_brid := brid;

    IF  V_STROPTION = 'A' then
    V_STRBRID := '%';
    elsif V_STROPTION = 'B' then
        select br.mapid into V_STRBRID from brgrp br where br.brid = v_brid;
    else V_STRBRID := v_brid;

    END IF;                                 ---HOANGND
/*
    IF PV_BANKCODE='ALL' THEN
        v_BankCode:='%%';
    ELSE
        v_BankCode:=PV_BANKCODE;
    END IF;
*/
     IF PV_TXNUM='ALL' THEN
        v_TxNum:='%%';
    ELSE
        v_TxNum:=PV_TXNUM;
    END IF;

    SELECT TO_CHAR(TO_DATE(VARVALUE,'DD/MM/RRRR')-90,'DD/MM/RRRR') INTO v_beginDate FROM SYSVAR WHERE VARNAME='CURRDATE';


    OPEN PV_REFCURSOR
    FOR
    SELECT LG.VERSION,LG.VERSIONLOCAL,REQ.REQID,REQ.TXDATE,REQ.TRFCODE,REQ.OBJNAME,REQ.BANKCODE,
    CRB.BANKNAME BANKNAME,REQ.AFACCTNO,REQ.BANKACCT BANKACCT,RF.CUSTNAME_R BANKACCNAME,
    CF.CUSTODYCD SECACCOUNT,RF.DESACCTNO_R DEBANKACOUNT,RF.DESACCTNAME_R DEBANKNAME,
    LD.REFNOTES DESCRIPT,LD.AMT,LD.STATUS,LG.TXDATE NGAY_TAO_BK,LG.AFFECTDATE NGAY_HL
    FROM (
        SELECT * FROM CRBTRFLOG
        UNION ALL
        SELECT * FROM CRBTRFLOGHIST
        WHERE TXDATE>=TO_DATE(v_beginDate,'DD/MM/RRRR')
    ) LG,(
        SELECT * FROM CRBTRFLOGDTL
        UNION ALL
        SELECT * FROM CRBTRFLOGDTLHIST
        WHERE TXDATE>=TO_DATE(v_beginDate,'DD/MM/RRRR')
    ) LD,(
        SELECT * FROM CRBTXREQ
        UNION ALL
        SELECT * FROM CRBTXREQHIST
        WHERE TXDATE>=TO_DATE(v_beginDate,'DD/MM/RRRR')
    ) REQ,CRBDEFACCT CRA,CRBDEFBANK CRB,(SELECT * FROM CFMAST WHERE INSTR(TLGOUPS, CAREBY)>0) CF,AFMAST AF,
    (
        SELECT * FROM
        (
            SELECT DTL.REQID, DTL.FLDNAME, NVL(DTL.CVAL,DTL.NVAL) REFVAL
            FROM   (
                SELECT * FROM CRBTXREQ
                UNION ALL
                SELECT * FROM CRBTXREQHIST
                WHERE TXDATE>=TO_DATE(v_beginDate,'DD/MM/RRRR')
            ) MST, (
                SELECT * FROM CRBTXREQDTL
                UNION ALL
                SELECT * FROM CRBTXREQDTLHIST
            ) DTL
            WHERE MST.REQID=DTL.REQID
         )
         PIVOT  (
            MAX(REFVAL) AS R FOR (FLDNAME) IN (
                'DESACCTNO' as DESACCTNO,'DESACCTNAME' as DESACCTNAME,
                'SECACCOUNT' as SECACCOUNT,'BANKNAME' as BANKNAME,'CUSTNAME' as CUSTNAME
            )
        )
        ORDER BY REQID
    ) RF
    WHERE REQ.REQID=RF.REQID AND REQ.BANKCODE=CRA.REFBANK AND REQ.TRFCODE=CRA.TRFCODE
    AND cspks_rmproc.is_number(CRA.MSGID)=1 AND REQ.BANKCODE=CRB.BANKCODE
    AND REQ.AFACCTNO=AF.ACCTNO AND AF.CUSTID=CF.CUSTID
    AND LD.REFREQID=REQ.REQID AND LD.BANKCODE=REQ.BANKCODE AND LD.TRFCODE=REQ.TRFCODE
    AND LD.VERSION=LG.VERSION AND LD.BANKCODE=LG.REFBANK
    AND LD.TRFCODE=LG.TRFCODE AND LD.TXDATE=LG.TXDATE AND LG.STATUS IN ('P','A','S','E','H','F')
    --AND REQ.TXDATE=TO_DATE(PV_TXDATE,'DD/MM/RRRR')
    AND LG.AUTOID LIKE PV_TXNUM
    AND (AF.BRID LIKE V_STRBRID OR INSTR(V_STRBRID,AF.BRID)<>0)             ---HOANGND
    AND LG.TRFCODE='TRFCATAX'; --AND LG.REFBANK LIKE v_BankCode;
EXCEPTION
    WHEN OTHERS THEN
        RETURN ;
END; -- Procedure
 
 
 
 
/
