SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE CI0092 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID        IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   P_CUSTODYCD    IN       VARCHAR2,
   P_AFACCTNO     IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   F_CDATE        IN       VARCHAR2,
   T_CDATE        IN       VARCHAR2,
   F_ODATE        IN       VARCHAR2,
   T_ODATE        IN       VARCHAR2,
   I_BRID         IN       VARCHAR2,
   I_ADTYPE       IN       VARCHAR2,
   VIA            IN       VARCHAR2,
   PV_CLEARDT     IN       VARCHAR2
 )
IS


-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
-- BANG KE UONG TRUOC TIEN BAN
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
--NGOCVTT 23/06/15
-- ---------   ------  -------------------------------------------
   V_STROPT     VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID    VARCHAR2 (40);           -- USED WHEN V_NUMOPTION > 0
   V_INBRID     VARCHAR2 (5);
   V_STRAFACCTNO   VARCHAR2 (20);
   V_STRCUSTODYCD  VARCHAR2 (20);
   V_STRISBRID      VARCHAR2 (5);
   V_FROMDATE       DATE;
   V_TODATE         DATE;
   V_CFROMDATE       DATE;
   V_CTODATE         DATE;
   V_OFROMDATE       DATE;
   V_OTODATE         DATE;
   V_ADVFEERATE NUMBER(20,6);
   V_TRADELOG CHAR(20);
   V_AUTOID NUMBER;
   V_INSTANCE VARCHAR2 (20);
   V_ADTYPE     VARCHAR2(20);
   V_STRVIA     VARCHAR2(20);
   V_PV_CLEARDT   NUMBER;
   V_STRCASHPLACE      VARCHAR2(1000);
   v_strchecker         varchar2(200);
   v_strmaker           varchar2(200);
   v_tltxcd             varchar2(200);

BEGIN

   V_STROPT := OPT;
   IF (V_STROPT <> 'A') AND (PV_BRID <> 'ALL')
   THEN
      V_STRBRID := PV_BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;
   
    -- GET REPORT'S PARAMETERS
    IF (UPPER(I_BRID) = 'ALL' OR I_BRID IS NULL)
    THEN
      V_STRISBRID := '%%';
    ELSE
      V_STRISBRID := I_BRID;
    END IF;
-----------------
    IF (UPPER(P_CUSTODYCD) = 'ALL' OR P_CUSTODYCD IS NULL)
    THEN
      V_STRCUSTODYCD := '%%';
    ELSE
      V_STRCUSTODYCD := P_CUSTODYCD;
    END IF;

        IF (UPPER(P_AFACCTNO) = 'ALL' OR P_AFACCTNO IS NULL)
    THEN
      V_STRAFACCTNO := '%%';
    ELSE
      V_STRAFACCTNO := P_AFACCTNO;
    END IF;
  --------------------------
    IF I_ADTYPE = 'ALL' OR I_ADTYPE IS NULL THEN
        V_ADTYPE := '%%';
    ELSE
        V_ADTYPE := I_ADTYPE;
    END IF;

    IF UPPER(VIA) = 'ALL' OR VIA IS NULL THEN
        V_STRVIA := '%';
    ELSE
        V_STRVIA := VIA;
    END IF;

    IF(UPPER(PV_CLEARDT) = 'ALL')OR PV_CLEARDT IS NULL THEN
        V_PV_CLEARDT := 0;
    ELSE
        V_PV_CLEARDT := PV_CLEARDT;
    END IF;

   V_FROMDATE   := TO_DATE(F_DATE,'DD/MM/RRRR');
   V_TODATE     := TO_DATE(T_DATE,'DD/MM/RRRR');
   V_CFROMDATE  := TO_DATE(F_CDATE,'DD/MM/RRRR');
   V_CTODATE    := TO_DATE(T_CDATE,'DD/MM/RRRR');
   V_OFROMDATE  := TO_DATE(F_ODATE,'DD/MM/RRRR');
   V_OTODATE    := TO_DATE(T_ODATE,'DD/MM/RRRR');
    SELECT TO_NUMBER(VARVALUE)/360 INTO V_ADVFEERATE
    FROM SYSVAR WHERE VARNAME = 'AINTRATE' AND GRNAME = 'SYSTEM';
    -- END OF GETTING REPORT'S PARAMETERS

   -- GET REPORT'S DATA
    OPEN  PV_REFCURSOR FOR
        SELECT nvl( tp.tradename,'') brid, ci.txnum, ci.txtype, ci.custodycd, cf.fullname, cf.idcode, cf.iddate, ci.namt amt, ci.txdate, ci.txtime, delt.txdate, delt.txtime,
            ci.tltxcd, tl.txdesc, nvl(mk.tlname,'') mk, ci.txdate, ci.busdate,
            nvl(ck.tlname,'')  ck, nvl(delt.tlid, '') ca
        FROM
            vw_citran_gen ci, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, tllogdel delt, tltx tl, tlprofiles mk, tlprofiles ck, tlprofiles ca,
            tradeplace tp, tradecareby tc
        WHERE ci.custid = cf.custid
            AND ci.txnum = delt.txnum(+)
            AND ci.tltxcd = tl.tltxcd
            and ci.tlid = mk.tlid(+)
            and ci.OFFID =ck.tlid(+)
            AND delt.tlid = ca.tlid(+)
            AND cf.careby = tc.grpid(+)
            AND tc.tradeid = tp.traid(+)
            and ci.field ='BALANCE'
            and ci.busdate  >=to_date(F_DATE,'DD/MM/YYYY')
            and ci.busdate  <=to_date(T_DATE,'DD/MM/YYYY')
            AND ci.TLTXCD LIKE V_TLTXCD
            AND NVL( ci.TLID,'-') LIKE V_STRMAKER
            AND NVL( ci.OFFID,'-') LIKE V_STRCHECKER
            AND ci.custodycd LIKE V_STRCUSTODYCD
            AND ci.acctno LIKE V_STRAFACCTNO
        ORDER BY CI.TXDATE,CI.TLTXCD ,CI.TXNUM;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
 
 
 
/
