import { Const, DemoBooleanValue, DemoHodorHttpErrorCallbackType } from '../pages/Const';
import { DemoApp } from '../utils/DemoApp';
import { DemoSp } from '../utils/DemoSp';
import { MediaBean, MediaInputType } from './MediaBean';
import { util } from '@kit.ArkTS';
import { DemoUtil, getAppConfig } from '../utils/DemoUtil';
import { DemoSetItem, DemoSetItemNumber, DemoSetItemString, SETTING_ITEM_APP_CONFIG, SETTING_ITEM_TYPE_LIVE, SETTING_ITEM_TYPE_NORMAL } from './DemoSetItem';
import { DemoSetTypes } from './DemoSetItem';
import { BuildProfile, KSLogLevel, KSRepresentation, KSStartPlayType, VideoCodecType } from '@kwai/streamlake-mediaplayer';

export const url_265_480_girl = "http://tx-playback.video.yximgs.com/mediacloud/demo/demo_video/kQOGfMsmAxe1Qtu6LuZ_oojT9p9MHx2inxahAaTrBuZ9kd5qN5yVZSxoKlBw55gV.mp4";

export const url_265_720_girl = "http://tx-playback.video.yximgs.com/mediacloud/demo/demo_video/kQOGfMsmAxe1Qtu6LuZ_oh1_0uOtCogxO5hFTXBPG4227dV5OeKosh9KZq6iG-tn.mp4";

export const url_265_1080_girl = "http://tx-playback.video.yximgs.com/mediacloud/demo/demo_video/H2Kvc0iPbPYMdBQYjJ9TzxY63ZtSPI1pskrDsd-VfPpdJRRvjE9LKr8tq5KnNOeM.mp4";

export const url_error_403 = "https://m2.kwaicdn.com/bs2/image-music/mbm_B6nZff8ET7U_jLoaZWBCIWg_v.m4a?pkey=AAVR_zPS6oG_satUOMzD2QhBargImg5ZJWvRpM_727TjH0taURRhPZ2uJaDVzU1SEDxfvYkMesac72T8kfXOQguQZgTju26Ih7TPm8x2S6BUfeGetBLaRif3Z4MIqR5GGn0";

export class DemoData {
  public static sAppId = "ks688206320011921833";
  public static sDeviceId = "";
  private static sInstance: DemoData;
  private mCallbacks: DataUpdateCallback[] = [];
  private mList: Array<MediaBean> = new Array<MediaBean>();
  private mSettingList: Array<DemoSetItem<DemoSetTypes>> = new Array();
  private mMultiQualityUrl: KSRepresentation[] = [
    new KSRepresentation(1, url_265_480_girl, "480p", "标清"),
    new KSRepresentation(2, url_265_720_girl, "720p", "高清"),
    new KSRepresentation(3, url_265_1080_girl, "1080p", "超清"),
    new KSRepresentation(4, url_error_403, "403", "403")
  ]

  private constructor() {
    this.initPlayList()
  }

  public static getInstance() {
    if (!DemoData.sInstance) {
      DemoData.sInstance = new DemoData()
    }
    return DemoData.sInstance;
  }

