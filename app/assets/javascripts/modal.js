$(function () {
  $('.modalRank__time').modaal({
    animation: 'fade',// アニメーション
    hide_close: false,// 閉じるボタンを隠す
    background: '#000',// 背景色
    overlay_opacity: 0.5,// opacity
    overlay_close: true, //モーダル背景クリック時に閉じるか
    start_open: false,  // ページロード時に表示するか
    fullscreen: false, // フルスクリーンモードにするか
    close_text: 'Close', // 閉じるボタンの文言

    // before_open: function (e) { } // 開く前に行いたい処理
    // after_open: function (modal_wrapper) { } //開いた後
    // before_close: function (modal_wrapper) { } //閉じた後
  });

  $('.modalRank__railway').modaal({
    animation: 'fade',// アニメーション
    hide_close: false,// 閉じるボタンを隠す
    background: '#000',// 背景色
    overlay_opacity: 0.5,// opacity
    overlay_close: true, //モーダル背景クリック時に閉じるか
    start_open: false,  // ページロード時に表示するか
    fullscreen: false, // フルスクリーンモードにするか
    close_text: 'Close', // 閉じるボタンの文言

    // before_open: function (e) { } // 開く前に行いたい処理
    // after_open: function (modal_wrapper) { } //開いた後
    // before_close: function (modal_wrapper) { } //閉じた後
  });

  $('.modalRank__station').modaal({
    animation: 'fade',// アニメーション
    hide_close: false,// 閉じるボタンを隠す
    background: '#000',// 背景色
    overlay_opacity: 0.5,// opacity
    overlay_close: true, //モーダル背景クリック時に閉じるか
    start_open: false,  // ページロード時に表示するか
    fullscreen: false, // フルスクリーンモードにするか
    close_text: 'Close', // 閉じるボタンの文言

    // before_open: function (e) { } // 開く前に行いたい処理
    // after_open: function (modal_wrapper) { } //開いた後
    // before_close: function (modal_wrapper) { } //閉じた後
  });
});
