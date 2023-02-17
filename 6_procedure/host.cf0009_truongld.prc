SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE cf0009_TruongLD (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   BRGID          IN       VARCHAR2,
   BRANCH         IN       VARCHAR2,
   STATUS         IN       VARCHAR2,
   PV_CUSTATCOM   IN       VARCHAR2
 )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE       COMMENTS
-- Diennt      15/12/2011 Create
-- TheNN       15-Mar-2012  Modified    Sua lay len dung du lieu khi truyen vao ALL chi nhanh
-- ---------   ------     -------------------------------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   v_bgrid varchar2(10);
   V_branch  varchar2(1000);
   V_BRANCHNAME VARCHAR2(2000);
   V_INBRID        VARCHAR2(4);
   V_STRBRID      VARCHAR2 (50);
   v_strstatus    VARCHAR2 (10);

   V_D_TOCHUC_TN  number(10,0);
   v_D_CANHAN_TN  number(10,0);
   V_D_TOCHUC_NN  number(10,0);
   V_D_CANHAN_NN  number(10,0);

   V_M_TOCHUC_TN  number(10,0);
   V_M_CANHAN_TN  number(10,0);
   V_M_TOCHUC_NN  number(10,0);
   V_M_CANHAN_NN  number(10,0);
   V_STRCUSTATCOM varchar2(10);
   v_strcust      varchar2(10);

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE

