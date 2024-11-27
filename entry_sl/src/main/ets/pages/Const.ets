export namespace Const {
  export const INDEX_HOME_PLAY_LIST = 0;
  export const INDEX_HOME_PRELOAD = 1;
  export const INDEX_HOME_PLAY_SETTING = 2;

  export const KEY_SCAN = "key_scan"
  export const KEY_CODEC_TYPE: string = "key_codec_type"
  export const KEY_MEDIA_CODEC_CNT: string = "key_media_codec_cnt"
  export const KEY_START_ON_PREPARED: string = "KEY_START_ON_PREPARED"
  export const KEY_KWAIVPP_FILTER: string = "KEY_KWAIVPP_FILTER"
  export const KEY_USE_NATIVE_CACHE: string = "KEY_USE_NATIVE_CACHE"
  export const KEY_HODOR_HTTP_ERROR_CALLBACK_TYPE: string = "KEY_HODOR_HTTP_ERROR_CALLBACK_TYPE"
  export const KEY_TEST_HLS_HTTP_REQUEST_LISTENER: string = "KEY_TEST_HLS_HTTP_REQUEST_LISTENER"
  export const KEY_LOG_LEVEL: string = "KEY_LOG_LEVEL"
  export const KEY_ACCURATE_SEEK: string = "KEY_ACCURATE_SEEK"
  export const KEY_PLAY_FROM_HISTORY: string = "KEY_PLAY_FROM_HISTORY"
  export const KEY_START_PLAY_POS: string = "key_start_play_pos"
  export const KEY_DEVICE_ID: string = "key_device_id"
  export const KEY_MAX_BUFFER_DURATION_MS: string = "key_max_buffer_duration_ms"
  export const KEY_MAX_BUFFER_DURATION_BSP_MS: string = "key_max_buffer_duration_bsp_ms"
  export const KEY_REP_FILTER: string = "KEY_REP_FILTER"
  export const KEY_HODOR_CACHE: string = "KEY_HODOR_CACHE"
  export const KEY_AUTO_NET_RETRY: string = "KEY_AUTO_NET_RETRY"
  export const KEY_APP_CONFIG_BASE_INFO: string = "key_app_config_base_info"
  export const KEY_ENABLE_FIRST_FRAME_FORCE_RENDER: string = "key_enable_first_frame_force_render"

  export const KEY_REFRESH_DATA_SOURCE: string = "KEY_REFRESH_DATA_SOURCE"
  export const KEY_ENABLE_QOS_MONITOR_RETRY: string = "KEY_ENABLE_QOS_MONITOR_RETRY"

  export const KEY_APP_CONFIG_VOD: string = "key_app_config_vod"
  export const KEY_APP_CONFIG_LIVE: string = "key_app_config_live"
  export const KEY_APP_CONFIG_SMARTDNSV2: string = "key_app_config_smartdnsv2"
  export const KEY_APP_CONFIG_OBIWAN: string = "key_app_config_obiwan"

  export const KEY_PLAY_SETTING_START_PLAY_TYPE = "key_start_play_type"
}

export enum DemoBooleanValue {
  BOOLEAN_NO = 0,
  BOOLEAN_YES = 1,
  BOOLEAN_UNSET = -1,
}

export enum DemoHodorHttpErrorCallbackType {
  CALLBACK_TYPE_NONE = 0,
  CALLBACK_TYPE_TS = 1,
  CALLBACK_TYPE_INJECT = 2,
}