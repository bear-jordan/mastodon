using Dates
using DataFrames
using CSV

include("./cleaner-utilities.jl")

function parse_dir(dir=pwd()*"/../../../Data/Raw Data/")
	albums = dir.*readdir(dir)
	mastodon = DataFrame(album=[], title=[], singer=[], lyrics=[], start_time=[], end_time=[])
	[append!(mastodon, parse_album(album)) for album in albums]
	return mastodon
end

function parse_album(album)
	songlist = open_album(album)
	parsed_singer = []
	parsed_lyrics = []
	parsed_title = []
	parsed_start = []
	parsed_end = []

	for s in songlist
		open(s, "r") do songfile
			clean_title = parse_song_title(s)
			println("\nProcessing: "*clean_title)
			song = read(songfile, String)
			song = replace(song, "\n\n"=>"--")
			song = replace(song, "\n"=>" ")
			singer, l, st, en = parse_song(song)
			ct = [clean_title for i in 1:length(singer)]
			append!(parsed_singer, singer)
			append!(parsed_title, ct)
			append!(parsed_lyrics, l)
			append!(parsed_start, st)
			append!(parsed_end, en)
		end
	end

	clean_album_title = parse_album_title(album)
	parsed_album_title = [clean_album_title for i in 1:size(parsed_title)[1]]
	data = DataFrame(album=parsed_album_title, title=parsed_title, singer=parsed_singer, lyrics=parsed_lyrics, start_time=parsed_start, end_time=parsed_end)
	return(data)
end

function parse_song(song)
	phrases = get_phrases(song)
	parsed_singers = []
	parsed_words = []
	parsed_start = []
	parsed_end = []
	for phrase in phrases
		append!(parsed_singers, parse_singer(phrase))
		append!(parsed_words, parse_words(phrase))
		append!(parsed_start, parse_time(phrase, "start"))
		append!(parsed_end, parse_time(phrase, "end"))
	end

	return parsed_singers, parsed_words, parsed_start, parsed_end
end


mastodon = parse_dir()
println("\n== Complete ==\nData stored to 'mastodon' variable.")
CSV.write("/../../../Data/discography.csv", mastodon)