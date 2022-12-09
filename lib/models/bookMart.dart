class BookMart {
  late int? index = 0;
  late String content;
  late String? input = "";
  late String url;
  late bool? isDelete = false;

  BookMart(this.index, this.content, this.url, [this.isDelete, this.input]);
}
