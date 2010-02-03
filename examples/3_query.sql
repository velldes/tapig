SET serveroutput ON
DECLARE
  user_rec ap_users_ta.user_rec;
  user_cur ap_users_ta.user_cur;
BEGIN
  user_rec.firstname := 'First%';
  ap_users_ta.qry( user_cur, user_rec );
  FETCH user_cur INTO user_rec;
  CLOSE user_cur;
  dbms_output.put_line( user_rec.firstname || ', ' || user_rec.lastname );
END;