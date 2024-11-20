import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/controllers/content_controller.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import 'package:flutter_application_data_chart_viewer/providers/analysis_data_provider.dart';
import 'package:provider/provider.dart';

class AnalysisTargetWidget extends StatefulWidget {
  final AnalysisCategory category;

  const AnalysisTargetWidget({
    super.key,
    required this.category,
  });

  @override
  State<AnalysisTargetWidget> createState() => _AnalysisTargetWidgetState();
}

class _AnalysisTargetWidgetState extends State<AnalysisTargetWidget> {
  @override
  void initState() {
    super.initState();
    // build 과정이 끝난 후 초기화하도록 수정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<AnalysisDataProvider>()
          .initializeWithCategory(widget.category);
    });
  }

  List<AnalysisCategory> _getAvailableOptions() {
    return [
      AnalysisCategory.countryTech,
      AnalysisCategory.companyTech,
      AnalysisCategory.academicTech
    ];
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<AnalysisDataProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '분석 대상',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Divider(
          color: Colors.grey,
          thickness: 1,
        ),
        if (widget.category == AnalysisCategory.techCompetition ||
            widget.category == AnalysisCategory.techAssessment ||
            widget.category == AnalysisCategory.techGap)
          _buildAnalysisTargetWithTechCompetition(dataProvider)
        else
          _buildAnalysisTarget(dataProvider),
      ],
    );
  }

  List<AnalysisSubCategory> _getAvailableSubCategories(
      AnalysisDataType dataType) {
    switch (dataType) {
      case AnalysisDataType.patent:
        return [
          AnalysisSubCategory.countryDetail,
          AnalysisSubCategory.companyDetail,
        ];
      case AnalysisDataType.paper:
        return [
          AnalysisSubCategory.countryDetail,
          AnalysisSubCategory.academicDetail
        ];
      case AnalysisDataType.patentAndPaper:
        return [
          AnalysisSubCategory.countryDetail,
        ];
    }
  }

  Widget _buildAnalysisTarget(
    AnalysisDataProvider dataProvider,
  ) {
    final availableOptions = _getAvailableOptions();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: availableOptions.map((option) {
            return Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Radio<AnalysisCategory>(
                    value: option,
                    groupValue: dataProvider.selectedCategory,
                    onChanged: (AnalysisCategory? value) {
                      if (value != null) {
                        dataProvider.setSelectedCategory(value);
                        context.read<ContentController>().changeContent(value);
                      }
                    },
                  ),
                  Text(option == AnalysisCategory.countryTech
                      ? '국가'
                      : option == AnalysisCategory.companyTech
                          ? '기업'
                          : '대학'),
                ],
              ),
            );
          }).toList(),
        ),
        if (dataProvider.selectedCategory == AnalysisCategory.countryTech)
          Container(
            margin: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            height: 300,
            child: ListView(
              children: dataProvider
                  .getAvailableCountries(
                      context.watch<AnalysisDataProvider>().selectedTechCode)
                  .map((country) {
                return CheckboxListTile(
                  title: Row(
                    children: [
                      CountryFlag.fromCountryCode(
                          country.replaceAll(RegExp(r'[\[\]]'), ''),
                          height: 16,
                          width: 24),
                      Text(country),
                    ],
                  ),
                  value: dataProvider.selectedCountries.contains(country),
                  onChanged: (bool? value) {
                    if (value != null) {
                      dataProvider.toggleCountrySelection(country);
                    }
                  },
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                );
              }).toList(),
            ),
          ),
        if (dataProvider.selectedCategory == AnalysisCategory.companyTech)
          Container(
            margin: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            height: 300,
            child: ListView(
              children: dataProvider.getAvailableCompanies().map((company) {
                return CheckboxListTile(
                  title: Text(company),
                  value: dataProvider.selectedCompanies.contains(company),
                  onChanged: (bool? value) {
                    if (value != null) {
                      dataProvider.toggleCompanySelection(company);
                    }
                  },
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                );
              }).toList(),
            ),
          ),
        if (dataProvider.selectedCategory == AnalysisCategory.academicTech)
          Container(
            margin: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            height: 300,
            child: ListView(
              children: dataProvider.getAvailableAcademics().map((academic) {
                return CheckboxListTile(
                  title: Text(academic),
                  value: dataProvider.selectedAcademics.contains(academic),
                  onChanged: (bool? value) {
                    if (value != null) {
                      dataProvider.toggleAcademicSelection(academic);
                    }
                  },
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildAnalysisTargetWithTechCompetition(
    AnalysisDataProvider dataProvider,
  ) {
    final availableOptions =
        _getAvailableSubCategories(dataProvider.selectedDataType);
    return Column(
      children: [
        Row(
          children: availableOptions.map((option) {
            return Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Radio<AnalysisSubCategory>(
                    value: option,
                    groupValue: dataProvider.selectedSubCategory,
                    onChanged: (AnalysisSubCategory? value) {
                      if (value != null) {
                        dataProvider.setSelectedSubCategory(value);
                      }
                    },
                  ),
                  Text(option == AnalysisSubCategory.countryDetail
                      ? '국가'
                      : option == AnalysisSubCategory.companyDetail
                          ? '기업'
                          : '대학'),
                ],
              ),
            );
          }).toList(),
        ),
        if (dataProvider.selectedSubCategory ==
            AnalysisSubCategory.countryDetail)
          Container(
            margin: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            height: 300,
            child: ListView(
              children: dataProvider
                  .getAvailableCountriesFromTechCompetition(
                      context.watch<AnalysisDataProvider>().selectedTechCode)
                  .map((country) {
                return CheckboxListTile(
                  title: Row(
                    children: [
                      CountryFlag.fromCountryCode(
                          country.replaceAll(RegExp(r'[\[\]]'), ''),
                          height: 16,
                          width: 24),
                      Text(country),
                    ],
                  ),
                  value: dataProvider.selectedCountries.contains(country),
                  onChanged: (bool? value) {
                    if (value != null) {
                      dataProvider.toggleCountrySelection(
                        country,
                      );
                    }
                  },
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                );
              }).toList(),
            ),
          ),
        if (dataProvider.selectedSubCategory ==
            AnalysisSubCategory.companyDetail)
          Container(
            margin: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            height: 300,
            child: ListView(
              children: dataProvider
                  .getAvailableCompaniesFromTechCompetition(
                      context.watch<AnalysisDataProvider>().selectedTechCode)
                  .map((company) {
                return CheckboxListTile(
                  title: Row(
                    children: [
                      CountryFlag.fromCountryCode(
                          dataProvider
                              .searchCountryCode(company)
                              .replaceAll(RegExp(r'[\[\]]'), ''),
                          height: 16,
                          width: 24),
                      Expanded(
                        child: Text(
                          company,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  value: dataProvider.selectedCompanies.contains(company),
                  onChanged: (bool? value) {
                    if (value != null) {
                      dataProvider.toggleCompanySelection(
                        company,
                      );
                    }
                  },
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                );
              }).toList(),
            ),
          ),
        if (dataProvider.selectedSubCategory ==
            AnalysisSubCategory.academicDetail)
          Container(
            margin: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            height: 300,
            child: ListView(
              children: dataProvider
                  .getAvailableAcademicsFromTechCompetition(
                      context.watch<AnalysisDataProvider>().selectedTechCode)
                  .map((academic) {
                return CheckboxListTile(
                  title: Row(
                    children: [
                      CountryFlag.fromCountryCode(
                          dataProvider
                              .searchCountryCode(academic)
                              .replaceAll(RegExp(r'[\[\]]'), ''),
                          height: 16,
                          width: 24),
                      Expanded(
                        child: Text(
                          academic,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  value: dataProvider.selectedAcademics.contains(academic),
                  onChanged: (bool? value) {
                    if (value != null) {
                      dataProvider.toggleAcademicSelection(
                        academic,
                      );
                    }
                  },
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
