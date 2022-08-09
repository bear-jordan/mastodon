import requests
from bs4 import BeautifulSoup as bs
import re
import json
import os
from urllib.error import HTTPError

class BearerAuth(requests.auth.AuthBase):
    def __init__(self, token):
        self.token = token
    def __call__(self, r):
        r.headers["authorization"] = "Bearer " + self.token
        return r

class GeniusUtils:

    def __init__(self, api_key:str):
        self.api_key=api_key


    def get_songs(self, artist_id:str) -> list:
        """
        For a given aritst id, return a list of their song ids

        :param string artist_id: a numerical artist_id
        :rtype: list
            return a list of dicts, one dict per cast member with the following structure:
                [{'annotation_count': 1,
                  'api_path': '/songs/1951215',
                  'artist_names': 'Mastodon',
                  'full_title': 'A Commotion by\xa0Mastodon',
                  'header_image_thumbnail_url': 'https://images.genius.com/3b788ceddf73741e336596ccfdbb43b5.300x300x1.jpg',
                  'header_image_url': 'https://images.genius.com/3b788ceddf73741e336596ccfdbb43b5.1000x1000x1.jpg',
                  'id': 1951215,
                  'lyrics_owner_id': 6578,
                  'lyrics_state': 'complete',
                  'path': '/Mastodon-a-commotion-lyrics',
                  'pyongs_count': None,
                  'song_art_image_thumbnail_url': 'https://images.genius.com/3b788ceddf73741e336596ccfdbb43b5.300x300x1.jpg',
                  'song_art_image_url': 'https://images.genius.com/3b788ceddf73741e336596ccfdbb43b5.1000x1000x1.jpg',
                  'stats': {
                    'unreviewed_annotations': 0,
                    'hot': False
                  },
                  'title': 'A Commotion',
                  'title_with_featured': 'A Commotion',
                  'url': 'https://genius.com/Mastodon-a-commotion-lyrics',
                  'primary_artist': {
                    'api_path': '/artists/14779',
                    'header_image_url': 'https://images.genius.com/e22938b32209419e5339d144c4f2c192.820x546x1.jpg',
                    'id': 14779,
                    'image_url': 'https://images.genius.com/cb15974b52b713c0d4449af0589ecff7.1000x1000x1.jpg',
                    'is_meme_verified': False,
                    'is_verified': False,
                    'name': 'Mastodon',
                    'url': 'https://genius.com/artists/Mastodon'
                  }
                }, ...]
        """
        try:
            Response = requests.get(f'https://api.genius.com/artists/{artist_id}/songs?per_page=50', auth=BearerAuth(self.api_key))
        except HTTPError:
            print(f'Artist "{artist_id}" not found')
            return []
        else:         
            Songs = Response.json()
            ReturnList = []
            i=0
            while Songs['response']['next_page']:
                i+=1
                try:
                    Response = requests.get(f'https://api.genius.com/artists/{artist_id}/songs?per_page=50&page={i}', auth=BearerAuth(self.api_key))
                except HTTPError:
                    print(f'Song page {i} of "{artist_id}" not found')
                    print('Do they have less than 50 songs?')
                    return []
                else:         
                    Songs = Response.json()
                    for song in Songs['response']['songs']:
                        Entry = {'artists': song['artist_names'],
                                 'title': song['title'],
                                 'url': song['url']}
                        ReturnList.append(Entry)

        return ReturnList

    def get_lyrics(self, song_url:str) -> str:
        """
        For a given aritst id, return a list of their song ids

        :param string artist_id: a numerical artist_id
        :rtype: 
        """
        try:
            Response = requests.get(song_url)
        except HTTPError:
            print(f'Unable to reach "{song_url}" not found')
            return ''
        else:         
            Page = Response.content
            Soup = bs(Page, 'html.parser')
            try:
                return Soup.find('div', class_=re.compile("^lyrics$|Lyrics__Root")).get_text()
            except:
                return 'na'
        return Lyrics    


