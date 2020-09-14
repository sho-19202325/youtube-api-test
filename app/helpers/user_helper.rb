module UserHelper
	def playlist_choice(user_playlist_items, user_playlists)
		playlist_choice = []
		user_playlist_items.keys.each do |item|
			playlist_choice << [
				item, user_playlists.find{|playlist| playlist["snippet"]["title"] == item}["id"]
			]
		end
		return playlist_choice
	end
end
