enum Localizable {
  appTitle,
  discoverTab,
  aiFinderTab,
  favoritesTab,
  favoritesTitle,
  searchWithAiHint,
  recommendedForYou,
  aiRecommendationLoadingTitle,
  aiRecommendationLoadingMessage,
  aiRecommendationEmptyTitle,
  aiRecommendationEmptyMessage,
  play,
  playStation,
  pauseStation,
  resumeStation,
  addFavorite,
  removeFavorite,
  noStationsFoundTitle,
  noStationsForFilterMessage,
  noStationsForSearchMessage,
  stationsCouldNotLoadTitle,
  pleaseTryAgainMessage,
  retry,
  dismissMessage,
  untaggedStation,
  listeningFallback,
  recommendationTemplate,
  bitrateKbpsTemplate,
  metadataSeparator,
  listSeparator,
  discoverFilterPopular,
  discoverFilterSpain,
  discoverFilterJazz,
  discoverFilterNews,
  discoverFilterRock,
  playbackFailed,
  noConnectionTitle,
  noConnectionMessage,
  noFavoritesTitle,
  noFavoritesMessage,
  aiSearchUnavailable,
  voiceSearchStart,
  voiceSearchStop,
  voiceSearchListening,
  voiceSearchProcessing,
  nowPlayingTitle,
  collapsePlayer,
  playerOptions,
  stop,
  favorite,
  savedFavorite,
  volume,
  similarStations,
  seeAll,
  previousStation,
  nextStation,
}

class Localizables {
  Localizables._();

  static const Map<Localizable, String> _english = {
    Localizable.appTitle: 'RadioBrowser',
    Localizable.discoverTab: 'Discover',
    Localizable.aiFinderTab: 'AI Finder',
    Localizable.favoritesTab: 'Favorites',
    Localizable.favoritesTitle: 'Favorites',
    Localizable.searchWithAiHint: 'Search with AI',
    Localizable.recommendedForYou: 'Recommended for you',
    Localizable.aiRecommendationLoadingTitle: 'Finding AI suggestions',
    Localizable.aiRecommendationLoadingMessage:
        'Personalized station picks will appear here in a moment.',
    Localizable.aiRecommendationEmptyTitle: 'AI suggestions will appear here',
    Localizable.aiRecommendationEmptyMessage:
        'Add your OpenAI key and refresh to see personalized radio picks.',
    Localizable.play: 'Play',
    Localizable.playStation: 'Play station',
    Localizable.pauseStation: 'Pause station',
    Localizable.resumeStation: 'Resume station',
    Localizable.addFavorite: 'Add favorite',
    Localizable.removeFavorite: 'Remove favorite',
    Localizable.noStationsFoundTitle: 'No stations found',
    Localizable.noStationsForFilterMessage: 'Try another filter.',
    Localizable.noStationsForSearchMessage: 'Try another search term.',
    Localizable.stationsCouldNotLoadTitle: 'Stations could not load',
    Localizable.pleaseTryAgainMessage: 'Please try again.',
    Localizable.retry: 'Retry',
    Localizable.dismissMessage: 'Dismiss message',
    Localizable.untaggedStation: 'Untagged',
    Localizable.listeningFallback: 'listening',
    Localizable.recommendationTemplate: '"Great for {value}"',
    Localizable.bitrateKbpsTemplate: '{value} kbps',
    Localizable.metadataSeparator: ' - ',
    Localizable.listSeparator: ', ',
    Localizable.discoverFilterPopular: 'Popular',
    Localizable.discoverFilterSpain: 'Spain',
    Localizable.discoverFilterJazz: 'Jazz',
    Localizable.discoverFilterNews: 'News',
    Localizable.discoverFilterRock: 'Rock',
    Localizable.playbackFailed: 'Station could not play.',
    Localizable.noConnectionTitle: 'No internet connection',
    Localizable.noConnectionMessage:
        'Once you are connected again, your stations will be right here.',
    Localizable.noFavoritesTitle: 'No favorite stations yet',
    Localizable.noFavoritesMessage:
        'Tap the heart on any station to keep it here for later.',
    Localizable.aiSearchUnavailable:
        'AI search needs an OpenAI API key to be enabled.',
    Localizable.voiceSearchStart: 'Start voice search',
    Localizable.voiceSearchStop: 'Stop voice search',
    Localizable.voiceSearchListening: 'Listening...',
    Localizable.voiceSearchProcessing: 'Transcribing...',
    Localizable.nowPlayingTitle: 'Now Playing',
    Localizable.collapsePlayer: 'Collapse player',
    Localizable.playerOptions: 'Player options',
    Localizable.stop: 'Stop',
    Localizable.favorite: 'Favorite',
    Localizable.savedFavorite: 'Saved',
    Localizable.volume: 'Volume',
    Localizable.similarStations: 'Similar Stations',
    Localizable.seeAll: 'See all',
    Localizable.previousStation: 'Previous station',
    Localizable.nextStation: 'Next station',
  };

  static Map<Localizable, String> _dictionary = _english;

  static void load(Map<Localizable, String> dictionary) {
    _dictionary = <Localizable, String>{..._english, ...dictionary};
  }

  static void reset() {
    _dictionary = _english;
  }

  static String resolve(Localizable key) {
    return _dictionary[key] ?? key.name;
  }
}

extension LocalizableText on Localizable {
  String get text => Localizables.resolve(this);

  String format(Map<String, Object> values) {
    return values.entries.fold(text, (resolved, entry) {
      return resolved.replaceAll('{${entry.key}}', entry.value.toString());
    });
  }
}
