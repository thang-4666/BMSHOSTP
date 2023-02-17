SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE CI1042 (
                                   PV_REFCURSOR         IN OUT   PKG_REPORT.REF_CURSOR,
                                   OPT                  IN       VARCHAR2,
                                   pv_BRID              IN       VARCHAR2,
                                   TLGOUPS              IN       VARCHAR2,
                                   TLSCOPE              IN       VARCHAR2,
                                   F_DATE             IN       VARCHAR2,
                                   T_DATE             IN       VARCHAR2,
                                   PV_IBRID             IN       VARCHAR2,
                                   PV_CUSTODYCD         IN       VARCHAR2,
                                     TLTXCD               IN       VARCHAR2,
                                   MAKER                IN       VARCHAR2,
                                   CHECKER              IN       VARCHAR2,
                                   STATUS               IN       VARCHAR2
                                  
                                   )
IS
--
-- BAO CAO KHACH HANG THU PHI LUU KY 2 LAN
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- DONT     24-AUG-16  CREATED
-- ---------   ------  -------------------------------------------
    CUR             PKG_REPORT.REF_CURSOR;
    V_STROPTION     VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
    V_STRBRID       VARCHAR2 (4);
    V_CUSTODYCD     VARCHAR2 (20);
    V_IBRID         VARCHAR2(10);
     V_TLTXCD        VARCHAR2(10);
    V_MAKER         VARCHAR2(10);
    V_CHECKER        VARCHAR2(10);
    V_STATUS        VARCHAR2(10);
    
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

    IF (PV_IBRID = 'ALL') THEN
        V_IBRID := '%%';
    ELSE
        V_IBRID := PV_IBRID;
    END IF;

     IF (TLTXCD = 'ALL') THEN
        V_TLTXCD := '%%';
    ELSE
        V_TLTXCD := TLTXCD;
    END IF;

     IF (MAKER = 'ALL') THEN
        V_MAKER := '%%';
    ELSE
        V_MAKER := MAKER;
    END IF;

     IF (CHECKER = 'ALL') THEN
        V_CHECKER := '%%';
    ELSE
        V_CHECKER := CHECKER;
    END IF;
     IF (STATUS = 'ALL') THEN
        V_STATUS := '%%';
    ELSE
        V_STATUS := STATUS;
    END IF;
    

    OPEN PV_REFCURSOR
    FOR
        SELECT '1' groupt, vw1.tltxcd, br.brname, cf.custodycd, ci.namt msgamt, vw1.busdate, nvl(tl1.tlname, ' ') maker, nvl(tl2.tlname, ' ') checker,
            A1.cdcontent status, A2.cdcontent txstatus, ci.txdesc note
            FROM vw_tllog_all vw1, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,
				(select txnum, txdate, txdesc, namt
                from vw_citran_gen
                where tltxcd in ('1180', '1182', '1189')
                    AND field = 'BALANCE'
                    AND txtype = 'D'
                    AND tltxcd like v_tltxcd
				union all
				SELECT txnum, txdate, txdesc, namt
				FROM vw_citran_gen
				WHERE tltxcd = '0088'
					AND txcd = '0011'
					AND txtype = 'D'
					AND field = 'BALANCE'
					AND trdesc LIKE '%phi luu ky%'	) ci,
				afmast af, brgrp br, allcode A1, allcode A2, tlprofiles tl1, tlprofiles tl2,
                       (SELECT cf.custodycd,  COUNT (cf.custodycd) dem
                          FROM vw_tllog_all tl, afmast af, cfmast cf
                         WHERE tl.tltxcd IN ('1180', '1189', '1182', '0088')
                              AND tl.busdate >= to_date(F_DATE, 'DD/MM/RRRR')
                              AND tl.busdate <= to_date(T_DATE, 'DD/MM/RRRR')
							  AND msgacct = af.acctno
                              AND af.custid = cf.custid
                        GROUP BY cf.custodycd
                        HAVING COUNT (cf.custodycd) >= 2) vw
            WHERE vw1.msgacct = af.acctno
            AND vw1.tltxcd IN ('1180', '1189', '1182', '0088')
            AND cf.custid = af.custid
            AND vw1.tltxcd like v_tltxcd
            and vw1.TLID like V_MAKER
            and nvl(vw1.OFFID,'A') like V_CHECKER
            and cf.status like v_status
            AND cf.custodycd = vw.custodycd
            AND cf.brid = br.brid
            AND vw1.tlid = tl1.tlid(+)
            AND vw1.offid = tl2.tlid(+)
			AND ci.txnum = vw1.txnum
			and ci.txdate = vw1.txdate
            AND A1.cdtype = 'CF'
            AND A1.cdname = 'STATUS'
            AND A1.cdval = cf.status
            AND A2.cdtype = 'SY'
            AND A2.cdname = 'TXSTATUS'
            AND A2.cdval = vw1.txstatus
            AND cf.brid LIKE V_IBRID
            AND cf.custodycd LIKE V_CUSTODYCD
            AND vw1.busdate >= to_date(F_DATE, 'DD/MM/RRRR')
            AND vw1.busdate <= to_date(T_DATE, 'DD/MM/RRRR')
            ORDER BY cf.custodycd, vw1.busdate, vw1.tltxcd;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE
 
 
 
 
/
