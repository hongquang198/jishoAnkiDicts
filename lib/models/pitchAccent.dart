class PitchAccent {
  final String orthsTxt;
  final String hira;
  final String hz;
  final String accsTxt;
  final String pattsTxt;
  PitchAccent(
      {this.orthsTxt, this.accsTxt, this.hira, this.hz, this.pattsTxt});

  Map<String, dynamic> toMap() {
    return {
      'orths_txt': orthsTxt,
      'hira': hira,
      'hz': hz,
      'accs_txt': accsTxt,
      'patts_txt': pattsTxt,
    };
  }
}
