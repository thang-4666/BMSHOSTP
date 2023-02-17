SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "DF0051" (
   PV_REFCURSOR             IN OUT   PKG_REPORT.REF_CURSOR,
   OPT                      IN       VARCHAR2,
   BBRID                     IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE         IN       VARCHAR2,
   P_RRTYPE         IN       VARCHAR2,
   P_DFTYPE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PV_AFACCTNO    IN       VARCHAR2,
   P_GROUPID        IN       VARCHAR2
       )
IS
    v_date  date;
    V_STROPTION         VARCHAR2  (5);
    V_STRBRID           VARCHAR2  (4);
    v_CUSTODYCD    varchar2(100);
    v_GROUPID    varchar2(100);
    v_AFAcctno     varchar2(100);
    v_DFTYPE    varchar2(4);
    v_RRTYPE    varchar2(4);
    l_BRID_FILTER        VARCHAR2(50);
    v_ToDate date;
    v_MinDate date;

BEGIN
    -- GET REPORT'S PARAMETERS
    V_STROPTION := OPT;

    IF V_STROPTION = 'A' then
        V_STRBRID := '%';
    ELSIF V_STROPTION = 'B' then
        V_STRBRID := substr(BBRID,1,2) || '__' ;
    else
        V_STRBRID:=BBRID;
    END IF;

    IF (V_STROPTION = 'A') THEN
  l_BRID_FILTER := '%';
ELSE if (V_STROPTION = 'B') then
        select brgrp.mapid into l_BRID_FILTER from brgrp where brgrp.brid = BBRID;
    else
        l_BRID_FILTER := BBRID;
    end if;
END IF;


    IF (PV_CUSTODYCD <> 'ALL' OR PV_CUSTODYCD <> '' OR PV_CUSTODYCD <> NULL) THEN
        v_CUSTODYCD := PV_CUSTODYCD;
    ELSE
        v_CUSTODYCD  := '%';
    END IF;

    IF (PV_AFACCTNO <> 'ALL' OR PV_AFACCTNO <> '' OR PV_AFACCTNO <> NULL) THEN
        v_AFAcctno := PV_AFACCTNO;
    ELSE
        v_AFAcctno  := '%';
    END IF;

    IF (P_GROUPID <> 'ALL' OR P_GROUPID <> '' OR P_GROUPID <> NULL) THEN
        v_GROUPID := P_GROUPID;
    ELSE
        v_GROUPID  := '%';
    END IF;

     IF (P_DFTYPE <> 'ALL' OR P_DFTYPE <> '' OR P_DFTYPE <> NULL) THEN
        v_DFTYPE := P_DFTYPE;
    ELSE
        v_DFTYPE  := '%';
    END IF;

     IF (P_RRTYPE <> 'ALL' OR P_RRTYPE <> '' OR P_RRTYPE <> NULL) THEN
        v_RRTYPE := P_RRTYPE;
    ELSE
        v_RRTYPE  := '%';
    END IF;
   v_ToDate:= to_date(I_DATE,'DD/MM/RRRR');
   select min(sbdate) into v_MinDate from sbcldr where sbdate >= v_ToDate and cldrtype='000' and holiday <> 'Y';