BEGIN
-- INSERT INTO TEMP_BUG(TEXT) VALUES('CF0001');COMMIT;
 /*  V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (BRID <> 'ALL')
   THEN
      V_STRBRID := BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;*/

   V_STROPTION := upper(OPT);
   V_INBRID := PV_BRID;
    if(V_STROPTION = 'A') then
        V_STRBRID := '%%';
    else
        if(V_STROPTION = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
    end if;
   IF (BRGID <> 'ALL')
   THEN
       v_bgrid:= BRGID;
   ELSE
      v_bgrid := '%%';
   END IF;
    V_branch:=BRANCH;
    -- LAY TEN CHI NHANH
    IF BRGID <> 'ALL' THEN
        SELECT BRNAME INTO V_BRANCHNAME FROM BRGRP WHERE BRID = BRGID;
    ELSE
        V_BRANCHNAME := '';
    END IF;

    IF STATUS is null or upper(STATUS) = 'ALL' THEN
        v_strstatus := '%';
    ELSE
        v_strstatus := upper(STATUS);
    END IF;
    v_strstatus := nvl(v_strstatus,'%');

    if PV_CUSTATCOM = 'Y' then
      V_STRCUSTATCOM := '%';
      v_strcust:='%';
      else
        V_STRCUSTATCOM := 'Y';
        v_strcust:=systemnums.C_COMPANYCD||'%';
    end if;

--------dong trong ky D_TOCHUC_TN
    SELECT count(distinct vw_tllog_all.msgacct) into V_D_TOCHUC_TN
    FROM vw_tllog_all,
            --VW_TLLOGFLD_ALL FLD,
            VSD_PROCESS_LOG vsd,
            (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0 ) cf
    WHERE vw_tllog_all.tltxcd = '0059'
        AND vw_tllog_all.txdate <= to_date(T_DATE,'dd/mm/rrrr')
        AND vw_tllog_all.txdate >= to_date(F_DATE,'dd/mm/rrrr') AND deltd <> 'Y'
        AND cf.custid = vw_tllog_all.msgacct AND cf.custtype = 'B'
        AND vw_tllog_all.TXNUM=vsd.TXNUM
        AND vw_tllog_all.TXDATE=vsd.TXDATE
        and vsd.process ='N'
        and cf.custatcom like V_STRCUSTATCOM
        AND CF.CUSTODYCD like v_strcust
        AND vw_tllog_all.TXSTATUS IN ('1','7')
        and (cf.status like v_strstatus or cf.ACTIVESTS like v_strstatus)
        AND CF.BRID like v_bgrid
        and substr(CF.custodycd,4,1)='C'
        and cf.class<>'000' and substr(CF.custodycd,4,1)<>'P' --issiu VCBSDEPII-215
        AND CF.custodycd IS NOT NULL;

--------dong trong ky D_CANHAN_TN
    SELECT count(distinct vw_tllog_all.msgacct) into v_D_CANHAN_TN
    FROM vw_tllog_all,
            --VW_TLLOGFLD_ALL FLD,
            VSD_PROCESS_LOG vsd,
            (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
    WHERE vw_tllog_all.tltxcd = '0059' AND vw_tllog_all.txdate <= to_date(T_DATE,'dd/mm/rrrr') AND vw_tllog_all.txdate >= to_date(F_DATE,'dd/mm/rrrr')
        AND vw_tllog_all.deltd <> 'Y'
        AND vw_tllog_all.TXNUM=vsd.TXNUM
        AND vw_tllog_all.TXDATE=vsd.TXDATE
        --AND FLD.FLDCD='08' AND FLD.CVALUE<>'N'
        and vsd.process ='N'
        AND vw_tllog_all.TXSTATUS IN ('1','7')
        AND cf.custid = vw_tllog_all.msgacct and cf.custtype = 'I'
        and cf.custatcom like V_STRCUSTATCOM
        AND CF.CUSTODYCD like v_strcust
        and cf.custodycd is not null
        and (cf.status like v_strstatus or cf.ACTIVESTS like v_strstatus)
        AND CF.BRID like v_bgrid
        AND CF.custodycd IS NOT NULL
        and substr(CF.custodycd,4,1)='C'
       and cf.class<>'000';

--------dong trong ky D_TOCHUC_NN
    SELECT count(distinct msgacct) into V_D_TOCHUC_NN
    FROM vw_tllog_all,VW_TLLOGFLD_ALL FLD, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
    WHERE tltxcd = '0059' AND vw_tllog_all.txdate <= to_date(T_DATE,'dd/mm/rrrr') AND vw_tllog_all.txdate >= to_date(F_DATE,'dd/mm/rrrr') AND deltd <> 'Y'
        AND cf.custid = vw_tllog_all.msgacct AND cf.custtype = 'B'
        and cf.custatcom like V_STRCUSTATCOM
        AND CF.CUSTODYCD like v_strcust
        AND vw_tllog_all.TXNUM=FLD.TXNUM
        AND vw_tllog_all.TXDATE=FLD.TXDATE
        AND FLD.FLDCD='08' AND FLD.CVALUE<>'N'
             AND vw_tllog_all.TXSTATUS IN ('1','7')
        and (cf.status like v_strstatus or cf.ACTIVESTS like v_strstatus)
        AND CF.BRID like v_bgrid
        AND CF.custodycd IS NOT NULL
       and substr(CF.custodycd,4,1)='F'
       and cf.class<>'000';
--------dong trong ky D_CANHAN_NN
    SELECT count(distinct msgacct) into V_D_CANHAN_NN
    FROM vw_tllog_all,VW_TLLOGFLD_ALL FLD, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
    WHERE tltxcd = '0059' AND vw_tllog_all.txdate <= to_date(T_DATE,'dd/mm/rrrr') AND vw_tllog_all.txdate >= to_date(F_DATE,'dd/mm/rrrr') AND deltd <> 'Y'
        AND cf.custid = vw_tllog_all.msgacct AND cf.custtype = 'I'
        ---AND cf.custatcom = 'Y'
        and cf.custatcom like V_STRCUSTATCOM
        AND CF.CUSTODYCD like v_strcust
        AND vw_tllog_all.TXNUM=FLD.TXNUM
        AND vw_tllog_all.TXDATE=FLD.TXDATE
             AND vw_tllog_all.TXSTATUS IN ('1','7')
        AND FLD.FLDCD='08' AND FLD.CVALUE<>'N'
        AND CF.custodycd IS NOT NULL
        and (cf.status like v_strstatus or cf.ACTIVESTS like v_strstatus)
        AND CF.BRID like v_bgrid
        and substr(CF.custodycd,4,1)='F'
        and cf.class<>'000';
----mo trong ky V_M_TOCHUC_TN
    SELECT count(distinct custid) into V_M_TOCHUC_TN FROM
    (
        SELECT cf.custid FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0 ) cf
        WHERE cf.opndate >= to_date(F_DATE,'dd/mm/rrrr') AND cf.opndate <= to_date(T_DATE,'dd/mm/rrrr')
            AND cf.custtype = 'B'
            and (cf.status like v_strstatus or cf.ACTIVESTS like v_strstatus)
            AND cf.custodycd IS NOT NULL
            and cf.custatcom like V_STRCUSTATCOM
            AND CF.CUSTODYCD like v_strcust
            AND(CF.STATUS='A' OR (/*CF.STATUS <>'C' AND*/ INSTR(CF.pstatus,'A') <> 0))
            and cf.class<>'000' and substr(CF.custodycd,4,1)<>'P' --issiu VCBSDEPII-215
            and cf.custodycd is not null  and substr(CF.custodycd,4,1)='C'
            and CF.BRID like v_bgrid
        union all
        SELECT vw_tllog_all.msgacct FROM vw_tllog_all, cfmast cf,VW_TLLOGFLD_ALL FLD
        WHERE tltxcd = '0067' AND busdate <= to_date(T_DATE,'dd/mm/rrrr') AND busdate >= to_date(F_DATE,'dd/mm/rrrr') AND deltd <> 'Y'
            AND cf.custid = vw_tllog_all.msgacct AND cf.custtype = 'B'
            --AND cf.custatcom = 'Y'
            and cf.custatcom like V_STRCUSTATCOM
             AND CF.CUSTODYCD like v_strcust
            AND vw_tllog_all.TXNUM=FLD.TXNUM
            AND vw_tllog_all.TXDATE=FLD.TXDATE
            AND FLD.FLDCD='08' AND FLD.CVALUE<>'N'
             AND vw_tllog_all.TXSTATUS IN ('1','7')
             AND(CF.STATUS='A' OR (/*CF.STATUS <>'C' AND*/ INSTR(CF.pstatus,'A') <> 0))
            and (cf.status like v_strstatus or cf.ACTIVESTS like v_strstatus)
            AND CF.BRID like v_bgrid
            AND CF.custodycd IS NOT NULL  and substr(CF.custodycd,4,1)='C'
            and cf.class<>'000' and substr(CF.custodycd,4,1)<>'P' --issiu VCBSDEPII-215

    );
----mo trong ky V_M_CANHAN_TN
    SELECT count(distinct custid) into V_M_CANHAN_TN
    FROM
    (
        SELECT cf.custid FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0 ) cf
        WHERE cf.opndate >= to_date(F_DATE,'dd/mm/rrrr') AND cf.opndate <= to_date(T_DATE,'dd/mm/rrrr')
            AND cf.custtype = 'I'
            AND cf.custodycd IS NOT NULL
            and cf.class<>'000'  and substr(CF.custodycd,4,1)='C'
            AND(CF.STATUS='A' OR (/*CF.STATUS <>'C' AND*/ INSTR(CF.pstatus,'A') <> 0))
            and (cf.status like v_strstatus or cf.ACTIVESTS like v_strstatus)
            AND CF.CUSTODYCD like v_strcust
            and cf.custatcom like V_STRCUSTATCOM
            and cf.custodycd is not null
            and CF.BRID like v_bgrid
        UNION all
        SELECT vw_tllog_all.msgacct custid FROM vw_tllog_all, cfmast cf,VW_TLLOGFLD_ALL FLD
        WHERE tltxcd = '0067' AND busdate <= to_date(T_DATE,'dd/mm/rrrr') AND busdate >= to_date(F_DATE,'dd/mm/rrrr') AND deltd <> 'Y'
            AND cf.custid = vw_tllog_all.msgacct AND cf.custtype = 'I'
                   AND CF.CUSTODYCD like v_strcust
            and cf.custatcom like V_STRCUSTATCOM
            AND vw_tllog_all.TXNUM=FLD.TXNUM
        AND vw_tllog_all.TXDATE=FLD.TXDATE
        AND FLD.FLDCD='08' AND FLD.CVALUE<>'N'
             AND vw_tllog_all.TXSTATUS IN ('1','7')
             AND(CF.STATUS='A' OR (/*CF.STATUS <>'C' AND*/ INSTR(CF.pstatus,'A') <> 0))
            and (cf.status like v_strstatus or cf.ACTIVESTS like v_strstatus)
            AND CF.BRID like v_bgrid
            AND CF.custodycd IS NOT NULL
            and cf.class<>'000'  and substr(CF.custodycd,4,1)='C'
    );
