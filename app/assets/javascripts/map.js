
$(function () {
  var url = location.href;
  if ($('#gmap').size()) {
    console.log("map js");

    function getNow() {
      var now = new Date();
      var year = now.getFullYear();
      var mon = now.getMonth() + 1; //１を足すこと
      var day = now.getDate();
      var hour = now.getHours();
      var min = now.getMinutes();
      var sec = now.getSeconds();

      //出力用
      // var s = year + "年" + mon + "月" + day + "日" + hour + "時" + min + "分" + sec + "秒";
      var s = hour + "時" + min + "分" + sec + "秒"
      return s;
    }
    var user_marker;
    var avatar_marker;
    var user_circle;

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
        avatar_marker = add_marker_avatar(gmap, avatar_info.curr_lat, avatar_info.curr_long); // 最初にマーカー
        console.log('gmap initial')
      }).fail(function () {
        alert("地図の表示に失敗しました。")
      });
    });

    // 地図にマーカーを乗せる
    function add_marker_avatar(gmap, lat, long) {
      gmap.addMarker({
        lat: lat,
        lng: long,
        title: 'アバター',
        infoWindow: {
          content: getNow()
        },
        icon: {
          url: `../assets/avatar_type${gon.icon_type}.png`, //アイコンの画像パス
          scaledSize: {
            width: 50,
            height: 50
          }
        }
      });
    };
    function add_marker_user(gmap, lat, long) {
      gmap.addMarker({
        lat: lat,
        lng: long,
        title: 'ユーザー',
        infoWindow: {
          content: 'ユーザーの現在位置'
        },
        flat: true
      });
    };

    // マップの更新メソッド(アバター中心)
    function map_refresh() {
      $.ajax({
        type: "GET",
        url: "/avatars/reload",
        dataType: "json"
      })
        .done(function (avatar_info) {
          gmap.panTo(new google.maps.LatLng(avatar_info.curr_lat, avatar_info.curr_long));
          gmap.removeMarkers(avatar_marker); //古いの消去
          avatar_marker = add_marker_avatar(gmap, avatar_info.curr_lat, avatar_info.curr_long);
          console.log('gmap done')
        });
    };

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
        // マーカーを更新
        gmap.removeMarkers(user_marker);
        user_marker = add_marker_user(gmap, pos.coords.latitude, pos.coords.longitude);
        // サークルを更新
        if (user_circle) {
          user_circle.setMap(null);
        };
        user_circle = gmap.drawCircle({
          lat: pos.coords.latitude,
          lng: pos.coords.longitude,
          radius: pos.coords.accuracy,
          fillColor: 'blue',
          fillOpacity: 0.25,
          strokeWeight: 0,
          click: function (e) {
          }
        });

        // 現在地にスクロールさせる
        gmap.panTo(currentPos);

      }, function () {
        // gps 取得失敗
        alert('GPSデータを取得できませんでした');
        return false;
      });
    })


    // アバター現在地ボタン押すと 更新してアバターの場所中心で表示
    $("#gmap__panTo--avatar").on("click", map_refresh);


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
