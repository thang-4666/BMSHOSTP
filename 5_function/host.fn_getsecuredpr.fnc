SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_getsecuredpr(p_PrTyp VARCHAR2,p_PrCode VARCHAR2 ,p_CodeID VARCHAR2  )
RETURN NUMBER
IS
l_PrSecured NUMBER;
BEGIN

    if p_PrTyp='P' then
            --Check nhom quan ly khach hang.
            BEGIN
                select  greatest(sum(nvl(od.secureamt,0)-ci.balance-nvl(adv.avladvance,0)),0) into l_PrSecured
                from cfmast cf, afmast af, cimast ci,
                    -- begin TABLE secure
                    (select a.afacctno, a.secureamt + nvl(b.absecured,0) secureamt
                    from (SELECT od.afacctno,
                                round(SUM (    quoteprice* remainqtty* (od.bratio/100)
                                            + execamt * (od.bratio/100)
                                            + execamt * (case when execqtty<=0 then 0 else dfqtty/execqtty end) * (1 + typ.deffeerate / 100 - od.bratio/100) ),0) secureamt
                        FROM odmast od, odtype typ
                        WHERE od.actype = typ.actype
                         AND od.txdate = (SELECT to_date(varvalue,systemnums.C_DATE_FORMAT) FROM sysvar WHERE varname = 'CURRDATE' AND grname = 'SYSTEM')
                         AND deltd <> 'Y'
                         AND od.exectype IN ('NB', 'BC')
                         group by od.afacctno) A,
                    (select od.afacctno,
                                sum(greatest(od.QUOTEPRICE* od.ORDERQTTY * od.BRATIO/100 - org.QUOTEPRICE* org.ORDERQTTY * org.BRATIO/100,0)) absecured
                    from odmast od,odmast org, ood, odtype typ, odtype orgtyp
                    where od.orderid=ood.orgorderid
                        and od.REFORDERID=org.orderid
                        and od.actype=typ.actype
                        and od.txdate = (SELECT to_date(varvalue,systemnums.C_DATE_FORMAT) FROM sysvar WHERE varname = 'CURRDATE' AND grname = 'SYSTEM')
                        and org.actype=orgtyp.actype
                        and OODSTATUS='N' and od.exectype ='AB'
                        and od.deltd <> 'Y' and org.deltd <>'Y'
                        group by od.afacctno ) B
                        where  a.afacctno =b.afacctno (+)) od,
                        -- END TABLE secure
                    aftype aft, mrtype mr,
                (select sum(depoamt) avladvance,afacctno
                    from v_getAccountAvlAdvance group by afacctno) adv
                where af.acctno = ci.acctno
                AND cf.custid = af.custid
                and af.acctno = od.afacctno(+)
                and ci.acctno = adv.afacctno(+)
                and nvl(od.secureamt,0)-ci.balance-nvl(adv.avladvance,0)>0
                and af.actype = aft.actype
                and aft.mrtype= mr.actype
                AND substr(cf.custodycd,0,3) = (SELECT varvalue FROM sysvar WHERE varname = 'COMPANYCD' AND grname = 'SYSTEM')
                AND NOT EXISTS (SELECT 1 FROM dftype WHERE ciacctno = af.acctno AND ciacctno IS NOT NULL)
                AND EXISTS (SELECT 1 FROM prtlgrpmap
                            WHERE prcode = p_prcode
                            AND af.careby = decode (grpid,'ALL',af.careby,grpid));

            EXCEPTION WHEN no_data_found THEN
                l_PrSecured:=0;
            END;
    ELSIF p_PrTyp='R' THEN
            BEGIN -- lay theo noi mo tieu khoan.
                SELECT - sum(nvl(CL_QTTY,0) + least(nvl(od.ETS_EXECQTTY,0) - least(greatest(0,nvl(od.ETS_EXECQTTY,0)-nvl(df.dftriggerqtty,0)),se.trade-nvl(od.S_QTTY,0)),
                        nvl(df.dftotalqtty,0) - nvl(od.DF_QTTY,0))
                       + nvl(od.DF_QTTY,0) - nvl(od.B_CL_QTTY,0)) INTO l_PrSecured
                FROM cfmast cf, afmast af,semast se,
                (SELECT od.afacctno, od.codeid,od.seacctno,
                        sum(case WHEN mrt.mrtype IN ('S','T') AND od.exectype IN ('NS','SS')
                            THEN od.execqtty + od.remainqtty ELSE 0 END) CL_QTTY, -- lenh ban creditline
                        sum(case WHEN od.exectype IN ('MS')
                            THEN od.execqtty + od.remainqtty ELSE 0 END) DF_QTTY, -- lenh ban deal
                        sum(CASE WHEN mrt.mrtype NOT IN ('S','T') AND od.exectype IN ('NS','SS') AND od.via = 'W'
                            THEN od.execqtty ELSE 0 END) ETS_EXECQTTY, -- lenh ban tu ETS
                        sum(CASE WHEN mrt.mrtype NOT IN ('S','T') AND od.exectype IN ('NS','SS') AND od.via <> 'W'
                            THEN od.execqtty + od.remainqtty ELSE 0 END) S_QTTY, -- lenh ban thuong o san
                        sum(CASE WHEN mrt.mrtype IN ('S','T') AND od.exectype IN ('NB','BC')
                            THEN od.execqtty + od.remainqtty ELSE 0 END) B_CL_QTTY
                        FROM odmast od, afmast af, aftype aft, mrtype mrt
                        WHERE od.exectype IN ('NS','SS','MS','BC','NB')
                        AND od.txdate = (SELECT to_date(varvalue,systemnums.C_DATE_FORMAT) FROM sysvar WHERE varname = 'CURRDATE' AND grname = 'SYSTEM')
                        AND od.afacctno = af.acctno
                        AND af.actype = aft.actype
                        AND aft.mrtype(+) = mrt.actype
                        AND od.deltd <> 'Y'
                        AND od.codeid = p_CodeID
                        group BY od.afacctno, od.codeid,od.seacctno) od,
                (SELECT df.afacctno, df.codeid,
                        sum(CASE WHEN df.triggerprice >= se.basicprice OR df.flagtrigger = 'T' OR ln.prinovd > 0 OR lns.overduedate = (SELECT to_date(varvalue,systemnums.C_DATE_FORMAT) FROM sysvar WHERE varname = 'CURRDATE' AND grname = 'SYSTEM') THEN df.dfqtty ELSE 0 end) dftriggerqtty,
                        sum(df.dfqtty) dftotalqtty
                    FROM dfmast df, securities_info se , lnmast ln, lnschd lns
                    WHERE df.codeid = se.codeid
                    AND ln.acctno = df.lnacctno
                    AND ln.acctno = lns.acctno
                    AND df.codeid = p_CodeID
                    AND ln.ftype='DF'
                    AND lns.REFTYPE IN ('P','GP')
                    GROUP BY df.afacctno, df.codeid
                ) df -- tong khoi luong chung khoan bi cham TRIGGER, Qua han, den han.
                WHERE cf.custid = af.custid
                AND af.acctno = se.afacctno(+)
                AND se.codeid = p_CodeID
                AND af.acctno = od.afacctno(+)
                AND af.acctno = df.afacctno(+)
                AND substr(cf.custodycd,0,3) = (SELECT varvalue FROM sysvar WHERE varname = 'COMPANYCD' AND grname = 'SYSTEM')
                AND NOT EXISTS (SELECT 1 FROM dftype WHERE ciacctno = af.acctno AND ciacctno IS NOT NULL)
                AND EXISTS (SELECT 1 FROM prtlgrpmap
                            WHERE prcode = p_prcode
                            AND af.careby = decode (grpid,'ALL',af.careby,grpid));

            EXCEPTION WHEN no_data_found THEN
                l_PrSecured:=0;
            END;
    ELSE
        RETURN 0;
    end if;

RETURN l_PrSecured;
EXCEPTION WHEN others THEN
RETURN 0;
END fn_getSecuredPR;

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
