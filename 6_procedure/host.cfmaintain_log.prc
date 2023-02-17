SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CFMAINTAIN_LOG" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2
 )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE       COMMENTS
-- Diennt      13/10/2011 Create
-- ---------   ------     -------------------------------------------
   V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
       -- USED WHEN V_NUMOPTION > 0
   V_INBRID         VARCHAR2(4);
   V_STRBRID        VARCHAR2 (50);
   V_STRTLID        VARCHAR2(6);
   v_strCUSTODYCD   VARCHAR2(10);
   V_F_DATE         DATE;
   V_T_DATE         DATE;

-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE


BEGIN
    if (PV_CUSTODYCD is null or upper(PV_CUSTODYCD) = 'ALL') then
        v_strCUSTODYCD := '%';
    else
        v_strCUSTODYCD := PV_CUSTODYCD;
    end if;

    V_F_DATE := TO_DATE(F_DATE,'DD/MM/RRRR');
    V_T_DATE  := TO_DATE(T_DATE,'DD/MM/RRRR');

OPEN PV_REFCURSOR
  FOR
    select cf.custodycd, cf.custid, tl.maker_dt, tl.maker_time,
        (
            case when tl.column_name = 'DATEOFBIRTH' then 'Ngày sinh'
                 when tl.column_name = 'ADDRESS' then 'Địa chỉ nhà riêng'
                 when tl.column_name = 'EMAIL' then 'Thư điện tử'
                 when tl.column_name = 'MOBILESMS' then 'Số điện thoại SMS'
                 when tl.column_name = 'SEX' then 'Giới tính'
                 else 'Khác'
            end
        ) column_name,
        (case when tl.column_name = 'SEX' then (case when tl.from_value = '001' then 'Nam' else 'Nữ' end)
              else tl.from_value end) from_value,
        (case when tl.column_name = 'SEX' then (case when tl.from_value = '001' then 'Nam' else 'Nữ' end)
              else tl.to_value end) to_value
    from cfmast cf, maintain_log tl
    where tl.table_name ='CFMAST'
        and tl.column_name in ('ADDRESS','MOBILESMS','DATEOFBIRTH','EMAIL','SEX')
        AND tl.action_flag = 'EDIT'
        and cf.custid=substr(trim(TL.record_key),11,10)
        AND CF.custodycd LIKE v_strCUSTODYCD
        AND TL.MAKER_DT >= V_F_DATE AND TL.MAKER_DT <= V_T_DATE
    order by tl.maker_dt DESC, tl.maker_time DESC
;

EXCEPTION
   WHEN OTHERS
   THEN

      RETURN;
End;

 
 
 
 
/
