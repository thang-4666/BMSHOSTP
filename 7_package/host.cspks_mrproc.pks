SET DEFINE OFF;
CREATE OR REPLACE PACKAGE cspks_mrproc
IS
    /*----------------------------------------------------------------------------------------------------
     ** Module   : COMMODITY SYSTEM
     ** and is copyrighted by FSS.
     **
     **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
     **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
     **    graphic, optic recording or otherwise, translated in any language or computer language,
     **    without the prior written permission of Financial Software Solutions. JSC.
     **
     **  MODIFICATION HISTORY
     **  Person      Date           Comments
     **  FSS      20-mar-2010    Created
     ** (c) 2008 by Financial Software Solutions. JSC.
     ----------------------------------------------------------------------------------------------------*/

    FUNCTION fn_TriggerAccountLog( p_type in varchar2 ,p_err_code in out varchar2)
    RETURN boolean;

  FUNCTION fn_ReleaseAdvanceLine(p_err_code in out varchar2)
  RETURN number;

  FUNCTION fn_getMrRate(p_afacctno in varchar2, p_codeid in varchar2)
  RETURN number;

  FUNCTION fn_getMrPrice(p_afacctno in varchar2, p_codeid in varchar2)
  RETURN number;

END;

 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY cspks_mrproc
IS
   -- declare log context
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

---------------------------------pr_OpenLoanAccount------------------------------------------------
FUNCTION fn_TriggerAccountLog( p_type in varchar2,p_err_code in out varchar2)
RETURN boolean
IS
l_currdate date;
BEGIN
    plog.setendsection(pkgctx, 'fn_TriggerAccountLog');
    l_currdate:= to_date(cspks_system.fn_get_sysvar('SYSTEM','CURRDATE'),'DD/MM/RRRR');

    /*update afmast
    set callday = callday + 1
    where exists (select 1 from v_getsecmarginratio v where (v.marginrate < v.mrmrate or v.dueamt > 1) and afmast.acctno = v.afacctno)
    and callday < 3;

    update afmast
    set callday = 0
    where exists (select 1 from v_getsecmarginratio v where v.marginrate >= v.mrmrate and v.dueamt < 1 and afmast.acctno = v.afacctno)
    and callday <= 3;

    update afmast
    set triggerdate = l_currdate
    where (exists (select 1 from v_getsecmarginratio v where (v.marginrate < v.mrlrate or v.ovamt > 1) and afmast.acctno = v.afacctno)
        or callday = 3)
    and triggerdate is null;

    update afmast
    set triggerdate = null
    where exists (select 1 from v_getsecmarginratio v where v.marginrate >= v.mrlrate and v.ovamt < 1 and afmast.acctno = v.afacctno)
        and callday < 3
    and triggerdate is not null;
    */
    --  HaiLT them

    --p_type ='AT' sau chay batch
    --p_type ='BF' sau chay batch

    if p_type='AT' THEN

    UPDATE DFGROUP
    SET CALLDAYS=CALLDAYS+1
    WHERE EXISTS (select 1 from v_getgrpdealformular V
                where (v.RTTDF < V.MRATE) and DFGROUP.GROUPID = v.GROUPID);

    UPDATE DFGROUP
    SET CALLDAYS=0
    WHERE EXISTS (select 1 from v_getgrpdealformular V
                where (v.RTTDF >= V.ARATE) and DFGROUP.GROUPID = v.GROUPID);



    -- End of HaiLT them



    UPDATE AFMAST
    SET CALLDAY=CALLDAY+1
    WHERE EXISTS (select 1 from v_getsecmarginratio V
                where (v.marginrate < V.MRMRATE/* and v.marginrate >= v.mrlrate*/) and afmast.acctno = v.afacctno);
    -- nhung tai khoan co to Rtt<Rnop tien va da tung co Rtt<Rcall trong qua khu
    update afmast
    set callday = callday + 1
    where CALLDAY>0
    AND EXISTS (select 1 from v_getsecmarginratio V
                where (v.marginrate < V.MRCRATE and v.marginrate >= V.MRMRATE) and afmast.acctno = v.afacctno);

    update afmast
    set callday = 0
    where exists (select 1 from v_getsecmarginratio v where v.marginrate >= V.MRCRATE and afmast.acctno = v.afacctno);


    /*update afmast
    set triggerdate = l_currdate
    where (exists (select 1 from v_getsecmarginratio v where (v.marginrate < v.mrlrate or v.ovamt > 1) and afmast.acctno = v.afacctno)
        )
    and triggerdate is null;*/
    update afmast
    set triggerdate = l_currdate
    where triggerdate is null AND (exists (select 1 from v_getsecmarginratio v where (v.marginrate < v.mrlrate or v.ovamt > 1) and afmast.acctno = v.afacctno)
        ) or afmast.CALLDAY >=afmast.K1DAYS
    ;

    update afmast
    set triggerdate = null
    where triggerdate is not null AND (afmast.CALLDAY < afmast.K1DAYS or afmast.CALLDAY=0) AND
        exists (select 1 from v_getsecmarginratio v
    where v.marginrate >= v.mrlrate and v.ovamt < 1 and afmast.acctno = v.afacctno)
     ;

