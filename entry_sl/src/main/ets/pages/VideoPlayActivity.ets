import router from '@ohos.router';
import {
  BuildProfile,
  KSAppConfig,
  KSUrlType,
  KSDataSourceFetchCallback,
  KSFetchReason,
  VideoCodecType,
  IKSVodPlayer,
  KSDebugView,
  KSDebugViewController,
  KSMediaPlayerBuilder,
  KSMediaPlayerCache,
  KSRepresentation,
  KSStartPlayType,
  KSSurfaceInfo,
  KSPlayerState,
  KSMediaPlayerConstants,
  PlayBufferConfig
} from '@kwai/streamlake-mediaplayer';
import { isManifest, isSingleUrl, MediaBean, MediaInputType } from '../data/MediaBean';
import { formatTime, localTimeStr } from '../utils/time';
import { DemoSp, DemoSpType } from '../utils/DemoSp';
import { Const } from './Const';
import { demologe, demologi, DemoUtil, getNetworkType, getRealRepId, getUserSetRepId, getWayneBriefVodStatJson, getWaynePlayerTsJson, getWayneVodStatJson, numberToMKB, showErrorDialog, startVodDebugMonitor, stopVodDebugMonitor } from '../utils/DemoUtil';
import { LogItem } from '../data/LogItem';
import { ActionQueue } from '../utils/ActionQueue';
import { DemoPlayerState } from '../data/DemoData';
import { DemoPlayerStateGet } from '../data/DemoData';
import { DemoNetworkType } from '../data/DemoNetworkType';
import { EventConvert } from '../utils/EventConvert';

const TAG = 'VideoPlayActivity';

@Entry
@Component
struct VideoPlayActivity {
  @State tabIdx: number = 0;
  @State statJson: string = '';
  @State playerState: DemoPlayerState[] = [{ key: "a", value: "A" }, { key: "b", value: "B" }, { key: "c", value: "C" }];
  @State isSeeking: boolean = false;
  @State currentPosition: number = 0;
  @State duration: number = 0;
  @State volume: number = 1.0
  @State mute: boolean = false
  @State looping: boolean = false
  @State playing: boolean = false
  @State playerWidth: number = 720;
  @State playerHeight: number = 1280;
  @State speedIndex: number = 2
  @State mLogList: LogItem[] = [];
  @State mUserRepId: number = -1
  @State mRealRepId: number = -1
  @State qualityList: KSRepresentation[] = [];
  @State mPlayingUrl?: string = ""
  @State mCacheKey?: string = ""
  @State mBufferPercent: number = 0
  @State mInitCacheSize: number = 0;
  private xComponentId: string = "DemoPlayerSurfaceId"
  private playerStateGetMap: DemoPlayerStateGet[] = [];
  private speedArr: Array<SelectOption> = [{ value: '0.5' }, { value: '0.75' }, { value: '1' }, { value: '1.25' }, { value: '1.5' }, { value: '2' }]
  private mediaBean: MediaBean = new MediaBean("", "", -10000)
  private vodPlayer?: IKSVodPlayer;
  private debugInfoController: KSDebugViewController = new KSDebugViewController();
  private timer = 0;
  private mSwitchingUrl: boolean = false;
  private startPlayType: KSStartPlayType = KSStartPlayType.StartOnPrepare
  private codecType = DemoSp.getInstance().getValueNumber(Const.KEY_CODEC_TYPE, VideoCodecType.DEFAULT_DECODE);
  private mBuilder: KSMediaPlayerBuilder = new KSMediaPlayerBuilder();

  aboutToAppear(): void {
    // let appconfig = DemoUtil.Uint8ArrayToString(getContext().resourceManager.getRawFileContentSync("aemonConfig.json"))
    // KSAppConfig.getInstance().updateAppConfig(appconfig)
    this.mediaBean = router.getParams() as MediaBean;
    this.mCacheKey = this.mediaBean.mCacheKey
    demologi(TAG, `lifecycle about toAppear ${BuildProfile.BUILD_MODE_NAME} ${BuildProfile.HAR_VERSION} ${JSON.stringify(this.mediaBean)}`);
    this.mInitCacheSize = KSMediaPlayerCache.getCachedSizeWithUrl(this.mediaBean.url, this.mCacheKey)
    this.initPlayer();
    this.startProgressTimer();
    this.startDebugMonitor()
  }

