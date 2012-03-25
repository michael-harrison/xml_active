require "nokogiri"
require "xml_active"

Given /^I have no books$/ do
  Book.destroy_all
  books_in_database = Book.all
  if (books_in_database.count > 0)
    fail "Records still exist in the database"
  end
end

When /^I have the "([^"]*)" with books in it$/ do |xml_document_file|
  if File.exists?(xml_document_file)
    xml_document = Nokogiri::XML(File.open(Rails.root.join(xml_document_file)).read)
    xml_document.children.first.name.downcase.eql?("books") || xml_document.children.first.name.downcase.eql?("book")
  else
    fail "XML File doesn't exist"
  end
end

When /^I synchronise with "([^"]*)"$/ do |xml_document_file|
  Book.many_from_xml(File.open(Rails.root.join(xml_document_file)).read, [:sync]) != nil
end

When /^I update with "([^"]*)"$/ do |xml_document_file|
  @original_books = Book.all
  @original_chapters = Chapter.all
  @original_pages = Page.all
  Book.many_from_xml(File.open(Rails.root.join(xml_document_file)).read, [:update]) != nil
end

Then /^the books in the database will be identical to those in "([^"]*)"$/ do |xml_document_file|
  books_in_database = Book.all
  if books_in_database.count > 0
    books_xml_document = Nokogiri::XML(File.open(Rails.root.join(xml_document_file)).read)

    # Ensure that all books in the xml document have been recorded
    book_elements = books_xml_document.xpath("//book")
    book_elements.each do |book_element|
      book_id = book_element.xpath("//book/id")[0].text
      book_name = book_element.xpath("//book/name")[0].text
      book = Book.find(book_id)
      if book == nil
        fail "Books with id #{book_id} is missing"
      else
        if book_name != book.name
          fail "Book name in database doesn't match book name in xml for book with id #{book_id}, XML: #{book_name}, Database: #{book.name}"
        end
      end
    end

    # Ensure there are not extra books
    books_in_xml = books_xml_document.xpath("//book")
    if books_in_database.count != books_in_xml.count
      fail "There number of books in the database (#{books_in_database.count}) doesn't match the number of books in the xml document (#{books_in_xml.count})"
    end

  else
    fail "no books recorded"
  end
end

When /^the chapters will be identical to those in "([^"]*)"$/ do |xml_document_file|
  chapters_in_database = Chapter.all
  if chapters_in_database.count > 0
    xml_document = Nokogiri::XML(File.open(Rails.root.join(xml_document_file)).read)

    # Ensure that all chapters in the xml document have been recorded

    xml_document.xpath("//book").each do |book_element|
      book_id = book_element.xpath("id").text
      xml_document.xpath("//book[id[text()='#{book_id}']]/chapters/chapter").each do |chapter_element|
        chapter_id = chapter_element.xpath("id")[0].text
        chapter_title = chapter_element.xpath("title")[0].text
        chapter_introduction = chapter_element.xpath("introduction")[0].text
        chapter = Chapter.find(chapter_id)

        if chapter == nil
          fail "Chapters with id #{chapter_id} is missing"
        else
          if chapter_title != chapter.title
            fail "Chapter title in database doesn't match chapter title in xml for chapter with id #{chapter_id}, XML: #{chapter_title}, Database: #{chapter.title}"
          end
          if chapter_introduction != chapter.introduction
            fail "Chapter introduction in database doesn't match chapter introduction in xml for chapter with id #{chapter_id}, XML: #{chapter_introduction}, Database: #{chapter.introduction}"
          end
          if book_id != chapter.book_id.to_s
            fail "Chapter book_id in database doesn't match chapter book_id in xml for chapter with id #{chapter_id}, XML: #{book_id}, Database: #{chapter.book_id}"
          end
        end
      end
    end


    # Ensure there are not extra chapters
    chapters_in_xml = xml_document.xpath("//chapter")
    if chapters_in_database.count != chapters_in_xml.count
      fail "There number of chapters in the database (#{chapters_in_database.count}) doesn't match the number of chapters in the xml document (#{chapters_in_xml.count})"
    end

  else
    fail "no chapters recorded"
  end
end

When /^the database will contain identical pages for the chapters as those in "([^"]*)"$/ do |xml_document_file|
  chapters_in_database = Chapter.all
  if chapters_in_database.count > 0
    xml_document = Nokogiri::XML(File.open(Rails.root.join(xml_document_file)).read)

    # Ensure that all chapters in the xml document have been recorded

    xml_document.xpath("//book").each do |book_element|
      book_id = book_element.xpath("id").text
      xml_document.xpath("//book[id[text()='#{book_id}']]/chapters/chapter").each do |chapter_element|
        chapter_id = chapter_element.xpath("id")[0].text
        pages = Page.where(:chapter_id => chapter_id)
        if (pages.count > 0)
          xml_document.xpath("//chapter[id[text()='#{chapter_id}']]/pages/page").each do |page_element|
            page_id = page_element.xpath("id")[0].text
            page_content = page_element.xpath("content")[0].text
            page_number = page_element.xpath("number")[0].text
            page = Page.find(page_id)

            if page == nil
              fail "Page with id #{page_id} is missing"
            else
              if page_content != page.content
                file "Page content in database doesn't match page content in xml for page with id #{page_id}, XML: #{page_content}, Database: #{page.content}"
              end
              
              if page_number != page.number.to_s
                fail "Page number in database doesn't match page number in xml for page with id #{page_id}, XML: #{page_number}, Database: #{page.number}"
              end
            end
          end
        else
          fail "no pages recorded for chapter with id #{chapter_id}"
        end
      end
    end


    # Ensure there are not extra pages
    pages_in_xml = xml_document.xpath("//page")
    pages_in_database = Page.all
    if pages_in_database.count != pages_in_xml.count
      fail "There number of pages in the database (#{pages_in_database.count}) doesn't match the number of pages in the xml document (#{pages_in_xml.count})"
    end

  else
    fail "no chapters recorded"
  end
end

Given /^I have a fresh set of books$/ do
  Book.many_from_xml(File.open(Rails.root.join("test/fixtures/xml/books_fresh.xml")).read, [:sync]) != nil
end
