DECLARE
  user_rec ap_users_ta.user_rec;
  user_tab ap_users_ta.user_tab;
BEGIN
  user_rec.id           := 1;
  user_rec.firstname    := 'FirstName';
  user_rec.lastname     := 'LastName';
  user_rec.country      := 'country';
  user_rec.create_date  := SYSDATE;
  user_tab(1) := user_rec;
  ap_users_ta.ins(user_tab);
END;