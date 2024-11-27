import { HashMap, util } from '@kit.ArkTS';
import { MediaBean, MediaInputType } from '../data/MediaBean';
import { Const } from '../pages/Const';
import { DemoSp } from './DemoSp';
import { promptAction } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { KSAppConfig, KSDebugViewController } from '@kwai/streamlake-mediaplayer';
import { ActionQueue } from './ActionQueue';
import { DemoNetworkType } from '../data/DemoNetworkType';
import wifiManager from '@ohos.wifiManager';
import data from '@ohos.telephony.data';
import radio from '@ohos.telephony.radio';

export class DemoUtil {
  public static maxLength: number = 3950;
  public static kManifestDummy: string = "kflv://manifest_string";
  public static kManifestSample: string = "{\n" +
    "      \"version\": \"2.0\",\n" +
    "      \"type\": \"dynamic\",\n" +
    "      \"isFreeTrafficCdn\": false,\n" +
    "      \"adaptationSet\":" +
    "      {\n" +
    "          \"representation\":" +
    "              [\n" +
    "                  {\n" +
    "                      \"url\" : \"kflv://manifest_string\",\n" +
    "                      \"id\" : 2,\n" +
    "                      \"bitrate\" : 2000\n" +
    "                  }\n" +
    "              ]\n" +
    "      }\n" +
    "}";

  public static Uint8ArrayToString(input: Uint8Array): string {
    let textDecoder = util.TextDecoder.create('utf-8', { ignoreBOM: true });
    // return textDecoder.decodeWithStream(input);
    return textDecoder.decodeToString(input);
  }

  public static createScanItem(url: string, save: boolean): MediaBean[] {
    if (save && url) {
      DemoSp.getInstance().setValueString(Const.KEY_SCAN, url);
    }
    const islive: boolean = url.indexOf(".flv") != -1;
    const list: Array<MediaBean> = new Array<MediaBean>();

    let type = islive ? MediaInputType.PLAY_ITEM_LIVE_SINGLE_URL : MediaInputType.PLAY_ITEM_VOD_SINGLE_URL;
    const item: MediaBean = new MediaBean(`扫一扫-${islive ? "LIVE" : "VOD"}`, url, type);
    list.push(item);

    // create live manifest
    if (islive) {
      let urlLive = DemoUtil.kManifestSample.replace(DemoUtil.kManifestDummy, url);
      const item: MediaBean = new MediaBean("扫一扫-LiveManifest", urlLive, MediaInputType.PLAY_ITEM_LIVE_MANIFEST);
      list.push(item);
    }
    return list;
  }

  public static showToast(message: string, duration: number = 2000, alignment: Alignment = Alignment.Bottom) {
    ActionQueue.getIns().enqueue({
      run: (): void => {
        try {
          promptAction.showToast({
            message: message,
            duration: duration,
            bottom: "0",
            alignment: alignment,
          })
        } catch (error) {
          console.error(`showToast args error code is ${error.code}, message is ${error.message}`);
        }
      },
      duration: duration
    })
  }

  public static String2List(msg: string): string[] {
    let list: string[] = [];
    msg = msg.trim();
    let index = 0;
    let sub: string;
    while (index < msg.length) {
      if (msg.length <= index + DemoUtil.maxLength) {
        sub = msg.substring(index);
      } else {
        sub = msg.substring(index, index + DemoUtil.maxLength);
      }
      index += DemoUtil.maxLength;
      list.push(sub);
    }
    return list;
  }
}

export function demologi(tag: string = 'ksplayer', msg: string | string[]): void {
  if (typeof msg === 'string') {
    if (msg && msg.length > DemoUtil.maxLength) {
      demologi(tag, DemoUtil.String2List(msg));
    } else {
      hilog.info(0x0000, "sl_player", '%{public}s', tag + " " + msg);
    }
  } else {
    msg.forEach(m => demologi(tag, m));
  }
}

export function demologw(tag: string = 'ksplayer', msg: string | string[]): void {
  if (typeof msg === 'string') {
    if (msg && msg.length > DemoUtil.maxLength) {
      demologw(tag, DemoUtil.String2List(msg));
    } else {
      hilog.warn(0x0000, "sl_player", '%{public}s', tag + " " + msg);
    }
  } else {
    msg.forEach(m => demologw(tag, m));
  }
}

export function demologe(tag: string = 'ksplayer', msg: string | string[]): void {
  if (typeof msg === 'string') {
    if (msg && msg.length > DemoUtil.maxLength) {
      demologe(tag, DemoUtil.String2List(msg));
    } else {
      hilog.error(0x0000, "sl_player", '%{public}s', tag + " " + msg);
    }
  } else {
    msg.forEach(m => demologe(tag, m));
  }
}

export function showErrorDialog(error: string) {
  AlertDialog.show({
    message: error,
    textStyle: { fontSize: 24, fontColor: Color.Red },
    autoCancel: true,
    height: 160,
    alignment: DialogAlignment.Center,
  })
}

