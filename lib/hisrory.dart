import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'cubit/auth_cubit.dart';
import 'cubit/auth_state.dart';
import 'models/local_language.dart';
import 'models/result_model.dart';
import 'upload_file.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {

  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().fetchAllResults();

  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    var currentLocale = Localizations.localeOf(context);
    bool isArabic = currentLocale.languageCode == 'ar';
    return  Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBackButton(context),
              _buildTitle(
                AppLocalizations.of(context).translate("History"),
                screenWidth,
              ),
              _buildDivider(screenWidth),
              Expanded(
                child: BlocBuilder<AuthCubit, AuthStates>(
                  builder: (context, state) {
                    if (state is ResultLoading) {
                      return Center(child: CircularProgressIndicator());
                    } else if (state is ResultLoaded) {
                      if (state.results.isEmpty) {
                        return Center(
                          child: Text(AppLocalizations.of(context).translate("No history available.")),
                        );
                      }

                      return _buildHistoryGrid(screenWidth, screenHeight,context, state.results);
                    } else if (state is ResultError) {
                      return Center(child: Text(state.message));
                    }
                    return Container();
                  },
                ),
              ),

            ],
          ),
        ),
        bottomNavigationBar: _buildCustomBottomNavBar(
          context,
          activeTab: AppLocalizations.of(context).translate("history"),
        ),
      );
  }

  Widget _buildBackButton(BuildContext context) {
    var currentLocale = Localizations.localeOf(context);
    bool isArabic = currentLocale.languageCode == 'ar';

    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, top: 20),
        child: IconButton(
          icon: Icon(
            isArabic ? Icons.arrow_forward : Icons.arrow_back,
            color: Color(0xff09122C),
          ),
          iconSize: 30,
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => UploadFileScreen()),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTitle(String title, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
      child: Text(
        title,
        style: TextStyle(
          fontSize: screenWidth * 0.06,
          fontWeight: FontWeight.bold,
          color: const Color(0xff09122C),
        ),
      ),
    );
  }

  Widget _buildDivider(double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: const Divider(color: Colors.black26, thickness: 1),
    );
  }

  Widget _buildHistoryGrid(
    double screenWidth,
    double screenHeight,
      BuildContext context,

      List<ResultModel> results,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
      child: GridView.builder(
        padding: EdgeInsets.only(bottom: screenHeight * 0.08),
        itemCount: results.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: screenWidth * 0.09,
          mainAxisSpacing: screenHeight * 0.02,
          childAspectRatio: 1.1,
        ),
        itemBuilder: (context, index) {
          final item = results[index];
          return GestureDetector(
            onTap: () {},
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: screenHeight * 0.12,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image:  NetworkImage(item.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Center(
                    child: Text(
                      item.diseaseName??"",
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Center(
                    child: Text(
                      item.createdAt != null
                          ? DateFormat('yyyy-MM-dd').format(DateTime.parse(item.createdAt!))
                          : "",
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCustomBottomNavBar(
    BuildContext context, {
    required String activeTab,
  }) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.10,
      decoration: const BoxDecoration(color: Color(0xff09122C)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavIcon(
              context,
              Icons.bookmark,
              "history",
              activeTab,
              screenWidth,
            ),
            _buildNavIcon(
              context,
              Icons.person,
              "settings",
              activeTab,
              screenWidth,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(
    BuildContext context,
    IconData icon,
    String tabName,
    String activeTab,
    double screenWidth,
  ) {
    return CircleAvatar(
      backgroundColor: activeTab == tabName ? Colors.yellow : Color(0xff09122C),
      radius: screenWidth * .08,
      child: IconButton(
        icon: Icon(
          icon,
          color: activeTab == tabName ? Color(0xff09122C) : Colors.grey,
          size: screenWidth * 0.07,
        ),
        onPressed: () {
          if (activeTab != tabName) {
            Navigator.pushReplacementNamed(
              context,
              tabName == "history" ? "History" : "Setting",
            );
          }
        },
      ),
    );
  }
}