  private initPlayList() {
    this.mList.push(new MediaBean("点播输入url", "", MediaInputType.PLAY_ITEM_VOD_INPUT))
    this.mList.push(new MediaBean("直播输入url", "", MediaInputType.PLAY_ITEM_LIVE_INPUT))

    this.mList.push(new MediaBean("打开本地音视频文件", "/storage/Users/currentUser/", MediaInputType.PLAY_ITEM_LOCAL_STORAGE_AV_FILE).setVideoId("0984365823"));
    this.mList.push(new MediaBean("H264 540p", "http://tx-playback.video.yximgs.com/mediacloud/demo/demo_video/kQOGfMsmAxe1Qtu6LuZ_olgvq3FtL87oVtpCGoJtSK49Hc_F-Rm0mokdfNqpPdgd.mp4").setVideoId("1984365823123561"));
    this.mList.push(new MediaBean("H264 720p", "http://tx-playback.video.yximgs.com/mediacloud/demo/demo_video/kQOGfMsmAxe1Qtu6LuZ_ojbOTtA5b_Xsonm_dF5bbshwxQ4tCKsHe2w8ahjRB0CA.mp4").setVideoId("1984365823123562"));
    this.mList.push(new MediaBean("H264 1080p", "http://tx-playback.video.yximgs.com/mediacloud/demo/demo_video/H2Kvc0iPbPYMdBQYjJ9Tz8TDyKaXZ5W1qeyzXHUEXMYixH3nXjz6DHQpj2npqqqG.mp4").setVideoId("1984365823123563"));
    this.mList.push(new MediaBean("H264 4K 25fps", "https://tx-playback.video.yximgs.com/mediacloud/demo/demo_video/i0nZBOz4qeO7k4clJgZ8sIwAdBaThKUH4nXPmvf86eAvlZY0O7CH29zrFdd5r09s.mp4").setVideoId("1984365823123564"));
    this.mList.push(new MediaBean("H264 1080p 60fps", "https://tx-playback.video.yximgs.com/mediacloud/demo/demo_video/RTplkH9L1MJeNgoiQMzg1gPMF-LrT_o0tgF3wfc8VxxHuZVEj_Lu92cTDln_mFcs.mp4").setVideoId("1984365823123565"));
    this.mList.push(new MediaBean("H265 480p", "http://tx-playback.video.yximgs.com/mediacloud/demo/demo_video/kQOGfMsmAxe1Qtu6LuZ_oojT9p9MHx2inxahAaTrBuZ9kd5qN5yVZSxoKlBw55gV.mp4").setVideoId("2984365823123561"));
    this.mList.push(new MediaBean("H265 720p", "http://tx-playback.video.yximgs.com/mediacloud/demo/demo_video/kQOGfMsmAxe1Qtu6LuZ_oh1_0uOtCogxO5hFTXBPG4227dV5OeKosh9KZq6iG-tn.mp4").setVideoId("2984365823123562"));
    this.mList.push(new MediaBean("H265 1080p", "http://tx-playback.video.yximgs.com/mediacloud/demo/demo_video/H2Kvc0iPbPYMdBQYjJ9TzxY63ZtSPI1pskrDsd-VfPpdJRRvjE9LKr8tq5KnNOeM.mp4").setVideoId("2984365823123563"));
    this.mList.push(new MediaBean("H265 4K 25fps", "https://tx-playback.video.yximgs.com/mediacloud/demo/demo_video/i0nZBOz4qeO7k4clJgZ8sCF8886wU7vqDKe3WXYbd0LSSYDqz-tPMBe0Rcphj_L1.mp4").setVideoId("2984365823123564"));
    this.mList.push(new MediaBean("H265 1080p 60fps", "https://tx-playback.video.yximgs.com/mediacloud/demo/demo_video/RTplkH9L1MJeNgoiQMzg1qKYmrxM3EZGhd82E4H8DPjVoMWBnjxkPyLReuss6LUr.mp4").setVideoId("2984365823123565"));
    this.mList.push(new MediaBean(
      "tuzi",
      "http://hwmov.a.yximgs.com/upic/2020/05/25/17/BMjAyMDA1MjUxNzI3MzRfMTA4NzI5ODA2MV8yOTI1MjgxODczMV8xXzM=_swft_B022b988b818f8462e12edf60357c66ae.mp4?tag=1-1590642115-scn-0-7hqksz4scu-6d97ccd173cb6c0a&type=hot&tt=swft&di=db8f9932&bp=10301",
      MediaInputType.PLAY_ITEM_VOD_SINGLE_URL
    ).setVideoId("123800"));
    this.mList.push(new MediaBean(
      "60fps电车",
      "http://txmov2.a.yximgs.com/ksc1/owimHlZ5tixXhTCc-CbLNcxSkE-uiPmxDZLOVpmpTCVu7tBt47xLeJ9X7-yBBPi1tAzMxH0fMpWWIgUncO2T_qLQKGbpPh2ks6zGNwLEhXjgdg9U2SeEKo9Xe5wyEkHgyi68Fc7t-sF6Tsxx_GIbqVQvoLWzgZkWkZQnvu53adpqHmucqWMCuqEgmkYEPvem.mp4?pkey=AAWnyCqA2m_NvXxKH7xtZHFh3P_EnbmuMe2eaXwbQhPVx71vASrkjdrKVQ3QZRzbDm1qKhwJLE5wqEX-fmu4sotVRX_21FnKQGIcxiOE5HYv7CEF-Zp7b0z0HhSzisHj_B8&tag=1-1655432831-l-0-y7ggdqnyfd-8b463e047e52b9aa&type=hot&clientCacheKey=3xmd74y53t38aai_uhvnus.mp4&di=7ae056c3&bp=10211&tt=uhvnus&ss=vp",
      MediaInputType.PLAY_ITEM_VOD_SINGLE_URL
    ).setVideoId("123802"));
    this.mList.push(new MediaBean(
      "绿边",
      "http://hwmov.a.yximgs.com/upic/2020/06/06/21/BMjAyMDA2MDYyMTE2MDRfODE3MDA4MjA2XzMwMDExODU5OTM5XzFfMw==_h1kxp2_Bce49271da63f14ef23111b0ffe51541e.mp4?tag=1-1591663869-h-0-2rnrdo67g9-a7798d7d63f8ecaf&type=hot&tt=h1kxp2&di=3cbab9ac&bp=10111",
      MediaInputType.PLAY_ITEM_VOD_SINGLE_URL
    ).setVideoId("123803"));
    this.mList.push(new MediaBean("hdr_1080p", "http://tx-playback.video.yximgs.com/mediacloud/demo_test/demo_test_video/511c949ce6e4ae70-24ccf8def8c60ef6b50a3a620ff7a967-1080p_x265_hdr_cloud_veryslow_1.mp4", MediaInputType.PLAY_ITEM_VOD_SINGLE_URL).setVideoId("8472623553"))
    this.mList.push(new MediaBean("清晰度切换", this.mMultiQualityUrl[1].url, MediaInputType.PLAY_ITEM_MULTI_QUALITY).setQualityArray(this.mMultiQualityUrl).setVideoId("9999999"))
    this.mList.push(new MediaBean(
      "音频301947.mp3",
      "https://music.163.com/song/media/outer/url?id=301947.mp3",
      MediaInputType.PLAY_ITEM_VOD_SINGLE_URL
    ).setCacheKey("music.163.com-song-media-outer-url?id=301947"));
    this.mList.push(new MediaBean(
      "音频430685732.mp3",
      "https://music.163.com/song/media/outer/url?id=430685732.mp3",
      MediaInputType.PLAY_ITEM_VOD_SINGLE_URL
    ).setCacheKey("music.163.com-song-media-outer-url?id=430685732"));

    this.mList.push(new MediaBean(
      "403 retry",
      "http://v1.oskwai.com/ksc2/vDxwAc9P71ME1cEI5Zd6OvCpQdAfqMtVHZPhGKQkJTcl6q6ys8NrwC5EM1tqnQVbwmAL9Lyo9WXE9Ccz-nC7g826cyDJUQkgX1Po8AjfvP9V6HGbxsMukQ0vrtHTAWdh0sKU2i7LHWVWIWRV3C2qnYQPY0uyrD7Yu1u1GHz8sS3exe2x61VvHExSxeq9MYRc.mp4?pkey=AAX1J8zzK5XvaVqi8mm2CMPofXi_g5GApa9VEG5fpIY6Q21mfgvlHMoz9rhCmXU2UzClzAnThn8zV0Eu_P7OamnwUCr0FasZrvDgj2-1RIWXU_71caJJdce9EuEuHNFqBsM&tag=1-1705925177-bs-0-7fjynegzia-9d97db8af3355eb2&type=hot&clientCacheKey=3xzhzfnfzhugh29_k26HighV4.mp4&di=6766cbcf&bp=10331&tt=k26HighV4&ss=vp",
      MediaInputType.PLAY_ITEM_VOD_SINGLE_URL
    ));
    // String.fromCharCode()
    this.mList.push(new MediaBean(
      "vod manifest",
      DemoUtil.Uint8ArrayToString(DemoApp.CONTEXT.resourceManager.getRawFileContentSync("demo_manifest_v2_vod_online_version.txt")),
      MediaInputType.PLAY_ITEM_VOD_MANIFEST
    ));

    this.mList.push(new MediaBean(
      "m3u8_nlav10895_url_2(320*184)",
      "https://s2-10895.kwimgs.com/kos/nlav10895/test-video/hls/url_2/193039199_mp4_h264_aac_ld_7.m3u8",
      MediaInputType.PLAY_ITEM_HLS_SINGLE_URL
    ))
    this.mList.push(new MediaBean(
      "m3u8_nlav10895_url_4(512*288)",
      "https://s2-10895.kwimgs.com/kos/nlav10895/test-video/hls/url_4/193039199_mp4_h264_aac_7.m3u8",
      MediaInputType.PLAY_ITEM_HLS_SINGLE_URL
    ))
    this.mList.push(new MediaBean(
      "m3u8_nlav10895_url_6(848*480)",
      "https://s2-10895.kwimgs.com/kos/nlav10895/test-video/hls/url_6/193039199_mp4_h264_aac_hq_7.m3u8",
      MediaInputType.PLAY_ITEM_HLS_SINGLE_URL
    ))

    // 之前扫一扫的结果
    const scan: string = DemoSp.getInstance().getValueString(Const.KEY_SCAN, "");
    if (scan.length > 0) {
      DemoUtil.createScanItem(scan, false).forEach((item: MediaBean) => {
        this.mList.push(item);
      })
    }
  }

