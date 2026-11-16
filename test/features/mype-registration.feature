@US18
Feature: MYPE registration with RUC
  As a MYPE owner
  I want to register my company using its RUC
  So that the platform retrieves my legal data and enables my business profile

  Scenario Outline: Create an empty profile when IAM registers a new user
    Given the IAM service publishes a user created event for user "<userId>" with email "<email>" and role "<role>"
    When the Profile service consumes the event from the "vankoo.iam.events" topic
    Then a <profile> profile exists for user "<userId>"
    And its KYC status is "PENDING"

    Examples:
      | userId                               | email                | role          | profile  |
      | 7b53549c-1f0e-4d2b-9a3c-0d1e2f3a4b5c | mype.owner@vankoo.pe | ROLE_MYPE     | company  |
      | c706c8ee-2a1b-4c3d-8e4f-5a6b7c8d9e0f | investor@vankoo.pe   | ROLE_INVESTOR | investor |

  @wip
  Scenario: Retrieve the legal data of an active RUC
    Given a company profile exists for user "7b53549c-1f0e-4d2b-9a3c-0d1e2f3a4b5c"
    And the RUC "20601234567" is active in the official registry
    When the MYPE owner registers the RUC "20601234567"
    Then the company profile stores the business name, the legal address and the tax status from the registry
    And the company profile is pending completion

  @wip
  Scenario Outline: Reject a RUC that cannot operate
    Given a company profile exists for user "7b53549c-1f0e-4d2b-9a3c-0d1e2f3a4b5c"
    And the RUC "<ruc>" is <registry state> in the official registry
    When the MYPE owner registers the RUC "<ruc>"
    Then the registration is rejected
    And the rejection reason "<reason>" is kept on the company profile
    And the company profile is not enabled to operate

    Examples:
      | ruc         | registry state | reason              |
      | 20100000001 | inactive       | RUC inactive        |
      | 20100000002 | deregistered   | RUC deregistered    |
      | 20999999999 | not found      | RUC not found       |
