import { Const } from './Const'
import { DemoList } from './DemoList'
import { Set } from './Set'
import { DemoApp } from '../utils/DemoApp'
import { ComponentRef, demologi, DemoTabLiteralInterface } from '../utils/DemoUtil'
import { PreloadPage } from './PreloadPage'
import { HashMap } from '@kit.ArkTS'
import { NetworkOperation } from '../utils/NetworkOperation'
import { PreloadMock } from '../data/PreloadMock'

@Entry
@Component
struct KSIndex {
  @State currentIndex: number = Const.INDEX_HOME_PLAY_LIST
  private tabsController: TabsController = new TabsController();
  private childrenRef = ComponentRef.useRef<DemoTabLiteralInterface>();
  private mLastRequestManifestTime = 0;

  aboutToAppear(): void {
    DemoApp.onCreate(getContext())
    demologi("index", "testpagelifecycle index about appear");
  }

  onDidBuild(): void {
    demologi("index", "testpagelifecycle index on did build")
  }

  onPageShow(): void {
    demologi("index", "testpagelifecycle index show");
    this.childrenRef.value?.change(this.currentIndex);
    this.requestManifestData();
  }

  onPageHide(): void {
    demologi("index", "testpagelifecycle index hide");
    this.requestManifestData();
  }

  aboutToDisappear(): void {
    demologi("index", "testpagelifecycle index about disappear")
  }

  onBackPress(): boolean | void {
    demologi("index", "testpagelifecycle index backpress")
  }

  @Builder
  TabBuilder(title: string, index: number, normalImg: Resource, selectedImg: Resource) {
    Column() {
      Image(this.currentIndex == index ? selectedImg : normalImg).width(15).height(15)
      Text(title).fontColor(this.currentIndex == index ? 0x00FFFF : 0xA0000000).fontSize(14)
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    // .height($r('app.float.barHeight'))
    .onClick(() => {
      demologi("index", `hometab click tab index=${index}`)
      this.currentIndex = index
      this.tabsController.changeIndex(this.currentIndex)
    })
  }

  build() {
    Tabs({ barPosition: BarPosition.End, controller: this.tabsController, index: this.currentIndex }) {
      TabContent() {
        DemoList()
      }.tabBar(this.TabBuilder("list", Const.INDEX_HOME_PLAY_LIST, $r('app.media.startIcon'), $r("app.media.startIcon")))

      TabContent() {
        PreloadPage({ childrenRef: this.childrenRef })
      }.tabBar(this.TabBuilder("预加载", Const.INDEX_HOME_PRELOAD, $r('app.media.startIcon'), $r("app.media.startIcon")))

      TabContent() {
        Set()
      }.tabBar(this.TabBuilder("设置", Const.INDEX_HOME_PLAY_SETTING, $r('app.media.startIcon'), $r("app.media.startIcon")))
    }
    // .backgroundColor(Color.Green)
    // .barHeight($r('app.float.barHeight'))
    // .barBackgroundColor(0x220000FF)
    .barMode(BarMode.Fixed)
    .tabIndex(this.currentIndex)
    .onChange((index: number) => {
      demologi("index", `hometab change index=${index}`)
      this.currentIndex = index;
      this.childrenRef.value?.change(this.currentIndex);
      this.requestManifestData();
    })
  }

  public requestManifestData(obj?: object) {
    let now = Date.now();
    if (now - this.mLastRequestManifestTime >= 10 * 60 * 1000 || PreloadMock.getIns().getManifestData().length <= 0) { // 10分钟请求一次
      let param: HashMap<Object, Object> = new HashMap<string, Object>();
      param.set("Category", "top")
      param.set("Offset", 0)
      param.set("Limit", 5);
      let host = "https://slapi.streamlake.cn";
      NetworkOperation.getIns().request(host, "/app/play/describe_video_feed_data", param, (result: string | undefined) => {
        if (result) {
          let obj: object = JSON.parse(result);
          if (obj && obj["ResponseData"]) {
            PreloadMock.getIns().refreshManifestData(obj["ResponseData"]["videoList"]);
          }
        }
      });
      this.mLastRequestManifestTime = now;
    }
  }
}
