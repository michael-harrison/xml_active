Feature: Remove records missing in XML
  As a Developer
  I need to update the my database with an XML document
  So that records in my database that do not share the same identify features as those in the XML are removed from my database

  Scenario: Attempt removing missing records when records exist in the database with some matching records in the XML Document
    Given I have a fresh set of books
    And I have the "test/fixtures/xml/books_changed.xml" with books in it
    When I synchronise with "test/fixtures/xml/books_changed.xml"
    Then the books in the database that don't exist in "test/fixtures/xml/books_changed.xml" will no longer exist in the database
    And the chapters in the database that don't exist in "test/fixtures/xml/books_changed.xml" will no longer exist in the database
    And the pages in the database that don't exist in "test/fixtures/xml/books_changed.xml" will no longer exist in the database

  Scenario: Attempt removing missing records when no records exist in the database

  Scenario: Attempt removing missing records when records exist but there are no matching records in the database