  public getPlayList(): Array<MediaBean> {
    return this.mList.slice()
  }

  public registerDataUpdateCallback(callback: DataUpdateCallback) {
    callback && this.mCallbacks.push(callback);
  }

  public updateAppVideo(arr: Array<MediaBean>) {
    this.mList.push(...arr);
    this.mCallbacks.forEach(c => {
      c.onDataAdded(arr);
    })
  }

  public getSettingList(): Array<DemoSetItem<DemoSetTypes>> {
    console.log("zzh", "zzhtestapp get settinglist");
    if (this.mSettingList.length <= 0) {
      // 1 normal
      this.mSettingList.push(createSettingItemString("设备did(杀进程生效)", Const.KEY_DEVICE_ID, DemoData.sDeviceId, []));
      this.mSettingList.push(createSettingItemNumber("日志打印等级(杀进程生效)", Const.KEY_LOG_LEVEL, KSLogLevel.Debug, [
        [KSLogLevel.Debug, "Debug"],
        [KSLogLevel.Info, "Info"],
        [KSLogLevel.Warn, "Warn"],
        [KSLogLevel.Error, "Error"],
        [KSLogLevel.None, "关闭"],
      ]));
      this.mSettingList.push(createSettingItemNumber("软硬解", Const.KEY_CODEC_TYPE, VideoCodecType.DEFAULT_DECODE, [
        [VideoCodecType.DEFAULT_DECODE, `默认`],
        [VideoCodecType.FORCE_HW_DECODE, `强制硬解`],
        [VideoCodecType.FORCE_SW_DECODE, `强制软解`],
      ]));
      this.mSettingList.push(createSettingItemNumber("精准seek", Const.KEY_ACCURATE_SEEK, DemoBooleanValue.BOOLEAN_YES, [
        [DemoBooleanValue.BOOLEAN_NO, "关闭"],
        [DemoBooleanValue.BOOLEAN_YES, "开启"],
      ]));
      this.mSettingList.push(createSettingItemNumber("StartPlayType", Const.KEY_PLAY_SETTING_START_PLAY_TYPE, KSStartPlayType.StartOnPrepare, [
        [KSStartPlayType.PreDecode, "pre decode"],
        [KSStartPlayType.PreLoad, "pre load"],
        [KSStartPlayType.StartOnPrepare, "start on prepare"],
      ]));
      this.mSettingList.push(createSettingItemNumber("历史进度播放", Const.KEY_PLAY_FROM_HISTORY, DemoBooleanValue.BOOLEAN_NO, [
        [DemoBooleanValue.BOOLEAN_NO, "关闭"],
        [DemoBooleanValue.BOOLEAN_YES, "开启"],
      ]));
      this.mSettingList.push(createSettingItemNumber("开播位置s", Const.KEY_START_PLAY_POS, -1, []));
      this.mSettingList.push(createSettingItemNumber("点播maxBufferDurationBspMs(毫秒)", Const.KEY_MAX_BUFFER_DURATION_BSP_MS, -1, []));
      this.mSettingList.push(createSettingItemNumber("点播maxBufferDurationMs(毫秒)", Const.KEY_MAX_BUFFER_DURATION_MS, -1, []));
      this.mSettingList.push(createSettingItemNumber("强制首帧渲染", Const.KEY_ENABLE_FIRST_FRAME_FORCE_RENDER, DemoBooleanValue.BOOLEAN_NO, [
        [DemoBooleanValue.BOOLEAN_NO, "关闭"],
        [DemoBooleanValue.BOOLEAN_YES, "开启"],
      ]));
      this.mSettingList.push(createSettingItemNumber("开启hodor cache", Const.KEY_HODOR_CACHE, DemoBooleanValue.BOOLEAN_YES, [
        [DemoBooleanValue.BOOLEAN_NO, "关闭"],
        [DemoBooleanValue.BOOLEAN_YES, "开启"],
      ]));
      // 2 live
      this.mSettingList.push(createSettingItemNumber("数据源重拉fetch", Const.KEY_REFRESH_DATA_SOURCE, DemoBooleanValue.BOOLEAN_YES, [
        [DemoBooleanValue.BOOLEAN_NO, "关闭"],
        [DemoBooleanValue.BOOLEAN_YES, "开启"],
      ], SETTING_ITEM_TYPE_LIVE));
      this.initAppConfig()
    }
    return this.mSettingList
  }

