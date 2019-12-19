$(function () {
  $('#show_btn').on('click', function () {
    $('.detail_not_show').addClass('indivi');
    $('.detail_show').removeClass('indivi');
  });

  $('#not_show_btn').on('click', function () {
    $('.detail_not_show').removeClass('indivi');
    $('.detail_show').addClass('indivi');
  });

  $("[class^=detail_plus_]").on("click", function () {
    var plus_name = $(this).attr("class");
    var minus_name = plus_name.replace("detail_plus_", ".detail_minus_");

    $(this).addClass('indivi');
    $(minus_name).removeClass('indivi');

    var detail_station_name = plus_name.replace("detail_plus_", ".detail_stations_");
    $(detail_station_name).removeClass('indivi');
  });

  $("[class^=detail_minus_]").on("click", function () {
    var minus_name = $(this).attr("class");
    var plus_name = minus_name.replace("detail_minus_", ".detail_plus_");

    $(this).addClass('indivi');
    $(plus_name).removeClass('indivi');

    var detail_station_name = minus_name.replace("detail_minus_", ".detail_stations_");
    $(detail_station_name).addClass('indivi');
  });

})