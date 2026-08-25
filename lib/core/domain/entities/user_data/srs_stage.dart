/// Card learning stage in the SRS lifecycle.
enum SrsStage {
  /// Card has not been reviewed yet.
  newCard,

  /// Card is currently progressing through learning steps.
  learning,

  /// Card has graduated and is in regular review intervals.
  review,

  /// Card lapsed during review and is relearning.
  relearning,
}

/// User rating given during a review session.
enum SrsRating {
  /// Failed recall: reset to first step or relearning.
  again,

  /// Recalled with significant difficulty: minor interval increase.
  hard,

  /// Successful recall: standard interval advance.
  good,

  /// Effortless recall: accelerated graduation or extra ease bonus.
  easy,
}
