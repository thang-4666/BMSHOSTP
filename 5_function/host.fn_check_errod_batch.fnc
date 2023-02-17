SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_check_errod_batch
return number
is
    v_count number;
    v_prevDate date;
    v_nextDate Date;
begin
  SELECT TO_DATE(VARVALUE,'DD/MM/YYYY') into  v_prevDate FROM SYSVAR WHERE GRNAME = 'SYSTEM' AND VARNAME ='PREVDATE';
  SELECT TO_DATE(VARVALUE,'DD/MM/YYYY') into  v_nextDate FROM SYSVAR WHERE GRNAME = 'SYSTEM' AND VARNAME ='NEXTDATE';
  -- da lam 8841 thi phai thuc hien 8846
  select count(*) into v_count from odmast o where o.errod ='Y' and o.execqtty > 0;
  if( v_count >0) then
    return -1;
  end if;
  -- da lam 8848 thi phai hoan tat thanh 8849
  select count(*) into v_count from odmast o where nvl(o.errsts,'N') ='G';
  if( v_count >0) then
    return -2;
  end if;
  -- nhung lenh
 /*  select count (od.orderid) into v_count from odmast od, stschd st
   where od.orderid = st.orgorderid and st.duetype in ('RS','RM') and st.status <>'C'  and st.cleardate <= v_nextDate and nvl(od.errsts,'N') not in ('N','D','C') and od.txdate >= v_prevDate ;
    if( v_count >0) then
    return -3;
  end if;*/
  return 1;
exception when others then
    return -1;
end;
/
