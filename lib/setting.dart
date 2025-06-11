import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import 'cubit/auth_cubit.dart';
import 'cubit/auth_state.dart';
import 'models/local_language.dart';
import 'upload_file.dart';

class SettingsScreen extends StatefulWidget {
  final Function(String) onLanguageChange;
  final Locale currentLocale;

  const SettingsScreen({
    super.key,
    required this.onLanguageChange,
    required this.currentLocale,
  });
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _hasFetched = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasFetched) {
      context.read<AuthCubit>().fetchUserData();
      _hasFetched = true;
    }
  }
  @override
  void initState() {
    super.initState();
     }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    String currentLang = Localizations.localeOf(context).languageCode;
    var currentLocale = Localizations.localeOf(context);
    bool isArabic = currentLocale.languageCode == 'ar';
    final authCubit = context.read<AuthCubit>();
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocBuilder<AuthCubit, AuthStates>(
          bloc: authCubit,
          builder: (context, state) {
            print("Current state: $state");
            if (state is UserLoading) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }else if (state is UserUpdated) {
              authCubit.fetchUserData();
              return Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            else if (state is UserLoaded) {
              return _buildProfileContent(currentLang, screenWidth, context);
            } else if (state is UserError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text('Something went wrong'));
          },
        ),
        bottomNavigationBar: _buildCustomBottomNavBar(
          context,
          activeTab: "settings",
        ),
      ),
    );
  }

  Widget _buildProfileContent(
    String currentLang,
    double screenWidth,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBackButton(context),
        _buildTitle(AppLocalizations.of(context).translate("settings")),
        _buildDivider(),
        _buildSectionTitle(AppLocalizations.of(context).translate("account")),
        _buildAccountInfo(screenWidth),
        _buildSectionTitle(AppLocalizations.of(context).translate("settings")),
        _buildSettingItem(
          Icons.language,
          AppLocalizations.of(context).translate("language"),
          currentLang == "en" ? "English" : "العربية",
          const Color(0xff09122C),
          onTap: () {
            String newLang = currentLang == "en" ? "ar" : "en";
            widget.onLanguageChange(newLang);
          },
          screenWidth,
        ),
        _buildSettingItem(
          Icons.help_outline,
          AppLocalizations.of(context).translate("help"),
          "",
          const Color(0xff09122C),
          screenWidth,
        ),
        _buildSettingItem(
          Icons.logout,
          AppLocalizations.of(context).translate("logout"),
          "",
          Colors.red,
          screenWidth,
          onTap: () {
            Navigator.pushReplacementNamed(context, 'Login');
          },
        ),
      ],
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

  Widget _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xff09122C),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(color: Colors.black26, thickness: 1),
    );
  }

  Widget _buildSectionTitle(String title) {
    var currentLocale = Localizations.localeOf(context);
    bool isArabic = currentLocale.languageCode == 'ar';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      child: Align(
        alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xff09122C),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountInfo(double screenWidth) {
    return BlocBuilder<AuthCubit, AuthStates>(
      builder: (context, state) {
        if (state is UserLoaded) {
          final user = state.user;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Container(
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: Icon(Icons.person, size: screenWidth * 0.07),
                title: Text(
                  user.name,
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    color: Color(0xff09122C),
                  ),
                ),
                subtitle: Text(
                  user.email,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Color(0xff09122C),
                  ),
                ),
                trailing: buildArrowIcon(Colors.black),
                onTap: () async {
                  final result = await Navigator.pushNamed(context, 'update');
                  if (result == true && context.mounted) {
                    context.read<AuthCubit>().fetchUserData();
                  }
                },
              ),
            ),
          );
        } else if (state is UserLoading) {
          return Center(child: CircularProgressIndicator());
        } else {
          return Center(child: Text('No user data available'));
        }
      },
    );
  }

  Widget _buildSettingItem(
    IconData icon,
    String title,
    String subtitle,
    Color color,
    double screenWidth, {
    VoidCallback? onTap,
  }) {
    String currentLang = widget.currentLocale.languageCode;
    String displayLang = currentLang == "en" ? "English" : "العربية";
    return Padding(
      padding: EdgeInsets.only(
        left: screenWidth * .09,
        right: screenWidth * .09,
        bottom: screenWidth * .05,
      ),
      child: ListTile(
        leading: Icon(icon, color: color, size: 30),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        subtitle: Text(displayLang, style: const TextStyle(color: Colors.grey)),
        trailing: buildArrowIcon(color),
        onTap: onTap,
      ),
    );
  }

  Widget _buildCustomBottomNavBar(
    BuildContext context, {
    required String activeTab,
  }) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          height: screenHeight * 0.10,
          decoration: const BoxDecoration(color: Color(0xff09122C)),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor:
                      activeTab == "history"
                          ? Colors.yellow
                          : Color(0xff09122C),
                  radius: screenWidth * .08,
                  child: IconButton(
                    icon: Icon(
                      Icons.bookmark,
                      color:
                          activeTab == "history"
                              ? Color(0xff09122C)
                              : Colors.grey,
                      size: screenWidth * 0.07,
                    ),
                    onPressed: () {
                      if (activeTab != "history") {
                        Navigator.pushReplacementNamed(context, "History");
                      }
                    },
                  ),
                ),
                CircleAvatar(
                  backgroundColor:
                      activeTab == "settings"
                          ? Colors.yellow
                          : Color(0xff09122C),
                  radius: screenWidth * .08,

                  child: IconButton(
                    icon: Icon(
                      Icons.person,
                      color:
                          activeTab == "settings"
                              ? Color(0xff09122C)
                              : Colors.grey,
                      size: screenWidth * 0.07,
                    ),
                    onPressed: () {
                      if (activeTab != "settings") {
                        Navigator.pushReplacementNamed(context, "Setting");
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildArrowIcon(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(20),
        color: Colors.transparent,
      ),
      child: Icon(Icons.arrow_forward_outlined, color: color, size: 16),
    );
  }
}
