SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE cf0083(PV_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
                                   OPT          IN VARCHAR2,
                                   PV_BRID      IN VARCHAR2,
                                   TLGOUPS      IN VARCHAR2,
                                   TLSCOPE      IN VARCHAR2,
                                   F_DATE       IN VARCHAR2,
                                   T_DATE       IN VARCHAR2,
                                   PV_CUSTODYCD IN VARCHAR2,
                                   PV_POLICY    IN VARCHAR2,
                                   PV_UD        IN VARCHAR2,
                                   PV_AFTYPE IN VARCHAR2) IS
  --
  -- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
  --
  -- MODIFICATION HISTORY
  -- PERSON      DATE       COMMENTS
  -- Diennt      28/12/2011 Create
  -- ---------   ------     -------------------------------------------
  V_STROPTION VARCHAR2(5); -- A: ALL; B: BRANCH; S: SUB-BRANCH
  V_STRBRGID  VARCHAR2(10);
  V_branch    varchar2(5);
  V_INBRID    VARCHAR2(4);
  V_STRBRID   VARCHAR2(50);
  V_STRSTATUS VARCHAR2(10);

  V_STRCUSTODYCD VARCHAR2(30);
  V_POLYCY       VARCHAR2(20);
  V_PV_AFTYPE       VARCHAR2(20);
  -- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE

