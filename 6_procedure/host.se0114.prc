SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE se0114 (
   PV_REFCURSOR             IN OUT   PKG_REPORT.REF_CURSOR,
   OPT                      IN       VARCHAR2,
   PV_BRID                  IN       VARCHAR2,
   TLGOUPS                  IN       VARCHAR2,
   TLSCOPE                  IN       VARCHAR2,
   PV_CUSTODYCD             IN       VARCHAR2,
   PV_SYMBOL        IN       VARCHAR2
)
IS

    v_CUSTODYCD VARCHAR2(15);
    v_SYMBOL VARCHAR2(20);
    v_CUSTID VARCHAR2(15);
    v_MAKER date;
    v_TIME VARCHAR2(15);
BEGIN


    IF (PV_CUSTODYCD IS NULL OR UPPER(PV_CUSTODYCD) = 'ALL')
    THEN
        v_CUSTODYCD := '%';
    ELSE
        v_CUSTODYCD := upper(PV_CUSTODYCD);
    END IF;
    v_SYMBOL := replace(rtrim(LTRIM(upper(PV_SYMBOL))),' ','_');

    select custid into v_CUSTID from cfmast where custodycd = v_CUSTODYCD;
    select maker_dt,maker_time into v_MAKER,v_TIME
    from
    (
        select maker_dt,maker_time
        from maintain_log
        where table_name = 'CFMAST'
        and  record_column_key = v_CUSTID
        order by maker_dt,maker_time desc
    )
    where ROWNUM = 1 ;

