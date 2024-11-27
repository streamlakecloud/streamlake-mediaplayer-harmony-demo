import { MediaBean } from '../data/MediaBean'
import { router } from '@kit.ArkUI';
import { demologi } from '../utils/DemoUtil';

const TAG: string = "ShortVideoAct"

@Entry
@Component
struct ShortVideoActivity {
  private mediaBean: MediaBean = new MediaBean("", "", -10000)

  aboutToAppear(): void {
    this.mediaBean = router.getParams() as MediaBean;
    demologi(TAG, `lifecycle about toAppear ${JSON.stringify(this.mediaBean)}`);
    this.initPlayer();
  }

  private initPlayer = () => {

  }

  build() {
    Text("上下滑")
  }
}