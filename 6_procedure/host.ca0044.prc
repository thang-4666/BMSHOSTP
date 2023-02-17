SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE ca0044 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID        IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
    F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   I_BRIDGD       IN       VARCHAR2,
   CACODE         IN       VARCHAR2,
   PV_AFACCTNO    IN       VARCHAR2,
   PLSENT         IN       varchar2,
   LOAI           IN       VARCHAR2
  )
IS
---------   ------  -------------------------------------------
--ngocvtt 05/05/15

    V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
    V_STRBRID      VARCHAR2 (40);
    V_INBRID       VARCHAR2 (4);
    V_STRCACODE    VARCHAR2 (20);
    V_STRAFACCTNO   VARCHAR2 (20);
     V_I_BRIDGD          VARCHAR2(100);
     V_BRNAME            NVARCHAR2(400);
     V_LOAI                 VARCHAR(100);

BEGIN
   V_STROPTION := upper(OPT);
   V_INBRID := pv_BRID;

   IF (V_STROPTION = 'A') THEN
      V_STRBRID := '%';
   ELSE if(V_STROPTION = 'B') then
            select brgrp.mapid into V_STRBRID from brgrp where brgrp.brid = V_INBRID;
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
      V_BRNAME   :=  ' Toan cong ty ';
   END IF;


  IF (LOAI <> 'ALL')
  THEN
     V_LOAI := LOAI;
  ELSE
   V_LOAI := '%%';
 END IF;
   -- GET REPORT'S PARAMETERS

OPEN PV_REFCURSOR
   FOR
         SELECT   PLSENT sendto,CUSTODYCD,BRNAME,MOBILESMS,FULLNAME,CAMASTID,IDCODE,IDDATE,ADDRESS,
             TEN_CK,CK_NHAN,CK_CHOT,RIGHTOFFRATE,SUM(MAXQTTY)MAXQTTY,
             SUM(MAXQTTY) - (SUM(suqtty) ) pbalance, SUM(AAMT) AAMT,REPORTDATE,NGAY_MUA,TODATETRANSFER
     FROM (
             SELECT CF.CUSTODYCD, CF.FULLNAME,   CAMAST.CAMASTID,af.acctno,
                    SYM.SYMBOL CK_NHAN, CA.PBALANCE PBALANCE, CA.PQTTY QTTY,
                    CA.PQTTY + CA.QTTY MAXQTTY, CA.PQTTY AVLQTTY, CA.QTTY SUQTTY, CAMAST.EXPRICE*CA.QTTY SUAAMT,
                     CA.PAAMT AAMT, camast.rightoffrate, cf.mobilesms,br.brname,
                    decode(cf.country, '234' , cf.idcode , cf.tradingcode) IDCODE,
                    CF.IDPLACE,  reportdate,
                    decode( cf.country , '234' , cf.iddate , cf.tradingcodedt ) IDDATE,
                    CF.ADDRESS,
                    iss.fullname ten_ck
                    ,CAMAST.DUEDATE TODATETRANSFER,CAMAST.BEGINDATE NGAY_MUA
                    ,AF.BANKACCTNO, AF.BANKNAME,
                    sym_org.symbol CK_CHOT, camast.isincode, cf.careby, CAMAST.isalloc
            FROM SBSECURITIES SYM,  CAMAST, CASCHD CA, AFMAST AF,
                  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF,
                   sbsecurities SYM_ORG, BRGRP BR, issuers iss
            WHERE  CA.AFACCTNO = AF.ACCTNO AND AF.CUSTID = CF.CUSTID
                  AND nvl(CAMAST.TOCODEID,camast.codeid) = SYM.CODEID AND CAMAST.camastid  = CA.camastid
                  AND CA.status <>'Y' AND CA.DELTD <> 'Y' AND CAMAST.catype='014' AND  CA.PQTTY > 0
                  AND to_date(camast.begindate,'DD/MM/YYYY') <= to_date(GETCURRDATE,'DD/MM/YYYY')
                  AND sym_org.codeid=camast.codeid       AND cf.brid = br.brid
                  and iss.issuerid = sym.issuerid
                  and ca.status<>'O' and ca.PBALANCE>0  --ngoc.vu edit chuyen khoan tat toan thi loai, so luong quyen mua con lai phai >0
                  AND CAMAST.camastid = V_STRCACODE
                  AND af.acctno like V_STRAFACCTNO
                  AND CF.BRID LIKE V_I_BRIDGD

          )
   GROUP BY CUSTODYCD,FULLNAME,CAMASTID,IDCODE,IDDATE,ADDRESS,BRNAME,MOBILESMS,RIGHTOFFRATE,TODATETRANSFER,
            TEN_CK,CK_NHAN,CK_CHOT, REPORTDATE,NGAY_MUA
   HAVING  SUM(MAXQTTY) - (SUM(suqtty) )> 0
            AND CASE WHEN SUM(suqtty)  = 0 THEN 'N'
                                 ELSE 'Y' END LIKE V_LOAI
   ORDER BY custodycd;
