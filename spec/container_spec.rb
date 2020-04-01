require "serverspec"
require "docker"
require "timeout"
require "net/smtp"
require "net/imap"
require "pry"

describe "Subliminal Mail Container" do
  before :all do
    puts "Starting container"
    image = Docker::Image.build_from_dir(".")
    container_opts = {
      Image: image.id,
      Entrypoint: ["bash", "-c", "/test.sh"],
      ExposedPorts: { "25/tcp" => {}, "143/tcp" => {}, "587/tcp" => {} },
      HostConfig: {
        PortBindings: {
          "25/tcp" => [{ "HostPort" => "2500"}],
          "143/tcp" => [{ "HostPort" => "1430"}],
          "587/tcp" => [{ "HostPort" => "5870"}],
        }
      },
      Env: [
        "SUBLIMIA_MAIL_DOMAINS=test.com",
        "SUBLIMIA_MAIL_USER_1=test@test.com:test",
      ]
    }
    @container = Docker::Container.create(container_opts)
    @container.archive_in(["spec/fixtures/dhparams.pem"], "/etc/sublimia/")
    @container.start

    set :os, family: :alpine
    set :backend, :docker
    set :docker_container, @container.id
  end

  after :all do
    @container.stop
    @container.delete
  end

  before :context do
    puts "Waiting for container"

    Timeout::timeout(10) do
      command("while [ ! -f /.ready ]; do sleep 1; done").exit_status
    end
  end

  describe "SMTP Service" do
    it "listens on port 25" do
      expect(port(25)).to be_listening
    end

    it "listens on port 587" do
      expect(port(587)).to be_listening
    end

    it "does starttls" do
      Net::SMTP.start("localhost", 5870) do |smtp|
        expect(smtp).to be_capable_starttls
      end
    end

    it "does not support auth before starttls" do
      Net::SMTP.start("localhost", 5870) do |smtp|
        expect(smtp).to_not be_capable_plain_auth
      end
    end

    it "supports plain auth after starttls" do
      client = Net::SMTP.new("localhost", 5870)
      client.enable_starttls
      client.start("helo") do |smtp|
        expect(smtp).to be_capable_plain_auth
      end
    end

    it "authenticates a client" do
      client = Net::SMTP.new("localhost", 5870)
      client.enable_starttls
      client.start("helo") do |smtp|
        expect(smtp.auth_plain("test@test.com", "test")).to be_success
      end
    end
  end

  describe "IMAP service" do
    it "listens on port 143" do
      expect(port(143)).to be_listening
    end

    it "does starttls" do
      imap = Net::IMAP.new("localhost", port: 1430)
      expect(imap.capability).to include "STARTTLS"
    end

    it "does not support auth before starttls" do
      imap = Net::IMAP.new("localhost", port: 1430)
      expect(imap.capability).to include "LOGINDISABLED"
    end

    it "supports plain auth after starttls" do
      imap = Net::IMAP.new("localhost", port: 1430)
      imap.starttls({verify_mode: OpenSSL::SSL::VERIFY_NONE})
      expect(imap.capability).to include "AUTH=PLAIN"
    end

    it "authenticates a client" do
      imap = Net::IMAP.new("localhost", port: 1430)
      imap.starttls({verify_mode: OpenSSL::SSL::VERIFY_NONE})
      expect {
        imap.authenticate("PLAIN", "test@test.com", "test")
      }.to_not raise_error
    end
  end

  describe "Mail delivery" do
    let(:email) { File.read("spec/fixtures/email.txt") }

    it "works" do
      client = Net::SMTP.new("localhost", 2500)
      client.enable_starttls
      client.start("helo") do |smtp|
        smtp.send_message(email, "testjoe@test.com", "test@test.com")
      end

      sleep 1

      imap = Net::IMAP.new("localhost", port: 1430)
      imap.starttls({verify_mode: OpenSSL::SSL::VERIFY_NONE})
      imap.authenticate("PLAIN", "test@test.com", "test")
      imap.select("INBOX")
      expect(imap.search(["SUBJECT", "Test"])).to eq [1]
    end
  end
end

