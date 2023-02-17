SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "FO9007"(PV_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
                                     OPT          IN VARCHAR2,
                                     pv_BRID      IN VARCHAR2,
                                     TLGOUPS      IN VARCHAR2,
                                     TLSCOPE      IN VARCHAR2,
                                     SYMBOL       IN VARCHAR2,
                                     I_DATE       IN VARCHAR2) IS
  --
  -- PURPOSE: BAO CAO DANH SACH NGUOI SO HUU CHUNG KHOAN LUU KY
  -- MODIFICATION HISTORY
  -- PERSON      DATE      COMMENTS
  -- QUOCTA   15-12-2011   CREATED
  -- ---------   ------  -------------------------------------------
  V_STROPTION VARCHAR2(5);
  V_STRBRID   VARCHAR2(40);
  V_INBRID    VARCHAR2(4);
  V_SYMBOL    VARCHAR2(40);
BEGIN
  V_STROPTION := upper(OPT);
  V_INBRID    := pv_BRID;

  IF (V_STROPTION = 'A') THEN
    V_STRBRID := '%';
  ELSif (V_STROPTION = 'B') then
    select brgrp.mapid
      into V_STRBRID
      from brgrp
     where brgrp.brid = V_INBRID;
  else
    V_STRBRID := V_INBRID;
  END IF;

  IF (SYMBOL <> 'ALL') THEN
    V_SYMBOL := SYMBOL;
  ELSE
    V_SYMBOL := '%%';
  END IF;

  -- GET REPORT'S DATA

  OPEN PV_REFCURSOR FOR
    SELECT T.WININTEREST Winrate,
           t.term,
           T.TOALWINAMOUNT/1000000000  TOALWINAMOUNT, --tong gia tri trung thau
           T.BIDQTTY/1000000000  BIDQTTY,-- tong gia tri dang ky
           cust.WINQTTY/1000000000  Registeredamount,
            (case when  T.TOALWINAMOUNT != 0 then   100*round(cust.WINQTTY/T.TOALWINAMOUNT,6)
          else 0
            end ) WinningVolume ,
           I_DATE I_DATE
      FROM BONDIPO T,
      (SELECT sum(WINQTTY) WINQTTY,
                   BONDID
              FROM bondcust K
             group by BONDID) cust
  WHERE
   t.ISSTMPDATE = to_date(I_DATE,'dd/MM/rrrr')
 and  t.bondid = cust.BONDID
  and t.CODEID like V_SYMBOL
  order by t.term;
  EXCEPTION WHEN OTHERS THEN
    RETURN;
END;
 
 
 
 
/
