

import 'package:dollar_x_app/Utils/scrapperUtil.dart';

class GetCurrency {

  Future<String> getBcv () async {
    final tasa = await ScrapperUtil.getDolarBcv();
    if (tasa != null) {
        return tasa.toStringAsFixed(2);
    }else{
      return "";
    }
  }
}
