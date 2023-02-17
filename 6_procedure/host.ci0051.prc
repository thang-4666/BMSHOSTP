SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE ci0051 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD      IN       VARCHAR2,
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
   V_STRBRID       VARCHAR2 (40);                   -- USED WHEN V_NUMOPTION > 0
   V_INBRID        VARCHAR2 (4);

   V_STRCUSTODYCD   VARCHAR2 (20);
   V_POTMAP varchar2(20);



   v_strmaker   varchar2(10);
   V_STRCHECKER   varchar2(10);

   L_STRAFTYPE        varchar2(20);
   V_I_BRIDGD          VARCHAR2(100);
   V_BRNAME            NVARCHAR2(400);
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

    if(UPPER(PV_BANKCODE) = 'ALL' or LENGTH(PV_BANKCODE) <= 1 ) THEN
        V_BANKCODE := '%';
    else
        V_BANKCODE := PV_BANKCODE;
    end if;

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
      V_BRNAME   :=  ' Toan cong ty ';
   END IF;
   -- GET REPORT'S DATA

OPEN  PV_REFCURSOR FOR

SELECT TRAN.TXDATE searchdate, cf.brid f_chi_nhanh, tran.custodycd f_tkluuky, tran.acctno f_sotk, cf.fullname f_tenkh,
        remt.benefcustname t_nguoinhan, remt.beneflicense t_cmnd, remt.benefiddate t_ngaycap, remt.benefidplace t_noicap,
        remt.benefacct t_sotk,AL.CDCONTENT MNEMONIC,tlp1.tlname maked, tlp2.tlname approve,
        V_STRCUSTODYCD CUST,TRAN.TXNUM,TRAN.BUSDATE,
         remt.benefbank || ' - ' || remt.cityef || ' - ' ||  remt.citybank t_nhnhan, remt.amt Sotien,tran.txdesc noidung,
         NVL(ba.FULLNAME,'') BANK
FROM ciremittance remt,vw_citran_gen tran,AFMAST AF,AFTYPE AFT, ALLCODE AL,TLPROFILES TLP1, TLPROFILES TLP2,
 (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf,/*,
(
   SELECT  tr.ref, NVL(FLD.CVALUE,0) BANK, BA.FULLNAME,FLD1.CVALUE
  FROM    vw_citran_gen tr,VW_TLLOGFLD_ALL FLD, BANKNOSTRO BA,VW_TLLOGFLD_ALL FLD1
  where tr.tltxcd = '1104' AND TR.TXCD='0043' AND TR.DELTD<>'Y'
  AND TR.TXNUM=FLD.TXNUM AND TR.TXDATE=FLD.TXDATE AND FLD.FLDCD='05'
  AND TR.TXNUM=FLD1.TXNUM AND TR.TXDATE=FLD1.TXDATE AND FLD1.FLDCD='07'
  AND   NVL(FLD.CVALUE,'00')=BA.SHORTNAME
  AND FLD.CVALUE LIKE V_BANKCODE
    )  tr*/
(SELECT * FROM    pomast WHERE DELTD <> 'Y' )po, banknostro ba
WHERE remt.rmstatus <> 'R'
and nvl(remt.potxnum,'000')=po.txnum(+)
 AND nvl(remt.potxdate,to_date('01/01/2010','dd/mm/yyyy'))=po.txdate(+)
 and nvl(po.bankid,'a')=ba.shortname(+)
AND remt.deltd <> 'Y'
AND AF.CUSTID=CF.CUSTID
AND AF.ACTYPE=AFT.ACTYPE
AND AL.CDTYPE='CF'
AND AL.CDVAL=AFT.PRODUCTTYPE
AND AL.CDNAME='PRODUCTTYPE'
AND TRAN.tlid=TLP1.TLID(+)
AND TRAN.offid=TLP2.TLID(+)
AND tran.txnum = remt.txnum
AND tran.tltxcd IN ('1101')
and tran.field = 'FLOATAMT'
AND tran.txdate = remt.txdate
AND tran.ACCTNO=AF.ACCTNO
AND nvl(po.bankid,'a') LIKE V_BANKCODE
AND CF.CUSTODYCD LIKE V_STRCUSTODYCD
AND CF.BRID LIKE V_I_BRIDGD
AND TRAN.txdate BETWEEN to_date(F_DATE, 'DD/MM/RRRR') AND to_date(T_DATE, 'DD/MM/RRRR')
and tran.tlid like v_strmaker
and nvl(tran.offid,'000') like V_STRCHECKER
AND AFT.PRODUCTTYPE LIKE L_STRAFTYPE
ORDER BY searchdate;
/*
UNION
SELECT remt.txdate searchdate, br.brname f_chi_nhanh, tran.custodycd f_tkluuky, tran.acctno f_sotk, cf.fullname f_tenkh,
        remt.benefcustname t_nguoinhan, remt.beneflicense t_cmnd, remt.benefiddate t_ngaycap, remt.benefidplace t_noicap,
        remt.benefacct t_sotk,AL.CDCONTENT MNEMONIC,tlp1.tlname maked, tlp2.tlname approve,
         remt.benefbank || ' - ' || remt.cityef || ' - ' ||  remt.citybank t_nhnhan, remt.amt Sotien,tran.txdesc noidung
FROM ciremittance remt,vw_citran_gen tran, cfmast cf, brgrp br,AFMAST AF,CFTYPE CFT, CFAFTYPE CFA, ALLCODE AL,TLPROFILES TLP1, TLPROFILES TLP2
WHERE ---remt.rmstatus = 'C' AND
    remt.deltd <> 'Y'
    AND AF.CUSTID=CF.CUSTID
AND AF.ACTYPE=CFA.aftype
AND CFT.ACTYPE=CFA.CFTYPE
AND CFT.ACTYPE=CF.ACTYPE
AND AL.CDTYPE='CF'
AND AL.CDVAL=CFA.PRODUCTTYPE
AND AL.CDNAME='PRODUCTTYPE'
AND TRAN.tlid=TLP1.TLID(+)
AND TRAN.offid=TLP2.TLID(+)
AND tran.tltxcd = '1114'
 AND tran.ref = remt.txnum || to_char(remt.txdate,'DD/MM/YYYY')
and tran.tltxcd like V_strtltxcd
and (tran.brid like V_STRBRID or INSTR(V_STRBRID,tran.brid) <> 0)
and tran.field = 'FLOATAMT'
AND tran.ACCTNO=AF.ACCTNO
AND cf.brid = br.brid
AND TRAN.txdate = to_date(I_DATE, 'DD/MM/RRRR')
and tran.tlid like v_strmaker
AND substr(CF.custid,1,4) LIKE V_I_BRIDGD
AND CFA.PRODUCTTYPE LIKE L_STRAFTYPE*/

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
