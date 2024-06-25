# for each zip code:
# find rate area (number and state) from zips file
# find silver plans for rate area in plans file
# store array of silver plans for rate area intermediantly? 
# find second lowest plan for rate from silver plans
# write that rate in original file

# if second lowest cost plan doesn't exist, leave cell blank
require 'csv'


def parse_zips
    zips_table = CSV.parse(File.read("zips.csv"), headers: true)
    # loop through starting at 1
    # create rails object with zip as key like {78757: "TX 1"}
    zips_hash = {}
    puts "in zips"
    zips_table.each do |row| 
        # if zip code appears more than once
        if zips_hash[row["zipcode"]]
            zips_hash[row["zipcode"]] = nil
        else
            zips_hash[row["zipcode"]] = "#{row["state"]} #{row["rate_area"]}"
        end
    end
# puts zips_hash
zips_hash
end
# parse zips csv

# puts zips_hash
def parse_plans
    plans_table = CSV.parse(File.read("plans.csv"), headers: true)
    # puts plans_table.first(10)
    plans_hash = {}
    plans_table.each do |row|
        # "TX 1": [798, 1045]
        # puts plans_hash[row]
        # puts plans_hash[row["state"]]
        next unless row["metal_level"] == "Silver"
        full_rate_area = "#{row["state"]} #{row["rate_area"]}"
        if plans_hash[full_rate_area] 
            plans_hash[full_rate_area] = plans_hash[full_rate_area] << row["rate"]
        else
            plans_hash[full_rate_area] = [row["rate"]]
        end  
    end
plans_hash
end 

def parse_slcsp(zips, plans)

    rows = CSV.parse(File.read("slcsp.csv"), headers: true)
    rows.each do |row|
        zipcode = row["zipcode"]
        puts zipcode
        rate_area = zips[zipcode]
        puts rate_area
        rates_array = plans[rate_area]
        puts "rates array #{rates_array}"
        rate = rates_array && rates_array.length > 0 ? plans[rate_area].sort[1] : nil
        puts "rate #{rate}"
        row['rate'] = rate
    end
    write_slcsp_to_csv(rows)
    puts rows
end

def write_slcsp_to_csv(rows)
    CSV.open("slcsp.csv", 'w') do |csv|
        # Write the headers
        csv << rows.headers

        # Write each row
        rows.each do |row|
            csv << row
        end
    end
end




if __FILE__ == $0
     zips = parse_zips
    puts zips
    plans = parse_plans
    slcsp = parse_slcsp(zips, plans)
    # write_slcsp_to_csv(slcsp)
end 