BEGIN

  IF PV_CUSTODYCD IS NULL OR UPPER(PV_CUSTODYCD) = 'ALL' THEN
    V_STRCUSTODYCD := '%';
  ELSE
    V_STRCUSTODYCD := UPPER(PV_CUSTODYCD);
  END IF;

  IF PV_POLICY IS NULL OR UPPER(PV_POLICY) = 'ALL' THEN
    V_POLYCY := '%';
  ELSE
    V_POLYCY := replace(PV_POLICY, ' ', '_');
  END IF;
  IF PV_AFTYPE IS NULL OR UPPER(PV_AFTYPE) = 'ALL' THEN
    V_PV_AFTYPE := '%';
  ELSE
    V_PV_AFTYPE := UPPER(PV_AFTYPE);
  END IF;
  if PV_UD = '001' then
    -- uu dai phi magin
    OPEN PV_REFCURSOR FOR
      SELECT LG.approve_dt ACTIONDATE,
             CF.CUSTODYCD,
             CF.ACCTNO,
             CF.TYPENAME,
             CF.FULLNAME,
             A1.CDCONTENT ACTION,
             (CASE
               when A1.CDVAL IN ('DELETE','EDIT') then
                ODPNEW.FULLNAME
               else
                ' '
             end) POLICYNAME_OLD,
             (CASE
               when A1.CDVAL IN ('DELETE','EDIT') then
                TO_CHAR(ODPNEW.AUTOID)
               else
                ''
             end) POLICYID_OLD,
             (CASE
               when A1.CDVAL IN ('ADD','EDIT') then
                ODPNEW.FULLNAME
               else
                ''
             end)  POLICYNAME_NEW,
             (CASE
               when A1.CDVAL = 'ADD' then
                TO_CHAR(ODPNEW.AUTOID)
               else
               to_char(lg.NEW_REFAUTOID) 
             end) POLICYID_NEW,
             TLP1.TLFULLNAME MAKERNAME,
             TLP2.TLFULLNAME APPROVENAME
         FROM (select CF.CUSTODYCD,
             AF.ACCTNO,
             AFT.TYPENAME,
             CF.FULLNAME,af.producttype  from   (SELECT *
                FROM CFMAST
               WHERE FNC_VALIDATE_SCOPE(BRID,
                                        CAREBY,
                                        TLSCOPE,
                                        pv_BRID,
                                        TLGOUPS) = 0
                 AND CUSTODYCD LIKE V_STRCUSTODYCD) cf
                 ,AFMAST AF,
             AFTYPE AFT
             where   AF.CUSTID = CF.CUSTID
         AND AF.ACTYPE = AFT.ACTYPE ) CF,
             lnprminmast ODPNEW,
             TLPROFILES TLP1,
             TLPROFILES TLP2,
             ALLCODE A1,
             (SELECT ACTION_FLAG,
                     RECORD_KEY,
                     MAKER_DT,
                     MAKER_ID,
                     MAX(NVL(APPROVE_ID, '00')) APPROVE_ID,
                     MAX(APPROVE_DT) APPROVE_DT,
                     MAX(CASE
                           WHEN COLUMN_NAME = 'AFACCTNO' THEN
                            (CASE
                              WHEN ACTION_FLAG IN ('ADD') THEN
                               TO_VALUE
                              ELSE
                               FROM_VALUE
                            END)
                           ELSE
                            ''
                         END) AFACCTNO,
                     MAX(CASE
                           WHEN COLUMN_NAME = 'REFID' THEN
                            FROM_VALUE
                           ELSE
                            ''
                         END) OLD_REFAUTOID,
                     MAX(CASE
                           WHEN COLUMN_NAME = 'REFID' THEN
                            TO_VALUE
                           ELSE
                            ''
                         END) NEW_REFAUTOID,lnp.afacctno  lnpafacctno
                FROM MAINTAIN_LOG mn,LNPRMINTCF lnp
               WHERE TABLE_NAME = 'LNPRMINTCF'
                 AND approve_dt >= TO_DATE('11/09/2015', 'DD/MM/RRRR')
                 AND approve_dt >= TO_DATE(F_DATE, 'DD/MM/RRRR')
                 AND approve_dt <= TO_DATE(T_DATE, 'DD/MM/RRRR')
                 and mn.record_column_key = lnp.autoid(+)
               GROUP BY ACTION_FLAG, RECORD_KEY, MAKER_DT, MAKER_ID,lnp.afacctno) LG
       WHERE (LG.AFACCTNO = CF.ACCTNO or lg.lnpafacctno = CF.ACCTNO)
          AND  (case when  LG.ACTION_FLAG = 'ADD' then NVL(LG.NEW_REFAUTOID, 99999)
               else  NVL(LG.OLD_REFAUTOID, 99999)  end ) = ODPNEW.AUTOID
         AND LG.MAKER_ID = TLP1.TLID
         AND LG.APPROVE_ID = TLP2.TLID(+)
         AND LG.ACTION_FLAG = A1.CDVAL
         AND A1.CDNAME = 'ACTION_FLAG'
         AND A1.CDTYPE = 'SA'
         and NVL(CF.producttype,'A') like V_PV_AFTYPE
         AND (NVL(LG.NEW_REFAUTOID, 99999) LIKE V_POLYCY OR
            NVL(LG.OLD_REFAUTOID, 99999) LIKE V_POLYCY);
  end if;

  if PV_UD = '002' then
    -- uu dai phi ung truoc
    OPEN PV_REFCURSOR FOR
      SELECT LG.approve_dt    ACTIONDATE,
             CF.CUSTODYCD,
             AF.ACCTNO,
             AFT.TYPENAME,
             CF.FULLNAME,
             A1.CDCONTENT     ACTION,
             (CASE
               when A1.CDVAL = 'DELETE' then
                ODPNEW.FULLNAME
               else
                ' '
             end) POLICYNAME_OLD,
             (CASE
               when A1.CDVAL = 'DELETE' then
                TO_CHAR(ODPNEW.AUTOID)
               else
                ''
             end) POLICYID_OLD,
             (CASE
               when A1.CDVAL = 'ADD' then
                ODPNEW.FULLNAME
               else
                ''
             end)  POLICYNAME_NEW,
             (CASE
               when A1.CDVAL = 'ADD' then
                TO_CHAR(ODPNEW.AUTOID)
               else
                ''
             end) POLICYID_NEW,
             TLP1.TLFULLNAME  MAKERNAME,
             TLP2.TLFULLNAME  APPROVENAME
        FROM (SELECT *
                FROM CFMAST
               WHERE FNC_VALIDATE_SCOPE(BRID,
                                        CAREBY,
                                        TLSCOPE,
                                        pv_BRID,
                                        TLGOUPS) = 0
                 AND CUSTODYCD LIKE V_STRCUSTODYCD) CF,
             AFMAST AF,
             AFTYPE AFT,
             ADPRMFEEMST ODPNEW,
             TLPROFILES TLP1,
             TLPROFILES TLP2,
             ALLCODE A1,
             (SELECT ACTION_FLAG,
                     RECORD_KEY,
                     MAKER_DT,
                     MAKER_ID,
                     MAX(NVL(APPROVE_ID, '00')) APPROVE_ID,
                     MAX(APPROVE_DT) APPROVE_DT,
                     MAX(CASE
                           WHEN COLUMN_NAME = 'AFACCTNO' THEN
                            (CASE
                              WHEN ACTION_FLAG = 'ADD' THEN
                               TO_VALUE
                              ELSE
                               FROM_VALUE
                            END)
                           ELSE
                            ''
                         END) AFACCTNO,
                     MAX(CASE
                           WHEN COLUMN_NAME = 'PROMOTIONID' THEN
                            FROM_VALUE
                           ELSE
                            ''
                         END) OLD_REFAUTOID,
                     MAX(CASE
                           WHEN COLUMN_NAME = 'PROMOTIONID' THEN
                            TO_VALUE
                           ELSE
                            ''
                         END) NEW_REFAUTOID
                FROM MAINTAIN_LOG
               WHERE TABLE_NAME = 'ADPRMFEECF'
                 AND approve_dt >= TO_DATE('11/09/2015', 'DD/MM/RRRR')
                 AND approve_dt >= TO_DATE(F_DATE, 'DD/MM/RRRR')
                 AND approve_dt <= TO_DATE(T_DATE, 'DD/MM/RRRR')
               GROUP BY ACTION_FLAG, RECORD_KEY, MAKER_DT, MAKER_ID) LG
       WHERE LG.AFACCTNO = AF.ACCTNO
         AND AF.CUSTID = CF.CUSTID
         AND AF.ACTYPE = AFT.ACTYPE
         AND (NVL(LG.NEW_REFAUTOID, 99999) = ODPNEW.AUTOID OR NVL(LG.OLD_REFAUTOID, 99999) = ODPNEW.AUTOID)
         AND LG.MAKER_ID = TLP1.TLID
         AND LG.APPROVE_ID = TLP2.TLID(+)
         AND LG.ACTION_FLAG = A1.CDVAL
         AND A1.CDNAME = 'ACTION_FLAG'
         AND A1.CDTYPE = 'SA'
         and af.producttype like V_PV_AFTYPE
         AND (NVL(LG.NEW_REFAUTOID, 99999) LIKE V_POLYCY OR
             NVL(LG.OLD_REFAUTOID, 99999) LIKE V_POLYCY);
  end if;

  if PV_UD = '003' then
    -- uu dai han muc marin
    OPEN PV_REFCURSOR FOR
      SELECT LG.approve_dt    ACTIONDATE,
             CF.CUSTODYCD,
             AF.ACCTNO,
             AFT.TYPENAME,
             CF.FULLNAME,
             A1.CDCONTENT     ACTION,
            (CASE
               when A1.CDVAL = 'DELETE' then
                ODPNEW.FULLNAME
               else
                ' '
             end) POLICYNAME_OLD,
             (CASE
               when A1.CDVAL = 'DELETE' then
                TO_CHAR(ODPNEW.AUTOID)
               else
                ''
             end) POLICYID_OLD,
             (CASE
               when A1.CDVAL = 'ADD' then
                ODPNEW.FULLNAME
               else
                ''
             end)  POLICYNAME_NEW,
             (CASE
               when A1.CDVAL = 'ADD' then
                TO_CHAR(ODPNEW.AUTOID)
               else
                ''
             end) POLICYID_NEW,
             TLP1.TLFULLNAME  MAKERNAME,
             TLP2.TLFULLNAME  APPROVENAME
        FROM (SELECT *
                FROM CFMAST
               WHERE FNC_VALIDATE_SCOPE(BRID,
                                        CAREBY,
                                        TLSCOPE,
                                        pv_BRID,
                                        TLGOUPS) = 0
                 AND CUSTODYCD LIKE V_STRCUSTODYCD) CF,
             AFMAST AF,
             AFTYPE AFT,
             MRPRMLIMITMST ODPNEW,
             TLPROFILES TLP1,
             TLPROFILES TLP2,
             ALLCODE A1,
             (SELECT ACTION_FLAG,
                     RECORD_KEY,
                     MAKER_DT,
                     MAKER_ID,
                     MAX(NVL(APPROVE_ID, '00')) APPROVE_ID,
                     MAX(APPROVE_DT) APPROVE_DT,
                     MAX(CASE
                           WHEN COLUMN_NAME = 'AFACCTNO' THEN
                            (CASE
                              WHEN ACTION_FLAG = 'ADD' THEN
                               TO_VALUE
                              ELSE
                               FROM_VALUE
                            END)
                           ELSE
                            ''
                         END) AFACCTNO,
                     MAX(CASE
                           WHEN COLUMN_NAME = 'PROMOTIONID' THEN
                            FROM_VALUE
                           ELSE
                            ''
                         END) OLD_REFAUTOID,
                     MAX(CASE
                           WHEN COLUMN_NAME = 'PROMOTIONID' THEN
                            TO_VALUE
                           ELSE
                            ''
                         END) NEW_REFAUTOID
                FROM MAINTAIN_LOG
               WHERE TABLE_NAME = 'MRPRMLIMITCF'
                 AND approve_dt >= TO_DATE('11/09/2015', 'DD/MM/RRRR')
                 AND approve_dt >= TO_DATE(F_DATE, 'DD/MM/RRRR')
                 AND approve_dt <= TO_DATE(T_DATE, 'DD/MM/RRRR')
               GROUP BY ACTION_FLAG, RECORD_KEY, MAKER_DT, MAKER_ID) LG
       WHERE LG.AFACCTNO = AF.ACCTNO
         AND AF.CUSTID = CF.CUSTID
         AND AF.ACTYPE = AFT.ACTYPE
         AND (NVL(LG.NEW_REFAUTOID, 99999) = ODPNEW.AUTOID OR NVL(LG.OLD_REFAUTOID, 99999) = ODPNEW.AUTOID)
         AND LG.MAKER_ID = TLP1.TLID
         AND LG.APPROVE_ID = TLP2.TLID(+)
         AND LG.ACTION_FLAG = A1.CDVAL
         AND A1.CDNAME = 'ACTION_FLAG'
         AND A1.CDTYPE = 'SA'
         and af.producttype like V_PV_AFTYPE
         AND (NVL(LG.NEW_REFAUTOID, 99999) LIKE V_POLYCY OR
             NVL(LG.OLD_REFAUTOID, 99999) LIKE V_POLYCY);
  end if;

  --- ALL
  IF PV_UD = 'ALL' then
    OPEN PV_REFCURSOR FOR
        SELECT LG.approve_dt ACTIONDATE,
             CF.CUSTODYCD,
             CF.ACCTNO,
             CF.TYPENAME,
             CF.FULLNAME,
             A1.CDCONTENT ACTION,
             (CASE
               when A1.CDVAL IN ('DELETE','EDIT') then
                ODPNEW.FULLNAME
               else
                ' '
             end) POLICYNAME_OLD,
             (CASE
               when A1.CDVAL IN ('DELETE','EDIT') then
                TO_CHAR(ODPNEW.AUTOID)
               else
                ''
             end) POLICYID_OLD,
             (CASE
               when A1.CDVAL IN ('ADD','EDIT')  then
                ODPNEW.FULLNAME
               else
                ''
             end)  POLICYNAME_NEW,
             (CASE
               when A1.CDVAL = 'ADD' then
                TO_CHAR(ODPNEW.AUTOID)
               else
               to_char(lg.NEW_REFAUTOID) 
             end) POLICYID_NEW,
             TLP1.TLFULLNAME MAKERNAME,
             TLP2.TLFULLNAME APPROVENAME
         FROM (select CF.CUSTODYCD,
             AF.ACCTNO,
             AFT.TYPENAME,
             CF.FULLNAME,af.producttype  from   (SELECT *
                FROM CFMAST
               WHERE FNC_VALIDATE_SCOPE(BRID,
                                        CAREBY,
                                        TLSCOPE,
                                        pv_BRID,
                                        TLGOUPS) = 0
                 AND CUSTODYCD LIKE V_STRCUSTODYCD) cf
                 ,AFMAST AF,
             AFTYPE AFT
             where   AF.CUSTID = CF.CUSTID
         AND AF.ACTYPE = AFT.ACTYPE ) CF,
             lnprminmast ODPNEW,
             TLPROFILES TLP1,
             TLPROFILES TLP2,
             ALLCODE A1,
             (SELECT ACTION_FLAG,
                     RECORD_KEY,
                     MAKER_DT,
                     MAKER_ID,
                     MAX(NVL(APPROVE_ID, '00')) APPROVE_ID,
                     MAX(APPROVE_DT) APPROVE_DT,
                     MAX(CASE
                           WHEN COLUMN_NAME = 'AFACCTNO' THEN
                            (CASE
                              WHEN ACTION_FLAG IN ('ADD') THEN
                               TO_VALUE
                              ELSE
                               FROM_VALUE
                            END)
                           ELSE
                            ''
                         END) AFACCTNO,
                     MAX(CASE
                           WHEN COLUMN_NAME = 'REFID' THEN
                            FROM_VALUE
                           ELSE
                            ''
                         END) OLD_REFAUTOID,
                     MAX(CASE
                           WHEN COLUMN_NAME = 'REFID' THEN
                            TO_VALUE
                           ELSE
                            ''
                         END) NEW_REFAUTOID,lnp.afacctno  lnpafacctno
                FROM MAINTAIN_LOG mn,LNPRMINTCF lnp
               WHERE TABLE_NAME = 'LNPRMINTCF'
                 AND approve_dt >= TO_DATE('11/09/2015', 'DD/MM/RRRR')
                 AND approve_dt >= TO_DATE(F_DATE, 'DD/MM/RRRR')
                 AND approve_dt <= TO_DATE(T_DATE, 'DD/MM/RRRR')
                 and mn.record_column_key = lnp.autoid(+)
               GROUP BY ACTION_FLAG, RECORD_KEY, MAKER_DT, MAKER_ID,lnp.afacctno) LG
       WHERE (LG.AFACCTNO = CF.ACCTNO or lg.lnpafacctno = CF.ACCTNO)
          AND  (case when  LG.ACTION_FLAG = 'ADD' then NVL(LG.NEW_REFAUTOID, 99999)
               else  NVL(LG.OLD_REFAUTOID, 99999)  end ) = ODPNEW.AUTOID
         AND LG.MAKER_ID = TLP1.TLID
         AND LG.APPROVE_ID = TLP2.TLID(+)
         AND LG.ACTION_FLAG = A1.CDVAL
         AND A1.CDNAME = 'ACTION_FLAG'
         AND A1.CDTYPE = 'SA'
         and NVL(CF.producttype,'A') like V_PV_AFTYPE
         AND (NVL(LG.NEW_REFAUTOID, 99999) LIKE V_POLYCY OR
            NVL(LG.OLD_REFAUTOID, 99999) LIKE V_POLYCY)

      union all
      SELECT LG.approve_dt    ACTIONDATE,
             CF.CUSTODYCD,
             AF.ACCTNO,
             AFT.TYPENAME,
             CF.FULLNAME,
             A1.CDCONTENT     ACTION,
            (CASE
               when A1.CDVAL = 'DELETE' then
                ODPNEW.FULLNAME
               else
                ' '
             end) POLICYNAME_OLD,
             (CASE
               when A1.CDVAL = 'DELETE' then
                TO_CHAR(ODPNEW.AUTOID)
               else
                ''
             end) POLICYID_OLD,
             (CASE
               when A1.CDVAL = 'ADD' then
                ODPNEW.FULLNAME
               else
                ''
             end)  POLICYNAME_NEW,
             (CASE
               when A1.CDVAL = 'ADD' then
                TO_CHAR(ODPNEW.AUTOID)
               else
                ''
             end) POLICYID_NEW,
             TLP1.TLFULLNAME  MAKERNAME,
             TLP2.TLFULLNAME  APPROVENAME
        FROM (SELECT *
                FROM CFMAST
               WHERE FNC_VALIDATE_SCOPE(BRID,
                                        CAREBY,
                                        TLSCOPE,
                                        pv_BRID,
                                        TLGOUPS) = 0
                 AND CUSTODYCD LIKE V_STRCUSTODYCD) CF,
             AFMAST AF,
             AFTYPE AFT,
             ADPRMFEEMST ODPNEW,
             TLPROFILES TLP1,
             TLPROFILES TLP2,
             ALLCODE A1,
             (SELECT ACTION_FLAG,
                     RECORD_KEY,
                     MAKER_DT,
                     MAKER_ID,
                     MAX(NVL(APPROVE_ID, '00')) APPROVE_ID,
                     MAX(APPROVE_DT) APPROVE_DT,
                     MAX(CASE
                           WHEN COLUMN_NAME = 'AFACCTNO' THEN
                            (CASE
                              WHEN ACTION_FLAG = 'ADD' THEN
                               TO_VALUE
                              ELSE
                               FROM_VALUE
                            END)
                           ELSE
                            ''
                         END) AFACCTNO,
                     MAX(CASE
                           WHEN COLUMN_NAME = 'PROMOTIONID' THEN
                            FROM_VALUE
                           ELSE
                            ''
                         END) OLD_REFAUTOID,
                     MAX(CASE
                           WHEN COLUMN_NAME = 'PROMOTIONID' THEN
                            TO_VALUE
                           ELSE
                            ''
                         END) NEW_REFAUTOID
                FROM MAINTAIN_LOG
               WHERE TABLE_NAME = 'ADPRMFEECF'
                 AND approve_dt >= TO_DATE('11/09/2015', 'DD/MM/RRRR')
                 AND approve_dt >= TO_DATE(F_DATE, 'DD/MM/RRRR')
                 AND approve_dt <= TO_DATE(T_DATE, 'DD/MM/RRRR')
               GROUP BY ACTION_FLAG, RECORD_KEY, MAKER_DT, MAKER_ID) LG
       WHERE LG.AFACCTNO = AF.ACCTNO
         AND AF.CUSTID = CF.CUSTID
         AND AF.ACTYPE = AFT.ACTYPE
         AND (NVL(LG.NEW_REFAUTOID, 99999) = ODPNEW.AUTOID OR  NVL(LG.OLD_REFAUTOID, 99999) = ODPNEW.AUTOID)
         AND LG.MAKER_ID = TLP1.TLID
         AND LG.APPROVE_ID = TLP2.TLID(+)
         AND LG.ACTION_FLAG = A1.CDVAL
         AND A1.CDNAME = 'ACTION_FLAG'
         AND A1.CDTYPE = 'SA'
         and af.producttype like V_PV_AFTYPE
         AND (NVL(LG.NEW_REFAUTOID, 99999) LIKE V_POLYCY OR
             NVL(LG.OLD_REFAUTOID, 99999) LIKE V_POLYCY)

      union all

      SELECT LG.approve_dt    ACTIONDATE,
             CF.CUSTODYCD,
             AF.ACCTNO,
             AFT.TYPENAME,
             CF.FULLNAME,
             A1.CDCONTENT     ACTION,
            (CASE
               when A1.CDVAL = 'DELETE' then
                ODPNEW.FULLNAME
               else
                ' '
             end) POLICYNAME_OLD,
             (CASE
               when A1.CDVAL = 'DELETE' then
                TO_CHAR(ODPNEW.AUTOID)
               else
                ''
             end) POLICYID_OLD,
             (CASE
               when A1.CDVAL = 'ADD' then
                ODPNEW.FULLNAME
               else
                ''
             end)  POLICYNAME_NEW,
             (CASE
               when A1.CDVAL = 'ADD' then
                TO_CHAR(ODPNEW.AUTOID)
               else
                ''
             end) POLICYID_NEW,
             TLP1.TLFULLNAME  MAKERNAME,
             TLP2.TLFULLNAME  APPROVENAME
        FROM (SELECT *
                FROM CFMAST
               WHERE FNC_VALIDATE_SCOPE(BRID,
                                        CAREBY,
                                        TLSCOPE,
                                        pv_BRID,
                                        TLGOUPS) = 0
                 AND CUSTODYCD LIKE V_STRCUSTODYCD) CF,
             AFMAST AF,
             AFTYPE AFT,
             MRPRMLIMITMST ODPNEW,
             TLPROFILES TLP1,
             TLPROFILES TLP2,
             ALLCODE A1,
             (SELECT ACTION_FLAG,
                     RECORD_KEY,
                     MAKER_DT,
                     MAKER_ID,
                     MAX(NVL(APPROVE_ID, '00')) APPROVE_ID,
                     MAX(APPROVE_DT) APPROVE_DT,
                     MAX(CASE
                           WHEN COLUMN_NAME = 'AFACCTNO' THEN
                            (CASE
                              WHEN ACTION_FLAG = 'ADD' THEN
                               TO_VALUE
                              ELSE
                               FROM_VALUE
                            END)
                           ELSE
                            ''
                         END) AFACCTNO,
                     MAX(CASE
                           WHEN COLUMN_NAME = 'PROMOTIONID' THEN
                            FROM_VALUE
                           ELSE
                            ''
                         END) OLD_REFAUTOID,
                     MAX(CASE
                           WHEN COLUMN_NAME = 'PROMOTIONID' THEN
                            TO_VALUE
                           ELSE
                            ''
                         END) NEW_REFAUTOID
                FROM MAINTAIN_LOG
               WHERE TABLE_NAME = 'MRPRMLIMITCF'
                 AND approve_dt >= TO_DATE('11/09/2015', 'DD/MM/RRRR')
                 AND approve_dt >= TO_DATE(F_DATE, 'DD/MM/RRRR')
                 AND approve_dt <= TO_DATE(T_DATE, 'DD/MM/RRRR')
               GROUP BY ACTION_FLAG, RECORD_KEY, MAKER_DT, MAKER_ID) LG
       WHERE LG.AFACCTNO = AF.ACCTNO
         AND AF.CUSTID = CF.CUSTID
         AND AF.ACTYPE = AFT.ACTYPE
         AND (NVL(LG.NEW_REFAUTOID, 99999) = ODPNEW.AUTOID OR NVL(LG.OLD_REFAUTOID, 99999) = ODPNEW.AUTOID)
         AND LG.MAKER_ID = TLP1.TLID
         AND LG.APPROVE_ID = TLP2.TLID(+)
         AND LG.ACTION_FLAG = A1.CDVAL
         AND A1.CDNAME = 'ACTION_FLAG'
         AND A1.CDTYPE = 'SA'
         and af.producttype like V_PV_AFTYPE
         AND (NVL(LG.NEW_REFAUTOID, 99999) LIKE V_POLYCY OR
             NVL(LG.OLD_REFAUTOID, 99999) LIKE V_POLYCY);
  end if;
EXCEPTION
  WHEN OTHERS THEN

    RETURN;
End;
 
 
 
 
/
