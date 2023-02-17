SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE od0006 (
   pv_refcursor   IN OUT   pkg_report.ref_cursor,
   opt            IN       VARCHAR2,
   pv_brid           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   I_BRID         IN       VARCHAR2,
   TRADEPLACE     IN       VARCHAR2,
   PV_SECTYPE     IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2
)
IS
--
-- Purpose: Briefly explain the functionality of the procedure
--

-- MODIFICATION HISTORY
-- Person      Date    Comments
-- NAMNT   21-Nov-06  Created
-- ---------   ------  -------------------------------------------
   v_stroption      VARCHAR2 (5);          -- A: All; B: Branch; S: Sub-branch
   v_strbrid        VARCHAR2 (4);                 -- Used when v_numOption > 0

   V_FROM_DATE      date;
   V_TO_DATE        date;
   V_INBRID         VARCHAR2(10);
   V_TRADEPLACE     VARCHAR2(10);
   V_STRSECTYPE     VARCHAR2(10);
   V_STRCUSTODYCD     VARCHAR2(10);
-- Declare program variables as shown above
BEGIN
   v_stroption := opt;

   IF (v_stroption <> 'A') AND (pv_brid <> 'ALL')
   THEN
      v_strbrid := pv_brid;
   ELSE
      v_strbrid := '%%';
   END IF;

    V_FROM_DATE := to_date(F_DATE,'dd/mm/rrrr');
    V_TO_DATE   := to_date(T_DATE,'dd/mm/rrrr');

    if(I_BRID is null or upper(I_BRID) = 'ALL') then
        V_INBRID := '%';
    else
        V_INBRID := I_BRID;
    end if;

    if(TRADEPLACE is null or upper(TRADEPLACE) = 'ALL') then
        V_TRADEPLACE := '%';
    else
        V_TRADEPLACE := TRADEPLACE;
    end if;

    if(PV_SECTYPE is null or upper(PV_SECTYPE) = 'ALL') then
        V_STRSECTYPE := '%';
    else
        V_STRSECTYPE := PV_SECTYPE;
    end if;

    if(PV_CUSTODYCD is null or upper(PV_CUSTODYCD) = 'ALL') then
        V_STRCUSTODYCD := '%';
    else
        V_STRCUSTODYCD := PV_CUSTODYCD;
    end if;

OPEN pv_refcursor
  FOR
SELECT IO.TXDATE, PV_SECTYPE INSECTYPE, V_TRADEPLACE INTRADEPLACE, V_INBRID INBRID,
    (case when SB.sectype in ('006','003') then '002' else '001' end) sectype,
    COUNT(DISTINCT io.orgorderid) N_COUNT,
    SUM(CASE WHEN IO.bors = 'B' THEN IO.matchqtty ELSE 0 END) matchqtty_B,
    SUM(CASE WHEN IO.bors = 'S' THEN IO.matchqtty ELSE 0 END) matchqtty_S,
    SUM(CASE WHEN IO.bors = 'B' THEN  case when nvl(bon.leg,'N') = 'N' then   IO.matchqtty*IO.matchprice else bon.amt1 end ELSE 0 END) matchAMT_B,
    SUM(CASE WHEN IO.bors = 'S' THEN case when nvl(bon.leg,'N') = 'N' then   IO.matchqtty*IO.matchprice else bon.amt1 end ELSE 0 END) matchAMT_S,

    (NVL(RE.typegr,'')) typegr,io.tradeplace,
    (case when nvl(bon.LEG,'A') = 'A' then
    (case when io.tradeplace = '005' then 0.02 ---UPCOM
        when sb.sectype in ('008','011') then 0.02 --- ETF: CCQ --Ngay 23/03/2017 CW NamTv chinh sua them sectype 011
        when sb.sectype in ('006','003') then 0.0075 --- Trai phieu
        when sb.sectype in ('001','002','007') then 0.03 --- Co Phieu,
        else 0 end)
    else nvl(bon.feerate,0) ---repo
    end) ferate
FROM vw_iod_tradeplace_all IO, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, sbsecurities SB,
    (select  custodycd , max(typegr) typegr
    from vw_gl_regr_od0006
    where getcurrdate BETWEEN re_frdate and re_todate
    group by custodycd ) re, (SELECT ORDERID, REPOACCTNO, TXDATE, QTTY, AMT1,FEEAMT, LEG, (case when leg='V' then 0 else
    (case when TERM <= 2 then 0.0005
    when TERM > 2 and TERM <= 14 then 0.004
    when TERM > 14 then 0.0075
    else 0 end
    ) end ) feerate FROM BONDREPO) bon
WHERE IO.custodycd = CF.custodycd
    AND io.orgorderid = bon.orderid(+)
    AND IO.codeid = SB.codeid AND IO.matchqtty <> 0
    AND IO.DELTD <> 'Y' AND io.tradeplace LIKE V_TRADEPLACE
    AND (SB.sectype LIKE V_STRSECTYPE or (V_STRSECTYPE = '006' and SB.sectype in ('006','003')))
    AND CF.brid LIKE V_INBRID
    AND IO.TXDATE >= V_FROM_DATE
    AND IO.TXDATE <= V_TO_DATE
    AND CF.BRID LIKE V_INBRID
    AND CF.CUSTODYCD LIKE V_STRCUSTODYCD
    AND CF.CUSTODYCD = RE.custodycd(+)
GROUP BY IO.TXDATE,  (case when SB.sectype in ('006','003') then '002' else '001' end),RE.typegr,io.tradeplace,
(case when nvl(bon.LEG,'A') = 'A' then
    (case when io.tradeplace = '005' then 0.02 ---UPCOM
        when sb.sectype in ('008','011') then 0.02 --- ETF : CCQ --Ngay 23/03/2017 CW NamTv chinh sua them sectype 011
        when sb.sectype in ('006','003') then 0.0075 --- Trai phieu
        when sb.sectype in ('001','002','007') then 0.03 --- Co Phieu,
        else 0 end)
    else nvl(bon.feerate,0) ---repo
    end)
;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- Procedure
 
/
