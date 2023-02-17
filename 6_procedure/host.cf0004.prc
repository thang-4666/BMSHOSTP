SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF0004" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   BRGID          IN       VARCHAR2,
   BRANCH         IN       varchar2,
   STATUS         IN       varchar2
 )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE       COMMENTS
-- Diennt      28/12/2011 Create
-- ---------   ------     -------------------------------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRGID           VARCHAR2 (10);
   V_branch  varchar2(5);
   V_INBRID        VARCHAR2(4);
   V_STRBRID      VARCHAR2 (50);
   V_STRSTATUS    VARCHAR2 (10);

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE

BEGIN
-- INSERT INTO TEMP_BUG(TEXT) VALUES('CF0001');COMMIT;
/*   V_STROPTION := OPT;

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
            select br.brid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
    end if;

   IF (BRGID  <> 'ALL')
   THEN
      V_STRBRGID  := BRGID;
   ELSE
      V_STRBRGID := '%%';
   END IF;

   IF (STATUS IS NULL OR UPPER(STATUS)  = 'ALL')
   THEN
      V_STRSTATUS  := '%';
   ELSE
      V_STRSTATUS := UPPER(STATUS);
   END IF;

   v_branch:=BRANCH;

OPEN PV_REFCURSOR
  FOR
select distinct cf.BRG, cf.BRAN, cf.fullname, cf.idcode, cf.iddate, cf.idplace, cf.custodycd, cf.address,cf.cfclsdate,
       cf.LOAI_DKSH, cf.CLOSE_OPEN, cf.LOAI_HINH, cf.country,
       CF.OFFNAME, CF.OFFDATE, CF.offtime, CF.TLNAME, CF.TLDATE, CF.TLtime
from
(
(
  SELECT BRGID BRG, v_branch BRAN,cf.fullname, cf.idcode, cf.iddate, cf.idplace, cf.custodycd, cf.address,cf.cfclsdate,
       case when cf.idtype='001' then '1'
            when cf.idtype='002' then '2'
            when cf.idtype='003' then '3'
            when cf.idtype='005' then '5'
            else '4' end LOAI_DKSH,
       '1' CLOSE_OPEN,
       --case when status='A' then '1' else'0' end CLOSE_OPEN,
      -- case when substr(cf.custodycd,4,1) in ('C','P') and cf.custtype='I' then '1'
         --   when substr(cf.custodycd,4,1)='F' and cf.custtype='I' then '2'
        --    when substr(cf.custodycd,4,1)in ('C','P') and cf.custtype='B' then '3'
         --   when substr(cf.custodycd,4,1)='F' and cf.custtype='B' then '4'
         --    else '' end LOAI_HINH,
             case when cf.custtype = 'I' then 'CN' else 'TC' end LOAI_HINH,
       al.cdcontent country, TR.OFFNAME, TR.OFFDATE, TR.offtime,
       TR.TLNAME, TR.TLDATE, TR.TLtime
FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, allcode al,
    (
SELECT DISTINCT substr(TL.record_key,11,10) CUSTID, TL.to_value custodycd,  nvl(TLP2.tlname,'') OFFNAME, TL.approve_dt OFFDATE, TL.approve_time offtime,
       nvl(TLP1.tlname,'') TLNAME, TL.maker_dt TLDATE, TL.maker_time TLtime
FROM maintain_log TL, tlprofiles TLP1, tlprofiles TLP2
WHERE TL.TABLE_NAME = 'CFMAST' AND TL.action_flag = 'ADD'
    AND TL.child_table_name IS NULL AND TL.column_name = 'CUSTODYCD'
    AND TL.maker_id = TLP1.tlid(+) AND TL.approve_id = TLP2.tlid(+)
) TR
WHERE cf.country = al.cdval and al.cdname='COUNTRY'
    and cf.custodycd is not NULL
    AND cf.custatcom = 'Y'
    and cf.status like V_STRSTATUS
    AND CF.CUSTID = TR.CUSTID(+)
    AND CF.custodycd = TR.custodycd(+)
    and cf.opndate >=TO_DATE(F_DATE,'dd/mm/yyyy')
    and cf.opndate<=TO_DATE(T_DATE,'dd/mm/yyyy')
    ---AND cf.brid LIKE V_STRBRID
    AND (cf.brid LIKE V_STRBRGID or instr(V_STRBRGID,cf.brid) <> 0 )
    /*AND CF.activests LIKE V_STRSTATUS */AND CF.STATUS LIKE V_STRSTATUS