END IF;

    --Cap nhat trang thai call len CFMAST
    update cfmast set callsts ='N' ;
    update cfmast set callsts ='Y' where exists (select 1 from afmast v where triggerdate is not null and cfmast.custid = v.custid);

    -- cap nhat trang thai call cfmast cho mr0002
    update cfmast set callsts ='Y'
    where exists (select 1 from v_getsecmarginratio sec,afmast af, cfmast cf
                           where sec.afacctno = af.acctno and af.custid = cf.custid
                           and (sec.marginrate  < af.mrmrate
                                     or ( sec.marginrate<af.mrcrate and af.callday>0)
                                )
                           and cf.custatcom ='Y'
                           and af.custid =cfmast.custid
                            );

    plog.setendsection(pkgctx, 'fn_TriggerAccountLog');
    return true;
EXCEPTION
WHEN OTHERS
THEN
  plog.error (pkgctx, SQLERRM);
  plog.setendsection (pkgctx, 'fn_TriggerAccountLog');
  RAISE errnums.E_SYSTEM_ERROR;
  return false;
END fn_TriggerAccountLog;


FUNCTION fn_ReleaseAdvanceLine(p_err_code in out varchar2)
RETURN number
IS
l_currdate date;
l_prevdate date;
l_release_advanceline number(20,4);
l_release_t0limitschd number(20,4);
l_txnum varchar2(10);
l_T0Limit number(20,4);
l_trft0amt number(20,0);
l_exec_trft0amt number(20,0);