----mo trong ky V_M_TOCHUC_NN
    SELECT count(distinct custid) into V_M_TOCHUC_NN
    FROM
    (
        SELECT cf.custid FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
        WHERE cf.opndate >= to_date(F_DATE,'dd/mm/rrrr') AND cf.opndate <= to_date(T_DATE,'dd/mm/rrrr')
            AND cf.custtype = 'B'
            AND cf.custodycd IS NOT NULL
            and substr(CF.custodycd,4,1)='F' and cf.class<>'000'
        AND CF.CUSTODYCD like v_strcust
            and cf.custatcom like V_STRCUSTATCOM
            and cf.custodycd is not null
            AND(CF.STATUS='A' OR (/*CF.STATUS <>'C' AND*/ INSTR(CF.pstatus,'A') <> 0))
            and (cf.status like v_strstatus or cf.ACTIVESTS like v_strstatus)
            and CF.BRID like v_bgrid
        UNION all
        SELECT vw_tllog_all.msgacct custid FROM vw_tllog_all, cfmast cf,VW_TLLOGFLD_ALL FLD
        WHERE tltxcd = '0067' AND busdate <= to_date(T_DATE,'dd/mm/rrrr') AND busdate >= to_date(F_DATE,'dd/mm/rrrr') AND deltd <> 'Y'
            AND cf.custid = vw_tllog_all.msgacct AND cf.custtype = 'B'
                 AND CF.CUSTODYCD like v_strcust
            and cf.custatcom like V_STRCUSTATCOM
            AND vw_tllog_all.TXNUM=FLD.TXNUM
        AND vw_tllog_all.TXDATE=FLD.TXDATE
        AND FLD.FLDCD='08' AND FLD.CVALUE<>'N'
             AND vw_tllog_all.TXSTATUS IN ('1','7')
             AND(CF.STATUS='A' OR (/*CF.STATUS <>'C' AND*/ INSTR(CF.pstatus,'A') <> 0))
            and (cf.status like v_strstatus or cf.ACTIVESTS like v_strstatus)
            AND CF.custodycd IS NOT NULL
            AND CF.BRID like v_bgrid
             and substr(CF.custodycd,4,1)='F' and cf.class<>'000'
    );
