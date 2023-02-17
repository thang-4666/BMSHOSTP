SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE se0058(PV_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
                                     OPT          IN VARCHAR2,
                                     PV_BRID      IN VARCHAR2,
                                     TLGOUPS      IN VARCHAR2,
                                     TLSCOPE      IN VARCHAR2,
                                     I_DATE       IN VARCHAR2,
                                     I_BRID       IN VARCHAR2,
                                     MAKER        IN VARCHAR2
                                     
                                     ) IS

  -- RP NAME : BAO CAO BANG KE CHUNG KHOAN GIAO DICH LO LE
  -- PERSON : NGOCVTT
  -- DATE : 23/04/2015
  -- ---------   ------  -------------------------------------------

  V_STRSYMBOL VARCHAR2(20);

  V_INBRID    VARCHAR2(4);
  V_STRBRID   VARCHAR2(50);
  V_STROPTION VARCHAR2(5);

  V_I_BRIDGD VARCHAR2(100);
  V_MAKER    NVARCHAR2(400);
  l_IDate    DATE;

BEGIN
  l_IDate := to_date(I_DATE, SYSTEMNUMS.C_DATE_FORMAT);
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

  if (upper(MAKER) = 'ALL' OR LENGTH(MAKER) < 1) then
    V_MAKER := '%';
  else
    V_MAKER := UPPER(MAKER);
  end if;
  IF (I_BRID <> 'ALL' OR I_BRID <> '') THEN
    V_I_BRIDGD := I_BRID;
  ELSE
    V_I_BRIDGD := '%%';
  END IF;

  -- GET REPORT'S DATA

  OPEN PV_REFCURSOR for
  
    select (CASE
             WHEN instr(tl.symbol, '_WFT') = 0 THEN
              1
             ELSE
              7
           END) LOAICP,
           tl.volume,
           cf.fullname, -- ten nhadt chuyen
           cf.custodycd,-- so tk ndt chuyen
           cf.idcode, -- so dtsh ndt chuyen
           cf.iddate, -- ngay cap ndt chuyen
           '1' idtype, -- loai dksh ndt chuyen VA NHAN
           TL.TENNDTNHAN,
           TL.SDKSHDTNHAN,
           TL.NGAYCAPDTNHAN,
           TL.TAIKHOANNDTNHAN,
           CF.brid,
           TL.SYMBOL,
           'ff' CHINHANH,
           'GD' MAGD
           
      from (SELECT *
              FROM CFMAST
             WHERE FNC_VALIDATE_SCOPE(BRID,
                                      CAREBY,
                                      TLSCOPE,
                                      pv_BRID,
                                      TLGOUPS) = 0) cf,
           (select tg.autoid, tg.tlid, tg.offid, tg.tltxcd, tf.*
              from VW_TLLOG_ALL tg,
                   (select txnum,
                           txdate,
                           max(decode(fldcd, '15', cvalue, null)) custodycd,
                           max(decode(fldcd, '10', nvalue, null)) volume,
                           max(decode(fldcd, '23', cvalue, null)) SYMBOL,
                           max(decode(fldcd, '49', cvalue, null)) TENNDTNHAN,
                           max(decode(fldcd, '50', cvalue, null)) SDKSHDTNHAN,
                           max(decode(fldcd, '51', cvalue, null)) NGAYCAPDTNHAN,
                           max(decode(fldcd, '88', cvalue, null)) TAIKHOANNDTNHAN
                      from VW_tllogfld_all
                     group by txnum, txdate) tf
             where tg.txnum = tf.txnum
               and tg.txdate = tf.txdate
               and tg.txdate = l_IDate
               and tg.tltxcd in ('2244')) tl
          
    
     where cf.custodycd = tl.custodycd
       and tl.tlid like V_MAKER
       and cf.brid like V_I_BRIDGD
    --  and cf.custodycd like V_STRCUSTODYCD
    ;

EXCEPTION
  WHEN OTHERS THEN
    RETURN;
END;
 
/
