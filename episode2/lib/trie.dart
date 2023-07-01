class _TrieNode {
  final Map<String, _TrieNode> children;
  late bool endOfWord;

  _TrieNode({
    this.endOfWord = false,
  }) : children = {};
}

///{@template trie}
///A tree data structure for storing strings
///and performing efficient string searches.
///{@endtemplate}
class Trie {
  late _TrieNode _root;

  ///{@macro trie}
  Trie() : _root = _TrieNode();

  ///Inserts [text] into trie.
  void insert(String text) {
    int length = text.length;
    _TrieNode node = _root;
    for (int i = 0; i < length; i++) {
      final char = text[i];
      if (node.children[char] == null) {
        final newNode = _TrieNode(endOfWord: i == length - 1);
        node.children[char] = newNode;
        node = newNode;
      } else {
        node = node.children[char]!;
      }
    }
    node.endOfWord = true;
  }

  int? _getLimit({int count = 0, int? limit}) {
    if (limit == null) return null;
    return limit - count;
  }

  ///Autocompletes [prefix] with suggestions from `trie`.
  ///If [limit] is not null, the returned list of suggestions
  ///will contain at most [limit] elements.
  List<String> autoComplete({required String prefix, int? limit}) {
    List<String> result = [];

    _TrieNode node = _root;
    int length = prefix.length;
    for (int i = 0; i < length; i++) {
      final char = prefix[i];
      if (node.children[char] == null) return [];
      node = node.children[char]!;
    }

    for (var char in node.children.keys) {
      final length = result.length;
      if (limit != null && length >= limit) break;
      _TrieNode? currentNode = node.children[char];
      if (currentNode == null || currentNode.endOfWord) {
        result.add(prefix + char);
        result.addAll(
          autoComplete(
            prefix: prefix + char,
            limit: _getLimit(limit: limit, count: length),
          ),
        );
      } else {
        result.addAll(
          autoComplete(
            prefix: prefix + char,
            limit: _getLimit(limit: limit, count: length),
          ),
        );
      }
    }

    if (limit != null) {
      return result.take(limit).toList()
        ..sort(
          (a, b) => a.length.compareTo(b.length),
        );
    }

    return result
      ..sort(
        (a, b) => a.length.compareTo(b.length),
      );
  }

  ///Clears trie.
  void clear() {
    _root = _TrieNode();
  }
}