----mo trong ky V_M_CANHAN_NN
    SELECT count(distinct custid) into V_M_CANHAN_NN
    FROM
    (
        SELECT custid FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0)
        WHERE opndate >= to_date(F_DATE,'dd/mm/rrrr') AND opndate <= to_date(T_DATE,'dd/mm/rrrr')
            AND custtype = 'I'
             and substr(custodycd,4,1)='F' and class<>'000'
            AND custodycd IS NOT NULL
            AND CUSTODYCD like v_strcust
            and custatcom like V_STRCUSTATCOM
            and custodycd is not null
            AND(STATUS='A' OR (/*STATUS <>'C' AND*/ INSTR(pstatus,'A') <> 0))
            and (status like v_strstatus or ACTIVESTS like v_strstatus)
            and BRID like v_bgrid
        UNION all
        SELECT vw_tllog_all.msgacct custid FROM vw_tllog_all, cfmast cf,VW_TLLOGFLD_ALL FLD
        WHERE tltxcd = '0067' AND busdate <= to_date(T_DATE,'dd/mm/rrrr') AND busdate >= to_date(F_DATE,'dd/mm/rrrr') AND deltd <> 'Y'
            AND cf.custid = vw_tllog_all.msgacct AND cf.custtype = 'I'
            AND CF.CUSTODYCD like v_strcust
            and cf.custatcom like V_STRCUSTATCOM
            AND vw_tllog_all.TXNUM=FLD.TXNUM
        AND vw_tllog_all.TXDATE=FLD.TXDATE
        AND FLD.FLDCD='08' AND FLD.CVALUE<>'N'
             AND vw_tllog_all.TXSTATUS IN ('1','7')
             AND(CF.STATUS='A' OR (/*CF.STATUS <>'C' AND*/ INSTR(CF.pstatus,'A') <> 0))
            and (cf.status like v_strstatus or cf.ACTIVESTS like v_strstatus)
            AND CF.BRID like v_bgrid
            AND CF.custodycd IS NOT NULL
             and substr(CF.custodycd,4,1)='F' and cf.class<>'000'
    );

