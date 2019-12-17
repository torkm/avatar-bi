$(window).on('load', function () {
  $(function () {
    if (document.URL.match('/')) {

      function avatar_traveling() {
        if ($('#is_moving').length) {
          console.log("is_moving");
          var url = "/avatars/travel"
          $.ajax({
            type: "GET",
            url: url,
            dataType: "json"
          }) // 場所の確認
            .done(function () {
              $.ajax({
                type: "GET",
                url: "/avatars/reload",
                dataType: "json"
              })
                .done(function (avatar_info) {
                  if (avatar_info.sta_name == avatar_info.n_sta_name) {
                    // 現在駅==次駅 「終点につきました」
                    $('#test_curr_condition').text(`電車が終点${avatar_info.sta_name}駅につきました。次の電車を探しています。`);
                  } else {
                    console.log(eval(avatar_info.timetable)[0][1])
                    // 電車は決まったがまだ乗っていない 「x駅で◯線を待っている」

                    // 駅着時間+10秒以内は「◯◯駅にいます」

                    //駅間走行中 「x駅とy駅の間を走っている」
                    $('#test_curr_condition').text(`${new Date()}現在、${avatar_info.sta_name}駅から${avatar_info.n_sta_name}駅に${avatar_info.railway}で移動中`);
                  };

                  $('#test_curr_timetable').text(avatar_info.timetable);
                  $('#test_curr_station').text(avatar_info.sta_name);
                  $('#test_curr_location_lat').text(avatar_info.curr_lat);
                  $('#test_curr_location_long').text(avatar_info.curr_long);
                });
            });
        };
      }
      setInterval(avatar_traveling, 3000);
    };
  });
});