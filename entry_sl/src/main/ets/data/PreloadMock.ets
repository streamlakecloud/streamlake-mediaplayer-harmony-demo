import { IKSPrefetchTask, KSMediaPlayerCache, KSMediaPlayerDownloadListener, KSPrefetchTaskBuilder, KSPrefetchType, KSPreloadConfig, KS_PRELOAD_PRIORITY, strEmpty } from "@kwai/streamlake-mediaplayer";
import { demologe, demologi, numberToMKB } from "../utils/DemoUtil";
import { VideoCardBean } from "./VideoCardBean";

let size4g = 1024 * 1024 * 3;
let sizewifi = 1024 * 1024 * 4;

export class PreloadMock {
  private static sIns: PreloadMock;
  private mNormalArr: Array<ItemPreload> = [];
  private mManifestArr: Array<ItemPreload> = [];
  private mManifestServerList: Array<VideoCardBean> = [];
  private mListener?: KSMediaPlayerDownloadListener;
  private mPrepared = false;

  private constructor() {
  }

  private initEvictLruList() {
    let priority = KS_PRELOAD_PRIORITY.MEDIUM;
    // 1
    let item1 = new ItemPreload();
    item1.url = "https://tx-playback.video.yximgs.com/mediacloud/demo/demo_video/RTplkH9L1MJeNgoiQMzg1gPMF-LrT_o0tgF3wfc8VxxHuZVEj_Lu92cTDln_mFcs.mp4";
    item1.videoId = "test_url1";
    item1.listener = this.mListener;
    let config1 = new KSPreloadConfig();
    config1.preloadBytes4G = size4g;
    config1.preloadBytesWifi = sizewifi;
    item1.config = config1;
    // 2
    let item2 = new ItemPreload();
    item2.url = "https://tx-playback.video.yximgs.com/mediacloud/demo/demo_video/i0nZBOz4qeO7k4clJgZ8sIwAdBaThKUH4nXPmvf86eAvlZY0O7CH29zrFdd5r09s.mp4";
    item2.videoId = "test_url2";
    item2.listener = this.mListener;
    let config2 = new KSPreloadConfig();
    config2.preloadBytes4G = size4g;
    config2.preloadBytesWifi = sizewifi;
    item2.config = config2;
    this.mNormalArr.push(item1.build());
    this.mNormalArr.push(item2.build());
  }

  public static getIns(): PreloadMock {
    if (!PreloadMock.sIns) {
      PreloadMock.sIns = new PreloadMock();
    }
    return PreloadMock.sIns;
  }

  public prepareData(listener: KSMediaPlayerDownloadListener): PreloadMock {
    if (!this.mListener) {
      this.mPrepared = true;
      this.mListener = listener;
      this.initEvictLruList();
    }
    return this;
  }

  public getData(): Array<ItemPreload> {
    let ret: Array<ItemPreload> = []
    if (!this.mListener) {
      return ret;
    }
    this.mNormalArr.forEach(item => {
      ret.push(item);
    });
    demologi("PRELOADTEST", "this.mManifestArr" + this.mManifestArr.length)
    this.mManifestArr.forEach(item => {
      if (!item.task) {
        item.listener = this.mListener;
        item.build();
      }
      ret.push(item);
    })
    return ret;
  }

  public getManifestData(): Array<VideoCardBean> {
    return this.mManifestServerList;
  }

  public refreshManifestData(obj?: object) {
    let titles = ["指定480p档位", "指定720p档位", "指定1080p档位", "指定4k档位", "默认"]
    this.mManifestServerList = obj as Array<VideoCardBean>;
    for (let i = 0; i < this.mManifestServerList.length; i++) {
      let serverItem = this.mManifestServerList[i];
      let exist = this.mManifestArr[i] != null && this.mManifestArr[i] != undefined
      let preloadItem = exist ? this.mManifestArr[i] : new ItemPreload();
      let manifestObj: object = JSON.parse(serverItem.manifest)
      manifestObj["mediaType"] = 2; // MediaType.MP4;
      if (Array.isArray(manifestObj["adaptationSet"])) {
        for (let j = 0; j < manifestObj["adaptationSet"].length; j++) {
          if (manifestObj["adaptationSet"][j]["vcodec"] == "hevc") {
            manifestObj["adaptationSet"][j] = undefined;
          }
        }
        manifestObj["adaptationSet"] = manifestObj["adaptationSet"].filter((item?: object) => item != undefined && item != null);
      }
      preloadItem.manifest = JSON.stringify(manifestObj);
      preloadItem.videoId = serverItem.videoId;
      preloadItem.type = KSPrefetchType.KS_PREFETCH_MANIFEST_VOD;
      let config2 = new KSPreloadConfig();
      config2.preloadBytes4G = size4g;
      config2.preloadBytesWifi = sizewifi;
      preloadItem.config = config2;
      preloadItem.mTitle= titles[i] ?? "默认";
      if (i == 0) {
        preloadItem.manifestQualityType = "480p"
      } else if (i == 1) {
        preloadItem.manifestQualityType = "720p"
      } else if (i == 2) {
        preloadItem.manifestQualityType = "1080p"
      } else if (i == 3) {
        preloadItem.manifestQualityType = "4k"
      } else if (i == 4) {
        preloadItem.manifestQualityType = ""
      }
      if (!exist) {
        this.mManifestArr.push(preloadItem)
      }
    }
  }
}

@Observed
export class ItemPreload {
  // 动态变化的字段
  public downloaded: string = "cacheSize=0"
  public cacheKey?: string;
  public isdone: boolean = false
  // 固定的配置字段
  public mTitle: string = "";
  public listener?: KSMediaPlayerDownloadListener;
  public task?: IKSPrefetchTask;
  public videoId: string = "";
  public config?: KSPreloadConfig;
  public priority?: KSPreloadConfig;
  public type: KSPrefetchType = KSPrefetchType.KS_PREFETCH_NORMAL;
  // 1 normal
  public url: string = ""
  // 2 manifest
  public manifest: string = "";
  public manifestQualityType: string = ""; // 小写p

  public build(): ItemPreload {
    if (this.type == KSPrefetchType.KS_PREFETCH_NORMAL) {
      this.downloaded = `cacheSize=${numberToMKB(KSMediaPlayerCache.getCachedSizeWithUrl(this.url, this.cacheKey))}`;
    } else if (!strEmpty(this.manifest)) {
      try {
        let manifestObj: object = JSON.parse(this.manifest);
        if (Array.isArray(manifestObj["adaptationSet"]) && manifestObj["adaptationSet"].length > 0) {
          let list: object = manifestObj["adaptationSet"][0]["representation"];
          if (Array.isArray(list)) {
            for (let j = 0; j < list.length; j++) {
              let repItem: object = list[j];
              this.downloaded = (j == 0 ? "" : `${this.downloaded}   `) + `${repItem["qualityType"]}=${numberToMKB(KSMediaPlayerCache.getCachedSizeWithUrl(repItem["url"]))}`;
            }
          }
        }
      } catch (e) {
        demologe("PRELOADTEST", `parse manifest error=${e.stack}`)
      }
    }
    this.task = new KSPrefetchTaskBuilder().setType(this.type)
      .setUrl(this.url)
      .setManifest(this.manifest)
      .setManifestQuality(this.manifestQualityType)
      .setVideoId(this.videoId)
      .setConfig(this.config)
      .setDownloadListener(this.listener)
      .setCacheKey(this.cacheKey)
      .build()
    return this;
  }
}