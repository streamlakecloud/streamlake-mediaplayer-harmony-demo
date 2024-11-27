import { KSDownloadStopReason, KSDownloadTaskState, KSMediaPlayerCache, KSMediaPlayerDownloadInfo, KSMediaPlayerDownloadListener, KSPrefetcher, KSPrefetchType, strEmpty } from '@kwai/streamlake-mediaplayer';
import { ItemPreload, PreloadMock } from '../data/PreloadMock';
import { ComponentRef, demologi, DemoTabLiteralInterface, numberToMKB } from '../utils/DemoUtil';
import { router } from '@kit.ArkUI';
import { MediaBean, MediaInputType } from '../data/MediaBean';

const TAG = "PRELOADTEST"

@Component
struct ItemViewPreload {
  @ObjectLink preItem?: ItemPreload;
  @ObjectLink itemData: ItemPreload;

  build() {
    Column() {
      RelativeContainer() {
        Text(`type=${KSPrefetchType[this.itemData.type]}`).fontSize(11).id("idRowType")
        Text(`videoid=${this.itemData.videoId}`).fontSize(11).id("idRowOne").alignRules({ left: { anchor: "__container__", align: HorizontalAlign.Start }, top: { anchor: "idRowType", align: VerticalAlign.Bottom } })
        Text(`cacheKey=${this.itemData.cacheKey}`).fontSize(11).padding({ top: 3, bottom: 3 }).alignRules({ left: { anchor: "__container__", align: HorizontalAlign.Start }, top: { anchor: "idRowOne", align: VerticalAlign.Bottom } }).id("idRowTwo")
        Text(`${this.itemData.downloaded}  `)
          .fontSize(14)
          .zIndex(100)
          .fontColor(Color.Red)
          .padding({ bottom: 4 })
          .alignRules({ left: { anchor: "__container__", align: HorizontalAlign.Start }, top: { anchor: "idRowTwo", align: VerticalAlign.Bottom } })
          .id("idRowThree")
        Text(`isDone=${this.itemData.isdone}`).fontSize(13).fontColor(Color.Blue).alignRules({ left: { anchor: "__container__", align: HorizontalAlign.Start }, top: { anchor: "idRowThree", align: VerticalAlign.Bottom } }).id("idRowFour")
        Button(`开始下载`, { type: ButtonType.Normal, stateEffect: true })// .fontSize(13)
          .alignRules({ right: { anchor: "__container__", align: HorizontalAlign.End } })
          .borderRadius(5)
          .padding(5)
          .height(42)
          .align(Alignment.End)
          .onClick(() => {
            KSPrefetcher.getInstance()?.addTask(this.itemData.task);
          })
          .id('idStartPreload')
        Button(`   播放   `, { type: ButtonType.Normal, stateEffect: true })// .fontSize(13)
          .alignRules({ right: { anchor: "__container__", align: HorizontalAlign.End }, top: { anchor: "idStartPreload", align: VerticalAlign.Bottom } })
          .borderRadius(5)
          .padding(5)
          .height(45)
          .margin({ top: 11 })
          .align(Alignment.End)
          .onClick(() => {
            let type = this.itemData.type == KSPrefetchType.KS_PREFETCH_NORMAL ? MediaInputType.PLAY_ITEM_VOD_SINGLE_URL : this.itemData.type == KSPrefetchType.KS_PREFETCH_MANIFEST_VOD ? MediaInputType.PLAY_ITEM_VOD_MANIFEST : MediaInputType.PLAY_ITEM_HLS_MANIFEST;
            let url = this.itemData.type == KSPrefetchType.KS_PREFETCH_NORMAL ? this.itemData.url : this.itemData.manifest;
            let mediaBean = new MediaBean(this.itemData.videoId, url, type).setVideoId(this.itemData.videoId).setCacheKey(this.itemData.cacheKey)
            router.pushUrl({
              url: "pages/VideoPlayActivity",
              params: mediaBean
            })
          })
          .id('idStartPlay')
        Text(`${this.itemData.mTitle}`).fontSize(18).id("idTitle").padding({ right: 8, bottom: 9 }).alignRules({ right: { anchor: "idStartPlay", align: HorizontalAlign.Start }, bottom: { anchor: "idStartPlay", align: VerticalAlign.Bottom } })
      }.height('auto').padding({ bottom: 8, left: 5, right: 5 })

      Divider().height(1)
    }.width('100%').constraintSize({ maxHeight: 110 }).padding({ top: 10 })
  }
}

