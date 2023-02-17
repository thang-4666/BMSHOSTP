SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF0005" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   TLID            IN       VARCHAR2
 )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE       COMMENTS
-- Diennt      13/10/2011 Create
-- ---------   ------     -------------------------------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
       -- USED WHEN V_NUMOPTION > 0
   V_INBRID        VARCHAR2(4);
   V_STRBRID      VARCHAR2 (50);
   V_STRTLID           VARCHAR2(6);

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
 V_STRTLID:= TLID;
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

OPEN PV_REFCURSOR
  FOR
SELECT v.custid, cf.fullname, cf.custodycd, v.confirmtxdate maker_dt, cf.address,
      CASE WHEN  v.nidcode IS NULL THEN  ' ' ELSE  v.oidcode END  from_idcode, v.nidcode to_idcode,
             CASE WHEN  v.niddate IS NULL THEN  ' ' ELSE  to_char(v.oiddate,'dd/MM/yyyy') END   from_iddate, v.niddate to_iddate,
              CASE WHEN  v.nidplace IS NULL THEN  ' ' ELSE  v.oidplace END  from_idplace, v.nidplace to_idplace,
             CASE WHEN  v.naddress IS NULL THEN  ' ' ELSE  v.oaddress END   from_address, v.naddress to_address,
         v.ofullname  from_fullname, v.nfullname to_fullname,
       ( CASE WHEN  v.ncountry IS NULL THEN  ''
          WHEN  v.ncountry= v.ocountry then '' ELSE  v.ocountry END )from_country,
         (case when  v.ncountry= v.ocountry then '' ELSE v.ncountry end) to_country
FROM cfvsdlog v, cfmast cf, vw_tllog_all tl, allcode a
WHERE v.custid = cf.custid
AND tl.txdate = v.txdate AND tl.txnum = v.txnum
AND cf.country = a.cdval AND a.cdname = 'COUNTRY' AND a.cdtype = 'CF'
AND v.confirmtxnum IS NOT NULL
AND v.confirmtxdate BETWEEN to_Date(F_DATE,'DD/MM/RRRR') AND to_date(T_DATE,'DD/MM/RRRR')
 AND (NVL(ocusttype,'-')<> NVL(ncusttype,ocusttype) OR NVL(ocountry,'-')<> NVL(ncountry,ocountry) OR NVL(otradingcodedt,to_date('01/01/9000','DD/MM/YYYY'))<> NVL(ntradingcodedt,otradingcodedt)
 OR NVL( otradingcode,'-') <> NVL( ntradingcode,otradingcode)
OR NVL( oidplace,'-')<> NVL(nidplace,oidplace) OR NVL(oidexpired,to_date('01/01/9000','DD/MM/YYYY')) <> NVL(oidexpired,oidexpired)
OR NVL(Oidcode,'-') <> NVL(NIdcode,Oidcode) OR  NVL(oiddate,to_date('01/01/9000','DD/MM/YYYY')) <> NVL(niddate,oiddate) OR NVL(oaddress,'-') <>NVL(naddress,oaddress) )

