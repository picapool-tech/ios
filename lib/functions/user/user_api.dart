import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:picapool/core/core.dart';
import 'package:picapool/models/response_model.dart';
import 'package:picapool/models/user_model.dart';
import 'package:picapool/screens/vicinity/request_vicinity.dart';

class UserApi {
  final PicapoolApi _api = PicapoolApi();

  FutureEither<bool> updateUser(
      Map<String, dynamic> updateValues, String accessToken) async {
    try {
      const String url = "https://api.picapool.com/v2/user/update";

      debugPrint("Updated Values: $updateValues");

      debugPrint("Access token : $accessToken");
      // var body = {

      //     ...updateValues,

      // };

      debugPrint(updateValues.toString());

      http.Response response = await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        },
        body: jsonEncode(updateValues),
      );

      var responseModel = ResponseModel.fromJson(jsonDecode(response.body));
      debugPrint('User Updated: ${response.body}');
      if (responseModel.success) {
        return right(true);
      } else {
        debugPrint(
            'Update User Error: ${response.statusCode} with response ${response.body}');
        return left(
          Failure(
            message: responseModel.message,
            stackTrace: StackTrace.current,
          ),
        );
      }
    } catch (e) {
      debugPrint('Update User Error: $e');
      return left(
        Failure(
          message: "Failed to update user details. Please try again.",
          stackTrace: StackTrace.fromString(
            e.toString(),
          ),
        ),
      );
    }
  }

  FutureEither<User> getUser(
      {required int userId, required String accessToken}) async {
    try {
      var response = await http.get(
        Uri.parse('https://api.picapool.com/v2/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        },
      );
      int statusCode = response.statusCode;
      if (statusCode >= 200 && statusCode <= 300) {
        var responseModel = ResponseModel.fromJson(jsonDecode(response.body));
        debugPrint("getUser Response: ${response.body}");
        if (responseModel.success) {
          var user = User.fromJson(responseModel.data);
          return right(user);
        } else {
          return left(
            Failure(
              message: responseModel.message,
              stackTrace: StackTrace.current,
            ),
          );
        }
      } else {
        debugPrint(
          'Not able to get the user : status code $statusCode',
        );

        return left(
          Failure(
            message:
                "Not able to get the user : status code ${response.statusCode} with me",
            stackTrace: StackTrace.current,
          ),
        );
      }
    } catch (e) {
      debugPrint('Get User Error: $e');
      return left(
        Failure(
          message: "Not able to get the user : status code $e",
          stackTrace: StackTrace.current,
        ),
      );
    }
  }

  FutureEither<List<NearUserModel>> getNearestUsers({
    required int userId,
    required LatLng currentPosition,
    required double radius,
  }) async {
    String endpoint = "https://api.picapool.com/v2/user/nearest";
    try {
      var response = await _api.makeRequest(
          enpoint: APIEndpoints.getNearestUsers,
          method: RequestMethod.post,
          requireAccessToken: true,
          body: {
            'dist': radius,
            'id': userId,
          },
          additionalHeaders: {
            'content-type': 'application/json',
          });

      return response.fold((error) => left(error), (responseModel) {
        if (responseModel.success) {
          List<NearUserModel> usersLocation = [];
          var users = responseModel.data as List<dynamic>? ?? [];

          for (var user in users) {
            var nearUser = NearUserModel.fromJson(user);
            usersLocation.add(nearUser);
          }

          return right(usersLocation);
        } else {
          return left(
            Failure(
              message: responseModel.message,
              stackTrace: StackTrace.current,
            ),
          );
        }
      });

      // final response = await http.post(Uri.parse(endpoint),
      //     body: jsonEncode({
      //       'dist': radius,
      //       'id': id,
      //     }),
      //     headers: {
      //       'content-type': 'application/json',
      //       'Authorization': 'Bearer $at'
      //     });

      //   // debugPrint("NEAREST USERS: ${response.body}");
      //   // if (response.statusCode < 300) {
      //   //   var responseModel = ResponseModel.fromJson(jsonDecode(response.body));

      //   //   if (!responseModel.success) {
      //   //     Get.snackbar(
      //   //       "No nearest user",
      //   //       "Not able to find any user near to your vicinity.",
      //   //     );
      //   //     return;
      //   //   }

      //   //   var users = responseModel.data as List<dynamic>? ?? [];
      //   //   List<NearUserModel> usersLocation = [];

      //   //   for (var user in users) {
      //   //     debugPrint("$user");
      //   //     var nearUser = NearUserModel.fromJson(user);
      //   //     usersLocation.add(nearUser);
      //   //   }

      //   //   _nearestUsers = usersLocation;

      //   //   setState(() {
      //   //     poolingUsers = users.length;
      //   //   });

      //   //   _addNearestUserMarkers();
      //   } else if (response.statusCode == 401) {
      //     debugPrint('Failed to load getNearestUsers - status code 401');
      //   } else {
      //     debugPrint('Failed to load getNearestUsers - status code not 200');
      //     return;
      //   }
    } catch (err) {
      debugPrint('Failed to fetch getNearestUsers - $err');
      return left(
        Failure(
          message: "Failed to fetch nearest users. Please try again.",
          stackTrace: StackTrace.current,
        ),
      );
    }
  }
}
