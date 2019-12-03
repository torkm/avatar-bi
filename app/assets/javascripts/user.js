$(window).on('load', function(){
  $(function(){

    function cal_total_time(diff_time){
      url = "users/"+gon.current_user.id
      var total_time_base = gon.current_user.total_travel_time
      if(total_time_base === null){
        total_time_base = 0;
      }
      var total_time = total_time_base + diff_time;
      $.ajax({
        type: "PUT",
        url: url,
        data: { this_travel_time:  diff_time,
                total_travel_time: total_time},
        dataType: "json"
      })
      .done(function(){
        console.log("OK");
      })
      .fail(function(){
        console.log("NG");
      });
    }; 

    var start_time = "";
    var end_time = "";

    $('.start_end_btn').on("click",function(){
      // 「移動開始」ボタンを押したら現在時刻とそれぞれのアバターのlast_station_idを取得
      if($('.start_end_btn').data('btn') === 'start'){
        $('.start_end_btn').data('btn','end');
        $('.start_end_btn').val('移動終了');
        var now = new Date;
        console.log(now);
        var day = now.getDay();
        var hour = now.getHours();
        var minutes = now.getMinutes();
        var wd = ['日', '月', '火', '水', '木', '金', '土']
        start_time = now.getTime();
        $.each(gon.avatars,function(index, avatar){
          console.log("start:"+avatar.last_station_id);
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
          // アバターテーブルでcurr_station_id,long.latが更新済みの前提
          console.log("end:"+avatar.curr_station_id); 
          var url = "/avatars/"+avatar.id;
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
          });
          cal_total_time(diff);
        });
      };
    });
  });
});
