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

  VALID_FROM_XML_OPTIONS = [:sync, :create, :update, :destroy, :build]

  module ClassMethods
    def many_from_xml(xml, options = [])
      if xml.is_a?(String)
        doc = Nokogiri::XML(xml)
        current_node = doc.children.first
      else
        current_node = xml
      end

      records = []
      if self.xml_node_matches_many_of_class(current_node)
        ids = []
        if (self.xml_node_is_association(current_node))
          current_node.element_children.each do |node|
            record = self.one_from_xml(node, options)
            ids[ids.length] = record[primary_key.to_sym]
            records[records.length] = record
          end
        else
          records[records.length] = self.one_from_xml(current_node)
        end

        if ids.length > 0 and (options.include?(:destroy) or options.include?(:sync))
          self.destroy_all [self.primary_key.to_s + " not in (?)", ids.collect]
        end
      else
        raise "The supplied XML (#{current_node.name}) cannot be mapped to this class (#{self.name})"
      end

      records
    end

    def one_from_xml(xml, options = [])
      if xml.is_a?(String)
        doc = Nokogiri::XML(xml)
        current_node = doc.children.first
      else
        current_node = xml
      end

      if self.xml_node_matches_single_class(current_node)
        pk_value = 0
        pk_node = current_node.xpath(self.primary_key.to_s)
        if pk_node
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

        if (ar.new_record? and options.include?(:update) and not options.include?(:sync))
          return(nil)
        end

        current_node.element_children.each do |node|
          sym = node.name.underscore.to_sym
          if self.xml_node_is_association(node)
            # Association
            association = self.reflect_on_association(sym)
            if association && association.collection?
              # association exists, lets process it
              child_ids = []
              node.element_children.each do |single_obj|
                child_ids[child_ids.length] = single_obj.xpath(self.primary_key.to_s).text
                if single_obj.attributes['type'].blank?
                  klass = association.klass
                else
                  klass = Kernel.const_get(single_obj.attributes['type'].value)
                end
                new_record = klass.one_from_xml(single_obj, options)
                if (new_record != nil)
                  ar.__send__(sym) << new_record
                end
              end
              if (pk_value != 0 and child_ids.length > 0 and (options.include?(:destroy) or options.include?(:sync)))
                klass.destroy_all [klass.primary_key.to_s + " not in (?) and #{association.primary_key_name} = ?", child_ids.collect, pk_value]
              end
            elsif association && ! association.collection?
              raise ArgumentError.new("Can't destroy, update or sync :has_one associations") if [:destroy, :update, :sync].any? {|opt| options.include?(opt) }

              ar.__send__("#{sym}=", association.klass.one_from_xml(node, options))
            end
          else
            # Attribute
            if node.attributes['nil'].try(:value)
              ar[sym] = nil
            else
              ar[sym] = node.text
            end
          end
        end

        if options.include?(:sync)
          # Doing complete synchronisation with XML
          ar.save
        elsif options.include?(:create) and ar.new_record?
          ar.save
        elsif options.include?(:update) and not ar.new_record?
          ar.save
        end

        ar
      else
        raise "The supplied XML (#{current_node.name}) cannot be mapped to this class (#{self.name})"
      end
    end

    def xml_node_matches_single_class(xml_node)
      if xml_node.attributes['type'].blank?
        self.name.underscore.eql?(xml_node.name.underscore)
      else
        self.name.underscore.eql?(xml_node.attributes['type'].value.underscore)
      end
    end

    def xml_node_matches_many_of_class(xml_node)
      self.name.pluralize.underscore.eql?(xml_node.name.underscore)
    end

    def xml_node_is_association(xml_node)
      attr
      if (attr = xml_node.attributes["type"]) && attr == 'array'
        # has_many
        true
      else
        # Maybe has one?
        reflect_on_association(xml_node.name.underscore.to_sym).present?
      end
    end
  end
end

class ActiveRecord::Base
  include XmlActive
end
