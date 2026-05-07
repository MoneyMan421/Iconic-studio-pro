class SecretCommunicationResult {
  final String uniqueEmojiSequence;
  final String shorthandMessage;
  final Map<String, String> codebook;

  const SecretCommunicationResult({
    required this.uniqueEmojiSequence,
    required this.shorthandMessage,
    required this.codebook,
  });
}

SecretCommunicationResult buildSecretCommunication(String input) {
  final emojis = _extractEmojiCharacters(input);
  final seen = <String>{};
  final unique = <String>[];

  for (final emoji in emojis) {
    if (seen.add(emoji)) {
      unique.add(emoji);
    }
  }

  final codebook = <String, String>{};
  for (var i = 0; i < unique.length; i++) {
    codebook[unique[i]] = _tokenForIndex(i);
  }

  final shorthand = unique.map((emoji) => codebook[emoji]!).join(' ');
  return SecretCommunicationResult(
    uniqueEmojiSequence: unique.join(),
    shorthandMessage: shorthand,
    codebook: codebook,
  );
}

List<String> _extractEmojiCharacters(String input) {
  final result = <String>[];
  for (final rune in input.runes) {
    if (_isLikelyEmojiRune(rune)) {
      result.add(String.fromCharCode(rune));
    }
  }
  return result;
}

bool _isLikelyEmojiRune(int rune) {
  return (rune >= 0x1F300 && rune <= 0x1FAFF) ||
      (rune >= 0x2600 && rune <= 0x27BF) ||
      (rune >= 0x1F1E6 && rune <= 0x1F1FF);
}

String _tokenForIndex(int index) {
  const syllables = [
    'ka',
    'zu',
    'mi',
    'ra',
    'to',
    'ne',
    'fi',
    'xo',
    'lu',
    've',
    'qi',
    'sa',
  ];
  final base = syllables[index % syllables.length];
  final round = (index ~/ syllables.length) + 1;
  return round == 1 ? base : '$base$round';
}
