class ApsController < ApplicationController

  include ApsHelper

  def create
    # insert new AP into database connected to the current site
    name = params['apname_in']
    hostname = params['hostname_in']
    uuid = params['site']
    weburl = params['weburl_in']
    jsonurl = params['jsonurl_in']

    unless Ap.where(name: name).empty?
      return render inline: "$('#name_warning').css('display','initial');"
    end
    unless Ap.where(hostname: hostname).empty?
      return render inline: "$('#host_warning').css('display','initial');"
    end

    begin
      Ap.create(site: uuid, hostname: hostname, weburl: weburl, jsonurl: jsonurl, name: name)
    rescue
      return render inline: "flashMessage('Error creating AP: #{$!}');"
    end

    render inline: "location.reload();"
  end

  def destroy
    # remove AP from the database
    @deleted_hostname = params['hostname']
    @deleted_uuid = params['site']

    begin    
      ap = Ap.find_by(hostname: @deleted_hostname, site: @deleted_uuid)
      @deleted_name = ap.name
      ap.destroy
    rescue
      return render inline: "flashMessage('Error removing AP: #{$!}');"
    end

    aps = Ap.where(site: @deleted_uuid).pluck(:hostname, :name)
    @ap_names = aps.map {|x| x[1]}
    @ap_hosts = aps.map {|x| x[0]}
    render inline: "$('##{sanitize(@deleted_hostname)}')[0].remove();"
  end

end