class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create
  def create
    client_id = ENV['GITHUB_KEY']
    client_secret = ENV['GITHUB_SECRET']
    code = params[:code]

    conn = Faraday.new(url: 'https://github.com', headers: { 'Accept': 'application/json' })

    response = conn.post('/login/oauth/access_token') do |req|
      req.params['code'] = code
      req.params['client_id'] = client_id
      req.params['client_secret'] = client_secret
    end
    data = JSON.parse(response.body, symbolize_names: true)
    access_token = data[:access_token]

    conn = Faraday.new(
      url: 'https://api.github.com',
      headers: {
        'Authorization': "token #{access_token}"
      }
    )
    response = conn.get('/user')
    data = JSON.parse(response.body, symbolize_names: true)

    # @user = User.find_or_create_by(auth_hash)
    # require 'pry'; binding.pry
    # self.current_user = @user
    # redirect_to dashboard_path

    user = User.find_or_create_by(uid: data[:id])
    user.username = data[:login]
    user.uid = data[:id]
    user.token = access_token
    user.save
    session[:user_id] = user.id
    redirect_to dashboard_path
  end

  #  protected
  private

  def auth_hash
    request.env['omniauth.auth']
  end
end
