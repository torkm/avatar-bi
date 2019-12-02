$(window).on('load', function(){
  $(function(){
    // 「移動開始」ボタンを押したら現在時刻とそれぞれのアバターのlast_station_idを取得
    $('.start_end_btn').on("click",function(){
      if($('.start_end_btn').data('btn') === 'start'){
        $('.start_end_btn').data('btn','end');
        $('.start_end_btn').val('移動終了');
        var now = new Date;
        var day = now.getDay();
        var hour = now.getHours();
        var minutes = now.getMinutes();
        var wd = ['日', '月', '火', '水', '木', '金', '土']
        $.each(gon.avatars,function(index, avatar){
          console.log(avatar.last_station_id);
        });
        
      }else{
        $('.start_end_btn').data('btn','start');
        $('.start_end_btn').val('移動開始');
        
      };
    });
  })
})
