SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "PRC_MAP_TRADEBOOK"
   IS
   V_COUNT NUMBER(10);
   V_SQL varchar2(500);
BEGIN
         dbms_output.put_line(' start '||to_char(sysdate,'hh24:mi:ss'));
         --Dua cac lenh moi vao bang ket qua khop lenh tam thoi.
         delete Stctradebooktemp;
        Insert Into Stctradebooktemp(Txdate, Confirmnumber, Refconfirmnumber, Ordernumber,
                bors, volume, price)
        Select
            Txdate, Confirmnumber, Refconfirmnumber,
             Case
                    When  Refconfirmnumber Like 'VS%' Then  '00'||Trim(Ordernumber)
                    Else Ordernumber
                END Ordernumber,
             Bors, Volume, Price
        FROM STCTRADEBOOKBUFFER S WHERE  NOT EXISTS
                (SELECT REFCONFIRMNUMBER FROM STCTRADEBOOK WHERE REFCONFIRMNUMBER =S.REFCONFIRMNUMBER);


        --Cap nhat STCTRADEBOOK cho nhung lenh da duoc map (o bang STCORDERBOOK)
        INSERT INTO STCTRADEBOOK
                SELECT * FROM STCTRADEBOOKTEMP WHERE SUBSTR(REFCONFIRMNUMBER,1,2) || ORDERNUMBER IN
                (SELECT SUBSTR(REFORDERNUMBER,1,2) || ORDERNUMBER FROM STCORDERBOOK);
        /*INSERT INTO STCTRADEBOOK
                SELECT * FROM STCTRADEBOOKTEMP WHERE REFCONFIRMNUMBER like 'VN%' and
                SUBSTR(REFCONFIRMNUMBER,1,2) || ORDERNUMBER IN
                (SELECT SUBSTR(REFORDERNUMBER,1,2) || ORDERNUMBER FROM STCORDERBOOK);

        INSERT INTO STCTRADEBOOK
                SELECT * FROM STCTRADEBOOKTEMP  WHERE REFCONFIRMNUMBER like 'VS%' and
                  Substr(Refconfirmnumber,1,2) || '00'||Trim(Ordernumber) In
                (SELECT SUBSTR(REFORDERNUMBER,1,2) || ORDERNUMBER FROM STCORDERBOOK);*/


        --Xoa nhung DEAL trong STCTRADEBOOKTEMP ma co ban ghi trong STCTRADEBOOK
        DELETE FROM STCTRADEBOOKTEMP S WHERE EXISTS
                (SELECT REFCONFIRMNUMBER FROM STCTRADEBOOK WHERE REFCONFIRMNUMBER=S.REFCONFIRMNUMBER);


        --Xoa di nhung DEAL khop lenh trong STCTRADEBOOKEXP ma khong xuat hien trong STCTRADEBOOKTEMP
        DELETE FROM STCTRADEBOOKEXP S WHERE  NOT EXISTS
                (SELECT REFCONFIRMNUMBER FROM STCTRADEBOOKTEMP WHERE REFCONFIRMNUMBER =S.REFCONFIRMNUMBER);

        --Day vao trong STCORDERBOOKEXP nhung lenh exception moi
        INSERT INTO STCTRADEBOOKEXP SELECT * FROM STCTRADEBOOKTEMP S WHERE  NOT EXISTS
                (SELECT REFCONFIRMNUMBER FROM STCTRADEBOOKEXP WHERE REFCONFIRMNUMBER=S.REFCONFIRMNUMBER);

        dbms_output.put_line(' finnish '||to_char(sysdate,'hh24:mi:ss'));
   EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
END;

 
 
 
 
/
