CREATE TABLE mailboxes (
  address TEXT NOT NULL,
  password TEXT NOT NULL,
  maildir TEXT NOT NULL,
  created TEXT DEFAULT CURRENT_TIMESTAMP,
  uid INT NOT NULL,
  gid INT NOT NULL,
  PRIMARY KEY (address)
);
