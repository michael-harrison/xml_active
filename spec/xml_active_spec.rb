require 'spec_helper'

describe XmlActive do
  shared_context "xml_elements" do |xml_element|
    it "can be imported" do
      pending "spec it"
    end

    it "can contain has_many associations" do
      pending "spec it"
    end

    it "can contain has_one associations" do
      pending "spec it"
    end

    it "can contain belongs_to associations" do
      pending "spec it"
    end

    it "can contains polymorphic belongs_to associations" do
      pending "spec it"
    end

    it "can differeniate between nil and blank" do
      pending "spec it"
    end
  end

  context "with only one record" do
    include_context "xml_elements"
  end

  context "with many records" do
    include_context "xml_elements"
  end
end
