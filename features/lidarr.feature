Feature: Lidarr

  Scenario: Help exits 0
    When I run `lidarr --help`
    Then the exit status should be 0

  Scenario: Version message
    When I run `lidarr version`
    Then the version should match Lidarr::VERSION
