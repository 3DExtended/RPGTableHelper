import 'dart:math';

/// Copyright notice: Copied and translated from here: https://github.com/farzher/fuzzysort/blob/master/fuzzysort.js

class Fuzzysort {
  Map<String, FuzzySearchPreparedTarget> preparedCache = {};
  Map<String, PreparedSearch> preparedSearchCache = {};

  List<int> matchesSimple = [];
  List<int> matchesStrict = [];
  List<int> nextBeginningIndexesChanges = [];
  List<int> keysSpacesBestScores = [];
  List<double> allowPartialMatchScores = [];
  Set<int> seenIndexes = {};
  int changeslen = 0;

  FuzzySearchPreparedTarget getPrepared(
      String targetIdentifier, String target) {
    if (target.length > 999) {
      return prepare(target, targetIdentifier); // don't cache huge targets
    }
    var targetPrepared = preparedCache[target];
    if (targetPrepared != null) return targetPrepared;

    targetPrepared = prepare(target, targetIdentifier);
    preparedCache[target] = targetPrepared;
    return targetPrepared;
  }

  PreparedSearch getPreparedSearch(String search) {
    if (search.length > 999) {
      return prepareSearch(search); // don't cache huge searches
    }
    var searchPrepared = preparedSearchCache[search];
    if (searchPrepared != null) return searchPrepared;

    searchPrepared = prepareSearch(search);
    preparedSearchCache[search] = searchPrepared;
    return searchPrepared;
  }

  // Placeholder queue class for maintaining the results
  final List<FuzzySearchResult> q = [];

  List<FuzzySearchResult> go(String search,
      List<FuzzySearchPreparedTarget> targets, Map<String, dynamic>? options) {
    var preparedSearch = getPreparedSearch(search);
    var searchBitflags = preparedSearch.bitflags;

    var threshold = denormalizeScore(options?['threshold'] ?? 0.0);
    var limit = options?['limit'] ?? double.infinity;

    var resultsLen = 0;
    var targetsLen = targets.length;

    void pushResult(FuzzySearchResult result) {
      if (resultsLen < limit) {
        q.add(result);
        ++resultsLen;
      } else {
        if (result.score > q[0].score) {
          q.sort((a, b) => a.score.compareTo(b.score));
          q.removeAt(0);

          q.add(result);
        }
      }
    }

    for (var i = 0; i < targetsLen; ++i) {
      var target = targets[i];
      if (!preparedCache.containsKey(target.target)) {
        target = getPrepared(
          target.identifier,
          target.target,
        );
      }

      if ((searchBitflags & target.bitFlags) != searchBitflags) continue;
      var result = algorithm(preparedSearch, target, true, true);
      if (result == null) continue;
      if (result.score < threshold) continue;

      pushResult(result);
    }

    if (resultsLen == 0) return [];

    List<FuzzySearchResult> results = [];
    for (var i = resultsLen - 1; i >= 0; --i) {
      q.sort((a, b) => a.score.compareTo(b.score));
      results.add(q.removeAt(0));
    }

    return results;
  }

