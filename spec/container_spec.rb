require "serverspec"
require "docker"
require "pry"

describe "Subliminal Mail Container" do

  before :all do
    image = Docker::Image.build_from_dir(".")

    set :os, family: :debian
    set :backend, :docker
    set :docker_image, image.id

    expect(command("sqlite3 $MAIL_DB_PATH 'INSERT INTO mailboxes VALUES (\"test@sublimia.nl\", \"{SHA256}n4bQgYhMfWWaL+qgxVrQFaO/TxsrC4Is0V1sFbDwCgg=\", \"sublimia.nl/test/\", CURRENT_TIMESTAMP, 5000, 5000);'").exit_status).to be 0
  end

  before do
    sleep 1
  end

  describe "SMTP Service" do
    it "listens on port 25" do
      expect(port(25)).to be_listening
    end

    it "listens on port 587" do
      expect(port(587)).to be_listening
    end

    it "has the certificates configured a-ok" do
      expect(command("echo quit | openssl s_client -connect localhost:25 -starttls smtp").stdout).to include "Verify return code: 0 (ok)"
    end

    it "delivers an email to maildir" do
      expect(command("sendmail -F test@test.com test@sublimia.nl < /root/test/test.mail").exit_status).to eq 0
      expect(file("/var/log/mail.log").content).to match(/test@sublimia.nl.*delivered to maildir/)
    end

    it "authenticates a client" do
      expect(command("(echo -e \"EHLO test@test.com\r\nAUTH PLAIN dGVzdEBzdWJsaW1pYS5ubAB0ZXN0QHN1YmxpbWlhLm5sAHRlc3Q=\"; sleep 1) | openssl s_client -connect localhost:587 -starttls smtp").stdout).to include "235 2.7.0 Authentication successful"
    end
  end

  describe "IMAP service" do
    it "listens on port 993" do
      expect(port(993)).to be_listening
    end

    it "has the certificates configured a-ok" do
      expect(command("echo quit | openssl s_client -connect localhost:993").stdout).to include "Verify return code: 0 (ok)"
    end
  end

  describe "Authentication service" do
    it "authenticates a user" do
      expect(command("authtest test@sublimia.nl test").exit_status).to eq 0
    end
  end
end

