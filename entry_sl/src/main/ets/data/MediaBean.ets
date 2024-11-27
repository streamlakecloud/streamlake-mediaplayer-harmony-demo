import { KSRepresentation } from '@kwai/streamlake-mediaplayer';

export namespace MediaInputType {
  export const PLAY_ITEM_VOD_SLIDE: number = -1;

  export const PLAY_ITEM_VOD_INPUT: number = -2;

  export const PLAY_ITEM_VOD_VR_INPUT: number = -3;

  export const PLAY_ITEM_LIVE_INPUT: number = -4;

  export const PLAY_ITEM_LAS_LIVE_INPUT: number = -5;

  export const PLAY_ITEM_VOD_SINGLE_URL: number = 0;

  export const PLAY_ITEM_LIVE_SINGLE_URL: number = 1;

  export const PLAY_ITEM_VOD_MANIFEST: number = 2;

  export const PLAY_ITEM_LIVE_MANIFEST: number = 3;

  export const PLAY_ITEM_HLS_SINGLE_URL: number = 4;

  export const PLAY_ITEM_HLS_MANIFEST: number = 5;

  export const PLAY_ITEM_MULTI_QUALITY: number = 6;
  export const PLAY_ITEM_LOCAL_STORAGE_AV_FILE: number = 7;
}

@Observed
export class MediaBean {
  public playType: number = MediaInputType.PLAY_ITEM_VOD_SINGLE_URL;
  public url: string = "";
  public videoId: string = "";
  public mCacheKey?: string;
  public name: string = "";
  public mQualityArray: KSRepresentation[] = [];
  public selectQualityType: string = "";
  public isPlayFromHistory: boolean = false;
  public vttUrl: string = "";

  public constructor(name: string, url: string, type: number = MediaInputType.PLAY_ITEM_VOD_SINGLE_URL) {
    this.name = name
    this.url = url;
    this.playType = type;
  }

  public setQualityArray(arr: KSRepresentation[]): MediaBean {
    this.mQualityArray = arr.slice()
    return this
  }

  public setVideoId(videoid: string): MediaBean {
    this.videoId = videoid
    return this
  }

  public setCacheKey(key?: string): MediaBean {
    this.mCacheKey = key
    return this
  }
}

export function isManifest(playType: number): boolean {
  return playType == MediaInputType.PLAY_ITEM_VOD_MANIFEST
    || playType == MediaInputType.PLAY_ITEM_LIVE_MANIFEST
    || playType == MediaInputType.PLAY_ITEM_HLS_MANIFEST
}

export function isSingleUrl(playType: number): boolean {
  return playType == MediaInputType.PLAY_ITEM_VOD_INPUT
    || playType == MediaInputType.PLAY_ITEM_VOD_VR_INPUT
    || playType == MediaInputType.PLAY_ITEM_LIVE_INPUT
    || playType == MediaInputType.PLAY_ITEM_HLS_SINGLE_URL
    || playType == MediaInputType.PLAY_ITEM_VOD_SINGLE_URL
    || playType == MediaInputType.PLAY_ITEM_LOCAL_STORAGE_AV_FILE
}

export function isLive(playType: number): boolean {
  return playType == MediaInputType.PLAY_ITEM_LIVE_SINGLE_URL
    || playType == MediaInputType.PLAY_ITEM_LIVE_MANIFEST
    || playType == MediaInputType.PLAY_ITEM_LIVE_INPUT
    || playType == MediaInputType.PLAY_ITEM_LAS_LIVE_INPUT
}

export function isInputType(type: number): boolean {
  return type <= MediaInputType.PLAY_ITEM_VOD_INPUT && type >= MediaInputType.PLAY_ITEM_LAS_LIVE_INPUT
}