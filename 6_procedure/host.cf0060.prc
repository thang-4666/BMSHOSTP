SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF0060" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   IN_DATE         IN       VARCHAR2
 )
IS
--

   V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID      VARCHAR2 (40);            -- USED WHEN V_NUMOPTION > 0
   V_INBRID     VARCHAR2 (5);      -- USED WHEN V_NUMOPTION > 0

   V_INDATE     DATE;

   V_TOCHUC_TN  number;
   V_CANHAN_TN  number;
   V_TOCHUC_NN  number;
   V_CANHAN_NN  number;

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE

BEGIN
-- INSERT INTO TEMP_BUG(TEXT) VALUES('CF0001');COMMIT;
   V_STROPTION := upper(OPT);
   V_INBRID := pv_BRID;

   if(V_STROPTION = 'A') then
        V_STRBRID := '%';
    else
        if(V_STROPTION = 'B') then
            select br.BRID into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := pv_BRID;
        end if;
    end if;

    V_INDATE := to_date(IN_DATE,'DD/MM/RRRR');

--- SL TO CHUC TRONG NUOC TAI NGAY
    SELECT a.amt + b.amt - c.amt into V_TOCHUC_TN
    FROM
    (
        SELECT count(*) amt FROM (
            select DISTINCT cf.* from (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af
            where cf.custid = af.custid
            and af.status = 'A') cf
        WHERE cf.status = 'A' AND cf.custtype = 'B' AND cf.custatcom = 'Y'
            AND cf.custodycd IS NOT NULL
            and nvl(cf.country,'234') = '234'
    ) a,
    (
        SELECT count(*) amt FROM vw_tllog_all, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,VW_TLLOGFLD_ALL FLD
        WHERE tltxcd = '0059' AND busdate >= V_INDATE AND deltd <> 'Y'
            AND cf.custid = vw_tllog_all.msgacct AND cf.custtype = 'B'
            AND cf.custatcom = 'Y'
            AND CF.custodycd IS NOT NULL
            AND custodycd IS NOT NULL
            and nvl(country,'234') = '234'
            AND vw_tllog_all.TXNUM=FLD.TXNUM
                        AND vw_tllog_all.TXDATE=FLD.TXDATE
                        AND FLD.FLDCD='08' AND FLD.CVALUE<>'N'
    ) b,
    (
        SELECT count(*) amt FROM
        (
            SELECT custid FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) WHERE opndate >= V_INDATE
                AND custtype = 'B'
                AND custodycd IS NOT NULL
                and nvl(country,'234') = '234'
                AND custatcom = 'Y'
            union all
            SELECT vw_tllog_all.msgacct FROM vw_tllog_all, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,VW_TLLOGFLD_ALL FLD
            WHERE tltxcd = '0067' AND busdate >= V_INDATE AND deltd <> 'Y'
                AND cf.custid = vw_tllog_all.msgacct AND cf.custtype = 'B'
                AND cf.custatcom = 'Y' AND CF.custodycd IS NOT NULL
                and nvl(country,'234') = '234'
                AND vw_tllog_all.TXNUM=FLD.TXNUM
                        AND vw_tllog_all.TXDATE=FLD.TXDATE
                        AND FLD.FLDCD='08' AND FLD.CVALUE<>'N'
        )
    ) c;
--- SL CA NHAN TRONG NUOC TAI NGAY
    SELECT a.amt + b.amt - c.amt INTO V_CANHAN_TN
    FROM
    (
        SELECT count(*) amt FROM (
            select DISTINCT cf.* from (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af
            where cf.custid = af.custid
            and af.status = 'A') cf
        WHERE cf.status = 'A' AND cf.custtype = 'I' AND cf.custatcom = 'Y'
            AND cf.custodycd IS NOT NULL and nvl(cf.country,'234') = '234'
    ) a,
    (
        SELECT count(*) amt FROM vw_tllog_all, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,VW_TLLOGFLD_ALL FLD
        WHERE tltxcd = '0059' AND busdate >= V_INDATE AND deltd <> 'Y'
        AND cf.custid = vw_tllog_all.msgacct AND cf.custtype = 'I'
        AND cf.custatcom = 'Y' AND CF.custodycd IS NOT NULL
        and nvl(country,'234') = '234'
        AND vw_tllog_all.TXNUM=FLD.TXNUM
        AND vw_tllog_all.TXDATE=FLD.TXDATE
        AND FLD.FLDCD='08' AND FLD.CVALUE<>'N'
    ) b,
    (
    SELECT count(*) amt FROM
    (
        SELECT custid FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0)  WHERE opndate >= V_INDATE
            AND custtype = 'I' AND custodycd IS NOT NULL
            and nvl(country,'234') = '234' AND custatcom = 'Y'
        union all
        SELECT vw_tllog_all.msgacct FROM vw_tllog_all, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,VW_TLLOGFLD_ALL FLD
        WHERE tltxcd = '0067' AND busdate >= V_INDATE AND deltd <> 'Y'
            AND cf.custid = vw_tllog_all.msgacct AND cf.custtype = 'I'
            AND cf.custatcom = 'Y' AND CF.custodycd IS NOT NULL
            and nvl(country,'234') = '234'
            AND vw_tllog_all.TXNUM=FLD.TXNUM
            AND vw_tllog_all.TXDATE=FLD.TXDATE
            AND FLD.FLDCD='08' AND FLD.CVALUE<>'N'
    )
    )c;