/*

     SELECT   PLSENT sendto,CUSTODYCD,BRNAME,MOBILESMS,FULLNAME,CAMASTID,IDCODE,IDDATE,ADDRESS,
                  TEN_CK,CK_NHAN,CK_CHOT,RIGHTOFFRATE,
             SUM(MAXQTTY)MAXQTTY,
                         --NVL(SUM(MAXQTTY)-SUM(SUQTTY),0) PBALANCE,
                          SUM(MAXQTTY) - (SUM(suqtty) - SUM(amt)) pbalance,
                         SUM(AAMT) AAMT,
                         REPORTDATE,NGAY_MUA,TODATETRANSFER
     FROM
         (
          SELECT MAXX.*, nvl(a.AMT,0) amt
          FROM
                    (
                                    ----------------------
                                    SELECT CF.CUSTODYCD, CF.FULLNAME,   CAMAST.CAMASTID,af.acctno,
                                    SYM.SYMBOL CK_NHAN, CA.PBALANCE PBALANCE, CA.PQTTY QTTY,
                                    CA.PQTTY + CA.QTTY MAXQTTY, CA.PQTTY AVLQTTY, CA.QTTY SUQTTY, CAMAST.EXPRICE*CA.QTTY SUAAMT,
                                     CA.PAAMT AAMT, camast.rightoffrate, cf.mobilesms,br.brname,
                                    decode(cf.country, '234' , cf.idcode , cf.tradingcode) IDCODE,
                                    CF.IDPLACE,  reportdate,
                                    decode( cf.country , '234' , cf.iddate , cf.tradingcodedt ) IDDATE,
                                    CF.ADDRESS,
                                    iss.fullname ten_ck
                                    ,CAMAST.DUEDATE TODATETRANSFER,CAMAST.BEGINDATE NGAY_MUA
                                    ,AF.BANKACCTNO, AF.BANKNAME,
                                    sym_org.symbol CK_CHOT, camast.isincode, cf.careby, CAMAST.isalloc
                                    FROM SBSECURITIES SYM,  CAMAST, CASCHD CA, AFMAST AF,
                                    (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF,
                                    sbsecurities SYM_ORG, BRGRP BR, issuers iss
                                    WHERE  CA.AFACCTNO = AF.ACCTNO AND AF.CUSTID = CF.CUSTID
                                    AND nvl(CAMAST.TOCODEID,camast.codeid) = SYM.CODEID AND CAMAST.camastid  = CA.camastid
                                    AND CA.status <>'Y' AND CA.DELTD <> 'Y' AND CAMAST.catype='014' AND  CA.PQTTY > 0
                                    AND to_date(camast.begindate,'DD/MM/YYYY') <= to_date(GETCURRDATE,'DD/MM/YYYY')
                                     AND sym_org.codeid=camast.codeid       AND cf.brid = br.brid
                                      and iss.issuerid = sym.issuerid
                                     AND CAMAST.camastid = V_STRCACODE
                                     AND af.acctno like V_STRAFACCTNO
                   AND CF.BRID LIKE V_I_BRIDGD
                                    --------------------------
          ) MAXX
                    LEFT JOIN
                    (
                         SELECT sum( case WHEN se.tltxcd IN ('3386','3326') THEN -nvl(se.namt,0) ELSE nvl(se.namt,0) END ) amt , chd.camastid, se.afacctno
                             FROM vw_setran_gen se, caschd chd
                             WHERE se.tltxcd IN ('3386','3384','3324','3326') AND se.field = 'RECEIVING'
                             AND se.ref = chd.autoid
                             AND se.txdate BETWEEN  to_date(F_DATE,'dd/MM/yyyy') AND  to_date(T_DATE,'dd/MM/yyyy')
                             GROUP BY chd.camastid, se.afacctno
                    ) a ON maxx.camastid = a.camastid AND maxx.acctno = a.afacctno

                )
                --WHERE (CASE WHEN MAXQTTY= PBALANCE THEN 'N' ELSE 'Y' END) LIKE  V_LOAI
        GROUP BY CUSTODYCD,FULLNAME,CAMASTID,IDCODE,IDDATE,ADDRESS,BRNAME,MOBILESMS,RIGHTOFFRATE,TODATETRANSFER,
               TEN_CK,CK_NHAN,CK_CHOT, REPORTDATE,NGAY_MUA
                HAVING  SUM(MAXQTTY) - (SUM(suqtty) - SUM(amt))> 0
                AND CASE WHEN SUM(suqtty) - SUM(amt) = 0 THEN 'N'
                                 ELSE 'Y' END LIKE V_LOAI
                ORDER BY custodycd

  ;
*/

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
 
 
 
/
