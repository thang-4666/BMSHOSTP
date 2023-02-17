SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_GETDEALINFO
(ACCTNO, AFACCTNO, LNACCTNO, FULLNAME, ADDRESS, 
 DEALTYPE, IDCODE, CUSTODYCD, FLAGTRIGGER, EMAIL, 
 TRIGGERDATE, TLID, CURRPRICE, NINTCD, PRINTFRQ1, 
 RATE1, PRINTFRQ2, RATE2, PRINTFRQ3, RATE3, 
 RLSDATE, CFRATE1, CFRATE2, CFRATE3, MINTERM, 
 PREPAID, INTPAIDMETHOD, AUTOAPPLY, FEEINTNMLACR, FEEINTOVDACR, 
 FEEINTNMLOVD, FEEINTDUE, FEEINTPREPAID, FEEINTPAID, INTFLOATAMT, 
 FEEFLOATAMT, TXDATE, TXNUM, TXTIME, ACTYPE, 
 RRTYPE, LIMITCHK, DFTYPE, CUSTBANK, CIACCTNO, 
 LNTYPE, LIMITCHECK, CIDRAWNDOWN, BANKDRAWNDOWN, CMPDRAWNDOWN, 
 RRID, FEE, FEEMIN, TAX, AMTMIN, 
 CODEID, SYMBOL, REFPRICE, DFPRICE, TRIGGERPRICE, 
 DFRATE, IRATE, MRATE, LRATE, CALLTYPE, 
 DFQTTY, BQTTY, RCVQTTY, CARCVQTTY, BLOCKQTTY, 
 CACASHQTTY, RLSQTTY, ADDASSETQTTY, INITASSETQTTY, DFAMT, 
 RLSAMT, AMT, ORGAMT, INTAMTACR, REMAINAMT, 
 FEEAMT, RLSFEEAMT, STATUS, DFREF, DESCRIPTION, 
 PRINNML, PRINOVD, INTNMLACR, INTOVDACR, INTNMLOVD, 
 INTDUE, INTPREPAID, INTPAID, OPRINNML, OPRINOVD, 
 OINTNMLACR, OINTOVDACR, OINTNMLOVD, OINTDUE, OINTPREPAID, 
 FEEDUE, FEEOVD, DEALAMT, DEALFEE, DEALPRINAMT, 
 DEALFEERATE, REMAINQTTY, AVLFEEAMT, ODAMT, RTT, 
 TAMT, CALLAMT, AVLRLSQTTY, AVLRLSAMT, DFTRADING, 
 SECURED, SECURED_MATCH, BASICPRICE, AUTOPAID, GROUPID, 
 TRADELOT, RELEVSDQTTY, DFSTANDING)
