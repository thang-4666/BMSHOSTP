SET DEFINE OFF;DELETE FROM ALLCODE WHERE 1 = 1 AND NVL(CDNAME,'NULL') = NVL('CUSTTYPE','NULL') AND NVL(CDTYPE,'NULL') = NVL('SA','NULL');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'CUSTTYPE', 'R', 'Dự trữ', 0, 'Y', 'Reserved', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'CUSTTYPE', 'N', 'Thông thường', 1, 'Y', 'Normal', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'CUSTTYPE', 'F', 'Cty QL quỹ', 2, 'Y', 'Fund company', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'CUSTTYPE', 'P', 'Tự doanh', 3, 'Y', 'Prop. trade', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'CUSTTYPE', 'O', 'CTCK khác', 4, 'Y', 'Other securities company', 'C');Insert into ALLCODE   (CDTYPE, CDNAME, CDVAL, CDCONTENT, LSTODR, CDUSER, EN_CDCONTENT, CHSTATUS) Values   ('SA', 'CUSTTYPE', 'B', 'Ngân hàng lưu ký', 4, 'Y', 'Custodian bank', 'C');COMMIT;