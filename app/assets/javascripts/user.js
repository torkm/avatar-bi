$(window).on('load', function(){
  $(function(){
    $('.start_end_btn').on("click",function(){
      if($('.start_end_btn').data('btn') === 'start'){
        $('.start_end_btn').data('btn','end');
        $('.start_end_btn').val('移動終了');
        var now = new Date;
        var day = now.getDay();
        var hour = now.getHours();
        var minutes = now.getMinutes();
        var wd = ['日', '月', '火', '水', '木', '金', '土']
        console.log(current_user);
        // console.log("("+wd[day]+")"+hour+":"+minutes);
      }else{
        $('.start_end_btn').data('btn','start');
        $('.start_end_btn').val('移動開始');
      };
    });
  })
})
