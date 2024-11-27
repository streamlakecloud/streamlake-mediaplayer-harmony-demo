import { IKSLivePlayer, KSDebugView, KSDebugViewController, KSLivePlayerBuilder, KSLivePlayerState, KSLiveQualityItem, VideoCodecType, KSLiveRestartReason, KSLiveDataSourceFetchCallback } from '@kwai/streamlake-mediaplayer';
import { isManifest, MediaBean } from '../data/MediaBean';
import { router } from '@kit.ArkUI';
import { demologe, demologi, DemoUtil, injectLiveQos, showErrorDialog, showLiveDebugView } from '../utils/DemoUtil';
import { Const } from './Const';
import { DemoSp } from '../utils/DemoSp';
import { ActionQueue } from '../utils/ActionQueue';
import { DemoPlayerState } from '../data/DemoData';
import { DemoPlayerStateGet } from '../data/DemoData';
import { LogItem } from '../data/LogItem';
import { formatTime, localTimeStr } from '../utils/time';

const TAG: string = "LivePlayActivityXXX"

@Entry
@Component
struct LivePlayActivity {
  @State tabIdx: number = 0;
  @State statJson: string = '';
  @State mPlayingUrl?: string = ""
  @State private listData: KSLiveQualityItem[] = [];
  @State surfaceId: string = "LivePlayerSurfaceId"
  @State playerWidth: number = 720;
  @State playerHeight: number = 1280;
  @State volume: number = 1.0
  @State mute: boolean = false;
  @State audioOnly: boolean = false;
  @State supportAudioOnly: boolean = false;
  @State playing: boolean = false;
  @State mLogList: LogItem[] = [];
  @State playerState: DemoPlayerState[] = [];
  private livePlayer?: IKSLivePlayer;
  private timer = 0;
  private codecType = DemoSp.getInstance().getValueNumber(Const.KEY_CODEC_TYPE, VideoCodecType.DEFAULT_DECODE)
  private mediaBean: MediaBean = new MediaBean("", "", -10000)
  private debugInfoController: KSDebugViewController = new KSDebugViewController();
  private playerStateGetMap: DemoPlayerStateGet[] = [];

  aboutToAppear(): void {
    this.mediaBean = router.getParams() as MediaBean;
    demologi(TAG, `lifecycle about toAppear ${JSON.stringify(this.mediaBean)}`);
    this.initPlayer();
    this.initPlayerStateGetMap();
  }

  aboutToDisappear(): void {
    ActionQueue.getIns().clear();
    demologi(TAG, 'aboutToDisappear');
    this.livePlayer?.releaseAsync();
  }

  onPageShow(): void {
    this.livePlayer?.start();
    this.startProgressTimer();
  }

  onPageHide(): void {
    this.livePlayer?.stop();
    this.stopProgressTimer();
  }