  // Main algorithm
  FuzzySearchResult? algorithm(
      PreparedSearch preparedSearch,
      FuzzySearchPreparedTarget prepared,
      bool allowSpaces,
      bool allowPartialMatch) {
    if (!allowSpaces && preparedSearch.containsSpace) {
      return algorithmSpaces(preparedSearch, prepared, allowPartialMatch);
    }

    List<int> searchLowerCodes = preparedSearch.lowerCodes;
    if (searchLowerCodes.isEmpty) return null;

    int searchLowerCode = searchLowerCodes[0];
    List<int> targetLowerCodes = prepared.targetLowerCodes ?? [];
    int searchLen = searchLowerCodes.length;
    int targetLen = targetLowerCodes.length;
    int searchI = 0;
    int targetI = 0;
    matchesSimple = [];

    // Walk through target, find sequential matches
    while (true) {
      bool isMatch = targetLowerCodes.length > targetI &&
          searchLowerCode == targetLowerCodes[targetI];
      if (isMatch) {
        matchesSimple.add(targetI);
        searchI++;
        if (searchI == searchLen) break;
        searchLowerCode = searchLowerCodes[searchI];
      }
      targetI++;
      if (targetI >= targetLen) return null; // Failed to find searchI
    }

    bool successStrict = false;
    searchI = 0;

    List<int>? nextBeginningIndexes = prepared.nextBeginningIndexes;
    nextBeginningIndexes ??= prepared.nextBeginningIndexes =
        prepareNextBeginningIndexes(prepared.target);

    targetI =
        matchesSimple[0] == 0 ? 0 : nextBeginningIndexes[matchesSimple[0] - 1];

    // Strict matching logic
    while (targetI < targetLen) {
      bool isMatch = searchLowerCodes[searchI] == targetLowerCodes[targetI];
      if (isMatch) {
        matchesStrict.add(targetI);
        searchI++;
        if (searchI == searchLen) {
          successStrict = true;
          break;
        }
        targetI++;
      } else {
        targetI = nextBeginningIndexes[targetI];
      }
    }

    // Substring matching
    int substringIndex = (searchLen <= 1)
        ? -1
        : prepared.targetLower.indexOf(preparedSearch.lower, matchesSimple[0]);
    bool isSubstring = substringIndex != -1;
    // assert(prepared.nextBeginningIndexes != null);
    bool isSubstringBeginning = isSubstring &&
        (substringIndex == 0 ||
            prepared.nextBeginningIndexes![substringIndex - 1] ==
                substringIndex);

    // Adjust score for best match
    if (isSubstring && !isSubstringBeginning) {
      for (int i = 0;
          i < nextBeginningIndexes.length;
          i = nextBeginningIndexes[i]) {
        if (i <= substringIndex) continue;
        for (int s = 0; s < searchLen; s++) {
          assert(prepared.targetLowerCodes != null);

          if (searchLowerCodes[s] != prepared.targetLowerCodes![i + s]) break;
          if (s == searchLen - 1) {
            substringIndex = i;
            isSubstringBeginning = true;
            break;
          }
        }
      }
    }

    // Calculate final score
    double score = calculateScore(
        successStrict,
        matchesSimple,
        matchesStrict,
        nextBeginningIndexes,
        isSubstring,
        isSubstringBeginning,
        searchLen,
        targetLen,
        prepared);

    FuzzySearchResult result = FuzzySearchResult(
        target: prepared.target,
        targetIdentifier: prepared.identifier,
        score: score,
        indexes: matchesSimple);

    return result;
  }

  // Function to handle spaces
  FuzzySearchResult? algorithmSpaces(PreparedSearch preparedSearch,
      FuzzySearchPreparedTarget target, bool allowPartialMatch) {
    seenIndexes.clear();
    double score = 0;
    FuzzySearchResult? result;

    int firstSeenIndexLastSearch = 0;
    List<PreparedSearch> searches = preparedSearch.spaceSearches;
    int searchesLen = searches.length;
    bool hasAtLeast1Match = false;

    allowPartialMatchScores = List.filled(searchesLen, double.negativeInfinity);
    for (int i = 0; i < searchesLen; i++) {
      PreparedSearch search = searches[i];

      result = algorithm(search, target, true, allowPartialMatch);
      if (allowPartialMatch) {
        if (result == null) continue;
        hasAtLeast1Match = true;
      } else {
        if (result == null) {
          for (var i = changeslen - 1; i >= 0; i--) {
            target.nextBeginningIndexes![
                    nextBeginningIndexesChanges[i * 2 + 0]] =
                nextBeginningIndexesChanges[i * 2 + 1];
          }

          return null;
        }
      }
      // Update nextBeginningIndexes for the next search
      bool isTheLastSearch = i == searchesLen - 1;
      if (!isTheLastSearch) {
        List<int>? indexes = result.indexes;
        bool indexesIsConsecutiveSubstring = true;

        for (int j = 0; j < indexes.length - 1; j++) {
          if (indexes[j + 1] - indexes[j] != 1) {
            indexesIsConsecutiveSubstring = false;
            break;
          }
        }

        if (indexesIsConsecutiveSubstring) {
          int newBeginningIndex = indexes[indexes.length - 1] + 1;

          assert(target.nextBeginningIndexes != null);

          int toReplace = target.nextBeginningIndexes![newBeginningIndex - 1];

          for (int j = newBeginningIndex - 1; j >= 0; j--) {
            if (toReplace != target.nextBeginningIndexes![j]) break;
            target.nextBeginningIndexes![j] = newBeginningIndex;
            if (nextBeginningIndexesChanges.isEmpty) {
              nextBeginningIndexesChanges = [...target.nextBeginningIndexes!];
            }

            nextBeginningIndexesChanges[changeslen * 2] = j;
            nextBeginningIndexesChanges[changeslen * 2 + 1] = toReplace;
            changeslen++;
          }
        }
      }

      score += result.score / searchesLen;
      allowPartialMatchScores[i] = result.score / searchesLen;

      if (result.indexes[0] < firstSeenIndexLastSearch) {
        score -= (firstSeenIndexLastSearch - result.indexes[0]) * 2;
      }
      firstSeenIndexLastSearch = result.indexes[0];

      for (int index in result.indexes) {
        seenIndexes.add(index);
      }
    }

    if (allowPartialMatch && !hasAtLeast1Match) return null;

    // Reset nextBeginningIndexes and return result
    target.nextBeginningIndexes = prepareNextBeginningIndexes(target.target);
    result = FuzzySearchResult(
        targetIdentifier: target.identifier,
        target: target.target,
        score: score,
        indexes: seenIndexes.toList());
    return result;
  }

