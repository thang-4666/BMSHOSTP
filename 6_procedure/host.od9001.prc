SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "OD9001" (
   PV_REFCURSOR             IN OUT   PKG_REPORT.REF_CURSOR,
   OPT                      IN       VARCHAR2,
   BRID                     IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE                   IN       VARCHAR2,
   PV_CUSTODYCD             IN       VARCHAR2,
   PV_AFACCTNO              IN       VARCHAR2,
   VIATYPE                  IN       VARCHAR2,
   p_custid                 IN       VARCHAR2
   )
IS
-- MODIFICATION HISTORY
-- B?O C?O GIAO D?CH CH?NG KHO?N THEO S? T?I KHO?N KI? B?NG K?HOA H?NG M? GI?I PH?T SINH TRONG TH?NG
-- PERSON   DATE  COMMENTS
-- QUOCTA  29-12-2011  CREATED
-- GianhVG 03/03/2012 _modify
-- Them phan chia theo nguon tien quan ly cua khach hang
-- ---------   ------  -------------------------------------------
   V_STROPTION         VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID           VARCHAR2 (4);            -- USED WHEN V_NUMOPTION > 0

   V_IN_DATE           DATE;
   V_CRRDATE           DATE;
   V_CUSTODYCD         VARCHAR2(100);
   V_AFACCTNO          VARCHAR2(100);
   V_VIATYPE           VARCHAR2(100);
   v_fullname_au       VARCHAR2(1000);
   v_licenseno_au         VARCHAR2(1000);
BEGIN
v_fullname_au:='';
v_licenseno_au:='';
--select  fullname , licenseno into v_fullname_au,v_licenseno_au  from cfauth  where acctno =PV_AFACCTNO and custid = p_custid;

FOR REC IN (select  case when cfa.custid is null then cfa.fullname else cf2.fullname end fullname ,
                    case when cfa.custid is null then cfa.licenseno else cf2.idcode end licenseno
                from cfauth cfa, cfmast cf1, cfmast cf2, afmast af
                where af.acctno = PV_AFACCTNO and cfa.custid = p_custid
                AND AF.ACTYPE NOT IN ('0000')
                and cfa.custid = cf2.custid(+)
                and cfa.cfcustid = cf1.custid)
LOOP
v_fullname_au:=REC.FULLNAME;
v_licenseno_au:=REC.licenseno;

END LOOP;



    V_STROPTION := OPT;

    IF (V_STROPTION <> 'A') AND (BRID <> 'ALL')
    THEN
         V_STRBRID := BRID;
    ELSE
         V_STRBRID := '%%';
    END IF;

-- GET REPORT'S PARAMETERS

    V_CUSTODYCD    :=    upper(PV_CUSTODYCD);

    IF (PV_AFACCTNO <> 'ALL' OR PV_AFACCTNO <> '')
    THEN
         V_AFACCTNO    :=    PV_AFACCTNO;
    ELSE
         V_AFACCTNO    :=    '%';
    END IF;

    if(substr(VIATYPE,1,1) <> 'O') then
        V_VIATYPE    := 'F';
    else
        V_VIATYPE    := 'O';
    end if;


    V_IN_DATE  :=    TO_DATE(I_DATE, SYSTEMNUMS.C_DATE_FORMAT);

    SELECT TO_DATE(SY.VARVALUE, SYSTEMNUMS.C_DATE_FORMAT) INTO V_CRRDATE
    FROM SYSVAR SY WHERE SY.VARNAME = 'CURRDATE' AND SY.GRNAME = 'SYSTEM';

OPEN PV_REFCURSOR
FOR
select cf.fullname , (case when cf.country = '234' then cf.idcode else cf.tradingcode end) idcode,
    cf.custodycd, af.acctno,
    sb.symbol, od.orderqtty, --od.quoteprice,
    (CASE WHEN OD.PRICETYPE IN ('ATO','ATC')THEN  OD.PRICETYPE  ELSE   TO_CHAR(OD.QUOTEPRICE) END ) quoteprice,
    od.via, od.txdate,
   v_fullname_au fullname_au, v_licenseno_au licenseno_au,
    substr(cf.custodycd,1,1) custodycd_1, substr(cf.custodycd,2,1) custodycd_2,
    substr(cf.custodycd,3,1) custodycd_3, substr(cf.custodycd,4,1) custodycd_4,
    substr(cf.custodycd,5,1) custodycd_5, substr(cf.custodycd,6,1) custodycd_6,
    substr(cf.custodycd,7,1) custodycd_7, substr(cf.custodycd,8,1) custodycd_8,
    substr(cf.custodycd,9,1) custodycd_9, substr(cf.custodycd,10,1) custodycd_10,
    substr(af.acctno,1,1) afacctno_1,substr(af.acctno,2,1) afacctno_2,
    substr(af.acctno,3,1) afacctno_3,substr(af.acctno,4,1) afacctno_4,
    substr(af.acctno,5,1) afacctno_5,substr(af.acctno,6,1) afacctno_6,
    substr(af.acctno,7,1) afacctno_7,substr(af.acctno,8,1) afacctno_8,
    substr(af.acctno,9,1) afacctno_9,substr(af.acctno,10,1) afacctno_10,
    DECODE(OD.VIA, 'O', 'Có', DECODE(NVL(CFR.custid, '0'), '0', 'Không', 'Có')) CONFIRMED
    from afmast af, cfmast cf, sbsecurities sb,
    (
        select * from odmast
        where exectype = 'NB' and deltd = 'N' and txdate = V_IN_DATE
        union all
        select * from odmasthist
        where exectype = 'NB' and deltd = 'N' and txdate = V_IN_DATE
    ) od
    LEFT JOIN confirmodrsts CFR ON CFR.orderid = OD.orderid
    where od.afacctno = af.acctno
        and af.custid = cf.custid
        AND AF.ACTYPE NOT IN ('0000')
        and od.codeid = sb.codeid
        and cf.custodycd = V_CUSTODYCD
        and af.acctno like V_AFACCTNO
        AND (CASE WHEN OD.VIA = 'O' THEN 'O' ELSE 'F' END) LIKE V_VIATYPE
    ;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
