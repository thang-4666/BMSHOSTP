SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "RM0067"
   (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PV_ACCTNO      IN       VARCHAR2,
   PV_AUTOID       IN       VARCHAR2,
   PV_BANKTYPE      IN       VARCHAR2,
   PV_NUMTYPE       IN       VARCHAR2
   )
   IS
   v_BankCode VARCHAR2(500);
   v_TxNum VARCHAR2(500);
   v_beginDate VARCHAR2(10);

   V_STROPTION         VARCHAR2  (5);
   V_STRBRID           VARCHAR2  (16);
   v_brid               VARCHAR2(4);
   v_NumType         VARCHAR2  (20);
   v_CUSTODYCD         VARCHAR2  (10);
   v_AFACCTNO        VARCHAR2  (10);
   v_BankType        VARCHAR2  (20);
BEGIN


    V_STROPTION := OPT;
    v_brid := brid;

    IF  V_STROPTION = 'A' and v_brid = '0001' then
    V_STRBRID := '%';
    elsif V_STROPTION = 'B' then
        select br.mapid into V_STRBRID from brgrp br where br.brid = v_brid;
    else V_STRBRID := v_brid;

    END IF;

     IF PV_AUTOID='ALL' THEN
        v_TxNum:='%%';
    ELSE
        v_TxNum:=PV_AUTOID;
    END IF;

     IF PV_BANKTYPE='ALL' THEN
        v_BankType:='%%';
    ELSE
        v_BankType:=PV_BANKTYPE;
    END IF;

     IF PV_NUMTYPE='ALL' THEN
        v_NumType:='%%';
    ELSE
        v_NumType:=PV_NUMTYPE;
    END IF;

    IF PV_CUSTODYCD='ALL' THEN
        v_CUSTODYCD:='%%';
    ELSE
        v_CUSTODYCD:=PV_CUSTODYCD;
    END IF;

    IF PV_ACCTNO='ALL' THEN
        v_AFACCTNO:='%%';
    ELSE
        v_AFACCTNO:=PV_ACCTNO;
    END IF;




    SELECT TO_CHAR(TO_DATE(VARVALUE,'DD/MM/RRRR')-90,'DD/MM/RRRR') INTO v_beginDate FROM SYSVAR WHERE VARNAME='CURRDATE';


    OPEN PV_REFCURSOR
    FOR

    SELECT distinct acc.refdorc, LG.AUTOID,LG.VERSION, REQ.OBJNAME, REQ.TXDATE,REQ.AFFECTDATE, REQ.OBJKEY, REQ.REFCODE,req.trfcode,
CASE WHEN NVL(SEC.SYMBOL,'N/A')='N/A' THEN
    CASE WHEN cspks_rmproc.is_number(SUBSTR(REQ.REFCODE,0,1))=1 THEN '' ELSE REQ.REFCODE END
ELSE SEC.SYMBOL END SYMBOL,
REQ.BANKCODE,
    CRB.BANKNAME BANKNAME,
REQ.AFACCTNO,CF.CUSTODYCD,
CASE WHEN ACC.REFDORC ='D'  then fn_getdesbankacc(req.reqid,req.bankcode, req.trfcode) else AF.bankacctno  end BANKACCTNO,
  case when acc.refdorc ='D' then fn_getdesbankname(req.reqid,req.bankcode, req.trfcode) else CF.FULLNAME end FULLNAME,
    case when acc.refdorc='D' then CF.FULLNAME else fn_getdesbankname(req.reqid,req.bankcode, req.trfcode) end DESACCTNAME,
      CASE when acc.refdorc ='D' then AF.bankacctno else fn_getdesbankacc(req.reqid,req.bankcode, req.trfcode) end DESACCTNO,
     LGD.AMT TXAMT,LGD.REFNOTES NOTES, A0.CDCONTENT DESC_STATUS,LGD.ERRMSG ERRDESC,LG.TXDATE NGAY_TAO_BK,LG.AFFECTDATE NGAY_HL, A1.CDCONTENT
FROM (
        SELECT * FROM CRBTRFLOG WHERE TXDATE BETWEEN TO_DATE(F_DATE,'DD/MM/RRRR') AND TO_DATE(T_DATE,'DD/MM/RRRR')
        UNION ALL
        SELECT * FROM CRBTRFLOGHIST
        WHERE TXDATE BETWEEN TO_DATE(F_DATE,'DD/MM/RRRR') AND TO_DATE(T_DATE,'DD/MM/RRRR')
    ) LG,
    (
        SELECT * FROM CRBTRFLOGDTL WHERE TXDATE BETWEEN TO_DATE(F_DATE,'DD/MM/RRRR') AND TO_DATE(T_DATE,'DD/MM/RRRR')
        UNION ALL
        SELECT * FROM CRBTRFLOGDTLHIST
        WHERE TXDATE BETWEEN TO_DATE(F_DATE,'DD/MM/RRRR') AND TO_DATE(T_DATE,'DD/MM/RRRR')
    ) LGD,
    (
        SELECT * FROM CRBTXREQ WHERE TXDATE BETWEEN TO_DATE(F_DATE,'DD/MM/RRRR') AND TO_DATE(T_DATE,'DD/MM/RRRR')
        UNION ALL
        SELECT * FROM CRBTXREQHIST
        WHERE TXDATE BETWEEN TO_DATE(F_DATE,'DD/MM/RRRR') AND TO_DATE(T_DATE,'DD/MM/RRRR')
    ) REQ
,ALLCODE A0,SECURITIES_INFO SEC,AFMAST AF,(SELECT * FROM CFMAST WHERE INSTR(TLGOUPS, CAREBY)>0) CF,CRBDEFACCT ACC, crbdefbank crb, ALLCODE A1
WHERE LG.VERSION=LGD.VERSION AND LG.TRFCODE=LGD.TRFCODE AND LGD.REFREQID=REQ.REQID
AND REQ.BANKCODE=CRB.BANKCODE
AND req.TRFCODE = ACC.TRFCODE
AND LG.AFFECTDATE=REQ.AFFECTDATE AND LG.TXDATE=LGD.TXDATE
AND A0.CDTYPE='RM' AND A0.CDNAME='TRFLOGDTLSTS' AND A0.CDVAL=LGD.STATUS
AND REQ.AFACCTNO=AF.ACCTNO AND AF.CUSTID=CF.CUSTID AND REQ.REFCODE = SEC.CODEID(+) AND LGD.AMT >0
AND A1.CDTYPE = 'SY' AND A1.CDNAME = 'TRFCODE' AND A1.CDUSER='Y' AND req.TRFCODE = A1.CDVAL
AND LG.AUTOID LIKE v_TxNum AND req.TRFCODE LIKE v_NumType
AND CF.CUSTODYCD LIKE v_CUSTODYCD AND AF.ACCTNO LIKE v_AFACCTNO
and crb.bankcode like v_BankType
AND LGD.STATUS NOT IN ('D','B')
AND (substr(REQ.AFACCTNO,1,4) like  V_STRBRID or instr(V_STRBRID,substr(REQ.AFACCTNO,1,4)) <> 0)

    ;
EXCEPTION
    WHEN OTHERS THEN
        RETURN ;
END; -- Procedure
 
 
 
 
/
