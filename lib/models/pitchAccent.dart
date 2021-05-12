class PitchAccent {
  final String orths_txt;
  final String hira;
  final String hz;
  final String accs_txt;
  final String patts_txt;
  PitchAccent(
      {this.orths_txt, this.accs_txt, this.hira, this.hz, this.patts_txt});

  Map<String, dynamic> toMap() {
    return {
      'orths_txt': orths_txt,
      'hira': hira,
      'hz': hz,
      'accs_txt': accs_txt,
      'patts_txt': patts_txt,
    };
  }
}
