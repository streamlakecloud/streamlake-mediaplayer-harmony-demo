import { HashMap } from "@kit.ArkTS";
import http from '@ohos.net.http';
import { BusinessError, request } from "@kit.BasicServicesKit";
import { demologw, mapToQueryStr } from "./DemoUtil";

export class NetworkOperation {
  /*单例*/
  private static instance: NetworkOperation;

  public static getIns(): NetworkOperation {
    if (!NetworkOperation.instance) {
      NetworkOperation.instance = new NetworkOperation();
    }

    return NetworkOperation.instance;
  }

  request(host: string, path: string, parameters: HashMap<Object, Object> | undefined, completion: ((response: string | undefined, error: BusinessError | undefined) => void) | undefined): void {
    let url = host + path;

    let queryString: string | undefined = mapToQueryStr(parameters)
    if (queryString) {
      url = url + queryString;
    }
    demologw("demonetwork", "url=" + url)
    let httpRequest = http.createHttp();
    httpRequest.request(
      url,
      {
        method: http.RequestMethod.GET,
        header: [{
          'Content-Type': 'application/json;charset=UTF-8',
          'Accept': 'text/html,application/xhtml+xml,application/xml,application/json'
        }],
        expectDataType: http.HttpDataType.STRING,
        usingCache: true,
        priority: 1,
        connectTimeout: 30000,
        readTimeout: 30000,
      }, (err: BusinessError, data: http.HttpResponse) => {
      httpRequest.destroy();
      this.handleRequestComplete(err, data, completion);
    });
  }

  handleRequestComplete(err: BusinessError, data: http.HttpResponse, completion: ((response: string | undefined, error: BusinessError | undefined) => void) | undefined): void {
    demologw("demonetwork", "err=" + JSON.stringify(err) + " " + JSON.stringify(data))
    if (!completion) {
      return
    }

    if (!err) {
      if (data.responseCode != 200) {
        let error = new Error('com.kuaishou.open.azeroth');
        error.name = data.responseCode.toString();
        completion(undefined, err);
        return;
      }
      completion(data.result as string, undefined);
    } else {
      if (completion) {
        completion(undefined, err);
      }
    }
  }

}
