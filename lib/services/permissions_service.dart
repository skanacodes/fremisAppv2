import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  final PermissionHandler permissionHandler = PermissionHandler();

  Future<bool> _requestPermission(
      PermissionGroup permission1, PermissionGroup permission2) async {
    var result =
        await permissionHandler.requestPermissions([permission1, permission2]);
    if (result[permission1] == PermissionStatus.granted) {
      return true;
    }
    if (result[permission2] == PermissionStatus.granted) {
      return true;
    }
    return false;
  }

  Future<bool> requestCameraandlocationPermission() async {
    return _requestPermission(PermissionGroup.camera, PermissionGroup.location);
  }
}
