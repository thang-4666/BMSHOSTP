SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SE0057"(PV_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
                                     OPT          IN VARCHAR2,
                                     PV_BRID      IN VARCHAR2,
                                     TLGOUPS      IN VARCHAR2,
                                     TLSCOPE      IN VARCHAR2,
                                     F_DATE       IN VARCHAR2,
                                     T_DATE       IN VARCHAR2,
                                     TLTXCD       IN VARCHAR2,
                                     PV_COUNT     IN VARCHAR2) IS

  V_STROPTION VARCHAR2(5); -- A: ALL; B: BRANCH; S: SUB-BRANCH
  V_STRBRID   VARCHAR2(40); -- USED WHEN V_NUMOPTION > 0
  V_STRINBRID VARCHAR2(4);

  V_STRTLTXCD VARCHAR2(6);

  V_STRCOUNT VARCHAR2(20);
  l_FromDate date;
  l_ToDate   date;
  -- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN
  -- INSERT INTO TEMP_BUG(TEXT) VALUES('CF0001');COMMIT;
  V_STROPTION := upper(OPT);
  V_STRINBRID := PV_BRID;
  l_FromDate  := to_date(F_DATE, SYSTEMNUMS.C_DATE_FORMAT);
  l_ToDate    := to_date(T_DATE, SYSTEMNUMS.C_DATE_FORMAT);
  IF (V_STROPTION = 'A') THEN
    V_STRBRID := '%';
  ELSE
    if (V_STROPTION = 'B') then
      select brgrp.mapid
        into V_STRBRID
        from brgrp
       where brgrp.brid = V_STRINBRID;
    else
      V_STRBRID := V_STRINBRID;
    end if;
  END IF;

  IF (TLTXCD <> 'ALL') THEN
    V_STRTLTXCD := TLTXCD;
  ELSE
    V_STRTLTXCD := '%%';
  END IF;
  IF PV_COUNT != 0 THEN
  OPEN PV_REFCURSOR

  FOR
     SELECT (case  when se.symbol is null then 0 else tlg.MSGAMT end ) volume,
(case  when se.symbol is  null then  tlg.MSGAMT else 0 end ) amt,
       se.symbol,
       tlg.TLTXCD,
       tlg.TXDESC,
       tlg.TXDATE,
       tlg.BUSDATE,
       cf.custodycd,
       tlg.TXDATE - tlg.BUSDATE songay,
           usertao.tlfullname   usertao,
           userduyet.tlfullname userduyet,
           cf.fullname
      from (SELECT *
              FROM CFMAST
             WHERE FNC_VALIDATE_SCOPE(BRID,
                                      CAREBY,
                                      TLSCOPE,
                                      pv_BRID,
                                      TLGOUPS) = 0) cf,
           vw_tllog_all tlg,securities_info se,
           tlprofiles usertao,
           tlprofiles userduyet
     where
        tlg.TLID = usertao.tlid
       and tlg.OFFID = userduyet.tlid
       and cf.custodycd = tlg.CFCUSTODYCD
       and tlg.CCYUSAGE = se.codeid(+)
       and tlg.TXDATE - tlg.BUSDATE = to_number(PV_COUNT)
       and tlg.txdate between l_FromDate and l_ToDate
       and tlg.tltxcd like V_STRTLTXCD
     order by tlg.TXDATE, tlg.tltxcd;
     else
      OPEN PV_REFCURSOR

  FOR
     SELECT (case  when se.symbol is null then 0 else tlg.MSGAMT end ) volume,
(case  when se.symbol is  null then  tlg.MSGAMT else 0 end ) amt,
       se.symbol,
       tlg.TLTXCD,
       tlg.TXDESC,
       tlg.TXDATE,
       tlg.BUSDATE,
       cf.custodycd,
       tlg.TXDATE - tlg.BUSDATE songay,
           usertao.tlfullname   usertao,
           userduyet.tlfullname userduyet,
           cf.fullname
      from (SELECT *
              FROM CFMAST
             WHERE FNC_VALIDATE_SCOPE(BRID,
                                      CAREBY,
                                      TLSCOPE,
                                      pv_BRID,
                                      TLGOUPS) = 0) cf,
           vw_tllog_all tlg,securities_info se,
           tlprofiles usertao,
           tlprofiles userduyet
     where
        tlg.TLID = usertao.tlid
       and tlg.OFFID = userduyet.tlid
       and cf.custodycd = tlg.CFCUSTODYCD
       and tlg.CCYUSAGE = se.codeid(+)
       and tlg.TXDATE - tlg.BUSDATE >0
       and tlg.txdate between l_FromDate and l_ToDate
       and tlg.tltxcd like V_STRTLTXCD
     order by tlg.TXDATE,tlg.tltxcd;
END IF;
EXCEPTION
  WHEN OTHERS THEN

    RETURN;
End;
 
 
 
 
/
