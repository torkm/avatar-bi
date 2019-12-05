$(function () {
  var map = new Y.Map("map");
  var circle = new Y.Circle(new Y.LatLng(0, 0), new Y.Size(0, 0), { unit: "km", strokeStyle: new Y.Style("99cc99", 2, 0.7), fillStyle: new Y.Style("99cc99", 1, 0.2) })
  var geo = navigator.geolocation;
  var wid = "";
  var button = $('#location');
  var Start = function () {
    button.html('stop watchPosition');
    wid = geo.watchPosition(function (pos) {
      var lat = pos.coords.latitude;
      var lon = pos.coords.longitude;
      console.log(pos);
      var ll = new Y.LatLng(lat, lon);
      var acc = parseInt(pos.coords.accuracy, 10) / 1000;
      circle.latlng = ll;
      circle.radius = new Y.Size(acc, acc);
      circle.adjust();
      map.panTo(ll, true);
    }, function (error) {
      // エラーコードのメッセージを定義
      var errorMessage = {
        0: "原因不明のエラーが発生しました",
        1: "位置情報の取得が許可されませんでした",
        2: "電波状況などで位置情報が取得できませんでした",
        3: "位置情報の取得に時間がかかり過ぎてタイムアウトしました",
      };
      // エラーコードに合わせたエラー内容をアラート表示
      alert(errorMessage[error.code]);
    }, {
      enableHighAccuracy: false,
      timeout: 6000,
      maximumAge: 600000,
    });
  };
  var Stop = function () {
    geo.clearWatch(wid);
    wid = "";
    button.html('start watchPosition');
  };

  //  現在地取得のメソッドが使えるとき
  if (geo) {
    button.bind("click", function () {
      if (wid) Stop();
      else Start();
    }).show();
  }
  map.drawMap(new Y.LatLng(35.691052, 139.701258), 14, Y.LayerSetId.NORMAL);
  map.addFeature(circle);


  ////////////////////////////////////////////
  //////  google map　クリックすると表示  ////////
  ///////////////////////////////////////////
  let gmap = new GMaps({
    div: '#map', //地図を表示する要素
    lat: gon.curr_location_lat, //緯度
    lng: gon.curr_location_long, //軽度
    zoom: 18 //倍率（1～21）
  });

  ////////////////////////////////////////////
  //////  streetビュー　クリックすると表示  ////////
  ///////////////////////////////////////////
  $("#panorama--display").on("click", function () {
    $("#panorama--display").empty()
    $("#panorama--refresh").append("ストリートビューを更新")
    // 本来はアバターの位置だけど、今は現在地を表示
    let panorama = GMaps.createPanorama({
      el: '#panorama__view', //ストリートビューを表示する要素
      lat: gon.curr_location_lat, //緯度
      lng: gon.curr_location_long, //経度
      zoom: 0, //倍率（0～2）
      pov: {
        heading: gon.viewangle, //水平角
        pitch: 0 //垂直角
      }
    });
    $("#panorama--refresh").on("click", function () {
      // let latlng = new google.maps.LatLng(35.362456, 138.775202)
      panorama.setPosition(new google.maps.LatLng(gon.curr_location_lat, gon.curr_location_long));
    });
  })
  ////////////////////////////////////////////////////


});




$(function () {
  $('.gps_map').click(function () {
    console.log('click')
    $("sensarmap").empty()
    //GPS情報取得を開始
    navigator.geolocation.getCurrentPosition(
      function (position) {
        var ymap = new Y.Map("sensarmap");
        console.log(ymap);

        ymap.drawMap(new Y.LatLng(position.coords.latitude, position.coords.longitude), 15, Y.LayerSetId.NORMAL);

        var control = new Y.ZoomControl();
        ymap.addControl(control);

        var marker = new Y.Marker(new Y.LatLng(this.lat, this.lng));
        marker.bind('click', function (latlng) {
          alert("どりゃ");
        });
        ymap.addFeature(marker);
      }
    );
  });
});
