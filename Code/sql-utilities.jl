using DataFrames
using CSV

function get_song_data()
	return CSV.read("../Data/songs.csv", DataFrame)
end

function get_member_data()
	return CSV.read("../Data/members.csv", DataFrame)
end

function format_phrase_entries(data)
	"""
	Return values to for an insert statement in sql.
	Format: id, song_id, member_id, start_time, end_time, lyrics
	"""
	songs = get_song_data()
	joined = leftjoin(songs, data, on = [:track_name => :title])
	rename!(joined, :id => :song_id)

	members = get_member_data()
	joined = leftjoin(joined, members, on = [:singer => :member]; matchmissing=:equal)
	rename!(joined, :id => :member_id)
	
	return select(joined, [:song_id, :member_id, :start_time, :end_time, :lyrics])
end

# phrases = format_phrase_entries(mastodon)
# CSV.write("../Data/phrases.csv", phrases)