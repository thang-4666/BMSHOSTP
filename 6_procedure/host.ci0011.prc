SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE ci0011 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PV_MAKER       IN       VARCHAR2,
   PV_CHECKER       IN       VARCHAR2,
   I_BRIDGD       IN       VARCHAR2,
   PV_AFTYPE      IN       VARCHAR2,
   PV_BANKCODE    IN       VARCHAR2
 )
IS
--

-- ---------   ------  -------------------------------------------
   V_STROPTION     VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH


   V_INBRID        VARCHAR2(4);
   V_STRBRID      VARCHAR2 (50);
   V_STRCUSTODYCD   VARCHAR2 (20);

   v_strmaker   varchar2(10);
   V_STRCHECKER   varchar2(10);

   L_STRAFTYPE        varchar2(20);
   V_I_BRIDGD          VARCHAR2(100);
   V_BRNAME            NVARCHAR2(400);
   V_BANKCODE          VARCHAR2(100);




BEGIN

   V_STROPTION := upper(OPT);
   V_INBRID := pv_BRID;
    if(V_STROPTION = 'A') then
        V_STRBRID := '%%';
    else
        if(V_STROPTION = 'B') then
            select br.BRID into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
    end if;

   -- GET REPORT'S PARAMETERS

    if(upper(PV_CUSTODYCD) = 'ALL' or LENGTH(PV_CUSTODYCD) <= 1 ) then
        V_STRCUSTODYCD := '%';
    else
        V_STRCUSTODYCD := PV_CUSTODYCD;
    end if;

    if(UPPER(PV_MAKER) = 'ALL' or LENGTH(PV_MAKER) <= 1 ) THEN
        v_strmaker := '%';
    else
        v_strmaker := PV_MAKER;
    end if;

    if(UPPER(PV_CHECKER) = 'ALL' or LENGTH(PV_CHECKER) <= 1 ) THEN
        v_strchecker := '%';
    else
        v_strchecker := PV_CHECKER;
    end if;

    if(UPPER(PV_BANKCODE) = 'ALL' or LENGTH(PV_BANKCODE) <= 1 ) THEN
        V_BANKCODE := '%';
    else
        V_BANKCODE := PV_BANKCODE;
    end if;

   IF (PV_AFTYPE IS NULL OR UPPER(PV_AFTYPE) = 'ALL')
   THEN
      L_STRAFTYPE := '%';
   ELSE
      L_STRAFTYPE := PV_AFTYPE;
   END IF;


      IF (I_BRIDGD <> 'ALL' OR I_BRIDGD <> '')
   THEN
      V_I_BRIDGD :=  I_BRIDGD;
   ELSE
      V_I_BRIDGD := '%%';
   END IF;

   IF (I_BRIDGD <> 'ALL' OR I_BRIDGD <> '')
   THEN
      BEGIN
            SELECT BRNAME INTO V_BRNAME FROM BRGRP WHERE BRID LIKE I_BRIDGD;
      END;
   ELSE
      V_BRNAME   :=  ' Toan cty ';
   END IF;

   -- GET REPORT'S DATA

OPEN  PV_REFCURSOR FOR
/*
select CF.BRID, A0.CDCONTENT PRODUC, REMT.TXNUM,TLP.TLNAME MAKER, TLP1.TLNAME CHECKER,V_STRCUSTODYCD CUST,
     REMT.TXDATE searchdate, cf.custodycd f_tkluuky, af.acctno f_sotk, cf.fullname f_tenkh,
    remt.benefcustname t_nguoinhan, remt.beneflicense t_cmnd, remt.benefiddate t_ngaycap,
    remt.benefidplace t_noicap, remt.benefacct t_sotk,
    remt.benefbank || ' - ' || remt.citybank || ' - ' || remt.cityef t_nhnhan,
    REMT.AMT-REMT.FEEAMT-REMT.VAT Sotien, tl.txdesc noidung, BA.FULLNAME BANK
from ciremittance remt,BANKNOSTRO BA,
    (
        SELECT  tr.ref, NVL(FLD.CVALUE,0) BANK, FLD3.CVALUE
        FROM    vw_citran_gen tr,VW_TLLOGFLD_ALL FLD,VW_TLLOGFLD_ALL FLD3
        where tr.tltxcd = '1104' AND TR.TXCD='0043' AND TR.DELTD<>'Y'
        AND TR.TXNUM=FLD.TXNUM AND TR.TXDATE=FLD.TXDATE AND FLD.FLDCD='05'
        AND TR.TXNUM=FLD3.TXNUM AND TR.TXDATE=FLD3.TXDATE AND FLD3.FLDCD='07'
        and tr.txdate = getcurrdate and fld.txdate = getcurrdate and fld3.txdate = getcurrdate
        AND FLD.CVALUE LIKE V_BANKCODE
    )  tr, afmast af, AFTYPE AFT, ALLCODE A0,TLPROFILES TLP, TLPROFILES TLP1,
    (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, vw_citran_gen tl
where tr.ref = remt.potxnum
    AND REMT.RMSTATUS<>'R' AND TL.deltd <>'Y'
    AND TR.CVALUE=REMT.TXNUM
    and tl.tltxcd in ('1101')
    AND NVL(TR.BANK,'00')=BA.SHORTNAME(+)
    and tl.field = 'FLOATAMT'
    and tl.txtype = 'C'
    and remt.txdate = tl.txdate
    and remt.txnum = tl.txnum
    and remt.acctno = af.acctno
    and af.custid = cf.custid
    AND AF.ACTYPE=AFT.ACTYPE
    AND TL.TLID=TLP.TLID(+)
    AND NVL(TL.offid,'000')=TLP1.TLID(+)
    AND A0.CDTYPE='CF' AND A0.CDNAME='PRODUCTTYPE' AND A0.CDVAL=AFT.PRODUCTTYPE
    AND CF.CUSTODYCD LIKE V_STRCUSTODYCD
    AND CF.BRID LIKE V_I_BRIDGD
    AND TL.tlid LIKE v_strmaker
    AND TL.TXDATE BETWEEN TO_DATE(F_DATE,'DD/MM/YYYY') AND TO_DATE(T_DATE,'DD/MM/YYYY')
    AND AFT.PRODUCTTYPE LIKE L_STRAFTYPE
    ORDER BY TL.TXDATE,CF.CUSTODYCD; */

