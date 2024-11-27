import { DemoData } from '../data/DemoData'
import { isInputType, isLive, MediaBean, MediaInputType } from '../data/MediaBean'
import { scanBarcode } from '@kit.ScanKit'
import { scanCore } from '@kit.ScanKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { DemoUtil, demologi, demologw, CustomDialogExample, demologe } from '../utils/DemoUtil'
import { router } from '@kit.ArkUI'
import { KSMediaPlayerCache, strEmpty } from '@kwai/streamlake-mediaplayer'
import  { picker } from '@kit.CoreFileKit';

@Component
export struct DemoList {
  static TAG: string = "DemoList"
  private mDocumentPicker: picker.DocumentViewPicker = new picker.DocumentViewPicker(getContext());
  @State private playList: Array<MediaBean> = DemoData.getInstance().getPlayList()

  aboutToAppear(): void {
    demologe(DemoList.TAG, "about appear for demolist write data");
    DemoData.getInstance().registerDataUpdateCallback({
      onDataAdded: (data: MediaBean[]): void => {
        this.playList.push(...data);
      }
    })
  }

  @Builder
  buildActionBar() {
    Flex({ wrap: FlexWrap.NoWrap, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
      Text('扫码')
        .fontSize(15)
        .height('100%')
        .textAlign(TextAlign.Start)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxLines(1)
        .onClick(() => {
          // 定义扫码参数options
          let options: scanBarcode.ScanOptions =
            { scanTypes: [scanCore.ScanType.QR_CODE], enableMultiMode: true, enableAlbum: true }
          // 启动扫码，拉起扫码界面
          scanBarcode.startScan(options).then((result: scanBarcode.ScanResult) => {
            // 收到正确的扫码返回
            const value = JSON.stringify(result)
            demologi(DemoList.TAG, `[Scan Sample] Promise scan result: ${value}`);
            let url = result.originalValue;
            if (url) {
              let islive: boolean = url.indexOf(".flv") != -1;
              let isvod: boolean = url.indexOf(".mp4") != -1;
              if (!islive && !isvod) {
                DemoUtil.showToast("仅支持mp4点播和flv直播", 3000, Alignment.Center)
                return
              }
              router.pushUrl({
                url: islive ? "pages/LivePlayActivity" : "pages/VideoPlayActivity",
                params: new MediaBean("scan", url, islive ? MediaInputType.PLAY_ITEM_LIVE_SINGLE_URL : MediaInputType.PLAY_ITEM_VOD_SINGLE_URL)
              })
              // DemoUtil.createScanItem(result.originalValue, true).forEach((item: MediaBean) => {
              //   this.playList.push(item);
              // })
            }
          }).catch((error: BusinessError) => {
            demologi(DemoList.TAG, "[Scan Sample] Promise scan error: %{public}s" + JSON.stringify(error));
          });
        })
      Text(`PlayList`)
        .fontSize(19)
        .textAlign(TextAlign.Center)
        .align(Alignment.Center)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxLines(1)
      Button(`清缓存`, { type: ButtonType.Normal, stateEffect: true })
        .fontSize(13).borderRadius(5).padding(5)
        .height(40)
        // .border({ width: 1, color: Color.Blue, radius: 10 })
        .align(Alignment.End)
        // .maxLines(1)
        // .textAlign(TextAlign.End)
        .onClick(() => {
          KSMediaPlayerCache.clearCache();
        })
    }.height(48)
  }

  build() {
    RelativeContainer() {
      Row() {
        this.buildActionBar();
      }
      .width('100%')
      .height(48)
      .padding({ left: 20, right: 20 })
      .alignItems(VerticalAlign.Bottom)
      .alignRules({
        top: { anchor: "__container__", align: VerticalAlign.Top },
        left: { anchor: "__container__", align: HorizontalAlign.Start }
      })
      .id("actionbar")

      Divider()
        .alignRules({
          top: { anchor: "actionbar", align: VerticalAlign.Bottom },
        })
        .width(`100%`)
        .height(0.5)
        .id("divider")

      List({ space: 0, initialIndex: 0 }) {
        ForEach(this.playList, (item: MediaBean, index: number) => {
          ListItem() {
            Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start }) {
              Text(`${item.name}`)
                .width('100%')
                .height(22)
                .padding({ left: 15 })
                .fontSize(15)
                .textAlign(TextAlign.Start)
                .margin({ top: strEmpty(item.url) ? 8 : 10, bottom: strEmpty(item.url) ? 10 : 0 })
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .maxLines(1)
              Text(`${item.url}`)
                .width('100%')
                .height(14)
                .fontSize(10)
                .padding({ left: 15 })
                .textAlign(TextAlign.Start)
                .margin({ bottom: 10 })
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .maxLines(1)
                .visibility(strEmpty(item.url) ? Visibility.None : Visibility.Visible)
              Divider().width('100%').height(1).color(0x44000000)
              Text().width('100%').height(8).backgroundColor(0x33FF0000).visibility(isInputType(item.playType) && !isInputType(this.playList[index + 1].playType) ? Visibility.Visible : Visibility.None)
            }
            .backgroundColor(isLive(item.playType) ? 0x110000FF : Color.White)
          }.onClick(() => {
            if (item.playType == MediaInputType.PLAY_ITEM_LOCAL_STORAGE_AV_FILE) {
              this.mDocumentPicker.select({ maxSelectNumber: 1 }).then((arr: Array<string>) => {
                demologw("zzhtestrawfile", "" + arr); // file://docs/storage/Users/currentUser/Download/local.mp4
                if (arr.length > 0) {
                  let uri = arr[0]
                  let index = uri.indexOf("/storage")
                  router.pushUrl({
                    url: "pages/VideoPlayActivity",
                    params: new MediaBean("localstoragefile", uri.substring(index), item.playType)
                  })
                }
              })
            } else if (item.playType == MediaInputType.PLAY_ITEM_VOD_SLIDE) {
              router.pushUrl({ url: "pages/ShortVideoActivity", params: item })
            } else if (isInputType(item.playType)) {
              let dialogController: CustomDialogController | null = new CustomDialogController({
                builder: CustomDialogExample({
                  title: item.name,
                  cancel: () => {
                    dialogController?.close()
                  },
                  confirm: (value) => {
                    demologw("dialogController", `confirm ${value}`)
                    dialogController?.close()
                    if (strEmpty(value)) {
                      DemoUtil.showToast(`url is empty`)
                    } else {
                      router.pushUrl({
                        url: isLive(item.playType) ? "pages/LivePlayActivity" : "pages/VideoPlayActivity",
                        params: new MediaBean(item.name, value, item.playType)
                      })
                    }
                  },
                }),
                autoCancel: true,
                onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
                  console.info("dialog onWillDismiss reason=" + JSON.stringify(dismissDialogAction.reason))
                  if (dismissDialogAction.reason == DismissReason.PRESS_BACK) {
                    dismissDialogAction.dismiss()
                  }
                  if (dismissDialogAction.reason == DismissReason.TOUCH_OUTSIDE) {
                    dismissDialogAction.dismiss()
                  }
                },
                alignment: DialogAlignment.Center,
                offset: { dx: 0, dy: -20 },
                gridCount: 4,
                customStyle: false,
                cornerRadius: 10,
              })
              dialogController.open()
            } else if (!strEmpty(item.url)) {
              router.pushUrl({
                url: isLive(item.playType) ? "pages/LivePlayActivity" : "pages/VideoPlayActivity",
                params: item
              }).catch((error: Error) => {
                demologi(DemoList.TAG, `router push url error=${error}`)
              });
            }
            demologi(DemoList.TAG, `ListItem item onClick:${JSON.stringify(item)}`)
          })
        }, (item: MediaBean) => {
          return "MediaBean:" + this.playList.indexOf(item);
        })
      }
      .listDirection(Axis.Vertical) // 排列方向
      .scrollBar(BarState.Auto)
      .friction(0.6)
      .edgeEffect(EdgeEffect.Spring) // 边缘效果设置为Spring
      .width('100%')
      .alignRules({
        top: { anchor: "divider", align: VerticalAlign.Bottom },
        bottom: { anchor: "__container__", align: VerticalAlign.Bottom },
        left: { anchor: "__container__", align: HorizontalAlign.Start }
      })
      .id('list')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(0xDCDCDC)
  }
}