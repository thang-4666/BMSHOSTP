SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE pr_re_commision
IS
    v_currdate date;
      v_nextdate date;
      v_lastday number(20);-- Ngay lam viec cuoi cung cua thang
      v_BMdays number(20);-- So ngay hoat dong cua moi gioi
      V_commdays number(20);  -- So ngay cua ky tinh hoa hong
      v_lastcustid varchar2(20);
      v_disacr number(20,4);  -- Dinh muc cua moi gio, bi tru dan sau khi phan bo cho tai khoan moi gioi
      v_disdirectacr number(20,4);-- Phan dc tinh hoa hong cua tk moi gioi (= Doanh so - Dinh muc)
      v_revenue number(20,4); -- Doanh thu cua tai khoan mg
      v_commision number(20,4);-- Hoa Hong cua tk moi gio
      v_mindrevamtreal number(20,4);-- Dinh muc truc tiep thuc te = Dinh muc truc tiep * So ngay MG hoat dong / So ngay cua thang
      v_minirevamtreal number(20,4);-- Dinh muc gian tiep thuc te = Dinh muc gian tiep * So ngay MG hoat dong / So ngay cua thang
      v_rffeeacr number(20,4);   -- Phi giam tru theo doanh thu phan bo
      v_rfmatchamt number(20,4);  -- phi giam tru theo doanh so phan bo
      v_groupcommision number(20,4); -- Hoa hong cua nhom
      v_memcommision number(20,4); -- Hoa hong cua truong nhom phu
      v_reacctno varchar2(14); --tai khoan moi gioi
      pkgctx plog.log_ctx;
      l_txmsg               tx.msg_rectype;
      v_strCURRDATE varchar2(20);
      v_strDesc varchar2(1000);
      v_strEN_Desc varchar2(1000);
      v_strOrgDesc varchar2(1000);
      v_strEN_OrgDesc varchar2(1000);
      l_err_param varchar2(300);
      v_perioddate date;
      v_autoid number;
  BEGIN
    SELECT TO_DATE (varvalue, systemnums.c_date_format) INTO v_currdate
    FROM sysvar WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';

    SELECT TO_DATE (varvalue, systemnums.c_date_format) INTO v_nextdate
    FROM sysvar WHERE grname = 'SYSTEM' AND varname = 'NEXTDATE';
   --Xac dinh ngay cuoi cung cua thang
   --- select to_number(to_char(max(sbdate),'DD')) into v_lastday from sbcldr where  to_char(sbdate,'MM/YYYY')= to_char(v_CURRDATE,'MM/YYYY') and cldrtype ='000';
    v_lastday := to_number(to_char(v_currdate,'DD'));
    -- Tinh Hoa Hong Truc Tiep
    For vc in
        (
            select rcl.autoid, rm.acctno, -- tk moi gioi
                Case when rty.rerole in ('RM','BM') then rcd.isdrev else 'N'
                    end isdrev, -- Co chiu luat dinh muc hay khong
                RCL.effdate,  RCL.mindrevamt, -- dinh muc doanh thu truc tiep
                nvl(rlog.rate,0) revrate, -- ty le dieu chinh dinh muc
                rm.directfeeacr,-- Doanh thu truc tiep
                rm.rffeeacr, -- Giam tru doanh thu
                rm.rfmatchamt, -- Giam tru doanh so
                icd.perioddate
            from recflnk rcl, recfdef rcd, retype rty, remast rm,
                (select * from rerevlog where status='A' and gor='R'  )  rlog,
                (SELECT actype, period, periodday,
                    to_date((case when periodday > to_number(to_char((getcurrdate),'DD')) or periodday<1
                    then to_number(to_char((getcurrdate),'DD')) else periodday end)  || '/' || to_char(getcurrdate,'MM/RRRR'), 'DD/MM/RRRR') perioddate
                FROM iccftypedef ic
                WHERE ic.EVENTCODE='CALFEECOMM'
                ) ICD
            where rcd.refrecflnkid=rcl.autoid
                and rcd.reactype=rty.actype
                and rty.retype='D'
                and rcl.custid=rm.custid
                and rcd.reactype=rm.actype
                and rty.actype= icd.actype
                and rcl.autoid = rlog.autoid(+)
                AND rcl.status = 'A' AND rm.status = 'A'
            order by rcl.custid, rcd.odrnum
        )
    Loop
        V_commdays := vc.perioddate - ADD_MONTHS(vc.perioddate,-1);
        v_BMdays := vc.perioddate - greatest(vc.effdate,ADD_MONTHS(vc.perioddate,-1)+1 ) +1 ;
        v_disacr := vc.mindrevamt * ((1 + vc.revrate/100) * v_BMdays / V_commdays);
        v_mindrevamtreal := v_disacr;
        If  vc.isdrev ='Y' then
            IF vc.directfeeacr >= v_mindrevamtreal THEN
                v_disdirectacr := vc.directfeeacr - vc.rffeeacr - vc.rfmatchamt;
            ELSE
                v_disdirectacr := 0;
            END IF;
        ELSE
            v_disdirectacr := vc.directfeeacr - vc.rffeeacr - vc.rfmatchamt;
        End if;
        v_revenue := v_disdirectacr;
        v_commision := fn_re_getcommision(vc.acctno,v_disdirectacr,v_revenue);
        update remast set recommision = v_commision
        where acctno = vc.acctno;
    end loop;
    -- end Tinh Hoa Hong Truc Tiep

    -- Tinh Hoa Hong Gian Tiep
    For VC in
        (
            select                 rcl.autoid,
                       rcl.custid,
                       rcl.mindrevamt, --dInh muc doanh so truc tiep
                       RCL.effdate ,
                       rcl.minirevamt,
                       rcl.minincome , -- luong toi thieu
                       rcl.minratesal, -- ti le huong luong toi thieu khi ko hoan thanh dinh muc
                       rcl.saltype,    -- Kieu tinh luong toi thieu
                       rcl.actype,
                       'Y' isdrev, -- Co chiu luat dinh muc hay khong
                        0 odrnum ,-- thu tu phan bo dinh muc
                       rm.acctno, -- tk moi gioi
                       rm.directacr, -- Doanh so truc tiep
                       rm.directfeeacr,-- Doanh thu truc tiep
                       rm.indirectacr,-- Doanh so gian tiep
                       rm.indirectfeeacr,-- Doanh thu gian tiep
                       rm.odfeetype, -- Cach tinh dua tren phi thuc thu hay phi co dinh M/F
                       rm.odfeerate, -- ti le phi co dinh
                       rm.inrfmatchamt, -- Giam tru doanh so
                       rm.inrffeeacr, -- Giam tru doanh thu
                       rm.inlmn, -- Gia tri phat vay bao lanh
                       rm.indisposal, -- Gia tri lenh giai chap
                       nvl(rlog.rate,0) revrate, -- ty le dieu chinh dinh muc
                       icd.period,
                       icd.periodday,
                       icd.perioddate
                from regrp rcl,  retype rty, remast rm,
                 (select * from rerevlog where status='A' and gor='G'  ) rlog,
                (SELECT actype,period, periodday,
                        to_date((case when periodday>v_lastday or periodday<1 then v_lastday else periodday end)
                        || '/' || to_char(v_CURRDATE,'MM/RRRR'), 'DD/MM/RRRR') perioddate
                FROM iccftypedef ic
                WHERE ic.EVENTCODE='CALFEECOMM' ) ICD
                where rcl.custid=rm.custid
                and rcl.actype=rm.actype
                and rcl.actype=rty.actype
                and rty.retype='I'
                and rty.actype=icd.actype
                and rcl.autoid=rlog.autoid(+)
                AND rm.status = 'A'
                order by rcl.autoid, rcl.custid
        )
    Loop
        V_commdays:=vc.perioddate - ADD_MONTHS(vc.perioddate,-1);
        v_BMdays:=vc.perioddate - greatest(vc.effdate,ADD_MONTHS(vc.perioddate,-1)+1 ) +1 ;

        v_disacr :=vc.minirevamt * (1 + vc.revrate/100) * v_BMdays / V_commdays;
        v_minirevamtreal:=v_disacr;

        IF vc.indirectfeeacr >= v_minirevamtreal THEN
            v_disdirectacr:=vc.indirectfeeacr-vc.inrffeeacr-vc.inrfmatchamt;
        ELSE
            v_disdirectacr:=0;
        END IF;

        --v_revenue:= v_disdirectacr * vc.odfeerate/100;
        v_revenue:= v_disdirectacr; --lay truc tiep tu doanh thu
        v_rfmatchamt:=0;
        v_rffeeacr:=0;
        v_commision:=fn_re_getcommision(vc.acctno,v_disdirectacr,v_revenue);
        v_groupcommision := v_commision;
        -- Phan bo hoa hong cho cac truong nhom phu
        For rec in (
                    Select r.custid, r.rate, r.minincome
                    From regrpleaders R
                    Where r.status = 'A'
                      and r.grpid = vc.autoid
                )
        Loop
            v_reacctno := rec.custid||vc.actype; -- Tai khoan moi gioi cua truong nhom phu
            v_memcommision := v_groupcommision * rec.rate /100;
            update remast set recommision = v_memcommision
            where acctno = v_reacctno;
            v_commision:= v_commision - v_memcommision;
        End loop;
         -- Hoa hong con lai cua truong nhom chinh
         update remast set recommision = v_commision
            where acctno = vc.acctno;
     End Loop;
     -- end TINH HOA HONG GIAN TIEP


EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    plog.error (pkgctx, dbms_utility.format_error_backtrace);
END;

 
 
 
 
 
 
 
 
 
 
/
