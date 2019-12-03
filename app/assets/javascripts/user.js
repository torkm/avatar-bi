$(window).on('load', function(){
  $(function(){
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
        $.each(gon.avatars,function(index, avatar){
          console.log("start:"+avatar.last_station_id);
        });
      }
      // 「移動終了」ボタンを押したらそれぞれのアバターのcurr_station_idをlast_stationに保存
      else{
        $('.start_end_btn').data('btn','start');
        $('.start_end_btn').val('移動開始');
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
        });
      };
    });
  });
});
