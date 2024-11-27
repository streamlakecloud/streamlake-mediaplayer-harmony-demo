export function formatTime(mSec: number = 0, hasMs?: boolean, hasHour?: boolean): string {
  mSec = Math.floor(Math.max(mSec, 0)) || 0;
  let m = 0, sec = Math.floor(mSec / 1000), s = sec % 60, ms = mSec % 1000, ret: string;

  if (hasHour === true || (typeof hasHour === 'undefined' && sec >= 3600)) {
    const h = Math.floor(sec / 3600);
    m = Math.floor((sec % 3600) / 60);
    ret = `${h.toString().padStart(2, '0')}:${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`;
  } else {
    m = Math.floor(sec / 60);
    ret = `${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`;
  }

  if (hasMs) {
    ret = `${ret}.${ms.toString().padStart(3, '0')}`;
  }

  return ret;
}

export function localTimeStr(ms: number = 0): string {
  let date = new Date(ms);
  let str = date.getFullYear() + "/" + date.getMonth() + "/" + date.getDate() + " " + date.getHours() + ":" + date.getMinutes() + ":" + date.getSeconds() + ":" + date.getMilliseconds()
  return str;
}

export function liveFormatTime(date: Date):string {
  const hours = date.getHours().toString().padStart(2, '0');
  const minutes = date.getMinutes().toString().padStart(2, '0');
  const seconds = date.getSeconds().toString().padStart(2, '0');
  const milliseconds = date.getMilliseconds().toString().padStart(2, '0');
  const formattedTime = `${hours}:${minutes}:${seconds}.${milliseconds}`;
  return formattedTime;
}