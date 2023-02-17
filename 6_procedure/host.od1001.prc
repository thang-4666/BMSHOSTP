SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE od1001 (
   PV_REFCURSOR             IN OUT   PKG_REPORT.REF_CURSOR,
   OPT                      IN       VARCHAR2,
   pv_BRID                     IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE                   IN       VARCHAR2,
   T_DATE                   IN       VARCHAR2,
   P_REACCNTO               IN       VARCHAR2, --- MA MOI GIOI
   P_GRPID                  IN       VARCHAR2, --- XXXX : MA DIEM HO TRO ; ALL : TAT CA
   P_TRADEPLACE             IN       VARCHAR2, --- 001 : HOSE; 002 : HNX; 003 : OTC; 005 : UPCOM; ALL : TAT CA
   P_CUSTODYCD              IN       VARCHAR2,
   P_SECTYPE                IN       VARCHAR2, --- 001 : CO PHIEU; 006 : TRAI PHIEU ; ALL : TAT CA
   P_SYMBOL                 IN       VARCHAR2,
   P_EXECTYPE               IN       VARCHAR2, --- NB : MUA; NS : BAN ; ALL : TAT CA
   P_ODTYPE                 IN       VARCHAR2, --- 01 : LENH KHOP; ALL : TAT CA
   P_COUNTRY                IN       VARCHAR2, --- 01 : TRONG NUOC; 02 : NUOC NGOAI;  ALL : TAT CA
   P_CUSTTYPE               IN       VARCHAR2, --- I : CA NHAN ; B : TO CHUC ; ALL : TAT CA
   P_AFTYPE                 IN       VARCHAR2 --- T3 : TIEU KHOAN T3 ; Margin : TIEU KHOAN MARGIN ; ALL : TAT CA
   )
IS
-- MODIFICATION HISTORY
-- KET QUA KHOP LENH CUA KHACH HANG
-- PERSON      DATE    COMMENTS
-- NAMNT   15-JUN-08  CREATED
-- DUNGNH  08-SEP-09  MODIFIED
-- THENN    27-MAR-2012 MODIFIED    SUA LAI TINH PHI, THUE DUNG
-- ---------   ------  -------------------------------------------
   V_STROPTION      VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID        VARCHAR2 (4);            -- USED WHEN V_NUMOPTION > 0

    V_FROMDATE      DATE;
    V_TODATE        DATE;
    V_REACCNTO      VARCHAR2(30);
    V_GRPID         VARCHAR2(10);
    V_TRADEPLACE    VARCHAR2(10);
    V_CUSTODYCD     VARCHAR2(20);
    V_SECTYPE       VARCHAR2(20);
    V_SYMBOL        VARCHAR2(20);
    V_EXECTYPE      VARCHAR2(10);
    V_COUNTRY       VARCHAR2(10);
    V_CUSTTYPE      VARCHAR2(10);
    V_AFTYPE        VARCHAR2(10);

    V_EXECAMT       number;

   --V_TRADELOG CHAR(2);
   --V_AUTOID NUMBER;



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
   V_FROMDATE  := TO_DATE(F_DATE,'DD/MM/RRRR');
   V_TODATE    := TO_DATE(T_DATE,'DD/MM/RRRR');
   IF(P_REACCNTO IS NULL OR UPPER(P_REACCNTO) = 'ALL') THEN
        V_REACCNTO := '%';
   ELSE
        V_REACCNTO := P_REACCNTO;
   END IF;

   IF(P_GRPID IS NULL OR UPPER(P_GRPID) = 'ALL') THEN
        V_GRPID := '%';
   ELSE
        V_GRPID := P_GRPID;
   END IF;

   IF(P_TRADEPLACE IS NULL OR UPPER(P_TRADEPLACE) = 'ALL') THEN
        V_TRADEPLACE := '%';
   ELSE
        V_TRADEPLACE := P_TRADEPLACE;
   END IF;

   IF(P_CUSTODYCD IS NULL OR UPPER(P_CUSTODYCD) = 'ALL') THEN
        V_CUSTODYCD := '%';
   ELSE
        V_CUSTODYCD := P_CUSTODYCD;
   END IF;

   IF(P_SECTYPE IS NULL OR UPPER(P_SECTYPE) = 'ALL') THEN
        V_SECTYPE := '%';
   ELSE
        V_SECTYPE := P_SECTYPE;
   END IF;

   IF(P_SYMBOL IS NULL OR UPPER(P_SYMBOL) = 'ALL') THEN
        V_SYMBOL := '%';
   ELSE
        V_SYMBOL := P_SYMBOL;
   END IF;

   IF(P_EXECTYPE IS NULL OR UPPER(P_EXECTYPE) = 'ALL') THEN
        V_EXECTYPE := '%';
   ELSE
        V_EXECTYPE := P_EXECTYPE;
   END IF;

   IF(P_COUNTRY IS NULL OR UPPER(P_COUNTRY) = 'ALL') THEN
        V_COUNTRY := '%';
   ELSE
        V_COUNTRY := P_COUNTRY;
   END IF;

   IF(P_CUSTTYPE IS NULL OR UPPER(P_CUSTTYPE) = 'ALL') THEN
        V_CUSTTYPE := '%';
   ELSE
        V_CUSTTYPE := P_CUSTTYPE;
   END IF;

   IF(P_AFTYPE IS NULL OR UPPER(P_AFTYPE) = 'ALL') THEN
        V_AFTYPE := '%';
   ELSE
        V_AFTYPE := P_AFTYPE;
   END IF;

   IF (P_ODTYPE = '01') then
       V_EXECAMT := 0;
   else
       V_EXECAMT := -1;
   end if;

