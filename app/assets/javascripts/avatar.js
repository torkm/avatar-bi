$(window).on('load', function(){
  $(function(){
    
    function select_AvatarType(avatar_type){
      let html = `<input value="${avatar_type}" type="hidden" name="avatar[avatar_type]" id="avatar_avatar_type">`;
      $('#avatar_avatar_type').remove();
      $('.form__type-select').append(html);
    }

    function buildSelectHTML(stations){
      $('#dummy_div').remove();
      let html              = `<form name="home_station_form" id="home_station_form">
                                <select name="home_station_select" id="home_station_select">
                                  <option value="0" disabled="disabled">駅を選んでください</option>`
      $.each(stations,function(index, station){
        let each_station_html = `<option value="${station.id}">${station.name}駅  (${station.railway_jname})</option>`
        html += each_station_html;
      });
      html += ` </select>
                <div name="dummy_div">
                  <input type="text" name="dummy" id="hidden"/>
                  <input type="button" onclick="submit();" id="hidden"/>
                </div>
              </form>`
      $('#home_station_form').remove();
      $('.form__home-station-input').append(html);
      $('#home_station_select').val(0);
    };

    function buildSendHome_Station_ID(home_station){
      $('#avatar_home_station_id').remove();
      $('#avatar_curr_station_id').remove();
      $('#avatar_last_station_id').remove();
      let html = `<input value="${home_station.id}" type="hidden" name="avatar[home_station_id]" id="avatar_home_station_id">
                  <input value="${home_station.id}" type="hidden" name="avatar[curr_station_id]" id="avatar_curr_station_id">
                  <input value="${home_station.id}" type="hidden" name="avatar[last_station_id]" id="avatar_last_station_id">
                  <input value="${home_station.lat}" type="hidden" name="avatar[curr_location_lat]" id="avatar_curr_location_lat">
                  <input value="${home_station.lat}" type="hidden" name="avatar[last_location_lat]" id="avatar_last_location_lat">
                  <input value="${home_station.long}" type="hidden" name="avatar[curr_location_long]" id="avatar_curr_location_long">
                  <input value="${home_station.long}" type="hidden" name="avatar[last_location_long]" id="avatar_last_location_long">
                  `;
      $('.form__home-station-input').append(html);
    }

    let candidate_stations = [];

    $('#home_station_input-field').on("keyup", function(e){
      if($('#home_station_input-field').val()!==""){
        e.preventDefault();
        let input = $("#home_station_input-field").val();
        $.ajax({
          type: "GET",
          url: "/stations",
          data: { keyword: input },
          dataType: "json"
        })
        .done(function(stations){
          if(stations[0] !== undefined){
            let html = buildSelectHTML(stations);
            candidate_stations = stations;
          };
        });
      } else {
        $('#home_station_select').remove();
      };
    });

    $('.form__home-station-input').change('#home_station_select', function(){
      let home_station_id = $('#home_station_select').val();
      if(home_station_id !== null){
        let input = $('option:selected').text();
        $('#home_station_input-field').val(input);
        $('#home_station_select').remove();
        $.each(candidate_stations,function(index, station){
          if(station.id === Number(home_station_id)){
            buildSendHome_Station_ID(station);
          };
        });
      };
    });

    $('.form__type-select__op__img--1').on("click", function(e){
      e.preventDefault();
      $('.form__type-select__op__img--selected').removeClass('form__type-select__op__img--selected');
      $(this).addClass('form__type-select__op__img--selected');
      select_AvatarType(1);
    });

    $('.form__type-select__op__img--2').on("click", function(e){
      e.preventDefault();
      $('.form__type-select__op__img--selected').removeClass('form__type-select__op__img--selected');
      $(this).addClass('form__type-select__op__img--selected');
      select_AvatarType(2);
    });

    $('.form__type-select__op__img--3').on("click", function(e){
      e.preventDefault();
      $('.form__type-select__op__img--selected').removeClass('form__type-select__op__img--selected');
      $(this).addClass('form__type-select__op__img--selected');
      select_AvatarType(3);
    });
  });
})