  onPageShow(): void {
    demologi(TAG, 'lifecycle on pageShow');
    if (this.vodPlayer?.isPaused() || this.vodPlayer?.isPrepared()) {
      this.printLog(`start play when on page show`)
      this.vodPlayer?.start();
    }
  }

  onPageHide(): void {
    demologi(TAG, 'lifecycle on pageHide');
    this.vodPlayer?.pause();
  }

  aboutToDisappear(): void {
    ActionQueue.getIns().clear();
    demologi(TAG, 'lifecycle about ToDisappear');
    this.stopDebugMonitor()
    this.vodPlayer?.stop({
      onStopComplete: (code: number) => {
        demologi(TAG, `stop finish ret=${code}`)
        this.vodPlayer?.releaseAsync();
      }
    })
    this.stopProgressTimer();
  }

  initPlayer = () => {
    let buffConfig = new PlayBufferConfig();
    buffConfig.maxBufferDurationMs = DemoSp.getInstance().getValueNumber(Const.KEY_MAX_BUFFER_DURATION_MS, -1);
    buffConfig.maxBufferTimeBspMs = DemoSp.getInstance().getValueNumber(Const.KEY_MAX_BUFFER_DURATION_BSP_MS, -1);;
    this.mBuilder.setPlayBufferConfig(buffConfig);
    let url = this.mediaBean.url
    if (this.mediaBean.playType == MediaInputType.PLAY_ITEM_MULTI_QUALITY) {
      this.mBuilder.setDataSourceList(this.mediaBean.mQualityArray, url)
    } else if (isSingleUrl(this.mediaBean.playType)) {
      this.mBuilder.setDataSourceUrl(url, this.mCacheKey)
    } else if (isManifest(this.mediaBean.playType)) {
      this.mBuilder.setDataSourceManifest(url)
    }
    this.mBuilder.setVideoId(this.mediaBean.videoId ?? `${Date.now()}`)
      .setDisableLocalCache(DemoSp.getInstance().getValueNumber(Const.KEY_HODOR_CACHE, 1) != 1)
      .setEnableAccurateSeek(DemoSp.getInstance().getValueNumber(Const.KEY_ACCURATE_SEEK, 1) == 1)
      .setStartPosition(DemoSp.getInstance().getValueNumber(Const.KEY_START_PLAY_POS, -1) * 1000)
      .setForceDecodeType(this.codecType)
      .setStartFromHistory(DemoSp.getInstance().getValueNumber(Const.KEY_PLAY_FROM_HISTORY, 0) == 1)
    if (isSingleUrl(this.mediaBean.playType)) {
      this.mBuilder.setDataSourceFetcher({
        fetch: (callback: KSDataSourceFetchCallback, reason?: KSFetchReason | undefined): void => {
          this.printLog(`fetchDataSource reason=${reason}`);
          DemoUtil.showToast(`fetchDataSource reason=${reason}`, 3000, Alignment.Center)
          callback.onSucceed("http://hwmov.a.yximgs.com/upic/2020/05/25/17/BMjAyMDA1MjUxNzI3MzRfMTA4NzI5ODA2MV8yOTI1MjgxODczMV8xXzM=_swft_B022b988b818f8462e12edf60357c66ae.mp4?tag=1-1590642115-scn-0-7hqksz4scu-6d97ccd173cb6c0a&type=hot&tt=swft&di=db8f9932&bp=10301", KSUrlType.TYPE_SINGLE_URL)
        },
        cancel: (): void => {
          demologi(TAG, `cancel fetchDataSource`);
        }
      })
    }
    this.startPlayType = DemoSp.getInstance().getValueNumber(Const.KEY_PLAY_SETTING_START_PLAY_TYPE, KSStartPlayType.StartOnPrepare);
    let forceFirstFrameRender = DemoSp.getInstance().getValueNumber(Const.KEY_ENABLE_FIRST_FRAME_FORCE_RENDER, 0) == 1
    this.mBuilder.setStartType(this.startPlayType);
    this.mBuilder.setEnableFirstFrameForceRender(forceFirstFrameRender);
    try {
      this.vodPlayer = this.mBuilder.build()
    } catch (e) {
      demologe(TAG, `build ksplayer error=${e.stack}`);
      DemoUtil.showToast(`build ksplayer error=${e.stack}`);
    }
    this.attachListeners()
    this.initStateFunction()
    this.vodPlayer?.setXComponentId(this.xComponentId);
    // play
    demologi(TAG, `start type: ${this.startPlayType}`);
    this.vodPlayer?.prepareAsync();
  }

