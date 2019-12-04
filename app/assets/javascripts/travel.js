$(window).on('load', function(){
  $(function(){
    if (document.URL.match('/')){

      function change_btn(is_moving){
        if(is_moving){
          $('.start_end_btn').data('btn','end');
          $('.start_end_btn').val('移動終了');
        }else{
          $('.start_end_btn').data('btn','start');
          $('.start_end_btn').val('移動開始');  
        };
      }

      function avatar_traveling(){
        $.ajax({
          type: "GET",
          url: "users/reload_user",
          dataType: "json"
        })
        .done(function(user){
          console.log(user.is_moving);
          change_btn(user.is_moving);
        })
      }
      
      setInterval(avatar_traveling, 1000);
    };
  });
})