Feature: Update database with XML
  As a Developer
  I need to update the my database with an XML document
  So that records in my database that share the same identify features as those in the XML are updated

  Scenario: Attempting to update when some records have the same identifying features as those in teh XML Document
    Given I have a fresh set of books
    And I have the "test/fixtures/xml/books_changed.xml" with books in it
    When I update with "test/fixtures/xml/books_changed.xml"
    Then the books with the same identifying features as those in "test/fixtures/xml/books_changed.xml" will be updated
    And the chapters with the same identifying features as those in "test/fixtures/xml/books_changed.xml" will be updated
    And the pages with the same identifying features as those in "test/fixtures/xml/books_changed.xml" will be updated


  Scenario: Update when no records exist in the database

  Scenario: Update when records exist but there are no matching records in the database