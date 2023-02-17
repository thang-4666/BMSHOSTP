SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SE0059"(PV_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
                                     OPT          IN VARCHAR2,
                                     BRID         IN VARCHAR2,
                                     TLGOUPS      IN VARCHAR2,
                                     TLSCOPE      IN VARCHAR2,
                                     F_DATE       IN VARCHAR2,
                                     T_DATE       IN VARCHAR2,
                                     PV_CUSTODYCD IN VARCHAR2,
                                     PV_AFACCTNO  IN VARCHAR2,
                                     PLSENT       IN VARCHAR2) IS

  -- RP NAME : YEU CAU CHUYEN KHOAN CHUNG KHOAN TAT TOAN TAI KHOAN
  -- PERSON --------------DATE---------------------COMMENTS
  -- THANHNM            17/07/2012                 CREATE
  -- SE00310: report main
  -- ---------   ------  -------------------------------------------
  V_STRAFACCTNO        VARCHAR2(15);
  V_CUSTODYCD          VARCHAR2(15);
  V_CURRDATE           DATE;
  V_STRFULLNAME        VARCHAR2(200);
  V_STR_TVLK_CODE      VARCHAR2(10);
  V_STR_TVLK_NAME      VARCHAR2(200);
  V_STR_CUSTODYCD_NHAN VARCHAR2(10);
  CUR                  PKG_REPORT.REF_CURSOR;

  V_INBRID    VARCHAR2(4);
  V_STRBRID   VARCHAR2(50);
  V_STROPTION VARCHAR2(5);
   V_COMPANYCD VARCHAR2(10);