IF(P_GRPID IS NULL OR UPPER(P_GRPID) = 'ALL') THEN
       -- GET REPORT'S DATA
    OPEN PV_REFCURSOR FOR
       SELECT CF.CUSTODYCD, AF.ACCTNO AFACCTNO, CF.FULLNAME, OD.TXDATE, SB.SYMBOL, AL.CDCONTENT EXECTYPE_NAME,
            OD.orderid, OD.orderqtty, OD.quoteprice, OD.MATCHPRICE, OD.MATCHQTTY, od.via, OD.tlname,
            OD.MATCHPRICE*OD.MATCHQTTY EXECAMT, OD.FEERATE,
            (case when cf.custtype = 'B' and cf.vat = 'N' and cf.whtax ='N' then 0 else OD.TAXRATE end) TAXRATE, OD.FEEAMT,
            (case when cf.custtype = 'B' and cf.vat = 'N' and cf.whtax ='N' then 0 else OD.TAXSELLAMT end) TAXSELLAMT, OD.TXTIME,
            AFT.mnemonic, OD.EXECTYPE
        FROM SBSECURITIES SB, AFMAST AF, (SELECT * FROM CFMAST /*WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0*/)  CF, ALLCODE AL, AFTYPE AFT,
            (
                SELECT od.custid, OD.orderid, OD.orderqtty,
                    (case when od.pricetype = 'LO' then to_char(OD.quoteprice,'999G9999G999G999G999') else od.pricetype end) quoteprice, OD.TXDATE, OD.CODEID,
                    OD.EXECTYPE, iodfeeacr FEEAMT, iodtaxsellamt TAXSELLAMT,
                    OD.AFACCTNO, IOD.MATCHPRICE, IOD.MATCHQTTY,
                    CASE WHEN OD.EXECAMT > 0 AND OD.FEEACR =0 AND OD.STSSTATUS = 'N' THEN ROUND(ODT.DEFFEERATE,5) ELSE ROUND(OD.FEEACR/OD.EXECAMT*100,2) END FEERATE,
                    CASE WHEN OD.EXECAMT > 0 AND IOD.BORS = 'S' AND OD.STSSTATUS = 'N'
                    THEN ROUND(TO_NUMBER(SYS.VARVALUE),5) ELSE NVL(OD.TAXRATE,0) END TAXRATE,
                    nvl(re.reacctno,'111') reacctno, al.CDCONTENT via, TLP.tlname, OD.TXTIME,
                    NVL(RE.RETLID,'1111') RETLID
                FROM VW_IOD_ALL IOD, ODTYPE ODT, SYSVAR SYS, allcode al, tlprofiles tlp,
                    VW_ODMAST_ALL OD
                    INNER join
                    (
                        select reaf.reacctno reacctno, reaf.afacctno, reaf.frdate, reaf.todate,
                            nvl(reaf.clstxdate,to_date('01/01/2050','dd/mm/rrrr')) clstxdate,
                            REU.tlid RETLID
                        from reaflnk reaf, remast re, retype ret, reuserlnk REU
                        where reaf.deltd <> 'Y' and reaf.reacctno = re.acctno
                            and re.actype = ret.actype and ret.rerole = 'RM'
                            AND REAF.refrecflnkid = REU.refrecflnkid
                            AND REU.tlid = V_REACCNTO
                    ) re
                    on re.frdate  <= OD.txdate AND re.todate  >= OD.txdate
                        AND OD.txdate < re.clstxdate AND od.custid = re.afacctno
                WHERE OD.ORDERID = IOD.ORGORDERID AND IOD.DELTD = 'N' AND OD.DELTD = 'N'
                    AND ODT.ACTYPE = OD.ACTYPE AND SYS.GRNAME = 'SYSTEM' AND SYS.VARNAME = 'ADVSELLDUTY'
                    and al.cdname = 'VIA' and al.cdtype = 'OD' and od.via = al.cdval
                    and od.tlid = tlp.tlid
                    AND OD.EXECAMT > V_EXECAMT AND OD.EXECTYPE LIKE V_EXECTYPE
                    AND OD.TXDATE >= V_FROMDATE
                    AND OD.TXDATE <= V_TODATE
                    AND iod.TXDATE >= V_FROMDATE
                    AND iod.TXDATE <= V_TODATE
            ) OD /*INNER JOIN
            regrplnk REG
            ON OD.reacctno = REG.reacctno AND reG.frdate  <= OD.txdate AND reG.todate  >= OD.txdate
                        AND OD.txdate < NVL(reG.clstxdate,to_date('01/01/2050','dd/mm/rrrr'))*/
        WHERE OD.CODEID = SB.CODEID AND OD.AFACCTNO = AF.ACCTNO AND AF.CUSTID = CF.CUSTID
            AND AF.ACTYPE = AFT.ACTYPE AND AFT.mnemonic LIKE V_AFTYPE
            AND AL.CDNAME = 'EXECTYPE' AND AL.CDTYPE = 'OD' AND AL.CDVAL = OD.EXECTYPE
            AND OD.RETLID = V_REACCNTO /* AND REG.refrecflnkid = V_GRPID*/
            AND SB.TRADEPLACE LIKE V_TRADEPLACE AND CF.CUSTODYCD LIKE V_CUSTODYCD
            AND (CASE WHEN SB.SECTYPE = '003' THEN '006' ELSE SB.SECTYPE END) LIKE V_SECTYPE
            AND SB.SYMBOL LIKE V_SYMBOL AND CF.CUSTTYPE LIKE V_CUSTTYPE
            AND (CASE WHEN CF.COUNTRY = '234' THEN '01' ELSE '02' END) LIKE V_COUNTRY
        ORDER BY OD.AFACCTNO, OD.TXDATE, SB.SYMBOL, OD.ORDERID, OD.MATCHPRICE;