  printLog = (value: string) => {
    demologi(TAG, value);
    this.mLogList.unshift({
      key: Math.random(),
      playerId: `[${1}][${this.livePlayer?.getPlayerId()}][${this.livePlayer?.getKernelPlayerId()}]`,
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

  private initPlayerStateGetMap() {
    if (!this.livePlayer) {
      return;
    }
    this.playerStateGetMap = [];
  }

  updateState = () => {
    if (!this.livePlayer) {
      return;
    }
    this.playing = this.livePlayer.isPlaying();
    this.mPlayingUrl = this.livePlayer.getCurrentPlayUrl();
    this.playerState = this.playerStateGetMap.map(item => {
      const value: string = item.func()?.toString() || '';
      return { key: item.key, value } as DemoPlayerState;
    });
    this.playerState.unshift({ key: 'isPlaying', value: `${this.playing}` });
    this.playerState.push({ key: 'wayneid/kernelid', value: `${this.livePlayer?.getPlayerId()}/${this.livePlayer?.getKernelPlayerId()}` });
    this.playerState.push({ key: 'width/height', value: `${this.playerWidth}/${this.playerHeight}` });
    this.playerState.push({ key: 'isMute', value: `${this.mute}` });
  }
  startProgressTimer = () => {
    this.timer = setInterval(this.updateState, 200);
    demologi(TAG, "start progressTimer timer:id" + this.timer);
  }
  stopProgressTimer = () => {
    demologi(TAG, "stopProgressTimer timer:id" + this.timer);
    clearInterval(this.timer);
  }
  private initPlayer = () => {
    let that = this
    try {
      let url = this.mediaBean.url
      let builder: KSLivePlayerBuilder = new KSLivePlayerBuilder()
      if (isManifest(this.mediaBean.playType)) {
        builder.setDataSourceManifest(url)
      } else {
        builder.setDataSource({ url: url, streamId: "123" })
      }
      builder.setLiveDecodeType(this.codecType)
      builder.setLiveDataSourceFetcher(DemoSp.getInstance().getValueNumber(Const.KEY_REFRESH_DATA_SOURCE, 1) ? {
        fetchDataSource(reason: KSLiveRestartReason, callback: KSLiveDataSourceFetchCallback) {
          that.printLog(`fetchLiveDataSource reason=${reason}`);
          DemoUtil.showToast(`fetchLiveDataSource reason=${reason}`, 3000, Alignment.Center)
          callback.onSucceed({ url: url, streamId: "123" })
        }
      } : undefined)
      this.livePlayer = builder.build()
      this.attachListeners()
    } catch (e) {
      demologe(TAG, `init liveplayer error=${e.stack}`);
      DemoUtil.showToast(`init liveplayer error=${e.stack}`);
    }
  }

  private attachListeners() {
    // 设置播放结束监听
    this.livePlayer?.setOnCompletionListener({
      onComplete: (): void => {
        this.printLog(`listener on complete`);
      }
    })
    // 设置错误监听
    this.livePlayer?.setOnErrorListener({
      onError: (what: number, extra: number): void => {
        this.printLog(`listener on error what=${what} extra=${extra}`);
        showErrorDialog(`on error what=${what} extra=${extra}`)
      }
    })
    // 设置播放视频分辨率变化监听
    this.livePlayer?.setOnVideoSizeChangedListener({
      onVideoSizeChanged: (w: number, h: number, sarNum: number, sarDen: number): void => {
        this.printLog(`listener on videosizechanged w=${w} h=${h} sarNum=${sarNum} sarDen=${sarDen}`);
        if (w > 0 && h > 0) {
          this.playerWidth = w;
          this.playerHeight = h;
          this.livePlayer?.setXComponentId(this.surfaceId)
        }
      }
    })
    // 设置渲染监听
    this.livePlayer?.setRenderListener({
      onVideoRenderingStart: (): void => {
        this.printLog(`listener on video render start`);
        // let data = this.livePlayer?.getLiveQualityList();
        // data?.forEach((value, index, array) => {
        //   this.listData.push(value);
        // });
      },
      onAudioRenderingStart: (): void => {
        this.printLog(`listener on audio render start`);
      },
      onSwitchToAudioStreamFromVideoStream: (): void => {
        this.printLog(`listener on switch to audio stream from video stream`);
      },
      onRenderingStartAfterResume: (): void => {
        this.printLog(`listener on render start after resume`);
      },
      onLivePlayViewShow: (): void => {
        this.printLog(`listener on live playview show`);
      }
    })
    // 设置播放状态变化监听
    this.livePlayer?.setStateChangeListener({
      onStateChange: (newState: KSLivePlayerState): void => {
        this.playing = newState == KSLivePlayerState.PLAYING;
        this.printLog(`listener on live state change=${newState}`);
      }
    })
    // 设置缓存信息监听
    this.livePlayer?.setBufferListener({
      onBufferStart: (): void => {
        this.printLog("listener onEvent buffer start");
      },
      onBufferEnd: (): void => {
        this.printLog("listener onEvent buffer end");
      },
      onBufferEmpty: (): void => {
        this.printLog("listener onEvent buffer empty");
      }
    });
    // 设置m3u8 url hook接口
    this.livePlayer?.setLiveRequestListener({
      onRequestBegin: (url: string): string => {
        demologe(TAG, "replace url out2: listenOnKwaiHttpRequestListener=" + url)
        return url;
      }
    })
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
        Text(`音量(${this.volume})`).id("idTxtVolume").fontSize(9).height(18).textAlign(TextAlign.Center)
        Slider({
          value: Math.round(this.volume * 100),
          min: 0,
          max: 100,
          style: SliderStyle.OutSet
        })
          .height(18)
          .width(`55%`)
          .onChange((value, mode) => {
            if (mode === SliderChangeMode.End && this.livePlayer) {
              let vlTmp = value / 100.0
              this.volume = Math.floor(vlTmp * 10) / 10.0 // 保留一位小数
              this.livePlayer.setVolume(vlTmp, vlTmp);
            }
          })
          .alignRules({ left: { anchor: "idTxtVolume", align: HorizontalAlign.End }, })
          .id("idVolumeBar")
        Image(this.mute ? $r('app.media.mute') : $r('app.media.unmute'))
          .width(25)
          .height(18)
          .alignRules({ left: { anchor: "idVolumeBar", align: HorizontalAlign.End } })
          .onClick(() => {
            if (this.livePlayer) {
              this.mute = !this.mute
              let vlTmp = this.mute ? 0 : this.volume
              this.livePlayer.setMute(this.mute);
            }
          })
          .margin({ left: 5 })
          .id("idImgMute")

        // two
        Toggle({ type: ToggleType.Button, isOn: this.audioOnly }) {
          Text('audioOnly').fontColor('#182431').fontSize(12).padding({ left: 5, right: 5 })
        }
        .onChange((isOn: boolean) => {
          // this.livePlayer?.switchAudioOnlyMode(isOn)
        })
        .margin({ top: 12, left: 0 })
        .alignRules({ top: { anchor: "idVolumeBar", align: VerticalAlign.Bottom } })
        .visibility(this.supportAudioOnly ? Visibility.Visible : Visibility.None)
        .id("idAudioOnly");

        Button("重试", { type: ButtonType.Normal })
          .onClick(() => {
            this.stopProgressTimer(); // retry
            this.livePlayer?.releaseAsync();
            this.initPlayer(); // retry
            this.livePlayer?.start(); // retry
            this.startProgressTimer(); // retry
          })
          .margin({ top: 12, left: 10 })
          .height(30)
          .border({ color: 0x317aff, width: 1, radius: 4 })
          .fontSize(12)
          .alignRules({ top: { anchor: "idVolumeBar", align: VerticalAlign.Bottom }, start: { anchor: "idAudioOnly", align: HorizontalAlign.End } })
          .id("idRestart")

        Button("clearLog", { type: ButtonType.Normal })
          .onClick(() => {
            this.clearLog()
          })
          .margin({ top: 12, left: 10 })
          .height(30)
          .border({ color: 0x317aff, width: 1, radius: 4 })
          .fontSize(12)
          .alignRules({ top: { anchor: "idVolumeBar", align: VerticalAlign.Bottom }, start: { anchor: "idRestart", align: HorizontalAlign.End } })
          .id("idClsLog")

        Image(this.playing ? $r("app.media.playing") : $r('app.media.paused'))
          .onClick(() => {
            if (!this.livePlayer?.isPlaying()) {
              this.livePlayer?.start();
            } else {
              this.livePlayer?.stop();
            }
          })
          .height(33)
          .margin({ right: 8 })
          .alignRules({ right: { anchor: "__container__", align: HorizontalAlign.End } })
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
            id: this.surfaceId,
            type: 'surface',
            libraryname: 'AemonPlayerNapi'
          })
            .width('100%')// .height('50%')
            .aspectRatio(this.playerWidth / this.playerHeight)
            .border({ width: 1, color: Color.Red })
            .onLoad((event?: object) => {
              demologi(TAG, `AemonPlayerNapi::AttachXComponent onLoad ${this.surfaceId}`)
              this.livePlayer?.setXComponentId(this.surfaceId);
            })
            .onDestroy((event?: object) => {
              demologi(TAG, `AemonPlayerNapi::AttachXComponent onDestroy ${this.surfaceId}`)
              this.livePlayer?.setXComponentId('');
            })
            .overlay()
          // 2 state
          Grid() {
            ForEach(this.playerState, (item: DemoPlayerState, index: number) => {
              GridItem() {
                Text(`${item.key}: ${item.value}`).fontSize(9).width('33%')
              }
            })
          }.margin({ top: 3 }).backgroundColor(0x3A000000)

          // 3 url
          Text(`${this.mPlayingUrl}`).fontSize(7).textAlign(TextAlign.Start).width('100%').align(Alignment.TopStart)
          // 4 log and qos
          Tabs() {
            TabContent() {
              List({ space: 0, initialIndex: 0 }) {
                ForEach(this.mLogList, (l: LogItem, index: number) => {
                  ListItem() {
                    Column() {
                      Text(`${localTimeStr(l.time)} ${l.playerId} `).fontSize(7)
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
