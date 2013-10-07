require "spec_helper"
require "pry"
require "pp"

describe YAMLInventory do
  let(:inventory) do 
    YAMLInventory::Parser.new(YAML.load_file("spec/fixtures/hosts.yml"))
  end

  describe "#groups" do
    it "doesn't explode too hard" do
      inventory.groups
    end
  end

  describe "#host" do
    it "doesn't explode too hard" do
      inventory.host("hostwithvars")
    end
  end
end