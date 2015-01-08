require 'spec_helper'

describe Merb::Cache::AdhocStore do
  it_should_behave_like 'all stores'

  before(:each) do
    Merb::Cache.stores.clear
    Thread.current[:'merb-cache'] = nil
    Merb::Cache.register(:dummy, DummyStore)
    @store = Merb::Cache::AdhocStore[:dummy]
  end

  describe "#initialize" do
    it "should lookup all store names" do
      names = [:first, :second, :third]
      names.each {|n| Merb::Cache.should_receive(:[]).with(n)}

      Merb::Cache::AdhocStore[*names]
    end
  end

  describe "#writable?" do
    it "should return the first non-nil result of a writeable store" do
      unwritable, writable = double(:unwritable_store), double(:writable_store)
      unwritable.should_receive(:writable?).and_return nil
      writable.should_receive(:writable?).and_return true

      adhoc = Merb::Cache::AdhocStore.new
      adhoc.stores = [unwritable, writable]
      adhoc.writable?(:foo).should be_truthy
    end

    it "should stop calling writable after the first non-nil result" do
      unwritable, writable, unused = double(:unwritable_store), double(:writable_store), double(:unused_store)
      unwritable.stub(:writable?).and_return nil
      writable.should_receive(:writable?).and_return true
      unused.should_not_receive(:writable?)

      adhoc = Merb::Cache::AdhocStore.new
      adhoc.stores = [unwritable, writable, unused]
      adhoc.writable?(:foo).should be_truthy
    end

    it "should return nil if none of the stores are writable" do
      unwritable = double(:unwritable_store)
      unwritable.should_receive(:writable?).exactly(3).times.and_return(nil)

      adhoc = Merb::Cache::AdhocStore.new
      adhoc.stores = [unwritable, unwritable, unwritable]
      adhoc.writable?(:foo).should be_nil
    end
  end

  describe "#write" do
    it "should return the first non-nil result of a writeable store" do
      unwritable, writable = double(:unwritable_store), double(:writable_store)
      unwritable.should_receive(:write).and_return nil
      writable.should_receive(:write).and_return true

      adhoc = Merb::Cache::AdhocStore.new
      adhoc.stores = [unwritable, writable]
      adhoc.write(:foo).should be_truthy
    end

    it "should stop calling writable after the first non-nil result" do
      unwritable, writable, unused = double(:unwritable_store), double(:writable_store), double(:unused_store)
      unwritable.stub(:write).and_return nil
      writable.should_receive(:write).and_return true
      unused.should_not_receive(:write)

      adhoc = Merb::Cache::AdhocStore.new
      adhoc.stores = [unwritable, writable, unused]
      adhoc.write(:foo).should be_truthy
    end

    it "should return nil if none of the stores are writable" do
      unwritable = double(:unwritable_store)
      unwritable.should_receive(:write).exactly(3).times.and_return(nil)

      adhoc = Merb::Cache::AdhocStore.new
      adhoc.stores = [unwritable, unwritable, unwritable]
      adhoc.write(:foo).should be_nil
    end
  end

  describe "#write_all" do
    it "should return false if a store returns nil for write_all" do
      unwritable, writable = double(:unwritable_store), double(:writable_store)
      unwritable.should_receive(:write_all).and_return nil
      writable.should_receive(:write_all).and_return "bar"

      adhoc = Merb::Cache::AdhocStore.new
      adhoc.stores = [unwritable, writable]
      adhoc.write_all(:foo).should be_falsey
    end

    it "should always call write_all on every store" do
      unwritable, writable, used = double(:unwritable_store), double(:writable_store), double(:used_store)
      unwritable.stub(:write_all).and_return nil
      writable.should_receive(:write_all).and_return true
      used.should_receive(:write_all).and_return true

      adhoc = Merb::Cache::AdhocStore.new
      adhoc.stores = [unwritable, writable, used]
      adhoc.write_all(:foo).should be_falsey
    end
  end

  describe "#fetch" do
    it "should return a call to read if it is non-nil" do
      adhoc = Merb::Cache::AdhocStore.new
      adhoc.should_receive(:read).and_return "bar"
      adhoc.fetch(:foo).should == "bar"
    end

    it "should return the first non-nil result of a fetchable store" do
      unfetchable, fetchable = double(:unfetchable_store), double(:fetchable_store)
      unfetchable.should_receive(:fetch).and_return nil
      fetchable.should_receive(:fetch).and_return true

      adhoc = Merb::Cache::AdhocStore.new
      adhoc.stores = [unfetchable, fetchable]
      adhoc.should_receive(:read).and_return nil
      adhoc.fetch(:foo).should be_truthy
    end

    it "should return the value of the block if none of the stores are fetchable" do
      adhoc = Merb::Cache::AdhocStore.new
      adhoc.fetch(:foo) {
        'foo'

      }.should == 'foo'
    end

    it "should stop calling fetch after the first non-nil result" do
      unfetchable, fetchable, unused = double(:unwritable_store), double(:writable_store), double(:unused_store)
      unfetchable.stub(:fetch).and_return nil
      fetchable.should_receive(:fetch).and_return true
      unused.should_not_receive(:fetch)

      adhoc = Merb::Cache::AdhocStore.new
      adhoc.stores = [unfetchable, fetchable, unused]
      adhoc.should_receive(:read).and_return nil
      adhoc.fetch(:foo).should be_truthy
    end
  end

  describe "#exists?" do
    it "should return the first non-nil result of a readable store" do
      unreadable, readable = double(:unreadable_store), double(:readable_store)
      unreadable.should_receive(:exists?).and_return nil
      readable.should_receive(:exists?).and_return true

      adhoc = Merb::Cache::AdhocStore.new
      adhoc.stores = [unreadable, readable]
      adhoc.exists?(:foo).should be_truthy
    end

    it "should stop calling readable after the first non-nil result" do
      unreadable, readable, unused = double(:unreadable_store), double(:readable_store), double(:unused_store)
      unreadable.stub(:exists?).and_return nil
      readable.should_receive(:exists?).and_return true
      unused.should_not_receive(:exists?)

      adhoc = Merb::Cache::AdhocStore.new
      adhoc.stores = [unreadable, readable, unused]
      adhoc.exists?(:foo).should be_truthy
    end

    it "should return nil if none of the stores are readable" do
      unreadable = double(:unreadable_store)
      unreadable.should_receive(:exists?).exactly(3).times.and_return(nil)

      adhoc = Merb::Cache::AdhocStore.new
      adhoc.stores = [unreadable, unreadable, unreadable]
      adhoc.exists?(:foo).should be_nil
    end
  end

  describe "#delete" do
    it "should return false if all stores returns nil for delete" do
      undeletable = double(:undeletable_store)
      undeletable.should_receive(:delete).and_return nil

      adhoc = Merb::Cache::AdhocStore.new
      adhoc.stores = [undeletable]
      adhoc.delete(:foo).should be_falsey
    end

    it "should always call delete on every store" do
      undeletable, deletable, used = double(:undeletable_store), double(:deletable_store), double(:used_store)
      undeletable.stub(:delete).and_return nil
      deletable.should_receive(:delete).and_return true
      used.should_receive(:delete).and_return true

      adhoc = Merb::Cache::AdhocStore.new
      adhoc.stores = [undeletable, deletable, used]
      adhoc.delete(:foo).should be_truthy
    end
  end

  describe "#delete_all!" do
    it "should return false if a store returns nil for write_all" do
      undeletable, deletable = double(:undeletable_store), double(:deletable_store)
      undeletable.should_receive(:delete_all!).and_return nil
      deletable.should_receive(:delete_all!).and_return true

      adhoc = Merb::Cache::AdhocStore.new
      adhoc.stores = [undeletable, deletable]
      adhoc.delete_all!.should be_falsey
    end

    it "should always call write_all on every store" do
      undeletable, deletable, used = double(:undeletable_store), double(:deletable_store), double(:used_store)
      undeletable.stub(:delete_all!).and_return nil
      deletable.should_receive(:delete_all!).and_return true
      used.should_receive(:delete_all!).and_return true

      adhoc = Merb::Cache::AdhocStore.new
      adhoc.stores = [undeletable, deletable, used]
      adhoc.delete_all!.should be_falsey
    end
  end
end