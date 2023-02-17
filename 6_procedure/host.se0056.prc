SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE se0056(PV_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
                                     OPT          IN VARCHAR2,
                                     PV_BRID      IN VARCHAR2,
                                     TLGOUPS      IN VARCHAR2,
                                     TLSCOPE      IN VARCHAR2,
                                     F_DATE       IN VARCHAR2,
                                     T_DATE       IN VARCHAR2,
                                     PV_CUSTODYCD IN VARCHAR2,
                                     I_BRIDGD     IN VARCHAR2,
                                     TLTXCD       IN VARCHAR2,
                                     MAKER        IN VARCHAR2,
                                     CHECKER      IN VARCHAR2

                                     ) IS

  -- RP NAME : BAO CAO BANG KE CHUNG KHOAN GIAO DICH LO LE
  -- PERSON : NGOCVTT
  -- DATE : 23/04/2015
  -- ---------   ------  -------------------------------------------

  V_STRCUSTODYCD VARCHAR2(15);

  V_STRSYMBOL VARCHAR2(20);

  V_INBRID    VARCHAR2(4);
  V_STRBRID   VARCHAR2(50);
  V_STROPTION VARCHAR2(5);

  V_I_BRIDGD VARCHAR2(100);
  V_BRNAME   NVARCHAR2(400);
  l_FromDate DATE;
  V_TLTXCD VARCHAR2(10);
  V_MAKER VARCHAR2(10);
  V_CHECKER VARCHAR2(10);

  l_ToDate DATE;
BEGIN
  l_FromDate := to_date(F_DATE, SYSTEMNUMS.C_DATE_FORMAT);
  l_ToDate   := to_date(T_DATE, SYSTEMNUMS.C_DATE_FORMAT);
  -- GET REPORT'S PARAMETERS
  V_STROPTION := upper(OPT);
  V_INBRID    := PV_BRID;
  if (V_STROPTION = 'A') then
    V_STRBRID := '%%';
  else
    if (V_STROPTION = 'B') then
      select br.BRID into V_STRBRID from brgrp br where br.brid = V_INBRID;
    else
      V_STRBRID := V_INBRID;
    end if;
  end if;

  if (upper(PV_CUSTODYCD) = 'ALL' OR LENGTH(PV_CUSTODYCD) < 1) then
    V_STRCUSTODYCD := '%';
  else
    V_STRCUSTODYCD := UPPER(PV_CUSTODYCD);
  end if;
  IF (I_BRIDGD <> 'ALL' OR I_BRIDGD <> '') THEN
    V_I_BRIDGD := I_BRIDGD;
  ELSE
    V_I_BRIDGD := '%%';
  END IF;

  IF (TLTXCD <> 'ALL' OR TLTXCD <> '') THEN
    V_TLTXCD := TLTXCD;
  ELSE
    V_TLTXCD := '%%';
  END IF;

  IF (MAKER <> 'ALL' OR MAKER <> '') THEN
    V_MAKER := MAKER;
  ELSE
    V_MAKER := '%%';
  END IF;

  IF (CHECKER <> 'ALL' OR CHECKER <> '') THEN
    V_CHECKER := CHECKER;
  ELSE
    V_CHECKER := '%%';
  END IF;

  IF (I_BRIDGD <> 'ALL' OR I_BRIDGD <> '') THEN
    BEGIN
      SELECT BRID INTO V_BRNAME FROM BRGRP WHERE BRID LIKE I_BRIDGD;
    END;
  ELSE
    V_BRNAME := 'ALL';
  END IF;

  -- GET REPORT'S DATA

  OPEN PV_REFCURSOR for

    select cf.fullname,
           tl.txdesc,
           tl.txdate,
           tl.txtime,
           tl.TLTXCD,
           cf.custodycd,
           t.txdesc             magd,
           cf.brid,
           tl.CHKTIME,
           usertao.tlfullname   usertao,
           userduyet.tlfullname userduyet,
           a.cdcontent          status,
           tl.amt,
           a1.cdcontent  TXSTATUS
      from (SELECT *
              FROM CFMAST
             WHERE FNC_VALIDATE_SCOPE(BRID,
                                      CAREBY,
                                      TLSCOPE,
                                      pv_BRID,
                                      TLGOUPS) = 0) cf,
           (select tg.autoid,
                   tg.tlid,
                   tg.offid,
                   tg.tltxcd,
                   tg.TXTIME,
                   tg.CHKTIME,
                   tg.txstatus,
                   tg.txdate,
                   tg.msgamt AMT,tg.cfcustodycd custodycd ,tg.txdesc txdesc,tg.deltd
              from  (select * from TLLOG union all select * from tllogall) tg

             where
               --and tg.TXSTATUS = 1
                tg.txdate between l_FromDate and l_ToDate
               and tg.tltxcd in ('1180', '1189')
               and tg.TLID like V_MAKER
               and nvl(tg.OFFID,'A') like V_CHECKER
               and tg.tltxcd like V_TLTXCD) tl,
           allcode a,allcode a1,
           tltx t,
           tlprofiles usertao,
           tlprofiles userduyet

     where cf.custodycd = tl.custodycd
       and a.cdname = 'STATUS'
       and a1.cdname = 'TXSTATUS'
       and a1.cdval = decode (TL.deltd,'Y','9','N',TL.TXSTATUS)
       and a.cdval = cf.status
       and a.cdtype = 'CF'
       and t.tltxcd = tl.TLTXCD
       and usertao.tlid = tl.TLID
       and  tl.OFFID=userduyet.tlid (+)
       and cf.brid like V_I_BRIDGD
       and cf.custodycd like V_STRCUSTODYCD;

EXCEPTION
  WHEN OTHERS THEN
    RETURN;
END;
 
/
