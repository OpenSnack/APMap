class SessionsController < ApplicationController
  def new
    if logged_in?
      # because no one likes logging in more than once
      redirect_to '/show'
    end
  end

  def create
    ldap = Net::LDAP.new host: "ldap.gsacrd.ab.ca",
              port: 389,
              auth: {method: :simple, 
                    username:"uid=#{params[:session][:name]},ou=lts,ou=staff,ou=people,o=gsacrd,c=ca",
                    password: params[:session][:password]}
    if ldap.bind
      # log in
      log_in params[:session][:name]
      redirect_to '/start'
    else
      # error
      flash.now[:danger] = ldap.get_operation_result.message
      render 'new'
    end
  end

  def destroy
    log_out
    redirect_to '/login'
  end

end
