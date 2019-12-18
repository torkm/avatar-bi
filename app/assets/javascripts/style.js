$(function () {
  $('#show_btn').on('click', function () {
    $('.detail_not_show').addClass('indivi');
    $('.detail_show').removeClass('indivi');
  });

  $('#not_show_btn').on('click', function () {
    $('.detail_not_show').removeClass('indivi');
    $('.detail_show').addClass('indivi');
  });
})