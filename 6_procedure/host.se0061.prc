SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE se0061 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD       IN       VARCHAR2, --CUSTODYCD
   PV_AFACCTNO         IN       VARCHAR2,
   PV_SECTYPE         IN       VARCHAR2,
   TLID           IN       VARCHAR2
   )
IS
--Phieu tinh phi luu ky
--created by CHaunh at 06/06/2012

-- ---------   ------  -------------------------------------------

   V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID      VARCHAR2 (40);            -- USED WHEN V_NUMOPTION > 0
   V_INBRID     VARCHAR2 (5);            -- USED WHEN V_NUMOPTION > 0
   V_STRCUSTODYCD  VARCHAR2 (20);
   V_STRAFACCTNO               VARCHAR2(20);
   V_STRSECTYPE         varchar2(10);
   v_FrDate                DATE;
   V_ToDate                 DATE;
   V_TLID       VARCHAR2(10);


BEGIN
   V_STROPTION := upper(OPT);
   V_INBRID := PV_BRID;
   V_TLID:=TLID;

   if(V_STROPTION = 'A') then
        V_STRBRID := '%';
    else
        if(V_STROPTION = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := PV_BRID;
        end if;
    end if;

   v_FrDate := to_date(F_DATE,'DD/MM/RRRR');
   v_ToDate   := to_date(T_DATE,'DD/MM/RRRR')+1;

   IF(PV_CUSTODYCD = 'ALL' or PV_CUSTODYCD is null )
   THEN
        V_STRCUSTODYCD := '%';
   ELSE
        V_STRCUSTODYCD := PV_CUSTODYCD;
   END IF;

   IF(PV_AFACCTNO = 'ALL' OR PV_AFACCTNO IS NULL)
    THEN
       V_STRAFACCTNO := '%';
   ELSE
       V_STRAFACCTNO := PV_AFACCTNO;
   END IF;

   IF(PV_SECTYPE <> 'ALL')
   THEN        V_STRSECTYPE  := PV_SECTYPE;
   ELSE        V_STRSECTYPE  := '%';
   END IF;

OPEN PV_REFCURSOR
FOR
SELECT  V_STRCUSTODYCD HD_custodycd, V_STRAFACCTNO HD_afacctno, V_STRSECTYPE HD_sectype,
        a.afacctno, a.from_date, a.to_date, a.sectype, a.fullname, a.custodycd, a.qtty, a.amt,
        round(a.amt/ (a.qtty*(a.to_date - a.from_date)),4)*30 muc_phi

FROM (
     select af.acctno afacctno,  --txdate,
        CASE WHEN txdate < v_FrDate and txdate + days > v_FrDate THEN v_FrDate
             ELSE txdate END from_date,
        CASE WHEN txdate = v_ToDate THEN v_ToDate + 1
             WHEN txdate <> v_ToDate AND txdate + days >=  v_ToDate THEN v_ToDate
            ELSE txdate + days END to_date,
        --days,
       CASE WHEN sb.sectype IN ('003' ,'006' ,'222','012') THEN 'TP'
            WHEN sb.sectype IN ('001', '002',  '008') THEN 'CP & CCQ'
            WHEN sb.sectype IN ('011') THEN 'CW'
              END sectype, --Ngay 23/03/2017 CW NamTv chinh sua them sectype 011
            cf.fullname, cf.custodycd, nvl(sum( case when depo.amt =0 then 0 else  depo.qtty end ),0) qtty,
            nvl(round(sum(case  when v_FrDate = v_ToDate then depo.amt/depo.days
                           /*WHEN v_ToDate - v_FrDate < days AND depo.txdate+de
                                THEN (v_ToDate - v_FrDate)/depo.days * depo.amt*/
                           ELSE (CASE when depo.txdate = v_ToDate then depo.amt/depo.days
                                when depo.txdate + depo.days > v_ToDate and txdate < v_ToDate then (v_ToDate - depo.txdate)/depo.days * depo.amt
                                when depo.txdate < v_FrDate and depo.txdate + days > v_FrDate then (depo.txdate + depo.days - v_FrDate)* depo.amt/depo.days
                                else depo.amt end)
                        END ),4),0) amt
    from sedepobal depo,   (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af, sbsecurities sb
    where  cf.custid = af.custid and af.acctno = substr(depo.acctno,1,10)
    AND depo.deltd <> 'Y'
    and cf.custodycd like V_STRCUSTODYCD
    and af.acctno like V_STRAFACCTNO
    --AND (substr(cf.custid,1,4) LIKE V_STRBRID OR instr(V_STRBRID,substr(cf.custid,1,4))<> 0)
    and depo.days <> 0
    AND sb.codeid = substr(depo.acctno, 11, 6)
    and depo.txdate + days > v_FrDate and depo.txdate < v_ToDate
    AND (CF.brid LIKE V_STRBRID or instr(V_STRBRID,CF.brid) <> 0 )
    AND depo.amt <> 0
    AND AF.ACTYPE NOT IN ('0000')
    group by af.acctno, CASE WHEN txdate < v_FrDate and txdate + days > v_FrDate THEN v_FrDate
             ELSE txdate END,
             CASE WHEN txdate = v_ToDate THEN v_ToDate + 1
             WHEN txdate <> v_ToDate AND txdate + days >= v_ToDate THEN v_ToDate
            ELSE txdate + days END,
            CASE WHEN sb.sectype IN ('003' ,'006' ,'222','012') THEN 'TP'
            WHEN sb.sectype IN ('001', '002',  '008') THEN 'CP & CCQ'
            WHEN sb.sectype IN ('011') THEN 'CW' END --Ngay 23/03/2017 CW NamTv chinh sua them sectype 011
            , cf.fullname, cf.custodycd
    )a
WHERE a.sectype LIKE V_STRSECTYPE
ORDER BY a.from_date, a.to_date
    ;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
-- PROCEDURE
 
/
