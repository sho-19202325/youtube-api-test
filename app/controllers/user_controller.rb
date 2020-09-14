class UserController < ApplicationController
  before_action :check_authorized

  def show
    niziu_channel_id = "UCHp2q2i85qt_9nn2H7AvGOw"
    niziu_uploadlist_id = "UUHp2q2i85qt_9nn2H7AvGOw"
    jyp_channel_id = "UCaO6TYtlC8U5ttz62hTrZgg"
    jyp_uploadlist_id = "UUaO6TYtlC8U5ttz62hTrZgg"

    @niziu_subscribed = subscribed?(niziu_channel_id)
    @jyp_subscribed = subscribed?(jyp_channel_id)

    @niziu_channel_movies = get_channel_movies(niziu_uploadlist_id)
    niziu_channel_movie_ids = @niziu_channel_movies.map{|movie| movie["snippet"]["resourceId"]["videoId"]}
    niziu_channel_movie_rates = get_rating(niziu_channel_movie_ids)

    @jyp_channel_movies = get_channel_movies(jyp_uploadlist_id).select{|movie| movie["snippet"]["title"].include?("Nizi")}
    jyp_channel_movie_ids = @jyp_channel_movies.map{|movie| movie["snippet"]["resourceId"]["videoId"]}
    jyp_channel_movie_rates = get_rating(jyp_channel_movie_ids)
    
    @user_rates = niziu_channel_movie_rates.merge(jyp_channel_movie_rates)
    @user_playlists = get_user_playlists
    @user_playlist_items = {}
    if @user_playlists.present?
      @user_playlists.each do |p|
        @user_playlist_items[p["snippet"]["title"]] = get_playlist_items(p["id"]).map{|item| item["snippet"]["title"] }
      end
    end
    @user_channel = get_user_channel
  end

  def like
    query = {
      id: params[:video_id],
      rating: "like"
    }.to_query

    api_post("videos/rate", "", query, {})
    redirect_to user_root_url(current_user)
  end

  def add_playlist_item
    request_body = {
      "snippet": {
        "resourceId": {
          "kind": "youtube#video",
          "videoId": params[:video_id]
        },
        "playlistId": params[:playlist_id]
      }
    }
    api_post("playlistItems", "snippet", "", request_body)
    redirect_to user_root_url(current_user)
  end

  def create_playlist
    request_body = {
      "snippet": {
        "title": params[:title]
      }
    }
    
    api_post("playlists", "snippet", "", request_body)
    redirect_to user_root_url(current_user)
  end

  # def subscribe
  #   params = {
  #     "snippet": {
  #       "resourceId": {
  #         "kind": "youtube#channel",
  #         "channelId": "UCHp2q2i85qt_9nn2H7AvGOw"
  #       }
  #     }
  #   }
  #   api_post("subscriptions", "snippet", params)
  #   redirect_to root_path
  # end

  
  
  private
  
    def api_call(type, part, opt)
      uri = URI("https://www.googleapis.com/youtube/v3/" + type + "?part=" + part + "&" + opt)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      req = Net::HTTP::Get.new(uri)
      req["Authorization"] = "Bearer #{current_user.access_token}"
      res = http.request(req)
      res_data=JSON.parse(res.body)
    end

    def api_post(type, part, opt, params)
      uri = URI("https://www.googleapis.com/youtube/v3/" + type + "?part=" + part + "&" + opt)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      headers = {
        "Authorization": "Bearer #{current_user.access_token}",
        "Content-Type": "application/json"
      }
      res = http.post(uri, params.to_json, headers)
      res_data = JSON.parse(res.body)
    end
  
    def subscribed?(channelId)
      query = {
        mine: true,
        maxResults: 50
      }.to_query
      subscriptions = api_call("subscriptions", "snippet", query)["items"]
      subscriptions.each do |subscription|
        return true if subscription["snippet"]["resourceId"]["channelId"] == channelId
      end
      false
    end

    def get_channel_movies(playlist_id)
      query = {
        playlist_id: playlist_id,
        maxResults: 50,
      }.to_query

      uploadlist_items = api_call("playlistItems", "snippet", query)
      channel_movies = uploadlist_items["items"]
      nextPageToken = uploadlist_items["nextPageToken"]
      while nextPageToken.present?
        query += "&pageToken=" + nextPageToken
        next_page_response = api_call("playlistItems", "snippet", query)
        channel_movies.concat(next_page_response["items"])
        nextPageToken = next_page_response["nextPageToken"]
      end
      return channel_movies
    end

    def get_user_playlists
      query = {
        mine: true,
        maxResults: 50
      }.to_query
      playlists = api_call("playlists", "id,snippet", query)["items"]
    end

    def get_user_channel
      query = {
        mine: true,
      }.to_query
      user_channel = api_call("channels", "snippet", query)["items"]
    end

    def get_playlist_items(playlist_id)
      query = {
        playlistId: playlist_id,
        maxResults: 50
      }.to_query
      playlistItems = api_call("playlistItems", "snippet", query)["items"]
    end

    def get_rating(ids)
      rates = {}
      until ids.length == 0
        query = { id: ids.pop(50).join(",") }.to_query
        get_rating_items = api_call("videos/getRating", "", query)["items"]
        get_rating_items.each do |item|
          rates[item["videoId"]] = item["rating"]
        end
      end
      return rates
    end

    def check_authorized
      if !current_user.present? || !current_user.valid_access_token?
        redirect_to root_url
      end
    end
end