import { KSMediaPlayerConfig } from '@kwai/streamlake-mediaplayer';
import { DemoData } from '../data/DemoData';
import { DemoSetItem, DemoSetTypes, SETTING_ITEM_APP_CONFIG, SETTING_ITEM_TYPE_LIVE } from '../data/DemoSetItem';
import { CustomDialogExample, demologi, DemoUtil } from '../utils/DemoUtil';
import { Const } from './Const';

const TAG: string = "Set"

@Component
struct DemoSettemView {
  @ObjectLink preItem: DemoSetItem<DemoSetTypes> | undefined;
  @ObjectLink item: DemoSetItem<DemoSetTypes>;

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start }) {
      Text('直播设置')
        .fontSize(15)
        .backgroundColor(Color.Gray)
        .textAlign(TextAlign.Center)
        .width('100%')
        .height(30)
        .visibility(this.item.type == SETTING_ITEM_TYPE_LIVE && this.preItem?.type != SETTING_ITEM_TYPE_LIVE ? Visibility.Visible : Visibility.None)
      Text('APP_CONFIG')
        .fontSize(15)
        .backgroundColor(Color.Gray)
        .textAlign(TextAlign.Center)
        .width('100%')
        .height(30)
        .visibility(this.item.type == SETTING_ITEM_APP_CONFIG && this.preItem?.type != SETTING_ITEM_APP_CONFIG ? Visibility.Visible : Visibility.None)
      Text(`${this.item.name}`)
        .width('100%')
        .height(19)
        .fontSize(17)
        .textAlign(TextAlign.Start)
        .padding({ left: 20, right: 20 })
        .margin({ top: 15 })
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxLines(1)
      Text(`${this.item.getTitle()}(${this.item.getValue()})`)
        .width('100%')
        .height(15)
        .fontSize(13)
        .padding({ left: 20, right: 20 })
        .textAlign(TextAlign.Start)
        .margin({ bottom: 15 })
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxLines(1)
    }
    .backgroundColor(0xFFFFFF)
  }
}

@Component
export struct Set {
  @State private settingList: Array<DemoSetItem<DemoSetTypes>> = DemoData.getInstance().getSettingList();

  showDialog(item: DemoSetItem<DemoSetTypes>) {
    let range: string[] = item.getRanges();
    let selected: number = item.index
    if ((item.options?.length ?? 0) <= 0) {
      if (item.type == SETTING_ITEM_APP_CONFIG) {
        AlertDialog.show({
          title: item.name,
          message: `${item.getValue()}`,
          autoCancel: true,
          alignment: DialogAlignment.Center,
          backgroundColor: 0x317aff,
          textStyle: { fontSize: 6, fontColor: Color.Red }
        })
      } else {
        let dialogController: CustomDialogController | null = new CustomDialogController({
          builder: CustomDialogExample({
            title: item.name,
            cancel: () => {
              dialogController?.close()
            },
            confirm: (value) => {
              item.defaultValue = item.isnumber ?  Number(value) : value
              item.onValueChanged(item.defaultValue)
              dialogController?.close()
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
      }
    } else {
      TextPickerDialog.show({
        range: range,
        selected: selected,
        canLoop: false,
        onAccept: (value: TextPickerResult) => {
          // 设置select为按下确定按钮时候的选中项index，这样当弹窗再次弹出时显示选中的是上一次确定的选项
          // this.select = value.index
          item.saveIndex(value.index as number);
          if (item.key == Const.KEY_LOG_LEVEL && typeof item.getValue() === 'number') {
            KSMediaPlayerConfig.setLogConfig(Number(item.getValue()))
            DemoUtil.showToast("请重启app", 2000)
          }
          console.info("TextPickerDialog:onAccept()" + JSON.stringify(value))
        },
        onCancel: () => {
          console.info("TextPickerDialog:onCancel()")
        }
      })
    }
  }

  build() {
    RelativeContainer() {
      // 1 action bar
      Text(``)
        .width('100%')
        .height(1)
        .fontSize(19)// .margin({ top: 32 })
        .textAlign(TextAlign.Center)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxLines(1)
        .alignRules({
          top: { anchor: "__container__", align: VerticalAlign.Top },
          left: { anchor: "__container__", align: HorizontalAlign.Start }
        })
        .id('actionbar')
      // 2 scroll
      Scroll() {
        Column() {
          List({ space: 1, initialIndex: 0 }) {
            ForEach(this.settingList, (item: DemoSetItem<DemoSetTypes>, index: number) => {
              ListItem() {
                DemoSettemView({
                  item: item,
                  preItem: index > 0 ? this.settingList[index - 1] : undefined
                })
              }.onClick(() => {
                this.showDialog(item);
                demologi(TAG, `ListItem item onClick:${item.name}`)
              })
            }, (item: DemoSetItem<DemoSetTypes>) => {
              return item.key + "..." + item.index;
            })
          }
          .listDirection(Axis.Vertical) // 排列方向
          .scrollBar(BarState.Auto)
          .friction(0.6)
          .edgeEffect(EdgeEffect.Spring) // 边缘效果设置为Spring
          .width('100%')
        }
      }
      .alignRules({
        top: { anchor: "actionbar", align: VerticalAlign.Bottom },
        bottom: { anchor: "__container__", align: VerticalAlign.Bottom },
        left: { anchor: "__container__", align: HorizontalAlign.Start }
      }).id('list')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(0xDCDCDC)
    .padding({ top: 0 })
  }
}