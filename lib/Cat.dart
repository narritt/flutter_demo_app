class Cat {
  String id;
  String url;

  Cat(String id, String url){
    this.id = id;
    this.url = url;
  }

  Cat.fromJson(Map<String, dynamic> cat) {
    id = cat["id"];
    url = cat['url'];
  }

  String toString(){
    return "Cat[" + (id != null &&  url != null).toString() + "]";
  }
}
