import 'dart:convert' show json;

class Quotations {

  List<Quotation> list;

  Quotations.fromParams({this.list});

  factory Quotations(jsonStr) => jsonStr == null ? null : jsonStr is String ? new Quotations.fromJson(json.decode(jsonStr)) : new Quotations.fromJson(jsonStr);

  Quotations.fromJson(jsonRes) {
    list = jsonRes == null ? null : [];
    for (var listItem in list == null ? [] : jsonRes){
      list.add(listItem == null ? null : new Quotation.fromJson(listItem));
    }
  }

  @override
  String toString() {
    return '{"json_list": $list}';
  }
}

class Quotation {

  String changeRate;
  String changeValue;
  String contractName;
  String contractNo;
  String lastPrice;
  String preClosingPrice;

  Quotation.fromParams({this.changeRate, this.changeValue, this.contractName, this.contractNo, this.lastPrice, this.preClosingPrice});

  Quotation.fromJson(jsonRes) {
    changeRate = jsonRes['changeRate'];
    changeValue = jsonRes['changeValue'];
    contractName = jsonRes['contractName'];
    contractNo = jsonRes['contractNo'];
    lastPrice = jsonRes['lastPrice'];
    preClosingPrice = jsonRes['preClosingPrice'];
  }

  @override
  String toString() {
    return '{"changeRate": ${changeRate != null?'${json.encode(changeRate)}':'null'},"changeValue": ${changeValue != null?'${json.encode(changeValue)}':'null'},"contractName": ${contractName != null?'${json.encode(contractName)}':'null'},"contractNo": ${contractNo != null?'${json.encode(contractNo)}':'null'},"lastPrice": ${lastPrice != null?'${json.encode(lastPrice)}':'null'},"preClosingPrice": ${preClosingPrice != null?'${json.encode(preClosingPrice)}':'null'}}';
  }
}