  private initAppConfig() {
    let baseInfo: object = new Object();
    baseInfo["appId"] = DemoData.sAppId;
    baseInfo["deviceId"] = DemoData.sDeviceId;
    baseInfo["ksmediaplayer_version"] = BuildProfile.HAR_VERSION;
    baseInfo["ksmediaplayer_build_mode"] = BuildProfile.BUILD_MODE_NAME;
    baseInfo["ksmediaplayer_target_name"] = BuildProfile.TARGET_NAME;
    this.mSettingList.push(createSettingItemString("baseinfo", Const.KEY_APP_CONFIG_BASE_INFO, JSON.stringify(baseInfo, null, '  '), [], SETTING_ITEM_APP_CONFIG));
    // app config
    let jsonObj = getAppConfig()
    let dataObj: object = jsonObj && jsonObj["data"]
    if (!dataObj) {
      return
    }
    if (dataObj["ksvodplayer"] && dataObj["ksvodplayer"]["config"]) {
      // 1
      let aemonglobal: string = dataObj["ksvodplayer"]["config"]["aemonPlayerGlobalParams"]
      aemonglobal && (typeof aemonglobal == 'string') && (dataObj["ksvodplayer"]["config"]["aemonPlayerGlobalParams"] = aemonglobal = JSON.parse(aemonglobal))
      // 2
      let aemonrender: string = dataObj["ksvodplayer"]["config"]["aemonPlayerRenderParams"]
      aemonrender && (typeof aemonrender == 'string') && (dataObj["ksvodplayer"]["config"]["aemonPlayerRenderParams"] = aemonrender = JSON.parse(aemonrender))
      // 3
      let aemonbinstance: string = dataObj["ksvodplayer"]["config"]["aemonPlayerInstanceParams"]
      aemonbinstance && (typeof aemonbinstance == 'string') && (dataObj["ksvodplayer"]["config"]["aemonPlayerInstanceParams"] = aemonbinstance = JSON.parse(aemonbinstance))
      // 4
      let aemonbuffer: string = dataObj["ksvodplayer"]["config"]["aemonPlayerBufferParams"]
      aemonbuffer && (typeof aemonbuffer == 'string') && (dataObj["ksvodplayer"]["config"]["aemonPlayerBufferParams"] = aemonbuffer = JSON.parse(aemonbuffer))
      this.mSettingList.push(createSettingItemString("vod", Const.KEY_APP_CONFIG_VOD, JSON.stringify(dataObj["ksvodplayer"]["config"], null, '  '), [], SETTING_ITEM_APP_CONFIG))
    }
    if (dataObj["ksliveplayer"] && dataObj["ksliveplayer"]["config"]) {
      // 1
      let aemonglobal: string = dataObj["ksliveplayer"]["config"]["aemonPlayerGlobalParams"]
      aemonglobal && (typeof aemonglobal == 'string') && (dataObj["ksliveplayer"]["config"]["aemonPlayerGlobalParams"] = aemonglobal = JSON.parse(aemonglobal))
      // 2
      let aemonrender: string = dataObj["ksliveplayer"]["config"]["aemonPlayerRenderParams"]
      aemonrender && (typeof aemonrender == 'string') && (dataObj["ksliveplayer"]["config"]["aemonPlayerRenderParams"] = aemonrender = JSON.parse(aemonrender))
      // 3
      let aemonbinstance: string = (dataObj["ksliveplayer"]["config"]["aemonPlayerInstanceParams"])
      aemonbinstance && (typeof aemonbinstance == 'string') && (dataObj["ksliveplayer"]["config"]["aemonPlayerInstanceParams"] = aemonbinstance = JSON.parse(aemonbinstance))
      // 4
      let aemonbuffer: string = dataObj["ksliveplayer"]["config"]["aemonPlayerBufferParams"]
      aemonbuffer && (typeof aemonbuffer == 'string') && (dataObj["ksliveplayer"]["config"]["aemonPlayerBufferParams"] = aemonbuffer = JSON.parse(aemonbuffer))
      // 5
      let configjson: string = dataObj["ksliveplayer"]["config"]["configJson"]
      configjson && (typeof configjson == 'string') && (dataObj["ksliveplayer"]["config"]["configJson"] = configjson = JSON.parse(configjson))
      this.mSettingList.push(createSettingItemString("live", Const.KEY_APP_CONFIG_LIVE, JSON.stringify(dataObj["ksliveplayer"]["config"], null, '  '), [], SETTING_ITEM_APP_CONFIG))
    }
    if (dataObj["smartdnsv2"] && dataObj["smartdnsv2"]["config"]) {
      this.mSettingList.push(createSettingItemString("smartdnsv2", Const.KEY_APP_CONFIG_SMARTDNSV2, JSON.stringify(dataObj["smartdnsv2"]["config"], null, '  '), [], SETTING_ITEM_APP_CONFIG))
    }
    if (dataObj["obiwan"] && dataObj["obiwan"]["config"]) {
      this.mSettingList.push(createSettingItemString("obiwan", Const.KEY_APP_CONFIG_OBIWAN, JSON.stringify(dataObj["obiwan"]["config"], null, '  '), [], SETTING_ITEM_APP_CONFIG))
    }
  }
}

function createSettingItemNumber(name: string, key: string, defaultValue: number, options: Array<[number, string]>, type: number = SETTING_ITEM_TYPE_NORMAL): DemoSetItemNumber {
  let item: DemoSetItemNumber = new DemoSetItemNumber();
  item.name = name;
  item.key = key;
  item.type = type;
  item.options = options;
  item.init(defaultValue);
  return item;
}

function createSettingItemString(name: string, key: string, defaultValue: string, options: Array<[string, string]>, type: number = SETTING_ITEM_TYPE_NORMAL): DemoSetItemString {
  let item: DemoSetItemString = new DemoSetItemString();
  item.isnumber = false;
  item.name = name;
  item.key = key;
  item.type = type;
  item.options = options;
  item.init(defaultValue);
  return item;
}


export interface DemoPlayerState {
  key: string,
  value: string
}
;

export interface DemoPlayerStateGet {
  key: string,
  func: Function
}

export interface DataUpdateCallback {
  onDataAdded: (data: Array<MediaBean>) => void;
}

export function appVideoDir(): string {
  return getContext().filesDir + "/appvideo/";
}
