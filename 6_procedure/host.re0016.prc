SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE RE0016 (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   PV_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2
 )
IS

-- MODIFICATION HISTORY
-- PERSON      DATE       COMMENTS
-- Ngoc.vu      10/08/2016 Create
-- ---------   ------     -------------------------------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   -- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
   V_STRPV_CUSTODYCD  VARCHAR2(20);

   V_INBRID           VARCHAR2(4);
   V_STRBRID        VARCHAR2 (50);
   V_STRTLID        VARCHAR2(6);

   v_fromdate        date;
   v_fr_date         date;
   v_todate          date;
   v_date            date;
   V_CURRDATE        date;

   V_FULLNAME        VARCHAR2 (500);
   V_CUSTID          VARCHAR2 (20);
   
   v_nav_bg          number;
   v_nav_end         number;
   v_careceiving_end number;
   v_mrnml_end  number;
   v_mrfeeamt_end number;
   v_seamt_end  number;
   v_balance_n  number;
   v_balance_t number;
   v_feedepo number;
   v_adfeeamt number;
   v_adamt_end number;
   v_depofeeamt_end  number;
   v_other_paid number;
   v_rcamt_end number;
   v_intacr_end number;
   v_other_add number;
   
   
BEGIN

   V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (PV_BRID <> 'ALL')
   THEN
      V_STRBRID := PV_BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;

    V_STRPV_CUSTODYCD  := upper(PV_CUSTODYCD);

    v_fromdate       := to_date(F_DATE,'dd/mm/rrrr');
    v_todate         := to_date(T_DATE,'dd/mm/rrrr');
   
    select min(sbdate)
        into  v_fr_date
    from (
             select sb.sbdate from sbcldr sb
             where sb.cldrtype = '000' and sb.holiday = 'N' and sb.sbdate < v_fromdate
             order by sb.sbdate desc)
     where rownum <= 1;
     
    select to_date(varvalue,'dd/mm/rrrr') into V_CURRDATE from sysvar where varname = 'CURRDATE';


    SELECT FULLNAME, CUSTID  INTO V_FULLNAME , V_CUSTID
    FROM CFMAST
    WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0 AND CUSTODYCD = V_STRPV_CUSTODYCD;
    --neu lay ngay hien tai thi CFREVIEWLOG chua co, lay ngay hien tai -1
    select max(lastdate) into v_date from CFREVIEWLOG 
                        where lastdate <= v_todate and custid=V_CUSTID;
                        
Begin
      select NVL(sum(case when mr.MRTYPE in ('S','T') then tbl.BALANCE else 0 end),0) balance_t,
             NVL(sum(case when mr.MRTYPE not in ('S','T') then tbl.BALANCE else 0 end),0) balance_n
             into v_balance_t, v_balance_n
      from (       select txdate ,afacctno,custodycd, max(balance)BALANCE from TBL_MR3007_LOG 
                   where  custodycd=V_STRPV_CUSTODYCD
                   group by txdate, afacctno,custodycd)tbl, afmast af, aftype aft, mrtype mr
      where tbl.AFACCTNO=af.acctno
      and af.actype=aft.actype
      and aft.mrtype=mr.actype
      and tbl.txdate=(select max(txdate) from TBL_MR3007_LOG where txdate<=v_todate and custodycd=V_STRPV_CUSTODYCD)
      and tbl.CUSTODYCD=V_STRPV_CUSTODYCD;
EXCEPTION
   WHEN OTHERS
   THEN
    v_balance_t:=0;
    v_balance_n:=0;
END;                        
BEGIN

   select round(NVL(max(cf.nav),0)),round(NVL(max(cf.careceiving),0)),round(NVL(max(cf.mrnml),0)),
          round(NVL(max(cf.mrfeeamt),0)), round(NVL(max(cf.seamt),0)),
          round(NVL(max(cf.ADVAMT),0)),round(NVL(max(cf.DEPOFEEAMT),0)),
          round(NVL(max(cf.ODAMT),0)- NVL(max(cf.ADVAMT),0)-NVL(max(cf.DEPOFEEAMT),0)
          -NVL(max(cf.mrnml),0)-NVL(max(cf.mrfeeamt),0)),
          round(NVL(max(cf.RCVAMT),0)), round(NVL(max(cf.CRINTACR),0)),
          round(NVL(max(cf.CIAMT),0)+NVL(max(cf.ODAMT),0)-v_balance_t-v_balance_n
          -NVL(max(cf.RCVAMT),0)-NVL(max(cf.CRINTACR),0)-NVL(max(cf.CARECEIVING),0))
          into v_nav_end, v_careceiving_end,v_mrnml_end,v_mrfeeamt_end, v_seamt_end,
          v_adamt_end,v_depofeeamt_end, v_other_paid,v_rcamt_end,v_intacr_end,v_other_add
   from CFREVIEWLOG cf 
   where cf.lastdate = v_date
   and cf.custid= V_CUSTID;


 EXCEPTION
   WHEN OTHERS
   THEN
    v_nav_end:=0;
    v_careceiving_end :=0;
    v_mrnml_end:=0;
    v_mrfeeamt_end:=0;
    v_seamt_end:=0;
END;

BEGIN

   select round(NVL(nav,0)) into v_nav_bg
   from CFREVIEWLOG 
   where lastdate = (select min(lastdate) from CFREVIEWLOG where lastdate >= v_fr_date and custid=V_CUSTID)
   and custid= V_CUSTID;

 EXCEPTION
   WHEN OTHERS
   THEN
    v_nav_bg:=0;
