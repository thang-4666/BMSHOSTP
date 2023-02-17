SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE cf1040(PV_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
                                   OPT          IN VARCHAR2,
                                   PV_BRID      IN VARCHAR2,
                                   TLGOUPS      IN VARCHAR2,
                                   TLSCOPE      IN VARCHAR2,
                                   PV_ACCTYPE   IN VARCHAR2,
                                   PV_CUSTODYCD IN VARCHAR2,
                                   I_BRID  IN VARCHAR2) IS
  --
  -- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
  --
  -- MODIFICATION HISTORY
  -- PERSON      DATE    COMMENTS
  -- NgocVTT edit 23/06/15
  -- ---------   ------  -------------------------------------------
  V_STROPTION VARCHAR2(5); -- A: ALL; B: BRANCH; S: SUB-BRANCH
  V_STRBRID   VARCHAR2(4);
  V_INBRID    VARCHAR2(4); -- USED WHEN V_NUMOPTION > 0
  V_PV_CUSTODYCD    VARCHAR2(15);
  V_I_BRID    VARCHAR2(10);

  -- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN
  V_STROPTION := upper(OPT);
  V_INBRID    := pv_BRID;

  IF (V_STROPTION = 'A') THEN
    V_STRBRID := '%';
  ELSE
    if (V_STROPTION = 'B') then
      select brgrp.mapid
        into V_STRBRID
        from brgrp
       where brgrp.brid = V_INBRID;
    else
      V_STRBRID := V_INBRID;
    end if;
  END IF;

    IF (PV_CUSTODYCD = 'ALL') THEN
        V_PV_CUSTODYCD := '%%';
    ELSE
        V_PV_CUSTODYCD := replace(PV_CUSTODYCD,'.');
    END IF;
    
    IF (I_BRID = 'ALL') THEN
        V_I_BRID := '%%';
    ELSE
        V_I_BRID := I_BRID;
    END IF;

  --- truong hop 1 ngay sinh bi null
  if (PV_ACCTYPE = '1') THEN
    OPEN PV_REFCURSOR FOR
      SELECT PV_ACCTYPE     PV_ACCTYPE,
             CF.BRID,
             CF.CUSTODYCD,
             CF.FULLNAME  FULLNAME,
             CF.IDCODE,
             CF.IDDATE,
             CF.IDPLACE,
             CF.DATEOFBIRTH,
             CF.ADDRESS,
             cf.mobilesms,
             cf.email,
             cf.bankacctno,
             cf.description,
             a.cdcontent    status
        FROM (SELECT *
                FROM CFMAST

               WHERE FNC_VALIDATE_SCOPE(BRID,
                                        CAREBY,
                                        TLSCOPE,
                                        pv_BRID,
                                        TLGOUPS) = 0

                 and UPPER(TRIM(replace(fullname,' '))) IN
                     (SELECT UPPER(TRIM(replace(fullname,' ')))
                        FROM cfmast
                       where dateofbirth is null
                       GROUP BY UPPER(TRIM(replace(fullname,' ')))
                      HAVING COUNT(fullname) > 1)
                ORDER BY   UPPER(TRIM(fullname))   desc   ) cf,
             ALLCODE a
       where a.cdval = cf.status
         and a.cdname = 'STATUS'
         and a.cdtype = 'CF'
         and dateofbirth is null
         and cf.brid like V_I_BRID
         and cf.CUSTODYCD like V_PV_CUSTODYCD
       order by UPPER(TRIM(replace(fullname,' '))) ,CF.DATEOFBIRTH    ;
  else
    -- trung ngay sinh
    OPEN PV_REFCURSOR FOR
      SELECT PV_ACCTYPE     PV_ACCTYPE,
             CF.BRID,
             CF.CUSTODYCD,
             CF.FULLNAME,
             CF.IDCODE,
             CF.IDDATE,
             CF.IDPLACE,
             CF.DATEOFBIRTH,
             CF.ADDRESS,
             cf.mobilesms,
             cf.email,
             cf.bankacctno,
             cf.description,
             a.cdcontent    status
        FROM (SELECT *
                FROM CFMAST

               WHERE FNC_VALIDATE_SCOPE(BRID,
                                        CAREBY,
                                        TLSCOPE,
                                        pv_BRID,
                                        TLGOUPS) = 0

              ) cf,
             (SELECT trim(upper(replace(cf.fullname,' '))) fullname ,cf.dateofbirth  FROM cfmast cf
    HAVING count(1) > 1
    GROUP BY  trim(upper(replace(cf.fullname,' '))),cf.dateofbirth) cf1,
             ALLCODE a
       where a.cdtype = 'CF'
         and a.cdval = cf.status
         and a.cdname = 'STATUS'
         and cf1.fullname = trim(upper(replace(cf.fullname,' ')))
         and cf1.dateofbirth = cf.dateofbirth
          and cf.brid like V_I_BRID
         and cf.CUSTODYCD like V_PV_CUSTODYCD
       order by trim(upper(replace(cf.fullname,' '))) ,CF.DATEOFBIRTH ;
  end if;
EXCEPTION
  WHEN OTHERS THEN
    --insert into temp_bug(text) values('CF0001');commit;
    RETURN;
END; -- PROCEDURE
 
 
 
 
/
