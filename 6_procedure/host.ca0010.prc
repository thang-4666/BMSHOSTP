SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE ca0010 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   I_BRIDGD       IN       VARCHAR2,
   CACODE         IN       VARCHAR2,
   PV_AFACCTNO    IN       VARCHAR2,
   PLSENT         in       varchar2
  )
IS
--
/*=={}===============>*/
---------   ------  -------------------------------------------

    CUR             PKG_REPORT.REF_CURSOR;
    V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
    V_STRBRID      VARCHAR2 (40);
    V_INBRID       VARCHAR2 (4);

    V_STRCACODE    VARCHAR2 (20);
    V_STRAFACCTNO   VARCHAR2 (20);

       V_I_BRIDGD          VARCHAR2(100);
       V_BRNAME            NVARCHAR2(400);


BEGIN
   V_STROPTION := upper(OPT);
   V_INBRID := pv_BRID;

   IF (V_STROPTION = 'A') THEN
      V_STRBRID := '%';
   ELSE if(V_STROPTION = 'B') then
            select brgrp.brid into V_STRBRID from brgrp where brgrp.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
   END IF;



   IF (CACODE <> 'ALL')
   THEN
      V_STRCACODE := CACODE;
   ELSE
      V_STRCACODE := '%%';
   END IF;

  IF (PV_AFACCTNO <> 'ALL')
  THEN
     V_STRAFACCTNO := PV_AFACCTNO;
  ELSE
   V_STRAFACCTNO := '%%';
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
      V_BRNAME   :=  ' Toàn công ty';
   END IF;

   -- GET REPORT'S PARAMETERS

--Tinh ngay nhan thanh toan bu tru


OPEN PV_REFCURSOR
   FOR
      SELECT PLSENT sendto,'' TYPELG_NAME,
         NVL(trim(CA.CUSTTYPE_NAME),'') CUSTTYPE_NAME ,
         NVL(CA.ISS_NAME,'') ISS_NAME,CA.TOISSNAME, CA.TOSYMBOL, ca.country ,CA.BRNAME,CA.BRID,
         ca.acctno , ca.custodycd,ca.fullname,ca.address,ca.MOBILE,ca.IDCODE,ca.IDDATE,
         nvl(ca.RIGHTOFFRATE,'') RIGHTOFFRATE,
         ca.Catype,ca.status_af status_af,ca.status,ca.camastid,ca.amt,
         ca.symbol,ca.reportdate, ca.frdatetransfer , ca.todatetransfer,
         ca.stcv, ca.actiondate,
         0 NUM_TRF, 0 NUM_RectrF, CA.codeid codeca,ca.nmqtty, ca.exprice,
         '' codetl,0 SLSH, sum(ca.QTTY) SLDKM,
         NVL(ca.roundtype,'') roundtype, sum(CA.slctm) slctm ,sum(ca.aamt) aamt
    FROM
        (
            SELECT  cas.aamt,af.acctno acctno ,cf.custid, cf.custodycd custodycd, cf.fullname fullname, cf.MOBILE mobile,
                    (case when cf.country = '234' then cf.idcode else cf.tradingcode end) idcode,BR.BRNAME, CF.BRID,
                    (case when cf.country = '234' then cf.iddate else cf.tradingcodedt end) IDDATE, cf.country, cf.address,
                    cas.balance SLCKSH, cam.RIGHTOFFRATE rightoffrate, A0.cdcontent Catype,
                    (case when cas.status<>'C' and cas.tqtty >0 then 'Thực hiện 3387' else to_char( A1.cdcontent) end  ) status, cam.camastid camastid,
                    cas.AMT AMT, se.symbol symbol, se.codeid codeid, cam.REPORTDATE reportdate, cas.qtty SLQMDNG, cas.amt STCV, CAS.PQTTY SLQMDPB,
                    cam.ACTIONDATE actiondate, cas.PBALANCE PBALANCE, cam.optcodeid optcodeid, cam.roundtype, cas.nmqtty, cam.exprice,
                    AF.status status_af,cam.begindate frdatetransfer , cam.duedate todatetransfer,
                    (cas.PQTTY+cas.QTTY) slctm, a2.cdcontent  AS CUSTTYPE_NAME, SE.ISS_NAME,
                    sb.ISS_NAME ToISSname, sb.symbol tosymbol, cas.autoid,cas.QTTY
            FROM caschd cas,BRGRP BR, (SELECT ISSUERS.FULLNAME ISS_NAME, SB.* from SBSECURITIES SB, ISSUERS  WHERE SB.ISSUERID = ISSUERS.ISSUERID) se,
                 camast cam, afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0)  cf, 
                 allcode A0, Allcode A1, allcode a2,
                 (SELECT ISSUERS.FULLNAME ISS_NAME, SB.* from SBSECURITIES SB, ISSUERS  WHERE SB.ISSUERID = ISSUERS.ISSUERID) sb  --Chaunh 02/10/2012
            WHERE cas.codeid = se.codeid
            AND cam.camastid = cas.camastid
            AND cas.afacctno = af.acctno
            AND af.custid = cf.custid
            AND CF.BRID=BR.BRID(+)
            AND nvl(cam.tocodeid,cam.codeid) = sb.codeid
            AND a0.CDTYPE = 'CA' AND a0.CDNAME = 'CATYPE' AND a0.CDVAL = cam.CATYPE
            AND A1.CDTYPE = 'CA' AND A1.CDNAME = 'CASTATUS' AND trim(A1.CDVAL) = trim(cas.STATUS)
            AND A2.CDTYPE = 'CF' AND A2.CDNAME = 'CUSTTYPE' AND trim(A2.CDVAL) = trim(cf.CUSTTYPE)
            AND cam.catype ='014' and cas.qtty>0
            and cas.afacctno like V_STRAFACCTNO
            and cf.BRID LIKE V_I_BRIDGD
            AND cam.camastid LIKE V_STRCACODE
            AND CAS.deltd<>'Y'  
     ) CA