END;

Begin
      SELECT nvl(round(sum(namt)),0) into v_feedepo
      FROM vw_citran_gen 
      WHERE tltxcd = '0088' and custid=V_CUSTID
            and busdate BETWEEN v_fromdate and v_date
            AND DELTD<>'Y' 
            AND field IN ('CIDEPOFEEACR') AND txtype = 'D';
 EXCEPTION
   WHEN OTHERS
   THEN
    v_feedepo:=0;
END;  
Begin    
      select round(nvl(sum(feeamt),0)) into v_adfeeamt
      from (select * from  adschd union all select * from adschdhist) ad,
      afmast af
      where af.acctno=ad.acctno
      and af.custid=V_CUSTID
      and ad.paidamt>0
      and ad.PAIDDATE  BETWEEN v_fromdate and v_date;
 EXCEPTION
   WHEN OTHERS
   THEN
    v_adfeeamt:=0;
END;      
      
     OPEN PV_REFCURSOR
     FOR 
        SELECT  cf.custid,cf.FULLNAME, cf.CUSTODYCD,v_adfeeamt  adfeeamt,
                v_nav_bg nav_bg,v_nav_end nav_end, v_careceiving_end careceiving_end,v_mrnml_end mrnml_end,
                v_mrfeeamt_end mrfeeamt_end, v_seamt_end seamt_end, round(v_balance_n) balance_n,round(v_balance_t) balance_t,
                v_adamt_end  adamt_end, v_depofeeamt_end depofeeamt_end, v_other_paid other_paid,
                v_rcamt_end rcamt_end, v_intacr_end intacr_end, v_other_add other_add,
                nvl(sum(case when tltxcd in ('1131','1141','1196','1191') then namt else 0 end),0) add_amt, --tien nop trong ky
                nvl(sum(case when tltxcd in ('1162') then namt 
                             when tltxcd='0088' and txcd='0012' then namt else 0 end),0) fee_non, -- phi ko ky han
                nvl(sum(case when tltxcd in ('3350','3354') then namt else 0 end),0) ca_amt, --tien co tuc ve trong ky
                nvl(sum(case when tltxcd in ('1101','1132','1190') then namt
                             when tltxcd='1114' then -namt else 0 end),0) cut_amt, --tien rut trong ky
                nvl(sum(case when tltxcd in ('8855','8856') then namt else 0 end),0) odfeeamt,  --phi lenh trong ky
                nvl(sum(case when tltxcd in ('5540','5567') and instr(nvl(trdesc, txdesc),'g')<=0 then namt else 0 end),0) fee_mr, --lai vay trong ky
                nvl(sum(case when tltxcd in ('1180','1182','1189') then namt else 0 end),0)+v_feedepo feedeposit ,  --phi luu ky
                nvl(sum(case when tltxcd in ('0066') then namt else 0 end),0) taxamt,  --thue tncn
                nvl(sum(case when tltxcd in ('3386') then -namt WHEN tltxcd in ('3384') then namt else 0 end),0) CA_MUA,  --TIEN THUC HIEN QUYEN
                nvl(sum(case when tltxcd in ('1110') and instr(trdesc,'l')>0 then namt else 0 end),0) fee_in_kyhan, --lai co ky han tra trongky 
                nvl(sum(case when tltxcd in ('5540','5567') and instr(nvl(trdesc, txdesc),'g')>0 then namt else 0 end),0) nml_mr_tk -- tien vay tra trongky
        FROM vw_citran_gen ci,  (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF
        WHERE FIELD='BALANCE' AND DELTD<>'Y' 
        AND TLTXCD IN ('1131','1141','1196','1162','1101','1132','0066','5540','5567','8855','8856',
            '1180','1182','1189','3350','3354','3387','3386','1114','3384','1191','1190','0088','1110')
        AND cf.CUSTID=V_CUSTID
        and cf.custid=ci.custid
        and ci.busdate BETWEEN v_fromdate and v_date
        GROUP BY cf.CUSTID ,cf.FULLNAME, cf.CUSTODYCD
        
        union all
        SELECT  V_CUSTID custid,V_FULLNAME FULLNAME,V_STRPV_CUSTODYCD CUSTODYCD,v_adfeeamt  adfeeamt,
                v_nav_bg nav_bg,v_nav_end nav_end, v_careceiving_end careceiving_end,v_mrnml_end mrnml_end,
                v_mrfeeamt_end mrfeeamt_end, v_seamt_end seamt_end, v_balance_n balance_n,v_balance_t balance_t,
                 v_adamt_end  adamt_end, v_depofeeamt_end depofeeamt_end, v_other_paid other_paid,
                v_rcamt_end rcamt_end, v_intacr_end intacr_end, v_other_add other_add,
                0 add_amt, --tien nop trong ky
                0 fee_non, -- phi ko ky han
                0 ca_amt, --tien co tuc ve trong ky
                0 cut_amt, --tien rut trong ky
                0 odfeeamt,  --phi lenh trong ky
                0 fee_mr, --lai vay trong ky
                0+v_feedepo feedeposit ,  --phi luu ky
                0 taxamt,  --thue tncn
                0 CA_MUA,  --TIEN THUC HIEN QUYEN
                0 fee_in_kyhan, --lai co ky han tra trongky 
                0 nml_mr_tk -- tien vay tra trongky
     
        from dual;

EXCEPTION
   WHEN OTHERS
   THEN

    OPEN PV_REFCURSOR
  FOR
  SELECT 0 A FROM DUAL WHERE 0=1;
End;

 
 
 
 
/
