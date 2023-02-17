SET DEFINE OFF;DELETE FROM CMDMENU WHERE 1 = 1 AND NVL(PRID,'NULL') = NVL('032000','NULL');Insert into CMDMENU   (CMDID, PRID, LEV, LAST, MENUTYPE, MENUCODE, MODCODE, OBJNAME, CMDNAME, EN_CMDNAME, AUTHCODE, TLTXCD) Values   ('032001', '032000', 4, 'Y', 'O', 'CF0001  ', 'CF', 'AFTYPE', 'Tiểu khoản giao dịch (AF)', 'Sub-account', 'YYYYYYYNNYY', '');Insert into CMDMENU   (CMDID, PRID, LEV, LAST, MENUTYPE, MENUCODE, MODCODE, OBJNAME, CMDNAME, EN_CMDNAME, AUTHCODE, TLTXCD) Values   ('032002', '032000', 4, 'Y', 'O', 'CI0001  ', 'CI', 'CITYPE', 'Tiền giao dịch (CI)', 'Current account', 'YYYYYYYNNYY', '');Insert into CMDMENU   (CMDID, PRID, LEV, LAST, MENUTYPE, MENUCODE, MODCODE, OBJNAME, CMDNAME, EN_CMDNAME, AUTHCODE, TLTXCD) Values   ('032004', '032000', 4, 'Y', 'O', 'OD0001  ', 'OD', 'ODTYPE', 'Lệnh (OD)', 'Orders', 'YYYYYYYNNYY', '');Insert into CMDMENU   (CMDID, PRID, LEV, LAST, MENUTYPE, MENUCODE, MODCODE, OBJNAME, CMDNAME, EN_CMDNAME, AUTHCODE, TLTXCD) Values   ('032005', '032000', 4, 'Y', 'O', 'MR0001', 'MR', 'MRTYPE', 'Giao dịch ký quỹ (MR)', 'Margin', 'YYYYYYYNNYY', '');Insert into CMDMENU   (CMDID, PRID, LEV, LAST, MENUTYPE, MENUCODE, MODCODE, OBJNAME, CMDNAME, EN_CMDNAME, AUTHCODE, TLTXCD) Values   ('032007', '032000', 4, 'Y', 'O', 'LN0001  ', 'LN', 'LNTYPE', 'Tín dụng (LN)', 'Loan', 'YYYYYYYNNYY', '');Insert into CMDMENU   (CMDID, PRID, LEV, LAST, MENUTYPE, MENUCODE, MODCODE, OBJNAME, CMDNAME, EN_CMDNAME, AUTHCODE, TLTXCD) Values   ('032008', '032000', 4, 'Y', 'O', 'DF0001', 'DF', 'DFTYPE', 'Cầm cố (DF)', 'Mortgage', 'YYYYYYYNNYY', '');Insert into CMDMENU   (CMDID, PRID, LEV, LAST, MENUTYPE, MENUCODE, MODCODE, OBJNAME, CMDNAME, EN_CMDNAME, AUTHCODE, TLTXCD) Values   ('032017', '032000', 4, 'Y', 'O', 'RE0001', 'RE', 'RETYPE', 'Đại lý/môi giới (RE)', 'Remiser/Broker', 'YYYYYYYNNYY', '');Insert into CMDMENU   (CMDID, PRID, LEV, LAST, MENUTYPE, MENUCODE, MODCODE, OBJNAME, CMDNAME, EN_CMDNAME, AUTHCODE, TLTXCD) Values   ('032018', '032000', 4, 'Y', 'O', 'AD0001', 'CF', 'ADTYPE', 'Ứng trước (AD)', 'Advanced payment', 'YYYYYYYNNYY', '');Insert into CMDMENU   (CMDID, PRID, LEV, LAST, MENUTYPE, MENUCODE, MODCODE, OBJNAME, CMDNAME, EN_CMDNAME, AUTHCODE, TLTXCD) Values   ('032019', '032000', 4, 'Y', 'O', 'IRRATE', 'SA', 'IRRATE', 'Lịch lãi cài đặt trước', 'Management calendar interest presets', 'YYYYYYYYYYY', '');Insert into CMDMENU   (CMDID, PRID, LEV, LAST, MENUTYPE, MENUCODE, MODCODE, OBJNAME, CMDNAME, EN_CMDNAME, AUTHCODE, TLTXCD) Values   ('032020', '032000', 4, 'Y', 'O', 'CFTYPE', 'CF', 'CFTYPE', 'Khách Hàng (CF)', 'Management Customer Product ', 'YYYYYYYNNYY', '');COMMIT;