SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE cf0087 (
                                   PV_REFCURSOR     IN OUT  PKG_REPORT.REF_CURSOR,
                                   OPT              IN      VARCHAR2,
                                   PV_BRID          IN      VARCHAR2,
                                   TLGOUPS          IN      VARCHAR2,
                                   TLSCOPE          IN      VARCHAR2,
                                   F_DATE           IN      VARCHAR2,
                                   T_DATE           IN      VARCHAR2,
                                   PV_CUSTODYCD     IN      VARCHAR2,
                                   I_BRID           IN      VARCHAR2,
                                   PV_TLID          IN      VARCHAR2,
                                   PV_AFTYPE        IN      VARCHAR2,
                                   PV_STATUS        IN      VARCHAR2

 )
IS

--
-- PURPOSE: BAO CAO KHACH CO 2 TK
-- MODIFICATION HISTORY
-- PERSON      DATE      COMMENTS
-- DONT   23-08-2016   CREATED
-- ---------   ------  -------------------------------------------

   V_STROPTION          VARCHAR2(10);
   V_INBRID             VARCHAR2(10);
   V_STRBRID            varchar2(20);
   v_CUSTODYCD          VARCHAR2(20);
   v_BRID               VARCHAR2(20);
   v_TLID               VARCHAR2(20);
   v_AFTYPE             VARCHAR2(20);
   v_STATUS             VARCHAR2(20);
BEGIN
  /* V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (BRID <> 'ALL')
   THEN
      V_STRBRID := BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;
*/
    V_STROPTION := upper(OPT);
    V_INBRID := PV_BRID;
    if(V_STROPTION = 'A') then
        V_STRBRID := '%%';
    else
        if(V_STROPTION = 'B') then
            select br.brid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
    end if;

   -- GET REPORT'S PARAMETERS
    IF PV_CUSTODYCD = 'ALL' THEN
        v_CUSTODYCD := '%%';
    ELSE
        v_CUSTODYCD := PV_CUSTODYCD;
    END IF;

    IF I_BRID = 'ALL' THEN
        v_BRID := '%%';
    ELSE
        v_BRID := I_BRID;
    END IF;

    IF PV_TLID = 'ALL' THEN
        v_TLID := '%%';
    ELSE
        v_TLID := PV_TLID;
    END IF;

    IF PV_AFTYPE = 'ALL' THEN
        v_AFTYPE := '%%';
    ELSE
        v_AFTYPE := PV_AFTYPE;
    END IF;

    IF PV_STATUS = 'ALL' THEN
        v_STATUS := '%%';
    ELSE
        v_STATUS := PV_STATUS;
    END IF;
   -- GET REPORT'S DATA

    OPEN PV_REFCURSOR
    FOR
         SELECT cf.custodycd, cf.fullname, A1.cdcontent aftype, cf.idcode, br.brname, A2.cdcontent status,
            nvl(ma.maker, ' ') maker, cf.opndate approve_dt
            FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, allcode A1, brgrp br, allcode A2,
                (SELECT idcode FROM cfmast HAVING count(idcode) >=2 GROUP BY idcode) id,
                (SELECT SUBSTR (ma.record_key, 11, 10) custid, ma.to_value, ma.maker_id, NVL (tl.tlname, '') maker, ma.approve_dt
                  FROM maintain_log ma, tlprofiles tl
                 WHERE     ma.table_name = 'CFMAST'
                       AND ma.column_name = 'IDCODE'
                       AND ma.action_flag = 'ADD'
                       AND NVL (ma.maker_id, 'XXX') = tl.tlid(+)) ma
            WHERE cf.idcode = id.idcode
                AND A1.cdname = 'CUSTTYPE'
                AND A1.cdtype = 'CF'
                AND A1.cdval = cf.custtype
                AND br.brid = cf.brid
                AND A2.cdname = 'STATUS'
                AND A2.cdtype = 'CF'
                AND A2.cdval = cf.status
                AND nvl(cf.opndate,'01-jan-2050') >= to_date(F_DATE, 'DD/MM/RRRR')
                AND nvl(cf.opndate,'01-jan-1999') <= to_date(T_DATE, 'DD/MM/RRRR')
                AND nvl(cf.custodycd,'%%') LIKE v_CUSTODYCD
                AND cf.brid LIKE v_BRID
                AND nvl(ma.maker, ' ') LIKE v_TLID
                AND (CASE WHEN CF.CUSTTYPE = 'I' THEN '001'
                            WHEN CF.CUSTTYPE = 'B' THEN '002' END) LIKE v_AFTYPE
                AND cf.status LIKE v_STATUS
                AND cf.custid = ma.custid(+)
            ORDER BY IDCODE;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
 
 
 
/
