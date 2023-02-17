SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF0022" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2

)
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- HUYNQ        CREATED
-- ---------   ------  -------------------------------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID          VARCHAR2 (4);              -- USED WHEN V_NUMOPTION > 0

   v_text varchar2(1000);
-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN
-- insert into temp_bug(text) values('CF0001');commit;
   V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (PV_BRID <> 'ALL')
   THEN
      V_STRBRID := PV_BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;

   -- GET REPORT'S PARAMETERS



   -- END OF GETTING REPORT'S PARAMETERS
   -- GET REPORT'S DATA
 --  IF (V_STROPTION <> 'A') AND (BRID <> 'ALL')
 -- THEN
      OPEN PV_REFCURSOR
       FOR
         select afm.clsdate,CF.custodycd,CF.idcode,CF.address,afm.opndate ,
        CF.fullname,CF.iddate,CF.idplace,CF.CUSTTYPE,CF.custodycd,CTRY.CDCONTENT COUNTRY
        from (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf ,

        (select af.custid, mst.clsdate ,mst.opndate from
               (select custid ,count(*)cnt from afmast group by custid) af,
                       (
                         select custid ,count(*) cnt,max(clsdate) clsdate ,min(opndate)opndate
                         from afmast where status='C'
                         group by custid
                       ) mst
        where af.custid = mst.custid
        /*and af.cnt=mst.cnt*/) afm, allcode ctry

        where afm.custid = cf.custid
        AND      CF.custodycd IS NOT NULL
        AND      CTRY.CDTYPE='CF'
        AND      CTRY.CDNAME='COUNTRY'
        and      ctry.cdval = cf.country
       AND      afm.clsdate >= TO_DATE (F_DATE, 'DD/MM/YYYY')
       AND      afm.clsdate <= TO_DATE (T_DATE, 'DD/MM/YYYY')
        AND      SUBSTR(CF.CUSTID,1,4)  LIKE  V_STRBRID;



--           v_text:='1 ';

 -- ELSE
 /*
             OPEN PV_REFCURSOR
            FOR

               select afm.clsdate,CF.custodycd,CF.idcode,CF.address,afm.opndate,
       CF.fullname,CF.iddate,CF.idplace,CF.CUSTTYPE,CF.custodycd,CTRY.CDCONTENT COUNTRY
       from cfmast cf ,

                    (select af.custid, mst.clsdate,mst.opndate  from
                    (select custid ,count(*)cnt from afmast group by custid) af,
                (
                         select custid ,count(*) cnt,max(clsdate) clsdate,min(opndate)opndate
                         from afmast where status='C'
                         group by custid
                 ) mst
            where af.custid = mst.custid and af.cnt=mst.cnt) afm, allcode ctry  -- like above

        where afm.custid = cf.custid
        AND      CF.custodycd IS NOT NULL
        AND      CTRY.CDTYPE='CF'
        AND      CTRY.CDNAME='COUNTRY'
        and      ctry.cdval = cf.country
    AND      afm.clsdate >= TO_DATE (F_DATE, 'DD/MM/YYYY')
       AND      afm.clsdate <= TO_DATE (T_DATE, 'DD/MM/YYYY')
        AND      SUBSTR(CF.CUSTID,1,4)  LIKE  V_STRBRID;


 --           v_text:='2 ';
   END IF;
*/
 EXCEPTION
   WHEN OTHERS
   THEN
    --insert into temp_bug(text) values('CF0001');commit;
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
