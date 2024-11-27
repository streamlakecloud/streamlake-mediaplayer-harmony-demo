import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import hilog from '@ohos.hilog';
import UIAbility from '@ohos.app.ability.UIAbility';
import Want from '@ohos.app.ability.Want';
import window from '@ohos.window';
import { WantAgent, wantAgent } from '@kit.AbilityKit';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { AsyncCallback, BusinessError } from '@kit.BasicServicesKit';
import { demologe, demologi } from '../utils/DemoUtil';

export default class EntryAbility extends UIAbility {
  private readonly TAG:string = "EntryAbility"

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    // Hodor.initialize(this.context, new HodorLogParam());
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.getMainWindow().then(window => window.setWindowKeepScreenOn(true));
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/KSIndex', (err, data) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content. Data: %{public}s', JSON.stringify(data) ?? '');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    console.info('testTag', '%{public}s', 'Ability onForeground');

    console.info('testTag', '%{public}s', 'Ability onBackground');
    try {
      backgroundTaskManager.stopBackgroundRunning(this.context).then(() => {
        demologi(this.TAG, "Operation stopBackgroundRunning succeeded");
      }).catch((error: BusinessError) => {
        demologe(this.TAG, `Operation stopBackgroundRunning failed. code is ${error.code} message is ${error.message}`);
      });
    } catch (error) {
      demologe(this.TAG, `Operation stopBackgroundRunning failed. code is ${(error as BusinessError).code} message is ${(error as BusinessError).message}`);
    }
  }

  onBackground(): void {
    // Ability has back to background

    let wantAgentInfo: wantAgent.WantAgentInfo = {
      // 点击通知后，将要执行的动作列表
      wants: [
        {
          bundleName: "com.kwai.video.waynedemo",
          abilityName: "EntryAbility"
        }
      ],
      // 点击通知后，动作类型
      operationType: wantAgent.OperationType.START_ABILITY,
      // 使用者自定义的一个私有值
      requestCode: 0,
      // 点击通知后，动作执行属性
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    };

    try {
      // 通过wantAgent模块下getWantAgent方法获取WantAgent对象
      wantAgent.getWantAgent(wantAgentInfo).then((wantAgentObj: WantAgent) => {
        try {
          backgroundTaskManager.startBackgroundRunning(this.context,
            backgroundTaskManager.BackgroundMode.LOCATION, wantAgentObj).then(() => {
            demologi(this.TAG, "Operation startBackgroundRunning succeeded");
          }).catch((error: BusinessError) => {
            demologe(this.TAG, `Operation startBackgroundRunning failed. code is ${error.code} message is ${error.message}`);
          });
        } catch (error) {
          demologe(this.TAG, `Operation startBackgroundRunning failed. code is ${(error as BusinessError).code} message is ${(error as BusinessError).message}`);
        }
      });
    } catch (error) {
      demologe(this.TAG, `Operation getWantAgent failed. code is ${(error as BusinessError).code} message is ${(error as BusinessError).message}`);
    }
  }
}
