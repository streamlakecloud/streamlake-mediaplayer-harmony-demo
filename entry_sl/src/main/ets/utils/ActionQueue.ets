// 目前仅支持简单的按顺序执行，还不支持自定义时间戳执行
export class ActionQueue {
  private static sIns: ActionQueue
  private mRunning = false
  private mArr: Array<RunInfo> = []

  private constructor() {
  }

  public static getIns(): ActionQueue {
    if (!ActionQueue.sIns) {
      ActionQueue.sIns = new ActionQueue()
    }
    return ActionQueue.sIns
  }

  private executeNext() {
    let runinfo = this.mArr.shift()
    console.warn("sl_player", "testactionqueue ")
    if (runinfo) {
      runinfo.run()
      setTimeout(() => {
        this.executeNext()
      }, runinfo.duration)
    } else {
      this.mRunning = false
    }
  }

  public enqueue(runinfo: RunInfo) {
    this.mArr.push(runinfo)
    if (!this.mRunning) {
      this.mRunning = true
      this.executeNext()
    }
  }

  public clear() {
    this.mArr = []
  }
}

export interface RunInfo {
  run: () => void
  duration: number
}