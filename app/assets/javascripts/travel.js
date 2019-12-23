$(window).on('load', function () {
  $(function () {
    if (document.URL.match('/')) {

      function avatar_traveling() {
        if ($('#is_moving').length) {
          console.log('moving');
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
                  // 中身 keys = ["sta_id", "sta_sameAs", "sta_name", "railway", "curr_lat", "curr_long", "n_sta_id", "n_sta_name", "viewangle", "timetable", "path"]
                  if (avatar_info.sta_name == avatar_info.n_sta_name) {
                    // 現在駅==次駅 「終点につきました」
                    $('#curr_condition').text(`電車が終点${avatar_info.sta_name}駅につきました。次の電車を探しています。`);
                    $('#curr_train').text('決まっていません')
                  } else {
                    time = (new Date(eval(avatar_info.timetable)[0][1])); // 列車の発車時刻
                    // 電車は決まったがまだ乗っていない 「x駅で◯線を待っている」
                    if (new Date() < time) {
                      $('#curr_condition').text(`${avatar_info.sta_name}駅で電車を待っています。`);
                    } else {
                      //駅間走行中 「x駅とy駅の間を走っている」
                      $('#curr_condition').text(`${avatar_info.sta_name}駅から${avatar_info.n_sta_name}駅へ移動中です。`);
                    }

                    //乗っている電車
                    $('#curr_train').text(`${eval(avatar_info.timetable)[0][4]}駅
                    ${time.toLocaleTimeString()}発
                    ${avatar_info.railway}
                    ${eval(avatar_info.timetable).pop()[4]}駅行き`)

                  };

                  $('#test_curr_timetable').text(avatar_info.timetable);
                  $('#test_curr_station').text(avatar_info.sta_name);
                  $('#test_curr_location_lat').text(avatar_info.curr_lat);
                  $('#test_curr_location_long').text(avatar_info.curr_long);
                });
            });
        } else {
          $('#curr_condition').text("お休み中です");
          $('#curr_train').text('決まっていません');
        };
      }
      setInterval(avatar_traveling, 5000);
    };
  });
});