UNION
SELECT BRGID BRG, v_branch BRAN,cf.fullname, cf.idcode, cf.iddate, cf.idplace, cf.custodycd, cf.address,cf.cfclsdate,
       case when cf.idtype='001' then '1'
            when cf.idtype='002' then '2'
            when cf.idtype='003' then '3'
            when cf.idtype='005' then '5'
            else '4' end LOAI_DKSH,
       CASE WHEN log.tltxcd = '0059' THEN '0'
            ELSE '1' END  CLOSE_OPEN,
       --case when substr(cf.custodycd,4,1) in ('C','P') and cf.custtype='I' then '1'
        --    when substr(cf.custodycd,4,1)='F' and cf.custtype='I' then '2'
        --    when substr(cf.custodycd,4,1)in ('C','P') and cf.custtype='B' then '3'
         --   when substr(cf.custodycd,4,1)='F' and cf.custtype='B' then '4'
         --   else '' end LOAI_HINH,
            case when cf.custtype = 'I' then 'CN' else 'TC' end LOAI_HINH,
       al.cdcontent country, nvl(TLP.tlname,'') OFFNAME, LOG.TXDATE OFFDATE, LOG.offtime offtime,
       nvl(TLP2.tlname,'') TLNAME, LOG.TXDATE TLDATE, LOG.txtime TLtime
FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, allcode al,
VW_TLLOGFLD_ALL FLD, vw_tllog_all log
LEFT JOIN tlprofiles TLP
    ON LOG.offid = TLP.tlid
LEFT JOIN tlprofiles TLP2
    ON LOG.tlid = TLP2.tlid
WHERE log.msgacct = cf.custid AND log.tltxcd IN ('0059','0067') AND log.deltd <> 'Y'
    AND LOG.TXDATE=FLD.TXDATE
    AND LOG.TXNUM=FLD.TXNUM
    AND LOG.TXSTATUS IN ('1','7')
    AND FLD.FLDCD='08' --AND FLD.CVALUE<>'N'
    and cf.country = al.cdval and al.cdname='COUNTRY'
    and cf.custodycd is not NULL
    AND cf.custatcom = 'Y'
    and cf.status like V_STRSTATUS
    and log.txdate >=TO_DATE(F_DATE,'dd/mm/yyyy')
    and log.txdate <=TO_DATE(T_DATE,'dd/mm/yyyy')
    AND (cf.brid LIKE V_STRBRGID or instr(V_STRBRGID,cf.brid) <> 0 )
    ----AND cf.brid LIKE V_STRBRID ---or instr(V_STRBRID,cf.brid) <> 0 )
)
/*union
(
SELECT BRGID BRG, v_branch BRAN,cf.fullname, cf.idcode, cf.iddate, cf.idplace, cf.custodycd, cf.address,
       case when cf.idtype='001' then '1'
            when cf.idtype='002' then '2'
            when cf.idtype='003' then '3'
            when cf.idtype='005' then '5'
            else '4' end LOAI_DKSH,
       CASE WHEN log.tltxcd = '0059' THEN '0'
            ELSE '1' END  CLOSE_OPEN,
       case when substr(cf.custodycd,4,1) in ('C','P') and cf.custtype='I' then '1'
            when substr(cf.custodycd,4,1)='F' and cf.custtype='I' then '2'
            when substr(cf.custodycd,4,1)in ('C','P') and cf.custtype='B' then '3'
            when substr(cf.custodycd,4,1)='F' and cf.custtype='B' then '4'
             else '' end LOAI_HINH,
       al.cdcontent country, TLP.tlname OFFNAME, LOG.TXDATE OFFDATE, LOG.offtime offtime,
       TLP2.tlname TLNAME, LOG.TXDATE TLDATE, LOG.txtime TLtime
FROM cfmast cf ,allcode al, vw_tllog_all log
LEFT JOIN tlprofiles TLP
    ON LOG.offid = TLP.tlid
    LEFT JOIN tlprofiles TLP2
    ON LOG.tlid = TLP2.tlid
WHERE log.msgacct = cf.custid AND log.tltxcd IN  ('0059','0067') AND log.deltd <> 'Y'
    and cf.country = al.cdval and al.cdname='COUNTRY'
    and cf.custodycd is not NULL
    AND cf.custatcom = 'Y'
    and cf.ACTIVESTS like V_STRSTATUS
---    and substr(cf.custid,1,4)  like V_STRBRGID
    and log.txdate >=TO_DATE(F_DATE,'dd/mm/yyyy')
    and log.txdate <=TO_DATE(T_DATE,'dd/mm/yyyy')
    AND cf.brid LIKE V_STRBRID ---- or instr(V_STRBRID,cf.brid) <> 0 )
)*/
) cf
;

EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;
 
/
