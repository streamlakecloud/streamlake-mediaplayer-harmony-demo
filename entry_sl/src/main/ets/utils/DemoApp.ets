import { KSLogLevel, KSMediaPlayerConfig } from '@kwai/streamlake-mediaplayer';
import { Const } from '../pages/Const';
import { DemoSp } from './DemoSp';
import { demologe } from './DemoUtil';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { appVideoDir, DemoData } from '../data/DemoData';
import { fileIo as fs } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit'
import { MediaBean } from '../data/MediaBean';
import { strEmpty } from '@kwai/streamlake-mediaplayer';

export class DemoApp {
  public static CONTEXT: Context

  public static onCreate(ctx: Context) {
    DemoApp.CONTEXT = ctx;
    DemoSp.getInstance().init(ctx);
    let defaultdid = "sl_demo_did"
    let did = DemoSp.getInstance().getValueString(Const.KEY_DEVICE_ID, defaultdid);
    if (strEmpty(did)) {
      did = defaultdid;
    }
    DemoData.sDeviceId = did;
    try {
      // 1 设置日志回调监听，可以在回调里搜集日志。小于此级别的日志不会回调
      let logLevel = DemoSp.getInstance().getValueNumber(Const.KEY_LOG_LEVEL, KSLogLevel.Debug)
      KSMediaPlayerConfig.setLogConfig(logLevel, {
        v: (tag: string, msg: string): void => {
          hilog.debug(0x0000, "demo:" + tag, '%{public}s', msg);
        },
        d: (tag: string, msg: string): void => {
          hilog.debug(0x0000, "demo:" + tag, '%{public}s', msg);
        },
        i: (tag: string, msg: string): void => {
          hilog.info(0x0000, "demo:" + tag, '%{public}s', msg);
        },
        w: (tag: string, msg: string): void => {
          hilog.warn(0x0000, "demo:" + tag, '%{public}s', msg);
        },
        e: (tag: string, msg: string): void => {
          hilog.error(0x0000, "demo:" + tag, '%{public}s', msg);
        }
      });
      // 2 初始化播放器sdk
      let t1 = Date.now();
      KSMediaPlayerConfig.init(ctx, DemoData.sAppId, did);
      let t2 = Date.now();
      demologe("KSMediaPlayer", `init ksplayer cost=${t2 - t1} did=${did}`);

      DemoApp.cpFile()
    } catch (e) {
      demologe("KSMediaPlayer", `init ksplayer error=${e.stack}`)
    }
  }

  public static cpFile(): Promise<number> {
    return new Promise<number>((resolve, reject) => {
      let dir = appVideoDir();
      let filename = "time.mp4";
      let fcontent: Uint8Array = getContext().resourceManager.getRawFileContentSync(filename)
      let filePath = dir + filename;
      fs.stat(filePath, (err: BusinessError, stat: fs.Stat) => {
        if (err || stat.size <= 0) {
          fs.mkdirSync(appVideoDir());
          let file = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
          let writeLen = fs.writeSync(file.fd, fcontent.buffer);
          demologe("", "write data to file succeed and size is:" + writeLen);
          fs.closeSync(file);
        } else {
          demologe("", "write data no need:");
        }
        // update data
        let filelist: string[] = fs.listFileSync(dir);
        demologe("", "write data filelist=" + filelist)
        let beanArr: MediaBean[] = []
        for (let i = 0; i < filelist.length; i++) {
          let afilename = filelist[i]
          if (afilename.endsWith(".mp4") || afilename.endsWith(".mp3") || afilename.endsWith(".wav") || afilename.endsWith(".m4a") || afilename.endsWith(".aac")) {
            let bean: MediaBean = new MediaBean(`本地app沙箱视频-${i}-${afilename}`, dir + afilename);
            beanArr.push(bean);
          }
        }
        DemoData.getInstance().updateAppVideo(beanArr);
      });
      return resolve(1)
    })
  }
}
