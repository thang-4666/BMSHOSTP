SET DEFINE OFF;
CREATE OR REPLACE PACKAGE UTF8NUMS
    is
    -- Save with PL/SQL Developer and Run on PL/SQL Developer
    c_const_AccountInfo_binhthuong constant varchar2(30):= 'Bình thường';
    c_const_AccountInfo_call constant varchar2(30):= 'CALL';
    c_const_AccountInfo_xuly constant varchar2(30):= 'Xử lý';
    c_const_AccountInfo_canhbao constant varchar2(30):= 'Cảnh báo';
    c_const_AccountInfo_phongtoa constant varchar2(30):= 'Phong tỏa';
    c_const_AccountInfo_ptbl constant varchar2(50):= 'Phong tỏa bảo lãnh';

    c_const_custtype_custodycd_bf constant varchar2(30):= 'Tổ chức nước ngoài';
    C_CONST_MONTH_VI CONSTANT VARCHAR2(20):= 'tháng';
    C_CONST_DATE_VI CONSTANT VARCHAR2(20):= 'ngày';
    C_CONST_YEAR_VI CONSTANT VARCHAR2(20):= 'năm';
    c_const_custtype_custodycd_ic constant varchar2(30):= 'Cá nhân trong nước';
    c_const_custtype_custodycd_bc constant varchar2(30):= 'Tổ chức trong nước';
    c_const_custtype_custodycd_if constant varchar2(30):= 'Cá nhân nước ngoài';

    c_const_custodycd_type_c constant varchar2(30):= 'Trong nước';
    c_const_custodycd_type_f constant varchar2(30):= 'Nước ngoài';
    c_const_custodycd_type_p constant varchar2(30):= 'Tự doanh';
    c_const_potxnum constant varchar2(30):= 'Bảng kê số';

    c_const_desc_8851 constant varchar2(70):= 'Hoàn trả ứng trước tiền bán chứng khoán';
    c_const_desc_8851_oddate constant varchar2(30):= 'Ngày ứng trước';
    c_const_desc_8851_txdate constant varchar2(30):= 'Ngày GD';

    c_const_ca0030_custodytype_1 constant varchar2(100) := 'I. MÔI GIỚI TRONG NƯỚC';
    c_const_ca0030_custodytype_2 constant varchar2(100) := 'II. MÔI GIỚI NƯỚC NGOÀI';
    c_const_ca0030_custodytype_3 constant varchar2(100) := 'III. TỰ DOANH';
    c_const_ca0030_custtype_1 constant varchar2(100) := '1. Cá nhân';
    c_const_ca0030_custtype_2 constant varchar2(100) := '2. Tổ chức';
    c_const_ca0030_name_allbranch constant varchar2(100) := 'Toàn công ty';
    c_const_ca0030_name_cb_COM constant varchar2(100) := 'Tại cty CK';
    c_const_df_marketname constant varchar2(100) := 'Trái phiếu chuyên biệt';

    c_const_ca_rightname_a constant varchar2(100) := 'A. QUYỀN NHẬN CỔ TỨC BẰNG CỔ PHIẾU';
    c_const_ca_rightname_b constant varchar2(100) := 'B. QUYỀN CỔ PHIẾU THƯỞNG';
    c_const_ca_rightname_c constant varchar2(100) := 'C. QUYỀN NHẬN CỔ TỨC BẰNG TIỀN';
    c_const_ca_rightname_d constant varchar2(100) := 'D. QUYỀN MUA';
    c_const_ca_rightname_e constant varchar2(100) := 'E. QUYỀN HOÁN ĐỔI CỔ PHIẾU';
    c_const_ca_rightname_f constant varchar2(100) := 'F. QUYỀN CHUYỂN ĐỔI TRÁI PHIẾU' ;
    c_const_ca_rightname_g constant varchar2(100) := 'G. QUYỀN BIỀU QUYẾT';
    c_const_ca_rightname_h constant varchar2(100) := 'H. QUYỀN KHÁC';

    --TXDESC
    c_const_TLTX_TXDESC_8855 constant varchar2(100) := 'Trả phí mua';
    c_const_TLTX_TXDESC_8856 constant varchar2(100) := 'Trả phí bán';
    c_const_TLTX_TXDESC_8865 constant varchar2(100) := 'Trả tiền mua';
    c_const_TLTX_TXDESC_8866 constant varchar2(100) := 'Nhận tiền bán';
    c_const_TLTX_TXDESC_2262 constant varchar2(100) := 'Chuyển CK chờ giao dịch thành giao dịch';
    c_const_TLTX_TXDESC_2670 constant varchar2(100) := 'Giải ngân vay ML';
    c_const_TLTX_TXDESC_2660 constant varchar2(30) := 'Tất toán';
    c_const_TLTX_TXDESC_6663_DESC constant varchar2(100) := 'Chuyển tiền mua CK , TK : ';
    c_const_TLTX_TXDESC_6663_order constant varchar2(30) := ', Số lệnh :';
    c_const_TLTX_TXDESC_6663_amt constant varchar2(30) := ', Số tiền ';
    c_const_TLTX_TXDESC_6663_date constant varchar2(30) := ', Ngày GD ';
    c_const_TLTX_TXDESC_1153_desc constant varchar2(100) := 'Phí Ứng trước tiền bán: TK :';
    c_const_TLTX_TXDESC_6641 constant varchar2(100) := 'Chuyển tiền thu phí lưu ký, TK: ';
    c_const_TLTX_TXDESC_6641_3384 constant varchar2(100) := 'Đăng ký thực hiện quyền mua, ';
    c_const_TLTX_TXDESC_6641_8842 constant varchar2(100) := 'Hoàn trả mua/bán quyền nhận tiền bán chứng khoán , TK: ';
    c_const_TLTX_TXDESC_6641_price constant varchar2(100) := 'giá';
    c_const_TLTX_TXDESC_6641_2 constant varchar2(100) := 'Phí chuyển khoản tất toán tài khoản';
    c_const_TLTX_TXDESC_6644_VAT constant varchar2(100) := 'Chuyển thuế bán CK lô lẻ CK';
    c_const_TLTX_TXDESC_6644 constant varchar2(100) := 'Chuyển tiền bán CK lô lẻ CK ';
    c_const_TLTX_TXDESC_6644_TAX constant varchar2(100) := 'Hoàn lại thuế, TK: ';
    c_const_TLTX_TXDESC_6644_FEE constant varchar2(100) := 'Hoàn lại phí, TK : ';
    c_const_TLTX_TXDESC_6644_BUY constant varchar2(100) := 'Hoàn lại tiền và phí mua, TK : ';
    c_const_TLTX_TXDESC_6643 constant varchar2(50) := 'Thu thuế ';
    c_const_TLTX_TXDESC_6643_3386 constant varchar2(50) := 'Hủy đăng ký quyền mua, ';
    c_const_TLTX_TXDESC_6682_DIV constant varchar2(100) := 'Chuyển thuế bán CK, TK : ';
    c_const_TLTX_TXDESC_6682_RI constant varchar2(100) := 'Chuyển thuế bán CK quyền mua , TK : ';
    c_const_TLTX_TXDESC_6666 constant varchar2(100) := 'Chuyển phí bán CK , TK : ';
    c_const_TLTX_TXDESC_6665 constant varchar2(100) := 'Chuyển tiền bán CK , TK : ';
    c_const_TLTX_TXDESC_6665_aamt constant varchar2(100) := 'đã ứng : ';
    c_const_TLTX_TXDESC_6664 constant varchar2(100) := 'Chuyển phí mua CK , TK : ';
    c_const_TLTX_TXDESC_6667 constant varchar2(100) := 'Hoàn ứng trước tiền bán , TK : ';