BEGIN

    SELECT VARVALUE INTO V_COMPANYCD
        FROM SYSVAR WHERE VARNAME = 'COMPANYCD' AND GRNAME = 'SYSTEM';

  -- GET REPORT'S PARAMETERS
  V_STROPTION := upper(OPT);
  V_INBRID    := BRID;
  if (V_STROPTION = 'A') then
    V_STRBRID := '%%';
  else
    if (V_STROPTION = 'B') then
      select br.mapid
        into V_STRBRID
        from brgrp br
       where br.brid = V_INBRID;
    else
      V_STRBRID := V_INBRID;
    end if;
  end if;

  V_CUSTODYCD     := UPPER(PV_CUSTODYCD);
  V_STR_TVLK_NAME := ' ';
  V_STR_TVLK_CODE := ' ';
  V_STRFULLNAME   := ' ';

  SELECT TO_DATE(VARVALUE, 'DD/MM/RRRR')
    INTO V_CURRDATE
    FROM SYSVAR
   WHERE VARNAME = 'CURRDATE'
     AND GRNAME = 'SYSTEM';

  IF (PV_AFACCTNO <> 'ALL') THEN
    V_STRAFACCTNO := PV_AFACCTNO;
  ELSE
    V_STRAFACCTNO := '%';
  END IF;

  SELECT FULLNAME
    INTO V_STRFULLNAME
    FROM CFMAST
   WHERE custodycd = V_CUSTODYCD;

  --LAY THONG TIN CHINH
  /* OPEN CUR FOR
    SELECT NVL(DP.FULLNAME, ' '),
           NVL(DT.BANK, ' '),
           NVL(DT.RECEIVCUSTODYCD, ' ')
      FROM DEPOSIT_MEMBER DP,
           (SELECT MAX(CASE
                         WHEN TLF.FLDCD = '27' THEN
                          TLF.CVALUE
                         ELSE
                          ' '
                       END) BANK,
                   MAX(CASE
                         WHEN TLF.FLDCD = '28' THEN
                          TLF.CVALUE
                         ELSE
                          ' '
                       END) RECEIVCUSTODYCD
              FROM VW_SETRAN_GEN SE, VW_TLLOGFLD_ALL TLF
             WHERE SE.TLTXCD = '2247'
               AND SE.DELTD = 'N'
               AND SE.CUSTODYCD = V_CUSTODYCD
               AND TLF.FLDCD IN ('27', '28')
               AND SE.TXNUM = TLF.TXNUM
               AND SE.TXDATE = TLF.TXDATE
               AND SE.TXDATE >= TO_DATE(F_DATE, 'DD/MM/YYYY')
               AND SE.TXDATE <= TO_DATE(T_DATE, 'DD/MM/YYYY')) DT
     WHERE DP.DEPOSITID = DT.BANK;

  LOOP
    FETCH CUR
      INTO V_STR_TVLK_NAME, V_STR_TVLK_CODE, V_STR_CUSTODYCD_NHAN;
    EXIT WHEN CUR%NOTFOUND;
  END LOOP;
  CLOSE CUR;*/

  -- GET REPORT'S DATA
  OPEN PV_REFCURSOR FOR

    SELECT SB.PARVALUE,
           SB.SYMBOL,

           ((case
             when sb.tradeplace = '009' then
              '013'
             else
              '012'
           end) || (case
             when DT.SE_TYPE IN ('8', '7') then
              '72'
             else
              (case
                when DT.SE_TYPE = '1' THEN
                 '12'
                ELSE
                 '22'
              END)
           end) || '.' || DT.MA_TVLK_NHAN) TK_NO,
           ((case
             when sb.tradeplace = '009' then
              '013'
             else
              '012'
           end) || (case
             when DT.SE_TYPE IN ('8', '7') then
              '72'
             else
              (case
                when DT.SE_TYPE = '1' THEN
                 '12'
                ELSE
                 '22'
              END)
           end) || '.' || V_COMPANYCD) TK_CO,
           DT.CUSTODYCD,

           /* (case when sb.tradeplace='002' then 'HNX'
           when sb.tradeplace='001' then 'HOSE'
           when sb.tradeplace='005' then 'UPCOM'
           when sb.tradeplace='007' then 'TR?I PHI? CHUY? BI?T'
           when sb.tradeplace='008' then 'T? PHI?U'
           when sb.tradeplace='086' then '?CNY'
           else '' end)*/
           A0.CDCONTENT SAN_GD,

           DT.NAMT,
           DT.SE_TYPE,
           V_STRFULLNAME FULLNAME,
           NVL(DeP.FULLNAME, ' ') TEN_TVLK_NHAN,
           MA_TVLK_NHAN,
           SO_TKLK_NHAN,
           TEN_NGUOI_NHAN,
           PLSENT PL_SENT
      FROM SBSECURITIES SB,
           ALLCODE A0,

               (select tl.TXDATE,
                           tl.TXNUM,
                            cf.custodycd,
                           se.afacctno ,
                           ser.inwardname MA_TVLK_NHAN,
                           ser.rcustodycd SO_TKLK_NHAN,
                           ser.infullname TEN_NGUOI_NHAN,
                           ser.amt  namt,
                           max(SB.TRADEPLACE) TRADEPLACE,
                           max(nvl(sb.refcodeid, sb.codeid)) codeid,
                           (case
                             when sb.refcodeid is null then
                              '1'
                             else
                              '7'
                           end) SE_TYPE
                      from (select tg.autoid,
                                   tg.tlid,
                                   tg.offid,
                                   tg.tltxcd,
                                   tg.MSGACCT,
                                   tg.CCYUSAGE,
                                   tg.TXNUM,
                                   tg.txdate,
                                   tg.CFCUSTODYCD
                              from VW_TLLOG_ALL tg where tg.txdate >=
                                   TO_DATE(F_DATE, 'DD/MM/YYYY')
                               AND tg.txdate <=
                                   TO_DATE(T_DATE, 'DD/MM/YYYY')
                               and tg.tltxcd in ('2244')) tl,
                           cfmast cf,
                           semast se,
                           sbsecurities sb,
                           SETYPETRF ser
                     where cf.custodycd = tl.cfcustodycd
                       and se.acctno = tl.MSGACCT
                       and se.codeid =  sb.codeid
                       and ser.txdate = tl.txdate
                       and ser.txnum = tl.txnum
                       and ser.tltxcd = '2244'
                       and ser.typetrf = '002'
                       and ser.trtype = '013'
                       and se.codeid = tl.CCYUSAGE
                       and cf.custodycd like V_CUSTODYCD
                        and tl.MSGACCT like V_STRAFACCTNO
                       --and se.trade > 0
                     group by tl.TXDATE,
                              tl.TXNUM,
                              cf.custodycd,
                              se.afacctno,
                              ser.inwardname,
                              ser.rcustodycd,
                              ser.infullname,
                              ser.amt,
                              sb.refcodeid

           union all
           select tl.TXDATE,
                           tl.TXNUM,
                           cf.custodycd,
                           se.afacctno ,
                           ser.inwardname MA_TVLK_NHAN,
                           ser.rcustodycd SO_TKLK_NHAN,
                           ser.infullname TEN_NGUOI_NHAN,
                           ser.depoblock  namt,
                           max(SB.TRADEPLACE) TRADEPLACE,
                           max(nvl(sb.refcodeid, sb.codeid)) codeid,
                           (case
                             when sb.refcodeid is null then
                              '2'
                             else
                              '8'
                           end) SE_TYPE
                      from (select tg.autoid,
                                   tg.tlid,
                                   tg.offid,
                                   tg.tltxcd,
                                   tg.MSGACCT,
                                   tg.CCYUSAGE,
                                   tg.TXNUM,
                                   tg.TXDATE,
                                   tg.CFCUSTODYCD
                              from VW_TLLOG_ALL tg  where tg.txdate >=
                                   TO_DATE(F_DATE, 'DD/MM/YYYY')
                               AND tg.txdate <=
                                   TO_DATE(T_DATE, 'DD/MM/YYYY')
                               and tg.tltxcd in ('2244')) tl,
                           cfmast cf,
                           semast se,
                           sbsecurities sb,
                           SETYPETRF ser
                     where cf.custodycd = tl.cfcustodycd
                       and se.acctno = tl.MSGACCT
                       and se.codeid =  sb.codeid
                       and ser.txdate = tl.txdate
                       and ser.txnum = tl.txnum
                       and ser.tltxcd = '2244'
                       and ser.typetrf = '002'
                      and ser.trtype = '013'
                       and se.codeid = tl.CCYUSAGE
                       and cf.custodycd like V_CUSTODYCD
                       and tl.MSGACCT like V_STRAFACCTNO

                     group by tl.TXDATE,
                              tl.TXNUM,
                              cf.custodycd,
                              se.afacctno,
                              ser.inwardname,
                              ser.rcustodycd,
                              ser.infullname,
                              ser.depoblock,
                              sb.refcodeid

            ) DT,
           DEPOSIT_MEMBER dep,
           CFMAST cf
     WHERE SB.CODEID = DT.CODEID
       AND DT.CUSTODYCD LIKE V_CUSTODYCD
       AND DT.NAMT > 0
       and dt.MA_TVLK_NHAN = dep.DEPOSITID(+)
       and cf.custodycd = dt.custodycd
       --and cf.status = 'G' -- tai khoan ke thua
       AND A0.CDTYPE = 'SE'
       AND A0.CDNAME = 'TRADEPLACE'
       AND A0.CDVAL = SB.TRADEPLACE order by sb.symbol,dt.se_type

    ;

EXCEPTION
  WHEN OTHERS THEN
    RETURN;
END;
 
 
 
 
/
