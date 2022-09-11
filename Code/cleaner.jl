using Dates

# Expects: parse_album(pwd()*"/Blood Mountain/")
# To Do:
# Remove all instrumentals
# Break apart ands to separate things

function open_album(album)
	return album.*readdir(album)
end

function parse_album(album)
	songlist = open_album(album)
	parsed_songs = []
	for s in songlist
		open(s, "r") do songfile
			println("\nProcessing: "*s)
			song = read(songfile, String)
			song = replace(song, "\n\n"=>"--")
			song = replace(song, "\n"=>" ")
			songinfo = parse_song(song)
			append!(parsed_songs, [parse_song_title(s), songinfo])
		end
	end
	return [parse_album_title(album), parsed_songs]
end

function parse_song_title(t)
	t = split(t, "/")
	t = t[end]
	return t[1:end-4]
end

function parse_album_title(t)
	t = split(t, "/")
	return t[end-1]
end

function parse_song(song)
	phrases = get_phrases(song)
	parsed_phrases = []
	for phrase in phrases
		append!(parsed_phrases, [parse_phrase(phrase)])
	end
	return parsed_phrases
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
	return (parse_singer(phrase), parse_time(phrase), parse_words(phrase))
end

function parse_singer(phrase)
	brann = "Brann Dailor"
	brent = "Brent Hinds"
	troy = "Troy Sanders"
	if occursin(brann, phrase)
		return brann
	elseif occursin(brent, phrase)
		return brent
	elseif occursin(troy, phrase)
		return troy
	else
		return "Guest"
	end
end

function parse_time(phrase)
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

parse_album(pwd()*"/Blood Mountain/")
