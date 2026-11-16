@TS02
Feature: Profiles and KYC REST contract
  As a developer integrating the MYPE and investor applications
  I want to complete profiles and verify or reject their KYC through the Profile API
  So that only verified identities can operate financially

  Scenario Outline: Retrieve an existing profile
    Given a <profile> exists with id "<id>"
    When I send a GET request to "/api/v1/<resource>/<id>"
    Then the response status is 200
    And the response contains the id "<id>" and a KYC status

    Examples:
      | profile  | resource  | id                                   |
      | company  | companies | 7b53549c-1f0e-4d2b-9a3c-0d1e2f3a4b5c |
      | investor | investors | c706c8ee-2a1b-4c3d-8e4f-5a6b7c8d9e0f |

  Scenario Outline: Report a profile that does not exist
    When I send a GET request to "/api/v1/<resource>/00000000-0000-0000-0000-000000000000"
    Then the response status is 404
    And the response contains an error message

    Examples:
      | resource  |
      | companies |
      | investors |

  Scenario: Complete a company profile
    Given a company exists with id "7b53549c-1f0e-4d2b-9a3c-0d1e2f3a4b5c" and KYC status "PENDING"
    When I send a PATCH request to "/api/v1/companies/7b53549c-1f0e-4d2b-9a3c-0d1e2f3a4b5c/profile" with:
      | rucNumber               | 20601234567               |
      | businessName            | Textiles Loreto SAC       |
      | industrySector          | MANUFACTURING             |
      | contactPhone            | 987654321                 |
      | legalAddress.street     | Av. Los Constructores 456 |
      | legalAddress.city       | Lima                      |
      | legalAddress.state      | Lima                      |
      | legalAddress.postalCode | 15023                     |
      | legalAddress.country    | Perú                      |
    Then the response status is 200
    And the response message is "Perfil de empresa completado exitosamente"
    And the company "7b53549c-1f0e-4d2b-9a3c-0d1e2f3a4b5c" has the business name "Textiles Loreto SAC"

  Scenario: Reject a profile completion with fields outside the contract
    Given a company exists with id "7b53549c-1f0e-4d2b-9a3c-0d1e2f3a4b5c" and KYC status "PENDING"
    When I send a PATCH request to "/api/v1/companies/7b53549c-1f0e-4d2b-9a3c-0d1e2f3a4b5c/profile" with an unknown field "isAdmin"
    Then the response status is 400
    And the company "7b53549c-1f0e-4d2b-9a3c-0d1e2f3a4b5c" keeps its previous data

  Scenario Outline: Verify the KYC of a pending profile
    Given a <profile> exists with id "<id>" and KYC status "PENDING"
    When I send a PATCH request to "/api/v1/<resource>/<id>/kyc/verify"
    Then the response status is 200
    And the response message is "KYC verificado exitosamente"
    And the <profile> "<id>" has KYC status "VERIFIED"

    Examples:
      | profile  | resource  | id                                   |
      | company  | companies | 7b53549c-1f0e-4d2b-9a3c-0d1e2f3a4b5c |
      | investor | investors | c706c8ee-2a1b-4c3d-8e4f-5a6b7c8d9e0f |

  Scenario Outline: Reject the KYC of a pending profile with a reason
    Given a <profile> exists with id "<id>" and KYC status "PENDING"
    When I send a PATCH request to "/api/v1/<resource>/<id>/kyc/reject" with the reason "La foto del DNI está ilegible"
    Then the response status is 200
    And the response message is "KYC rechazado"
    And the <profile> "<id>" has KYC status "REJECTED"

    Examples:
      | profile  | resource  | id                                   |
      | company  | companies | 7b53549c-1f0e-4d2b-9a3c-0d1e2f3a4b5c |
      | investor | investors | c706c8ee-2a1b-4c3d-8e4f-5a6b7c8d9e0f |

  Scenario: Require a reason to reject a KYC
    Given an investor exists with id "c706c8ee-2a1b-4c3d-8e4f-5a6b7c8d9e0f" and KYC status "PENDING"
    When I send a PATCH request to "/api/v1/investors/c706c8ee-2a1b-4c3d-8e4f-5a6b7c8d9e0f/kyc/reject" without a reason
    Then the response status is 400
    And the investor "c706c8ee-2a1b-4c3d-8e4f-5a6b7c8d9e0f" has KYC status "PENDING"

  Scenario Outline: Keep the KYC status when the profile is no longer pending
    Given a company exists with id "7b53549c-1f0e-4d2b-9a3c-0d1e2f3a4b5c" and KYC status "<current status>"
    When I send a PATCH request to "/api/v1/companies/7b53549c-1f0e-4d2b-9a3c-0d1e2f3a4b5c/kyc/<action>"
    Then the response status is 400
    And the company "7b53549c-1f0e-4d2b-9a3c-0d1e2f3a4b5c" has KYC status "<current status>"

    Examples:
      | current status | action |
      | VERIFIED       | verify |
      | REJECTED       | verify |
      | VERIFIED       | reject |

  Scenario Outline: Report a KYC change on a profile that does not exist
    When I send a PATCH request to "/api/v1/<resource>/00000000-0000-0000-0000-000000000000/kyc/verify"
    Then the response status is 404

    Examples:
      | resource  |
      | companies |
      | investors |
