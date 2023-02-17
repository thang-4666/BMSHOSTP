SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CA0022" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID        IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   PV_CACODE       IN       VARCHAR2,
	 PV_CUSTODYCD IN        VARCHAR2,
	 PV_TLBRID         IN      VARCHAR2,
	 PV_RPTTYPE        IN      VARCHAR2
   )
IS
--

    CUR             PKG_REPORT.REF_CURSOR;
    V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
    V_STRBRID      VARCHAR2 (4);
    V_STRCACODE    VARCHAR2 (20);
		V_CUSTODYCD VARCHAR2(10);
		V_TLBRID VARCHAR2(10);
		V_RPTTYPE VARCHAR2(20);

BEGIN


   IF (PV_CACODE <> 'ALL' OR PV_CACODE <> '')
   THEN
      V_STRCACODE := replace(PV_CACODE,'.','');
   ELSE
      V_STRCACODE := '%%';
   END IF;

   IF PV_CUSTODYCD ='ALL' THEN  V_CUSTODYCD :='%';
	 ELSE V_CUSTODYCD:= PV_CUSTODYCD;
	 END IF;
	 
	 IF PV_TLBRID = 'ALL' THEN V_TLBRID := '%';
	 ELSE V_TLBRID:= PV_TLBRID;
	 END IF;

