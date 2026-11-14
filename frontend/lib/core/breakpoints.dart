/// 画面幅の境目(ピクセル)。画面全体の幅がこれ以上なら「広い画面」(PC・Web)として扱う
/// 使う場所: component/navbar.dart(サイドバーの出し分け)
const double kWideBreakpoint = 800;

/// 画面の中身(ナビの右側)の幅の境目。これ以上ならカードを横に並べる
/// 使う場所: community/page/community_menu_page.dart(メニューカード)
const double kContentWideBreakpoint = 800;
