
$(function () {
  // if (document.URL.match('/')) {  
  var url = location.href;
  // if (url == "http://localhost:3000/") {
  if ($('#gmap').size()) {
    console.log("map js");

    ////////////////////////////////////////////
    //////  google map　クリックすると表示  ////////
    ///////////////////////////////////////////

    // Gmapsインスタンスの生成 (課金対象)
    let gmap = new GMaps({
      div: '#gmap__map', //地図を表示する要素
      lat: gon.global.curr_location_lat, //緯度
      lng: gon.global.curr_location_long, //軽度
      zoom: 16 //倍率（1～21）
    });


    // マップの更新メソッド
    function map_refresh(lat, long) {
      $.ajax({
        type: "GET",
        url: "/avatars/reload",
        dataType: "json"
      })
        .done(function (avatars) {
          gmap.panTo(new google.maps.LatLng(avatars[0].curr_location_lat, avatars[0].curr_location_long));
          console.log('gmap done')
        });
    };

    // アバター現在地ボタン押すと アバターの場所更新して表示
    $("#gmap__panTo--avatar").on("click", map_refresh);

    // ユーザー現在地ボタン押すと ユーザーの場所更新して表示
    $("#gmap__panTo--user").on("click", function () {
      // gps に対応しているかチェック
      if (!navigator.geolocation) {
        alert('GPSに対応したブラウザでお試しください');
        return false;
      };

      // gps取得開始
      navigator.geolocation.getCurrentPosition(function (pos) {
        // gps 取得成功
        // google map 初期化

        // 現在位置にピンをたてる
        var currentPos = new google.maps.LatLng(pos.coords.latitude, pos.coords.longitude);
        // 現在地にスクロールさせる
        gmap.panTo(currentPos);

      }, function () {
        // gps 取得失敗
        alert('GPSデータを取得できませんでした');
        return false;
      });
    })




    ////////////////////////////////////////////
    //////  streetビュー　クリックすると表示  ////////
    ///////////////////////////////////////////

    // ストリートビューの描画+更新ボタンの追加
    $("#panorama__option--display").on("click", function () {
      $("#panorama__option--display").empty()
      $("#panorama__option--refresh").append("ストリートビューを更新")
      $("#panorama__option").append("<input id='panorama__option--auto-refresh' type='checkbox'>自動更新")

      // Panoramaインスタンスの作成(課金対象)
      let panorama = GMaps.createPanorama({
        el: '#panorama__view', //ストリートビューを表示する要素
        lat: gon.global.curr_location_lat, //緯度
        lng: gon.global.curr_location_long, //経度
        zoom: 0, //倍率（0～2）
        pov: {
          heading: gon.global.viewangle, //水平角
          pitch: 0 //垂直角
        }
      });

      // ストリートビューの更新メソッド
      function panorama_refresh() {
        $.ajax({
          type: "GET",
          url: "/avatars/reload",
          dataType: "json"
        })
          .done(function (avatars) {
            panorama.setPosition(new google.maps.LatLng(avatars[0].curr_location_lat, avatars[0].curr_location_long));
            console.log('donee')
          });
      };

      // 更新ボタン押すと更新
      $("#panorama__option--refresh").on("click", panorama_refresh);

      // チェックボックス入れるとストリートビュー自動更新
      $("#panorama__option--auto-refresh").on('click', function () {
        if ($(this).prop("checked")) {
          console.log('checked')
          autoPanoramaRefresh = setInterval(panorama_refresh, 5000);
        } else {
          clearInterval(autoPanoramaRefresh);
        };
      });
    });

  };
});