# These values were found after an initial search, regex was used to filter live songs out
MASTADON_ID = '14779'
MASTADON_SONG_LIST = ['A Commotion',
                      'All the Heavy Lifting',
                      'Ancient Kingdom',
                      'Andromeda',
                      'Aqua Dementia',
                      'Asleep in the Deep',
                      'A Spoonful Weighs a Ton',
                      'Atlanta',
                      'Aunt Lisa',
                      'Battle at Sea',
                      'Bedazzled Fingernails',
                      'Black Tongue',
                      'Bladecatcher',
                      'Blasteroid',
                      'Blood and Thunder',
                      'Blue Walsh',
                      'Burning Man',
                      'Call of the Mastodon',
                      'Capillarian Crest',
                      'Chimes at Midnight',
                      'Circle of Cysquatch',
                      'Clandestiny',
                      'Clayton Boys',
                      'Cold Dark Place',
                      'Colony of Birchmen',
                      'Crack the Skye',
                      'Creature Lives',
                      'Crusher Destroyer',
                      'Crystal Skull',
                      'Curl of the Burl',
                      'Cut You Up with a Linoleum Knife',
                      'Dagger',
                      'Deathbound',
                      'Death March',
                      'Deep Sea Creature',
                      'Diamond in the Witch House',
                      'Divinations',
                      'Down Like That',
                      'Dry Bone Valley',
                      'Elephant Man',
                      'Ember City',
                      'Emerald',
                      'Eyes of Serpents',
                      'Fallen Torches',
                      'Feast Your Eyes',
                      'Forged By Neron',
                      'Ghost of Karelia',
                      'Gigantium',
                      'Gobblers of Dregs',
                      'Had It All',
                      'Hail to Fire',
                      'Halloween',
                      'Hand of Stone',
                      'Hearts Alive',
                      'High Road',
                      'Hunters of the Sky',
                      'I Am Ahab',
                      'Indian Theme',
                      'Iron Tusk',
                      'Island',
                      'Jaguar God',
                      'Joseph Merrick',
                      'Just Got Paid',
                      'March of the Fire Ants',
                      'Megalodon',
                      'More Than I Could Chew',
                      'Mother Puncher',
                      'Naked Burn',
                      'North Side Star',
                      'Oblivion',
                      'Octopus Has No Friends',
                      'Ol’e Nessie',
                      'Once More ’Round the Sun',
                      'Orion',
                      'Pain with an Anchor',
                      'Peace and Tranquility',
                      'Pendulous Skin',
                      'Precious Stones',
                      'Pushing the Tides',
                      'Quintessence',
                      'Roots Remain',
                      'Rufus Lives',
                      'Savage Lands',
                      'Scorpion Breath',
                      'Seabeast',
                      'Shadows That Move',
                      'Show Yourself',
                      'Siberian Divide',
                      'Sickle and Peace',
                      'Skeleton of Splendor',
                      'Sleeping Giant',
                      'Slickleg',
                      'Spectrelight',
                      'Stairway to Heaven',
                      'Stargasm',
                      'Steambreather',
                      'Sultan’s Curse',
                      'Teardrinker',
                      'Thank You for This',
                      'The Beast',
                      'The Bit',
                      'The Crux',
                      'The Czar',
                      'The Hunter',
                      'The Last Baron',
                      'The Motherload',
                      'The Ruiner',
                      'The Sparrow',
                      'The Wolf Is Loose',
                      'Thickening',
                      'This Mortal Soil',
                      'Toe to Toes',
                      'Train Assault',
                      'Trainwreck',
                      'Trampled Under Hoof',
                      'Tread Lightly',
                      'Trilobite',
                      'We Built This Come Death',
                      'Welcoming War',
                      'Where Strides the Behemoth',
                      'White Walker',
                      'Word to the Wise',
                      'Workhorse']

if __name__ == '__main__':
    os.chdir('/Users/bear/Documents/Projects/Mastadon/Genius API')
    GUtils = GeniusUtils(api_key='YBVxVTreKgN210WeC0_D6fX8cnnP01YmFftoaO-dAN7XpA7STr4GEcN8CDzkUBAw')
    DirtySongs = GUtils.get_songs(MASTADON_ID)
    with open('./Output/raw_lyrics.txt', 'a') as output:
        for song in DirtySongs:
            if song['title'] in MASTADON_SONG_LIST:
                print(f'Starting {song["title"]}')
                song['lyrics'] = GUtils.get_lyrics(song['url']) 
                output.write(f'{json.dumps(song)}\n\n')
                print('   song complete')