  private attachListeners() {
    let that = this
    // 设置prepare监听
    this.vodPlayer?.setOnPreparedListener({
      onPrepared: (): void => {
        this.printLog(`listener on prepared`)
        this.mPlayingUrl = this.vodPlayer?.getCurrentPlayUrl()
        this.mCacheKey = this.mCacheKey || KSMediaPlayerCache.getCacheKey(this.mPlayingUrl ?? "");
        this.mUserRepId = getUserSetRepId(this.vodPlayer)
        this.mRealRepId = getRealRepId(this.vodPlayer)
        if (this.startPlayType != KSStartPlayType.StartOnPrepare) {
          this.printLog(`start play manually on prepared`)
          this.vodPlayer?.start();
        }
      }
    })
    // 设置多码率列表回调监听, 回调参数1: 多分辨率列表; 回调参数2: 列表里当前播放的 index >= 0
    this.vodPlayer?.setOnRepresentationListReadyListener({
      onQualityRepresentationListReady: (reps: KSRepresentation[], index: number): void => {
        demologi(TAG, `listener on qualitylistready info=${JSON.stringify(reps)} index=${index}`)
        this.printLog(`listener on qualitylistready size=${reps.length} index=${index}`)
        this.qualityList = reps;
        if (reps.length <= 1 && this.mediaBean.mQualityArray.length > reps.length) {
          this.qualityList = this.mediaBean.mQualityArray
        }
      }
    })
    // 设置分辨率变化监听
    this.vodPlayer?.setOnVideoSizeChangedListener({
      onVideoSizeChanged: (width: number, height: number, sarNum: number, sarDen: number): void => {
        this.printLog(`listener on size change w: ${width} h: ${height} sarNum: ${sarNum} sarDen: ${sarDen}`);
        if (width > 0 && height > 0) {
          this.playerWidth = width;
          this.playerHeight = height;
        }
      }
    })
    // 设置错误监听
    this.vodPlayer?.setOnErrorListener({
      onError(what: number, extra: number) {
        that.printLog(`listener on error 1=${what} 2=${extra}`)
        showErrorDialog(`on error what=${what} extra=${extra}`)
      }
    })
    // 设置播放结束监听
    this.vodPlayer?.setOnCompletionListener({
      onComplete() {
        that.printLog(`listener on complete`)
      }
    })
    // 设置播放器进度改变监听
    this.vodPlayer?.setOnProgressChangeListener({
      onProgressChanged: (currentPosition: number, duration: number): void => {
        this.duration = duration;
        this.currentPosition = currentPosition;
      }
    })
    // 设置首帧回调监听
    this.vodPlayer?.setOnFirstFrameRenderingStart({
      onFirstFrameRenderingStart: (what: number, extra: number): void => {
        that.printLog(`listener on first frame rendering start. what: ${what} extra: ${extra}`)
      }
    })
    // 设置渲染开始的监听
    this.vodPlayer?.setOnRenderingStartListener({
      onRenderingStart: (what: number, extra: number): void => {
        that.printLog(`listener on rendering start. what: ${what} extra: ${extra}`)
      }
    })
    // 设置第一帧解码完成监听
    this.vodPlayer?.setOnDecodeFirstFrame({
      onDecodeFirstFrame: (what: number, extra: number): void => {
        that.printLog(`listener on decode first frame. what: ${what} extra: ${extra}`);
      }
    })
    // 设置事件监听
    this.vodPlayer?.setOnEventListener({
      onEvent: (what: number, extra: number): void => {
        let pairInfo = EventConvert.getEventDesc(what, extra);
        that.printLog(`listener onEvent: what: ${pairInfo[0]}${pairInfo[1]}`);
        if (what == KSMediaPlayerConstants.KS_MEDIA_PLAYER_PLAYBACK_STATE_CHANGED) {
          demologi(TAG, `listener StreamlakeStateEvent player state::${extra} ${KSPlayerState[extra]}`);
          this.playing = extra == KSPlayerState.Playing ? true : false;
        } else if (what == KSMediaPlayerConstants.KS_MEDIA_PLAYER_EVENT_BUFFERING_START) {
          that.printLog(`listener onBufferingStart`);
        } else if (what == KSMediaPlayerConstants.KS_MEDIA_PLAYER_EVENT_BUFFERING_END) {
          that.printLog(`listener onBufferingEnd`);
        } else if (what == KSMediaPlayerConstants.KS_MEDIA_PLAYER_INFO_VIDEO_QUALITY_SWITCH_START) {
          this.mSwitchingUrl = true;
        } else if (what == KSMediaPlayerConstants.KS_MEDIA_PLAYER_INFO_VIDEO_QUALITY_SWITCH_END) {
          this.startDebugMonitor();
          this.mPlayingUrl = this.vodPlayer?.getCurrentPlayUrl();
          this.mCacheKey = KSMediaPlayerCache.getCacheKey(this.mPlayingUrl ?? "");
          this.printLog(`start play manually on switch end`)
          this.vodPlayer?.start();
          this.mSwitchingUrl = false;
        } else if (what ==  KSMediaPlayerConstants.KS_MEDIA_PLAYER_INFO_MEDIA_ACCURATE_SEEK_COMPLETE) {
        }
      }
    })
    // 设置buffer进度监听
    this.vodPlayer?.setOnBufferingUpdate({
      onBufferingUpdate: (percent: number): void => {
        demologi(TAG, `listener onBufferingUpdate. percent: ${percent}`);
        this.mBufferPercent = percent;
      }
    })
  }

