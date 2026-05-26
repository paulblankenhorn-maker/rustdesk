import 'package:get/get.dart';
import 'package:managed_configurations/managed_configurations.dart';

import '../../common.dart';
import '../../consts.dart';
import '../../models/platform_model.dart';
import '../../models/server_model.dart';

class ManagedAppConfigs {

  static String id="";

  Future<void> loadConfigs() async {
    final managedConfig = ManagedConfigurations();
    final managedAppConfig = await managedConfig.getManagedConfigurations;
    setConfigs(managedAppConfig);
    managedConfig.mangedConfigurationsStream.listen((managedAppConfig) {
      // executed when managed config gets updated
      setConfigs(managedAppConfig);
    });
  }

  Future<void> setConfigs(Map<String, dynamic>? managedAppConfig) async {

    String idServer = managedAppConfig?.remove(kManagedAppKeyIdServer);
    String relayServer = managedAppConfig?.remove(kManagedAppKeyRelayServer);
    String serverKey = managedAppConfig?.remove(kManagedAppKeyServerKey);
    setServerConfigs(idServer, relayServer, serverKey);

    String password = managedAppConfig?.remove(kManagedAppKeyPassword);
    String id = managedAppConfig?.remove(kManagedAppKeyId);
    if(password.isNotEmpty){
      bind.mainSetPermanentPasswordWithResult(password: password);
      bind.mainSetOption(key: kOptionVerificationMethod, value: kUsePermanentPassword);
      gFFI.serverModel.updatePasswordModel();
    }
    if(id.isNotEmpty){
      bind.mainMdmSetId(newId: id);
      ManagedAppConfigs.id=id;
    }
    if("false"== managedAppConfig?.remove(kManagedAppShowScamWarning)){
      // disabeling scam warning --> not needed for managed devices in a MDM system
        bind.mainSetLocalOption(key: "show-scam-warning", value: "N");
    }
    if("true"== managedAppConfig?.remove(kManagedAppStartConnectionService)){
      await gFFI.serverModel.startService();
      bind.pluginSyncUi(syncTo: kAppTypeMain);
      bind.pluginListReload();
    }
    if("true"== managedAppConfig?.remove(kManagedAppDisableSettings)){
      bind.setHarrrrdOptidsdon(key: "disable-settings", value: "Y");
    }else{
      bind.setHarrrrdOptidsdon(key: "disable-settings", value: "N");
    }
    if("true"== managedAppConfig?.remove(kManagedAppIncomingOnly)){
      bind.setHarrrrdOptidsdon(key: "conn-type", value: "incoming");
    }else {
      bind.setHarrrrdOptidsdon(key: "conn-type", value: "");
    }

    //for all settings that are not accessable in the flutter code



  }
  Future<void> setServerConfigs(String idServer,String relayServer,String serverKey) async {
    RxString idServerMsg = ''.obs;
    RxString relayServerMsg = ''.obs;
    RxString apiServerMsg = ''.obs;

    final errMsgs = [
      idServerMsg,
      relayServerMsg,
      apiServerMsg,
    ];
    await setServerConfig(
    null,
    errMsgs,
    ServerConfig(
        idServer: idServer.trim(),
        relayServer: relayServer.trim(),
        apiServer: "".trim(),
        key: serverKey.trim()));
  }
}
