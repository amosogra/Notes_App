class GenerateSearch {
  static List<String> getSearchKeywords(String title) {
    List<String> keywordsSearchList = [];
    String temp = "";
    for (int i = 0; i < title.length; i++) {
      temp = temp + title[i];
      keywordsSearchList.add(temp);
    }
    return keywordsSearchList;
  }
}
