SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE gl0041 (
   PV_REFCURSOR           IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE         IN       VARCHAR2
  )
IS
--
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
-- BAO CAO CHI TIEU NGOAI BANG
-- MODIFICATION HISTORY
-- PERSON      DATE         COMMENTS
-- ANTB      15/03/2014     CREATED
-- ---------   ------       -------------------------------------------
--
   CUR            PKG_REPORT.REF_CURSOR;
   V_STROPT       VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID      VARCHAR2 (100);                   -- USED WHEN V_NUMOPTION > 0
   V_INBRID       VARCHAR2 (5);
   v_strIBRID     VARCHAR2 (4);
   vn_BRID        varchar2(50);
   vn_TRADEPLACE varchar2(50);
   v_strTRADEPLACE VARCHAR2 (4);
   v_OnDate date;
   v_CurrDate date;
   v_strsqlcmd varchar2(4000);
   v_COMPANYCD varchar2(5);
   v_wkdate varchar2(15);

BEGIN

/*IF V_STROPTION = 'A' THEN
    V_STRBRID := '%';
ELSIF V_STROPTION = 'B' then
    V_STRBRID := BRID;
else
    V_STRBRID := BRID;
END IF;*/
    V_STROPT := upper(OPT);
    V_INBRID := BRID;



    v_OnDate:= to_date(I_DATE,'DD/MM/RRRR');

    select varvalue into v_COMPANYCD from sysvar where varname='COMPANYCD' and grname='SYSTEM';

    select  max(to_char(sbdate,'DD/MM/RRRR')) into v_wkdate  from sbcurrdate where sbtype='B' and sbdate<= v_OnDate;

    delete from mis_item_results where groupid='GL0041' and busdate = v_OnDate;
    commit;

    For rec in(
       select * from mis_items where groupid = 'GL0041' order by serial
       )
       Loop
           v_strsqlcmd:= replace(upper(rec.sqlcmd),'<@BUSDATE>',I_DATE);
           v_strsqlcmd:= replace(upper(v_strsqlcmd),'<@COMPANYCD>',v_COMPANYCD);
           v_strsqlcmd:= replace(upper(v_strsqlcmd),'<@WKDATE>',v_WKDATE);

           if length(v_strsqlcmd) > 0 then
              Begin
                Execute immediate v_strsqlcmd;
                commit;
                EXCEPTION
              WHEN OTHERS
               THEN
               --dbms_output.put_line('GL0041 ERROR');
               plog.error(substr('GL0041: - SQL1: ' ||v_strsqlcmd, 1, 2000) );
                plog.error(substr('GL0041: - SQL2: ' ||v_strsqlcmd, 2001, 4000) );
               plog.error('GL0041: - ITEMCD: '|| rec.ITEMCD || ' - SQL: ' ||dbms_utility.format_error_backtrace);
              end;
           end if;
       End Loop;

    -- A. 8. Tai san tai chinh niem yet/dang ky giao dich tai VSD cua CTCK
    update mis_item_results
    set itemvalue = (select sum(to_number(r.itemvalue))
                        from mis_item_results r
                        where r.groupid='GL0041' and r.itemcd in ('A008A','A008B','A008C','A008D','A008E','A008F','A008G') and r.busdate = v_ondate
                    )
    where groupid='GL0041' and itemcd = 'A008';
    -- A. 9. Tai san tai chinh da luu ky tai VSD va chua giao dich CTCK
    update mis_item_results
    set itemvalue = (select sum(to_number(r.itemvalue))
                        from mis_item_results r
                        where r.groupid='GL0041' and r.itemcd in ('A009A','A009B','A009C','A009D') and r.busdate = v_ondate
                    )
    where groupid='GL0041' and itemcd = 'A009';
    -- B. 1. Tai san tai chinh niem yet/dang ky giao dich tai VSD cua Nha dau tu
    update mis_item_results
    set itemvalue = (select sum(to_number(r.itemvalue))
                        from mis_item_results r
                        where r.groupid='GL0041' and r.itemcd in ('B001A','B001B','B001C','B001D','B001E','B001F','B001G') and r.busdate = v_ondate
                    )
    where groupid='GL0041' and itemcd = 'B001';
    -- B. 2. Tai san tai chinh da luu ky tai VSD va chua giao dich Nha dau tu
    update mis_item_results
    set itemvalue = (select sum(to_number(r.itemvalue))
                        from mis_item_results r
                        where r.groupid='GL0041' and r.itemcd in ('B002A','B002B','B002C','B002D') and r.busdate = v_ondate
                    )
    where groupid='GL0041' and itemcd = 'B002';
    -- B. 6.1. Tien gui ve hoat dong luu ky CK
    update mis_item_results
    set itemvalue = (select sum(to_number(r.itemvalue))
                        from mis_item_results r
                        where r.groupid='GL0041' and r.itemcd in ('B0061A','B0061B') and r.busdate = v_ondate
                    )
    where groupid='GL0041' and itemcd = 'B0061';
    -- B. 6.3. Tien gui bu tru va thanh toan giao dich CK
    update mis_item_results
    set itemvalue = (select sum(to_number(r.itemvalue))
                        from mis_item_results r
                        where r.groupid='GL0041' and r.itemcd in ('B0063A','B0063B') and r.busdate = v_ondate
                    )
    where groupid='GL0041' and itemcd = 'B0063';
    -- B. 6. Tien gui cua khach hang
    update mis_item_results
    set itemvalue = (select sum(to_number(r.itemvalue))
                        from mis_item_results r
                        where r.groupid='GL0041' and r.itemcd in ('B0061','B0062','B0063','B0064') and r.busdate = v_ondate
                    )
    where groupid='GL0041' and itemcd = 'B006';
    -- B. 7. Phai tra Nha dau tu ve tien gui giao dich CK theo phuong thuc CTCK quan ly
    update mis_item_results
    set itemvalue = (select sum(to_number(r.itemvalue))
                        from mis_item_results r
                        where r.groupid='GL0041' and r.itemcd in ('B0071','B0072') and r.busdate = v_ondate
                    )
    where groupid='GL0041' and itemcd = 'B007';
    -- B. 8. Phai tra Nha dau tu ve tien gui giao dich CK theo phuong thuc Ngan hang thuong mai quan ly
    update mis_item_results
    set itemvalue = (select sum(to_number(r.itemvalue))
                        from mis_item_results r
                        where r.groupid='GL0041' and r.itemcd in ('B0081','B0082') and r.busdate = v_ondate
                    )
    where groupid='GL0041' and itemcd = 'B008';
-- Main report
OPEN PV_REFCURSOR FOR
    SELECT serial, item.itemcd, item.itemname, results.itemvalue, item.amttype, item.fonttype, results.busdate, item.shortname
    FROM mis_item_results results, mis_items item
    where results.groupid = item.groupid
        and results.itemcd = item.shortname
        and item.groupid = 'GL0041'
        --and length(results.itemcd) = 3
        and results.busdate = v_OnDate
    order by serial
;

EXCEPTION
  WHEN OTHERS
   THEN
   dbms_output.put_line('GL0041 ERROR');
   plog.error('GL0041: - ' ||dbms_utility.format_error_backtrace);
      RETURN;
END;
 
 
 
/
