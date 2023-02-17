SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CA0020" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE           IN       VARCHAR2,
   T_DATE           IN       VARCHAR2,
   pv_COREBANK         in       VARCHAR2,
   pv_BANKNAME          in       VARCHAR2,
   pv_CACODE           in        varchar2,
   pv_SYMBOL           in        varchar2,
   PV_CUSTODYCD     in        varchar2
  )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
-- BAO CAO TAI KHOAN TIEN TONG HOP CUA NGUOI DAU TU
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- THANHNM   23-APR-12  CREATED
-- ---------   ------  -------------------------------------------

    CUR             PKG_REPORT.REF_CURSOR;
    V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
    V_STRBRID      VARCHAR2 (40);
    V_INBRID       VARCHAR2 (4);

    V_STRACCTNO    VARCHAR2 (20);
    V_STRBANKNAME  VARCHAR2 (10);
    V_STRCOREBANK  VARCHAR2 (5);
    V_F_DATE       DATE;
    V_T_DATE       DATE;
    V_CACODE       VARCHAR2 (20);
    V_SYMBOL       VARCHAR2 (20);
    V_STRCUSTODYCD  VARCHAR2 (20);
BEGIN
   V_STROPTION := upper(OPT);
   V_INBRID := pv_BRID;
   V_F_DATE := TO_DATE(F_DATE,'DD/MM/RRRR');
   V_T_DATE := TO_DATE(T_DATE,'DD/MM/RRRR');
   IF (V_STROPTION = 'A') THEN
      V_STRBRID := '%';
   ELSE if(V_STROPTION = 'B') then
          select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
   END IF;

   IF(pv_COREBANK <> 'ALL')   THEN  V_STRCOREBANK  := pv_COREBANK;
   ELSE   V_STRCOREBANK  := '%';
   END IF;

   IF(pv_BANKNAME <> 'ALL')   THEN        V_STRBANKNAME  := pv_BANKNAME;
   ELSE        V_STRBANKNAME  := '%';
   END IF;
   IF(pv_CACODE <> 'ALL')   THEN  V_CACODE  := pv_CACODE;
   ELSE   V_CACODE  := '%';
   END IF;
   IF(pv_SYMBOL <> 'ALL')   THEN  V_SYMBOL  :=  upper(REPLACE (pv_SYMBOL,' ','_')) || '%';
   ELSE   V_SYMBOL  := '%';
   END IF;
    IF(PV_CUSTODYCD <> 'ALL')   THEN  V_STRCUSTODYCD  := PV_CUSTODYCD;
   ELSE   V_STRCUSTODYCD  := '%';
   END IF;

   -- GET REPORT'S PARAMETERS
/*      OPT            IN       VARCHAR2,
   BRID           IN       VARCHAR2,
   F_DATE           IN       VARCHAR2,
   T_DATE           IN       VARCHAR2,
   COREBANK         in       VARCHAR2,
   BANKNAME          in       VARCHAR2,
   CACODE           in        varchar2,
   SYMBOL           in        varchar2,
   PV_CUSTODYCD     in        varchar2
*/
/*pr_error('ca0020', 'OPT:' || OPT);
pr_error('ca0020', 'BRID:' || BRID);
pr_error('ca0020', 'F_DATE:' || F_DATE);
pr_error('ca0020', 'T_DATE:' || T_DATE);
pr_error('ca0020', 'COREBANK:' || pv_COREBANK);
pr_error('ca0020', 'BANKNAME:' || pv_BANKNAME);
pr_error('ca0020', 'CACODE:' || pv_CACODE);
pr_error('ca0020', 'SYMBOL:' || pv_SYMBOL);
pr_error('ca0020', 'PV_CUSTODYCD:' || PV_CUSTODYCD);
*/


OPEN PV_REFCURSOR
   FOR

