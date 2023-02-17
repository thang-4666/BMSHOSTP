SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CF0040" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   pv_OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   pv_AFACCTNO       IN       VARCHAR2--,
   --TLID            IN       VARCHAR2
)
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- LINHLNB   11-Apr-2012  CREATED
-- ---------   ------  -------------------------------------------
   l_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   l_STRBRID          VARCHAR2 (4);
   l_AFACCTNO         VARCHAR2 (20);


   l_cimastcheck_arr txpks_check.cimastcheck_arrtype;
   l_baldefovd number(20,0);
   l_balance number(20,0);
   l_emkamt number(20,0);
   l_bamt number(20,0);
   l_avladvance number(20,0);
   l_paidamt number(20,0);
   l_advanceamount  number(20,0);
   l_OUTSTANDING  number(20,0);
   l_NAVACCOUNT  number(20,0);
   l_ODAMT number(20,0);
   l_DUEAMT number(20,0);
   l_OVAMT number(20,0);
   l_TRFBUYAMT number(20,0);
   l_DEPOFEEAMT number(20,0);
   l_DFODAMT number(20,0);
   l_MARGINRATE number(20,4);
   l_MRIRATE number(20,4);
   l_MRMRATE number(20,4);
   l_MRLRATE number(20,4);
   l_MRCRLIMITMAX number(20,4);
   l_ADVANCELINE number(20,4);
   l_AVLLIMIT number(20,4);
   l_CUSTODYCD varchar2(20);
   l_FULLNAME varchar2(2000);
   l_MARGINTYPE varchar2(1000);
   l_AUTOADV    VARCHAR2(1);
   l_MRSTATUS    VARCHAR2(1);
   l_AVLADVAMT  NUMBER;
   l_MARGINTYPECD varchar2(1);

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE
BEGIN
   l_STROPTION := pv_OPT;

   IF (l_STROPTION <> 'A') AND (pv_BRID <> 'ALL')
   THEN
      l_STRBRID := pv_BRID;
   ELSE
      l_STRBRID := '%%';
   END IF;
   l_AFACCTNO  := replace(pv_AFACCTNO,'.','');
   -- END OF GETTING REPORT'S PARAMETERS

   l_CIMASTcheck_arr := txpks_check.fn_cimastcheck(l_AFACCTNO,'CIMAST','ACCTNO');

   l_BALDEFOVD := l_CIMASTcheck_arr(0).BALDEFOVD;
   l_BALANCE := l_CIMASTcheck_arr(0).BALANCE;
   l_bamt := l_CIMASTcheck_arr(0).bamt;
   l_avladvance := l_CIMASTcheck_arr(0).avladvance;
   l_paidamt := l_CIMASTcheck_arr(0).paidamt;
   l_advanceamount := l_CIMASTcheck_arr(0).advanceamount;
   l_OUTSTANDING := l_CIMASTcheck_arr(0).OUTSTANDING;
   l_NAVACCOUNT := l_CIMASTcheck_arr(0).NAVACCOUNT;
   l_ODAMT := to_number(l_CIMASTcheck_arr(0).ODAMT);
   l_DUEAMT := l_CIMASTcheck_arr(0).DUEAMT;
   l_OVAMT := l_CIMASTcheck_arr(0).OVAMT;
   l_AVLLIMIT := to_number(l_CIMASTcheck_arr(0).AVLLIMIT);
   l_emkamt := l_CIMASTcheck_arr(0).EMKAMT;
   l_MARGINTYPECD := l_CIMASTcheck_arr(0).MRTYPE;



   -- DEPOFEEAMT
   select nvl(sum(DEPOFEEAMT),0), nvl(sum(DFODAMT),0), nvl(sum(trfbuyamt),0) into l_DEPOFEEAMT, l_DFODAMT, l_TRFBUYAMT from cimast where acctno = l_AFACCTNO;
   --
   select nvl(sum(MARGINRATE),0)
        into l_MARGINRATE
   from v_getsecmarginratio
   where afacctno = l_AFACCTNO;
   --
   select af.MRIRATE, af.MRMRATE, af.MRLRATE, af.MRCRLIMITMAX, af.ADVANCELINE, aft.mnemonic
   into l_MRIRATE, l_MRMRATE, l_MRLRATE, l_MRCRLIMITMAX, l_ADVANCELINE, l_MARGINTYPE
   from afmast af, aftype aft where af.actype = aft.actype and acctno = l_AFACCTNO;


    select custodycd, fullname, af.autoadv, CASE WHEN mr.mrtype IN ('N','L') THEN 'N' WHEN mr.mrtype IN ('S','T') THEN 'Y' ELSE 'N' END MRSTATUS
    into l_CUSTODYCD, l_FULLNAME, l_AUTOADV, l_MRSTATUS
    from (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af, aftype aft, mrtype mr
    where cf.custid = af.custid
        AND af.actype = aft.actype
        AND aft.mrtype = mr.actype
        and af.acctno = l_AFACCTNO;


    -- LAY THONG TIN SO TIEN CHUA UNG TRUOC
    SELECT nvl(sum(GREATEST(MAXAVLAMT-ROUND(DEALPAID,0),0)),0) MAXAVLAMT
    INTO l_AVLADVAMT
    FROM
        (
            SELECT VW.MAXAVLAMT,
                (CASE WHEN VW.TXDATE =TO_DATE(SYS.VARVALUE,'DD/MM/RRRR') THEN fn_getdealgrppaid(VW.ACCTNO) ELSE 0 END)*
                    (1+ADT.ADVRATE/100/360*VW.days) DEALPAID
            FROM VW_ADVANCESCHEDULE VW, SYSVAR SYS, AFMAST AF, AFTYPE AFT ,ADTYPE ADT
            WHERE SYS.GRNAME='SYSTEM' AND SYS.VARNAME ='CURRDATE'
                AND VW.ACCTNO = AF.ACCTNo AND AF.ACTYPE=AFT.ACTYPE AND AFT.ADTYPE=ADT.ACTYPE
                AND VW.acctno = l_AFACCTNO
        );

   -- GET REPORT'S DATA
    OPEN PV_REFCURSOR
        FOR
        select * from (

          select 1 REFNUM, cdcontent REFNAME,
            case when l_MARGINTYPECD = 'T' then  l_avladvance + l_balance + l_bamt - l_ovamt - l_depofeeamt
                else l_avladvance + l_balance - l_ovamt - l_trfbuyamt - l_depofeeamt end REFVAL,
            case when l_MARGINTYPECD = 'T' then '{9}+{4}-{14}-{15}' else '{9}+{4}-{14}-{15}-{5}-{6}' end REFFORMULA, l_CUSTODYCD CUSTODYCD, l_FULLNAME FULLNAME, l_AFACCTNO AFACCTNO, l_MARGINTYPE MARGINTYPE, l_AUTOADV AUTOADV, l_BALDEFOVD BALDEFOVD
            ,0 groupnum,'WITHDRAW' grouprpt from dual, allcode where cdtype = 'CF' and cdname = 'CF0040' and cdval = 'BALDEFOVD'
          union all
          select 2 REFNUM, cdcontent REFNAME,
            case when l_MARGINTYPECD = 'T' then (100 * l_NAVACCOUNT + (l_OUTSTANDING -l_ADVANCELINE) * l_MRIRATE) / l_MRIRATE else greatest(l_BALDEFOVD,0) end REFVAL,
            case when l_MARGINTYPECD = 'T' then '(100x{11}-{12}*{18})/{18}' else '' end REFFORMULA, l_CUSTODYCD CUSTODYCD, l_FULLNAME FULLNAME, l_AFACCTNO AFACCTNO, l_MARGINTYPE MARGINTYPE, l_AUTOADV AUTOADV, l_BALDEFOVD BALDEFOVD
            ,0 groupnum,'WITHDRAW' grouprpt from dual, allcode where cdtype = 'CF' and cdname = 'CF0040' and cdval = 'RATELIMIT'
          union all
          /*select 3 REFNUM, cdcontent REFNAME,
            case when l_MARGINTYPECD = 'T' then l_AVLLIMIT-l_ADVANCELINE else greatest(l_BALDEFOVD,0) end REFVAL,
            case when l_MARGINTYPECD = 'T' then '{21}-{16}-{12}' else '' end REFFORMULA, l_CUSTODYCD CUSTODYCD, l_FULLNAME FULLNAME, l_AFACCTNO AFACCTNO, l_MARGINTYPE MARGINTYPE, l_AUTOADV AUTOADV, l_BALDEFOVD BALDEFOVD
            ,0 groupnum,'WITHDRAW' grouprpt from dual, allcode where cdtype = 'CF' and cdname = 'CF0040' and cdval = 'AVLLIMIT'
          union all*/
          select 4 REFNUM, cdcontent REFNAME, l_BALANCE + l_bamt REFVAL, '' REFFORMULA, l_CUSTODYCD CUSTODYCD, l_FULLNAME FULLNAME, l_AFACCTNO AFACCTNO, l_MARGINTYPE MARGINTYPE, l_AUTOADV AUTOADV, l_BALDEFOVD BALDEFOVD
            ,1 groupnum,'BALANCE' grouprpt from dual, allcode where cdtype = 'CF' and cdname = 'CF0040' and cdval = 'BALANCE'
          union all
          select 5 REFNUM, cdcontent REFNAME, l_bamt - l_TRFBUYAMT REFVAL, '' REFFORMULA, l_CUSTODYCD CUSTODYCD, l_FULLNAME FULLNAME, l_AFACCTNO AFACCTNO, l_MARGINTYPE MARGINTYPE, l_AUTOADV AUTOADV, l_BALDEFOVD BALDEFOVD
            ,1 groupnum,'BALANCE' grouprpt from dual, allcode where cdtype = 'CF' and cdname = 'CF0040' and cdval = 'SECUREDAMT'
          union all
          select 6 REFNUM, cdcontent REFNAME, l_TRFBUYAMT REFVAL, '' REFFORMULA, l_CUSTODYCD CUSTODYCD, l_FULLNAME FULLNAME, l_AFACCTNO AFACCTNO, l_MARGINTYPE MARGINTYPE, l_AUTOADV AUTOADV, l_BALDEFOVD BALDEFOVD
            ,1 groupnum,'BALANCE' grouprpt from dual, allcode where cdtype = 'CF' and cdname = 'CF0040' and cdval = 'TRFBUYAMT'
          union all
          select 7 REFNUM, cdcontent REFNAME, l_advanceamount REFVAL, '' REFFORMULA, l_CUSTODYCD CUSTODYCD, l_FULLNAME FULLNAME, l_AFACCTNO AFACCTNO, l_MARGINTYPE MARGINTYPE, l_AUTOADV AUTOADV, l_BALDEFOVD BALDEFOVD
            ,1 groupnum,'BALANCE' grouprpt from dual, allcode where cdtype = 'CF' and cdname = 'CF0040' and cdval = 'ADVANCEAMOUNT'
          union all
          select 8 REFNUM, cdcontent REFNAME, l_paidamt REFVAL, '' REFFORMULA, l_CUSTODYCD CUSTODYCD, l_FULLNAME FULLNAME, l_AFACCTNO AFACCTNO, l_MARGINTYPE MARGINTYPE, l_AUTOADV AUTOADV, l_BALDEFOVD BALDEFOVD
            ,1 groupnum,'BALANCE' grouprpt from dual, allcode where cdtype = 'CF' and cdname = 'CF0040' and cdval = 'PAIDAMT'
          union all
          select 9 REFNUM, cdcontent REFNAME, l_avladvance REFVAL, '' REFFORMULA, l_CUSTODYCD CUSTODYCD, l_FULLNAME FULLNAME, l_AFACCTNO AFACCTNO, l_MARGINTYPE MARGINTYPE, l_AUTOADV AUTOADV, l_BALDEFOVD BALDEFOVD
            ,1 groupnum,'BALANCE' grouprpt from dual, allcode where cdtype = 'CF' and cdname = 'CF0040' and cdval = 'AVLADVANCE'
          union all
          select 10 REFNUM, cdcontent REFNAME, l_emkamt REFVAL, '' REFFORMULA, l_CUSTODYCD CUSTODYCD, l_FULLNAME FULLNAME, l_AFACCTNO AFACCTNO, l_MARGINTYPE MARGINTYPE, l_AUTOADV AUTOADV, l_BALDEFOVD BALDEFOVD
            ,1 groupnum,'BALANCE' grouprpt from dual, allcode where cdtype = 'CF' and cdname = 'CF0040' and cdval = 'EMKAMT'
          union all
          select 11 REFNUM, cdcontent REFNAME, l_NAVACCOUNT REFVAL, '' REFFORMULA, l_CUSTODYCD CUSTODYCD, l_FULLNAME FULLNAME, l_AFACCTNO AFACCTNO, l_MARGINTYPE MARGINTYPE, l_AUTOADV AUTOADV, l_BALDEFOVD BALDEFOVD
            ,2 groupnum,'ASS' grouprpt from dual, allcode where cdtype = 'CF' and cdname = 'CF0040' and cdval = 'NAVACCOUNT'
          union all
          --ci.balance + nvl(se.avladvance,0)- ci.odamt - ci.depofeeamt -nvl(se.secureamt,0) - ci.trfbuyamt
          --- l_OUTSTANDING  - l_ADVANCELINE
          ---(l_avladvance + l_balance- l_ODAMT - l_DEPOFEEAMT)
          select 12 REFNUM, cdcontent REFNAME,
            case when l_MARGINTYPECD = 'T' then -(l_avladvance + l_balance- l_ODAMT - l_DEPOFEEAMT) else 0 end REFVAL,
            case when l_MARGINTYPECD = 'T' then '({5}+{6}+{13}+{14}+{15}-{4}-{9})' else '' end REFFORMULA, l_CUSTODYCD CUSTODYCD, l_FULLNAME FULLNAME, l_AFACCTNO AFACCTNO, l_MARGINTYPE MARGINTYPE, l_AUTOADV AUTOADV, l_BALDEFOVD BALDEFOVD
            ,3 groupnum,'OD' grouprpt from dual, allcode where cdtype = 'CF' and cdname = 'CF0040' and cdval = 'OUTSTANDING'
          union all
          select 13 REFNUM, cdcontent REFNAME, l_ODAMT-(l_DUEAMT + l_OVAMT) REFVAL, '' REFFORMULA, l_CUSTODYCD CUSTODYCD, l_FULLNAME FULLNAME, l_AFACCTNO AFACCTNO, l_MARGINTYPE MARGINTYPE, l_AUTOADV AUTOADV, l_BALDEFOVD BALDEFOVD
            ,3 groupnum,'OD' grouprpt from dual, allcode where cdtype = 'CF' and cdname = 'CF0040' and cdval = 'ODAMT'
          union all
          select 14 REFNUM, cdcontent REFNAME, l_DUEAMT + l_OVAMT REFVAL, '' REFFORMULA, l_CUSTODYCD CUSTODYCD, l_FULLNAME FULLNAME, l_AFACCTNO AFACCTNO, l_MARGINTYPE MARGINTYPE, l_AUTOADV AUTOADV, l_BALDEFOVD BALDEFOVD
            ,3 groupnum,'OD' grouprpt from dual, allcode where cdtype = 'CF' and cdname = 'CF0040' and cdval = 'OVAMT'
          union all
          select 15 REFNUM, cdcontent REFNAME, l_DEPOFEEAMT REFVAL, '' REFFORMULA, l_CUSTODYCD CUSTODYCD, l_FULLNAME FULLNAME, l_AFACCTNO AFACCTNO, l_MARGINTYPE MARGINTYPE, l_AUTOADV AUTOADV, l_BALDEFOVD BALDEFOVD
            ,3 groupnum,'OD' grouprpt from dual, allcode where cdtype = 'CF' and cdname = 'CF0040' and cdval = 'DEPOFEEAMT'
          union all
          select 16 REFNUM, cdcontent REFNAME, l_DFODAMT REFVAL, '' REFFORMULA, l_CUSTODYCD CUSTODYCD, l_FULLNAME FULLNAME, l_AFACCTNO AFACCTNO, l_MARGINTYPE MARGINTYPE, l_AUTOADV AUTOADV, l_BALDEFOVD BALDEFOVD
            ,3 groupnum,'OD' grouprpt from dual, allcode where cdtype = 'CF' and cdname = 'CF0040' and cdval = 'DFODAMT'
          union all
          select 21 REFNUM, cdcontent REFNAME, l_MRCRLIMITMAX REFVAL, '' REFFORMULA, l_CUSTODYCD CUSTODYCD, l_FULLNAME FULLNAME, l_AFACCTNO AFACCTNO, l_MARGINTYPE MARGINTYPE, l_AUTOADV AUTOADV, l_BALDEFOVD BALDEFOVD
            ,4 groupnum,'LIMIT' grouprpt from dual, allcode where cdtype = 'CF' and cdname = 'CF0040' and cdval = 'MRCRLIMITMAX'
          union all
          select 22 REFNUM, cdcontent REFNAME, l_ADVANCELINE REFVAL, '' REFFORMULA, l_CUSTODYCD CUSTODYCD, l_FULLNAME FULLNAME, l_AFACCTNO AFACCTNO, l_MARGINTYPE MARGINTYPE, l_AUTOADV AUTOADV, l_BALDEFOVD BALDEFOVD
            ,4 groupnum,'LIMIT' grouprpt from dual, allcode where cdtype = 'CF' and cdname = 'CF0040' and cdval = 'ADVANCELINE'
          union all
          select 17 REFNUM, cdcontent REFNAME, l_MARGINRATE REFVAL, '' REFFORMULA, l_CUSTODYCD CUSTODYCD, l_FULLNAME FULLNAME, l_AFACCTNO AFACCTNO, l_MARGINTYPE MARGINTYPE, l_AUTOADV AUTOADV, l_BALDEFOVD BALDEFOVD
            ,5 groupnum,'RATE' grouprpt from dual, allcode where cdtype = 'CF' and cdname = 'CF0040' and cdval = 'MARGINRATE'
          union all
          select 18 REFNUM, cdcontent REFNAME, l_MRIRATE REFVAL, '' REFFORMULA, l_CUSTODYCD CUSTODYCD, l_FULLNAME FULLNAME, l_AFACCTNO AFACCTNO, l_MARGINTYPE MARGINTYPE, l_AUTOADV AUTOADV, l_BALDEFOVD BALDEFOVD
            ,5 groupnum,'RATE' grouprpt from dual, allcode where cdtype = 'CF' and cdname = 'CF0040' and cdval = 'MRIRATE'
          union all
          select 19 REFNUM, cdcontent REFNAME, l_MRMRATE REFVAL, '' REFFORMULA, l_CUSTODYCD CUSTODYCD, l_FULLNAME FULLNAME, l_AFACCTNO AFACCTNO, l_MARGINTYPE MARGINTYPE, l_AUTOADV AUTOADV, l_BALDEFOVD BALDEFOVD
            ,5 groupnum,'RATE' grouprpt from dual, allcode where cdtype = 'CF' and cdname = 'CF0040' and cdval = 'MRMRATE'
          union all
          select 20 REFNUM, cdcontent REFNAME, l_MRLRATE REFVAL, '' REFFORMULA, l_CUSTODYCD CUSTODYCD, l_FULLNAME FULLNAME, l_AFACCTNO AFACCTNO, l_MARGINTYPE MARGINTYPE, l_AUTOADV AUTOADV, l_BALDEFOVD BALDEFOVD
            ,5 groupnum,'RATE' grouprpt from dual, allcode where cdtype = 'CF' and cdname = 'CF0040' and cdval = 'MRLRATE'
          --union all
          --select 1 REFNUM, cdcontent REFNAME, l_AVLLIMIT REFVAL, '' REFFORMULA, l_CUSTODYCD CUSTODYCD, l_FULLNAME FULLNAME, l_AFACCTNO AFACCTNO, l_MARGINTYPE MARGINTYPE, l_AUTOADV AUTOADV, l_BALDEFOVD BALDEFOVD
          --  ,'LIMIT' grouprpt from dual, allcode where cdtype = 'CF' and cdname = 'CF0040' and cdval = 'AVLLIMIT'

        ) order by groupnum, refnum;

 EXCEPTION
   WHEN OTHERS
   THEN
        pr_error('CF0040',dbms_utility.format_error_backtrace || ':'|| SQLERRM);
        dbms_output.put_line('CF0040:'||dbms_utility.format_error_backtrace || ':'|| SQLERRM);
        RETURN;
END;

 
 
 
 
/
