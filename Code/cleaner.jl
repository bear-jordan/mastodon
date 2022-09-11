using Dates
using DataFrames
using CSV

# To Do:
# Remove all instrumentals

function parse_dir(dir=pwd()*"/../Data/To Process/")
	albums = dir.*readdir(dir)
	mastodon = DataFrame(album=[], title=[], singer=[], timespan=[], lyrics=[], start_time=[], end_time=[])
	[append!(mastodon, parse_album(album)) for album in albums]
	return mastodon
end

function open_album(album)
	return album*"/".*readdir(album)
end

function parse_album(album)
	songlist = open_album(album)
	parsed_singer = []
	parsed_time = []
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
			singer, t, l, st, en = parse_song(song)
			ct = [clean_title for i in 1:length(singer)]
			append!(parsed_title, ct)
			append!(parsed_singer, singer)
			append!(parsed_time, t)
			append!(parsed_lyrics, l)
			append!(parsed_start, st)
			append!(parsed_end, en)
		end
	end
	clean_album_title = parse_album_title(album)
	parsed_album_title = [clean_album_title for i in 1:length(parsed_singer)]
	data = DataFrame(album=parsed_album_title, title=parsed_title, singer=parsed_singer, timespan=parsed_time, lyrics=parsed_lyrics, start_time=parsed_start, end_time=parsed_end)
	return(data)
end

function parse_song_title(t)
	t = split(t, "/")
	t = t[end]
	return t[1:end-4]
end

function parse_album_title(t)
	t = split(t, "/")
	return t[end]
end

function parse_song(song)
	phrases = get_phrases(song)
	parsed_singers = []
	parsed_times = []
	parsed_words = []
	parsed_start = []
	parsed_end = []
	for phrase in phrases
		singer, time, words, start_time, end_time = parse_phrase(phrase)
		append!(parsed_singers, [singer])
		append!(parsed_times, time)
		append!(parsed_words, [words])
		append!(parsed_start, start_time)
		append!(parsed_end, end_time)
	end

	return parsed_singers, parsed_times, parsed_words, parsed_start, parsed_end
end

function get_phrases(song)
	newline = "--"
	if occursin(newline, song)
		return split(song, newline)
	else
		error("file formatted incorrectly")
	end
end

function parse_phrase(phrase)
	return (parse_singer(phrase), parse_time_delta(phrase), parse_words(phrase), parse_start_time(phrase), parse_end_time(phrase))
end

function parse_singer(phrase)
	brann = "Brann Dailor"
	brent = "Brent Hinds"
	troy = "Troy Sanders"
	eric = "Eric Saner"
	scott = "Scott Kelly"
	if occursin(brann, phrase)
		return brann
	elseif occursin(brent, phrase)
		return brent
	elseif occursin(troy, phrase)
		return troy
	elseif occursin(eric, phrase)
		return eric
	elseif occursin(scott, phrase)
		return scott
	else
		return "Guest"
	end
end

function parse_time_delta(phrase)
	at = r"\d:\d\d"
	if occursin(at, phrase)
		matches = [m.match for m in eachmatch(at, phrase)]
		if length(matches) == 2
			t₁ = DateTime(matches[1], dateformat"MM:SS")
			t₂ = DateTime(matches[2], dateformat"MM:SS")
			return Dates.value(Dates.Second(t₂-t₁))
		else
			error("phrase parsed incorrectly: wrong number of timestamps")
		end
	else
		error("phrase parsed incorrectly: no timestamps")
	end
end

function parse_words(phrase)
	m = match(r"(?<=]).*(?=@)", phrase)
	return m.match
end

function parse_start_time(phrase)
	at = r"\d:\d\d"
	if occursin(at, phrase)
		matches = [m.match for m in eachmatch(at, phrase)]
		if length(matches) == 2
			return Dates.value(Dates.Second(DateTime(matches[1], dateformat"MM:SS")))
		else
			error("phrase parsed incorrectly: wrong number of timestamps")
		end
	else
		error("phrase parsed incorrectly: no timestamps")
	end
end

function parse_end_time(phrase)
	at = r"\d:\d\d"
	if occursin(at, phrase)
		matches = [m.match for m in eachmatch(at, phrase)]
		if length(matches) == 2
			return Dates.value(Dates.Second(DateTime(matches[2], dateformat"MM:SS")))
		else
			error("phrase parsed incorrectly: wrong number of timestamps")
		end
	else
		error("phrase parsed incorrectly: no timestamps")
	end
end

mastodon = parse_dir()

# CSV.write("../Data/discography.csv", mastodon)