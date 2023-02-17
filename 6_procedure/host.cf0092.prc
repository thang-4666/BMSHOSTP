SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF0092"(PV_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
                                     OPT          IN VARCHAR2,
                                     pv_BRID      IN VARCHAR2,
                                     TLGOUPS      IN VARCHAR2,
                                     TLSCOPE      IN VARCHAR2,
                                     F_DATE       IN VARCHAR2,
                                     T_DATE       IN VARCHAR2,
                                     AGREE        IN VARCHAR2,
                                     ISDISAGREE   IN VARCHAR2,
                                     ISUSSIGN     IN VARCHAR2,
                                     ISUS         IN VARCHAR2,
                                     ISOPPSITION  IN VARCHAR2) IS
  --

  -- ---------   ------  -------------------------------------------
  V_STROPTION   VARCHAR2(5); -- A: ALL; B: BRANCH; S: SUB-BRANCH
  V_STRBRID     VARCHAR2(40); -- USED WHEN V_NUMOPTION > 0
  V_INBRID      VARCHAR2(4);
  V_AGREE       VARCHAR2(40);
  V_ISDISAGREE  VARCHAR2(40);
  V_ISUSSIGN    VARCHAR2(40);
  V_ISUS        VARCHAR2(40);
  V_ISOPPSITION VARCHAR2(40);

BEGIN
  /*   V_STROPTION := upper(OPT);
   V_INBRID := pv_BRID;
  
  IF (V_STROPTION = 'A')
   THEN
      V_STRBRID := '%';
   ELSE if (V_STROPTION = 'B') then
            select brgrp.mapid into V_STRBRID from brgrp where brgrp.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
   END IF;*/

  V_STROPTION := OPT;

  IF (V_STROPTION <> 'A') AND (pv_BRID <> 'ALL') THEN
    V_STRBRID := pv_BRID;
  ELSE
    V_STRBRID := '%%';
  END IF;
  -- GET REPORT'S PARAMETERS

  IF (AGREE <> 'ALL' OR AGREE <> '') THEN
    V_AGREE := AGREE;
  ELSE
    V_AGREE := '%%';
  END IF;

  IF (ISDISAGREE <> 'ALL' OR ISDISAGREE <> '') THEN
    V_ISDISAGREE := ISDISAGREE;
  ELSE
    V_ISDISAGREE := '%%';
  END IF;

  IF (ISUSSIGN <> 'ALL' OR ISUSSIGN <> '') THEN
    V_ISUSSIGN := ISUSSIGN;
  ELSE
    V_ISUSSIGN := '%%';
  END IF;

  IF (ISUS <> 'ALL' OR ISUS <> '') THEN
    V_ISUS := ISUS;
  ELSE
    V_ISUS := '%%';
  END IF;
  IF (ISOPPSITION <> 'ALL' OR ISOPPSITION <> '') THEN
    V_ISOPPSITION := ISOPPSITION;
  ELSE
    V_ISOPPSITION := '%%';
  END IF;

  -- GET REPORT'S DATA

  OPEN PV_REFCURSOR FOR
  
    SELECT *
      FROM (SELECT CF.CUSTODYCD,
                   CF.CUSTID,
                   CF.FULLNAME,
                   FAT.OPNDATE,
                   to_char(CF.OPNDATE,'dd/mm/rrrr') OPDATE,
                   to_date(CF.OPNDATE,'dd/mm/rrrr') OPDATE1,
                   NVL(FAT.ISDISAGREE, '') ISDISAGREE,
                   NVL(FAT.ISOPPOSITION, '') ISOPPOSITION,
                   NVL(FAT.ISUSSIGN, '') ISUSSIGN,
                   FAT.REOPNDATE,
                   NVL(FAT.W9ORW8BEN, '') W9ORW8BEN,
                   NVL(FAT.ISUS, '') ISUS,
                   FAT.FIRSTCALL,
                   FAT.SECONDCALL,
                   FAT.THIRTHCALL,
                   /*(CASE
                     WHEN FAT.isuscitizen = 'Y' THEN
                      'Y'
                     WHEN FAT.isusplaceofbirth = 'Y' THEN
                      'Y'
                     WHEN FAT.isusmail = 'Y' THEN
                      'Y'
                     WHEN FAT.isusphone = 'Y' THEN
                      'Y'
                     WHEN FAT.isustranfer = 'Y' THEN
                      'Y'
                     WHEN FAT.isauthrigh = 'Y' THEN
                      'Y'
                     WHEN FAT.issoleaddress = 'Y' THEN
                      'Y'
                     ELSE
                      'N'
                   END) AGREE*/
                   'Y' AGREE
              FROM FATCA FAT,
                   (SELECT *
                      FROM CFMAST
                     WHERE FNC_VALIDATE_SCOPE(BRID,
                                              CAREBY,
                                              TLSCOPE,
                                              pv_BRID,
                                              TLGOUPS) = 0) CF
             WHERE FAT.CUSTID = CF.CUSTID)
     WHERE OPDATE1 >= to_date(F_DATE, 'dd/mm/rrrr')
       AND OPDATE1 <= to_date(T_DATE, 'dd/mm/rrrr')
       AND AGREE LIKE V_AGREE
       AND ISDISAGREE LIKE V_ISDISAGREE
       AND ISOPPOSITION LIKE V_ISOPPSITION
       AND ISUS LIKE V_ISUS
       AND ISUSSIGN LIKE V_ISUSSIGN
    
    ;

EXCEPTION
  WHEN OTHERS THEN
    RETURN;
END;
 
 
 
 
/