  double calculateScore(
    bool successStrict,
    List<int> matchesSimple,
    List<int> matchesStrict,
    List<int> nextBeginningIndexes,
    bool isSubstring,
    bool isSubstringBeginning,
    int searchLen,
    int targetLen,
    FuzzySearchPreparedTarget prepared,
  ) {
    double score = 0;
    int extraMatchGroupCount = 0;

    // Use matchesSimple or matchesStrict based on successStrict
    List<int> matches = successStrict ? matchesStrict : matchesSimple;

    // Calculate penalties for non-consecutive matches
    for (int i = 1; i < searchLen; i++) {
      if (matches[i] - matches[i - 1] != 1) {
        score -= matches[i];
        extraMatchGroupCount++;
      }
    }

    // Calculate unmatched distance
    int unmatchedDistance =
        matches[searchLen - 1] - matches[0] - (searchLen - 1);
    score -= (12 + unmatchedDistance) *
        extraMatchGroupCount; // Penalty for more groups

    // Penalty for not starting near the beginning
    if (matches[0] != 0) {
      score -= matches[0] * matches[0] * 0.2;
    }

    if (!successStrict) {
      // Multiply score by 1000 if strict match was not successful
      score *= 1000;
    } else {
      // Penalize if there are too many unique beginning indexes in strict mode
      int uniqueBeginningIndexesCount = 1;
      for (int i = nextBeginningIndexes[0];
          i < targetLen;
          i = nextBeginningIndexes[i]) {
        uniqueBeginningIndexesCount++;
      }
      if (uniqueBeginningIndexesCount > 24) {
        score *= (uniqueBeginningIndexesCount - 24) * 10;
      }
    }

    // Penalty for longer targets
    score -= (targetLen - searchLen) / 2;

    // Bonus for substring matches
    if (isSubstring) {
      score /= 1 + searchLen * searchLen * 1;
    }
    if (isSubstringBeginning) {
      score /= 1 + searchLen * searchLen * 1;
    }

    // Additional penalty for longer targets
    score -= (targetLen - searchLen) / 2;

    return score;
  }

  // Normalize score function
  double normalizeScore(double score) {
    if (score == double.negativeInfinity) return 0;
    if (score > 1) return score;
    return exp((((-score + 1) > 0 ? pow(-score + 1, 0.04307) : 0) - 1) * -2);
  }

  // Denormalize score function
  double denormalizeScore(double normalizedScore) {
    if (normalizedScore == 0) return double.negativeInfinity;
    if (normalizedScore > 1) return normalizedScore;
    return 1 - pow((log(normalizedScore) / -2 + 1), 1 / 0.04307).toDouble();
  }

  // Prepare string for matching
  FuzzySearchPreparedTarget prepare(String target, String targetIdentifier) {
    if (preparedCache.containsKey(target)) return preparedCache[target]!;
    FuzzySearchPreparedTarget prepared =
        FuzzySearchPreparedTarget(target: target, identifier: targetIdentifier);

    preparedCache[target] = prepared;

    return prepared;
  }

  // Prepare search string
  PreparedSearch prepareSearch(String search) {
    if (preparedSearchCache.containsKey(search)) {
      return preparedSearchCache[search]!;
    }
    PreparedSearch preparedSearch = PreparedSearch(search);
    preparedSearchCache[search] = preparedSearch;
    return preparedSearch;
  }

