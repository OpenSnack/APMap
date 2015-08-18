require 'open-uri'
require 'thread'

module ApplicationHelper

  def get_ap_status(ap)
    # pull system information from the AP
    ap_jsonurl = "http://#{ap[0]}#{ap[2]}"
    ping = `ping -q -c 1 -t 1 #{ap[0]}`
    if $? != 0
      return {"apname": ap[3], "error": "ping timeout"}
    end
    begin
      ap_data = JSON.load(open(ap_jsonurl))
    rescue
      # couldn't connect for some reason
      return {"apname": ap[3], "error": $!.to_s}
    end

    # construct the dictionary for the info pane
    connections = 0
    ap_data["wifinets"].each do |w|
      w["networks"].each { |n| connections += n["assoclist"].size }
    end
    ap_up = [60,60,24].reduce([ap_data["uptime"]]) { |m,o| m.unshift(m.shift.divmod(o)).flatten }
    uptime = "#{ap_up[0]}d #{ap_up[1]}h #{ap_up[2]}m"
    r0_networks = ap_data["wifinets"][0]["networks"]
    r0_info = {"channel": "#{r0_networks[0]["channel"]} (#{r0_networks[0]["frequency"]} GHz)",
                "signal": r0_networks.map {|n| n["signal"]}.reduce(:+)/r0_networks.reject {|i| i["signal"]==0}.size.to_f,
                "quality": r0_networks.map {|n| n["quality"]}.reduce(:+)/r0_networks.reject {|i| i["signal"]==0}.size.to_f}
    r1_networks = ap_data["wifinets"][1]["networks"]
    r1_info = {"channel": "#{r1_networks[0]["channel"]} (#{r1_networks[0]["frequency"]} GHz)",
                "signal": r1_networks.map {|n| n["signal"]}.reduce(:+)/r1_networks.reject {|i| i["signal"]==0}.size.to_f,
                "quality": r1_networks.map {|n| n["quality"]}.reduce(:+)/r1_networks.reject {|i| i["signal"]==0}.size.to_f}
    return {"apname": ap[3], "hname": ap[0], "connections": connections, "uptime": uptime, "r0_info": r0_info, "r1_info": r1_info}
  end

  def ap_config(ap)
    # set up AP for viewing correctly
    ap[6] = get_ap_status(ap)
    if ap[6][:connections].nil?
      ap[6][:img] = "/images/ap/signal-down.png"
    else
      if ap[6][:connections] <= 15
        conn = "green"
      elsif ap[6][:connections] < 30
        conn = "yellow"
      else
        conn = "red"
      end
      valid_qual = [ap[6][:r0_info][:quality],ap[6][:r1_info][:quality]].reject {|i| i.nan?}
      if valid_qual.size == 2
        quality = valid_qual.reduce(:+)/valid_qual.size.to_f
      elsif valid_qual.size == 1
        quality = valid_qual[0]
      else
        quality = 0
      end
      if quality == 0
        qual = "0"
      elsif quality <= 25
        qual = "0-25"
      elsif quality <= 50
        qual = "25-50"
      elsif quality <= 75
        qual = "50-75"
      else
        qual = "75-100"
      end
      ap[6][:img] = "/images/ap/signal-#{qual}-#{conn}.png"
    end
  end
  
end