IF PV_RPTTYPE <> 'ADDRESS' THEN
	
	 IF PV_RPTTYPE = 'EMAIL'  OR PV_RPTTYPE = 'SMS' THEN  V_RPTTYPE  := PV_RPTTYPE;
	 ELSE V_RPTTYPE:= '%%';
	 END IF;
	 
   OPEN PV_REFCURSOR FOR 
	 ----LAY RA EMAIL + SMS GUI DI
	 SELECT * FROM (
	 SELECT cf.fullname,cf.custodycd, EM.EMAIL SENDADDRESS, em.createtime, em.senttime,
              a.cdcontent isonline, ca.description, ca.duedate, sb.symbol, ca.reportdate, cf.address, em.templateid, 'EMAIL' via
       FROM (SELECT * FROM  emaillog UNION ALL SELECT * FROM emailloghist) em, 
			      (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf , 
			         camast ca , allcode a, sbsecurities sb
       WHERE em.templateid IN ('0217','0216','216A','216B','216C','216D','216E','216F')
       AND cf.email  = em.email AND instr(em.datasource,cf.custodycd) <> 0
       AND instr(em.datasource ,ca.camastid) <> 0 AND em.status = 'S'
       AND a.cdname = 'YESNO'
       AND a.cdval = (CASE WHEN EM.templateid = '216E' THEN 'N' ELSE cf.tradeonline END)
       AND ca.codeid = sb.codeid
       AND CA.CAMASTID = V_STRCACODE
			 AND CF.CUSTODYCD LIKE V_CUSTODYCD
			 AND CF.BRID LIKE V_TLBRID
			 AND 'EMAIL' LIKE V_RPTTYPE

       UNION ALL

       SELECT cf.fullname, cf.custodycd, EM.EMAIL SENDADDRESS, em.createtime, em.senttime,a.cdcontent isonline , ca.description, ca.duedate, sb.symbol, ca.reportdate, cf.address, EM.TEMPLATEID,'SMS' via
       FROM   (SELECT * FROM  emaillog  UNION ALL SELECT * FROM emailloghist) em, 
			        (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, 
							camast ca ,allcode a, sbsecurities sb
       WHERE em.email = cf.mobilesms AND instr(em.datasource,cf.custodycd) <> 0 
			 AND em.templateid = '0321' AND INSTR(em.datasource, ca.camastid) <> 0
       AND em.status = 'S' AND a.cdname = 'YESNO' AND a.cdval = cf.tradeonline  AND ca.codeid = sb.codeid
       AND CA.CAMASTID = V_STRCACODE
			 AND CF.CUSTODYCD LIKE V_CUSTODYCD
			 AND CF.BRID LIKE V_TLBRID
			 AND 'SMS' LIKE V_RPTTYPE
   ) ORDER BY CUSTODYCD	 
	 ;
ELSE 
   OPEN PV_REFCURSOR FOR 
	 ----LAY TOAN BO THONG TIN KHACH HANG TRONG BAO CAO CA0008
	  SELECT CF.FULLNAME, CF.CUSTODYCD, CF.ADDRESS SENDADDRESS, MST.DESCRIPTION, MST.DUEDATE, SB.symbol, MST.REPORTDATE, a.cdcontent isonline, 'LETTER' via
    FROM
        AFMAST AF,  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, 
				ALLCODE AL, SBSECURITIES SB, ISSUERS ISS, sbsecurities  tosb, issuers toiss,
        CAMAST  MST,TLPROFILES TLP,
        caschd ca , VW_TLLOG_ALL TL, ALLCODE A
    WHERE CA.AFACCTNO    = AF.ACCTNO
    AND   AF.CUSTID      = CF.CUSTID
    AND   CF.COUNTRY     = AL.CDVAL
    AND NVL(TL.OFFID,'000')=TLP.TLID(+)
    AND   AL.CDNAME      = 'COUNTRY'
    AND   nvl(mst.tocodeid,CA.CODEID)  = toSB.CODEID
    and   ca.codeid = sb.codeid
    AND   SB.ISSUERID    = ISS.ISSUERID
    and  tosb.issuerid = toiss.issuerid
		AND a.cdname = 'YESNO'
    AND a.cdval =  cf.tradeonline 
    AND   CA.DELTD       <>'Y'
    AND   (CA.BALANCE + CA.PBALANCE) > 0
    AND   CA.CAMASTID   =  MST.CAMASTID
    and   cf.custodycd LIKE V_CUSTODYCD
    and   ca.camastid like V_STRCACODE
    AND CF.BRID LIKE V_TLBRID
    AND   tl.tltxcd = '3370' AND tl.msgacct = mst.camastid AND TL.TXSTATUS IN ('1','7')
    AND   MST.CATYPE    =  '014'
    group by CF.FULLNAME, CF.CUSTODYCD, CF.ADDRESS , MST.DESCRIPTION, MST.DUEDATE,MST.REPORTDATE, a.cdcontent, sb.symbol
    order BY CF.CUSTODYCD;
END IF;




/*OPEN PV_REFCURSOR
FOR


       SELECT cf.fullname,cf.custodycd, cf.mobilesms, cf.email, em.createtime, em.senttime,
              a.cdcontent isonline, ca.description, ca.duedate, sb.symbol, ca.reportdate, cf.address
       FROM (SELECT * FROM  emaillog UNION ALL SELECT * FROM emailloghist) em, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf , camast ca , allcode a, sbsecurities sb
       WHERE em.templateid IN ('0217','0216','216A','216B','216C','216D','216E','216F')
       AND cf.email  = em.email
       AND instr(em.datasource ,ca.camastid) <> 0 AND em.status = 'S'
       AND a.cdname = 'YESNO'
       AND a.cdval = (CASE WHEN EM.templateid = '216E' THEN 'N' ELSE cf.tradeonline END)
       AND ca.codeid = sb.codeid
       AND CA.CAMASTID = V_STRCACODE

       UNION ALL

       SELECT cf.fullname, cf.custodycd, cf.mobilesms, cf.email, em.createtime, em.senttime,a.cdcontent isonline , ca.description, ca.duedate, sb.symbol, ca.reportdate, cf.address
       FROM   (SELECT * FROM  emaillog  UNION ALL SELECT * FROM emailloghist) em, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, camast ca ,allcode a, sbsecurities sb
       WHERE em.email = cf.mobilesms AND em.templateid = '0321' AND INSTR(em.datasource, ca.camastid) <> 0
       AND em.status = 'S' AND a.cdname = 'YESNO' AND a.cdval = cf.tradeonline  AND ca.codeid = sb.codeid
       AND CA.CAMASTID = V_STRCACODE*/


    


EXCEPTION
   WHEN OTHERS
   then
        --plog.error('Report:'||'CA0006:'||SQLERRM|| ':'||dbms_utility.format_error_backtrace);
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