--    c_const_TLTX_TXDESC_6668 constant varchar2(100) := 'Chuyển tiền từ tài khoản @ sang tài khoản tiền gửi ';
    c_const_TLTX_TXDESC_6668 constant varchar2(100) := 'Trich tien TKCN của TKCK ';
    c_const_TLTX_TXDESC_6668_1 constant varchar2(100) := ' de thuc hien nghia vu thanh toan';
    c_const_TLTX_TXDESC_6668_2 constant varchar2(100) := 'của KH tại BSC để thực hiện nghĩa vụ nợ';
    c_const_TLTX_TXDESC_6669 constant varchar2(100) := 'Bù trừ từ TK chính sang TK phụ';
    c_const_TLTX_TXDESC_6669_Inday constant varchar2(100) := 'Chuyển tiền từ TK chính sang TK phụ ngày ';
    c_const_TLTX_TXDESC_6669_1131 constant varchar2(100) := '(nộp tiền)';
    c_const_TLTX_TXDESC_6669_1141 constant varchar2(100) := '(nhận báo có từ NH)';
    c_const_TLTX_TXDESC_6669_1153 constant varchar2(100) := '(ứng trước)';
    c_const_TLTX_TXDESC_6669_plus constant varchar2(100) := 'đã trừ nghĩa vụ, nợ (nếu có)';
    c_const_TLTX_TXDESC_6669_RM constant varchar2(100) := 'Chuyển tiền sang TKCN ';
    c_const_TLTX_TXDESC_6669_RM2 constant varchar2(100) := 'sau khi đã trừ nghĩa vụ nợ (nếu có)';
    c_const_TLTX_TXDESC_SAMTTRF constant varchar2(100) := 'CT bán CK , TK : ';
    c_const_TLTX_TXDESC_SAMTTRF_D constant varchar2(100) := ', Ngày GD ';
    c_const_TLTX_TXDESC_SAMTTRF2 constant varchar2(100) := ' sang TKCN ';
    c_const_TLTX_TXDESC_SAMTTRF3 constant varchar2(100) := '(đã trừ nghĩa vụ nợ)';
    c_const_TLTX_TXDESC_SAMTTRF4 constant varchar2(100) := 'Chuyển tiền ';

    c_const_reftype_AFGP constant varchar2(100) := 'Hỗ trợ chậm thanh toán tiền mua';
    c_const_reftype_AFP constant varchar2(100) := 'Giao dịch ký quỹ';
    c_const_reftype_dfp constant varchar2(100) := 'Hợp đồng vay DF';
    c_const_TLTX_TXDESC_3356 constant varchar2(100) := 'Chuyển chứng khoán chờ giao dịch thành giao dịch, chốt ngày ';
    c_const_TLTX_TXDESC_3356_DF constant varchar2(100) := 'Chuyển cầm cố từ quyền chờ về sang giao dịch do làm 3356 ngày ';
    c_const_TLTX_TXDESC_3355_DF constant varchar2(100) := 'Chuyển cầm cố từ quyền chờ về sang giao dịch do làm 3355 ngày ';
    c_const_TLTX_TXDESC_0088_FEE constant varchar2(100) := 'Phí chuyển khoản tất toán TK';
    c_const_TXDESC_1101_OL constant varchar2(100) := 'Chuyển khoản ra ngoài: ';
    c_const_TXDESC_1120_OL constant varchar2(100) := 'Chuyển khoản nội bộ: ';
    c_const_TXDESC_1133_OL constant varchar2(100) := 'Chuyển khoản ra ngoài với CMND: ';
    c_const_TLTX_TXDESC_6646 constant varchar2(100) := 'Chuyển tiền mua/bán quyền nhận tiền bán chứng khoán ';
    c_const_TLTX_TXDESC_6646_amt constant varchar2(100) := 'số tiền: ';
    c_const_TLTX_TXDESC_6646_fee constant varchar2(100) := 'phí: ';
    c_const_TLTX_TXDESC_2244 constant varchar2(100) := 'Chuyển khoản chứng khoán ra ngoài';

    c_const_RPT_CF1000_1143 constant varchar2(200) := 'Số tiền đến hạn phải thanh toán';
    c_const_RPT_CF1000_1153 constant varchar2(200) := 'Phí ứng trước';
    c_const_RPT_CF1000_2266 constant varchar2(200) := 'Chuyển khoản chứng khoán ra bên ngoài';
    c_const_RPT_CF1007_8865 constant varchar2(200) := 'Trả tiền mua CK ngày ';
    c_const_RPT_CF1007_8855 constant varchar2(200) := 'Trả phí mua CK ngày ';
    c_const_RPT_CF1007_8866 constant varchar2(200) := 'Nhận tiền bán CK ngày ';
    c_const_RPT_CF1007_8866_2 constant varchar2(200) := 'Trả phí bán CK ngày ';

    c_const_RPT_OD0040_noilk_1 constant varchar2(200) := 'Tất cả';
    c_const_RPT_OD0040_noilk_2 constant varchar2(200) := 'Tại cty CK';
    c_const_RPT_OD0040_noilk_3 constant varchar2(200) := 'Lưu ký nơi khác';

    c_const_RPT_OD0040_chinhanh constant varchar2(200) := 'Tất cả';


    c_const_RPT_OD0040_noidetien_1 constant varchar2(200) := 'Tất cả';
    c_const_RPT_OD0040_noidetien_2 constant varchar2(200) := 'Công ty chứng khoán';
    c_const_RPT_OD0040_noidetien_3 constant varchar2(200) := 'Kết nối ngân hàng';
    c_const_RPT_OD0040_nhomql constant varchar2(200) := 'Tất cả';
    --RM TRFCODE
    c_const_RM_RM8878_diengiai_1 constant varchar2(200) := 'Chuyển tiền bán CK lẻ, SL';
    c_const_RM_RM8878_diengiai_2 constant varchar2(200) := 'Chuyển thuế bán CK lẻ ';
    c_const_RM_RM3384ex_diengiai_1 constant varchar2(200):='Ðăng ký thực hiện quyền mua ,CK mã';
    c_const_RM_RM3350ex_diengiai_1 constant varchar2(200) :='Thu thuế chia cổ tức bằng tiền';
    c_const_RM_RM3350ex_diengiai_2 constant varchar2(200) :='Chia cổ tức bằng tiền';
    c_const_RM_RM3384ex_gia constant varchar2(200) := ' Giá ';
    c_const_RM_RM8848ex_diengiai_1 constant varchar2(200) := 'Hoàn tiền sửa lỗi lệnh TK: ';
    c_FindText constant varchar2(2000) :=  'áàảãạâấầẩẫậăắằẳẵặđéèẻẽẹêếềểễệíìỉĩịóòỏõọôốồổỗộơớờởỡợúùủũụưứừửữựýỳỷỹỵÁÀẢÃẠÂẤẦẨẪẬĂẮẰẲẴẶĐÉÈẺẼẸÊẾỀỂỄỆÍÌỈĨỊÓÒỎÕỌÔỐỒỔỖỘƠỚỜỞỠỢÚÙỦŨỤƯỨỪỬỮỰÝỲỶỸỴ/&&#%\';
    c_ReplText constant varchar2(2000) :=  'aaaaaaaaaaaaaaaaadeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyAAAAAAAAAAAAAAAAADEEEEEEEEEEEIIIIIOOOOOOOOOOOOOOOOOUUUUUUUUUUUYYYYY/&&#%\';
    c_ReplTextTelex constant varchar2(2000) :=  '|?as?|?af?|?ar?|?ax?|?aj?|?aa?|?aas?|?aaf?|?aar?|?aax?|?aaj?|?aw?|?aws?|?awf?|?awr?|?awx?|?awj?|?dd?|?es?|?ef?|?er?|?ex?|?ej?|?ee?|?ees?|?eef?|?eer?|?eex?|?eej?|?is?|?if?|?ir?|?ix?|?ij?|?os?|?of?|?or?|?ox?|?oj?|?oo?|?oos?|?oof?|?oor?|?oox?|?ooj?|?ow?|?ows?|?owf?|?owr?|?owx?|?owj?|?us?|?uf?|?ur?|?ux?|?uj?|?uw?|?uws?|?uwf?|?uwr?|?uwx?|?uwj?|?ys?|?yf?|?yr?|?yx?|?yj?|?AS?|?AF?|?AR?|?AX?|?AJ?|?AA?|?AAS?|?AAF?|?AAR?|?AAX?|?AAJ?|?AW?|?AWS?|?AWF?|?AWR?|?AWX?|?AWJ?|?DD?|?ES?|?EF?|?ER?|?EX?|?EJ?|?EE?|?EES?|?EEF?|?EER?|?EEX?|?EEJ?|?IS?|?IF?|?IR?|?IX?|?IJ?|?OS?|?OF?|?OR?|?OX?|?OJ?|?OO?|?OOS?|?OOF?|?OOR?|?OOX?|?OOJ?|?OW?|?OWS?|?OWF?|?OWR?|?OWX?|?OWJ?|?US?|?UF?|?UR?|?UX?|?UJ?|?UW?|?UWS?|?UWF?|?UWR?|?UWX?|?UWJ?|?YS?|?YF?|?YR?|?YX?|?YJ?|?_?|?_38?|?_35?|?_37?|?_92?|';
    --- msgDEALER
    c_SYMBOL_BUYAMT constant varchar2(500) := 'Vượt qui định giá trị mua tối đa của chứng khoán';
    c_ADMIN_NOTPLO constant varchar2(500) := 'Quản trị không được phép đặt lệnh';
    c_CHECK_FAILED  constant varchar2(500) := 'Không tuân thủ luật kiểm soát tự doanh';
    c_COMPANY_MAXNAV constant varchar2(500):= 'Vượt qui định giá trị danh mục nắm giữ của toàn công ty';
    c_COMPANY_MAXQTTYORDER constant varchar2(500) := 'Vượt qui định KL tối đa một lệnh đặt';
    c_GROUP_MAXNAV constant varchar2(500) := 'Vượt qui định giá trị danh mục nắm giữ của nhóm';
    c_LEADER_NOTPLO constant varchar2(500) := 'Trưởng nhóm không có quyền đặt lệnh';
    c_OVER_DELTA_BUYING_PRICE constant varchar2(500) := 'Vượt biên độ giá mua qui định';
    c_OVER_DELTA_SELLING_PRICE constant varchar2(500) := 'Vi phạm biên độ giá bán qui định';
    c_OVER_MAX_BUYING_PRICE constant varchar2(500) := 'Vượt quá giá mua qui định';
    c_OVER_MIN_SELLING_PRICE constant varchar2(500) := 'Vi phạm giá bán tối thiểu';
    c_OVER_SYS_CURRENT_NAV_ALL constant varchar2(500) := 'Vượt giá trị danh mục toàn công ty';
    c_OVER_SYS_MAX_QTTY_PER_ORDER constant varchar2(500) := 'Vượt quá khối lượng tối đa của lệnh';
    c_OVER_TOTAL_QTTY constant varchar2(500) := 'Vượt khối lượng nắm giữ tối đa';
    c_SYMBOL_BUYPRICE constant varchar2(500) := 'Vượt qui định giá mua tối đa của chứng khoán';
    c_SYMBOL_CANNOT_TRADE constant varchar2(500) := 'Không được phép giao dịch mã này';
    c_SYMBOL_MAXAVL constant varchar2(500) := 'Vượt qui định khối lượng nắm giữ tối đa';
    c_SYMBOL_MINAVL constant varchar2(500) := 'Vượt qui định khối lượng nắm giữ tối thiểu';
    c_SYMBOL_SELLAMT constant varchar2(500) := 'Vượt qui định giá trị bán tối đa của chứng khoán';
    c_SYMBOL_SELLPRICE constant varchar2(500) := 'Vượt qui định giá bán tối thiểu của chứng khoán';
    c_TRADER_CANNOT_PLACE_ORDER constant varchar2(500) := 'Trưởng nhóm không có quyền đặt lệnh';
    c_TRADER_MAXNAV constant varchar2(500) := 'Vượt qui định giá trị danh mục nắm giữ của cán bộ';
    c_TRADER_MAXALLSELL constant varchar2(500) := 'Vượt qui định giá trị bán trong tuần của chứng khoán';
    c_TRADER_MAXALLBUY constant varchar2(500) := 'Vượt qui định giá trị mua trong tuần của chứng khoán';
    c_ALERT_OVER_TRD_G_LISTEDQTTY constant varchar2(500) := 'Giao dịch vượt xx% KL lưu hành';
    ---c_ALERT_OVER_TRD_L_LISTEDQTTY constant varchar2(500) := 'Giao dịch vượt xx% KL lưu hành';
    c_ALERT_MKT_G_AVGQTTY constant varchar2(500) := 'Giao dịch vượt xx% KL bình quân giao dịch';
    c_ALERT_OVER_TRD_L_LISTEDQTTY constant varchar2(500) := 'Giao dịch giảm xx% khối lượng lưu hành';
    c_ALERT_OVER_BAL_G_LISTEDQTTY constant varchar2(500) := 'Nắm giữ vượt xx% KL lưu hành  ';
    c_ALERT_OVER_TOTAL_QTTY constant varchar2(500) := 'Vượt quá khối lượng giao dịch tối đa';
    c_ALERT_OVER_MIN_QTTY_PRICE constant varchar2(500) := 'Nhỏ hơn khối lượng giao dịch tối thiểu';
    -- end msgDEALER
    C_FOPKS_API_BEGIN constant varchar2(100) := 'Dư đầu kỳ';
    C_FOPKS_API_END constant varchar2(100) := 'Dư cuối kỳ';
    --- DIEN GIAI SU KIEN 010
    C_TXDESC_3350_1 constant varchar2(50) := 'tạm ứng cổ tức lần 1, ';
    C_TXDESC_3350_2 constant varchar2(50) := 'nhận cổ tức đợt 2, ';
    C_CF2007_COPHIEU constant varchar2(50) := '%Cổ tức bằng tiền% ';
    C_CF2007_LAI_TP constant varchar2(50) := '%Lãi trái phiếu% ';
    C_CF2007_CP_LE constant varchar2(50) := '%CP lẻ trả bằng tiền%';
    C_CF1030_DEC constant varchar2(50) := 'lãi';
    C_2242_GEN_DESC constant varchar2(250) :='Từ tiểu khoản (<$88CUSTODYCD>) sang tiểu khoản (<$89CUSTODYCD>)';
    C_CONST_TLTX_TXDESC_1153 constant varchar2(100) := 'ứng trước tiền lệnh bán ngày: ';
    C_CONST_SELLTYPE_MR0063_BH constant varchar2(50) := 'Bán hết';
    C_CONST_SELLTYPE_MR0063_BD constant varchar2(50) := 'Bán đủ';

    C_CONST_SELLTYPE_MR0063_CTYBH constant varchar2(50) := 'Công ty bán hết';
    C_CONST_SELLTYPE_MR0063_CTYBD constant varchar2(50) := 'Công ty Bán đủ';
    C_CONST_SELLTYPE_MR0063_KHBD constant varchar2(50) := 'Khách hàng bán';

END utf8nums;
 
/
