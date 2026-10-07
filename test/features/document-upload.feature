@TS02
Feature: Identity document upload
  As a MYPE owner or an investor
  I want to upload my identity and company documents through presigned URLs
  So that the KYC review has the files it needs without passing them through the API

  Scenario Outline: Request a presigned upload URL for an allowed file type
    Given a <profile> exists with id "<id>"
    When I send a POST request to "/api/v1/<resource>/<id>/<document>/upload-url" with the content type "<content type>"
    Then the response status is 200
    And the response contains a presigned URL for the object storage

    Examples:
      | profile  | resource  | id                                   | document | content type    |
      | company  | companies | 7b53549c-1f0e-4d2b-9a3c-0d1e2f3a4b5c | ruc      | application/pdf |
      | company  | companies | 7b53549c-1f0e-4d2b-9a3c-0d1e2f3a4b5c | logo     | image/png       |
      | investor | investors | c706c8ee-2a1b-4c3d-8e4f-5a6b7c8d9e0f | dni      | image/jpeg      |
      | investor | investors | c706c8ee-2a1b-4c3d-8e4f-5a6b7c8d9e0f | photo    | image/jpeg      |

  Scenario: Reject a file type that is not allowed
    Given an investor exists with id "c706c8ee-2a1b-4c3d-8e4f-5a6b7c8d9e0f"
    When I send a POST request to "/api/v1/investors/c706c8ee-2a1b-4c3d-8e4f-5a6b7c8d9e0f/dni/upload-url" with the content type "application/zip"
    Then the response status is 400
    And the error message lists the allowed content types "image/jpeg", "image/png" and "application/pdf"

  Scenario: Report an upload URL request for a profile that does not exist
    When I send a POST request to "/api/v1/companies/00000000-0000-0000-0000-000000000000/ruc/upload-url" with the content type "application/pdf"
    Then the response status is 404

  Scenario: Register the uploaded RUC document on the company profile
    Given a company exists with id "7b53549c-1f0e-4d2b-9a3c-0d1e2f3a4b5c"
    And the RUC document was uploaded to "https://vankoo-storage.s3.amazonaws.com/rucs/20601234567.pdf"
    When I send a PATCH request to "/api/v1/companies/7b53549c-1f0e-4d2b-9a3c-0d1e2f3a4b5c/ruc" with the document URL "https://vankoo-storage.s3.amazonaws.com/rucs/20601234567.pdf"
    Then the response status is 200
    And the response message is "RUC subido exitosamente"

  Scenario: Reject a document reference that is not a URL
    Given a company exists with id "7b53549c-1f0e-4d2b-9a3c-0d1e2f3a4b5c"
    When I send a PATCH request to "/api/v1/companies/7b53549c-1f0e-4d2b-9a3c-0d1e2f3a4b5c/ruc" with the document URL "not a url"
    Then the response status is 400
    And the company "7b53549c-1f0e-4d2b-9a3c-0d1e2f3a4b5c" keeps its previous RUC document
