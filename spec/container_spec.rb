require "serverspec"
require "docker"
require "pry"

describe "Subliminal Mail Container" do

  before :all do
    @image = Docker::Image.build_from_dir(".")

    set :os, family: :debian
    set :backend, :docker
    set :docker_image, @image.id

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
  end
end