OPEN PV_REFCURSOR
  FOR
    /*SELECT PV_BRID PV_BRID,  to_date(T_DATE,'dd/mm/rrrr') todate, V_branch BRAN, BRGID BRANCHID, V_BRANCHNAME BRANCHNAME,
       ---Dong trong thang.
       V_D_TOCHUC_TN D_TOCHUC_TN, v_D_CANHAN_TN D_CANHAN_TN,
       V_D_TOCHUC_NN D_TOCHUC_NN, V_D_CANHAN_NN D_CANHAN_NN,
       --Mo trong thang.
       V_M_TOCHUC_TN GIUA_TOCHUC_TN, V_M_CANHAN_TN GIUA_CANHAN_TN,
       V_M_TOCHUC_NN GIUA_TOCHUC_NN, V_M_CANHAN_NN GIUA_CANHAN_NN,
       --DAU KY
       A.CK_TOCHUC_TN,B.CK_CANHAN_TN,C.CK_TOCHUC_NN,D.CK_CANHAN_NN
    FROM
    (   SELECT COUNT(*) CK_TOCHUC_TN
        FROM   (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, AFMAST AF,  AFTYPE AFT
        WHERE            AF.CUSTID = CF.CUSTID
                 AND      AF.status not in ('P','R','E')
                 AND      nvl(AF.OPNDATE,TO_DATE('01/01/2010','dd/MM/rrrr')) >= to_date('01/01/1900','dd/mm/rrrr')
                 AND      nvl(AF.OPNDATE,TO_DATE('01/01/2010','dd/MM/rrrr')) <= to_date(F_DATE,'dd/mm/rrrr')
                 AND      nvl(AF.clsdate,CASE WHEN AF.status='C' THEN  TO_DATE('01/01/2000','dd/MM/yyyy') ELSE TO_DATE('01/01/9000','dd/MM/yyyy') END)> to_date(F_DATE,'dd/mm/rrrr')
                 AND      nvl(CF.CFclsdate, CASE WHEN cf.status='C' THEN  TO_DATE('01/01/2000','dd/MM/rrrr') ELSE TO_DATE('01/01/9000','dd/MM/rrrr') END)> to_date(F_DATE,'dd/mm/rrrr')
                 AND      CF.CLASS <> '000'
                 AND      AF.ACTYPE=AFT.ACTYPE
                 AND      AFT.PRODUCTTYPE ='NN'
                 AND      CF.CUSTTYPE='B'
                 --AND      nvl(CF.country,'234') = '234'
                 AND      SUBSTR(CF.CUSTODYCD,4,1)<>'F'
                 AND      SUBSTR(CF.CUSTODYCD,4,1)<>'P'
                 AND      CF.CUSTODYCD like v_strcust
                 and      cf.CUSTATCOM like V_STRCUSTATCOM
                 and      (cf.status like v_strstatus or cf.ACTIVESTS like v_strstatus)
                 and      CF.BRID like v_bgrid
        ) A,
         (   SELECT COUNT(*) CK_CANHAN_TN
        FROM   (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, AFMAST AF,  AFTYPE AFT
        WHERE            AF.CUSTID = CF.CUSTID
                 AND      AF.status not in ('P','R','E')
                 AND      nvl(AF.OPNDATE,TO_DATE('01/01/2010','dd/MM/rrrr')) >= to_date('01/01/1900','dd/mm/rrrr')
                 AND      nvl(AF.OPNDATE,TO_DATE('01/01/2010','dd/MM/rrrr')) <= to_date(F_DATE,'dd/mm/rrrr')
                 AND      nvl(AF.clsdate,CASE WHEN AF.status='C' THEN  TO_DATE('01/01/2000','dd/MM/yyyy') ELSE TO_DATE('01/01/9000','dd/MM/yyyy') END)> to_date(F_DATE,'dd/mm/rrrr')
                 AND      nvl(CF.CFclsdate, CASE WHEN cf.status='C' THEN  TO_DATE('01/01/2000','dd/MM/rrrr') ELSE TO_DATE('01/01/9000','dd/MM/rrrr') END)> to_date(F_DATE,'dd/mm/rrrr')
                 AND      CF.CLASS <> '000'
                 AND      AF.ACTYPE=AFT.ACTYPE
                 AND      AFT.PRODUCTTYPE ='NN'
                 AND      CF.CUSTTYPE='I'
                 --AND      nvl(CF.country,'234') = '234'
                    AND      SUBSTR(CF.CUSTODYCD,4,1)<>'F'
                 AND      CF.CUSTODYCD like v_strcust
                 and      cf.CUSTATCOM like V_STRCUSTATCOM
                 and      (cf.status like v_strstatus or cf.ACTIVESTS like v_strstatus)
                 and      CF.BRID like v_bgrid
        ) B,
         (   SELECT COUNT(*) CK_TOCHUC_NN
        FROM   (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, AFMAST AF,  AFTYPE AFT
        WHERE            AF.CUSTID = CF.CUSTID
                 AND      AF.status not in ('P','R','E')
                 AND      nvl(AF.OPNDATE,TO_DATE('01/01/2010','dd/MM/rrrr')) >= to_date('01/01/1900','dd/mm/rrrr')
                 AND      nvl(AF.OPNDATE,TO_DATE('01/01/2010','dd/MM/rrrr')) <= to_date(F_DATE,'dd/mm/rrrr')
                 AND      nvl(AF.clsdate,CASE WHEN AF.status='C' THEN  TO_DATE('01/01/2000','dd/MM/yyyy') ELSE TO_DATE('01/01/9000','dd/MM/yyyy') END)> to_date(F_DATE,'dd/mm/rrrr')
                 AND      nvl(CF.CFclsdate, CASE WHEN cf.status='C' THEN  TO_DATE('01/01/2000','dd/MM/rrrr') ELSE TO_DATE('01/01/9000','dd/MM/rrrr') END)> to_date(F_DATE,'dd/mm/rrrr')
                 AND      CF.CLASS <> '000'
                 AND      AF.ACTYPE=AFT.ACTYPE
                 AND      AFT.PRODUCTTYPE ='NN'
                 AND      CF.CUSTTYPE='B'
                -- AND      nvl(CF.country,'234') <> '234'
                   AND      SUBSTR(CF.CUSTODYCD,4,1)='F'
                 AND      CF.CUSTODYCD like v_strcust
                 and      cf.CUSTATCOM like V_STRCUSTATCOM
                 and      (cf.status like v_strstatus or cf.ACTIVESTS like v_strstatus)
                 and      CF.BRID like v_bgrid
        ) C,
         (   SELECT COUNT(*) CK_CANHAN_NN
        FROM   (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, AFMAST AF,  AFTYPE AFT
        WHERE            AF.CUSTID = CF.CUSTID
                 AND      AF.status not in ('P','R','E')
                 AND      nvl(AF.OPNDATE,TO_DATE('01/01/2010','dd/MM/rrrr')) >= to_date('01/01/1900','dd/mm/rrrr')
                 AND      nvl(AF.OPNDATE,TO_DATE('01/01/2010','dd/MM/rrrr')) <= to_date(F_DATE,'dd/mm/rrrr')
                 AND      nvl(AF.clsdate,CASE WHEN AF.status='C' THEN  TO_DATE('01/01/2000','dd/MM/yyyy') ELSE TO_DATE('01/01/9000','dd/MM/yyyy') END)> to_date(F_DATE,'dd/mm/rrrr')
                 AND      nvl(CF.CFclsdate, CASE WHEN cf.status='C' THEN  TO_DATE('01/01/2000','dd/MM/rrrr') ELSE TO_DATE('01/01/9000','dd/MM/rrrr') END)> to_date(F_DATE,'dd/mm/rrrr')
                 AND      CF.CLASS <> '000'
                 AND      AF.ACTYPE=AFT.ACTYPE
                 AND      AFT.PRODUCTTYPE ='NN'
                 AND      CF.CUSTTYPE='I'
                -- AND      nvl(CF.country,'234') <> '234'
                   AND      SUBSTR(CF.CUSTODYCD,4,1)='F'
                 AND      CF.CUSTODYCD like v_strcust
                 and      cf.CUSTATCOM like V_STRCUSTATCOM
                 and      (cf.status like v_strstatus or cf.ACTIVESTS like v_strstatus)
                 and      CF.BRID like v_bgrid
        ) D
     ;*/