BEGIN
    plog.setendsection(pkgctx, 'fn_ReleaseAdvanceLine');
    l_currdate:= to_date(cspks_system.fn_get_sysvar('SYSTEM','CURRDATE'),'DD/MM/RRRR');
    l_prevdate:= to_date(cspks_system.fn_get_sysvar('SYSTEM','PREVDATE'),'DD/MM/RRRR');

    for rec in
    (
        select af.acctno afacctno, af.advanceline, nvl(oprin.oprinamount,0) oprinamount
        from afmast af,
            (select trfacctno, sum(oprinnml+oprinovd) oprinamount
                from lnmast
                where ftype = 'AF' and oprinnml+oprinovd > 0
                group by trfacctno) oprin
        where af.acctno = oprin.trfacctno(+)
        order by af.acctno
    )
    loop
        -- Xac dinh so Bao Lanh Co the thu hoi.
        -- So Bao Lanh phai giu lai: So Tien Tra Cham. Luu trong bang STSCHD.
        -- So Bao Lanh khong duoc phep Release: Goc Bao lanh dang vay.
        select nvl(sum(acclimit),0) into l_T0Limit from useraflimit where acctno = rec.afacctno and typereceive = 'T0';
        l_release_advanceline:= greatest(l_T0Limit - rec.oprinamount,0);

        if l_release_advanceline > 0 then

            --Lay TXNUM
            SELECT    '8000'
                      || SUBSTR ('000000' || seq_batchtxnum.NEXTVAL,
                                 LENGTH ('000000' || seq_batchtxnum.NEXTVAL) - 5,
                                 6
                                )
                 INTO l_txnum
                 FROM DUAL;


            l_trft0amt:=greatest(l_release_advanceline,0);
            l_exec_trft0amt:=0;
            FOR REC_2 IN
            (
                SELECT AUTOID, TLID, TYPEALLOCATE, ALLOCATEDLIMIT - RETRIEVEDLIMIT AMT
                FROM (  select * from T0LIMITSCHD
                            union all
                        select * from T0LIMITSCHDHIST)
                WHERE ACCTNO = rec.afacctno AND ALLOCATEDLIMIT - RETRIEVEDLIMIT > 0
                ORDER BY AUTOID
            )
            LOOP
                IF l_trft0amt > 0 THEN
                    IF l_trft0amt > REC_2.AMT THEN
                       l_release_t0limitschd := REC_2.AMT;
                    ELSE
                       l_release_t0limitschd := l_trft0amt;
                    END IF;
                    l_trft0amt := l_trft0amt - l_release_t0limitschd;
                    l_exec_trft0amt:=l_exec_trft0amt + l_release_t0limitschd;
                    -- Cap nhat giam so luong da phan bo bao lanh
                    UPDATE T0LIMITSCHD SET RETRIEVEDLIMIT = RETRIEVEDLIMIT + l_release_t0limitschd WHERE AUTOID = REC_2.AUTOID;
                    UPDATE T0LIMITSCHDHIST SET RETRIEVEDLIMIT = RETRIEVEDLIMIT + l_release_t0limitschd WHERE AUTOID = REC_2.AUTOID;

                    UPDATE USERAFLIMIT SET ACCLIMIT = ACCLIMIT - l_release_t0limitschd
                    WHERE ACCTNO = rec.afacctno AND TLIDUSER = REC_2.TLID AND TYPERECEIVE = 'T0';

                    INSERT INTO USERAFLIMITLOG (TXNUM,TXDATE,ACCTNO,ACCLIMIT,TLIDUSER,TYPEALLOCATE,TYPERECEIVE)
                    VALUES (l_txnum, l_prevdate,rec.afacctno,-l_release_t0limitschd,REC_2.TLID,REC_2.TYPEALLOCATE,'T0');

                    INSERT INTO RETRIEVEDT0LOG(TXDATE, TXNUM, AUTOID, TLID, RETRIEVEDAMT)
                    VALUES(l_prevdate,l_txnum, REC_2.AUTOID, REC_2.TLID, l_release_t0limitschd);


                END IF;
            END LOOP;

            /*FOR REC_2 IN
            (
                SELECT AUTOID, TLID, TYPEALLOCATE, ALLOCATEDLIMIT - RETRIEVEDLIMIT AMT
                FROM (  select * from T0LIMITSCHD
                            union all
                        select * from T0LIMITSCHDHIST)
                WHERE ACCTNO = rec.afacctno AND ALLOCATEDLIMIT - RETRIEVEDLIMIT > 0
                ORDER BY AUTOID DESC
            )
            LOOP
                IF l_release_advanceline > 0 THEN
                    IF l_release_advanceline > REC_2.AMT THEN
                       l_release_t0limitschd := REC_2.AMT;
                    ELSE
                       l_release_t0limitschd := l_release_advanceline;
                    END IF;
                    l_release_advanceline := l_release_advanceline - l_release_t0limitschd;
                    -- Cap nhat giam so luong da phan bo bao lanh
                    UPDATE T0LIMITSCHD SET RETRIEVEDLIMIT = RETRIEVEDLIMIT + l_release_t0limitschd WHERE AUTOID = REC_2.AUTOID;
                    UPDATE T0LIMITSCHDHIST SET RETRIEVEDLIMIT = RETRIEVEDLIMIT + l_release_t0limitschd WHERE AUTOID = REC_2.AUTOID;

                    UPDATE USERAFLIMIT SET ACCLIMIT = ACCLIMIT - l_release_t0limitschd
                    WHERE ACCTNO = rec.afacctno AND TLIDUSER = REC_2.TLID AND TYPERECEIVE = 'T0';

                    INSERT INTO USERAFLIMITLOG (TXNUM,TXDATE,ACCTNO,ACCLIMIT,TLIDUSER,TYPEALLOCATE,TYPERECEIVE)
                    VALUES (l_txnum, l_prevdate,rec.afacctno,-l_release_t0limitschd,REC_2.TLID,REC_2.TYPEALLOCATE,'T0');

                    INSERT INTO RETRIEVEDT0LOG(TXDATE, TXNUM, AUTOID, TLID, RETRIEVEDAMT)
                    VALUES(l_prevdate,l_txnum, REC_2.AUTOID, REC_2.TLID, l_release_t0limitschd);


                END IF;
            END LOOP;*/

            update afmast set t0amt = 0
            where acctno = rec.afacctno;
        end if;

        -- Thu hoi AFMAST.ADVANCELINE
        if greatest(rec.advanceline,0) > 0 then
            INSERT INTO aftran (acctno, txnum,txdate, txcd, namt, camt, REF,deltd, autoid)
            VALUES (rec.afacctno, l_txnum,l_currdate, '0022', greatest(rec.advanceline,0), '', '','N', seq_aftran.NEXTVAL);

            update afmast
            set advanceline = advanceline - greatest(rec.advanceline,0)
            where acctno = rec.afacctno;
        end if;
    end loop;

    --Thiet lap lai han muc Bao Lanh cho tai khoan tu doanh.
    for rec in (
        select af.acctno, af.advanceline, 3000000000 initadvanceline from cfmast cf, afmast af
            where cf.custid = af.custid and substr(cf.custodycd,4,1) ='P'
    )
    loop
        --Lay TXNUM
        SELECT    '8000' || SUBSTR ('000000' || seq_batchtxnum.NEXTVAL,
                          LENGTH ('000000' || seq_batchtxnum.NEXTVAL) - 5,6)
          INTO l_txnum FROM DUAL;
        --Thu hoi lai han muc con lai
        INSERT INTO aftran (acctno, txnum,txdate, txcd, namt, camt, REF,deltd, autoid)
            VALUES (rec.acctno, l_txnum,l_currdate, '0022', greatest(rec.advanceline,0), '', '','N', seq_aftran.NEXTVAL);
        --BMSC khong cap lai han muc cho TK tu doanh, user se cap bang tay
        /*--Cap han muc moi
        INSERT INTO aftran (acctno, txnum,txdate, txcd, namt, camt, REF,deltd, autoid)
            VALUES (rec.acctno, l_txnum,l_currdate, '0062', greatest(rec.initadvanceline,0), '', '','N', seq_aftran.NEXTVAL);
            */

        update afmast
        set advanceline = rec.initadvanceline
        --set advanceline = 0
        where acctno = rec.acctno;
    end loop;
    plog.setendsection(pkgctx, 'fn_ReleaseAdvanceLine');
    return systemnums.C_SUCCESS;
