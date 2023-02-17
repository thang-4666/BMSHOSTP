SET DEFINE OFF;
CREATE OR REPLACE PACKAGE utils IS

  TYPE unicode IS TABLE OF VARCHAR2(50) INDEX BY BINARY_INTEGER;

  tab_unicode unicode;

  TYPE tcvn3 IS TABLE OF VARCHAR2(50) INDEX BY BINARY_INTEGER;

  tab_tcvn3 tcvn3;

  TYPE utf8 IS TABLE OF VARCHAR2(50) INDEX BY BINARY_INTEGER;

  tab_utf8 utf8;

  FUNCTION so_thanh_chu(p_a NUMBER) RETURN VARCHAR2;

  FUNCTION ext_to_number(p_a VARCHAR2) RETURN NUMBER;

  FUNCTION get_max(p_a NUMBER, p_b NUMBER) RETURN NUMBER;

  FUNCTION get_min(p_a NUMBER, p_b NUMBER) RETURN NUMBER;

  /*FUNCTION exception_error_message(p_error_code NUMBER, p_message VARCHAR2)
  RETURN VARCHAR2;*/
  FUNCTION fnc_convert_to_utf8(p_string VARCHAR2) RETURN VARCHAR2;

END utils;

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY utils IS

  FUNCTION so_thanh_chu(p_a NUMBER) RETURN VARCHAR2 IS
    v_char      VARCHAR2(50);
    v_str       VARCHAR2(50);
    v_start_pos NUMBER;
  BEGIN
    v_char      := to_char(round(p_a, 0));
    v_start_pos := length(v_char) -
                   (round(length(v_char) / 3 + 0.5, 0) - 1) * 3;
    v_str       := substr(v_char, 0, v_start_pos);
    LOOP
      EXIT WHEN substr(v_char, v_start_pos + 1, 3) IS NULL;
      v_str       := v_str || ',' || substr(v_char, v_start_pos + 1, 3);
      v_start_pos := v_start_pos + 3;
    END LOOP;
    IF substr(v_str, 1, 1) = ','
    THEN
      v_str := substr(v_str, 2);
    END IF;
    RETURN v_str;
  END;

  FUNCTION ext_to_number(p_a VARCHAR2) RETURN NUMBER IS
    v_number NUMBER;
  BEGIN
    BEGIN
      SELECT to_number(REPLACE(p_a, ',', '.')) INTO v_number FROM dual;
    EXCEPTION
      WHEN OTHERS THEN
        SELECT to_number(REPLACE(p_a, '.', ',')) INTO v_number FROM dual;
    END;
    RETURN v_number;
  END;

  FUNCTION get_max(p_a NUMBER, p_b NUMBER) RETURN NUMBER IS
    v_max NUMBER;
  BEGIN
    v_max := p_a;
    IF v_max < p_b
    THEN
      v_max := p_b;
    END IF;
    RETURN v_max;
  END;

  FUNCTION get_min(p_a NUMBER, p_b NUMBER) RETURN NUMBER IS
    v_min NUMBER;
  BEGIN
    v_min := p_a;
    IF v_min > p_b
    THEN
      v_min := p_b;
    END IF;
    RETURN v_min;
  END;

  /*FUNCTION exception_error_message(p_error_code NUMBER, p_message VARCHAR2)
    RETURN VARCHAR2 IS
    v_message VARCHAR2(100) := 'Co l?i trong h? th?ng giao d?ch ch?ng khoan';
  BEGIN
    BEGIN
      SELECT a.ERROR_CODE
        INTO v_message
        FROM error_definition a
       WHERE a.ERROR_CODE = p_error_code;
    EXCEPTION
      WHEN no_data_found THEN
        v_message := p_message;
    END;
    RETURN v_message;
  END;*/
  PROCEDURE prc_get_initial_unicode IS
  BEGIN
    tab_unicode(1) := ';;.224;';
    tab_unicode(2) := ';;.225;';
    tab_unicode(3) := ';;.7843;';
    tab_unicode(4) := ';;.227;';
    tab_unicode(5) := ';;.7841;';
    tab_unicode(6) := ';;.259;';
    tab_unicode(7) := ';;.7857;';
    tab_unicode(8) := ';;.7855;';
    tab_unicode(9) := ';;.7859;';
    tab_unicode(10) := ';;.7861;';
    tab_unicode(11) := ';;.7863;';
    tab_unicode(12) := ';;.226;';
    tab_unicode(13) := ';;.7847;';
    tab_unicode(14) := ';;.7845;';
    tab_unicode(15) := ';;.7849;';
    tab_unicode(16) := ';;.7851;';
    tab_unicode(17) := ';;.7853;';
    tab_unicode(18) := ';;.273;';
    tab_unicode(19) := ';;.232;';
    tab_unicode(20) := ';;.233;';
    tab_unicode(21) := ';;.7867;';
    tab_unicode(22) := ';;.7869;';
    tab_unicode(23) := ';;.7865;';
    tab_unicode(24) := ';;.234;';
    tab_unicode(25) := ';;.7873;';
    tab_unicode(26) := ';;.7871;';
    tab_unicode(27) := ';;.7875;';
    tab_unicode(28) := ';;.7877;';
    tab_unicode(29) := ';;.7879;';
    tab_unicode(30) := ';;.236;';
    tab_unicode(31) := ';;.237;';
    tab_unicode(32) := ';;.7881;';
    tab_unicode(33) := ';;.297;';
    tab_unicode(34) := ';;.7883;';
    tab_unicode(35) := ';;.242;';
    tab_unicode(36) := ';;.243;';
    tab_unicode(37) := ';;.7887;';
    tab_unicode(38) := ';;.245;';
    tab_unicode(39) := ';;.7885;';
    tab_unicode(40) := ';;.244;';
    tab_unicode(41) := ';;.7891;';
    tab_unicode(42) := ';;.7889;';
    tab_unicode(43) := ';;.7893;';
    tab_unicode(44) := ';;.7895;';
    tab_unicode(45) := ';;.7897;';
    tab_unicode(46) := ';;.417;';
    tab_unicode(47) := ';;.7901;';
    tab_unicode(48) := ';;.7899;';
    tab_unicode(49) := ';;.7903;';
    tab_unicode(50) := ';;.7905;';
    tab_unicode(51) := ';;.7907;';
    tab_unicode(52) := ';;.249;';
    tab_unicode(53) := ';;.250;';
    tab_unicode(54) := ';;.7911;';
    tab_unicode(55) := ';;.361;';
    tab_unicode(56) := ';;.7909;';
    tab_unicode(57) := ';;.432;';
    tab_unicode(58) := ';;.7915;';
    tab_unicode(59) := ';;.7913;';
    tab_unicode(60) := ';;.7917;';
    tab_unicode(61) := ';;.7919;';
    tab_unicode(62) := ';;.7921;';
    tab_unicode(63) := ';;.7923;';
    tab_unicode(64) := ';;.253;';
    tab_unicode(65) := ';;.7927;';
    tab_unicode(66) := ';;.7929;';
    tab_unicode(67) := ';;.7925;';
    tab_unicode(68) := ';;.258;';
    tab_unicode(69) := ';;.194;';
    tab_unicode(70) := ';;.272;';
    tab_unicode(71) := ';;.202;';
    tab_unicode(72) := ';;.212;';
    tab_unicode(73) := ';;.416;';
    tab_unicode(74) := ';;.431;';
    tab_unicode(75) := ';;.224;';
    tab_unicode(76) := ';;.225;';
    tab_unicode(77) := ';;.7843;';
    tab_unicode(78) := ';;.227;';
    tab_unicode(79) := ';;.7841;';
    tab_unicode(80) := ';;.7857;';
    tab_unicode(81) := ';;.7855;';
    tab_unicode(82) := ';;.7859;';
    tab_unicode(83) := ';;.7861;';
    tab_unicode(84) := ';;.7863;';
    tab_unicode(85) := ';;.7847;';
    tab_unicode(86) := ';;.7845;';
    tab_unicode(87) := ';;.7849;';
    tab_unicode(88) := ';;.7851;';
    tab_unicode(89) := ';;.7853;';
    tab_unicode(90) := ';;.232;';
    tab_unicode(91) := ';;.233;';
    tab_unicode(92) := ';;.7867;';
    tab_unicode(93) := ';;.7869;';
    tab_unicode(94) := ';;.7865;';
    tab_unicode(95) := ';;.7873;';
    tab_unicode(96) := ';;.7871;';
    tab_unicode(97) := ';;.7875;';
    tab_unicode(98) := ';;.7877;';
    tab_unicode(99) := ';;.7879;';
    tab_unicode(100) := ';;.236;';
    tab_unicode(101) := ';;.237;';
    tab_unicode(102) := ';;.7881;';
    tab_unicode(103) := ';;.297;';
    tab_unicode(104) := ';;.7883;';
    tab_unicode(105) := ';;.242;';
    tab_unicode(106) := ';;.243;';
    tab_unicode(107) := ';;.7887;';
    tab_unicode(108) := ';;.245;';
    tab_unicode(109) := ';;.7885;';
    tab_unicode(110) := ';;.7891;';
    tab_unicode(111) := ';;.7889;';
    tab_unicode(112) := ';;.7893;';
    tab_unicode(113) := ';;.7895;';
    tab_unicode(114) := ';;.7897;';
    tab_unicode(115) := ';;.7901;';
    tab_unicode(116) := ';;.7899;';
    tab_unicode(117) := ';;.7903;';
    tab_unicode(118) := ';;.7905;';
    tab_unicode(119) := ';;.7907;';
    tab_unicode(120) := ';;.249;';
    tab_unicode(121) := ';;.250;';
    tab_unicode(122) := ';;.7911;';
    tab_unicode(123) := ';;.361;';
    tab_unicode(124) := ';;.7909;';
    tab_unicode(125) := ';;.7915;';
    tab_unicode(126) := ';;.7913;';
    tab_unicode(127) := ';;.7917;';
    tab_unicode(128) := ';;.7919;';
    tab_unicode(129) := ';;.7921;';
    tab_unicode(130) := ';;.7923;';
    tab_unicode(131) := ';;.253;';
    tab_unicode(132) := ';;.7927;';
    tab_unicode(133) := ';;.7929;';
    tab_unicode(134) := ';;.7925;';
  END;

  PROCEDURE prc_get_utf8 IS
  BEGIN
    tab_utf8(1) := 'a';
    tab_utf8(2) := 'a';
    tab_utf8(3) := '?';
    tab_utf8(4) := '?';
    tab_utf8(5) := '?';
    tab_utf8(6) := 'a';
    tab_utf8(7) := '?';
    tab_utf8(8) := '?';
    tab_utf8(9) := '?';
    tab_utf8(10) := '?';
    tab_utf8(11) := '?';
    tab_utf8(12) := 'a';
    tab_utf8(13) := '?';
    tab_utf8(14) := '?';
    tab_utf8(15) := '?';
    tab_utf8(16) := '?';
    tab_utf8(17) := '?';
    tab_utf8(18) := 'd';
    tab_utf8(19) := 'e';
    tab_utf8(20) := 'e';
    tab_utf8(21) := '?';
    tab_utf8(22) := '?';
    tab_utf8(23) := '?';
    tab_utf8(24) := 'e';
    tab_utf8(25) := '?';
    tab_utf8(26) := '?';
    tab_utf8(27) := '?';
    tab_utf8(28) := '?';
    tab_utf8(29) := '?';
    tab_utf8(30) := 'i';
    tab_utf8(31) := 'i';
    tab_utf8(32) := '?';
    tab_utf8(33) := 'i';
    tab_utf8(34) := '?';
    tab_utf8(35) := 'o';
    tab_utf8(36) := 'o';
    tab_utf8(37) := '?';
    tab_utf8(38) := '?';
    tab_utf8(39) := '?';
    tab_utf8(40) := 'o';
    tab_utf8(41) := '?';
    tab_utf8(42) := '?';
    tab_utf8(43) := '?';
    tab_utf8(44) := '?';
    tab_utf8(45) := '?';
    tab_utf8(46) := 'o';
    tab_utf8(47) := '?';
    tab_utf8(48) := '?';
    tab_utf8(49) := '?';
    tab_utf8(50) := '?';
    tab_utf8(51) := '?';
    tab_utf8(52) := 'u';
    tab_utf8(53) := 'u';
    tab_utf8(54) := '?';
    tab_utf8(55) := 'u';
    tab_utf8(56) := '?';
    tab_utf8(57) := 'u';
    tab_utf8(58) := '?';
    tab_utf8(59) := '?';
    tab_utf8(60) := '?';
    tab_utf8(61) := '?';
    tab_utf8(62) := '?';
    tab_utf8(63) := '?';
    tab_utf8(64) := 'y';
    tab_utf8(65) := '?';
    tab_utf8(66) := '?';
    tab_utf8(67) := '?';
    tab_utf8(68) := 'A';
    tab_utf8(69) := 'A';
    tab_utf8(70) := '?';
    tab_utf8(71) := 'E';
    tab_utf8(72) := 'O';
    tab_utf8(73) := 'O';
    tab_utf8(74) := 'U';
    tab_utf8(75) := 'a';
    tab_utf8(76) := 'a';
    tab_utf8(77) := '?';
    tab_utf8(78) := '?';
    tab_utf8(79) := '?';
    tab_utf8(80) := '?';
    tab_utf8(81) := '?';
    tab_utf8(82) := '?';
    tab_utf8(83) := '?';
    tab_utf8(84) := '?';
    tab_utf8(85) := '?';
    tab_utf8(86) := '?';
    tab_utf8(87) := '?';
    tab_utf8(88) := '?';
    tab_utf8(89) := '?';
    tab_utf8(90) := 'e';
    tab_utf8(91) := 'e';
    tab_utf8(92) := '?';
    tab_utf8(93) := '?';
    tab_utf8(94) := '?';
    tab_utf8(95) := '?';
    tab_utf8(96) := '?';
    tab_utf8(97) := '?';
    tab_utf8(98) := '?';
    tab_utf8(99) := '?';
    tab_utf8(100) := 'i';
    tab_utf8(101) := 'i';
    tab_utf8(102) := '?';
    tab_utf8(103) := 'i';
    tab_utf8(104) := '?';
    tab_utf8(105) := 'o';
    tab_utf8(106) := 'o';
    tab_utf8(107) := '?';
    tab_utf8(108) := '?';
    tab_utf8(109) := '?';
    tab_utf8(110) := '?';
    tab_utf8(111) := '?';
    tab_utf8(112) := '?';
    tab_utf8(113) := '?';
    tab_utf8(114) := '?';
    tab_utf8(115) := '?';
    tab_utf8(116) := '?';
    tab_utf8(117) := '?';
    tab_utf8(118) := '?';
    tab_utf8(119) := '?';
    tab_utf8(120) := 'u';
    tab_utf8(121) := 'u';
    tab_utf8(122) := '?';
    tab_utf8(123) := 'u';
    tab_utf8(124) := '?';
    tab_utf8(125) := '?';
    tab_utf8(126) := '?';
    tab_utf8(127) := '?';
    tab_utf8(128) := '?';
    tab_utf8(129) := '?';
    tab_utf8(130) := '?';
    tab_utf8(131) := 'y';
    tab_utf8(132) := '?';
    tab_utf8(133) := '?';
    tab_utf8(134) := '?';
  END;

  FUNCTION fnc_convert_to_utf8(p_string VARCHAR2) RETURN VARCHAR2 IS
    v_string VARCHAR2(10000) := p_string;
  BEGIN
    prc_get_initial_unicode;
    prc_get_utf8;
    FOR i IN 1 .. tab_unicode.COUNT()
    LOOP
      v_string := REPLACE(v_string, tab_unicode(i), tab_utf8(i));
    END LOOP;
    RETURN v_string;
  END;

END utils;

/
