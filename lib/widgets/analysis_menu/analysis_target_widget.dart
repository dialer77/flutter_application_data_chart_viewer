import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/controllers/content_controller.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import 'package:flutter_application_data_chart_viewer/providers/analysis_data_provider.dart';
import 'package:flutter_application_data_chart_viewer/utils/common_utils.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:provider/provider.dart';

class AnalysisTargetWidget extends StatefulWidget {
  final AnalysisCategory category;
  final double buttonHeight;
  final double fontSize;
  const AnalysisTargetWidget({
    super.key,
    required this.category,
    required this.buttonHeight,
    required this.fontSize,
  });

  @override
  State<AnalysisTargetWidget> createState() => _AnalysisTargetWidgetState();
}

class _AnalysisTargetWidgetState extends State<AnalysisTargetWidget> {
  @override
  void initState() {
    super.initState();
  }

  List<AnalysisCategory> _getAvailableOptions() {
    return [AnalysisCategory.countryTech, AnalysisCategory.companyTech, AnalysisCategory.academicTech];
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<AnalysisDataProvider>();

    return LayoutBuilder(
      builder: (context, constraints) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.category == AnalysisCategory.techCompetition || widget.category == AnalysisCategory.techAssessment || widget.category == AnalysisCategory.techGap)
            Expanded(
              child: _buildAnalysisTargetWithTechCompetition(dataProvider),
            )
          else
            Expanded(
              child: Container(
                child: _buildAnalysisTarget(dataProvider),
              ),
            ),
        ],
      ),
    );
  }

  List<AnalysisSubCategory> _getAvailableSubCategories(AnalysisDataType dataType) {
    switch (dataType) {
      case AnalysisDataType.patent:
        return [
          AnalysisSubCategory.countryDetail,
          AnalysisSubCategory.companyDetail,
        ];
      case AnalysisDataType.paper:
        return [AnalysisSubCategory.countryDetail, AnalysisSubCategory.academicDetail];
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
    Set<String> availableItems = {};
    switch (dataProvider.selectedCategory) {
      case AnalysisCategory.countryTech:
        availableItems = dataProvider.getAvailableCountries(context.watch<AnalysisDataProvider>().selectedTechCode);
        break;
      case AnalysisCategory.companyTech:
        availableItems = dataProvider.getAvailableCompanies();
        break;
      case AnalysisCategory.academicTech:
        availableItems = dataProvider.getAvailableAcademics();
        break;
      default:
        break;
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: widget.buttonHeight,
              child: LayoutGrid(
                columnSizes: [1.fr, 1.fr, 1.2.fr],
                rowSizes: [1.fr],
                children: availableOptions
                    .map(
                      (option) => Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Transform.scale(
                              scale: widget.buttonHeight * 0.02,
                              child: Radio<AnalysisCategory>(
                                value: option,
                                groupValue: dataProvider.selectedCategory,
                                onChanged: (AnalysisCategory? value) {
                                  if (value != null) {
                                    dataProvider.setSelectedCategory(value);
                                    context.read<ContentController>().changeContent(value);
                                  }
                                },
                              ),
                            ),
                            Text(
                              option == AnalysisCategory.countryTech
                                  ? '국가'
                                  : option == AnalysisCategory.companyTech
                                      ? '기업'
                                      : '대학',
                              style: TextStyle(
                                fontSize: widget.fontSize,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ListView(
                  children: availableItems.map((item) {
                    return CheckboxListTile(
                      title: Row(
                        children: [
                          if (dataProvider.selectedCategory == AnalysisCategory.countryTech)
                            CountryFlag.fromCountryCode(
                              CommonUtils.instance.replaceCountryCode(item),
                              height: 16,
                              width: 24,
                            ),
                          Expanded(
                            child: Text(
                              CommonUtils.instance.replaceCountryCode(item),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      value: switch (dataProvider.selectedCategory) {
                        AnalysisCategory.countryTech => dataProvider.selectedCountries.contains(item),
                        AnalysisCategory.companyTech => dataProvider.selectedCompanies.contains(item),
                        AnalysisCategory.academicTech => dataProvider.selectedAcademics.contains(item),
                        _ => false,
                      },
                      onChanged: (bool? value) {
                        if (value != null) {
                          if (dataProvider.selectedCategory == AnalysisCategory.countryTech) {
                            dataProvider.toggleCountrySelection(item);
                          } else if (dataProvider.selectedCategory == AnalysisCategory.companyTech) {
                            dataProvider.toggleCompanySelection(item);
                          } else if (dataProvider.selectedCategory == AnalysisCategory.academicTech) {
                            dataProvider.toggleAcademicSelection(item);
                          }
                        }
                      },
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnalysisTargetWithTechCompetition(
    AnalysisDataProvider dataProvider,
  ) {
    final availableOptions = _getAvailableSubCategories(dataProvider.selectedDataType);
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
                  Text(
                    option == AnalysisSubCategory.countryDetail
                        ? '국가'
                        : option == AnalysisSubCategory.companyDetail
                            ? '기업'
                            : '대학',
                    style: TextStyle(
                      fontSize: widget.fontSize,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        if (dataProvider.selectedSubCategory == AnalysisSubCategory.countryDetail)
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ListView(
                children: dataProvider.getAvailableCountriesFromTechCompetition(context.watch<AnalysisDataProvider>().selectedTechCode).map((country) {
                  return CheckboxListTile(
                    title: Row(
                      children: [
                        CountryFlag.fromCountryCode(country.replaceAll(RegExp(r'[\[\]]'), ''), height: 16, width: 24),
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
          ),
        if (dataProvider.selectedSubCategory == AnalysisSubCategory.companyDetail)
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ListView(
                children: dataProvider.getAvailableCompaniesFromTechCompetition(context.watch<AnalysisDataProvider>().selectedTechCode).map((company) {
                  return CheckboxListTile(
                    title: Row(
                      children: [
                        CountryFlag.fromCountryCode(dataProvider.searchCountryCode(company).replaceAll(RegExp(r'[\[\]]'), ''), height: 16, width: 24),
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
          ),
        if (dataProvider.selectedSubCategory == AnalysisSubCategory.academicDetail)
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ListView(
                children: dataProvider.getAvailableAcademicsFromTechCompetition(context.watch<AnalysisDataProvider>().selectedTechCode).map((academic) {
                  return CheckboxListTile(
                    title: Row(
                      children: [
                        CountryFlag.fromCountryCode(dataProvider.searchCountryCode(academic).replaceAll(RegExp(r'[\[\]]'), ''), height: 16, width: 24),
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
          ),
      ],
    );
  }
}
