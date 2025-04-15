import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled/domain/models/log_out_models/log_out_request.dart';
import 'package:untitled/domain/models/profile_models/profile_request.dart';

import '../../../domain/models/profile_models/profile_response.dart';
import '../../../navigation/page_routes.dart';
import '../../../utils/common_bottom_navigation.dart';
import '../../bloc/logout_bloc/logout_cubit.dart';
import '../../bloc/logout_bloc/logout_state.dart';
import '../../bloc/profile_bloc/profile_cubit.dart';
import '../../bloc/profile_bloc/profile_state.dart';


/*
class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 1;
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().fetchProfile();
  }
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("My Profile"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoadingState) {
            return Center(child: CircularProgressIndicator());
          } else if (state is ProfileSuccessState) {
            return buildProfileUI(state.response);
          } else if (state is ProfileErrorState) {
            return Center(child: Text("Error: ${state.error}"));
          } else {
            return Center(child: Text("No data available"));
          }
        },
      ),
      bottomNavigationBar: BottomNavigationWidget(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),

    );
  }

  Widget buildProfileUI(ProfileResponse profile) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [


          // Name
          Text(
            profile.data.fullName ?? "Unknown",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 8),

          // Profile Details
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 2),
              ],
            ),
            child: Column(
              children: [
                buildProfileDetail(Icons.email, profile.data.email ?? "No Email"),
                Divider(),
                buildProfileDetail(Icons.phone, profile.data.phone ?? "No Phone"),
                Divider(),
                buildProfileDetail(Icons.location_on, profile.data.address ?? "No Location"),
              ],
            ),
          ),

          SizedBox(height: 24),

        BlocConsumer<LogoutCubit, LogoutState>(
          listener: (context, state) {
            if (state is LogoutSuccessState) {
              // Navigate to Login Screen after logout success
              Navigator.of(context, rootNavigator: true).pushNamed(PageRoutes.login);

            } else if (state is LogoutErrorState) {
              // Show error message on failure
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorResponse.toString())),
              );
            }
          },
          builder: (context, state) {
            return buildProfileOption(
              Icons.logout,
              "Logout",
              onTap: () {
                final deviceToken = "deviceToken"; // Fetch actual token
                context.read<LogoutCubit>().logouts(logoutRequest: LogoutRequest(deviceToken: deviceToken));
              },

            );
          },
        ),



          buildProfileOption(Icons.history, "Order history", onTap: () {
            Navigator.of(context, rootNavigator: true).pushNamed(PageRoutes.orderHistory);
          }),
        ],
      ),
    );
  }

  Widget buildProfileDetail(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.purple, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProfileOption(IconData icon, String title, {Widget? trailing, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Colors.grey.shade100,
        leading: Icon(icon, color: Colors.black54),
        title: Text(title, style: TextStyle(fontSize: 16)),
        trailing: trailing ?? Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
        onTap: onTap,
      ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../gallery_bottomsheet.dart';
/*import 'package:project_screen/actionrequiredpopup.dart';
import 'package:project_screen/gallery_bottomsheet.dart';
import 'package:project_screen/login_bottomsheet.dart';*/

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  int _selectedIndex = 1;
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().fetchProfile();
  }
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Profile',
          style: GoogleFonts.nunitoSans(color: Colors.black),
        ),
        backgroundColor: Color(0xFFF9F9F9),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [

            SizedBox(height: 60),

            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap : (){
                          showCustomBottomSheet(
                  context,
                  onRecentPictures: () {},
                  onSelectFromGallery: () {},
                  onSelectFromLocalFiles: () {},
                );
                    },
                      child: CircleAvatar(radius: 50, backgroundColor: Colors.grey[300])),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Color(0xFFF7653F6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                if (state is ProfileLoadingState) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is ProfileSuccessState) {
                  return buildProfileUI(state.response);
                } else if (state is ProfileErrorState) {
                  return Center(child: Text("Error: ${state.error}"));
                } else {
                  return Center(child: Text("No data available"));
                }
              },
            ),

            SizedBox(height: 100),
            ProfileMenuItem(
              icon: Icons.edit,
              text: 'Edit Profile',
              onTap: () {
            //    showLoginSuccessBottomSheet(context);
              },
            ),
            SizedBox(height: 20),
            ProfileMenuItem(
              icon: Icons.password,
              text: 'Change Password',
              onTap: () {
                Navigator.of(context, rootNavigator: true).pushNamed(PageRoutes.changePasswordScreen);
             //   showActionRequiredPopup(context);
              },
              showTrailingIcon: true,
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                height: 64,
                width: 430,
                padding: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x1AAFAEAE),
                      blurRadius: 50,
                      spreadRadius: 0,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.notifications, color: Colors.black54),
                        SizedBox(width: 15),
                        Text(
                          'Notification',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: true,
                      onChanged: (value) {},
                      activeColor: Color(0xFFF7653F6),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            BlocConsumer<LogoutCubit, LogoutState>(
              listener: (context, state) {
                if (state is LogoutSuccessState) {
                  // Navigate to Login Screen after logout success
                  Navigator.of(context, rootNavigator: true).pushNamed(PageRoutes.login);

                } else if (state is LogoutErrorState) {
                  // Show error message on failure
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.errorResponse.toString())),
                  );
                }
              },
              builder: (context, state) {
                return ProfileMenuItem(
                 icon : Icons.logout,
                  text : "Logout",
                  onTap: () {
                    final deviceToken = "deviceToken"; // Fetch actual token
                    context.read<LogoutCubit>().logouts(logoutRequest: LogoutRequest(deviceToken: deviceToken));
                  },

                );
              },
            ),

          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationWidget(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget buildProfileUI(ProfileResponse response) {
    return Column(children: [
      Text(
        '${response.data.fullName}',
        style: GoogleFonts.nunitoSans(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        '${response.data.address}',
        style: GoogleFonts.nunitoSans(fontSize: 16, color: Colors.grey),
      ),
    ],);
  }
}

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final bool showTrailingIcon;

  const ProfileMenuItem({
    required this.icon,
    required this.text,
    required this.onTap,
    this.showTrailingIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 8,
      ), // Adjust spacing
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 64,
          width: 430,
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Color(0x1AAFAEAE),
                blurRadius: 50,
                spreadRadius: 0,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.black54),
                  SizedBox(width: 15),
                  Text(
                    text,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              if (showTrailingIcon)
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue),
            ],
          ),
        ),
      ),
    );
  }
}