SELECT CI.busdate TXDATE, cf.custodycd, af.acctno Sub_Account,
    --REPLACE(se.symbol,'_WFT','') symbol ,
    ca.symbol symbol,
    CASE WHEN CI.TLTXCD = '3386' THEN -SE.NAMT ELSE SE.NAMT END Quantity,
    CASE WHEN CI.TLTXCD = '3386' THEN -CI.NAMT ELSE CI.NAMT END Amount,
    NVL(mk.tlname,'-----') maker_name, NVL(ck.tlname,'-----') checker_name,
   'Completed'  Status, decode (af.COREBANK,'Y',AF.bankname, cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME')) bankname,
   ca.tosymbol tosymbol
FROM (SELECT * FROM   VW_CITRAN_GEN  WHERE TLTXCD IN ('3394','3384','3386'))  CI,
      ( SELECT * FROM   VW_SETRAN_GEN  WHERE TLTXCD IN ('3394','3384','3386') ) SE ,
  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af,tlprofiles mk, tlprofiles ck, caschd chd,
  (SELECT camastid, sb.symbol symbol, tosb.symbol tosymbol
    FROM camast ca, sbsecurities tosb, sbsecurities sb
    WHERE nvl(ca.tocodeid, ca.codeid) = tosb.codeid AND ca.codeid = sb.codeid
  ) ca--add by CHAUNH
WHERE SE.TXNUM = CI.TXNUM AND SE.TXDATE = CI.TXDATE
--AND se.REF = ca.camastid (+) --xoa CHAUNH
AND se.REF = to_char(chd.autoid) AND chd.camastid = ca.camastid
AND SE.DELTD='N' AND CI.DELTD='N' AND SE.field ='RECEIVING' AND CI.field='BALANCE'
AND ci.busdate >= V_F_DATE AND  ci.busdate <= V_T_DATE
AND CI.ACCTNO = af.acctno and af.custid = cf.custid AND SE.custid = CF.custid --AND CF.custid = AF.custid
AND CI.TLID = MK.TLID (+) AND CI.offid = CK.TLID(+)
AND AF.COREBANK LIKE V_STRCOREBANK
AND AF.bankname LIKE V_STRBANKNAME
--AND AF.BRID LIKE V_STRBRID
ANd  (af.brid like V_STRBRID or instr(V_STRBRID,af.brid) <> 0)
AND CF.CUSTODYCD LIKE V_STRCUSTODYCD
AND se.symbol LIKE V_SYMBOL
AND chd.camastid LIKE V_CACODE


UNION ALL


SELECT SE.busdate TXDATE, cf.custodycd, af.acctno Sub_Account,
    --REPLACE(se.symbol,'_WFT','') symbol ,
    ca.symbol symbol,
    CASE WHEN SE.TLTXCD = '3326' THEN -SE.NAMT ELSE SE.NAMT END Quantity, 0 Amount,
    NVL(mk.tlname,'-----') maker_name, NVL(ck.tlname,'-----') checker_name,
   'Completed'  Status, decode (af.COREBANK,'Y',AF.bankname, cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME')) bankname,
    ca.tosymbol tosymbol
FROM ( SELECT * FROM   VW_SETRAN_GEN  WHERE TLTXCD IN ('3324','3326') ) SE ,
  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af,tlprofiles mk, tlprofiles ck, caschd chd,
  (SELECT camastid, sb.symbol symbol, tosb.symbol tosymbol
    FROM camast ca, sbsecurities tosb, sbsecurities sb
    WHERE nvl(ca.tocodeid, ca.codeid) = tosb.codeid AND ca.codeid = sb.codeid
  ) ca--add by CHAUNH
WHERE SE.DELTD='N' AND SE.field ='RECEIVING'
--AND se.REF = ca.camastid (+)
AND se.REF = to_char(chd.autoid) AND chd.camastid = ca.camastid
AND SE.busdate >= V_F_DATE AND  SE.busdate <= V_T_DATE
AND SE.AFACCTNO = af.acctno and af.custid = cf.custid AND SE.custid = CF.custid --AND CF.custid = AF.custid
AND SE.TLID = MK.TLID (+) AND SE.offid = CK.TLID(+)
AND AF.COREBANK LIKE V_STRCOREBANK
AND AF.bankname LIKE V_STRBANKNAME
--AND AF.BRID LIKE V_STRBRID
ANd  (af.brid like V_STRBRID or instr(V_STRBRID,af.brid) <> 0)
AND CF.CUSTODYCD LIKE V_STRCUSTODYCD
AND chd.camastid LIKE V_CACODE
AND se.symbol LIKE V_SYMBOL

UNION ALL

SELECT  tran.txdate, cf.custodycd, af.acctno sub_account,
        ca.symbol symbol,
        CASE WHEN tl.tltxcd = '3327' THEN tl.msgamt ELSE -tl.msgamt END Quantity,
        0 amount,  NVL(mk.tlname,'-----') maker_name, NVL(ck.tlname,'-----') checker_name, 'Completed'  Status,
        decode (af.COREBANK,'Y',AF.bankname, cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME')) bankname, ca.tosymbol tosymbol
FROM
(SELECT * FROM catran
UNION all
SELECT * FROM catrana) tran,
vw_tllog_all tl, cfmast cf, afmast af,tlprofiles mk, tlprofiles ck,
 (SELECT camastid, sb.symbol symbol, tosb.symbol tosymbol
    FROM camast ca, sbsecurities tosb, sbsecurities sb
    WHERE nvl(ca.tocodeid, ca.codeid) = tosb.codeid AND ca.codeid = sb.codeid) ca, vw_caschd_all chd
WHERE tl.txdate = tran.txdate AND tl.txnum = tran.txnum
AND cf.custid = af.custid AND af.acctno = tl.msgacct
AND TL.TLID = MK.TLID (+) AND tl.offid = ck.TLID(+)
AND ca.camastid = chd.camastid
AND chd.autoid = tran.acctno
AND tl.tltxcd IN ('3327','3328')
AND tl.busdate >= V_F_DATE AND  tl.busdate <= V_T_DATE
AND AF.COREBANK LIKE V_STRCOREBANK
AND AF.bankname LIKE V_STRBANKNAME
--AND AF.BRID LIKE V_STRBRID
ANd  (af.brid like V_STRBRID or instr(V_STRBRID,af.brid) <> 0)
AND CF.CUSTODYCD LIKE V_STRCUSTODYCD
AND ca.camastid LIKE V_CACODE
AND ca.symbol LIKE V_SYMBOL

ORDER BY TXDATE



;
/*pr_error('ca0020', 'CHAY THANH CONG');*/
EXCEPTION
   WHEN OTHERS
   THEN
   /*pr_error('ca0020', 'CO LOI XAY RA TAI DONG: ' || dbms_utility.format_error_backtrace );*/
      RETURN;
END;

 
 
 
 
/
