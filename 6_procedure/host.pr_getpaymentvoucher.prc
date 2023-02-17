SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE pr_getpaymentvoucher(PV_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,pv_POTXNUM in varchar2,pv_OBJNAME in varchar2,pv_TLTXCD in varchar2)
is
v_count  number;
begin

        --LAY GD 3387
    if pv_OBJNAME ='CAMAST' then
        select count(*) into v_count
        from (
                select DISTINCT(pod.camastid)
                from POMAST PO , (
                select * from podetails
                union all
                select * from podetailshist
                ) pod
                where po.txnum = pod.potxnum and po.txdate = pod.potxdate
                    and PO.TXNUM= pv_POTXNUM
                );
        if v_count = 1 then
            OPEN PV_REFCURSOR FOR
            SELECT '1' FEETYPE, PO.*,PO.AMT CI_AMT,'' CI_BENEFBANK, '' CI_BENEFACCT,
                '' CI_BENEFCUSTNAME, '' CI_BENEFLICENSE, '' CI_BENEFIDDATE,
                '' CI_BENEFIDPLACE, '' CI_DESCRIPTION,'N' CI_IS1TRN,
                'BMSC ma TV 086 chuyen tien mua them co phieu ' || sb.symbol || ' NC ' || TO_CHAR(reportdate,'dd/mm/rrrr') ||' TL ' || CA.rightoffrate ||' gia mua ' || ca.exprice CA_DESCRIPTION,
                0 CI_VATAMT
            FROM POMAST PO , (
            select * from podetails
            union all
            select * from podetailshist
            ) pod, camast ca, sbsecurities sb
            where po.txnum = pod.potxnum and po.txdate = pod.potxdate
                and pod.camastid =  ca.camastid and ca.codeid = sb.codeid
                and PO.TXNUM = pv_POTXNUM;
        else
            OPEN PV_REFCURSOR FOR
            SELECT '1' FEETYPE, PO.*,PO.AMT CI_AMT,'' CI_BENEFBANK, '' CI_BENEFACCT,
                  '' CI_BENEFCUSTNAME, '' CI_BENEFLICENSE, '' CI_BENEFIDDATE,
                  '' CI_BENEFIDPLACE, '' CI_DESCRIPTION,'N' CI_IS1TRN, '' CA__DESCRIPTION, 0 CI_VATAMT
                  FROM POMAST PO  where PO.TXNUM= pv_POTXNUM;
        end if;

    ELSif pv_TLTXCD = '1108' then
        select count(POTXNUM)  into  v_count   from ciremittance where POTXNUM = pv_POTXNUM;
        if v_count >1 then
            OPEN PV_REFCURSOR FOR
            SELECT PO.*,CI.AMT CI_AMT,CI.FEEAMT CI_FEEAMT ,'' CI_BENEFBANK, '' CI_BENEFACCT,
              '' CI_BENEFCUSTNAME, '' CI_BENEFLICENSE, '' CI_BENEFIDDATE,
              '' CI_BENEFIDPLACE, '' CI_DESCRIPTION,'N' CI_IS1TRN, VAT CI_VATAMT
              FROM POMAST PO,
              (SELECT SUM(AMT) AMT,SUM(FEEAMT) FEEAMT,SUM(VAT) VAT,POTXNUM,MAX(POTXDATE) POTXDATE FROM
               CIREMITTANCE WHERE DELTD ='N' AND POTXNUM= pv_POTXNUM GROUP BY POTXNUM ) CI
              WHERE PO.TXNUM = CI.POTXNUM   AND PO.TXDATE = CI.POTXDATE AND PO.DELTD='N';
         else
            OPEN PV_REFCURSOR FOR
              SELECT PO.*,CI.AMT CI_AMT, CI.FEEAMT CI_FEEAMT,CI.BENEFBANK ||' - ' || CI.citybank || ' - ' || ci.cityef CI_BENEFBANK, CI.BENEFACCT CI_BENEFACCT,
              CI.BENEFCUSTNAME CI_BENEFCUSTNAME, CI.BENEFLICENSE CI_BENEFLICENSE, CI.BENEFIDDATE CI_BENEFIDDATE,
              CI.BENEFIDPLACE CI_BENEFIDPLACE,case when PO.DESCRIPTION is null then PO.DESCRIPTION else PO.DESCRIPTION  || (case when substr(ci.txnum,1,4)='6800' then ' (Online)' else '' end) end CI_DESCRIPTION,'Y' CI_IS1TRN,
              CI.VAT CI_VATAMT
              FROM POMAST PO, CIREMITTANCE CI
              WHERE PO.TXNUM = CI.POTXNUM AND CI.DELTD='N'
              AND PO.TXDATE = CI.POTXDATE AND PO.DELTD='N'
              AND CI.POTXNUM= pv_POTXNUM;
           END IF;
    else

     ---LAY GIAO DICH 1104
        select count(POTXNUM)  into  v_count   from ciremittance where POTXNUM = pv_POTXNUM;
        if v_count >1 then
         OPEN PV_REFCURSOR FOR
              SELECT PO.*,CI.AMT CI_AMT,CI.FEEAMT CI_FEEAMT , '' CI_BENEFBANK, '' CI_BENEFACCT,
              '' CI_BENEFCUSTNAME, '' CI_BENEFLICENSE, '' CI_BENEFIDDATE,
              '' CI_BENEFIDPLACE, '' CI_DESCRIPTION,'N' CI_IS1TRN, CI.VAT CI_VATAMT
              FROM POMAST PO,
              (SELECT SUM(AMT) AMT, SUM(FEEAMT) FEEAMT, SUM(VAT) VAT,POTXNUM,MAX(POTXDATE) POTXDATE FROM
               CIREMITTANCE WHERE DELTD ='N' AND POTXNUM= pv_POTXNUM GROUP BY POTXNUM ) CI
              WHERE PO.TXNUM = CI.POTXNUM   AND PO.TXDATE = CI.POTXDATE AND PO.DELTD='N'
            ;
        else
       OPEN PV_REFCURSOR FOR
           /*     SELECT PO.*,CI.AMT CI_AMT,CI.BENEFBANK ||' - ' || CI.citybank || ' - ' || ci.cityef CI_BENEFBANK, CI.BENEFACCT CI_BENEFACCT,
              CI.BENEFCUSTNAME CI_BENEFCUSTNAME, CI.BENEFLICENSE CI_BENEFLICENSE, CI.BENEFIDDATE CI_BENEFIDDATE,
              CI.BENEFIDPLACE CI_BENEFIDPLACE,case when PO.DESCRIPTION is null then PO.DESCRIPTION else PO.DESCRIPTION  || (case when substr(ci.txnum,1,4)='6800' then ' (Online)' else '' end) end CI_DESCRIPTION,'Y' CI_IS1TRN
              FROM POMAST PO, CIREMITTANCE CI
              WHERE PO.TXNUM = CI.POTXNUM AND CI.DELTD='N'
              AND PO.TXDATE = CI.POTXDATE AND PO.DELTD='N'
              AND CI.POTXNUM= pv_POTXNUM*/
               SELECT PO.*,CI.AMT CI_AMT, CI.FEEAMT CI_FEEAMT,CI.BENEFBANK ||' - ' || CI.citybank || ' - ' || ci.cityef CI_BENEFBANK, CI.BENEFACCT CI_BENEFACCT,
              CI.BENEFCUSTNAME CI_BENEFCUSTNAME, CI.BENEFLICENSE CI_BENEFLICENSE, CI.BENEFIDDATE CI_BENEFIDDATE,
              CI.BENEFIDPLACE CI_BENEFIDPLACE,
              case when PO.DESCRIPTION is null then  ''
               ELSE SUBSTR ( PO.DESCRIPTION,1,INSTR(PO.DESCRIPTION,'/') +1 )||'/ ' || CF.fullname||'/ '||' '||CF.custodycd   || (case when substr(ci.txnum,1,4)='6800' then ' (Online)' else '' end) end CI_DESCRIPTION,'Y' CI_IS1TRN,
                    CI.VAT CI_VATAMT
              FROM POMAST PO, CIREMITTANCE CI,AFMAST AF , CFMAST CF
              WHERE PO.TXNUM = CI.POTXNUM AND CI.DELTD='N'
              AND PO.TXDATE = CI.POTXDATE AND PO.DELTD='N'
              AND CI.acctno = AF.ACCTNO  AND AF.CUSTID = CF.CUSTID
              AND CI.POTXNUM= pv_POTXNUM;
        end if;
    end if;
exception when others then
    return;
end;
 
 
 
 
/
