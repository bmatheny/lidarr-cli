# frozen_string_literal: true

## the stderr should contain exactly "hello"
Then "the version should match Lidarr::VERSION" do
  expect(all_stdout).to include_output_string Lidarr::VERSION
end
