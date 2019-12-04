$(window).on('load', function(){
  $(function(){

    function get_and_save_timenow(string){
      var now = new Date;
      var data = "";

      if(string === "start"){
        data = { start_time: now,
                 is_moving: true};
      }else{

      };

      $.ajax({
        type: "PUT",
        url: "users/reload_user",
        data: data,
        dataType: "json"
      })
      .done(function(){
        console.log("PUT ok");
      });
    };

    function calc_total_time(diff_time){
      // current_userの情報をGETリクエストで取得
      $.ajax({
        type: "GET",
        url: "users/reload_user",
      })
      .done(function(current_user){
        url  = "users/" + current_user.id;
        var total_time_base = current_user.total_travel_time;
        var total_time = Math.round(total_time_base) + Math.round(diff_time);

        // 移動時間を保存
        $.ajax({
          type: "PUT",
          url: url,
          data: { this_travel_time:  diff_time,
                  total_travel_time: total_time},
          dataType: "json"
        });
      })
      .fail(function(){
        alert("ユーザ情報の取得に失敗しました。ページを更新してください。");
      });
    }; 

    var start_time = "";
    var end_time = "";

    $('.start_end_btn').on("click",function(){

      get_and_save_timenow($('.start_end_btn').data('btn'));

      // 「移動開始」ボタンを押したら現在時刻とそれぞれのアバターのlast_station_idを取得
      if($('.start_end_btn').data('btn') === 'start'){
        $('.start_end_btn').data('btn','end');
        $('.start_end_btn').val('移動終了');
        var now = new Date;
        // console.log(now);
        var day = now.getDay();
        var hour = now.getHours();
        var minutes = now.getMinutes();
        var wd = ['日', '月', '火', '水', '木', '金', '土']
        start_time = now.getTime();
        $.each(gon.avatars,function(index, avatar){
          // console.log("start:"+avatar.last_station_id);
        });
      }
      // 「移動終了」ボタンを押したらそれぞれのアバターのcurr_station_idをlast_stationに保存
      else{
        $('.start_end_btn').data('btn','start');
        $('.start_end_btn').val('移動開始');

        var now = new Date;
        end_time = now.getTime();
        diff = (end_time - start_time)/1000;

        $.each(gon.avatars,function(index, avatar){
          var url = "/avatars/" + avatar.id;
          $.ajax({
            type: "PUT",
            url: url,
            data: { last_station_id:    avatar.curr_station_id,
                    last_location_lat:  avatar.curr_location_lat,
                    last_location_long: avatar.curr_location_long},
            dataType: "json"
          })
          .done(function(){
          })
          .fail(function(){
            alert("ユーザ情報の保存に失敗しました。");
          });

          calc_total_time(diff);

        });
      };
    });
  });
});
