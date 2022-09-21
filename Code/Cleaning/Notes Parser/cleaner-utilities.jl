function get_phrases(song)
	newline = "--"
	if occursin(newline, song)
		return split(song, newline)
	else
		error("file formatted incorrectly")
	end
end

function open_album(album)
	return album*"/".*readdir(album)
end

function parse_album_title(t)
	t = split(t, "/")

	return t[end]
end

function parse_singer(phrase)
	brann = "Brann Dailor"
	brent = "Brent Hinds"
	troy = "Troy Sanders"
	eric = "Eric Saner"
	scott = "Scott Kelly"
	if occursin(brann, phrase)
		return [brann]
	elseif occursin(brent, phrase)
		return [brent]
	elseif occursin(troy, phrase)
		return [troy]
	elseif occursin(eric, phrase)
		return [eric]
	elseif occursin(scott, phrase)
		return [scott]
	else
		return ["Guest"]
	end
end

function parse_song_title(t)
	t = split(t, "/")
	t = t[end]
	t = t[1:end-4]

	return t
end

function parse_time(phrase, time)
	at = r"\d:\d\d"
	if occursin(at, phrase)
		matches = [m.match for m in eachmatch(at, phrase)]
		if length(matches) == 2
			if time == "start"
				return [matches[1]]
			elseif time == "end"
				return [matches[2]]
			else
				error("phrase parsed incorrectly: wrong time parameter")
			end
		else
			error("phrase parsed incorrectly: wrong number of timestamps")
		end
	else
		error("phrase parsed incorrectly: no timestamps")
	end
end

function parse_words(phrase)
	m = match(r"(?<=]).*(?=@)", phrase)
	return [m.match]
end
