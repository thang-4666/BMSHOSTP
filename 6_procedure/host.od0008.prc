SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE od0008 (
   PV_REFCURSOR             IN OUT   PKG_REPORT.REF_CURSOR,
   OPT                      IN       VARCHAR2,
   pv_BRID                  IN       VARCHAR2,
   TLGOUPS                  IN       VARCHAR2,
   TLSCOPE                  IN       VARCHAR2,
   I_DATE                   IN       VARCHAR2,
   MAKER                    IN       VARCHAR2,
   LOAI                     IN       VARCHAR2,
   I_BRIDGD                 IN       VARCHAR2,
   VIA                      IN       VARCHAR2
   )
IS
-- MODIFICATION HISTORY
-- TH?NG K?L?NH THEO USER
-- PERSON      DATE    COMMENTS
-- NGOCVTT   15-JUN-15  CREATED
-- ---------   ------  -------------------------------------------
   V_STROPTION      VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID        VARCHAR2 (4);            -- USED WHEN V_NUMOPTION > 0
   V_I_BRID         VARCHAR2 (10);
   V_LOAI       VARCHAR2 (20);
   V_MAKER          VARCHAR2 (20);

   V_CUR_DATE       DATE ;
   V_VIA          VARCHAR2 (200);

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN
   V_STROPTION := OPT;


   IF (V_STROPTION <> 'A') AND (pv_BRID <> 'ALL')
   THEN
      V_STRBRID := pv_BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;

    -- GET REPORT'S PARAMETERS
   --
   IF (MAKER <> 'ALL')
   THEN
      V_MAKER := MAKER;
   ELSE
      V_MAKER := '%%';
   END IF;

   --
   IF (I_BRIDGD <> 'ALL')
   THEN
      V_I_BRID := I_BRIDGD;
   ELSE
      V_I_BRID := '%%';
   END IF;

   --
    IF (LOAI <> 'ALL')
   THEN
      V_LOAI := LOAI;
   ELSE
      V_LOAI := '%%';
   END IF;
      --
    IF (UPPER(VIA) <> 'ALL')
   THEN
      V_VIA := UPPER(VIA);
   ELSE
      V_VIA := '%%';
   END IF;

   SELECT TO_DATE(VARVALUE ,'DD/MM/YYYY') INTO V_CUR_DATE FROM SYSVAR WHERE VARNAME ='CURRDATE';


   -- GET REPORT'S DATA
    OPEN PV_REFCURSOR
     FOR

        SELECT TO_DATE(I_DATE,'DD/MM/YYYY') INDATE,V_LOAI LOAI,OD.TXDATE,OD.TLID,TL.TLFULLNAME TLNAME,TL.BRID,
               COUNT(OD.TYPE_OD1) TYPE_OD1, COUNT(OD.TYPE_OD2) TYPE_OD2, COUNT(OD.TYPE_OD3) TYPE_OD3, SUM(EX_B) EX_B,SUM(EX_S) EX_S
        FROM(
              SELECT OD.TXDATE,OD.TLID,(CASE WHEN OD.EXECTYPE IN ('NS','SS','MS','NB','BC')
                    THEN 'ORDER' ELSE '' END) TYPE_OD1,
                    (CASE WHEN OD.EXECTYPE IN ('CB','CS') THEN 'CANCEL' ELSE '' END) TYPE_OD2,
                    (CASE WHEN OD.EXECTYPE IN ('AS','AB') THEN 'AMEND' ELSE '' END) TYPE_OD3,
                    (CASE WHEN OD.EXECTYPE IN ('NB','BC') THEN OD.execamt ELSE 0 END) EX_B,
                    (CASE WHEN OD.EXECTYPE IN ('NS','SS','MS') THEN OD.execamt ELSE 0 END) EX_S ,cf.brid

              FROM VW_ODMAST_ALL OD,AFMAST AF, AFTYPE AFT, MRTYPE MR,
                   (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF,CONFIRMODRSTS CON

              WHERE OD.EXECTYPE IN ('NS','SS','MS','NB','BC','CB','CS','AB','AS')
                    AND OD.AFACCTNO=AF.ACCTNO
                    AND AF.CUSTID=CF.CUSTID
                    AND AF.ACTYPE=AFT.ACTYPE
                    AND AFT.MRTYPE=MR.ACTYPE
                    AND OD.ORDERID = CON.ORDERID(+)
                    AND nvl(CON.confirmed,'N') ='N'
                    AND MR.MRTYPE LIKE V_LOAI
                    AND OD.VIA LIKE V_VIA
                    AND OD.TLID<>'6868'
                    AND OD.TXDATE=TO_DATE(I_DATE,'DD/MM/YYYY')
                    AND OD.TLID LIKE V_MAKER
                    AND cf.BRID LIKE V_I_BRID
                    ) OD, TLPROFILES TL
        WHERE OD.TLID=TL.TLID

        GROUP BY OD.TXDATE,OD.TLID,TL.TLFULLNAME,TL.BRID
        ORDER BY  OD.TXDATE,OD.TLID;


EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
-- PROCEDURE

 
 
 
 
/
