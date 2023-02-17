SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CA0004" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   CACODE         IN       VARCHAR2,
   AFACCTNO       IN       VARCHAR2
  )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
-- BAO CAO TAI KHOAN TIEN TONG HOP CUA NGUOI DAU TU
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- HUNG.LB    23/Aug/2010 UPDATED
-- TRUONGLD MODIFYED 10/04/2010
-- CHAUNH them dk, ten moi gioi 11/05/2012
-- ---------   ------  -------------------------------------------

    CUR             PKG_REPORT.REF_CURSOR;
    V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
    V_STRBRID      VARCHAR2 (4);
    V_STRCACODE    VARCHAR2 (20);
    V_STRAFACCTNO   VARCHAR2 (20);

BEGIN
   V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (pv_BRID <> 'ALL')
   THEN
      V_STRBRID := pv_BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;

   IF (CACODE <> 'ALL')
   THEN
      V_STRCACODE := CACODE;
   ELSE
      V_STRCACODE := '%%';
   END IF;

      IF (AFACCTNO <> 'ALL')
   THEN
      V_STRAFACCTNO := AFACCTNO;
   ELSE
      V_STRAFACCTNO := '%%';
   END IF;

   -- GET REPORT'S PARAMETERS

--Tinh ngay nhan thanh toan bu tru