SELECT PV_BRID PV_BRID,  to_date(T_DATE,'dd/mm/yyyy') todate, V_branch BRAN, BRGID BRANCHID, V_BRANCHNAME BRANCHNAME,
       ---Dong trong thang.
       V_D_TOCHUC_TN D_TOCHUC_TN, v_D_CANHAN_TN D_CANHAN_TN,
       V_D_TOCHUC_NN D_TOCHUC_NN, V_D_CANHAN_NN D_CANHAN_NN,
       --Mo trong thang.
       V_M_TOCHUC_TN GIUA_TOCHUC_TN, V_M_CANHAN_TN GIUA_CANHAN_TN,
       V_M_TOCHUC_NN GIUA_TOCHUC_NN, V_M_CANHAN_NN GIUA_CANHAN_NN,
       --CUOI KY
        (
            SELECT a.amt + b.amt - c.amt FROM
            (
                SELECT count(*) amt FROM (
                    select DISTINCT cf.* from (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af
                    where cf.custid = af.custid
                        --and af.status = 'A'
                        ) cf
                WHERE cf.status = 'A' AND cf.custtype = 'B'
                    ---AND cf.custatcom = 'Y'
                    and cf.custatcom like V_STRCUSTATCOM
                    and cf.class<>'000' and substr(CF.custodycd,4,1)<>'P' --issiu VCBSDEPII-215
                    AND cf.custodycd IS NOT NULL
                    and nvl(cf.country,'234') = '234'
                    and (cf.status like v_strstatus or cf.ACTIVESTS like v_strstatus)
                    and CF.BRID like v_bgrid
            ) a,
            (
                SELECT count(*) amt FROM vw_tllog_all, cfmast cf,VW_TLLOGFLD_ALL FLD
                WHERE tltxcd = '0059' AND busdate > to_date(T_DATE,'dd/mm/rrrr') AND deltd <> 'Y'
                    AND cf.custid = vw_tllog_all.msgacct AND cf.custtype = 'B'
                    ---AND cf.custatcom = 'Y'
                    and cf.custatcom like V_STRCUSTATCOM
                    AND vw_tllog_all.TXNUM=FLD.TXNUM
                    AND vw_tllog_all.TXDATE=FLD.TXDATE
                    AND FLD.FLDCD='08' AND FLD.CVALUE<>'N'
                    AND CF.custodycd IS NOT NULL
                         AND vw_tllog_all.TXSTATUS IN ('1','7')
                    and (cf.status like v_strstatus or cf.ACTIVESTS like v_strstatus)
                    AND CF.BRID like v_bgrid
                    AND cf.custodycd IS NOT NULL
                    and cf.class<>'000' and substr(CF.custodycd,4,1)<>'P' --issiu VCBSDEPII-215
                    and nvl(cf.country,'234') = '234'
            ) b,
            (
                SELECT count(*) amt FROM
                (
                    SELECT cf.custid FROM cfmast cf WHERE cf.opndate > to_date(T_DATE,'dd/mm/rrrr')
                        AND cf.custtype = 'B'
                        and (cf.status like v_strstatus or cf.ACTIVESTS like v_strstatus)
                        AND cf.custodycd IS NOT NULL
                        and nvl(cf.country,'234') = '234'
                        and cf.class<>'000' and substr(CF.custodycd,4,1)<>'P' --issiu VCBSDEPII-215
                        AND(CF.STATUS='A' OR (/*CF.STATUS <>'C' AND*/ INSTR(CF.pstatus,'A') <> 0))
                        ----AND cf.custatcom = 'Y'
                        and cf.custatcom like V_STRCUSTATCOM
                        and CF.BRID like v_bgrid
                    union all
                    SELECT vw_tllog_all.msgacct FROM vw_tllog_all, cfmast cf,VW_TLLOGFLD_ALL FLD
                    WHERE tltxcd = '0067' AND busdate > to_date(T_DATE,'dd/mm/rrrr') AND deltd <> 'Y'
                        AND cf.custid = vw_tllog_all.msgacct AND cf.custtype = 'B'
                        ---AND cf.custatcom = 'Y'
                        and cf.custatcom like V_STRCUSTATCOM
                        AND CF.custodycd IS NOT NULL
                        AND vw_tllog_all.TXNUM=FLD.TXNUM
                        AND vw_tllog_all.TXDATE=FLD.TXDATE
                        AND vw_tllog_all.TXSTATUS IN ('1','7')
                         AND(CF.STATUS='A' OR (/*CF.STATUS <>'C' AND*/ INSTR(CF.pstatus,'A') <> 0))
                        and cf.class<>'000' and substr(CF.custodycd,4,1)<>'P' --issiu VCBSDEPII-215
                        AND FLD.FLDCD='08' AND FLD.CVALUE<>'N'
                        and (cf.status like v_strstatus or cf.ACTIVESTS like v_strstatus)
                        AND CF.BRID like v_bgrid
                        and nvl(cf.country,'234') = '234'
                )
            ) c
        ) CK_TOCHUC_TN,
       (SELECT a.amt + b.amt - c.amt FROM
            (
                SELECT count(*) amt FROM (
                    select DISTINCT cf.* from (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af
                    where cf.custid = af.custid
                        --and af.status = 'A'
                        ) cf
                WHERE cf.status = 'A' AND cf.custtype = 'I'
                    ----AND cf.custatcom = 'Y'
                    and cf.custatcom like V_STRCUSTATCOM
                    AND cf.custodycd IS NOT NULL
                    and nvl(cf.country,'234') = '234'
                    and (cf.status like v_strstatus or cf.ACTIVESTS like v_strstatus)
                    and CF.BRID like v_bgrid
            ) a,
            (
                SELECT count(*) amt FROM vw_tllog_all,VW_TLLOGFLD_ALL FLD, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
                WHERE tltxcd = '0059' AND busdate > to_date(T_DATE,'dd/mm/rrrr') AND deltd <> 'Y'
                    AND cf.custid = vw_tllog_all.msgacct AND cf.custtype = 'I'
                    ----AND cf.custatcom = 'Y'
                    and cf.custatcom like V_STRCUSTATCOM
                    AND CF.custodycd IS NOT NULL
                    AND vw_tllog_all.TXNUM=FLD.TXNUM
                    AND vw_tllog_all.TXDATE=FLD.TXDATE
                    AND FLD.FLDCD='08' AND FLD.CVALUE<>'N'
                    AND vw_tllog_all.TXSTATUS IN ('1','7')
                    and (cf.status like v_strstatus or cf.ACTIVESTS like v_strstatus)
                    AND CF.BRID like v_bgrid
                    and nvl(country,'234') = '234'
            ) b,
            (
                 SELECT count(*) amt FROM
                (SELECT cf.custid FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf WHERE cf.opndate >= to_date(T_DATE,'dd/mm/rrrr')
                        AND cf.custtype = 'I'
                        and (cf.status like v_strstatus or cf.ACTIVESTS like v_strstatus)
                        AND cf.custodycd IS NOT NULL
                        and nvl(cf.country,'234') = '234'
                        ---AND cf.custatcom = 'Y'
                         AND(CF.STATUS='A' OR (/*CF.STATUS <>'C' AND*/ INSTR(CF.pstatus,'A') <> 0))
                        and cf.custatcom like V_STRCUSTATCOM
                        and CF.BRID like v_bgrid
                union all
                SELECT vw_tllog_all.msgacct FROM vw_tllog_all,VW_TLLOGFLD_ALL FLD, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
                  --  WHERE tltxcd = '0067' AND busdate >= to_date(T_DATE,'dd/mm/rrrr') AND deltd <> 'Y'
                    WHERE tltxcd = '0067' AND busdate > to_date(T_DATE,'dd/mm/rrrr') AND deltd <> 'Y'
                    AND cf.custid = vw_tllog_all.msgacct AND cf.custtype = 'I'
                    ---AND cf.custatcom = 'Y'
                    and cf.custatcom like V_STRCUSTATCOM
                    AND CF.custodycd IS NOT NULL
                    AND vw_tllog_all.TXNUM=FLD.TXNUM
                     AND vw_tllog_all.TXDATE=FLD.TXDATE
                      AND FLD.FLDCD='08' AND FLD.CVALUE<>'N'
                       AND(CF.STATUS='A' OR (/*CF.STATUS <>'C' AND*/ INSTR(CF.pstatus,'A') <> 0))
                           AND vw_tllog_all.TXSTATUS IN ('1','7')
                    and (cf.status like v_strstatus or cf.ACTIVESTS like v_strstatus)
                    AND CF.BRID like v_bgrid
                    and nvl(country,'234') = '234'
                )
            )c
       ) CK_CANHAN_TN,
       (SELECT a.amt + b.amt - c.amt FROM
            (SELECT count(*) amt FROM (
                    select DISTINCT cf.* from (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af
                    where cf.custid = af.custid
                        --and af.status = 'A'
                        ) cf WHERE STATUS = 'A'
                    AND cf.custtype = 'B'
                    and (cf.status like v_strstatus or cf.ACTIVESTS like v_strstatus)
                    AND cf.custodycd IS NOT NULL
                    and nvl(cf.country,'234') <> '234'
                    ----AND cf.custatcom = 'Y'
                    and cf.custatcom like V_STRCUSTATCOM
                    and CF.BRID like v_bgrid
            ) a,
            (SELECT count(*) amt FROM vw_tllog_all,VW_TLLOGFLD_ALL FLD, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
                WHERE tltxcd = '0059' AND busdate > to_date(T_DATE,'dd/mm/rrrr')  AND deltd <> 'Y'
                AND cf.custid = vw_tllog_all.msgacct AND cf.custtype = 'B'
                ---AND cf.custatcom = 'Y'
                and cf.custatcom like V_STRCUSTATCOM
                AND vw_tllog_all.TXNUM=FLD.TXNUM
                AND vw_tllog_all.TXDATE=FLD.TXDATE
                AND FLD.FLDCD='08' AND FLD.CVALUE<>'N'
                AND vw_tllog_all.TXSTATUS IN ('1','7')
                and (cf.status like v_strstatus or cf.ACTIVESTS like v_strstatus)
                AND CF.BRID like v_bgrid
                AND CF.custodycd IS NOT NULL
                and nvl(country,'234') <> '234'
            ) b,
            (
                SELECT count(*) amt FROM
                (SELECT cf.custid FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf  WHERE cf.opndate >= to_date(T_DATE,'dd/mm/rrrr')
                        AND cf.custtype = 'B'
                        and (cf.status like v_strstatus or cf.ACTIVESTS like v_strstatus)
                        AND cf.custodycd IS NOT NULL
                        and nvl(cf.country,'234') <> '234'
                        ----AND cf.custatcom = 'Y'
                        AND(CF.STATUS='A' OR (/*CF.STATUS <>'C' AND*/ INSTR(CF.pstatus,'A') <> 0))
                        and cf.custatcom like V_STRCUSTATCOM
                        and CF.BRID like v_bgrid
                union all
                SELECT vw_tllog_all.msgacct FROM vw_tllog_all, cfmast cf, VW_TLLOGFLD_ALL FLD
                    WHERE tltxcd = '0067' AND busdate > to_date(T_DATE,'dd/mm/rrrr') AND deltd <> 'Y'
                    AND cf.custid = vw_tllog_all.msgacct AND cf.custtype = 'B'
                    ---AND cf.custatcom = 'Y'
                    and cf.custatcom like V_STRCUSTATCOM
                    AND vw_tllog_all.TXNUM=FLD.TXNUM
                    AND vw_tllog_all.TXDATE=FLD.TXDATE
                    AND FLD.FLDCD='08' AND FLD.CVALUE<>'N'
                    AND vw_tllog_all.TXSTATUS IN ('1','7')
                     AND(CF.STATUS='A' OR (/*CF.STATUS <>'C' AND*/ INSTR(CF.pstatus,'A') <> 0))
                    and (cf.status like v_strstatus or cf.ACTIVESTS like v_strstatus)
                    AND CF.BRID like v_bgrid
                    AND CF.custodycd IS NOT NULL
                    and nvl(country,'234') <> '234'
                )
            )c
       ) CK_TOCHUC_NN,
       (SELECT a.amt + b.amt - c.amt FROM
            (
                SELECT count(*) amt FROM (
                    select DISTINCT cf.* from (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af
                    where cf.custid = af.custid
                        --and af.status = 'A'
                        ) cf WHERE STATUS = 'A'
                    AND cf.custtype = 'I'
                    AND cf.custodycd IS NOT NULL
                    and nvl(cf.country,'234') <> '234'
                    ----AND cf.custatcom = 'Y'
                    and cf.custatcom like V_STRCUSTATCOM
                    and (cf.status like v_strstatus or cf.ACTIVESTS like v_strstatus)
                    and CF.BRID like v_bgrid
            ) a,
            (
                SELECT count(*) amt FROM vw_tllog_all,VW_TLLOGFLD_ALL FLD, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf
                WHERE tltxcd = '0059' AND busdate > to_date(T_DATE,'dd/mm/rrrr')  AND deltd <> 'Y'
                    AND cf.custid = vw_tllog_all.msgacct AND cf.custtype = 'I'
                    ----AND cf.custatcom = 'Y'
                    and cf.custatcom like V_STRCUSTATCOM
                    AND vw_tllog_all.TXNUM=FLD.TXNUM
                    AND vw_tllog_all.TXDATE=FLD.TXDATE
                    AND FLD.FLDCD='08' AND FLD.CVALUE<>'N'
                    AND vw_tllog_all.TXSTATUS IN ('1','7')
                    and (cf.status like v_strstatus or cf.ACTIVESTS like v_strstatus)
                    AND CF.BRID like v_bgrid
                    AND CF.custodycd IS NOT NULL
                    and nvl(country,'234') <> '234'
            ) b,
            (
                SELECT count(*) amt FROM
                (
                    SELECT cf.custid FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf  WHERE cf.opndate >= to_date(T_DATE,'dd/mm/rrrr')
                        AND cf.custtype = 'I'
                        and (cf.status like v_strstatus or cf.ACTIVESTS like v_strstatus)
                        AND cf.custodycd IS NOT NULL
                        and nvl(cf.country,'234') <> '234'
                        AND(CF.STATUS='A' OR (/*CF.STATUS <>'C' AND*/ INSTR(CF.pstatus,'A') <> 0))
                        ---AND cf.custatcom = 'Y'
                        and cf.custatcom like V_STRCUSTATCOM
                        and CF.BRID like v_bgrid
                    union all
                    SELECT vw_tllog_all.msgacct FROM vw_tllog_all, cfmast cf,VW_TLLOGFLD_ALL FLD
                    WHERE tltxcd = '0067' AND busdate > to_date(T_DATE,'dd/mm/rrrr') AND deltd <> 'Y'
                        AND cf.custid = vw_tllog_all.msgacct AND cf.custtype = 'I'
                        ---AND cf.custatcom = 'Y'
                        and cf.custatcom like V_STRCUSTATCOM
                        AND vw_tllog_all.TXNUM=FLD.TXNUM
                        AND vw_tllog_all.TXDATE=FLD.TXDATE
                        AND FLD.FLDCD='08' AND FLD.CVALUE<>'N'
                        AND vw_tllog_all.TXSTATUS IN ('1','7')
                         AND(CF.STATUS='A' OR (/*CF.STATUS <>'C' AND*/ INSTR(CF.pstatus,'A') <> 0))
                        and (cf.status like v_strstatus or cf.ACTIVESTS like v_strstatus)
                        AND CF.BRID like v_bgrid
                        AND CF.custodycd IS NOT NULL
                        and nvl(country,'234') <> '234'
                )
            )c
       ) CK_CANHAN_NN
    FROM DUAL ;

EXCEPTION
   WHEN OTHERS
   THEN
    dbms_output.put_line(dbms_utility.format_error_backtrace);
      RETURN;
End;
 
/
