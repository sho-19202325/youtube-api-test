class UserController < ApplicationController
  def show
    @subscribed = subscribed?("UCHp2q2i85qt_9nn2H7AvGOw")
    @channel_movies = get_channel_movies("UCHp2q2i85qt_9nn2H7AvGOw")
    @user_playlists = get_user_playlists
  end
  
    private
  
    def api_call(type, part, opt, auth=false)
      uri = URI("https://www.googleapis.com/youtube/v3/" + type + "?part=" + part + "&" + opt)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      req = Net::HTTP::Get.new(uri)
      req["Authorization"] = "Bearer #{current_user.access_token}" if auth
      res = http.request(req)
      res_data=JSON.parse(res.body)
    end
  
    def subscribed?(channelId)
      query = {
        mine: true,
        maxResults: 50
      }.to_query
      subscriptions = api_call("subscriptions", "snippet", query, true)["items"]
      subscriptions.each do |subscription|
        return true if subscription["snippet"]["resourceId"]["channelId"] == channelId
      end
      false
    end

    def get_channel_movies(channel_id)
      query = {
        channel_id: channel_id,
        maxResults: 50
      }.to_query

      activities = api_call("activities", "snippet,contentDetails", query, true)["items"]
      activities.select{ |activity| activity["snippet"]["type"] == "upload"}
    end

    def get_user_playlists
      query = {
        mine: true,
        maxResults: 50
      }.to_query
      playlists = api_call("playlists", "id,snippet", query, true)["items"]
    end
end