OPEN PV_REFCURSOR
   FOR
    SELECT (CASE WHEN SUBSTR(CA.custodycd,4,1) = 'P' THEN 'T? doanh' ELSE 'M?i gi?i' END) TYPELG_NAME, CA.CUSTTYPE_NAME, CA.ISS_NAME, ca.country,
           ca.acctno, ca.custodycd, ca.fullname, ca.address, ca.MOBILE, ca.IDCODE, ca.iddate, ca.RIGHTOFFRATE, ca.Catype,ca.status_af status_af,
           ca.status, ca.camastid, ca.amt, ca.symbol, ca.reportdate, ca.stcv, ca.actiondate, NVL(TL.NUM_TRF,0) NUM_TRF,CA.NMQTTY,CA.EXPRICE,
           NVL(TL.NUM_RectrF,0) NUM_RectrF, CA.codeid codeca, tl.codeid codetl, NVL(TL.SLDKM,0) SLDKM, ca.roundtype, CA.slctm,ca.aamt,
           --reaflnk.fullname ten_moi_gioi,
           ca.tocodeid, ca.tosymbol, ca.begindate, ca.duedate
    FROM /*(
            SELECT cfmast.fullname, reaflnk.afacctno FROM reaflnk, retype, cfmast
            WHERE retype.actype = substr(reaflnk.reacctno,11,4)
            AND retype.rerole IN ('BM','RM')
            AND reaflnk.status = 'A'
            AND cfmast.custid = substr(reaflnk.reacctno,1,10)
         )reaflnk, */
        (
            SELECT  cas.aamt,af.acctno acctno , cf.custodycd custodycd, cf.fullname fullname, cf.MOBILE mobile,
                (case when cf.country = '234' then cf.idcode else cf.tradingcode end) idcode,
                (case when cf.country = '234' then cf.iddate else cf.tradingcodedt end) iddate,
                cf.country, cf.address, cas.balance SLCKSH, cam.RIGHTOFFRATE rightoffrate, A0.cdcontent Catype,
                (case when cas.status<>'C' and cas.tqtty >0 then '? th?c hi?n 3387' else to_char( A1.cdcontent) end  ) status, cam.camastid camastid,
                cas.AMT AMT, se.symbol symbol, se.codeid codeid, cam.REPORTDATE reportdate, cas.qtty SLQMDNG,cas.NMqtty , cas.amt STCV, CAS.PQTTY SLQMDPB,
                cam.ACTIONDATE actiondate, cas.PBALANCE PBALANCE, cam.optcodeid optcodeid, cam.roundtype, AF.status status_af, CAM.EXPRICE,
                (cas.PQTTY+cas.QTTY) slctm, a2.cdcontent  AS CUSTTYPE_NAME, SE.ISS_NAME,
                nvl(sb2.symbol,se.symbol) tosymbol, nvl(sb2.codeid,se.codeid) tocodeid, cas.autoid, cam.begindate, cam.duedate
            FROM caschd cas, (SELECT ISSUERS.FULLNAME ISS_NAME, SB.* from SBSECURITIES SB, ISSUERS  WHERE SB.ISSUERID = ISSUERS.ISSUERID) se,
                 camast cam, afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, allcode A0, Allcode A1, allcode a2,
                 sbsecurities sb2
            WHERE cas.codeid = se.codeid
            AND nvl(cam.tocodeid, cas.codeid) = sb2.codeid
            AND cam.camastid = cas.camastid
            AND cas.afacctno = af.acctno
            AND af.custid = cf.custid
            AND CAS.STATUS<>'O'
            AND a0.CDTYPE = 'CA' AND a0.CDNAME = 'CATYPE' AND a0.CDVAL = cam.CATYPE
            AND A1.CDTYPE = 'CA' AND A1.CDNAME = 'CASTATUS' AND trim(A1.CDVAL) = trim(cas.STATUS)
            AND A2.CDTYPE = 'CF' AND A2.CDNAME = 'CUSTTYPE' AND trim(A2.CDVAL) = trim(cf.CUSTTYPE)
            AND cam.catype ='014'
            and cas.afacctno like V_STRAFACCTNO
            AND cam.camastid LIKE V_STRCACODE
            AND CAS.deltd<>'Y'
        ) CA,
        (
           SELECT Sum(NVL(Num_trf,0)) NUM_TRF, sum(NVL(num_rectrf,0)) NUM_RectrF, sum(NVL(SLDKM,0)) SLDKM,  acctno, codeid, autoid FROM
            (
               SELECT    substr(se.acctno,1,10) acctno, substr(se.acctno,11,6) codeid,
                        CASE WHEN tl.tltxcd in ( '3382','3383') AND SE.TXCD IN('0040') then SE.NAMT
                             WHEN tl.tltxcd IN ('3392','3353') AND se.txcd IN ('0045') THEN - se.namt
                             ELSE 0 END  Num_trf,
                        CASE WHEN tl.tltxcd = '3385' AND se.txcd = '0045' THEN SE.NAMT
                             WHEN tl.tltxcd = '3382' AND se.txtype = 'C' THEN se.namt
                             ELSE 0 END  Num_rectrf, 0 SLDKM, se.acctref autoid
                FROM vw_TLLOG_all TL, vw_SETRAN_gen SE
                WHERE TL.TXNUM = SE.TXNUM AND TL.TXDATE = SE.TXDATE
                AND TL.DELTD <> 'Y' AND TL.TLTXCD IN( '3382','3383','3392','3353','3385')
                AND SE.TXCD IN('0040','0045')
               --3384
                UNION ALL
              SELECT  CA.AFACCTNO acctno  ,CAMAST.optcodeid  codeid , 0 Num_trf, 0 Num_rectrf,  SUM(CA.QTTY)  SLDKM, to_char(ca.autoid) autoid
              FROM caschd CA , CAMAST
              WHERE CAMAST.camastid  = CA.camastid AND CAMAST.catype ='014'AND CA.QTTY >0 GROUP BY CA.AFACCTNO  ,CAMAST.optcodeid, ca.autoid
            )GROUP BY acctno, codeid, autoid
        )TL
        /*,
        ( -- Begin SLQuyen
            select (mst.BALANCE -nvl(AMT.amt,0))balance , mst.acctno, mst.CODEID ,MST.CAMASTID, mst.autoid  from
            (
                   SELECT (CAS.PBALANCE + CAS.BALANCE ) BALANCE, CAS.AFACCTNO ACCTNO, CAM.CODEID CODEID, CAM.CAMASTID CAMASTID, CAM.OPTCODEID, cas.autoid
                   FROM  CAMAST CAM, CASCHD CAS  WHERE  CAS.CAMASTID = CAM.CAMASTID AND  CAS.DELTD <>'Y'
             )mst,
             (
                   SELECT SUBSTR (AMT.ACCTNO,1,10) AFACCTNO , SUBSTR (AMT.ACCTNO,11,6)CODEID , SUM (AMT.AMT) AMT, AMT.acctref
                   FROM
                          (
                          SELECT  SE.ACCTNO ,(CASE WHEN APP.TXTYPE = 'D'THEN -SE.NAMT WHEN APP.TXTYPE = 'C' THEN SE.NAMT ELSE 0  END ) AMT, se.acctref
                                 FROM TLLOG TL, SETRAN SE, APPTX APP
                                 WHERE TL.TXNUM = SE.TXNUM AND TL.TXDATE = SE.TXDATE
                                 AND SE.TXCD = APP.TXCD AND TL.DELTD <> 'Y' AND TL.TLTXCD IN( '3382','3383','3385','3392','3353')
                                 AND SE.TXCD IN('0045','0040') AND APP.apptype ='SE'

                                 UNION ALL

                                 SELECT  SE.ACCTNO ,(CASE WHEN APP.TXTYPE = 'D'THEN -SE.NAMT WHEN APP.TXTYPE = 'C' THEN SE.NAMT ELSE 0  END ) AMT, se.acctref
                                 FROM TLLOGALL TL, SETRANA SE, APPTX APP
                                 WHERE TL.TXNUM = SE.TXNUM AND TL.TXDATE = SE.TXDATE
                                 AND SE.TXCD = APP.TXCD AND TL.DELTD <> 'Y' AND TL.TLTXCD IN( '3382','3383','3385', '3392','3353')
                                 AND SE.TXCD IN('0045','0040')AND APP.apptype ='SE'
                               )AMT

                            GROUP BY AMT.ACCTNO, AMT.acctref
                  )AMT
          where  mst.ACCTNO = AMT.AFACCTNO(+) AND  MST.OPTCODEID = AMT.CODEID(+) AND mst.autoid = amt.acctref(+)

        )SLQuyen */
    WHERE CA.camastid LIKE V_STRCACODE
---    AND ca.acctno = reaflnk.afacctno (+)
    AND  CA.acctno = TL.acctno (+)
    AND CA.optcodeid = TL.codeid (+)
    AND ca.autoid = TL.autoid (+)
/*    AND CA.camastid = SLQuyen.camastid
    AND CA.acctno = SLQuyen.acctno
    AND CA.autoid = SLQuyen.autoid
    AND CASE WHEN  NVL(SLQUYEN.Balance,0)-NVL(TL.NUM_TRF,0)+NVL(TL.NUM_RectrF,0) > 0 AND  V_STRPLSENT = 0 AND  ca.aamt = 0 THEN 1
             WHEN  NVL(SLQUYEN.Balance,0)-NVL(TL.NUM_TRF,0)+NVL(TL.NUM_RectrF,0) > 0 AND  V_STRPLSENT = 1 AND  ca.aamt > 0 THEN 1
             WHEN  V_STRPLSENT = -1 THEN 1
        ELSE 0
        END = 1 */
    ORDER  BY ca.acctno


  ;


EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