--- SL TO CHUC NUOC NGOAI TAI NGAY
    SELECT a.amt + b.amt - c.amt into V_TOCHUC_NN
    FROM
    (
        SELECT count(*) amt FROM (
            select DISTINCT cf.* from (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af
            where cf.custid = af.custid
            and af.status = 'A') cf
        WHERE STATUS = 'A' AND cf.custtype = 'B' AND cf.custodycd IS NOT NULL
            and nvl(cf.country,'234') <> '234' AND cf.custatcom = 'Y'
    ) a,
    (
        SELECT count(*) amt FROM vw_tllog_all, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, VW_TLLOGFLD_ALL FLD
        WHERE tltxcd = '0059' AND busdate >= V_INDATE  AND deltd <> 'Y'
        AND cf.custid = vw_tllog_all.msgacct AND cf.custtype = 'B'
        AND cf.custatcom = 'Y'
        AND vw_tllog_all.TXNUM=FLD.TXNUM
        AND vw_tllog_all.TXDATE=FLD.TXDATE
        AND FLD.FLDCD='08' AND FLD.CVALUE<>'N'
        AND CF.custodycd IS NOT NULL and nvl(country,'234') <> '234'
    ) b,
    (
        SELECT count(*) amt FROM
        (
            SELECT custid FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) WHERE opndate >= V_INDATE
            AND custtype = 'B' AND custodycd IS NOT NULL
            and nvl(country,'234') <> '234' AND custatcom = 'Y'
            union all
            SELECT vw_tllog_all.msgacct FROM vw_tllog_all, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, VW_TLLOGFLD_ALL FLD
            WHERE tltxcd = '0067' AND busdate >= V_INDATE AND deltd <> 'Y'
                AND cf.custid = vw_tllog_all.msgacct AND cf.custtype = 'B'
                AND cf.custatcom = 'Y'
                AND vw_tllog_all.TXNUM=FLD.TXNUM
                AND vw_tllog_all.TXDATE=FLD.TXDATE
                AND FLD.FLDCD='08' AND FLD.CVALUE<>'N'
                AND CF.custodycd IS NOT NULL and nvl(country,'234') <> '234'

        )
    )c;
--- SL CA NHAN NUOC NGOAI TAI NGAY

    SELECT a.amt + b.amt - c.amt INTO V_CANHAN_NN
    FROM
    (
        SELECT count(*) amt FROM (
        select DISTINCT cf.* from (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af
        where cf.custid = af.custid
        and af.status = 'A') cf WHERE STATUS = 'A'
        AND cf.custtype = 'I' AND cf.custodycd IS NOT NULL
        and nvl(cf.country,'234') <> '234' AND cf.custatcom = 'Y'
    ) a,
    (
        SELECT count(*) amt FROM vw_tllog_all, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, VW_TLLOGFLD_ALL FLD
        WHERE tltxcd = '0059' AND busdate >= V_INDATE AND deltd <> 'Y'
        AND cf.custid = vw_tllog_all.msgacct AND cf.custtype = 'I'
        AND cf.custatcom = 'Y'
        AND vw_tllog_all.TXNUM=FLD.TXNUM
        AND vw_tllog_all.TXDATE=FLD.TXDATE
        AND FLD.FLDCD='08' AND FLD.CVALUE<>'N'
        AND CF.custodycd IS NOT NULL and nvl(country,'234') <> '234'
    ) b,
    (
        SELECT count(*) amt FROM
        (
            SELECT custid FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0)
            WHERE opndate >= V_INDATE AND custtype = 'I'
                AND custodycd IS NOT NULL
                and nvl(country,'234') <> '234' AND custatcom = 'Y'
            union all
            SELECT vw_tllog_all.msgacct FROM vw_tllog_all, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, VW_TLLOGFLD_ALL FLD
            WHERE tltxcd = '0067' AND busdate >= V_INDATE AND deltd <> 'Y'
                AND cf.custid = vw_tllog_all.msgacct AND cf.custtype = 'I'
                AND cf.custatcom = 'Y'
                AND vw_tllog_all.TXNUM=FLD.TXNUM
                AND vw_tllog_all.TXDATE=FLD.TXDATE
                AND FLD.FLDCD='08' AND FLD.CVALUE<>'N'
                AND CF.custodycd IS NOT NULL and nvl(country,'234') <> '234'
        )
    )c;

OPEN PV_REFCURSOR FOR
SELECT V_INDATE INDATE, V_TOCHUC_TN TOCHUC_TN, V_CANHAN_TN CANHAN_TN,
    V_TOCHUC_NN TOCHUC_NN, V_CANHAN_NN CANHAN_NN
FROM DUAL
;

EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;
 
 
 
 
/
