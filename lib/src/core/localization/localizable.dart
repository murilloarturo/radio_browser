enum Localizable {
  appTitle,
  discoverTab,
  aiFinderTab,
  favoritesTab,
  searchWithAiHint,
  recommendedForYou,
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
}

class Localizables {
  Localizables._();

  static const Map<Localizable, String> _english = {
    Localizable.appTitle: 'RadioBrowser',
    Localizable.discoverTab: 'Discover',
    Localizable.aiFinderTab: 'AI Finder',
    Localizable.favoritesTab: 'Favorites',
    Localizable.searchWithAiHint: 'Search with AI',
    Localizable.recommendedForYou: 'Recommended for you',
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
