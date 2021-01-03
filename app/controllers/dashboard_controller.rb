class DashboardController < ApplicationController
  def show
    access_token = current_user.token
    response = Faraday.get('https://api.github.com/user/repos', {}, { 'Authorization': "token #{access_token}" })
    require 'pry'; binding.pry
    repos = JSON.parse(response.body, symbolize_names: true)
    @public_repos = repos.select { |repo| repo[:private] == false }
    @private_repos = repos.select { |repo| repo[:private] == true }
    # require 'pry'; binding.pry
  end
end
