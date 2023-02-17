SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE se0035 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   TRADEPLACE     IN       VARCHAR2,
   PV_SYMBOL      IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2

       )
IS

-- RP NAME : Danh sach nguoi so huu de nghi luu ky chung khoan 11B/LK
-- PERSON : QUYET.KIEU
-- DATE : 28/04/2011
-- COMMENTS : CREATE NEW
-- ---------   ------  -------------------------------------------
   V_SYMBOL  VARCHAR2 (20);
   V_CUSTODYCD VARCHAR2 (15);
   V_TRADEPLACE VARCHAR2 (15);
   V_INBRID        VARCHAR2(4);
   V_STRBRID      VARCHAR2 (50);
   V_STROPTION    VARCHAR2(5);

BEGIN
-- GET REPORT'S PARAMETERS
   V_STROPTION := upper(OPT);
   V_INBRID := pv_BRID;
    if(V_STROPTION = 'A') then
        V_STRBRID := '%%';
    else
        if(V_STROPTION = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
    end if;

   IF  (TRADEPLACE <> 'ALL')
   THEN
         V_TRADEPLACE := TRADEPLACE;
   ELSE
        V_TRADEPLACE := '%';
   END IF;


   IF  (PV_CUSTODYCD <> 'ALL')
   THEN
         V_CUSTODYCD := PV_CUSTODYCD;
   ELSE
        V_CUSTODYCD := '%';
   END IF;


   IF  (PV_SYMBOL <> 'ALL')
   THEN
        V_SYMBOL := REPLACE(trim(PV_SYMBOL),' ','_');
   ELSE
        V_SYMBOL := '%';
   END IF;

-- GET REPORT'S DATA
 OPEN PV_REFCURSOR
 FOR
 Select TB.* ,pv_BRID branchID from
(
SELECT
         nvl(A2.cdcontent ,'') san,
         nvl(cf.fullname,'') fullname,
         nvl(cf.custodycd,'') custodycd,
         nvl(cf.idcode ,'')idcode,
         nvl( cf.iddate ,'')iddate,
           (Case when A1.cdval='001' then '1'
              when A1.cdval='005' then '3'
           else '4' end
        ) IDTYPE ,
         nvl((case when sb.refcodeid is null then sb.symbol else sb1.symbol end),'') codeid,
         nvl(iss.fullname,'') CK_Name,
         Sum(nvl(tl.msgamt,'')) So_luong,
         nvl(tl.sectype,'') sectype,
         nvl(sb.PARVALUE,'') Menh_gia,
         nvl(PV_SYMBOL,'') PV_SYMBOL,
         V_TRADEPLACE V_TRADEPLACE ,
         V_CUSTODYCD V_CUSTODYCD,
         V_SYMBOL V_SYMBOL
  FROM   (
   SELECT mst.txdate, mst.afacctno acctno, mst.codeid, mst.withdraw msgamt,
        (case when sb.refcodeid is null then '1' else '7' end) sectype
        From sewithdrawdtl mst, sbsecurities sb
         where mst.status in ('A','C')
        /* mst.txdatetxnum in
        (Select msgacct from  tLlog
         WHERE       tltxcd = '2292'
        AND txdate >= TO_DATE (f_date, 'DD/MM/YYYY')
         AND txdate <= TO_DATE (t_date, 'DD/MM/YYYY')
        Union all
        Select msgacct from  tLlogALl
         WHERE       tltxcd = '2292'
         AND txdate >= TO_DATE (f_date, 'DD/MM/YYYY')
         AND txdate <= TO_DATE (t_date, 'DD/MM/YYYY')
        )*/ 
        and mst.codeid = sb.codeid and  mst.withdraw > 0
    union all
       SELECT mst.txdate, mst.afacctno acctno, mst.codeid, mst.blockwithdraw msgamt,
       (case when sb.refcodeid is null then '2' else '8' end) sectype
        From sewithdrawdtl mst, sbsecurities sb
        where mst.status in ('A','C')
        /* mst.txdatetxnum in
        (Select msgacct from  tLlog
         WHERE       tltxcd = '2292'
        AND txdate >= TO_DATE (f_date, 'DD/MM/YYYY')
         AND txdate <= TO_DATE (t_date, 'DD/MM/YYYY')
        Union all
        Select msgacct from  tLlogALl
         WHERE       tltxcd = '2292'
         AND txdate >= TO_DATE (f_date, 'DD/MM/YYYY')
         AND txdate <= TO_DATE (t_date, 'DD/MM/YYYY')
        )*/ 
        and mst.codeid = sb.codeid and mst.blockwithdraw > 0
 ) tl, afmast af,
          (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0)  cf,
         sbsecurities sb,
         sbsecurities sb1,
         issuers iss,
         ALLCODE A1,
         ALLCODE A2
 WHERE       tl.acctno = af.acctno
         AND af.custid = cf.custid
         AND AF.ACTYPE NOT IN ('0000')
         AND tl.codeid = sb.codeid
         and nvl(sb.refcodeid, sb.codeid) = sb1.codeid
         AND sb.tradeplace IN ('001', '002', '005','006')
         -----------------
         AND A1.CDTYPE = 'CF' AND A1.CDNAME = 'IDTYPE'
         AND A1.CDVAL = CF.IDTYPE
         AND iss.issuerid = sb.issuerid
         AND A2.CDTYPE = 'SE' AND A2.CDNAME = 'TRADEPLACE'
         AND A2.CDVAL = sb.tradeplace
         AND sb.tradeplace = A2.cdval
         AND Cf.CUSTODYCD LIKE V_CUSTODYCD
         AND sb.symbol LIKE V_SYMBOL
         AND sb.tradeplace like V_TRADEPLACE
         AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )
         --AND sb.tradeplace = PV_TRADEPLACE
        group by

        cf.fullname,
        cf.custodycd,
        cf.idcode,
        cf.iddate,
        A1.cdval,
        A2.cdcontent ,
        (case when sb.refcodeid is null then sb.symbol else sb1.symbol end),
        iss.fullname,
        sb.PARVALUE,
        PV_SYMBOL,
        nvl(tl.sectype,'')
 ) TB
      ;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
/