SELECT MST.BRID, MST.PRODUC, MST.TXNUM, MST.MAKER, MST.CHECKER, MST.CUST,
    MST.searchdate, MST.f_tkluuky, MST.f_sotk, MST.f_tenkh,
    MST.t_nguoinhan, MST.t_cmnd, MST.t_ngaycap, MST.t_noicap, MST.t_sotk,
    MST.t_nhnhan, MST.Sotien, MST.noidung, BA.FULLNAME BANK
FROM (
    select CF.BRID, A0.CDCONTENT PRODUC, REMT.TXNUM,TLP.TLNAME MAKER, TLP1.TLNAME CHECKER,V_STRCUSTODYCD CUST,
         REMT.TXDATE searchdate, cf.custodycd f_tkluuky, af.acctno f_sotk, cf.fullname f_tenkh,
        remt.benefcustname t_nguoinhan, remt.beneflicense t_cmnd, remt.benefiddate t_ngaycap,
        remt.benefidplace t_noicap, remt.benefacct t_sotk,
        remt.benefbank || ' - ' || remt.citybank || ' - ' || remt.cityef t_nhnhan,
        REMT.AMT-REMT.FEEAMT-REMT.VAT Sotien, tl.txdesc noidung, ---BA.FULLNAME BANK
        (CASE WHEN remt.bankid IS NULL THEN NVL(POM.bankid,'00') ELSE '02' END) BANKID,
        TL.TXDATE
    from ciremittance remt,
        /*(
            SELECT distinct  tr.ref
            FROM  vw_citran_gen tr
            where tr.tltxcd = '1104' AND TR.TXCD = '0043' AND TR.DELTD <> 'Y'
        )  tr,*/ afmast af, AFTYPE AFT, ALLCODE A0,TLPROFILES TLP, TLPROFILES TLP1,
        (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, vw_citran_gen tl,
        pomast pom
    where /*tr.ref = remt.potxnum   --dao do lay cac mon da lam 1104,lay pomast
        AND*/ REMT.RMSTATUS <> 'R' AND TL.deltd <>'Y'
        and tl.tltxcd = '1101'
        and tl.field = 'FLOATAMT'
        and tl.txtype = 'C'
        and remt.txdate = tl.txdate
        and remt.txnum = tl.txnum
        and remt.acctno = af.acctno
        and af.custid = cf.custid
        AND AF.ACTYPE = AFT.ACTYPE
        AND TL.TLID = TLP.TLID(+)
        AND NVL(TL.offid,'000') = TLP1.TLID(+)
        and pom.deltd<>'Y'
        AND REMT.POTXNUM = POM.TXNUM
        AND REMT.POTXDATE = POM.TXDATE
        ---AND (CASE WHEN remt.bankid IS NULL THEN NVL(POM.bankid,'00') ELSE '02' END) = BA.shortname(+)

        AND A0.CDTYPE='CF' AND A0.CDNAME='PRODUCTTYPE' AND A0.CDVAL=AFT.PRODUCTTYPE
        AND CF.CUSTODYCD LIKE V_STRCUSTODYCD
        AND CF.BRID LIKE V_I_BRIDGD
        AND TL.tlid LIKE v_strmaker
        and nvl(tl.offid,'000') like V_STRCHECKER
        AND TL.TXDATE BETWEEN TO_DATE(F_DATE,'DD/MM/YYYY') AND TO_DATE(T_DATE,'DD/MM/YYYY')
        AND AFT.PRODUCTTYPE LIKE L_STRAFTYPE
    ) MST
    LEFT JOIN BANKNOSTRO BA
    ON MST.BANKID = BA.shortname
    where mst.BANKID like V_BANKCODE
    ORDER BY MST.TXDATE, MST.f_tkluuky
        ;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
