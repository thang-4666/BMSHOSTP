SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE se0029 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PV_SYMBOL      IN       VARCHAR2,
    PV_PLACE       IN        VARCHAR2,
   PV_TLID        IN       VARCHAR2
       )
IS

-- RP NAME : Danh sach nguoi so huu de nghi luu ky chung khoan
-- PERSON : QUYET.KIEU
-- DATE : 13/02/2011
-- COMMENTS : CREATE NEW
-- ---------   ------  -------------------------------------------

   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID          VARCHAR2 (40);        -- USED WHEN V_NUMOPTION > 0
   V_INBRID           VARCHAR2 (4);

   V_SYMBOL  VARCHAR2 (20);
   V_CUSTODYCD VARCHAR2 (15);
   V_STRTLID           VARCHAR2(40);
BEGIN
-- GET REPORT'S PARAMETERS
   V_STROPTION := upper(OPT);
   V_INBRID := PV_BRID;
   IF (V_STROPTION = 'A') AND (V_INBRID  = '0001')
   THEN
        V_STRBRID := '%';
   ELSE if V_STROPTION = 'B' then
        select brgrp.mapid into V_STRBRID from brgrp where brgrp.brid = V_INBRID;
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
          V_SYMBOL := REPLACE(trim(PV_SYMBOL),' ','_'); ---PV_SYMBOL;    --REPLACE(trim(PV_SYMBOL),' ','_');
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
 Select PV_PLACE PLACE,TB.* ,PV_BRID branchID from
(
SELECT
         nvl(A2.cdcontent ,'') san,
         nvl(cf.fullname,'') fullname,
         nvl(cf.custodycd,'') custodycd,
         nvl(cf.idcode ,'')idcode,
         nvl( cf.iddate ,'')iddate,
           (Case when A1.cdval='001' then '1'
               when A1.cdval='009' then '2'
              when A1.cdval='005' then '3'
           else '4' end
        ) IDTYPE ,
         nvl((CASE WHEN SB.REFCODEID IS NULL THEN sb.symbol ELSE SB1.SYMBOL END),'') codeid,
         nvl(iss.fullname,'') CK_Name,
         Sum(nvl(tl.msgamt,'')) So_luong,
         tl.type ,
         nvl(sb.PARVALUE,'') Menh_gia,
         nvl(PV_SYMBOL,'') PV_SYMBOL
  FROM (
       select tr.txdate, tr.afacctno acctno,
            tr.codeid codeid, tr.namt msgamt,
            (case when sb.refcodeid is null then (CASE WHEN tr.txcd = '0045' THEN '1' ELSE '2' END) else CASE WHEN tr.txcd = '0045' THEN '7' ELSE '8' END end  ) type
       from vw_setran_gen tr, sbsecurities sb
       where tr.tltxcd = '2293'
            AND tr.txcd IN ('0045','0043')
            and tr.codeid = sb.codeid
            AND tr.txdate >= TO_DATE (f_date, 'DD/MM/YYYY')
            AND tr.txdate <= TO_DATE (t_date, 'DD/MM/YYYY')
               AND TR.TLID LIKE V_STRTLID
 ) tl, afmast af,
         (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
         sbsecurities sb,
         sbsecurities sb1,
         issuers iss,
         ALLCODE A1,
         ALLCODE A2
 WHERE tl.acctno = af.acctno
         AND af.custid = cf.custid
        -- AND AF.ACTYPE NOT IN ('0000')
         AND tl.codeid = sb.codeid
         AND NVL(SB.REFCODEID, SB.CODEID) =  SB1.CODEID
         AND sb.tradeplace IN ('001', '002', '005','006')
         -----------------
         AND A1.CDTYPE = 'CF' AND A1.CDNAME = 'IDTYPE'
         AND A1.CDVAL = CF.IDTYPE
         AND iss.issuerid = sb.issuerid
         AND A2.CDTYPE = 'SE' AND A2.CDNAME = 'TRADEPLACE'
         and (case when sb.refcodeid is null then sb.tradeplace else sb1.tradeplace end) = A2.CDVAL
         --AND A2.CDVAL = sb.tradeplace
         --AND sb.tradeplace = A2.cdval
         AND Cf.CUSTODYCD LIKE V_CUSTODYCD
         and (af.brid like V_STRBRID or INSTR(V_STRBRID,af.brid) <> 0)
         AND sb.symbol like V_SYMBOL
        group by
        cf.fullname,
        cf.custodycd,
        cf.idcode,
        cf.iddate,
        A1.cdval,
        A2.cdcontent ,
        sb.symbol,
        iss.fullname,
        sb.PARVALUE,

        tl.type, nvl((CASE WHEN SB.REFCODEID IS NULL THEN sb.symbol ELSE SB1.SYMBOL END),''),
        PV_SYMBOL
 ) TB
      ;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
/
