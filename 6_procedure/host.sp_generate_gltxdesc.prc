SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SP_GENERATE_GLTXDESC" (
  pv_tltxcd in VARCHAR,
  pv_txnum in VARCHAR,
  v_txdate in VARCHAR,
  pv_txdesc in VARCHAR,
  pv_txdescnew out VARCHAR) IS
  v_code  NUMBER;
  v_errm  VARCHAR2(64);
  pv_errmsg varchar(250);
    v_date date;
    l_id number;
    l_count number;
    l_txdesc varchar(3000);
    l_result varchar(3000);
    l_txtarget varchar(5);
    l_txvalue varchar(1000);
BEGIN
    --Replace cac thong tin trong txdesc bang cac gia tri trong TLLOGFLD va tra ve txdesc moi.
    v_date:= TO_DATE(v_txdate,'DD/MM/RRRR');
    l_txdesc := pv_txdesc;
    l_result := pv_txdesc;
    l_count := Length(l_txdesc) - 1;
    For l_id in  0 .. l_count loop
            If substr(l_txdesc,l_id+1,1) = '#' Then
                l_txtarget := substr(l_txdesc, l_id+2,2);
                SELECT NVL(CVALUE,TO_CHAR(NVALUE)) INTO l_txvalue
                FROM (SELECT * FROM TLLOGFLD WHERE TXDATE = TO_DATE(v_txdate,'DD/MM/RRRR') AND TXNUM = pv_txnum
                      UNION ALL
                      SELECT * FROM tllogfldall WHERE TXDATE = TO_DATE(v_txdate,'DD/MM/RRRR') AND TXNUM = pv_txnum) TLA
                WHERE TLA.FLDCD = l_txtarget;
                l_result := replace(l_result, substr(l_txdesc, l_id+1,3),l_txvalue);
            End If;
            If substr(l_txdesc,l_id+1,1) = '$' Then
                l_txtarget := substr(l_txdesc, l_id+2,2);
                SELECT NVL(CVALUE,TO_CHAR(NVALUE)) INTO l_txvalue
                FROM (SELECT * FROM TLLOGFLD WHERE TXDATE = TO_DATE(v_txdate,'DD/MM/RRRR') AND TXNUM = pv_txnum
                      UNION ALL
                      SELECT * FROM tllogfldall WHERE TXDATE = TO_DATE(v_txdate,'DD/MM/RRRR') AND TXNUM = pv_txnum) TLA
                WHERE TLA.FLDCD = l_txtarget;
                if pv_tltxcd = '2685' then
                   if l_txtarget = '01' then
                      select symbol into l_txvalue from sbsecurities where codeid=trim(l_txvalue);
                   end if;
                   if l_txtarget = '04' then
                      select b.rate3 into l_txvalue from dftype a, lntype b where a.lntype = b.actype and a.actype =trim(l_txvalue);
                   end if;
                end if;
                l_result := replace(l_result, substr(l_txdesc, l_id+1,3),l_txvalue);
            End If;
    end loop;
    pv_txdescnew := l_result;

EXCEPTION
  WHEN OTHERS THEN
    v_code := SQLCODE;
    v_errm := SUBSTR(SQLERRM, 1, 64);
    INSERT INTO errors (code, message, logdetail, happened) VALUES (v_code, v_errm, 'SP_GENERATE_GLTXDESC:' || v_txdate, SYSTIMESTAMP);
END;

 
 
 
 
/