OPEN PV_REFCURSOR FOR
SELECT IDATE, CUSTODYCD, AFACCTNO, FULLNAME, CODEID, SYMBOL, DFREFPRICE ,DFRATE , SUM(RCVQTTY) RCVQTTY, SUM(BLOCKQTTY) BLOCKQTTY, SUM(OTHERQTTY) OTHERQTTY, SUM(TOTAL) TOTAL FROM (
  SELECT v_ToDate IDATE, DFM.ACCTNO,
    DFM.GROUPID, CF.CUSTODYCD, DFM.AFACCTNO, DFM.ACTYPE, CF.FULLNAME, DFM.ACCTNO, LNT.RRTYPE , A1.CDCONTENT, DFM.CODEID, SE.SYMBOL, DFM.DFRATE, SE.DFREFPRICE,
    DFM.RCVQTTY +  NVL(SETRAN.RCVQTTY,0) RCVQTTY,
        DFM.BLOCKQTTY + NVL(SETRAN.BLOCKQTTY,0) BLOCKQTTY,
        DFM.DFQTTY + DFM.CARCVQTTY + DFM.CACASHQTTY + NVL(SETRAN.OTHERQTTY,0) + NVL(SETRAN.sellqtty,0)  OTHERQTTY,
    (DFM.RCVQTTY +  NVL(SETRAN.RCVQTTY,0) + DFM.BLOCKQTTY + NVL(SETRAN.BLOCKQTTY,0) + DFM.DFQTTY + DFM.CARCVQTTY + NVL(SETRAN.OTHERQTTY,0) + NVL(SETRAN.sellqtty,0) ) * SE.DFREFPRICE * DFM.DFRATE /100
    + DFM.CACASHQTTY * DFM.DFRATE /100 TOTAL

FROM
  v_getdealinfo DFM ,AFMAST AF, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, BBRID, TLGOUPS)=0) CF, DFTYPE DFT, LNTYPE LNT, ALLCODE A1,
        (
            SELECT getcurrdate HISTDATE ,S.CODEID,S.SYMBOL, s.DFREFPRICE FROM securities_info s where getcurrdate = v_MinDate
            UNION ALL
            SELECT HISTDATE, SH.CODEID,SH.SYMBOL, SH.DFREFPRICE FROM securities_info_hist sh WHERE HISTDATE= v_MinDate
        ) SE,

        (
            SELECT GROUPID, ACCTNO, SUM(RCVQTTY) RCVQTTY, SUM (BLOCKQTTY) BLOCKQTTY, SUM(OTHERQTTY) OTHERQTTY, SUM(sellqtty) sellqtty FROM
            (
                 select dg.groupid, tran.acctno,tran.FIELD, CASE WHEN FIELD='RCVQTTY' THEN SUM(tran.qtty) ELSE 0 END RCVQTTY,  CASE WHEN FIELD='BLOCKQTTY' THEN SUM(tran.qtty) ELSE 0 END BLOCKQTTY,
                    CASE  WHEN FIELD NOT IN ('RCVQTTY','BLOCKQTTY') THEN SUM(tran.qtty) ELSE 0 END OTHERQTTY, 0 SELLQTTY  from dfgroup dg,
                      (
                          select df.groupid, df.acctno, ap.FIELD ,  sum(case when ap.txtype = 'D' then namt else -namt end ) qtty
                              from vw_dftran_all tran, apptx ap, vw_dfmast_all df
                              where tran.txcd = ap.txcd and ap.apptype = 'DF'  and tran.deltd <> 'Y'
                              and ap.field in ('DFQTTY', 'RCVQTTY', 'BLOCKQTTY' , 'CARCVQTTY' ,'CAQTTY','CACASHQTTY') and ap.txtype in ('C','D')
                              and df.acctno = tran.acctno
                              and tran.txdate > v_ToDate

                          group by df.groupid, df.acctno,ap.FIELD
                      ) tran
                      where tran.groupid = dg.groupid
                  group by dg.groupid, tran.acctno,tran.FIELD

                  UNION ALL

                 SELECT v.groupid, od.refid ACCTNO,'SELLQTTY' FIELD, 0 RCVQTTY, 0 BLOCKQTTY, 0 OTHERQTTY, sum(od.execqtty) sellqtty FROM vw_dfmast_all V, (
                       select odm.txdate ,od.orderid, od.refid, od.type, od.ordernum, od.qtty, od.deltd, od.status, -od.execqtty execqtty from odmapext od, odmast odm where od.deltd <>'Y' and od.execqtty >0 and od.orderid=odm.orderid
                            and odm.txdate = v_ToDate
/*                       union all
                       select odm.txdate ,od.orderid, od.refid, od.type, od.ordernum, od.qtty, od.deltd, od.status, od.execqtty from odmapexthist od, odmasthist odm where od.deltd <>'Y' and od.execqtty >0  and od.execqtty >0 and od.orderid=odm.orderid
                            and odm.txdate > v_ToDate*/
                       ) OD
                   WHERE v.acctno = od.refid
                   group by v.groupid, refid

            ) WHERE GROUPID LIKE v_GROUPID  GROUP BY GROUPID, ACCTNO

        ) SETRAN
WHERE   DFM.GROUPID LIKE v_GROUPID AND
        DFM.TXDATE <= v_ToDate AND
        DFM.ACTYPE=DFT.ACTYPE AND DFT.LNTYPE = LNT.ACTYPE AND
        DFM.AFACCTNO = AF.ACCTNO AND AF.CUSTID = CF.CUSTID
        AND DFM.CODEID=SE.CODEID AND LNT.RRTYPE=A1.CDVAL
        AND A1.CDNAME='RRTYPE' AND A1.CDTYPE='LN'
        AND CF.CUSTODYCD LIKE v_CUSTODYCD
        AND DFM.AFACCTNO LIKE v_AFAcctno AND
        LNT.RRTYPE LIKE v_RRTYPE AND DFM.ACTYPE LIKE v_DFTYPE
        and DFM.ACCTNO = SETRAN.ACCTNO (+) AND
        case when V_STROPTION = 'A' then 1 else instr(l_BRID_FILTER,substr(DFM.AFacctno,1,4)) end  <> 0
) GROUP BY        IDATE, CUSTODYCD, AFACCTNO, FULLNAME, CODEID, SYMBOL, DFREFPRICE,DFRATE
        ;



EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
 
 
 
/
