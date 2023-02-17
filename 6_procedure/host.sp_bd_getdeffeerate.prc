SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SP_BD_GETDEFFEERATE" (PV_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,pv_ACCTNO varchar2, pv_EXECTYPE varchar2,pv_MatchType varchar2,pv_via varchar2, pv_PriceType varchar2, pv_Codeid varchar2)
is
    l_feerate number;
    l_sectype varchar2(10);
    l_tradeplace varchar2(10);
    l_actype varchar2(10);
begin
    select sectype, tradeplace into l_sectype,l_tradeplace from sbsecurities where codeid = pv_Codeid;
    select actype into l_actype from afmast where acctno = pv_ACCTNO;
    Open PV_REFCURSOR for
    SELECT deffeerate
                  FROM (SELECT a.actype, a.clearday, a.bratio, a.minfeeamt, a.deffeerate, b.ODRNUM
                  FROM odtype a, afidtype b
                  WHERE     a.status = 'Y'
                        AND (a.via = pv_via OR a.via = 'A') --VIA
                        AND a.clearcd = 'B'       --CLEARCD
                        AND (a.exectype = pv_Exectype
                             OR a.exectype = 'AA')                    --EXECTYPE
                        AND (a.timetype = 'T'
                             OR a.timetype = 'A')                     --TIMETYPE
                        AND (a.pricetype = pv_PriceType
                             OR a.pricetype = 'AA')                  --PRICETYPE
                        AND (a.matchtype = pv_MatchType
                             OR a.matchtype = 'A')                   --MATCHTYPE
                        AND (a.tradeplace = l_TradePlace
                             OR a.tradeplace = '000')
                        AND (instr(case when l_secType in ('001','002') then l_secType || ',' || '111,333'
                                       when l_secType in ('003','006') then l_secType || ',' || '222,333,444'
                                       when l_secType in ('008') then l_secType || ',' || '111,444'
                                       else l_secType end, a.sectype)>0 OR a.sectype = '000')
                        AND (a.nork = 'N' OR a.nork = 'A') --NORK
                        AND (CASE WHEN A.CODEID IS NULL THEN pv_Codeid ELSE A.CODEID END)=pv_Codeid
                        AND a.actype = b.actype and b.aftype=l_actype and b.objname='OD.ODTYPE'
                        order by b.odrnum desc) where rownum<=1;
exception when others then
    Open PV_REFCURSOR for select 0.3 DEFFEERATE from dual;
end;

 
 
 
 
/
