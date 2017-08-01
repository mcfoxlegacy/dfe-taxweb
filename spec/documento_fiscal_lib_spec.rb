require 'spec_helper'

describe DocumentoFiscalLib do

  it 'has a version number' do
    expect(DocumentoFiscalLib::VERSION).not_to be_nil
  end

  # describe ".configuration" do
  #   it "is done via block initialization" do
  #     Asjm.configure do |c|
  #       c.host = "http://some/where"
  #       c.user_agent = "My App v1.0"
  #     end
  #     expect(Asjm.configuration.url).to eq "http://some/where/v1"
  #     expect(Asjm.configuration.user_agent).to eq "My App v1.0"
  #   end
  #
  #   it "uses a singleton object for the configuration values" do
  #     config1 = Asjm.configuration
  #     config2 = Asjm.configuration
  #     expect(config1).to eq config2
  #   end
  # end
  #
  # describe ".configure" do
  #   it "returns nil when no block given" do
  #     expect(Asjm.configure).to eql(nil)
  #   end
  #
  #   it "raise error if no method" do
  #     expect do
  #       Asjm.configure { |c| c.user = "Bart" }
  #     end.to raise_error(NoMethodError)
  #   end
  # end

  describe ".nfe" do
    let(:nfe_xml_string){File.read("spec/fixtures/files/nfe.xml")}
    subject { described_class.nfe(nfe_xml_string) }

    it "returns an instance of DocumentoFiscalLib::Nfe" do
      expect(subject).to be_a(DocumentoFiscalLib::Nfe)
    end
  end

  # describe ".subscribe" do
  #   class FakePublisher
  #     include Wisper::Publisher
  #
  #     def apply
  #       publish("fake.event")
  #     end
  #   end
  #
  #   it "notifies all listeners about an event occurrence" do
  #     listener = double("listener")
  #     expect(listener).to receive(:call).and_return(true)
  #     described_class.subscribe("fake.event", listener)
  #     FakePublisher.new.apply
  #   end
  # end
  #
  # describe '.signature' do
  #   subject { described_class.signature("my-secret-key") }
  #
  #   it "returns an instance of Asjm::Client" do
  #     expect(subject).to be_a(Asjm::Signature)
  #   end
  # end

end