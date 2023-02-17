SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE CF1047 (
                                   PV_REFCURSOR         IN OUT   PKG_REPORT.REF_CURSOR,
                                   OPT                  IN       VARCHAR2,
                                   pv_BRID              IN       VARCHAR2,
                                   TLGOUPS              IN       VARCHAR2,
                                   TLSCOPE              IN       VARCHAR2,
                                   PV_FRDATE            IN       VARCHAR2,
                                   PV_TODATE            IN       VARCHAR2,
                                   PV_IBRID             in       VARCHAR2,
                                   PV_CUSTODYCD         IN       VARCHAR2,
                                   PV_CFTYPE            in       VARCHAR2,
                                    PV_ODPROBK          in       VARCHAR2,
                                   PV_MAKER             IN       VARCHAR2,
                                   PV_CHECKER           IN       VARCHAR2
                                   )
IS
--
-- BAO CAO DANH SACH KHACH HANG DA DONG CO HANG DAC BIET
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- DONT     22-AUG-16  CREATED
-- ---------   ------  -------------------------------------------
    CUR             PKG_REPORT.REF_CURSOR;
    V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
    V_STRBRID      VARCHAR2 (4);
    V_CUSTODYCD     VARCHAR2 (20);
    v_maker         varchar2(20);
    v_checker       varchar2(20);
    v_cftype        varchar2(20);
    v_odprobk       varchar2(20);
    v_ibrid         varchar2(20);
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

    IF (PV_MAKER = 'ALL') THEN
        v_maker := '%%';
    ELSE
        v_maker := PV_MAKER;
    END IF;

    IF (PV_CHECKER = 'ALL') THEN
        v_checker := '%%';
    ELSE
        v_checker := PV_CHECKER;
    END IF;

    IF (PV_CFTYPE = 'ALL') THEN
        v_cftype := '%%';
    ELSE
        v_cftype := PV_CFTYPE;
    END IF;

    IF (PV_ODPROBK = 'ALL') THEN
        v_odprobk := '%%';
    ELSE
        v_odprobk := PV_ODPROBK;
    END IF;

    IF (PV_IBRID = 'ALL') THEN
        v_ibrid := '%%';
    ELSE
        v_ibrid := PV_IBRID;
    END IF;

    OPEN PV_REFCURSOR
    FOR
       select * from ( 
       -- lay tai khoan co trong chinh sach phi moi gioi va khong thuoc hang co trong danh sach
       SELECT cf.custodycd, cf.custid, cf.fullname, cf.idcode, cf.cfclsdate, tl.txtime, tl1.tlname maker, tl2.tlname checker,
            brg.brname,  A1.cdcontent status, cft.typename, mst.fullname fee_name
        FROM (SELECT MAX(txtime) txtime, max(tlid) tlid, max(offid) offid, msgacct
                FROM vw_tllog_all
                WHERE tltxcd = '0059'
                GROUP BY msgacct )tl,
            brgrp brg,
            (SELECT refautoid, cf.custid ,max(af.acctno) acctno
                FROM odprobrkaf, afmast af, cfmast cf
                WHERE af.custid = cf.custid
                AND af.acctno = odprobrkaf.afacctno
                GROUP BY refautoid,cf.custid) br,  odprobrkmst mst,
            tlprofiles tl1, tlprofiles tl2, allcode A1, cftype cft,
           (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF
        WHERE tl.msgacct = cf.custid
            AND cf.status = 'C'
            AND cf.brid = brg.brid
            AND tl1.tlid = tl.tlid
            AND tl2.tlid = tl.tlid
            and cf.custid = br.custid
            AND br.refautoid = mst.autoid 
            AND A1.cdtype = 'CF'
            AND A1.cdname = 'STATUS'
            AND A1.cdval = cf.status
            AND cf.actype =  cft.actype
            AND cf.custodycd LIKE V_CUSTODYCD
            AND tl.tlid LIKE v_maker
            AND tl.offid LIKE v_checker
            AND cf.brid LIKE v_ibrid
            AND mst.autoid like v_odprobk
            and cft.actype like v_cftype
            and cft.actype  not in  ('0001', '0008', '0014', '0000', '0009', '0015', '0007','0021')
            
            union all
            -- lay tai khoan khong thuoc hang liet ke khong co chinh sach phi
            SELECT cf.custodycd, cf.custid, cf.fullname, cf.idcode, cf.cfclsdate, tl.txtime, tl1.tlname maker, tl2.tlname checker,
            brg.brname,  A1.cdcontent status, cft.typename, NULL fee_name
        FROM (SELECT MAX(txtime) txtime, max(tlid) tlid, max(offid) offid, msgacct
                FROM vw_tllog_all
                WHERE tltxcd = '0059'
                GROUP BY msgacct )tl,
            brgrp brg,
            tlprofiles tl1, tlprofiles tl2, allcode A1, cftype cft,
           (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF
        WHERE tl.msgacct = cf.custid
            AND cf.status = 'C'
            AND cf.brid = brg.brid
            AND tl1.tlid = tl.tlid
            AND tl2.tlid = tl.tlid
            
            and cf.custid not in (SELECT cf.custid 
                FROM odprobrkaf, afmast af, cfmast cf
                WHERE af.custid = cf.custid
                AND af.acctno = odprobrkaf.afacctno 
                GROUP by cf.custid  )
                
            AND A1.cdtype = 'CF'
            AND A1.cdname = 'STATUS'
            AND A1.cdval = cf.status
            AND cf.actype =  cft.actype
            AND cf.custodycd LIKE V_CUSTODYCD
            AND tl.tlid LIKE v_maker
            AND tl.offid LIKE v_checker
            AND cf.brid LIKE v_ibrid
           
            and cft.actype like v_cftype
            and cft.actype   not in   ('0001', '0008', '0014', '0000', '0009', '0015', '0007','0021')
            
            union all
            -- khach hang co chinh sach phi thuoc hang khong co trong sach sach
             SELECT cf.custodycd, cf.custid, cf.fullname, cf.idcode, cf.cfclsdate, tl.txtime, tl1.tlname maker, tl2.tlname checker,
            brg.brname,  A1.cdcontent status, cft.typename, mst.fullname fee_name
        FROM (SELECT MAX(txtime) txtime, max(tlid) tlid, max(offid) offid, msgacct
                FROM vw_tllog_all
                WHERE tltxcd = '0059'
                GROUP BY msgacct )tl,
            brgrp brg,
            (SELECT refautoid, cf.custid ,max(af.acctno) acctno
                FROM odprobrkaf, afmast af, cfmast cf
                WHERE af.custid = cf.custid
                AND af.acctno = odprobrkaf.afacctno
                GROUP BY refautoid,cf.custid) br,  odprobrkmst mst,
            tlprofiles tl1, tlprofiles tl2, allcode A1, cftype cft,
           (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF
        WHERE tl.msgacct = cf.custid
            AND cf.status = 'C'
            AND cf.brid = brg.brid
            AND tl1.tlid = tl.tlid
            AND tl2.tlid = tl.tlid
            and cf.custid = br.custid
            AND br.refautoid = mst.autoid 
            AND A1.cdtype = 'CF'
            AND A1.cdname = 'STATUS'
            AND A1.cdval = cf.status
            AND cf.actype =  cft.actype
            AND cf.custodycd LIKE V_CUSTODYCD
            AND tl.tlid LIKE v_maker
            AND tl.offid LIKE v_checker
            AND cf.brid LIKE v_ibrid
            AND mst.autoid like v_odprobk
            and cft.actype like v_cftype
            and cft.actype   in  ('0001', '0008', '0014', '0000', '0009', '0015', '0007','0021')
            
         
        ) t where 1=1
        group by t.custodycd, t.custid, t.fullname, t.idcode, t.cfclsdate, t.txtime, t.maker, t.checker,
            t.brname,  t.status, t.typename, t.fee_name  order by t.custodycd;
        

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE
 
 
 
 
/
