import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:picapool/core/api_impl.dart';
import 'package:picapool/core/core.dart';
import 'package:picapool/models/near_user_model.dart';
import 'package:picapool/models/response_model.dart';
import 'package:picapool/models/user_model.dart';

class UserApi with PicapoolApiClass {
  FutureEither<List<NearUserModel>> getNearestUsers({
    required int userId,
    required LatLng currentPosition,
    required double radius,
  }) async {
    try {
      var response = await api.makeRequest(
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

      return response.fold((error) => left(error),
          (ResponseModel responseModel) async {
        if (responseModel.success) {
          List<NearUserModel> usersLocation = await responseModel
              .parseDataList<NearUserModel>(NearUserModel.fromJson);

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

  FutureEither<User> getUser({
    required int userId,
  }) async {
    try {
      final response = await api.makeRequest(
          enpoint: APIEndpoints.getUser(userId),
          method: RequestMethod.getRequest,
          additionalHeaders: {
            'Content-Type': 'application/json',
          });

      return response.fold((error) => left(error), (responseModel) {
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
      });
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

  FutureEither<bool> updateUser({
    required Map<String, dynamic> updateValues,
  }) async {
    try {
      debugPrint("Updated Values: $updateValues");

      debugPrint(updateValues.toString());

      final response = await api.makeRequest(
        enpoint: APIEndpoints.updateUser,
        method: RequestMethod.patch,
        additionalHeaders: {'Content-Type': 'application/json'},
        body: updateValues,
      );

      return response.fold((error) => left(error), (responseModel) {
        if (responseModel.success) {
          return right(true);
        } else {
          debugPrint(
              'Update User Error: ${responseModel.message} with response ${responseModel.toString()}');
          return left(
            Failure(
              message: responseModel.message,
              stackTrace: StackTrace.current,
            ),
          );
        }
      });
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
}
