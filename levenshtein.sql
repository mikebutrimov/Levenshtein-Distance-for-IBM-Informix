DROP PROCEDURE IF EXISTS  hexval;
CREATE PROCEDURE hexval(c CHAR(1)) RETURNING INTEGER;
    RETURN INSTR("0123456789abcdef", lower(c)) - 1;
END PROCEDURE;

DROP PROCEDURE IF EXISTS hexstr_to_bigint;
CREATE PROCEDURE hexstr_to_bigint(ival VARCHAR(18)) RETURNING bigint;
    DEFINE oval DECIMAL(20,0);
    DEFINE i,j,len INTEGER;
    LET ival = LOWER(ival);
    IF (ival[1,2] = '0x') THEN LET ival = ival[3,18]; END IF;
    LET len = LENGTH(ival);
    LET oval = 0;
    FOR i = 1 TO len
        LET j = hexval(SUBSTR(ival, i, 1));
        LET oval = oval * 16 + j;
    END FOR;
    IF (oval > 9223372036854775807) THEN
        LET oval = oval - 18446744073709551616;
    END IF;
    RETURN oval;
END PROCEDURE;

DROP FUNCTION IF EXISTS levenshtein;
CREATE FUNCTION levenshtein (s1 char(50), s2 char(50))
RETURNING int;
    DEFINE s1_len, s2_len, i, j, c, c_temp, cost INT;
    DEFINE s1_char CHAR;
    DEFINE cv0, cv1 LVARCHAR(256);
    LET s1_len = LENGTH(s1);
    LET s2_len = LENGTH(s2);
    LET cv1 = 0;
    LET j = 1;
    LET i = 1;
    LET c = 0;

    IF s1 = s2 THEN
      RETURN 0;
    ELIF s1_len = 0 THEN
      RETURN s2_len;
    ELIF s2_len = 0 THEN
      RETURN s1_len;
    ELSE
     WHILE j <= s2_len LOOP
        LET cv1 = CONCAT(cv1, hexstr_to_bigint(j)::CHAR);
        LET j = j + 1;
      END LOOP;
      
      WHILE  i <= s1_len LOOP
        LET s1_char = SUBSTR(s1, i, 1);
        LET c = i;
        LET cv0 = HEX(i)::CHAR;
        LET j = 1;

        WHILE j <= s2_len LOOP
          LET c = c + 1;
          IF s1_char = SUBSTR(s2, j, 1) THEN
            LET cost = 0;
          ELSE
            LET cost = 1;
          END IF;
          LET c_temp = hexstr_to_bigint(SUBSTR(cv1, j, 1))::INT + cost;
          IF c > c_temp THEN
            LET c = c_temp;
          END IF;
          LET c_temp = hexstr_to_bigint(SUBSTR(cv1, j+1, 1))::INT + 1;
          IF c > c_temp THEN
            LET c = c_temp;
          END IF;
          LET cv0 = CONCAT(cv0, c);
          LET j = j + 1;
        END LOOP;
        LET cv1 = cv0;
        LET i = i + 1;   
      END LOOP;
    END IF;
    RETURN c;
END FUNCTION
