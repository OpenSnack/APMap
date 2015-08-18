require 'fileutils'

class SitesController < ApplicationController

  def create
    # insert new site into database
    name = params['shortname_in']
    comment = params['sitename_in']

    unless Site.where(name: name).empty?
      return render inline: "$('#abbrev_warning').css('display','initial');"
    end
    unless Site.where(comment: comment).empty?
      return render inline: "$('#sitename_warning').css('display','initial');"
    end

    begin
      Site.create(name: name, comment: comment)
    rescue
      return render inline: "flashMessage('Error creating site: #{$!}');"
    end

    uuid = Site.find_by(name: name).uuid
    render inline: "window.location = '/show?site_select=#{uuid}'"
  end

  def update
    # update site in database with new name/comment
    uuid = params['site']
    name = params['edit_shortname_in']
    comment = params['edit_sitename_in']

    begin
      Site.update(uuid, name: name, comment: comment)
    rescue
      return render inline: "flashMessage('Error updating site: #{$!}');"
    end

    render inline: "location.reload();"
  end

  def destroy
    # remove site from database and remove its images folder
    begin
      Site.find(params['site']).destroy
    rescue
      return render inline: "flashMessage('Error removing site: #{$!}');"
    end
    begin
      FileUtils.rm_r "./public/images/maps/#{params['site']}"
    rescue
      return render inline: "flashMessage('Error while removing site: couldn't remove map directory')"
    end

    render inline: "window.location = '/start'"
  end
  
end