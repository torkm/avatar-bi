$(window).on('load', function () {
  $(function () {

    // 座標を取得して保存（start or end）
    function save_now_pos(string) {
      var geo = navigator.geolocation;

      geo.getCurrentPosition(function (pos) {
        var lat = "";
        var long = "";
        lat = pos.coords.latitude;  //緯度
        long = pos.coords.longitude; //経度
        var data;
        if (string === "start") {
          data = {
            start_pos_lat: lat,
            start_pos_long: long
          };
        } else {
          data = {
            end_pos_lat: lat,
            end_pos_long: long
          };
        };
        url = "users/" + gon.current_user.id;
        $.ajax({
          type: "PUT",
          url: url,
          data: data,
          dataType: "json"
        })
          .done(function () {
          });
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
        enableHighAccuracy: true,
        timeout: 1000000,
        maximumAge: 1000
      });
    };


    // 現在日時を取得して保存（start or end）
    function save_now_time(string) {
      var now = new Date;
      var data = "";
      url = "users/" + gon.current_user.id;

      if (string === "start") {
        var html = `<div id="is_moving"></div>`
        $(".fr").append(html);
        data = {
          start_time: now,
          is_moving: true
        }
      } else {
        $("#is_moving").remove(html);
        data = {
          end_time: now,
          is_moving: false
        }
      };

      $.ajax({
        type: "PUT",
        url: url,
        data: data,
        dataType: "json"
      })
        .done(function () {
        })
        .fail(function () {
        });
      return now;
    };


    // ユーザの移動時間を算出、保存
    function calc_total_time(end_time) {
      // current_userの情報をGETリクエストで取得
      $.ajax({
        type: "GET",
        url: "users/reload",
      })
        .done(function (current_user) {
          var diff_time = (end_time - new Date(current_user.start_time)) / 1000;

          url = "users/" + current_user.id;
          var total_time_base = current_user.total_travel_time;
          var total_time = Math.round(total_time_base) + Math.round(diff_time);

          // 移動時間を保存
          $.ajax({
            type: "PUT",
            url: url,
            data: {
              this_travel_time: diff_time,
              total_travel_time: total_time
            },
            dataType: "json"
          })
            .done(function () {
            });
        })
        .fail(function () {
          alert("ユーザ情報の取得に失敗しました。ページを更新してください。");
        });
    };

    function end_travel(now_time) {
      train_timetable_empty = "";

      calc_total_time(now_time);
      $.each(gon.avatars, function (index, avatar) {
        $.ajax({
          type: "GET",
          url: "/avatars/reload",
          dataType: "json"
        }).done(function (avatar_info) {
          // 駅情報をcsvからゲットできたら、保存
          var url = "/avatars/" + avatar.id;
          $.ajax({
            type: "PUT",
            url: url,
            data: {
              last_station_id: avatar_info.sta_id,
              last_location_lat: avatar_info.curr_lat,
              last_location_long: avatar_info.curr_long,
              train_timetable: train_timetable_empty
            },
            dataType: "json"
          })
            .done(function () {
              console.log("save done");
            })
            .fail(function () {
              alert("ユーザ情報の保存に失敗しました。");
            });
        }).fail(function () {
          alert("ユーザ情報の保存に失敗しました。");
        });
      });
    }


    $('.start_end_btn').on("click", function () {
      // ボタン押下で現在時刻と座標を保存
      var now_time = save_now_time($('.start_end_btn').data('btn'));
      save_now_pos($('.start_end_btn').data('btn'));

      // 「移動開始」ボタンを押したら現在時刻とそれぞれのアバターのlast_station_idを取得
      if ($('.start_end_btn').data('btn') === 'start') {
        $('.start_end_btn').data('btn', 'end');
        $('.start_end_btn').val('移動終了');
      }
      // 「移動終了」ボタンを押したらそれぞれのアバターのcurr_station_idをlast_stationに保存
      // train_timetableを削除
      else {
        $('.start_end_btn').data('btn', 'start');
        $('.start_end_btn').val('移動開始');
        end_travel(now_time);
      };
    });

  });
});
