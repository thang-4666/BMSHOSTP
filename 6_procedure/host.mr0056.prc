SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "MR0056" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   pv_OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE         IN       VARCHAR2
)
IS
--
-- ---------   ------  -------------------------------------------
   l_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   l_STRBRID          VARCHAR2 (4);
   V_IDATE           DATE;
   V_INBRID        VARCHAR2(4);
   V_STRBRID      VARCHAR2 (50);
   V_STROPTION VARCHAR2(10);


BEGIN

   V_STROPTION := upper(pv_OPT);
   V_INBRID := pv_BRID;
    if(V_STROPTION = 'A') then
        V_STRBRID := '%%';
    else
        if(V_STROPTION = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
    end if;
V_IDATE:=TO_DATE(I_DATE,'DD/MM/YYYY');

-- GET REPORT'S DATA
    OPEN PV_REFCURSOR FOR
		SELECT * FROM
		(
				SELECT V_IDATE INDATE, MR.* FROM
				(
					SELECT SB.CODEID,SB.SYMBOL,RM.MRMAXQTTY,SB.BASICPRICE,RM.SEQTTY,RM.SEQTTY*SB.BASICPRICE GIA_TRI
					FROM SECURITIES_INFO SB, V_GETMARGINROOMINFO RM
					WHERE SB.CODEID=RM.CODEID
								AND (RM.MRMAXQTTY+RM.SEQTTY)<>0
								ORDER BY RM.SEQTTY DESC
				)MR
				where  Getcurrdate = V_IDATE
				UNION ALL
				SELECT * FROM log_mr0056 WHERE indate = V_IDATE
		)
		ORDER BY indate, seqtty DESC
    ;



 EXCEPTION
   WHEN OTHERS
   THEN
        RETURN;
END;

 
 
 
 
/
