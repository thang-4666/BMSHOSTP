SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SA0014" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   TLID       IN       VARCHAR2

 )
IS

-- ---------   ------  -------------------------------------------
   V_STROPTION        VARCHAR2 (10);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID          VARCHAR2 (10);        -- USED WHEN V_NUMOPTION > 0
   V_STRTLID              VARCHAR2 (10);


BEGIN

   V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (BRID <> 'ALL')
   THEN
      V_STRBRID := BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;

   IF(TLID <> 'ALL')
   THEN
        V_STRTLID  := TLID;
   ELSE
        V_STRTLID  := '%%';
   END IF;



OPEN PV_REFCURSOR
  FOR

         SELECT V_STRTLID V_STRTLID, MA.MAKER_DT,MAKER_ID,MA.ACTION_FLAG,MA.COLUMN_NAME,
                fn_get_tlgroupname(MA.FROM_VALUE,MA.COLUMN_NAME) FROM_VALUE,
                fn_get_tlgroupname(MA.TO_VALUE,MA.COLUMN_NAME)TO_VALUE,
                (CASE WHEN MA.COLUMN_NAME='BRID' THEN 'Mã chi nhánh/phòng GD/Đơn Vị'
                WHEN MA.COLUMN_NAME='TLPRN' THEN 'Số điện thoại' else FLD.CAPTION end)CAPTION ,
                MA.MAKER_ID||':'||TL.TLNAME MAKER, MA.MAKER_TIME, TLP.*
         FROM MAINTAIN_LOG MA,TLPROFILES TLP, FLDMASTER FLD, TLPROFILES TL
         WHERE MA.TABLE_NAME='TLPROFILES'
             AND SUBSTR(MA.RECORD_KEY,9,4)=TLP.TLID
             AND TL.TLID=MA.MAKER_ID
             AND MA.ACTION_FLAG IN ('ADD','EDIT')
             AND (MA.FROM_VALUE IS NOT NULL OR MA.TO_VALUE IS NOT NULL)
             AND FLD.OBJNAME='SA.TLPROFILES'
             AND FLD.FLDNAME=MA.COLUMN_NAME
             AND MA.MAKER_DT BETWEEN TO_DATE(F_DATE,'DD/MM/YYYY') AND TO_DATE(T_DATE,'DD/MM/YYYY')
             AND TLP.TLID LIKE V_STRTLID

         UNION ALL
          SELECT V_STRTLID V_STRTLID, MA.MAKER_DT,MA.MAKER_ID,MA.ACTION_FLAG,MA.COLUMN_NAME,
               fn_get_tlgroupname(MA.FROM_VALUE,MA.COLUMN_NAME) FROM_VALUE,
                 fn_get_tlgroupname(MA.TO_VALUE,MA.COLUMN_NAME)TO_VALUE, 'Vị trí' CAPTION,
                  MA.MAKER_ID||':'||TL.TLNAME MAKER, MA.MAKER_TIME, TLP.*
         FROM MAINTAIN_LOG MA,TLPROFILES TLP,TLPROFILES TL
         WHERE MA.TABLE_NAME='TLPROFILES'
             AND SUBSTR(MA.RECORD_KEY,9,4)=TLP.TLID
             AND TL.TLID=MA.MAKER_ID
             AND MA.ACTION_FLAG IN ('ADD','EDIT')
             AND (MA.FROM_VALUE IS NOT NULL OR MA.TO_VALUE IS NOT NULL)
             AND MA.COLUMN_NAME='TLTYPE'
             AND MA.MAKER_DT BETWEEN TO_DATE(F_DATE,'DD/MM/YYYY') AND TO_DATE(T_DATE,'DD/MM/YYYY')
             AND TLP.TLID LIKE V_STRTLID

          ORDER BY MAKER_DT,MAKER_TIME;


 EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
