class RecentUser {
  final String icon, name, date, size;

  RecentUser({required this.icon, required this.name, required this.date, required this.size});
}

List demoRecentFiles = [
  RecentUser(
    icon: "assets/Icons/xd_file.svg",
    name: "XD File",
    date: "01-03-2021",
    size: "3.5mb",
  ),
  RecentUser(
    icon: "assets/Icons/Figma_file.svg",
    name: "Figma File",
    date: "27-02-2021",
    size: "19.0mb",
  ),
  RecentUser(
    icon: "assets/Icons/doc_file.svg",
    name: "Documents",
    date: "23-02-2021",
    size: "32.5mb",
  ),
  RecentUser(
    icon: "assets/Icons/sound_file.svg",
    name: "Sound File",
    date: "21-02-2021",
    size: "3.5mb",
  ),
  RecentUser(
    icon: "assets/Icons/media_file.svg",
    name: "Media File",
    date: "23-02-2021",
    size: "2.5gb",
  ),
  RecentUser(
    icon: "assets/Icons/pdf_file.svg",
    name: "Sals PDF",
    date: "25-02-2021",
    size: "3.5mb",
  ),
  RecentUser(
    icon: "assets/Icons/excle_file.svg",
    name: "Excel File",
    date: "25-02-2021",
    size: "34.5mb",
  ),
];
