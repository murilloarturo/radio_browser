enum StationSearchOrder {
  name('name'),
  url('url'),
  homepage('homepage'),
  favicon('favicon'),
  tags('tags'),
  country('country'),
  state('state'),
  language('language'),
  votes('votes'),
  codec('codec'),
  bitrate('bitrate'),
  lastCheckOk('lastcheckok'),
  lastCheckTime('lastchecktime'),
  clickTimestamp('clicktimestamp'),
  clickCount('clickcount'),
  clickTrend('clicktrend'),
  changeTimestamp('changetimestamp'),
  random('random');

  const StationSearchOrder(this.apiValue);

  final String apiValue;
}
