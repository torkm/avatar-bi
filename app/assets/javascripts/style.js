$(function () {
  $('.detail_not_show').on('click', function () {
    $('.detail_not_show').addClass('indivi');
    $('.detail_show').removeClass('indivi');
  });

  $('.detail_show').on('click', function () {
    $('.detail_not_show').removeClass('indivi');
    $('.detail_show').addClass('indivi');
  });
})