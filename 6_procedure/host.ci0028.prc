SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CI0028" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PV_MAKER       IN       VARCHAR2,
   PV_CHECKER     IN       VARCHAR2,
   I_BRIDGD       IN       VARCHAR2,
   PV_AFTYPE      IN       VARCHAR2,
   PV_TLTXCD      IN       VARCHAR2,
   PV_BANKCODE    IN       VARCHAR2

 )
IS
--

-- ---------   ------  -------------------------------------------
   V_STROPTION     VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID       VARCHAR2 (40);
   V_INBRID        VARCHAR2 (4);

   V_STRCUSTODYCD   VARCHAR2 (20);

   v_strmaker   varchar2(10);
      V_STRCHECKER   varchar2(10);

   L_STRAFTYPE        varchar2(20);
   V_I_BRIDGD          VARCHAR2(100);
   V_BRNAME            NVARCHAR2(400);
   V_STRTLTXCD          VARCHAR2(100);
  V_BANKCODE          VARCHAR2(100);

BEGIN
   V_STROPTION := upper(OPT);
   V_INBRID := pv_BRID;

   IF (V_STROPTION = 'A')
   THEN
      V_STRBRID := '%';
   ELSE if (V_STROPTION = 'B') then
            select brgrp.mapid into V_STRBRID from brgrp where brgrp.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
   END IF;

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


 if(upper(PV_TLTXCD) = 'ALL' or LENGTH(PV_TLTXCD) <= 1 ) then
        V_strtltxcd := '%';
    else
        V_strtltxcd := PV_TLTXCD;
    end if;

    if(UPPER(PV_BANKCODE) = 'ALL' or LENGTH(PV_BANKCODE) <= 1 ) THEN
        V_BANKCODE := '%';
    else
        V_BANKCODE := PV_BANKCODE;
    end if;

   -- GET REPORT'S DATA

OPEN  PV_REFCURSOR FOR
SELECT MST.* FROM (
SELECT  TRAN.TLTXCD,REMT.TXDATE SEARCHDATE,CF.BRID f_chi_nhanh, CF.CUSTODYCD f_tkluuky, AF.ACCTNO f_sotk, CF.FULLNAME f_tenkh,
       remt.benefcustname t_nguoinhan, remt.beneflicense t_cmnd, remt.benefiddate t_ngaycap, remt.benefidplace t_noicap,
        remt.benefacct t_sotk,AL.cdcontent MNEMONIC,tlp1.tlname maked, tlp2.tlname approve,
        remt.benefbank || ' - ' || remt.cityef || ' - ' ||  remt.citybank t_nhnhan, remt.amt Sotien,tran.txdesc noidung,
        tran.txnum,V_STRCUSTODYCD cust, PO.BANKID

FROM ciremittance remt, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, brgrp br,AFMAST AF,AFTYPE AFT, ALLCODE AL,TLPROFILES TLP1, TLPROFILES TLP2,
      (SELECT TL.BUSDATE,TL.MSGACCT,TL.MSGAMT, TL.BRID, TL.TLID, TL.OFFID,TL.TLTXCD, TL.TXNUM, TL.TXDESC , TL.TXDATE
       FROM   VW_TLLOG_ALL TL
       WHERE  TL.TLTXCD='1112'
           AND TL.DELTD<>'Y' AND TL.TXSTATUS IN ('1','7')
) TRAN,POMAST PO
WHERE   REMT.POTXNUM=TRAN.MSGACCT
AND PO.TXDATE=TRAN.TXDATE AND PO.TXNUM=TRAN.MSGACCT
AND REMT.TXDATE=TRAN.TXDATE
AND REMT.ACCTNO=AF.ACCTNO
AND AF.CUSTID=CF.CUSTID
AND AF.ACTYPE=AFT.ACTYPE
AND AL.CDTYPE='CF'
AND AL.CDVAL=AFT.PRODUCTTYPE
AND AL.CDNAME='PRODUCTTYPE'
AND TRAN.tlid=TLP1.TLID(+)
AND TRAN.offid=TLP2.TLID(+)
AND cf.brid = br.brid
AND TRAN.TXDATE between TO_DATE(F_DATE, 'DD/MM/RRRR') AND TO_DATE(T_DATE, 'DD/MM/RRRR')
and tran.tltxcd like V_strtltxcd
AND CF.CUSTODYCD LIKE V_STRCUSTODYCD
AND NVL(TRAN.OFFID,'000') LIKE V_STRCHECKER
and tran.tlid like v_strmaker
AND CF.BRID LIKE V_I_BRIDGD
AND AFT.PRODUCTTYPE LIKE L_STRAFTYPE

UNION ALL

SELECT  TRAN.TLTXCD,remt.txdate searchdate, CF.BRID f_chi_nhanh, tran.custodycd f_tkluuky, tran.acctno f_sotk, cf.fullname f_tenkh,
        remt.benefcustname t_nguoinhan, remt.beneflicense t_cmnd, remt.benefiddate t_ngaycap, remt.benefidplace t_noicap,
        remt.benefacct t_sotk,AL.cdcontent MNEMONIC,tlp1.tlname maked, tlp2.tlname approve,
         remt.benefbank || ' - ' || remt.cityef || ' - ' ||  remt.citybank t_nhnhan, remt.amt Sotien,tran.txdesc noidung,
                tran.txnum,V_STRCUSTODYCD cust,
                 (CASE WHEN remt.bankid IS NOT NULL THEN remt.bankid ELSE '02' END) BANKID
FROM ciremittance remt,vw_citran_gen tran, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, brgrp br,AFMAST AF,AFTYPE AFT, ALLCODE AL,TLPROFILES TLP1, TLPROFILES TLP2
WHERE  AF.CUSTID=CF.CUSTID
AND AF.ACTYPE=AFT.ACTYPE
AND AL.CDTYPE='CF'
AND AL.CDVAL=AFT.PRODUCTTYPE
AND AL.CDNAME='PRODUCTTYPE'
AND TRAN.tlid=TLP1.TLID(+)
AND TRAN.offid=TLP2.TLID(+)
AND tran.tltxcd = '1114'
AND tran.ref = remt.txnum || to_char(remt.txdate,'DD/MM/YYYY')
and tran.field = 'FLOATAMT'
AND tran.ACCTNO=AF.ACCTNO
AND cf.brid = br.brid
AND CF.CUSTODYCD LIKE V_STRCUSTODYCD
AND TRAN.TXDATE between TO_DATE(F_DATE, 'DD/MM/RRRR') AND TO_DATE(T_DATE, 'DD/MM/RRRR')
and tran.tltxcd like V_strtltxcd
and tran.tlid like v_strmaker
AND NVL(TRAN.OFFID,'000') LIKE V_STRCHECKER
AND CF.BRID LIKE V_I_BRIDGD
AND AFT.PRODUCTTYPE LIKE L_STRAFTYPE
)MST LEFT JOIN  BANKNOSTRO BA
    ON MST.BANKID = BA.shortname
    where mst.BANKID like V_BANKCODE

ORDER BY SEARCHDATE
;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
