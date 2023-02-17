SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_re_commision(strACCTNO IN varchar2 -- ma tk moi gioi.
)
RETURN NUMBER IS
-- PURPOSE: SO CK THAY DOI TRONG KY
-- MODIFICATION HISTORY
-- PERSON      DATE         COMMENTS
-- ---------   ------       -------------------------------------------
-- THANHNM   09/03/2012     CREATED
   V_RESULT         NUMBER;
   V_STRCUSTODYCD   VARCHAR2(20);
   v_currdate       date;
   v_nextdate       date;
   v_lastday        number;
   v_revenue        number(20,4);
   v_odfeetype      varchar2(1);
   v_odfeerate      number(20,4);
   v_strACCTNO      varchar2(50);
   v_disdirectacr   number(20,4); -- Doanh so truc tiep
   V_directfeeacr   number(20,4); -- Doanh thu truc tiep
   V_indirectacr    number(20,4); -- Doanh so gian tiep
   v_matchamt       number(20,4); -- Doanh so trong ngay
   v_feeacr         number(20,4); -- Doanh thu trong ngay
   v_DAMTACR        number(20,4); -- Doanh so giam tiep trong ngay

   v_count          number(10);

BEGIN
    v_strACCTNO    := strACCTNO;
    SELECT TO_DATE (varvalue, systemnums.c_date_format)
        INTO v_currdate
    FROM sysvar
    WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    SELECT TO_DATE (varvalue, systemnums.c_date_format)
        INTO v_nextdate
    FROM sysvar
    WHERE grname = 'SYSTEM' AND varname = 'NEXTDATE';
   --Xac dinh ngay cuoi cung cua thang
    select to_number(to_char(max(sbdate),'DD')) into v_lastday from sbcldr where  to_char(sbdate,'MM/YYYY')= to_char(v_CURRDATE,'MM/YYYY') and cldrtype ='000';
    V_RESULT := 0;

    begin
        select odfeetype, odfeerate, directacr, directfeeacr, indirectacr
            into v_odfeetype, v_odfeerate, v_disdirectacr, V_directfeeacr, V_indirectacr
        from remast rm where acctno = v_strACCTNO;
    EXCEPTION WHEN OTHERS THEN
        v_odfeetype := 'F';
        v_odfeerate := 0;
        v_disdirectacr := 0;
        V_directfeeacr := 0;
        V_indirectacr := 0;
    end ;
    begin
        Select sum(od.execamt) matchamt, sum(od.feeacr) feeacr
            into v_matchamt, v_feeacr
        From reaflnk re, odmast od, recfdef red, retype ret, remast rem, afmast af
        Where re.status='A' and re.deltd<>'Y'
            and re.frdate<= v_currdate and v_currdate <= re.todate
            and od.deltd<>'Y'
            and od.txdate = (select to_date(varvalue,'dd/mm/yyyy') from sysvar where varname='CURRDATE')
            and re.afacctno = af.custid and af.acctno = od.afacctno
            and od.execamt >0
            and re.refrecflnkid = red.refrecflnkid
            and substr(re.reacctno,11,4)=red.reactype
            and red.effdate<= v_currdate and  v_currdate < red.expdate
            and red.reactype=ret.actype
            and ret.retype='D'
            and re.reacctno=rem.acctno
            and re.reacctno = v_strACCTNO;
    EXCEPTION WHEN OTHERS THEN
        v_matchamt := 0;
        v_feeacr := 0;
    end;
    v_disdirectacr := v_disdirectacr + nvl(v_matchamt,0);
    V_directfeeacr := V_directfeeacr + nvl(v_feeacr,0);
    V_indirectacr  := V_indirectacr + nvl(v_matchamt,0);

    select count(autoid) into v_count from REGRP where custid || actype = strACCTNO;


    if (v_count > 0 ) then
        begin
                Select sum(rgl.DAMTACR )
                    into v_DAMTACR
                From REGRP rg,
                 (Select rgl.refrecflnkid, sum(tr.matchamt) DAMTACR
                  From REGRPLNK rgl, (Select re.reacctno, sum(od.execamt) matchamt, sum(od.feeacr) feeacr
                From reaflnk re, odmast od, recfdef red, retype ret, remast rem, afmast af
                Where re.status='A' and re.deltd<>'Y'
                    and re.frdate<= v_currdate and v_currdate <= re.todate
                    and od.deltd<>'Y'
                    and od.txdate = (select to_date(varvalue,'dd/mm/yyyy') from sysvar where varname='CURRDATE')
                    and re.afacctno = af.custid and af.acctno = od.afacctno
                    and od.execamt >0
                    and re.refrecflnkid = red.refrecflnkid
                    and substr(re.reacctno,11,4)=red.reactype
                    and red.effdate<= v_currdate and  v_currdate < red.expdate
                    and red.reactype=ret.actype
                    and ret.retype='D'
                    and re.reacctno=rem.acctno
    group by reacctno) tr, remast rm,
                  retype ret
                  where rgl.reacctno=rm.acctno
                        and rm.acctno = tr.reacctno(+)
                       and rgl.frdate<=v_currdate and v_currdate<=rgl.todate
                        and rgl.deltd<>'Y'
                        and rgl.status='A'
                        and rm.status='A'
                        and rm.actype=ret.actype
                        and ret.retype='D'
                   Group by  rgl.refrecflnkid
                   ) rgl
                Where SP_FORMAT_REGRP_MAPCODE( rgl.refrecflnkid) like SP_FORMAT_REGRP_MAPCODE(rg.autoid)||'%'
                and rg.custid||rg.actype = v_strACCTNO;
        EXCEPTION WHEN OTHERS THEN
            v_DAMTACR := 0;
        end;
    end if;

    V_indirectacr  := V_indirectacr + nvl(v_DAMTACR,0);

    If v_odfeetype = 'F' then  -- Phi co dinh
        v_revenue := v_disdirectacr * v_odfeerate/100;
    ELSE  -- Phi thuc thu
        IF V_INDIRECTACR <> 0 THEN
            v_revenue := v_disdirectacr*V_directfeeacr/V_indirectacr;
        ELSE -- v_disdirectacr, V_directfeeacr, V_indirectacr
            v_revenue:=0;
        END IF;
    End if;

    V_RESULT := fn_re_getcommision(v_strACCTNO,v_disdirectacr,v_revenue);

    RETURN V_RESULT;

EXCEPTION
   WHEN OTHERS THEN
    RETURN 0;
END;


                                                             -- PROCEDURE

 
 
 
 
 
 
 
 
 
 
 
/