EXCEPTION
WHEN OTHERS
THEN
  plog.error (pkgctx, SQLERRM);
  plog.setendsection (pkgctx, 'fn_ReleaseAdvanceLine');
  RAISE errnums.E_SYSTEM_ERROR;
  return errnums.C_SYSTEM_ERROR;
END fn_ReleaseAdvanceLine;

FUNCTION fn_getMrRate(p_afacctno in varchar2, p_codeid in varchar2)
RETURN number
IS
l_result number;
BEGIN
    plog.setendsection(pkgctx, 'fn_getMrRate');
    select mrratioloan into l_result
    from afmast af, afserisk rsk
    where af.actype = rsk.actype and af.acctno = p_afacctno and rsk.codeid = p_codeid;
    plog.setendsection(pkgctx, 'fn_getMrRate');
    return l_result;
EXCEPTION
WHEN OTHERS
THEN
  plog.error (pkgctx, SQLERRM);
  plog.setendsection (pkgctx, 'fn_getMrRate');
  return 0;
END fn_getMrRate;

FUNCTION fn_getMrPrice(p_afacctno in varchar2, p_codeid in varchar2)
RETURN number
IS
l_result number;
BEGIN
    plog.setendsection(pkgctx, 'fn_getMrPrice');

    select greatest(least(se.marginprice, mrpriceloan),0) into l_result
    from afmast af, afserisk rsk, securities_info se
    where af.actype = rsk.actype and af.acctno = p_afacctno and rsk.codeid = p_codeid
    and rsk.codeid = se.codeid;

    plog.setendsection(pkgctx, 'fn_getMrPrice');
    return l_result;
EXCEPTION
WHEN OTHERS
THEN
  plog.error (pkgctx, SQLERRM);
  plog.setendsection (pkgctx, 'fn_getMrPrice');
  return 0;
END fn_getMrPrice;

-- initial LOG
BEGIN
   SELECT *
   INTO logrow
   FROM tlogdebug
   WHERE ROWNUM <= 1;

   pkgctx    :=
      plog.init ('cspks_mrproc',
                 plevel => logrow.loglevel,
                 plogtable => (logrow.log4table = 'Y'),
                 palert => (logrow.log4alert = 'Y'),
                 ptrace => (logrow.log4trace = 'Y')
      );
END;
/
