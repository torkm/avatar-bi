
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
      lat: 40, //緯度
      lng: 140, //軽度
      zoom: 16 //倍率（1～21）
    });
    // Gmap の初回描画
    $(function () {
      $.ajax({
        type: "GET",
        url: "/avatars/reload",
        dataType: "json"
      }).done(function (avatar_info) {
        gmap.panTo(new google.maps.LatLng(avatar_info.curr_lat, avatar_info.curr_long));
        add_markers(avatar_info.curr_lat, avatar_info.curr_long, avatar_info.curr_lat, avatar_info.curr_long);
        console.log('gmap initial')
      }).fail(function () {
        alert("地図の表示に失敗しました。")
      });
    });

    function add_markers(a_lat, a_long, u_lat, u_long) {
      gmap.addMarker({
        lat: a_lat,
        lng: a_long,
        title: '尾道市役所',
        infoWindow: {
          content: '<h4>尾道市役所</h4><ul><li>〒722-8501 広島県尾道市久保一丁目15-1</li><li>TEL：（0848）38-9111</li></ul>'
        },
        icon: 'app/assets/images/avatar_type2.png' //アイコンの画像パス
      });
      gmap.addMarker({
        lat: u_lat,
        lng: u_long,
        title: '尾道',
        infoWindow: {
          content: '<h4>尾道市役所</h4><ul><li>〒722-8501 広島県尾道市久保一丁目15-1</li><li>TEL：（0848）38-9111</li></ul>'
        },
        icon: 'app/assets/images/avatar_type1.png' //アイコンの画像パス
      });
    };

    // マップの更新メソッド
    function map_refresh() {
      $.ajax({
        type: "GET",
        url: "/avatars/reload",
        dataType: "json"
      })
        .done(function (avatar_info) {
          gmap.panTo(new google.maps.LatLng(avatar_info.curr_lat, avatar_info.curr_long));
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

    // チェックボックス入れるとマップ自動更新
    $("#auto-refresh").on('click', function () {
      if ($(this).prop("checked")) {
        console.log('checked_gmap')
        autoGmapRefresh = setInterval(map_refresh, 5000);
      } else {
        clearInterval(autoGmapRefresh);
      };
    });



    ////////////////////////////////////////////
    //////  streetビュー クリックすると表示  ////////
    ///////////////////////////////////////////

    // ストリートビューの描画+更新ボタンの追加
    $("#panorama__option--display").on("click", function () {
      $("#panorama__option--display").empty()
      $("#panorama__option--refresh").append("ストリートビューを更新")
      $("#panorama__option").append("<input id='panorama__option--auto-refresh' type='checkbox'>自動更新")

      // Panoramaインスタンスの作成(課金対象)
      let panorama = GMaps.createPanorama({
        el: '#panorama__view', //ストリートビューを表示する要素
        lat: 40, //緯度
        lng: 140, //経度
        zoom: 0, //倍率（0～2）
        pov: {
          heading: 0, //水平角
          pitch: 0 //垂直角
        }
      });

      //ストリートビューの初回描画
      $(function () {
        $.ajax({
          type: "GET",
          url: "/avatars/reload",
          dataType: "json"
        }).done(function (avatar_info) {
          panorama.setPov({
            heading: Number(avatar_info.viewangle), //水平角
            pitch: 0 //垂直角
          })
          panorama.setPosition(new google.maps.LatLng(avatar_info.curr_lat, avatar_info.curr_long)); console.log('street initial')
        }).fail(function () {
          alert("ストリートビューの表示に失敗しました。")
        });
      });

      // ストリートビューの更新メソッド
      function panorama_refresh() {
        $.ajax({
          type: "GET",
          url: "/avatars/reload",
          dataType: "json"
        })
          .done(function (avatar_info) {
            panorama.setPov({
              heading: Number(avatar_info.viewangle), //水平角
              pitch: 0 //垂直角
            })
            panorama.setPosition(new google.maps.LatLng(avatar_info.curr_lat, avatar_info.curr_long));
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

    ////////////////////////////////////////
    ///////////  自動更新  ///////////////////
    /////////////////////////////////////////
    // 同時に更新するか検討中






  };
});
