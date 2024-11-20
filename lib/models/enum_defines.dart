enum SectionType {
  analysisData,
  analysisPeriod,
  technologyList,
}

enum AnalysisCategory {
  industryTech('산업기술 분석'), // 산업기술
  countryTech('국가별 분석'), // 국가기술
  companyTech('기업별 분석'), // 기업기술
  academicTech('대학별 분석'), // 학술기술
  techCompetition('기술경쟁력 분석'), // 기술경쟁
  techAssessment('기술진단 분석'), // 기술진단
  techGap('기술격차 분석'); // 기술격차

  final String label;
  const AnalysisCategory(this.label);

  @override
  String toString() => label;
}

enum AnalysisDataType {
  patent('특허'),
  paper('논문'),
  patentAndPaper('특허+논문');

  final String label;
  const AnalysisDataType(this.label);

  @override
  String toString() => label;
}

enum AnalysisSubCategory {
  techTrend('기술트렌드'),
  countryTrend('국가트렌드'),
  companyTrend('기업트렌드'),
  academicTrend('대학트렌드'),
  techInnovationIndex('기술혁신지수'),
  marketExpansionIndex('시장확장지수'),
  rdInvestmentIndex('R&D투자지수'),
  countryDetail('국가'),
  companyDetail('기업'),
  academicDetail('대학');

  final String label;
  const AnalysisSubCategory(this.label);

  @override
  String toString() => label;
}

enum TechListType {
  lc('LC'),
  mc('MC'),
  sc('SC');

  final String label;
  const TechListType(this.label);

  @override
  String toString() => label;
}

enum CagrCalculationMode {
  selectedPeriod, // 선택된 기간만 사용
  fullPeriod, // 전체 기간 사용
}