BEQUEATH DEFINER
AS 
select df.ACCTNO,df.AFACCTNO,df.LNACCTNO,to_char(cf.FULLNAME) FULLNAME,CF.ADDRESS ADDRESS,df.dealtype,
        CF.IDCODE IDCODE,CF.CUSTODYCD CUSTODYCD, DF.FLAGTRIGGER, cf.email, df.triggerdate, nvl(df.tlid,'0000') tlid, sb.basicprice currprice,
        LNTYPE.NINTCD, ln.PRINTFRQ1, ln.rate1, ln.PRINTFRQ2, ln.rate2, ln.PRINTFRQ3, ln.rate3, ln.rlsdate,
        ln.cfrate1,ln.cfrate2,ln.Cfrate3,ln.minterm,ln.PREPAID,ln.INTPAIDMETHOD,ln.autoapply,
        ln.FEEINTNMLACR,ln.FEEINTOVDACR,ln.FEEINTNMLOVD,ln.FEEINTDUE,ln.FEEINTPREPAID,
        ln.FEEINTPAID,ln.INTFLOATAMT,ln.FEEFLOATAMT,
                df.TXDATE ,df.TXNUM,df.TXTIME,df.ACTYPE,
                df.RRTYPE,df.LIMITCHK,df.DFTYPE,df.CUSTBANK,df.CIACCTNO,df.LNTYPE,
                (case when df.LIMITCHK='Y' then 1 else 0 end ) LIMITCHECK,
                (case when df.RRTYPE='O' then 1 else 0 end ) CIDRAWNDOWN,
                (case when df.RRTYPE='B' then 1 else 0 end ) BANKDRAWNDOWN,
                (case when df.RRTYPE='C' then 1 else 0 end ) CMPDRAWNDOWN,
                (case when df.RRTYPE='C' then ''
            when df.RRTYPE='O' then df.ciacctno
            when df.RRTYPE='B' then df.custbank
            else '' end) RRID,
                df.FEE,df.FEEMIN,df.TAX,df.AMTMIN,
                df.CODEID,DF.SYMBOL SYMBOL,df.REFPRICE,df.DFPRICE,df.TRIGGERPRICE,
                df.DFRATE,df.IRATE,df.MRATE,df.LRATE,
                ac.cdcontent CALLTYPE,df.DFQTTY,df.BQTTY,df.RCVQTTY,df.CARCVQTTY,df.BLOCKQTTY,DF.CACASHQTTY,df.RLSQTTY,DF.ADDASSETQTTY, DF.INITASSETQTTY,
                df.DFAMT,df.RLSAMT,df.AMT,df.ORGAMT,df.INTAMTACR, (df.amt - df.rlsamt) REMAINAMT,
                df.FEEAMT,df.RLSFEEAMT,df.STATUS,
                df.DFREF,to_char(df.DESCRIPTION) DESCRIPTION,
                ln.PRINNML,ln.PRINOVD,
                round(ln.INTNMLACR,0) INTNMLACR,round(ln.INTOVDACR,0) INTOVDACR,round(ln.INTNMLOVD,0) INTNMLOVD,
                round(ln.INTDUE,0) INTDUE,round(ln.INTPREPAID,0) INTPREPAID, round(ln.INTPAID,0) INTPAID,
                ln.OPRINNML,ln.OPRINOVD,
                round(ln.OINTNMLACR,0) OINTNMLACR,round(ln.OINTOVDACR,0) OINTOVDACR,round(ln.OINTNMLOVD,0) OINTNMLOVD,
                round(ln.OINTDUE,0) OINTDUE,round(ln.OINTPREPAID,0) OINTPREPAID,
                round(ln.FEEDUE,0) FEEDUE,round(ln.FEEOVD,0) FEEOVD,
                DF.AMT DEALAMT,
                greatest(round(df.INTAMTACR,0)+round(df.FEEAMT,0) ,round(df.FEEMIN,0) - round(df.RLSFEEAMT,0)) + round(ln.INTNMLACR,0)+round(ln.INTOVDACR,0)+round(ln.INTNMLOVD,0)+round(ln.INTDUE,0)+
                 round(ln.FEEINTNMLACR,0)+round(ln.FEEINTOVDACR,0)+round(ln.FEEINTNMLOVD,0)+round(ln.FEEINTDUE,0)+
                round(ln.OINTNMLACR,0)+round(ln.OINTOVDACR,0)+round(ln.OINTNMLOVD,0)+round(ln.OINTDUE,0)+round(ln.FEE,0)+round(ln.FEEDUE,0)+round(ln.FEEOVD,0) DEALFEE,
                ln.PRINNML+ln.PRINOVD+ln.OPRINNML+ln.OPRINOVD DEALPRINAMT, --Lay phan goc chua tra
                case when ln.PRINNML+ln.PRINOVD+ln.OPRINNML+ln.OPRINOVD>0 then
                    round(100*(greatest(round(df.INTAMTACR,0)+round(df.FEEAMT,0) ,round(df.FEEMIN,0) - round(df.RLSFEEAMT,0)) + round(ln.INTNMLACR,0)+round(ln.INTOVDACR,0)+round(ln.INTNMLOVD,0)+round(ln.INTDUE,0)+
                round(ln.FEEINTNMLACR,0)+round(ln.FEEINTOVDACR,0)+round(ln.FEEINTNMLOVD,0)+round(ln.FEEINTDUE,0)+
                round(ln.OINTNMLACR,0)+round(ln.OINTOVDACR,0)+round(ln.OINTNMLOVD,0)+round(ln.OINTDUE,0)+round(ln.FEE,0)+round(ln.FEEDUE,0)+round(ln.FEEOVD,0))/
                    (ln.PRINNML+ln.PRINOVD+ln.OPRINNML+ln.OPRINOVD) ,11)
                else 0 END DEALFEERATE,    --Lay ty le % lai tren goc tai thoi diem hien tai
                df.dfqtty + df.rcvqtty + df.carcvqtty + df.blockqtty + df.bqtty + df.cacashqtty remainqtty,
                greatest(round(df.INTAMTACR,0)+round(df.feeamt,0),round(df.FEEMIN,0)-round(df.RLSFEEAMT,0)) AVLFEEAMT,
                greatest(round(df.INTAMTACR,0)+round(df.feeamt,0),round(df.FEEMIN,0)-round(df.RLSFEEAMT,0)) +
                ln.PRINNML + ln.PRINOVD + round(ln.INTNMLACR,0) + round(ln.INTOVDACR,0) +round(ln.INTNMLOVD,0)+round(ln.INTDUE,0)+
                    ln.OPRINNML+ln.OPRINOVD+round(ln.OINTNMLACR,0)+round(ln.OINTOVDACR,0)+round(ln.OINTNMLOVD,0)+
                    round(ln.OINTDUE,0)+round(ln.FEE,0)+round(ln.FEEDUE,0)+round(ln.FEEOVD,0)
                    +  round(ln.FEEINTNMLACR,0) + round(ln.FEEINTOVDACR,0) +round(ln.FEEINTNMLOVD,0)+round(ln.FEEINTDUE,0) ODAMT,
                (case when df.CALLTYPE='P' then 0 else
                         (case when (DF.DFAMT + greatest(round(df.INTAMTACR,0)+round(df.feeamt,0),round(df.FEEMIN,0)-round(df.RLSFEEAMT,0)) +
                      ln.PRINNML+ln.PRINOVD+round(ln.INTNMLACR,0)+round(ln.INTOVDACR,0)+round(ln.INTNMLOVD,0)+round(ln.INTDUE,0)+
                      round(ln.FEEINTNMLACR,0)+round(ln.FEEINTOVDACR,0)+round(ln.FEEINTNMLOVD,0)+round(ln.FEEINTDUE,0)+
                          ln.OPRINNML+ln.OPRINOVD+round(ln.OINTNMLACR,0)+round(ln.OINTOVDACR,0)+round(ln.OINTNMLOVD,0)+
                          round(ln.OINTDUE,0)+round(ln.FEE,0)+round(ln.FEEDUE,0)+round(ln.FEEOVD,0)) =0
                         then 1000000
                         else
                          round(((df.dfqtty + df.rcvqtty + df.carcvqtty + df.blockqtty + df.bqtty) * SB.DFREFPRICE + df.cacashqtty) * DF.DFRATE
                  / (DF.DFAMT + greatest(round(df.INTAMTACR,0)+round(df.feeamt,0),round(df.FEEMIN,0)-round(df.RLSFEEAMT,0)) +
                      ln.PRINNML+ln.PRINOVD+round(ln.INTNMLACR,0)+round(ln.INTOVDACR,0)+round(ln.INTNMLOVD,0)+round(ln.INTDUE,0)+
                      round(ln.FEEINTNMLACR,0)+round(ln.FEEINTOVDACR,0)+round(ln.FEEINTNMLOVD,0)+round(ln.FEEINTDUE,0)+
                          ln.OPRINNML+ln.OPRINOVD+round(ln.OINTNMLACR,0)+round(ln.OINTOVDACR,0)+round(ln.OINTNMLOVD,0)+
                          round(ln.OINTDUE,0)+round(ln.FEE,0)+round(ln.FEEDUE,0)+round(ln.FEEOVD,0)),4)
                    end)
        end) Rtt,
        DF.RLSAMT+ greatest(round(df.INTAMTACR,0)+round(df.feeamt,0),round(df.FEEMIN,0)-round(df.RLSFEEAMT,0)) +
                      ln.PRINNML+ln.PRINOVD+round(ln.INTNMLACR,0)+round(ln.INTOVDACR,0)+round(ln.INTNMLOVD,0)+round(ln.INTDUE,0)+
                      round(ln.FEEINTNMLACR,0)+round(ln.FEEINTOVDACR,0)+round(ln.FEEINTNMLOVD,0)+round(ln.FEEINTDUE,0)+
                      ln.OPRINNML+ln.OPRINOVD+round(ln.OINTNMLACR,0)+round(ln.OINTOVDACR,0)+
                      round(ln.OINTNMLOVD,0)+round(ln.OINTDUE,0)+round(ln.FEE,0)+round(ln.FEEDUE,0)+round(ln.FEEOVD,0) TAMT,
                greatest(
                    (case when df.CALLTYPE='P' then
                (case when sb.DFREFPRICE<=df.triggerprice then
                          round((df.dfprice-(case when nvl(bsk.dfprice,0)>0
                                                    then least(nvl(bsk.dfprice,0),nvl(sb.DFREFPRICE,0) * nvl(bsk.dfrate,0)/100)
                                                    else nvl(sb.DFREFPRICE,0) * nvl(bsk.dfrate,0)/100
                                                end)) *
                          (df.dfqtty + df.rcvqtty + df.carcvqtty + df.blockqtty + df.bqtty) + df.cacashqtty * nvl(bsk.dfrate,0)/100  - df.dfamt,4)
                      else 0
                      end)
            else
              greatest(0,
                                (case when df.irate <=0 then 0 else
                                    round((DF.DFAMT + ln.PRINNML+ln.PRINOVD) -
                                    ((df.dfqtty + df.rcvqtty + df.carcvqtty + df.blockqtty + df.bqtty) * SB.DFREFPRICE + df.cacashqtty) * DF.DFRATE/df.irate,4)
                                end)
              )
            end ),0) callamt,
        greatest(
      (case when df.AMT<=0 then df.dfqtty + df.rcvqtty + df.carcvqtty + df.blockqtty + df.bqtty + df.cacashqtty + rlsqtty - nvl(v.secureamt,0)
          else
              ROUND (df.rlsamt / df.AMT
                  * (df.dfqtty + df.rcvqtty + df.carcvqtty + df.blockqtty + df.bqtty + rlsqtty + df.cacashqtty)
                  - rlsqtty)
          end),0) avlrlsqtty,
        greatest(round(dfamt-
                            (case when sb.DFREFPRICE<=df.triggerprice then
                          round((df.dfprice-(case when nvl(bsk.dfprice,0)>0
                                                    then least(nvl(bsk.dfprice,0),nvl(sb.DFREFPRICE,0) * nvl(bsk.dfrate,0)/100)
                                                    else nvl(sb.DFREFPRICE,0) * nvl(bsk.dfrate,0)/100
                                                end)) *
                          (df.dfqtty + df.rcvqtty + df.carcvqtty + df.blockqtty + df.bqtty) + df.cacashqtty* nvl(bsk.dfrate,0)/100 - df.dfamt,4)
                          else 0
                          end),0) ,4) avlrlsamt,
        case when df.relamt > 0 then dfqtty + df.dfstanding - nvl(v.secureamt,0) - df.sendvsdqtty else 0 end dftrading,nvl(v.secureamt,0) secured,nvl(v.secureamt,0) secured_match,sb.DFREFPRICE BASICPRICE,df.autopaid,df.groupid,sb.tradelot,
        df.RELEVSDQTTY, df.dfstanding
        from (select df.*, dft.basketid, to_char(sb.symbol) symbol, dft.isvsd, dfg.amt relamt   from dfmast df, dftype dft, sbsecurities sb, dfgroup dfg where df.actype = dft.actype and df.codeid = sb.codeid and df.groupid=dfg.groupid ) df, lnmast ln, lntype,
        securities_info sb, dfbasket bsk, sbsecurities sec, afmast af, cfmast cf,v_getdealsellorderinfo v, allcode ac
                where df.lnacctno = ln.acctno and df.codeid= sb.codeid and sb.codeid = sec.codeid and df.afacctno = af.acctno and af.custid= cf.custid
                and df.calltype = ac.cdval and ac.cdtype = 'DF' and ac.cdname = 'CALLTYPE' and ln.actype=lntype.actype
                and df.basketid= bsk.basketid(+) and to_char(df.symbol) = bsk.symbol (+)
                and df.dealtype =bsk.dealtype(+)
                and df.acctno = v.dfacctno (+)
/