group by  NVL(trim(CA.CUSTTYPE_NAME),''),NVL(CA.ISS_NAME,'') ,CA.TOISSNAME, CA.TOSYMBOL,ca.country ,
         CA.BRNAME,CA.BRID,ca.acctno , ca.custodycd,ca.fullname,ca.address,ca.MOBILE,ca.IDCODE,ca.IDDATE,
         nvl(ca.RIGHTOFFRATE,'') ,ca.Catype,ca.status_af ,ca.status,ca.camastid,ca.amt,
         ca.symbol,ca.reportdate, ca.frdatetransfer , ca.todatetransfer,
         ca.stcv, ca.actiondate,CA.codeid ,ca.nmqtty, ca.exprice, NVL(ca.roundtype,'') 
HAVING   SUM(CA.QTTY) > 0
order by ca.custodycd,ca.acctno;
/*
    SELECT PLSENT sendto,
    (CASE WHEN SUBSTR(CA.custodycd,4,1) = 'P' THEN ' T? doanh ' ELSE ' Môi gi?i ' END) TYPELG_NAME,
         NVL(trim(CA.CUSTTYPE_NAME),'') CUSTTYPE_NAME ,
         NVL(CA.ISS_NAME,'') ISS_NAME,
         CA.TOISSNAME, CA.TOSYMBOL,  --Chaunh 02/10/2012
         nvl(ca.country,'')  country,CA.BRNAME,CA.BRID,
         nvl(ca.acctno,'')   acctno ,
         nvl(ca.custodycd,'') custodycd ,
         nvl(ca.fullname,'')  fullname ,
         nvl(ca.address,'')   address ,
         nvl(ca.MOBILE,'') MOBILE ,
         nvl(ca.IDCODE,'') IDCODE,
         nvl(ca.IDDATE,'') IDDATE,
         nvl(ca.RIGHTOFFRATE,'') RIGHTOFFRATE,
         ca.Catype,ca.status_af status_af,ca.status,ca.camastid,ca.amt,
         ca.symbol,ca.reportdate, ca.frdatetransfer , ca.todatetransfer,
         ca.stcv, ca.actiondate,
         NVL(TL.NUM_TRF,0) NUM_TRF, NVL(TL.NUM_RectrF,0)NUM_RectrF, CA.codeid codeca,ca.nmqtty, ca.exprice,
         NVL(tl.codeid,'a') codetl,
         0 SLSH,
       \*  NVL(TL.SLDKM,0) SLDKM,*\ NVL(NGAY.AMT,0) SLDKM,
         NVL(ca.roundtype,'') roundtype, NVL(CA.slctm,'') slctm ,
         NVL(ca.aamt,'') aamt
    FROM
        (
            SELECT  cas.aamt,af.acctno acctno ,cf.custid, cf.custodycd custodycd, cf.fullname fullname, cf.MOBILE mobile,
                    (case when cf.country = '234' then cf.idcode else cf.tradingcode end) idcode,BR.BRNAME, CF.BRID,
                    (case when cf.country = '234' then cf.iddate else cf.tradingcodedt end) IDDATE, cf.country, cf.address,
                    cas.balance SLCKSH, cam.RIGHTOFFRATE rightoffrate, A0.cdcontent Catype,
                    (case when cas.status<>'C' and cas.tqtty >0 then 'Th?c hi?n 3387' else to_char( A1.cdcontent) end  ) status, cam.camastid camastid,
                    cas.AMT AMT, se.symbol symbol, se.codeid codeid, cam.REPORTDATE reportdate, cas.qtty SLQMDNG, cas.amt STCV, CAS.PQTTY SLQMDPB,
                    cam.ACTIONDATE actiondate, cas.PBALANCE PBALANCE, cam.optcodeid optcodeid, cam.roundtype, cas.nmqtty, cam.exprice,
                    AF.status status_af,cam.begindate frdatetransfer , cam.duedate todatetransfer,
                    (cas.PQTTY+cas.QTTY) slctm, a2.cdcontent  AS CUSTTYPE_NAME, SE.ISS_NAME,
                    sb.ISS_NAME ToISSname, sb.symbol tosymbol, cas.autoid
            FROM caschd cas,BRGRP BR, (SELECT ISSUERS.FULLNAME ISS_NAME, SB.* from SBSECURITIES SB, ISSUERS  WHERE SB.ISSUERID = ISSUERS.ISSUERID) se,
                 camast cam, afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, allcode A0, Allcode A1, allcode a2,
                 (SELECT ISSUERS.FULLNAME ISS_NAME, SB.* from SBSECURITIES SB, ISSUERS  WHERE SB.ISSUERID = ISSUERS.ISSUERID) sb  --Chaunh 02/10/2012
            WHERE cas.codeid = se.codeid
            AND cam.camastid = cas.camastid
            AND cas.afacctno = af.acctno
            AND af.custid = cf.custid
            AND CF.BRID=BR.BRID(+)
            AND nvl(cam.tocodeid,cam.codeid) = sb.codeid --Chaunh 02/10/2012
            --and (af.brid like V_STRBRID or INSTR(V_STRBRID,af.brid) <> 0)
            AND a0.CDTYPE = 'CA' AND a0.CDNAME = 'CATYPE' AND a0.CDVAL = cam.CATYPE
            AND A1.CDTYPE = 'CA' AND A1.CDNAME = 'CASTATUS' AND trim(A1.CDVAL) = trim(cas.STATUS)
            AND A2.CDTYPE = 'CF' AND A2.CDNAME = 'CUSTTYPE' AND trim(A2.CDVAL) = trim(cf.CUSTTYPE)
            AND cam.catype ='014'
            and cas.afacctno like V_STRAFACCTNO
            AND cam.camastid LIKE V_STRCACODE
            AND CAS.deltd<>'Y'
        ) CA,
        (
           SELECT Sum(NVL(Num_trf,0)) NUM_TRF, sum(NVL(num_rectrf,0)) NUM_RectrF, sum(NVL(SLDKM,0)) SLDKM,  acctno, codeid , autoid FROM
            (
              \* SELECT    substr(se.acctno,1,10) acctno, substr(se.acctno,11,6) codeid, SE.NAMT Num_trf, 0 Num_rectrf, 0 SLDKM, se.ref autoid
                FROM TLLOG TL, SETRAN SE, APPTX APP
                WHERE TL.TXNUM = SE.TXNUM AND TL.TXDATE = SE.TXDATE
                AND SE.TXCD = APP.TXCD AND TL.DELTD <> 'Y' AND TL.TLTXCD IN( '3382','3383','3385') -- bo 3384
                AND SE.TXCD IN('0040') AND APP.apptype ='SE'
                    ----and (tl.brid like V_STRBRID or INSTR(V_STRBRID,tl.brid) <> 0)
                UNION ALL
                SELECT    substr(se.acctno,1,10) acctno, substr(se.acctno,11,6) codeid, SE.NAMT Num_trf, 0 Num_rectrf, 0 SLDKM, se.ref autoid
                FROM TLLOGALL TL, SETRANA SE, APPTX APP
                WHERE TL.TXNUM = SE.TXNUM AND TL.TXDATE = SE.TXDATE
                AND SE.TXCD = APP.TXCD AND TL.DELTD <> 'Y' AND TL.TLTXCD IN( '3382','3383','3385')
                AND SE.TXCD IN('0040')AND APP.apptype ='SE'
                ---and (tl.brid like V_STRBRID or INSTR(V_STRBRID,tl.brid) <> 0)
                UNION  ALL
                SELECT    substr(se.acctno,1,10) acctno, substr(se.acctno,11,6) codeid, 0 Num_trf, SE.NAMT Num_rectrf, 0 SLDKM, se.ref autoid
                FROM TLLOG TL, SETRAN SE, APPTX APP
                WHERE TL.TXNUM = SE.TXNUM AND TL.TXDATE = SE.TXDATE
                AND SE.TXCD = APP.TXCD AND TL.DELTD <> 'Y' AND TL.TLTXCD IN( '3382','3383','3385')
                AND SE.TXCD IN('0045') AND APP.apptype ='SE'
                    ----and (tl.brid like V_STRBRID or INSTR(V_STRBRID,tl.brid) <> 0)
                UNION ALL
                SELECT    substr(se.acctno,1,10) acctno, substr(se.acctno,11,6) codeid, 0 Num_trf, SE.NAMT Num_rectrf, 0 SLDKM, se.ref autoid
                FROM TLLOGALL TL, SETRANA SE, APPTX APP
                WHERE TL.TXNUM = SE.TXNUM AND TL.TXDATE = SE.TXDATE
                AND SE.TXCD = APP.TXCD AND TL.DELTD <> 'Y' AND TL.TLTXCD IN( '3382','3383','3385')
               AND SE.TXCD IN('0045')AND APP.apptype ='SE'
               ---and (tl.brid like V_STRBRID or INSTR(V_STRBRID,tl.brid) <> 0)
               --3384*\

                 SELECT    substr(se.acctno,1,10) acctno, substr(se.acctno,11,6) codeid, SE.NAMT Num_trf, 0 Num_rectrf, 0 SLDKM, se.ref autoid
                FROM VW_SETRAN_GEN SE, APPTX APP
                WHERE  SE.TXCD = APP.TXCD AND SE.DELTD <> 'Y' AND SE.TLTXCD IN( '3382','3383','3385') -- bo 3384
                AND SE.TXCD IN('0040') AND APP.apptype ='SE'
                UNION  ALL
                SELECT    substr(se.acctno,1,10) acctno, substr(se.acctno,11,6) codeid, 0 Num_trf, SE.NAMT Num_rectrf, 0 SLDKM, se.ref autoid
                FROM  VW_SETRAN_GEN SE, APPTX APP
                WHERE  SE.TXCD = APP.TXCD AND SE.DELTD <> 'Y' AND SE.TLTXCD IN( '3382','3383','3385')
                AND SE.TXCD IN('0045') AND APP.apptype ='SE' --3384 NGOCVTT EDIT

                UNION ALL
              SELECT  CA.AFACCTNO acctno  ,CAMAST.optcodeid  codeid , 0 Num_trf, 0 Num_rectrf,  SUM(CA.QTTY)  SLDKM, to_char(CA.autoid) autoid
              FROM caschd CA , CAMAST
              WHERE CAMAST.camastid  = CA.camastid AND CAMAST.catype ='014'AND CA.QTTY >0
              GROUP BY CA.AFACCTNO, CAMAST.optcodeid, CA.autoid
            )GROUP BY acctno, codeid, autoid
        )TL,
       \* ( -- Begin SLQuyen
            select (mst.BALANCE -nvl(AMT.amt,0))balance , mst.acctno, mst.CODEID ,MST.CAMASTID, mst.autoid  from
            (
                   SELECT (CAS.PBALANCE + CAS.BALANCE ) BALANCE, CAS.AFACCTNO ACCTNO, CAM.CODEID CODEID,
                          CAM.CAMASTID CAMASTID, CAM.OPTCODEID, cas.autoid
                   FROM  CAMAST CAM, CASCHD CAS  WHERE  CAS.CAMASTID = CAM.CAMASTID AND  CAS.DELTD <>'Y'
             )mst,
             (
                   SELECT SUBSTR (AMT.ACCTNO,1,10) AFACCTNO , SUBSTR (AMT.ACCTNO,11,6)CODEID , SUM (AMT.AMT) AMT, AMT.autoid
                   FROM
                          (
                                 SELECT  SE.ACCTNO ,(CASE WHEN APP.TXTYPE = 'D'THEN -SE.NAMT WHEN APP.TXTYPE = 'C' THEN SE.NAMT ELSE 0  END ) AMT
                                         ,se.ref autoid
                                 FROM TLLOG TL, SETRAN SE, APPTX APP
                                 WHERE TL.TXNUM = SE.TXNUM AND TL.TXDATE = SE.TXDATE
                                 AND SE.TXCD = APP.TXCD AND TL.DELTD <> 'Y' AND TL.TLTXCD IN( '3382','3383','3385')
                                 AND SE.TXCD IN('0045','0040') AND APP.apptype ='SE'
                                    ---and (tl.brid like V_STRBRID or INSTR(V_STRBRID,tl.brid) <> 0)
                                 UNION ALL
                                 SELECT  SE.ACCTNO ,(CASE WHEN APP.TXTYPE = 'D'THEN -SE.NAMT WHEN APP.TXTYPE = 'C' THEN SE.NAMT ELSE 0  END ) AMT
                                         ,se.ref autoid
                                 FROM TLLOGALL TL, SETRANA SE, APPTX APP
                                 WHERE TL.TXNUM = SE.TXNUM AND TL.TXDATE = SE.TXDATE
                                 AND SE.TXCD = APP.TXCD AND TL.DELTD <> 'Y' AND TL.TLTXCD IN( '3382','3383','3385')
                                    ---and (tl.brid like V_STRBRID or INSTR(V_STRBRID,tl.brid) <> 0)
                                 AND SE.TXCD IN('0045','0040')AND APP.apptype ='SE'
                               )AMT
                            GROUP BY AMT.ACCTNO, AMT.autoid
                  )AMT
          where  mst.ACCTNO = AMT.AFACCTNO(+) AND  MST.OPTCODEID = AMT.CODEID(+) AND mst.autoid = amt.autoid(+)
        )SLQuyen,*\ -- NGOCVTT EDIT
       (  SELECT NVL(SUM(B.NAMT)-NVL(SUM(A.MSGAMT),0),0) AMT,B.CAMASTID,B.AFACCTNO
         FROM (
         select  SUM(NVL(SE.NAMT,0)) MSGAMT, NVL(SUBSTR(SE.ACCTNO,1,10),'') MSGACCT,NVL(CA.CAMASTID,'') CAMASTID
                       from vw_setran_gen SE,  CASCHD CA
                        WHERE SE.TLTXCD in ('3386','3326') AND SE.DELTD <>'Y' AND SE.TXCD='0015'
                        AND TO_CHAR(CA.AUTOID)=SE.REF(+)
                        AND CA.CAMASTID LIKE V_STRCACODE
                        and SE.txdate>= to_date(F_DATE,'dd/mm/yyyy')
                        and SE.txdate <= to_date(T_DATE,'dd/mm/yyyy')
                        GROUP BY SE.ACCTNO,CA.CAMASTID
                        ) A,(
          SELECT distinct SUM(SE.NAMT) NAMT,CHD.CAMASTID,SE.AFACCTNO
                FROM vw_setran_gen se, caschd chd, camast ca, sbsecurities sb
                WHERE to_char(chd.autoid) = se.REF AND chd.camastid = ca.camastid
                AND se.field = 'RECEIVING' AND sb.codeid = ca.codeid and se.tltxcd in ('3384','3324')
                 AND CHD.CAMASTID LIKE V_STRCACODE
                   and SE.txdate>= to_date(F_DATE,'dd/mm/yyyy')
                   and SE.txdate <= to_date(T_DATE,'dd/mm/yyyy')
                   GROUP BY CHD.CAMASTID,SE.AFACCTNO
                   ) B
                WHERE B.CAMASTID=A.CAMASTID(+)
                AND B.AFACCTNO=A.MSGACCT(+)
                AND B.CAMASTID LIKE V_STRCACODE
                GROUP BY B.CAMASTID,B.AFACCTNO
) ngay
    WHERE CA.camastid LIKE V_STRCACODE
    AND ca.brid LIKE V_I_BRIDGD
    and ca.camastid=ngay.camastid
    and ca.acctno=NGAY.AFACCTNO
    AND  CA.acctno = TL.acctno (+)
    AND CA.optcodeid = TL.codeid (+)
    AND CA.autoid = TL.autoid (+)
   -- AND CA.acctno = SLQuyen.acctno
   -- AND CA.camastid = SLQuyen.camastid
   -- AND CA.autoid = SLQuyen.autoid
    and tl.SLDKM<>0
    ORDER  BY ca.acctno
  ;
*/

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
 
 
 
/
