SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE CI1040 (
                                   PV_REFCURSOR         IN OUT   PKG_REPORT.REF_CURSOR,
                                   OPT                  IN       VARCHAR2,
                                   pv_BRID              IN       VARCHAR2,
                                   TLGOUPS              IN       VARCHAR2,
                                   TLSCOPE              IN       VARCHAR2,
                                   F_DATE               IN       VARCHAR2,
                                   T_DATE               IN       VARCHAR2,
                                   PV_CUSTODYCD         IN       VARCHAR2,
                                   PV_IBRID             IN       VARCHAR2,
                                   PV_FEENAME           IN       VARCHAR2,
                                   PV_CFTYPE            IN       VARCHAR2,
                                   PV_STATUS            IN       varchar2)
IS
--
-- BAO CAO KHACH HANG DUOC MIEN/GIAM PHI LUU KY
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- DONT     23-AUG-16  CREATED
-- ---------   ------  -------------------------------------------
    CUR             PKG_REPORT.REF_CURSOR;
    V_STROPTION     VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
    V_STRBRID       VARCHAR2 (4);
    V_CUSTODYCD     VARCHAR2 (20);
    V_IBRID         VARCHAR2(10);
    V_STATUS        VARCHAR2(10);
    v_feename       varchar2(20);
    v_feerate       varchar2(20);
    v_cftype        varchar2(10);
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

    IF (PV_FEENAME = 'ALL') THEN
        v_feename := '%%';
    ELSE
        v_feename := PV_FEENAME;
    END IF;

    IF (PV_IBRID = 'ALL') THEN
        V_IBRID := '%%';
    ELSE
        V_IBRID := PV_IBRID;
    END IF;

    IF (PV_STATUS = 'ALL') THEN
        V_STATUS := '%%';
    ELSE
        V_STATUS := PV_STATUS;
    END IF;
    
    IF (PV_CFTYPE = 'ALL') THEN
        v_cftype := '%%';
    ELSE
        v_cftype := PV_CFTYPE;
    END IF;

    OPEN PV_REFCURSOR
    FOR
        SELECT cf.custodycd, cf.fullname, br.brname, ext.valdate, ext.expdate, ext.feeamt, ext.opendate, cft.typename, 
            ext.typename feename, A1.cdcontent status, sum(nvl(fee.amt, 0)) amt
             FROM cfmast cf, afmast af, brgrp br, cifeedef_ext ext, cifeedef_extlnk lnk, cftype cft, allcode A1,
             (SELECT substr(acctno, 1, 10) afacctno, 
                (round(sum(qtty * vsdfeeamt * days/30), 4) - sum(amt)) amt
             FROM sedepobal
                 where txdate >= to_date(F_DATE, 'DD/MM/RRRR')
                 AND txdate <= to_date(T_DATE, 'DD/MM/RRRR')
             GROUP BY substr(acctno, 1, 10)) fee
             WHERE cf.custid = af.custid
             AND cf.brid = br.brid
             AND af.acctno = lnk.afacctno
             AND lnk.actype = ext.actype
             AND cf.actype = cft.actype
			 and cf.actype like v_cftype
             AND A1.cdtype = 'CF'
             AND A1.cdname = 'STATUS'
             AND A1.cdval = cf.status
             AND af.acctno = fee.afacctno(+)
             AND ext.valdate <= to_date(F_DATE, 'DD/MM/RRRR')
             AND ext.expdate >= to_date(T_DATE, 'DD/MM/RRRR')
             AND cf.custodycd LIKE V_CUSTODYCD
             AND cf.brid LIKE V_IBRID
             AND ext.actype LIKE v_feename
             AND cf.status LIKE V_STATUS
         GROUP BY cf.custodycd, cf.fullname, br.brname, ext.valdate, ext.expdate, ext.feeamt, ext.opendate, cft.typename, 
            ext.typename, A1.cdcontent
        ORDER BY cf.custodycd;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE
 
 
 
 
/
