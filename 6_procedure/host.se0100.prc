SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE SE0100 (
                                   PV_REFCURSOR         IN OUT   PKG_REPORT.REF_CURSOR,
                                   OPT                  IN       VARCHAR2,
                                   pv_BRID              IN       VARCHAR2,
                                   TLGOUPS              IN       VARCHAR2,
                                   TLSCOPE              IN       VARCHAR2,
                                   PV_CUSTODYCD         IN       VARCHAR2,
                                   PV_STATUS            IN       VARCHAR2,
                                   PV_SYMBOL            IN       VARCHAR2,
                                   I_BRID               IN       VARCHAR2
                                   )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
-- BAO CAO TAI KHOAN CON BI PHONG TOA CK
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- DONT   18-AUG-16  CREATED
-- ---------   ------  -------------------------------------------
    CUR             PKG_REPORT.REF_CURSOR;
    V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
    V_STRBRID      VARCHAR2 (4);
    V_STRCUSTODYCD     VARCHAR2 (20);
    v_symbol        varchar2(20);
    v_status        varchar2(20);
    V_I_BRID       varchar2(20);
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
      V_STRCUSTODYCD := PV_CUSTODYCD;
   ELSE
      V_STRCUSTODYCD := '%%';
   END IF;

   IF (PV_SYMBOL = 'ALL') THEN
        v_symbol := '%%';
    ELSE
        v_symbol := PV_SYMBOL;
    END IF;

    IF (PV_STATUS = 'ALL') THEN
        v_status := '%%';
    ELSE
        v_status := PV_STATUS;
    END IF;

    IF (I_BRID = 'ALL') THEN
        v_I_BRID := '%%';
    ELSE
        v_I_BRID := I_BRID;
    END IF;

    OPEN PV_REFCURSOR
    FOR
        SELECT cf.custodycd, cf.fullname, cf.brid, sb.symbol, se.emkqtty, A1.cdcontent cfstatus, A2.cdcontent sestatus,a3.cdcontent producttype
        FROM (SELECT * FROM CFMAST WHERE INSTR(TLGOUPS, CAREBY)>0) cf, semast se, sbsecurities sb, allcode A1, allcode A2,allcode a3,afmast af
        WHERE cf.custid = se.custid
            AND se.codeid = sb.codeid
            AND cf.status = A1.cdval
            AND A1.cdname = 'STATUS'
            AND A1.cdtype = 'CF'
            AND se.status = A2.cdval
            AND A2.cdname = 'STATUS'
            AND A2.cdtype = 'CF'
            AND se.emkqtty > 0
            and af.custid = cf.custid
            and af.acctno = se.afacctno
            and a3.cdval = af.producttype
            and a3.cdname='PRODUCTTYPE'
            and a3.cdtype ='CF'
            AND cf.custodycd LIKE V_STRCUSTODYCD
            AND cf.status LIKE v_status
            AND sb.symbol LIKE v_symbol
            AND cf.brid like V_I_BRID
      order by cf.custodycd,a3.lstodr;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE
 
 
 
 
/
