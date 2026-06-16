
# This test is run following the 03_TLS test and checks the govlogger logs contain the correct
# content. Hence the name 05_ prefix. The "--order defined" option is used on rspec to order by
# filename

require "spec_helper"
require "json"

describe "Govlogger postprocesser output" do

  context "Check correct count log lines from post processor" do

    lines = []

    it "Logfile has correct line count and is parses" do
      # Wait for the postprocessor to finish running
      # the healthcheck eventually flushes log output
      sleep(20)

      f = File.open("/test_log_data/govlogs.out","r")
      f.each { |line|
        lines.push(JSON.parse(line))
      }

      # We expect 8 log events
      expect(lines.length).to be == 8
    end

    it "Successful EAP-TLS logged" do
      # Check we get the first success log line
      found = nil
      count = 0

      # Should have 1 line logged
      lines.each { |line|
        if (line["Calling-Station-Id"] == "F5-23-78-27-71-00")
          count += 1
          found = line
        end
      }
      expect(count).to eq 1

      # Correct lines logged
      expect(found["lines"].length).to eq 3

      # None should have a Module-Failure-Message
      found["lines"].each { |log_entry|
        expect(log_entry).not_to include("Module-Failure-Message")
      }

      # NAK
      expect(found["lines"][0]).to include("EAP-Type" => "NAK")

      # then NAK
      expect(found["lines"][1]).to include("EAP-Type" => "TLS")

      # then NAK
      expect(found["lines"][2]).to include("EAP-Type" => "TLS")
    end

    it "Invalid cert - Wrong Key" do
      # Check we get the first success log line
      found = nil
      count = 0

      # Find single log entry
      lines.each { |line|
        if (line["Calling-Station-Id"] == "F5-23-78-27-71-01")
          count += 1
          found = line
        end
      }
      expect(count).to eq 1

      # Correct entry count
      expect(found["lines"].length).to eq 1

      # None jave a Module-Failure-Message
      found["lines"].each { |log_entry|
        expect(log_entry).not_to include("Module-Failure-Message")
      }

      # First is identity
      expect(found["lines"][0]).to include("EAP-Type" => "NAK")
    end

    it "Invalid cert - Invalid Client" do
      # Check we get the first success log line
      found = nil
      count = 0

      # Find single log entry
      lines.each { |line|
        if (line["Calling-Station-Id"] == "F5-23-78-27-71-02")
          count += 1
          found = line
        end
      }
      expect(count).to eq 1

      # Correct entry count
      expect(found["lines"].length).to eq 1

      # None jave a Module-Failure-Message
      found["lines"].each { |log_entry|
        expect(log_entry).not_to include("Module-Failure-Message")
      }

      # Just a NAK
      expect(found["lines"][0]).to include("EAP-Type" => "NAK")
    end

    it "Invalid cert - Expired Client Cert" do
      # Check we get the first success log line
      found = nil
      count = 0

      # Find single log entry
      lines.each { |line|
        if (line["Calling-Station-Id"] == "F5-23-78-27-71-03")
          count += 1
          found = line
        end
      }
      expect(count).to eq 1

      # Correct entry count
      expect(found["lines"].length).to eq 3


      # NAK
      expect(found["lines"][0]).to include("EAP-Type" => "NAK")

      # then TLS
      expect(found["lines"][1]).to include("EAP-Type" => "TLS")

      # then TLS
      expect(found["lines"][2]).to include("EAP-Type" => "TLS")

    
      # Last entry should be module failure
      expect(found["lines"][0]).not_to include("Module-Failure-Message")
      expect(found["lines"][1]).not_to include("Module-Failure-Message")
      expect(found["lines"][2]).to include("Module-Failure-Message")
      expect(found["lines"][2]["Module-Failure-Message"][0]).to match(/certificate has expired/)
    end

    it "Invalid cert - Foreign CA" do
      # Check we get the first success log line
      found = nil
      count = 0

      # Find single log entry
      lines.each { |line|
        if (line["Calling-Station-Id"] == "F5-23-78-27-71-04")
          count += 1
          found = line
        end
      }
      expect(count).to eq 1

      # Correct entry count
      expect(found["lines"].length).to eq 3


      # NAK
      expect(found["lines"][0]).to include("EAP-Type" => "NAK")

      # then TLS
      expect(found["lines"][1]).to include("EAP-Type" => "TLS")

      # then TLS
      expect(found["lines"][2]).to include("EAP-Type" => "TLS")

    
      # Last entry should be module failure
      expect(found["lines"][0]).not_to include("Module-Failure-Message")
      expect(found["lines"][1]).not_to include("Module-Failure-Message")
      expect(found["lines"][2]).to include("Module-Failure-Message")
      expect(found["lines"][2]["Module-Failure-Message"][0]).to match(/OpenSSL says error 20/)
      expect(found["lines"][2]).to include("TLS-Client-Cert-Subject-Alt-Name-Dns" => "unclealbert.bigmight.com")
    end


  end

end