OPEN PV_REFCURSOR
FOR
    /*SELECT CF.CUSTID, CF.CUSTODYCD, upper(SE.SHAREHOLDERSID) SHAREHOLDERSID, upper(CF.FULLNAME) FULLNAME, CF.IDCODE LICENSENO, CF.IDDATE LICENSEDATE, CF.IDPLACE LICENSEPLACE,
        CF.ADDRESS, NVL(CT.ADDRESS,'') CTADDRESS, CF.MOBILESMS MOBILE, CF.EMAIL, A1.CDCONTENT COUNTRY, SE.BANKACCTNO, SE.BANKNAME
    FROM CFMAST CF, (
             SELECT AF.CUSTID, MAX(nvl(upper(SE.SHAREHOLDERSID),'')) SHAREHOLDERSID, max(AF.BANKACCTNO) BANKACCTNO,
                 max(DECODE(AF.BANKNAME,'---','',A1.CDCONTENT)) BANKNAME
             FROM (
                     SELECT AFACCTNO,SHAREHOLDERSID
                     FROM SEMAST SE, SBSECURITIES SB
                     WHERE SE.CODEID = SB.CODEID
                        AND SHAREHOLDERSID IS NOT NULL
                        --AND SB.SYMBOL = V_SYMBOL
                  ) SE, AFMAST AF,(
                     SELECT CDVAL, CDCONTENT
                     FROM ALLCODE
                     WHERE CDTYPE = 'CF' AND CDNAME = 'BANKNAME'
                 ) A1
             WHERE AF.ACCTNO = SE.AFACCTNO
                 and AF.BANKNAME = A1.CDVAL
             GROUP BY AF.CUSTID

        )SE,
        (
            SELECT CUSTID, MAX(ADDRESS) ADDRESS
            FROM CFCONTACT
            GROUP BY CUSTID
        ) CT, ALLCODE A1
    WHERE CF.CUSTID = SE.CUSTID
        AND CF.CUSTID = CT.CUSTID(+)
        AND CF.COUNTRY = A1.CDVAL AND A1.CDTYPE = 'CF' AND A1.CDNAME = 'COUNTRY'
        and CF.CUSTODYCD = v_CUSTODYCD
        --AND SE.SHAREHOLDERSID = V_SHAREHOLDERSID
        AND INSTR(TLGOUPS, CF.CAREBY)>0
        ;*/

        select UPPER(CF.FULLNAME) FULLNAME, UPPER(SE.SHAREHOLDERSID) SHAREHOLDERSID, CT.ADDRESS CTADDRESS,AF.BANKACCTNO,
               DECODE(AF.BANKNAME,'---','',AL2.CDCONTENT) BANKNAME,
               NVL(L4.from_value,CF.ADDRESS) FADDRESS, NVL(L4.to_value,'') TADDRESS,
               NVL(L5.from_value,CF.MOBILESMS) FMOBILE, NVL(L5.to_value,'') TMOBILE,
               NVL(L1.from_value,CF.IDCODE) FIDCODE, NVL(L1.to_value,'') TIDCODE,
               NVL(L2.from_value,CF.IDDATE) FIDDATE, NVL(L2.to_value,'') TIDDATE,
               NVL(L3.from_value,CF.IDPLACE) FIDPLACE, NVL(L3.to_value,'') TIDPLACE,
               NVL(L6.from_value,CF.EMAIL) FEMAIL, NVL(L6.to_value,'') TEMAIL,
               NVL(L7.from_value,AL.CDCONTENT) FCOUNTRY, NVL(L7.to_value,'') TCOUNTRY
        from CFMAST CF,CFCONTACT CT, SEMAST SE, AFMAST AF, SBSECURITIES SB,
        (
            select record_column_key custid,from_value,to_value
            from maintain_log
            where table_name = 'CFMAST'
            and action_flag = 'EDIT'
            and column_name = 'IDCODE'
            and record_column_key = v_CUSTID
            and maker_dt = v_MAKER
            and maker_time = v_TIME
        )l1,
        (
            select record_column_key custid,from_value,to_value
            from maintain_log
            where table_name = 'CFMAST'
            and action_flag = 'EDIT'
            and column_name = 'IDDATE'
            and record_column_key = v_CUSTID
            and maker_dt = v_MAKER
            and maker_time = v_TIME
        )l2,
        (
            select record_column_key custid,from_value,to_value
            from maintain_log
            where table_name = 'CFMAST'
            and action_flag = 'EDIT'
            and column_name = 'IDPLACE'
            and record_column_key = v_CUSTID
            and maker_dt = v_MAKER
            and maker_time = v_TIME
        )l3,
        (
            select record_column_key custid,from_value,to_value
            from maintain_log
            where table_name = 'CFMAST'
            and action_flag = 'EDIT'
            and column_name = 'ADDRESS'
            and record_column_key = v_CUSTID
            and maker_dt = v_MAKER
            and maker_time = v_TIME
        )l4,
        (
            select record_column_key custid,from_value,to_value
            from maintain_log
            where table_name = 'CFMAST'
            and action_flag = 'EDIT'
            and column_name = 'MOBILESMS'
            and record_column_key = v_CUSTID
            and maker_dt = v_MAKER
            and maker_time = v_TIME
        )l5,
        (
            select record_column_key custid,from_value,to_value
            from maintain_log
            where table_name = 'CFMAST'
            and action_flag = 'EDIT'
            and column_name = 'EMAIL'
            and record_column_key = v_CUSTID
            and maker_dt = v_MAKER
            and maker_time = v_TIME
        )l6,
        (
           select record_column_key custid,
                   (select CDCONTENT from allcode where CDNAME = 'COUNTRY' AND CDTYPE = 'CF' and CDVAL = from_value) from_value,
                   (select CDCONTENT from allcode where CDNAME = 'COUNTRY' AND CDTYPE = 'CF' and CDVAL = to_value) to_value
           from maintain_log
           where table_name = 'CFMAST'
           and action_flag = 'EDIT'
           and column_name = 'COUNTRY'
           and record_column_key = v_CUSTID
           and maker_dt = v_MAKER
           and maker_time = v_TIME
        )l7,
        (SELECT CDVAL, CDCONTENT FROM ALLCODE WHERE CDNAME = 'COUNTRY' AND CDTYPE = 'CF') AL,
        (SELECT CDVAL, CDCONTENT FROM ALLCODE WHERE CDTYPE = 'CF' AND CDNAME = 'BANKNAME') AL2
        where CF.CUSTID = CT.CUSTID(+)
        AND   CF.CUSTID = AF.CUSTID
        AND   AF.ACCTNO = SE.AFACCTNO
        AND   SE.CODEID = SB.CODEID
        AND   CF.COUNTRY = AL.CDVAL
        AND   AF.BANKNAME = AL2.CDVAL(+)
        AND   CF.CUSTID = L1.CUSTID(+)
        AND   CF.CUSTID = L2.CUSTID(+)
        AND   CF.CUSTID = L3.CUSTID(+)
        AND   CF.CUSTID = L4.CUSTID(+)
        AND   CF.CUSTID = L5.CUSTID(+)
        AND   CF.CUSTID = L6.CUSTID(+)
        AND   CF.CUSTID = L7.CUSTID(+)
        AND   SE.SHAREHOLDERSID IS NOT NULL
        AND   CF.CUSTODYCD = v_CUSTODYCD
        AND   SB.SYMBOL = V_SYMBOL;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
/