  // Generate next beginning indexes
  List<int> prepareNextBeginningIndexes(String target) {
    // Get the length of the target string
    int targetLen = target.length;

    // Get the list of beginning indexes
    List<int> beginningIndexes = prepareBeginningIndexes(target);

    // Initialize the list to hold next beginning indexes
    List<int> nextBeginningIndexes =
        List.filled(targetLen, targetLen); // Using `targetLen` as default value

    int lastIsBeginning =
        beginningIndexes.isNotEmpty ? beginningIndexes[0] : targetLen;
    int lastIsBeginningI = 0;

    for (int i = 0; i < targetLen; ++i) {
      if (lastIsBeginning > i) {
        nextBeginningIndexes[i] = lastIsBeginning;
      } else {
        if (++lastIsBeginningI < beginningIndexes.length) {
          lastIsBeginning = beginningIndexes[lastIsBeginningI];
          nextBeginningIndexes[i] = lastIsBeginning;
        } else {
          nextBeginningIndexes[i] = targetLen;
        }
      }
    }

    return nextBeginningIndexes;
  }

  // Identify beginning indexes
  List<int> prepareBeginningIndexes(String target) {
    List<int> beginningIndexes = [];
    bool wasUpper = false;
    bool wasAlphanum = false;

    for (int i = 0; i < target.length; i++) {
      int targetCode = target.codeUnitAt(i);
      bool isUpper = targetCode >= 65 && targetCode <= 90;
      bool isAlphanum = isUpper ||
          (targetCode >= 97 && targetCode <= 122) ||
          (targetCode >= 48 && targetCode <= 57);
      bool isBeginning = (isUpper && !wasUpper) || !wasAlphanum || !isAlphanum;
      wasUpper = isUpper;
      wasAlphanum = isAlphanum;

      if (isBeginning) {
        beginningIndexes.add(i);
      }
    }
    return beginningIndexes;
  }
}

class FuzzySearchPreparedTarget {
  String identifier;
  String target; // Original target string
  late String targetLower; // Lowercase version of the target string
  List<int>?
      targetLowerCodes; // Unicode code points of each character in the lowercase target
  List<int>?
      nextBeginningIndexes; // Indexes indicating where word beginnings are

  late int bitFlags;

  // Constructor to initialize the prepared target
  FuzzySearchPreparedTarget({required this.target, required this.identifier}) {
    // Convert target to lowercase
    targetLower = target.toLowerCase();

    // Store the Unicode code points of each character in the lowercase target
    targetLowerCodes = targetLower.codeUnits;

    // Initially, the nextBeginningIndexes will be null; will be filled during search preparation
    nextBeginningIndexes = null;

    bitFlags = _calculateBitflags(targetLowerCodes!);
  }
}

class PreparedSearch {
  String search; // Original search string
  late String lower; // Lowercase version of the search string
  late List<int>
      lowerCodes; // Unicode code points of each character in the lowercase search
  late bool containsSpace; // Whether the search string contains spaces
  late List<PreparedSearch>
      spaceSearches; // List of searches split by spaces (for fuzzy search with spaces)
  late int bitflags; // Bitflags used for fast comparison

  // Constructor to initialize the prepared search
  PreparedSearch(this.search) {
    // Convert search string to lowercase
    lower = search.toLowerCase();

    // Store the Unicode code points of each character in the lowercase search
    lowerCodes = lower.codeUnits;

    // Check if the search string contains spaces
    containsSpace = lower.contains(' ');

    // Prepare space-separated searches if there are spaces
    spaceSearches = containsSpace
        ? lower.split(' ').map((part) => PreparedSearch(part)).toList()
        : [];

    // Initialize bitflags for fast comparison (based on ASCII values)
    bitflags = _calculateBitflags(lowerCodes);
  }
}

class FuzzySearchResult {
  String targetIdentifier; // The target string that matched
  String target; // The target string that matched
  double score; // The calculated score of the match
  List<int>
      indexes; // The list of indexes where matches occurred in the target string

  // Constructor
  FuzzySearchResult(
      {required this.targetIdentifier,
      required this.target,
      required this.score,
      required this.indexes});

  @override
  String toString() {
    return 'Result(targetIdentifier: $targetIdentifier, target: $target, score: $score, indexes: $indexes)';
  }
}

// Private method to calculate bitflags for fast comparison
int _calculateBitflags(List<int> codes) {
  int flags = 0;

  for (var code in codes) {
    if (code == 32) continue; // Skip spaces

    int bit = (code >= 97 && code <= 122)
        ? code - 97 // alphabet
        : (code >= 48 && code <= 57)
            ? 26 // numbers
            : (code <= 127)
                ? 30 // other ASCII
                : 31; // other UTF-8 characters

    flags |= (1 << bit);
  }

  return flags;
}