ORDER BY v.txdate, cf.custodycd
/*SELECT DISTINCT a.CUSTID, a.fullname, a.custodycd, a.MAKER_DT,A.ADDRESS,
    a.FROM_IDCODE,
    a.TO_IDCODE,
    a.FROM_IDDATE,
    a.TO_IDDATE,
    a.FROM_IDPLACE,
    a.TO_IDPLACE,
    a.TO_ADDRESS,
    a.FROM_COUNTRY,
       a.TO_COUNTRY, a.FROM_POSITION,
       a.TO_POSITION,
       a.FROM_FULLNAME, a.TO_FULLNAME
    ,CASE WHEN NVL(b.confirmtxdate,to_date('01/01/1900','DD/MM/RRRR')) <> TO_DATE('01/01/1900','DD/MM/RRRR') THEN 'Y' ELSE 'N' END  confirmVSD
FROM
(
  SELECT CF.CUSTID, cf.fullname, cf.custodycd, tl.MAKER_DT,CF.ADDRESS,
    (case when tl.FROM_IDCODE is null then cf.idcode else tl.FROM_IDCODE end) FROM_IDCODE,
    tl.TO_IDCODE,
    (case when tl.FROM_IDDATE is null then to_char(cf.iddate,'dd/mm/rrrr') else tl.FROM_IDDATE end) FROM_IDDATE,
    tl.TO_IDDATE,
    case when tl.FROM_IDPLACE is null then cf.IDPLACE else tl.FROM_IDPLACE end FROM_IDPLACE,
    tl.TO_IDPLACE,
    case when tl.FROM_ADDRESS is null then cf.ADDRESS else tl.FROM_ADDRESS end FROM_ADDRESS, tl.TO_ADDRESS,
    case when tl.FROM_COUNTRY is null then a1.cdcontent else tl.FROM_COUNTRY end FROM_COUNTRY,
       tl.TO_COUNTRY, (CASE WHEN TL.FROM_BUSINESSTYPE='006' then TL.FROM_POSITION else '' end) FROM_POSITION,
       (CASE WHEN TL.TO_BUSINESSTYPE = '006' then TL.FROM_POSITION else '' end) TO_POSITION,
       case when TL.FROM_FULLNAME is null then cf.FULLNAME else TL.FROM_FULLNAME end FROM_FULLNAME, TO_FULLNAME
    FROM
    (
     select record_key,maker_dt,maker_time,
        max(case when  column_name = 'IDCODE' then from_value else '' end ) FROM_IDCODE,
        max(case when column_name = 'IDCODE' then to_value else '' end ) TO_IDCODE,
        max(case when column_name = 'IDDATE' then from_value else '' end ) FROM_IDDATE,
        max(case when column_name = 'IDDATE' then to_value else '' end ) TO_IDDATE,
        max(case when column_name = 'IDPLACE' then from_value else '' end ) FROM_IDPLACE,
        max(case when column_name = 'IDPLACE' then to_value else '' end ) TO_IDPLACE,
        max(case when column_name = 'ADDRESS' then from_value else '' end ) FROM_ADDRESS,
        max(case when column_name = 'ADDRESS' then to_value else '' end ) TO_ADDRESS,
        max(case when column_name = 'COUNTRY' then nvl(a1.cdcontent,'') else '' end ) FROM_COUNTRY,
        max(case when column_name = 'COUNTRY' then nvl(a2.cdcontent,'') else '' end ) TO_COUNTRY,
        max(case when column_name = 'POSITION' then nvl(a3.cdcontent,'') else '' end ) FROM_POSITION,
        max(case when column_name = 'POSITION' then nvl(a4.cdcontent,'') else '' end ) TO_POSITION,
        max(case when column_name = 'BUSINESSTYPE' then from_value else '' end ) FROM_BUSINESSTYPE,
        max(case when column_name = 'BUSINESSTYPE' then to_value else '' end ) TO_BUSINESSTYPE,
        max(case when column_name = 'FULLNAME' then from_value else '' end ) FROM_FULLNAME,
        max(case when column_name = 'FULLNAME' then to_value else '' end ) TO_FULLNAME
    from maintain_log
        left join allcode a1 on from_value = a1.cdval and a1.cdname ='COUNTRY' and a1.cdtype='CF'
        left join allcode a2 on to_value = a2.cdval and a2.cdname ='COUNTRY' and a2.cdtype='CF'
        left join allcode a3 on from_value = a3.cdval and a3.cdname ='COUNTRY' and a3.cdtype='CF'
        left join allcode a4 on to_value = a4.cdval and a4.cdname ='COUNTRY' and a4.cdtype='CF'
    where table_name ='CFMAST'
        and column_name in ('FULLNAME','IDCODE','IDDATE','IDPLACE','ADDRESS','COUNTRY','POSITION','BUSINESSTYPE')
        AND action_flag='EDIT'
    group by record_key,maker_dt, maker_time
    ) tl,(SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, V_INBRID, TLGOUPS)=0) cf left join allcode a1 on cf.COUNTRY = a1.cdval and a1.cdname ='COUNTRY' and a1.cdtype='CF'
    WHERE
        cf.custid=substr(trim(TL.record_key),11,10)
    and tl.maker_dt <= to_date(T_DATE,'DD/MM/YYYY' )
    AND tl.maker_dt >= to_date(F_DATE,'DD/MM/YYYY' )

) A , cfvsdlog b
where
    A.CUSTID = b.CUSTID
        AND b.confirmtxnum is NOT NULL
and a.maker_dt = b.txdate*/
;

EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;
 
 
 
 
/
