Then /^the books in the database that don't exist in "([^"]*)" will no longer exist in the database$/ do |xml_document_file|
  xml_document = Nokogiri::XML(File.open(Rails.root.join(xml_document_file)).read)
  books_in_xml = xml_document.xpath("//book")
  books_in_database = Book.all

  if (books_in_xml.count != books_in_database.count)
    fail "Book count does not match. There are #{books_in_database.count} in the database and #{books_in_xml.count} in the xml document"
  else
    # Check that all the books in the xml document exist in the database
    xml_document.each do |book_element|
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
  end
end

When /^the chapters in the database that don't exist in "([^"]*)" will no longer exist in the database$/ do |xml_document_file|
  xml_document = Nokogiri::XML(File.open(Rails.root.join(xml_document_file)).read)
  chapters_in_xml = xml_document.xpath("//chapter")
  chapters_in_database = Chapter.all

  if (chapters_in_xml.count != chapters_in_database.count)
    fail "Chapter count does not match. There are #{chapters_in_database.count} in the database and #{chapters_in_xml.count} in the xml document"
  else
    # Check that all the chapters in the xml document exist in the database
    xml_document.xpath("//book").each do |book_element|
      book_id = book_element.xpath("id").text
      xml_document.xpath("//book[id[text()='#{book_id}']]/chapters/chapter").each do |chapter_element|
        chapter_id = chapter_element.xpath("id")[0].text
        chapter_title = chapter_element.xpath("title")[0].text
        chapter_introduction = chapter_element.xpath("introduction")[0].text

        begin
          chapter = Chapter.find(chapter_id)
        rescue
          chapter = nil
        end

        if chapter != nil
          if chapter_title != chapter.title
            fail "Chapter title in database doesn't match chapter title in xml for chapter with id #{chapter_id}, XML: #{chapter_title}, Database: #{chapter.title}"
          end
          if chapter_introduction != chapter.introduction
            fail "Chapter introduction in database doesn't match chapter introduction in xml for chapter with id #{chapter_id}, XML: #{chapter_introduction}, Database: #{chapter.introduction}"
          end
          if book_id != chapter.book_id.to_s
            fail "Chapter book_id in database doesn't match chapter book_id in xml for chapter with id #{chapter_id}, XML: #{book_id}, Database: #{chapter.book_id}"
          end
        else
          fail "Chapter with id #{chapter_id} is missing"
        end
      end
    end
  end
end

When /^the pages in the database that don't exist in "([^"]*)" will no longer exist in the database$/ do |xml_document_file|
  xml_document = Nokogiri::XML(File.open(Rails.root.join(xml_document_file)).read)
  pages_in_xml = xml_document.xpath("//page")
  pages_in_database = Page.all

  if (pages_in_xml.count != pages_in_database.count)
    fail "Page count does not match. There are #{pages_in_database.count} in the database and #{pages_in_xml.count} in the xml document"
  else
    xml_document.xpath("//book").each do |book_element|
      book_id = book_element.xpath("id").text
      xml_document.xpath("//book[id[text()='#{book_id}']]/chapters/chapter").each do |chapter_element|
        chapter_id = chapter_element.xpath("id")[0].text
        pages = Page.where(:chapter_id => chapter_id)
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
      end
    end
  end
end