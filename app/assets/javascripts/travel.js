$(window).on('load', function () {
  $(function () {
    if (document.URL.match('/')) {

      function avatar_traveling() {
        $.ajax({
          type: "GET",
          url: "/users/reload",
          dataType: "json"
        })
          .done(function (user) {
            if (user.is_moving) {
              console.log("is_moving");
              var url = "/avatars/travel"
              $.ajax({
                type: "GET",
                url: url,
                dataType: "json"
              })
                .done(function () {
                  $.ajax({
                    type: "GET",
                    url: "/avatars/reload",
                    dataType: "json"
                  })
                    .done(function (avatar_info) {
                      $('#test_curr_timetable').text(avatar_info.timetable);
                      $('#test_curr_station').text(avatar_info.sta_name);
                      $('#test_curr_location_lat').text(avatar_info.curr_lat);
                      $('#test_curr_location_long').text(avatar_info.curr_long);
                    });
                });
            };
          });
      };

      setInterval(avatar_traveling, 3000);
    };
  });
});