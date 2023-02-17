SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "BO10061" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   PV_CUSTID      IN       VARCHAR2,
   PV_BONDID      IN       VARCHAR2,
   PV_CONTRACTNO  IN       VARCHAR2
)
IS

   V_STROPTION     VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID       VARCHAR2 (4);                   -- USED WHEN V_NUMOPTION > 0

    V_CUSTID VARCHAR2 (100);
    V_BONDID VARCHAR2 (100);
BEGIN

   V_STROPTION := OPT;

  IF V_STROPTION = 'A' then
      V_STRBRID := '%';
  ELSIF V_STROPTION = 'B' then
      V_STRBRID := substr(BRID,1,2) || '__' ;
  else
      V_STRBRID:=BRID;
  END IF;

    V_CUSTID:=PV_CUSTID;
    V_BONDID:= PV_BONDID;


  -- GET REPORT'S DATA

OPEN PV_REFCURSOR FOR

SELECT BC.bondid, BC.txdesc, BC.custid
FROM bondcust bc
where BC.custid = V_CUSTID
    AND BC.BONDID = RTRIM(V_BONDID)

    ;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
