import { KSMediaPlayerConstants, KSPlayerState } from "@kwai/streamlake-mediaplayer";

export class EventConvert {
  public static getEventDesc(what: number, extra: number): [string, string] {
    let desc = " " + what + " ";
    let descExtra = " " + extra + " ";
    if (what == KSMediaPlayerConstants.KS_MEDIA_PLAYER_EVENT_BUFFERING_START) {
      desc += "KS_MEDIA_PLAYER_EVENT_BUFFERING_START";
    } else if (what == KSMediaPlayerConstants.KS_MEDIA_PLAYER_EVENT_BUFFERING_END) {
      desc += "KS_MEDIA_PLAYER_EVENT_BUFFERING_END";
    } else if (what == KSMediaPlayerConstants.KS_MEDIA_PLAYER_EVENT_VIDEO_RENDERING_START) {
      desc += "KS_MEDIA_PLAYER_EVENT_VIDEO_RENDERING_START";
    } else if (what == KSMediaPlayerConstants.KS_MEDIA_PLAYER_EVENT_AUDIO_RENDERING_START) {
      desc += "KS_MEDIA_PLAYER_EVENT_AUDIO_RENDERING_START";
    } else if (what == KSMediaPlayerConstants.KS_MEDIA_PLAYER_INFO_VIDEO_RENDERING_START_AFTER_SEEK) {
      desc += "KS_MEDIA_PLAYER_INFO_VIDEO_RENDERING_START_AFTER_SEEK";
    } else if (what == KSMediaPlayerConstants.KS_MEDIA_PLAYER_INFO_AUDIO_RENDERING_START_AFTER_SEEK) {
      desc += "KS_MEDIA_PLAYER_INFO_AUDIO_RENDERING_START_AFTER_SEEK";
    } else if (what == KSMediaPlayerConstants.KS_MEDIA_PLAYER_INFO_PLAY_TO_END) {
      desc += "KS_MEDIA_PLAYER_INFO_PLAY_TO_END";
    } else if (what == KSMediaPlayerConstants.KS_MEDIA_PLAYER_INFO_VIDEO_QUALITY_SWITCH_START) {
      desc += "KS_MEDIA_PLAYER_INFO_VIDEO_QUALITY_SWITCH_START";
    } else if (what == KSMediaPlayerConstants.KS_MEDIA_PLAYER_INFO_VIDEO_QUALITY_SWITCH_END) {
      desc += "KS_MEDIA_PLAYER_INFO_VIDEO_QUALITY_SWITCH_END";
    } else if (what == KSMediaPlayerConstants.KS_MEDIA_PLAYER_INFO_MEDIA_ACCURATE_SEEK_COMPLETE) {
      desc += "KS_MEDIA_PLAYER_INFO_MEDIA_ACCURATE_SEEK_COMPLETE";
    } else if (what == KSMediaPlayerConstants.KS_MEDIA_PLAYER_PLAYBACK_STATE_CHANGED) {
      desc += "KS_MEDIA_PLAYER_PLAYBACK_STATE_CHANGED";
    } else if (what == KSMediaPlayerConstants.KS_MEDIA_PLAYER_INFO_HTTP_CONNECT_TIME_MS) {
      desc += "KS_MEDIA_PLAYER_INFO_HTTP_CONNECT_TIME_MS";
    } else if (what == KSMediaPlayerConstants.KS_MEDIA_PLAYER_RETRY_PLAY_START) {
      desc += "KS_MEDIA_PLAYER_RETRY_PLAY_START";
    } else if (what == KSMediaPlayerConstants.KS_MEDIA_PLAYER_RETRY_PLAY_END) {
      desc += "KS_MEDIA_PLAYER_RETRY_PLAY_END";
    } else if (what == KSMediaPlayerConstants.KS_MEDIA_PLAYER_INFO_PLAY_CAN_LOAD_NEXT) {
      desc += "KS_MEDIA_PLAYER_INFO_PLAY_CAN_LOAD_NEXT";
    } else if (what == KSMediaPlayerConstants.KS_MEDIA_PLAYER_INFO_DECODE_FIRST_FRAME_INFO_SUCCESS) {
      desc += "KS_MEDIA_PLAYER_INFO_DECODE_FIRST_FRAME_INFO_SUCCESS";
    } else if (what == KSMediaPlayerConstants.KS_MEDIA_INFO_VIDEO_RENDERING_START_AFTER_RESUME) {
      desc += "KS_MEDIA_INFO_VIDEO_RENDERING_START_AFTER_RESUME";
    } else if (what == KSMediaPlayerConstants.KS_MEDIA_PLAYER_INFO_VIDEO_ROTATION_CHANGED) {
      desc += "KS_MEDIA_PLAYER_INFO_VIDEO_ROTATION_CHANGED";
    } else if (what == KSMediaPlayerConstants.KS_MEDIA_PLAYER_INFO_RELOADED_VIDEO_RENDERING_START) {
      desc += "KS_MEDIA_PLAYER_INFO_RELOADED_VIDEO_RENDERING_START";
    } else if (what == KSMediaPlayerConstants.KS_MEDIA_PLAYER_PRELOAD_FINISH) {
      desc += "KS_MEDIA_PLAYER_PRELOAD_FINISH";
    } else if (what == KSMediaPlayerConstants.KS_MEDIA_PLAYER_INFO_NETWORK_BANDWIDTH) {
      desc += "KS_MEDIA_PLAYER_INFO_NETWORK_BANDWIDTH";
    } else if (what == KSMediaPlayerConstants.KS_MEDIA_PLAYER_INFO_BAD_INTERLEAVING) {
      desc += "KS_MEDIA_PLAYER_INFO_BAD_INTERLEAVING";
    } else if (what == KSMediaPlayerConstants.KS_MEDIA_PLAYER_INFO_NOT_SEEKABLE) {
      desc += "KS_MEDIA_PLAYER_INFO_NOT_SEEKABLE";
    } else if (what == KSMediaPlayerConstants.KS_MEDIA_PLAYER_INFO_METADATA_UPDATE) {
      desc += "KS_MEDIA_PLAYER_INFO_METADATA_UPDATE";
    } else if (what == KSMediaPlayerConstants.KS_MEDIA_PLAYER_INFO_TIMED_TEXT_ERROR) {
      desc += "KS_MEDIA_PLAYER_INFO_TIMED_TEXT_ERROR";
    } else if (what == KSMediaPlayerConstants.KS_MEDIA_PLAYER_INFO_UNSUPPORTED_SUBTITL) {
      desc += "KS_MEDIA_PLAYER_INFO_UNSUPPORTED_SUBTITL";
    } else if (what == KSMediaPlayerConstants.KS_MEDIA_PLAYER_INFO_SUBTITLE_TIMED_OUT) {
      desc += "KS_MEDIA_PLAYER_INFO_SUBTITLE_TIMED_OUT";
    } else if (what == KSMediaPlayerConstants.KS_MEDIA_PLAYER_INFO_START) {
      desc += "KS_MEDIA_PLAYER_INFO_START";
    }

    // 解析extra
    if (what == KSMediaPlayerConstants.KS_MEDIA_PLAYER_PLAYBACK_STATE_CHANGED) {
      descExtra += KSPlayerState[extra];
    }
    return [desc, descExtra];
  }
}