@Component
export struct PreloadPage {
  private childrenRef = ComponentRef.useRef<DemoTabLiteralInterface>();
  private mListener: KSMediaPlayerDownloadListener = {
    onMediaPlayerDownloadProgress: (info?: KSMediaPlayerDownloadInfo) => {
      this.updateUIWhenDownload(info, true)
    },
    onMediaPlayerDownloadFinish: (info?: KSMediaPlayerDownloadInfo) => {
      this.updateUIWhenDownload(info, false)
    }
  }
  @State mList: ItemPreload[] = PreloadMock.getIns().prepareData(this.mListener).getData();

  ref(): DemoTabLiteralInterface {
    let func: DemoTabLiteralInterface = {
      change: (i: number) => {
        if (i == 1) {
          this.updateUIWhenDownload();
          if (this.mList.length <= 2) {
            this.mList = PreloadMock.getIns().prepareData(this.mListener).getData();
          }
        }
      }
    }
    return func;
  }

  aboutToAppear(): void {
    this.childrenRef.export(this.ref());
  }

  updateUIWhenDownload(info?: KSMediaPlayerDownloadInfo, byprogress?: boolean) {
    let target = -1;
    let isdone = false;
    for (let i = 0; i < this.mList.length; i++) {
      let item = this.mList[i];
      item.cacheKey = item.cacheKey || item.task?.getCacheKey();
      if (info) {
        if (info.cacheKey == item.cacheKey) {
          target = i;
          item.isdone = isdone = info.stopReason == KSDownloadStopReason.STOP_REASON_FINISHED || info.downloadState == KSDownloadTaskState.Finished;
          // break;
        }
      }
      if (item.type == KSPrefetchType.KS_PREFETCH_NORMAL) {
        item.downloaded = `cacheSize=${numberToMKB(KSMediaPlayerCache.getCachedSizeWithUrl(item.url, item.cacheKey))}`;
      } else if (!strEmpty(item.manifest)) {
        let manifestObj: object = JSON.parse(item.manifest);
        if (Array.isArray(manifestObj["adaptationSet"]) && manifestObj["adaptationSet"].length > 0) {
          let list: object = manifestObj["adaptationSet"][0]["representation"];
          if (Array.isArray(list)) {
            for (let j = 0; j < list.length; j++) {
              let repItem: object = list[j];
              item.downloaded = (j == 0 ? "" : `${item.downloaded}   `) + `${repItem["qualityType"]}=${numberToMKB(KSMediaPlayerCache.getCachedSizeWithUrl(repItem["url"]))}`;
            }
          }
        }
      }
    }
    demologi(TAG, "zzh preload i=" + target + " byprogress?=" + byprogress + " isdone=" + isdone + " " + JSON.stringify(info));
  }

  build() {
    Column() {
      List({ space: 0, initialIndex: 0 }) {
        ForEach(this.mList, (item: ItemPreload, index: number) => {
          ListItem() {
            ItemViewPreload({
              itemData: item,
              preItem: index > 0 ? this.mList[index - 1] : undefined
            })
          }.onClick(() => {
            demologi(TAG, `ListItem item onClick:${index}`)
          })
        }, (i: ItemPreload) => `${i.videoId}_${i.type}_${i.url}_${i.manifest}`)
      }.width('100%').height('100%')
    }.width('100%').height('100%')
  }
}