  getCacheInfo() {
    let info = `cacheKey=${this.mCacheKey}`;
    if (isSingleUrl(this.mediaBean.playType) && this.mediaBean.mQualityArray.length <= 1) {
      info += `      cacheSizeBeforePlay=${numberToMKB(this.mInitCacheSize)}`;
    }
    return info;
  }

  initStateFunction = () => {
    this.playerStateGetMap = [
      { key: 'isPrepared', func: this.vodPlayer?.isPrepared.bind(this.vodPlayer) },
      { key: 'isPlaying', func: this.vodPlayer?.isPlaying.bind(this.vodPlayer) },
      { key: 'isPaused', func: this.vodPlayer?.isPaused.bind(this.vodPlayer) },
      { key: 'isLoop', func: this.vodPlayer?.isLooping.bind(this.vodPlayer) },
      { key: 'pos', func: this.vodPlayer?.getCurrentPosition.bind(this.vodPlayer) },
      { key: 'duration', func: this.vodPlayer?.getDuration.bind(this.vodPlayer) },
      { key: 'width', func: this.vodPlayer?.getVideoWidth.bind(this.vodPlayer) },
      { key: 'height', func: this.vodPlayer?.getVideoHeight.bind(this.vodPlayer) },
      { key: 'speed', func: this.vodPlayer?.getSpeed.bind(this.vodPlayer) },
      { key: 'network', func: () => DemoNetworkType[getNetworkType()] },
    ];
  }
  updateState = () => {
    if (!this.vodPlayer) {
      return;
    }
    this.playerState = this.playerStateGetMap.map(item => {
      const value: string = item.func()?.toString() || '';
      if (item.key == "isLoop") {
        this.looping = value.toLowerCase() == 'true'
      }
      // if (item.key == "isPlaying") {
      //   this.playing = value.toLowerCase() == 'true'
      // }
      if (item.key == "pos" && this.duration > 0) {
        this.currentPosition = Number(value)
      }
      return { key: item.key, value } as DemoPlayerState;
    });
    this.playerState.unshift({ key: 'startPlayType', value: `${this.startPlayType}` });
    this.playerState.unshift({ key: 'codec', value: `${this.codecType}` });
    this.playerState.push({ key: 'wayneid/kernelid', value: `${this.vodPlayer?.getPlayerId()}/${this.vodPlayer?.getKernelPlayerId()}` });
    this.playerState.push({ key: 'videoId', value: `${this.mBuilder.getVideoId()}` });
    // this.playerState.unshift({ key: 'input', value: `nil` });
  }
  printLog = (value: string) => {
    demologi(TAG, value);
    this.mLogList.unshift({
      key: Math.random(),
      playerId: `[${1}][${this.vodPlayer?.getPlayerId()}][${this.vodPlayer?.getKernelPlayerId()}]`,
      time: Date.now(),
      value
    });
    if (this.mLogList.length > 100) {
      this.mLogList.pop();
    }
  }
  clearLog = () => {
    this.mLogList = []
  }
  startProgressTimer = () => {
    this.timer = setInterval(this.updateState, 200);
  }
  stopProgressTimer = () => {
    clearInterval(this.timer);
  }

