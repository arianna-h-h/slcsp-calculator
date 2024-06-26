require 'csv'

def parse_zips
  zips_table = CSV.parse(File.read("zips.csv"), headers: true)
  zips_hash = {}
  zips_table.each do |row|
    if zips_hash[row["zipcode"]]
      zips_hash[row["zipcode"]] << "#{row["state"]} #{row["rate_area"]}"
    else
      zips_hash[row["zipcode"]] = ["#{row["state"]} #{row["rate_area"]}"]
    end
  end
  zips_hash
end

def parse_plans
  plans_table = CSV.parse(File.read("plans.csv"), headers: true)
  plans_hash = {}
  plans_table.each do |row|
    next unless row["metal_level"] == "Silver"
    full_rate_area = "#{row["state"]} #{row["rate_area"]}"
    rate = row["rate"].to_f
    if plans_hash[full_rate_area]
      plans_hash[full_rate_area] << rate
    else
      plans_hash[full_rate_area] = [rate]
    end
  end
  plans_hash
end

def calculate_slcsp(zips, plans)
  rows = CSV.parse(File.read("slcsp.csv"), headers: true)
  rows.each do |row|
    zipcode = row["zipcode"]
    rate_areas = zips[zipcode]
    if rate_areas.nil? || rate_areas.uniq.size != 1
      row['rate'] = nil
    else
      rate_area = rate_areas.first
      rates_array = plans[rate_area]
      if rates_array
        rates_array = rates_array.uniq.sort
        rate = rates_array.length > 1 ? rates_array[1] : nil
        row['rate'] = rate
      else
        row['rate'] = nil
      end
    end
  end
  write_slcsp_to_csv(rows)
end

def write_slcsp_to_csv(rows)
  CSV.open("slcsp.csv", 'w', write_headers: true, headers: rows.headers) do |csv|
    rows.each do |row|
      csv << row
    end
  end
end

if __FILE__ == $0
  zips = parse_zips
  plans = parse_plans
  calculate_slcsp(zips, plans)
end
