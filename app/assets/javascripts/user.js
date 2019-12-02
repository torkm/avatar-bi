$(window).on('load', function(){
  $(function(){
    $('.start_end_btn').on("click",function(){
      if($('.start_end_btn').data('btn') === 'start'){
        $('.start_end_btn').data('btn','end');
        $('.start_end_btn').val('移動終了');
      }else{
        $('.start_end_btn').data('btn','start');
        $('.start_end_btn').val('移動開始');
      };
    });
  })
})
