import { DemoSp } from '../utils/DemoSp';

export type DemoSetTypes = string | number

export const SETTING_ITEM_TYPE_NORMAL = 0
export const SETTING_ITEM_TYPE_LIVE = 1
export const SETTING_ITEM_APP_CONFIG = 2

@Observed
export abstract class DemoSetItem<T extends DemoSetTypes> {
  public type: number = SETTING_ITEM_TYPE_NORMAL;
  public name: string = "";
  public key: string = "";
  public index: number = -1;
  public defaultValue?: T;
  public options?: Array<[T, string]>;
  public isnumber: boolean = true;

  abstract init(defaultValue: T): void;

  abstract onValueChanged(value: T): void;

  getTitle(): string {
    if (this.index == -1) {
      return this.name;
    }
    return this.options?.[this.index][1] ?? this.name;
  }

  getValue(): T | undefined {
    if (this.index == -1) {
      return this.defaultValue;
    }
    return this.options?.[this.index][0] ?? this.defaultValue;
  }

  getRanges(): Array<string> {
    let ret = new Array<string>();
    this.options?.forEach((value: [T, string]) => {
      ret.push(value[1] + "(" + value[0] + ")");
    })
    return ret;
  }

  saveIndex(index: number) {
    if (index != this.index) {
      this.index = index;
      if (this.index != -1) {
        let value: T | undefined = this.getValue();
        if (value != undefined) {
          this.onValueChanged(value);
        }
      }
    }
  }

  findIndexByValue(value: T, defaultIndex: number): number {
    return this.options?.findIndex((v: [T, string]) => value === v[0]) ?? defaultIndex;
  }

  setValue(value: T) {
    this.defaultValue = value
    this.index = this.findIndexByValue(value, -1);
  }
}

export class DemoSetItemString extends DemoSetItem<string> {
  init(defaultValue: string): void {
    this.setValue(DemoSp.getInstance().getValueString(this.key, defaultValue));
  }

  onValueChanged(value: string): void {
    DemoSp.getInstance().setValueString(this.key, value);
  }
}

export class DemoSetItemNumber extends DemoSetItem<number> {
  init(defaultValue: number): void {
    this.setValue(DemoSp.getInstance().getValueNumber(this.key, defaultValue));
  }

  onValueChanged(value: number): void {
    DemoSp.getInstance().setValueNumber(this.key, value);
  }
}