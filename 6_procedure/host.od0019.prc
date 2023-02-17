SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "OD0019" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_RECUSTID IN       VARCHAR2,
   PV_TLID        IN       VARCHAR2,
   PV_CFAFACCTNO  IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PV_AFACCTNO        IN       VARCHAR2,
   PV_VIA   IN       VARCHAR2,
   PV_CONFIRMED        IN       VARCHAR2
   )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
-- TONG HOP KET QUA KHOP LENH
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- NAMNT   21-NOV-06  CREATED
-- ---------   ------  -------------------------------------------
   V_STROPT          VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID            VARCHAR2 (100);               -- USED WHEN V_NUMOPTION > 0
    V_INBRID       VARCHAR2 (5);
   V_STRVIA             VARCHAR2 (10);
   V_STRTLID           VARCHAR2(6);
   v_strCustodycd      VARCHAR2(10);
   v_strAfacctno      VARCHAR2(10);
   v_strConfirmed     VARCHAR2(2);
   v_strRECustid   VARCHAR2(10);
   v_strCFAfacctno    VARCHAR2(10);

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN
  /* V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (BRID <> 'ALL')
   THEN
      V_STRBRID := BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;*/

  V_STROPT := upper(OPT);
    V_INBRID := pv_BRID;
    if(V_STROPT = 'A') then
        V_STRBRID := '%';
    else
        if(V_STROPT = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := pv_BRID;
        end if;
    end if;

    -- GET REPORT'S PARAMETERS
   IF (PV_TLID <> 'ALL')
   THEN
      V_STRTLID := PV_TLID;
   ELSE
      V_STRTLID := '%%';
   END IF;
   --
  IF (PV_CUSTODYCD <> 'ALL')
   THEN
      v_strCustodycd := PV_CUSTODYCD;
   ELSE
      v_strCustodycd := '%%';
   END IF;
   --
   IF (PV_afacctno <> 'ALL')
   THEN
      v_strAfacctno := PV_afacctno;
   ELSE
      v_strAfacctno := '%%';
   END IF;
   --
   IF (PV_CONFIRMED <> 'ALL')
   THEN
      v_strConfirmed := PV_CONFIRMED;
   ELSE
      v_strConfirmed := '%%';
   END IF;
   --
    IF (PV_RECUSTID <> 'ALL')
   THEN
      v_strRECustid := PV_RECUSTID;
   ELSE
      v_strRECustid := '%%';
   END IF;
   --
    IF (PV_CFAFACCTNO <> 'ALL')
   THEN
      v_strCFAfacctno := PV_CFAFACCTNO;
   ELSE
      v_strCFAfacctno := '%%';
   END IF;
   --
      IF (PV_VIA <> 'ALL')
   THEN
      v_strVIA := PV_VIA;
   ELSE
      v_strVIA := '%%';
   END IF;
   --- TINH GT KHOP MG

OPEN PV_REFCURSOR
 FOR
      SELECT mst.*,
      (CASE WHEN NVL(mst.userid,'a') <> 'a' THEN mst.userid || ' - ' || tl.tlfullname
          WHEN  NVL(mst.cfafacctno,'a') <> 'a' THEN mst.cfafacctno || ' - ' || cf.fullname
          ELSE  ''  END) confirmdesc

      FROM
          (SELECT OD.ORDERID,OD.CODEID, A0.CDCONTENT TRADEPLACE, A1.CDCONTENT EXECTYPE,
          OD.PRICETYPE, A3.CDCONTENT VIA, OD.ORDERQTTY,OD.QUOTEPRICE, OD.REFORDERID,
          se.symbol,a4.CDCONTENT CONFIRMED,od.afacctno, cf.custodycd, cf.fullname,
          cspks_odproc.fn_OD_GetRootOrderID(od.orderid) ROOTORDERID,
            od.txdate, od.txtime,re.refullname,tl.tlname tlid, CFMSTS.Userid,CFMSTS.custid cfafacctno,
           ( CASE WHEN od.via='O' THEN 'Y' ELSE nvl(CFMSTS.CONFIRMED,'N') END) CONFIRMEDVAL
          FROM CONFIRMODRSTS CFMSTS,
          (select * from ODMAST union all select * from odmasthist) OD, SBSECURITIES SE,
          ALLCODE A0, ALLCODE A1, ALLCODE A2, ALLCODE A3,aLLCODE A4,
          afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
              (select re.afacctno, MAX(cf.fullname) refullname,max(cf.custid) RECustid
                    from reaflnk re, sysvar sys, cfmast cf,RETYPE
                    where to_date(varvalue,'DD/MM/RRRR') between re.frdate and re.todate
                    and substr(re.reacctno,0,10) = cf.custid
                    and varname = 'CURRDATE' and grname = 'SYSTEM'
                    and re.status <> 'C' and re.deltd <> 'Y'
                    AND   substr(re.reacctno,11) = RETYPE.ACTYPE
                    AND  rerole IN ( 'RM','BM','AE')
                    GROUP BY AFACCTNO
                ) re,
                tlprofiles tl
          WHERE CFMSTS.ORDERID(+)=OD.ORDERID
          AND OD.CODEID=SE.CODEID
          AND a0.cdtype = 'OD' AND a0.cdname = 'TRADEPLACE' AND a0.cdval = se.tradeplace
          AND A1.cdtype = 'OD' AND A1.cdname = 'EXECTYPE'
          AND A1.cdval =(case when nvl(od.reforderid,'a') <>'a' and OD.EXECTYPE = 'NB' then 'AB'
          when  nvl(od.reforderid,'a') <>'a' and OD.EXECTYPE in ( 'NS','MS') then 'AS'
            else od.EXECTYPE end)
          AND A2.cdtype = 'OD' AND A2.cdname = 'PRICETYPE' AND A2.cdval = OD.PRICETYPE
          AND A3.cdtype = 'OD' AND A3.cdname = 'VIA' AND A3.cdval = OD.VIA
          AND a4.cdtype = 'SY' AND a4.cdname = 'YESNO'
          AND a4.cdval=(CASE WHEN od.via='O' THEN 'Y' ELSE nvl(CFMSTS.CONFIRMED,'N') END )
          and ( (od.exectype in ('NB','NS','MS') AND od.via in ('F','T','O')) or (od.exectype  not in ('NB','NS','MS')))
          and od.exectype not in ('AB','AS')
          and od.txdate >=to_date('01/01/2012','DD/MM/YYYY')
          and od.afacctno=af.acctno and af.custid=cf.custid
          AND re.afacctno=af.acctno
          AND nvl(CFMSTS.userid,'a') LIKE v_strtlid
          AND cf.custodycd LIKE v_strCustodycd
          AND af.acctno LIKE v_strAfacctno
          AND AF.ACTYPE NOT IN ('0000')
          AND re.recustid LIKE v_strRECustid
          AND NVL(CFMSTS.userid,'a') LIKE v_strTLID
          AND NVL(CFMSTS.CUSTID,'a') LIKE v_strCFAfacctno
          AND (CASE WHEN (nvl(od.reforderid,'a') = 'a' OR od.exectype IN ('CB','CS'))  THEN od.tlid
                    ELSE (SELECT tlid FROM (SELECT * FROM odmast UNION ALL SELECT * FROM odmasthist) od2
                           WHERE od2.orderid <> od.orderid AND od.reforderid= od2.reforderid ) END) = tl.tlid
          and od.txdate >=to_date(F_DATE,'DD/MM/YYYY')
          and od.txdate <=to_date(T_DATE,'DD/MM/YYYY')
          AND od.via LIKE V_STRVIA
          AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )
          ----
          ) mst, tlprofiles tl,
          cfmast cf

          WHERE mst.userid=tl.tlid(+)
          AND mst.cfafacctno=cf.custid(+)
          AND mst.CONFIRMEDVAL  LIKE v_strConfirmed
          ORDER BY TXDATE,mst.CUSTODYCD, AFACCTNO, TXTIME;


EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