export function mapToQueryStr(map?: HashMap<Object, Object>) {
  let str = ""
  map?.forEach((value, key) => {
    if (key) {
      let separator = str ? "&" : "?";
      str = str + separator + key + "=" + value;
    }
  });
  return str;
}

export function getNetworkType(): number {
  try {
    if (canIUse('SystemCapability.Communication.WiFi.STA') && wifiManager.isWifiActive()) {
      return DemoNetworkType.Wifi;
    } else if (canIUse('SystemCapability.Telephony.CoreService') && canIUse('SystemCapability.Telephony.CellularData')) {
      const slotId = data.getDefaultCellularDataSlotIdSync();
      const info = radio.getSignalInformationSync(slotId);
      if (!info.length) {
        return DemoNetworkType.Unknown;
      }

      if (info.find(i => i.signalType === radio.NetworkType.NETWORK_TYPE_NR)) {
        return DemoNetworkType.FiveG;
      } else if (info.find(i => i.signalType === radio.NetworkType.NETWORK_TYPE_LTE)) {
        return DemoNetworkType.FourG;
      } else if (info.find(i => i.signalType === radio.NetworkType.NETWORK_TYPE_TDSCDMA || i.signalType === radio.NetworkType.NETWORK_TYPE_WCDMA)) {
        return DemoNetworkType.ThreeG;
      } else if (info.find(i => i.signalType === radio.NetworkType.NETWORK_TYPE_GSM || i.signalType === radio.NetworkType.NETWORK_TYPE_CDMA)) {
        return DemoNetworkType.TwoG;
      }
    }
  } catch (e) {
    // e.code
  }

  return DemoNetworkType.Unknown;
}

export function numberToMKB(num: number): string {
  if (!isNumber(num)) {
    return `${num}`;
  }
  let fstNumIndex = num >= 0 ? 0 : 1;
  let indicator = 1;
  let str = `${num}`
  let ret = ""
  for (let i = str.length - 1; i >= 0; i--) {
    ret = str.charAt(i) + ret;
    indicator % 3 == 0 && i > fstNumIndex && (ret = "," + ret);
    ++indicator;
  }
  return ret
}

export function isNumber<T>(str: T): boolean {
  if (typeof str == 'boolean'
    || typeof str == 'object'
    || typeof str == 'undefined') {
    return false
  }
  let vNumber = Number(str)
  return isNaN(vNumber) ? false : true
}

export class ComponentRef<T> {
  value?: T

  export(ref: T) {
    this.value = ref
  }

  static useRef<T>() {
    return new ComponentRef<T>()
  }
}

export interface DemoTabLiteralInterface {
  change: (index: number) => void;
}

@CustomDialog
@Component
export struct CustomDialogExample {
  title: string = ""
  defaultValue: string = ""
  callbackValue: string = ""
  controller?: CustomDialogController
  // 若尝试在CustomDialog中传入多个其他的Controller，以实现在CustomDialog中打开另一个或另一些CustomDialog，那么此处需要将指向自己的controller放在所有controller的后面
  cancel: () => void = () => {
  }
  confirm: (value: string) => void = () => {
  }

  build() {
    Column() {
      Text(`${this.title}`).fontSize(20).margin({ top: 10, bottom: 10 })
      TextInput({ placeholder: '', text: this.defaultValue }).height(60).width('90%')
        .onChange((value: string) => {
          this.defaultValue = value
        })
      Text('').fontSize(16).margin({ bottom: 10 })
      Flex({ justifyContent: FlexAlign.SpaceAround }) {
        Button('cancel')
          .onClick(() => {
            if (this.controller != undefined) {
              this.controller.close()
            }
            this.cancel()
          }).backgroundColor(0xffffff).fontColor(Color.Black)
        Button('confirm')
          .onClick(() => {
            if (this.controller != undefined) {
              this.callbackValue = this.defaultValue
              this.controller.close()
            }
            this.confirm(this.defaultValue)
          }).backgroundColor(0xffffff).fontColor(Color.Red)
      }.margin({ bottom: 10 })

    }.borderRadius(10)

    // 如果需要使用border属性或cornerRadius属性，请和borderRadius属性一起使用。
  }
}

// ------------------------------华丽分割线---------------------------------------------------------------------
export function startVodDebugMonitor(player?: object, ctrl?: object) {
}

export function stopVodDebugMonitor(player?: object, ctrl?: object) {
}

export function getWayneBriefVodStatJson(player?: object): string {
  return "";
}

export function getWayneVodStatJson(player?: object): string {
  return "";
}

export function getWaynePlayerTsJson(player?: object) {
  return "";
}

export function getUserSetRepId(player?: object): number {
  return -1
}

export function getRealRepId(player?: object): number {
  return -1
}

export function showLiveDebugView(player?: object, controller?: KSDebugViewController) {
}

export function getAppConfig(): object | undefined {
  return undefined
}

export function injectLiveQos(livePlayer?: object, cb?: (qos: object) => void) {
}

interface DemoDebugInfoViewController {
  startMonitor: (oo?: object) => void;
  stopMonitor: (oo?: object) => void;
}

