SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE rm0068
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
   PV_BANKTYPE      IN       VARCHAR2,
   PV_CUSTTYPE       IN       VARCHAR2,
   PV_TIME          IN          VARCHAR2
   )
   IS
   v_BankCode VARCHAR2(500);
   v_TxNum VARCHAR2(500);
   v_beginDate VARCHAR2(10);

   V_STROPTION         VARCHAR2  (5);
   V_STRBRID           VARCHAR2  (16);
   v_brid               VARCHAR2(4);
   v_CUSTTYPE         VARCHAR2  (5);
   v_CUSTODYCD         VARCHAR2  (10);
   v_AFACCTNO        VARCHAR2  (10);
   v_BankType        VARCHAR2  (20);
   v_BankAcc        VARCHAR2  (20);
BEGIN


    V_STROPTION := OPT;
    v_brid := brid;

    IF  V_STROPTION = 'A' and v_brid = '0001' then
    V_STRBRID := '%';
    elsif V_STROPTION = 'B' then
        select br.mapid into V_STRBRID from brgrp br where br.brid = v_brid;
    else V_STRBRID := v_brid;

    END IF;


     IF PV_BANKTYPE='ALL' THEN
        v_BankType:='%%';
    ELSE
        v_BankType:=PV_BANKTYPE;
    END IF;

     IF Pv_CUSTTYPE='ALL' THEN
        v_CUSTTYPE:='%%';
    ELSE
        v_CUSTTYPE:=Pv_CUSTTYPE;
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

    --select refacctno into v_BankAcc from CRBDEFACCT where refbank=PV_BANKTYPE and trfcode='TRFSUBTRER' and rownum<=1;
    select refacctno
        into v_BankAcc
    from CRBDEFACCT
    where refbank=DECODE(UPPER(PV_BANKTYPE),'ALL','BIDV',PV_BANKTYPE) and trfcode='TRFSUBTRER' and rownum<=1;


    SELECT TO_CHAR(TO_DATE(VARVALUE,'DD/MM/RRRR')-90,'DD/MM/RRRR') INTO v_beginDate FROM SYSVAR WHERE VARNAME='CURRDATE';


    OPEN PV_REFCURSOR
    FOR

    SELECT  distinct acc.refdorc, LG.AUTOID,LG.VERSION, REQ.OBJNAME, REQ.TXDATE,req.trfcode,
            REQ.BANKCODE,CRB.BANKNAME BANKNAME, v_BankAcc BankAcc,F_DATE FDATE, T_DATE TDATE,
            REQ.AFACCTNO,CF.CUSTODYCD,  CF.FULLNAME CUSTFULLNAME,
            --CASE WHEN ACC.REFDORC ='D'  then fn_getdesbankacc(req.reqid,req.bankcode, req.trfcode) else AF.bankacctno  end BANKACCTNO,
            AF.bankacctno BANKACCTNO,
            case when acc.refdorc ='D' then fn_getdesbankname(req.reqid,req.bankcode, req.trfcode) else CF.FULLNAME end FULLNAME,
            case when acc.refdorc='D' then CF.FULLNAME else fn_getdesbankname(req.reqid,req.bankcode, req.trfcode) end DESACCTNAME,
            CASE when acc.refdorc ='D' then AF.bankacctno else fn_getdesbankacc(req.reqid,req.bankcode, req.trfcode) end DESACCTNO,
            LGD.AMT TXAMT, NMPKS_EMS.fn_convert_to_vn(LGD.REFNOTES) NOTES, A0.CDCONTENT DESC_STATUS,LG.TXDATE NGAY_TAO_BK, A1.CDCONTENT
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
        ) REQ,
        ALLCODE A0,SECURITIES_INFO SEC,AFMAST AF,CFMAST CF,CRBDEFACCT ACC, crbdefbank crb, ALLCODE A1
    WHERE LG.VERSION=LGD.VERSION AND LG.TRFCODE=LGD.TRFCODE AND LGD.REFREQID=REQ.REQID
            AND REQ.BANKCODE=CRB.BANKCODE
            AND req.TRFCODE = ACC.TRFCODE
            AND LG.AFFECTDATE=REQ.AFFECTDATE AND LG.TXDATE=LGD.TXDATE
            AND A0.CDTYPE='RM' AND A0.CDNAME='TRFLOGDTLSTS' AND A0.CDVAL=LGD.STATUS
            AND REQ.AFACCTNO=AF.ACCTNO AND AF.CUSTID=CF.CUSTID AND REQ.REFCODE = SEC.CODEID(+) AND LGD.AMT >0
            AND A1.CDTYPE = 'SY' AND A1.CDNAME = 'TRFCODE' AND A1.CDUSER='Y' AND req.TRFCODE = A1.CDVAL
            --AND REQ.objname in ('6669','6643')
            AND REQ.trfcode = 'TRFSUBTRER'
            AND (case when CF.country='234' then '001' else '002' end) LIKE v_CUSTTYPE
            AND CF.CUSTODYCD LIKE v_CUSTODYCD
            AND AF.ACCTNO LIKE v_AFACCTNO
            and crb.bankcode like v_BankType
            --and ACC.REFDORC ='C'
            AND LGD.STATUS NOT IN ('D','B')
            --AnTB add 08/04/2015 tach bang ke di dau ngay va cuoi ngay
            AND case when PV_TIME ='ALL' then 'ALL'
                    when to_date(req.createdate,'DD/MM/RRRR') <>  req.txdate then '001'
                        else '002' end = PV_TIME
            --AND (substr(REQ.AFACCTNO,1,4) like  V_STRBRID or instr(V_STRBRID,substr(REQ.AFACCTNO,1,4)) <> 0)

    ;
EXCEPTION
    WHEN OTHERS THEN
        RETURN ;
END; -- Procedure
 
/