  startDebugMonitor() {
    startVodDebugMonitor(this.vodPlayer, this.debugInfoController);
  }

  stopDebugMonitor() {
    stopVodDebugMonitor(this.vodPlayer, this.debugInfoController);
  }

  @Builder
  tabBuilder(index: number, name: string) {
    Column() {
      Text(name)
        .fontSize(16)
        .fontWeight(this.tabIdx === index ? 500 : 400)
        .lineHeight(22)
        .margin({ top: 1, bottom: 1 })
      Divider()
        .strokeWidth(2)
        .color('#007DFF')
        .opacity(this.tabIdx === index ? 1 : 0)
    }.width('100%')
  }

  @Builder
  buildPlayControlView() {
    Column() {
      RelativeContainer() {
        // one
        Text(`buff:${this.mBufferPercent}%`)
          .id("idBufferPercent")
          .fontSize(9)
          .height(18)
          .textAlign(TextAlign.Center)
          .alignRules({ right: { anchor: "__container__", align: HorizontalAlign.End } })
        Text(`音量(${this.volume})`).id("idTxtVolume").fontSize(9).height(18).textAlign(TextAlign.Center)
        Slider({
          value: Math.round(this.volume * 100),
          min: 0,
          max: 100,
          style: SliderStyle.OutSet
        })
          .height(18)
          .width(`50%`)
          .onChange((value, mode) => {
            if (mode === SliderChangeMode.End && this.vodPlayer) {
              let vlTmp = value / 100.0
              this.volume = Math.floor(vlTmp * 10) / 10.0 // 保留一位小数
              this.vodPlayer.setVolume(vlTmp, vlTmp);
            }
          })
          .alignRules({ left: { anchor: "idTxtVolume", align: HorizontalAlign.End }, })
          .id("idVolumeBar")
        Image(this.mute ? $r('app.media.mute') : $r('app.media.unmute'))
          .width(25)
          .height(18)
          .margin({ left: 7, right: 7 })
          .alignRules({ left: { anchor: "idVolumeBar", align: HorizontalAlign.End } })
          .onClick(() => {
            if (this.vodPlayer) {
              this.mute = !this.mute
              let vlTmp = this.mute ? 0 : this.volume
              this.vodPlayer.setMute(this.mute);
            }
          })
          .margin({ left: 5 })
          .id("idImgMute")

        Select(this.speedArr)
          .value(`速度(${this.speedArr[this.speedIndex].value})`)
          .selected(this.speedIndex)
          .constraintSize({ minHeight: 15 })
          .height(18)//.controlSize(ControlSize.SMALL)
          .font({ size: 11, weight: 500 })
          .fontColor(0x0000FF)
          .selectedOptionFont({ size: 11, weight: 400 })
          .optionFont({ size: 9, weight: 400 })
          .alignRules({ left: { anchor: "idImgMute", align: HorizontalAlign.End } })
          .onSelect((index: number) => {
            this.speedIndex = index
            let speedVal = Number(this.speedArr[index].value)
            demologi(TAG, 'Select:' + index + " value=" + speedVal)
            this.vodPlayer?.setSpeed(speedVal)
          })
          .id("idSpeedSelect")

        // two
        RelativeContainer() {
          Text(`${formatTime(this.currentPosition)} / ${formatTime(this.duration)}`)
            .fontColor(Color.Red)
            .fontSize(12).maxLines(1)
            .height(15)
            .padding(0).width('auto')
            .id("idTxtPlayProgress")
          Slider({
            value: Math.round(this.currentPosition / this.duration * 100),
            min: 0,
            max: 100,
            style: SliderStyle.OutSet
          })
            .height(15).margin({right:10})
            .alignRules({ left: { anchor: "idTxtPlayProgress", align: HorizontalAlign.End }, right: { anchor: "__container__", align: HorizontalAlign.End } })
            .onChange((value, mode) => {
              if (mode === SliderChangeMode.End && this.duration && this.vodPlayer) {
                let targetPos = this.duration * (value / 100)
                this.printLog(`start seek to ${targetPos}`)
                this.vodPlayer.seekTo(targetPos);
              }
            })
            .id("idPosBar")
          }
        .height(27).padding({ top: 5, bottom: 5 }).align(Alignment.Center).margin({ top: 3 })
        .alignRules({ top: { anchor: "idSpeedSelect", align: VerticalAlign.Bottom }, right: { anchor: "__container__", align: HorizontalAlign.End } }).id("idPlayProContainer")

        Toggle({ type: ToggleType.Button, isOn: this.looping }) {
          Text('Loop').fontColor('#182431').fontSize(12).padding({ left: 5, right: 5 })
        }.onChange((isOn: boolean) => {
          this.vodPlayer?.setLooping(isOn)
        }).margin({ top: 12, left: 0 }).alignRules({ top: { anchor: "idPlayProContainer", align: VerticalAlign.Bottom } }).id("idLoop")

        Button("stopPlay", { type: ButtonType.Normal })
          .onClick(() => {
            this.vodPlayer?.stop();
          })
          .margin({ top: 12, left: 6 })
          .height(30)
          .border({ color: 0x317aff, width: 1, radius: 4 })
          .fontSize(12)
          .alignRules({ top: { anchor: "idPlayProContainer", align: VerticalAlign.Bottom }, start: { anchor: "idLoop", align: HorizontalAlign.End } })
          .id("idStop")

        Button("restart", { type: ButtonType.Normal })
          .onClick(() => {
            this.vodPlayer?.reStart(this.currentPosition);
          })
          .margin({ top: 12, left: 6 })
          .height(30)
          .border({ color: 0x317aff, width: 1, radius: 4 })
          .fontSize(12)
          .alignRules({ top: { anchor: "idPlayProContainer", align: VerticalAlign.Bottom }, start: { anchor: "idStop", align: HorizontalAlign.End } })
          .id("idReStart")

        Button("clearLog", { type: ButtonType.Normal })
          .onClick(() => {
            this.clearLog()
          })
          .margin({ top: 12, left: 6 })
          .height(30)
          .border({ color: 0x317aff, width: 1, radius: 4 })
          .fontSize(12)
          .alignRules({ top: { anchor: "idPlayProContainer", align: VerticalAlign.Bottom }, start: { anchor: "idReStart", align: HorizontalAlign.End } })
          .id("idClsLog")

        // Button("retry", { type: ButtonType.Normal })
        //   .onClick(() => {
        //     this.vodPlayer?.retryPlayback()
        //   })
        //   .margin({ top: 12, left: 10 })
        //   .padding(0)
        //   .height(30)
        //   .border({ color: 0x317aff, width: 1, radius: 4 })
        //   .fontSize(12)
        //   .alignRules({ top: { anchor: "idPlayProContainer", align: VerticalAlign.Bottom }, start: { anchor: "idClsLog", align: HorizontalAlign.End } })
        //   .id("idRetry")
        Image(this.playing ? $r("app.media.playing") : $r('app.media.paused'))
          .onClick(() => {
            if (this.vodPlayer?.isPaused() || !this.vodPlayer?.isPlaying() && !this.vodPlayer?.isPaused()) {
              this.vodPlayer?.start();
            } else {
              this.vodPlayer?.pause();
            }
          })
          .height(30)
          .margin({ right: 1, top: 12 })
          .alignRules({ right: { anchor: "__container__", align: HorizontalAlign.End }, top: { anchor: "idPlayProContainer", align: VerticalAlign.Bottom } })
          .id("idBtnPlay")

      }.width(`100%`).height('auto').backgroundColor(0x1AFFEA00)
    }.width(`100%`).justifyContent(FlexAlign.End)
  }

