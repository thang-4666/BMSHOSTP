SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF0079" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE         IN       VARCHAR2,
   I_BRIDGD         IN       VARCHAR2,
   ACTYPE      IN       VARCHAR2
 )
IS

---------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID          VARCHAR2 (40);        -- USED WHEN V_NUMOPTION > 0
   V_STRCUSTODYCD     VARCHAR2(100);
   V_STR_IBRID       VARCHAR2(40);
   V_STRACTYPE       VARCHAR2(100);

BEGIN
/*   V_STROPTION := upper(OPT);
   V_INBRID := pv_BRID;
   IF (V_STROPTION = 'A') THEN
      V_STRBRID := '%';
   ELSE if (V_STROPTION = 'B') then
            select brgrp.mapid into V_STRBRID from brgrp where brgrp.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
   END IF;*/
   V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (PV_BRID <> 'ALL')
   THEN
      V_STRBRID := PV_BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;

   IF (I_BRIDGD <> 'ALL')
   THEN
      V_STR_IBRID := I_BRIDGD;
   ELSE
      V_STR_IBRID := '%%';
   END IF;

   IF (ACTYPE <> 'ALL')
   THEN
      V_STRACTYPE := ACTYPE;
   ELSE
      V_STRACTYPE := '%%';
   END IF;

OPEN PV_REFCURSOR
  FOR

SELECT V_STRACTYPE ACTYPE, TO_DATE(I_DATE,'DD/MM/YYYY') IDATE, CF.*,NVL(HANG.TXDATE,'') TXDATE,NVL(MG.TXDATE,'') DATE_MG, NVL(RE.REFULLNAME,'') MG_CHINH, NVL(REFT.REFULLNAME,'') MG_PHU

FROM (
SELECT CF.CUSTID, NVL(CF.CUSTODYCD,'') CUSTODYCD, NVL(CF.TRADINGCODE,'') TRADINGCODE,CF.FULLNAME,
       BR.BRNAME, CFT.TYPENAME  HANG, AL.CDCONTENT VIA
FROM (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF,BRGRP BR,  CFTYPE CFT, ALLCODE AL
WHERE CF.BRID=BR.BRID(+)
AND CF.ACTYPE=CFT.ACTYPE
AND AL.CDTYPE='CF'
AND AL.CDNAME='VIA'
AND AL.CDVAL=CF.OPENVIA
AND SUBSTR(CF.brid,1,4) LIKE V_STR_IBRID
AND CFT.ACTYPE LIKE V_STRACTYPE

) CF
LEFT JOIN
 ( SELECT MAX(TXDATE) TXDATE,  CUSTID FROM CHANGECFTYPE_LOG
   WHERE DELTD<>'Y'
   GROUP BY CUSTID) HANG ON CF.CUSTID=HANG.CUSTID
LEFT JOIN
 ( SELECT MAX(TXDATE) TXDATE, MSGACCT CUSTODYCD FROM VW_TLLOG_ALL
   WHERE TLTXCD='0380' AND DELTD<>'Y'
   GROUP BY MSGACCT) MG ON CF.CUSTODYCD=MG.CUSTODYCD
LEFT JOIN
 (--moi gioi chinh-tu van dau tu vip
SELECT CFRE.CUSTID RECUSTID,TYP.TYPENAME NAME, CFRE.FULLNAME REFULLNAME, A0.CDCONTENT DESC_REROLE,
CF.CUSTODYCD, CF.FULLNAME CUSTNAME, LNK.AFACCTNO ACCTNO, LNK.FRDATE, LNK.TODATE
FROM REAFLNK LNK, CFMAST CF, REMAST RE, RETYPE TYP, CFMAST CFRE, ALLCODE A0 , RECFLNK RF
WHERE CF.CUSTID=LNK.AFACCTNO AND LNK.STATUS='A' AND TYP.REROLE='CS'
AND RE.ACTYPE=TYP.ACTYPE AND RE.CUSTID=CFRE.CUSTID AND RE.ACCTNO=LNK.REACCTNO
AND A0.CDTYPE='RE' AND A0.CDNAME='REROLE' AND A0.CDVAL=TYP.REROLE
 AND LNK.refrecflnkid=RF.autoid AND (V_STRBRID ='0001' or  RF.BRID LIKE V_STRBRID)
 ) RE

ON RE.ACCTNO=CF.CUSTID

LEFT JOIN
 (--moi giơi phu-cham soc ho
SELECT CFRE.CUSTID RECUSTID, CFRE.FULLNAME REFULLNAME, A0.CDCONTENT DESC_REROLE,
CF.CUSTODYCD, CF.FULLNAME CUSTNAME, LNK.AFACCTNO ACCTNO, LNK.FRDATE, LNK.TODATE
FROM REAFLNK LNK, CFMAST CF, REMAST RE, RETYPE TYP, CFMAST CFRE, ALLCODE A0 , RECFLNK RF
WHERE CF.CUSTID=LNK.AFACCTNO AND LNK.STATUS='A' AND TYP.REROLE='DG'
AND RE.ACTYPE=TYP.ACTYPE AND RE.CUSTID=CFRE.CUSTID AND RE.ACCTNO=LNK.REACCTNO
AND A0.CDTYPE='RE' AND A0.CDNAME='REROLE' AND A0.CDVAL=TYP.REROLE
 AND LNK.refrecflnkid=RF.autoid AND (V_STRBRID ='0001' or  RF.BRID LIKE V_STRBRID)
 ) REFT   ON REFT.ACCTNO=CF.CUSTID

ORDER BY CF.CUSTID


;


EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;
 
 
 
 
/
