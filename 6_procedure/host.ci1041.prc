SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE CI1041 (
                                   PV_REFCURSOR         IN OUT   PKG_REPORT.REF_CURSOR,
                                   OPT                  IN       VARCHAR2,
                                   pv_BRID              IN       VARCHAR2,
                                   TLGOUPS              IN       VARCHAR2,
                                   TLSCOPE              IN       VARCHAR2,
                                   F_DATE               IN       VARCHAR2,
                                   T_DATE               IN       VARCHAR2,
                                   PV_IBRID             IN       VARCHAR2,
                                   PV_CUSTODYCD         IN       VARCHAR2,
                                   TLTXCD               IN       VARCHAR2,
                                   MAKER                IN       VARCHAR2,
                                   CHECKER              IN       VARCHAR2,
                                   STATUS               IN       VARCHAR2
                                   )
IS
--
-- BAO CAO KHACH HANG THU PHI LUU KY 2 LAN
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- DONT     24-AUG-16  CREATED
-- ---------   ------  -------------------------------------------
    CUR             PKG_REPORT.REF_CURSOR;
    V_STROPTION     VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
    V_STRBRID       VARCHAR2 (4);
    V_CUSTODYCD     VARCHAR2 (20);
    V_IBRID         VARCHAR2(10);
    V_TLTXCD        VARCHAR2(10);
    V_MAKER         VARCHAR2(10);
    V_CHECKER        VARCHAR2(10);
    V_STATUS        VARCHAR2(10);
BEGIN
   V_STROPTION := OPT;
   IF (V_STROPTION <> 'A') AND (pv_BRID <> 'ALL')
   THEN
      V_STRBRID := pv_BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;

   -- GET REPORT'S PARAMETERS
   IF (PV_CUSTODYCD <> 'ALL')
   THEN
      V_CUSTODYCD := PV_CUSTODYCD;
   ELSE
      V_CUSTODYCD := '%%';
   END IF;

    IF (PV_IBRID = 'ALL') THEN
        V_IBRID := '%%';
    ELSE
        V_IBRID := PV_IBRID;
    END IF;

     IF (TLTXCD = 'ALL') THEN
        V_TLTXCD := '%%';
    ELSE
        V_TLTXCD := TLTXCD;
    END IF;

     IF (MAKER = 'ALL') THEN
        V_MAKER := '%%';
    ELSE
        V_MAKER := MAKER;
    END IF;

     IF (CHECKER = 'ALL') THEN
        V_CHECKER := '%%';
    ELSE
        V_CHECKER := CHECKER;
    END IF;
     IF (STATUS = 'ALL') THEN
        V_STATUS := '%%';
    ELSE
        V_STATUS := STATUS;
    END IF;


    OPEN PV_REFCURSOR
    FOR
        SELECT cf.custodycd, br.brname, vw.COUNT
        FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
          brgrp br,
           (SELECT cf.custodycd, COUNT (cf.custodycd) COUNT
            FROM vw_tllog_all tl, cfmast cf, afmast af
            WHERE tltxcd IN ('1180', '1189', '1182', '0088')
                and tl.msgacct = af.acctno
                and cf.custid = af.custid
                AND tl.busdate >= to_date(F_DATE, 'DD/MM/RRRR')
                AND tl.busdate <= to_date(T_DATE, 'DD/MM/RRRR')
                and tltxcd LIKE V_TLTXCD
                and tl.TLID like V_MAKER
                and nvl(tl.OFFID,'A') like V_CHECKER
                and tl.TXSTATUS = 1
                --and tl.TXSTATUS like V_PV_STATUS
                and cf.status like v_status
            GROUP BY cf.custodycd
            HAVING COUNT (cf.custodycd) >= 2) vw
     WHERE cf.custodycd = vw.custodycd
        AND cf.brid = br.brid
        AND cf.custodycd LIKE V_CUSTODYCD
        AND cf.brid LIKE V_IBRID
        and cf.status like v_status
     ORDER BY cf.custodycd;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE
 
 
 
 
/
