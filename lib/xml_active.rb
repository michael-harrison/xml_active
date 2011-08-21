require "xml_active/version"

module XmlActive
  def self.included(base)
    base.extend ClassMethods
  end

  def ensure_unique(name)
    begin
      self[name] = yield
    end while self.class.exists?(name => self[name])
  end

  module ClassMethods
    def many_from_xml(xml, do_save = false, delete_obsolete = false)
      if xml.is_a?(String)
        doc = Nokogiri::XML(xml)
        current_node = doc.children.first
      else
        current_node = xml
      end

      records = []
      if self.xml_node_matches_many_of_class(current_node)
        # puts "container:" + current_node.name
        ids = []
        if (self.xml_node_is_association(current_node))
          current_node.element_children.each do |node|
            # puts "child:" + node.name
            record = self.one_from_xml(node, do_save, delete_obsolete)
            ids[ids.length] = record[primary_key.to_sym]
            records[records.length] = record
          end
        else
          records[records.length] = self.one_from_xml(current_node)
        end

        if ids.length > 0 && delete_obsolete
          self.destroy_all [self.primary_key.to_s + " not in (?)", ids.collect]
        end
      else
        puts "The supplied XML (#{current_node.name}) cannot be mapped to this class (#{self.name})";
      end

      records
    end

    def one_from_xml(xml, do_save = false, delete_obsolete = false)
      if xml.is_a?(String)
        doc = Nokogiri::XML(xml)
        current_node = doc.children.first
      else
        current_node = xml
      end

      if self.xml_node_matches_single_class(current_node)
        pk_value = 0
        pk_node = current_node.xpath(self.primary_key.to_s)
        if (pk_node)
          begin
            ar = find(pk_node.text)
            pk_value = pk_node.text
          rescue
            # No record exists, create a new one
            ar = self.new
          end
        else
          # No primary key value, must be a new record
          ar = self.new
        end

        current_node.element_children.each do |node|
          sym = node.name.underscore.to_sym
          if (self.xml_node_is_association(node))
            # Association
            # puts "association:" + node.name
            association = self.reflect_on_association(sym)
            if (association)
              # association exists, lets process it
              klass = association.klass
              child_ids = []
              node.element_children.each do |single_obj|
                # puts sym
                # puts "child:" + single_obj.name
                child_ids[child_ids.length] = single_obj.xpath(self.primary_key.to_s).text
                ar.__send__(sym) << klass.one_from_xml(single_obj, do_save, delete_obsolete)
              end
              if (pk_value != 0 && child_ids.length > 0 && delete_obsolete)
                # puts klass.name + "." + klass.primary_key.to_s + " not in (#{child_ids}) and #{association.primary_key_name} = #{pk_value}"
                klass.destroy_all [klass.primary_key.to_s + " not in (?) and #{association.primary_key_name} = ?", child_ids.collect, pk_value]
              end
            end
          else
            # Attribute
            # puts "attribute:" + node.name
            ar[sym] = node.text
          end
        end
        if do_save
          ar.save
        end

        ar
      else
        puts "The supplied XML (#{current_node.name}) cannot be mapped to this class (#{self.name})";
      end
    end

    def xml_node_matches_single_class(xml_node)
      self.name.downcase.eql?(xml_node.name.downcase)
    end

    def xml_node_matches_many_of_class(xml_node)
      self.name.pluralize.downcase.eql?(xml_node.name.downcase)
    end

    def xml_node_is_association(xml_node)
      attr = xml_node.attributes["type"]
      if (attr)
        attr.value == "array"
      else
        false
      end
    end
  end
end

class ActiveRecord::Base
  include XmlActive
end