ELSE
       -- GET REPORT'S DATA
    OPEN PV_REFCURSOR FOR
       SELECT CF.CUSTODYCD, AF.ACCTNO AFACCTNO, CF.FULLNAME, OD.TXDATE, SB.SYMBOL, AL.CDCONTENT EXECTYPE_NAME,
            OD.orderid, OD.orderqtty, OD.quoteprice, OD.MATCHPRICE, OD.MATCHQTTY, od.via, OD.tlname,
            OD.MATCHPRICE*OD.MATCHQTTY EXECAMT, OD.FEERATE,
            (case when cf.custtype = 'B' and cf.vat = 'N' and cf.whtax ='N' then 0 else OD.TAXRATE end) TAXRATE, OD.FEEAMT,
            (case when cf.custtype = 'B' and cf.vat = 'N' and cf.whtax ='N' then 0 else OD.TAXSELLAMT end) TAXSELLAMT, OD.TXTIME,
            AFT.mnemonic, OD.EXECTYPE
        FROM SBSECURITIES SB, AFMAST AF, (SELECT * FROM CFMAST /*WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0*/)  CF, ALLCODE AL, AFTYPE AFT,
            (
                SELECT od.custid, OD.orderid, OD.orderqtty,
                (case when od.pricetype = 'LO' then to_char(OD.quoteprice,'999G9999G999G999G999') else od.pricetype end) quoteprice, OD.TXDATE, OD.CODEID,
                    OD.EXECTYPE, iodfeeacr FEEAMT, iodtaxsellamt TAXSELLAMT,
                    OD.AFACCTNO, IOD.MATCHPRICE, IOD.MATCHQTTY,
                    CASE WHEN OD.EXECAMT > 0 AND OD.FEEACR =0 AND OD.STSSTATUS = 'N' THEN ROUND(ODT.DEFFEERATE,5) ELSE ROUND(OD.FEEACR/OD.EXECAMT*100,2) END FEERATE,
                    CASE WHEN OD.EXECAMT > 0 AND IOD.BORS = 'S' AND OD.STSSTATUS = 'N'
                    THEN ROUND(TO_NUMBER(SYS.VARVALUE),5) ELSE NVL(OD.TAXRATE,0) END TAXRATE,
                    nvl(re.reacctno,'111') reacctno, al.CDCONTENT via, TLP.tlname, OD.TXTIME,
                    NVL(RE.RETLID,'1111') RETLID, re.rerole
                FROM VW_IOD_ALL IOD, ODTYPE ODT, SYSVAR SYS, allcode al, tlprofiles tlp,
                    VW_ODMAST_ALL OD
                    INNER join
                    (
                        select reaf.reacctno reacctno, reaf.afacctno, reaf.frdate, reaf.todate,
                            nvl(reaf.clstxdate,to_date('01/01/2050','dd/mm/rrrr')) clstxdate,
                            REU.tlid RETLID, ret.rerole
                        from reaflnk reaf, remast re, retype ret, reuserlnk REU
                        where reaf.deltd <> 'Y' and reaf.reacctno = re.acctno
                            and re.actype = ret.actype --and ret.rerole = 'RM'
                            AND REAF.refrecflnkid = REU.refrecflnkid
                            --AND REU.tlid = V_REACCNTO
                    ) re
                    on re.frdate  <= OD.txdate AND re.todate  >= OD.txdate
                        AND OD.txdate < re.clstxdate AND od.custid = re.afacctno
                WHERE OD.ORDERID = IOD.ORGORDERID AND IOD.DELTD = 'N' AND OD.DELTD = 'N'
                    AND ODT.ACTYPE = OD.ACTYPE AND SYS.GRNAME = 'SYSTEM' AND SYS.VARNAME = 'ADVSELLDUTY'
                    and al.cdname = 'VIA' and al.cdtype = 'OD' and od.via = al.cdval
                    and od.tlid = tlp.tlid
                    AND OD.EXECAMT > V_EXECAMT AND OD.EXECTYPE LIKE V_EXECTYPE
                    AND OD.TXDATE >= V_FROMDATE
                    AND OD.TXDATE <= V_TODATE
                    AND iod.TXDATE >= V_FROMDATE
                    AND iod.TXDATE <= V_TODATE
            ) OD , regrplnk REG, regrp rep

        WHERE OD.CODEID = SB.CODEID AND OD.AFACCTNO = AF.ACCTNO AND AF.CUSTID = CF.CUSTID
            AND AF.ACTYPE = AFT.ACTYPE AND AFT.mnemonic LIKE V_AFTYPE
            AND AL.CDNAME = 'EXECTYPE' AND AL.CDTYPE = 'OD' AND AL.CDVAL = OD.EXECTYPE
            and OD.reacctno = REG.reacctno AND reG.frdate  <= OD.txdate AND reG.todate  >= OD.txdate
            AND OD.txdate < NVL(reG.clstxdate,to_date('01/01/2050','dd/mm/rrrr'))
            AND OD.RETLID = V_REACCNTO AND REG.refrecflnkid = V_GRPID
            and reg.refrecflnkid = rep.autoid
            and (case when rep.grptype = 'R' then 'RD' else 'RM' end) = od.rerole
            AND SB.TRADEPLACE LIKE V_TRADEPLACE AND CF.CUSTODYCD LIKE V_CUSTODYCD
            AND (CASE WHEN SB.SECTYPE = '003' THEN '006' ELSE SB.SECTYPE END) LIKE V_SECTYPE
            AND SB.SYMBOL LIKE V_SYMBOL AND CF.CUSTTYPE LIKE V_CUSTTYPE
            AND (CASE WHEN CF.COUNTRY = '234' THEN '01' ELSE '02' END) LIKE V_COUNTRY
            ORDER BY OD.AFACCTNO, OD.TXDATE, SB.SYMBOL, OD.ORDERID, OD.MATCHPRICE;
END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
-- PROCEDURE

 
 
 
 
/
