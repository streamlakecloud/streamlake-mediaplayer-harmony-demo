import dataPreferences from '@ohos.data.preferences';
import { ValueType } from '@kit.ArkData';

export type DemoSpType = number | string | boolean | Array<number> | Array<string> | Array<boolean> | Uint8Array | object | bigint;

export class DemoSp {
  TAG = 'DemoSp';
  private static instance: DemoSp;
  private preferences?: dataPreferences.Preferences;

  private constructor() {
  }

  public static getInstance(): DemoSp {
    if (!DemoSp.instance) {
      DemoSp.instance = new DemoSp();
    }
    return DemoSp.instance;
  }

  init(context: Context) {
    this.preferences = dataPreferences.getPreferencesSync(context, { name: 'KSDemoPreferences' });
  }

  setValueString(key: string, value: string) {
    this.setValue(key, value);
  }

  getValueString(key: string, def_value: string): string {
    return this.getValue(key, def_value) as string;
  }

  setValueNumber(key: string, value: number) {
    this.setValue(key, value);
  }

  getValueNumber(key: string, def_value: number): number {
    return this.getValue(key, def_value) as number;
  }

  setValue(key: string, value: DemoSpType) {
    this.preferences?.put(key, value).then(() => {
      this.preferences?.flush();
    });
  }

  getValue(key: string, def_value: DemoSpType): DemoSpType {
    let value: DemoSpType = def_value;
    value = this.preferences?.getSync(key, value) as DemoSpType;
    if (typeof value !== 'undefined') {
      return value;
    } else {
      return def_value;
    }
  }
}