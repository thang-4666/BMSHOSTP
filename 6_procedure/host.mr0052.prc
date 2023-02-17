SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "MR0052" (
   PV_REFCURSOR     IN OUT   PKG_REPORT.REF_CURSOR,
   OPT              IN       VARCHAR2,
   pv_BRID             IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,

   I_DATE           IN       VARCHAR2,
   ROOMTYPE         IN       VARCHAR2

       )
IS

--
-- PURPOSE: BAO CAO QUAN LY HAN MUC CK NHAN LAM TSDB
-- MODIFICATION HISTORY
-- PERSON       DATE        COMMENTS
-- THENN        20-MAR-2012 CREATED
-- ---------    ------      -------------------------------------------

    V_STROPTION         VARCHAR2  (5);
    V_ROOMTYPE          varchar2(1);
    V_IN_DATE           VARCHAR2(15);
    V_INBRID        VARCHAR2(4);
    V_STRBRID      VARCHAR2 (50);

BEGIN
    -- GET REPORT'S PARAMETERS
    /*V_STROPTION := OPT;

    IF (V_STROPTION <> 'A') AND (BRID <> 'ALL')
    THEN
        V_STRBRID := BRID;
    ELSE
        V_STRBRID := '%%';
    END IF;*/
     V_STROPTION := upper(OPT);
     V_INBRID := pv_BRID;
    if(V_STROPTION = 'A') then
        V_STRBRID := '%%';
    else
        if(V_STROPTION = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
    end if;
    V_ROOMTYPE := ROOMTYPE;
    V_IN_DATE := I_DATE;

    IF V_ROOMTYPE = 'S' THEN
        -- ROOM HE THONG --> LAY CA CK MARGIN, DF
        OPEN PV_REFCURSOR FOR
            SELECT a.symbol, max(sif.syroomlimit) totalroomlimit, sum(a.totalqtty) totalqtty, sum(a.tradeqtty) tradeqtty,
                sum(a.recvqtty) recvqtty, sum(a.resqtty) resqtty, sum(a.otherqtty) otherqtty, max(sif.basicprice) refprice,
                sum(a.loanamount) loanamount, max(sif.listingqtty) listingqtty,
                CASE WHEN max(sif.listingqtty) > 0 then round(sum(a.totalqtty)/max(sif.listingqtty)*100,4) ELSE 0 end lstqttrate,
                MAX(A1.CDCONTENT) ROOMTYPEDESC, V_IN_DATE IN_DATE
            FROM
            (
                SELECT mr.symbol, mr.codeid, sum(mr.prinused) totalqtty, sum(mr.tradeqtty) tradeqtty,
                    sum(mr.recvqtty) recvqtty, 0 resqtty, 0 otherqtty, max(mr.refprice) refprice, sum(mr.loanamount) loanamount
                FROM
                (
                    SELECT sif.symbol, alo.codeid, alo.afacctno, alo.prinused,
                        sm.trade, asr.mrratiorate, asr.mrratioloan,
                        CASE WHEN alo.prinused >= sm.trade THEN sm.trade ELSE alo.prinused END tradeqtty,
                        CASE WHEN alo.prinused >= sm.trade THEN alo.prinused - sm.trade ELSE 0 END recvqtty,
                        0 resqtty, 0 otherqtty, sif.basicprice refprice, alo.prinused * asr.mrratioloan * sif.basicprice /100 loanamount
                    FROM
                        (
                            SELECT alo.afacctno, alo.codeid, sum(alo.prinused) prinused
                            FROM vw_afpralloc_all alo
                            WHERE alo.prinused <>0
                                AND alo.restype LIKE '%%'
                            GROUP BY alo.afacctno, alo.codeid
                        ) alo, semast sm, afmast af, afserisk asr, securities_info sif
                    WHERE alo.codeid = sif.codeid AND alo.afacctno = af.acctno
                        AND alo.afacctno = sm.afacctno AND alo.codeid = sm.codeid
                        AND af.actype = asr.actype AND alo.codeid = asr.codeid
                        AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )
                ) mr
                GROUP BY mr.symbol, mr.codeid
                UNION all
                SELECT max(sif.symbol) symbol, df.codeid, sum(df.dfqtty+df.rcvqtty+df.blockqtty+df.carcvqtty+df.caqtty) totalqtty,
                    sum(df.dfqtty) tradeqtty, sum(df.rcvqtty) recvqtty, sum(df.blockqtty) resqtty, sum(df.carcvqtty + df.caqtty) otherqtty,
                    max(sif.basicprice) refprice, sum(df.dfrate * (df.dfqtty+df.rcvqtty+df.blockqtty+df.carcvqtty+df.caqtty) * df.dfprice /100) loanamount
                FROM dfmast df, securities_info sif, afmast af
                WHERE df.codeid = sif.codeid AND df.status = 'A'
                      AND df.afacctno=af.acctno
                      AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )
                GROUP BY df.codeid
            ) a, securities_info sif, ALLCODE A1
            WHERE a.codeid = sif.codeid and a.totalqtty > 0
                AND A1.CDTYPE = 'SA' AND A1.CDNAME = 'ROOMTYPE' AND CDVAL = 'S'
            GROUP BY a.symbol
            ORDER BY a.symbol
        ;
    ELSIF V_ROOMTYPE = 'M' THEN
        -- ROOM TUAN THU TT74 --> CHI LAY MARGIN THEO TT74
        OPEN PV_REFCURSOR FOR
            SELECT a.symbol, max(sif.syroomlimit) totalroomlimit, sum(a.totalqtty) totalqtty, sum(a.tradeqtty) tradeqtty,
                sum(a.recvqtty) recvqtty, sum(a.resqtty) resqtty, sum(a.otherqtty) otherqtty, max(sif.basicprice) refprice,
                sum(a.loanamount) loanamount, max(sif.listingqtty) listingqtty,
                CASE WHEN max(sif.listingqtty) > 0 then round(sum(a.totalqtty)/max(sif.listingqtty)*100,4) ELSE 0 END lstqttrate,
                MAX(A1.CDCONTENT) ROOMTYPEDESC, V_IN_DATE IN_DATE
            FROM
            (
                SELECT mr.symbol, mr.codeid, sum(mr.prinused) totalqtty, sum(mr.tradeqtty) tradeqtty,
                    sum(mr.recvqtty) recvqtty, 0 resqtty, 0 otherqtty, max(mr.refprice) refprice, sum(mr.loanamount) loanamount
                FROM
                (
                    SELECT sif.symbol, alo.codeid, alo.afacctno, alo.prinused,
                        sm.trade, asr.mrratiorate, asr.mrratioloan,
                        CASE WHEN alo.prinused >= sm.trade THEN sm.trade ELSE alo.prinused END tradeqtty,
                        CASE WHEN alo.prinused >= sm.trade THEN alo.prinused - sm.trade ELSE 0 END recvqtty,
                        0 resqtty, 0 otherqtty, sif.basicprice refprice, alo.prinused * least(asr.mrratioloan, (100-af.mriratio)) * sif.basicprice /100 loanamount
                    FROM
                        (
                            SELECT alo.afacctno, alo.codeid, sum(alo.prinused) prinused
                            FROM vw_afpralloc_all alo
                            WHERE alo.prinused <>0
                                AND alo.restype = 'M'
                            GROUP BY alo.afacctno, alo.codeid
                        ) alo, semast sm, afmast af, afserisk74 asr, securities_info sif
                    WHERE alo.codeid = sif.codeid AND alo.afacctno = af.acctno
                        AND alo.afacctno = sm.afacctno AND alo.codeid = sm.codeid
                        AND af.actype = asr.actype AND alo.codeid = asr.codeid
                        AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )
                ) mr
                GROUP BY mr.symbol, mr.codeid
            ) a, securities_info sif, ALLCODE A1
            WHERE a.codeid = sif.codeid and a.totalqtty > 0
                AND A1.CDTYPE = 'SA' AND A1.CDNAME = 'ROOMTYPE' AND CDVAL = 'M'
            GROUP BY a.symbol
            ORDER BY a.symbol
        ;
    END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
