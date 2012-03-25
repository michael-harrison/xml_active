require 'spec_helper'

describe XmlActive do
  it "should import one record" do
    book = FactoryGirl.create :book
    should be_imported pending "from_xml method"
  end

  it "should import many records" do
    pending "from_xml method"
  end

  it "should import one record and its has_many records" do
    pending "from_xml method"
  end

  it "should import many records and all their has_many records" do
    pending "from_xml method"
  end

  it "should import one record and its has_one record" do
    pending "from_xml method"
  end

  it "should import many records and their has_one record" do
    pending "from_xml method"
  end

  it "should import one record and its belongs_to record" do
    pending "from_xml method"
  end

  it "should import many records and their belongs_to records" do
    pending "from_xml method"
  end

  RSpec::Matchers.define :be_imported do |expected|
    match do
      expected_xml = expected.to_xml
      expected_class = Array.wrap(expected).class
      
      Array.wrap(expected).each { |one_of_expected| one_of_expected.destroy }

      actual_xml = expected_class.from_xml(expected_xml)
      actual_xml == expected_xml
    end

    diffable
  end
end