  build() {
    RelativeContainer() {
      Scroll() {
        Column() {
          // 1 surface
          XComponent({
            id: this.xComponentId, type: 'surface', libraryname: 'AemonPlayerNapi'
          })
            .border({ width: 1, color: Color.Red })
            .width('100%')
            .aspectRatio(this.playerWidth / this.playerHeight)
            .onLoad((event?: object) => {
              this.vodPlayer?.setXComponentId(this.xComponentId);
              const info: KSSurfaceInfo = new KSSurfaceInfo("", -1, -1) // this.vodPlayer?.getSurfaceInfoFromXComponentId(this.xComponentId);
              this.printLog(`onLoad surfaceId(${this.xComponentId}) (${this.vodPlayer ? "playerOk" : "playerNull"})}`)
            })
            .onDestroy((event?: object) => {
              demologi(TAG, `AemonPlayerNapi::AttachXComponent onDestroy ${this.xComponentId}`)
              this.vodPlayer?.setXComponentId('');
            })
          // 2 state
          Grid() {
            ForEach(this.playerState, (item: DemoPlayerState, index: number) => {
              GridItem() {
                Text(`${item.key}: ${item.value}`).fontSize(9).width('33%')
              }
            })
          }.margin({ top: 3 }).backgroundColor(0x3A000000)

          // 3 多分辨率列表
          Text(`${this.mPlayingUrl}`).fontSize(7).textAlign(TextAlign.Start).width('100%').align(Alignment.TopStart)
          Text(`${this.getCacheInfo()}`)
            .fontSize(7)
            .textAlign(TextAlign.Start)
            .width('100%')
            .align(Alignment.TopStart)
            .fontColor(0x317aff)
          Flex() {
            ForEach(this.qualityList, (l: KSRepresentation, i: number) => {
              Button(l.qualityType ?? `${i}`, { type: ButtonType.Normal, stateEffect: true })
                .height(24)
                .margin(4)
                .fontColor(0x317aff)
                .border({ color: 0x317aff, width: 1, radius: 4 })
                .backgroundColor(l.url === this.mPlayingUrl ? Color.Yellow : 0xFFFFFF)
                .fontSize(12)
                .onClick(() => {
                  demologi(TAG, `setRepresentation: ${l.id}`);
                  this.vodPlayer?.switchVideoQuality(l.url);
                })
            })
          }.visibility(this.qualityList.length > 1 ? Visibility.Visible : Visibility.Hidden)

          // 4 log and qos
          Tabs() {
            TabContent() {
              List({ space: 0, initialIndex: 0 }) {
                ForEach(this.mLogList, (l: LogItem, index: number) => {
                  ListItem() {
                    Column() {
                      Text(`${localTimeStr(l.time)} ${l.playerId}`).fontSize(7)
                      Text(l.value).fontSize(8).maxLines(2)
                      Divider().height(1)
                    }.alignItems(HorizontalAlign.Start)
                  }
                }, (l: LogItem) => `${l.key}_${l.playerId}_${l.time}`)
              }.listDirection(Axis.Vertical)
            }.tabBar(this.tabBuilder(0, 'callback'))

          }.onChange((index: number) => {
            this.tabIdx = index
          })
          .width('100%').height('50%').margin({ top: 1, bottom: 90 })
        }
      }.width('100%').height('100%').scrollable(ScrollDirection.Vertical)

      Column() {
        this.buildPlayControlView()
      }
      .height('auto')
      .width('100%')
      .justifyContent(FlexAlign.End)
      .align(Alignment.Bottom)
      .alignRules({ bottom: { anchor: "__container__", align: VerticalAlign.Bottom } })

    }.width('100%').height('100%')
  }
}

