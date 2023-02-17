SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF0014" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE         IN       VARCHAR2
)
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
-- BAO CAO TAI KHOAN SE KHACH HANG
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- NAMNT   20-DEC-06  CREATED
-- ---------   ------  -------------------------------------------
   V_STROPTION     VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID       VARCHAR2 (4);
   V_CURRDATE       DATE;
   V_INDATE         DATE;
BEGIN
   V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (PV_BRID <> 'ALL')
   THEN
      V_STRBRID := PV_BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;
    select TO_DATE(varvalue,'DD/MM/RRRR') INTO V_CURRDATE from sysvar where varname = 'CURRDATE' AND GRNAME = 'SYSTEM';

---    V_INDATE := TO_DATE(I_DATE,'DD/MM/RRRR');
    SELECT max(sbdate) INTO V_INDATE
    FROM sbcurrdate
    WHERE sbtype = 'B' AND sbdate <= to_date(I_DATE,'DD/MM/RRRR');
 -- END OF GETTING REPORT'S PARAMETERS

   -- GET REPORT'S DATA`
IF (V_INDATE = V_CURRDATE) THEN
    OPEN PV_REFCURSOR FOR
    SELECT * FROM
    (
    SELECT I_DATE indate, orderby, sum(S_TK) S_TK, bankname
        FROM
        (
            SELECT 1 orderby, sum(1) S_TK, 'BIDV' bankname
            FROM
            (
                SELECT CF.custodycd, SUM(CASE WHEN af.corebank = 'Y' or af.alternateacct = 'Y' THEN 1 ELSE 0 END) IScorebank,
                    SUM(CASE WHEN af.corebank = 'N' THEN 1 ELSE 0 END) NOTcorebank
                FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, AFMAST AF
                WHERE CF.CUSTID = AF.custid AND cf.custatcom = 'Y'
                    AND CF.status = 'A' and af.status = 'A' AND cf.opndate < V_INDATE
                GROUP BY CF.custodycd
            )
            WHERE IScorebank >= 1
        ) close_open
        group by bankname, orderby
    union all
    SELECT I_DATE indate, orderby, sum(S_TK) S_TK, bankname
        FROM
        (
            SELECT 2 orderby, sum(1) S_TK, 'TKT' bankname
            FROM
            (
                SELECT CF.custodycd, SUM(CASE WHEN af.corebank = 'Y' or af.alternateacct = 'Y' THEN 1 ELSE 0 END) IScorebank,
                    SUM(CASE WHEN af.corebank = 'N' THEN 1 ELSE 0 END) NOTcorebank
                FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, AFMAST AF
                WHERE CF.CUSTID = AF.custid AND cf.custatcom = 'Y'
                    AND CF.status = 'A' and af.status = 'A' AND cf.opndate < V_INDATE
                GROUP BY CF.custodycd
            )
            WHERE IScorebank = 0 AND NOTcorebank >= 1
        ) close_open
        group by bankname, orderby
    union all
    SELECT I_DATE indate, orderby, sum(S_TK) S_TK, bankname
        FROM
        (
            SELECT 3 orderby, sum(1) S_TK, 'TKKLK' bankname
            FROM cfmast cf
            WHERE cf.opndate <= V_INDATE AND cf.custatcom = 'N'
                AND CF.status = 'A'
        ) close_open
        group by bankname, orderby
    )
;
ELSE
OPEN PV_REFCURSOR FOR
    select TO_CHAR(txdate ,'DD/MM/RRRR') indate, id orderby, SUM(countn) S_TK,
        (CASE WHEN id = 1 THEN 'BIDV'
            WHEN id = 2 THEN 'TKT'
            WHEN id = 3 THEN 'TKKLK'
            ELSE 'BIDV' END) bankname
    from cf0014_log WHERE txdate = V_INDATE
    GROUP BY id, txdate ;
END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
