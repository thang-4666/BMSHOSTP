SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE od1030 (
   PV_REFCURSOR             IN OUT   PKG_REPORT.REF_CURSOR,
   OPT                      IN       VARCHAR2,
   pv_BRID                  IN       VARCHAR2,
   TLGOUPS                  IN       VARCHAR2,
   TLSCOPE                  IN       VARCHAR2,
   F_DATE                   IN       VARCHAR2,
   T_DATE                   IN       VARCHAR2,
   TRAID                    IN       VARCHAR2,
   I_BRID                   IN       VARCHAR2
    )
IS
-- MODIFICATION HISTORY
-- KET QUA KHOP LENH CUA KHACH HANG
-- PERSON      DATE    COMMENTS
-- NAMNT   15-JUN-08  CREATED
-- DUNGNH  08-SEP-09  MODIFIED
-- THENN    27-MAR-2012 MODIFIED    SUA LAI TINH PHI, THUE DUNG
-- ---------   ------  -------------------------------------------
   V_STROPTION      VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID        VARCHAR2 (4);            -- USED WHEN V_NUMOPTION > 0
   V_STRTRAID        VARCHAR2 (4);


   --V_TRADELOG CHAR(2);
   --V_AUTOID NUMBER;


-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN
   V_STROPTION := OPT;



   IF (V_STROPTION <> 'A') AND (pv_BRID <> 'ALL')
   THEN
      V_STRBRID := pv_BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;

    -- GET REPORT'S PARAMETERS
   --
  IF (TRAID <> 'ALL')
   THEN
      V_STRTRAID := TRAID;
   ELSE
      V_STRTRAID := '%%';
   END IF;

  IF (I_BRID <> 'ALL')
   THEN
      V_STRBRID := I_BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;

   -- GET REPORT'S DATA
    OPEN PV_REFCURSOR FOR
     select od.txdate NGAY_GD, cf.custodycd SO_TAI_KHOAN, cf.fullname HO_TEN,
    od.orgorderid MA_GD, od.matchqtty KHOI_LUONG_KHOP, od.matchprice GIA_KHOP,
    od.matchqtty*od.matchprice GIA_TRI_KHOP, od.iodfeeacr PHI_KHOP,
    (CASE WHEN SB.sectype IN ('001','002','007','011') AND sb.tradeplace = '005' THEN 0.0002 --Ngay 23/03/2017 CW NamTv them sectype 011
          WHEN SB.sectype IN ('003','006') THEN 0.000075
          ELSE 0.0003 END)*(od.matchqtty*od.matchprice) PHI_NOP_TTGD
from
(
    select custodycd, txdate, orgorderid, codeid, sum(matchqtty) matchqtty, matchprice, sum(iodfeeacr ) iodfeeacr
    from vw_iod_all
    where matchqtty > 0 AND TXDATE >= TO_DATE(F_DATE,'DD/MM/RRRR')
    AND TXDATE <= TO_DATE(T_DATE,'DD/MM/RRRR')
    group by custodycd, txdate, orgorderid, codeid, matchprice

) od,
(
    select cf.custodycd, cf.fullname
    from cfmast cf, tradecareby tra
    where cf.careby = tra.grpid
    and tra.tradeid LIKE  V_STRTRAID
    AND cf.brid LIKE V_STRBRID
)cf, sbsecurities sb
where od.custodycd = cf.custodycd
and sb.codeid = od.codeid;


EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
-- PROCEDURE
 
/
