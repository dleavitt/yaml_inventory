require "spec_helper"
require "pry"
require "pp"

describe YAMLInventory do
  let(:inventory) do
    YAMLInventory::Parser.new(YAML.load_file("spec/fixtures/hosts.yml"))
  end

  describe "#full" do
    it "makes the right groups" do
      groups = %w( group1 exsubgroup ungrouped )
      inventory.full.keys.sort.must_equal groups.sort
    end

    describe "vars" do
      it "supports setting vars" do
        inventory.full["group1"][:vars]["group1var1"].must_equal "group1var1"
        inventory.full["exsubgroup"][:vars]["exsubvar1"].must_equal "exsubvar1"
      end

      it "inherits vars from parent groups" do
        inventory.full["exsubgroup"][:vars]["group1var1"].must_equal "group1var1"
      end

      it "overrides vars inherited from parent groups" do
        inventory.full["group1"][:vars]["overriddenhg"].must_equal "overridden"
        inventory.full["exsubgroup"][:vars]["overriddenhg"].must_equal "overriddenbygroup"
      end

      it "does not inherit vars from child groups" do
        inventory.full["group1"][:vars]["exsubvar1"].must_be_nil
      end

      it "does not inherit vars from hosts" do
        inventory.full["group1"][:vars]["hostvar1"].must_be_nil
        inventory.full["group1"][:vars]["hostvar2"].must_be_nil
      end

      it "does not inherit vars from hosts" do
        inventory.full["group1"][:vars]["hostvar1"].must_be_nil
        inventory.full["group1"][:vars]["hostvar2"].must_be_nil
      end
    end

    describe "hosts" do
      it "supports setting undefined hosts" do
        inventory.full["group1"][:hosts].must_include "newhost"
      end

      it "supports setting previously-defined hosts" do
        inventory.full["group1"][:hosts].must_include "hostwithvars"
        inventory.full["exsubgroup"][:hosts].must_include "notstandalonehost"
      end

      it "encompasses hosts from child groups" do
        inventory.full["group1"][:hosts].must_include "notstandalonehost"
      end

      it "does not inherit hosts from parent groups" do
        inventory.full["exsubgroup"][:hosts].wont_include "newhost"
        inventory.full["exsubgroup"][:hosts].wont_include "hostwithvars"
      end

      it "allows defining groups within hosts" do
        skip "Not implemented yet"
      end

      it "allows defining groups within groups" do
        skip "Not implemented yet"
      end
    end

    describe "groups" do
      it "sets child groups" do
        inventory.full["group1"][:children].must_include "exsubgroup"
      end
    end

    describe "'ungrouped' group" do
      subject do
        inventory.full["ungrouped"]
      end

      let :standalones do
        %w(standalonehost1 standalonehost2 standalonehostwithvars).sort
      end

      it "has hosts" do
        subject[:hosts].wont_be_nil
      end

      it "contains only standalone hosts" do
        subject[:hosts].sort.must_equal standalones
      end

      it "doesn't contain hosts that have groups" do
        subject[:hosts].wont_include "notstandalonehost"
      end

      it "has no vars" do
        subject[:vars].must_be_empty
      end

      it "has no children" do
        subject[:children].must_be_empty
      end
    end

  end

  describe "#groups" do
    subject do
      inventory.groups
    end

    it "puts the ungrouped ones into 'ungrouped'" do
      subject["ungrouped"].sort.must_equal %w( standalonehost1 standalonehost2 standalonehostwithvars ).sort
    end

    it "collects subgroup hosts" do
      subject["group1"].sort.must_equal %w( newhost hostwithvars notstandalonehost ).sort
    end

    it "doesn't collected supergroup hosts" do
      subject["exsubgroup"].sort.must_equal %w( notstandalonehost ).sort
    end
  end

  describe "#host" do
    def host(hostname, var = nil)
      h = inventory.host(hostname)
      var ? h[var] : h
    end

    it "returns vars when they are set on hosts" do
      host("hostwithvars", "hostvar1").must_equal "hostvar1v"
      host("standalonehostwithvars", "hostvar3").must_equal "hostvar3v"
    end

    it "returns no vars for standalone hosts" do
      host("standalonehost1").must_be_empty
    end

    it "inherits vars from groups" do
      host("newhost", "group1var1").must_equal "group1var1"
    end

    it "inherits vars from parent groups" do
      host("notstandalonehost", "group1var1").must_equal "group1var1"
    end

    it "overrides inherited vars with its own" do
      host("hostwithvars", "overriddenh").must_equal "overriddenbyhost"
    end

    it "gives precedence to group vars from its most direct parent" do
      host("notstandalonehost", "overriddenhg").must_equal "overriddenbygroup"
    end

    it "inherits group vars from ALL its parents" do
      skip "No example yet"
    end

    it "doesn't explode too hard" do
      inventory.host("hostwithvars")
    end
  end
end