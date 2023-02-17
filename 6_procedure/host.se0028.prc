SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE se0028 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PV_SYMBOL      IN       VARCHAR2,
   PV_PLACE       IN        VARCHAR2,
   PV_TLID        IN       VARCHAR2,
   PLSENT         in       varchar2
       )
IS


-- RP NAME : Danh sach nguoi so huu de nghi luu ky chung khoan
-- COMMENTS : CREATE NEW
-- ---------   ------  -------------------------------------------

   V_STROPTION        VARCHAR2 (10);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID          VARCHAR2 (40);        -- USED WHEN V_NUMOPTION > 0
   V_INBRID           VARCHAR2 (10);

   V_SYMBOL  VARCHAR2 (20);
   V_CUSTODYCD VARCHAR2 (15);
   V_STRTLID           VARCHAR2(40);
BEGIN
-- GET REPORT'S PARAMETERS

   V_STROPTION := upper(OPT);
   V_INBRID := pv_BRID;
   IF (V_STROPTION = 'A') AND (V_INBRID  = '0001')
   THEN
        V_STRBRID := '%';
   ELSE if V_STROPTION = 'B' then
        select brgrp.BRID into V_STRBRID from brgrp where brgrp.brid = V_INBRID;
        else
        V_STRBRID := V_INBRID;
        end if;
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


    if(PV_TLID is null or PV_TLID = 'ALL')then
        V_STRTLID := '%';
    else
        V_STRTLID := PV_TLID;
    end if;

-- GET REPORT'S DATA
 OPEN PV_REFCURSOR
 FOR
SELECT    PLSENT SENDTO,  PV_PLACE PLACE, T.*, pv_BRID branchID FROM
(
SELECT
         nvl(A2.cdcontent ,'') san,
         nvl(cf.fullname,'') fullname,
         nvl(cf.custodycd,'') custodycd,
         nvl(cf.idcode ,'')idcode,
         nvl(cf.iddate ,'')iddate,
          (Case when A1.cdval='001' then '1'
              when A1.cdval='009' then '2'
              when A1.cdval='005' then '3'
           else '4' end
         ) IDTYPE,
         nvl(sb.symbol,'') codeid,
         nvl(iss.fullname,'') CK_Name,
         Sum(nvl(tl.msgamt,'')) So_luong,
         nvl(sb.PARVALUE,'') Menh_gia,
         tl.type type, tl.securitiestype sectype,
         nvl(PV_SYMBOL,'') PV_SYMBOL
  FROM   (
                 SELECT  SE.txdate ,SE.afacctno acctno, sb.codeid  codeid , SE.withdraw  msgamt,
                    (case when sb.refcodeid is null then '1' else '7' end) TYPE,
                    (CASE WHEN sb.sectype IN ('001','002') THEN 'Co phieu'
                          WHEN sb.sectype IN ('003','006') THEN 'Trai phieu'
                          WHEN sb.sectype IN ('007','008') THEN 'Chung chi'
                          ELSE ' ' END) securitiestype
            From sewithdrawdtl SE , sbsecurities sb, vw_tllog_all TL
            where se.codeid=sb.codeid and se.txdate=tl.txdate and se.txnum=tl.txnum and tl.tltxcd='2200'
                AND se.txdate >= TO_DATE (f_date, 'DD/MM/YYYY')
                AND se.txdate <= TO_DATE (t_date, 'DD/MM/YYYY')      
                AND SE.withdraw > 0
                 and se.deltd<>'Y'
                AND TL.TLID LIKE V_STRTLID
            UNION ALL
            SELECT  SE.txdate ,SE.afacctno acctno , sb.codeid codeid , SE.blockwithdraw  msgamt ,
                    (case when sb.refcodeid is null then '2' else '8' end) TYPE,
                    (CASE WHEN sb.sectype IN ('001','002') THEN 'Co phieu'
                          WHEN sb.sectype IN ('003','006') THEN 'Trai phieu'
                          WHEN sb.sectype IN ('007','008') THEN 'Chung chi'
                          ELSE ' ' END) securitiestype
            From sewithdrawdtl SE, sbsecurities sb, vw_tllog_all TL
            where SE.codeid=sb.codeid and se.txdate=tl.txdate and se.txnum=tl.txnum and tl.tltxcd='2200'
                 AND se.txdate >= TO_DATE (f_date, 'DD/MM/YYYY')
                 AND se.txdate <= TO_DATE (t_date, 'DD/MM/YYYY')
                 AND SE.blockwithdraw > 0
                 and se.deltd<>'Y'
                 AND TL.TLID LIKE V_STRTLID
        ) tl, afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, sbsecurities sb, issuers iss, ALLCODE A1, ALLCODE A2,
            sbsecurities sb1
 WHERE       tl.acctno = af.acctno
         AND af.custid = cf.custid
         AND tl.CODEID = sb.codeid
         AND sb.tradeplace IN ('001', '002', '005','006')
         and sb.refcodeid = sb1.codeid (+)
         and (case when sb.refcodeid is null then sb.tradeplace else sb1.tradeplace end) = A2.CDVAL
         AND A1.CDTYPE = 'CF' AND A1.CDNAME = 'IDTYPE'
         AND A1.CDVAL = CF.IDTYPE
         AND iss.issuerid = sb.issuerid
         AND A2.CDTYPE = 'SE' AND A2.CDNAME = 'TRADEPLACE'
---         AND A2.CDVAL = sb.tradeplace
----         AND sb.tradeplace = A2.cdval
         AND Cf.CUSTODYCD LIKE V_CUSTODYCD
         AND sb.symbol    LIKE V_SYMBOL
        -- AND sb.tradeplace = PV_TRADEPLACE
        Group BY cf.fullname,cf.custodycd,cf.idcode ,cf.iddate ,A1.cdval,sb.symbol,iss.fullname,sb.PARVALUE,A2.cdcontent,
            tl.TYPE, tl.securitiestype
) T
 ;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
/
