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
                    .done(function (avatars) {
                      var curr_id = avatars[0].curr_station_id;
                      $.ajax({
                        type: "GET",
                        url: "/stations/get_name",
                        data: { id: curr_id },
                        dataType: "json"
                      })
                        .done(function (station) {
                          console.log(station);
                          $('#test_curr_timetable').text(avatars[0].train_timetable);
                          $('#test_curr_station').text(station.name);
                          $('#test_curr_location_lat').text(avatars[0].curr_location_lat);
                          $('#test_curr_location_long').text(avatars[0].curr_location_long);
                        });
                    });
                });
            };
          });
      };

      setInterval(avatar_traveling, 3000);
    };
  });
});