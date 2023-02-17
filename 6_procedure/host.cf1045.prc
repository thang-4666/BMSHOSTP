SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE CF1045 (
                                   PV_REFCURSOR         IN OUT   PKG_REPORT.REF_CURSOR,
                                   OPT                  IN       VARCHAR2,
                                   pv_BRID              IN       VARCHAR2,
                                   TLGOUPS              IN       VARCHAR2,
                                   TLSCOPE              IN       VARCHAR2,
                                   PV_FRDATE            IN       VARCHAR2,
                                   PV_TODATE            IN       VARCHAR2,
                                   PV_CUSTODYCD         IN       VARCHAR2,
                                   PV_STATUS            IN       VARCHAR2,
                                   PV_OBRID            IN       VARCHAR2,
                                   PV_NBRID             IN      varchar2
                                   )
IS
--
-- BAO CAO DANH SACH KHACH HANG CHUYEN DIA BAN
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- DONT   19-AUG-16  CREATED
-- ---------   ------  -------------------------------------------
    CUR             PKG_REPORT.REF_CURSOR;
    V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
    V_STRBRID      VARCHAR2 (4);
    V_STRCUSTODYCD     VARCHAR2 (20);
    v_status        varchar2(20);
    v_oldbrid       varchar2(20);
    v_newbrid       varchar2(20);
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
    
    IF (PV_STATUS = 'ALL') THEN
        v_status := '%%';
    ELSE
        v_status := PV_STATUS;
    END IF;
    
    IF (PV_OBRID = 'ALL') THEN
        v_oldbrid := '%%';
    ELSE
        v_oldbrid := PV_OBRID;
    END IF;
    
    IF (PV_NBRID = 'ALL') THEN
        v_newbrid := '%%';
    ELSE
        v_newbrid := PV_NBRID;
    END IF;
    
    OPEN PV_REFCURSOR
    FOR
        SELECT cf.custodycd, cf.fullname, cf.idcode, cf.iddate, br1.brname oldbranch, br2.brname newbranch, 
                A1.cdcontent status, ml.approve_dt maker_dt
            FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, 
            brgrp br1, brgrp br2, allcode A1, maintain_log ml
            WHERE ml.table_name = 'CFMAST' 
            AND ml.column_name = 'BRID' 
            AND ml.action_flag = 'EDIT'
            AND ml.record_column_key = cf.custid
            AND ml.from_value = br1.brid
            AND ml.to_value = br2.brid
            AND A1.cdval = cf.status
            AND A1.cdtype = 'CF'
            AND A1.cdname = 'STATUS'
            AND cf.custodycd LIKE V_STRCUSTODYCD
            AND cf.status LIKE v_status
            AND ml.from_value LIKE v_oldbrid
            AND ml.to_value LIKE v_newbrid
            AND ml.maker_dt >= to_date(PV_FRDATE, 'DD/MM/RRRR')
            AND ml.maker_dt <= to_date(PV_TODATE, 'DD/MM/RRRR')
            ORDER BY ml.approve_dt;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE
 
 
 
 
/
